# 🖥️ VPRO SYSTEM - FRONTEND SHELL (STREAMLIT MASTER DASHBOARD V7.9.4)
import streamlit as st
import requests
import datetime
import pandas as pd
import unicodedata
import time
import os
import base64

from modulos_prueba import mod_autos, mod_eventos, mod_kiosco, mod_checkout, mod_incidencias, mod_empleados, mod_clientes, mod_inventario, mod_proveedores, mod_reporte_gastos, mod_equipos_danados,mod_analitica_kpis, mod_manual, mod_reuniones,mod_reporte_asistencia, mod_cotizaciones, mod_rh

# 🎛️ CONFIGURACIÓN DE LIENZO MAESTRO
st.set_page_config(
    page_title="VPRO Dashboard", 
    layout="wide", 
    initial_sidebar_state="expanded"
)

try:
    from core.config import API_URL, FOTOS_EQUIPOS_DIR, FOTOS_PERSONAL_DIR
except ImportError:
    API_URL = "https://172.16.0.20:8000"
    FOTOS_EQUIPOS_DIR = "Fotos_de_equipos"
    FOTOS_PERSONAL_DIR = "Fotos_de_personal"

from modulos_prueba.utils_frontend import get_base64_of_bin_file

# ⚙️ INTERRUPTOR DE NAVEGACIÓN (Feature Flag)
# Cambiar a False si se desea volver al menú clásico sin submenú de Catálogos (ABC)
AGRUPAR_MENU_ABC = True

requests.packages.urllib3.disable_warnings()

def transformar_imagen_a_web(ruta_archivo):
    """Convierte una imagen local a formato Base64 para que el HTML de Streamlit la renderice en cualquier red"""
    data = get_base64_of_bin_file(ruta_archivo)
    if data:
        ext = "png" if ruta_archivo.lower().endswith(".png") else "jpeg"
        return f"data:image/{ext};base64,{data}"
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
        respuesta = requests.get(url_pendientes, verify=False, timeout=5)
        
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

def contar_gastos_pendientes():
    try:
        res = requests.get(f"{API_URL}/api/gastos/pendientes/conteo", verify=False, timeout=5)
        return res.json() if res.status_code == 200 else 0
    except: return 0

