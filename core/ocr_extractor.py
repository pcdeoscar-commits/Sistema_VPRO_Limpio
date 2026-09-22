"""
core/ocr_extractor.py
=====================
Motor de OCR + Extracción Inteligente de Campos para documentos mexicanos.
Utilizado por el módulo de Recursos Humanos VPRO.

Soporta:
  - INE / Credencial para Votar
  - CURP (constancia RENAPO)
  - NSS (tarjeta IMSS)
  - RFC (constancia SAT)
  - Acta de Nacimiento
  - Licencia de Conducir
  - Comprobante de Domicilio
  - Contrato
  - Otro (extracción genérica)

Flujo:
  1. imagen_bytes → preprocesar_imagen() → imagen mejorada
  2. imagen mejorada → ocr_leer_texto() → texto + bloques con confianza
  3. texto + tipo_doc → extraer_campos() → dict {campo: {valor, confianza}}
"""

import re
import io
import logging
from typing import Optional

logger = logging.getLogger(__name__)

# ── Constantes de confianza ───────────────────────────────────────────────────
CONFIANZA_ALTA  = "ALTA"    # >= 0.85
CONFIANZA_MEDIA = "MEDIA"   # 0.65 – 0.84
CONFIANZA_BAJA  = "BAJA"    # < 0.65

# ── Meses en español ──────────────────────────────────────────────────────────
MESES_ES = {
    "enero":1,"febrero":2,"marzo":3,"abril":4,"mayo":5,"junio":6,
    "julio":7,"agosto":8,"septiembre":9,"octubre":10,"noviembre":11,"diciembre":12,
    "ene":1,"feb":2,"mar":3,"abr":4,"jun":6,"jul":7,"ago":8,"sep":9,"oct":10,"nov":11,"dic":12
}

# ══════════════════════════════════════════════════════════════════════════════
# PREPROCESAMIENTO DE IMAGEN
# ══════════════════════════════════════════════════════════════════════════════

def preprocesar_imagen(imagen_bytes: bytes, formato: str = "JPG") -> bytes:
    """
    Mejora la imagen para OCR: escala de grises, contraste, nitidez.
    Retorna bytes de la imagen procesada en formato PNG.
    """
    try:
        from PIL import Image, ImageEnhance, ImageFilter
        import io as _io

        img = Image.open(_io.BytesIO(imagen_bytes))

        # Convertir a RGB si es necesario
        if img.mode not in ("RGB", "L"):
            img = img.convert("RGB")

        # Escalar si es muy pequeña (min 1200px de ancho para mejor OCR)
        w, h = img.size
        if w < 1200:
            factor = 1200 / w
            img = img.resize((int(w * factor), int(h * factor)), Image.LANCZOS)

        # Escala de grises
        img_gray = img.convert("L")

        # Mejorar contraste
        enhancer = ImageEnhance.Contrast(img_gray)
        img_contrast = enhancer.enhance(2.0)

        # Mejorar nitidez
        img_sharp = img_contrast.filter(ImageFilter.SHARPEN)

        # Guardar como PNG
        out = _io.BytesIO()
        img_sharp.save(out, format="PNG")
        return out.getvalue()

    except Exception as e:
        logger.warning(f"preprocesar_imagen: {e} — usando imagen original")
        return imagen_bytes


def pdf_a_imagen(pdf_bytes: bytes, pagina: int = 0) -> bytes:
    """
    Convierte una página de PDF a imagen PNG usando PyMuPDF.
    """
    try:
        import fitz  # PyMuPDF
        doc = fitz.open(stream=pdf_bytes, filetype="pdf")
        page = doc[pagina]
        # Renderizar a alta resolución (200 DPI)
        mat = fitz.Matrix(200/72, 200/72)
        pix = page.get_pixmap(matrix=mat)
        return pix.tobytes("png")
    except Exception as e:
        logger.error(f"pdf_a_imagen: {e}")
        raise RuntimeError(f"No se pudo convertir PDF a imagen: {e}")


# ══════════════════════════════════════════════════════════════════════════════
# MOTOR OCR
# ══════════════════════════════════════════════════════════════════════════════

