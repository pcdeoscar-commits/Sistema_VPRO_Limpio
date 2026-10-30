// ==============================================================================
// MÓDULO: equipos_danados.js
// 🛠️ PLATAFORMA INTEGRADA DE MANTENIMIENTO & TALLER VPRO (ESTILO ODOO)
// Incluye: Tablero Kanban de Taller, Radar Preventivo, Protocolo QC y
// 🔒 Reportes Ejecutivos & Auditoría Financiera (EXCLUSIVO EMPLEADOS 201 Y 202)
// ==============================================================================

let catalogoGlobalEquipos = [];
let datosKanbanCache = null;
let datosPreventivosCache = [];
let pestanaMantenimientoActiva = 'kanban';
let indiceFocoSugerenciaDirecto = -1;
let indiceFocoSugerenciaExpediente = -1;
let chartReportesDeptoInstance = null;

// ==============================================================================
// 1. NAVEGACIÓN ENTRE PESTAÑAS DEL MÓDULO
// ==============================================================================
function cambiarPestanaMantenimiento(tab) {
    pestanaMantenimientoActiva = tab;

    // Elementos de subvistas
    const subKanban = document.getElementById("subvista-mant-kanban");
    const subPrev = document.getElementById("subvista-mant-preventivo");
    const subRep = document.getElementById("subvista-mant-reportes");

    // Botones
    const btnKanban = document.getElementById("btn-tab-mant-kanban");
    const btnPrev = document.getElementById("btn-tab-mant-preventivo");
    const btnRep = document.getElementById("btn-tab-mant-reportes");

    const estilosInactivo = "background: transparent; border: none; border-bottom: 3px solid transparent; padding: 10px 20px; font-size: 13.5px; font-weight: 600; color: #64748b; cursor: pointer; display: flex; align-items: center; gap: 8px; border-radius: 6px 6px 0 0;";
    const estilosActivo = "background: white; border: none; border-bottom: 3px solid #2563eb; padding: 10px 20px; font-size: 13.5px; font-weight: 700; color: #1e40af; cursor: pointer; display: flex; align-items: center; gap: 8px; border-radius: 6px 6px 0 0;";

    if (btnKanban) btnKanban.style.cssText = tab === 'kanban' ? estilosActivo : estilosInactivo;
    if (btnPrev) btnPrev.style.cssText = tab === 'preventivo' ? estilosActivo : estilosInactivo;
    if (btnRep) btnRep.style.cssText = tab === 'reportes' ? estilosActivo : estilosInactivo;

    if (subKanban) subKanban.style.display = tab === 'kanban' ? 'block' : 'none';
    if (subPrev) subPrev.style.display = tab === 'preventivo' ? 'block' : 'none';
    if (subRep) subRep.style.display = tab === 'reportes' ? 'block' : 'none';

    if (tab === 'kanban') {
        cargarTableroKanban();
    } else if (tab === 'preventivo') {
        cargarRadarPreventivos();
    } else if (tab === 'reportes') {
        cargarReportesEjecutivos();
    }
}

// Compatibilidad con invocaciones previas
function cambiarPestanaDanados(tab) {
    cambiarPestanaMantenimiento('kanban');
}

// ==============================================================================
// 2. CARGA CENTRALIZADA DEL MÓDULO
// ==============================================================================
async function cargarModuloDanados() {
    try {
        // Cargar catálogo global si está vacío
        if (catalogoGlobalEquipos.length === 0) {
            try {
                const resCat = await fetch(`${API_URL}/api/inventario/catalogo-global`);
                if (resCat.ok) {
                    catalogoGlobalEquipos = await resCat.json() || [];
                }
            } catch(e) {
                console.warn("No se pudo cargar catalogo global:", e);
            }
        }

        // Cargar la pestaña activa actual
        if (pestanaMantenimientoActiva === 'kanban') {
            await cargarTableroKanban();
        } else if (pestanaMantenimientoActiva === 'preventivo') {
            await cargarRadarPreventivos();
        } else if (pestanaMantenimientoActiva === 'reportes') {
            await cargarReportesEjecutivos();
        }

        // Actualizar indicador del candado según usuario
        actualizarIndicadorCandadoReportes();

    } catch (err) {
        console.error("Error al cargar módulo de mantenimiento:", err);
    }
}

function cargarEquiposDanados() {
    cargarModuloDanados();
}

function actualizarIndicadorCandadoReportes() {
    const esAutorizado = typeof esUsuarioAutorizadoMantenimientoReportes === 'function'
        ? esUsuarioAutorizadoMantenimientoReportes()
        : ['201', '202'].includes(String(usuarioLogueado?.id_empleado || '').trim());

    const badgeCandado = document.getElementById("badge-reportes-candado");
    const iconoCandado = document.getElementById("icono-candado-reportes");

    if (badgeCandado) {
        if (esAutorizado) {
            badgeCandado.innerText = "Autorizado 201/202";
            badgeCandado.style.background = "#dcfce7";
            badgeCandado.style.color = "#166534";
        } else {
            badgeCandado.innerText = "🔒 Solo 201/202";
            badgeCandado.style.background = "#fee2e2";
            badgeCandado.style.color = "#991b1b";
        }
    }
    if (iconoCandado) {
        iconoCandado.style.color = esAutorizado ? "#16a34a" : "#f59e0b";
    }
}

// ==============================================================================
// 3. TABLERO KANBAN DE TALLER (ODOO STYLE)
// ==============================================================================
async function cargarTableroKanban() {
    try {
        const res = await fetch(`${API_URL}/api/inventario/mantenimiento/kanban`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);

        const data = await res.json();
        datosKanbanCache = data.kanban || {};

        // Actualizar contadores
        const badgeTotal = document.getElementById("badge-kanban-total");
        const badgeSidebar = document.getElementById("badge-danados");
        if (badgeTotal) badgeTotal.innerText = data.total_activos || 0;
        if (badgeSidebar) badgeSidebar.innerText = data.total_activos || 0;

        renderizarColumnasKanban(datosKanbanCache);

    } catch (err) {
        console.error("Error al cargar Kanban:", err);
        mostrarErrorEnColumnasKanban("Error al conectar con el servidor para cargar el tablero Kanban.");
    }
}

function renderizarColumnasKanban(kanbanData) {
    const columnasConfig = [
        { id: "diagnostico", etapa: "DIAGNOSTICO", badgeId: "col-count-diagnostico", contId: "kanban-col-diagnostico" },
        { id: "espera", etapa: "ESPERA_REFACCION", badgeId: "col-count-espera", contId: "kanban-col-espera" },
        { id: "reparacion", etapa: "EN_REPARACION", badgeId: "col-count-reparacion", contId: "kanban-col-reparacion" },
        { id: "calidad", etapa: "CONTROL_CALIDAD", badgeId: "col-count-calidad", contId: "kanban-col-calidad" }
    ];

    columnasConfig.forEach(col => {
        const tickets = kanbanData[col.etapa] || [];
        const badgeEl = document.getElementById(col.badgeId);
        const contEl = document.getElementById(col.contId);

        if (badgeEl) badgeEl.innerText = tickets.length;
        if (!contEl) return;

        if (tickets.length === 0) {
            contEl.innerHTML = `
                <div style="text-align: center; color: #94a3b8; font-size: 12px; padding: 28px 12px; border: 1px dashed #cbd5e1; border-radius: 8px;">
                    <i class="ph ph-check-circle" style="font-size: 24px; color: #cbd5e1; display: block; margin-bottom: 4px;"></i>
                    Sin tickets en esta etapa
                </div>`;
            return;
        }

        contEl.innerHTML = tickets.map(t => generarTarjetaKanbanHTML(t)).join("");
    });
}

