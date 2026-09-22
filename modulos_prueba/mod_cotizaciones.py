import streamlit as st
import pandas as pd
import datetime
import requests
from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus

def renderizar_modulo(API_URL):
    st.markdown("## 📄 Módulo Generador de Cotizaciones")
    st.caption("Creación dinámica de propuestas comerciales con estandarización ISO 9001-2015 (VPF-PSC-COT).")

    # 1️⃣ DATOS GENERALES DEL CLIENTE (Conectado a la Base de Datos)
    st.markdown("### 👤 Datos del Cliente")
    
    lista_clientes = [] # 🔌 Llamada al backend para obtener el catálogo de clientes
    try:
        res_clientes = requests.get(f"{API_URL}/api/clientes/catalogo", verify=False, timeout=5)
        if res_clientes.status_code == 200:
            lista_clientes = res_clientes.json() 
    except Exception as e:
        st.warning("⚠️ No se pudo cargar el catálogo de clientes. Verifica la conexión con el servidor.")

    col_c1, col_c2 = st.columns(2)
    with col_c1:
        cliente_empresa = st.selectbox("Empresa / Cliente:", options=["--- Selecciona un Cliente ---"] + lista_clientes)
        
        lista_contactos = []
        if cliente_empresa != "--- Selecciona un Cliente ---":
            try:
                res_contactos = requests.get(f"{API_URL}/api/clientes/contactos/{cliente_empresa}", verify=False, timeout=5)
                if res_contactos.status_code == 200:
                    lista_contactos = res_contactos.json()
            except Exception as e:
                print(f"⚠️ SILENCED ERROR in mod_cotizaciones.py: {e}") # Si falla la red, simplemente no cargamos la lista
        
        opciones_contacto = ["--- Selecciona un Contacto ---"] + lista_contactos + ["✍️ Capturar manualmente..."]
        contacto_seleccionado = st.selectbox("Atención a (Contacto):", options=opciones_contacto)
        
        if contacto_seleccionado == "✍️ Capturar manualmente...":
            cliente_contacto = st.text_input("Ingresa el nombre del contacto:")
        else:
            cliente_contacto = contacto_seleccionado if contacto_seleccionado != "--- Selecciona un Contacto ---" else ""

    with col_c2:
        cliente_depto = st.text_input("Departamento / Puesto:", placeholder="Ej. Depto. De Compras-Región Pacífico")
        fecha_cotizacion = st.date_input("Fecha de la Cotización:", datetime.date.today())

    st.divider()
    
    # 2️⃣ CUERPO DE LA PROPUESTA (Totalmente editable)
    st.markdown("### 📝 Estructura de la Propuesta")
    
    texto_introduccion = st.text_area(
        "Contexto / Introducción:", 
        value="Ponemos a su consideración el siguiente presupuesto por servicios...", 
        height=100
    )
    
    col_t1, col_t2 = st.columns(2)
    with col_t1:
        texto_tecnico = st.text_area(
            "Propuesta Técnica:", 
            value="- Adaptación de guion.\n- 5 minutos de edición y animación CutOut.\n- Voz de narrador.\n- Musicalización libre de derechos.", 
            height=150
        )
    with col_t2:
        texto_entregables = st.text_area(
            "Entregables:", 
            value="- Entrega de máster de 5 minutos.\n- Entrega de cada módulo (tema) por separado.", 
            height=150
        )

    st.divider()

    # 3️⃣ TABLA DINÁMICA DE COSTOS
    st.markdown("### 💰 Desglose Económico y Servicios")
    st.caption("Agrega filas escribiendo en la última celda vacía o usando el símbolo '+' que aparece al pasar el ratón.")

    if 'df_cotizacion' not in st.session_state:
        st.session_state.df_cotizacion = pd.DataFrame([{"CANTIDAD": 1, "CONCEPTO": "", "PRECIO_UNITARIO": 0.0}])

    df_editado = st.data_editor(
        st.session_state.df_cotizacion,
        num_rows="dynamic",
        use_container_width=True,
        hide_index=True,
        column_config={
            "CANTIDAD": st.column_config.NumberColumn("Cant.", min_value=1, step=1),
            "CONCEPTO": st.column_config.TextColumn("Descripción del Concepto / Equipo", required=True),
            "PRECIO_UNITARIO": st.column_config.NumberColumn("Precio Unitario ($)", min_value=0.0, format="$ %.2f")
        }
    )

    subtotal = 0.0  # Matemáticas automáticas
    if not df_editado.empty:
        df_editado["CANTIDAD"] = pd.to_numeric(df_editado["CANTIDAD"], errors='coerce').fillna(1)
        df_editado["PRECIO_UNITARIO"] = pd.to_numeric(df_editado["PRECIO_UNITARIO"], errors='coerce').fillna(0.0)
        df_editado["IMPORTE"] = df_editado["CANTIDAD"] * df_editado["PRECIO_UNITARIO"]
        subtotal = df_editado["IMPORTE"].sum()

    iva = subtotal * 0.16
    total = subtotal + iva

    st.write("##")
    m1, m2, m3 = st.columns(3)
    m1.metric("📊 Subtotal", f"${subtotal:,.2f}")
    m2.metric("⚖️ IVA (16%)", f"${iva:,.2f}")
    m3.metric("💵 TOTAL DEFINITIVO", f"${total:,.2f}")

    st.divider()

    # 4️⃣ POLÍTICAS Y CONDICIONES
    st.markdown("### 📜 Políticas y Condiciones Comerciales")
    texto_politicas = st.text_area(
        "Políticas de VPro (Editables por el vendedor):", 
        value="- Precios indicados son en pesos y más IVA.\n- Para efectos de reservación de agenda se requiere del 50% de anticipo y resto al término del evento y/o ORDEN DE COMPRA.\n- En caso de realizar el evento a primeras horas de la mañana, se requiere instalar un día previo por la tarde, para realización de ensayos y pruebas en un máximo de 3hrs. servicio tendrá un costo adicional del 50% sobre el valor del evento cotizado.\n- El cliente proporcionará facillidades de permisos y resguardo de equipo en el lugar del evento, cuando se requiera instalar un día previo.",
        height=200
    )

    st.write("##")
    
    # 5️⃣ BOTÓN DISPARADOR Y GENERADOR DE PDF
    from fpdf import FPDF
    import tempfile
    import os

    if cliente_empresa == "--- Selecciona un Cliente ---":
        st.warning("⚠️ Selecciona un cliente para habilitar la descarga del PDF.")
    elif subtotal <= 0:
        st.warning("⚠️ Agrega al menos un concepto con costo para generar la cotización.")
    else:
        def crear_pdf():
            pdf = FPDF(format='letter')
            pdf.add_page()
            
            ruta_plantilla = "hoja_membretada.png"  # 1. PLANTILLA DE FONDO
            if os.path.exists(ruta_plantilla):
                pdf.image(ruta_plantilla, x=0, y=0, w=215.9, h=279.4)
            
            pdf.set_y(45)   # Bajamos el cursor un poco para librar el logo superior
            
            pdf.set_font("Arial", "B", 11)  # 2. DATOS DEL CLIENTE
            pdf.cell(0, 5, f"Empresa: {cliente_empresa}", ln=True)
            
            pdf.set_font("Arial", "", 10)
            pdf.cell(0, 5, f"Atención a: {cliente_contacto}", ln=True)
            if cliente_depto: # Solo se imprime si hay un departamento capturado
                pdf.cell(0, 5, f"Departamento: {cliente_depto}", ln=True)
            pdf.ln(8)

            pdf.set_font("Arial", "", 10)   # 3. TEXTOS Y PROPUESTAS
            pdf.multi_cell(0, 5, texto_introduccion)
            pdf.ln(5)

            if texto_tecnico:   # Agregar Propuesta Técnica
                pdf.set_font("Arial", "B", 10)
                pdf.cell(0, 5, "Propuesta Técnica:", ln=True)
                pdf.set_font("Arial", "", 10)
                pdf.multi_cell(0, 5, texto_tecnico)
                pdf.ln(5)

            if texto_entregables:   # Agregar Entregables
                pdf.set_font("Arial", "B", 10)
                pdf.cell(0, 5, "Entregables:", ln=True)
                pdf.set_font("Arial", "", 10)
                pdf.multi_cell(0, 5, texto_entregables)
                pdf.ln(5)

            pdf.set_font("Arial", "B", 10)  # 4. TABLA DINÁMICA DE COSTOS
            pdf.set_fill_color(200, 200, 200)
            pdf.cell(20, 7, "CANT.", border=1, fill=True, align='C')
            pdf.cell(110, 7, "CONCEPTO", border=1, fill=True, align='C')
            pdf.cell(30, 7, "P. UNITARIO", border=1, fill=True, align='C')
            pdf.cell(30, 7, "IMPORTE", border=1, fill=True, align='C')
            pdf.ln()

            pdf.set_font("Arial", "", 9)
            for _, fila in df_editado.iterrows():
                if fila["CANTIDAD"] > 0 and fila["PRECIO_UNITARIO"] > 0:
                    pdf.cell(20, 7, str(int(fila["CANTIDAD"])), border=1, align='C')
                    concepto_corto = str(fila["CONCEPTO"])[:55] 
                    pdf.cell(110, 7, concepto_corto, border=1)
                    pdf.cell(30, 7, f"${fila['PRECIO_UNITARIO']:,.2f}", border=1, align='R')
                    pdf.cell(30, 7, f"${fila['IMPORTE']:,.2f}", border=1, align='R')
                    pdf.ln()

            pdf.set_font("Arial", "B", 10)  # TOTALES
            pdf.cell(160, 7, "SUBTOTAL", border=1, align='R')
            pdf.cell(30, 7, f"${subtotal:,.2f}", border=1, align='R')
            pdf.ln()
            pdf.cell(160, 7, "IVA (16%)", border=1, align='R')
            pdf.cell(30, 7, f"${iva:,.2f}", border=1, align='R')
            pdf.ln()
            pdf.cell(160, 7, "TOTAL", border=1, align='R')
            pdf.cell(30, 7, f"${total:,.2f}", border=1, align='R')
            pdf.ln(8)

            pdf.set_font("Arial", "B", 9)   # 5. POLÍTICAS
            pdf.cell(0, 5, "Políticas y Condiciones:", ln=True)
            pdf.set_font("Arial", "", 8)
            pdf.multi_cell(0, 4, texto_politicas)
            
            pdf.ln(10)  # 6. FIRMA, QR Y FECHA
            pdf.set_font("Arial", "B", 10)
            pdf.cell(0, 5, "Atentamente:", ln=True, align="C")
            pdf.cell(0, 5, "Pedro Villarreal Uribe / Director", ln=True, align="C")
            
            # Insertar QR de VPRO (Debe estar en la misma carpeta como qr_vpro.png)
            ruta_qr = "qr_vpro.png"
            if os.path.exists(ruta_qr):
                y_actual = pdf.get_y() + 2 # Guardamos la altura actual
                pdf.image(ruta_qr, x=95, y=y_actual, w=25)
                pdf.set_y(y_actual + 27) 
            else:
                pdf.ln(15) # Espacio en blanco si no encuentra el QR
                
            pdf.cell(0, 5, f"Fecha de emisión: {fecha_cotizacion}", ln=True, align="C")

            return pdf.output(dest='S').encode('latin1')

        pdf_bytes = crear_pdf()
        st.download_button(
            label="⬇️ DESCARGAR COTIZACIÓN EN PDF",
            data=pdf_bytes,
            file_name=f"Cotizacion_VPRO_{cliente_empresa.replace(' ', '_')}.pdf",
            mime="application/pdf",
            type="primary"
        )