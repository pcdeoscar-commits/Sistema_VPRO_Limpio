import datetime
from datetime import date, time
from typing import List, Optional, Dict, Any
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from sqlalchemy import text

from core.database import engine_personal
from core.utils import safe_decode_hex

router = APIRouter(prefix="/api/rh", tags=["👥 Recursos Humanos"])

# --- HELPERS ---
def _registrar_historial(conn, id_empleado, tipo_evento, descripcion, tabla, ref_id, usuario, automatico=True):
    query_hist = text("""
        INSERT INTO public.rh_historial 
        (id_empleado, fecha_evento, tipo_evento, descripcion, referencia_tabla, referencia_id, registrado_por, es_automatico)
        VALUES 
        (:id_empleado, CURRENT_TIMESTAMP, :tipo_evento, :descripcion, :tabla, :ref_id, :usuario, :automatico)
    """)
    conn.execute(query_hist, {
        "id_empleado": id_empleado,
        "tipo_evento": tipo_evento,
        "descripcion": descripcion,
        "tabla": tabla,
        "ref_id": ref_id,
        "usuario": usuario,
        "automatico": automatico
    })

def calcular_anios_trabajados(fecha_ing: Optional[date]) -> int:
    if not fecha_ing:
        return 0
    return (date.today() - fecha_ing).days // 365

