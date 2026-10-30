import os


import re


import json


import base64


import shutil


import time


import datetime


from typing import Dict, Any, List, Optional


from fastapi import APIRouter, HTTPException, File, Form, UploadFile, Request


from psycopg2.extras import RealDictCursor


from sqlalchemy import text





from core.config import DIR_EVIDENCIAS_REAL


from core.database import (


    engine_inventario, engine_personal, get_db_cursor


)


from core.utils import safe_decode_hex, reparar_mojibake





router = APIRouter(tags=["🛠️ Inventario General"])





@router.get("/api/inventario")


def obtener_inventario():


    """Consulta todo el catálogo de inventario maestro ordenado por código."""


    try:


        with get_db_cursor("db_inventario", cursor_factory=RealDictCursor) as cursor:


            cursor.execute("SELECT * FROM inventario ORDER BY codigo ASC;")


            inventario = cursor.fetchall()


        return inventario


    except Exception as e:


        raise HTTPException(status_code=500, detail=f"Error en BD: {str(e)}")





@router.post("/api/inventario/guardar")


def guardar_inventario(payload: dict):


    """Inserta o actualiza un equipo en inventario."""


    try:


        with get_db_cursor("db_inventario", commit=True) as cursor:


            cursor.execute(


                "SELECT codigo FROM inventario WHERE codigo = %s;", (payload["codigo"],)


            )


            existe = cursor.fetchone()





            if existe:


                query = """


                    UPDATE inventario SET


                        responsiva = %(responsiva)s, fecha_compra = %(fecha_compra)s,


                        descripcion = %(descripcion)s, marca = %(marca)s, modelo = %(modelo)s,


                        serie = %(serie)s, responsable = %(responsable)s, estado = %(estado)s,


                        ubicacion = %(ubicacion)s, observaciones = %(observaciones)s


                    WHERE codigo = %(codigo)s;


                """


            else:


                query = """


                    INSERT INTO inventario (


                        codigo, responsiva, fecha_compra, descripcion, marca, modelo,


                        serie, responsable, estado, ubicacion, observaciones


                    ) VALUES (


                        %(codigo)s, %(responsiva)s, %(fecha_compra)s, %(descripcion)s, %(marca)s, %(modelo)s,


                        %(serie)s, %(responsable)s, %(estado)s, %(ubicacion)s, %(observaciones)s


                    );


                """


            cursor.execute(query, payload)


        return {"status": "ok", "mensaje": "Inventario guardado"}


    except Exception as e:


        raise HTTPException(status_code=500, detail=f"Error al guardar: {str(e)}")





@router.delete("/api/inventario/eliminar/{codigo}")


def eliminar_inventario(codigo: str):


    """Elimina un equipo del inventario por código."""


    try:


        with get_db_cursor("db_inventario", commit=True) as cursor:


            cursor.execute("DELETE FROM inventario WHERE codigo = %s;", (codigo,))


        return {"status": "ok", "mensaje": f"Equipo {codigo} eliminado"}


    except Exception as e:


        raise HTTPException(status_code=500, detail=f"Error al eliminar: {str(e)}")





@router.get("/api/inventario-kits/completo")


def obtener_inventario_kits():


    """Consulta todos los kits de inventario alterno."""


    try:


        with get_db_cursor("db_inventario", cursor_factory=RealDictCursor) as cursor:


            cursor.execute("""


                SELECT 


                    codigo_inv_kits AS codigo,


                    descripcion_inv_kits AS descripcion,


                    responsable_inv_kits AS responsable,


                    estado_inv_kits AS estado,


                    observaciones_inv_kits AS observaciones


                FROM inventario_kits 


                ORDER BY id_inv_kits ASC;


            """)


            kits = cursor.fetchall()


        return kits


    except Exception as e:


        raise HTTPException(status_code=500, detail=f"Error en BD Kits: {str(e)}")





@router.get("/api/inventario/radar-danos")


def obtener_radar_danos():


    """Consulta la tabla reparaciones y la cruza con los nombres de personal."""


    try:


        with get_db_cursor("db_personal", cursor_factory=RealDictCursor) as cursor_emp:


            cursor_emp.execute("SELECT id_empleado, nombre FROM public.empleados;")


            empleados_db = cursor_emp.fetchall()





        mapa_empleados = {str(emp["id_empleado"]).strip(): emp["nombre"] for emp in empleados_db}





        with get_db_cursor("db_inventario", cursor_factory=RealDictCursor) as cursor_inv:


            cursor_inv.execute("""


                SELECT 


                    r.num_d_servicio AS "NUM_SERVICIO",


                    r.fecha_d_reporte AS "FECHA_REPORTE",


                    r.equipo_n_reparacion AS "ID",


                    COALESCE(i.descripcion, k.descripcion_inv_kits, r.equipo_n_reparacion) AS "EQUIPO",


                    r.area_q_pertenece AS "DEPARTAMENTO",


                    r.reportante AS "REPORTÓ_RAW",


                    r.estado_actual AS "ESTADO",


                    r.descripcion_del_dano AS "FALLA",


                    COALESCE(r.costo_d_reparacion, 0.0) AS "COSTO",


                    r.folio_vpro AS "FOLIO"


                FROM public.reparaciones r


                LEFT JOIN public.inventario i ON (UPPER(TRIM(r.equipo_n_reparacion)) = UPPER(TRIM(i.codigo)) OR UPPER(TRIM(r.equipo_n_reparacion)) = UPPER(TRIM(i.descripcion)))


                LEFT JOIN public.inventario_kits k ON (UPPER(TRIM(r.equipo_n_reparacion)) = UPPER(TRIM(k.codigo_inv_kits)) OR UPPER(TRIM(r.equipo_n_reparacion)) = UPPER(TRIM(k.descripcion_inv_kits)))


                WHERE UPPER(COALESCE(r.estado_actual, '')) NOT IN ('RESUELTO', 'REPARADO', 'OK', 'BAJA DEFINITIVA')


                ORDER BY r.fecha_d_reporte DESC;


            """)


            danados = cursor_inv.fetchall()





        resultados_finales = []


        servicios_vistos = set()


        for row in danados:


            reportante_crudo = str(row["REPORTÓ_RAW"] or "")


            numeros_encontrados = re.findall(r'\d+', reportante_crudo)


            id_extraido = numeros_encontrados[0] if numeros_encontrados else None


            nombre_real = mapa_empleados.get(id_extraido, reportante_crudo)


            


            fila_limpia = dict(row)


            fila_limpia["REPORTÓ"] = nombre_real


            del fila_limpia["REPORTÓ_RAW"]





            num_serv = str(fila_limpia.get("NUM_SERVICIO") or "").strip()


            if num_serv:


                if num_serv in servicios_vistos:


                    continue


                servicios_vistos.add(num_serv)





            resultados_finales.append(fila_limpia)





        return resultados_finales


    except Exception as e:


        raise HTTPException(status_code=500, detail=f"Error en Radar de Daños: {str(e)}")





