import io
import json
import re
from typing import Optional
from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from pydantic import BaseModel
from sqlalchemy import text

from core.ai_client import consultar_gemini, obtener_estado_ia, VPRO_CONTEXTO_SISTEMA
from core.database import engine_eventos

router = APIRouter(prefix="/api/ia", tags=["🤖 Inteligencia Artificial VPRO"])


class PreguntaIAPayload(BaseModel):
    pregunta: str
    modulo_actual: Optional[str] = "vista-inicio"
    rol: Optional[str] = "PRODUCCION"
    id_empleado: Optional[str] = "anon"


def _comprimir_imagen_para_ia(raw_bytes: bytes, max_dim: int = 1280) -> tuple[bytes, str]:
    """Redimensiona y comprime imágenes con Pillow antes de enviarlas a Visión IA (ahorra ~60% de tokens)."""
    try:
        from PIL import Image
        img = Image.open(io.BytesIO(raw_bytes))
        if img.mode not in ("RGB", "L"):
            img = img.convert("RGB")
        w, h = img.size
        if max(w, h) > max_dim:
            ratio = max_dim / float(max(w, h))
            img = img.resize((int(w * ratio), int(h * ratio)), Image.LANCZOS)
        out = io.BytesIO()
        img.save(out, format="JPEG", quality=80, optimize=True)
        return out.getvalue(), "image/jpeg"
    except Exception:
        return raw_bytes, "image/jpeg"


def _extraer_json_limpio(texto: str) -> dict:
    """Extrae un bloque JSON de la respuesta de Gemini aunque venga envuelto en ```json ... ```."""
    limpio = re.sub(r"^```(?:json)?\s*|\s*```$", "", texto.strip(), flags=re.IGNORECASE | re.MULTILINE).strip()
    try:
        return json.loads(limpio)
    except Exception:
        m = re.search(r"\{.*\}", limpio, flags=re.DOTALL)
        if m:
            try:
                return json.loads(m.group(0))
            except Exception:
                pass
    return {}


@router.get("/estado")
def consultar_estado_servicio_ia():
    """Retorna si la IA está habilitada, consultas del día y si hubo alerta de cuota."""
    return obtener_estado_ia()


@router.post("/asistente")
def preguntar_copiloto_vpro(payload: PreguntaIAPayload):
    """Copiloto operativo que responde dudas de uso y reglas de negocio de VPRO."""
    pregunta = (payload.pregunta or "").strip()
    if not pregunta:
        raise HTTPException(status_code=400, detail="Escribe una pregunta para el asistente.")

    prompt = (
        f"Usuario con rol '{payload.rol}' actualmente en la pantalla '{payload.modulo_actual}'.\n"
        f"Pregunta: {pregunta}\n"
        f"Responde de manera directa, práctica y en máximo 5 líneas o viñetas claras."
    )
    resp = consultar_gemini(
        prompt=prompt,
        id_usuario=payload.id_empleado or "anon",
        usar_cache=True,
        system_instruction=VPRO_CONTEXTO_SISTEMA,
    )
    return resp


@router.post("/leer-ticket")
async def leer_ticket_gastos_ia(
    archivo: UploadFile = File(...),
    id_empleado: str = Form("anon"),
):
    """Extrae fecha, comercio, RFC, concepto, subtotal, IVA y total de una foto de ticket o factura."""
    raw = await archivo.read()
    if not raw:
        raise HTTPException(status_code=400, detail="Archivo vacío.")

    img_bytes, mime = _comprimir_imagen_para_ia(raw)
    prompt = (
        "Analiza este ticket o factura mexicana y extrae los datos en JSON estricto con estas claves exactas:\n"
        '{"comercio": "", "rfc": "", "fecha": "YYYY-MM-DD", "concepto": "", '
        '"categoria": "COMBUSTIBLE|CASETAS|ALIMENTOS|HOSPEDAJE|MATERIAL|OTRO", '
        '"subtotal": 0.0, "iva": 0.0, "total": 0.0}\n'
        "Responde únicamente con el JSON válido sin texto adicional."
    )
    resp = consultar_gemini(
        prompt=prompt,
        id_usuario=id_empleado,
        imagen_bytes=img_bytes,
        mime_type=mime,
        usar_cache=False,
    )
    datos = _extraer_json_limpio(resp["texto"]) if resp["ok"] else {}
    return {
        "ok": resp["ok"],
        "status": resp["status"],
        "mensaje": resp["texto"] if not resp["ok"] else "Ticket analizado correctamente.",
        "datos": datos,
    }


