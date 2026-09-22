---
name: formato-reporte-pdf
description: >-
  Usa esta habilidad cuando el usuario pida generar, diseñar o dar formato
  a un documento o reporte PDF oficial del sistema VPRO. Se aplica a reportes
  de inventario, equipos dañados, checkout, personal, clientes y cualquier
  comunicado oficial de la empresa.
---

# Formato Oficial de Reportes y Documentos VPRO

Cada vez que generes un documento o reporte PDF en el sistema VPRO, debes
aplicar esta estructura OBLIGATORIA sin excepción.

---

## PARTE 1: Encabezado (Header) de la Página

El encabezado se divide en dos columnas en la parte superior de la página:

### Columna Izquierda (Superior Izquierda):
- Insertar el **Logo de VPRO** (`hoja_membretada.png` o la imagen oficial del logo).
- El logo debe estar alineado a la izquierda.

### Columna Derecha (Superior Derecha):
- Insertar el **Logo de la Norma ISO 9001-2015**.
- Justo **abajo del logo ISO**, colocar la fecha en formato largo completo:
  - Ejemplo exacto: `Lunes 09 de Septiembre del 2026`
  - El día de la semana siempre en español y con mayúscula inicial.
  - El mes siempre con mayúscula inicial.

---

## PARTE 2: Datos del Destinatario

En el renglón siguiente al encabezado, **alineado a la izquierda**:

1. **Nombre:** A quien va dirigido el documento (ej: `Ing. Juan Pérez García`).
2. **Puesto:** En el renglón inmediatamente inferior al nombre (ej: `Gerente de Operaciones`).
3. **Saludo:** En el renglón siguiente, escribir exactamente así (con espacios entre letras):

   ```
   P r e s e n t e ;
   ```

---

## PARTE 3: Reglas Generales

- Nunca omitir ni cambiar el orden de los elementos del encabezado.
- La palabra **P r e s e n t e ;** siempre va espaciada, con punto y coma al final.
- Si no se tiene el nombre del destinatario, preguntar al usuario antes de generar el documento.
- Si no se tiene la imagen del logo ISO, usar texto `ISO 9001-2015` en su lugar temporalmente.
- Los archivos de logo disponibles en el proyecto son:
  - `hoja_membretada.png` (logo VPRO en la carpeta raíz del proyecto)
  - `qr_vpro.png` (código QR del sistema)