# Instancia global de EasyOCR (se carga solo una vez)
_ocr_reader = None

def _get_ocr_reader():
    """Carga el lector EasyOCR en español + inglés (se cachea globalmente)."""
    global _ocr_reader
    if _ocr_reader is None:
        try:
            import easyocr
            logger.info("Cargando modelo EasyOCR (puede tardar la primera vez)...")
            _ocr_reader = easyocr.Reader(["es", "en"], gpu=False, verbose=False)
            logger.info("EasyOCR cargado correctamente.")
        except ImportError:
            raise RuntimeError("easyocr no instalado. Ejecuta: pip install easyocr")
    return _ocr_reader


def ocr_leer_texto(imagen_bytes: bytes) -> tuple[str, list]:
    """
    Aplica OCR a la imagen y retorna:
      - texto_completo: todo el texto concatenado
      - bloques: lista de (texto, confianza) para análisis de confianza
    """
    reader = _get_ocr_reader()
    resultados = reader.readtext(imagen_bytes, detail=1, paragraph=False)

    bloques = []
    lineas  = []
    for (_, texto, confianza) in resultados:
        texto = texto.strip()
        if texto:
            bloques.append({"texto": texto, "confianza": float(confianza)})
            lineas.append(texto)

    texto_completo = " ".join(lineas)
    return texto_completo, bloques


def _nivel_confianza(score: float) -> str:
    if score >= 0.85: return CONFIANZA_ALTA
    if score >= 0.65: return CONFIANZA_MEDIA
    return CONFIANZA_BAJA


# ══════════════════════════════════════════════════════════════════════════════
# PATRONES REGEX — DOCUMENTOS MEXICANOS
# ══════════════════════════════════════════════════════════════════════════════

# CURP: 18 caracteres
RE_CURP = re.compile(
    r'\b([A-Z]{4}\d{6}[HM][A-Z]{2}[A-Z]{3}[A-Z0-9]\d)\b',
    re.IGNORECASE
)

# RFC con homoclave: 12-13 caracteres
RE_RFC = re.compile(
    r'\b([A-ZÑ&]{3,4}\d{6}[A-Z0-9]{3})\b',
    re.IGNORECASE
)

# NSS IMSS: exactamente 11 dígitos
RE_NSS = re.compile(r'\b(\d{11})\b')

# Fechas: dd/mm/aaaa | dd-mm-aaaa | dd.mm.aaaa
RE_FECHA_SLASH = re.compile(
    r'\b(\d{1,2})[/\-\.](\d{1,2})[/\-\.](\d{4})\b'
)

# Fecha escrita: "12 de marzo de 1985"
RE_FECHA_ESCRITA = re.compile(
    r'\b(\d{1,2})\s+(?:de\s+)?('
    + '|'.join(MESES_ES.keys())
    + r')\s+(?:de\s+)?(\d{4})\b',
    re.IGNORECASE
)

# Año solo (para vencimiento de INE)
RE_ANIO = re.compile(r'\b(20\d{2})\b')

# Código Postal: 5 dígitos que no sean parte de un número mayor
RE_CP = re.compile(r'\bC\.?P\.?\s*(\d{5})\b', re.IGNORECASE)
RE_CP2 = re.compile(r'\b(\d{5})\b')

# Número de teléfono mexicano
RE_TEL = re.compile(r'\b(\d{2,3}[\s\-]?\d{3,4}[\s\-]?\d{4})\b')


# ══════════════════════════════════════════════════════════════════════════════
# UTILIDADES DE EXTRACCIÓN
# ══════════════════════════════════════════════════════════════════════════════

def _buscar_curp(texto: str) -> Optional[str]:
    m = RE_CURP.search(texto.upper())
    return m.group(1).upper() if m else None


def _buscar_rfc(texto: str) -> Optional[str]:
    """Busca RFC evitando confundirlo con CURP."""
    texto_u = texto.upper()
    m = RE_RFC.search(texto_u)
    if m:
        candidato = m.group(1)
        # Descartar si tiene 18 chars (sería CURP)
        if len(candidato) not in (12, 13):
            return None
        return candidato
    return None


