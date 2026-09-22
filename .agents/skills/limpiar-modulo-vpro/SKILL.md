---
name: limpiar-modulo-vpro
description: >-
  Usa esta habilidad cuando el usuario pida revisar, limpiar, ordenar, refactorizar
  o mejorar un módulo de Python del sistema VPRO. Aplica tanto a módulos del
  backend (routers, api_core) como del frontend (módulos de Streamlit en modulos_prueba/).
---

# Procedimiento Seguro de Limpieza para Módulos VPRO

Cuando te pidan limpiar o revisar un módulo, sigue SIEMPRE estos pasos en orden.
**NUNCA saltes un paso ni borres lógica de negocio sin antes preguntar.**

---

## PASO 1: Leer y Entender Antes de Tocar

Antes de cambiar cualquier línea:
- Leer el módulo completo de principio a fin.
- Identificar qué hace cada función principal.
- Si hay lógica que no se entiende bien, **preguntar al usuario antes de modificar**.

---

## PASO 2: Revisar Importaciones

Verificar que todas las librerías importadas al inicio del archivo realmente se usen:
- Si una librería está importada pero **no se usa en ninguna parte**, marcarla como candidata a eliminar.
- **Antes de borrarla, mostrarla al usuario y confirmar.**
- Librerías comunes del proyecto que siempre son válidas:
  - `streamlit`, `requests`, `pandas`, `datetime`, `time`
  - `fastapi`, `sqlalchemy`, `pydantic`
  - `from core.database import ...` (nunca eliminar sin avisar)
  - `from core.config import ...` (nunca eliminar sin avisar)

---

## PASO 3: Verificar Estructura del Módulo

### Para módulos Frontend (Streamlit — carpeta `modulos_prueba/`):
- Debe existir una función principal llamada `renderizar_modulo(API_URL)`.
- Los roles de usuario válidos en VPRO son: `ADMIN`, `PRODUCTOR`, `EMPLEADO`.
- Las llamadas a la API deben tener siempre `verify=False, timeout=5` para funcionar en red local.

### Para módulos Backend (FastAPI — carpeta `routers/`):
- Cada router debe tener su `prefix` y `tags` definidos.
- Los endpoints deben tener su docstring explicativo.
- Las funciones deben usar los engines correctos de `core.database`.

---

## PASO 4: Limpieza de Comentarios y Código Muerto

- Eliminar líneas comentadas que ya no son necesarias (código viejo comentado con `#`).
- **EXCEPCIÓN:** Si el comentario explica el POR QUÉ de una decisión de negocio, conservarlo.
- Consolidar bloques de comentarios repetidos o redundantes.
- Si hay funciones duplicadas, señalarlas y preguntar cuál es la correcta antes de borrar.

---

## PASO 5: Revisar Manejo de Errores

- Todo bloque `try/except` debe tener al menos un mensaje de manejo.
- Los `except Exception: pass` silenciosos deben revisarse — pueden esconder bugs.
- En módulos Streamlit, los errores de conexión a la API deben mostrar algo al usuario
  (ej. `st.warning("Sin conexión al servidor")`).

---

## PASO 6: Reportar los Cambios

Al terminar, siempre mostrar al usuario un resumen claro:

```
✅ RESUMEN DE LIMPIEZA - [nombre del módulo]
─────────────────────────────────────────
🗑️  Importaciones eliminadas:  [lista]
💬  Comentarios mejorados:     [cantidad]
🐛  Posibles bugs encontrados: [descripción]
⚠️  Cambios que requieren tu OK antes de aplicar: [lista]
```

---

## REGLAS DE ORO (Nunca Violarlas)

1. **Nunca borrar lógica de negocio** sin confirmación explícita del usuario.
2. **Nunca cambiar nombres** de funciones, variables o rutas de API sin avisar primero.
3. **Nunca modificar** archivos de la carpeta `core/` sin revisión especial del usuario.
4. Si un cambio podría **romper el sistema en producción**, decirlo claramente con ⚠️.

