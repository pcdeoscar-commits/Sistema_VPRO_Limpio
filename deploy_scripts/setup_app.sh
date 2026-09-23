#!/bin/bash
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
