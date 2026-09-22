"""
Utilidades compartidas para módulos de frontend (Streamlit).
Centraliza parsing de fechas, deserialización de listas de PostgreSQL,
búsqueda segura de índices y codificación base64 de recursos estáticos.
"""
import os
import base64
from datetime import date
from typing import Any, List, Optional
import pandas as pd


def parse_fecha(fecha_str: Any) -> Optional[date]:
    """Convierte fechas en cadena o timestamp a datetime.date para Streamlit.
    
    Retorna None si la fecha es nula, vacía o inválida.
    """
    if pd.isna(fecha_str) or str(fecha_str).strip() in ["", "None", "nan", "null"]:
        return None
    try:
        return pd.to_datetime(fecha_str).date()
    except Exception:
        return None


def get_idx(lista: list, valor: Any) -> int:
    """Busca el índice de un valor en una lista para componentes st.selectbox.
    
    Si el valor no se encuentra o es inválido, retorna 0 (primer elemento por defecto).
    """
    if not lista:
        return 0
    try:
        return lista.index(str(valor).upper() if isinstance(valor, str) else valor)
    except Exception:
        return 0


def parsed_array(val: Any) -> List[str]:
    """Auxiliar para limpiar listas que vienen de PostgreSQL como texto '{a,b,c}' o listas nativas."""
    if isinstance(val, list):
        return [str(x).strip() for x in val if x is not None and str(x).strip()]
    if not val:
        return []
    s = str(val).strip()
    if s.startswith("{") and s.endswith("}"):
        s = s[1:-1]
    if not s:
        return []
    import csv, io
    try:
        reader = csv.reader(io.StringIO(s), delimiter=',', quotechar='"')
        items = next(reader)
        return [x.strip().strip("'") for x in items if x.strip()]
    except Exception:
        return [
            x.strip().strip('"').strip("'")
            for x in s.split(",")
            if x.strip()
        ]


def get_base64_of_bin_file(bin_file: str) -> str:
    """Lee un archivo binario y lo codifica en base64 para incrustar en HTML/Streamlit."""
    if os.path.exists(bin_file):
        try:
            with open(bin_file, "rb") as f:
                return base64.b64encode(f.read()).decode("utf-8")
        except Exception:
            return ""
    return ""



import requests

def _get(api_url, endpoint, params=None):
    try:
        r = requests.get(f"{api_url}{endpoint}", params=params, verify=False, timeout=5)
        return r.json() if r.status_code == 200 else None
    except Exception as e:
        print(f"⚠️ SILENCED ERROR in utils_frontend.py (_get): {e}")
        return None

def _post(api_url, endpoint, payload):
    try:
        r = requests.post(f"{api_url}{endpoint}", json=payload, verify=False, timeout=10)
        return r.status_code, r.json() if r.text else {}
    except Exception as e:
        print(f"⚠️ SILENCED ERROR in utils_frontend.py (_post): {e}")
        return 500, {}

def _put(api_url, endpoint, payload):
    try:
        r = requests.put(f"{api_url}{endpoint}", json=payload, verify=False, timeout=10)
        return r.status_code, r.json() if r.text else {}
    except Exception as e:
        print(f"⚠️ SILENCED ERROR in utils_frontend.py (_put): {e}")
        return 500, {}

def _delete(api_url, endpoint):
    try:
        r = requests.delete(f"{api_url}{endpoint}", verify=False, timeout=10)
        return r.status_code, r.json() if r.text else {}
    except Exception as e:
        print(f"⚠️ SILENCED ERROR in utils_frontend.py (_delete): {e}")
        return 500, {}

def _badge(texto, color):
    return f"<span style='background-color:{color};color:#fff;padding:2px 8px;border-radius:12px;font-size:0.8rem;white-space:nowrap;'>{texto}</span>"

def _color_estatus(estatus):
    e = str(estatus).upper()
    if e in ['ACTIVO', 'VIGENTE', 'APROBADO', 'COMPLETO', 'PAGADO', 'CERRADO']: return '#10b981'
    if e in ['BAJA', 'VENCIDO', 'RECHAZADO', 'CANCELADO', 'DEFICIENTE']: return '#ef4444'
    if e in ['SUSPENDIDO', 'PENDIENTE', 'REVISIÓN', 'PROCESO', 'REGULAR']: return '#f59e0b'
    if e in ['VACACIONES', 'EXCELENTE', 'BUENO']: return '#3b82f6'
    return '#6b7280'
