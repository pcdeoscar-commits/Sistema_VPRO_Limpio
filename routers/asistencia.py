import datetime
import unicodedata
from datetime import date, time
from typing import List, Optional, Dict, Any
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from sqlalchemy import text

from core.database import engine_personal, engine_eventos
from core.utils import safe_decode_hex, parse_pg_array, reparar_mojibake

router = APIRouter(prefix="/api/asistencia", tags=["⏱️ Asistencia y Kiosco"])

# --- MODELOS PYDANTIC ---
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

class ChecadaPayload(BaseModel):
    id_empleado: str
    tipo_movimiento: Optional[str] = "CHEQUEO"
    estatus: str
    observaciones: str

class SellarRutaExactaPayload(BaseModel):
    id_evento: int
    folio: str
    fecha: str
    hora_personalizada: str
    tipo_movimiento: str
    personal: List[str]
    estatus_dinamico: str

class FiltroAsistencia(BaseModel):
    fecha_inicio: str
    fecha_fin: str
    empleado: Optional[str] = None

class ComisionLocalPayload(BaseModel):
    id_empleado: str
    fecha: str
    cliente_o_motivo: str
    tipo_jornada: Optional[str] = "TARDE"

class AutorizarHorasExtrasPayload(BaseModel):
    ids_autorizacion: List[int]
    aprobado_por: str
    accion: Optional[str] = "APROBAR"
    observaciones: Optional[str] = ""

# --- RUTAS DE ASISTENCIA LOCACIÓN Y COMISIÓN ---

@router.get("/ops-activas-empleado/{nombre_empleado}", tags=["⏱️ Asistencia y Kiosco"])
def obtener_ops_activas_empleado(nombre_empleado: str):
    """Retorna las Órdenes de Producción activas donde el empleado está convocado oficialmente."""
    query = text("""
        SELECT e.id_evento, e.folio, e.nombre_evento, e.para_q_cliente, e.personal_convocado_op
        FROM public.eventos e
        WHERE UPPER(COALESCE(e.estatus, 'ACTIVA')) != 'CERRADA (HISTÓRICO)'
          AND NOT EXISTS (
              SELECT 1 FROM public.informes_gastos_maestro igm 
              WHERE igm.folio_vpro = e.id_evento
          )
        ORDER BY e.id_evento DESC
    """)
    try:
        with engine_eventos.connect() as conn:
            rows = conn.execute(query).mappings().fetchall()

        nom_buscado = nombre_empleado.strip().upper()
        ops_asignadas = []
        for r in rows:
            convocados = [str(p).strip().upper() for p in parse_pg_array(r.get("personal_convocado_op"))]
            if nom_buscado in convocados:
                folio = r.get("folio") or str(r.get("id_evento"))
                cliente = reparar_mojibake(r.get("para_q_cliente")) or "Cliente General"
                evento = reparar_mojibake(r.get("nombre_evento")) or "Evento"
                etiqueta = f"OP-{str(folio).zfill(3)} | {cliente} - {evento}"
                ops_asignadas.append({
                    "id_evento": r.get("id_evento"),
                    "folio": folio,
                    "etiqueta": etiqueta
                })
        return ops_asignadas
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/locacion/hoy/{nombre_empleado}", tags=["⏱️ Asistencia Locación"])
def asistencia_locacion_hoy_individual(nombre_empleado: str):
    """Busca si el empleado tiene registros de gira/locación el día de hoy."""
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
            
            folio = safe_decode_hex(row_dict.get('folio_hex', '')) if row_dict.get('folio_hex') else "S/F"
            evento = safe_decode_hex(row_dict.get('evento_hex', '')) if row_dict.get('evento_hex') else "Evento Locación"
            row_dict['evento_str'] = f"{folio} | {evento}"
            
            result.append(row_dict)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/locacion/todas", tags=["⏱️ Asistencia Locación"])
