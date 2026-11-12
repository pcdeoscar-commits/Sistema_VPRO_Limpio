import sys
import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE

# 1. Crear Presentación 16:9 Panorámica
prs = Presentation()
prs.slide_width = Inches(13.333)
prs.slide_height = Inches(7.5)
blank_layout = prs.slide_layouts[6]  # Diapositiva en blanco

# Paleta de Colores Minimalista & Corporativa
DARK_BG = RGBColor(11, 15, 25)        # #0B0F19 (Deep Slate)
DARK_CARD = RGBColor(19, 26, 42)      # #131A2A
DARK_BORDER = RGBColor(37, 47, 69)    # #252F45

LIGHT_BG = RGBColor(248, 250, 252)    # #F8FAFC (Clean Snow)
LIGHT_CARD = RGBColor(255, 255, 255)  # #FFFFFF
LIGHT_BORDER = RGBColor(226, 232, 240)# #E2E8F0

CYAN_ACCENT = RGBColor(14, 165, 233)  # #0EA5E9 (VPRO Cyan)
RED_ACCENT = RGBColor(239, 68, 68)    # #EF4444 (VPRO Red)
AMBER_ACCENT = RGBColor(245, 158, 11) # #F59E0B
GREEN_ACCENT = RGBColor(16, 185, 129) # #10B981

TEXT_WHITE = RGBColor(255, 255, 255)
TEXT_MUTED_DARK = RGBColor(148, 163, 184) # #94A3B8
TEXT_BLACK = RGBColor(15, 23, 42)         # #0F172A
TEXT_MUTED_LIGHT = RGBColor(100, 116, 139)# #64748B

BANNER_3PANEL = r'prueba_web\vendor\img\vpro_banner_3paneles.png'
BANNER_INST = r'prueba_web\vendor\img\vpro_banner_institucional.png'
LOGO_ISO = r'prueba_web\vendor\img\vpro_iso_9001_hq.jpg'
LOGO_VPRO = r'prueba_web\vendor\img\vpro_logo_oficial.png'

FOOTER_SIGNATURE = "Powered by VPRO — Cuahutémoc Rivera Agúndez & Ag AI Partners"
SYSTEM_SUBTITLE = "VPRO DASHBOARD ENTERPRISE v2.4.0 • SISTEMA INTEGRAL DIGITAL"

def agregar_fondo(slide, es_oscuro=True):
    bg_shape = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
    bg_shape.fill.solid()
    bg_shape.fill.fore_color.rgb = DARK_BG if es_oscuro else LIGHT_BG
    bg_shape.line.color.rgb = DARK_BG if es_oscuro else LIGHT_BG
    return bg_shape

def agregar_footer(slide, es_oscuro=True, pagina=1, total=10):
    tx_box = slide.shapes.add_textbox(Inches(0.8), Inches(6.9), Inches(11.733), Inches(0.4))
    tf = tx_box.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = f"{SYSTEM_SUBTITLE}   |   {FOOTER_SIGNATURE}"
    p.font.size = Pt(8.5)
    p.font.bold = True
    p.font.name = "Segoe UI"
    p.font.color.rgb = TEXT_MUTED_DARK if es_oscuro else TEXT_MUTED_LIGHT
    p.alignment = PP_ALIGN.LEFT

    # Número de diapositiva
    p2 = tf.add_paragraph()
    p2.text = f"{pagina:02d} / {total:02d}"
    p2.font.size = Pt(8.5)
    p2.font.bold = True
    p2.font.name = "Segoe UI"
    p2.font.color.rgb = CYAN_ACCENT if es_oscuro else RGBColor(2, 132, 199)
    p2.alignment = PP_ALIGN.RIGHT
    tx_box.top = Inches(6.85)

def crear_tarjeta(slide, x, y, w, h, es_oscuro=True):
    card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(x), Inches(y), Inches(w), Inches(h))
    card.fill.solid()
    card.fill.fore_color.rgb = DARK_CARD if es_oscuro else LIGHT_CARD
    card.line.color.rgb = DARK_BORDER if es_oscuro else LIGHT_BORDER
    card.line.width = Pt(1.2)
    return card

# ═══════════════════════════════════════════════════════════════════
# SLIDE 1: PORTADA EJECUTIVA (DARK THEME)
# ═══════════════════════════════════════════════════════════════════
s1 = prs.slides.add_slide(blank_layout)
agregar_fondo(s1, es_oscuro=True)

# Banner 3 Paneles en la parte superior derecha
if os.path.exists(BANNER_3PANEL):
    s1.shapes.add_picture(BANNER_3PANEL, Inches(8.5), Inches(0.8), width=Inches(4.0))

# Badge ISO
if os.path.exists(LOGO_ISO):
    s1.shapes.add_picture(LOGO_ISO, Inches(0.8), Inches(0.8), width=Inches(1.1), height=Inches(1.1))

# Título y Subtítulo
tbox1 = s1.shapes.add_textbox(Inches(0.8), Inches(2.2), Inches(11.7), Inches(3.2))
tf1 = tbox1.text_frame
tf1.word_wrap = True

