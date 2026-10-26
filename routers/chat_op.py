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


# ==============================================================================
# UTILIDADES DE AUTORIZACIÓN Y FILTRADO
# ==============================================================================
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
    if any(k in norm_nom for k in ["VILLARREAL", "VILLAREAL", "AGUNDEZ"]):
        return True
    if any(k in norm_rol for k in ["ADMIN", "COORDINADOR", "DIRECCION", "GERENCIA", "SUPERVISOR"]):
        return True
    return False

def usuario_pertenece_a_op(usuario_nom: str, resp_prod: str, resp_gastos: str, chofer: str, convocados: List[str]) -> bool:
    if not usuario_nom:
        return True
    norm_user = normalizar_texto(usuario_nom)
    if not norm_user:
        return True
    
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
    rol: Optional[str] = None
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
                (SELECT COUNT(*) FROM public.chat_op_mensajes m WHERE m.id_evento = e.id_evento) AS total_mensajes,
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

            # Validación de pertenencia si no es administrador/directivo
            if usuario_nombre and not es_privilegiado:
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
                "fijados_count": r.fijados_count or 0,
                "ultimo_mensaje": ultimo_msj,
                "ultimo_autor": r.ultimo_autor,
                "ultima_hora": r.ultima_hora
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
                personal_convocado_op
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
            "personal_convocado_op": convocados
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
                :id_emp, :autor_nom, :autor_rol, :msj, :tipo, :fijado, CURRENT_TIMESTAMP
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
                "fijado": payload.es_fijado or False
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
                :id_emp, :autor_nom, :autor_rol, :msj, :tipo, :url, CURRENT_TIMESTAMP
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
                "url": url_archivo
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
