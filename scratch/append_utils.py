import os

content = """
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
"""

with open('modulos_prueba/utils_frontend.py', 'a', encoding='utf-8') as f:
    f.write('\n' + content)