function generarTarjetaKanbanHTML(t) {
    const numServicio = escaparHTMLSeguro(t.ticket || "");
    const codEquipo = escaparHTMLSeguro(t.id_equipo || "");
    const nombreEquipo = escaparHTMLSeguro(t.nombre_equipo || t.id_equipo || "Equipo sin nombre");
    const tipo = (t.tipo_mantenimiento || "CORRECTIVO").toUpperCase();
    const esPreventivo = tipo.includes("PREV");
    const dias = parseInt(t.dias_en_taller) || 0;
    const reporto = escaparHTMLSeguro(t.reporto || "No especificado");
    const falla = escaparHTMLSeguro(t.falla || "Sin detalle registrado");
    const costo = parseFloat(t.costo || 0.0);
    const etapa = t.etapa || "DIAGNOSTICO";

    // Semáforo de días
    let badgeDiasStyle = "background: #dcfce7; color: #166534;";
    if (dias > 7) badgeDiasStyle = "background: #fee2e2; color: #991b1b; font-weight: 700;";
    else if (dias > 3) badgeDiasStyle = "background: #fef3c7; color: #92400e;";

    // Badge de tipo
    const badgeTipoStyle = esPreventivo 
        ? "background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe;" 
        : "background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca;";
    const badgeTipoIcon = esPreventivo ? "🕒 PREVENTIVO" : "🔧 CORRECTIVO";

    // Botones de avance de etapa
    let botonesAccion = "";
    if (etapa === "DIAGNOSTICO") {
        botonesAccion = `
            <div style="display: flex; gap: 6px; margin-top: 10px;">
                <button type="button" onclick="moverTicketEtapa('${numServicio}', 'ESPERA_REFACCION')" title="Mover a Espera Refacción" style="flex: 1; background: #fffbeb; border: 1px solid #fde68a; color: #b45309; padding: 6px 8px; border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer;">
                    ⏳ Espera Refacción
                </button>
                <button type="button" onclick="moverTicketEtapa('${numServicio}', 'EN_REPARACION')" title="Mover a Reparación" style="flex: 1; background: #f5f3ff; border: 1px solid #ddd6fe; color: #6d28d9; padding: 6px 8px; border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer;">
                    🔧 A Reparación
                </button>
            </div>
        `;
    } else if (etapa === "ESPERA_REFACCION") {
        botonesAccion = `
            <div style="display: flex; gap: 6px; margin-top: 10px;">
                <button type="button" onclick="moverTicketEtapa('${numServicio}', 'DIAGNOSTICO')" style="background: #f1f5f9; border: 1px solid #cbd5e1; color: #475569; padding: 6px 8px; border-radius: 6px; font-size: 11px; font-weight: 600; cursor: pointer;">
                    ◀ Volver
                </button>
                <button type="button" onclick="moverTicketEtapa('${numServicio}', 'EN_REPARACION')" style="flex: 1; background: #f5f3ff; border: 1px solid #ddd6fe; color: #6d28d9; padding: 6px 8px; border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer;">
                    🔧 Iniciar Reparación ▶
                </button>
            </div>
        `;
    } else if (etapa === "EN_REPARACION") {
        botonesAccion = `
            <div style="display: flex; gap: 6px; margin-top: 10px;">
                <button type="button" onclick="moverTicketEtapa('${numServicio}', 'ESPERA_REFACCION')" style="background: #fffbeb; border: 1px solid #fde68a; color: #b45309; padding: 6px 8px; border-radius: 6px; font-size: 11px; font-weight: 600; cursor: pointer;">
                    ⏳ Pausar (Pieza)
                </button>
                <button type="button" onclick="moverTicketEtapa('${numServicio}', 'CONTROL_CALIDAD')" style="flex: 1; background: #ecfdf5; border: 1px solid #a7f3d0; color: #047857; padding: 6px 8px; border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer;">
                    🛡️ Pasar a QC ▶
                </button>
            </div>
        `;
    } else if (etapa === "CONTROL_CALIDAD") {
        botonesAccion = `
            <div style="margin-top: 10px;">
                <button type="button" onclick="abrirModalQC('${numServicio}', '${codEquipo}', ${costo})" style="width: 100%; background: #10b981; color: white; border: none; padding: 8px 12px; border-radius: 6px; font-size: 11.5px; font-weight: 800; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 6px; box-shadow: 0 2px 4px rgba(16,185,129,0.25);">
                    <i class="ph ph-shield-check" style="font-size: 15px;"></i> Protocolo QC y Liberar
                </button>
            </div>
        `;
    }

    return `
        <div class="tarjeta-kanban-item" style="background: white; border: 1px solid #cbd5e1; border-radius: 10px; padding: 12px 14px; box-shadow: 0 2px 5px rgba(0,0,0,0.04); transition: transform 0.15s, box-shadow 0.15s;">
            
            <!-- Encabezado Tarjeta -->
            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 6px;">
                <span style="font-family: monospace; font-size: 11px; font-weight: 800; color: #2563eb; background: #eff6ff; padding: 2px 6px; border-radius: 4px;">
                    #${numServicio}
                </span>
                <span style="font-size: 10px; font-weight: 700; padding: 2px 6px; border-radius: 4px; ${badgeTipoStyle}">
                    ${badgeTipoIcon}
                </span>
            </div>

            <!-- Título del Equipo (Clic abre expediente clínico) -->
            <div style="font-weight: 700; font-size: 13px; color: #0f172a; line-height: 1.3; margin-bottom: 3px; cursor: pointer;" 
                 onclick="abrirExpedienteEquipoModal('${codEquipo}', '${nombreEquipo}', '${numServicio}')" 
                 title="Haz clic para ver el expediente clínico del equipo">
                ${nombreEquipo}
            </div>
            <div style="font-size: 11px; color: #64748b; font-family: monospace; margin-bottom: 8px;">
                ID: ${codEquipo}
            </div>

            <!-- Detalle de la Falla -->
            <div style="font-size: 12px; color: #475569; background: #f8fafc; border-left: 3px solid #cbd5e1; padding: 6px 8px; border-radius: 0 4px 4px 0; margin-bottom: 8px; line-height: 1.3;">
                ${falla}
            </div>

            <!-- Metadatos: Días y Reportante -->
            <div style="display: flex; justify-content: space-between; align-items: center; font-size: 11px; color: #64748b; margin-top: 4px;">
                <span style="padding: 2px 6px; border-radius: 4px; ${badgeDiasStyle}">
                    ⏱️ ${dias} día${dias === 1 ? '' : 's'}
                </span>
                <span style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 130px;" title="Reportado por: ${reporto}">
                    👤 ${reporto}
                </span>
            </div>

            <!-- Botones de Acción de Etapa -->
            ${botonesAccion}

        </div>
    `;
}

function mostrarErrorEnColumnasKanban(mensaje) {
    ["kanban-col-diagnostico", "kanban-col-espera", "kanban-col-reparacion", "kanban-col-calidad"].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.innerHTML = `<div style="text-align: center; color: #b91c1c; font-size: 11.5px; padding: 20px 8px;">${mensaje}</div>`;
    });
}

function filtrarKanbanEnVivo(termino) {
    if (!datosKanbanCache) return;
    const t = normalizarTextoBusqueda(termino);
    if (!t) {
        renderizarColumnasKanban(datosKanbanCache);
        return;
    }

    const filtrado = {};
    for (const etapa in datosKanbanCache) {
        filtrado[etapa] = datosKanbanCache[etapa].filter(item => {
            const ticket = normalizarTextoBusqueda(item.ticket);
            const equipo = normalizarTextoBusqueda(item.nombre_equipo);
            const id = normalizarTextoBusqueda(item.id_equipo);
            const rep = normalizarTextoBusqueda(item.reporto);
            const falla = normalizarTextoBusqueda(item.falla);
            return ticket.includes(t) || equipo.includes(t) || id.includes(t) || rep.includes(t) || falla.includes(t);
        });
    }
    renderizarColumnasKanban(filtrado);
}

async function moverTicketEtapa(numServicio, nuevaEtapa) {
    try {
        const res = await fetch(`${API_URL}/api/inventario/mantenimiento/cambiar-etapa`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                num_servicio: numServicio,
                nueva_etapa: nuevaEtapa,
                encargado: usuarioLogueado?.nombre || "TALLER"
            })
        });

        if (res.ok) {
            await cargarTableroKanban();
        } else {
            const err = await res.json();
            alert(`❌ Error al mover ticket: ${err.detail || 'Operación fallida'}`);
        }
    } catch (e) {
        alert(`❌ Error de red: ${e.message}`);
    }
}

// ==============================================================================
// 4. PROTOCOLO DE CONTROL DE CALIDAD (QC) Y LIBERACIÓN A BODEGA
// ==============================================================================
function abrirModalQC(numServicio, codEquipo, costoActual) {
    const modal = document.getElementById("modal-mant-qc");
    const subTit = document.getElementById("modal-qc-subtitulo");
    const inputTec = document.getElementById("qc-input-tecnico");
    const inputCosto = document.getElementById("qc-input-costo");
    const inputHidden = document.getElementById("qc-hidden-ticket");
    const txtObs = document.getElementById("qc-txt-observaciones");

    if (subTit) subTit.innerText = `Ticket #${numServicio} • Activo: ${codEquipo}`;
    if (inputHidden) inputHidden.value = numServicio;
    if (inputTec) inputTec.value = usuarioLogueado?.nombre || "TÉCNICO QC";
    if (inputCosto) inputCosto.value = costoActual || 0.0;
    if (txtObs) txtObs.value = "";

    // Resetear checkboxes a activo por defecto
    const c1 = document.getElementById("qc-chk-electrico");
    const c2 = document.getElementById("qc-chk-operativo");
    const c3 = document.getElementById("qc-chk-limpieza");
    if (c1) c1.checked = true;
    if (c2) c2.checked = true;
    if (c3) c3.checked = true;

    if (modal) modal.style.display = "flex";
}

function cerrarModalQC() {
    const modal = document.getElementById("modal-mant-qc");
    if (modal) modal.style.display = "none";
}

async function ejecutarAprobacionQC() {
    const numServicio = document.getElementById("qc-hidden-ticket")?.value;
    const c1 = document.getElementById("qc-chk-electrico")?.checked;
    const c2 = document.getElementById("qc-chk-operativo")?.checked;
    const c3 = document.getElementById("qc-chk-limpieza")?.checked;

    if (!c1 || !c2 || !c3) {
        if (!confirm("⚠️ Advertencia: No has marcado las 3 pruebas de control de calidad como exitosas. ¿Deseas aprobar la liberación de todas formas?")) {
            return;
        }
    }

    const tec = document.getElementById("qc-input-tecnico")?.value || "TÉCNICO QC";
    const costo = parseFloat(document.getElementById("qc-input-costo")?.value || 0.0);
    const obs = document.getElementById("qc-txt-observaciones")?.value || "Liberado con éxito tras mantenimiento.";

    try {
        const res = await fetch(`${API_URL}/api/inventario/mantenimiento/liberar-qc`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                num_servicio: numServicio,
                resultado: "APROBADO_OK",
                checklist: {
                    electrico_ok: c1,
                    operativo_ok: c2,
                    limpieza_ok: c3
                },
                tecnico_responsable: tec,
                observaciones: obs,
                costo_final: costo
            })
        });

        if (res.ok) {
            alert(`🎉 ¡Equipo rehabilitado con éxito! Se marcó como 'OK' en el inventario y está listo para eventos.`);
            cerrarModalQC();
            await cargarTableroKanban();
        } else {
            const err = await res.json();
            alert(`❌ Error al liberar: ${err.detail || 'Fallo en servidor'}`);
        }
    } catch (e) {
        alert(`❌ Error de red: ${e.message}`);
    }
}

