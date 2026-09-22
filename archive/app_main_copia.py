# 🖥️ VPRO SYSTEM - FRONTEND SHELL (STREAMLIT MASTER DASHBOARD V7.9.4)
import streamlit as st
import requests
import datetime
import pandas as pd
import plotly.express as px
import unicodedata
import time
import os
import numpy as np
import base64

# 🎛️ CONFIGURACIÓN DE LIENZO MAESTRO
st.set_page_config(
    page_title="VPRO Dashboard", 
    layout="wide", 
    initial_sidebar_state="expanded"
)

API_URL = "https://172.16.0.20:8000"
requests.packages.urllib3.disable_warnings()
FOTOS_EQUIPOS_DIR = "Fotos_de_equipos"
FOTOS_PERSONAL_DIR = "Fotos_de_personal"

def transformar_imagen_a_web(ruta_archivo):
    """Convierte una imagen local a formato Base64 para que el HTML de Streamlit la renderice en cualquier red"""
    if os.path.exists(ruta_archivo):
        with open(ruta_archivo, "rb") as f:
            datos_binarios = f.read()
        codificado = base64.b64encode(datos_binarios).decode("utf-8")
        extension = "png" if ruta_archivo.lower().endswith(".png") else "jpeg"
        return f"data:image/{extension};base64,{codificado}"
    return ""

