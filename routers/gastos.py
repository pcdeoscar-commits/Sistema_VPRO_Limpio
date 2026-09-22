import datetime
from typing import Dict, Any, List, Optional
from fastapi import APIRouter, HTTPException
from sqlalchemy import text

from core.database import engine_eventos, engine_personal
from core.utils import safe_decode_hex

router = APIRouter(prefix="/api/gastos", tags=["💸 Gastos Operativos"])

@router.get("/ultimo-km/{vehiculo}")
def obtener_ultimo_km_vehiculo(vehiculo: str):
    """Consulta el último odómetro final registrado para un vehículo."""
    query = text("SELECT km_final FROM public.informes_gastos_maestro WHERE UPPER(vehiculo) LIKE UPPER(:veh) ORDER BY id_informe DESC LIMIT 1")
    try:
        with engine_eventos.connect() as conn:
            resultado = conn.execute(query, {"veh": f"%{vehiculo.strip()}%"}).fetchone()
            if resultado and resultado[0]: 
                return {"ultimo_km": int(resultado[0])}
            return {"ultimo_km": 0}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/pendientes/conteo")
def contar_gastos_pendientes_api():
    """Retorna el número de comprobaciones de gastos pendientes de auditoría."""
    query = text("SELECT COUNT(*) FROM public.informes_gastos_maestro WHERE revisado = FALSE")
    try:
        with engine_eventos.connect() as conn: 
            return conn.execute(query).scalar()
    except Exception: 
        return 0

@router.get("/folios-pendientes")
def listar_folios_pendientes_gastos():
    """Lista las OPs que tienen checkout recibido pero no tienen informe de gastos."""
    query = text("""
        SELECT e.id_evento, encode(e.para_q_cliente::bytea, 'hex'), encode(e.nombre_evento::bytea, 'hex')
        FROM public.eventos e
        WHERE NOT EXISTS (SELECT 1 FROM public.informes_gastos_maestro m WHERE m.folio_vpro = e.id_evento)
        AND EXISTS (SELECT 1 FROM public.checkouts_maestro cm WHERE cm.folio_op = e.id_evento AND cm.estado_bodega = 'RECIBIDO')
        ORDER BY e.id_evento DESC
    """)
    try:
        with engine_eventos.connect() as conn: 
            rows = conn.execute(query).fetchall()
            return [{"id_evento": r[0], "cliente": safe_decode_hex(r[1]), "nombre_evento": safe_decode_hex(r[2])} for r in rows]
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/evento/{id_evento}")
def obtener_datos_evento_gasto(id_evento: int):
    """Obtiene los datos base del evento para la rendición de gastos."""
    query = text("""
        SELECT encode(resp_de_produccion::bytea, 'hex'), fec_de_instalacion, 
               encode(carros_usados_op::text::bytea, 'hex'), encode(personal_convocado_op::text::bytea, 'hex')
        FROM public.eventos WHERE id_evento = :id
    """)
    try:
        with engine_eventos.connect() as conn: 
            res = conn.execute(query, {"id": id_evento}).first()
            if res:
                return {
                    "productor_responsable": safe_decode_hex(res[0]), 
                    "fec_de_instalacion": str(res[1]) if res[1] else None, 
                    "carros_usados_op": safe_decode_hex(res[2]), 
                    "personal_convocado_op": safe_decode_hex(res[3])
                }
            raise HTTPException(status_code=404, detail="Evento no mapeado")
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/validar-incidencias/{id_evento}")
def validar_incidencias_completas(id_evento: int):
    """Valida que todo el personal convocado haya realizado su checkout de incidencias."""
    try:
        with engine_eventos.connect() as conn_e:
            res = conn_e.execute(text("SELECT personal_convocado_op FROM public.eventos WHERE id_evento = :id"), {"id": id_evento}).first()
            if not res or not res[0]:
                return {"faltantes": []}
            convocados = res[0]
            
        with engine_personal.connect() as conn_p:
            nombres_str = ','.join([f"'{n.strip()}'" for n in convocados])
            if not nombres_str: return {"faltantes": []}
            rows = conn_p.execute(text(f"SELECT TRIM(id_empleado), nombre FROM public.empleados WHERE nombre IN ({nombres_str})")).fetchall()
            id_to_nombre = {str(r[0]): r[1] for r in rows}
            
        with engine_eventos.connect() as conn_e:
            if not id_to_nombre: return {"faltantes": []}
            ids_str = ','.join([f"'{i}'" for i in id_to_nombre.keys()])
            checkouts = conn_e.execute(text(f"SELECT TRIM(id_empleado), incidencias_generales FROM public.checkouts_maestro WHERE folio_op = {id_evento} AND TRIM(id_empleado) IN ({ids_str})")).fetchall()
            
            validos = set()
            for c in checkouts:
                id_e = str(c[0])
                inc = str(c[1]).strip() if c[1] else ''
                if inc and inc.lower() != 'favor de reportar aqui las incidencias del evento' and inc.lower() != 'sin incidencias':
                    validos.add(id_e)
                    
            faltantes = [n for i, n in id_to_nombre.items() if i not in validos]
            
        return {"faltantes": faltantes}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/guardar")
