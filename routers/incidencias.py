import datetime
import re
from typing import Dict, Any, List, Optional
from fastapi import APIRouter, HTTPException, Query
from sqlalchemy import text

from core.database import engine_eventos, engine_eventos_vieja, engine_personal
from core.utils import safe_decode_hex, reparar_mojibake

router = APIRouter(prefix="/api/incidencias", tags=["📊 Incidencias"])

@router.get("/balance-ejecutivo")
def obtener_balance_ejecutivo_incidencias(
    desde: Optional[str] = Query(None, description="Fecha inicio YYYY-MM-DD"),
    hasta: Optional[str] = Query(None, description="Fecha fin YYYY-MM-DD")
):
    """Calcula el balance ejecutivo de incidencias tanto para VPRO como para Proveedores."""
    try:
        filtro_fecha = ""
        params = {}
        if desde and hasta:
            filtro_fecha = " AND COALESCE(ev.fec_del_evento, cm.fecha) BETWEEN CAST(:desde AS date) AND CAST(:hasta AS date) "
            params = {"desde": desde, "hasta": hasta}

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

        try:
            with engine_eventos.connect() as conn_ev:
                rows_nuevos = conn_ev.execute(query_maestro, params).fetchall()
        except Exception as e:
            print(f"⚠️ SILENCED ERROR in incidencias.py: {e}")

        try:
            with engine_eventos_vieja.connect() as conn_ev_v:
                rows_viejos = conn_ev_v.execute(query_maestro, params).fetchall()
        except Exception as e:
            print(f"⚠️ SILENCED ERROR in incidencias.py: {e}")

        registros_unicos = []
        firmas_vistas = set()
        
        for r in rows_nuevos + rows_viejos:
            firma_unica = f"{str(r[1])}_{str(r[2])}_{str(r[4])}"
            if firma_unica not in firmas_vistas:
                firmas_vistas.add(firma_unica)
                registros_unicos.append(r)

        rows_ev = sorted(registros_unicos, key=lambda x: x[3] if x[3] else datetime.date.min, reverse=True)

        with engine_personal.connect() as conn_pers:
            rows_p = conn_pers.execute(text("SELECT encode(id_empleado::bytea, 'hex'), encode(nombre::bytea, 'hex') FROM public.empleados")).fetchall()
            dict_empleados = {safe_decode_hex(r[0]).strip(): reparar_mojibake(safe_decode_hex(r[1])).strip() for r in rows_p}

        incidencias_vpro = []
        incidencias_proveedores = []
        todos_checkouts = []
        conteo_prov = {}
        patron_relleno = r'^(?:[\-\*\s]*)(?:sin\s+incidencias?(?:\s+en|\s+de)?(?:\s+equipo|\s+transmisi[oó0-9a-z_Ã³]+|\s+personal)?[\.\,\s\-]*)+'

        for r in rows_ev:
            folio_op = f"OP-{str(r[1]).zfill(3)}" if r[1] else "S/F"
            nota_bruta = reparar_mojibake(safe_decode_hex(r[2])).strip() if r[2] else ""
            fecha_str = str(r[3]) if r[3] else "S/F"
            id_emp_decoded = safe_decode_hex(r[4]).strip() if r[4] else ""
            nombre_staff = dict_empleados.get(id_emp_decoded, f"Empleado ID: {id_emp_decoded}") if id_emp_decoded else "Sin Asignar"
            nombre_evento = reparar_mojibake(safe_decode_hex(r[5])) if r[5] else "Evento Desconocido"
            cliente_nombre = reparar_mojibake(safe_decode_hex(r[6])) if r[6] else "Cliente Desconocido"

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

@router.get("/reporte")
def obtener_reporte_incidencias_global():
    """Obtiene la bitácora consolidada de incidencias cruzando base nueva y vieja."""
    try:
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

        try:
            with engine_eventos.connect() as conn_ev:
                rows_nuevos = conn_ev.execute(query).fetchall()
        except Exception as e:
            print(f"⚠️ SILENCED ERROR in incidencias.py: {e}")

        try:
            with engine_eventos_vieja.connect() as conn_ev_v:
                rows_viejos = conn_ev_v.execute(query).fetchall()
        except Exception as e:
            print(f"⚠️ SILENCED ERROR in incidencias.py: {e}")

        mejores_registros = {}
        for r in rows_nuevos + rows_viejos:
            firma_unica = f"{str(r[1])}_{str(r[3])}_{str(r[4])}"
            nota_actual = str(r[2]) if r[2] else ""
            
            if firma_unica not in mejores_registros:
                mejores_registros[firma_unica] = r
            else:
                nota_guardada = str(mejores_registros[firma_unica][2]) if mejores_registros[firma_unica][2] else ""
                if len(nota_actual) > len(nota_guardada):
                    mejores_registros[firma_unica] = r

        registros_unicos = list(mejores_registros.values())

        with engine_personal.connect() as conn_pers:
            query_p = text("SELECT encode(e.id_empleado::bytea, 'hex'), encode(e.nombre::bytea, 'hex'), encode(COALESCE(d.nombre, e.depto)::bytea, 'hex') FROM public.empleados e LEFT JOIN public.departamentos d ON (CASE WHEN e.depto ~ '^[0-9]+$' THEN CAST(e.depto AS INTEGER) = d.id ELSE FALSE END)")
            rows_p = conn_pers.execute(query_p).fetchall()

        personal_map = {safe_decode_hex(r[0]): {"nombre_empleado": reparar_mojibake(safe_decode_hex(r[1])), "depto_real": reparar_mojibake(safe_decode_hex(r[2]))} for r in rows_p}
        
        reporte = []
        for r in registros_unicos:
            id_emp_decoded = safe_decode_hex(r[4])
            emp_info = personal_map.get(id_emp_decoded, {"nombre_empleado": "Desconocido", "depto_real": "Sin Departamento"})
            reporte.append({
                "id_maestro": r[0], 
                "folio_op": r[1], 
                "incidencias_generales": reparar_mojibake(safe_decode_hex(r[2])), 
                "fecha": str(r[3]) if r[3] else None, 
                "id_empleado": id_emp_decoded, 
                "nombre_evento": reparar_mojibake(safe_decode_hex(r[5])) if r[5] else "Evento no registrado", 
                "para_q_cliente": reparar_mojibake(safe_decode_hex(r[6])) if r[6] else "Cliente no registrado", 
                "nombre_empleado": emp_info["nombre_empleado"], 
                "depto_real": emp_info["depto_real"]
            })
        
        reporte.sort(key=lambda x: x["fecha"] if x["fecha"] else "0000-00-00", reverse=True)
        return reporte

    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

