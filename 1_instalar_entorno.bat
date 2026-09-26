@echo off
chcp 65001 > nul
title VPRO ERP - Paso 1: Instalación de Entorno

echo =====================================================================
echo 🎬 VPRO WORKSPACE ERP - INSTALACIÓN DE ENTORNO VIRTUAL Y DEPENDENCIAS
echo =====================================================================
echo.

where python >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] No se encontró Python instalado en este equipo o no está en el PATH.
    echo Por favor descarga e instala Python 3.10 o superior desde https://www.python.org/
    echo Asegúrate de marcar la casilla "Add Python to PATH" durante la instalación.
    echo.
    pause
    exit /b 1
)

echo [1/3] Verificando versión de Python...
python --version
echo.

echo [2/3] Creando entorno virtual (venv)...
if not exist "venv" (
    python -m venv venv
    echo Entorno virtual creado exitosamente.
) else (
    echo El entorno virtual 'venv' ya existe.
)
echo.

echo [3/3] Instalando dependencias de Python...
call venv\Scripts\activate.bat
python -m pip install --upgrade pip
pip install -r requirements.txt
echo.

echo =====================================================================
echo 🎉 ENTORNO INSTALADO CON ÉXITO.
echo Siguiente paso: Ejecuta '2_restaurar_bd.bat' para cargar las bases de datos.
echo =====================================================================
echo.
pause