def guardar_informe_gastos_completo(payload: dict):
    """Guarda un nuevo informe de gastos por comprobar (maestro y detalles diarios)."""
    try:
        maestro = payload.get("maestro", {})
        detalles = payload.get("detalles", [])
        with engine_eventos.begin() as conn:
            sql_m = text("""
                INSERT INTO public.informes_gastos_maestro (
                    folio_vpro, id_empleado, periodo_desde, periodo_hasta, vehiculo, km_inicial, km_final, 
                    departamento, num_personas, subtotal, monto_entregado, restante, fecha_registro, hora_registro, revisado
                ) VALUES (
                    :folio_vpro, :id_empleado, CAST(:periodo_desde AS date), CAST(:periodo_hasta AS date), 
                    :vehiculo, :km_inicial, :km_final, :departamento, :num_personas, :subtotal, :monto_entregado, 
                    :restante, CURRENT_DATE, CURRENT_TIME, FALSE
                ) RETURNING id_informe
            """)
            id_informe = conn.execute(sql_m, {
                "folio_vpro": int(maestro.get("folio_vpro")), 
                "id_empleado": str(maestro.get("id_empleado", ""))[:3], 
                "periodo_desde": maestro.get("periodo_desde"),
                "periodo_hasta": maestro.get("periodo_hasta"), 
                "vehiculo": str(maestro.get("vehiculo", ""))[:100], 
                "km_inicial": int(maestro.get("km_inicial", 0)),
                "km_final": int(maestro.get("km_final", 0)), 
                "departamento": str(maestro.get("departamento", ""))[:50], 
                "num_personas": int(maestro.get("num_personas", 0)),
                "subtotal": float(maestro.get("subtotal", 0.0)), 
                "monto_entregado": float(maestro.get("monto_entregado", 0.0)), 
                "restante": float(maestro.get("restante", 0.0))
            }).scalar()
            
            sql_d = text("""
                INSERT INTO public.informes_gastos_detalle (
                    id_informe, dia_num, hotel, transporte, combustible, casetas, desayuno, comida, cenas, varios, total_dia
                ) VALUES (
                    :id_informe, :dia_num, :hotel, :transporte, :combustible, :casetas, :desayuno, :comida, :cenas, :varios, :total_dia
                )
            """)
            for d in detalles:
                conn.execute(sql_d, {
                    "id_informe": id_informe, 
                    "dia_num": int(d.get("dia_num")), 
                    "hotel": float(d.get("hotel", 0.0)), 
                    "transporte": float(d.get("transporte", 0.0)),
                    "combustible": float(d.get("combustible", 0.0)), 
                    "casetas": float(d.get("casetas", 0.0)), 
                    "desayuno": float(d.get("desayuno", 0.0)),
                    "comida": float(d.get("comida", 0.0)), 
                    "cenas": float(d.get("cenas", 0.0)), 
                    "varios": float(d.get("varios", 0.0)), 
                    "total_dia": float(d.get("total_dia", 0.0))
                })
        return {"status": "SUCCESS", "id_informe": id_informe}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/informe-completo/{id_informe}")