p_pill = tf1.paragraphs[0]
p_pill.text = "⚡ PLATAFORMA INTEGRAL DE GESTIÓN & TRANSMISIÓN BROADCAST"
p_pill.font.size = Pt(11)
p_pill.font.bold = True
p_pill.font.color.rgb = CYAN_ACCENT
p_pill.font.name = "Segoe UI"
p_pill.space_after = Pt(12)

p_tit = tf1.add_paragraph()
p_tit.text = "VPRO DASHBOARD ENTERPRISE"
p_tit.font.size = Pt(36)
p_tit.font.bold = True
p_tit.font.color.rgb = TEXT_WHITE
p_tit.font.name = "Segoe UI"
p_tit.space_after = Pt(8)

p_sub = tf1.add_paragraph()
p_sub.text = "Sistema Unificado de Gestión Empresarial y Operaciones Audiovisuales (ERP · CRM · HRMS · Broadcast Ops)"
p_sub.font.size = Pt(16)
p_sub.font.color.rgb = TEXT_MUTED_DARK
p_sub.font.name = "Segoe UI"
p_sub.space_after = Pt(28)

# Tarjeta de Créditos / Powered By
c_cred = crear_tarjeta(s1, 0.8, 5.2, 11.733, 1.25, es_oscuro=True)
tbox_cred = s1.shapes.add_textbox(Inches(1.1), Inches(5.35), Inches(11.1), Inches(0.95))
tfc = tbox_cred.text_frame
tfc.word_wrap = True

pc1 = tfc.paragraphs[0]
pc1.text = "ARQUITECTURA Y DESARROLLO TECNOLÓGICO"
pc1.font.size = Pt(10)
pc1.font.bold = True
pc1.font.color.rgb = AMBER_ACCENT
pc1.font.name = "Segoe UI"

pc2 = tfc.add_paragraph()
pc2.text = FOOTER_SIGNATURE
pc2.font.size = Pt(15)
pc2.font.bold = True
pc2.font.color.rgb = TEXT_WHITE
pc2.font.name = "Segoe UI"

agregar_footer(s1, es_oscuro=True, pagina=1)

# ═══════════════════════════════════════════════════════════════════
# SLIDE 2: VISIÓN INTEGRAL (LIGHT THEME - BANNER INSTITUCIONAL)
# ═══════════════════════════════════════════════════════════════════
s2 = prs.slides.add_slide(blank_layout)
agregar_fondo(s2, es_oscuro=False)

# Header banner institucional
if os.path.exists(BANNER_INST):
    s2.shapes.add_picture(BANNER_INST, Inches(8.5), Inches(0.6), width=Inches(4.0))

tbox2 = s2.shapes.add_textbox(Inches(0.8), Inches(0.6), Inches(7.5), Inches(1.3))
tf2 = tbox2.text_frame
p2_1 = tf2.paragraphs[0]
p2_1.text = "ARQUITECTURA DEL SISTEMA"
p2_1.font.size = Pt(11)
p2_1.font.bold = True
p2_1.font.color.rgb = RED_ACCENT
p2_1.font.name = "Segoe UI"

p2_2 = tf2.add_paragraph()
p2_2.text = "Las 4 Columnas Maestras de VPRO"
p2_2.font.size = Pt(26)
p2_2.font.bold = True
p2_2.font.color.rgb = TEXT_BLACK
p2_2.font.name = "Segoe UI"

# 4 Columnas / Tarjetas
cols = [
    ("💼 CRM", "Gestión Comercial", "• Catálogo de Clientes\n• Módulo de Cotizaciones\n• Historial de Coberturas\n• Conversión Directa a OP", RED_ACCENT),
    ("🏢 ERP", "Recursos & Viáticos", "• Control de Activos Broadcast\n• Comprobación de Viáticos\n• Flota Vehicular & Choferes\n• Equipos Dañados / Taller", CYAN_ACCENT),
    ("👥 HRMS", "Capital Humano", "• Kiosco Biométrico Digital\n• Control con Tolerancia 10m\n• Expedientes y Contratos\n• Gestión de Permisos (Horas/Días)", AMBER_ACCENT),
    ("🎬 BROADCAST", "Operaciones & Giras", "• OPs Multidía y Crews\n• Remoto 08:00 vs Estudio 16:00\n• Check-out / Check-in\n• Candados de Incidencias", GREEN_ACCENT),
]

card_w = 2.75
gap = 0.24
start_x = 0.8
for idx, (tit, sub, desc, color_acc) in enumerate(cols):
    x = start_x + idx * (card_w + gap)
    crear_tarjeta(s2, x, 2.0, card_w, 4.6, es_oscuro=False)
    
    tb = s2.shapes.add_textbox(Inches(x + 0.15), Inches(2.2), Inches(card_w - 0.3), Inches(4.2))
    tf = tb.text_frame
    tf.word_wrap = True
    
    pt = tf.paragraphs[0]
    pt.text = tit
    pt.font.size = Pt(17)
    pt.font.bold = True
    pt.font.color.rgb = color_acc
    pt.font.name = "Segoe UI"
    pt.space_after = Pt(4)
    
    ps = tf.add_paragraph()
    ps.text = sub
    ps.font.size = Pt(11)
    ps.font.bold = True
    ps.font.color.rgb = TEXT_MUTED_LIGHT
    ps.font.name = "Segoe UI"
    ps.space_after = Pt(14)
    
    pd = tf.add_paragraph()
    pd.text = desc
    pd.font.size = Pt(11.5)
    pd.font.color.rgb = TEXT_BLACK
    pd.font.name = "Segoe UI"
    pd.line_spacing = 1.3

