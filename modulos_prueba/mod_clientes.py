import streamlit as st
import requests
import pandas as pd
from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus

# 🚨 1. DIÁLOGO MODAL (POP-UP) DE CONFIRMACIÓN DE ELIMINACIÓN
@st.dialog("🚨 Confirmación de Baja de Cliente")
def modal_confirmar_baja_cliente(id_cliente, cliente_empresa, API_URL):
    st.write(f"¿Está seguro de que desea eliminar permanentemente al cliente **{cliente_empresa}** (ID: {id_cliente})?")
    st.caption("⚠️ Esta acción no se puede deshacer y borrará la empresa del catálogo maestro.")
    
    col_canc, col_conf = st.columns(2)
    if col_canc.button("❌ Cancelar", use_container_width=True):
        st.rerun()
        
    if col_conf.button("🔥 Sí, Eliminar", type="primary", use_container_width=True):
        with st.spinner(f"Eliminando cliente {cliente_empresa}..."):
            try:
                res_del = requests.delete(f"{API_URL}/api/clientes/eliminar/{id_cliente}", verify=False, timeout=5)
                if res_del.status_code == 200:
                    st.success(f"💥 Cliente **{cliente_empresa}** eliminado exitosamente.")
                    st.rerun()
                else:
                    st.error(f"❌ No se pudo eliminar: {res_del.text}")
            except Exception as e:
                st.error(f"🛑 Error de conexión: {e}")

