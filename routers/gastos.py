import datetime
import unicodedata
from typing import Dict, Any, List, Optional
from fastapi import APIRouter, HTTPException
from sqlalchemy import text

from core.database import engine_eventos, engine_personal
from core.utils import safe_decode_hex

def es_usuario_autorizado_gastos(nombre: str) -> bool:
    """Verifica si el usuario es un Productor o Directivo con facultad para rendir o auditar gastos."""
    if not nombre:
        return False
    norm = ''.join(c for c in unicodedata.normalize('NFD', str(nombre).upper()) if unicodedata.category(c) != 'Mn')
    productores_autorizados = [
        "VILLARREAL", "VILLAREAL", "VILARREAL", "AGUNDEZ", 
        "SANCHEZ ESTRADA", "MADRID ZAZUETA", "TORRES SANCHEZ"
    ]
    return any(p in norm for p in productores_autorizados)

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
    """Lista las OPs activas y pendientes que no tienen informe de gastos registrado.
    Permite a los productores asignados en la OP rendir sus cuentas sin bloqueos.
    """
    query = text("""
        SELECT e.id_evento, 
               encode(e.para_q_cliente::bytea, 'hex'), 
               encode(e.nombre_evento::bytea, 'hex'),
               encode(e.resp_de_produccion::bytea, 'hex'),
               e.fec_del_evento,
               e.fec_de_instalacion,
               e.fec_fin_evento,
               0.0 AS estimado_gasto
        FROM public.eventos e
        WHERE UPPER(COALESCE(e.estatus, '')) != 'CERRADA (HISTÓRICO)'
          AND NOT EXISTS (
            SELECT 1 FROM public.informes_gastos_maestro m 
            WHERE m.folio_vpro = e.id_evento
        )
        ORDER BY e.id_evento DESC
    """)
    try:
        with engine_eventos.connect() as conn: 
            rows = conn.execute(query).fetchall()
            return [
                {
                    "id_evento": r[0], 
                    "cliente": safe_decode_hex(r[1]), 
                    "nombre_evento": safe_decode_hex(r[2]),
                    "productor": safe_decode_hex(r[3]),
                    "fec_evento": f"{r[4]} al {r[6]}" if (r[4] and r[6] and r[4] != r[6]) else (str(r[4]) if r[4] else (str(r[5]) if r[5] else "")),
                    "estimado_gasto": float(r[7] or 0.0)
                } for r in rows
            ]
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/evento/{id_evento}")
def obtener_datos_evento_gasto(id_evento: int):
    """Obtiene los datos base del evento para la rendición de gastos."""
    query = text("""
        SELECT encode(resp_de_produccion::bytea, 'hex'), 
               fec_de_instalacion, 
               carros_usados_op, 
               personal_convocado_op,
               encode(nombre_evento::bytea, 'hex'),
               encode(para_q_cliente::bytea, 'hex'),
               fec_del_evento,
               fec_fin_evento,
               0.0 AS estimado_gasto,
               quien_solicita,
               dependencia_solicita,
               encode(COALESCE(responsable_gastos, '')::bytea, 'hex')
        FROM public.eventos WHERE id_evento = :id
    """)
    try:
        with engine_eventos.connect() as conn: 
            res = conn.execute(query, {"id": id_evento}).first()
            if res:
                # Autos parse
                raw_autos = res[2]
                autos_list = []
                if isinstance(raw_autos, list):
                    autos_list = [str(x) for x in raw_autos if x]
                elif isinstance(raw_autos, str):
                    clean_str = raw_autos.strip("{}")
                    if clean_str:
                        autos_list = [x.strip(' "\'') for x in clean_str.split(",") if x.strip(' "\'')]

                # Personal convocado parse
                raw_personal = res[3]
                personal_list = []
                if isinstance(raw_personal, list):
                    personal_list = [str(x) for x in raw_personal if x]
                elif isinstance(raw_personal, str):
                    clean_str = raw_personal.strip("{}")
                    if clean_str:
                        personal_list = [x.strip(' "\'') for x in clean_str.split(",") if x.strip(' "\'')]

                return {
                    "productor_responsable": safe_decode_hex(res[0]), 
                    "responsable_gastos": safe_decode_hex(res[11]),
                    "fec_de_instalacion": str(res[1]) if res[1] else None, 
                    "carros_usados_op": autos_list, 
                    "personal_convocado_op": personal_list,
                    "nombre_evento": safe_decode_hex(res[4]),
                    "cliente": safe_decode_hex(res[5]),
                    "fec_del_evento": str(res[6]) if res[6] else None,
                    "fec_fin_evento": str(res[7]) if res[7] else (str(res[6]) if res[6] else None),
                    "estimado_gasto": float(res[8] or 0.0),
                    "quien_solicita": str(res[9] or ""),
                    "dependencia_solicita": str(res[10] or "")
                }
            raise HTTPException(status_code=404, detail="Evento no mapeado")
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/guardar")
def guardar_informe_gastos_completo(payload: dict):
    """Guarda un nuevo informe de gastos por comprobar (maestro y detalles diarios)."""
    try:
        maestro = payload.get("maestro", {})
        detalles = payload.get("detalles", [])
        
        folio_vpro = int(maestro.get("folio_vpro", 0))
        emp_id = str(maestro.get("id_empleado", "")).strip()[:3]
        nombre_usuario = str(maestro.get("nombre_usuario", "")).strip()

        # 🔒 Consultar el Productor Responsable y Responsable de Gastos asignados en la OP
        prod_op_nom = ""
        resp_gastos_nom = ""
        if folio_vpro:
            try:
                with engine_eventos.connect() as ev_conn:
                    row_ev = ev_conn.execute(
                        text("SELECT encode(resp_de_produccion::bytea, 'hex'), encode(COALESCE(responsable_gastos, '')::bytea, 'hex') FROM public.eventos WHERE id_evento = :id"),
                        {"id": folio_vpro}
                    ).first()
                    if row_ev:
                        prod_op_nom = safe_decode_hex(row_ev[0]).strip() if row_ev[0] else ""
                        resp_gastos_nom = safe_decode_hex(row_ev[1]).strip() if row_ev[1] else ""
            except Exception:
                pass

        # El responsable oficial designado para la OP (Responsable de Gastos tiene precedencia si se especificó, sino Productor)
        responsable_oficial_nom = resp_gastos_nom if resp_gastos_nom else prod_op_nom

        # Obtener el ID de empleado oficial del responsable desde db_personal
        emp_id_oficial = None
        if responsable_oficial_nom:
            try:
                with engine_personal.connect() as p_conn:
                    emp_rows = p_conn.execute(text("SELECT TRIM(id_empleado), encode(nombre::bytea, 'hex') FROM public.empleados")).fetchall()
                    for er in emp_rows:
                        nom_bd = safe_decode_hex(er[1]).strip().lower()
                        if nom_bd and (nom_bd == responsable_oficial_nom.lower() or responsable_oficial_nom.lower() in nom_bd or nom_bd in responsable_oficial_nom.lower()):
                            emp_id_oficial = str(er[0])[:3]
                            break
            except Exception:
                pass

        # 🔒 REGLA ESTRICTA: Solo el Productor Responsable o el Responsable de Gastos de la OP puede elaborar este reporte
        es_autor_valido = False
        if responsable_oficial_nom:
            norm_resp = ''.join(c for c in unicodedata.normalize('NFD', responsable_oficial_nom.upper()) if unicodedata.category(c) != 'Mn')
            norm_usr = ''.join(c for c in unicodedata.normalize('NFD', nombre_usuario.upper()) if unicodedata.category(c) != 'Mn')
            if emp_id_oficial and emp_id == emp_id_oficial:
                es_autor_valido = True
            elif norm_resp and norm_usr and (norm_resp in norm_usr or norm_usr in norm_resp):
                es_autor_valido = True

        if not es_autor_valido and responsable_oficial_nom:
            raise HTTPException(
                status_code=403,
                detail=f"Acceso denegado: Solo el Productor Responsable o el Responsable de Gastos asignado a la OP-{folio_vpro} ({responsable_oficial_nom}) está facultado para elaborar y remitir este reporte."
            )

        # Asignar id_empleado oficial al registro para garantizar trazabilidad 100%
        if emp_id_oficial:
            emp_id = emp_id_oficial
        elif not emp_id or emp_id == "000":
            emp_id = "000"

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
                "folio_vpro": folio_vpro, 
                "id_empleado": emp_id, 
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

        # Sellar y archivar automáticamente el chat operativo de la OP relacionada al rendir gastos
        if folio_vpro:
            try:
                with engine_eventos.begin() as conn_seal:
                    msjs_op = conn_seal.execute(text("""
                        SELECT encode(autor_nombre::bytea, 'hex') AS aut_hex,
                               autor_rol,
                               encode(mensaje::bytea, 'hex') AS msj_hex,
                               archivo_url,
                               to_char(fecha_hora, 'YYYY-MM-DD HH24:MI:SS') AS fec_hora
                        FROM public.chat_op_mensajes
                        WHERE id_evento = :id_ev OR folio = CAST(:id_ev AS text)
                        ORDER BY fecha_hora ASC, id ASC
                    """), {"id_ev": folio_vpro}).fetchall()

                    op_info = conn_seal.execute(text("""
                        SELECT id_evento, folio,
                               encode(nombre_evento::bytea, 'hex') AS nombre_hex,
                               encode(locacion::bytea, 'hex') AS loc_hex,
                               encode(resp_de_produccion::bytea, 'hex') AS resp_hex,
                               fec_del_evento, hra_de_llamado,
                               chat_historial
                        FROM public.eventos
                        WHERE id_evento = :id_ev OR folio = CAST(:id_ev AS text)
                    """), {"id_ev": folio_vpro}).mappings().first()

                    if op_info and not (op_info["chat_historial"] and str(op_info["chat_historial"]).strip()):
                        nom_ev = safe_decode_hex(op_info["nombre_hex"])
                        loc_ev = safe_decode_hex(op_info["loc_hex"])
                        resp_prod = safe_decode_hex(op_info["resp_hex"])
                        folio_str = op_info["folio"] or str(op_info["id_evento"])
                        ahora_cierre = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

                        lineas = [
                            "=" * 80,
                            f"BITÁCORA OFICIAL DE CHAT OPERATIVO - VPRO WORKSPACE",
                            f"ORDEN DE PRODUCCIÓN: OP-{folio_str} | EVENTO: {nom_ev}",
                            f"LOCACIÓN: {loc_ev}",
                            f"FECHA DEL EVENTO: {op_info['fec_del_evento'] or 'N/A'} | HORA LLAMADO: {op_info['hra_de_llamado'] or 'N/A'}",
                            f"PRODUCTOR RESPONSABLE: {resp_prod}",
                            "-" * 80,
                            f"ESTADO: CERRADO Y SELLADO AL RENDIR REPORTE DE GASTOS",
                            f"SELLADO POR: {emp_nombre or resp_prod}",
                            f"FECHA Y HORA DE CIERRE: {ahora_cierre}",
                            f"TOTAL REGISTROS INTEGRADOS: {len(msjs_op)} MENSAJES Y EVIDENCIAS",
                            "=" * 80,
                            ""
                        ]
                        if not msjs_op:
                            lineas.append("[Sin mensajes registrados durante la cobertura]")
                        else:
                            for m in msjs_op:
                                m_aut = safe_decode_hex(m.aut_hex)
                                m_txt = safe_decode_hex(m.msj_hex)
                                m_adj = f" | [Adjunto: {m.archivo_url}]" if m.archivo_url else ""
                                lineas.append(f"[{m.fec_hora}] [{m.autor_rol or 'STAFF'}] {m_aut}:{m_adj}")
                                lineas.append(f"  {m_txt}\n")
                        lineas.extend([
                            "-" * 80,
                            "FIN DE LA BITÁCORA - EXPEDIENTE SELLADO PARA AUDITORÍA Y ACLARACIONES",
                            "=" * 80
                        ])
                        bitacora_txt = "\n".join(lineas)

                        conn_seal.execute(text("""
                            UPDATE public.eventos
                            SET chat_cerrado = TRUE,
                                chat_cerrado_por = :cerrador,
                                chat_fecha_cierre = NOW(),
                                chat_historial = :hist
                            WHERE id_evento = :id_ev OR folio = CAST(:id_ev AS text)
                        """), {
                            "cerrador": emp_nombre or resp_prod,
                            "hist": bitacora_txt,
                            "id_ev": folio_vpro
                        })
                    else:
                        conn_seal.execute(text("""
                            UPDATE public.eventos
                            SET chat_cerrado = TRUE
                            WHERE id_evento = :id_ev OR folio = CAST(:id_ev AS text)
                        """), {"id_ev": folio_vpro})
            except Exception as e_seal:
                print(f"Aviso al autosellar chat OP-{folio_vpro}: {e_seal}")

        return {"status": "SUCCESS", "id_informe": id_informe}
    except HTTPException:
        raise
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

