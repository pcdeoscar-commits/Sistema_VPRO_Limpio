import psycopg2
from psycopg2.extras import RealDictCursor
from sqlalchemy import create_engine
from contextlib import contextmanager
from typing import Generator, Optional, Any
from core.config import DB_USER, DB_PASS, DB_HOST, DB_PORT

# 🔌 FUNCIÓN DE CONEXIÓN DINÁMICA (psycopg2)
def get_db_connection(db_name: str = "db_personal") -> psycopg2.extensions.connection:
    """Abre una conexión directa a PostgreSQL."""
    return psycopg2.connect(
        host=DB_HOST,
        database=db_name,
        user=DB_USER,
        password=DB_PASS,
        port=DB_PORT,
    )

# 🛡️ CONTEXT MANAGER SEGURO (Previene fugas de conexiones y cursores)
@contextmanager
def get_db_cursor(
    db_name: str = "db_personal", 
    cursor_factory: Optional[Any] = None, 
    commit: bool = True
) -> Generator[psycopg2.extensions.cursor, None, None]:
    """
    Context manager seguro para consultas psycopg2.
    Garantiza que el cursor y la conexión siempre se cierren,
    incluso ante excepciones, y maneja rollback/commit automáticamente.
    """
    conn = get_db_connection(db_name)
    cursor = None
    try:
        cursor = conn.cursor(cursor_factory=cursor_factory) if cursor_factory else conn.cursor()
        yield cursor
        if commit:
            conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        if cursor is not None:
            try:
                cursor.close()
            except Exception as e:
                print(f"⚠️ SILENCED ERROR in database.py: {e}")
        try:
            conn.close()
        except Exception as e:
            print(f"⚠️ SILENCED ERROR in database.py: {e}")

def _make_engine(db_name: str):
    return create_engine(
        f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{db_name}",
        pool_size=5,
        max_overflow=10,
        pool_pre_ping=True,
        connect_args={'client_encoding': 'utf8'}
    )

# 🧠 MOTORES DE CONEXIÓN (SQLAlchemy) - BASES DE DATOS REALES DE PRODUCCIÓN
engine_autos = _make_engine("db_autos")
engine_autos_vieja = engine_autos

engine_eventos = _make_engine("db_eventos")
engine_eventos_vieja = engine_eventos

engine_personal = _make_engine("db_personal")
engine_personal_vieja = engine_personal

engine_clientes = _make_engine("db_clientes")
engine_clientes_vieja = engine_clientes

engine_inventario = _make_engine("db_inventario")
engine_inventario_vieja = engine_inventario

engine_proveedores = _make_engine("db_proveedores")
engine_proveedores_vieja = engine_proveedores

