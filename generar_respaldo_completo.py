import os
import sys
import time
import zipfile
import subprocess
from pathlib import Path
from datetime import datetime

# Asegurar codificación UTF-8 en consola de Windows
if sys.platform.startswith("win"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

BASE_DIR = Path(__file__).resolve().parent
DUMPS_DIR = BASE_DIR / "database_dumps"
DUMPS_DIR.mkdir(exist_ok=True)

DATABASES = [
    "db_autos",
    "db_clientes",
    "db_eventos",
    "db_inventario",
    "db_personal",
    "db_proveedores"
]

def find_pg_dump():
    for p in [
        "pg_dump",
        r"C:\Program Files\PostgreSQL\18\bin\pg_dump.exe",
        r"C:\Program Files\PostgreSQL\17\bin\pg_dump.exe",
        r"C:\Program Files\PostgreSQL\16\bin\pg_dump.exe",
        r"C:\Program Files\PostgreSQL\15\bin\pg_dump.exe",
        r"C:\Program Files (x86)\PostgreSQL\17\bin\pg_dump.exe",
        r"C:\Program Files (x86)\PostgreSQL\16\bin\pg_dump.exe",
    ]:
        try:
            res = subprocess.run([p, "--version"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            if res.returncode == 0:
                return p
        except Exception:
            pass
    return None

def volcar_bases_de_datos(pg_dump_cmd):
    print("=" * 70)
    print("1. VOLCANDO BASES DE DATOS DE POSTGRESQL (DATOS EN VIVO)")
    print("=" * 70)
    
    env = os.environ.copy()
    env["PGPASSWORD"] = "1qaz2wsx"
    
    for db in DATABASES:
        out_file = DUMPS_DIR / f"{db}.sql"
        cmd = [pg_dump_cmd, "-U", "postgres", "-h", "localhost", "-p", "5432", "--clean", "--if-exists", db]
        try:
            with open(out_file, "w", encoding="utf-8") as f:
                res = subprocess.run(cmd, env=env, stdout=f, stderr=subprocess.PIPE, text=True)
            if res.returncode == 0:
                size_kb = out_file.stat().st_size / 1024
                print(f"  ✔ {db:15} -> {out_file.name} ({size_kb:7.1f} KB)")
            else:
                print(f"  ❌ Error en {db}: {res.stderr.strip()}")
        except Exception as e:
            print(f"  ❌ Excepción al volcar {db}: {e}")

def empaquetar_zip(fecha_str):
    zip_name = f"VPRO_RESPALDO_COMPLETO_{fecha_str}.zip"
    zip_path = BASE_DIR / zip_name
    
    print("\n" + "=" * 70)
    print(f"2. EMPAQUETANDO TODO EL ENTORNO EN: {zip_name}")
    print("=" * 70)
    
    # Carpetas y archivos a ignorar para no inflar innecesariamente el zip
    IGNORAR_CARPETAS = {"venv", ".venv", "__pycache__", ".pytest_cache", ".idea", "backups"}
    IGNORAR_EXT = {".pyc", ".pyo"}
    
    archivos_incluidos = 0
    bytes_totales = 0
    t0 = time.time()
    
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as zip_f:
        for root, dirs, files in os.walk(BASE_DIR):
            # Filtrar carpetas ignoradas in-place
            dirs[:] = [d for d in dirs if d not in IGNORAR_CARPETAS]
            
            for file in files:
                # Evitar incluir archivos de respaldo zip existentes dentro del nuevo zip
                if file.startswith("VPRO_RESPALDO_COMPLETO_") and file.endswith(".zip"):
                    continue
                ext = os.path.splitext(file)[1].lower()
                if ext in IGNORAR_EXT:
                    continue
                
                full_path = Path(root) / file
                rel_path = full_path.relative_to(BASE_DIR)
                
                try:
                    zip_f.write(full_path, arcname=str(rel_path))
                    archivos_incluidos += 1
                    bytes_totales += full_path.stat().st_size
                except Exception as e:
                    print(f"  ⚠️ Error agregando {rel_path}: {e}")
                    
    duracion = time.time() - t0
    zip_size_mb = zip_path.stat().st_size / (1024 * 1024)
    descomprimido_mb = bytes_totales / (1024 * 1024)
    
    print(f"\n🎉 ¡RESPALDO GENERADO CON ÉXITO!")
    print(f"   • Archivo de salida:     {zip_name}")
    print(f"   • Ubicación física:      {zip_path}")
    print(f"   • Archivos incluidos:    {archivos_incluidos:,}")
    print(f"   • Tamaño comprimido:     {zip_size_mb:.1f} MB")
    print(f"   • Tamaño descomprimido:  {descomprimido_mb:.1f} MB")
    print(f"   • Tiempo transcurrido:   {duracion:.1f} segundos")
    print("=" * 70)
    return zip_path

def main():
    pg_dump = find_pg_dump()
    if not pg_dump:
        print("❌ Error: No se encontró 'pg_dump.exe' para exportar la base de datos.")
        sys.exit(1)
        
    print(f"✔ Utilizando motor: {pg_dump}\n")
    volcar_bases_de_datos(pg_dump)
    
    fecha_hoy = datetime.now().strftime("%Y%m%d")
    empaquetar_zip(fecha_hoy)

if __name__ == "__main__":
    main()
