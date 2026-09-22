import streamlit as st
import requests
import pandas as pd
import datetime
import time
import os
import urllib.parse

# 🚨 1. DIÁLOGO MODAL (POP-UP) PARA BORRADO DE HARDWARE
@st.dialog("🚨 Confirmación de Baja de Hardware")
def modal_confirmar_baja_hardware(codigo, descripcion, API_URL):
    st.write(f"¿Está seguro de que desea eliminar el equipo **{codigo}** ({descripcion})?")
    st.caption("⚠️ Esta acción borrará permanentemente la pieza del catálogo maestro de inventario.")
    
    col_canc, col_conf = st.columns(2)
    if col_canc.button("❌ Cancelar"):
        st.rerun()
        
    if col_conf.button("🔥 Sí, Eliminar Pieza", type="primary"):
        with st.spinner(f"Eliminando equipo {codigo}..."):
            try:
                res_del = requests.delete(f"{API_URL}/api/inventario/eliminar/{codigo}", verify=False, timeout=5)
                if res_del.status_code == 200:
                    st.success(f"💥 Equipo **{codigo}** eliminado permanentemente del sistema.")
                    time.sleep(1)
                    st.rerun()
                else:
                    st.error(f"❌ No se pudo eliminar: {res_del.text}")
            except Exception as e:
                st.error(f"🛑 Error de conexión: {e}")

from modulos_prueba.utils_frontend import parse_fecha, get_idx
from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus

def semaforo_hardware(row):
    est = str(row.get('estado', '')).strip().upper()
    if est in ["BAJA", "DANADO", "DAÑADO", "FALLA", "DAÃ‘ADO"]: 
        return ['background-color: #5c191e; color: #ffb3b7; font-weight: 500'] * len(row)
    if est in ["REVISIÓN", "REVISION", "REPARACIÓN", "MANTENIMIENTO"]:
        return ['background-color: #422006; color: #fed7aa; font-weight: 500'] * len(row)
    return [''] * len(row)