def renderizar_aprobacion_horas_extras(API_URL):
    nom_usr = str(st.session_state.get("usuario_actual", "")).strip()
    if not nom_usr: 
        return
    try:
        res = requests.get(f"{API_URL}/api/asistencia/horas-extras/pendientes/{nom_usr}", verify=False, timeout=5)
        if res.status_code == 200:
            solicitudes = res.json()
            if solicitudes:
                with st.expander(f"🌙 {len(solicitudes)} Registro(s) de Horas Extras por Cierre en Madrugada (Requiere Aprobación)", expanded=True):
                    st.markdown("""
                    <div style="background: linear-gradient(135deg, #1e1b4b 0%, #312e81 100%); color: white; padding: 14px 18px; border-radius: 10px; margin-bottom: 15px;">
                        <h4 style="color: #fbbf24; margin: 0 0 4px 0; font-size: 18px;">🌙 Aprobación de Jornadas Nocturnas y Horas Extras</h4>
                        <p style="color: #e0e7ff; margin: 0; font-size: 13px;">El personal convocado finalizó actividades en la madrugada. Como Productor / Administrador, confirma la autorización de las horas extraordinarias para el reporte de nómina.</p>
                    </div>
                    """, unsafe_allow_html=True)

                    ops_agrupadas = {}
                    for sol in solicitudes:
                        op_key = f"OP-{sol.get('folio_op', 'S/N')} - {sol.get('nombre_evento', 'Evento')}"
                        ops_agrupadas.setdefault(op_key, []).append(sol)

                    for op_nombre, lista in ops_agrupadas.items():
                        st.markdown(f"**🎬 {op_nombre}** | Fecha de Llamado: `{lista[0].get('fecha_jornada', '')}` | Productor: `{lista[0].get('productor_responsable', '')}`")
                        
                        df_he = pd.DataFrame([{
                            "Empleado": s['nombre_empleado'],
                            "☀️ Entrada": str(s['hora_entrada'])[:5],
                            "🌙 Salida (+1d)": f"{str(s['hora_salida_madrugada'])[:5]} 🌙",
                            "Corte Normal": str(s['corte_ordinario'])[:5],
                            "⏱️ Horas Extras": f"{s['horas_extra_calculadas']} hrs",
                            "Estatus": "⏳ PENDIENTE"
                        } for s in lista])
                        st.dataframe(df_he, use_container_width=True, hide_index=True)

                        c_btn1, c_btn2, _ = st.columns([2, 2, 4])
                        ids_op = [s['id_autorizacion'] for s in lista]
                        with c_btn1:
                            if st.button(f"✅ AUTORIZAR TIEMPO EXTRA ({len(lista)})", key=f"btn_aut_he_{op_nombre}", type="primary", use_container_width=True):
                                payload = {
                                    "ids_autorizacion": ids_op,
                                    "aprobado_por": nom_usr,
                                    "accion": "APROBAR"
                                }
                                r_aut = requests.post(f"{API_URL}/api/asistencia/horas-extras/autorizar", json=payload, verify=False)
                                if r_aut.status_code == 200:
                                    st.success(f"🎉 Horas extras de {op_nombre} autorizadas exitosamente. Se integraron al reporte de nómina.")
                                    import time
                                    time.sleep(1.2)
                                    st.rerun()
                        with c_btn2:
                            if st.button(f"❌ RECHAZAR", key=f"btn_rech_he_{op_nombre}", use_container_width=True):
                                payload = {
                                    "ids_autorizacion": ids_op,
                                    "aprobado_por": nom_usr,
                                    "accion": "RECHAZAR"
                                }
                                requests.post(f"{API_URL}/api/asistencia/horas-extras/autorizar", json=payload, verify=False)
                                st.warning("Horas extras rechazadas.")
                                import time
                                time.sleep(1.2)
                                st.rerun()
                        st.write("")
    except Exception as e:
        print(f"⚠️ SILENCED ERROR in app_main_prueba.py: {e}")

# 📦 CONTROL DE SESIÓN GENERAL
if "autenticado" not in st.session_state: st.session_state.autenticado = False
if "confirmacion_baja_pendiente" not in st.session_state: st.session_state.confirmacion_baja_pendiente = False
if "payload_temporal" not in st.session_state: st.session_state.payload_temporal = None
if "nombres_bajas_temporales" not in st.session_state: st.session_state.nombres_bajas_temporales = []
if "menu_principal_radio" not in st.session_state: st.session_state.menu_principal_radio = "🏠 Inicio"
if "op_activa_checkout" not in st.session_state: st.session_state.op_activa_checkout = "---"
if "rh_expandido" not in st.session_state: st.session_state.rh_expandido = False


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

opciones_abc = []
if es_kiosko:
    menu_opciones = ["🕒 Checador"]
