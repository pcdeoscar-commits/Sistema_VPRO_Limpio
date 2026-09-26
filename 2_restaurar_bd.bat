@echo off
chcp 65001 > nul
title VPRO ERP - Paso 2: Restauración de Bases de Datos

echo =====================================================================
echo 🎬 VPRO WORKSPACE ERP - RESTAURACIÓN DE BASES DE DATOS POSTGRESQL
echo =====================================================================
echo.

if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
    python restaurar_bd.py
) else (
    python restaurar_bd.py
)

echo.
pause
