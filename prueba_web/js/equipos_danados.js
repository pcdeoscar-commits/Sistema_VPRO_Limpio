// ==============================================================================
// MÓDULO: equipos_danados.js
// 7. Equipos dañados + buscador en vivo
// Líneas originales: 3592–4456 de script.js
// ==============================================================================

// ==========================================
// 7. MÓDULO EQUIPOS DAÑADOS
// ==========================================
let datosRadarDanosCache = [];
let datosDanosFiltrados = [];
let chartDanadosInstance = null;

// ==============================================================================
// BUSCADOR EN VIVO DE EQUIPOS PARA EXPEDIENTE CLÍNICO Y REPORTES DE DAÑOS
// ==============================================================================
let catalogoGlobalEquipos = [];
let indiceFocoSugerenciaExpediente = -1;
let indiceFocoSugerenciaDirecto = -1;

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

// --- Autocomplete Expediente Clínico ---
function activarSugerenciasExpediente() {
    const input = document.getElementById("input-expediente-buscar");
    filtrarSugerenciasExpediente(input ? input.value : "");
}

function filtrarSugerenciasExpediente(termino) {
    const dropdown = document.getElementById("sugerencias-expediente-dropdown");
    const btnLimpiar = document.getElementById("btn-limpiar-busqueda-expediente");
    if (!dropdown) return;

    if (btnLimpiar) {
        btnLimpiar.style.display = (termino && termino.trim()) ? "block" : "none";
    }

    const t = normalizarTextoBusqueda(termino);
    indiceFocoSugerenciaExpediente = -1;

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
        dropdown.innerHTML = `
            <div style="padding: 16px; text-align: center; color: #64748b; font-size: 13px;">
                <i class="ph ph-warning-circle" style="font-size: 20px; color: #f59e0b; display: block; margin-bottom: 4px;"></i>
                No se encontraron equipos con el término: "<b>${termino}</b>"<br>
                <span style="font-size: 11.5px; color: #94a3b8;">Intenta con otra palabra clave (marca, nombre o código).</span>
            </div>
        `;
        dropdown.style.display = "block";
        return;
    }

    dropdown.innerHTML = `
        <div style="padding: 8px 12px; background: #f8fafc; border-bottom: 1px solid #e2e8f0; font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; display: flex; justify-content: space-between;">
            <span>Coincidencias encontradas (${coincidencias.length}${coincidencias.length === 50 ? '+' : ''}):</span>
            <span style="font-size: 10.5px; text-transform: none; color: #94a3b8;">Usa ↑ ↓ y Enter o haz clic</span>
        </div>
        ` + coincidencias.map((item, idx) => {
            const partes = item.split(" - ");
            const codigo = partes[0].trim();
            const nombre = partes.slice(1).join(" - ").trim() || codigo;
            return `
                <div class="sugerencia-item-exp" data-idx="${idx}" onclick="seleccionarEquipoExpediente('${codigo.replace(/'/g, "\\'")}', '${item.replace(/'/g, "\\'")}')" 
                     style="padding: 10px 14px; cursor: pointer; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center; transition: background 0.15s;"
                     onmouseover="this.style.background='#eff6ff'" onmouseout="this.style.background='white'">
                    <div style="flex: 1; padding-right: 12px;">
                        <div style="font-weight: 600; color: #0f172a; font-size: 13.5px; line-height: 1.3;">
                            ${resaltarTexto(nombre, termino)}
                        </div>
                        <div style="font-size: 11.5px; color: #64748b; margin-top: 3px; display: flex; align-items: center; gap: 6px;">
                            <span style="background: #e2e8f0; color: #334155; padding: 2px 7px; border-radius: 4px; font-family: monospace; font-weight: 700; font-size: 11px;">
                                ${resaltarTexto(codigo, termino)}
                            </span>
                        </div>
                    </div>
                    <i class="ph ph-arrow-circle-right" style="color: var(--accent-color); font-size: 18px; flex-shrink: 0;"></i>
                </div>
            `;
        }).join("");

    dropdown.style.display = "block";
}

function ocultarSugerenciasExpediente() {
    const dropdown = document.getElementById("sugerencias-expediente-dropdown");
    if (dropdown) dropdown.style.display = "none";
}

function seleccionarEquipoExpediente(codigo, itemCompleto) {
    const input = document.getElementById("input-expediente-buscar");
    const hidden = document.getElementById("sel-expediente-equipo-buscar");
    if (input) input.value = itemCompleto;
    if (hidden) hidden.value = codigo;
    ocultarSugerenciasExpediente();
    buscarExpedienteDanado();
}