else:
    if AGRUPAR_MENU_ABC:
        # 🗂️ Módulos de Catálogos (Altas, Bajas y Cambios - ABC) según permisos
        if rol_actual in ["ADMIN", "COORDINADOR"]:
            opciones_abc.append("🦺 Empleados")
            opciones_abc.append("🚚 Proveedores")
            opciones_abc.append("🏢 Clientes")
            opciones_abc.append("🤝 Reuniones / Prospectos")
            opciones_abc.append("🚙 Autos")
        opciones_abc.append("🛠️ Inventario")

        abc_expandido = st.session_state.get("abc_expandido", False)
        rh_expandido  = st.session_state.get("rh_expandido",  False)

        # Sub-opciones del módulo Recursos Humanos
        opciones_rh = [
            "🔍 Expediente de Empleado",
            "📝 Solicitudes de Empleo",
            "🏖️ Calendario de Vacaciones",
            "📥 Bandeja de Permisos",
            "⚠️ Alertas del Sistema",
            "📖 Guía de Registro RH",
        ]

        menu_opciones = ["🏠 Inicio"]
        if rol_actual in ["ADMIN", "COORDINADOR", "PRODUCTOR"]:
            menu_opciones.append("📝 Orden de Produccion")

        if opciones_abc:
            menu_opciones.append("📁 Catálogos (ABC)")
            # Desplegar los catálogos DIRECTAMENTE DEBAJO de "📁 Catálogos (ABC)"
            if abc_expandido:
                for cat in opciones_abc:
                    menu_opciones.append(f"   ↳ {cat}")

        if rol_actual in ["ADMIN", "COORDINADOR"]:
            menu_opciones.extend(["⏱️ Auditoría Asistencia", "📄 Cotizaciones"])

        menu_opciones.append("📦 Checkout [VPF-PSP-CHL]")

        if rol_actual in ["ADMIN", "COORDINADOR"]:
            menu_opciones.append("📊 Incidencias")

        menu_opciones.append("🚩 Equipos con Daño")

        if rol_actual in ["ADMIN", "COORDINADOR", "PRODUCTOR"]:
            conteo_pendientes = contar_gastos_pendientes()
            etiqueta_gastos = f"💸 Reporte de Gastos ({conteo_pendientes})" if conteo_pendientes > 0 else "💸 Reporte de Gastos"
            menu_opciones.append(etiqueta_gastos)

        if rol_actual in ["ADMIN", "COORDINADOR"] or es_villarreal_menu or es_cuauhtemoc:
            menu_opciones.append("📈 Analítica y KPIs")

        if rol_actual in ["ADMIN"]:
            menu_opciones.append("👥 Recursos Humanos")
            # Desplegar sub-opciones RH directamente debajo
            if rh_expandido:
                for sub in opciones_rh:
                    menu_opciones.append(f"   ↳ {sub}")

        menu_opciones.append("🕒 Checador")
    else:
        # Menú clásico (plano) sin agrupación
        menu_opciones = ["🏠 Inicio"]
        if rol_actual in ["ADMIN", "COORDINADOR", "PRODUCTOR"]:
            menu_opciones.append("📝 Orden de Produccion")
            menu_opciones.append("🤝 Reuniones / Prospectos")
            menu_opciones.append("🚙 Autos")
            
        menu_opciones.append("🛠️ Inventario")
            
        if rol_actual in ["ADMIN", "COORDINADOR"]:
            menu_opciones.extend(["🦺 Empleados", "🚚 Proveedores", "🏢 Clientes", "⏱️ Auditoría Asistencia", "📄 Cotizaciones"])
                
        menu_opciones.append("📦 Checkout [VPF-PSP-CHL]")
        
        if rol_actual in ["ADMIN", "COORDINADOR"]:
            menu_opciones.append("📊 Incidencias")
            
        menu_opciones.append("🚩 Equipos con Daño")
        
        if rol_actual in ["ADMIN", "COORDINADOR", "PRODUCTOR"]:
            conteo_pendientes = contar_gastos_pendientes()
            etiqueta_gastos = f"💸 Reporte de Gastos ({conteo_pendientes})" if conteo_pendientes > 0 else "💸 Reporte de Gastos"
            menu_opciones.append(etiqueta_gastos)
            
        if rol_actual in ["ADMIN", "COORDINADOR"] or es_villarreal_menu or es_cuauhtemoc:
            menu_opciones.append("📈 Analítica y KPIs")

        if rol_actual in ["ADMIN"]:
            menu_opciones.append("👥 Recursos Humanos")

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
        
    # Compatibilidad con redirecciones directas a sub-módulos ABC
    if AGRUPAR_MENU_ABC and st.session_state.menu_dinamico in opciones_abc:
        st.session_state.abc_expandido = True
        st.session_state.menu_dinamico = f"   ↳ {st.session_state.menu_dinamico}"

    # Compatibilidad con redirecciones directas a sub-módulos RH
    if AGRUPAR_MENU_ABC and st.session_state.get("menu_dinamico","") in [
        "🔍 Expediente de Empleado", "📝 Solicitudes de Empleo",
        "🏖️ Calendario de Vacaciones", "📥 Bandeja de Permisos",
        "⚠️ Alertas del Sistema", "📖 Guía de Registro RH"
    ]:
        st.session_state.rh_expandido  = True
        st.session_state.menu_dinamico = f"   ↳ {st.session_state.menu_dinamico}"

    # Sanitizar selección si el menú se colapsó
    if st.session_state.menu_dinamico not in menu_opciones:
        st.session_state.menu_dinamico = menu_opciones[0]
        
    try:
        idx_menu_destino = menu_opciones.index(st.session_state.menu_dinamico)
    except Exception:
        idx_menu_destino = 0
        
    opcion_seleccionada = st.sidebar.radio("MENÚ PRINCIPAL:", menu_opciones, index=idx_menu_destino)
    
    if opcion_seleccionada != st.session_state.menu_dinamico:
        st.session_state.menu_dinamico = opcion_seleccionada
        
        # Lógica de acordeón dinámico
        if opcion_seleccionada == "📁 Catálogos (ABC)":
            st.session_state.abc_expandido = True
        elif opcion_seleccionada == "👥 Recursos Humanos":
            # Toggle: si ya está expandido, colapsar; si no, expandir
            st.session_state.rh_expandido = not st.session_state.get("rh_expandido", False)
            st.session_state.abc_expandido = False
        elif opcion_seleccionada.startswith("   ↳ "):
            # Sub-opción de ABC o RH: mantener el acordeón correspondiente abierto
            st.session_state.abc_expandido = True
        else:
            # Cualquier otra opción: colapsar AMBOS acordeones
            st.session_state.abc_expandido = False
            st.session_state.rh_expandido  = False
            
        st.rerun()

    st.write("---") # Para poner una línea que separe el menú de los botones

    if st.button("❓Ayuda / Manual Completo", use_container_width=True):
        mod_manual.mostrar_manual_popup()
    
    # Este es el botón de cerrar sesión que ya tenías
    if st.button("🚪 Cerrar Sesión", width='stretch'):
        st.session_state.clear()
        st.rerun()
                        
