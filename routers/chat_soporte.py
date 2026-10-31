import datetime
import os
import shutil
import time
import json
from pathlib import Path
from typing import Dict, Any, List, Optional
from fastapi import APIRouter, HTTPException, UploadFile, File, Form, WebSocket, WebSocketDisconnect
from sqlalchemy import text
from pydantic import BaseModel

from core.database import engine_personal
from core.utils import safe_decode_hex, reparar_mojibake
from core.config import FOTOS_EVENTOS_DIR

router = APIRouter(prefix="/api/chat-soporte", tags=["💻 Chat de Soporte TI, Sistemas & Consultas"])

# Directorio de almacenamiento para capturas y archivos de soporte
CHAT_SOPORTE_DIR = FOTOS_EVENTOS_DIR / "chat_soporte"
CHAT_SOPORTE_DIR.mkdir(parents=True, exist_ok=True)


def _asegurar_tabla_chat_soporte():
    """Crea la tabla e índices para la mesa de soporte si no existen."""
    try:
        with engine_personal.begin() as conn:
            conn.execute(text("""
                CREATE TABLE IF NOT EXISTS public.chat_soporte_mensajes (
                    id SERIAL PRIMARY KEY,
                    id_empleado VARCHAR(50) NOT NULL,
                    autor_nombre VARCHAR(255) NOT NULL,
                    autor_rol VARCHAR(100),
                    mensaje TEXT NOT NULL,
                    tipo_mensaje VARCHAR(50) DEFAULT 'TEXTO',
                    archivo_url TEXT,
                    es_fijado BOOLEAN DEFAULT FALSE,
                    reacciones JSONB DEFAULT '{}'::jsonb,
                    metadata_extra JSONB DEFAULT '{}'::jsonb,
                    fecha_hora TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
                );
                CREATE INDEX IF NOT EXISTS idx_chat_soporte_fec 
                    ON public.chat_soporte_mensajes(fecha_hora ASC);
                CREATE INDEX IF NOT EXISTS idx_chat_soporte_fijado 
                    ON public.chat_soporte_mensajes(es_fijado);
            """))
    except Exception as e:
        print(f"[WARN] Error al verificar tabla chat_soporte: {e}")

_asegurar_tabla_chat_soporte()


# ==============================================================================
# GESTOR DE CONEXIONES EN TIEMPO REAL (WEBSOCKETS)
# ==============================================================================
class SoporteChatConnectionManager:
    def __init__(self):
        # Lista de WebSockets activos en la sala general de soporte
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        if websocket not in self.active_connections:
            self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)

    async def broadcast(self, data: dict):
        conexiones = list(self.active_connections)
        for conn in conexiones:
            try:
                await conn.send_json(data)
            except Exception:
                self.disconnect(conn)

ws_soporte_manager = SoporteChatConnectionManager()


# ==============================================================================
# MODELOS DE DATOS
# ==============================================================================
class MensajeSoporteCreate(BaseModel):
    id_empleado: str
    autor_nombre: str
    autor_rol: Optional[str] = "COLABORADOR"
    mensaje: str
    tipo_mensaje: Optional[str] = "TEXTO"
    archivo_url: Optional[str] = None
    es_fijado: Optional[bool] = False
    metadata_extra: Optional[Dict[str, Any]] = None

class ReaccionSoportePayload(BaseModel):
    emoji: str
    usuario_id: str
    usuario_nombre: str


def obtener_ahora_local() -> datetime.datetime:
    """Hora local de operación Sinaloa/Noroeste (UTC-7)."""
    return datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None) - datetime.timedelta(hours=7)


# ==============================================================================
# ENDPOINTS REST
# ==============================================================================

@router.get("/info")
def obtener_info_soporte():
    """
    Retorna métricas y datos rápidos de la mesa de ayuda de soporte.
    """
    try:
        with engine_personal.connect() as conn:
            row = conn.execute(text("""
                SELECT 
                    COUNT(*) AS total_mensajes,
                    COUNT(*) FILTER (WHERE fecha_hora >= CURRENT_DATE) AS hoy_mensajes,
                    (SELECT mensaje FROM public.chat_soporte_mensajes WHERE es_fijado = TRUE ORDER BY id DESC LIMIT 1) AS aviso_fijado,
                    (SELECT autor_nombre FROM public.chat_soporte_mensajes WHERE es_fijado = TRUE ORDER BY id DESC LIMIT 1) AS aviso_fijado_autor,
                    (SELECT to_char(fecha_hora, 'YYYY-MM-DD HH24:MI') FROM public.chat_soporte_mensajes WHERE es_fijado = TRUE ORDER BY id DESC LIMIT 1) AS aviso_fijado_fecha
                FROM public.chat_soporte_mensajes
            """)).mappings().first()

            return {
                "nombre_canal": "Mesa de Ayuda TI & Consultas Generales",
                "descripcion": "Canal corporativo para dudas de red/internet, software, equipos, conectividad y avisos de sistemas.",
                "total_mensajes": row["total_mensajes"] or 0,
                "mensajes_hoy": row["hoy_mensajes"] or 0,
                "aviso_fijado": row["aviso_fijado"],
                "aviso_fijado_autor": row["aviso_fijado_autor"],
                "aviso_fijado_fecha": row["aviso_fijado_fecha"]
            }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/mensajes")
