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

router = APIRouter(prefix="/api/chat-admin", tags=["🏢 Chat Administrativo & Recursos Humanos"])

# Directorio de almacenamiento para audios, imágenes y justificantes del chat administrativo
CHAT_ADMIN_DIR = FOTOS_EVENTOS_DIR / "chat_admin"
CHAT_ADMIN_DIR.mkdir(parents=True, exist_ok=True)


def _asegurar_tabla_chat_admin():
    """Crea la tabla e índices si no existen."""
    try:
        with engine_personal.begin() as conn:
            conn.execute(text("""
                CREATE TABLE IF NOT EXISTS public.chat_admin_mensajes (
                    id SERIAL PRIMARY KEY,
                    id_empleado VARCHAR(50) NOT NULL,
                    autor_id VARCHAR(50) NOT NULL,
                    autor_nombre VARCHAR(255) NOT NULL,
                    autor_rol VARCHAR(100),
                    mensaje TEXT NOT NULL,
                    tipo_mensaje VARCHAR(50) DEFAULT 'TEXTO',
                    archivo_url TEXT,
                    metadata_extra JSONB DEFAULT '{}'::jsonb,
                    fecha_hora TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                    leido_por_admin BOOLEAN DEFAULT FALSE,
                    leido_por_empleado BOOLEAN DEFAULT FALSE
                );
                CREATE INDEX IF NOT EXISTS idx_chat_admin_emp ON public.chat_admin_mensajes(id_empleado, fecha_hora ASC);
            """))
    except Exception as e:
        print(f"[WARN] Error al verificar tabla chat_admin: {e}")

_asegurar_tabla_chat_admin()


# ==============================================================================
# GESTOR DE CONEXIONES EN TIEMPO REAL (WEBSOCKETS)
# ==============================================================================
class AdminChatConnectionManager:
    def __init__(self):
        # id_empleado -> lista de WebSockets
        self.rooms: Dict[str, List[WebSocket]] = {}
        # Conexiones generales de administradores para alertas globales
        self.admin_listeners: List[WebSocket] = []

    async def connect(self, room_id: str, websocket: WebSocket, es_admin: bool = False):
        await websocket.accept()
        if room_id not in self.rooms:
            self.rooms[room_id] = []
        self.rooms[room_id].append(websocket)
        if es_admin and websocket not in self.admin_listeners:
            self.admin_listeners.append(websocket)

    def disconnect(self, room_id: str, websocket: WebSocket):
        if room_id in self.rooms:
            if websocket in self.rooms[room_id]:
                self.rooms[room_id].remove(websocket)
            if not self.rooms[room_id]:
                del self.rooms[room_id]
        if websocket in self.admin_listeners:
            self.admin_listeners.remove(websocket)

    async def broadcast_to_room(self, room_id: str, data: dict):
        # Enviar a los que están en la conversación específica
        if room_id in self.rooms:
            conexiones = list(self.rooms[room_id])
            for conn in conexiones:
                try:
                    await conn.send_json(data)
                except Exception:
                    self.disconnect(room_id, conn)

        # Enviar notificación a los administradores escuchando alertas
        admins = list(self.admin_listeners)
        for adm_conn in admins:
            if room_id in self.rooms and adm_conn in self.rooms[room_id]:
                continue # Ya se le envió arriba
            try:
                await adm_conn.send_json({
                    "tipo_alerta": "NUEVO_MENSAJE_ADMIN",
                    "id_empleado": room_id,
                    "data": data
                })
            except Exception:
                if adm_conn in self.admin_listeners:
                    self.admin_listeners.remove(adm_conn)

ws_admin_manager = AdminChatConnectionManager()


# ==============================================================================
# MODELOS
# ==============================================================================
class ChatAdminMensajeCreate(BaseModel):
    autor_id: str
    autor_nombre: str
    autor_rol: Optional[str] = "EMPLEADO"
    mensaje: str
    tipo_mensaje: Optional[str] = "TEXTO"
    archivo_url: Optional[str] = None
    metadata_extra: Optional[Dict[str, Any]] = None


# ==============================================================================
# ENDPOINTS REST
# ==============================================================================

