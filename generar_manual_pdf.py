"""
Generador de Manual Oficial en PDF: Reporte y Trazabilidad de Equipos Dañados (VPRO System)
Utiliza ReportLab para compilar un documento corporativo de alta calidad técnica y visual.
"""

import os
import sys
from datetime import datetime
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether
)
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    """Canvas personalizado que calcula el número total de páginas y agrega encabezado y pie de página."""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        # Omitir en la portada (página 1)
        if self._pageNumber == 1:
            return

        self.saveState()
        self.setFont("Helvetica", 8)
        self.setFillColor(colors.HexColor("#64748B"))

        # Encabezado superior
        self.drawString(54, 750, "🎬 VPRO PRODUCCIONES | SISTEMA DE CONTROL Y TRAZABILIDAD OPERATIVA")
        self.drawRightString(612 - 54, 750, "MANUAL DE EQUIPOS DAÑADOS")
        self.setStrokeColor(colors.HexColor("#CBD5E1"))
        self.setLineWidth(0.5)
        self.line(54, 742, 612 - 54, 742)

        # Pie de página inferior
        self.line(54, 45, 612 - 54, 45)
        self.drawString(54, 32, "Confidencial - Uso Interno Exclusivo VPRO Dashboard v8.1")
        page_text = f"Página {self._pageNumber} de {page_count}"
        self.drawRightString(612 - 54, 32, page_text)
        self.restoreState()