def calcular_dias_vacaciones_lft(fecha_ing: Optional[date]) -> int:
    anios = calcular_anios_trabajados(fecha_ing)
    if anios == 0:
        return 0
    elif anios == 1:
        return 12
    elif anios == 2:
        return 14
    elif anios == 3:
        return 16
    elif anios == 4:
        return 18
    elif 5 <= anios <= 9:
        return 20
    elif 10 <= anios <= 14:
        return 22
    elif 15 <= anios <= 19:
        return 24
    elif 20 <= anios <= 24:
        return 26
    elif 25 <= anios <= 29:
        return 28
    else:
        return 28 + 2 * ((anios - 30) // 5)


# --- MODELOS PYDANTIC ---
# Empleados
class EmpleadoUpdate(BaseModel):
    nombre: Optional[str] = None
    depto: Optional[str] = None
    email: Optional[str] = None
    cel: Optional[str] = None
    fecha_nac: Optional[date] = None
    fecha_ing: Optional[date] = None
    rfc: Optional[str] = None
    curp: Optional[str] = None
    nss: Optional[str] = None
    estado_civil: Optional[str] = None
    domicilio: Optional[str] = None
    ciudad: Optional[str] = None
    cp: Optional[str] = None
    contacto_emergencia: Optional[str] = None
    tel_emergencia: Optional[str] = None
    parentesco_emergencia: Optional[str] = None
    escolaridad: Optional[str] = None
    puesto: Optional[str] = None
    tipo_contrato: Optional[str] = None
    salario_mensual: Optional[float] = None
    foto_url: Optional[str] = None
    estatus_empleado: Optional[str] = None
    fecha_baja: Optional[date] = None
    motivo_baja: Optional[str] = None
    rol: Optional[str] = None

# Solicitudes
class SolicitudCreate(BaseModel):
    nombre_completo: str
    email: Optional[str] = None
    tel_celular: Optional[str] = None
    fecha_nac: Optional[date] = None
    rfc: Optional[str] = None
    curp: Optional[str] = None
    domicilio: Optional[str] = None
    escolaridad: Optional[str] = None
    carrera_especialidad: Optional[str] = None
    cedula_profesional: Optional[str] = None
    puesto_solicitado: Optional[str] = None
    depto_solicitado: Optional[str] = None
    experiencia_anios: Optional[int] = None
    experiencia_descripcion: Optional[str] = None
    habilidades: Optional[str] = None
    pretension_salarial: Optional[float] = None
    como_se_entero: Optional[str] = None
    referido_por: Optional[str] = None
    disponibilidad_inmediata: Optional[bool] = None
    fecha_disponible: Optional[date] = None
    tiene_auto: Optional[bool] = None
    tiene_licencia: Optional[bool] = None
    cv_url: Optional[str] = None
    creado_por: Optional[str] = None

class SolicitudUpdate(BaseModel):
    estatus: Optional[str] = None
    observaciones_rh: Optional[str] = None
    id_empleado_resultado: Optional[str] = None

# Entrevistas
class EntrevistaCreate(BaseModel):
    id_solicitud: Optional[int] = None
    id_empleado: Optional[str] = None
    tipo_entrevista: str
    fecha_entrevista: date
    hora_inicio: Optional[time] = None
    hora_fin: Optional[time] = None
    entrevistador: Optional[str] = None
    modalidad: Optional[str] = None
    link_videollamada: Optional[str] = None
    resultado: Optional[str] = None
    puntualidad: Optional[float] = None
    presentacion: Optional[float] = None
    conocimientos_tecnicos: Optional[float] = None
    actitud: Optional[float] = None
    comunicacion: Optional[float] = None
    comentarios: Optional[str] = None
    recomendacion: Optional[str] = None
    archivo_prueba_url: Optional[str] = None
    registrado_por: Optional[str] = None

class EntrevistaUpdate(BaseModel):
    resultado: Optional[str] = None
    comentarios: Optional[str] = None
    recomendacion: Optional[str] = None

# Contratos
class ContratoCreate(BaseModel):
    id_empleado: str
    tipo_contrato: str
    fecha_inicio: date
    fecha_fin: Optional[date] = None
    es_indefinido: Optional[bool] = False
    puesto_contratado: Optional[str] = None
    departamento: Optional[str] = None
    salario_mensual: Optional[float] = None
    dias_vacaciones_anuales: Optional[int] = None
    jornada: Optional[str] = None
    horario: Optional[str] = None
    clausulas_especiales: Optional[str] = None
    archivo_contrato_url: Optional[str] = None
    registrado_por: Optional[str] = None

class ContratoUpdate(BaseModel):
    estatus_contrato: Optional[str] = None
    firmado_empleado: Optional[bool] = None
    firmado_empresa: Optional[bool] = None
    fecha_firma: Optional[date] = None
    observaciones: Optional[str] = None

# Vacaciones
class VacacionCreate(BaseModel):
    id_empleado: str
    anio_periodo: int
    dias_tomados: int
    fecha_inicio_goce: date
    fecha_fin_goce: date
    fecha_limite_goce: Optional[date] = None
    tipo: str
    observaciones: Optional[str] = None
    registrado_por: Optional[str] = None

class VacacionUpdate(BaseModel):
    estatus: Optional[str] = None
    aprobado_por: Optional[str] = None
    fecha_aprobacion: Optional[date] = None
    notificado_admon: Optional[bool] = None
    fecha_notif_admon: Optional[date] = None
    observaciones: Optional[str] = None

# Permisos
class PermisoCreate(BaseModel):
    id_empleado: str
    tipo_permiso: str
    fecha_solicitud: date
    fecha_inicio: date
    fecha_fin: date
    con_goce_de_sueldo: bool
    justificacion: Optional[str] = None
    archivo_justificante: Optional[str] = None
    registrado_por: Optional[str] = None

class PermisoUpdate(BaseModel):
    estatus: Optional[str] = None
    aprobado_por: Optional[str] = None
    fecha_aprobacion: Optional[date] = None
    motivo_rechazo: Optional[str] = None
    impacta_asistencia: Optional[bool] = None
    observaciones_rh: Optional[str] = None

# Incapacidades
class IncapacidadCreate(BaseModel):
    id_empleado: str
    tipo: str
    fecha_inicio: date
    fecha_fin: date
    numero_imss: Optional[str] = None
    medico_tratante: Optional[str] = None
    diagnostico: Optional[str] = None
    porcentaje_pago_imss: Optional[float] = None
    archivo_incapacidad_url: Optional[str] = None
    registrado_por: Optional[str] = None

class IncapacidadUpdate(BaseModel):
    estatus: Optional[str] = None
    validado_por_rh: Optional[bool] = None
    fecha_validacion: Optional[date] = None
    observaciones: Optional[str] = None

# Capacitación
class CapacitacionCreate(BaseModel):
    id_empleado: str
    nombre_curso: str
    tipo: str
    institucion: Optional[str] = None
    fecha_inicio: date
    fecha_fin: Optional[date] = None
    horas_duracion: Optional[float] = None
    resultado: Optional[str] = None
    calificacion: Optional[float] = None
    tiene_constancia: Optional[bool] = None
    constancia_url: Optional[str] = None
    costo: Optional[float] = None
    pagado_por_empresa: Optional[bool] = None
    observaciones: Optional[str] = None
    registrado_por: Optional[str] = None

class CapacitacionUpdate(BaseModel):
    resultado: Optional[str] = None
    calificacion: Optional[float] = None
    tiene_constancia: Optional[bool] = None
    constancia_url: Optional[str] = None
    observaciones: Optional[str] = None

# Evaluaciones
class EvaluacionCreate(BaseModel):
    id_empleado: str
    periodo: str
    tipo: str
    evaluador: str
    puesto_evaluador: Optional[str] = None
    puntualidad: float
    calidad_trabajo: float
    trabajo_equipo: float
    responsabilidad: float
    iniciativa: float
    comunicacion: float
    cumplimiento_objetivos: float
    fortalezas: Optional[str] = None
    areas_mejora: Optional[str] = None
    plan_accion: Optional[str] = None
    comentarios_empleado: Optional[str] = None
    archivo_evaluacion_url: Optional[str] = None
    registrado_por: Optional[str] = None

class EvaluacionUpdate(BaseModel):
    firma_empleado: Optional[bool] = None
    archivo_evaluacion_url: Optional[str] = None
    comentarios_empleado: Optional[str] = None

# Documentos
class DocumentoCreate(BaseModel):
    id_empleado: str
    tipo_documento: str
    nombre_archivo: str
    archivo_url: str
    formato: str
    fecha_emision: Optional[date] = None
    fecha_vencimiento: Optional[date] = None
    esta_vigente: Optional[bool] = True
    observaciones: Optional[str] = None
    subido_por: Optional[str] = None

class DocumentoUpdate(BaseModel):
    fecha_vencimiento: Optional[date] = None
    esta_vigente: Optional[bool] = None
    verificado_por_rh: Optional[bool] = None
    observaciones: Optional[str] = None


# --- ENDPOINTS ---

# --- EMPLEADOS ---
@router.get("/empleados")
def get_empleados():
    query = text("""
        SELECT id_empleado, nombre, depto, puesto, estatus_empleado, fecha_ing, salario_mensual
        FROM public.empleados
        WHERE estatus_empleado = 'ACTIVO'
        ORDER BY nombre ASC
    """)
    try:
        with engine_personal.connect() as conn:
            rows = conn.execute(query).mappings().fetchall()
            result = []
            for r in rows:
                d = dict(r)
                d["nombre"] = safe_decode_hex(d.get("nombre", ""))
                d["depto"] = safe_decode_hex(d.get("depto", ""))
                if d.get("fecha_ing"):
                    d["fecha_ing"] = str(d["fecha_ing"])
                result.append(d)
            return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/empleados/{id_empleado}")
def get_empleado(id_empleado: str):
    query = text("SELECT * FROM public.empleados WHERE id_empleado = :id_empleado")
    try:
        with engine_personal.connect() as conn:
            row = conn.execute(query, {"id_empleado": id_empleado}).mappings().first()
            if not row:
                raise HTTPException(status_code=404, detail="Empleado no encontrado")
            
            d = dict(row)
            d["nombre"] = safe_decode_hex(d.get("nombre", ""))
            d["depto"] = safe_decode_hex(d.get("depto", ""))
            
            # Calcular edad
            if d.get("fecha_nac"):
                d["edad"] = (date.today() - d["fecha_nac"]).days // 365
            else:
                d["edad"] = None
                
            # Calcular años trabajados
            d["anios_trabajados"] = calcular_anios_trabajados(d.get("fecha_ing"))
            
            # Formatear fechas
            for k, v in d.items():
                if isinstance(v, (date, time, datetime.datetime)):
                    d[k] = str(v)
                    
            return d
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/empleados/{id_empleado}")
def update_empleado(id_empleado: str, payload: EmpleadoUpdate):
    update_data = {k: v for k, v in payload.model_dump().items() if v is not None}
    if not update_data:
        return {"msg": "No hay campos para actualizar"}
        
    set_clauses = []
    params = {"id_empleado": id_empleado}
    for k, v in update_data.items():
        set_clauses.append(f"{k} = :{k}")
        params[k] = v
        
    query_str = f"UPDATE public.empleados SET {', '.join(set_clauses)} WHERE id_empleado = :id_empleado"
    
    try:
        with engine_personal.begin() as conn:
            conn.execute(text(query_str), params)
            
            # Historial
            desc = f"Actualización de datos: {', '.join(update_data.keys())}"
            _registrar_historial(conn, id_empleado, "ACTUALIZACION_DATOS", desc, "empleados", id_empleado, "SISTEMA")
            
            return {"msg": "Empleado actualizado exitosamente"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/alertas")
def get_alertas():
    try:
        with engine_personal.connect() as conn:
            alertas = []
            hoy = date.today()
            
            # Contratos por vencer (<= 30 dias)
            query_ctr = text("""
                SELECT c.id_contrato, c.id_empleado, e.nombre, c.fecha_fin 
                FROM public.rh_contratos c
                JOIN public.empleados e ON c.id_empleado = e.id_empleado
                WHERE c.estatus_contrato = 'VIGENTE' 
                AND c.es_indefinido = false 
                AND c.fecha_fin IS NOT NULL
                AND e.estatus_empleado = 'ACTIVO'
            """)
            ctrs = conn.execute(query_ctr).mappings().fetchall()
            for c in ctrs:
                if c["fecha_fin"]:
                    dias_restantes = (c["fecha_fin"] - hoy).days
                    if 0 <= dias_restantes <= 30:
                        nombre = safe_decode_hex(c.get("nombre", ""))
                        urgencia = "ALTA" if dias_restantes <= 7 else "MEDIA"
                        alertas.append({
                            "tipo": "CONTRATO_POR_VENCER",
                            "empleado": nombre,
                            "id_empleado": c["id_empleado"],
                            "mensaje": f"Contrato vence en {dias_restantes} días (el {c['fecha_fin']})",
                            "urgencia": urgencia
                        })
            
            # Vacaciones por vencer (<= 60 dias limite goce)
            query_vac = text("""
                SELECT v.id_vacacion, v.id_empleado, e.nombre, v.fecha_limite_goce 
                FROM public.rh_vacaciones v
                JOIN public.empleados e ON v.id_empleado = e.id_empleado
                WHERE v.estatus = 'PENDIENTE'
                AND v.fecha_limite_goce IS NOT NULL
                AND e.estatus_empleado = 'ACTIVO'
            """)
            vacs = conn.execute(query_vac).mappings().fetchall()
            for v in vacs:
                if v["fecha_limite_goce"]:
                    dias_restantes = (v["fecha_limite_goce"] - hoy).days
                    if 0 <= dias_restantes <= 60:
                        nombre = safe_decode_hex(v.get("nombre", ""))
                        urgencia = "ALTA" if dias_restantes <= 15 else "MEDIA"
                        alertas.append({
                            "tipo": "VACACIONES_POR_VENCER",
                            "empleado": nombre,
                            "id_empleado": v["id_empleado"],
                            "mensaje": f"Periodo vacacional debe ser tomado antes del {v['fecha_limite_goce']} ({dias_restantes} días restantes)",
                            "urgencia": urgencia
                        })
                        
            # Documentos por vencer (<= 30 dias) -> en la descripcion decia "licencias por vencer"
            query_doc = text("""
                SELECT d.id_documento, d.id_empleado, e.nombre, d.tipo_documento, d.fecha_vencimiento
                FROM public.rh_documentos d
                JOIN public.empleados e ON d.id_empleado = e.id_empleado
                WHERE d.esta_vigente = true
                AND d.fecha_vencimiento IS NOT NULL
                AND e.estatus_empleado = 'ACTIVO'
            """)
            docs = conn.execute(query_doc).mappings().fetchall()
            for d in docs:
                if d["fecha_vencimiento"]:
                    dias_restantes = (d["fecha_vencimiento"] - hoy).days
                    if 0 <= dias_restantes <= 30:
                        nombre = safe_decode_hex(d.get("nombre", ""))
                        urgencia = "ALTA" if dias_restantes <= 7 else "MEDIA"
                        alertas.append({
                            "tipo": "DOCUMENTO_POR_VENCER",
                            "empleado": nombre,
                            "id_empleado": d["id_empleado"],
                            "mensaje": f"Documento {d['tipo_documento']} vence en {dias_restantes} días ({d['fecha_vencimiento']})",
                            "urgencia": urgencia
                        })
                        
            return alertas
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- SOLICITUDES DE EMPLEO ---
@router.get("/solicitudes")
def get_solicitudes(estatus: Optional[str] = None):
    try:
        with engine_personal.connect() as conn:
            if estatus:
                query = text("SELECT * FROM public.rh_solicitudes_empleo WHERE estatus = :estatus ORDER BY fecha_solicitud DESC")
                rows = conn.execute(query, {"estatus": estatus}).mappings().fetchall()
            else:
                query = text("SELECT * FROM public.rh_solicitudes_empleo ORDER BY fecha_solicitud DESC")
                rows = conn.execute(query).mappings().fetchall()
                
            return [{k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in r.items()} for r in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/solicitudes")
def create_solicitud(payload: SolicitudCreate):
    try:
        with engine_personal.begin() as conn:
            # Generar folio SOL-YYYY-NNN
            anio = date.today().year
            query_count = text("SELECT COUNT(*) as c FROM public.rh_solicitudes_empleo WHERE EXTRACT(YEAR FROM fecha_solicitud) = :anio")
            count = conn.execute(query_count, {"anio": anio}).scalar() or 0
            folio = f"SOL-{anio}-{count + 1:03d}"
            
            data = payload.model_dump()
            data["folio"] = folio
            data["fecha_solicitud"] = date.today()
            data["estatus"] = "RECIBIDA"
            
            cols = list(data.keys())
            vals = [f":{c}" for c in cols]
            
            query = text(f"""
                INSERT INTO public.rh_solicitudes_empleo ({', '.join(cols)})
                VALUES ({', '.join(vals)})
                RETURNING id_solicitud
            """)
            
            res = conn.execute(query, data).mappings().first()
            return {"msg": "Solicitud creada", "id_solicitud": res["id_solicitud"], "folio": folio}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/solicitudes/{id_solicitud}")
def update_solicitud(id_solicitud: int, payload: SolicitudUpdate):
    update_data = {k: v for k, v in payload.model_dump().items() if v is not None}
    if not update_data:
        return {"msg": "No hay campos para actualizar"}
        
    set_clauses = []
    params = {"id_solicitud": id_solicitud}
    for k, v in update_data.items():
        set_clauses.append(f"{k} = :{k}")
        params[k] = v
        
    query_str = f"UPDATE public.rh_solicitudes_empleo SET {', '.join(set_clauses)} WHERE id_solicitud = :id_solicitud"
    
    try:
        with engine_personal.begin() as conn:
            conn.execute(text(query_str), params)
            return {"msg": "Solicitud actualizada"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/solicitudes/{id_solicitud}")
def delete_solicitud(id_solicitud: int):
    try:
        with engine_personal.begin() as conn:
            query = text("SELECT estatus FROM public.rh_solicitudes_empleo WHERE id_solicitud = :id")
            row = conn.execute(query, {"id": id_solicitud}).mappings().first()
            if not row:
                raise HTTPException(status_code=404, detail="Solicitud no encontrada")
            if row["estatus"] != "RECIBIDA":
                raise HTTPException(status_code=400, detail="Solo se pueden eliminar solicitudes en estatus RECIBIDA")
                
            query_del = text("DELETE FROM public.rh_solicitudes_empleo WHERE id_solicitud = :id")
            conn.execute(query_del, {"id": id_solicitud})
            return {"msg": "Solicitud eliminada"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- ENTREVISTAS ---
@router.get("/entrevistas")
def get_entrevistas(id_solicitud: Optional[int] = None, id_empleado: Optional[str] = None):
    try:
        with engine_personal.connect() as conn:
            if id_solicitud:
                query = text("SELECT * FROM public.rh_entrevistas WHERE id_solicitud = :id ORDER BY fecha_entrevista DESC")
                params = {"id": id_solicitud}
            elif id_empleado:
                query = text("SELECT * FROM public.rh_entrevistas WHERE id_empleado = :id ORDER BY fecha_entrevista DESC")
                params = {"id": id_empleado}
            else:
                raise HTTPException(status_code=400, detail="Debe proveer id_solicitud o id_empleado")
                
            rows = conn.execute(query, params).mappings().fetchall()
            return [{k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in r.items()} for r in rows]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/entrevistas")
def create_entrevista(payload: EntrevistaCreate):
    data = payload.model_dump()
    
    # Calcular promedio
    criterios = [data.get("puntualidad"), data.get("presentacion"), data.get("conocimientos_tecnicos"), data.get("actitud"), data.get("comunicacion")]
    criterios_validos = [c for c in criterios if c is not None]
    if criterios_validos:
        data["calificacion_general"] = sum(criterios_validos) / len(criterios_validos)
    else:
        data["calificacion_general"] = None

    cols = list(data.keys())
    vals = [f":{c}" for c in cols]
    
    try:
        with engine_personal.begin() as conn:
            query = text(f"""
                INSERT INTO public.rh_entrevistas ({', '.join(cols)})
                VALUES ({', '.join(vals)})
                RETURNING id_entrevista
            """)
            res = conn.execute(query, data).mappings().first()
            return {"msg": "Entrevista creada", "id_entrevista": res["id_entrevista"]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/entrevistas/{id_entrevista}")
def update_entrevista(id_entrevista: int, payload: EntrevistaUpdate):
    update_data = {k: v for k, v in payload.model_dump().items() if v is not None}
    if not update_data:
        return {"msg": "No hay campos para actualizar"}
        
    set_clauses = []
    params = {"id_entrevista": id_entrevista}
    for k, v in update_data.items():
        set_clauses.append(f"{k} = :{k}")
        params[k] = v
        
    query_str = f"UPDATE public.rh_entrevistas SET {', '.join(set_clauses)} WHERE id_entrevista = :id_entrevista"
    
    try:
        with engine_personal.begin() as conn:
            conn.execute(text(query_str), params)
            return {"msg": "Entrevista actualizada"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- CONTRATOS ---
@router.get("/contratos/{id_empleado}")
def get_contratos(id_empleado: str):
    try:
        with engine_personal.connect() as conn:
            query = text("SELECT * FROM public.rh_contratos WHERE id_empleado = :id ORDER BY fecha_inicio DESC")
            rows = conn.execute(query, {"id": id_empleado}).mappings().fetchall()
            return [{k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in r.items()} for r in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/contratos/vigente/{id_empleado}")
def get_contrato_vigente(id_empleado: str):
    try:
        with engine_personal.connect() as conn:
            query = text("SELECT * FROM public.rh_contratos WHERE id_empleado = :id AND estatus_contrato = 'VIGENTE' ORDER BY fecha_inicio DESC LIMIT 1")
            row = conn.execute(query, {"id": id_empleado}).mappings().first()
            if not row:
                return None
            return {k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in row.items()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/contratos")
def create_contrato(payload: ContratoCreate):
    try:
        with engine_personal.begin() as conn:
            # Folio CTR-YYYY-NNN
            anio = date.today().year
            query_count = text("SELECT COUNT(*) as c FROM public.rh_contratos WHERE EXTRACT(YEAR FROM fecha_registro) = :anio")
            count = conn.execute(query_count, {"anio": anio}).scalar() or 0
            folio = f"CTR-{anio}-{count + 1:03d}"
            
            data = payload.model_dump()
            data["folio_contrato"] = folio
            data["estatus_contrato"] = "VIGENTE"
            
            cols = list(data.keys())
            vals = [f":{c}" for c in cols]
            
            query = text(f"""
                INSERT INTO public.rh_contratos ({', '.join(cols)})
                VALUES ({', '.join(vals)})
                RETURNING id_contrato
            """)
            res = conn.execute(query, data).mappings().first()
            id_contrato = res["id_contrato"]
            
            # Historial
            _registrar_historial(conn, data["id_empleado"], "NUEVO_CONTRATO", f"Contrato {folio} generado", "rh_contratos", str(id_contrato), data.get("registrado_por", "SISTEMA"))
            
            return {"msg": "Contrato creado", "id_contrato": id_contrato, "folio": folio}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/contratos/{id_contrato}")
def update_contrato(id_contrato: int, payload: ContratoUpdate):
    update_data = {k: v for k, v in payload.model_dump().items() if v is not None}
    if not update_data:
        return {"msg": "No hay campos para actualizar"}
        
    set_clauses = []
    params = {"id_contrato": id_contrato}
    for k, v in update_data.items():
        set_clauses.append(f"{k} = :{k}")
        params[k] = v
        
    query_str = f"UPDATE public.rh_contratos SET {', '.join(set_clauses)} WHERE id_contrato = :id_contrato RETURNING id_empleado"
    
    try:
        with engine_personal.begin() as conn:
            res = conn.execute(text(query_str), params).mappings().first()
            if res:
                _registrar_historial(conn, res["id_empleado"], "ACTUALIZACION_CONTRATO", f"Contrato ID {id_contrato} actualizado", "rh_contratos", str(id_contrato), "SISTEMA")
            return {"msg": "Contrato actualizado"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- VACACIONES ---
@router.get("/vacaciones/calendario")
def get_vacaciones_calendario():
    try:
        with engine_personal.connect() as conn:
            query = text("""
                SELECT v.*, e.nombre, e.depto 
                FROM public.rh_vacaciones v
                JOIN public.empleados e ON v.id_empleado = e.id_empleado
                WHERE v.estatus IN ('APROBADO', 'EN_GOCE')
                ORDER BY v.fecha_inicio_goce ASC
            """)
            rows = conn.execute(query).mappings().fetchall()
            result = []
            for r in rows:
                d = dict(r)
                d["nombre"] = safe_decode_hex(d.get("nombre", ""))
                d["depto"] = safe_decode_hex(d.get("depto", ""))
                result.append({k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in d.items()})
            return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/vacaciones/{id_empleado}")
def get_vacaciones(id_empleado: str):
    try:
        with engine_personal.connect() as conn:
            query_hist = text("SELECT * FROM public.rh_vacaciones WHERE id_empleado = :id ORDER BY anio_periodo DESC")
            rows = conn.execute(query_hist, {"id": id_empleado}).mappings().fetchall()
            historial = [{k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in r.items()} for r in rows]
            
            # Calcular resumen
            query_emp = text("SELECT fecha_ing FROM public.empleados WHERE id_empleado = :id")
            emp = conn.execute(query_emp, {"id": id_empleado}).mappings().first()
            
            dias_totales = calcular_dias_vacaciones_lft(emp["fecha_ing"] if emp else None)
            dias_tomados = sum([r["dias_tomados"] for r in rows if r["estatus"] in ("APROBADO", "EN_GOCE", "FINALIZADO")])
            
            resumen = {
                "dias_totales_acumulados": dias_totales,
                "dias_tomados": dias_tomados,
                "dias_pendientes": max(0, dias_totales - dias_tomados)
            }
            
            return {"historial": historial, "resumen": resumen}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/vacaciones")
def create_vacacion(payload: VacacionCreate):
    try:
        with engine_personal.begin() as conn:
            # Obtener empleado para calcular dias
            query_emp = text("SELECT fecha_ing FROM public.empleados WHERE id_empleado = :id")
            emp = conn.execute(query_emp, {"id": payload.id_empleado}).mappings().first()
            if not emp:
                raise HTTPException(status_code=404, detail="Empleado no encontrado")
                
            dias_corresp = calcular_dias_vacaciones_lft(emp["fecha_ing"])
            dias_pendientes = max(0, dias_corresp - payload.dias_tomados) # simplificado para este periodo
            
            data = payload.model_dump()
            data["dias_correspondientes"] = dias_corresp
            data["dias_pendientes"] = dias_pendientes
            data["estatus"] = "PENDIENTE"
            
            cols = list(data.keys())
            vals = [f":{c}" for c in cols]
            
            query = text(f"""
                INSERT INTO public.rh_vacaciones ({', '.join(cols)})
                VALUES ({', '.join(vals)})
                RETURNING id_vacacion
            """)
            res = conn.execute(query, data).mappings().first()
            id_vacacion = res["id_vacacion"]
            
            _registrar_historial(conn, data["id_empleado"], "SOLICITUD_VACACIONES", f"Periodo {data['fecha_inicio_goce']} a {data['fecha_fin_goce']}", "rh_vacaciones", str(id_vacacion), data.get("registrado_por", "SISTEMA"))
            
            return {"msg": "Vacaciones registradas", "id_vacacion": id_vacacion}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/vacaciones/{id_vacacion}")
def update_vacacion(id_vacacion: int, payload: VacacionUpdate):
    update_data = {k: v for k, v in payload.model_dump().items() if v is not None}
    if not update_data:
        return {"msg": "No hay campos para actualizar"}
        
    set_clauses = []
    params = {"id_vacacion": id_vacacion}
    for k, v in update_data.items():
        set_clauses.append(f"{k} = :{k}")
        params[k] = v
        
    query_str = f"UPDATE public.rh_vacaciones SET {', '.join(set_clauses)} WHERE id_vacacion = :id_vacacion RETURNING id_empleado"
    
    try:
        with engine_personal.begin() as conn:
            res = conn.execute(text(query_str), params).mappings().first()
            if res:
                _registrar_historial(conn, res["id_empleado"], "ACTUALIZACION_VACACIONES", f"Estatus/datos vacación ID {id_vacacion} actualizados", "rh_vacaciones", str(id_vacacion), update_data.get("aprobado_por", "SISTEMA"))
            return {"msg": "Vacaciones actualizadas"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- PERMISOS ---
@router.get("/permisos")
def get_permisos(id_empleado: Optional[str] = None, estatus: Optional[str] = None):
    try:
        with engine_personal.connect() as conn:
            conds = []
            params = {}
            if id_empleado:
                conds.append("id_empleado = :id_empleado")
                params["id_empleado"] = id_empleado
            if estatus:
                conds.append("estatus = :estatus")
                params["estatus"] = estatus
                
            where = f"WHERE {' AND '.join(conds)}" if conds else ""
            query = text(f"SELECT * FROM public.rh_permisos {where} ORDER BY fecha_solicitud DESC")
            
            rows = conn.execute(query, params).mappings().fetchall()
            return [{k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in r.items()} for r in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/permisos")
def create_permiso(payload: PermisoCreate):
    try:
        with engine_personal.begin() as conn:
            # Folio PER-YYYY-NNN
            anio = date.today().year
            query_count = text("SELECT COUNT(*) as c FROM public.rh_permisos WHERE EXTRACT(YEAR FROM fecha_registro) = :anio")
            count = conn.execute(query_count, {"anio": anio}).scalar() or 0
            folio = f"PER-{anio}-{count + 1:03d}"
            
            data = payload.model_dump()
            data["folio_permiso"] = folio
            data["dias_solicitados"] = max(1, (data["fecha_fin"] - data["fecha_inicio"]).days + 1)
            data["estatus"] = "PENDIENTE"
            
            cols = list(data.keys())
            vals = [f":{c}" for c in cols]
            
            query = text(f"""
                INSERT INTO public.rh_permisos ({', '.join(cols)})
                VALUES ({', '.join(vals)})
                RETURNING id_permiso
            """)
            res = conn.execute(query, data).mappings().first()
            id_permiso = res["id_permiso"]
            
            _registrar_historial(conn, data["id_empleado"], "NUEVO_PERMISO", f"Permiso {folio} de {data['dias_solicitados']} días", "rh_permisos", str(id_permiso), data.get("registrado_por", "SISTEMA"))
            
            return {"msg": "Permiso creado", "id_permiso": id_permiso, "folio": folio}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/permisos/{id_permiso}")
def update_permiso(id_permiso: int, payload: PermisoUpdate):
    update_data = {k: v for k, v in payload.model_dump().items() if v is not None}
    if not update_data:
        return {"msg": "No hay campos para actualizar"}
        
    set_clauses = []
    params = {"id_permiso": id_permiso}
    for k, v in update_data.items():
        set_clauses.append(f"{k} = :{k}")
        params[k] = v
        
    query_str = f"UPDATE public.rh_permisos SET {', '.join(set_clauses)} WHERE id_permiso = :id_permiso RETURNING *"
    
    try:
        with engine_personal.begin() as conn:
            row = conn.execute(text(query_str), params).mappings().first()
            if row:
                _registrar_historial(conn, row["id_empleado"], "ACTUALIZACION_PERMISO", f"Estatus permiso ID {id_permiso} actualizado a {row['estatus']}", "rh_permisos", str(id_permiso), update_data.get("aprobado_por", "SISTEMA"))
                
                # Inserción en control_asistencia si impacta (Lógica simplificada, asume tabla control_asistencia existe)
                if row.get("estatus") == "APROBADO" and row.get("impacta_asistencia") == True:
                    # Rango de fechas
                    fecha_actual = row["fecha_inicio"]
                    while fecha_actual <= row["fecha_fin"]:
                        try:
                            # Intentar insertar registro en control_asistencia
                            query_asist = text("""
                                INSERT INTO public.control_asistencia (num_empleado, fecha_jornada, tipo_movimiento, estatus, observaciones)
                                VALUES (:num_empleado, :fecha, 'PERMISO', 'PERMISO', 'Permiso aprobado desde RH')
                                ON CONFLICT DO NOTHING
                            """)
                            # Requiere que id_empleado sea un numero, extraemos si es formato VARCHAR(3) como 001
                            try:
                                num_emp = int(row["id_empleado"])
                                conn.execute(query_asist, {"num_empleado": num_emp, "fecha": fecha_actual})
                            except Exception as e:
                                print(f"⚠️ SILENCED ERROR in rh.py: {e}") # si id_empleado no es convertible a int, omitimos.
                        except Exception as e:
                            print(f"⚠️ SILENCED ERROR in rh.py: {e}")
                        fecha_actual += datetime.timedelta(days=1)
                        
            return {"msg": "Permiso actualizado"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- INCAPACIDADES ---
@router.get("/incapacidades/{id_empleado}")
def get_incapacidades(id_empleado: str):
    try:
        with engine_personal.connect() as conn:
            query = text("SELECT * FROM public.rh_incapacidades WHERE id_empleado = :id ORDER BY fecha_inicio DESC")
            rows = conn.execute(query, {"id": id_empleado}).mappings().fetchall()
            return [{k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in r.items()} for r in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/incapacidades")
def create_incapacidad(payload: IncapacidadCreate):
    try:
        with engine_personal.begin() as conn:
            # Folio INC-YYYY-NNN
            anio = date.today().year
            query_count = text("SELECT COUNT(*) as c FROM public.rh_incapacidades WHERE EXTRACT(YEAR FROM fecha_registro) = :anio")
            count = conn.execute(query_count, {"anio": anio}).scalar() or 0
            folio = f"INC-{anio}-{count + 1:03d}"
            
            data = payload.model_dump()
            data["folio_incapacidad"] = folio
            data["dias_incapacidad"] = max(1, (data["fecha_fin"] - data["fecha_inicio"]).days + 1)
            data["estatus"] = "ACTIVA"
            
            cols = list(data.keys())
            vals = [f":{c}" for c in cols]
            
            query = text(f"""
                INSERT INTO public.rh_incapacidades ({', '.join(cols)})
                VALUES ({', '.join(vals)})
                RETURNING id_incapacidad
            """)
            res = conn.execute(query, data).mappings().first()
            id_incapacidad = res["id_incapacidad"]
            
            _registrar_historial(conn, data["id_empleado"], "NUEVA_INCAPACIDAD", f"Incapacidad {folio}", "rh_incapacidades", str(id_incapacidad), data.get("registrado_por", "SISTEMA"))
            
            return {"msg": "Incapacidad registrada", "id_incapacidad": id_incapacidad, "folio": folio}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/incapacidades/{id_incapacidad}")
def update_incapacidad(id_incapacidad: int, payload: IncapacidadUpdate):
    update_data = {k: v for k, v in payload.model_dump().items() if v is not None}
    if not update_data:
        return {"msg": "No hay campos para actualizar"}
        
    set_clauses = []
    params = {"id_incapacidad": id_incapacidad}
    for k, v in update_data.items():
        set_clauses.append(f"{k} = :{k}")
        params[k] = v
        
    query_str = f"UPDATE public.rh_incapacidades SET {', '.join(set_clauses)} WHERE id_incapacidad = :id_incapacidad RETURNING id_empleado"
    
    try:
        with engine_personal.begin() as conn:
            res = conn.execute(text(query_str), params).mappings().first()
            if res:
                _registrar_historial(conn, res["id_empleado"], "ACTUALIZACION_INCAPACIDAD", f"Actualización incapacidad ID {id_incapacidad}", "rh_incapacidades", str(id_incapacidad), "SISTEMA")
            return {"msg": "Incapacidad actualizada"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- CAPACITACIÓN ---
@router.get("/capacitacion/{id_empleado}")
def get_capacitaciones(id_empleado: str):
    try:
        with engine_personal.connect() as conn:
            query = text("SELECT * FROM public.rh_capacitacion WHERE id_empleado = :id ORDER BY fecha_inicio DESC")
            rows = conn.execute(query, {"id": id_empleado}).mappings().fetchall()
            return [{k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in r.items()} for r in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/capacitacion")
def create_capacitacion(payload: CapacitacionCreate):
    data = payload.model_dump()
    cols = list(data.keys())
    vals = [f":{c}" for c in cols]
    
    try:
        with engine_personal.begin() as conn:
            query = text(f"""
                INSERT INTO public.rh_capacitacion ({', '.join(cols)})
                VALUES ({', '.join(vals)})
                RETURNING id_capacitacion
            """)
            res = conn.execute(query, data).mappings().first()
            id_capacitacion = res["id_capacitacion"]
            
            _registrar_historial(conn, data["id_empleado"], "NUEVA_CAPACITACION", f"Curso: {data['nombre_curso']}", "rh_capacitacion", str(id_capacitacion), data.get("registrado_por", "SISTEMA"))
            
            return {"msg": "Capacitación registrada", "id_capacitacion": id_capacitacion}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/capacitacion/{id_capacitacion}")
def update_capacitacion(id_capacitacion: int, payload: CapacitacionUpdate):
    update_data = {k: v for k, v in payload.model_dump().items() if v is not None}
    if not update_data:
        return {"msg": "No hay campos para actualizar"}
        
    set_clauses = []
    params = {"id_capacitacion": id_capacitacion}
    for k, v in update_data.items():
        set_clauses.append(f"{k} = :{k}")
        params[k] = v
        
    query_str = f"UPDATE public.rh_capacitacion SET {', '.join(set_clauses)} WHERE id_capacitacion = :id_capacitacion RETURNING id_empleado"
    
    try:
        with engine_personal.begin() as conn:
            res = conn.execute(text(query_str), params).mappings().first()
            if res:
                _registrar_historial(conn, res["id_empleado"], "ACTUALIZACION_CAPACITACION", f"Capacitacion ID {id_capacitacion} actualizada", "rh_capacitacion", str(id_capacitacion), "SISTEMA")
            return {"msg": "Capacitación actualizada"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- EVALUACIONES ---
@router.get("/evaluaciones/{id_empleado}")
def get_evaluaciones(id_empleado: str):
    try:
        with engine_personal.connect() as conn:
            query = text("SELECT * FROM public.rh_evaluaciones WHERE id_empleado = :id ORDER BY periodo DESC")
            rows = conn.execute(query, {"id": id_empleado}).mappings().fetchall()
            return [{k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in r.items()} for r in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/evaluaciones")
def create_evaluacion(payload: EvaluacionCreate):
    data = payload.model_dump()
    
    # Calcular promedio
    criterios = [data.get("puntualidad"), data.get("calidad_trabajo"), data.get("trabajo_equipo"), 
                 data.get("responsabilidad"), data.get("iniciativa"), data.get("comunicacion"), data.get("cumplimiento_objetivos")]
    
    calificacion_final = sum(criterios) / len(criterios)
    data["calificacion_final"] = round(calificacion_final, 2)
    
    if calificacion_final >= 9:
        data["nivel_desempeno"] = "EXCELENTE"
    elif calificacion_final >= 7:
        data["nivel_desempeno"] = "BUENO"
    elif calificacion_final >= 5:
        data["nivel_desempeno"] = "REGULAR"
    else:
        data["nivel_desempeno"] = "DEFICIENTE"

    cols = list(data.keys())
    vals = [f":{c}" for c in cols]
    
    try:
        with engine_personal.begin() as conn:
            query = text(f"""
                INSERT INTO public.rh_evaluaciones ({', '.join(cols)})
                VALUES ({', '.join(vals)})
                RETURNING id_evaluacion
            """)
            res = conn.execute(query, data).mappings().first()
            id_evaluacion = res["id_evaluacion"]
            
            _registrar_historial(conn, data["id_empleado"], "NUEVA_EVALUACION", f"Evaluación {data['periodo']} - Nivel: {data['nivel_desempeno']}", "rh_evaluaciones", str(id_evaluacion), data.get("registrado_por", "SISTEMA"))
            
            return {"msg": "Evaluación registrada", "id_evaluacion": id_evaluacion, "calificacion_final": data["calificacion_final"], "nivel_desempeno": data["nivel_desempeno"]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/evaluaciones/{id_evaluacion}")
def update_evaluacion(id_evaluacion: int, payload: EvaluacionUpdate):
    update_data = {k: v for k, v in payload.model_dump().items() if v is not None}
    if not update_data:
        return {"msg": "No hay campos para actualizar"}
        
    set_clauses = []
    params = {"id_evaluacion": id_evaluacion}
    for k, v in update_data.items():
        set_clauses.append(f"{k} = :{k}")
        params[k] = v
        
    query_str = f"UPDATE public.rh_evaluaciones SET {', '.join(set_clauses)} WHERE id_evaluacion = :id_evaluacion"
    
    try:
        with engine_personal.begin() as conn:
            conn.execute(text(query_str), params)
            return {"msg": "Evaluación actualizada"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- DOCUMENTOS ---
@router.get("/documentos/{id_empleado}")
def get_documentos(id_empleado: str):
    try:
        with engine_personal.connect() as conn:
            query = text("SELECT * FROM public.rh_documentos WHERE id_empleado = :id ORDER BY fecha_subida DESC")
            rows = conn.execute(query, {"id": id_empleado}).mappings().fetchall()
            return [{k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in r.items()} for r in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/documentos")
def create_documento(payload: DocumentoCreate):
    data = payload.model_dump()
    cols = list(data.keys())
    vals = [f":{c}" for c in cols]
    
    try:
        with engine_personal.begin() as conn:
            query = text(f"""
                INSERT INTO public.rh_documentos ({', '.join(cols)})
                VALUES ({', '.join(vals)})
                RETURNING id_documento
            """)
            res = conn.execute(query, data).mappings().first()
            return {"msg": "Documento registrado", "id_documento": res["id_documento"]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/documentos/{id_documento}")
def update_documento(id_documento: int, payload: DocumentoUpdate):
    update_data = {k: v for k, v in payload.model_dump().items() if v is not None}
    if not update_data:
        return {"msg": "No hay campos para actualizar"}
        
    set_clauses = []
    params = {"id_documento": id_documento}
    for k, v in update_data.items():
        set_clauses.append(f"{k} = :{k}")
        params[k] = v
        
    query_str = f"UPDATE public.rh_documentos SET {', '.join(set_clauses)} WHERE id_documento = :id_documento"
    
    try:
        with engine_personal.begin() as conn:
            conn.execute(text(query_str), params)
            return {"msg": "Documento actualizado"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/documentos/{id_documento}")
def delete_documento(id_documento: int):
    try:
        with engine_personal.begin() as conn:
            query = text("DELETE FROM public.rh_documentos WHERE id_documento = :id")
            conn.execute(query, {"id": id_documento})
            return {"msg": "Registro de documento eliminado"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- HISTORIAL ---
@router.get("/historial/{id_empleado}")
def get_historial(id_empleado: str):
    try:
        with engine_personal.connect() as conn:
            query = text("SELECT * FROM public.rh_historial WHERE id_empleado = :id ORDER BY fecha_evento DESC")
            rows = conn.execute(query, {"id": id_empleado}).mappings().fetchall()
            
            # TODO: Opcionalmente consultar de control_asistencia resumido por mes
            
            return [{k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in r.items()} for r in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- EXPEDIENTE COMPLETO ---
@router.get("/expediente/{id_empleado}")
def get_expediente(id_empleado: str):
    try:
        with engine_personal.connect() as conn:
            expediente = {}
            
            # Datos Personales
            q_emp = text("SELECT * FROM public.empleados WHERE id_empleado = :id")
            row_emp = conn.execute(q_emp, {"id": id_empleado}).mappings().first()
            if not row_emp:
                raise HTTPException(status_code=404, detail="Empleado no encontrado")
                
            d = dict(row_emp)
            d["nombre"] = safe_decode_hex(d.get("nombre", ""))
            d["depto"] = safe_decode_hex(d.get("depto", ""))
            expediente["datos_personales"] = {k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in d.items()}
            
            # Contrato Vigente
            q_ctr = text("SELECT * FROM public.rh_contratos WHERE id_empleado = :id AND estatus_contrato = 'VIGENTE' LIMIT 1")
            row_ctr = conn.execute(q_ctr, {"id": id_empleado}).mappings().first()
            expediente["contrato_vigente"] = {k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in row_ctr.items()} if row_ctr else None
            
            # Resumen vacaciones
            q_vac = text("SELECT * FROM public.rh_vacaciones WHERE id_empleado = :id")
            rows_vac = conn.execute(q_vac, {"id": id_empleado}).mappings().fetchall()
            dias_totales = calcular_dias_vacaciones_lft(row_emp.get("fecha_ing"))
            dias_tomados = sum([r["dias_tomados"] for r in rows_vac if r["estatus"] in ("APROBADO", "EN_GOCE", "FINALIZADO")])
            expediente["resumen_vacaciones"] = {
                "dias_totales_acumulados": dias_totales,
                "dias_tomados": dias_tomados,
                "dias_pendientes": max(0, dias_totales - dias_tomados),
                "ultimas_solicitudes": [{k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in r.items()} for r in rows_vac[:3]]
            }
            
            # Permisos Activos
            q_per = text("SELECT * FROM public.rh_permisos WHERE id_empleado = :id AND estatus IN ('PENDIENTE', 'APROBADO') AND fecha_fin >= CURRENT_DATE")
            rows_per = conn.execute(q_per, {"id": id_empleado}).mappings().fetchall()
            expediente["permisos_activos"] = [{k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in r.items()} for r in rows_per]
            
            # Incapacidades Activas
            q_inc = text("SELECT * FROM public.rh_incapacidades WHERE id_empleado = :id AND estatus = 'ACTIVA'")
            rows_inc = conn.execute(q_inc, {"id": id_empleado}).mappings().fetchall()
            expediente["incapacidades_activas"] = [{k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in r.items()} for r in rows_inc]
            
            # Documentos
            q_doc = text("SELECT * FROM public.rh_documentos WHERE id_empleado = :id")
            rows_doc = conn.execute(q_doc, {"id": id_empleado}).mappings().fetchall()
            expediente["documentos"] = [{k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in r.items()} for r in rows_doc]
            
            # Ultima evaluacion
            q_eval = text("SELECT * FROM public.rh_evaluaciones WHERE id_empleado = :id ORDER BY periodo DESC LIMIT 1")
            row_eval = conn.execute(q_eval, {"id": id_empleado}).mappings().first()
            expediente["ultima_evaluacion"] = {k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in row_eval.items()} if row_eval else None
            
            # Ultimas capacitaciones
            q_cap = text("SELECT * FROM public.rh_capacitacion WHERE id_empleado = :id ORDER BY fecha_inicio DESC LIMIT 3")
            rows_cap = conn.execute(q_cap, {"id": id_empleado}).mappings().fetchall()
            expediente["ultimas_capacitaciones"] = [{k: str(v) if isinstance(v, (date, time, datetime.datetime)) else v for k, v in r.items()} for r in rows_cap]
            
            return expediente
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ══════════════════════════════════════════════════════════════════════════════
# OCR — Lectura automática de documentos escaneados
# ══════════════════════════════════════════════════════════════════════════════

class OCRRequest(BaseModel):
    tipo_documento: str          # INE | CURP | NSS | RFC | ACTA NACIMIENTO | LICENCIA CONDUCIR | COMPROBANTE DOMICILIO | OTRO
    imagen_base64: str           # Imagen en base64 (JPG, PNG o PDF)
    formato: str = "JPG"         # JPG | PNG | PDF
    id_empleado: Optional[str] = None  # Si se provee, actualiza la BD al confirmar


@router.post("/documentos/ocr", summary="🔍 Leer documento escaneado con OCR")
def leer_documento_ocr(req: OCRRequest):
    """
    Recibe un documento escaneado en base64, aplica OCR y extrae los campos
    relevantes según el tipo de documento (INE, CURP, NSS, RFC, etc.).
    
    Retorna los campos detectados con nivel de confianza para revisión del usuario.
    Los campos NO se guardan automáticamente — requieren confirmación via PUT /empleados/{id}.
    """
    import base64
    try:
        # Decodificar imagen de base64
        # Remover prefijo data:image/...;base64, si viene del frontend
        b64_data = req.imagen_base64
        if "," in b64_data:
            b64_data = b64_data.split(",", 1)[1]
        
        imagen_bytes = base64.b64decode(b64_data)
        es_pdf = req.formato.upper() == "PDF"

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error decodificando imagen: {e}")

    try:
        from core.ocr_extractor import procesar_documento_ocr
        resultado = procesar_documento_ocr(
            imagen_bytes=imagen_bytes,
            tipo_documento=req.tipo_documento,
            es_pdf=es_pdf
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en OCR: {e}")

    if not resultado["exito"]:
        raise HTTPException(status_code=422, detail=resultado.get("error", "Error OCR desconocido"))

    return {
        "tipo_documento": req.tipo_documento,
        "campos_extraidos": resultado["campos_extraidos"],
        "texto_completo": resultado["texto_completo"],
        "total_campos": resultado["total_campos"],
        "confianza_global": resultado.get("confianza_global", 0),
        "id_empleado": req.id_empleado,
        "mensaje": f"Se detectaron {resultado['total_campos']} campo(s). Revisa y confirma antes de guardar."
    }


class OCRConfirmarRequest(BaseModel):
    id_empleado: str
    campos: Dict[str, Any]       # {campo_db_key: valor_confirmado}
    tipo_documento: str
    registrado_por: str = "RH"


@router.post("/documentos/ocr/confirmar", summary="💾 Confirmar y guardar campos OCR en BD")
def confirmar_campos_ocr(req: OCRConfirmarRequest):
    """
    Recibe los campos revisados/confirmados por el usuario y los guarda en
    la tabla empleados y/o rh_documentos según corresponda.
    
    Mapeo de campos soportados:
      - nombre, curp, nss, rfc, fecha_nac, domicilio, cp, ciudad, licencia_vence
        → tabla empleados
      - fecha_vencimiento
        → rh_documentos (actualiza el último documento del empleado)
    """
    # Campos que van a empleados
    CAMPOS_EMPLEADOS = {
        "nombre", "curp", "nss", "rfc", "fecha_nac",
        "domicilio", "cp", "ciudad", "licencia_vence",
        "fecha_nacimiento"  # alias
    }
    ALIAS = {
        "fecha_nacimiento": "fecha_nac",
        "vencimiento": None,  # va a rh_documentos
    }

    campos_emp = {}
    fecha_vencimiento = None

    for campo, valor in req.campos.items():
        if not valor or str(valor).strip() in ("", "—", "None"):
            continue
        campo_real = ALIAS.get(campo, campo)
        if campo_real is None:
            # Es fecha de vencimiento para rh_documentos
            fecha_vencimiento = valor
        elif campo_real in CAMPOS_EMPLEADOS:
            # Convertir fecha DD/MM/AAAA → AAAA-MM-DD para PostgreSQL
            if campo_real in ("fecha_nac", "licencia_vence") and "/" in str(valor):
                partes = str(valor).split("/")
                if len(partes) == 3:
                    try:
                        valor = f"{partes[2]}-{partes[1].zfill(2)}-{partes[0].zfill(2)}"
                    except Exception as e:
                        print(f"⚠️ SILENCED ERROR in rh.py: {e}")
            campos_emp[campo_real] = valor

    if not campos_emp and not fecha_vencimiento:
        raise HTTPException(status_code=400, detail="No hay campos válidos para guardar.")

    try:
        with engine_personal.begin() as conn:
            actualizados = []

            # Actualizar tabla empleados
            if campos_emp:
                set_parts = [f"{k} = :{k}" for k in campos_emp]
                query_emp = text(
                    f"UPDATE public.empleados SET {', '.join(set_parts)} "
                    f"WHERE id_empleado = :id_empleado"
                )
                params_emp = {**campos_emp, "id_empleado": req.id_empleado}
                conn.execute(query_emp, params_emp)
                actualizados.extend(list(campos_emp.keys()))

            # Actualizar fecha_vencimiento en el último documento registrado
            if fecha_vencimiento:
                # Convertir si es necesario
                if "/" in str(fecha_vencimiento):
                    partes = str(fecha_vencimiento).split("/")
                    if len(partes) == 3:
                        try:
                            fecha_vencimiento = f"{partes[2]}-{partes[1].zfill(2)}-{partes[0].zfill(2)}"
                        except Exception as e:
                            print(f"⚠️ SILENCED ERROR in rh.py: {e}")
                conn.execute(text("""
                    UPDATE public.rh_documentos
                    SET fecha_vencimiento = :fv
                    WHERE id_empleado = :ide
                    AND id_documento = (
                        SELECT id_documento FROM public.rh_documentos
                        WHERE id_empleado = :ide
                        ORDER BY fecha_subida DESC LIMIT 1
                    )
                """), {"fv": fecha_vencimiento, "ide": req.id_empleado})
                actualizados.append("fecha_vencimiento (documento)")

            # Registrar en historial
            desc = (
                f"Datos actualizados via OCR ({req.tipo_documento}): "
                + ", ".join(actualizados)
            )
            _registrar_historial(
                conn, req.id_empleado,
                "ACTUALIZACIÓN", desc,
                "empleados", None,
                req.registrado_por, automatico=True
            )

        return {
            "exito": True,
            "campos_guardados": actualizados,
            "mensaje": f"✅ {len(actualizados)} campo(s) guardados correctamente en la BD."
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
