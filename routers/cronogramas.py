from typing import Dict, Any, List, Optional
import json
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from sqlalchemy import text

from core.database import engine_eventos, engine_personal, engine_autos
from core.utils import serialize_row_dates

router = APIRouter(prefix="/api/cronogramas", tags=["📅 Cronogramas de Eventos"])

class ActividadCronograma(BaseModel):
    horario: Optional[str] = ""
    actividad: Optional[str] = ""
    ubicacion: Optional[str] = ""
    evento: Optional[str] = ""
    personal_convocado: Optional[str] = ""
    vehiculo: Optional[str] = ""
    observaciones: Optional[str] = ""

class CronogramaIn(BaseModel):
    id_cronograma: Optional[int] = None
    folio: str
    fecha: str
    nombre_evento: Optional[str] = ""
    ubicacion_general: Optional[str] = ""
    folio_op: Optional[str] = ""
    actividades: List[Dict[str, Any]] = []
    observaciones_generales: Optional[str] = ""
    creado_por: Optional[str] = "Admin VPRO"

@router.get("")
def listar_cronogramas():
    """Consulta la lista de cronogramas de eventos registrados."""
    query = text("""
        SELECT 
            id_cronograma,
            folio,
            fecha,
            nombre_evento,
            ubicacion_general,
            folio_op,
            jsonb_array_length(COALESCE(actividades, '[]'::jsonb)) as total_actividades,
            observaciones_generales,
            creado_por,
            fecha_creacion
        FROM public.cronogramas_eventos
        ORDER BY fecha DESC, id_cronograma DESC
    """)
    try:
        with engine_eventos.connect() as conn:
            rows = conn.execute(query).mappings().fetchall()
            return [serialize_row_dates(dict(r)) for r in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{id_cronograma}")
def obtener_cronograma(id_cronograma: int):
    """Consulta el detalle completo de un cronograma con todas sus actividades."""
    query = text("""
        SELECT 
            id_cronograma,
            folio,
            fecha,
            nombre_evento,
            ubicacion_general,
            folio_op,
            actividades,
            observaciones_generales,
            creado_por,
            fecha_creacion
        FROM public.cronogramas_eventos
        WHERE id_cronograma = :id
    """)
    try:
        with engine_eventos.connect() as conn:
            row = conn.execute(query, {"id": id_cronograma}).mappings().first()
            if not row:
                raise HTTPException(status_code=404, detail="Cronograma no encontrado.")
            return serialize_row_dates(dict(row))
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("")
def guardar_cronograma(payload: CronogramaIn):
    """Crea o actualiza un cronograma de evento con sus actividades."""
    actividades_json = json.dumps(payload.actividades, ensure_ascii=False)
    try:
        if payload.id_cronograma:
            query = text("""
                UPDATE public.cronogramas_eventos
                SET folio = :folio,
                    fecha = CAST(:fecha AS DATE),
                    nombre_evento = :nombre_evento,
                    ubicacion_general = :ubicacion_general,
                    folio_op = :folio_op,
                    actividades = CAST(:actividades AS JSONB),
                    observaciones_generales = :observaciones_generales,
                    creado_por = :creado_por
                WHERE id_cronograma = :id
            """)
            params = {
                "id": payload.id_cronograma,
                "folio": payload.folio.strip(),
                "fecha": payload.fecha,
                "nombre_evento": payload.nombre_evento or "",
                "ubicacion_general": payload.ubicacion_general or "",
                "folio_op": payload.folio_op or "",
                "actividades": actividades_json,
                "observaciones_generales": payload.observaciones_generales or "",
                "creado_por": payload.creado_por or "Admin VPRO"
            }
        else:
            query = text("""
                INSERT INTO public.cronogramas_eventos (
                    folio, fecha, nombre_evento, ubicacion_general, folio_op, actividades, observaciones_generales, creado_por
                ) VALUES (
                    :folio, CAST(:fecha AS DATE), :nombre_evento, :ubicacion_general, :folio_op, CAST(:actividades AS JSONB), :observaciones_generales, :creado_por
                ) RETURNING id_cronograma
            """)
            params = {
                "folio": payload.folio.strip(),
                "fecha": payload.fecha,
                "nombre_evento": payload.nombre_evento or "",
                "ubicacion_general": payload.ubicacion_general or "",
                "folio_op": payload.folio_op or "",
                "actividades": actividades_json,
                "observaciones_generales": payload.observaciones_generales or "",
                "creado_por": payload.creado_por or "Admin VPRO"
            }

        with engine_eventos.begin() as conn:
            if payload.id_cronograma:
                conn.execute(query, params)
                res_id = payload.id_cronograma
            else:
                row = conn.execute(query, params).first()
                res_id = row[0] if row else None

        return {
            "status": "success",
            "mensaje": f"Cronograma con Folio {payload.folio} guardado exitosamente.",
            "id_cronograma": res_id
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{id_cronograma}")
def eliminar_cronograma(id_cronograma: int):
    """Elimina un cronograma de evento."""
    query = text("DELETE FROM public.cronogramas_eventos WHERE id_cronograma = :id")
    try:
        with engine_eventos.begin() as conn:
            conn.execute(query, {"id": id_cronograma})
        return {"status": "success", "mensaje": f"Cronograma {id_cronograma} eliminado correctamente."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/catalogo/op")
def catalogo_cronogramas_para_op():
    """Retorna las firmas de cronogramas formateadas para seleccionar y vincular en una OP."""
    query = text("""
        SELECT 
            id_cronograma,
            folio,
            fecha,
            nombre_evento,
            CONCAT('FOLIO: ', folio, ' | ', TO_CHAR(fecha, 'DD/MM/YYYY'), ' - ', COALESCE(nombre_evento, 'Sin título')) AS firma
        FROM public.cronogramas_eventos
        ORDER BY fecha DESC, folio ASC
    """)
    try:
        with engine_eventos.connect() as conn:
            rows = conn.execute(query).mappings().fetchall()
            return [str(r["firma"]).strip() for r in rows if r["firma"]]
    except Exception as e:
        return []

@router.get("/recursos/opciones")
def obtener_recursos_cronograma():
    """Obtiene empleados activos, vehículos y eventos disponibles para agilizar la captura del cronograma."""
    empleados = []
    vehiculos = []
    eventos = []

    try:
        with engine_personal.connect() as conn:
            res_emp = conn.execute(text("""
                SELECT nombre, puesto 
                FROM public.empleados 
                WHERE UPPER(rol) NOT IN ('BAJA', 'PROVEEDOR') 
                ORDER BY nombre ASC
            """)).mappings().fetchall()
            empleados = [dict(r) for r in res_emp]
    except Exception:
        pass

    try:
        with engine_autos.connect() as conn:
            res_aut = conn.execute(text("""
                SELECT num_control, marca, modelo 
                FROM public.autos 
                ORDER BY num_control ASC
            """)).mappings().fetchall()
            vehiculos = [f"{r['num_control']} - {r['marca']} {r['modelo']}".strip() for r in res_aut]
    except Exception:
        pass

    try:
        with engine_eventos.connect() as conn:
            res_ev = conn.execute(text("""
                SELECT COALESCE(folio::text, id_evento::text) as folio_op, nombre_evento, locacion 
                FROM public.eventos 
                ORDER BY id_evento DESC 
                LIMIT 40
            """)).mappings().fetchall()
            eventos = [dict(r) for r in res_ev]
    except Exception:
        pass

    return {
        "empleados": empleados,
        "vehiculos": vehiculos,
        "eventos": eventos
    }
