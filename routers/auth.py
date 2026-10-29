from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import List, Dict, Any, Optional

from core.database import get_db_cursor
from core.security import verificar_password, encriptar_password
from core.utils import safe_decode_hex

router = APIRouter(prefix="/api/auth", tags=["Seguridad"])

class LoginRequest(BaseModel):
    usuario: str
    contrasena: str

class CambioPasswordPayload(BaseModel):
    id_empleado: str
    nueva_contrasena: str

@router.get("/empleados-lista", response_model=List[str])
def obtener_lista_nombres_login():
    """Retorna la lista de empleados activos para el selector de login."""
    try:
        with get_db_cursor("db_personal") as cursor:
            cursor.execute(
                "SELECT encode(nombre::bytea, 'hex'), encode(rol::bytea, 'hex'), encode(depto::bytea, 'hex') "
                "FROM public.empleados WHERE nombre IS NOT NULL"
            )
            rows = cursor.fetchall()
        
        lista_filtrada = []
        for r in rows:
            nombre = safe_decode_hex(r[0])
            rol = safe_decode_hex(r[1]).strip().upper()
            depto = safe_decode_hex(r[2]).strip().lower()
            if rol not in ['BAJA', 'PROVEEDOR'] and 'externo' not in depto:
                lista_filtrada.append(nombre)
        lista_filtrada.sort()
        return lista_filtrada
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/login")
def autenticar_usuario(datos: LoginRequest):
    """Autentica un usuario verificando contraseña en texto plano o hash bcrypt."""
    try:
        with get_db_cursor("db_personal") as cursor:
            cursor.execute("""
                SELECT encode(nombre::bytea, 'hex'), encode(depto::bytea, 'hex'), encode(password::bytea, 'hex'), 
                       encode(rol::bytea, 'hex'), encode(id_empleado::bytea, 'hex'), encode(email::bytea, 'hex')
                FROM public.empleados
            """)
            rows = cursor.fetchall()
        
        target_user = datos.usuario.strip().lower()
        
        for row in rows:
            db_nombre = safe_decode_hex(row[0]).strip()
            if db_nombre.lower() == target_user:
                db_password = safe_decode_hex(row[2]).strip()
                
                if not verificar_password(datos.contrasena, db_password):
                    raise HTTPException(status_code=401, detail="Contraseña incorrecta.")
                
                import re
                def is_password_simple(pwd: str) -> bool:
                    if len(pwd) < 8: return True
                    if not re.search(r'[A-Z]', pwd): return True
                    if not re.search(r'[a-z]', pwd): return True
                    if not re.search(r'[0-9]', pwd): return True
                    if not re.search(r'[\W_]', pwd): return True
                    return False

                requiere_cambio = False
                clave_ingresada = datos.contrasena.strip()
                
                # Checar si la contraseña es simple, o no está hasheada
                if not db_password.startswith("$2b$") or is_password_simple(clave_ingresada) or clave_ingresada.startswith("VPRO-"):
                    requiere_cambio = True
                
                db_id_emp = safe_decode_hex(row[4]).strip()
                # 🔒 Blindaje: Dispositivo central (000 / Celular) tiene contraseña fija permanente (1344) y nunca exige cambio
                if db_id_emp == "000" or "CELULAR" in db_nombre.upper() or "LIVE STREAM" in db_nombre.upper():
                    requiere_cambio = False
                try:
                    with get_db_cursor("db_personal", commit=True) as cur_log:
                        cur_log.execute("""
                            INSERT INTO public.log_accesos (id_empleado, nombre_empleado, tipo_evento, ip_origen)
                            VALUES (%s, %s, %s, %s)
                        """, (
                            int(db_id_emp) if db_id_emp.isdigit() else None,
                            db_nombre,
                            "LOGIN_SISTEMA",
                            "INTRANET"
                        ))
                except Exception as err_log:
                    print(f"⚠️ Error registrando log_accesos: {err_log}")

                return {
                    "autenticado": True,
                    "nombre_completo": db_nombre,
                    "rol": safe_decode_hex(row[3]).strip().upper(),
                    "depto": safe_decode_hex(row[1]),
                    "id_empleado": db_id_emp,
                    "email": safe_decode_hex(row[5]).strip(),
                    "requiere_cambio": requiere_cambio
                }
        raise HTTPException(status_code=401, detail="El empleado no se encuentra registrado.")
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/cambiar-password")
def cambiar_password(payload: dict):
    """Actualiza la contraseña del empleado con hash bcrypt."""
    try:
        id_emp = str(payload.get("id_empleado") or payload.get("id_usuario") or "").strip()
        nueva_pass = str(payload.get("nueva_contrasena") or payload.get("nueva_clave") or payload.get("password") or "").strip()
        
        if not id_emp or not nueva_pass:
            raise HTTPException(status_code=400, detail="Faltan datos obligatorios para el cambio.")
            
        if id_emp == "000":
            raise HTTPException(status_code=403, detail="Este dispositivo central tiene contraseña permanente e inmutable (1344). No se permite modificarla.")
            
        pass_encriptada = encriptar_password(nueva_pass)
        
        with get_db_cursor("db_personal", commit=True) as cursor:
            cursor.execute(
                "UPDATE public.empleados SET password = %s WHERE TRIM(id_empleado) = %s;",
                (pass_encriptada, id_emp)
            )
        
        return {"status": "SUCCESS", "mensaje": "Contraseña encriptada y actualizada con éxito."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/personal-selector")
def obtener_personal_para_selector():
    """Retorna la lista de empleados activos para el dropdown del CEO."""
    try:
        with get_db_cursor("db_personal") as cursor:
            cursor.execute("""
                SELECT TRIM(id_empleado), nombre, depto, puesto
                FROM public.empleados
                WHERE (estatus_empleado = 'ACTIVO' OR estatus_empleado IS NULL)
                  AND UPPER(COALESCE(rol, '')) NOT IN ('BAJA', 'PROVEEDOR')
                  AND nombre IS NOT NULL
                ORDER BY nombre ASC
            """)
            rows = cursor.fetchall()

        resultado = []
        for r in rows:
            resultado.append({
                "id_empleado": str(r[0]),
                "nombre": str(r[1]).strip(),
                "depto": str(r[2]).strip() if r[2] else "GENERAL",
                "puesto": str(r[3]).strip() if r[3] else ""
            })
        return resultado
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/registrar-acceso")
def registrar_acceso_sesion(payload: dict):
    """Registra un evento de acceso / sesión activa en log_accesos."""
    try:
        id_emp = str(payload.get("id_empleado", "")).strip()
        nombre = str(payload.get("nombre", "")).strip()
        tipo = str(payload.get("tipo_evento", "ACCESO_SISTEMA")).strip()
        ip = str(payload.get("ip_origen", "INTRANET")).strip()
        
        with get_db_cursor("db_personal", commit=True) as cursor:
            cursor.execute("""
                INSERT INTO public.log_accesos (id_empleado, nombre_empleado, tipo_evento, ip_origen)
                VALUES (%s, %s, %s, %s)
            """, (int(id_emp) if id_emp.isdigit() else None, nombre, tipo, ip))
        return {"status": "SUCCESS", "mensaje": "Acceso registrado correctamente."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/accesos-recientes/{id_empleado}")
def obtener_accesos_recientes_empleado(id_empleado: str, dias: int = 7):
    """
    Retorna cuántas veces ha accesado al sistema un empleado en los últimos N días.
    Consolida accesos a la plataforma ERP (log_accesos) y registros de asistencia/checador (control_asistencia).
    """
    try:
        id_emp_clean = id_empleado.strip()
        with get_db_cursor("db_personal") as cursor:
            # 1. Datos del empleado
            cursor.execute(
                "SELECT TRIM(id_empleado), nombre, puesto, depto FROM public.empleados WHERE TRIM(id_empleado) = %s",
                (id_emp_clean,)
            )
            emp_row = cursor.fetchone()
            nombre_emp = emp_row[1] if emp_row else f"ID: {id_emp_clean}"
            depto_emp = emp_row[3] if emp_row else ""
            puesto_emp = emp_row[2] if emp_row else ""

            # 2. Consultar log_accesos (accesos a la plataforma VPRO)
            cursor.execute("""
                SELECT fecha, hora, tipo_evento, ip_origen 
                FROM public.log_accesos 
                WHERE (id_empleado = %s OR LOWER(nombre_empleado) = %s)
                  AND fecha >= CURRENT_DATE - %s
                ORDER BY fecha DESC, hora DESC
            """, (int(id_emp_clean) if id_emp_clean.isdigit() else -1, nombre_emp.lower(), dias))
            rows_logs = cursor.fetchall()

            # 3. Consultar control_asistencia (checadas / Kiosco)
            cursor.execute("""
                SELECT fecha, hora_entrada, hora_salida, observaciones 
                FROM public.control_asistencia 
                WHERE TRIM(id_empleado) = %s AND fecha >= CURRENT_DATE - %s
                ORDER BY fecha DESC, hora_entrada DESC
            """, (id_emp_clean, dias))
            rows_asis = cursor.fetchall()

        historial = []
        fechas_unicas = set()

        for r in rows_logs:
            f_str = str(r[0])
            fechas_unicas.add(f_str)
            historial.append({
                "fecha": f_str,
                "hora": str(r[1])[:8] if r[1] else "--:--",
                "tipo": "🖥️ Plataforma ERP (Login)",
                "detalle": f"Evento: {r[2] or 'Acceso'} | Origen: {r[3] or 'Intranet'}"
            })

        for r in rows_asis:
            f_str = str(r[0])
            fechas_unicas.add(f_str)
            h_in = str(r[1])[:5] if r[1] else "--:--"
            h_out = str(r[2])[:5] if r[2] else "--:--"
            obs = r[3] or "Checador"
            historial.append({
                "fecha": f_str,
                "hora": h_in,
                "tipo": "🕒 Checador / Asistencia",
                "detalle": f"Entrada: {h_in} | Salida: {h_out} ({obs})"
            })

        historial.sort(key=lambda x: (x["fecha"], x["hora"]), reverse=True)

        total_sesiones_erp = len(rows_logs)
        total_checadas = len(rows_asis)
        total_dias_activos = len(fechas_unicas)
        total_accesos_consolidado = len(historial)

        return {
            "status": "SUCCESS",
            "id_empleado": id_emp_clean,
            "nombre": nombre_emp,
            "depto": depto_emp,
            "puesto": puesto_emp,
            "dias_evaluados": dias,
            "total_accesos": total_accesos_consolidado,
            "total_sesiones_erp": total_sesiones_erp,
            "total_checadas_asistencia": total_checadas,
            "dias_con_acceso": total_dias_activos,
            "ultimo_acceso": historial[0] if historial else None,
            "historial": historial
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
