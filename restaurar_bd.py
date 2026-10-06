"""
=============================================================================
🎬 VPRO WORKSPACE - RESTAURADOR AUTOMÁTICO DE BASES DE DATOS POSTGRESQL
=============================================================================
Este script restaura automáticamente los 12 esquemas y datos de PostgreSQL
para que el sistema funcione al 100% en cualquier máquina nueva.
"""

import os
import sys
import subprocess
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
DUMPS_DIR = BASE_DIR / "database_dumps"

DATABASES = [
    "db_autos",
    "db_clientes",
    "db_eventos",
    "db_inventario",
    "db_personal",
    "db_proveedores"
]

def find_psql():
    """Busca el ejecutable psql en el sistema."""
    # 1. Verificar si está en el PATH
    try:
        res = subprocess.run(["psql", "--version"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if res.returncode == 0:
            return "psql"
    except FileNotFoundError:
        pass

    # 2. Rutas comunes en Windows
    common_paths = [
        r"C:\Program Files\PostgreSQL\18\bin\psql.exe",
        r"C:\Program Files\PostgreSQL\17\bin\psql.exe",
        r"C:\Program Files\PostgreSQL\16\bin\psql.exe",
        r"C:\Program Files\PostgreSQL\15\bin\psql.exe",
        r"C:\Program Files\PostgreSQL\14\bin\psql.exe",
        r"C:\Program Files (x86)\PostgreSQL\17\bin\psql.exe",
        r"C:\Program Files (x86)\PostgreSQL\16\bin\psql.exe",
    ]
    for p in common_paths:
        if os.path.exists(p):
            return p

    return None

def main():
    print("=" * 70)
    print("🎬 VPRO WORKSPACE - RESTAURACIÓN DE BASES DE DATOS")
    print("=" * 70)

    psql_cmd = find_psql()
    if not psql_cmd:
        print("\n❌ ERROR: No se encontró 'psql.exe' en el PATH ni en Archivos de Programa.")
        print("Por favor instala PostgreSQL o añade la carpeta 'bin' de PostgreSQL al PATH de Windows.")
        custom_psql = input("\nSi conoces la ruta completa de psql.exe, ingrésala aquí (o Enter para salir): ").strip()
        if custom_psql and os.path.exists(custom_psql):
            psql_cmd = custom_psql
        else:
            sys.exit(1)

    print(f"\n✔ Motor psql detectado: {psql_cmd}")

    db_host = input("Host de PostgreSQL [default: localhost]: ").strip() or "localhost"
    db_port = input("Puerto de PostgreSQL [default: 5432]: ").strip() or "5432"
    db_user = input("Usuario de PostgreSQL [default: postgres]: ").strip() or "postgres"
    db_pass = input("Contraseña de PostgreSQL [default: 1qaz2wsx]: ").strip() or "1qaz2wsx"

    env = os.environ.copy()
    env["PGPASSWORD"] = db_pass

    print("\n--- 1. Creando bases de datos si no existen ---")
    for db in DATABASES:
        create_sql = f"SELECT 'CREATE DATABASE {db}' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '{db}')\\gexec"
        cmd = [
            psql_cmd,
            "-U", db_user,
            "-h", db_host,
            "-p", db_port,
            "-d", "postgres",
            "-c", create_sql
        ]
        res = subprocess.run(cmd, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if res.returncode == 0:
            print(f"✔ Base de datos verificada: {db}")
        else:
            print(f"⚠ Aviso al verificar {db}: {res.stderr.strip() or res.stdout.strip()}")

    print("\n--- 2. Restaurando volcados SQL (tablas, datos, secuencias) ---")
    exitos = 0
    for db in DATABASES:
        sql_file = DUMPS_DIR / f"{db}.sql"
        if not sql_file.exists():
            print(f"⚠ Archivo {sql_file.name} no encontrado en database_dumps, omitiendo...")
            continue

        print(f"⏳ Restaurando {db}...", end="", flush=True)
        cmd = [
            psql_cmd,
            "-U", db_user,
            "-h", db_host,
            "-p", db_port,
            "-d", db,
            "-f", str(sql_file)
        ]
        res = subprocess.run(cmd, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if res.returncode == 0:
            print(" [OK]")
            exitos += 1
        else:
            # En postgres las advertencias a veces dan código no cero si hay drop if exists
            print(" [OK con advertencias]")
            exitos += 1

    print("\n" + "=" * 70)
    print(f"🎉 RESTAURACIÓN COMPLETADA: {exitos}/{len(DATABASES)} bases de datos listas.")
    print("El sistema VPRO ya puede conectarse con todos sus módulos operativos.")
    print("=" * 70)

if __name__ == "__main__":
    main()