function limpiarBusquedaExpediente() {
    const input = document.getElementById("input-expediente-buscar");
    const hidden = document.getElementById("sel-expediente-equipo-buscar");
    const btnLimpiar = document.getElementById("btn-limpiar-busqueda-expediente");
    if (input) {
        input.value = "";
        input.focus();
    }
    if (hidden) hidden.value = "";
    if (btnLimpiar) btnLimpiar.style.display = "none";
    filtrarSugerenciasExpediente("");
}

function manejarKeydownSugerenciasExpediente(e) {
    const dropdown = document.getElementById("sugerencias-expediente-dropdown");
    if (!dropdown || dropdown.style.display === "none") {
        if (e.key === "Enter") {
            e.preventDefault();
            buscarExpedienteDanado();
        }
        return;
    }

    const items = dropdown.querySelectorAll(".sugerencia-item-exp");
    if (items.length === 0) return;

    if (e.key === "ArrowDown") {
        e.preventDefault();
        indiceFocoSugerenciaExpediente = (indiceFocoSugerenciaExpediente + 1) % items.length;
        items.forEach((it, i) => it.style.background = i === indiceFocoSugerenciaExpediente ? "#eff6ff" : "white");
        items[indiceFocoSugerenciaExpediente].scrollIntoView({ block: "nearest" });
    } else if (e.key === "ArrowUp") {
        e.preventDefault();
        indiceFocoSugerenciaExpediente = (indiceFocoSugerenciaExpediente - 1 + items.length) % items.length;
        items.forEach((it, i) => it.style.background = i === indiceFocoSugerenciaExpediente ? "#eff6ff" : "white");
        items[indiceFocoSugerenciaExpediente].scrollIntoView({ block: "nearest" });
    } else if (e.key === "Enter") {
        e.preventDefault();
        if (indiceFocoSugerenciaExpediente >= 0 && indiceFocoSugerenciaExpediente < items.length) {
            items[indiceFocoSugerenciaExpediente].click();
        } else {
            buscarExpedienteDanado();
        }
    } else if (e.key === "Escape") {
        ocultarSugerenciasExpediente();
    }
}

// --- Autocomplete Reporte Directo ---
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

    dropdown.innerHTML = coincidencias.map((item, idx) => {
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
    const contExp = document.getElementById("contenedor-input-expediente");
    const dropExp = document.getElementById("sugerencias-expediente-dropdown");
    if (dropExp && contExp && !contExp.contains(e.target) && !dropExp.contains(e.target)) {
        dropExp.style.display = "none";
    }

    const contDir = document.getElementById("contenedor-input-directo");
    const dropDir = document.getElementById("sugerencias-directo-dropdown");
    if (dropDir && contDir && !contDir.contains(e.target) && !dropDir.contains(e.target)) {
        dropDir.style.display = "none";
    }

    const contInv = document.getElementById("contenedor-busqueda-inv-editor");
    const dropInv = document.getElementById("sugerencias-inv-editor-dropdown");
    if (dropInv && contInv && !contInv.contains(e.target) && !dropInv.contains(e.target)) {
        dropInv.style.display = "none";
    }
});

function cambiarPestanaDanados(tab) {
    // Vista unificada: si se invoca por compatibilidad, asegurar que la vista principal esté activa
    const viewRadar = document.getElementById("subvista-danados-radar");
    if (viewRadar) viewRadar.style.display = 'block';
}

