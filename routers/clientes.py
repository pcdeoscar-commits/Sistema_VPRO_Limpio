from typing import Dict, Any, List
from fastapi import APIRouter, HTTPException
from psycopg2.extras import RealDictCursor
from sqlalchemy import text

from core.database import engine_clientes, get_db_cursor

router = APIRouter(prefix="/api/clientes", tags=["🏢 Gestión Clientes"])

@router.get("")
def obtener_clientes():
    """Consulta el directorio general de clientes corporativos."""
    try:
        with get_db_cursor("db_clientes_prueba", cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT * FROM clientes ORDER BY id_cliente ASC;")
            clientes = cursor.fetchall()
        return clientes
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en BD: {str(e)}")

@router.post("/guardar")
def guardar_cliente(payload: dict):
    """Crea o actualiza los datos corporativos de un cliente."""
    try:
        with get_db_cursor("db_clientes_prueba", commit=True) as cursor:
            cursor.execute(
                "SELECT id_cliente FROM clientes WHERE id_cliente = %s;",
                (payload["id_cliente"],),
            )
            existe = cursor.fetchone()

            if existe:
                query = """
                    UPDATE clientes SET
                        cliente_empresa = %(cliente_empresa)s, gte_gral = %(gte_gral)s,
                        estado = %(estado)s, ciudad = %(ciudad)s, tel_de_ofna = %(tel_de_ofna)s,
                        email_de_empresa = %(email_de_empresa)s, nombre_contacto_princ = %(nombre_contacto_princ)s,
                        cel_contact_princ = %(cel_contact_princ)s, nombre_contacto_a = %(nombre_contacto_a)s,
                        cel_contact_a = %(cel_contact_a)s
                    WHERE id_cliente = %(id_cliente)s;
                """
            else:
                query = """
                    INSERT INTO clientes (
                        id_cliente, cliente_empresa, gte_gral, estado, ciudad, tel_de_ofna,
                        email_de_empresa, nombre_contacto_princ, cel_contact_princ,
                        nombre_contacto_a, cel_contact_a
                    ) VALUES (
                        %(id_cliente)s, %(cliente_empresa)s, %(gte_gral)s, %(estado)s, %(ciudad)s, %(tel_de_ofna)s,
                        %(email_de_empresa)s, %(nombre_contacto_princ)s, %(cel_contact_princ)s,
                        %(nombre_contacto_a)s, %(cel_contact_a)s
                    );
                """
            cursor.execute(query, payload)
        return {"status": "ok", "mensaje": "Cliente guardado correctamente"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al guardar: {str(e)}")

@router.delete("/eliminar/{id_cliente}")
def eliminar_cliente(id_cliente: int):
    """Elimina permanentemente un cliente del catálogo maestro."""
    try:
        with get_db_cursor("db_clientes_prueba", commit=True) as cursor:
            cursor.execute("DELETE FROM clientes WHERE id_cliente = %s;", (id_cliente,))
        return {"status": "ok", "mensaje": f"Cliente {id_cliente} eliminado"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al eliminar: {str(e)}")

@router.get("/catalogo", tags=["🏢 Clientes"])
def obtener_catalogo_clientes():
    """Retorna los nombres de empresas de clientes para selectores."""
    try:
        query = text("""
            SELECT DISTINCT cliente_empresa 
            FROM public.clientes 
            WHERE cliente_empresa IS NOT NULL
            ORDER BY cliente_empresa ASC
        """)
        with engine_clientes.connect() as conn:
            resultados = conn.execute(query).mappings().all()
        return [str(r["cliente_empresa"]).strip() for r in resultados if r["cliente_empresa"]]
    except Exception:
        return []

@router.get("/contactos/{nombre_empresa}", tags=["🏢 Clientes"])
def obtener_contactos_cliente(nombre_empresa: str):
    """Retorna la lista de nombres de contacto de una empresa específica."""
    try:
        query = text("""
            SELECT gte_gral, nombre_contacto_princ, nombre_contacto_a 
            FROM public.clientes 
            WHERE cliente_empresa = :empresa
        """)
        with engine_clientes.connect() as conn:
            resultado = conn.execute(query, {"empresa": nombre_empresa}).mappings().first()
            
        contactos = []
        if resultado:
            for columna in ["gte_gral", "nombre_contacto_princ", "nombre_contacto_a"]:
                valor = str(resultado.get(columna, "")).strip()
                if valor and valor.lower() not in ["none", "null", "nan", ""]:
                    contactos.append(valor)
        return contactos
    except Exception:
        return []