def renderizar_modulo(API_URL):
    st.markdown("## 🛠️ Control e Inventario de Hardware VPRO")
    st.caption("Módulo de Altas, Bajas, Diagnóstico de Kits y Expediente Clínico de Reparaciones.")

    tab_catalogo, tab_alterno, tab_expediente = st.tabs([
        "📦 1. Catálogo Maestro de Hardware", 
        "🧳 2. Inventario Alterno (Kits)", 
        "📋 3. Expediente y Mantenimiento"
    ])

    # ==========================================
    # PESTAÑA 1: CATÁLOGO MAESTRO DE HARDWARE
    # ==========================================
    with tab_catalogo:
        st.subheader("Control General de Activos")
        
        lista_inv = []
        try:
            res_inv = requests.get(f"{API_URL}/api/inventario", verify=False, timeout=5)
            if res_inv.status_code == 200:
                lista_inv = res_inv.json()
            else:
                st.error(f"⚠️ La API respondió con código {res_inv.status_code}")
        except Exception as e:
            st.error(f"🛑 Error de conexión con inventario: {e}")

        # 📋 TABLA GENERAL DE HARDWARE
        with st.expander("📋 Ver Catálogo Completo de Hardware", expanded=False):
            if lista_inv:
                df_resumen = pd.DataFrame(lista_inv)
                cols_deseadas = ['codigo', 'responsiva', 'fecha_compra', 'descripcion', 'marca', 'modelo', 'serie', 'responsable', 'estado', 'ubicacion', 'observaciones']
                cols_ver = [c for c in cols_deseadas if c in df_resumen.columns]
                st.dataframe(df_resumen[cols_ver].style.apply(semaforo_hardware, axis=1), use_container_width=True, hide_index=True)
            else:
                st.info("Sin piezas registradas en el inventario actualmente.")

        # Selector de pieza
        diccionario_inv = {f"{i['codigo']} - {i.get('descripcion', '')} ({i.get('marca', 'S/M')})": i for i in lista_inv if 'codigo' in i}
        opciones_selector = ["➕ Registrar Nuevo Hardware"] + list(diccionario_inv.keys())

        st.markdown("### 🔎 Editor de Activos")
        seleccion = st.selectbox("Seleccione un equipo para editarlo, o elija 'Nuevo':", opciones_selector)

        d_form = {
            "codigo": "", "responsiva": "", "fecha_compra": None, "descripcion": "",
            "marca": "", "modelo": "", "serie": "", "responsable": "",
            "estado": "BUEN ESTADO", "ubicacion": "BODEGA PRINCIPAL", "observaciones": ""
        }

        es_edicion = seleccion != "➕ Registrar Nuevo Hardware"

        if es_edicion:
            d_form.update(diccionario_inv[seleccion])
            for k, v in d_form.items():
                if v is None: d_form[k] = ""

        # Formulario
        with st.form("form_alta_hardware"):
            col1, col2, col3 = st.columns(3)
            with col1:
                codigo = st.text_input("Código / ID Hardware*", value=str(d_form["codigo"]), disabled=es_edicion, help="Clave única del equipo (ej. CAM-01).")
                descripcion = st.text_input("Descripción del Hardware*", value=str(d_form["descripcion"]))
                marca = st.text_input("Marca", value=str(d_form["marca"]))
                modelo = st.text_input("Modelo", value=str(d_form["modelo"]))
            with col2:
                serie = st.text_input("Número de Serie", value=str(d_form["serie"]))
                responsiva = st.text_input("Folio Responsiva", value=str(d_form["responsiva"]))
                responsable = st.text_input("Responsable Asignado", value=str(d_form["responsable"]))
                fecha_compra = st.date_input("Fecha de Compra", value=parse_fecha(d_form.get("fecha_compra")))
            with col3:
                opc_estado = ["BUEN ESTADO", "REVISION", "DANADO", "BAJA"]
                estado = st.selectbox("Estado Operativo", opc_estado, index=get_idx(opc_estado, d_form.get("estado")))
                ubicacion = st.text_input("Ubicación en Bodega", value=str(d_form["ubicacion"]))
                observaciones = st.text_area("Observaciones Técnicas", value=str(d_form["observaciones"]), height=80)

            st.divider()

            # 🛠️ AQUÍ QUITAMOS EL USE_CONTAINER_WIDTH PARA EVITAR EL "APLASTAMIENTO"
            if es_edicion:
                col_guardar, col_baja = st.columns([2, 1])
                with col_guardar:
                    submit_btn = st.form_submit_button("💾 Actualizar Hardware", type="primary")
                with col_baja:
                    baja_btn = st.form_submit_button("🚨 Eliminar Pieza", type="secondary")
            else:
                submit_btn = st.form_submit_button("💾 Guardar Hardware Nuevo", type="primary")
                baja_btn = False

            if submit_btn:
                if not codigo or not descripcion:
                    st.error("⚠️ El Código y la Descripción son obligatorios.")
                else:
                    with st.spinner("Guardando pieza de hardware..."):
                        payload = {
                            "codigo": str(codigo).strip().upper(),
                            "responsiva": str(responsiva).strip(),
                            "fecha_compra": str(fecha_compra) if fecha_compra else None,
                            "descripcion": str(descripcion).strip(),
                            "marca": str(marca).strip(),
                            "modelo": str(modelo).strip(),
                            "serie": str(serie).strip(),
                            "responsable": str(responsable).strip(),
                            "estado": str(estado).strip().upper(),
                            "ubicacion": str(ubicacion).strip(),
                            "observaciones": str(observaciones).strip()
                        }
                        try:
                            res_post = requests.post(f"{API_URL}/api/inventario/guardar", json=payload, verify=False, timeout=10)
                            if res_post.status_code == 200:
                                st.success(f"✅ ¡Hardware {codigo} sincronizado con éxito!")
                                time.sleep(1)
                                st.rerun()
                            else:
                                st.error(f"❌ Error al guardar: {res_post.text}")
                        except Exception as e:
                            st.error(f"❌ Error de conexión: {e}")

            if baja_btn:
                modal_confirmar_baja_hardware(codigo, descripcion, API_URL)

    # ==========================================
    # PESTAÑA 2: INVENTARIO ALTERNO DE KITS
    # ==========================================
    with tab_alterno:
        st.subheader("🧳 Kits de Checkout y Hardware Secundario")
        try:
            res_alt = requests.get(f"{API_URL}/api/inventario-kits/completo", verify=False, timeout=5)
            if res_alt.status_code == 200:
                kits_data = res_alt.json()
                if kits_data:
                    df_alt = pd.DataFrame(kits_data)
                    config_columnas_alt = {
                        "codigo": st.column_config.TextColumn("Código Kit", disabled=True), 
                        "descripcion": st.column_config.TextColumn("Descripción Hardware", disabled=True), 
                        "responsable": st.column_config.TextColumn("Responsable", disabled=True), 
                        "estado": st.column_config.SelectboxColumn("Estado", options=["BUEN ESTADO", "DANADO", "REVISION", "BAJA"], required=True),
                        "observaciones": st.column_config.TextColumn("Diagnóstico / Falla Técnica", width="large")
                    }
                    
                    # 👁️ INYECTAMOS EL FILTRO INTELIGENTE
                    usuario_logeado = str(st.session_state.get("usuario_actual", "")).strip().upper()
                    filtro_vista = st.selectbox(
                        "👁️ Filtrar vista de inventario alterno:",
                        options=["🌎 Mostrar Todos los Kits", "👤 Mostrar solo mis equipos asignados"]
                    )
                    
                    if filtro_vista == "👤 Mostrar solo mis equipos asignados":
                        df_mostrar = df_alt[df_alt['responsable'].astype(str).str.strip().str.upper() == usuario_logeado]
                    else:
                        df_mostrar = df_alt

                    if df_mostrar.empty:
                        st.info(f"💡 No tienes equipos alternos o kits asignados a tu nombre ({usuario_logeado}).")
                        edited_alt_df = pd.DataFrame() # Creamos un df vacío para que no rompa el botón de guardar
                    else:
                        edited_alt_df = st.data_editor(
                            df_mostrar.style.apply(semaforo_hardware, axis=1), 
                            column_config=config_columnas_alt, 
                            use_container_width=True, 
                            hide_index=True,
                            key="grid_kits_interactivo"
                        )

                    # 🛠️ ELIMINADO EL USE_CONTAINER_WIDTH DEL BOTÓN
                    if st.button("💾 GUARDAR CAMBIOS EN KITS", type="primary"):
                        for idx, row_editada in edited_alt_df.iterrows():
                            payload_save_kit = {
                                "codigo": str(row_editada['codigo']).strip(),
                                "estado": str(row_editada['estado']).strip().upper(),
                                "observaciones": str(row_editada['observaciones']).strip()
                            }
                            requests.post(f"{API_URL}/api/inventario-kits/guardar", json=payload_save_kit, verify=False)
                        st.success("✅ Cambios en Kits guardados en la base de datos.")
                        time.sleep(1)
                        st.rerun()
                else:
                    st.info("💡 No hay ítems registrados en la tabla 'inventario_kits'.")
            else:
                st.error(f"⚠️ Error al conectar con la API ({res_alt.status_code}).")
        except Exception as e:
            st.error(f"❌ Error al consultar Kits: {e}")

    # ==========================================
    # PESTAÑA 3: EXPEDIENTE CLÍNICO DE EQUIPOS
    # ==========================================
    with tab_expediente:
        st.subheader("📋 Expediente Histórico y Bitácora de Fallas")
        try:
            p_radar = {
                "user_id": str(st.session_state.get("id_usuario", "")),
                "rol": str(st.session_state.get("rol", "")),
                "nombre_usuario": str(st.session_state.get("usuario_actual", ""))
            }
            res_inv_list = requests.get(f"{API_URL}/api/inventario/radar-danos", params=p_radar, verify=False, timeout=5)
            
            if res_inv_list.status_code == 200:
                df_exp = pd.DataFrame(res_inv_list.json())
                if not df_exp.empty:
                    st.markdown("#### 🩺 Equipos con Reporte de Daño o Mantenimiento")
                    st.caption("Selecciona una fila para abrir la bitácora médica y registrar la reparación.")
                    
                    grid_seleccion = st.dataframe(
                        df_exp.style.apply(semaforo_hardware, axis=1),
                        use_container_width=True,
                        hide_index=True,
                        selection_mode="single-row",
                        on_select="rerun",
                        key="tabla_expediente_reactivo_vpro_maestro"
                    )
                    
                    indice_seleccionado = grid_seleccion.selection.rows
                    if indice_seleccionado:
                        row_idx = indice_seleccionado[0]
                        codigo_sel = df_exp.iloc[row_idx].get('codigo') or df_exp.iloc[row_idx].get('ID')
                        
                        st.markdown(f"---")
                        st.markdown(f"### 📂 Expediente Clínico: `{codigo_sel}`")
                        
                        # 🌟 MAGIA FOTOGRÁFICA Y DE HISTORIAL VÍA API
                        cod_seguro = urllib.parse.quote(str(codigo_sel))
                        fotos, historial = [], []
                        try:
                            res_exp = requests.get(f"{API_URL}/api/inventario/expediente/{cod_seguro}", verify=False, timeout=8)
                            if res_exp.status_code == 200:
                                datos_exp = res_exp.json()
                                fotos = datos_exp.get("fotos", [])
                                historial = datos_exp.get("historial", [])
                        except Exception as e:
                            st.warning(f"Error al conectar con el expediente: {e}")
                        
                        col_card, col_foto = st.columns([2, 1])
                        with col_card:
                            with st.container(border=True):
                                c_a, c_b = st.columns(2)
                                c_a.markdown(f"**Equipo:** {df_exp.iloc[row_idx].get('descripcion', 'N/A')}")
                                c_b.markdown(f"**Estatus:** `{df_exp.iloc[row_idx].get('estado', 'DANADO')}`")
                        
                        with col_foto:
                            if fotos:
                                url_base = API_URL.rstrip('/')
                                url_foto_segura = urllib.parse.quote(fotos[0], safe="/")
                                try:
                                    img_res = requests.get(f"{url_base}/{url_foto_segura}", verify=False, timeout=8)
                                    if img_res.status_code == 200:
                                        st.image(img_res.content, use_container_width=True, caption=f"📸 Evidencia: {codigo_sel}")
                                    else:
                                        st.warning("⚠️ Foto encontrada, pero no se descargó.")
                                except:
                                    st.warning("⚠️ Error de red al descargar foto.")
                            else:
                                st.warning("📷 No hay foto registrada.")
                                
                            up_pic = st.file_uploader("🖼️ Subir foto:", type=["png", "jpg", "jpeg"], key=f"pic_{codigo_sel}")
                            if up_pic:
                                try:
                                    files = {"file": (up_pic.name, up_pic.getvalue(), up_pic.type)}
                                    data = {"codigo_equipo": str(codigo_sel).strip(), "folio_vpro": "CARGA_MANUAL"}
                                    res_up = requests.post(f"{API_URL}/api/inventario/subir-evidencia", files=files, data=data, verify=False)
                                    if res_up.status_code == 200:
                                        st.success("✅ Fotografía asociada.")
                                        time.sleep(1)
                                        st.rerun()
                                    else:
                                        st.error(f"Error al subir: {res_up.text}")
                                except Exception as e:
                                    st.error(f"Error de conexión: {e}")

                        # Historial cronológico
                        st.markdown("##### ⏳ Historial de Reparaciones")
                        if historial:
                            st.dataframe(pd.DataFrame(historial), use_container_width=True, hide_index=True)
                        else:
                            st.info("Sin registros anteriores de mantenimiento.")

                        # 🦸‍♂️ EL FORMULARIO CON SUPERPODERES
                        with st.expander("🔧 Registrar Nueva Intervención / Reparación", expanded=True):
                            c_f1, c_f2 = st.columns(2)
                            tipo_ev = c_f1.selectbox("🩺 Tipo de Intervención:", ["REPARACIÓN_TÉCNICA", "MANTENIMIENTO_PREVENTIVO", "DIAGNÓSTICO", "BAJA_DEFINITIVA"])
                            nuevo_estado = c_f2.selectbox("📊 Nuevo Estado del Equipo:", ["RESUELTO", "EN TALLER", "PENDIENTE", "BAJA"])
                            
                            txt_treatment = st.text_area("📝 Diagnóstico / Trabajo Realizado (Obligatorio):")
                            
                            c_f3, c_f4 = st.columns(2)
                            txt_op_maint = c_f3.text_input("🎬 Asociar a Folio OP:", value="MANTENIMIENTO_INTERNO")
                            costo_rep = c_f4.number_input("💰 Costo de Reparación ($):", min_value=0.0, value=0.0, step=50.0)
                            
                            # 🛠️ BOTÓN LIMPIO Y SIN APLASTAR
                            if st.button("💾 GUARDAR EN EXPEDIENTE", type="primary"):
                                if not txt_treatment.strip():
                                    st.warning("⚠️ Debes detallar la reparación realizada.")
                                else:
                                    payload_hist = {
                                        "codigo_equipo": str(codigo_sel).strip(),
                                        "tipo_evento": tipo_ev,
                                        "descripcion": str(txt_treatment).strip(),
                                        "folio_vpro": str(txt_op_maint).strip(),
                                        "id_empleado": str(st.session_state.get("id_usuario", "000")),
                                        "estado_final": nuevo_estado,
                                        "costo_asociado": float(costo_rep),
                                        "departamento": str(st.session_state.get("depto", "OFICINA")).upper()
                                    }
                                    with st.spinner("Guardando en bitácora..."):
                                        try:
                                            res_hist = requests.post(f"{API_URL}/api/inventario/historial/guardar", json=payload_hist, verify=False, timeout=8)
                                            if res_hist.status_code == 200:
                                                st.success("🔒 Intervención técnica anexada con éxito.")
                                                time.sleep(1)
                                                st.rerun()
                                            else:
                                                st.error(f"Error de base de datos: {res_hist.text}")
                                        except Exception as e:
                                            st.error(f"Error de servidor: {e}")
                else:
                    st.success("🎉 **Búnker al 100%:** No hay equipos reportados con falla actualmente.")
        except Exception as e:
            st.error(f"❌ Error al consultar expediente de fallas: {e}")