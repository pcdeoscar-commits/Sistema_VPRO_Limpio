@echo off
chcp 65001 > nul
title VPRO ERP - Frontend Streamlit

echo =====================================================================
echo 🎬 VPRO WORKSPACE ERP - INICIANDO FRONTEND STREAMLIT
echo =====================================================================
echo.

if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
)

echo Iniciando Streamlit en el puerto 8520...
streamlit run app_main_prueba.py --server.port 8520
pause
