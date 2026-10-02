import os
import re
import time
import uuid
import datetime
from pathlib import Path
from typing import Optional

from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Request
from fastapi.responses import FileResponse
from sqlalchemy import text

from core.database import engine_personal, engine_personal_vieja
from core.config import BASE_DIR

router = APIRouter(prefix="/api/transferencias", tags=["📦 Transferencia de Archivos (VPRO Transfer)"])

CARPETA_TRANSFERENCIAS = BASE_DIR / "Archivos_Compartidos"
CARPETA_TRANSFERENCIAS.mkdir(parents=True, exist_ok=True)

LIMITE_MAX_BYTES = 5 * 1024 * 1024 * 1024  # 5 GB (5,368,709,120 bytes)
CHUNK_SIZE = 2 * 1024 * 1024  # 2 MB por bloque de streaming

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

            # Replicar actualización en base vieja si existe
            try:
                with engine_personal_vieja.begin() as conn_v:
                    conn_v.execute(text("""
                        UPDATE public.archivos_compartidos
                        SET estatus = 'EXPIRADO_BORRADO'
                        WHERE id_transferencia = ANY(:ids)
                    """), {"ids": ids_a_marcar})
            except Exception:
                pass

        return len(ids_a_marcar)
    except Exception as e:
        print(f"[VPRO Transfer] Error en ejecutar_limpieza_expirados: {e}")
        return 0

@router.post("/subir")
async def subir_archivo_compartido(
    id_empleado_origen: str = Form(...),
    nombre_origen: str = Form(...),
    id_empleado_destino: str = Form(...),
    nombre_destino: str = Form(...),
    mensaje: Optional[str] = Form(""),
    file: UploadFile = File(...)
):
    """
    Recibe y almacena un archivo compartido de hasta 5 GB mediante streaming a disco.
    Registra al empleado origen (usuario en sesión) y destino seleccionado.
    """
    nombre_original = os.path.basename(file.filename or "archivo_compartido")
    nombre_limpio = re.sub(r'[^a-zA-Z0-9_.-]', '_', nombre_original)
    timestamp = int(time.time())
    token_unico = uuid.uuid4().hex[:8]
    nombre_fisico = f"trans_{timestamp}_{token_unico}_{nombre_limpio}"
    
    destino_path = CARPETA_TRANSFERENCIAS / nombre_fisico
    
    total_leido = 0
    try:
        with open(destino_path, "wb") as buffer:
            while True:
                chunk = await file.read(CHUNK_SIZE)
                if not chunk:
                    break
                total_leido += len(chunk)
                if total_leido > LIMITE_MAX_BYTES:
                    # Excedió 5 GB: abortar y borrar archivo parcial
                    buffer.close()
                    if destino_path.exists():
                        destino_path.unlink()
                    raise HTTPException(
                        status_code=400,
                        detail="El archivo excede el límite máximo permitido de 5 GB."
                    )
                buffer.write(chunk)
                
        if total_leido == 0:
            if destino_path.exists():
                destino_path.unlink()
            raise HTTPException(status_code=400, detail="El archivo enviado está vacío.")

        tamano_str = _tamano_legible(total_leido)
        tipo_mime = file.content_type or "application/octet-stream"

        query_insert = text("""
            INSERT INTO public.archivos_compartidos (
                id_empleado_origen, nombre_origen, id_empleado_destino, nombre_destino,
                nombre_archivo_original, nombre_archivo_fisico, tamano_bytes, tamano_legible,
                tipo_mime, mensaje, fecha_subida, descargado, veces_descargado, estatus
            ) VALUES (
                :id_origen, :nom_origen, :id_destino, :nom_destino,
                :nom_orig_file, :nom_fisico, :tam_bytes, :tam_leg,
                :mime, :msg, CURRENT_TIMESTAMP, FALSE, 0, 'DISPONIBLE'
            ) RETURNING id_transferencia
        """)
        
        params = {
            "id_origen": str(id_empleado_origen).strip(),
            "nom_origen": str(nombre_origen).strip(),
            "id_destino": str(id_empleado_destino).strip(),
            "nom_destino": str(nombre_destino).strip(),
            "nom_orig_file": nombre_original,
            "nom_fisico": nombre_fisico,
            "tam_bytes": total_leido,
            "tam_leg": tamano_str,
            "mime": tipo_mime,
            "msg": str(mensaje or "").strip()
        }

        with engine_personal.begin() as conn:
            id_trans = conn.execute(query_insert, params).scalar()

        # Replicar en base vieja si está disponible
        try:
            with engine_personal_vieja.begin() as conn_v:
                conn_v.execute(query_insert, params)
        except Exception:
            pass

        return {
            "status": "SUCCESS",
            "id_transferencia": id_trans,
            "nombre_archivo": nombre_original,
            "tamano": tamano_str,
            "destinatario": nombre_destino,
            "mensaje": f"Archivo enviado exitosamente a {nombre_destino}."
        }

    except HTTPException:
        raise
    except Exception as e:
        if destino_path.exists():
            try:
                destino_path.unlink()
            except Exception:
                pass
        raise HTTPException(status_code=500, detail=f"Error al procesar la transferencia: {str(e)}")

