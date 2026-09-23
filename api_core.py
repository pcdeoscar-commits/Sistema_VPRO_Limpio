"""
🎬 VPRO SYSTEM - BACKEND CORE API ENGINE
Motor central unificado refactorizado bajo arquitectura modular FastAPI con Piloto Automático de Asistencias.
"""

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from core.config import (
    CORS_ORIGINS, 
    FOTOS_EQUIPOS_DIR, 
    DIR_EVIDENCIAS_REAL
)
from core.scheduler import init_scheduler, shutdown_scheduler

# Exportaciones para compatibilidad retroactiva
from core.database import (
    get_db_connection, get_db_cursor,
    engine_autos, engine_autos,
    engine_eventos, engine_eventos,
    engine_personal, engine_personal,
    engine_clientes, engine_clientes,
    engine_inventario, engine_inventario,
    engine_proveedores, engine_proveedores
)
from core.security import verificar_password, encriptar_password
from core.utils import safe_decode_hex, reparar_mojibake

# Importación de Routers Modulares
from routers import (
    auth,
    asistencia,
    eventos,
    checkout,
    inventario,
    gastos,
    empleados,
    clientes,
    proveedores,
    autos,
    incidencias,
    reuniones,
    dashboard,
    rh
)

# 🔄 CICLO DE VIDA DE LA APLICACIÓN (Lifespan Context Manager)
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Inicio: Arrancar el scheduler en segundo plano
    init_scheduler()
    yield
    # Apagado: Detener el scheduler limpiamente
    shutdown_scheduler()

# 1️⃣ INICIALIZACIÓN DE FASTAPI
app = FastAPI(
    title="🎬 VPRO Core API Engine",
    description="Motor central unificado con arquitectura modular y Piloto Automático de Asistencias.",
    version="8.1.0",
    lifespan=lifespan
)

# 2️⃣ CONFIGURACIÓN DE SEGURIDAD (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 3️⃣ MONTAJE DE DIRECTORIOS ESTÁTICOS
app.mount("/Fotos_de_equipos", StaticFiles(directory=str(FOTOS_EQUIPOS_DIR)), name="fotos")
app.mount("/evidencias_web", StaticFiles(directory=str(DIR_EVIDENCIAS_REAL)), name="evidencias")

# 4️⃣ REGISTRO DE ROUTERS MODULARES
app.include_router(auth.router)
app.include_router(asistencia.router)
app.include_router(eventos.router)
app.include_router(checkout.router)
app.include_router(inventario.router)
app.include_router(gastos.router)
app.include_router(empleados.router)
app.include_router(clientes.router)
app.include_router(proveedores.router)
app.include_router(autos.router)
app.include_router(incidencias.router)
app.include_router(reuniones.router)
app.include_router(dashboard.router)
app.include_router(rh.router)

@app.get("/health", tags=["Sistema"])
def health_check():
    """Endpoint de verificación de salud del sistema."""
    return {"status": "ONLINE", "service": "VPRO Core API Engine", "version": "8.1.0"}