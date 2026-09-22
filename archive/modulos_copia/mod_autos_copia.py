import streamlit as st
import requests
import pandas as pd
import datetime

# 🚨 1. DIÁLOGO MODAL (POP-UP) DE CONFIRMACIÓN DE ELIMINACIÓN
@st.dialog("🚨 Confirmación de Baja Vehicular")
def modal_confirmar_baja(num_control, API_URL):
    st.write(f"¿Está seguro de que desea eliminar permanentemente la unidad **{num_control}**?")
    st.caption("⚠️ Esta acción no se puede deshacer y borrará el registro del catálogo.")
    
    col_canc, col_conf = st.columns(2)
    if col_canc.button("❌ Cancelar", use_container_width=True):
        st.rerun()
        
    if col_conf.button("🔥 Sí, Eliminar", type="primary", use_container_width=True):
        with st.spinner(f"Eliminando vehículo {num_control}..."):
            try:
                res_del = requests.delete(f"{API_URL}/api/autos/{num_control}", verify=False, timeout=5)
                if res_del.status_code == 200:
                    st.success(f"💥 Vehículo {num_control} eliminado permanentemente.")
                    st.rerun()
                else:
                    st.error(f"❌ No se pudo eliminar: {res_del.text}")
            except Exception as e:
                st.error(f"🛑 Error de conexión: {e}")

def parse_fecha(fecha_str):
    """Convierte fechas de texto a formato que Streamlit pueda pintar en el calendario"""
    if pd.isna(fecha_str) or str(fecha_str).strip() in ["", "None", "nan", "null"]: 
        return None
    try: 
        return pd.to_datetime(fecha_str).date()
    except: 
        return None

def get_idx(lista, valor):
    """Busca el índice de un valor en un selectbox, si no lo halla regresa el primero"""
    try: 
        return lista.index(str(valor).upper() if isinstance(valor, str) else valor)
    except: 
        return 0

