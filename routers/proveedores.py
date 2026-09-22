from typing import Dict, Any, List
from fastapi import APIRouter, HTTPException
from psycopg2.extras import RealDictCursor

from core.database import get_db_cursor

router = APIRouter(prefix="/api/proveedores", tags=["🚚 Gestión Proveedores"])

@router.get("")
def obtener_proveedores():
    """Consulta el directorio maestro de proveedores comerciales."""
    try:
        with get_db_cursor("db_proveedores_prueba", cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT * FROM proveedores ORDER BY nombre_del_proveedor ASC;")
            proveedores = cursor.fetchall()
        return proveedores
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en BD Proveedores: {str(e)}")

@router.post("/guardar")
def guardar_proveedor(payload: dict):
    """Crea o actualiza el registro de un proveedor."""
    try:
        with get_db_cursor("db_proveedores_prueba", commit=True) as cursor:
            cursor.execute(
                "SELECT nombre_del_proveedor FROM proveedores WHERE UPPER(nombre_del_proveedor) = UPPER(%s);",
                (payload["nombre_del_proveedor"],),
            )
            existe = cursor.fetchone()

            if existe:
                query = """
                    UPDATE proveedores SET
                        gte_gral = %(gte_gral)s, estado = %(estado)s, ciudad = %(ciudad)s,
                        tel_de_ofna = %(tel_de_ofna)s, email_de_empresa = %(email_de_empresa)s,
                        nombre_contacto_princ = %(nombre_contacto_princ)s, cel_contact_princ = %(cel_contact_princ)s,
                        nombre_contacto_a = %(nombre_contacto_a)s, cel_contact_a = %(cel_contact_a)s
                    WHERE UPPER(nombre_del_proveedor) = UPPER(%(nombre_del_proveedor)s);
                """
            else:
                query = """
                    INSERT INTO proveedores (
                        nombre_del_proveedor, gte_gral, estado, ciudad, tel_de_ofna,
                        email_de_empresa, nombre_contacto_princ, cel_contact_princ,
                        nombre_contacto_a, cel_contact_a
                    ) VALUES (
                        %(nombre_del_proveedor)s, %(gte_gral)s, %(estado)s, %(ciudad)s, %(tel_de_ofna)s,
                        %(email_de_empresa)s, %(nombre_contacto_princ)s, %(cel_contact_princ)s,
                        %(nombre_contacto_a)s, %(cel_contact_a)s
                    );
                """
            cursor.execute(query, payload)
        return {"status": "ok", "mensaje": "Proveedor guardado correctamente"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al guardar proveedor: {str(e)}")

@router.delete("/eliminar/{nombre_proveedor}")
def eliminar_proveedor(nombre_proveedor: str):
    """Elimina permanentemente un proveedor por su nombre."""
    try:
        with get_db_cursor("db_proveedores_prueba", commit=True) as cursor:
            cursor.execute(
                "DELETE FROM proveedores WHERE UPPER(nombre_del_proveedor) = UPPER(%s);", 
                (nombre_proveedor,)
            )
        return {"status": "ok", "mensaje": f"Proveedor {nombre_proveedor} eliminado"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al eliminar proveedor: {str(e)}")

