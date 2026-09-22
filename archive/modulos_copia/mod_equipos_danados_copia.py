import streamlit as st
import requests
import pandas as pd
import datetime
import time
import plotly.express as px
import urllib.parse

def renderizar_modulo(API_URL):
    rol = st.session_state.get('rol', '')
    user_id = str(st.session_state.get('id_usuario', '000'))
    depto_usuario = st.session_state.get('depto', 'OFICINA')
    operador = st.session_state.get('usuario_actual', 'OPERADOR')
    nombre_usuario = operador.upper()

    if "AGUNDEZ" in nombre_usuario or "VILLARREAL" in nombre_usuario: 
        st.markdown("## 🚀 Radar Global: Control de Equipos y Hardware en Taller/Falla")
    elif rol == "PRODUCTOR": 
        st.markdown(f"## 📢 Radar de Departamento: {depto_usuario}")
    else: 
        st.markdown("## 🚩 Mis Reportes Personales de Hardware y Equipo")

    st.caption("Consola unificada con seguimiento de tickets activos en la tabla de reparaciones.")
    
    tab_radar, tab_expediente = st.tabs(["🚨 Radar y Reportes Activos", "📖 Expediente Clínico (Historial)"])

    # =========================================================
    # PESTAÑA 1: TU CÓDIGO ACTUAL (RADAR)
    # =========================================================
    with tab_radar:
        # 1️⃣ FORMULARIO DUAL: REPORTE MANUAL DE OFICINA / BODEGA
        with st.expander("🛠️ REGISTRAR REPORTE DIRECTO DE OFICINA / MANTENIMIENTO INTERNO", expanded=False):
            codigos_inv = []
            try:
                res_inv_lista = requests.get(f"{API_URL}/api/inventario/catalogo-global", verify=False, timeout=5)
                if res_inv_lista.status_code == 200:
                    codigos_inv = res_inv_lista.json()
            except: 
                codigos_inv = []
        
            c_c1, c_c2 = st.columns([2, 1])
            eq_seleccionado = c_c1.selectbox("🔍 Selecciona el Equipo / Activo de Oficina:", options=["---"] + codigos_inv, key="manual_eq_sel")
            tipo_log = c_c2.selectbox("🩺 Tipo de Evento:", ["MANTENIMIENTO_TÉCNICO", "FALLA_OPERATIVA", "DAÑO_FÍSICO_OFICINA", "RESPALDO_SISTEMAS"], key="manual_tipo_log")
        
            c_c3, c_c4 = st.columns(2)
            est_final = c_c3.selectbox("📊 Estado Inicial del Ticket:", ["PENDIENTE", "EN TALLER", "DAÑADO", "BAJA"], key="manual_est_final")
            costo_asoc = c_c4.number_input("💰 Costo Estimado Reparación ($):", min_value=0.0, value=0.0, step=50.0, key="manual_costo_asoc")
        
            txt_bitacora = st.text_area("📝 Diagnóstico / Detalle del Daño:", placeholder="Ej. El aire acondicionado tira agua sobre la mesa...", key="manual_txt_bitacora")
            foto_evidencia = st.file_uploader("📸 Adjuntar Evidencia Fotográfica (Opcional):", type=["png", "jpg", "jpeg"], key="manual_foto_evidencia")
        
            if "boton_reporte_bloqueado" not in st.session_state:
                st.session_state.boton_reporte_bloqueado = False

            if st.button("💾 REGISTRAR TICKET EN POSTGRES", width=True, type="primary", key="manual_btn_save", disabled=st.session_state.boton_reporte_bloqueado):
                if eq_seleccionado == "---" or not txt_bitacora.strip():
                    st.warning("⚠️ Por favor selecciona un equipo y escribe el detalle del reporte.")
                else:
                    st.session_state.boton_reporte_bloqueado = True
                    cod_puro = eq_seleccionado.split(" - ")[0].strip() if " - " in eq_seleccionado else eq_seleccionado.strip()
                
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
                
                    try:
                        res_m_save = requests.post(f"{API_URL}/api/inventario/historial/guardar", json=payload_manual, verify=False, timeout=8)
                        if res_m_save.status_code == 200:
                            if foto_evidencia is not None:
                                files = {"file": (foto_evidencia.name, foto_evidencia.getvalue(), foto_evidencia.type)}
                                data = {"codigo_equipo": cod_puro, "folio_vpro": "MANTENIMIENTO_INTERNO"}
                                requests.post(f"{API_URL}/api/inventario/subir-evidencia", files=files, data=data, verify=False, timeout=8)

                            st.success("🔒 ¡Ticket registrado en Postgres!")
                            time.sleep(1.2)
                            st.session_state.boton_reporte_bloqueado = False
                            st.rerun()
                        else: 
                            st.error(f"❌ Error en base de datos: {res_m_save.text}")
                            st.session_state.boton_reporte_bloqueado = False
                    except Exception as ex_m:
                        st.error(f"📡 Error de comunicación: {ex_m}")
                        st.session_state.boton_reporte_bloqueado = False

        st.divider()

        # 2️⃣ CONSULTA AL RADAR DE DAÑOS
        df_base = pd.DataFrame()
        try:
            res_danos = requests.get(f"{API_URL}/api/inventario/radar-danos", verify=False, timeout=8)
            if res_danos.status_code == 200:
                raw_data = res_danos.json()
                if raw_data:
                    df_base = pd.DataFrame(raw_data)
            else: 
                st.error(f"❌ Error al consultar reparaciones: {res_danos.text}")
                st.stop()
        except Exception as e: 
            st.error(f"📡 Error de comunicación: {e}")
            st.stop()

        if not df_base.empty:
            df_base['FECHA_REPORTE'] = pd.to_datetime(df_base['FECHA_REPORTE'], errors='coerce').dt.date
            df_base['FECHA_REPORTE'] = df_base['FECHA_REPORTE'].fillna(datetime.date.today())
        
            hoy = datetime.date.today()
            df_base['DÍAS_INACTIVO'] = df_base['FECHA_REPORTE'].apply(lambda f: (hoy - f).days if pd.notnull(f) else 0)

            # FILTROS
            st.markdown("### 🎯 Filtros de Auditoría de Hardware")
            c1, c2, c3 = st.columns(3)
        
            fd_min = df_base['FECHA_REPORTE'].min()
            fd_max = df_base['FECHA_REPORTE'].max()
        
            with c1: 
                rango_fechas_danos = st.date_input("📅 Periodo:", [fd_min, fd_max], key="danos_rango_fechas")
            with c2:
                lista_deptos_danos = ["Todos", "ADMINISTRACION", "EDICION", "PRODUCCION", "SISTEMAS", "VENTAS"]
                depto_sel_danos = st.selectbox("🏢 Departamento:", lista_deptos_danos, key="danos_depto_select")
            with c3:
                df_temp_emp_danos = df_base.copy()
                empleados_danos = ["Todos"] + sorted(df_temp_emp_danos['REPORTÓ'].dropna().unique().tolist())
                emp_sel_danos = st.selectbox("👤 Reportante / Responsable:", empleados_danos, key="danos_emp_select")

            df_filtrado_danos = df_base.copy()

            if isinstance(rango_fechas_danos, (list, tuple)) and len(rango_fechas_danos) == 2:
                df_filtrado_danos = df_filtrado_danos[(df_filtrado_danos['FECHA_REPORTE'] >= rango_fechas_danos[0]) & (df_filtrado_danos['FECHA_REPORTE'] <= rango_fechas_danos[1])]
            if depto_sel_danos != "Todos":
                df_filtrado_danos = df_filtrado_danos[df_filtrado_danos['DEPARTAMENTO'] == depto_sel_danos]
            if emp_sel_danos != "Todos":
                df_filtrado_danos = df_filtrado_danos[df_filtrado_danos['REPORTÓ'] == emp_sel_danos]

            # METRICAS
            m1, m2, m3, m4 = st.columns(4)
            m1.metric("Tickets Activos en Taller", len(df_filtrado_danos))
            prom_dias = int(df_filtrado_danos['DÍAS_INACTIVO'].mean()) if not df_filtrado_danos.empty else 0
            m2.metric("Promedio Días Fuera", f"{prom_dias} Días")
            top_emp = df_filtrado_danos['REPORTÓ'].value_counts().index[0] if not df_filtrado_danos.empty else "N/A"
            m3.metric("Mayor Reportante", top_emp)
            top_dep = df_filtrado_danos['DEPARTAMENTO'].value_counts().index[0] if not df_filtrado_danos.empty else "N/A"
            m4.metric("Área Principal", top_dep)

            st.divider()
            st.markdown("### 📊 Gráfico de Inactividad por Personal")
            df_conteo = df_filtrado_danos['REPORTÓ'].value_counts().reset_index()
            df_conteo.columns = ['Reportante', 'Tickets Activos']
        
            fig = px.bar(
                df_conteo, x='Reportante', y='Tickets Activos', text='Tickets Activos',
                color='Tickets Activos', color_continuous_scale='Reds', template='plotly_dark'
            )
            fig.update_layout(height=350, xaxis_title="Personal", yaxis_title="Cantidad de Registros")
            st.plotly_chart(fig, width=True)

            st.markdown("### 📋 Matriz Activa de Reparaciones")
            columnas_visibles = ['NUM_SERVICIO', 'FECHA_REPORTE', 'DÍAS_INACTIVO', 'ID', 'EQUIPO', 'DEPARTAMENTO', 'REPORTÓ', 'ESTADO', 'FALLA', 'COSTO']
            cols_finales = [c for c in columnas_visibles if c in df_filtrado_danos.columns]
        
            st.dataframe(
                df_filtrado_danos[cols_finales], 
                width=True, 
                hide_index=True,
                column_config={
                    "NUM_SERVICIO": st.column_config.TextColumn("Ticket #"),
                    "DÍAS_INACTIVO": st.column_config.NumberColumn("⏱️ Días Fuera", format="%d días"),
                    "COSTO": st.column_config.NumberColumn("Costo Estimado", format="$%.2f")
                }
            )

            # 3️⃣ MÓDULO DE RESOLUCIÓN Y CIERRE DE TICKETS
            st.divider()
            st.markdown("### ⚙️ Actualizar o Cerrar Ticket de Reparación")
            col_sel_t, col_accion = st.columns([2, 1])
        
            opciones_tickets = df_filtrado_danos['NUM_SERVICIO'].dropna().tolist()
            ticket_elegido = col_sel_t.selectbox("Seleccione Ticket para resolver:", options=["---"] + opciones_tickets, key="sel_ticket_cerrar")
            nuevo_estatus_ticket = col_accion.selectbox("Nuevo Estado:", ["RESUELTO", "REPARADO", "BAJA DEFINITIVA"], key="sel_estatus_cerrar")
        
            if st.button("✅ REHABILITAR EQUIPO / CERRAR TICKET", width=True, type="primary", key="btn_cerrar_ticket"):
                if ticket_elegido != "---":
                    res_cierre = requests.post(f"{API_URL}/api/inventario/reparacion/cerrar/{ticket_elegido}", json={"estado_actual": nuevo_estatus_ticket}, verify=False)
                    if res_cierre.status_code == 200:
                        st.success(f"✅ Ticket {ticket_elegido} marcado como {nuevo_estatus_ticket}. Equipo rehabilitado.")
                        time.sleep(1.2)
                        st.rerun()
                    else:
                        st.error(f"❌ Error al actualizar ticket: {res_cierre.text}")
        else: 
            st.success("✅ Operación Limpia: La tabla public.reparaciones no contiene tickets pendientes.")
            
    # =========================================================
    # PESTAÑA 2: EL NUEVO EXPEDIENTE CLÍNICO (CON FOTO INTEGRADA)
    # =========================================================
    with tab_expediente:
        st.markdown("### 🔍 Rastreador de Historial de Equipo")
        
        # Reutilizamos la lista de equipos que ya tienes consultada
        eq_buscar = st.selectbox("Selecciona o escribe el equipo a auditar:", options=["---"] + codigos_inv, key="exp_eq_sel")
        
        if eq_buscar != "---":
            cod_puro_exp = eq_buscar.split(" - ")[0].strip() if " - " in eq_buscar else eq_buscar.strip()
            
            if st.button("🔎 Buscar Expediente y Fotos", type="primary"):
                try:
                    # 🌟 Convertimos los espacios en formato seguro para internet
                    cod_seguro = urllib.parse.quote(cod_puro_exp)
                    res_exp = requests.get(f"{API_URL}/api/inventario/expediente/{cod_seguro}", verify=False, timeout=8)
                    
                    if res_exp.status_code == 200:
                        datos_exp = res_exp.json()
                        df_hist = pd.DataFrame(datos_exp.get("historial", []))
                        fotos = datos_exp.get("fotos", [])
                        
                        # Extraemos el estatus más reciente del historial
                        estatus_actual = df_hist.iloc[0]["ESTADO POSTERIOR"] if not df_hist.empty else "DESCONOCIDO"

                        # 🌟 DISEÑO DE TARJETA: EXPEDIENTE Y FOTO
                        st.markdown(f"### 📁 Expediente Clínico: `{cod_puro_exp}`")
                        
                        col_info, col_foto = st.columns([2, 1])
                        
                        with col_info:
                            # Tarjeta de información del equipo
                            st.info(f"**Equipo:** {eq_buscar}\n\n**Estatus Actual:** {estatus_actual}")
                        
                        with col_foto:
                            # 📸 Mostrar la foto si existe
                            if fotos:
                                url_base = API_URL.rstrip('/')
                                url_foto_segura = urllib.parse.quote(fotos[0], safe="/")
                                ruta_final = f"{url_base}/{url_foto_segura}"
                                
                                try:
                                    img_res = requests.get(ruta_final, verify=False, timeout=8)
                                    if img_res.status_code == 200:
                                        st.image(img_res.content, width=True, caption="📸 Evidencia actual")
                                    else:
                                        st.warning("⚠️ No se pudo cargar la imagen del servidor.")
                                except:
                                    st.warning("⚠️ Error de conexión al servidor de imágenes.")
                            else:
                                st.warning("📷 No hay foto registrada para este equipo.")
                            
                            # Uploader para subir/actualizar foto
                            nueva_foto = st.file_uploader("Subir/Actualizar foto:", type=["png", "jpg", "jpeg"], key="up_foto_exp")
                            if nueva_foto is not None:
                                st.caption("Haz clic en un botón de registro para guardar esta nueva foto.")

                        st.divider()

                        # 📜 Mostrar el historial de movimientos
                        st.markdown("#### ⏳ Historial de Reparaciones y Movimientos")
                        if not df_hist.empty:
                            st.dataframe(
                                df_hist, 
                                width=True, 
                                hide_index=True
                            )
                        else:
                            st.info("No hay historial registrado para este equipo.")
                            
                except Exception as e:
                    st.error(f"Error de conexión: {e}")