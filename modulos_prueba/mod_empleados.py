import streamlit as st
import requests
import pandas as pd
import datetime
from pathlib import Path

from modulos_prueba.utils_frontend import parse_fecha, _get, _post, _put, _delete, _badge, _color_estatus

# ══════════════════════════════════════════════════════════════════════════════
# MÓDULO DE ACCESO Y PLANTILLA — "Empleados" en Catálogos (ABC)
#
# RESPONSABILIDAD ÚNICA DE ESTE MÓDULO:
#   ✅ Crear acceso al sistema (ID, nombre, depto, rol, contraseña)
#   ✅ Cambiar contraseña de un empleado
#   ✅ Ver tabla de plantilla activa
#   ✅ Enlace rápido al Expediente Completo en Recursos Humanos
#
# LO QUE YA NO HACE ESTE MÓDULO (se hace en 👥 RH):
#   ❌ Editar datos del expediente (RFC, CURP, NSS, domicilio...)
#   ❌ Dar de baja con historial
#   ❌ Contratos, vacaciones, permisos, documentos, evaluaciones...
# ══════════════════════════════════════════════════════════════════════════════

ROLES_DISPONIBLES = ["ADMIN", "PRODUCCION", "COORDINADOR", "PRODUCTOR",
                     "CHOFER", "PROVEEDOR", "BAJA"]

DEPTOS_DISPONIBLES = ["ADMINISTRACION", "EDICION", "PRODUCCION", "SISTEMAS",
                      "VENTAS", "OPERACIONES", "LOGISTICA"]


@st.dialog("🔑 Cambiar Contraseña")
def _dialog_cambiar_password(id_empleado: str, nombre: str, API_URL: str):
    st.markdown(f"**Empleado:** {nombre} (ID: {id_empleado})")
    nueva = st.text_input("Nueva contraseña", type="password", key="nueva_pwd")
    confirmar = st.text_input("Confirmar contraseña", type="password", key="conf_pwd")
    col1, col2 = st.columns(2)
    if col1.button("❌ Cancelar", use_container_width=True):
        st.rerun()
    if col2.button("💾 Guardar", type="primary", use_container_width=True):
        if not nueva:
            st.error("La contraseña no puede estar vacía.")
        elif nueva != confirmar:
            st.error("Las contraseñas no coinciden.")
        else:
            try:
                emp_data = {}
                res_get = requests.get(f"{API_URL}/api/empleados", verify=False, timeout=5)
                if res_get.status_code == 200:
                    todos = res_get.json()
                    emp_data = next((e for e in todos if str(e.get("id_empleado")) == str(id_empleado)), {})

                payload = {**emp_data, "password": nueva, "id_empleado": id_empleado}
                res = requests.post(f"{API_URL}/api/empleados/guardar", json=payload,
                                    verify=False, timeout=10)
                if res.status_code == 200:
                    st.success(f"✅ Contraseña actualizada para {nombre}.")
                    st.rerun()
                else:
                    st.error(f"❌ Error: {res.text}")
            except Exception as e:
                print(f"⚠️ SILENCED ERROR in mod_empleados.py (_dialog_cambiar_password): {e}")
                st.error("❌ Error de conexión al servidor.")


