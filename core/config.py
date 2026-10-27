import os
import shutil
from pathlib import Path
from urllib.parse import urlparse

# Directorio base del proyecto
BASE_DIR = Path(__file__).resolve().parent.parent

# Cargar variables desde .env si existe localmente
env_path = BASE_DIR / ".env"
if env_path.exists():
    try:
        from dotenv import load_dotenv
        load_dotenv(env_path)
    except ImportError:
        pass

# 🔌 Configuración de Base de Datos PostgreSQL
# Soporta tanto Railway (DATABASE_URL / PGHOST) como el entorno local (.20 o intranet)
DATABASE_URL = os.getenv("DATABASE_URL")

if DATABASE_URL:
    url = urlparse(DATABASE_URL)
    DB_USER = url.username or "postgres"
    DB_PASS = url.password or "1qaz2wsx"
    DB_HOST = url.hostname or "localhost"
    DB_PORT = str(url.port or 5432)
else:
    # Prioridad: Variables Railway (PG*) -> Variables Personalizadas (DB_*) -> Valores locales por defecto (.20)
    DB_USER = os.getenv("PGUSER") or os.getenv("DB_USER", "postgres")
    DB_PASS = os.getenv("PGPASSWORD") or os.getenv("DB_PASS", "1qaz2wsx")
    DB_HOST = os.getenv("PGHOST") or os.getenv("DB_HOST", "localhost")
    DB_PORT = os.getenv("PGPORT") or os.getenv("DB_PORT", "5432")

# Puerto y URL del Backend API
PORT = int(os.getenv("PORT", "8521"))
API_URL = os.getenv("API_URL", f"http://localhost:{PORT}")

# 📁 Carpetas de Recursos y Evidencias
# DATA_DIR permite montar un volumen persistente en Railway (/data o similar) sin perder fotos al desplegar
DATA_DIR = Path(os.getenv("DATA_DIR", BASE_DIR))
FOTOS_EQUIPOS_DIR = DATA_DIR / "Fotos_de_equipos"
FOTOS_PERSONAL_DIR = DATA_DIR / "Fotos_de_personal"
FOTOS_EVENTOS_DIR = DATA_DIR / "Fotos_de_eventos"
DIR_EVIDENCIAS_REAL = str(FOTOS_EQUIPOS_DIR)

# Asegurar que existan los directorios clave
FOTOS_EQUIPOS_DIR.mkdir(parents=True, exist_ok=True)
FOTOS_PERSONAL_DIR.mkdir(parents=True, exist_ok=True)
FOTOS_EVENTOS_DIR.mkdir(parents=True, exist_ok=True)

# Si se montó un volumen persistente externo (ej. /vpro-datos),
# sembramos los archivos base del repositorio para que no queden vacías las fotos de personal o equipos.
if DATA_DIR.resolve() != BASE_DIR.resolve():
    for folder_name in ["Fotos_de_equipos", "Fotos_de_personal", "Fotos_de_eventos"]:
        src_folder = BASE_DIR / folder_name
        dst_folder = DATA_DIR / folder_name
        if src_folder.exists() and src_folder.is_dir():
            for item in src_folder.iterdir():
                target_item = dst_folder / item.name
                if not target_item.exists():
                    try:
                        if item.is_file():
                            shutil.copy2(item, target_item)
                        elif item.is_dir():
                            shutil.copytree(item, target_item, dirs_exist_ok=True)
                    except Exception as e:
                        print(f"⚠️ Error al migrar {item.name} al volumen persistente: {e}")

# Orígenes Permitidos para CORS
CORS_ORIGINS = [
    "https://172.16.0.20:8520",
    "https://localhost:8520",
    "http://localhost:8520",
    "http://172.16.0.20:8520",
    "http://localhost:8521",
    "http://172.16.0.20:8521",
    "*"
]


