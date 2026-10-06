import os
import re
import time
import uuid
import datetime
import zipfile
import io
from pathlib import Path
from typing import Optional, List

from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Request
from fastapi.responses import FileResponse, StreamingResponse
from sqlalchemy import text

from core.database import engine_personal
from core.config import BASE_DIR

router = APIRouter(prefix="/api/transferencias", tags=["📦 Transferencia de Archivos (VPRO Transfer)"])

CARPETA_TRANSFERENCIAS = BASE_DIR / "Archivos_Compartidos"
CARPETA_TRANSFERENCIAS.mkdir(parents=True, exist_ok=True)

LIMITE_MAX_BYTES = 5 * 1024 * 1024 * 1024  # 5 GB total (5,368,709,120 bytes)
CHUNK_SIZE = 2 * 1024 * 1024  # 2 MB por bloque de streaming

def _asegurar_tabla_transferencias():
    """Garantiza automáticamente la existencia de la tabla en db_personal."""
    try:
        with engine_personal.begin() as conn:
            conn.execute(text("""
                CREATE TABLE IF NOT EXISTS public.archivos_compartidos (
                    id_transferencia SERIAL PRIMARY KEY,
                    id_empleado_origen VARCHAR(50) NOT NULL,
                    nombre_origen VARCHAR(255) NOT NULL,
                    id_empleado_destino VARCHAR(50) NOT NULL,
                    nombre_destino VARCHAR(255) NOT NULL,
                    nombre_archivo_original VARCHAR(255) NOT NULL,
                    nombre_archivo_fisico VARCHAR(255) NOT NULL,
                    tamano_bytes BIGINT NOT NULL,
                    tamano_legible VARCHAR(50),
                    tipo_mime VARCHAR(100),
                    mensaje TEXT,
                    folio_paquete VARCHAR(100),
                    fecha_subida TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    descargado BOOLEAN DEFAULT FALSE,
                    veces_descargado INTEGER DEFAULT 0,
                    fecha_primer_descarga TIMESTAMP,
                    fecha_limite_borrado TIMESTAMP,
                    estatus VARCHAR(50) DEFAULT 'DISPONIBLE'
                );
                CREATE INDEX IF NOT EXISTS idx_archivos_destino ON public.archivos_compartidos (id_empleado_destino);
                CREATE INDEX IF NOT EXISTS idx_archivos_origen ON public.archivos_compartidos (id_empleado_origen);
                CREATE INDEX IF NOT EXISTS idx_archivos_paquete ON public.archivos_compartidos (folio_paquete);
                CREATE INDEX IF NOT EXISTS idx_archivos_estatus ON public.archivos_compartidos (estatus);
            """))
    except Exception as e:
        print(f"[VPRO Transfer] Aviso al verificar tabla archivos_compartidos: {e}")

_asegurar_tabla_transferencias()

def _tamano_legible(num_bytes: int) -> str:
    """Convierte bytes a formato legible (KB, MB, GB)."""
    if num_bytes < 1024:
        return f"{num_bytes} B"
    elif num_bytes < 1024 * 1024:
        return f"{num_bytes / 1024:.1f} KB"
    elif num_bytes < 1024 * 1024 * 1024:
        return f"{num_bytes / (1024 * 1024):.1f} MB"
    else:
        return f"{num_bytes / (1024 * 1024 * 1024):.2f} GB"