def obtener_todas_las_locaciones():
    """Obtiene todo el historial de jornadas de TODAS las OPs."""
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
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/locacion/{id_evento}", tags=["⏱️ Asistencia Locación"])
def obtener_asistencia_evento(id_evento: int):
    """Obtiene todo el historial de jornadas de una OP en específico."""
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
            row_dict['fecha_jornada'] = str(row_dict['fecha_jornada'])
            row_dict['hora_entrada'] = str(row_dict['hora_entrada'])
            row_dict['hora_salida'] = str(row_dict['hora_salida'])
            if row_dict.get('fecha_registro'):
                row_dict['fecha_registro'] = str(row_dict['fecha_registro'])
            result.append(row_dict)
            
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/locacion/{id_evento}", tags=["⏱️ Asistencia Locación"])
def guardar_asistencia_evento(id_evento: int, payload: AsistenciaBatch):
    """Guarda una jornada completa en locación reemplazando fechas existentes.
    🔒 CANDADO DE SEGURIDAD: Valida estrictamente que cada empleado esté convocado en la OP.
    """
    try:
        with engine_eventos.begin() as conn:
            # 1. Consultar la lista oficial de personal convocado para esta OP
            op_row = conn.execute(
                text("SELECT folio, nombre_evento, personal_convocado_op FROM public.eventos WHERE id_evento = :id"),
                {"id": id_evento}
            ).mappings().first()
            
            if not op_row:
                raise HTTPException(status_code=404, detail=f"No se encontró la Orden de Producción #{id_evento}.")
            
            folio_op = op_row.get("folio") or str(id_evento)
            raw_convocados = parse_pg_array(op_row.get("personal_convocado_op"))
            personal_autorizado = {str(p).strip().upper() for p in raw_convocados if str(p).strip()}
            
            if not personal_autorizado:
                raise HTTPException(
                    status_code=400, 
                    detail=f"⚠️ La OP-{folio_op} no tiene personal seleccionado en 'SELECCIONAR PERSONAL VPRO'. Debe asignar personal a la orden antes de registrar bitácora foránea."
                )
            
            # 2. Validar que cada empleado en el payload esté en la lista convocada
            for reg in payload.registros:
                nom_emp = str(reg.nombre_empleado).strip().upper()
                if nom_emp not in personal_autorizado:
                    raise HTTPException(
                        status_code=400,
                        detail=f"⛔ Acceso denegado: El empleado '{reg.nombre_empleado}' NO está seleccionado en el personal convocado de la OP-{folio_op}. No se le puede tomar asistencia fuera de la ciudad."
                    )

            fechas_en_batch = list(set([r.fecha_jornada for r in payload.registros]))
            
            if fechas_en_batch:
                del_query = text("""
                    DELETE FROM public.asistencia_locacion 
                    WHERE id_evento = :id_evento AND fecha_jornada = :fecha
                """)
                for f in fechas_en_batch:
                    conn.execute(del_query, {"id_evento": id_evento, "fecha": f})

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
                
        return {"status": "success", "msg": f"Se guardaron {len(datos_insert)} registros correctamente para la OP-{folio_op}."}
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/auditoria", tags=["⏱️ Asistencia y Kiosco"])
def obtener_auditoria_asistencia(filtro: FiltroAsistencia):
    """Genera el reporte gerencial de asistencias combinando checador físico y giras en un solo renglón por día."""
    try:
        def _norm_nom(n: str) -> str:
            if not n: return ""
            return ''.join(c for c in unicodedata.normalize('NFD', str(n).strip().upper()) if unicodedata.category(c) != 'Mn')

        def _es_valida(h) -> bool:
            if not h: return False
            s = str(h).strip()
            return s not in ["", "None", "null", "00:00:00", "00:00", "0:00", "--:--"]

        def _fmt_h(h) -> str:
            if not _es_valida(h): return ""
            return str(h).strip()[:8]

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

        query_gira = """
            SELECT 
                al.fecha_jornada as fecha, 
                al.nombre_empleado as nombre, 
                al.hora_entrada, 
                al.hora_salida, 
                al.t_desayuno, 
                al.t_comida, 
                al.t_cena, 
                al.observaciones,
                COALESCE(e.folio::text, e.id_evento::text) as folio_op,
                e.nombre_evento
            FROM public.asistencia_locacion al
            LEFT JOIN public.eventos e ON al.id_evento = e.id_evento
            WHERE al.fecha_jornada >= CAST(:f_ini AS DATE) 
              AND al.fecha_jornada <= CAST(:f_fin AS DATE)
        """
        params_gira = {"f_ini": filtro.fecha_inicio, "f_fin": filtro.fecha_fin}
        if filtro.empleado and filtro.empleado != "👥 TODOS":
            query_gira += " AND TRIM(al.nombre_empleado) = TRIM(:emp)"
            params_gira["emp"] = filtro.empleado

        with engine_eventos.connect() as conn2:
            res_gira = conn2.execute(text(query_gira), params_gira).mappings().all()

        mapa_combinado = {}

        for r in res_oficina:
            f_str = str(r['fecha']) if r['fecha'] else ""
            nom = str(r['nombre']).strip() if r['nombre'] else ""
            key = (f_str, _norm_nom(nom))
            
            h_sal_v_str = _fmt_h(r['hora_salida_v'])
            obs_of = str(r['observaciones']).strip() if r.get('observaciones') else ""
            if h_sal_v_str and ("(+1D)" in obs_of.upper() or "MADRUGADA" in obs_of.upper()) and "(+1D)" not in h_sal_v_str.upper():
                h_sal_v_str = h_sal_v_str[:5] + " (+1d)"

            mapa_combinado[key] = {
                "fecha": f_str,
                "nombre": nom,
                "hora_entrada": _fmt_h(r['hora_entrada']),
                "hora_salida": _fmt_h(r['hora_salida']),
                "hora_entrada_v": _fmt_h(r['hora_entrada_v']) or "--:--",
                "hora_salida_v": h_sal_v_str or "--:--",
                "observaciones": obs_of
            }

        for r in res_gira:
            f_str = str(r['fecha']) if r['fecha'] else ""
            nom = str(r['nombre']).strip() if r['nombre'] else ""
            key = (f_str, _norm_nom(nom))

            t_des = float(r.get('t_desayuno') or 0.0)
            t_com = float(r.get('t_comida') or 0.0)
            t_cen = float(r.get('t_cena') or 0.0)
            obs_gira_orig = str(r.get('observaciones') or "").strip()
            texto_comidas = f" (Alimentos: {t_des:.2f}D/{t_com:.2f}C/{t_cen:.2f}C)" if (t_des > 0 or t_com > 0 or t_cen > 0) else ""
            folio = r.get('folio_op')
            nom_ev = reparar_mojibake(r.get('nombre_evento'))
            op_info = f" OP-{folio} - {nom_ev}" if (folio and nom_ev) else ""
            nota_gira = f"📍 [EN GIRA]{op_info}{texto_comidas} {obs_gira_orig}".strip()

            gira_in = _fmt_h(r['hora_entrada'])
            gira_out = _fmt_h(r['hora_salida'])

            if key not in mapa_combinado:
                mapa_combinado[key] = {
                    "fecha": f_str,
                    "nombre": nom,
                    "hora_entrada": gira_in or ("00:00:00" if str(r['hora_entrada']).strip()[:5] == "00:00" else ""),
                    "hora_salida": gira_out or ("00:00:00" if str(r['hora_salida']).strip()[:5] == "00:00" else ""),
                    "hora_entrada_v": "--:--",
                    "hora_salida_v": "--:--",
                    "observaciones": nota_gira
                }
            else:
                # 🌟 ¡FUSIÓN INTELIGENTE EN EL MISMO RENGLÓN!
                reg = mapa_combinado[key]
                of_in = reg['hora_entrada']
                of_out = reg['hora_salida']

                # 1. Unificar Entrada Matutina
                if not _es_valida(of_in) and _es_valida(gira_in):
                    reg['hora_entrada'] = gira_in
                elif _es_valida(of_in) and _es_valida(gira_in):
                    # Si checó en oficina después de las 12:00 y la gira empezó antes de las 12:00,
                    # la checada de oficina fue salida matutina (comida), no entrada
                    if of_in >= "12:00:00" and gira_in < "12:00:00":
                        if not _es_valida(of_out):
                            reg['hora_salida'] = of_in
                        reg['hora_entrada'] = gira_in
                    else:
                        reg['hora_entrada'] = min(of_in, gira_in)

                # 2. Unificar Salida Matutina / Jornada
                if not _es_valida(reg['hora_salida']) and _es_valida(gira_out):
                    if gira_out >= "18:00:00":
                        if not _es_valida(reg['hora_salida_v']):
                            reg['hora_salida_v'] = gira_out
                        else:
                            reg['hora_salida_v'] = max(reg['hora_salida_v'], gira_out)
                    else:
                        reg['hora_salida'] = gira_out
                elif _es_valida(reg['hora_salida']) and _es_valida(gira_out):
                    if gira_out >= "18:00:00":
                        if not _es_valida(reg['hora_salida_v']):
                            reg['hora_salida_v'] = gira_out
                            if reg['hora_salida'] >= "18:00:00":
                                reg['hora_salida'] = "--:--"
                        else:
                            reg['hora_salida_v'] = max(reg['hora_salida_v'], gira_out)
                    else:
                        reg['hora_salida'] = max(reg['hora_salida'], gira_out)

                # 3. Unificar Observaciones
                obs_act = reg.get('observaciones', '').strip()
                if nota_gira and nota_gira not in obs_act and "EN GIRA" not in obs_act.upper():
                    reg['observaciones'] = f"{obs_act} | {nota_gira}".strip(" |")

        # Asegurar que cualquier salida de fin de jornada (>= 18:00:00) esté en el turno vespertino
        for reg in mapa_combinado.values():
            if _es_valida(reg.get('hora_salida')) and reg['hora_salida'] >= "18:00:00" and not _es_valida(reg.get('hora_salida_v')):
                reg['hora_salida_v'] = reg['hora_salida']
                reg['hora_salida'] = "--:--"

        datos_limpios = list(mapa_combinado.values())
        datos_limpios.sort(key=lambda x: (x['fecha'], x['nombre']), reverse=True)
        return datos_limpios
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- RUTAS DE CHECADOR (KIOSCO) ---

