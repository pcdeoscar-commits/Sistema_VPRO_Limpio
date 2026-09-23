import streamlit as st
import os
from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus

# El decorador convierte esta función en una ventana flotante (Pop-up)
@st.dialog("📖 MANUAL DE TRAZABILIDAD OPERATIVA VPRO", width="large")
def mostrar_manual_popup():
    st.markdown("""
    <div style="background-color: #1e293b; padding: 20px; border-radius: 15px; border-left: 10px solid #38bdf8; margin-bottom: 25px;">
        <h2 style="margin: 0; color: #f8fafc;">📖 MANUAL DE TRAZABILIDAD OPERATIVA VPRO</h2>
        <p style="margin: 0; color: #bae6fd; font-weight: bold;">Flujo Integral del Sistema: De la Planeación al Cierre Financiero</p>
    </div>

    Este documento detalla el ciclo de vida exacto de una Orden de Producción (OP) en el Sistema VPRO. Su objetivo es que cada departamento comprenda cómo su captura de datos detona, bloquea o libera el trabajo de los demás departamentos.

    ---

    ### 📑 Índice Interactivo

    1. [🎬 FASE 1: Planeación y Nacimiento del Proyecto (Módulo de Eventos)](#fase-1)
    2. [📦 FASE 2: Despacho de Hardware (Módulo de Checkout - Salida)](#fase-2)
    3. [🎥 FASE 3: Operación en Locación](#fase-3)
    4. [📥 FASE 4: Retorno a Base y Liberación (Módulo de Checkout - Check-in)](#fase-4)
    5. [🧾 FASE 5: Rendición de Cuentas (Módulo Reporte de Gastos)](#fase-5)
    6. [🔎 FASE 6: Auditoría y Cierre Financiero (Buzón de Dirección)](#fase-6)
    7. [🚨 ANEXO: PROTOCOLO DE CORRECCIÓN DE ERRORES Y EXCEPCIONES](#anexo)
    8. [🛠️ FASE ESPECIAL: Trazabilidad de Equipos Dañados (Check-in vs Instalaciones)](#fase-danos)

    ---

    <h3 id="fase-1">🎬 FASE 1: Planeación y Nacimiento del Proyecto (Módulo de Eventos)</h3>

    **Actor responsable:** Administración, Coordinación o Ventas.  
    **Objetivo:** Crear el evento y definir a los responsables.

    *   📝 **Captura de Datos Base:** El Coordinador ingresa al módulo de Orden de Producción y llena los datos vitales: Cliente, Nombre del Evento, Locación exacta, Fecha/Hora de Instalación y Fecha/Hora del Evento.
    *   👤 **El Nombramiento del Productor:** Se asigna obligatoriamente un Productor Responsable.
        *   🔒 **Candado del Sistema:** El usuario que sea seleccionado en esta casilla será el único en toda la empresa que tendrá permisos para llenar el Reporte de Gastos al finalizar el evento.
    *   📋 **Logística y Convocatoria:** Se despliegan los menús para seleccionar al personal de VPRO convocado, apoyos externos, proveedores co-convocados y los vehículos de la flotilla a utilizar.
    *   ✍️ **Firmas de Autorización:** Se definen los cuatro responsables del documento (Elaboró, Coordina, Organiza y Vo.Bo.).
    *   ✈️ **Logística de Viajes (Modo Gira):** Si el evento es foráneo, se activa el sello de "Asistencia Automática en Ruta". Se elige el rango de fechas del viaje y el sistema registra automáticamente las asistencias en el Kiosco para todo el personal seleccionado, evitando que tengan faltas en Recursos Humanos mientras están de viaje.
    *   💾 **Guardado Maestro:** Al hacer clic en el botón azul de guardado, la OP nace oficialmente en la base de datos y se le asigna su Folio VPRO.

    [⬆️ Volver al Índice](#indice-interactivo)

    ---

    <h3 id="fase-2">📦 FASE 2: Despacho de Hardware (Módulo de Checkout - Salida)</h3>

    **Actor responsable:** Coordinador / Logística.  
    **Objetivo:** Registrar exactamente qué equipo sale de las instalaciones.

    *   📂 **Apertura de la OP:** El personal seleccionado entra a su panel y el sistema le muestra automáticamente las Órdenes de Producción que están pendientes de salir.
    *   🧳 **Carga de Equipo:**
        *   Bodega puede cargar una plantilla preestablecida (Ej. "Kit Básico de Audio").
        *   O bien, puede usar el "Inyector Rápido de Hardware" para buscar piezas específicas en el inventario global y agregarlas a la lista.
        *   🛡️ **Regla de Calidad:** El sistema bloquea renglones duplicados; si se seleccionan dos equipos iguales, obliga a unificar la cantidad.
    *   ✅ **Auditoría de Salida:** Un Coordinador revisa la pantalla, confirma que las cantidades coincidan físicamente y presiona **"AUTORIZAR SALIDA DE BODEGA"**.
    *   🚚 **Estatus de Tránsito:** La OP queda sellada y su estado interno cambia a `DESPACHADO`. A partir de este momento, el equipo está bajo la custodia de la producción.

    [⬆️ Volver al Índice](#indice-interactivo)

    ---

    <h3 id="fase-3">🎥 FASE 3: Operación en Locación</h3>

    **Responsable:** Productor Responsable.  
    **Objetivo:** Controlar los tiempos de trabajo del personal fuera de la oficina.

    *   📍 **Apertura de Llamado:** El Productor Responsable entra a la OP desde su celular o equipo de cómputo en la locación (Esta opción solo le aparece a él).
    *   🟢 **Registro de Entrada:** En la sección "Claqueta de Asistencia", verifica qué personal está físicamente en el set y presiona **"INICIAR LLAMADO"**. Esto manda la hora exacta de entrada al sistema de Recursos Humanos.
    *   🔴 **Cierre de Jornada:** Al terminar el evento o montaje, el Productor presiona **"TERMINAR JORNADA"**, lo que sella la hora de salida de todo su equipo, calculando horas trabajadas y evitando reportes de abandono de turno.

    [⬆️ Volver al Índice](#indice-interactivo)

    ---

    <h3 id="fase-4">📥 FASE 4: Retorno a Base y Liberación (Módulo de Checkout - Check-in)</h3>

    **Actor responsable:** Coordinación / Logística.  
    **Objetivo:** Recuperar el hardware, auditar daños y liberar la OP.

    *   🏢 **Recepción:** Cuando el personal regresa a las instalaciones, el Coordinador abre el módulo de Check-in y carga el folio de la OP.
    *   ✅ **Cotejo Individual:** La pantalla muestra exclusivamente lo que se llevó el personal convocado. Bodega debe marcar la casilla "¿Regresó?" por cada cable, bocina o case.
    *   🚦 **Auditoría de Daños (Semáforo Inteligente):**
        *   Si una pieza regresa rota o con fallas, Bodega lo escribe en la columna de "Notas de Regreso".
        *   🔒 **Candado del Sistema:** Si el texto contiene palabras clave de alerta (ej. *daño, roto, falló, quebrado, golpe*), el sistema automáticamente manda ese equipo al "Expediente Clínico / Taller" y cambia su estatus a `DAÑADO` en el inventario global.
    *   📜 **Acta de Incidencias a Proveedores:** Si faltó equipo o hubo un daño por culpa de un proveedor (ej. la empresa de tarimas rompió un cable), Bodega selecciona al proveedor en el menú de infractores y redacta el acta. De este modo se registrarán las incidencias de los proveedores.
    *   🏁 **Cierre y Liberación:** Al dar clic en **"FINALIZAR REVISIÓN Y REGRESO"**, el estado de la OP cambia a `RECIBIDO`.
        *   🔐 **CANDADO FINANCIERO:** Es matemáticamente imposible que un Productor rinda gastos si Bodega no ha realizado este paso. El sistema de finanzas está bloqueado hasta que el equipo regrese a casa.

    [⬆️ Volver al Índice](#indice-interactivo)

    ---

    <h3 id="fase-5">🧾 FASE 5: Rendición de Cuentas (Módulo Reporte de Gastos)</h3>

    **Actor responsable:** Productor Responsable (Asignado en la Fase 1).  
    **Objetivo:** Comprobar el dinero de viáticos y registrar kilometrajes.

    *   🔓 **Acceso al Reporte:** El Productor entra a su menú de rendición. El sistema detecta su usuario y le muestra en el menú desplegable solo las OPs que él dirigió y que ya fueron liberadas por Bodega.
    *   🚗 **Captura de Odómetros:** El sistema le exige capturar el Kilometraje Inicial y Final exacto de todas las camionetas que se llevó al evento.
    *   📊 **Matriz Dinámica de Gastos:** Se genera una tabla automática según los días que duró el evento. El Productor debe teclear el gasto diario en las categorías designadas (Hotel, Casetas, Alimentos, Combustible, etc.).
    *   🧮 **Cálculo Automático:** Tras hacer clic en **"SUMAR TODOS LOS GASTOS"**, el Productor ingresa cuánto dinero en efectivo/transferencia se le entregó antes del viaje ("Presupuesto Entregado"). El sistema resta el total gastado y le dicta con exactitud la cantidad del Remanente que debe devolver a Administración.
    *   🖋️ **Firma Electrónica:** Al dar clic en **"ENVIAR INFORME COMPLETO Y ARCHIVAR EVENTO"**, la OP queda bloqueada para él y se manda directo al escritorio de Dirección.

    [⬆️ Volver al Índice](#indice-interactivo)

    ---

    <h3 id="fase-6">🔎 FASE 6: Auditoría y Cierre Financiero (Buzón de Dirección)</h3>

    **Actor responsable:** Dirección / Administración.  
    **Objetivo:** Revisar comprobantes físicos, saldar cuentas y cerrar el ciclo.

    *   📥 **Buzón de Entrada:** Administración ingresa a la pestaña "Panel de Auditoría y Aprobación". Ahí encuentra una lista de alertas con los informes recién enviados por los Productores.
    *   🔍 **Inspección Visual:** Al seleccionar un informe, el panel le resume todo: Quién gastó, en qué vehículos, total de kilómetros recorridos, dinero entregado, dinero comprobado en el sistema y el remanente a devolver.
    *   🧾 **Cuadre Físico:** Dirección recibe del Productor los tickets físicos, facturas y el dinero en efectivo sobrante. Debe cotejar que el papel coincida con lo que dice la pantalla.
    *   🖨️ **Generación de PDF Oficial:** Dirección puede descargar un PDF formateado con membrete de VPRO que funciona como acuse de recibo contable.
    *   ✅ **El Sello Definitivo:** Si no hay diferencias ni discrepancias, Administración debe presionar el botón **"✅ MARCAR COMO REVISADO Y APROBADO"**.
    *   📁 **Bóveda Histórica (Desaparición de la OP):** Esta acción congela la base de datos. En este instante, **la Orden de Producción desaparece por completo de todas las listas y menús de "Pendientes" de la empresa**. El informe se transfiere exclusivamente al "Historial de Informes Archivados", donde solo las personas con el nivel de autorización requerido (Administración / Dirección) tendrán acceso a consultarlo en modo de solo lectura. El evento queda oficialmente cerrado y blindado ante cualquier modificación futura.

    [⬆️ Volver al Índice](#indice-interactivo)

    ---

    <h3 id="anexo">🚨 ANEXO: PROTOCOLO DE CORRECCIÓN DE ERRORES Y EXCEPCIONES</h3>

    En el flujo operativo de VPRO, la regla general es: *"El que envía la información, ya no puede modificarla"*. Esto evita alteraciones no autorizadas y protege la integridad de los datos. Sin embargo, existen protocolos de corrección bajo la supervisión de Dirección o Administración.

    **1. El Productor se equivocó al capturar el Reporte de Gastos**
    *   **La Situación:** El Productor envió su comprobación y la OP desapareció de sus pendientes. De pronto, se da cuenta de que tecleó $5,000 en casetas en lugar de $500.
    *   **El Bloqueo:** El Productor ya no puede editarlo. El sistema ha blindado el documento.
    *   **La Solución:** El Productor debe notificar inmediatamente a Administración.
    *   **El Rescate:** Desde su "Panel de Auditoría", Administración tiene el privilegio exclusivo de hacer doble clic sobre cualquier celda de la tabla de gastos, corregir el monto y el sistema recalculará matemáticamente el total y el remanente. Incluso si el informe ya estaba en el Archivo Muerto, Administración puede buscarlo en el Historial, editar el número y presionar **"💾 GUARDAR CORRECCIONES AL HISTÓRICO"**.

    **2. El Productor olvidó Actualizar la información del personal en Locación.**
    *   **La Situación:** El Productor inició el llamado en la locación, pero al terminar el evento, por las prisas, olvidó abrir su celular y presionar "🔴 TERMINAR JORNADA". El personal sigue "trabajando" para el sistema.
    *   **Solución Automática (El Reloj Despertador):** El "Piloto Automático" del servidor VPRO se despierta en horarios clave (9:00, 14:00, 16:00 y 19:00 hrs). Si a las 19:00 hrs detecta a personal que sigue con estatus "EN EVENTO" y sin hora de salida, el motor cerrará su jornada automáticamente.
    *   **Solución Manual (Auditoría de RH):** Un Administrador puede ir al Checador / Kiosco, entrar a la "Vista Plana Tradicional (Bitácora)" de asistencia, editar manualmente la celda de la "Hora Salida" del empleado afectado y guardar el cambio dejando una nota en la bitácora que diga *"Cierre manual"*.

    **3. Bodega se equivocó en el Check-in de Hardware**
    *   **La Situación:** Bodega marcó que un monitor regresó "DAÑADO" y liberó el folio, pero minutos después se dan cuenta de que solo era un cable desconectado y el monitor funciona perfecto.
    *   **El Bloqueo:** La OP ya se cerró para Bodega y el ticket de falla ya se levantó en el sistema.
    *   **La Solución:** El encargado debe ir al módulo de Inventario, buscar el equipo en cuestión y entrar a su Expediente Clínico. Ahí debe utilizar el "Editor de Activos" para cambiar el estatus operativo manualmente de regreso a "BUEN ESTADO", cerrando el falso reporte de reparación.

    **4. Error al asignar al Productor Responsable en la OP**
    *   **La Situación:** Se creó la Orden de Producción, pero por error se seleccionó a "Juan" como Productor cuando el encargado real era "Pedro".
    *   **El Bloqueo:** Pedro no podrá ver la Claqueta Digital ni podrá llenar el Reporte de Gastos porque el sistema cree que le corresponden a Juan.
    *   **La Solución:** El creador original de la OP o un Coordinador deben ir al módulo de Orden de Producción, buscar el folio y cambiar el nombre en la casilla "🎬 PRODUCTOR RESP." a "Pedro". Al darle guardar, el sistema le transferirá automáticamente los "poderes" del evento a Pedro.

    [⬆️ Volver al Índice](#indice-interactivo)

    ---

    <h3 id="fase-danos">🛠️ FASE ESPECIAL: Trazabilidad de Equipos Dañados (Check-in vs Instalaciones)</h3>

    Existen dos compuertas oficiales y complementarias para el reporte de hardware y activos averiados en VPRO:

    #### 🚚 Canal A: Retorno de Evento (Módulo Check-in / Bodega)
    *   **Uso:** Exclusivo para equipos que regresan de una filmación o llamado de producción.
    *   **El Procedimiento:** En la tabla de cotejo de Check-in, el almacenista escribe en la columna **"Nota de regreso (incidencia)"**.
    *   **Semáforo Inteligente:** Si el texto incluye palabras como *daño, roto, falló, quebrado, golpe, pérdida*, el sistema automáticamente:
        1. Marca el equipo como `DAÑADO` en el inventario.
        2. Genera un ticket en taller con prefijo `REP-RUT-` amarrado indisolublemente a la OP.
        3. Inyecta el evento en el **Expediente Clínico** del activo con folio `OP-XXX`.
        4. Aparece de inmediato en el **Radar de Daños / Taller**.

    #### 🏢 Canal B: Mantenimiento Interno / Oficina (Módulo Equipos con Daño)
    *   **Uso:** Para activos fijos de instalaciones que no van a eventos (Aire Acondicionado Mini Split, computadoras de oficina, monitores de edición, mobiliario).
    *   **El Procedimiento:** Desde el módulo `🛠️ Equipos con Daño`, abrir el expander **"🛠️ REGISTRAR REPORTE DIRECTO DE OFICINA"**.
    *   **Captura:** Se selecciona el equipo del catálogo oficial, se elige el tipo de evento (`MANTENIMIENTO_TÉCNICO`, `FALLA_OPERATIVA`, etc.), se redacta el diagnóstico y se adjunta **fotografía de evidencia**.
    *   **Resultado:** Genera un ticket `REP-INT-` bajo el folio `MANTENIMIENTO_INTERNO` y archiva la foto en el servidor central.

    #### ⚙️ Rehabilitación y Regreso a Operación
    *   Una vez reparado el equipo, el técnico o coordinador selecciona el ticket en el panel inferior de *Equipos con Daño*, lo cambia a `REPARADO` o `RESUELTO` y hace clic en **"✅ REHABILITAR EQUIPO"**.
    *   El sistema regresa el activo a `OK` en inventario (`BUEN ESTADO` en kits) y queda libre para futuras asignaciones.

    [⬆️ Volver al Índice](#indice-interactivo)
    """, unsafe_allow_html=True)
    
    st.write("")
    pdf_manual_path = "Manual_Trazabilidad_Reporte_Equipos_Danados_VPRO.pdf"
    if os.path.exists(pdf_manual_path):
        try:
            with open(pdf_manual_path, "rb") as f_pdf:
                st.download_button(
                    label="📄 Descargar Manual Oficial de Daños y Trazabilidad (PDF)",
                    data=f_pdf.read(),
                    file_name="Manual_Trazabilidad_Reporte_Equipos_Danados_VPRO.pdf",
                    mime="application/pdf",
                    use_container_width=True
                )
        except Exception as e:
            print(f"⚠️ SILENCED ERROR in mod_manual.py: {e}")

    st.write("")
    if st.button("✖️ Cerrar Manual", use_container_width=True):
        st.rerun()