agregar_footer(s2, es_oscuro=False, pagina=2)

# ═══════════════════════════════════════════════════════════════════
# SLIDE 3: CRM & COTIZACIONES (DARK THEME - BANNER 3 PANELES)
# ═══════════════════════════════════════════════════════════════════
s3 = prs.slides.add_slide(blank_layout)
agregar_fondo(s3, es_oscuro=True)

if os.path.exists(BANNER_3PANEL):
    s3.shapes.add_picture(BANNER_3PANEL, Inches(9.2), Inches(0.6), width=Inches(3.3))

tb3 = s3.shapes.add_textbox(Inches(0.8), Inches(0.6), Inches(8.0), Inches(1.2))
tf3 = tb3.text_frame
p = tf3.paragraphs[0]
p.text = "1. MÓDULO CRM & PROSPECCIÓN"
p.font.size = Pt(11)
p.font.bold = True
p.font.color.rgb = CYAN_ACCENT
p.font.name = "Segoe UI"

p = tf3.add_paragraph()
p.text = "Relación con Clientes y Cotizaciones de Eventos"
p.font.size = Pt(26)
p.font.bold = True
p.font.color.rgb = TEXT_WHITE
p.font.name = "Segoe UI"

# 2 Tarjetas Horizontales Grandes
c1 = crear_tarjeta(s3, 0.8, 2.0, 5.7, 4.6, es_oscuro=True)
tb_c1 = s3.shapes.add_textbox(Inches(1.0), Inches(2.2), Inches(5.3), Inches(4.2))
tf_c1 = tb_c1.text_frame
tf_c1.word_wrap = True

p = tf_c1.paragraphs[0]
p.text = "🎯 Catálogo Institucional de Clientes"
p.font.size = Pt(17)
p.font.bold = True
p.font.color.rgb = CYAN_ACCENT
p.space_after = Pt(12)

bullets_c1 = [
    ("Directorio Corporativo:", "Registro de marcas, ligas deportivas, dependencias gubernamentales y clientes particulares."),
    ("Contactos Clave:", "Directorio de productores, enlaces técnicos y coordinadores externos asociados a cada cuenta."),
    ("Trazabilidad Histórica:", "Histórico de todas las coberturas y eventos realizados para cada cliente.")
]
for b_tit, b_desc in bullets_c1:
    p = tf_c1.add_paragraph()
    p.text = f"• {b_tit} {b_desc}"
    p.font.size = Pt(12)
    p.font.color.rgb = TEXT_MUTED_DARK
    p.font.name = "Segoe UI"
    p.space_after = Pt(8)

c2 = crear_tarjeta(s3, 6.8, 2.0, 5.7, 4.6, es_oscuro=True)
tb_c2 = s3.shapes.add_textbox(Inches(7.0), Inches(2.2), Inches(5.3), Inches(4.2))
tf_c2 = tb_c2.text_frame
tf_c2.word_wrap = True

p = tf_c2.paragraphs[0]
p.text = "📑 Generador de Cotizaciones VPRO"
p.font.size = Pt(17)
p.font.bold = True
p.font.color.rgb = AMBER_ACCENT
p.space_after = Pt(12)

bullets_c2 = [
    ("Desglose Paramétrico:", "Presupuestos formales según cámaras (vMix, ópticas, cableados, microfonía, enlaces y dron)."),
    ("Exportación Ejecutiva:", "Generación de cotización lista para presentación al cliente con identidad corporativa."),
    ("Ecosistema Puente:", "Una cotización aprobada se convierte en la base operativa para generar su Orden de Producción (OP).")
]
for b_tit, b_desc in bullets_c2:
    p = tf_c2.add_paragraph()
    p.text = f"• {b_tit} {b_desc}"
    p.font.size = Pt(12)
    p.font.color.rgb = TEXT_MUTED_DARK
    p.font.name = "Segoe UI"
    p.space_after = Pt(8)

agregar_footer(s3, es_oscuro=True, pagina=3)

# ═══════════════════════════════════════════════════════════════════
# SLIDE 4: ERP - FINANZAS, VIÁTICOS Y FLOTA (LIGHT THEME - BANNER INST)
# ═══════════════════════════════════════════════════════════════════
s4 = prs.slides.add_slide(blank_layout)
agregar_fondo(s4, es_oscuro=False)

if os.path.exists(BANNER_INST):
    s4.shapes.add_picture(BANNER_INST, Inches(9.2), Inches(0.6), width=Inches(3.3))

tb4 = s4.shapes.add_textbox(Inches(0.8), Inches(0.6), Inches(8.0), Inches(1.2))
tf4 = tb4.text_frame
p = tf4.paragraphs[0]
p.text = "2. MÓDULO ERP FINANCIERO & LOGÍSTICA"
p.font.size = Pt(11)
p.font.bold = True
p.font.color.rgb = RED_ACCENT
p.font.name = "Segoe UI"