@router.get("/status/{id_empleado}", tags=["🕒 Checador Asistencia"])
def extraer_estado_asistencia_diaria(id_empleado: str):
    """Consulta el estatus actual de asistencia del empleado hoy."""
    ahora = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(hours=7)
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

        # 🔍 Si no hay registro en oficina hoy, revisar si coordinación registró entrada en Gira
        query_emp = text("SELECT nombre FROM public.empleados WHERE TRIM(id_empleado) = :emp LIMIT 1")
        with engine_personal.connect() as conn_emp:
            row_emp = conn_emp.execute(query_emp, {"emp": id_empleado.strip()}).mappings().first()
        
        if row_emp and row_emp.get("nombre"):
            nom_emp = str(row_emp["nombre"]).strip()
            query_loc = text("""
                SELECT id_asistencia, hora_entrada, hora_salida, observaciones 
                FROM public.asistencia_locacion 
                WHERE fecha_jornada = CAST(:hoy AS date) 
                  AND TRIM(nombre_empleado) = :nom
                ORDER BY id_asistencia DESC LIMIT 1
            """)
            with engine_eventos.connect() as conn_ev:
                row_loc = conn_ev.execute(query_loc, {"hoy": hoy_str, "nom": nom_emp}).mappings().first()
            
            if row_loc and row_loc.get("hora_entrada"):
                h_in_str = str(row_loc["hora_entrada"]).strip()
                h_out_str = str(row_loc["hora_salida"]).strip() if row_loc.get("hora_salida") else ""
                if h_in_str not in ["", "None", "00:00:00", "00:00"] and h_out_str in ["", "None", "00:00:00", "00:00"]:
                    return {
                        "registrado": True,
                        "id_registro": None,
                        "hora_entrada": h_in_str[:8],
                        "hora_salida": None,
                        "hora_entrada_v": None,
                        "hora_salida_v": None,
                        "estatus": "GIRA / LOCACIÓN",
                        "observaciones": f"📍 [EN GIRA] Entrada Coord.: {h_in_str[:5]}",
                        "completo": False
                    }

        return {"registrado": False, "completo": False}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/checar", tags=["🕒 Checador Asistencia"])
