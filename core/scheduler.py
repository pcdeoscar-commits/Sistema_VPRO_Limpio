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

def init_scheduler():
    """Registra las tareas cron e inicia el scheduler si no está corriendo."""
    if not scheduler.running:
        scheduler.add_job(piloto_automatico_asistencias, CronTrigger(hour=9, minute=0), id="asistencia_0900", replace_existing=True)
        scheduler.add_job(piloto_automatico_asistencias, CronTrigger(hour=14, minute=0), id="asistencia_1400", replace_existing=True)
        scheduler.add_job(piloto_automatico_asistencias, CronTrigger(hour=16, minute=0), id="asistencia_1600", replace_existing=True)
        scheduler.add_job(piloto_automatico_asistencias, CronTrigger(hour=19, minute=0), id="asistencia_1900", replace_existing=True)
        scheduler.start()
        print("[SCHEDULER] Planificador de tareas en segundo plano iniciado correctamente.")

def shutdown_scheduler():
    """Detiene el scheduler de forma segura al apagar la aplicación."""
    if scheduler.running:
        scheduler.shutdown(wait=False)
        print("[SCHEDULER] Planificador de tareas detenido.")

