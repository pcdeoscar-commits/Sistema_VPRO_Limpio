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
    """Panel ejecutivo CEO para indicadores consolidados de operación, clientes y taller."""
    try:
        with get_db_cursor("db_eventos", cursor_factory=RealDictCursor) as cur_ev:
            cur_ev.execute("""
                SELECT COUNT(*) AS total
                FROM public.eventos
                WHERE fec_del_evento BETWEEN %s AND %s
                  AND UPPER(COALESCE(estatus, 'ACTIVA')) NOT LIKE '%%CANCELAD%%'
            """, (desde, hasta))
            total_eventos = cur_ev.fetchone()["total"]

            cur_ev.execute("""
                SELECT para_q_cliente AS cliente, COUNT(*) AS total
                FROM public.eventos
                WHERE fec_del_evento BETWEEN %s AND %s
                  AND para_q_cliente IS NOT NULL AND TRIM(para_q_cliente) != ''
                GROUP BY para_q_cliente
                ORDER BY total DESC
                LIMIT 5
            """, (desde, hasta))
            ranking_clientes = cur_ev.fetchall()
            cliente_top = ranking_clientes[0]["cliente"] if ranking_clientes else "Sin eventos en periodo"

        with get_db_cursor("db_inventario", cursor_factory=RealDictCursor) as cur_inv:
            cur_inv.execute("""
                SELECT COUNT(*) AS total
                FROM public.reparaciones
                WHERE UPPER(COALESCE(etapa_taller, '')) NOT IN ('CERRADO', 'LIBERADO', 'COMPLETADO')
            """)
            equipos_reparacion = cur_inv.fetchone()["total"]

            cur_inv.execute("""
                SELECT COALESCE(departamento, 'General') AS depto, COUNT(*) AS total
                FROM public.historial_equipo
                GROUP BY COALESCE(departamento, 'General')
                ORDER BY total DESC
            """)
            incidencias_por_depto = cur_inv.fetchall()

        return {
            "status": "SUCCESS",
            "total_eventos": total_eventos,
            "cliente_top": cliente_top,
            "ranking_clientes": ranking_clientes,
            "equipos_reparacion": equipos_reparacion,
            "desviacion": "0%",
            "top_empleados": [],
            "taller_tracking": [],
            "incidencias_por_depto": incidencias_por_depto
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/api/dashboard/filtros")
def obtener_filtros_disponibles():
    """Retorna los departamentos y empleados disponibles para filtrar el dashboard."""
    try:
        with get_db_cursor("db_inventario") as cur_inv:
            cur_inv.execute("SELECT DISTINCT departamento FROM public.historial_equipo WHERE departamento IS NOT NULL;")
            deptos = [row[0] for row in cur_inv.fetchall()]

        with get_db_cursor("db_eventos") as cur_ev:
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
        with get_db_cursor("db_inventario", cursor_factory=RealDictCursor) as cursor_inv:
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
        with get_db_cursor("db_eventos", cursor_factory=RealDictCursor) as cursor_ev:
            query_ops = "SELECT COUNT(*) as total FROM public.eventos WHERE 1=1"
            params_ops = []
            if fecha_inicio and fecha_fin:
                query_ops += " AND fec_de_elaboracion_de_op BETWEEN %s AND %s"
                params_ops.extend([fecha_inicio, fecha_fin])
            else:
                query_ops += " AND EXTRACT(MONTH FROM fec_de_elaboracion_de_op) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM fec_de_elaboracion_de_op) = EXTRACT(YEAR FROM CURRENT_DATE)"
                
            cursor_ev.execute(query_ops, tuple(params_ops))
            ops_mes = cursor_ev.fetchone()["total"]

            query_chk = "SELECT incidencias_generales FROM public.checkouts_maestro WHERE 1=1"
            params_chk = []
            
            if fecha_inicio and fecha_fin:
                filtro_fecha = " AND fecha BETWEEN %s AND %s"
                query_chk += filtro_fecha
                params_chk.extend([fecha_inicio, fecha_fin])
                
            if empleado and empleado != "Todos":
                filtro_emp = " AND id_empleado = %s"
                query_chk += filtro_emp
                params_chk.append(empleado)

            cursor_ev.execute(query_chk, tuple(params_chk))
            filas_chk = cursor_ev.fetchall()
            total_checkouts = len(filas_chk)
            checkouts_con_incidencias = 0

            import re
            patron_limpio_multidia = r'📅\s*\[[^\]]+\]:\s*(?:sin\s+incidencias?(?:\s+reportadas?)?|operaci[oó]n\s+limpia|todo\s+bien|sin\s+novedad[es]*)[\.\s]*'

            for f in filas_chk:
                txt_inc = str(f.get("incidencias_generales") or "").strip()
                if not txt_inc:
                    continue
                txt_lower = txt_inc.lower()
                txt_filtrado = re.sub(patron_limpio_multidia, '', txt_lower, flags=re.IGNORECASE).strip()
                if txt_filtrado and txt_filtrado not in ["despacho autorizado por coordinador.", "despacho autorizado por coordinador", "evento concluido sin incidencias.", "sin incidencias.", "sin incidencias", "ninguna", "ok", "todo bien", "todo en orden"]:
                    checkouts_con_incidencias += 1
            
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
            with get_db_cursor("db_personal", cursor_factory=RealDictCursor) as cursor_pers:
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
        with get_db_cursor("db_autos", cursor_factory=RealDictCursor) as cursor_autos:
            cursor_autos.execute("SELECT num_control, marca, estado_actual as estado FROM public.autos WHERE estado_actual IS NOT NULL;")
            estado_flota = cursor_autos.fetchall()
            
            autos_en_taller = 0
            for item in estado_flota:
                texto_estado = str(item['estado']).lower()
                if any(fallo in texto_estado for fallo in ['taller', 'mantenimiento', 'reparación', 'inactivo', 'apaga', 'truena', 'falla']):
                    autos_en_taller += 1

            cursor_autos.execute("SELECT COUNT(*) as vencen_pronto FROM public.autos WHERE seguro_vence BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days';")
            seguros_vencer = cursor_autos.fetchone()["vencen_pronto"]

        # 4.5️⃣ LLAVE 4: GASTOS REALES DE OPERACIÓN Y PROVEEDORES
        gasto_operacion = 0.0
        with get_db_cursor("db_eventos", cursor_factory=RealDictCursor) as cursor_g:
            q_g = "SELECT COALESCE(SUM(subtotal), 0) AS total_op FROM public.informes_gastos_maestro WHERE 1=1"
            p_g = []
            if fecha_inicio and fecha_fin:
                q_g += " AND fecha_registro BETWEEN %s AND %s"
                p_g.extend([fecha_inicio, fecha_fin])
            cursor_g.execute(q_g, tuple(p_g))
            gasto_operacion = float(cursor_g.fetchone()["total_op"] or 0.0)

        proveedores_activos = 0
        try:
            with get_db_cursor("db_proveedores") as cur_prov:
                cur_prov.execute("SELECT COUNT(*) FROM public.proveedores;")
                proveedores_activos = cur_prov.fetchone()[0] or 0
        except Exception:
            proveedores_activos = 0

        # 5️⃣ EMPAQUETADO FINAL
        return {
            "finanzas": {
                "gasto_mes": float(gasto_total) + gasto_operacion,
                "gasto_reparaciones": float(gasto_total),
                "gasto_operacion": gasto_operacion,
                "equipos_danados": sum(d['total'] for d in deptos_danos), 
                "flota_taller": autos_en_taller, 
                "seguros_vencer": seguros_vencer, 
                "deptos_danos": deptos_danos,
                "estado_flota": estado_flota 
            },
            "comercial": {
                "ops_mes": ops_mes,
                "cliente_top": cliente_top,
                "proveedores_activos": proveedores_activos,
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


@router.get("/api/dashboard/estadisticas-avanzadas", tags=["📊 Dashboard"])
def obtener_estadisticas_avanzadas(
    fecha_inicio: Optional[str] = None,
    fecha_fin: Optional[str] = None
):
    """
    Estadísticas ejecutivas Fase 3:
    1. Rentabilidad / Gastos Operativos por OP.
    2. Puntualidad, Retardos y Horas Extra de RRHH.
    3. Top de Equipos más utilizados en OPs.
    """
    try:
        # 1. Gastos y Rentabilidad por OP
        ops_gastos = []
        top_equipos = []
        with get_db_cursor("db_eventos", cursor_factory=RealDictCursor) as cur_ev:
            q_rent = """
                SELECT COALESCE(e.folio, e.id_evento::text) AS folio,
                       e.nombre_evento,
                       e.para_q_cliente AS cliente,
                       e.fec_del_evento,
                       COALESCE(SUM(g.subtotal), 0) AS gasto_comprobado,
                       COALESCE(SUM(g.monto_entregado), 0) AS viatico_entregado
                FROM public.eventos e
                LEFT JOIN public.informes_gastos_maestro g
                    ON (g.folio_vpro = e.id_evento OR g.folio_vpro::text = TRIM(e.folio))
                WHERE 1=1
            """
            p_rent = []
            if fecha_inicio and fecha_fin:
                q_rent += " AND e.fec_del_evento BETWEEN %s AND %s"
                p_rent.extend([fecha_inicio, fecha_fin])
            q_rent += """
                GROUP BY e.id_evento, e.folio, e.nombre_evento, e.para_q_cliente, e.fec_del_evento
                HAVING COALESCE(SUM(g.subtotal), 0) > 0 OR COALESCE(SUM(g.monto_entregado), 0) > 0
                ORDER BY gasto_comprobado DESC
                LIMIT 10
            """
            cur_ev.execute(q_rent, tuple(p_rent))
            ops_gastos = [
                {
                    "folio": str(r["folio"]),
                    "nombre_evento": str(r["nombre_evento"] or ""),
                    "cliente": str(r["cliente"] or ""),
                    "fecha": str(r["fec_del_evento"] or ""),
                    "gasto_comprobado": float(r["gasto_comprobado"] or 0),
                    "viatico_entregado": float(r["viatico_entregado"] or 0),
                }
                for r in cur_ev.fetchall()
            ]

            cur_ev.execute("""
                SELECT TRIM(d.codigo_equipo) AS codigo, COUNT(*) AS usos, COALESCE(SUM(d.cantidad), 0) AS unidades
                FROM public.checkouts_detalle d
                WHERE d.codigo_equipo IS NOT NULL AND TRIM(d.codigo_equipo) != ''
                GROUP BY TRIM(d.codigo_equipo)
                ORDER BY usos DESC
                LIMIT 8
            """)
            top_equipos = [dict(r) for r in cur_ev.fetchall()]

        # 2. Estadísticas de Puntualidad y Horas Extra (RRHH)
        rrhh_stats = {"a_tiempo": 0, "retardos": 0, "descansos": 0, "horas_extra_totales": 0.0, "por_depto": []}
        with get_db_cursor("db_personal", cursor_factory=RealDictCursor) as cur_p:
            q_asist = """
                SELECT UPPER(COALESCE(c.estatus, '')) AS est,
                       COALESCE(e.depto, 'GENERAL') AS depto,
                       COUNT(*) AS total
                FROM public.control_asistencia c
                LEFT JOIN public.empleados e ON TRIM(c.id_empleado::text) = TRIM(e.id_empleado::text)
                WHERE 1=1
            """
            p_a = []
            if fecha_inicio and fecha_fin:
                q_asist += " AND c.fecha BETWEEN %s AND %s"
                p_a.extend([fecha_inicio, fecha_fin])
            q_asist += " GROUP BY UPPER(COALESCE(c.estatus, '')), COALESCE(e.depto, 'GENERAL')"
            cur_p.execute(q_asist, tuple(p_a))

            mapa_depto = {}
            for r in cur_p.fetchall():
                est = r["est"]
                depto = r["depto"]
                cnt = int(r["total"] or 0)
                if depto not in mapa_depto:
                    mapa_depto[depto] = {"depto": depto, "a_tiempo": 0, "retardos": 0}
                if "RETARDO" in est:
                    rrhh_stats["retardos"] += cnt
                    mapa_depto[depto]["retardos"] += cnt
                elif est in ("DESCANSO", "PERMISO", "VACACIONES", "INCAPACIDAD"):
                    rrhh_stats["descansos"] += cnt
                else:
                    rrhh_stats["a_tiempo"] += cnt
                    mapa_depto[depto]["a_tiempo"] += cnt

            rrhh_stats["por_depto"] = sorted(mapa_depto.values(), key=lambda x: x["a_tiempo"] + x["retardos"], reverse=True)

            cur_p.execute("""
                SELECT COALESCE(SUM(horas_extra_calculadas), 0) AS he
                FROM public.control_horas_extras
                WHERE UPPER(COALESCE(estatus_aprobacion, '')) = 'AUTORIZADO'
            """)
            rrhh_stats["horas_extra_totales"] = float(cur_p.fetchone()["he"] or 0.0)

        return {
            "ops_gastos": ops_gastos,
            "top_equipos": top_equipos,
            "rrhh": rrhh_stats
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/api/analitica/uso-inventario", tags=["📊 Inteligencia de Negocio / CEO"])
def obtener_uso_inventario_ceo(
    fecha_inicio: Optional[str] = None,
    fecha_fin: Optional[str] = None,
    departamento: Optional[str] = None,
    id_empleado: Optional[str] = None,
    busqueda: Optional[str] = None,
    solo_maestro: bool = False,
):
    """
    Reporte ejecutivo de uso de inventario: cuántas veces se ha usado cada equipo,
    en qué OPs/eventos, quién hizo el checkout, su status actual y si presenta o tuvo daños.
    """
    try:
        # 1. Empleados y departamentos (db_personal)
        mapa_emp = {}
        deptos_set = set()
        empleados_list = []
        with get_db_cursor("db_personal", cursor_factory=RealDictCursor) as cur_p:
            cur_p.execute("SELECT id_empleado, nombre, depto FROM public.empleados ORDER BY nombre;")
            for e in cur_p.fetchall():
                eid = str(e["id_empleado"]).strip()
                nombre = (e["nombre"] or "").strip()
                depto = (e["depto"] or "SIN DEPTO").strip()
                mapa_emp[eid] = {"nombre": nombre, "depto": depto}
                if depto:
                    deptos_set.add(depto)
                empleados_list.append({"id_empleado": eid, "nombre": nombre, "depto": depto})

        # 2. Catálogo maestro, kits y tickets de taller (db_inventario)
        mapa_inv = {}
        mapa_rep_por_clave = {}
        estados_cerrados_taller = {
            "RESUELTO", "REPARADO", "OK", "BAJA DEFINITIVA", "CERRADO", "COMPLETADO"
        }

        with get_db_cursor("db_inventario", cursor_factory=RealDictCursor) as cur_i:
            cur_i.execute("""
                SELECT codigo, descripcion, estado, ubicacion, responsable
                FROM public.inventario;
            """)
            for r in cur_i.fetchall():
                cod = (r["codigo"] or "").strip()
                if not cod:
                    continue
                mapa_inv[cod.upper()] = {
                    "codigo": cod,
                    "descripcion": (r["descripcion"] or "").strip(),
                    "estado": (r["estado"] or "Sin estado").strip(),
                    "ubicacion": (r["ubicacion"] or "").strip(),
                    "origen": "MAESTRO",
                }

            cur_i.execute("""
                SELECT codigo_inv_kits, descripcion_inv_kits, estado_inv_kits, ubicacion_inv_kits
                FROM public.inventario_kits;
            """)
            for r in cur_i.fetchall():
                cod = (r["codigo_inv_kits"] or "").strip()
                if not cod or cod.upper() in mapa_inv:
                    continue
                mapa_inv[cod.upper()] = {
                    "codigo": cod,
                    "descripcion": (r["descripcion_inv_kits"] or "").strip(),
                    "estado": (r["estado_inv_kits"] or "Sin estado").strip(),
                    "ubicacion": (r["ubicacion_inv_kits"] or "").strip(),
                    "origen": "KIT",
                }

            cur_i.execute("""
                SELECT num_d_servicio, fecha_d_reporte, equipo_n_reparacion,
                       estado_actual, descripcion_del_dano, costo_d_reparacion,
                       reportante, folio_vpro, tipo_mantenimiento
                FROM public.reparaciones
                WHERE UPPER(COALESCE(tipo_mantenimiento, '')) != 'PREVENTIVO'
                  AND UPPER(COALESCE(folio_vpro, '')) != 'RUTINA_PREVENTIVA'
                ORDER BY fecha_d_reporte DESC NULLS LAST;
            """)
            for rep in cur_i.fetchall():
                clave = (rep["equipo_n_reparacion"] or "").strip().upper()
                if not clave:
                    continue
                est_rep = (rep["estado_actual"] or "").strip().upper()
                abierto = est_rep not in estados_cerrados_taller
                folio_raw = (rep["folio_vpro"] or "").strip().upper()
                folio_norm = folio_raw.replace("OP-", "").replace("OP", "").strip() if folio_raw.startswith("OP") else folio_raw

                rep_raw = (rep["reportante"] or "").strip()
                if rep_raw.lower().startswith("empleado id:"):
                    eid_rep = rep_raw.split(":", 1)[1].strip()
                    rep_nombre = mapa_emp.get(eid_rep, {}).get("nombre") or rep_raw
                elif rep_raw in mapa_emp:
                    rep_nombre = mapa_emp[rep_raw]["nombre"]
                else:
                    rep_nombre = rep_raw

                info_rep = {
                    "num_servicio": rep["num_d_servicio"],
                    "fecha": str(rep["fecha_d_reporte"] or ""),
                    "estado": rep["estado_actual"] or "",
                    "dano": (rep["descripcion_del_dano"] or "").strip(),
                    "costo": float(rep["costo_d_reparacion"] or 0.0),
                    "reportante": rep_nombre,
                    "folio_op_norm": folio_norm,
                    "abierto": abierto,
                }
                mapa_rep_por_clave.setdefault(clave, []).append(info_rep)

        # 3. Checkouts + Eventos (db_eventos)
        with get_db_cursor("db_eventos", cursor_factory=RealDictCursor) as cur_ev:
            query_chk = """
                SELECT cm.id_maestro, cm.folio_op, cm.id_empleado,
                       COALESCE(TO_CHAR((cm.fecha + cm.hora) AT TIME ZONE 'America/Mazatlan', 'YYYY-MM-DD'), CAST(cm.fecha AS TEXT)) AS fecha_local,
                       COALESCE(TO_CHAR((cm.fecha + cm.hora) AT TIME ZONE 'America/Mazatlan', 'HH24:MI'), '') AS hora_local,
                       cm.estado_bodega, cm.incidencias_generales,
                       cd.codigo_equipo, cd.cantidad, cd.cotejado,
                       cd.incidencias AS inc_detalle, cd.notas_regreso,
                       ev.nombre_evento, ev.para_q_cliente, ev.estatus AS estatus_op
                FROM public.checkouts_detalle cd
                JOIN public.checkouts_maestro cm ON cd.id_maestro = cm.id_maestro
                LEFT JOIN public.eventos ev ON TRIM(CAST(cm.folio_op AS TEXT)) = TRIM(ev.folio)
                WHERE cd.codigo_equipo IS NOT NULL AND TRIM(cd.codigo_equipo) != ''
            """
            params = []
            if fecha_inicio and fecha_fin:
                query_chk += " AND cm.fecha BETWEEN %s AND %s"
                params.extend([fecha_inicio, fecha_fin])
            elif fecha_inicio:
                query_chk += " AND cm.fecha >= %s"
                params.append(fecha_inicio)
            elif fecha_fin:
                query_chk += " AND cm.fecha <= %s"
                params.append(fecha_fin)

            if id_empleado and id_empleado.strip():
                query_chk += " AND TRIM(CAST(cm.id_empleado AS TEXT)) = %s"
                params.append(id_empleado.strip())

            query_chk += " ORDER BY cm.fecha DESC, cm.hora DESC, cm.id_maestro DESC;"
            cur_ev.execute(query_chk, tuple(params))
            filas_chk = cur_ev.fetchall()

        # 4. Cruzar y agrupar por equipo
        depto_filtro = (departamento or "").strip().upper()
        busq_filtro = (busqueda or "").strip().upper()
        agrupado = {}
        total_salidas = 0
        total_incidencias_chk = 0

        def _es_incidencia_real(val: str) -> str:
            t = (val or "").strip()
            if not t:
                return ""
            tl = t.lower()
            if tl in ("sin incidencias", "sin incidencia", "sin novedad", "ninguna", "ninguno", "n/a", "na", "ok", "-", "0", "none"):
                return ""
            if tl.startswith("no hubo incidencias"):
                return ""
            return t

        for f in filas_chk:
            cod_raw = (f["codigo_equipo"] or "").strip()
            cod_key = cod_raw.split(" - ")[0].strip().upper() if " - " in cod_raw else cod_raw.upper()
            meta = mapa_inv.get(cod_key) or mapa_inv.get(cod_raw.upper())

            if solo_maestro and (not meta or meta["origen"] != "MAESTRO"):
                continue

            eid = str(f["id_empleado"] or "").strip()
            emp_info = mapa_emp.get(eid, {"nombre": eid or "Sin asignar", "depto": "SIN DEPTO"})

            if depto_filtro and emp_info["depto"].upper() != depto_filtro:
                continue

            desc_eq = meta["descripcion"] if meta else cod_raw
            cod_mostrar = meta["codigo"] if meta else cod_raw

            if busq_filtro and (
                busq_filtro not in cod_mostrar.upper()
                and busq_filtro not in desc_eq.upper()
                and busq_filtro not in str(f["folio_op"] or "").upper()
                and busq_filtro not in (f["nombre_evento"] or "").upper()
            ):
                continue

            inc_det = _es_incidencia_real(f["inc_detalle"])
            inc_texto = inc_det
            tiene_inc = bool(inc_texto)
            if tiene_inc:
                total_incidencias_chk += 1
            total_salidas += 1

            if cod_key not in agrupado:
                tickets = list(mapa_rep_por_clave.get(cod_key, []))
                if desc_eq:
                    for t in mapa_rep_por_clave.get(desc_eq.upper(), []):
                        if t not in tickets:
                            tickets.append(t)

                agrupado[cod_key] = {
                    "codigo": cod_mostrar,
                    "descripcion": desc_eq,
                    "origen": meta["origen"] if meta else "EXTERNO",
                    "estado_actual": meta["estado"] if meta else "No catalogado",
                    "ubicacion": meta["ubicacion"] if meta else "",
                    "veces_usado": 0,
                    "unidades_totales": 0,
                    "ultimo_uso_fecha": str(f["fecha_local"] or ""),
                    "ultimo_uso_op": f["folio_op"],
                    "ultimo_uso_evento": (f["nombre_evento"] or "").strip() or f"OP-{f['folio_op']}",
                    "ultimo_uso_empleado": emp_info["nombre"],
                    "incidencias_checkout": 0,
                    "tickets_taller": len(tickets),
                    "dano_abierto": any(t["abierto"] for t in tickets),
                    "costo_reparaciones": sum(t["costo"] for t in tickets),
                    "tickets_detalle": tickets,
                    "movimientos": [],
                }

            item = agrupado[cod_key]
            item["veces_usado"] += 1
            item["unidades_totales"] += int(f["cantidad"] or 1)
            if tiene_inc:
                item["incidencias_checkout"] += 1

            item["movimientos"].append({
                "fecha": str(f["fecha_local"] or ""),
                "hora": str(f["hora_local"] or ""),
                "folio_op": f["folio_op"],
                "nombre_evento": (f["nombre_evento"] or "").strip() or "--",
                "cliente": (f["para_q_cliente"] or "").strip() or "--",
                "empleado": emp_info["nombre"],
                "depto": emp_info["depto"],
                "estado_bodega": (f["estado_bodega"] or "ENTREGADO").strip(),
                "cotejado": bool(f["cotejado"]),
                "incidencia": inc_texto,
                "notas_regreso": (f["notas_regreso"] or "").strip(),
            })

        equipos_lista = sorted(
            agrupado.values(),
            key=lambda x: (-x["veces_usado"], -int(x["dano_abierto"]), x["codigo"])
        )

        equipos_con_dano = sum(
            1 for x in equipos_lista
            if x["dano_abierto"] or x["incidencias_checkout"] > 0
            or x["estado_actual"].lower() in ("fuera de servicio", "funcional con limitaciones", "en reparación", "dañado")
        )

        movimientos_planos = []
        for eq in equipos_lista:
            tickets = eq["tickets_detalle"]

            for m in eq["movimientos"]:
                op_str = str(m["folio_op"] or "").strip().upper()
                tickets_op = [t for t in tickets if t.get("folio_op_norm") == op_str]

                dano_taller_txt = ""
                reportante_dano = ""
                dano_abierto_op = False
                if tickets_op:
                    t0 = tickets_op[0]
                    reportante_dano = t0.get("reportante") or ""
                    dano_abierto_op = any(t["abierto"] for t in tickets_op)
                    if dano_abierto_op:
                        dano_taller_txt = f"⚠️ DAÑO ABIERTO [{t0['num_servicio']}]: {t0['dano'] or t0['estado']}"
                    else:
                        dano_taller_txt = f"Taller ({len(tickets_op)}): {t0['num_servicio']} [{t0['estado']}]"

                rep_dano = reportante_dano or (m["empleado"] if m["incidencia"] else "")
                movimientos_planos.append({
                    "fecha": m["fecha"],
                    "hora": m["hora"],
                    "folio_op": m["folio_op"],
                    "nombre_evento": m["nombre_evento"],
                    "cliente": m["cliente"],
                    "codigo": eq["codigo"],
                    "descripcion": eq["descripcion"],
                    "empleado": m["empleado"],
                    "depto": m["depto"],
                    "reportante_dano": rep_dano,
                    "estado_equipo": eq["estado_actual"],
                    "estado_bodega": m["estado_bodega"],
                    "cotejado": m["cotejado"],
                    "incidencia_checkout": m["incidencia"],
                    "notas_regreso": m["notas_regreso"],
                    "dano_abierto": dano_abierto_op,
                    "dano_taller": dano_taller_txt,
                })

        movimientos_planos.sort(key=lambda x: (x["fecha"], x["hora"], str(x["folio_op"] or "")), reverse=True)

        return {
            "kpis": {
                "total_salidas": total_salidas,
                "equipos_distintos": len(equipos_lista),
                "equipos_con_dano": equipos_con_dano,
                "incidencias_checkouts": total_incidencias_chk,
            },
            "filtros": {
                "departamentos": sorted(list(deptos_set)),
                "empleados": empleados_list,
            },
            "equipos": equipos_lista,
            "movimientos": movimientos_planos,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en uso de inventario: {str(e)}")


