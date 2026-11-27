"""
core/ai_client.py
=================
Cliente ligero y seguro para Google Gemini API (gemini-2.5-flash).
Incluye:
  - Degradación elegante si no hay GEMINI_API_KEY o si se agota la cuota (HTTP 429).
  - Caché en memoria para preguntas frecuentes de ayuda.
  - Límite diario por usuario para proteger el consumo de tokens.
  - Alerta automática interna cuando se detecta cuota agotada.
"""

import os
import time
import json
import base64
import hashlib
import datetime
from typing import Optional, Dict, Any, Tuple
import requests

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "").strip()
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-3.8-flash").strip()
GEMINI_FALLBACK_MODELS = [
    GEMINI_MODEL,
    "gemini-3.8-flash",
    "gemini-3-flash-preview",
    "gemini-3.1-flash-lite-preview",
]
LIMITE_DIARIO_USUARIO = int(os.getenv("IA_LIMITE_DIARIO_USUARIO", "40"))

# Estado global en memoria (reseteo diario automático)
_CACHE_RESPUESTAS: Dict[str, Tuple[float, str]] = {}
_CONTEO_DIARIO: Dict[str, int] = {}
_ESTADO_CUOTA = {
    "cuota_agotada": False,
    "ultimo_error": None,
    "fecha_alerta": None,
    "consultas_hoy": 0,
    "fecha_conteo": None,
}

VPRO_CONTEXTO_SISTEMA = """
Eres el Copiloto Operativo oficial de VPRO Workspace ERP (vprocloud.com), empresa de producción audiovisual y transmisión en vivo en Culiacán, Sinaloa.
Responde siempre en español claro, breve, amable y práctico.

Reglas clave del sistema VPRO que debes conocer:
1. Reloj Checador / Kiosco QR:
   - Son 4 marcas diarias: Entrada Matutina (09:00), Salida a Comer (14:00), Entrada Vespertina (16:00) y Salida (19:00).
   - Tolerancia oficial: 10 minutos sobre la hora de entrada o llamado de OP.
   - Si una OP tiene llamado en la tarde (>= 13:00), el sistema otorga "Mañana libre autorizada" y registra directo en Entrada Vespertina.
   - Si el empleado olvida checar salida a comer (14:00) y regresa en la tarde, el sistema auto-ajusta la salida matutina a las 14:00.
   - Si falló el lector o se olvidó una marca, el empleado puede usar "Solicitar Aclaración de Checada" en Inicio para que RRHH la apruebe.
2. Órdenes de Producción (OPs) y Checkout:
   - El Productor Responsable asignado es quien puede comprobar gastos en el Reporte de Gastos.
   - Candado de Incidencias: para enviar el Informe de Gastos, todos los convocados que sacaron equipo en Checkout deben haber reportado sus incidencias al retornar a bodega.
   - Al crear/editar una OP, el sistema alerta automáticamente si hay traslapes de personal o vehículos.
3. Cotizaciones:
   - Desde Bóveda de Cotizaciones se puede editar, descargar PDF o convertir a OP con el botón "A OP".
4. RRHH y Permisos:
   - Permisos por días o por horas y vacaciones se solicitan al panel de RRHH; al aprobarse se sincronizan con el Checador.
   - En Inicio solo aparecen los permisos pendientes de evaluación; una vez dictaminados pasan al expediente de RRHH.
5. VPRO Transfer:
   - Permite enviar archivos y carpetas completas hasta 10 GB. Expiran 24h después de descargarse o a las 72h sin descarga.
6. Consulta y Auditoría de Asistencia:
   - Pestaña exclusiva para usuarios con rol ADMIN.
"""


def _resetear_si_nuevo_dia():
    hoy = datetime.date.today().isoformat()
    if _ESTADO_CUOTA["fecha_conteo"] != hoy:
        _CONTEO_DIARIO.clear()
        _ESTADO_CUOTA["consultas_hoy"] = 0
        _ESTADO_CUOTA["fecha_conteo"] = hoy
        _ESTADO_CUOTA["cuota_agotada"] = False
        _ESTADO_CUOTA["ultimo_error"] = None


def obtener_estado_ia() -> Dict[str, Any]:
    _resetear_si_nuevo_dia()
    api_key = os.getenv("GEMINI_API_KEY", GEMINI_API_KEY).strip()
    return {
        "habilitada": bool(api_key),
        "modelo": GEMINI_MODEL,
        "cuota_agotada": _ESTADO_CUOTA["cuota_agotada"],
        "ultimo_error": _ESTADO_CUOTA["ultimo_error"],
        "fecha_alerta": _ESTADO_CUOTA["fecha_alerta"],
        "consultas_hoy": _ESTADO_CUOTA["consultas_hoy"],
        "limite_diario_usuario": LIMITE_DIARIO_USUARIO,
    }


