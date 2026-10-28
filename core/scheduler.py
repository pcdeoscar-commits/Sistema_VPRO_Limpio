import datetime
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from sqlalchemy import text
from core.database import engine_personal

scheduler = BackgroundScheduler()

def piloto_automatico_asistencias():
    """Revisión automática de asistencias para personal en gira o evento."""
    ahora = datetime.datetime.now()
    hora_actual = ahora.hour
    hoy_str = ahora.strftime('%Y-%m-%d')
    print(f"[PILOTO AUTOMATICO] Despertando a las {ahora.strftime('%H:%M:%S')} para revision de Giras...")
    
    try:
        with engine_personal.begin() as conn:
            if hora_actual == 9:
                conn.execute(
                    text("UPDATE public.control_asistencia SET hora_entrada = '09:00:00' WHERE fecha = CAST(:hoy AS date) AND hora_entrada IS NULL AND estatus LIKE 'EN EVENTO%'"), 
                    {"hoy": hoy_str}
                )
            elif hora_actual == 14:
                conn.execute(
                    text("UPDATE public.control_asistencia SET hora_salida = '14:00:00' WHERE fecha = CAST(:hoy AS date) AND hora_salida IS NULL AND estatus LIKE 'EN EVENTO%'"), 
                    {"hoy": hoy_str}
                )
            elif hora_actual == 16:
                conn.execute(
                    text("UPDATE public.control_asistencia SET hora_entrada_v = '16:00:00' WHERE fecha = CAST(:hoy AS date) AND hora_entrada_v IS NULL AND estatus LIKE 'EN EVENTO%'"), 
                    {"hoy": hoy_str}
                )
            elif hora_actual == 19: 
                conn.execute(
                    text("UPDATE public.control_asistencia SET hora_salida_v = '19:00:00', estatus = 'COMPLETO' WHERE fecha = CAST(:hoy AS date) AND hora_salida_v IS NULL AND estatus LIKE 'EN EVENTO%'"), 
                    {"hoy": hoy_str}
                )
        print("[PILOTO AUTOMATICO] Revision completada. Volviendo a dormir.")
    except Exception as e:
        print(f"[PILOTO AUTOMATICO ERROR]: {e}")

def tarea_limpiar_archivos_compartidos():
    """Limpia archivos compartidos que excedieron las 24 horas de su descarga o 72h sin descargar."""
    try:
        from routers.transferencias import ejecutar_limpieza_expirados
        eliminados = ejecutar_limpieza_expirados()
        if eliminados > 0:
            print(f"[SCHEDULER] Se limpiaron {eliminados} archivos compartidos expirados (regla 24h).")
    except Exception as e:
        print(f"[SCHEDULER ERROR] Error al limpiar archivos compartidos: {e}")

def tarea_recordatorios_llamado_op():
    """
    Revisa si hay eventos programados para hoy cuyo horario de llamado
    esté próximo (entre 90 y 135 minutos en el futuro, ~2 horas antes)
    y emite un recordatorio automático en el chat de la OP si no se ha emitido aún.
    """
    try:
        from core.database import engine_eventos
        from routers.chat_op import obtener_ahora_local, publicar_alerta_sistema

        ahora_dt = obtener_ahora_local()
        hoy_str = ahora_dt.strftime("%Y-%m-%d")

        query = text("""
            SELECT id_evento, folio, nombre_evento, locacion, chofer,
                   hra_de_llamado, inicio_del_evento
            FROM public.eventos
            WHERE fec_del_evento = CAST(:hoy AS date)
              AND hra_de_llamado IS NOT NULL
              AND COALESCE(chat_cerrado, FALSE) = FALSE
        """)

        with engine_eventos.connect() as conn:
            eventos_hoy = conn.execute(query, {"hoy": hoy_str}).mappings().fetchall()

            for ev in eventos_hoy:
                id_ev = ev["id_evento"]
                folio_str = str(ev["folio"] or id_ev)
                hra_llamado_val = ev["hra_de_llamado"]
                if not hra_llamado_val:
                    continue

                # Construir datetime de llamado para el día de hoy
                llamado_dt = datetime.datetime.combine(ahora_dt.date(), hra_llamado_val)
                diferencia_minutos = (llamado_dt - ahora_dt).total_seconds() / 60.0

                # Ventana de 90 a 135 minutos antes del llamado (~2 horas antes)
                if 90 <= diferencia_minutos <= 135:
                    check_q = text("""
                        SELECT 1 FROM public.chat_op_mensajes
                        WHERE id_evento = :id_ev
                          AND tipo_mensaje = 'SISTEMA'
                          AND mensaje LIKE '%Recordatorio de Llamado%'
                        LIMIT 1
                    """)
                    ya_enviado = conn.execute(check_q, {"id_ev": id_ev}).scalar()
                    if not ya_enviado:
                        minutos_aprox = int(round(diferencia_minutos))
                        hora_str = hra_llamado_val.strftime("%H:%M")
                        loc = ev["locacion"] or "Sede designada"
                        chof = ev["chofer"] or "No asignado"
                        msg = (
                            f"⏰ Recordatorio de Llamado: Faltan aproximadamente {minutos_aprox} minutos para la cita ({hora_str} hrs).\n"
                            f"📍 Locación: {loc}.\n"
                            f"🚐 Chofer / Traslado: {chof}.\n"
                            f"Equipo técnico: favor de reportar estatus de salida o llegada a través de este canal."
                        )
                        publicar_alerta_sistema(id_ev, folio_str, msg)
                        print(f"[SCHEDULER] Recordatorio de llamado enviado a OP-{folio_str} (evento {id_ev}).")

    except Exception as e:
        print(f"[SCHEDULER ERROR] Error al procesar recordatorios de llamado: {e}")

def init_scheduler():
    """Registra las tareas cron e inicia el scheduler si no está corriendo."""
    if not scheduler.running:
        scheduler.add_job(piloto_automatico_asistencias, CronTrigger(hour=9, minute=0), id="asistencia_0900", replace_existing=True)
        scheduler.add_job(piloto_automatico_asistencias, CronTrigger(hour=14, minute=0), id="asistencia_1400", replace_existing=True)
        scheduler.add_job(piloto_automatico_asistencias, CronTrigger(hour=16, minute=0), id="asistencia_1600", replace_existing=True)
        scheduler.add_job(piloto_automatico_asistencias, CronTrigger(hour=19, minute=0), id="asistencia_1900", replace_existing=True)
        scheduler.add_job(tarea_limpiar_archivos_compartidos, 'interval', minutes=15, id="limpiar_transferencias_15m", replace_existing=True)
        scheduler.add_job(tarea_recordatorios_llamado_op, 'interval', minutes=15, id="recordatorios_llamado_15m", replace_existing=True)
        scheduler.start()
        print("[SCHEDULER] Planificador de tareas en segundo plano iniciado correctamente.")

def shutdown_scheduler():
    """Detiene el scheduler de forma segura al apagar la aplicación."""
    if scheduler.running:
        scheduler.shutdown(wait=False)
        print("[SCHEDULER] Planificador de tareas detenido.")