def generar_pdf_gastos(r_temp, df_detalles):        # 📄 MOTOR GENERADOR DE COMPROBANTES DE GASTOS EN FORMATO PDF
    from io import BytesIO
    from reportlab.lib.pagesizes import letter
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib import colors
    
    buffer = BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=letter, rightMargin=36, leftMargin=36, topMargin=36, bottomMargin=36)
    story = []
    
    styles = getSampleStyleSheet()
    normal_style     = ParagraphStyle('NormalStyle', parent=styles['Normal'], fontSize=9, leading=12)
    sig_style        = ParagraphStyle('SigStyle', parent=styles['Normal'], fontSize=9, leading=14, alignment=1)
    tbl_cell_style   = ParagraphStyle('TblCell', parent=styles['Normal'], fontSize=8, leading=10, alignment=1)
    title_style      = ParagraphStyle('TitleStyle', parent=styles['Heading1'], fontSize=16, leading=20, textColor=colors.HexColor('#0f172a'), alignment=1)
    header_style     = ParagraphStyle('HeaderStyle', parent=styles['Heading3'], fontSize=11, leading=14, textColor=colors.HexColor('#1e293b'), spaceBefore=10)
    tbl_header_style = ParagraphStyle('TblHeader', parent=styles['Normal'], fontSize=8, leading=10, textColor=colors.white, fontName='Helvetica-Bold', alignment=1)
    
    story.append(Paragraph("<b>REPORTE DE GASTOS POR COMPROBAR</b>", title_style))
    story.append(Spacer(1, 12))
    
    try:    # 1️⃣ Calculamos los kilómetros recorridos (usamos un try/except por si el campo viene vacío)
        kms_recorridos = int(r_temp['km_f']) - int(r_temp['km_i'])
    except:
        kms_recorridos = 0

    # 2️⃣ Armamos la tabla de ReportLab con la nueva etiqueta de fuente (<font>)
    meta_data = [
        [Paragraph(f"<b>Folio Evento OP:</b> {r_temp['folio']}", normal_style), Paragraph(f"<b>Fecha de Emisión:</b> {datetime.date.today().strftime('%d/%m/%Y')}", normal_style)],
        [Paragraph(f"<b>Responsable:</b> {r_temp['nombre']}", normal_style), Paragraph(f"<b>Departamento Origen:</b> {r_temp['depto']}", normal_style)],
        [Paragraph(f"<b>Vehículo(s) Asignado(s):</b> {r_temp['vehiculo']}", normal_style), Paragraph(f"<b>Odómetro Inicial/Final:</b> {r_temp['km_i']} - {r_temp['km_f']} KM <font color='#2563eb'><b>(Recorridos: {kms_recorridos} KM)</b></font>", normal_style)],
        [Paragraph(f"<b>Num. de personas Convocadas:</b> {r_temp.get('num_personas', 0)} personas", normal_style), Paragraph("", normal_style)]
    ]
    
    t_meta = Table(meta_data, colWidths=[270, 270])
    t_meta.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#f8fafc')),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor('#e2e8f0')),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor('#f1f5f9')),
        ('PADDING', (0,0), (-1,-1), 5),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    
    story.append(t_meta)
    story.append(Spacer(1, 12))
    
    fin_headers = [Paragraph("<b>💰 IMPORTE ENTREGADO</b>", tbl_header_style), Paragraph("<b>💳 TOTAL COSTO DE PRODUCC</b>", tbl_header_style), Paragraph("<b>⚖️ DIFERENCIA</b>", tbl_header_style)]
    fin_values = [Paragraph(f"<b>$ {r_temp['entregado']:,.2f}</b>", title_style), Paragraph(f"<b>$ {r_temp['subtotal']:,.2f}</b>", title_style), Paragraph(f"<b>$ {r_temp['restante']:,.2f}</b>", title_style)]
    t_fin = Table([fin_headers, fin_values], colWidths=[180, 180, 180])
    t_fin.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#1e293b')),
        ('BACKGROUND', (0,1), (-1,1), colors.HexColor('#f1f5f9')),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor('#cbd5e1')),
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('PADDING', (0,0), (-1,-1), 6),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(t_fin)
    story.append(Spacer(1, 15))
    
    story.append(Paragraph("<b>📊 Desglose Diario por Concepto de GASTOS POR COMPROBAR</b>", header_style))
    story.append(Spacer(1, 4))
    
    columnas_df = ["Fecha", "Hotel", "Transp", "Combust", "Casetas", "Desay", "Comida", "Cenas", "Varios"]
    grid_headers = [Paragraph(f"<b>{c}</b>", tbl_header_style) for c in columnas_df] + [Paragraph("<b>Total Día</b>", tbl_header_style)]
    grid_rows = [grid_headers]
    
    cats = ["Hotel", "Transp", "Combust", "Casetas", "Desay", "Comida", "Cenas", "Varios"]
    for _, row in df_detalles.iterrows():
        row_cells = [Paragraph(str(row["Fecha"]), tbl_cell_style)]
        for c in cats:
            row_cells.append(Paragraph(f"${float(row[c]):,.2f}", tbl_cell_style))
        row_cells.append(Paragraph(f"<b>${float(row['Total']):,.2f}</b>", tbl_cell_style))
        grid_rows.append(row_cells)
        
    t_grid = Table(grid_rows, colWidths=[75] + [51]*8 + [56])
    t_grid.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#0f172a')),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor('#94a3b8')),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor('#e2e8f0')),
        ('PADDING', (0,0), (-1,-1), 4),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(t_grid)
    
    story.append(Spacer(1, 45))
    sig_data = [
        [
            Paragraph(f"_____________________________________<br/><b>{r_temp['nombre']}</b><br/>Productor Responsable", sig_style),
            Paragraph("_____________________________________<br/><b>ANA LILIA VILLARREAL URIBE</b><br/>Auditoría Administration", sig_style)
        ]
    ]
    t_sig = Table(sig_data, colWidths=[270, 270])
    t_sig.setStyle(TableStyle([
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('BOTTOMPADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(t_sig)
    
    doc.build(story)
    buffer.seek(0)
    return buffer.getvalue()

def parsed_array(val):      # 🌟 AUXILIARES GLOBALES
    if isinstance(val, list): return val
    if not val: return []
    return [x.strip().strip('"').strip("'") for x in val.replace("{","").replace("}","").split(",") if x]

def contar_gastos_pendientes():
    try:
        res = requests.get(f"{API_URL}/api/gastos/pendientes/conteo", verify=False)
        return res.json() if res.status_code == 200 else 0
    except: return 0

# 📦 CONTROL DE SESIÓN GENERAL
if "autenticado" not in st.session_state: st.session_state.autenticado = False
if "confirmacion_baja_pendiente" not in st.session_state: st.session_state.confirmacion_baja_pendiente = False
if "payload_temporal" not in st.session_state: st.session_state.payload_temporal = None
if "nombres_bajas_temporales" not in st.session_state: st.session_state.nombres_bajas_temporales = []
if "menu_principal_radio" not in st.session_state: st.session_state.menu_principal_radio = "🏠 Inicio"
if "op_activa_checkout" not in st.session_state: st.session_state.op_activa_checkout = "---"

def get_base64_of_bin_file(bin_file):
    if os.path.exists(bin_file):
        with open(bin_file, 'rb') as f:
            return base64.b64encode(f.read()).decode()
    return ""

if not st.session_state.autenticado:    # DESIGN: NETFLIX EXECUTIVE - GRID COMPLETO
    try:
        logo_login_base64 = get_base64_of_bin_file("vpro_menu.jpg")
        if logo_login_base64:
            st.markdown(f"""
            <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; margin-bottom: 30px; margin-top: 10px; gap: 12px;">
                <img src="data:image/jpeg;base64,{logo_login_base64}" 
                     style="height: 85px; width: auto; border-radius: 8px; box-shadow: 0 6px 12px rgba(0,0,0,0.18);">
                <h2 style="margin: 0; padding: 0; font-family: sans-serif; font-size: 32px; color: #1e293b; font-weight: bold; border: none; line-height: 1.2; letter-spacing: -0.5px;">
                    SISTEMA INTEGRAL VPRO
                </h2>
            </div>
            """, unsafe_allow_html=True)
        else:
            st.markdown("<h2 style='text-align: center; color: #1e293b; font-family: sans-serif; font-weight: bold;'>🎬 SISTEMA INTEGRAL VPRO</h2>", unsafe_allow_html=True)
    except Exception:
        st.markdown("<h2 style='text-align: center; color: #1e293b; font-family: sans-serif; font-weight: bold;'>🎬 SISTEMA INTEGRAL VPRO</h2>", unsafe_allow_html=True)
        
    st.write("")

    if "empleado_seleccionado" not in st.session_state: 
        st.session_state.empleado_seleccionado = None

    lista_empleados = []    # 📡 CONEXIÓN MAESTRA CON LA BD: EXTRACCIÓN Y PURGA DE PERSONAL ACTIVO
    try:
        res_lista = requests.get(f"{API_URL}/api/empleados", verify=False)
        if res_lista.status_code == 200:
            df_emp_auth = pd.DataFrame(res_lista.json())
            if not df_emp_auth.empty:
                df_emp_auth['rol'] = df_emp_auth['rol'].fillna("").astype(str).str.upper().str.strip()
                
                if 'estado' in df_emp_auth.columns:
                    df_emp_auth = df_emp_auth[df_emp_auth['estado'].astype(str).str.upper() == 'ACTIVO']
                elif 'estatus' in df_emp_auth.columns:
                    df_emp_auth = df_emp_auth[df_emp_auth['estatus'].astype(str).str.upper() == 'ACTIVO']

                df_emp_auth = df_emp_auth[(df_emp_auth['rol'] != 'BAJA') & (df_emp_auth['rol'] != 'INACTIVO') & (df_emp_auth['rol'] != 'PROVEEDOR')]
                lista_empleados = df_emp_auth.to_dict(orient="records")
                
    except Exception as e:
        st.error(f"📡 Error de enlace con la API: {e}")
        st.stop()

    if st.session_state.empleado_seleccionado is None:          # --- ESCENARIO A: EL MURO DE TODOS LOS EMPLEADOS ---
        st.markdown("<p style='text-align: center; color: #475569; font-size: 16px; font-weight: 500;'>Abajo de tu fotografía hay un botón de ACCESO. Presiónalo para ingresar al Sistema...</p>", unsafe_allow_html=True)
        
        if not lista_empleados:
            st.info("💡 **Búnker listo:** Esperando sincronización de datos desde el pgAdmin local.")
            st.write("---")
            st.warning("⚠️ Acceso alterno temporal (Sin datos en BD):")
            user_test = st.text_input("Usuario Temporal de pruebas:")
            pass_test = st.text_input("Contraseña Temporal:", type="password")
            if st.button("Ingresar forzado (Desarrollo)"):
                st.session_state.update({"autenticado": True, "usuario_actual": user_test, "rol": "COORDINADOR", "depto": "SISTEMAS", "id_usuario": "999"})
                st.rerun()
        else:
            COLUMNAS_POR_FILA = 4
            
            for orden_fila in range(0, len(lista_empleados), COLUMNAS_POR_FILA):
                bloque_fila = lista_empleados[orden_fila : orden_fila + COLUMNAS_POR_FILA]
                columnas_render = st.columns(COLUMNAS_POR_FILA)
                
                for idx, emp in enumerate(bloque_fila):
                    with columnas_render[idx]:
                        with st.container(border=True):
                            exts = ['.png', '.jpg', '.jpeg', '.PNG', '.JPG', '.JPEG']
                            foto_render = "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"
                            
                            for ext in exts:
                                ruta_prueba = os.path.join(FOTOS_PERSONAL_DIR, f"{emp['id_empleado']}{ext}")
                                if os.path.exists(ruta_prueba):
                                    foto_render = ruta_prueba
                                    break

                            st.image(foto_render, width='stretch')
                            
                            id_emp_actual = str(emp['id_empleado']).strip()
                            primer_nombre = emp['nombre'].split()[0] if emp['nombre'].split() else ""
                            
                            if id_emp_actual == "104":
                                nombre_final_tarjeta = "JOSE FRANCISCO"
                                tamano_fuente = "16px"
                            elif id_emp_actual == "105":
                                nombre_final_tarjeta = "JOSE DANIEL"
                                tamano_fuente = "16px"
                            elif id_emp_actual == "119":
                                nombre_final_tarjeta = "MANUEL ANTONIO"
                                tamano_fuente = "16px"
                            elif id_emp_actual == "124":
                                nombre_final_tarjeta = "MANUEL EDUARDO"
                                tamano_fuente = "16px"
                            elif id_emp_actual == "529":
                                nombre_final_tarjeta = "CHECADOR (KIOSKO)"
                                tamano_fuente = "16px"
                            elif primer_nombre.upper() in ["ANA", "GERARDO", "PEDRO", "SOFIA", "ANDREA"]:
                                nombre_final_tarjeta = str(emp['nombre']).strip().upper()
                                tamano_fuente = "14px"
                            else:
                                nombre_final_tarjeta = primer_nombre.upper()
                                tamano_fuente = "16px"
                            
                            st.markdown(f"<p style='text-align:center; margin-bottom:12px; font-weight:bold; color:#0f172a; font-size:{tamano_fuente};'>{nombre_final_tarjeta}</p>", unsafe_allow_html=True)
                            
                            if st.button("👤 ACCESO", key=f"btn_muro_{emp['id_empleado']}", width='stretch', type="primary"):
                                st.session_state.empleado_seleccionado = emp
                                st.rerun()

    else:       # --- ESCENARIO B: PANTALLA DE CLAVE ESTILO MAC ---
        emp_activo = st.session_state.empleado_seleccionado
        
        exts = ['.png', '.jpg', '.jpeg', '.PNG', '.JPG', '.JPEG']
        foto_perfil = "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"
        for ext in exts:
            ruta_prueba = os.path.join(FOTOS_PERSONAL_DIR, f"{emp_activo['id_empleado']}{ext}")
            if os.path.exists(ruta_prueba):
                foto_perfil = ruta_prueba
                break

        c1, c2, c3 = st.columns([1.2, 1.5, 1.2])
        with c2:
            st.write("")
            with st.container(border=True):
                col_f1, col_f2, col_f3 = st.columns([1, 2, 1])
                with col_f2: st.image(foto_perfil, width='stretch')
                st.markdown(f"<h3 style='text-align:center; margin-bottom:2px; color:#0f172a;'>{emp_activo['nombre']}</h3>", unsafe_allow_html=True)
                st.markdown(f"<p style='text-align:center; color:#16a34a; margin-top:0;'>🔑 {emp_activo['depto'] if emp_activo['depto'] else 'SISTEMA'}</p>", unsafe_allow_html=True)
                
                pass_input = st.text_input("CONTRASEÑA:", type="password", placeholder="••••••••", label_visibility="collapsed")
                st.write("")
                
                b_ok, b_cancel = st.columns(2)
                if b_ok.button("🔒 ENTRAR", type="primary", width='stretch'):
                    try:
                        payload = {"usuario": emp_activo["nombre"], "contrasena": pass_input}
                        res = requests.post(f"{API_URL}/api/auth/login", json=payload, verify=False)
                        if res.status_code == 200:
                            d_user = res.json()
                            st.session_state.update({
                                "autenticado": True, 
                                "usuario_actual": d_user["nombre_completo"], 
                                "rol": d_user["rol"], 
                                "depto": d_user["depto"], 
                                "id_usuario": d_user["id_empleado"],
                                "requiere_cambio": False if str(d_user["id_empleado"]) == "529" else d_user.get("requiere_cambio", False)
                            })
                            st.rerun()
                        else: st.error("❌ Clave incorrecta.")
                    except Exception as e: st.error(f"📡 Error: {e}")
                
                if b_cancel.button("❌ REGRESAR", width='stretch'):
                    st.session_state.empleado_seleccionado = None
                    st.rerun()
    st.stop()
    
if st.session_state.get("requiere_cambio", False):  # 🚧 RETÉN DE SEGURIDAD CRÍTICA: CAMBIO FORZOSO DE CONTRASEÑA
    import re       # Escondemos el menú lateral por completo para que no se escape
    
    st.markdown("""<style>[data-testid="stSidebar"] { display: none !important; } [data-testid="stSidebarCollapseButton"] { display: none !important; }</style>""", unsafe_allow_html=True)
    
    c1, c2, c3 = st.columns([1, 1.5, 1])
    with c2:
        st.write("")
        st.write("")
        with st.container(border=True):
            st.markdown("<h2 style='text-align:center; color:#0f172a; font-weight:800; margin-bottom: 5px; font-family: sans-serif;'>Crea una contraseña segura</h2>", unsafe_allow_html=True)
            st.markdown("<p style='text-align:center; color:#64748b; margin-top: 0px;'>Por políticas de seguridad, debes actualizar tu clave temporal.</p>", unsafe_allow_html=True)
            st.write("")
            
            pass_nueva = st.text_input("Contraseña*", type="password", key="input_nueva_pass_segura", placeholder="••••••••••••")
            
            v_len = len(pass_nueva) >= 8        # 🧠 LÓGICA DE VALIDACIÓN EN TIEMPO REAL
            v_upper = bool(re.search(r'[A-Z]', pass_nueva))
            v_lower = bool(re.search(r'[a-z]', pass_nueva))
            v_num = bool(re.search(r'\d', pass_nueva))
            v_sym = bool(re.search(r'[!@#$%^&*(),.?":{}|<>]', pass_nueva))
            
            todos_validos = v_len and v_upper and v_lower and v_num and v_sym
            
            # 🎨 DISEÑO DE UI MODERNA (ESTILO iOS)
            st.markdown(f"""
                <div style='display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid {"#2563eb" if todos_validos else "#e2e8f0"}; padding-bottom: 5px; margin-bottom: 15px;'>
                    <span style='color: #64748b; font-size: 14px;'>Seguridad de contraseña</span>
                    <span style='color: {"#2563eb" if todos_validos else "#94a3b8"}; font-size: 14px; font-weight: bold;'>{"Muy fuerte" if todos_validos else "Requiere atención"}</span>
                </div>
            """, unsafe_allow_html=True)
            
            def render_check(valido, texto):
                color_icono = "#2563eb" if valido else "#cbd5e1"
                icono = "✔" if valido else "⚪"
                color_texto = "#0f172a" if valido else "#64748b"
                return f"<div style='margin-bottom: 8px;'><span style='color: {color_icono}; font-weight: bold; margin-right: 8px;'>{icono}</span><span style='color: {color_texto}; font-size: 14px;'>{texto}</span></div>"
            
            st.markdown(render_check(v_len, "Mínimo de 8 caracteres"), unsafe_allow_html=True)
            st.markdown(render_check(v_upper and v_lower, "Letras minúsculas y mayúsculas"), unsafe_allow_html=True)
            st.markdown(render_check(v_num, "Al menos 1 número"), unsafe_allow_html=True)
            st.markdown(render_check(v_sym, "Al menos 1 símbolo (ej. @, #, $, !)"), unsafe_allow_html=True)
            
            st.write("")
            st.write("")
            
            if st.button("Continuar", type="primary", width='stretch'):
                if not todos_validos:
                    st.error("⚠️ Tu contraseña aún no cumple con todos los requisitos de seguridad.")
                else:
                    try:
                        payload_cp = {
                            "id_empleado": str(st.session_state.id_usuario),
                            "nueva_contrasena": pass_nueva
                        }
                        res_cp = requests.post(f"{API_URL}/api/auth/cambiar-password", json=payload_cp, verify=False)
                        
                        if res_cp.status_code == 200:
                            st.success("✅ ¡Contraseña blindada con éxito! Entrando al sistema...")
                            time.sleep(1.5)
                            st.session_state.requiere_cambio = False
                            st.rerun()
                        else:
                            st.error("❌ Error al actualizar la contraseña en el servidor.")
                    except Exception as e:
                        st.error(f"📡 Error de conexión: {e}")
    st.stop()

es_kiosko = st.session_state.get("id_usuario") == "529" # Evaluar identidades críticas post-autenticación
usuario_real = str(st.session_state.get("usuario_actual", "")).strip()
es_cuauhtemoc = "Cuauhtémoc Rivera" in usuario_real or "Cuauhtemoc Rivera" in usuario_real

if es_kiosko:       # 🎨 INYECCIÓN DE ESTILOS PREMIUM
    st.markdown("""<style>[data-testid="stSidebar"] { display: none !important; } [data-testid="stSidebarCollapseButton"] { display: none !important; } .main .block-container { max-width: 95% !important; padding-top: 2rem !important; padding-bottom: 2rem !important; padding-left: 5rem !important; padding-right: 5rem !important; }</style>""", unsafe_allow_html=True)
else:
    st.markdown("""<style>[data-testid="stSidebarNav"] { display: none; } .st-emotion-cache-6qob1r { background-color: #0f172a; } div[data-testid="stSidebarUserContent"] { padding-top: 0rem; } div.row-widget.stRadio > div { background-color: transparent !important; } label[data-testid="stWidgetLabel"] { font-weight: bold !important; color: #0f172a !important; } .main .block-container { max-width: 95% !important; padding-top: 1.5rem !important; padding-bottom: 1.5rem !important; padding-left: 2.5rem !important; padding-right: 2.5rem !important; }</style>""", unsafe_allow_html=True)

rol_actual = str(st.session_state.get("rol", "")).strip().upper()       # --- CONSTRUCCIÓN DEL MENÚ LATERAL INTERACTIVO Y FILTRADO REAL POR ROL
usuario_completo_menu = str(st.session_state.get("usuario_actual", "")).strip().upper()
llave_menu_clean = ''.join(c for c in unicodedata.normalize('NFD', usuario_completo_menu) if unicodedata.category(c) != 'Mn')

es_villarreal_menu = any(x in llave_menu_clean for x in ["ANDREA", "SOFIA", "GERARDO", "PEDRO", "ANA LILIA"]) or "VILLAREAL" in llave_menu_clean        # 👑 ADUANA DE DIRECCIÓN GENERAL: Identifica si el usuario logueado es un Villarreal

if es_kiosko:
    menu_opciones = ["🕒 Checador"]
else:
    menu_opciones = ["🏠 Inicio"]
    
    if rol_actual in ["ADMIN", "COORDINADOR"]:
        menu_opciones.append("📝 Orden de Produccion")
        menu_opciones.append("🚙 Autos")
        
    menu_opciones.append("🛠️ Inventario")
        
    if rol_actual == "ADMIN":
        menu_opciones.extend(["🦺 Empleados", "🚚 Proveedores", "🏢 Clientes"])
            
    menu_opciones.append("📦 Checkout [VPF-PSP-CHL]")
    
    if rol_actual in ["ADMIN", "COORDINADOR"]:
        menu_opciones.append("📊 Incidencias")
        
    menu_opciones.append("🚩 Equipos con Daño")
    
    if rol_actual in ["ADMIN", "COORDINADOR", "PRODUCTOR"]:
        conteo_pendientes = contar_gastos_pendientes()
        etiqueta_gastos = f"💸 Reporte de Gastos ({conteo_pendientes})" if conteo_pendientes > 0 else "💸 Reporte de Gastos"
        menu_opciones.append(etiqueta_gastos)
        
    if rol_actual == "ADMIN" or es_villarreal_menu or es_cuauhtemoc:
        menu_opciones.append("📈 Analítica y KPIs")
    
    menu_opciones.append("🕒 Checador")

# 🎛️ RENDERIZADO DEL SIDEBAR CON MENÚ SEGURO A UN SOLO CLIC
with st.sidebar:
    try:
        logo_base64 = get_base64_of_bin_file("vpro_menu.jpg")
        if logo_base64:
            st.markdown(f"""
            <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; gap: 8px; margin-bottom: 20px; margin-top: -10px;">
                <img src="data:image/jpeg;base64,{logo_base64}" 
                     style="width: 100%; max-width: 260px; height: auto; border-radius: 4px; box-shadow: 0 4px 6px rgba(0,0,0,0.15);">
                <h3 style="margin: 0; padding: 0; font-size: 17px; color: #0f172a; font-weight: 800; border: none; letter-spacing: 0.5px;">
                    SISTEMA INTEGRAL VPRO
                </h3>
            </div>
            """, unsafe_allow_html=True)
        else:
            st.markdown("<h3 style='text-align: center; color: #0f172a; margin-top: 0;'>🎬 SISTEMA INTEGRAL VPRO</h3>", unsafe_allow_html=True)
    except Exception:
        st.markdown("<h3 style='text-align: center; color: #0f172a; margin-top: 0;'>🎬 SISTEMA INTEGRAL VPRO</h3>", unsafe_allow_html=True)
        
    st.markdown(f"<p style='text-align:center; color:#334155; margin:0; font-size:15px;'><b>{st.session_state.usuario_actual}</b><br><small style='color:#64748b; font-weight:bold;'>{st.session_state.rol}</small></p>", unsafe_allow_html=True)
    st.divider()
    
    if "menu_dinamico" not in st.session_state:
        st.session_state.menu_dinamico = menu_opciones[0]
        
    try:
        idx_menu_destino = menu_opciones.index(st.session_state.menu_dinamico)
    except:
        idx_menu_destino = 0
        
    opcion_seleccionada = st.sidebar.radio("MENÚ PRINCIPAL:", menu_opciones, index=idx_menu_destino)
    
    if opcion_seleccionada != st.session_state.menu_dinamico:
        st.session_state.menu_dinamico = opcion_seleccionada
        st.rerun()
    
    if st.button("🚪 Cerrar Sesión", width='stretch'):
        st.session_state.clear()
        st.rerun()
                        
st.header(f"{opcion_seleccionada}")
st.write("---")

if "Inicio" in opcion_seleccionada:     # 🏠 MÓDULO: INICIO
    rol_actual = st.session_state.get('role', st.session_state.get('rol', ''))
    es_admin = (rol_actual == "ADMIN") 
    usuario_completo = st.session_state.usuario_actual
    id_usuario = str(st.session_state.get("id_usuario", ""))
    
    df_incidencias_depto = pd.DataFrame()
    df_danados_tracking = pd.DataFrame()
    df_top_emp = pd.DataFrame()
    total_eventos, cliente_top, equipos_reparacion, desviacion = 0, "---", 0, "0.0% Desviación"
    
    tabla_alias = {
        "ANA LILIA VILLARREAL URIBE": "Ana Lilia", "GERARDO VILLARREAL URIBE": "Gerardo", 
        "JOSE FRANCISCO TORRES SANCHEZ": "Paco", "JOSE DANIEL TORRES ARROYO": "Dany", 
        "MARTIN EDUARDO SANCHEZ ESTRADA": "Geo", "OSIEL CUAUHTEMOC HERNANDEZ ALDAPE": "Osiel",
        "CARLOS JACOBO QUEZADA MENDOZA": "Carlos", "IBON ARACELI CAMPOS MEDINA": "Ibon", 
        "MANUEL ANTONIO MADRID ZAZUETA": "Manuel", "SOFIA ALEJANDRA VILLARREAL LOPEZ": "Sofia", 
        "MANUEL EDUARDO MADRID": "Manuel Eduardo", "ANDREA MARIA VILLARREAL LOPEZ": "Andrea",
        "CUAUHTEMOC RIVERA AGUNDEZ": "Cuauhtemoc", "EDGAR JAVIER AMARILLAS": "Edgar", 
        "PEDRO VILLARREAL URIBE": "Sr. Pedro Villarreal"
    }
    
    llave_busqueda = str(usuario_completo).strip().upper()
    llave_busqueda = ''.join(c for c in unicodedata.normalize('NFD', llave_busqueda) if unicodedata.category(c) != 'Mn')
    nombre_saludo = tabla_alias.get(llave_busqueda, usuario_completo.split()[0] if usuario_completo else "Operador")

    st.subheader(f"Hola {nombre_saludo} 👋")
    
    st.write("")        # 🔔 1. REVISIÓN DE PENDIENTES GLOBALES (GASTOS Y CHECKOUTS)
    ya_puso_titulo = False

    if st.session_state.rol in ["ADMIN", "DIRECCION"]:      # --- A) ALERTA DE REPORTES DE GASTOS PENDIENTES (Agrupado Ejecutivo) ---
        try:
            res_gastos_pendientes = requests.get(f"{API_URL}/api/gastos/pendientes-auditoria", verify=False, timeout=3)
            if res_gastos_pendientes.status_code == 200:
                gastos_por_revisar = res_gastos_pendientes.json()
                if gastos_por_revisar:
                    st.markdown("### 🔔 Centro de Notificaciones")
                    ya_puso_titulo = True
                    
                    dict_emps = {}      # 1. Bajamos catálogo para traducir el ID a Nombre
                    try:
                        r_emps = requests.get(f"{API_URL}/api/empleados", verify=False, timeout=2)
                        if r_emps.status_code == 200:
                            for e in r_emps.json():
                                dict_emps[str(e["id_empleado"]).strip()] = e.get("nombre", "Desconocido")
                    except: pass

                    with st.expander(f"📁 Bandeja de Auditoría: Tienes {len(gastos_por_revisar)} Reportes Listos para Firma", expanded=False):      # 2. 📁 ENCAPSULAMOS TODO EN UNA SOLA BANDEJA EJECUTIVA
                        for gasto in gastos_por_revisar:
                            folio_g = gasto.get('folio_op', 'S/F')
                            id_emp = str(gasto.get('id_empleado', '')).replace("ID: ", "").strip()
                            nombre_productor = dict_emps.get(id_emp, f"ID: {id_emp}")
                            
                            col_g_txt, col_g_btn = st.columns([4, 1])   # Fila compacta y limpia
                            with col_g_txt:
                                st.markdown(f"🧾 **OP-{folio_g}** | Productor: **{nombre_productor}**")
                            with col_g_btn:
                                if st.button("🔍 REVISAR", key=f"btn_rev_gasto_{folio_g}", width='stretch'):
                                    conteo = contar_gastos_pendientes()
                                    nombre_menu_gastos = f"💸 Reporte de Gastos ({conteo})" if conteo > 0 else "💸 Reporte de Gastos"
                                    st.session_state.menu_dinamico = nombre_menu_gastos
                                    st.session_state.folio_auditoria_gastos = folio_g
                                    st.rerun()
                            st.markdown("<hr style='margin: 0px 0px 10px 0px; padding: 0; border-top: 1px solid #e2e8f0;'>", unsafe_allow_html=True)
        except Exception: pass

    try:        # --- B) ALERTA DE CHECKOUTS PERSONALES (Agrupado Ejecutivo) ---
        res_pend = requests.get(f"{API_URL}/api/checkout/pendientes/{id_usuario}/{usuario_completo}", verify=False, timeout=3)
        if res_pend.status_code == 200:
            ops_pendientes = res_pend.json()
            if ops_pendientes:
                if not ya_puso_titulo:
                    st.markdown("### 🔔 Centro de Notificaciones")
                
                with st.expander(f"📦 Tienes {len(ops_pendientes)} Órdenes Pendientes de Bodega (Checkout)", expanded=False):   # 📁 ENCAPSULAMOS LOS CHECKOUTS EN UNA SOLA BANDEJA
                    for op in ops_pendientes:
                        col_p_txt, col_p_btn = st.columns([4, 1])
                        with col_p_txt:
                            st.markdown(f"⚠️ **{op['label']}** | Estatus actual: `{op['estado']}`")
                        with col_p_btn:
                            if st.button("📝 ELABORAR", key=f"home_pend_{op['id_evento']}", width='stretch'):
                                st.session_state.menu_dinamico = "📦 Checkout" 
                                st.session_state.op_activa_checkout = op['label']
                                st.session_state.modo_actual = "MODIFICAR"
                                st.rerun()
                        st.markdown("<hr style='margin: 0px 0px 10px 0px; padding: 0; border-top: 1px solid #e2e8f0;'>", unsafe_allow_html=True)
                st.write("")
    except Exception: pass

    if rol_actual in ["COORDINADOR", "ADMIN"] or es_cuauhtemoc: # 🚨 2. RADAR LOGÍSTICO PARA COORDINADORES / ADMIN
        try:
            dias_radar = st.session_state.get("slider_profundidad_radar_omisos_final", 7)   # Rescatamos el valor del slider de la memoria, por defecto 7 días
            res_faltantes = requests.get(f"{API_URL}/api/checkout/faltantes-global", params={"dias": dias_radar}, verify=False, timeout=4)
            
            if res_faltantes.status_code == 200:
                lista_omisos = res_faltantes.json()
                
                if lista_omisos:
                    with st.expander(f"🚨 Radar de Bodega: Se detectaron {len(lista_omisos)} Checkouts Omisos", expanded=False):    # 📁 BANDEJA CERRADA CON ALERTA DISCRETA
                        st.slider("🔍 Días de profundidad para búsqueda:", min_value=5, max_value=30, value=7, step=1, key="slider_profundidad_radar_omisos_final")
                        st.markdown("<p style='color: #ef4444; font-size: 14px; font-weight: bold; margin-bottom: 5px;'>⚠️ Personal que no ha realizado su checkout (retorno de equipo):</p>", unsafe_allow_html=True)
                        st.dataframe(pd.DataFrame(lista_omisos), width='stretch', hide_index=True, key="tabla_radar_omisos_coordinador")
                else: 
                    with st.expander("✅ Radar de Bodega: 100% de Checkouts al día (Operación Limpia)", expanded=False):    # 📁 BANDEJA CERRADA CON ESTATUS VERDE
                        st.slider("🔍 Días de profundidad para búsqueda:", min_value=5, max_value=30, value=7, step=1, key="slider_profundidad_radar_omisos_final")
                        st.success("🎉 ¡Excelente control! Todo el personal convocado en este periodo ha elaborado su checkout a tiempo.")
        except Exception as e_omisos: 
            pass
        
        st.divider()

    # 👑 C) ALERTAS EXCLUSIVAS DE DIRECCIÓN (FAMILIA VILLARREAL / ADMIN)
    es_villarreal = any(x in llave_busqueda for x in ["VILLARREAL", "ANA LILIA", "PEDRO", "GERARDO", "ANDREA", "SOFIA"])
    if es_admin or es_villarreal:
        licencias_alertas, cumpleanos_alertas, seguros_alertas, retardos_alertas, puntuales_alertas = [], [], [], [], []
        hoy = datetime.date.today()
        
        # 1. 🪪 REVISIÓN DE LICENCIAS Y 🎂 CUMPLEAÑOS (Desde Catálogo de Empleados)
        try:
            res_emp_alertas = requests.get(f"{API_URL}/api/empleados", verify=False, timeout=3)
            if res_emp_alertas.status_code == 200:
                for emp in res_emp_alertas.json():
                    if str(emp.get('rol', '')).upper() in ['BAJA', 'PROVEEDOR', 'INACTIVO']: continue
                    nombre_e = str(emp.get('nombre', 'Desconocido')).title()
                    
                    # Analizar Licencias
                    vence_lic = emp.get('licencia_vence')
                    if not vence_lic or str(vence_lic).strip().lower() in ["none", "nan", ""]:
                        licencias_alertas.append(f"⚠️ **{nombre_e}** no tiene licencia registrada.")
                    else:
                        fecha_lic = pd.to_datetime(vence_lic).date()
                        dias_lic = (fecha_lic - hoy).days
                        if dias_lic < 0:
                            licencias_alertas.append(f"🚨 **{nombre_e}**: Licencia VENCIDA hace {abs(dias_lic)} días.")
                        elif 0 <= dias_lic <= 15:
                            licencias_alertas.append(f"⚠️ **{nombre_e}**: Licencia por vencer en {dias_lic} días.")
                            
                    # Analizar Cumpleaños (Rango de 3 días)
                    nac = emp.get('fecha_nac')
                    if nac and str(nac).strip().lower() not in ["none", "nan", ""]:
                        try:
                            fecha_nac = pd.to_datetime(nac).date()
                            # Ajuste para calcular el cumpleaños de este año (ignorando año bisiesto bug)
                            try: cumple_este_ano = fecha_nac.replace(year=hoy.year)
                            except ValueError: cumple_este_ano = fecha_nac.replace(year=hoy.year, day=28)
                            
                            # Si ya pasó este año, mirar al próximo
                            if cumple_este_ano < hoy:
                                try: cumple_este_ano = cumple_este_ano.replace(year=hoy.year + 1)
                                except ValueError: cumple_este_ano = cumple_este_ano.replace(year=hoy.year + 1, day=28)
                                
                            dias_cumple = (cumple_este_ano - hoy).days
                            if 0 <= dias_cumple <= 3:
                                if dias_cumple == 0: cumpleanos_alertas.append(f"🎈 ¡HOY es el cumpleaños de **{nombre_e}**! 🎂")
                                elif dias_cumple == 1: cumpleanos_alertas.append(f"🎁 Mañana es el cumpleaños de **{nombre_e}**.")
                                else: cumpleanos_alertas.append(f"🎉 **{nombre_e}** cumple años en {dias_cumple} días.")
                        except: pass
        except Exception: pass

        # 2. 🛡️ REVISIÓN DE SEGUROS VEHICULARES (Desde Catálogo de Autos)
        try:
            res_autos_alertas = requests.get(f"{API_URL}/api/autos", verify=False, timeout=3)
            if res_autos_alertas.status_code == 200:
                for auto in res_autos_alertas.json():
                    vence_seg = auto.get('seguro_vence')
                    vehiculo_str = f"{str(auto.get('marca','')).title()} {str(auto.get('modelo','')).title()} (ID: {auto.get('num_control','')})"
                    
                    if not vence_seg or str(vence_seg).strip().lower() in ["none", "nan", ""]:
                        seguros_alertas.append(f"⚠️ **{vehiculo_str}** no tiene póliza de seguro registrada.")
                    else:
                        fecha_seg = pd.to_datetime(vence_seg).date()
                        dias_seg = (fecha_seg - hoy).days
                        if dias_seg < 0:
                            seguros_alertas.append(f"🚨 **{vehiculo_str}**: Seguro VENCIDO hace {abs(dias_seg)} días.")
                        elif 0 <= dias_seg <= 30:
                            seguros_alertas.append(f"⚠️ **{vehiculo_str}**: Seguro por vencer en {dias_seg} días.")
        except Exception: pass

        # 3. ⏱️ REVISIÓN DE DISCIPLINA (Desde Panel Analítico del API)
        try:
            res_vill = requests.get(f"{API_URL}/api/analitica/villarreal-panel", verify=False, timeout=3)
            if res_vill.status_code == 200 and res_vill.json().get("status") == "SUCCESS":
                kpis = res_vill.json().get("kpis", {})
                
                mas_retardos = kpis.get("empleado_mas_retardos", "")
                if mas_retardos and "Sin retardos" not in mas_retardos:
                    retardos_alertas.append(f"🔴 **Área de Oportunidad:** {mas_retardos}")
                    
                menos_retardos = kpis.get("empleados_menos_retardos", [])
                for p in menos_retardos:
                    if "Sin marcas" not in p: puntuales_alertas.append(f"🟢 **Destacado:** {p}")
        except Exception: pass

        # --- 🎨 RENDERIZADO VISUAL EN BANDEJAS EJECUTIVAS ---
        if licencias_alertas or cumpleanos_alertas or seguros_alertas or retardos_alertas:
            st.markdown("<br><p style='color: #0f172a; font-size: 16px; font-weight: bold; margin-bottom: 5px;'>👑 Radar Directivo</p>", unsafe_allow_html=True)
            
            if cumpleanos_alertas:
                with st.expander(f"🎂 Tienes {len(cumpleanos_alertas)} eventos de personal (Cumpleaños)", expanded=False):
                    for c in cumpleanos_alertas:
                        st.markdown(f"<span>{c}</span>", unsafe_allow_html=True)
                        st.markdown("<hr style='margin: 5px 0px; border-top: 1px dashed #e2e8f0;'>", unsafe_allow_html=True)
            
            if licencias_alertas:
                with st.expander(f"🪪 Tienes {len(licencias_alertas)} alertas de Licencias de Conducir (Vencidas/Próximas)", expanded=False):
                    for l in licencias_alertas:
                        color_text = "#ef4444" if "VENCIDA" in l else "#f59e0b"
                        st.markdown(f"<span style='color: {color_text};'>{l}</span>", unsafe_allow_html=True)
                        st.markdown("<hr style='margin: 5px 0px; border-top: 1px dashed #e2e8f0;'>", unsafe_allow_html=True)

            if seguros_alertas:
                with st.expander(f"🛡️ Tienes {len(seguros_alertas)} alertas de Seguros Vehiculares y Flota", expanded=False):
                    for s in seguros_alertas:
                        color_text = "#ef4444" if "VENCIDO" in s else "#f59e0b"
                        st.markdown(f"<span style='color: {color_text};'>{s}</span>", unsafe_allow_html=True)
                        st.markdown("<hr style='margin: 5px 0px; border-top: 1px dashed #e2e8f0;'>", unsafe_allow_html=True)
                        
            if retardos_alertas or puntuales_alertas:
                with st.expander(f"⏱️ Radar de Disciplina y Puntualidad (Últimos 30 días)", expanded=False):
                    for r in retardos_alertas:
                        st.markdown(f"<span>{r}</span>", unsafe_allow_html=True)
                        st.markdown("<hr style='margin: 5px 0px; border-top: 1px dashed #e2e8f0;'>", unsafe_allow_html=True)
                    for p in puntuales_alertas:
                        st.markdown(f"<span>{p}</span>", unsafe_allow_html=True)
                        st.markdown("<hr style='margin: 5px 0px; border-top: 1px dashed #e2e8f0;'>", unsafe_allow_html=True)
                        
        # 🎨 Inyección CSS para reducir el tamaño de las métricas y darle look Ejecutivo
        st.markdown("""
        <style>
        /* Reducimos la letra del valor principal */
        [data-testid="stMetricValue"] {
            font-size: 1.5rem !important; 
        }
        /* Hacemos que el texto baje al siguiente renglón en lugar de cortarse con "..." */
        [data-testid="stMetricValue"] > div {
            white-space: normal !important;
            word-wrap: break-word !important;
            line-height: 1.2 !important;
        }
        </style>
        """, unsafe_allow_html=True)

        st.markdown("<h4 style='color:#0f172a;'>📅 Filtro de Periodo Operativo</h4>", unsafe_allow_html=True)

        # 📅 Selector de rango unificado (Estilo Ejecutivo)
        rango_operativo = st.date_input("Periodo de Consulta:",  value=[datetime.date(2026, 6, 1), datetime.date.today()])

        if isinstance(rango_operativo, (list, tuple)) and len(rango_operativo) == 2:
            fecha_inicio, fecha_fin = rango_operativo[0], rango_operativo[1]
        elif isinstance(rango_operativo, (list, tuple)) and len(rango_operativo) == 1:
            fecha_inicio, fecha_fin = rango_operativo[0], rango_operativo[0]
        else:
            fecha_inicio, fecha_fin = datetime.date.today(), datetime.date.today()

        st.write("---")

        # 🔌 INICIO DE CABLES INTERNOS: Sincronizando BD con los calendarios
        df_inc_global = pd.DataFrame()
        with st.spinner("🧠 Sincronizando métricas operativas..."):
            try:
                # 1. Top Empleados (Convocatorias)
                res_asist = requests.get(f"{API_URL}/api/asistencia/reporte", verify=False)
                if res_asist.status_code == 200 and res_asist.json():
                    df_temp = pd.DataFrame(res_asist.json())
                    df_temp['fecha'] = pd.to_datetime(df_temp['fecha']).dt.date
                    df_fil = df_temp[(df_temp['fecha'] >= fecha_inicio) & (df_temp['fecha'] <= fecha_fin)]
                    if not df_fil.empty:
                        df_top = df_fil['nombre_empleado'].value_counts().reset_index()
                        df_top.columns = ['Empleado', 'Días Convocados / Laborados']
                        df_top_emp = df_top.head(10)

                # 2. Incidencias y Fugas
                res_inc = requests.get(f"{API_URL}/api/incidencias/reporte", verify=False)
                if res_inc.status_code == 200 and res_inc.json():
                    df_inc_temp = pd.DataFrame(res_inc.json())
                    df_inc_temp['fecha'] = pd.to_datetime(df_inc_temp['fecha']).dt.date
                    df_inc_global = df_inc_temp[(df_inc_temp['fecha'] >= fecha_inicio) & (df_inc_temp['fecha'] <= fecha_fin)]
                    if not df_inc_global.empty:
                        df_incidencias_depto = df_inc_global.groupby('depto_real').size().reset_index(name='Número de Incidencias')
                        df_incidencias_depto.rename(columns={'depto_real': 'Departamento'}, inplace=True)

                # 3. Hardware Dañado en Taller
                p_radar = {"user_id": id_usuario, "rol": "ADMIN", "nombre_usuario": usuario_completo}
                res_danos = requests.get(f"{API_URL}/api/inventario/radar-danos", params=p_radar, verify=False)
                if res_danos.status_code == 200 and res_danos.json():
                    df_danos_temp = pd.DataFrame(res_danos.json())
                    if not df_danos_temp.empty:
                        df_danos_temp['FECHA_REPORTE'] = pd.to_datetime(df_danos_temp['FECHA_REPORTE'], errors='coerce').dt.date
                        df_danos_fil = df_danos_temp[(df_danos_temp['FECHA_REPORTE'] >= fecha_inicio) & (df_danos_temp['FECHA_REPORTE'] <= fecha_fin)]
                        if not df_danos_fil.empty:
                            df_danados_tracking = pd.DataFrame({
                                "ID Equipo": df_danos_fil['ID'],
                                "Hardware": df_danos_fil['EQUIPO'],
                                "Reportado Por": df_danos_fil['REPORTÓ'],
                                "Folio Origen": df_danos_fil.get('FOLIO_TALLER', 'S/F'),
                                "Estatus de Recuperación": "⚙️ EN REPARACIÓN",
                                "Costo Est. ($)": 0.0
                            })
            except Exception as e:
                st.error(f"Fallo de conexión al sincronizar métricas: {e}")
        # 🔌 FIN DE CABLES INTERNOS

        # --- RENDERIZADO DE PESTAÑAS ---
        tab_personal, tab_incidencias, tab_hardware = st.tabs(["👥 Estadística de Personal", "⚠️ Incidencias por Área", "📦 Seguimiento a equipo REPORTADO COMO DAÑADO"])
        
        with tab_personal:
            st.markdown("#### 🏆 Top Empleados Más Convocados")
            if not df_top_emp.empty: 
                st.dataframe(df_top_emp, hide_index=True, width='stretch')
            else: 
                st.info("📭 No se registraron convocatorias operativas en este rango de fechas.")
            
        with tab_incidencias:
            st.markdown("#### 🔍 Análisis de Errores por Periodo, Departamento y Operador")
            sub_tab_global, sub_tab_depto, sub_tab_emp = st.tabs(["🌐 Resumen Global", "🏢 Por Departamento", "👤 Por Empleado"])
            
            with sub_tab_global:
                st.markdown("**Bitácora Cronológica de Reportes en Ruta:**")
                if not df_inc_global.empty:
                    st.dataframe(
                        df_inc_global[['fecha', 'folio_op', 'incidencias_generales', 'nombre_empleado', 'depto_real']], 
                        hide_index=True, 
                        width='stretch'
                    )
                else:
                    st.success("✅ Operación limpia: Sin reportes de incidencias globales en este periodo.")
                
            with sub_tab_depto:
                st.markdown("**Fugas Operativas vs Operaciones Limpias por Área:**")
                
                df_valido = df_inc_global.copy()    # 🚫 Filtro de Limpieza: Excluir la OP-42 de las estadísticas
                if not df_valido.empty and 'folio_op' in df_valido.columns:
                    df_valido = df_valido[df_valido['folio_op'].astype(str) != "42"]

                if not df_valido.empty: # 🧠 1. Clasificador Inteligente de Texto (LA REGLA ALV)
                    def clasificar_reporte(texto):
                        texto_limpio = str(texto).strip()
                        
                        if pd.isna(texto) or texto_limpio in ["", "nan", "None", "null"]: # 🕵️‍♂️ Omisiones (En Blanco)
                            return "⚪ Omisión (En Blanco)"
                        
                        if 0 < len(texto_limpio) < 21: # 🛡️ LA REGLA DE ORO (>0 y <21): Si escribieron poquito, todo chido ALV.
                            return "✅ Operación Limpia"
                            
                        return "🚨 Incidencia Real" # 🚨 Si se pasaron de 20 letras... ya soltaron el llanto.

                    df_grafica = df_valido.copy()   # 2. Preparamos los datos
                    df_grafica['Estatus'] = df_grafica['incidencias_generales'].apply(clasificar_reporte)
                    df_grafica['Departamento'] = df_grafica['depto_real']

                    df_agrupado = df_grafica.groupby(['Departamento', 'Estatus']).size().reset_index(name='Cantidad de Reportes')   # 3. Agrupamos contando las incidencias

                    # 📊 4. Dibujamos la gráfica de Barras Agrupadas
                    fig_depto = px.bar(
                        df_agrupado, 
                        x="Departamento", 
                        y="Cantidad de Reportes", 
                        color="Estatus", 
                        text_auto=True, 
                        barmode='group',
                        color_discrete_map={"✅ Operación Limpia": "#16a34a","🚨 Incidencia Real": "#dc2626","⚪ Omisión (En Blanco)": "#94a3b8"})
                    
                    fig_depto.update_layout(height=380, margin=dict(t=30, b=10, l=10, r=10), legend_title_text="")
                    st.plotly_chart(fig_depto, width='stretch')
                    
                    st.write("---") # 👇 DESGLOSE DETALLADO 👇
                    st.markdown("##### 📋 Desglose Detallado de Reportes")
                    
                    columnas_requeridas = ['fecha', 'id_empleado', 'nombre_empleado', 'depto_real', 'folio_op', 'incidencias_generales']
                    for col in columnas_requeridas:
                        if col not in df_valido.columns:
                            df_valido[col] = "N/A"
                            
                    st.dataframe(
                        df_valido[columnas_requeridas], 
                        column_config={
                            "fecha": "Fecha",
                            "id_empleado": "Núm. Empleado",
                            "nombre_empleado": "Nombre",
                            "depto_real": "Departamento",
                            "folio_op": "Folio OP",
                            "incidencias_generales": "Reporte de Incidencia"
                        },
                        width='stretch', 
                        hide_index=True
                    )
                else: 
                    st.success("✅ Operación limpia: Sin incidencias registradas en este periodo (o excluidas de la estadística).")
                
            with sub_tab_emp:
                st.markdown("**Top Empleados con Más Fugas / Incidencias Reportadas:**")
                if not df_danados_tracking.empty:
                    conteo_emp = df_danados_tracking['Reportado Por'].value_counts().reset_index()
                    conteo_emp.columns = ['Empleado', 'Total Fugas']
                    
                    fig_emp_fugas = px.bar(
                        conteo_emp, 
                        x='Total Fugas', 
                        y='Empleado', 
                        orientation='h',
                        text='Total Fugas',
                        color='Total Fugas',
                        color_continuous_scale=['#fb923c', '#ef4444', '#7f1d1d'], 
                    )
                    
                    fig_emp_fugas.update_traces(texttemplate='<b>%{text} incidentes</b>', textposition='outside')
                    fig_emp_fugas.update_layout(
                        yaxis={'categoryorder':'total ascending', 'title': ''},
                        xaxis={'title': 'Número de Daños / Fugas Reportadas'},
                        margin=dict(t=10, b=10, l=10, r=40),
                        showlegend=False
                    )
                    st.plotly_chart(fig_emp_fugas, width='stretch')
                else:
                    st.success("🎉 ¡Operación Impecable! Ningún miembro del personal registra incidencias, fugas o daños en el periodo seleccionado.")

        with tab_hardware:
            st.markdown("#### 🛠️ Bitácora y Seguimiento de Recuperación de Activos")
            st.write("Estatus actual de reparación y costeo de los equipos en el taller mecánico de VPRO:")
            
            if not df_danados_tracking.empty:
                edited_taller = st.data_editor(
                    df_danados_tracking,
                    column_config={
                        "Estatus de Recuperación": st.column_config.SelectboxColumn("Estatus de Recuperación", options=["⚙️ EN REPARACIÓN", "⏳ ESPERA DE REFACCIÓN", "✅ RECUPERADO / REINGRESÓ A BODEGA"], required=True),
                        "Costo Est. ($)": st.column_config.NumberColumn("Costo Reparación", format="$ %.2f")
                    },
                    hide_index=True,
                    width='stretch',
                    key="editor_taller_ceo_panel"
                )
                
                st.write("---") 
                st.markdown("##### 📸 Visor de Evidencias de Daño")
                
                c_visor1, c_visor2 = st.columns([2, 1])
                opciones_evidencia = df_danados_tracking["Folio Origen"].astype(str) + " | " + df_danados_tracking["ID Equipo"].astype(str)
                seleccion_ev = c_visor1.selectbox("🔍 Selecciona un equipo en taller para cargar su evidencia:", options=["---"] + opciones_evidencia.tolist())
                
                if seleccion_ev != "---":
                    fol_sel_id = seleccion_ev.split(" | ")[0].strip()
                    eq_sel_id = seleccion_ev.split(" | ")[1].strip()
                    
                    with st.spinner("Descargando imagen del servidor..."):
                        res_img = requests.get(f"{API_URL}/api/inventario/evidencia/{fol_sel_id}/{eq_sel_id}", verify=False)
                        if res_img.status_code == 200 and res_img.json().get("status") == "SUCCESS":
                            c_visor2.image(res_img.json()["imagen_b64"], caption=f"Evidencia de {eq_sel_id}", width='stretch')
                        else:
                            c_visor2.info("🚫 No se adjuntó fotografía al momento de levantar este reporte.")

                if not edited_taller.equals(df_danados_tracking):
                    st.write("")
                    if st.button("💾 ACTUALIZAR BITÁCORA DE TALLER", type="primary", width='stretch'):
                        st.success("🔒 Historial clínico de hardware actualizado con éxito en la base de datos.")
                        time.sleep(1)
                        st.rerun()
            else: 
                st.info("📭 Taller vacío. No hay hardware en estado de reparación en este periodo.")

    elif not es_cuauhtemoc:
        st.info("🎯 Panel operativo central listo. Selecciona una opción del menú de la izquierda para comenzar.")

# 🏢 MÓDULO: CLIENTES (CON CANDADO ANTI-BORRADO)
elif "Clientes" in opcion_seleccionada:
    st.subheader("🏢 ABC - Catálogo Maestro de Clientes VPRO")
    puede_editar = (st.session_state.rol == "ADMIN")
    
    # 🔒 Inicializadores de seguridad temporal para Clientes
    if "cli_borrados_pendientes" not in st.session_state: st.session_state.cli_borrados_pendientes = []
    if "cli_tabla_temporal" not in st.session_state: st.session_state.cli_tabla_temporal = None

    try:
        res_cli = requests.get(f"{API_URL}/api/clientes", verify=False)
        if res_cli.status_code == 200:
            df_cli = pd.DataFrame(res_cli.json())
            columnas_ordenadas = ["id_cliente", "cliente_empresa", "gte_gral", "estado", "ciudad", "tel_de_ofna", "email_de_empresa", "nombre_contacto_princ", "cel_contact_princ", "nombre_contacto_a", "cel_contact_a"]
            df_cli = df_cli[columnas_ordenadas] if not df_cli.empty else pd.DataFrame(columns=columnas_ordenadas)
            config_columnas_cli = {"id_cliente": st.column_config.NumberColumn("ID Cliente", required=True), "cliente_empresa": st.column_config.TextColumn("Cliente / Empresa", required=True), "gte_gral": st.column_config.TextColumn("Gerente General"), "estado": st.column_config.TextColumn("Estado"), "ciudad": st.column_config.TextColumn("Ciudad"), "tel_de_ofna": st.column_config.TextColumn("Tel. Oficina"), "email_de_empresa": st.column_config.TextColumn("Email de Empresa"), "nombre_contacto_princ": st.column_config.TextColumn("Contacto Principal"), "cel_contact_princ": st.column_config.TextColumn("Celular Principal"), "nombre_contacto_a": st.column_config.TextColumn("Contacto Alterno"), "cel_contact_a": st.column_config.TextColumn("Celular Alterno")}
            
            edited_df = st.data_editor(df_cli.reset_index(drop=True), column_config=config_columnas_cli, num_rows="dynamic" if puede_editar else "fixed", width='stretch', hide_index=True, disabled=not puede_editar, key="grid_clientes_vpro")
            
            if puede_editar:
                st.write("")
                
                # 🛑 ADUANA DE CONFIRMACIÓN VISUAL
                if st.session_state.cli_borrados_pendientes:
                    with st.container(border=True):
                        st.markdown("<h4 style='color: #ffb3b7;'>⚠️ CONTROL DE SEGURIDAD CRÍTICO</h4>", unsafe_allow_html=True)
                        st.warning(f"¿Confirmas la eliminación permanente en Postgres de los Clientes con ID: {st.session_state.cli_borrados_pendientes}?")
                        
                        btn_c1, btn_c2 = st.columns(2)
                        if btn_c1.button("🔥 SÍ, ELIMINAR REGISTROS", type="primary", width='stretch', key="btn_execute_delete_cli"):
                            # 1. Ejecutamos los deletes acumulados
                            for id_borrar in st.session_state.cli_borrados_pendientes:
                                requests.delete(f"{API_URL}/api/clientes/eliminar/{id_borrar}", verify=False)
                            
                            # 2. Guardamos o actualizamos el resto de la tabla
                            exito_operacion = True
                            for _, row in st.session_state.cli_tabla_temporal.iterrows():
                                if pd.isna(row['id_cliente']) or str(row['id_cliente']).strip() == "": continue
                                payload_cli = {"id_cliente": int(row['id_cliente']), "cliente_empresa": str(row['cliente_empresa']).strip().upper(), "gte_gral": str(row['gte_gral']).strip(), "estado": str(row['estado']).strip(), "ciudad": str(row['ciudad']).strip(), "tel_de_ofna": str(row['tel_de_ofna']).strip(), "email_de_empresa": str(row['email_de_empresa']).strip(), "nombre_contacto_princ": str(row['nombre_contacto_princ']).strip(), "cel_contact_princ": str(row['cel_contact_princ']).strip(), "nombre_contacto_a": str(row['nombre_contacto_a']).strip(), "cel_contact_a": str(row['cel_contact_a']).strip()}
                                res_save = requests.post(f"{API_URL}/api/clientes/guardar", json=payload_cli, verify=False)
                                if res_save.status_code != 200: exito_operacion = False
                            
                            # Limpiamos estados y recargamos
                            st.session_state.cli_borrados_pendientes = []
                            st.session_state.cli_tabla_temporal = None
                            if exito_operacion: st.success("✅ Base de clientes sincronizada."); time.sleep(1); st.rerun()
                            
                        if btn_c2.button("❌ CANCELAR OPERACIÓN", width='stretch', key="btn_cancel_delete_cli"):
                            st.session_state.cli_borrados_pendientes = []
                            st.session_state.cli_tabla_temporal = None
                            st.rerun()
                
                # BOTÓN MAESTRO DISPARADOR
                elif st.button("💾 GUARDAR CAMBIOS CLIENTES", type="primary", width='stretch'):
                    ids_antes = set(df_cli['id_cliente'].dropna().astype(int).tolist())
                    ids_ahora = set(edited_df['id_cliente'].dropna().astype(int).tolist())
                    bajas_solicitadas = list(ids_antes - ids_ahora)
                    
                    if bajas_solicitadas:
                        st.session_state.cli_borrados_pendientes = bajas_solicitadas
                        st.session_state.cli_tabla_temporal = edited_df
                        st.rerun()
                    else:
                        exito_operacion = True
                        for _, row in edited_df.iterrows():
                            if pd.isna(row['id_cliente']) or str(row['id_cliente']).strip() == "": continue
                            payload_cli = {"id_cliente": int(row['id_cliente']),
                                           "cliente_empresa": str(row['cliente_empresa']).strip().upper(),
                                           "gte_gral": str(row['gte_gral']).strip(),
                                           "estado": str(row['estado']).strip(),
                                           "ciudad": str(row['ciudad']).strip(),
                                           "tel_de_ofna": str(row['tel_de_ofna']).strip(),
                                           "email_de_empresa": str(row['email_de_empresa']).strip(),
                                           "nombre_contacto_princ": str(row['nombre_contacto_princ']).strip(),
                                           "cel_contact_princ": str(row['cel_contact_princ']).strip(),
                                           "nombre_contacto_a": str(row['nombre_contacto_a']).strip(),
                                           "cel_contact_a": str(row['cel_contact_a']).strip()}
                            res_save = requests.post(f"{API_URL}/api/clientes/guardar", json=payload_cli, verify=False)
                            if res_save.status_code != 200: exito_operacion = False
                        if exito_operacion: st.success("✅ Base de clientes sincronizada."); time.sleep(1); st.rerun()
    except Exception as e: st.error(f"❌ Error módulo clientes: {e}")
    
# 🛠️ MÓDULO INTERACTIVO DE INVENTARIO
elif "Inventario" in opcion_seleccionada:
    tab_catalogo, tab_alterno, tab_expediente = st.tabs([
        "📦 Catálogo Maestro de Hardware", 
        "🧳 Inventario Alterno (Kits)", 
        "📋 Expediente de Equipos"
    ])
    
    def semaforo_hardware(row):
        est = str(row.get('estado', '')).strip().upper()
        if est in ["BAJA", "DANADO", "DAÑADO", "FALLA", "DAÃ‘ADO"]: 
            return ['background-color: #5c191e; color: #ffb3b7; font-weight: 500'] * len(row)
        if est in ["REVISIÓN", "REVISION"]:
            return ['background-color: #422006; color: #fed7aa; font-weight: 500'] * len(row)
        return [''] * len(row)

    # PESTAÑA 1: CATÁLOGO MAESTRO DE HARDWARE
    with tab_catalogo:
        st.subheader("🛠️ ABC - Inventario General de Hardware")
        puede_editar = (st.session_state.rol == "ADMIN")
        try:
            res_inv = requests.get(f"{API_URL}/api/inventario", verify=False)
            if res_inv.status_code == 200:
                df_inv = pd.DataFrame(res_inv.json())
                config_columnas_inv = {"codigo": st.column_config.TextColumn("Código (ID)", required=True), "responsiva": st.column_config.TextColumn("Responsiva"), "fecha_compra": st.column_config.TextColumn("Fecha Compra"), "descripcion": st.column_config.TextColumn("Descripción de Hardware"), "marca": st.column_config.TextColumn("Marca"), "modelo": st.column_config.TextColumn("Modelo"), "serie": st.column_config.TextColumn("Número de Serie"), "responsable": st.column_config.TextColumn("Responsable"), "estado": st.column_config.TextColumn("Estado"), "ubicacion": st.column_config.TextColumn("Ubicación Bodega"), "observaciones": st.column_config.TextColumn("Observaciones Técnicas")}
                
                edited_df = st.data_editor(df_inv.style.apply(semaforo_hardware, axis=1), column_config=config_columnas_inv, num_rows="dynamic" if puede_editar else "fixed", width='stretch', hide_index=True, disabled=not puede_editar, key="grid_inventario_vpro")
                if puede_editar:
                    st.write("")
                    if st.button("💾 GUARDAR CAMBIOS INVENTARIO", type="primary", width='stretch'):
                        exito_operacion = True
                        ids_antes = set(df_inv['codigo'].dropna().astype(str).tolist())
                        ids_ahora = set(edited_df['codigo'].dropna().astype(str).tolist())
                        for id_borrar in (ids_antes - ids_ahora): requests.delete(f"{API_URL}/api/inventario/eliminar/{id_borrar}", verify=False)
                        for _, row in edited_df.iterrows():
                            if pd.isna(row['codigo']) or str(row['codigo']).strip() == "": continue
                            payload_inv = {"codigo": str(row['codigo']).strip().upper(), "responsiva": str(row['responsiva']).strip(), "fecha_compra": str(row['fecha_compra']).strip(), "descripcion": str(row['descripcion']).strip(), "marca": str(row['marca']).strip(), "modelo": str(row['modelo']).strip(), "serie": str(row['serie']).strip(), "responsable": str(row['responsable']).strip(), "estado": str(row['estado']).strip(), "ubicacion": str(row['ubicacion']).strip(), "observaciones": str(row['observaciones']).strip()}
                            res_save = requests.post(f"{API_URL}/api/inventario/guardar", json=payload_inv, verify=False)
                            if res_save.status_code != 200: exito_operacion = False
                        if exito_operacion: st.success("✅ Base de inventario sincronizada."); time.sleep(1); st.rerun()
        except Exception as e: st.error(f"❌ Error hardware: {e}")

    # PESTAÑA 2: INVENTARIO ALTERNO DE KITS
    with tab_alterno:
        st.subheader("🧳 ABC - Inventario Alterno de Hardware (Kits de Checkout)")
        es_coordinador_admin = (st.session_state.rol in ["ADMIN", "COORDINADOR"])
        try:
            res_alt = requests.get(f"{API_URL}/api/inventario-kits/completo", verify=False)
            if res_alt.status_code == 200:
                df_alt = pd.DataFrame(res_alt.json())
                
                if not df_alt.empty:
                    if 'equipo' in df_alt.columns and 'descripcion' not in df_alt.columns:
                        df_alt.rename(columns={'equipo': 'descripcion'}, inplace=True)
                    
                    if 'estado' in df_alt.columns:
                        df_alt['estado'] = df_alt['estado'].astype(str).str.upper().str.strip()
                        df_alt['estado'] = df_alt['estado'].replace({
                            "DAÃ‘ADO": "DANADO", "DAÑADO": "DANADO", "DAÑADA": "DANADO",
                            "REVISIÓN": "REVISION", "BUEN ESTADO": "BUEN ESTADO", "NONE": "", "NAN": ""
                        })
                        
                        if 'observaciones' in df_alt.columns:
                            for i in df_alt.index:
                                obs_texto = str(df_alt.at[i, 'observaciones']).lower()
                                est_texto = str(df_alt.at[i, 'estado']).strip()
                                if est_texto in ["", "NONE", "NAN", "CONTRATADO"]:
                                    if any(p in obs_texto for p in ["dañ", "rot", "fall", "quebr", "freg", "mal", "daã"]):
                                        df_alt.at[i, 'estado'] = "DANADO"
                                    else:
                                        df_alt.at[i, 'estado'] = "BUEN ESTADO"
                    
                    config_columnas_alt = {
                        "codigo": st.column_config.TextColumn("Código (ID)", disabled=True), 
                        "descripcion": st.column_config.TextColumn("Descripción de Hardware", disabled=True), 
                        "responsable": st.column_config.TextColumn("Responsable", disabled=True), 
                        "estado": st.column_config.SelectboxColumn("Estado", options=["BUEN ESTADO", "DANADO", "REVISION", "BAJA"], required=True),
                        "observaciones": st.column_config.TextColumn("Observaciones Técnicas / Diagnóstico de la pieza", width="large")
                    }
                    
                    edited_alt_df = st.data_editor(
                        df_alt.style.apply(semaforo_hardware, axis=1), 
                        column_config=config_columnas_alt, 
                        width='stretch', 
                        hide_index=True, 
                        disabled=not es_coordinador_admin,
                        key="grid_inventario_alterno_interactivo_vpro_final"
                    )
                    
                    if es_coordinador_admin:
                        st.write("")
                        if st.button("💾 APLICAR CAMBIOS Y DISPARAR REPORTES DE DAÑO", type="primary", width='stretch', key="btn_save_kits_salud_final"):
                            for idx, row_original in df_alt.iterrows():
                                row_editada = edited_alt_df.iloc[idx]
                                cod_item = row_original['codigo']
                                
                                if str(row_original['estado']).upper() != str(row_editada['estado']).upper() or str(row_original['observaciones']) != str(row_editada['observaciones']):
                                    payload_save_kit = {
                                        "codigo": str(cod_item).strip(),
                                        "estado": str(row_editada['estado']).strip().upper(),
                                        "observaciones": str(row_editada['observaciones']).strip()
                                    }
                                    requests.post(f"{API_URL}/api/inventario-kits/guardar", json=payload_save_kit, verify=False)
                                    
                                    payload_log = {
                                        "codigo_equipo": str(cod_item).strip().upper(),
                                        "tipo_evento": f"MODIFICACION_PANEL_{str(row_editada['estado']).upper()}",
                                        "descripcion": 'observaciones',
                                        "folio_vpro": "LOG_BODEGA_INTERNO",
                                        "id_empleado": str(st.session_state.get("id_usuario", "000")),
                                        "estado_final": "MANTENIMIENTO" if str(row_editada['estado']).upper() == "DANADO" else "RESUELTO",
                                        "departamento": str(st.session_state.get("depto", "OFICINA")).upper()
                                    }
                                    requests.post(f"{API_URL}/api/inventario/historial/guardar", json=payload_log, verify=False)
                                    
                            st.success("✅ Inventario e historial clínico actualizados en Postgres."); time.sleep(1); st.rerun()
                else: st.info("💡 No hay ítems alternos registrados.")
        except Exception as e: st.error(f"❌ Error hardware alterno: {e}")

    # PESTAÑA 3: EXPEDIENTE CLÍNICO DE EQUIPOS
    with tab_expediente:
        st.subheader("📋 Expediente Histórico de Equipo Inventariado")
        try:
            p_radar = {
                "user_id": str(st.session_state.get("id_usuario", "")),
                "rol": str(st.session_state.get("rol", "")),
                "nombre_usuario": str(st.session_state.get("usuario_actual", ""))
            }
            res_inv_list = requests.get(f"{API_URL}/api/inventario/radar-danos", params=p_radar, verify=False)
            
            if res_inv_list.status_code == 200:
                df_exp = pd.DataFrame(res_inv_list.json())
            
                if not df_exp.empty:
                    df_exp.columns = [str(c).upper().strip() for c in df_exp.columns]
                    
                    mapeo_clinico = {
                        'ID': 'codigo',
                        'EQUIPO': 'descripcion',
                        'FALLA': 'observaciones',
                        'REPORTÓ': 'responsable',
                        'ESTADO_INV': 'estado'
                    }
                    df_exp.rename(columns=mapeo_clinico, inplace=True)
                    df_exp.columns = [str(c).lower().strip() for c in df_exp.columns]
                    
                    for col_maestra in ['codigo', 'responsiva', 'fecha_compra', 'descripcion', 'marca', 'modelo', 'serie', 'responsable', 'estado', 'ubicacion', 'observaciones']:
                        if col_maestra not in df_exp.columns:
                            df_exp[col_maestra] = ""
                    
                    if 'equipo' in df_exp.columns and df_exp['descripcion'].eq("").all():
                        df_exp['descripcion'] = df_exp['equipo']
                    
                    if 'estado' in df_exp.columns:
                        df_exp['estado'] = df_exp['estado'].astype(str).str.upper().str.strip()
                        df_exp['estado'] = df_exp['estado'].replace({
                            "DAÃ‘ADO": "DANADO", "DAÑADO": "DANADO", "DAÑADA": "DANADO", "REVISIÓN": "REVISION"
                        })
                        
                        if 'observaciones' in df_exp.columns:
                            for i in df_exp.index:
                                if str(df_exp.at[i, 'estado']).strip() in ["", "NONE", "NAN"]:
                                    obs_t = str(df_exp.at[i, 'observaciones']).lower()
                                    if any(p in obs_t for p in ["dañ", "rot", "fall", "quebr", "freg", "mal", "daã"]):
                                        df_exp.at[i, 'estado'] = "DANADO"
                    
                    st.markdown("#### 🩺 Equipo/Activo con Reporte de Daño Activo")
                    st.markdown("<small style='color: #64748b;'>💡 Selecciona un renglón de la tabla con un clic para abrir su expediente histórico completo abajo.</small>", unsafe_allow_html=True)
                    st.write("")
                    
                    estados_sanos = ['OK', 'BUEN ESTADO', 'ACTIVO', 'NUEVO', 'FUNCIONANDO', '---', 'NONE', 'NAN', '']
                    df_danados = df_exp[~df_exp['estado'].astype(str).str.upper().str.strip().isin(estados_sanos)].copy().reset_index(drop=True)
                    
                    if not df_danados.empty:
                        config_columnas_clinicas = {
                            "codigo": st.column_config.TextColumn("Código (ID)"), 
                            "responsiva": st.column_config.TextColumn("Responsiva"), 
                            "fecha_compra": st.column_config.TextColumn("Fecha Compra"), 
                            "descripcion": st.column_config.TextColumn("Descripción de Hardware"), 
                            "marca": st.column_config.TextColumn("Marca"), 
                            "modelo": st.column_config.TextColumn("Modelo"), 
                            "serie": st.column_config.TextColumn("Número de Serie"), 
                            "responsable": st.column_config.TextColumn("Responsable"), 
                            "estado": st.column_config.TextColumn("Estado"), 
                            "ubicacion": st.column_config.TextColumn("Ubicación Bodega"), 
                            "observaciones": st.column_config.TextColumn("Observaciones Técnicas / Reporte de Falla", width="large")
                        }
                        
                        orden_columnas_gala = ['codigo', 'responsiva', 'fecha_compra', 'descripcion', 'marca', 'modelo', 'serie', 'responsable', 'estado', 'ubicacion', 'observaciones']
                        
                        grid_seleccion = st.dataframe(
                            df_danados[orden_columnas_gala].style.apply(semaforo_hardware, axis=1),
                            column_config=config_columnas_clinicas,
                            width='stretch',
                            hide_index=True,
                            selection_mode="single-row", 
                            on_select="rerun",           
                            key="tabla_expediente_reactivo_vpro_maestro"
                        )
                        
                        indice_seleccionado = grid_seleccion.selection.rows
                        
                        if indice_seleccionado:
                            row_idx = indice_seleccionado[0]
                            codigo_seleccionado = df_danados.iloc[row_idx]['codigo']
                            row_hardware = df_danados.iloc[row_idx]
                            
                            st.write("---")
                            st.markdown(f"### 📂 Expediente para darle seguimiento: `{codigo_seleccionado}`")
                            
                            foto_eq_png = os.path.join(FOTOS_EQUIPOS_DIR, f"{codigo_seleccionado}.png")
                            foto_eq_jpg = os.path.join(FOTOS_EQUIPOS_DIR, f"{codigo_seleccionado}.jpg")
                            foto_eq_activa = foto_eq_png if os.path.exists(foto_eq_png) else (foto_eq_jpg if os.path.exists(foto_eq_jpg) else None)
                        
                            c_card, c_foto_preview = st.columns([2, 1])
                        
                            with c_card:
                                with st.container(border=True):
                                    col_f1, col_f2, col_f3 = st.columns(3)
                                    col_f1.markdown(f"**Hardware:**\n{row_hardware['descripcion']}")
                                    col_f2.markdown(f"**Responsable:**\n{row_hardware['responsable'] if row_hardware['responsable'] else 'No asignado'}")
                                    col_f3.markdown(f"**Estatus de Salud:**\n`{str(row_hardware['estado']).upper()}`")
                        
                            with c_foto_preview:
                                if foto_eq_activa:
                                    st.image(foto_eq_activa, caption=f"Foto Real de {codigo_seleccionado}", width='stretch')
                                else:
                                    uploaded_eq_pic = st.file_uploader("🖼️ Subir foto del equipo:", type=["png", "jpg", "jpeg"], key=f"pic_up_{codigo_seleccionado}")
                                    if uploaded_eq_pic is not None:
                                        os.makedirs(FOTOS_EQUIPOS_DIR, exist_ok=True)
                                        with open(foto_eq_png, "wb") as f: f.write(uploaded_eq_pic.getbuffer())
                                        st.success("¡Fotografía amarrada con éxito!"); time.sleep(1); st.rerun()
                        
                            res_hist = requests.get(f"{API_URL}/api/inventario/historial/{codigo_seleccionado}", verify=False)
                            if res_hist.status_code == 200:
                                hist_data = res_hist.json()
                                if hist_data:
                                    df_hist_view = pd.DataFrame(hist_data)
                                    df_hist_view.columns = [str(c).lower().strip() for c in df_hist_view.columns]
                                
                                    st.markdown("##### ⏳ Historial Cronológico de Reparaciones y Eventos (Postgres):")
                                
                                    st.dataframe(
                                        df_hist_view[['fecha', 'tipo_evento', 'folio_vpro', 'descripcion']], 
                                        column_config={
                                            "fecha": st.column_config.DateColumn("📅 Fecha Clínicas", format="DD/MM/YYYY"), 
                                            "tipo_evento": st.column_config.TextColumn("🩺 Diagnóstico / Evento"), 
                                            "folio_vpro": st.column_config.TextColumn("🎬 Evento Origen"), 
                                            "descripcion": st.column_config.TextColumn("📝 Notas Médicas de Reparación", width="large")
                                        },  
                                        width='stretch', 
                                        hide_index=True,
                                        key=f"bitacora_cronologica_medica_{codigo_seleccionado}"
                                    )
                                else:
                                    st.success("🎉 ¡Excelente! No hay reportes de daños previos registrados en la bitácora de esta pieza.")
                        
                            st.write("")
                            with st.expander("🔧 Registrar/Actualizar el status del equipo"):
                                txt_treatment = st.text_area("📝 Diagnóstico y Tratamiento Aplicado:", key="exp_txt_tratamiento_man")
                                txt_op_maint = st.text_input("🎬 Asociar a Folio OP:", value="MANTENIMIENTO_INTERNO", key="exp_txt_op_man")
                                if st.button("💾 ACTUALIZAR EXPEDIENTE", width='stretch', type="primary", key="exp_btn_save_man"):
                                    if not txt_treatment.strip(): st.warning("⚠️ Describe el tratamiento.")
                                    else:
                                        payload_hist = {
                                            "codigo_equipo": str(codigo_seleccionado).strip(), 
                                            "tipo_evento": "REPARACIÓN_TÉCNICA", 
                                            "descripcion": str(txt_treatment).strip(), 
                                            "folio_vpro": str(txt_op_maint).strip(),
                                            "id_empleado": str(st.session_state.get("id_usuario", "000")), 
                                            "estado_final": "RESUELTO",
                                            "departamento": str(st.session_state.get("depto", "OFICINA")).upper()
                                        }
                                        if requests.post(f"{API_URL}/api/inventario/historial/guardar", json=payload_hist, verify=False).status_code == 200: 
                                            st.success("🔒 Tratamiento registrado."); time.sleep(1); st.rerun()
                    else:
                        st.success("🎉 **Búnker en Perfecto Estado:** 100% del hardware operativo se encuentra en verde (Buen Estado).")
                else:
                    st.info("💡 Aún no hay registros en la base de datos de inventario con reportes de daño activos.")
        except Exception as e:
            st.error(f"❌ Error en la suite médica de hardware: {e}")

# 📝 MÓDULO: ÓRDENES DE PRODUCCIÓN
elif "Produccion" in opcion_seleccionada:
    nombre_usuario = st.session_state.usuario_actual; rol = st.session_state.rol
    st.markdown(f"""<div style="background-color: #1e293b; padding: 20px; border-radius: 15px; border-left: 10px solid #deff9a; margin-bottom: 25px;"><h2 style="margin: 0; color: #f8fafc;">👋 ¡Hola, {nombre_usuario}!</h2><p style="margin: 0; color: #deff9a; font-weight: bold;">Panel Operativo Maestro: Orden de Producción VPRO</p></div>""", unsafe_allow_html=True)
    if 'op_data' not in st.session_state: st.session_state.op_data = {}
    d = st.session_state.op_data
    lista_proveedores, lista_autos, lista_clientes = [], [], ["->"]; folios_existentes = ["🆕 CREAR NUEVA ORDEN"]; staff_vpro, apoyos_proveedor = [], []; proximo_id = 1
    try:
        res_cat = requests.get(f"{API_URL}/api/eventos/catalogos", verify=False)
        if res_cat.status_code == 200:
            cats = res_cat.json(); lista_autos = cats["autos"]; lista_clientes += cats["clientes"]; lista_proveedores = cats["proveedores"]; staff_vpro = cats["staff_vpro"]; apoyos_proveedor = cats["apoyos_externos"]
        res_fol = requests.get(f"{API_URL}/api/eventos/folios", verify=False)
        if res_fol.status_code == 200:
            fols_data = res_fol.json(); folios_existentes += fols_data["folios"]; proximo_id = fols_data["proximo_id"]
    except Exception as e: st.error(f"📡 Error crítico: {e}")

    st.write("### 📂 Gestión de Folios")
    with st.container(border=True):
        c_sel, c_empty = st.columns([2, 3])
        sel = c_sel.selectbox("🔍 BUSCAR O SELECCIONAR FOLIO:", options=folios_existentes, index=0)
        folio_extraido = sel.split(" - ")[0] if sel != "🆕 CREAR NUEVA ORDEN" else None
        if folio_extraido and str(d.get('folio')) != str(folio_extraido):
            res_buscar = requests.get(f"{API_URL}/api/eventos/buscar/{folio_extraido}", verify=False)
            if res_buscar.status_code == 200:
                for k in ['evento_nombre', 'loc_lugar', 'quien_sol', 'ubi_exacta', 'n_serv']:
                    if k in st.session_state: del st.session_state[k]
                st.session_state.op_data = res_buscar.json(); st.rerun()
        elif not folio_extraido and d.get('id_evento'): st.session_state.op_data = {}; st.rerun()

    id_actual = d.get('id_evento', proximo_id); val_folio_mostrar = str(d.get('folio')) if d.get('folio') else str(id_actual)
    if 'evento_nombre' not in st.session_state: st.session_state.evento_nombre = d.get('nombre_evento', "")
    if 'loc_lugar' not in st.session_state: st.session_state.loc_lugar = d.get('locacion', "")
    if 'quien_sol' not in st.session_state: st.session_state.quien_sol = d.get('quien_solicita', "")
    if 'ubi_exacta' not in st.session_state: st.session_state.ubi_exacta = d.get('ubicacion', "")
    if 'n_serv' not in st.session_state: st.session_state.n_serv = d.get('tipo_de_servicio', "")

    st.write("### 📝 Datos de la Orden")
    with st.container(border=True):
        c1, c2, c3 = st.columns([1, 2, 4])
        fol_in = c1.text_input("🔢 FOLIO VPRO:", value=val_folio_mostrar, disabled=True)
        cli_op = c2.selectbox("👤 CLIENTE:", options=lista_clientes, index=lista_clientes.index(d.get('para_q_cliente')) if d.get('para_q_cliente') in lista_clientes else 0)
        eve_op = c3.text_input("🎉 EVENTO:", key="evento_nombre")
        c4, c5, c6 = st.columns([2, 1.5, 1.5])
        loc_op = c4.text_input("📍 LOCACIÓN (Lugar):", key="loc_lugar")
        f_inst = c5.date_input("📅 FECHA INSTALACIÓN:", value=datetime.date.fromisoformat(d.get('fec_de_instalacion')) if d.get('fec_de_instalacion') else datetime.date.today())
        h_inst = c6.time_input("⏰ HORA INSTALACIÓN:", value=datetime.time.fromisoformat(d.get('hra_de_instalacion')) if d.get('hra_de_instalacion') else datetime.time(9, 0))
        c7, c8, c9, c10, c11 = st.columns([1.5, 1.5, 1, 1, 1])
        sol_op = c7.text_input("📣 SOLICITA:", key="quien_sol")
        prd_op = c8.selectbox("🎬 PRODUCTOR RESP.:", options=["---"] + staff_vpro, index=(staff_vpro.index(d.get('resp_de_produccion'))+1) if d.get('resp_de_produccion') in staff_vpro else 0)
        f_even = c9.date_input("📅 FECHA EVENTO:", value=datetime.date.fromisoformat(d.get('fec_del_evento')) if d.get('fec_del_evento') else datetime.date.today())
        h_inic = c10.time_input("🚀 H. INICIO:", value=datetime.time.fromisoformat(d.get('inicio_del_evento')) if d.get('inicio_del_evento') else datetime.time(11, 0))
        h_llam = c11.time_input("📞 H. LLAMADO:", value=datetime.time.fromisoformat(d.get('hra_de_llamado')) if d.get('hra_de_llamado') else datetime.time(6, 0))
        ubi_op = st.text_input("🗺️ UBICACIÓN EXACTA:", key="ubi_exacta"); serv_op = st.text_area("🛠️ TIPO DE SERVICIO:", height=65, key='n_serv')

    st.divider(); st.write("### 👥 Asignación de Equipo y Logística")
    with st.container(border=True):
        col_iz, col_de = st.columns(2)
        with col_iz:
            pers_sel = st.multiselect("SELECCIONAR PERSONAL VPRO:", options=staff_vpro, default=[p for p in parsed_array(d.get('personal_convocado_op')) if p in staff_vpro])
            proveed_sel = st.multiselect("SELECCIONAR PERSONAL EXTERNO:", options=apoyos_proveedor, default=[p for p in parsed_array(d.get('externos_op')) if p in apoyos_proveedor])
        with col_de:
            cars = st.multiselect("VEHÍCULOS:", options=lista_autos, default=[c for c in parsed_array(d.get('carros_usados_op')) if c in lista_autos])
            prov = st.multiselect("PROVEEDORES CO-CONVOCADOS:", options=lista_proveedores, default=[p for p in parsed_array(d.get('proveedor_op')) if p in lista_proveedores])
            
        st.write("")
        
    # 🚀 Textos amplios (afuera de las columnas para tomar el 100% del ancho)
    ins_p = st.text_area("📦 PRODUCCIÓN:(LEER las INSTRUCCIONES y SI HAY DUDAS PREGUNTAR a su jefe inmediato)", value=d.get('produccion', ""), height=200)
    ins_s = st.text_area("💻 SISTEMAS / REDES:", value=d.get('internet_redes', ""), height=200)
    ins_v = st.text_area("🏗️ ACTIVIDADES PROVEEDORES:", value=d.get('actividades_de_proveedores', ""), height=200)
    nota = st.text_area("📝 NOTAS ADICIONALES:", value=d.get('nota', ""), height=140)
    
    
    if d.get('id_evento') and (rol in ['ADMIN', 'COORDINADOR'] or es_cuauhtemoc): # ✈️ LOGÍSTICA DE VIAJES (Aparece SOLO UNA VEZ, ANTES de las firmas)
        st.write("---")
        st.markdown("### ✈️ Logística de Viajes Fuera de la Ciudad")
        with st.expander("💼 SI EL EVENTO ES FUERA DE LA CIUDAD ... PRESIONE AQUI"):
            st.info("💡 Al activar este sello, el sistema registrará automáticamente la bitácora de asistencia.")
            c_viaje1, c_viaje2 = st.columns(2)
            
            # 🛡️ LLAVES DINÁMICAS: Le sumamos el id_actual para que sean únicas por OP
            v_inicio = c_viaje1.date_input("📅 Inicio de Comisión:", value=datetime.date.fromisoformat(d.get('fec_de_instalacion')) if d.get('fec_de_instalacion') else datetime.date.today(), key=f"viaje_ini_{id_actual}")
            v_fin = c_viaje2.date_input("🏁 Fin de Comisión:", value=datetime.date.fromisoformat(d.get('fec_del_evento')) if d.get('fec_del_evento') else datetime.date.today(), key=f"viaje_fin_{id_actual}")
            
            st.markdown(f"**personal convocado que recibirá el sello de asistencia:** {', '.join(pers_sel) if pers_sel else '⚠️ Nadie seleccionado aún'}")
            
            if st.button("🚀 SELLAR ASISTENCIA AUTOMÁTICA EN RUTA", type="primary", width='stretch', key=f"btn_sellar_viaje_{id_actual}"): # 🛡️ Llave dinámica también para el botón rojo
                if not pers_sel:
                    st.error("⚠️ No hay personal seleccionado en la lista de arriba para asignarle viáticos/asistencia.")
                else:
                    with st.spinner("Generando marcas de comisión..."):
                        nombre_ev_limpio = d.get('concepto', d.get('nombre_evento', d.get('descripcion', 'PROYECTO RUTA')))
                        texto_estatus_maestro = f"EN EVENTO {val_folio_mostrar}: {nombre_ev_limpio}"
                        p_viaje = {
                            "id_evento": int(id_actual),
                            "folio": str(val_folio_mostrar),
                            "fecha_inicio": str(v_inicio),
                            "fecha_fin": str(v_fin),
                            "personal": list(pers_sel),
                            "estatus_dinamico": texto_estatus_maestro[:65]
                        }
                        res_viaje = requests.post(f"{API_URL}/api/asistencia/sellar-ruta", json=p_viaje, verify=False)
                        if res_viaje.status_code == 200:
                            st.success("🔒 ¡Sello de Comisión aplicado con éxito! El crew tiene asistencia justificada.")
                            time.sleep(1.5)
                            st.rerun()
                        else:
                            st.error(f"❌ Error del motor logístico: {res_viaje.text}")
                            
                            
    # 🎬 NUEVO BLOQUE: CLAQUETA DIGITAL DE LOCACIÓN (EXCLUSIVO PRODUCTOR RESPONSABLE)
    es_productor_asignado = str(d.get('resp_de_produccion', '')).strip().upper() == str(nombre_usuario).strip().upper()
    
    if d.get('id_evento') and es_productor_asignado:
        st.write("---")
        st.markdown("### 🎬 Claqueta de Asistencia en Locación (Control de Productor)")
        with st.container(border=True):
            st.info("💡 **Modo Gira Activo:** Registra las horas reales de inicio y fin de la jornada para todo tu crew convocado el día de hoy.")
            st.markdown(f"**Crew en locación hoy:** `{', '.join(pers_sel) if pers_sel else '⚠️ Nadie seleccionado'}`")
            
            st.write("")
            c_claq1, c_claq2 = st.columns(2)
            
            with c_claq1:
                st.markdown("##### 🟢 Apertura de Llamado")
                hora_llamado_in = st.time_input("Hora Real de Entrada:", value=datetime.time(7, 0), key=f"claq_in_{id_actual}")
                if st.button("🟢 INICIAR LLAMADO DEL CREW", type="primary", width='stretch', key=f"btn_claq_in_{id_actual}"):
                    if not pers_sel:
                        st.error("⚠️ No hay personal convocado.")
                    else:
                        with st.spinner("Abriendo jornada en ruta..."):
                            p_in = {
                                "id_evento": int(id_actual),
                                "folio": str(val_folio_mostrar),
                                "fecha": str(datetime.date.today()),
                                "hora_personalizada": str(hora_llamado_in),
                                "tipo_movimiento": "ENTRADA",
                                "personal": list(pers_sel),
                                "estatus_dinamico": f"Llamado Locación (OP-{val_folio_mostrar}) a las {hora_llamado_in.strftime('%H:%M')}"
                            }
                            res = requests.post(f"{API_URL}/api/asistencia/sellar-ruta-exacta", json=p_in, verify=False)
                            if res.status_code == 200:
                                st.success(f"✅ Jornada abierta con éxito a las {hora_llamado_in.strftime('%H:%M')}")
                                time.sleep(1.5)
                                st.rerun()
                            else: st.error(f"❌ Error: {res.text}")
                            
            with c_claq2:
                st.markdown("##### 🔴 Cierre de Jornada")
                hora_llamado_out = st.time_input("Hora Real de Salida:", value=datetime.time(22, 0), key=f"claq_out_{id_actual}")
                if st.button("🔴 TERMINAR JORNADA DEL CREW", type="secondary", width='stretch', key=f"btn_claq_out_{id_actual}"):
                    if not pers_sel:
                        st.error("⚠️ No hay personal convocado.")
                    else:
                        with st.spinner("Cerrando marcas de la jornada..."):
                            p_out = {
                                "id_evento": int(id_actual),
                                "folio": str(val_folio_mostrar),
                                "fecha": str(datetime.date.today()),
                                "hora_personalizada": str(hora_llamado_out),
                                "tipo_movimiento": "SALIDA",
                                "personal": list(pers_sel),
                                "estatus_dinamico": "Fin de Jornada"
                            }
                            res = requests.post(f"{API_URL}/api/asistencia/sellar-ruta-exacta", json=p_out, verify=False)
                            if res.status_code == 200:
                                st.success(f"🔴 Jornada cerrada con éxito a las {hora_llamado_out.strftime('%H:%M')}")
                                time.sleep(1.5)
                                st.rerun()
                            else: st.error(f"❌ Error: {res.text}")

    st.write("### 🖋️ Autorizaciones") # 🖋️ AUTORIZACIONES
    with st.container(border=True):
        f_a1, f_a2, f_a3, f_a4 = st.columns(4)
        def_elab = d.get('elabora') if d.get('elabora') else "Ana Lilia Villarreal Uribe"; def_coor = d.get('coordina') if d.get('coordina') else "Manuel Eduardo Madrid"; def_organ = d.get('organiza') if d.get('organiza') else "Martin Eduardo Sanchez Estrada"; def_vobo = d.get('vobo') if d.get('vobo') else "Gerardo Villarreal Uribe"
        idx_e = (staff_vpro.index(def_elab) + 1) if def_elab in staff_vpro else 0; idx_c = (staff_vpro.index(def_coor) + 1) if def_coor in staff_vpro else 0; idx_o = (staff_vpro.index(def_organ) + 1) if def_organ in staff_vpro else 0; idx_v = (staff_vpro.index(def_vobo) + 1) if def_vobo in staff_vpro else 0
        elab = f_a1.selectbox("📝 Elaboró:", ["---"] + staff_vpro, index=idx_e); coor = f_a2.selectbox("🔀 Coordina:", ["---"] + staff_vpro, index=idx_c); organ = f_a3.selectbox("🏢 Organiza:", ["---"] + staff_vpro, index=idx_o); vobo = f_a4.selectbox("✅ Vo.Bo.:", ["---"] + staff_vpro, index=idx_v)
    
    st.divider(); creador_original = d.get('empleado_que_creo_la_op', nombre_usuario)
    
    if st.button("💾 GUARDAR CAMBIOS ORDEN", width='stretch', type="primary"): # 💾 BOTÓN GUARDAR (Al fondo del módulo)
        es_autorizado = rol in ['ADMIN', 'COORDINADOR']
        es_el_dueno = (creador_original == nombre_usuario)
        if not es_autorizado and not es_el_dueno: st.error(f"🚫 Acceso Denegado. Solo un Coordinador o el creador ({creador_original}) pueden modificar esta OP.")
        else:
            nombre_ev_limpio = st.session_state.evento_nombre if 'evento_nombre' in st.session_state else d.get('nombre_evento', 'PROYECTO RUTA')
            payload_op = {"id_evento": int(id_actual),
                          "folio": str(val_folio_mostrar).strip(),
                          "para_q_cliente": str(cli_op),
                          "nombre_evento": str(nombre_ev_limpio).strip(),
                          "locacion": str(st.session_state.loc_lugar).strip(),
                          "fec_de_instalacion": str(f_inst),
                          "hra_de_instalacion": str(h_inst),
                          "quien_solicita": str(st.session_state.quien_sol).strip(),
                          "resp_de_produccion": str(prd_op),
                          "fec_del_evento": str(f_even),
                          "inicio_del_evento": str(h_inic),
                          "hra_de_llamado": str(h_llam),
                          "ubicacion": str(st.session_state.ubi_exacta).strip(),
                          "tipo_de_servicio": str(st.session_state.n_serv).strip(),
                          "produccion": str(ins_p).strip(),
                          "internet_redes": str(ins_s).strip(),
                          "actividades_de_proveedores": str(ins_v).strip(),
                          "nota": str(nota).strip(), "elabora": str(elab), 
                          "organiza": str(organ), "coordina": str(coor), 
                          "vobo": str(vobo), "proveedor_op": list(prov),
                          "personal_convocado_op": list(pers_sel), 
                          "carros_usados_op": list(cars), 
                          "externos_op": list(proveed_sel),
                          "empleado_que_creo_la_op": str(creador_original)}
            
            with st.spinner("Sincronizando orden..."):
                try:
                    response = requests.post(f"{API_URL}/api/eventos/guardar", json=payload_op, verify=False)
                    if response.status_code == 200:
                        if 'op_data' in st.session_state: del st.session_state['op_data']
                        st.toast("✅ ¡Orden de Producción guardada con éxito!", icon="💾")
                        time.sleep(1.2)
                        st.rerun()
                    else:
                        try: error_detail = response.json().get('detail', response.text)
                        except: error_detail = response.text
                        st.error(f"❌ Error al guardar (Código {response.status_code}):\n\n`{error_detail}`")
                except Exception as e:
                    st.error(f"📡 Fallo de comunicación con el Cerebro API: {e}")

# 🚙 MÓDULO: AUTOMÓVILES
elif "Autos" in opcion_seleccionada:
    st.subheader("🚗 ABC - Control Vehicular y Flota VPRO")
    puede_editar = (st.session_state.rol == "ADMIN")
    try:
        res_autos = requests.get(f"{API_URL}/api/autos", verify=False)
        if res_autos.status_code == 200:
            df_original = pd.DataFrame(res_autos.json())
            for col in ['fecha_compra', 'seguro_vence', 'mantenimiento_fecha']: df_original[col] = pd.to_datetime(df_original[col], errors='coerce').dt.date
            config_columnas_autos = {"num_control": st.column_config.TextColumn("Nº Control / ID", required=True), "marca": st.column_config.TextColumn("Marca", required=True), "modelo": st.column_config.TextColumn("Modelo", required=True), "serie": st.column_config.TextColumn("Número de Serie"), "fecha_compra": st.column_config.DateColumn("Fecha Compra", format="DD/MM/YYYY"), "estado_actual": st.column_config.TextColumn("Estado Físico"), "servicios_hechos": st.column_config.TextColumn("Historial Servicios"), "observaciones_comentarios": st.column_config.TextColumn("Observaciones"), "seguro_vence": st.column_config.DateColumn("Vence Seguro 🛡️", format="DD/MM/YYYY"), "mantenimiento_fecha": st.column_config.DateColumn("Próximo Mantenimiento 🔧", format="DD/MM/YYYY")}
            def semaforo_flota(row):
                hoy = datetime.date.today()
                if pd.notna(row['seguro_vence']):
                    dias = (row['seguro_vence'] - hoy).days
                    if dias < 0: return ['background-color: #5c191e; color: #ffb3b7; font-weight: 500'] * len(row)
                    elif dias <= 30: return ['background-color: #61460b; color: #ffe69c; font-weight: 500'] * len(row)
                if pd.notna(row['mantenimiento_fecha']) and (row['mantenimiento_fecha'] - hoy).days < 0: return ['background-color: #4a123a; color: #ffbdf0; font-weight: 500'] * len(row)
                return [''] * len(row)
            
            edited_df = st.data_editor(df_original.style.apply(semaforo_flota, axis=1), column_config=config_columnas_autos, num_rows="dynamic" if puede_editar else "fixed", width='stretch', hide_index=True, disabled=not puede_editar)
            if puede_editar:
                st.divider()
                if st.button("💾 GUARDAR CAMBIOS EN FLOTA", type="primary", width='stretch'):
                    ids_antes = set(df_original['num_control'].dropna().tolist())
                    ids_ahora = set(edited_df['num_control'].dropna().tolist())
                    for id_borrar in (ids_antes - ids_ahora): requests.delete(f"{API_URL}/api/autos/eliminar/{id_borrar}", verify=False)
                    for _, r in edited_df.iterrows():
                        if pd.isna(r['num_control']) or str(r['num_control']).strip() == "": continue
                        payload_auto = {"num_control": str(r['num_control']).strip(), "marca": str(r['marca']).strip(), "modelo": str(r['modelo']).strip(), "serie": str(r['serie']).strip() if pd.notna(r['serie']) else "", "fecha_compra": str(r['fecha_compra']) if pd.notna(r['fecha_compra']) else None, "estado_actual": str(r['estado_actual']).strip(), "servicios_hechos": str(r['servicios_hechos']).strip(), "observaciones_comentarios": str(r['observaciones_comentarios']).strip(), "seguro_vence": str(r['seguro_vence']) if pd.notna(r['seguro_vence']) else None, "mantenimiento_fecha": str(r['mantenimiento_fecha']) if pd.notna(r['mantenimiento_fecha']) else None}
                        requests.post(f"{API_URL}/api/autos/guardar", json=payload_auto, verify=False)
                    st.success("✅ Flota vehicular sincronizada de forma exitosa."); time.sleep(1); st.rerun()
    except Exception as e: st.error(f"❌ Error automotriz: {e}")

# 🦺 MÓDULO: EMPLEADOS
elif "Empleados" in opcion_seleccionada:
    st.subheader("👥 ABC - Directorio y Control de Personal VPRO")
    es_admin = (st.session_state.rol == "ADMIN")
    
    if 'confirmacion_baja_pendiente' not in st.session_state:
        st.session_state.confirmacion_baja_pendiente = False

    try:
        res_emp = requests.get(f"{API_URL}/api/empleados", verify=False)
        if res_emp.status_code == 200:
            df_master = pd.DataFrame(res_emp.json())
            for col in ['licencia_vence', 'fecha_nac', 'fecha_ing']: 
                df_master[col] = pd.to_datetime(df_master[col], errors='coerce').dt.date
                
            config_columnas_normal = {
                "id_empleado": st.column_config.TextColumn("ID", required=True),
                "nombre": st.column_config.TextColumn("Nombre Completo", required=True),
                "depto": st.column_config.SelectboxColumn(
                    "Departamento", 
                    options=["ADMINISTRACION", "EDICION", "PRODUCCION", "SISTEMAS", "VENTAS"], 
                    required=True
                ),
                "rol": st.column_config.SelectboxColumn(
                    "Rol / Estatus", 
                    options=["ADMIN", "PRODUCTOR", "COORDINADOR", "PRODUCCION", "PROVEEDOR", "BAJA"], 
                    required=True
                ),
                "licencia_vence": st.column_config.DateColumn("Vence Licencia 🪪", format="DD/MM/YYYY"),
                "fecha_nac": st.column_config.DateColumn("Cumleaños 🎂", format="DD/MM/YYYY"),
                "fecha_ing": st.column_config.DateColumn("Fecha Ingreso 💼", format="DD/MM/YYYY"),
                "email": st.column_config.TextColumn("Contacto")
            }
            
            if es_admin: config_columnas_normal["password"] = st.column_config.TextColumn("🔑 Password", required=True)
                
            config_columnas_bajas = config_columnas_normal.copy()
            config_columnas_bajas["fecha_nac"] = st.column_config.DateColumn("📅 Fecha de Salida", format="DD/MM/YYYY")
            
            def semaforo_licencia(row):
                if pd.isna(row['licencia_vence']): return [''] * len(row)
                dias = (row['licencia_vence'] - datetime.date.today()).days
                if dias < 0: return ['background-color: #5c191e; color: #ffb3b7; font-weight: 500'] * len(row)
                if dias <= 30: return ['background-color: #61460b; color: #ffe69c; font-weight: 500'] * len(row)
                return [''] * len(row)
            
            tab_activos, tab_bajas = st.tabs(["👥 Personal Activo", "🚫 Historial de Bajas"])
            
            df_activos_limpio = df_master[df_master['rol'].str.strip().str.upper() != "BAJA"].reset_index(drop=True)
            with tab_activos: 
                edited_df = st.data_editor(df_activos_limpio.style.apply(semaforo_licencia, axis=1),
                                            column_config=config_columnas_normal,
                                            num_rows="dynamic" if es_admin else "fixed",
                                            width='stretch',
                                            hide_index=True,
                                            disabled=not es_admin,
                                            key="editor_personal_activo"
                                        )
                
            df_bajas_limpio = df_master[df_master['rol'].str.strip().str.upper() == "BAJA"].reset_index(drop=True)
            with tab_bajas: 
                st.data_editor(df_bajas_limpio,
                    column_config=config_columnas_bajas,
                    num_rows="fixed",
                    width='stretch',
                    hide_index=True,
                    disabled=True,
                    key="editor_personal_bajas"
                )
                
            if es_admin:
                if st.session_state.confirmacion_baja_pendiente:
                    with st.container(border=True):
                        st.markdown("<h4 style='color: #ffb3b7;'>⚠️ CONTROL DE SEGURIDAD</h4>", unsafe_allow_html=True)
                        
                        nombres_bajas = ", ".join(st.session_state.get('nombres_bajas_temporales', []))
                        st.warning(f"¿Confirmas la baja definitiva del sistema para: **{nombres_bajas}**?")
                        
                        btn_c1, btn_c2 = st.columns(2)
                        if btn_c1.button("🔥 CONFIRMAR BAJA", type="primary", width='stretch'):
                            for payload in st.session_state.payload_temporal: 
                                requests.post(f"{API_URL}/api/empleados/guardar", json=payload, verify=False)
                            st.session_state.confirmacion_baja_pendiente = False
                            st.success("🔒 Sello aplicado.")
                            time.sleep(1)
                            st.rerun()
                            
                        if btn_c2.button("❌ CANCELAR", width='stretch'): 
                            st.session_state.confirmacion_baja_pendiente = False
                            st.rerun()
                            
                elif st.button("💾 GUARDAR CAMBIOS DE PERSONAL", type="primary", width='stretch'):
                    ids_antes = set(df_master[df_master['rol'].str.strip().str.upper() != "BAJA"]['id_empleado'].dropna().astype(str).tolist())
                    ids_ahora = set(edited_df['id_empleado'].dropna().astype(str).tolist())
                    
                    for id_borrar in (ids_antes - ids_ahora): 
                        requests.delete(f"{API_URL}/api/empleados/eliminar/{id_borrar}", verify=False)
                        
                    payload_lista = []
                    bajas_detectadas = []
                    
                    for _, r_row in edited_df.iterrows():
                        if pd.isna(r_row['id_empleado']) or str(r_row['id_empleado']).strip() == "": 
                            continue
                        rol_nuevo = str(r_row['rol']).strip().upper()
                        fecha_nac_final = str(datetime.date.today()) if rol_nuevo == "BAJA" else str(r_row['fecha_nac'])
                        
                        if rol_nuevo == "BAJA": 
                            bajas_detectadas.append(str(r_row['nombre']))
                            
                        payload_lista.append({"id_empleado": str(r_row['id_empleado']).strip(), 
                                                "nombre": str(r_row['nombre']).strip(), 
                                                "depto": str(r_row['depto']).strip(), 
                                                "rol": rol_nuevo, 
                                                "licencia_vence": str(r_row['licencia_vence']) if pd.notna(r_row['licencia_vence']) else None, 
                                                "email": str(r_row['email']).strip(), 
                                                "password": str(r_row['password']).strip() if 'password' in r_row and pd.notna(r_row['password']) else "vpro123", 
                                                "fecha_nac": fecha_nac_final, 
                                                "fecha_ing": str(r_row['fecha_ing']) if pd.notna(r_row['fecha_ing']) else str(datetime.date.today())
                                            })
                        
                    if bajas_detectadas: 
                        st.session_state.confirmacion_baja_pendiente = True
                        st.session_state.payload_temporal = payload_lista
                        st.session_state.nombres_bajas_temporales = bajas_detectadas
                        st.rerun()
                    else:
                        for p in payload_lista: 
                            requests.post(f"{API_URL}/api/empleados/guardar", json=p, verify=False)
                        st.success("🔒 Personal synchronized.")
                        time.sleep(1)
                        st.rerun()
                        
    except Exception as e: 
        st.error(f"❌ Error personal: {e}")

# 🚚 MÓDULO: PROVEEDORES (CON CANDADO ANTI-BORRADO)
elif "Proveedores" in opcion_seleccionada:
    st.subheader("🚚 ABC - Catálogo Maestro de Proveedores")
    puede_editar = (st.session_state.rol == "ADMIN")
    
    # 🔒 Inicializadores de seguridad temporal para Proveedores
    if "prov_borrados_pendientes" not in st.session_state: st.session_state.prov_borrados_pendientes = []
    if "prov_tabla_temporal" not in st.session_state: st.session_state.prov_tabla_temporal = None

    try:
        res_prov = requests.get(f"{API_URL}/api/proveedores", verify=False)
        if res_prov.status_code == 200:
            df_prov = pd.DataFrame(res_prov.json())
            config_columnas_prov = {
                "nombre_del_proveedor": st.column_config.TextColumn("Proveedor (ID Único)", required=True),
                "gte_gral": st.column_config.TextColumn("Gerente General"),
                "estado": st.column_config.TextColumn("Estado"),
                "ciudad": st.column_config.TextColumn("Ciudad"),
                "tel_de_ofna": st.column_config.TextColumn("Tel. Oficina"),
                "email_de_empresa": st.column_config.TextColumn("Email de Empresa"),
                "nombre_contacto_princ": st.column_config.TextColumn("Contacto Principal"),
                "cel_contact_princ": st.column_config.TextColumn("Celular Principal"),
                "nombre_contacto_a": st.column_config.TextColumn("Contacto Alterno"),
                "cel_contact_a": st.column_config.TextColumn("Celular Alterno")
            }
            
            df_editado = st.data_editor(df_prov.reset_index(drop=True), column_config=config_columnas_prov, num_rows="dynamic" if puede_editar else "fixed", hide_index=True, width='stretch', key="grid_maestro_proveedores")
            
            if puede_editar:
                st.write("")
                
                # 🛑 ADUANA DE CONFIRMACIÓN VISUAL
                if st.session_state.prov_borrados_pendientes:
                    with st.container(border=True):
                        st.markdown("<h4 style='color: #ffb3b7;'>⚠️ CONTROL DE SEGURIDAD CRÍTICO</h4>", unsafe_allow_html=True)
                        st.warning(f"¿Confirmas la eliminación permanente en Postgres de los Proveedores: {st.session_state.prov_borrados_pendientes}?")
                        
                        btn_p1, btn_p2 = st.columns(2)
                        if btn_p1.button("🔥 SÍ, ELIMINAR PROVEEDORES", type="primary", width='stretch', key="btn_execute_delete_prov"):
                            # 1. Borrar de la base de datos
                            for name_del in st.session_state.prov_borrados_pendientes:
                                requests.delete(f"{API_URL}/api/proveedores/eliminar/{name_del}", verify=False)
                            
                            # 2. Guardar el resto
                            exito_operacion = True
                            for _, row in st.session_state.prov_tabla_temporal.iterrows():
                                if pd.isna(row['nombre_del_proveedor']) or str(row['nombre_del_proveedor']).strip() == "": continue
                                payload_prov = {"nombre_del_proveedor": str(row['nombre_del_proveedor']).strip().upper(), "gte_gral": str(row['gte_gral']).strip(), "estado": str(row['estado']).strip(), "ciudad": str(row['ciudad']).strip(), "tel_de_ofna": str(row['tel_de_ofna']).strip(), "email_de_empresa": str(row['email_de_empresa']).strip(), "nombre_contacto_princ": str(row['nombre_contacto_princ']).strip(), "cel_contact_princ": str(row['cel_contact_princ']).strip(), "nombre_contacto_a": str(row['nombre_contacto_a']).strip(), "cel_contact_a": str(row['cel_contact_a']).strip()}
                                if requests.post(f"{API_URL}/api/proveedores/guardar", json=payload_prov, verify=False).status_code != 200: exito_operacion = False
                            
                            st.session_state.prov_borrados_pendientes = []
                            st.session_state.prov_tabla_temporal = None
                            if exito_operacion: st.success("✅ Base de proveedores sincronizada."); time.sleep(1); st.rerun()
                            
                        if btn_p2.button("❌ CANCELAR OPERACIÓN", width='stretch', key="btn_cancel_delete_prov"):
                            st.session_state.prov_borrados_pendientes = []
                            st.session_state.prov_tabla_temporal = None
                            st.rerun()
                
                # BOTÓN MAESTRO DISPARADOR
                elif st.button("💾 GUARDAR CAMBIOS PROVEEDORES", type="primary", width='stretch'):
                    nombres_antes = set(df_prov['nombre_del_proveedor'].dropna().tolist())
                    nombres_ahora = set(df_editado['nombre_del_proveedor'].dropna().tolist())
                    borrados_solicitados = list(nombres_antes - nombres_ahora)
                    
                    if borrados_solicitados:
                        st.session_state.prov_borrados_pendientes = borrados_solicitados
                        st.session_state.prov_tabla_temporal = df_editado
                        st.rerun()
                    else:
                        exito_operacion = True
                        for _, row in df_editado.iterrows():
                            if pd.isna(row['nombre_del_proveedor']) or str(row['nombre_del_proveedor']).strip() == "": continue
                            payload_prov = {"nombre_del_proveedor": str(row['nombre_del_proveedor']).strip().upper(), "gte_gral": str(row['gte_gral']).strip(), "estado": str(row['estado']).strip(), "ciudad": str(row['ciudad']).strip(), "tel_de_ofna": str(row['tel_de_ofna']).strip(), "email_de_empresa": str(row['email_de_empresa']).strip(), "nombre_contacto_princ": str(row['nombre_contacto_princ']).strip(), "cel_contact_princ": str(row['cel_contact_princ']).strip(), "nombre_contacto_a": str(row['nombre_contacto_a']).strip(), "cel_contact_a": str(row['cel_contact_a']).strip()}
                            if requests.post(f"{API_URL}/api/proveedores/guardar", json=payload_prov, verify=False).status_code != 200: exito_operacion = False
                        if exito_operacion: st.success("✅ Base de proveedores sincronizada."); time.sleep(1); st.rerun()
    except Exception as e: st.error(f"❌ Error proveedores: {e}")

# 📦 MÓDULO: CHECKOUT
elif "Checkout" in opcion_seleccionada:                 # 📦 MÓDULO: CHECKOUT
    rol_actual = st.session_state.rol
    id_est = st.session_state.get("id_usuario", "001")
    depto_logueado = st.session_state.depto
    operador = st.session_state.usuario_actual
    incidencias_limpias_mostrar = ""
    proveedor_con_incidente_guardado = "--- Ninguno ---"
    detalle_incidente_prov_guardado = ""
    
    if 'modo_actual' not in st.session_state: st.session_state.modo_actual = None
    if 'id_est_temp' not in st.session_state: st.session_state.id_est_temp = id_est
    if 'df_checkout' not in st.session_state: st.session_state.df_checkout = pd.DataFrame(columns=['ID', 'EQUIPO', 'CANT', 'OBSERVACIONES'])
    
    st.subheader(f"📦 {depto_logueado}: Control de Carga y Retorno de Hardware")
    ordenes, lista_kits, alertas_pendientes = [], ["--- Sin plantilla ---"], []
    name_to_id = {}
    proveedores_asignados_op = [] # 🚀 SEGURIDAD: Inicializada en la raíz para que Pylance no reclame
    
    try:
        res_init = requests.get(f"{API_URL}/api/checkout/init-data/{id_est}", verify=False)
        if res_init.status_code == 200:
            pack = res_init.json()
            ordenes = pack["ordenes"]
            lista_kits += pack["kits"]
            alertas_pendientes = pack["alertas_pendientes"]
            
            res_emp_map = requests.get(f"{API_URL}/api/empleados", verify=False)
            if res_emp_map.status_code == 200:
                emp_df = pd.DataFrame(res_emp_map.json())
                name_to_id = dict(zip(emp_df['nombre'].str.strip().str.upper(), emp_df['id_empleado'].str.strip()))
    except Exception as e: 
        st.error(f"📡 Error de conexión inicial con la API: {e}")

    opciones_selectbox = ["---"] + ordenes
    op_en_memoria = st.session_state.get("op_activa_checkout", "---")
    idx_default_op = 0
    
    if op_en_memoria in opciones_selectbox:
        idx_default_op = opciones_selectbox.index(op_en_memoria)
    elif op_en_memoria != "---":
        for i, f_op in enumerate(opciones_selectbox):
            if str(op_en_memoria).split(" | ")[0] in f_op:
                idx_default_op = i
                break

    op_seleccionada = st.selectbox(
        "1️⃣ Seleccione Orden de Producción Destino:", 
        options=opciones_selectbox, 
        index=idx_default_op,
        key="selector_visual_op_checkout" 
    )
    
    if op_seleccionada != st.session_state.get("op_activa_checkout"):
        st.session_state.op_activa_checkout = op_seleccionada
        st.session_state.modo_actual = None
        if "sb_kits_master_final" in st.session_state:
            del st.session_state["sb_kits_master_final"]
        st.rerun()
    
    if op_seleccionada != "---":
        id_op_ref = int(op_seleccionada.split("|")[0].replace("OP-", "").strip())
        convocados_lista = []
        api_comms_ok = False
        
        es_coordinador = (str(rol_actual).upper() == 'COORDINADOR')
        
        def desglosar_array_postgres(val):
            if not val: return []
            if isinstance(val, list): return [str(item).strip() for item in val if item]
            if isinstance(val, str):
                s = val.strip()
                if s.startswith("{") and s.endswith("}"):
                    s = s[1:-1]
                    import csv
                    try: return [x.strip() for x in next(csv.reader([s])) if x]
                    except: return [x.strip().strip('"').strip() for x in s.split(",") if x]
                return [x.strip().strip('"').strip() for x in s.split(",") if x]
            return []

        try:
            res_light = requests.get(f"{API_URL}/api/checkout/status/{id_op_ref}/{id_est}", verify=False)
            if res_light.status_code == 200:
                status_pack = res_light.json()
                id_maestro_db = status_pack.get("id_maestro")
                incidencias_generales_db = status_pack.get("incidencias_generales") or ""
                estado_bodega = status_pack.get("estado_bodega", "NUEVO")
                detalle_items = status_pack.get("detalle", [])
                
                # 🚀 ASIGNACIÓN REAL DESDE EL PAQUETE DE LA API
                proveedores_raw = status_pack.get("proveedores_op", [])
                proveedores_asignados_op = desglosar_array_postgres(proveedores_raw)
                
                if "[PROVEEDOR_INCIDENTE:" in incidencias_limpias_mostrar:
                    start_idx = incidencias_limpias_mostrar.find("[PROVEEDOR_INCIDENTE:")
                    end_idx = incidencias_limpias_mostrar.find("]", start_idx)
                    if end_idx != -1:
                        raw_tag = incidencias_limpias_mostrar[start_idx + 21:end_idx].strip()
                        if " | NOTA: " in raw_tag:
                            p_name, p_note = raw_tag.split(" | NOTA: ", 1)
                            proveedor_con_incidente_guardado = p_name.strip().upper()
                            detalle_incidente_prov_guardado = p_note.strip()
                        else:
                            proveedor_con_incidente_guardado = raw_tag.upper()
                        incidencias_limpias_mostrar = incidencias_limpias_mostrar[:start_idx].strip()
                
                convocados_raw = status_pack.get("convocados", [])
                convocados_lista = desglosar_array_postgres(convocados_raw)
                if convocados_lista: api_comms_ok = True
        except Exception:
            api_comms_ok = False

        if not api_comms_ok or not convocados_lista:
            try:
                res_crew = requests.get(f"{API_URL}/api/gastos/evento/{id_op_ref}", verify=False)
                if res_crew.status_code == 200:
                    ev_data_crew = res_crew.json()
                    row_dict = ev_data_crew[0] if isinstance(ev_data_crew, list) and len(ev_data_crew) > 0 else (ev_data_crew if isinstance(ev_data_crew, dict) else {})
                    columna_real = row_dict.get("personal_convocado_op") or row_dict.get("personalconvocadoop") or row_dict.get("personal")
                    if not columna_real:
                        for k, v in row_dict.items():
                            if "personal" in k.lower() or "convocad" in k.lower():
                                columna_real = v; break
                    convocados_lista = desglosar_array_postgres(columna_real)
            except Exception:
                pass

        convocados_lista = sorted(list(set([str(x).strip() for x in convocados_lista if x])))
        
        if not es_coordinador and operador.strip() not in convocados_lista: 
            st.error(f"🚫 Acceso Denegado a {operador}. No estás convocado a esta OP.")
            st.stop()
        
        id_sujeto_a_revisar = id_est
        if es_coordinador:
            st.write("---")
            st.info("🕵️ Modo Coordinación Activo.")
            opciones_empleados = [c for c in convocados_lista if str(c).strip().upper() in name_to_id]
            if not opciones_empleados: opciones_empleados = convocados_lista
            
            if not opciones_empleados:
                st.error("⚠️ No se encontraron personas convocadas registradas en esta OP.")
            else:
                empleado_revisar_sel = st.selectbox("👤 Personal Convocado a Revisar:", options=opciones_empleados, key="coordinador_emp_select_unificado_final")
                id_sujeto_a_revisar = name_to_id.get(str(empleado_revisar_sel).strip().upper(), id_est)
                if st.session_state.get('id_est_temp') != id_sujeto_a_revisar:
                    st.session_state.modo_actual = None
                    st.session_state.id_est_temp = id_sujeto_a_revisar
                    st.rerun()

        try:
            res_kits = requests.get(f"{API_URL}/api/checkout/kits/{id_sujeto_a_revisar}", verify=False)
            if res_kits.status_code == 200: lista_kits = ["--- Sin plantilla ---"] + res_kits.json().get("kits", [])
        except: pass

        mapa_kits_nombres = {}
        try:
            res_kits_n = requests.get(f"{API_URL}/api/inventario-kits/completo", verify=False)
            if res_kits_n.status_code == 200:
                for k_item in res_kits_n.json():
                    c_id = str(k_item.get('codigo', k_item.get('codigo_inv_kits', ''))).strip().upper()
                    c_desc = str(k_item.get('descripcion', k_item.get('equipo', ''))).strip()
                    if c_id and c_desc:
                        mapa_kits_nombres[c_id] = c_desc
        except: pass

        id_maestro_db, incidencia_general_db, estado_bodega, detalle_items = None, "", "NUEVO", []
        try:
            res_status = requests.get(f"{API_URL}/api/checkout/status/{id_op_ref}/{id_sujeto_a_revisar}", verify=False)
            if res_status.status_code == 200:
                status_pack = res_status.json()
                id_maestro_db = status_pack.get("id_maestro")
                
                # Limpiamos las generales
                incidencias_generales_db = status_pack.get("incidencias_generales") or ""
                if str(incidencias_generales_db).strip() in ["None", "nan", "null"]: incidencias_generales_db = ""
                
                incidencias_limpias_mostrar = incidencias_generales_db
                estado_bodega = status_pack.get("estado_bodega", "NUEVO")
                detalle_items = status_pack.get("detalle", [])
                
                if detalle_items:
                    for item in detalle_items:
                        # 🛡️ 1. SANITIZACIÓN ABSOLUTA: Matamos el 'None' en Observaciones de Salida
                        obs_raw = item.get('OBSERVACIONES', item.get('observaciones', item.get('notas', item.get('obs_salida', ''))))
                        if obs_raw is None or str(obs_raw).strip() in ["None", "nan", "null"]:
                            clean_obs = ""
                        else:
                            clean_obs = str(obs_raw).strip()
                            
                        # Limpiar nombre del equipo y ID de falsos nulos
                        cod_val = str(item.get('ID', item.get('codigo', item.get('codigo_equipo', '')))).strip().upper()
                        if cod_val in ["NONE", "NAN", "NULL"]: cod_val = ""
                        item['ID'] = cod_val  # 🚀 FORZAMOS A QUE QUEDE EN BLANCO Y NO DIGA "None"
                        
                        eq_val = str(item.get('Equipo', item.get('EQUIPO', item.get('descripcion', item.get('equipo', ''))))).strip().upper()
                        if eq_val in ["NONE", "NAN", "NULL"]: eq_val = ""
                        
                        # 🚀 SOLO BUSCA EN EL DICCIONARIO SI EL CÓDIGO NO ESTÁ VACÍO
                        if cod_val and cod_val in mapa_kits_nombres and (not eq_val or eq_val == "EQUIPO NO REGISTRADO"):
                            item['Equipo'] = mapa_kits_nombres[cod_val]
                            item['EQUIPO'] = mapa_kits_nombres[cod_val]
                            item['descripcion'] = mapa_kits_nombres[cod_val]
                            eq_val = item['EQUIPO'].upper()

                        if not eq_val or eq_val == "EQUIPO NO REGISTRADO":
                            if "[CUST_EQ:" in clean_obs:
                                start_idx = clean_obs.find("[CUST_EQ:") + 9
                                end_idx = clean_obs.find("]", start_idx)
                                if end_idx != -1:
                                    extracted_name = clean_obs[start_idx:end_idx].strip()
                                    item['Equipo'] = extracted_name
                                    item['EQUIPO'] = extracted_name
                                    item['descripcion'] = extracted_name
                                    
                                    clean_obs = clean_obs[:clean_obs.find("[CUST_EQ:")].strip() + " " + clean_obs[end_idx+1:].strip()
                                    clean_obs = clean_obs.strip()
                        
                        # Guardamos las versiones purgadas
                        item['OBSERVACIONES'] = clean_obs
                        item['observaciones'] = clean_obs
                        item['notas'] = clean_obs
                        item['obs_salida'] = clean_obs
                        
                        # 🛡️ 2. SANITIZACIÓN ABSOLUTA: Matamos el 'None' en Observaciones de Regreso
                        inc_raw = item.get('Incidencia', item.get('OBS_REGRESO', item.get('notas_regreso', '')))
                        if inc_raw is None or str(inc_raw).strip() in ["None", "nan", "null"]:
                            item['Incidencia'] = ""
                            item['OBS_REGRESO'] = ""
                            item['notas_regreso'] = ""
                        else:
                            item['Incidencia'] = str(inc_raw)
                            item['OBS_REGRESO'] = str(inc_raw)
                            item['notas_regreso'] = str(inc_raw)
        except: pass

        cache_key = f"chk_{id_op_ref}_{id_sujeto_a_revisar}"
        if st.session_state.get("last_checkout_cache") != cache_key:
            if id_maestro_db and detalle_items:
                df_temp_check = pd.DataFrame(detalle_items)
                for c_item in df_temp_check.to_dict(orient="records"):
                    c_item['ID'] = c_item.get('ID', c_item.get('codigo', ''))
                    c_item['EQUIPO'] = c_item.get('EQUIPO', c_item.get('Equipo', c_item.get('descripcion', '')))
                    c_item['CANT'] = c_item.get('CANT', c_item.get('cantidad', c_item.get('CANT_SALIDA', 1)))
                    c_item['OBSERVACIONES'] = c_item.get('OBSERVACIONES', c_item.get('observaciones', ''))
                
                df_temp_check = pd.DataFrame(detalle_items)
                for c in ['ID', 'EQUIPO', 'CANT', 'OBSERVACIONES']:
                    if c not in df_temp_check.columns: df_temp_check[c] = ""
                st.session_state.df_checkout = df_temp_check[['ID', 'EQUIPO', 'CANT', 'OBSERVACIONES']]
                st.session_state.last_tpl_loaded = status_pack.get("nombre_kit") or "--- Sin plantilla ---"
            else:
                st.session_state.df_checkout = pd.DataFrame(columns=['ID', 'EQUIPO', 'CANT', 'OBSERVACIONES'])
                st.session_state.last_tpl_loaded = "--- Sin plantilla ---"
            st.session_state.id_maestro_temp = id_maestro_db
            st.session_state.last_checkout_cache = cache_key

        if st.session_state.modo_actual not in ["MODIFICAR", "VERIFICAR_SALIDA", "CHECKIN"]:
            if id_maestro_db: st.session_state.modo_actual = "VISTA_PREVIA"
            else: st.session_state.modo_actual = "NUEVO"

        # --- ESCENARIO A: PANEL DE VISTA PREVIA OPERATIVA ---
        if st.session_state.modo_actual == "VISTA_PREVIA" and id_maestro_db:
            st.info(f"📋 Estatus de Bodega: `{estado_bodega}` | 🧰 Plantilla Base: `{st.session_state.get('last_tpl_loaded', '--- Sin plantilla ---')}`")
            c1, c2, c3 = st.columns(3)
            if c1.button("✏️ MODIFICAR EL CHECKOUT", width='stretch'): 
                st.session_state.modo_actual = "MODIFICAR"; st.rerun()
            if estado_bodega != 'DESPACHADO':
                if c2.button("📤 REVISAR EL CHECKOUT AL CARGAR", width='stretch', type="primary"):
                    st.session_state.modo_actual = "VERIFICAR_SALIDA"; st.rerun()
            else:
                c2.button("📦 CARGAMENTO DESPACHADO", disabled=True, width='stretch')
            if c3.button("📥 CHECK-IN", width='stretch'): 
                st.session_state.modo_actual = "CHECKIN"; st.rerun()

        # --- ESCENARIO B: VERIFICAR SALIDA (COORDINACIÓN) ---
        elif st.session_state.modo_actual == "VERIFICAR_SALIDA" and id_maestro_db:
            st.subheader(f"📤 Pase de Lista de Salida: Verificación de Carga")
            st.info(f"🧰 Plantilla Base: `{st.session_state.get('last_tpl_loaded', '--- Sin plantilla ---')}`")
            
            rows_salida_construidas = []
            for item in detalle_items:
                rows_salida_construidas.append({
                    "id_detalle": item.get("id_detalle", ""),
                    "ID": item.get("ID", item.get("codigo", item.get("codigo_equipo", ""))),
                    "EQUIPO": item.get("EQUIPO", item.get("Equipo", item.get("descripcion", "Equipo no registrado"))),
                    "CANT": item.get("CANT", item.get("cantidad", item.get("Salió", 1))),
                    "OBSERVACIONES": item.get("OBSERVACIONES", item.get("observaciones", item.get("notas", "")))
                })
            
            df_final_salida = st.data_editor(
                pd.DataFrame(rows_salida_construidas), 
                column_config={"id_detalle": None, "ID": st.column_config.TextColumn("ID", disabled=True), "EQUIPO": st.column_config.TextColumn("Equipo", disabled=True), "CANT": st.column_config.NumberColumn("Cantidad Real", min_value=0), "OBSERVACIONES": st.column_config.TextColumn("Notas")}, 
                hide_index=True, width='stretch'
            )
            
            txt_incidencias_gen_salida = st.text_area("📝 NOTAS GENERALES DE SALIDA:", value=incidencia_general_db, height=100)
            col_c1, col_c2 = st.columns([3, 1])
            if col_c1.button("🔒 AUTORIZAR SALIDA DE BODEGA", type="primary", width='stretch'):
                items_api_salida = []
                for _, r in df_final_salida.iterrows():
                    items_api_salida.append({
                        "id_detalle": r.get("id_detalle"),
                        "ID": str(r.get("ID", "")), "codigo": str(r.get("ID", "")),
                        "CANT": int(r.get("CANT", 1)), "cantidad": int(r.get("CANT", 1)),
                        "OBSERVACIONES": str(r.get("OBSERVACIONES", "")), "observaciones": str(r.get("OBSERVACIONES", ""))
                    })
                
                payload_verif = {"id_maestro": int(id_maestro_db), "incidencias_generales": str(txt_incidencias_gen_salida).strip(), "items": items_api_salida}
                if requests.post(f"{API_URL}/api/checkout/verificar-salida-coordinador", json=payload_verif, verify=False).status_code == 200:
                    st.session_state.modo_actual = None; st.success("🔒 Despachado."); time.sleep(1); st.rerun()
            if col_c2.button("❌ CANCELAR", width='stretch'): st.session_state.modo_actual = None; st.rerun()

        # --- ESCENARIO C: CHECKIN / RECEPCIÓN TÉCNICA CONTABLE ---
        elif st.session_state.modo_actual == "CHECKIN" and id_maestro_db:
            st.subheader(f"📥 Verificación de Retorno (Check-in)")
            st.info(f"🧰 Plantilla Base utilizada en este llamado: `{st.session_state.get('last_tpl_loaded', '--- Sin plantilla ---')}`")
            
            rows_checkin_estables = []
            for item in detalle_items:
                rows_checkin_estables.append({
                    "id_detalle": item.get("id_detalle", ""),
                    "ID": item.get("ID", item.get("codigo", item.get("codigo_equipo", ""))),
                    "EQUIPO": item.get("Equipo", item.get("EQUIPO", item.get("descripcion", "Equipo no registrado"))),
                    "CANT_SALIDA": item.get("CANT", 1),
                    "OBS_SALIDA": item.get("OBSERVACIONES", ""),
                    "✅ COTEJO": bool(item.get("¿Regresó?", item.get("✅ COTEJO", item.get("cotejado", False)))),
                    "OBS_REGRESO": item.get("Incidencia", item.get("OBS_REGRESO", item.get("notas_regreso", "")))
                })
                
            df_checkin_limpio = pd.DataFrame(rows_checkin_estables)
            df_final_captura = st.data_editor(
                df_checkin_limpio, 
                column_config={"id_detalle": None, "ID": st.column_config.TextColumn("Código", disabled=True), "EQUIPO": st.column_config.TextColumn("Descripción del Equipo", disabled=True), "CANT_SALIDA": st.column_config.NumberColumn("Salió", disabled=True), "OBS_SALIDA": st.column_config.TextColumn("Notas Salida", disabled=True), "✅ COTEJO": st.column_config.CheckboxColumn("¿Regresó?"), "OBS_REGRESO": st.column_config.TextColumn("Nota de Regreso (Incidencia)")}, 
                hide_index=True, width='stretch', key="editor_checkin_vpro_v3"
            )
            
            st.write("")
            with st.container(border=True):
                st.markdown("##### 🚚 Acta de Incidencias de Proveedores Externos")
                
                try: p_inc = proveedor_con_incidente_guardado
                except NameError: p_inc = "--- Ninguno ---"
                
                try: p_note = detalle_incidente_prov_guardado
                except NameError: p_note = ""
                
                opciones_prov_limpias = ["--- Ninguno ---"] + [str(p).strip().upper() for p in proveedores_asignados_op]
                idx_prov_inc = opciones_prov_limpias.index(p_inc) if p_inc in opciones_prov_limpias else 0
                
                prov_mal_comportamiento = st.selectbox("Selecciona el proveedor implicado:", options=opciones_prov_limpias, index=idx_prov_inc, key="sb_prov_mal_comportamiento_checkin")
                
                txt_reporte_prov = ""
                if prov_mal_comportamiento != "--- Ninguno ---":
                    txt_reporte_prov = st.text_area(f"📝 Detalles del Reporte para {prov_mal_comportamiento}:", value=p_note, key="txt_reporte_prov_checkin")

            txt_incidencias_gen_checkin = st.text_area("📝 NOTAS DE RECEPCIÓN (BODEGA):", value=incidencias_limpias_mostrar, height=120)
            
            if st.button("💾 FINALIZAR REVISIÓN Y REGRESO", type="primary", width='stretch'):
                items_api_checkin = []
                for _, r in df_final_captura.iterrows():
                    nota_regreso = str(r.get("OBS_REGRESO", "")).strip()
                    texto_analisis = nota_regreso.lower()
                    
                    if any(peligro in texto_analisis for peligro in ["dañ", "dan", "rot", "quebrad", "fall", "perd"]):
                        estatus_final = "DAÑADO"
                    else:
                        estatus_final = ""
                        
                    items_api_checkin.append({
                        "id_detalle": r.get("id_detalle"), 
                        "ID": str(r.get("ID", "")),
                        "cotejado": bool(r.get("✅ COTEJO", False)), 
                        "OBS_REGRESO": nota_regreso,
                        "estatus_equipo": estatus_final
                    })

                tag_provs = f"\n[PROVEEDOR_INCIDENTE: {prov_mal_comportamiento} | NOTA: {txt_reporte_prov.strip()}]" if prov_mal_comportamiento != "--- Ninguno ---" and txt_reporte_prov.strip() else ""
                payload_checkin = {"id_maestro": int(id_maestro_db), "id_evento": int(id_op_ref), "incidencias_generales": f"{txt_incidencias_gen_checkin}{tag_provs}".strip(), "items": items_api_checkin}
                if requests.post(f"{API_URL}/api/checkout/finalizar-checkin", json=payload_checkin, verify=False).status_code == 200:
                    st.session_state.modo_actual = None; st.success("🔒 Retorno cerrado de forma exitosa."); time.sleep(1); st.rerun()

        # 📤 ESCENARIO D: FORMULARIO REAL DE CAPTURA DE SALIDA (REPARADO)
        elif st.session_state.modo_actual in ["MODIFICAR", "NUEVO"]:
            st.subheader("📤 Formulario Activo: Captura de Salida de Hardware")
            
            # 1️⃣ PRIMERO: Recuperamos la memoria del kit y calculamos el índice dinámico
            tpl_memoria = str(st.session_state.get("last_tpl_loaded", "--- Sin plantilla ---")).strip()
            if tpl_memoria and tpl_memoria not in lista_kits: 
                lista_kits.append(tpl_memoria)
            
            lista_kits_limpia = [str(k).strip().upper() for k in lista_kits]
            idx_dinamico = lista_kits_limpia.index(tpl_memoria.upper()) if tpl_memoria.upper() in lista_kits_limpia else 0
            
            tpl_sel = st.selectbox("📋 Matriz de Kits disponibles:", options=lista_kits, index=idx_dinamico)
            
            if tpl_sel != "--- Sin plantilla ---" and str(st.session_state.get("last_tpl_loaded")).strip().upper() != tpl_sel.strip().upper():
                try:
                    import urllib.parse
                    import json
                    tpl_encoded = urllib.parse.quote(tpl_sel)
                    res_buscar = requests.get(f"{API_URL}/api/eventos/buscar_kit/{tpl_encoded}/{id_sujeto_a_revisar}", verify=False)
                    
                    if res_buscar.status_code == 200:
                        raw_items = res_buscar.json().get("items", [])
                        
                        # 🛡️ Sanitización profunda del formato JSON para evitar tablas en blanco
                        if isinstance(raw_items, str):
                            try: raw_items = json.loads(raw_items)
                            except: raw_items = []
                        
                        if raw_items and isinstance(raw_items, list):
                            df_loaded = pd.DataFrame(raw_items)
                            df_loaded.columns = [str(c).upper().strip() for c in df_loaded.columns]
                            mapeo_sinonimos = {'DESCRIPCION': 'EQUIPO', 'DESCRIPCIÓN': 'EQUIPO', 'CANTIDAD': 'CANT', 'CODIGO': 'ID', 'ID_ITEM': 'ID'}
                            for col_vieja, col_nueva in mapeo_sinonimos.items():
                                if col_vieja in df_loaded.columns and col_nueva not in df_loaded.columns: df_loaded.rename(columns={col_vieja: col_nueva}, inplace=True)
                            for col_req in ['ID', 'EQUIPO', 'CANT', 'OBSERVACIONES']:
                                if col_req not in df_loaded.columns: df_loaded[col_req] = "" if col_req != 'CANT' else 1
                                
                            st.session_state.df_checkout = df_loaded[['ID', 'EQUIPO', 'CANT', 'OBSERVACIONES']].reset_index(drop=True)
                        else:
                            # Forzamos la limpieza de la tabla si la base de datos la mandó vacía
                            st.session_state.df_checkout = pd.DataFrame(columns=['ID', 'EQUIPO', 'CANT', 'OBSERVACIONES'])
                            st.warning("⚠️ La plantilla está vacía o el formato almacenado en Postgres es ilegible.")
                    else:
                        st.error(f"📡 Error del motor al descargar kit (Código {res_buscar.status_code}): {res_buscar.text}")
                        
                    st.session_state.last_tpl_loaded = tpl_sel; st.rerun()
                except Exception as e: st.error(f"⚠️ Error en el procesador de plantillas: {e}")

            if "catalogo_inventario_completo" not in st.session_state:
                try:
                    res_inv = requests.get(f"{API_URL}/api/inventario/catalogo-global", verify=False)
                    st.session_state.catalogo_inventario_completo = res_inv.json() if res_inv.status_code == 200 else []
                except: st.session_state.catalogo_inventario_completo = []
                
            items_del_kit_actual = st.session_state.df_checkout["EQUIPO"].dropna().astype(str).str.strip().tolist() if not st.session_state.df_checkout.empty else []
            nombres_alternos = list(mapa_kits_nombres.values())
            opciones_autocompletado = sorted(list(set(st.session_state.catalogo_inventario_completo + items_del_kit_actual + nombres_alternos)))

            df_editado = st.data_editor(
                st.session_state.df_checkout,
                column_config={"ID": None, "EQUIPO": st.column_config.TextColumn("Descripción Hardware", required=True), "CANT": st.column_config.NumberColumn("Cant", min_value=1, default=1), "OBSERVACIONES": st.column_config.TextColumn("Notas Salida")},
                num_rows="dynamic", hide_index=True, width='stretch', key="grid_edicion_checkout_real_vpro"
            )
            
            if df_editado is not None and not df_editado.empty and "EQUIPO" in df_editado.columns:
                textos_usuario = df_editado["EQUIPO"].dropna().astype(str).str.strip().str.lower()
                from collections import Counter
                conteos_tabla = Counter([t for t in textos_usuario if len(t) > 2])
                repetidos_en_pantalla = [eq for eq, cant in conteos_tabla.items() if cant > 1]
                if repetidos_en_pantalla:
                    st.error(f"⚠️ **REPETIDO EN TU TABLA:** Estás seleccionando **'{repetidos_en_pantalla[0].upper()}'** en más de un renglón. Unifica las cantidades.")

            with st.expander("🔍 Buscador e Inyector Rápido de Hardware Oficial", expanded=False):
                col_inj1, col_inj2 = st.columns([3, 1])
                with col_inj1: equipo_sel_helper = st.selectbox("Selecciona un equipo:", options=["--- Selecciona un artículo ---"] + opciones_autocompletado, key="selectbox_helper_injector_pro")
                with col_inj2:
                    st.write("##")
                    if st.button("➕ AGREGAR articulo AL CHECKOUT", width='stretch', key="btn_execute_injection_pro"):
                        if equipo_sel_helper != "--- Selecciona un artículo ---":
                            if df_editado is not None: st.session_state.df_checkout = df_editado.copy()
                            nueva_fila_hw = pd.DataFrame([{"ID": "", "EQUIPO": equipo_sel_helper, "CANT": 1, "OBSERVACIONES": ""}], columns=['ID', 'EQUIPO', 'CANT', 'OBSERVACIONES'])
                            st.session_state.df_checkout = pd.concat([st.session_state.df_checkout, nueva_fila_hw], ignore_index=True); st.rerun()

            # 🚀 AQUÍ REGRESA A LA VIDA EL BOTÓN FALTANTE PARA GUARDAR PLANTILLAS
            with st.expander("💾 Guardar esta lista como Plantilla / Kit Predeterminado", expanded=False):
                st.caption("Si utilizas esta misma lista de equipos frecuentemente, guárdala como plantilla para cargarla en 1 clic en futuros llamados.")
                c_k1, c_k2 = st.columns([3, 1])
                nombre_nuevo_kit = c_k1.text_input("Nombre de la Plantilla (Ej. Kit Básico de Audio):", value=tpl_memoria if tpl_memoria != "--- Sin plantilla ---" else "", key=f"txt_nombre_kit_{id_op_ref}")
                
                if c_k2.button("💾 GRABAR PLANTILLA", width='stretch', key=f"btn_grabar_kit_{id_op_ref}"):
                    if not nombre_nuevo_kit.strip():
                        st.warning("⚠️ Debes asignarle un nombre a la plantilla.")
                    elif df_editado is None or df_editado.empty:
                        st.warning("⚠️ La lista de hardware está vacía.")
                    else:
                        # 🚀 FIX: Generamos y sellamos los IDs PERMANENTES aquí mismo antes de guardar la plantilla
                        ultimo_num_db = 0
                        try:
                            res_max = requests.get(f"{API_URL}/api/inventario-kits/ultimo-id-alterno/{id_sujeto_a_revisar}", verify=False)
                            if res_max.status_code == 200: ultimo_num_db = res_max.json().get("ultimo_id", 0)
                        except: ultimo_num_db = 0

                        mapa_n_kits = mapa_kits_nombres if 'mapa_kits_nombres' in locals() else {}
                        mapa_nombres_a_kits = {v.upper(): k for k, v in mapa_n_kits.items()}
                        items_a_guardar = []
                        
                        for _, row in df_editado.iterrows():
                            eq_str = str(row.get('EQUIPO', '')).strip()
                            if eq_str and eq_str.lower() not in ["none", "nan", ""]:
                                cod = str(row.get('ID', '')).strip()
                                if cod.upper() in ["NONE", "NAN", "NULL"]: cod = "" # 🚀 ESCUDO ANTI-FALSO NONE
                                cant = int(row.get('CANT', 1) if pd.notna(row.get('CANT')) else 1)
                                obs = str(row.get('OBSERVACIONES', '')).strip()

                                if not cod and eq_str.upper() in mapa_nombres_a_kits:
                                    cod = mapa_nombres_a_kits[eq_str.upper()]
                                    
                                if not cod and eq_str:
                                    ultimo_num_db += 1
                                    cod = f"Inv_alt_{str(id_sujeto_a_revisar).strip()}{str(ultimo_num_db).zfill(4)}"
                                    obs = f"[CUST_EQ:{eq_str}] {obs}".strip()

                                items_a_guardar.append({
                                    "ID": cod,
                                    "EQUIPO": eq_str,
                                    "CANT": cant,
                                    "OBSERVACIONES": obs
                                })
                        
                        payload_kit = {
                            "id_empleado": id_sujeto_a_revisar,
                            "nombre_kit": nombre_nuevo_kit,
                            "items": items_a_guardar,
                            "usuario_actual": st.session_state.usuario_actual
                        }
                        res_k = requests.post(f"{API_URL}/api/checkout/grabar-kit", json=payload_kit, verify=False)
                        if res_k.status_code == 200:
                            st.success(f"✅ Plantilla '{nombre_nuevo_kit}' blindada y guardada con éxito en tu perfil.")
                            st.session_state.last_tpl_loaded = nombre_nuevo_kit
                            time.sleep(1.2)
                            st.rerun()
                        else:
                            st.error(f"❌ Error al guardar plantilla: {res_k.text}")

            st.write("")
            with st.container(border=True):
                st.markdown("##### 🚚 Acta de Incidencias de Proveedores Externos")
                st.caption("Si algún proveedor co-convocado cometió una falta o daño material, levanta su reporte aquí:")
                
                p_asignados = proveedores_asignados_op if 'proveedores_asignados_op' in locals() else []
                p_inc_guardado = proveedor_con_incidente_guardado if 'proveedor_con_incidente_guardado' in locals() else "--- Ninguno ---"
                p_note_guardado = detalle_incidente_prov_guardado if 'detalle_incidente_prov_guardado' in locals() else ""
                
                opciones_prov_limpias = ["--- Ninguno ---"] + [str(p).strip().upper() for p in p_asignados]
                idx_prov_inc = opciones_prov_limpias.index(p_inc_guardado) if p_inc_guardado in opciones_prov_limpias else 0
                prov_mal_comportamiento = st.selectbox("Selecciona el proveedor implicado:", options=opciones_prov_limpias, index=idx_prov_inc, key=f"sb_prov_mal_comportamiento_form_{id_op_ref}")
                
                txt_reporte_prov = ""
                if prov_mal_comportamiento != "--- Ninguno ---":
                    txt_reporte_prov = st.text_area(f"📝 Detalles del Reporte para {prov_mal_comportamiento}:", value=p_note_guardado, key=f"txt_reporte_prov_form_{id_op_ref}")

            inc_limpias = incidencias_limpias_mostrar if 'incidencias_limpias_mostrar' in locals() else ""
            db_val = inc_limpias.strip() if inc_limpias else ""
            val_por_defecto = "Sin incidencias" if not db_val or db_val.lower() in ["ninguna", "todo bien", "ok", "none"] else db_val
            nota_incidencias = st.text_area("⚠️ Incidencias Generales de la Salida:", value=val_por_defecto, height=100, key=f"txt_incidencias_checkout_{id_op_ref}_{id_sujeto_a_revisar}")
            
            c_actions1, c_actions2 = st.columns([3, 1])
            if c_actions1.button("🚀 FINALIZAR Y REGISTRAR SALIDA DE BODEGA", type="primary", width='stretch', key=f"btn_finalizar_salida_{id_op_ref}_{id_sujeto_a_revisar}"):
                df_final = df_editado.copy().reset_index(drop=True)
                ultimo_num_db = 0
                try:
                    res_max = requests.get(f"{API_URL}/api/inventario-kits/ultimo-id-alterno/{id_sujeto_a_revisar}", verify=False)
                    if res_max.status_code == 200: ultimo_num_db = res_max.json().get("ultimo_id", 0)
                except: ultimo_num_db = 0
                
                mapa_n_kits = mapa_kits_nombres
                mapa_nombres_a_kits = {v.upper(): k for k, v in mapa_n_kits.items()}
                items_api_finales = []
                
                for i, row in df_final.iterrows():
                    cod = str(row.get('ID', '')).strip()
                    if cod.upper() in ["NONE", "NAN", "NULL"]: cod = ""
                    eq = str(row.get('EQUIPO', '')).strip()
                    cant = int(row.get('CANT', 1) if pd.notna(row.get('CANT')) else 1)
                    obs = str(row.get('OBSERVACIONES', '')).strip()
                    
                    if not cod and eq.upper() in mapa_nombres_a_kits: cod = mapa_nombres_a_kits[eq.upper()]
                    if not cod and eq:
                        ultimo_num_db += 1
                        cod = f"Inv_alt_{str(id_sujeto_a_revisar).strip()}{str(ultimo_num_db).zfill(4)}"
                        obs = f"[CUST_EQ:{eq}] {obs}".strip()
                        
                    items_api_finales.append({"ID": cod, "CANT": cant, "OBSERVACIONES": obs, "EQUIPO": eq})
                
                tag_provs = f"\n[PROVEEDOR_INCIDENTE: {prov_mal_comportamiento} | NOTA: {txt_reporte_prov.strip()}]" if prov_mal_comportamiento != "--- Ninguno ---" and txt_reporte_prov.strip() else ""
                payload_salida = {"id_evento": int(id_op_ref), "id_sujeto_a_revisar": str(id_sujeto_a_revisar).strip(), "incidencias_generales": f"{nota_incidencias}{tag_provs}".strip(), "nombre_kit": str(tpl_sel).strip(), "items": items_api_finales}
                
                res_salida = requests.post(f"{API_URL}/api/checkout/finalizar-salida", json=payload_salida, verify=False)
                if res_salida.status_code == 200:
                    st.success("🔒 ¡Checkout guardado y sincronizado con éxito!")
                    st.session_state.modo_actual = "VISTA"
                    st.session_state.df_checkout = pd.DataFrame(columns=['ID', 'EQUIPO', 'CANT', 'OBSERVACIONES'])
                    time.sleep(1.5); st.rerun()
                else: st.error(f"❌ Error al registrar salida: {res_salida.text}")
            
            if c_actions2.button("❌ ABORTAR", width='stretch', key=f"btn_abortar_checkout_{id_op_ref}"):
                st.session_state.modo_actual = None; st.rerun()
        else:
            st.info("🎯 Panel operativo central listo. Selecciona una opción del menú de la izquierda para comenzar.")

elif "Incidencias" in opcion_seleccionada: # 📊 MÓDULO: INCIDENCIAS
    nombre_raw = st.session_state.usuario_actual
    def limpiar_texto_firma(texto):
        texto_norm = unicodedata.normalize('NFD', str(texto))
        return "".join(c for c in texto_norm if unicodedata.category(c) != 'Mn').upper()
    usuario_pc = limpiar_texto_firma(nombre_raw)
    es_autorizado = "VILLARREAL" in usuario_pc or "AGUNDEZ" in usuario_pc
    if not es_autorizado:
        st.error("🚫 **ACCESO TOTALMENTE DENEGADO**")
        st.stop()

    st.subheader("📊 Monitoreo y Análisis de Incidencias Técnicas")
    df_raw = pd.DataFrame(columns=['id_maestro', 'folio_op', 'incidencias_generales', 'fecha', 'id_empleado', 'nombre_evento', 'para_q_cliente', 'nombre_empleado', 'depto_real'])
    try:
        res_inc = requests.get(f"{API_URL}/api/incidencias/reporte", verify=False)
        if res_inc.status_code == 200:
            data_json = res_inc.json()
            if data_json:
                df_raw = pd.DataFrame(data_json)
                df_raw['fecha'] = pd.to_datetime(df_raw['fecha']).dt.date
                df_raw['depto_real'] = df_raw['depto_real'].fillna("Sin Departamento").astype(str).str.strip()
        else: st.error(f"❌ Error en el Servidor Central de Incidencias: Código {res_inc.status_code}")
    except Exception as e: 
        st.error(f"📡 Error de Enlace: {e}")
        st.stop()

    def clasificar_texto(texto):
        if not texto: return "✅ Sin Incidencias"
        t = str(texto).lower().strip()
        if t.startswith("sin incidencia") or t in ["ninguna", "todo bien", "exito", "ok", "n/a", "none"]: return "✅ Sin Incidencias"
        return "⚠️ Con Incidencias"

    if not df_raw.empty:
        df_raw['Estatus'] = df_raw['incidencias_generales'].apply(clasificar_texto)
        st.markdown("### 🎯 Seleccione para FILTRAR información")
        c1, c2, c3 = st.columns(3)
        df_fechas = df_raw.dropna(subset=['fecha'])
        f_min, f_max = (df_fechas['fecha'].min(), df_fechas['fecha'].max()) if not df_fechas.empty else (datetime.date.today(), datetime.date.today())
        with c1: rango_fechas = st.date_input("📅 Periodo:", [f_min, f_max])
        with c2:
            lista_deptos = ["Todos"] + sorted(df_raw['depto_real'].unique().tolist())
            depto_sel = st.selectbox("🏢 Departamento:", lista_deptos)
        with c3:
            df_temp_emp = df_raw.copy()
            if depto_sel != "Todos": df_temp_emp = df_temp_emp[df_temp_emp['depto_real'] == depto_sel]
            empleados = ["Todos"] + sorted(df_temp_emp['nombre_empleado'].dropna().unique().tolist())
            emp_sel = st.selectbox("👤 Empleado:", empleados)

        df_filtrado = df_raw.copy()
        if isinstance(rango_fechas, (list, tuple)) and len(rango_fechas) == 2: df_filtrado = df_filtrado[(df_filtrado['fecha'] >= rango_fechas[0]) & (df_filtrado['fecha'] <= rango_fechas[1])]
        if depto_sel != "Todos": df_filtrado = df_filtrado[df_filtrado['depto_real'] == depto_sel]
        if emp_sel != "Todos": df_filtrado = df_filtrado[df_filtrado['nombre_empleado'] == emp_sel]

        st.divider()
        
        # 🚀 CONSOLIDACIÓN QUIRÚRGICA: Agrupamos por OP para obtener Eventos Únicos Reales
        df_eventos_unicos = df_filtrado.groupby('nombre_evento').agg({
            'Estatus': lambda x: '⚠️ Con Incidencias' if '⚠️ Con Incidencias' in x.values else '✅ Sin Incidencias'
        }).reset_index()

        total_eventos_unicos = len(df_eventos_unicos)
        exitos_eventos = len(df_eventos_unicos[df_eventos_unicos['Estatus'] == "✅ Sin Incidencias"])
        fallas_eventos = total_eventos_unicos - exitos_eventos
        total_registros_logs = len(df_filtrado)

        col1, col2, col3, col4 = st.columns(4) # Pintamos la nueva estructura de 4 columnas horizontales transparentes
        col1.metric("Total Eventos Evaluados", total_eventos_unicos)
        col2.metric("Eventos SIN INCIDENCIAS", exitos_eventos, delta=f"{(exitos_eventos/total_eventos_unicos*100):.1f}%" if total_eventos_unicos > 0 else "0%")
        col3.metric("Eventos CON INCIDENCIAS", fallas_eventos, delta=f"-{(fallas_eventos/total_eventos_unicos*100):.1f}%" if total_eventos_unicos > 0 else "0%", delta_color="inverse")
        col4.metric("Total Registros/Logs Analizados", total_registros_logs)

        st.markdown("### 📊 Análisis Gráfico"); g1, g2 = st.columns([1, 2])
        with g1:
            if total_eventos_unicos > 0: # El gráfico de pastel/balance ahora se alimenta estrictamente de EVENTOS ÚNICOS
                df_comp = df_eventos_unicos['Estatus'].value_counts(normalize=True).reset_index()
                df_comp.columns = ['Estatus', 'Porcentaje']
                df_comp['Porcentaje'] = df_comp['Porcentaje'] * 100
                df_comp['Total'] = "Balance General"
                
                fig_balance_bar = px.bar(df_comp, x='Total', y='Porcentaje', color='Estatus', text='Porcentaje', color_discrete_map={"✅ Sin Incidencias": "#2ecc71", "⚠️ Con Incidencias": "#e74c3c"})
                fig_balance_bar.update_traces(texttemplate='%{text:.1f}%', textposition='inside')
                st.plotly_chart(fig_balance_bar, width='stretch')
        with g2:
            if total_registros_logs > 0:
                
                df_trend = df_filtrado.groupby(['fecha', 'Estatus']).size().reset_index(name='Cuenta')  # 1. Agrupamos y obtenemos los conteos nativos
                df_trend = df_trend.sort_values('fecha')                                                # 2. Aseguramos orden cronológico real por fecha antes de formatear
                df_trend['Fecha_Corta'] = pd.to_datetime(df_trend['fecha']).dt.strftime('%d/%m')        # 3. 🧠 EL TRUCO: Convertimos la fecha a texto ejecutivo (Día/Mes) eliminando el año
                
                # 4. Construimos el gráfico usando el nuevo eje X corto
                fig_trend = px.bar(
                    df_trend, 
                    x='Fecha_Corta',
                    y='Cuenta', 
                    color='Estatus', 
                    color_discrete_map={"✅ Sin Incidencias": "#2ecc71", "⚠️ Con Incidencias": "#e74c3c"}, 
                    barmode='group'
                )
                
                fig_trend.update_layout(
                    xaxis=dict(type='category', title="Fecha del Log Registrado (Día/Mes)")
                )
                st.plotly_chart(fig_trend, width='stretch')

        st.divider()
        df_tabla = df_filtrado[df_filtrado['incidencias_generales'].notna() & (df_filtrado['incidencias_generales'] != '')]
        if not df_tabla.empty:
            columnas_visibles = ['fecha', 'nombre_evento', 'para_q_cliente', 'nombre_empleado', 'Estatus', 'incidencias_generales']
            st.dataframe(df_tabla[columnas_visibles], width='stretch', hide_index=True)
    else: st.info("✅ Operación Limpia: No se registran equipos dañados bajo este perfil.")

elif "Equipos con Daño" in opcion_seleccionada: # 🚩 MÓDULO: EQUIPOS CON DAÑO
    rol = st.session_state.rol; user_id = str(st.session_state.id_usuario); depto_usuario = st.session_state.depto; operador = st.session_state.usuario_actual; nombre_usuario = operador.upper()
    if "AGUNDEZ" in nombre_usuario or "VILLARREAL" in nombre_usuario: st.subheader("🚀 Radar Global: Equipos con Falla/Incidencia Activa")
    elif rol == "PRODUCTOR": st.subheader(f"📢 Radar de Departamento: {depto_usuario}")
    else: st.subheader("🚩 Mis Reportes Personales de Hardware")

    with st.expander("🛠️ REGISTRAR REPORTE DIRECTO DE OFICINA / MANTENIMIENTO INTERNO"):
        try:
            res_inv_lista = requests.get(f"{API_URL}/api/inventario-kits/lista", verify=False)
            if res_inv_lista.status_code == 200:
                codigos_inv = [f"{x['codigo']} - {x['descripcion']}" for x in res_inv_lista.json()]
            else: codigos_inv = []
        except: codigos_inv = []
        
        c_c1, c_c2 = st.columns([2, 1])
        eq_seleccionado = c_c1.selectbox("🔍 Selecciona el Equipo de Oficina / Bodega:", options=["---"] + codigos_inv, key="manual_eq_sel")
        tipo_log = c_c2.selectbox("🩺 Tipo de Evento:", ["MANTENIMIENTO_TÉCNICO", "FALLA_OPERATIVA", "DAÑO_FÍSICO_OFICINA", "RESPALDO_SISTEMAS"], key="manual_tipo_log")
        
        c_c3, c_c4 = st.columns(2)
        est_final = c_c3.selectbox("📊 Estado Final del Equipo:", ["RESUELTO", "PENDIENTE", "EN TALLER", "BAJA"], key="manual_est_final")
        costo_asoc = c_c4.number_input("💰 Costo Asociado (Opcional $):", min_value=0.0, value=0.0, step=50.0, key="manual_costo_asoc")
        
        txt_bitacora = st.text_area("📝 Pega aquí el reporte del equipo (Ej. texto de WhatsApp):", placeholder="Buena tarde, conforme a lo comentado se realizaron los respaldos...", key="manual_txt_bitacora")
        
        foto_evidencia = st.file_uploader("📸 Adjuntar Evidencia Fotográfica (Opcional):", type=["png", "jpg", "jpeg"], key="manual_foto_evidencia")
        
        # Agregamos una llave de seguridad temporal arriba del botón
        if "boton_reporte_bloqueado" not in st.session_state:
            st.session_state.boton_reporte_bloqueado = False

        if st.button("💾 ACTUALIZAR REPORTE AL EXPEDIENTE HISTÓRICO", width='stretch', type="primary", key="manual_btn_save", disabled=st.session_state.boton_reporte_bloqueado):
            if eq_seleccionado == "---" or not txt_bitacora.strip():
                st.warning("⚠️ Por favor selecciona un equipo y escribe el detalle del reporte.")
            else:
                st.session_state.boton_reporte_bloqueado = True # Bloqueamos el botón instantáneamente
                
                cod_puro = eq_seleccionado.split(" - ")[0].strip()
                payload_manual = {
                    "codigo_equipo": cod_puro,
                    "folio_vpro": "MANTENIMIENTO_INTERNO",
                    "id_empleado": user_id,
                    "tipo_evento": tipo_log,
                    "descripcion": txt_bitacora.strip(),
                    "costo_asociado": float(costo_asoc),
                    "estado_final": est_final,
                    "departamento": depto_usuario.upper()
                }
                res_m_save = requests.post(f"{API_URL}/api/inventario/historial/guardar", json=payload_manual, verify=False)
                
                if res_m_save.status_code == 200:
                    if foto_evidencia is not None:
                        files = {"file": (foto_evidencia.name, foto_evidencia.getvalue(), foto_evidencia.type)}
                        data = {"codigo_equipo": cod_puro, "folio_vpro": "MANTENIMIENTO_INTERNO"}
                        requests.post(f"{API_URL}/api/inventario/subir-evidencia", files=files, data=data, verify=False)

                    st.toast("🔒 ¡Reporte y evidencia fijados con éxito!")
                    time.sleep(1.2)
                    st.session_state.boton_reporte_bloqueado = False # Soltamos el botón antes de recargar
                    st.rerun()
                else: 
                    st.error(f"❌ Error REAL del Motor Postgres: {res_m_save.text}")
                    st.session_state.boton_reporte_bloqueado = False

    st.write("")
    df_base = pd.DataFrame()
    try:
        res_danos = requests.get(f"{API_URL}/api/inventario/radar-danos", params={"user_id": user_id, "rol": rol, "nombre_usuario": operador}, verify=False)
        if res_danos.status_code == 200:
            df_base = pd.DataFrame(res_danos.json())
            if not df_base.empty:
                for col_req in ['FECHA_REPORTE', 'ID', 'EQUIPO', 'DEPARTAMENTO', 'FALLA', 'REPORTÓ', 'FOLIO_TALLER']:
                    if col_req not in df_base.columns:
                        df_base[col_req] = "---" if col_req != 'FECHA_REPORTE' else datetime.date.today()

                df_base['FALLA'] = df_base['FALLA'].fillna('').astype(str).str.strip()
        else: st.error(f"❌ Error al mapear radar de fallas: {res_danos.text}"); st.stop()
    except Exception as e: st.error(f"📡 Error de comunicación con el Cerebro API: {e}"); st.stop()

    if not df_base.empty:
        st.markdown("### 🎯 Seleccione para FILTRAR información")
        
        c1, c2, c3 = st.columns(3)
        df_fechas_danos = df_base.dropna(subset=['FECHA_REPORTE'])
        fd_min, fd_max = (df_fechas_danos['FECHA_REPORTE'].min(), df_fechas_danos['FECHA_REPORTE'].max()) if not df_fechas_danos.empty else (datetime.date.today(), datetime.date.today())
        
        with c1: rango_fechas_danos = st.date_input("📅 Periodo:", [fd_min, fd_max], key="danos_rango_fechas")
        with c2:
            lista_deptos_danos = ["Todos"] + sorted(df_base['DEPARTAMENTO'].unique().tolist())
            depto_sel_danos = st.selectbox("🏢 Departamento:", lista_deptos_danos, key="danos_depto_select")
        with c3:
            df_temp_emp_danos = df_base.copy()
            if depto_sel_danos != "Todos": 
                df_temp_emp_danos = df_temp_emp_danos[df_temp_emp_danos['DEPARTAMENTO'] == depto_sel_danos]
            empleados_danos = ["Todos"] + sorted(df_temp_emp_danos['REPORTÓ'].dropna().unique().tolist())
            emp_sel_danos = st.selectbox("👤 Empleado:", empleados_danos, key="danos_emp_select")

        df_filtrado_danos = df_base.copy()
        
        df_filtrado_danos['FECHA_REPORTE'] = pd.to_datetime(df_filtrado_danos['FECHA_REPORTE'], errors='coerce').dt.date
        df_filtrado_danos['FECHA_REPORTE'] = df_filtrado_danos['FECHA_REPORTE'].fillna(datetime.date.today())

        if isinstance(rango_fechas_danos, (list, tuple)) and len(rango_fechas_danos) == 2:
            df_filtrado_danos = df_filtrado_danos[(df_filtrado_danos['FECHA_REPORTE'] >= rango_fechas_danos[0]) & (df_filtrado_danos['FECHA_REPORTE'] <= rango_fechas_danos[1])]
        if depto_sel_danos != "Todos":
            df_filtrado_danos = df_filtrado_danos[df_filtrado_danos['DEPARTAMENTO'] == depto_sel_danos]
        if emp_sel_danos != "Todos":
            df_filtrado_danos = df_filtrado_danos[df_filtrado_danos['REPORTÓ'] == emp_sel_danos]

        st.divider(); st.markdown("### 📊 Reportes Totales por Personal")
        df_conteo = df_filtrado_danos['REPORTÓ'].value_counts().reset_index(); df_conteo.columns = ['Empleado', 'Cantidad']
        fig = px.bar(df_conteo, x='Empleado', y='Cantidad', text='Cantidad', color='Cantidad', color_continuous_scale='Reds', template='plotly_dark')
        fig.update_layout(height=400, xaxis_title="Personal de Ruta", yaxis_title="Reportes Emitidos")
        st.plotly_chart(fig, width='stretch')

        st.markdown("### 📋 Detalle de Incidencias en Bodega")
        columnas_visibles = ['FECHA_REPORTE', 'ID', 'EQUIPO', 'DEPARTAMENTO', 'FALLA', 'REPORTÓ', 'FOLIO_TALLER']
        st.dataframe(df_filtrado_danos[columnas_visibles], width='stretch', hide_index=True)
    else: st.success("✅ Operación Limpia: No se registran equipos dañados bajo este perfil.")

# 🕒 MÓDULO: CHECADOR DE PERSONAL POR CÓDIGO QR (KIOSCO INDUSTRIAL ANTI-BLOQUEO)
elif "Checador" in opcion_seleccionada:
    if st.session_state.get("id_usuario") == "529":
        st.markdown("<style>.st-emotion-cache-10trblm {display: none;} h1 {display: none;}</style>", unsafe_allow_html=True)
        
    id_operador = st.session_state.id_usuario
    id_sujeto_checa = id_operador
    rol_user = st.session_state.rol
    nombre_operador = st.session_state.usuario_actual

    # 🧠 Inicializamos memorias del Kiosco
    if "historial_kiosko_ui" not in st.session_state: st.session_state.historial_kiosko_ui = []
    if "ultimo_escaneado_ui" not in st.session_state: st.session_state.ultimo_escaneado_ui = None
    if "memoria_kiosko" not in st.session_state: st.session_state.memoria_kiosko = {}
    if "qr_a_procesar" not in st.session_state: st.session_state.qr_a_procesar = None

    # 🎯 CALLBACK AUTOMÁTICO: Vacía la caja al instante en que el escáner dispara
    def atrapar_qr():
        leido = st.session_state.get("widget_lector_kiosko", "").strip()
        if leido:
            st.session_state.qr_a_procesar = leido
            st.session_state.widget_lector_kiosko = "" # Limpia el campo visualmente

    if es_kiosko:
        # --- CASO A: MODO KIOSCO AUTOMÁTICO ---
        st.markdown("""
            <div style="background-color: #0f172a; padding: 30px; border-radius: 12px; border-left: 10px solid #a3e635; text-align: center; margin-bottom: 25px; box-shadow: 0 6px 12px rgba(0,0,0,0.15);">
                <h1 style="margin: 0; color: #ffffff; letter-spacing: -1px; font-size: 41px; font-weight: 800; display: block !important;">
                    ⏱️ RELOJ CHECADOR VPRO
                </h1>
                <p style="margin: 15px 0 0 0; color: #a3e635; font-size: 22px; font-weight: bold;">
                    👋 BIENVENID@. Pase el código QR de su credencial por el lector digital...
                </p>
            </div>
        """, unsafe_allow_html=True)
        
        # 1️⃣ EL ESCÁNER ESTÁTICO PERO INTELIGENTE (Ya no cambia el key, usa Callback)
        st.text_input(
            "Lector QR", 
            key="widget_lector_kiosko", 
            label_visibility="collapsed", 
            placeholder="Pase su gafete por el escáner aquí...",
            on_change=atrapar_qr
        )
        
        # 🛡️ Inyector de enfoque purificado (MODO TERMINATOR ANTI-DORMILONES)
        st.components.v1.html("""
            <script>
                function engancharCursor() {
                    var inputs = window.parent.document.querySelectorAll('input');
                    for (var i = 0; i < inputs.length; i++) {
                        if (inputs[i].placeholder && inputs[i].placeholder.includes('Pase su gafete')) {
                            // Solo roba el foco si se ha perdido
                            if (window.parent.document.activeElement !== inputs[i]) {
                                inputs[i].focus();
                            }
                            break;
                        }
                    }
                }
                engancharCursor();
                // setInterval obliga al navegador a revisar el cursor CADA SEGUNDO (1000 ms)
                setInterval(engancharCursor, 1000); 
            </script>
        """, height=0)

        # 2️⃣ PROCESAMIENTO DEL QR ATRAPADO EN MEMORIA
        if st.session_state.qr_a_procesar:
            id_limpio = st.session_state.qr_a_procesar
            st.session_state.qr_a_procesar = None # Consumimos el dato para que no se cicle
            
            ahora_segundos = datetime.datetime.now().timestamp()
            ultimo_registro = st.session_state.memoria_kiosko.get(id_limpio, 0)
            
            # Bloqueo anti-spam de 60 segundos
            if (ahora_segundos - ultimo_registro) < 60:
                st.toast("⏱️ Tu asistencia ya se registró. Deja pasar al que sigue.", icon="⚠️")
            else:
                st.session_state.memoria_kiosko[id_limpio] = ahora_segundos
                
                try:
                    res_lista = requests.get(f"{API_URL}/api/empleados", verify=False)
                    if res_lista.status_code == 200:
                        employees_all = res_lista.json()
                        emp_match = next((e for e in employees_all if str(e['id_empleado']).strip() == id_limpio), None)
                        
                        if emp_match:
                            id_s = emp_match["id_empleado"]
                            nombre_s = emp_match["nombre"]
                            
                            status_checada = {"registrado": False, "completo": False}
                            res_st = requests.get(f"{API_URL}/api/asistencia/status/{id_s}", verify=False)
                            if res_st.status_code == 200: status_checada = res_st.json()
                        
                            ahora = datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None) - datetime.timedelta(hours=7)
                            ahora_hora = ahora.time()
                            ahora_hora_txt = ahora.strftime('%H:%M:%S')
                            ya_cerro_turno = status_checada.get("hora_salida") is not None
                            
                            if not status_checada.get("registrado") or ya_cerro_turno:
                                tipo_mov = "ENTRADA"
                                if ahora_hora < datetime.time(14, 30, 0):
                                    limite_retardo = datetime.time(9, 1, 0)
                                    observacion_turno = "T. Matutino"
                                else:
                                    limite_retardo = datetime.time(16, 1, 0)
                                    observacion_turno = "T. Vespertino"
                                    
                                if ahora_hora > limite_retardo:
                                    estatus_final = "RETARDO"
                                    dt_limite = datetime.datetime.combine(ahora.date(), limite_retardo)
                                    segundos_tarde = int((ahora - dt_limite).total_seconds())
                                    m_t = segundos_tarde // 60
                                    s_t = segundos_tarde % 60
                                    texto_llegada = f"🔴 TARDE ({m_t}m {s_t}s)"
                                else:
                                    estatus_final = "ASISTENCIA"
                                    texto_llegada = "🟢 A TIEMPO"
                            else:
                                tipo_mov = "SALIDA"
                                estatus_final = "ASISTENCIA"
                                if ahora_hora < datetime.time(15, 30, 0): observacion_turno = "Comida"
                                else: observacion_turno = "Fin Jornada"
                                texto_llegada = f"🔵 SALIDA ({observacion_turno})"
                                
                            p_mov = {"id_empleado": id_s, "tipo_movimiento": tipo_mov, "estatus": estatus_final, "observaciones": f"Kiosco - {observacion_turno}"}
                            res_final_ch = requests.post(f"{API_URL}/api/asistencia/checar", json=p_mov, verify=False)
                            
                            if res_final_ch.status_code == 200:
                                st.toast(f"✅ ¡{nombre_s} registrado con éxito!", icon="👍")
                                
                                # Actualizamos memoria visual
                                st.session_state.ultimo_escaneado_ui = {
                                    "id": id_s, "nombre": nombre_s, "movimiento": tipo_mov, "hora": ahora_hora_txt, "estatus_str": texto_llegada
                                }
                                st.session_state.historial_kiosko_ui.insert(0, {
                                    "ID": id_s, "Empleado": nombre_s, "Hora": ahora_hora_txt, "Estatus": texto_llegada
                                })
                                st.session_state.historial_kiosko_ui = st.session_state.historial_kiosko_ui[:15]
                            else:
                                st.toast(f"❌ Error de servidor al guardar checada.", icon="⚠️")
                        else:
                            st.toast(f"🚫 CÓDIGO {id_limpio} NO RECONOCIDO.", icon="⚠️")
                except Exception as e:
                    st.toast(f"📡 Error de red: {e}", icon="⚠️")

        # 3️⃣ RENDERIZADO VISUAL DEL KIOSKO (Izquierda: Foto Gigante, Derecha: Wall of Fame)
        c_perfil, c_historial = st.columns([1.2, 2.8])
        
        with c_perfil:
            if st.session_state.ultimo_escaneado_ui:
                u = st.session_state.ultimo_escaneado_ui
                with st.container(border=True):
                    foto_path = "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"
                    for ext in ['.png', '.jpg', '.jpeg', '.PNG', '.JPG', '.JPEG']:
                        p_prueba = os.path.join(FOTOS_PERSONAL_DIR, f"{u['id']}{ext}")
                        if os.path.exists(p_prueba):
                            foto_path = p_prueba
                            break
                    st.image(foto_path, use_container_width=True)
                    st.markdown(f"<h3 style='text-align:center; color:#0f172a; margin-top:5px; margin-bottom:0;'>{u['nombre']}</h3>", unsafe_allow_html=True)
                    st.markdown(f"<p style='text-align:center; color:#64748b; font-size:16px; margin:0;'>ID: {u['id']}</p>", unsafe_allow_html=True)
                    st.divider()
                    st.markdown(f"<h4 style='text-align:center; margin:0;'>{u['estatus_str']}</h4>", unsafe_allow_html=True)
                    st.markdown(f"<p style='text-align:center; color:#475569; font-size:18px;'>{u['movimiento']} | ⏰ {u['hora']}</p>", unsafe_allow_html=True)
            else:
                with st.container(border=True): # Tarjeta de espera por si alguien refresca la página
                    st.image("https://cdn-icons-png.flaticon.com/512/3135/3135715.png", use_container_width=True)
                    st.markdown("<h3 style='text-align:center; color:#64748b; margin-top:15px;'>Esperando lectura...</h3>", unsafe_allow_html=True)
                
        with c_historial:
            st.markdown("<h4 style='text-align:center; color:#f8fafc; margin-top:0;'>📊 MATRIZ DE ASISTENCIA DEL DÍA</h4>", unsafe_allow_html=True)
            try:    # 1. Traemos a TODOS los empleados y los registros de hoy
                res_emps = requests.get(f"{API_URL}/api/empleados", verify=False)
                res_hoy = requests.get(f"{API_URL}/api/asistencia/reporte", verify=False)
                
                if res_emps.status_code == 200 and res_hoy.status_code == 200:
                    empleados_data_raw = res_emps.json()
                    todos_los_registros = res_hoy.json()
                    hoy_str = str(datetime.date.today())
                    
                    empleados_data = [] # 🧹 EL FILTRO DEFINITIVO (CAZA-FANTASMAS NIVEL DIOS)
                    for emp in empleados_data_raw:
                        id_e = str(emp.get('id_empleado', '')).strip()
                        email_emp = str(emp.get('email', '')).strip()
                        
                        todo_el_texto = f"{emp.get('estatus', '')} {emp.get('estado', '')} {emp.get('rol', '')} {emp.get('depto', '')}".upper() # Juntamos TODO lo que RH pudo haber escrito en cualquier caja de texto
                        
                        if id_e == "529": continue      # 🚫 Regla 1: Ignorar al Kiosco
                        if "@" not in email_emp: continue   # 🚫 Regla 2: Exigir correo (por si RH sí hizo su trabajo y lo borró)
                        if 'BAJA' in todo_el_texto or 'INACTIV' in todo_el_texto: continue      # 🚫 Regla 3: Si dice BAJA o INACTIVO en CUALQUIER rincón del perfil, va para afuera
                        if 'PROVEEDOR' in todo_el_texto or 'EXTERNO' in todo_el_texto: continue     # 🚫 Regla 4: Proveedores y externos, para afuera
                            
                        empleados_data.append(emp)
                    
                    registros_hoy = [r for r in todos_los_registros if str(r['fecha']).startswith(hoy_str)]     # Filtramos las checadas solo para hoy
                    df_asist = pd.DataFrame(registros_hoy) if registros_hoy else pd.DataFrame()
                    
                    def clean_time_full(x):
                        if pd.isna(x) or str(x).strip() in ["", "None", "nan"]: return "--:--:--"
                        return str(x)[:8]
                        
                    def calc_estatus_entrada(hora_str, turno):
                        if hora_str == "--:--:--": return ""
                        try:
                            h, m, s = map(int, str(hora_str).split(':'))
                            hora_dt = datetime.timedelta(hours=h, minutes=m, seconds=s)
                            limite_dt = datetime.timedelta(hours=9, minutes=1, seconds=0) if turno == "Matutino" else datetime.timedelta(hours=16, minutes=1, seconds=0)
                            if hora_dt > limite_dt:
                                retraso = hora_dt - limite_dt
                                mins = int(retraso.total_seconds() // 60)
                                secs = int(retraso.total_seconds() % 60)
                                return f"🔴 TARDE ({mins}m {secs}s)"
                            else: return "🟢 A TIEMPO"
                        except: return "🟢 A TIEMPO"

                    def calc_estatus_salida_vesp(hora_str):
                        if hora_str == "--:--:--": return ""
                        try:
                            h, m, s = map(int, str(hora_str).split(':'))
                            if (h == 19 and m >= 50) or h >= 20: return "🌙 Revisar T. Extra"
                            return "🏠 Descansa"
                        except: return "🏠 Descansa"

                    records = []
                    
                    empleados_ordenados = sorted(empleados_data, key=lambda x: x['nombre'])     # Ordenamos la plantilla alfabéticamente para que siempre salgan en el mismo orden
                    
                    for emp in empleados_ordenados:
                        id_emp = str(emp['id_empleado']).strip()
                        nom = emp['nombre']
                        
                        m_in, m_out, v_in, v_out = "--:--:--", "--:--:--", "--:--:--", "--:--:--"
                        m_in_est, v_in_est, v_out_est = "", "", ""
                        
                        if not df_asist.empty:      # Buscar si este empleado específico ya checó hoy
                            emp_records = df_asist[df_asist['id_empleado'].astype(str).str.strip() == id_emp]
                            for _, row in emp_records.iterrows():
                                h_ent = clean_time_full(row.get('hora_entrada'))
                                h_sal = clean_time_full(row.get('hora_salida'))
                                
                                turno = "Matutino"      # Determinar a qué turno pertenece esa checada
                                if h_ent != "--:--:--":
                                    try:
                                        if int(h_ent[:2]) >= 15: turno = "Vespertino"
                                    except: pass
                                    
                                if turno == "Matutino":
                                    m_in, m_out = h_ent, h_sal
                                    m_in_est = calc_estatus_entrada(m_in, "Matutino")
                                else:
                                    v_in, v_out = h_ent, h_sal
                                    v_in_est = calc_estatus_entrada(v_in, "Vespertino")
                                    v_out_est = calc_estatus_salida_vesp(v_out)
                                    
                        # Agregamos la fila (tenga checadas o esté completamente vacía)
                        records.append({
                            ("", "ID"): id_emp,
                            ("", "Empleado"): nom,
                            ("TURNO MATUTINO", "Entrada"): m_in,
                            ("TURNO MATUTINO", "Estatus"): m_in_est,
                            ("TURNO MATUTINO", "Salida"): m_out,
                            ("TURNO VESPERTINO", "Entrada"): v_in,
                            ("TURNO VESPERTINO", "Estatus"): v_in_est,
                            ("TURNO VESPERTINO", "Salida"): v_out,
                            ("TURNO VESPERTINO", "Estatus "): v_out_est
                        })
                        
                    df_final_turnos = pd.DataFrame(records)
                    
                    if not df_final_turnos.empty:
                        df_final_turnos.columns = pd.MultiIndex.from_tuples(df_final_turnos.columns)
                        
                        def resaltar_sabana_kiosko(val):        # 🎨 Paleta de colores ajustada para el fondo oscuro del Kiosco
                            val_str = str(val)
                            if val_str == "--:--:--": return 'color: #f87171; background-color: rgba(153, 27, 27, 0.2);'
                            if "TARDE" in val_str: return 'color: #fca5a5; background-color: rgba(153, 27, 27, 0.5); font-weight: bold;'
                            if "A TIEMPO" in val_str: return 'color: #86efac; background-color: rgba(22, 101, 52, 0.5); font-weight: bold;'
                            if "Descansa" in val_str: return 'color: #93c5fd; background-color: rgba(30, 64, 175, 0.5); font-weight: bold;'
                            if "T. Extra" in val_str: return 'color: #fef08a; background-color: rgba(133, 77, 14, 0.5); font-weight: bold;'
                            return ''
                            
                        st.dataframe(df_final_turnos.style.map(resaltar_sabana_kiosko), width='stretch', height=600, hide_index=True)
                else:
                    st.error("Error al cargar datos del servidor.")
            except Exception as e:
                st.error(f"Error de red: {e}")
    else:       # --- CASO B: MODO CHECADOR INDIVIDUAL (APP WEB) ---
        tab_checar, tab_admin = st.tabs(["🕒 Registrar Marca Diaria", "📊 REVISION DE ASISTENCIA DE PERSONAL"])
        
        with tab_checar:
            id_sujeto_checa = id_operador
            nombre_sujeto_checa = nombre_operador
            
            foto_png = os.path.join(FOTOS_PERSONAL_DIR, f"{id_sujeto_checa}.png")
            foto_jpg = os.path.join(FOTOS_PERSONAL_DIR, f"{id_sujeto_checa}.jpg")
            foto_ruta_activa = foto_png if os.path.exists(foto_png) else (foto_jpg if os.path.exists(foto_jpg) else None)
            
            status_checada = {"registrado": False}
            try:
                res_st = requests.get(f"{API_URL}/api/asistencia/status/{id_sujeto_checa}", verify=False)
                if res_st.status_code == 200: status_checada = res_st.json()
            except Exception as e: st.error(f"Error al bajar status: {e}")
            
            emp_data = {}
            try:
                res_emps = requests.get(f"{API_URL}/api/empleados", verify=False)
                if res_emps.status_code == 200:
                    for e in res_emps.json():
                        if str(e["id_empleado"]).strip() == str(id_sujeto_checa).strip():
                            emp_data = e
                            break
            except: pass
            
            qr_b64 = None; qr_bytes = None
            try:
                res_qr = requests.get(f"{API_URL}/api/empleados/{id_sujeto_checa}/qr", verify=False)
                if res_qr.status_code == 200:
                    qr_pack = res_qr.json()
                    qr_b64 = qr_pack["qr_base64"]
                    qr_bytes = base64.b64decode(qr_b64.split(",")[1])
            except: pass

            def fmt_fecha(f_str):
                if not f_str or str(f_str) in ["None", "nan", ""]: return "No registrada"
                try: return pd.to_datetime(f_str).strftime("%d/%m/%Y")
                except: return str(f_str)

            st.write("")
            with st.container(border=True):
                st.markdown(f"<h3 style='margin-bottom: 5px; color:#0f172a;'>🪪 Credencial Digital VPRO</h3>", unsafe_allow_html=True)
                st.markdown("<p style='color:#64748b; margin-top:0;'>Presente el Código QR en la terminal física para registrar su asistencia.</p>", unsafe_allow_html=True)
                st.write("")
                
                c_foto, c_datos, c_qr = st.columns([1.5, 2.5, 1.5])
                
                with c_foto:
                    if foto_ruta_activa: 
                        st.image(foto_ruta_activa, width='stretch')
                    else: 
                        st.error("❌ Fotografía no vinculada")
                        
                with c_datos:
                    st.markdown(f"**Nombre:** {nombre_sujeto_checa}")
                    st.markdown(f"**ID de Empleado:** `{id_sujeto_checa}`")
                    st.markdown(f"**Departamento:** {emp_data.get('depto', st.session_state.depto)}")
                    st.markdown(f"**Puesto:** {emp_data.get('rol', st.session_state.rol)}")
                    st.markdown(f"**Vence Licencia:** {fmt_fecha(emp_data.get('licencia_vence'))}")
                    st.markdown(f"**Contacto:** {emp_data.get('email', 'No registrado')}")
                    st.markdown(f"**Miembro VPRO desde:** {fmt_fecha(emp_data.get('fecha_ing'))}")
                    
                with c_qr:
                    if qr_b64:
                        st.image(qr_b64, caption="QR de Asistencia", width='stretch')
                        if qr_bytes:
                            st.download_button(label="📥 Descargar QR", data=qr_bytes, file_name=f"QR_VPRO_{id_sujeto_checa}.png", mime="image/png", width='stretch')
                    else:
                        st.error("⚠️ Sin código QR")

            st.markdown("<h4 style='color:#0f172a; margin-top: 15px;'>⏱️ Bitácora de Asistencia (Hoy)</h4>", unsafe_allow_html=True) 
            try:
                res_hoy = requests.get(f"{API_URL}/api/asistencia/reporte", verify=False)
                if res_hoy.status_code == 200:
                    todos_los_registros = res_hoy.json()
                    hoy_str = str(datetime.date.today())
                    
                    registros_hoy = [r for r in todos_los_registros if str(r['id_empleado']).strip() == str(id_sujeto_checa).strip() and str(r['fecha']).startswith(hoy_str)]
                    
                    if registros_hoy:
                        m_in, m_out, v_in, v_out = "--:--", "--:--", "--:--", "--:--"
                        
                        for reg in registros_hoy:
                            h_ent_raw = str(reg.get('hora_entrada', ''))
                            h_sal_raw = str(reg.get('hora_salida', ''))
                            
                            h_ent = h_ent_raw[:5] if h_ent_raw and h_ent_raw != "None" else "--:--"
                            h_sal = h_sal_raw[:5] if h_sal_raw and h_sal_raw != "None" else "--:--"
                            
                            if h_ent != "--:--":
                                try:
                                    if int(h_ent[:2]) < 15:
                                        m_in = h_ent
                                        m_out = h_sal
                                    else:
                                        v_in = h_ent
                                        v_out = h_sal
                                except:
                                    m_in = h_ent
                                    m_out = h_sal
                                    
                        df_hoy = pd.DataFrame([{
                            ("☀️ Turno Matutino", "Entrada"): m_in,
                            ("☀️ Turno Matutino", "Salida"): m_out,
                            ("🌙 Turno Vespertino", "Entrada"): v_in,
                            ("🌙 Turno Vespertino", "Salida"): v_out
                        }])
                        
                        df_hoy.columns = pd.MultiIndex.from_tuples(df_hoy.columns)
                        
                        def resaltar_olvidos_hoy(val):
                            if val == "--:--":
                                return 'color: #9f1239; background-color: #ffe4e6; font-weight: bold;'
                            return ''
                            
                        st.dataframe(df_hoy.style.map(resaltar_olvidos_hoy), width='stretch', hide_index=True)
                    else:
                        st.info("👋 Aún no tienes marcas de asistencia registradas el día de hoy.")
            except Exception as e:
                st.error("No se pudo cargar el historial de hoy.")
        
        with tab_admin:
            user_firma = str(st.session_state.get("usuario_actual", "")).strip().upper()
            user_firma_clean = ''.join(c for c in unicodedata.normalize('NFD', user_firma) if unicodedata.category(c) != 'Mn')
            es_villarreal_directiva = any(x in user_firma_clean for x in ["ANDREA", "SOFIA", "GERARDO", "PEDRO", "ANA LILIA"]) or "VILLAREAL" in user_firma_clean

            if not (es_cuauhtemoc or es_villarreal_directiva or rol_actual == "ADMIN"):
                st.warning("🔒 El panel de auditoría y reportes consolidados es de acceso exclusivo de Dirección.")
            else:
                st.subheader("📊 Historial General Y Auditoría de Tiempos")
                try:
                    res_rep = requests.get(f"{API_URL}/api/asistencia/reporte", verify=False)
                    if res_rep.status_code == 200:
                        df_asist = pd.DataFrame(res_rep.json())
                        if not df_asist.empty:
                            df_asist['fecha'] = pd.to_datetime(df_asist['fecha']).dt.date
                            
                            st.markdown("### 🎯 CAMBIE SI ES NECESARIO Los Parámetros de Consulta de Personal")
                            c_filt1, c_filt2, c_filt3 = st.columns(3)
                            
                            with c_filt1: 
                                rango_asist = c_filt1.date_input("📅 Periodo de Consulta:", [df_asist['fecha'].min(), df_asist['fecha'].max()], key="filtro_fecha_asistencia_admin")
                            with c_filt2:
                                lista_empleados_asist = ["Todos"] + sorted(df_asist['nombre_empleado'].dropna().unique().tolist())
                                emp_asist_sel = c_filt2.selectbox("👤 Seleccionar Empleado:", lista_empleados_asist, key="filtro_emp_asistencia_admin")
                            with c_filt3:
                                lista_estatus = ["Todos"] + sorted(df_asist['estatus'].unique().tolist())
                                est_sel = c_filt3.selectbox("📊 Estatus de Asistencia:", lista_estatus, key="filtro_estatus_asistencia_admin")
                            
                            df_asist_filt = df_asist.copy()
                            if isinstance(rango_asist, (list, tuple)) and len(rango_asist) == 2:
                                df_asist_filt = df_asist_filt[(df_asist_filt['fecha'] >= rango_asist[0]) & (df_asist_filt['fecha'] <= rango_asist[1])]
                            if emp_asist_sel != "Todos":
                                df_asist_filt = df_asist_filt[df_asist_filt['nombre_empleado'] == emp_asist_sel]
                            if est_sel != "Todos":
                                df_asist_filt = df_asist_filt[df_asist_filt['estatus'] == est_sel]
                            
                            st.divider()
                            
                            opcion_formato = st.radio(
                                "Formato de Visualización del Reporte:", 
                                [
                                    "📋 Vista Sábana / Matriz (Estilo Excel)", 
                                    "🗂️ Vista Plana Tradicional (Bitácora)",
                                    "⏱️ Radar de Retardos (Segmentación)"
                                ], 
                                horizontal=True,
                                key="radio_formato_reporte_asistencia"
                            )
                            st.write("")
                            
                            if opcion_formato == "📋 Vista Sábana / Matriz (Estilo Excel)":
                                if not df_asist_filt.empty:
                                    st.markdown("##### 🗂️ Historial de Asistencia por Doble Turno")
                                    
                                    def clean_time(x):
                                        if pd.isna(x) or str(x).strip() in ["", "None", "nan"]: return "--:--"
                                        return str(x)[:5]
                                        
                                    df_base = df_asist_filt.copy()
                                    df_base['Entrada'] = df_base['hora_entrada'].apply(clean_time)
                                    df_base['Salida'] = df_base['hora_salida'].apply(clean_time)
                                    
                                    def define_turno(hora_str):
                                        try:
                                            if int(str(hora_str)[:2]) < 15: return "Matutino"
                                            else: return "Vespertino"
                                        except: return "Matutino"
                                        
                                    df_base['Turno'] = df_base['hora_entrada'].apply(define_turno)
                                    
                                    records = []
                                    for (fecha, id_emp, nom, depto), group in df_base.groupby(['fecha', 'id_empleado', 'nombre_empleado', 'depto']):
                                        m_in, m_out, v_in, v_out = "--:--", "--:--", "--:--", "--:--"
                                        
                                        for _, row in group.iterrows():
                                            if row['Turno'] == "Matutino":
                                                m_in, m_out = row['Entrada'], row['Salida']
                                            else:
                                                v_in, v_out = row['Entrada'], row['Salida']
                                                
                                        fecha_str = fecha.strftime('%d/%m/%Y') if hasattr(fecha, 'strftime') else str(fecha)
                                        
                                        records.append({
                                            ("👤 Datos del Empleado", "Fecha"): fecha_str,
                                            ("👤 Datos del Empleado", "ID"): id_emp,
                                            ("👤 Datos del Empleado", "Nombre"): nom,
                                            ("👤 Datos del Empleado", "Depto"): depto,
                                            ("☀️ Turno Matutino", "Entrada"): m_in,
                                            ("☀️ Turno Matutino", "Salida"): m_out,
                                            ("🌙 Turno Vespertino", "Entrada"): v_in,
                                            ("🌙 Turno Vespertino", "Salida"): v_out
                                        })
                                        
                                    df_final_turnos = pd.DataFrame(records)
                                    
                                    if not df_final_turnos.empty:
                                        df_final_turnos.columns = pd.MultiIndex.from_tuples(df_final_turnos.columns)
                                        df_final_turnos = df_final_turnos.sort_values(by=[("👤 Datos del Empleado", "Fecha"), ("👤 Datos del Empleado", "Nombre")], ascending=[False, True])
                                        
                                        def resaltar_olvidos(val):
                                            if val == "--:--": return 'color: #9f1239; background-color: #ffe4e6; font-weight: bold;'
                                            return ''
                                            
                                        st.dataframe(df_final_turnos.style.map(resaltar_olvidos), width='stretch', hide_index=True)
                                    else:
                                        st.info("📭 No se pudo procesar la matriz de turnos.")
                                else:
                                    st.info("📭 No hay registros que coincidan con los filtros seleccionados.")
                                    
                            elif opcion_formato == "🗂️ Vista Plana Tradicional (Bitácora)":
                                if not df_asist_filt.empty:
                                    st.markdown("##### 🗂️ Edición y Corrección de Bitácoras (Auditoría)")
                                    st.info("💡 Modifica las horas o el Estatus directamente en la tabla y presiona Guardar.")
                                    
                                    df_editable = df_asist_filt[['id_registro', 'fecha', 'id_empleado', 'nombre_empleado', 'depto', 'hora_entrada', 'hora_salida', 'estatus', 'observaciones']].copy()
                                    
                                    def format_hms(val):
                                        if pd.isna(val) or str(val).strip() in ["", "None", "nan"]: return ""
                                        return str(val)[:8]
                                        
                                    df_editable['hora_entrada'] = df_editable['hora_entrada'].apply(format_hms)
                                    df_editable['hora_salida'] = df_editable['hora_salida'].apply(format_hms)
                                    
                                    edited_asist = st.data_editor(
                                        df_editable,
                                        column_config={
                                            "id_registro": None,
                                            "fecha": st.column_config.DateColumn("Fecha", format="DD/MM/YYYY", disabled=True),
                                            "id_empleado": st.column_config.TextColumn("ID", disabled=True),
                                            "nombre_empleado": st.column_config.TextColumn("Nombre", disabled=True),
                                            "depto": st.column_config.TextColumn("Departamento", disabled=True),
                                            "hora_entrada": st.column_config.TextColumn("Entrada"),
                                            "hora_salida": st.column_config.TextColumn("Salida"),
                                            "estatus": st.column_config.SelectboxColumn(
                                                "Estatus", 
                                                options=["ASISTENCIA", "RETARDO", "FALTA", "PERMISO C/SUELDO", "PERMISO S/SUELDO", "VACACIONES", "INCAPACIDAD", "VIAJE DE RUTA"]
                                            ),
                                            "observaciones": st.column_config.TextColumn("Bitácora de Registro")
                                        }, 
                                        width='stretch', hide_index=True, key="editor_asistencia_gerencial"
                                    )
                                    
                                    st.write("")
                                    if st.button("💾 GUARDAR CAMBIOS DE AUDITORÍA", type="primary", width='stretch'):
                                        cambios = []
                                        for idx, row in edited_asist.iterrows():
                                            orig_row = df_editable.iloc[idx]
                                            if (str(row['hora_entrada']) != str(orig_row['hora_entrada']) or str(row['hora_salida']) != str(orig_row['hora_salida']) or str(row['estatus']) != str(orig_row['estatus']) or str(row['observaciones']) != str(orig_row['observaciones'])):
                                                cambios.append({
                                                    "id_registro": int(row['id_registro']),
                                                    "hora_entrada": str(row['hora_entrada']).replace("None", "").strip(),
                                                    "hora_salida": str(row['hora_salida']).replace("None", "").strip(),
                                                    "estatus": str(row['estatus']).strip(),
                                                    "observaciones": str(row['observaciones']).strip()
                                                })
                                                
                                        if cambios:
                                            res_cambios = requests.post(f"{API_URL}/api/asistencia/guardar-cambios", json=cambios, verify=False)
                                            if res_cambios.status_code == 200:
                                                st.success("✅ Cambios guardados y justificados con éxito en el expediente.")
                                                time.sleep(1.5)
                                                st.rerun()
                                            else:
                                                st.error(f"❌ Error al guardar en base de datos: {res_cambios.text}")
                                        else:
                                            st.info("No se detectaron modificaciones en la tabla.")
                                else:
                                    st.info("📭 No hay registros que coincidan con los filtros seleccionados.")
                                    
                            elif "Radar" in opcion_formato:
                                if not df_asist_filt.empty:
                                    st.markdown("##### ⏱️ Personal por Horario de Llegada")
                                    
                                    df_entradas = df_asist_filt.copy()
                                    df_entradas = df_entradas.dropna(subset=['hora_entrada'])
                                    df_entradas = df_entradas.sort_values('hora_entrada').groupby(['fecha', 'nombre_empleado']).first().reset_index()
                                    
                                    def clasificar_llegada(hora_str):
                                        try:
                                            hora_limpia = str(hora_str)[:5]
                                            h, m = map(int, hora_limpia.split(':'))
                                            if h < 9 or (h == 9 and m == 0): return "🟢 09:00 o antes (A tiempo)"
                                            elif h == 9 and 1 <= m <= 5: return "🟡 09:01 a 09:05"
                                            elif h == 9 and 6 <= m <= 10: return "🟠 09:06 a 09:10"
                                            elif h == 9 and 11 <= m <= 15: return "🟠 09:11 a 09:15"
                                            elif h == 9 and 16 <= m <= 20: return "🔴 09:16 a 09:20"
                                            elif h == 9 and 21 <= m <= 25: return "🔴 09:21 a 09:25"
                                            elif h == 9 and 26 <= m <= 30: return "🔴 09:26 a 09:30"
                                            else: return "🔥 Después de las 09:30 (> 30 mins)"
                                        except: return "❓ Error de lectura"
                                            
                                    df_entradas['Rango de Llegada'] = df_entradas['hora_entrada'].apply(clasificar_llegada)
                                    
                                    orden_bloques = ["🟢 09:00 o antes (A tiempo)", "🟡 09:01 a 09:05", "🟠 09:06 a 09:10", "🟠 09:11 a 09:15", "🔴 09:16 a 09:20", "🔴 09:21 a 09:25", "🔴 09:26 a 09:30", "🔥 Después de las 09:30 (> 30 mins)", "❓ Error de lectura"]
                                    
                                    df_agrupado = df_entradas.groupby(['fecha', 'Rango de Llegada'])['nombre_empleado'].apply(lambda x: ', '.join(x)).reset_index()
                                    df_agrupado.columns = ['Fecha', 'Rango de Llegada', 'Personal Registrado']
                                    df_agrupado['Rango de Llegada'] = pd.Categorical(df_agrupado['Rango de Llegada'], categories=orden_bloques, ordered=True)
                                    df_agrupado = df_agrupado.sort_values(['Fecha', 'Rango de Llegada'], ascending=[False, True]).reset_index(drop=True)
                                    df_agrupado = df_agrupado.dropna(subset=['Personal Registrado'])
                                    
                                    st.dataframe(df_agrupado, width='stretch', hide_index=True)
                                else:
                                    st.info("📭 No hay registros matutinos para segmentar en este periodo.")
                        else:
                            st.info("📭 No hay registros de asistencia en la base de datos general.")
                    else:
                        st.error(f"❌ Error del servidor (Código {res_rep.status_code}): No se encontró el endpoint de asistencia.")
                except Exception as e_asist:
                    st.error(f"❌ Fallo crítico al compilar auditoría: {e_asist}")
                    
# 💸 MÓDULO: REPORTE DE GASTOS OPERATIVOS
elif "Reporte de Gastos" in opcion_seleccionada:
    operador = st.session_state.usuario_actual
    id_usuario = str(st.session_state.id_usuario)
    depto_usuario = st.session_state.depto
    rol_usuario = st.session_state.get('role', st.session_state.get('rol', ''))
    nombre_usuario = operador.upper()
    
    es_auditor = rol_usuario in ["ADMIN", "COORDINADOR"] or "ANA" in nombre_usuario or "LILIA" in nombre_usuario
    es_ana_lilia_directiva = "ANA" in nombre_usuario or "LILIA" in nombre_usuario
    
    if es_auditor:
        if es_ana_lilia_directiva or st.session_state.get("folio_auditoria_gastos"):
            tab_auditoria, tab_captura = st.tabs(["🔍 Panel de Auditoría y Aprobación (Ana Lilia)", "📝 Rendición de Cuentas (Productor)"])
        else:
            tab_captura, tab_auditoria = st.tabs(["📝 Rendición de Cuentas (Productor)", "🔍 Panel de Auditoría y Aprobación (Ana Lilia)"])
    else:
        tab_captura, tab_mi_historial = st.tabs(["📝 Rendición de Cuentas (Productor)", "📦 Mis Informes Archivados"])

    # PESTAÑA 1: FORMULARIO DE CAPTURA PARA PRODUCTORES
    with tab_captura:
        st.markdown("### 📝 Registro y Balance de Gastos Operativos")
        cats = ["Hotel", "Transp", "Combust", "Casetas", "Desay", "Comida", "Cenas", "Varios"]
        folios_p = ["--- Seleccionar Folio Pendiente ---"]
        
        try:
            res_fol = requests.get(f"{API_URL}/api/gastos/folios-pendientes", verify=False, timeout=3)
            if res_fol.status_code == 200:
                folios_p += [f"{x['id_evento']} - {x['cliente']} | {x['nombre_evento']}" for x in res_fol.json()]
            else:
                st.caption(f"⚠️ Nota de Caja Chica: No se pudieron indexar folios pendientes (Código {res_fol.status_code}).")
        except Exception as e_gastos: 
            st.caption(f"💡 Módulo financiero: Sincronizando marcas de red... (Detalle: {e_gastos})")

        col1, col2, col3 = st.columns([2, 1, 1])
        sel_folio = col1.selectbox("📋 Seleccione Folio OP a rendir:", options=folios_p, key="gastos_master_folio_sel")
        
        if "---" in sel_folio: 
            st.session_state.panel_vpro_visible = False
        else:
            folio_id = int(sel_folio.split(" - ")[0])
            resp_de_produccion, f_def, p_num = "NO ASIGNADO", datetime.date.today(), 0
            lista_vehiculos_op = []
    
            ev_data = {}
            try:
                res_ev = requests.get(f"{API_URL}/api/gastos/evento/{folio_id}", verify=False)
                if res_ev.status_code == 200:
                    raw_response = res_ev.json()
                    if isinstance(raw_response, list) and len(raw_response) > 0:
                        ev_data = raw_response[0]
                    elif isinstance(raw_response, dict):
                        ev_data = raw_response.get('data') or raw_response.get('evento') or raw_response
            except: 
                pass
        
            ev_clean = {}
            if isinstance(ev_data, dict):
                ev_clean = {k.lower().replace('_', '').replace('-', '').strip(): v for k, v in ev_data.items()}
        
            responsable_api = ev_clean.get('respdeproduccion') or ev_clean.get('productorresponsable') or ev_clean.get('productor') or ev_clean.get('responsable')
            if responsable_api:
                resp_de_produccion = str(responsable_api).strip().upper()
                
            fec_inst = ev_clean.get('fecdeinstalacion') or ev_clean.get('fechainstalacion')
            if fec_inst:
                try: f_def = pd.to_datetime(fec_inst).date()
                except: pass
                
            raw_cars = ev_clean.get('carrosusadosop') or ev_clean.get('carrosusados') or ev_clean.get('carros') or ev_clean.get('vehiculos')
            
            if isinstance(raw_cars, list) and len(raw_cars) == 1 and isinstance(raw_cars[0], str) and raw_cars[0].startswith('{'):
                raw_cars = raw_cars[0]

            if isinstance(raw_cars, list):
                lista_vehiculos_op = raw_cars
            elif isinstance(raw_cars, str) and raw_cars.strip():
                s = raw_cars.strip()
                if s.startswith('{') and s.endswith('}'):
                    s = s[1:-1]
                    import csv
                    try: lista_vehiculos_op = next(csv.reader([s]))
                    except: lista_vehiculos_op = s.split(',')
                elif s.startswith('[') and s.endswith(']'):
                    import json
                    try: lista_vehiculos_op = json.loads(s)
                    except: lista_vehiculos_op = s[1:-1].split(',')
                else:
                    lista_vehiculos_op = s.split(',')

            lista_vehiculos_op = [str(x).replace('"', '').replace('\\', '').strip() for x in lista_vehiculos_op if x]
            if not lista_vehiculos_op: 
                lista_vehiculos_op = ["General"]
                
            raw_personal = ev_clean.get('personalconvocadoop') or ev_clean.get('personal')
            if raw_personal:
                try: p_num = len(raw_personal) if isinstance(raw_personal, list) else len(parsed_array(raw_personal))
                except: p_num = 0
        
            responsable_evento = resp_de_produccion
            responsable_clean = str(responsable_evento).upper().strip()
            usuario_actual_clean = str(st.session_state.usuario_actual).upper().strip()

            if (usuario_actual_clean in responsable_clean) or (responsable_clean in ["", "NONE", "NO ASIGNADO", "NULL"]) or (st.session_state.get('rol') == 'ADMIN'):
                
                f_desde = col2.date_input("📅 Desde:", value=f_def, key=f"f_d_{folio_id}")
                monto_entregado = col3.number_input("💰 Importe Entregado ($):", min_value=0.0, format="%.2f", key=f"m_{folio_id}")

                with st.container(border=True):
                    c_top1, c_top2 = st.columns(2)
                    c_top1.text_input("👤 Empleado que rinde:", value=nombre_usuario, disabled=True, key=f"rep_u_{folio_id}")
                    c_top2.text_input("🏢 Departamento:", value=depto_usuario, disabled=True, key=f"dep_u_{folio_id}")
                    
                    st.markdown("##### 🚗 Registro de Odómetros por Unidad Asignada:")
            
                    dict_km = {}
                    for auto in lista_vehiculos_op:
                        auto_lbl = str(auto).strip().upper()
                        
                        ultimo_km_registrado = 0    # 📡 Consultamos el último KM al servidor para ESTE vehículo en específico
                        try:
                            res_km = requests.get(f"{API_URL}/api/gastos/ultimo-km/{auto_lbl}", verify=False)
                            if res_km.status_code == 200:
                                ultimo_km_registrado = res_km.json().get("ultimo_km", 0)
                        except Exception:
                            pass # Si el servidor no responde o es unidad nueva, se queda en 0
                            
                        c_auto, c_kmini, c_kmfin = st.columns([2, 1.5, 1.5])
                        with c_auto: 
                            st.text_input("Unidad:", value=auto_lbl, disabled=True, key=f"txt_auto_{auto}_{folio_id}")
                        with c_kmini: 
                            ki_val = c_kmini.number_input("🏎️ KM Inicial:", min_value=0, value=ultimo_km_registrado, key=f"ki_{auto}_{folio_id}")
                        with c_kmfin: 
                            kf_val = c_kmfin.number_input("🏁 KM Final:", min_value=0, value=ultimo_km_registrado, key=f"kf_{auto}_{folio_id}")
                        
                        dict_km[auto_lbl] = {"km_i": ki_val, "km_f": kf_val}
                
                    v_txt_detallado = ", ".join([f"{carro} ({data['km_i']}-{data['km_f']})" for carro, data in dict_km.items()])
                    total_km_i = sum([d['km_i'] for d in dict_km.values()])
                    total_km_f = sum([d['km_f'] for d in dict_km.values()])

                num_dias = max((datetime.date.today() - f_desde).days + 1, 1)
                state_key = f"df_buffer_{folio_id}"
        
                if state_key not in st.session_state:
                    dias_es = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]
                    lista_fechas = []
                    for i in range(num_dias):
                        fecha_obj = f_desde + datetime.timedelta(days=i)
                        lista_fechas.append(f"{fecha_obj.strftime('%d/%m')} - {dias_es[fecha_obj.weekday()]}")
                    df_base = pd.DataFrame({"Fecha": lista_fechas, **{c: [0.0]*num_dias for c in cats}, "Total": [0.0]*num_dias})
                    fila_total = pd.DataFrame([["TOTALES"] + [0.0]*(len(cats) + 1)], columns=df_base.columns)
                    st.session_state[state_key] = pd.concat([df_base, fila_total], ignore_index=True)

                with st.form("contenedor_gastos"):
                    df_act = st.data_editor(st.session_state[state_key], width="stretch", hide_index=True, key=f"grid_{folio_id}",
                        column_config={"Fecha": st.column_config.TextColumn(disabled=True), "Total": st.column_config.NumberColumn(format="$%.2f", disabled=True),
                        **{c: st.column_config.NumberColumn(format="$%.2f") for c in cats}})
                    aplicar = st.form_submit_button("🔄 SUMAR TODOS LOS GASTOS ", width='stretch')
            
                if aplicar:
                    datos_reales = df_act.iloc[:-1].copy()
                    
                    for c in cats:
                        datos_reales[c] = pd.to_numeric(datos_reales[c], errors='coerce').fillna(0.0)
                    
                    datos_reales['Total'] = datos_reales[cats].sum(axis=1)
                    sumas_verticales = datos_reales[cats + ['Total']].sum()
                    fila_totales_actualizada = pd.DataFrame([["TOTALES"] + sumas_verticales.tolist()], columns=df_act.columns)
                    
                    st.session_state[state_key] = pd.concat([datos_reales, fila_totales_actualizada], ignore_index=True)
                    st.session_state.panel_vpro_visible = True
                    st.rerun()

                df_actualizado = st.session_state[state_key]
                total_g = float(df_actualizado.iloc[-1]['Total'])
                dif = float(monto_entregado - total_g)

                if st.session_state.get('panel_vpro_visible', False):
                    with st.container(border=True):
                        st.subheader("📄 Validación del Informe")
                        
                        r_temp = {
                            'folio': str(sel_folio), 
                            'nombre': str(resp_de_produccion), 
                            'depto': str(depto_usuario), 
                            'entregado': float(monto_entregado), 
                            'subtotal': float(total_g), 
                            'restante': float(dif), 
                            'km_i': int(total_km_i), 
                            'km_f': int(total_km_f), 
                            'vehiculo': str(v_txt_detallado),
                            'num_personas': int(p_num)
                        }
                        
                        pdf_avance = generar_pdf_gastos(r_temp, df_actualizado)
                        
                        col_v, col_x = st.columns([2, 1])
                        col_v.download_button(label="📥 GENERAR Y DESCARGAR PDF", data=pdf_avance, file_name=f"Informe_Gastos_OP_{folio_id}.pdf", mime="application/pdf", width='stretch')
                        if col_x.button("✖️ OCULTAR REVISIÓN", width='stretch'):
                            st.session_state.panel_vpro_visible = False
                            st.rerun()

                with st.container(border=True):
                    st.markdown("### 📊 Balance Financiero del Proyecto")
                    m1, m2, m3 = st.columns(3)
                    m1.metric("💰 PRESUPUESTO ENTREGADO", f"$ {monto_entregado:,.2f}")
                    m2.metric("💳 TOTAL GASTADO EN SET", f"$ {total_g:,.2f}")
                    m3.metric("⚖️ REMANENTE DEVOLUCIÓN", f"$ {dif:,.2f}", delta=dif, delta_color="normal" if dif >= 0 else "inverse")

                if st.button("💾 ENVIAR INFORME COMPLETO Y ARCHIVAR EVENTO", type="primary", width='stretch', key="btn_save_gastos_final"):
                    payload_gasto = {
                        "maestro": {"folio_vpro": int(folio_id), "id_empleado": str(id_usuario), "periodo_desde": str(f_desde), "periodo_hasta": str(datetime.date.today()), "vehiculo": str(v_txt_detallado), "km_inicial": int(total_km_i), "km_final": int(total_km_f), "departamento": str(depto_usuario), "num_personas": int(p_num), "subtotal": float(total_g), "monto_entregado": float(monto_entregado), "restante": float(dif)},
                        "detalles": []
                    }
                    for idx, row in df_actualizado.iloc[:-1].iterrows():
                        t_dia = float(sum([row[c] for c in cats]))
                        payload_gasto["detalles"].append({"dia_num": int(idx + 1), "hotel": float(row['Hotel']), "transporte": float(row['Transp']), "combustible": float(row['Combust']), "casetas": float(row['Casetas']), "desayuno": float(row['Desay']), "comida": float(row['Comida']), "cenas": float(row['Cenas']), "varios": float(row['Varios']), "total_dia": t_dia})
                    
                    res_save = requests.post(f"{API_URL}/api/gastos/guardar", json=payload_gasto, verify=False)
                    if res_save.status_code == 200:
                        st.success("✅ Informe enviado con éxito. Ana Lilia lo tiene listo para revisión en Auditoría.")
                        st.session_state.panel_vpro_visible = False
                        if f"df_buffer_{folio_id}" in st.session_state: 
                            del st.session_state[f"df_buffer_{folio_id}"]
                        time.sleep(1.5)
                        st.rerun()
                    else: 
                        st.error(f"❌ Error al Actualizar informe: {res_save.text}")
            
            else:
                st.info(f"ℹ️ **Responsable en OP:** {responsable_evento} | **Firmado en Terminal:** {st.session_state.usuario_actual}")
                st.error(f"🚫 **ACCESO RESTRINGIDO:** A esta Orden de Producción le corresponde rendir cuentas a: {responsable_evento}")

    # PESTAÑA 2: EL BUZÓN DE REVISIÓN Y AUDITORÍA DE ANA LILIA
    if es_auditor:
        with tab_auditoria:
            st.markdown("### 🔍 Centro de Control Financiero y Auditoría Exclusiva")
            cats_grid_master = ["Hotel", "Transp", "Combust", "Casetas", "Desay", "Comida", "Cenas", "Varios"]
            
            lista_informes = []
            try:
                res_aud = requests.get(f"{API_URL}/api/gastos/informes-auditoria", verify=False)
                if res_aud.status_code == 200: lista_informes = res_aud.json()
            except: pass
            
            informes_pendientes = [x for x in lista_informes if not x["revisado"]]
            informes_archivados = [x for x in lista_informes if x["revisado"]]
            
            sub_tab_buzon, sub_tab_historial = st.tabs(["📥 Buzón de Entrada (Pendientes)", "📦 Historial de Informes Archivados"])
            
            with sub_tab_buzon:
                if not informes_pendientes:
                    st.success("🎉 ¡Felicidades Ana Lilia! Operación limpia: No tienes informes pendientes por auditar.")
                else:
                    mapa_pendientes = {}
                    opciones_pendientes = []
                    
                    # 🚀 EFECTO TELETRANSPORTE: Atrapamos el folio de la memoria
                    folio_objetivo = st.session_state.get("folio_auditoria_gastos")
                    idx_pre_select = 0
                    
                    for i, inf in enumerate(informes_pendientes):
                        lbl = f"⚠️ Informe #{inf['id_informe']} | OP-{inf['folio_vpro']} - {inf['nombre_evento']} ({inf['nombre_empleado']})"
                        opciones_pendientes.append(lbl)
                        mapa_pendientes[lbl] = inf['id_informe']
                        
                        # Si coincide con el que le dio click Ana Lilia en el menú, guardamos su número de fila
                        if folio_objetivo and str(inf['folio_vpro']) == str(folio_objetivo):
                            idx_pre_select = i
                    
                    sel_p = st.selectbox("📥 Selecciona el informe entrante para calificar:", options=opciones_pendientes, index=idx_pre_select, key="audit_pendientes_selectbox")
                    id_p_sel = mapa_pendientes[sel_p]
                    
                    # Limpiamos la memoria
                    if st.session_state.get("folio_auditoria_gastos"):
                        del st.session_state["folio_auditoria_gastos"]
                    
                    try:
                        res_comp = requests.get(f"{API_URL}/api/gastos/informe-completo/{id_p_sel}", verify=False)
                        if res_comp.status_code == 200:
                            exp = res_comp.json()
                            mae = exp["maestro"]
                            det = exp["detalles"]
                            
                            c_inf1, c_inf2 = st.columns(2)
                            with c_inf1:
                                with st.container(border=True):
                                    st.markdown(f"**Productor:** {mae['nombre_empleado']}")
                                    st.markdown(f"**Departamento:** {mae['departamento']}")
                                    st.markdown(f"**Periodo:** Del `{mae['periodo_desde']}` al `{mae['periodo_hasta']}`")
                            with c_inf2:
                                with st.container(border=True):
                                    st.markdown(f"**Flota:** {mae['vehiculo']}")
                                    st.markdown(f"**Kilometraje:** Inicial: `{mae['km_inicial']:,}` KM | Final: `{mae['km_final']:,}` KM")
                                    st.markdown("**Estatus de Auditoría:** `⚖️ EN REVISIÓN DIARIA`")
                            
                            m_aud1, m_aud2, m_aud3 = st.columns(3)
                            m_aud1.metric("💰 PRESUPUESTO ENTREGADO", f"$ {mae['monto_entregado']:,.2f}")
                            m_aud2.metric("💳 COMPROBADO EN SET", f"$ {mae['subtotal']:,.2f}")
                            m_aud3.metric("⚖️ REMANENTE DEVOLUCIÓN", f"$ {mae['restante']:,.2f}", delta=mae['restante'])
                            
                            st.markdown("##### 📊 Desglose Diario Comprobado:")
                            rows_tabla_audit = []
                            for d in det:
                                rows_tabla_audit.append({"Fecha": f"Día {d['dia_num']}", "Hotel": d['hotel'], "Transp": d['transporte'], "Combust": d['combustible'], "Casetas": d['casetas'], "Desay": d['desayuno'], "Comida": d['comida'], "Cenas": d['cenas'], "Varios": d['varios'], "Total": d['total_dia']})
                            df_audit_view = pd.DataFrame(rows_tabla_audit)
                            st.dataframe(df_audit_view, width='stretch', hide_index=True, column_config={"Total": st.column_config.NumberColumn(format="$%.2f"), **{c: st.column_config.NumberColumn(format="$%.2f") for c in cats_grid_master}})
                            
                            st.divider()
                            c_btn1, c_btn2 = st.columns([2, 1])
                            r_temp_pdf = {'folio': f"OP-{mae['folio_vpro']}", 'nombre': str(mae['nombre_empleado']), 'depto': str(mae['departamento']), 'entregado': float(mae['monto_entregado']), 'subtotal': float(mae['subtotal']), 'restante': float(mae['restante']), 'km_i': int(mae['km_inicial']), 'km_f': int(mae['km_final']), 'vehiculo': str(mae['vehiculo']), 'num_personas': int(mae.get('num_personas', 0))}
                            pdf_auditoria = generar_pdf_gastos(r_temp_pdf, df_audit_view)
                            
                            c_btn1.download_button(label="📥 IMPRIMIR / DESCARGAR REPORTE OFICIAL PDF", data=pdf_auditoria, file_name=f"Validacion_Gastos_OP_{mae['folio_vpro']}.pdf", mime="application/pdf", width='stretch', key=f"dl_btn_p_{mae['id_informe']}")
                            
                            if c_btn2.button("✅ MARCAR COMO REVISADO Y APROBADO", type="primary", width='stretch', key=f"chk_btn_p_{mae['id_informe']}"):
                                if requests.post(f"{API_URL}/api/gastos/revisar/{id_p_sel}", verify=False).status_code == 200:
                                    st.success("🔒 Sello de Auditoría Aplicado. Cuenta Saldada con éxito.")
                                    time.sleep(1.2); st.rerun()
                    except Exception as e: st.error(f"❌ Error al cargar expediente: {e}")

            with sub_tab_historial:
                if not informes_archivados:
                    st.info("💡 Aún no existen informes históricos archivados en este periodo.")
                else:
                    mapa_archivados = {}
                    options_archivados = []
                    for inf in informes_archivados:
                        lbl = f"📦 ID #{inf['id_informe']} | OP-{inf['folio_vpro']} - {inf['nombre_evento']} ({inf['nombre_empleado']})"
                        options_archivados.append(lbl)
                        mapa_archivados[lbl] = inf['id_informe']
                    
                    sel_h = st.selectbox("🔍 Consultar Historial Clínico de Gastos (Solo Lectura):", options=options_archivados, key="audit_archivados_selectbox")
                    id_h_sel = mapa_archivados[sel_h]
                    
                    try:
                        res_comp_h = requests.get(f"{API_URL}/api/gastos/informe-completo/{id_h_sel}", verify=False)
                        if res_comp_h.status_code == 200:
                            exp_h = res_comp_h.json()
                            mae_h = exp_h["maestro"]
                            det_h = exp_h["detalles"]
                            
                            with st.container(border=True):
                                c_h1, c_h2, c_h3 = st.columns(3)
                                c_h1.markdown(f"**Productor:**\n{mae_h['nombre_empleado']}")
                                c_h2.markdown(f"**Periodo:**\n`{mae_h['periodo_desde']}` al `{mae_h['periodo_hasta']}`")
                                c_h3.markdown(f"**Estatus Digital:**\n`🔒 ARCHIVADO CONTABLE`")
                            
                            mh1, mh2, mh3 = st.columns(3)
                            mh1.metric("💰 PRESUPUESTO ORIGINAL", f"$ {mae_h['monto_entregado']:,.2f}")
                            mh2.metric("💳 TOTAL COMPROBADO", f"$ {mae_h['subtotal']:,.2f}")
                            mh3.metric("⚖️ REMANENTE DEVUELTO", f"$ {mae_h['restante']:,.2f}")
                            
                            rows_tabla_h = []
                            for d in det_h:
                                rows_tabla_h.append({"Fecha": f"Día {d['dia_num']}", "Hotel": d['hotel'], "Transp": d['transporte'], "Combust": d['combustible'], "Casetas": d['casetas'], "Desay": d['desayuno'], "Comida": d['comida'], "Cenas": d['cenas'], "Varios": d['varios'], "Total": d['total_dia']})
                            df_h_view = pd.DataFrame(rows_tabla_h)
                            
                            # 🚀 TABLA INTELIGENTE: Editable si es Ana Lilia, bloqueada si es otro.
                            df_h_editado = st.data_editor(
                                df_h_view, 
                                width='stretch', 
                                hide_index=True, 
                                disabled=not es_ana_lilia_directiva, 
                                column_config={"Total": st.column_config.NumberColumn(format="$%.2f", disabled=True), "Fecha": st.column_config.TextColumn(disabled=True), **{c: st.column_config.NumberColumn(format="$%.2f") for c in cats_grid_master}},
                                key=f"editor_historial_admin_{id_h_sel}"
                            )
                            
                            # 🚀 BOTÓN DE GUARDADO DINÁMICO (Solo aparece si Ana Lilia modificó algo)
                            if es_ana_lilia_directiva and not df_h_editado.equals(df_h_view):
                                st.warning("⚠️ Modificaste los montos. Guarda los cambios para recalcular los totales en la base de datos.")
                                if st.button("💾 GUARDAR CORRECCIONES AL HISTÓRICO", type="primary", width='stretch'):
                                    payload_mod = {"id_informe": id_h_sel, "detalles": []}
                                    for idx_mod, row_mod in df_h_editado.iterrows():
                                        t_dia = float(sum([pd.to_numeric(row_mod[c], errors='coerce') for c in cats_grid_master]))
                                        payload_mod["detalles"].append({
                                            "dia_num": int(str(row_mod['Fecha']).replace("Día ", "")),
                                            "hotel": float(row_mod['Hotel']), "transporte": float(row_mod['Transp']), 
                                            "combustible": float(row_mod['Combust']), "casetas": float(row_mod['Casetas']), 
                                            "desayuno": float(row_mod['Desay']), "comida": float(row_mod['Comida']), 
                                            "cenas": float(row_mod['Cenas']), "varios": float(row_mod['Varios']), 
                                            "total_dia": t_dia
                                        })
                                    res_mod = requests.post(f"{API_URL}/api/gastos/modificar-historico", json=payload_mod, verify=False)
                                    if res_mod.status_code == 200:
                                        st.success("✅ Histórico corregido y recalculado con éxito.")
                                        time.sleep(1.5)
                                        st.rerun()
                                    else:
                                        st.error(f"❌ Error al modificar: {res_mod.text}")

                            r_temp_h_pdf = {'folio': f"OP-{mae_h['folio_vpro']}", 'nombre': str(mae_h['nombre_empleado']), 'depto': str(mae_h['departamento']), 'entregado': float(mae_h['monto_entregado']), 'subtotal': float(mae_h['subtotal']), 'restante': float(mae_h['restante']), 'km_i': int(mae_h['km_inicial']), 'km_f': int(mae_h['km_final']), 'vehiculo': str(mae_h['vehiculo']), 'num_personas': int(mae_h.get('num_personas', 0))}
                            pdf_h_auditoria = generar_pdf_gastos(r_temp_h_pdf, df_h_editado) # Usa el editado para el PDF en tiempo real
                            
                            st.download_button(label="🖨️ VOLVER A IMPRIMIR PDF OFICIAL ARCHIVADO", data=pdf_h_auditoria, file_name=f"Cierre_Gastos_Archivado_OP_{mae_h['folio_vpro']}.pdf", mime="application/pdf", width='stretch', key=f"dl_btn_h_{mae_h['id_informe']}")
                    except Exception as e: st.error(f"❌ Error al jalar registro histórico: {e}")
    # 🚀 BÓVEDA EXCLUSIVA PARA PRODUCTORES
    if not es_auditor:
        with tab_mi_historial:
            st.markdown("### 📦 Mis Informes Archivados")
            lista_mis_informes = []
            try:
                res_aud = requests.get(f"{API_URL}/api/gastos/informes-auditoria", verify=False)
                if res_aud.status_code == 200: 
                    # Filtramos solo los revisados que le pertenezcan a este usuario
                    lista_mis_informes = [x for x in res_aud.json() if x["revisado"] and str(x["nombre_empleado"]).strip().upper() == nombre_usuario]
            except: pass
            
            if not lista_mis_informes:
                st.info("💡 Aún no tienes informes históricos archivados por Dirección.")
            else:
                mapa_mis_arch = {}
                options_mis_arch = []
                for inf in lista_mis_informes:
                    lbl = f"📦 ID #{inf['id_informe']} | OP-{inf['folio_vpro']} - {inf['nombre_evento']}"
                    options_mis_arch.append(lbl)
                    mapa_mis_arch[lbl] = inf['id_informe']
                
                sel_m = st.selectbox("🔍 Selecciona tu informe:", options=options_mis_arch, key="mis_arch_selectbox")
                id_m_sel = mapa_mis_arch[sel_m]
                
                try:
                    res_comp_m = requests.get(f"{API_URL}/api/gastos/informe-completo/{id_m_sel}", verify=False)
                    if res_comp_m.status_code == 200:
                        exp_m = res_comp_m.json()
                        mae_m = exp_m["maestro"]
                        det_m = exp_m["detalles"]
                        
                        with st.container(border=True):
                            c_m1, c_m2, c_m3 = st.columns(3)
                            c_m1.markdown(f"**Periodo:**\n`{mae_m['periodo_desde']}` al `{mae_m['periodo_hasta']}`")
                            c_m2.markdown(f"**Estatus Digital:**\n`🔒 ARCHIVADO CONTABLE`")
                            c_m3.markdown(f"**Vehículo:**\n{mae_m['vehiculo']}")
                        
                        mm1, mm2, mm3 = st.columns(3)
                        mm1.metric("💰 PRESUPUESTO ORIGINAL", f"$ {mae_m['monto_entregado']:,.2f}")
                        mm2.metric("💳 TOTAL COMPROBADO", f"$ {mae_m['subtotal']:,.2f}")
                        mm3.metric("⚖️ REMANENTE DEVUELTO", f"$ {mae_m['restante']:,.2f}")
                        
                        rows_tabla_m = []
                        cats_grid_master = ["Hotel", "Transp", "Combust", "Casetas", "Desay", "Comida", "Cenas", "Varios"]
                        for d in det_m:
                            rows_tabla_m.append({"Fecha": f"Día {d['dia_num']}", "Hotel": d['hotel'], "Transp": d['transporte'], "Combust": d['combustible'], "Casetas": d['casetas'], "Desay": d['desayuno'], "Comida": d['comida'], "Cenas": d['cenas'], "Varios": d['varios'], "Total": d['total_dia']})
                        
                        df_m_view = pd.DataFrame(rows_tabla_m)
                        st.dataframe(df_m_view, width='stretch', hide_index=True, column_config={"Total": st.column_config.NumberColumn(format="$%.2f"), **{c: st.column_config.NumberColumn(format="$%.2f") for c in cats_grid_master}})
                        
                        r_temp_m_pdf = {'folio': f"OP-{mae_m['folio_vpro']}", 'nombre': str(mae_m['nombre_empleado']), 'depto': str(mae_m['departamento']), 'entregado': float(mae_m['monto_entregado']), 'subtotal': float(mae_m['subtotal']), 'restante': float(mae_m['restante']), 'km_i': int(mae_m['km_inicial']), 'km_f': int(mae_m['km_final']), 'vehiculo': str(mae_m['vehiculo']), 'num_personas': int(mae_m.get('num_personas', 0))}
                        pdf_m_auditoria = generar_pdf_gastos(r_temp_m_pdf, df_m_view)
                        
                        st.download_button(label="🖨️ DESCARGAR MI PDF OFICIAL ARCHIVADO", data=pdf_m_auditoria, file_name=f"Mi_Cierre_Gastos_OP_{mae_m['folio_vpro']}.pdf", mime="application/pdf", width='stretch', key=f"dl_btn_m_{mae_m['id_informe']}")
                except Exception as e: st.error(f"❌ Error al cargar tu historial: {e}")
                    
# 📈 MÓDULO: ANALÍTICA Y KPIs DIRECTIVOS
elif "Analítica" in opcion_seleccionada:
    st.markdown("""
        <div style="background-color: #0f172a; padding: 20px; border-radius: 10px; border-left: 8px solid #3b82f6; margin-bottom: 25px;">
            <h2 style="margin: 0; color: #ffffff;">📈 Centro de Inteligencia y KPIs Directivos</h2>
            <p style="margin: 0; color: #94a3b8;">Monitoreo en tiempo real del rendimiento operativo y disciplina del personal.</p>
        </div>
    """, unsafe_allow_html=True)
    
    tab_rrhh, tab_finanzas = st.tabs(["👥 KPIs Recursos Humanos", "💸 KPIs (Próximamente)"])
    
    with tab_rrhh:
        st.markdown("### 🎯 Rendimiento del Reloj Checador")
        try:
            res_rep = requests.get(f"{API_URL}/api/asistencia/reporte", verify=False)
            if res_rep.status_code == 200 and res_rep.json():
                df_kpi = pd.DataFrame(res_rep.json())
                df_kpi['fecha'] = pd.to_datetime(df_kpi['fecha']).dt.date
                
                # Filtro global de fechas para el Dashboard
                c_f1, c_f2 = st.columns([1, 3])
                rango_kpi = c_f1.date_input("📅 Mes a evaluar:", [df_kpi['fecha'].min(), df_kpi['fecha'].max()], key="kpi_date_range")
                
                if isinstance(rango_kpi, (list, tuple)) and len(rango_kpi) == 2:
                    df_kpi = df_kpi[(df_kpi['fecha'] >= rango_kpi[0]) & (df_kpi['fecha'] <= rango_kpi[1])]
                
                if not df_kpi.empty:
                    # Clasificamos Estatus para las gráficas
                    df_kpi['estatus_kpi'] = df_kpi.apply(
                        lambda r: 'Falta' if str(r['estatus']) == 'FALTA' 
                        else ('Sin Salida' if pd.isna(r['hora_salida']) or str(r['hora_salida']).strip() == "" 
                        else 'Ciclo Completo'), axis=1
                    )
                    
                    st.divider()
                    c_graf1, c_graf2 = st.columns(2)
                    
                    # 🍩 GRÁFICO 1: Salud de la Terminal (Dono)
                    with c_graf1:
                        resumen_global = df_kpi['estatus_kpi'].value_counts().reset_index()
                        resumen_global.columns = ['Estatus', 'Cantidad']
                        fig_donut = px.pie(
                            resumen_global, values='Cantidad', names='Estatus', hole=0.5, 
                            color='Estatus', color_discrete_map={'Ciclo Completo':'#10b981', 'Sin Salida':'#f59e0b', 'Falta':'#ef4444'},
                            title="Porc. de Personal que realiza correctamente sus Ent/Sal"
                        )
                        fig_donut.update_traces(textposition='inside', textinfo='percent+label')
                        st.plotly_chart(fig_donut, width='stretch')
                    
                    # 📊 GRÁFICO 2: Top Omisiones (Muro de la Vergüenza)
                    with c_graf2:
                        df_omisiones = df_kpi[df_kpi['estatus_kpi'] == 'Sin Salida']
                        if not df_omisiones.empty:
                            conteo_omisiones = df_omisiones['nombre_empleado'].value_counts().reset_index()
                            conteo_omisiones.columns = ['Empleado', 'Omisiones']
                            fig_barras = px.bar(
                                conteo_omisiones.head(10), x='Omisiones', y='Empleado', orientation='h',
                                title="Empleados que olvidan o no realizaron chequeo completo Ent/Sal (9-2 y 4-7)",
                                color='Omisiones', 
                                color_continuous_scale=['#fb923c', '#ef4444', '#7f1d1d']
                            )
                            fig_barras.update_layout(yaxis={'categoryorder':'total ascending'})
                            st.plotly_chart(fig_barras, width='stretch')
                        else:
                            st.success("🎉 ¡Excelente! No hay omisiones de salida en este periodo.")

                    df_asistencia = df_kpi[df_kpi['estatus_kpi'] != 'Falta'] # 📈 GRÁFICO 3: Tendencia de Asistencia
                    if not df_asistencia.empty:
                        tendencia_diaria = df_asistencia.groupby('fecha').size().reset_index(name='Asistencias')
                        tendencia_diaria['fecha_str'] = pd.to_datetime(tendencia_diaria['fecha']).dt.strftime('%d/%b')
                        
                        fig_lineas = px.line(
                            tendencia_diaria, x='fecha_str', y='Asistencias', markers=True,
                            title="personal que checó/Se presentó a la oficina.(por dia)", line_shape='spline'
                        )
                        fig_lineas.update_traces(line_color="#0ea5e9", marker=dict(size=8, color="#0284c7"))
                        fig_lineas.update_layout(xaxis_title="Día", yaxis_title="Personas")
                        st.plotly_chart(fig_lineas, width='stretch')
                else:
                    st.info("No hay datos en el rango de fechas seleccionado.")
        except Exception as e:
            st.error(f"Error al cargar KPIs de RRHH: {e}")

    # 💸 INYECCIÓN DEL NUEVO MÓDULO FINANCIERO
    # 💸 INYECCIÓN DEL NUEVO MÓDULO FINANCIERO Y AUDITORÍA DE FLOTA
    with tab_finanzas:
        st.markdown("### 💸 Monitor de Viáticos y Caja Chica")
        st.caption("Los datos mostrados a continuación provienen **exclusivamente** de los informes de gastos que ya han sido revisados, conciliados y archivados por el área de Auditoría.")
        
        # 1. Obtener lista de clientes reales para el filtro
        lista_clientes_fin = ["Todos"]
        try:
            res_cli_fin = requests.get(f"{API_URL}/api/clientes", verify=False)
            if res_cli_fin.status_code == 200:
                lista_clientes_fin += sorted([c["cliente_empresa"] for c in res_cli_fin.json()])
        except: pass

        c_fin1, c_fin2, c_fin3 = st.columns([1.5, 1.5, 2])
        # Filtros de Dashboard
        rango_fin = c_fin1.date_input("📅 Periodo a Consultar:", [datetime.date.today() - datetime.timedelta(days=30), datetime.date.today()], key="fin_date_range")
        cliente_fin = c_fin2.selectbox("🏢 Filtrar por Cliente:", options=lista_clientes_fin, key="fin_client_sel")
        
        if isinstance(rango_fin, (list, tuple)) and len(rango_fin) == 2:
            fecha_i, fecha_f = rango_fin[0], rango_fin[1]
            
            import urllib.parse
            cliente_codificado = urllib.parse.quote(cliente_fin)
            
            with st.spinner("📊 Analizando libros contables y rendimientos vehiculares..."):
                try:
                    # Hacemos la consulta inyectando el filtro del cliente
                    res_fin = requests.get(f"{API_URL}/api/analitica/kpis-financieros?desde={fecha_i}&hasta={fecha_f}&cliente={cliente_codificado}", verify=False)
                    if res_fin.status_code == 200 and res_fin.json().get("status") == "SUCCESS":
                        data_fin = res_fin.json()
                        t = data_fin["totales"]
                        avg = data_fin.get("promedios", {})
                        
                        st.divider()
                        m_f1, m_f2, m_f3, m_f4, m_f5 = st.columns(5)
                        m_f1.metric("💰 PTO. INYECTADO", f"${t['entregado']:,.2f}")
                        m_f2.metric("💳 GASTO REAL", f"${t['gastado']:,.2f}")
                        
                        color_rem = "normal" if t['remanente'] >= 0 else "inverse"
                        m_f3.metric("⚖️ RETORNADO", f"${t['remanente']:,.2f}", delta=f"{(t['remanente']/t['entregado']*100):.1f}% de recup." if t['entregado'] > 0 else "0%", delta_color=color_rem)
                        
                        # NUEVAS TARJETAS: Rentabilidad Promedio
                        m_f4.metric("🎫 COSTO X EVENTO", f"${avg.get('costo_por_evento', 0):,.2f}")
                        m_f5.metric("📆 GASTO X DÍA", f"${avg.get('costo_por_dia', 0):,.2f}")
                        
                        st.write("")
                        g_f1, g_f2 = st.columns(2)
                        
                        with g_f1:
                            st.markdown(f"##### 🍕 Distribución del Gasto Operativo {'(Global)' if cliente_fin == 'Todos' else f'({cliente_fin})'}")
                            df_desglose = pd.DataFrame(data_fin["desglose"])
                            if not df_desglose.empty:
                                fig_pie = px.pie(df_desglose, values='Monto', names='Categoria', hole=0.4, color_discrete_sequence=px.colors.qualitative.Pastel)
                                fig_pie.update_traces(textposition='inside', textinfo='percent+label')
                                # Le escondemos la leyenda de lado para que se vea más limpia
                                fig_pie.update_layout(margin=dict(t=10, b=10, l=10, r=10), showlegend=False)
                                st.plotly_chart(fig_pie, width='stretch')
                            else:
                                st.info("📭 No hay gastos registrados en este cruce de filtros.")
                                
                        with g_f2:
                            st.markdown("##### 🏆 Clientes de Mayor Consumo de Viáticos")
                            df_cli = pd.DataFrame(data_fin["top_clientes"])
                            if not df_cli.empty:
                                fig_bar = px.bar(
                                    df_cli, 
                                    x='Gasto', 
                                    y='Cliente', 
                                    orientation='h', 
                                    color='Cliente', 
                                    color_discrete_sequence=px.colors.qualitative.Vivid
                                )
                                fig_bar.update_traces(texttemplate='<b>$%{x:,.2f}</b>', textposition='auto', showlegend=False)
                                fig_bar.update_layout(
                                    yaxis={'categoryorder':'total ascending', 'title': ''}, 
                                    xaxis={'title': 'Dinero Gastado ($)'},
                                    margin=dict(t=10, b=10, l=10, r=40)
                                )
                                st.plotly_chart(fig_bar, width='stretch')
                            else:
                                st.info("📭 No hay proyectos auditados en este rango de fechas.")
                                
                        # 🚗 NUEVA SECCIÓN: AUDITORÍA DE FLOTA VEHICULAR
                        st.write("---")
                        st.markdown(f"##### 🚗 Auditoría de Flota: Desgaste vs Rendimiento de Combustible")
                        
                        df_flota = pd.DataFrame(data_fin.get("flota", []))
                        if not df_flota.empty:
                            c_fl1, c_fl2 = st.columns(2)
                            
                            with c_fl1:
                                fig_km = px.bar(df_flota, x='KM_Recorridos', y='Vehiculo', orientation='h', text='KM_Recorridos', color='KM_Recorridos', color_continuous_scale='Blues', title="Desgaste por Unidad (KM Recorridos)")
                                fig_km.update_traces(texttemplate='%{text:,.0f} KM', textposition='outside')
                                fig_km.update_layout(yaxis={'categoryorder':'total ascending', 'title': ''}, xaxis_title="Kilómetros", margin=dict(t=30, b=10, l=10, r=40))
                                st.plotly_chart(fig_km, width='stretch')
                            
                            with c_fl2:
                                # Aquí mapeamos el color en base al "Costo_por_KM" (rojo = alerta de fuga)
                                fig_gas = px.bar(df_flota, x='Costo_Combustible', y='Vehiculo', orientation='h', text='Costo_Combustible', hover_data=['Costo_por_KM'], color='Costo_por_KM', color_continuous_scale='Reds', title="Costo de Gasolina ($) y Alertas de Rendimiento")
                                fig_gas.update_traces(texttemplate='$%{text:,.2f}', textposition='outside', hovertemplate='Gasto Gasolina: $%{x:,.2f}<br>Costo Promedio: $%{customdata[0]:,.2f} x KM')
                                fig_gas.update_layout(yaxis={'categoryorder':'total ascending', 'title': ''}, xaxis_title="Gasto en Combustible ($)", margin=dict(t=30, b=10, l=10, r=40))
                                st.plotly_chart(fig_gas, width='stretch')
                        else:
                            st.info("📭 No hay vehículos con kilometraje o gasolina registrada en este periodo.")

                    else:
                        st.error(f"Error al procesar la contabilidad de Postgres: {res_fin.json().get('detail', 'Desconocido')}")
                except Exception as e:
                    st.error(f"📡 Error de enlace con motor analítico: {e}")
                    
# 📯 CONDICIONAL EXCEPCIONAL FINAL DEL PERÍMETRO VPRO
else:
    st.warning("🚧 Selección en desarrollo o módulo no interpretado.")