def renderizar_modulo(API_URL):
    st.markdown("## 🏢 Catálogo Maestro de Clientes VPRO")
    st.caption("Módulo de Altas, Bajas, Cambios y Directorio de Contactos Corporativos.")

    # 1️⃣ EXTRAER CLIENTES DE LA BASE DE DATOS
    lista_clientes = []
    try:
        res = requests.get(f"{API_URL}/api/clientes", verify=False, timeout=5)
        if res.status_code == 200: 
            lista_clientes = res.json()
        else:
            st.error(f"⚠️ La API respondió con código {res.status_code}")
    except Exception as e: 
        st.error(f"🛑 Error de conexión al intentar leer clientes: {e}")

    # --- 📋 TABLA GENERAL DE CLIENTES (11 CAMPOS BD) ---
    with st.expander("📋 Ver Catálogo Completo de Clientes", expanded=False):
        if lista_clientes:
            df_resumen = pd.DataFrame(lista_clientes)
            cols_deseadas = [
                "id_cliente", "cliente_empresa", "gte_gral", "ciudad", "estado", 
                "tel_de_ofna", "email_de_empresa", "nombre_contacto_princ", 
                "cel_contact_princ", "nombre_contacto_a", "cel_contact_a"
            ]
            cols_ver = [c for c in cols_deseadas if c in df_resumen.columns]
            st.dataframe(df_resumen[cols_ver], use_container_width=True, hide_index=True)
        else:
            st.info("Sin clientes registrados actualmente.")

    # Armar diccionario para búsqueda rápida
    diccionario_cli = {f"{c['id_cliente']} - {c.get('cliente_empresa', '')}": c for c in lista_clientes if 'id_cliente' in c}
    opciones_selector = ["➕ Registrar Nuevo Cliente"] + list(diccionario_cli.keys())

    st.markdown("### 🔎 Editor de Clientes")
    seleccion = st.selectbox("Seleccione un cliente para editarlo, o elija 'Nuevo':", opciones_selector)
    
    # Preparamos las variables con las 11 columnas de pgAdmin
    d_form = {
        "id_cliente": 0, "cliente_empresa": "", "gte_gral": "", "estado": "", "ciudad": "",
        "tel_de_ofna": "", "email_de_empresa": "", "nombre_contacto_princ": "", 
        "cel_contact_princ": "", "nombre_contacto_a": "", "cel_contact_a": ""
    }
    
    es_edicion = seleccion != "➕ Registrar Nuevo Cliente"
    
    if es_edicion:
        d_form.update(diccionario_cli[seleccion])
        for k, v in d_form.items():
            if v is None: d_form[k] = ""

    # --- 📝 INICIO DEL FORMULARIO ---
    with st.form("form_alta_cliente"):
        tab_empresa, tab_contactos = st.tabs(["🏢 1. Datos de Empresa y Ubicación", "👤 2. Contactos Directos"])
        
        with tab_empresa:
            st.subheader("Datos Corporativos")
            col1, col2 = st.columns(2)
            with col1:
                id_cliente = st.number_input("ID Cliente*", min_value=0, value=int(d_form.get("id_cliente") or 0), disabled=es_edicion, help="ID numérico único del cliente.")
                cliente_empresa = st.text_input("Razón Social / Nombre Empresa*", value=str(d_form["cliente_empresa"]))
                gte_gral = st.text_input("Gerente General", value=str(d_form["gte_gral"]))
            
            with col2:
                ciudad = st.text_input("Ciudad", value=str(d_form["ciudad"]))
                estado = st.text_input("Estado", value=str(d_form["estado"]))
                tel_de_ofna = st.text_input("☎️ Teléfono de Oficina", value=str(d_form["tel_de_ofna"]))
                email_de_empresa = st.text_input("✉️ Email Empresa", value=str(d_form["email_de_empresa"]))

        with tab_contactos:
            st.subheader("Directorio de Enlaces")
            col3, col4 = st.columns(2)
            with col3:
                st.markdown("**Contacto Principal**")
                nombre_contacto_princ = st.text_input("Nombre Contacto Principal", value=str(d_form["nombre_contacto_princ"]))
                cel_contact_princ = st.text_input("📱 Celular Contacto Principal", value=str(d_form["cel_contact_princ"]))
                
            with col4:
                st.markdown("**Contacto Alterno**")
                nombre_contacto_a = st.text_input("Nombre Contacto Alterno", value=str(d_form["nombre_contacto_a"]))
                cel_contact_a = st.text_input("📱 Celular Contacto Alterno", value=str(d_form["cel_contact_a"]))

        st.divider()
        
        # 🎛️ BOTONES DE ACCIÓN (MISMO ESTÁNDAR)
        if es_edicion:
            col_guardar, col_baja = st.columns([2, 1])
            with col_guardar:
                submit_btn = st.form_submit_button("💾 Actualizar Cliente", type="primary", use_container_width=True)
            with col_baja:
                baja_btn = st.form_submit_button("🚨 Eliminar Cliente", type="secondary", use_container_width=True)
        else:
            submit_btn = st.form_submit_button("💾 Guardar Cliente Nuevo", type="primary", use_container_width=True)
            baja_btn = False

        # --- 🟢 LÓGICA DE GUARDAR / ACTUALIZAR ---
        if submit_btn:
            if not cliente_empresa or id_cliente <= 0:
                st.error("⚠️ El ID Cliente (mayor a 0) y el Nombre de la Empresa son obligatorios.")
            else:
                with st.spinner("Guardando cliente..."):
                    payload = {
                        "id_cliente": int(id_cliente),
                        "cliente_empresa": str(cliente_empresa).strip().upper(),
                        "gte_gral": str(gte_gral).strip(),
                        "estado": str(estado).strip(),
                        "ciudad": str(ciudad).strip(),
                        "tel_de_ofna": str(tel_de_ofna).strip(),
                        "email_de_empresa": str(email_de_empresa).strip(),
                        "nombre_contacto_princ": str(nombre_contacto_princ).strip(),
                        "cel_contact_princ": str(cel_contact_princ).strip(),
                        "nombre_contacto_a": str(nombre_contacto_a).strip(),
                        "cel_contact_a": str(cel_contact_a).strip()
                    }
                    try:
                        res_post = requests.post(f"{API_URL}/api/clientes/guardar", json=payload, verify=False, timeout=10)
                        if res_post.status_code == 200:
                            st.success(f"✅ ¡Registro actualizado para {cliente_empresa}!")
                            st.rerun() 
                        else:
                            st.error(f"❌ Error al guardar: {res_post.text}")
                    except Exception as e:
                        st.error(f"❌ Error de conexión: {e}")

        # --- 🔴 LÓGICA DE ELIMINAR (POP-UP MODAL) ---
        if baja_btn:
            modal_confirmar_baja_cliente(id_cliente, cliente_empresa, API_URL)