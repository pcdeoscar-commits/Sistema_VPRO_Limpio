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
        with get_db_cursor("db_personal_prueba") as cursor:
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
        with get_db_cursor("db_personal_prueba") as cursor:
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
                
                requiere_cambio = False
                clave_ingresada = datos.contrasena.strip()
                if not db_password.startswith("$2b$") or clave_ingresada == "vpro123" or clave_ingresada.startswith("VPRO-"):
                    requiere_cambio = True
                
                return {
                    "autenticado": True,
                    "nombre_completo": db_nombre,
                    "rol": safe_decode_hex(row[3]).strip().upper(),
                    "depto": safe_decode_hex(row[1]),
                    "id_empleado": safe_decode_hex(row[4]).strip(),
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
            
        pass_encriptada = encriptar_password(nueva_pass)
        
        with get_db_cursor("db_personal_prueba", commit=True) as cursor:
            cursor.execute(
                "UPDATE public.empleados SET password = %s WHERE TRIM(id_empleado) = %s;",
                (pass_encriptada, id_emp)
            )
        
        return {"status": "SUCCESS", "mensaje": "Contraseña encriptada y actualizada con éxito."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

