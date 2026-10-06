# 🚀 GUÍA DE INSTALACIÓN Y DESPLIEGUE EN PRODUCCIÓN (INTRANET)
## Sistema VPRO Workspace ERP

Este manual detalla los pasos exactos y óptimos para desplegar el sistema en los dos servidores dedicados de la empresa:
* **Servidor de Base de Datos:** `172.16.0.8` (Debian 13 Trixie / PostgreSQL 18.4)
* **Servidor de Aplicación:** `172.16.0.10` (Debian 12 Bookworm)

---

## 📋 Arquitectura de la Red

```
[ PCs de Empleados en Intranet ]
             │
             ▼ (HTTP :8521)
┌─────────────────────────────────┐
│ Servidor Sistema (172.16.0.10)  │
│ Debian 12 Bookworm              │
│ FastAPI + Web SPA 100% Offline  │
│ Servicio: vpro.service          │
└─────────────────────────────────┘
             │
             ▼ (PostgreSQL :5432)
┌─────────────────────────────────┐
│ Servidor Bases de Datos         │
│ (172.16.0.8)                    │
│ Debian 13 Trixie                │
│ PostgreSQL 18.4 UTF-8           │
│ 6 Bases de Datos de Producción  │
└─────────────────────────────────┘
```

---

## PASO 1: Configurar el Servidor de Bases de Datos (`172.16.0.8`)

### 1.1 Permitir conexiones remotas desde el servidor de aplicación
En `172.16.0.8`, abre una terminal como `root`:

1. Edita el archivo de configuración principal de PostgreSQL:
   ```bash
   nano /etc/postgresql/18/main/postgresql.conf
   ```
   Busca la línea `listen_addresses` y asegúrate de que esté configurada así:
   ```conf
   listen_addresses = '*'
   ```

2. Edita las reglas de autenticación:
   ```bash
   nano /etc/postgresql/18/main/pg_hba.conf
   ```
   Agrega al final del archivo una línea para autorizar al servidor de aplicación (`172.16.0.10`):
   ```conf
   host    all             all             172.16.0.10/32          md5
   ```
   *(Si el usuario `postgres` usa cifrado SCRAM, puedes colocar `scram-sha-256` en lugar de `md5`)*.

3. Reinicia PostgreSQL para aplicar los cambios:
   ```bash
   systemctl restart postgresql
   ```

4. Asegúrate de conocer la contraseña del usuario `postgres` (por defecto `1qaz2wsx`). Si deseas cambiarla o redefinirla:
   ```bash
   sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '1qaz2wsx';"
   ```

---

### 1.2 Restaurar las 6 Bases de Datos de Producción
Copia la carpeta `database_dumps/` y el script `deploy_scripts/setup_db.sh` al servidor `172.16.0.8` (o descomprime el ZIP allí):

```bash
cd /ruta/donde/descomprimiste
chmod +x deploy_scripts/setup_db.sh
./deploy_scripts/setup_db.sh
```

El script creará automáticamente las 6 bases de datos con codificación `UTF-8` y Collate `es_MX.UTF-8`, e importará todos los datos limpios:
* `db_autos`
* `db_clientes`
* `db_eventos`
* `db_inventario`
* `db_personal`
* `db_proveedores`

---

## PASO 2: Configurar el Servidor de Aplicación (`172.16.0.10`)

### 2.1 Descomprimir el proyecto en el servidor
En `172.16.0.10`, copia el archivo `VPRO_WORKSPACE_PRODUCCION.zip` (por ejemplo mediante SCP, WinSCP o memoria USB):

```bash
# Como root o con sudo
sudo apt-get update && sudo apt-get install -y unzip

# Descomprimir en /opt/vpro
sudo mkdir -p /opt/vpro
sudo unzip -o VPRO_WORKSPACE_PRODUCCION.zip -d /opt/vpro
cd /opt/vpro
```

---

### 2.2 Verificar el archivo de configuración `.env`
El archivo `/opt/vpro/.env` debe apuntar al servidor de base de datos `172.16.0.8`:

```ini
DB_HOST=172.16.0.8
DB_PORT=5432
DB_USER=postgres
DB_PASS=1qaz2wsx

API_URL=http://172.16.0.10:8521
```

*(Si la contraseña del usuario `postgres` en `172.16.0.8` es diferente, cámbiala en `DB_PASS`).*

---

### 2.3 Ejecutar el instalador automático
Ejecuta el script de instalación optimizado para Debian 12:

```bash
chmod +x deploy_scripts/*.sh
./deploy_scripts/setup_app.sh
```

El instalador realizará todo de forma desatendida:
1. Instala `python3`, `python3-venv`, `libpq-dev` y herramientas de compilación.
2. Crea el entorno virtual en `/opt/vpro/venv`.
3. Instala todas las librerías de `requirements.txt`.
4. Crea las carpetas de fotos y transferencias (`Fotos_de_personal`, `Archivos_Compartidos`, etc.).
5. Instala e inicia el servicio Systemd `vpro.service`.
6. Verifica que el endpoint `/health` responda `ONLINE`.

---

## PASO 3: Verificación y Administración del Sistema

### 3.1 Comandos de control (Systemd)
El sistema queda registrado como servicio permanente del sistema operativo:

* **Ver estado en tiempo real:**
  ```bash
  sudo systemctl status vpro
  ```
* **Reiniciar el sistema:**
  ```bash
  sudo systemctl restart vpro
  ```
* **Detener el sistema:**
  ```bash
  sudo systemctl stop vpro
  ```
* **Ver logs de depuración en vivo:**
  ```bash
  sudo journalctl -u vpro -f
  ```

---

### 3.2 Acceso desde las computadoras de los empleados (Intranet)
Cualquier empleado conectado a la red local puede abrir su navegador web favorito (Chrome, Edge, Firefox) e ingresar a:

👉 **`http://172.16.0.10:8521`**

* **100% Offline / Intranet:** No requiere salida a Internet. Todas las fuentes (Inter), íconos (Phosphor) y librerías de gráficos (Chart.js) se cargan desde el servidor local.
* **Transferencias VPRO Transfer:** Se pueden compartir y descargar archivos de hasta 5 GB entre colaboradores de la empresa a la velocidad de la red local (Gigabit / Fast Ethernet).
* **Documentación técnica de la API:** Disponible en `http://172.16.0.10:8521/docs`.