p = tf4.add_paragraph()
p.text = "Control Presupuestal, Viáticos de Gira y Flota"
p.font.size = Pt(26)
p.font.bold = True
p.font.color.rgb = TEXT_BLACK
p.font.name = "Segoe UI"

# 3 Tarjetas Verticales
erp_fin = [
    ("💳 Presupuesto y Viáticos", "Control Riguroso de Gastos", [
        "Estimado de gasto asignado por OP.",
        "Comprobación en tiempo real: Gasolina, Casetas, Alimentos, Hospedaje y Extras.",
        "Subida de comprobantes y tickets digitales.",
        "Balance automático entre presupuesto vs. gasto real comprobado."
    ], RED_ACCENT),
    ("🚗 Flota & Choferes Asignados", "Seguridad en Carretera", [
        "Parque vehicular: Sprinter, Hilux, Tiida, Ford.",
        "Asignación de conductor oficial por vehículo.",
        "Candado estricto: En eventos foráneos, el chofer se restringe exclusivamente al personal que viaja.",
        "Bitácora de traslado y resguardo de unidades."
    ], CYAN_ACCENT),
    ("🔒 Candado de Cierre", "Cero Pérdidas Operativas", [
        "El productor NO puede presentar reporte de gastos si algún técnico tiene pendientes.",
        "Auditoría cruzada: Asistencia + Check-out de equipo + Incidencias capturadas.",
        "Dictamen contable limpio y transparente."
    ], GREEN_ACCENT)
]

w4 = 3.7
gap4 = 0.31
for idx, (t, s, items, col) in enumerate(erp_fin):
    x = 0.8 + idx * (w4 + gap4)
    crear_tarjeta(s4, x, 2.0, w4, 4.6, es_oscuro=False)
    
    tb = s4.shapes.add_textbox(Inches(x + 0.18), Inches(2.2), Inches(w4 - 0.36), Inches(4.2))
    tf = tb.text_frame
    tf.word_wrap = True
    
    pt = tf.paragraphs[0]
    pt.text = t
    pt.font.size = Pt(16)
    pt.font.bold = True
    pt.font.color.rgb = col
    pt.space_after = Pt(4)
    
    ps = tf.add_paragraph()
    ps.text = s
    ps.font.size = Pt(11)
    ps.font.bold = True
    ps.font.color.rgb = TEXT_MUTED_LIGHT
    ps.space_after = Pt(14)
    
    for it in items:
        pi = tf.add_paragraph()
        pi.text = f"• {it}"
        pi.font.size = Pt(11)
        pi.font.color.rgb = TEXT_BLACK
        pi.space_after = Pt(6)

agregar_footer(s4, es_oscuro=False, pagina=4)

# ═══════════════════════════════════════════════════════════════════
# SLIDE 5: ERP - ACTIVOS, INVENTARIO Y DAÑADOS (DARK THEME - BANNER 3)
# ═══════════════════════════════════════════════════════════════════
s5 = prs.slides.add_slide(blank_layout)
agregar_fondo(s5, es_oscuro=True)

if os.path.exists(BANNER_3PANEL):
    s5.shapes.add_picture(BANNER_3PANEL, Inches(9.2), Inches(0.6), width=Inches(3.3))

tb5 = s5.shapes.add_textbox(Inches(0.8), Inches(0.6), Inches(8.0), Inches(1.2))
tf5 = tb5.text_frame
p = tf5.paragraphs[0]
p.text = "3. MÓDULO ERP ACTIVOS & INVENTARIO"
p.font.size = Pt(11)
p.font.bold = True
p.font.color.rgb = CYAN_ACCENT

p = tf5.add_paragraph()
p.text = "Custodia de Equipos Broadcast y Mantenimiento Técnico"
p.font.size = Pt(26)
p.font.bold = True
p.font.color.rgb = TEXT_WHITE

c1 = crear_tarjeta(s5, 0.8, 2.0, 5.7, 4.6, es_oscuro=True)
tb_c1 = s5.shapes.add_textbox(Inches(1.0), Inches(2.2), Inches(5.3), Inches(4.2))
tf_c1 = tb_c1.text_frame
tf_c1.word_wrap = True

p = tf_c1.paragraphs[0]
p.text = "📦 Control de Inventario & Kits Estándar"
p.font.size = Pt(17)
p.font.bold = True
p.font.color.rgb = CYAN_ACCENT
p.space_after = Pt(12)

inv_items = [
    ("Equipos de Alta Gama:", "Cámaras broadcast, switchers vMix, ópticas cinema, microfonía inalámbrica, tripies y cablería."),
    ("Kits Preconfigurados:", "Kit Estándar Fuera de Oficina, Kits de Transmisión Remota y Kits de Iluminación."),
    ("Filtros por Estado:", "Disponibilidad en almacén, equipos en gira/locación y unidades en reserva."),
    ("Códigos de Identificación:", "Claves únicas y seriales para cada pieza de producción.")
]
for t, d in inv_items:
    p = tf_c1.add_paragraph()
    p.text = f"• {t} {d}"
    p.font.size = Pt(12)
    p.font.color.rgb = TEXT_MUTED_DARK
    p.space_after = Pt(8)

