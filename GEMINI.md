# 🧠 MEMORIA MAESTRA Y REGLAS DE PROYECTO: VPRO WORKSPACE ERP

Este documento contiene todo el conocimiento arquitectónico, reglas de negocio, aprendizajes clave y configuraciones operativas del sistema **VPRO Workspace ERP** (`vprocloud.com`).
Cualquier agente o sesión de Antigravity debe consultar y respetar estas directrices.

---

## 🏗️ 1. ARQUITECTURA GENERAL

- **Backend:** Python con **FastAPI** (`api_core.py`), con endpoints modulares en la carpeta `/routers/` (`eventos.py`, `personal.py`, `inventario.py`, `clientes.py`, `autos.py`, `proveedores.py`, `transferencias.py`, `chat.py`, etc.).
- **Frontend:** SPA web nativa sin frameworks pesados ubicada en `/prueba_web/`:
  - `index.html`: Estructura principal de la aplicación.
  - `/js/`: Módulos de lógica (`eventos_op.js`, `eventos_impresion.js`, `inicio_asistencia.js`, `transfer.js`, `chat.js`, `auth.js`, etc.).
  - `/css/`: Estilos visuales del sistema.
- **Servidor de Producción / Nube:** Railway con despliegue automático desde GitHub (`Sistema_VPRO_Limpio`, rama `main`), usando Nixpacks y `uvicorn api_core:app --host 0.0.0.0 --port ${PORT:-8521}`.
- **Dominio Público:** `https://vprocloud.com`
- **Dominio Local / Laptop:** `http://localhost:8521`

---

## 🗄️ 2. BASES DE DATOS (POSTGRESQL 18)

El sistema utiliza un clúster PostgreSQL con 6 bases de datos dedicadas:
1. `db_autos`: Flotilla vehicular, kilometrajes, mantenimientos.
2. `db_clientes`: Directorio de clientes, razones sociales y contactos.
3. `db_eventos`: Órdenes de Producción (OPs), cronogramas, equipos asignados, locaciones y finanzas de eventos.
4. `db_inventario`: Catálogo de equipo audiovisual, números de serie, categorías y estados.
5. `db_personal`: Empleados, checadas biométricas/asistencias, puestos, credenciales de acceso, roles.
6. `db_proveedores`: Directorio de proveedores de insumos y servicios.

### Credenciales y Conexiones
- **Local (PC de escritorio o Laptop):**
  - Host: `localhost` (o `172.16.0.8` en red local) | Puerto: `5432`
  - Usuario: `postgres` | Contraseña: `1qaz2wsx`
- **Producción (Railway):**
  - Host: `shuttle.proxy.rlwy.net` | Puerto: `26822`
  - Usuario: `postgres` | Contraseña: `Vpro2026*NubeDbSegura`

---

## 💼 3. REGLAS DE NEGOCIO CLAVE Y APRENDIZAJES

### A. Órdenes de Producción (OPs) / Módulo de Eventos
- **Folios:**
  - Los folios activos se listan en el selector superior de OPs excluyendo las que ya tienen informe de gastos cerrado o estatus `'CERRADA (HISTÓRICO)'`.
  - Existen folios numéricos secuenciales (ej. 174, 177, 179, 180) y folios directivos especiales con sufijo (ej. `45-DIR`, `35-DIR`).
  - El campo `id_evento` es el autoincremental primario, mientras que `folio` es el identificador visual de negocio.

### B. Módulo de Personal y Asistencias (1 a 1 y RRHH)
- **Filtro de Personal Activo:**
  - Un colaborador se considera **activo** si tiene al menos una checada registrada en los últimos **15 días**.
  - **Excepción VIP:** Los miembros de la **Familia Villarreal** (Dirección y Jefaturas) siempre aparecen activos y visibles en las listas de selección, sin importar si checaron en los últimos 15 días.

### C. Módulo de Chat y Comunicación
- Cuenta con 4 aristas o pestañas:
  1. *Chat General:* Comunicación abierta para todo el equipo.
  2. *Chat por OP / Evento:* Canales específicos vinculados a cada evento o producción.
  3. *Chat 1 a 1:* Mensajería privada y directa entre colaboradores activos.
  4. *Ayuda Redes / Soporte:* Canal directo para reportes técnicos o asistencia.

### D. Módulo de Transferencias de Archivos (VPRO Transfer)
- **Límite de tamaño:** Hasta **10.0 GB** por transferencia combinada.
- **Soporte de arrastre:** Permite arrastrar archivos individuales, selección múltiple y carpetas completas de Windows (usando lectura recursiva `webkitGetAsEntry`).
- Se eliminaron botones redundantes en el dropzone para mantener un diseño minimalista y moderno.

---

## 🛠️ 4. SCRIPTS DE CONTINGENCIA Y OPERACIÓN

El proyecto cuenta con scripts automáticos para replicar y operar el sistema en cualquier máquina:
- **`0_crear_respaldo_completo.bat` / `generar_respaldo_completo.py`:** Genera un zip maestro con el código y volcados SQL de la PC.
- **`1_instalar_entorno.bat`:** Crea el entorno virtual `venv` e instala las dependencias de Python (`requirements.txt`).
- **`2_restaurar_bd.bat` / `restaurar_bd.py`:** Verifica y crea las 6 bases en PostgreSQL local e importa los volcados de `/database_dumps/`. Incluye soporte tolerante a codificaciones de Windows en español.
- **`3_iniciar_sistema.bat`:** Inicia el backend en el puerto 8521 y abre la aplicación en el navegador.
- **`sincronizar_desde_railway.bat` / `sincronizar_desde_railway.py`:** Conecta directamente a Railway y descarga/restaura la última versión de los datos de producción en el PostgreSQL local de la máquina.

---

## 💡 5. CONSEJO PARA NUEVAS SESIONES DE IA
Cualquier agente que trabaje en este repositorio debe mantener la coherencia de estilos en `prueba_web`, no romper las rutas de CORS, y validar que los cambios en bases de datos mantengan compatibilidad tanto con PostgreSQL 18 local como con Railway.
