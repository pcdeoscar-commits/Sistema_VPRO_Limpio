@echo off
chcp 65001 > nul
title VPRO ERP - Paso 3: Iniciar Sistema

echo =====================================================================
echo 🎬 VPRO WORKSPACE ERP - INICIANDO SISTEMA COMPLETO
echo =====================================================================
echo.

set PY_CMD=python
if exist "venv\Scripts\activate.bat" (
    set ACTIVATE=call venv\Scripts\activate.bat ^&^&
) else (
    set ACTIVATE=
)

echo [1/1] Iniciando Servidor Unificado VPRO ERP (Backend + Frontend Web) en el puerto 8521...
start "VPRO Workspace ERP (Puerto 8521)" cmd /k "%ACTIVATE% python -m uvicorn api_core:app --host 0.0.0.0 --port 8521 --reload"

echo.
echo Esperando 3 segundos a que el servidor inicialice...
timeout /t 3 > nul

echo Abriendo navegador en http://localhost:8521 ...
start http://localhost:8521

echo.
echo =====================================================================
echo 🚀 VPRO WORKSPACE ESTÁ EN LÍNEA EN EL PUERTO 8521:
echo ---------------------------------------------------------------------
echo • Frontend Web (Dashboard):  http://localhost:8521
echo • Acceso en Red Local (LAN): http://172.16.0.20:8521
echo • Backend API (Swagger UI):  http://localhost:8521/docs
echo • Salud del Servidor:        http://localhost:8521/health
echo =====================================================================
echo.
echo Deja la ventana de comando abierta mientras utilices el sistema.
echo Para cerrar todo, puedes ejecutar '4_detener_sistema.bat'.
echo.
pause