@router.get("/conversaciones")
def listar_conversaciones_admin(
    usuario_id: str,
    es_admin: bool = False
):
    """
    Lista las conversaciones disponibles para el usuario en la arista administrativa.
    - Si es Admin: lista los empleados que tienen mensajes o solicitudes de permisos.
    - Si es empleado: devuelve su canal único con Administración.
    """
    try:
        with engine_personal.connect() as conn:
            if es_admin:
                # Obtener todos los empleados que tengan mensajes o permisos pendientes
                sql = text("""
                    SELECT 
                        e.id_empleado,
                        e.nombre,
                        e.puesto,
                        e.depto,
                        e.foto_url,
                        e.cel,
                        (
                            SELECT COUNT(*) 
                            FROM public.chat_admin_mensajes m 
                            WHERE m.id_empleado = e.id_empleado AND m.leido_por_admin = FALSE
                        ) AS no_leidos,
                        (
                            SELECT COUNT(*) 
                            FROM public.rh_permisos p 
                            WHERE p.id_empleado = e.id_empleado AND p.estatus = 'PENDIENTE'
                        ) AS permisos_pendientes,
                        (
                            SELECT m.mensaje 
                            FROM public.chat_admin_mensajes m 
                            WHERE m.id_empleado = e.id_empleado 
                            ORDER BY m.id DESC LIMIT 1
                        ) AS ultimo_mensaje,
                        (
                            SELECT m.tipo_mensaje 
                            FROM public.chat_admin_mensajes m 
                            WHERE m.id_empleado = e.id_empleado 
                            ORDER BY m.id DESC LIMIT 1
                        ) AS ultimo_tipo_mensaje,
                        (
                            SELECT to_char(m.fecha_hora, 'YYYY-MM-DD HH24:MI:SS') 
                            FROM public.chat_admin_mensajes m 
                            WHERE m.id_empleado = e.id_empleado 
                            ORDER BY m.id DESC LIMIT 1
                        ) AS ultima_hora
                    FROM public.empleados e
                    WHERE e.estatus_empleado = 'ACTIVO' OR e.estatus_empleado IS NULL
                    ORDER BY 
                        permisos_pendientes DESC,
                        no_leidos DESC,
                        ultima_hora DESC NULLS LAST,
                        e.nombre ASC
                """)
                rows = conn.execute(sql).mappings().fetchall()
                resultado = []
                for r in rows:
                    # Mostrar si tiene mensajes o permisos pendientes o si es relevante
                    if r["ultimo_mensaje"] or r["permisos_pendientes"] > 0 or r["no_leidos"] > 0:
                        resultado.append({
                            "id_empleado": str(r["id_empleado"]),
                            "nombre": r["nombre"],
                            "puesto": r["puesto"] or "Colaborador",
                            "depto": r["depto"] or "General",
                            "foto_url": r["foto_url"],
                            "no_leidos": r["no_leidos"] or 0,
                            "permisos_pendientes": r["permisos_pendientes"] or 0,
                            "ultimo_mensaje": r["ultimo_mensaje"] or ("📋 Permiso pendiente de revisión" if r["permisos_pendientes"] > 0 else "Sin mensajes"),
                            "ultimo_tipo_mensaje": r["ultimo_tipo_mensaje"] or "TEXTO",
                            "ultima_hora": r["ultima_hora"] or ""
                        })
                return resultado
            else:
                # Para un empleado individual, consultar su propio hilo con Administración
                sql_emp = text("""
                    SELECT 
                        (
                            SELECT COUNT(*) 
                            FROM public.chat_admin_mensajes m 
                            WHERE m.id_empleado = :id_emp AND m.leido_por_empleado = FALSE
                        ) AS no_leidos,
                        (
                            SELECT m.mensaje 
                            FROM public.chat_admin_mensajes m 
                            WHERE m.id_empleado = :id_emp 
                            ORDER BY m.id DESC LIMIT 1
                        ) AS ultimo_mensaje,
                        (
                            SELECT to_char(m.fecha_hora, 'YYYY-MM-DD HH24:MI:SS') 
                            FROM public.chat_admin_mensajes m 
                            WHERE m.id_empleado = :id_emp 
                            ORDER BY m.id DESC LIMIT 1
                        ) AS ultima_hora
                """)
                res = conn.execute(sql_emp, {"id_emp": str(usuario_id)}).mappings().first()
                no_lei = res["no_leidos"] if res else 0
                ult_m = res["ultimo_mensaje"] if res else None
                ult_h = res["ultima_hora"] if res else ""

                return [{
                    "id_empleado": str(usuario_id),
                    "nombre": "Administración & Recursos Humanos",
                    "puesto": "Atención Oficial y Permisos Laborales",
                    "depto": "Dirección General / RH",
                    "foto_url": "vendor/img/vpro_iso_badge.png",
                    "no_leidos": no_lei or 0,
                    "permisos_pendientes": 0,
                    "ultimo_mensaje": ult_m or "Canal directo con Administración para dudas y permisos laborales",
                    "ultimo_tipo_mensaje": "TEXTO",
                    "ultima_hora": ult_h or ""
                }]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/mensajes/{id_empleado}")
