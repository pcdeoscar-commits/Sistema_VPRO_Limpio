import os
from PIL import Image

from pathlib import Path

# ==========================================
# CONFIGURACIÓN DE PRODUCCIÓN VPRO
# ==========================================
BASE_DIR = Path(__file__).resolve().parent
CARPETA_ORIGINAL = str(BASE_DIR / "Fotos_de_personal")
CARPETA_DESTINO = str(BASE_DIR / "Fotos_de_personal" / "Fotos_recortadas")

# 📏 Tamaño final cuadrado (en pixeles) para el Cinematic Strip
TAMANO_FINAL = (400, 400) 

def procesar_set_fotografico():
    # Asegurar que la carpeta de destino exista
    if not os.path.exists(CARPETA_DESTINO):
        os.makedirs(CARPETA_DESTINO)
        print(f"🎬 Carpeta de destino creada: {CARPETA_DESTINO}")

    # Extensiones válidas
    extensiones = ('.jpg', '.jpeg', '.png', '.JPG', '.JPEG', '.PNG')

    cont_exito = 0
    cont_error = 0

    print("🚀 Arrancando proceso de edición automatizada...")

    for archivo in os.listdir(CARPETA_ORIGINAL):
        if archivo.endswith(extensiones):
            ruta_completa_orig = os.path.join(CARPETA_ORIGINAL, archivo)
            
            try:
                # Abrir la imagen
                with Image.open(ruta_completa_orig) as img:
                    # Convertir a RGB si es necesario (para JPGs con perfiles extraños)
                    if img.mode != 'RGB':
                        img = img.convert('RGB')
                    
                    # --- ALGORITMO DE RECORTE (Hombros para arriba / Central Square) ---
                    width, height = img.size
                    
                    # 1. Encontrar la dimensión más corta para hacer un cuadrado
                    size_min = min(width, height)
                    
                    # 2. Calcular las coordenadas para un recorte central
                    # Esto corta de los lados si es horizontal, o de arriba/abajo si es vertical
                    left = (width - size_min) / 2
                    top = (height - size_min) / 2
                    right = (width + size_min) / 2
                    bottom = (height + size_min) / 2
                    
                    # 💥 TRUCO VPRO: Si queremos "hombros para arriba", a veces conviene
                    # subir un poco el recorte central para no mochar la cabeza.
                    # Vamos a subir el recorte un 10% del tamaño si es vertical.
                    if height > width:
                         factor_subida = size_min * 0.10
                         top = max(0, top - factor_subida)
                         bottom = bottom - factor_subida

                    # 3. Ejecutar el recorte
                    img_cropped = img.crop((left, top, right, bottom))
                    
                    # 4. Redimensionar al tamaño final para uniformar
                    img_final = img_cropped.resize(TAMANO_FINAL, Image.Resampling.LANCZOS)
                    
                    # 5. Guardar como PNG (mismo nombre original)
                    # 💡 NOTA: Acuérdate de renombrar las fotos a su ID de Empleado LUEGO.
                    nombre_base, _ = os.path.splitext(archivo)
                    ruta_guardado = os.path.join(CARPETA_DESTINO, f"{nombre_base}.png")
                    
                    img_final.save(ruta_guardado, "PNG")
                    print(f"✅ Foto procesada: {archivo} -> {nombre_base}.png")
                    cont_exito += 1

            except Exception as e:
                print(f"❌ Error procesando {archivo}: {e}")
                cont_error += 1

    print("="*40)
    print(f"🏁 FIN DEL PROCESO")
    print(f"👍 Éxito: {cont_exito}")
    print(f"👎 Errores: {cont_error}")
    print(f"📁 Revisa tus fotos listas en: {CARPETA_DESTINO}")
    print("="*40)

if __name__ == '__main__':
    procesar_set_fotografico()