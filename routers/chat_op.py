import asyncio
import datetime
import os
import shutil
import time
import re
import json
from pathlib import Path
from typing import Dict, Any, List, Optional
from fastapi import APIRouter, HTTPException, UploadFile, File, Form, WebSocket, WebSocketDisconnect
from sqlalchemy import text
from pydantic import BaseModel

from core.database import engine_eventos, engine_personal
from core.utils import safe_decode_hex, parse_pg_array, reparar_mojibake
from core.config import FOTOS_EVENTOS_DIR

router = APIRouter(prefix="/api/chat-op", tags=["💬 Chat Operativo de Producción (OP)"])

# Directorio para archivos adjuntos y fotos enviadas en los chats
CHAT_DIR = FOTOS_EVENTOS_DIR / "chat_op"
CHAT_DIR.mkdir(parents=True, exist_ok=True)

def _asegurar_tabla_chat():
    """Garantiza automáticamente que la tabla e índices de chat existan."""
    try:
        with engine_eventos.begin() as conn:
            conn.execute(text("""
                CREATE TABLE IF NOT EXISTS public.chat_op_mensajes (
                    id SERIAL PRIMARY KEY,
                    id_evento INTEGER NOT NULL REFERENCES public.eventos(id_evento) ON DELETE CASCADE,
                    folio VARCHAR(50),
                    id_empleado VARCHAR(50),
                    autor_nombre VARCHAR(255) NOT NULL,
                    autor_rol VARCHAR(100),
                    mensaje TEXT NOT NULL,
                    tipo_mensaje VARCHAR(50) DEFAULT 'TEXTO',
                    archivo_url TEXT,
                    fecha_hora TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                    es_fijado BOOLEAN DEFAULT FALSE,
                    reacciones JSONB DEFAULT '{}'::jsonb
                );
                CREATE INDEX IF NOT EXISTS idx_chat_op_mensajes_evento 
                    ON public.chat_op_mensajes(id_evento, fecha_hora ASC);
            """))
    except Exception as e:
        print(f"⚠️ Nota de verificación de tabla chat_op: {e}")

_asegurar_tabla_chat()


# ==============================================================================
# GESTOR DE CONEXIONES EN TIEMPO REAL (WEBSOCKETS)
# ==============================================================================
class ChatConnectionManager:
    def __init__(self):
        # id_evento -> lista de WebSockets activos
        self.rooms: Dict[int, List[WebSocket]] = {}

    async def connect(self, id_evento: int, websocket: WebSocket):
        await websocket.accept()
        if id_evento not in self.rooms:
            self.rooms[id_evento] = []
        self.rooms[id_evento].append(websocket)

    def disconnect(self, id_evento: int, websocket: WebSocket):
        if id_evento in self.rooms:
            if websocket in self.rooms[id_evento]:
                self.rooms[id_evento].remove(websocket)
            if not self.rooms[id_evento]:
                del self.rooms[id_evento]

    async def broadcast_to_op(self, id_evento: int, data: dict):
        if id_evento in self.rooms:
            conexiones = list(self.rooms[id_evento])
            for conn in conexiones:
                try:
                    await conn.send_json(data)
                except Exception:
                    self.disconnect(id_evento, conn)

ws_manager = ChatConnectionManager()


# ==============================================================================
# MODELOS DE DATOS
# ==============================================================================
class MensajeNuevoPayload(BaseModel):
    id_empleado: Optional[str] = ""
    autor_nombre: str
    autor_rol: Optional[str] = "PRODUCCION"
    mensaje: str
    tipo_mensaje: Optional[str] = "TEXTO"
    es_fijado: Optional[bool] = False

class CerrarChatPayload(BaseModel):
    productor_nombre: str
    id_empleado: Optional[str] = ""


# ==============================================================================
# UTILIDADES DE AUTORIZACIÓN Y FILTRADO
# ==============================================================================
def obtener_ahora_local() -> datetime.datetime:
    """Devuelve la fecha y hora actual en la zona horaria operativa de VPRO (UTC-7 / Sinaloa)."""
    return datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None) - datetime.timedelta(hours=7)

def normalizar_texto(t: str) -> str:
    import unicodedata
    if not t:
        return ""
    nfkd = unicodedata.normalize('NFKD', str(t))
    sin_tildes = "".join([c for c in nfkd if not unicodedata.combining(c)])
    return re.sub(r'[^a-zA-Z0-9]', '', sin_tildes).upper()

def es_usuario_privilegiado(nombre: str, rol: str) -> bool:
    norm_nom = normalizar_texto(nombre)
    norm_rol = normalizar_texto(rol)
    # Regla estricta: Solo a los Villarreal, Agundez y Coordinador
    if any(k in norm_nom for k in ["VILLARREAL", "VILLAREAL", "AGUNDEZ"]):
        return True
    if "COORD" in norm_rol:
        return True
    return False

