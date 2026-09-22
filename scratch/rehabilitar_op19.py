import sys
from sqlalchemy import create_engine, text
engine = create_engine('postgresql://postgres:1qaz2wsx@localhost:5432/db_eventos_prueba')
with engine.connect() as conn:
    conn.execute(text("UPDATE eventos SET estatus = 'ACTIVA' WHERE id_evento = 19"))
    conn.commit()
    res = conn.execute(text("SELECT id_evento, estatus FROM eventos WHERE id_evento = 19")).first()
    print('OP-19 estatus cambiado a:', res[1])