async function cargarModuloDanados() {
    try {
        // Cargar catálogo global para los selectores si no se ha cargado
        const [resCat, resRadar] = await Promise.all([
            fetch(`${API_URL}/api/inventario/catalogo-global`),
            fetch(`${API_URL}/api/inventario/radar-danos`)
        ]);

        if (resCat.ok) {
            const catalogo = await resCat.json();
            catalogoGlobalEquipos = catalogo || [];
            const selDirecto = document.getElementById("danos-sel-equipo-directo");

            if (selDirecto && selDirecto.tagName === 'SELECT' && selDirecto.children.length <= 1) {
                selDirecto.innerHTML = '<option value="">--- Seleccionar Activo ---</option>' +
                    catalogo.map(c => `<option value="${c}">${c}</option>`).join("");
            }
        }

        if (resRadar.ok) {
            const rawRadar = await resRadar.json();
            
            // 🛡️ DEDUPLICACIÓN ESTRICTA: Garantizar que cada NUM_SERVICIO aparezca exactamente una vez
            const vistosServicios = new Set();
            datosRadarDanosCache = [];
            (rawRadar || []).forEach(d => {
                const numServ = d.NUM_SERVICIO ? String(d.NUM_SERVICIO).trim() : null;
                if (!numServ || !vistosServicios.has(numServ)) {
                    if (numServ) vistosServicios.add(numServ);
                    datosRadarDanosCache.push(d);
                }
            });

            const badgeDanados = document.getElementById("badge-danados");
            if (badgeDanados) badgeDanados.innerText = datosRadarDanosCache.length || 0;

            // Poblar dropdown de reportantes
            const selReportante = document.getElementById("filtro-danos-reportante");
            if (selReportante) {
                const reportantes = [...new Set(datosRadarDanosCache.map(d => d["REPORTÓ"] || d["REPORTÓ_RAW"]).filter(Boolean))].sort();
                selReportante.innerHTML = '<option value="Todos">Todos</option>' +
                    reportantes.map(r => `<option value="${r}">${r}</option>`).join("");
            }

            // Poblar dropdown de tickets para resolver
            const selTicketResolver = document.getElementById("sel-ticket-danado-cerrar");
            if (selTicketResolver) {
                selTicketResolver.innerHTML = '<option value="">--- Seleccionar Ticket ---</option>' +
                    datosRadarDanosCache.map(d => `<option value="${d.NUM_SERVICIO}">#${d.NUM_SERVICIO} - ${d.EQUIPO} (${d.ESTADO})</option>`).join("");
            }

            aplicarFiltrosDanados();
        }
    } catch (err) {
        console.error("Error al cargar radar de daños:", err);
    }
}

function cargarEquiposDanados() {
    cargarModuloDanados();
}

function aplicarFiltrosDanados() {
    const fDesde = document.getElementById("filtro-danos-desde")?.value;
    const fHasta = document.getElementById("filtro-danos-hasta")?.value;
    const fDepto = document.getElementById("filtro-danos-depto")?.value || "Todos";
    const fReportante = document.getElementById("filtro-danos-reportante")?.value || "Todos";

    const hoy = new Date();

    datosDanosFiltrados = datosRadarDanosCache.filter(item => {
        const fRepStr = item.FECHA_REPORTE ? String(item.FECHA_REPORTE).substring(0, 10) : "";
        if (fDesde && fRepStr && fRepStr < fDesde) return false;
        if (fHasta && fRepStr && fRepStr > fHasta) return false;

        if (fDepto !== "Todos") {
            const dItem = String(item.DEPARTAMENTO || "").toUpperCase();
            if (dItem !== fDepto.toUpperCase()) return false;
        }

        if (fReportante !== "Todos") {
            const repItem = String(item["REPORTÓ"] || item["REPORTÓ_RAW"] || "").trim();
            if (repItem !== fReportante.trim()) return false;
        }

        return true;
    });

    // Calcular días fuera para cada registro
    datosDanosFiltrados.forEach(item => {
        if (item.FECHA_REPORTE) {
            const fItem = new Date(item.FECHA_REPORTE);
            const diffTime = Math.abs(hoy - fItem);
            item.DIAS_FUERA = Math.floor(diffTime / (1000 * 60 * 60 * 24));
        } else {
            item.DIAS_FUERA = 0;
        }
    });

    // 4 KPIs
    const elKpiTotal = document.getElementById("kpi-danados-total");
    const elKpiDias = document.getElementById("kpi-danados-dias");
    const elKpiTopRep = document.getElementById("kpi-danados-top-rep");
    const elKpiTopArea = document.getElementById("kpi-danados-top-area");

    if (elKpiTotal) elKpiTotal.innerText = datosDanosFiltrados.length;

    const promDias = datosDanosFiltrados.length > 0 
        ? Math.round(datosDanosFiltrados.reduce((acc, i) => acc + (i.DIAS_FUERA || 0), 0) / datosDanosFiltrados.length)
        : 0;
    if (elKpiDias) elKpiDias.innerText = `${promDias} Días`;

    // Conteo por reportante
    const conteoRep = {};
    const conteoDepto = {};
    datosDanosFiltrados.forEach(i => {
        const r = i["REPORTÓ"] || i["REPORTÓ_RAW"] || "Sin asignar";
        conteoRep[r] = (conteoRep[r] || 0) + 1;
        const d = i.DEPARTAMENTO || "General";
        conteoDepto[d] = (conteoDepto[d] || 0) + 1;
    });

    const topRep = Object.keys(conteoRep).sort((a,b) => conteoRep[b] - conteoRep[a])[0] || "--";
    const topDepto = Object.keys(conteoDepto).sort((a,b) => conteoDepto[b] - conteoDepto[a])[0] || "--";

    if (elKpiTopRep) elKpiTopRep.innerText = topRep;
    if (elKpiTopArea) elKpiTopArea.innerText = topDepto;

    // Actualizar gráfica Chart.js
    renderizarGraficaDanadosPersonal(conteoRep);

    // Renderizar tabla interactiva
    renderizarTablaDanados(datosDanosFiltrados);
}

