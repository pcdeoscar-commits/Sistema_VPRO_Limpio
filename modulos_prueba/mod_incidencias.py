import streamlit as st
import requests
import pandas as pd
import datetime
import unicodedata
import plotly.express as px
from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus

def renderizar_modulo(API_URL):
    nombre_raw = st.session_state.get("usuario_actual", "")
    
    def limpiar_texto_firma(texto):
        texto_norm = unicodedata.normalize('NFD', str(texto))
        return "".join(c for c in texto_norm if unicodedata.category(c) != 'Mn').upper()
        
    usuario_pc = limpiar_texto_firma(nombre_raw)
    es_autorizado = "VILLARREAL" in usuario_pc or "AGUNDEZ" in usuario_pc
    
    if not es_autorizado:
        st.error("🚫 **ACCESO TOTALMENTE DENEGADO:** Módulo restringido a Dirección y Administración.")
        st.stop()

    st.markdown("## 📊 Monitoreo y Análisis de Incidencias VPRO")
    st.caption("Consola ejecutiva para evaluar desempeño de Empleados y Proveedores.")

    df_raw = pd.DataFrame(columns=['id_maestro', 'folio_op', 'incidencias_generales', 'fecha', 'id_empleado', 'nombre_evento', 'para_q_cliente', 'nombre_empleado', 'depto_real'])
    
    try:
        res_inc = requests.get(f"{API_URL}/api/incidencias/reporte", verify=False, timeout=8)
        if res_inc.status_code == 200:
            data_json = res_inc.json()
            if data_json:
                df_raw = pd.DataFrame(data_json)
                df_raw['fecha'] = pd.to_datetime(df_raw['fecha']).dt.date
                df_raw['depto_real'] = df_raw['depto_real'].fillna("Sin Departamento").astype(str).str.strip()
        else:
            st.error(f"❌ Error en el Servidor Central: Código {res_inc.status_code}")
    except Exception as e: 
        st.error(f"📡 Error de Enlace con el Servidor: {e}")
        st.stop()

    if not df_raw.empty:
        # ==========================================
        # 🧠 EL CEREBRO SEPARADOR DE EVALUACIONES
        # ==========================================
        evaluaciones = []
        
        for idx, row in df_raw.iterrows():
            texto_raw = str(row['incidencias_generales']) if pd.notna(row['incidencias_generales']) else ""
            emp_nombre = row['nombre_empleado']
            evento = row['nombre_evento']
            fecha = row['fecha']
            depto = row['depto_real']
            
            # Variables de separación
            prov_nombre = None
            prov_nota = ""  # ✨ NUEVO: Variable para guardar el chisme completo
            emp_text = texto_raw
            
            # Si hay un proveedor reportado, lo extraemos y limpiamos el texto del empleado
            if "[PROVEEDOR_INCIDENTE:" in texto_raw:
                s_idx = texto_raw.find("[PROVEEDOR_INCIDENTE:")
                e_idx = texto_raw.find("]", s_idx)
                if e_idx != -1:
                    prov_raw = texto_raw[s_idx+21:e_idx].strip()
                    if " | NOTA: " in prov_raw:
                        partes = prov_raw.split(" | NOTA: ", 1)
                        prov_nombre = partes[0].strip()
                        prov_nota = partes[1].strip() # ✨ ATRAPAMOS EL TEXTO EXACTO DEL USUARIO
                    else:
                        prov_nombre = prov_raw
                        prov_nota = "Incidencia reportada (Sin detalles)"
                    
                    # Le quitamos la culpa al empleado borrando el reporte del proveedor de su registro
                    emp_text = texto_raw[:s_idx].strip() + " " + texto_raw[e_idx+1:].strip()

            def clasificar_texto(texto):
                if not texto: return "✅ Sin Incidencias"
                t = str(texto).lower().strip()
                if t.startswith("sin incidencia") or t in ["ninguna", "todo bien", "exito", "ok", "n/a", "none", "---", ""]: 
                    return "✅ Sin Incidencias"
                return "⚠️ Con Incidencias"

            # 1. Calificamos al Empleado
            evaluaciones.append({
                "Fecha": fecha,
                "Evento": evento,
                "Actor": emp_nombre,
                "Tipo": "Empleado",
                "Departamento": depto,
                "Estatus": clasificar_texto(emp_text),
                "Nota": emp_text if emp_text.strip() else "Operación Limpia"
            })
            
            # 2. Calificamos al Proveedor (Si es que hubo uno reportado)
            if prov_nombre and "--- NINGUNO ---" not in prov_nombre.upper():
                evaluaciones.append({
                    "Fecha": fecha,
                    "Evento": evento,
                    "Actor": prov_nombre,
                    "Tipo": "Proveedor",
                    "Departamento": "Externo (Proveedor)",
                    "Estatus": "⚠️ Con Incidencias",
                    "Nota": prov_nota # ✨ PONEMOS EL TEXTO EXACTO EN LA TABLA
                })
                
        # Convertimos la nueva tabla maestra de evaluaciones
        df_eval = pd.DataFrame(evaluaciones)

        # ==========================================
        # 🎯 FILTROS DE AUDITORÍA
        # ==========================================
        st.markdown("### 🎯 Filtros de Auditoría")
        c1, c2, c3 = st.columns(3)
        
        f_min, f_max = df_eval['Fecha'].min(), df_eval['Fecha'].max()
        
        with c1: 
            rango_fechas = st.date_input("📅 Periodo de Análisis:", [f_min, f_max], key="inc_rango")
        
        with c2:
            lista_deptos = ["Todos"] + sorted(df_eval[df_eval['Tipo']=='Empleado']['Departamento'].unique().tolist())
            depto_sel = st.selectbox("🏢 Departamento:", lista_deptos, key="inc_depto")
        
        with c3:
            df_temp = df_eval.copy()
            if depto_sel != "Todos": 
                df_temp = df_temp[df_temp['Departamento'] == depto_sel]
                
            lista_empleados = sorted(df_temp[df_temp['Tipo']=='Empleado']['Actor'].unique().tolist())
            lista_proveedores = sorted(df_eval[df_eval['Tipo']=='Proveedor']['Actor'].unique().tolist())

            opciones_analisis = [
                "🌟 TODOS (Empleados y Proveedores)",
                "👥 TODOS LOS EMPLEADOS",
                "🚚 TODOS LOS PROVEEDORES"
            ]
            if lista_empleados: opciones_analisis += ["--- EMPLEADOS INDIVIDUALES ---"] + lista_empleados
            if lista_proveedores: opciones_analisis += ["--- PROVEEDORES INDIVIDUALES ---"] + lista_proveedores

            actor_sel = st.selectbox("👤/🚚 Evaluar a:", options=opciones_analisis, index=0, key="inc_actor")

        # ==========================================
        # 🧠 APLICAR FILTROS
        # ==========================================
        df_filtrado = df_eval.copy()
        
        if isinstance(rango_fechas, (list, tuple)) and len(rango_fechas) == 2: 
            df_filtrado = df_filtrado[(df_filtrado['Fecha'] >= rango_fechas[0]) & (df_filtrado['Fecha'] <= rango_fechas[1])]
        
        if depto_sel != "Todos": 
            df_filtrado = df_filtrado[(df_filtrado['Departamento'] == depto_sel) | (df_filtrado['Tipo'] == 'Proveedor')]
            
        if actor_sel == "👥 TODOS LOS EMPLEADOS":
            df_filtrado = df_filtrado[df_filtrado['Tipo'] == 'Empleado']
        elif actor_sel == "🚚 TODOS LOS PROVEEDORES":
            df_filtrado = df_filtrado[df_filtrado['Tipo'] == 'Proveedor']
        elif actor_sel.startswith("---"):
            pass
        elif actor_sel != "🌟 TODOS (Empleados y Proveedores)":
            df_filtrado = df_filtrado[df_filtrado['Actor'] == actor_sel]

        st.divider()
        
        # ==========================================
        # 🧮 MÉTRICAS (Basadas en Actores Evaluados)
        # ==========================================
        total_evaluaciones = len(df_filtrado)
        exitos = len(df_filtrado[df_filtrado['Estatus'] == "✅ Sin Incidencias"])
        fallas = total_evaluaciones - exitos
        eventos_involucrados = df_filtrado['Evento'].nunique()

        col1, col2, col3, col4 = st.columns(4)
        col1.metric("Evaluaciones Realizadas", total_evaluaciones)
        col2.metric("Evaluaciones LIMPIAS", exitos, delta=f"{(exitos/total_evaluaciones*100):.1f}%" if total_evaluaciones > 0 else "0%")
        col3.metric("Evaluaciones CON INCIDENCIAS", fallas, delta=f"-{(fallas/total_evaluaciones*100):.1f}%" if total_evaluaciones > 0 else "0%", delta_color="inverse")
        col4.metric("Eventos Únicos Auditados", eventos_involucrados)

        st.markdown("### 📊 Análisis Gráfico de Calidad Operativa")

        # 1️⃣ GRÁFICA 1: Balance General
        if total_evaluaciones > 0:
            df_comp = df_filtrado['Estatus'].value_counts(normalize=True).reset_index()
            df_comp.columns = ['Estatus', 'Porcentaje']
            df_comp['Porcentaje'] = df_comp['Porcentaje'] * 100
            df_comp['Total'] = "Balance General"
            
            fig_balance_bar = px.bar(
                df_comp, x='Total', y='Porcentaje', color='Estatus', text='Porcentaje',
                color_discrete_map={"✅ Sin Incidencias": "#2ecc71", "⚠️ Con Incidencias": "#e74c3c"}
            )
            fig_balance_bar.update_traces(texttemplate='%{text:.1f}%', textposition='inside')
            fig_balance_bar.update_layout(xaxis_title="", yaxis_title="Porcentaje (%)", height=300)
            st.plotly_chart(fig_balance_bar, use_container_width=True)

        st.write("") 

        # 2️⃣ GRÁFICA 2: Detalle por Evento (BARRA VERDE Y ROJA JUNTAS)
        if total_evaluaciones > 0:
            df_trend = df_filtrado.groupby(['Evento', 'Estatus']).size().reset_index(name='Cuenta')
            
            fig_trend = px.bar(
                df_trend, x='Evento', y='Cuenta', color='Estatus',
                color_discrete_map={"✅ Sin Incidencias": "#2ecc71", "⚠️ Con Incidencias": "#e74c3c"},
                barmode='group' # Esto hace que se pongan una al lado de la otra
            )
            fig_trend.update_layout(
                xaxis=dict(type='category', title="Eventos (Orden de Producción)"),
                yaxis_title="Cantidad de Evaluaciones", height=400
            )
            st.plotly_chart(fig_trend, use_container_width=True)

        st.divider()
        st.markdown("### 📋 Bitácora Detallada de Observaciones")

        # Mostramos absolutamente toda la bitácora (Limpios y Con Incidencias)
        df_tabla = df_filtrado
    
        if not df_tabla.empty:
            columnas_visibles = ['Fecha', 'Evento', 'Tipo', 'Actor', 'Estatus', 'Nota']
            st.dataframe(df_tabla[columnas_visibles], use_container_width=True, hide_index=True)
        else:
            st.success("✅ Operación Limpia: No hay notas para los filtros seleccionados.")
    else: 
        st.info("✅ No hay datos disponibles para procesar.")