c2 = crear_tarjeta(s5, 6.8, 2.0, 5.7, 4.6, es_oscuro=True)
tb_c2 = s5.shapes.add_textbox(Inches(7.0), Inches(2.2), Inches(5.3), Inches(4.2))
tf_c2 = tb_c2.text_frame
tf_c2.word_wrap = True

p = tf_c2.paragraphs[0]
p.text = "🛠️ Módulo de Equipos Dañados & Taller"
p.font.size = Pt(17)
p.font.bold = True
p.font.color.rgb = RED_ACCENT
p.space_after = Pt(12)

dan_items = [
    ("Reporte Inmediato de Avería:", "Se captura desde el Check-in al volver de evento con detalle fotográfico y descripción."),
    ("Diagnóstico Técnico:", "Bitácora interna de taller: falla reportada, tipo de reparación requerida y piezas a sustituir."),
    ("Presupuesto de Reparación:", "Estimado económico y proveedor o técnico asignado para la compostura."),
    ("Historial de Incidencias:", "Evita que equipos con fallas intermitentes salgan de nuevo a producción.")
]
for t, d in dan_items:
    p = tf_c2.add_paragraph()
    p.text = f"• {t} {d}"
    p.font.size = Pt(12)
    p.font.color.rgb = TEXT_MUTED_DARK
    p.space_after = Pt(8)

agregar_footer(s5, es_oscuro=True, pagina=5)

# ═══════════════════════════════════════════════════════════════════
# SLIDE 6: HRMS - CAPITAL HUMANO, KIOSCO & RH (LIGHT THEME - ISO 9001)
# ═══════════════════════════════════════════════════════════════════
s6 = prs.slides.add_slide(blank_layout)
agregar_fondo(s6, es_oscuro=False)

if os.path.exists(LOGO_ISO):
    s6.shapes.add_picture(LOGO_ISO, Inches(11.4), Inches(0.6), width=Inches(1.1), height=Inches(1.1))

tb6 = s6.shapes.add_textbox(Inches(0.8), Inches(0.6), Inches(10.0), Inches(1.2))
tf6 = tb6.text_frame
p = tf6.paragraphs[0]
p.text = "4. MÓDULO HRMS CAPITAL HUMANO & BIOMETRÍA"
p.font.size = Pt(11)
p.font.bold = True
p.font.color.rgb = AMBER_ACCENT

p = tf6.add_paragraph()
p.text = "Kiosco Asistencia, Tolerancias y Gestión de Expedientes"
p.font.size = Pt(26)
p.font.bold = True
p.font.color.rgb = TEXT_BLACK

hrms_cards = [
    ("🕒 Kiosco Biométrico Inteligente", "Control de Asistencia con Tolerancias", [
        "Horario Normal de Oficina: 09:00 a. m. con 10 minutos de tolerancia (hasta 09:10:00).",
        "Llamados Especiales de OP: Evalúa contra el llamado exacto (Remoto 08:00, Estudio 16:00).",
        "Detección de Omisión de Comida: Alerta automática si se omite registro entre 09:00 y 19:00.",
        "Registro de Madrugadas: Soporte de coberturas nocturnas que concluyen al día siguiente."
    ], CYAN_ACCENT),
    ("📁 Expedientes Digitales RH", "Contratos y Perfiles de Colaborador", [
        "Ficha completa de personal VPRO, nómina y puesto.",
        "Contratos laborales registrados (L-V 09:00 a 18:00, etc.).",
        "Historial consolidado de retardos, asistencias y justificaciones.",
        "Auditoría gerencial en tiempo real con exportación de reportes."
    ], RED_ACCENT),
    ("⏱️ Permisos por Horas y Días", "Dictámenes Automatizados", [
        "Solicitud digital de permisos (médicos, personales, oficiales).",
        "Modalidades: Permiso por Horas o Días completos (Con/Sin goce).",
        "Ajuste automático en Checador: Si el empleado tiene permiso autorizado, el checador no marca retardo.",
        "Trazabilidad y aprobación con firma digital."
    ], GREEN_ACCENT)
]

w6 = 3.7
gap6 = 0.31
for idx, (t, s, items, col) in enumerate(hrms_cards):
    x = 0.8 + idx * (w6 + gap6)
    crear_tarjeta(s6, x, 2.0, w6, 4.6, es_oscuro=False)
    
    tb = s6.shapes.add_textbox(Inches(x + 0.18), Inches(2.2), Inches(w6 - 0.36), Inches(4.2))
    tf = tb.text_frame
    tf.word_wrap = True
    
    pt = tf.paragraphs[0]
    pt.text = t
    pt.font.size = Pt(16)
    pt.font.bold = True
    pt.font.color.rgb = col
    pt.space_after = Pt(4)
    
    ps = tf.add_paragraph()
    ps.text = s
    ps.font.size = Pt(11)
    ps.font.bold = True
    ps.font.color.rgb = TEXT_MUTED_LIGHT
    ps.space_after = Pt(14)
    
    for it in items:
        pi = tf.add_paragraph()
        pi.text = f"• {it}"
        pi.font.size = Pt(11)
        pi.font.color.rgb = TEXT_BLACK
        pi.space_after = Pt(6)

