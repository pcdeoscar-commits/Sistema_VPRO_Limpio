---
name: reiniciar-vpro
description: >-
  Usa esta habilidad cuando el usuario escriba "reinicia", "reiniciar", 
  "restart", "reinicia el server", "reinicia el backend" o cualquier 
  variante que implique reiniciar el sistema VPRO. Aplica al backend 
  (FastAPI puerto 8000) y/o al frontend (Streamlit puerto 8520).
---

# Procedimiento de Reinicio del Sistema VPRO

Cuando el usuario pida reiniciar, ejecuta este procedimiento completo y en orden.

---

## PASO 1: Identificar qué reiniciar

Según lo que pida el usuario:
- **"reinicia"** o **"reinicia todo"** → Reiniciar AMBOS (backend + frontend).
- **"reinicia el backend"** o **"reinicia el server"** → Solo FastAPI (puerto 8000).
- **"reinicia el frontend"** o **"reinicia streamlit"** → Solo Streamlit (puerto 8520).

---

## PASO 2: Reiniciar el Backend (FastAPI — Puerto 8000)

### 2a. Encontrar el proceso que ocupa el puerto 8000:
```powershell
netstat -ano | findstr :8000
```
- Tomar el número de PID que aparezca en la columna de la derecha.

### 2b. Matar ese proceso:
```powershell
taskkill /PID [EL_PID_QUE_ENCONTRASTE] /F
```

### 2c. Arrancar el servidor FastAPI nuevamente:
```powershell
python -m uvicorn api_core_prueba:app --host 172.16.0.20 --port 8000 --ssl-certfile cert.pem --ssl-keyfile key.pem
```
- Directorio de trabajo: `c:\Users\cuauhtemoc\Desktop\Curso_de_Python\Graficos\VPRO_Dashboard_V2_TODO_NUEVO`
- Arrancar como proceso de fondo (IsDaemon: true) para no bloquear el chat.
- Esperar 4-5 segundos y verificar que diga "Application startup complete."

---

## PASO 3: Reiniciar el Frontend (Streamlit — Puerto 8520)

### 3a. Encontrar el proceso que ocupa el puerto 8520:
```powershell
netstat -ano | findstr :8520
```

### 3b. Matar ese proceso:
```powershell
taskkill /PID [EL_PID_QUE_ENCONTRASTE] /F
```

### 3c. Arrancar Streamlit nuevamente:
```powershell
python -m streamlit run app_main_prueba.py --server.port 8520 --server.address 172.16.0.20
```
- Mismo directorio de trabajo que el backend.
- Arrancar como proceso de fondo (IsDaemon: true).

---

## PASO 4: Confirmar al usuario

Después de reiniciar, reportar:
```
✅ Backend  (FastAPI  — puerto 8000): ACTIVO
✅ Frontend (Streamlit — puerto 8520): ACTIVO
```
O en caso de error, decir exactamente qué falló y por qué.

---

## REGLAS IMPORTANTES

1. Si el `netstat` no muestra ningún proceso en el puerto, el servidor ya estaba apagado — omitir el `taskkill` e ir directo al arranque.
2. Si el arranque falla con WinError 10048, esperar 3 segundos y volver a intentar el `taskkill` + arranque.
3. **Nunca** reiniciar si el usuario está en medio de una operación crítica (ej. guardando un informe de gastos). Advertir primero si es posible.

