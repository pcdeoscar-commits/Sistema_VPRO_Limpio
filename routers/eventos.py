import datetime
from fastapi import APIRouter, HTTPException
from sqlalchemy import text
from typing import Dict, Any, List

from core.database import (
    engine_autos, engine_clientes, engine_proveedores, 
    engine_personal, engine_eventos, engine_eventos_vieja
)
from core.utils import safe_decode_hex, serialize_row_dates

router = APIRouter(prefix="/api/eventos", tags=["📝 Órdenes Producción"])

@router.get("/catalogos")
def extraer_catalogos_de_apoyo():
    """Extrae catálogos de soporte para la creación de órdenes de producción."""
    try:
        with engine_autos.connect() as conn:
            res_autos = conn.execute(text("SELECT num_control, marca, modelo FROM public.autos")).fetchall()
            lista_autos = [f"{r[0]} - {r[1]} {r[2]}" for r in res_autos]
                
        with engine_clientes.connect() as conn:
            clientes = conn.execute(text("SELECT encode(cliente_empresa::bytea,'hex') FROM public.clientes ORDER BY id_cliente ASC")).fetchall()
        lista_clientes = [safe_decode_hex(c[0]) for c in clientes]

        with engine_proveedores.connect() as conn:
            provs = conn.execute(text("SELECT encode(nombre_del_proveedor::bytea,'hex') FROM public.proveedores ORDER BY nombre_del_proveedor ASC")).fetchall()
        lista_proveedores = [safe_decode_hex(p[0]) for p in provs]

        with engine_personal.connect() as conn:
            staff_rows = conn.execute(text("SELECT encode(nombre::bytea,'hex'), encode(rol::bytea,'hex') FROM public.empleados ORDER BY nombre ASC")).fetchall()
        
        staff_vpro, apoyos_externos = [], []
        for s in staff_rows:
            nom = safe_decode_hex(s[0])
            rol = safe_decode_hex(s[1]).strip().upper()
            if rol in ['EXTERNO', 'PROVEEDOR', 'PROV'] and rol != 'BAJA':
                apoyos_externos.append(nom)
            elif rol != 'BAJA':
                staff_vpro.append(nom)

        return {
            "autos": lista_autos,
            "clientes": lista_clientes,
            "proveedores": lista_proveedores,
            "staff_vpro": staff_vpro,
            "apoyos_externos": apoyos_externos
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/folios")
def obtener_folios_activos_e_historicos():
    """Obtiene los folios activos e históricos de ambas bases de datos.
    Excluye las OPs que ya tienen un informe de gastos registrado.
    """
    try:
        # Solo OPs activas que NO tienen aún informe de gastos registrado
        query_activos_nueva = text("""
            SELECT folio, nombre_evento 
            FROM public.eventos 
            WHERE UPPER(estatus) != 'CERRADA (HISTÓRICO)'
              AND NOT EXISTS (
                  SELECT 1 FROM public.informes_gastos_maestro m 
                  WHERE m.folio_vpro = id_evento
              )
            ORDER BY id_evento DESC
        """)
        query_historicos_nueva = text("""
            SELECT folio, nombre_evento 
            FROM public.eventos 
            WHERE UPPER(estatus) = 'CERRADA (HISTÓRICO)'
               OR EXISTS (
                   SELECT 1 FROM public.informes_gastos_maestro m 
                   WHERE m.folio_vpro = id_evento
               )
            ORDER BY id_evento DESC
        """)
        query_max_id = text("SELECT COALESCE(MAX(id_evento), 0) + 1 AS proximo_id FROM public.eventos")

        query_vieja = text("SELECT folio, nombre_evento FROM public.eventos ORDER BY id_evento DESC")

        folios_activos = []
        folios_historicos = []
        max_id_nuevo = 1

        with engine_eventos.connect() as conn:
            activos_nuevos = conn.execute(query_activos_nueva).mappings().fetchall()
            historicos_nuevos = conn.execute(query_historicos_nueva).mappings().fetchall()
            max_id_nuevo = conn.execute(query_max_id).scalar()
            
            folios_activos.extend([f"{r['folio']} - {r['nombre_evento']}" for r in activos_nuevos])
            folios_historicos.extend([f"{r['folio']} - {r['nombre_evento']} [NUEVA]" for r in historicos_nuevos])

        with engine_eventos_vieja.connect() as conn:
            todos_viejos = conn.execute(query_vieja).mappings().fetchall()
            
            for r in todos_viejos:
                folio_str = f"{r['folio']} - {r['nombre_evento']}"
                if folio_str not in folios_activos and folio_str not in [f.replace(' [NUEVA]', '') for f in folios_historicos]:
                    folios_activos.append(folio_str)

        return {
            "folios": folios_activos,
            "folios_historicos": folios_historicos,
            "proximo_id": max_id_nuevo
        }
    except Exception as e:
        return {"folios": [], "folios_historicos": [], "proximo_id": 1}


@router.get("/buscar/{folio}")
def buscar_op_por_folio(folio: str):
    """Busca una orden de producción por folio en la base nueva o en la histórica,
    e integra el detalle completo de las reuniones previas vinculadas."""
    try:
        query = text("SELECT * FROM public.eventos WHERE folio = :folio")
        
        with engine_eventos.connect() as conn:
            resultado = conn.execute(query, {"folio": folio}).mappings().first()
            
        if not resultado:
            with engine_eventos_vieja.connect() as conn:
                resultado = conn.execute(query, {"folio": folio}).mappings().first()

        if resultado:
            data = serialize_row_dates(dict(resultado))
            
            # Enriquecer con el expediente detallado de reuniones vinculadas
            reuniones_raw = data.get("reuniones_vinculadas")
            reuniones_list = []
            if isinstance(reuniones_raw, list):
                reuniones_list = [str(x).strip() for x in reuniones_raw if str(x).strip()]
            elif isinstance(reuniones_raw, str) and reuniones_raw.strip():
                s = reuniones_raw.strip()
                if s.startswith("{") and s.endswith("}"):
                    s = s[1:-1]
                import csv, io
                try:
                    reuniones_list = [x.strip() for x in next(csv.reader(io.StringIO(s))) if x.strip()]
                except Exception:
                    reuniones_list = [x.strip().strip('"').strip("'") for x in s.split(",") if x.strip()]

            detalles_reuniones = []
            if reuniones_list:
                with engine_eventos.connect() as conn:
                    for r_item in reuniones_list:
                        r_clean = str(r_item).strip().strip('"').strip("'")
                        q_reu = text("""
                            SELECT id_reunion, fecha_reunion, cliente_tentativo, nombre_proyecto_tentativo,
                                   asistentes, minuta_acuerdos, presupuesto_estimado, fecha_probable_evento,
                                   estatus_proyecto
                            FROM public.reuniones_previas
                            WHERE CONCAT(fecha_reunion, ' | ', cliente_tentativo, ' - ', nombre_proyecto_tentativo) = :firma
                               OR CAST(id_reunion AS TEXT) = :firma
                            LIMIT 1
                        """)
                        row_reu = conn.execute(q_reu, {"firma": r_clean}).mappings().first()
                        if row_reu:
                            rd = dict(row_reu)
                            rd["fecha_reunion"] = str(rd["fecha_reunion"]) if rd.get("fecha_reunion") else ""
                            rd["fecha_probable_evento"] = str(rd["fecha_probable_evento"]) if rd.get("fecha_probable_evento") else ""
                            rd["presupuesto_estimado"] = float(rd.get("presupuesto_estimado") or 0.0)
                            detalles_reuniones.append(rd)
                        else:
                            detalles_reuniones.append({
                                "id_reunion": None,
                                "fecha_reunion": "",
                                "cliente_tentativo": "",
                                "nombre_proyecto_tentativo": r_clean,
                                "asistentes": "No especificado",
                                "minuta_acuerdos": "Minuta registrada sin ficha detallada asociada.",
                                "presupuesto_estimado": 0.0,
                                "fecha_probable_evento": ""
                            })
            data["detalle_reuniones"] = detalles_reuniones
            return data
        else:
            raise HTTPException(status_code=404, detail="Folio no encontrado en ninguna de las bases de datos.")
            
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/guardar")
def guardar_o_actualizar_op(op: dict):
    """Guarda o actualiza una orden de producción."""
    try:
        id_ev = int(op.get("id_evento"))
        
        def format_pg_array(data):
            if not data:
                return "{}"
            if isinstance(data, str):
                return data
            sanitizados = [f'"{str(x).replace("\"", "\\\"")}"' for x in data]
            return "{" + ",".join(sanitizados) + "}"

        payload = dict(op)
        payload["proveedor_op"] = format_pg_array(payload.get("proveedor_op", []))
        payload["personal_convocado_op"] = format_pg_array(payload.get("personal_convocado_op", []))
        payload["carros_usados_op"] = format_pg_array(payload.get("carros_usados_op", []))
        payload["externos_op"] = format_pg_array(payload.get("externos_op", []))
        payload["reuniones_vinculadas"] = format_pg_array(payload.get("reuniones_vinculadas", []))
        
        if 'estatus' in payload:
            del payload['estatus']

        with engine_eventos.connect() as conn:
            existe = conn.execute(text("SELECT 1 FROM public.eventos WHERE id_evento = :id_evento"), {"id_evento": id_ev}).scalar()
            
        if existe:
            query_update = text("""
                UPDATE public.eventos SET 
                    folio = :folio, para_q_cliente = :para_q_cliente, nombre_evento = :nombre_evento, locacion = :locacion, fec_de_instalacion = CAST(:fec_de_instalacion AS date), 
                    hra_de_instalacion = CAST(:hra_de_instalacion AS time), quien_solicita = :quien_solicita, resp_de_produccion = :resp_de_produccion, fec_del_evento = CAST(:fec_del_evento AS date), 
                    inicio_del_evento = CAST(:inicio_del_evento AS time), hra_de_llamado = CAST(:hra_de_llamado AS time), ubicacion = :ubicacion, tipo_de_servicio = :tipo_de_servicio, produccion = :produccion, 
                    internet_redes = :internet_redes, actividades_de_proveedores = :actividades_de_proveedores, nota = :nota, elabora = :elabora, organiza = :organiza, coordina = :coordina, vobo = :vobo, 
                    proveedor_op = CAST(:proveedor_op AS text[]), personal_convocado_op = CAST(:personal_convocado_op AS text[]), carros_usados_op = CAST(:carros_usados_op AS text[]), externos_op = CAST(:externos_op AS text[]), 
                    reuniones_vinculadas = CAST(:reuniones_vinculadas AS text[]), 
                    fec_de_elaboracion_de_op = CURRENT_DATE
                WHERE id_evento = :id_evento
            """)
            with engine_eventos.begin() as conn:
                conn.execute(query_update, payload)
        else:
            query_insert = text("""
                INSERT INTO public.eventos (
                    id_evento, folio, para_q_cliente, nombre_evento, locacion, fec_de_instalacion, hra_de_instalacion, quien_solicita, resp_de_produccion, fec_del_evento, 
                    inicio_del_evento, hra_de_llamado, ubicacion, tipo_de_servicio, produccion, internet_redes, actividades_de_proveedores, nota, elabora, organiza, coordina, 
                    vobo, proveedor_op, personal_convocado_op, carros_usados_op, externos_op, reuniones_vinculadas, empleado_que_creo_la_op, fec_de_elaboracion_de_op 
                ) VALUES (
                    :id_evento, :folio, :para_q_cliente, :nombre_evento, :locacion, CAST(:fec_de_instalacion AS date), CAST(:hra_de_instalacion AS time), :quien_solicita, :resp_de_produccion, CAST(:fec_del_evento AS date), 
                    CAST(:inicio_del_evento AS time), CAST(:hra_de_llamado AS time), :ubicacion, :tipo_de_servicio, :produccion, :internet_redes, :actividades_de_proveedores, :nota, :elabora, :organiza, :coordina, 
                    :vobo, CAST(:proveedor_op AS text[]), CAST(:personal_convocado_op AS text[]), CAST(:carros_usados_op AS text[]), CAST(:externos_op AS text[]), CAST(:reuniones_vinculadas AS text[]), :empleado_que_creo_la_op, CURRENT_DATE 
                )
            """)
            with engine_eventos.begin() as conn:
                conn.execute(query_insert, payload)

        # Si hay reuniones vinculadas, sincronizar folio_op_generado en reuniones_previas
        if op.get("reuniones_vinculadas"):
            try:
                raw_reus = op.get("reuniones_vinculadas")
                lista_reus = raw_reus if isinstance(raw_reus, list) else [str(raw_reus)]
                with engine_eventos.begin() as conn_r:
                    for r_firma in lista_reus:
                        r_clean = str(r_firma).strip().strip('"').strip("'")
                        conn_r.execute(text("""
                            UPDATE public.reuniones_previas
                            SET folio_op_generado = :id_ev, estatus_proyecto = 'VINCULADO A OP'
                            WHERE CONCAT(fecha_reunion, ' | ', cliente_tentativo, ' - ', nombre_proyecto_tentativo) = :firma
                               OR CAST(id_reunion AS TEXT) = :firma
                        """), {"id_ev": id_ev, "firma": r_clean})
            except Exception as e:
                print(f"⚠️ SILENCED ERROR in eventos.py: {e}")

        return {"status": "SUCCESS"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