agregar_footer(s6, es_oscuro=False, pagina=6)

# ═══════════════════════════════════════════════════════════════════
# SLIDE 7: BROADCAST OPS - OPs MULTIDÍA (DARK THEME - BANNER 3)
# ═══════════════════════════════════════════════════════════════════
s7 = prs.slides.add_slide(blank_layout)
agregar_fondo(s7, es_oscuro=True)

if os.path.exists(BANNER_3PANEL):
    s7.shapes.add_picture(BANNER_3PANEL, Inches(9.2), Inches(0.6), width=Inches(3.3))

tb7 = s7.shapes.add_textbox(Inches(0.8), Inches(0.6), Inches(8.0), Inches(1.2))
tf7 = tb7.text_frame
p = tf7.paragraphs[0]
p.text = "5. BROADCAST OPERATIONS HUB"
p.font.size = Pt(11)
p.font.bold = True
p.font.color.rgb = GREEN_ACCENT

p = tf7.add_paragraph()
p.text = "Órdenes de Producción (OPs) Multijornada"
p.font.size = Pt(26)
p.font.bold = True
p.font.color.rgb = TEXT_WHITE

c1 = crear_tarjeta(s7, 0.8, 2.0, 5.7, 4.6, es_oscuro=True)
tb_c1 = s7.shapes.add_textbox(Inches(1.0), Inches(2.2), Inches(5.3), Inches(4.2))
tf_c1 = tb_c1.text_frame
tf_c1.word_wrap = True

p = tf_c1.paragraphs[0]
p.text = "📡 División Estratégica de Cuadrillas"
p.font.size = Pt(17)
p.font.bold = True
p.font.color.rgb = CYAN_ACCENT
p.space_after = Pt(12)

b_ops1 = [
    ("Personal en Locación Remota (Gira):", "Equipo que viaja fuera de la ciudad. Exento del checador de oficina local mientras se encuentra en cobertura foránea."),
    ("Personal en Estudio / Cabina Local:", "Operadores de switcher, audio y graficación que operan desde las instalaciones fijas de VPRO."),
    ("Personal Externo / Freelance:", "Integración de especialistas convocados por evento sin alterar la nómina interna."),
    ("Asignación de Roles Precisos:", "Cámaras, Switcher vMix, Repetición, Audio, Producción y Chofer.")
]
for t, d in b_ops1:
    p = tf_c1.add_paragraph()
    p.text = f"• {t} {d}"
    p.font.size = Pt(12)
    p.font.color.rgb = TEXT_MUTED_DARK
    p.space_after = Pt(8)

c2 = crear_tarjeta(s7, 6.8, 2.0, 5.7, 4.6, es_oscuro=True)
tb_c2 = s7.shapes.add_textbox(Inches(7.0), Inches(2.2), Inches(5.3), Inches(4.2))
tf_c2 = tb_c2.text_frame
tf_c2.word_wrap = True

p = tf_c2.paragraphs[0]
p.text = "🗓️ Bitácora Multidía con Llamados Día a Día"
p.font.size = Pt(17)
p.font.bold = True
p.font.color.rgb = AMBER_ACCENT
p.space_after = Pt(12)

b_ops2 = [
    ("Fechas Dinámicas Vinculadas:", "La bitácora sincroniza desde la Fecha de Instalación hasta la Fecha de Fin del evento con sugerencias en un clic."),
    ("Llamados Independientes:", "Viernes Remoto entra a las 08:00 a. m. y Estudio entra a las 16:00 hrs; el sábado los horarios cambian según la pauta."),
    ("Botones de Aplicación Rápida:", "Permite aplicar el horario al grupo Remoto o Estudio con un solo clic, o personalizar técnico por técnico."),
    ("Gestión y Eliminación Limpia:", "El coordinador puede agregar, sincronizar personal o eliminar jornadas con trazabilidad íntegra.")
]
for t, d in b_ops2:
    p = tf_c2.add_paragraph()
    p.text = f"• {t} {d}"
    p.font.size = Pt(12)
    p.font.color.rgb = TEXT_MUTED_DARK
    p.space_after = Pt(8)

agregar_footer(s7, es_oscuro=True, pagina=7)

# ═══════════════════════════════════════════════════════════════════
# SLIDE 8: CHECK-OUT, CHECK-IN & CANDADOS DE INCIDENCIAS (LIGHT THEME)
# ═══════════════════════════════════════════════════════════════════
s8 = prs.slides.add_slide(blank_layout)
agregar_fondo(s8, es_oscuro=False)

if os.path.exists(BANNER_INST):
    s8.shapes.add_picture(BANNER_INST, Inches(9.2), Inches(0.6), width=Inches(3.3))

tb8 = s8.shapes.add_textbox(Inches(0.8), Inches(0.6), Inches(8.0), Inches(1.2))
tf8 = tb8.text_frame
p = tf8.paragraphs[0]
p.text = "6. CADENA DE CUSTODIA & CALIDAD OPERATIVA"
p.font.size = Pt(11)
p.font.bold = True
p.font.color.rgb = RED_ACCENT

