"""
VPRO DATABASE AUTO-MIGRATIONS
Asegura que todas las tablas y columnas necesarias para nuevos modulos
(como Mantenimiento & Taller estilo Odoo) existan de forma automatica
e idempotente tanto en local (.20) como en la nube (Railway/Produccion).
"""
import logging
from core.database import get_db_cursor

logger = logging.getLogger("uvicorn")

def aplicar_migraciones_automaticas():
    """Ejecuta los ALTER TABLE IF NOT EXISTS para sincronizar esquemas de BD."""
    try:
        with get_db_cursor("db_inventario", commit=True) as cursor:
            # 1. Columnas en public.reparaciones
            cursor.execute("""
                ALTER TABLE public.reparaciones 
                ADD COLUMN IF NOT EXISTS tipo_mantenimiento character varying(50) DEFAULT 'CORRECTIVO',
                ADD COLUMN IF NOT EXISTS etapa_taller character varying(50) DEFAULT 'DIAGNOSTICO',
                ADD COLUMN IF NOT EXISTS checklist_calidad jsonb DEFAULT '{}'::jsonb,
                ADD COLUMN IF NOT EXISTS fecha_prometida date;
            """)
            
            # 2. Columnas en public.inventario
            cursor.execute("""
                ALTER TABLE public.inventario 
                ADD COLUMN IF NOT EXISTS frecuencia_mantenimiento_dias integer,
                ADD COLUMN IF NOT EXISTS fecha_ultimo_mantenimiento date,
                ADD COLUMN IF NOT EXISTS fecha_proximo_mantenimiento date;
            """)

            # 3. Columnas en public.historial_equipo
            cursor.execute("""
                ALTER TABLE public.historial_equipo
                ADD COLUMN IF NOT EXISTS costo_asociado numeric(12,2) DEFAULT 0.0,
                ADD COLUMN IF NOT EXISTS estado_final character varying(50),
                ADD COLUMN IF NOT EXISTS departamento character varying(100);
            """)

            # 4. Asegurar indices de busqueda rapida
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_reparaciones_etapa ON public.reparaciones (etapa_taller);
                CREATE INDEX IF NOT EXISTS idx_reparaciones_tipo ON public.reparaciones (tipo_mantenimiento);
                CREATE INDEX IF NOT EXISTS idx_inventario_prox_mant ON public.inventario (fecha_proximo_mantenimiento);
            """)

            logger.info("[Auto-Migraciones] Esquemas de db_inventario y mantenimiento sincronizados al 100%.")
    except Exception as e:
        logger.warning(f"[Auto-Migraciones] Advertencia al sincronizar esquemas: {e}")
