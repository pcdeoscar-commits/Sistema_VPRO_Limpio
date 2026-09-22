# 🖥️ VPRO SYSTEM - FRONTEND SHELL (STREAMLIT MASTER DASHBOARD V7.9.4)
import streamlit as st
import requests
import datetime
import pandas as pd
import unicodedata
import time
import os
import base64

from modulos_prueba import mod_autos, mod_eventos, mod_kiosco, mod_checkout, mod_incidencias, mod_empleados, mod_clientes, mod_inventario, mod_proveedores, mod_reporte_gastos, mod_equipos_danados,mod_analitica_kpis, mod_manual, mod_reuniones,mod_reporte_asistencia, mod_cotizaciones

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

def renderizar_notificaciones(API_URL):
    st.markdown("### 🔔 Centro de Notificaciones")
    
    id_empleado = st.session_state.get("id_usuario", "")
    nombre_usuario = st.session_state.get("usuario_actual", "")
    
    if not id_empleado or not nombre_usuario:
        st.warning("Datos de sesión no encontrados para cargar notificaciones.")
        return

    try:
        url_pendientes = f"{API_URL}/api/checkout/pendientes/{id_empleado}/{nombre_usuario}"
        respuesta = requests.get(url_pendientes, verify=False)
        
        if respuesta.status_code == 200:
            ops_pendientes = respuesta.json()
            total_pendientes = len(ops_pendientes)
            
            if total_pendientes > 0:
                with st.expander(f"📦 Tienes {total_pendientes} Órdenes Pendientes de Bodega (Checkout)", expanded=True):
                    for op in ops_pendientes:
                        col1, col2 = st.columns([4, 1])
                        
                        with col1:
                            st.warning(f"⚠️ **{op['label']}** | Estatus actual: `{op['estado']}`")
                            
                        with col2:
                            if st.button("📝 ELABORAR", key=f"btn_inicio_{op['id_evento']}", use_container_width=True):
                                st.session_state["menu_dinamico"] = "📦 Checkout [VPF-PSP-CHL]" 
                                st.session_state["op_preseleccionada"] = op['id_evento'] 
                                st.rerun()
            else:
                with st.expander("✅ Radar de Bodega: 100% de Checkouts al día (Operación Limpia)"):
                    st.success("No tienes órdenes pendientes por sacar de bodega. ¡Excelente trabajo!")
                    
    except Exception as e:
        st.error(f"Error al cargar las notificaciones: {e}")

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
    sig_data = [[Paragraph(f"_____________________________________<br/><b>{r_temp['nombre']}</b><br/>Productor Responsable", sig_style),
                 Paragraph("_____________________________________<br/><b>ANA LILIA VILLARREAL URIBE</b><br/>Auditoría Administration", sig_style)
               ]]
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
        menu_opciones.append("🤝 Reuniones / Prospectos")
        menu_opciones.append("🚙 Autos")
        
    menu_opciones.append("🛠️ Inventario")
        
    if rol_actual == "ADMIN":
        menu_opciones.extend(["🦺 Empleados", "🚚 Proveedores", "🏢 Clientes", "⏱️ Auditoría Asistencia", "📄 Cotizaciones"])
            
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
    
    if opcion_seleccionada != st.session_state.menu_dinamico:
        st.session_state.menu_dinamico = opcion_seleccionada
        st.rerun()
    
    st.write("---") # Para poner una línea que separe el menú de los botones

    if st.button("❓Ayuda / Manual Completo", use_container_width=True):
        mod_manual.mostrar_manual_popup()
    
    # Este es el botón de cerrar sesión que ya tenías
    if st.button("🚪 Cerrar Sesión", width='stretch'):
        st.session_state.clear()
        st.rerun()
                        
st.header(f"{opcion_seleccionada}")
st.write("---")