p = tf8.add_paragraph()
p.text = "Check-out, Check-in y Candados de Incidencias"
p.font.size = Pt(26)
p.font.bold = True
p.font.color.rgb = TEXT_BLACK

cad_cards = [
    ("📤 Check-out de Equipo", "Salida con Responsiva", [
        "Asignación de kit técnico por colaborador requerido.",
        "Pase de lista físico antes de subir a unidad.",
        "Firma digital y responsiva de custodia del operador.",
        "Candado de salida: No se despacha equipo sin check-out formal."
    ], CYAN_ACCENT),
    ("📥 Check-in al Retorno", "Inspección de Entrega", [
        "Recepción pieza por pieza al concluir la cobertura.",
        "Verificación de cables, cargadores, tarjetas y periféricos.",
        "Detección inmediata de faltantes o averías.",
        "Reingreso automático al almacén digital de VPRO."
    ], AMBER_ACCENT),
    ("⚠️ Candado de Incidencias", "Obligatoriedad Estricta", [
        "El técnico debe capturar las incidencias de cada jornada o marcar 'Concluido Sin Incidencias'.",
        "Sin reporte de incidencias, el sistema bloquea el cierre.",
        "Alerta al Productor: Muestra los nombres de los pendientes y bloquea la comprobación de gastos.",
        "Garantiza el cumplimiento de la norma ISO 9001:2015."
    ], RED_ACCENT)
]

w8 = 3.7
gap8 = 0.31
for idx, (t, s, items, col) in enumerate(cad_cards):
    x = 0.8 + idx * (w8 + gap8)
    crear_tarjeta(s8, x, 2.0, w8, 4.6, es_oscuro=False)
    
    tb = s8.shapes.add_textbox(Inches(x + 0.18), Inches(2.2), Inches(w8 - 0.36), Inches(4.2))
    tf = tb.text_frame
    tf.word_wrap = True
    
    pt = tf.paragraphs[0]
    pt.text = t
    pt.font.size = Pt(16)
    pt.font.bold = True
    pt.font.color.rgb = col
    pt.space_after = Pt(4)
    
    ps = tf.add_paragraph()
    ps.text = s
    ps.font.size = Pt(11)
    ps.font.bold = True
    ps.font.color.rgb = TEXT_MUTED_LIGHT
    ps.space_after = Pt(14)
    
    for it in items:
        pi = tf.add_paragraph()
        pi.text = f"• {it}"
        pi.font.size = Pt(11)
        pi.font.color.rgb = TEXT_BLACK
        pi.space_after = Pt(6)

agregar_footer(s8, es_oscuro=False, pagina=8)

# ═══════════════════════════════════════════════════════════════════
# SLIDE 9: VPRO TRANSFER & CLOUD INFRASTRUCTURE (DARK THEME - BANNER 3)
# ═══════════════════════════════════════════════════════════════════
s9 = prs.slides.add_slide(blank_layout)
agregar_fondo(s9, es_oscuro=True)

if os.path.exists(BANNER_3PANEL):
    s9.shapes.add_picture(BANNER_3PANEL, Inches(9.2), Inches(0.6), width=Inches(3.3))

tb9 = s9.shapes.add_textbox(Inches(0.8), Inches(0.6), Inches(8.0), Inches(1.2))
tf9 = tb9.text_frame
p = tf9.paragraphs[0]
p.text = "7. INFRAESTRUCTURA & HERRAMIENTAS PROPIETARIAS"
p.font.size = Pt(11)
p.font.bold = True
p.font.color.rgb = CYAN_ACCENT

p = tf9.add_paragraph()
p.text = "VPRO Transfer y Arquitectura Tecnológica Cloud"
p.font.size = Pt(26)
p.font.bold = True
p.font.color.rgb = TEXT_WHITE

c1 = crear_tarjeta(s9, 0.8, 2.0, 5.7, 4.6, es_oscuro=True)
tb_c1 = s9.shapes.add_textbox(Inches(1.0), Inches(2.2), Inches(5.3), Inches(4.2))
tf_c1 = tb_c1.text_frame
tf_c1.word_wrap = True

p = tf_c1.paragraphs[0]
p.text = "🚀 VPRO Transfer (Buzón Interno de Archivos)"
p.font.size = Pt(17)
p.font.bold = True
p.font.color.rgb = CYAN_ACCENT
p.space_after = Pt(12)

tr_items = [
    ("Transferencia Peer-to-Peer Empresarial:", "Envío directo de videos, audios, fotos y documentos entre colaboradores sin salir del sistema."),
    ("Cero Dependencia de Terceros:", "Evita límites de WeTransfer, enlaces caídos de Google Drive o saturación de correos electrónicos."),
    ("Buzón de Recibidos y Enviados:", "Historial completo, estado de descarga, visor multimedia integrado y opción de descarte."),
    ("Seguridad y Confidencialidad:", "Toda la información se aloja en los servidores dedicados de VPRO.")
]
for t, d in tr_items:
    p = tf_c1.add_paragraph()
    p.text = f"• {t} {d}"
    p.font.size = Pt(12)
    p.font.color.rgb = TEXT_MUTED_DARK
    p.space_after = Pt(8)

