import os
import json
import qrcode
import base64
import shutil
import logging
import bcrypt

def verificar_password(plain_password: str, hashed_password: str) -> bool:
    """Verifica si la clave coincide. Soporta el formato viejo y el nuevo encriptado"""
    if not hashed_password.startswith("$2b$"):
        return plain_password == hashed_password
    
    # bcrypt requiere que los textos se conviertan a bytes antes de comparar
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

def encriptar_password(password: str) -> str:
    """Convierte el texto en un hash ilegible de forma nativa y moderna"""
    salt = bcrypt.gensalt()
    hashed_bytes = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed_bytes.decode('utf-8')

from io import BytesIO
from pydantic import BaseModel
from datetime import datetime, date, time
from fastapi import File, UploadFile, Form
from sqlalchemy import create_engine, text
from typing import Optional, List, Dict, Any
from fastapi import FastAPI, HTTPException, status

app = FastAPI(title="🎬 VPRO Core API Engine",description="Motor central unificado con soporte logístico, clínico y checador biométrico facial inmune a Unicode.",version="7.9.9")

# 🗄️ CONFIGURACIÓN DE ACCESO POSTGRESQL
DB_USER = "postgres"
DB_PASS = "1qaz2wsx"
DB_HOST = "localhost"
DB_PORT = "5432"

# 🧠 MOTORES DE CONEXIÓN SIMULTÁNEOS
engine_autos = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_autos", pool_size=5, max_overflow=10)
engine_eventos = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_eventos", pool_size=5, max_overflow=10)
engine_personal = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_personal", pool_size=5, max_overflow=10)
engine_clientes = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_clientes", pool_size=5, max_overflow=10)
engine_inventario = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_inventario", pool_size=5, max_overflow=10)
engine_proveedores = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/db_proveedores", pool_size=5, max_overflow=10)

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
    
def safe_decode_hex(hex_str: str) -> str:
    if not hex_str: return ""
    try: return bytes.fromhex(hex_str).decode('latin-1').strip()
    except:
        try: return bytes.fromhex(hex_str).decode('utf-8', errors='replace').strip()
        except: return str(hex_str).strip()

@app.get("/api/checkout/faltantes-global")
def obtener_checkouts_faltantes_global(dias: int = 7):
    """🚨 RADAR MULTI-BASE DE DATOS: Busca OPs omisas o inactivas"""
    try:
        with engine_eventos.connect() as conn_ev:
            q_ops = text("""
                SELECT id_evento, folio, nombre_evento, personal_convocado_op 
                FROM public.eventos
                WHERE fec_de_instalacion >= CURRENT_DATE - CAST(:dias || ' days' AS INTERVAL)
                   OR fec_del_evento >= CURRENT_DATE - CAST(:dias || ' days' AS INTERVAL)
                ORDER BY id_evento DESC
            """)
            res_ops = conn_ev.execute(q_ops, {"dias": dias}).fetchall()
            
        with engine_personal.connect() as conn_p:
            q_emps = text("SELECT TRIM(id_empleado), TRIM(nombre) FROM public.empleados")
            empleados_db = conn_p.execute(q_emps).fetchall()
            
        id_a_nombre = {r[0]: r[1] for r in empleados_db}
        nombre_a_id = {r[1].upper(): r[0] for r in empleados_db}
        checkouts_faltantes = []
        
        with engine_eventos.connect() as conn_ev:
            for op in res_ops:
                id_ev, folio, nombre_eve, personal_raw = op
                convocados = []
                if personal_raw:
                    if isinstance(personal_raw, list): convocados = [str(p).strip() for p in personal_raw]
                    else:
                        s_limpio = str(personal_raw).replace("{","").replace("}","").replace("[","").replace("]","")
                        convocados = [p.strip().strip('"').strip("'").strip() for p in s_limpio.split(",") if p]
                
                for item in convocados:
                    if not item: continue
                    item_clean = item.strip()
                    if item_clean.upper() in nombre_a_id:
                        emp_id = nombre_a_id[item_clean.upper()]; nombre_trabajador = item_clean
                    elif item_clean in id_a_nombre:
                        emp_id = item_clean; nombre_trabajador = id_a_nombre[item_clean]
                    else: emp_id = item_clean; nombre_trabajador = item_clean

                    q_chk = text("SELECT estado_bodega FROM public.checkouts_maestro WHERE folio_op = :id_ev AND TRIM(id_empleado) = :emp_id")
                    chk_status = conn_ev.execute(q_chk, {"id_ev": id_ev, "emp_id": emp_id}).fetchone()
                    
                    # 🚀 PARCHE: PENDIENTE Y RECIBIDO TAMBIÉN SIGNIFICAN QUE EL EMPLEADO YA CUMPLIÓ
                    if not chk_status or chk_status[0] not in ["DESPACHADO", "PROCESADO", "PENDIENTE", "RECIBIDO"]:
                        checkouts_faltantes.append({
                            "Folio": f"OP-{folio}", 
                            "Evento": nombre_eve, 
                            "Empleado": nombre_trabajador, 
                            "Estatus": "❌ Omiso (Sin registro)" if not chk_status else f"⚠️ Atorado: {chk_status[0]}"
                        })
        return checkouts_faltantes
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))
        
@app.get("/api/analitica/villarreal-panel", tags=["📊 Inteligencia de Negocio / CEO"])
def obtener_analitica_villarreal():
    """
    Calcula los 10 KPIs críticos operativos y financieros de los últimos 30 días
    cruzando información de db_eventos, db_autos, db_personal y db_inventario.
    """
    try:
        data_kpis = {}

        # 1️⃣ CIRCUITO: db_eventos (Órdenes Activas, Clientes y Gastos)
        with engine_eventos.connect() as conn:
            # Conteo de OPs activas (hoy o a futuro)
            data_kpis["ordenes_activas"] = conn.execute(text(
                "SELECT COUNT(*) FROM public.eventos WHERE CAST(fec_del_evento AS DATE) >= CURRENT_DATE"
            )).scalar() or 0

            # 5. Cliente líder en los últimos 30 días
            q_cli_top = text("""
                SELECT para_q_cliente, COUNT(*) as total 
                FROM public.eventos 
                WHERE fec_del_evento BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
                GROUP BY para_q_cliente ORDER BY total DESC LIMIT 1
            """)
            res_cli = conn.execute(q_cli_top).fetchone()
            data_kpis["cliente_top_30d"] = res_cli[0] if res_cli else "Sin eventos"

            # 8. Gastos pendientes por comprobar de los últimos 30 días
            q_gastos_pend = text("""
                SELECT e.id_evento, encode(e.nombre_evento::bytea, 'hex'), encode(e.resp_de_produccion::bytea, 'hex')
                FROM public.eventos e
                WHERE e.fec_del_evento BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
                  AND NOT EXISTS (
                      SELECT 1 FROM public.informes_gastos_maestro m WHERE m.folio_vpro = e.id_evento
                  )
                  AND EXISTS (
                      SELECT 1 FROM public.checkouts_maestro cm WHERE cm.folio_op = e.id_evento AND cm.estado_bodega = 'RECIBIDO'
                  )
                ORDER BY e.id_evento DESC
            """)
            res_gastos = conn.execute(q_gastos_pend).fetchall()
            data_kpis["gastos_pendientes_30d"] = [
                f"OP-{str(r[0]).zfill(3)} | {safe_decode_hex(r[1])} (Resp: {safe_decode_hex(r[2])})" 
                for r in res_gastos
            ]

        # 2️⃣ CIRCUITO: db_autos (Seguros Vencidos y Próximos 30 Días)
        with engine_autos.connect() as conn:
            q_seguros = text("""
                SELECT 
                    encode(num_control::bytea, 'hex'), 
                    encode(marca::bytea, 'hex'), 
                    encode(modelo::bytea, 'hex'), 
                    seguro_vence 
                FROM public.autos 
                WHERE seguro_vence < CURRENT_DATE + INTERVAL '30 days'
                ORDER BY seguro_vence ASC
            """)
            res_autos = conn.execute(q_seguros).fetchall()
            
            seguros_vencidos_list = []
            seguros_por_vencer_list = []
            hoy_dt = datetime.date.today()
            
            for r in res_autos:
                num_c = safe_decode_hex(r[0])
                marca = safe_decode_hex(r[1])
                modelo = safe_decode_hex(r[2])
                vence_date = r[3]
                
                msg_flota = f"🚙 Unidad {num_c}: {marca} {modelo} (Vence: {vence_date.strftime('%d/%m/%Y')})"
                
                if vence_date < hoy_dt:
                    seguros_vencidos_list.append(msg_flota)
                else:
                    seguros_por_vencer_list.append(msg_flota)
            
            data_kpis["seguros_vencidos"] = seguros_vencidos_list
            data_kpis["seguros_por_vencer"] = seguros_por_vencer_list

        # 3️⃣ CIRCUITO: db_inventario (Hardware Dañado e Incidencias de Proveedores)
        with engine_inventario.connect() as conn_inv: # 6 y 7. Hardware con más fallas (Últimos 30 días)
            q_hw_inc = text("""
                SELECT equipo_n_reparacion, COUNT(*) as fallas
                FROM public.reparaciones
                WHERE fecha_d_reporte BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
                GROUP BY equipo_n_reparacion ORDER BY fallas DESC LIMIT 2
            """)
            res_hw = conn_inv.execute(q_hw_inc).fetchall()
            data_kpis["equipos_mas_incidencias"] = [f"📦 {r[0]} ({r[1]} reportes)" for r in res_hw] if res_hw else ["Ninguno"]

            # 4. Proveedor externo con más reportes en taller
            q_prov_inc = text("""
                SELECT reportante, COUNT(*) as fallas
                FROM public.reparaciones
                WHERE fecha_d_reporte BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
                GROUP BY reportante ORDER BY fallas DESC LIMIT 1
            """)
            res_prov = conn_inv.execute(q_prov_inc).fetchone()
            data_kpis["proveedor_mas_incidencias"] = f"🚚 {res_prov[0]} ({res_prov[1]} fallas)" if res_prov else "Ninguno"

        # 4️⃣ CIRCUITO: db_personal (Auditoría de Asistencias, Retardos y Personal Limpio)
        with engine_personal.connect() as conn_p:
            # Conteo quincenal detallado de retardos (>14 mins tarde)
            q_retardos_15d = text("""
                SELECT encode(e.nombre::bytea, 'hex'), COUNT(*) as total_tardes
                FROM public.control_asistencia c
                JOIN public.empleados e ON TRIM(c.id_empleado) = TRIM(e.id_empleado)
                WHERE c.estatus = 'RETARDO' AND c.fecha BETWEEN CURRENT_DATE - INTERVAL '15 days' AND CURRENT_DATE
                GROUP BY e.nombre
                ORDER BY total_tardes DESC
            """)
            res_ret_15d = conn_p.execute(q_retardos_15d).fetchall()
            
            retardos_15d_list = [
                f"⏰ {safe_decode_hex(r[0])} ({r[1]} llegadas con >14 mins de retraso en la quincena)"
                for r in res_ret_15d
            ]
            data_kpis["retardos_15d_conteo"] = len(retardos_15d_list)
            data_kpis["retardos_15d_detalles"] = retardos_15d_list

            q_max_ret = text("""
                SELECT TRIM(c.id_empleado), COUNT(*) as total
                FROM public.control_asistencia c
                WHERE c.estatus = 'RETARDO' AND c.fecha BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
                GROUP BY TRIM(c.id_empleado) ORDER BY total DESC LIMIT 1
            """)
            res_max_ret = conn_p.execute(q_max_ret).fetchone()
            
            # Top estrellas más puntuales (Últimos 30 días)
            q_min_ret = text("""
                SELECT TRIM(c.id_empleado), COUNT(*) as total
                FROM public.control_asistencia c
                WHERE c.estatus = 'ASISTENCIA' AND c.fecha BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
                GROUP BY TRIM(c.id_empleado) ORDER BY total DESC LIMIT 3
            """)
            res_min_ret = conn_p.execute(q_min_ret).fetchall()

            # Traductor de IDs a nombres reales
            emp_rows = conn_p.execute(text("SELECT TRIM(id_empleado), encode(nombre::bytea, 'hex') FROM public.empleados")).fetchall()
            dict_nombres = {r[0]: safe_decode_hex(r[1]) for r in emp_rows}

            data_kpis["empleado_mas_retardos"] = f"👤 {dict_nombres.get(res_max_ret[0], 'ID: '+res_max_ret[0])} ({res_max_ret[1]} retardos)" if res_max_ret else "Sin retardos registrados"
            data_kpis["empleados_menos_retardos"] = [f"⭐ {dict_nombres.get(r[0], 'ID: '+r[0])} ({r[1]} a tiempo)" for r in res_min_ret] if res_min_ret else ["Sin marcas"]

            # 🛠️ RECUPERADO: 3. Empleados activos sin incidencias de puntualidad (Últimos 30 días)
            q_clean_staff = text("""
                SELECT encode(nombre::bytea, 'hex') FROM public.empleados 
                WHERE rol NOT IN ('BAJA', 'PROVEEDOR')
                  AND nombre NOT IN (
                      SELECT DISTINCT e.nombre FROM public.empleados e 
                      JOIN public.control_asistencia a ON TRIM(e.id_empleado) = TRIM(a.id_empleado)
                      WHERE a.estatus = 'RETARDO' AND a.fecha BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
                  ) LIMIT 4
            """)
            res_clean = conn_p.execute(q_clean_staff).fetchall()
            data_kpis["empleados_sin_incidencias"] = [safe_decode_hex(r[0]) for r in res_clean] if res_clean else ["No asignado"]

        # 🚀 RETORNO INTEGRAL EXITOSO
        return {"status": "SUCCESS", "kpis": data_kpis}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Fallo crítico en el motor analítico unificado: {str(e)}")

