# 📜 Bitácora Oficial de Homologación de Folios VPRO

**Fecha de Actualización:** 21 de Noviembre de 2026  
**Responsable Técnico:** Dirección de Sistemas VPRO / Administración

---

## 🎯 1. Resumen de Homologación Integral

Se consolidó y unificó la numeración oficial de las Órdenes de Producción (OPs) de VPRO entre los registros de **Administración (Sra. Ana Lilia Villarreal)** y la **Plataforma Digital VPRO Cloud**:

1. **Histórico Total (Folios 001 al 113):**
   * 114 órdenes de producción históricas (septiembre 2025 a junio 2026) extraídas e ingresadas al sistema en estatus `CERRADA (HISTÓRICO)` y protegidas contra edición.
2. **Operaciones Recientes (Folios 114 al 176):**
   * Sincronizadas 1 a 1 con los archivos de Excel oficiales de Administración.
   * Transición del *Informe Presidencial* (Folio 114), *Simposio Conisiapa* (Folio 131) hasta *Premio Estatal del Deporte* (Folio 176).
3. **Reasignación de Órdenes Recientes Creadas en Sistema:**
   * Las órdenes generadas directamente en la plataforma web que tenían identificadores temporales (`-DIR`) han sido promovidas a folios oficiales consecutivos para dar continuidad cronológica:
     * **`OP-177`** (12-Nov-2026) | GOBIERNO DEL ESTADO | Asambleas informativas (Imelda Castro) — *Estatus: ACTIVA*
     * **`OP-178`** (13-Nov-2026) | H. AYUNTAMIENTO DE BADIRAGUATO | Torneo Tebacas Baloncesto — *Estatus: CERRADA (HISTÓRICO)*
     * **`OP-179`** (03-Dic-2026) | IEES | Sesión Extraordinaria Virtual en Estudio TV (Melissa León) — *Estatus: ACTIVA*

---

## 🛠️ 2. Módulos Actualizados

* **Módulo de Gastos (`routers/gastos.py`, `prueba_web/js/gastos.js`):**
  * Homologado para desplegar siempre el **Folio Real Administrativo** (`OP-174`, `OP-175`, `OP-177`, etc.) en lugar de identificadores internos.
  * Selector de rendición de gastos dividido en *"Mis OPs Asignadas"* y *"Otras OPs Pendientes"*.
* **Dashboard y Alertas (`prueba_web/js/inicio_asistencia.js`):**
  * Indicadores de OPs pendientes de personal muestran el folio formal consecutivo.
* **Chat y Bitácora Operativa (`public.chat_op_mensajes`):**
  * Historiales, evidencias y sellos de chat vinculados a los folios oficiales correspondientes.

---

## 📊 3. Métricas de Integridad (Railway & Local)

* **Total de OPs en Sistema:** 167 OPs
* **Folios Duplicados (`UNIQUE`):** 0
* **Integridad Referencial:** 100% de checkouts, bitácoras de chat y gastos vinculados sin pérdidas.
