import streamlit as st
import requests
import pandas as pd
import datetime
import os
import base64
import unicodedata
import time
from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus

def renderizar_modulo(API_URL, FOTOS_PERSONAL_DIR):
    # 🧠 Variables de Sesión
    id_operador = str(st.session_state.get("id_usuario", ""))
    rol_user = str(st.session_state.get("rol", ""))
    nombre_operador = str(st.session_state.get("usuario_actual", ""))
    depto_operador = str(st.session_state.get("depto", ""))
    
    es_kiosko = (id_operador == "529") # Cuenta maestra de la pantalla física

    if es_kiosko:
        st.markdown("<style>.st-emotion-cache-10trblm {display: none;} h1 {display: none;}</style>", unsafe_allow_html=True)

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
        # ==============================================================
        # --- CASO A: MODO KIOSCO AUTOMÁTICO (PANTALLA FÍSICA) ---
        # ==============================================================
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
        
        # 1️⃣ EL ESCÁNER ESTÁTICO PERO INTELIGENTE
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
                            if (window.parent.document.activeElement !== inputs[i]) {
                                inputs[i].focus();
                            }
                            break;
                        }
                    }
                }
                engancharCursor();
                setInterval(engancharCursor, 1000); 
            </script>
        """, height=0)

        # 2️⃣ PROCESAMIENTO DEL QR ATRAPADO EN MEMORIA
        if st.session_state.qr_a_procesar:
            id_limpio = st.session_state.qr_a_procesar
            st.session_state.qr_a_procesar = None # Consumimos el dato
            
            ahora_segundos = datetime.datetime.now().timestamp()
            ultimo_registro = st.session_state.memoria_kiosko.get(id_limpio, 0)
            
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
                                    limite_retardo = datetime.time(9, 5, 59)  # 5 minutos de tolerancia
                                    hora_base = datetime.time(9, 0, 0)
                                    observacion_turno = "T. Matutino"
                                else:
                                    limite_retardo = datetime.time(16, 5, 59)  # 5 minutos de tolerancia
                                    hora_base = datetime.time(16, 0, 0)
                                    observacion_turno = "T. Vespertino"
                                    
                                if ahora_hora > limite_retardo:
                                    estatus_final = "RETARDO"
                                    dt_base = datetime.datetime.combine(ahora.date(), hora_base)
                                    segundos_tarde = int((ahora - dt_base).total_seconds())
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
                                resp_data = res_final_ch.json() if res_final_ch.text else {}
                                adv_msg = resp_data.get("advertencia")
                                
                                if adv_msg and "VILLARREAL" not in nombre_s.upper():
                                    texto_llegada = "🚨 SALIDA (OMISIÓN COMIDA)"
                                    st.toast(adv_msg, icon="⚠️")
                                else:
                                    adv_msg = None
                                    st.toast(f"✅ ¡{nombre_s} registrado con éxito!", icon="👍")
                                
                                # Actualizamos memoria visual
                                st.session_state.ultimo_escaneado_ui = {
                                    "id": id_s, "nombre": nombre_s, "movimiento": tipo_mov, "hora": ahora_hora_txt, "estatus_str": texto_llegada, "advertencia": adv_msg
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

        # 3️⃣ RENDERIZADO VISUAL DEL KIOSKO (Izquierda: Foto, Derecha: Matriz)
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
                    
                    if u.get('advertencia'):
                        st.markdown(f"""
                            <div style='background-color:#fee2e2; border: 2px solid #ef4444; border-radius: 8px; padding: 10px; margin-top: 10px; text-align:center;'>
                                <p style='color:#991b1b; font-weight:bold; font-size:13px; margin:0;'>
                                    {u['advertencia']}
                                </p>
                            </div>
                        """, unsafe_allow_html=True)
            else:
                with st.container(border=True): 
                    st.image("https://cdn-icons-png.flaticon.com/512/3135/3135715.png", use_container_width=True)
                    st.markdown("<h3 style='text-align:center; color:#64748b; margin-top:15px;'>Esperando lectura...</h3>", unsafe_allow_html=True)
                
        with c_historial:
            st.markdown("<h4 style='text-align:center; color:#f8fafc; margin-top:0;'>📊 MATRIZ DE ASISTENCIA DEL DÍA</h4>", unsafe_allow_html=True)
            try:
                res_emps = requests.get(f"{API_URL}/api/empleados", verify=False)
                res_hoy = requests.get(f"{API_URL}/api/asistencia/reporte", verify=False)
                
                if res_emps.status_code == 200 and res_hoy.status_code == 200:
                    empleados_data_raw = res_emps.json()
                    todos_los_registros = res_hoy.json()
                    hoy_str = str(datetime.date.today())
                    
                    empleados_data = [] 
                    for emp in empleados_data_raw:
                        id_e = str(emp.get('id_empleado', '')).strip()
                        email_emp = str(emp.get('email', '')).strip()
                        todo_el_texto = f"{emp.get('estatus', '')} {emp.get('estado', '')} {emp.get('rol', '')} {emp.get('depto', '')}".upper() 
                        
                        if id_e == "529": continue
                        if "@" not in email_emp: continue
                        if 'BAJA' in todo_el_texto or 'INACTIV' in todo_el_texto: continue
                        if 'PROVEEDOR' in todo_el_texto or 'EXTERNO' in todo_el_texto: continue
                            
                        empleados_data.append(emp)
                    
                    registros_hoy = [r for r in todos_los_registros if str(r['fecha']).startswith(hoy_str)]
                    df_asist = pd.DataFrame(registros_hoy) if registros_hoy else pd.DataFrame()
                    
                    def clean_time_full(x):
                        if pd.isna(x) or str(x).strip() in ["", "None", "nan", "null"]: return "--:--:--"
                        return str(x)[:8]
                        
                    def calc_estatus_entrada(hora_str, turno):
                        if hora_str == "--:--:--": return ""
                        try:
                            h, m, s = map(int, str(hora_str).split(':'))
                            hora_dt = datetime.timedelta(hours=h, minutes=m, seconds=s)
                            limite_dt = datetime.timedelta(hours=9, minutes=5, seconds=59) if turno == "Matutino" else datetime.timedelta(hours=16, minutes=5, seconds=59)
                            if hora_dt > limite_dt:
                                retraso = hora_dt - (datetime.timedelta(hours=9) if turno == "Matutino" else datetime.timedelta(hours=16))
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
                    empleados_ordenados = sorted(empleados_data, key=lambda x: x['nombre'])
                    
                    for emp in empleados_ordenados:
                        id_emp = str(emp['id_empleado']).strip()
                        nom = emp['nombre']
                        m_in, m_out, v_in, v_out = "--:--:--", "--:--:--", "--:--:--", "--:--:--"
                        m_in_est, v_in_est, v_out_est = "", "", ""
                        
                        if not df_asist.empty:
                            emp_records = df_asist[df_asist['id_empleado'].astype(str).str.strip() == id_emp]
                            if not emp_records.empty:
                                row = emp_records.iloc[0] 
                                m_in = clean_time_full(row.get('hora_entrada'))
                                m_out = clean_time_full(row.get('hora_salida'))
                                v_in = clean_time_full(row.get('hora_entrada_v'))
                                v_out = clean_time_full(row.get('hora_salida_v'))
                                m_in_est = calc_estatus_entrada(m_in, "Matutino") if m_in != "--:--:--" else ""
                                v_in_est = calc_estatus_entrada(v_in, "Vespertino") if v_in != "--:--:--" else ""
                                v_out_est = calc_estatus_salida_vesp(v_out) if v_out != "--:--:--" else ""
                        
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
                        def resaltar_sabana_kiosko(val):
                            val_str = str(val)
                            if val_str == "--:--:--": return 'color: #f87171; background-color: rgba(153, 27, 27, 0.2);'
                            if "TARDE" in val_str: return 'color: #fca5a5; background-color: rgba(153, 27, 27, 0.5); font-weight: bold;'
                            if "A TIEMPO" in val_str: return 'color: #86efac; background-color: rgba(22, 101, 52, 0.5); font-weight: bold;'
                            if "Descansa" in val_str: return 'color: #93c5fd; background-color: rgba(30, 64, 175, 0.5); font-weight: bold;'
                            if "T. Extra" in val_str: return 'color: #fef08a; background-color: rgba(133, 77, 14, 0.5); font-weight: bold;'
                            return ''
                            
                        st.dataframe(df_final_turnos.style.map(resaltar_sabana_kiosko), use_container_width=True, height=600, hide_index=True)
                else:
                    st.error("Error al cargar datos del servidor.")
            except Exception as e:
                st.error(f"Error de red: {e}")
                
    else:
        # ==============================================================
        # --- CASO B: MODO CHECADOR INDIVIDUAL (APP WEB) ---
        # ==============================================================
        
        # 🔒 LÓGICA DE SEGURIDAD PARA LAS PESTAÑAS
        user_firma = str(nombre_operador).strip().upper()
        user_firma_clean = ''.join(c for c in unicodedata.normalize('NFD', user_firma) if unicodedata.category(c) != 'Mn')
        es_villarreal_directiva = any(x in user_firma_clean for x in ["ANDREA", "SOFIA", "GERARDO", "PEDRO", "ANA LILIA"]) or "VILLAREAL" in user_firma_clean
        es_cuauhtemoc = "CUAUHTEMOC" in user_firma_clean
        
        es_admin_autorizado = (es_cuauhtemoc or es_villarreal_directiva or rol_user in ["ADMIN", "COORDINADOR"])

        # Dibujamos las pestañas dinámicamente según el Rol
        if es_admin_autorizado:
            tab_checar, tab_admin = st.tabs(["🕒 Registrar Marca Diaria", "📊 REVISION DE ASISTENCIA (ADMIN)"])
        else:
            # Para los mortales, solo dibujamos la pestaña de su checador. 
            tab_checar = st.tabs(["🕒 Registrar Marca Diaria"])[0]
            tab_admin = None # Literalmente no existe en la interfaz para ellos
        
        # --- PESTAÑA 1: CREDENCIAL Y BITÁCORA PERSONAL (PARA TODOS) ---
        with tab_checar:
            id_sujeto_checa = id_operador
            nombre_sujeto_checa = nombre_operador
            
            foto_png = os.path.join(FOTOS_PERSONAL_DIR, f"{id_sujeto_checa}.png")
            foto_jpg = os.path.join(FOTOS_PERSONAL_DIR, f"{id_sujeto_checa}.jpg")
            foto_ruta_activa = foto_png if os.path.exists(foto_png) else (foto_jpg if os.path.exists(foto_jpg) else None)
            
            emp_data = {}
            try:
                res_emps = requests.get(f"{API_URL}/api/empleados", verify=False)
                if res_emps.status_code == 200:
                    for e in res_emps.json():
                        if str(e["id_empleado"]).strip() == str(id_sujeto_checa).strip():
                            emp_data = e
                            break
            except Exception as e: print(f"⚠️ SILENCED ERROR in mod_kiosco.py: {e}")
            
            qr_b64 = None; qr_bytes = None
            try:
                res_qr = requests.get(f"{API_URL}/api/empleados/{id_sujeto_checa}/qr", verify=False)
                if res_qr.status_code == 200:
                    qr_pack = res_qr.json()
                    qr_b64 = qr_pack["qr_base64"]
                    qr_bytes = base64.b64decode(qr_b64.split(",")[1])
            except Exception as e: print(f"⚠️ SILENCED ERROR in mod_kiosco.py: {e}")

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
                    if foto_ruta_activa: st.image(foto_ruta_activa, use_container_width=True)
                    else: st.error("❌ Fotografía no vinculada")
                        
                with c_datos:
                    st.markdown(f"**Nombre:** {nombre_sujeto_checa}")
                    st.markdown(f"**ID de Empleado:** `{id_sujeto_checa}`")
                    st.markdown(f"**Departamento:** {emp_data.get('depto', depto_operador)}")
                    st.markdown(f"**Puesto:** {emp_data.get('rol', rol_user)}")
                    st.markdown(f"**Vence Licencia:** {fmt_fecha(emp_data.get('licencia_vence'))}")
                    st.markdown(f"**Contacto:** {emp_data.get('email', 'No registrado')}")
                    st.markdown(f"**Miembro VPRO desde:** {fmt_fecha(emp_data.get('fecha_ing'))}")
                    
                with c_qr:
                    if qr_b64:
                        st.image(qr_b64, caption="QR de Asistencia", use_container_width=True)
                        if qr_bytes:
                            st.download_button(label="📥 Descargar QR", data=qr_bytes, file_name=f"QR_VPRO_{id_sujeto_checa}.png", mime="image/png", use_container_width=True)
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
                        reg = registros_hoy[0]
                        def limpia_hora(h_raw):
                            h_str = str(h_raw).strip()
                            if h_str in ["", "None", "null"]: return "--:--"
                            return h_str[:5]

                        m_in = limpia_hora(reg.get('hora_entrada'))
                        m_out = limpia_hora(reg.get('hora_salida'))
                        v_in = limpia_hora(reg.get('hora_entrada_v'))
                        v_out = limpia_hora(reg.get('hora_salida_v'))
                            
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
                            
                        st.dataframe(df_hoy.style.map(resaltar_olvidos_hoy), use_container_width=True, hide_index=True)
                    else:
                        st.info("👋 Aún no tienes marcas de asistencia registradas el día de hoy.")
                        
                    # 🚗 SECCIÓN: REGULARIZAR SALIDA A CLIENTE / COMISIÓN LOCAL CON OP REGISTRADA
                    with st.expander("🚗 ¿Saliste a un servicio o llamado express con cliente? (Justificar Asistencia)"):
                        st.caption("Solo puedes justificar salidas a servicios de clientes amparados por una Orden de Producción donde estés convocado.")
                        
                        # Consultar OPs activas donde el empleado está asignado
                        ops_asignadas = []
                        try:
                            res_ops_emp = requests.get(f"{API_URL}/api/asistencia/ops-activas-empleado/{nombre_sujeto_checa}", verify=False, timeout=4)
                            if res_ops_emp.status_code == 200:
                                ops_asignadas = res_ops_emp.json()
                        except Exception:
                            ops_asignadas = []

                        if not ops_asignadas:
                            st.warning("🚫 **No tienes Órdenes de Producción activas donde estés asignado.**\n\nSi saliste a atender una emergencia o servicio con un cliente, el Coordinador debe registrar la OP y convocarte a ella antes de que puedas justificar tu salida.")
                        else:
                            opciones_ops = ["--- Selecciona la OP del servicio ---"] + [op['etiqueta'] for op in ops_asignadas]
                            
                            col_mot, col_btn = st.columns([3, 1])
                            with col_mot:
                                op_seleccionada = st.selectbox(
                                    "Orden de Producción del servicio en campo:", 
                                    options=opciones_ops, 
                                    index=0,
                                    key=f"sel_op_com_{id_sujeto_checa}"
                                )
                            with col_btn:
                                st.write("##")
                                if st.button("✅ Registrar Salida", type="primary", use_container_width=True, key=f"btn_just_com_{id_sujeto_checa}"):
                                    if op_seleccionada == "--- Selecciona la OP del servicio ---":
                                        st.warning("⚠️ Debes seleccionar la OP correspondiente al servicio atendido.")
                                    else:
                                        payload_com = {
                                            "id_empleado": str(id_sujeto_checa).strip(),
                                            "fecha": str(datetime.date.today()),
                                            "cliente_o_motivo": op_seleccionada.strip()
                                        }
                                        try:
                                            res_c = requests.post(f"{API_URL}/api/asistencia/comision-local", json=payload_com, verify=False, timeout=5)
                                            if res_c.status_code == 200:
                                                st.success(f"✅ Salida justificada exitosamente bajo la {op_seleccionada.split(' | ')[0]}.")
                                                import time
                                                time.sleep(1.2)
                                                st.rerun()
                                            else:
                                                st.error(f"Error al registrar: {res_c.text}")
                                        except Exception as ex:
                                            st.error(f"Error de red: {ex}")
                else:
                    st.error("Error de conexión al cargar el historial.")
            except Exception as e:
                st.error(f"No se pudo cargar el historial de hoy: {e}")
        
        # --- PESTAÑA 2: AUDITORÍA Y REPORTES (SOLO ADMINS) ---
        if tab_admin is not None:
            with tab_admin:
                st.subheader("📊 Historial General Y Auditoría de Tiempos")
                try:
                    res_rep = requests.get(f"{API_URL}/api/asistencia/reporte", verify=False)
                    res_loc = requests.get(f"{API_URL}/api/asistencia/locacion/todas", verify=False)
                    res_emps = requests.get(f"{API_URL}/api/empleados", verify=False) 
                    
                    if res_rep.status_code == 200:
                        df_of = pd.DataFrame(res_rep.json())
                        df_loc = pd.DataFrame(res_loc.json()) if res_loc.status_code == 200 else pd.DataFrame()
                        
                        # 1️⃣ Preparar datos de OFICINA
                        if not df_of.empty:
                            df_of['origen'] = 'OFICINA'
                            df_of['fecha'] = pd.to_datetime(df_of['fecha']).dt.date
                            df_of['id_empleado'] = df_of['id_empleado'].astype(str).str.strip()
                            
                        # 2️⃣ Preparar datos de LOCACIÓN (Gira)
                        if not df_loc.empty:
                            df_loc = df_loc.rename(columns={'fecha_jornada': 'fecha'})
                            df_loc['fecha'] = pd.to_datetime(df_loc['fecha']).dt.date
                            df_loc['origen'] = 'LOCACION'
                            df_loc['hora_entrada_v'] = None
                            df_loc['hora_salida_v'] = None
                            df_loc['estatus'] = 'GIRA / LOCACIÓN'
                            
                            if res_emps.status_code == 200:
                                mapa_empleados = {str(e['nombre']).strip().upper(): str(e['id_empleado']).strip() for e in res_emps.json()}
                                df_loc['id_empleado'] = df_loc['nombre_empleado'].apply(lambda x: mapa_empleados.get(str(x).strip().upper(), "0"))
                            else:
                                df_loc['id_empleado'] = "0"
                        
                        # 3️⃣ FUSIÓN HÍBRIDA (La Magia para mezclar Oficina y Gira)
                        registros_fusionados = {}
                        
                        # A. Metemos todo lo de la oficina como verdad absoluta
                        if not df_of.empty:
                            for _, row in df_of.iterrows():
                                llave = (row['fecha'], str(row['nombre_empleado']).strip().upper())
                                registros_fusionados[llave] = row.to_dict()
                                registros_fusionados[llave]['tipo_registro'] = "🏢 Físico"

                        # B. Revisamos locación y rellenamos huecos
                        if not df_loc.empty:
                            for _, row in df_loc.iterrows():
                                llave = (row['fecha'], str(row['nombre_empleado']).strip().upper())
                                
                                def es_vacio(v):
                                    s = str(v).strip()
                                    return pd.isna(v) or s in ["", "None", "nan", "null", "00:00:00", "00:00", "0:00", "--:--"]
                                
                                loc_in = str(row.get('hora_entrada', '')).strip()
                                loc_out = str(row.get('hora_salida', '')).strip()
                                
                                if llave in registros_fusionados:
                                    # ¡CHOQUE! Checó en oficina pero está en gira. Rellenamos huecos vacíos.
                                    reg = registros_fusionados[llave]
                                    reg['tipo_registro'] = "🏢 Físico + 📍 Gira"
                                    obs_reg = str(reg.get('observaciones', '')).upper()
                                    
                                    if not es_vacio(loc_in):
                                        if loc_in >= "12:00:00" or loc_in >= "12:00":
                                            if es_vacio(reg.get('hora_entrada_v')):
                                                reg['hora_entrada_v'] = loc_in[:5] + " 📍"
                                        else:
                                            if es_vacio(reg.get('hora_entrada')):
                                                reg['hora_entrada'] = loc_in[:5] + " 📍"
                                            elif "ENTRADA COORD" in obs_reg or "[EN GIRA] ENTRADA" in obs_reg or "ENTRADA:" in obs_reg:
                                                if "📍" not in str(reg.get('hora_entrada', '')):
                                                    reg['hora_entrada'] = str(reg.get('hora_entrada'))[:5] + " 📍"
                                    
                                    if not es_vacio(loc_out):
                                        if loc_out >= "18:00:00" or loc_out >= "18:00":
                                            reg['hora_salida_v'] = loc_out[:5] + " 📍"
                                            if str(reg.get('hora_salida', '')).replace(" 📍", "").strip().startswith(loc_out[:5]):
                                                reg['hora_salida'] = None
                                        else:
                                            if es_vacio(reg.get('hora_salida')):
                                                reg['hora_salida'] = loc_out[:5] + " 📍"
                                            elif "SALIDA COORD" in obs_reg or "[EN GIRA] SALIDA" in obs_reg:
                                                if "📍" not in str(reg.get('hora_salida', '')):
                                                    reg['hora_salida'] = str(reg.get('hora_salida'))[:5] + " 📍"
                                else:
                                    # 100% Gira (No pisó la oficina)
                                    nuevo_reg = row.to_dict()
                                    nuevo_reg['tipo_registro'] = "📍 Gira 100%"
                                    if not es_vacio(loc_in):
                                        if loc_in >= "12:00:00" or loc_in >= "12:00":
                                            nuevo_reg['hora_entrada_v'] = loc_in[:5] + " 📍"
                                            nuevo_reg['hora_entrada'] = None
                                        else:
                                            nuevo_reg['hora_entrada'] = loc_in[:5] + " 📍"
                                    if not es_vacio(loc_out):
                                        if loc_out >= "18:00:00" or loc_out >= "18:00":
                                            nuevo_reg['hora_salida_v'] = loc_out[:5] + " 📍"
                                            nuevo_reg['hora_salida'] = None
                                        else:
                                            nuevo_reg['hora_salida'] = loc_out[:5] + " 📍"
                                    registros_fusionados[llave] = nuevo_reg

                        df_asist = pd.DataFrame(list(registros_fusionados.values()))

                        if not df_asist.empty:
                            st.markdown("### 🎯 CAMBIE SI ES NECESARIO Los Parámetros de Consulta de Personal")
                            c_filt1, c_filt2, c_filt3 = st.columns(3)
                            
                            with c_filt1: 
                                rango_asist = c_filt1.date_input("📅 Periodo de Consulta:", [df_asist['fecha'].min(), df_asist['fecha'].max()], key="filtro_fecha_asistencia_admin")
                            with c_filt2:
                                lista_empleados_asist = ["Todos"] + sorted(df_asist['nombre_empleado'].dropna().unique().tolist())
                                emp_asist_sel = c_filt2.selectbox("👤 Seleccionar Empleado:", lista_empleados_asist, key="filtro_emp_asistencia_admin")
                            with c_filt3:
                                lista_estatus = ["Todos"] + sorted(df_asist['estatus'].dropna().unique().tolist())
                                est_sel = c_filt3.selectbox("📊 Estatus de Asistencia:", lista_estatus, key="filtro_estatus_asistencia_admin")
                            
                            df_asist_filt = df_asist.copy()
                            
                            # 1️⃣ Filtrar por rango de fechas y expandir días completos del periodo
                            if isinstance(rango_asist, (list, tuple)) and len(rango_asist) == 2:
                                f_ini, f_fin = rango_asist[0], rango_asist[1]
                                if f_ini and f_fin and f_ini <= f_fin:
                                    df_asist_filt = df_asist_filt[(df_asist_filt['fecha'] >= f_ini) & (df_asist_filt['fecha'] <= f_fin)]
                                    
                                    # 2️⃣ Filtrar por empleado si se seleccionó uno específico
                                    if emp_asist_sel != "Todos":
                                        df_asist_filt = df_asist_filt[df_asist_filt['nombre_empleado'] == emp_asist_sel]
                                        emps_a_procesar = [emp_asist_sel]
                                    else:
                                        emps_a_procesar = sorted([e for e in lista_empleados_asist if e != "Todos"])

                                    # Diccionario de metadatos de empleados (ID y Depto)
                                    mapa_info_emps = {}
                                    for _, r in df_asist.iterrows():
                                        nom = str(r.get('nombre_empleado', '')).strip()
                                        if nom and nom not in mapa_info_emps:
                                            mapa_info_emps[nom] = {
                                                'id_empleado': str(r.get('id_empleado', '')).strip(),
                                                'depto': str(r.get('depto', '')).strip()
                                            }

                                    # Generar todos los días del periodo
                                    num_dias = (f_fin - f_ini).days + 1
                                    dias_rango = [f_ini + datetime.timedelta(days=i) for i in range(num_dias)]
                                    
                                    claves_existentes = set()
                                    if not df_asist_filt.empty:
                                        claves_existentes = set(zip(df_asist_filt['fecha'], df_asist_filt['nombre_empleado'].astype(str).str.strip()))

                                    filas_faltantes = []
                                    for emp in emps_a_procesar:
                                        info_emp = mapa_info_emps.get(emp, {'id_empleado': '0', 'depto': 'GENERAL'})
                                        for d in dias_rango:
                                            if (d, emp.strip()) not in claves_existentes:
                                                try:
                                                    from core.utils import es_feriado_mexico
                                                    es_fer, nom_fer = es_feriado_mexico(d)
                                                except Exception:
                                                    es_fer, nom_fer = False, ""

                                                es_domingo = (d.weekday() == 6)
                                                if es_fer:
                                                    estatus_dia = "DESCANSO OBLIGATORIO"
                                                    obs_dia = f"Descanso obligatorio ({nom_fer})"
                                                elif es_domingo:
                                                    estatus_dia = "DESCANSO"
                                                    obs_dia = "Día de descanso semanal"
                                                else:
                                                    estatus_dia = "FALTA"
                                                    obs_dia = "Sin registro de asistencia / Falta"
                                                
                                                filas_faltantes.append({
                                                    'id_registro': None,
                                                    'fecha': d,
                                                    'id_empleado': info_emp['id_empleado'],
                                                    'nombre_empleado': emp,
                                                    'depto': info_emp['depto'],
                                                    'hora_entrada': None,
                                                    'hora_salida': None,
                                                    'estatus': estatus_dia,
                                                    'observaciones': obs_dia,
                                                    'hora_entrada_v': None,
                                                    'hora_salida_v': None,
                                                    'tipo_registro': '❌ Sin Registro',
                                                    'origen': 'SISTEMA'
                                                })

                                    if filas_faltantes:
                                        df_faltantes = pd.DataFrame(filas_faltantes)
                                        df_asist_filt = pd.concat([df_asist_filt, df_faltantes], ignore_index=True)

                            if est_sel != "Todos":
                                df_asist_filt = df_asist_filt[df_asist_filt['estatus'] == est_sel]
                            
                            st.divider()
                            
                            opcion_formato = st.radio(
                                "Formato de Visualización del Reporte:", 
                                [
                                    "💰 Resumen de Nómina (Totales)",
                                    "📋 Vista Sábana / Matriz (Estilo Excel)", 
                                    "🗂️ Vista Plana Tradicional (Bitácora)",
                                    "⏱️ Radar de Retardos (Segmentación)"
                                ], 
                                horizontal=True,
                                key="radio_formato_reporte_asistencia"
                            )
                            st.write("")
                            
                            # ==============================================================
                            # 1️⃣ NUEVA VISTA: RESUMEN DE NÓMINA (Totales calculados)
                            # ==============================================================
                            if opcion_formato == "💰 Resumen de Nómina (Totales)":
                                if not df_asist_filt.empty:
                                    st.markdown("##### 💰 Resumen de Nómina (Totales por Empleado)")
                                    st.info("💡 Este reporte consolida los días del periodo seleccionado. 3 retardos calculan 1 falta administrativa de forma automática.")
                                    
                                    df_detalle = df_asist_filt.copy()
                                    
                                    def clean_time_xls(x):
                                        val = str(x).strip()
                                        tiene_pin = "📍" in val
                                        val_limpio = val.replace(" 📍", "").replace("📍", "").strip()
                                        if pd.isna(x) or val_limpio in ["", "None", "nan", "null", "00:00:00", "00:00", "0:00", "--:--"]: 
                                            return "--:--"
                                        return val_limpio[:5] + (" 📍" if tiene_pin else "")
                                        
                                    df_detalle['hora_entrada'] = df_detalle['hora_entrada'].apply(clean_time_xls)
                                    df_detalle['hora_salida'] = df_detalle['hora_salida'].apply(clean_time_xls)
                                    
                                    resumen_data = []
                                    for nombre_emp, group in df_detalle.groupby('nombre_empleado'):
                                        id_emp = str(group['id_empleado'].iloc[0]).replace(".0", "")
                                        depto = group['depto'].iloc[0]
                                        
                                        # Días laborados solo son aquellos donde sí asistió a trabajar
                                        dias_laborados = len(group[~group['estatus'].str.contains('FALTA|DESCANSO|SIN REGISTRO', na=False, case=False)])
                                        faltas = len(group[group['estatus'].str.contains('FALTA', na=False, case=False)])
                                        retardos = len(group[group['estatus'].str.contains('RETARDO', na=False, case=False)])
                                        vacaciones_incap = len(group[group['estatus'].str.contains('VACACIONES|INCAPACIDAD', na=False, case=False, regex=True)])
                                        
                                        penalizacion = retardos // 3 
                                        
                                        olvidos = len(group[(group['hora_entrada'] != "--:--") & (group['hora_salida'] == "--:--")])
                                        obs_sistema = "🟢 Ok"
                                        if olvidos > 0: obs_sistema = f"⚠️ Falta registrar {olvidos} salida(s)"
                                        elif penalizacion > 0: obs_sistema = "🟡 Aplicar descuento por retardos"
                                        elif faltas > 0: obs_sistema = "🔴 Presenta faltas"
                                        
                                        resumen_data.append({
                                            'ID': id_emp,
                                            'Nombre': nombre_emp,
                                            'Departamento': depto,
                                            'Días Asistidos': dias_laborados,
                                            'Faltas': faltas,
                                            'Retardos Totales': retardos,
                                            'Faltas por Retardo (3x1)': penalizacion,
                                            'Días Vacaciones/Incap.': vacaciones_incap,
                                            'Observaciones del Sistema': obs_sistema
                                        })
                                        
                                    df_resumen_out = pd.DataFrame(resumen_data).sort_values(by='Nombre')
                                    
                                    def resaltar_alertas(val):
                                        if isinstance(val, str):
                                            if "⚠️" in val: return 'color: #9f1239; background-color: #ffe4e6; font-weight: bold;'
                                            if "🔴" in val: return 'color: #9f1239; font-weight: bold;'
                                            if "🟡" in val: return 'color: #854d0e; background-color: #fef08a; font-weight: bold;'
                                        return ''

                                    st.dataframe(df_resumen_out.style.map(resaltar_alertas), use_container_width=True, hide_index=True)
                                else:
                                    st.info("📭 No hay registros en este periodo.")
                                    
                            # ==============================================================
                            # 2️⃣ VISTA SÁBANA
                            # ==============================================================
                            elif opcion_formato == "📋 Vista Sábana / Matriz (Estilo Excel)":
                                if not df_asist_filt.empty:
                                    st.markdown("##### 🗂️ Historial de Asistencia por Doble Turno")
                                    
                                    def clean_time(x):
                                        val = str(x).strip()
                                        tiene_pin = "📍" in val
                                        tiene_1d = "(+1D)" in val.upper()
                                        val_limpio = val.replace(" 📍", "").replace("📍", "").replace(" (+1d)", "").replace("(+1d)", "").replace(" (+1D)", "").replace("(+1D)", "").strip()
                                        if pd.isna(x) or val_limpio in ["", "None", "nan", "null", "00:00:00", "00:00", "0:00", "--:--"]: 
                                            return "--:--"
                                        res = val_limpio[:5]
                                        if tiene_1d: res += " (+1d)"
                                        if tiene_pin: res += " 📍"
                                        return res
                                        
                                    records = []
                                    dias_semana_es = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
                                    df_asist_ordenado = df_asist_filt.sort_values(by=['fecha', 'nombre_empleado'], ascending=[False, True])
                                    
                                    for _, row in df_asist_ordenado.iterrows():
                                        m_in = clean_time(row.get('hora_entrada'))
                                        m_out = clean_time(row.get('hora_salida'))
                                        v_in = clean_time(row.get('hora_entrada_v'))
                                        v_out = clean_time(row.get('hora_salida_v'))
                                        
                                        # 🌙 REGLA OPERATIVA 1: Si la entrada es a partir de las 12:00 md y no hay vespertino,
                                        # corresponde al Turno Vespertino:
                                        h_in_limpia = m_in.replace(" 📍", "").replace(" (+1d)", "").strip()
                                        if h_in_limpia not in ["--:--", ""] and h_in_limpia >= "12:00" and v_in == "--:--":
                                            v_in = m_in
                                            v_out = m_out
                                            m_in = "--:--"
                                            m_out = "--:--"
                                        
                                        # 🌙 REGLA OPERATIVA 2: Si la salida matutina es tarde en la noche (>= 18:00) y la salida vespertina está vacía,
                                        # corresponde a la salida de fin de jornada (Turno Vespertino Salida):
                                        h_out_limpia = m_out.replace(" 📍", "").replace(" (+1d)", "").strip()
                                        if h_out_limpia not in ["--:--", ""] and h_out_limpia >= "18:00" and v_out == "--:--":
                                            v_out = m_out
                                            m_out = "--:--"

                                        # 🌙 REGLA OPERATIVA 3: Si la bitácora indica salida de madrugada del día siguiente (+1d)
                                        obs_text = str(row.get('observaciones', '')).upper()
                                        if ("(+1D)" in obs_text or "MADRUGADA" in obs_text) and v_out != "--:--":
                                            if "(+1D)" not in v_out.upper():
                                                if "📍" in v_out:
                                                    v_out = v_out.replace(" 📍", " (+1d) 📍")
                                                else:
                                                    v_out += " (+1d)"

                                        # 🌙 REGLA OPERATIVA 4: Continuación de jornada nocturna
                                        # Si hora_entrada = 00:00 y hay hora_salida_v pero no hay vespertino,
                                        # colocar en turno vespertino como jornada nocturna continua
                                        if m_in == "00:00" and v_in == "--:--" and v_out == "--:--":
                                            v_in = "00:00 🌙"
                                            v_out = m_out if m_out != "--:--" else "--:--"
                                            # m_out ya tiene el valor de hora_salida si existe; usar hora_salida_v si m_out vacío
                                            raw_v_out = clean_time(row.get('hora_salida_v'))
                                            if raw_v_out != "--:--":
                                                v_out = raw_v_out
                                            m_in = "--:--"
                                            m_out = "--:--"

                                        # 📍 Asegurar el PIN si el registro o la checada proviene de Coordinación / En Gira
                                        obs_text = str(row.get('observaciones', '')).upper()
                                        tipo_reg = str(row.get('tipo_registro', '')).upper()
                                        origen_reg = str(row.get('origen', '')).upper()
                                        
                                        # 1. Entrada hecha por el Coordinador
                                        es_entrada_coord = (
                                            "ENTRADA COORD" in obs_text or 
                                            "[EN GIRA] ENTRADA" in obs_text or 
                                            "ENTRADA:" in obs_text or
                                            tipo_reg == "📍 GIRA 100%" or 
                                            origen_reg == "LOCACION"
                                        )
                                        if es_entrada_coord:
                                            if m_in != "--:--" and "📍" not in m_in and not obs_text.startswith("KIOSCO - T. MATUTINO"):
                                                m_in += " 📍"
                                            if v_in != "--:--" and "📍" not in v_in and not obs_text.startswith("KIOSCO - T. VESPERTINO"):
                                                v_in += " 📍"

                                        # 2. Salida hecha por el Coordinador
                                        es_salida_coord = (
                                            "SALIDA COORD" in obs_text or 
                                            "[EN GIRA] SALIDA" in obs_text or 
                                            "SALIDA FIN JORNADA" in obs_text or 
                                            ("[EN GIRA]" in obs_text and "KIOSCO" not in obs_text.split("|")[-1]) or
                                            tipo_reg == "📍 GIRA 100%" or 
                                            origen_reg == "LOCACION"
                                        )
                                        if es_salida_coord:
                                            if v_out != "--:--" and "📍" not in v_out:
                                                v_out += " 📍"
                                            if m_out != "--:--" and "📍" not in m_out and "KIOSCO" not in obs_text.split("|")[-1]:
                                                m_out += " 📍"
                                        
                                        fecha = row['fecha']
                                        try:
                                            f_dt = pd.to_datetime(fecha)
                                            nom_dia = dias_semana_es[f_dt.weekday()]
                                            fecha_str = f_dt.strftime('%d/%m/%Y')
                                        except Exception:
                                            nom_dia = ""
                                            fecha_str = str(fecha)
                                        
                                        records.append({
                                            ("👤 Datos del Empleado", "Día"): nom_dia,
                                            ("👤 Datos del Empleado", "Fecha"): fecha_str,
                                            ("👤 Datos del Empleado", "ID"): str(row.get('id_empleado', '0')).strip(),
                                            ("👤 Datos del Empleado", "Nombre"): row['nombre_empleado'],
                                            ("👤 Datos del Empleado", "Depto"): row['depto'],
                                            ("☀️ Turno Matutino", "Entrada"): m_in,
                                            ("☀️ Turno Matutino", "Salida"): m_out,
                                            ("🌙 Turno Vespertino", "Entrada"): v_in,
                                            ("🌙 Turno Vespertino", "Salida"): v_out
                                        })
                                        
                                    df_final_turnos = pd.DataFrame(records)
                                    
                                    if not df_final_turnos.empty:
                                        df_final_turnos.columns = pd.MultiIndex.from_tuples(df_final_turnos.columns)
                                        
                                        def resaltar_olvidos(val):
                                            if val == "--:--": return 'color: #9f1239; background-color: #ffe4e6; font-weight: bold;'
                                            return ''
                                            
                                        st.dataframe(df_final_turnos.style.map(resaltar_olvidos), use_container_width=True, hide_index=True)
                                    else:
                                        st.info("📭 No se pudo procesar la matriz de turnos.")
                                else:
                                    st.info("📭 No hay registros que coincidan con los filtros seleccionados.")
                                    
                            # ==============================================================
                            # 3️⃣ VISTA PLANA / EDICIÓN
                            # ==============================================================
                            elif opcion_formato == "🗂️ Vista Plana Tradicional (Bitácora)":
                                if not df_asist_filt.empty:
                                    st.markdown("##### 🗂️ Edición y Corrección de Bitácoras (Auditoría)")
                                    st.info("💡 Modifica las horas o el Estatus directamente en la tabla y presiona Guardar.")
                                    
                                    df_editable = df_asist_filt[['id_registro', 'fecha', 'id_empleado', 'nombre_empleado', 'depto', 'hora_entrada', 'hora_salida', 'estatus', 'observaciones', 'tipo_registro']].copy()
                                    
                                    def format_hms(val):
                                        val = str(val).strip()
                                        val_limpio = val.replace(" 📍", "").replace("📍", "").strip()
                                        if pd.isna(val) or val_limpio in ["", "None", "nan", "null", "00:00:00", "00:00", "0:00"]: return ""
                                        return val_limpio[:8]
                                        
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
                                            "tipo_registro": st.column_config.TextColumn("Origen (Físico/Gira)", disabled=True),
                                            "hora_entrada": st.column_config.TextColumn("Entrada"),
                                            "hora_salida": st.column_config.TextColumn("Salida"),
                                            "estatus": st.column_config.SelectboxColumn(
                                                "Estatus", 
                                                options=["ASISTENCIA", "RETARDO", "FALTA", "COMISIÓN LOCAL", "PERMISO C/SUELDO", "PERMISO S/SUELDO", "VACACIONES", "INCAPACIDAD", "VIAJE DE RUTA", "GIRA / LOCACIÓN"]
                                            ),
                                            "observaciones": st.column_config.TextColumn("Bitácora de Registro")
                                        }, 
                                        use_container_width=True, hide_index=True, key="editor_asistencia_gerencial"
                                    )
                                    
                                    st.write("")
                                    if st.button("💾 GUARDAR CAMBIOS DE AUDITORÍA", type="primary", use_container_width=True):
                                        cambios = []
                                        for idx, row in edited_asist.iterrows():
                                            orig_row = df_editable.iloc[idx]
                                            if (str(row['hora_entrada']) != str(orig_row['hora_entrada']) or str(row['hora_salida']) != str(orig_row['hora_salida']) or str(row['estatus']) != str(orig_row['estatus']) or str(row['observaciones']) != str(orig_row['observaciones'])):
                                                cambios.append({
                                                    "id_registro": int(row['id_registro'] if pd.notna(row['id_registro']) else 0),
                                                    "hora_entrada": str(row['hora_entrada']).replace("None", "").strip(),
                                                    "hora_salida": str(row['hora_salida']).replace("None", "").strip(),
                                                    "estatus": str(row['estatus']).strip(),
                                                    "observaciones": str(row['observaciones']).strip()
                                                })
                                                
                                        if cambios:
                                            res_cambios = requests.post(f"{API_URL}/api/asistencia/guardar-cambios", json=cambios, verify=False)
                                            if res_cambios.status_code == 200:
                                                st.success("✅ Cambios guardados y justificados con éxito en el expediente.")
                                                import time
                                                time.sleep(1.5)
                                                st.rerun()
                                            else:
                                                st.error(f"❌ Error al guardar en base de datos: {res_cambios.text}")
                                        else:
                                            st.info("No se detectaron modificaciones en la tabla.")
                                else:
                                    st.info("📭 No hay registros que coincidan con los filtros seleccionados.")
                                    
                            # ==============================================================
                            # 4️⃣ VISTA RADAR
                            # ==============================================================
                            elif "Radar" in opcion_formato:
                                if not df_asist_filt.empty:
                                    st.markdown("##### ⏱️ Personal por Horario de Llegada")
                                    
                                    df_entradas = df_asist_filt.copy()
                                    df_entradas = df_entradas.dropna(subset=['hora_entrada'])
                                    df_entradas = df_entradas.sort_values('hora_entrada').groupby(['fecha', 'nombre_empleado']).first().reset_index()
                                    
                                    def clasificar_llegada(hora_str):
                                        try:
                                            hora_limpia = str(hora_str).replace(" 📍", "").replace("📍", "").strip()[:5]
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
                                    
                                    st.dataframe(df_agrupado, use_container_width=True, hide_index=True)
                                else:
                                    st.info("📭 No hay registros matutinos para segmentar en este periodo.")
                        else:
                            st.info("📭 No hay registros de asistencia en la base de datos general.")
                    else:
                        st.error(f"❌ Error del servidor (Código {res_rep.status_code}): No se encontró el endpoint de asistencia.")
                except Exception as e_asist:
                    st.error(f"❌ Fallo crítico al compilar auditoría: {e_asist}")