def usuario_pertenece_a_op(usuario_nom: str, resp_prod: str, resp_gastos: str, chofer: str, convocados: List[str]) -> bool:
    if not usuario_nom or not usuario_nom.strip():
        return False
    norm_user = normalizar_texto(usuario_nom)
    if not norm_user:
        return False
    
    # Comprobar si coincide con alguno de los responsables
    for resp in [resp_prod, resp_gastos, chofer]:
        if resp and (norm_user in normalizar_texto(resp) or normalizar_texto(resp) in norm_user):
            return True
            
    # Comprobar en lista de convocados
    for conv in convocados:
        norm_conv = normalizar_texto(conv)
        if norm_user in norm_conv or norm_conv in norm_user:
            return True
            
    # Comparar por palabras clave de nombre/apellido (mínimo 2 tokens)
    palabras_user = [w for w in re.split(r'\s+', usuario_nom.upper()) if len(w) >= 3]
    for conv in convocados:
        conv_u = conv.upper()
        coincidencias = sum(1 for w in palabras_user if w in conv_u)
        if coincidencias >= 2:
            return True

    return False


# ==============================================================================
# ENDPOINTS REST
# ==============================================================================

@router.get("/ops")
def listar_ops_para_chat(
    usuario_nombre: Optional[str] = None,
    id_empleado: Optional[str] = None,
    rol: Optional[str] = None,
    ver_todas: Optional[bool] = False
):
    """
    Lista las Órdenes de Producción activas para el chat.
    Filtra automáticamente mostrando solo las OPs donde el usuario está convocado,
    a menos que sea perfil directivo/coordinador/admin.
    """
    try:
        query_sql = text("""
            SELECT 
                e.id_evento,
                e.folio,
                encode(e.nombre_evento::bytea, 'hex') AS nombre_evento_hex,
                encode(e.subtitulo_evento::bytea, 'hex') AS subtitulo_evento_hex,
                encode(e.locacion::bytea, 'hex') AS locacion_hex,
                e.fec_del_evento,
                e.fec_fin_evento,
                e.inicio_del_evento,
                e.hra_de_llamado,
                encode(e.resp_de_produccion::bytea, 'hex') AS resp_prod_hex,
                encode(e.responsable_gastos::bytea, 'hex') AS resp_gastos_hex,
                encode(e.chofer::bytea, 'hex') AS chofer_hex,
                e.personal_convocado_op,
                e.estatus,
                COALESCE(e.chat_cerrado, FALSE) AS chat_cerrado,
                encode(COALESCE(e.chat_cerrado_por, '')::bytea, 'hex') AS chat_cerrado_por_hex,
                to_char(e.chat_fecha_cierre, 'YYYY-MM-DD HH24:MI:SS') AS chat_fecha_cierre_str,
                (SELECT COUNT(*) FROM public.chat_op_mensajes m WHERE m.id_evento = e.id_evento) AS total_mensajes,
                (SELECT MAX(m.id) FROM public.chat_op_mensajes m WHERE m.id_evento = e.id_evento) AS ultimo_id_mensaje,
                (SELECT COUNT(*) FROM public.chat_op_mensajes m WHERE m.id_evento = e.id_evento AND m.es_fijado = TRUE) AS fijados_count,
                (SELECT encode(m.mensaje::bytea, 'hex') FROM public.chat_op_mensajes m WHERE m.id_evento = e.id_evento ORDER BY m.id DESC LIMIT 1) AS ultimo_mensaje_hex,
                (SELECT m.autor_nombre FROM public.chat_op_mensajes m WHERE m.id_evento = e.id_evento ORDER BY m.id DESC LIMIT 1) AS ultimo_autor,
                (SELECT to_char(m.fecha_hora, 'YYYY-MM-DD HH24:MI:SS') FROM public.chat_op_mensajes m WHERE m.id_evento = e.id_evento ORDER BY m.id DESC LIMIT 1) AS ultima_hora
            FROM public.eventos e
            WHERE (e.estatus IS NULL OR UPPER(e.estatus) NOT IN ('CANCELADO', 'ARCHIVADO', 'CERRADO'))
            ORDER BY COALESCE(
                (SELECT m.fecha_hora FROM public.chat_op_mensajes m WHERE m.id_evento = e.id_evento ORDER BY m.id DESC LIMIT 1),
                (e.fec_del_evento::timestamp + COALESCE(e.inicio_del_evento, '00:00:00'::time)::time)
            ) DESC
        """)

        with engine_eventos.connect() as conn:
            rows = conn.execute(query_sql).fetchall()

        es_privilegiado = False
        if usuario_nombre and rol:
            es_privilegiado = es_usuario_privilegiado(usuario_nombre, rol)

        resultado = []
        for r in rows:
            nombre_ev = reparar_mojibake(safe_decode_hex(r.nombre_evento_hex))
            subtitulo = reparar_mojibake(safe_decode_hex(r.subtitulo_evento_hex))
            locacion = reparar_mojibake(safe_decode_hex(r.locacion_hex))
            resp_prod = reparar_mojibake(safe_decode_hex(r.resp_prod_hex))
            resp_gastos = reparar_mojibake(safe_decode_hex(r.resp_gastos_hex))
            chofer = reparar_mojibake(safe_decode_hex(r.chofer_hex))
            convocados = [reparar_mojibake(p) for p in parse_pg_array(r.personal_convocado_op) if reparar_mojibake(p).strip()]
            
            ultimo_msj = reparar_mojibake(safe_decode_hex(r.ultimo_mensaje_hex)) if r.ultimo_mensaje_hex else None

            # Validación de pertenencia a la OP:
            # Por defecto (ver_todas=False), TODO usuario (incluso Admin) SOLO ve las OPs donde está convocado o asignado
            if usuario_nombre and (not ver_todas or not es_privilegiado):
                pertenece = usuario_pertenece_a_op(usuario_nombre, resp_prod, resp_gastos, chofer, convocados)
                if not pertenece:
                    continue

            resultado.append({
                "id_evento": r.id_evento,
                "folio": r.folio or str(r.id_evento),
                "nombre_evento": nombre_ev,
                "subtitulo_evento": subtitulo,
                "locacion": locacion,
                "fec_del_evento": str(r.fec_del_evento) if r.fec_del_evento else "",
                "fec_fin_evento": str(r.fec_fin_evento) if r.fec_fin_evento else "",
                "inicio_del_evento": str(r.inicio_del_evento) if r.inicio_del_evento else "",
                "hra_de_llamado": str(r.hra_de_llamado) if r.hra_de_llamado else "",
                "resp_de_produccion": resp_prod,
                "responsable_gastos": resp_gastos,
                "chofer": chofer,
                "personal_convocado_op": convocados,
                "total_mensajes": r.total_mensajes or 0,
                "ultimo_id_mensaje": r.ultimo_id_mensaje or 0,
                "fijados_count": r.fijados_count or 0,
                "ultimo_mensaje": ultimo_msj,
                "ultimo_autor": r.ultimo_autor,
                "ultima_hora": r.ultima_hora,
                "chat_cerrado": bool(r.chat_cerrado),
                "chat_cerrado_por": reparar_mojibake(safe_decode_hex(r.chat_cerrado_por_hex)) if r.chat_cerrado_por_hex else "",
                "chat_fecha_cierre": r.chat_fecha_cierre_str or ""
            })

        return {"status": "success", "total": len(resultado), "ops": resultado}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al listar OPs para chat: {str(e)}")