@app.get("/api/auth/empleados-lista", tags=["Seguridad"])           # 🔐 ENDPOINTS DE SEGURIDAD E IDENTIFICACIÓN (db_personal)
def obtener_lista_nombres_login():
    query = text("SELECT encode(nombre::bytea, 'hex'), encode(rol::bytea, 'hex'), encode(depto::bytea, 'hex') FROM public.empleados WHERE nombre IS NOT NULL")
    try:
        with engine_personal.connect() as conn: rows = conn.execute(query).fetchall()
        lista_filtrada = []
        for r in rows:
            nombre = safe_decode_hex(r[0])
            rol = safe_decode_hex(r[1]).strip().upper()
            depto = safe_decode_hex(r[2]).strip().lower()
            if rol not in ['BAJA', 'PROVEEDOR'] and 'externo' not in depto:
                lista_filtrada.append(nombre)
        lista_filtrada.sort()
        return lista_filtrada
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/auth/login", tags=["Seguridad"])
def autenticar_usuario(datos: LoginRequest):
    query = text("""
        SELECT encode(nombre::bytea, 'hex'), encode(depto::bytea, 'hex'), encode(password::bytea, 'hex'), 
               encode(rol::bytea, 'hex'), encode(id_empleado::bytea, 'hex'), encode(email::bytea, 'hex')
        FROM public.empleados
    """)
    try:
        with engine_personal.connect() as conn: rows = conn.execute(query).fetchall()
        target_user = datos.usuario.strip().lower()
        
        for row in rows:
            db_nombre = safe_decode_hex(row[0])
            if db_nombre.strip().lower() == target_user:
                db_password = safe_decode_hex(row[2]).strip()
                
                # 1. Pasamos por la aduana criptográfica
                if not verificar_password(datos.contrasena.strip(), db_password):
                    raise HTTPException(status_code=401, detail="Contraseña incorrecta.")
                
                # 2. Bandera inteligente: ¿Es una contraseña temporal de un solo uso?
                requiere_cambio = False
                clave_ingresada = datos.contrasena.strip()
                if not db_password.startswith("$2b$") or clave_ingresada == "vpro123" or clave_ingresada.startswith("VPRO-"):
                    requiere_cambio = True
                
                return {
                    "autenticado": True, "nombre_completo": db_nombre,
                    "rol": safe_decode_hex(row[3]).strip().upper(), "depto": safe_decode_hex(row[1]),
                    "id_empleado": safe_decode_hex(row[4]).strip(), "email": safe_decode_hex(row[5]).strip(),
                    "requiere_cambio": requiere_cambio # 🚩 El semáforo para Streamlit
                }
        raise HTTPException(status_code=401, detail="El empleado no se encuentra registrado.")
    except HTTPException as he: raise he
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/auth/cambiar-password", tags=["Seguridad"])
def cambiar_password(payload: CambioPasswordPayload):
    """Toma la contraseña segura, la encripta y quema el boleto viejo"""
    pass_encriptada = encriptar_password(payload.nueva_contrasena.strip())
    query = text("UPDATE public.empleados SET password = :hash WHERE TRIM(id_empleado) = :id")
    try:
        with engine_personal.begin() as conn: 
            conn.execute(query, {"hash": pass_encriptada, "id": payload.id_empleado.strip()})
        return {"status": "SUCCESS"}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))
        
