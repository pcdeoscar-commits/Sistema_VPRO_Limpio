import streamlit as st
import streamlit.components.v1 as components
import requests
import datetime

def renderizar_modulo(API_URL):
    st.markdown("""
    <div style="background-color: #f8fafc; padding: 22px; border-radius: 12px; border-left: 8px solid #3788d8; margin-bottom: 25px;">
        <h3 style="color: #0f172a; margin: 0 0 8px 0;">📅 Agenda de Actividades y Giras</h3>
        <p style="color: #475569; margin: 0; font-size: 14px;">
            Vista consolidada de Órdenes de Producción, Vacaciones y Comisiones.
        </p>
    </div>
    """, unsafe_allow_html=True)
    
    # === PESTAÑAS ===
    tab_calendario, tab_nuevo = st.tabs(["🗓️ Calendario Visual", "➕ Registrar Evento / Actividad"])
    
    # ----------------------------------------------------
    # TAB 1: CALENDARIO FULLCALENDAR
    # ----------------------------------------------------
    with tab_calendario:
        st.write("Cargando calendario interactivo...")
        # HTML/JS para inyectar FullCalendar
        # Mapeamos los campos para que 'title' y 'start'/'end' los lea FullCalendar correctamente
        
        # Endpoint para traer datos: /api/agenda/eventos
        # FullCalendar puede recibir un JSON array directamente del endpoint
        # Pero vamos a hacerle un format map en javascript por si las variables difieren
        
        html_code = f"""
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset='utf-8' />
          <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.js'></script>
          <style>
            body {{
              margin: 0;
              padding: 0;
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
              font-size: 14px;
            }}
            #calendar {{
              max-width: 100%;
              margin: 20px auto;
              background-color: #ffffff;
              padding: 15px;
              border-radius: 10px;
              box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            }}
            .fc-event {{
              cursor: pointer;
              border-radius: 4px;
              padding: 2px;
              color: white !important;
              font-weight: 600;
              border: none;
            }}
            .fc-toolbar-title {{
              font-size: 1.5em !important;
              color: #1e293b;
              font-weight: bold;
              text-transform: capitalize;
            }}
            .fc-button-primary {{
              background-color: #1e293b !important;
              border-color: #1e293b !important;
            }}
            .fc-button-primary:hover {{
              background-color: #334155 !important;
            }}
          </style>
          <script>
            document.addEventListener('DOMContentLoaded', function() {{
              var calendarEl = document.getElementById('calendar');
              
              var calendar = new FullCalendar.Calendar(calendarEl, {{
                initialView: 'dayGridMonth',
                locale: 'es',
                headerToolbar: {{
                  left: 'prev,next today',
                  center: 'title',
                  right: 'dayGridMonth,timeGridWeek,listMonth'
                }},
                buttonText: {{
                  today: 'Hoy',
                  month: 'Mes',
                  week: 'Semana',
                  list: 'Lista'
                }},
                firstDay: 1, // Lunes
                height: 750,
                eventSources: [
                  {{
                    url: '{API_URL}/api/agenda/eventos',
                    method: 'GET',
                    failure: function() {{
                      alert('Error al cargar los eventos desde el servidor.');
                    }},
                    success: function(content, response) {{
                      // Mapeamos los datos de la base de datos a lo que FullCalendar entiende
                      return content.map(function(evento) {{
                        return {{
                          id: evento.id,
                          title: evento.titulo,
                          start: evento.fecha_inicio,
                          end: evento.fecha_fin,
                          allDay: evento.todo_el_dia,
                          backgroundColor: evento.color_fondo || '#3788d8',
                          extendedProps: {{
                            tipo_evento: evento.tipo_evento,
                            locacion: evento.locacion,
                            recursos: evento.recursos_tecnicos,
                            personal: evento.personal_asignado,
                            notas: evento.notas_adicionales
                          }}
                        }};
                      }});
                    }}
                  }}
                ],
                eventClick: function(info) {{
                    var ev = info.event;
                    var detalles = "📌 " + ev.title + "\\n\\n" +
                                   "📍 Locación: " + (ev.extendedProps.locacion || 'N/A') + "\\n" +
                                   "👥 Personal: " + (ev.extendedProps.personal || 'N/A') + "\\n" +
                                   "🎥 Equipo: " + (ev.extendedProps.recursos || 'N/A') + "\\n\\n" +
                                   "📝 Notas: " + (ev.extendedProps.notas || 'N/A');
                    alert(detalles);
                }}
              }});
              
              calendar.render();
            }});
          </script>
        </head>
        <body>
          <div id='calendar'></div>
        </body>
        </html>
        """
        
        components.html(html_code, height=800, scrolling=True)

    # ----------------------------------------------------
    # TAB 2: FORMULARIO DE REGISTRO
    # ----------------------------------------------------
    with tab_nuevo:
        st.markdown("### Crear Nuevo Registro en la Agenda")
        with st.form("form_nueva_agenda"):
            col1, col2 = st.columns(2)
            
            with col1:
                titulo = st.text_input("Título / Descripción corta (Ej. GIRA GUASAVE)", max_chars=100)
                tipo_evento = st.selectbox("Clasificación", ["Producción", "Gira", "Vacaciones", "Inhábil", "Administrativo"])
                
                c_f1, c_f2 = st.columns(2)
                f_inicio = c_f1.date_input("Fecha Inicio", format="DD/MM/YYYY")
                h_inicio = c_f2.time_input("Hora de Inicio", datetime.time(8, 0))
                
                todo_el_dia = st.checkbox("Evento de todo el día (Ej. Vacaciones / Descanso)", value=False)
            
            with col2:
                # Paleta de colores similar a la que usa en el Excel
                colores_dict = {
                    "Producción (Azul)": "#60a5fa",
                    "Gira / Evento (Rojo)": "#dc2626",
                    "Inhábil / Descanso (Naranja)": "#f97316",
                    "Vacaciones (Rosa/Beige)": "#fed7aa",
                    "Gabinete / Otro (Gris)": "#94a3b8"
                }
                color_select = st.selectbox("Color en el Calendario", list(colores_dict.keys()))
                color_hex = colores_dict[color_select]
                
                locacion = st.text_input("Locación", placeholder="Ej. Teatro Mía, Estudio TV...")
                
                c_f3, c_f4 = st.columns(2)
                f_fin = c_f3.date_input("Fecha Fin", format="DD/MM/YYYY")
                h_fin = c_f4.time_input("Hora de Fin", datetime.time(14, 0))
                
            st.divider()
            st.markdown("#### Detalles de Producción")
            col_d1, col_d2 = st.columns(2)
            
            with col_d1:
                recursos = st.text_area("Equipo Técnico / KUWA", placeholder="Ej. 1 Monitor de 55, 1 switcher, 1 antena starlink...", height=100)
                notas = st.text_area("Notas Adicionales", placeholder="Ej. El internet lo proporcionarán ellos.", height=100)
            
            with col_d2:
                personal = st.text_area("Personal Asignado", placeholder="Ej. Daniel, Carlos, Edgar, Manuel...", height=100)
                
            submit_form = st.form_submit_button("✅ Guardar en Calendario", type="primary", use_container_width=True)
            
            if submit_form:
                if not titulo:
                    st.error("El título es obligatorio.")
                else:
                    dt_inicio = datetime.datetime.combine(f_inicio, h_inicio).isoformat()
                    dt_fin = datetime.datetime.combine(f_fin, h_fin).isoformat()
                    
                    payload = {
                        "titulo": titulo.upper(),
                        "fecha_inicio": dt_inicio,
                        "fecha_fin": dt_fin,
                        "todo_el_dia": todo_el_dia,
                        "tipo_evento": tipo_evento.upper(),
                        "color_fondo": color_hex,
                        "locacion": locacion.upper(),
                        "recursos_tecnicos": recursos,
                        "personal_asignado": personal,
                        "notas_adicionales": notas,
                        "creado_por": st.session_state.get("usuario_actual", "Desconocido")
                    }
                    
                    try:
                        res = requests.post(f"{API_URL}/api/agenda/eventos", json=payload, verify=False, timeout=5)
                        if res.status_code == 200:
                            st.success("✅ Evento creado exitosamente en la Agenda.")
                            st.info("🔄 Se actualizará el calendario (si no ves el cambio, entra y sal del módulo).")
                        else:
                            st.error(f"Error del servidor: {res.text}")
                    except Exception as e:
                        st.error(f"Error de conexión con el backend: {e}")

