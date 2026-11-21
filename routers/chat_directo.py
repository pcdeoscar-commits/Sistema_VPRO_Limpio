import asyncio
from core.notificaciones_ws import despachar_notificacion_directo
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

router = APIRouter(prefix="/api/chat-directo", tags=["💬 Chat Directo 1 a 1 entre Colaboradores"])

# Directorio de almacenamiento para capturas y archivos de chats directos
CHAT_DIRECTO_DIR = FOTOS_EVENTOS_DIR / "chat_directo"
CHAT_DIRECTO_DIR.mkdir(parents=True, exist_ok=True)


def _asegurar_tabla_chat_directo():
    """Crea la tabla e índices para el chat directo 1 a 1 si no existen."""
    try:
        with engine_personal.begin() as conn:
            conn.execute(text("""
                CREATE TABLE IF NOT EXISTS public.chat_directo_mensajes (
                    id SERIAL PRIMARY KEY,
                    sala_id VARCHAR(120) NOT NULL,
                    remitente_id VARCHAR(50) NOT NULL,
                    destinatario_id VARCHAR(50) NOT NULL,
                    remitente_nombre VARCHAR(255) NOT NULL,
                    mensaje TEXT NOT NULL,
                    tipo_mensaje VARCHAR(50) DEFAULT 'TEXTO',
                    archivo_url TEXT,
                    reacciones JSONB DEFAULT '{}'::jsonb,
                    metadata_extra JSONB DEFAULT '{}'::jsonb,
                    fecha_hora TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                    leido BOOLEAN DEFAULT FALSE
                );

                CREATE INDEX IF NOT EXISTS idx_chat_dir_sala 
                    ON public.chat_directo_mensajes(sala_id, fecha_hora ASC);
                CREATE INDEX IF NOT EXISTS idx_chat_dir_dest_leido 
                    ON public.chat_directo_mensajes(destinatario_id, leido);
                CREATE INDEX IF NOT EXISTS idx_chat_dir_rem 
                    ON public.chat_directo_mensajes(remitente_id);
                CREATE INDEX IF NOT EXISTS idx_chat_dir_dest 
                    ON public.chat_directo_mensajes(destinatario_id);
            """))
    except Exception as e:
        print(f"[WARN] Error al verificar tabla chat_directo_mensajes: {e}")

_asegurar_tabla_chat_directo()


def generar_sala_id(id1: str, id2: str) -> str:
    """Genera un identificador simétrico e invariante para la sala 1 a 1."""
    a, b = str(id1).strip(), str(id2).strip()
    return f"{a}_{b}" if a < b else f"{b}_{a}"


def obtener_ahora_local() -> datetime.datetime:
    """Hora local de operación Sinaloa/Noroeste (UTC-7)."""
    return datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None) - datetime.timedelta(hours=7)


# ==============================================================================
# GESTOR DE CONEXIONES EN TIEMPO REAL (WEBSOCKETS DIRECTOS)
# ==============================================================================
class DirectoChatConnectionManager:
    def __init__(self):
        # usuario_id -> lista de WebSockets activos
        self.user_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, usuario_id: str, websocket: WebSocket):
        await websocket.accept()
        u_id = str(usuario_id).strip()
        if u_id not in self.user_connections:
            self.user_connections[u_id] = []
        self.user_connections[u_id].append(websocket)

    def disconnect(self, usuario_id: str, websocket: WebSocket):
        u_id = str(usuario_id).strip()
        if u_id in self.user_connections:
            if websocket in self.user_connections[u_id]:
                self.user_connections[u_id].remove(websocket)
            if not self.user_connections[u_id]:
                del self.user_connections[u_id]

    async def send_to_user(self, usuario_id: str, data: dict):
        u_id = str(usuario_id).strip()
        if u_id in self.user_connections:
            for conn in list(self.user_connections[u_id]):
                try:
                    await conn.send_json(data)
                except Exception:
                    self.disconnect(u_id, conn)

    async def broadcast_direct(self, remitente_id: str, destinatario_id: str, data: dict):
        # Enviar al destinatario
        await self.send_to_user(destinatario_id, data)
        # Enviar al remitente (para sincronizar múltiples pestañas o dispositivos)
        await self.send_to_user(remitente_id, data)