@router.get("/mensajes/{id_evento}")
def obtener_mensajes_op(id_evento: int):
    """
    Obtiene el historial cronológico completo de mensajes y notas de una OP específica,
    junto con los datos del evento para la cabecera del chat.
    """
    try:
        # 1. Cabecera de la OP
        query_op = text("""
            SELECT 
                id_evento, folio,
                encode(nombre_evento::bytea, 'hex') AS nombre_evento_hex,
                encode(subtitulo_evento::bytea, 'hex') AS subtitulo_evento_hex,
                encode(locacion::bytea, 'hex') AS locacion_hex,
                fec_del_evento, inicio_del_evento, hra_de_llamado,
                encode(resp_de_produccion::bytea, 'hex') AS resp_prod_hex,
                encode(responsable_gastos::bytea, 'hex') AS resp_gastos_hex,
                encode(chofer::bytea, 'hex') AS chofer_hex,
                personal_convocado_op,
                COALESCE(chat_cerrado, FALSE) AS chat_cerrado,
                encode(COALESCE(chat_cerrado_por, '')::bytea, 'hex') AS chat_cerrado_por_hex,
                to_char(chat_fecha_cierre, 'YYYY-MM-DD HH24:MI:SS') AS chat_fecha_cierre_str
            FROM public.eventos
            WHERE id_evento = :id_ev
        """)

        # 2. Mensajes del chat
        query_msjs = text("""
            SELECT 
                id, id_evento, folio, id_empleado,
                encode(autor_nombre::bytea, 'hex') AS autor_nombre_hex,
                autor_rol,
                encode(mensaje::bytea, 'hex') AS mensaje_hex,
                tipo_mensaje, archivo_url,
                to_char(fecha_hora, 'YYYY-MM-DD HH24:MI:SS') AS fecha_hora_str,
                es_fijado, reacciones
            FROM public.chat_op_mensajes
            WHERE id_evento = :id_ev
            ORDER BY fecha_hora ASC, id ASC
        """)

        with engine_eventos.connect() as conn:
            op_row = conn.execute(query_op, {"id_ev": id_evento}).fetchone()
            if not op_row:
                raise HTTPException(status_code=404, detail="Orden de Producción no encontrada")
            msj_rows = conn.execute(query_msjs, {"id_ev": id_evento}).fetchall()

        # Construir cabecera
        convocados = [reparar_mojibake(p) for p in parse_pg_array(op_row.personal_convocado_op) if reparar_mojibake(p).strip()]
        op_info = {
            "id_evento": op_row.id_evento,
            "folio": op_row.folio or str(op_row.id_evento),
            "nombre_evento": reparar_mojibake(safe_decode_hex(op_row.nombre_evento_hex)),
            "subtitulo_evento": reparar_mojibake(safe_decode_hex(op_row.subtitulo_evento_hex)),
            "locacion": reparar_mojibake(safe_decode_hex(op_row.locacion_hex)),
            "fec_del_evento": str(op_row.fec_del_evento) if op_row.fec_del_evento else "",
            "inicio_del_evento": str(op_row.inicio_del_evento) if op_row.inicio_del_evento else "",
            "hra_de_llamado": str(op_row.hra_de_llamado) if op_row.hra_de_llamado else "",
            "resp_de_produccion": reparar_mojibake(safe_decode_hex(op_row.resp_prod_hex)),
            "responsable_gastos": reparar_mojibake(safe_decode_hex(op_row.resp_gastos_hex)),
            "chofer": reparar_mojibake(safe_decode_hex(op_row.chofer_hex)),
            "personal_convocado_op": convocados,
            "chat_cerrado": bool(op_row.chat_cerrado),
            "chat_cerrado_por": reparar_mojibake(safe_decode_hex(op_row.chat_cerrado_por_hex)) if op_row.chat_cerrado_por_hex else "",
            "chat_fecha_cierre": op_row.chat_fecha_cierre_str or ""
        }

        # Construir lista de mensajes
        mensajes = []
        for m in msj_rows:
            mensajes.append({
                "id": m.id,
                "id_evento": m.id_evento,
                "folio": m.folio,
                "id_empleado": m.id_empleado or "",
                "autor_nombre": reparar_mojibake(safe_decode_hex(m.autor_nombre_hex)),
                "autor_rol": m.autor_rol or "STAFF",
                "mensaje": reparar_mojibake(safe_decode_hex(m.mensaje_hex)),
                "tipo_mensaje": m.tipo_mensaje or "TEXTO",
                "archivo_url": m.archivo_url,
                "fecha_hora": m.fecha_hora_str,
                "es_fijado": bool(m.es_fijado),
                "reacciones": m.reacciones or {}
            })

        return {
            "status": "success",
            "op": op_info,
            "total_mensajes": len(mensajes),
            "mensajes": mensajes
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener mensajes: {str(e)}")


@router.post("/mensajes/{id_evento}")
async def enviar_mensaje_op(id_evento: int, payload: MensajeNuevoPayload):
    """
    Registra un nuevo mensaje en el chat de la OP y notifica en tiempo real por WebSockets.
    """
    texto_limpio = (payload.mensaje or "").strip()
    if not texto_limpio:
        raise HTTPException(status_code=400, detail="El mensaje no puede estar vacío")

    try:
        # Verificar si el chat ya está cerrado
        with engine_eventos.connect() as conn:
            chk_cerrado = conn.execute(
                text("SELECT COALESCE(chat_cerrado, FALSE) AS cerrado FROM public.eventos WHERE id_evento = :id_ev"),
                {"id_ev": id_evento}
            ).fetchone()
            if chk_cerrado and chk_cerrado.cerrado:
                raise HTTPException(status_code=400, detail="Este chat operativo ha sido cerrado y sellado por el Productor.")

        # Detectar enlaces en el mensaje automáticamente
        tipo = payload.tipo_mensaje or "TEXTO"
        if tipo == "TEXTO" and ("http://" in texto_limpio.lower() or "https://" in texto_limpio.lower()):
            tipo = "LINK"

        query_insert = text("""
            INSERT INTO public.chat_op_mensajes (
                id_evento, folio, id_empleado, autor_nombre, autor_rol, mensaje, tipo_mensaje, es_fijado, fecha_hora
            ) VALUES (
                :id_ev, 
                (SELECT COALESCE(folio, CAST(:id_ev AS VARCHAR)) FROM public.eventos WHERE id_evento = :id_ev),
                :id_emp, :autor_nom, :autor_rol, :msj, :tipo, :fijado, :fec_hora
            )
            RETURNING id, id_evento, folio, id_empleado, autor_nombre, autor_rol, mensaje, tipo_mensaje, archivo_url, 
                      to_char(fecha_hora, 'YYYY-MM-DD HH24:MI:SS') AS fecha_hora_str, es_fijado, reacciones;
        """)

        with engine_eventos.begin() as conn:
            row = conn.execute(query_insert, {
                "id_ev": id_evento,
                "id_emp": payload.id_empleado or "",
                "autor_nom": payload.autor_nombre,
                "autor_rol": payload.autor_rol or "STAFF",
                "msj": texto_limpio,
                "tipo": tipo,
                "fijado": payload.es_fijado or False,
                "fec_hora": obtener_ahora_local()
            }).fetchone()

        mensaje_dict = {
            "id": row.id,
            "id_evento": row.id_evento,
            "folio": row.folio,
            "id_empleado": row.id_empleado,
            "autor_nombre": row.autor_nombre,
            "autor_rol": row.autor_rol,
            "mensaje": row.mensaje,
            "tipo_mensaje": row.tipo_mensaje,
            "archivo_url": row.archivo_url,
            "fecha_hora": row.fecha_hora_str,
            "es_fijado": row.es_fijado,
            "reacciones": row.reacciones or {}
        }

        # Notificar por WebSocket a todos los que tengan abierta la conversación
        await ws_manager.broadcast_to_op(id_evento, {
            "tipo": "NUEVO_MENSAJE",
            "mensaje": mensaje_dict
        })

        return {"status": "success", "mensaje": mensaje_dict}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al enviar mensaje: {str(e)}")


@router.post("/subir-adjunto/{id_evento}")
async def subir_adjunto_chat_op(
    id_evento: int,
    archivo: UploadFile = File(...),
    autor_nombre: str = Form(...),
    id_empleado: str = Form(""),
    autor_rol: str = Form("PRODUCCION"),
    comentario: str = Form("")
):
    """
    Sube una fotografía o archivo tomada desde el celular o PC y la registra de inmediato en el chat.
    """
    try:
        with engine_eventos.connect() as conn:
            chk_cerrado = conn.execute(
                text("SELECT COALESCE(chat_cerrado, FALSE) AS cerrado FROM public.eventos WHERE id_evento = :id_ev"),
                {"id_ev": id_evento}
            ).fetchone()
            if chk_cerrado and chk_cerrado.cerrado:
                raise HTTPException(status_code=400, detail="Este chat operativo ha sido cerrado y sellado por el Productor.")

        # Generar nombre único seguro
        timestamp_str = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        ext = os.path.splitext(archivo.filename or "")[1].lower()
        if not ext:
            ext = ".jpg"
        
        nombre_limpio = re.sub(r'[^a-zA-Z0-9_\-]', '', os.path.splitext(archivo.filename or "foto")[0])
        nombre_guardado = f"op_{id_evento}_{timestamp_str}_{nombre_limpio[:20]}{ext}"
        ruta_destino = CHAT_DIR / nombre_guardado

        with open(ruta_destino, "wb") as buffer:
            shutil.copyfileobj(archivo.file, buffer)

        # Determinar tipo
        tipo_msg = "IMAGEN" if ext in [".jpg", ".jpeg", ".png", ".webp", ".gif"] else "ARCHIVO"
        url_archivo = f"/Fotos_de_eventos/chat_op/{nombre_guardado}"
        mensaje_texto = comentario.strip() if comentario.strip() else ("📷 Foto enviada" if tipo_msg == "IMAGEN" else f"📎 Archivo: {archivo.filename}")

        query_insert = text("""
            INSERT INTO public.chat_op_mensajes (
                id_evento, folio, id_empleado, autor_nombre, autor_rol, mensaje, tipo_mensaje, archivo_url, fecha_hora
            ) VALUES (
                :id_ev, 
                (SELECT COALESCE(folio, CAST(:id_ev AS VARCHAR)) FROM public.eventos WHERE id_evento = :id_ev),
                :id_emp, :autor_nom, :autor_rol, :msj, :tipo, :url, :fec_hora
            )
            RETURNING id, id_evento, folio, id_empleado, autor_nombre, autor_rol, mensaje, tipo_mensaje, archivo_url, 
                      to_char(fecha_hora, 'YYYY-MM-DD HH24:MI:SS') AS fecha_hora_str, es_fijado, reacciones;
        """)

        with engine_eventos.begin() as conn:
            row = conn.execute(query_insert, {
                "id_ev": id_evento,
                "id_emp": id_empleado,
                "autor_nom": autor_nombre,
                "autor_rol": autor_rol,
                "msj": mensaje_texto,
                "tipo": tipo_msg,
                "url": url_archivo,
                "fec_hora": obtener_ahora_local()
            }).fetchone()

        mensaje_dict = {
            "id": row.id,
            "id_evento": row.id_evento,
            "folio": row.folio,
            "id_empleado": row.id_empleado,
            "autor_nombre": row.autor_nombre,
            "autor_rol": row.autor_rol,
            "mensaje": row.mensaje,
            "tipo_mensaje": row.tipo_mensaje,
            "archivo_url": row.archivo_url,
            "fecha_hora": row.fecha_hora_str,
            "es_fijado": row.es_fijado,
            "reacciones": row.reacciones or {}
        }

        # Transmisión WebSocket
        await ws_manager.broadcast_to_op(id_evento, {
            "tipo": "NUEVO_MENSAJE",
            "mensaje": mensaje_dict
        })

        return {"status": "success", "mensaje": mensaje_dict}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al subir archivo al chat: {str(e)}")


@router.post("/toggle-fijar/{id_mensaje}")
async def alternar_mensaje_fijado(id_mensaje: int):
    """
    Fija o desfija un mensaje importante (ej. horarios, vMix call, requerimientos del chofer).
    """
    try:
        query_toggle = text("""
            UPDATE public.chat_op_mensajes
            SET es_fijado = NOT COALESCE(es_fijado, FALSE)
            WHERE id = :id_msj
            RETURNING id, id_evento, es_fijado;
        """)

        with engine_eventos.begin() as conn:
            row = conn.execute(query_toggle, {"id_msj": id_mensaje}).fetchone()
            if not row:
                raise HTTPException(status_code=404, detail="Mensaje no encontrado")

        await ws_manager.broadcast_to_op(row.id_evento, {
            "tipo": "MENSAJE_FIJADO_CAMBIO",
            "id_mensaje": row.id,
            "es_fijado": row.es_fijado
        })

        return {"status": "success", "id_mensaje": row.id, "es_fijado": row.es_fijado}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al fijar mensaje: {str(e)}")


@router.post("/reaccion/{id_mensaje}")
async def toggle_reaccion_mensaje(
    id_mensaje: int,
    emoji: str = Form("👍"),
    usuario_nombre: str = Form(...)
):
    """
    Agrega o retira una reacción a un mensaje estilo WhatsApp.
    """
    try:
        query_sel = text("SELECT id, id_evento, reacciones FROM public.chat_op_mensajes WHERE id = :id_msj")
        with engine_eventos.begin() as conn:
            row = conn.execute(query_sel, {"id_msj": id_mensaje}).fetchone()
            if not row:
                raise HTTPException(status_code=404, detail="Mensaje no encontrado")
            
            reacciones = dict(row.reacciones or {})
            lista_usuarios = reacciones.get(emoji, [])
            if usuario_nombre in lista_usuarios:
                lista_usuarios.remove(usuario_nombre)
                if not lista_usuarios:
                    reacciones.pop(emoji, None)
                else:
                    reacciones[emoji] = lista_usuarios
            else:
                lista_usuarios.append(usuario_nombre)
                reacciones[emoji] = lista_usuarios

            conn.execute(
                text("UPDATE public.chat_op_mensajes SET reacciones = CAST(:reacc AS jsonb) WHERE id = :id_msj"),
                {"reacc": json.dumps(reacciones), "id_msj": id_mensaje}
            )

        await ws_manager.broadcast_to_op(row.id_evento, {
            "tipo": "REACCION_CAMBIO",
            "id_mensaje": row.id,
            "reacciones": reacciones
        })

        return {"status": "success", "reacciones": reacciones}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al reaccionar: {str(e)}")


# ==============================================================================
# CIERRE Y SELLADO OFICIAL DE CHAT OPERATIVO
# ==============================================================================
@router.post("/cerrar-chat/{id_evento}")
async def cerrar_chat_op(id_evento: int, payload: CerrarChatPayload):
    """
    Cierra oficialmente la sala de chat de la OP, compila todos los mensajes y notas,
    y los sella en el expediente histórico (chat_historial) de la OP.
    Exclusivo para el Productor asignado a la OP o Dirección.
    """
    try:
        # 1. Obtener datos de la OP
        query_op = text("""
            SELECT id_evento, folio,
                   encode(nombre_evento::bytea, 'hex') AS nombre_evento_hex,
                   encode(locacion::bytea, 'hex') AS locacion_hex,
                   encode(resp_de_produccion::bytea, 'hex') AS resp_prod_hex,
                   fec_del_evento, hra_de_llamado,
                   COALESCE(chat_cerrado, FALSE) AS chat_cerrado
            FROM public.eventos
            WHERE id_evento = :id_ev
        """)
        
        with engine_eventos.connect() as conn:
            op_row = conn.execute(query_op, {"id_ev": id_evento}).fetchone()
            if not op_row:
                raise HTTPException(status_code=404, detail="Orden de Producción no encontrada")
                
        folio = op_row.folio or str(op_row.id_evento)
        nombre_evento = reparar_mojibake(safe_decode_hex(op_row.nombre_evento_hex))
        locacion = reparar_mojibake(safe_decode_hex(op_row.locacion_hex))
        resp_prod = reparar_mojibake(safe_decode_hex(op_row.resp_prod_hex))
        
        # Validar si el usuario que intenta cerrar es el productor asignado o dirección
        user_nom = (payload.productor_nombre or "").strip()
        norm_user = normalizar_texto(user_nom)
        norm_prod = normalizar_texto(resp_prod)
        
        es_prod = bool(norm_user and norm_prod and (norm_user in norm_prod or norm_prod in norm_user))
        if not es_prod:
            tokens_u = [w for w in norm_user.split() if len(w) >= 3]
            tokens_p = [w for w in norm_prod.split() if len(w) >= 3]
            es_prod = sum(1 for w in tokens_u if w in tokens_p) >= 2
        
        if not es_prod:
            raise HTTPException(
                status_code=403, 
                detail=f"Acceso denegado: Solo el Productor Responsable ({resp_prod}) asignado en la OP puede cerrar y sellar este chat."
            )

        # 2. Obtener todos los mensajes en orden cronológico
        query_msjs = text("""
            SELECT 
                id,
                encode(autor_nombre::bytea, 'hex') AS autor_nombre_hex,
                autor_rol,
                encode(mensaje::bytea, 'hex') AS mensaje_hex,
                tipo_mensaje, archivo_url,
                to_char(fecha_hora, 'YYYY-MM-DD HH24:MI:SS') AS fecha_hora_str
            FROM public.chat_op_mensajes
            WHERE id_evento = :id_ev
            ORDER BY fecha_hora ASC, id ASC
        """)
        
        with engine_eventos.connect() as conn:
            msjs = conn.execute(query_msjs, {"id_ev": id_evento}).fetchall()

        ahora_dt = obtener_ahora_local()
        ahora_str = ahora_dt.strftime("%Y-%m-%d %H:%M:%S")

        # 3. Compilar el historial oficial sellado
        lineas_bitacora = [
            "=" * 80,
            f"BITÁCORA OFICIAL DE CHAT OPERATIVO - VPRO WORKSPACE",
            f"ORDEN DE PRODUCCIÓN: OP-{folio} | EVENTO: {nombre_evento}",
            f"LOCACIÓN: {locacion}",
            f"FECHA DEL EVENTO: {op_row.fec_del_evento or 'N/A'} | HORA LLAMADO: {op_row.hra_de_llamado or 'N/A'}",
            f"PRODUCTOR RESPONSABLE: {resp_prod}",
            "-" * 80,
            f"ESTADO: CERRADO Y SELLADO",
            f"SELLADO POR PRODUCTOR: {user_nom}",
            f"FECHA Y HORA DE CIERRE: {ahora_str}",
            f"TOTAL REGISTROS INTEGRADOS: {len(msjs)} MENSAJES Y EVIDENCIAS",
            "=" * 80,
            ""
        ]

        if not msjs:
            lineas_bitacora.append("[Sin mensajes registrados durante la cobertura]")
        else:
            for m in msjs:
                m_autor = reparar_mojibake(safe_decode_hex(m.autor_nombre_hex))
                m_msj = reparar_mojibake(safe_decode_hex(m.mensaje_hex))
                m_rol = m.autor_rol or "STAFF"
                m_hora = m.fecha_hora_str or ""
                m_adjunto = f" | [Adjunto: {m.archivo_url}]" if m.archivo_url else ""
                
                lineas_bitacora.append(f"[{m_hora}] [{m_rol}] {m_autor}:{m_adjunto}")
                lineas_bitacora.append(f"  {m_msj}")
                lineas_bitacora.append("")

        lineas_bitacora.extend([
            "-" * 80,
            "FIN DE LA BITÁCORA - EXPEDIENTE SELLADO PARA AUDITORÍA Y ACLARACIONES",
            "=" * 80
        ])

        bitacora_completa = "\n".join(lineas_bitacora)

        # 4. Actualizar tabla public.eventos
        update_op = text("""
            UPDATE public.eventos
            SET chat_historial = :historial,
                chat_cerrado = TRUE,
                chat_cerrado_por = :cerrador,
                chat_fecha_cierre = :fec_cierre
            WHERE id_evento = :id_ev
            RETURNING folio, to_char(chat_fecha_cierre, 'YYYY-MM-DD HH24:MI:SS') AS fecha_cierre_str;
        """)

        with engine_eventos.begin() as conn:
            up_row = conn.execute(update_op, {
                "id_ev": id_evento,
                "historial": bitacora_completa,
                "cerrador": user_nom,
                "fec_cierre": ahora_dt
            }).fetchone()

            # Insertar mensaje de sistema en el chat
            conn.execute(text("""
                INSERT INTO public.chat_op_mensajes (
                    id_evento, folio, id_empleado, autor_nombre, autor_rol, mensaje, tipo_mensaje, fecha_hora
                ) VALUES (
                    :id_ev, :folio, :id_emp, 'SISTEMA VPRO', 'AUDITORÍA',
                    :msj_sistema, 'SISTEMA', :fec_cierre
                )
            """), {
                "id_ev": id_evento,
                "folio": folio,
                "id_emp": payload.id_empleado or "",
                "msj_sistema": f"🔒 El chat operativo de esta OP ha sido cerrado y sellado oficialmente por el Productor {user_nom}. La bitácora ha sido integrada al expediente histórico.",
                "fec_cierre": ahora_dt
            })

        fecha_cierre_final = up_row.fecha_cierre_str if up_row else ahora_str

        # 5. Notificar a todas las conexiones WebSocket activas
        await ws_manager.broadcast_to_op(id_evento, {
            "tipo": "CHAT_CERRADO",
            "id_evento": id_evento,
            "folio": folio,
            "cerrado_por": user_nom,
            "fecha_cierre": fecha_cierre_final
        })

        return {
            "ok": True,
            "status": "success",
            "mensaje": f"Chat de la OP-{folio} cerrado y sellado con éxito.",
            "folio": folio,
            "chat_cerrado": True,
            "chat_cerrado_por": user_nom,
            "chat_fecha_cierre": fecha_cierre_final
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al cerrar chat: {str(e)}")


# ==============================================================================
# MOTOR EMISOR DE ALERTAS AUTOMÁTICAS DEL SISTEMA VPRO
# ==============================================================================
def publicar_alerta_sistema(id_evento: int, folio: str, texto_mensaje: str):
    """
    Publica un mensaje automático de sistema/alerta en el canal de chat de la OP
    y lo retransmite en tiempo real a todos los sockets conectados.
    """
    try:
        ahora_dt = obtener_ahora_local()
        query_insert = text("""
            INSERT INTO public.chat_op_mensajes (
                id_evento, folio, id_empleado, autor_nombre, autor_rol, mensaje, tipo_mensaje, fecha_hora
            ) VALUES (
                :id_ev, :folio, 'BOT', '🤖 SISTEMA VPRO', 'ALERTA OPERATIVA', :msj, 'SISTEMA', :fec_hora
            )
            RETURNING id, id_evento, folio, id_empleado, autor_nombre, autor_rol, mensaje, tipo_mensaje, archivo_url, 
                      to_char(fecha_hora, 'YYYY-MM-DD HH24:MI:SS') AS fecha_hora_str, es_fijado, reacciones;
        """)

        with engine_eventos.begin() as conn:
            row = conn.execute(query_insert, {
                "id_ev": id_evento,
                "folio": str(folio),
                "msj": texto_mensaje.strip(),
                "fec_hora": ahora_dt
            }).fetchone()

        if row:
            mensaje_dict = {
                "id": row.id,
                "id_evento": row.id_evento,
                "folio": row.folio,
                "id_empleado": row.id_empleado,
                "autor_nombre": row.autor_nombre,
                "autor_rol": row.autor_rol,
                "mensaje": row.mensaje,
                "tipo_mensaje": row.tipo_mensaje,
                "archivo_url": row.archivo_url,
                "fecha_hora": row.fecha_hora_str,
                "es_fijado": row.es_fijado,
                "reacciones": row.reacciones or {}
            }
            # Difusión por WebSocket (segura para contextos síncronos o asíncronos)
            try:
                loop = asyncio.get_running_loop()
                loop.create_task(ws_manager.broadcast_to_op(id_evento, {
                    "tipo": "NUEVO_MENSAJE",
                    "mensaje": mensaje_dict
                }))
            except RuntimeError:
                pass
            return mensaje_dict
    except Exception as e:
        print(f"⚠️ Error al publicar alerta de sistema en chat OP-{id_evento}: {e}")
        return None

class AlertaSistemaPayload(BaseModel):
    mensaje: str
    folio: Optional[str] = ""

@router.post("/alerta-sistema/{id_evento}")
async def emitir_alerta_sistema_endpoint(id_evento: int, payload: AlertaSistemaPayload):
    """Permite disparar una alerta oficial de sistema hacia la sala de chat de la OP."""
    res = publicar_alerta_sistema(id_evento, payload.folio, payload.mensaje)
    if not res:
        raise HTTPException(status_code=500, detail="No se pudo publicar la alerta de sistema.")
    return {"status": "success", "alerta": res}


# ==============================================================================
# CANAL WEBSOCKET BIDIRECCIONAL
# ==============================================================================
@router.websocket("/ws/{id_evento}")
async def websocket_endpoint_chat_op(websocket: WebSocket, id_evento: int):
    """
    Socket permanente para recibir y enviar mensajes instantáneamente sin recargar pantalla.
    """
    await ws_manager.connect(id_evento, websocket)
    try:
        while True:
            # Espera mensajes o pings
            data = await websocket.receive_text()
            if data == "ping":
                await websocket.send_text("pong")
    except WebSocketDisconnect:
        ws_manager.disconnect(id_evento, websocket)
    except Exception:
        ws_manager.disconnect(id_evento, websocket)