# Normalizar nombre del módulo para renderizar
if opcion_seleccionada.startswith("   ↳ "):
    modulo_a_ejecutar = opcion_seleccionada.replace("   ↳ ", "").strip()
else:
    modulo_a_ejecutar = opcion_seleccionada

st.header(f"{modulo_a_ejecutar}")
st.write("---")

# 🔀 ENRUTADOR PRINCIPAL (El "Switch" de Módulos)
if modulo_a_ejecutar == "🏠 Inicio":
    st.info("🏠 Bienvenido al Laboratorio de Pruebas VPRO. Selecciona un módulo en el menú izquierdo.")
    
    renderizar_notificaciones(API_URL)
    renderizar_aprobacion_horas_extras(API_URL)
    st.write("---")

    st.markdown("<h4 style='color:#0f172a; margin-top: 25px;'>⏱️ Mi Asistencia de la Semana</h4>", unsafe_allow_html=True)
    try:
        import pandas as pd
        import datetime
        
        id_usr = str(st.session_state.get("id_usuario", ""))
        nom_usr = str(st.session_state.get("usuario_actual", ""))
        
        # 1️⃣ Calcular el rango de la semana actual (Lunes a Domingo)
        hoy = datetime.date.today()
        lunes = hoy - datetime.timedelta(days=hoy.weekday())
        domingo = lunes + datetime.timedelta(days=6)
        
        dias_espanol = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
        
        # 2️⃣ Construir la estructura base de los 7 días
        semana_data = {}
        for i in range(7):
            fecha_iter = lunes + datetime.timedelta(days=i)
            semana_data[str(fecha_iter)] = {
                "Dia": dias_espanol[i],
                "Fecha": fecha_iter.strftime("%d/%m/%Y"),
                "M_IN": "--:--", "M_OUT": "--:--", 
                "V_IN": "--:--", "V_OUT": "--:--", 
                "Nota": ""
            }
            
        # 3️⃣ Consultar el endpoint de auditoría (fusiona oficina y giras automáticamente)
        payload_semana = {
            "fecha_inicio": str(lunes),
            "fecha_fin": str(domingo),
            "empleado": nom_usr
        }
        res_semana = requests.post(f"{API_URL}/api/asistencia/auditoria", json=payload_semana, verify=False, timeout=5)
        
        if res_semana.status_code == 200:
            registros = res_semana.json()
            
            def limpia_hora(h):
                if not h or h in ["", "None", "null", "--:--"]: return "--:--"
                return str(h)[:5]
                
            for r in registros:
                f_reg = r.get("fecha", "")
                if f_reg in semana_data:
                    semana_data[f_reg]["M_IN"] = limpia_hora(r.get("hora_entrada"))
                    semana_data[f_reg]["M_OUT"] = limpia_hora(r.get("hora_salida"))
                    semana_data[f_reg]["V_IN"] = limpia_hora(r.get("hora_entrada_v"))
                    semana_data[f_reg]["V_OUT"] = limpia_hora(r.get("hora_salida_v"))
                    
                    nota_actual = semana_data[f_reg]["Nota"]
                    nueva_nota = r.get("observaciones", "").strip()
                    if nueva_nota:
                        semana_data[f_reg]["Nota"] = f"{nota_actual} | {nueva_nota}".strip(" |")

        # 4️⃣ Función de análisis inteligente por día
        HORA_LIMITE_ENTRADA = "09:05"  # Tolerancia de 5 min

        def generar_observacion(dia_idx, m_in, m_out, v_in, v_out, es_pasado_o_hoy, nota_dia="", fecha_obj=None):
            """Analiza la asistencia del día y genera un comentario de semáforo."""
            if dia_idx >= 5:           # Sábado/Domingo — no aplica
                return ""
            if not es_pasado_o_hoy:    # Días futuros — no aplica
                return ""

            # Reconocimiento de Comisión Local (Servicio a cliente en campo)
            if "COMISIÓN LOCAL" in nota_dia.upper() or "COMISION LOCAL" in nota_dia.upper():
                return "🚗 Comisión Local (Justificado)"

            # Registro de Gira/Campo (00:00 o nota de gira es marcador de actividad foránea)
            if (m_in == "00:00" and m_out == "00:00") or "GIRA" in nota_dia.upper() or "LOCACION" in nota_dia.upper() or "LOCACIÓN" in nota_dia.upper():
                import re
                m_op = re.search(r'(OP-\d+)\s*[-:]?\s*([^|]+)', nota_dia, re.IGNORECASE)
                if m_op:
                    op_tag = m_op.group(1).upper()
                    ev_nom = m_op.group(2).strip().lstrip('-').strip()
                    ev_nom = re.sub(r'[\U00010000-\U0010ffff]', '', ev_nom)
                    ev_nom = ev_nom.replace("(+1d)", "").replace("(+1D)", "").strip().strip("-").strip()
                    gira_txt = f"📍 En Gira / {op_tag} - {ev_nom}"
                else:
                    gira_txt = "📍 En Gira / Campo (Justificado)"

                # Si el día además es feriado, anteponer el aviso de día no laborable
                if fecha_obj:
                    try:
                        from core.utils import es_feriado_mexico
                        es_fer, nom_fer = es_feriado_mexico(fecha_obj)
                        if es_fer:
                            return f"🗓️ Día no laborable ({nom_fer}) | {gira_txt}"
                    except Exception as e:
                        print(f"⚠️ SILENCED ERROR in app_main_prueba.py: {e}")
                return gira_txt

            sin_m_in  = m_in  in ("--:--", "")
            sin_m_out = m_out in ("--:--", "")
            sin_v_in  = v_in  in ("--:--", "")
            sin_v_out = v_out in ("--:--", "")

            # Sin ningún registro en día hábil
            if sin_m_in and sin_m_out and sin_v_in and sin_v_out:
                if fecha_obj:
                    try:
                        from core.utils import es_feriado_mexico
                        es_fer, nom_fer = es_feriado_mexico(fecha_obj)
                        if es_fer:
                            return f"🗓️ Descanso obligatorio ({nom_fer})"
                    except Exception as e:
                        print(f"⚠️ SILENCED ERROR in app_main_prueba.py: {e}")
                return "❌ Ausencia — sin registro"

            mensajes = []

            # Retardo en entrada matutina
            if not sin_m_in and m_in > HORA_LIMITE_ENTRADA:
                try:
                    h, m_ = map(int, m_in.split(":"))
                    lh, lm = map(int, HORA_LIMITE_ENTRADA.split(":"))
                    mins_tarde = (h * 60 + m_) - (lh * 60 + lm)
                    mensajes.append(f"🕐 Retardo +{mins_tarde} min")
                except Exception:
                    mensajes.append("🕐 Retardo detectado")

            # Salida matutina no registrada (pero sí entró)
            if not sin_m_in and sin_m_out:
                mensajes.append("⚠️ Salida mat. sin registrar")

            # Entrada vespertina faltante (pero sí tuvo jornada matutina)
            if not sin_m_in and sin_v_in:
                mensajes.append("⚠️ Entrada vesp. sin registrar")

            # Salida vespertina faltante (pero sí entró en vespertino)
            if not sin_v_in and sin_v_out:
                mensajes.append("⚠️ Salida vesp. sin registrar")

            return " | ".join(mensajes) if mensajes else "✅ Al día"

        # 5️⃣ Construir DataFrame plano con Observaciones
        filas_df = []
        obs_semana = []

        for idx_dia, (f_iso, data) in enumerate(semana_data.items()):
            fecha_obj_iter = datetime.date.fromisoformat(f_iso)
            es_pasado = fecha_obj_iter <= hoy

            obs = generar_observacion(
                idx_dia,
                data["M_IN"], data["M_OUT"],
                data["V_IN"], data["V_OUT"],
                es_pasado,
                data.get("Nota", ""),
                fecha_obj_iter
            )
            obs_semana.append(obs)

            filas_df.append({
                "Día":              data["Dia"],
                "Fecha":            data["Fecha"],
                "☀️ Ent.":         data["M_IN"],
                "☀️ Sal.":         data["M_OUT"],
                "🌙 Ent.":         data["V_IN"],
                "🌙 Sal.":         data["V_OUT"],
                "📝 Observaciones": obs,
            })

        # 6️⃣ Alerta global: 3 o más retardos en la semana
        total_retardos = sum(1 for o in obs_semana if "Retardo" in o)
        total_ausencias = sum(1 for o in obs_semana if "Ausencia" in o)
        if total_retardos >= 3:
            st.warning(
                f"⚠️ **{total_retardos} retardos esta semana.** "
                "Recuerda respetar el horario de entrada — más de 3 retardos pueden afectar tu evaluación."
            )
        if total_ausencias > 0:
            st.error(f"❌ **{total_ausencias} día(s) sin registro** esta semana. Verifica con tu coordinador.")

        df_semana = pd.DataFrame(filas_df)

        # 7️⃣ Estilos: Marcar entradas/salidas faltantes en rojo
        def aplicar_estilos_faltas(row):
            estilos = [""] * len(row)
            try:
                fecha_obj_r = datetime.datetime.strptime(row["Fecha"], "%d/%m/%Y").date()
                if fecha_obj_r <= hoy:
                    for i, col in enumerate(row.index):
                        if col in ["☀️ Ent.", "☀️ Sal.", "🌙 Ent.", "🌙 Sal."] and row[col] == "--:--":
                            estilos[i] = "color:#9f1239; background-color:#ffe4e6; font-weight:bold;"
            except Exception as e:
                print(f"⚠️ SILENCED ERROR in app_main_prueba.py: {e}")
            return estilos

        tabla_estilizada = df_semana.style.hide(axis="index").apply(aplicar_estilos_faltas, axis=1)

        st.dataframe(
            tabla_estilizada,
            hide_index=True,
            use_container_width=True,
            column_config={
                "Día":              st.column_config.TextColumn("Día",         width="small"),
                "Fecha":            st.column_config.TextColumn("Fecha",        width="small"),
                "☀️ Ent.":         st.column_config.TextColumn("☀️ Ent.",      width="small"),
                "☀️ Sal.":         st.column_config.TextColumn("☀️ Sal.",      width="small"),
                "🌙 Ent.":         st.column_config.TextColumn("🌙 Ent.",      width="small"),
                "🌙 Sal.":         st.column_config.TextColumn("🌙 Sal.",      width="small"),
                "📝 Observaciones": st.column_config.TextColumn("📝 Observaciones", width="large"),
            }
        )


    except Exception as e:
        print(f"⚠️ SILENCED ERROR in app_main_prueba.py: {e}") # Si hay error de red, no ensuciamos el inicio

