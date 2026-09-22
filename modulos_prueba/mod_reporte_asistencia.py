import streamlit as st
import pandas as pd
import requests
import datetime
from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus

def renderizar_modulo(API_URL):
    st.markdown("## ⏱️ Auditoría Gerencial de Asistencias")
    st.info("💡 Evalúa el comportamiento de puntualidad del equipo. Las celdas en 🟥 indican omisiones y en 🟨 retardos.")

    # 1️⃣ --- CARGA DE LISTA DE PERSONAL (Reutilizando tu API de reuniones) ---
    lista_empleados = []
    try:
        res_emp = requests.get(f"{API_URL}/api/reuniones/asistentes", verify=False)
        if res_emp.status_code == 200:
            lista_empleados = res_emp.json()
    except Exception as e:
        print(f"⚠️ SILENCED ERROR in mod_reporte_asistencia.py: {e}")

    # 2️⃣ --- ZONA DE FILTROS ---
    with st.container(border=True):
        c1, c2, c3 = st.columns([1, 1, 1])
        
        # Selector de rango de fechas (Por defecto los últimos 7 días)
        hoy = datetime.date.today()
        hace_una_semana = hoy - datetime.timedelta(days=7)
        rango_fechas = c1.date_input("📅 Rango de Evaluación:", value=(hace_una_semana, hoy))
        
        # Selector de Empleado
        empleado_sel = c2.selectbox("👤 Filtrar por Empleado:", ["👥 TODOS"] + lista_empleados)
        
        c3.write("##") # Espaciador
        btn_buscar = c3.button("🔍 Generar Auditoría", type="primary", use_container_width=True)

    # 3️⃣ --- LÓGICA DEL REPORTE ---
    if btn_buscar:
        if len(rango_fechas) != 2:
            st.warning("⚠️ Por favor selecciona una Fecha de Inicio y una Fecha de Fin.")
            return

        f_ini, f_fin = rango_fechas
        
        with st.spinner("Desenterrando registros y calculando métricas..."):
            try:
                payload = {
                    "fecha_inicio": str(f_ini),
                    "fecha_fin": str(f_fin),
                    "empleado": empleado_sel
                }
                res_auditoria = requests.post(f"{API_URL}/api/asistencia/auditoria", json=payload, verify=False)
                
                if res_auditoria.status_code == 200:
                    datos = res_auditoria.json()
                    
                    if not datos and empleado_sel == "👥 TODOS":
                        st.success("📂 No hay registros de asistencia en el periodo seleccionado.")
                    else:
                        df = pd.DataFrame(datos) if datos else pd.DataFrame()
                        
                        if empleado_sel != "👥 TODOS":
                            num_dias = (f_fin - f_ini).days + 1
                            dias_rango = [str(f_ini + datetime.timedelta(days=i)) for i in range(num_dias)]
                            fechas_existentes = set(df['fecha'].astype(str)) if not df.empty else set()
                            faltantes = []
                            for d_str in dias_rango:
                                if d_str not in fechas_existentes:
                                    d_obj = datetime.date.fromisoformat(d_str)
                                    try:
                                        from core.utils import es_feriado_mexico
                                        es_fer, nom_fer = es_feriado_mexico(d_obj)
                                    except Exception:
                                        es_fer, nom_fer = False, ""

                                    es_dom = (d_obj.weekday() == 6)
                                    if es_fer:
                                        obs_texto = f"Descanso obligatorio ({nom_fer})"
                                    elif es_dom:
                                        obs_texto = "Día de descanso"
                                    else:
                                        obs_texto = "Sin registro / Falta"

                                    faltantes.append({
                                        'fecha': d_str,
                                        'nombre': empleado_sel,
                                        'hora_entrada': '--:--',
                                        'hora_salida': '--:--',
                                        'hora_entrada_v': '--:--',
                                        'hora_salida_v': '--:--',
                                        'observaciones': obs_texto
                                    })
                            if faltantes:
                                df = pd.concat([df, pd.DataFrame(faltantes)], ignore_index=True)
                        
                        # Limpiamos los nulos para evitar errores
                        df.fillna("--:--", inplace=True)
                        
                        # REGLAS DE NEGOCIO PARA ALERTAS
                        def evaluar_status(row):
                            alertas = 0
                            retardos = 0
                            # Evaluamos vacíos (Omisiones)
                            for col in ['hora_entrada', 'hora_salida', 'hora_entrada_v', 'hora_salida_v']:
                                val = str(row.get(col, ""))
                                if val in ["", "None", "null", "00:00:00", "--:--"]:
                                    alertas += 1
                                    
                            # Evaluamos retardos (Ej: Matutino después de 09:15)
                            h_in = str(row.get('hora_entrada', ''))
                            if h_in != "--:--" and h_in > "09:15:00":
                                retardos += 1
                                
                            return alertas, retardos

                        # Aplicamos reglas fila por fila
                        df[['omisiones', 'retardos']] = df.apply(lambda x: pd.Series(evaluar_status(x)), axis=1)

                        # --- GENERAR RESUMEN EJECUTIVO ---
                        st.write("---")
                        st.subheader("📊 Resumen Ejecutivo del Periodo")
                        
                        resumen = df.groupby('nombre').agg(
                            dias_laborados=('fecha', 'count'),
                            total_retardos=('retardos', 'sum'),
                            total_omisiones=('omisiones', 'sum')
                        ).reset_index()
                        
                        # Darle formato a la tabla resumen
                        st.dataframe(resumen, use_container_width=True, hide_index=True)

                        # --- GENERAR TABLA DETALLADA CON COLORES ---
                        st.write("---")
                        st.subheader("📝 Bitácora Detallada (Semáforo)")
                        
                        # Función de Pandas para pintar celdas
                        def pintar_celdas(val):
                            val_str = str(val)
                            # Celdas vacías en rojo
                            if val_str in ["", "None", "null", "00:00:00", "--:--"]:
                                return 'background-color: #fee2e2; color: #991b1b; font-weight: bold;'
                            # Retardos en amarillo (Ej: > 09:15)
                            elif len(val_str) >= 5 and ":" in val_str and val_str > "09:15:00" and val_str < "12:00:00":
                                return 'background-color: #fef08a; color: #854d0e; font-weight: bold;'
                            return ''
                        
                        # 🌙 REGLA OPERATIVA: Checadas después de las 12:00 md pertenecen al Turno Vespertino
                        def ajustar_turnos_vespertinos(row):
                            h_in = str(row.get('hora_entrada', '')).strip()
                            h_out = str(row.get('hora_salida', '')).strip()
                            v_in = str(row.get('hora_entrada_v', '')).strip()
                            v_out = str(row.get('hora_salida_v', '')).strip()
                            if h_in not in ["--:--", "", "None", "00:00:00", "00:00"] and h_in >= "12:00:00" and v_in in ["--:--", "", "None"]:
                                row['hora_entrada_v'] = h_in
                                row['hora_salida_v'] = h_out
                                row['hora_entrada'] = "--:--"
                                row['hora_salida'] = "--:--"
                            elif h_out not in ["--:--", "", "None", "00:00:00", "00:00"] and h_out >= "18:00:00" and v_out in ["--:--", "", "None"]:
                                row['hora_salida_v'] = h_out
                                row['hora_salida'] = "--:--"
                            return row

                        df = df.apply(ajustar_turnos_vespertinos, axis=1)

                        def marcar_pines_coordinador(row):
                            obs = str(row.get('observaciones', '')).upper()
                            # Pin Entrada hecha por coordinador
                            if ("ENTRADA COORD" in obs or "[EN GIRA] ENTRADA" in obs or "ENTRADA:" in obs or "📍 [EN GIRA]" in obs) and not obs.startswith("KIOSCO - T. MATUTINO"):
                                h_in = str(row.get('hora_entrada', '')).strip()
                                if h_in not in ["--:--", "", "None", "00:00:00"] and "📍" not in h_in:
                                    row['hora_entrada'] = h_in[:5] + " 📍"
                                h_inv = str(row.get('hora_entrada_v', '')).strip()
                                if h_inv not in ["--:--", "", "None", "00:00:00"] and "📍" not in h_inv:
                                    row['hora_entrada_v'] = h_inv[:5] + " 📍"
                            # Pin Salida hecha por coordinador
                            if ("SALIDA COORD" in obs or "[EN GIRA] SALIDA" in obs or "SALIDA FIN JORNADA" in obs or ("[EN GIRA]" in obs and "KIOSCO" not in obs.split("|")[-1])):
                                h_out = str(row.get('hora_salida', '')).strip()
                                if h_out not in ["--:--", "", "None", "00:00:00"] and "📍" not in h_out:
                                    row['hora_salida'] = h_out[:5] + " 📍"
                                h_outv = str(row.get('hora_salida_v', '')).strip()
                                if h_outv not in ["--:--", "", "None", "00:00:00"] and "📍" not in h_outv:
                                    row['hora_salida_v'] = h_outv[:5] + " 📍"
                            return row

                        df = df.apply(marcar_pines_coordinador, axis=1)

                        # Limpiamos columnas para mostrar con Día y Fecha separados
                        dias_semana_es = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
                        def extraer_dia(f_val):
                            try:
                                f_dt = pd.to_datetime(f_val)
                                return dias_semana_es[f_dt.weekday()]
                            except Exception:
                                return ""

                        def formatear_solo_fecha(f_val):
                            try:
                                f_dt = pd.to_datetime(f_val)
                                return f_dt.strftime('%d/%m/%Y')
                            except Exception:
                                return str(f_val)

                        df_mostrar = df[['fecha', 'nombre', 'hora_entrada', 'hora_salida', 'hora_entrada_v', 'hora_salida_v', 'observaciones']].copy()
                        df_mostrar['Día'] = df_mostrar['fecha'].apply(extraer_dia)
                        df_mostrar['Fecha'] = df_mostrar['fecha'].apply(formatear_solo_fecha)
                        df_mostrar = df_mostrar[['Día', 'Fecha', 'nombre', 'hora_entrada', 'hora_salida', 'hora_entrada_v', 'hora_salida_v', 'observaciones']]
                        df_mostrar.columns = ['Día', 'Fecha', 'Empleado', '☀️ Mat In', '☀️ Mat Out', '🌙 Vesp In', '🌙 Vesp Out', 'Notas']
                        
                        # Aplicamos los estilos solo a las horas
                        df_estilizado = df_mostrar.style.map(pintar_celdas, subset=['☀️ Mat In', '☀️ Mat Out', '🌙 Vesp In', '🌙 Vesp Out'])
                        
                        st.dataframe(df_estilizado, use_container_width=True, hide_index=True)

            except Exception as e:
                st.error(f"📡 Error de comunicación con el servidor: {e}")