def obtener_mensajes_soporte(limit: int = 150):
    """
    Devuelve los últimos N mensajes de la sala de soporte ordenados cronológicamente.
    """
    try:
        with engine_personal.connect() as conn:
            sql = text("""
                SELECT 
                    m.id,
                    m.id_empleado,
                    encode(m.autor_nombre::bytea, 'hex') AS autor_nombre_hex,
                    m.autor_rol,
                    encode(m.mensaje::bytea, 'hex') AS mensaje_hex,
                    m.tipo_mensaje,
                    m.archivo_url,
                    m.es_fijado,
                    m.reacciones,
                    m.metadata_extra,
                    to_char(m.fecha_hora, 'YYYY-MM-DD HH24:MI:SS') AS fecha_hora_str,
                    e.foto_url
                FROM (
                    SELECT * FROM public.chat_soporte_mensajes
                    ORDER BY id DESC
                    LIMIT :lim
                ) m
                LEFT JOIN public.empleados e ON e.id_empleado = m.id_empleado
                ORDER BY m.id ASC
            """)
            rows = conn.execute(sql, {"lim": limit}).fetchall()

            resultado = []
            for r in rows:
                nom = reparar_mojibake(safe_decode_hex(r.autor_nombre_hex))
                msj = reparar_mojibake(safe_decode_hex(r.mensaje_hex))
                resultado.append({
                    "id": r.id,
                    "id_empleado": str(r.id_empleado),
                    "autor_nombre": nom,
                    "autor_rol": r.autor_rol or "COLABORADOR",
                    "mensaje": msj,
                    "tipo_mensaje": r.tipo_mensaje or "TEXTO",
                    "archivo_url": r.archivo_url,
                    "es_fijado": bool(r.es_fijado),
                    "reacciones": r.reacciones or {},
                    "metadata_extra": r.metadata_extra or {},
                    "fecha_hora_str": r.fecha_hora_str or "",
                    "foto_url": r.foto_url or f"/fotos/{r.id_empleado}.jpg"
                })

            return resultado
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/mensajes")
async def enviar_mensaje_soporte(payload: MensajeSoporteCreate):
    """
    Inserta un nuevo mensaje en la sala de soporte y notifica a todos por WebSockets.
    """
    texto_limpio = (payload.mensaje or "").strip()
    if not texto_limpio:
        raise HTTPException(status_code=400, detail="El mensaje no puede estar vacío.")

    try:
        tipo = payload.tipo_mensaje or "TEXTO"
        if tipo == "TEXTO" and ("http://" in texto_limpio.lower() or "https://" in texto_limpio.lower()):
            tipo = "LINK"

        meta_json = json.dumps(payload.metadata_extra or {})

        sql = text("""
            INSERT INTO public.chat_soporte_mensajes (
                id_empleado, autor_nombre, autor_rol, mensaje, tipo_mensaje,
                archivo_url, es_fijado, metadata_extra, fecha_hora
            ) VALUES (
                :id_emp, :nom, :rol, :msj, :tipo, :arch, :fij, CAST(:meta AS jsonb), :fec_hora
            )
            RETURNING id, to_char(fecha_hora, 'YYYY-MM-DD HH24:MI:SS') AS fecha_hora_str;
        """)

        fec_actual = obtener_ahora_local()

        with engine_personal.begin() as conn:
            res = conn.execute(sql, {
                "id_emp": str(payload.id_empleado),
                "nom": payload.autor_nombre,
                "rol": payload.autor_rol or "COLABORADOR",
                "msj": texto_limpio,
                "tipo": tipo,
                "arch": payload.archivo_url,
                "fij": bool(payload.es_fijado),
                "meta": meta_json,
                "fec_hora": fec_actual
            }).mappings().first()

            nuevo_id = res["id"]
            fecha_str = res["fecha_hora_str"]

            # Obtener foto del empleado si existe
            row_emp = conn.execute(
                text("SELECT foto_url FROM public.empleados WHERE id_empleado = :id_emp"),
                {"id_emp": str(payload.id_empleado)}
            ).mappings().first()
            foto_emp = row_emp["foto_url"] if row_emp and row_emp["foto_url"] else f"/fotos/{payload.id_empleado}.jpg"

        msg_obj = {
            "id": nuevo_id,
            "id_empleado": str(payload.id_empleado),
            "autor_nombre": payload.autor_nombre,
            "autor_rol": payload.autor_rol or "COLABORADOR",
            "mensaje": texto_limpio,
            "tipo_mensaje": tipo,
            "archivo_url": payload.archivo_url,
            "es_fijado": bool(payload.es_fijado),
            "reacciones": {},
            "metadata_extra": payload.metadata_extra or {},
            "fecha_hora_str": fecha_str,
            "foto_url": foto_emp
        }

        # Transmisión en tiempo real vía WebSocket
        await ws_soporte_manager.broadcast({
            "tipo": "NUEVO_MENSAJE_SOPORTE",
            "mensaje": msg_obj
        })

        return {"status": "success", "mensaje": msg_obj}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/subir-adjunto")
