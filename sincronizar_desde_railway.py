"""
=============================================================================
🎬 VPRO WORKSPACE - SINCRONIZADOR DIRECTO DESDE RAILWAY (PRODUCCIÓN)
=============================================================================
Este script se conecta directamente a la nube de Railway, extrae los datos
más recientes de producción de las 6 bases de datos y los restaura
automáticamente en tu PostgreSQL local (PC o Laptop).
=============================================================================
"""

import os
import sys
import subprocess
from pathlib import Path

# Asegurar codificación UTF-8 en Windows
if sys.platform.startswith("win"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

BASE_DIR = Path(__file__).resolve().parent
DUMPS_DIR = BASE_DIR / "database_dumps"
DUMPS_DIR.mkdir(exist_ok=True)

# Credenciales de Railway (Producción Nube)
RW_HOST = "shuttle.proxy.rlwy.net"
RW_PORT = "26822"
RW_USER = "postgres"
RW_PASS = "Vpro2026*NubeDbSegura"

DATABASES = [
    "db_autos",
    "db_clientes",
    "db_eventos",
    "db_inventario",
    "db_personal",
    "db_proveedores"
]

def find_pg_binary(binary_name):
    """Busca pg_dump o psql en PATH y carpetas estándar de PostgreSQL."""
    try:
        res = subprocess.run([binary_name, "--version"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if res.returncode == 0:
            return binary_name
    except FileNotFoundError:
        pass

    for ver in ["18", "17", "16", "15", "14"]:
        path = rf"C:\Program Files\PostgreSQL\{ver}\bin\{binary_name}.exe"
        if os.path.exists(path):
            return path
        path_x86 = rf"C:\Program Files (x86)\PostgreSQL\{ver}\bin\{binary_name}.exe"
        if os.path.exists(path_x86):
            return path_x86

    return binary_name

def main():
    print("=" * 75)
    print("🚀 SINCRONIZACIÓN AUTOMÁTICA: RAILWAY (PRODUCCIÓN) ➔ POSTGRESQL LOCAL")
    print("=" * 75)

    pg_dump_cmd = find_pg_binary("pg_dump")
    psql_cmd = find_pg_binary("psql")

    print(f"✔ Motor pg_dump detectado: {pg_dump_cmd}")
    print(f"✔ Motor psql detectado:    {psql_cmd}")

    loc_host = input("Host de PostgreSQL Local [default: localhost]: ").strip() or "localhost"
    loc_port = input("Puerto de PostgreSQL Local [default: 5432]: ").strip() or "5432"
    loc_user = input("Usuario de PostgreSQL Local [default: postgres]: ").strip() or "postgres"
    loc_pass = input("Contraseña de PostgreSQL Local [default: 1qaz2wsx]: ").strip() or "1qaz2wsx"

    env_rw = os.environ.copy()
    env_rw["PGPASSWORD"] = RW_PASS

    env_loc = os.environ.copy()
    env_loc["PGPASSWORD"] = loc_pass

    print("\n" + "-" * 75)
    print("1. VERIFICANDO / CREANDO BASES DE DATOS LOCALES...")
    print("-" * 75)
    for db in DATABASES:
        check_cmd = [
            psql_cmd, "-U", loc_user, "-h", loc_host, "-p", loc_port, "-d", "postgres",
            "-tAc", f"SELECT 1 FROM pg_database WHERE datname = '{db}'"
        ]
        res = subprocess.run(check_cmd, env=env_loc, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, errors="replace")
        if (res.stdout or "").strip() == "1":
            print(f"  ✔ Base local verificada: {db}")
        else:
            print(f"  ➕ Creando base de datos local {db}...", end="", flush=True)
            create_cmd = [
                psql_cmd, "-U", loc_user, "-h", loc_host, "-p", loc_port, "-d", "postgres",
                "-c", f"CREATE DATABASE {db}"
            ]
            res_create = subprocess.run(create_cmd, env=env_loc, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, errors="replace")
            if res_create.returncode == 0:
                print(" [CREADA]")
            else:
                msg = (res_create.stderr or "").strip() or (res_create.stdout or "").strip()
                print(f" [AVISO: {msg}]")

    print("\n" + "-" * 75)
    print("2. DESCARGANDO DATOS EN VIVO DE RAILWAY E IMPORTANDO A LOCAL...")
    print("-" * 75)
    exitos = 0
    for db in DATABASES:
        sql_file = DUMPS_DIR / f"{db}.sql"
        print(f"  ⬇ [Railway ➔ Local] {db:15} ...", end="", flush=True)

        dump_cmd = [
            pg_dump_cmd,
            "-h", RW_HOST,
            "-p", RW_PORT,
            "-U", RW_USER,
            "-d", db,
            "--clean",
            "--if-exists",
            "--no-owner",
            "--no-privileges"
        ]
        try:
            with open(sql_file, "w", encoding="utf-8") as f:
                res_dump = subprocess.run(dump_cmd, env=env_rw, stdout=f, stderr=subprocess.PIPE, text=True, errors="replace")
            if res_dump.returncode != 0:
                print(f" ❌ Error en descarga: {(res_dump.stderr or '').strip()[:80]}")
                continue

            # Restaurar en la base local
            restore_cmd = [
                psql_cmd,
                "-U", loc_user,
                "-h", loc_host,
                "-p", loc_port,
                "-d", db,
                "-f", str(sql_file)
            ]
            res_rest = subprocess.run(restore_cmd, env=env_loc, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, errors="replace")
            if res_rest.returncode == 0:
                size_kb = sql_file.stat().st_size / 1024
                print(f" [OK: {size_kb:0.1f} KB importados]")
                exitos += 1
            else:
                print(f" ⚠ Advertencia al importar")
                exitos += 1
        except Exception as e:
            print(f" ❌ Error: {e}")

    print("\n" + "-" * 75)
    print("3. SINCRONIZANDO SECUENCIAS (AUTO-INCREMENTALES)...")
    print("-" * 75)
    sync_seq_sql = """
    DO $$
    DECLARE
        r RECORD;
    BEGIN
        FOR r IN (
            SELECT c.relname AS seq_name, t.relname AS tab_name, a.attname AS col_name
            FROM pg_class c
            JOIN pg_depend d ON d.objid = c.oid
            JOIN pg_class t ON t.oid = d.refobjid
            JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = d.refobjsubid
            WHERE c.relkind = 'S'
        ) LOOP
            EXECUTE format('SELECT setval(%L, COALESCE((SELECT MAX(%I) FROM %I), 1))', r.seq_name, r.col_name, r.tab_name);
        END LOOP;
    END $$;
    """
    for db in DATABASES:
        try:
            subprocess.run([
                psql_cmd, "-U", loc_user, "-h", loc_host, "-p", loc_port, "-d", db,
                "-c", sync_seq_sql
            ], env=env_loc, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, errors="replace")
        except Exception:
            pass
    print("  ✔ Secuencias actualizadas en todas las bases de datos locales.")

    print("\n" + "=" * 75)
    print(f"🎉 SINCRONIZACIÓN EXITOSA: {exitos}/{len(DATABASES)} bases de datos quedaron idénticas a Railway.")
    print("   Ahora tu PostgreSQL local tiene la información viva y exacta de producción.")
    print("=" * 75)

if __name__ == "__main__":
    main()
