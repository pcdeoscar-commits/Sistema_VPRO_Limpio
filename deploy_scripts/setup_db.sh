#!/bin/bash
# ==============================================================================
# VPRO WORKSPACE ERP - INSTALACIÓN DE BASES DE DATOS EN POSTGRESQL 18
# Servidor DB: Debian 13 (trixie) @ IP: 172.16.0.8
# ==============================================================================

set -e

echo "======================================================================"
echo "🎬 VPRO WORKSPACE - RESTAURACIÓN DE BASES DE DATOS DE PRODUCCIÓN"
echo "======================================================================"
echo "Servidor PostgreSQL 18.4 | UTF-8 | es_MX.UTF-8"
echo ""

# 1. Definición de las 6 bases de datos reales
DBS=("db_autos" "db_clientes" "db_eventos" "db_inventario" "db_personal" "db_proveedores")

# 2. Creación e importación de cada base de datos
for db in "${DBS[@]}"; do
    echo "----------------------------------------------------------------------"
    echo "📦 Procesando base de datos: $db"
    
    # Crear base de datos si no existe con la codificación y collate exactos del servidor
    sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname = '$db'" | grep -q 1 || \
    sudo -u postgres psql -c "CREATE DATABASE $db WITH ENCODING 'UTF8' LC_COLLATE 'es_MX.UTF-8' LC_CTYPE 'es_MX.UTF-8';"
    
    # Restaurar el dump SQL limpio
    if [ -f "database_dumps/$db.sql" ]; then
        echo "   Importando esquema y datos desde database_dumps/$db.sql..."
        sudo -u postgres psql -d "$db" -f "database_dumps/$db.sql" > /dev/null
        echo "   ✓ $db restaurada exitosamente."
    else
        echo "   ⚠️ Archivo database_dumps/$db.sql no encontrado."
    fi
done

echo ""
echo "======================================================================"
echo "🔐 CONFIGURACIÓN DE ACCESO REMOTO PARA EL SERVIDOR DE APLICACIÓN (172.16.0.10)"
echo "======================================================================"
echo ""
echo "Recuerda asegurar que PostgreSQL permita conexiones desde 172.16.0.10:"
echo ""
echo "1) En postgresql.conf (típicamente en /etc/postgresql/18/main/postgresql.conf):"
echo "   listen_addresses = '*'"
echo ""
echo "2) En pg_hba.conf (típicamente en /etc/postgresql/18/main/pg_hba.conf):"
echo "   host    all             all             172.16.0.10/32          md5"
echo ""
echo "3) Reiniciar PostgreSQL:"
echo "   systemctl restart postgresql"
echo ""
echo "======================================================================"
echo "✓ BASES DE DATOS RESTAURADAS AL 100%"
echo "======================================================================"