def obtener_expediente_informe_completo(id_informe: int):
    """Consulta el expediente completo de un informe de gastos."""
    query_m = text("""
        SELECT id_informe, folio_vpro, id_empleado, periodo_desde, periodo_hasta, 
               encode(vehiculo::bytea, 'hex'), km_inicial, km_final, encode(departamento::bytea, 'hex'), 
               num_personas, subtotal, monto_entregado, restante, revisado 
        FROM public.informes_gastos_maestro WHERE id_informe = :id
    """)
    query_d = text("""
        SELECT dia_num, hotel, transporte, combustible, casetas, desayuno, comida, cenas, varios, total_dia 
        FROM public.informes_gastos_detalle WHERE id_informe = :id ORDER BY dia_num ASC
    """)
    try:
        with engine_eventos.connect() as conn:
            m = conn.execute(query_m, {"id": id_informe}).first()
            detalles = conn.execute(query_d, {"id": id_informe}).fetchall()
        if not m: 
            raise HTTPException(status_code=404, detail="Informe no mapeado")
        
        with engine_personal.connect() as conn_p:
            emp_row = conn_p.execute(text("SELECT encode(nombre::bytea, 'hex') FROM public.empleados WHERE TRIM(id_empleado) = :id"), {"id": str(m[2]).strip()}).first()
        nombre_emp = safe_decode_hex(emp_row[0]) if emp_row else f"ID: {m[2]}"

        return {
            "maestro": {
                "id_informe": m[0], "folio_vpro": m[1], "nombre_empleado": nombre_emp, 
                "periodo_desde": str(m[3]), "periodo_hasta": str(m[4]),
                "vehiculo": safe_decode_hex(m[5]), "km_inicial": m[6], "km_final": m[7], 
                "departamento": safe_decode_hex(m[8]), "num_personas": m[9], 
                "subtotal": float(m[10]), "monto_entregado": float(m[11]), 
                "restante": float(m[12]), "revisado": m[13]
            },
            "detalles": [
                {
                    "dia_num": d[0], "hotel": float(d[1]), "transporte": float(d[2]), 
                    "combustible": float(d[3]), "casetas": float(d[4]), "desayuno": float(d[5]), 
                    "comida": float(d[6]), "cenas": float(d[7]), "varios": float(d[8]), 
                    "total_dia": float(d[9])
                } for d in detalles
            ]
        }
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/revisar/{id_informe}")
def aprobar_y_sellar_informe_gasto(id_informe: int):
    """Sella el informe de gastos por Administración (Ana Lilia) y cierra la OP enviándola a la Bóveda Histórica."""
    query_gasto = text("UPDATE public.informes_gastos_maestro SET revisado = TRUE WHERE id_informe = :id RETURNING folio_vpro")
    query_cerrar_op = text("UPDATE public.eventos SET estatus = 'CERRADA (HISTÓRICO)' WHERE id_evento = :folio_vpro OR folio = CAST(:folio_vpro AS VARCHAR)")
    try:
        with engine_eventos.begin() as conn:
            res = conn.execute(query_gasto, {"id": id_informe}).fetchone()
            if res and res[0]:
                folio_vpro = int(res[0])
                conn.execute(query_cerrar_op, {"folio_vpro": folio_vpro})
                
                # Sincronizar estatus de reuniones previas vinculadas
                ev_row = conn.execute(
                    text("SELECT reuniones_vinculadas FROM public.eventos WHERE id_evento = :folio_vpro OR folio = CAST(:folio_vpro AS VARCHAR)"),
                    {"folio_vpro": folio_vpro}
                ).fetchone()
                if ev_row and ev_row[0]:
                    conn.execute(text("""
                        UPDATE public.reuniones_previas
                        SET folio_op_generado = :folio_vpro, estatus_proyecto = 'CONVERTIDO A OP'
                        WHERE CONCAT(fecha_reunion, ' | ', cliente_tentativo, ' - ', nombre_proyecto_tentativo) = ANY(:reuniones)
                    """), {"folio_vpro": folio_vpro, "reuniones": ev_row[0]})
        return {"status": "SUCCESS"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/pendientes-auditoria")
def obtener_gastos_pendientes_auditoria():
    """Consulta la lista de gastos pendientes de ser revisados por auditoría."""
    try:
        with engine_eventos.connect() as conn:
            query = text("""
                SELECT igm.folio_vpro, igm.id_empleado, encode(e.nombre_evento::bytea, 'hex'), encode(e.para_q_cliente::bytea, 'hex') 
                FROM public.informes_gastos_maestro igm 
                LEFT JOIN public.eventos e ON igm.folio_vpro = e.id_evento 
                WHERE igm.revisado IS FALSE OR igm.revisado IS NULL
            """)
            res = conn.execute(query).fetchall()
            lista_pendientes = []
            for r in res:
                cliente_str = safe_decode_hex(r[3]) if r[3] else ""
                evento_str = safe_decode_hex(r[2]) if r[2] else "Evento Desconocido"
                lista_pendientes.append({
                    "folio_op": r[0], 
                    "id_empleado": str(r[1]).strip(), 
                    "evento": f"{cliente_str} - {evento_str}".strip(" -")
                })
            return lista_pendientes
    except Exception: 
        return []

@router.get("/informes-auditoria")
def listar_informes_auditoria():
    """Lista todos los informes de gastos registrados con su estado de auditoría."""
    try:
        with engine_eventos.connect() as conn:
            query = text("""
                SELECT m.id_informe, m.folio_vpro, m.revisado, m.id_empleado, encode(e.nombre_evento::bytea, 'hex')
                FROM public.informes_gastos_maestro m 
                LEFT JOIN public.eventos e ON m.folio_vpro = e.id_evento 
                ORDER BY m.id_informe DESC
            """)
            rows = conn.execute(query).fetchall()
            
        with engine_personal.connect() as conn_p:
            emp_rows = conn_p.execute(text("SELECT TRIM(id_empleado), encode(nombre::bytea, 'hex') FROM public.empleados")).fetchall()
            dict_emps = {r[0]: safe_decode_hex(r[1]) for r in emp_rows}
            
        lista_final = []
        for r in rows:
            id_emp = str(r[3]).strip()
            nombre_ev = safe_decode_hex(r[4]) if r[4] else "Evento Desconocido"
            lista_final.append({
                "id_informe": r[0], 
                "folio_vpro": r[1], 
                "revisado": bool(r[2]), 
                "nombre_empleado": dict_emps.get(id_emp, f"ID: {id_emp}"), 
                "nombre_evento": nombre_ev
            })
        return lista_final
    except Exception: 
        return []

@router.post("/modificar-historico")
def modificar_informe_historico(payload: dict):
    """Permite modificar las partidas de un informe histórico y recalcula el saldo."""
    try:
        with engine_eventos.begin() as conn:
            conn.execute(text("DELETE FROM public.informes_gastos_detalle WHERE id_informe = :id"), {"id": payload["id_informe"]})
            sql_d = text("""
                INSERT INTO public.informes_gastos_detalle (
                    id_informe, dia_num, hotel, transporte, combustible, casetas, desayuno, comida, cenas, varios, total_dia
                ) VALUES (
                    :id_informe, :dia_num, :hotel, :transporte, :combustible, :casetas, :desayuno, :comida, :cenas, :varios, :total_dia
                )
            """)
            subtotal_nuevo = 0.0
            for d in payload["detalles"]:
                subtotal_nuevo += float(d.get("total_dia", 0.0))
                conn.execute(sql_d, {
                    "id_informe": payload["id_informe"], 
                    "dia_num": int(d.get("dia_num", 1)), 
                    "hotel": float(d.get("hotel", 0.0)), 
                    "transporte": float(d.get("transporte", 0.0)),
                    "combustible": float(d.get("combustible", 0.0)), 
                    "casetas": float(d.get("casetas", 0.0)), 
                    "desayuno": float(d.get("desayuno", 0.0)), 
                    "comida": float(d.get("comida", 0.0)),
                    "cenas": float(d.get("cenas", 0.0)), 
                    "varios": float(d.get("varios", 0.0)), 
                    "total_dia": float(d.get("total_dia", 0.0))
                })
            conn.execute(
                text("UPDATE public.informes_gastos_maestro SET subtotal = :sub, restante = monto_entregado - :sub WHERE id_informe = :id"), 
                {"sub": subtotal_nuevo, "id": payload["id_informe"]}
            )
        return {"status": "SUCCESS"}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/historial-op/{id_evento}")
def obtener_gastos_historicos_op(id_evento: str):
    """Consulta el informe financiero histórico detallado de una OP."""
    try:
        with engine_eventos.connect() as conn:
            q_maestro = text("SELECT * FROM public.informes_gastos_maestro WHERE CAST(folio_vpro AS TEXT) = :id")
            m_row = conn.execute(q_maestro, {"id": str(id_evento).strip()}).mappings().first()
            
            if not m_row: 
                return {"status": "EMPTY", "informe": None}
                
            id_inf = m_row.get("id_informe")
            id_emp = str(m_row.get("id_empleado", "")).strip()
            fecha_inicio_op = m_row.get("periodo_desde")
            
            nombre_productor = id_emp
            if id_emp:
                with engine_personal.connect() as conn_p:
                    emp_row = conn_p.execute(
                        text("SELECT encode(nombre::bytea, 'hex') FROM public.empleados WHERE TRIM(id_empleado) = :id"), 
                        {"id": id_emp}
                    ).scalar()
                    if emp_row: 
                        nombre_productor = safe_decode_hex(emp_row)
            
            q_detalle = text("SELECT * FROM public.informes_gastos_detalle WHERE id_informe = :id_inf ORDER BY dia_num ASC")
            detalles = conn.execute(q_detalle, {"id_inf": id_inf}).mappings().fetchall()
            
            def formatear_fecha(fecha_base, dia_n):
                if not fecha_base:
                    return f"Día {dia_n}"
                try:
                    if isinstance(fecha_base, str):
                        f_base = datetime.date.fromisoformat(fecha_base)
                    else:
                        f_base = fecha_base
                    
                    f_calc = f_base + datetime.timedelta(days=int(dia_n)-1)
                    dias = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]
                    return f"{str(f_calc.day).zfill(2)}/{str(f_calc.month).zfill(2)} - {dias[f_calc.weekday()]}"
                except Exception:
                    return f"Día {dia_n}"

            def fmt(val):
                return f"${float(val or 0):,.2f}"

            items = []
            for d in detalles:
                dia_numero = d.get("dia_num", 1)
                items.append({
                    "Fecha": formatear_fecha(fecha_inicio_op, dia_numero),
                    "Hotel": fmt(d.get("hotel", 0)),
                    "Transp": fmt(d.get("transporte", 0)),
                    "Combust": fmt(d.get("combustible", 0)),
                    "Casetas": fmt(d.get("casetas", 0)),
                    "Desay": fmt(d.get("desayuno", 0)),
                    "Comida": fmt(d.get("comida", 0)),
                    "Cenas": fmt(d.get("cenas", 0)),
                    "Varios": fmt(d.get("varios", 0)),
                    "Total": fmt(d.get("total_dia", 0))
                })
                
            informe = {
                "productor": nombre_productor,
                "asignado": float(m_row.get("monto_entregado", 0) or 0),
                "gastado": float(m_row.get("subtotal", 0) or 0),
                "saldo": float(m_row.get("restante", 0) or 0),
                "items": items
            }
            return {"status": "SUCCESS", "informe": informe}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

