import os
import tempfile
from fastapi import APIRouter, HTTPException, BackgroundTasks
from pydantic import BaseModel
from typing import List, Optional
from fpdf import FPDF
from fastapi.responses import FileResponse

router = APIRouter(prefix="/api/cotizaciones", tags=["💰 Cotizaciones"])

class CotizacionItem(BaseModel):
    cantidad: float
    concepto: str
    precio_unitario: float
    importe: float

class CotizacionRequest(BaseModel):
    empresa: str
    contacto: str
    departamento: Optional[str] = ""
    fecha: str
    introduccion: str
    tecnica: str
    entregables: str
    items: List[CotizacionItem]
    subtotal: float
    iva: float
    total: float
    politicas: str

class PDFConFondo(FPDF):
    def header(self):
        # 1. PLANTILLA DE FONDO en cada pagina
        ruta_plantilla = "hoja_membretada.png"
        if os.path.exists(ruta_plantilla):
            self.image(ruta_plantilla, x=0, y=0, w=215.9, h=279.4)
        
        # Ajustar el cursor inicial si es la primera página (esto se maneja en el generador)
        # pero para paginas subsecuentes aseguramos un margen:
        self.set_y(45)

def limpiar_archivo_temporal(path: str):
    try:
        if os.path.exists(path):
            os.remove(path)
    except Exception as e:
        print(f"Error limpiando temporal {path}: {e}")

