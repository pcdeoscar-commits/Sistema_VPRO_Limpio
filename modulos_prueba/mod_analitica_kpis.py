import streamlit as st
import pandas as pd
import requests
import plotly.express as px
from datetime import date, timedelta
from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus

def renderizar_modulo(API_URL):
    # ENCABEZADO Y FILTRO GLOBAL
    st.markdown("## 📊 VPRO Analytics | Dashboard Ejecutivo")
    st.caption("Visión global de indicadores clave, rentabilidad y operatividad de la empresa.")
    
    # 🌟 EL CALENDARIO MÁGICO (Rango de Fechas)
    hoy = date.today()
    hace_un_mes = hoy - timedelta(days=30)
    
    col1, col2 = st.columns([1, 3])
    with col1:
        rango_fechas = st.date_input(
            "📅 Selecciona el rango a evaluar:",
            value=(hace_un_mes, hoy),
            max_value=hoy # Para que no puedan elegir fechas del futuro
        )
    
    # Validación: Streamlit devuelve una tupla de 1 elemento si el usuario
    if len(rango_fechas) != 2:
        st.warning("⏳ Por favor, selecciona la fecha de fin en el calendario.")
        st.stop() # Detiene la pantalla hasta que tengamos las dos fechas
        
    fecha_inicio, fecha_fin = rango_fechas
    st.divider()

    # CONEXIÓN A LA API (AHORA ENVIANDO FECHAS)
    datos = {}
    try:
        # 🌟 Le inyectamos las fechas a la URL usando "params"
        res = requests.get(
            f"{API_URL}/api/dashboard/resumen", 
            params={"fecha_inicio": fecha_inicio, "fecha_fin": fecha_fin},
            verify=False, 
            timeout=10
        )
        if res.status_code == 200:
            datos = res.json()
        else:
            st.warning("⚠️ No se pudieron cargar los datos del dashboard. Revisa la conexión.")
    except Exception as e:
        st.error(f"📡 Error de conexión con la API: {e}")

    # Extraer categorías de datos
    finanzas = datos.get("finanzas", {})
    comercial = datos.get("comercial", {})
    operaciones = datos.get("operaciones", {})

    # ESTRUCTURA DE PESTAÑAS (TABS)
    tab_finanzas, tab_comercial, tab_operaciones = st.tabs([
        "💰 Finanzas y Activos", 
        "📈 Producción y Clientes", 
        "⚙️ Operaciones y RRHH"
    ])

    # 1️⃣ PESTAÑA: FINANZAS Y ACTIVOS
    with tab_finanzas:
        st.markdown("### 🛠️ Salud del Capital y Riesgos")
        
        m1, m2, m3, m4 = st.columns(4)
        m1.metric("Gasto en Reparaciones", f"${finanzas.get('gasto_mes', 0):,.2f}", "Rango seleccionado")
        m2.metric("Equipos Dañados / Taller", finanzas.get('equipos_danados', 0), "Activos")
        m3.metric("Flota Vehicular en Taller", finanzas.get('flota_taller', 0), "Autos Inactivos")
        m4.metric("Seguros por Vencer", finanzas.get('seguros_vencer', 0), "Próximos 30 días")

        st.divider()
        
        col_graf_1, col_graf_2 = st.columns(2)
        with col_graf_1:
            st.markdown("#### 🚨 Equipos Dañados por Departamento")
            df_deptos = pd.DataFrame(finanzas.get("deptos_danos", []))
            if not df_deptos.empty:
                fig_deptos = px.pie(df_deptos, values='total', names='depto', hole=0.4)
                st.plotly_chart(fig_deptos, use_container_width=True)
            else:
                st.info("No hay datos de daños registrados en estas fechas.")
            
        with col_graf_2:
            st.markdown("#### 🚙 Unidades con Desperfectos (Taller)")
            df_flota = pd.DataFrame(finanzas.get("estado_flota", []))
            
            if not df_flota.empty:
                # 🧠 INTELIGENCIA DE FILTRADO: Identificamos los que NO están bien
                def tiene_falla(texto):
                    t = str(texto).lower().strip()
                    # Si el comentario tiene estas palabras, el auto está SANO (Falso que tiene falla)
                    if "excelente" in t or t == "e c" or t == "ec" or "ok" in t:
                        return False
                    return True # Cualquier otra cosa rara (truena, apaga, chocado) es una FALLA
                
                df_flota['tiene_falla'] = df_flota['estado'].apply(tiene_falla)
                df_fallas = df_flota[df_flota['tiene_falla']].copy()
                
                if not df_fallas.empty:
                    df_fallas['Unidad'] = 1 
                    
                    fig_autos = px.bar(
                        df_fallas, 
                        x='num_control',      
                        y='Unidad',           
                        color='marca',        
                        text='estado', # ✨ MAGIA: Imprime el texto directamente en la gráfica
                        labels={"num_control": "Vehículo", "marca": "Marca", "estado": "Falla Reportada"}
                    )
                    
                    # Formato para que el texto se vea súper claro y centrado
                    fig_autos.update_traces(textposition='inside', textfont_size=14, insidetextanchor='middle')
                    fig_autos.update_yaxes(showticklabels=False, title="")
                    fig_autos.update_layout(xaxis_title="Unidades Afectadas")
                    
                    st.plotly_chart(fig_autos, use_container_width=True)
                else:
                    # Si la lista de fallas quedó vacía, celebramos
                    st.success("🎉 ¡Excelente noticia! Toda la flota está operando al 100%.")
            else:
                st.info("No hay datos de vehículos registrados.")

    # 2️⃣ PESTAÑA: PRODUCCIÓN Y CLIENTES
    with tab_comercial:
        st.markdown("### 📝 Rendimiento Comercial y Volumen")
        
        c1, c2, c3 = st.columns(3)
        c1.metric("Órdenes de Producción", comercial.get('ops_mes', 0), "En el periodo")
        c2.metric("Cliente Principal", comercial.get('cliente_top', "N/A"), "Mayor Volumen")
        c3.metric("Proveedores Activos", comercial.get('proveedores_activos', 0), "En OPs")
        
        st.divider()
        
        col_com_1, col_com_2 = st.columns(2)
        
        with col_com_1:
            st.markdown("#### 🏆 Top 5 Clientes")
            df_clientes = pd.DataFrame(comercial.get("top_clientes", []))
            if not df_clientes.empty:
                df_clientes = df_clientes.sort_values(by="total", ascending=False) 
                fig_cli = px.bar(df_clientes, x='cliente', y='total', text='total', color_discrete_sequence=['#2ecc71'])
                fig_cli.update_traces(textposition='outside') 
                st.plotly_chart(fig_cli, use_container_width=True)
            else:
                st.info("No hay datos de clientes.")
                
        with col_com_2:
            st.markdown("#### 📈 Evolución de Órdenes de Producción")
            df_ops = pd.DataFrame(comercial.get("ops_por_mes", []))
            if not df_ops.empty:
                fig_ops = px.line(df_ops, x='mes', y='total', markers=True, color_discrete_sequence=['#9b59b6'])
                fig_ops.update_traces(line=dict(width=3), marker=dict(size=8))
                st.plotly_chart(fig_ops, use_container_width=True)
            else:
                st.info("No hay datos de OPs en estas fechas.")
                
    # 3️⃣ PESTAÑA: OPERACIONES Y RRHH
    with tab_operaciones:
        st.markdown("### ⚙️ Eficiencia Logística y Personal")
        
        o1, o2, o3 = st.columns(3)
        o1.metric("Checkouts con Incidencias", f"{operaciones.get('tasa_incidencias', 0)}%", "Tasa de Error")
        o2.metric("Logística a Tiempo", f"{operaciones.get('logistica_tiempo', 0)}%", "Entregas limpias")
        o3.metric("Empleado más activo", operaciones.get('empleado_top', "N/A"), "Más OPs asignadas")
        
        st.divider()
        
        col_op_1, col_op_2 = st.columns(2)
        
        with col_op_1:
            st.markdown("#### 🏃‍♂️ Top 3 Empleados (Carga de Trabajo)")
            df_emp = pd.DataFrame(operaciones.get("top_empleados", []))
            
            if not df_emp.empty:
                # Ordenamos de menor a mayor para que en la gráfica horizontal el mayor quede arriba
                df_emp = df_emp.sort_values(by="total", ascending=True) 
                fig_emp = px.bar(
                    df_emp, x='total', y='empleado', orientation='h', text='total',
                    color_discrete_sequence=['#3498db']
                )
                fig_emp.update_traces(textposition='outside')
                fig_emp.update_layout(xaxis_title="Checkouts Realizados", yaxis_title="")
                st.plotly_chart(fig_emp, use_container_width=True)
            else:
                st.info("No hay datos suficientes de actividad de personal en este rango de fechas.")
                
        with col_op_2:
            st.markdown("#### 🎯 Efectividad en Checkouts")
            df_efec = pd.DataFrame(operaciones.get("efectividad_checkouts", []))
            
            if not df_efec.empty:
                fig_efec = px.pie(
                    df_efec, values='total', names='estado', hole=0.4,
                    color='estado', 
                    color_discrete_map={"Limpios": "#2ecc71", "Con Incidencias": "#e74c3c"}
                )
                fig_efec.update_traces(textinfo='percent+label', textposition='inside')
                st.plotly_chart(fig_efec, use_container_width=True)
            else:
                st.info("No hay datos de evaluación de checkouts en este rango de fechas.")