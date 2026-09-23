import os
import shutil
import zipfile

ZIP_NAME = "actualizaciones_Sistema_230926.zip"
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.abspath(os.path.join(BASE_DIR, ".."))

files_to_pack = [
    # Frontend
    ("app_main_prueba.py", "app_main_prueba.py"),
    ("app_main_prueba.py", "app_main.py"),  # Compatibilidad si en el server se llama app_main.py
    ("modulos_prueba/mod_kiosco.py", "modulos_prueba/mod_kiosco.py"),
    ("modulos_prueba/mod_reporte_asistencia.py", "modulos_prueba/mod_reporte_asistencia.py"),
    
    # Backend
    ("api_core_prueba.py", "api_core_prueba.py"),
    ("api_core_prueba.py", "api_core.py"),  # Compatibilidad si en el server se llama api_core.py
    ("routers/eventos.py", "routers/eventos.py"),
    ("routers/asistencia.py", "routers/asistencia.py"),
]

zip_path = os.path.join(PROJECT_DIR, ZIP_NAME)
if os.path.exists(zip_path):
    os.remove(zip_path)

with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
    for src_rel, arc_name in files_to_pack:
        src_full = os.path.join(PROJECT_DIR, src_rel)
        if os.path.exists(src_full):
            zf.write(src_full, arcname=arc_name)
            print(f"Agregado: {arc_name}")
        else:
            print(f"ADVERTENCIA: No se encontro {src_full}")

print(f"\n¡Archivo ZIP creado exitosamente en: {zip_path}")

