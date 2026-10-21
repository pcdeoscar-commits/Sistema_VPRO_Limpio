# 📦 MANUAL DE RESTAURACIÓN Y REINSTALACIÓN COMPLETA
## Sistema VPRO Workspace ERP & CRM (Dashboard Integral)
**Versión de Respaldo:** 20 de Octubre de 2026  
**Archivo de Respaldo:** `VPRO_RESPALDO_COMPLETO_20261020.zip`

---

## 🎯 ¿Qué incluye este Respaldo?
1. **Código Fuente Completo:** Backend en FastAPI (`api_core.py`), Frontend SPA 100% Offline (`prueba_web/`), todos los routers (`rh`, `inventario`, `checkout`, `eventos`, `gastos`, etc.) y utilidades (`core/`).
2. **Bases de Datos Actualizadas (`database_dumps/`):** Volcados SQL limpios con datos al día (20/Oct/2026):
   - `db_autos.sql`
   - `db_clientes.sql`
   - `db_eventos.sql`
   - `db_inventario.sql`
   - `db_personal.sql`
   - `db_proveedores.sql`
3. **Multimedia y Activos Persistentes:**
   - `Fotos_de_personal/` (Fotografías de colaboradores y credenciales)
   - `Fotos_de_equipos/` (Evidencias de taller y hardware)
   - `Fotos_de_eventos/` (Registros de órdenes de producción y operaciones)
   - `prueba_web/` (Fondos de video, logos corporativos, certificado ISO 9001:2015, librerías offline)
4. **Repositorio Git Oficial (`.git`):** Conectado al remoto de GitHub `https://github.com/pcdeoscar-commits/Sistema_VPRO_Limpio.git` en la rama `main`.
5. **Configuración y Scripts Automatizados:**
   - `instalar_extensiones_vscode.bat` (Configura extensiones de Visual Studio Code)
   - `1_instalar_entorno.bat` (Crea entorno virtual e instala dependencias)
   - `2_restaurar_bd.bat` (Crea y restaura las 6 bases de datos automáticamente)
   - `3_iniciar_sistema.bat` (Arranca el servidor en el puerto 8521 y abre el navegador)
   - `4_detener_sistema.bat` (Detiene el servidor ordenadamente)

---

## ⚙️ REQUISITOS PREVIOS EN EL EQUIPO NUEVO O REINSTALADO

Antes de restaurar el respaldo, asegúrate de tener instalado:

1. **Python 3.10 o superior (recomendado 3.12 o 3.14):**
   - Descargar desde: [https://www.python.org/downloads/](https://www.python.org/downloads/)
   - ⚠️ **PASO CLAVE:** En la primera pantalla del instalador, marcar la casilla **"Add Python to PATH"**.
2. **PostgreSQL 15, 16, 17 o 18:**
   - Descargar desde: [https://www.postgresql.org/download/windows/](https://www.postgresql.org/download/windows/)
   - Contraseña estándar del sistema: `1qaz2wsx` (o la que tú prefieras, configurable en `.env`).
3. **Visual Studio Code (opcional para desarrollo):**
   - Descargar desde: [https://code.visualstudio.com/](https://code.visualstudio.com/)
4. **Git para Windows (opcional para sincronizar GitHub):**
   - Descargar desde: [https://git-scm.com/download/win](https://git-scm.com/download/win)

---

## 🚀 PASO A PASO: GUÍA DE REINSTALACIÓN (4 PASOS FÁCILES)

### PASO 1: Descomprimir el Respaldo
1. Copia `VPRO_RESPALDO_COMPLETO_20261020.zip` en la ubicación donde desees instalar el sistema, por ejemplo:
   `C:\Curso_de_Python\Graficos\VPRO_Dashboard_V2_TODO_NUEVO` o en tu `Escritorio`.
2. Haz clic derecho -> **Extraer todo...** y entra a la carpeta extraída.

---

### PASO 2: Instalar el Entorno de Python y Dependencias
1. En la carpeta del proyecto, haz **doble clic** en:
   👉 **`1_instalar_entorno.bat`**
2. Este script automáticamente:
   - Verificará que Python esté instalado.
   - Creará la carpeta de entorno virtual `venv/`.
   - Actualizará `pip` e instalará todas las librerías necesarias especificadas en `requirements.txt` (`fastapi`, `uvicorn`, `psycopg2`, `sqlalchemy`, `pydantic`, etc.).

---

### PASO 3: Restaurar las 6 Bases de Datos de PostgreSQL
1. Verifica que el servicio de PostgreSQL esté en ejecución en tu equipo.
2. Haz **doble clic** en:
   👉 **`2_restaurar_bd.bat`**
3. El script ejecutará `restaurar_bd.py`:
   - Detectará automáticamente el comando `psql.exe`.
   - Te pedirá confirmar Host (`localhost`), Puerto (`5432`), Usuario (`postgres`) y Contraseña (`1qaz2wsx`) [solo presiona Enter si usas los valores estándar].
   - Creará las bases de datos faltantes y cargará todas las tablas, secuencias y registros desde `database_dumps/`.

> **Nota:** Si vas a conectarte a la base de datos de un servidor central remoto (ej. `172.16.0.8`) en lugar de usar base de datos local:
> - No necesitas ejecutar `2_restaurar_bd.bat`.
> - Simplemente copia el archivo `.env.laptop_remoto_172.16.0.8` y renómbralo como `.env`.

---

### PASO 4: Iniciar el Sistema
Haz **doble clic** en:
👉 **`3_iniciar_sistema.bat`**

¡Listo! Ocurrirá lo siguiente:
- Se iniciará el servidor unificado VPRO ERP en el puerto **8521**.
- Se abrirá automáticamente tu navegador web en: **`http://localhost:8521`**
- El sistema también quedará disponible para cualquier otra computadora o tablet en la misma red local (LAN) usando la IP del equipo (ejemplo: `http://172.16.0.20:8521`).

---

## 🛠️ OPCIONES ADICIONALES PARA PROGRAMAR (VS CODE & GITHUB)

Si vas a continuar programando o colaborando en esa máquina:

1. **Instalar todas las Extensiones de VS Code con 1 Clic:**
   - Haz doble clic en **`instalar_extensiones_vscode.bat`**.
   - Se instalarán automáticamente extensiones como Python, Pylance, Git, Antigravity, SQLTools, Prettier, etc.
2. **Sincronizar con GitHub:**
   - Como el respaldo incluye la carpeta `.git`, la máquina ya tiene vinculado el repositorio remoto oficial.
   - Para bajar cambios nuevos de GitHub:
     ```powershell
     git pull origin main
     ```
   - Para subir mejoras nuevas:
     ```powershell
     git add .
     git commit -m "Mensaje de tu cambio"
     git push origin main
     ```

---

## ❓ PREGUNTAS FRECUENTES Y SOLUCIÓN DE PROBLEMAS

- **¿Cómo detengo el servidor?**  
  Haz doble clic en **`4_detener_sistema.bat`** o cierra la ventana de consola negra que abrió el servidor.
- **¿Qué pasa si mi contraseña de PostgreSQL es diferente?**  
  Crea un archivo llamado `.env` en la raíz del proyecto y escribe:
  ```env
  DB_HOST=localhost
  DB_PORT=5432
  DB_USER=postgres
  DB_PASS=tu_contraseña_aqui
  ```
- **¿Los videos y fotos están respaldados?**  
  Sí, el archivo zip contiene todas las carpetas multimedia completas y offline.

