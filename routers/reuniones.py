from typing import Dict, Any, List, Optional
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from sqlalchemy import text

from core.database import engine_personal, engine_eventos, engine_clientes

router = APIRouter(prefix="/api/reuniones", tags=["🤝 Prospectos y Reuniones"])

class ReunionPreviaIn(BaseModel):
    id_reunion: Optional[int] = None
    fecha_reunion: str
    cliente_tentativo: str
    nombre_proyecto_tentativo: str
    asistentes: str
    minuta_acuerdos: str
    presupuesto_estimado: Optional[float] = 0.0
    fecha_probable_evento: Optional[str] = None

@router.get("/asistentes")
def obtener_asistentes_validos():
    """Consulta la lista de empleados activos que pueden asistir a reuniones."""
    try:
        query = text("""
            SELECT nombre 
            FROM public.empleados 
            WHERE UPPER(rol) NOT IN ('BAJA', 'PROVEEDOR')
            ORDER BY nombre ASC
        """)
        with engine_personal.connect() as conn: 
            resultados = conn.execute(query).fetchall()
            return [fila[0] for fila in resultados if fila[0]]
    except Exception:
        return []

@router.post("")
def crear_o_actualizar_reunion(reunion: ReunionPreviaIn):
    """Crea una minuta de reunión o actualiza una existente."""
    try:
        if reunion.id_reunion:
            query = text("""
                UPDATE public.reuniones_previas 
                SET fecha_reunion = :fecha, cliente_tentativo = :cliente, nombre_proyecto_tentativo = :proyecto, 
                    asistentes = :asistentes, minuta_acuerdos = :minuta, presupuesto_estimado = :presupuesto, fecha_probable_evento = :fecha_probable
                WHERE id_reunion = :id
            """)
            parametros = {
                "id": reunion.id_reunion, 
                "fecha": reunion.fecha_reunion, 
                "cliente": reunion.cliente_tentativo, 
                "proyecto": reunion.nombre_proyecto_tentativo, 
                "asistentes": reunion.asistentes, 
                "minuta": reunion.minuta_acuerdos, 
                "presupuesto": reunion.presupuesto_estimado, 
                "fecha_probable": reunion.fecha_probable_evento if reunion.fecha_probable_evento else None
            }
        else:
            query = text("""
                INSERT INTO public.reuniones_previas 
                (fecha_reunion, cliente_tentativo, nombre_proyecto_tentativo, asistentes, minuta_acuerdos, presupuesto_estimado, fecha_probable_evento)
                VALUES (:fecha, :cliente, :proyecto, :asistentes, :minuta, :presupuesto, :fecha_probable)
            """)
            parametros = {
                "fecha": reunion.fecha_reunion, 
                "cliente": reunion.cliente_tentativo, 
                "proyecto": reunion.nombre_proyecto_tentativo, 
                "asistentes": reunion.asistentes, 
                "minuta": reunion.minuta_acuerdos, 
                "presupuesto": reunion.presupuesto_estimado, 
                "fecha_probable": reunion.fecha_probable_evento if reunion.fecha_probable_evento else None
            }
            
        with engine_eventos.begin() as conn:
            conn.execute(query, parametros)
            
        return {"status": "success", "mensaje": "Operación registrada exitosamente."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/historial")
def obtener_historial_reuniones():
    """Consulta las minutas de reuniones activas que no han sido vinculadas a una OP."""
    try:
        query = text("""
            WITH vinculadas AS (
                SELECT unnest(reuniones_vinculadas) as firma_v 
                FROM public.eventos 
                WHERE reuniones_vinculadas IS NOT NULL
            )
            SELECT id_reunion, 
                   fecha_reunion, 
                   cliente_tentativo, 
                   nombre_proyecto_tentativo, 
                   asistentes, 
                   minuta_acuerdos, 
                   presupuesto_estimado, 
                   fecha_probable_evento
            FROM public.reuniones_previas
            WHERE CONCAT(fecha_reunion, ' | ', cliente_tentativo, ' - ', nombre_proyecto_tentativo) NOT IN (SELECT firma_v FROM vinculadas)
              AND (folio_op_generado IS NULL OR folio_op_generado = 0)
              AND UPPER(COALESCE(estatus_proyecto, '')) NOT IN ('CONVERTIDO A OP', 'VINCULADO A OP', 'CERRADA (HISTÓRICO)')
            ORDER BY fecha_reunion DESC
        """)
        
        with engine_eventos.connect() as conn:
            resultados = conn.execute(query).mappings().all()
            
        lista_reuniones = []
        for r in resultados:
            fila = dict(r)
            fila["fecha_reunion"] = str(fila["fecha_reunion"]) if fila["fecha_reunion"] else ""
            fila["fecha_probable_evento"] = str(fila["fecha_probable_evento"]) if fila["fecha_probable_evento"] else ""
            lista_reuniones.append(fila)
            
        return lista_reuniones
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/clientes")
def obtener_clientes_reuniones():
    """Obtiene la lista de clientes para vincular a reuniones preliminares."""
    try:
        query = text("SELECT cliente_empresa FROM public.clientes ORDER BY cliente_empresa ASC")
        with engine_clientes.connect() as conn: 
            resultados = conn.execute(query).fetchall()
            return [fila[0] for fila in resultados if fila[0]]
    except Exception:
        return []

@router.get("/catalogo", tags=["📅 Reuniones"])
def obtener_catalogo_reuniones():
    """Retorna las firmas de reuniones para el selector de vinculación en la OP.
    Excluye las reuniones que ya están vinculadas a una OP cerrada o convertida."""
    try:
        query = text("""
            WITH vinculadas_cerradas AS (
                SELECT unnest(reuniones_vinculadas) as firma_v 
                FROM public.eventos 
                WHERE reuniones_vinculadas IS NOT NULL
                  AND (
                      UPPER(estatus) = 'CERRADA (HISTÓRICO)'
                      OR EXISTS (
                          SELECT 1 FROM public.informes_gastos_maestro igm 
                          WHERE igm.folio_vpro = id_evento AND igm.revisado = TRUE
                      )
                  )
            )
            SELECT CONCAT(fecha_reunion, ' | ', cliente_tentativo, ' - ', nombre_proyecto_tentativo) AS nombre_reunion 
            FROM public.reuniones_previas 
            WHERE CONCAT(fecha_reunion, ' | ', cliente_tentativo, ' - ', nombre_proyecto_tentativo) NOT IN (SELECT firma_v FROM vinculadas_cerradas)
              AND (folio_op_generado IS NULL OR folio_op_generado = 0 OR folio_op_generado NOT IN (SELECT id_evento FROM public.eventos WHERE UPPER(estatus) = 'CERRADA (HISTÓRICO)'))
              AND UPPER(COALESCE(estatus_proyecto, '')) NOT IN ('CONVERTIDO A OP', 'CERRADA (HISTÓRICO)')
            ORDER BY fecha_reunion DESC
        """)
        with engine_eventos.connect() as conn: 
            resultados = conn.execute(query).mappings().all()
        return [str(r["nombre_reunion"]).strip() for r in resultados if r["nombre_reunion"]]
    except Exception:
        return []