def ejecutar_limpieza_expirados():
    """
    Elimina físicamente del disco los archivos que ya cumplieron su periodo de retención:
    1. Archivos descargados cuya fecha_limite_borrado (7 horas) ya se venció.
    2. Archivos no descargados que lleven más de 72 horas sin ser descargados (para proteger el disco duro).
    """
    try:
        query_buscar = text("""
            SELECT id_transferencia, nombre_archivo_fisico, estatus, fecha_limite_borrado, fecha_subida
            FROM public.archivos_compartidos
            WHERE estatus != 'EXPIRADO_BORRADO'
              AND (
                (fecha_limite_borrado IS NOT NULL AND fecha_limite_borrado <= CURRENT_TIMESTAMP)
                OR (descargado = FALSE AND fecha_subida <= CURRENT_TIMESTAMP - INTERVAL '72 hours')
              )
        """)
        
        with engine_personal.connect() as conn:
            expirados = conn.execute(query_buscar).mappings().all()

        if not expirados:
            return 0

        ids_a_marcar = []
        for reg in expirados:
            ids_a_marcar.append(reg["id_transferencia"])
            archivo_path = CARPETA_TRANSFERENCIAS / reg["nombre_archivo_fisico"]
            try:
                if archivo_path.exists():
                    archivo_path.unlink()
                    print(f"[VPRO Transfer] Archivo físico eliminado por vencimiento: {archivo_path.name}")
            except Exception as fe:
                print(f"[VPRO Transfer] Error al eliminar archivo físico {archivo_path.name}: {fe}")

        if ids_a_marcar:
            with engine_personal.begin() as conn:
                conn.execute(text("""
                    UPDATE public.archivos_compartidos
                    SET estatus = 'EXPIRADO_BORRADO'
                    WHERE id_transferencia = ANY(:ids)
                """), {"ids": ids_a_marcar})

        return len(ids_a_marcar)
    except Exception as e:
        print(f"[VPRO Transfer] Error en ejecutar_limpieza_expirados: {e}")
        return 0