elif modulo_a_ejecutar == "📝 Orden de Produccion":
    mod_eventos.renderizar_modulo(API_URL)

elif modulo_a_ejecutar == "📁 Catálogos (ABC)":
    st.markdown("""
    <div style="background-color: #1e293b; padding: 22px; border-radius: 12px; border-left: 8px solid #deff9a; margin-bottom: 25px;">
        <h3 style="color: #f8fafc; margin: 0 0 8px 0;">📁 Catálogos Maestros (Altas, Bajas y Cambios)</h3>
        <p style="color: #cbd5e1; margin: 0; font-size: 14px;">
            Selecciona un catálogo en el menú lateral o en los botones inferiores para abrir el módulo.
        </p>
    </div>
    """, unsafe_allow_html=True)
    
    cols = st.columns(3)
    for idx_cat, cat in enumerate(opciones_abc):
        with cols[idx_cat % 3]:
            if st.button(f"Abrir {cat}", key=f"btn_hub_cat_{idx_cat}", use_container_width=True):
                st.session_state.abc_expandido = True
                st.session_state.menu_dinamico = f"   ↳ {cat}"
                st.rerun()

elif modulo_a_ejecutar == "📦 Checkout [VPF-PSP-CHL]":
    mod_checkout.renderizar_modulo(API_URL)
    