def _buscar_nss(texto: str) -> Optional[str]:
    m = RE_NSS.search(texto)
    return m.group(1) if m else None


def _buscar_fecha(texto: str) -> Optional[str]:
    """Retorna primera fecha encontrada en formato DD/MM/AAAA."""
    # Intenta formato numérico primero
    m = RE_FECHA_SLASH.search(texto)
    if m:
        d, mo, a = m.group(1), m.group(2), m.group(3)
        return f"{int(d):02d}/{int(mo):02d}/{a}"

    # Intenta fecha escrita
    m2 = RE_FECHA_ESCRITA.search(texto.lower())
    if m2:
        d   = int(m2.group(1))
        mes = MESES_ES.get(m2.group(2).lower(), 0)
        a   = int(m2.group(3))
        if mes > 0:
            return f"{d:02d}/{mes:02d}/{a}"
    return None


def _buscar_todas_fechas(texto: str) -> list:
    """Retorna todas las fechas encontradas."""
    fechas = []
    for m in RE_FECHA_SLASH.finditer(texto):
        fechas.append(f"{int(m.group(1)):02d}/{int(m.group(2)):02d}/{m.group(3)}")
    for m in RE_FECHA_ESCRITA.finditer(texto.lower()):
        mes = MESES_ES.get(m.group(2).lower(), 0)
        if mes:
            fechas.append(f"{int(m.group(1)):02d}/{mes:02d}/{m.group(3)}")
    return fechas


def _buscar_cp(texto: str) -> Optional[str]:
    m = RE_CP.search(texto)
    if m: return m.group(1)
    # Buscar secuencia de 5 dígitos que inicie con 0-9 (CP México: 01000-99999)
    for m2 in RE_CP2.finditer(texto):
        cp = m2.group(1)
        if 1000 <= int(cp) <= 99999:
            return cp
    return None


def _extraer_nombre_de_bloques(bloques: list, keywords_previas: list) -> Optional[str]:
    """
    Busca el bloque de texto que sigue a una de las keywords en la lista.
    Ej: después de "NOMBRE" o "APELLIDO PATERNO" → tomar el siguiente bloque de texto.
    """
    textos = [b["texto"].upper() for b in bloques]
    for i, t in enumerate(textos):
        for kw in keywords_previas:
            if kw.upper() in t:
                # Tomar los siguientes 3 bloques como nombre
                partes = []
                for j in range(i + 1, min(i + 4, len(textos))):
                    siguiente = bloques[j]["texto"].strip()
                    # Si es un keyword de otro campo, parar
                    if any(k in siguiente.upper() for k in ["DOMICILIO","DIRECCIÓN","CALLE","CURP","RFC","NSS"]):
                        break
                    # Filtrar números y caracteres raros
                    if re.match(r'^[A-ZÁÉÍÓÚÜÑ\s]+$', siguiente, re.IGNORECASE):
                        partes.append(siguiente)
                if partes:
                    return " ".join(partes).title()
    return None


def _promedio_confianza(bloques: list, texto_objetivo: str) -> float:
    """Retorna la confianza promedio de los bloques que contienen el texto buscado."""
    matches = [b["confianza"] for b in bloques
               if texto_objetivo.lower() in b["texto"].lower()]
    return sum(matches) / len(matches) if matches else 0.75


# ══════════════════════════════════════════════════════════════════════════════
# EXTRACTORES POR TIPO DE DOCUMENTO
# ══════════════════════════════════════════════════════════════════════════════

