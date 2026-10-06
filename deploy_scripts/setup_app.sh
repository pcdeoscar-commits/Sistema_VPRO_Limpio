#!/bin/bash
# ==============================================================================
# VPRO WORKSPACE ERP - INSTALACIÓN EN SERVIDOR DE APLICACIÓN
# Servidor: Debian 12 (bookworm) @ IP: 172.16.0.10
# ==============================================================================

set -e

echo "======================================================================"
echo "🎬 VPRO WORKSPACE ERP - INSTALADOR PARA DEBIAN 12 (BOOKWORM)"
echo "======================================================================"
echo ""

APP_DIR="/opt/vpro"
CURRENT_DIR="$(pwd)"

# 1. Si no se está ejecutando desde /opt/vpro, copiar los archivos
if [ "$CURRENT_DIR" != "$APP_DIR" ]; then
    echo "[1/6] Creando directorio $APP_DIR y copiando archivos..."
    sudo mkdir -p "$APP_DIR"
    sudo cp -r ./* "$APP_DIR/"
    cd "$APP_DIR"
else
    echo "[1/6] Ejecutando desde $APP_DIR..."
fi

# 2. Actualizar repositorios e instalar paquetes base del sistema
echo "[2/6] Instalando dependencias del sistema operativo (Python 3, venv, libpq)..."
sudo apt-get update -y
sudo apt-get install -y python3 python3-venv python3-pip libpq-dev build-essential curl

# 3. Crear entorno virtual de Python
echo "[3/6] Creando y configurando entorno virtual Python..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 4. Asegurar directorios de almacenamiento y permisos
echo "[4/6] Verificando carpetas de almacenamiento local..."
mkdir -p Fotos_de_personal Fotos_de_equipos Fotos_de_eventos Archivos_Compartidos
chmod -R 775 Fotos_de_personal Fotos_de_equipos Fotos_de_eventos Archivos_Compartidos

# Configurar archivo de variables de entorno si no existe
if [ ! -f ".env" ]; then
    if [ -f ".env.produccion" ]; then
        echo "   Copiando .env.produccion a .env..."
        cp .env.produccion .env
    else
        echo "   Copiando .env.example a .env..."
        cp .env.example .env
    fi
fi

# 5. Instalar y habilitar servicio Systemd
echo "[5/6] Instalando servicio de sistema (Systemd)..."
sudo cp deploy_scripts/vpro.service /etc/systemd/system/vpro.service
sudo systemctl daemon-reload
sudo systemctl enable vpro.service
sudo systemctl restart vpro.service

# 6. Verificación de salud del servidor
echo "[6/6] Verificando arranque del servidor en puerto 8521..."
sleep 3

if curl -s http://localhost:8521/health | grep -q "ONLINE"; then
    echo ""
    echo "======================================================================"
    echo "🚀 ¡INSTALACIÓN COMPLETADA CON ÉXITO!"
    echo "======================================================================"
    echo "El sistema está activo y funcionando en segundo plano como servicio."
    echo ""
    echo "• Acceso Local en Servidor: http://localhost:8521"
    echo "• Acceso en Intranet (LAN): http://172.16.0.10:8521"
    echo "• Documentación Swagger API: http://172.16.0.10:8521/docs"
    echo ""
    echo "Comandos útiles de gestión:"
    echo "  sudo systemctl status vpro   (Ver estado del servicio)"
    echo "  sudo systemctl restart vpro  (Reiniciar el sistema)"
    echo "  sudo systemctl stop vpro     (Detener el sistema)"
    echo "  sudo journalctl -u vpro -f   (Ver logs en tiempo real)"
    echo "======================================================================"
else
    echo "⚠️ El servidor arrancó pero aún no responde en /health."
    echo "Revisa los logs con: sudo journalctl -u vpro -n 50 --no-pager"
fi