@router.get("/api/inventario/historial/{codigo}")
def extraer_expediente_clinico_hardware(codigo: str):
    """Consulta el historial clínico de un equipo por código con chat archivado."""
    query = text("""
        SELECT encode(codigo_equipo::bytea, 'hex') as cod, 
               encode(COALESCE(tipo_evento, '')::bytea, 'hex') as tipo, 
               encode(COALESCE(descripcion, '')::bytea, 'hex') as descr, 
               fecha, 
               encode(COALESCE(folio_vpro, '')::bytea, 'hex') as fol,
               COALESCE(costo_asociado, 0.0) as costo,
               encode(COALESCE(estado_final, 'OK')::bytea, 'hex') as est,
               chat_historial
        FROM public.historial_equipo 
        WHERE LOWER(TRIM(codigo_equipo)) = LOWER(:cod) 
        ORDER BY fecha DESC, id_registro DESC
    """)
    try:
        with engine_inventario.connect() as conn:
            rows = conn.execute(query, {"cod": codigo.strip()}).fetchall()
        return [
            {
                "codigo_equipo": safe_decode_hex(r[0]),
                "tipo_evento": reparar_mojibake(safe_decode_hex(r[1])),
                "descripcion": reparar_mojibake(safe_decode_hex(r[2])),
                "fecha": str(r[3]) if r[3] else None,
                "folio_vpro": safe_decode_hex(r[4]),
                "costo_asociado": float(r[5] or 0.0),
                "estado_final": reparar_mojibake(safe_decode_hex(r[6])),
                "chat_historial": r[7] if r[7] else []
            } 
            for r in rows
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/api/inventario/historial/guardar")


def registrar_receta_tratamiento_medico(log: dict):


    """Inyecta el reporte en historial_equipo y sincroniza la tabla reparaciones."""


    try:


        cod_eq = str(log.get("codigo_equipo", "")).strip().upper()


        est_final = str(log.get("estado_final", "PENDIENTE")).strip().upper()


        fol_vpro = str(log.get("folio_vpro", "MANTENIMIENTO_INTERNO")).strip()


        depto = str(log.get("departamento", "OFICINA")).strip().upper()


        desc = str(log.get("descripcion", "")).strip()


        costo = float(log.get("costo_asociado", 0.0))


        emp_id = str(log.get("id_empleado", "000")).strip()





        with get_db_cursor("db_inventario", commit=True) as cursor:


            cursor.execute("""


                INSERT INTO public.historial_equipo 


                    (codigo_equipo, fecha, folio_vpro, id_empleado, tipo_evento, descripcion, costo_asociado, estado_final, departamento)


                VALUES 


                    (%s, CURRENT_DATE, %s, %s, %s, %s, %s, %s, %s);


            """, (cod_eq, fol_vpro, emp_id, str(log.get("tipo_evento", "MANTENIMIENTO_TÉCNICO")), desc, costo, est_final, depto))





            estados_taller = ["DIAGNOSTICO", "ESPERA_REFACCION", "EN_REPARACION", "CONTROL_CALIDAD", "PENDIENTE", "EN TALLER", "DAÑADO", "DANADO", "BAJA"]


            if est_final in estados_taller:


                etapa_taller = est_final if est_final in ["DIAGNOSTICO", "ESPERA_REFACCION", "EN_REPARACION", "CONTROL_CALIDAD"] else "DIAGNOSTICO"


                if cod_eq.startswith("INV_VPRO_ALT_"):


                    cursor.execute("UPDATE public.inventario_kits SET estado_inv_kits = 'DANADO' WHERE UPPER(codigo_inv_kits) = %s OR UPPER(descripcion_inv_kits) = %s;", (cod_eq, cod_eq))


                else:


                    cursor.execute("UPDATE public.inventario SET estado = 'DAÑADO' WHERE UPPER(codigo) = %s OR UPPER(descripcion) = %s;", (cod_eq, cod_eq))


                


                ticket_id = f"REP-INT-{int(time.time())}"


                cursor.execute("""


                    INSERT INTO public.reparaciones 


                        (num_d_servicio, fecha_d_reporte, equipo_n_reparacion, area_q_pertenece, reportante, estado_actual, etapa_taller, tipo_mantenimiento, descripcion_del_dano, costo_d_reparacion, folio_vpro, fec_d_ent_a_reparacion)


                    VALUES 


                        (%s, CURRENT_DATE, %s, %s, %s, %s, %s, %s, %s, %s, %s, CURRENT_DATE);


                """, (ticket_id, cod_eq, depto, f"Empleado ID: {emp_id}", "⚙️ PENDIENTE", etapa_taller, "CORRECTIVO", desc, costo, fol_vpro))


                


            elif est_final in ["RESUELTO", "OK", "BUEN ESTADO"]:


                if cod_eq.startswith("INV_VPRO_ALT_"):


                    cursor.execute("UPDATE public.inventario_kits SET estado_inv_kits = 'BUEN ESTADO' WHERE UPPER(codigo_inv_kits) = %s OR UPPER(descripcion_inv_kits) = %s;", (cod_eq, cod_eq))


                else:


                    cursor.execute("UPDATE public.inventario SET estado = 'OK' WHERE UPPER(codigo) = %s OR UPPER(descripcion) = %s;", (cod_eq, cod_eq))





                cursor.execute("UPDATE public.reparaciones SET estado_actual = 'RESUELTO' WHERE UPPER(equipo_n_reparacion) = %s;", (cod_eq,))





        return {"status": "SUCCESS"}


    except Exception as e:


        raise HTTPException(status_code=500, detail=f"Error al guardar expediente: {str(e)}")





@router.post("/api/inventario/reparacion/cerrar/{num_servicio}")


def cerrar_ticket_reparacion(num_servicio: str, payload: dict):


    """Permite dar de alta o reparar un equipo desde la interfaz del Radar."""


    try:


        nuevo_estatus = str(payload.get("estado_actual", "RESUELTO")).strip().upper()


        with get_db_cursor("db_inventario", commit=True) as cursor:


            cursor.execute("SELECT equipo_n_reparacion FROM public.reparaciones WHERE num_d_servicio = %s;", (num_servicio,))


            row = cursor.fetchone()


            


            if row:


                cod_eq = str(row[0]).strip().upper()


                cursor.execute("UPDATE public.reparaciones SET estado_actual = %s WHERE num_d_servicio = %s;", (nuevo_estatus, num_servicio))
                if nuevo_estatus in ['RESUELTO', 'REPARADO', 'OK', 'BAJA DEFINITIVA', 'BAJA']:
                    try:
                        _sellar_chat_taller(cursor, num_servicio, 'TECNICO RADAR')
                    except Exception as _e_sell:
                        print(f'Error al sellar chat radar: {_e_sell}')


                


                if nuevo_estatus in ["RESUELTO", "REPARADO", "OK"]:


                    if cod_eq.startswith("INV_VPRO_ALT_"):


                        cursor.execute("UPDATE public.inventario_kits SET estado_inv_kits = 'BUEN ESTADO' WHERE UPPER(codigo_inv_kits) = %s OR UPPER(descripcion_inv_kits) = %s;", (cod_eq, cod_eq))


                    else:


                        cursor.execute("UPDATE public.inventario SET estado = 'OK' WHERE UPPER(codigo) = %s OR UPPER(descripcion) = %s;", (cod_eq, cod_eq))


                elif nuevo_estatus in ["BAJA DEFINITIVA", "BAJA"]:


                    if cod_eq.startswith("INV_VPRO_ALT_"):


                        cursor.execute("UPDATE public.inventario_kits SET estado_inv_kits = 'BAJA' WHERE UPPER(codigo_inv_kits) = %s OR UPPER(descripcion_inv_kits) = %s;", (cod_eq, cod_eq))


                    else:


                        cursor.execute("UPDATE public.inventario SET estado = 'BAJA' WHERE UPPER(codigo) = %s OR UPPER(descripcion) = %s;", (cod_eq, cod_eq))





        return {"status": "SUCCESS"}


    except Exception as e:


        raise HTTPException(status_code=500, detail=str(e))





@router.get("/api/inventario/catalogo-global")


def obtener_catalogo_global_inventario():


    """Obtiene el catálogo consolidado de códigos y descripciones de inventario y kits."""


    try:


        items_globales = set()


        with engine_inventario.connect() as conn:


            rows_kits = conn.execute(text("""


                SELECT codigo_inv_kits, descripcion_inv_kits 


                FROM public.inventario_kits 


                WHERE descripcion_inv_kits IS NOT NULL 


                  AND descripcion_inv_kits NOT IN ('', 'None', 'nan', 'NaN', 'Equipo no registrado')


            """)).fetchall()


            for r in rows_kits:


                cod = str(r[0]).strip() if r[0] else ""


                desc = str(r[1]).strip() if r[1] else ""


                if cod and desc and cod.upper() != desc.upper():


                    items_globales.add(f"{cod} - {desc}")


                elif desc:


                    items_globales.add(desc)


                elif cod:


                    items_globales.add(cod)


                


            rows_master = conn.execute(text("""


                SELECT codigo, descripcion 


                FROM public.inventario 


                WHERE (descripcion IS NOT NULL AND descripcion NOT IN ('', 'None', 'nan', 'NaN', 'Equipo no registrado'))


                   OR (codigo IS NOT NULL AND codigo NOT IN ('', 'None', 'nan', 'NaN'))


            """)).fetchall()


            for r in rows_master:


                cod = str(r[0]).strip() if r[0] else ""


                desc = str(r[1]).strip() if r[1] else ""


                if cod and desc and cod.upper() != desc.upper():


                    items_globales.add(f"{cod} - {desc}")


                elif desc:


                    items_globales.add(desc)


                elif cod:


                    items_globales.add(cod)


                


        return sorted(list(items_globales))


    except Exception as e:


        raise HTTPException(status_code=500, detail=str(e))





@router.get("/api/inventario-kits/ultimo-id-alterno/{id_empleado}")


def obtener_ultimo_id_alterno_empleado(id_empleado: str):


    """Consulta el último ID secuencial de kits asignados al empleado."""


    try:


        with engine_inventario.connect() as conn:


            patron = f"Inv_alt_{id_empleado.strip()}%"


            row = conn.execute(


                text("SELECT codigo_inv_kits FROM public.inventario_kits WHERE codigo_inv_kits LIKE :patron ORDER BY codigo_inv_kits DESC LIMIT 1"), 


                {"patron": patron}


            ).fetchone()


            if row and row[0]:


                val_str = str(row[0]).strip()


                prefijo = f"Inv_alt_{id_empleado.strip()}"


                str_num = val_str.replace(prefijo, "")


                try:


                    return {"ultimo_id": int(str_num)}


                except Exception as e:


                    print(f"⚠️ SILENCED ERROR in inventario.py: {e}")


        return {"ultimo_id": 0}


    except Exception:


        return {"ultimo_id": 0}





@router.post("/api/inventario/subir-evidencia")


def subir_evidencia_falla(codigo_equipo: str = Form(...), folio_vpro: str = Form(...), file: UploadFile = File(...)):


    """Guarda una fotografía de evidencia de falla física de equipo."""


    try:


        cod_safe = codigo_equipo.replace("/", "_").replace("\\", "_").replace(" ", "_").strip().upper()


        fol_safe = folio_vpro.replace("/", "_").replace("\\", "_").replace(" ", "_").strip().upper()


        


        filename = f"Evidencia_{fol_safe}_{cod_safe}.jpg"


        filepath = os.path.join(DIR_EVIDENCIAS_REAL, filename)


        


        with open(filepath, "wb") as buffer:


            shutil.copyfileobj(file.file, buffer)


            


        return {"status": "SUCCESS"}


    except Exception as e: 


        raise HTTPException(status_code=500, detail=str(e))





@router.get("/api/inventario/evidencia/{folio_vpro}/{codigo_equipo}")


def obtener_evidencia_falla(folio_vpro: str, codigo_equipo: str):


    """Descarga la evidencia fotográfica de daño de un equipo."""


    try:


        cod_safe = codigo_equipo.replace("/", "_").replace("\\", "_").strip().upper()


        fol_safe = folio_vpro.replace("/", "_").replace("\\", "_").strip().upper()


        filename_evidencia = f"Evidencia_{fol_safe}_{cod_safe}.jpg"


        filepath_evidencia = os.path.join(DIR_EVIDENCIAS_REAL, filename_evidencia)


        


        filepath_generico = None


        for ext in ['.jpg', '.png', '.jpeg', '.JPG', '.PNG', '.JPEG']:


            p_prueba = os.path.join(DIR_EVIDENCIAS_REAL, f"{cod_safe}{ext}")


            if os.path.exists(p_prueba):


                filepath_generico = p_prueba


                break


        


        target_path = filepath_evidencia if os.path.exists(filepath_evidencia) else filepath_generico


        if target_path and os.path.exists(target_path):


            with open(target_path, "rb") as f:


                encoded = base64.b64encode(f.read()).decode("utf-8")


            return {"status": "SUCCESS", "imagen_b64": f"data:image/jpeg;base64,{encoded}"}


        return {"status": "NOT_FOUND"}


    except Exception as e:


        raise HTTPException(status_code=500, detail=str(e))





@router.get("/api/inventario/expediente/{codigo_equipo:path}")


def consultar_expediente_equipo(codigo_equipo: str, request: Request):


    """Consulta el expediente completo de un equipo (historial y fotografías)."""


    try:


        with get_db_cursor("db_inventario", cursor_factory=RealDictCursor) as cursor:


            cursor.execute("""


                SELECT 


                    to_char(fecha, 'YYYY-MM-DD') as "FECHA",


                    tipo_evento as "TIPO DE EVENTO",


                    folio_vpro as "FOLIO OP / REF",


                    departamento as "ÁREA",


                    descripcion as "DIAGNÓSTICO / NOTAS",


                    estado_final as "ESTADO POSTERIOR",


                    COALESCE(costo_asociado, 0.0) as "COSTO ($)"


                FROM public.historial_equipo 


                WHERE LOWER(TRIM(codigo_equipo)) = LOWER(TRIM(%s))


                   OR LOWER(TRIM(codigo_equipo)) IN (


                       SELECT LOWER(TRIM(descripcion)) FROM public.inventario WHERE LOWER(TRIM(codigo)) = LOWER(TRIM(%s))


                       UNION


                       SELECT LOWER(TRIM(descripcion_inv_kits)) FROM public.inventario_kits WHERE LOWER(TRIM(codigo_inv_kits)) = LOWER(TRIM(%s))


                   )


                   OR LOWER(TRIM(codigo_equipo)) IN (


                       SELECT LOWER(TRIM(codigo)) FROM public.inventario WHERE LOWER(TRIM(descripcion)) = LOWER(TRIM(%s))


                       UNION


                       SELECT LOWER(TRIM(codigo_inv_kits)) FROM public.inventario_kits WHERE LOWER(TRIM(descripcion_inv_kits)) = LOWER(TRIM(%s))


                   )


                ORDER BY fecha DESC, id_registro DESC;


            """, (codigo_equipo, codigo_equipo, codigo_equipo, codigo_equipo, codigo_equipo))


            historial_db = cursor.fetchall()





        fotos_encontradas = []


        if os.path.exists(DIR_EVIDENCIAS_REAL):


            codigo_limpio = codigo_equipo.replace(" ", "_").lower()


            terminos_busqueda = [codigo_limpio]


            


            # Agregar descripciones asociadas a los términos de búsqueda de fotos


            with get_db_cursor("db_inventario", cursor_factory=RealDictCursor) as cursor_alias:


                cursor_alias.execute("""


                    SELECT descripcion FROM public.inventario WHERE LOWER(TRIM(codigo)) = LOWER(TRIM(%s))


                    UNION


                    SELECT descripcion_inv_kits FROM public.inventario_kits WHERE LOWER(TRIM(codigo_inv_kits)) = LOWER(TRIM(%s));


                """, (codigo_equipo, codigo_equipo))


                for row_alias in cursor_alias.fetchall():


                    if row_alias.get("descripcion"):


                        terminos_busqueda.append(row_alias["descripcion"].replace(" ", "_").lower())





            for nombre_archivo in os.listdir(DIR_EVIDENCIAS_REAL):


                archivo_limpio = nombre_archivo.replace(" ", "_").lower()


                if any(term in archivo_limpio for term in terminos_busqueda) and nombre_archivo.lower().endswith(('.png', '.jpg', '.jpeg')):


                    url_foto = f"Fotos_de_equipos/{nombre_archivo}" 


                    if url_foto not in fotos_encontradas:


                        fotos_encontradas.append(url_foto)





        return {


            "historial": historial_db,


            "fotos": fotos_encontradas


        }


    except Exception as e:


        raise HTTPException(status_code=500, detail=f"Error al consultar expediente: {str(e)}")








@router.get("/api/inventario/mis-reportes-dano/{id_empleado}")


def obtener_mis_reportes_dano(id_empleado: str):


    """Obtiene los reportes de equipo dañado activos (sin resolver/reparar) 


    registrados por el empleado. Incluye los días transcurridos para el semáforo de urgencia.


    """


    import datetime


    ESTADOS_ACTIVOS = ("DAÑADO", "⚙️ DAÑADO", "EN REPARACION", "EN REVISIÓN", "PENDIENTE")


    try:


        with get_db_cursor("db_inventario", cursor_factory=RealDictCursor) as cursor:


            cursor.execute("""


                SELECT 


                    r.num_d_servicio,


                    r.fecha_d_reporte,


                    r.equipo_n_reparacion,


                    COALESCE(i.descripcion, k.descripcion_inv_kits, r.equipo_n_reparacion) as nombre_equipo,


                    r.descripcion_del_dano,


                    r.estado_actual,


                    r.area_q_pertenece


                FROM public.reparaciones r


                LEFT JOIN public.inventario i ON LOWER(TRIM(r.equipo_n_reparacion)) = LOWER(TRIM(i.codigo))


                LEFT JOIN public.inventario_kits k ON LOWER(TRIM(r.equipo_n_reparacion)) = LOWER(TRIM(k.codigo_inv_kits))


                WHERE r.reportante = %s


                  AND UPPER(TRIM(r.estado_actual)) NOT IN (


                      'REPARADO', 'RESUELTO', 'BAJA DEFINITIVA', 'CERRADO'


                  )


                ORDER BY r.fecha_d_reporte DESC


            """, (f"Empleado ID: {id_empleado.strip()}",))


            rows = cursor.fetchall()





        hoy = datetime.date.today()


        resultado = []


        for r in rows:


            fecha_rep = r.get("fecha_d_reporte")


            dias = (hoy - fecha_rep).days if fecha_rep else 0





            if dias == 0:


                urgencia = "verde"


            elif dias <= 2:


                urgencia = "naranja"


            else:


                urgencia = "rojo"





            resultado.append({


                "ticket":        r.get("num_d_servicio", ""),


                "equipo":        r.get("equipo_n_reparacion", ""),


                "nombre_equipo": r.get("nombre_equipo", ""),


                "descripcion": r.get("descripcion_del_dano", ""),


                "estado":      r.get("estado_actual", ""),


                "area":        r.get("area_q_pertenece", ""),


                "fecha":       str(fecha_rep) if fecha_rep else "",


                "dias":        dias,


                "urgencia":    urgencia,


            })


        return resultado


    except Exception as e:


        raise HTTPException(status_code=500, detail=str(e))








# ==============================================================================


# 🛠️ MÓDULO INTEGRADO DE MANTENIMIENTO VPRO (KANBAN, PREVENTIVOS Y QC)


# ==============================================================================





@router.get("/api/inventario/mantenimiento/kanban")


def obtener_tablero_kanban_mantenimiento():


    """Retorna los tickets activos de taller clasificados para el tablero Kanban."""


    try:


        with get_db_cursor("db_personal", cursor_factory=RealDictCursor) as cursor_emp:


            cursor_emp.execute("SELECT id_empleado, nombre FROM public.empleados;")


            mapa_empleados = {str(emp["id_empleado"]).strip(): emp["nombre"] for emp in cursor_emp.fetchall()}





        with get_db_cursor("db_inventario", cursor_factory=RealDictCursor) as cursor_inv:


            cursor_inv.execute("""


                SELECT 


                    r.num_d_servicio AS "ticket",


                    r.fecha_d_reporte AS "fecha_reporte",


                    r.equipo_n_reparacion AS "id_equipo",


                    COALESCE(i.descripcion, k.descripcion_inv_kits, r.equipo_n_reparacion) AS "nombre_equipo",


                    r.area_q_pertenece AS "departamento",


                    r.reportante AS "reportante_raw",


                    r.estado_actual AS "estado",


                    COALESCE(r.etapa_taller, 'DIAGNOSTICO') AS "etapa",


                    COALESCE(r.tipo_mantenimiento, 'CORRECTIVO') AS "tipo_mantenimiento",


                    r.descripcion_del_dano AS "falla",


                    COALESCE(r.costo_d_reparacion, 0.0) AS "costo",


                    r.folio_vpro AS "folio",


                    COALESCE(r.encargado_d_reparacion, 'Sin Asignar') AS "encargado",


                    r.fecha_prometida AS "fecha_prometida",


                    r.detalles_de_reparacion AS "notas",


                    COALESCE(r.checklist_calidad, '{}'::jsonb) AS "checklist_calidad"


                FROM public.reparaciones r


                LEFT JOIN public.inventario i ON (UPPER(TRIM(r.equipo_n_reparacion)) = UPPER(TRIM(i.codigo)) OR UPPER(TRIM(r.equipo_n_reparacion)) = UPPER(TRIM(i.descripcion)))


                LEFT JOIN public.inventario_kits k ON (UPPER(TRIM(r.equipo_n_reparacion)) = UPPER(TRIM(k.codigo_inv_kits)) OR UPPER(TRIM(r.equipo_n_reparacion)) = UPPER(TRIM(k.descripcion_inv_kits)))


                WHERE UPPER(COALESCE(r.estado_actual, '')) NOT IN ('RESUELTO', 'REPARADO', 'OK', 'BAJA DEFINITIVA', 'BAJA', 'CERRADO')


                ORDER BY r.fecha_d_reporte ASC;


            """)


            raw_tickets = cursor_inv.fetchall()





        hoy = datetime.date.today()


        kanban = {


            "DIAGNOSTICO": [],


            "ESPERA_REFACCION": [],


            "EN_REPARACION": [],


            "CONTROL_CALIDAD": []


        }





        vistos = set()


        for t in raw_tickets:


            num = str(t.get("ticket") or "").strip()


            if num in vistos:


                continue


            vistos.add(num)





            raw_rep = str(t.get("reportante_raw") or "")


            ids_found = re.findall(r'\d+', raw_rep)


            emp_id = ids_found[0] if ids_found else None


            t["reporto"] = mapa_empleados.get(emp_id, raw_rep)





            f_rep = t.get("fecha_reporte")


            t["dias_en_taller"] = (hoy - f_rep).days if f_rep else 0


            t["fecha_reporte"] = str(f_rep) if f_rep else ""


            t["fecha_prometida"] = str(t.get("fecha_prometida")) if t.get("fecha_prometida") else ""


            


            # Etapa segura


            etapa = str(t.get("etapa") or "DIAGNOSTICO").strip().upper()


            if etapa not in kanban:


                etapa = "DIAGNOSTICO"


            t["etapa"] = etapa





            kanban[etapa].append(t)





        return {


            "kanban": kanban,


            "total_activos": len(vistos),


            "resumen_etapas": {k: len(v) for k, v in kanban.items()}


        }


    except Exception as e:


        raise HTTPException(status_code=500, detail=f"Error en Kanban: {str(e)}")








@router.post("/api/inventario/mantenimiento/cambiar-etapa")


def cambiar_etapa_taller(payload: dict):


    """Mueve un ticket de mantenimiento entre etapas Kanban."""


    num_servicio = str(payload.get("num_servicio", "")).strip()


    nueva_etapa = str(payload.get("nueva_etapa", "")).strip().upper()


    encargado = payload.get("encargado")


    costo = payload.get("costo")


    fecha_prometida = payload.get("fecha_prometida")


    notas = payload.get("notas")





    etapas_validas = ["DIAGNOSTICO", "ESPERA_REFACCION", "EN_REPARACION", "CONTROL_CALIDAD"]


    if nueva_etapa not in etapas_validas:


        raise HTTPException(status_code=400, detail=f"Etapa inválida. Permitidas: {etapas_validas}")





    if not num_servicio:


        raise HTTPException(status_code=400, detail="Falta num_servicio")





    try:


        with get_db_cursor("db_inventario", commit=True) as cursor:


            # Consultar ticket previo


            cursor.execute("SELECT num_d_servicio, equipo_n_reparacion, detalles_de_reparacion, folio_vpro FROM public.reparaciones WHERE num_d_servicio = %s;", (num_servicio,))


            row = cursor.fetchone()


            if not row:


                raise HTTPException(status_code=404, detail="Ticket no encontrado")





            cod_equipo = str(row[1]).strip()


            folio_ref = str(row[3] or "MANTENIMIENTO")





            updates = ["etapa_taller = %s"]


            params = [nueva_etapa]





            if encargado is not None:


                updates.append("encargado_d_reparacion = %s")


                params.append(str(encargado).strip())





            if costo is not None:


                updates.append("costo_d_reparacion = %s")


                params.append(float(costo))





            if fecha_prometida:


                updates.append("fecha_prometida = %s")


                params.append(fecha_prometida)





            if notas:


                nota_acumulada = f"[{datetime.date.today()}] ({nueva_etapa}): {notas}\n" + (row[2] or "")


                updates.append("detalles_de_reparacion = %s")


                params.append(nota_acumulada)





            params.append(num_servicio)


            sql = f"UPDATE public.reparaciones SET {', '.join(updates)} WHERE num_d_servicio = %s;"


            cursor.execute(sql, tuple(params))





            # Guardar entrada en historial si hay nota o cambio significativo


            if notas:


                cursor.execute("""


                    INSERT INTO public.historial_equipo 


                    (codigo_equipo, fecha, folio_vpro, id_empleado, tipo_evento, descripcion, costo_asociado, estado_final, departamento)


                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);


                """, (


                    cod_equipo,


                    datetime.date.today(),


                    folio_ref,


                    encargado or "TALLER",


                    f"AVANCE_TALLER_{nueva_etapa}",


                    notas,


                    float(costo or 0.0),


                    f"ETAPA_{nueva_etapa}",


                    "TALLER"


                ))





        return {"status": "SUCCESS", "num_servicio": num_servicio, "nueva_etapa": nueva_etapa}


    except HTTPException:


        raise


    except Exception as e:


        raise HTTPException(status_code=500, detail=str(e))








@router.post("/api/inventario/mantenimiento/liberar-qc")


def liberar_equipo_control_calidad(payload: dict):


    """Cierra el ciclo de mantenimiento con checklist de calidad y rehabilita el activo."""


    num_servicio = str(payload.get("num_servicio", "")).strip()


    resultado = str(payload.get("resultado", "APROBADO_OK")).strip().upper()


    checklist = payload.get("checklist", {})


    tecnico = str(payload.get("tecnico_responsable", "TECNICO_QC")).strip()


    observaciones = str(payload.get("observaciones", "Liberado con éxito tras mantenimiento.")).strip()


    costo_final = float(payload.get("costo_final", 0.0))





    if not num_servicio:


        raise HTTPException(status_code=400, detail="Falta num_servicio")





    try:


        hoy = datetime.date.today()


        with get_db_cursor("db_inventario", commit=True) as cursor:


            cursor.execute("SELECT equipo_n_reparacion, folio_vpro, tipo_mantenimiento FROM public.reparaciones WHERE num_d_servicio = %s;", (num_servicio,))


            row = cursor.fetchone()


            if not row:


                raise HTTPException(status_code=404, detail="Ticket no encontrado")





            cod_eq = str(row[0]).strip().upper()


            folio_ref = str(row[1] or "MANTENIMIENTO")


            tipo_mant = str(row[2] or "CORRECTIVO")





            if resultado in ["APROBADO_OK", "REPARADO", "RESUELTO"]:


                nuevo_estado_ticket = "RESUELTO"


                nueva_etapa = "LISTO"


                estado_activo_inv = "OK"


                estado_kits = "BUEN ESTADO"


                tipo_evento_historial = "LIBERACION_QC_OK"


            else:


                nuevo_estado_ticket = "BAJA DEFINITIVA"


                nueva_etapa = "BAJA"


                estado_activo_inv = "BAJA"


                estado_kits = "BAJA"


                tipo_evento_historial = "BAJA_DEFINITIVA_TALLER"





            # 1. Actualizar ticket


            cursor.execute("""


                UPDATE public.reparaciones 


                SET estado_actual = %s,


                    etapa_taller = %s,


                    checklist_calidad = %s,


                    recibe_equipo = %s,


                    fecha_d_entrega = %s,


                    costo_d_reparacion = GREATEST(COALESCE(costo_d_reparacion, 0.0), %s)


                WHERE num_d_servicio = %s;


            """, (


                nuevo_estado_ticket,


                nueva_etapa,


                json.dumps(checklist),


                tecnico,


                hoy,


                costo_final,


                num_servicio


            ))





            # 2. Actualizar activo en inventario


            if cod_eq.startswith("INV_VPRO_ALT_"):


                cursor.execute("""


                    UPDATE public.inventario_kits 


                    SET estado_inv_kits = %s 


                    WHERE UPPER(codigo_inv_kits) = %s OR UPPER(descripcion_inv_kits) = %s;


                """, (estado_kits, cod_eq, cod_eq))


            else:


                # Si tiene frecuencia preventiva, calcular próxima fecha


                cursor.execute("SELECT frecuencia_mantenimiento_dias FROM public.inventario WHERE UPPER(codigo) = %s OR UPPER(descripcion) = %s;", (cod_eq, cod_eq))


                inv_row = cursor.fetchone()


                frecuencia = inv_row[0] if inv_row else None





                proxima_fecha = None


                if frecuencia and int(frecuencia) > 0 and resultado == "APROBADO_OK":


                    proxima_fecha = hoy + datetime.timedelta(days=int(frecuencia))





                cursor.execute("""


                    UPDATE public.inventario 


                    SET estado = %s,


                        fecha_ultimo_mantenimiento = %s,


                        fecha_proximo_mantenimiento = COALESCE(%s, fecha_proximo_mantenimiento)


                    WHERE UPPER(codigo) = %s OR UPPER(descripcion) = %s;


                """, (estado_activo_inv, hoy, proxima_fecha, cod_eq, cod_eq))





            # Sellar chat de taller y archivarlo
            chat_sellado = _sellar_chat_taller(cursor, num_servicio, tecnico)

            # 3. Registrar en historial clínico con el chat archivado
            detalle_hist = f"Control de Calidad: {resultado}. Técnico: {tecnico}. Checklist: {json.dumps(checklist)}. Notas: {observaciones}"
            cursor.execute("""
                INSERT INTO public.historial_equipo 
                (codigo_equipo, fecha, folio_vpro, id_empleado, tipo_evento, descripcion, costo_asociado, estado_final, departamento, chat_historial)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
            """, (
                cod_eq,
                hoy,
                num_servicio,
                tecnico,
                tipo_evento_historial,
                detalle_hist,
                costo_final,
                estado_activo_inv,
                "TALLER_QC",
                json.dumps(chat_sellado)
            ))





        return {


            "status": "SUCCESS",


            "resultado": resultado,


            "num_servicio": num_servicio,


            "equipo": cod_eq,


            "estado_inventario": estado_activo_inv


        }


    except HTTPException:


        raise


    except Exception as e:


        raise HTTPException(status_code=500, detail=str(e))








@router.get("/api/inventario/mantenimiento/preventivos")


def obtener_radar_preventivos():


    """Consulta los activos que tienen configurado plan de mantenimiento preventivo."""


    try:


        hoy = datetime.date.today()


        with get_db_cursor("db_inventario", cursor_factory=RealDictCursor) as cursor:


            cursor.execute("""


                SELECT 


                    codigo,


                    descripcion,


                    marca,


                    modelo,


                    ubicacion,


                    estado,


                    frecuencia_mantenimiento_dias,


                    fecha_ultimo_mantenimiento,


                    fecha_proximo_mantenimiento


                FROM public.inventario


                WHERE frecuencia_mantenimiento_dias IS NOT NULL 


                  AND frecuencia_mantenimiento_dias > 0


                ORDER BY fecha_proximo_mantenimiento ASC NULLS FIRST;


            """)


            activos = cursor.fetchall()





        resultado = []


        for a in activos:


            f_prox = a.get("fecha_proximo_mantenimiento")


            dias_restantes = (f_prox - hoy).days if f_prox else None





            if dias_restantes is None:


                semaforo = "PENDIENTE_CALCULO"


                urgencia = "gris"


            elif dias_restantes < 0:


                semaforo = "VENCIDO"


                urgencia = "rojo"


            elif dias_restantes <= 7:


                semaforo = "URGENTE_ESTA_SEMANA"


                urgencia = "naranja"


            elif dias_restantes <= 20:


                semaforo = "PROXIMO"


                urgencia = "amarillo"


            else:


                semaforo = "AL_DIA"


                urgencia = "verde"





            resultado.append({


                "codigo": a.get("codigo"),


                "descripcion": a.get("descripcion"),


                "marca": a.get("marca") or "",


                "modelo": a.get("modelo") or "",


                "ubicacion": a.get("ubicacion") or "",


                "estado_actual": a.get("estado") or "OK",


                "frecuencia_dias": a.get("frecuencia_mantenimiento_dias"),


                "ultimo_mantenimiento": str(a.get("fecha_ultimo_mantenimiento")) if a.get("fecha_ultimo_mantenimiento") else "Sin registro",


                "proximo_mantenimiento": str(f_prox) if f_prox else "Inmediato",


                "dias_restantes": dias_restantes,


                "semaforo": semaforo,


                "urgencia": urgencia


            })





        return resultado


    except Exception as e:


        raise HTTPException(status_code=500, detail=str(e))








@router.post("/api/inventario/mantenimiento/programar-preventivo")


def programar_frecuencia_preventiva(payload: dict):


    """Establece la frecuencia de días y próxima fecha para el mantenimiento de un activo."""


    codigo = str(payload.get("codigo_equipo", "")).strip()


    frecuencia_dias = int(payload.get("frecuencia_dias", 30))


    fecha_proximo = payload.get("fecha_proximo_mantenimiento")





    if not codigo:


        raise HTTPException(status_code=400, detail="Falta codigo_equipo")





    try:


        hoy = datetime.date.today()


        if not fecha_proximo:


            fecha_proximo = hoy + datetime.timedelta(days=frecuencia_dias)





        with get_db_cursor("db_inventario", commit=True) as cursor:


            cursor.execute("""


                UPDATE public.inventario 


                SET frecuencia_mantenimiento_dias = %s,


                    fecha_proximo_mantenimiento = %s


                WHERE UPPER(codigo) = %s OR UPPER(descripcion) = %s;


            """, (frecuencia_dias, fecha_proximo, codigo.upper(), codigo.upper()))





        return {


            "status": "SUCCESS", 


            "codigo": codigo, 


            "frecuencia_dias": frecuencia_dias, 


            "fecha_proximo": str(fecha_proximo)


        }


    except Exception as e:


        raise HTTPException(status_code=500, detail=str(e))








@router.post("/api/inventario/mantenimiento/crear-ticket-preventivo")


def crear_ticket_mantenimiento_preventivo(payload: dict):


    """Genera una orden de mantenimiento preventivo periódica que entra directo al tablero Kanban."""


    codigo_equipo = str(payload.get("codigo_equipo", "")).strip()


    id_empleado = str(payload.get("id_empleado", "SISTEMAS")).strip()


    descripcion = str(payload.get("descripcion", "Rutina periódica de mantenimiento preventivo")).strip()


    departamento = str(payload.get("departamento", "OPERACIONES")).strip().upper()





    if not codigo_equipo:


        raise HTTPException(status_code=400, detail="Falta codigo_equipo")





    try:


        import random


        num_servicio = f"REP-PRV-{int(time.time())}"


        hoy = datetime.date.today()





        with get_db_cursor("db_inventario", commit=True) as cursor:


            # Obtener datos de inventario


            cursor.execute("SELECT descripcion, marca, modelo FROM public.inventario WHERE UPPER(codigo) = %s OR UPPER(descripcion) = %s;", (codigo_equipo.upper(), codigo_equipo.upper()))


            inv = cursor.fetchone()


            marca = inv[1] if inv else ""


            modelo = inv[2] if inv else ""





            # 1. Insertar ticket preventivo en reparaciones


            cursor.execute("""


                INSERT INTO public.reparaciones (


                    num_d_servicio, fecha_d_reporte, equipo_n_reparacion, 


                    area_q_pertenece, marca, modelo, folio_vpro, 


                    reportante, estado_actual, etapa_taller, 


                    tipo_mantenimiento, descripcion_del_dano, fec_d_ent_a_reparacion


                ) VALUES (


                    %s, %s, %s, 


                    %s, %s, %s, %s, 


                    %s, %s, %s, 


                    %s, %s, %s


                );


            """, (


                num_servicio, hoy, codigo_equipo,


                departamento, marca, modelo, "RUTINA_PREVENTIVA",


                f"Empleado ID: {id_empleado}", "⚙️ EN MANTENIMIENTO", "DIAGNOSTICO",


                "PREVENTIVO", descripcion, hoy


            ))





            # 2. Marcar equipo como en mantenimiento


            cursor.execute("UPDATE public.inventario SET estado = 'EN MANTENIMIENTO' WHERE UPPER(codigo) = %s OR UPPER(descripcion) = %s;", (codigo_equipo.upper(), codigo_equipo.upper()))





            # 3. Registrar en historial


            cursor.execute("""


                INSERT INTO public.historial_equipo 


                (codigo_equipo, fecha, folio_vpro, id_empleado, tipo_evento, descripcion, costo_asociado, estado_final, departamento)


                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);


            """, (


                codigo_equipo, hoy, "RUTINA_PREVENTIVA", id_empleado,


                "INICIO_MANTENIMIENTO_PREVENTIVO", descripcion, 0.0,


                "EN MANTENIMIENTO", departamento


            ))





        return {


            "status": "SUCCESS",


            "num_servicio": num_servicio,


            "codigo_equipo": codigo_equipo,


            "tipo": "PREVENTIVO",


            "etapa": "DIAGNOSTICO"


        }


    except Exception as e:


        raise HTTPException(status_code=500, detail=str(e))








# ==============================================================================
# 💬 CHAT DE TALLER & REPARACIÓN (TÉCNICO ⇄ REPORTANTE)
# ==============================================================================

def _sellar_chat_taller(cursor, num_servicio: str, cerrador_nombre: str = "TÉCNICO"):
    """
    Sella y congela la conversación entre el técnico y el reportante.
    Archiva los mensajes en JSONB tanto en reparaciones como en historial_equipo.
    """
    try:
        num_clean = str(num_servicio or "").strip()
        if not num_clean:
            return []

        cursor.execute("""
            SELECT id, num_servicio, codigo_equipo, id_empleado, nombre_autor, rol_autor, mensaje, adjunto_url, 
                   to_char(fecha_hora AT TIME ZONE 'UTC' AT TIME ZONE 'America/Mazatlan', 'YYYY-MM-DD HH12:MI AM') as fecha_hora
            FROM public.chat_taller_mensajes
            WHERE num_servicio = %s
            ORDER BY fecha_hora ASC, id ASC;
        """, (num_clean,))
        mensajes_db = cursor.fetchall()
        mensajes = [dict(m) for m in mensajes_db]

        # Verificar si ya estaba cerrado
        cursor.execute("SELECT chat_cerrado FROM public.reparaciones WHERE num_d_servicio = %s;", (num_clean,))
        row_rep = cursor.fetchone()
        ya_cerrado = bool(row_rep and (row_rep[0] if isinstance(row_rep, tuple) else row_rep.get("chat_cerrado")))

        if not ya_cerrado:
            msg_cierre = f"🔒 Servicio concluido y liberado por {cerrador_nombre}. El chat ha sido sellado y archivado permanentemente en el expediente clínico."
            cursor.execute("""
                INSERT INTO public.chat_taller_mensajes (num_servicio, codigo_equipo, id_empleado, nombre_autor, rol_autor, mensaje)
                VALUES (%s, '', 'SISTEMA', 'Sistema VPRO', 'SISTEMA', %s);
            """, (num_clean, msg_cierre))

            cursor.execute("""
                SELECT id, num_servicio, codigo_equipo, id_empleado, nombre_autor, rol_autor, mensaje, adjunto_url, 
                       to_char(fecha_hora AT TIME ZONE 'UTC' AT TIME ZONE 'America/Mazatlan', 'YYYY-MM-DD HH12:MI AM') as fecha_hora
                FROM public.chat_taller_mensajes
                WHERE num_servicio = %s
                ORDER BY fecha_hora ASC, id ASC;
            """, (num_clean,))
            mensajes = [dict(m) for m in cursor.fetchall()]

        # Sellar en reparaciones
        cursor.execute("""
            UPDATE public.reparaciones
            SET chat_cerrado = TRUE,
                chat_cerrado_por = %s,
                chat_fecha_cierre = NOW(),
                chat_historial = %s
            WHERE num_d_servicio = %s;
        """, (cerrador_nombre, json.dumps(mensajes), num_clean))

        # Sellar en historial_equipo para la entrada asociada
        cursor.execute("""
            UPDATE public.historial_equipo
            SET chat_historial = %s
            WHERE folio_vpro = %s OR id_registro IN (
                SELECT id_registro FROM public.historial_equipo 
                WHERE folio_vpro = %s OR descripcion LIKE %s
                ORDER BY id_registro DESC LIMIT 1
            );
        """, (json.dumps(mensajes), num_clean, num_clean, f"%{num_clean}%"))

        return mensajes
    except Exception as e:
        print(f"⚠️ Error al sellar chat de taller {num_servicio}: {e}")
        return []


# Estado volátil de escritura en tiempo real: { num_servicio: { id_empleado: { "nombre": str, "ts": float } } }
_estado_escribiendo_taller: Dict[str, Dict[str, Any]] = {}

@router.post("/api/inventario/mantenimiento/chat/escribiendo")
def notificar_escribiendo_chat_taller(payload: dict):
    """Registra que un usuario está tecleando en el chat de un ticket de taller."""
    num_servicio = str(payload.get("num_servicio", "")).strip()
    id_empleado = str(payload.get("id_empleado", "")).strip()
    nombre_autor = str(payload.get("nombre_autor", "")).strip()

    if not num_servicio or not id_empleado:
        return {"status": "ignored"}

    ahora = time.time()
    if num_servicio not in _estado_escribiendo_taller:
        _estado_escribiendo_taller[num_servicio] = {}

    _estado_escribiendo_taller[num_servicio][id_empleado] = {
        "nombre": nombre_autor or f"Empleado {id_empleado}",
        "ts": ahora
    }

    # Limpieza de viejos (más de 5 segundos)
    _estado_escribiendo_taller[num_servicio] = {
        uid: info for uid, info in _estado_escribiendo_taller[num_servicio].items()
        if ahora - info.get("ts", 0) < 5.0
    }

    return {"status": "ok"}


@router.get("/api/inventario/mantenimiento/chat/{num_servicio}")
def obtener_chat_taller(num_servicio: str, id_lector: Optional[str] = None):
    """Consulta el historial de chat de un ticket de taller activo o archivado."""
    num_clean = str(num_servicio or "").strip()
    if not num_clean:
        raise HTTPException(status_code=400, detail="Falta num_servicio")

    try:
        with get_db_cursor("db_inventario", cursor_factory=RealDictCursor) as cursor:
            cursor.execute("""
                SELECT 
                    num_d_servicio AS ticket,
                    equipo_n_reparacion AS codigo_equipo,
                    reportante,
                    COALESCE(chat_cerrado, FALSE) AS chat_cerrado,
                    chat_cerrado_por,
                    to_char(chat_fecha_cierre, 'YYYY-MM-DD HH24:MI:SS') AS chat_fecha_cierre,
                    chat_historial
                FROM public.reparaciones
                WHERE num_d_servicio = %s;
            """, (num_clean,))
            ticket = cursor.fetchone()

            if not ticket:
                ticket = {
                    "ticket": num_clean,
                    "codigo_equipo": "",
                    "reportante": "Sin asignar",
                    "chat_cerrado": False,
                    "chat_cerrado_por": None,
                    "chat_fecha_cierre": None,
                    "chat_historial": []
                }

            esta_cerrado = bool(ticket.get("chat_cerrado"))

            cursor.execute("""
                SELECT 
                    id,
                    num_servicio,
                    codigo_equipo,
                    id_empleado,
                    nombre_autor,
                    rol_autor,
                    mensaje,
                    adjunto_url,
                    to_char(fecha_hora AT TIME ZONE 'UTC' AT TIME ZONE 'America/Mazatlan', 'YYYY-MM-DD HH12:MI AM') AS fecha_hora
                FROM public.chat_taller_mensajes
                WHERE num_servicio = %s
                ORDER BY fecha_hora ASC, id ASC;
            """, (num_clean,))
            mensajes_db = cursor.fetchall()

            if esta_cerrado and not mensajes_db and ticket.get("chat_historial"):
                raw_hist = ticket.get("chat_historial")
                if isinstance(raw_hist, str):
                    try:
                        mensajes = json.loads(raw_hist)
                    except Exception:
                        mensajes = []
                elif isinstance(raw_hist, list):
                    mensajes = raw_hist
                else:
                    mensajes = []
            else:
                mensajes = [dict(m) for m in mensajes_db]

            rep_raw = str(ticket.get("reportante") or "").strip()
            rep_id = ""
            ids_found = re.findall(r'\d+', rep_raw)
            if ids_found:
                rep_id = ids_found[0]

        rep_nombre = rep_raw
        try:
            with get_db_cursor("db_personal", cursor_factory=RealDictCursor) as cursor_emp:
                if rep_id:
                    cursor_emp.execute("SELECT id_empleado, nombre FROM public.empleados WHERE id_empleado = %s;", (rep_id,))
                else:
                    cursor_emp.execute("SELECT id_empleado, nombre FROM public.empleados WHERE UPPER(TRIM(nombre)) = UPPER(TRIM(%s));", (rep_raw,))
                emp_row = cursor_emp.fetchone()
                if emp_row:
                    rep_nombre = emp_row.get("nombre") or rep_raw
                    rep_id = str(emp_row.get("id_empleado") or rep_id).strip()
        except Exception:
            pass

        # Quien está escribiendo actualmente
        ahora = time.time()
        quienes_escriben = []
        if num_clean in _estado_escribiendo_taller:
            activos = {}
            for uid, info in _estado_escribiendo_taller[num_clean].items():
                if ahora - info.get("ts", 0) < 4.5:
                    activos[uid] = info
                    if str(uid).strip() != str(id_lector or "").strip():
                        quienes_escriben.append(info.get("nombre", "Alguien"))
            _estado_escribiendo_taller[num_clean] = activos

        return {
            "ticket": num_clean,
            "codigo_equipo": ticket.get("codigo_equipo", ""),
            "reportante_id": rep_id,
            "reportante_nombre": rep_nombre,
            "chat_cerrado": esta_cerrado,
            "chat_cerrado_por": ticket.get("chat_cerrado_por") or "",
            "chat_fecha_cierre": ticket.get("chat_fecha_cierre") or "",
            "mensajes": mensajes,
            "quien_escribe": quienes_escriben
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/api/inventario/mantenimiento/chat/enviar")
def enviar_mensaje_chat_taller(payload: dict):
    """Envía un mensaje entre el técnico y el reportante en el ticket de taller."""
    num_servicio = str(payload.get("num_servicio", "")).strip()
    codigo_equipo = str(payload.get("codigo_equipo", "")).strip()
    id_empleado = str(payload.get("id_empleado", "")).strip()
    nombre_autor = str(payload.get("nombre_autor", "")).strip()
    rol_autor = str(payload.get("rol_autor", "TECNICO")).strip().upper()
    mensaje = str(payload.get("mensaje", "")).strip()
    adjunto_url = payload.get("adjunto_url")

    if not num_servicio:
        raise HTTPException(status_code=400, detail="Falta num_servicio")
    if not mensaje:
        raise HTTPException(status_code=400, detail="El mensaje no puede estar vacío")

    try:
        with get_db_cursor("db_inventario", commit=True, cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT chat_cerrado FROM public.reparaciones WHERE num_d_servicio = %s;", (num_servicio,))
            row = cursor.fetchone()
            if row and row.get("chat_cerrado"):
                raise HTTPException(
                    status_code=400, 
                    detail="Este ticket ya fue concluido. El chat está cerrado y archivado en el expediente clínico."
                )

            cursor.execute("""
                INSERT INTO public.chat_taller_mensajes 
                (num_servicio, codigo_equipo, id_empleado, nombre_autor, rol_autor, mensaje, adjunto_url)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                RETURNING id, num_servicio, codigo_equipo, id_empleado, nombre_autor, rol_autor, mensaje, adjunto_url,
                          to_char(fecha_hora AT TIME ZONE 'UTC' AT TIME ZONE 'America/Mazatlan', 'YYYY-MM-DD HH12:MI AM') AS fecha_hora;
            """, (
                num_servicio,
                codigo_equipo,
                id_empleado,
                nombre_autor,
                rol_autor,
                mensaje,
                adjunto_url
            ))
            nuevo_msj = cursor.fetchone()

        # Limpiar estado escribiendo de este usuario
        if num_servicio in _estado_escribiendo_taller and id_empleado in _estado_escribiendo_taller[num_servicio]:
            del _estado_escribiendo_taller[num_servicio][id_empleado]

        return {
            "status": "SUCCESS",
            "mensaje": dict(nuevo_msj) if nuevo_msj else {}
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ==============================================================================
# 🔒 REPORTES Y MÉTRICAS EJECUTIVAS (ACCESO EXCLUSIVO EMPLEADOS 201 Y 202)


# ==============================================================================


EMPLEADOS_AUTORIZADOS_REPORTES_MANTENIMIENTO = {"201", "202"}





@router.get("/api/inventario/mantenimiento/reportes-kpis")


def obtener_reportes_kpis_mantenimiento(id_empleado: str):


    """


    Genera métricas consolidadas, costos y KPIs de mantenimiento.


    RESTRICCIÓN DE SEGURIDAD: Visible ÚNICAMENTE para empleados 201 y 202.


    """


    id_clean = str(id_empleado or "").strip()


    if id_clean not in EMPLEADOS_AUTORIZADOS_REPORTES_MANTENIMIENTO:


        raise HTTPException(


            status_code=403, 


            detail="Acceso Restringido: Los reportes ejecutivos de mantenimiento son visibles exclusivamente para los empleados 201 y 202."


        )





    try:


        with get_db_cursor("db_inventario", cursor_factory=RealDictCursor) as cursor:


            # 1. Resumen General


            cursor.execute("""


                SELECT 


                    COUNT(*) as total,


                    COUNT(*) FILTER (WHERE UPPER(COALESCE(estado_actual, '')) NOT IN ('RESUELTO', 'REPARADO', 'OK', 'BAJA DEFINITIVA', 'BAJA', 'CERRADO')) as activos,


                    COUNT(*) FILTER (WHERE UPPER(COALESCE(estado_actual, '')) IN ('RESUELTO', 'REPARADO', 'OK')) as resueltos,


                    COUNT(*) FILTER (WHERE UPPER(COALESCE(estado_actual, '')) IN ('BAJA DEFINITIVA', 'BAJA')) as bajas,


                    COALESCE(SUM(costo_d_reparacion), 0.0) as gasto_total


                FROM public.reparaciones;


            """)


            resumen_row = cursor.fetchone() or {}





            # 2. Desglose por Departamento


            cursor.execute("""


                SELECT 


                    COALESCE(area_q_pertenece, 'GENERAL') as depto,


                    COUNT(*) as tickets,


                    COALESCE(SUM(costo_d_reparacion), 0.0) as costo


                FROM public.reparaciones


                GROUP BY area_q_pertenece


                ORDER BY tickets DESC;


            """)


            por_depto = [dict(r) for r in cursor.fetchall()]





            # 3. Desglose por Tipo (Correctivo vs Preventivo)


            cursor.execute("""


                SELECT 


                    COALESCE(tipo_mantenimiento, 'CORRECTIVO') as tipo,


                    COUNT(*) as tickets,


                    COALESCE(SUM(costo_d_reparacion), 0.0) as costo


                FROM public.reparaciones


                GROUP BY tipo_mantenimiento;


            """)


            por_tipo = [dict(r) for r in cursor.fetchall()]





            # 4. Top Equipos con más fallas o gasto


            cursor.execute("""


                SELECT 


                    r.equipo_n_reparacion as codigo,


                    COALESCE(i.descripcion, r.equipo_n_reparacion) as nombre,


                    COUNT(*) as incidencias,


                    COALESCE(SUM(r.costo_d_reparacion), 0.0) as gasto_acumulado


                FROM public.reparaciones r


                LEFT JOIN public.inventario i ON UPPER(TRIM(r.equipo_n_reparacion)) = UPPER(TRIM(i.codigo))


                GROUP BY r.equipo_n_reparacion, i.descripcion


                ORDER BY incidencias DESC, gasto_acumulado DESC


                LIMIT 8;


            """)


            top_equipos = [dict(r) for r in cursor.fetchall()]





            # 5. Promedio de Días en Taller (Inactividad)


            hoy = datetime.date.today()


            cursor.execute("""


                SELECT 


                    fecha_d_reporte,


                    fecha_d_entrega,


                    estado_actual


                FROM public.reparaciones


                WHERE fecha_d_reporte IS NOT NULL;


            """)


            fechas_taller = cursor.fetchall()


            dias_totales = 0


            conteo_validos = 0


            for f in fechas_taller:


                f_rep = f.get("fecha_d_reporte")


                f_ent = f.get("fecha_d_entrega")


                if f_rep:


                    dias = (f_ent - f_rep).days if f_ent else (hoy - f_rep).days


                    dias_totales += max(0, dias)


                    conteo_validos += 1





            promedio_dias = round(dias_totales / conteo_validos, 1) if conteo_validos > 0 else 0





        return {


            "resumen": {


                "total_tickets": int(resumen_row.get("total") or 0),


                "activos": int(resumen_row.get("activos") or 0),


                "resueltos": int(resumen_row.get("resueltos") or 0),


                "bajas": int(resumen_row.get("bajas") or 0),


                "gasto_total": float(resumen_row.get("gasto_total") or 0.0),


                "promedio_dias_taller": promedio_dias


            },


            "por_departamento": [


                {


                    "depto": str(r["depto"]),


                    "tickets": int(r["tickets"]),


                    "costo": float(r["costo"])


                }


                for r in por_depto


            ],


            "por_tipo": [


                {


                    "tipo": str(r["tipo"]),


                    "tickets": int(r["tickets"]),


                    "costo": float(r["costo"])


                }


                for r in por_tipo


            ],


            "top_equipos": [


                {


                    "codigo": str(r["codigo"]),


                    "nombre": str(r["nombre"]),


                    "incidencias": int(r["incidencias"]),


                    "gasto_acumulado": float(r["gasto_acumulado"])


                }


                for r in top_equipos


            ],


            "acceso_autorizado": True,


            "empleado_consultante": id_clean


        }


    except HTTPException:


        raise


    except Exception as e:


        raise HTTPException(status_code=500, detail=str(e))


