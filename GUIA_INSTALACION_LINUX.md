# 🚀 Guía Definitiva de Instalación - VPRO Dashboard (Servidor Debian 12)

¡Hola Edgar! Esta guía contiene los pasos exactos para levantar el sistema VPRO en el servidor Linux `172.16.0.10` sin errores de importación. Incluye qué archivos específicos necesitas copiar (excluyendo scripts de Windows y temporales) y las versiones correctas de Python.

---

## 🏗️ 1. Arquitectura y Archivos del Sistema (¿Qué debes subir al servidor?)

El sistema funciona con **FastAPI** (Python 3.11+). **NO** copies toda la carpeta de desarrollo de Windows. Solo debes transferir los siguientes archivos y carpetas esenciales a tu ruta de trabajo en Linux (ej. `/home/sistema_vpro/vpro_workspace`):

### ✅ ARCHIVOS REQUERIDOS (Copiar al servidor):
*   `api_core.py`: Es el **corazón del sistema** y el punto de entrada que ejecuta Uvicorn.
*   `requirements.txt`: La lista estricta de dependencias.
*   `.env.produccion` (o tu `.env` configurado): Variables de conexión a la BD e IPs.
*   `hoja_membretada.png`: Plantilla gráfica que usa el backend para generar PDFs.
*   **Carpetas del Backend:**
    *   `core/`: Configuraciones de base de datos (`database.py`) y seguridad.
    *   `routers/`: Los Endpoints de la API separados por módulo.
*   **Carpetas del Frontend (Archivos estáticos):**
    *   `prueba_web/`: Contiene el `index.html`, `script.js` y hojas de estilo base.
    *   `modulos_prueba/`: Formularios de HTML de los submódulos.
*   **Carpetas de Almacenamiento (pueden ir vacías, pero deben existir):**
    *   `Archivos_Compartidos/`, `Fotos_de_personal/`, `Fotos_de_equipos/`, `Fotos_de_eventos/`

### ❌ ARCHIVOS A EXCLUIR (NO copiar al servidor):
*   Cualquier archivo `.bat` (ej. `1_instalar_entorno.bat`, `3_iniciar_sistema.bat` son exclusivos de Windows).
*   Carpetas `.vscode/`, `.git/`, `scratch/`, `database_dumps/`, `deploy_scripts/`.
*   Archivos `.env.laptop*` o `.env.example`.
*   Scripts de restauración sueltos (ej. `restaurar_bd.py` si no vas a restaurar BD).

---

## 🛠️ 2. Requisitos Previos en Debian 12 (Python 3.11)

Debian 12 trae **Python 3.11** por defecto, el cual es ideal para este proyecto. Instala los paquetes del entorno virtual y la librería de PostgreSQL:

```bash
sudo apt update
sudo apt install python3.11 python3.11-venv python3-pip libpq-dev -y
```

---

## 📥 3. Preparación del Entorno

Asegúrate de que los archivos listados en el **Paso 1** ya estén copiados en `/home/sistema_vpro/vpro_workspace`.

**1. Entrar a la carpeta correcta (¡MUY IMPORTANTE!)**
El 90% de los errores (`Could not import module api_core`) ocurren por intentar correr comandos desde una ruta equivocada.
```bash
cd /home/sistema_vpro/vpro_workspace
```

**2. Crear el entorno virtual de Python**
```bash
python3.11 -m venv venv
```

**3. Activar el entorno e instalar dependencias**
```bash
# Activar entorno (verás un (venv) al inicio de tu consola)
source venv/bin/activate

# Instalar librerías
pip install -r requirements.txt
```

---

## ⚙️ 4. Configurar Variables (.env)

Asegúrate de que el archivo se llame `.env` exactamente. Si copiaste el de producción, renómbralo:
```bash
cp .env.produccion .env
```
*(Abre el `.env` con `nano .env` y revisa que el host, usuarios y contraseñas de PostgreSQL sean los correctos para las bases de datos de este servidor `172.16.0.10`).*

---

## 🧪 5. Prueba Manual (Prueba de Fuego)

Antes de crear el servicio en segundo plano, probemos que levante manualmente. 
**Debes seguir posicionado en `/home/sistema_vpro/vpro_workspace`**.

Ejecuta:
```bash
/home/sistema_vpro/vpro_workspace/venv/bin/python3 -m uvicorn api_core:app --host 172.16.0.10 --port 8501 --workers 4
```
*Si la terminal dice `Uvicorn running on http://172.16.0.10:8501`, **¡éxito total!** Presiona `Ctrl + C` para detenerlo y pasar al paso final.*

---

## 🚀 6. Configurar el Servicio Automático (systemd)

Para que el sistema viva en segundo plano y se levante solo al reiniciar el servidor Debian.

**1. Crear el archivo del servicio:**
```bash
sudo nano /etc/systemd/system/vpro_workspace.service
```

**2. Pegar EXACTAMENTE esta configuración:**
*(Nota que `WorkingDirectory` apunta a la carpeta raíz, esto soluciona definitivamente el error de "Could not import module" que les ocurrió).*

```ini
[Unit]
Description=Servicio Backend API de VPRO Dashboard
After=network.target

[Service]
User=sistema_vpro
Group=sistema_vpro
# ESTO ES VITAL: Define desde dónde se ejecuta el código (previene error import api_core)
WorkingDirectory=/home/sistema_vpro/vpro_workspace
Environment="PATH=/home/sistema_vpro/vpro_workspace/venv/bin"

# Comando de arranque (usando el python del entorno virtual)
ExecStart=/home/sistema_vpro/vpro_workspace/venv/bin/python3 -m uvicorn api_core:app --host 172.16.0.10 --port 8501 --workers 4

# Reiniciar si falla
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```
*Guarda y cierra el archivo (`Ctrl + O`, `Enter`, y `Ctrl + X` en nano).*

**3. Iniciar y Habilitar:**
Ejecuta uno por uno estos comandos:
```bash
sudo systemctl daemon-reload
sudo systemctl start vpro_workspace
sudo systemctl enable vpro_workspace
sudo systemctl status vpro_workspace
```
*(El estatus final debe decir **Active: active (running)** en verde).*

---

## 🚨 Resolución Rápida de Errores

*   **`Could not import module "api_core"`**
    *   **Causa:** El comando se está lanzando desde el directorio padre (`/home/sistema_vpro/`) y no desde el workspace.
    *   **Solución:** Valida que la directiva `WorkingDirectory` en el archivo `.service` apunte exactamente a `/home/sistema_vpro/vpro_workspace`.
*   **Error conectando a BD (`psycopg2.OperationalError`)**
    *   **Solución:** Revisa tu `.env`. Valida que el servicio `postgresql` esté activo en el puerto 5432.
*   **No se ve la página en el navegador de otra PC**
    *   **Solución:** Liberar el puerto en el firewall de Debian usando: `sudo ufw allow 8501/tcp`.
*   **Ver Logs en Vivo:** `sudo journalctl -u vpro_workspace -f`
