import os
from PIL import Image, ImageEnhance, ImageOps

from pathlib import Path

# ==========================================
# CONFIGURACIÓN DEL VPRO-MONOIZER (Blanco y Negro)
# ==========================================
BASE_DIR = Path(__file__).resolve().parent
CARPETA_ORIGINAL = str(BASE_DIR / "Fotos_de_personal")
CARPETA_DESTINO = str(BASE_DIR / "Fotos_de_personal" / "Fotos_recortadas")

# 📏 Tamaño cuadrado final
TAMANO_FINAL = (400, 400) 

def procesar_premium_monochrome():
    if not os.path.exists(CARPETA_DESTINO):
        os.makedirs(CARPETA_DESTINO)

    extensiones = ('.jpg', '.jpeg', '.png', '.JPG', '.JPEG', '.PNG')
    cont_exito = 0

    print("🚀 Fabricando Set Fotográfico Premium Monochrome VPRO... ¡A webo!")

    for archivo in os.listdir(CARPETA_ORIGINAL):
        if archivo.endswith(extensiones):
            ruta_completa_orig = os.path.join(CARPETA_ORIGINAL, archivo)
            try:
                with Image.open(ruta_completa_orig) as img:
                    # 1. Convertir a Blanco y Negro (Grayscale)
                    img = img.convert('L')
                    
                    # 2. Recorte Central Táctico Mild (No tan agresivo)
                    width, height = img.size
                    size_min = min(width, height)
                    left = (width - size_min) / 2
                    top = (height - size_min) / 2
                    right = (width + size_min) / 2
                    bottom = (height + size_min) / 2
                    img_cropped = img.crop((left, top, right, bottom))
                    
                    # 3. Redimensionar uniformemente
                    img_final = img_cropped.resize(TAMANO_FINAL, Image.Resampling.LANCZOS)
                    
                    # 💥 TRUCO PREMIUM VPRO: Subir contraste y nitidez
                    # Sube el contraste un 20% para un look más "táctico"
                    enhancer_contraste = ImageEnhance.Contrast(img_final)
                    img_final = enhancer_contraste.enhance(1.2) 
                    
                    # 4. Guardar como PNG
                    nombre_base, _ = os.path.splitext(archivo)
                    ruta_guardado = os.path.join(CARPETA_DESTINO, f"{nombre_base}.png")
                    img_final.save(ruta_guardado, "PNG")
                    
                    print(f"✅ Foto Premium B&N: {nombre_base}.png")
                    cont_exito += 1
            except Exception as e:
                print(f"❌ Error en {archivo}: {e}")

    print(f"🏁 FIN DEL PROCESO. ¡{cont_exito} Fotos B&N Premium listas en {CARPETA_DESTINO}!")

if __name__ == '__main__':
    procesar_premium_monochrome()