ws_directo_manager = DirectoChatConnectionManager()


# ==============================================================================
# MODELOS DE DATOS
# ==============================================================================
class MensajeDirectoCreate(BaseModel):
    remitente_id: str
    remitente_nombre: str
    mensaje: str
    tipo_mensaje: Optional[str] = "TEXTO"
    archivo_url: Optional[str] = None
    metadata_extra: Optional[Dict[str, Any]] = None

class ReaccionDirectoPayload(BaseModel):
    emoji: str
    usuario_id: str
    usuario_nombre: str


# ==============================================================================
# ENDPOINTS REST
# ==============================================================================

@router.get("/directorio")
def obtener_directorio_colaboradores(usuario_id: str):
    """
    Devuelve la lista de compañeros disponibles para iniciar una conversación 1 a 1,
    excluyendo al propio usuario solicitante.
    """
    uid_str = str(usuario_id).strip()
    try:
        with engine_personal.connect() as conn:
            sql = text("""
                SELECT DISTINCT
                    e.id_empleado,
                    e.nombre,
                    e.puesto,
                    e.depto,
                    e.foto_url,
                    e.cel
                FROM public.empleados e
                LEFT JOIN public.control_asistencia a 
                    ON TRIM(e.id_empleado) = TRIM(a.id_empleado)
                    AND a.fecha >= CURRENT_DATE - INTERVAL '15 days'
                    AND (a.hora_entrada IS NOT NULL OR a.hora_salida IS NOT NULL)
                WHERE (e.estatus_empleado = 'ACTIVO' OR e.estatus_empleado IS NULL)
                  AND e.id_empleado != :uid
                  AND e.id_empleado NOT IN ('000', '529')
                  AND UPPER(e.nombre) NOT LIKE '%CELULAR%'
                  AND UPPER(e.nombre) NOT LIKE '%KIOSCO%'
                  AND UPPER(e.nombre) NOT LIKE '%KIOSKO%'
                  AND UPPER(e.nombre) NOT LIKE '%LIVE STREAM%'
                  AND (
                      a.id_registro IS NOT NULL
                      OR UPPER(e.nombre) LIKE '%VILLAR%'
                      OR UPPER(e.nombre) LIKE '%VILAR%'
                      OR UPPER(e.nombre) LIKE '%AGUNDEZ%'
                  )
                ORDER BY e.nombre ASC
            """)
            rows = conn.execute(sql, {"uid": uid_str}).mappings().fetchall()

            resultado = []
            for r in rows:
                resultado.append({
                    "id_empleado": str(r["id_empleado"]),
                    "nombre": r["nombre"],
                    "puesto": r["puesto"] or "Colaborador",
                    "depto": r["depto"] or "General",
                    "foto_url": r["foto_url"] or f"/fotos/{r['id_empleado']}.jpg",
                    "cel": r["cel"] or ""
                })
            return resultado
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/conversaciones")
def listar_conversaciones_directas(usuario_id: str):
    """
    Devuelve la lista de conversaciones 1 a 1 activas del usuario, ordenadas
    por las más recientes y con el conteo de mensajes sin leer.
    """
    uid_str = str(usuario_id).strip()
    try:
        with engine_personal.connect() as conn:
            # Obtener compañeros con los que ha conversado
            sql = text("""
                WITH companeros AS (
                    SELECT DISTINCT
                        CASE 
                            WHEN remitente_id = :uid THEN destinatario_id 
                            ELSE remitente_id 
                        END AS companero_id
                    FROM public.chat_directo_mensajes
                    WHERE remitente_id = :uid OR destinatario_id = :uid
                )
                SELECT 
                    c.companero_id,
                    e.nombre AS companero_nombre,
                    e.puesto AS companero_puesto,
                    e.depto AS companero_depto,
                    e.foto_url,
                    e.cel,
                    (
                        SELECT COUNT(*) 
                        FROM public.chat_directo_mensajes m 
                        WHERE m.destinatario_id = :uid 
                          AND m.remitente_id = c.companero_id 
                          AND m.leido = FALSE
                    ) AS no_leidos,
                    (
                        SELECT m.mensaje 
                        FROM public.chat_directo_mensajes m 
                        WHERE (m.remitente_id = :uid AND m.destinatario_id = c.companero_id)
                           OR (m.remitente_id = c.companero_id AND m.destinatario_id = :uid)
                        ORDER BY m.id DESC LIMIT 1
                    ) AS ultimo_mensaje,
                    (
                        SELECT m.tipo_mensaje 
                        FROM public.chat_directo_mensajes m 
                        WHERE (m.remitente_id = :uid AND m.destinatario_id = c.companero_id)
                           OR (m.remitente_id = c.companero_id AND m.destinatario_id = :uid)
                        ORDER BY m.id DESC LIMIT 1
                    ) AS ultimo_tipo_mensaje,
                    (
                        SELECT to_char(m.fecha_hora, 'YYYY-MM-DD HH24:MI:SS') 
                        FROM public.chat_directo_mensajes m 
                        WHERE (m.remitente_id = :uid AND m.destinatario_id = c.companero_id)
                           OR (m.remitente_id = c.companero_id AND m.destinatario_id = :uid)
                        ORDER BY m.id DESC LIMIT 1
                    ) AS ultima_hora
                FROM companeros c
                LEFT JOIN public.empleados e ON e.id_empleado = c.companero_id
                ORDER BY no_leidos DESC, ultima_hora DESC NULLS LAST
            """)
            rows = conn.execute(sql, {"uid": uid_str}).mappings().fetchall()

            resultado = []
            for r in rows:
                c_id = str(r["companero_id"])
                resultado.append({
                    "companero_id": c_id,
                    "companero_nombre": r["companero_nombre"] or f"Colaborador {c_id}",
                    "companero_puesto": r["companero_puesto"] or "Colaborador",
                    "companero_depto": r["companero_depto"] or "General",
                    "foto_url": r["foto_url"] or f"/fotos/{c_id}.jpg",
                    "cel": r["cel"] or "",
                    "no_leidos": r["no_leidos"] or 0,
                    "ultimo_mensaje": r["ultimo_mensaje"] or "",
                    "ultimo_tipo_mensaje": r["ultimo_tipo_mensaje"] or "TEXTO",
                    "ultima_hora": r["ultima_hora"] or "",
                    "sala_id": generar_sala_id(uid_str, c_id)
                })
            return resultado
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/mensajes/{companero_id}")
def obtener_mensajes_directos(
    companero_id: str,
    usuario_id: str,
    limit: int = 150
):
    """
    Devuelve los mensajes de la conversación 1 a 1 entre usuario_id y companero_id.
    Marca automáticamente como leídos los mensajes dirigidos a usuario_id.
    """
    uid_str = str(usuario_id).strip()
    cid_str = str(companero_id).strip()
    sala = generar_sala_id(uid_str, cid_str)

    try:
        with engine_personal.begin() as conn:
            # Marcar mensajes como leídos
            conn.execute(text("""
                UPDATE public.chat_directo_mensajes 
                SET leido = TRUE 
                WHERE sala_id = :sala AND destinatario_id = :uid AND leido = FALSE
            """), {"sala": sala, "uid": uid_str})

            # Traer mensajes
            sql = text("""
                SELECT 
                    m.id,
                    m.sala_id,
                    m.remitente_id,
                    m.destinatario_id,
                    encode(m.remitente_nombre::bytea, 'hex') AS remitente_nombre_hex,
                    encode(m.mensaje::bytea, 'hex') AS mensaje_hex,
                    m.tipo_mensaje,
                    m.archivo_url,
                    m.reacciones,
                    m.metadata_extra,
                    to_char(m.fecha_hora, 'YYYY-MM-DD HH24:MI:SS') AS fecha_hora_str,
                    m.leido,
                    e.foto_url
                FROM (
                    SELECT * FROM public.chat_directo_mensajes
                    WHERE sala_id = :sala
                    ORDER BY id DESC
                    LIMIT :lim
                ) m
                LEFT JOIN public.empleados e ON e.id_empleado = m.remitente_id
                ORDER BY m.id ASC
            """)
            rows = conn.execute(sql, {"sala": sala, "lim": limit}).fetchall()

            resultado = []
            for r in rows:
                nom = reparar_mojibake(safe_decode_hex(r.remitente_nombre_hex))
                msj = reparar_mojibake(safe_decode_hex(r.mensaje_hex))
                resultado.append({
                    "id": r.id,
                    "sala_id": r.sala_id,
                    "remitente_id": str(r.remitente_id),
                    "destinatario_id": str(r.destinatario_id),
                    "remitente_nombre": nom,
                    "mensaje": msj,
                    "tipo_mensaje": r.tipo_mensaje or "TEXTO",
                    "archivo_url": r.archivo_url,
                    "reacciones": r.reacciones or {},
                    "metadata_extra": r.metadata_extra or {},
                    "fecha_hora_str": r.fecha_hora_str or "",
                    "leido": bool(r.leido),
                    "foto_url": r.foto_url or f"/fotos/{r.remitente_id}.jpg"
                })

            return resultado
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/mensajes/{companero_id}")
async def enviar_mensaje_directo(
    companero_id: str,
    payload: MensajeDirectoCreate
):
    """
    Inserta un nuevo mensaje en la conversación 1 a 1 y lo transmite en tiempo real.
    """
    texto_limpio = (payload.mensaje or "").strip()
    if not texto_limpio:
        raise HTTPException(status_code=400, detail="El mensaje no puede estar vacío.")

    rem_id_str = str(payload.remitente_id).strip()
    dest_id_str = str(companero_id).strip()
    sala = generar_sala_id(rem_id_str, dest_id_str)

    try:
        tipo = payload.tipo_mensaje or "TEXTO"
        if tipo == "TEXTO" and ("http://" in texto_limpio.lower() or "https://" in texto_limpio.lower()):
            tipo = "LINK"

        meta_json = json.dumps(payload.metadata_extra or {})
        fec_actual = obtener_ahora_local()

        sql = text("""
            INSERT INTO public.chat_directo_mensajes (
                sala_id, remitente_id, destinatario_id, remitente_nombre,
                mensaje, tipo_mensaje, archivo_url, metadata_extra, fecha_hora, leido
            ) VALUES (
                :sala, :rem_id, :dest_id, :nom,
                :msj, :tipo, :arch, CAST(:meta AS jsonb), :fec_hora, FALSE
            )
            RETURNING id, to_char(fecha_hora, 'YYYY-MM-DD HH24:MI:SS') AS fecha_hora_str;
        """)

        with engine_personal.begin() as conn:
            res = conn.execute(sql, {
                "sala": sala,
                "rem_id": rem_id_str,
                "dest_id": dest_id_str,
                "nom": payload.remitente_nombre,
                "msj": texto_limpio,
                "tipo": tipo,
                "arch": payload.archivo_url,
                "meta": meta_json,
                "fec_hora": fec_actual
            }).mappings().first()

            nuevo_id = res["id"]
            fecha_str = res["fecha_hora_str"]

            row_emp = conn.execute(
                text("SELECT foto_url FROM public.empleados WHERE id_empleado = :id_emp"),
                {"id_emp": rem_id_str}
            ).mappings().first()
            foto_emp = row_emp["foto_url"] if row_emp and row_emp["foto_url"] else f"/fotos/{rem_id_str}.jpg"

        msg_obj = {
            "id": nuevo_id,
            "sala_id": sala,
            "remitente_id": rem_id_str,
            "destinatario_id": dest_id_str,
            "remitente_nombre": payload.remitente_nombre,
            "mensaje": texto_limpio,
            "tipo_mensaje": tipo,
            "archivo_url": payload.archivo_url,
            "reacciones": {},
            "metadata_extra": payload.metadata_extra or {},
            "fecha_hora_str": fecha_str,
            "leido": False,
            "foto_url": foto_emp
        }

        # Transmitir en vivo por WebSocket a ambos participantes
        await ws_directo_manager.broadcast_direct(rem_id_str, dest_id_str, {
            "tipo": "NUEVO_MENSAJE_DIRECTO",
            "sala_id": sala,
            "remitente_id": rem_id_str,
            "destinatario_id": dest_id_str,
            "mensaje": msg_obj
        })
        asyncio.create_task(despachar_notificacion_directo(
            remitente_id=rem_id_str,
            remitente_nombre=payload.remitente_nombre,
            destinatario_id=dest_id_str,
            mensaje=texto_limpio,
            foto_url=foto_emp
        ))

        return {"status": "success", "mensaje": msg_obj}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/subir-adjunto")
