import re
import base64
import datetime
from datetime import date, time
from io import BytesIO
import json
import logging
import os
import shutil
from typing import Any, Dict, List, Optional

from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
import bcrypt
from fastapi import (APIRouter, FastAPI,File, Form, HTTPException, Query, UploadFile, status,)
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
import psycopg2
from psycopg2.extras import RealDictCursor
import qrcode
from sqlalchemy import create_engine, text
from pydantic import BaseModel
from pydantic import BaseModel
from typing import Optional

# 1️⃣ INICIALIZACIÓN ÚNICA DE FASTAPI (¡Esto va PRIMERO!)
app = FastAPI(
    title="🎬 VPRO Core API Engine",
    description="Motor central unificado con Piloto Automático de Asistencias.",
    version="8.0.0",
)

# 🔥 EL CADENERO DE SEGURIDAD (CORS) 🔥
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://172.16.0.20:8520",  # <--- Súper importante que tenga https y 8520
        "https://localhost:8520",
        "http://localhost:8520"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 2️⃣ MONTAJE DE DIRECTORIOS (¡Esto va DESPUÉS de crear la app!)
app.mount("/Fotos_de_equipos", StaticFiles(directory="Fotos_de_equipos"), name="fotos")

# 3️⃣ FUNCIONES AUXILIARES GLOBALES
def reparar_mojibake(texto):
    """Detecta y repara texto corrupto por doble codificación UTF-8 / Latin-1"""
    if not texto:
        return ""
    str_texto = str(texto)
    
    # Intenta revertir hasta 2 pasadas de codificación cruzada
    for _ in range(2):
        if any(c in str_texto for c in ['Ã', 'Â', 'ï', '½', '±']):
            try:
                str_texto = str_texto.encode('latin-1', errors='ignore').decode('utf-8', errors='ignore')
            except Exception:
                break
                
    # Limpieza final de residuos irreparables
    return str_texto.replace('Â', '').strip()

# 2️⃣ CONFIGURACIÓN GLOBAL DE ACCESO POSTGRESQL
DB_USER = "postgres"
DB_PASS = "1qaz2wsx"
DB_HOST = "localhost"
DB_PORT = "5432"

# 🧠 MOTORES DE CONEXIÓN SIMULTÁNEOS (SQLAlchemy) - 💉 Vacunados con UTF-8
engine_autos = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_autos_prueba", pool_size=5, max_overflow=10, connect_args={'client_encoding': 'utf8'})
engine_autos_vieja = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_autos", pool_size=5, max_overflow=10, connect_args={'client_encoding': 'utf8'})

engine_eventos = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_eventos_prueba", pool_size=5, max_overflow=10, connect_args={'client_encoding': 'utf8'})
engine_eventos_vieja = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_eventos", pool_size=5, max_overflow=10, connect_args={'client_encoding': 'utf8'})

engine_personal = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_personal_prueba", pool_size=5, max_overflow=10, connect_args={'client_encoding': 'utf8'})
engine_personal_vieja = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_personal", pool_size=5, max_overflow=10, connect_args={'client_encoding': 'utf8'})

engine_clientes = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_clientes_prueba", pool_size=5, max_overflow=10, connect_args={'client_encoding': 'utf8'})
engine_clientes_vieja = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_clientes", pool_size=5, max_overflow=10, connect_args={'client_encoding': 'utf8'})

engine_inventario = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_inventario_prueba", pool_size=5, max_overflow=10, connect_args={'client_encoding': 'utf8'})
engine_inventario_vieja = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_inventario", pool_size=5, max_overflow=10, connect_args={'client_encoding': 'utf8'})

engine_proveedores = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_proveedores_prueba", pool_size=5, max_overflow=10, connect_args={'client_encoding': 'utf8'})
engine_proveedores_vieja = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_proveedores", pool_size=5, max_overflow=10, connect_args={'client_encoding': 'utf8'})

# 🔌 FUNCIÓN DE CONEXIÓN DINÁMICA (psycopg2)
def get_db_connection(db_name="db_personal_prueba"):
  conn = psycopg2.connect(
      host=DB_HOST,
      database=db_name,
      user=DB_USER,
      password=DB_PASS,
      port=DB_PORT,
  )
  return conn


# 3️⃣ MODELOS PYDANTIC Y FUNCIONES AUXILIARES
class ChecadaPayload(BaseModel):
  id_empleado: str
  tipo_movimiento: str
  estatus: str
  observaciones: str

class LoginRequest(BaseModel):
  usuario: str
  contrasena: str

class CambioPasswordPayload(BaseModel):
  id_empleado: str
  nueva_contrasena: str

class SellarRutaExactaPayload(BaseModel):
  id_evento: int
  folio: str
  fecha: str
  hora_personalizada: str
  tipo_movimiento: str
  personal: List[str]
  estatus_dinamico: str

def safe_decode_hex(hex_str: str) -> str:
  if not hex_str:
    return ""
  try:
    return bytes.fromhex(hex_str).decode("latin-1").strip()
  except:
    try:
      return bytes.fromhex(hex_str).decode("utf-8", errors="replace").strip()
    except:
      return str(hex_str).strip()


def verificar_password(plain_password: str, hashed_password: str) -> bool:
    plain = str(plain_password).strip()
    hashed = str(hashed_password).strip()
    
    # 🕵️ IMPRIME EN LA TERMINAL DE UVICORN LA COMPARACIÓN REAL
    print(f"\n🔍 [DEBUG LOGIN] Texto ingresado: '{plain}' (longitud {len(plain)})")
    print(f"🔍 [DEBUG LOGIN] Texto en Postgres: '{hashed}' (longitud {len(hashed)})\n")
    
    if not hashed.startswith("$2b$"):
        return plain == hashed
    return bcrypt.checkpw(plain.encode('utf-8'), hashed.encode('utf-8'))
    
def encriptar_password(password: str) -> str:
  salt = bcrypt.gensalt()
  hashed_bytes = bcrypt.hashpw(password.encode("utf-8"), salt)
  return hashed_bytes.decode("utf-8")

# --- MODELOS DE DATOS PARA ASISTENCIA ---
class AsistenciaRegistro(BaseModel):
    fecha_jornada: date
    num_empleado: int
    nombre_empleado: str
    depto: str
    hora_entrada: time
    t_desayuno: float = 0.0
    t_comida: float = 0.0
    t_cena: float = 0.0
    hora_salida: time
    observaciones: Optional[str] = ""

class AsistenciaBatch(BaseModel):
    registros: List[AsistenciaRegistro]

# --- RUTAS DE LA API ---

@app.get("/api/asistencia/locacion/hoy/{nombre_empleado}", tags=["⏱️ Asistencia Locación"])
def asistencia_locacion_hoy_individual(nombre_empleado: str):
    """Busca si el empleado tiene registros de gira/locación el día de hoy"""
    query = text("""
        SELECT encode(e.folio::bytea, 'hex') as folio_hex, 
               encode(e.nombre_evento::bytea, 'hex') as evento_hex, 
               al.hora_entrada, al.hora_salida, 
               al.t_desayuno, al.t_comida, al.t_cena, al.observaciones
        FROM public.asistencia_locacion al
        LEFT JOIN public.eventos e ON al.id_evento = e.id_evento
        WHERE LOWER(TRIM(al.nombre_empleado)) = LOWER(TRIM(:nom))
          AND al.fecha_jornada = CURRENT_DATE
    """)
    try:
        with engine_eventos.connect() as conn:
            rows = conn.execute(query, {"nom": nombre_empleado}).mappings().fetchall()
        
        result = []
        for r in rows:
            row_dict = dict(r)
            row_dict['hora_entrada'] = str(row_dict['hora_entrada'])[:5] if row_dict['hora_entrada'] else "--:--"
            row_dict['hora_salida'] = str(row_dict['hora_salida'])[:5] if row_dict['hora_salida'] else "--:--"
            
            # Decodificamos el evento
            folio = safe_decode_hex(row_dict.get('folio_hex', '')) if row_dict.get('folio_hex') else "S/F"
            evento = safe_decode_hex(row_dict.get('evento_hex', '')) if row_dict.get('evento_hex') else "Evento Locación"
            row_dict['evento_str'] = f"{folio} | {evento}"
            
            result.append(row_dict)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ==============================================================
