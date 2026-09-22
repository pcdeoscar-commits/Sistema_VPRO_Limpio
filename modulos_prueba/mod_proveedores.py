import streamlit as st
import requests
import pandas as pd
import time
from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus

# 🚨 1. DIÁLOGO MODAL (POP-UP) DE CONFIRMACIÓN DE BAJA
@st.dialog("🚨 Confirmación de Baja de Proveedor")
def modal_confirmar_baja_proveedor(nombre_proveedor, API_URL):
    st.write(f"¿Está seguro de que desea eliminar permanentemente al proveedor **{nombre_proveedor}**?")
    st.caption("⚠️ Esta acción no se puede deshacer y eliminará la empresa del catálogo maestro.")
    
    col_canc, col_conf = st.columns(2)
    if col_canc.button("❌ Cancelar", use_container_width=True):
        st.rerun()
        
    if col_conf.button("🔥 Sí, Eliminar", type="primary", use_container_width=True):
        with st.spinner(f"Eliminando proveedor {nombre_proveedor}..."):
            try:
                res_del = requests.delete(f"{API_URL}/api/proveedores/eliminar/{nombre_proveedor}", verify=False, timeout=5)
                if res_del.status_code == 200:
                    st.success(f"💥 Proveedor **{nombre_proveedor}** eliminado exitosamente.")
                    st.rerun()
                else:
                    st.error(f"❌ No se pudo eliminar: {res_del.text}")
            except Exception as e:
                st.error(f"🛑 Error de conexión: {e}")

def renderizar_modulo(API_URL):
    st.markdown("## 🚚 Catálogo Maestro de Proveedores VPRO")
    st.caption("Módulo de Altas, Bajas, Cambios y Directorio de Proveedores Comerciales.")

    # 1️⃣ EXTRAER PROVEEDORES DE LA BASE DE DATOS
    lista_proveedores = []
    try:
        res = requests.get(f"{API_URL}/api/proveedores", verify=False, timeout=5)
        if res.status_code == 200: 
            lista_proveedores = res.json()
        else:
            st.error(f"⚠️ La API respondió con código {res.status_code}")
    except Exception as e: 
        st.error(f"🛑 Error de conexión al intentar leer proveedores: {e}")

    # --- 📋 TABLA GENERAL DE PROVEEDORES (10 CAMPOS BD) ---
    with st.expander("📋 Ver Catálogo Completo de Proveedores", expanded=False):
        if lista_proveedores:
            df_resumen = pd.DataFrame(lista_proveedores)
            cols_deseadas = [
                "nombre_del_proveedor", "gte_gral", "ciudad", "estado", 
                "tel_de_ofna", "email_de_empresa", "nombre_contacto_princ", 
                "cel_contact_princ", "nombre_contacto_a", "cel_contact_a"
            ]
            cols_ver = [c for c in cols_deseadas if c in df_resumen.columns]
            st.dataframe(df_resumen[cols_ver], use_container_width=True, hide_index=True)
        else:
            st.info("Sin proveedores registrados actualmente.")

    # Armar diccionario para búsqueda rápida
    diccionario_prov = {p['nombre_del_proveedor']: p for p in lista_proveedores if 'nombre_del_proveedor' in p}
    opciones_selector = ["➕ Registrar Nuevo Proveedor"] + list(diccionario_prov.keys())

    st.markdown("### 🔎 Editor de Proveedores")
    seleccion = st.selectbox("Seleccione un proveedor para editarlo, o elija 'Nuevo':", opciones_selector)
    
    # Preparamos las variables con las 10 columnas de pgAdmin
    d_form = {
        "nombre_del_proveedor": "", "gte_gral": "", "estado": "", "ciudad": "",
        "tel_de_ofna": "", "email_de_empresa": "", "nombre_contacto_princ": "", 
        "cel_contact_princ": "", "nombre_contacto_a": "", "cel_contact_a": ""
    }
    
    es_edicion = seleccion != "➕ Registrar Nuevo Proveedor"
    
    if es_edicion:
        d_form.update(diccionario_prov[seleccion])
        for k, v in d_form.items():
            if v is None: d_form[k] = ""

    # --- 📝 INICIO DEL FORMULARIO ---
    with st.form("form_alta_proveedor"):
        tab_empresa, tab_contactos = st.tabs(["🚚 1. Datos Corporativos y Ubicación", "👤 2. Contactos Directos"])
        
        with tab_empresa:
            st.subheader("Datos Comerciales")
            col1, col2 = st.columns(2)
            with col1:
                nombre_del_proveedor = st.text_input("Razón Social / Nombre Proveedor*", value=str(d_form["nombre_del_proveedor"]), disabled=es_edicion, help="Nombre único del proveedor (Llave Principal).")
                gte_gral = st.text_input("Gerente General", value=str(d_form["gte_gral"]))
            
            with col2:
                ciudad = st.text_input("Ciudad", value=str(d_form["ciudad"]))
                estado = st.text_input("Estado", value=str(d_form["estado"]))
            
            col_tel, col_email = st.columns(2)
            with col_tel:
                tel_de_ofna = st.text_input("☎️ Teléfono de Oficina", value=str(d_form["tel_de_ofna"]))
            with col_email:
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
        
        # 🎛️ BOTONES DE ACCIÓN
        if es_edicion:
            col_guardar, col_baja = st.columns([2, 1])
            with col_guardar:
                submit_btn = st.form_submit_button("💾 Actualizar Proveedor", type="primary", use_container_width=True)
            with col_baja:
                baja_btn = st.form_submit_button("🚨 Eliminar Proveedor", type="secondary", use_container_width=True)
        else:
            submit_btn = st.form_submit_button("💾 Guardar Proveedor Nuevo", type="primary", use_container_width=True)
            baja_btn = False

        # --- 🟢 LÓGICA DE GUARDAR / ACTUALIZAR ---
        if submit_btn:
            if not nombre_del_proveedor.strip():
                st.error("⚠️ El Nombre del Proveedor es obligatorio.")
            else:
                with st.spinner("Guardando proveedor..."):
                    payload = {
                        "nombre_del_proveedor": str(nombre_del_proveedor).strip().upper(),
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
                        res_post = requests.post(f"{API_URL}/api/proveedores/guardar", json=payload, verify=False, timeout=10)
                        if res_post.status_code == 200:
                            st.success(f"✅ ¡Registro guardado para {nombre_del_proveedor}!")
                            st.rerun() 
                        else:
                            st.error(f"❌ Error al guardar: {res_post.text}")
                    except Exception as e:
                        st.error(f"❌ Error de conexión: {e}")

        # --- 🔴 LÓGICA DE ELIMINAR (POP-UP MODAL) ---
        if baja_btn:
            modal_confirmar_baja_proveedor(nombre_del_proveedor, API_URL)