def _extraer_ine(texto: str, bloques: list) -> dict:
    """Extrae campos de INE / Credencial para Votar."""
    campos = {}

    curp = _buscar_curp(texto)
    if curp:
        campos["curp"] = {"valor": curp, "confianza": CONFIANZA_ALTA, "campo_db": "empleados.curp"}

    # Nombre — busca después de NOMBRE/APELLIDO PATERNO
    nombre = _extraer_nombre_de_bloques(bloques, ["NOMBRE","APELLIDO PATERNO","NOMBRES"])
    if nombre:
        campos["nombre"] = {"valor": nombre, "confianza": CONFIANZA_MEDIA, "campo_db": "empleados.nombre"}

    # Fechas — la primera es nacimiento, la última suele ser vencimiento
    fechas = _buscar_todas_fechas(texto)
    if fechas:
        campos["fecha_nacimiento"] = {"valor": fechas[0], "confianza": CONFIANZA_ALTA, "campo_db": "empleados.fecha_nac"}
    if len(fechas) > 1:
        campos["vencimiento"] = {"valor": fechas[-1], "confianza": CONFIANZA_ALTA, "campo_db": "rh_documentos.fecha_vencimiento"}

    # Domicilio — busca después de DOMICILIO o CALLE
    for i, b in enumerate(bloques):
        if any(kw in b["texto"].upper() for kw in ["DOMICILIO","CALLE","DIREC"]):
            partes = []
            for j in range(i, min(i + 5, len(bloques))):
                t = bloques[j]["texto"].strip()
                if re.match(r'.*(CLAVE|FOLIO|SECCION|MUNICIPIO|CURP).*', t.upper()):
                    break
                partes.append(t)
            if partes:
                dom = " ".join(partes).strip("DOMICILIO:").strip()
                campos["domicilio"] = {"valor": dom, "confianza": CONFIANZA_MEDIA, "campo_db": "empleados.domicilio"}
            break

    # CP
    cp = _buscar_cp(texto)
    if cp:
        campos["cp"] = {"valor": cp, "confianza": CONFIANZA_MEDIA, "campo_db": "empleados.cp"}

    return campos


def _extraer_curp(texto: str, bloques: list) -> dict:
    """Extrae campos de constancia CURP."""
    campos = {}

    curp = _buscar_curp(texto)
    if curp:
        campos["curp"] = {"valor": curp, "confianza": CONFIANZA_ALTA, "campo_db": "empleados.curp"}

    nombre = _extraer_nombre_de_bloques(bloques,
        ["NOMBRE(S)","PRIMER APELLIDO","NOMBRE","APELLIDO"])
    if nombre:
        campos["nombre"] = {"valor": nombre, "confianza": CONFIANZA_MEDIA, "campo_db": "empleados.nombre"}

    fechas = _buscar_todas_fechas(texto)
    if fechas:
        campos["fecha_nacimiento"] = {"valor": fechas[0], "confianza": CONFIANZA_ALTA, "campo_db": "empleados.fecha_nac"}

    return campos


def _extraer_nss(texto: str, bloques: list) -> dict:
    """Extrae campos de tarjeta NSS del IMSS."""
    campos = {}

    nss = _buscar_nss(texto)
    if nss:
        campos["nss"] = {"valor": nss, "confianza": CONFIANZA_ALTA, "campo_db": "empleados.nss"}

    nombre = _extraer_nombre_de_bloques(bloques, ["NOMBRE","ASEGURADO","TRABAJADOR"])
    if nombre:
        campos["nombre"] = {"valor": nombre, "confianza": CONFIANZA_MEDIA, "campo_db": "empleados.nombre"}

    return campos


def _extraer_rfc(texto: str, bloques: list) -> dict:
    """Extrae campos de constancia RFC del SAT."""
    campos = {}

    rfc = _buscar_rfc(texto)
    if rfc:
        campos["rfc"] = {"valor": rfc, "confianza": CONFIANZA_ALTA, "campo_db": "empleados.rfc"}

    nombre = _extraer_nombre_de_bloques(bloques, ["NOMBRE","DENOMINACIÓN","RAZÓN SOCIAL"])
    if nombre:
        campos["nombre"] = {"valor": nombre, "confianza": CONFIANZA_MEDIA, "campo_db": "empleados.nombre"}

    # Domicilio fiscal
    for i, b in enumerate(bloques):
        if "DOMICILIO" in b["texto"].upper() or "FISCAL" in b["texto"].upper():
            partes = []
            for j in range(i + 1, min(i + 6, len(bloques))):
                t = bloques[j]["texto"].strip()
                if "CP" in t.upper() or re.match(r'^\d{5}$', t):
                    partes.append(t)
                    break
                partes.append(t)
            if partes:
                campos["domicilio"] = {
                    "valor": " ".join(partes),
                    "confianza": CONFIANZA_MEDIA,
                    "campo_db": "empleados.domicilio"
                }
            break

    cp = _buscar_cp(texto)
    if cp:
        campos["cp"] = {"valor": cp, "confianza": CONFIANZA_ALTA, "campo_db": "empleados.cp"}

    return campos


