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
    """Crea la tabla, columnas e índices para la mesa de soporte 1 a 1 si no existen."""
    try:
        with engine_personal.begin() as conn:
            conn.execute(text("""
                CREATE TABLE IF NOT EXISTS public.chat_soporte_mensajes (
                    id SERIAL PRIMARY KEY,
                    id_empleado VARCHAR(50) NOT NULL,
                    id_empleado_consulta VARCHAR(50),
                    autor_id VARCHAR(50),
                    autor_nombre VARCHAR(255) NOT NULL,
                    autor_rol VARCHAR(100),
                    mensaje TEXT NOT NULL,
                    tipo_mensaje VARCHAR(50) DEFAULT 'TEXTO',
                    archivo_url TEXT,
                    es_fijado BOOLEAN DEFAULT FALSE,
                    reacciones JSONB DEFAULT '{}'::jsonb,
                    metadata_extra JSONB DEFAULT '{}'::jsonb,
                    fecha_hora TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                    leido_por_ti BOOLEAN DEFAULT FALSE,
                    leido_por_empleado BOOLEAN DEFAULT FALSE
                );

                ALTER TABLE public.chat_soporte_mensajes 
                ADD COLUMN IF NOT EXISTS id_empleado_consulta VARCHAR(50),
                ADD COLUMN IF NOT EXISTS autor_id VARCHAR(50),
                ADD COLUMN IF NOT EXISTS leido_por_ti BOOLEAN DEFAULT FALSE,
                ADD COLUMN IF NOT EXISTS leido_por_empleado BOOLEAN DEFAULT FALSE;

                UPDATE public.chat_soporte_mensajes 
                SET id_empleado_consulta = id_empleado 
                WHERE id_empleado_consulta IS NULL OR id_empleado_consulta = '';

                UPDATE public.chat_soporte_mensajes 
                SET autor_id = id_empleado 
                WHERE autor_id IS NULL OR autor_id = '';

                UPDATE public.chat_soporte_mensajes 
                SET leido_por_ti = TRUE, leido_por_empleado = TRUE 
                WHERE leido_por_ti IS NULL OR leido_por_empleado IS NULL;

                CREATE INDEX IF NOT EXISTS idx_chat_soporte_emp_cons 
                    ON public.chat_soporte_mensajes(id_empleado_consulta, fecha_hora ASC);
                CREATE INDEX IF NOT EXISTS idx_chat_soporte_leido_ti 
                    ON public.chat_soporte_mensajes(id_empleado_consulta, leido_por_ti);
                CREATE INDEX IF NOT EXISTS idx_chat_soporte_fec 
                    ON public.chat_soporte_mensajes(fecha_hora ASC);
                CREATE INDEX IF NOT EXISTS idx_chat_soporte_fijado 
                    ON public.chat_soporte_mensajes(es_fijado);
            """))
    except Exception as e:
        print(f"[WARN] Error al verificar tabla chat_soporte: {e}")

_asegurar_tabla_chat_soporte()


# ==============================================================================
# GESTOR DE CONEXIONES EN TIEMPO REAL (WEBSOCKETS 1 A 1)
# ==============================================================================
class SoporteChatConnectionManager:
    def __init__(self):
        # id_empleado_consulta -> lista de WebSockets en la sala privada
        self.rooms: Dict[str, List[WebSocket]] = {}
        # Conexiones generales de personal de Sistemas / Administración para alertas globales
        self.ti_listeners: List[WebSocket] = []

    async def connect(self, room_id: str, websocket: WebSocket, es_ti: bool = False):
        await websocket.accept()
        if room_id not in self.rooms:
            self.rooms[room_id] = []
        self.rooms[room_id].append(websocket)
        if es_ti and websocket not in self.ti_listeners:
            self.ti_listeners.append(websocket)

    def disconnect(self, room_id: str, websocket: WebSocket):
        if room_id in self.rooms:
            if websocket in self.rooms[room_id]:
                self.rooms[room_id].remove(websocket)
            if not self.rooms[room_id]:
                del self.rooms[room_id]
        if websocket in self.ti_listeners:
            self.ti_listeners.remove(websocket)

    async def broadcast_to_room(self, room_id: str, data: dict):
        """Envía el mensaje a la sala 1-1 y notifica a los agentes de TI."""
        if room_id in self.rooms:
            conexiones = list(self.rooms[room_id])
            for conn in conexiones:
                try:
                    await conn.send_json(data)
                except Exception:
                    self.disconnect(room_id, conn)

        # Enviar notificación a personal de Sistemas que esté escuchando alertas
        for ti_conn in list(self.ti_listeners):
            if room_id in self.rooms and ti_conn in self.rooms[room_id]:
                continue
            try:
                await ti_conn.send_json({
                    "tipo_alerta": "NUEVO_MENSAJE_SOPORTE",
                    "id_empleado_consulta": room_id,
                    "data": data
                })
            except Exception:
                if ti_conn in self.ti_listeners:
                    self.ti_listeners.remove(ti_conn)

    async def broadcast_global(self, data: dict):
        """Transmisión general (reacciones, avisos fijados)."""
        todos = set()
        for r in self.rooms.values():
            todos.update(r)
        todos.update(self.ti_listeners)
        for conn in list(todos):
            try:
                await conn.send_json(data)
            except Exception:
                pass

