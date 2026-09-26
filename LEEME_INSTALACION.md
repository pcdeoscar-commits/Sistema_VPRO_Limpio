# 🎬 VPRO Workspace ERP - Guía de Instalación y Puesta en Marcha

Esta guía te permitirá desplegar y ejecutar el sistema **VPRO Workspace ERP** en cualquier computadora con Windows en menos de 5 minutos.

---

## 📋 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado en la computadora:

1. **Python 3.10 o superior**:
   * Descargar desde: [python.org](https://www.python.org/downloads/)
   * ⚠️ **MUY IMPORTANTE**: Durante la instalación, marca la casilla **"Add python.exe to PATH"**.

2. **PostgreSQL 14, 15, 16, 17 o 18**:
   * Descargar desde: [postgresql.org](https://www.postgresql.org/download/windows/)
   * Contraseña recomendada para el usuario `postgres`: `1qaz2wsx` *(o la de tu preferencia)*.
   * Puerto por defecto: `5432`.

---

## 🚀 Pasos de Instalación (Solo 3 Clics)

Descomprime el archivo `.zip` en la carpeta de tu preferencia (por ejemplo, en el Escritorio o en `C:\VPRO_Dashboard`). Dentro de la carpeta encontrarás los scripts numerados:

### Paso 1: Instalar Entorno y Librerías
* Haz doble clic en **`1_instalar_entorno.bat`**.
* Esto creará un entorno virtual aislado (`venv`) e instalará automáticamente todas las dependencias necesarias (`fastapi`, `uvicorn`, `sqlalchemy`, `psycopg2`, `reportlab`, `qrcode`, `pillow`, etc.).

### Paso 2: Restaurar Bases de Datos
* Haz doble clic en **`2_restaurar_bd.bat`**.
* El asistente detectará `psql.exe`, solicitará tus credenciales de PostgreSQL (si usaste `1qaz2wsx` solo presiona Enter) y creará/restaurará automáticamente las 12 bases de datos operativas con toda la información y catálogos:
  * `db_personal_prueba` y `db_personal` (Empleados, checador, expedientes RH)
  * `db_inventario_prueba` y `db_inventario` (Equipos, números de serie, kits)
  * `db_eventos_prueba` y `db_eventos` (Órdenes de producción, checkout, check-in, incidencias)
  * `db_clientes_prueba` y `db_clientes` (Directorio comercial)
  * `db_autos_prueba` y `db_autos` (Flotilla vehicular)
  * `db_proveedores_prueba` y `db_proveedores` (Proveedores externos)

### Paso 3: Iniciar el Sistema
* Haz doble clic en **`3_iniciar_sistema.bat`**.
* Se abrirán dos consolas de soporte y tu navegador web se abrirá automáticamente en:
  👉 **http://localhost:5500**

---

## 🌐 Direcciones y Accesos del Sistema

| Servicio | URL | Descripción |
| :--- | :--- | :--- |
| **Dashboard Web Moderno** | `http://localhost:5500` | Interfaz gráfica completa de VPRO Workspace ERP |
| **Backend API (Swagger Docs)** | `http://localhost:8000/docs` | Documentación interactiva de todos los endpoints REST |
| **Salud del Servidor** | `http://localhost:8000/health` | Verificación de estado del motor central |

---

## ⚙️ Configuración Personalizada (`.env`)

Si tu servidor de PostgreSQL está en otra máquina o utilizas credenciales distintas, puedes editar el archivo `.env` en la raíz del proyecto:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASS=tu_contraseña_aqui
API_URL=http://localhost:8000
```

---

## 🛑 Detener los Servicios

Cuando termines tu jornada o desees reiniciar los servicios, simplemente haz doble clic en **`4_detener_sistema.bat`**. Cerrará de forma segura los servidores que se encuentren en los puertos 8000 y 5500.

---

## 📦 Frontend Alternativo (Streamlit)
Si deseas utilizar la interfaz complementaria basada en Streamlit, puedes ejecutar **`iniciar_streamlit.bat`**, la cual abrirá la aplicación en el puerto `8520`.
