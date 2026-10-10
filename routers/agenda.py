from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from sqlalchemy import text

# Importamos la conexión a BD tal como lo tienes en rh.py
from core.database import engine_personal 

router = APIRouter(prefix="/api/agenda", tags=["📅 Agenda y Producción"])

# --- MODELOS PYDANTIC ---
class AgendaEventoBase(BaseModel):
    titulo: str
    fecha_inicio: datetime
    fecha_fin: datetime
    todo_el_dia: Optional[bool] = False
    tipo_evento: Optional[str] = None
    color_fondo: Optional[str] = "#3788d8"
    locacion: Optional[str] = None
    recursos_tecnicos: Optional[str] = None
    personal_asignado: Optional[str] = None
    notas_adicionales: Optional[str] = None
    creado_por: Optional[str] = None

class AgendaEventoCreate(AgendaEventoBase):
    pass

class AgendaEventoUpdate(BaseModel):
    titulo: Optional[str] = None
    fecha_inicio: Optional[datetime] = None
    fecha_fin: Optional[datetime] = None
    todo_el_dia: Optional[bool] = None
    tipo_evento: Optional[str] = None
    color_fondo: Optional[str] = None
    locacion: Optional[str] = None
    recursos_tecnicos: Optional[str] = None
    personal_asignado: Optional[str] = None
    notas_adicionales: Optional[str] = None
    estatus: Optional[str] = None

class AgendaEventoResponse(AgendaEventoBase):
    id: int
    fecha_creacion: datetime
    estatus: str

    class Config:
        from_attributes = True

# --- RUTAS / ENDPOINTS ---

@router.get("/eventos", response_model=List[AgendaEventoResponse])
def obtener_eventos(start: Optional[datetime] = None, end: Optional[datetime] = None):
    """
    Obtiene los eventos. 
    Nota: FullCalendar envía parámetros 'start' y 'end' automáticamente 
    para cargar solo los eventos del mes/semana actual y optimizar la carga.
    """
    query_str = "SELECT * FROM public.op_agenda WHERE estatus = 'Activo'"
    params = {}
    
    if start and end:
        query_str += " AND fecha_inicio >= :start AND fecha_fin <= :end"
        params["start"] = start
        params["end"] = end
        
    query_str += " ORDER BY fecha_inicio ASC"
    
    try:
        with engine_personal.connect() as conn:
            result = conn.execute(text(query_str), params).mappings().all()
            return [dict(row) for row in result]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener agenda: {str(e)}")

@router.post("/eventos", response_model=dict)
def crear_evento(evento: AgendaEventoCreate):
    query = text("""
        INSERT INTO public.op_agenda 
        (titulo, fecha_inicio, fecha_fin, todo_el_dia, tipo_evento, color_fondo, 
         locacion, recursos_tecnicos, personal_asignado, notas_adicionales, creado_por)
        VALUES 
        (:titulo, :fecha_inicio, :fecha_fin, :todo_el_dia, :tipo_evento, :color_fondo, 
         :locacion, :recursos_tecnicos, :personal_asignado, :notas_adicionales, :creado_por)
        RETURNING id
    """)
    # Usamos dict() para compatibilidad con pydantic v1/v2
    evento_dict = evento.dict() if hasattr(evento, 'dict') else evento.model_dump()
    
    try:
        with engine_personal.connect() as conn:
            result = conn.execute(query, evento_dict)
            nuevo_id = result.scalar()
            conn.commit()
            return {"mensaje": "Evento creado exitosamente", "id": nuevo_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al crear evento: {str(e)}")

@router.put("/eventos/{evento_id}", response_model=dict)
def actualizar_evento(evento_id: int, evento: AgendaEventoUpdate):
    # Usamos dict(exclude_unset=True) para solo actualizar lo que el usuario envió
    update_data = evento.dict(exclude_unset=True) if hasattr(evento, 'dict') else evento.model_dump(exclude_unset=True)
    
    if not update_data:
        raise HTTPException(status_code=400, detail="No hay datos para actualizar")
        
    set_clauses = []
    for key in update_data.keys():
        set_clauses.append(f"{key} = :{key}")
        
    query_str = f"""
        UPDATE public.op_agenda 
        SET {', '.join(set_clauses)}
        WHERE id = :evento_id
    """
    update_data["evento_id"] = evento_id
    
    try:
        with engine_personal.connect() as conn:
            result = conn.execute(text(query_str), update_data)
            conn.commit()
            if result.rowcount == 0:
                raise HTTPException(status_code=404, detail="Evento no encontrado")
            return {"mensaje": "Evento actualizado exitosamente"}
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=f"Error al actualizar evento: {str(e)}")

@router.delete("/eventos/{evento_id}", response_model=dict)
def eliminar_evento(evento_id: int):
    """
    Soft delete (Borrado lógico): En lugar de borrar el registro por completo, 
    solo cambiamos su estatus a 'Cancelado' por seguridad de la información.
    """
    query = text("UPDATE public.op_agenda SET estatus = 'Cancelado' WHERE id = :evento_id")
    try:
        with engine_personal.connect() as conn:
            result = conn.execute(query, {"evento_id": evento_id})
            conn.commit()
            if result.rowcount == 0:
                raise HTTPException(status_code=404, detail="Evento no encontrado")
            return {"mensaje": "Evento cancelado exitosamente"}
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=f"Error al eliminar evento: {str(e)}")