async function ejecutarBajaDefinitivaQC() {
    const numServicio = document.getElementById("qc-hidden-ticket")?.value;
    if (!confirm(`¿Confirmas declarar la BAJA DEFINITIVA del equipo amparado por el ticket #${numServicio}? Esta acción desincorporará el activo del inventario activo.`)) {
        return;
    }

    const tec = document.getElementById("qc-input-tecnico")?.value || "TÉCNICO QC";
    const costo = parseFloat(document.getElementById("qc-input-costo")?.value || 0.0);
    const obs = document.getElementById("qc-txt-observaciones")?.value || "Equipo irreparable o no costeable.";

    try {
        const res = await fetch(`${API_URL}/api/inventario/mantenimiento/liberar-qc`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                num_servicio: numServicio,
                resultado: "BAJA_DEFINITIVA",
                checklist: {},
                tecnico_responsable: tec,
                observaciones: obs,
                costo_final: costo
            })
        });

        if (res.ok) {
            alert(`Ticket #${numServicio} cerrado y activo marcado como 'BAJA'.`);
            cerrarModalQC();
            await cargarTableroKanban();
        } else {
            const err = await res.json();
            alert(`❌ Error: ${err.detail || 'Fallo en servidor'}`);
        }
    } catch (e) {
        alert(`❌ Error de red: ${e.message}`);
    }
}

// ==============================================================================
// 5. RADAR DE MANTENIMIENTO PREVENTIVO
// ==============================================================================
async function cargarRadarPreventivos() {
    const tbody = document.getElementById("tabla-preventivos-body");
    const badgePrev = document.getElementById("badge-preventivo-total");

    try {
        const res = await fetch(`${API_URL}/api/inventario/mantenimiento/preventivos`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);

        const activos = await res.json();
        datosPreventivosCache = activos || [];

        if (badgePrev) badgePrev.innerText = datosPreventivosCache.length;

        renderizarTablaPreventivos(datosPreventivosCache);

    } catch (err) {
        console.error("Error al cargar radar preventivo:", err);
        if (tbody) {
            tbody.innerHTML = `<tr><td colspan="9" style="text-align: center; padding: 24px; color: #b91c1c;">Error al cargar planes preventivos: ${err.message}</td></tr>`;
        }
    }
}

function renderizarTablaPreventivos(lista) {
    const tbody = document.getElementById("tabla-preventivos-body");
    if (!tbody) return;

    if (lista.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="9" style="text-align: center; padding: 32px; color: #64748b;">
                    <i class="ph ph-calendar-x" style="font-size: 28px; color: #94a3b8; display: block; margin-bottom: 6px;"></i>
                    No hay activos con plan de mantenimiento preventivo configurado.<br>
                    <span style="font-size: 12px; color: #94a3b8;">Usa el botón "Programar Frecuencia a un Activo" para dar de alta uno.</span>
                </td>
            </tr>`;
        return;
    }

    tbody.innerHTML = lista.map(a => {
        let badgeSemaforo = "";
        if (a.semaforo === "VENCIDO") {
            badgeSemaforo = `<span style="background: #fee2e2; color: #991b1b; padding: 4px 8px; border-radius: 999px; font-weight: 800; font-size: 11px;">🔴 VENCIDO</span>`;
        } else if (a.semaforo === "URGENTE_ESTA_SEMANA") {
            badgeSemaforo = `<span style="background: #ffedd5; color: #c2410c; padding: 4px 8px; border-radius: 999px; font-weight: 800; font-size: 11px;">🟠 ESTA SEMANA</span>`;
        } else if (a.semaforo === "PROXIMO") {
            badgeSemaforo = `<span style="background: #fef3c7; color: #b45309; padding: 4px 8px; border-radius: 999px; font-weight: 700; font-size: 11px;">🟡 PRÓXIMO</span>`;
        } else {
            badgeSemaforo = `<span style="background: #dcfce7; color: #166534; padding: 4px 8px; border-radius: 999px; font-weight: 700; font-size: 11px;">🟢 AL DÍA</span>`;
        }

        const diasText = a.dias_restantes === null ? "Sin calcular" : `${a.dias_restantes} días`;
        const codEsc = escaparHTMLSeguro(a.codigo);

        return `
            <tr>
                <td>${badgeSemaforo}</td>
                <td style="font-family: monospace; font-weight: 700; color: #2563eb;">${codEsc}</td>
                <td><b>${escaparHTMLSeguro(a.descripcion)}</b><br><span style="font-size: 11.5px; color: #64748b;">${escaparHTMLSeguro(a.marca)} ${escaparHTMLSeguro(a.modelo)}</span></td>
                <td>${escaparHTMLSeguro(a.ubicacion || 'Bodega General')}</td>
                <td>Cada <b>${a.frecuencia_dias}</b> días</td>
                <td>${escaparHTMLSeguro(a.ultimo_mantenimiento)}</td>
                <td style="font-weight: 700;">${escaparHTMLSeguro(a.proximo_mantenimiento)}</td>
                <td><span style="font-weight: 600;">${diasText}</span></td>
                <td>
                    <button type="button" onclick="crearTicketPreventivoInmediato('${codEsc}')" style="background: #2563eb; color: white; border: none; padding: 6px 12px; border-radius: 6px; font-size: 11.5px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                        <i class="ph ph-play"></i> Iniciar Taller
                    </button>
                </td>
            </tr>
        `;
    }).join("");
}

function filtrarTablaPreventivos(termino) {
    const t = normalizarTextoBusqueda(termino);
    if (!t) {
        renderizarTablaPreventivos(datosPreventivosCache);
        return;
    }
    const filtrados = datosPreventivosCache.filter(a => {
        return normalizarTextoBusqueda(a.codigo).includes(t) ||
               normalizarTextoBusqueda(a.descripcion).includes(t) ||
               normalizarTextoBusqueda(a.ubicacion).includes(t);
    });
    renderizarTablaPreventivos(filtrados);
}

function alternarFormularioConfigurarPreventivo() {
    const el = document.getElementById("contenedor-form-config-preventivo");
    if (el) el.style.display = el.style.display === "none" ? "block" : "none";
}

async function guardarFrecuenciaPreventivaActivo() {
    const codigo = document.getElementById("prev-input-codigo")?.value.trim();
    const dias = parseInt(document.getElementById("prev-input-dias")?.value || 30);
    const fechaProx = document.getElementById("prev-input-fecha-prox")?.value || null;

    if (!codigo) {
        alert("⚠️ Por favor ingresa el código del equipo.");
        return;
    }

    try {
        const res = await fetch(`${API_URL}/api/inventario/mantenimiento/programar-preventivo`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                codigo_equipo: codigo,
                frecuencia_dias: dias,
                fecha_proximo_mantenimiento: fechaProx
            })
        });

        if (res.ok) {
            alert(`✅ Plan preventivo programado para el equipo ${codigo}.`);
            alternarFormularioConfigurarPreventivo();
            await cargarRadarPreventivos();
        } else {
            const err = await res.json();
            alert(`❌ Error: ${err.detail || 'Fallo en servidor'}`);
        }
    } catch (e) {
        alert(`❌ Error de red: ${e.message}`);
    }
}

async function crearTicketPreventivoInmediato(codigo) {
    if (!confirm(`¿Deseas enviar una orden de servicio preventiva a taller para el equipo ${codigo}?`)) {
        return;
    }

    try {
        const res = await fetch(`${API_URL}/api/inventario/mantenimiento/crear-ticket-preventivo`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                codigo_equipo: codigo,
                id_empleado: usuarioLogueado?.id_empleado || "201",
                descripcion: "Mantenimiento preventivo periódico por rutina programada"
            })
        });

        if (res.ok) {
            const data = await res.json();
            alert(`🚀 Orden preventiva #${data.num_servicio} creada con éxito e inyectada al Tablero Kanban.`);
            cambiarPestanaMantenimiento('kanban');
        } else {
            const err = await res.json();
            alert(`❌ Error: ${err.detail || 'Fallo al generar orden'}`);
        }
    } catch (e) {
        alert(`❌ Error de red: ${e.message}`);
    }
}

