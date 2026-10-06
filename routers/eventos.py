import datetime
import os, shutil, time, re
from fastapi import APIRouter, HTTPException, UploadFile, File
from sqlalchemy import text
from typing import Dict, Any, List

from core.database import (
    engine_autos, engine_clientes, engine_proveedores, 
    engine_personal, engine_eventos
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
        # Solo OPs activas (o habilitadas explícitamente para edición)
        query_activos_nueva = text("""
            SELECT folio, nombre_evento, COALESCE(habilitada_para_edicion, FALSE) AS habilitada_para_edicion
            FROM public.eventos 
            WHERE habilitada_para_edicion = TRUE
               OR (
                   UPPER(COALESCE(estatus, '')) != 'CERRADA (HISTÓRICO)'
                   AND NOT EXISTS (
                       SELECT 1 FROM public.informes_gastos_maestro m 
                       WHERE m.folio_vpro = id_evento
                   )
               )
            ORDER BY id_evento DESC
        """)
        # OPs en archivo histórico (solo si no están habilitadas para edición)
        query_historicos_nueva = text("""
            SELECT folio, nombre_evento 
            FROM public.eventos 
            WHERE (habilitada_para_edicion IS NOT TRUE)
              AND (
                  UPPER(COALESCE(estatus, '')) = 'CERRADA (HISTÓRICO)'
                  OR EXISTS (
                      SELECT 1 FROM public.informes_gastos_maestro m 
                      WHERE m.folio_vpro = id_evento
                  )
              )
            ORDER BY id_evento DESC
        """)
        query_max_id = text("SELECT COALESCE(MAX(id_evento), 0) + 1 AS proximo_id FROM public.eventos")

        folios_activos = []
        folios_historicos = []
        max_id_nuevo = 1

        with engine_eventos.connect() as conn:
            activos_nuevos = conn.execute(query_activos_nueva).mappings().fetchall()
            historicos_nuevos = conn.execute(query_historicos_nueva).mappings().fetchall()
            max_id_nuevo = conn.execute(query_max_id).scalar()
            
            folios_activos.extend([
                f"{r['folio']} - {r['nombre_evento']}" + (" 🔓 [EN EDICIÓN]" if r.get('habilitada_para_edicion') else "")
                for r in activos_nuevos
            ])
            folios_historicos.extend([f"{r['folio']} - {r['nombre_evento']}" for r in historicos_nuevos])

        return {
            "folios": folios_activos,
            "folios_historicos": folios_historicos,
            "proximo_id": max_id_nuevo
        }
    except Exception as e:
        return {"folios": [], "folios_historicos": [], "proximo_id": 1}


@router.get("/buscar/{folio}")
@router.get("/folio/{folio}")
def buscar_op_por_folio(folio: str):
    """Busca una orden de producción por folio en la base de datos de producción,
    e integra el detalle completo de las reuniones previas vinculadas."""
    try:
        query = text("SELECT * FROM public.eventos WHERE folio = :folio")
        
        with engine_eventos.connect() as conn:
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

            # Enriquecer con el detalle completo de cronogramas vinculados
            cronogramas_raw = data.get("cronogramas_vinculados")
            cronogramas_list = []
            if isinstance(cronogramas_raw, list):
                cronogramas_list = [str(x).strip() for x in cronogramas_raw if str(x).strip()]
            elif isinstance(cronogramas_raw, str) and cronogramas_raw.strip():
                s_c = cronogramas_raw.strip()
                if s_c.startswith("{") and s_c.endswith("}"):
                    s_c = s_c[1:-1]
                import csv, io
                try:
                    cronogramas_list = [x.strip() for x in next(csv.reader(io.StringIO(s_c))) if x.strip()]
                except Exception:
                    cronogramas_list = [x.strip().strip('"').strip("'") for x in s_c.split(",") if x.strip()]

            detalles_cronogramas = []
            if cronogramas_list:
                with engine_eventos.connect() as conn:
                    for c_item in cronogramas_list:
                        c_clean = str(c_item).strip().strip('"').strip("'")
                        folio_extracted = ""
                        if "FOLIO:" in c_clean.upper():
                            try:
                                folio_extracted = c_clean.upper().split("FOLIO:")[1].split("|")[0].strip()
                            except Exception:
                                pass
                        q_cron = text("""
                            SELECT id_cronograma, folio, fecha, nombre_evento, ubicacion_general, folio_op,
                                   actividades, observaciones_generales, creado_por
                            FROM public.cronogramas_eventos
                            WHERE CONCAT('FOLIO: ', folio, ' | ', TO_CHAR(fecha, 'DD/MM/YYYY'), ' - ', COALESCE(nombre_evento, 'Sin título')) = :firma
                               OR folio = :firma
                               OR CAST(id_cronograma AS TEXT) = :firma
                               OR (folio = :folio_ext AND :folio_ext <> '')
                            LIMIT 1
                        """)
                        row_cron = conn.execute(q_cron, {"firma": c_clean, "folio_ext": folio_extracted}).mappings().first()
                        if row_cron:
                            cd = dict(row_cron)
                            cd["fecha"] = str(cd["fecha"]) if cd.get("fecha") else ""
                            detalles_cronogramas.append(cd)
            data["detalle_cronogramas"] = detalles_cronogramas

            # Enriquecer con lista de fotografías de evidencia del evento
            fotos_raw = data.get("fotos_evidencia")
            fotos_list = []
            if isinstance(fotos_raw, list):
                fotos_list = [str(x).strip() for x in fotos_raw if str(x).strip()]
            elif isinstance(fotos_raw, str) and fotos_raw.strip():
                s_f = fotos_raw.strip()
                if s_f.startswith("{") and s_f.endswith("}"):
                    s_f = s_f[1:-1]
                import csv, io
                try:
                    fotos_list = [x.strip() for x in next(csv.reader(io.StringIO(s_f))) if x.strip()]
                except Exception:
                    fotos_list = [x.strip().strip('"').strip("'") for x in s_f.split(",") if x.strip()]
            data["fotos_evidencia"] = [f for f in fotos_list if f]

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
            sanitizados = ['"' + str(x).replace('"', '\\"') + '"' for x in data]
            return "{" + ",".join(sanitizados) + "}"

        payload = dict(op)
        payload["proveedor_op"] = format_pg_array(payload.get("proveedor_op", []))
        payload["personal_convocado_op"] = format_pg_array(payload.get("personal_convocado_op", []))
        payload["carros_usados_op"] = format_pg_array(payload.get("carros_usados_op", []))
        payload["externos_op"] = format_pg_array(payload.get("externos_op", []))
        payload["reuniones_vinculadas"] = format_pg_array(payload.get("reuniones_vinculadas", []))
        payload["cronogramas_vinculados"] = format_pg_array(payload.get("cronogramas_vinculados", []))
        payload["fotos_evidencia"] = format_pg_array(payload.get("fotos_evidencia", []))
        
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
                    cronogramas_vinculados = CAST(:cronogramas_vinculados AS text[]),
                    fotos_evidencia = CAST(:fotos_evidencia AS text[]),
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
                    vobo, proveedor_op, personal_convocado_op, carros_usados_op, externos_op, reuniones_vinculadas, cronogramas_vinculados, fotos_evidencia, empleado_que_creo_la_op, fec_de_elaboracion_de_op 
                ) VALUES (
                    :id_evento, :folio, :para_q_cliente, :nombre_evento, :locacion, CAST(:fec_de_instalacion AS date), CAST(:hra_de_instalacion AS time), :quien_solicita, :resp_de_produccion, CAST(:fec_del_evento AS date), 
                    CAST(:inicio_del_evento AS time), CAST(:hra_de_llamado AS time), :ubicacion, :tipo_de_servicio, :produccion, :internet_redes, :actividades_de_proveedores, :nota, :elabora, :organiza, :coordina, 
                    :vobo, CAST(:proveedor_op AS text[]), CAST(:personal_convocado_op AS text[]), CAST(:carros_usados_op AS text[]), CAST(:externos_op AS text[]), CAST(:reuniones_vinculadas AS text[]), CAST(:cronogramas_vinculados AS text[]), CAST(:fotos_evidencia AS text[]), :empleado_que_creo_la_op, CURRENT_DATE 
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

        # Si hay cronogramas vinculados, sincronizar folio_op en cronogramas_eventos
        if op.get("cronogramas_vinculados"):
            try:
                raw_c = op.get("cronogramas_vinculados")
                lista_c = raw_c if isinstance(raw_c, list) else [str(raw_c)]
                folio_target = str(op.get("folio") or id_ev)
                with engine_eventos.begin() as conn_c:
                    for c_firma in lista_c:
                        c_clean = str(c_firma).strip().strip('"').strip("'")
                        conn_c.execute(text("""
                            UPDATE public.cronogramas_eventos
                            SET folio_op = :folio_op
                            WHERE CONCAT('FOLIO: ', folio, ' | ', TO_CHAR(fecha, 'DD/MM/YYYY'), ' - ', COALESCE(nombre_evento, 'Sin título')) = :firma
                               OR folio = :firma
                               OR CAST(id_cronograma AS TEXT) = :firma
                        """), {"folio_op": folio_target, "firma": c_clean})
            except Exception as e:
                print(f"⚠️ SILENCED ERROR updating cronogramas folio_op: {e}")

        return {"status": "SUCCESS"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/subir_foto_evidencia/{id_evento}")
async def subir_foto_evidencia(id_evento: int, file: UploadFile = File(...)):
    """Sube una fotografía de evidencia (máx 1MB) o video MP4 (máx 5MB) para la Orden de Producción."""
    try:
        from core.config import BASE_DIR
        carpeta_evidencias = BASE_DIR / "Fotos_de_eventos"
        carpeta_evidencias.mkdir(parents=True, exist_ok=True)
        
        nombre_original = os.path.basename(file.filename or "evidencia")
        ext = os.path.splitext(nombre_original)[1].lower()

        FOTOS_EXTS = {".jpg", ".jpeg", ".png", ".webp"}
        VIDEOS_EXTS = {".mp4"}

        if ext in FOTOS_EXTS:
            max_bytes = 1 * 1024 * 1024  # 1 MB
            tipo_label = "foto"
            desc_tipo = "Fotografía (máx. 1 MB)"
        elif ext in VIDEOS_EXTS:
            max_bytes = 5 * 1024 * 1024  # 5 MB
            tipo_label = "video"
            desc_tipo = "Video MP4 (máx. 5 MB)"
        else:
            raise HTTPException(
                status_code=400, 
                detail="Formato no permitido. Solo se aceptan fotografías (.jpg, .jpeg, .png, .webp) de máx. 1 MB y videos (.mp4) de máx. 5 MB."
            )

        # Leer archivo en bloques controlados para no saturar memoria ni disco
        total_leido = 0
        chunk_size = 64 * 1024  # 64 KB
        contenido = bytearray()

        while True:
            chunk = await file.read(chunk_size)
            if not chunk:
                break
            total_leido += len(chunk)
            if total_leido > max_bytes:
                limite_mb = 1 if tipo_label == "foto" else 5
                raise HTTPException(
                    status_code=400,
                    detail=f"El archivo '{nombre_original}' excede el límite máximo permitido de {limite_mb} MB para {desc_tipo}."
                )
            contenido.extend(chunk)

        nombre_sanitizado = re.sub(r'[^a-zA-Z0-9_.-]', '_', nombre_original)
        timestamp = int(time.time() * 1000)
        nuevo_nombre = f"evidencia_{tipo_label}_OP{id_evento}_{timestamp}_{nombre_sanitizado}"
        
        destino = carpeta_evidencias / nuevo_nombre
        with open(destino, "wb") as buffer:
            buffer.write(contenido)
            
        url_relativa = f"/Fotos_de_eventos/{nuevo_nombre}"
        
        # Guardar inmediatamente en la OP
        with engine_eventos.begin() as conn:
            conn.execute(text("""
                UPDATE public.eventos
                SET fotos_evidencia = array_append(COALESCE(fotos_evidencia, '{}'::text[]), :url)
                WHERE id_evento = :id_evento
            """), {"id_evento": id_evento, "url": url_relativa})
            
        return {
            "status": "SUCCESS", 
            "url": url_relativa, 
            "nombre": nuevo_nombre,
            "tipo": tipo_label,
            "tamano_bytes": total_leido
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/eliminar_foto_evidencia/{id_evento}")
def eliminar_foto_evidencia(id_evento: int, url: str):
    """Elimina una fotografía o video de evidencia vinculado a la OP."""
    try:
        url_clean = url.strip()
        with engine_eventos.begin() as conn:
            conn.execute(text("""
                UPDATE public.eventos
                SET fotos_evidencia = array_remove(COALESCE(fotos_evidencia, '{}'::text[]), :url)
                WHERE id_evento = :id_evento
            """), {"id_evento": id_evento, "url": url_clean})
            
        # Intentar remover el archivo físico
        try:
            from core.config import BASE_DIR
            nombre_archivo = os.path.basename(url_clean)
            archivo_fisico = BASE_DIR / "Fotos_de_eventos" / nombre_archivo
            if archivo_fisico.exists():
                archivo_fisico.unlink()
        except Exception:
            pass

        return {"status": "SUCCESS"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/habilitar-edicion")
def habilitar_edicion_op(payload: dict):
    """Permite al Coordinador o Admin habilitar una OP histórica para
    subir evidencias (fotos/videos) o editar información faltante."""
    folio = str(payload.get("folio", "")).strip()
    usuario = payload.get("usuario", "COORDINADOR")
    rol = str(payload.get("rol", "")).upper()
    
    # Validar permisos
    roles_permitidos = ["ADMIN", "COORDINADOR", "COORDINACION", "PRODUCCION"]
    if not any(r in rol for r in roles_permitidos):
        raise HTTPException(
            status_code=403, 
            detail="Solo personal con rol de Coordinador o Administrador puede habilitar OPs del histórico."
        )
    
    if not folio:
        raise HTTPException(status_code=400, detail="Debe especificar el folio de la OP.")
        
    try:
        with engine_eventos.begin() as conn:
            # Buscar por folio o id_evento
            res = conn.execute(
                text("""
                    UPDATE public.eventos
                    SET habilitada_para_edicion = TRUE,
                        estatus = 'HABILITADA (EDICIÓN)'
                    WHERE folio = :folio 
                       OR CAST(id_evento AS text) = :folio
                    RETURNING folio, nombre_evento, id_evento;
                """),
                {"folio": folio}
            ).mappings().first()
            
            if not res:
                raise HTTPException(status_code=404, detail=f"No se encontró la OP con folio '{folio}'.")
                
            return {
                "ok": True,
                "mensaje": f"La OP {res['folio']} - {res['nombre_evento']} ha sido habilitada para edición y evidencias.",
                "folio": res["folio"],
                "id_evento": res["id_evento"]
            }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/mandar-al-historial")
def mandar_al_historial_op(payload: dict):
    """Permite regresar una OP al archivo histórico (solo lectura)."""
    folio = str(payload.get("folio", "")).strip()
    usuario = payload.get("usuario", "COORDINADOR")
    rol = str(payload.get("rol", "")).upper()
    
    # Validar permisos
    roles_permitidos = ["ADMIN", "COORDINADOR", "COORDINACION", "PRODUCCION"]
    if not any(r in rol for r in roles_permitidos):
        raise HTTPException(
            status_code=403, 
            detail="Solo personal con rol de Coordinador o Administrador puede archivar OPs en el histórico."
        )
        
    if not folio:
        raise HTTPException(status_code=400, detail="Debe especificar el folio de la OP.")
        
    try:
        with engine_eventos.begin() as conn:
            res = conn.execute(
                text("""
                    UPDATE public.eventos
                    SET habilitada_para_edicion = FALSE,
                        estatus = 'CERRADA (HISTÓRICO)'
                    WHERE folio = :folio 
                       OR CAST(id_evento AS text) = :folio
                    RETURNING folio, nombre_evento, id_evento;
                """),
                {"folio": folio}
            ).mappings().first()
            
            if not res:
                raise HTTPException(status_code=404, detail=f"No se encontró la OP con folio '{folio}'.")
                
            return {
                "ok": True,
                "mensaje": f"La OP {res['folio']} - {res['nombre_evento']} ha sido enviada al archivo histórico.",
                "folio": res["folio"],
                "id_evento": res["id_evento"]
            }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))