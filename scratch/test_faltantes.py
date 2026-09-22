import json
from sqlalchemy import create_engine, text

engine_e = create_engine('postgresql://postgres:1qaz2wsx@localhost:5432/db_eventos_prueba')
engine_p = create_engine('postgresql://postgres:1qaz2wsx@localhost:5432/db_personal_prueba')

def get_faltantes(id_evento):
    with engine_e.connect() as conn_e:
        res = conn_e.execute(text(f'SELECT personal_convocado_op FROM eventos WHERE id_evento = {id_evento}')).first()
        convocados = res[0]
        
    print('Convocados:', convocados)
    
    with engine_p.connect() as conn_p:
        nombres_str = ','.join([f"'{n}'" for n in convocados])
        rows = conn_p.execute(text(f'SELECT id_empleado, nombre FROM empleados WHERE nombre IN ({nombres_str})')).fetchall()
        id_to_nombre = {str(r[0]).strip(): r[1] for r in rows}
        print('ID to Nombre:', id_to_nombre)
        
    with engine_e.connect() as conn_e:
        ids_str = ','.join([f"'{i}'" for i in id_to_nombre.keys()])
        checkouts = conn_e.execute(text(f"SELECT id_empleado, incidencias_generales FROM checkouts_maestro WHERE folio_op = {id_evento} AND id_empleado IN ({ids_str})")).fetchall()
        
        validos = set()
        for c in checkouts:
            id_e = str(c[0]).strip()
            inc = str(c[1]).strip() if c[1] else ''
            if inc and inc != 'favor de reportar aqui las incidencias del evento':
                validos.add(id_e)
                
        faltantes = []
        for i, n in id_to_nombre.items():
            if i not in validos:
                faltantes.append(n)
        
    print('Faltantes:', faltantes)

if __name__ == '__main__':
    get_faltantes(19)