def consultar_gemini(
    prompt: str,
    id_usuario: str = "anon",
    imagen_bytes: Optional[bytes] = None,
    mime_type: str = "image/jpeg",
    usar_cache: bool = True,
    system_instruction: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Envía una consulta (texto o texto + imagen) a Gemini API de forma segura.
    Retorna dict con {"ok": bool, "status": str, "texto": str, "desde_cache": bool}.
    """
    _resetear_si_nuevo_dia()
    api_key = os.getenv("GEMINI_API_KEY", GEMINI_API_KEY).strip()

    if not api_key:
        return {
            "ok": False,
            "status": "UNCONFIGURED",
            "texto": "La IA aún no está activada (falta configurar GEMINI_API_KEY en el servidor). Puedes seguir usando las guías rápidas y captura manual normalmente.",
            "desde_cache": False,
        }

    # Control de cuota diaria por usuario
    clave_usr = str(id_usuario or "anon").strip()
    usos_usr = _CONTEO_DIARIO.get(clave_usr, 0)
    if usos_usr >= LIMITE_DIARIO_USUARIO:
        return {
            "ok": False,
            "status": "RATE_LIMIT_USER",
            "texto": f"Has alcanzado tu límite preventivo diario de {LIMITE_DIARIO_USUARIO} consultas de IA. Inténtalo mañana o usa las guías rápidas.",
            "desde_cache": False,
        }

    # Caché en memoria (solo para texto sin imagen, TTL 6 horas)
    cache_key = None
    if usar_cache and not imagen_bytes:
        cache_key = hashlib.sha256(f"{system_instruction or ''}|{prompt.strip().lower()}".encode("utf-8")).hexdigest()
        cached = _CACHE_RESPUESTAS.get(cache_key)
        if cached and (time.time() - cached[0]) < 21600:
            return {"ok": True, "status": "OK", "texto": cached[1], "desde_cache": True}

    parts = [{"text": prompt}]
    if imagen_bytes:
        parts.append({
            "inline_data": {
                "mime_type": mime_type,
                "data": base64.b64encode(imagen_bytes).decode("ascii"),
            }
        })

    body: Dict[str, Any] = {
        "contents": [{"role": "user", "parts": parts}],
        "generationConfig": {"temperature": 0.2, "maxOutputTokens": 1024},
    }
    if system_instruction:
        body["systemInstruction"] = {"parts": [{"text": system_instruction}]}

    modelos_a_probar = []
    for m in GEMINI_FALLBACK_MODELS:
        if m and m not in modelos_a_probar:
            modelos_a_probar.append(m)

    ultimo_status = "API_ERROR"
    ultimo_msg = "No se pudo obtener respuesta de IA."

    for modelo_actual in modelos_a_probar:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{modelo_actual}:generateContent?key={api_key}"
        try:
            resp = requests.post(url, json=body, timeout=28)
            if resp.status_code == 429 or "RESOURCE_EXHAUSTED" in resp.text:
                _ESTADO_CUOTA["cuota_agotada"] = True
                _ESTADO_CUOTA["ultimo_error"] = "Cuota de Gemini API agotada (HTTP 429)."
                _ESTADO_CUOTA["fecha_alerta"] = datetime.datetime.now().isoformat(timespec="seconds")
                ultimo_status = "QUOTA_EXHAUSTED"
                ultimo_msg = "⚠️ La cuota de IA se ha agotado temporalmente. El sistema continúa operando en modo manual; avisa a Sistemas/Dirección."
                continue

            if resp.status_code in (404, 503):
                ultimo_status = "API_ERROR"
                ultimo_msg = f"Modelo {modelo_actual} no disponible temporalmente (HTTP {resp.status_code})."
                continue

            if not resp.ok:
                return {
                    "ok": False,
                    "status": "API_ERROR",
                    "texto": f"No se pudo obtener respuesta de IA (HTTP {resp.status_code}). Usa el modo manual mientras se restablece.",
                    "desde_cache": False,
                }

            data = resp.json()
            candidatos = data.get("candidates") or []
            texto_out = ""
            if candidatos:
                partes_out = (candidatos[0].get("content") or {}).get("parts") or []
                texto_out = "\n".join(p.get("text", "") for p in partes_out if p.get("text")).strip()

            if not texto_out:
                return {"ok": False, "status": "EMPTY", "texto": "La IA no devolvió contenido utilizable.", "desde_cache": False}

            _CONTEO_DIARIO[clave_usr] = usos_usr + 1
            _ESTADO_CUOTA["consultas_hoy"] += 1
            _ESTADO_CUOTA["cuota_agotada"] = False

            if cache_key:
                _CACHE_RESPUESTAS[cache_key] = (time.time(), texto_out)

            return {"ok": True, "status": "OK", "texto": texto_out, "desde_cache": False}
        except Exception as e:
            ultimo_status = "NETWORK_ERROR"
            ultimo_msg = f"Error de conexión con servicio de IA: {e}"
            continue

    return {
        "ok": False,
        "status": ultimo_status,
        "texto": ultimo_msg,
        "desde_cache": False,
    }