function renderizarGraficaDanadosPersonal(conteoRep) {
    const canvas = document.getElementById("chart-danados-personal");
    if (!canvas || typeof Chart === 'undefined') return;

    if (chartDanadosInstance) {
        chartDanadosInstance.destroy();
        chartDanadosInstance = null;
    }

    const labels = Object.keys(conteoRep).slice(0, 10);
    const data = labels.map(l => conteoRep[l]);

    chartDanadosInstance = new Chart(canvas, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Tickets Activos',
                data: data,
                backgroundColor: 'rgba(239, 68, 68, 0.85)',
                borderColor: '#dc2626',
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
                        label: ctx => ` ${ctx.raw} ticket(s) activo(s)`
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { stepSize: 1 }
                },
                x: {
                    ticks: { maxRotation: 35, minRotation: 0 }
                }
            }
        }
    });
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

function renderizarTablaDanados(lista) {
    const tbody = document.getElementById("tabla-danados-body");
    if (!tbody) return;

    if (lista.length === 0) {
        tbody.innerHTML = `<tr><td colspan="11" style="text-align: center; padding: 24px; color: #166534; font-weight: 500;">✅ No hay equipos con daño bajo estos criterios de búsqueda.</td></tr>`;
        return;
    }

    tbody.innerHTML = lista.map(eq => {
        const estado = (eq.ESTADO || 'EN REVISIÓN').toUpperCase();
        let badgeStyle = "background: #fef3c7; color: #92400e;";
        if (estado.includes('TALLER') || estado.includes('GRAVE') || estado.includes('DAÑ')) badgeStyle = "background: #fee2e2; color: #991b1b;";
        else if (estado.includes('PIEZA') || estado.includes('ESPERA')) badgeStyle = "background: #e0e7ff; color: #3730a3;";
        else if (estado.includes('REPARADO') || estado.includes('RESUELTO')) badgeStyle = "background: #dcfce7; color: #166534;";

        const idSeguro = encodeURIComponent(eq.ID || '');
        const nomSeguro = encodeURIComponent(eq.EQUIPO || eq.ID || '');
        const ticketSeguro = encodeURIComponent(eq.NUM_SERVICIO || '');

        return `
            <tr style="transition: background-color 0.15s ease;">
                <td style="font-weight: 700; color: #2563eb; cursor: pointer;" 
                    onclick="abrirExpedienteEquipoModal(decodeURIComponent('${idSeguro}'), decodeURIComponent('${nomSeguro}'), decodeURIComponent('${ticketSeguro}'))" 
                    title="Haz clic para ver el expediente clínico de este equipo">
                    <span style="display: inline-flex; align-items: center; gap: 4px; text-decoration: underline dotted;">
                        #${escaparHTMLSeguro(eq.NUM_SERVICIO) || '--'}
                    </span>
                </td>
                <td>${eq.FECHA_REPORTE ? String(eq.FECHA_REPORTE).substring(0, 10) : '--'}</td>
                <td><span style="background: #f1f5f9; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 11px;">${eq.DIAS_FUERA || 0} d</span></td>
                <td style="cursor: pointer;" 
                    onclick="abrirExpedienteEquipoModal(decodeURIComponent('${idSeguro}'), decodeURIComponent('${nomSeguro}'), decodeURIComponent('${ticketSeguro}'))" 
                    title="Haz clic para consultar el historial completo del activo ${escaparHTMLSeguro(eq.ID)}">
                    <code style="background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; padding: 2px 8px; border-radius: 4px; font-weight: 700; display: inline-flex; align-items: center; gap: 4px; text-decoration: underline dotted;">
                        ${escaparHTMLSeguro(eq.ID) || '--'}
                        <i class="ph ph-magnifying-glass" style="font-size: 11px;"></i>
                    </code>
                </td>
                <td style="font-weight: 600; color: #0f172a; cursor: pointer;" 
                    onclick="abrirExpedienteEquipoModal(decodeURIComponent('${idSeguro}'), decodeURIComponent('${nomSeguro}'), decodeURIComponent('${ticketSeguro}'))" 
                    title="Haz clic para abrir el expediente de ${escaparHTMLSeguro(eq.EQUIPO)}">
                    <span style="display: inline-flex; align-items: center; gap: 6px; color: #0f172a;">
                        ${escaparHTMLSeguro(eq.EQUIPO) || '--'}
                        <i class="ph ph-arrow-square-out" style="color: #64748b; font-size: 13px;"></i>
                    </span>
                </td>
                <td>${escaparHTMLSeguro(eq.DEPARTAMENTO) || '--'}</td>
                <td>${escaparHTMLSeguro(eq["REPORTÓ"] || eq["REPORTÓ_RAW"]) || '--'}</td>
                <td><span style="display: inline-block; padding: 3px 8px; border-radius: 6px; font-size: 11px; font-weight: 700; ${badgeStyle}">${escaparHTMLSeguro(estado)}</span></td>
                <td style="max-width: 240px; font-size: 12px; line-height: 1.4;">${escaparHTMLSeguro(eq.FALLA) || '--'}</td>
                <td style="font-weight: 700; color: #0f172a;">$${Number(eq.COSTO || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</td>
                <td>
                    <button type="button" 
                        onclick="abrirExpedienteEquipoModal(decodeURIComponent('${idSeguro}'), decodeURIComponent('${nomSeguro}'), decodeURIComponent('${ticketSeguro}'))" 
                        style="background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; padding: 5px 10px; border-radius: 6px; font-size: 11.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                        <i class="ph ph-first-aid"></i> Historial
                    </button>
                </td>
            </tr>
        `;
    }).join("");
}

