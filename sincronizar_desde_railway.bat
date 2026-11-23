@echo off
chcp 65001 > nul
title VPRO ERP - Sincronizar desde Railway (Producción)

echo =====================================================================
echo 🚀 VPRO WORKSPACE - SINCRONIZAR DESDE RAILWAY A POSTGRES LOCAL
echo =====================================================================
echo.

if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
    python sincronizar_desde_railway.py
) else (
    python sincronizar_desde_railway.py
)

echo.
pause
