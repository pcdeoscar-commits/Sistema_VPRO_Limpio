from typing import Dict, Any, List, Optional
from fastapi import APIRouter, HTTPException, Query
from psycopg2.extras import RealDictCursor

from core.database import get_db_cursor

router = APIRouter(tags=["📊 Dashboard"])

@router.get("/api/analitica/ceo-panel", tags=["📊 Inteligencia de Negocio / CEO"])
def obtener_analitica_panel_ceo(
    desde: str = Query(..., description="Fecha inicio YYYY-MM-DD"), 
    hasta: str = Query(..., description="Fecha fin YYYY-MM-DD")
):
    """Panel ejecutivo CEO para indicadores consolidados de rentabilidad."""
    return {
        "status": "SUCCESS", 
        "total_eventos": 0, 
        "cliente_top": "Deshabilitado", 
        "ranking_clientes": [], 
        "equipos_reparacion": 0, 
        "desviacion": "0%", 
        "top_empleados": [], 
        "taller_tracking": [], 
        "incidencias_por_depto": []
    }

@router.get("/api/dashboard/filtros")
def obtener_filtros_disponibles():
    """Retorna los departamentos y empleados disponibles para filtrar el dashboard."""
    try:
        with get_db_cursor("db_inventario_prueba") as cur_inv:
            cur_inv.execute("SELECT DISTINCT departamento FROM public.historial_equipo WHERE departamento IS NOT NULL;")
            deptos = [row[0] for row in cur_inv.fetchall()]

        with get_db_cursor("db_eventos_prueba") as cur_ev:
            cur_ev.execute("SELECT DISTINCT id_empleado FROM public.checkouts_maestro WHERE id_empleado IS NOT NULL;")
            empleados = [row[0] for row in cur_ev.fetchall()]

        return {"departamentos": deptos, "empleados": empleados}
    except Exception:
        return {"departamentos": [], "empleados": []}