@router.post("/generar_pdf")
def generar_cotizacion_pdf(data: CotizacionRequest, background_tasks: BackgroundTasks):
    try:
        pdf = PDFConFondo(format='letter')
        pdf.add_page()
        
        pdf.set_font("Arial", "B", 11)  # 2. DATOS DEL CLIENTE
        # Se escapan los strings por si tienen algun caracter raro (latin1 limit)
        pdf.cell(0, 5, f"Empresa: {data.empresa.encode('latin-1', 'replace').decode('latin-1')}", ln=True)
        
        pdf.set_font("Arial", "", 10)
        pdf.cell(0, 5, f"Atencion a: {data.contacto.encode('latin-1', 'replace').decode('latin-1')}", ln=True)
        if data.departamento: 
            pdf.cell(0, 5, f"Departamento: {data.departamento.encode('latin-1', 'replace').decode('latin-1')}", ln=True)
        pdf.ln(8)

        pdf.set_font("Arial", "", 10)   # 3. TEXTOS Y PROPUESTAS
        pdf.multi_cell(0, 5, data.introduccion.encode('latin-1', 'replace').decode('latin-1'))
        pdf.ln(5)

        if data.tecnica:   # Agregar Propuesta Técnica
            pdf.set_font("Arial", "B", 10)
            pdf.cell(0, 5, "Propuesta Tecnica:", ln=True)
            pdf.set_font("Arial", "", 10)
            pdf.multi_cell(0, 5, data.tecnica.encode('latin-1', 'replace').decode('latin-1'))
            pdf.ln(5)

        if data.entregables:   # Agregar Entregables
            pdf.set_font("Arial", "B", 10)
            pdf.cell(0, 5, "Entregables:", ln=True)
            pdf.set_font("Arial", "", 10)
            pdf.multi_cell(0, 5, data.entregables.encode('latin-1', 'replace').decode('latin-1'))
            pdf.ln(5)

        pdf.set_font("Arial", "B", 10)  # 4. TABLA DINÁMICA DE COSTOS
        pdf.set_fill_color(200, 200, 200)
        pdf.cell(20, 7, "CANT.", border=1, fill=True, align='C')
        pdf.cell(110, 7, "CONCEPTO", border=1, fill=True, align='C')
        pdf.cell(30, 7, "P. UNITARIO", border=1, fill=True, align='C')
        pdf.cell(30, 7, "IMPORTE", border=1, fill=True, align='C')
        pdf.ln()

        pdf.set_font("Arial", "", 9)
        for fila in data.items:
            if fila.cantidad > 0 and fila.precio_unitario > 0:
                pdf.cell(20, 7, str(int(fila.cantidad)), border=1, align='C')
                concepto_corto = str(fila.concepto)[:55].encode('latin-1', 'replace').decode('latin-1') 
                pdf.cell(110, 7, concepto_corto, border=1)
                pdf.cell(30, 7, f"${fila.precio_unitario:,.2f}", border=1, align='R')
                pdf.cell(30, 7, f"${fila.importe:,.2f}", border=1, align='R')
                pdf.ln()

        pdf.set_font("Arial", "B", 10)  # TOTALES
        pdf.cell(160, 7, "SUBTOTAL", border=1, align='R')
        pdf.cell(30, 7, f"${data.subtotal:,.2f}", border=1, align='R')
        pdf.ln()
        pdf.cell(160, 7, "IVA (16%)", border=1, align='R')
        pdf.cell(30, 7, f"${data.iva:,.2f}", border=1, align='R')
        pdf.ln()
        pdf.cell(160, 7, "TOTAL", border=1, align='R')
        pdf.cell(30, 7, f"${data.total:,.2f}", border=1, align='R')
        pdf.ln(8)

        pdf.set_font("Arial", "B", 9)   # 5. POLÍTICAS
        pdf.cell(0, 5, "Politicas y Condiciones:", ln=True)
        pdf.set_font("Arial", "", 8)
        pdf.multi_cell(0, 4, data.politicas.encode('latin-1', 'replace').decode('latin-1'))
        
        pdf.ln(10)  # 6. FIRMA, QR Y FECHA
        pdf.set_font("Arial", "B", 10)
        pdf.cell(0, 5, "Atentamente:", ln=True, align="C")
        pdf.cell(0, 5, "Pedro Villarreal Uribe / Director", ln=True, align="C")
        
        # Insertar QR de VPRO (Debe estar en la misma carpeta como qr_vpro.png)
        ruta_qr = "qr_vpro.png"
        if os.path.exists(ruta_qr):
            y_actual = pdf.get_y() + 2
            pdf.image(ruta_qr, x=95, y=y_actual, w=25)
            pdf.set_y(y_actual + 27) 
        else:
            pdf.ln(15) 
            
        pdf.cell(0, 5, f"Fecha de emision: {data.fecha}", ln=True, align="C")

        # Guardar en BD (cotizaciones_historial)
        from core.database import engine_eventos
        from sqlalchemy import text
        from datetime import date
        
        # Guardar archivo PDF en una carpeta compartida en lugar de temp
        carpeta_cotizaciones = "Archivos_Compartidos/Cotizaciones"
        os.makedirs(carpeta_cotizaciones, exist_ok=True)
        
        folio = "COT-PENDIENTE"
        try:
            with engine_eventos.begin() as conn:
                # Insertar registro
                query = text("""
                    INSERT INTO cotizaciones_historial (
                        folio, fecha, cliente, contacto, subtotal, iva, total, creada_por, datos_json
                    ) VALUES (
                        :folio, :fecha, :cliente, :contacto, :subtotal, :iva, :total, :creada_por, :datos_json
                    ) RETURNING id_cotizacion
                """)
                res = conn.execute(query, {
                    "folio": folio,
                    "fecha": data.fecha or str(date.today()),
                    "cliente": data.empresa,
                    "contacto": data.contacto,
                    "subtotal": data.subtotal,
                    "iva": data.iva,
                    "total": data.total,
                    "creada_por": "Sistema VPRO",
                    "datos_json": data.model_dump_json()
                }).fetchone()
                
                id_cot = res[0]
                folio = f"COT-{date.today().year}-{str(id_cot).zfill(4)}"
                
                # Actualizar folio y ruta pdf
                nombre_pdf = f"{folio}_{data.empresa.replace(' ', '_')}.pdf"
                ruta_final_pdf = f"{carpeta_cotizaciones}/{nombre_pdf}"
                
                conn.execute(text("""
                    UPDATE cotizaciones_historial 
                    SET folio = :folio, archivo_pdf = :ruta_pdf 
                    WHERE id_cotizacion = :id
                """), {"folio": folio, "ruta_pdf": ruta_final_pdf, "id": id_cot})
                
        except Exception as e_bd:
            print("Error al guardar cotizacion en BD:", e_bd)
            fd, path = tempfile.mkstemp(suffix=".pdf")
            os.close(fd)
            ruta_final_pdf = path
            background_tasks.add_task(limpiar_archivo_temporal, path)

        # Si todo salio bien en BD, guardamos el archivo permanente y no lo borramos
        with open(ruta_final_pdf, 'wb') as f:
            f.write(pdf.output(dest='S').encode('latin1'))

        return FileResponse(path=ruta_final_pdf, media_type="application/pdf", filename=f"{folio}.pdf")
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/lista")
def obtener_cotizaciones():
    try:
        from core.database import engine_eventos
        from sqlalchemy import text
        with engine_eventos.connect() as conn:
            query = text("""
                SELECT id_cotizacion, folio, fecha, cliente, contacto, total, archivo_pdf 
                FROM cotizaciones_historial
                ORDER BY id_cotizacion DESC
            """)
            res = conn.execute(query).mappings().all()
            return list(res)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))



@router.get("/{id_cotizacion}")
def obtener_cotizacion(id_cotizacion: int):
    try:
        from core.database import engine_eventos
        from sqlalchemy import text
        with engine_eventos.connect() as conn:
            query = text("SELECT datos_json FROM cotizaciones_historial WHERE id_cotizacion = :id")
            res = conn.execute(query, {"id": id_cotizacion}).fetchone()
            if not res:
                raise HTTPException(status_code=404, detail="Cotización no encontrada")
            
            import json
            datos = res[0]
            if isinstance(datos, str):
                try:
                    datos = json.loads(datos)
                except:
                    datos = None
            
            return {"datos_json": datos} if datos else {}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