def crear_manual_pdf(output_path="Manual_Trazabilidad_Reporte_Equipos_Danados_VPRO.pdf"):
    doc = SimpleDocTemplate(
        output_path,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )

    styles = getSampleStyleSheet()

    # Estilos tipográficos personalizados
    title_cover = ParagraphStyle(
        'CoverTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=22,
        leading=26,
        textColor=colors.HexColor("#0F172A"),
        alignment=0
    )

    subtitle_cover = ParagraphStyle(
        'CoverSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=11,
        leading=15,
        textColor=colors.HexColor("#0284C7"),
        alignment=0
    )

    h1_style = ParagraphStyle(
        'Header1',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=16,
        textColor=colors.HexColor("#0F172A"),
        spaceBefore=12,
        spaceAfter=5,
        keepWithNext=True
    )

    h2_style = ParagraphStyle(
        'Header2',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=10.5,
        leading=13,
        textColor=colors.HexColor("#0369A1"),
        spaceBefore=8,
        spaceAfter=3,
        keepWithNext=True
    )

    body_style = ParagraphStyle(
        'BodyDark',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=12,
        textColor=colors.HexColor("#1E293B"),
        spaceAfter=5
    )

    bullet_style = ParagraphStyle(
        'BulletText',
        parent=body_style,
        leftIndent=12,
        firstLineIndent=-8,
        spaceAfter=3
    )

    callout_style = ParagraphStyle(
        'CalloutText',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=12,
        textColor=colors.HexColor("#0F172A")
    )

    table_cell = ParagraphStyle(
        'TableCell',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=7.5,
        leading=10,
        textColor=colors.HexColor("#0F172A")
    )

    table_header = ParagraphStyle(
        'TableHeader',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=10,
        textColor=colors.white
    )

    story = []

    # ==========================================
    # 🌟 PORTADA / PRIMERA SECCIÓN
    # ==========================================
    banner_data = [[
        Paragraph("<b>MANUAL TÉCNICO & OPERATIVO</b><br/><font size=8.5 color='#BAE6FD'>GESTIÓN DE ACTIVOS, LOGÍSTICA DE BODEGA Y TALLER DE REPARACIONES</font>", ParagraphStyle('Bnr', parent=styles['Normal'], fontName='Helvetica', fontSize=10, leading=14, textColor=colors.white))
    ]]
    banner_table = Table(banner_data, colWidths=[504])
    banner_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#0369A1")),
        ('PADDING', (0,0), (-1,-1), 10),
        ('BOTTOMPADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(banner_table)
    story.append(Spacer(1, 15))

    story.append(Paragraph("TRAZABILIDAD INTEGRAL EN REPORTE DE EQUIPOS DAÑADOS", title_cover))
    story.append(Spacer(1, 5))
    story.append(Paragraph("Protocolo Unificado: Retorno de Eventos (Check-in) y Falla en Instalaciones (Mantenimiento Interno)", subtitle_cover))
    story.append(Spacer(1, 12))

    meta_info = [
        [Paragraph("<b>Sistema:</b> VPRO Dashboard & Core API Engine", table_cell), Paragraph("<b>Versión:</b> 8.1.0 Enterprise", table_cell)],
        [Paragraph("<b>Áreas de Aplicación:</b> Bodega, Logística, Sistemas, Operaciones, Dirección", table_cell), Paragraph(f"<b>Fecha de Emisión:</b> {datetime.now().strftime('%d/%m/%Y')}", table_cell)],
        [Paragraph("<b>Documento:</b> GUÍA-SOP-VPRO-DAÑOS-2026", table_cell), Paragraph("<b>Nivel de Seguridad:</b> Operativo / Auditoría", table_cell)]
    ]
    t_meta = Table(meta_info, colWidths=[270, 234])
    t_meta.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#F8FAFC")),
        ('BOX', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('PADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(t_meta)
    story.append(Spacer(1, 12))

    # Cuadro de Resumen Ejecutivo
    resumen_box = [[
        Paragraph(
            "<b>🎯 OBJETIVO DEL MANUAL:</b><br/>"
            "Establecer con precisión matemática y operativa cómo se detecta, registra, audita y rehabilita cualquier activo o equipo dañado en la empresa. "
            "El sistema garantiza que ningún hardware roto quede extraviado o sea asignado por error a otra producción, amarrando cada incidencia "
            "con su folio de evento (OP) o ticket interno de instalaciones.",
            callout_style
        )
    ]]
    t_resumen = Table(resumen_box, colWidths=[504])
    t_resumen.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#EFF6FF")),
        ('LINELEFT', (0,0), (0,0), 4, colors.HexColor("#0284C7")),
        ('BOX', (0,0), (-1,-1), 0.5, colors.HexColor("#BFDBFE")),
        ('PADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_resumen)
    story.append(Spacer(1, 14))

    # ==========================================
    # 📌 SECCIÓN 1: LOS DOS CANALES DE REPORTE
    # ==========================================
    story.append(Paragraph("1. La Arquitectura Dual de Reporte de Daños", h1_style))
    story.append(Paragraph(
        "Para comprender la trazabilidad del sistema VPRO, es fundamental entender que existen <b>dos canales complementarios</b> de entrada para reportar un equipo dañado, dependiendo de la ubicación y causa de la avería:",
        body_style
    ))

    canales_data = [
        [
            Paragraph("<b>CANAL A: RETORNO DE EVENTO (BODEGA / CHECK-IN)</b>", table_header),
            Paragraph("<b>CANAL B: INSTALACIONES / OFICINA (TALLER / MANTO.)</b>", table_header)
        ],
        [
            Paragraph(
                "• <b>Origen:</b> Equipo físico que regresa de una filmación o llamado de producción.<br/>"
                "• <b>Módulo:</b> Checkout / Check-in (<code>mod_checkout.py</code>).<br/>"
                "• <b>Disparador:</b> Campo <i>'Nota de regreso (incidencia)'</i> en la matriz de cotejo.<br/>"
                "• <b>Detección:</b> Semáforo inteligente con palabras clave (<i>daño, roto, quebró, falló, golpe</i>).<br/>"
                "• <b>Folio Asignado:</b> <code>OP-XXX</code> (amarrado a la Orden de Producción).<br/>"
                "• <b>Ticket de Taller:</b> Prefijo <code>REP-RUT-timestamp-cod</code>.<br/>"
                "• <b>Reportante:</b> 'Operación / Ruta (Check-in)'.",
                table_cell
            ),
            Paragraph(
                "• <b>Origen:</b> Activos fijos internos de instalaciones (Aire Acondicionado, PCs de edición, monitores, mobiliario o herramientas de bodega).<br/>"
                "• <b>Módulo:</b> Equipos con Daño / Taller (<code>mod_equipos_danados.py</code>).<br/>"
                "• <b>Disparador:</b> Formulario <i>'🛠️ Registrar Reporte Directo'</i>.<br/>"
                "• <b>Detección:</b> Captura manual de diagnóstico, tipo de evento y costo.<br/>"
                "• <b>Folio Asignado:</b> <code>MANTENIMIENTO_INTERNO</code>.<br/>"
                "• <b>Ticket de Taller:</b> Prefijo <code>REP-INT-timestamp</code>.<br/>"
                "• <b>Reportante:</b> ID del empleado y departamento que levantó la falla.",
                table_cell
            )
        ]
    ]
    t_canales = Table(canales_data, colWidths=[252, 252])
    t_canales.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (0,0), colors.HexColor("#1E3A8A")),
        ('BACKGROUND', (1,0), (1,0), colors.HexColor("#065F46")),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('PADDING', (0,0), (-1,-1), 6),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('BACKGROUND', (0,1), (0,1), colors.HexColor("#F8FAFC")),
        ('BACKGROUND', (1,1), (1,1), colors.HexColor("#F0FDF4")),
    ]))
    story.append(t_canales)
    story.append(Spacer(1, 12))

    # ==========================================
    # 📌 SECCIÓN 2: DIAGRAMA DE TRAZABILIDAD
    # ==========================================
    story.append(Paragraph("2. Diagrama de Trazabilidad y Ciclo de Vida", h1_style))
    story.append(Paragraph(
        "A continuación se presenta el flujo cronológico y los estados del hardware desde que se detecta el problema hasta que regresa a la operación activa:",
        body_style
    ))

    pasos_ciclo = [
        [Paragraph("<b>Paso</b>", table_header), Paragraph("<b>Fase</b>", table_header), Paragraph("<b>Acción Operativa</b>", table_header), Paragraph("<b>Impacto en BD (Postgres)</b>", table_header)],
        [
            Paragraph("<b>1</b>", table_cell),
            Paragraph("<b>Detección</b>", table_cell),
            Paragraph("El equipo falla en evento o en oficina (ej. A/C gotea o cámara tiene sensor dañado).", table_cell),
            Paragraph("Estado actual: En uso / En set.", table_cell)
        ],
        [
            Paragraph("<b>2</b>", table_cell),
            Paragraph("<b>Captura</b>", table_cell),
            Paragraph("• Canal A: En Check-in se escribe en <i>'Nota de regreso'</i>.<br/>• Canal B: En Equipos con Daño se llena el formulario directo con foto.", table_cell),
            Paragraph("Se dispara llamada HTTP POST a la API (<code>/api/checkout/finalizar-checkin</code> o <code>/api/inventario/historial/guardar</code>).", table_cell)
        ],
        [
            Paragraph("<b>3</b>", table_cell),
            Paragraph("<b>Afectación en BD</b>", table_cell),
            Paragraph("El sistema inyecta registros automáticamente en 3 tablas simultáneas.", table_cell),
            Paragraph("1. <code>inventario</code>: <code>estado = 'DAÑADO'</code><br/>2. <code>historial_equipo</code>: Evento clínico registrado.<br/>3. <code>reparaciones</code>: Ticket abierto en taller.", table_cell)
        ],
        [
            Paragraph("<b>4</b>", table_cell),
            Paragraph("<b>Atención Taller</b>", table_cell),
            Paragraph("El equipo aparece en el <b>Radar de Daños</b> con contador de días fuera de servicio.", table_cell),
            Paragraph("El técnico consulta el <b>Expediente Clínico</b> y visualiza la foto de evidencia.", table_cell)
        ],
        [
            Paragraph("<b>5</b>", table_cell),
            Paragraph("<b>Rehabilitación</b>", table_cell),
            Paragraph("El técnico repara el equipo y presiona <b>'✅ REHABILITAR EQUIPO'</b> marcándolo como <code>REPARADO</code> o <code>RESUELTO</code>.", table_cell),
            Paragraph("1. <code>reparaciones</code>: <code>estado_actual = 'RESUELTO'</code><br/>2. <code>inventario</code>: <code>estado = 'OK'</code> / <code>'BUEN ESTADO'</code>.<br/>¡Vuelve a estar listo para eventos!", table_cell)
        ]
    ]
    t_pasos = Table(pasos_ciclo, colWidths=[30, 70, 204, 200])
    t_pasos.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#0F172A")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('PADDING', (0,0), (-1,-1), 4),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor("#F8FAFC")]),
    ]))
    story.append(t_pasos)

    story.append(PageBreak())

    # ==========================================
    # 📌 SECCIÓN 3: FLUJO DETALLADO - CHECK-IN
    # ==========================================
    story.append(Paragraph("3. Flujo Detallado: Retorno de Evento (Módulo Check-in)", h1_style))
    story.append(Paragraph(
        "El módulo de Check-in es la <b>aduana principal</b> del hardware de producción. Su función es verificar que lo que salió a llamado regrese íntegro a bodega.",
        body_style
    ))

    story.append(Paragraph("Paso a Paso del Operador de Bodega:", h2_style))
    story.append(Paragraph("<b>1. Acceso a la OP:</b> El almacenista abre el menú <code>Logística &gt; Check-in</code> y selecciona la Orden de Producción que acaba de llegar de locación.", bullet_style))
    story.append(Paragraph("<b>2. Cotejo Físico:</b> El sistema muestra la tabla con las piezas despachadas. El almacenista desempaca las maletas y marca la casilla <code>✅ COTEJO (¿Regresó?)</code>.", bullet_style))
    story.append(Paragraph("<b>3. Reporte en la Columna 'Nota de Regreso (Incidencia)':</b> Si un equipo presenta avería, golpe, fisura o falla electrónica, se escribe detalladamente en la celda de esa misma fila.", bullet_style))

    alert_box = [[
        Paragraph(
            "<b>🧠 SEMÁFORO INTELIGENTE DE TEXTO:</b><br/>"
            "El sistema escanea el contenido escrito en la columna <i>'OBS_REGRESO'</i>. Si detecta fragmentos como: "
            "<code>dañ</code>, <code>rot</code>, <code>fall</code>, <code>quebr</code>, <code>freg</code>, <code>mal</code>, <code>golp</code>, <code>perd</code> o <code>abiert</code>, "
            "el sistema automáticamente cataloga el equipo con estatus <b>DAÑADO</b> sin necesidad de que el usuario lo configure manualmente.",
            callout_style
        )
    ]]
    t_alert = Table(alert_box, colWidths=[504])
    t_alert.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#FEF2F2")),
        ('LINELEFT', (0,0), (0,0), 4, colors.HexColor("#EF4444")),
        ('BOX', (0,0), (-1,-1), 0.5, colors.HexColor("#FECACA")),
        ('PADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(t_alert)
    story.append(Spacer(1, 6))

    story.append(Paragraph("<b>4. Acta de Incidencias de Proveedores (Opcional):</b> Si el daño fue provocado por un proveedor externo co-convocado (ej. mobiliario, plantas de luz, transporte), Bodega selecciona al proveedor en el recuadro inferior y describe lo sucedido. El sistema crea un ticket administrativo especial con prefijo <code>REP-PRV-</code>.", bullet_style))
    story.append(Paragraph("<b>5. Finalización y Bloqueo Financiero:</b> Al hacer clic en <b>'💾 FINALIZAR REVISIÓN Y REGRESO'</b>:<br/>"
                           "• La OP pasa a estatus <code>RECIBIDO</code>.<br/>"
                           "• Se desbloquea el módulo para que el Productor pueda rendir sus viáticos (Candado Financiero VPRO).<br/>"
                           "• El equipo averiado queda bloqueado en inventario como <code>DAÑADO</code> y no podrá ser asignado a ninguna otra OP.", bullet_style))

    story.append(Spacer(1, 10))

    # ==========================================
    # 📌 SECCIÓN 4: FLUJO DETALLADO - INSTALACIONES Y OFICINA
    # ==========================================
    story.append(Paragraph("4. Flujo Detallado: Activos de Instalaciones y Oficina", h1_style))
    story.append(Paragraph(
        "En la empresa existen activos que <b>nunca van a llamado en eventos</b>, pero sufren desgaste o averías: el aire acondicionado (Mini Split) de Sistemas o Dirección, las computadoras de escritorio de los editores, monitores auxiliares, servidores, refrigeradores o mobiliario de oficina.",
        body_style
    ))

    story.append(Paragraph("Procedimiento para Reporte Directo de Oficina:", h2_style))
    story.append(Paragraph("<b>1. Acceso al Módulo:</b> Cualquier empleado autorizado ingresa a <code>🛠️ Equipos con Daño</code> y abre el expander <b>'🛠️ REGISTRAR REPORTE DIRECTO DE OFICINA / MANTENIMIENTO INTERNO'</b>.", bullet_style))
    story.append(Paragraph("<b>2. Búsqueda en el Catálogo Institucional:</b> El usuario busca en el menú desplegable el activo afectado. Las opciones muestran el código y la descripción formal, por ejemplo:<br/>"
                           "&nbsp;&nbsp;&nbsp;&nbsp;• <code>VPRO-AA-SISTEMAS - A/Acondicionado Marca Mirage en Ofna Sistemas</code><br/>"
                           "&nbsp;&nbsp;&nbsp;&nbsp;• <code>VPNFIJ005 - Aire acondicionado tipo Mini Split 2 ton. Mirage Absolut</code><br/>"
                           "&nbsp;&nbsp;&nbsp;&nbsp;• <code>COMPUTADORA DE ESCRITORIO CON DOS MONITORES</code>", bullet_style))
    story.append(Paragraph("<b>3. Clasificación del Tipo de Evento:</b> Se selecciona la categoría técnica adecuada: <code>MANTENIMIENTO_TÉCNICO</code>, <code>FALLA_OPERATIVA</code>, <code>DAÑO_FÍSICO_OFICINA</code> o <code>RESPALDO_SISTEMAS</code>.", bullet_style))
    story.append(Paragraph("<b>4. Diagnóstico Detallado:</b> Redactar en el área de texto la falla observada (ej. <i>'El Mini Split tira agua sobre el escritorio de Sistemas y hace ruido excesivo el compresor'</i>).", bullet_style))
    story.append(Paragraph("<b>5. Evidencia Fotográfica (Obligatorio/Recomendado):</b> Adjuntar fotografía en formato JPG/PNG. El sistema guardará la imagen como:<br/>"
                           "&nbsp;&nbsp;&nbsp;&nbsp;<code>Fotos_de_equipos/Evidencia_MANTENIMIENTO_INTERNO_[CODIGO].jpg</code>", bullet_style))
    story.append(Paragraph("<b>6. Registro en Postgres:</b> Al presionar <b>'💾 REGISTRAR TICKET EN POSTGRES'</b>, el sistema genera el ticket <code>REP-INT-timestamp</code> asignado al departamento del usuario y a su ID de empleado.", bullet_style))

    story.append(Spacer(1, 6))

    regla_inv = [[
        Paragraph(
            "<b>⚠️ ¿QUÉ HACER SI EL ARTÍCULO NO APARECE EN EL CATÁLOGO?</b><br/>"
            "Si se daña una silla ejecutiva, una cafetera, una herramienta nueva o un equipo recién adquirido y no aparece en la lista desplegable:<br/>"
            "<b>1.</b> No intentar forzar un reporte con otro nombre.<br/>"
            "<b>2.</b> Acudir con el <b>Coordinador / Administrador</b> para darlo de alta en el Inventario Institucional (módulo <i>Inventario &gt; Guardar</i>).<br/>"
            "<b>3.</b> Una vez registrado con su código oficial, regresar a este formulario para levantar su ticket con evidencia fotográfica.",
            callout_style
        )
    ]]
    t_regla = Table(regla_inv, colWidths=[504])
    t_regla.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#FFFBEB")),
        ('LINELEFT', (0,0), (0,0), 4, colors.HexColor("#D97706")),
        ('BOX', (0,0), (-1,-1), 0.5, colors.HexColor("#FDE68A")),
        ('PADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(t_regla)

    story.append(PageBreak())

    # ==========================================
    # 📌 SECCIÓN 5: LA CONSOLA DE TALLER Y REHABILITACIÓN
    # ==========================================
    story.append(Paragraph("5. Consola de Taller: Radar de Daños y Expediente Clínico", h1_style))
    story.append(Paragraph(
        "La pantalla principal de <b>Equipos con Daño</b> funciona como la consola central de mantenimiento de VPRO. Cuenta con dos pestañas de trabajo:",
        body_style
    ))

    story.append(Paragraph("Pestaña 1: Radar y Reportes Activos", h2_style))
    story.append(Paragraph("• <b>Métricas de Control:</b> Muestra en tiempo real el total de tickets activos, el promedio de días que los equipos llevan fuera de servicio, el mayor reportante y el departamento con mayor incidencia.<br/>"
                           "• <b>Filtros de Auditoría:</b> Permite filtrar por rango de fechas, departamento (Administración, Edición, Producción, Sistemas, Ventas) o por empleado responsable.<br/>"
                           "• <b>Matriz Activa de Reparaciones:</b> Tabla donde se observan los tickets (<code>REP-RUT-</code> o <code>REP-INT-</code>), código, nombre del equipo, reportante, falla y costo estimado.", body_style))

    story.append(Paragraph("Pestaña 2: Expediente Clínico (Historial del Hardware)", h2_style))
    story.append(Paragraph("• <b>Búsqueda Individual:</b> Al seleccionar cualquier equipo de la empresa, el sistema consulta su historial completo en <code>public.historial_equipo</code>.<br/>"
                           "• <b>Fotografía Sincronizada:</b> Despliega en pantalla la foto de evidencia capturada al momento del reporte.<br/>"
                           "• <b>Historial de Movimientos:</b> Tabla cronológica con cada servicio, falla, costo asociado y técnico que intervino en la vida útil del activo.", body_style))

    story.append(Spacer(1, 8))
    story.append(Paragraph("Proceso de Rehabilitación (Cierre de Ticket)", h2_style))
    story.append(Paragraph(
        "Cuando el personal técnico, taller externo o sistemas termina la compostura física del equipo, se debe aplicar el siguiente protocolo:",
        body_style
    ))

    rehab_steps = [
        [Paragraph("<b>Paso</b>", table_header), Paragraph("<b>Instrucción en Pantalla</b>", table_header), Paragraph("<b>Resultado en el Sistema</b>", table_header)],
        [
            Paragraph("<b>1</b>", table_cell),
            Paragraph("En la sección inferior <i>'Actualizar o Cerrar Ticket de Reparación'</i>, localizar el número de ticket (ej. <code>REP-INT-1788212086</code>).", table_cell),
            Paragraph("El sistema vincula el ticket con el registro de la tabla <code>reparaciones</code>.", table_cell)
        ],
        [
            Paragraph("<b>2</b>", table_cell),
            Paragraph("En el menú <i>'Nuevo Estado'</i>, elegir una de las 3 opciones:<br/>• <b>REPARADO</b> o <b>RESUELTO</b> (Si ya funciona al 100%).<br/>• <b>BAJA DEFINITIVA</b> (Si fue pérdida total o incosteable).", table_cell),
            Paragraph("Define el destino final operativo del activo.", table_cell)
        ],
        [
            Paragraph("<b>3</b>", table_cell),
            Paragraph("Presionar el botón verde <b>'✅ REHABILITAR EQUIPO / CERRAR TICKET'</b>.", table_cell),
            Paragraph("• El ticket desaparece del Radar Activo.<br/>• El activo en <code>inventario</code> cambia a <code>OK</code>.<br/>• En <code>inventario_kits</code> cambia a <code>BUEN ESTADO</code>.<br/>• Queda disponible de inmediato para nuevas OPs.", table_cell)
        ]
    ]
    t_rehab = Table(rehab_steps, colWidths=[30, 237, 237])
    t_rehab.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#065F46")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('PADDING', (0,0), (-1,-1), 5),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor("#F0FDF4")]),
    ]))
    story.append(t_rehab)

    story.append(Spacer(1, 10))

    # ==========================================
    # 📌 SECCIÓN 6: MATRIZ TÉCNICA DE BASE DE DATOS
    # ==========================================
    story.append(Paragraph("6. Matriz Técnica de Base de Datos y Trazabilidad", h1_style))
    story.append(Paragraph(
        "Para el equipo de Desarrollo y Auditoría de Sistemas, esta es la correlación exacta de tablas y llaves que garantizan la integridad referencial:",
        body_style
    ))

    db_matrix = [
        [Paragraph("<b>Tabla en PostgreSQL</b>", table_header), Paragraph("<b>Campos Clave Modificados</b>", table_header), Paragraph("<b>Propósito Operativo</b>", table_header)],
        [
            Paragraph("<code>public.inventario</code>", table_cell),
            Paragraph("<code>estado = 'DAÑADO' | 'OK'<br/>ubicacion = 'BODEGA'<br/>observaciones = [diagnóstico]</code>", table_cell),
            Paragraph("Gobernanza del hardware maestro. Bloquea o autoriza la salida de equipo en futuras OPs.", table_cell)
        ],
        [
            Paragraph("<code>public.inventario_kits</code>", table_cell),
            Paragraph("<code>estado_inv_kits = 'DANADO' | 'BUEN ESTADO'<br/>ubicacion_inv_kits = 'BODEGA'</code>", table_cell),
            Paragraph("Gobernanza de piezas individuales y kits de producción alternos.", table_cell)
        ],
        [
            Paragraph("<code>public.historial_equipo</code>", table_cell),
            Paragraph("<code>codigo_equipo, fecha, folio_vpro,<br/>id_empleado, tipo_evento, descripcion,<br/>costo_asociado, estado_final, depto</code>", table_cell),
            Paragraph("Expediente Clínico del Hardware. Bitácora inmutable de todo lo que le ha pasado al activo en su vida útil.", table_cell)
        ],
        [
            Paragraph("<code>public.reparaciones</code>", table_cell),
            Paragraph("<code>num_d_servicio (REP-RUT- / REP-INT-),<br/>equipo_n_reparacion, reportante,<br/>estado_actual, descripcion_del_dano, folio_vpro</code>", table_cell),
            Paragraph("Tablero Kanban de taller. Controla los tickets abiertos y cerrados para el personal de soporte.", table_cell)
        ],
        [
            Paragraph("<code>public.checkouts_detalle</code>", table_cell),
            Paragraph("<code>cotejado (Boolean), notas_regreso</code>", table_cell),
            Paragraph("Guarda el cotejo físico exacto firmado por bodega al momento de recibir las maletas del evento.", table_cell)
        ],
        [
            Paragraph("<code>public.checkouts_maestro</code>", table_cell),
            Paragraph("<code>estado_bodega = 'RECIBIDO',<br/>incidencias_generales, fecha, hora</code>", table_cell),
            Paragraph("Sello de liberación de la Orden de Producción. Permite al Productor comprobar sus gastos.", table_cell)
        ]
    ]
    t_db = Table(db_matrix, colWidths=[110, 194, 200])
    t_db.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1E293B")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('PADDING', (0,0), (-1,-1), 4),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor("#F8FAFC")]),
    ]))
    story.append(t_db)

    story.append(Spacer(1, 10))

    # ==========================================
    # 📌 SECCIÓN 7: PREGUNTAS FRECUENTES Y MITIGACIÓN
    # ==========================================
    story.append(Paragraph("7. Preguntas Frecuentes y Resolución de Incidencias", h1_style))

    faqs = [
        ("¿Qué pasa si Bodega reportó daño por error en Check-in pero el equipo servía?",
         "Si solo fue una confusión (ej. un cable flojo), el técnico debe ir a 'Equipos con Daño', buscar el ticket recién creado en la sección inferior, seleccionarlo y cerrarlo inmediatamente con estatus 'RESUELTO'. El sistema regresará el activo a 'OK' en inventario."),
        ("¿Por qué un Productor no puede llenar su Reporte de Gastos si no se ha hecho Check-in?",
         "Es una regla de negocio y candado financiero estricto de VPRO: No se pueden liquidar viáticos ni finiquitar cuentas con un Productor mientras el equipo físico de filmación siga bajo su custodia en la calle."),
        ("¿Cómo reporto equipo de oficina que no tiene código de barras ni etiqueta VPRO?",
         "Todo activo sujeto a mantenimiento debe tener ficha en el sistema. Debe notificarse a Coordinación para que le asigne un código oficial (ej. VPRO-MUEBLE-01) en el módulo de Inventario. Tras esto, podrá reportarse con trazabilidad permanente."),
        ("¿Dónde se guardan físicamente las fotos de evidencia?",
         "Se transfieren al directorio seguro 'Fotos_de_equipos/' en el servidor central y son servidas a través de la API en el endpoint estático '/evidencias_web/', garantizando acceso rápido desde cualquier terminal autorizada.")
    ]

    for q, a in faqs:
        story.append(Paragraph(f"<b>❓ {q}</b>", h2_style))
        story.append(Paragraph(f"{a}", body_style))
        story.append(Spacer(1, 2))

    # Construcción final del PDF
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"Manual PDF generado exitosamente en: {os.path.abspath(output_path)}")
    return os.path.abspath(output_path)


if __name__ == "__main__":
    crear_manual_pdf()