def obtener_mensajes_chat_admin(
    id_empleado: str,
    lector_id: Optional[str] = None,
    es_admin: bool = False
):
    """
    Devuelve los mensajes del hilo entre el colaborador y Administración.
    Marca automáticamente como leídos los mensajes correspondientes.
    """
    try:
        with engine_personal.begin() as conn:
            # Marcar leídos
            if es_admin:
                conn.execute(text("""
                    UPDATE public.chat_admin_mensajes 
                    SET leido_por_admin = TRUE 
                    WHERE id_empleado = :id_emp AND leido_por_admin = FALSE
                """), {"id_emp": str(id_empleado)})
            else:
                conn.execute(text("""
                    UPDATE public.chat_admin_mensajes 
                    SET leido_por_empleado = TRUE 
                    WHERE id_empleado = :id_emp AND leido_por_empleado = FALSE
                """), {"id_emp": str(id_empleado)})

            # Traer mensajes
            sql = text("""
                SELECT 
                    id,
                    id_empleado,
                    autor_id,
                    autor_nombre,
                    autor_rol,
                    mensaje,
                    tipo_mensaje,
                    archivo_url,
                    metadata_extra,
                    to_char(fecha_hora, 'YYYY-MM-DD HH24:MI:SS') AS fecha_hora_str,
                    leido_por_admin,
                    leido_por_empleado
                FROM public.chat_admin_mensajes
                WHERE id_empleado = :id_emp
                ORDER BY id ASC
            """)
            rows = conn.execute(sql, {"id_emp": str(id_empleado)}).mappings().fetchall()

            return [dict(r) for r in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/mensajes/{id_empleado}")
async def enviar_mensaje_chat_admin(
    id_empleado: str,
    payload: ChatAdminMensajeCreate
):
    """
    Guarda un mensaje en el hilo y lo transmite por WebSockets en tiempo real.
    """
    try:
        es_autor_admin = (payload.autor_rol or "").upper().strip() in ("ADMIN", "DIRECCION", "RH", "ADMINISTRACION")
        leido_adm = es_autor_admin
        leido_emp = not es_autor_admin

        with engine_personal.begin() as conn:
            meta_json = json.dumps(payload.metadata_extra or {})
            sql = text("""
                INSERT INTO public.chat_admin_mensajes (
                    id_empleado, autor_id, autor_nombre, autor_rol,
                    mensaje, tipo_mensaje, archivo_url, metadata_extra,
                    leido_por_admin, leido_por_empleado
                )
                VALUES (
                    :id_emp, :aut_id, :aut_nom, :aut_rol,
                    :msj, :tipo, :arch, CAST(:meta AS jsonb),
                    :l_adm, :l_emp
                )
                RETURNING id, to_char(fecha_hora, 'YYYY-MM-DD HH24:MI:SS') AS fecha_hora_str
            """)
            res = conn.execute(sql, {
                "id_emp": str(id_empleado),
                "aut_id": str(payload.autor_id),
                "aut_nom": payload.autor_nombre,
                "aut_rol": payload.autor_rol or "EMPLEADO",
                "msj": payload.mensaje,
                "tipo": payload.tipo_mensaje or "TEXTO",
                "arch": payload.archivo_url,
                "meta": meta_json,
                "l_adm": leido_adm,
                "l_emp": leido_emp
            }).mappings().first()

            nuevo_id = res["id"]
            fecha_str = res["fecha_hora_str"]

        msg_obj = {
            "id": nuevo_id,
            "id_empleado": str(id_empleado),
            "autor_id": str(payload.autor_id),
            "autor_nombre": payload.autor_nombre,
            "autor_rol": payload.autor_rol or "EMPLEADO",
            "mensaje": payload.mensaje,
            "tipo_mensaje": payload.tipo_mensaje or "TEXTO",
            "archivo_url": payload.archivo_url,
            "metadata_extra": payload.metadata_extra or {},
            "fecha_hora_str": fecha_str,
            "leido_por_admin": leido_adm,
            "leido_por_empleado": leido_emp
        }

        # Transmitir por WebSocket en vivo
        await ws_admin_manager.broadcast_to_room(str(id_empleado), msg_obj)

        return {"msg": "Mensaje enviado", "data": msg_obj}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/subir-adjunto/{id_empleado}")
async def subir_adjunto_chat_admin(
    id_empleado: str,
    archivo: UploadFile = File(...)
):
    """
    Guarda archivos o audios del chat administrativo y devuelve la URL pública.
    """
    try:
        ts = int(time.time() * 1000)
        ext = Path(archivo.filename).suffix.lower() or ".bin"
        nombre_limpio = f"adm_{id_empleado}_{ts}{ext}"
        destino = CHAT_ADMIN_DIR / nombre_limpio

        with open(destino, "wb") as f_out:
            shutil.copyfileobj(archivo.file, f_out)

        url_publica = f"/Fotos_de_eventos/chat_admin/{nombre_limpio}"
        return {
            "msg": "Archivo subido exitosamente",
            "archivo_url": url_publica,
            "filename": nombre_limpio
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.websocket("/ws/{id_empleado}")
async def websocket_chat_admin(
    websocket: WebSocket,
    id_empleado: str,
    es_admin: bool = False
):
    """
    Canal WebSocket para mensajería en tiempo real del chat administrativo.
    """
    room_id = str(id_empleado)
    await ws_admin_manager.connect(room_id, websocket, es_admin=es_admin)
    try:
        while True:
            data = await websocket.receive_text()
            # Mantener conexión viva (ping/pong)
            try:
                parsed = json.loads(data)
                if parsed.get("tipo") == "PING":
                    await websocket.send_json({"tipo": "PONG"})
            except Exception:
                pass
    except WebSocketDisconnect:
        ws_admin_manager.disconnect(room_id, websocket)
    except Exception:
        ws_admin_manager.disconnect(room_id, websocket)