// ==============================================================================
// 6. REPORTES, COSTOS & AUDITORÍA (🔒 EXCLUSIVO EMPLEADOS 201 Y 202)
// ==============================================================================
async function cargarReportesEjecutivos() {
    const contenedor = document.getElementById("contenedor-reportes-bloque-seguro");
    if (!contenedor) return;

    // 🔒 REGLA DE SEGURIDAD ESTRICTA: Solo empleados 201 y 202
    const esAutorizado = typeof esUsuarioAutorizadoMantenimientoReportes === 'function'
        ? esUsuarioAutorizadoMantenimientoReportes()
        : ['201', '202'].includes(String(usuarioLogueado?.id_empleado || '').trim());

    if (!esAutorizado) {
        contenedor.innerHTML = `
            <div style="background: white; border: 2px dashed #f59e0b; border-radius: 14px; padding: 48px 24px; text-align: center; max-width: 680px; margin: 40px auto; box-shadow: 0 4px 20px rgba(0,0,0,0.04);">
                <div style="background: #fef3c7; width: 64px; height: 64px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px auto;">
                    <i class="ph ph-lock-key" style="font-size: 32px; color: #b45309;"></i>
                </div>
                <h3 style="margin: 0 0 8px 0; color: #0f172a; font-size: 19px;">Módulo Restringido a Dirección y Sistemas</h3>
                <p style="color: #64748b; font-size: 13.5px; line-height: 1.5; margin: 0 0 20px 0;">
                    Por políticas de confidencialidad institucional, los reportes financieros de costos de taller, 
                    auditorías acumuladas y expedientes de siniestralidad están reservados 
                    <b>exclusivamente para los empleados 201 y 202</b>.
                </p>
                <div style="display: inline-flex; align-items: center; gap: 8px; background: #f8fafc; border: 1px solid #e2e8f0; padding: 8px 16px; border-radius: 8px; font-size: 12px; color: #475569;">
                    <span>Tu usuario actual: <b>${usuarioLogueado?.nombre || 'Invitado'}</b> (ID: ${usuarioLogueado?.id_empleado || 'N/A'})</span>
                </div>
            </div>
        `;
        return;
    }

    // Usuario 201 o 202: Proceder a cargar métricas y reportes
    contenedor.innerHTML = `<div style="text-align: center; padding: 40px; color: #64748b;"><i class="ph ph-spinner ph-spin" style="font-size: 28px;"></i> Cargando reportes ejecutivos...</div>`;

    try {
        const idEmp = String(usuarioLogueado?.id_empleado || "201").trim();
        const res = await fetch(`${API_URL}/api/inventario/mantenimiento/reportes-kpis?id_empleado=${encodeURIComponent(idEmp)}`);
        if (!res.ok) {
            const err = await res.json();
            throw new Error(err.detail || `HTTP ${res.status}`);
        }

        const data = await res.json();
        renderizarVistaReportesAutorizado(data);

    } catch (err) {
        console.error("Error al cargar reportes ejecutivos:", err);
        contenedor.innerHTML = `
            <div style="background: #fee2e2; border: 1px solid #fca5a5; padding: 24px; border-radius: 12px; color: #991b1b; text-align: center;">
                <b>⚠️ Error al consultar reportes:</b> ${err.message}
            </div>
        `;
    }
}

function renderizarVistaReportesAutorizado(data) {
    const contenedor = document.getElementById("contenedor-reportes-bloque-seguro");
    if (!contenedor) return;

    const res = data.resumen || {};
    const porDepto = data.por_departamento || [];
    const porTipo = data.por_tipo || [];
    const topEq = data.top_equipos || [];

    const totalTickets = res.total_tickets || 0;
    const activos = res.activos || 0;
    const resueltos = res.resueltos || 0;
    const bajas = res.bajas || 0;
    const gastoTotal = (res.gasto_total || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    const promDias = res.promedio_dias_taller || 0;

    contenedor.innerHTML = `
        <!-- 4 Tarjetas KPI Ejecutivas -->
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; margin-bottom: 24px;">
            <div style="background: #eff6ff; border: 1px solid #bfdbfe; padding: 18px 20px; border-radius: 12px;">
                <div style="font-size: 12px; font-weight: 700; color: #1e40af; text-transform: uppercase;">Total Histórico de Tickets</div>
                <div style="font-size: 32px; font-weight: 800; color: #1d4ed8; margin-top: 4px;">${totalTickets}</div>
                <div style="font-size: 11.5px; color: #3b82f6; margin-top: 4px;">${activos} activos en taller hoy</div>
            </div>
            <div style="background: #ecfdf5; border: 1px solid #a7f3d0; padding: 18px 20px; border-radius: 12px;">
                <div style="font-size: 12px; font-weight: 700; color: #065f46; text-transform: uppercase;">Gasto Total en Reparaciones</div>
                <div style="font-size: 32px; font-weight: 800; color: #047857; margin-top: 4px;">$${gastoTotal}</div>
                <div style="font-size: 11.5px; color: #059669; margin-top: 4px;">Inversión acumulada en refacciones</div>
            </div>
            <div style="background: #fef3c7; border: 1px solid #fde68a; padding: 18px 20px; border-radius: 12px;">
                <div style="font-size: 12px; font-weight: 700; color: #92400e; text-transform: uppercase;">Promedio Días en Taller</div>
                <div style="font-size: 32px; font-weight: 800; color: #b45309; margin-top: 4px;">${promDias} Días</div>
                <div style="font-size: 11.5px; color: #d97706; margin-top: 4px;">Tiempo medio de resolución (MTTR)</div>
            </div>
            <div style="background: #f3e8ff; border: 1px solid #d8b4fe; padding: 18px 20px; border-radius: 12px;">
                <div style="font-size: 12px; font-weight: 700; color: #6b21a8; text-transform: uppercase;">Tasa de Éxito / Bajas</div>
                <div style="font-size: 26px; font-weight: 800; color: #7e22ce; margin-top: 6px;">${resueltos} OK / ${bajas} Bajas</div>
                <div style="font-size: 11.5px; color: #9333ea; margin-top: 4px;">Activos rehabilitados vs chatarra</div>
            </div>
        </div>

        <!-- Gráfico y Desglose por Departamento y Tipo -->
        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px; margin-bottom: 24px;">
            
            <!-- Gráfica por Departamento -->
            <div style="background: white; border: 1px solid var(--border-color); border-radius: 12px; padding: 20px;">
                <h4 style="margin: 0 0 16px 0; color: #0f172a; font-size: 14.5px; display: flex; align-items: center; gap: 8px;">
                    <i class="ph ph-chart-bar" style="color: #2563eb;"></i> Tickets e Inversión por Departamento
                </h4>
                <div style="height: 260px; position: relative;">
                    <canvas id="chart-mant-deptos"></canvas>
                </div>
            </div>

            <!-- Desglose Tipo de Mantenimiento -->
            <div style="background: white; border: 1px solid var(--border-color); border-radius: 12px; padding: 20px;">
                <h4 style="margin: 0 0 16px 0; color: #0f172a; font-size: 14.5px; display: flex; align-items: center; gap: 8px;">
                    <i class="ph ph-pie-chart" style="color: #8b5cf6;"></i> Correctivo vs Preventivo
                </h4>
                <div style="display: flex; flex-direction: column; gap: 14px; margin-top: 20px;">
                    ${porTipo.map(t => {
                        const esPrev = t.tipo.includes('PREV');
                        const colorBar = esPrev ? '#3b82f6' : '#ef4444';
                        const pct = totalTickets > 0 ? Math.round((t.tickets / totalTickets) * 100) : 0;
                        return `
                            <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px 14px;">
                                <div style="display: flex; justify-content: space-between; font-size: 12.5px; font-weight: 700; color: #1e293b; margin-bottom: 6px;">
                                    <span>${esPrev ? '🕒 Preventivo' : '🔧 Correctivo'} (${t.tickets} tickets)</span>
                                    <span>${pct}%</span>
                                </div>
                                <div style="background: #e2e8f0; height: 8px; border-radius: 999px; overflow: hidden; margin-bottom: 6px;">
                                    <div style="background: ${colorBar}; width: ${pct}%; height: 100%;"></div>
                                </div>
                                <div style="font-size: 11.5px; color: #64748b;">
                                    Gasto asociado: <b>$${t.costo.toLocaleString('es-MX', { minimumFractionDigits: 2 })}</b>
                                </div>
                            </div>
                        `;
                    }).join("")}
                </div>
            </div>

        </div>

        <!-- Top Equipos Problemáticos / con Mayor Gasto -->
        <div style="background: white; border: 1px solid var(--border-color); border-radius: 12px; padding: 20px; margin-bottom: 24px;">
            <h4 style="margin: 0 0 14px 0; color: #0f172a; font-size: 14.5px; display: flex; align-items: center; gap: 8px;">
                <i class="ph ph-warning-octagon" style="color: #dc2626;"></i> Top Equipos con Mayor Índice de Falla o Gasto Acumulado
            </h4>
            <div class="tabla-container">
                <table class="tabla-vpro">
                    <thead>
                        <tr>
                            <th>Código ID</th>
                            <th>Equipo / Descripción</th>
                            <th>Total Incidencias</th>
                            <th>Gasto Acumulado ($)</th>
                            <th>Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${topEq.map(eq => {
                            const codEsc = escaparHTMLSeguro(eq.codigo);
                            const nomEsc = escaparHTMLSeguro(eq.nombre);
                            return `
                                <tr>
                                    <td style="font-family: monospace; font-weight: 700; color: #2563eb;">${codEsc}</td>
                                    <td><b>${nomEsc}</b></td>
                                    <td><span style="background: #fee2e2; color: #991b1b; padding: 3px 8px; border-radius: 4px; font-weight: 700;">${eq.incidencias} reportes</span></td>
                                    <td style="font-weight: 700;">$${eq.gasto_acumulado.toLocaleString('es-MX', { minimumFractionDigits: 2 })}</td>
                                    <td>
                                        <button type="button" onclick="abrirExpedienteEquipoModal('${codEsc}', '${nomEsc}')" style="background: #f1f5f9; border: 1px solid #cbd5e1; padding: 5px 12px; border-radius: 6px; font-size: 11.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                                            <i class="ph ph-first-aid"></i> Ver Historial
                                        </button>
                                    </td>
                                </tr>
                            `;
                        }).join("")}
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Buscador Rápido de Expediente Clínico de Cualquier Activo -->
        <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px;">
            <h4 style="margin: 0 0 8px 0; color: #0f172a; font-size: 14.5px; display: flex; align-items: center; gap: 8px;">
                <i class="ph ph-magnifying-glass" style="color: #2563eb;"></i> Consulta de Expediente Clínico por Código o Nombre
            </h4>
            <p style="font-size: 12.5px; color: #64748b; margin: 0 0 14px 0;">Busca cualquier equipo del inventario general para consultar su línea de tiempo histórica y todos los costos acumulados.</p>
            <div style="display: flex; gap: 10px; max-width: 600px;">
                <input type="text" id="buscar-expediente-manual-input" placeholder="Teclea código o nombre del equipo..." style="flex: 1; padding: 9px 14px; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 13px;">
                <button type="button" onclick="consultarExpedienteManual()" style="background: #2563eb; color: white; border: none; padding: 9px 18px; border-radius: 6px; font-weight: 700; cursor: pointer;">
                    Buscar Expediente
                </button>
            </div>
        </div>
    `;

    // Renderizar gráfico con Chart.js si está disponible
    setTimeout(() => {
        renderizarGraficaDepartamentos(porDepto);
    }, 100);
}

function renderizarGraficaDepartamentos(porDepto) {
    const canvas = document.getElementById("chart-mant-deptos");
    if (!canvas || typeof Chart === 'undefined') return;

    if (chartReportesDeptoInstance) {
        chartReportesDeptoInstance.destroy();
        chartReportesDeptoInstance = null;
    }

    const labels = porDepto.map(d => d.depto);
    const dataTickets = porDepto.map(d => d.tickets);

    chartReportesDeptoInstance = new Chart(canvas, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Tickets',
                data: dataTickets,
                backgroundColor: 'rgba(37, 99, 235, 0.85)',
                borderColor: '#1d4ed8',
                borderWidth: 1.5,
                borderRadius: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: ctx => ` ${ctx.raw} tickets registrados`
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { stepSize: 1 }
                }
            }
        }
    });
}

