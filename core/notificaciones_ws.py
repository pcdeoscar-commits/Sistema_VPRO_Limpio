import asyncio
import json
import re
from typing import Dict, List, Optional, Any
from fastapi import WebSocket, WebSocketDisconnect
from sqlalchemy import text
from core.database import engine_personal, engine_eventos
from core.utils import safe_decode_hex, reparar_mojibake

class GlobalNotificationManager:
    def __init__(self):
        # usuario_id -> list of active WebSockets in index.html/dashboard
        self.user_sockets: Dict[str, List[WebSocket]] = {}

    async def connect(self, usuario_id: str, websocket: WebSocket):
        await websocket.accept()
        uid = str(usuario_id).strip()
        if uid not in self.user_sockets:
            self.user_sockets[uid] = []
        self.user_sockets[uid].append(websocket)

    def disconnect(self, usuario_id: str, websocket: WebSocket):
        uid = str(usuario_id).strip()
        if uid in self.user_sockets:
            if websocket in self.user_sockets[uid]:
                self.user_sockets[uid].remove(websocket)
            if not self.user_sockets[uid]:
                del self.user_sockets[uid]

    async def enviar_a_usuario(self, usuario_id: str, payload: dict):
        uid = str(usuario_id).strip()
        if uid in self.user_sockets:
            for ws in list(self.user_sockets[uid]):
                try:
                    await ws.send_json(payload)
                except Exception:
                    self.disconnect(uid, ws)

    async def enviar_a_usuarios(self, usuario_ids: List[str], payload: dict):
        unicos = set(str(u).strip() for u in usuario_ids if str(u).strip())
        for uid in unicos:
            await self.enviar_a_usuario(uid, payload)

ws_notificaciones = GlobalNotificationManager()


def normalizar_cadena(txt: str) -> str:
    if not txt:
        return ""
    import unicodedata
    n = unicodedata.normalize('NFD', txt.upper())
    return re.sub(r'[\u0300-\u036f]', '', n).strip()


# ==============================================================================
# DISPATCHERS SEGÚN REGLAS ESTRICTAS DE NEGOCIO:
# ==============================================================================

async def despachar_notificacion_op(
    id_evento: int,
    autor_id: str,
    autor_nombre: str,
    mensaje: str,
    foto_url: Optional[str] = None
):
    """
    Regla 1: OPs
    Solo se notifica a los involucrados convocados en esa OP (y roles directivos).
    El remitente NO recibe notificación a sí mismo.
    """
    try:
        # 1. Obtener detalles del evento y personal convocado
        sql_ev = text("""
            SELECT 
                folio, 
                nombre_evento, 
                resp_prod, 
                resp_gastos, 
                chofer, 
                personal_convocado_op,
                choferes_por_vehiculo
            FROM public.eventos 
            WHERE id_evento = :ev
        """)
        with engine_eventos.connect() as conn:
            row_ev = conn.execute(sql_ev, {"ev": id_evento}).mappings().first()

        if not row_ev:
            return

        folio = row_ev["folio"] or str(id_evento)
        nom_ev = row_ev["nombre_evento"] or f"Evento {folio}"
        resp_prod = normalizar_cadena(row_ev["resp_prod"] or "")
        resp_gastos = normalizar_cadena(row_ev["resp_gastos"] or "")
        chofer = normalizar_cadena(row_ev["chofer"] or "")

        # Extraer convocados
        raw_conv = row_ev["personal_convocado_op"] or []
        convocados_norm = [normalizar_cadena(c) for c in raw_conv if c]

        # 2. Consultar empleados activos en db_personal
        sql_emp = text("""
            SELECT id_empleado, nombre, rol, puesto, depto 
            FROM public.empleados 
            WHERE estatus_empleado = 'ACTIVO' OR estatus_empleado IS NULL
        """)
        with engine_personal.connect() as conn:
            rows_emp = conn.execute(sql_emp).mappings().fetchall()

        destinatarios = []
        autor_id_str = str(autor_id).strip()

        for emp in rows_emp:
            emp_id = str(emp["id_empleado"]).strip()
            if emp_id == autor_id_str:
                continue # No auto-notificar al autor

            emp_nom = normalizar_cadena(emp["nombre"] or "")
            emp_rol = normalizar_cadena(f"{emp['rol'] or ''} {emp['puesto'] or ''}")

            # Directivos y coordinadores autorizados
            es_directivo = any(k in emp_nom for k in ["VILLARREAL", "AGUNDEZ"]) or "COORD" in emp_rol or "201" == emp_id
            if es_directivo:
                destinatarios.append(emp_id)
                continue

            # Involucrados en la OP
            if emp_nom and (emp_nom in resp_prod or emp_nom in resp_gastos or emp_nom in chofer):
                destinatarios.append(emp_id)
                continue

            if any(emp_nom in c or c in emp_nom for c in convocados_norm if c):
                destinatarios.append(emp_id)
                continue

            # Comparar por apellidos/tokens de nombre (mínimo 2 coincidencias)
            tokens = [w for w in emp_nom.split() if len(w) >= 3]
            for c in convocados_norm:
                if sum(1 for t in tokens if t in c) >= 2:
                    destinatarios.append(emp_id)
                    break

        if not destinatarios:
            return

        payload = {
            "tipo": "AVISO_CHAT_VPRO",
            "origen": "ops",
            "badge_texto": f"OP-{folio}",
            "badge_color": "#00a884",
            "icono": "ph-film-strip",
            "titulo": f"OP-{folio}: {nom_ev[:26]}",
            "autor": autor_nombre,
            "mensaje": mensaje,
            "foto_url": foto_url or f"/fotos/{autor_id_str}.jpg",
            "url_chat": f"chat.html?folio={folio}&arista=ops"
        }

        await ws_notificaciones.enviar_a_usuarios(destinatarios, payload)

    except Exception as e:
        print(f"[WARN] Error al despachar notificacion OP: {e}")


