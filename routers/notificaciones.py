import json
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from core.notificaciones_ws import ws_notificaciones

router = APIRouter(prefix="/api/notificaciones", tags=["🔔 Notificaciones Flotantes en Tiempo Real"])

@router.websocket("/ws/{usuario_id}")
async def websocket_notificaciones_usuario(websocket: WebSocket, usuario_id: str):
    """
    Canal WebSocket en segundo plano para escuchar avisos y timbres VPRO en toda la plataforma.
    """
    uid_str = str(usuario_id).strip()
    await ws_notificaciones.connect(uid_str, websocket)
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
        ws_notificaciones.disconnect(uid_str, websocket)
    except Exception:
        ws_notificaciones.disconnect(uid_str, websocket)