function consultarExpedienteManual() {
    const input = document.getElementById("buscar-expediente-manual-input");
    const val = input ? input.value.trim() : "";
    if (!val) {
        alert("⚠️ Ingresa un código o nombre de equipo para buscar.");
        return;
    }
    abrirExpedienteEquipoModal(val, val);
}

// ==============================================================================
// 7. FORMULARIO REPORTE DIRECTO Y AUTOCOMPLETE
// ==============================================================================
function alternarFormularioReporteDirecto() {
    const el = document.getElementById("contenedor-form-reporte-directo");
    if (!el) return;
    el.style.display = el.style.display === "none" ? "block" : "none";
    if (el.style.display === "block") {
        const inp = document.getElementById("input-danos-equipo-directo");
        if (inp) inp.focus();
    }
}

function normalizarTextoBusqueda(str) {
    return (str || "")
        .toString()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .toLowerCase()
        .trim();
}

function resaltarTexto(texto, query) {
    if (!query || !texto) return texto || "";
    const cleanQuery = normalizarTextoBusqueda(query);
    if (!cleanQuery) return texto;
    const re = new RegExp(`(${cleanQuery.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
    return String(texto).replace(re, '<mark style="background: #fef08a; color: #854d0e; padding: 0 2px; border-radius: 2px;">$1</mark>');
}

function activarSugerenciasDirecto() {
    const input = document.getElementById("input-danos-equipo-directo");
    filtrarSugerenciasDirecto(input ? input.value : "");
}

function filtrarSugerenciasDirecto(termino) {
    const dropdown = document.getElementById("sugerencias-directo-dropdown");
    const btnLimpiar = document.getElementById("btn-limpiar-busqueda-directo");
    if (!dropdown) return;

    if (btnLimpiar) {
        btnLimpiar.style.display = (termino && termino.trim()) ? "block" : "none";
    }

    const t = normalizarTextoBusqueda(termino);
    let coincidencias = [];
    if (!t) {
        coincidencias = catalogoGlobalEquipos.slice(0, 30);
    } else {
        const palabras = t.split(" ").filter(Boolean);
        coincidencias = catalogoGlobalEquipos.filter(item => {
            const norm = normalizarTextoBusqueda(item);
            return palabras.every(pal => norm.includes(pal));
        }).slice(0, 50);
    }

    if (coincidencias.length === 0) {
        dropdown.innerHTML = `<div style="padding: 12px; text-align: center; color: #64748b; font-size: 12.5px;">No se encontraron equipos</div>`;
        dropdown.style.display = "block";
        return;
    }

    dropdown.innerHTML = coincidencias.map(item => {
        const partes = item.split(" - ");
        const codigo = partes[0].trim();
        const nombre = partes.slice(1).join(" - ").trim() || codigo;
        return `
            <div onclick="seleccionarEquipoDirecto('${codigo.replace(/'/g, "\\'")}', '${item.replace(/'/g, "\\'")}')" 
                 style="padding: 9px 12px; cursor: pointer; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center; font-size: 13px;"
                 onmouseover="this.style.background='#eff6ff'" onmouseout="this.style.background='white'">
                <div>
                    <b>${nombre}</b>
                    <div style="font-size: 11px; color: #64748b; font-family: monospace;">${codigo}</div>
                </div>
            </div>
        `;
    }).join("");

    dropdown.style.display = "block";
}

function ocultarSugerenciasDirecto() {
    const dropdown = document.getElementById("sugerencias-directo-dropdown");
    if (dropdown) dropdown.style.display = "none";
}

function seleccionarEquipoDirecto(codigo, itemCompleto) {
    const input = document.getElementById("input-danos-equipo-directo");
    const hidden = document.getElementById("danos-sel-equipo-directo");
    if (input) input.value = itemCompleto;
    if (hidden) hidden.value = codigo;
    ocultarSugerenciasDirecto();
}

function limpiarBusquedaDirecto() {
    const input = document.getElementById("input-danos-equipo-directo");
    const hidden = document.getElementById("danos-sel-equipo-directo");
    const btnLimpiar = document.getElementById("btn-limpiar-busqueda-directo");
    if (input) {
        input.value = "";
        input.focus();
    }
    if (hidden) hidden.value = "";
    if (btnLimpiar) btnLimpiar.style.display = "none";
    filtrarSugerenciasDirecto("");
}

function manejarKeydownSugerenciasDirecto(e) {
    if (e.key === "Escape") ocultarSugerenciasDirecto();
}

// Cierre automático al hacer clic fuera
document.addEventListener("click", function(e) {
    const contDir = document.getElementById("contenedor-input-directo");
    const dropDir = document.getElementById("sugerencias-directo-dropdown");
    if (dropDir && contDir && !contDir.contains(e.target) && !dropDir.contains(e.target)) {
        dropDir.style.display = "none";
    }
});

async function guardarReporteDirectoDanado() {
    const selEq = document.getElementById("danos-sel-equipo-directo")?.value;
    const tipoEvento = document.getElementById("danos-tipo-evento")?.value;
    const estInicial = document.getElementById("danos-estado-inicial")?.value || "DIAGNOSTICO";
    const costo = parseFloat(document.getElementById("danos-costo-estimado")?.value || 0);
    const detalle = document.getElementById("danos-txt-detalle")?.value.trim();

    if (!selEq || !detalle) {
        alert("⚠️ Por favor selecciona un equipo y escribe el diagnóstico o detalle de la falla.");
        return;
    }

    const codPuro = selEq.includes(" - ") ? selEq.split(" - ")[0].trim() : selEq.trim();
    const userId = usuarioLogueado?.id_empleado ? String(usuarioLogueado.id_empleado) : "000";
    const userDepto = usuarioLogueado?.depto ? String(usuarioLogueado.depto).toUpperCase() : "TALLER";

    const payload = {
        codigo_equipo: codPuro,
        folio_vpro: "MANTENIMIENTO_DIRECTO",
        id_empleado: userId,
        tipo_evento: tipoEvento,
        descripcion: detalle,
        costo_asociado: costo,
        estado_final: estInicial,
        departamento: userDepto
    };

    try {
        const res = await fetch(`${API_URL}/api/inventario/historial/guardar`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (res.ok) {
            alert(`✅ Ticket de taller registrado con éxito para el equipo ${codPuro}.`);
            alternarFormularioReporteDirecto();
            limpiarBusquedaDirecto();
            const txtDet = document.getElementById("danos-txt-detalle");
            if (txtDet) txtDet.value = "";
            await cargarTableroKanban();
        } else {
            const err = await res.json();
            alert(`❌ Error al guardar reporte: ${err.detail || 'Fallo en servidor'}`);
        }
    } catch (e) {
        alert(`❌ Error de red: ${e.message}`);
    }
}

// ==============================================================================
// 8. EXPEDIENTE CLÍNICO DE HARDWARE & CHAT DE TALLER INTEGRADO
// ==============================================================================

let chatTallerActivo = {
    ticket: null,
    codigoEquipo: null,
    reportanteId: null,
    reportanteNombre: null,
    modoSimulacionReportante: false,
    estaCerrado: false,
    intervaloPoller: null,
    totalMensajes: 0
};

function cerrarModalExpedienteDanado() {
    const modal = document.getElementById("modal-danados-expediente");
    if (modal) modal.style.display = "none";
    if (chatTallerActivo.intervaloPoller) {
        clearInterval(chatTallerActivo.intervaloPoller);
        chatTallerActivo.intervaloPoller = null;
    }
}

async function abrirExpedienteEquipoModal(codId, nombreEquipo, numServicio) {
    const modal = document.getElementById("modal-danados-expediente");
    const titulo = document.getElementById("modal-expediente-titulo");
    const subtitulo = document.getElementById("modal-expediente-subtitulo");
    const contenido = document.getElementById("modal-expediente-contenido");
    const footerAcciones = document.getElementById("modal-expediente-acciones-footer");

    if (!modal || !contenido) return;

    if (titulo) titulo.innerHTML = `<i class="ph ph-first-aid" style="color: #ef4444;"></i> Expediente Clínico: ${escaparHTMLSeguro(nombreEquipo || codId)}`;
    if (subtitulo) subtitulo.innerText = `ID de Control: ${codId} • Historial completo de movimientos, mantenimiento e incidencias.`;
    contenido.innerHTML = `<div style="text-align: center; padding: 40px; color: #64748b;"><i class="ph ph-spinner ph-spin" style="font-size: 28px;"></i> Cargando historial clínico...</div>`;
    if (footerAcciones) footerAcciones.innerHTML = "";

    modal.style.display = "flex";

    // 1. Cargar el Chat de Taller en la columna derecha
    if (numServicio) {
        cargarChatTaller(numServicio, codId);
    } else {
        reiniciarChatTallerEstadoVacio(codId);
    }

    try {
        const codLimpio = (codId || '').trim();
        const resExp = await fetch(`${API_URL}/api/inventario/historial/${encodeURIComponent(codLimpio)}`);
        if (!resExp.ok) throw new Error(`HTTP ${resExp.status}`);

        const historial = await resExp.json();

        if (!historial || historial.length === 0) {
            contenido.innerHTML = `
                <div style="padding: 32px; text-align: center; color: #64748b;">
                    <i class="ph ph-clipboard-text" style="font-size: 36px; color: #cbd5e1; display: block; margin-bottom: 8px;"></i>
                    <p style="font-weight: 600; margin: 0 0 4px 0;">Sin eventos registrados en la bitácora histórica</p>
                    <p style="font-size: 12.5px; margin: 0;">Este activo no cuenta con entradas previas de daño o taller.</p>
                </div>
            `;
            return;
        }

        // Si no se pasó numServicio explícito pero hay tickets en el historial, autoseleccionar el más reciente
        if (!numServicio) {
            const primerTicket = historial.find(h => h.folio_vpro && String(h.folio_vpro).startsWith("REP-"));
            if (primerTicket) {
                cargarChatTicketDesdeHistorial(primerTicket.folio_vpro, codId);
            }
        }

        const costoTotal = historial.reduce((acc, h) => acc + (parseFloat(h.costo_asociado) || 0), 0);

        contenido.innerHTML = `
            <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 12px 16px; margin-bottom: 14px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                <div>
                    <span style="font-size: 11.5px; color: #64748b; font-weight: 600;">TOTAL DE ENTRADAS CLÍNICAS:</span>
                    <span style="font-weight: 800; font-size: 15px; color: #0f172a; margin-left: 6px;">${historial.length}</span>
                </div>
                <div>
                    <span style="font-size: 11.5px; color: #64748b; font-weight: 600;">INVERSIÓN TOTAL EN REPARACIONES:</span>
                    <span style="font-weight: 800; font-size: 15px; color: #059669; margin-left: 6px;">$${costoTotal.toLocaleString('es-MX', { minimumFractionDigits: 2 })}</span>
                </div>
            </div>

            <div class="tabla-container" style="max-height: 440px; overflow-y: auto;">
                <table class="tabla-vpro" style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr>
                            <th>Fecha</th>
                            <th>Folio Ref.</th>
                            <th>Tipo de Evento</th>
                            <th>Diagnóstico / Detalle Clínico</th>
                            <th>Costo ($)</th>
                            <th>Estatus</th>
                            <th style="text-align: center;">Chat</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${historial.map(h => {
                            const fec = h.fecha ? String(h.fecha).substring(0, 10) : 'Sin fecha';
                            const fol = h.folio_vpro || 'N/A';
                            const tipo = h.tipo_evento || 'REPORTE';
                            const diag = h.descripcion || 'Sin detalle';
                            const cto = parseFloat(h.costo_asociado) || 0;
                            const est = h.estado_final || 'OK';
                            const tieneFolioRep = fol && String(fol).startsWith("REP-");

                            const btnChat = tieneFolioRep ? `
                                <button type="button" onclick="cargarChatTicketDesdeHistorial('${escaparHTMLSeguro(fol)}', '${escaparHTMLSeguro(codId)}')" 
                                        style="background: #eff6ff; color: #2563eb; border: 1px solid #bfdbfe; padding: 3px 8px; border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;" 
                                        title="Ver bitácora de mensajes de este servicio">
                                    <i class="ph ph-chat-teardrop-text"></i> Ver
                                </button>
                            ` : `<span style="color: #cbd5e1; font-size: 11px;">—</span>`;

                            return `
                                <tr>
                                    <td>${escaparHTMLSeguro(fec)}</td>
                                    <td><b>${escaparHTMLSeguro(fol)}</b></td>
                                    <td><span style="background: #eff6ff; color: #1e40af; font-size: 10.5px; padding: 2px 6px; border-radius: 4px; font-weight: 600;">${escaparHTMLSeguro(tipo)}</span></td>
                                    <td style="max-width: 260px; line-height: 1.3; font-size: 12px;">${escaparHTMLSeguro(diag)}</td>
                                    <td style="font-weight: 700; font-size: 12px;">$${cto.toLocaleString('es-MX', { minimumFractionDigits: 2 })}</td>
                                    <td><span style="font-weight: 700; font-size: 11px;">${escaparHTMLSeguro(est)}</span></td>
                                    <td style="text-align: center;">${btnChat}</td>
                                </tr>
                            `;
                        }).join("")}
                    </tbody>
                </table>
            </div>
        `;

        if (numServicio && footerAcciones) {
            footerAcciones.innerHTML = `
                <button type="button" onclick="abrirModalQC('${escaparHTMLSeguro(numServicio)}', '${escaparHTMLSeguro(codId)}', 0)" style="background: #10b981; color: white; border: none; padding: 8px 16px; border-radius: 6px; font-weight: 700; font-size: 12.5px; cursor: pointer; display: flex; align-items: center; gap: 6px;">
                    <i class="ph ph-shield-check"></i> Abrir Control de Calidad QC para este Ticket
                </button>
            `;
        }

    } catch (err) {
        console.error("Error al cargar expediente:", err);
        contenido.innerHTML = `
            <div style="padding: 24px; text-align: center; color: #b91c1c;">
                Error al consultar expediente: ${err.message}
            </div>
        `;
    }
}

// ==============================================================================
// 9. FUNCIONALIDAD DEL CHAT DE TALLER (TÉCNICO ⇄ REPORTANTE)
// ==============================================================================

function reiniciarChatTallerEstadoVacio(codId) {
    chatTallerActivo.ticket = null;
    chatTallerActivo.codigoEquipo = codId;
    chatTallerActivo.estaCerrado = false;
    if (chatTallerActivo.intervaloPoller) {
        clearInterval(chatTallerActivo.intervaloPoller);
        chatTallerActivo.intervaloPoller = null;
    }

    const badgeTicket = document.getElementById("chat-taller-ticket-badge");
    const repNom = document.getElementById("chat-taller-reportante-nom");
    const estadoBadge = document.getElementById("chat-taller-estado-badge");
    const lista = document.getElementById("chat-taller-mensajes-lista");
    const formEnvio = document.getElementById("form-chat-taller-envio");
    const avisoCerrado = document.getElementById("chat-taller-aviso-cerrado");

    if (badgeTicket) badgeTicket.innerText = "—";
    if (repNom) repNom.innerText = "Consulta General";
    if (estadoBadge) estadoBadge.innerHTML = `<span style="font-size: 11px; font-weight: 700; background: #f1f5f9; color: #64748b; padding: 3px 8px; border-radius: 12px;">ℹ️ Consulta</span>`;
    if (formEnvio) formEnvio.style.display = "none";
    if (avisoCerrado) {
        avisoCerrado.style.display = "block";
        avisoCerrado.innerHTML = `<i class="ph ph-chats" style="color: #64748b;"></i> Selecciona un ticket con botón <b>Ver</b> en la tabla para revisar su chat.`;
    }

    if (lista) {
        lista.innerHTML = `
            <div style="text-align: center; color: #94a3b8; font-size: 12.5px; padding: 50px 10px;">
                <i class="ph ph-chat-teardrop-dots" style="font-size: 38px; display: block; margin-bottom: 8px; color: #cbd5e1;"></i>
                Para chatear en vivo con el reportante o ver notas de taller, abre el expediente desde una tarjeta del Kanban o elige un ticket del historial.
            </div>
        `;
    }
}

async function cargarChatTicketDesdeHistorial(folioTicket, codId) {
    if (!folioTicket || folioTicket === 'N/A') return;
    cargarChatTaller(folioTicket, codId);
}

function obtenerUsuarioActualSeguro() {
    if (typeof usuarioLogueado !== 'undefined' && usuarioLogueado && usuarioLogueado.id_empleado) {
        return {
            ...usuarioLogueado,
            nombre_completo: usuarioLogueado.nombre_completo || usuarioLogueado.nombre || "Cuauhtémoc Rivera Agúndez"
        };
    }
    if (typeof chatState !== 'undefined' && chatState && chatState.usuario && chatState.usuario.id_empleado) {
        return {
            ...chatState.usuario,
            nombre_completo: chatState.usuario.nombre_completo || chatState.usuario.nombre || "Cuauhtémoc Rivera Agúndez"
        };
    }
    try {
        const u = JSON.parse(localStorage.getItem("vpro_chat_usuario") || "{}");
        if (u && u.id_empleado) return u;
    } catch(e) {}
    try {
        const u2 = JSON.parse(localStorage.getItem("usuario") || "{}");
        if (u2 && u2.id_empleado) return u2;
    } catch(e) {}
    return { id_empleado: "201", nombre: "Cuauhtémoc Rivera Agúndez", nombre_completo: "Cuauhtémoc Rivera Agúndez" };
}

function alternarModoSimulacionReportante() {
    chatTallerActivo.modoSimulacionReportante = !chatTallerActivo.modoSimulacionReportante;
    actualizarBarraAutorChat();
}

function actualizarBarraAutorChat() {
    const lbl = document.getElementById("chat-taller-autor-label");
    const input = document.getElementById("chat-taller-input-texto");
    const btn = document.getElementById("btn-toggle-simular-reportante");
    const repNom = chatTallerActivo.reportanteNombre || "Reportante";
    const uAct = obtenerUsuarioActualSeguro();
    let miNombre = (String(uAct.id_empleado || "201").trim() === "201") ? "Cuauhtémoc Rivera Agúndez" : (uAct.nombre_completo || uAct.nombre || "Técnico Taller");

    if (chatTallerActivo.modoSimulacionReportante) {
        if (lbl) {
            lbl.style.color = "#047857";
            lbl.innerText = `${repNom} (Reportó Activo)`;
        }
        if (input) input.placeholder = `Escribe respuesta como ${repNom}...`;
        if (btn) {
            btn.style.background = "#d1fae5";
            btn.style.color = "#065f46";
            btn.style.borderColor = "#10b981";
            btn.innerHTML = `<i class="ph ph-arrows-left-right"></i> <span>⇄ Cambiar a Técnico (${miNombre.split(" ")[0]})</span>`;
        }
    } else {
        if (lbl) {
            lbl.style.color = "#1d4ed8";
            lbl.innerText = `${miNombre} (Taller VPRO)`;
        }
        if (input) input.placeholder = `Escribe un mensaje al reportante...`;
        if (btn) {
            btn.style.background = "#f1f5f9";
            btn.style.color = "#475569";
            btn.style.borderColor = "#cbd5e1";
            btn.innerHTML = `<i class="ph ph-arrows-left-right"></i> <span>⇄ Responder como Reportante (Prueba)</span>`;
        }
    }
}

let ultimoEnvioTyping = 0;
function alTeclearMensajeChatTaller() {
    const ahora = Date.now();
    if (ahora - ultimoEnvioTyping < 2000) return;
    ultimoEnvioTyping = ahora;

    const ticket = chatTallerActivo.ticket;
    if (!ticket || chatTallerActivo.estaCerrado) return;

    const uAct = obtenerUsuarioActualSeguro();
    const idAutor = String(uAct.id_empleado || "201").trim();
    const nomAutor = String(uAct.nombre_completo || uAct.nombre || "Técnico Taller").trim();

    fetch(`${API_URL}/api/inventario/mantenimiento/chat/escribiendo`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            num_servicio: ticket,
            id_empleado: idAutor,
            nombre_autor: nomAutor
        })
    }).catch(() => {});
}

async function cargarChatTaller(numServicio, codId) {
    if (!numServicio) return;

    if (chatTallerActivo.intervaloPoller) {
        clearInterval(chatTallerActivo.intervaloPoller);
        chatTallerActivo.intervaloPoller = null;
    }

    chatTallerActivo.ticket = numServicio;
    chatTallerActivo.codigoEquipo = codId;

    const badgeTicket = document.getElementById("chat-taller-ticket-badge");
    const repNom = document.getElementById("chat-taller-reportante-nom");
    const estadoBadge = document.getElementById("chat-taller-estado-badge");
    const lista = document.getElementById("chat-taller-mensajes-lista");
    const formEnvio = document.getElementById("form-chat-taller-envio");
    const avisoCerrado = document.getElementById("chat-taller-aviso-cerrado");

    if (badgeTicket) badgeTicket.innerText = `#${numServicio}`;
    if (lista) {
        lista.innerHTML = `
            <div style="text-align: center; color: #64748b; font-size: 12.5px; padding: 30px 10px;">
                <i class="ph ph-spinner ph-spin" style="font-size: 26px; display: block; margin-bottom: 6px; color: #2563eb;"></i>
                Cargando mensajes del ticket...
            </div>
        `;
    }

    try {
        const miIdLector = String(window.usuarioLogueado?.id_empleado || "201").trim();
        const res = await fetch(`${API_URL}/api/inventario/mantenimiento/chat/${encodeURIComponent(numServicio)}?id_lector=${encodeURIComponent(miIdLector)}`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = await res.json();

        chatTallerActivo.estaCerrado = Boolean(data.chat_cerrado);
        chatTallerActivo.reportanteId = data.reportante_id || "";
        chatTallerActivo.reportanteNombre = data.reportante_nombre || "Reportante";
        chatTallerActivo.totalMensajes = (data.mensajes || []).length;

        if (repNom) repNom.innerText = chatTallerActivo.reportanteNombre;

        // Render estado
        if (estadoBadge) {
            if (chatTallerActivo.estaCerrado) {
                estadoBadge.innerHTML = `<span style="font-size: 11px; font-weight: 700; background: #f1f5f9; color: #475569; padding: 3px 8px; border-radius: 12px; border: 1px solid #cbd5e1;">🔒 Sellado / Concluido</span>`;
            } else {
                estadoBadge.innerHTML = `<span style="font-size: 11px; font-weight: 700; background: #dcfce7; color: #15803d; padding: 3px 8px; border-radius: 12px;">🟢 En Revisión</span>`;
            }
        }

        // Render visibilidad del formulario de envío
        if (chatTallerActivo.estaCerrado) {
            if (formEnvio) formEnvio.style.display = "none";
            if (avisoCerrado) {
                avisoCerrado.style.display = "block";
                avisoCerrado.innerHTML = `<i class="ph ph-lock" style="color: #64748b;"></i> Este ticket fue concluido. El chat está sellado y archivado permanentemente.`;
            }
        } else {
            if (formEnvio) formEnvio.style.display = "flex";
            if (avisoCerrado) avisoCerrado.style.display = "none";
        }

        // Actualizar barra de autor
        chatTallerActivo.modoSimulacionReportante = false;
        if (typeof actualizarBarraAutorChat === "function") actualizarBarraAutorChat();

        // Render mensajes
        renderizarMensajesChatTaller(data.mensajes || []);

        // Iniciar polling si sigue abierto
        if (!chatTallerActivo.estaCerrado) {
            chatTallerActivo.intervaloPoller = setInterval(() => {
                sincronizarMensajesChatTallerSilencioso(numServicio);
            }, 3500);
        }

    } catch (err) {
        console.error("Error al cargar chat taller:", err);
        if (lista) {
            lista.innerHTML = `
                <div style="text-align: center; color: #ef4444; font-size: 12px; padding: 20px;">
                    Error al cargar mensajes: ${err.message}
                </div>
            `;
        }
    }
}