c2 = crear_tarjeta(s9, 6.8, 2.0, 5.7, 4.6, es_oscuro=True)
tb_c2 = s9.shapes.add_textbox(Inches(7.0), Inches(2.2), Inches(5.3), Inches(4.2))
tf_c2 = tb_c2.text_frame
tf_c2.word_wrap = True

p = tf_c2.paragraphs[0]
p.text = "☁️ Stack Tecnológico & Calidad Certificada"
p.font.size = Pt(17)
p.font.bold = True
p.font.color.rgb = GREEN_ACCENT
p.space_after = Pt(12)

stack_items = [
    ("Backend de Alto Desempeño:", "Desarrollado en Python con FastAPI, asíncrono, ultraligero y con validación estricta de datos."),
    ("Base de Datos Cloud PostgreSQL:", "Estructura relacional con esquemas independientes (eventos, personal, inventario, asistencia)."),
    ("Frontend Web Modular:", "HTML5, CSS3 y JavaScript moderno con arquitectura por módulos y soporte offline/cache."),
    ("Norma de Calidad ISO 9001:2015:", "Diseñado para cumplir y superar los estándares de auditoría internacional en procesos de transmisión.")
]
for t, d in stack_items:
    p = tf_c2.add_paragraph()
    p.text = f"• {t} {d}"
    p.font.size = Pt(12)
    p.font.color.rgb = TEXT_MUTED_DARK
    p.space_after = Pt(8)

agregar_footer(s9, es_oscuro=True, pagina=9)

# ═══════════════════════════════════════════════════════════════════
# SLIDE 10: CONCLUSIÓN & CRÉDITOS OFICIALES (DARK KEYNOTE CLOSING)
# ═══════════════════════════════════════════════════════════════════
s10 = prs.slides.add_slide(blank_layout)
agregar_fondo(s10, es_oscuro=True)

# Logos superiores
if os.path.exists(BANNER_3PANEL):
    s10.shapes.add_picture(BANNER_3PANEL, Inches(8.5), Inches(0.8), width=Inches(4.0))

if os.path.exists(LOGO_ISO):
    s10.shapes.add_picture(LOGO_ISO, Inches(0.8), Inches(0.8), width=Inches(1.2), height=Inches(1.2))

# Tarjeta Central Principal
c10 = crear_tarjeta(s10, 0.8, 2.3, 11.733, 4.3, es_oscuro=True)
tb10 = s10.shapes.add_textbox(Inches(1.2), Inches(2.55), Inches(10.9), Inches(3.8))
tf10 = tb10.text_frame
tf10.word_wrap = True

p = tf10.paragraphs[0]
p.text = "CONCLUSIÓN DEL SISTEMA VPRO DASHBOARD"
p.font.size = Pt(11)
p.font.bold = True
p.font.color.rgb = CYAN_ACCENT
p.space_after = Pt(6)

p = tf10.add_paragraph()
p.text = "Un Ecosistema Empresarial de Clase Mundial Hecho a la Medida"
p.font.size = Pt(25)
p.font.bold = True
p.font.color.rgb = TEXT_WHITE
p.space_after = Pt(16)

p = tf10.add_paragraph()
p.text = (
    "El Dashboard de VPRO Streaming Services no es un software empaquetado genérico; es una suite integral "
    "creada específicamente para resolver las exigencias más críticas de la industria audiovisual: "
    "cero fugas de inventario con cadena de custodia estricta, puntualidad auditada mediante biometría y tolerancias, "
    "control riguroso de viáticos en ruta, y trazabilidad total de incidencias operativas bajo la norma ISO 9001:2015."
)
p.font.size = Pt(13)
p.font.color.rgb = TEXT_MUTED_DARK
p.line_spacing = 1.35
p.space_after = Pt(24)

# Bloque de créditos
p_line = tf10.add_paragraph()
p_line.text = "─────────────────────────────────────────────────────────────────────────────"
p_line.font.size = Pt(9)
p_line.font.color.rgb = DARK_BORDER
p_line.space_after = Pt(10)

p_cr1 = tf10.add_paragraph()
p_cr1.text = "DIRECCIÓN DE PROYECTO & ARQUITECTURA TECNOLÓGICA"
p_cr1.font.size = Pt(10.5)
p_cr1.font.bold = True
p_cr1.font.color.rgb = AMBER_ACCENT
p_cr1.space_after = Pt(4)

p_cr2 = tf10.add_paragraph()
p_cr2.text = FOOTER_SIGNATURE
p_cr2.font.size = Pt(18)
p_cr2.font.bold = True
p_cr2.font.color.rgb = TEXT_WHITE

agregar_footer(s10, es_oscuro=True, pagina=10)

# Guardar Presentación
output_path = r"VPRO_Dashboard_Presentacion_Ejecutiva.pptx"
prs.save(output_path)
print(f"✅ ¡Presentación generada exitosamente en: {os.path.abspath(output_path)}!")