@app.get("/api/empleados/{id_empleado}/qr", tags=["🦺 Gestión Personal"])           # 🪪 MÓDULO GENERADOR DE CÓDIGOS QR (db_personal)
def generar_codigo_qr_empleado(id_empleado: str):
    """
    Busca al empleado en Postgres y genera su código QR oficial 
    en formato Base64 listo para ser renderizado por Streamlit.
    """
    query_verificar = text("SELECT encode(nombre::bytea, 'hex') FROM public.empleados WHERE TRIM(id_empleado) = :id")
    try:
        with engine_personal.connect() as conn:
            row = conn.execute(query_verificar, {"id": id_empleado.strip()}).first()
        
        if not row:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, 
                detail="El ID de empleado no existe en el sistema VPRO."
            )
            
        nombre_empleado = safe_decode_hex(row[0])
        
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        qr.add_data(id_empleado.strip())
        qr.make(fit=True)
        
        img = qr.make_image(fill_color="black", back_color="white")
        
        buffer = BytesIO()
        img.save(buffer, format="PNG")
        qr_base64 = base64.b64encode(buffer.getvalue()).decode("utf-8")
        
        return {
            "status": "SUCCESS",
            "id_empleado": id_empleado.strip(),
            "nombre": nombre_empleado,
            "qr_base64": f"data:image/png;base64,{qr_base64}"
        }
        
    except HTTPException as he: raise he
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/empleados", tags=["🦺 Gestión Personal"])            # 🦺 ENDPOINTS GESTIÓN DE PERSONAL (db_personal)
def listar_empleados_completos():
    query = text("""
        SELECT encode(id_empleado::bytea, 'hex'), encode(nombre::bytea, 'hex'), encode(depto::bytea, 'hex'), encode(rol::bytea, 'hex'), 
               licencia_vence, encode(email::bytea, 'hex'), fecha_nac, fecha_ing, encode(password::bytea, 'hex')
        FROM public.empleados ORDER BY id_empleado ASC
    """)
    try:
        with engine_personal.connect() as conn: result = conn.execute(query).fetchall()
        return [{"id_empleado": safe_decode_hex(r[0]), "nombre": safe_decode_hex(r[1]), "depto": safe_decode_hex(r[2]), "rol": safe_decode_hex(r[3]), "licencia_vence": r[4], "email": safe_decode_hex(r[5]), "fecha_nac": r[6], "fecha_ing": r[7], "password": safe_decode_hex(r[8])} for r in result]
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/empleados/guardar", tags=["🦺 Gestión Personal"])
def guardar_o_actualizar_empleado(empleado: dict):
    query = text("""
        INSERT INTO public.empleados (id_empleado, nombre, depto, rol, licencia_vence, email, password, fecha_nac, fecha_ing) 
        VALUES (:id_empleado, :nombre, :depto, :rol, :licencia_vence, :email, :password, :fecha_nac, :fecha_ing) 
        ON CONFLICT (id_empleado) DO UPDATE SET nombre=EXCLUDED.nombre, depto=EXCLUDED.depto, rol=EXCLUDED.rol, licencia_vence=EXCLUDED.licencia_vence, email=EXCLUDED.email, password=EXCLUDED.password, fecha_nac=EXCLUDED.fecha_nac, fecha_ing=EXCLUDED.fecha_ing;
    """)
    try:
        with engine_personal.begin() as conn: conn.execute(query, empleado)
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/empleados/eliminar/{id_empleado}", tags=["🦺 Gestión Personal"])
def eliminar_empleado(id_empleado: str):
    query = text("DELETE FROM public.empleados WHERE id_empleado = :id")
    try:
        with engine_personal.begin() as conn: conn.execute(query, {"id": id_empleado.strip()})
        return {"status": "DELETED"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/asistencia/status/{id_empleado}", tags=["🕒 Checador Asistencia"])
def extraer_estado_asistencia_diaria(id_empleado: str):
    import datetime as dt_module
    ahora = dt_module.datetime.now(dt_module.timezone.utc) - dt_module.timedelta(hours=7)
    hoy_str = ahora.strftime('%Y-%m-%d')
    
    query = text("""
        SELECT id_registro, hora_entrada, hora_salida, estatus, observaciones 
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
                "estatus": row["estatus"], 
                "observaciones": row["observaciones"],
                "completo": row["hora_salida"] is not None  # 👈 Bandera crítica: Indica si el turno previo ya cerró
            }
        return {"registrado": False, "completo": False}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/asistencia/checar", tags=["🕒 Checador Asistencia"])
def registrar_tarjetazo_asistencia(payload: ChecadaPayload):
    import datetime as dt_module
    
    # ⏱️ 1. Calculamos la hora de Sinaloa limpiecita y sin conflictos
    ahora = dt_module.datetime.now(dt_module.timezone.utc).replace(tzinfo=None) - dt_module.timedelta(hours=7)
    hoy_str = ahora.strftime('%Y-%m-%d')
    hora_str = ahora.strftime('%H:%M:%S')

    # 🛠️ 2. DESFIBRILADOR AISLADO: Lo corremos en su propia conexión para que NO rompa nada si falla
    try:
        with engine_personal.connect() as conn_seq:
            conn_seq.execute(text("SELECT setval(pg_get_serial_sequence('public.control_asistencia', 'id_registro'), COALESCE(MAX(id_registro), 0) + 1, false) FROM public.control_asistencia;"))
            conn_seq.commit()
    except:
        pass # Si la tabla no lo necesita, lo ignora en silencio y sigue fluyendo

    # 💾 3. TRANSACCIÓN PRINCIPAL (Ahora sí, 100% segura)
    try:
        with engine_personal.begin() as conn:
            if payload.tipo_movimiento.upper() == "ENTRADA": 
                duplicado = conn.execute(text("""
                    SELECT 1 FROM public.control_asistencia 
                    WHERE TRIM(id_empleado) = :emp AND fecha = CAST(:hoy AS date) AND hora_salida IS NULL
                """), {"emp": payload.id_empleado.strip(), "hoy": hoy_str}).scalar()
                
                if duplicado: 
                    raise HTTPException(status_code=400, detail="Ya tienes un turno abierto. Registra tu salida primero.")
                
                conn.execute(text("""
                    INSERT INTO public.control_asistencia (id_empleado, fecha, hora_entrada, estatus, observaciones)
                    VALUES (:emp, CAST(:hoy AS date), CAST(:hora AS time), :est, :obs)
                """), {"emp": payload.id_empleado.strip(), "hoy": hoy_str, "hora": hora_str, "est": payload.estatus, "obs": payload.observaciones})
            else:
                id_reg = conn.execute(text("""
                    SELECT id_registro FROM public.control_asistencia 
                    WHERE TRIM(id_empleado) = :emp AND fecha = CAST(:hoy AS date) AND hora_salida IS NULL
                    ORDER BY id_registro DESC LIMIT 1
                """), {"emp": payload.id_empleado.strip(), "hoy": hoy_str}).scalar()
                
                if not id_reg: 
                    raise HTTPException(status_code=400, detail="No tienes un turno activo abierto para registrar salida.")
                
                conn.execute(text("""
                    UPDATE public.control_asistencia 
                    SET hora_salida = CAST(:hora AS time), observaciones = observaciones || ' | Salida: ' || :obs
                    WHERE id_registro = :id
                """), {"id": id_reg, "hora": hora_str, "obs": payload.observaciones})
        return {"status": "SUCCESS"}
    except HTTPException as he: raise he
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/api/asistencia/reporte", tags=["🕒 Checador Asistencia"])
def obtener_reporte_asistencia_global():
    """Extrae la bitácora completa de asistencias para el panel de Auditoría y Analítica"""
    query = text("""
        SELECT c.id_registro, c.fecha, TRIM(c.id_empleado), encode(e.nombre::bytea, 'hex') as nombre_empleado, 
               encode(e.depto::bytea, 'hex') as depto, c.hora_entrada, c.hora_salida, c.estatus, c.observaciones
        FROM public.control_asistencia c
        LEFT JOIN public.empleados e ON TRIM(c.id_empleado) = TRIM(e.id_empleado)
        ORDER BY c.fecha DESC, c.hora_entrada DESC
    """)
    try:
        with engine_personal.connect() as conn:
            rows = conn.execute(query).fetchall()
        return [{
            "id_registro": r[0],
            "fecha": str(r[1]),
            "id_empleado": r[2],
            "nombre_empleado": safe_decode_hex(r[3]) if r[3] else "Desconocido",
            "depto": safe_decode_hex(r[4]) if r[4] else "N/A",
            "hora_entrada": str(r[5]) if r[5] else None,
            "hora_salida": str(r[6]) if r[6] else None,
            "estatus": r[7],
            "observaciones": r[8]
        } for r in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/api/inventario-kits/completo", tags=["🛠️ Inventario General"])           # 🌟 ENDPOINT CLÍNICO ACTUALIZADO: Ahora también extrae la columna de observaciones nativa
def obtener_inventario_kits_completo():
    query = text("""
        SELECT DISTINCT ON (codigo_inv_kits) 
            encode(codigo_inv_kits::bytea, 'hex'), 
            encode(descripcion_inv_kits::bytea, 'hex'), 
            encode(responsable_inv_kits::bytea, 'hex'), 
            encode(estado_inv_kits::bytea, 'hex'),
            encode(observaciones_inv_kits::bytea, 'hex')
        FROM public.inventario_kits
        WHERE codigo_inv_kits IS NOT NULL AND codigo_inv_kits != ''
        ORDER BY codigo_inv_kits ASC
    """)
    try:
        with engine_inventario.connect() as conn: rows = conn.execute(query).fetchall()
        return [{
            "codigo": safe_decode_hex(r[0]),
            "descripcion": safe_decode_hex(r[1]),
            "responsable": safe_decode_hex(r[2]) if r[2] else "Sin asignar",
            "estado": safe_decode_hex(r[3]) if r[3] else "Buen Estado",
            "observaciones": safe_decode_hex(r[4]) if r[4] else ""
        } for r in rows]
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/inventario-kits/guardar", tags=["🛠️ Inventario General"])           # 🚀 NUEVO ENDPOINT COMPUETA: Permite actualizar salud y notas de kits individuales en Postgres
def guardar_o_actualizar_kit_item(item: dict):
    query = text("""
        UPDATE public.inventario_kits 
        SET estado_inv_kits = :estado, observaciones_inv_kits = :observaciones
        WHERE codigo_inv_kits = :codigo
    """)
    try:
        with engine_inventario.begin() as conn:
            conn.execute(query, {
                "codigo": str(item.get("codigo")).strip(),
                "estado": str(item.get("estado")).strip(),
                "observaciones": str(item.get("observaciones", ""))
            })
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/api/inventario-kits/lista", tags=["🛠️ Inventario General"])          # 🌟 NUEVA RUTA INTEGRADA: Extrae el inventario alterno y limpio directo de los kits
def listar_inventario_kits_base():
    query = text("""
        SELECT DISTINCT encode(codigo_inv_kits::bytea, 'hex'), encode(descripcion_inv_kits::bytea, 'hex') 
        FROM public.inventario_kits 
        WHERE codigo_inv_kits IS NOT NULL AND codigo_inv_kits != ''
        ORDER BY encode(codigo_inv_kits::bytea, 'hex') ASC
    """)
    try:
        with engine_inventario.connect() as conn: rows = conn.execute(query).fetchall()
        return [{"codigo": safe_decode_hex(r[0]), "descripcion": safe_decode_hex(r[1])} for r in rows]
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

# Definimos la estructura que espera recibir el endpoint desde tu lector QR
class RegistroAsistenciaSchema(BaseModel):
    id_empleado: str

@app.post("/asistencia/registrar")
def registrar_asistencia(datos: RegistroAsistenciaSchema):
    import datetime as dt_module
    
    # ⏱️ Calculamos la hora exacta
    ahora = dt_module.datetime.now(dt_module.timezone.utc).replace(tzinfo=None) - dt_module.timedelta(hours=7)
    hoy_str = ahora.strftime('%Y-%m-%d')
    hora_str = ahora.strftime('%H:%M:%S')
    
    # 🔍 Buscamos si ya hay un registro HOY para este empleado
    query_buscar = text("""
        SELECT id_registro, hora_entrada, hora_salida, hora_entrada_v, hora_salida_v 
        FROM public.control_asistencia 
        WHERE TRIM(id_empleado) = :emp AND fecha = CAST(:hoy AS date)
        ORDER BY id_registro DESC LIMIT 1
    """)

    try:
        with engine_personal.connect() as conn_check:
            registro_hoy = conn_check.execute(query_buscar, {"emp": datos.id_empleado.strip(), "hoy": hoy_str}).mappings().first()

        with engine_personal.begin() as conn:
            # 1️⃣ NO HAY REGISTRO HOY: Creamos fila y ponemos Entrada Matutina
            if not registro_hoy:
                conn.execute(text("""
                    INSERT INTO public.control_asistencia (id_empleado, fecha, hora_entrada, estatus, observaciones)
                    VALUES (:emp, CAST(:hoy AS date), CAST(:hora AS time), 'ASISTENCIA', 'Checada Lector USB - Turno Matutino (Entrada)')
                """), {"emp": datos.id_empleado.strip(), "hoy": hoy_str, "hora": hora_str})
                return {"status": "ok", "mensaje": "✅ ENTRADA MATUTINA REGISTRADA"}

            # Si ya existe, guardamos su ID para actualizar esa misma fila
            id_reg = registro_hoy["id_registro"]

            # 2️⃣ HAY ENTRADA MATUTINA PERO NO SALIDA: Ponemos Salida Matutina
            if registro_hoy["hora_entrada"] is not None and registro_hoy["hora_salida"] is None:
                conn.execute(text("""
                    UPDATE public.control_asistencia 
                    SET hora_salida = CAST(:hora AS time), observaciones = observaciones || ' | (Salida a comer)'
                    WHERE id_registro = :id_reg
                """), {"hora": hora_str, "id_reg": id_reg})
                return {"status": "ok", "mensaje": "✅ SALIDA MATUTINA REGISTRADA"}

            # 3️⃣ YA SALIÓ A COMER, PERO NO HA ENTRADO EN LA TARDE: Ponemos Entrada Vespertina
            elif registro_hoy["hora_salida"] is not None and registro_hoy.get("hora_entrada_v") is None:
                conn.execute(text("""
                    UPDATE public.control_asistencia 
                    SET hora_entrada_v = CAST(:hora AS time), observaciones = observaciones || ' | Turno Vespertino (Entrada)'
                    WHERE id_registro = :id_reg
                """), {"hora": hora_str, "id_reg": id_reg})
                return {"status": "ok", "mensaje": "✅ ENTRADA VESPERTINA REGISTRADA"}

            # 4️⃣ YA ENTRÓ EN LA TARDE, PERO NO HA SALIDO: Ponemos Salida Vespertina
            elif registro_hoy.get("hora_entrada_v") is not None and registro_hoy.get("hora_salida_v") is None:
                conn.execute(text("""
                    UPDATE public.control_asistencia 
                    SET hora_salida_v = CAST(:hora AS time), estatus = 'COMPLETO', observaciones = observaciones || ' | (Salida Final)'
                    WHERE id_registro = :id_reg
                """), {"hora": hora_str, "id_reg": id_reg})
                return {"status": "ok", "mensaje": "✅ SALIDA FINAL REGISTRADA"}

            # 5️⃣ YA LLENÓ LAS 4 COLUMNAS: Día terminado
            else:
                raise HTTPException(status_code=400, detail="Tranquilo viejo, ya completaste tus dos turnos de hoy.")

    except HTTPException as he: 
        raise he
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/autos", tags=["🚙 Control Vehicular"])           # 🚙 ENDPOINTS GESTIÓN VEHICULAR (db_autos)
def listar_autos():
    query = text("""
        SELECT encode(num_control::bytea, 'hex'), encode(marca::bytea, 'hex'), encode(modelo::bytea, 'hex'), encode(serie::bytea, 'hex'), 
               fecha_compra, encode(estado_actual::bytea, 'hex'), encode(servicios_hechos::bytea, 'hex'), encode(observaciones_comentarios::bytea, 'hex'), 
               seguro_vence, mantenimiento_fecha 
        FROM public.autos ORDER BY num_control ASC
    """)
    try:
        with engine_autos.connect() as conn: result = conn.execute(query).fetchall()
        return [{"num_control": safe_decode_hex(r[0]), "marca": safe_decode_hex(r[1]), "modelo": safe_decode_hex(r[2]), "serie": safe_decode_hex(r[3]), "fecha_compra": r[4], "estado_actual": safe_decode_hex(r[5]), "servicios_hechos": safe_decode_hex(r[6]), "observaciones_comentarios": safe_decode_hex(r[7]), "seguro_vence": r[8], "mantenimiento_fecha": r[9]} for r in result]
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/autos/guardar", tags=["🚙 Control Vehicular"])
def guardar_o_actualizar_auto(auto: dict):
    query_upsert = text("""
        INSERT INTO public.autos (num_control, marca, modelo, serie, fecha_compra, estado_actual, servicios_hechos, observaciones_comentarios, seguro_vence, mantenimiento_fecha)
        VALUES (:num_control, :marca, :modelo, :serie, :fecha_compra, :estado_actual, :servicios_hechos, :observaciones_comentarios, :seguro_vence, :mantenimiento_fecha)
        ON CONFLICT (num_control) DO UPDATE SET marca = EXCLUDED.marca, modelo = EXCLUDED.modelo, serie = EXCLUDED.serie, fecha_compra = EXCLUDED.fecha_compra, estado_actual = EXCLUDED.estado_actual, servicios_hechos = EXCLUDED.servicios_hechos, observaciones_comentarios = EXCLUDED.observaciones_comentarios, seguro_vence = EXCLUDED.seguro_vence, mantenimiento_fecha = EXCLUDED.mantenimiento_fecha;
    """)
    try:
        with engine_autos.begin() as conn: conn.execute(query_upsert, auto)
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/autos/eliminar/{num_control}", tags=["🚙 Control Vehicular"])
def eliminar_auto(num_control: str):
    query = text("DELETE FROM public.autos WHERE num_control = :id")
    try:
        with engine_autos.begin() as conn: conn.execute(query, {"id": num_control.strip()})
        return {"status": "DELETED"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/proveedores", tags=["🚚 Gestión Proveedores"])           # 🚚 ENDPOINTS CATÁLOGO PROVEEDORES (db_proveedores)
def listar_proveedores():
    select_query = text("""
        SELECT encode(nombre_del_proveedor::bytea, 'hex'), encode(gte_gral::bytea, 'hex'), encode(estado::bytea, 'hex'), encode(ciudad::bytea, 'hex'), encode(tel_de_ofna::bytea, 'hex'), encode(email_de_empresa::bytea, 'hex'), encode(nombre_contacto_princ::bytea, 'hex'), encode(cel_contact_princ::bytea, 'hex'), encode(nombre_contacto_a::bytea, 'hex'), encode(cel_contact_a::bytea, 'hex')
        FROM public.proveedores ORDER BY nombre_del_proveedor ASC
    """)
    try:
        with engine_proveedores.connect() as conn: result = conn.execute(select_query).fetchall()
        return [{"nombre_del_proveedor": safe_decode_hex(r[0]), "gte_gral": safe_decode_hex(r[1]), "estado": safe_decode_hex(r[2]), "ciudad": safe_decode_hex(r[3]), "tel_de_ofna": safe_decode_hex(r[4]), "email_de_empresa": safe_decode_hex(r[5]), "nombre_contacto_princ": safe_decode_hex(r[6]), "cel_contact_princ": safe_decode_hex(r[7]), "nombre_contacto_a": safe_decode_hex(r[8]), "cel_contact_a": safe_decode_hex(r[9])} for r in result]
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/proveedores/guardar", tags=["🚚 Gestión Proveedores"])
def guardar_o_actualizar_proveedor(prov: dict):
    query = text("""
        INSERT INTO public.proveedores (nombre_del_proveedor, gte_gral, estado, city, tel_de_ofna, email_de_empresa, nombre_contacto_princ, cel_contact_princ, nombre_contacto_a, cel_contact_a)
        VALUES (:nombre_del_proveedor, :gte_gral, :estado, :ciudad, :tel_de_ofna, :email_de_empresa, :nombre_contacto_princ, :cel_contact_princ, :nombre_contacto_a, :cel_contact_a)
        ON CONFLICT (nombre_del_proveedor) DO UPDATE SET gte_gral=EXCLUDED.gte_gral, estado=EXCLUDED.estado, city=EXCLUDED.city, tel_de_ofna=EXCLUDED.tel_de_ofna, email_de_empresa=EXCLUDED.email_de_empresa, nombre_contacto_princ=EXCLUDED.nombre_contacto_princ, cel_contact_princ=EXCLUDED.cel_contact_princ, nombre_contacto_a=EXCLUDED.nombre_contacto_a, cel_contact_a=EXCLUDED.cel_contact_a;
    """)
    try:
        with engine_proveedores.begin() as conn: conn.execute(query, prov)
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/proveedores/eliminar/{nombre}", tags=["🚚 Gestión Proveedores"])
def eliminar_proveedor(nombre: str):
    query = text("DELETE FROM public.proveedores WHERE nombre_del_proveedor = :nombre")
    try:
        with engine_proveedores.begin() as conn: conn.execute(query, {"nombre": nombre.strip()})
        return {"status": "DELETED"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/inventario", tags=["🛠️ Inventario General"])         # 🛠️ ENDPOINTS INVENTARIO GENERAL (db_inventario)
def listar_inventario():
    query = text("""
        SELECT encode(codigo::bytea, 'hex'), encode(responsiva::bytea, 'hex'), encode(fecha_compra::bytea, 'hex'), encode(descripcion::bytea, 'hex'), encode(marca::bytea, 'hex'), encode(modelo::bytea, 'hex'), encode(serie::bytea, 'hex'), encode(responsable::bytea, 'hex'), encode(estado::bytea, 'hex'), encode(ubicacion::bytea, 'hex'), encode(observaciones::bytea, 'hex')
        FROM public.inventario ORDER BY codigo ASC
    """)
    try:
        with engine_inventario.connect() as conn: result = conn.execute(query).fetchall()
        return [{"codigo": safe_decode_hex(r[0]), "responsiva": safe_decode_hex(r[1]), "fecha_compra": safe_decode_hex(r[2]), "descripcion": safe_decode_hex(r[3]), "marca": safe_decode_hex(r[4]), "modelo": safe_decode_hex(r[5]), "serie": safe_decode_hex(r[6]), "responsable": safe_decode_hex(r[7]), "estado": safe_decode_hex(r[8]), "ubicacion": safe_decode_hex(r[9]), "observaciones": safe_decode_hex(r[10])} for r in result]
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

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
    query = text("""
        INSERT INTO public.historial_equipo 
            (codigo_equipo, fecha, folio_vpro, id_empleado, tipo_evento, descripcion, costo_asociado, estado_final, departamento)
        VALUES 
            (:codigo_equipo, CURRENT_DATE, :folio_vpro, :id_empleado, :tipo_evento, :descripcion, :costo_asociado, :estado_final, :departamento)
    """)
    try:
        with engine_inventario.begin() as conn: 
            cod_eq = str(log.get("codigo_equipo", "")).strip().upper()
            est_final = str(log.get("estado_final", "PENDIENTE")).strip().upper()
            
            # 1. Guardamos la bitácora en la Caja Negra (Historial)
            conn.execute(query, {
                "codigo_equipo": cod_eq,
                "folio_vpro": str(log.get("folio_vpro", "MANTENIMIENTO_INTERNO")).strip(),
                "id_empleado": str(log.get("id_empleado", "")).strip(),
                "tipo_evento": str(log.get("tipo_evento", "MANTENIMIENTO_TÉCNICO")).strip(),
                "descripcion": str(log.get("descripcion", "")).strip(),
                "costo_asociado": float(log.get("costo_asociado", 0.0)),
                "estado_final": est_final,
                "departamento": str(log.get("departamento", "OFICINA")).strip()
            })
            
            # 🔗 TRAZABILIDAD 360: CONEXIÓN AUTOMÁTICA AL PANEL CEO Y AL INVENTARIO MAESTRO
            # CASO A: El equipo de oficina está dañado / En Taller
            if est_final in ["PENDIENTE", "EN TALLER", "DAÑADO", "DANADO", "BAJA"]:
                if cod_eq.startswith("INV_VPRO_ALT_"): # 1. Pintamos el inventario de rojo para que nadie lo pueda pedir
                    conn.execute(text("UPDATE public.inventario_kits SET estado_inv_kits = 'DANADO' WHERE codigo_inv_kits = :cod"), {"cod": cod_eq})
                else:
                    conn.execute(text("UPDATE public.inventario SET estado = 'DAÑADO' WHERE codigo = :cod"), {"cod": cod_eq})
                
                # 2. Generamos el Ticket de Urgencias en el Panel de Taller (CEO)
                if est_final != "BAJA": # Si es baja, ya murió, no va al taller.
                    import time
                    ticket_urgencia = f"REP-INT-{int(time.time())}" # Genera un folio único
                    
                    conn.execute(text("""
                        INSERT INTO public.reparaciones 
                            (num_d_servicio, equipo_n_reparacion, reportante, descripcion_del_dano, estado_actual, costo_d_reparacion, fecha_d_reporte, area_q_pertenece, folio_vpro) 
                        VALUES 
                            (:num_serv, :eq, 'Reporte Interno (Oficina/Bodega)', :desc, '⚙️ EN REPARACIÓN', :costo, CURRENT_DATE, :depto, :fol)
                    """), {
                        "num_serv": ticket_urgencia,
                        "eq": cod_eq,
                        "desc": str(log.get("descripcion", "")).strip(),
                        "costo": float(log.get("costo_asociado", 0.0)),
                        "depto": str(log.get("departamento", "OFICINA")).strip(),
                        "fol": str(log.get("folio_vpro", "MANTENIMIENTO_INTERNO")).strip()
                    })
            
            # CASO B: El equipo fue reparado (Resolución exitosa)
            elif est_final in ["RESUELTO", "OK", "BUEN ESTADO"]:
                if cod_eq.startswith("INV_VPRO_ALT_"): # Lo regresamos a verde en el catálogo para que pueda volver a usarse
                    conn.execute(text("UPDATE public.inventario_kits SET estado_inv_kits = 'BUEN ESTADO' WHERE codigo_inv_kits = :cod"), {"cod": cod_eq})
                else:
                    conn.execute(text("UPDATE public.inventario SET estado = 'OK' WHERE codigo = :cod"), {"cod": cod_eq})

        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/inventario/radar-danos", tags=["🛠️ Inventario General"])         # 🚩 RADAR BODEGA DE EQUIPOS DAÑADOS (UNIFICADO: INCISOS 1, 2 Y 3)
def extraer_radar_equipos_danados(user_id: str, rol: str, nombre_usuario: str):
    try:
        nombre_upper = nombre_usuario.upper().strip()
        es_admin_o_productor = "AGUNDEZ" in nombre_upper or "VILLARREAL" in nombre_upper or rol.upper() == "PRODUCTOR"
        
        if es_admin_o_productor:            # 🛡️ CONFIGURACIÓN DE FILTROS SEGUROS POR ROL PARA CADA INCISO
            filtro_rol_kits = "1=1"
            filtro_rol_master = "1=1"
            filtro_rol_eventos = "1=1"
        else:
            filtro_rol_kits = f"TRIM(h.id_empleado_ref_inv_kits) = '{user_id.strip()}'"
            filtro_rol_master = f"TRIM(h.responsable) = '{user_id.strip()}'"
            # 👇 CORRECCIÓN 1: Se corrigió id_sujeto_a_revisar por id_empleado
            filtro_rol_eventos = f"TRIM(m.id_empleado::text) = '{user_id.strip()}'"

        data_final = []
        mapa_descripciones = {}

        with engine_personal.connect() as conn_p:           # 📂 PASO 1: GENERAR EL MAPA GLOBAL DE PERSONAL Y TRADUCTOR DE HARDWARE
            rows_p = conn_p.execute(text("SELECT TRIM(id_empleado), encode(nombre::bytea, 'hex'), encode(depto::bytea, 'hex') FROM public.empleados")).fetchall()
        mapa_personal = {r[0]: {"nombre": safe_decode_hex(r[1]), "depto": safe_decode_hex(r[2])} for r in rows_p}

        with engine_inventario.connect() as conn_inv:           # Jalamos descripciones de Kits Alternos
            rows_desc_kits = conn_inv.execute(text("SELECT encode(codigo_inv_kits::bytea, 'hex'), encode(descripcion_inv_kits::bytea, 'hex') FROM public.inventario_kits")).fetchall()
            for r in rows_desc_kits:
                mapa_descripciones[safe_decode_hex(r[0]).strip()] = safe_decode_hex(r[1]).strip()
            
            rows_desc_master = conn_inv.execute(text("SELECT encode(codigo::bytea, 'hex'), encode(descripcion::bytea, 'hex') FROM public.inventario")).fetchall()            # Jalamos descripciones del Catálogo Maestro
            for r in rows_desc_master:
                mapa_descripciones[safe_decode_hex(r[0]).strip()] = safe_decode_hex(r[1]).strip()

        try:            # 📥 INCISO 1: DAÑOS DESDE EL RETORNO (db_eventos -> checkouts_detalle)
            # 👇 CORRECCIÓN 2: Se corrigió el SELECT por m.id_empleado y m.fecha
            query_eventos = text(f"""
                SELECT encode(d.codigo_equipo::bytea, 'hex'),
                       encode(COALESCE(d.notas_regreso, d.incidencias)::bytea, 'hex'),
                       encode(m.id_empleado::text::bytea, 'hex'),
                       m.fecha
                FROM public.checkouts_detalle d
                JOIN public.checkouts_maestro m ON d.id_maestro = m.id_maestro
                WHERE ((d.incidencias IS NOT NULL AND d.incidencias NOT ILIKE 'Sin incidencia%' AND d.incidencias != '')
                   OR (d.notas_regreso IS NOT NULL AND d.notas_regreso NOT IN ('', 'None', 'null', '[null]')))
                   AND {filtro_rol_eventos}
            """)
            with engine_eventos.connect() as conn_ev:
                rows_ev = conn_ev.execute(query_eventos).fetchall()
                
            for r in rows_ev:
                cod_eq = safe_decode_hex(r[0]).strip()
                falla = safe_decode_hex(r[1]).strip()
                emp_ref = safe_decode_hex(r[2]).strip()
                
                emp_info = mapa_personal.get(emp_ref, {"nombre": "Coordinador de Ruta", "depto": "PRODUCCIÓN"})
                nombre_eq = mapa_descripciones.get(cod_eq, f"Equipo de Ruta ({cod_eq})")
                fecha_rep = str(r[3]) if r[3] else str(date.today())
                
                data_final.append({
                    "ID": cod_eq, "EQUIPO": nombre_eq, "ESTADO_INV": "DAGNADO", "FALLA": falla,
                    "REPORTÓ": emp_info["nombre"], "DEPARTAMENTO": emp_info["depto"].upper(),
                    "FOLIO_TALLER": "Reporte en Check-in (Ruta)", "FECHA_REPORTE": fecha_rep
                })
        except Exception as ex_ev:
            logging.warning(f"⚠️ Alerta: No se pudo mapear el Inciso 1 (Checkouts): {ex_ev}")

        try:            # 🛠️ INCISO 2: DAÑOS DESDE EL CATÁLOGO MAESTRO (db_inventario -> inventario)
            query_master = text(f"""
                SELECT encode(h.codigo::bytea, 'hex'),
                       encode(h.descripcion::bytea, 'hex'),
                       encode(h.observaciones::bytea, 'hex'),
                       encode(h.responsable::text::bytea, 'hex')
                FROM public.inventario h
                WHERE (h.estado NOT ILIKE 'Bien' 
                   OR (h.observaciones IS NOT NULL AND h.observaciones NOT IN ('', 'None', 'none', 'null', '[null]', '')))
                   AND {filtro_rol_master}
            """)
            with engine_inventario.connect() as conn_inv:
                rows_master = conn_inv.execute(query_master).fetchall()
                
            for r in rows_master:
                falla = safe_decode_hex(r[2]).strip()
                if not falla or falla.lower() in ['none', 'null', 'n/a', 'na', '[null]']: continue
                
                cod_eq = safe_decode_hex(r[0]).strip()
                emp_ref = safe_decode_hex(r[3]).strip()
                
                if emp_ref.endswith('.0'):
                    emp_ref = emp_ref.split('.')[0]
                
                emp_info = mapa_personal.get(emp_ref, {"nombre": "Administrador Bodega", "depto": "LOGÍSTICA"})
                
                data_final.append({
                    "ID": cod_eq, "EQUIPO": safe_decode_hex(r[1]).strip(), "ESTADO_INV": "DAGNADO", "FALLA": falla,
                    "REPORTÓ": emp_info["nombre"], "DEPARTAMENTO": emp_info["depto"].upper(),
                    "FOLIO_TALLER": "Activo Fijo (Revisión Bodega)", "FECHA_REPORTE": str(date.today())
                })
        except Exception as ex_ma:
            logging.warning(f"⚠️ Alerta: No se pudo mapear el Inciso 2 (Master Inventory): {ex_ma}")

        query_inv = text(f"""
            SELECT encode(h.codigo_inv_kits::bytea, 'hex'), 
                   encode(h.descripcion_inv_kits::bytea, 'hex'), 
                   encode(h.observaciones_inv_kits::bytea, 'hex'), 
                   encode(h.id_empleado_ref_inv_kits::bytea, 'hex'), 
                   encode(r.num_d_servicio::bytea, 'hex'),
                   h.fecha_registro_inv_kits
            FROM public.inventario_kits h
            LEFT JOIN public.reparaciones r ON h.codigo_inv_kits = r.equipo_n_reparacion 
                AND r.estado_actual NOT IN ('Cerrado', 'Baja')
            WHERE h.observaciones_inv_kits IS NOT NULL 
            AND {filtro_rol_kits}
        """)
        
        with engine_inventario.connect() as conn_inv: 
            rows_inv = conn_inv.execute(query_inv).fetchall()
            
        for r in rows_inv:
            falla = safe_decode_hex(r[2]).strip()
            if not falla or falla.lower() in ['none', 'null', 'n/a', 'na', '[null]', '']: continue
                
            emp_ref = safe_decode_hex(r[3]).strip()
            emp_info = mapa_personal.get(emp_ref, {"nombre": "Sistema/Bodega", "depto": "BODEGA CENTRAL"})
            fecha_final = str(r[5].date()) if r[5] else str(date.today())
            
            data_final.append({
                "ID": safe_decode_hex(r[0]),
                "EQUIPO": safe_decode_hex(r[1]),
                "ESTADO_INV": "DAGNADO",
                "FALLA": falla,
                "REPORTÓ": emp_info["nombre"],
                "DEPARTAMENTO": emp_info["depto"].upper(),
                "FOLIO_TALLER": safe_decode_hex(r[4]) if r[4] else "Bodega Central (En Espera)",
                "FECHA_REPORTE": fecha_final
            })

        return sorted(data_final, key=lambda x: x["FECHA_REPORTE"], reverse=True)           # Regresar la lista unificada ordenada por fecha más reciente

    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/clientes", tags=["🏢 Gestión Clientes"])         # 🏢 ENDPOINTS CONTROL DE CLIENTES
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

@app.get("/api/eventos/catalogos", tags=["📝 Órdenes Producción"])          # 📝 ENDPOINTS CENTRALIZADOS DE ORDENES DE PRODUCCIÓN (db_eventos)
def extraer_catalogos_de_apoyo():
    try:
        with engine_autos.connect() as conn:
            autos = conn.execute(text("SELECT encode(marca::bytea,'hex'), encode(modelo::bytea,'hex') FROM public.autos")).fetchall()
        lista_autos = [f"{safe_decode_hex(a[0])} {safe_decode_hex(a[1])}" for a in autos]

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
    except Exception as e: raise HTTPException(status_code=500, detail=f"Fallo al unir catálogos remotos: {e}")

@app.get("/api/eventos/folios", tags=["📝 Órdenes Producción"])
def listar_folios_y_proximo_id():
    q_folios = text("SELECT encode(folio::bytea, 'hex'), encode(nombre_evento::bytea, 'hex') FROM public.eventos WHERE folio IS NOT NULL ORDER BY id_evento DESC")
    q_max = text("SELECT COALESCE(MAX(id_evento), 0) + 1 FROM public.eventos")
    try:
        with engine_eventos.connect() as conn:
            rows = conn.execute(q_folios).fetchall()
            prox_id = conn.execute(q_max).scalar()
        return {"folios": [f"{safe_decode_hex(r[0])} - {safe_decode_hex(r[1])}" for r in rows], "proximo_id": int(prox_id)}
    except Exception as e: raise HTTPException(status_code=500, detail=f"Fallo en base de datos de eventos al compilar folios: {e}")

@app.get("/api/gastos/ultimo-km/{vehiculo}", tags=["💸 Gastos"])
def obtener_ultimo_km_vehiculo(vehiculo: str):
    """Busca el último kilometraje final registrado para una unidad específica."""
    # Reemplaza 'informes_gastos_maestro' por el nombre exacto de tu tabla si es diferente
    query = text("""
        SELECT km_final 
        FROM public.informes_gastos_maestro 
        WHERE vehiculo = :vehiculo 
        ORDER BY id_informe DESC 
        LIMIT 1
    """)
    try:
        with engine_eventos.connect() as conn:
            resultado = conn.execute(query, {"vehiculo": vehiculo.strip()}).fetchone()
            
            if resultado and resultado[0]:
                return {"ultimo_km": int(resultado[0])}
            else:
                return {"ultimo_km": 0} # Si el vehículo es nuevo y no tiene historial
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/eventos/buscar/{folio}", tags=["📝 Órdenes Producción"])
def extraer_orden_por_folio(folio: str):
    query = text("SELECT * FROM public.eventos WHERE TRIM(folio) = :folio")
    try:
        with engine_eventos.connect() as conn: row = conn.execute(query, {"folio": folio.strip()}).mappings().first()
        if not row: raise HTTPException(status_code=404, detail="Folio no encontrado.")
        res = dict(row)
        for k, v in res.items():
            if isinstance(v, (date, time)): res[k] = str(v)
        return res
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

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

        with engine_eventos.connect() as conn:
            existe = conn.execute(text("SELECT 1 FROM public.eventos WHERE id_evento = :id_evento"), {"id_evento": id_ev}).scalar()
            
        if existe:
            query_update = text("""
                UPDATE public.eventos SET 
                    folio = :folio, para_q_cliente = :para_q_cliente, nombre_evento = :nombre_evento, 
                    locacion = :locacion, fec_de_instalacion = CAST(:fec_de_instalacion AS date), 
                    hra_de_instalacion = CAST(:hra_de_instalacion AS time), quien_solicita = :quien_solicita, 
                    resp_de_produccion = :resp_de_produccion, fec_del_evento = CAST(:fec_del_evento AS date), 
                    inicio_del_evento = CAST(:inicio_del_evento AS time), hra_de_llamado = CAST(:hra_de_llamado AS time), 
                    ubicacion = :ubicacion, tipo_de_servicio = :tipo_de_servicio, produccion = :produccion, 
                    internet_redes = :internet_redes, actividades_de_proveedores = :actividades_de_proveedores, 
                    nota = :nota, elabora = :elabora, organiza = :organiza, coordina = :coordina, vobo = :vobo, 
                    proveedor_op = CAST(:proveedor_op AS text[]), personal_convocado_op = CAST(:personal_convocado_op AS text[]), 
                    carros_usados_op = CAST(:carros_usados_op AS text[]), externos_op = CAST(:externos_op AS text[]), 
                    fec_de_elaboracion_de_op = CURRENT_DATE
                WHERE id_evento = :id_evento
            """)
            with engine_eventos.begin() as conn: conn.execute(query_update, payload)
        else:
            query_insert = text("""
                INSERT INTO public.eventos (
                    id_evento, folio, para_q_cliente, nombre_evento, locacion, fec_de_instalacion, 
                    hra_de_instalacion, quien_solicita, resp_de_produccion, fec_del_evento, 
                    inicio_del_evento, hra_de_llamado, ubicacion, tipo_de_servicio, produccion, 
                    internet_redes, actividades_de_proveedores, nota, elabora, organiza, coordina, 
                    vobo, proveedor_op, personal_convocado_op, carros_usados_op, externos_op, 
                    empleado_que_creo_la_op, fec_de_elaboracion_de_op
                ) VALUES (
                    :id_evento, :folio, :para_q_cliente, :nombre_evento, :locacion, CAST(:fec_de_instalacion AS date), 
                    CAST(:hra_de_instalacion AS time), :quien_solicita, :resp_de_produccion, CAST(:fec_del_evento AS date), 
                    CAST(:inicio_del_evento AS time), CAST(:hra_de_llamado AS time), :ubicacion, :tipo_de_servicio, :produccion, 
                    :internet_redes, :actividades_de_proveedores, :nota, :elabora, :organiza, :coordina, 
                    :vobo, CAST(:proveedor_op AS text[]), CAST(:personal_convocado_op AS text[]), 
                    CAST(:carros_usados_op AS text[]), CAST(:externos_op AS text[]), :empleado_que_creo_la_op, CURRENT_DATE
                )
            """)
            with engine_eventos.begin() as conn: conn.execute(query_insert, payload)
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=f"Error transaccional en public.eventos: {str(e)}")

@app.get("/api/inventario/catalogo-global", tags=["📦 Checkout & Logística"])
def obtener_catalogo_global_inventario():
    """Extrae de golpe todas las descripciones unicas del inventario acumulado (Maestro + Kits) para el autocompletado en Streamlit"""
    try:
        nombres_globales = set()
        
        with engine_inventario.connect() as conn:
            # 1️⃣ Jalamos los artículos del Inventario Alterno (Kits)
            rows_kits = conn.execute(text("""
                SELECT DISTINCT descripcion_inv_kits 
                FROM public.inventario_kits 
                WHERE descripcion_inv_kits IS NOT NULL 
                  AND descripcion_inv_kits NOT IN ('', 'None', 'nan', 'NaN', 'Equipo no registrado')
            """)).fetchall()
            
            for r in rows_kits:
                if r[0]: nombres_globales.add(str(r[0]).strip())
                
            # 2️⃣ Jalamos los fierros pesados del Catálogo Maestro de Hardware
            rows_master = conn.execute(text("""
                SELECT DISTINCT descripcion 
                FROM public.inventario 
                WHERE descripcion IS NOT NULL 
                  AND descripcion NOT IN ('', 'None', 'nan', 'NaN', 'Equipo no registrado')
            """)).fetchall()
            
            for r in rows_master:
                if r[0]: nombres_globales.add(str(r[0]).strip())
                
        # Retornamos la lista unificada, limpia y ordenada alfabéticamente
        return sorted(list(nombres_globales))
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Fallo al extraer catálogo acumulado: {str(e)}")
    
@app.get("/api/checkout/init-data/{id_empleado}", tags=["📦 Checkout & Logística"])         # 📦 ENDPOINTS LOGÍSTICA DE BODEGA: CHECKOUT / CHECKIN - ¡PULIDO ANTI-CLONES!
def inicializar_modulo_checkout(id_empleado: str):
    try:
        with engine_eventos.connect() as conn:
            evs = conn.execute(text("SELECT id_evento, encode(para_q_cliente::bytea,'hex'), encode(nombre_evento::bytea,'hex') FROM public.eventos ORDER BY id_evento DESC")).fetchall()
            
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
                id_p_str = str(p[0]).strip()
                alertas_lista.append({"folio": p[1], "nombre": dict_nombres.get(id_p_str, "Desconocido")})

        return {"ordenes": ordenes, "kits": lista_kits, "alertas_pendientes": alertas_lista}
    except Exception as e: raise HTTPException(status_code=500, detail=f"Fallo en inicialización de checkout: {e}")

@app.get("/api/checkout/kits/{id_empleado}", tags=["📦 Checkout & Logística"])          # 🚀 NUEVO ENDPOINT QUIRÚRGICO: Trae única y exclusivamente los kits del empleado en revisión
def obtener_kits_por_empleado(id_empleado: str):
    try:
        with engine_eventos.connect() as conn:
            kits_rows = conn.execute(text("SELECT DISTINCT encode(nombre_kit::bytea,'hex') FROM public.kits_empleados WHERE TRIM(id_empleado) = :id"), {"id": id_empleado.strip()}).fetchall()
        return {"kits": [safe_decode_hex(k[0]) for k in kits_rows]}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))
    
@app.post("/api/checkout/verificar-salida-coordinador", tags=["📦 Checkout & Checkin"])
def verificar_salida_coordinador(payload: dict):
    """El coordinador valida la carga antes de salir de la bodega, ajustando cantidades reales en caliente"""
    id_maestro = payload.get("id_maestro")
    incidencias = payload.get("incidencias_generales")
    items = payload.get("items", [])
    try:
        with engine_eventos.begin() as conn:     # 1. Sellamos el estatus del maestro de la bodega como 'DESPACHADO'
            conn.execute(text("""
                UPDATE public.checkouts_maestro 
                SET estado_bodega = 'DESPACHADO', 
                    incidencias_generales = :inc
                WHERE id_maestro = :id
            """), {"inc": incidencias, "id": id_maestro})
            
            for item in items:          # 2. Sincronizamos renglón por renglón con las modificaciones hechas por el coordinador
                conn.execute(text("""
                    UPDATE public.checkouts_detalle 
                    SET cantidad = :cant,
                        observaciones = :obs
                    WHERE id_detalle = :id_det
                """), {
                    "cant": int(item.get("CANT", 1)),
                    "obs": str(item.get("OBSERVACIONES", "")).strip(),
                    "id_det": item.get("id_detalle")
                })
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/eventos/buscar_kit/{nombre_kit}/{id_empleado}", tags=["📦 Checkout & Logística"])
def buscar_kit_operador(nombre_kit: str, id_empleado: str):
    """🌟 PARCHE DE ALTA ESCUELA: Extracción de Plantillas con Deserialización Segura"""
    query = text("""
        SELECT items FROM public.kits_empleados 
        WHERE LOWER(TRIM(nombre_kit)) = LOWER(TRIM(:nom)) 
          AND LOWER(TRIM(id_empleado)) = LOWER(TRIM(:id))
    """)
    try:
        with engine_eventos.connect() as conn: 
            row = conn.execute(query, {"nom": nombre_kit.strip(), "id": id_empleado.strip()}).fetchone()
            
        if not row: return {"items": []}
        
        # 🛡️ Blindaje de Deserialización: Postgres a veces devuelve String crudo, a veces JSON nativo
        val = row[0]
        if isinstance(val, str):
            import json
            try:
                val = json.loads(val)
                # Si se guardó con doble codificación (string dentro de string), lo abrimos de nuevo
                if isinstance(val, str): val = json.loads(val)
            except:
                val = []
                
        if not isinstance(val, list): val = []
        return {"items": val}
        
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/checkout/status/{id_evento}/{id_empleado}", tags=["📦 Checkout & Logística"])
def extraer_estado_checkout(id_evento: int, id_empleado: str):
    try:
        with engine_eventos.connect() as conn:
            # 🚀 PARCHE ANTI-UNICODE MAESTRO: Blindamos las matrices y textos libres para evitar el Error 500
            conv_row = conn.execute(text("""
                SELECT encode(personal_convocado_op::text::bytea, 'hex'), 
                       encode(proveedor_op::text::bytea, 'hex') 
                FROM public.eventos WHERE id_evento = :id
            """), {"id": id_evento}).fetchone()
            
            # Decodificamos de forma segura las matrices
            convocados = safe_decode_hex(conv_row[0]) if conv_row and conv_row[0] else "[]"
            proveedores_op = safe_decode_hex(conv_row[1]) if conv_row and len(conv_row) > 1 and conv_row[1] else "[]"
            
            # Blindamos también los textos de la bitácora
            m_row = conn.execute(text("""
                SELECT id_maestro, 
                       encode(incidencias_generales::bytea, 'hex'), 
                       estado_bodega, 
                       encode(nombre_kit::bytea, 'hex') 
                FROM public.checkouts_maestro 
                WHERE folio_op = :id AND TRIM(id_empleado) = :emp
            """), {"id": id_evento, "emp": id_empleado.strip()}).fetchone()
            
            df_detalle = []
            if m_row:
                id_maestro = m_row[0]
                inc_gen = safe_decode_hex(m_row[1])
                est_bodega = m_row[2]
                nom_kit = safe_decode_hex(m_row[3])

                det_rows = conn.execute(text("""
                    SELECT id_detalle, 
                           encode(codigo_equipo::bytea,'hex') as id_eq, 
                           cantidad, 
                           encode(observaciones::bytea,'hex'), 
                           cotejado, 
                           encode(notas_regreso::bytea,'hex') 
                    FROM public.checkouts_detalle 
                    WHERE id_maestro = :id_m
                """), {"id_m": id_maestro}).fetchall()
                
                df_detalle = [{
                    "id_detalle": r[0], 
                    "ID": safe_decode_hex(r[1]), 
                    "CANT": r[2], 
                    "OBSERVACIONES": safe_decode_hex(r[3]), 
                    "COTEJADO": bool(r[4]), 
                    "OBS_REGRESO": safe_decode_hex(r[5])
                } for r in det_rows]

                if df_detalle:
                    with engine_inventario.connect() as conn_inv:
                        inv_rows = conn_inv.execute(text("SELECT encode(codigo_inv_kits::bytea,'hex'), encode(descripcion_inv_kits::bytea,'hex') FROM public.inventario_kits")).fetchall()
                    dict_inv = {str(safe_decode_hex(i[0])).strip().upper(): str(safe_decode_hex(i[1])).strip() for i in inv_rows}
                    for d in df_detalle: 
                        id_limpio = str(d.get("ID", "")).strip().upper()
                        d["EQUIPO"] = dict_inv.get(id_limpio, "Equipo no registrado")

        return {
            "convocados": convocados, 
            "proveedores_op": proveedores_op, # 👈 Ahora viajará limpio y sin crashear el servidor
            "id_maestro": m_row[0] if m_row else None, 
            "incidencias_generales": inc_gen.strip() if m_row and inc_gen else "", 
            "estado_bodega": est_bodega if m_row else "NUEVO", 
            "nombre_kit": nom_kit.strip() if m_row and nom_kit else "--- Sin plantilla ---",
            "detalle": df_detalle
        }
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/checkout/grabar-kit", tags=["📦 Checkout & Logística"])
def guardar_plantilla_kit_operador(payload: dict):
    try:
        id_emp = str(payload["id_empleado"]).strip()
        nom_kit = str(payload["nombre_kit"]).strip()
        items_list = payload["items"]
        user_actual = str(payload["usuario_actual"])
        
        with engine_eventos.begin() as conn_ev:         # 🌟 EL FILTRO ANTIMUERTE: Borrado 100% blindado insensible a variaciones de mayúsculas/espacios
            conn_ev.execute(text("""
                DELETE FROM public.kits_empleados 
                WHERE LOWER(TRIM(nombre_kit)) = LOWER(TRIM(:nom)) 
                  AND LOWER(TRIM(id_empleado)) = LOWER(TRIM(:id))
            """), {"nom": nom_kit, "id": id_emp})
            
            # Guardamos de forma sanitizada y limpia en el insert
            conn_ev.execute(text("""
                INSERT INTO public.kits_empleados (id_empleado, nombre_kit, items) 
                VALUES (TRIM(:id), TRIM(:nom), :items)
            """), {"id": id_emp, "nom": nom_kit, "items": json.dumps(items_list)})
        
        with engine_inventario.begin() as conn_inv:
            for item in items_list:
                conn_inv.execute(text("""
                    INSERT INTO public.inventario_kits (codigo_inv_kits, descripcion_inv_kits, responsable_inv_kits, id_empleado_ref_inv_kits, estado_inv_kits, ubicacion_inv_kits, observaciones_inv_kits, fecha_registro_inv_kits)
                    VALUES (:cod, :desc, :resp, :ref, 'Buen Estado', 'BODEGA', :obs, NOW())
                    ON CONFLICT (codigo_inv_kits) DO UPDATE SET descripcion_inv_kits = EXCLUDED.descripcion_inv_kits, responsable_inv_kits = EXCLUDED.responsable_inv_kits;
                """), {"cod": str(item["ID"]), "desc": str(item["EQUIPO"]), "resp": user_actual, "ref": id_emp, "obs": str(item["OBSERVACIONES"])})
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=f"Fallo al registrar Kit sin clones: {e}")

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
    except Exception as e: 
        raise HTTPException(status_code=500, detail=f"Fallo de salida: {e}")

@app.post("/api/checkout/finalizar-checkin", tags=["📦 Checkout & Logística"])
def registrar_retorno_checkin(payload: dict):
    try:
        id_maestro = int(payload["id_maestro"])
        id_op = int(payload["id_evento"])
        incidencias_gen = str(payload["incidencias_generales"])
        items = payload["items"]
        
        with engine_eventos.begin() as conn_ev:         # 1️⃣ CIRCUITO: db_eventos (Sellar la OP de ruta como RECIBIDO)
            conn_ev.execute(text("UPDATE public.checkouts_maestro SET estado_bodega = 'RECIBIDO', incidencias_generales = :obs, fecha=CURRENT_DATE, hora=CURRENT_TIME WHERE id_maestro = :id_m"), {"obs": incidencias_gen, "id_m": id_maestro})
            for item in items:
                valor_cotejo = bool(item.get("COTEJADO", item.get("cotejado", False)))
                conn_ev.execute(text("UPDATE public.checkouts_detalle SET cotejado = :cot, notas_regreso = :not_r WHERE id_detalle = :id_d"), {"cot": valor_cotejo, "not_r": str(item.get("OBS_REGRESO", "")), "id_d": int(item["id_detalle"])})
        
        with engine_inventario.begin() as conn_inv:         # 2️⃣ CIRCUITO: db_inventario (Inyección Híbrida y Libro Clínico Completo)
            for item in items:
                cod_eq = str(item["ID"]).strip()
                obs_regreso = str(item.get("OBS_REGRESO", "")).strip()
                valor_cotejo = bool(item.get("COTEJADO", item.get("cotejado", False)))
                
                es_danado = any(p in obs_regreso.lower() for p in ["dañ", "rot", "fall", "quebr", "freg", "mal", "golp", "abiert", "daã"])
                médico_status = "DANADO" if es_danado else "BUEN ESTADO"
                
                if valor_cotejo:          # Evaluamos si el ID es de Kit alterno o del Catálogo Maestro
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
                
                if obs_regreso:         # 🚀 INYECCIÓN DE LA CAJA NEGRA: Mapeo milimétrico del historial clínico
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

                    if es_danado:   # 🔗 EL ESLABÓN PERDIDO: INYECCIÓN DIRECTA AL PANEL DEL CEO (TABLA REPARACIONES)
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

        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/incidencias/reporte", tags=["📊 Incidencias"])           # 📊 ENDPOINT MAESTRO DE REPORTES DE INCIDENCIAS
def obtener_reporte_incidencias_global():
    try:
        with engine_eventos.connect() as conn_ev:
            query_ev = text("""
                SELECT cm.id_maestro, cm.folio_op, encode(cm.incidencias_generales::bytea, 'hex'), cm.fecha, encode(cm.id_empleado::bytea, 'hex'),
                       encode(ev.nombre_evento::bytea, 'hex'), encode(ev.para_q_cliente::bytea, 'hex')
                FROM public.checkouts_maestro cm
                LEFT JOIN public.eventos ev ON cm.folio_op = ev.id_evento
            """)
            rows_ev = conn_ev.execute(query_ev).fetchall()

        with engine_personal.connect() as conn_pers:
            query_p = text("""
                SELECT encode(e.id_empleado::bytea, 'hex'), encode(e.nombre::bytea, 'hex'), encode(COALESCE(d.nombre, e.depto)::bytea, 'hex')
                FROM public.empleados e
                LEFT JOIN public.departamentos d ON (CASE WHEN e.depto ~ '^[0-9]+$' THEN CAST(e.depto AS INTEGER) = d.id ELSE FALSE END)
            """)
            rows_p = conn_pers.execute(query_p).fetchall()

        personal_map = {safe_decode_hex(r[0]): {"nombre_empleado": safe_decode_hex(r[1]), "depto_real": safe_decode_hex(r[2])} for r in rows_p}
        reporte = []
        for r in rows_ev:
            id_emp_decoded = safe_decode_hex(r[4])
            emp_info = personal_map.get(id_emp_decoded, {"nombre_empleado": "Desconocido", "depto_real": "Sin Departamento"})
            reporte.append({"id_maestro": r[0], "folio_op": r[1], "incidencias_generales": safe_decode_hex(r[2]), "fecha": str(r[3]) if r[3] else None, "id_empleado": id_emp_decoded, "nombre_evento": safe_decode_hex(r[5]) if r[5] else "Evento no registrado", "para_q_cliente": safe_decode_hex(r[6]) if r[6] else "Cliente no registrado", "nombre_empleado": emp_info["nombre_empleado"], "depto_real": emp_info["depto_real"]})
        return reporte
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))
    
# 💸 ENDPOINTS MAESTROS: SISTEMA DE CONTROL DE GASTOS OPERATIVOS (VPRO ERP)
@app.get("/api/gastos/pendientes/conteo", tags=["💸 Gastos Operativos"])
def contar_gastos_pendientes_api():
    """Devuelve el conteo de informes de gastos que aún no han sido revisados por Ana Lilia"""
    query = text("SELECT COUNT(*) FROM public.informes_gastos_maestro WHERE revisado = FALSE")
    try:
        with engine_eventos.connect() as conn: return conn.execute(query).scalar()
    except: return 0

@app.get("/api/gastos/folios-pendientes", tags=["💸 Gastos Operativos"])
def listar_folios_pendientes_gastos():
    """
    Busca eventos concluidos que ya pasaron por check-in de bodega ('RECIBIDO')
    pero que el responsable de producción aún no ha presentado su informe financiero.
    """
    query = text("""
        SELECT e.id_evento, 
               encode(e.para_q_cliente::bytea, 'hex'), 
               encode(e.nombre_evento::bytea, 'hex')
        FROM public.eventos e
        WHERE NOT EXISTS (
            SELECT 1 FROM public.informes_gastos_maestro m 
            WHERE m.folio_vpro = e.id_evento
        )
        AND EXISTS (
            SELECT 1 FROM public.checkouts_maestro cm 
            WHERE cm.folio_op = e.id_evento AND cm.estado_bodega = 'RECIBIDO'
        )
        ORDER BY e.id_evento DESC
    """)
    try:
        with engine_eventos.connect() as conn: rows = conn.execute(query).fetchall()
        return [{
            "id_evento": r[0],
            "cliente": safe_decode_hex(r[1]),
            "nombre_evento": safe_decode_hex(r[2])
        } for r in rows]
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/gastos/evento/{id_evento}", tags=["💸 Gastos Operativos"])
def obtener_datos_evento_gasto(id_evento: int):
    """Extrae el productor asignado, vehículos y personal de la OP de origen de forma blindada"""
    # 🌟 PARCHE MAESTRO VPRO: Agregamos ::text antes de ::bytea para procesar matrices de Postgres sin Error 500
    query = text("""
        SELECT encode(resp_de_produccion::bytea, 'hex'), 
               fec_de_instalacion, 
               encode(carros_usados_op::text::bytea, 'hex'), 
               encode(personal_convocado_op::text::bytea, 'hex')
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
        raise HTTPException(status_code=500, detail=f"Fallo en decodificación de matrices text[] de Postgres: {str(e)}")

@app.post("/api/gastos/guardar", tags=["💸 Gastos Operativos"])
def guardar_informe_gastos_completo(payload: dict):
    """Inyecta de forma síncrona el registro Maestro y la cascada del Detalle (image_c62ab7)"""
    try:
        maestro = payload.get("maestro", {})
        detalles = payload.get("detalles", [])
        
        with engine_eventos.begin() as conn:            # 1. Guardar la Cabecera Maestro (id_empleado acortado a varchar(3) por regla de base de datos)
            sql_m = text("""
                INSERT INTO public.informes_gastos_maestro (
                    folio_vpro, id_empleado, periodo_desde, periodo_hasta, vehiculo, 
                    km_inicial, km_final, departamento, num_personas, subtotal,
                    monto_entregado, restante, fecha_registro, hora_registro, revisado
                ) VALUES (
                    :folio_vpro, :id_empleado, :periodo_desde, :periodo_hasta, :vehiculo,
                    :km_inicial, :km_final, :departamento, :num_personas, :subtotal,
                    :monto_entregado, :restante, CURRENT_DATE, CURRENT_TIME, FALSE
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
            
            # 2. Inyección masiva renglón por renglón del detalle diario
            sql_d = text("""
                INSERT INTO public.informes_gastos_detalle (
                    id_informe, dia_num, hotel, transporte, combustible, 
                    casetas, desayuno, comida, cenas, varios, total_dia
                ) VALUES (
                    :id_informe, :dia_num, :hotel, :transporte, :combustible,
                    :casetas, :desayuno, :comida, :cenas, :varios, :total_dia
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
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/api/gastos/informe-completo/{id_informe}", tags=["💸 Gastos Operativos"])            # 🔍 ENDPOINTS DE AUDITORÍA: CONTROL FINANCIERO DE CAJA CHICA (ANA LILIA AUDIT)
def obtener_expediente_informe_completo(id_informe: int):
    """Extrae la cabecera maestro y la cascada de desgloses diarios de un informe específico"""
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
        if not m: raise HTTPException(status_code=404, detail="Informe no mapeado")
        
        with engine_personal.connect() as conn_p:
            emp_row = conn_p.execute(text("SELECT encode(nombre::bytea, 'hex') FROM public.empleados WHERE id_empleado = :id"), {"id": str(m[2]).strip()}).first()
        nombre_emp = safe_decode_hex(emp_row[0]) if emp_row else f"ID: {m[2]}"

        return {
            "maestro": {
                "id_informe": m[0], "folio_vpro": m[1], "nombre_empleado": nombre_emp, "periodo_desde": str(m[3]), "periodo_hasta": str(m[4]),
                "vehiculo": safe_decode_hex(m[5]), "km_inicial": m[6], "km_final": m[7], "departamento": safe_decode_hex(m[8]),
                "num_personas": m[9], "subtotal": m[10], "monto_entregado": m[11], "restante": m[12], "revisado": m[13]
            },
            "detalles": [{
                "dia_num": d[0], "hotel": d[1], "transporte": d[2], "combustible": d[3], "casetas": d[4],
                "desayuno": d[5], "comida": d[6], "cenas": d[7], "varios": d[8], "total_dia": d[9]
            } for d in detalles]
        }
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/gastos/revisar/{id_informe}", tags=["💸 Gastos Operativos"])
def aprobar_y_sellar_informe_gasto(id_informe: int):
    """Cambia el estatus de revisado a TRUE para archivar la cuenta y limpiar alertas de barra lateral"""
    query = text("UPDATE public.informes_gastos_maestro SET revisado = TRUE WHERE id_informe = :id")
    try:
        with engine_eventos.begin() as conn: conn.execute(query, {"id": id_informe})
        return {"status": "SUCCESS"}
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/api/inventario-kits/ultimo-id-alterno/{id_empleado}", tags=["🛠️ Inventario General"])
def obtener_ultimo_id_alterno_empleado(id_empleado: str):
    """🚀 NUEVA LÓGICA: Rastrea el último consecutivo exclusivo de un empleado específico"""
    try:
        with engine_inventario.connect() as conn:
            # 1. Buscamos el nuevo patrón corto
            patron = f"Inv_alt_{id_empleado.strip()}%"
            query = text("""
                SELECT codigo_inv_kits 
                FROM public.inventario_kits 
                WHERE codigo_inv_kits LIKE :patron 
                ORDER BY codigo_inv_kits DESC 
                LIMIT 1
            """)
            row = conn.execute(query, {"patron": patron}).fetchone()
            
            if row and row[0]:
                val_str = str(row[0]).strip()
                prefijo = f"Inv_alt_{id_empleado.strip()}"
                str_num = val_str.replace(prefijo, "")
                try: 
                    return {"ultimo_id": int(str_num)}
                except: 
                    pass
        return {"ultimo_id": 0}
    except: 
        return {"ultimo_id": 0}
    
from fastapi import Query
from sqlalchemy import text
import datetime

@app.get("/api/gastos/pendientes-auditoria", tags=["💸 Reporte de Gastos"])
def obtener_gastos_pendientes_auditoria():
    try:
        with engine_eventos.connect() as conn:
            query = text("""
                SELECT 
                    igm.folio_vpro, 
                    igm.id_empleado, 
                    e.nombre_evento,
                    e.para_q_cliente
                FROM public.informes_gastos_maestro igm
                LEFT JOIN public.eventos e ON igm.folio_vpro = e.id_evento
                WHERE igm.revisado IS FALSE OR igm.revisado IS NULL
            """)
            res = conn.execute(query).fetchall()
            
            lista_pendientes = []
            for r in res:
                cliente_str = r[3] if r[3] else ""
                evento_str = r[2] if r[2] else "Evento Desconocido"
                nombre_completo_evento = f"{cliente_str} - {evento_str}".strip(" -")
                
                lista_pendientes.append({
                    "folio_op": r[0],
                    "id_empleado": str(r[1]).strip(),
                    "evento": nombre_completo_evento
                })
            
            return lista_pendientes
            
    except Exception as e:
        print(f"Error al buscar gastos pendientes: {e}")
        return []

@app.get("/api/gastos/informes-auditoria", tags=["💸 Gastos Operativos"])
def listar_informes_auditoria():
    """Extrae TODOS los informes (pendientes y archivados) para el panel de Ana Lilia"""
    try:
        # 1. Traemos los reportes y los cruzamos con los eventos
        with engine_eventos.connect() as conn:
            query = text("""
                SELECT 
                    m.id_informe, 
                    m.folio_vpro, 
                    m.revisado, 
                    m.id_empleado, 
                    e.nombre_evento
                FROM public.informes_gastos_maestro m
                LEFT JOIN public.eventos e ON m.folio_vpro = e.id_evento
                ORDER BY m.id_informe DESC
            """)
            rows = conn.execute(query).fetchall()
            
        # 2. Traemos a los empleados de la otra base de datos para traducir el ID al nombre real
        with engine_personal.connect() as conn_p:
            emp_rows = conn_p.execute(text("SELECT TRIM(id_empleado), encode(nombre::bytea, 'hex') FROM public.empleados")).fetchall()
            dict_emps = {r[0]: safe_decode_hex(r[1]) for r in emp_rows}
            
        # 3. Armamos la lista final para enviarla a la pantalla
        lista_final = []
        for r in rows:
            id_emp = str(r[3]).strip()
            lista_final.append({
                "id_informe": r[0],
                "folio_vpro": r[1],
                "revisado": bool(r[2]),
                "nombre_empleado": dict_emps.get(id_emp, f"ID: {id_emp}"),
                "nombre_evento": r[4] if r[4] else "Evento Desconocido"
            })
            
        return lista_final
        
    except Exception as e:
        print(f"Error en informes-auditoria: {e}")
        return []
    
@app.post("/api/gastos/modificar-historico", tags=["💸 Gastos Operativos"])
def modificar_informe_historico(payload: dict):
    try:
        with engine_eventos.begin() as conn:
            conn.execute(text("DELETE FROM public.informes_gastos_detalle WHERE id_informe = :id"), {"id": payload["id_informe"]})
            
            sql_d = text("""
                INSERT INTO public.informes_gastos_detalle (
                    id_informe, dia_num, hotel, transporte, combustible, 
                    casetas, desayuno, comida, cenas, varios, total_dia
                ) VALUES (
                    :id_informe, :dia_num, :hotel, :transporte, :combustible,
                    :casetas, :desayuno, :comida, :cenas, :varios, :total_dia
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
            
            conn.execute(text("""
                UPDATE public.informes_gastos_maestro 
                SET subtotal = :sub, restante = monto_entregado - :sub
                WHERE id_informe = :id
            """), {"sub": subtotal_nuevo, "id": payload["id_informe"]})
            
        return {"status": "SUCCESS"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/analitica/ceo-panel", tags=["📊 Inteligencia de Negocio / CEO"])
def obtener_analitica_panel_ceo(
    desde: str = Query(..., description="Fecha inicio YYYY-MM-DD"),
    hasta: str = Query(..., description="Fecha fin YYYY-MM-DD")
):
    try:
        # 1️⃣ CIRCUITO: db_eventos (Eventos, Clientes y Convocatorias)
        with engine_eventos.connect() as conn:
            query_ops = text("SELECT COUNT(*) FROM public.eventos WHERE fec_del_evento BETWEEN :desde AND :hasta")
            total_ops = conn.execute(query_ops, {"desde": desde, "hasta": hasta}).scalar() or 0
            
            query_cliente = text("SELECT para_q_cliente, COUNT(*) as conteo FROM public.eventos WHERE fec_del_evento BETWEEN :desde AND :hasta GROUP BY para_q_cliente ORDER BY conteo DESC LIMIT 1")
            res_cliente = conn.execute(query_cliente, {"desde": desde, "hasta": hasta}).fetchone()
            cliente_top = res_cliente[0] if res_cliente else "Sin movimientos"

            query_ranking_clientes = text("SELECT para_q_cliente as cliente, COUNT(*) as conteo FROM public.eventos WHERE fec_del_evento BETWEEN :desde AND :hasta GROUP BY para_q_cliente ORDER BY conteo DESC")
            res_ranking_cli = conn.execute(query_ranking_clientes, {"desde": desde, "hasta": hasta}).fetchall()
            lista_clientes_ranking = [{"Cliente": r[0] if r[0] else "No Especificado", "Eventos": r[1]} for r in res_ranking_cli]

            query_ranking_personal = text("SELECT TRIM(empleado) as emp, COUNT(*) as total_asistencias FROM public.eventos, UNNEST(personal_convocado_op) as empleado WHERE fec_del_evento BETWEEN :desde AND :hasta GROUP BY emp ORDER BY total_asistencias DESC LIMIT 5")
            res_personal = conn.execute(query_ranking_personal, {"desde": desde, "hasta": hasta}).fetchall()
            
            nombres_top = [r[0] for r in res_personal if r[0]]
            roles_map = {}
            if nombres_top:
                with engine_personal.connect() as conn_p:
                    query_roles = text("SELECT nombre, rol FROM public.empleados WHERE nombre IN :nombres")
                    res_roles = conn_p.execute(query_roles, {"nombres": tuple(nombres_top)}).fetchall()
                    roles_map = {str(r[0]).strip(): str(r[1]).strip() for r in res_roles}

            lista_empleados_top = [{"Empleado": r[0], "Eventos": r[1], "Rol": roles_map.get(r[0].strip(), "STAFF").upper()} for r in res_personal if r[0]]
            
        # 2️⃣ CIRCUITO: db_inventario (CON TRADUCTOR DE NOMBRES INTEGRADO)
        with engine_inventario.connect() as conn_i:
            query_taller = text("""
                SELECT folio_vpro, equipo_n_reparacion, reportante, descripcion_del_dano, estado_actual, costo_d_reparacion, fecha_d_reporte
                FROM public.reparaciones WHERE estado_actual NOT IN ('RESUELTO', 'ENTREGADO', '✅ RECUPERADO/LISTO/REINGRESÓ A BODEGA')
                ORDER BY fecha_d_reporte DESC
            """)
            res_taller = conn_i.execute(query_taller).fetchall()

            # 🚀 EL TRADUCTOR: Extraemos catálogos maestros para cruzar la información
            dict_nombres_hw = {}
            try:
                res_maestro = conn_i.execute(text("SELECT encode(codigo::bytea, 'hex'), encode(descripcion::bytea, 'hex') FROM public.inventario")).fetchall()
                for r in res_maestro: dict_nombres_hw[safe_decode_hex(r[0]).strip().upper()] = safe_decode_hex(r[1])
                
                res_kits = conn_i.execute(text("SELECT encode(codigo_inv_kits::bytea, 'hex'), encode(descripcion_inv_kits::bytea, 'hex') FROM public.inventario_kits")).fetchall()
                for r in res_kits: dict_nombres_hw[safe_decode_hex(r[0]).strip().upper()] = safe_decode_hex(r[1])
            except: pass

            lista_taller = []
            for r in res_taller:
                fol_orig = r[0] if r[0] else "S/F"
                id_eq_puro = str(r[1]).strip().upper()
                
                # 🔍 Reemplazamos el ID frío por su descripción amigable
                if id_eq_puro in dict_nombres_hw:
                    nombre_amigable = f"{id_eq_puro} - {dict_nombres_hw[id_eq_puro]}"
                else:
                    nombre_amigable = id_eq_puro

                lista_taller.append({
                    "Folio Origen": fol_orig, 
                    "ID Equipo": nombre_amigable, 
                    "Reportado Por": r[2], 
                    "Diagnóstico Clínico": r[3], 
                    "Estatus de Recuperación": r[4] if r[4] else "⚙️ EN REPARACIÓN", 
                    "Costo Est. ($)": float(r[5]) if r[5] else 0.0, 
                    "Fecha de Reporte": str(r[6]) if r[6] else "S/F"
                })
                
            total_taller = len(lista_taller)

            query_deptos = text("SELECT area_q_pertenece, COUNT(*) as conteo FROM public.reparaciones WHERE fecha_d_reporte BETWEEN :desde AND :hasta GROUP BY area_q_pertenece ORDER BY conteo DESC")
            res_deptos = conn_i.execute(query_deptos, {"desde": desde, "hasta": hasta}).fetchall()
            lista_incidencias_depto = [{"Departamento": str(r[0]).strip().upper(), "Número de Incidencias": r[1]} for r in res_deptos if r[0]]

        if lista_empleados_top:
            lista_empleados_top = [emp for emp in lista_empleados_top if str(emp.get("Rol", emp.get("rol", ""))).upper().strip() != "BAJA"]

        # 🚀 RETORNO EXITOSO UNIFICADO
        return {
            "status": "SUCCESS", "total_eventos": total_ops, "cliente_top": cliente_top, "ranking_clientes": lista_clientes_ranking, 
            "equipos_reparacion": total_taller, "desviacion": f"{(total_taller / total_ops * 100):.1f}% Desviación" if total_ops > 0 else "0.0% Desviación",
            "top_empleados": lista_empleados_top, "taller_tracking": lista_taller, "incidencias_por_depto": lista_incidencias_depto
        }
        
    except Exception as e:
        return {"status": "ERROR", "detail": str(e), "total_eventos": 0, "cliente_top": f"⚠️ Error: {str(e)}", "ranking_clientes": [], "equipos_reparacion": 0, "desviacion": "0%", "top_empleados": [], "taller_tracking": [], "incidencias_por_depto": []}

@app.get("/api/analitica/kpis-financieros", tags=["📊 Inteligencia de Negocio / CEO"])
def obtener_kpis_financieros(
    desde: str = Query(..., description="Fecha inicio YYYY-MM-DD"),
    hasta: str = Query(..., description="Fecha fin YYYY-MM-DD"),
    cliente: str = Query("Todos", description="Filtro opcional por cliente")
):
    try:
        with engine_eventos.connect() as conn:
            # Armamos la condición extra si viene un cliente específico
            filtro_cliente = ""
            params = {"desde": desde, "hasta": hasta}
            if cliente != "Todos":
                filtro_cliente = " AND e.para_q_cliente = :cliente "
                params["cliente"] = cliente

            # 1. Totales Globales de Presupuesto vs Gasto
            q_totales = text(f"""
                SELECT COALESCE(SUM(m.monto_entregado), 0), COALESCE(SUM(m.subtotal), 0), COALESCE(SUM(m.restante), 0)
                FROM public.informes_gastos_maestro m
                JOIN public.eventos e ON m.folio_vpro = e.id_evento
                WHERE m.fecha_registro BETWEEN CAST(:desde AS date) AND CAST(:hasta AS date)
                  AND m.revisado = TRUE
                  {filtro_cliente}
            """)
            t_ent, t_gas, t_rem = conn.execute(q_totales, params).fetchone()

            # 2. Desglose Quirúrgico por Categoría de Gasto
            q_cats = text(f"""
                SELECT 
                    COALESCE(SUM(d.hotel), 0), COALESCE(SUM(d.transporte), 0), COALESCE(SUM(d.combustible), 0),
                    COALESCE(SUM(d.casetas), 0), COALESCE(SUM(d.desayuno), 0), COALESCE(SUM(d.comida), 0),
                    COALESCE(SUM(d.cenas), 0), COALESCE(SUM(d.varios), 0)
                FROM public.informes_gastos_detalle d
                JOIN public.informes_gastos_maestro m ON d.id_informe = m.id_informe
                JOIN public.eventos e ON m.folio_vpro = e.id_evento
                WHERE m.fecha_registro BETWEEN CAST(:desde AS date) AND CAST(:hasta AS date)
                  AND m.revisado = TRUE
                  {filtro_cliente}
            """)
            cats_res = conn.execute(q_cats, params).fetchone()

            # 3. Ranking de Clientes (Mantenemos el top 5)
            q_cli = text(f"""
                SELECT encode(e.para_q_cliente::bytea, 'hex'), COALESCE(SUM(m.subtotal), 0) as gastado
                FROM public.informes_gastos_maestro m
                JOIN public.eventos e ON m.folio_vpro = e.id_evento
                WHERE m.fecha_registro BETWEEN CAST(:desde AS date) AND CAST(:hasta AS date)
                  AND m.revisado = TRUE
                  {filtro_cliente}
                GROUP BY e.para_q_cliente
                ORDER BY gastado DESC LIMIT 5
            """)
            cli_res = conn.execute(q_cli, params).fetchall()

        # Armamos el empaquetado para Plotly
        desglose = [
            {"Categoria": "Hoteles", "Monto": float(cats_res[0])},
            {"Categoria": "Transporte (Vuelos/Uber)", "Monto": float(cats_res[1])},
            {"Categoria": "Combustible", "Monto": float(cats_res[2])},
            {"Categoria": "Casetas", "Monto": float(cats_res[3])},
            {"Categoria": "Desayunos", "Monto": float(cats_res[4])},
            {"Categoria": "Comidas", "Monto": float(cats_res[5])},
            {"Categoria": "Cenas", "Monto": float(cats_res[6])},
            {"Categoria": "Gastos Varios", "Monto": float(cats_res[7])}
        ]

        top_clientes = [{"Cliente": safe_decode_hex(r[0]) if r[0] else "Sin Cliente", "Gasto": float(r[1])} for r in cli_res]

        return {
            "status": "SUCCESS",
            "totales": {"entregado": float(t_ent), "gastado": float(t_gas), "remanente": float(t_rem)},
            "desglose": [x for x in desglose if x["Monto"] > 0],
            "top_clientes": top_clientes
        }
    except Exception as e:
        return {"status": "ERROR", "detail": str(e)}
            
@app.get("/api/checkout/pendientes/{id_empleado}/{nombre_usuario}", tags=["📦 Checkout & Logística"])           # 🔔 ALERTA DE ÓRDENES DE PRODUCCIÓN PENDIENTES (Versión Limpia Tipo Título)
def obtener_ops_pendientes_usuario(id_empleado: str, nombre_usuario: str):
    try:
        # 🍃 Respetamos el formato Tipo Título original de la sesión
        target_user = nombre_usuario.strip()
        
        with engine_eventos.connect() as conn:
            query = text("""
                SELECT id_evento, encode(para_q_cliente::bytea, 'hex'), encode(nombre_evento::bytea, 'hex'), personal_convocado_op
                FROM public.eventos
                ORDER BY id_evento DESC
            """)
            rows = conn.execute(query).fetchall()
            
            ops_pendientes = []
            for r in rows:
                id_ev = r[0]
                cliente = safe_decode_hex(r[1])
                evento = safe_decode_hex(r[2])
                personal_raw = r[3]
                
                convocados = []         # Desglosamos el array manteniendo las letras originales de la base de datos
                if personal_raw:
                    if isinstance(personal_raw, list):
                        convocados = [str(p).strip() for p in personal_raw if p]
                    elif isinstance(personal_raw, str):
                        s = personal_raw.strip()
                        if s.startswith("{") and s.endswith("}"):
                            s = s[1:-1]
                            import csv
                            try: convocados = [x.strip() for x in next(csv.reader([s])) if x]
                            except: convocados = [x.strip().strip('"').strip() for x in s.split(",") if x]
                        else:
                            convocados = [x.strip().strip('"').strip() for x in s.split(",") if x]
                
                if target_user in convocados:           # Comparación directa 1 a 1 en Tipo Título
                    m_row = conn.execute(text("""
                        SELECT estado_bodega 
                        FROM public.checkouts_maestro 
                        WHERE folio_op = :id AND TRIM(id_empleado) = :emp
                    """), {"id": id_ev, "emp": id_empleado.strip()}).mappings().first()
                    
                    estado_actual_bodega = m_row["estado_bodega"] if m_row else "NUEVO"
                    
                    if estado_actual_bodega in ["NUEVO", "PENDIENTE"]:
                        ops_pendientes.append({
                            "id_evento": id_ev,
                            "label": f"OP-{str(id_ev).zfill(3)} | {cliente} - {evento}",
                            "estado": estado_actual_bodega
                        })
            return ops_pendientes
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.post("/api/asistencia/guardar-cambios", tags=["🕒 Checador Asistencia"])
def guardar_cambios_asistencia_admin(logs: List[dict]):
    """Permite a Dirección corregir marcas, horarios u olvidos de checada desde el Panel de Auditoría"""
    query = text("""
        UPDATE public.control_asistencia
        SET hora_entrada = CAST(:hora_entrada AS time),
            hora_salida = CAST(:hora_salida AS time),
            estatus = :estatus,
            observaciones = :observaciones
        WHERE id_registro = :id_registro
    """)
    try:
        with engine_personal.begin() as conn:
            for log in logs:
                # Sanitización: Convertimos basura visual de texto a NULL para no romper el CAST de Postgres
                h_ent = str(log.get("hora_entrada", "")).strip()
                h_sal = str(log.get("hora_salida", "")).strip()
                
                if h_ent in ["", "None", "None", "??:??"]: h_ent = None
                if h_sal in ["", "None", "None", "En Set", "??:??"]: h_sal = None
                
                conn.execute(query, {
                    "hora_entrada": h_ent,
                    "hora_salida": h_sal,
                    "estatus": str(log.get("estatus", "ASISTENCIA")).strip().upper(),
                    "observaciones": str(log.get("observaciones", "")).strip(),
                    "id_registro": int(log.get("id_registro"))
                })
        return {"status": "SUCCESS"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.post("/api/asistencia/sellar-ruta", tags=["🕒 Checador Asistencia"])
def sellar_asistencia_viaje_ruta(payload: dict):
    """Permite al Coordinador pre-autorizar y sellar los días de viaje con el nombre del evento específico"""
    id_evento = payload.get("id_evento")
    fecha_inicio = date.fromisoformat(payload.get("fecha_inicio"))
    fecha_fin = date.fromisoformat(payload.get("fecha_fin"))
    personal = payload.get("personal", [])
    
    # 🎯 RECIBIMOS LA ETIQUETA DINÁMICA CONFIGURADA POR EL USUARIO
    estatus_dinamico = payload.get("estatus_dinamico", "VIAJE DE RUTA")
    
    query_ids = text("SELECT nombre, id_empleado FROM public.empleados")
    query_insert = text("""
        INSERT INTO public.control_asistencia (id_empleado, fecha, hora_entrada, hora_salida, estatus, observaciones)
        VALUES (:id, :fecha, '09:00:00', '19:00:00', :estatus, :obs)
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
                            "id": emp_id,
                            "fecha": dia_evaluado,
                            "estatus": estatus_dinamico.strip().upper(),  # 👈 Sello personalizado en Postgres
                            "obs": f"Logística VPRO: Comisión Foránea - OP-{id_evento}"
                        })
        return {"status": "SUCCESS"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
class SellarRutaExactaPayload(BaseModel):
    id_evento: int
    folio: str
    fecha: str
    hora_personalizada: str
    tipo_movimiento: str
    personal: List[str]
    estatus_dinamico: str

@app.post("/api/asistencia/sellar-ruta-exacta", tags=["🕒 Checador Asistencia"])
def sellar_asistencia_ruta_exacta(payload: SellarRutaExactaPayload):
    try:
        # 1. Traductor: Convertimos los nombres del Dropdown a sus IDs reales
        query_ids = text("SELECT nombre, id_empleado FROM public.empleados")
        with engine_personal.connect() as conn_p:
            rows = conn_p.execute(query_ids).fetchall()
            name_to_id = {str(r[0]).strip().upper(): str(r[1]).strip() for r in rows}

        with engine_personal.begin() as conn:
            for operario in payload.personal:
                emp_name_clean = str(operario).strip().upper()
                
                # Si encontramos el nombre en el directorio, sacamos su ID
                if emp_name_clean in name_to_id:
                    emp_clean = name_to_id[emp_name_clean]
                    
                    if payload.tipo_movimiento.upper() == "ENTRADA":
                        # 🚫 Evita duplicar entrada si ya hay una abierta hoy para ese empleado
                        existe = conn.execute(text("""
                            SELECT 1 FROM public.control_asistencia 
                            WHERE TRIM(id_empleado) = :emp AND fecha = CAST(:fec AS date) AND hora_salida IS NULL
                        """), {"emp": emp_clean, "fec": payload.fecha}).scalar()
                        
                        if not existe:
                            conn.execute(text("""
                                INSERT INTO public.control_asistencia (id_empleado, fecha, hora_entrada, estatus, observaciones)
                                VALUES (:emp, CAST(:fec AS date), CAST(:hora AS time), :est, :obs)
                            """), {
                                "emp": emp_clean, 
                                "fec": payload.fecha, 
                                "hora": payload.hora_personalizada, 
                                "est": "ASISTENCIA", 
                                "obs": payload.estatus_dinamico
                            })
                    else:
                        # 🟢 SALIDA: Busca el registro que esté abierto hoy para cerrarlo
                        id_reg = conn.execute(text("""
                            SELECT id_registro FROM public.control_asistencia 
                            WHERE TRIM(id_empleado) = :emp AND fecha = CAST(:fec AS date) AND hora_salida IS NULL
                            ORDER BY id_registro DESC LIMIT 1
                        """), {"emp": emp_clean, "fec": payload.fecha}).scalar()
                        
                        if id_reg:
                            conn.execute(text("""
                                UPDATE public.control_asistencia 
                                SET hora_salida = CAST(:hora AS time), observaciones = observaciones || ' | ' || :obs
                                WHERE id_registro = :id
                            """), {
                                "id": id_reg, 
                                "hora": payload.hora_personalizada, 
                                "obs": f"Salida Locación: {payload.hora_personalizada}"
                            })
        return {"status": "SUCCESS"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 📸 MOTOR DE EVIDENCIAS FOTOGRÁFICAS DE DAÑOS (RUTA LOCAL REAL)
DIR_EVIDENCIAS_REAL = r"C:\Users\cuauhtemoc\Desktop\Curso_de_Python\Graficos\VPRO_Dashboard_V2_TODO_NUEVO\Fotos_de_equipos"
os.makedirs(DIR_EVIDENCIAS_REAL, exist_ok=True)

@app.post("/api/inventario/subir-evidencia", tags=["🛠️ Inventario General"])
def subir_evidencia_falla(codigo_equipo: str = Form(...), folio_vpro: str = Form(...), file: UploadFile = File(...)):
    try:
        cod_safe = codigo_equipo.replace("/", "_").replace("\\", "_").strip().upper()
        fol_safe = folio_vpro.replace("/", "_").replace("\\", "_").strip().upper()
        
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
        
        filename_evidencia = f"Evidencia_{fol_safe}_{cod_safe}.jpg" # 1. Buscamos primero si hay una foto específica del daño de esta OP (ej. Evidencia_OP-123_INV-001.jpg)
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