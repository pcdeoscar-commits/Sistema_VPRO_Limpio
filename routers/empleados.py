import base64
from io import BytesIO
from typing import Dict, Any, List
from fastapi import APIRouter, HTTPException, Depends
from psycopg2.extras import RealDictCursor
import qrcode

from core.database import get_db_cursor, engine_personal
from core.security import encriptar_password, requerir_roles
from sqlalchemy import text

router = APIRouter(prefix="/api/empleados", tags=["🦺 Gestión Personal"])

def _asegurar_roles_productores():
    try:
        with engine_personal.begin() as conn:
            conn.execute(text("UPDATE public.empleados SET rol = 'PRODUCTOR' WHERE TRIM(id_empleado) IN ('107', '119') AND UPPER(COALESCE(rol, '')) != 'PRODUCTOR';"))
    except Exception as e:
        print(f"⚠️ Nota de roles productores: {e}")

_asegurar_roles_productores()

@router.get("")
def obtener_empleados():
    """Consulta la plantilla completa de empleados activos e inactivos (sin exponer hashes de contraseña)."""
    try:
        with get_db_cursor("db_personal", cursor_factory=RealDictCursor) as cursor:
            query = """
                SELECT id_empleado, nombre, depto, email, cel, 
                       fecha_nac, fecha_ing, licencia_vence, rol, estatus_empleado
                FROM empleados 
                ORDER BY id_empleado ASC;
            """
            cursor.execute(query)
            empleados = cursor.fetchall()
        return empleados
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en BD: {str(e)}")

@router.post("/guardar")
def guardar_empleado(payload: dict, usuario: dict = Depends(requerir_roles("ADMIN", "RRHH"))):
    """Crea o actualiza el registro de un empleado (solo ADMIN / RRHH)."""
    try:
        emp_id = str(payload.get("id_empleado") or "").strip()
        if not emp_id:
            raise HTTPException(status_code=400, detail="El id_empleado es obligatorio.")

        raw_pwd = str(payload.get("password") or "").strip()

        with get_db_cursor("db_personal", commit=True) as cursor:
            cursor.execute(
                "SELECT id_empleado FROM empleados WHERE TRIM(id_empleado) = %s;",
                (emp_id,),
            )
            existe = cursor.fetchone()

            if existe:
                if raw_pwd and not raw_pwd.startswith("$2b$"):
                    payload["password"] = encriptar_password(raw_pwd)
                    pwd_clause = ", password = %(password)s"
                elif raw_pwd.startswith("$2b$"):
                    pwd_clause = ", password = %(password)s"
                else:
                    pwd_clause = ""

                query = f"""
                    UPDATE empleados SET
                        nombre = %(nombre)s, depto = %(depto)s, email = %(email)s,
                        cel = %(cel)s, fecha_nac = %(fecha_nac)s, fecha_ing = %(fecha_ing)s,
                        licencia_vence = %(licencia_vence)s, rol = %(rol)s{pwd_clause}
                    WHERE TRIM(id_empleado) = %(id_empleado)s;
                """
            else:
                if not raw_pwd:
                    raw_pwd = f"VPRO-{emp_id}"
                if not raw_pwd.startswith("$2b$"):
                    payload["password"] = encriptar_password(raw_pwd)
                query = """
                    INSERT INTO empleados (
                        id_empleado, nombre, depto, email, cel, 
                        fecha_nac, fecha_ing, licencia_vence, password, rol
                    ) VALUES (
                        %(id_empleado)s, %(nombre)s, %(depto)s, %(email)s, %(cel)s, 
                        %(fecha_nac)s, %(fecha_ing)s, %(licencia_vence)s, %(password)s, %(rol)s
                    );
                """
            cursor.execute(query, payload)
        return {"status": "ok", "mensaje": "Empleado guardado correctamente"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al guardar: {str(e)}")

@router.delete("/eliminar/{id_empleado}")
def eliminar_empleado(id_empleado: str, usuario: dict = Depends(requerir_roles("ADMIN", "RRHH"))):
    """Elimina permanentemente a un empleado por su ID (solo ADMIN / RRHH)."""
    try:
        with get_db_cursor("db_personal", commit=True) as cursor:
            cursor.execute("DELETE FROM empleados WHERE id_empleado = %s;", (id_empleado,))
        return {"status": "ok", "mensaje": f"Empleado {id_empleado} eliminado"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al eliminar: {str(e)}")

@router.get("/{id_empleado}/qr")
def generar_qr_empleado(id_empleado: str):
    """Genera el código QR en base64 de la credencial del empleado."""
    try:
        with get_db_cursor("db_personal") as cursor:
            cursor.execute("SELECT id_empleado FROM empleados WHERE TRIM(id_empleado) = %s;", (id_empleado.strip(),))
            existe = cursor.fetchone()

        if not existe:
            raise HTTPException(status_code=404, detail="Empleado no encontrado")

        qr = qrcode.QRCode(version=1, box_size=10, border=2)
        qr.add_data(id_empleado.strip())
        qr.make(fit=True)
        img = qr.make_image(fill_color="black", back_color="white")
        
        buffered = BytesIO()
        img.save(buffered, format="PNG")
        img_str = base64.b64encode(buffered.getvalue()).decode()
        
        return {"status": "SUCCESS", "qr_base64": f"data:image/png;base64,{img_str}"}

    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))