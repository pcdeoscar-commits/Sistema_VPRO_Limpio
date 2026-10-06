# 💻 MANUAL DE INSTALACIÓN Y CONFIGURACIÓN EN LAPTOP
## Entorno Completo de Desarrollo VPRO Workspace ERP
### Laptop: IP `172.16.0.112` (Windows)

Este manual te permite clonar exactamente la misma estación de trabajo que tienes en tu PC principal, con todas las herramientas, extensiones de Visual Studio Code, repositorios de GitHub, librerías y bases de datos.

---

## 📋 Resumen del Paquete de Desarrollo (`VPRO_ENTORNO_DESARROLLO_LAPTOP.zip`)

El paquete contiene:
1. **Todo el código fuente:** Backend FastAPI (`api_core.py`), Frontend SPA 100% Offline (`prueba_web/`), Routers y Módulos.
2. **Repositorio Git integrado (`.git`):** Con el historial completo y el remoto de GitHub (`origin -> https://github.com/pcdeoscar-commits/Sistema_VPRO_Limpio.git`) ya configurado.
3. **Las 6 Bases de Datos de Producción (`database_dumps/`):** Volcados limpios de PostgreSQL 18 para restaurar localmente si deseas trabajar sin conexión de oficina.
4. **Automatización para VS Code:**
   * `.vscode/extensions.json` y `.vscode/settings.json`.
   * `instalar_extensiones_vscode.bat`: Instalador con 1 clic de todas las extensiones que tienes en la PC principal (Python, Antigravity, GitHub, SQLTools, Docker, etc.).
5. **Scripts de ejecución rápida:**
   * `1_instalar_entorno.bat`: Creación de entorno virtual e instalación de dependencias.
   * `2_restaurar_bd.bat`: Restaurador automático de las 6 bases de datos.
   * `3_iniciar_sistema.bat`: Arranque del servidor unificado en el puerto 8521.
   * `4_detener_sistema.bat`: Cierre del servidor.

---

## PASO 1: Requisitos Previos en la Laptop

Antes de descomprimir, asegúrate de tener instalado lo siguiente en la laptop (si aún no lo tienes):

1. **Python 3.10 o superior (recomendado 3.12 o 3.14):**
   * Descarga desde [python.org](https://www.python.org/downloads/)
   * ⚠️ **MUY IMPORTANTE:** Al instalar, marca la casilla **"Add Python to PATH"**.
2. **Visual Studio Code:**
   * Descarga desde [code.visualstudio.com](https://code.visualstudio.com/)
3. **Git para Windows:**
   * Descarga desde [git-scm.com](https://git-scm.com/download/win)
   * Durante la instalación, puedes dejar todas las opciones por defecto.
4. **PostgreSQL (Opcional, según cómo quieras trabajar):**
   * **Modo A (Recomendado si programas fuera de la oficina):** Instala PostgreSQL en la laptop para tener tus propias bases de datos locales.
   * **Modo B (En la oficina conectada a red):** No necesitas instalar PostgreSQL en la laptop, puedes conectarte directamente al servidor dedicado `172.16.0.8`.

---

## PASO 2: Descomprimir el Paquete

1. Copia `VPRO_ENTORNO_DESARROLLO_LAPTOP.zip` a tu laptop (por memoria USB o por red local).
2. Descomprímelo en una carpeta de tu preferencia (por ejemplo, en el Escritorio o en `C:\Curso_de_Python\Graficos\VPRO_Dashboard_V2_TODO_NUEVO`).
3. Entra a la carpeta descomprimida.

---

## PASO 3: Instalar todas las Extensiones de VS Code

1. Abre la carpeta del proyecto.
2. Haz doble clic en el archivo:
   👉 **`instalar_extensiones_vscode.bat`**
3. El script instalará automáticamente todas las extensiones de tu barra lateral:
   * 🐍 **Python / Pylance / Debugpy** (Entorno de desarrollo Python)
   * 🐙 **GitHub Pull Requests & Issues** (Integración completa con GitHub)
   * 🚀 **Google Antigravity** (Asistente de Inteligencia Artificial para programar contigo)
   * 🗄️ **SQLTools / MSSQL** (Explorador y gestor de bases de datos)
   * 🐳 **Docker Containers** (Herramientas de contenedores)
   * 🌐 **Edge DevTools** (Depurador web integrado)
   * 📊 **Matplotlib Pilot & Image Preview** (Visualizadores de gráficas y fotos)
   * 🎨 **Prettier & Markdownlint** (Formateadores de código)

---

## PASO 4: Instalar las Librerías de Python (Entorno Virtual)

1. En la carpeta del proyecto, haz doble clic en:
   👉 **`1_instalar_entorno.bat`**
2. Se creará automáticamente la carpeta `venv/` y se instalarán todas las librerías necesarias (`fastapi`, `uvicorn`, `sqlalchemy`, `psycopg2`, `pydantic`, etc.).

---

## PASO 5: Configurar la Base de Datos

Tienes dos opciones según cómo vayas a trabajar en la laptop:

### Opción A: Trabajar con Bases de Datos Locales en la Laptop (Offline / Standalone)
Si instalaste PostgreSQL en la laptop:
1. Copia el archivo `.env.laptop_local` y renómbralo a `.env` (o déjalo tal cual, ya viene configurado para `localhost`).
2. Haz doble clic en:
   👉 **`2_restaurar_bd.bat`**
3. Se crearán y restaurarán automáticamente las 6 bases de datos con los datos actuales:
   * `db_autos`
   * `db_clientes`
   * `db_eventos`
   * `db_inventario`
   * `db_personal`
   * `db_proveedores`

### Opción B: Conectarte a la Base de Datos del Servidor (`172.16.0.8`)
Si tu laptop está en la red de la oficina (IP `172.16.0.112`) y quieres compartir datos en tiempo real con el servidor central:
1. Copia el archivo `.env.laptop_remoto_172.16.0.8` y renómbralo a `.env`.
2. ¡Listo! Tu laptop consumirá la base de datos central de producción.

---

## PASO 6: Iniciar el Sistema en la Laptop

Haz doble clic en:
👉 **`3_iniciar_sistema.bat`**

* Se abrirá automáticamente el navegador en: **`http://localhost:8521`**
* Tu laptop también será accesible para otras computadoras de la red en: **`http://172.16.0.112:8521`**

---

## PASO 7: Abrir en Visual Studio Code para Programar

1. Abre Visual Studio Code.
2. Menú **File** -> **Open Folder...** -> Selecciona la carpeta del proyecto.
3. En la barra lateral izquierda aparecerá el icono de **Antigravity**. Haz clic en él y ¡estaremos listos para continuar programando juntos!

