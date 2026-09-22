"""
mod_rh.py — Módulo de Recursos Humanos VPRO
============================================
Expediente digital completo de empleados.
Accesible desde app_main_prueba.py como módulo de menú.
"""

import streamlit as st
import pandas as pd
import datetime
import requests
from typing import Optional
from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus

# ── Helpers ───────────────────────────────────────────────────────────────────

COLORES_ESTATUS = {
    "ACTIVO": "#16a34a", "BAJA": "#dc2626", "SUSPENDIDO": "#d97706",
    "VIGENTE": "#2563eb", "VENCIDO": "#9f1239", "EN RENOVACIÓN": "#d97706",
    "PENDIENTE": "#d97706", "APROBADA": "#16a34a", "APROBADO": "#16a34a",
    "RECHAZADO": "#dc2626", "RECHAZADA": "#dc2626", "ACTIVA": "#dc2626",
    "FINALIZADA": "#6b7280", "EN CURSO": "#2563eb",
    "RECIBIDA": "#6b7280", "ENTREVISTA": "#7c3aed", "CANCELADA": "#6b7280",
}

def _edad(fecha_nac) -> str:
    if not fecha_nac:
        return "—"
    try:
        fn = datetime.date.fromisoformat(str(fecha_nac)[:10])
        hoy = datetime.date.today()
        return str((hoy - fn).days // 365)
    except Exception:
        return "—"

def _anios_trabajados(fecha_ing) -> int:
    if not fecha_ing:
        return 0
    try:
        fi = datetime.date.fromisoformat(str(fecha_ing)[:10])
        return (datetime.date.today() - fi).days // 365
    except Exception:
        return 0

def _dias_vacaciones_lft(anios: int) -> int:
    tabla = [(1,12),(2,14),(3,16),(4,18),(9,20),(14,22),(19,24),(24,26),(29,28)]
    for limite, dias in tabla:
        if anios <= limite:
            return dias
    # 30+ años: 28 + 2 cada 5 años adicionales
    extra = ((anios - 30) // 5) * 2
    return 28 + max(0, extra)

def _fmt_fecha(val) -> str:
    if not val or val in ("None", "null", ""):
        return "—"
    try:
        return datetime.date.fromisoformat(str(val)[:10]).strftime("%d/%m/%Y")
    except Exception:
        return str(val)[:10]

# ══════════════════════════════════════════════════════════════════════════════
# SUBPANELES DEL EXPEDIENTE
# ══════════════════════════════════════════════════════════════════════════════

def _panel_datos_generales(api_url: str, emp: dict, id_emp: str):
    """Panel de edición de datos generales del empleado."""
    st.markdown("#### 📋 Datos Generales del Empleado")

    with st.form("form_datos_gen"):
        col1, col2, col3 = st.columns(3)
        with col1:
            nombre   = st.text_input("Nombre completo", value=emp.get("nombre",""))
            email    = st.text_input("Correo", value=emp.get("email","") or "")
            cel      = st.text_input("Celular", value=emp.get("cel","") or "")
            rfc      = st.text_input("RFC", value=emp.get("rfc","") or "")
            curp     = st.text_input("CURP", value=emp.get("curp","") or "")
            nss      = st.text_input("NSS (IMSS)", value=emp.get("nss","") or "")
        with col2:
            depto    = st.text_input("Departamento", value=emp.get("depto","") or "")
            puesto   = st.text_input("Puesto / Cargo", value=emp.get("puesto","") or "")
            tipo_cont= st.selectbox("Tipo contrato",
                ["PLANTA","EVENTUAL","HONORARIOS","PROYECTO"],
                index=["PLANTA","EVENTUAL","HONORARIOS","PROYECTO"].index(
                    emp.get("tipo_contrato","PLANTA") or "PLANTA"))
            salario  = st.number_input("Salario mensual bruto ($)", value=float(emp.get("salario_mensual") or 0), step=500.0)
            escolar  = st.selectbox("Escolaridad",
                ["PRIMARIA","SECUNDARIA","PREPARATORIA","TÉCNICO","LICENCIATURA","MAESTRÍA","DOCTORADO","OTRO"],
                index=["PRIMARIA","SECUNDARIA","PREPARATORIA","TÉCNICO","LICENCIATURA","MAESTRÍA","DOCTORADO","OTRO"].index(
                    emp.get("escolaridad","LICENCIATURA") or "LICENCIATURA") if emp.get("escolaridad") else 4)
            estado_civ = st.selectbox("Estado civil",
                ["SOLTERO","CASADO","UNIÓN LIBRE","DIVORCIADO","VIUDO"],
                index=["SOLTERO","CASADO","UNIÓN LIBRE","DIVORCIADO","VIUDO"].index(
                    emp.get("estado_civil","SOLTERO") or "SOLTERO") if emp.get("estado_civil") else 0)
        with col3:
            domicilio = st.text_area("Domicilio", value=emp.get("domicilio","") or "", height=68)
            ciudad    = st.text_input("Ciudad", value=emp.get("ciudad","") or "")
            cp        = st.text_input("Código Postal", value=emp.get("cp","") or "")
            contacto_emerg = st.text_input("Contacto emergencia", value=emp.get("contacto_emergencia","") or "")
            tel_emerg = st.text_input("Tel. emergencia", value=emp.get("tel_emergencia","") or "")
            parent_emerg = st.text_input("Parentesco", value=emp.get("parentesco_emergencia","") or "")

        col_e1, col_e2, col_e3 = st.columns(3)
        with col_e1:
            estatus_emp = st.selectbox("Estatus empleado",
                ["ACTIVO","BAJA","SUSPENDIDO","VACACIONES"],
                index=["ACTIVO","BAJA","SUSPENDIDO","VACACIONES"].index(
                    emp.get("estatus_empleado","ACTIVO") or "ACTIVO"))
        with col_e2:
            fecha_baja_val = emp.get("fecha_baja")
            fecha_baja = st.date_input("Fecha baja (si aplica)",
                value=datetime.date.fromisoformat(str(fecha_baja_val)[:10]) if fecha_baja_val else None)
        with col_e3:
            motivo_baja = st.text_input("Motivo de baja", value=emp.get("motivo_baja","") or "")

        usuario_actual = st.session_state.get("usuario_nombre", "RH")
        
        st.divider()
        col_btn1, col_btn2 = st.columns([1, 1])
        with col_btn1:
            submitted = st.form_submit_button("💾 Guardar cambios en el Expediente", use_container_width=True)
        with col_btn2:
            if st.form_submit_button("🔑 Ir a Catálogo (ABC) para Accesos y Contraseña", type="secondary", use_container_width=True):
                st.session_state["menu_dinamico"] = "   ↳ 🦺 Empleados"
                st.session_state["abc_expandido"] = True
                st.rerun()

    if submitted:
        body = {
            "nombre": nombre, "email": email, "cel": cel, "rfc": rfc,
            "curp": curp, "nss": nss, "depto": depto, "puesto": puesto,
            "tipo_contrato": tipo_cont, "salario_mensual": salario,
            "escolaridad": escolar, "estado_civil": estado_civ,
            "domicilio": domicilio, "ciudad": ciudad, "cp": cp,
            "contacto_emergencia": contacto_emerg, "tel_emergencia": tel_emerg,
            "parentesco_emergencia": parent_emerg, "estatus_empleado": estatus_emp,
            "fecha_baja": str(fecha_baja) if fecha_baja else None,
            "motivo_baja": motivo_baja, "registrado_por": usuario_actual
        }
        status, resp = _put(api_url, f"/api/rh/empleados/{id_emp}", body)
        if status == 200:
            st.success("✅ Datos actualizados correctamente.")
            import time
            time.sleep(1)
            st.rerun()
        else:
            st.error(f"❌ Error: {resp.get('detail', 'Desconocido')}")


def _panel_solicitud_empleo(api_url: str, id_emp: str):
    """Panel de solicitud de empleo original del empleado."""
    sol = _get(api_url, "/api/rh/solicitudes", {"id_empleado_resultado": id_emp})
    if sol:
        s = sol[0] if isinstance(sol, list) else sol
        st.markdown("#### 📝 Solicitud de Empleo Original")
        cols = st.columns(3)
        cols[0].metric("Folio", s.get("folio","—"))
        cols[1].metric("Fecha solicitud", _fmt_fecha(s.get("fecha_solicitud")))
        cols[2].markdown(_badge(s.get("estatus","—"), _color_estatus(s.get("estatus",""))), unsafe_allow_html=True)
        with st.expander("Ver detalle completo de la solicitud"):
            st.json(s)
    else:
        st.info("📭 No se encontró solicitud de empleo vinculada a este empleado.")

    st.divider()
    st.markdown("#### ➕ Nueva Solicitud de Empleo (candidato externo)")
    if st.button("📝 Registrar nueva solicitud"):
        st.session_state["rh_nueva_solicitud"] = True

    if st.session_state.get("rh_nueva_solicitud"):
        with st.form("form_nueva_solicitud"):
            st.markdown("**Datos del candidato**")
            col1, col2 = st.columns(2)
            with col1:
                nombre_c = st.text_input("Nombre completo *")
                email_c  = st.text_input("Correo")
                tel_c    = st.text_input("Teléfono celular")
                puesto_c = st.text_input("Puesto solicitado *")
                depto_c  = st.text_input("Departamento")
            with col2:
                exp_anios = st.number_input("Años de experiencia", 0, 50, 0)
                pretension = st.number_input("Pretensión salarial ($)", 0.0, step=500.0)
                como_ent  = st.selectbox("¿Cómo se enteró?",
                    ["Referido","LinkedIn","Bolsa de trabajo","Redes sociales","Otro"])
                referido_por = st.text_input("¿Quién lo refirió?")
                disponible_ya = st.checkbox("Disponibilidad inmediata")
            escolar_c = st.selectbox("Escolaridad",
                ["PREPARATORIA","TÉCNICO","LICENCIATURA","MAESTRÍA","DOCTORADO"])
            habilidades_c = st.text_area("Habilidades y competencias")
            exp_desc_c    = st.text_area("Descripción de experiencia previa")
            col3, col4, col5 = st.columns(3)
            tiene_auto = col3.checkbox("¿Tiene auto?")
            tiene_lic  = col4.checkbox("¿Tiene licencia de conducir?")

            usuario_actual = st.session_state.get("usuario_nombre", "RH")
            sub = st.form_submit_button("📤 Enviar solicitud", use_container_width=True)
        if sub:
            body = {
                "nombre_completo": nombre_c, "email": email_c, "tel_celular": tel_c,
                "puesto_solicitado": puesto_c, "depto_solicitado": depto_c,
                "experiencia_anios": exp_anios, "pretension_salarial": pretension,
                "como_se_entero": como_ent, "referido_por": referido_por,
                "disponibilidad_inmediata": disponible_ya, "escolaridad": escolar_c,
                "habilidades": habilidades_c, "experiencia_descripcion": exp_desc_c,
                "tiene_auto": tiene_auto, "tiene_licencia": tiene_lic,
                "creado_por": usuario_actual
            }
            status, resp = _post(api_url, "/api/rh/solicitudes", body)
            if status in (200, 201):
                st.success(f"✅ Solicitud registrada. Folio: {resp.get('folio','—')}")
                st.session_state["rh_nueva_solicitud"] = False
                st.rerun()
            else:
                st.error(f"❌ {resp.get('detail','Error desconocido')}")


def _panel_entrevistas(api_url: str, id_emp: str):
    """Panel de entrevistas del empleado."""
    st.markdown("#### 🤝 Historial de Entrevistas")
    entrevistas = _get(api_url, "/api/rh/entrevistas", {"id_empleado": id_emp}) or []

    if entrevistas:
        for e in entrevistas:
            cal_g = e.get("calificacion_general")
            cal_str = f"⭐ {cal_g}/10" if cal_g else "Sin calificar"
            color = _color_estatus(e.get("resultado",""))
            with st.expander(
                f"📅 {_fmt_fecha(e.get('fecha_entrevista'))} — {e.get('tipo_entrevista','—')} — "
                f"{e.get('entrevistador','—')} — {cal_str}"
            ):
                col1, col2, col3 = st.columns(3)
                col1.metric("Tipo", e.get("tipo_entrevista","—"))
                col1.metric("Modalidad", e.get("modalidad","—"))
                col2.metric("Entrevistador", e.get("entrevistador","—"))
                col2.markdown(_badge(e.get("resultado","—"), color), unsafe_allow_html=True)
                col3.metric("Fecha", _fmt_fecha(e.get("fecha_entrevista")))
                col3.metric("Horario", f"{e.get('hora_inicio','')[:5]} – {e.get('hora_fin','')[:5]}")
                if cal_g:
                    crit = {
                        "Puntualidad": e.get("puntualidad",0),
                        "Presentación": e.get("presentacion",0),
                        "Conocimientos": e.get("conocimientos_tecnicos",0),
                        "Actitud": e.get("actitud",0),
                        "Comunicación": e.get("comunicacion",0),
                    }
                    df_crit = pd.DataFrame(crit.items(), columns=["Criterio","Calificación"])
                    st.dataframe(df_crit, hide_index=True, use_container_width=True)
                if e.get("comentarios"):
                    st.info(f"💬 {e['comentarios']}")
                if e.get("recomendacion"):
                    st.success(f"✅ Recomendación: {e['recomendacion']}")
    else:
        st.info("📭 Sin entrevistas registradas.")

    st.divider()
    st.markdown("#### ➕ Agregar nueva entrevista")
    with st.form("form_nueva_entrevista"):
        col1, col2 = st.columns(2)
        with col1:
            tipo_ent    = st.selectbox("Tipo de entrevista",
                ["INICIAL","TÉCNICA","RH","FINAL","PSICOMÉTRICA"])
            fecha_ent   = st.date_input("Fecha", value=datetime.date.today())
            hora_ini    = st.time_input("Hora inicio", value=datetime.time(10,0))
            hora_fin    = st.time_input("Hora fin", value=datetime.time(11,0))
            entrev_por  = st.text_input("Entrevistador")
        with col2:
            modalidad   = st.selectbox("Modalidad", ["PRESENCIAL","VIDEOLLAMADA","TELEFÓNICA"])
            link_vid    = st.text_input("Link (si es remota)")
            resultado_e = st.selectbox("Resultado",
                ["PENDIENTE","APROBADO","RECHAZADO","EN ESPERA"])

        st.markdown("**Calificación por criterio (0–10)**")
        c1, c2, c3, c4, c5 = st.columns(5)
        punt  = c1.number_input("Puntualidad", 0.0, 10.0, 7.0, 0.5)
        pres  = c2.number_input("Presentación", 0.0, 10.0, 7.0, 0.5)
        conoc = c3.number_input("Conocimientos", 0.0, 10.0, 7.0, 0.5)
        acti  = c4.number_input("Actitud", 0.0, 10.0, 7.0, 0.5)
        comu  = c5.number_input("Comunicación", 0.0, 10.0, 7.0, 0.5)
        comentarios_e = st.text_area("Comentarios / Observaciones")
        recomendacion_e = st.text_area("Recomendación")
        usuario_actual = st.session_state.get("usuario_nombre", "RH")
        sub_ent = st.form_submit_button("💾 Guardar entrevista", use_container_width=True)

    if sub_ent:
        body = {
            "id_empleado": id_emp,
            "tipo_entrevista": tipo_ent,
            "fecha_entrevista": str(fecha_ent),
            "hora_inicio": str(hora_ini),
            "hora_fin": str(hora_fin),
            "entrevistador": entrev_por,
            "modalidad": modalidad,
            "link_videollamada": link_vid,
            "resultado": resultado_e,
            "puntualidad": punt, "presentacion": pres,
            "conocimientos_tecnicos": conoc, "actitud": acti, "comunicacion": comu,
            "comentarios": comentarios_e, "recomendacion": recomendacion_e,
            "registrado_por": usuario_actual
        }
        status, resp = _post(api_url, "/api/rh/entrevistas", body)
        if status in (200, 201):
            st.success("✅ Entrevista registrada.")
            st.rerun()
        else:
            st.error(f"❌ {resp.get('detail','Error')}")


def _panel_contratos(api_url: str, id_emp: str):
    """Panel de contratos."""
    st.markdown("#### 📄 Historial de Contratos")
    contratos = _get(api_url, f"/api/rh/contratos/{id_emp}") or []
    vigente   = _get(api_url, f"/api/rh/contratos/vigente/{id_emp}")

    if vigente:
        with st.container(border=True):
            st.markdown(f"**Contrato Vigente** — {vigente.get('folio_contrato','—')}")
            c1, c2, c3, c4 = st.columns(4)
            c1.metric("Tipo", vigente.get("tipo_contrato","—"))
            c2.metric("Puesto", vigente.get("puesto_contratado","—"))
            c3.metric("Inicio", _fmt_fecha(vigente.get("fecha_inicio")))
            c4.metric("Fin", _fmt_fecha(vigente.get("fecha_fin")) if not vigente.get("es_indefinido") else "INDEFINIDO")
            c1.metric("Salario", f"${vigente.get('salario_mensual',0):,.2f}")
            c2.metric("Jornada", vigente.get("jornada","—"))
            c3.metric("Horario", vigente.get("horario","—"))
            c4.metric("Días vacaciones/año", vigente.get("dias_vacaciones_anuales","—"))

    if contratos:
        df_cont = pd.DataFrame([{
            "Folio": c.get("folio_contrato","—"),
            "Tipo": c.get("tipo_contrato","—"),
            "Inicio": _fmt_fecha(c.get("fecha_inicio")),
            "Fin": _fmt_fecha(c.get("fecha_fin")) if not c.get("es_indefinido") else "Indefinido",
            "Puesto": c.get("puesto_contratado","—"),
            "Salario": f"${c.get('salario_mensual',0):,.2f}",
            "Estatus": c.get("estatus_contrato","—"),
        } for c in contratos])
        st.dataframe(df_cont, hide_index=True, use_container_width=True)

    st.divider()
    st.markdown("#### ➕ Registrar nuevo contrato")
    with st.form("form_nuevo_contrato"):
        col1, col2 = st.columns(2)
        with col1:
            tipo_c   = st.selectbox("Tipo de contrato",
                ["PLANTA","EVENTUAL","PROYECTO","HONORARIOS","PRUEBA 90 DÍAS"])
            puesto_c = st.text_input("Puesto contratado")
            depto_c  = st.text_input("Departamento")
            salario_c= st.number_input("Salario mensual bruto ($)", 0.0, step=500.0)
            jornada_c= st.selectbox("Jornada", ["COMPLETA","MEDIO TIEMPO","POR PROYECTO"])
            horario_c= st.text_input("Horario", value="Lunes–Viernes 09:00–19:00")
        with col2:
            f_ini_c  = st.date_input("Fecha inicio", value=datetime.date.today())
            indefinido = st.checkbox("¿Contrato indefinido?", value=False)
            f_fin_c  = None if indefinido else st.date_input("Fecha fin", value=datetime.date.today() + datetime.timedelta(days=365))
            dias_vac = st.number_input("Días de vacaciones anuales (LFT)", 12, 30, 12)
            firmado_emp = st.checkbox("¿Firmó el empleado?")
            firmado_emp2 = st.checkbox("¿Firmó la empresa?")
            f_firma  = st.date_input("Fecha de firma", value=datetime.date.today())
        clausulas = st.text_area("Cláusulas especiales (opcional)")
        observ_c  = st.text_area("Observaciones")
        usuario_actual = st.session_state.get("usuario_nombre", "RH")
        sub_c = st.form_submit_button("💾 Guardar contrato", use_container_width=True)

    if sub_c:
        body = {
            "id_empleado": id_emp, "tipo_contrato": tipo_c,
            "puesto_contratado": puesto_c, "departamento": depto_c,
            "salario_mensual": salario_c, "jornada": jornada_c, "horario": horario_c,
            "fecha_inicio": str(f_ini_c),
            "fecha_fin": str(f_fin_c) if f_fin_c else None,
            "es_indefinido": indefinido,
            "dias_vacaciones_anuales": dias_vac,
            "firmado_empleado": firmado_emp, "firmado_empresa": firmado_emp2,
            "fecha_firma": str(f_firma),
            "clausulas_especiales": clausulas, "observaciones": observ_c,
            "estatus_contrato": "VIGENTE", "registrado_por": usuario_actual
        }
        status, resp = _post(api_url, "/api/rh/contratos", body)
        if status in (200, 201):
            st.success(f"✅ Contrato registrado. Folio: {resp.get('folio_contrato','—')}")
            st.rerun()
        else:
            st.error(f"❌ {resp.get('detail','Error')}")


def _panel_vacaciones(api_url: str, id_emp: str, emp: dict):
    """Panel de vacaciones con cálculo LFT automático."""
    st.markdown("#### 🏖️ Vacaciones")

    anios = _anios_trabajados(emp.get("fecha_ing"))
    dias_lft = _dias_vacaciones_lft(anios)

    vac_data = _get(api_url, f"/api/rh/vacaciones/{id_emp}") or {}
    historial = vac_data.get("historial", []) if isinstance(vac_data, dict) else []
    resumen   = vac_data.get("resumen", {}) if isinstance(vac_data, dict) else {}

    # Tarjetas de resumen
    col1, col2, col3, col4 = st.columns(4)
    col1.metric("Antigüedad", f"{anios} años")
    col2.metric("Días LFT correspondientes", f"{dias_lft} días")
    col3.metric("Días tomados", resumen.get("dias_tomados", 0))
    col4.metric("Días pendientes", resumen.get("dias_pendientes", dias_lft))

    if historial:
        df_vac = pd.DataFrame([{
            "Periodo": v.get("anio_periodo","—"),
            "Tipo": v.get("tipo","—"),
            "Inicio goce": _fmt_fecha(v.get("fecha_inicio_goce")),
            "Fin goce": _fmt_fecha(v.get("fecha_fin_goce")),
            "Días": v.get("dias_correspondientes","—"),
            "Límite LFT": _fmt_fecha(v.get("fecha_limite_goce")),
            "Estatus": v.get("estatus","—"),
            "Aprobado por": v.get("aprobado_por","—"),
            "Admon notif.": "✅" if v.get("notificado_admon") else "⏳",
        } for v in historial])
        st.dataframe(df_vac, hide_index=True, use_container_width=True)

    st.divider()
    st.markdown("#### ➕ Registrar periodo de vacaciones")
    with st.form("form_vacaciones"):
        col1, col2 = st.columns(2)
        with col1:
            anio_per = st.number_input("Año del periodo", 2020, 2030, datetime.date.today().year)
            tipo_vac = st.selectbox("Tipo", ["ORDINARIA","ANTICIPADA","COMPENSATORIA"])
            f_ini_vac= st.date_input("Fecha inicio de goce", value=datetime.date.today())
            f_fin_vac= st.date_input("Fecha fin de goce",
                value=datetime.date.today() + datetime.timedelta(days=dias_lft-1))
        with col2:
            f_lim_vac= st.date_input("Fecha límite para disfrutarlas",
                value=datetime.date(f_ini_vac.year, 12, 31))
            estatus_v= st.selectbox("Estatus",
                ["SOLICITADA","APROBADA","EN CURSO","FINALIZADA","CANCELADA"])
            aprobado_por_v = st.text_input("Aprobado por")
            notif_admon = st.checkbox("¿Administración notificada?")
        observ_v = st.text_area("Observaciones")
        usuario_actual = st.session_state.get("usuario_nombre", "RH")
        sub_v = st.form_submit_button("💾 Guardar vacaciones", use_container_width=True)

    if sub_v:
        dias_calc = (f_fin_vac - f_ini_vac).days + 1
        body = {
            "id_empleado": id_emp, "anio_periodo": anio_per,
            "dias_correspondientes": dias_lft, "dias_tomados": dias_calc,
            "dias_pendientes": dias_lft - dias_calc,
            "fecha_inicio_goce": str(f_ini_vac), "fecha_fin_goce": str(f_fin_vac),
            "fecha_limite_goce": str(f_lim_vac), "tipo": tipo_vac,
            "estatus": estatus_v, "aprobado_por": aprobado_por_v,
            "notificado_admon": notif_admon,
            "observaciones": observ_v, "registrado_por": usuario_actual
        }
        status, resp = _post(api_url, "/api/rh/vacaciones", body)
        if status in (200, 201):
            st.success("✅ Vacaciones registradas.")
            st.rerun()
        else:
            st.error(f"❌ {resp.get('detail','Error')}")


def _panel_permisos(api_url: str, id_emp: str):
    """Panel de permisos y ausencias."""
    st.markdown("#### 📅 Permisos y Ausencias")
    permisos = _get(api_url, "/api/rh/permisos", {"id_empleado": id_emp}) or []

    if permisos:
        for p in permisos:
            color = _color_estatus(p.get("estatus",""))
            gce = "Con goce" if p.get("con_goce_de_sueldo") else "Sin goce"
            with st.expander(
                f"📋 {p.get('folio_permiso','—')} — {p.get('tipo_permiso','—')} — "
                f"{_fmt_fecha(p.get('fecha_inicio'))} al {_fmt_fecha(p.get('fecha_fin'))} — {gce}"
            ):
                col1, col2, col3 = st.columns(3)
                col1.metric("Tipo", p.get("tipo_permiso","—"))
                col1.metric("Días", p.get("dias_solicitados","—"))
                col2.markdown(_badge(p.get("estatus","—"), color), unsafe_allow_html=True)
                col2.metric("Aprobado por", p.get("aprobado_por","—") or "Pendiente")
                col3.metric("Inicio", _fmt_fecha(p.get("fecha_inicio")))
                col3.metric("Fin", _fmt_fecha(p.get("fecha_fin")))
                if p.get("justificacion"):
                    st.info(f"📝 {p['justificacion']}")
                if p.get("motivo_rechazo"):
                    st.error(f"❌ Rechazado: {p['motivo_rechazo']}")

                if p.get("estatus") == "PENDIENTE":
                    colA, colB = st.columns(2)
                    usuario_actual = st.session_state.get("usuario_nombre", "RH")
                    if colA.button("✅ Aprobar", key=f"apr_p_{p['id_permiso']}"):
                        _put(api_url, f"/api/rh/permisos/{p['id_permiso']}",
                            {"estatus": "APROBADO", "aprobado_por": usuario_actual,
                             "fecha_aprobacion": str(datetime.date.today())})
                        st.rerun()
                    if colB.button("❌ Rechazar", key=f"rec_p_{p['id_permiso']}"):
                        _put(api_url, f"/api/rh/permisos/{p['id_permiso']}",
                            {"estatus": "RECHAZADO", "aprobado_por": usuario_actual})
                        st.rerun()
    else:
        st.info("📭 Sin permisos registrados.")

    st.divider()
    st.markdown("#### ➕ Nueva solicitud de permiso")
    with st.form("form_permiso"):
        col1, col2 = st.columns(2)
        with col1:
            tipo_p   = st.selectbox("Tipo de permiso",
                ["PERSONAL","MÉDICO","FAMILIAR","LUTO","PATERNIDAD","MATERNIDAD","ESTUDIO","OTRO"])
            f_ini_p  = st.date_input("Fecha inicio", value=datetime.date.today())
            f_fin_p  = st.date_input("Fecha fin", value=datetime.date.today())
        with col2:
            goce_p   = st.checkbox("Con goce de sueldo", value=True)
            impacta  = st.checkbox("Impacta en asistencia (marcar como PERMISO)", value=True)
        justif   = st.text_area("Justificación / Motivo")
        usuario_actual = st.session_state.get("usuario_nombre", "RH")
        sub_p = st.form_submit_button("📤 Solicitar permiso", use_container_width=True)

    if sub_p:
        dias_calc = (f_fin_p - f_ini_p).days + 1
        body = {
            "id_empleado": id_emp, "tipo_permiso": tipo_p,
            "fecha_inicio": str(f_ini_p), "fecha_fin": str(f_fin_p),
            "dias_solicitados": dias_calc, "con_goce_de_sueldo": goce_p,
            "justificacion": justif, "impacta_asistencia": impacta,
            "registrado_por": usuario_actual
        }
        status, resp = _post(api_url, "/api/rh/permisos", body)
        if status in (200, 201):
            st.success(f"✅ Permiso registrado. Folio: {resp.get('folio_permiso','—')}")
            st.rerun()
        else:
            st.error(f"❌ {resp.get('detail','Error')}")


def _panel_incapacidades(api_url: str, id_emp: str):
    """Panel de incapacidades IMSS."""
    st.markdown("#### 🏥 Incapacidades")
    incaps = _get(api_url, f"/api/rh/incapacidades/{id_emp}") or []

    if incaps:
        df_inc = pd.DataFrame([{
            "Folio": i.get("folio_incapacidad","—"),
            "Tipo": i.get("tipo","—"),
            "Inicio": _fmt_fecha(i.get("fecha_inicio")),
            "Fin": _fmt_fecha(i.get("fecha_fin")),
            "Días": i.get("dias_incapacidad","—"),
            "Núm. IMSS": i.get("numero_imss","—"),
            "Médico": i.get("medico_tratante","—"),
            "% IMSS": i.get("porcentaje_pago_imss","—"),
            "Estatus": i.get("estatus","—"),
            "Validado RH": "✅" if i.get("validado_por_rh") else "⏳",
        } for i in incaps])
        st.dataframe(df_inc, hide_index=True, use_container_width=True)
    else:
        st.info("📭 Sin incapacidades registradas.")

    st.divider()
    st.markdown("#### ➕ Registrar incapacidad")
    with st.form("form_incapacidad"):
        col1, col2 = st.columns(2)
        with col1:
            tipo_i   = st.selectbox("Tipo",
                ["ENFERMEDAD GENERAL","RIESGO DE TRABAJO","MATERNIDAD","PATERNIDAD"])
            f_ini_i  = st.date_input("Fecha inicio", value=datetime.date.today())
            f_fin_i  = st.date_input("Fecha fin", value=datetime.date.today() + datetime.timedelta(days=3))
            num_imss = st.text_input("Número de incapacidad IMSS")
        with col2:
            medico_i = st.text_input("Médico tratante / Clínica")
            pct_imss = st.number_input("% pago IMSS", 0.0, 100.0, 60.0, 10.0)
            validado_i = st.checkbox("¿Validado por RH?")
            diagnost = st.text_area("Diagnóstico (opcional)")
        observ_i = st.text_area("Observaciones")
        usuario_actual = st.session_state.get("usuario_nombre", "RH")
        sub_i = st.form_submit_button("💾 Registrar incapacidad", use_container_width=True)

    if sub_i:
        dias_i = (f_fin_i - f_ini_i).days + 1
        body = {
            "id_empleado": id_emp, "tipo": tipo_i,
            "fecha_inicio": str(f_ini_i), "fecha_fin": str(f_fin_i),
            "dias_incapacidad": dias_i, "numero_imss": num_imss,
            "medico_tratante": medico_i, "diagnostico": diagnost,
            "porcentaje_pago_imss": pct_imss, "validado_por_rh": validado_i,
            "observaciones": observ_i, "registrado_por": usuario_actual
        }
        status, resp = _post(api_url, "/api/rh/incapacidades", body)
        if status in (200, 201):
            st.success(f"✅ Incapacidad registrada. Folio: {resp.get('folio_incapacidad','—')}")
            st.rerun()
        else:
            st.error(f"❌ {resp.get('detail','Error')}")


def _panel_capacitacion(api_url: str, id_emp: str):
    """Panel de capacitación y cursos."""
    st.markdown("#### 🎓 Capacitación y Cursos")
    cursos = _get(api_url, f"/api/rh/capacitacion/{id_emp}") or []

    if cursos:
        df_cursos = pd.DataFrame([{
            "Curso": c.get("nombre_curso","—"),
            "Tipo": c.get("tipo","—"),
            "Institución": c.get("institucion","—"),
            "Inicio": _fmt_fecha(c.get("fecha_inicio")),
            "Fin": _fmt_fecha(c.get("fecha_fin")),
            "Horas": c.get("horas_duracion","—"),
            "Resultado": c.get("resultado","—"),
            "Calificación": c.get("calificacion","—"),
            "Constancia": "✅" if c.get("tiene_constancia") else "—",
            "Costo": f"${c.get('costo',0):,.2f}",
            "Empresa paga": "✅" if c.get("pagado_por_empresa") else "No",
        } for c in cursos])
        st.dataframe(df_cursos, hide_index=True, use_container_width=True)
    else:
        st.info("📭 Sin capacitaciones registradas.")

    st.divider()
    st.markdown("#### ➕ Registrar curso / capacitación")
    with st.form("form_capacitacion"):
        col1, col2 = st.columns(2)
        with col1:
            nombre_cur = st.text_input("Nombre del curso / capacitación *")
            tipo_cur   = st.selectbox("Tipo", ["INTERNA","EXTERNA","EN LÍNEA","CERTIFICACIÓN"])
            instituc   = st.text_input("Institución / Proveedor")
            f_ini_cur  = st.date_input("Fecha inicio", value=datetime.date.today())
            f_fin_cur  = st.date_input("Fecha fin", value=datetime.date.today() + datetime.timedelta(days=7))
        with col2:
            horas_cur  = st.number_input("Horas de duración", 0, 500, 8)
            result_cur = st.selectbox("Resultado", ["EN CURSO","APROBADO","REPROBADO","NO PRESENTADO"])
            calif_cur  = st.number_input("Calificación (si aplica)", 0.0, 100.0, 0.0)
            const_cur  = st.checkbox("¿Obtuvo constancia/certificado?")
            costo_cur  = st.number_input("Costo ($)", 0.0, step=100.0)
            empresa_paga = st.checkbox("¿Lo pagó la empresa?", value=True)
        observ_cur = st.text_area("Observaciones")
        usuario_actual = st.session_state.get("usuario_nombre", "RH")
        sub_cur = st.form_submit_button("💾 Registrar", use_container_width=True)

    if sub_cur:
        body = {
            "id_empleado": id_emp, "nombre_curso": nombre_cur, "tipo": tipo_cur,
            "institucion": instituc, "fecha_inicio": str(f_ini_cur), "fecha_fin": str(f_fin_cur),
            "horas_duracion": horas_cur, "resultado": result_cur,
            "calificacion": calif_cur if calif_cur > 0 else None,
            "tiene_constancia": const_cur, "costo": costo_cur,
            "pagado_por_empresa": empresa_paga, "observaciones": observ_cur,
            "registrado_por": usuario_actual
        }
        status, resp = _post(api_url, "/api/rh/capacitacion", body)
        if status in (200, 201):
            st.success("✅ Capacitación registrada.")
            st.rerun()
        else:
            st.error(f"❌ {resp.get('detail','Error')}")


def _panel_evaluaciones(api_url: str, id_emp: str):
    """Panel de evaluaciones de desempeño."""
    st.markdown("#### 📈 Evaluaciones de Desempeño")
    evals = _get(api_url, f"/api/rh/evaluaciones/{id_emp}") or []

    if evals:
        for ev in evals:
            cal = ev.get("calificacion_final", 0) or 0
            nivel = ev.get("nivel_desempeno","—")
            color_niv = {"EXCELENTE":"#16a34a","BUENO":"#2563eb","REGULAR":"#d97706","DEFICIENTE":"#dc2626"}.get(nivel,"#6b7280")
            with st.expander(
                f"📊 {ev.get('periodo','—')} — {ev.get('tipo','—')} — "
                f"Cal: {cal}/10 — {nivel}"
            ):
                col1, col2 = st.columns(2)
                criterios = {
                    "Puntualidad": ev.get("puntualidad",0),
                    "Calidad trabajo": ev.get("calidad_trabajo",0),
                    "Trabajo en equipo": ev.get("trabajo_equipo",0),
                    "Responsabilidad": ev.get("responsabilidad",0),
                    "Iniciativa": ev.get("iniciativa",0),
                    "Comunicación": ev.get("comunicacion",0),
                    "Cumplimiento objetivos": ev.get("cumplimiento_objetivos",0),
                }
                df_ev = pd.DataFrame(criterios.items(), columns=["Criterio","Calificación"])
                col1.dataframe(df_ev, hide_index=True)
                col2.metric("Calificación final", f"{cal}/10")
                col2.markdown(_badge(nivel, color_niv), unsafe_allow_html=True)
                col2.metric("Evaluador", ev.get("evaluador","—"))
                if ev.get("fortalezas"):
                    st.success(f"💪 Fortalezas: {ev['fortalezas']}")
                if ev.get("areas_mejora"):
                    st.warning(f"🎯 Áreas de mejora: {ev['areas_mejora']}")
                if ev.get("plan_accion"):
                    st.info(f"📋 Plan de acción: {ev['plan_accion']}")
    else:
        st.info("📭 Sin evaluaciones registradas.")

    st.divider()
    st.markdown("#### ➕ Nueva evaluación de desempeño")
    with st.form("form_evaluacion"):
        col1, col2 = st.columns(2)
        with col1:
            periodo_ev  = st.text_input("Periodo", value=f"{datetime.date.today().year}-S{1 if datetime.date.today().month<=6 else 2}")
            tipo_ev     = st.selectbox("Tipo", ["SEMESTRAL","ANUAL","PRUEBA 90 DÍAS","ESPECIAL"])
            evaluador_ev= st.text_input("Evaluador")
            puesto_eval = st.text_input("Puesto del evaluador")
        with col2:
            st.markdown("**Criterios (0–10)**")
        c1,c2,c3,c4 = st.columns(4)
        punt_ev = c1.number_input("Puntualidad",0.0,10.0,8.0,0.5)
        cal_ev  = c2.number_input("Calidad trabajo",0.0,10.0,8.0,0.5)
        eq_ev   = c3.number_input("Trabajo equipo",0.0,10.0,8.0,0.5)
        resp_ev = c4.number_input("Responsabilidad",0.0,10.0,8.0,0.5)
        c5,c6,c7,_ = st.columns(4)
        ini_ev  = c5.number_input("Iniciativa",0.0,10.0,8.0,0.5)
        com_ev  = c6.number_input("Comunicación",0.0,10.0,8.0,0.5)
        obj_ev  = c7.number_input("Cumpl. objetivos",0.0,10.0,8.0,0.5)
        fortalezas_ev = st.text_area("Fortalezas identificadas")
        mejoras_ev    = st.text_area("Áreas de mejora")
        plan_ev       = st.text_area("Plan de acción acordado")
        comentarios_emp_ev = st.text_area("Comentarios del empleado evaluado")
        firma_emp_ev  = st.checkbox("¿El empleado firmó de enterado?")
        usuario_actual = st.session_state.get("usuario_nombre", "RH")
        sub_ev = st.form_submit_button("💾 Guardar evaluación", use_container_width=True)

    if sub_ev:
        body = {
            "id_empleado": id_emp, "periodo": periodo_ev, "tipo": tipo_ev,
            "evaluador": evaluador_ev, "puesto_evaluador": puesto_eval,
            "puntualidad": punt_ev, "calidad_trabajo": cal_ev,
            "trabajo_equipo": eq_ev, "responsabilidad": resp_ev,
            "iniciativa": ini_ev, "comunicacion": com_ev,
            "cumplimiento_objetivos": obj_ev,
            "fortalezas": fortalezas_ev, "areas_mejora": mejoras_ev,
            "plan_accion": plan_ev, "comentarios_empleado": comentarios_emp_ev,
            "firma_empleado": firma_emp_ev, "registrado_por": usuario_actual
        }
        status, resp = _post(api_url, "/api/rh/evaluaciones", body)
        if status in (200, 201):
            st.success(f"✅ Evaluación registrada. Calificación: {resp.get('calificacion_final','—')}/10")
            st.rerun()
        else:
            st.error(f"❌ {resp.get('detail','Error')}")


def _panel_documentos(api_url: str, id_emp: str):
    """Panel de repositorio de documentos con OCR integrado."""
    import base64

    st.markdown("#### 📂 Repositorio de Documentos")
    docs = _get(api_url, f"/api/rh/documentos/{id_emp}") or []

    TIPOS_DOC_OCR = ["INE", "CURP", "NSS", "RFC", "ACTA NACIMIENTO",
                     "LICENCIA CONDUCIR", "COMPROBANTE DOMICILIO"]
    TIPOS_DOC = TIPOS_DOC_OCR + ["TÍTULO", "CÉDULA PROFESIONAL", "FOTO",
                                  "CARTA RECOMENDACIÓN", "CONTRATO FIRMADO",
                                  "CARTA NO ANTECEDENTES", "EXAMEN MÉDICO", "OTRO"]

    # ── Lista de documentos existentes ────────────────────────────────────────
    if docs:
        df_docs = pd.DataFrame([{
            "Tipo": d.get("tipo_documento", "—"),
            "Nombre": d.get("nombre_archivo", "—"),
            "Formato": d.get("formato", "—"),
            "Fecha emisión": _fmt_fecha(d.get("fecha_emision")),
            "Vencimiento": _fmt_fecha(d.get("fecha_vencimiento")),
            "Vigente": "✅" if d.get("esta_vigente") else "❌",
            "Verificado RH": "✅" if d.get("verificado_por_rh") else "⏳",
            "Subido": _fmt_fecha(d.get("fecha_subida")),
        } for d in docs])
        st.dataframe(df_docs, hide_index=True, use_container_width=True)
    else:
        st.info("📭 Sin documentos registrados.")

    st.divider()

    # ══════════════════════════════════════════════════════════════════════════
    # SECCIÓN OCR
    # ══════════════════════════════════════════════════════════════════════════
    st.markdown("""
        <div style='background:linear-gradient(90deg,#1e3a5f,#7c3aed);
        padding:10px 18px;border-radius:8px;margin-bottom:14px'>
            <span style='color:white;font-size:1.05rem;font-weight:700'>
                🔍 Leer documento con OCR — Extracción automática de campos
            </span>
        </div>
    """, unsafe_allow_html=True)

    st.caption("Sube la imagen o PDF del documento escaneado. El sistema leerá y extraerá los datos automáticamente.")

    col_tipo, col_fmt = st.columns([3, 1])
    with col_tipo:
        tipo_ocr = st.selectbox(
            "Tipo de documento a escanear",
            TIPOS_DOC,
            key=f"ocr_tipo_{id_emp}"
        )
    with col_fmt:
        fmt_ocr = st.selectbox("Formato", ["JPG", "PNG", "PDF"], key=f"ocr_fmt_{id_emp}")

    archivo_ocr = st.file_uploader(
        "📎 Sube el documento escaneado (imagen o PDF)",
        type=["jpg", "jpeg", "png", "pdf"],
        key=f"ocr_upload_{id_emp}"
    )

    # Botón de lectura OCR
    if archivo_ocr is not None:
        col_btn, col_info = st.columns([2, 3])
        with col_btn:
            leer_btn = st.button(
                "🔍 LEER CON OCR",
                key=f"ocr_leer_{id_emp}",
                type="primary",
                use_container_width=True
            )
        with col_info:
            st.caption(f"📄 Archivo: **{archivo_ocr.name}** ({archivo_ocr.size:,} bytes)")

        if leer_btn:
            with st.spinner("⏳ Procesando documento con OCR... (puede tardar 5-15 segundos)"):
                try:
                    # Convertir archivo a base64
                    img_bytes = archivo_ocr.read()
                    img_b64   = base64.b64encode(img_bytes).decode("utf-8")

                    # Llamar al endpoint OCR
                    status, resp = _post(api_url, "/api/rh/documentos/ocr", {
                        "tipo_documento": tipo_ocr,
                        "imagen_base64": img_b64,
                        "formato": fmt_ocr,
                        "id_empleado": id_emp
                    })

                    if status == 200:
                        st.session_state[f"ocr_resultado_{id_emp}"] = resp
                        st.session_state[f"ocr_tipo_{id_emp}"]      = tipo_ocr
                        st.success(f"✅ OCR completado — {resp.get('total_campos', 0)} campo(s) detectado(s)")
                    else:
                        detalle = resp.get("detail", "Error desconocido")
                        st.error(f"❌ Error OCR: {detalle}")

                except Exception as e:
                    st.error(f"❌ Error de conexión: {e}")

    # ── Panel de revisión de campos extraídos ─────────────────────────────────
    resultado_ocr = st.session_state.get(f"ocr_resultado_{id_emp}")

    if resultado_ocr:
        campos_ext = resultado_ocr.get("campos_extraidos", {})
        conf_global = resultado_ocr.get("confianza_global", 0)
        tipo_doc_leido = st.session_state.get(f"ocr_tipo_{id_emp}", tipo_ocr)

        st.markdown("---")
        st.markdown("""
            <div style='background:#f0fdf4;border:1.5px solid #16a34a;
            border-radius:8px;padding:10px 16px;margin-bottom:10px'>
                <span style='color:#15803d;font-weight:700;font-size:1rem'>
                    ✅ Revisión de datos extraídos — Edita si es necesario y confirma
                </span>
            </div>
        """, unsafe_allow_html=True)

        # Confianza global
        pct = int(conf_global * 100)
        color_conf = "#16a34a" if pct >= 85 else "#d97706" if pct >= 65 else "#dc2626"
        st.markdown(
            f"**Confianza global del OCR:** "
            f"<span style='color:{color_conf};font-weight:700;font-size:1.1rem'>{pct}%</span>",
            unsafe_allow_html=True
        )

        if not campos_ext:
            st.warning("⚠️ No se detectaron campos reconocibles. Verifica que la imagen sea clara y del tipo correcto.")
        else:
            # Mostrar texto crudo del OCR en expander
            with st.expander("🔬 Ver texto bruto detectado por OCR"):
                st.text(resultado_ocr.get("texto_completo", "(vacío)"))

            # Formulario de revisión y edición
            st.markdown("**Campos detectados — edita si hay algún error:**")

            ETIQUETAS = {
                "nombre":           "👤 Nombre completo",
                "curp":             "🪪 CURP",
                "rfc":              "🧾 RFC",
                "nss":              "🏥 NSS (IMSS)",
                "fecha_nacimiento":  "🎂 Fecha de nacimiento",
                "fecha_nac":        "🎂 Fecha de nacimiento",
                "domicilio":        "🏠 Domicilio",
                "cp":               "📮 Código Postal",
                "ciudad":           "🌆 Ciudad",
                "vencimiento":      "📅 Fecha de vencimiento",
                "licencia_vence":   "🚗 Vencimiento licencia",
                "fecha_detectada":  "📅 Fecha detectada",
            }

            CONF_COLORES = {
                "ALTA":  ("#f0fdf4", "#16a34a", "✅ Confianza ALTA"),
                "MEDIA": ("#fffbeb", "#d97706", "⚠️ Confianza MEDIA — revisa"),
                "BAJA":  ("#fef2f2", "#dc2626", "❗ Confianza BAJA — verifica"),
            }

            campos_editados = {}

            for campo, info in campos_ext.items():
                valor     = info.get("valor", "")
                confianza = info.get("confianza", "MEDIA")
                campo_db  = info.get("campo_db", "—")
                bg, border, label_conf = CONF_COLORES.get(confianza, CONF_COLORES["MEDIA"])
                etiqueta = ETIQUETAS.get(campo, campo.replace("_", " ").title())

                st.markdown(
                    f"<div style='background:{bg};border-left:4px solid {border};"
                    f"border-radius:4px;padding:6px 10px;margin-bottom:4px'>"
                    f"<small style='color:{border}'>{label_conf} → <code>{campo_db}</code></small>"
                    f"</div>",
                    unsafe_allow_html=True
                )
                nuevo_valor = st.text_input(
                    etiqueta,
                    value=str(valor),
                    key=f"ocr_campo_{id_emp}_{campo}"
                )
                campos_editados[campo] = nuevo_valor

            st.markdown("---")
            col_conf, col_desc, col_cancel = st.columns([2, 3, 1])

            with col_conf:
                confirmar = st.button(
                    "💾 CONFIRMAR Y GUARDAR EN BD",
                    key=f"ocr_confirmar_{id_emp}",
                    type="primary",
                    use_container_width=True
                )
            with col_desc:
                st.caption(
                    "Al confirmar, los datos se guardarán en la tabla `empleados` "
                    "y en `rh_documentos`. Podrás editar después desde Datos Generales."
                )
            with col_cancel:
                if st.button("✖ Cancelar", key=f"ocr_cancel_{id_emp}", use_container_width=True):
                    del st.session_state[f"ocr_resultado_{id_emp}"]
                    st.rerun()

            if confirmar:
                usuario_actual = st.session_state.get("usuario_actual", "RH")
                status2, resp2 = _post(api_url, "/api/rh/documentos/ocr/confirmar", {
                    "id_empleado": id_emp,
                    "campos": campos_editados,
                    "tipo_documento": tipo_doc_leido,
                    "registrado_por": usuario_actual
                })
                if status2 == 200:
                    guardados = resp2.get("campos_guardados", [])
                    st.success(
                        f"🎉 ¡Datos guardados! Campos actualizados: "
                        f"{', '.join(guardados)}"
                    )
                    # Limpiar estado OCR
                    del st.session_state[f"ocr_resultado_{id_emp}"]
                    # También registrar el documento en rh_documentos
                    _post(api_url, "/api/rh/documentos", {
                        "id_empleado": id_emp,
                        "tipo_documento": tipo_doc_leido,
                        "nombre_archivo": f"{tipo_doc_leido} — leído con OCR",
                        "formato": fmt_ocr,
                        "esta_vigente": True,
                        "verificado_por_rh": True,
                        "observaciones": f"Campos extraídos automáticamente por OCR. Confianza: {pct}%",
                        "subido_por": usuario_actual
                    })
                    st.rerun()
                else:
                    st.error(f"❌ Error al guardar: {resp2.get('detail', 'Error desconocido')}")

    st.divider()

    # ── Formulario de registro manual ─────────────────────────────────────────
    st.markdown("#### ➕ Registrar documento manualmente")
    with st.form("form_documento"):
        col1, col2 = st.columns(2)
        with col1:
            tipo_d    = st.selectbox("Tipo de documento", TIPOS_DOC)
            nombre_d  = st.text_input("Nombre del archivo / descripción")
            formato_d = st.selectbox("Formato", ["PDF", "JPG", "PNG", "DOCX"])
            archivo_d = st.text_input("Ruta/URL del archivo (si aplica)")
        with col2:
            f_emis_d  = st.date_input("Fecha de emisión", value=datetime.date.today())
            f_venc_d  = st.date_input("Fecha de vencimiento (si aplica)",
                value=datetime.date.today() + datetime.timedelta(days=365))
            vigente_d = st.checkbox("¿Documento vigente?", value=True)
            verif_d   = st.checkbox("¿Verificado con el original?", value=False)
        observ_d       = st.text_input("Observaciones")
        usuario_actual = st.session_state.get("usuario_actual", "RH")
        sub_d = st.form_submit_button("💾 Registrar documento", use_container_width=True)

    if sub_d:
        body = {
            "id_empleado": id_emp, "tipo_documento": tipo_d,
            "nombre_archivo": nombre_d, "archivo_url": archivo_d,
            "formato": formato_d, "fecha_emision": str(f_emis_d),
            "fecha_vencimiento": str(f_venc_d),
            "esta_vigente": vigente_d, "verificado_por_rh": verif_d,
            "observaciones": observ_d, "subido_por": usuario_actual
        }
        status, resp = _post(api_url, "/api/rh/documentos", body)
        if status in (200, 201):
            st.success("✅ Documento registrado.")
            st.rerun()
        else:
            st.error(f"❌ {resp.get('detail', 'Error')}")




def _panel_historial(api_url: str, id_emp: str):
    """Timeline completo del empleado."""
    st.markdown("#### 📜 Historial Completo del Empleado")
    historial = _get(api_url, f"/api/rh/historial/{id_emp}") or []

    if historial:
        ICONOS = {
            "CONTRATACIÓN":"🎉","PROMOCIÓN":"⬆️","CAMBIO DEPTO":"🔄",
            "AUMENTO SUELDO":"💰","INCIDENCIA":"⚠️","PERMISO":"📅",
            "INCAPACIDAD":"🏥","VACACIÓN":"🏖️","EVALUACIÓN":"📈",
            "ADVERTENCIA":"🔴","FELICITACIÓN":"⭐","BAJA":"🚪","REINGRESO":"🔁",
            "ACTUALIZACIÓN":"✏️","CONTRATO":"📄","CAPACITACIÓN":"🎓",
        }
        for h in sorted(historial, key=lambda x: x.get("fecha_evento",""), reverse=True):
            tipo = str(h.get("tipo_evento","")).upper()
            icono = ICONOS.get(tipo, "📌")
            auto_tag = "🤖 Sistema" if h.get("es_automatico") else f"👤 {h.get('registrado_por','—')}"
            fecha_str = str(h.get("fecha_evento",""))[:16].replace("T"," ")
            with st.container():
                st.markdown(
                    f"{icono} **{tipo}** — {fecha_str} — {auto_tag}  \n"
                    f"{h.get('descripcion','')}"
                )
                st.divider()
    else:
        st.info("📭 Sin historial registrado aún.")


# ══════════════════════════════════════════════════════════════════════════════
# VISTAS PRINCIPALES DEL MÓDULO
# ══════════════════════════════════════════════════════════════════════════════

def _vista_alertas(api_url: str):
    """Muestra alertas del sistema de RH."""
    alertas = _get(api_url, "/api/rh/alertas") or []
    if not alertas:
        st.success("✅ Sin alertas activas en este momento.")
        return
    for a in alertas:
        urgencia = a.get("urgencia","MEDIA")
        if urgencia == "ALTA":
            st.error(f"🔴 **{a.get('tipo','')}** — {a.get('empleado','')} — {a.get('mensaje','')}")
        else:
            st.warning(f"🟡 **{a.get('tipo','')}** — {a.get('empleado','')} — {a.get('mensaje','')}")


def _vista_calendario_vacaciones(api_url: str):
    """Vista global del calendario de vacaciones."""
    st.markdown("#### 🗓️ Calendario de Vacaciones — Equipo VPRO")
    cal = _get(api_url, "/api/rh/vacaciones/calendario") or []
    if cal:
        df_cal = pd.DataFrame([{
            "Empleado": v.get("nombre_empleado","—"),
            "Departamento": v.get("depto","—"),
            "Inicio": _fmt_fecha(v.get("fecha_inicio_goce")),
            "Fin": _fmt_fecha(v.get("fecha_fin_goce")),
            "Días": v.get("dias_correspondientes","—"),
            "Estatus": v.get("estatus","—"),
            "Admon. notif.": "✅" if v.get("notificado_admon") else "⏳",
        } for v in cal])
        st.dataframe(df_cal, hide_index=True, use_container_width=True)
    else:
        st.info("📭 Sin vacaciones programadas.")


def _vista_bandeja_permisos(api_url: str):
    """Bandeja de permisos pendientes de aprobación."""
    st.markdown("#### 📥 Bandeja de Permisos Pendientes")
    permisos = _get(api_url, "/api/rh/permisos", {"estatus": "PENDIENTE"}) or []
    if permisos:
        for p in permisos:
            with st.expander(
                f"⏳ {p.get('folio_permiso','—')} — {p.get('nombre_empleado','—')} — "
                f"{p.get('tipo_permiso','—')} — {_fmt_fecha(p.get('fecha_inicio'))} al {_fmt_fecha(p.get('fecha_fin'))}"
            ):
                st.write(f"**Justificación:** {p.get('justificacion','—')}")
                st.write(f"**Días:** {p.get('dias_solicitados','—')} | **Goce:** {'Sí' if p.get('con_goce_de_sueldo') else 'No'}")
                colA, colB = st.columns(2)
                usuario_actual = st.session_state.get("usuario_nombre","RH")
                if colA.button("✅ Aprobar", key=f"ap_{p['id_permiso']}"):
                    _put(api_url, f"/api/rh/permisos/{p['id_permiso']}",
                        {"estatus":"APROBADO","aprobado_por":usuario_actual,
                         "fecha_aprobacion":str(datetime.date.today())})
                    st.rerun()
                if colB.button("❌ Rechazar", key=f"re_{p['id_permiso']}"):
                    _put(api_url, f"/api/rh/permisos/{p['id_permiso']}",
                        {"estatus":"RECHAZADO","aprobado_por":usuario_actual})
                    st.rerun()
    else:
        st.success("✅ Sin permisos pendientes.")


def _vista_solicitudes_externas(api_url: str):
    """Lista de solicitudes de empleo externas."""
    st.markdown("#### 📝 Solicitudes de Empleo")
    filtro_e = st.selectbox("Filtrar por estatus",
        ["TODAS","RECIBIDA","EN REVISIÓN","ENTREVISTA","APROBADA","RECHAZADA"])
    params = {} if filtro_e == "TODAS" else {"estatus": filtro_e}
    solicitudes = _get(api_url, "/api/rh/solicitudes", params) or []

    if solicitudes:
        df_sol = pd.DataFrame([{
            "Folio": s.get("folio","—"),
            "Fecha": _fmt_fecha(s.get("fecha_solicitud")),
            "Nombre": s.get("nombre_completo","—"),
            "Puesto": s.get("puesto_solicitado","—"),
            "Dept.": s.get("depto_solicitado","—"),
            "Pretensión": f"${s.get('pretension_salarial',0):,.0f}",
            "Estatus": s.get("estatus","—"),
        } for s in solicitudes])
        st.dataframe(df_sol, hide_index=True, use_container_width=True)
    else:
        st.info("📭 Sin solicitudes.")


# ══════════════════════════════════════════════════════════════════════════════
# FUNCIÓN PRINCIPAL DEL MÓDULO (Entry point desde app_main_prueba.py)
# ══════════════════════════════════════════════════════════════════════════════

def renderizar_modulo(API_URL: str, submodulo: str = "🔍 Expediente de Empleado",
                      fotos_personal_dir: str = "Fotos_de_personal"):
    """Punto de entrada principal del módulo de Recursos Humanos.
    
    Args:
        API_URL: URL base del backend.
        submodulo: Opción activa del sub-menú RH (viene desde app_main_prueba.py).
        fotos_personal_dir: Ruta al directorio de fotos de personal.
    """
    import base64
    from pathlib import Path

    st.markdown("""
        <div style='background:linear-gradient(90deg,#1e3a5f,#2563eb);
        padding:14px 22px;border-radius:10px;margin-bottom:16px'>
            <span style='color:white;font-size:1.4rem;font-weight:700'>👥 Recursos Humanos</span>
            <span style='color:#93c5fd;font-size:0.95rem;margin-left:12px'>Expediente Digital VPRO</span>
        </div>
    """, unsafe_allow_html=True)

    # ── Panel de alertas compacto ──────────────────────────────────────────
    alertas = _get(API_URL, "/api/rh/alertas") or []
    altas   = [a for a in alertas if a.get("urgencia") == "ALTA"]
    medias  = [a for a in alertas if a.get("urgencia") == "MEDIA"]
    if altas:
        st.error(f"🔴 **{len(altas)} alerta(s) urgentes** — selecciona ↳ Alertas del Sistema")
    if medias:
        st.warning(f"🟡 **{len(medias)} alerta(s) de atención** — selecciona ↳ Alertas del Sistema")

    # ── Helper: cargar foto del empleado ──────────────────────────────────
    def _cargar_foto_empleado(emp_data: dict) -> str | None:
        """
        Intenta cargar la foto del empleado desde:
          1. foto_url (ruta local en Fotos_de_personal/)
          2. Fotos_de_personal/{id_empleado}.jpg / .png / .jpeg
        Retorna data-URI base64 o None si no existe.
        """
        id_emp = emp_data.get("id_empleado", "")
        foto_url = emp_data.get("foto_url", "") or ""

        candidatos = []

        # a) Ruta guardada en la BD
        if foto_url.strip():
            candidatos.append(Path(foto_url))
            # También relativo a fotos_personal_dir
            candidatos.append(Path(fotos_personal_dir) / foto_url.strip())

        # b) Por ID del empleado con extensiones comunes
        for ext in [".jpg", ".jpeg", ".png", ".webp"]:
            candidatos.append(Path(fotos_personal_dir) / f"{id_emp}{ext}")
            candidatos.append(Path(fotos_personal_dir) / f"{id_emp.zfill(3)}{ext}")

        for ruta in candidatos:
            try:
                if ruta.exists() and ruta.stat().st_size > 0:
                    ext = ruta.suffix.lower().lstrip(".")
                    mime = "jpeg" if ext in ("jpg", "jpeg") else ext
                    data = base64.b64encode(ruta.read_bytes()).decode("utf-8")
                    return f"data:image/{mime};base64,{data}"
            except Exception:
                continue
        return None

    # ══════════════════════════════════════════════════════════════════════
    # NAV: el sub-menú ahora viene del sidebar principal (app_main_prueba.py)
    # Se limpia el prefijo " ↳ " si viene con él
    nav = submodulo.strip().lstrip("↳").strip()

    # ══════════════════════════════════════════════════════════════════════
    if nav == "🔍 Expediente de Empleado":
        # Cargar lista de empleados
        empleados_list = _get(API_URL, "/api/rh/empleados") or []
        if not empleados_list:
            st.error("❌ No se pudo cargar la lista de empleados.")
            return

        # ── Filtro de Activos / Inactivos ──────────────────────────────────
        mostrar_inactivos = st.toggle("👁️ Mostrar todo el personal (incluir bajas y otros roles)", value=False)
        
        roles_activos = ["ADMIN", "PRODUCCION", "COORDINADOR"]
        if mostrar_inactivos:
            empleados_filtrados = empleados_list
        else:
            empleados_filtrados = [
                e for e in empleados_list
                if e.get("rol") in roles_activos and e.get("estatus_empleado") != "BAJA"
            ]

        if not empleados_filtrados:
            st.warning("No hay empleados activos con rol ADMIN, PRODUCCION o COORDINADOR. Activa el botón 'Mostrar todo el personal'.")
            return

        opciones_emp = {
            f"{e.get('nombre','—')} (ID: {e.get('id_empleado','—')}) — {e.get('depto','—')}": e.get("id_empleado")
            for e in sorted(empleados_filtrados, key=lambda x: x.get("nombre",""))
        }

        # Revisar si hay un empleado preseleccionado desde el módulo ABC
        id_presel = st.session_state.get("rh_emp_presel_id")
        idx_default = 0
        claves = list(opciones_emp.keys())
        if id_presel:
            for i, clave in enumerate(claves):
                if opciones_emp[clave] == id_presel:
                    idx_default = i
                    break
            # Limpiar el session state para que no se quede pegado
            st.session_state.pop("rh_emp_presel_id", None)

        seleccion = st.selectbox(
            "🔍 Buscar empleado (por nombre, ID o departamento)",
            claves,
            index=idx_default,
            key="rh_emp_sel"
        )
        id_emp_sel = opciones_emp[seleccion]

        # Cargar expediente completo
        expediente = _get(API_URL, f"/api/rh/expediente/{id_emp_sel}") or {}
        emp = expediente.get("datos_personales") or \
              next((e for e in empleados_list if e.get("id_empleado") == id_emp_sel), {})

        # ── Tarjeta de cabecera del empleado ──────────────────────────────
        anios_trab  = _anios_trabajados(emp.get("fecha_ing"))
        edad_emp    = _edad(emp.get("fecha_nac"))
        estatus_emp = emp.get("estatus_empleado","ACTIVO") or "ACTIVO"
        color_est   = _color_estatus(estatus_emp)

        with st.container(border=True):
            col_foto, col_info = st.columns([1, 4])
            with col_foto:
                foto_b64 = _cargar_foto_empleado(emp)
                if foto_b64:
                    st.markdown(
                        f"<img src='{foto_b64}' "
                        f"style='width:110px;height:110px;object-fit:cover;"
                        f"border-radius:50%;border:3px solid #2563eb;"
                        f"display:block;margin:auto'>",
                        unsafe_allow_html=True
                    )
                else:
                    # Silhouette SVG con las iniciales del empleado
                    nombre_emp = emp.get("nombre","?")
                    iniciales  = "".join(p[0].upper() for p in nombre_emp.split()[:2])
                    st.markdown(
                        f"<div style='width:110px;height:110px;border-radius:50%;"
                        f"background:linear-gradient(135deg,#2563eb,#7c3aed);"
                        f"display:flex;align-items:center;justify-content:center;"
                        f"margin:auto;border:3px solid #93c5fd'>"
                        f"<span style='color:white;font-size:2rem;font-weight:700'>{iniciales}</span>"
                        f"</div>",
                        unsafe_allow_html=True
                    )
            with col_info:
                st.markdown(
                    f"### {emp.get('nombre','—')}  "
                    f"{_badge(estatus_emp, color_est)}",
                    unsafe_allow_html=True
                )
                c1, c2, c3, c4, c5 = st.columns(5)
                c1.metric("ID", emp.get("id_empleado","—"))
                c2.metric("Puesto", emp.get("puesto","—") or emp.get("depto","—"))
                c3.metric("Antigüedad", f"{anios_trab} años")
                c4.metric("Edad", f"{edad_emp} años")
                c5.metric("Ingreso", _fmt_fecha(emp.get("fecha_ing")))

        # ── Pestañas del expediente ────────────────────────────────────────
        pestanas = st.tabs([
            "📋 Datos Generales",
            "📝 Solicitud",
            "🤝 Entrevistas",
            "📄 Contratos",
            "🏖️ Vacaciones",
            "📅 Permisos",
            "🏥 Incapacidades",
            "🎓 Capacitación",
            "📈 Evaluaciones",
            "📂 Documentos",
            "📜 Historial",
        ])

        with pestanas[0]:
            _panel_datos_generales(API_URL, emp, id_emp_sel)
        with pestanas[1]:
            _panel_solicitud_empleo(API_URL, id_emp_sel)
        with pestanas[2]:
            _panel_entrevistas(API_URL, id_emp_sel)
        with pestanas[3]:
            _panel_contratos(API_URL, id_emp_sel)
        with pestanas[4]:
            _panel_vacaciones(API_URL, id_emp_sel, emp)
        with pestanas[5]:
            _panel_permisos(API_URL, id_emp_sel)
        with pestanas[6]:
            _panel_incapacidades(API_URL, id_emp_sel)
        with pestanas[7]:
            _panel_capacitacion(API_URL, id_emp_sel)
        with pestanas[8]:
            _panel_evaluaciones(API_URL, id_emp_sel)
        with pestanas[9]:
            _panel_documentos(API_URL, id_emp_sel)
        with pestanas[10]:
            _panel_historial(API_URL, id_emp_sel)

    # ══════════════════════════════════════════════════════════════════════
    elif nav == "📝 Solicitudes de Empleo":
        _vista_solicitudes_externas(API_URL)

    elif nav == "🏖️ Calendario de Vacaciones":
        _vista_calendario_vacaciones(API_URL)

    elif nav == "📥 Bandeja de Permisos":
        _vista_bandeja_permisos(API_URL)

    elif nav == "⚠️ Alertas del Sistema":
        _vista_alertas(API_URL)

    elif nav == "📖 Guía de Registro RH":
        _manual_rh()

    else:
        # Vista por defecto: expediente
        _vista_alertas(API_URL)


def _manual_rh():
    """Manual de trazabilidad del módulo de Recursos Humanos VPRO."""

    # ── Encabezado ─────────────────────────────────────────────────────────
    st.markdown("""
        <div style='background:linear-gradient(135deg,#1e3a5f,#7c3aed);
        padding:20px 28px;border-radius:12px;margin-bottom:20px'>
            <h2 style='color:white;margin:0;font-size:1.6rem'>
                📖 Guía de Registro y Trazabilidad — Recursos Humanos VPRO
            </h2>
            <p style='color:#c4b5fd;margin:6px 0 0 0;font-size:0.95rem'>
                Manual operativo para el Departamento de Recursos Humanos
            </p>
        </div>
    """, unsafe_allow_html=True)

    st.info(
        "**¿Para qué sirve esta guía?**  \n"
        "Esta guía te explica paso a paso cómo registrar correctamente a un empleado "
        "en el sistema VPRO, desde que es candidato hasta su baja, garantizando que "
        "el **historial quede completo y trazable** en todo momento."
    )

    # ── Índice rápido ──────────────────────────────────────────────────────
    st.markdown("---")
    st.markdown("### 📋 Índice de Pasos")

    pasos_indice = [
        ("1", "📝", "Solicitud de Empleo",         "Registro del candidato externo"),
        ("2", "🤝", "Entrevistas",                  "Calificación y selección"),
        ("3", "👤", "Alta del Empleado",             "Crear ficha + datos generales"),
        ("4", "📄", "Contrato",                      "Registro del contrato firmado"),
        ("5", "📂", "Documentos (con OCR)",           "Escanear y capturar documentos"),
        ("6", "🏖️", "Vacaciones",                    "Registro de periodo de goce"),
        ("7", "📅", "Permisos y Ausencias",           "Solicitudes y autorizaciones"),
        ("8", "🏥", "Incapacidades",                  "Registro IMSS / médico"),
        ("9", "🎓", "Capacitación",                   "Cursos y constancias"),
        ("10","📈", "Evaluaciones de Desempeño",      "Calificación periódica"),
        ("11","📜", "Historial",                      "Consulta de trazabilidad completa"),
        ("12","🚪", "Baja del Empleado",              "Proceso de salida"),
    ]

    cols = st.columns(3)
    for i, (num, icon, titulo, desc) in enumerate(pasos_indice):
        with cols[i % 3]:
            st.markdown(
                f"<div style='background:#f8fafc;border:1px solid #e2e8f0;"
                f"border-radius:8px;padding:10px 14px;margin-bottom:8px'>"
                f"<span style='color:#6b7280;font-size:0.75rem;font-weight:600'>PASO {num}</span><br>"
                f"<span style='font-size:1.1rem'>{icon}</span> "
                f"<b style='color:#0f172a'>{titulo}</b><br>"
                f"<small style='color:#64748b'>{desc}</small>"
                f"</div>",
                unsafe_allow_html=True
            )

    st.markdown("---")

    # ══════════════════════════════════════════════════════════════════════
    # PASOS DETALLADOS EN ACORDEÓN
    # ══════════════════════════════════════════════════════════════════════

    # ── PASO 1 ─────────────────────────────────────────────────────────────
    with st.expander("📝 PASO 1 — Solicitud de Empleo (candidato externo)", expanded=False):
        st.markdown("""
**¿Cuándo se usa?**
Cuando llega un candidato externo que solicita un puesto en la empresa.

**Dónde hacerlo:** Menú lateral → **📝 Solicitudes de Empleo**

**Campos obligatorios a capturar:**
| Campo | Descripción |
|---|---|
| Nombre completo | Nombre del candidato tal como aparece en su INE |
| Puesto solicitado | El cargo al que aplica |
| Pretensión salarial | Salario que pide el candidato |
| Escolaridad | Nivel máximo de estudios |
| Disponibilidad | Si puede incorporarse de inmediato |

**Resultado:** El sistema genera automáticamente un **Folio** `SOL-AAAA-NNN` y registra el estatus `RECIBIDA`.

> ⚠️ **Importante:** Cambia el estatus a `EN REVISIÓN` cuando RH empiece a evaluar la solicitud.
        """)
        st.markdown("""
**Flujo de estatus de la solicitud:**
```
RECIBIDA → EN REVISIÓN → ENTREVISTA → APROBADA / RECHAZADA
```
        """)

    # ── PASO 2 ─────────────────────────────────────────────────────────────
    with st.expander("🤝 PASO 2 — Entrevistas", expanded=False):
        st.markdown("""
**¿Cuándo se usa?**
Después de revisar la solicitud. Se pueden agregar **N entrevistas** por candidato (igual que las reuniones en las OPs).

**Dónde hacerlo:** Expediente del empleado (o de la solicitud) → pestaña **🤝 Entrevistas**

**Tipos de entrevista disponibles:**
- `INICIAL` — Primera llamada o filtro rápido
- `TÉCNICA` — Prueba de conocimientos del área
- `RH` — Entrevista formal con Recursos Humanos
- `PSICOMÉTRICA` — Prueba de personalidad / habilidades
- `FINAL` — Entrevista de cierre con dirección

**Criterios de calificación (0–10 cada uno):**
| Criterio | ¿Qué mide? |
|---|---|
| Puntualidad | Si llegó a tiempo a la entrevista |
| Presentación | Aspecto personal y profesionalismo |
| Conocimientos técnicos | Dominio del área solicitada |
| Actitud | Disposición y motivación |
| Comunicación | Claridad al expresarse |

> ✅ El sistema calcula automáticamente la **calificación general** como promedio de los 5 criterios.

**Resultado en el historial:** Cada entrevista genera un registro en `📜 Historial` automáticamente.
        """)

    # ── PASO 3 ─────────────────────────────────────────────────────────────
    with st.expander("👤 PASO 3 — Alta del Empleado (Datos Generales)", expanded=False):
        st.markdown("""
**¿Cuándo se usa?**
Cuando el candidato es aprobado y se va a contratar. Se da de alta en el sistema.

**Dónde hacerlo:** Expediente → pestaña **📋 Datos Generales**

**Datos personales a completar:**
""")
        col1, col2 = st.columns(2)
        with col1:
            st.markdown("""
**Identificación:**
- RFC (13 caracteres)
- CURP (18 caracteres)
- NSS — Número de Seguro Social IMSS (11 dígitos)
- Estado civil

**Contacto:**
- Correo corporativo
- Celular
- Domicilio completo
- Ciudad y Código Postal
            """)
        with col2:
            st.markdown("""
**Laboral:**
- Puesto / Cargo formal
- Departamento
- Tipo de contrato
- Salario mensual bruto
- Escolaridad

**Emergencias:**
- Nombre del contacto de emergencia
- Teléfono de emergencia
- Parentesco
            """)

        st.warning(
            "💡 **Consejo OCR:** Muchos de estos campos se pueden llenar automáticamente "
            "escaneando los documentos del empleado. Ve a la pestaña **📂 Documentos** "
            "y usa el lector OCR para el INE, CURP, RFC y NSS."
        )
        st.markdown("""
> ✅ **Estatus del empleado:** Asegúrate de que quede en `ACTIVO` al dar de alta.  
> El sistema registra en el **historial** la fecha exacta de contratación.
        """)

    # ── PASO 4 ─────────────────────────────────────────────────────────────
    with st.expander("📄 PASO 4 — Contrato", expanded=False):
        st.markdown("""
**¿Cuándo se usa?**
Inmediatamente después del alta. Se registra el contrato firmado.

**Dónde hacerlo:** Expediente → pestaña **📄 Contratos**

**Tipos de contrato:**
| Tipo | Descripción |
|---|---|
| `PLANTA` | Contrato indefinido de base |
| `EVENTUAL` | Contrato por tiempo determinado |
| `PROYECTO` | Para una producción específica |
| `HONORARIOS` | Sin relación laboral formal |
| `PRUEBA 90 DÍAS` | Período de evaluación inicial |

**Campos clave:**
- **Fecha inicio** — Primer día de trabajo
- **Fecha fin** — Dejar vacío si es indefinido (marcar "¿Contrato indefinido?")
- **Salario mensual bruto** — Debe coincidir con lo acordado
- **Días de vacaciones anuales** — Según LFT: 12 días para el primer año
- **Horario** — Ej: "Lunes–Viernes 09:00–19:00"

> ⚠️ **Importante:** Marca `✅ Firmó el empleado` y `✅ Firmó la empresa` solo cuando tengas el contrato físicamente firmado.

**Alertas automáticas del sistema:**
- El sistema alertará cuando el contrato esté a **30 días de vencer**.
- El historial registrará la fecha de cada contrato y renovación.
        """)

    # ── PASO 5 ─────────────────────────────────────────────────────────────
    with st.expander("📂 PASO 5 — Documentos (con Lectura OCR)", expanded=False):
        st.markdown("""
**¿Cuándo se usa?**
Al dar de alta al empleado, para digitalizar y archivar sus documentos oficiales.

**Dónde hacerlo:** Expediente → pestaña **📂 Documentos**

**Documentos prioritarios para el expediente:**
| # | Documento | ¿Se puede leer con OCR? | Campos que extrae |
|---|---|---|---|
| 1 | 🪪 INE | ✅ Sí | Nombre, CURP, Domicilio, Fecha nac., Vencimiento |
| 2 | 📋 CURP | ✅ Sí | CURP completo, Nombre, Fecha nac. |
| 3 | 🏥 NSS | ✅ Sí | Número de Seguro Social, Nombre |
| 4 | 🧾 RFC | ✅ Sí | RFC, Nombre, Domicilio fiscal, CP |
| 5 | 📜 Acta Nacimiento | ✅ Sí | Nombre, Fecha nac., Ciudad |
| 6 | 🚗 Licencia Conducir | ✅ Sí | Nombre, CURP, Vencimiento |
| 7 | 🏠 Comprobante Domicilio | ✅ Sí | Nombre, Domicilio, CP |
| 8 | 🎓 Título / Cédula | ❌ Manual | Solo registro |
| 9 | 📸 Foto | ❌ Manual | Solo imagen |

**Cómo usar el OCR paso a paso:**
        """)
        st.markdown("""
```
1. Selecciona el Tipo de documento (ej: INE)
2. Selecciona el Formato (JPG, PNG o PDF)
3. Sube la imagen escaneada del documento
4. Presiona [🔍 LEER CON OCR]
   → El sistema procesa en 5-15 segundos
5. Revisa los campos detectados:
   ✅ Verde = Alta confianza (verificar rápido)
   ⚠️ Amarillo = Confianza media (revisa con cuidado)
   ❗ Rojo = Confianza baja (corregir manualmente)
6. Edita cualquier campo que sea incorrecto
7. Presiona [💾 CONFIRMAR Y GUARDAR EN BD]
   → Los datos se guardan en la tabla de empleados
   → El documento queda registrado en el repositorio
   → El historial registra la actualización OCR
```
        """)
        st.success(
            "💡 **Tip:** Escanea primero el **INE** — es el documento que más campos "
            "llena automáticamente (nombre, CURP, domicilio, fecha de nacimiento)."
        )
        st.warning(
            "⚠️ **Calidad del escaneo:** Para mejores resultados, escanea a **300 DPI** "
            "mínimo. Si usas cámara de celular, asegúrate de que el documento esté bien "
            "iluminado y sin sombras. La primera lectura descargará el modelo de IA (~100 MB)."
        )

    # ── PASO 6 ─────────────────────────────────────────────────────────────
    with st.expander("🏖️ PASO 6 — Vacaciones", expanded=False):
        st.markdown("""
**¿Cuándo se usa?**
Cuando el empleado solicita su período de vacaciones o cuando se programa el calendario anual.

**Dónde hacerlo:** Expediente → pestaña **🏖️ Vacaciones**

**¿Cuántos días corresponden según la LFT?**
| Años de antigüedad | Días de vacaciones |
|---|---|
| 1 año | **12 días** |
| 2 años | **14 días** |
| 3 años | **16 días** |
| 4 años | **18 días** |
| 5 a 9 años | **20 días** |
| 10 a 14 años | **22 días** |
| 15 a 19 años | **24 días** |
| 20 a 24 años | **26 días** |
| 25 a 29 años | **28 días** |

> ⚡ El sistema calcula los días automáticamente basándose en la **fecha de ingreso**.

**Proceso de registro:**
1. El sistema muestra los **días disponibles** automáticamente
2. Selecciona el **periodo de goce** (inicio y fin)
3. Ingresa la **fecha límite LFT** (6 meses después del aniversario laboral)
4. Cambia el estatus a `APROBADA` cuando RH autorice
5. Marca **"¿Administración notificada?"** para que Admon quede informada con anticipación

**Alertas automáticas:**
- 🟡 Si quedan **≤ 60 días** para que venzan y no se han disfrutado
        """)

    # ── PASO 7 ─────────────────────────────────────────────────────────────
    with st.expander("📅 PASO 7 — Permisos y Ausencias", expanded=False):
        st.markdown("""
**¿Cuándo se usa?**
Cuando un empleado solicita ausentarse por cualquier motivo justificado.

**Dónde hacerlo:** Expediente → pestaña **📅 Permisos** O desde **📥 Bandeja de Permisos**

**Tipos de permiso:**
| Tipo | Ejemplo | ¿Con goce? |
|---|---|---|
| `PERSONAL` | Trámites bancarios, personales | Según política |
| `MÉDICO` | Cita médica, estudios | Sí |
| `FAMILIAR` | Enfermedad de familiar | Según días |
| `LUTO` | Fallecimiento de familiar | Sí (3 días LFT) |
| `PATERNIDAD` | Nacimiento de hijo | Sí (5 días LFT) |
| `MATERNIDAD` | Embarazo / parto | Sí (84 días LFT) |
| `ESTUDIO` | Exámenes, titulación | Sin goce (general) |

**Proceso de autorización:**
```
Empleado / RH registra solicitud → PENDIENTE
         ↓
RH o coordinador revisa
         ↓
[✅ Aprobar]  →  APROBADO  →  Se marca en Asistencia como "PERMISO"
[❌ Rechazar] →  RECHAZADO →  Motivo queda registrado
```

> ⚠️ Si marcas **"Impacta en asistencia"**, el sistema registrará automáticamente los días 
> como `PERMISO` en el control de asistencia. Esto evita que aparezcan como faltas.
        """)

    # ── PASO 8 ─────────────────────────────────────────────────────────────
    with st.expander("🏥 PASO 8 — Incapacidades", expanded=False):
        st.markdown("""
**¿Cuándo se usa?**
Cuando el empleado presenta un certificado médico de incapacidad del IMSS o médico particular.

**Dónde hacerlo:** Expediente → pestaña **🏥 Incapacidades**

**Tipos de incapacidad:**
| Tipo | % que paga IMSS | Observación |
|---|---|---|
| `ENFERMEDAD GENERAL` | **60%** del salario diario | A partir del 4° día |
| `RIESGO DE TRABAJO` | **100%** desde el 1er día | Accidente en el trabajo |
| `MATERNIDAD` | **100%** | 84 días (42 antes + 42 después) |
| `PATERNIDAD` | Variable | Según IMSS |

**Campos a registrar:**
- **Fecha inicio y fin** (el sistema calcula días automáticamente)
- **Número de incapacidad IMSS** (aparece en el documento oficial)
- **Médico tratante / Clínica**
- **Porcentaje de pago IMSS** (ver tabla arriba)
- Adjuntar el **certificado escaneado** en el repositorio de documentos

> ✅ Marca **"¿Validado por RH?"** solo cuando hayas revisado físicamente el documento original con el sello del IMSS.

**El folio** se genera automáticamente: `INC-AAAA-NNN`
        """)

    # ── PASO 9 ─────────────────────────────────────────────────────────────
    with st.expander("🎓 PASO 9 — Capacitación y Cursos", expanded=False):
        st.markdown("""
**¿Cuándo se usa?**
Cada vez que el empleado toma un curso, taller, certificación o capacitación, ya sea pagada por la empresa o personal.

**Dónde hacerlo:** Expediente → pestaña **🎓 Capacitación**

**Tipos de capacitación:**
| Tipo | Descripción |
|---|---|
| `INTERNA` | Impartida dentro de la empresa |
| `EXTERNA` | Curso con proveedor externo |
| `EN LÍNEA` | Plataforma digital (Udemy, Coursera, etc.) |
| `CERTIFICACIÓN` | Con validez oficial (IFT, SEP, etc.) |

**Campos importantes:**
- **Nombre del curso** — Exactamente como aparece en la constancia
- **Institución / Proveedor** — Quién impartió el curso
- **Horas de duración** — Total de horas académicas
- **Resultado** — APROBADO / REPROBADO / EN CURSO
- **¿Tiene constancia?** — Marcar si se obtuvo certificado
- **Costo** — Si fue pagado, registrar el monto
- **¿Lo pagó la empresa?** — Para control de inversión en capacitación

> 💡 Este historial permite demostrar que la empresa cumple con la obligación de capacitación **LFT Art. 132** (mínimo 40 horas anuales por empleado).
        """)

    # ── PASO 10 ────────────────────────────────────────────────────────────
    with st.expander("📈 PASO 10 — Evaluaciones de Desempeño", expanded=False):
        st.markdown("""
**¿Cuándo se usa?**
Periódicamente para medir el desempeño y detectar áreas de mejora. Se recomienda:
- Al terminar el **período de prueba** (90 días)
- **Semestral** (cada 6 meses)
- **Anual** (cierre de año)

**Dónde hacerlo:** Expediente → pestaña **📈 Evaluaciones**

**Rúbrica de calificación (0–10 por criterio):**
| Criterio | ¿Qué evalúa? |
|---|---|
| Puntualidad | Cumplimiento de horarios |
| Calidad del trabajo | Resultados y precisión |
| Trabajo en equipo | Colaboración con colegas |
| Responsabilidad | Cumplimiento de compromisos |
| Iniciativa | Propuestas y proactividad |
| Comunicación | Claridad y efectividad |
| Cumplimiento de objetivos | Metas logradas en el periodo |

**Niveles de desempeño automáticos (calificación final):**
| Calificación | Nivel |
|---|---|
| 9.0 – 10.0 | ⭐ EXCELENTE |
| 7.0 – 8.9 | ✅ BUENO |
| 5.0 – 6.9 | ⚠️ REGULAR |
| 0.0 – 4.9 | ❌ DEFICIENTE |

> ✅ Asegúrate de registrar el **Plan de Acción** cuando la calificación sea REGULAR o DEFICIENTE.
> El empleado debe **firmar de enterado** — marca la casilla correspondiente.
        """)

    # ── PASO 11 ────────────────────────────────────────────────────────────
    with st.expander("📜 PASO 11 — Consulta del Historial (Trazabilidad)", expanded=False):
        st.markdown("""
**¿Para qué sirve?**
El historial es el **registro inmutable** de TODO lo que ha ocurrido con el empleado desde su registro hasta la fecha. Ningún registro se puede borrar.

**Dónde consultarlo:** Expediente → pestaña **📜 Historial**

**¿Qué eventos quedan registrados automáticamente?**
| Ícono | Evento | Se genera cuando... |
|---|---|---|
| 🎉 | CONTRATACIÓN | Se da de alta al empleado |
| 📄 | CONTRATO | Se registra un contrato |
| ✏️ | ACTUALIZACIÓN | Se modifican datos del empleado |
| 📷 | OCR | Se leen documentos con OCR |
| 🏖️ | VACACIÓN | Se registra un periodo de vacaciones |
| 📅 | PERMISO | Se aprueba o rechaza un permiso |
| 🏥 | INCAPACIDAD | Se registra una incapacidad |
| 🎓 | CAPACITACIÓN | Se registra un curso |
| 📈 | EVALUACIÓN | Se realiza una evaluación de desempeño |
| ⬆️ | PROMOCIÓN | Se actualiza el puesto o salario |
| 🚪 | BAJA | Se da de baja al empleado |

**Diferencia entre eventos automáticos y manuales:**
- 🤖 **Sistema** — El propio sistema lo registró al hacer una acción
- 👤 **Usuario (nombre)** — Un usuario de RH lo registró manualmente

> 🔍 **Para auditorías o revisiones legales:** Este historial constituye la evidencia digital del expediente completo del empleado.
        """)

    # ── PASO 12 ────────────────────────────────────────────────────────────
    with st.expander("🚪 PASO 12 — Baja del Empleado", expanded=False):
        st.markdown("""
**¿Cuándo se usa?**
Cuando un empleado termina su relación laboral con la empresa.

**Dónde hacerlo:** Expediente → pestaña **📋 Datos Generales**

**Proceso de baja:**
1. Cambiar **Estatus del empleado** a `BAJA`
2. Registrar la **Fecha de baja** (último día laborado)
3. Registrar el **Motivo de baja**:

| Motivo de baja | Descripción |
|---|---|
| Renuncia voluntaria | El empleado presentó su renuncia |
| Rescisión por empresa | La empresa da por terminada la relación |
| Fin de contrato | El contrato llegó a su fecha de vencimiento |
| Mutuo acuerdo | Finiquito negociado |
| Abandono de empleo | 3 días de falta injustificada |
| Fallecimiento | Defunción del trabajador |

4. Cambiar el **Estatus del contrato** a `VENCIDO` o `CANCELADO`
5. En **📂 Documentos**, archivar: carta de renuncia, finiquito firmado, carta de recomendación

> ⚠️ **Importante:** El empleado con estatus `BAJA` **no aparecerá** en el Checador ni en las OPs. El historial de toda su trayectoria queda preservado.

**El sistema registra automáticamente en el historial:**
```
🚪 BAJA — [fecha] — 👤 [usuario RH]
Empleado dado de baja. Motivo: [motivo registrado]
```
        """)

    st.markdown("---")

    # ── Diagrama de flujo general ──────────────────────────────────────────
    st.markdown("### 🔄 Flujo Completo de Trazabilidad RH")
    st.markdown("""
```
📝 Solicitud de Empleo (SOL-AAAA-NNN)
    ↓
🤝 Entrevistas (1 o más rondas con calificación)
    ↓
👤 Alta del Empleado (Datos Generales + RFC, CURP, NSS)
    ↓
📄 Contrato (CTR-AAAA-NNN + firmas)
    ↓
📂 Documentos (OCR automático: INE, CURP, NSS, RFC...)
    ↓
╔══════════════════════════════════════════╗
║      VIDA LABORAL ACTIVA DEL EMPLEADO   ║
╠═══════════════════╦══════════════════════╣
║ 🏖️ Vacaciones     ║ 📈 Evaluaciones      ║
║ 📅 Permisos       ║ 🎓 Capacitación      ║
║ 🏥 Incapacidades  ║ ⬆️ Cambios de puesto ║
╚═══════════════════╩══════════════════════╝
    ↓
📜 Historial (trazabilidad inmutable de todo)
    ↓
🚪 Baja (con motivo + documentos de finiquito)
```
    """)

    # ── Alertas automáticas del sistema ───────────────────────────────────
    st.markdown("---")
    st.markdown("### ⚠️ Alertas Automáticas del Sistema")
    st.markdown("""
El sistema genera alertas visibles en la pantalla de inicio cuando detecta:

| Ícono | Alerta | Condición |
|---|---|---|
| 🔴 | Contrato urgente por vencer | Vence en ≤ 30 días |
| 🔴 | Vacaciones por caducar | Límite LFT en ≤ 60 días |
| 🟡 | Licencia de conducir por vencer | Vence en ≤ 30 días |
| 🔵 | Evaluación pendiente | No hay evaluación en el año actual |
| 🏥 | Empleado en incapacidad | Incapacidad activa |
| 📅 | Permiso activo | Permiso aprobado vigente |
    """)

    # ── Preguntas frecuentes ───────────────────────────────────────────────
    st.markdown("---")
    st.markdown("### ❓ Preguntas Frecuentes")

    with st.expander("¿Puedo modificar datos del empleado después de guardados?"):
        st.markdown("""
**Sí.** Ve a la pestaña **📋 Datos Generales** del expediente, edita el campo y presiona **💾 Guardar cambios**.
Cada modificación queda registrada automáticamente en el **📜 Historial** con la fecha, hora y usuario que hizo el cambio.
        """)

    with st.expander("¿El OCR puede equivocarse?"):
        st.markdown("""
**Sí, es posible**, especialmente si el documento está:
- Muy doblado, rayado o con manchas
- Fotografiado con poca luz o en ángulo
- Es una fotocopia de baja calidad

Por eso el sistema siempre muestra el **nivel de confianza** (🟢 ALTA / 🟡 MEDIA / 🔴 BAJA)
y permite **editar todos los campos** antes de confirmar. El OCR es un asistente, 
**no reemplaza la revisión humana**.
        """)

    with st.expander("¿Qué pasa si el empleado ya existe pero no tiene algunos datos?"):
        st.markdown("""
**No hay problema.** Solo ve a su expediente y usa el **OCR** para escanear los documentos que le faltan.
También puedes editar directamente en **📋 Datos Generales**. El sistema solo actualiza los campos que completes,
sin borrar los que ya tenían información.
        """)

    with st.expander("¿Los permisos y ausencias afectan el reporte de asistencia?"):
        st.markdown("""
**Solo si marcas "Impacta en asistencia"** al registrar el permiso. Cuando está marcada,
el sistema registra los días del permiso en el control de asistencia con estatus `PERMISO`,
evitando que aparezcan como faltas injustificadas.
        """)

    with st.expander("¿Cómo sé qué documentos le faltan a un empleado?"):
        st.markdown("""
Ve al expediente → pestaña **📂 Documentos**. Ahí verás la lista de documentos registrados.
Si la lista está vacía o falta algún tipo (INE, NSS, RFC, etc.), ese es el pendiente.

**Documentos mínimos recomendados para un expediente completo:**
- ✅ INE vigente
- ✅ CURP
- ✅ NSS (IMSS)
- ✅ RFC (SAT)
- ✅ Acta de Nacimiento
- ✅ Comprobante de Domicilio (no mayor a 3 meses)
- ✅ Contrato firmado
- ✅ Foto del empleado
        """)

    # ── Pie de página ──────────────────────────────────────────────────────
    st.markdown("---")
    st.markdown(
        "<div style='text-align:center;color:#94a3b8;font-size:0.85rem;padding:10px'>"
        "📖 Guía de Recursos Humanos VPRO — Versión 1.0 — Sistema VPRO Dashboard v2<br>"
        "Para soporte técnico contacta al administrador del sistema."
        "</div>",
        unsafe_allow_html=True
    )