ws_soporte_manager = SoporteChatConnectionManager()


# ==============================================================================
# MODELOS DE DATOS
# ==============================================================================
class MensajeSoporteCreate(BaseModel):
    autor_id: str
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


def es_personal_ti(autor_rol: str = None, nombre: str = None) -> bool:
    """Determina si el usuario tiene privilegios de TI/Sistemas o Dirección."""
    txt = f"{autor_rol or ''} {nombre or ''}".upper()
    return any(k in txt for k in ["SISTEMA", "TI", "ADMIN", "DIRECCION", "CUAUHTEMOC", "VILLARREAL", "AGUNDEZ"])


# ==============================================================================
# ENDPOINTS REST
# ==============================================================================

@router.get("/conversaciones")
def listar_conversaciones_soporte(
    usuario_id: str,
    es_ti: bool = False
):
    """
    Lista las conversaciones disponibles para el usuario en la arista de Soporte TI:
    - Si es TI / Sistemas / Dirección: lista a todos los colaboradores que tienen consultas de soporte,
      ordenados por consultas sin leer y más recientes.
    - Si es un colaborador regular: devuelve ÚNICAMENTE su canal privado 1 a 1 con la Mesa de Ayuda TI.
    """
    try:
        with engine_personal.connect() as conn:
            if es_ti:
                # Sistemas ve la lista de colaboradores con solicitudes o mensajes
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
                            FROM public.chat_soporte_mensajes m 
                            WHERE m.id_empleado_consulta = e.id_empleado AND m.leido_por_ti = FALSE
                        ) AS no_leidos,
                        (
                            SELECT m.mensaje 
                            FROM public.chat_soporte_mensajes m 
                            WHERE m.id_empleado_consulta = e.id_empleado 
                            ORDER BY m.id DESC LIMIT 1
                        ) AS ultimo_mensaje,
                        (
                            SELECT m.tipo_mensaje 
                            FROM public.chat_soporte_mensajes m 
                            WHERE m.id_empleado_consulta = e.id_empleado 
                            ORDER BY m.id DESC LIMIT 1
                        ) AS ultimo_tipo_mensaje,
                        (
                            SELECT to_char(m.fecha_hora, 'YYYY-MM-DD HH24:MI:SS') 
                            FROM public.chat_soporte_mensajes m 
                            WHERE m.id_empleado_consulta = e.id_empleado 
                            ORDER BY m.id DESC LIMIT 1
                        ) AS ultima_hora
                    FROM public.empleados e
                    WHERE EXISTS (
                        SELECT 1 FROM public.chat_soporte_mensajes m 
                        WHERE m.id_empleado_consulta = e.id_empleado
                    )
                    ORDER BY 
                        no_leidos DESC,
                        ultima_hora DESC NULLS LAST,
                        e.nombre ASC
                """)
                rows = conn.execute(sql).mappings().fetchall()
                resultado = []
                for r in rows:
                    resultado.append({
                        "id_empleado": str(r["id_empleado"]),
                        "id_empleado_consulta": str(r["id_empleado"]),
                        "nombre": r["nombre"],
                        "puesto": r["puesto"] or "Colaborador",
                        "depto": r["depto"] or "General",
                        "foto_url": r["foto_url"] or f"/fotos/{r['id_empleado']}.jpg",
                        "no_leidos": r["no_leidos"] or 0,
                        "ultimo_mensaje": r["ultimo_mensaje"] or "Sin mensajes",
                        "ultimo_tipo_mensaje": r["ultimo_tipo_mensaje"] or "TEXTO",
                        "ultima_hora": r["ultima_hora"] or ""
                    })
                return resultado
            else:
                # Colaborador regular: únicamente su propio hilo privado 1-1 con TI
                sql_emp = text("""
                    SELECT 
                        (
                            SELECT COUNT(*) 
                            FROM public.chat_soporte_mensajes m 
                            WHERE m.id_empleado_consulta = :id_emp AND m.leido_por_empleado = FALSE
                        ) AS no_leidos,
                        (
                            SELECT m.mensaje 
                            FROM public.chat_soporte_mensajes m 
                            WHERE m.id_empleado_consulta = :id_emp 
                            ORDER BY m.id DESC LIMIT 1
                        ) AS ultimo_mensaje,
                        (
                            SELECT to_char(m.fecha_hora, 'YYYY-MM-DD HH24:MI:SS') 
                            FROM public.chat_soporte_mensajes m 
                            WHERE m.id_empleado_consulta = :id_emp 
                            ORDER BY m.id DESC LIMIT 1
                        ) AS ultima_hora
                """)
                res = conn.execute(sql_emp, {"id_emp": str(usuario_id)}).mappings().first()
                no_lei = res["no_leidos"] if res else 0
                ult_m = res["ultimo_mensaje"] if res else None
                ult_h = res["ultima_hora"] if res else ""

                return [{
                    "id_empleado": str(usuario_id),
                    "id_empleado_consulta": str(usuario_id),
                    "nombre": "Mesa de Ayuda TI",
                    "puesto": "Sistemas, Redes & Soporte Técnico 1-1",
                    "depto": "TI & Soporte",
                    "foto_url": "vendor/img/avatar_default.png",
                    "no_leidos": no_lei or 0,
                    "ultimo_mensaje": ult_m or "Canal directo 1 a 1 con Soporte TI para resolver dudas técnicas, internet y equipos.",
                    "ultimo_tipo_mensaje": "TEXTO",
                    "ultima_hora": ult_h or ""
                }]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/info")
def obtener_info_soporte(id_empleado_consulta: Optional[str] = None):
    """
    Retorna métricas y datos rápidos de la mesa de soporte.
    """
    try:
        with engine_personal.connect() as conn:
            filtro = ""
            params = {}
            if id_empleado_consulta:
                filtro = "WHERE id_empleado_consulta = :emp"
                params["emp"] = str(id_empleado_consulta)

            sql = text(f"""
                SELECT 
                    COUNT(*) AS total_mensajes,
                    COUNT(*) FILTER (WHERE fecha_hora >= CURRENT_DATE) AS hoy_mensajes,
                    (SELECT mensaje FROM public.chat_soporte_mensajes WHERE es_fijado = TRUE ORDER BY id DESC LIMIT 1) AS aviso_fijado,
                    (SELECT autor_nombre FROM public.chat_soporte_mensajes WHERE es_fijado = TRUE ORDER BY id DESC LIMIT 1) AS aviso_fijado_autor,
                    (SELECT to_char(fecha_hora, 'YYYY-MM-DD HH24:MI') FROM public.chat_soporte_mensajes WHERE es_fijado = TRUE ORDER BY id DESC LIMIT 1) AS aviso_fijado_fecha
                FROM public.chat_soporte_mensajes
                {filtro}
            """)
            row = conn.execute(sql, params).mappings().first()

            return {
                "nombre_canal": "Mesa de Ayuda TI (1 a 1 Privado)",
                "descripcion": "Consultas directas y confidenciales con el área de Sistemas sobre internet, contraseñas, equipos y software.",
                "total_mensajes": row["total_mensajes"] or 0,
                "mensajes_hoy": row["hoy_mensajes"] or 0,
                "aviso_fijado": row["aviso_fijado"],
                "aviso_fijado_autor": row["aviso_fijado_autor"],
                "aviso_fijado_fecha": row["aviso_fijado_fecha"]
            }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/mensajes/{id_empleado_consulta}")
def obtener_mensajes_conversacion_soporte(
    id_empleado_consulta: str,
    lector_id: Optional[str] = None,
    es_ti: bool = False,
    limit: int = 150
):
    """
    Devuelve los mensajes de la sala 1 a 1 entre el colaborador especificado y Soporte TI.
    Garantiza privacidad: si el lector no es TI, únicamente puede leer su propia sala.
    Marca automáticamente como leídos los mensajes correspondientes.
    """
    emp_consulta_str = str(id_empleado_consulta).strip()
    lector_id_str = str(lector_id).strip() if lector_id else ""

    # Control de acceso estricto
    if not es_ti and lector_id_str and lector_id_str != emp_consulta_str:
        raise HTTPException(status_code=403, detail="No tienes autorización para ver las consultas privadas de este colaborador.")

    try:
        with engine_personal.begin() as conn:
            # Marcar leídos
            if es_ti:
                conn.execute(text("""
                    UPDATE public.chat_soporte_mensajes 
                    SET leido_por_ti = TRUE 
                    WHERE id_empleado_consulta = :emp AND leido_por_ti = FALSE
                """), {"emp": emp_consulta_str})
            else:
                conn.execute(text("""
                    UPDATE public.chat_soporte_mensajes 
                    SET leido_por_empleado = TRUE 
                    WHERE id_empleado_consulta = :emp AND leido_por_empleado = FALSE
                """), {"emp": emp_consulta_str})

            # Obtener mensajes de este hilo 1 a 1
            sql = text("""
                SELECT 
                    m.id,
                    m.id_empleado,
                    m.id_empleado_consulta,
                    COALESCE(m.autor_id, m.id_empleado) AS autor_id,
                    encode(m.autor_nombre::bytea, 'hex') AS autor_nombre_hex,
                    m.autor_rol,
                    encode(m.mensaje::bytea, 'hex') AS mensaje_hex,
                    m.tipo_mensaje,
                    m.archivo_url,
                    m.es_fijado,
                    m.reacciones,
                    m.metadata_extra,
                    to_char(m.fecha_hora, 'YYYY-MM-DD HH24:MI:SS') AS fecha_hora_str,
                    m.leido_por_ti,
                    m.leido_por_empleado,
                    e.foto_url
                FROM (
                    SELECT * FROM public.chat_soporte_mensajes
                    WHERE id_empleado_consulta = :emp
                    ORDER BY id DESC
                    LIMIT :lim
                ) m
                LEFT JOIN public.empleados e ON e.id_empleado = COALESCE(m.autor_id, m.id_empleado)
                ORDER BY m.id ASC
            """)
            rows = conn.execute(sql, {"emp": emp_consulta_str, "lim": limit}).fetchall()

            resultado = []
            for r in rows:
                nom = reparar_mojibake(safe_decode_hex(r.autor_nombre_hex))
                msj = reparar_mojibake(safe_decode_hex(r.mensaje_hex))
                resultado.append({
                    "id": r.id,
                    "id_empleado": str(r.id_empleado),
                    "id_empleado_consulta": str(r.id_empleado_consulta or emp_consulta_str),
                    "autor_id": str(r.autor_id),
                    "autor_nombre": nom,
                    "autor_rol": r.autor_rol or "COLABORADOR",
                    "mensaje": msj,
                    "tipo_mensaje": r.tipo_mensaje or "TEXTO",
                    "archivo_url": r.archivo_url,
                    "es_fijado": bool(r.es_fijado),
                    "reacciones": r.reacciones or {},
                    "metadata_extra": r.metadata_extra or {},
                    "fecha_hora_str": r.fecha_hora_str or "",
                    "leido_por_ti": bool(r.leido_por_ti),
                    "leido_por_empleado": bool(r.leido_por_empleado),
                    "foto_url": r.foto_url or f"/fotos/{r.autor_id}.jpg"
                })

            return resultado
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/mensajes")
def obtener_mensajes_soporte_legado(
    usuario_id: Optional[str] = None,
    es_ti: bool = False,
    limit: int = 150
):
    """
    Ruta de compatibilidad para clientes existentes que no pasaban id_empleado_consulta en la URL.
    Si usuario_id está presente y no es TI, devuelve únicamente sus mensajes.
    """
    if usuario_id and not es_ti:
        return obtener_mensajes_conversacion_soporte(
            id_empleado_consulta=usuario_id,
            lector_id=usuario_id,
            es_ti=False,
            limit=limit
        )
    # Si es TI o llamada general sin parámetro, devuelve mensajes vacíos o del primer hilo
    return []


@router.post("/mensajes/{id_empleado_consulta}")
async def enviar_mensaje_conversacion_soporte(
    id_empleado_consulta: str,
    payload: MensajeSoporteCreate
):
    """
    Inserta un nuevo mensaje en la sala privada 1 a 1 y lo transmite en tiempo real por WebSockets.
    """
    texto_limpio = (payload.mensaje or "").strip()
    if not texto_limpio:
        raise HTTPException(status_code=400, detail="El mensaje no puede estar vacío.")

    emp_consulta_str = str(id_empleado_consulta).strip()
    aut_id_str = str(payload.autor_id).strip()

    try:
        tipo = payload.tipo_mensaje or "TEXTO"
        if tipo == "TEXTO" and ("http://" in texto_limpio.lower() or "https://" in texto_limpio.lower()):
            tipo = "LINK"

        # Determinación de leído:
        # Si el autor es personal de TI/Sistemas o Admin respondiendo, la consulta ya fue leída por TI.
        es_autor_ti = es_personal_ti(payload.autor_rol, payload.autor_nombre)
        leido_ti = es_autor_ti
        leido_emp = not es_autor_ti

        meta_json = json.dumps(payload.metadata_extra or {})
        fec_actual = obtener_ahora_local()

        sql = text("""
            INSERT INTO public.chat_soporte_mensajes (
                id_empleado, id_empleado_consulta, autor_id, autor_nombre, autor_rol, 
                mensaje, tipo_mensaje, archivo_url, es_fijado, metadata_extra, 
                fecha_hora, leido_por_ti, leido_por_empleado
            ) VALUES (
                :aut_id, :emp_cons, :aut_id, :nom, :rol,
                :msj, :tipo, :arch, :fij, CAST(:meta AS jsonb),
                :fec_hora, :l_ti, :l_emp
            )
            RETURNING id, to_char(fecha_hora, 'YYYY-MM-DD HH24:MI:SS') AS fecha_hora_str;
        """)

        with engine_personal.begin() as conn:
            res = conn.execute(sql, {
                "aut_id": aut_id_str,
                "emp_cons": emp_consulta_str,
                "nom": payload.autor_nombre,
                "rol": payload.autor_rol or "COLABORADOR",
                "msj": texto_limpio,
                "tipo": tipo,
                "arch": payload.archivo_url,
                "fij": bool(payload.es_fijado),
                "meta": meta_json,
                "fec_hora": fec_actual,
                "l_ti": leido_ti,
                "l_emp": leido_emp
            }).mappings().first()

            nuevo_id = res["id"]
            fecha_str = res["fecha_hora_str"]

            row_emp = conn.execute(
                text("SELECT foto_url FROM public.empleados WHERE id_empleado = :id_emp"),
                {"id_emp": aut_id_str}
            ).mappings().first()
            foto_emp = row_emp["foto_url"] if row_emp and row_emp["foto_url"] else f"/fotos/{aut_id_str}.jpg"

        msg_obj = {
            "id": nuevo_id,
            "id_empleado": aut_id_str,
            "id_empleado_consulta": emp_consulta_str,
            "autor_id": aut_id_str,
            "autor_nombre": payload.autor_nombre,
            "autor_rol": payload.autor_rol or "COLABORADOR",
            "mensaje": texto_limpio,
            "tipo_mensaje": tipo,
            "archivo_url": payload.archivo_url,
            "es_fijado": bool(payload.es_fijado),
            "reacciones": {},
            "metadata_extra": payload.metadata_extra or {},
            "fecha_hora_str": fecha_str,
            "leido_por_ti": leido_ti,
            "leido_por_empleado": leido_emp,
            "foto_url": foto_emp
        }

        # Transmisión en tiempo real vía WebSocket a la sala 1 a 1 y a escuchas de TI
        await ws_soporte_manager.broadcast_to_room(emp_consulta_str, {
            "tipo": "NUEVO_MENSAJE_SOPORTE",
            "id_empleado_consulta": emp_consulta_str,
            "mensaje": msg_obj
        })

        return {"status": "success", "mensaje": msg_obj}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/subir-adjunto/{id_empleado_consulta}")
async def subir_adjunto_soporte(
    id_empleado_consulta: str,
    archivo: UploadFile = File(...)
):
    """
    Almacena archivos o capturas enviadas al chat de soporte 1 a 1 y devuelve la URL accesible.
    """
    try:
        ts = int(time.time() * 1000)
        ext = Path(archivo.filename).suffix.lower() or ".bin"
        nombre_limpio = f"soporte_{id_empleado_consulta}_{ts}{ext}"
        destino = CHAT_SOPORTE_DIR / nombre_limpio

        with open(destino, "wb") as buffer:
            shutil.copyfileobj(archivo.file, buffer)

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
                text("SELECT reacciones, id_empleado_consulta FROM public.chat_soporte_mensajes WHERE id = :mid"),
                {"mid": mensaje_id}
            ).fetchone()

            if not row:
                raise HTTPException(status_code=404, detail="Mensaje no encontrado")

            reacciones = row[0] or {}
            id_emp_consulta = str(row[1] or "")
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

        # Notificar por WebSocket a la sala
        data_ev = {
            "tipo": "REACCION_SOPORTE",
            "mensaje_id": mensaje_id,
            "id_empleado_consulta": id_emp_consulta,
            "reacciones": reacciones
        }
        if id_emp_consulta:
            await ws_soporte_manager.broadcast_to_room(id_emp_consulta, data_ev)
        else:
            await ws_soporte_manager.broadcast_global(data_ev)

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
                text("SELECT es_fijado, id_empleado_consulta FROM public.chat_soporte_mensajes WHERE id = :mid"),
                {"mid": mensaje_id}
            ).fetchone()

            if not row:
                raise HTTPException(status_code=404, detail="Mensaje no encontrado")

            nuevo_estado = not bool(row[0])
            id_emp_consulta = str(row[1] or "")
            conn.execute(
                text("UPDATE public.chat_soporte_mensajes SET es_fijado = :st WHERE id = :mid"),
                {"st": nuevo_estado, "mid": mensaje_id}
            )

        data_ev = {
            "tipo": "FIJADO_SOPORTE_CAMBIO",
            "mensaje_id": mensaje_id,
            "id_empleado_consulta": id_emp_consulta,
            "es_fijado": nuevo_estado
        }
        if id_emp_consulta:
            await ws_soporte_manager.broadcast_to_room(id_emp_consulta, data_ev)
        else:
            await ws_soporte_manager.broadcast_global(data_ev)

        return {"status": "success", "es_fijado": nuevo_estado}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==============================================================================
# WEBSOCKET EN TIEMPO REAL (1 A 1)
# ==============================================================================
@router.websocket("/ws/{id_empleado_consulta}")
async def websocket_chat_soporte(
    websocket: WebSocket,
    id_empleado_consulta: str,
    es_ti: bool = False
):
    """
    Canal WebSocket privado 1 a 1 para mensajería en tiempo real de Soporte TI.
    """
    room_id = str(id_empleado_consulta).strip()
    await ws_soporte_manager.connect(room_id, websocket, es_ti=es_ti)
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
        ws_soporte_manager.disconnect(room_id, websocket)
    except Exception:
        ws_soporte_manager.disconnect(room_id, websocket)


@router.websocket("/ws")
async def websocket_chat_soporte_legado(websocket: WebSocket):
    """
    Canal WebSocket legado para conexiones que no envíen el parámetro de sala en la URL.
    """
    room_id = "general"
    await ws_soporte_manager.connect(room_id, websocket, es_ti=True)
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
        ws_soporte_manager.disconnect(room_id, websocket)
    except Exception:
        ws_soporte_manager.disconnect(room_id, websocket)