@router.get("/recibidos/{id_empleado}")
def obtener_archivos_recibidos(id_empleado: str):
    """
    Retorna la lista de archivos que han sido enviados al empleado especificado.
    Calcula el tiempo restante para los que ya fueron descargados (regla de 7 horas).
    """
    # Ejecutar limpieza oportunista
    ejecutar_limpieza_expirados()
    
    try:
        query = text("""
            SELECT 
                id_transferencia, id_empleado_origen, nombre_origen,
                nombre_archivo_original, tamano_bytes, tamano_legible,
                tipo_mime, mensaje, fecha_subida, descargado, veces_descargado,
                fecha_primer_descarga, fecha_limite_borrado, estatus
            FROM public.archivos_compartidos
            WHERE id_empleado_destino = :id_emp
              AND estatus IN ('DISPONIBLE', 'DESCARGADO')
            ORDER BY fecha_subida DESC
        """)
        
        with engine_personal.connect() as conn:
            rows = conn.execute(query, {"id_emp": str(id_empleado).strip()}).mappings().all()

        ahora = datetime.datetime.now()
        resultado = []
        for r in rows:
            item = dict(r)
            # Formatear fechas
            if item["fecha_subida"]:
                item["fecha_subida_str"] = item["fecha_subida"].strftime("%d/%m/%Y %H:%M")
            if item["fecha_primer_descarga"]:
                item["fecha_primer_descarga_str"] = item["fecha_primer_descarga"].strftime("%d/%m/%Y %H:%M")
            
            # Cálculo de tiempo restante de las 7 horas si ya fue descargado
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
                nombre_archivo_original, tamano_legible, mensaje,
                fecha_subida, descargado, veces_descargado,
                fecha_primer_descarga, fecha_limite_borrado, estatus
            FROM public.archivos_compartidos
            WHERE id_empleado_origen = :id_emp
            ORDER BY fecha_subida DESC
            LIMIT 50
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
    Endpoint rápido para el panel de Inicio (similar a OPs pendientes):
    Retorna la lista de archivos que el usuario tiene pendientes de descargar.
    """
    try:
        query = text("""
            SELECT 
                id_transferencia, id_empleado_origen, nombre_origen,
                nombre_archivo_original, tamano_legible, mensaje, fecha_subida
            FROM public.archivos_compartidos
            WHERE id_empleado_destino = :id_emp
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
    Inicia la descarga directa del archivo compartido.
    Al descargarse por primera vez:
    - Marca 'descargado = TRUE'.
    - Fija 'fecha_primer_descarga = NOW()'.
    - Fija 'fecha_limite_borrado = NOW() + 7 horas'.
    - La cuenta regresiva de 7 horas comienza a correr inmediatamente.
    """
    try:
        with engine_personal.connect() as conn:
            reg = conn.execute(text("""
                SELECT 
                    id_transferencia, nombre_archivo_original, nombre_archivo_fisico,
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

        # Actualizar estado de descarga y fijar límite de 7 horas si es la primera descarga
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

        # Replicar en base vieja si aplica
        try:
            with engine_personal_vieja.begin() as conn_v:
                conn_v.execute(text("""
                    UPDATE public.archivos_compartidos
                    SET descargado = TRUE,
                        veces_descargado = COALESCE(veces_descargado, 0) + 1,
                        fecha_primer_descarga = COALESCE(fecha_primer_descarga, CURRENT_TIMESTAMP),
                        fecha_limite_borrado = COALESCE(fecha_limite_borrado, CURRENT_TIMESTAMP + INTERVAL '7 hours'),
                        estatus = 'DESCARGADO'
                    WHERE id_transferencia = :id_trans
                """), {"id_trans": id_transferencia})
        except Exception:
            pass

        return FileResponse(
            path=str(archivo_path),
            filename=reg["nombre_archivo_original"],
            media_type="application/octet-stream"
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al descargar: {str(e)}")

@router.delete("/eliminar/{id_transferencia}")
def cancelar_o_eliminar_transferencia(id_transferencia: int):
    """
    Permite eliminar o cancelar un archivo compartido antes o después de la descarga.
    Elimina físicamente el archivo del disco y marca el estatus en la BD.
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

        try:
            with engine_personal_vieja.begin() as conn_v:
                conn_v.execute(text("""
                    UPDATE public.archivos_compartidos
                    SET estatus = 'CANCELADO'
                    WHERE id_transferencia = :id_trans
                """), {"id_trans": id_transferencia})
        except Exception:
            pass

        return {"status": "SUCCESS", "mensaje": "Transferencia eliminada y archivo borrado del disco."}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/limpiar_expirados")
def ejecutar_limpieza_manual():
    """Ejecuta de forma manual o bajo demanda la limpieza de archivos vencidos (>7 horas post descarga)."""
    eliminados = ejecutar_limpieza_expirados()
    return {"status": "SUCCESS", "archivos_eliminados": eliminados}