async function sincronizarMensajesChatTallerSilencioso(numServicio) {
    if (!numServicio || chatTallerActivo.ticket !== numServicio || chatTallerActivo.estaCerrado) return;

    try {
        const miIdLector = String(window.usuarioLogueado?.id_empleado || "201").trim();
        const res = await fetch(`${API_URL}/api/inventario/mantenimiento/chat/${encodeURIComponent(numServicio)}?id_lector=${encodeURIComponent(miIdLector)}`);
        if (!res.ok) return;
        const data = await res.json();

        // Control del indicador animado "Escribiendo..."
        const typingBox = document.getElementById("chat-taller-typing-indicator");
        const typingText = document.getElementById("chat-taller-typing-text");
        if (data.quien_escribe && data.quien_escribe.length > 0) {
            if (typingBox) typingBox.style.display = "flex";
            if (typingText) typingText.innerText = `${data.quien_escribe.join(", ")} está escribiendo...`;
        } else {
            if (typingBox) typingBox.style.display = "none";
        }

        const listaMsjs = data.mensajes || [];
        if (listaMsjs.length !== chatTallerActivo.totalMensajes) {
            chatTallerActivo.totalMensajes = listaMsjs.length;
            renderizarMensajesChatTaller(listaMsjs);
        }

        if (data.chat_cerrado && !chatTallerActivo.estaCerrado) {
            chatTallerActivo.estaCerrado = true;
            if (chatTallerActivo.intervaloPoller) {
                clearInterval(chatTallerActivo.intervaloPoller);
                chatTallerActivo.intervaloPoller = null;
            }
            const estadoBadge = document.getElementById("chat-taller-estado-badge");
            if (estadoBadge) estadoBadge.innerHTML = `<span style="font-size: 11px; font-weight: 700; background: #f1f5f9; color: #475569; padding: 3px 8px; border-radius: 12px; border: 1px solid #cbd5e1;">🔒 Sellado / Concluido</span>`;
            const formEnvio = document.getElementById("form-chat-taller-envio");
            const avisoCerrado = document.getElementById("chat-taller-aviso-cerrado");
            if (formEnvio) formEnvio.style.display = "none";
            if (avisoCerrado) avisoCerrado.style.display = "block";
        }
    } catch (_) {}
}

