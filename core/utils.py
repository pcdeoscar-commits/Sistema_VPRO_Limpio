import datetime
from typing import Any, Dict

def reparar_mojibake(texto: Any) -> str:
    """Detecta y repara texto corrupto por doble codificación UTF-8 / Latin-1."""
    if not texto:
        return ""
    str_texto = str(texto)
    
    for _ in range(2):
        if any(c in str_texto for c in ['Ã', 'Â', 'ï', '½', '±']):
            try:
                str_texto = str_texto.encode('latin-1', errors='ignore').decode('utf-8', errors='ignore')
            except Exception:
                break
                
    return str_texto.replace('Â', '').strip()

def safe_decode_hex(hex_str: Any) -> str:
    """Decodifica cadenas hexadecimales provenientes de PostgreSQL con prioridad UTF-8 y limpieza de mojibake."""
    if not hex_str:
        return ""
    s = str(hex_str).strip()
    try:
        raw = bytes.fromhex(s)
    except Exception:
        return reparar_mojibake(s)

    try:
        txt = raw.decode("utf-8").strip()
        return reparar_mojibake(txt)
    except UnicodeDecodeError:
        try:
            txt = raw.decode("latin-1").strip()
            return reparar_mojibake(txt)
        except Exception:
            return reparar_mojibake(s)
    except Exception:
        return reparar_mojibake(s)

def serialize_row_dates(row_dict: Dict[str, Any]) -> Dict[str, Any]:
    """Convierte objetos de fecha/hora de un diccionario a string para serialización JSON."""
    d = dict(row_dict)
    for k, v in d.items():
        if isinstance(v, (datetime.date, datetime.time, datetime.datetime)):
            d[k] = str(v)
    return d


def parse_pg_array(val: Any) -> list:
    """Limpia y deserializa arrays de PostgreSQL representados como lista nativa o string '{a,b}'."""
    if isinstance(val, list):
        return [str(x).strip() for x in val if str(x).strip()]
    if not val:
        return []
    return [
        x.strip().strip('"').strip("'")
        for x in str(val).replace("{", "").replace("}", "").split(",")
        if x.strip()
    ]


def obtener_feriados_mexico(anio: int) -> Dict[datetime.date, str]:
    """Retorna los días de descanso obligatorio oficiales en México (Ley Federal del Trabajo, Art. 74)."""
    feriados = {}
    
    # 1 de enero - Año Nuevo
    feriados[datetime.date(anio, 1, 1)] = "Año Nuevo"
    
    # Primer lunes de febrero en conmemoración del 5 de febrero (Día de la Constitución)
    feb1 = datetime.date(anio, 2, 1)
    offset_feb = (0 - feb1.weekday()) % 7
    feriados[feb1 + datetime.timedelta(days=offset_feb)] = "Día de la Constitución"
    
    # Tercer lunes de marzo en conmemoración del 21 de marzo (Natalicio de Benito Juárez)
    mar1 = datetime.date(anio, 3, 1)
    offset_mar = (0 - mar1.weekday()) % 7
    feriados[mar1 + datetime.timedelta(days=offset_mar + 14)] = "Natalicio de Benito Juárez"
    
    # 1 de mayo - Día del Trabajo
    feriados[datetime.date(anio, 5, 1)] = "Día del Trabajo"
    
    # 16 de septiembre - Día de la Independencia
    feriados[datetime.date(anio, 9, 16)] = "Día de la Independencia"
    
    # Tercer lunes de noviembre en conmemoración del 20 de noviembre (Revolución Mexicana)
    nov1 = datetime.date(anio, 1, 1).replace(month=11)
    offset_nov = (0 - nov1.weekday()) % 7
    feriados[nov1 + datetime.timedelta(days=offset_nov + 14)] = "Revolución Mexicana"
    
    # 1 de octubre cada 6 años (Transmisión del Poder Ejecutivo Federal - reforma 2024)
    if (anio - 2024) % 6 == 0:
        feriados[datetime.date(anio, 10, 1)] = "Transmisión del Poder Ejecutivo Federal"
        
    # 25 de diciembre - Navidad
    feriados[datetime.date(anio, 12, 25)] = "Navidad"
    
    return feriados


def es_feriado_mexico(fecha: Any) -> tuple:
    """Verifica si una fecha dada es día de descanso obligatorio en México.
    Retorna (True, 'Nombre del Feriado') o (False, '')
    """
    if not fecha:
        return False, ""
    try:
        if isinstance(fecha, str):
            f_obj = datetime.date.fromisoformat(fecha[:10])
        elif isinstance(fecha, datetime.datetime):
            f_obj = fecha.date()
        elif isinstance(fecha, datetime.date):
            f_obj = fecha
        else:
            return False, ""
            
        feriados = obtener_feriados_mexico(f_obj.year)
        if f_obj in feriados:
            return True, feriados[f_obj]
        return False, ""
    except Exception:
        return False, ""