async def subir_adjunto_soporte(
    id_empleado: str = Form(...),
    archivo: UploadFile = File(...)
):
    """
    Almacena archivos o capturas enviadas al chat de soporte y devuelve la URL accesible.
    """
    try:
        ts = int(time.time() * 1000)
        ext = Path(archivo.filename).suffix.lower() or ".bin"
        nombre_limpio = f"soporte_{id_empleado}_{ts}{ext}"
        destino = CHAT_SOPORTE_DIR / nombre_limpio

        with open(destino, "wb") as buffer:
            shutil.copyfileobj(archivo.file, buffer)

        # La ruta estática se sirve a través del montaje de fotos de eventos / chat_soporte
        url_publica = f"/Fotos_de_eventos/chat_soporte/{nombre_limpio}"

        return {
            "status": "success",
            "archivo_url": url_publica,
            "nombre_original": archivo.filename
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al subir adjunto de soporte: {str(e)}")


@router.post("/mensajes/{mensaje_id}/reaccionar")
async def reaccionar_mensaje_soporte(mensaje_id: int, payload: ReaccionSoportePayload):
    """
    Agrega o retira una reacción emoji a un mensaje de soporte.
    """
    try:
        with engine_personal.begin() as conn:
            row = conn.execute(
                text("SELECT reacciones FROM public.chat_soporte_mensajes WHERE id = :mid"),
                {"mid": mensaje_id}
            ).fetchone()

            if not row:
                raise HTTPException(status_code=404, detail="Mensaje no encontrado")

            reacciones = row[0] or {}
            emoji = payload.emoji.strip()
            uid = str(payload.usuario_id).strip()

            if emoji not in reacciones:
                reacciones[emoji] = []

            if uid in reacciones[emoji]:
                reacciones[emoji].remove(uid)
                if not reacciones[emoji]:
                    del reacciones[emoji]
            else:
                reacciones[emoji].append(uid)

            conn.execute(
                text("UPDATE public.chat_soporte_mensajes SET reacciones = CAST(:r AS jsonb) WHERE id = :mid"),
                {"r": json.dumps(reacciones), "mid": mensaje_id}
            )

        # Notificar por WebSocket
        await ws_soporte_manager.broadcast({
            "tipo": "REACCION_SOPORTE",
            "mensaje_id": mensaje_id,
            "reacciones": reacciones
        })

        return {"status": "success", "reacciones": reacciones}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/mensajes/{mensaje_id}/fijar")
async def alternar_fijado_soporte(mensaje_id: int):
    """
    Alterna el estado fijado de un mensaje para mostrarlo en el banner de avisos de Sistemas.
    """
    try:
        with engine_personal.begin() as conn:
            row = conn.execute(
                text("SELECT es_fijado FROM public.chat_soporte_mensajes WHERE id = :mid"),
                {"mid": mensaje_id}
            ).fetchone()

            if not row:
                raise HTTPException(status_code=404, detail="Mensaje no encontrado")

            nuevo_estado = not bool(row[0])
            conn.execute(
                text("UPDATE public.chat_soporte_mensajes SET es_fijado = :st WHERE id = :mid"),
                {"st": nuevo_estado, "mid": mensaje_id}
            )

        await ws_soporte_manager.broadcast({
            "tipo": "FIJADO_SOPORTE_CAMBIO",
            "mensaje_id": mensaje_id,
            "es_fijado": nuevo_estado
        })

        return {"status": "success", "es_fijado": nuevo_estado}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==============================================================================
# WEBSOCKET EN TIEMPO REAL
# ==============================================================================
@router.websocket("/ws")
async def websocket_endpoint_soporte(websocket: WebSocket):
    await ws_soporte_manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_text()
            # Mantenimiento de conexión viva (heartbeat / ping-pong)
            try:
                parsed = json.loads(data)
                if parsed.get("tipo") == "PING":
                    await websocket.send_json({"tipo": "PONG"})
            except Exception:
                pass
    except WebSocketDisconnect:
        ws_soporte_manager.disconnect(websocket)
    except Exception:
        ws_soporte_manager.disconnect(websocket)
