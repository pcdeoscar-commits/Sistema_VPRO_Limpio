# ==============================================================================
# 🚀 VPRO BIOMETRIC UTILITY: GENERADOR STANDALONE DE TRANSICIONES Y ESCÁNERES
# ==============================================================================
# Desarrollado para optimizar el rendimiento del Kiosco de asistencia VPRO.
# Requisitos previos en tu terminal de comandos:
#   pip install Pillow numpy
# ==============================================================================

import os
import sys
import numpy as np
from PIL import Image, ImageDraw

from pathlib import Path

# 📁 CONFIGURACIÓN DE RUTAS LOCALES
BASE_DIR = Path(__file__).resolve().parent
FOTOS_DIR = str(BASE_DIR / "Fotos_de_personal")

# Compatibilidad de filtros para diferentes versiones de Pillow
try:
    RESAMPLE_FILTER = Image.Resampling.LANCZOS
except AttributeError:
    RESAMPLE_FILTER = Image.ANTIALIAS

def inicializar_interfaz():
    """Dibuja una interfaz limpia en la consola de comandos."""
    os.system('cls' if os.name == 'nt' else 'clear')
    print("=" * 70)
    print("⚙️  VPRO SYSTEMS - GENERADOR DE TRANSICIONES BIOMÉTRICAS v2.5")
    print("=" * 70)
    print(f"📂 Carpeta de personal activa:\n   '{FOTOS_DIR}'")
    print("-" * 70)

def buscar_fotos_empleado(id_emp):
    """
    Busca de forma tolerante fotos serias y sonrientes para el ID provisto.
    Retorna (ruta_seria, ruta_sonrisa) o lanza fallos amigables.
    """
    extensiones = ['.png', '.jpg', '.jpeg', '.PNG', '.JPG', '.JPEG']
    ruta_seria = None
    ruta_sonrisa = None

    # 1. Buscar foto seria (ID estándar)
    for ext in extensiones:
        path_prueba = os.path.join(FOTOS_DIR, f"{id_emp}{ext}")
        if os.path.exists(path_prueba):
            ruta_seria = path_prueba
            break
            
    # 2. Buscar foto sonriente (ID_sonrisa)
    for ext in extensiones:
        path_prueba_sonrisa = os.path.join(FOTOS_DIR, f"{id_emp}_sonrisa{ext}")
        if os.path.exists(path_prueba_sonrisa):
            ruta_sonrisa = path_prueba_sonrisa
            break

    return ruta_seria, ruta_sonrisa

def crear_bucle_fade(ruta_seria, ruta_sonrisa, output_path):
    """Genera una transición suave entre dos imágenes y la guarda como GIF."""
    print("\n🧠 Analizando rasgos faciales en ambas imágenes...")
    
    img_seria = Image.open(ruta_seria).convert("RGB")
    img_sonrisa = Image.open(ruta_sonrisa).convert("RGB")
    
    # Redimensionar la foto sonriente para que calce 1:1 con la seria
    if img_seria.size != img_sonrisa.size:
        print(f"⚠️  Diferencia de resolución detectada. Homologando a {img_seria.size[0]}x{img_seria.size[1]}px...")
        img_sonrisa = img_sonrisa.resize(img_seria.size, RESAMPLE_FILTER)
        
    frames = []
    pasos_transicion = 12  # Cuadros dedicados a la mezcla de desvanecimiento
    
    # Fase 1: Sostener rostro serio (5 cuadros estáticos)
    for _ in range(5):
        frames.append(img_seria)
        
    # Fase 2: Mezcla lineal (Serio -> Sonrisa)
    print("✨ Tejiendo desvanecimiento de rasgos en la RAM...")
    for i in range(pasos_transicion):
        alpha = i / (pasos_transicion - 1)
        # alpha blending matemático cuadro por cuadro
        img_blend = Image.blend(img_seria, img_sonrisa, alpha)
        frames.append(img_blend)
        
    # Fase 3: Sostener rostro sonriendo (5 cuadros estáticos)
    for _ in range(5):
        frames.append(img_sonrisa)
        
    # Fase 4: Mezcla inversa (Sonrisa -> Serio) para un loop perfecto de asistencia
    for i in range(pasos_transicion):
        alpha = 1.0 - (i / (pasos_transicion - 1))
        img_blend = Image.blend(img_seria, img_sonrisa, alpha)
        frames.append(img_blend)

    # Guardar GIF animado
    frames[0].save(
        output_path,
        save_all=True,
        append_images=frames[1:],
        duration=70,  # Milisegundos por transición
        loop=0
    )
    print(f"✅ ¡Éxito rotundo! Transición guardada como:\n   '{output_path}'")