@router.post("/resumen-op/{id_evento}")
def generar_resumen_ejecutivo_op(id_evento: int, id_empleado: str = "admin"):
    """Compila los datos de la OP y sus mensajes de chat para generar un resumen ejecutivo automático."""
    try:
        with engine_eventos.connect() as conn:
            ev = conn.execute(text("""
                SELECT id_evento, COALESCE(folio, id_evento::text) AS folio, nombre_evento,
                       para_q_cliente, locacion, fec_del_evento, fec_fin_evento, resp_de_produccion
                FROM public.eventos
                WHERE id_evento = :id
            """), {"id": id_evento}).mappings().first()

            if not ev:
                raise HTTPException(status_code=404, detail="Orden de Producción no encontrada.")

            msgs = conn.execute(text("""
                SELECT autor, mensaje, fecha_envio
                FROM public.chat_op_mensajes
                WHERE id_evento = :id
                ORDER BY id_mensaje ASC
                LIMIT 80
            """), {"id": id_evento}).mappings().all()

        historial_txt = "\n".join(
            f"- {m.get('autor', 'Sistema')}: {m.get('mensaje', '')}"
            for m in msgs if (m.get("mensaje") or "").strip()
        ) or "Sin mensajes registrados en el chat de la OP."

        prompt = (
            f"Genera un resumen ejecutivo breve (1 párrafo de síntesis + máximo 3 viñetas de incidencias o acuerdos clave) "
            f"para Dirección sobre la OP-{ev['folio']} ({ev['nombre_evento']} - Cliente: {ev['para_q_cliente']}, "
            f"Locación: {ev['locacion']}, Fechas: {ev['fec_del_evento']} al {ev['fec_fin_evento']}, "
            f"Productor: {ev['resp_de_produccion']}).\n\n"
            f"Bitácora de mensajes:\n{historial_txt}"
        )
        resp = consultar_gemini(
            prompt=prompt,
            id_usuario=id_empleado,
            usar_cache=False,
            system_instruction="Eres analista ejecutivo de operaciones en VPRO. Sé objetivo, concreto y claro.",
        )
        return {
            "ok": resp["ok"],
            "status": resp["status"],
            "folio": ev["folio"],
            "resumen": resp["texto"],
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/ocr-documento")
async def ocr_multimodal_documento_rrhh(
    archivo: UploadFile = File(...),
    tipo_documento: str = Form("INE"),
    id_empleado: str = Form("rrhh"),
):
    """Lee documentos oficiales de RRHH (INE, Licencia, CURP, RFC) usando Visión IA."""
    raw = await archivo.read()
    if not raw:
        raise HTTPException(status_code=400, detail="Archivo vacío.")

    img_bytes, mime = _comprimir_imagen_para_ia(raw)
    prompt = (
        f"Lee este documento mexicano de tipo '{tipo_documento}' y extrae los datos visibles en JSON estricto:\n"
        '{"nombre_completo": "", "curp": "", "rfc": "", "nss": "", "clave_elector_o_licencia": "", '
        '"fecha_nacimiento": "YYYY-MM-DD", "vigencia": "YYYY-MM-DD", "domicilio": ""}\n'
        "Deja vacío lo que no sea visible. Responde únicamente con JSON válido."
    )
    resp = consultar_gemini(
        prompt=prompt,
        id_usuario=id_empleado,
        imagen_bytes=img_bytes,
        mime_type=mime,
        usar_cache=False,
    )
    datos = _extraer_json_limpio(resp["texto"]) if resp["ok"] else {}
    return {
        "ok": resp["ok"],
        "status": resp["status"],
        "mensaje": resp["texto"] if not resp["ok"] else "Documento leído con Visión IA.",
        "datos": datos,
    }