function renderizarMensajesChatTaller(mensajes) {
    const lista = document.getElementById("chat-taller-mensajes-lista");
    if (!lista) return;

    if (!mensajes || mensajes.length === 0) {
        lista.innerHTML = `
            <div style="text-align: center; color: #94a3b8; font-size: 12px; padding: 35px 12px;">
                <i class="ph ph-chat-centered-dots" style="font-size: 32px; display: block; margin-bottom: 6px; color: #cbd5e1;"></i>
                No hay mensajes aún en este ticket. Envía un mensaje para coordinar la revisión del equipo.
            </div>
        `;
        return;
    }

    const uAct = obtenerUsuarioActualSeguro();
    const miId = String(uAct.id_empleado || "201").trim();
    const repIdTicket = String(chatTallerActivo.reportanteId || "").trim();
    const repNomTicket = String(chatTallerActivo.reportanteNombre || "").trim();

    lista.innerHTML = mensajes.map(m => {
        const idAutor = String(m.id_empleado || "").trim();
        const rol = String(m.rol_autor || "OPERATIVO").toUpperCase();
        const texto = escaparHTMLSeguro(m.mensaje || "");
        
        // 1. Resolver nombre real oficial (NUNCA mostrar genéricos ni "Tú")
        let nombre = (m.nombre_autor || "").trim();
        if (idAutor === "201") {
            nombre = "Cuauhtémoc Rivera Agúndez";
        } else if (idAutor === "202" && (rol.includes("TALLER") || rol.includes("SUPERVISOR"))) {
            nombre = "Edgar Javier Amarillas";
        } else if (rol.includes("REPORT") || (repIdTicket && idAutor === repIdTicket)) {
            nombre = repNomTicket || nombre || "Reportante";
        } else if (!nombre || nombre === "Usuario" || nombre === "Técnico Taller") {
            nombre = (idAutor === "201") ? "Cuauhtémoc Rivera Agúndez" : ((idAutor === "202") ? "Edgar Javier Amarillas" : "Usuario");
        }
        const nombreLimpio = escaparHTMLSeguro(nombre);

        // 2. Formatear hora MZT Mazatlán / Culiacán (12 horas AM/PM)
        let horaMZT = "";
        if (m.fecha_hora) {
            const strF = String(m.fecha_hora).trim();
            horaMZT = strF.length > 11 ? strF.substring(11) : strF;
        }

        // 3. Mensaje del Sistema / Cierre de Ticket
        if (rol === "SISTEMA" || idAutor === "SISTEMA") {
            return `
                <div style="display: flex; justify-content: center; margin: 8px 0;">
                    <div style="background: #f8fafc; border: 1px solid #cbd5e1; color: #334155; font-size: 11px; padding: 6px 14px; border-radius: 14px; max-width: 92%; text-align: center; line-height: 1.35; box-shadow: 0 1px 2px rgba(0,0,0,0.03);">
                        <i class="ph ph-lock-key" style="color: #64748b; margin-right: 4px;"></i>${texto}
                    </div>
                </div>
            `;
        }

        // 4. Determinar si es del REPORTANTE (Verde • Izquierda) o del TALLER (Azul • Derecha)
        const esReportante = rol.includes("REPORT") || 
                             (repIdTicket && idAutor === repIdTicket && !rol.includes("TALLER") && !rol.includes("SUPERVISOR")) ||
                             (idAutor !== "201" && idAutor !== "202");

        if (esReportante) {
            // ========================================================
            // 🟢 MENSAJE DEL REPORTANTE (VERDE ESMERALDA • IZQUIERDA)
            // ========================================================
            return `
                <div style="display: flex; flex-direction: column; align-items: flex-start; margin-bottom: 10px;">
                    <div style="font-size: 11px; color: #065f46; margin-bottom: 3px; display: flex; align-items: center; gap: 5px;">
                        <span style="background: #d1fae5; color: #047857; font-size: 9.5px; font-weight: 800; padding: 2px 7px; border-radius: 4px; border: 1px solid #a7f3d0;">📋 REPORTÓ</span>
                        <b style="color: #047857;">${nombreLimpio}</b>
                        <span style="color: #64748b; font-size: 10px;">• ${horaMZT}</span>
                    </div>
                    <div style="background: #ecfdf5; color: #064e3b; border: 1.5px solid #10b981; padding: 9px 14px; border-radius: 14px 14px 14px 2px; max-width: 82%; font-size: 13px; line-height: 1.4; word-break: break-word; box-shadow: 0 1px 3px rgba(16,185,129,0.12);">
                        ${texto}
                    </div>
                </div>
            `;
        } else {
            // ========================================================
            // 🔵 MENSAJE DEL TALLER / TÉCNICO (AZUL VPRO • DERECHA)
            // ========================================================
            return `
                <div style="display: flex; flex-direction: column; align-items: flex-end; margin-bottom: 10px;">
                    <div style="font-size: 11px; color: #1e40af; margin-bottom: 3px; display: flex; align-items: center; gap: 5px;">
                        <span style="color: #64748b; font-size: 10px;">${horaMZT} •</span>
                        <b style="color: #1d4ed8;">${nombreLimpio}</b>
                        <span style="background: #dbeafe; color: #1d4ed8; font-size: 9.5px; font-weight: 800; padding: 2px 7px; border-radius: 4px; border: 1px solid #bfdbfe;">🔧 TALLER</span>
                    </div>
                    <div style="background: #2563eb; color: #ffffff; padding: 9px 14px; border-radius: 14px 14px 2px 14px; max-width: 82%; font-size: 13px; line-height: 1.4; word-break: break-word; box-shadow: 0 1px 3px rgba(37,99,235,0.2);">
                        ${texto}
                    </div>
                </div>
            `;
        }
    }).join("");

    setTimeout(() => {
        lista.scrollTop = lista.scrollHeight;
    }, 40);
}