function filtrarTablaDanadosEnVivo(termino) {
    const t = (termino || "").toLowerCase().trim();
    if (!t) {
        renderizarTablaDanados(datosDanosFiltrados);
        return;
    }
    const filtrados = datosDanosFiltrados.filter(eq =>
        (eq.EQUIPO && eq.EQUIPO.toLowerCase().includes(t)) ||
        (eq.ID && eq.ID.toLowerCase().includes(t)) ||
        (eq.DEPARTAMENTO && eq.DEPARTAMENTO.toLowerCase().includes(t)) ||
        (eq["REPORTÓ"] && eq["REPORTÓ"].toLowerCase().includes(t)) ||
        (eq.FALLA && eq.FALLA.toLowerCase().includes(t)) ||
        (eq.ESTADO && eq.ESTADO.toLowerCase().includes(t)) ||
        String(eq.NUM_SERVICIO).includes(t)
    );
    renderizarTablaDanados(filtrados);
}

function resetearFiltrosDanados() {
    const fDesde = document.getElementById("filtro-danos-desde");
    const fHasta = document.getElementById("filtro-danos-hasta");
    const fDepto = document.getElementById("filtro-danos-depto");
    const fReportante = document.getElementById("filtro-danos-reportante");
    const fBuscar = document.getElementById("buscar-danados-tabla");

    if (fDesde) fDesde.value = "";
    if (fHasta) fHasta.value = "";
    if (fDepto) fDepto.value = "Todos";
    if (fReportante) fReportante.value = "Todos";
    if (fBuscar) fBuscar.value = "";

    aplicarFiltrosDanados();
}

