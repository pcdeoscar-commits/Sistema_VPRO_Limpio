import streamlit as st
import requests
import pandas as pd
import datetime
import time
from io import BytesIO
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors

# 📄 GENERADOR DUAL DE PDF (PARA COMPROBACIÓN DE GASTOS VPRO)
def generar_pdf_gastos(resumen, df_detalle):
    buffer = BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=letter, rightMargin=30, leftMargin=30, topMargin=30, bottomMargin=30)
    story = []
    styles = getSampleStyleSheet()
    
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Heading1'],
        fontSize=16,
        leading=20,
        textColor=colors.HexColor('#1e293b'),
        alignment=1
    )
    
    label_style = ParagraphStyle(
        'DocLabel',
        parent=styles['Normal'],
        fontSize=9,
        leading=12,
        textColor=colors.HexColor('#475569')
    )
    
    story.append(Paragraph("<b>PRODUCCIONES VPRO S.A. DE C.V.</b>", title_style))
    story.append(Paragraph("INFORME DE RENDICIÓN DE CUENTAS Y COMPROBACIÓN DE GASTOS", ParagraphStyle('Sub', parent=title_style, fontSize=11, leading=14)))
    story.append(Spacer(1, 15))
    
    data_encabezado = [
        [Paragraph(f"<b>Folio Evento:</b> {resumen.get('folio', '')}", label_style), Paragraph(f"<b>Empleado:</b> {resumen.get('nombre', '')}", label_style)],
        [Paragraph(f"<b>Departamento:</b> {resumen.get('depto', '')}", label_style), Paragraph(f"<b>Vehículo/Unidades:</b> {resumen.get('vehiculo', '')}", label_style)],
        [Paragraph(f"<b>Presupuesto Entregado:</b> ${resumen.get('entregado', 0.0):,.2f}", label_style), Paragraph(f"<b>Total Gastado:</b> ${resumen.get('subtotal', 0.0):,.2f}", label_style)],
        [Paragraph(f"<b>Remanente/Devolución:</b> ${resumen.get('restante', 0.0):,.2f}", label_style), Paragraph(f"<b>Rango Odómetro:</b> {resumen.get('km_i', 0):,} - {resumen.get('km_f', 0):,} KM", label_style)]
    ]
    
    t_enc = Table(data_encabezado, colWidths=[270, 270])
    t_enc.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#f8fafc')),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor('#cbd5e1')),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('PADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(t_enc)
    story.append(Spacer(1, 15))
    
    # Tabla de Desglose
    tabla_data = [list(df_detalle.columns)]
    for _, row in df_detalle.iterrows():
        fila = []
        for col_name in df_detalle.columns:
            val = row[col_name]
            if isinstance(val, (int, float)):
                fila.append(f"${val:,.2f}")
            else:
                fila.append(str(val))
        tabla_data.append(fila)
        
    t_det = Table(tabla_data, colWidths=[60] + [53]*(len(df_detalle.columns)-1))
    t_det.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#0f172a')),
        ('TEXTCOLOR', (0,0), (-1,0), colors.white),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,-1), 8),
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#cbd5e1')),
        ('BACKGROUND', (0,-1), (-1,-1), colors.HexColor('#f1f5f9')),
        ('FONTNAME', (0,-1), (-1,-1), 'Helvetica-Bold'),
    ]))
    story.append(t_det)
    
    doc.build(story)
    return buffer.getvalue()

def parsed_array(raw_val):
    if not raw_val: return []
    if isinstance(raw_val, list): return raw_val
    s = str(raw_val).strip()
    if s.startswith('{') and s.endswith('}'): s = s[1:-1]
    return [x.strip().replace('"', '') for x in s.split(',') if x.strip()]

