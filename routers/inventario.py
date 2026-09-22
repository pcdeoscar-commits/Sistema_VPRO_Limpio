import os
import re
import base64
import shutil
import time
from typing import Dict, Any, List, Optional
from fastapi import APIRouter, HTTPException, File, Form, UploadFile, Request
from psycopg2.extras import RealDictCursor
from sqlalchemy import text

from core.config import DIR_EVIDENCIAS_REAL
from core.database import (
    engine_inventario, engine_inventario_vieja, 
    engine_personal, get_db_cursor
)
from core.utils import safe_decode_hex, reparar_mojibake

router = APIRouter(tags=["🛠️ Inventario General"])

@router.get("/api/inventario")
def obtener_inventario():
    """Consulta todo el catálogo de inventario maestro ordenado por código."""
    try:
        with get_db_cursor("db_inventario_prueba", cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT * FROM inventario ORDER BY codigo ASC;")
            inventario = cursor.fetchall()
        return inventario
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en BD: {str(e)}")

@router.post("/api/inventario/guardar")
def guardar_inventario(payload: dict):
    """Inserta o actualiza un equipo en inventario."""
    try:
        with get_db_cursor("db_inventario_prueba", commit=True) as cursor:
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
        with get_db_cursor("db_inventario_prueba", commit=True) as cursor:
            cursor.execute("DELETE FROM inventario WHERE codigo = %s;", (codigo,))
        return {"status": "ok", "mensaje": f"Equipo {codigo} eliminado"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al eliminar: {str(e)}")

@router.get("/api/inventario-kits/completo")
def obtener_inventario_kits():
    """Consulta todos los kits de inventario alterno."""
    try:
        with get_db_cursor("db_inventario_prueba", cursor_factory=RealDictCursor) as cursor:
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
        with get_db_cursor("db_personal_prueba", cursor_factory=RealDictCursor) as cursor_emp:
            cursor_emp.execute("SELECT id_empleado, nombre FROM public.empleados;")
            empleados_db = cursor_emp.fetchall()

        mapa_empleados = {str(emp["id_empleado"]).strip(): emp["nombre"] for emp in empleados_db}

        with get_db_cursor("db_inventario_prueba", cursor_factory=RealDictCursor) as cursor_inv:
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
        for row in danados:
            reportante_crudo = str(row["REPORTÓ_RAW"] or "")
            numeros_encontrados = re.findall(r'\d+', reportante_crudo)
            id_extraido = numeros_encontrados[0] if numeros_encontrados else None
            nombre_real = mapa_empleados.get(id_extraido, reportante_crudo)
            
            fila_limpia = dict(row)
            fila_limpia["REPORTÓ"] = nombre_real
            del fila_limpia["REPORTÓ_RAW"]
            resultados_finales.append(fila_limpia)

        return resultados_finales
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en Radar de Daños: {str(e)}")

@router.get("/api/inventario/historial/{codigo}")
def extraer_expediente_clinico_hardware(codigo: str):
    """Consulta el historial clínico de un equipo por código."""
    query = text("""
        SELECT encode(codigo_equipo::bytea, 'hex') as cod, encode(tipo_evento::bytea, 'hex') as tipo, 
               encode(descripcion::bytea, 'hex') as descr, fecha, encode(folio_vpro::bytea, 'hex') as fol 
        FROM public.historial_equipo WHERE LOWER(TRIM(codigo_equipo)) = LOWER(:cod) ORDER BY fecha DESC
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
                "folio_vpro": safe_decode_hex(r[4])
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

        with get_db_cursor("db_inventario_prueba", commit=True) as cursor:
            cursor.execute("""
                INSERT INTO public.historial_equipo 
                    (codigo_equipo, fecha, folio_vpro, id_empleado, tipo_evento, descripcion, costo_asociado, estado_final, departamento)
                VALUES 
                    (%s, CURRENT_DATE, %s, %s, %s, %s, %s, %s, %s);
            """, (cod_eq, fol_vpro, emp_id, str(log.get("tipo_evento", "MANTENIMIENTO_TÉCNICO")), desc, costo, est_final, depto))

            if est_final in ["PENDIENTE", "EN TALLER", "DAÑADO", "DANADO", "BAJA"]:
                if cod_eq.startswith("INV_VPRO_ALT_"):
                    cursor.execute("UPDATE public.inventario_kits SET estado_inv_kits = 'DANADO' WHERE UPPER(codigo_inv_kits) = %s OR UPPER(descripcion_inv_kits) = %s;", (cod_eq, cod_eq))
                else:
                    cursor.execute("UPDATE public.inventario SET estado = 'DAÑADO' WHERE UPPER(codigo) = %s OR UPPER(descripcion) = %s;", (cod_eq, cod_eq))
                
                ticket_id = f"REP-INT-{int(time.time())}"
                cursor.execute("""
                    INSERT INTO public.reparaciones 
                        (num_d_servicio, fecha_d_reporte, equipo_n_reparacion, area_q_pertenece, reportante, estado_actual, descripcion_del_dano, costo_d_reparacion, folio_vpro)
                    VALUES 
                        (%s, CURRENT_DATE, %s, %s, %s, %s, %s, %s, %s);
                """, (ticket_id, cod_eq, depto, f"Empleado ID: {emp_id}", f"⚙️ {est_final}", desc, costo, fol_vpro))
                
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
        with get_db_cursor("db_inventario_prueba", commit=True) as cursor:
            cursor.execute("SELECT equipo_n_reparacion FROM public.reparaciones WHERE num_d_servicio = %s;", (num_servicio,))
            row = cursor.fetchone()
            
            if row:
                cod_eq = str(row[0]).strip().upper()
                cursor.execute("UPDATE public.reparaciones SET estado_actual = %s WHERE num_d_servicio = %s;", (nuevo_estatus, num_servicio))
                
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
        with get_db_cursor("db_inventario_prueba", cursor_factory=RealDictCursor) as cursor:
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
            with get_db_cursor("db_inventario_prueba", cursor_factory=RealDictCursor) as cursor_alias:
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
        with get_db_cursor("db_inventario_prueba", cursor_factory=RealDictCursor) as cursor:
            cursor.execute("""
                SELECT 
                    num_d_servicio,
                    fecha_d_reporte,
                    equipo_n_reparacion,
                    descripcion_del_dano,
                    estado_actual,
                    area_q_pertenece
                FROM public.reparaciones
                WHERE reportante = %s
                  AND UPPER(TRIM(estado_actual)) NOT IN (
                      'REPARADO', 'RESUELTO', 'BAJA DEFINITIVA', 'CERRADO'
                  )
                ORDER BY fecha_d_reporte DESC
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
                "ticket":      r.get("num_d_servicio", ""),
                "equipo":      r.get("equipo_n_reparacion", ""),
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