def renderizar_modulo(API_URL: str):
    """Módulo ABC — Acceso al sistema y plantilla de personal."""

    st.markdown("""
        <div style='background:linear-gradient(90deg,#064e3b,#059669);
        padding:12px 20px;border-radius:10px;margin-bottom:14px'>
            <span style='color:white;font-size:1.35rem;font-weight:700'>🦺 Empleados — Catálogo y Accesos</span>
            <span style='color:#a7f3d0;font-size:0.9rem;margin-left:12px'>Alta al sistema · Contraseñas · Plantilla</span>
        </div>
    """, unsafe_allow_html=True)

    st.info(
        "**Este módulo gestiona el acceso al sistema VPRO.**  \n"
        "Para editar el expediente completo de un empleado (RFC, CURP, contratos, vacaciones, "
        "documentos, etc.) usa **👥 Recursos Humanos** en el menú."
    )

    # ── Cargar lista de empleados ──────────────────────────────────────────
    lista_empleados: list = []
    try:
        res = requests.get(f"{API_URL}/api/empleados", verify=False, timeout=5)
        if res.status_code == 200:
            lista_empleados = res.json()
        else:
            st.error(f"⚠️ API respondió con código {res.status_code}")
    except Exception as e:
        print(f"⚠️ SILENCED ERROR in mod_empleados.py (renderizar_modulo get): {e}")
        st.error("🛑 Error de conexión al cargar lista de empleados.")

    # ══════════════════════════════════════════════════════════════════════
    # SECCIÓN 1 — Plantilla de personal activo
    # ══════════════════════════════════════════════════════════════════════
    st.markdown("---")
    activos    = [e for e in lista_empleados if e.get("rol") != "BAJA"]
    inactivos  = [e for e in lista_empleados if e.get("rol") == "BAJA"]

    col_a, col_b, col_c = st.columns(3)
    col_a.metric("👥 Total plantilla", len(lista_empleados))
    col_b.metric("✅ Activos", len(activos))
    col_c.metric("🚪 Bajas", len(inactivos))

    with st.expander(f"📋 Ver Plantilla Completa ({len(lista_empleados)} colaboradores)", expanded=False):
        if lista_empleados:
            df = pd.DataFrame([{
                "ID":       e.get("id_empleado", "—"),
                "Nombre":   e.get("nombre", "—"),
                "Depto":    e.get("depto", "—"),
                "Rol":      e.get("rol", "—"),
                "Celular":  e.get("cel", "—"),
                "Email":    e.get("email", "—"),
                "Ingreso":  e.get("fecha_ing", "—"),
                "Lic. Vence": e.get("licencia_vence", "—"),
                "Estatus":  "✅ Activo" if e.get("rol") != "BAJA" else "🚪 Baja",
            } for e in lista_empleados])
            st.dataframe(df, use_container_width=True, hide_index=True)
        else:
            st.info("Sin colaboradores registrados.")

    # ══════════════════════════════════════════════════════════════════════
    # SECCIÓN 2 — Acceso rápido: navegar al expediente RH
    # ══════════════════════════════════════════════════════════════════════
    st.markdown("---")
    st.markdown("### 🗂️ Ir al Expediente Completo (Recursos Humanos)")
    st.caption("Selecciona un empleado para ver o editar su expediente completo: contratos, vacaciones, documentos, historial, etc.")

    col_sel, col_btn = st.columns([3, 1])
    opciones_nav = {
        f"{e.get('nombre') or '—'} (ID: {e.get('id_empleado') or '—'}) — {e.get('depto') or '—'}":
        e.get("id_empleado")
        for e in sorted(activos, key=lambda x: str(x.get("nombre") or ""))
    }
    with col_sel:
        sel_nav = st.selectbox("Seleccionar empleado:", list(opciones_nav.keys()),
                               key="abc_emp_nav")
    with col_btn:
        st.markdown("<br>", unsafe_allow_html=True)
        if st.button("📋 Abrir Expediente RH →", type="primary", use_container_width=True):
            if sel_nav:
                id_sel = opciones_nav.get(sel_nav)
                # Guardar en session_state para que RH lo preseleccione
                st.session_state["rh_emp_presel_id"] = id_sel
                st.session_state["rh_expandido"]     = True
                st.session_state["menu_dinamico"]    = "   ↳ 🔍 Expediente de Empleado"
                st.rerun()

    # ══════════════════════════════════════════════════════════════════════
    # SECCIÓN 3 — Alta de Nuevo Empleado (solo acceso al sistema)
    # ══════════════════════════════════════════════════════════════════════
    st.markdown("---")
    st.markdown("### ➕ Alta de Nuevo Empleado al Sistema")
    st.caption(
        "Registra los datos mínimos para que el empleado pueda iniciar sesión en VPRO. "
        "**Después** ve a 👥 RH para completar el expediente (RFC, CURP, contratos, etc.)."
    )

    with st.form("form_alta_nuevo"):
        col1, col2 = st.columns(2)
        with col1:
            id_nuevo   = st.text_input("ID / No. de Empleado *", placeholder="Ej: 215",
                                        help="Clave única de 1–5 caracteres.")
            nombre_nuevo = st.text_input("Nombre Completo *", placeholder="Ej: Carlos López Pérez")
            depto_nuevo  = st.selectbox("Departamento *", DEPTOS_DISPONIBLES)
        with col2:
            rol_nuevo   = st.selectbox("Rol de acceso *", ROLES_DISPONIBLES)
            cel_nuevo   = st.text_input("📱 Celular / WhatsApp", placeholder="5512345678")
            email_nuevo = st.text_input("✉️ Correo", placeholder="empleado@vpro.mx")

        col3, col4 = st.columns(2)
        fecha_ing_nuevo = col3.date_input("📅 Fecha de Ingreso", value=datetime.date.today())
        fecha_nac_nuevo = col4.date_input("🎂 Fecha de Nacimiento", value=None)

        pwd_nuevo = st.text_input("🔑 Contraseña inicial *", value="vpro123", type="password",
                                   help="El empleado puede cambiarla después de su primer inicio de sesión.")

        st.markdown(
            "<small style='color:#6b7280'>* Después del alta, ve a 👥 Recursos Humanos para completar "
            "el expediente (RFC, CURP, NSS, contratos, documentos, etc.)</small>",
            unsafe_allow_html=True
        )

        submit_nuevo = st.form_submit_button("💾 Dar de Alta al Sistema", type="primary",
                                              use_container_width=True)

    if submit_nuevo:
        if not id_nuevo.strip() or not nombre_nuevo.strip():
            st.error("⚠️ El ID y el Nombre son obligatorios.")
        elif any(str(e.get("id_empleado")) == id_nuevo.strip() for e in lista_empleados):
            st.error(f"⚠️ Ya existe un empleado con ID '{id_nuevo}'. Usa un ID diferente.")
        else:
            payload = {
                "id_empleado": id_nuevo.strip(),
                "nombre":      nombre_nuevo.strip(),
                "depto":       depto_nuevo,
                "rol":         rol_nuevo,
                "cel":         cel_nuevo.strip(),
                "email":       email_nuevo.strip(),
                "password":    pwd_nuevo.strip(),
                "fecha_ing":   str(fecha_ing_nuevo),
                "fecha_nac":   str(fecha_nac_nuevo) if fecha_nac_nuevo else None,
                "licencia_vence": None,
            }
            try:
                res = requests.post(f"{API_URL}/api/empleados/guardar", json=payload,
                                    verify=False, timeout=10)
                if res.status_code == 200:
                    st.success(
                        f"✅ ¡**{nombre_nuevo}** dado de alta exitosamente! "
                        f"ID: **{id_nuevo}** — Ahora ve a 👥 Recursos Humanos para completar su expediente."
                    )
                    # Preseleccionar en RH para continuar flujo
                    st.session_state["rh_emp_presel_id"] = id_nuevo.strip()
                    st.balloons()
                    import time; time.sleep(1.5)
                    st.session_state["rh_expandido"] = True
                    st.session_state["menu_dinamico"] = "   ↳ 🔍 Expediente de Empleado"
                    st.rerun()
                else:
                    st.error(f"❌ Error al guardar: {res.text}")
            except Exception as e:
                print(f"⚠️ SILENCED ERROR in mod_empleados.py (guardar nuevo): {e}")
                st.error("❌ Error de conexión.")

    # ══════════════════════════════════════════════════════════════════════
    # SECCIÓN 4 — Cambiar contraseña de empleado existente
    # ══════════════════════════════════════════════════════════════════════
    st.markdown("---")
    st.markdown("### 🔑 Cambiar Contraseña de Empleado Existente")

    col_pwd1, col_pwd2 = st.columns([3, 1])
    opciones_pwd = {
        f"{e.get('nombre') or '—'} (ID: {e.get('id_empleado') or '—'})":
        (e.get("id_empleado"), e.get("nombre") or "")
        for e in sorted(activos, key=lambda x: str(x.get("nombre") or ""))
    }
    with col_pwd1:
        sel_pwd = st.selectbox("Empleado:", list(opciones_pwd.keys()), key="sel_cambiar_pwd")
    with col_pwd2:
        st.markdown("<br>", unsafe_allow_html=True)
        if st.button("🔑 Cambiar", use_container_width=True, key="btn_cambiar_pwd"):
            if sel_pwd and sel_pwd in opciones_pwd:
                id_e, nombre_e = opciones_pwd[sel_pwd]
                _dialog_cambiar_password(str(id_e), nombre_e, API_URL)
            else:
                st.warning("Selecciona un empleado válido.")

    # ══════════════════════════════════════════════════════════════════════
    # SECCIÓN 5 — Alertas de licencias por vencer
    # ══════════════════════════════════════════════════════════════════════
    hoy = datetime.date.today()
    licencias_criticas = []
    for e in activos:
        f_lic = parse_fecha(e.get("licencia_vence"))
        if f_lic:
            dias = (f_lic - hoy).days
            if dias <= 30:
                licencias_criticas.append((e.get("nombre",""), f_lic, dias))

    if licencias_criticas:
        st.markdown("---")
        st.markdown("### 🚗 Licencias de Conducir por Vencer")
        for nombre_l, fecha_l, dias_l in licencias_criticas:
            if dias_l < 0:
                st.error(f"🔴 **{nombre_l}** — Licencia **VENCIDA** el {fecha_l} (hace {abs(dias_l)} días)")
            else:
                st.warning(f"🟡 **{nombre_l}** — Licencia vence el {fecha_l} (en {dias_l} días)")