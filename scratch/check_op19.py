import sys
from sqlalchemy import create_engine, text
engine = create_engine('postgresql://postgres:1qaz2wsx@localhost:5432/db_eventos_prueba')
with engine.connect() as conn:
    res = conn.execute(text("SELECT id_evento, estatus FROM eventos WHERE id_evento = 19")).first()
    print('OP-19 estatus:', res[1])

