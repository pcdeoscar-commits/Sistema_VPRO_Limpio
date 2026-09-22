import os
from pathlib import Path

# Directorio base del proyecto
BASE_DIR = Path(__file__).resolve().parent.parent

# Configuración de Base de Datos PostgreSQL
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASS = os.getenv("DB_PASS", "1qaz2wsx")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")

# URL del Backend API
API_URL = os.getenv("API_URL", "https://172.16.0.20:8000")

# Carpetas de Recursos y Evidencias
FOTOS_EQUIPOS_DIR = BASE_DIR / "Fotos_de_equipos"
FOTOS_PERSONAL_DIR = BASE_DIR / "Fotos_de_personal"
DIR_EVIDENCIAS_REAL = str(FOTOS_EQUIPOS_DIR)

# Asegurar que existan los directorios clave
FOTOS_EQUIPOS_DIR.mkdir(parents=True, exist_ok=True)
FOTOS_PERSONAL_DIR.mkdir(parents=True, exist_ok=True)

# Orígenes Permitidos para CORS
CORS_ORIGINS = [
    "https://172.16.0.20:8520",
    "https://localhost:8520",
    "http://localhost:8520",
    "http://172.16.0.20:8520",
]