def registrar_tarjetazo_asistencia(payload: ChecadaPayload):
    """Registra la marca de asistencia (entrada/salida matutina o vespertina)."""
    ahora = datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None) - datetime.timedelta(hours=7)
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
                # 🌙 REGLA DE MADRUGADA (< 06:00 AM): CRUCE DE MEDIANOCHE / JORNADA EXTENDIDA
                if hora_str < "06:00:00":
                    ayer = ahora.date() - datetime.timedelta(days=1)
                    ayer_str = ayer.strftime('%Y-%m-%d')
                    registro_ayer = conn.execute(text("""
                        SELECT id_registro, hora_entrada, hora_salida, hora_entrada_v, hora_salida_v, observaciones
                        FROM public.control_asistencia
                        WHERE TRIM(id_empleado) = :emp AND fecha = CAST(:ayer AS date)
                        ORDER BY id_registro DESC LIMIT 1
                    """), {"emp": payload.id_empleado.strip(), "ayer": ayer_str}).mappings().first()

                    if registro_ayer and registro_ayer["hora_salida_v"] is None:
                        row_emp = conn.execute(text("SELECT nombre FROM public.empleados WHERE TRIM(id_empleado) = :emp LIMIT 1"), {"emp": payload.id_empleado.strip()}).mappings().first()
                        nom_emp = str(row_emp["nombre"]).strip() if row_emp else "Empleado"

                        # Buscar OP activa de los últimos 2 días donde el empleado esté convocado
                        evento_op = None
                        try:
                            with engine_eventos.connect() as conn_ev:
                                ops = conn_ev.execute(text("""
                                    SELECT id_evento, folio, nombre_evento, resp_de_produccion, personal_convocado_op
                                    FROM public.eventos
                                    WHERE fec_del_evento >= CAST(:ayer AS date) - INTERVAL '2 days'
                                      AND fec_del_evento <= CAST(:ayer AS date)
                                    ORDER BY id_evento DESC
                                """), {"ayer": ayer_str}).mappings().all()

                                def _clean_txt(txt):
                                    return ''.join(c for c in unicodedata.normalize('NFD', str(txt).strip().upper()) if unicodedata.category(c) != 'Mn')

                                for op in ops:
                                    personal_lista = parse_pg_array(str(op.get("personal_convocado_op", ""))) if isinstance(op.get("personal_convocado_op"), str) else (op.get("personal_convocado_op") or [])
                                    if any(_clean_txt(nom_emp) in _clean_txt(str(p)) for p in personal_lista):
                                        evento_op = op
                                        break
                        except Exception as e:
                            print(f"⚠️ SILENCED ERROR in asistencia.py: {e}")

                        id_ev = evento_op["id_evento"] if evento_op else None
                        folio = evento_op["folio"] if evento_op else (str(id_ev) if id_ev else "S/N")
                        nom_ev = reparar_mojibake(evento_op["nombre_evento"]) if evento_op else "Servicio Nocturno / Oficina"
                        productor = evento_op["resp_de_produccion"] if evento_op else "Administración VPRO"

                        # ── SPLIT DE JORNADA NOCTURNA ─────────────────────────────────────────
                        # Día anterior: cerrar la jornada a 23:59:59 (fin del día laboral)
                        obs_ayer = (registro_ayer["observaciones"] or "").strip()
                        nota_op = f"📍 [EN GIRA] OP-{folio} - {nom_ev}" if (evento_op and "EN GIRA" not in obs_ayer.upper()) else ""
                        # Limpiar cualquier tag previo de madrugada y armar obs del día anterior
                        import re as _re
                        obs_ayer_limpia = _re.sub(r'\s*\|\s*🌙[^|]*', '', obs_ayer, flags=_re.IGNORECASE).strip().strip("|").strip()
                        piezas_ayer = [p for p in [obs_ayer_limpia, nota_op] if p]
                        obs_dia_ant = " | ".join(piezas_ayer)

                        conn.execute(text("""
                            UPDATE public.control_asistencia
                            SET hora_salida_v = '23:59:59'::time,
                                observaciones = :obs
                            WHERE id_registro = :id
                        """), {"obs": obs_dia_ant, "id": registro_ayer["id_registro"]})

                        # Día actual (madrugada): insertar nuevo registro con hora_entrada=00:00
                        # y hora_salida_v = hora real de la madrugada
                        from core.utils import es_feriado_mexico as _es_fer
                        _es_feriado, _nom_fer = _es_fer(ahora.date())
                        if _es_feriado:
                            obs_hoy_base = f"🗓️ Día no laborable ({_nom_fer})"
                        else:
                            obs_hoy_base = "🌙 Continuación jornada nocturna"
                        nota_op_hoy = f"📍 [EN GIRA] OP-{folio} - {nom_ev}" if evento_op else ""
                        piezas_hoy = [p for p in [obs_hoy_base, nota_op_hoy] if p]
                        obs_dia_hoy = " | ".join(piezas_hoy)

                        conn.execute(text("""
                            INSERT INTO public.control_asistencia
                                (id_empleado, fecha, hora_entrada, hora_salida, hora_entrada_v, hora_salida_v, estatus, observaciones)
                            VALUES
                                (:emp, CAST(:hoy AS date), '00:00:00'::time, NULL, NULL,
                                 CAST(:hora_mad AS time), :estatus, :obs)
                            ON CONFLICT DO NOTHING
                        """), {
                            "emp": payload.id_empleado.strip(),
                            "hoy": hoy_str,
                            "hora_mad": hora_str,
                            "estatus": "GIRA / LOCACIÓN" if evento_op else "ASISTENCIA",
                            "obs": obs_dia_hoy
                        })

                        # Corte Ordinario: 14:00 si fue Sábado, 19:00 L-V
                        h_corte = datetime.time(14, 0, 0) if ayer.weekday() == 5 else datetime.time(19, 0, 0)
                        mins_antes_medianoche = ((24 - h_corte.hour) * 60) - h_corte.minute
                        h_madrugada = ahora.time()
                        mins_despues_medianoche = (h_madrugada.hour * 60) + h_madrugada.minute
                        total_mins_extra = max(0, mins_antes_medianoche + mins_despues_medianoche)
                        horas_extra = round(total_mins_extra / 60.0, 2)

                        conn.execute(text("""
                            INSERT INTO public.control_horas_extras (
                                id_registro_asistencia, id_empleado, nombre_empleado,
                                id_evento, folio_op, nombre_evento, productor_responsable,
                                fecha_jornada, hora_entrada, hora_salida_madrugada,
                                corte_ordinario, horas_extra_calculadas, estatus_aprobacion, observaciones
                            ) VALUES (
                                :id_reg, :emp, :nom,
                                :id_ev, :fol, :nom_ev, :prod,
                                CAST(:ayer AS date), :h_ent, CAST(:h_sal AS time),
                                CAST(:corte AS time), :he, 'PENDIENTE', :obs_he
                            )
                        """), {
                            "id_reg": registro_ayer["id_registro"],
                            "emp": payload.id_empleado.strip(),
                            "nom": nom_emp,
                            "id_ev": id_ev,
                            "fol": folio,
                            "nom_ev": nom_ev,
                            "prod": productor,
                            "ayer": ayer_str,
                            "h_ent": registro_ayer["hora_entrada"],
                            "h_sal": hora_str,
                            "corte": h_corte.strftime('%H:%M:%S'),
                            "he": horas_extra,
                            "obs_he": f"Jornada nocturna {ayer_str} → {hoy_str} ({horas_extra} hrs extras)"
                        })

                        return {
                            "status": "SUCCESS",
                            "mensaje": f"🌙 JORNADA NOCTURNA REGISTRADA. Salida {ayer_str} 23:59 / Entrada {hoy_str} 00:00 / Salida {hora_str[:5]}. Horas extras enviadas a visto bueno."
                        }

                # 🔍 Verificar si ya existía entrada en gira por el coordinador
                query_emp = text("SELECT nombre FROM public.empleados WHERE TRIM(id_empleado) = :emp LIMIT 1")
                row_emp = conn.execute(query_emp, {"emp": payload.id_empleado.strip()}).mappings().first()
                loc_entrada = None
                if row_emp and row_emp.get("nombre"):
                    nom_emp = str(row_emp["nombre"]).strip()
                    try:
                        with engine_eventos.begin() as conn_ev:
                            row_loc = conn_ev.execute(text("""
                                SELECT id_asistencia, hora_entrada, hora_salida 
                                FROM public.asistencia_locacion 
                                WHERE fecha_jornada = CAST(:hoy AS date) 
                                  AND TRIM(nombre_empleado) = :nom
                                ORDER BY id_asistencia DESC LIMIT 1
                            """), {"hoy": hoy_str, "nom": nom_emp}).mappings().first()
                            if row_loc and row_loc.get("hora_entrada"):
                                h_in_loc = str(row_loc["hora_entrada"]).strip()
                                h_out_loc = str(row_loc["hora_salida"]).strip() if row_loc.get("hora_salida") else ""
                                if h_in_loc not in ["", "None", "00:00:00", "00:00"] and h_out_loc in ["", "None", "00:00:00", "00:00"]:
                                    loc_entrada = h_in_loc
                                    conn_ev.execute(text("""
                                        UPDATE public.asistencia_locacion 
                                        SET hora_salida = CAST(:hora AS time) 
                                        WHERE id_asistencia = :id
                                    """), {"hora": hora_str, "id": row_loc["id_asistencia"]})
                    except Exception as e:
                        print(f"⚠️ SILENCED ERROR in asistencia.py: {e}")

                if loc_entrada:
                    # El empleado ya tenía entrada matutina en gira: esta checada en Kiosco es su SALIDA MATUTINA (comida)
                    obs_fusion = f"📍 [EN GIRA] Entrada: {loc_entrada[:5]} | Kiosco - Salida Matutina / Comida"
                    conn.execute(text("""
                        INSERT INTO public.control_asistencia (id_empleado, fecha, hora_entrada, hora_salida, estatus, observaciones)
                        VALUES (:emp, CAST(:hoy AS date), CAST(:h_in AS time), CAST(:h_out AS time), 'GIRA / COMIDA', :obs)
                    """), {"emp": payload.id_empleado.strip(), "hoy": hoy_str, "h_in": loc_entrada, "h_out": hora_str, "obs": obs_fusion})
                    return {"status": "SUCCESS", "mensaje": "✅ SALIDA MATUTINA REGISTRADA (Continuación de Gira)"}
                else:
                    conn.execute(text("""
                        INSERT INTO public.control_asistencia (id_empleado, fecha, hora_entrada, estatus, observaciones)
                        VALUES (:emp, CAST(:hoy AS date), CAST(:hora AS time), :est, :obs)
                    """), {"emp": payload.id_empleado.strip(), "hoy": hoy_str, "hora": hora_str, "est": payload.estatus, "obs": payload.observaciones})
                    return {"status": "SUCCESS", "mensaje": "✅ ENTRADA MATUTINA REGISTRADA"}

            id_reg = registro_hoy["id_registro"]

            if registro_hoy["hora_entrada"] is not None and registro_hoy["hora_salida"] is None:
                # 🔍 Consultar datos del empleado para verificar excepción de Villarreal
                row_emp = conn.execute(text("SELECT nombre FROM public.empleados WHERE TRIM(id_empleado) = :emp LIMIT 1"), {"emp": payload.id_empleado.strip()}).mappings().first()
                nom_emp = str(row_emp["nombre"]).strip() if row_emp and row_emp.get("nombre") else "Empleado"
                es_villarreal = "VILLARREAL" in nom_emp.upper()

                # Si checa después de las 16:30:00, ya no es salida a comer, es salida de fin de jornada
                if hora_str >= "16:30:00":
                    if not es_villarreal:
                        # 🚨 PRÁCTICA IRRESPONSABLE DETECTADA: Entrada matutina y salida nocturna sin checar comida
                        obs_omision = "🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)"
                        conn.execute(text("""
                            UPDATE public.control_asistencia 
                            SET hora_salida_v = CAST(:hora AS time), 
                                estatus = 'OMISIÓN COMIDA',
                                observaciones = COALESCE(observaciones, '') || ' | ' || :obs
                            WHERE id_registro = :id
                        """), {"hora": hora_str, "obs": obs_omision, "id": id_reg})
                        
                        msg_adv = f"⚠️ ATENCIÓN {nom_emp}: Registraste entrada en la mañana pero OMITISTE registrar tu salida y regreso de comida. Checar solo entrada y salida corrida es una práctica incorrecta y no autorizada."
                        return {
                            "status": "WARNING",
                            "mensaje": "⚠️ SALIDA REGISTRADA CON ADVERTENCIA: Omitiste tus horarios de comida.",
                            "advertencia": msg_adv
                        }
                    else:
                        # Excepción oficial: Familia Villarreal registra salida vespertina limpia
                        conn.execute(text("""
                            UPDATE public.control_asistencia 
                            SET hora_salida_v = CAST(:hora AS time), 
                                observaciones = COALESCE(observaciones, '') || ' | ' || :obs 
                            WHERE id_registro = :id
                        """), {"hora": hora_str, "obs": payload.observaciones, "id": id_reg})
                        return {"status": "SUCCESS", "mensaje": "✅ SALIDA VESPERTINA REGISTRADA"}
                else:
                    # Checada normal antes de las 16:30:00 -> Salida a comer
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
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/reporte", tags=["🕒 Checador Asistencia"])
def obtener_reporte_asistencia_global():
    """Extrae la bitácora completa de asistencias."""
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
                "hora_salida_v": (str(r[10])[:5] + " (+1d)") if (r[10] and ("(+1D)" in str(r[8]).upper() or "MADRUGADA" in str(r[8]).upper()) and "(+1D)" not in str(r[10]).upper()) else (str(r[10]) if r[10] else None)
            })
        return reporte_list
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en consulta de asistencia: {str(e)}")