async function guardarReporteDirectoDanado() {
    const selEq = document.getElementById("danos-sel-equipo-directo")?.value;
    const tipoEvento = document.getElementById("danos-tipo-evento")?.value;
    const estInicial = document.getElementById("danos-estado-inicial")?.value;
    const costo = parseFloat(document.getElementById("danos-costo-estimado")?.value || 0);
    const detalle = document.getElementById("danos-txt-detalle")?.value.trim();
    const fotoFile = document.getElementById("danos-input-foto")?.files?.[0];

    if (!selEq || !detalle) {
        alert("⚠️ Por favor selecciona un equipo y escribe el diagnóstico o detalle del daño.");
        return;
    }

    const codPuro = selEq.includes(" - ") ? selEq.split(" - ")[0].trim() : selEq.trim();
    const userId = usuarioLogueado?.id_empleado ? String(usuarioLogueado.id_empleado) : "000";
    const userDepto = usuarioLogueado?.depto ? String(usuarioLogueado.depto).toUpperCase() : "OFICINA";

    const payload = {
        codigo_equipo: codPuro,
        folio_vpro: "MANTENIMIENTO_INTERNO",
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

        if (!res.ok) {
            const err = await res.text();
            throw new Error(err);
        }

        if (fotoFile) {
            const fd = new FormData();
            fd.append("file", fotoFile);
            fd.append("codigo_equipo", codPuro);
            fd.append("folio_vpro", "MANTENIMIENTO_INTERNO");
            await fetch(`${API_URL}/api/inventario/subir-evidencia`, {
                method: "POST",
                body: fd
            });
        }

        alert("✅ ¡Ticket de falla registrado con éxito en base de datos!");
        document.getElementById("danos-txt-detalle").value = "";
        document.getElementById("danos-costo-estimado").value = "0.00";
        if (document.getElementById("danos-input-foto")) document.getElementById("danos-input-foto").value = "";
        cargarModuloDanados();
    } catch (e) {
        console.error("Error al guardar ticket directo:", e);
        alert(`❌ Error al registrar ticket: ${e.message}`);
    }
}

