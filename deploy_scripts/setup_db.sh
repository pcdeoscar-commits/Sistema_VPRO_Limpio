#!/bin/bash
# Script de instalacion para Servidor DB (Debian 13 - 172.16.0.8)
echo "Restaurando BBDD en PostgreSQL 18.4..."
DBS=("db_personal_prueba" "db_eventos_prueba" "db_inventario_prueba" "db_clientes_prueba" "db_autos_prueba" "db_proveedores_prueba")
for db in "${DBS[@]}"; do
    echo "Procesando $db..."
    sudo -u postgres psql -c "CREATE DATABASE $db LC_COLLATE 'es_MX.UTF-8' LC_CTYPE 'es_MX.UTF-8';"
    sudo -u postgres psql -d $db -f "database_dumps/$db.sql"
done
echo "Restauración completa."