@router.post("/sellar-ruta", tags=["🕒 Checador Asistencia"])
def sellar_asistencia_viaje_ruta(payload: dict):
    """Registra comisión foránea para el personal en el rango de fechas indicado."""
    try:
        fecha_inicio = date.fromisoformat(payload.get("fecha_inicio"))
        fecha_fin = date.fromisoformat(payload.get("fecha_fin"))
        personal = payload.get("personal", [])
        estatus_dinamico = payload.get("estatus_dinamico", "VIAJE DE RUTA")
        
        query_ids = text("SELECT nombre, id_empleado FROM public.empleados")
        query_insert = text("""
            INSERT INTO public.control_asistencia (id_empleado, fecha, estatus, observaciones)
            VALUES (:id, :fecha, :estatus, :obs)
            ON CONFLICT DO NOTHING
        """)
        
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
                            "obs": "Logística VPRO: Comisión Foránea"
                        })
        return {"status": "SUCCESS"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/sellar-ruta-exacta", tags=["🕒 Checador Asistencia"])
def sellar_asistencia_ruta_exacta(payload: SellarRutaExactaPayload):
    """Registra marca exacta de ruta para el personal convocado."""
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
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/guardar-cambios", tags=["🕒 Checador Asistencia"])
def guardar_cambios_asistencia_admin(logs: List[dict]):
    """Permite a los administradores corregir y guardar cambios de asistencias."""
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
                if h_ent in ["", "None", "??:??"]:
                    h_ent = None
                if h_sal in ["", "None", "En Set", "??:??"]:
                    h_sal = None
                
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


@router.post("/comision-local", tags=["🕒 Checador Asistencia"])
def registrar_comision_local(payload: ComisionLocalPayload):
    """Registra o regulariza una salida imprevista a servicio/comisión local con cliente.
    Ajusta la bitácora del día con la hora real y el estatus justificado.
    """
    try:
        fec = date.fromisoformat(payload.fecha)
        ahora = datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None) - datetime.timedelta(hours=7)
        hora_actual = ahora.strftime('%H:%M:%S')
        
        motivo_limpio = payload.cliente_o_motivo.strip() if payload.cliente_o_motivo else "Servicio a Cliente"
        obs_texto = f"🚗 [COMISIÓN LOCAL] {motivo_limpio}"

        with engine_personal.begin() as conn:
            reg = conn.execute(text("""
                SELECT id_registro, hora_entrada, hora_salida, hora_entrada_v, hora_salida_v, observaciones
                FROM public.control_asistencia
                WHERE TRIM(id_empleado) = :emp AND fecha = :fec
                ORDER BY id_registro DESC LIMIT 1
            """), {"emp": payload.id_empleado.strip(), "fec": fec}).mappings().first()

            if not reg:
                # Si el empleado estuvo todo el día en campo desde temprano:
                conn.execute(text("""
                    INSERT INTO public.control_asistencia 
                    (id_empleado, fecha, hora_entrada, estatus, observaciones)
                    VALUES (:emp, :fec, CAST(:ha AS time), 'COMISIÓN LOCAL', :obs)
                """), {"emp": payload.id_empleado.strip(), "fec": fec, "ha": hora_actual, "obs": obs_texto})
            else:
                id_r = reg["id_registro"]
                obs_act = (reg["observaciones"] or "").strip()
                nueva_obs = f"{obs_act} | {obs_texto}".strip(" |")

                # Si no ha registrado salida vespertina, NO inventamos 19:00: registramos la hora actual del movimiento
                conn.execute(text("""
                    UPDATE public.control_asistencia
                    SET hora_salida_v = COALESCE(hora_salida_v, CAST(:ha AS time)),
                        estatus = 'COMISIÓN LOCAL',
                        observaciones = :obs
                    WHERE id_registro = :id
                """), {"ha": hora_actual, "obs": nueva_obs, "id": id_r})

        return {"status": "SUCCESS", "mensaje": "Comisión local registrada con la hora real del movimiento."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- RUTAS DE HORAS EXTRAS Y JORNADA EXTENDIDA ---

@router.get("/horas-extras/pendientes/{usuario}", tags=["⏱️ Asistencia y Kiosco"])
def obtener_horas_extras_pendientes(usuario: str):
    """Consulta las solicitudes de horas extras pendientes de autorización para el productor o admin."""
    try:
        def _clean_n(n: str) -> str:
            if not n: return ""
            return ''.join(c for c in unicodedata.normalize('NFD', str(n).strip().upper()) if unicodedata.category(c) != 'Mn')

        u_norm = _clean_n(usuario)
        es_admin = any(adm in u_norm for adm in ["ADMIN", "CUAUHTEMOC", "ANA LILIA", "TODOS"])

        with engine_personal.connect() as conn:
            query = text("""
                SELECT id_autorizacion, id_registro_asistencia, id_empleado, nombre_empleado,
                       id_evento, folio_op, nombre_evento, productor_responsable,
                       fecha_jornada, hora_entrada, hora_salida_madrugada, corte_ordinario,
                       horas_extra_calculadas, estatus_aprobacion, observaciones
                FROM public.control_horas_extras
                WHERE estatus_aprobacion = 'PENDIENTE'
                ORDER BY fecha_jornada DESC, id_autorizacion ASC
            """)
            all_rows = conn.execute(query).mappings().all()

            if es_admin:
                rows = all_rows
            else:
                rows = [r for r in all_rows if _clean_n(r.get("productor_responsable", "")) == u_norm]

            resultado = []
            for r in rows:
                resultado.append({
                    "id_autorizacion": r["id_autorizacion"],
                    "id_registro_asistencia": r["id_registro_asistencia"],
                    "id_empleado": str(r["id_empleado"]).strip(),
                    "nombre_empleado": str(r["nombre_empleado"]).strip(),
                    "id_evento": r["id_evento"],
                    "folio_op": str(r["folio_op"]),
                    "nombre_evento": str(r["nombre_evento"]),
                    "productor_responsable": str(r["productor_responsable"]),
                    "fecha_jornada": str(r["fecha_jornada"]),
                    "hora_entrada": str(r["hora_entrada"])[:5] if r["hora_entrada"] else "--:--",
                    "hora_salida_madrugada": str(r["hora_salida_madrugada"])[:5] if r["hora_salida_madrugada"] else "--:--",
                    "corte_ordinario": str(r["corte_ordinario"])[:5] if r["corte_ordinario"] else "19:00",
                    "horas_extra_calculadas": float(r["horas_extra_calculadas"] or 0.0),
                    "estatus_aprobacion": str(r["estatus_aprobacion"]),
                    "observaciones": str(r["observaciones"] or "")
                })
            return resultado
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/horas-extras/autorizar", tags=["⏱️ Asistencia y Kiosco"])
def autorizar_horas_extras(payload: AutorizarHorasExtrasPayload):
    """Permite al productor responsable o admin autorizar o rechazar horas extras de jornada nocturna."""
    try:
        ahora = datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None) - datetime.timedelta(hours=7)
        nuevo_estatus = "AUTORIZADO" if payload.accion.upper() == "APROBAR" else "RECHAZADO"

        with engine_personal.begin() as conn:
            for id_aut in payload.ids_autorizacion:
                row_aut = conn.execute(text("""
                    SELECT id_autorizacion, id_registro_asistencia, horas_extra_calculadas, folio_op
                    FROM public.control_horas_extras
                    WHERE id_autorizacion = :id
                """), {"id": id_aut}).mappings().first()

                if row_aut:
                    conn.execute(text("""
                        UPDATE public.control_horas_extras
                        SET estatus_aprobacion = :est,
                            aprobado_por = :usr,
                            fecha_aprobacion = :fec,
                            observaciones = COALESCE(observaciones, '') || ' | ' || :obs
                        WHERE id_autorizacion = :id
                    """), {
                        "est": nuevo_estatus,
                        "usr": payload.aprobado_por,
                        "fec": ahora,
                        "obs": f"{nuevo_estatus} por {payload.aprobado_por}",
                        "id": id_aut
                    })

                    id_reg = row_aut["id_registro_asistencia"]
                    he = row_aut["horas_extra_calculadas"]
                    if id_reg:
                        nota_extra = f"✅ [HORAS EXTRA: {he}h {nuevo_estatus} por {payload.aprobado_por}]"
                        conn.execute(text("""
                            UPDATE public.control_asistencia
                            SET observaciones = COALESCE(observaciones, '') || ' | ' || :nota
                            WHERE id_registro = :id_reg
                        """), {"nota": nota_extra, "id_reg": id_reg})

        return {"status": "SUCCESS", "mensaje": f"Horas extras actualizadas a {nuevo_estatus} correctamente."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