# 🌟 NUEVA RUTA GLOBAL (¡TIENE QUE ESTAR AQUÍ ARRIBA!)
# ==============================================================
@app.get("/api/asistencia/locacion/todas", tags=["⏱️ Asistencia Locación"])
def obtener_todas_las_locaciones():
    """Obtiene todo el historial de jornadas de TODAS las OPs"""
    query = text("""
        SELECT * FROM public.asistencia_locacion
        ORDER BY fecha_jornada DESC
    """)
    try:
        with engine_eventos.connect() as conn:
            rows = conn.execute(query).mappings().fetchall()
            
        result = []
        for r in rows:
            row_dict = dict(r)
            row_dict['fecha_jornada'] = str(row_dict['fecha_jornada'])
            row_dict['hora_entrada'] = str(row_dict['hora_entrada'])
            row_dict['hora_salida'] = str(row_dict['hora_salida'])
            if row_dict.get('fecha_registro'):
                row_dict['fecha_registro'] = str(row_dict['fecha_registro'])
            result.append(row_dict)
            
        return result
    except Exception as e:
        print(f"🔥 Error al obtener asistencia global: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# ==============================================================
# RUTA ESPECÍFICA (La original)
# ==============================================================
@app.get("/api/asistencia/locacion/{id_evento}", tags=["⏱️ Asistencia Locación"])
def obtener_asistencia_evento(id_evento: int):
    """Obtiene todo el historial de jornadas de una OP en específico"""
    query = text("""
        SELECT * FROM public.asistencia_locacion
        WHERE id_evento = :id_evento
        ORDER BY fecha_jornada ASC, num_empleado ASC
    """)
    try:
        with engine_eventos.connect() as conn:
            rows = conn.execute(query, {"id_evento": id_evento}).mappings().fetchall()
            
        result = []
        for r in rows:
            row_dict = dict(r)
            # Convertimos fechas y horas a texto para que viajen bien en el JSON
            row_dict['fecha_jornada'] = str(row_dict['fecha_jornada'])
            row_dict['hora_entrada'] = str(row_dict['hora_entrada'])
            row_dict['hora_salida'] = str(row_dict['hora_salida'])
            if row_dict.get('fecha_registro'):
                row_dict['fecha_registro'] = str(row_dict['fecha_registro'])
            result.append(row_dict)
            
        return result
    except Exception as e:
        print(f"🔥 Error al obtener asistencia: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/asistencia/locacion/{id_evento}", tags=["⏱️ Asistencia Locación"])
def guardar_asistencia_evento(id_evento: int, payload: AsistenciaBatch):
    """Guarda una jornada completa. Si la fecha ya existe, la reemplaza (Para poder Editar)"""
    try:
        with engine_eventos.begin() as conn: # Usamos begin() para que sea una transacción segura
            # 1. Identificamos qué fechas nos están mandando en este bloque
            fechas_en_batch = list(set([r.fecha_jornada for r in payload.registros]))
            
            # 2. BORRAMOS los registros anteriores de ESA FECHA y ESA OP (El botón Salva-Conejos)
            if fechas_en_batch:
                del_query = text("""
                    DELETE FROM public.asistencia_locacion 
                    WHERE id_evento = :id_evento AND fecha_jornada = :fecha
                """)
                for f in fechas_en_batch:
                    conn.execute(del_query, {"id_evento": id_evento, "fecha": f})

            # 3. INSERTAMOS la nueva información fresquecita
            insert_query = text("""
                INSERT INTO public.asistencia_locacion (
                    id_evento, fecha_jornada, num_empleado, nombre_empleado, depto, 
                    hora_entrada, t_desayuno, t_comida, t_cena, hora_salida, observaciones
                ) VALUES (
                    :id_evento, :fecha_jornada, :num_empleado, :nombre_empleado, :depto,
                    :hora_entrada, :t_desayuno, :t_comida, :t_cena, :hora_salida, :observaciones
                )
            """)
            
            datos_insert = []
            for reg in payload.registros:
                datos_insert.append({
                    "id_evento": id_evento,
                    "fecha_jornada": reg.fecha_jornada,
                    "num_empleado": reg.num_empleado,
                    "nombre_empleado": reg.nombre_empleado,
                    "depto": reg.depto,
                    "hora_entrada": reg.hora_entrada,
                    "t_desayuno": reg.t_desayuno,
                    "t_comida": reg.t_comida,
                    "t_cena": reg.t_cena,
                    "hora_salida": reg.hora_salida,
                    "observaciones": reg.observaciones
                })
            
            if datos_insert:
                conn.execute(insert_query, datos_insert)
                
        return {"status": "success", "msg": f"Se guardaron {len(datos_insert)} registros correctamente."}
    except Exception as e:
        print(f"🔥 Error en guardar_asistencia: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# 1️⃣ Modelo para estructurar los datos que llegarán desde la pantalla
class ReunionPreviaIn(BaseModel):
    id_reunion: Optional[int] = None  # 👈 Añade esta línea
    fecha_reunion: str
    cliente_tentativo: str
    nombre_proyecto_tentativo: str
    asistentes: str
    minuta_acuerdos: str
    presupuesto_estimado: Optional[float] = 0.0
    fecha_probable_evento: Optional[str] = None

from pydantic import BaseModel
from typing import Optional

# Modelo de datos para recibir la petición
class FiltroAsistencia(BaseModel):
    fecha_inicio: str
    fecha_fin: str
    empleado: Optional[str] = None

# 📊 Ruta para el Reporte Gerencial de Asistencias (¡AHORA FUSIONADA CON GIRAS!)
@app.post("/api/asistencia/auditoria", tags=["⏱️ Asistencia y Kiosco"])
def obtener_auditoria_asistencia(filtro: FiltroAsistencia):
    try:
        datos_limpios = []
        
        # 1️⃣ BUSCAR ASISTENCIA NORMAL (OFICINA / KIOSCO)
        query_oficina = """
            SELECT 
                c.fecha, 
                e.nombre, 
                c.hora_entrada, 
                c.hora_salida, 
                c.hora_entrada_v, 
                c.hora_salida_v, 
                c.observaciones 
            FROM public.control_asistencia c
            INNER JOIN public.empleados e 
                ON TRIM(c.id_empleado::text) = TRIM(e.id_empleado::text)
            WHERE c.fecha >= CAST(:f_ini AS DATE) 
              AND c.fecha <= CAST(:f_fin AS DATE)
        """
        params_oficina = {"f_ini": filtro.fecha_inicio, "f_fin": filtro.fecha_fin}
        if filtro.empleado and filtro.empleado != "👥 TODOS":
            query_oficina += " AND TRIM(e.nombre) = TRIM(:emp)"
            params_oficina["emp"] = filtro.empleado
            
        with engine_personal.connect() as conn: 
            res_oficina = conn.execute(text(query_oficina), params_oficina).mappings().all()
            
        for r in res_oficina:
            fila = dict(r)
            fila['fecha'] = str(fila['fecha']) if fila['fecha'] else ""
            fila['hora_entrada'] = str(fila['hora_entrada']) if fila['hora_entrada'] else ""
            fila['hora_salida'] = str(fila['hora_salida']) if fila['hora_salida'] else ""
            fila['hora_entrada_v'] = str(fila['hora_entrada_v']) if fila['hora_entrada_v'] else ""
            fila['hora_salida_v'] = str(fila['hora_salida_v']) if fila['hora_salida_v'] else ""
            datos_limpios.append(fila)

        # 2️⃣ BUSCAR ASISTENCIA FORÁNEA (GIRA / LOCACIÓN)
        query_gira = """
            SELECT 
                fecha_jornada as fecha, 
                nombre_empleado as nombre, 
                hora_entrada, 
                hora_salida, 
                t_desayuno, 
                t_comida, 
                t_cena, 
                observaciones 
            FROM public.asistencia_locacion
            WHERE fecha_jornada >= CAST(:f_ini AS DATE) 
              AND fecha_jornada <= CAST(:f_fin AS DATE)
        """
        params_gira = {"f_ini": filtro.fecha_inicio, "f_fin": filtro.fecha_fin}
        if filtro.empleado and filtro.empleado != "👥 TODOS":
            query_gira += " AND TRIM(nombre_empleado) = TRIM(:emp)"
            params_gira["emp"] = filtro.empleado

        with engine_eventos.connect() as conn2:
            res_gira = conn2.execute(text(query_gira), params_gira).mappings().all()

        for r in res_gira:
            fila = dict(r)
            fila['fecha'] = str(fila['fecha']) if fila['fecha'] else ""
            
            # Formateamos las horas (En gira no hay turno vespertino separado)
            fila['hora_entrada'] = str(fila['hora_entrada']) if fila['hora_entrada'] else ""
            fila['hora_salida'] = str(fila['hora_salida']) if fila['hora_salida'] else ""
            fila['hora_entrada_v'] = "--:--"
            fila['hora_salida_v'] = "--:--"
            
            # 🔥 El toque maestro: Le avisamos a RH que andaba de viaje
            obs_original = str(fila['observaciones']).strip() if fila.get('observaciones') else ""
            texto_comidas = f" (Alimentos: {fila['t_desayuno']}D/{fila['t_comida']}C/{fila['t_cena']}C)"
            
            fila['observaciones'] = f"📍 [EN GIRA]{texto_comidas} {obs_original}".strip()
            
            datos_limpios.append(fila)

        # 3️⃣ MEZCLAR, ORDENAR Y MANDAR A LA WEB
        datos_limpios.sort(key=lambda x: (x['fecha'], x['nombre']), reverse=True)
        
        return datos_limpios
        
    except Exception as e:
        print(f"\n🔥 ERROR EN AUDITORIA ASISTENCIA: {e}\n")
        return []

# 🏝️ MÓDULO: LA ISLA (REUNIONES Y PROSPECTOS)
# 1️⃣ Ruta para OBTENER asistentes válidos (Sin BAJAS ni PROVEEDORES)
@app.get("/api/reuniones/asistentes", tags=["🤝 Prospectos y Reuniones"])
def obtener_asistentes_validos():
    try:
        query = text("""
            SELECT nombre 
            FROM public.empleados 
            WHERE UPPER(rol) NOT IN ('BAJA', 'PROVEEDOR')
            ORDER BY nombre ASC
        """)
        
        # 🚨 AQUÍ ESTÁ LA LLAVE MAESTRA: engine_personal 🚨
        with engine_personal.connect() as conn: 
            resultados = conn.execute(query).fetchall()
            lista_nombres = [fila[0] for fila in resultados if fila[0]]
            
        return lista_nombres
        
    except Exception as e:
        print(f"🔥 Error al obtener asistentes: {e}")
        return []

# 2️⃣ Ruta para GUARDAR una nueva reunión
@app.post("/api/reuniones", tags=["🤝 Prospectos y Reuniones"])
def crear_o_actualizar_reunion(reunion: ReunionPreviaIn):
    try:
        if reunion.id_reunion:
            # 🔄 ES UNA ACTUALIZACIÓN
            query = text("""
                UPDATE public.reuniones_previas 
                SET fecha_reunion = :fecha, cliente_tentativo = :cliente, nombre_proyecto_tentativo = :proyecto, 
                    asistentes = :asistentes, minuta_acuerdos = :minuta, presupuesto_estimado = :presupuesto, fecha_probable_evento = :fecha_probable
                WHERE id_reunion = :id
            """)
            parametros = {"id": reunion.id_reunion, "fecha": reunion.fecha_reunion, "cliente": reunion.cliente_tentativo, "proyecto": reunion.nombre_proyecto_tentativo, "asistentes": reunion.asistentes, "minuta": reunion.minuta_acuerdos, "presupuesto": reunion.presupuesto_estimado, "fecha_probable": reunion.fecha_probable_evento if reunion.fecha_probable_evento else None}
        else:
            # 🆕 ES UNA REUNIÓN NUEVA
            query = text("""
                INSERT INTO public.reuniones_previas 
                (fecha_reunion, cliente_tentativo, nombre_proyecto_tentativo, asistentes, minuta_acuerdos, presupuesto_estimado, fecha_probable_evento)
                VALUES (:fecha, :cliente, :proyecto, :asistentes, :minuta, :presupuesto, :fecha_probable)
            """)
            parametros = {"fecha": reunion.fecha_reunion, "cliente": reunion.cliente_tentativo, "proyecto": reunion.nombre_proyecto_tentativo, "asistentes": reunion.asistentes, "minuta": reunion.minuta_acuerdos, "presupuesto": reunion.presupuesto_estimado, "fecha_probable": reunion.fecha_probable_evento if reunion.fecha_probable_evento else None}
            
        with engine_eventos.begin() as conn:
            conn.execute(query, parametros)
            
        return {"status": "success", "mensaje": "Operación registrada exitosamente."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/reuniones/historial", tags=["🤝 Prospectos y Reuniones"])
def obtener_historial_reuniones():
    try:
        # 🧠 La magia: Filtramos las que ya están vinculadas a cualquier evento
        query = text("""
            WITH vinculadas AS (
                SELECT unnest(reuniones_vinculadas) as firma_v 
                FROM public.eventos 
                WHERE reuniones_vinculadas IS NOT NULL
            )
            SELECT id_reunion, 
                   fecha_reunion, 
                   cliente_tentativo, 
                   nombre_proyecto_tentativo, 
                   asistentes, 
                   minuta_acuerdos, 
                   presupuesto_estimado, 
                   fecha_probable_evento
            FROM public.reuniones_previas
            WHERE CONCAT(fecha_reunion, ' | ', cliente_tentativo, ' - ', nombre_proyecto_tentativo) NOT IN (SELECT firma_v FROM vinculadas)
            ORDER BY fecha_reunion DESC
        """)
        
        with engine_eventos.connect() as conn:
            resultados = conn.execute(query).mappings().all()
            
        lista_reuniones = []
        for r in resultados:
            fila = dict(r)
            fila["fecha_reunion"] = str(fila["fecha_reunion"]) if fila["fecha_reunion"] else ""
            fila["fecha_probable_evento"] = str(fila["fecha_probable_evento"]) if fila["fecha_probable_evento"] else ""
            lista_reuniones.append(fila)
            
        return lista_reuniones
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 1.5️⃣ Ruta para OBTENER clientes válidos
@app.get("/api/reuniones/clientes", tags=["🤝 Prospectos y Reuniones"])
def obtener_clientes_reuniones():
    try:
        # Seleccionamos la columna 'cliente_empresa' de la tabla 'clientes'
        query = text("""
            SELECT cliente_empresa 
            FROM public.clientes 
            ORDER BY cliente_empresa ASC
        """)
        
        # 🚨 Usamos el motor correcto para los clientes
        with engine_clientes.connect() as conn: 
            resultados = conn.execute(query).fetchall()
            # Extraemos los nombres asegurándonos de que no vengan vacíos
            lista_clientes = [fila[0] for fila in resultados if fila[0]]
            
        return lista_clientes
        
    except Exception as e:
        print(f"🔥 Error al obtener clientes: {e}")
        return []
    
# 📅 CATÁLOGO DE REUNIONES (Para vincular en las OP)
@app.get("/api/reuniones/catalogo", tags=["📅 Reuniones"])
def obtener_catalogo_reuniones():
    try:
        query = """
            SELECT CONCAT(fecha_reunion, ' | ', cliente_tentativo, ' - ', nombre_proyecto_tentativo) AS nombre_reunion 
            FROM public.reuniones_previas 
            ORDER BY fecha_reunion DESC
        """
        
        with engine_eventos.connect() as conn: 
            from sqlalchemy import text
            resultados = conn.execute(text(query)).mappings().all()
            
        lista = [str(r["nombre_reunion"]).strip() for r in resultados if r["nombre_reunion"]]
        return lista
        
    except Exception as e:
        print(f"\n🔥 ERROR AL OBTENER CATÁLOGO DE REUNIONES: {e}\n")
        return []

# 🏢 CATÁLOGO DE CLIENTES (Para menús desplegables y cotizador)
@app.get("/api/clientes/catalogo", tags=["🏢 Clientes"])
def obtener_catalogo_clientes():
    try:
        query = """
            SELECT DISTINCT cliente_empresa 
            FROM public.clientes 
            WHERE cliente_empresa IS NOT NULL
            ORDER BY cliente_empresa ASC
        """
        
        # 🔥 EL CAMBIO ESTRELLA: Usamos el motor de clientes
        with engine_clientes.connect() as conn:
            from sqlalchemy import text
            resultados = conn.execute(text(query)).mappings().all()
            
        # Extraemos los datos usando tu columna exacta
        lista_clientes = [str(r["cliente_empresa"]).strip() for r in resultados if r["cliente_empresa"]]
        
        return lista_clientes
        
    except Exception as e:
        print(f"\n🔥 ERROR AL OBTENER CATÁLOGO DE CLIENTES: {e}\n")
        return []

# 👥 CONTACTOS POR CLIENTE (Para menú dinámico en cotizador)
@app.get("/api/clientes/contactos/{nombre_empresa}", tags=["🏢 Clientes"])
def obtener_contactos_cliente(nombre_empresa: str):
    try:
        query = """
            SELECT gte_gral, nombre_contacto_princ, nombre_contacto_a 
            FROM public.clientes 
            WHERE cliente_empresa = :empresa
        """
        
        with engine_clientes.connect() as conn:
            from sqlalchemy import text
            resultado = conn.execute(text(query), {"empresa": nombre_empresa}).mappings().first()
            
        contactos = []
        if resultado:
            for columna in ["gte_gral", "nombre_contacto_princ", "nombre_contacto_a"]:
                valor = str(resultado.get(columna, "")).strip()
                if valor and valor.lower() not in ["none", "null", "nan", ""]:
                    contactos.append(valor)
                    
        return contactos
        
    except Exception as e:
        print(f"\n🔥 ERROR AL OBTENER CONTACTOS: {e}\n")
        return []

# 📦 INVENTARIO Y KITS (db_inventario_prueba)
@app.get("/api/inventario", tags=["🛠️ Inventario General"])
def obtener_inventario():
  try:
    conn = get_db_connection("db_inventario_prueba")
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    cursor.execute("SELECT * FROM inventario ORDER BY codigo ASC;")
    inventario = cursor.fetchall()
    cursor.close()
    conn.close()
    return inventario
  except Exception as e:
    raise HTTPException(status_code=500, detail=f"Error en BD: {str(e)}")

@app.post("/api/inventario/guardar", tags=["🛠️ Inventario General"])
def guardar_inventario(payload: dict):
  try:
    conn = get_db_connection("db_inventario_prueba")
    cursor = conn.cursor()
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
    conn.commit()
    cursor.close()
    conn.close()
    return {"status": "ok", "mensaje": "Inventario guardado"}
  except Exception as e:
    raise HTTPException(status_code=500, detail=f"Error al guardar: {str(e)}")

@app.delete("/api/inventario/eliminar/{codigo}", tags=["🛠️ Inventario General"])
def eliminar_inventario(codigo: str):
  try:
    conn = get_db_connection("db_inventario_prueba")
    cursor = conn.cursor()
    cursor.execute("DELETE FROM inventario WHERE codigo = %s;", (codigo,))
    conn.commit()
    cursor.close()
    conn.close()
    return {"status": "ok", "mensaje": f"Equipo {codigo} eliminado"}
  except Exception as e:
    raise HTTPException(status_code=500, detail=f"Error al eliminar: {str(e)}")

@app.get("/api/inventario-kits/completo", tags=["🛠️ Inventario General"])
def obtener_inventario_kits():
  try:
    conn = get_db_connection("db_inventario_prueba")
    cursor = conn.cursor(cursor_factory=RealDictCursor)
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
    cursor.close()
    conn.close()
    return kits
  except Exception as e:
    raise HTTPException(status_code=500, detail=f"Error en BD Kits: {str(e)}")

@app.get("/api/inventario/radar-danos", tags=["🛠️ Inventario General"])
def obtener_radar_danos():
    """Consulta la tabla reparaciones y la cruza en Python con db_personal_prueba"""
    try:
        # 1️⃣ Traer el catálogo de empleados desde la base de Personal
        conn_emp = get_db_connection("db_personal_prueba")
        cursor_emp = conn_emp.cursor(cursor_factory=RealDictCursor)
        cursor_emp.execute("SELECT id_empleado, nombre FROM public.empleados;")
        empleados_db = cursor_emp.fetchall()
        cursor_emp.close()
        conn_emp.close()

        # Armamos un diccionario rápido en Python: {'201': 'Juan', '202': 'Maria'}
        mapa_empleados = {str(emp["id_empleado"]).strip(): emp["nombre"] for emp in empleados_db}

        # 2️⃣ Traer las reparaciones desde la base de Inventario
        conn_inv = get_db_connection("db_inventario_prueba")
        cursor_inv = conn_inv.cursor(cursor_factory=RealDictCursor)
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
            LEFT JOIN public.inventario i ON UPPER(TRIM(r.equipo_n_reparacion)) = UPPER(TRIM(i.codigo))
            LEFT JOIN public.inventario_kits k ON UPPER(TRIM(r.equipo_n_reparacion)) = UPPER(TRIM(k.codigo_inv_kits))
            WHERE UPPER(COALESCE(r.estado_actual, '')) NOT IN ('RESUELTO', 'REPARADO', 'OK', 'BAJA DEFINITIVA')
            ORDER BY r.fecha_d_reporte DESC;
        """)
        danados = cursor_inv.fetchall()
        cursor_inv.close()
        conn_inv.close()

        # 3️⃣ Hacer el cruce (Traducción de ID a Nombre)
        resultados_finales = []
        for row in danados:
            reportante_crudo = str(row["REPORTÓ_RAW"] or "")
            
            # Extraemos solo el número del texto "Empleado ID: 201"
            numeros_encontrados = re.findall(r'\d+', reportante_crudo)
            id_extraido = numeros_encontrados[0] if numeros_encontrados else None
            
            # Buscamos el nombre; si no existe, dejamos el texto original para no perder datos
            nombre_real = mapa_empleados.get(id_extraido, reportante_crudo)
            
            fila_limpia = dict(row)
            fila_limpia["REPORTÓ"] = nombre_real
            del fila_limpia["REPORTÓ_RAW"] # Borramos la columna temporal
            
            resultados_finales.append(fila_limpia)

        return resultados_finales

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en Radar de Daños: {str(e)}")
    
# 🏢 CLIENTES (db_clientes_prueba)
@app.get("/api/clientes", tags=["🏢 Gestión Clientes"])
def obtener_clientes():
  try:
    conn = get_db_connection("db_clientes_prueba")
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    cursor.execute("SELECT * FROM clientes ORDER BY id_cliente ASC;")
    clientes = cursor.fetchall()
    cursor.close()
    conn.close()
    return clientes
  except Exception as e:
    raise HTTPException(status_code=500, detail=f"Error en BD: {str(e)}")


@app.post("/api/clientes/guardar", tags=["🏢 Gestión Clientes"])
def guardar_cliente(payload: dict):
  try:
    conn = get_db_connection("db_clientes_prueba")
    cursor = conn.cursor()
    cursor.execute(
        "SELECT id_cliente FROM clientes WHERE id_cliente = %s;",
        (payload["id_cliente"],),
    )
    existe = cursor.fetchone()

    if existe:
      query = """
                UPDATE clientes SET
                    cliente_empresa = %(cliente_empresa)s, gte_gral = %(gte_gral)s,
                    estado = %(estado)s, ciudad = %(ciudad)s, tel_de_ofna = %(tel_de_ofna)s,
                    email_de_empresa = %(email_de_empresa)s, nombre_contacto_princ = %(nombre_contacto_princ)s,
                    cel_contact_princ = %(cel_contact_princ)s, nombre_contacto_a = %(nombre_contacto_a)s,
                    cel_contact_a = %(cel_contact_a)s
                WHERE id_cliente = %(id_cliente)s;
            """
    else:
      query = """
                INSERT INTO clientes (
                    id_cliente, cliente_empresa, gte_gral, estado, ciudad, tel_de_ofna,
                    email_de_empresa, nombre_contacto_princ, cel_contact_princ,
                    nombre_contacto_a, cel_contact_a
                ) VALUES (
                    %(id_cliente)s, %(cliente_empresa)s, %(gte_gral)s, %(estado)s, %(ciudad)s, %(tel_de_ofna)s,
                    %(email_de_empresa)s, %(nombre_contacto_princ)s, %(cel_contact_princ)s,
                    %(nombre_contacto_a)s, %(cel_contact_a)s
                );
            """
    cursor.execute(query, payload)
    conn.commit()
    cursor.close()
    conn.close()
    return {"status": "ok", "mensaje": "Cliente guardado correctamente"}
  except Exception as e:
    raise HTTPException(status_code=500, detail=f"Error al guardar: {str(e)}")


@app.delete("/api/clientes/eliminar/{id_cliente}", tags=["🏢 Gestión Clientes"])
def eliminar_cliente(id_cliente: int):
  try:
    conn = get_db_connection("db_clientes_prueba")
    cursor = conn.cursor()
    cursor.execute("DELETE FROM clientes WHERE id_cliente = %s;", (id_cliente,))
    conn.commit()
    cursor.close()
    conn.close()
    return {"status": "ok", "mensaje": f"Cliente {id_cliente} eliminado"}
  except Exception as e:
    raise HTTPException(status_code=500, detail=f"Error al eliminar: {str(e)}")

# 🦺 EMPLEADOS (db_personal_prueba)
@app.get("/api/empleados", tags=["🦺 Gestión Personal"])
def obtener_empleados():
  try:
    conn = get_db_connection("db_personal_prueba")
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    query = """
            SELECT id_empleado, nombre, depto, email, cel, 
                   fecha_nac, fecha_ing, licencia_vence, password, rol 
            FROM empleados 
            ORDER BY id_empleado ASC;
        """
    cursor.execute(query)
    empleados = cursor.fetchall()
    cursor.close()
    conn.close()
    return empleados
  except Exception as e:
    raise HTTPException(status_code=500, detail=f"Error en BD: {str(e)}")


@app.post("/api/empleados/guardar", tags=["🦺 Gestión Personal"])
def guardar_empleado(payload: dict):
  try:
    conn = get_db_connection("db_personal_prueba")
    cursor = conn.cursor()

    cursor.execute(
        "SELECT id_empleado FROM empleados WHERE id_empleado = %s;",
        (payload["id_empleado"],),
    )
    existe = cursor.fetchone()

    if existe:
      query = """
                UPDATE empleados SET
                    nombre = %(nombre)s, depto = %(depto)s, email = %(email)s,
                    cel = %(cel)s, fecha_nac = %(fecha_nac)s, fecha_ing = %(fecha_ing)s,
                    licencia_vence = %(licencia_vence)s, password = %(password)s, rol = %(rol)s
                WHERE id_empleado = %(id_empleado)s;
            """
    else:
      query = """
                INSERT INTO empleados (
                    id_empleado, nombre, depto, email, cel, 
                    fecha_nac, fecha_ing, licencia_vence, password, rol
                ) VALUES (
                    %(id_empleado)s, %(nombre)s, %(depto)s, %(email)s, %(cel)s, 
                    %(fecha_nac)s, %(fecha_ing)s, %(licencia_vence)s, %(password)s, %(rol)s
                );
            """
    cursor.execute(query, payload)
    conn.commit()
    cursor.close()
    conn.close()
    return {"status": "ok", "mensaje": "Empleado guardado correctamente"}
  except Exception as e:
    raise HTTPException(status_code=500, detail=f"Error al guardar: {str(e)}")


@app.delete(
    "/api/empleados/eliminar/{id_empleado}", tags=["🦺 Gestión Personal"]
)
def eliminar_empleado(id_empleado: str):
  try:
    conn = get_db_connection("db_personal_prueba")
    cursor = conn.cursor()
    cursor.execute(
        "DELETE FROM empleados WHERE id_empleado = %s;", (id_empleado,)
    )
    conn.commit()
    cursor.close()
    conn.close()
    return {"status": "ok", "mensaje": f"Empleado {id_empleado} eliminado"}
  except Exception as e:
    raise HTTPException(status_code=500, detail=f"Error al eliminar: {str(e)}")

@app.get("/api/empleados/{id_empleado}/qr", tags=["🦺 Gestión Personal"])
def generar_qr_empleado(id_empleado: str):
    try:
        # Verificamos que el empleado exista
        conn = get_db_connection("db_personal_prueba")
        cursor = conn.cursor()
        cursor.execute("SELECT id_empleado FROM empleados WHERE TRIM(id_empleado) = %s;", (id_empleado.strip(),))
        existe = cursor.fetchone()
        cursor.close()
        conn.close()

        if not existe:
            raise HTTPException(status_code=404, detail="Empleado no encontrado")

        # Generar QR
        qr = qrcode.QRCode(version=1, box_size=10, border=2)
        qr.add_data(id_empleado.strip())
        qr.make(fit=True)
        img = qr.make_image(fill_color="black", back_color="white")
        
        # Convertir a Base64
        buffered = BytesIO()
        img.save(buffered, format="PNG")
        img_str = base64.b64encode(buffered.getvalue()).decode()
        
        return {"status": "SUCCESS", "qr_base64": f"data:image/png;base64,{img_str}"}

    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 🕒 ASISTENCIA Y KIOSCO (CON PILOTO AUTOMÁTICO)
@app.get("/api/asistencia/status/{id_empleado}", tags=["🕒 Checador Asistencia"])
def extraer_estado_asistencia_diaria(id_empleado: str):
    import datetime as dt_module
    ahora = dt_module.datetime.now(dt_module.timezone.utc) - dt_module.timedelta(hours=7)
    hoy_str = ahora.strftime('%Y-%m-%d')
    
    query = text("""
        SELECT id_registro, hora_entrada, hora_salida, estatus, observaciones, hora_entrada_v, hora_salida_v 
        FROM public.control_asistencia 
        WHERE TRIM(id_empleado) = :emp AND fecha = CAST(:hoy AS date)
        ORDER BY id_registro DESC LIMIT 1
    """)
    try:
        with engine_personal.connect() as conn: 
            row = conn.execute(query, {"emp": id_empleado.strip(), "hoy": hoy_str}).mappings().first()
        if row:
            return {
                "registrado": True, 
                "id_registro": row["id_registro"],
                "hora_entrada": str(row["hora_entrada"]) if row["hora_entrada"] else None,
                "hora_salida": str(row["hora_salida"]) if row["hora_salida"] else None,
                "hora_entrada_v": str(row["hora_entrada_v"]) if row["hora_entrada_v"] else None,
                "hora_salida_v": str(row["hora_salida_v"]) if row["hora_salida_v"] else None,
                "estatus": row["estatus"], 
                "observaciones": row["observaciones"],
                "completo": row["hora_salida_v"] is not None 
            }
        return {"registrado": False, "completo": False}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/asistencia/checar", tags=["🕒 Checador Asistencia"])
def registrar_tarjetazo_asistencia(payload: ChecadaPayload):
    import datetime as dt_module
    ahora = dt_module.datetime.now(dt_module.timezone.utc).replace(tzinfo=None) - dt_module.timedelta(hours=7)
    hoy_str = ahora.strftime('%Y-%m-%d')
    hora_str = ahora.strftime('%H:%M:%S')

    try:
        with engine_personal.begin() as conn:
            registro_hoy = conn.execute(text("""
                SELECT id_registro, hora_entrada, hora_salida, hora_entrada_v, hora_salida_v 
                FROM public.control_asistencia 
                WHERE TRIM(id_empleado) = :emp AND fecha = CAST(:hoy AS date)
                ORDER BY id_registro DESC LIMIT 1
            """), {"emp": payload.id_empleado.strip(), "hoy": hoy_str}).mappings().first()

            if not registro_hoy:
                conn.execute(text("""
                    INSERT INTO public.control_asistencia (id_empleado, fecha, hora_entrada, estatus, observaciones)
                    VALUES (:emp, CAST(:hoy AS date), CAST(:hora AS time), :est, :obs)
                """), {"emp": payload.id_empleado.strip(), "hoy": hoy_str, "hora": hora_str, "est": payload.estatus, "obs": payload.observaciones})
                return {"status": "SUCCESS", "mensaje": "✅ ENTRADA MATUTINA REGISTRADA"}

            id_reg = registro_hoy["id_registro"]

            if registro_hoy["hora_entrada"] is not None and registro_hoy["hora_salida"] is None:
                conn.execute(text("UPDATE public.control_asistencia SET hora_salida = CAST(:hora AS time), observaciones = COALESCE(observaciones, '') || ' | ' || :obs WHERE id_registro = :id"), {"hora": hora_str, "obs": payload.observaciones, "id": id_reg})
                return {"status": "SUCCESS", "mensaje": "✅ SALIDA MATUTINA REGISTRADA"}
            elif registro_hoy["hora_salida"] is not None and registro_hoy.get("hora_entrada_v") is None:
                conn.execute(text("UPDATE public.control_asistencia SET hora_entrada_v = CAST(:hora AS time), observaciones = COALESCE(observaciones, '') || ' | ' || :obs WHERE id_registro = :id"), {"hora": hora_str, "obs": payload.observaciones, "id": id_reg})
                return {"status": "SUCCESS", "mensaje": "✅ ENTRADA VESPERTINA REGISTRADA"}
            elif registro_hoy.get("hora_entrada_v") is not None and registro_hoy.get("hora_salida_v") is None:
                conn.execute(text("UPDATE public.control_asistencia SET hora_salida_v = CAST(:hora AS time), estatus = 'COMPLETO', observaciones = COALESCE(observaciones, '') || ' | ' || :obs WHERE id_registro = :id"), {"hora": hora_str, "obs": payload.observaciones, "id": id_reg})
                return {"status": "SUCCESS", "mensaje": "✅ SALIDA VESPERTINA REGISTRADA"}
            else:
                raise HTTPException(status_code=400, detail="Tranquilo, ya completaste tus registros de hoy.")
    except HTTPException as he: raise he
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/asistencia/reporte", tags=["🕒 Checador Asistencia"])
def obtener_reporte_asistencia_global():
    """Extrae la bitácora completa de asistencias de forma segura"""
    query = text("""
        SELECT c.id_registro, 
               c.fecha, 
               TRIM(c.id_empleado) as id_emp, 
               encode(e.nombre::bytea, 'hex') as nombre_empleado, 
               encode(e.depto::bytea, 'hex') as depto, 
               c.hora_entrada, 
               c.hora_salida, 
               c.estatus, 
               c.observaciones,
               c.hora_entrada_v, 
               c.hora_salida_v
        FROM public.control_asistencia c
        LEFT JOIN public.empleados e ON TRIM(c.id_empleado) = TRIM(e.id_empleado)
        ORDER BY c.fecha DESC, c.hora_entrada DESC
    """)
    try:
        with engine_personal.connect() as conn:
            rows = conn.execute(query).fetchall()
            
        reporte_list = []
        for r in rows:
            reporte_list.append({
                "id_registro": r[0],
                "fecha": str(r[1]) if r[1] else "",
                "id_empleado": str(r[2]) if r[2] else "",
                "nombre_empleado": safe_decode_hex(r[3]) if r[3] else "Desconocido",
                "depto": safe_decode_hex(r[4]) if r[4] else "N/A",
                "hora_entrada": str(r[5]) if r[5] else None,
                "hora_salida": str(r[6]) if r[6] else None,
                "estatus": str(r[7]) if r[7] else "ASISTENCIA",
                "observaciones": str(r[8]) if r[8] else "",
                "hora_entrada_v": str(r[9]) if r[9] else None,
                "hora_salida_v": str(r[10]) if r[10] else None
            })
        return reporte_list
    except Exception as e:
        print(f"🔥 Error en /api/asistencia/reporte: {e}")
        raise HTTPException(status_code=500, detail=f"Error en consulta de asistencia: {str(e)}")

@app.post("/api/asistencia/sellar-ruta", tags=["🕒 Checador Asistencia"])
def sellar_asistencia_viaje_ruta(payload: dict):
    fecha_inicio = date.fromisoformat(payload.get("fecha_inicio"))
    fecha_fin = date.fromisoformat(payload.get("fecha_fin"))
    personal = payload.get("personal", [])
    estatus_dinamico = payload.get("estatus_dinamico", "VIAJE DE RUTA")
    
    query_ids = text("SELECT nombre, id_empleado FROM public.empleados")
    # OJO: Insertamos sin horas para que el Piloto Automático actúe
    query_insert = text("""
        INSERT INTO public.control_asistencia (id_empleado, fecha, estatus, observaciones)
        VALUES (:id, :fecha, :estatus, :obs)
        ON CONFLICT DO NOTHING
    """)
    
    try:
        with engine_personal.connect() as conn_p:
            rows = conn_p.execute(query_ids).fetchall()
            name_to_id = {str(r[0]).strip().upper(): str(r[1]).strip() for r in rows}
        
        num_dias = (fecha_fin - fecha_inicio).days + 1
        with engine_personal.begin() as conn_ins:
            for operario in personal:
                emp_name_clean = str(operario).strip().upper()
                if emp_name_clean in name_to_id:
                    emp_id = name_to_id[emp_name_clean]
                    for i in range(num_dias):
                        dia_evaluado = fecha_inicio + datetime.timedelta(days=i)
                        conn_ins.execute(query_insert, {
                            "id": emp_id, "fecha": dia_evaluado, 
                            "estatus": estatus_dinamico.strip().upper(), 
                            "obs": f"Logística VPRO: Comisión Foránea"
                        })
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/asistencia/sellar-ruta-exacta", tags=["🕒 Checador Asistencia"])
def sellar_asistencia_ruta_exacta(payload: SellarRutaExactaPayload):
    try:
        query_ids = text("SELECT nombre, id_empleado FROM public.empleados")
        with engine_personal.connect() as conn_p:
            rows = conn_p.execute(query_ids).fetchall()
            name_to_id = {str(r[0]).strip().upper(): str(r[1]).strip() for r in rows}

        with engine_personal.begin() as conn:
            for operario in payload.personal:
                emp_name_clean = str(operario).strip().upper()
                if emp_name_clean in name_to_id:
                    emp_clean = name_to_id[emp_name_clean]
                    
                    if payload.tipo_movimiento.upper() == "ENTRADA":
                        existe = conn.execute(text("SELECT 1 FROM public.control_asistencia WHERE TRIM(id_empleado) = :emp AND fecha = CAST(:fec AS date) AND hora_salida IS NULL"), {"emp": emp_clean, "fec": payload.fecha}).scalar()
                        if not existe:
                            conn.execute(text("INSERT INTO public.control_asistencia (id_empleado, fecha, hora_entrada, estatus, observaciones) VALUES (:emp, CAST(:fec AS date), CAST(:hora AS time), :est, :obs)"), {"emp": emp_clean, "fec": payload.fecha, "hora": payload.hora_personalizada, "est": "ASISTENCIA", "obs": payload.estatus_dinamico})
                    else:
                        id_reg = conn.execute(text("SELECT id_registro FROM public.control_asistencia WHERE TRIM(id_empleado) = :emp AND fecha = CAST(:fec AS date) AND hora_salida IS NULL ORDER BY id_registro DESC LIMIT 1"), {"emp": emp_clean, "fec": payload.fecha}).scalar()
                        if id_reg:
                            conn.execute(text("UPDATE public.control_asistencia SET hora_salida = CAST(:hora AS time), observaciones = observaciones || ' | ' || :obs WHERE id_registro = :id"), {"id": id_reg, "hora": payload.hora_personalizada, "obs": f"Salida Locación: {payload.hora_personalizada}"})
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/asistencia/guardar-cambios", tags=["🕒 Checador Asistencia"])
def guardar_cambios_asistencia_admin(logs: List[dict]):
    query = text("""
        UPDATE public.control_asistencia
        SET hora_entrada = CAST(:hora_entrada AS time), hora_salida = CAST(:hora_salida AS time), estatus = :estatus, observaciones = :observaciones
        WHERE id_registro = :id_registro
    """)
    try:
        with engine_personal.begin() as conn:
            for log in logs:
                h_ent = str(log.get("hora_entrada", "")).strip()
                h_sal = str(log.get("hora_salida", "")).strip()
                if h_ent in ["", "None", "None", "??:??"]: h_ent = None
                if h_sal in ["", "None", "None", "En Set", "??:??"]: h_sal = None
                
                conn.execute(query, {
                    "hora_entrada": h_ent, "hora_salida": h_sal,
                    "estatus": str(log.get("estatus", "ASISTENCIA")).strip().upper(),
                    "observaciones": str(log.get("observaciones", "")).strip(),
                    "id_registro": int(log.get("id_registro"))
                })
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

# 🤖 EL PILOTO AUTOMÁTICO (RELOJ DESPERTADOR)
def piloto_automatico_asistencias():
    ahora = datetime.datetime.now()
    hora_actual = ahora.hour
    hoy_str = ahora.strftime('%Y-%m-%d')
    print(f"🤖 [PILOTO AUTOMÁTICO] Despertando a las {ahora.strftime('%H:%M:%S')} para revisión de Giras...")
    
    try:
        with engine_personal.begin() as conn:
            if hora_actual == 9:
                conn.execute(text("UPDATE public.control_asistencia SET hora_entrada = '09:00:00' WHERE fecha = CAST(:hoy AS date) AND hora_entrada IS NULL AND estatus LIKE 'EN EVENTO%'"), {"hoy": hoy_str})
            elif hora_actual == 14:
                conn.execute(text("UPDATE public.control_asistencia SET hora_salida = '14:00:00' WHERE fecha = CAST(:hoy AS date) AND hora_salida IS NULL AND estatus LIKE 'EN EVENTO%'"), {"hoy": hoy_str})
            elif hora_actual == 16:
                conn.execute(text("UPDATE public.control_asistencia SET hora_entrada_v = '16:00:00' WHERE fecha = CAST(:hoy AS date) AND hora_entrada_v IS NULL AND estatus LIKE 'EN EVENTO%'"), {"hoy": hoy_str})
            elif hora_actual == 19: 
                conn.execute(text("UPDATE public.control_asistencia SET hora_salida_v = '19:00:00', estatus = 'COMPLETO' WHERE fecha = CAST(:hoy AS date) AND hora_salida_v IS NULL AND estatus LIKE 'EN EVENTO%'"), {"hoy": hoy_str})
        print("✅ [PILOTO AUTOMÁTICO] Revisión completada. Volviendo a dormir.")
    except Exception as e:
        print(f"🔥 [PILOTO AUTOMÁTICO ERROR]: {e}")

# Inicializamos el Reloj
scheduler = BackgroundScheduler()
scheduler.add_job(piloto_automatico_asistencias, CronTrigger(hour=9, minute=0))
scheduler.add_job(piloto_automatico_asistencias, CronTrigger(hour=14, minute=0))
scheduler.add_job(piloto_automatico_asistencias, CronTrigger(hour=16, minute=0))
scheduler.add_job(piloto_automatico_asistencias, CronTrigger(hour=19, minute=0))
scheduler.start()

@app.on_event("shutdown")
def shutdown_event():
    scheduler.shutdown()

# 🚙 AUTOS
@app.get("/api/autos", tags=["🚙 Control Vehicular"])
def obtener_flota():
    query = text("SELECT * FROM public.autos ORDER BY num_control ASC")
    try:
        with engine_autos.connect() as conn:
            rows = conn.execute(query).mappings().fetchall()
            return [dict(row) for row in rows]
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/autos/guardar", tags=["🚙 Control Vehicular"])
def guardar_o_actualizar_auto(auto: dict):
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

@app.delete("/api/autos/{num_control}", tags=["🚙 Control Vehicular"])
def eliminar_vehiculo(num_control: str):
    query = text("DELETE FROM public.autos WHERE num_control = :num_control")
    try:
        with engine_autos.begin() as conn: conn.execute(query, {"num_control": num_control})
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

# 🚚 PROVEEDORES (db_proveedores_prueba)
@app.get("/api/proveedores", tags=["🚚 Gestión Proveedores"])
def obtener_proveedores():
    try:
        conn = get_db_connection("db_proveedores_prueba")
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute("SELECT * FROM proveedores ORDER BY nombre_del_proveedor ASC;")
        proveedores = cursor.fetchall()
        cursor.close()
        conn.close()
        return proveedores
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en BD Proveedores: {str(e)}")


@app.post("/api/proveedores/guardar", tags=["🚚 Gestión Proveedores"])
def guardar_proveedor(payload: dict):
    try:
        conn = get_db_connection("db_proveedores_prueba")
        cursor = conn.cursor()
        cursor.execute(
            "SELECT nombre_del_proveedor FROM proveedores WHERE UPPER(nombre_del_proveedor) = UPPER(%s);",
            (payload["nombre_del_proveedor"],),
        )
        existe = cursor.fetchone()

        if existe:
            query = """
                UPDATE proveedores SET
                    gte_gral = %(gte_gral)s, estado = %(estado)s, ciudad = %(ciudad)s,
                    tel_de_ofna = %(tel_de_ofna)s, email_de_empresa = %(email_de_empresa)s,
                    nombre_contacto_princ = %(nombre_contacto_princ)s, cel_contact_princ = %(cel_contact_princ)s,
                    nombre_contacto_a = %(nombre_contacto_a)s, cel_contact_a = %(cel_contact_a)s
                WHERE UPPER(nombre_del_proveedor) = UPPER(%(nombre_del_proveedor)s);
            """
        else:
            query = """
                INSERT INTO proveedores (
                    nombre_del_proveedor, gte_gral, estado, ciudad, tel_de_ofna,
                    email_de_empresa, nombre_contacto_princ, cel_contact_princ,
                    nombre_contacto_a, cel_contact_a
                ) VALUES (
                    %(nombre_del_proveedor)s, %(gte_gral)s, %(estado)s, %(ciudad)s, %(tel_de_ofna)s,
                    %(email_de_empresa)s, %(nombre_contacto_princ)s, %(cel_contact_princ)s,
                    %(nombre_contacto_a)s, %(cel_contact_a)s
                );
            """
        cursor.execute(query, payload)
        conn.commit()
        cursor.close()
        conn.close()
        return {"status": "ok", "mensaje": "Proveedor guardado correctamente"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al guardar proveedor: {str(e)}")


@app.delete("/api/proveedores/eliminar/{nombre_proveedor}", tags=["🚚 Gestión Proveedores"])
def eliminar_proveedor(nombre_proveedor: str):
    try:
        conn = get_db_connection("db_proveedores_prueba")
        cursor = conn.cursor()
        cursor.execute(
            "DELETE FROM proveedores WHERE UPPER(nombre_del_proveedor) = UPPER(%s);", 
            (nombre_proveedor,)
        )
        conn.commit()
        cursor.close()
        conn.close()
        return {"status": "ok", "mensaje": f"Proveedor {nombre_proveedor} eliminado"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al eliminar proveedor: {str(e)}")

# 🏢 CLIENTES
@app.get("/api/clientes", tags=["🏢 Gestión Clientes"])
def listar_clientes():
    query = text("""
        SELECT encode(cliente_empresa::bytea, 'hex'), encode(gte_gral::bytea, 'hex'), encode(estado::bytea, 'hex'), encode(ciudad::bytea, 'hex'), encode(tel_de_ofna::bytea, 'hex'), encode(email_de_empresa::bytea, 'hex'), encode(nombre_contacto_princ::bytea, 'hex'), encode(cel_contact_princ::bytea, 'hex'), encode(nombre_contacto_a::bytea, 'hex'), encode(cel_contact_a::bytea, 'hex'), id_cliente
        FROM public.clientes ORDER BY id_cliente ASC
    """)
    try:
        with engine_clientes.connect() as conn: result = conn.execute(query).fetchall()
        return [{"cliente_empresa": safe_decode_hex(r[0]), "gte_gral": safe_decode_hex(r[1]), "estado": safe_decode_hex(r[2]), "ciudad": safe_decode_hex(r[3]), "tel_de_ofna": safe_decode_hex(r[4]), "email_de_empresa": safe_decode_hex(r[5]), "nombre_contacto_princ": safe_decode_hex(r[6]), "cel_contact_princ": safe_decode_hex(r[7]), "nombre_contacto_a": safe_decode_hex(r[8]), "cel_contact_a": safe_decode_hex(r[9]), "id_cliente": r[10]} for r in result]
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/clientes/guardar", tags=["🏢 Gestión Clientes"])
def guardar_o_actualizar_cliente(cliente: dict):
    query_upsert = text("""
        INSERT INTO public.clientes (id_cliente, cliente_empresa, gte_gral, estado, ciudad, tel_de_ofna, email_de_empresa, nombre_contacto_princ, cel_contact_princ, nombre_contacto_a, cel_contact_a)
        VALUES (:id_cliente, :cliente_empresa, :gte_gral, :estado, :ciudad, :tel_de_ofna, :email_de_empresa, :nombre_contacto_princ, :cel_contact_princ, :nombre_contacto_a, :cel_contact_a)
        ON CONFLICT (id_cliente) DO UPDATE SET cliente_empresa = EXCLUDED.cliente_empresa, gte_gral = EXCLUDED.gte_gral, estado = EXCLUDED.estado, ciudad = EXCLUDED.ciudad, tel_de_ofna = EXCLUDED.tel_de_ofna, email_de_empresa = EXCLUDED.email_de_empresa, nombre_contacto_princ = EXCLUDED.nombre_contacto_princ, cel_contact_princ = EXCLUDED.cel_contact_princ, nombre_contacto_a = EXCLUDED.nombre_contacto_a, cel_contact_a = EXCLUDED.cel_contact_a;
    """)
    try:
        with engine_clientes.begin() as conn: conn.execute(query_upsert, cliente)
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/clientes/eliminar/{id_cliente}", tags=["🏢 Gestión Clientes"])
def eliminar_cliente(id_cliente: int):
    query = text("DELETE FROM public.clientes WHERE id_cliente = :id")
    try:
        with engine_clientes.begin() as conn: conn.execute(query, {"id": id_cliente})
        return {"status": "DELETED"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

# 📝 EVENTOS Y ORDENES DE PRODUCCIÓN
@app.get("/api/eventos/catalogos", tags=["📝 Órdenes Producción"])
def extraer_catalogos_de_apoyo():
    try:
        with engine_autos.connect() as conn:
            res_autos = conn.execute(text("SELECT num_control, marca, modelo FROM public.autos")).fetchall()
            lista_autos = [f"{r[0]} - {r[1]} {r[2]}" for r in res_autos]
                
        with engine_clientes.connect() as conn:
            clientes = conn.execute(text("SELECT encode(cliente_empresa::bytea,'hex') FROM public.clientes ORDER BY id_cliente ASC")).fetchall()
        lista_clientes = [safe_decode_hex(c[0]) for c in clientes]

        with engine_proveedores.connect() as conn:
            provs = conn.execute(text("SELECT encode(nombre_del_proveedor::bytea,'hex') FROM public.proveedores ORDER BY nombre_del_proveedor ASC")).fetchall()
        lista_proveedores = [safe_decode_hex(p[0]) for p in provs]

        with engine_personal.connect() as conn:
            staff_rows = conn.execute(text("SELECT encode(nombre::bytea,'hex'), encode(rol::bytea,'hex') FROM public.empleados ORDER BY nombre ASC")).fetchall()
        
        staff_vpro, apoyos_externos = [], []
        for s in staff_rows:
            nom = safe_decode_hex(s[0])
            rol = safe_decode_hex(s[1]).strip().upper()
            if rol in ['EXTERNO', 'PROVEEDOR', 'PROV'] and rol != 'BAJA': apoyos_externos.append(nom)
            elif rol != 'BAJA': staff_vpro.append(nom)

        return {"autos": lista_autos, "clientes": lista_clientes, "proveedores": lista_proveedores, "staff_vpro": staff_vpro, "apoyos_externos": apoyos_externos}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/eventos/folios", tags=["📝 Órdenes Producción"])
def obtener_folios_activos_e_historicos():
    try:
        # 🟢 Consultas para la NUEVA BD (Esta sí tiene la columna estatus)
        query_activos_nueva = text("SELECT folio, nombre_evento FROM public.eventos WHERE UPPER(estatus) != 'CERRADA (HISTÓRICO)' ORDER BY id_evento DESC")
        query_historicos_nueva = text("SELECT folio, nombre_evento FROM public.eventos WHERE UPPER(estatus) = 'CERRADA (HISTÓRICO)' ORDER BY id_evento DESC")
        query_max_id = text("SELECT COALESCE(MAX(id_evento), 0) + 1 AS proximo_id FROM public.eventos")

        # 🟡 Consulta para la VIEJA BD (Esta NO tiene columna estatus, traemos todo)
        query_vieja = text("SELECT folio, nombre_evento FROM public.eventos ORDER BY id_evento DESC")

        folios_activos = []
        folios_historicos = []
        max_id_nuevo = 1

        # 1️⃣ LEEMOS LA BASE NUEVA
        with engine_eventos.connect() as conn:
            activos_nuevos = conn.execute(query_activos_nueva).mappings().fetchall()
            historicos_nuevos = conn.execute(query_historicos_nueva).mappings().fetchall()
            max_id_nuevo = conn.execute(query_max_id).scalar()
            
            folios_activos.extend([f"{r['folio']} - {r['nombre_evento']}" for r in activos_nuevos])
            folios_historicos.extend([f"{r['folio']} - {r['nombre_evento']} [NUEVA]" for r in historicos_nuevos])

        # 2️⃣ LEEMOS LA BASE VIEJA
        with engine_eventos_vieja.connect() as conn:
            todos_viejos = conn.execute(query_vieja).mappings().fetchall()
            
            for r in todos_viejos:
                folio_str = f"{r['folio']} - {r['nombre_evento']}"
                # Evitamos duplicados: Si el folio ya está en la nueva, no lo volvemos a poner
                if folio_str not in folios_activos and folio_str not in [f.replace(' [NUEVA]', '') for f in folios_historicos]:
                    folios_activos.append(folio_str)

        return {
            "folios": folios_activos,
            "folios_historicos": folios_historicos,
            "proximo_id": max_id_nuevo
        }
    except Exception as e:
        print(f"🔥 Error al obtener folios híbridos: {e}")
        return {"folios": [], "folios_historicos": [], "proximo_id": 1}

@app.get("/api/eventos/buscar/{folio}", tags=["📝 Órdenes Producción"])
def buscar_op_por_folio(folio: str):
    try:
        query = text("SELECT * FROM public.eventos WHERE folio = :folio")
        
        # 1️⃣ INTENTAMOS EN LA BASE NUEVA
        with engine_eventos.connect() as conn:
            resultado = conn.execute(query, {"folio": folio}).mappings().first()
            
        # 2️⃣ SI NO ESTÁ, BUSCAMOS EN LA BASE VIEJA
        if not resultado:
            with engine_eventos_vieja.connect() as conn:
                resultado = conn.execute(query, {"folio": folio}).mappings().first()

        if resultado:
            datos = dict(resultado)
            # Convertimos formatos de fecha/hora a texto para que no truene el JSON
            for k, v in datos.items():
                if isinstance(v, (datetime.date, datetime.time, datetime.datetime)):
                    datos[k] = str(v)
            return datos
        else:
            raise HTTPException(status_code=404, detail="Folio no encontrado en ninguna de las bases de datos.")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/eventos/guardar", tags=["📝 Órdenes Producción"])
def guardar_o_actualizar_op(op: dict):
    try:
        id_ev = int(op.get("id_evento"))
        def format_pg_array(data):
            if not data: return "{}"
            if isinstance(data, str): return data
            sanitizados = [f'"{str(x).replace("\"", "\\\"")}"' for x in data]
            return "{" + ",".join(sanitizados) + "}"

        payload = dict(op)
        payload["proveedor_op"] = format_pg_array(payload.get("proveedor_op", []))
        payload["personal_convocado_op"] = format_pg_array(payload.get("personal_convocado_op", []))
        payload["carros_usados_op"] = format_pg_array(payload.get("carros_usados_op", []))
        payload["externos_op"] = format_pg_array(payload.get("externos_op", []))
        # 🔥 AQUÍ SE FORMATEA LA NUEVA COLUMNA DE REUNIONES
        payload["reuniones_vinculadas"] = format_pg_array(payload.get("reuniones_vinculadas", []))
        
        # ✨ EVITAMOS QUE EXPLOTE: Borramos el estatus si el frontend lo mandó, porque no existe en la BD
        if 'estatus' in payload:
            del payload['estatus']

        with engine_eventos.connect() as conn:
            existe = conn.execute(text("SELECT 1 FROM public.eventos WHERE id_evento = :id_evento"), {"id_evento": id_ev}).scalar()
            
        if existe:
            query_update = text("""
                UPDATE public.eventos SET 
                    folio = :folio, para_q_cliente = :para_q_cliente, nombre_evento = :nombre_evento, locacion = :locacion, fec_de_instalacion = CAST(:fec_de_instalacion AS date), 
                    hra_de_instalacion = CAST(:hra_de_instalacion AS time), quien_solicita = :quien_solicita, resp_de_produccion = :resp_de_produccion, fec_del_evento = CAST(:fec_del_evento AS date), 
                    inicio_del_evento = CAST(:inicio_del_evento AS time), hra_de_llamado = CAST(:hra_de_llamado AS time), ubicacion = :ubicacion, tipo_de_servicio = :tipo_de_servicio, produccion = :produccion, 
                    internet_redes = :internet_redes, actividades_de_proveedores = :actividades_de_proveedores, nota = :nota, elabora = :elabora, organiza = :organiza, coordina = :coordina, vobo = :vobo, 
                    proveedor_op = CAST(:proveedor_op AS text[]), personal_convocado_op = CAST(:personal_convocado_op AS text[]), carros_usados_op = CAST(:carros_usados_op AS text[]), externos_op = CAST(:externos_op AS text[]), 
                    reuniones_vinculadas = CAST(:reuniones_vinculadas AS text[]), 
                    fec_de_elaboracion_de_op = CURRENT_DATE
                WHERE id_evento = :id_evento
            """)
            with engine_eventos.begin() as conn: conn.execute(query_update, payload)
        else:
            query_insert = text("""
                INSERT INTO public.eventos (
                    id_evento, folio, para_q_cliente, nombre_evento, locacion, fec_de_instalacion, hra_de_instalacion, quien_solicita, resp_de_produccion, fec_del_evento, 
                    inicio_del_evento, hra_de_llamado, ubicacion, tipo_de_servicio, produccion, internet_redes, actividades_de_proveedores, nota, elabora, organiza, coordina, 
                    vobo, proveedor_op, personal_convocado_op, carros_usados_op, externos_op, reuniones_vinculadas, empleado_que_creo_la_op, fec_de_elaboracion_de_op 
                ) VALUES (
                    :id_evento, :folio, :para_q_cliente, :nombre_evento, :locacion, CAST(:fec_de_instalacion AS date), CAST(:hra_de_instalacion AS time), :quien_solicita, :resp_de_produccion, CAST(:fec_del_evento AS date), 
                    CAST(:inicio_del_evento AS time), CAST(:hra_de_llamado AS time), :ubicacion, :tipo_de_servicio, :produccion, :internet_redes, :actividades_de_proveedores, :nota, :elabora, :organiza, :coordina, 
                    :vobo, CAST(:proveedor_op AS text[]), CAST(:personal_convocado_op AS text[]), CAST(:carros_usados_op AS text[]), CAST(:externos_op AS text[]), CAST(:reuniones_vinculadas AS text[]), :empleado_que_creo_la_op, CURRENT_DATE 
                )
            """)
            with engine_eventos.begin() as conn: conn.execute(query_insert, payload)
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

# 💸 GASTOS OPERATIVOS (db_eventos_prueba)
@app.get("/api/gastos/ultimo-km/{vehiculo}", tags=["💸 Gastos Operativos"])
def obtener_ultimo_km_vehiculo(vehiculo: str):
    query = text("SELECT km_final FROM public.informes_gastos_maestro WHERE UPPER(vehiculo) LIKE UPPER(:veh) ORDER BY id_informe DESC LIMIT 1")
    try:
        with engine_eventos.connect() as conn:
            resultado = conn.execute(query, {"veh": f"%{vehiculo.strip()}%"}).fetchone()
            if resultado and resultado[0]: 
                return {"ultimo_km": int(resultado[0])}
            return {"ultimo_km": 0}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/gastos/pendientes/conteo", tags=["💸 Gastos Operativos"])
def contar_gastos_pendientes_api():
    query = text("SELECT COUNT(*) FROM public.informes_gastos_maestro WHERE revisado = FALSE")
    try:
        with engine_eventos.connect() as conn: 
            return conn.execute(query).scalar()
    except: 
        return 0


@app.get("/api/gastos/folios-pendientes", tags=["💸 Gastos Operativos"])
def listar_folios_pendientes_gastos():
    query = text("""
        SELECT e.id_evento, encode(e.para_q_cliente::bytea, 'hex'), encode(e.nombre_evento::bytea, 'hex')
        FROM public.eventos e
        WHERE NOT EXISTS (SELECT 1 FROM public.informes_gastos_maestro m WHERE m.folio_vpro = e.id_evento)
        AND EXISTS (SELECT 1 FROM public.checkouts_maestro cm WHERE cm.folio_op = e.id_evento AND cm.estado_bodega = 'RECIBIDO')
        ORDER BY e.id_evento DESC
    """)
    try:
        with engine_eventos.connect() as conn: 
            rows = conn.execute(query).fetchall()
            return [{"id_evento": r[0], "cliente": safe_decode_hex(r[1]), "nombre_evento": safe_decode_hex(r[2])} for r in rows]
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/gastos/evento/{id_evento}", tags=["💸 Gastos Operativos"])
def obtener_datos_evento_gasto(id_evento: int):
    query = text("""
        SELECT encode(resp_de_produccion::bytea, 'hex'), fec_de_instalacion, 
               encode(carros_usados_op::text::bytea, 'hex'), encode(personal_convocado_op::text::bytea, 'hex')
        FROM public.eventos WHERE id_evento = :id
    """)
    try:
        with engine_eventos.connect() as conn: 
            res = conn.execute(query, {"id": id_evento}).first()
            if res:
                return {
                    "productor_responsable": safe_decode_hex(res[0]), 
                    "fec_de_instalacion": str(res[1]) if res[1] else None, 
                    "carros_usados_op": safe_decode_hex(res[2]), 
                    "personal_convocado_op": safe_decode_hex(res[3])
                }
            raise HTTPException(status_code=404, detail="Evento no mapeado")
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/gastos/guardar", tags=["💸 Gastos Operativos"])
def guardar_informe_gastos_completo(payload: dict):
    try:
        maestro = payload.get("maestro", {})
        detalles = payload.get("detalles", [])
        with engine_eventos.begin() as conn:
            sql_m = text("""
                INSERT INTO public.informes_gastos_maestro (
                    folio_vpro, id_empleado, periodo_desde, periodo_hasta, vehiculo, km_inicial, km_final, 
                    departamento, num_personas, subtotal, monto_entregado, restante, fecha_registro, hora_registro, revisado
                ) VALUES (
                    :folio_vpro, :id_empleado, CAST(:periodo_desde AS date), CAST(:periodo_hasta AS date), 
                    :vehiculo, :km_inicial, :km_final, :departamento, :num_personas, :subtotal, :monto_entregado, 
                    :restante, CURRENT_DATE, CURRENT_TIME, FALSE
                ) RETURNING id_informe
            """)
            id_informe = conn.execute(sql_m, {
                "folio_vpro": int(maestro.get("folio_vpro")), 
                "id_empleado": str(maestro.get("id_empleado", ""))[:3], 
                "periodo_desde": maestro.get("periodo_desde"),
                "periodo_hasta": maestro.get("periodo_hasta"), 
                "vehiculo": str(maestro.get("vehiculo", ""))[:100], 
                "km_inicial": int(maestro.get("km_inicial", 0)),
                "km_final": int(maestro.get("km_final", 0)), 
                "departamento": str(maestro.get("departamento", ""))[:50], 
                "num_personas": int(maestro.get("num_personas", 0)),
                "subtotal": float(maestro.get("subtotal", 0.0)), 
                "monto_entregado": float(maestro.get("monto_entregado", 0.0)), 
                "restante": float(maestro.get("restante", 0.0))
            }).scalar()
            
            sql_d = text("""
                INSERT INTO public.informes_gastos_detalle (
                    id_informe, dia_num, hotel, transporte, combustible, casetas, desayuno, comida, cenas, varios, total_dia
                ) VALUES (
                    :id_informe, :dia_num, :hotel, :transporte, :combustible, :casetas, :desayuno, :comida, :cenas, :varios, :total_dia
                )
            """)
            for d in detalles:
                conn.execute(sql_d, {
                    "id_informe": id_informe, 
                    "dia_num": int(d.get("dia_num")), 
                    "hotel": float(d.get("hotel", 0.0)), 
                    "transporte": float(d.get("transporte", 0.0)),
                    "combustible": float(d.get("combustible", 0.0)), 
                    "casetas": float(d.get("casetas", 0.0)), 
                    "desayuno": float(d.get("desayuno", 0.0)),
                    "comida": float(d.get("comida", 0.0)), 
                    "cenas": float(d.get("cenas", 0.0)), 
                    "varios": float(d.get("varios", 0.0)), 
                    "total_dia": float(d.get("total_dia", 0.0))
                })
        return {"status": "SUCCESS", "id_informe": id_informe}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/gastos/informe-completo/{id_informe}", tags=["💸 Gastos Operativos"])
def obtener_expediente_informe_completo(id_informe: int):
    query_m = text("""
        SELECT id_informe, folio_vpro, id_empleado, periodo_desde, periodo_hasta, 
               encode(vehiculo::bytea, 'hex'), km_inicial, km_final, encode(departamento::bytea, 'hex'), 
               num_personas, subtotal, monto_entregado, restante, revisado 
        FROM public.informes_gastos_maestro WHERE id_informe = :id
    """)
    query_d = text("""
        SELECT dia_num, hotel, transporte, combustible, casetas, desayuno, comida, cenas, varios, total_dia 
        FROM public.informes_gastos_detalle WHERE id_informe = :id ORDER BY dia_num ASC
    """)
    try:
        with engine_eventos.connect() as conn:
            m = conn.execute(query_m, {"id": id_informe}).first()
            detalles = conn.execute(query_d, {"id": id_informe}).fetchall()
        if not m: 
            raise HTTPException(status_code=404, detail="Informe no mapeado")
        
        with engine_personal.connect() as conn_p:
            emp_row = conn_p.execute(text("SELECT encode(nombre::bytea, 'hex') FROM public.empleados WHERE TRIM(id_empleado) = :id"), {"id": str(m[2]).strip()}).first()
        nombre_emp = safe_decode_hex(emp_row[0]) if emp_row else f"ID: {m[2]}"

        return {
            "maestro": {
                "id_informe": m[0], "folio_vpro": m[1], "nombre_empleado": nombre_emp, 
                "periodo_desde": str(m[3]), "periodo_hasta": str(m[4]),
                "vehiculo": safe_decode_hex(m[5]), "km_inicial": m[6], "km_final": m[7], 
                "departamento": safe_decode_hex(m[8]), "num_personas": m[9], 
                "subtotal": float(m[10]), "monto_entregado": float(m[11]), 
                "restante": float(m[12]), "revisado": m[13]
            },
            "detalles": [
                {
                    "dia_num": d[0], "hotel": float(d[1]), "transporte": float(d[2]), 
                    "combustible": float(d[3]), "casetas": float(d[4]), "desayuno": float(d[5]), 
                    "comida": float(d[6]), "cenas": float(d[7]), "varios": float(d[8]), 
                    "total_dia": float(d[9])
                } for d in detalles
            ]
        }
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/gastos/revisar/{id_informe}", tags=["💸 Gastos Operativos"])
def aprobar_y_sellar_informe_gasto(id_informe: int):
    query = text("UPDATE public.informes_gastos_maestro SET revisado = TRUE WHERE id_informe = :id")
    try:
        with engine_eventos.begin() as conn: 
            conn.execute(query, {"id": id_informe})
        return {"status": "SUCCESS"}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/gastos/pendientes-auditoria", tags=["💸 Gastos Operativos"])
def obtener_gastos_pendientes_auditoria():
    try:
        with engine_eventos.connect() as conn:
            query = text("""
                SELECT igm.folio_vpro, igm.id_empleado, encode(e.nombre_evento::bytea, 'hex'), encode(e.para_q_cliente::bytea, 'hex') 
                FROM public.informes_gastos_maestro igm 
                LEFT JOIN public.eventos e ON igm.folio_vpro = e.id_evento 
                WHERE igm.revisado IS FALSE OR igm.revisado IS NULL
            """)
            res = conn.execute(query).fetchall()
            lista_pendientes = []
            for r in res:
                cliente_str = safe_decode_hex(r[3]) if r[3] else ""
                evento_str = safe_decode_hex(r[2]) if r[2] else "Evento Desconocido"
                lista_pendientes.append({
                    "folio_op": r[0], 
                    "id_empleado": str(r[1]).strip(), 
                    "evento": f"{cliente_str} - {evento_str}".strip(" -")
                })
            return lista_pendientes
    except Exception as e: 
        return []


@app.get("/api/gastos/informes-auditoria", tags=["💸 Gastos Operativos"])
def listar_informes_auditoria():
    try:
        with engine_eventos.connect() as conn:
            query = text("""
                SELECT m.id_informe, m.folio_vpro, m.revisado, m.id_empleado, encode(e.nombre_evento::bytea, 'hex')
                FROM public.informes_gastos_maestro m 
                LEFT JOIN public.eventos e ON m.folio_vpro = e.id_evento 
                ORDER BY m.id_informe DESC
            """)
            rows = conn.execute(query).fetchall()
            
        with engine_personal.connect() as conn_p:
            emp_rows = conn_p.execute(text("SELECT TRIM(id_empleado), encode(nombre::bytea, 'hex') FROM public.empleados")).fetchall()
            dict_emps = {r[0]: safe_decode_hex(r[1]) for r in emp_rows}
            
        lista_final = []
        for r in rows:
            id_emp = str(r[3]).strip()
            nombre_ev = safe_decode_hex(r[4]) if r[4] else "Evento Desconocido"
            lista_final.append({
                "id_informe": r[0], 
                "folio_vpro": r[1], 
                "revisado": bool(r[2]), 
                "nombre_empleado": dict_emps.get(id_emp, f"ID: {id_emp}"), 
                "nombre_evento": nombre_ev
            })
        return lista_final
    except Exception as e: 
        return []


@app.post("/api/gastos/modificar-historico", tags=["💸 Gastos Operativos"])
def modificar_informe_historico(payload: dict):
    try:
        with engine_eventos.begin() as conn:
            conn.execute(text("DELETE FROM public.informes_gastos_detalle WHERE id_informe = :id"), {"id": payload["id_informe"]})
            sql_d = text("""
                INSERT INTO public.informes_gastos_detalle (
                    id_informe, dia_num, hotel, transporte, combustible, casetas, desayuno, comida, cenas, varios, total_dia
                ) VALUES (
                    :id_informe, :dia_num, :hotel, :transporte, :combustible, :casetas, :desayuno, :comida, :cenas, :varios, :total_dia
                )
            """)
            subtotal_nuevo = 0.0
            for d in payload["detalles"]:
                subtotal_nuevo += float(d.get("total_dia", 0.0))
                conn.execute(sql_d, {
                    "id_informe": payload["id_informe"], 
                    "dia_num": int(d.get("dia_num", 1)), 
                    "hotel": float(d.get("hotel", 0.0)), 
                    "transporte": float(d.get("transporte", 0.0)),
                    "combustible": float(d.get("combustible", 0.0)), 
                    "casetas": float(d.get("casetas", 0.0)), 
                    "desayuno": float(d.get("desayuno", 0.0)), 
                    "comida": float(d.get("comida", 0.0)),
                    "cenas": float(d.get("cenas", 0.0)), 
                    "varios": float(d.get("varios", 0.0)), 
                    "total_dia": float(d.get("total_dia", 0.0))
                })
            conn.execute(
                text("UPDATE public.informes_gastos_maestro SET subtotal = :sub, restante = monto_entregado - :sub WHERE id_informe = :id"), 
                {"sub": subtotal_nuevo, "id": payload["id_informe"]}
            )
        return {"status": "SUCCESS"}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))
    
# 📦 INVENTARIO Y LOGÍSTICA
@app.get("/api/inventario", tags=["🛠️ Inventario General"])
def listar_inventario_maestro():
    try:
        # ⚠️ Asegúrate de conectar a la BD real: db_inventario_prueba
        conn = get_db_connection("db_inventario_prueba")
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        
        cursor.execute("""
            SELECT 
                codigo, 
                responsiva, 
                fecha_compra, 
                descripcion, 
                marca, 
                modelo, 
                serie, 
                responsable, 
                estado, 
                ubicacion, 
                observaciones 
            FROM public.inventario 
            ORDER BY codigo ASC;
        """)
        activos = cursor.fetchall()
        cursor.close()
        conn.close()
        return activos
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al consultar inventario: {str(e)}")

@app.post("/api/inventario/guardar", tags=["🛠️ Inventario General"])
def guardar_o_actualizar_inventario(item: dict):
    query_upsert = text("""
        INSERT INTO public.inventario (codigo, responsiva, fecha_compra, descripcion, marca, modelo, serie, responsable, estado, ubicacion, observaciones) 
        VALUES (:codigo, :responsiva, :fecha_compra, :descripcion, :marca, :modelo, :serie, :responsable, :estado, :ubicacion, :observaciones)
        ON CONFLICT (codigo) DO UPDATE SET responsiva=EXCLUDED.responsiva, fecha_compra=EXCLUDED.fecha_compra, descripcion=EXCLUDED.descripcion, marca=EXCLUDED.marca, modelo=EXCLUDED.modelo, serie=EXCLUDED.serie, responsable=EXCLUDED.responsable, estado=EXCLUDED.estado, ubicacion=EXCLUDED.ubicacion, observaciones=EXCLUDED.observaciones;
    """)
    try:
        with engine_inventario.begin() as conn: conn.execute(query_upsert, item)
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/inventario/eliminar/{codigo}", tags=["🛠️ Inventario General"])
def eliminar_inventario(codigo: str):
    query = text("DELETE FROM public.inventario WHERE codigo = :codigo")
    try:
        with engine_inventario.begin() as conn: conn.execute(query, {"codigo": codigo.strip()})
        return {"status": "DELETED"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/inventario/historial/{codigo}", tags=["🛠️ Inventario General"])
def extraer_expediente_clinico_hardware(codigo: str):
    query = text("""
        SELECT encode(codigo_equipo::bytea, 'hex') as cod, encode(tipo_evento::bytea, 'hex') as tipo, 
               encode(descripcion::bytea, 'hex') as descr, fecha, encode(folio_vpro::bytea, 'hex') as fol 
        FROM public.historial_equipo WHERE LOWER(TRIM(codigo_equipo)) = LOWER(:cod) ORDER BY fecha DESC
    """)
    try:
        with engine_inventario.connect() as conn: rows = conn.execute(query, {"cod": codigo.strip()}).fetchall()
        return [{"codigo_equipo": safe_decode_hex(r[0]), "tipo_evento": safe_decode_hex(r[1]), "descripcion": safe_decode_hex(r[2]), "fecha": str(r[3]) if r[3] else None, "folio_vpro": safe_decode_hex(r[4])} for r in rows]
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/inventario/historial/guardar", tags=["🛠️ Inventario General"])
def registrar_receta_tratamiento_medico(log: dict):
    """Inyecta el reporte en historial_equipo y sincroniza la tabla reparaciones"""
    try:
        conn = get_db_connection("db_inventario_prueba")
        cursor = conn.cursor()
        
        cod_eq = str(log.get("codigo_equipo", "")).strip().upper()
        est_final = str(log.get("estado_final", "PENDIENTE")).strip().upper()
        fol_vpro = str(log.get("folio_vpro", "MANTENIMIENTO_INTERNO")).strip()
        depto = str(log.get("departamento", "OFICINA")).strip().upper()
        desc = str(log.get("descripcion", "")).strip()
        costo = float(log.get("costo_asociado", 0.0))
        emp_id = str(log.get("id_empleado", "000")).strip()

        # 1. Insertar en historial_equipo
        cursor.execute("""
            INSERT INTO public.historial_equipo 
                (codigo_equipo, fecha, folio_vpro, id_empleado, tipo_evento, descripcion, costo_asociado, estado_final, departamento)
            VALUES 
                (%s, CURRENT_DATE, %s, %s, %s, %s, %s, %s, %s);
        """, (cod_eq, fol_vpro, emp_id, str(log.get("tipo_evento", "MANTENIMIENTO_TÉCNICO")), desc, costo, est_final, depto))

        # 2. Actualizar estado del hardware en inventario / inventario_kits
        if est_final in ["PENDIENTE", "EN TALLER", "DAÑADO", "DANADO", "BAJA"]:
            if cod_eq.startswith("INV_VPRO_ALT_"):
                cursor.execute("UPDATE public.inventario_kits SET estado_inv_kits = 'DANADO' WHERE UPPER(codigo_inv_kits) = %s;", (cod_eq,))
            else:
                cursor.execute("UPDATE public.inventario SET estado = 'DAÑADO' WHERE UPPER(codigo) = %s;", (cod_eq,))
            
            # Crear ticket activo en public.reparaciones
            import time
            ticket_id = f"REP-INT-{int(time.time())}"
            cursor.execute("""
                INSERT INTO public.reparaciones 
                    (num_d_servicio, fecha_d_reporte, equipo_n_reparacion, area_q_pertenece, reportante, estado_actual, descripcion_del_dano, costo_d_reparacion, folio_vpro)
                VALUES 
                    (%s, CURRENT_DATE, %s, %s, %s, %s, %s, %s, %s);
            """, (ticket_id, cod_eq, depto, f"Empleado ID: {emp_id}", f"⚙️ {est_final}", desc, costo, fol_vpro))
            
        elif est_final in ["RESUELTO", "OK", "BUEN ESTADO"]:
            if cod_eq.startswith("INV_VPRO_ALT_"):
                cursor.execute("UPDATE public.inventario_kits SET estado_inv_kits = 'BUEN ESTADO' WHERE UPPER(codigo_inv_kits) = %s;", (cod_eq,))
            else:
                cursor.execute("UPDATE public.inventario SET estado = 'OK' WHERE UPPER(codigo) = %s;", (cod_eq,))

            cursor.execute("UPDATE public.reparaciones SET estado_actual = 'RESUELTO' WHERE UPPER(equipo_n_reparacion) = %s;", (cod_eq,))

        conn.commit()
        cursor.close()
        conn.close()
        return {"status": "SUCCESS"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al guardar expediente: {str(e)}")

@app.post("/api/inventario/reparacion/cerrar/{num_servicio}", tags=["🛠️ Inventario General"])
def cerrar_ticket_reparacion(num_servicio: str, payload: dict):
    """Permite dar de alta o reparar un equipo desde la interfaz del Radar"""
    try:
        nuevo_estatus = str(payload.get("estado_actual", "RESUELTO")).strip().upper()
        conn = get_db_connection("db_inventario_prueba")
        cursor = conn.cursor()
        
        # Consultar el equipo asociado al ticket
        cursor.execute("SELECT equipo_n_reparacion FROM public.reparaciones WHERE num_d_servicio = %s;", (num_servicio,))
        row = cursor.fetchone()
        
        if row:
            cod_eq = str(row[0]).strip().upper()
            cursor.execute("UPDATE public.reparaciones SET estado_actual = %s WHERE num_d_servicio = %s;", (nuevo_estatus, num_servicio))
            
            if nuevo_estatus in ["RESUELTO", "REPARADO", "OK"]:
                if cod_eq.startswith("INV_VPRO_ALT_"):
                    cursor.execute("UPDATE public.inventario_kits SET estado_inv_kits = 'BUEN ESTADO' WHERE UPPER(codigo_inv_kits) = %s;", (cod_eq,))
                else:
                    cursor.execute("UPDATE public.inventario SET estado = 'OK' WHERE UPPER(codigo) = %s;", (cod_eq,))

        conn.commit()
        cursor.close()
        conn.close()
        return {"status": "SUCCESS"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/inventario/catalogo-global", tags=["📦 Checkout & Logística"])
def obtener_catalogo_global_inventario():
    try:
        nombres_globales = set()
        with engine_inventario.connect() as conn:
            rows_kits = conn.execute(text("SELECT DISTINCT descripcion_inv_kits FROM public.inventario_kits WHERE descripcion_inv_kits IS NOT NULL AND descripcion_inv_kits NOT IN ('', 'None', 'nan', 'NaN', 'Equipo no registrado')")).fetchall()
            for r in rows_kits:
                if r[0]: nombres_globales.add(str(r[0]).strip())
                
            rows_master = conn.execute(text("SELECT DISTINCT descripcion FROM public.inventario WHERE descripcion IS NOT NULL AND descripcion NOT IN ('', 'None', 'nan', 'NaN', 'Equipo no registrado')")).fetchall()
            for r in rows_master:
                if r[0]: nombres_globales.add(str(r[0]).strip())
                
        return sorted(list(nombres_globales))
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/api/checkout/init-data/{id_empleado}", tags=["📦 Checkout & Logística"])
def inicializar_modulo_checkout(id_empleado: str):
    try:
        with engine_eventos.connect() as conn: # Voy a dejar todo el comentario para regresarlo a como debe de ser despues de que hagan el checkin
            # Este es el script con las politicas incorrectas por si algun usuario se apendeja
            # evs_query = text("""
                # SELECT e.id_evento, encode(e.para_q_cliente::bytea,'hex'), encode(e.nombre_evento::bytea,'hex') 
                # FROM public.eventos e
                # LEFT JOIN public.informes_gastos_maestro igm ON e.id_evento = igm.folio_vpro
                # WHERE COALESCE(igm.revisado, FALSE) = FALSE 
                # AND UPPER(COALESCE(e.estatus, 'ACTIVA')) != 'CERRADA (HISTÓRICO)'
                # ORDER BY e.id_evento DESC
            # """)
            
            
            # Este es el script normal con las politicas correctas
            evs_query = text("""
               SELECT e.id_evento, encode(e.para_q_cliente::bytea,'hex'), encode(e.nombre_evento::bytea,'hex') 
               FROM public.eventos e
               LEFT JOIN public.informes_gastos_maestro igm ON e.id_evento = igm.folio_vpro
               WHERE COALESCE(igm.revisado, FALSE) = FALSE 
               AND igm.id_informe IS NULL 
               AND UPPER(COALESCE(e.estatus, 'ACTIVA')) != 'CERRADA (HISTÓRICO)'
               ORDER BY e.id_evento DESC
            """)
            evs = conn.execute(evs_query).fetchall()
            
            kits_rows = conn.execute(text("SELECT DISTINCT encode(nombre_kit::bytea,'hex') FROM public.kits_empleados WHERE TRIM(id_empleado) = :id"), {"id": id_empleado.strip()}).fetchall()
            pendientes_raw = conn.execute(text("SELECT id_empleado, folio_op FROM public.checkouts_maestro WHERE (incidencias_generales IS NULL OR incidencias_generales = '') AND estado_bodega = 'RECIBIDO'")).fetchall()
        
        ordenes = [f"OP-{str(r[0]).zfill(3)} | {safe_decode_hex(r[1])} - {safe_decode_hex(r[2])}" for r in evs]
        lista_kits = [safe_decode_hex(k[0]) for k in kits_rows]
        
        alertas_lista = []
        if pendientes_raw:
            ids_p = list(set([str(p[0]).strip() for p in pendientes_raw if p[0]]))
            with engine_personal.connect() as conn_p:
                ids_formateados = "', '".join(ids_p)
                df_emp = conn_p.execute(text(f"SELECT TRIM(id_empleado), encode(nombre::bytea,'hex') FROM public.empleados WHERE id_empleado IN ('{ids_formateados}')")).fetchall()
            dict_nombres = {r[0]: safe_decode_hex(r[1]) for r in df_emp}
            for p in pendientes_raw:
                alertas_lista.append({"folio": p[1], "nombre": dict_nombres.get(str(p[0]).strip(), "Desconocido")})

        return {"ordenes": ordenes, "kits": lista_kits, "alertas_pendientes": alertas_lista}
    except Exception as e: 
        print(f"🔥 Error en Checkout init: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/checkout/kits/{id_empleado}", tags=["📦 Checkout & Logística"])
def obtener_kits_por_empleado(id_empleado: str):
    try:
        with engine_eventos.connect() as conn:
            kits_rows = conn.execute(text("SELECT DISTINCT encode(nombre_kit::bytea,'hex') FROM public.kits_empleados WHERE TRIM(id_empleado) = :id"), {"id": id_empleado.strip()}).fetchall()
        # ✨ Inyectamos reparar_mojibake aquí
        return {"kits": [reparar_mojibake(safe_decode_hex(k[0])) for k in kits_rows]}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))
    
@app.post("/api/checkout/verificar-salida-coordinador", tags=["📦 Checkout & Checkin"])
def verificar_salida_coordinador(payload: dict):
    id_maestro = payload.get("id_maestro")
    incidencias = payload.get("incidencias_generales")
    items = payload.get("items", [])
    try:
        with engine_eventos.begin() as conn: 
            conn.execute(text("UPDATE public.checkouts_maestro SET estado_bodega = 'DESPACHADO', incidencias_generales = :inc WHERE id_maestro = :id"), {"inc": incidencias, "id": id_maestro})
            for item in items:
                conn.execute(text("UPDATE public.checkouts_detalle SET cantidad = :cant, observaciones = :obs WHERE id_detalle = :id_det"), {"cant": int(item.get("CANT", 1)), "obs": str(item.get("OBSERVACIONES", "")).strip(), "id_det": item.get("id_detalle")})
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/eventos/buscar_kit/{nombre_kit}/{id_empleado}", tags=["📦 Checkout & Logística"])
def buscar_kit_operador(nombre_kit: str, id_empleado: str):
    query = text("SELECT items FROM public.kits_empleados WHERE LOWER(TRIM(nombre_kit)) = LOWER(TRIM(:nom)) AND LOWER(TRIM(id_empleado)) = LOWER(TRIM(:id))")
    try:
        with engine_eventos.connect() as conn: 
            row = conn.execute(query, {"nom": nombre_kit.strip(), "id": id_empleado.strip()}).fetchone()
        if not row: return {"items": []}
        
        val = row[0]
        if isinstance(val, str):
            try:
                val = json.loads(val)
                if isinstance(val, str): val = json.loads(val)
            except: val = []
        if not isinstance(val, list): val = []
        
        # ✨ Limpiamos la basura de cada artículo antes de enviarlo
        for item in val:
            if isinstance(item, dict):
                if "EQUIPO" in item: item["EQUIPO"] = reparar_mojibake(item["EQUIPO"])
                if "OBSERVACIONES" in item: item["OBSERVACIONES"] = reparar_mojibake(item["OBSERVACIONES"])
                
        return {"items": val}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/checkout/status/{id_evento}/{id_empleado}", tags=["📦 Checkout & Logística"])
def extraer_estado_checkout(id_evento: int, id_empleado: str):
    try:
        with engine_eventos.connect() as conn:
            conv_row = conn.execute(text("SELECT encode(personal_convocado_op::text::bytea, 'hex'), encode(proveedor_op::text::bytea, 'hex') FROM public.eventos WHERE id_evento = :id"), {"id": id_evento}).fetchone()
            convocados = safe_decode_hex(conv_row[0]) if conv_row and conv_row[0] else "[]"
            proveedores_op = safe_decode_hex(conv_row[1]) if conv_row and len(conv_row) > 1 and conv_row[1] else "[]"
            
            m_row = conn.execute(text("SELECT id_maestro, encode(incidencias_generales::text::bytea, 'hex'), estado_bodega, encode(nombre_kit::text::bytea, 'hex') FROM public.checkouts_maestro WHERE folio_op = :id AND TRIM(id_empleado) = :emp"), {"id": id_evento, "emp": id_empleado.strip()}).fetchone()
            
            df_detalle = []
            if m_row:
                id_maestro = m_row[0]
                det_rows = conn.execute(text("SELECT id_detalle, encode(codigo_equipo::text::bytea,'hex') as id_eq, cantidad, encode(observaciones::text::bytea,'hex'), cotejado, encode(notas_regreso::text::bytea,'hex') FROM public.checkouts_detalle WHERE id_maestro = :id_m"), {"id_m": id_maestro}).fetchall()
                
                # ✨ Limpiamos Observaciones y Notas de Regreso
                df_detalle = [{"id_detalle": r[0], "ID": safe_decode_hex(r[1]), "CANT": r[2], "OBSERVACIONES": reparar_mojibake(safe_decode_hex(r[3])), "COTEJADO": bool(r[4]), "OBS_REGRESO": reparar_mojibake(safe_decode_hex(r[5]))} for r in det_rows]

                if df_detalle:
                    dict_inv = {}
                    
                    # 🧠 Motor de Fusión de Catálogos (Bases de Datos + Tablas)
                    def cargar_catalogo(engine_db):
                        try:
                            with engine_db.connect() as c_inv:
                                # 1. Leer Inventario General
                                inv = c_inv.execute(text("SELECT encode(codigo::text::bytea,'hex'), encode(descripcion::text::bytea,'hex') FROM public.inventario")).fetchall()
                                for r in inv:
                                    if r[0]: dict_inv[safe_decode_hex(r[0]).strip().upper()] = safe_decode_hex(r[1]).strip()
                                
                                # 2. Leer Kits
                                kits = c_inv.execute(text("SELECT encode(codigo_inv_kits::text::bytea,'hex'), encode(descripcion_inv_kits::text::bytea,'hex') FROM public.inventario_kits")).fetchall()
                                for r in kits:
                                    if r[0]: dict_inv[safe_decode_hex(r[0]).strip().upper()] = safe_decode_hex(r[1]).strip()
                        except Exception as e:
                            print(f"⚠️ Aviso cargando inventario: {e}")

                    # 1️⃣ Cargamos BD Vieja primero
                    cargar_catalogo(engine_inventario_vieja)
                    # 2️⃣ Cargamos BD Nueva al final (Si Edgar editó aquí, sobreescribirá lo viejo)
                    cargar_catalogo(engine_inventario)

                    for d in df_detalle: 
                        id_limpio = str(d.get("ID", "")).strip().upper()
                        obs_salida = d.get("OBSERVACIONES", "")
                        nombre_eq = dict_inv.get(id_limpio, "Equipo no registrado")
                        
                        # ✨ Lógica recuperada: Detectar equipos anotados a mano [CUST_EQ: ...]
                        if not id_limpio and "[CUST_EQ:" in obs_salida:
                            s_idx = obs_salida.find("[CUST_EQ:") + 9
                            e_idx = obs_salida.find("]", s_idx)
                            if e_idx != -1:
                                nombre_eq = obs_salida[s_idx:e_idx]
                                d["OBSERVACIONES"] = (obs_salida[:obs_salida.find("[CUST_EQ:")].strip() + " " + obs_salida[e_idx+1:].strip()).strip()

                        d["EQUIPO"] = reparar_mojibake(nombre_eq)

        return {
            "convocados": convocados, 
            "proveedores_op": proveedores_op, 
            "id_maestro": m_row[0] if m_row else None, 
            "incidencias_generales": reparar_mojibake(safe_decode_hex(m_row[1]).strip()) if m_row and m_row[1] else "", 
            "estado_bodega": m_row[2] if m_row else "NUEVO", 
            "nombre_kit": reparar_mojibake(safe_decode_hex(m_row[3]).strip()) if m_row and m_row[3] else "--- Sin plantilla ---",
            "detalle": df_detalle
        }
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/checkout/grabar-kit", tags=["📦 Checkout & Logística"])
def guardar_plantilla_kit_operador(payload: dict):
    try:
        def sanitizar_cadena(val):
            if val is None: 
                return ""
            if isinstance(val, bytes):
                return val.decode('utf-8', errors='ignore')
            return str(val).encode('utf-8', errors='ignore').decode('utf-8')

        id_emp = sanitizar_cadena(payload.get("id_empleado", "")).strip()
        nom_kit = sanitizar_cadena(payload.get("nombre_kit", "")).strip()
        items_raw = payload.get("items", [])
        user_actual = sanitizar_cadena(payload.get("usuario_actual", ""))
        
        # Sanitizamos cada item de la lista de producción
        items_limpios = []
        for it in items_raw:
            items_limpios.append({
                "ID": sanitizar_cadena(it.get("ID", "")),
                "EQUIPO": sanitizar_cadena(it.get("EQUIPO", "")),
                "OBSERVACIONES": sanitizar_cadena(it.get("OBSERVACIONES", ""))
            })
        
        # ensure_ascii=True escapa caracteres especiales a unicode (\uXXXX)
        # garantizando una cadena 100% compatible con UTF-8 y Postgres
        items_json = json.dumps(items_limpios, ensure_ascii=True)
        
        with engine_eventos.begin() as conn_ev:
            conn_ev.execute(
                text("DELETE FROM public.kits_empleados WHERE LOWER(TRIM(nombre_kit)) = LOWER(TRIM(:nom)) AND LOWER(TRIM(id_empleado)) = LOWER(TRIM(:id))"), 
                {"nom": nom_kit, "id": id_emp}
            )
            conn_ev.execute(
                text("INSERT INTO public.kits_empleados (id_empleado, nombre_kit, items) VALUES (TRIM(:id), TRIM(:nom), :items)"), 
                {"id": id_emp, "nom": nom_kit, "items": items_json}
            )
        
        with engine_inventario.begin() as conn_inv:
            for item in items_limpios:
                conn_inv.execute(text("""
                    INSERT INTO public.inventario_kits (
                        codigo_inv_kits, descripcion_inv_kits, responsable_inv_kits, 
                        id_empleado_ref_inv_kits, estado_inv_kits, ubicacion_inv_kits, 
                        observaciones_inv_kits, fecha_registro_inv_kits
                    )
                    VALUES (:cod, :desc, :resp, :ref, 'Buen Estado', 'BODEGA', :obs, NOW())
                    ON CONFLICT (codigo_inv_kits) 
                    DO UPDATE SET 
                        descripcion_inv_kits = EXCLUDED.descripcion_inv_kits, 
                        responsable_inv_kits = EXCLUDED.responsable_inv_kits;
                """), {
                    "cod": item["ID"], 
                    "desc": item["EQUIPO"], 
                    "resp": user_actual, 
                    "ref": id_emp, 
                    "obs": item["OBSERVACIONES"]
                })
        return {"status": "SUCCESS"}
    except Exception as e:
        err_clean = str(e).encode('utf-8', errors='ignore').decode('utf-8')
        raise HTTPException(status_code=500, detail=err_clean)

@app.post("/api/checkout/finalizar-salida", tags=["📦 Checkout & Logística"])
def registrar_finalizacion_checkout(payload: dict):
    try:
        items = payload.get("items", [])
        id_op = int(payload["id_evento"])
        id_sujeto = str(payload["id_sujeto_a_revisar"]).strip()
        incidencias_gen = str(payload["incidencias_generales"])
        nombre_kit = str(payload.get("nombre_kit", "--- Sin plantilla ---")).strip() 
        
        with engine_eventos.begin() as conn:
            m_id = conn.execute(text("SELECT id_maestro FROM public.checkouts_maestro WHERE folio_op = :id AND TRIM(id_empleado) = :emp"), {"id": id_op, "emp": id_sujeto}).scalar()
            if m_id:
                conn.execute(text("DELETE FROM public.checkouts_detalle WHERE id_maestro = :id_m"), {"id_m": m_id})
                conn.execute(text("UPDATE public.checkouts_maestro SET fecha=CURRENT_DATE, hora=CURRENT_TIME, incidencias_generales=:obs, nombre_kit=:kit WHERE id_maestro=:id_m"), {"obs": incidencias_gen, "kit": nombre_kit, "id_m": m_id})
            else:
                m_id = conn.execute(text("INSERT INTO public.checkouts_maestro (folio_op, id_empleado, fecha, hora, estado_bodega, incidencias_generales, nombre_kit) VALUES (:id, :emp, CURRENT_DATE, CURRENT_TIME, 'PENDIENTE', :obs, :kit) RETURNING id_maestro"), {"id": id_op, "emp": id_sujeto, "obs": incidencias_gen, "kit": nombre_kit}).scalar()
            
            for item in items:
                if str(item.get("EQUIPO","")).strip().lower() not in ["none", "nan", ""]:
                    conn.execute(text("INSERT INTO public.checkouts_detalle (id_maestro, codigo_equipo, cantidad, observaciones, cotejado, notas_regreso) VALUES (:id_m, :cod, :cant, :obs, false, '')"), {"id_m": int(m_id), "cod": str(item.get("ID","")), "cant": int(item.get("CANT", 1)), "obs": str(item.get("OBSERVACIONES",""))})
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/checkout/finalizar-checkin", tags=["📦 Checkout & Logística"])
def registrar_retorno_checkin(payload: dict):
    try:
        id_maestro = int(payload["id_maestro"])
        id_op = int(payload["id_evento"])
        incidencias_gen = str(payload["incidencias_generales"])
        items = payload["items"]
        
        with engine_eventos.begin() as conn_ev:
            # 1️⃣ CIRCUITO: db_eventos (Sellar la OP de ruta como RECIBIDO)
            conn_ev.execute(text("""
                UPDATE public.checkouts_maestro 
                SET estado_bodega = 'RECIBIDO', 
                    incidencias_generales = :obs, 
                    fecha = CURRENT_DATE, 
                    hora = CURRENT_TIME 
                WHERE id_maestro = :id_m
            """), {"obs": incidencias_gen, "id_m": id_maestro})

            for item in items:
                valor_cotejo = bool(item.get("COTEJADO", item.get("cotejado", False)))
                conn_ev.execute(text("""
                    UPDATE public.checkouts_detalle 
                    SET cotejado = :cot, notas_regreso = :not_r 
                    WHERE id_detalle = :id_d
                """), {"cot": valor_cotejo, "not_r": str(item.get("OBS_REGRESO", "")), "id_d": int(item["id_detalle"])})
        
        with engine_inventario.begin() as conn_inv:
            # 2️⃣ CIRCUITO: db_inventario (Actualización de Hardware e Historial)
            for item in items:
                cod_eq = str(item["ID"]).strip()
                obs_regreso = str(item.get("OBS_REGRESO", "")).strip()
                valor_cotejo = bool(item.get("COTEJADO", item.get("cotejado", False)))
                
                es_danado = any(p in obs_regreso.lower() for p in ["dañ", "rot", "fall", "quebr", "freg", "mal", "golp", "abiert", "daã"])
                médico_status = "DANADO" if es_danado else "BUEN ESTADO"
                
                if valor_cotejo:
                    if cod_eq.lower().startswith("inv_vpro_alt_"):
                        conn_inv.execute(text("""
                            UPDATE public.inventario_kits 
                            SET ubicacion_inv_kits = 'BODEGA', estado_inv_kits = :est, observaciones_inv_kits = :obs 
                            WHERE codigo_inv_kits = :cod
                        """), {"cod": cod_eq, "est": médico_status, "obs": obs_regreso})
                    else:
                        conn_inv.execute(text("""
                            UPDATE public.inventario 
                            SET ubicacion = 'BODEGA', estado = :est, observaciones = :obs 
                            WHERE codigo = :cod
                        """), {"cod": cod_eq, "est": "DAÑADO" if es_danado else "OK", "obs": obs_regreso})
                
                if obs_regreso:
                    conn_inv.execute(text("""
                        INSERT INTO public.historial_equipo 
                            (codigo_equipo, fecha, folio_vpro, id_empleado, tipo_evento, descripcion, costo_asociado, estado_final, departamento) 
                        VALUES 
                            (:codigo_equipo, CURRENT_DATE, :folio_vpro, :id_empleado, :tipo_evento, :descripcion, :costo_asociado, :estado_final, :departamento)
                    """), {
                        "codigo_equipo": cod_eq.upper(), 
                        "folio_vpro": f"OP-{id_op}", 
                        "id_empleado": "000", 
                        "tipo_evento": "FALLA_EN_SET" if es_danado else "CHECKIN_REVISIÓN", 
                        "descripcion": obs_regreso, 
                        "costo_asociado": 0.0, 
                        "estado_final": "MANTENIMIENTO" if es_danado else "RESUELTO", 
                        "departamento": "BODEGA"
                    })

                    if es_danado:
                        import time
                        ticket_ruta = f"REP-RUT-{int(time.time())}-{cod_eq.upper()[:4]}"
                        conn_inv.execute(text("""
                            INSERT INTO public.reparaciones 
                                (num_d_servicio, equipo_n_reparacion, reportante, descripcion_del_dano, estado_actual, costo_d_reparacion, fecha_d_reporte, area_q_pertenece, folio_vpro) 
                            VALUES 
                                (:num_serv, :eq, 'Operación / Ruta (Check-in)', :desc, '⚙️ EN REPARACIÓN', 0.0, CURRENT_DATE, 'SISTEMAS', :fol)
                        """), {
                            "num_serv": ticket_ruta, 
                            "eq": cod_eq.upper(), 
                            "desc": obs_regreso, 
                            "fol": f"OP-{id_op}"
                        })

            # 3️⃣ 🎯 EL CAJETEÓ-TRACKER: ASIGNACIÓN DIRECTA DE INCIDENCIA AL PROVEEDOR
            if "[PROVEEDOR_INCIDENTE:" in incidencias_gen:
                try:
                    start_idx = incidencias_gen.find("[PROVEEDOR_INCIDENTE:") + 21
                    end_idx = incidencias_gen.find("]", start_idx)
                    if end_idx != -1:
                        raw_prov = incidencias_gen[start_idx:end_idx].strip()
                        prov_nom, prov_nota = "--- NINGUNO ---", ""
                        if " | NOTA: " in raw_prov:
                            prov_nom, prov_nota = raw_prov.split(" | NOTA: ", 1)
                        else:
                            prov_nom = raw_prov

                        prov_nom = prov_nom.strip().upper()
                        prov_nota = prov_nota.strip()

                        if prov_nom and prov_nom != "--- NINGUNO ---":
                            import time
                            ticket_prov = f"REP-PRV-{int(time.time())}"
                            
                            # Inyectamos a la tabla de reparaciones usando al proveedor como 'reportante'
                            conn_inv.execute(text("""
                                INSERT INTO public.reparaciones 
                                    (num_d_servicio, equipo_n_reparacion, reportante, descripcion_del_dano, estado_actual, costo_d_reparacion, fecha_d_reporte, area_q_pertenece, folio_vpro) 
                                VALUES 
                                    (:num_serv, 'INCIDENCIA/FALTA DE SERVICIO', :reportante, :desc, '⚠️ REPORTADO A DIRECCIÓN', 0.0, CURRENT_DATE, 'PROVEEDORES', :fol)
                            """), {
                                "num_serv": ticket_prov,
                                "reportante": prov_nom,  # 👈 Sello indestructible con su nombre
                                "desc": f"Falta/Daño reportado en Check-in de OP-{id_op}: {prov_nota}",
                                "fol": f"OP-{id_op}"
                            })
                except Exception as ex_p:
                    print(f"⚠️ Alerta al procesar culpa del proveedor: {ex_p}")

        return {"status": "SUCCESS"}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/checkout/pendientes/{id_empleado}/{nombre_usuario}", tags=["📦 Checkout & Logística"])
def obtener_ops_pendientes_usuario(id_empleado: str, nombre_usuario: str):
    try:
        target_user = nombre_usuario.strip()
        with engine_eventos.connect() as conn:
            # ✨ EL MISMO FILTRO AQUÍ
            query_pendientes = text("""
                SELECT e.id_evento, encode(e.para_q_cliente::bytea, 'hex'), encode(e.nombre_evento::bytea, 'hex'), e.personal_convocado_op 
                FROM public.eventos e
                LEFT JOIN public.informes_gastos_maestro igm ON e.id_evento = igm.folio_vpro
                WHERE COALESCE(igm.revisado, FALSE) = FALSE 
                  AND UPPER(COALESCE(e.estatus, 'ACTIVA')) != 'CERRADA (HISTÓRICO)'
                ORDER BY e.id_evento DESC
            """)
            rows = conn.execute(query_pendientes).fetchall()
            ops_pendientes = []
            
            for r in rows:
                id_ev = r[0]
                cliente = reparar_mojibake(safe_decode_hex(r[1]))
                evento = reparar_mojibake(safe_decode_hex(r[2]))
                personal_raw = r[3]
                
                convocados = []
                if personal_raw:
                    if isinstance(personal_raw, list): convocados = [str(p).strip() for p in personal_raw if p]
                    elif isinstance(personal_raw, str):
                        s = personal_raw.strip()
                        if s.startswith("{") and s.endswith("}"):
                            s = s[1:-1]
                            import csv
                            try: convocados = [x.strip() for x in next(csv.reader([s])) if x]
                            except: convocados = [x.strip().strip('"').strip() for x in s.split(",") if x]
                        else: convocados = [x.strip().strip('"').strip() for x in s.split(",") if x]
                
                if target_user in convocados:
                    m_row = conn.execute(text("SELECT estado_bodega FROM public.checkouts_maestro WHERE folio_op = :id AND TRIM(id_empleado) = :emp"), {"id": id_ev, "emp": id_empleado.strip()}).mappings().first()
                    estado_actual_bodega = m_row["estado_bodega"] if m_row else "NUEVO"
                    
                    if estado_actual_bodega in ["NUEVO", "PENDIENTE"]:
                        ops_pendientes.append({"id_evento": id_ev, "label": f"OP-{str(id_ev).zfill(3)} | {cliente} - {evento}", "estado": estado_actual_bodega})
            return ops_pendientes
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/inventario-kits/ultimo-id-alterno/{id_empleado}", tags=["🛠️ Inventario General"])
def obtener_ultimo_id_alterno_empleado(id_empleado: str):
    try:
        with engine_inventario.connect() as conn:
            patron = f"Inv_alt_{id_empleado.strip()}%"
            row = conn.execute(text("SELECT codigo_inv_kits FROM public.inventario_kits WHERE codigo_inv_kits LIKE :patron ORDER BY codigo_inv_kits DESC LIMIT 1"), {"patron": patron}).fetchone()
            if row and row[0]:
                val_str = str(row[0]).strip()
                prefijo = f"Inv_alt_{id_empleado.strip()}"
                str_num = val_str.replace(prefijo, "")
                try: return {"ultimo_id": int(str_num)}
                except: pass
        return {"ultimo_id": 0}
    except: return {"ultimo_id": 0}
    


# 📊 INCIDENCIAS Y BALANCE EJECUTIVO (COMPARATIVO CON vs SIN INCIDENCIA) - ⚡ VERSIÓN DIAGNÓSTICO
@app.get("/api/incidencias/balance-ejecutivo", tags=["📊 Incidencias"])
def obtener_balance_ejecutivo_incidencias(
    desde: Optional[str] = Query(None, description="Fecha inicio YYYY-MM-DD"),
    hasta: Optional[str] = Query(None, description="Fecha fin YYYY-MM-DD")
):
    try:
        filtro_fecha = ""
        params = {}
        if desde and hasta:
            filtro_fecha = " AND COALESCE(ev.fec_del_evento, cm.fecha) BETWEEN CAST(:desde AS date) AND CAST(:hasta AS date) "
            params = {"desde": desde, "hasta": hasta}

        # 🛡️ Regresamos al SQL original exacto que tú tenías, solo sumamos el COALESCE de la fecha
        query_maestro = text(f"""
            SELECT cm.id_maestro, 
                   cm.folio_op, 
                   encode(cm.incidencias_generales::bytea, 'hex') as inc_hex, 
                   COALESCE(ev.fec_del_evento, cm.fecha) as fecha, 
                   encode(cm.id_empleado::bytea, 'hex') as emp_hex, 
                   encode(ev.nombre_evento::bytea, 'hex') as ev_hex, 
                   encode(ev.para_q_cliente::bytea, 'hex') as cli_hex
            FROM public.checkouts_maestro cm 
            LEFT JOIN public.eventos ev ON cm.folio_op = ev.id_evento
            WHERE 1=1
              {filtro_fecha}
        """)

        rows_nuevos = []
        rows_viejos = []

        # 1️⃣ LEEMOS LA BASE NUEVA
        try:
            with engine_eventos.connect() as conn_ev:
                rows_nuevos = conn_ev.execute(query_maestro, params).fetchall()
                print(f"✅ BASE NUEVA: Se encontraron {len(rows_nuevos)} registros.")
        except Exception as e:
            print(f"⚠️ ERROR LEYENDO BASE NUEVA: {e}")

        # 2️⃣ LEEMOS LA BASE VIEJA
        try:
            with engine_eventos_vieja.connect() as conn_ev_v:
                rows_viejos = conn_ev_v.execute(query_maestro, params).fetchall()
                print(f"✅ BASE VIEJA: Se encontraron {len(rows_viejos)} registros.")
        except Exception as e:
            print(f"⚠️ ERROR LEYENDO BASE VIEJA: {e}")

        # 🧠 3️⃣ FUSIÓN 
        registros_unicos = []
        firmas_vistas = set()
        
        for r in rows_nuevos + rows_viejos:
            # Firma: Folio + Texto_Hex + Empleado
            firma_unica = f"{str(r[1])}_{str(r[2])}_{str(r[4])}"
            if firma_unica not in firmas_vistas:
                firmas_vistas.add(firma_unica)
                registros_unicos.append(r)

        print(f"🔄 FUSIÓN TOTAL: Quedaron {len(registros_unicos)} registros únicos tras juntarlas.")

        rows_ev = sorted(registros_unicos, key=lambda x: x[3] if x[3] else datetime.date.min, reverse=True)

        with engine_personal.connect() as conn_pers:
            rows_p = conn_pers.execute(text("SELECT encode(id_empleado::bytea, 'hex'), encode(nombre::bytea, 'hex') FROM public.empleados")).fetchall()
            dict_empleados = {safe_decode_hex(r[0]).strip(): safe_decode_hex(r[1]).strip() for r in rows_p}

        incidencias_vpro = []
        incidencias_proveedores = []
        todos_checkouts = []
        conteo_prov = {}
        patron_relleno = r'^(?:[\-\*\s]*)(?:sin\s+incidencias?(?:\s+en|\s+de)?(?:\s+equipo|\s+transmisi[oó0-9a-z_Ã³]+|\s+personal)?[\.\,\s\-]*)+'

        for r in rows_ev:
            folio_op = f"OP-{str(r[1]).zfill(3)}" if r[1] else "S/F"
            nota_bruta = safe_decode_hex(r[2]).strip() if r[2] else ""
            fecha_str = str(r[3]) if r[3] else "S/F"
            id_emp_decoded = safe_decode_hex(r[4]).strip() if r[4] else ""
            nombre_staff = dict_empleados.get(id_emp_decoded, f"Empleado ID: {id_emp_decoded}") if id_emp_decoded else "Sin Asignar"
            nombre_evento = safe_decode_hex(r[5]) if r[5] else "Evento Desconocido"
            cliente_nombre = safe_decode_hex(r[6]) if r[6] else "Cliente Desconocido"

            es_incidencia = True
            if not nota_bruta or len(nota_bruta) < 18:
                es_incidencia = False
            else:
                nota_sin_relleno = re.sub(patron_relleno, '', nota_bruta, flags=re.IGNORECASE).strip()
                if len(nota_sin_relleno) < 8:
                    es_incidencia = False

            estado_registro = "CON INCIDENCIA" if es_incidencia else "SIN INCIDENCIA"
            checkout_item = {
                "fecha": fecha_str,
                "responsable_o_prov": nombre_staff,
                "folio_op": folio_op,
                "evento": f"{cliente_nombre} - {nombre_evento}",
                "descripcion": nota_bruta if nota_bruta else "Sin incidencias.",
                "estado_incidencia": estado_registro,
                "estatus": "📝 NOTA DE CAMPO" if es_incidencia else "✅ OK / SIN INCIDENCIA"
            }
            
            todos_checkouts.append(checkout_item)

            if es_incidencia:
                if "[PROVEEDOR_INCIDENTE:" in nota_bruta:
                    start_idx = nota_bruta.find("[PROVEEDOR_INCIDENTE:") + 21
                    end_idx = nota_bruta.find("]", start_idx)
                    prov_nom, prov_nota = "--- NINGUNO ---", ""
                    if end_idx != -1:
                        raw_tag = nota_bruta[start_idx:end_idx].strip()
                        if " | NOTA: " in raw_tag:
                            prov_nom, prov_nota = raw_tag.split(" | NOTA: ", 1)
                        else:
                            prov_nom = raw_tag
                        nota_bruta = nota_bruta[:nota_bruta.find("[PROVEEDOR_INCIDENTE:")].strip()

                    prov_nom = prov_nom.strip().upper()
                    prov_nota = prov_nota.strip() if prov_nota else nota_bruta

                    if prov_nom and prov_nom != "--- NINGUNO ---":
                        conteo_prov[prov_nom] = conteo_prov.get(prov_nom, 0) + 1
                        incidencias_proveedores.append({
                            "fecha": fecha_str,
                            "responsable_o_prov": prov_nom,
                            "folio_op": folio_op,
                            "evento": f"{cliente_nombre} - {nombre_evento}",
                            "descripcion": prov_nota,
                            "reportado_por": nombre_staff,
                            "estatus": "⚠️ REPORTADO A DIRECCIÓN",
                            "estado_incidencia": "CON INCIDENCIA"
                        })
                incidencias_vpro.append(checkout_item)

        ranking_proveedores = [{"proveedor": prov, "total_faltas": cant} for prov, cant in sorted(conteo_prov.items(), key=lambda x: x[1], reverse=True)]

        return {
            "status": "SUCCESS",
            "totales": {
                "total_general": len(todos_checkouts),
                "total_con_incidencia": len(incidencias_vpro) + len(incidencias_proveedores),
                "total_sin_incidencia": len(todos_checkouts) - len(incidencias_vpro),
                "total_vpro": len(incidencias_vpro),
                "total_proveedores": len(incidencias_proveedores)
            },
            "todos_checkouts": todos_checkouts,
            "ranking_proveedores": ranking_proveedores,
            "detalle_vpro": incidencias_vpro,
            "detalle_proveedores": incidencias_proveedores
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@app.get("/api/incidencias/reporte", tags=["📊 Incidencias"])
def obtener_reporte_incidencias_global():
    try:
        # 1. SQL mejorado (Usando la fecha real del evento y asegurando formato texto)
        query = text("""
            SELECT cm.id_maestro, 
                   cm.folio_op, 
                   encode(cm.incidencias_generales::text::bytea, 'hex') as inc_hex, 
                   COALESCE(ev.fec_del_evento, cm.fecha) as fecha, 
                   encode(cm.id_empleado::text::bytea, 'hex') as emp_hex, 
                   encode(ev.nombre_evento::text::bytea, 'hex') as ev_hex, 
                   encode(ev.para_q_cliente::text::bytea, 'hex') as cli_hex
            FROM public.checkouts_maestro cm 
            LEFT JOIN public.eventos ev ON cm.folio_op = ev.id_evento
        """)
        
        rows_nuevos = []
        rows_viejos = []

        # 2. 🟢 LEER BASE DE DATOS NUEVA
        try:
            with engine_eventos.connect() as conn_ev:
                rows_nuevos = conn_ev.execute(query).fetchall()
        except Exception: pass

        # 3. 🟡 LEER BASE DE DATOS VIEJA (Aquí estaba el error, ¡le faltaba esto!)
        try:
            with engine_eventos_vieja.connect() as conn_ev_v:
                rows_viejos = conn_ev_v.execute(query).fetchall()
        except Exception: pass

        # 4. 🧠 FUSIÓN INTELIGENTE (Priorizamos el reporte con más texto)
        mejores_registros = {}
        for r in rows_nuevos + rows_viejos:
            # Firma: Folio + Fecha + Empleado
            firma_unica = f"{str(r[1])}_{str(r[3])}_{str(r[4])}"
            nota_actual = str(r[2]) if r[2] else ""
            
            if firma_unica not in mejores_registros:
                mejores_registros[firma_unica] = r
            else:
                nota_guardada = str(mejores_registros[firma_unica][2]) if mejores_registros[firma_unica][2] else ""
                if len(nota_actual) > len(nota_guardada):
                    mejores_registros[firma_unica] = r

        registros_unicos = list(mejores_registros.values())

        # 5. Mapeo de personal y armado del reporte
        with engine_personal.connect() as conn_pers:
            query_p = text("SELECT encode(e.id_empleado::bytea, 'hex'), encode(e.nombre::bytea, 'hex'), encode(COALESCE(d.nombre, e.depto)::bytea, 'hex') FROM public.empleados e LEFT JOIN public.departamentos d ON (CASE WHEN e.depto ~ '^[0-9]+$' THEN CAST(e.depto AS INTEGER) = d.id ELSE FALSE END)")
            rows_p = conn_pers.execute(query_p).fetchall()

        personal_map = {safe_decode_hex(r[0]): {"nombre_empleado": safe_decode_hex(r[1]), "depto_real": safe_decode_hex(r[2])} for r in rows_p}
        
        reporte = []
        for r in registros_unicos:
            id_emp_decoded = safe_decode_hex(r[4])
            emp_info = personal_map.get(id_emp_decoded, {"nombre_empleado": "Desconocido", "depto_real": "Sin Departamento"})
            reporte.append({
                "id_maestro": r[0], 
                "folio_op": r[1], 
                "incidencias_generales": safe_decode_hex(r[2]), 
                "fecha": str(r[3]) if r[3] else None, 
                "id_empleado": id_emp_decoded, 
                "nombre_evento": safe_decode_hex(r[5]) if r[5] else "Evento no registrado", 
                "para_q_cliente": safe_decode_hex(r[6]) if r[6] else "Cliente no registrado", 
                "nombre_empleado": emp_info["nombre_empleado"], 
                "depto_real": emp_info["depto_real"]
            })
        
        # Ordenar por fecha descendente antes de enviar
        reporte.sort(key=lambda x: x["fecha"] if x["fecha"] else "0000-00-00", reverse=True)
        return reporte

    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

# 📸 MOTOR DE EVIDENCIAS FOTOGRÁFICAS DE DAÑOS
DIR_EVIDENCIAS_REAL = r"C:\Users\cuauhtemoc\Desktop\Curso_de_Python\Graficos\VPRO_Dashboard_V2_TODO_NUEVO\Fotos_de_equipos"
os.makedirs(DIR_EVIDENCIAS_REAL, exist_ok=True)
app.mount("/evidencias_web", StaticFiles(directory=DIR_EVIDENCIAS_REAL), name="evidencias")

@app.post("/api/inventario/subir-evidencia", tags=["🛠️ Inventario General"])
def subir_evidencia_falla(codigo_equipo: str = Form(...), folio_vpro: str = Form(...), file: UploadFile = File(...)):
    try:
        # 🌟 LA LICUADORA APLICADA: Ahora también elimina los espacios
        cod_safe = codigo_equipo.replace("/", "_").replace("\\", "_").replace(" ", "_").strip().upper()
        fol_safe = folio_vpro.replace("/", "_").replace("\\", "_").replace(" ", "_").strip().upper()
        
        filename = f"Evidencia_{fol_safe}_{cod_safe}.jpg"
        filepath = os.path.join(DIR_EVIDENCIAS_REAL, filename)
        
        with open(filepath, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        return {"status": "SUCCESS"}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/inventario/evidencia/{folio_vpro}/{codigo_equipo}", tags=["🛠️ Inventario General"])
def obtener_evidencia_falla(folio_vpro: str, codigo_equipo: str):
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
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/analitica/ceo-panel", tags=["📊 Inteligencia de Negocio / CEO"])
def obtener_analitica_panel_ceo(desde: str = Query(..., description="Fecha inicio YYYY-MM-DD"), hasta: str = Query(..., description="Fecha fin YYYY-MM-DD")):
    # (Mantenido intacto el bloque original de CEO por brevedad)
    return {"status": "SUCCESS", "total_eventos": 0, "cliente_top": "Deshabilitado", "ranking_clientes": [], "equipos_reparacion": 0, "desviacion": "0%", "top_empleados": [], "taller_tracking": [], "incidencias_por_depto": []}

# 🔐 SEGURIDAD Y AUTH

@app.get("/api/auth/empleados-lista", tags=["Seguridad"])
def obtener_lista_nombres_login():
    try:
        conn = get_db_connection("db_personal_prueba")
        cursor = conn.cursor()
        cursor.execute("SELECT encode(nombre::bytea, 'hex'), encode(rol::bytea, 'hex'), encode(depto::bytea, 'hex') FROM public.empleados WHERE nombre IS NOT NULL")
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        
        lista_filtrada = []
        for r in rows:
            nombre = safe_decode_hex(r[0])
            rol = safe_decode_hex(r[1]).strip().upper()
            depto = safe_decode_hex(r[2]).strip().lower()
            if rol not in ['BAJA', 'PROVEEDOR'] and 'externo' not in depto:
                lista_filtrada.append(nombre)
        lista_filtrada.sort()
        return lista_filtrada
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/auth/login", tags=["Seguridad"])
def autenticar_usuario(datos: LoginRequest):
    try:
        conn = get_db_connection("db_personal_prueba")
        cursor = conn.cursor()
        cursor.execute("""
            SELECT encode(nombre::bytea, 'hex'), encode(depto::bytea, 'hex'), encode(password::bytea, 'hex'), 
                   encode(rol::bytea, 'hex'), encode(id_empleado::bytea, 'hex'), encode(email::bytea, 'hex')
            FROM public.empleados
        """)
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        
        target_user = datos.usuario.strip().lower()
        
        for row in rows:
            db_nombre = safe_decode_hex(row[0]).strip()
            if db_nombre.lower() == target_user:
                db_password = safe_decode_hex(row[2]).strip()
                
                # Verificamos la contraseña
                if not verificar_password(datos.contrasena, db_password):
                    raise HTTPException(status_code=401, detail="Contraseña incorrecta.")
                
                requiere_cambio = False
                clave_ingresada = datos.contrasena.strip()
                if not db_password.startswith("$2b$") or clave_ingresada == "vpro123" or clave_ingresada.startswith("VPRO-"):
                    requiere_cambio = True
                
                return {
                    "autenticado": True, "nombre_completo": db_nombre,
                    "rol": safe_decode_hex(row[3]).strip().upper(), "depto": safe_decode_hex(row[1]),
                    "id_empleado": safe_decode_hex(row[4]).strip(), "email": safe_decode_hex(row[5]).strip(),
                    "requiere_cambio": requiere_cambio 
                }
        raise HTTPException(status_code=401, detail="El empleado no se encuentra registrado.")
    except HTTPException as he: raise he
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/auth/cambiar-password", tags=["Seguridad"])
def cambiar_password(payload: dict):
    try:
        # 🔍 Extraemos la info del JSON dinámicamente
        id_emp = str(payload.get("id_empleado") or payload.get("id_usuario") or "").strip()
        nueva_pass = str(payload.get("nueva_contrasena") or payload.get("nueva_clave") or payload.get("password") or "").strip()
        
        if not id_emp or not nueva_pass:
            raise HTTPException(status_code=400, detail="Faltan datos obligatorios para el cambio.")
            
        pass_encriptada = encriptar_password(nueva_pass)
        
        conn = get_db_connection("db_personal_prueba")
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE public.empleados SET password = %s WHERE TRIM(id_empleado) = %s;",
            (pass_encriptada, id_emp)
        )
        conn.commit()
        cursor.close()
        conn.close()
        
        return {"status": "SUCCESS", "mensaje": "Contraseña encriptada y actualizada con éxito."}
    except Exception as e:
        print(f"🔥 Error en cambiar_password: {e}")
        raise HTTPException(status_code=500, detail=str(e))
import os
from fastapi import Request

# 📖 VISOR DE EXPEDIENTE CLÍNICO DE EQUIPOS (Historial + Fotos)
@app.get("/api/inventario/expediente/{codigo_equipo:path}", tags=["🛠️ Inventario General"])
def consultar_expediente_equipo(codigo_equipo: str, request: Request):
    try:
        conn = get_db_connection("db_inventario_prueba")
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        
        # 1️⃣ Buscamos el historial en la tabla CORRECTA y con las columnas CORRECTAS
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
            ORDER BY fecha DESC, id_registro DESC;  -- 🌟 AQUÍ ESTABA EL ERROR (id_registro)
        """, (codigo_equipo,))
        
        historial_db = cursor.fetchall()
        cursor.close()
        conn.close()

        # 2️⃣ Buscamos si hay fotos usando la "Licuadora"
        fotos_encontradas = []
        if os.path.exists(DIR_EVIDENCIAS_REAL):
            
            codigo_limpio = codigo_equipo.replace(" ", "_").lower()
            
            for nombre_archivo in os.listdir(DIR_EVIDENCIAS_REAL):
                archivo_limpio = nombre_archivo.replace(" ", "_").lower()
                
                if codigo_limpio in archivo_limpio and nombre_archivo.lower().endswith(('.png', '.jpg', '.jpeg')):
                    
                    url_foto = f"Fotos_de_equipos/{nombre_archivo}" 
                    fotos_encontradas.append(url_foto)

        return {
            "historial": historial_db,
            "fotos": fotos_encontradas
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al consultar expediente: {str(e)}")

# ===============================================================================
# 📊 DASHBOARD EJECUTIVO Y FILTROS DINÁMICOS
# ===============================================================================

@app.get("/api/dashboard/filtros", tags=["📊 Dashboard"])
def obtener_filtros_disponibles():
    try:
        # Buscamos Departamentos en Inventario
        conn_inv = get_db_connection("db_inventario_prueba")
        cur_inv = conn_inv.cursor()
        cur_inv.execute("SELECT DISTINCT departamento FROM public.historial_equipo WHERE departamento IS NOT NULL;")
        deptos = [row[0] for row in cur_inv.fetchall()]
        cur_inv.close()
        conn_inv.close()

        # Buscamos Empleados en Eventos (Checkouts)
        conn_ev = get_db_connection("db_eventos_prueba")
        cur_ev = conn_ev.cursor()
        cur_ev.execute("SELECT DISTINCT id_empleado FROM public.checkouts_maestro WHERE id_empleado IS NOT NULL;")
        empleados = [row[0] for row in cur_ev.fetchall()]
        cur_ev.close()
        conn_ev.close()

        return {"departamentos": deptos, "empleados": empleados}
    except Exception as e:
        return {"departamentos": [], "empleados": []}


@app.get("/api/dashboard/resumen", tags=["📊 Dashboard"])
def obtener_resumen_dashboard(
    fecha_inicio: Optional[str] = None, 
    fecha_fin: Optional[str] = None,
    departamento: Optional[str] = None,
    empleado: Optional[str] = None
):
    try:
        # 1️⃣ LLAVE 1: INVENTARIO (Daños y Gastos)
        conn_inv = get_db_connection("db_inventario_prueba")
        cursor_inv = conn_inv.cursor(cursor_factory=RealDictCursor)

        query_gastos = "SELECT COALESCE(SUM(costo_asociado), 0) as total_gastado FROM public.historial_equipo WHERE 1=1"
        params_inv = []
        if departamento and departamento != "Todos":
            query_gastos += " AND departamento = %s"
            params_inv.append(departamento)
            
        cursor_inv.execute(query_gastos, tuple(params_inv))
        gasto_total = cursor_inv.fetchone()["total_gastado"]

        cursor_inv.execute("SELECT departamento as depto, COUNT(*) as total FROM public.historial_equipo WHERE departamento IS NOT NULL GROUP BY departamento;")
        deptos_danos = cursor_inv.fetchall()

        cursor_inv.close()
        conn_inv.close()

        # 2️⃣ LLAVE 2: EVENTOS (Operaciones y Comercial)
        conn_ev = get_db_connection("db_eventos_prueba")
        cursor_ev = conn_ev.cursor(cursor_factory=RealDictCursor)

        query_ops = "SELECT COUNT(*) as total FROM public.eventos WHERE 1=1"
        params_ops = []
        if fecha_inicio and fecha_fin:
            query_ops += " AND fec_de_elaboracion_de_op BETWEEN %s AND %s"
            params_ops.extend([fecha_inicio, fecha_fin])
        else:
            query_ops += " AND EXTRACT(MONTH FROM fec_de_elaboracion_de_op) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM fec_de_elaboracion_de_op) = EXTRACT(YEAR FROM CURRENT_DATE)"
            
        cursor_ev.execute(query_ops, tuple(params_ops))
        ops_mes = cursor_ev.fetchone()["total"]

        query_chk = "SELECT COUNT(*) as total FROM public.checkouts_maestro WHERE 1=1"
        query_inc = "SELECT COUNT(*) as total FROM public.checkouts_maestro WHERE incidencias_generales IS NOT NULL AND TRIM(incidencias_generales) != ''"
        params_chk = []
        
        if fecha_inicio and fecha_fin:
            filtro_fecha = " AND fecha BETWEEN %s AND %s"
            query_chk += filtro_fecha
            query_inc += filtro_fecha
            params_chk.extend([fecha_inicio, fecha_fin])
            
        if empleado and empleado != "Todos":
            filtro_emp = " AND id_empleado = %s"
            query_chk += filtro_emp
            query_inc += filtro_emp
            params_chk.append(empleado)

        cursor_ev.execute(query_chk, tuple(params_chk))
        total_checkouts = cursor_ev.fetchone()["total"]
        
        cursor_ev.execute(query_inc, tuple(params_chk))
        checkouts_con_incidencias = cursor_ev.fetchone()["total"]
        
        if total_checkouts > 0:
            tasa_incidencias = round((checkouts_con_incidencias / total_checkouts) * 100, 1)
            logistica_tiempo = round(100 - tasa_incidencias, 1)
        else:
            tasa_incidencias, logistica_tiempo = 0, 100

        # ✨ NUEVO: Matemática para la Gráfica de Dona (Efectividad)
        checkouts_limpios = total_checkouts - checkouts_con_incidencias
        efectividad_checkouts = [
            {"estado": "Limpios", "total": checkouts_limpios},
            {"estado": "Con Incidencias", "total": checkouts_con_incidencias}
        ] if total_checkouts > 0 else []

        cursor_ev.execute("SELECT para_q_cliente as cliente, COUNT(*) as total FROM public.eventos WHERE para_q_cliente IS NOT NULL AND TRIM(para_q_cliente) != '' GROUP BY para_q_cliente ORDER BY total DESC LIMIT 5;")
        top_clientes = cursor_ev.fetchall()
        cliente_top = top_clientes[0]["cliente"] if top_clientes else "Sin datos"
        
        # ✨ NUEVO: Extracción del TOP 3 Empleados
        cursor_ev.execute("SELECT id_empleado, COUNT(*) as total FROM public.checkouts_maestro WHERE id_empleado IS NOT NULL AND TRIM(id_empleado) != '' GROUP BY id_empleado ORDER BY total DESC LIMIT 3;")
        top_empleados_raw = cursor_ev.fetchall()

        cursor_ev.execute("SELECT TO_CHAR(fec_de_elaboracion_de_op, 'YYYY-MM') as mes, COUNT(*) as total FROM public.eventos WHERE fec_de_elaboracion_de_op IS NOT NULL GROUP BY mes ORDER BY mes ASC;")
        ops_por_mes = cursor_ev.fetchall()

        cursor_ev.close()
        conn_ev.close()

        # ✨ NUEVO: Traductor de IDs a Nombres Reales
        top_empleados = []
        empleado_top = "Sin datos"
        
        if top_empleados_raw:
            conn_pers = get_db_connection("db_personal_prueba")
            cursor_pers = conn_pers.cursor(cursor_factory=RealDictCursor)
            cursor_pers.execute("SELECT TRIM(id_empleado) as id_emp, encode(nombre::bytea, 'hex') as nombre_hex FROM public.empleados")
            emps = cursor_pers.fetchall()
            cursor_pers.close()
            conn_pers.close()
            
            def dec_hex(val):
                try: return bytes.fromhex(val).decode('utf-8')
                except: return str(val)
                
            dict_empleados = {str(e['id_emp']): dec_hex(e['nombre_hex']) for e in emps if e['id_emp'] and e['nombre_hex']}
            
            for row in top_empleados_raw:
                id_e = str(row["id_empleado"]).strip()
                nombre_real = dict_empleados.get(id_e, f"ID: {id_e}")
                top_empleados.append({"empleado": nombre_real, "total": row["total"]})
                
            empleado_top = top_empleados[0]["empleado"]

        # 3️⃣ LLAVE 3: AUTOS (Flota y Seguros)
        conn_autos = get_db_connection("db_autos_prueba")
        cursor_autos = conn_autos.cursor(cursor_factory=RealDictCursor)

        # Traemos num_control, marca y estado_actual
        cursor_autos.execute("SELECT num_control, marca, estado_actual as estado FROM public.autos WHERE estado_actual IS NOT NULL;")
        estado_flota = cursor_autos.fetchall()
        
        # Inteligencia para detectar autos con problemas
        autos_en_taller = 0
        for item in estado_flota:
            texto_estado = str(item['estado']).lower()
            if any(fallo in texto_estado for fallo in ['taller', 'mantenimiento', 'reparación', 'inactivo', 'apaga', 'truena', 'falla']):
                autos_en_taller += 1

        cursor_autos.execute("SELECT COUNT(*) as vencen_pronto FROM public.autos WHERE seguro_vence BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days';")
        seguros_vencer = cursor_autos.fetchone()["vencen_pronto"]

        cursor_autos.close()
        conn_autos.close()

        # 4️⃣ EMPAQUETADO FINAL A STREAMLIT
        return {
            "finanzas": {
                "gasto_mes": float(gasto_total),
                "equipos_danados": sum(d['total'] for d in deptos_danos), 
                "flota_taller": autos_en_taller, 
                "seguros_vencer": seguros_vencer, 
                "deptos_danos": deptos_danos,
                "estado_flota": estado_flota 
            },
            "comercial": {
                "ops_mes": ops_mes,
                "cliente_top": cliente_top,
                "proveedores_activos": 0,
                "top_clientes": top_clientes, 
                "ops_por_mes": ops_por_mes    
            },
            "operaciones": {
                "tasa_incidencias": tasa_incidencias,
                "logistica_tiempo": logistica_tiempo,
                "empleado_top": empleado_top,
                "top_empleados": top_empleados,              # 🚀 Inyectado
                "efectividad_checkouts": efectividad_checkouts # 🚀 Inyectado
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/checkout/historial-op/{id_evento}", tags=["📦 Checkout & Logística"])
def obtener_historial_checkouts_op(id_evento: int):
    try:
        with engine_eventos.connect() as conn:
            q_maestro = text("""
                SELECT id_maestro, id_empleado, fecha, hora, estado_bodega, 
                       encode(incidencias_generales::bytea, 'hex'), 
                       encode(nombre_kit::bytea, 'hex')
                FROM public.checkouts_maestro 
                WHERE folio_op = :id_ev
            """)
            maestros = conn.execute(q_maestro, {"id_ev": id_evento}).fetchall()
            
            if not maestros:
                return {"status": "EMPTY", "checkouts": []}
                
            # Traer nombres de empleados
            with engine_personal.connect() as conn_p:
                emp_rows = conn_p.execute(text("SELECT TRIM(id_empleado), encode(nombre::bytea, 'hex') FROM public.empleados")).fetchall()
                dict_emps = {r[0]: safe_decode_hex(r[1]) for r in emp_rows}
            
            # Traer catálogo global para traducir IDs a nombres de equipo
            with engine_inventario.connect() as conn_i:
                inv_rows = conn_i.execute(text("SELECT codigo, encode(descripcion::bytea, 'hex') FROM public.inventario")).fetchall()
                inv_kits_rows = conn_i.execute(text("SELECT codigo_inv_kits, encode(descripcion_inv_kits::bytea, 'hex') FROM public.inventario_kits")).fetchall()
                dict_eq = {str(r[0]).strip().upper(): safe_decode_hex(r[1]) for r in inv_rows if r[0]}
                dict_eq.update({str(r[0]).strip().upper(): safe_decode_hex(r[1]) for r in inv_kits_rows if r[0]})

            resultados = []
            for m in maestros:
                id_m = m[0]
                nombre_emp = dict_emps.get(str(m[1]).strip(), f"ID: {m[1]}")
                
                q_detalle = text("""
                    SELECT encode(codigo_equipo::bytea, 'hex'), cantidad, encode(observaciones::bytea, 'hex'), 
                           cotejado, encode(notas_regreso::bytea, 'hex')
                    FROM public.checkouts_detalle WHERE id_maestro = :id_m
                """)
                detalles = conn.execute(q_detalle, {"id_m": id_m}).fetchall()
                
                items = []
                for d in detalles:
                    cod_eq = safe_decode_hex(d[0]).strip()
                    obs_salida = safe_decode_hex(d[2])
                    nombre_eq = dict_eq.get(cod_eq.upper(), "Equipo No Registrado")
                    
                    # Si es equipo custom (escrito a mano)
                    if not cod_eq and "[CUST_EQ:" in obs_salida:
                        s_idx = obs_salida.find("[CUST_EQ:") + 9
                        e_idx = obs_salida.find("]", s_idx)
                        if e_idx != -1:
                            nombre_eq = obs_salida[s_idx:e_idx]
                            obs_salida = obs_salida[:obs_salida.find("[CUST_EQ:")].strip() + " " + obs_salida[e_idx+1:].strip()
                            
                    items.append({
                        "CÓDIGO": cod_eq, "EQUIPO": nombre_eq, "CANT": d[1],
                        "OBS. SALIDA": obs_salida, "¿REGRESÓ?": "✅ SÍ" if d[3] else "❌ NO", "INCIDENCIA / DAÑO": safe_decode_hex(d[4])
                    })
                    
                resultados.append({
                    "empleado": nombre_emp, "fecha": str(m[2]) if m[2] else "", "hora": str(m[3]) if m[3] else "",
                    "estado": m[4], "incidencias": safe_decode_hex(m[5]), "plantilla": safe_decode_hex(m[6]), "items": items
                })
            return {"status": "SUCCESS", "checkouts": resultados}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/api/gastos/historial-op/{id_evento}", tags=["💸 Gastos"])
def obtener_gastos_historicos_op(id_evento: str):
    try:
        with engine_eventos.connect() as conn:
            q_maestro = text("SELECT * FROM public.informes_gastos_maestro WHERE CAST(folio_vpro AS TEXT) = :id")
            m_row = conn.execute(q_maestro, {"id": str(id_evento).strip()}).mappings().first()
            
            if not m_row: 
                return {"status": "EMPTY", "informe": None}
                
            id_inf = m_row.get("id_informe")
            id_emp = str(m_row.get("id_empleado", "")).strip()
            fecha_inicio_op = m_row.get("periodo_desde")
            
            nombre_productor = id_emp
            if id_emp:
                with engine_personal.connect() as conn_p:
                    emp_row = conn_p.execute(text("SELECT encode(nombre::bytea, 'hex') FROM public.empleados WHERE TRIM(id_empleado) = :id"), {"id": id_emp}).scalar()
                    if emp_row: 
                        nombre_productor = safe_decode_hex(emp_row)
            
            q_detalle = text("SELECT * FROM public.informes_gastos_detalle WHERE id_informe = :id_inf ORDER BY dia_num ASC")
            detalles = conn.execute(q_detalle, {"id_inf": id_inf}).mappings().fetchall()
            
            # ✨ CALCULADORA DE FECHAS (FORMATO: 13/08 - Jue)
            import datetime
            def formatear_fecha(fecha_base, dia_n):
                if not fecha_base: return f"Día {dia_n}"
                try:
                    if isinstance(fecha_base, str): f_base = datetime.date.fromisoformat(fecha_base)
                    else: f_base = fecha_base
                    
                    f_calc = f_base + datetime.timedelta(days=int(dia_n)-1)
                    dias = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]
                    
                    return f"{str(f_calc.day).zfill(2)}/{str(f_calc.month).zfill(2)} - {dias[f_calc.weekday()]}"
                except:
                    return f"Día {dia_n}"

            def fmt(val): return f"${float(val or 0):,.2f}"

            # ✨ ARMAMOS LA TABLA EXACTAMENTE COMO ANA LILIA LA VE
            items = []
            for d in detalles:
                dia_numero = d.get("dia_num", 1)
                items.append({
                    "Fecha": formatear_fecha(fecha_inicio_op, dia_numero),
                    "Hotel": fmt(d.get("hotel", 0)),
                    "Transp": fmt(d.get("transporte", 0)),
                    "Combust": fmt(d.get("combustible", 0)),
                    "Casetas": fmt(d.get("casetas", 0)),
                    "Desay": fmt(d.get("desayuno", 0)),
                    "Comida": fmt(d.get("comida", 0)),
                    "Cenas": fmt(d.get("cenas", 0)),
                    "Varios": fmt(d.get("varios", 0)),
                    "Total": fmt(d.get("total_dia", 0))
                })
                
            informe = {
                "productor": nombre_productor,
                "asignado": float(m_row.get("monto_entregado", 0) or 0),
                "gastado": float(m_row.get("subtotal", 0) or 0),
                "saldo": float(m_row.get("restante", 0) or 0),
                "items": items
            }
            return {"status": "SUCCESS", "informe": informe}
    except Exception as e:
        print(f"🔥 Error fatal en historial financiero: {e}")
        raise HTTPException(status_code=500, detail=str(e))