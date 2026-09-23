import json
import csv
import time
from typing import Dict, Any, List, Optional
from fastapi import APIRouter, HTTPException
from sqlalchemy import text

from core.database import (
    engine_eventos, engine_personal, 
    engine_inventario, engine_inventario_vieja
)
from core.utils import safe_decode_hex, reparar_mojibake

router = APIRouter(tags=["📦 Checkout & Logística"])

@router.get("/api/checkout/init-data/{id_empleado}")
def inicializar_modulo_checkout(id_empleado: str):
    """Carga los datos iniciales de órdenes, kits y alertas de checkout para el empleado."""
    try:
        with engine_eventos.connect() as conn:
            evs_query = text("""
               SELECT DISTINCT e.id_evento, encode(e.para_q_cliente::bytea,'hex'), encode(e.nombre_evento::bytea,'hex') 
               FROM public.eventos e
               WHERE UPPER(COALESCE(e.estatus, 'ACTIVA')) != 'CERRADA (HISTÓRICO)'
                 AND NOT EXISTS (
                     SELECT 1 FROM public.informes_gastos_maestro igm 
                     WHERE igm.folio_vpro = e.id_evento
                 )
               ORDER BY e.id_evento DESC
            """)
            evs = conn.execute(evs_query).fetchall()
            
            kits_rows = conn.execute(
                text("SELECT DISTINCT encode(nombre_kit::bytea,'hex') FROM public.kits_empleados WHERE TRIM(id_empleado) = :id"),
                {"id": id_empleado.strip()}
            ).fetchall()
            
            pendientes_raw = conn.execute(
                text("SELECT id_empleado, folio_op FROM public.checkouts_maestro WHERE (incidencias_generales IS NULL OR incidencias_generales = '') AND estado_bodega = 'RECIBIDO'")
            ).fetchall()
        
        ordenes = [f"OP-{str(r[0]).zfill(3)} | {safe_decode_hex(r[1])} - {safe_decode_hex(r[2])}" for r in evs]
        lista_kits = [safe_decode_hex(k[0]) for k in kits_rows]
        
        alertas_lista = []
        if pendientes_raw:
            ids_p = list(set([str(p[0]).strip() for p in pendientes_raw if p[0]]))
            with engine_personal.connect() as conn_p:
                ids_formateados = "', '".join(ids_p)
                df_emp = conn_p.execute(text(f"SELECT TRIM(id_empleado), encode(nombre::bytea,'hex') FROM public.empleados WHERE id_empleado IN ('{ids_formateados}')")).fetchall()
            dict_nombres = {r[0]: safe_decode_hex(r[1]) for r in df_emp}
            for p in pendientes_raw:
                alertas_lista.append({"folio": p[1], "nombre": dict_nombres.get(str(p[0]).strip(), "Desconocido")})

        return {"ordenes": ordenes, "kits": lista_kits, "alertas_pendientes": alertas_lista}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/api/checkout/kits/{id_empleado}")
