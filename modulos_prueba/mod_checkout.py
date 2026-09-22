import streamlit as st
import requests
import pandas as pd
import time
import csv
import json
import urllib.parse
from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus

def renderizar_modulo(API_URL):
    rol_actual = st.session_state.get("rol", "")
    id_est = st.session_state.get("id_usuario", "001")
    depto_logueado = st.session_state.get("depto", "BODEGA")
    operador = st.session_state.get("usuario_actual", "OPERADOR")
    
    incidencias_limpias_mostrar = ""
    proveedor_con_incidente_guardado = "--- Ninguno ---"
    detalle_incidente_prov_guardado = ""
    
    if 'modo_actual' not in st.session_state: st.session_state.modo_actual = None
    if 'id_est_temp' not in st.session_state: st.session_state.id_est_temp = id_est
    if 'df_checkout' not in st.session_state: st.session_state.df_checkout = pd.DataFrame(columns=['ID', 'EQUIPO', 'CANT', 'OBSERVACIONES'])
    
    st.subheader(f"📦 {depto_logueado}: Control de Carga y Retorno de Hardware")

    # 👉 AYUDA CONTEXTUAL INYECTADA
    with st.expander("❓ Ayuda Contextual: ¿Cómo funciona la salida y entrada de equipo?"):
        st.markdown("""
        ### 📦 FASE 2: Despacho de Hardware (Salida)
        **Actor responsable:** Coordinador / Logística.  
        **Objetivo:** Registrar exactamente qué equipo sale de las instalaciones.
        
        *   📂 **Apertura de la OP:** El sistema muestra automáticamente las OPs pendientes de salir.
        *   🧳 **Carga de Equipo:** Se carga una plantilla (Kit) o se usa el Inyector Rápido. El sistema bloquea renglones duplicados.
        *   ✅ **Auditoría de Salida:** Un Coordinador confirma las cantidades y presiona **"AUTORIZAR SALIDA DE BODEGA"**. El estatus cambia a `DESPACHADO`.
        
        ---
        ### 📥 FASE 4: Retorno a Base y Liberación (Check-in)
        **Actor responsable:** Coordinación / Logística.  
        **Objetivo:** Recuperar el hardware, auditar daños y liberar la OP.
        
        *   ✅ **Cotejo Individual:** Se debe marcar la casilla "¿Regresó?" por cada artículo.
        *   🚦 **Auditoría de Daños:** Si una pieza regresa rota o con fallas, se escribe en "Notas de Regreso". 
            *   🔒 **Candado:** Palabras como *daño, roto, quebrado o falló* mandarán automáticamente el equipo al Taller y lo marcarán como `DAÑADO`.
        *   📜 **Acta a Proveedores:** Si hubo daño por culpa de un proveedor, se selecciona en el menú de infractores y se levanta el acta aquí.
        *   🏁 **Cierre y Liberación:** Al presionar **"FINALIZAR REVISIÓN Y REGRESO"**, el estado cambia a `RECIBIDO`. 
            *   🔐 **CANDADO FINANCIERO:** Es matemáticamente imposible que un Productor rinda gastos si Bodega no ha completado este paso.
        """)

    ordenes, lista_kits, alertas_pendientes = [], ["--- Sin plantilla ---"], []
    name_to_id = {}
    proveedores_asignados_op = []
    
    try:
        # 🌟 AQUÍ SE CARGAN LOS DATOS YA FILTRADOS DESDE EL BACKEND
        res_init = requests.get(f"{API_URL}/api/checkout/init-data/{id_est}", verify=False)
        if res_init.status_code == 200:
            pack = res_init.json()
            ordenes = pack.get("ordenes", [])
            lista_kits += pack.get("kits", [])
            alertas_pendientes = pack.get("alertas_pendientes", [])
            
            res_emp_map = requests.get(f"{API_URL}/api/empleados", verify=False)
            if res_emp_map.status_code == 200:
                emp_df = pd.DataFrame(res_emp_map.json())
                if not emp_df.empty and 'nombre' in emp_df.columns and 'id_empleado' in emp_df.columns:
                    name_to_id = dict(zip(emp_df['nombre'].astype(str).str.strip().str.upper(), emp_df['id_empleado'].astype(str).str.strip()))
    except Exception as e: 
        st.error(f"📡 Error de conexión inicial con la API: {e}")

    # 🧠 CONTROL INTELIGENTE Y ROBUSTO DEL SELECTBOX DE OP
    opciones_selectbox = ["---"] + ordenes
    
    # 1. Resolver preselección externa (ej. desde el Dashboard de Inicio)
    op_pre = st.session_state.pop("op_preseleccionada", None)
    if op_pre and opciones_selectbox:
        prefijo_buscado = f"OP-{str(op_pre).zfill(3)}"
        for opcion in opciones_selectbox:
            if opcion.startswith(prefijo_buscado):
                st.session_state["selector_visual_op_checkout"] = opcion
                st.session_state["op_activa_checkout"] = opcion
                st.session_state.modo_actual = None
                st.session_state.pop("coordinador_emp_select_unificado_final", None)
                st.session_state.pop("sb_prov_mal_comportamiento_checkin", None)
                break

    # 2. Asegurar que la opción guardada siga siendo válida en las opciones actuales de la API
    op_actual = st.session_state.get("selector_visual_op_checkout", st.session_state.get("op_activa_checkout", "---"))
    if op_actual not in opciones_selectbox:
        folio_antiguo = str(op_actual).split(" | ")[0].strip()
        coincidencia = next((op for op in opciones_selectbox if op.startswith(f"{folio_antiguo} |")), "---")
        op_actual = coincidencia

    st.session_state["selector_visual_op_checkout"] = op_actual
    st.session_state["op_activa_checkout"] = op_actual

    # 3. Callback nativo: se dispara SOLO si el usuario cambia la selección manualmente
    def al_cambiar_op_checkout():
        nueva_sel = st.session_state.get("selector_visual_op_checkout", "---")
        st.session_state["op_activa_checkout"] = nueva_sel
        st.session_state.modo_actual = None
        st.session_state.last_checkout_cache = None
        st.session_state.pop("coordinador_emp_select_unificado_final", None)
        st.session_state.pop("sb_prov_mal_comportamiento_checkin", None)

    # 4. Selectbox limpio y reactivo (sin dobles reruns ni desincronización)
    op_seleccionada = st.selectbox(
        "1️⃣ Seleccione Orden de Producción Destino:", 
        options=opciones_selectbox, 
        key="selector_visual_op_checkout",
        on_change=al_cambiar_op_checkout
    )
    
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
                incidencias_limpias_mostrar = incidencias_generales_db
                estado_bodega = status_pack.get("estado_bodega", "NUEVO")
                detalle_items = status_pack.get("detalle", [])
                
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
            except Exception as e:
                print(f"⚠️ SILENCED ERROR in mod_checkout.py: {e}")

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
                if st.session_state.get("coordinador_emp_select_unificado_final") not in opciones_empleados:
                    st.session_state.pop("coordinador_emp_select_unificado_final", None)
                empleado_revisar_sel = st.selectbox("👤 Personal Convocado a Revisar:", options=opciones_empleados, key="coordinador_emp_select_unificado_final")
                id_sujeto_a_revisar = name_to_id.get(str(empleado_revisar_sel).strip().upper(), id_est)
                if st.session_state.get('id_est_temp') != id_sujeto_a_revisar:
                    st.session_state.modo_actual = None
                    st.session_state.id_est_temp = id_sujeto_a_revisar
                    st.rerun()

        try:
            res_kits = requests.get(f"{API_URL}/api/checkout/kits/{id_sujeto_a_revisar}", verify=False)
            if res_kits.status_code == 200: lista_kits = ["--- Sin plantilla ---"] + res_kits.json().get("kits", [])
        except Exception as e: print(f"⚠️ SILENCED ERROR in mod_checkout.py: {e}")

        mapa_kits_nombres = {}
        try:
            res_kits_n = requests.get(f"{API_URL}/api/inventario-kits/completo", verify=False)
            if res_kits_n.status_code == 200:
                for k_item in res_kits_n.json():
                    c_id = str(k_item.get('codigo', k_item.get('codigo_inv_kits', ''))).strip().upper()
                    c_desc = str(k_item.get('descripcion', k_item.get('equipo', ''))).strip()
                    if c_id and c_desc:
                        mapa_kits_nombres[c_id] = c_desc
        except Exception as e: print(f"⚠️ SILENCED ERROR in mod_checkout.py: {e}")

        id_maestro_db, incidencia_general_db, estado_bodega, detalle_items = None, "", "NUEVO", []
        try:
            res_status = requests.get(f"{API_URL}/api/checkout/status/{id_op_ref}/{id_sujeto_a_revisar}", verify=False)
            if res_status.status_code == 200:
                status_pack = res_status.json()
                id_maestro_db = status_pack.get("id_maestro")
                
                incidencias_generales_db = status_pack.get("incidencias_generales") or ""
                if str(incidencias_generales_db).strip() in ["None", "nan", "null"]: incidencias_generales_db = ""
                
                incidencias_limpias_mostrar = incidencias_generales_db
                estado_bodega = status_pack.get("estado_bodega", "NUEVO")
                detalle_items = status_pack.get("detalle", [])
                
                if detalle_items:
                    for item in detalle_items:
                        obs_raw = item.get('OBSERVACIONES', item.get('observaciones', item.get('notas', item.get('obs_salida', ''))))
                        if obs_raw is None or str(obs_raw).strip() in ["None", "nan", "null"]:
                            clean_obs = ""
                        else:
                            clean_obs = str(obs_raw).strip()
                            
                        cod_val = str(item.get('ID', item.get('codigo', item.get('codigo_equipo', '')))).strip().upper()
                        if cod_val in ["NONE", "NAN", "NULL"]: cod_val = ""
                        item['ID'] = cod_val
                        
                        eq_val = str(item.get('Equipo', item.get('EQUIPO', item.get('descripcion', item.get('equipo', ''))))).strip().upper()
                        if eq_val in ["NONE", "NAN", "NULL"]: eq_val = ""
                        
                        if cod_val and cod_val in mapa_kits_nombres and (not eq_val or eq_val == "EQUIPO NO REGISTRADO"):
                            item['Equipo'] = mapa_kits_nombres[cod_val]
                            item['EQUIPO'] = mapa_kits_nombres[cod_val]
                            item['descripcion'] = mapa_kits_nombres[cod_val]
                            eq_val = item['EQUIPO'].upper()

                        if "[CUST_EQ:" in clean_obs:
                            start_idx = clean_obs.find("[CUST_EQ:") + 9
                            end_idx = clean_obs.find("]", start_idx)
                            if end_idx != -1:
                                extracted_name = clean_obs[start_idx:end_idx].strip()
                                
                                if not eq_val or eq_val == "EQUIPO NO REGISTRADO":
                                    item['Equipo'] = extracted_name
                                    item['EQUIPO'] = extracted_name
                                    item['descripcion'] = extracted_name
                                
                                clean_obs = clean_obs[:clean_obs.find("[CUST_EQ:")].strip() + " " + clean_obs[end_idx+1:].strip()
                                clean_obs = clean_obs.strip()
                                if clean_obs.lower() in ["none", "nan", "null"]: clean_obs = ""
                        
                        item['OBSERVACIONES'] = clean_obs
                        item['observaciones'] = clean_obs
                        item['notas'] = clean_obs
                        item['obs_salida'] = clean_obs
                        
                        inc_raw = item.get('Incidencia', item.get('OBS_REGRESO', item.get('notas_regreso', '')))
                        if inc_raw is None or str(inc_raw).strip() in ["None", "nan", "null"]:
                            item['Incidencia'] = ""
                            item['OBS_REGRESO'] = ""
                            item['notas_regreso'] = ""
                        else:
                            item['Incidencia'] = str(inc_raw)
                            item['OBS_REGRESO'] = str(inc_raw)
                            item['notas_regreso'] = str(inc_raw)
        except Exception as e: print(f"⚠️ SILENCED ERROR in mod_checkout.py: {e}")

        cache_key = f"chk_{id_op_ref}_{id_sujeto_a_revisar}"
        if st.session_state.get("last_checkout_cache") != cache_key:
            if id_maestro_db and detalle_items:
                clean_items = []
                for c_item in detalle_items:
                    clean_items.append({
                        'ID': str(c_item.get('ID', c_item.get('codigo', ''))).strip(),
                        'EQUIPO': str(c_item.get('EQUIPO', c_item.get('Equipo', c_item.get('descripcion', '')))).strip(),
                        'CANT': int(c_item.get('CANT', c_item.get('cantidad', c_item.get('CANT_SALIDA', 1))) or 1),
                        'OBSERVACIONES': str(c_item.get('OBSERVACIONES', c_item.get('observaciones', ''))).strip()
                    })
                st.session_state.df_checkout = pd.DataFrame(clean_items)[['ID', 'EQUIPO', 'CANT', 'OBSERVACIONES']]
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
            if c1.button("✏️ MODIFICAR EL CHECKOUT", use_container_width=True): 
                st.session_state.modo_actual = "MODIFICAR"; st.rerun()
            if estado_bodega != 'DESPACHADO':
                if c2.button("📤 REVISAR EL CHECKOUT AL CARGAR", use_container_width=True, type="primary"):
                    st.session_state.modo_actual = "VERIFICAR_SALIDA"; st.rerun()
            else:
                c2.button("📦 CARGAMENTO DESPACHADO", disabled=True, use_container_width=True)
            if c3.button("📥 CHECK-IN", use_container_width=True): 
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
                hide_index=True, use_container_width=True
            )
            
            txt_incidencias_gen_salida = st.text_area("📝 NOTAS GENERALES DE SALIDA:", value=incidencias_limpias_mostrar, height=100)
            col_c1, col_c2 = st.columns([3, 1])
            if col_c1.button("🔒 AUTORIZAR SALIDA DE BODEGA", type="primary", use_container_width=True):
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
            if col_c2.button("❌ CANCELAR", use_container_width=True): st.session_state.modo_actual = None; st.rerun()

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
                hide_index=True, use_container_width=True, key="editor_checkin_vpro_v3"
            )
            
            st.write("")
            with st.container(border=True):
                st.markdown("##### 🚚 Acta de Incidencias de Proveedores Externos")
                p_inc = proveedor_con_incidente_guardado if 'proveedor_con_incidente_guardado' in locals() else "--- Ninguno ---"
                p_note = detalle_incidente_prov_guardado if 'detalle_incidente_prov_guardado' in locals() else ""
                
                opciones_prov_limpias = ["--- Ninguno ---"] + [str(p).strip().upper() for p in proveedores_asignados_op]
                if st.session_state.get("sb_prov_mal_comportamiento_checkin") not in opciones_prov_limpias:
                    st.session_state.pop("sb_prov_mal_comportamiento_checkin", None)
                idx_prov_inc = opciones_prov_limpias.index(p_inc) if p_inc in opciones_prov_limpias else 0
                
                prov_mal_comportamiento = st.selectbox("Selecciona el proveedor implicado:", options=opciones_prov_limpias, index=idx_prov_inc, key="sb_prov_mal_comportamiento_checkin")
                
                txt_reporte_prov = ""
                if prov_mal_comportamiento != "--- Ninguno ---":
                    txt_reporte_prov = st.text_area(f"📝 Detalles del Reporte para {prov_mal_comportamiento}:", value=p_note, key="txt_reporte_prov_checkin")

            txt_incidencias_gen_checkin = st.text_area("📝 NOTAS DE RECEPCIÓN (BODEGA):", value=incidencias_limpias_mostrar, height=120)
            
            if st.button("💾 FINALIZAR REVISIÓN Y REGRESO", type="primary", use_container_width=True):
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

        # --- ESCENARIO D: FORMULARIO REAL DE CAPTURA DE SALIDA ---
        elif st.session_state.modo_actual in ["MODIFICAR", "NUEVO"]:
            st.subheader("📤 Formulario Activo: Captura de Salida de Hardware")
            
            tpl_memoria = str(st.session_state.get("last_tpl_loaded", "--- Sin plantilla ---")).strip()
            if tpl_memoria and tpl_memoria not in lista_kits: 
                lista_kits.append(tpl_memoria)
            
            lista_kits_limpia = [str(k).strip().upper() for k in lista_kits]
            idx_dinamico = lista_kits_limpia.index(tpl_memoria.upper()) if tpl_memoria.upper() in lista_kits_limpia else 0
            
            tpl_sel = st.selectbox("📋 Matriz de Kits disponibles:", options=lista_kits, index=idx_dinamico)
            
            if tpl_sel != "--- Sin plantilla ---" and str(st.session_state.get("last_tpl_loaded")).strip().upper() != tpl_sel.strip().upper():
                try:
                    tpl_encoded = urllib.parse.quote(tpl_sel)
                    res_buscar = requests.get(f"{API_URL}/api/eventos/buscar_kit/{tpl_encoded}/{id_sujeto_a_revisar}", verify=False)
                    
                    if res_buscar.status_code == 200:
                        raw_items = res_buscar.json().get("items", [])
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
                num_rows="dynamic", hide_index=True, use_container_width=True, key="grid_edicion_checkout_real_vpro"
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
            
                equipo_con_dano = False     # Variables de memoria para el daño
                nota_dano = ""

                with col_inj1: 
                    equipo_sel_helper = st.selectbox("Selecciona un equipo:", options=["--- Selecciona un artículo ---"] + opciones_autocompletado, key="selectbox_helper_injector_pro")
                
                    if equipo_sel_helper != "--- Selecciona un artículo ---":   # 🔥 SENSOR DE DAÑOS AL VUELO
                        try:
                            res_danos = requests.get(f"{API_URL}/api/inventario/radar-danos", verify=False, timeout=2)
                            if res_danos.status_code == 200:
                                lista_danos = res_danos.json()
                                eq_puro = equipo_sel_helper.split(" - ")[0].strip() if " - " in equipo_sel_helper else equipo_sel_helper.strip()
                            
                                if any(eq_puro.upper() in str(d.get('EQUIPO', '')).upper() for d in lista_danos):   # Revisamos si el equipo seleccionado está en la lista de enfermos
                                    equipo_con_dano = True
                                    nota_dano = "⚠️ [LLEVA DAÑO REPORTADO]"
                                    st.warning("⚠️ **¡OJO!** Este equipo tiene un reporte activo de falla o daño en taller. Puedes agregarlo al evento, pero considera que no está al 100%.")
                        except Exception as e:
                            print(f"⚠️ SILENCED ERROR in mod_checkout.py: {e}") # Si hay lag en el server, lo ignoramos para no estorbar el flujo rápido

                with col_inj2:
                    st.write("##")
                    if st.button("➕ AGREGAR articulo AL CHECKOUT", use_container_width=True, key="btn_execute_injection_pro"):
                        if equipo_sel_helper != "--- Selecciona un artículo ---":
                            if df_editado is not None: st.session_state.df_checkout = df_editado.copy()
                        
                            nueva_fila_hw = pd.DataFrame([{
                                "ID": "", 
                                "EQUIPO": equipo_sel_helper, 
                                "CANT": 1, 
                                "OBSERVACIONES": nota_dano 
                            }], columns=['ID', 'EQUIPO', 'CANT', 'OBSERVACIONES'])
                        
                            st.session_state.df_checkout = pd.concat([st.session_state.df_checkout, nueva_fila_hw], ignore_index=True)
                            st.rerun()

            with st.expander("💾 Guardar esta lista como Plantilla / Kit Predeterminado", expanded=False):
                st.caption("Si utilizas esta misma lista de equipos frecuentemente, guárdala como plantilla para cargarla en 1 clic en futuros llamados.")
                c_k1, c_k2 = st.columns([3, 1])
                nombre_nuevo_kit = c_k1.text_input("Nombre de la Plantilla (Ej. Kit Básico de Audio):", value=tpl_memoria if tpl_memoria != "--- Sin plantilla ---" else "", key=f"txt_nombre_kit_{id_op_ref}")
                
                if c_k2.button("💾 GRABAR PLANTILLA", use_container_width=True, key=f"btn_grabar_kit_{id_op_ref}"):
                    if not nombre_nuevo_kit.strip():
                        st.warning("⚠️ Debes asignarle un nombre a la plantilla.")
                    elif df_editado is None or df_editado.empty:
                        st.warning("⚠️ La lista de hardware está vacía.")
                    else:
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
                                if cod.upper() in ["NONE", "NAN", "NULL"]: cod = ""
                                cant = int(row.get('CANT', 1) if pd.notna(row.get('CANT')) else 1)
                                obs = str(row.get('OBSERVACIONES', '')).strip()
                                # 🔥 EXORCISMO: Evitamos que el None se guarde en la BD
                                if obs.lower() in ["none", "nan", "null"]: obs = ""

                                if not cod and eq_str.upper() in mapa_nombres_a_kits:
                                    cod = mapa_nombres_a_kits[eq_str.upper()]
                                    
                                if not cod and eq_str:
                                    ultimo_num_db += 1
                                    cod = f"Inv_alt_{str(id_sujeto_a_revisar).strip()}{str(ultimo_num_db).zfill(4)}"
                                    obs = f"[CUST_EQ:{eq_str}] {obs}".strip()

                                items_a_guardar.append({
                                    "ID": cod, "EQUIPO": eq_str, "CANT": cant, "OBSERVACIONES": obs
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
            val_por_defecto = "favor de reportar aqui las incidencias del evento" if not db_val or db_val.lower() in ["ninguna", "todo bien", "ok", "none", "sin incidencias"] else db_val
            nota_incidencias = st.text_area("⚠️ Incidencias Generales de la Salida:", value=val_por_defecto, height=100, key=f"txt_incidencias_checkout_{id_op_ref}_{id_sujeto_a_revisar}")
            
            c_actions1, c_actions2 = st.columns([3, 1])
            if c_actions1.button("🚀 FINALIZAR Y REGISTRAR SALIDA DE BODEGA", type="primary", use_container_width=True, key=f"btn_finalizar_salida_{id_op_ref}_{id_sujeto_a_revisar}"):
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
                    if obs.lower() in ["none", "nan", "null"]: obs = ""
                    
                    if not cod and eq.upper() in mapa_nombres_a_kits: cod = mapa_nombres_a_kits[eq.upper()]
                    if not cod and eq:
                        ultimo_num_db += 1
                        cod = f"Inv_alt_{str(id_sujeto_a_revisar).strip()}{str(ultimo_num_db).zfill(4)}"
                        obs = f"[CUST_EQ:{eq}] {obs}".strip()
                        
                    # Le enviamos al servidor ambas variables por seguridad (CANT y cantidad)
                    items_api_finales.append({
                        "ID": cod, "codigo": cod, 
                        "CANT": cant, "cantidad": cant, 
                        "OBSERVACIONES": obs, "observaciones": obs, 
                        "EQUIPO": eq, "descripcion": eq
                    })
                
                tag_provs = f"\n[PROVEEDOR_INCIDENTE: {prov_mal_comportamiento} | NOTA: {txt_reporte_prov.strip()}]" if prov_mal_comportamiento != "--- Ninguno ---" and txt_reporte_prov.strip() else ""
                payload_salida = {"id_evento": int(id_op_ref), "id_sujeto_a_revisar": str(id_sujeto_a_revisar).strip(), "incidencias_generales": f"{nota_incidencias}{tag_provs}".strip(), "nombre_kit": str(tpl_sel).strip(), "items": items_api_finales}
                
                res_salida = requests.post(f"{API_URL}/api/checkout/finalizar-salida", json=payload_salida, verify=False)
                if res_salida.status_code == 200:
                    st.success("🔒 ¡Checkout guardado y sincronizado con éxito!")
                    st.session_state.modo_actual = "VISTA"
                    st.session_state.df_checkout = pd.DataFrame(columns=['ID', 'EQUIPO', 'CANT', 'OBSERVACIONES'])
                    
                    # 🧹 LA MAGIA: Limpiamos el caché para forzar al sistema a traer la cantidad nueva de la DB
                    st.session_state.last_checkout_cache = None 
                    
                    time.sleep(1.5); st.rerun()
                    
                else: st.error(f"❌ Error al registrar salida: {res_salida.text}")
            
            if c_actions2.button("❌ ABORTAR", use_container_width=True, key=f"btn_abortar_checkout_{id_op_ref}"):
                st.session_state.modo_actual = None; st.rerun()
        else:
            st.info("🎯 Panel operativo central listo. Selecciona una opción del menú de la izquierda para comenzar.")