# 🔀 ENRUTADOR PRINCIPAL (El "Switch" de Módulos)
if opcion_seleccionada == "🏠 Inicio":
    st.info("🏠 Bienvenido al Laboratorio de Pruebas VPRO. Selecciona un módulo en el menú izquierdo.")
    
    renderizar_notificaciones(API_URL)
    st.write("---")

    st.markdown("<h4 style='color:#0f172a; margin-top: 25px;'>⏱️ Mi Asistencia de Hoy</h4>", unsafe_allow_html=True)
    try:
        import pandas as pd
        import datetime
        
        id_usr = str(st.session_state.get("id_usuario", ""))
        nom_usr = str(st.session_state.get("usuario_actual", ""))
            
        res_hoy = requests.get(f"{API_URL}/api/asistencia/reporte", verify=False)
        res_loc = requests.get(f"{API_URL}/api/asistencia/locacion/hoy/{nom_usr}", verify=False)
            
        registros_oficina = []
        registros_locacion = []
            
        if res_hoy.status_code == 200:
            hoy_str = str(datetime.date.today())
            registros_oficina = [r for r in res_hoy.json() if str(r['id_empleado']).strip() == id_usr.strip() and str(r['fecha']).startswith(hoy_str)]
            
        if res_loc.status_code == 200:
            registros_locacion = res_loc.json()

        if registros_oficina or registros_locacion:
            def limpia_hora(h_raw):
                h_str = str(h_raw).strip()
                if h_str in ["", "None", "null", "00:00:00", "00:00", "0:00"]: return "--:--"
                return h_str[:5]

            m_in, m_out, v_in, v_out = "--:--", "--:--", "--:--", "--:--"
            nota_viaje = ""
            tiene_fisico = False

            # 1️⃣ Primero cargamos lo del CHECADOR FÍSICO (Nuestra verdad absoluta)
            if registros_oficina:
                reg = registros_oficina[0]
                m_in = limpia_hora(reg.get('hora_entrada'))
                m_out = limpia_hora(reg.get('hora_salida'))
                v_in = limpia_hora(reg.get('hora_entrada_v'))
                v_out = limpia_hora(reg.get('hora_salida_v'))
                    
                # Si tiene al menos un registro real, activamos la bandera de protección
                if m_in != "--:--" or m_out != "--:--" or v_in != "--:--" or v_out != "--:--":
                        tiene_fisico = True

                # 2️⃣ Verificamos la LOCACIÓN FORÁNEA
            if registros_locacion:
                reg_loc = registros_locacion[0]
                    
                # Si el empleado está completamente EN BLANCO en la oficina, tomamos la gira
                if not tiene_fisico:
                    m_in = limpia_hora(reg_loc.get('hora_entrada'))
                    m_out = limpia_hora(reg_loc.get('hora_salida'))
                    nota_viaje = reg_loc.get('evento_str', 'Gira / Locación')
                else:
                    # Si SÍ checó físicamente aunque sea una vez, no mezclamos datos
                    nota_viaje = "⚠️ Estás en una lista de gira, pero tus horas oficiales son las del Checador Físico de base."

            # 3️⃣ Dibujamos LA ÚNICA TABLA
            df_hoy = pd.DataFrame([{
                ("☀️ Turno Matutino", "Entrada"): m_in,
                ("☀️ Turno Matutino", "Salida"): m_out,
                ("🌙 Turno Vespertino", "Entrada"): v_in,
                ("🌙 Turno Vespertino", "Salida"): v_out
            }])
            df_hoy.columns = pd.MultiIndex.from_tuples(df_hoy.columns)
                
            def resaltar_olvidos_hoy(val):
                if val == "--:--": return 'color: #9f1239; background-color: #ffe4e6; font-weight: bold;'
                return ''
                
            estilos_encabezado = [{'selector': 'th', 'props': [('color', 'black !important'), ('font-weight', '900 !important')]}]
                
            tabla_estilizada = df_hoy.style.hide(axis="index").map(resaltar_olvidos_hoy).set_table_styles(estilos_encabezado)
                
            st.table(tabla_estilizada)
                    
            if nota_viaje: st.caption(f"📍 **Locación Foránea:** {nota_viaje}")
        else:
            st.info("👋 Aún no tienes marcas de asistencia registradas el día de hoy.")
                
    except Exception as e:
        pass # Si hay error de red, no ensuciamos el inicio

elif opcion_seleccionada == "📝 Orden de Produccion":
    mod_eventos.renderizar_modulo()
    
elif opcion_seleccionada == "📦 Checkout [VPF-PSP-CHL]":
    mod_checkout.renderizar_modulo(API_URL)
    
elif "💸 Reporte de Gastos" in opcion_seleccionada:
    mod_reporte_gastos.renderizar_modulo(API_URL)
    
elif opcion_seleccionada == "🚩 Equipos con Daño":
    mod_equipos_danados.renderizar_modulo(API_URL)   
    
elif opcion_seleccionada == "📊 Incidencias":
    mod_incidencias.renderizar_modulo(API_URL)
    
elif opcion_seleccionada == "📈 Analítica y KPIs":
    mod_analitica_kpis.renderizar_modulo(API_URL)
    
elif opcion_seleccionada == "🚙 Autos":
    mod_autos.renderizar_modulo(API_URL)
    
elif opcion_seleccionada == "🏢 Clientes":
    mod_clientes.renderizar_modulo(API_URL)
    
elif opcion_seleccionada == "🦺 Empleados":
    mod_empleados.renderizar_modulo(API_URL)
    
elif opcion_seleccionada == "🛠️ Inventario":
    mod_inventario.renderizar_modulo(API_URL)

elif opcion_seleccionada == "🚚 Proveedores":
    mod_proveedores.renderizar_modulo(API_URL)

elif opcion_seleccionada == "🕒 Checador":
    mod_kiosco.renderizar_modulo(API_URL, FOTOS_PERSONAL_DIR)

elif opcion_seleccionada == "🤝 Reuniones / Prospectos":
    mod_reuniones.renderizar_modulo(API_URL)
    
elif opcion_seleccionada == "⏱️ Auditoría Asistencia":
    mod_reporte_asistencia.renderizar_modulo(API_URL)

elif opcion_seleccionada == "📄 Cotizaciones":
    mod_cotizaciones.renderizar_modulo(API_URL)
    
else:
    st.warning(f"🚧 El módulo '{opcion_seleccionada}' está en proceso de migración al nuevo sistema de módulos.")