def _extraer_acta_nacimiento(texto: str, bloques: list) -> dict:
    """Extrae campos de Acta de Nacimiento."""
    campos = {}

    nombre = _extraer_nombre_de_bloques(bloques,
        ["NOMBRE","REGISTRADO","NACIDO","MENOR"])
    if nombre:
        campos["nombre"] = {"valor": nombre, "confianza": CONFIANZA_MEDIA, "campo_db": "empleados.nombre"}

    fechas = _buscar_todas_fechas(texto)
    if fechas:
        campos["fecha_nacimiento"] = {"valor": fechas[0], "confianza": CONFIANZA_ALTA, "campo_db": "empleados.fecha_nac"}

    # Ciudad/municipio
    for b in bloques:
        t = b["texto"].upper()
        if any(kw in t for kw in ["MUNICIPIO","CIUDAD","LOCALIDAD"]):
            campos["ciudad"] = {"valor": b["texto"], "confianza": CONFIANZA_BAJA, "campo_db": "empleados.ciudad"}
            break

    return campos


def _extraer_licencia(texto: str, bloques: list) -> dict:
    """Extrae campos de Licencia de Conducir."""
    campos = {}

    nombre = _extraer_nombre_de_bloques(bloques, ["NOMBRE","APELLIDOS","TITULAR"])
    if nombre:
        campos["nombre"] = {"valor": nombre, "confianza": CONFIANZA_MEDIA, "campo_db": "empleados.nombre"}

    curp = _buscar_curp(texto)
    if curp:
        campos["curp"] = {"valor": curp, "confianza": CONFIANZA_ALTA, "campo_db": "empleados.curp"}

    fechas = _buscar_todas_fechas(texto)
    if fechas:
        # El vencimiento suele ser la última fecha
        campos["vencimiento"] = {"valor": fechas[-1], "confianza": CONFIANZA_ALTA, "campo_db": "empleados.licencia_vence"}
        if len(fechas) > 1:
            campos["fecha_nacimiento"] = {"valor": fechas[0], "confianza": CONFIANZA_MEDIA, "campo_db": "empleados.fecha_nac"}

    dom = _extraer_nombre_de_bloques(bloques, ["DOMICILIO","DIRECCIÓN","CALLE"])
    if dom:
        campos["domicilio"] = {"valor": dom, "confianza": CONFIANZA_BAJA, "campo_db": "empleados.domicilio"}

    return campos


def _extraer_comprobante_domicilio(texto: str, bloques: list) -> dict:
    """Extrae campos de Comprobante de Domicilio."""
    campos = {}

    nombre = _extraer_nombre_de_bloques(bloques, ["NOMBRE","TITULAR","CLIENTE","A NOMBRE DE"])
    if nombre:
        campos["nombre"] = {"valor": nombre, "confianza": CONFIANZA_MEDIA, "campo_db": "empleados.nombre"}

    # Domicilio completo
    for i, b in enumerate(bloques):
        if any(kw in b["texto"].upper() for kw in ["CALLE","AV.","AVENIDA","BLVD","BOULEVARD"]):
            partes = [b["texto"]]
            for j in range(i + 1, min(i + 5, len(bloques))):
                t = bloques[j]["texto"]
                if re.match(r'^\d{5}$', t) or "FECHA" in t.upper():
                    break
                partes.append(t)
            campos["domicilio"] = {
                "valor": " ".join(partes),
                "confianza": CONFIANZA_MEDIA,
                "campo_db": "empleados.domicilio"
            }
            break

    cp = _buscar_cp(texto)
    if cp:
        campos["cp"] = {"valor": cp, "confianza": CONFIANZA_ALTA, "campo_db": "empleados.cp"}

    return campos