async def despachar_notificacion_rrhh(
    autor_id: str,
    autor_nombre: str,
    id_empleado_hilo: str,
    mensaje: str,
    foto_url: Optional[str] = None
):
    """
    Regla 2: RRHH
    - Si el mensaje es de un colaborador: solo a Ana Lilia (ID 101).
    - Si el mensaje lo envía Ana Lilia (RRHH): solo al colaborador del hilo.
    """
    try:
        aut_id_str = str(autor_id).strip()
        hilo_id_str = str(id_empleado_hilo).strip()

        # Ana Lilia Villarreal Uribe es ID 101
        es_ana_lilia = (aut_id_str == "101") or ("ANA LILIA" in normalizar_cadena(autor_nombre))

        if es_ana_lilia:
            # Respuesta de RRHH hacia el empleado
            destinatario = hilo_id_str
            titulo = "RRHH - Respuesta Oficial"
            badge_color = "#6366f1"
        else:
            # Consulta de un empleado hacia RRHH (Ana Lilia)
            destinatario = "101"
            titulo = "RRHH - Nueva Solicitud"
            badge_color = "#6366f1"

        if destinatario == aut_id_str:
            return # Evitar auto-notificación

        payload = {
            "tipo": "AVISO_CHAT_VPRO",
            "origen": "admin",
            "badge_texto": "RRHH",
            "badge_color": badge_color,
            "icono": "ph-buildings",
            "titulo": titulo,
            "autor": autor_nombre,
            "mensaje": mensaje,
            "foto_url": foto_url or f"/fotos/{aut_id_str}.jpg",
            "url_chat": f"chat.html?arista=admin&id={hilo_id_str}"
        }

        await ws_notificaciones.enviar_a_usuario(destinatario, payload)

    except Exception as e:
        print(f"[WARN] Error al despachar notificacion RRHH: {e}")


async def despachar_notificacion_ayuda_redes(
    autor_id: str,
    autor_nombre: str,
    id_empleado_consulta: str,
    mensaje: str,
    foto_url: Optional[str] = None
):
    """
    Regla 3: Ayuda Redes
    - Si consulta un colaborador: a los empleados 201 y 202 (Sistemas).
    - Si responde Sistemas: solo al colaborador de la consulta.
    """
    try:
        aut_id_str = str(autor_id).strip()
        cons_id_str = str(id_empleado_consulta).strip()

        es_sistemas = aut_id_str in ("201", "202")

        if es_sistemas:
            # Sistemas responde al colaborador
            destinatarios = [cons_id_str]
            titulo = "Ayuda Redes - Soporte Técnico"
        else:
            # Colaborador pide ayuda a Sistemas (201 y 202)
            destinatarios = ["201", "202"]
            titulo = "Ayuda Redes - Nueva Consulta"

        destinatarios = [d for d in destinatarios if d != aut_id_str]
        if not destinatarios:
            return

        payload = {
            "tipo": "AVISO_CHAT_VPRO",
            "origen": "soporte",
            "badge_texto": "Ayuda Redes",
            "badge_color": "#0284c7",
            "icono": "ph-laptop",
            "titulo": titulo,
            "autor": autor_nombre,
            "mensaje": mensaje,
            "foto_url": foto_url or f"/fotos/{aut_id_str}.jpg",
            "url_chat": f"chat.html?arista=soporte&id={cons_id_str}"
        }

        await ws_notificaciones.enviar_a_usuarios(destinatarios, payload)

    except Exception as e:
        print(f"[WARN] Error al despachar notificacion Ayuda Redes: {e}")


async def despachar_notificacion_directo(
    remitente_id: str,
    remitente_nombre: str,
    destinatario_id: str,
    mensaje: str,
    foto_url: Optional[str] = None
):
    """
    Regla 4: Chat 1 a 1
    Aviso estrictamente a quien se le manda el mensaje (destinatario_id solamente).
    """
    try:
        rem_str = str(remitente_id).strip()
        dest_str = str(destinatario_id).strip()

        if rem_str == dest_str:
            return # No auto-notificar

        payload = {
            "tipo": "AVISO_CHAT_VPRO",
            "origen": "directo",
            "badge_texto": "1-1",
            "badge_color": "#8b5cf6",
            "icono": "ph-chat-circle-dots",
            "titulo": "1-1 Mensaje Privado",
            "autor": remitente_nombre,
            "mensaje": mensaje,
            "foto_url": foto_url or f"/fotos/{rem_str}.jpg",
            "url_chat": f"chat.html?arista=directo&id={rem_str}"
        }

        await ws_notificaciones.enviar_a_usuario(dest_str, payload)

    except Exception as e:
        print(f"[WARN] Error al despachar notificacion 1 a 1: {e}")