def obtener_kits_por_empleado(id_empleado: str):
    """Obtiene los nombres de plantillas/kits asignados al empleado."""
    try:
        with engine_eventos.connect() as conn:
            kits_rows = conn.execute(
                text("SELECT DISTINCT encode(nombre_kit::bytea,'hex') FROM public.kits_empleados WHERE TRIM(id_empleado) = :id"), 
                {"id": id_empleado.strip()}
            ).fetchall()
        return {"kits": [reparar_mojibake(safe_decode_hex(k[0])) for k in kits_rows]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/api/checkout/verificar-salida-coordinador", tags=["📦 Checkout & Checkin"])
def verificar_salida_coordinador(payload: dict):
    """Autoriza la salida de bodega por el coordinador."""
    id_maestro = payload.get("id_maestro")
    incidencias = payload.get("incidencias_generales")
    items = payload.get("items", [])
    try:
        with engine_eventos.begin() as conn: 
            conn.execute(
                text("UPDATE public.checkouts_maestro SET estado_bodega = 'DESPACHADO', incidencias_generales = :inc WHERE id_maestro = :id"), 
                {"inc": incidencias, "id": id_maestro}
            )
            for item in items:
                conn.execute(
                    text("UPDATE public.checkouts_detalle SET cantidad = :cant, observaciones = :obs WHERE id_detalle = :id_det"), 
                    {"cant": int(item.get("CANT", 1)), "obs": str(item.get("OBSERVACIONES", "")).strip(), "id_det": item.get("id_detalle")}
                )
        return {"status": "SUCCESS"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/api/eventos/buscar_kit/{nombre_kit}/{id_empleado}")
def buscar_kit_operador(nombre_kit: str, id_empleado: str):
    """Busca el contenido de un kit o plantilla para un operador específico."""
    query = text("SELECT items FROM public.kits_empleados WHERE LOWER(TRIM(nombre_kit)) = LOWER(TRIM(:nom)) AND LOWER(TRIM(id_empleado)) = LOWER(TRIM(:id))")
    try:
        with engine_eventos.connect() as conn: 
            row = conn.execute(query, {"nom": nombre_kit.strip(), "id": id_empleado.strip()}).fetchone()
        if not row:
            return {"items": []}
        
        val = row[0]
        if isinstance(val, str):
            try:
                val = json.loads(val)
                if isinstance(val, str):
                    val = json.loads(val)
            except Exception:
                val = []
        if not isinstance(val, list):
            val = []
        
        for item in val:
            if isinstance(item, dict):
                if "EQUIPO" in item:
                    item["EQUIPO"] = reparar_mojibake(item["EQUIPO"])
                if "OBSERVACIONES" in item:
                    item["OBSERVACIONES"] = reparar_mojibake(item["OBSERVACIONES"])
                
        return {"items": val}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/api/checkout/status/{id_evento}/{id_empleado}")
def extraer_estado_checkout(id_evento: int, id_empleado: str):
    """Consulta el estado del checkout de una OP para un empleado específico."""
    try:
        with engine_eventos.connect() as conn:
            conv_row = conn.execute(
                text("SELECT encode(personal_convocado_op::text::bytea, 'hex'), encode(proveedor_op::text::bytea, 'hex') FROM public.eventos WHERE id_evento = :id"), 
                {"id": id_evento}
            ).fetchone()
            convocados = safe_decode_hex(conv_row[0]) if conv_row and conv_row[0] else "[]"
            proveedores_op = safe_decode_hex(conv_row[1]) if conv_row and len(conv_row) > 1 and conv_row[1] else "[]"
            
            m_row = conn.execute(
                text("SELECT id_maestro, encode(incidencias_generales::text::bytea, 'hex'), estado_bodega, encode(nombre_kit::text::bytea, 'hex') FROM public.checkouts_maestro WHERE folio_op = :id AND TRIM(id_empleado) = :emp"), 
                {"id": id_evento, "emp": id_empleado.strip()}
            ).fetchone()
            
            df_detalle = []
            if m_row:
                id_maestro = m_row[0]
                det_rows = conn.execute(
                    text("SELECT id_detalle, encode(codigo_equipo::text::bytea,'hex') as id_eq, cantidad, encode(observaciones::text::bytea,'hex'), cotejado, encode(notas_regreso::text::bytea,'hex') FROM public.checkouts_detalle WHERE id_maestro = :id_m"), 
                    {"id_m": id_maestro}
                ).fetchall()
                
                df_detalle = [
                    {
                        "id_detalle": r[0],
                        "ID": safe_decode_hex(r[1]),
                        "CANT": r[2],
                        "OBSERVACIONES": reparar_mojibake(safe_decode_hex(r[3])),
                        "COTEJADO": bool(r[4]),
                        "OBS_REGRESO": reparar_mojibake(safe_decode_hex(r[5]))
                    }
                    for r in det_rows
                ]

                if df_detalle:
                    dict_inv = {}
                    
                    def cargar_catalogo(engine_db):
                        try:
                            with engine_db.connect() as c_inv:
                                inv = c_inv.execute(text("SELECT encode(codigo::text::bytea,'hex'), encode(descripcion::text::bytea,'hex') FROM public.inventario")).fetchall()
                                for r in inv:
                                    if r[0]:
                                        dict_inv[safe_decode_hex(r[0]).strip().upper()] = safe_decode_hex(r[1]).strip()
                                
                                kits = c_inv.execute(text("SELECT encode(codigo_inv_kits::text::bytea,'hex'), encode(descripcion_inv_kits::text::bytea,'hex') FROM public.inventario_kits")).fetchall()
                                for r in kits:
                                    if r[0]:
                                        dict_inv[safe_decode_hex(r[0]).strip().upper()] = safe_decode_hex(r[1]).strip()
                        except Exception as e:
                            print(f"⚠️ Aviso cargando inventario: {e}")

                    cargar_catalogo(engine_inventario_vieja)
                    cargar_catalogo(engine_inventario)

                    for d in df_detalle: 
                        id_limpio = str(d.get("ID", "")).strip().upper()
                        obs_salida = d.get("OBSERVACIONES", "")
                        nombre_eq = dict_inv.get(id_limpio, "Equipo no registrado")
                        
                        if not id_limpio and "[CUST_EQ:" in obs_salida:
                            s_idx = obs_salida.find("[CUST_EQ:") + 9
                            e_idx = obs_salida.find("]", s_idx)
                            if e_idx != -1:
                                nombre_eq = obs_salida[s_idx:e_idx]
                                d["OBSERVACIONES"] = (obs_salida[:obs_salida.find("[CUST_EQ:")].strip() + " " + obs_salida[e_idx+1:].strip()).strip()

                        d["EQUIPO"] = reparar_mojibake(nombre_eq)

        return {
            "convocados": convocados, 
            "proveedores_op": proveedores_op, 
            "id_maestro": m_row[0] if m_row else None, 
            "incidencias_generales": reparar_mojibake(safe_decode_hex(m_row[1]).strip()) if m_row and m_row[1] else "", 
            "estado_bodega": m_row[2] if m_row else "NUEVO", 
            "nombre_kit": reparar_mojibake(safe_decode_hex(m_row[3]).strip()) if m_row and m_row[3] else "--- Sin plantilla ---",
            "detalle": df_detalle
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/api/checkout/grabar-kit")
def guardar_plantilla_kit_operador(payload: dict):
    """Guarda una plantilla o kit personalizada para un operador."""
    try:
        def sanitizar_cadena(val):
            if val is None: 
                return ""
            if isinstance(val, bytes):
                return val.decode('utf-8', errors='ignore')
            return str(val).encode('utf-8', errors='ignore').decode('utf-8')

        id_emp = sanitizar_cadena(payload.get("id_empleado", "")).strip()
        nom_kit = sanitizar_cadena(payload.get("nombre_kit", "")).strip()
        items_raw = payload.get("items", [])
        user_actual = sanitizar_cadena(payload.get("usuario_actual", ""))
        
        items_limpios = []
        for it in items_raw:
            items_limpios.append({
                "ID": sanitizar_cadena(it.get("ID", "")),
                "EQUIPO": sanitizar_cadena(it.get("EQUIPO", "")),
                "OBSERVACIONES": sanitizar_cadena(it.get("OBSERVACIONES", ""))
            })
        
        items_json = json.dumps(items_limpios, ensure_ascii=True)
        
        with engine_eventos.begin() as conn_ev:
            conn_ev.execute(
                text("DELETE FROM public.kits_empleados WHERE LOWER(TRIM(nombre_kit)) = LOWER(TRIM(:nom)) AND LOWER(TRIM(id_empleado)) = LOWER(TRIM(:id))"), 
                {"nom": nom_kit, "id": id_emp}
            )
            conn_ev.execute(
                text("INSERT INTO public.kits_empleados (id_empleado, nombre_kit, items) VALUES (TRIM(:id), TRIM(:nom), :items)"), 
                {"id": id_emp, "nom": nom_kit, "items": items_json}
            )
        
        with engine_inventario.begin() as conn_inv:
            for item in items_limpios:
                conn_inv.execute(text("""
                    INSERT INTO public.inventario_kits (
                        codigo_inv_kits, descripcion_inv_kits, responsable_inv_kits, 
                        id_empleado_ref_inv_kits, estado_inv_kits, ubicacion_inv_kits, 
                        observaciones_inv_kits, fecha_registro_inv_kits
                    )
                    VALUES (:cod, :desc, :resp, :ref, 'Buen Estado', 'BODEGA', :obs, NOW())
                    ON CONFLICT (codigo_inv_kits) 
                    DO UPDATE SET 
                        descripcion_inv_kits = EXCLUDED.descripcion_inv_kits, 
                        responsable_inv_kits = EXCLUDED.responsable_inv_kits;
                """), {
                    "cod": item["ID"], 
                    "desc": item["EQUIPO"], 
                    "resp": user_actual, 
                    "ref": id_emp, 
                    "obs": item["OBSERVACIONES"]
                })
        return {"status": "SUCCESS"}
    except Exception as e:
        err_clean = str(e).encode('utf-8', errors='ignore').decode('utf-8')
        raise HTTPException(status_code=500, detail=err_clean)

@router.post("/api/checkout/finalizar-salida")
def registrar_finalizacion_checkout(payload: dict):
    """Registra la salida física de hardware para una OP."""
    try:
        items = payload.get("items", [])
        id_op = int(payload["id_evento"])
        id_sujeto = str(payload["id_sujeto_a_revisar"]).strip()
        incidencias_gen = str(payload["incidencias_generales"])
        nombre_kit = str(payload.get("nombre_kit", "--- Sin plantilla ---")).strip() 
        
        with engine_eventos.begin() as conn:
            m_id = conn.execute(
                text("SELECT id_maestro FROM public.checkouts_maestro WHERE folio_op = :id AND TRIM(id_empleado) = :emp"), 
                {"id": id_op, "emp": id_sujeto}
            ).scalar()
            
            if m_id:
                conn.execute(text("DELETE FROM public.checkouts_detalle WHERE id_maestro = :id_m"), {"id_m": m_id})
                conn.execute(
                    text("UPDATE public.checkouts_maestro SET fecha=CURRENT_DATE, hora=CURRENT_TIME, incidencias_generales=:obs, nombre_kit=:kit WHERE id_maestro=:id_m"), 
                    {"obs": incidencias_gen, "kit": nombre_kit, "id_m": m_id}
                )
            else:
                m_id = conn.execute(
                    text("INSERT INTO public.checkouts_maestro (folio_op, id_empleado, fecha, hora, estado_bodega, incidencias_generales, nombre_kit) VALUES (:id, :emp, CURRENT_DATE, CURRENT_TIME, 'PENDIENTE', :obs, :kit) RETURNING id_maestro"), 
                    {"id": id_op, "emp": id_sujeto, "obs": incidencias_gen, "kit": nombre_kit}
                ).scalar()
            
            for item in items:
                if str(item.get("EQUIPO","")).strip().lower() not in ["none", "nan", ""]:
                    conn.execute(
                        text("INSERT INTO public.checkouts_detalle (id_maestro, codigo_equipo, cantidad, observaciones, cotejado, notas_regreso) VALUES (:id_m, :cod, :cant, :obs, false, '')"), 
                        {"id_m": int(m_id), "cod": str(item.get("ID","")), "cant": int(item.get("CANT", 1)), "obs": str(item.get("OBSERVACIONES",""))}
                    )
        return {"status": "SUCCESS"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/api/checkout/finalizar-checkin")
def registrar_retorno_checkin(payload: dict):
    """Registra el retorno físico de hardware, auditoría de daños y liberación de OP."""
    try:
        id_maestro = int(payload["id_maestro"])
        id_op = int(payload["id_evento"])
        incidencias_gen = str(payload["incidencias_generales"])
        items = payload["items"]
        
        with engine_eventos.begin() as conn_ev:
            conn_ev.execute(text("""
                UPDATE public.checkouts_maestro 
                SET estado_bodega = 'RECIBIDO', 
                    incidencias_generales = :obs, 
                    fecha = CURRENT_DATE, 
                    hora = CURRENT_TIME 
                WHERE id_maestro = :id_m
            """), {"obs": incidencias_gen, "id_m": id_maestro})

            for item in items:
                valor_cotejo = bool(item.get("COTEJADO", item.get("cotejado", False)))
                conn_ev.execute(text("""
                    UPDATE public.checkouts_detalle 
                    SET cotejado = :cot, notas_regreso = :not_r 
                    WHERE id_detalle = :id_d
                """), {"cot": valor_cotejo, "not_r": str(item.get("OBS_REGRESO", "")), "id_d": int(item["id_detalle"])})
        
        with engine_inventario.begin() as conn_inv:
            for item in items:
                cod_eq = str(item["ID"]).strip()
                obs_regreso = str(item.get("OBS_REGRESO", "")).strip()
                valor_cotejo = bool(item.get("COTEJADO", item.get("cotejado", False)))
                
                es_danado = any(p in obs_regreso.lower() for p in ["dañ", "rot", "fall", "quebr", "freg", "mal", "golp", "abiert", "daã"])
                medico_status = "DANADO" if es_danado else "BUEN ESTADO"
                
                if valor_cotejo:
                    if cod_eq.lower().startswith("inv_vpro_alt_"):
                        conn_inv.execute(text("""
                            UPDATE public.inventario_kits 
                            SET ubicacion_inv_kits = 'BODEGA', estado_inv_kits = :est, observaciones_inv_kits = :obs 
                            WHERE codigo_inv_kits = :cod
                        """), {"cod": cod_eq, "est": medico_status, "obs": obs_regreso})
                    else:
                        conn_inv.execute(text("""
                            UPDATE public.inventario 
                            SET ubicacion = 'BODEGA', estado = :est, observaciones = :obs 
                            WHERE codigo = :cod
                        """), {"cod": cod_eq, "est": "DAÑADO" if es_danado else "OK", "obs": obs_regreso})
                
                if obs_regreso:
                    conn_inv.execute(text("""
                        INSERT INTO public.historial_equipo 
                            (codigo_equipo, fecha, folio_vpro, id_empleado, tipo_evento, descripcion, costo_asociado, estado_final, departamento) 
                        VALUES 
                            (:codigo_equipo, CURRENT_DATE, :folio_vpro, :id_empleado, :tipo_evento, :descripcion, :costo_asociado, :estado_final, :departamento)
                    """), {
                        "codigo_equipo": cod_eq.upper(), 
                        "folio_vpro": f"OP-{id_op}", 
                        "id_empleado": "000", 
                        "tipo_evento": "FALLA_EN_SET" if es_danado else "CHECKIN_REVISIÓN", 
                        "descripcion": obs_regreso, 
                        "costo_asociado": 0.0, 
                        "estado_final": "MANTENIMIENTO" if es_danado else "RESUELTO", 
                        "departamento": "BODEGA"
                    })

                    if es_danado:
                        ticket_ruta = f"REP-RUT-{int(time.time())}-{cod_eq.upper()[:4]}"
                        conn_inv.execute(text("""
                            INSERT INTO public.reparaciones 
                                (num_d_servicio, equipo_n_reparacion, reportante, descripcion_del_dano, estado_actual, costo_d_reparacion, fecha_d_reporte, area_q_pertenece, folio_vpro) 
                            VALUES 
                                (:num_serv, :eq, 'Operación / Ruta (Check-in)', :desc, '⚙️ EN REPARACIÓN', 0.0, CURRENT_DATE, 'SISTEMAS', :fol)
                        """), {
                            "num_serv": ticket_ruta, 
                            "eq": cod_eq.upper(), 
                            "desc": obs_regreso, 
                            "fol": f"OP-{id_op}"
                        })

            if "[PROVEEDOR_INCIDENTE:" in incidencias_gen:
                try:
                    start_idx = incidencias_gen.find("[PROVEEDOR_INCIDENTE:") + 21
                    end_idx = incidencias_gen.find("]", start_idx)
                    if end_idx != -1:
                        raw_prov = incidencias_gen[start_idx:end_idx].strip()
                        prov_nom, prov_nota = "--- NINGUNO ---", ""
                        if " | NOTA: " in raw_prov:
                            prov_nom, prov_nota = raw_prov.split(" | NOTA: ", 1)
                        else:
                            prov_nom = raw_prov

                        prov_nom = prov_nom.strip().upper()
                        prov_nota = prov_nota.strip()

                        if prov_nom and prov_nom != "--- NINGUNO ---":
                            ticket_prov = f"REP-PRV-{int(time.time())}"
                            conn_inv.execute(text("""
                                INSERT INTO public.reparaciones 
                                    (num_d_servicio, equipo_n_reparacion, reportante, descripcion_del_dano, estado_actual, costo_d_reparacion, fecha_d_reporte, area_q_pertenece, folio_vpro) 
                                VALUES 
                                    (:num_serv, 'INCIDENCIA/FALTA DE SERVICIO', :reportante, :desc, '⚠️ REPORTADO A DIRECCIÓN', 0.0, CURRENT_DATE, 'PROVEEDORES', :fol)
                            """), {
                                "num_serv": ticket_prov,
                                "reportante": prov_nom,
                                "desc": f"Falta/Daño reportado en Check-in de OP-{id_op}: {prov_nota}",
                                "fol": f"OP-{id_op}"
                            })
                except Exception as ex_p:
                    print(f"⚠️ Alerta al procesar culpa del proveedor: {ex_p}")

        return {"status": "SUCCESS"}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/api/checkout/pendientes/{id_empleado}/{nombre_usuario}")
def obtener_ops_pendientes_usuario(id_empleado: str, nombre_usuario: str):
    """Consulta las OPs que tienen checkouts pendientes para el usuario."""
    try:
        target_user = nombre_usuario.strip()
        with engine_eventos.connect() as conn:
            query_pendientes = text("""
                SELECT e.id_evento, encode(e.para_q_cliente::bytea, 'hex'), encode(e.nombre_evento::bytea, 'hex'), 
                       e.personal_convocado_op, encode(e.resp_de_produccion::bytea, 'hex') 
                FROM public.eventos e
                WHERE UPPER(COALESCE(e.estatus, 'ACTIVA')) != 'CERRADA (HISTÓRICO)'
                  AND NOT EXISTS (
                      SELECT 1 FROM public.informes_gastos_maestro igm 
                      WHERE igm.folio_vpro = e.id_evento
                  )
                ORDER BY e.id_evento DESC
            """)
            rows = conn.execute(query_pendientes).fetchall()
            ops_pendientes = []
            
            for r in rows:
                id_ev = r[0]
                cliente = reparar_mojibake(safe_decode_hex(r[1]))
                evento = reparar_mojibake(safe_decode_hex(r[2]))
                personal_raw = r[3]
                resp_prod = reparar_mojibake(safe_decode_hex(r[4])).strip() if r[4] else ""
                
                convocados = []
                if personal_raw:
                    if isinstance(personal_raw, list):
                        convocados = [str(p).strip() for p in personal_raw if p]
                    elif isinstance(personal_raw, str):
                        s = personal_raw.strip()
                        if s.startswith("{") and s.endswith("}"):
                            s = s[1:-1]
                            try:
                                convocados = [x.strip() for x in next(csv.reader([s])) if x]
                            except Exception:
                                convocados = [x.strip().strip('"').strip() for x in s.split(",") if x]
                        else:
                            convocados = [x.strip().strip('"').strip() for x in s.split(",") if x]
                
                es_productor = (resp_prod.upper() == target_user.upper())
                es_convocado = (target_user in convocados)

                if es_convocado:
                    m_row = conn.execute(
                        text("SELECT estado_bodega FROM public.checkouts_maestro WHERE folio_op = :id AND TRIM(id_empleado) = :emp"), 
                        {"id": id_ev, "emp": id_empleado.strip()}
                    ).mappings().first()
                    estado_actual_bodega = m_row["estado_bodega"] if m_row else "NUEVO"
                    
                    if estado_actual_bodega in ["NUEVO", "PENDIENTE"]:
                        ops_pendientes.append({
                            "id_evento": id_ev, 
                            "label": f"OP-{str(id_ev).zfill(3)} | {cliente} - {evento}", 
                            "estado": estado_actual_bodega
                        })
                        continue

                if es_productor and not any(op["id_evento"] == id_ev for op in ops_pendientes):
                    pendientes_crew = conn.execute(
                        text("SELECT count(id_maestro) FROM public.checkouts_maestro WHERE folio_op = :id AND estado_bodega != 'RECIBIDO'"),
                        {"id": id_ev}
                    ).scalar() or 0
                    total_creados = conn.execute(
                        text("SELECT count(id_maestro) FROM public.checkouts_maestro WHERE folio_op = :id"),
                        {"id": id_ev}
                    ).scalar() or 0
                    if pendientes_crew > 0 or (len(convocados) > total_creados):
                        ops_pendientes.append({
                            "id_evento": id_ev, 
                            "label": f"OP-{str(id_ev).zfill(3)} | {cliente} - {evento} (Productor)", 
                            "estado": "PENDIENTE (Equipo)"
                        })
            return ops_pendientes
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/api/checkout/historial-op/{id_evento}")
def obtener_historial_checkouts_op(id_evento: int):
    """Consulta el historial de todos los checkouts y retornos de una OP."""
    try:
        with engine_eventos.connect() as conn:
            q_maestro = text("""
                SELECT id_maestro, id_empleado, fecha, hora, estado_bodega, 
                       encode(incidencias_generales::bytea, 'hex'), 
                       encode(nombre_kit::bytea, 'hex')
                FROM public.checkouts_maestro 
                WHERE folio_op = :id_ev
            """)
            maestros = conn.execute(q_maestro, {"id_ev": id_evento}).fetchall()
            
            if not maestros:
                return {"status": "EMPTY", "checkouts": []}
                
            with engine_personal.connect() as conn_p:
                emp_rows = conn_p.execute(text("SELECT TRIM(id_empleado), encode(nombre::bytea, 'hex') FROM public.empleados")).fetchall()
                dict_emps = {r[0]: safe_decode_hex(r[1]) for r in emp_rows}
            
            with engine_inventario.connect() as conn_i:
                inv_rows = conn_i.execute(text("SELECT codigo, encode(descripcion::bytea, 'hex') FROM public.inventario")).fetchall()
                inv_kits_rows = conn_i.execute(text("SELECT codigo_inv_kits, encode(descripcion_inv_kits::bytea, 'hex') FROM public.inventario_kits")).fetchall()
                dict_eq = {str(r[0]).strip().upper(): safe_decode_hex(r[1]) for r in inv_rows if r[0]}
                dict_eq.update({str(r[0]).strip().upper(): safe_decode_hex(r[1]) for r in inv_kits_rows if r[0]})

            resultados = []
            for m in maestros:
                id_m = m[0]
                nombre_emp = dict_emps.get(str(m[1]).strip(), f"ID: {m[1]}")
                
                q_detalle = text("""
                    SELECT encode(codigo_equipo::bytea, 'hex'), cantidad, encode(observaciones::bytea, 'hex'), 
                           cotejado, encode(notas_regreso::bytea, 'hex')
                    FROM public.checkouts_detalle WHERE id_maestro = :id_m
                """)
                detalles = conn.execute(q_detalle, {"id_m": id_m}).fetchall()
                
                items = []
                for d in detalles:
                    cod_eq = safe_decode_hex(d[0]).strip()
                    obs_salida = safe_decode_hex(d[2])
                    nombre_eq = dict_eq.get(cod_eq.upper(), "Equipo No Registrado")
                    
                    if not cod_eq and "[CUST_EQ:" in obs_salida:
                        s_idx = obs_salida.find("[CUST_EQ:") + 9
                        e_idx = obs_salida.find("]", s_idx)
                        if e_idx != -1:
                            nombre_eq = obs_salida[s_idx:e_idx]
                            obs_salida = obs_salida[:obs_salida.find("[CUST_EQ:")].strip() + " " + obs_salida[e_idx+1:].strip()
                            
                    items.append({
                        "CÓDIGO": cod_eq,
                        "EQUIPO": nombre_eq,
                        "CANT": d[1],
                        "OBS. SALIDA": obs_salida,
                        "¿REGRESÓ?": "✅ SÍ" if d[3] else "❌ NO",
                        "INCIDENCIA / DAÑO": safe_decode_hex(d[4])
                    })
                    
                resultados.append({
                    "empleado": nombre_emp,
                    "fecha": str(m[2]) if m[2] else "",
                    "hora": str(m[3]) if m[3] else "",
                    "estado": m[4],
                    "incidencias": safe_decode_hex(m[5]),
                    "plantilla": safe_decode_hex(m[6]),
                    "items": items
                })
            return {"status": "SUCCESS", "checkouts": resultados}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

