import streamlit as st
import requests
import datetime
import time
from modulos_prueba.utils_frontend import parsed_array
from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus

def renderizar_modulo(API_URL: str):
    # 👤 Extraemos variables de sesión vitales
    nombre_usuario = st.session_state.get("usuario_actual", "Desconocido")
    rol = st.session_state.get("rol", "")
    usuario_real = str(nombre_usuario).strip()
    
    es_cuauhtemoc = "Cuauhtémoc Rivera" in usuario_real or "Cuauhtemoc Rivera" in usuario_real
    es_villarreal = "VILLARREAL" in usuario_real.upper() or "ANA LILIA" in usuario_real.upper()
    es_admin_coordinador = rol in ['ADMIN', 'COORDINADOR'] or es_cuauhtemoc
    
    tiene_acceso_boveda = rol in ['ADMIN', 'COORDINADOR', 'PRODUCTOR'] or es_villarreal or es_cuauhtemoc    # 🔒 REGLA DE NEGOCIO: ¿Quién puede ver la Bóveda Histórica?

    st.markdown(f"""
    <div style="background-color: #1e293b; padding: 20px; border-radius: 15px; border-left: 10px solid #deff9a; margin-bottom: 25px;">
        <h2 style="margin: 0; color: #f8fafc;">👋 ¡Hola, {nombre_usuario}!</h2>
        <p style="margin: 0; color: #deff9a; font-weight: bold;">Panel Operativo Maestro: Orden de Producción VPRO</p>
    </div>
    """, unsafe_allow_html=True)
    
    with st.expander("❓ Ayuda Contextual: ¿Cómo funciona la Orden de Producción?"):
        st.markdown("""
        ### 🎬 FASE 1: Planeación y Nacimiento del Proyecto
        **Actor responsable:** Administración, Coordinación o Ventas.  
        **Objetivo:** Crear el evento y definir a los responsables.

        *   📝 **Captura de Datos Base:** Se llenan los datos vitales: Cliente, Nombre, Locación y Fechas.
        *   👤 **El Nombramiento del Productor:** Se asigna obligatoriamente un Productor Responsable.
        *   🗂️ **Cierre de Ciclo Automático:** Cuando el evento finaliza y Ana Lilia aprueba los gastos en Auditoría, la OP pasa a la Bóveda Histórica de solo lectura.
        """)
    
    if 'op_data' not in st.session_state: st.session_state.op_data = {}
    d = st.session_state.op_data
    
    lista_proveedores, lista_autos, lista_clientes = [], [], ["->"] # 🗄️ Carga de Catálogos desde la API
    folios_existentes_activos = ["🆕 CREAR NUEVA ORDEN"]
    folios_historicos = []
    staff_vpro, apoyos_proveedor = [], []
    proximo_id = 1
    
    try:
        res_cat = requests.get(f"{API_URL}/api/eventos/catalogos", verify=False)
        if res_cat.status_code == 200:
            cats = res_cat.json()
            lista_autos = cats.get("autos", [])
            lista_clientes += cats.get("clientes", [])
            lista_proveedores = cats.get("proveedores", [])
            staff_vpro = cats.get("staff_vpro", [])
            apoyos_proveedor = cats.get("apoyos_externos", [])
            
        res_fol = requests.get(f"{API_URL}/api/eventos/folios", verify=False, timeout=5)
        if res_fol.status_code == 200:
            fols_data = res_fol.json()
            folios_existentes_activos += fols_data.get("folios", [])
            folios_historicos = fols_data.get("folios_historicos", [])
            proximo_id = fols_data.get("proximo_id", 1)
    except Exception as e: 
        st.error(f"📡 Error de red: {e}")

    if tiene_acceso_boveda: # ✨ RENDERIZADO DINÁMICO DE PESTAÑAS
        tabs = st.tabs(["📝 Panel de OPs Activas", "📦 Bóveda de Archivo Histórico"])
        tab_activas = tabs[0]
        tab_historico = tabs[1]
    else:
        tabs = st.tabs(["📝 Panel de OPs Activas"])
        tab_activas = tabs[0]
        tab_historico = None

    with tab_activas:
        st.write("### 📂 Gestión de Folios Activos")    # 📂 GESTIÓN DE FOLIOS ACTIVOS
        with st.container(border=True):
            c_sel, c_empty = st.columns([2, 3])
            sel = c_sel.selectbox("🔍 BUSCAR O SELECCIONAR FOLIO:", options=folios_existentes_activos, index=0, key="sel_activos")
            folio_extraido = sel.split(" - ")[0] if sel != "🆕 CREAR NUEVA ORDEN" else None
            
            if folio_extraido and str(d.get('folio')) != str(folio_extraido):
                res_buscar = requests.get(f"{API_URL}/api/eventos/buscar/{folio_extraido}", verify=False)
                if res_buscar.status_code == 200:
                    st.session_state.op_data = res_buscar.json()
                    st.rerun()
            elif not folio_extraido and d.get('id_evento'): 
                st.session_state.op_data = {}
                st.rerun()

        id_actual = d.get('id_evento', proximo_id)
        val_folio_mostrar = str(d.get('folio')) if d.get('folio') else str(id_actual)
        estatus_db = str(d.get('estatus', 'ACTIVA')).strip().upper()

        if estatus_db == 'CERRADA (HISTÓRICO)':
            st.warning("⚠️ ESTA ORDEN HA SIDO SELLADA POR DIRECCIÓN. VE A LA PESTAÑA 'BÓVEDA DE ARCHIVO HISTÓRICO' PARA VERLA.")
        else:
            st.write("### 📝 Datos de la Orden")
            with st.container(border=True):
                c1, c2, c3 = st.columns([1, 2, 4])
                fol_in = c1.text_input("🔢 FOLIO VPRO:", value=val_folio_mostrar, disabled=True, key=f"folio_vpro_{id_actual}")
                
                idx_cli = lista_clientes.index(d.get('para_q_cliente')) if d.get('para_q_cliente') in lista_clientes else 0
                cli_op = c2.selectbox("👤 CLIENTE:", options=lista_clientes, index=idx_cli, key=f"cli_{id_actual}")
                
                eve_op = c3.text_input("🎉 EVENTO:", value=d.get('nombre_evento', ""), key=f"eve_{id_actual}")
                
                c4, c5, c6 = st.columns([2, 1.5, 1.5])
                loc_op = c4.text_input("📍 LOCACIÓN (Lugar):", value=d.get('locacion', ""), key=f"loc_{id_actual}")
                
                val_f_inst = datetime.date.fromisoformat(d.get('fec_de_instalacion')) if d.get('fec_de_instalacion') else datetime.date.today()
                f_inst = c5.date_input("📅 FECHA INSTALACIÓN:", value=val_f_inst, key=f"finst_{id_actual}")
                
                val_h_inst = datetime.time.fromisoformat(d.get('hra_de_instalacion')) if d.get('hra_de_instalacion') else datetime.time(9, 0)
                h_inst = c6.time_input("⏰ HORA INSTALACIÓN:", value=val_h_inst, key=f"hinst_{id_actual}")
                
                c7, c8, c9, c10, c11 = st.columns([1.5, 1.5, 1, 1, 1])
                sol_op = c7.text_input("📣 SOLICITA:", value=d.get('quien_solicita', ""), key=f"sol_{id_actual}")
                
                idx_prd = (staff_vpro.index(d.get('resp_de_produccion'))+1) if d.get('resp_de_produccion') in staff_vpro else 0
                prd_op = c8.selectbox("🎬 PRODUCTOR RESP.:", options=["---"] + staff_vpro, index=idx_prd, key=f"prd_{id_actual}")
                
                val_f_even = datetime.date.fromisoformat(d.get('fec_del_evento')) if d.get('fec_del_evento') else datetime.date.today()
                f_even = c9.date_input("📅 FECHA EVENTO:", value=val_f_even, key=f"feve_{id_actual}")
                
                val_h_inic = datetime.time.fromisoformat(d.get('inicio_del_evento')) if d.get('inicio_del_evento') else datetime.time(11, 0)
                h_inic = c10.time_input("🚀 H. INICIO:", value=val_h_inic, key=f"hinic_{id_actual}")
                
                val_h_llam = datetime.time.fromisoformat(d.get('hra_de_llamado')) if d.get('hra_de_llamado') else datetime.time(6, 0)
                h_llam = c11.time_input("📞 H. LLAMADO:", value=val_h_llam, key=f"hllam_{id_actual}")
                
                ubi_op = st.text_input("🗺️ UBICACIÓN EXACTA:", value=d.get('ubicacion', ""), key=f"ubi_{id_actual}")
                
                # ==============================================================
                # 🤝 SECCIÓN NUEVA: MULTISELECT DE REUNIONES
                # ==============================================================
                lista_reuniones = []
                try:
                    res_reu = requests.get(f"{API_URL}/api/reuniones/catalogo", verify=False, timeout=2)
                    if res_reu.status_code == 200:
                        lista_reuniones = res_reu.json()
                except Exception as e:
                    print(f"⚠️ SILENCED ERROR in mod_eventos.py: {e}")
                
                # Cargamos las reuniones que ya se habían guardado antes en esta OP
                reuniones_guardadas = parsed_array(d.get('reuniones_vinculadas'))
                for r in reuniones_guardadas:
                    if r and r not in lista_reuniones:
                        lista_reuniones.append(r)
                reuniones_bd = [r for r in reuniones_guardadas if r in lista_reuniones]
                
                reuniones_sel = st.multiselect(
                    "🤝 VINCULAR REUNIÓN(ES):", 
                    options=lista_reuniones, 
                    default=reuniones_bd, 
                    key=f"reuniones_{id_actual}", 
                    placeholder="Despliega y selecciona una o varias reuniones..."
                )
                
                # Vista previa rápida de minutas vinculadas si existen
                if reuniones_sel and d.get('detalle_reuniones'):
                    with st.expander(f"📋 Minutas Vinculadas a esta OP ({len(reuniones_sel)})", expanded=False):
                        for dr in d.get('detalle_reuniones', []):
                            st.markdown(f"**📌 {dr.get('nombre_proyecto_tentativo', 'Reunión')}** ({dr.get('fecha_reunion', 'S/F')})")
                            if dr.get('asistentes'):
                                st.caption(f"👥 **Asistentes:** {dr.get('asistentes')}")
                            if dr.get('minuta_acuerdos'):
                                st.info(dr.get('minuta_acuerdos'))
                # ==============================================================

                serv_op = st.text_area("🛠️ TIPO DE SERVICIO:", value=d.get('tipo_de_servicio', ""), height=65, key=f"serv_{id_actual}")
                
            st.divider() # 👥 ASIGNACIÓN DE EQUIPO
            st.write("### 👥 Asignación de Equipo y Logística")
            with st.container(border=True):
                col_iz, col_de = st.columns(2)
                
                lista_personal_bd = [p for p in parsed_array(d.get('personal_convocado_op')) if p in staff_vpro]
                lista_externos_bd = [p for p in parsed_array(d.get('externos_op')) if p in apoyos_proveedor]
                lista_provs_bd = [p for p in parsed_array(d.get('proveedor_op')) if p in lista_proveedores]
                
                autos_guardados = parsed_array(d.get('carros_usados_op'))
                lista_autos_bd = []
                for guardado in autos_guardados:
                    for opcion in lista_autos:
                        if str(guardado).strip().lower() in str(opcion).lower():
                            if opcion not in lista_autos_bd: lista_autos_bd.append(opcion)
                            break
                        
                with col_iz:
                    pers_sel = st.multiselect("SELECCIONAR PERSONAL VPRO:", options=staff_vpro, default=lista_personal_bd, key=f"pers_{id_actual}")
                    proveed_sel = st.multiselect("SELECCIONAR PERSONAL EXTERNO:", options=apoyos_proveedor, default=lista_externos_bd, key=f"ext_{id_actual}")
                with col_de:
                    cars = st.multiselect("VEHÍCULOS:", options=lista_autos, default=lista_autos_bd, key=f"cars_{id_actual}")
                    prov = st.multiselect("PROVEEDORES CO-CONVOCADOS:", options=lista_proveedores, default=lista_provs_bd, key=f"provs_{id_actual}")
                    
                st.write("")
                
                ins_p = st.text_area("📦 PRODUCCIÓN:(LEER las INSTRUCCIONES y SI HAY DUDAS PREGUNTAR a su jefe inmediato)", value=d.get('produccion', ""), height=200, key=f"prod_{id_actual}")
                ins_s = st.text_area("💻 SISTEMAS / REDES:", value=d.get('internet_redes', ""), height=200, key=f"redes_{id_actual}")
                ins_v = st.text_area("🏗️ ACTIVIDADES PROVEEDORES:", value=d.get('actividades_de_proveedores', ""), height=200, key=f"act_prov_{id_actual}")
                nota = st.text_area("📝 NOTAS ADICIONALES:", value=d.get('nota', ""), height=140, key=f"nota_{id_actual}")
                
            es_productor_asignado = str(d.get('resp_de_produccion', '')).strip().upper() == str(nombre_usuario).strip().upper() # ✈️ BITÁCORA DE GIRA (REEMPLAZA A LA VIEJA CLAQUETA)
            
            if d.get('id_evento') and (es_admin_coordinador or es_productor_asignado):  # 🔒 Solo el Admin, Coordinador o el Productor de la OP pueden ver esto
                st.write("---")
                st.markdown("### ✈️ Logística de Viajes y Bitácora de Horas")

                # Consultamos si ya existen jornadas guardadas para mantener el toggle encendido
                historial_jornadas = []
                try:
                    res_hist = requests.get(f"{API_URL}/api/asistencia/locacion/{id_actual}", verify=False, timeout=5)
                    if res_hist.status_code == 200:
                        historial_jornadas = res_hist.json()
                except Exception as e:
                    print(f"⚠️ SILENCED ERROR in mod_eventos.py: {e}")

                llave_toggle_gira = f"tgl_gira_{id_actual}"
                if llave_toggle_gira not in st.session_state and len(historial_jornadas) > 0:
                    st.session_state[llave_toggle_gira] = True
                
                activar_gira = st.toggle("💼 SI EL EVENTO ES FUERA DE LA CIUDAD ... ACTIVE ESTA BITÁCORA", key=llave_toggle_gira) # El Switch Principal
                
                if activar_gira:
                    if not pers_sel:
                        st.error("⚠️ Atención: Debes seleccionar personal en 'SELECCIONAR PERSONAL VPRO' arriba para poder tomar asistencia.")
                    else:
                        with st.container(border=True):
                            st.info(f"👥 **Crew activo en esta locación:** {', '.join(pers_sel)}")

                            jornadas_por_fecha = {} # Agrupar registros por fecha para pintarlos ordenados
                            for reg in historial_jornadas:
                                f = reg['fecha_jornada']
                                if f not in jornadas_por_fecha: jornadas_por_fecha[f] = []
                                jornadas_por_fecha[f].append(reg)
                            
                            fechas_registradas = sorted(list(jornadas_por_fecha.keys()))
                            
                            import pandas as pd # 2. 🔒 Renderizar Días Anteriores (Modo Solo Lectura / Modo Edición en sitio)
                            for fecha_str in fechas_registradas:
                                df_jornada = pd.DataFrame(jornadas_por_fecha[fecha_str])
                                df_mostrar = df_jornada[['nombre_empleado', 'hora_entrada', 't_desayuno', 't_comida', 't_cena', 'hora_salida', 'observaciones']]
                                df_mostrar.columns = ['Empleado', 'Entrada', 'Hrs Desayuno', 'Hrs Comida', 'Hrs Cena', 'Salida', 'Notas']

                                llave_edicion = f"modo_edicion_{fecha_str}_{id_actual}" # Llave de memoria para saber si esta tabla específica está abierta
                                if llave_edicion not in st.session_state:
                                    st.session_state[llave_edicion] = False

                                with st.expander(f"🔒 Jornada Registrada: {fecha_str}", expanded=st.session_state[llave_edicion]):
                                    
                                    if not st.session_state[llave_edicion]: # MODO LECTURA: Mostrar la tabla bloqueada y el botón de abrir
                                        st.dataframe(df_mostrar, use_container_width=True, hide_index=True)
                                        if st.button(f"🔓 Habilitar Edición para {fecha_str}", key=f"btn_abrir_{fecha_str}_{id_actual}"):
                                            st.session_state[llave_edicion] = True
                                            st.rerun()

                                    else:   # MODO EDICIÓN: Mostrar tabla editable y el botón de guardar
                                        st.warning("✏️ Estás editando esta jornada. Solo puedes modificar horas, alimentos y notas del personal convocado.")
                                        
                                        # 🔒 CANDADO: Columna Empleado bloqueada, filas fijas sin inserción libre
                                        df_editado = st.data_editor(
                                            df_mostrar, 
                                            use_container_width=True, 
                                            hide_index=True, 
                                            num_rows="fixed",
                                            disabled=["Empleado"],
                                            column_config={
                                                "Empleado": st.column_config.TextColumn("Empleado (Convocado)", disabled=True),
                                                "Entrada": st.column_config.TextColumn("Entrada"),
                                                "Hrs Desayuno": st.column_config.NumberColumn("Hrs Desayuno", min_value=0.0, max_value=24.0, step=0.5),
                                                "Hrs Comida": st.column_config.NumberColumn("Hrs Comida", min_value=0.0, max_value=24.0, step=0.5),
                                                "Hrs Cena": st.column_config.NumberColumn("Hrs Cena", min_value=0.0, max_value=24.0, step=0.5),
                                                "Salida": st.column_config.TextColumn("Salida"),
                                                "Notas": st.column_config.TextColumn("Notas")
                                            },
                                            key=f"editor_{fecha_str}_{id_actual}"
                                        )

                                        c_btn1, c_btn2 = st.columns(2)
                                        if c_btn1.button("💾 Guardar Correcciones", type="primary", use_container_width=True, key=f"btn_guardar_{fecha_str}_{id_actual}"):
                                            
                                            # Validación previa: nadie fuera de pers_sel
                                            pers_convocados_set = {str(p).strip().upper() for p in pers_sel}
                                            empleados_en_tabla = [str(r['Empleado']).strip() for _, r in df_editado.iterrows()]
                                            no_convocados = [e for e in empleados_en_tabla if e.upper() not in pers_convocados_set]
                                            
                                            if no_convocados:
                                                st.error(f"⛔ Candado de Seguridad: El personal '{', '.join(no_convocados)}' no está convocado en esta OP. No se puede guardar.")
                                                st.stop()

                                            def arreglar_hora(val): # 🧹 TRADUCTOR AUTOMÁTICO DE HORAS (Arregla los puntos y vacíos)
                                                v_str = str(val).strip().replace(".", ":") # Cambiamos errores de punto por dos puntos
                                                if v_str.lower() in ["none", "nan", "null", ""]: return "00:00:00"
                                                if len(v_str) == 5: return v_str + ":00" # 09:30 -> 09:30:00
                                                return v_str

                                            registros_modificados = []  # Armamos el payload con los datos modificados
                                            for idx, row in df_editado.iterrows():
                                                registros_modificados.append({
                                                    "fecha_jornada": str(fecha_str),
                                                    "num_empleado": 0, 
                                                    "nombre_empleado": str(row['Empleado']).strip(),
                                                    "depto": "STAFF VPRO",
                                                    "hora_entrada": arreglar_hora(row['Entrada']),
                                                    "t_desayuno": float(row['Hrs Desayuno']) if pd.notna(row['Hrs Desayuno']) else 0.0,
                                                    "t_comida": float(row['Hrs Comida']) if pd.notna(row['Hrs Comida']) else 0.0,
                                                    "t_cena": float(row['Hrs Cena']) if pd.notna(row['Hrs Cena']) else 0.0,
                                                    "hora_salida": arreglar_hora(row['Salida']),
                                                    "observaciones": str(row['Notas']).strip() if pd.notna(row['Notas']) else ""
                                                })

                                            try:
                                                res_post = requests.post(f"{API_URL}/api/asistencia/locacion/{id_actual}", json={"registros": registros_modificados}, verify=False)
                                                if res_post.status_code == 200:
                                                    st.session_state[llave_edicion] = False
                                                    st.success("✅ Cambios guardados con éxito.")
                                                    time.sleep(1)
                                                    st.rerun()
                                                else:
                                                    st.error(f"❌ Error al guardar en la BD: {res_post.text}")
                                            except Exception as e:
                                                st.error(f"📡 Error de red: {e}")

                                                
                                        if c_btn2.button("❌ Cancelar", use_container_width=True, key=f"btn_cancelar_{fecha_str}_{id_actual}"):
                                            st.session_state[llave_edicion] = False
                                            st.rerun()
                            
                            st.write("---") # ➕ AGREGAR NUEVO DÍA AL DIARIO DE GIRA
                            st.markdown("#### 📅 Agregar Nuevo Día a la Bitácora")
                            st.caption("Selecciona el día de la gira que deseas registrar. Se creará una plantilla vacía para todo el Crew activo.")
                
                            col_fecha, col_btn_nuevo = st.columns([1, 2])
                            with col_fecha:
                                nueva_fecha = st.date_input("Selecciona la fecha:", value=datetime.date.today(), key=f"nueva_fecha_{id_actual}")
                
                            with col_btn_nuevo:
                                st.write("##") # Espaciador para alinear con el calendario
                                if st.button("➕ Crear Bitácora para esta fecha", type="primary", use_container_width=True, key=f"btn_nuevo_dia_{id_actual}"):
                                    if str(nueva_fecha) in fechas_registradas:
                                        st.warning(f"⚠️ Ya existe una bitácora abierta para el día {nueva_fecha}.")
                                    else:
                                        registros_nuevos = []
                                        for persona in pers_sel:
                                            registros_nuevos.append({
                                                "fecha_jornada": str(nueva_fecha),
                                                "num_empleado": 0, 
                                                "nombre_empleado": str(persona).strip(),
                                                "depto": "STAFF VPRO",
                                                "hora_entrada": "00:00:00",
                                                "t_desayuno": 0.0,
                                                "t_comida": 0.0,
                                                "t_cena": 0.0,
                                                "hora_salida": "00:00:00",
                                                "observaciones": ""
                                            })
                                        
                                        with st.spinner("Creando nuevo día en el diario de gira..."):   # 3. Lo inyectamos silenciosamente en la Base de Datos
                                            try:
                                                res_crear = requests.post(f"{API_URL}/api/asistencia/locacion/{id_actual}", json={"registros": registros_nuevos}, verify=False)
                                                if res_crear.status_code == 200:
                                                    st.success(f"✅ ¡Día {nueva_fecha} agregado! Ya puedes abrirlo arriba para asignarle las horas.")
                                                    time.sleep(1.5)
                                                    st.rerun()
                                                else:
                                                    st.error("❌ Error del servidor al intentar crear la nueva jornada.")
                                            except Exception as e:
                                                st.error(f"📡 Error de comunicación con la base de datos: {e}")
            
            st.write("### 🖋️ Autorizaciones")   # 🖋️ AUTORIZACIONES
            with st.container(border=True):
                f_a1, f_a2, f_a3, f_a4 = st.columns(4)
                def_elab = d.get('elabora') if d.get('elabora') else "Ana Lilia Villarreal Uribe"
                def_coor = d.get('coordina') if d.get('coordina') else "Manuel Eduardo Madrid"
                def_organ = d.get('organiza') if d.get('organiza') else "Martin Eduardo Sanchez Estrada"
                def_vobo = d.get('vobo') if d.get('vobo') else "Gerardo Villarreal Uribe"
                
                idx_e = (staff_vpro.index(def_elab) + 1) if def_elab in staff_vpro else 0
                idx_c = (staff_vpro.index(def_coor) + 1) if def_coor in staff_vpro else 0
                idx_o = (staff_vpro.index(def_organ) + 1) if def_organ in staff_vpro else 0
                idx_v = (staff_vpro.index(def_vobo) + 1) if def_vobo in staff_vpro else 0
                
                elab = f_a1.selectbox("📝 Elaboró:", ["---"] + staff_vpro, index=idx_e, key=f"elab_{id_actual}")
                coor = f_a2.selectbox("🔀 Coordina:", ["---"] + staff_vpro, index=idx_c, key=f"coor_{id_actual}")
                organ = f_a3.selectbox("🏢 Organiza:", ["---"] + staff_vpro, index=idx_o, key=f"org_{id_actual}")
                vobo = f_a4.selectbox("✅ Vo.Bo.:", ["---"] + staff_vpro, index=idx_v, key=f"vobo_{id_actual}")
            
            st.divider()
            creador_original = d.get('empleado_que_creo_la_op', nombre_usuario)
            
            if st.button("💾 GUARDAR CAMBIOS ORDEN", use_container_width=True, type="primary", key=f"save_{id_actual}"):    # 💾 BOTÓN GUARDAR MAESTRO
                es_autorizado = es_admin_coordinador
                es_el_dueno = (creador_original == nombre_usuario)
                
                if not es_autorizado and not es_el_dueno: 
                    st.error(f"🚫 Acceso Denegado. Solo un Coordinador o el creador ({creador_original}) pueden modificar esta OP.")
                else:
                    payload_op = {
                        "id_evento": int(id_actual), 
                        "folio": str(val_folio_mostrar).strip(), 
                        "para_q_cliente": str(cli_op),
                        "nombre_evento": str(eve_op).strip(), 
                        "locacion": str(loc_op).strip(),
                        "fec_de_instalacion": str(f_inst), 
                        "hra_de_instalacion": str(h_inst), 
                        "quien_solicita": str(sol_op).strip(),
                        "resp_de_produccion": str(prd_op), 
                        "fec_del_evento": str(f_even), 
                        "inicio_del_evento": str(h_inic),
                        "hra_de_llamado": str(h_llam), 
                        "ubicacion": str(ubi_op).strip(), 
                        "reuniones_vinculadas": list(reuniones_sel), # 🔥 AQUÍ SE INYECTAN LAS REUNIONES EN EL PAYLOAD
                        "tipo_de_servicio": str(serv_op).strip(),
                        "produccion": str(ins_p).strip(), 
                        "internet_redes": str(ins_s).strip(), 
                        "actividades_de_proveedores": str(ins_v).strip(),
                        "nota": str(nota).strip(), 
                        "elabora": str(elab), 
                        "organiza": str(organ), 
                        "coordina": str(coor), 
                        "vobo": str(vobo), 
                        "proveedor_op": list(prov), 
                        "personal_convocado_op": list(pers_sel), 
                        "carros_usados_op": list(cars), 
                        "externos_op": list(proveed_sel),
                        "empleado_que_creo_la_op": str(creador_original)
                    }
                    
                    with st.spinner("Sincronizando orden con la base de datos..."):
                        try:
                            response = requests.post(f"{API_URL}/api/eventos/guardar", json=payload_op, verify=False)
                            if response.status_code == 200:
                                if 'op_data' in st.session_state: del st.session_state['op_data']
                                st.toast("✅ ¡Orden de Producción guardada con éxito!", icon="💾")
                                time.sleep(1.2)
                                st.rerun()
                            else:
                                try: error_detail = response.json().get('detail', response.text)
                                except: error_detail = response.text
                                st.error(f"❌ Error al guardar (Código {response.status_code}):\n\n`{error_detail}`")
                        except Exception as e:
                            st.error(f"📡 Fallo de comunicación con el Cerebro API: {e}")

    if tab_historico is not None:   # 📦 PESTAÑA: BÓVEDA HISTÓRICA (SOLO LECTURA)
        with tab_historico:
            st.info("💡 En esta bóveda solo aparecen las OPs que han sido selladas financieramente. La información aquí es de **Solo Lectura**.")
            
            with st.container(border=True):
                c_sel_h, c_empty_h = st.columns([2, 3])
                
                if not folios_historicos:
                    st.success("🎉 Bóveda vacía. Aún no hay órdenes cerradas ni selladas por Dirección.")
                else:
                    sel_h = c_sel_h.selectbox("📦 BUSCAR OP ARCHIVADA:", options=folios_historicos, index=0, key="sel_historico")
                    
                    if sel_h:
                        folio_h = sel_h.split(" - ")[0]
                        
                        if st.button("🔍 ABRIR EXPEDIENTE HISTÓRICO", type="secondary", use_container_width=True):
                            res_buscar_h = requests.get(f"{API_URL}/api/eventos/buscar/{folio_h}", verify=False)
                            if res_buscar_h.status_code == 200:
                                data_h = res_buscar_h.json()
                                
                                st.divider()
                                st.markdown(f"### 📦 EXPEDIENTE OP-{data_h.get('folio', '')}: {data_h.get('nombre_evento', '')}")
                                
                                with st.container(border=True): # 1. 📝 DATOS DE LA ORDEN (Solo Lectura)
                                    c1, c2, c3 = st.columns([1, 2, 4])
                                    c1.text_input("🔢 FOLIO VPRO:", value=str(data_h.get('folio', '')), disabled=True, key=f"h_fol_{folio_h}")
                                    c2.text_input("👤 CLIENTE:", value=data_h.get('para_q_cliente', ''), disabled=True, key=f"h_cli_{folio_h}")
                                    c3.text_input("🎉 EVENTO:", value=data_h.get('nombre_evento', ''), disabled=True, key=f"h_eve_{folio_h}")
                                    
                                    c4, c5, c6 = st.columns([2, 1.5, 1.5])
                                    c4.text_input("📍 LOCACIÓN (Lugar):", value=data_h.get('locacion', ''), disabled=True, key=f"h_loc_{folio_h}")
                                    c5.text_input("📅 FECHA INSTALACIÓN:", value=str(data_h.get('fec_de_instalacion', '')), disabled=True, key=f"h_finst_{folio_h}")
                                    c6.text_input("⏰ HORA INSTALACIÓN:", value=str(data_h.get('hra_de_instalacion', '')), disabled=True, key=f"h_hinst_{folio_h}")
                                    
                                    c7, c8, c9, c10, c11 = st.columns([1.5, 1.5, 1, 1, 1])
                                    c7.text_input("📣 SOLICITA:", value=data_h.get('quien_solicita', ''), disabled=True, key=f"h_sol_{folio_h}")
                                    c8.text_input("🎬 PRODUCTOR RESP.:", value=data_h.get('resp_de_produccion', ''), disabled=True, key=f"h_prd_{folio_h}")
                                    c9.text_input("📅 FECHA EVENTO:", value=str(data_h.get('fec_del_evento', '')), disabled=True, key=f"h_feve_{folio_h}")
                                    c10.text_input("🚀 H. INICIO:", value=str(data_h.get('inicio_del_evento', '')), disabled=True, key=f"h_hini_{folio_h}")
                                    c11.text_input("📞 H. LLAMADO:", value=str(data_h.get('hra_de_llamado', '')), disabled=True, key=f"h_hllam_{folio_h}")
                                    
                                    st.text_input("🗺️ UBICACIÓN EXACTA:", value=data_h.get('ubicacion', ''), disabled=True, key=f"h_ubi_{folio_h}")
                                    # 🔥 EXPEDIENTE HISTÓRICO: MINUTAS DE REUNIONES PREVIAS VINCULADAS
                                    detalles_reu_h = data_h.get('detalle_reuniones', [])
                                    reus_raw_h = parsed_array(data_h.get('reuniones_vinculadas'))
                                    
                                    if detalles_reu_h:
                                        st.markdown(f"#### 🤝 Minutas de Reuniones Previas Vinculadas ({len(detalles_reu_h)})")
                                        for idx_r, r_det in enumerate(detalles_reu_h, 1):
                                            tit_r = r_det.get('nombre_proyecto_tentativo') or f"Reunión #{idx_r}"
                                            f_r = r_det.get('fecha_reunion') or "S/F"
                                            cli_r = r_det.get('cliente_tentativo') or data_h.get('para_q_cliente', '')
                                            with st.expander(f"📌 {idx_r}. {tit_r} — 📅 {f_r} | 🏢 {cli_r}", expanded=(idx_r == 1)):
                                                cr1, cr2 = st.columns([2, 1])
                                                cr1.markdown(f"**👥 Asistentes:** {r_det.get('asistentes', 'No especificados')}")
                                                presup = r_det.get('presupuesto_estimado', 0.0)
                                                if presup:
                                                    cr2.markdown(f"**💰 Presupuesto Estimado:** `${presup:,.2f}`")
                                                f_prob = r_det.get('fecha_probable_evento', '')
                                                if f_prob:
                                                    cr2.markdown(f"**📅 Fecha Probable Evento:** `{f_prob}`")
                                                
                                                minuta_txt = r_det.get('minuta_acuerdos', '')
                                                if minuta_txt:
                                                    st.markdown("**📝 Acuerdos y Minuta:**")
                                                    st.info(minuta_txt)
                                    elif reus_raw_h:
                                        st.markdown(f"#### 🤝 Reuniones Previas Registradas ({len(reus_raw_h)})")
                                        for idx_r, r_nom in enumerate(reus_raw_h, 1):
                                            st.markdown(f"- 📌 **{r_nom}**")
                                    else:
                                        st.caption("ℹ️ Esta Orden de Producción no tiene reuniones previas vinculadas.")

                                    st.text_area("🛠️ TIPO DE SERVICIO:", value=data_h.get('tipo_de_servicio', ''), height=65, disabled=True, key=f"h_serv_{folio_h}")

                                st.write("### 👥 Asignación de Equipo y Logística") # 2. 👥 ASIGNACIÓN DE EQUIPO (Solo Lectura)
                                with st.container(border=True):
                                    col_iz, col_de = st.columns(2)
                                    with col_iz:
                                        st.text_area("SELECCIONAR PERSONAL VPRO:", value=", ".join(parsed_array(data_h.get('personal_convocado_op'))), height=80, disabled=True, key=f"h_pers_{folio_h}")
                                        st.text_area("SELECCIONAR PERSONAL EXTERNO:", value=", ".join(parsed_array(data_h.get('externos_op'))), height=80, disabled=True, key=f"h_ext_{folio_h}")
                                    with col_de:
                                        st.text_area("VEHÍCULOS:", value=", ".join(parsed_array(data_h.get('carros_usados_op'))), height=80, disabled=True, key=f"h_cars_{folio_h}")
                                        st.text_area("PROVEEDORES CO-CONVOCADOS:", value=", ".join(parsed_array(data_h.get('proveedor_op'))), height=80, disabled=True, key=f"h_provs_{folio_h}")

                                st.text_area("📦 PRODUCCIÓN:", value=data_h.get('produccion', ""), height=150, disabled=True, key=f"h_prod_txt_{folio_h}")
                                st.text_area("💻 SISTEMAS / REDES:", value=data_h.get('internet_redes', ""), height=100, disabled=True, key=f"h_redes_{folio_h}")
                                st.text_area("🏗️ ACTIVIDADES PROVEEDORES:", value=data_h.get('actividades_de_proveedores', ""), height=100, disabled=True, key=f"h_act_prov_{folio_h}")
                                st.text_area("📝 NOTAS ADICIONALES:", value=data_h.get('nota', ""), height=100, disabled=True, key=f"h_nota_{folio_h}")

                                st.write("### 🖋️ Autorizaciones")   # 3. 🖋️ AUTORIZACIONES (Solo Lectura)
                                with st.container(border=True):
                                    f_a1, f_a2, f_a3, f_a4 = st.columns(4)
                                    f_a1.text_input("📝 Elaboró:", value=data_h.get('elabora', ''), disabled=True, key=f"h_elab_{folio_h}")
                                    f_a2.text_input("🔀 Coordina:", value=data_h.get('coordina', ''), disabled=True, key=f"h_coor_{folio_h}")
                                    f_a3.text_input("🏢 Organiza:", value=data_h.get('organiza', ''), disabled=True, key=f"h_org_{folio_h}")
                                    f_a4.text_input("✅ Vo.Bo.:", value=data_h.get('vobo', ''), disabled=True, key=f"h_vobo_{folio_h}")

                                st.write("---")
                                st.success("✅ **STATUS:** CERRADA Y SELLADA FINANCIERAMENTE POR DIRECCIÓN VPRO.")

                                st.write("---") # 4. 🧳 HISTORIAL DE BODEGA / CHECKOUTS ASOCIADOS
                                st.markdown("### 🧳 Manifiestos de Bodega (Checkouts Asignados)")
                                
                                with st.spinner("Desenterrando manifiestos de bodega..."):
                                    try:
                                        res_chk = requests.get(f"{API_URL}/api/checkout/historial-op/{data_h.get('id_evento')}", verify=False)
                                        if res_chk.status_code == 200:
                                            pack_chk = res_chk.json()
                                            chks = pack_chk.get("checkouts", [])
                                            
                                            if not chks:
                                                st.info("📦 No se registraron movimientos de bodega para esta Orden de Producción.")
                                            else:
                                                import pandas as pd
                                                for idx, chk in enumerate(chks):
                                                    with st.expander(f"📦 Manifiesto de: {chk['empleado']} | 🚦 {chk['estado']} | 📅 {chk['fecha']} {chk['hora']}", expanded=(idx==0)):
                                                        st.markdown(f"**🧰 Plantilla Base Utilizada:** `{chk['plantilla'] or '--- Sin plantilla ---'}`")
        
                                                        incidencias_raw = str(chk.get('incidencias_generales', chk.get('incidencias', chk.get('observaciones', ''))))
        
                                                        if incidencias_raw.strip().lower() in ["none", "null", "nan", ""]: 
                                                            incidencias_raw = ""
            
                                                        notas_gen = incidencias_raw
                                                        prov_text = ""
                                                        
                                                        if "[PROVEEDOR_INCIDENTE:" in incidencias_raw:
                                                            s_idx = incidencias_raw.find("[PROVEEDOR_INCIDENTE:")
                                                            e_idx = incidencias_raw.find("]", s_idx)
                                                            if e_idx != -1:
                                                                prov_raw = incidencias_raw[s_idx+21:e_idx].strip()
                                                                if " | NOTA: " in prov_raw:
                                                                    p_nom, p_not = prov_raw.split(" | NOTA: ", 1)
                                                                    prov_text = f"**Proveedor Implicado:** {p_nom} \n\n**Detalle del Reporte:** {p_not}"
                                                                else:
                                                                    prov_text = f"**Proveedor Implicado:** {prov_raw}"
                                                                notas_gen = incidencias_raw[:s_idx].strip()
                                                        
                                                        col_n1, col_n2 = st.columns(2)
                                                        with col_n1:
                                                            if notas_gen:
                                                                st.info(f"📝 **Incidencias reportadas en Evento:**\n\n{notas_gen}")
                                                            else:
                                                                st.info("📝 **Incidencias reportadas en Evento:**\n\n*Sin incidencias reportadas.*")
                                                        with col_n2:
                                                            if prov_text and "--- NINGUNO ---" not in prov_text.upper():
                                                                st.error(f"🚚 **Acta de Incidencias a Proveedor:**\n\n{prov_text}")
                                                            else:
                                                                st.success("🚚 **Acta de Incidencias a Proveedor:**\n\n*Ningún proveedor reportado con fallas.*")
                                                        
                                                        st.write("")
                                                        if chk['items']:
                                                            st.dataframe(pd.DataFrame(chk['items']), use_container_width=True, hide_index=True)
                                        else:
                                            st.error("Error de conexión al cargar los manifiestos de bodega.")
                                    except Exception as e:
                                        st.error(f"Fallo al buscar checkouts: {e}")

                                st.write("---") # 5. 💸 HISTORIAL DE GASTOS ASOCIADOS
                                st.markdown("### 💸 Rendición de Cuentas y Gastos")
                                
                                with st.spinner("Desenterrando reporte financiero..."):
                                    try:
                                        res_gas = requests.get(f"{API_URL}/api/gastos/historial-op/{data_h.get('id_evento')}", verify=False)
                                        if res_gas.status_code == 200:
                                            pack_gas = res_gas.json()
                                            inf = pack_gas.get("informe")
                                            
                                            if not inf:
                                                st.info("💸 No se registró ningún informe de gastos para esta Orden de Producción.")
                                            else:
                                                with st.expander(f"🧾 Informe Financiero de: {inf['productor']} | 🔒 AUDITADO Y SELLADO POR DIRECCIÓN", expanded=True):
                                                    g_col1, g_col2, g_col3 = st.columns(3)
                                                    g_col1.metric("💰 Presupuesto Asignado", f"${inf['asignado']:,.2f}")
                                                    g_col2.metric("📉 Total Gastado", f"${inf['gastado']:,.2f}")
                                                    
                                                    if inf['saldo'] >= 0:
                                                        g_col3.metric("💵 Saldo a Favor VPRO", f"${inf['saldo']:,.2f}")
                                                    else:
                                                        g_col3.metric("🚨 Saldo a Favor Productor", f"${abs(inf['saldo']):,.2f}")
                                                    
                                                    st.write("")
                                                    if inf['items']:
                                                        st.dataframe(pd.DataFrame(inf['items']), use_container_width=True, hide_index=True)
                                        else:
                                            st.error("Error de conexión al cargar el informe financiero.")
                                    except Exception as e:
                                        st.error(f"Fallo al buscar informe de gastos: {e}")