import streamlit as st

st.set_page_config(page_title="Lab Autos VPRO", layout="wide")

st.markdown("## 🚙 Laboratorio de Control Vehicular (Pruebas)")
st.info("💡 Todo lo que se guarde aquí se irá a la tabla 'autos_prueba'")

with st.form("form_alta_auto"):
    # Creamos las 3 pestañas para organizar el formulario
    tab_flota, tab_seguro, tab_impuestos = st.tabs([
        "🚗 1. Datos del Vehículo", 
        "🛡️ 2. Póliza de Seguro", 
        "💰 3. Impuestos y Trámites"
    ])
    
    with tab_flota:
        st.subheader("Información General de la Unidad")
        col1, col2, col3 = st.columns(3)
        with col1:
            num_control = st.text_input("Número de Control (Ej. VPFord)*")
            tipo_vehiculo = st.selectbox("Tipo", ["Auto", "Camioneta", "Remolque", "SUV", "VAN"])
            marca = st.text_input("Marca")
            modelo = st.text_input("Modelo")
        with col2:
            anio = st.text_input("Año")
            placa = st.text_input("Placa Vehicular")
            serie = st.text_input("No. de Serie (VIN)")
            color = st.text_input("Color")
        with col3:
            carga_maxima = st.text_input("Carga Máxima")
            estado_actual = st.selectbox("Estado del Vehículo", ["EXCELENTE", "BUENO", "REGULAR", "EN REPARACIÓN", "BAJA"])
            estado_mant = st.text_area("Estado de Mant. Preventivo", height=68)

    with tab_seguro:
        st.subheader("Datos de la Póliza Actual")
        col4, col5 = st.columns(2)
        with col4:
            aseguradora = st.text_input("Aseguradora (Ej. Qualitas, Chubb)")
            no_poliza = st.text_input("No. de Póliza")
            status_seguro = st.selectbox("Status", ["ACTIVA", "PROXIMA A VENCER", "VENCIDA"])
        with col5:
            forma_pago = st.selectbox("Forma de Pago", ["Anual", "Semestral", "Trimestral", "Mensual"])
            prima_total = st.number_input("Prima Total ($)", min_value=0.0, step=100.0)
            c_fec1, c_fec2 = st.columns(2)
            seguro_inicio = c_fec1.date_input("Inicio de Vigencia")
            seguro_vence = c_fec2.date_input("Vencimiento")

    with tab_impuestos:
        st.subheader("Control de Obligaciones (Calca, Tenencia)")
        col6, col7 = st.columns(2)
        with col6:
            impuesto_anio = st.text_input("Año de Impuesto")
            impuesto_monto = st.number_input("Monto Pagado ($)", min_value=0.0, step=50.0)
        with col7:
            impuesto_f_pago = st.date_input("Fecha de Pago")
            impuesto_f_vence = st.date_input("Próximo Vencimiento")

    st.divider()
    # Botón para enviar todo el formulario
    submit_btn = st.form_submit_button("💾 Guardar Vehículo en Base de Datos", type="primary", use_container_width=True)

    if submit_btn:
        if not num_control:
            st.error("⚠️ El Número de Control es obligatorio.")
        else:
            with st.spinner("Guardando en la base de datos..."):
                # 📦 Empaquetamos EXACTAMENTE con los nombres de tus columnas en PostgreSQL
                payload = {
                    "num_control": num_control,
                    "marca": marca,
                    "modelo": modelo,
                    "serie": serie,
                    "tipo_vehiculo": tipo_vehiculo,
                    "anio": anio,
                    "placa": placa,
                    "color": color,
                    "carga_maxima": carga_maxima,
                    "estado_actual": estado_actual,
                    "estado_mant_preventivo": estado_mant,
                    "aseguradora": aseguradora,
                    "no_poliza": no_poliza,
                    "forma_pago_seguro": forma_pago,
                    "prima_total": float(prima_total),
                    "status_seguro": status_seguro,
                    "seguro_inicio": str(seguro_inicio) if seguro_inicio else None,
                    "seguro_vence": str(seguro_vence) if seguro_vence else None,
                    "impuesto_anio": impuesto_anio,
                    "impuesto_monto": float(impuesto_monto),
                    "impuesto_fecha_pago": str(impuesto_f_pago) if impuesto_f_pago else None,
                    "impuesto_fecha_vencimiento": str(impuesto_f_vence) if impuesto_f_vence else None,
                    # Los campos originales que no están en esta vista los mandamos vacíos por ahora
                    "fecha_compra": None,
                    "servicios_hechos": "",
                    "observaciones_comentarios": ""
                }
                st.success("✅ Paquete de datos armado correctamente. (Conexión al API simulada).")