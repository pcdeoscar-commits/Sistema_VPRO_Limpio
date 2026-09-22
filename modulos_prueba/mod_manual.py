import streamlit as st
import os
from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus

# El decorador convierte esta función en una ventana flotante (Pop-up)
@st.dialog("📖 MANUAL DE USUARIO INTEGRAL VPRO", width="large")
def mostrar_manual_popup():
    st.markdown("""
    <div style="background-color: #1e293b; padding: 20px; border-radius: 15px; border-left: 10px solid #38bdf8; margin-bottom: 25px;">
        <h2 style="margin: 0; color: #f8fafc;">📖 MANUAL DE USUARIO INTEGRAL VPRO</h2>
        <p style="margin: 0; color: #bae6fd; font-weight: bold;">Guía completa de todos los módulos operativos y administrativos del sistema.</p>
    </div>

    Bienvenido al sistema **VPRO Dashboard**. Este manual centralizado contiene las reglas de negocio, flujos y responsabilidades de todos los módulos del sistema. El objetivo es que cada departamento comprenda cómo su captura de datos detona, bloquea o libera el trabajo de los demás departamentos.

    ---

    ### 📑 Índice General Interactivo

    **1. 🏢 ADMINISTRACIÓN Y CATÁLOGOS GLOBALES (ABC)**
    * [1.1. 🦺 Empleados (Accesos y Plantilla Básica)](#mod-empleados)
    * [1.2. 👥 Recursos Humanos (El Expediente Completo)](#mod-rh)
    * [1.3. 🤝 Clientes y 🏢 Proveedores](#mod-clientes-proveedores)
    * [1.4. 🛠️ Inventario General y Kits](#mod-inventario)
    * [1.5. 🚗 Autos y Flotilla Vehicular](#mod-autos)

    **2. ⏱️ ASISTENCIA Y CONTROL DE TIEMPOS**
    * [2.1. 🕒 Kiosco / Reloj Checador](#mod-kiosco)
    * [2.2. ⏱️ Reporte y Auditoría de Asistencia](#mod-reporte-asistencia)

    **3. 🎬 EL CICLO DE VIDA DE UN EVENTO (LOGÍSTICA Y FINANZAS)**
    * [3.1. Planeación y Nacimiento del Proyecto (Módulo de Eventos)](#fase-1)
    * [3.2. Despacho de Hardware (Módulo de Checkout - Salida)](#fase-2)
    * [3.3. Operación en Locación (Claqueta del Productor)](#fase-3)
    * [3.4. Retorno a Base y Liberación (Check-in de Bodega)](#fase-4)
    * [3.5. Rendición de Cuentas (Reporte de Gastos y Viáticos)](#fase-5)
    * [3.6. Auditoría y Cierre Financiero (Buzón de Dirección)](#fase-6)
    * [3.7. 🛠️ Trazabilidad de Equipos Dañados (Taller)](#fase-danos)

    **4. 📊 GESTIÓN COMERCIAL Y CONTROL DIRECTIVO**
    * [4.1. 📄 Cotizaciones](#mod-cotizaciones)
    * [4.2. ⚠️ Incidencias (Reportes Internos)](#mod-incidencias)
    * [4.3. 🤝 Minutas / Reuniones de Trabajo](#mod-reuniones)
    * [4.4. 📈 Analítica / KPIs Gerenciales](#mod-analitica)

    **5. 🚨 ANEXO: PROTOCOLOS DE CORRECCIÓN DE ERRORES](#anexo-errores)

    ---
    
    <h3 id="mod-empleados">1.1. 🦺 Empleados (Accesos y Plantilla Básica)</h3>
    Módulo destinado exclusivamente a la creación de <b>credenciales de acceso</b>.
    <ul>
        <li><b>Alta de Sistema:</b> Permite registrar a un nuevo colaborador con sus datos mínimos (ID, contraseña, rol) para que pueda hacer login en el Dashboard.</li>
        <li><b>Seguridad:</b> Permite restablecer contraseñas.</li>
        <li><b>Regla de Negocio:</b> Tras dar de alta el acceso, toda la documentación oficial (Contratos, RFC, Cuentas Bancarias) debe ser llenada en el módulo de <b>Recursos Humanos</b>.</li>
    </ul>
    
    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="mod-rh">1.2. 👥 Recursos Humanos (El Expediente Completo)</h3>
    El "Corazón" del personal. Es el módulo de uso exclusivo de RH y Administración.
    <ul>
        <li><b>Expediente Clínico Digital:</b> Almacena toda la información de contacto, médica, actas de nacimiento y referencias del empleado.</li>
        <li><b>Gestor Documental y Contractual:</b> Sube archivos escaneados (PDFs) y lleva el historial completo de las renovaciones de contrato del trabajador.</li>
        <li><b>Vacaciones y Permisos:</b> Calcula automáticamente los días correspondientes según la Ley Federal de Trabajo y gestiona la bandeja de aprobación de permisos (con o sin goce de sueldo).</li>
        <li><b>Registro de Trazabilidad:</b> Cualquier edición que se haga sobre un empleado queda sellada en el "Historial de Cambios" con la fecha, hora y el nombre del directivo que lo autorizó.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="mod-clientes-proveedores">1.3. 🤝 Clientes y 🏢 Proveedores</h3>
    Catálogos maestros comerciales.
    <ul>
        <li><b>Clientes:</b> Base de datos de agencias o empresas a las que VPRO emite facturas y proyectos. La creación de un evento u Orden de Producción exige un cliente pre-registrado.</li>
        <li><b>Proveedores:</b> Módulo para empresas que prestan servicios (carpas, templetes, transporte externo). Estos proveedores pueden ser "co-convocados" dentro de las Órdenes de Producción para llevar un control de quiénes nos apoyan en locación.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="mod-inventario">1.4. 🛠️ Inventario General y Kits</h3>
    La bóveda de activos y hardware de la compañía.
    <ul>
        <li><b>Activos Fijos:</b> Cada cable, monitor o cámara cuenta con un código/placa único.</li>
        <li><b>Kits Pre-Armados:</b> Agrupaciones lógicas (Ej. "Kit Pantallas LED 4x4") que aceleran el proceso de carga en Bodega sin tener que bipar cable por cable.</li>
        <li><b>Trazabilidad Activa:</b> El inventario bloquea equipos marcados como <code>DAÑADO</code> o <code>EN MANTENIMIENTO</code>, impidiendo que Logística los cargue por error a un evento.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="mod-autos">1.5. 🚗 Autos y Flotilla Vehicular</h3>
    Gestión del parque vehicular operativo.
    <ul>
        <li><b>Catálogo:</b> Registro de placas, seguros, número de motor y características.</li>
        <li><b>Bitácora de Eventos:</b> Si un vehículo se usa en un evento, el Productor registrará los kilómetros iniciales y finales, alimentando directamente la ficha histórica de cada camioneta para calcular su desgaste y próximos mantenimientos.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="mod-kiosco">2.1. 🕒 Kiosco / Reloj Checador</h3>
    Sistema de asistencia diario para el personal operativo y de oficina.
    <ul>
        <li><b>Claqueta Diaria:</b> Todo empleado registra su <b>ENTRADA</b> y <b>SALIDA</b> tecleando su NIP.</li>
        <li><b>Piloto Automático (Giras):</b> Si Recursos Humanos/Eventos etiqueta a un empleado como "En Ruta" o "En Viaje Foráneo", el sistema justifica sus faltas automáticamente, evitando que el Kiosco lo marque como ausente.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="mod-reporte-asistencia">2.2. ⏱️ Reporte y Auditoría de Asistencia</h3>
    Panel de uso exclusivo para Administración.
    <ul>
        <li><b>Auditoría en Tiempo Real:</b> Calcula retardos, horas trabajadas y ausencias de toda la plantilla.</li>
        <li><b>Aprobación de Horas Extras:</b> Cuando un evento termina de madrugada, las horas adicionales caen a una bandeja. RH debe autorizar explícitamente estas horas para que procedan al pago de nómina.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="fase-1">3.1. Planeación y Nacimiento del Proyecto (Módulo de Eventos)</h3>
    <b>Actor responsable:</b> Administración, Coordinación o Ventas.<br>
    <b>Objetivo:</b> Crear la Orden de Producción (OP) y definir responsables.
    <ul>
        <li>📝 <b>Captura de Datos Base:</b> Se llenan los datos vitales: Cliente, Evento, Locación, y Fechas de Montaje/Desmontaje.</li>
        <li>👤 <b>El Productor Responsable:</b> Se asigna al líder. <b>Candado:</b> El usuario elegido aquí será el único que podrá llenar el Reporte de Gastos al finalizar el evento.</li>
        <li>📋 <b>Logística y Convocatoria:</b> Se selecciona al personal técnico, proveedores y vehículos de flotilla a utilizar.</li>
        <li>✈️ <b>Viajes (Modo Gira):</b> Si el evento es foráneo, se activa el sello "Asistencia en Ruta". El sistema registra automáticamente asistencias virtuales para el personal, evitando reportes de inasistencia en oficina.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="fase-2">3.2. Despacho de Hardware (Módulo de Checkout - Salida)</h3>
    <b>Actor responsable:</b> Logística / Bodega.<br>
    <b>Objetivo:</b> Registrar exactamente qué equipo sale de las instalaciones hacia la OP.
    <ul>
        <li>🧳 <b>Carga de Equipo:</b> Bodega usa el "Inyector Rápido" o carga Kits pre-armados.</li>
        <li>🛡️ <b>Regla de Calidad:</b> El sistema bloquea duplicados. Si se escanean dos equipos iguales, obliga a unificar cantidades. No permite sacar equipo <code>DAÑADO</code>.</li>
        <li>🚚 <b>Tránsito:</b> Tras autorizar la salida, la OP cambia a <code>DESPACHADO</code>. El equipo queda bajo la custodia de producción.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="fase-3">3.3. Operación en Locación (Claqueta del Productor)</h3>
    <b>Responsable:</b> Productor Responsable.<br>
    <b>Objetivo:</b> Controlar los tiempos de trabajo en campo.
    <ul>
        <li>🟢 <b>Iniciar Llamado:</b> El Productor abre la OP en su celular, verifica qué personal asistió físicamente y presiona iniciar. Esto marca la HORA DE ENTRADA en el sistema de Asistencia general.</li>
        <li>🔴 <b>Terminar Jornada:</b> Al finalizar el desmontaje, sella la salida de su cuadrilla, calculando horas extras de forma exacta.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="fase-4">3.4. Retorno a Base y Liberación (Check-in de Bodega)</h3>
    <b>Actor responsable:</b> Logística / Bodega.<br>
    <b>Objetivo:</b> Recuperar hardware, auditar mermas y liberar finanzas.
    <ul>
        <li>✅ <b>Cotejo de Retorno:</b> Bodega marca casilla por casilla los cables y cases que regresan.</li>
        <li>🚦 <b>Auditoría de Daños Inteligente:</b> Si Bodega escribe en las Notas que un equipo llegó "roto" o "falló", el sistema detecta la palabra, manda el equipo a taller y cambia su estatus global a <code>DAÑADO</code>.</li>
        <li>🔐 <b>Candado Financiero:</b> Es matemáticamente imposible que el Productor compruebe gastos si Bodega no ha cerrado y recibido la OP completa.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="fase-5">3.5. Rendición de Cuentas (Reporte de Gastos)</h3>
    <b>Actor responsable:</b> Productor Responsable.<br>
    <b>Objetivo:</b> Comprobar viáticos y uso vehicular.
    <ul>
        <li>🚗 <b>Odómetros:</b> Obliga a capturar el Kilometraje Inicial y Final de cada camioneta involucrada.</li>
        <li>📊 <b>Matriz Dinámica:</b> El Productor captura gastos por día (Hotel, Casetas, Alimentos, Diésel).</li>
        <li>🧮 <b>Remanente Automático:</b> El sistema cruza el presupuesto entregado con el total gastado y dicta el "Remanente a Devolver" exacto.</li>
        <li>🖋️ <b>Cierre Final:</b> Al enviar el informe, la OP se bloquea para el productor y se envía directo al Buzón de Dirección.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="fase-6">3.6. Auditoría y Cierre Financiero (Buzón de Dirección)</h3>
    <b>Actor responsable:</b> Dirección / Administración.<br>
    <b>Objetivo:</b> Sellar el evento contablemente.
    <ul>
        <li>🔍 <b>Inspección y Cuadre Físico:</b> Dirección revisa que los tickets de papel (facturas) coincidan con el monto que arrojó el sistema.</li>
        <li>🖨️ <b>Descarga PDF:</b> Genera el Acuse de Recibo Oficial.</li>
        <li>📁 <b>Bóveda Histórica:</b> Al hacer clic en <b>Aprobar</b>, la OP desaparece de todos los tableros operativos de VPRO y se encripta como "Archivo Histórico" en modo de solo lectura. El evento está cerrado al 100%.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="fase-danos">3.7. 🛠️ Trazabilidad de Equipos Dañados (Taller)</h3>
    Existen dos compuertas oficiales para el reporte de mermas:
    <ul>
        <li><b>🚚 Canal A (Retorno de Eventos):</b> En el módulo de Check-in, si el almacenista detecta roturas, el sistema liga el daño automáticamente al Folio de la OP para saber en qué evento ocurrió la falla.</li>
        <li><b>🏢 Canal B (Oficinas):</b> Mantenimiento a aires acondicionados o PCs internas. Se levanta un ticket en el módulo "Equipos Dañados" adjuntando evidencia fotográfica.</li>
        <li><b>⚙️ Rehabilitación:</b> Desde el panel de Taller, los técnicos reparan y presionan "Rehabilitar Equipo", regresándolo a estado <code>OK</code> y liberándolo para nuevas rentas.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="mod-cotizaciones">4.1. 📄 Cotizaciones</h3>
    Gestión pre-operativa.
    <ul>
        <li>Diseño de estimaciones comerciales jalando costos directamente de la Base de Inventario (sin teclear precios manualmente).</li>
        <li>Si el cliente aprueba la cotización, esta se "Promueve" a Orden de Producción, ahorrando doble captura de datos en el sistema.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="mod-incidencias">4.2. ⚠️ Incidencias (Reportes Internos)</h3>
    Módulo disciplinario.
    <ul>
        <li>Levantamiento de reportes (ej. pérdida de llaves, faltas de respeto, accidentes) en contra de empleados.</li>
        <li>Cada incidencia se archiva permanentemente en el Expediente RH del trabajador para futuras métricas de desempeño o justificación de actas administrativas.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="mod-reuniones">4.3. 🤝 Minutas / Reuniones de Trabajo</h3>
    <ul>
        <li>Digitaliza los acuerdos tomados en las juntas de área directiva o producción.</li>
        <li>Asigna "To-Dos" (Tareas) al personal. Si no cumplen en la fecha prometida, el sistema arroja alertas rojas de incumplimiento de objetivos.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="mod-analitica">4.4. 📈 Analítica / KPIs Gerenciales</h3>
    Panel de alto nivel (Dashboards visuales exclusivos de Dirección).
    <ul>
        <li>Rentabilidad de Eventos vs Presupuesto en tiempo real.</li>
        <li>Frecuencia de Mantenimiento de Vehículos y Equipos.</li>
        <li>Desempeño y puntualidad del personal según el Kiosco y RH.</li>
    </ul>

    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a><hr>

    <h3 id="anexo-errores">5. 🚨 ANEXO: PROTOCOLOS DE CORRECCIÓN DE ERRORES</h3>
    La regla de oro del sistema es: <i>"El que envía información, ya no puede modificarla"</i>. Esto blinda a VPRO contra alteraciones y fraude. Sin embargo, hay protocolos "Salvavidas" para Administración:
    <ul>
        <li><b>Error en captura de Gastos:</b> Si el Productor mandó $500 en lugar de $50, él ya no puede editar. Dirección, desde el Buzón de Auditoría, tiene el privilegio de dar "doble clic" a la celda errónea, corregirla y el sistema recalcula el remanente automáticamente.</li>
        <li><b>Personal olvidado en "Llamado":</b> Si el productor olvidó marcar la salida de su gente en la locación, el servidor VPRO detecta a las 19:00 hrs a la gente perdida y cierra sus turnos. Adicionalmente, RH puede editar sus bitácoras de manera plana (manual).</li>
        <li><b>Falso reporte de Equipo Dañado:</b> Si Bodega mandó algo a taller por error, el técnico solo debe buscar el equipo en su Expediente Clínico y marcarlo como "Falsa Alarma - Operativo", regresándolo al juego sin registrar reparación.</li>
    </ul>
    
    <a href="#indice-general-interactivo">⬆️ Volver al Índice</a>

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