@router.get("/api/dashboard/resumen")
def obtener_resumen_dashboard(
    fecha_inicio: Optional[str] = None, 
    fecha_fin: Optional[str] = None,
    departamento: Optional[str] = None,
    empleado: Optional[str] = None
):
    """Calcula todas las métricas ejecutivas de finanzas, comercial y operaciones."""
    try:
        # 1️⃣ LLAVE 1: INVENTARIO (Daños y Gastos)
        with get_db_cursor("db_inventario_prueba", cursor_factory=RealDictCursor) as cursor_inv:
            query_gastos = "SELECT COALESCE(SUM(costo_asociado), 0) as total_gastado FROM public.historial_equipo WHERE 1=1"
            params_inv = []
            if departamento and departamento != "Todos":
                query_gastos += " AND departamento = %s"
                params_inv.append(departamento)
                
            cursor_inv.execute(query_gastos, tuple(params_inv))
            gasto_total = cursor_inv.fetchone()["total_gastado"]

            cursor_inv.execute("SELECT departamento as depto, COUNT(*) as total FROM public.historial_equipo WHERE departamento IS NOT NULL GROUP BY departamento;")
            deptos_danos = cursor_inv.fetchall()

        # 2️⃣ LLAVE 2: EVENTOS (Operaciones y Comercial)
        with get_db_cursor("db_eventos_prueba", cursor_factory=RealDictCursor) as cursor_ev:
            query_ops = "SELECT COUNT(*) as total FROM public.eventos WHERE 1=1"
            params_ops = []
            if fecha_inicio and fecha_fin:
                query_ops += " AND fec_de_elaboracion_de_op BETWEEN %s AND %s"
                params_ops.extend([fecha_inicio, fecha_fin])
            else:
                query_ops += " AND EXTRACT(MONTH FROM fec_de_elaboracion_de_op) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM fec_de_elaboracion_de_op) = EXTRACT(YEAR FROM CURRENT_DATE)"
                
            cursor_ev.execute(query_ops, tuple(params_ops))
            ops_mes = cursor_ev.fetchone()["total"]

            query_chk = "SELECT COUNT(*) as total FROM public.checkouts_maestro WHERE 1=1"
            query_inc = "SELECT COUNT(*) as total FROM public.checkouts_maestro WHERE incidencias_generales IS NOT NULL AND TRIM(incidencias_generales) != ''"
            params_chk = []
            
            if fecha_inicio and fecha_fin:
                filtro_fecha = " AND fecha BETWEEN %s AND %s"
                query_chk += filtro_fecha
                query_inc += filtro_fecha
                params_chk.extend([fecha_inicio, fecha_fin])
                
            if empleado and empleado != "Todos":
                filtro_emp = " AND id_empleado = %s"
                query_chk += filtro_emp
                query_inc += filtro_emp
                params_chk.append(empleado)

            cursor_ev.execute(query_chk, tuple(params_chk))
            total_checkouts = cursor_ev.fetchone()["total"]
            
            cursor_ev.execute(query_inc, tuple(params_chk))
            checkouts_con_incidencias = cursor_ev.fetchone()["total"]
            
            if total_checkouts > 0:
                tasa_incidencias = round((checkouts_con_incidencias / total_checkouts) * 100, 1)
                logistica_tiempo = round(100 - tasa_incidencias, 1)
            else:
                tasa_incidencias, logistica_tiempo = 0, 100

            checkouts_limpios = total_checkouts - checkouts_con_incidencias
            efectividad_checkouts = [
                {"estado": "Limpios", "total": checkouts_limpios},
                {"estado": "Con Incidencias", "total": checkouts_con_incidencias}
            ] if total_checkouts > 0 else []

            cursor_ev.execute("SELECT para_q_cliente as cliente, COUNT(*) as total FROM public.eventos WHERE para_q_cliente IS NOT NULL AND TRIM(para_q_cliente) != '' GROUP BY para_q_cliente ORDER BY total DESC LIMIT 5;")
            top_clientes = cursor_ev.fetchall()
            cliente_top = top_clientes[0]["cliente"] if top_clientes else "Sin datos"
            
            cursor_ev.execute("SELECT id_empleado, COUNT(*) as total FROM public.checkouts_maestro WHERE id_empleado IS NOT NULL AND TRIM(id_empleado) != '' GROUP BY id_empleado ORDER BY total DESC LIMIT 3;")
            top_empleados_raw = cursor_ev.fetchall()

            cursor_ev.execute("SELECT TO_CHAR(fec_de_elaboracion_de_op, 'YYYY-MM') as mes, COUNT(*) as total FROM public.eventos WHERE fec_de_elaboracion_de_op IS NOT NULL GROUP BY mes ORDER BY mes ASC;")
            ops_por_mes = cursor_ev.fetchall()

        # 3️⃣ Traductor de IDs a Nombres Reales
        top_empleados = []
        empleado_top = "Sin datos"
        
        if top_empleados_raw:
            with get_db_cursor("db_personal_prueba", cursor_factory=RealDictCursor) as cursor_pers:
                cursor_pers.execute("SELECT TRIM(id_empleado) as id_emp, encode(nombre::bytea, 'hex') as nombre_hex FROM public.empleados")
                emps = cursor_pers.fetchall()
                
            def dec_hex(val):
                try: 
                    return bytes.fromhex(val).decode('utf-8')
                except Exception: 
                    return str(val)
                
            dict_empleados = {str(e['id_emp']): dec_hex(e['nombre_hex']) for e in emps if e['id_emp'] and e['nombre_hex']}
            
            for row in top_empleados_raw:
                id_e = str(row["id_empleado"]).strip()
                nombre_real = dict_empleados.get(id_e, f"ID: {id_e}")
                top_empleados.append({"empleado": nombre_real, "total": row["total"]})
                
            empleado_top = top_empleados[0]["empleado"]

        # 4️⃣ LLAVE 3: AUTOS (Flota y Seguros)
        with get_db_cursor("db_autos_prueba", cursor_factory=RealDictCursor) as cursor_autos:
            cursor_autos.execute("SELECT num_control, marca, estado_actual as estado FROM public.autos WHERE estado_actual IS NOT NULL;")
            estado_flota = cursor_autos.fetchall()
            
            autos_en_taller = 0
            for item in estado_flota:
                texto_estado = str(item['estado']).lower()
                if any(fallo in texto_estado for fallo in ['taller', 'mantenimiento', 'reparación', 'inactivo', 'apaga', 'truena', 'falla']):
                    autos_en_taller += 1

            cursor_autos.execute("SELECT COUNT(*) as vencen_pronto FROM public.autos WHERE seguro_vence BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days';")
            seguros_vencer = cursor_autos.fetchone()["vencen_pronto"]

        # 5️⃣ EMPAQUETADO FINAL
        return {
            "finanzas": {
                "gasto_mes": float(gasto_total),
                "equipos_danados": sum(d['total'] for d in deptos_danos), 
                "flota_taller": autos_en_taller, 
                "seguros_vencer": seguros_vencer, 
                "deptos_danos": deptos_danos,
                "estado_flota": estado_flota 
            },
            "comercial": {
                "ops_mes": ops_mes,
                "cliente_top": cliente_top,
                "proveedores_activos": 0,
                "top_clientes": top_clientes, 
                "ops_por_mes": ops_por_mes    
            },
            "operaciones": {
                "tasa_incidencias": tasa_incidencias,
                "logistica_tiempo": logistica_tiempo,
                "empleado_top": empleado_top,
                "top_empleados": top_empleados,
                "efectividad_checkouts": efectividad_checkouts
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