elif "💸 Reporte de Gastos" in modulo_a_ejecutar:
    mod_reporte_gastos.renderizar_modulo(API_URL)
    
elif modulo_a_ejecutar == "🚩 Equipos con Daño":
    mod_equipos_danados.renderizar_modulo(API_URL)   
    
elif modulo_a_ejecutar == "📊 Incidencias":
    mod_incidencias.renderizar_modulo(API_URL)
    
elif modulo_a_ejecutar == "📈 Analítica y KPIs":
    mod_analitica_kpis.renderizar_modulo(API_URL)
    
elif modulo_a_ejecutar == "🚙 Autos":
    mod_autos.renderizar_modulo(API_URL)
    
elif modulo_a_ejecutar == "🏢 Clientes":
    mod_clientes.renderizar_modulo(API_URL)
    
elif modulo_a_ejecutar == "🦺 Empleados":
    mod_empleados.renderizar_modulo(API_URL)
    
elif modulo_a_ejecutar == "🛠️ Inventario":
    mod_inventario.renderizar_modulo(API_URL)

elif modulo_a_ejecutar == "🚚 Proveedores":
    mod_proveedores.renderizar_modulo(API_URL)

elif modulo_a_ejecutar == "🕒 Checador":
    mod_kiosco.renderizar_modulo(API_URL, FOTOS_PERSONAL_DIR)

