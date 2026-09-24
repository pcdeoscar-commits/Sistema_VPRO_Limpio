import os
import subprocess
import shutil
import zipfile
import datetime

DB_USER = "postgres"
DB_PASS = "1qaz2wsx"
PG_DUMP = r"C:\Program Files\PostgreSQL\18\bin\pg_dump.exe"
DBS = [
    "db_personal_prueba",
    "db_eventos_prueba",
    "db_inventario_prueba",
    "db_clientes_prueba",
    "db_autos_prueba",
    "db_proveedores_prueba"
]

BASE_DIR = r"c:\Users\cuauhtemoc\Desktop\Curso_de_Python\Graficos\VPRO_Dashboard_V2_TODO_NUEVO"
DUMP_DIR = os.path.join(BASE_DIR, "database_dumps")
os.makedirs(DUMP_DIR, exist_ok=True)

print("1. Generando respaldos frescos de las 6 bases de datos PostgreSQL...")
env = os.environ.copy()
env["PGPASSWORD"] = DB_PASS

for db in DBS:
    dump_file = os.path.join(DUMP_DIR, f"{db}.sql")
    cmd = [PG_DUMP, "-U", DB_USER, "-h", "localhost", "-d", db, "-F", "p", "-f", dump_file]
    try:
        subprocess.run(cmd, env=env, check=True)
        size_kb = os.path.getsize(dump_file) / 1024
        print(f"  -> Dump {db}.sql completado ({size_kb:.1f} KB)")
    except Exception as e:
        print(f"  -> Error al respaldar {db}: {e}")

# Sincronizar archivos espejo para despliegue en Linux
print("2. Sincronizando scripts principales...")
shutil.copy2(os.path.join(BASE_DIR, "api_core_prueba.py"), os.path.join(BASE_DIR, "api_core.py"))
shutil.copy2(os.path.join(BASE_DIR, "app_main_prueba.py"), os.path.join(BASE_DIR, "app_main.py"))

# Crear paquete ZIP
ZIP_NAME = "VPRO_Respaldo_Integral_Sistema.zip"
zip_path = os.path.join(BASE_DIR, ZIP_NAME)
if os.path.exists(zip_path):
    os.remove(zip_path)

print(f"3. Creando archivo comprimido {ZIP_NAME}...")
carpetas_a_incluir = [
    "core",
    "modulos_prueba",
    "routers",
    "database_dumps",
    "deploy_scripts",
    "Fotos_de_equipos",
    "Fotos_de_personal",
    "prueba_web"
]

archivos_raiz = [
    ".env",
    "api_core.py",
    "api_core_prueba.py",
    "app_main.py",
    "app_main_prueba.py",
    "cert.pem",
    "key.pem",
    "requirements.txt"
]

total_archivos = 0
with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zipf:
    # Agregar archivos de la raíz
    for f in archivos_raiz:
        f_path = os.path.join(BASE_DIR, f)
        if os.path.exists(f_path):
            zipf.write(f_path, arcname=f)
            total_archivos += 1

    # Agregar carpetas excluyendo __pycache__ y temporales
    for carpeta in carpetas_a_incluir:
        dir_path = os.path.join(BASE_DIR, carpeta)
        if not os.path.exists(dir_path):
            continue
        for root, dirs, files in os.walk(dir_path):
            if "__pycache__" in root or ".git" in root:
                continue
            for file in files:
                if file.endswith(".pyc"):
                    continue
                file_full = os.path.join(root, file)
                rel_path = os.path.relpath(file_full, BASE_DIR)
                zipf.write(file_full, arcname=rel_path)
                total_archivos += 1

zip_mb = os.path.getsize(zip_path) / (1024 * 1024)
print(f"¡Éxito! Respaldo creado con {total_archivos} archivos ({zip_mb:.2f} MB)")
print(f"Ubicación: {zip_path}")

