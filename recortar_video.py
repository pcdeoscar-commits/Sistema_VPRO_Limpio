import os

# 🚀 BLINDAJE UNIVERSAL ANTI-VERSIONES
try:
    from moviepy import VideoFileClip
except ImportError:
    from moviepy.editor import VideoFileClip
    
def mochar_final_video(archivo_entrada, archivo_salida, segundos_a_quitar=56):
    """
    ✂️ AJUSTE FINO VPRO: Carga el video, calcula su duración 
    y le corta los últimos segundos de forma exacta.
    """
    if not os.path.exists(archivo_entrada):
        print(f"❌ Error: No encontré el video en la ruta: {archivo_entrada}")
        return

    print(f"🎬 Cargando video original: {os.path.basename(archivo_entrada)}...")
    
    # 1. Abrimos el clip de video
    clip = VideoFileClip(archivo_entrada)
    duracion_original = clip.duration
    
    # 2. Calculamos el nuevo tiempo de corte
    nueva_duracion = duracion_original - segundos_a_quitar
    
    if nueva_duracion <= 0:
        print("⚠️ El video es más corto que los segundos que le quieres quitar.")
        clip.close()
        return

    print(f"⏱️ Duración original: {duracion_original:.2f} segundos.")
    print(f"✂️ Mochando últimos {segundos_a_quitar} segundos... Nueva duración: {nueva_duracion:.2f} segundos.")

    # 3. 🧠 COMPUERTA INTELIGENTE: Detecta si tu MoviePy usa la nueva sintaxis 'subclipped'
    if hasattr(clip, "subclipped"):
        clip_recortado = clip.subclipped(0, nueva_duracion)
    else:
        clip_recortado = clip.subclip(0, nueva_duracion)

    # 4. Exportamos el video limpio con codecs universales
    clip_recortado.write_videofile(
        archivo_salida, 
        codec="libx264", 
        audio_codec="aac",
        logger=None # Silencia las letras feas de la consola
    )

    # 5. Cerramos los archivos para liberar la memoria de la PC
    clip.close()
    clip_recortado.close()
    
    print(f"✅ ¡Video editado y guardado con éxito en: {archivo_salida}!")

# ==============================================================================
# 🎛️ CONFIGURACIÓN DE TUS RUTAS REALES
# ==============================================================================
if __name__ == "__main__":
    video_sucio = r"D:\VPRO_Dashboard_V2_TODO_NUEVO\Fotos_de_personal\ayuda_como_ingresar_al_sistema.webm"
    video_limpio = r"D:\VPRO_Dashboard_V2_TODO_NUEVO\Fotos_de_personal\Tutorial_Kiosko_VPRO.mp4"
    
    mochar_final_video(video_sucio, video_limpio, segundos_a_quitar=3)