@router.get("/destinatarios")
def obtener_destinatarios_activos():
    """
    Retorna la lista de empleados activos ordenados alfabéticamente
    para llenar el selector de destinatarios en VPRO Transfer.
    """
    try:
        with engine_personal.connect() as conn:
            query = text("""
                SELECT 
                    id_empleado, 
                    nombre, 
                    COALESCE(depto, 'General') as depto, 
                    COALESCE(puesto, '') as puesto
                FROM public.empleados
                WHERE estatus_empleado IS NULL OR UPPER(TRIM(estatus_empleado)) != 'BAJA'
                ORDER BY nombre ASC
            """)
            rows = conn.execute(query).mappings().all()
            return [dict(r) for r in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener destinatarios: {str(e)}")

@router.post("/subir")
async def subir_archivos_compartidos(
    id_empleado_origen: str = Form(...),
    nombre_origen: str = Form(...),
    id_empleado_destino: str = Form(...),
    nombre_destino: str = Form(...),
    mensaje: Optional[str] = Form(""),
    files: Optional[List[UploadFile]] = File(None),
    file: Optional[UploadFile] = File(None)
):
    """
    Recibe y almacena 1 o más archivos compartidos (hasta 5 GB en total) mediante streaming a disco.
    Agrupa los archivos en un mismo folio_paquete para facilitar la entrega al destinatario.
    """
    lista_archivos = []
    if files:
        lista_archivos.extend([f for f in files if f.filename])
    if file and file.filename and file not in lista_archivos:
        lista_archivos.append(file)
        
    if not lista_archivos:
        raise HTTPException(status_code=400, detail="No se seleccionó ningún archivo para transferir.")

    folio_paquete = f"TRF-{int(time.time())}-{uuid.uuid4().hex[:6].upper()}"
    archivos_guardados = []
    total_leido_combinado = 0
    archivos_fisicos_creados = []

    try:
        for f in lista_archivos:
            nombre_original = os.path.basename(f.filename or "archivo_compartido")
            nombre_limpio = re.sub(r'[^a-zA-Z0-9_.-]', '_', nombre_original)
            timestamp = int(time.time())
            token_unico = uuid.uuid4().hex[:8]
            nombre_fisico = f"trans_{timestamp}_{token_unico}_{nombre_limpio}"
            destino_path = CARPETA_TRANSFERENCIAS / nombre_fisico
            
            total_leido_archivo = 0
            with open(destino_path, "wb") as buffer:
                while True:
                    chunk = await f.read(CHUNK_SIZE)
                    if not chunk:
                        break
                    total_leido_archivo += len(chunk)
                    total_leido_combinado += len(chunk)
                    
                    if total_leido_combinado > LIMITE_MAX_BYTES:
                        buffer.close()
                        destino_path.unlink(missing_ok=True)
                        for af in archivos_fisicos_creados:
                            try:
                                af.unlink(missing_ok=True)
                            except Exception:
                                pass
                        raise HTTPException(
                            status_code=400,
                            detail="El peso combinado de los archivos excede el límite máximo permitido de 5.0 GB."
                        )
                    buffer.write(chunk)

            if total_leido_archivo > 0:
                archivos_fisicos_creados.append(destino_path)
                archivos_guardados.append({
                    "nombre_original": nombre_original,
                    "nombre_fisico": nombre_fisico,
                    "tamano_bytes": total_leido_archivo,
                    "tamano_legible": _tamano_legible(total_leido_archivo),
                    "tipo_mime": f.content_type or "application/octet-stream"
                })

        if not archivos_guardados:
            raise HTTPException(status_code=400, detail="Los archivos enviados están vacíos.")

        query_insert = text("""
            INSERT INTO public.archivos_compartidos (
                id_empleado_origen, nombre_origen, id_empleado_destino, nombre_destino,
                nombre_archivo_original, nombre_archivo_fisico, tamano_bytes, tamano_legible,
                tipo_mime, mensaje, folio_paquete, fecha_subida, descargado, veces_descargado, estatus
            ) VALUES (
                :id_origen, :nom_origen, :id_destino, :nom_destino,
                :nom_orig_file, :nom_fisico, :tam_bytes, :tam_leg,
                :mime, :msg, :folio_paq, CURRENT_TIMESTAMP, FALSE, 0, 'DISPONIBLE'
            ) RETURNING id_transferencia
        """)

        ids_generados = []
        with engine_personal.begin() as conn:
            for item in archivos_guardados:
                params = {
                    "id_origen": str(id_empleado_origen).strip(),
                    "nom_origen": str(nombre_origen).strip(),
                    "id_destino": str(id_empleado_destino).strip(),
                    "nom_destino": str(nombre_destino).strip(),
                    "nom_orig_file": item["nombre_original"],
                    "nom_fisico": item["nombre_fisico"],
                    "tam_bytes": item["tamano_bytes"],
                    "tam_leg": item["tamano_legible"],
                    "mime": item["tipo_mime"],
                    "msg": str(mensaje or "").strip(),
                    "folio_paq": folio_paquete
                }
                new_id = conn.execute(query_insert, params).scalar()
                ids_generados.append(new_id)

        tamano_total_str = _tamano_legible(total_leido_combinado)
        cant_archivos = len(archivos_guardados)
        texto_archivos = f"{cant_archivos} archivo(s)" if cant_archivos > 1 else archivos_guardados[0]["nombre_original"]

        return {
            "status": "SUCCESS",
            "folio_paquete": folio_paquete,
            "total_archivos": cant_archivos,
            "tamano_total": tamano_total_str,
            "destinatario": nombre_destino,
            "mensaje": f"Se envió exitosamente {texto_archivos} ({tamano_total_str}) a {nombre_destino}."
        }

    except HTTPException:
        raise
    except Exception as e:
        for af in archivos_fisicos_creados:
            try:
                af.unlink(missing_ok=True)
            except Exception:
                pass
        raise HTTPException(status_code=500, detail=f"Error al procesar la transferencia: {str(e)}")

@router.get("/recibidos/{id_empleado}")
def obtener_archivos_recibidos(id_empleado: str):
    """
    Retorna la lista de archivos que han sido enviados al empleado especificado.
    Calcula el tiempo restante para los que ya fueron descargados (regla de 7 horas).
    """
    ejecutar_limpieza_expirados()
    
    try:
        query = text("""
            SELECT 
                id_transferencia, id_empleado_origen, nombre_origen,
                nombre_archivo_original, tamano_bytes, tamano_legible,
                tipo_mime, mensaje, folio_paquete, fecha_subida, descargado, veces_descargado,
                fecha_primer_descarga, fecha_limite_borrado, estatus
            FROM public.archivos_compartidos
            WHERE (TRIM(id_empleado_destino) = TRIM(:id_emp) OR id_empleado_destino = :id_emp)
              AND estatus IN ('DISPONIBLE', 'DESCARGADO')
            ORDER BY fecha_subida DESC
        """)
        
        with engine_personal.connect() as conn:
            rows = conn.execute(query, {"id_emp": str(id_empleado).strip()}).mappings().all()

        ahora = datetime.datetime.now()
        resultado = []
        for r in rows:
            item = dict(r)
            if item["fecha_subida"]:
                item["fecha_subida_str"] = item["fecha_subida"].strftime("%d/%m/%Y %H:%M")
            if item["fecha_primer_descarga"]:
                item["fecha_primer_descarga_str"] = item["fecha_primer_descarga"].strftime("%d/%m/%Y %H:%M")
            
            if item["descargado"] and item["fecha_limite_borrado"]:
                limite = item["fecha_limite_borrado"]
                diff = limite - ahora
                segundos_restantes = int(diff.total_seconds())
                if segundos_restantes > 0:
                    horas = segundos_restantes // 3600
                    minutos = (segundos_restantes % 3600) // 60
                    item["tiempo_restante_texto"] = f"Se borrará en {horas}h {minutos}m"
                    item["expirado"] = False
                else:
                    item["tiempo_restante_texto"] = "Vencido (en proceso de borrado)"
                    item["expirado"] = True
            else:
                item["tiempo_restante_texto"] = "Disponible para descargar (vigente)"
                item["expirado"] = False
                
            resultado.append(item)

        return resultado
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/enviados/{id_empleado}")
def obtener_archivos_enviados(id_empleado: str):
    """
    Retorna la lista de archivos enviados por el empleado especificado (bandeja de salida).
    """
    ejecutar_limpieza_expirados()
    try:
        query = text("""
            SELECT 
                id_transferencia, id_empleado_destino, nombre_destino,
                nombre_archivo_original, tamano_legible, mensaje, folio_paquete,
                fecha_subida, descargado, veces_descargado,
                fecha_primer_descarga, fecha_limite_borrado, estatus
            FROM public.archivos_compartidos
            WHERE TRIM(id_empleado_origen) = TRIM(:id_emp) OR id_empleado_origen = :id_emp
            ORDER BY fecha_subida DESC
            LIMIT 100
        """)
        with engine_personal.connect() as conn:
            rows = conn.execute(query, {"id_emp": str(id_empleado).strip()}).mappings().all()

        ahora = datetime.datetime.now()
        resultado = []
        for r in rows:
            item = dict(r)
            if item["fecha_subida"]:
                item["fecha_subida_str"] = item["fecha_subida"].strftime("%d/%m/%Y %H:%M")
            if item["fecha_primer_descarga"]:
                item["fecha_primer_descarga_str"] = item["fecha_primer_descarga"].strftime("%d/%m/%Y %H:%M")
                
            if item["estatus"] == "EXPIRADO_BORRADO":
                item["estado_display"] = "🗑️ Eliminado por límite de 7h"
            elif item["estatus"] == "CANCELADO":
                item["estado_display"] = "❌ Cancelado por remitente"
            elif item["descargado"]:
                if item["fecha_limite_borrado"]:
                    diff = item["fecha_limite_borrado"] - ahora
                    seg = int(diff.total_seconds())
                    if seg > 0:
                        h = seg // 3600
                        m = (seg % 3600) // 60
                        item["estado_display"] = f"📥 Descargado (se borra en {h}h {m}m)"
                    else:
                        item["estado_display"] = "⌛ Descargado (expirando)"
                else:
                    item["estado_display"] = "📥 Descargado"
            else:
                item["estado_display"] = "⏳ Pendiente de descarga"
                
            resultado.append(item)

        return resultado
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/pendientes_notificacion/{id_empleado}")
def obtener_pendientes_notificacion(id_empleado: str):
    """
    Endpoint para el Centro de Notificaciones en Inicio:
    Retorna la lista de archivos pendientes de descargar enviados al empleado.
    """
    try:
        query = text("""
            SELECT 
                id_transferencia, id_empleado_origen, nombre_origen,
                nombre_archivo_original, tamano_legible, mensaje, folio_paquete, fecha_subida
            FROM public.archivos_compartidos
            WHERE (TRIM(id_empleado_destino) = TRIM(:id_emp) OR id_empleado_destino = :id_emp)
              AND descargado = FALSE
              AND estatus = 'DISPONIBLE'
            ORDER BY fecha_subida DESC
        """)
        with engine_personal.connect() as conn:
            rows = conn.execute(query, {"id_emp": str(id_empleado).strip()}).mappings().all()

        pendientes = []
        for r in rows:
            item = dict(r)
            if item["fecha_subida"]:
                item["fecha_subida_str"] = item["fecha_subida"].strftime("%d/%m/%Y %H:%M")
            pendientes.append(item)

        return {
            "total_pendientes": len(pendientes),
            "pendientes": pendientes
        }
    except Exception as e:
        return {"total_pendientes": 0, "pendientes": [], "error": str(e)}

@router.get("/descargar/{id_transferencia}")
def descargar_archivo_compartido(id_transferencia: int):
    """
    Inicia la descarga de un archivo compartido individual.
    Al descargarse:
    - Marca 'descargado = TRUE'.
    - Fija 'fecha_primer_descarga = NOW()'.
    - Fija 'fecha_limite_borrado = NOW() + 7 horas'.
    """
    try:
        with engine_personal.connect() as conn:
            reg = conn.execute(text("""
                SELECT 
                    id_transferencia, nombre_archivo_original, nombre_archivo_fisico, folio_paquete,
                    descargado, veces_descargado, fecha_primer_descarga, fecha_limite_borrado,
                    estatus
                FROM public.archivos_compartidos
                WHERE id_transferencia = :id_trans
            """), {"id_trans": id_transferencia}).mappings().first()

        if not reg:
            raise HTTPException(status_code=404, detail="La transferencia no existe.")

        if reg["estatus"] == "EXPIRADO_BORRADO":
            raise HTTPException(
                status_code=410,
                detail="Este archivo ya cumplió su periodo de 7 horas posterior a la descarga y fue eliminado automáticamente para liberar espacio."
            )
            
        if reg["estatus"] == "CANCELADO":
            raise HTTPException(status_code=410, detail="Esta transferencia fue cancelada por el remitente.")

        archivo_path = CARPETA_TRANSFERENCIAS / reg["nombre_archivo_fisico"]
        if not archivo_path.exists():
            raise HTTPException(status_code=404, detail="El archivo físico ya no se encuentra en el servidor.")

        with engine_personal.begin() as conn:
            if not reg["descargado"]:
                conn.execute(text("""
                    UPDATE public.archivos_compartidos
                    SET descargado = TRUE,
                        veces_descargado = COALESCE(veces_descargado, 0) + 1,
                        fecha_primer_descarga = CURRENT_TIMESTAMP,
                        fecha_limite_borrado = CURRENT_TIMESTAMP + INTERVAL '7 hours',
                        estatus = 'DESCARGADO'
                    WHERE id_transferencia = :id_trans
                """), {"id_trans": id_transferencia})
            else:
                conn.execute(text("""
                    UPDATE public.archivos_compartidos
                    SET veces_descargado = COALESCE(veces_descargado, 0) + 1
                    WHERE id_transferencia = :id_trans
                """), {"id_trans": id_transferencia})

        return FileResponse(
            path=str(archivo_path),
            filename=reg["nombre_archivo_original"],
            media_type="application/octet-stream"
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al descargar: {str(e)}")

@router.get("/descargar_paquete/{folio_paquete}")
def descargar_paquete_completo_zip(folio_paquete: str):
    """
    Descarga todos los archivos de un paquete en un archivo ZIP.
    Activa la regla de 7 horas para todos los archivos del paquete.
    """
    try:
        with engine_personal.connect() as conn:
            archivos = conn.execute(text("""
                SELECT 
                    id_transferencia, nombre_archivo_original, nombre_archivo_fisico,
                    descargado, estatus
                FROM public.archivos_compartidos
                WHERE folio_paquete = :folio AND estatus IN ('DISPONIBLE', 'DESCARGADO')
            """), {"folio": folio_paquete}).mappings().all()

        if not archivos:
            raise HTTPException(status_code=404, detail="El paquete no contiene archivos disponibles.")

        # Activar regla de 7 horas en todos los archivos del paquete
        ids = [a["id_transferencia"] for a in archivos]
        with engine_personal.begin() as conn:
            conn.execute(text("""
                UPDATE public.archivos_compartidos
                SET descargado = TRUE,
                    veces_descargado = COALESCE(veces_descargado, 0) + 1,
                    fecha_primer_descarga = COALESCE(fecha_primer_descarga, CURRENT_TIMESTAMP),
                    fecha_limite_borrado = COALESCE(fecha_limite_borrado, CURRENT_TIMESTAMP + INTERVAL '7 hours'),
                    estatus = 'DESCARGADO'
                WHERE id_transferencia = ANY(:ids)
            """), {"ids": ids})

        # Generar ZIP en memoria
        zip_buffer = io.BytesIO()
        with zipfile.ZipFile(zip_buffer, "w", zipfile.ZIP_DEFLATED) as zip_file:
            for a in archivos:
                ruta = CARPETA_TRANSFERENCIAS / a["nombre_archivo_fisico"]
                if ruta.exists():
                    zip_file.write(str(ruta), arcname=a["nombre_archivo_original"])

        zip_buffer.seek(0)
        zip_filename = f"VPRO_Transfer_{folio_paquete}.zip"

        return StreamingResponse(
            zip_buffer,
            media_type="application/zip",
            headers={"Content-Disposition": f"attachment; filename={zip_filename}"}
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al generar paquete ZIP: {str(e)}")

@router.delete("/eliminar/{id_transferencia}")
def cancelar_o_eliminar_transferencia(id_transferencia: int):
    """
    Permite eliminar un archivo compartido individual.
    """
    try:
        with engine_personal.connect() as conn:
            reg = conn.execute(text("""
                SELECT id_transferencia, nombre_archivo_fisico 
                FROM public.archivos_compartidos 
                WHERE id_transferencia = :id_trans
            """), {"id_trans": id_transferencia}).mappings().first()

        if not reg:
            raise HTTPException(status_code=404, detail="Transferencia no encontrada.")

        archivo_path = CARPETA_TRANSFERENCIAS / reg["nombre_archivo_fisico"]
        if archivo_path.exists():
            try:
                archivo_path.unlink()
            except Exception as fe:
                print(f"[VPRO Transfer] Error al borrar archivo físico: {fe}")

        with engine_personal.begin() as conn:
            conn.execute(text("""
                UPDATE public.archivos_compartidos
                SET estatus = 'CANCELADO'
                WHERE id_transferencia = :id_trans
            """), {"id_trans": id_transferencia})

        return {"status": "SUCCESS", "mensaje": "Transferencia eliminada y archivo borrado del disco."}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/eliminar_paquete/{folio_paquete}")
def cancelar_o_eliminar_paquete(folio_paquete: str):
    """
    Permite eliminar un paquete completo de archivos transferidos.
    """
    try:
        with engine_personal.connect() as conn:
            regs = conn.execute(text("""
                SELECT id_transferencia, nombre_archivo_fisico 
                FROM public.archivos_compartidos 
                WHERE folio_paquete = :folio
            """), {"folio": folio_paquete}).mappings().all()

        for reg in regs:
            archivo_path = CARPETA_TRANSFERENCIAS / reg["nombre_archivo_fisico"]
            if archivo_path.exists():
                try:
                    archivo_path.unlink()
                except Exception:
                    pass

        with engine_personal.begin() as conn:
            conn.execute(text("""
                UPDATE public.archivos_compartidos
                SET estatus = 'CANCELADO'
                WHERE folio_paquete = :folio
            """), {"folio": folio_paquete})

        return {"status": "SUCCESS", "mensaje": "Paquete eliminado exitosamente."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/limpiar_expirados")
def ejecutar_limpieza_manual():
    """Ejecuta de forma manual o bajo demanda la limpieza de archivos vencidos (>7 horas post descarga)."""
    eliminados = ejecutar_limpieza_expirados()
    return {"status": "SUCCESS", "archivos_eliminados": eliminados}
