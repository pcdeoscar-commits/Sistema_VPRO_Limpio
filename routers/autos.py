from typing import Dict, Any, List
from fastapi import APIRouter, HTTPException
from sqlalchemy import text

from core.database import engine_autos
from core.utils import serialize_row_dates

router = APIRouter(prefix="/api/autos", tags=["🚙 Control Vehicular"])

@router.get("")
def obtener_flota():
    """Consulta la flota vehicular completa de la empresa."""
    query = text("SELECT * FROM public.autos ORDER BY num_control ASC")
    try:
        with engine_autos.connect() as conn:
            rows = conn.execute(query).mappings().fetchall()
            return [serialize_row_dates(dict(row)) for row in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/guardar")
def guardar_o_actualizar_auto(auto: dict):
    """Guarda o actualiza los datos técnicos, seguro e impuestos de un vehículo."""
    query_upsert = text("""
        INSERT INTO public.autos (
            num_control, marca, modelo, serie, tipo_vehiculo, anio, placa, color, 
            carga_maxima, kilometraje_actual, estado_actual, estado_mant_preventivo, 
            fecha_compra, aseguradora, no_poliza, status_seguro, forma_pago_seguro, 
            prima_total, seguro_inicio, seguro_vence, impuesto_anio, impuesto_monto, 
            impuesto_fecha_pago, impuesto_fecha_vencimiento, mantenimiento_fecha, 
            servicios_hechos, observaciones_comentarios
        )
        VALUES (
            :num_control, :marca, :modelo, :serie, :tipo_vehiculo, :anio, :placa, :color, 
            :carga_maxima, :kilometraje_actual, :estado_actual, :estado_mant_preventivo, 
            :fecha_compra, :aseguradora, :no_poliza, :status_seguro, :forma_pago_seguro, 
            :prima_total, :seguro_inicio, :seguro_vence, :impuesto_anio, :impuesto_monto, 
            :impuesto_fecha_pago, :impuesto_fecha_vencimiento, :mantenimiento_fecha, 
            :servicios_hechos, :observaciones_comentarios
        )
        ON CONFLICT (num_control) DO UPDATE SET 
            marca = EXCLUDED.marca, 
            modelo = EXCLUDED.modelo, 
            serie = EXCLUDED.serie, 
            tipo_vehiculo = EXCLUDED.tipo_vehiculo, 
            anio = EXCLUDED.anio, 
            placa = EXCLUDED.placa, 
            color = EXCLUDED.color, 
            carga_maxima = EXCLUDED.carga_maxima, 
            kilometraje_actual = EXCLUDED.kilometraje_actual, 
            estado_actual = EXCLUDED.estado_actual, 
            estado_mant_preventivo = EXCLUDED.estado_mant_preventivo, 
            fecha_compra = EXCLUDED.fecha_compra, 
            aseguradora = EXCLUDED.aseguradora, 
            no_poliza = EXCLUDED.no_poliza, 
            status_seguro = EXCLUDED.status_seguro, 
            forma_pago_seguro = EXCLUDED.forma_pago_seguro, 
            prima_total = EXCLUDED.prima_total, 
            seguro_inicio = EXCLUDED.seguro_inicio, 
            seguro_vence = EXCLUDED.seguro_vence, 
            impuesto_anio = EXCLUDED.impuesto_anio, 
            impuesto_monto = EXCLUDED.impuesto_monto, 
            impuesto_fecha_pago = EXCLUDED.impuesto_fecha_pago, 
            impuesto_fecha_vencimiento = EXCLUDED.impuesto_fecha_vencimiento, 
            mantenimiento_fecha = EXCLUDED.mantenimiento_fecha, 
            servicios_hechos = EXCLUDED.servicios_hechos, 
            observaciones_comentarios = EXCLUDED.observaciones_comentarios;
    """)
    try:
        with engine_autos.begin() as conn: 
            conn.execute(query_upsert, auto)
        return {"status": "SUCCESS"}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{num_control}")
def eliminar_vehiculo(num_control: str):
    """Elimina permanentemente una unidad de la flota por su número de control."""
    query = text("DELETE FROM public.autos WHERE num_control = :num_control")
    try:
        with engine_autos.begin() as conn:
            conn.execute(query, {"num_control": num_control})
        return {"status": "SUCCESS"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