async function cerrarTicketDanado() {
    const selTicket = document.getElementById("sel-ticket-danado-cerrar")?.value;
    const nuevoEstado = document.getElementById("sel-estado-danado-cerrar")?.value;

    if (!selTicket) {
        alert("⚠️ Por favor selecciona el ticket que deseas resolver.");
        return;
    }

    if (!confirm(`¿Confirmas rehabilitar el equipo y marcar el ticket #${selTicket} como ${nuevoEstado}?`)) {
        return;
    }

    try {
        const res = await fetch(`${API_URL}/api/inventario/reparacion/cerrar/${selTicket}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ estado_actual: nuevoEstado })
        });

        if (res.ok) {
            alert(`✅ Ticket #${selTicket} cerrado con estado: ${nuevoEstado}. Equipo rehabilitado.`);
            cargarModuloDanados();
        } else {
            const err = await res.text();
            alert(`❌ Error al cerrar ticket: ${err}`);
        }
    } catch (e) {
        alert(`❌ Error de comunicación: ${e.message}`);
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// MODAL DE EXPEDIENTE CLÍNICO INTEGRADO (ACCESIBLE DESDE CÓDIGO ID / EQUIPO / TICKET)
// ══════════════════════════════════════════════════════════════════════════════
function cerrarModalExpedienteDanado() {
    const modal = document.getElementById("modal-danados-expediente");
    if (modal) modal.style.display = "none";
}

async function abrirExpedienteEquipoModal(codigoEquipo, nombreEquipo, numServicio) {
    const modal = document.getElementById("modal-danados-expediente");
    const titulo = document.getElementById("modal-expediente-titulo");
    const subtitulo = document.getElementById("modal-expediente-subtitulo");
    const contenido = document.getElementById("modal-expediente-contenido");
    const footerAcciones = document.getElementById("modal-expediente-acciones-footer");

    if (!modal || !contenido) return;

    modal.style.display = "flex";
    const codLimpio = (codigoEquipo || "").trim();
    const nomLimpio = (nombreEquipo || codLimpio).trim();

    titulo.innerHTML = `<i class="ph ph-first-aid" style="color: #ef4444;"></i> Expediente Clínico: <code style="background: #f1f5f9; padding: 2px 8px; border-radius: 6px; color: #0f172a; margin-left: 6px;">${escaparHTMLSeguro(codLimpio)}</code>`;
    subtitulo.innerText = `Activo: ${nomLimpio}`;

    contenido.innerHTML = `
        <div style="text-align: center; padding: 40px; color: #64748b;">
            <i class="ph ph-spinner ph-spin" style="font-size: 32px; color: #2563eb;"></i>
            <p style="margin-top: 10px; font-size: 14px;">Consultando historial médico y movimientos de ${escaparHTMLSeguro(nomLimpio)}...</p>
        </div>
    `;

    if (footerAcciones) footerAcciones.innerHTML = "";

    try {
        const res = await fetch(`${API_URL}/api/inventario/expediente/${encodeURIComponent(codLimpio)}`);
        if (!res.ok) throw new Error("No se pudo obtener el historial del equipo");

        const data = await res.json();
        const historial = data.historial || [];
        const fotos = data.fotos || [];

        // Calcular costo acumulado histórico
        const costoTotal = historial.reduce((acc, h) => {
            const val = parseFloat(h["COSTO ($)"] || h["COSTO"] || 0);
            return acc + (isNaN(val) ? 0 : val);
        }, 0);

        const ultimoEstado = historial.length > 0 ? (historial[0]["ESTADO POSTERIOR"] || "EN REVISIÓN") : "BUEN ESTADO";

        // URL de foto de evidencia
        let urlFoto = "";
        if (historial.length > 0) {
            const folioRef = String(historial[0]["FOLIO OP / REF"] || "MANTENIMIENTO_INTERNO").replace(/[/\\ ]/g, "_").toUpperCase();
            const codSafe = codLimpio.replace(/[/\\ ]/g, "_").toUpperCase();
            urlFoto = `${API_URL}/evidencias_web/Evidencia_${folioRef}_${codSafe}.jpg`;
        } else if (fotos.length > 0) {
            urlFoto = `${API_URL}/${fotos[0]}`;
        }

        // Renderizar ficha del equipo y tabla histórica
        contenido.innerHTML = `
            <!-- Ficha Resumen -->
            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 16px; margin-bottom: 20px;">
                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 16px;">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px;">
                        <div>
                            <span style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase;">Nombre del Activo</span>
                            <div style="font-size: 17px; font-weight: 700; color: #0f172a; margin-top: 2px;">${escaparHTMLSeguro(nomLimpio)}</div>
                            <span style="font-size: 12px; color: #64748b; font-family: monospace;">ID: ${escaparHTMLSeguro(codLimpio)}</span>
                        </div>
                        <span style="background: #fee2e2; color: #991b1b; padding: 4px 10px; border-radius: 6px; font-size: 11.5px; font-weight: 700;">
                            ${escaparHTMLSeguro(ultimoEstado)}
                        </span>
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 14px; border-top: 1px solid #cbd5e1; padding-top: 12px;">
                        <div style="background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 14px;">
                            <span style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">Intervenciones Históricas</span>
                            <div style="font-size: 22px; font-weight: 800; color: #0f172a; margin-top: 2px;">${historial.length}</div>
                        </div>
                        <div style="background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 14px;">
                            <span style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">Costo Acumulado Total</span>
                            <div style="font-size: 22px; font-weight: 800; color: #047857; margin-top: 2px;">$${Number(costoTotal).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</div>
                        </div>
                    </div>
                </div>

                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 14px; text-align: center; display: flex; flex-direction: column; justify-content: center; align-items: center;">
                    <span style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; margin-bottom: 8px;">📸 Evidencia Fotográfica</span>
                    <div style="width: 100%; height: 135px; background: #e2e8f0; border-radius: 8px; overflow: hidden; display: flex; align-items: center; justify-content: center;">
                        <img id="modal-expediente-foto" src="${urlFoto}" alt="Evidencia" 
                            style="width: 100%; height: 100%; object-fit: cover; cursor: pointer;"
                            onclick="if(this.src) window.open(this.src, '_blank')"
                            onerror="this.style.display='none'; document.getElementById('modal-expediente-sin-foto').style.display='block';">
                        <div id="modal-expediente-sin-foto" style="display: none; color: #94a3b8; font-size: 12px; padding: 10px;">
                            <i class="ph ph-image-square" style="font-size: 28px; display: block; margin-bottom: 4px;"></i>
                            Sin fotografía vinculada
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tabla de Historial Completo -->
            <div style="background: white; border: 1px solid #e2e8f0; border-radius: 10px; padding: 16px;">
                <h5 style="margin: 0 0 12px 0; color: #0f172a; display: flex; align-items: center; gap: 8px; font-size: 14px;">
                    <i class="ph ph-clock-counter-clockwise" style="color: #2563eb;"></i> Bitácora Cronológica de Entradas a Taller y Fallas
                </h5>
                <div class="tabla-container" style="max-height: 280px; overflow-y: auto;">
                    <table class="tabla-vpro" style="font-size: 12px; width: 100%;">
                        <thead>
                            <tr style="background: #f8fafc;">
                                <th>Fecha</th>
                                <th>Folio / OP</th>
                                <th>Área</th>
                                <th>Tipo Evento</th>
                                <th>Diagnóstico / Notas</th>
                                <th>Costo</th>
                                <th>Estado Posterior</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${historial.length === 0 ? `
                                <tr><td colspan="7" style="text-align: center; padding: 24px; color: #166534; font-weight: 500;">
                                    ✅ Este equipo no tiene registros previos de daño o reparación en su expediente.
                                </td></tr>
                            ` : historial.map(h => {
                                const fec = h["FECHA"] ? String(h["FECHA"]).substring(0, 10) : '--';
                                const fol = h["FOLIO OP / REF"] || '--';
                                const area = h["ÁREA"] || '--';
                                const tipo = h["TIPO DE EVENTO"] || h["TIPO EVENTO"] || '--';
                                const diag = h["DIAGNÓSTICO / NOTAS"] || h["DIAGNÓSTICO"] || h["DETALLE"] || '--';
                                const cto = Number(h["COSTO ($)"] || h["COSTO"] || 0);
                                const est = h["ESTADO POSTERIOR"] || '--';
                                return `
                                    <tr>
                                        <td>${escaparHTMLSeguro(fec)}</td>
                                        <td><b>${escaparHTMLSeguro(fol)}</b></td>
                                        <td>${escaparHTMLSeguro(area)}</td>
                                        <td><span style="background: #eff6ff; color: #1e40af; font-size: 11px; padding: 2px 6px; border-radius: 4px; font-weight: 600;">${escaparHTMLSeguro(tipo)}</span></td>
                                        <td style="max-width: 260px; line-height: 1.3;">${escaparHTMLSeguro(diag)}</td>
                                        <td style="font-weight: 600;">$${cto.toLocaleString('es-MX', { minimumFractionDigits: 2 })}</td>
                                        <td><span style="font-weight: 700; font-size: 11px;">${escaparHTMLSeguro(est)}</span></td>
                                    </tr>
                                `;
                            }).join("")}
                        </tbody>
                    </table>
                </div>
            </div>
        `;

        // Acción rápida de resolución si se abrió desde un ticket activo
        if (numServicio && numServicio !== 'undefined' && footerAcciones) {
            footerAcciones.innerHTML = `
                <div style="display: flex; align-items: center; gap: 8px;">
                    <span style="font-size: 12px; color: #475569; font-weight: 600;">Resolver Ticket #${escaparHTMLSeguro(numServicio)}:</span>
                    <select id="modal-sel-estado-cierre" style="padding: 6px 10px; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 12.5px;">
                        <option value="REPARADO">REPARADO</option>
                        <option value="RESUELTO">RESUELTO</option>
                        <option value="BAJA DEFINITIVA">BAJA DEFINITIVA</option>
                    </select>
                    <button type="button" onclick="cerrarTicketDesdeModal('${escaparHTMLSeguro(numServicio)}')" style="background: #16a34a; color: white; border: none; border-radius: 6px; padding: 7px 14px; font-weight: 600; cursor: pointer; font-size: 12.5px; display: inline-flex; align-items: center; gap: 4px;">
                        <i class="ph ph-check"></i> Rehabilitar Equipo
                    </button>
                </div>
            `;
        }

    } catch (err) {
        console.error("Error al cargar expediente:", err);
        contenido.innerHTML = `
            <div style="padding: 24px; text-align: center; color: #b91c1c;">
                <i class="ph ph-warning-circle" style="font-size: 32px; display: block; margin-bottom: 8px;"></i>
                <p style="font-weight: 600;">Error al cargar el expediente clínico:</p>
                <p style="font-size: 13px; color: #475569;">${err.message}</p>
            </div>
        `;
    }
}

async function cerrarTicketDesdeModal(numServicio) {
    const selEstado = document.getElementById("modal-sel-estado-cierre")?.value || "REPARADO";
    if (!confirm(`¿Confirmas rehabilitar el equipo y marcar el ticket #${numServicio} como ${selEstado}?`)) {
        return;
    }

    try {
        const res = await fetch(`${API_URL}/api/inventario/reparacion/cerrar/${encodeURIComponent(numServicio)}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ estado_actual: selEstado })
        });

        if (res.ok) {
            alert(`✅ Ticket #${numServicio} cerrado exitosamente como ${selEstado}.`);
            cerrarModalExpedienteDanado();
            cargarModuloDanados();
        } else {
            const err = await res.text();
            alert(`❌ Error al cerrar ticket: ${err}`);
        }
    } catch (e) {
        alert(`❌ Error de comunicación: ${e.message}`);
    }
}