def _extraer_generico(texto: str, bloques: list) -> dict:
    """Extracción genérica: busca CURP, RFC, NSS, fechas en cualquier documento."""
    campos = {}

    curp = _buscar_curp(texto)
    if curp:
        campos["curp"] = {"valor": curp, "confianza": CONFIANZA_ALTA, "campo_db": "empleados.curp"}

    rfc = _buscar_rfc(texto)
    if rfc:
        campos["rfc"] = {"valor": rfc, "confianza": CONFIANZA_ALTA, "campo_db": "empleados.rfc"}

    nss = _buscar_nss(texto)
    if nss:
        campos["nss"] = {"valor": nss, "confianza": CONFIANZA_ALTA, "campo_db": "empleados.nss"}

    fechas = _buscar_todas_fechas(texto)
    if fechas:
        campos["fecha_detectada"] = {"valor": fechas[0], "confianza": CONFIANZA_MEDIA, "campo_db": "—"}

    return campos


# ══════════════════════════════════════════════════════════════════════════════
# FUNCIÓN PRINCIPAL — PUNTO DE ENTRADA
# ══════════════════════════════════════════════════════════════════════════════

EXTRACTORES = {
    "INE":                     _extraer_ine,
    "CURP":                    _extraer_curp,
    "NSS":                     _extraer_nss,
    "RFC":                     _extraer_rfc,
    "ACTA NACIMIENTO":         _extraer_acta_nacimiento,
    "LICENCIA CONDUCIR":       _extraer_licencia,
    "COMPROBANTE DOMICILIO":   _extraer_comprobante_domicilio,
}


def procesar_documento_ocr(
    imagen_bytes: bytes,
    tipo_documento: str,
    es_pdf: bool = False,
    pagina_pdf: int = 0
) -> dict:
    """
    Función principal del módulo OCR.

    Parámetros:
        imagen_bytes    : bytes de la imagen o PDF
        tipo_documento  : tipo de documento (INE, CURP, NSS, RFC, etc.)
        es_pdf          : True si el archivo es PDF
        pagina_pdf      : número de página a procesar (0-indexed)

    Retorna dict con:
        {
            "campos_extraidos": { campo: {valor, confianza, campo_db} },
            "texto_completo": str,
            "total_campos": int,
            "exito": bool,
            "error": str | None
        }
    """
    try:
        # 1. Si es PDF, convertir a imagen
        if es_pdf:
            imagen_bytes = pdf_a_imagen(imagen_bytes, pagina_pdf)

        # 2. Preprocesar imagen para mejorar OCR
        imagen_procesada = preprocesar_imagen(imagen_bytes)

        # 3. Aplicar OCR
        texto_completo, bloques = ocr_leer_texto(imagen_procesada)

        if not texto_completo.strip():
            return {
                "campos_extraidos": {},
                "texto_completo": "",
                "total_campos": 0,
                "exito": False,
                "error": "No se detectó texto en la imagen. Verifica que el documento sea legible."
            }

        # 4. Extraer campos por tipo de documento
        tipo_upper = tipo_documento.upper().strip()
        extractor = EXTRACTORES.get(tipo_upper, _extraer_generico)
        campos = extractor(texto_completo, bloques)

        # 5. Agregar confianza global
        confianza_global = sum(
            0.85 if c["confianza"] == CONFIANZA_ALTA
            else 0.75 if c["confianza"] == CONFIANZA_MEDIA
            else 0.55
            for c in campos.values()
        ) / max(len(campos), 1)

        return {
            "campos_extraidos": campos,
            "texto_completo": texto_completo,
            "total_campos": len(campos),
            "confianza_global": round(confianza_global, 2),
            "exito": True,
            "error": None
        }

    except Exception as e:
        logger.error(f"procesar_documento_ocr: {e}")
        return {
            "campos_extraidos": {},
            "texto_completo": "",
            "total_campos": 0,
            "confianza_global": 0.0,
            "exito": False,
            "error": str(e)
        }