async function enviarMensajeChatTaller(event) {
    if (event) event.preventDefault();

    const input = document.getElementById("chat-taller-input-texto");
    const btn = document.getElementById("btn-chat-taller-enviar");
    const texto = (input ? input.value : "").trim();

    if (!texto || !chatTallerActivo.ticket) return;

    const uAct = obtenerUsuarioActualSeguro();
    const repIdTicket = String(chatTallerActivo.reportanteId || "").trim();
    const repNomTicket = String(chatTallerActivo.reportanteNombre || "Reportante").trim();

    let miId = String(uAct.id_empleado || "201").trim();
    let miNombre = (miId === "201") ? "Cuauhtémoc Rivera Agúndez" : ((miId === "202") ? "Edgar Javier Amarillas" : (uAct.nombre_completo || uAct.nombre || "Técnico Taller"));
    let rolAutor = "SUPERVISOR TALLER";

    // Si el técnico activó la simulación de respuesta del reportante para pruebas:
    if (chatTallerActivo.modoSimulacionReportante) {
        miId = repIdTicket || "REP";
        miNombre = repNomTicket || "Reportante";
        rolAutor = "REPORTANTE";
    } else if (repIdTicket && miId === repIdTicket) {
        rolAutor = "REPORTANTE";
    }

    if (input) input.disabled = true;
    if (btn) btn.disabled = true;

    try {
        const payload = {
            num_servicio: chatTallerActivo.ticket,
            codigo_equipo: chatTallerActivo.codigoEquipo || "",
            id_empleado: miId,
            nombre_autor: miNombre,
            rol_autor: rolAutor,
            mensaje: texto
        };

        const res = await fetch(`${API_URL}/api/inventario/mantenimiento/chat/enviar`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (!res.ok) {
            const errData = await res.json().catch(() => ({}));
            throw new Error(errData.detail || `HTTP ${res.status}`);
        }

        if (input) input.value = "";

        // Refrescar mensajes inmediatamente
        sincronizarMensajesChatTallerSilencioso(chatTallerActivo.ticket);

    } catch (err) {
        alert(`No se pudo enviar el mensaje: ${err.message}`);
    } finally {
        if (input) {
            input.disabled = false;
            input.focus();
        }
        if (btn) btn.disabled = false;
    }
}

function escaparHTMLSeguro(str) {
    if (!str) return "";
    return String(str)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}
