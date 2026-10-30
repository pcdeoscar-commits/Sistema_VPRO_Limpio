import streamlit as st
import requests
import pandas as pd
import datetime
import time
import plotly.express as px
import urllib.parse
import os
from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus

def renderizar_modulo(API_URL):
    rol = st.session_state.get('rol', '')
    user_id = str(st.session_state.get('id_usuario', '000'))
    depto_usuario = st.session_state.get('depto', 'OFICINA')
    operador = st.session_state.get('usuario_actual', 'OPERADOR')
    nombre_usuario = operador.upper()

    st.markdown("## 🛠️ Centro de Mantenimiento Proactivo y Taller VPRO")
    st.caption("Plataforma integrada de gestión de activos: Tablero Kanban de Taller, Mantenimiento Preventivo y Control de Calidad (QC).")

    # Carga centralizada y segura del catálogo institucional
    codigos_inv = []
    try:
        res_inv_lista = requests.get(f"{API_URL}/api/inventario/catalogo-global", verify=False, timeout=5)
        if res_inv_lista.status_code == 200:
            codigos_inv = res_inv_lista.json()
    except Exception:
        codigos_inv = []

    with st.expander("❓ Ayuda Contextual: ¿Cómo funciona el Módulo de Reparaciones y Taller?"):    # 👉 AYUDA CONTEXTUAL DE TALLER Y MANTENIMIENTO
        st.markdown("""
        ### 🛠️ Módulo de Taller y Mantenimiento
        **Objetivo:** Gestionar y dar seguimiento al hardware que se encuentra dañado o en mantenimiento.
        
        *   **Canal A - Radar de Daños (Retorno de Evento):** Cuando un equipo regresa averiado de llamado y Bodega escribe una incidencia en el Check-in (ej. *'cable roto'*), el sistema lo marca automáticamente como `DAÑADO` y aparece en esta pantalla con prefijo `REP-RUT-` amarrado a su OP.
        *   **Canal B - Reporte Manual (Instalaciones / Oficina):** Cualquier empleado puede usar el botón inferior (`🛠️ REGISTRAR REPORTE DIRECTO`) para reportar una falla de instalaciones (ej. *'El aire acondicionado de Sistemas gotea sobre el escritorio'* o *'La PC de Edición no enciende'*). Se genera un ticket `REP-INT-` y se le asigna folio de Mantenimiento Interno.
        *   **Expediente Clínico integrado:** Haz clic en cualquier ticket de la Matriz para ver el detalle completo y el historial acumulado del equipo.
        
        #### 📋 El Flujo Correcto (Equipos no encontrados en catálogo)
        Si se rompe una silla, una cafetera, una PC nueva o un Mini Split, y al buscarlo en el menú no existe:
        1. **Hablar con el Coordinador / Administrador** e informar que el activo no está registrado.
        2. El Administrador lo da de alta con su código oficial en el módulo de Inventario.
        3. Hasta entonces se selecciona en este formulario para registrar su ticket y evidencia fotográfica.

        #### ⚙️ Proceso de Rehabilitación (Cierre de Ticket)
        **Para que un equipo vuelva a estar disponible para futuros eventos u oficinas:**
        1. Expande el ticket en la Matriz Activa de Reparaciones.
        2. Cambiar su estatus a `REPARADO`, `RESUELTO` o `BAJA DEFINITIVA`.
        3. Presionar el botón de **✅ Cerrar Ticket**.
        """)

        # Botón de Descarga del Manual Oficial PDF
        pdf_path = "Manual_Trazabilidad_Reporte_Equipos_Danados_VPRO.pdf"
        if os.path.exists(pdf_path):
            try:
                with open(pdf_path, "rb") as f_pdf:
                    st.download_button(
                        label="📄 Descargar Manual Oficial de Trazabilidad y Daños (PDF)",
                        data=f_pdf.read(),
                        file_name="Manual_Trazabilidad_Reporte_Equipos_Danados_VPRO.pdf",
                        mime="application/pdf",
                        use_container_width=True
                    )
            except Exception as e:
                print(f"⚠️ SILENCED ERROR in mod_equipos_danados.py: {e}")

    # ═══════════════════════════════════════════════════════════════════════════
    # 3 PESTAÑAS PRINCIPALES DEL SISTEMA
    # ═══════════════════════════════════════════════════════════════════════════
    tab_kanban, tab_preventivo, tab_auditoria = st.tabs([
        "📌 Tablero Kanban de Taller",
        "📅 Radar de Mantenimiento Preventivo",
        "📋 Auditoría, Expedientes y Liberación (QC)"
    ])

    # ─────────────────────────────────────────────────────────────────────────
    # PESTAÑA 1: TABLERO KANBAN DE TALLER
    # ─────────────────────────────────────────────────────────────────────────
    with tab_kanban:
        st.markdown("### 🗂️ Flujo de Trabajo en Taller")
        st.caption("Visualiza el avance de los equipos en reparación y cambia su etapa en tiempo real.")

        kanban_data = {}
        try:
            res_kb = requests.get(f"{API_URL}/api/inventario/mantenimiento/kanban", verify=False, timeout=8)
            if res_kb.status_code == 200:
                kanban_data = res_kb.json().get("kanban", {})
            else:
                st.error(f"Error al consultar Kanban: {res_kb.text}")
        except Exception as e_kb:
            st.error(f"Error de comunicación con API: {e_kb}")

        col_diag, col_ref, col_rep, col_qc = st.columns(4)

        etapas_config = [
            ("DIAGNOSTICO", "🟡 1. Diagnóstico / Revisión", col_diag, "#fef08a", "#854d0e"),
            ("ESPERA_REFACCION", "🟠 2. Espera de Refacción", col_ref, "#fed7aa", "#9a3412"),
            ("EN_REPARACION", "🔵 3. En Mesa de Taller", col_rep, "#bfdbfe", "#1e40af"),
            ("CONTROL_CALIDAD", "🟣 4. Control de Calidad (QC)", col_qc, "#e9d5ff", "#6b21a8")
        ]

        for etapa_key, titulo, columna, bg_color, text_color in etapas_config:
            tickets_etapa = kanban_data.get(etapa_key, [])
            with columna:
                st.markdown(f"""
                <div style="background-color: {bg_color}; color: {text_color}; padding: 8px 12px; border-radius: 8px; font-weight: bold; margin-bottom: 12px; text-align: center; border: 1px solid rgba(0,0,0,0.1);">
                    {titulo} ({len(tickets_etapa)})
                </div>
                """, unsafe_allow_html=True)

                if not tickets_etapa:
                    st.caption("Sin tickets en esta etapa.")
                else:
                    for t in tickets_etapa:
                        ticket_id = t.get("ticket")
                        nom_eq = t.get("nombre_equipo") or t.get("id_equipo")
                        dias = t.get("dias_en_taller", 0)
                        tipo = t.get("tipo_mantenimiento", "CORRECTIVO")
                        encargado = t.get("encargado", "Sin Asignar")
                        costo = float(t.get("costo") or 0.0)
                        badge_tipo = "🟢 PREV" if tipo == "PREVENTIVO" else "🔴 CORR"

                        with st.expander(f"{badge_tipo} **{t.get('id_equipo')}** | ⏱️ {dias}d", expanded=False):
                            st.markdown(f"**Folio:** `{ticket_id}`")
                            st.markdown(f"**Equipo:** {nom_eq}")
                            st.markdown(f"**Reportó:** {t.get('reporto', 'N/A')}")
                            st.markdown(f"**Responsable Taller:** `{encargado}`")
                            if costo > 0:
                                st.markdown(f"**Costo Estimado:** `${costo:,.2f}`")
                            st.info(t.get("falla") or "Sin diagnóstico registrado.")

                            st.divider()
                            st.markdown("**⚙️ Mover a otra fase:**")
                            c_mov1, c_mov2 = st.columns([2, 1])
                            nueva_etapa_sel = c_mov1.selectbox(
                                "Fase:",
                                ["DIAGNOSTICO", "ESPERA_REFACCION", "EN_REPARACION", "CONTROL_CALIDAD"],
                                index=["DIAGNOSTICO", "ESPERA_REFACCION", "EN_REPARACION", "CONTROL_CALIDAD"].index(etapa_key),
                                key=f"kb_sel_{ticket_id}"
                            )
                            if c_mov2.button("➔ Mover", key=f"kb_btn_{ticket_id}", use_container_width=True):
                                res_mov = requests.post(f"{API_URL}/api/inventario/mantenimiento/cambiar-etapa", json={
                                    "num_servicio": ticket_id,
                                    "nueva_etapa": nueva_etapa_sel
                                }, verify=False)
                                if res_mov.status_code == 200:
                                    st.success("¡Etapa actualizada!")
                                    time.sleep(0.8)
                                    st.rerun()
                                else:
                                    st.error(f"Error: {res_mov.text}")

        st.divider()
        st.markdown("💡 *Para liberar definitivamente un equipo que está en 'Control de Calidad' y devolverlo al inventario con estatus OK, utiliza el formulario de la pestaña **📋 Auditoría, Expedientes y Liberación**.*")

    # ─────────────────────────────────────────────────────────────────────────
    # PESTAÑA 2: RADAR DE MANTENIMIENTO PREVENTIVO
    # ─────────────────────────────────────────────────────────────────────────
    with tab_preventivo:
        st.markdown("### 📅 Radar de Mantenimiento Preventivo Periódico")
        st.caption("Programa y monitorea rutinas periódicas de servicio para equipos de alto valor y uso continuo.")

        # Botón rápido para abrir nueva orden preventiva
        with st.expander("⚡ Generar Orden de Mantenimiento Preventivo (Ingresar a Taller)", expanded=False):
            cp1, cp2 = st.columns([2, 1])
            eq_prev_sel = cp1.selectbox("Activo a ingresar a mantenimiento preventivo:", options=["---"] + codigos_inv, key="prev_eq_sel")
            depto_prev = cp2.selectbox("Área / Departamento:", ["OPERACIONES", "SISTEMAS", "PRODUCCION", "OFICINA"], key="prev_depto_sel")
            desc_prev = st.text_area("Descripción de la rutina preventiva:", placeholder="Ej. Limpieza de ventiladores, actualización de firmware y prueba de cables...", key="prev_desc_txt")

            if st.button("🚀 Ingresar a Taller Preventivo", type="primary", key="btn_crear_prev"):
                if eq_prev_sel == "---" or not desc_prev.strip():
                    st.warning("⚠️ Selecciona un equipo y escribe la descripción de la rutina.")
                else:
                    cod_puro_prev = eq_prev_sel.split(" - ")[0].strip() if " - " in eq_prev_sel else eq_prev_sel.strip()
                    payload_prev = {
                        "codigo_equipo": cod_puro_prev,
                        "id_empleado": user_id,
                        "descripcion": desc_prev.strip(),
                        "departamento": depto_prev
                    }
                    try:
                        res_crear_p = requests.post(f"{API_URL}/api/inventario/mantenimiento/crear-ticket-preventivo", json=payload_prev, verify=False, timeout=8)
                        if res_crear_p.status_code == 200:
                            st.success(f"✅ ¡Orden preventiva {res_crear_p.json().get('num_servicio')} creada y agregada al Tablero Kanban!")
                            time.sleep(1.2)
                            st.rerun()
                        else:
                            st.error(f"Error al generar orden: {res_crear_p.text}")
                    except Exception as ex_p:
                        st.error(f"Error de conexión: {ex_p}")

        # Formulario para configurar frecuencia de activo
        with st.expander("⚙️ Configurar Frecuencia Preventiva a un Activo", expanded=False):
            c_f1, c_f2 = st.columns(2)
            eq_prog_sel = c_f1.selectbox("Activo del Catálogo:", options=["---"] + codigos_inv, key="prog_eq_sel")
            frec_dias = c_f2.number_input("Frecuencia recomendada (Días):", min_value=15, max_value=365, value=30, step=15, key="prog_frec_input")

            if st.button("💾 Guardar Plan Preventivo en Activo", key="btn_save_prog"):
                if eq_prog_sel == "---":
                    st.warning("Selecciona un equipo para configurar su plan.")
                else:
                    cod_puro_prog = eq_prog_sel.split(" - ")[0].strip() if " - " in eq_prog_sel else eq_prog_sel.strip()
                    res_prog = requests.post(f"{API_URL}/api/inventario/mantenimiento/programar-preventivo", json={
                        "codigo_equipo": cod_puro_prog,
                        "frecuencia_dias": int(frec_dias)
                    }, verify=False)
                    if res_prog.status_code == 200:
                        st.success("¡Plan preventivo configurado exitosamente!")
                        time.sleep(1.0)
                        st.rerun()
                    else:
                        st.error(f"Error: {res_prog.text}")

        st.divider()

        # Lista de activos con plan preventivo
        lista_prev = []
        try:
            r_prev = requests.get(f"{API_URL}/api/inventario/mantenimiento/preventivos", verify=False, timeout=8)
            if r_prev.status_code == 200:
                lista_prev = r_prev.json()
        except Exception:
            lista_prev = []

        if not lista_prev:
            st.info("ℹ️ Aún no hay equipos con frecuencia preventiva configurada. Utiliza el formulario superior para programar la primera rutina.")
        else:
            df_prev = pd.DataFrame(lista_prev)
            m_p1, m_p2, m_p3 = st.columns(3)
            m_p1.metric("Equipos con Plan Activo", len(df_prev))
            vencidos = len(df_prev[df_prev['semaforo'] == 'VENCIDO']) if 'semaforo' in df_prev.columns else 0
            m_p2.metric("Mantenimientos Vencidos", vencidos, delta=-vencidos if vencidos > 0 else 0)
            al_dia = len(df_prev[df_prev['semaforo'] == 'AL_DIA']) if 'semaforo' in df_prev.columns else 0
            m_p3.metric("Mantenimientos al Día", al_dia)

            st.markdown("#### 📋 Matriz de Próximos Servicios Preventivos")
            for item in lista_prev:
                icono_sem = "🟢" if item["semaforo"] == "AL_DIA" else ("🔴" if item["semaforo"] == "VENCIDO" else "🟠")
                b_color = '#22c55e' if item['semaforo']=='AL_DIA' else ('#ef4444' if item['semaforo']=='VENCIDO' else '#f59e0b')
                t_color = '#86efac' if item['semaforo']=='AL_DIA' else '#fca5a5'
                st.markdown(f"""
                <div style="border-left: 5px solid {b_color}; background: #1e293b; color: white; padding: 12px 16px; border-radius: 6px; margin-bottom: 10px;">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <div>
                            <strong>{icono_sem} {item['codigo']}</strong> — {item['descripcion']}
                            <div style="font-size: 13px; color: #94a3b8;">Ubicación: {item['ubicacion']} | Frecuencia: Cada {item['frecuencia_dias']} días | Último servicio: {item['ultimo_mantenimiento']}</div>
                        </div>
                        <div style="text-align: right;">
                            <span style="font-size: 14px; font-weight: bold; color: {t_color};">Próximo: {item['proximo_mantenimiento']}</span>
                            <div style="font-size: 12px; color: #cbd5e1;">Días restantes: {item['dias_restantes'] if item['dias_restantes'] is not None else 'N/A'}</div>
                        </div>
                    </div>
                </div>
                """, unsafe_allow_html=True)

    # ─────────────────────────────────────────────────────────────────────────
    # PESTAÑA 3: AUDITORÍA, EXPEDIENTES Y LIBERACIÓN (QC)
    # ─────────────────────────────────────────────────────────────────────────
    with tab_auditoria:
            # REGISTRO DE REPORTE DIRECTO
        with st.expander("🛠️ REGISTRAR REPORTE DIRECTO DE OFICINA / MANTENIMIENTO INTERNO", expanded=False):
            c_c1, c_c2 = st.columns([2, 1])
            eq_seleccionado = c_c1.selectbox("🔍 Selecciona el Equipo / Activo de Oficina:", options=["---"] + codigos_inv, key="manual_eq_sel")
            tipo_log = c_c2.selectbox("🩺 Tipo de Evento:", ["MANTENIMIENTO_TÉCNICO", "FALLA_OPERATIVA", "DAÑO_FÍSICO_OFICINA", "RESPALDO_SISTEMAS"], key="manual_tipo_log")

            c_c3, c_c4 = st.columns(2)
            est_final = c_c3.selectbox("📊 Estado Inicial del Ticket:", ["PENDIENTE", "EN TALLER", "DAÑADO", "BAJA"], key="manual_est_final")
            costo_asoc = c_c4.number_input("💰 Costo Estimado Reparación ($):", min_value=0.0, value=0.0, step=50.0, key="manual_costo_asoc")

            txt_bitacora = st.text_area("📝 Diagnóstico / Detalle del Daño:", placeholder="Ej. El aire acondicionado tira agua sobre la mesa...", key="manual_txt_bitacora")
            foto_evidencia = st.file_uploader("📸 Adjuntar Evidencia Fotográfica (Opcional):", type=["png", "jpg", "jpeg"], key="manual_foto_evidencia")

            if foto_evidencia is not None:
                st.image(foto_evidencia, caption="👀 Vista previa de la evidencia", width=350)

            if "boton_reporte_bloqueado" not in st.session_state:
                st.session_state.boton_reporte_bloqueado = False

            if st.button("💾 REGISTRAR TICKET EN POSTGRES", use_container_width=True, type="primary", key="manual_btn_save", disabled=st.session_state.boton_reporte_bloqueado):
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

        # ═══════════════════════════════════════════════════════════════════════════
        # 2️⃣ CONSULTA AL RADAR DE DAÑOS
        # ═══════════════════════════════════════════════════════════════════════════
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

            # ── DEDUPLICAR: si hay NUM_SERVICIO repetido, conservar solo la primera aparición ──
            if 'NUM_SERVICIO' in df_base.columns:
                df_base = df_base.drop_duplicates(subset=['NUM_SERVICIO'], keep='first')

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
                df_filtrado_danos = df_filtrado_danos[
                    (df_filtrado_danos['FECHA_REPORTE'] >= rango_fechas_danos[0]) &
                    (df_filtrado_danos['FECHA_REPORTE'] <= rango_fechas_danos[1])
                ]
            if depto_sel_danos != "Todos":
                df_filtrado_danos = df_filtrado_danos[df_filtrado_danos['DEPARTAMENTO'] == depto_sel_danos]
            if emp_sel_danos != "Todos":
                df_filtrado_danos = df_filtrado_danos[df_filtrado_danos['REPORTÓ'] == emp_sel_danos]

            m1, m2, m3, m4 = st.columns(4)  # MÉTRICAS
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
            st.plotly_chart(fig, use_container_width=True)

            # ════════════════════════════════════════════════════════════════════
            # MATRIZ ACTIVA CON DRILL-DOWN INTERACTIVO
            # ════════════════════════════════════════════════════════════════════
            st.markdown("### 📋 Matriz Activa de Reparaciones")
            st.caption("🔽 Expande cualquier fila para ver el detalle del ticket y el historial completo del equipo.")

            # Semáforo de estado
            COLOR_ESTADO = {
                "DAÑADO":          "🔴",
                "⚙️ DAÑADO":       "🔴",
                "PENDIENTE":       "🟡",
                "EN TALLER":       "🟠",
                "EN REVISIÓN":     "🟠",
                "EN REPARACION":   "🟠",
                "BAJA":            "⚫",
                "BAJA DEFINITIVA": "⚫",
            }

            if df_filtrado_danos.empty:
                st.success("✅ No hay tickets activos con los filtros seleccionados.")
            else:
                for idx, fila in df_filtrado_danos.iterrows():
                    ticket_num  = str(fila.get('NUM_SERVICIO', 'S/N'))
                    fecha_rep   = str(fila.get('FECHA_REPORTE', ''))
                    dias_fuera  = int(fila.get('DÍAS_INACTIVO', 0))
                    cod_id      = str(fila.get('ID', ''))
                    equipo_nom  = str(fila.get('EQUIPO', cod_id))
                    depto_fila  = str(fila.get('DEPARTAMENTO', ''))
                    reporto     = str(fila.get('REPORTÓ', ''))
                    estado_fila = str(fila.get('ESTADO', ''))
                    falla_texto = str(fila.get('FALLA', ''))
                    costo_fila  = float(fila.get('COSTO', 0.0))

                    icono_estado = COLOR_ESTADO.get(estado_fila.strip().upper(), "⚪")
                    dias_label   = f"⏱️ {dias_fuera}d" if dias_fuera > 0 else "📅 Hoy"
                    costo_label  = f"${costo_fila:,.2f}" if costo_fila > 0 else "—"

                    # Cabecera resumida (siempre visible — la línea del expander)
                    expander_label = (
                        f"{icono_estado} **{ticket_num}**  |  "
                        f"🖥️ `{equipo_nom}`  |  "
                        f"{dias_label}  |  "
                        f"👤 {reporto}  |  "
                        f"{estado_fila}  |  "
                        f"💰 {costo_label}"
                    )

                    with st.expander(expander_label, expanded=False):

                        # ── Bloque 1: detalle del ticket ─────────────────────────
                        st.markdown(f"#### 🎫 Detalle del Ticket `{ticket_num}`")
                        d1, d2, d3, d4 = st.columns(4)
                        d1.metric("Fecha reporte",  fecha_rep)
                        d2.metric("Días fuera",     f"{dias_fuera} días")
                        d3.metric("Estado",         estado_fila)
                        d4.metric("Costo estimado", costo_label)

                        col_det, col_foto = st.columns([2, 1])
                        with col_det:
                            st.markdown(f"**🏢 Departamento:** {depto_fila}")
                            st.markdown(f"**👤 Reportó:** {reporto}")
                            st.markdown(f"**🔑 Código ID:** `{cod_id}`")
                            st.markdown("**📝 Falla detectada:**")
                            st.info(falla_texto if falla_texto else "Sin descripción registrada.")

                        with col_foto:
                            # Intentar cargar foto de evidencia del ticket
                            folio_ref   = str(fila.get('FOLIO', 'MANTENIMIENTO_INTERNO'))
                            cod_safe    = cod_id.replace("/", "_").replace("\\", "_").replace(" ", "_").strip().upper()
                            fol_safe    = folio_ref.replace("/", "_").replace("\\", "_").replace(" ", "_").strip().upper()
                            nombre_foto = f"Evidencia_{fol_safe}_{cod_safe}.jpg"
                            url_foto    = f"{API_URL.rstrip('/')}/evidencias_web/{nombre_foto}"
                            try:
                                img_r = requests.get(url_foto, verify=False, timeout=5)
                                if img_r.status_code == 200:
                                    st.image(img_r.content, caption=f"📸 {nombre_foto}", use_container_width=True)
                                else:
                                    st.caption("📷 Sin foto de evidencia registrada.")
                            except Exception:
                                st.caption("📷 Sin foto de evidencia.")

                        st.divider()

                        # ── Bloque 2: historial completo del equipo (Expediente) ──
                        st.markdown(f"#### 📖 Historial del Equipo `{equipo_nom}`")
                        st.caption(f"Todos los reportes históricos del activo `{cod_id}` — del más reciente al más antiguo.")

                        try:
                            cod_seguro   = urllib.parse.quote(cod_id)
                            res_exp      = requests.get(f"{API_URL}/api/inventario/expediente/{cod_seguro}", verify=False, timeout=8)
                            if res_exp.status_code == 200:
                                datos_exp    = res_exp.json()
                                df_historial = pd.DataFrame(datos_exp.get("historial", []))
                                if not df_historial.empty:
                                    costo_total = df_historial["COSTO ($)"].sum() if "COSTO ($)" in df_historial.columns else 0.0
                                    h1, h2 = st.columns(2)
                                    h1.metric("Total de incidencias registradas", len(df_historial))
                                    h2.metric("Costo acumulado histórico",        f"${costo_total:,.2f}")
                                    st.dataframe(df_historial, use_container_width=True, hide_index=True)
                                else:
                                    st.info("ℹ️ Este equipo aún no tiene entradas en el historial clínico.")
                            else:
                                st.warning(f"⚠️ No se pudo cargar el expediente (error {res_exp.status_code}).")
                        except Exception as e_exp:
                            st.error(f"📡 Error al cargar historial: {e_exp}")

                        # ── Bloque 3: Protocolo de Control de Calidad (QC) y Liberación a Bodega ──
                        st.divider()
                        st.markdown("#### 🛡️ Protocolo de Control de Calidad (QC) y Liberación")
                        st.caption("Valida las 3 inspecciones mínimas antes de devolver el activo a bodega con estatus OK:")

                        qc1, qc2, qc3 = st.columns(3)
                        chk_elec = qc1.checkbox("⚡ Encendido y Sistema Eléctrico OK", value=True, key=f"qc_e_{ticket_num}_{idx}")
                        chk_func = qc2.checkbox("📡 Prueba Operativa / Señal OK", value=True, key=f"qc_f_{ticket_num}_{idx}")
                        chk_clean = qc3.checkbox("✨ Limpieza Estética y Accesorios OK", value=True, key=f"qc_c_{ticket_num}_{idx}")

                        col_tec, col_costo = st.columns(2)
                        tec_qc = col_tec.text_input("Técnico / Responsable de Liberación:", value=operador, key=f"qc_tec_{ticket_num}_{idx}")
                        costo_real = col_costo.number_input("Costo Final de Reparación ($):", min_value=0.0, value=costo_fila, step=50.0, key=f"qc_costo_{ticket_num}_{idx}")
                        obs_qc = st.text_area("Observaciones de Salida / Garantía:", placeholder="Equipo probado en banco de trabajo sin calentamiento ni fallas...", key=f"qc_obs_{ticket_num}_{idx}")

                        col_btn_ok, col_btn_baja = st.columns(2)
                        if col_btn_ok.button("✅ Aprobar Control de Calidad y Devolver a Bodega (OK)", key=f"btn_qc_ok_{ticket_num}_{idx}", type="primary", use_container_width=True):
                            payload_qc = {
                                "num_servicio": ticket_num,
                                "resultado": "APROBADO_OK",
                                "checklist": {
                                    "electrico_ok": chk_elec,
                                    "operativo_ok": chk_func,
                                    "limpieza_ok": chk_clean
                                },
                                "tecnico_responsable": tec_qc,
                                "observaciones": obs_qc,
                                "costo_final": costo_real
                            }
                            res_qc = requests.post(f"{API_URL}/api/inventario/mantenimiento/liberar-qc", json=payload_qc, verify=False)
                            if res_qc.status_code == 200:
                                st.success(f"🎉 ¡Equipo {cod_id} liberado con éxito! Se marcó como 'OK' en el inventario.")
                                time.sleep(1.2)
                                st.rerun()
                            else:
                                st.error(f"❌ Error al liberar: {res_qc.text}")

                        if col_btn_baja.button("⚫ Declarar Baja Definitiva (No Costeable)", key=f"btn_qc_baja_{ticket_num}_{idx}", use_container_width=True):
                            payload_baja = {
                                "num_servicio": ticket_num,
                                "resultado": "BAJA_DEFINITIVA",
                                "checklist": {},
                                "tecnico_responsable": tec_qc,
                                "observaciones": obs_qc or "Equipo irreparable o costo excede valor del activo.",
                                "costo_final": costo_real
                            }
                            res_b = requests.post(f"{API_URL}/api/inventario/mantenimiento/liberar-qc", json=payload_baja, verify=False)
                            if res_b.status_code == 200:
                                st.warning(f"Ticket {ticket_num} cerrado y equipo marcado como 'BAJA'.")
                                time.sleep(1.2)
                                st.rerun()
                            else:
                                st.error(f"❌ Error: {res_b.text}")

        else:
            st.success("✅ Operación Limpia: La tabla public.reparaciones no contiene tickets pendientes.")