async def subir_adjunto_directo(
    remitente_id: str = Form(...),
    archivo: UploadFile = File(...)
):
    """
    Guarda archivos, audios o fotos compartidas en el chat directo y devuelve la URL accesible.
    """
    try:
        ts = int(time.time() * 1000)
        ext = Path(archivo.filename).suffix.lower() or ".bin"
        nombre_limpio = f"dir_{remitente_id}_{ts}{ext}"
        destino = CHAT_DIRECTO_DIR / nombre_limpio

        with open(destino, "wb") as buffer:
            shutil.copyfileobj(archivo.file, buffer)

        url_publica = f"/Fotos_de_eventos/chat_directo/{nombre_limpio}"

        return {
            "status": "success",
            "archivo_url": url_publica,
            "nombre_original": archivo.filename
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al subir adjunto directo: {str(e)}")


@router.post("/mensajes/{mensaje_id}/reaccionar")
async def reaccionar_mensaje_directo(mensaje_id: int, payload: ReaccionDirectoPayload):
    """
    Agrega o retira una reacción emoji a un mensaje directo.
    """
    try:
        with engine_personal.begin() as conn:
            row = conn.execute(
                text("SELECT reacciones, remitente_id, destinatario_id FROM public.chat_directo_mensajes WHERE id = :mid"),
                {"mid": mensaje_id}
            ).fetchone()

            if not row:
                raise HTTPException(status_code=404, detail="Mensaje no encontrado")

            reacciones = row[0] or {}
            rem_id = str(row[1] or "")
            dest_id = str(row[2] or "")
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
                text("UPDATE public.chat_directo_mensajes SET reacciones = CAST(:r AS jsonb) WHERE id = :mid"),
                {"r": json.dumps(reacciones), "mid": mensaje_id}
            )

        # Notificar por WebSocket a ambos participantes
        await ws_directo_manager.broadcast_direct(rem_id, dest_id, {
            "tipo": "REACCION_DIRECTO",
            "mensaje_id": mensaje_id,
            "reacciones": reacciones
        })

        return {"status": "success", "reacciones": reacciones}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==============================================================================
# WEBSOCKET EN TIEMPO REAL
# ==============================================================================
@router.websocket("/ws/{usuario_id}")
async def websocket_chat_directo(
    websocket: WebSocket,
    usuario_id: str
):
    """
    Canal WebSocket para mensajería directa en tiempo real de cada colaborador.
    """
    uid_str = str(usuario_id).strip()
    await ws_directo_manager.connect(uid_str, websocket)
    try:
        while True:
            data = await websocket.receive_text()
            try:
                parsed = json.loads(data)
                if parsed.get("tipo") == "PING":
                    await websocket.send_json({"tipo": "PONG"})
            except Exception:
                pass
    except WebSocketDisconnect:
        ws_directo_manager.disconnect(uid_str, websocket)
    except Exception:
        ws_directo_manager.disconnect(uid_str, websocket)
