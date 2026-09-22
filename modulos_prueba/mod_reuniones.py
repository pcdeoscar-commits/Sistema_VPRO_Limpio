import streamlit as st
import requests
import datetime
import pandas as pd
from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus

def renderizar_modulo(API_URL):
    st.markdown("## 🤝 Reuniones / Prospectos")
    st.info("Aquí se guardan las minutas y acuerdos iniciales. Si el proyecto se aprueba, podrás ligarlo a una nueva Orden de Producción (OP). Al hacerlo, desaparecerá de esta lista activa.")

    # 1. EXTRAER EL HISTORIAL ACTIVO (Sin OP vinculada)
    try:
        res_historial = requests.get(f"{API_URL}/api/reuniones/historial", verify=False)
        reuniones_activas = res_historial.json() if res_historial.status_code == 200 else []
    except Exception:
        reuniones_activas = []

    # 2. LA FLECHITA (Selector Dinámico)
    opciones = [{"label": "✨ --- REGISTRAR NUEVA REUNIÓN ---", "data": None}]
    for r in reuniones_activas:
        opciones.append({
            "label": f"🗓️ {r['fecha_reunion']} | {r['cliente_tentativo']} - {r['nombre_proyecto_tentativo']}",
            "data": r
        })
        
    seleccion = st.selectbox(
        "Seleccione un prospecto activo para modificar, o elija crear uno nuevo:", 
        options=opciones, 
        format_func=lambda x: x["label"]
    )
    
    st.divider()

    # 3. AUTO-RELLENADO DE DATOS (Si eligió editar)
    data_sel = seleccion["data"]
    
    def_id = data_sel.get("id_reunion") if data_sel else None
    def_cliente = data_sel.get("cliente_tentativo", "") if data_sel else ""
    def_proyecto = data_sel.get("nombre_proyecto_tentativo", "") if data_sel else ""
    def_minuta = data_sel.get("minuta_acuerdos", "") if data_sel else ""
    def_asistentes = data_sel.get("asistentes", "") if data_sel else ""
    def_presupuesto = float(data_sel.get("presupuesto_estimado", 0.0)) if data_sel else 0.0
    
    try: 
        def_fecha_reu = datetime.date.fromisoformat(data_sel["fecha_reunion"]) if data_sel and data_sel.get("fecha_reunion") else datetime.date.today()
    except: def_fecha_reu = datetime.date.today()
        
    try: 
        def_fecha_prob = datetime.date.fromisoformat(data_sel["fecha_probable_evento"]) if data_sel and data_sel.get("fecha_probable_evento") else None
    except: def_fecha_prob = None

    # 4. EL FORMULARIO (Se adapta a crear o editar)
    with st.container():
        col1, col2 = st.columns(2)
        with col1:
            fecha_reu = st.date_input("Fecha de la Reunión *", value=def_fecha_reu)
            cliente = st.text_input("Cliente Tentativo *", value=def_cliente, placeholder="Ej. Gobierno del Estado")
            proyecto = st.text_input("Nombre del Proyecto *", value=def_proyecto, placeholder="Ej. Gira de Trabajo")
            
        with col2:
            asistentes_str = st.text_input("Asistentes *", value=def_asistentes, placeholder="Ej. Juan, Pedro, Maria...")
            presupuesto = st.number_input("Presupuesto Estimado ($)", value=def_presupuesto, step=1000.0)
            fecha_prob = st.date_input("Fecha Probable del Evento (Opcional)", value=def_fecha_prob)

        minuta = st.text_area("Minuta y Acuerdos *", value=def_minuta, height=150, placeholder="Describe de qué hablaron, qué pidieron y qué sigue...")

        # El botón cambia de nombre y función según el contexto
        texto_boton = "💾 Guardar Nueva Reunión" if def_id is None else "🔄 Actualizar Minuta de Reunión"
        
        if st.button(texto_boton, use_container_width=True):
            if not cliente or not proyecto or not asistentes_str or not minuta:
                st.warning("⚠️ Por favor, llena todos los campos marcados con asterisco (*).")
            else:
                datos_post = {
                    "id_reunion": def_id,
                    "fecha_reunion": str(fecha_reu),
                    "cliente_tentativo": cliente,
                    "nombre_proyecto_tentativo": proyecto,
                    "asistentes": asistentes_str,
                    "minuta_acuerdos": minuta,
                    "presupuesto_estimado": float(presupuesto),
                    "fecha_probable_evento": str(fecha_prob) if fecha_prob else None
                }
                
                try:
                    res_post = requests.post(f"{API_URL}/api/reuniones", json=datos_post, verify=False)
                    if res_post.status_code == 200:
                        st.success("✅ " + res_post.json().get("mensaje", "Operación exitosa."))
                        st.rerun() # Obliga a la página a recargar para actualizar la "flechita"
                    else:
                        st.error(f"❌ Error al guardar: {res_post.text}")
                except Exception as e:
                    st.error(f"🔥 Error de conexión con el servidor: {e}")

    # 5. VISOR DE TABLA (SOLO LECTURA)
    st.divider()
    st.markdown("### 🗂️ Reuniones Activas (Pendientes de OP)")
    if reuniones_activas:
        df_reuniones = pd.DataFrame(reuniones_activas)
        df_reuniones = df_reuniones.rename(columns={
            "fecha_reunion": "Fecha", "cliente_tentativo": "Cliente", 
            "nombre_proyecto_tentativo": "Proyecto", "asistentes": "Asistentes", 
            "minuta_acuerdos": "Acuerdos", "presupuesto_estimado": "Presupuesto", "fecha_probable_evento": "Probable OP"
        })
        st.dataframe(df_reuniones.drop(columns=["id_reunion"], errors='ignore'), use_container_width=True, hide_index=True)
    else:
        st.info("No hay prospectos activos. Todo está vinculado a OPs.")