def renderizar_modulo(API_URL):
    st.markdown("## 🚙 Control y Administración de Flota Vehicular")
    st.caption("Módulo de Altas, Bajas, Cambios y Control de Documentación para el Parque Vehicular.")

    # 1️⃣ SECCIÓN DE BÚSQUEDA Y EXTRACCIÓN DE DATOS
    lista_autos = []
    try:
        res = requests.get(f"{API_URL}/api/autos", verify=False, timeout=5)
        if res.status_code == 200: 
            lista_autos = res.json()
        else:
            st.error(f"⚠️ La API respondió con código {res.status_code}")
            st.code(res.text)
    except Exception as e: 
        st.error(f"🛑 Error de conexión al intentar leer los autos: {e}")

    # --- 📋 TABLA GENERAL DE LA FLOTA (SÓLO LECTURA) ---
    with st.expander("📋 Ver Catálogo Completo de Unidades (Todos los Campos)", expanded=False):
        if lista_autos:
            df_resumen = pd.DataFrame(lista_autos)
            
            todos_los_campos = [
                "num_control", "tipo_vehiculo", "marca", "modelo", "anio", "placa", 
                "serie", "color", "carga_maxima", "kilometraje_actual", "estado_actual", 
                "estado_mant_preventivo", "fecha_compra", "aseguradora", "no_poliza", 
                "status_seguro", "forma_pago_seguro", "prima_total", "seguro_inicio", 
                "seguro_vence", "impuesto_anio", "impuesto_monto", "impuesto_fecha_pago", 
                "impuesto_fecha_vencimiento", "mantenimiento_fecha", "servicios_hechos", 
                "observaciones_comentarios"
            ]
            
            for col in todos_los_campos:
                if col not in df_resumen.columns:
                    df_resumen[col] = None
                    
            st.dataframe(df_resumen[todos_los_campos], use_container_width=True, hide_index=True)
        else:
            st.info("Sin vehículos registrados actualmente.")

    # Armar diccionario para búsqueda rápida
    diccionario_autos = {f"{a['num_control']} - {a.get('marca', '')} {a.get('modelo', '')} ({a.get('placa', 'S/P')})": a for a in lista_autos}
    opciones_selector = ["➕ Registrar Nuevo Vehículo"] + list(diccionario_autos.keys())

    st.markdown("### 🔎 Editor de Unidades")
    seleccion = st.selectbox("Seleccione un vehículo para editarlo, o elija 'Nuevo' para capturar desde cero:", opciones_selector)
    
    d_form = {
        "num_control": "", "tipo_vehiculo": "Auto", "marca": "", "modelo": "", 
        "anio": "", "placa": "", "serie": "", "color": "", "carga_maxima": "", "kilometraje_actual": 0,
        "estado_actual": "EXCELENTE", "estado_mant_preventivo": "", "fecha_compra": None,
        "aseguradora": "", "no_poliza": "", "status_seguro": "ACTIVA", "forma_pago_seguro": "Anual",
        "prima_total": 0.0, "seguro_inicio": None, "seguro_vence": None,
        "impuesto_anio": "", "impuesto_monto": 0.0, "impuesto_fecha_pago": None, "impuesto_fecha_vencimiento": None,
        "mantenimiento_fecha": None, "servicios_hechos": "", "observaciones_comentarios": ""
    }
    
    es_edicion = seleccion != "➕ Registrar Nuevo Vehículo"
    
    if es_edicion:
        d_form.update(diccionario_autos[seleccion])
        for k, v in d_form.items():
            if v is None: 
                d_form[k] = ""

        # ✨ EL PARCHE DEL CORTOCIRCUITO: Limpieza automática de "chismes"
        estado_bd = str(d_form.get("estado_actual", "")).strip().upper()
        opciones_validas = ["EXCELENTE", "BUENO", "REGULAR", "EN REPARACIÓN", "FUERA DE SERVICIO", "BAJA"]

        if estado_bd not in opciones_validas and estado_bd != "":
            texto_previo = str(d_form.get("estado_mant_preventivo", "")).strip()
            separador = "\n\n---\n\n" if texto_previo else ""
            d_form["estado_mant_preventivo"] = f"⚠️ [REPORTE PREVIO REASIGNADO AUTOMÁTICAMENTE]: {estado_bd}{separador}{texto_previo}"
            d_form["estado_actual"] = "⚠️ SELECCIONAR ESTADO"

        # 🚨 ALERTAS VISUALES DE DOCUMENTACIÓN VENCIDA
        hoja_vence_seguro = parse_fecha(d_form.get("seguro_vence"))
        hoy = datetime.date.today()
        if hoja_vence_seguro and hoja_vence_seguro <= hoy:
            st.error(f"🚨 ¡ATENCIÓN SRA. ANA! La póliza de seguro de este vehículo VENCIÓ el {hoja_vence_seguro}.")
        elif hoja_vence_seguro and (hoja_vence_seguro - hoy).days <= 30:
            st.warning(f"⚠️ AVISO: La póliza de seguro vence pronto ({hoja_vence_seguro}).")

    # --- 📝 INICIO DEL FORMULARIO ---
    # ✨ EL EXORCISMO: Le damos una llave dinámica al formulario basada en el vehículo seleccionado.
    # Esto fuerza a Streamlit a destruir y recrear el formulario limpio cada vez que cambias de vehículo.
    clave_dinamica = f"form_vehiculo_{seleccion}"
    
    with st.form(clave_dinamica):
        tab_flota, tab_seguro, tab_impuestos, tab_bitacora = st.tabs([
            "🚗 1. Datos del Vehículo", 
            "🛡️ 2. Póliza de Seguro", 
            "💰 3. Impuestos y Trámites",
            "📝 4. Historial y Comentarios"
        ])
        
        with tab_flota:
            st.subheader("Información General de la Unidad")
            col1, col2, col3 = st.columns(3)
            with col1:
                num_control_input = st.text_input("Número de Control (Ej. VPFord)*", value=str(d_form["num_control"]), disabled=es_edicion, help="Clave única del vehículo.")
                opc_tipo = ["Auto", "Camioneta", "Remolque", "SUV", "VAN"]
                tipo_vehiculo = st.selectbox("Tipo", opc_tipo, index=get_idx([x.upper() for x in opc_tipo], str(d_form.get("tipo_vehiculo")).upper()))
                marca = st.text_input("Marca", value=str(d_form["marca"]))
                modelo = st.text_input("Modelo", value=str(d_form["modelo"]))
            with col2:
                anio = st.text_input("Año", value=str(d_form["anio"]))
                placa = st.text_input("Placa Vehicular", value=str(d_form["placa"]))
                serie = st.text_input("No. de Serie (VIN)", value=str(d_form["serie"]))
                color = st.text_input("Color", value=str(d_form["color"]))
            with col3:
                carga_maxima = st.text_input("Carga Máxima (Kg / Ton)", value=str(d_form["carga_maxima"]))
                kilometraje_actual = st.number_input("Kilometraje Actual", min_value=0, step=500, value=int(d_form.get("kilometraje_actual") or 0))
                opc_estado = ["⚠️ SELECCIONAR ESTADO", "EXCELENTE", "BUENO", "REGULAR", "EN REPARACIÓN", "FUERA DE SERVICIO", "BAJA"]
                estado_actual = st.selectbox("Estado Operativo", opc_estado, index=get_idx(opc_estado, d_form.get("estado_actual")))
                fecha_compra = st.date_input("Fecha de Adquisición / Compra", value=parse_fecha(d_form.get("fecha_compra")))
                
            estado_mant = st.text_area("Estado de Mantenimiento Preventivo", value=str(d_form["estado_mant_preventivo"]), height=90)

        with tab_seguro:
            st.subheader("Datos de la Póliza Actual")
            col4, col5 = st.columns(2)
            with col4:
                aseguradora = st.text_input("Aseguradora (Ej. Qualitas, Chubb)", value=str(d_form["aseguradora"]))
                no_poliza = st.text_input("No. de Póliza", value=str(d_form["no_poliza"]))
                opc_status = ["ACTIVA", "PROXIMA A VENCER", "VENCIDA"]
                status_seguro = st.selectbox("Estatus Póliza", opc_status, index=get_idx(opc_status, d_form.get("status_seguro")))
            with col5:
                opc_pago = ["Anual", "Semestral", "Trimestral", "Mensual"]
                forma_pago = st.selectbox("Forma de Pago", opc_pago, index=get_idx([x.upper() for x in opc_pago], str(d_form.get("forma_pago_seguro")).upper()))
                prima_total = st.number_input("Prima Total ($)", min_value=0.0, step=100.0, value=float(d_form.get("prima_total") or 0.0))
                c_fec1, c_fec2 = st.columns(2)
                seguro_inicio = c_fec1.date_input("Inicio de Vigencia", value=parse_fecha(d_form.get("seguro_inicio")))
                seguro_vence = c_fec2.date_input("Vencimiento de Póliza", value=parse_fecha(d_form.get("seguro_vence")))

        with tab_impuestos:
            st.subheader("Control de Obligaciones (Calca, Tenencia, Refrendo)")
            col6, col7 = st.columns(2)
            with col6:
                impuesto_anio = st.text_input("Año de Impuesto", value=str(d_form["impuesto_anio"]))
                impuesto_monto = st.number_input("Monto Pagado ($)", min_value=0.0, step=50.0, value=float(d_form.get("impuesto_monto") or 0.0))
            with col7:
                impuesto_f_pago = st.date_input("Fecha de Pago", value=parse_fecha(d_form.get("impuesto_fecha_pago")))
                impuesto_f_vence = st.date_input("Próximo Vencimiento", value=parse_fecha(d_form.get("impuesto_fecha_vencimiento")))

        with tab_bitacora:
            st.subheader("Bitácora de Servicios y Notas")
            mantenimiento_fecha = st.date_input("Último Mantenimiento Realizado", value=parse_fecha(d_form.get("mantenimiento_fecha")))
            servicios_hechos = st.text_area("Servicios Realizados (Frenos, Afinación, Llantas, etc.)", value=str(d_form["servicios_hechos"]))
            observaciones_comentarios = st.text_area("Observaciones Generales / Detalles de Carrocería", value=str(d_form["observaciones_comentarios"]))

        st.divider()
        
        # 🎛️ BOTONES DE ACCIÓN (2 BOTONES LIMPIOS EN UN SOLO RENGLÓN)
        if es_edicion:
            col_guardar, col_baja = st.columns([2, 1])
            with col_guardar:
                submit_btn = st.form_submit_button("💾 Actualizar Vehículo", type="primary", use_container_width=True)
            with col_baja:
                baja_btn = st.form_submit_button("🚨 Eliminar Unidad", type="secondary", use_container_width=True)
        else:
            submit_btn = st.form_submit_button("💾 Guardar Vehículo Nuevo", type="primary", use_container_width=True)
            baja_btn = False

        # --- 🟢 LÓGICA DE GUARDAR / ACTUALIZAR ---
        if submit_btn:
            # ✨ Usamos el num_control del diccionario si estamos editando, para evitar problemas si el campo está deshabilitado
            num_control_final = str(d_form["num_control"]) if es_edicion else num_control_input
            
            if not num_control_final:
                st.error("⚠️ El Número de Control es obligatorio.")
            elif estado_actual == "⚠️ SELECCIONAR ESTADO":
                st.error("🛑 OBLIGATORIO: Asigne un 'Estado Operativo' válido desde el menú antes de continuar.")
            else:
                with st.spinner("Guardando registro vehicular..."):
                    payload = {
                        "num_control": num_control_final, "marca": marca, "modelo": modelo, "serie": serie,
                        "tipo_vehiculo": tipo_vehiculo, "anio": anio, "placa": placa, "color": color,
                        "carga_maxima": carga_maxima, "kilometraje_actual": int(kilometraje_actual),
                        "estado_actual": estado_actual, "estado_mant_preventivo": estado_mant,
                        "fecha_compra": str(fecha_compra) if fecha_compra else None,
                        "aseguradora": aseguradora, "no_poliza": no_poliza, "forma_pago_seguro": forma_pago,
                        "prima_total": float(prima_total), "status_seguro": status_seguro,
                        "seguro_inicio": str(seguro_inicio) if seguro_inicio else None,
                        "seguro_vence": str(seguro_vence) if seguro_vence else None,
                        "impuesto_anio": impuesto_anio, "impuesto_monto": float(impuesto_monto),
                        "impuesto_fecha_pago": str(impuesto_f_pago) if impuesto_f_pago else None,
                        "impuesto_fecha_vencimiento": str(impuesto_f_vence) if impuesto_f_vence else None,
                        "mantenimiento_fecha": str(mantenimiento_fecha) if mantenimiento_fecha else None,
                        "servicios_hechos": servicios_hechos,
                        "observaciones_comentarios": observaciones_comentarios
                    }
                    try:
                        res_post = requests.post(f"{API_URL}/api/autos/guardar", json=payload, verify=False, timeout=10)
                        if res_post.status_code == 200:
                            st.success(f"✅ ¡Registro actualizado para la unidad {num_control_final}!")
                            st.rerun() 
                        else:
                            st.error(f"❌ Error al guardar: {res_post.text}")
                    except Exception as e:
                        st.error(f"❌ Error de conexión: {e}")

        # --- 🔴 LÓGICA DE ELIMINAR (DISPARA EL POP-UP MODAL) ---
        if baja_btn:
            num_control_final = str(d_form["num_control"]) if es_edicion else num_control_input
            modal_confirmar_baja(num_control_final, API_URL)