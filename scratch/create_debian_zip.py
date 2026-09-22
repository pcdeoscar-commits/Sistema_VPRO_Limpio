import os, subprocess, shutil, zipfile

DB_USER = 'postgres'
DB_PASS = '1qaz2wsx'
PG_DUMP = r'C:\Program Files\PostgreSQL\18\bin\pg_dump.exe'
DBS = ['db_personal_prueba', 'db_eventos_prueba', 'db_inventario_prueba', 'db_clientes_prueba', 'db_autos_prueba', 'db_proveedores_prueba']
RELEASE_DIR = 'VPRO_Release_Debian'

if os.path.exists(RELEASE_DIR):
    shutil.rmtree(RELEASE_DIR)
os.makedirs(os.path.join(RELEASE_DIR, 'database_dumps'), exist_ok=True)
os.makedirs(os.path.join(RELEASE_DIR, 'deploy_scripts'), exist_ok=True)

print('1. Exporting databases (Plain text for Debian psql)...')
env = os.environ.copy()
env['PGPASSWORD'] = DB_PASS

for db in DBS:
    dump_file = os.path.join(RELEASE_DIR, 'database_dumps', f'{db}.sql')
    cmd = [PG_DUMP, '-U', DB_USER, '-h', 'localhost', '-d', db, '-F', 'p', '-f', dump_file]
    try:
        subprocess.run(cmd, env=env, check=True)
    except Exception as e:
        print(f'Error dumping {db}: {e}')

print('2. Copying system files...')
dirs_to_copy = ['core', 'modulos_prueba', 'routers', 'Fotos_de_equipos', 'Fotos_de_personal']
files_to_copy = ['api_core_prueba.py', 'app_main_prueba.py', 'cert.pem', 'key.pem', 'requirements.txt']

for d in dirs_to_copy:
    dest = os.path.join(RELEASE_DIR, d)
    if os.path.exists(d):
        shutil.copytree(d, dest, ignore=shutil.ignore_patterns('__pycache__', '*.pyc', '.agents', '.git'))

for f in files_to_copy:
    if os.path.exists(f):
        shutil.copy2(f, RELEASE_DIR)

print('3. Generating Debian Deploy Scripts & config...')
env_content = '''# CONFIGURACION PARA PRODUCCION VPRO (Debian Linux)
# Servidor de Base de Datos (Debian 13)
DB_HOST=172.16.0.8
DB_PORT=5432
DB_USER=postgres
DB_PASS=1qaz2wsx

# Servidor del Sistema (Debian 12)
API_URL=https://172.16.0.10:8000
'''
with open(os.path.join(RELEASE_DIR, '.env'), 'w', encoding='utf-8') as f:
    f.write(env_content)

setup_db_sh = '''#!/bin/bash
# Script de instalacion para Servidor DB (Debian 13 - 172.16.0.8)
echo "Restaurando BBDD en PostgreSQL 18.4..."
DBS=("db_personal_prueba" "db_eventos_prueba" "db_inventario_prueba" "db_clientes_prueba" "db_autos_prueba" "db_proveedores_prueba")
for db in "${DBS[@]}"; do
    echo "Procesando $db..."
    sudo -u postgres psql -c "CREATE DATABASE $db LC_COLLATE 'es_MX.UTF-8' LC_CTYPE 'es_MX.UTF-8';"
    sudo -u postgres psql -d $db -f "database_dumps/$db.sql"
done
echo "Restauración completa."
'''
with open(os.path.join(RELEASE_DIR, 'deploy_scripts', 'setup_db.sh'), 'w', encoding='utf-8', newline='\n') as f:
    f.write(setup_db_sh)

vpro_backend_service = '''[Unit]
Description=VPRO Backend FastAPI
After=network.target

[Service]
User=root
WorkingDirectory=/opt/VPRO_Dashboard
ExecStart=/opt/VPRO_Dashboard/venv/bin/python -m uvicorn api_core_prueba:app --host 172.16.0.10 --port 8000 --ssl-certfile cert.pem --ssl-keyfile key.pem
Restart=always

[Install]
WantedBy=multi-user.target
'''
with open(os.path.join(RELEASE_DIR, 'deploy_scripts', 'vpro-backend.service'), 'w', encoding='utf-8', newline='\n') as f:
    f.write(vpro_backend_service)

vpro_frontend_service = '''[Unit]
Description=VPRO Frontend Streamlit
After=network.target

[Service]
User=root
WorkingDirectory=/opt/VPRO_Dashboard
ExecStart=/opt/VPRO_Dashboard/venv/bin/python -m streamlit run app_main_prueba.py --server.port 8520 --server.address 172.16.0.10
Restart=always

[Install]
WantedBy=multi-user.target
'''
with open(os.path.join(RELEASE_DIR, 'deploy_scripts', 'vpro-frontend.service'), 'w', encoding='utf-8', newline='\n') as f:
    f.write(vpro_frontend_service)

setup_app_sh = '''#!/bin/bash
# Script de instalacion para Servidor Sistema (Debian 12 - 172.16.0.10)
echo "Configurando entorno de Python e instalando dependencias..."
sudo apt-get update && sudo apt-get install -y python3-venv python3-pip
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

echo "Instalando servicios Systemd..."
sudo cp deploy_scripts/vpro-backend.service /etc/systemd/system/
sudo cp deploy_scripts/vpro-frontend.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable vpro-backend
sudo systemctl enable vpro-frontend
echo "Puedes iniciarlos con: sudo systemctl start vpro-backend && sudo systemctl start vpro-frontend"
'''
with open(os.path.join(RELEASE_DIR, 'deploy_scripts', 'setup_app.sh'), 'w', encoding='utf-8', newline='\n') as f:
    f.write(setup_app_sh)

print('4. Zipping Debian optimized release...')
zip_filename = 'VPRO_Sistema_Completo_Debian.zip'
if os.path.exists(zip_filename):
    os.remove(zip_filename)

with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk(RELEASE_DIR):
        for file in files:
            file_path = os.path.join(root, file)
            zipf.write(file_path, arcname=os.path.relpath(file_path, RELEASE_DIR))

print(f'Done! {zip_filename} created successfully.')