def renderizar_modulo(API_URL):
    operador = st.session_state.get('usuario_actual', 'OPERADOR')
    id_usuario = str(st.session_state.get('id_usuario', '000'))
    depto_usuario = st.session_state.get('depto', 'OFICINA')
    rol_usuario = st.session_state.get('role', st.session_state.get('rol', ''))
    nombre_usuario = operador.upper()
    
    es_auditor = rol_usuario in ["ADMIN", "COORDINADOR"] or "ANA" in nombre_usuario or "LILIA" in nombre_usuario
    es_ana_lilia_directiva = "ANA" in nombre_usuario or "LILIA" in nombre_usuario
    
    st.markdown("## 💸 Rendición de Cuentas y Control de Gastos Operativos")
    
    if es_auditor:
        if es_ana_lilia_directiva or st.session_state.get("folio_auditoria_gastos"):
            tab_auditoria, tab_captura = st.tabs(["🔍 Panel de Auditoría y Aprobación (Ana Lilia)", "📝 Rendición de Cuentas (Productor)"])
        else:
            tab_captura, tab_auditoria = st.tabs(["📝 Rendición de Cuentas (Productor)", "🔍 Panel de Auditoría y Aprobación (Ana Lilia)"])
    else:
        tab_captura, tab_mi_historial = st.tabs(["📝 Rendición de Cuentas (Productor)", "📦 Mis Informes Archivados"])

    # ==========================================
    # PESTAÑA 1: CAPTURA PARA PRODUCTORES
    # ==========================================
    with tab_captura:
        st.subheader("Registro y Balance de Gastos Operativos")
        cats = ["Hotel", "Transp", "Combust", "Casetas", "Desay", "Comida", "Cenas", "Varios"]
        folios_p = ["--- Seleccionar Folio Pendiente ---"]
        
        try:
            res_fol = requests.get(f"{API_URL}/api/gastos/folios-pendientes", verify=False, timeout=5)
            if res_fol.status_code == 200:
                folios_p += [f"{x['id_evento']} - {x['cliente']} | {x['nombre_evento']}" for x in res_fol.json()]
            else:
                st.caption(f"⚠️ Nota de Caja Chica: No se pudieron indexar folios pendientes (Código {res_fol.status_code}).")
        except Exception as e_gastos: 
            st.caption(f"💡 Módulo financiero: Sincronizando marcas de red...")

        col1, col2, col3 = st.columns([2, 1, 1])
        sel_folio = col1.selectbox("📋 Seleccione Folio OP a rendir:", options=folios_p, key="gastos_master_folio_sel")
        
        if "---" in sel_folio: 
            st.session_state.panel_vpro_visible = False
            st.info("Seleccione una Orden de Producción activa para desplegar la hoja de comprobación diaria.")
        else:
            folio_id = int(sel_folio.split(" - ")[0])
            resp_de_produccion, f_def, p_num = "NO ASIGNADO", datetime.date.today(), 0
            lista_vehiculos_op = []
    
            ev_data = {}
            try:
                res_ev = requests.get(f"{API_URL}/api/gastos/evento/{folio_id}", verify=False, timeout=5)
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
            if isinstance(raw_cars, list):
                lista_vehiculos_op = raw_cars
            elif isinstance(raw_cars, str) and raw_cars.strip():
                lista_vehiculos_op = parsed_array(raw_cars)

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
                        ultimo_km_registrado = 0
                        try:
                            res_km = requests.get(f"{API_URL}/api/gastos/ultimo-km/{auto_lbl}", verify=False, timeout=3)
                            if res_km.status_code == 200:
                                ultimo_km_registrado = res_km.json().get("ultimo_km", 0)
                        except:
                            pass
                            
                        c_auto, c_kmini, c_kmfin = st.columns([2, 1.5, 1.5])
                        with c_auto: 
                            st.text_input("Unidad:", value=auto_lbl, disabled=True, key=f"txt_auto_{auto}_{folio_id}")
                        with c_kmini: 
                            ki_val = c_kmini.number_input("🏎️ KM Inicial:", min_value=0, value=int(ultimo_km_registrado), key=f"ki_{auto}_{folio_id}")
                        with c_kmfin: 
                            kf_val = c_kmfin.number_input("🏁 KM Final:", min_value=0, value=int(ultimo_km_registrado), key=f"kf_{auto}_{folio_id}")
                        
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
                    df_act = st.data_editor(
                        st.session_state[state_key], use_container_width=True, hide_index=True, key=f"grid_{folio_id}",
                        column_config={
                            "Fecha": st.column_config.TextColumn(disabled=True), 
                            "Total": st.column_config.NumberColumn(format="$%.2f", disabled=True),
                            **{c: st.column_config.NumberColumn(format="$%.2f") for c in cats}
                        }
                    )
                    aplicar = st.form_submit_button("🔄 SUMAR TODOS LOS GASTOS", use_container_width=True)
            
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
                            'folio': str(sel_folio), 'nombre': str(resp_de_produccion), 'depto': str(depto_usuario), 
                            'entregado': float(monto_entregado), 'subtotal': float(total_g), 'restante': float(dif), 
                            'km_i': int(total_km_i), 'km_f': int(total_km_f), 'vehiculo': str(v_txt_detallado), 'num_personas': int(p_num)
                        }
                        pdf_avance = generar_pdf_gastos(r_temp, df_actualizado)
                        col_v, col_x = st.columns([2, 1])
                        col_v.download_button(label="📥 GENERAR Y DESCARGAR PDF", data=pdf_avance, file_name=f"Informe_Gastos_OP_{folio_id}.pdf", mime="application/pdf", use_container_width=True)
                        if col_x.button("✖️ OCULTAR REVISIÓN", use_container_width=True):
                            st.session_state.panel_vpro_visible = False
                            st.rerun()

                with st.container(border=True):
                    st.markdown("### 📊 Balance Financiero del Proyecto")
                    m1, m2, m3 = st.columns(3)
                    m1.metric("💰 PRESUPUESTO ENTREGADO", f"$ {monto_entregado:,.2f}")
                    m2.metric("💳 TOTAL GASTADO EN SET", f"$ {total_g:,.2f}")
                    m3.metric("⚖️ REMANENTE DEVOLUCIÓN", f"$ {dif:,.2f}", delta=dif, delta_color="normal" if dif >= 0 else "inverse")

                if st.button("💾 ENVIAR INFORME COMPLETO Y ARCHIVAR EVENTO", type="primary", use_container_width=True, key="btn_save_gastos_final"):
                    payload_gasto = {
                        "maestro": {
                            "folio_vpro": int(folio_id), "id_empleado": str(id_usuario), "periodo_desde": str(f_desde), 
                            "periodo_hasta": str(datetime.date.today()), "vehiculo": str(v_txt_detallado), "km_inicial": int(total_km_i), 
                            "km_final": int(total_km_f), "departamento": str(depto_usuario), "num_personas": int(p_num), 
                            "subtotal": float(total_g), "monto_entregado": float(monto_entregado), "restante": float(dif)
                        },
                        "detalles": []
                    }
                    for idx, row in df_actualizado.iloc[:-1].iterrows():
                        t_dia = float(sum([row[c] for c in cats]))
                        payload_gasto["detalles"].append({
                            "dia_num": int(idx + 1), "hotel": float(row['Hotel']), "transporte": float(row['Transp']), 
                            "combustible": float(row['Combust']), "casetas": float(row['Casetas']), "desayuno": float(row['Desay']), 
                            "comida": float(row['Comida']), "cenas": float(row['Cenas']), "varios": float(row['Varios']), "total_dia": t_dia
                        })
                    
                    res_save = requests.post(f"{API_URL}/api/gastos/guardar", json=payload_gasto, verify=False)
                    if res_save.status_code == 200:
                        st.success("✅ Informe enviado con éxito. Ana Lilia lo tiene listo para revisión en Auditoría.")
                        st.session_state.panel_vpro_visible = False
                        if f"df_buffer_{folio_id}" in st.session_state: 
                            del st.session_state[f"df_buffer_{folio_id}"]
                        time.sleep(1.5)
                        st.rerun()
                    else: 
                        st.error(f"❌ Error al guardar informe: {res_save.text}")
            else:
                st.info(f"ℹ️ **Responsable en OP:** {responsable_evento} | **Firmado en Terminal:** {st.session_state.usuario_actual}")
                st.error(f"🚫 **ACCESO RESTRINGIDO:** A esta Orden de Producción le corresponde rendir cuentas a: {responsable_evento}")

    # ==========================================
    # PESTAÑA 2: BUZÓN AUDITORÍA (ANA LILIA)
    # ==========================================
    if es_auditor:
        with tab_auditoria:
            st.subheader("🔍 Centro de Control Financiero y Auditoría Exclusiva")
            cats_grid_master = ["Hotel", "Transp", "Combust", "Casetas", "Desay", "Comida", "Cenas", "Varios"]
            
            lista_informes = []
            try:
                res_aud = requests.get(f"{API_URL}/api/gastos/informes-auditoria", verify=False, timeout=5)
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
                    
                    folio_objetivo = st.session_state.get("folio_auditoria_gastos")
                    idx_pre_select = 0
                    
                    for i, inf in enumerate(informes_pendientes):
                        lbl = f"⚠️ Informe #{inf['id_informe']} | OP-{inf['folio_vpro']} - {inf['nombre_evento']} ({inf['nombre_empleado']})"
                        opciones_pendientes.append(lbl)
                        mapa_pendientes[lbl] = inf['id_informe']
                        
                        if folio_objetivo and str(inf['folio_vpro']) == str(folio_objetivo):
                            idx_pre_select = i
                    
                    sel_p = st.selectbox("📥 Selecciona el informe entrante para calificar:", options=opciones_pendientes, index=idx_pre_select, key="audit_pendientes_selectbox")
                    id_p_sel = mapa_pendientes[sel_p]
                    
                    if st.session_state.get("folio_auditoria_gastos"):
                        del st.session_state["folio_auditoria_gastos"]
                    
                    try:
                        res_comp = requests.get(f"{API_URL}/api/gastos/informe-completo/{id_p_sel}", verify=False)
                        if res_comp.status_code == 200:
                            exp = res_comp.json()
                            mae, det = exp["maestro"], exp["detalles"]
                            
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
                            
                            rows_tabla_audit = []
                            for d in det:
                                rows_tabla_audit.append({"Fecha": f"Día {d['dia_num']}", "Hotel": d['hotel'], "Transp": d['transporte'], "Combust": d['combustible'], "Casetas": d['casetas'], "Desay": d['desayuno'], "Comida": d['comida'], "Cenas": d['cenas'], "Varios": d['varios'], "Total": d['total_dia']})
                            df_audit_view = pd.DataFrame(rows_tabla_audit)
                            st.dataframe(df_audit_view, use_container_width=True, hide_index=True, column_config={"Total": st.column_config.NumberColumn(format="$%.2f"), **{c: st.column_config.NumberColumn(format="$%.2f") for c in cats_grid_master}})
                            
                            st.divider()
                            c_btn1, c_btn2 = st.columns([2, 1])
                            r_temp_pdf = {'folio': f"OP-{mae['folio_vpro']}", 'nombre': str(mae['nombre_empleado']), 'depto': str(mae['departamento']), 'entregado': float(mae['monto_entregado']), 'subtotal': float(mae['subtotal']), 'restante': float(mae['restante']), 'km_i': int(mae['km_inicial']), 'km_f': int(mae['km_final']), 'vehiculo': str(mae['vehiculo']), 'num_personas': int(mae.get('num_personas', 0))}
                            pdf_auditoria = generar_pdf_gastos(r_temp_pdf, df_audit_view)
                            
                            c_btn1.download_button(label="📥 IMPRIMIR / DESCARGAR REPORTE OFICIAL PDF", data=pdf_auditoria, file_name=f"Validacion_Gastos_OP_{mae['folio_vpro']}.pdf", mime="application/pdf", use_container_width=True, key=f"dl_btn_p_{mae['id_informe']}")
                            
                            if c_btn2.button("✅ MARCAR COMO REVISADO Y APROBADO", type="primary", use_container_width=True, key=f"chk_btn_p_{mae['id_informe']}"):
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
                            mae_h, det_h = exp_h["maestro"], exp_h["detalles"]
                            
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
                            
                            df_h_editado = st.data_editor(
                                df_h_view, use_container_width=True, hide_index=True, disabled=not es_ana_lilia_directiva, 
                                column_config={"Total": st.column_config.NumberColumn(format="$%.2f", disabled=True), "Fecha": st.column_config.TextColumn(disabled=True), **{c: st.column_config.NumberColumn(format="$%.2f") for c in cats_grid_master}},
                                key=f"editor_historial_admin_{id_h_sel}"
                            )
                            
                            if es_ana_lilia_directiva and not df_h_editado.equals(df_h_view):
                                st.warning("⚠️ Modificaste los montos. Guarda los cambios para recalcular los totales en la base de datos.")
                                if st.button("💾 GUARDAR CORRECCIONES AL HISTÓRICO", type="primary", use_container_width=True):
                                    payload_mod = {"id_informe": id_h_sel, "detalles": []}
                                    for idx_mod, row_mod in df_h_editado.iterrows():
                                        t_dia = float(sum([pd.to_numeric(row_mod[c], errors='coerce') for c in cats_grid_master]))
                                        payload_mod["detalles"].append({
                                            "dia_num": int(str(row_mod['Fecha']).replace("Día ", "")),
                                            "hotel": float(row_mod['Hotel']), "transporte": float(row_mod['Transp']), 
                                            "combustible": float(row_mod['Combust']), "casetas": float(row_mod['Casetas']), 
                                            "desayuno": float(row_mod['Desay']), "comida": float(row_mod['Comida']), 
                                            "cenas": float(row_mod['Cenas']), "varios": float(row_mod['Varios']), "total_dia": t_dia
                                        })
                                    res_mod = requests.post(f"{API_URL}/api/gastos/modificar-historico", json=payload_mod, verify=False)
                                    if res_mod.status_code == 200:
                                        st.success("✅ Histórico corregido y recalculado con éxito.")
                                        time.sleep(1.5); st.rerun()
                                    else:
                                        st.error(f"❌ Error al modificar: {res_mod.text}")

                            r_temp_h_pdf = {'folio': f"OP-{mae_h['folio_vpro']}", 'nombre': str(mae_h['nombre_empleado']), 'depto': str(mae_h['departamento']), 'entregado': float(mae_h['monto_entregado']), 'subtotal': float(mae_h['subtotal']), 'restante': float(mae_h['restante']), 'km_i': int(mae_h['km_inicial']), 'km_f': int(mae_h['km_final']), 'vehiculo': str(mae_h['vehiculo']), 'num_personas': int(mae_h.get('num_personas', 0))}
                            pdf_h_auditoria = generar_pdf_gastos(r_temp_h_pdf, df_h_editado)
                            st.download_button(label="🖨️ VOLVER A IMPRIMIR PDF OFICIAL ARCHIVADO", data=pdf_h_auditoria, file_name=f"Cierre_Gastos_Archivado_OP_{mae_h['folio_vpro']}.pdf", mime="application/pdf", use_container_width=True, key=f"dl_btn_h_{mae_h['id_informe']}")
                    except Exception as e: st.error(f"❌ Error al jalar registro histórico: {e}")

    # ==========================================
    # PESTAÑA 2 BÓVEDA PRODUCTORES
    # ==========================================
    if not es_auditor:
        with tab_mi_historial:
            st.subheader("Mis Informes Archivados")
            lista_mis_informes = []
            try:
                res_aud = requests.get(f"{API_URL}/api/gastos/informes-auditoria", verify=False, timeout=5)
                if res_aud.status_code == 200: 
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
                        mae_m, det_m = exp_m["maestro"], exp_m["detalles"]
                        
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
                        st.dataframe(df_m_view, use_container_width=True, hide_index=True, column_config={"Total": st.column_config.NumberColumn(format="$%.2f"), **{c: st.column_config.NumberColumn(format="$%.2f") for c in cats_grid_master}})
                        
                        r_temp_m_pdf = {'folio': f"OP-{mae_m['folio_vpro']}", 'nombre': str(mae_m['nombre_empleado']), 'depto': str(mae_m['departamento']), 'entregado': float(mae_m['monto_entregado']), 'subtotal': float(mae_m['subtotal']), 'restante': float(mae_m['restante']), 'km_i': int(mae_m['km_inicial']), 'km_f': int(mae_m['km_final']), 'vehiculo': str(mae_m['vehiculo']), 'num_personas': int(mae_m.get('num_personas', 0))}
                        pdf_m_auditoria = generar_pdf_gastos(r_temp_m_pdf, df_m_view)
                        st.download_button(label="🖨️ DESCARGAR MI PDF OFICIAL ARCHIVADO", data=pdf_m_auditoria, file_name=f"Mi_Cierre_Gastos_OP_{mae_m['folio_vpro']}.pdf", mime="application/pdf", use_container_width=True, key=f"dl_btn_m_{mae_m['id_informe']}")
                except Exception as e: st.error(f"❌ Error al cargar tu historial: {e}")