elif modulo_a_ejecutar == "🤝 Reuniones / Prospectos":
    mod_reuniones.renderizar_modulo(API_URL)
    
elif modulo_a_ejecutar == "⏱️ Auditoría Asistencia":
    mod_reporte_asistencia.renderizar_modulo(API_URL)

elif modulo_a_ejecutar == "📄 Cotizaciones":
    mod_cotizaciones.renderizar_modulo(API_URL)

elif modulo_a_ejecutar == "👥 Recursos Humanos":
    # Sin sub-opción activa: abrir Expediente por defecto
    mod_rh.renderizar_modulo(API_URL, "🔍 Expediente de Empleado", str(FOTOS_PERSONAL_DIR))

elif modulo_a_ejecutar in [
    "🔍 Expediente de Empleado",
    "📝 Solicitudes de Empleo",
    "🏖️ Calendario de Vacaciones",
    "📥 Bandeja de Permisos",
    "⚠️ Alertas del Sistema",
    "📖 Guía de Registro RH",
]:
    # Sub-opción de RH seleccionada desde el acordeón
    mod_rh.renderizar_modulo(API_URL, modulo_a_ejecutar, str(FOTOS_PERSONAL_DIR))

else:
    st.warning(f"🚧 El módulo '{modulo_a_ejecutar}' está en proceso de migración al nuevo sistema de módulos.")