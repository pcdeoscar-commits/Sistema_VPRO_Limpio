import os
import cv2
import numpy as np

from pathlib import Path

# ==========================================
# CONFIGURACIÓN DEL VPRO-CARTOONIZER
# ==========================================
BASE_DIR = Path(__file__).resolve().parent
CARPETA_ORIGINAL = str(BASE_DIR / "Fotos_de_personal")
CARPETA_DESTINO = str(BASE_DIR / "Fotos_de_personal" / "Fotos_recortadas")

# 📏 Tamaño final cuadrado para la tira cinematográfica
TAMANO_FINAL = (400, 400) 

def cartoonize_image(img_path):
    # Leer imagen
    img = cv2.imread(img_path)
    if img is None:
        return None
    
    # Recorte central para hacerlo cuadrado perfecto antes del efecto
    h, w = img.shape[0], img.shape[1]
    size = min(h, w)
    top = (h - size) // 2
    left = (w - size) // 2
    img_cropped = img[top:top+size, left:left+size]
    img_resized = cv2.resize(img_cropped, TAMANO_FINAL, interpolation=cv2.INTER_AREA)

    # --- EFECTO AVATAR CÓMIC ---
    # Suaviza colores y piel
    color = cv2.bilateralFilter(img_resized, d=9, sigmaColor=300, sigmaSpace=300)
    # Detecta rasgos y crea bordes negros estilo dibujo animado
    gray = cv2.cvtColor(img_resized, cv2.COLOR_BGR2GRAY)
    gray_blur = cv2.medianBlur(gray, 7)
    edges = cv2.adaptiveThreshold(gray_blur, 255, 
                                  cv2.ADAPTIVE_THRESH_MEAN_C, 
                                  cv2.THRESH_BINARY, 9, 9)
    # Une los colores suaves con los bordes negros
    cartoon = cv2.bitwise_and(color, color, mask=edges)
    return cartoon

def procesar_set_fotografico():
    if not os.path.exists(CARPETA_DESTINO):
        os.makedirs(CARPETA_DESTINO)

    extensiones = ('.jpg', '.jpeg', '.png', '.JPG', '.JPEG', '.PNG')
    cont_exito = 0

    print("🚀 Fabricando Avatares VPRO... ¡Espere un momento!")

    for archivo in os.listdir(CARPETA_ORIGINAL):
        if archivo.endswith(extensiones):
            ruta_completa_orig = os.path.join(CARPETA_ORIGINAL, archivo)
            try:
                img_cartoon = cartoonize_image(ruta_completa_orig)
                if img_cartoon is not None:
                    nombre_base, _ = os.path.splitext(archivo)
                    ruta_guardado = os.path.join(CARPETA_DESTINO, f"{nombre_base}.png")
                    cv2.imwrite(ruta_guardado, img_cartoon)
                    print(f"✅ Avatar Creado: {nombre_base}.png")
                    cont_exito += 1
            except Exception as e:
                print(f"❌ Error en {archivo}: {e}")

    print(f"🏁 FIN DEL PROCESO. ¡{cont_exito} Avatares listos en {CARPETA_DESTINO}!")

if __name__ == '__main__':
    procesar_set_fotografico()