def crear_escaneo_cyberpunk(ruta_seria, output_path, id_emp):
    """Crea una animación futurista de escaneo láser sobre una única fotografía."""
    print("\n🔮 Foto de sonrisa no detectada. Iniciando reactor Cyberpunk...")
    
    img_base = Image.open(ruta_seria).convert("RGB")
    ancho, alto = img_base.size
    
    # Forzar dimensiones manejables si la foto es gigantesca (Previene lag de renderizado)
    if ancho > 600 or alto > 600:
        factor = min(600/ancho, 600/alto)
        ancho, alto = int(ancho * factor), int(alto * factor)
        img_base = img_base.resize((ancho, alto), RESAMPLE_FILTER)
        
    frames = []
    total_cuadros = 24
    
    print("📷 Proyectando láser verde y grillas holográficas...")
    for i in range(total_cuadros):
        # Crear copia de la imagen original para dibujar encima
        frame_actual = img_base.copy()
        draw = ImageDraw.Draw(frame_actual, "RGBA")
        
        # 1. Dibujar una sutil cuadrícula verde semitransparente
        for x in range(0, ancho, 40):
            draw.line([(x, 0), (x, alto)], fill=(34, 197, 94, 30), width=1)
        for y in range(0, alto, 40):
            draw.line([(0, y), (ancho, y)], fill=(34, 197, 94, 30), width=1)
            
        # 2. Dibujar Brackets de enfoque biométrico en el centro (Simulando Detección de Rostro)
        cx, cy = ancho // 2, alto // 2
        r_box = min(ancho, alto) // 4
        # Esquina superior izquierda del visor
        draw.line([(cx - r_box, cy - r_box), (cx - r_box + 20, cy - r_box)], fill=(56, 189, 248, 180), width=3)
        draw.line([(cx - r_box, cy - r_box), (cx - r_box, cy - r_box + 20)], fill=(56, 189, 248, 180), width=3)
        # Esquina superior derecha del visor
        draw.line([(cx + r_box, cy - r_box), (cx + r_box - 20, cy - r_box)], fill=(56, 189, 248, 180), width=3)
        draw.line([(cx + r_box, cy - r_box), (cx + r_box, cy - r_box + 20)], fill=(56, 189, 248, 180), width=3)
        # Esquina inferior izquierda del visor
        draw.line([(cx - r_box, cy + r_box), (cx - r_box + 20, cy + r_box)], fill=(56, 189, 248, 180), width=3)
        draw.line([(cx - r_box, cy + r_box), (cx - r_box, cy + r_box - 20)], fill=(56, 189, 248, 180), width=3)
        # Esquina inferior derecha del visor
        draw.line([(cx + r_box, cy + r_box), (cx + r_box - 20, cy + r_box)], fill=(56, 189, 248, 180), width=3)
        draw.line([(cx + r_box, cy + r_box), (cx + r_box, cy + r_box - 20)], fill=(56, 189, 180), width=3)

        # 3. Calcular el rebote del láser (Sube y baja)
        mitad = total_cuadros // 2
        if i < mitad:
            pos_y = int(30 + (i * (alto - 60) / mitad))
        else:
            pos_y = int((alto - 30) - ((i - mitad) * (alto - 60) / mitad))
            
        # 4. Inyectar el haz de luz del láser neón con degradado de transparencia
        draw.rectangle([(10, pos_y - 4), (ancho - 10, pos_y + 4)], fill=(74, 222, 128, 40))  # Resplandor externo
        draw.line([(10, pos_y), (ancho - 10, pos_y)], fill=(255, 255, 255, 220), width=2)     # Núcleo blanco brillante
        
        frames.append(frame_actual)

    # Compilar secuencia a GIF
    frames[0].save(
        output_path,
        save_all=True,
        append_images=frames[1:],
        duration=50,
        loop=0
    )
    print(f"✅ ¡Impresionante! Escáner de seguridad compilado con éxito en:\n   '{output_path}'")

def main():
    inicializar_interfaz()
    
    # 📁 Validación de existencia de directorio base
    if not os.path.exists(FOTOS_DIR):
        print(f"❌ ERROR: El directorio configurado no existe en tu sistema.\n   Verifica la variable FOTOS_DIR en el código del script.")
        input("\nPresiona Enter para cerrar...")
        sys.exit(1)

    # 🆔 Entrada de datos interactiva
    id_emp = input("👤 Ingresa el ID del Empleado a procesar (Ej: 124, 529): ").strip()
    if not id_emp:
        print("❌ Operación cancelada. El ID no puede estar en blanco.")
        input("\nPresiona Enter para salir...")
        sys.exit(0)

    # 🔎 Radar de imágenes
    ruta_seria, ruta_sonrisa = buscar_fotos_empleado(id_emp)
    output_path = os.path.join(FOTOS_DIR, f"{id_emp}.gif")

    if not ruta_seria:
        print(f"\n🚫 ERROR CRÍTICO: No se encontró la foto base para el empleado con ID '{id_emp}'")
        print(f"   Asegúrate de tener un archivo llamado '{id_emp}.png' o '{id_emp}.jpg' en la carpeta.")
        input("\nPresiona Enter para volver a intentar...")
        sys.exit(1)

    # 🚀 Selección de motor basada en los archivos disponibles
    try:
        if ruta_seria and ruta_sonrisa:
            crear_bucle_fade(ruta_seria, ruta_sonrisa, output_path)
        else:
            crear_escaneo_cyberpunk(ruta_seria, output_path, id_emp)
            
        print("\n🎉 Proceso finalizado. El Dashboard ya lo tiene disponible para el logueo.")
    except Exception as e:
        print(f"\n❌ Error fatal durante el procesamiento binario: {e}")
        
    input("\nPresiona Enter para finalizar...")

if __name__ == "__main__":
    main()