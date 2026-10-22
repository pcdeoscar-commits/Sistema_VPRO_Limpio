// ==============================================================================
// MÓDULO: incidencias.js
// 15. Incidencias operativas
// Líneas originales: 9061–10826 de script.js
// ==============================================================================

// ==========================================
// 15. MÓDULO DE INCIDENCIAS OPERATIVAS
// ==========================================

let rawEvaluacionesIncidencias = [];
let evaluacionesFiltradasIncidencias = [];
let evaluacionesComparativasIncidencias = [];
let modoComparativoIncidencias = false;
let modoPeriodoB = 'inmediato_anterior';
let tabBitacoraActual = 'A';

let chartIncBalanceInstance = null;
let chartIncEventosInstance = null;
let chartIncComparativaInstance = null;
let chartIncTendenciaInstance = null;
let modoTendenciaActivo = null;

async function cargarModuloIncidencias() {
    if (typeof esUsuarioAutorizadoDireccion === 'function' && !esUsuarioAutorizadoDireccion()) {
        console.warn("Intento de acceso no autorizado al módulo de incidencias.");
        const tbody = document.getElementById('tbody-incidencias-detallada');
        if (tbody) {
            tbody.innerHTML = `<tr><td colspan="6" style="text-align: center; padding: 30px; color: #dc2626; font-weight: 700;">⛔ Acceso denegado: Este módulo es confidencial y solo está disponible para Dirección (Villarreal / Agundez).</td></tr>`;
        }
        return;
    }

    try {
        const tbody = document.getElementById('tbody-incidencias-detallada');
        if (tbody) {
            tbody.innerHTML = `<tr><td colspan="6" style="text-align: center; padding: 30px; color: #64748b;"><i class="ph ph-spinner" style="font-size: 24px;"></i> Cargando evaluaciones de incidencias...</td></tr>`;
        }

        const nombreParam = encodeURIComponent(usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || '');
        const res = await fetch(`${API_URL}/api/incidencias/reporte?usuario=${nombreParam}`);
        if (!res.ok) {
            if (res.status === 403) {
                throw new Error("Acceso denegado por el servidor: No tienes permisos de Dirección.");
            }
            throw new Error("Error al obtener reporte de incidencias");
        }
        const dataJson = await res.json();

        // Procesar evaluaciones
        rawEvaluacionesIncidencias = [];
        dataJson.forEach(row => {
            const textoRaw = (row.incidencias_generales || "").trim();
            const empNombre = row.nombre_empleado || "Sin Nombre";
            const evento = row.nombre_evento || "Evento General";
            const fecha = row.fecha || "";
            const depto = (row.depto_real || "Sin Departamento").trim();

            let provNombre = null;
            let provNota = "";
            let empText = textoRaw;

            if (textoRaw.includes("[PROVEEDOR_INCIDENTE:")) {
                const sIdx = textoRaw.indexOf("[PROVEEDOR_INCIDENTE:");
                const eIdx = textoRaw.indexOf("]", sIdx);
                if (eIdx !== -1) {
                    const provRaw = textoRaw.substring(sIdx + 21, eIdx).trim();
                    if (provRaw.includes(" | NOTA: ")) {
                        const partes = provRaw.split(" | NOTA: ");
                        provNombre = partes[0].trim();
                        provNota = partes[1].trim();
                    } else {
                        provNombre = provRaw;
                        provNota = "Incidencia reportada (Sin detalles)";
                    }
                    empText = (textoRaw.substring(0, sIdx).trim() + " " + textoRaw.substring(eIdx + 1).trim()).trim();
                }
            }

            function clasificarTexto(texto) {
                if (!texto) return "✅ Sin Incidencias";
                const t = texto.toLowerCase().trim();
                if (t.startsWith("sin incidencia") || ["ninguna", "todo bien", "exito", "ok", "n/a", "none", "---", ""].includes(t)) {
                    return "✅ Sin Incidencias";
                }
                return "⚠️ Con Incidencias";
            }

            // 1. Empleado
            rawEvaluacionesIncidencias.push({
                Fecha: fecha,
                Evento: evento,
                Actor: empNombre,
                Tipo: "Empleado",
                Departamento: depto,
                Estatus: clasificarTexto(empText),
                Nota: empText.trim() ? empText.trim() : "Operación Limpia"
            });

            // 2. Proveedor si fue reportado
            if (provNombre && !provNombre.toUpperCase().includes("--- NINGUNO ---")) {
                rawEvaluacionesIncidencias.push({
                    Fecha: fecha,
                    Evento: evento,
                    Actor: provNombre,
                    Tipo: "Proveedor",
                    Departamento: "Externo (Proveedor)",
                    Estatus: "⚠️ Con Incidencias",
                    Nota: provNota.trim() ? provNota.trim() : "Falla de proveedor reportada"
                });
            }
        });

        // Configurar rango de fechas inicial: por defecto el mes más reciente con registros o rango completo
        const fechas = rawEvaluacionesIncidencias.map(e => e.Fecha).filter(Boolean).sort();
        if (fechas.length > 0) {
            const fMax = fechas[fechas.length - 1]; // ej. 2026-09-30
            const mesMax = fMax.substring(0, 7);    // ej. 2026-09
            const inputDesde = document.getElementById('filtro-inc-desde');
            const inputHasta = document.getElementById('filtro-inc-hasta');
            
            // Establecer el mes más reciente como periodo inicial
            if (inputDesde && !inputDesde.value) inputDesde.value = `${mesMax}-01`;
            if (inputHasta && !inputHasta.value) inputHasta.value = fMax;
        }

        // Poblar selectores de Periodos (Meses y Años)
        poblarSelectoresPeriodoIncidencias();

        // Poblar departamentos y actores
        poblarFiltroDepartamentosIncidencias();
        poblarFiltroActoresIncidencias();

        // Si el modo comparativo estaba activo, calcular periodo B
        if (modoComparativoIncidencias) {
            calcularFechasPeriodoB();
        }

        // Aplicar filtros y renderizar
        aplicarFiltrosIncidencias();

    } catch (e) {
        console.error("Error al cargar módulo de incidencias:", e);
        const tbody = document.getElementById('tbody-incidencias-detallada');
        if (tbody) tbody.innerHTML = `<tr><td colspan="6" style="text-align: center; color: #ef4444; padding: 20px;">Error al cargar las incidencias: ${e.message}</td></tr>`;
    }
}

// -------------------------------------------------------------
// SELECTORES DE PERIODO: MESES, AÑOS Y PREAJUSTES RÁPIDOS
// -------------------------------------------------------------
function poblarSelectoresPeriodoIncidencias() {
    const selMes = document.getElementById('sel-inc-mes');
    const selAno = document.getElementById('sel-inc-ano');
    if (!selMes || !selAno) return;

    const mesesNombres = [
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ];

    const mesesSet = new Set();
    const anosSet = new Set();

    rawEvaluacionesIncidencias.forEach(e => {
        if (e.Fecha && e.Fecha.length >= 7) {
            mesesSet.add(e.Fecha.substring(0, 7)); // YYYY-MM
            anosSet.add(e.Fecha.substring(0, 4));  // YYYY
        }
    });

    // Ordenar de más reciente a más antiguo
    const mesesOrdenados = Array.from(mesesSet).sort().reverse();
    const anosOrdenados = Array.from(anosSet).sort().reverse();

    // Poblar Meses
    selMes.innerHTML = '<option value="">-- Por Mes --</option>' + mesesOrdenados.map(m => {
        const [ano, mesNum] = m.split('-');
        const idx = parseInt(mesNum, 10) - 1;
        const nombre = (idx >= 0 && idx < 12) ? mesesNombres[idx] : mesNum;
        return `<option value="${m}">${nombre} ${ano}</option>`;
    }).join('');

    // Poblar Años
    selAno.innerHTML = '<option value="">-- Por Año --</option>' + anosOrdenados.map(a => {
        return `<option value="${a}">Año ${a}</option>`;
    }).join('');

    // Si las fechas actuales coinciden con algún mes exacto, seleccionarlo
    const fDesde = document.getElementById('filtro-inc-desde')?.value || "";
    const fHasta = document.getElementById('filtro-inc-hasta')?.value || "";
    if (fDesde && fHasta && fDesde.substring(0, 7) === fHasta.substring(0, 7)) {
        selMes.value = fDesde.substring(0, 7);
    }
}

function seleccionarMesIncidencias(mesStr) {
    if (!mesStr) return;
    const [anoStr, mesStrNum] = mesStr.split('-');
    const ano = parseInt(anoStr, 10);
    const mes = parseInt(mesStrNum, 10);
    const ultimoDia = new Date(ano, mes, 0).getDate();

    const fDesde = `${mesStr}-01`;
    const fHasta = `${mesStr}-${String(ultimoDia).padStart(2, '0')}`;

    const inputDesde = document.getElementById('filtro-inc-desde');
    const inputHasta = document.getElementById('filtro-inc-hasta');
    if (inputDesde) inputDesde.value = fDesde;
    if (inputHasta) inputHasta.value = fHasta;

    const selAno = document.getElementById('sel-inc-ano');
    if (selAno) selAno.value = "";

    modoTendenciaActivo = null;
    actualizarEstiloChipsTendencia();

    if (modoComparativoIncidencias) {
        calcularFechasPeriodoB();
    }
    aplicarFiltrosIncidencias();
}

function seleccionarAnoIncidencias(anoStr) {
    if (!anoStr) return;
    const fDesde = `${anoStr}-01-01`;
    const fHasta = `${anoStr}-12-31`;

    const inputDesde = document.getElementById('filtro-inc-desde');
    const inputHasta = document.getElementById('filtro-inc-hasta');
    if (inputDesde) inputDesde.value = fDesde;
    if (inputHasta) inputHasta.value = fHasta;

    const selMes = document.getElementById('sel-inc-mes');
    if (selMes) selMes.value = "";

    modoTendenciaActivo = null;
    actualizarEstiloChipsTendencia();

    if (modoComparativoIncidencias) {
        calcularFechasPeriodoB();
    }
    aplicarFiltrosIncidencias();
}

function alCambiarRangoManualIncidencias() {
    const selMes = document.getElementById('sel-inc-mes');
    const selAno = document.getElementById('sel-inc-ano');
    if (selMes) selMes.value = "";
    if (selAno) selAno.value = "";

    modoTendenciaActivo = null;
    actualizarEstiloChipsTendencia();

    if (modoComparativoIncidencias) {
        calcularFechasPeriodoB();
    }
    aplicarFiltrosIncidencias();
}

// -------------------------------------------------------------
// 📈 MÓDULO DE COMPARATIVAS Y TENDENCIAS TEMPORALES
// -------------------------------------------------------------
function activarComparativaTendencia(tipo, parametro) {
    modoTendenciaActivo = { tipo, parametro };
    actualizarEstiloChipsTendencia();

    const fechas = rawEvaluacionesIncidencias.map(e => e.Fecha).filter(Boolean).sort();
    const hoyStr = fechas.length > 0 ? fechas[fechas.length - 1] : new Date().toISOString().substring(0, 10);
    const dtHoy = new Date(hoyStr + 'T12:00:00');

    function formatoYMD(dt) {
        const y = dt.getFullYear();
        const m = String(dt.getMonth() + 1).padStart(2, '0');
        const d = String(dt.getDate()).padStart(2, '0');
        return `${y}-${m}-${d}`;
    }

    const inputDesde = document.getElementById('filtro-inc-desde');
    const inputHasta = document.getElementById('filtro-inc-hasta');
    const selMes = document.getElementById('sel-inc-mes');
    const selAno = document.getElementById('sel-inc-ano');

    if (tipo === 'semanas') {
        const numSem = parametro || 4;
        const diasTotal = (numSem * 7) - 1;
        const dtInicio = new Date(dtHoy.getTime() - diasTotal * 86400000);
        
        if (inputDesde) inputDesde.value = formatoYMD(dtInicio);
        if (inputHasta) inputHasta.value = formatoYMD(dtHoy);
        if (selMes) selMes.value = "";
        if (selAno) selAno.value = "";

        if (modoComparativoIncidencias) {
            toggleModoComparativoIncidencias();
        }

    } else if (tipo === 'meses_ano') {
        const ano = selAno && selAno.value ? selAno.value : String(dtHoy.getFullYear());
        if (inputDesde) inputDesde.value = `${ano}-01-01`;
        if (inputHasta) inputHasta.value = `${ano}-12-31`;
        if (selMes) selMes.value = "";
        if (selAno) selAno.value = ano;

        if (modoComparativoIncidencias) {
            toggleModoComparativoIncidencias();
        }

    } else if (tipo === 'mes_vs_anteriores') {
        let mesRef = selMes && selMes.value ? selMes.value : formatoYMD(dtHoy).substring(0, 7);
        const [anoStr, mesStr] = mesRef.split('-');
        const ano = parseInt(anoStr, 10);
        const mesNum = parseInt(mesStr, 10);
        const ultimoDia = new Date(ano, mesNum, 0).getDate();

        if (inputDesde) inputDesde.value = `${mesRef}-01`;
        if (inputHasta) inputHasta.value = `${mesRef}-${String(ultimoDia).padStart(2, '0')}`;
        if (selMes) selMes.value = mesRef;
        if (selAno) selAno.value = "";

        if (!modoComparativoIncidencias) {
            toggleModoComparativoIncidencias();
        }
        
        const inputDesdeB = document.getElementById('filtro-inc-comp-desde');
        const inputHastaB = document.getElementById('filtro-inc-comp-hasta');
        const selModoB = document.getElementById('sel-modo-comparativo-b');
        
        if (mesNum > 1) {
            const mesPrevioNum = mesNum - 1;
            const ultimoDiaPrevio = new Date(ano, mesPrevioNum, 0).getDate();
            if (inputDesdeB) inputDesdeB.value = `${anoStr}-01-01`;
            if (inputHastaB) inputHastaB.value = `${anoStr}-${String(mesPrevioNum).padStart(2, '0')}-${String(ultimoDiaPrevio).padStart(2, '0')}`;
        } else {
            if (inputDesdeB) inputDesdeB.value = `${ano - 1}-01-01`;
            if (inputHastaB) inputHastaB.value = `${ano - 1}-12-31`;
        }
        if (selModoB) selModoB.value = 'personalizado';
        modoPeriodoB = 'personalizado';

    } else if (tipo === 'anos_historico') {
        const anosSet = new Set();
        fechas.forEach(f => { if (f.length >= 4) anosSet.add(f.substring(0, 4)); });
        const anos = Array.from(anosSet).sort();
        const minAno = anos.length > 0 ? anos[0] : String(dtHoy.getFullYear() - 1);
        const maxAno = anos.length > 0 ? anos[anos.length - 1] : String(dtHoy.getFullYear());

        if (inputDesde) inputDesde.value = `${minAno}-01-01`;
        if (inputHasta) inputHasta.value = `${maxAno}-12-31`;
        if (selMes) selMes.value = "";
        if (selAno) selAno.value = "";

        if (modoComparativoIncidencias) {
            toggleModoComparativoIncidencias();
        }

    } else if (tipo === 'todo') {
        if (fechas.length > 0) {
            if (inputDesde) inputDesde.value = fechas[0];
            if (inputHasta) inputHasta.value = fechas[fechas.length - 1];
        }
        if (selMes) selMes.value = "";
        if (selAno) selAno.value = "";

        if (modoComparativoIncidencias) {
            toggleModoComparativoIncidencias();
        }
    }

    aplicarFiltrosIncidencias();
}

function actualizarEstiloChipsTendencia() {
    const ids = ['chip-sem-4', 'chip-sem-8', 'chip-sem-12', 'chip-meses-ano', 'chip-mes-vs-ant', 'chip-anos-hist', 'chip-todo'];
    ids.forEach(id => {
        const el = document.getElementById(id);
        if (el) el.classList.remove('active');
    });

    if (!modoTendenciaActivo) return;

    if (modoTendenciaActivo.tipo === 'semanas') {
        const chip = document.getElementById(`chip-sem-${modoTendenciaActivo.parametro}`);
        if (chip) chip.classList.add('active');
    } else if (modoTendenciaActivo.tipo === 'meses_ano') {
        document.getElementById('chip-meses-ano')?.classList.add('active');
    } else if (modoTendenciaActivo.tipo === 'mes_vs_anteriores') {
        document.getElementById('chip-mes-vs-ant')?.classList.add('active');
    } else if (modoTendenciaActivo.tipo === 'anos_historico') {
        document.getElementById('chip-anos-hist')?.classList.add('active');
    } else if (modoTendenciaActivo.tipo === 'todo') {
        document.getElementById('chip-todo')?.classList.add('active');
    }
}

function actualizarEstiloChipsPeriodo(val) {
    actualizarEstiloChipsTendencia();
}

// -------------------------------------------------------------
// ⚖️ MODO COMPARATIVO DE PERIODOS (EVALUACIÓN DE DESEMPEÑO)
// -------------------------------------------------------------
function toggleModoComparativoIncidencias() {
    modoComparativoIncidencias = !modoComparativoIncidencias;

    const panelComp = document.getElementById('panel-periodo-comparativo');
    const badgeStatus = document.getElementById('badge-comp-status');
    const btnToggle = document.getElementById('btn-toggle-comp-inc');
    const bannerDesemp = document.getElementById('banner-inc-desempeno');
    const cardComp = document.getElementById('card-grafica-comparativa');
    const tabsBit = document.getElementById('tabs-bitacora-comparativa');
    const lblModo = document.getElementById('lbl-graficas-modo');

    if (modoComparativoIncidencias) {
        if (panelComp) panelComp.style.display = 'block';
        if (badgeStatus) {
            badgeStatus.innerText = 'ACTIVO';
            badgeStatus.style.background = '#4338ca';
            badgeStatus.style.color = '#ffffff';
        }
        if (btnToggle) {
            btnToggle.style.background = '#eef2ff';
            btnToggle.style.borderColor = '#4338ca';
            btnToggle.style.color = '#312e81';
        }
        if (bannerDesemp) bannerDesemp.style.display = 'block';
        if (cardComp) cardComp.style.display = 'block';
        if (tabsBit) tabsBit.style.display = 'inline-flex';
        if (lblModo) {
            lblModo.innerText = 'Modo: Evaluación Comparativa de Desempeño (Periodo A vs Periodo B)';
            lblModo.style.background = '#c7d2fe';
            lblModo.style.color = '#312e81';
        }
        calcularFechasPeriodoB();
    } else {
        if (panelComp) panelComp.style.display = 'none';
        if (badgeStatus) {
            badgeStatus.innerText = 'OFF';
            badgeStatus.style.background = '#e0e7ff';
            badgeStatus.style.color = '#4338ca';
        }
        if (btnToggle) {
            btnToggle.style.background = 'white';
            btnToggle.style.borderColor = '#6366f1';
            btnToggle.style.color = '#4338ca';
        }
        if (bannerDesemp) bannerDesemp.style.display = 'none';
        if (cardComp) cardComp.style.display = 'none';
        if (tabsBit) tabsBit.style.display = 'none';
        if (lblModo) {
            lblModo.innerText = 'Modo: Vista Estándar';
            lblModo.style.background = '#e0e7ff';
            lblModo.style.color = '#6366f1';
        }
        tabBitacoraActual = 'A';
    }

    aplicarFiltrosIncidencias();
}

function calcularFechasPeriodoB() {
    const fDesdeA = document.getElementById('filtro-inc-desde')?.value || "";
    const fHastaA = document.getElementById('filtro-inc-hasta')?.value || "";
    const inputDesdeB = document.getElementById('filtro-inc-comp-desde');
    const inputHastaB = document.getElementById('filtro-inc-comp-hasta');
    const lblResumenA = document.getElementById('lbl-resumen-periodo-a');

    if (lblResumenA) {
        lblResumenA.innerText = `Periodo A (${fDesdeA || 'Inicio'} al ${fHastaA || 'Fin'})`;
    }

    if (!fDesdeA || !fHastaA || !inputDesdeB || !inputHastaB) return;
    if (modoPeriodoB === 'personalizado') return;

    function formatoYMD(dt) {
        const y = dt.getFullYear();
        const m = String(dt.getMonth() + 1).padStart(2, '0');
        const d = String(dt.getDate()).padStart(2, '0');
        return `${y}-${m}-${d}`;
    }

    const dtDesdeA = new Date(fDesdeA + 'T12:00:00');
    const dtHastaA = new Date(fHastaA + 'T12:00:00');

    if (modoPeriodoB === 'inmediato_anterior') {
        // Duración en días de Periodo A
        const duracionDias = Math.max(1, Math.round((dtHastaA - dtDesdeA) / 86400000) + 1);
        const dtHastaB = new Date(dtDesdeA.getTime() - 86400000); // 1 día antes del inicio de A
        const dtDesdeB = new Date(dtHastaB.getTime() - (duracionDias - 1) * 86400000);
        inputDesdeB.value = formatoYMD(dtDesdeB);
        inputHastaB.value = formatoYMD(dtHastaB);
    } else if (modoPeriodoB === 'mes_anterior') {
        const dtDesdeB = new Date(dtDesdeA);
        dtDesdeB.setMonth(dtDesdeB.getMonth() - 1);
        const dtHastaB = new Date(dtHastaA);
        dtHastaB.setMonth(dtHastaB.getMonth() - 1);
        inputDesdeB.value = formatoYMD(dtDesdeB);
        inputHastaB.value = formatoYMD(dtHastaB);
    } else if (modoPeriodoB === 'ano_anterior') {
        const dtDesdeB = new Date(dtDesdeA);
        dtDesdeB.setFullYear(dtDesdeB.getFullYear() - 1);
        const dtHastaB = new Date(dtHastaA);
        dtHastaB.setFullYear(dtHastaB.getFullYear() - 1);
        inputDesdeB.value = formatoYMD(dtDesdeB);
        inputHastaB.value = formatoYMD(dtHastaB);
    }
}

function alCambiarModoComparativoB(modo) {
    modoPeriodoB = modo;
    calcularFechasPeriodoB();
    aplicarFiltrosIncidencias();
}

function alCambiarFechasComparativoB() {
    modoPeriodoB = 'personalizado';
    const selModoB = document.getElementById('sel-modo-comparativo-b');
    if (selModoB) selModoB.value = 'personalizado';
    aplicarFiltrosIncidencias();
}

function poblarFiltroDepartamentosIncidencias() {
    const selDepto = document.getElementById('filtro-inc-depto');
    if (!selDepto) return;

    const deptos = new Set();
    rawEvaluacionesIncidencias.forEach(e => {
        if (e.Tipo === 'Empleado' && e.Departamento) deptos.add(e.Departamento);
    });

    const ordenados = Array.from(deptos).sort();
    selDepto.innerHTML = `<option value="Todos">Todos</option>` + ordenados.map(d => `<option value="${d}">${d}</option>`).join('');
}

function alCambiarDeptoIncidencias() {
    poblarFiltroActoresIncidencias();
    aplicarFiltrosIncidencias();
}

function poblarFiltroActoresIncidencias() {
    const selActor = document.getElementById('filtro-inc-actor');
    const selDepto = document.getElementById('filtro-inc-depto');
    if (!selActor) return;

    const deptoSel = selDepto?.value || "Todos";
    const valorActual = selActor.value;

    const emps = new Set();
    const provs = new Set();

    rawEvaluacionesIncidencias.forEach(e => {
        if (e.Tipo === 'Empleado') {
            if (deptoSel === "Todos" || e.Departamento === deptoSel) {
                emps.add(e.Actor);
            }
        } else if (e.Tipo === 'Proveedor') {
            provs.add(e.Actor);
        }
    });

    const empsList = Array.from(emps).sort();
    const provsList = Array.from(provs).sort();

    let html = `
        <option value="🌟 TODOS (Empleados y Proveedores)">🌟 TODOS (Empleados y Proveedores)</option>
        <option value="👥 TODOS LOS EMPLEADOS">👥 TODOS LOS EMPLEADOS</option>
        <option value="🚚 TODOS LOS PROVEEDORES">🚚 TODOS LOS PROVEEDORES</option>
    `;

    if (empsList.length > 0) {
        html += `<optgroup label="--- EMPLEADOS INDIVIDUALES ---">`;
        empsList.forEach(nom => {
            html += `<option value="${nom}">${nom}</option>`;
        });
        html += `</optgroup>`;
    }

    if (provsList.length > 0) {
        html += `<optgroup label="--- PROVEEDORES INDIVIDUALES ---">`;
        provsList.forEach(nom => {
            html += `<option value="${nom}">${nom}</option>`;
        });
        html += `</optgroup>`;
    }

    selActor.innerHTML = html;
    if ([...selActor.options].some(o => o.value === valorActual)) {
        selActor.value = valorActual;
    } else {
        selActor.selectedIndex = 0;
    }
}

function resetearFiltrosIncidencias() {
    const selMes = document.getElementById('sel-inc-mes');
    const selAno = document.getElementById('sel-inc-ano');
    if (selMes) selMes.value = "";
    if (selAno) selAno.value = "";

    const fechas = rawEvaluacionesIncidencias.map(e => e.Fecha).filter(Boolean).sort();
    if (fechas.length > 0) {
        const inputDesde = document.getElementById('filtro-inc-desde');
        const inputHasta = document.getElementById('filtro-inc-hasta');
        if (inputDesde) inputDesde.value = fechas[0];
        if (inputHasta) inputHasta.value = fechas[fechas.length - 1];
    }
    const selDepto = document.getElementById('filtro-inc-depto');
    if (selDepto) selDepto.value = "Todos";
    poblarFiltroActoresIncidencias();
    const selActor = document.getElementById('filtro-inc-actor');
    if (selActor) selActor.selectedIndex = 0;
    const buscar = document.getElementById('inc-buscar-tabla');
    if (buscar) buscar.value = "";

    modoTendenciaActivo = null;
    actualizarEstiloChipsTendencia();

    if (modoComparativoIncidencias) {
        calcularFechasPeriodoB();
    }
    aplicarFiltrosIncidencias();
}

// -------------------------------------------------------------
// FILTRADO Y MOTOR DE CÁLCULO
// -------------------------------------------------------------
function aplicarFiltrosIncidencias() {
    const fDesdeA = document.getElementById('filtro-inc-desde')?.value || "";
    const fHastaA = document.getElementById('filtro-inc-hasta')?.value || "";
    const depto = document.getElementById('filtro-inc-depto')?.value || "Todos";
    const actor = document.getElementById('filtro-inc-actor')?.value || "🌟 TODOS (Empleados y Proveedores)";

    // Filtrar Periodo A (Principal)
    evaluacionesFiltradasIncidencias = rawEvaluacionesIncidencias.filter(item => {
        if (fDesdeA && item.Fecha && item.Fecha < fDesdeA) return false;
        if (fHastaA && item.Fecha && item.Fecha > fHastaA) return false;

        if (depto !== "Todos") {
            if (item.Tipo === 'Empleado' && item.Departamento !== depto) return false;
        }

        if (actor === "👥 TODOS LOS EMPLEADOS") {
            if (item.Tipo !== 'Empleado') return false;
        } else if (actor === "🚚 TODOS LOS PROVEEDORES") {
            if (item.Tipo !== 'Proveedor') return false;
        } else if (actor !== "🌟 TODOS (Empleados y Proveedores)") {
            if (item.Actor !== actor) return false;
        }

        return true;
    });

    // Filtrar Periodo B (Comparativo) si está activo
    if (modoComparativoIncidencias) {
        const fDesdeB = document.getElementById('filtro-inc-comp-desde')?.value || "";
        const fHastaB = document.getElementById('filtro-inc-comp-hasta')?.value || "";

        evaluacionesComparativasIncidencias = rawEvaluacionesIncidencias.filter(item => {
            if (fDesdeB && item.Fecha && item.Fecha < fDesdeB) return false;
            if (fHastaB && item.Fecha && item.Fecha > fHastaB) return false;

            if (depto !== "Todos") {
                if (item.Tipo === 'Empleado' && item.Departamento !== depto) return false;
            }

            if (actor === "👥 TODOS LOS EMPLEADOS") {
                if (item.Tipo !== 'Empleado') return false;
            } else if (actor === "🚚 TODOS LOS PROVEEDORES") {
                if (item.Tipo !== 'Proveedor') return false;
            } else if (actor !== "🌟 TODOS (Empleados y Proveedores)") {
                if (item.Actor !== actor) return false;
            }

            return true;
        });
    } else {
        evaluacionesComparativasIncidencias = [];
    }

    actualizarKPIsIncidencias();
    renderizarBannerDesempeno();
    renderizarGraficasIncidencias();
    renderizarTablaIncidenciasSegunTab();
}

function actualizarKPIsIncidencias() {
    const totalA = evaluacionesFiltradasIncidencias.length;
    const limpiasA = evaluacionesFiltradasIncidencias.filter(e => e.Estatus.includes("Sin Incidencias")).length;
    const fallasA = totalA - limpiasA;
    const eventosA = new Set(evaluacionesFiltradasIncidencias.map(e => e.Evento)).size;

    const pctLimpiasA = totalA > 0 ? ((limpiasA / totalA) * 100) : 0;
    const pctFallasA = totalA > 0 ? ((fallasA / totalA) * 100) : 0;

    const elTotal = document.getElementById('kpi-inc-total');
    const elSubTotal = document.getElementById('kpi-inc-sub-total');
    const elLimpias = document.getElementById('kpi-inc-limpias');
    const elPctLimpias = document.getElementById('kpi-inc-pct-limpias');
    const elSubLimpias = document.getElementById('kpi-inc-sub-limpias');
    const elFallas = document.getElementById('kpi-inc-fallas');
    const elPctFallas = document.getElementById('kpi-inc-pct-fallas');
    const elSubFallas = document.getElementById('kpi-inc-sub-fallas');
    const elEventos = document.getElementById('kpi-inc-eventos');
    const elSubEventos = document.getElementById('kpi-inc-sub-eventos');

    function formatoYMD(dt) {
        const y = dt.getFullYear();
        const m = String(dt.getMonth() + 1).padStart(2, '0');
        const d = String(dt.getDate()).padStart(2, '0');
        return `${y}-${m}-${d}`;
    }

    if (!modoComparativoIncidencias) {
        // MODO ESTÁNDAR O TENDENCIA ACTIVA
        if (elTotal) elTotal.innerText = totalA;
        if (elLimpias) elLimpias.innerText = limpiasA;
        if (elFallas) elFallas.innerText = fallasA;
        if (elEventos) elEventos.innerText = eventosA;

        if (elPctLimpias) {
            elPctLimpias.innerText = `+${pctLimpiasA.toFixed(1)}%`;
            elPctLimpias.style.background = "#dcfce7";
            elPctLimpias.style.color = "#15803d";
        }

        if (elPctFallas) {
            elPctFallas.innerText = `-${pctFallasA.toFixed(1)}%`;
            elPctFallas.style.background = "#fee2e2";
            elPctFallas.style.color = "#b91c1c";
        }

        if (modoTendenciaActivo && modoTendenciaActivo.tipo === 'semanas') {
            const numSem = modoTendenciaActivo.parametro || 4;
            const fHastaStr = document.getElementById('filtro-inc-hasta')?.value;
            const dtFin = fHastaStr ? new Date(fHastaStr + 'T23:59:59') : new Date();
            const dtIniUltSem = new Date(dtFin.getTime() - 6 * 86400000);
            const ultSemStr = formatoYMD(dtIniUltSem);
            const evUltSem = evaluacionesFiltradasIncidencias.filter(e => e.Fecha && e.Fecha >= ultSemStr);
            const fallasUlt = evUltSem.filter(e => !e.Estatus.includes("Sin Incidencias")).length;
            const evPrev = evaluacionesFiltradasIncidencias.filter(e => e.Fecha && e.Fecha < ultSemStr);
            const fallasPrev = evPrev.filter(e => !e.Estatus.includes("Sin Incidencias")).length;
            const promFallasPrev = (numSem > 1) ? (fallasPrev / (numSem - 1)) : fallasUlt;

            if (elSubTotal) elSubTotal.innerText = `Total en últimas ${numSem} semanas`;
            if (elSubLimpias) elSubLimpias.innerText = `Sin incidencias acumuladas`;
            if (elSubFallas) elSubFallas.innerHTML = `Última sem: <strong>${fallasUlt} fallas</strong> (prom. prev. ${promFallasPrev.toFixed(1)})`;
            if (elSubEventos) elSubEventos.innerText = `Órdenes auditadas en las ${numSem} semanas`;

        } else if (modoTendenciaActivo && modoTendenciaActivo.tipo === 'meses_ano') {
            if (elSubTotal) elSubTotal.innerText = `Acumulado del año auditado`;
            if (elSubLimpias) elSubLimpias.innerText = `Calidad limpia anual`;
            if (elSubFallas) elSubFallas.innerText = `Incidencias registradas en el año`;
            if (elSubEventos) elSubEventos.innerText = `Órdenes de producción del año`;

        } else if (modoTendenciaActivo && modoTendenciaActivo.tipo === 'anos_historico') {
            if (elSubTotal) elSubTotal.innerText = `Total en histórico multi-anual`;
            if (elSubLimpias) elSubLimpias.innerText = `Operaciones limpias multi-año`;
            if (elSubFallas) elSubFallas.innerText = `Fallas multi-anuales registradas`;
            if (elSubEventos) elSubEventos.innerText = `Eventos totales en historial`;

        } else {
            if (elSubTotal) elSubTotal.innerText = "Total registros auditados";
            if (elSubLimpias) elSubLimpias.innerText = "Operación sin contratiempos";
            if (elSubFallas) elSubFallas.innerText = "Reportes de fallas o daños";
            if (elSubEventos) elSubEventos.innerText = "Órdenes de Producción con registro";
        }

    } else {
        // MODO COMPARATIVO (Periodo A vs Periodo B)
        const totalB = evaluacionesComparativasIncidencias.length;
        const limpiasB = evaluacionesComparativasIncidencias.filter(e => e.Estatus.includes("Sin Incidencias")).length;
        const fallasB = totalB - limpiasB;
        const eventosB = new Set(evaluacionesComparativasIncidencias.map(e => e.Evento)).size;

        const pctLimpiasB = totalB > 0 ? ((limpiasB / totalB) * 100) : 0;
        const pctFallasB = totalB > 0 ? ((fallasB / totalB) * 100) : 0;

        const deltaCalidad = pctLimpiasA - pctLimpiasB;
        const deltaTotal = totalA - totalB;
        const deltaEventos = eventosA - eventosB;

        if (elTotal) {
            elTotal.innerHTML = `
                <div style="display: flex; align-items: baseline; gap: 8px;">
                    <span>${totalA}</span>
                    <span style="font-size: 15px; font-weight: 600; color: #64748b;">vs ${totalB} (B)</span>
                </div>
            `;
        }
        if (elSubTotal) {
            const signo = deltaTotal >= 0 ? '+' : '';
            elSubTotal.innerHTML = `Variación: <strong>${signo}${deltaTotal} eval(s)</strong> respecto a Periodo B`;
        }

        if (elLimpias) elLimpias.innerText = `${limpiasA} (${pctLimpiasA.toFixed(1)}%)`;
        if (elPctLimpias) {
            const signoCal = deltaCalidad >= 0 ? '+' : '';
            const esMejora = deltaCalidad >= 0;
            elPctLimpias.innerText = `${signoCal}${deltaCalidad.toFixed(1)}% vs B`;
            elPctLimpias.style.background = esMejora ? "#dcfce7" : "#fee2e2";
            elPctLimpias.style.color = esMejora ? "#15803d" : "#b91c1c";
        }
        if (elSubLimpias) {
            elSubLimpias.innerHTML = `Periodo B: <strong>${limpiasB} limpias (${pctLimpiasB.toFixed(1)}%)</strong>`;
        }

        if (elFallas) elFallas.innerText = `${fallasA} (${pctFallasA.toFixed(1)}%)`;
        if (elPctFallas) {
            const deltaFallas = pctFallasA - pctFallasB;
            const signoFallas = deltaFallas >= 0 ? '+' : '';
            const esFallaMenor = deltaFallas <= 0;
            elPctFallas.innerText = `${signoFallas}${deltaFallas.toFixed(1)}% vs B`;
            elPctFallas.style.background = esFallaMenor ? "#dcfce7" : "#fee2e2";
            elPctFallas.style.color = esFallaMenor ? "#15803d" : "#b91c1c";
        }
        if (elSubFallas) {
            elSubFallas.innerHTML = `Periodo B: <strong>${fallasB} fallas (${pctFallasB.toFixed(1)}%)</strong>`;
        }

        if (elEventos) {
            elEventos.innerHTML = `
                <div style="display: flex; align-items: baseline; gap: 8px;">
                    <span>${eventosA}</span>
                    <span style="font-size: 15px; font-weight: 600; color: #64748b;">vs ${eventosB} (B)</span>
                </div>
            `;
        }
        if (elSubEventos) {
            const signoEv = deltaEventos >= 0 ? '+' : '';
            elSubEventos.innerHTML = `Variación: <strong>${signoEv}${deltaEventos} evento(s)</strong> OPs auditadas`;
        }
    }
}

function renderizarBannerDesempeno() {
    const banner = document.getElementById('banner-inc-desempeno');
    if (!banner) return;

    function formatoYMD(dt) {
        const y = dt.getFullYear();
        const m = String(dt.getMonth() + 1).padStart(2, '0');
        const d = String(dt.getDate()).padStart(2, '0');
        return `${y}-${m}-${d}`;
    }

    const mesesCortos = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];

    // 1. Caso Modo Comparativo A vs B
    if (modoComparativoIncidencias) {
        const totalA = evaluacionesFiltradasIncidencias.length;
        const totalB = evaluacionesComparativasIncidencias.length;
        const limpiasA = evaluacionesFiltradasIncidencias.filter(e => e.Estatus.includes("Sin Incidencias")).length;
        const limpiasB = evaluacionesComparativasIncidencias.filter(e => e.Estatus.includes("Sin Incidencias")).length;

        const pctLimpiasA = totalA > 0 ? (limpiasA / totalA) * 100 : 0;
        const pctLimpiasB = totalB > 0 ? (limpiasB / totalB) * 100 : 0;
        const deltaCalidad = pctLimpiasA - pctLimpiasB;

        const fDesdeA = document.getElementById('filtro-inc-desde')?.value || "";
        const fHastaA = document.getElementById('filtro-inc-hasta')?.value || "";
        const fDesdeB = document.getElementById('filtro-inc-comp-desde')?.value || "";
        const fHastaB = document.getElementById('filtro-inc-comp-hasta')?.value || "";

        banner.style.display = 'block';

        let config = {
            icono: 'ph-chart-line-up',
            colorIcono: '#16a34a',
            bg: '#f0fdf4',
            border: '1.5px solid #86efac',
            tituloColor: '#166534',
            titulo: `📈 ¡MEJORA EN EL DESEMPEÑO OPERATIVO! (+${deltaCalidad.toFixed(1)}% Calidad Limpia)`,
            detalle: `En el <strong>Periodo A (${fDesdeA} al ${fHastaA})</strong> la tasa de operaciones sin contratiempos alcanzó <strong>${pctLimpiasA.toFixed(1)}%</strong>, superando el <strong>${pctLimpiasB.toFixed(1)}%</strong> registrado en el <strong>Periodo B (${fDesdeB} al ${fHastaB})</strong>. La tasa de incidencias disminuyó <strong>${Math.abs(deltaCalidad).toFixed(1)} puntos porcentuales</strong>.`
        };

        if (deltaCalidad < -0.1) {
            config = {
                icono: 'ph-warning',
                colorIcono: '#dc2626',
                bg: '#fef2f2',
                border: '1.5px solid #fca5a5',
                tituloColor: '#991b1b',
                titulo: `⚠️ ALERTA DE DESEMPEÑO: Incremento en Tasa de Incidencias (${deltaCalidad.toFixed(1)}% Calidad)`,
                detalle: `En el <strong>Periodo A (${fDesdeA} al ${fHastaA})</strong> la proporción de fallas aumentó, registrándose <strong>${(100 - pctLimpiasA).toFixed(1)}%</strong> de incidencias contra <strong>${(100 - pctLimpiasB).toFixed(1)}%</strong> del <strong>Periodo B (${fDesdeB} al ${fHastaB})</strong>. Se recomienda auditar las órdenes de producción de este ciclo.`
            };
        } else if (Math.abs(deltaCalidad) <= 0.1) {
            config = {
                icono: 'ph-scales',
                colorIcono: '#2563eb',
                bg: '#eff6ff',
                border: '1.5px solid #93c5fd',
                tituloColor: '#1e40af',
                titulo: `⚖️ DESEMPEÑO CONSISTENTE: Calidad Estable entre Periodos (0.0% variación)`,
                detalle: `El desempeño operativo se mantuvo equilibrado entre el <strong>Periodo A</strong> (${pctLimpiasA.toFixed(1)}% limpias) y el <strong>Periodo B</strong> (${pctLimpiasB.toFixed(1)}% limpias).`
            };
        }

        banner.style.background = config.bg;
        banner.style.border = config.border;
        banner.innerHTML = `
            <div style="display: flex; gap: 16px; align-items: center; flex-wrap: wrap;">
                <div style="width: 48px; height: 48px; border-radius: 50%; background: white; display: flex; align-items: center; justify-content: center; box-shadow: 0 2px 6px rgba(0,0,0,0.08); flex-shrink: 0;">
                    <i class="ph ${config.icono}" style="font-size: 28px; color: ${config.colorIcono};"></i>
                </div>
                <div style="flex: 1; min-width: 250px;">
                    <div style="font-size: 15px; font-weight: 800; color: ${config.tituloColor}; margin-bottom: 4px;">
                        ${config.titulo}
                    </div>
                    <div style="font-size: 13px; color: #334155; line-height: 1.45;">
                        ${config.detalle}
                    </div>
                </div>
                <div style="display: flex; gap: 12px; align-items: center;">
                    <div style="background: white; padding: 8px 14px; border-radius: 8px; border: 1px solid rgba(0,0,0,0.06); text-align: center;">
                        <div style="font-size: 10px; font-weight: 700; color: #64748b; text-transform: uppercase;">Periodo A</div>
                        <div style="font-size: 15px; font-weight: 800; color: #4338ca;">${pctLimpiasA.toFixed(1)}% OK</div>
                    </div>
                    <div style="background: white; padding: 8px 14px; border-radius: 8px; border: 1px solid rgba(0,0,0,0.06); text-align: center;">
                        <div style="font-size: 10px; font-weight: 700; color: #64748b; text-transform: uppercase;">Periodo B</div>
                        <div style="font-size: 15px; font-weight: 800; color: #ea580c;">${pctLimpiasB.toFixed(1)}% OK</div>
                    </div>
                </div>
            </div>
        `;
        return;
    }

    // 2. Caso Modo Tendencia Semanal
    if (modoTendenciaActivo && modoTendenciaActivo.tipo === 'semanas') {
        const numSem = modoTendenciaActivo.parametro || 4;
        const fHastaStr = document.getElementById('filtro-inc-hasta')?.value;
        const dtFin = fHastaStr ? new Date(fHastaStr + 'T23:59:59') : new Date();

        const dtIniUltSem = new Date(dtFin.getTime() - 6 * 86400000);
        const ultSemStr = formatoYMD(dtIniUltSem);
        const evUltSem = evaluacionesFiltradasIncidencias.filter(e => e.Fecha && e.Fecha >= ultSemStr);
        const fallasUlt = evUltSem.filter(e => !e.Estatus.includes("Sin Incidencias")).length;
        const totalUlt = evUltSem.length;
        const tasaUlt = totalUlt > 0 ? (fallasUlt / totalUlt) * 100 : 0;

        const evPrev = evaluacionesFiltradasIncidencias.filter(e => e.Fecha && e.Fecha < ultSemStr);
        const fallasPrev = evPrev.filter(e => !e.Estatus.includes("Sin Incidencias")).length;
        const totalPrev = evPrev.length;
        const tasaPrev = totalPrev > 0 ? (fallasPrev / totalPrev) * 100 : 0;

        banner.style.display = 'block';

        const esMejora = tasaUlt <= tasaPrev;
        const diffTasa = Math.abs(tasaUlt - tasaPrev);

        let bg = esMejora ? '#f0fdf4' : '#fef2f2';
        let border = esMejora ? '1.5px solid #86efac' : '1.5px solid #fca5a5';
        let titColor = esMejora ? '#166534' : '#991b1b';
        let icono = esMejora ? 'ph-trend-down' : 'ph-trend-up';
        let colorIcono = esMejora ? '#16a34a' : '#dc2626';
        let titulo = esMejora
            ? `📉 TENDENCIA SEMANAL FAVORABLE: ${diffTasa.toFixed(1)}% menor incidencia en la última semana`
            : `⚠️ ALERTA SEMANAL: Incremento de ${diffTasa.toFixed(1)}% en tasa de fallas en la última semana`;

        let detalle = `En la semana más reciente se registraron <strong>${fallasUlt} incidencias de ${totalUlt} evaluaciones (${tasaUlt.toFixed(1)}% fallas)</strong>, frente a una tasa promedio de <strong>${tasaPrev.toFixed(1)}%</strong> en las semanas previas del ciclo analizado.`;

        banner.style.background = bg;
        banner.style.border = border;
        banner.innerHTML = `
            <div style="display: flex; gap: 16px; align-items: center; flex-wrap: wrap;">
                <div style="width: 48px; height: 48px; border-radius: 50%; background: white; display: flex; align-items: center; justify-content: center; box-shadow: 0 2px 6px rgba(0,0,0,0.08); flex-shrink: 0;">
                    <i class="ph ${icono}" style="font-size: 28px; color: ${colorIcono};"></i>
                </div>
                <div style="flex: 1; min-width: 250px;">
                    <div style="font-size: 15px; font-weight: 800; color: ${titColor}; margin-bottom: 4px;">
                        ${titulo}
                    </div>
                    <div style="font-size: 13px; color: #334155; line-height: 1.45;">
                        ${detalle}
                    </div>
                </div>
                <div style="display: flex; gap: 12px; align-items: center;">
                    <div style="background: white; padding: 8px 14px; border-radius: 8px; border: 1px solid rgba(0,0,0,0.06); text-align: center;">
                        <div style="font-size: 10px; font-weight: 700; color: #64748b; text-transform: uppercase;">Última Semana</div>
                        <div style="font-size: 15px; font-weight: 800; color: ${esMejora ? '#16a34a' : '#dc2626'};">${tasaUlt.toFixed(1)}% Fallas</div>
                    </div>
                    <div style="background: white; padding: 8px 14px; border-radius: 8px; border: 1px solid rgba(0,0,0,0.06); text-align: center;">
                        <div style="font-size: 10px; font-weight: 700; color: #64748b; text-transform: uppercase;">Semanas Previas</div>
                        <div style="font-size: 15px; font-weight: 800; color: #475569;">${tasaPrev.toFixed(1)}% Fallas</div>
                    </div>
                </div>
            </div>
        `;
        return;
    }

    // 3. Caso Modo Meses del Año
    if (modoTendenciaActivo && modoTendenciaActivo.tipo === 'meses_ano') {
        const fDesdeStr = document.getElementById('filtro-inc-desde')?.value || "";
        const anoRef = fDesdeStr ? fDesdeStr.substring(0, 4) : String(new Date().getFullYear());

        const mesesStats = [];
        for (let m = 1; m <= 12; m++) {
            const mesStr = `${anoRef}-${String(m).padStart(2, '0')}`;
            const ev = evaluacionesFiltradasIncidencias.filter(e => e.Fecha && e.Fecha.startsWith(mesStr));
            if (ev.length > 0) {
                const total = ev.length;
                const limpias = ev.filter(e => e.Estatus.includes("Sin Incidencias")).length;
                const fallas = total - limpias;
                const pctLimpia = (limpias / total) * 100;
                mesesStats.push({ mes: mesesCortos[m - 1], total, limpias, fallas, pctLimpia });
            }
        }

        if (mesesStats.length > 0) {
            mesesStats.sort((a, b) => b.pctLimpia - a.pctLimpia);
            const mejor = mesesStats[0];
            const peor = mesesStats[mesesStats.length - 1];

            banner.style.display = 'block';
            banner.style.background = '#eef2ff';
            banner.style.border = '1.5px solid #c7d2fe';
            banner.innerHTML = `
                <div style="display: flex; gap: 16px; align-items: center; flex-wrap: wrap;">
                    <div style="width: 48px; height: 48px; border-radius: 50%; background: white; display: flex; align-items: center; justify-content: center; box-shadow: 0 2px 6px rgba(0,0,0,0.08); flex-shrink: 0;">
                        <i class="ph ph-calendar-check" style="font-size: 28px; color: #4338ca;"></i>
                    </div>
                    <div style="flex: 1; min-width: 250px;">
                        <div style="font-size: 15px; font-weight: 800; color: #312e81; margin-bottom: 4px;">
                            🗓️ EVOLUCIÓN ANUAL MES A MES (${anoRef})
                        </div>
                        <div style="font-size: 13px; color: #334155; line-height: 1.45;">
                            El mes con mejor índice de calidad fue <strong>${mejor.mes}</strong> con <strong>${mejor.pctLimpia.toFixed(1)}%</strong> de operaciones limpias. La mayor concentración de incidencias se presentó en <strong>${peor.mes}</strong> (${peor.fallas} fallas).
                        </div>
                    </div>
                    <div style="display: flex; gap: 12px; align-items: center;">
                        <div style="background: white; padding: 8px 14px; border-radius: 8px; border: 1px solid rgba(0,0,0,0.06); text-align: center;">
                            <div style="font-size: 10px; font-weight: 700; color: #16a34a; text-transform: uppercase;">Mejor Mes: ${mejor.mes}</div>
                            <div style="font-size: 15px; font-weight: 800; color: #16a34a;">${mejor.pctLimpia.toFixed(1)}% OK</div>
                        </div>
                        <div style="background: white; padding: 8px 14px; border-radius: 8px; border: 1px solid rgba(0,0,0,0.06); text-align: center;">
                            <div style="font-size: 10px; font-weight: 700; color: #dc2626; text-transform: uppercase;">Mayor Falla: ${peor.mes}</div>
                            <div style="font-size: 15px; font-weight: 800; color: #dc2626;">${peor.fallas} Fallas</div>
                        </div>
                    </div>
                </div>
            `;
            return;
        }
    }

    // 4. Caso Modo Años Histórico
    if (modoTendenciaActivo && modoTendenciaActivo.tipo === 'anos_historico') {
        const anosSet = new Set();
        evaluacionesFiltradasIncidencias.forEach(e => {
            if (e.Fecha && e.Fecha.length >= 4) anosSet.add(e.Fecha.substring(0, 4));
        });
        const anos = Array.from(anosSet).sort();

        if (anos.length >= 2) {
            const anoActual = anos[anos.length - 1];
            const anoAnt = anos[anos.length - 2];

            const evAct = evaluacionesFiltradasIncidencias.filter(e => e.Fecha && e.Fecha.startsWith(anoActual));
            const evAnt = evaluacionesFiltradasIncidencias.filter(e => e.Fecha && e.Fecha.startsWith(anoAnt));

            const totalAct = evAct.length;
            const limpiasAct = evAct.filter(e => e.Estatus.includes("Sin Incidencias")).length;
            const pctAct = totalAct > 0 ? (limpiasAct / totalAct) * 100 : 0;

            const totalAnt = evAnt.length;
            const limpiasAnt = evAnt.filter(e => e.Estatus.includes("Sin Incidencias")).length;
            const pctAnt = totalAnt > 0 ? (limpiasAnt / totalAnt) * 100 : 0;

            const deltaYoY = pctAct - pctAnt;
            const esMejoraYoY = deltaYoY >= 0;

            banner.style.display = 'block';
            banner.style.background = esMejoraYoY ? '#f0fdf4' : '#fef2f2';
            banner.style.border = esMejoraYoY ? '1.5px solid #86efac' : '1.5px solid #fca5a5';
            banner.innerHTML = `
                <div style="display: flex; gap: 16px; align-items: center; flex-wrap: wrap;">
                    <div style="width: 48px; height: 48px; border-radius: 50%; background: white; display: flex; align-items: center; justify-content: center; box-shadow: 0 2px 6px rgba(0,0,0,0.08); flex-shrink: 0;">
                        <i class="ph ph-chart-line-up" style="font-size: 28px; color: ${esMejoraYoY ? '#16a34a' : '#dc2626'};"></i>
                    </div>
                    <div style="flex: 1; min-width: 250px;">
                        <div style="font-size: 15px; font-weight: 800; color: ${esMejoraYoY ? '#166534' : '#991b1b'}; margin-bottom: 4px;">
                            📆 COMPARATIVA INTERANUAL (${anoActual} vs ${anoAnt})
                        </div>
                        <div style="font-size: 13px; color: #334155; line-height: 1.45;">
                            En el año <strong>${anoActual}</strong> la tasa de operaciones limpias es de <strong>${pctAct.toFixed(1)}%</strong> (${totalAct} registros), comparado con el <strong>${pctAnt.toFixed(1)}%</strong> registrado en el año <strong>${anoAnt}</strong> (${totalAnt} registros). Variación interanual: <strong>${deltaYoY >= 0 ? '+' : ''}${deltaYoY.toFixed(1)}%</strong>.
                        </div>
                    </div>
                    <div style="display: flex; gap: 12px; align-items: center;">
                        <div style="background: white; padding: 8px 14px; border-radius: 8px; border: 1px solid rgba(0,0,0,0.06); text-align: center;">
                            <div style="font-size: 10px; font-weight: 700; color: #4338ca; text-transform: uppercase;">Año ${anoActual}</div>
                            <div style="font-size: 15px; font-weight: 800; color: #4338ca;">${pctAct.toFixed(1)}% OK</div>
                        </div>
                        <div style="background: white; padding: 8px 14px; border-radius: 8px; border: 1px solid rgba(0,0,0,0.06); text-align: center;">
                            <div style="font-size: 10px; font-weight: 700; color: #64748b; text-transform: uppercase;">Año ${anoAnt}</div>
                            <div style="font-size: 15px; font-weight: 800; color: #64748b;">${pctAnt.toFixed(1)}% OK</div>
                        </div>
                    </div>
                </div>
            `;
            return;
        }
    }

    banner.style.display = 'none';
}

// -------------------------------------------------------------
// RENDERIZADO DE GRÁFICAS DE CALIDAD Y DESEMPEÑO
// -------------------------------------------------------------
function renderizarGraficasIncidencias() {
    if (typeof Chart === 'undefined') return;

    function formatoYMD(dt) {
        const y = dt.getFullYear();
        const m = String(dt.getMonth() + 1).padStart(2, '0');
        const d = String(dt.getDate()).padStart(2, '0');
        return `${y}-${m}-${d}`;
    }

    const mesesCortos = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];

    const totalA = evaluacionesFiltradasIncidencias.length;
    const limpiasA = evaluacionesFiltradasIncidencias.filter(e => e.Estatus.includes("Sin Incidencias")).length;
    const fallasA = totalA - limpiasA;
    const pctLimpiasA = totalA > 0 ? ((limpiasA / totalA) * 100) : 0;
    const pctFallasA = totalA > 0 ? ((fallasA / totalA) * 100) : 0;

    const lblModo = document.getElementById('lbl-graficas-modo');
    if (lblModo) {
        if (modoComparativoIncidencias) {
            lblModo.innerText = 'Modo: Evaluación Comparativa de Desempeño (Periodo A vs Periodo B)';
            lblModo.style.background = '#c7d2fe';
            lblModo.style.color = '#312e81';
        } else if (modoTendenciaActivo && modoTendenciaActivo.tipo === 'semanas') {
            lblModo.innerText = `Modo: Tendencia por Semanas (Últimas ${modoTendenciaActivo.parametro || 4} Semanas)`;
            lblModo.style.background = '#e0e7ff';
            lblModo.style.color = '#4338ca';
        } else if (modoTendenciaActivo && modoTendenciaActivo.tipo === 'meses_ano') {
            lblModo.innerText = 'Modo: Evolución Mes a Mes del Año';
            lblModo.style.background = '#e0e7ff';
            lblModo.style.color = '#4338ca';
        } else if (modoTendenciaActivo && modoTendenciaActivo.tipo === 'anos_historico') {
            lblModo.innerText = 'Modo: Comparativa Interanual Histórica';
            lblModo.style.background = '#e0e7ff';
            lblModo.style.color = '#4338ca';
        } else if (modoTendenciaActivo && modoTendenciaActivo.tipo === 'todo') {
            lblModo.innerText = 'Modo: Historial Completo';
            lblModo.style.background = '#e0e7ff';
            lblModo.style.color = '#4338ca';
        } else {
            lblModo.innerText = 'Modo: Vista Estándar';
            lblModo.style.background = '#e0e7ff';
            lblModo.style.color = '#6366f1';
        }
    }

    // 0️⃣ Gráfica Especial: Tendencia y Comparativa Temporal (Semanas / Meses / Años)
    const cardTendencia = document.getElementById('card-grafica-tendencia');
    const ctxTendencia = document.getElementById('chart-inc-tendencia')?.getContext('2d');
    const titTendencia = document.getElementById('titulo-grafica-tendencia');
    const subTendencia = document.getElementById('subtitulo-grafica-tendencia');

    if (modoTendenciaActivo && ['semanas', 'meses_ano', 'anos_historico', 'mes_vs_anteriores'].includes(modoTendenciaActivo.tipo) && ctxTendencia) {
        if (cardTendencia) cardTendencia.style.display = 'block';
        if (chartIncTendenciaInstance) chartIncTendenciaInstance.destroy();

        if (modoTendenciaActivo.tipo === 'semanas') {
            const numSem = modoTendenciaActivo.parametro || 4;
            if (titTendencia) titTendencia.innerHTML = `<i class="ph ph-trend-up" style="color: #4f46e5; font-size: 18px;"></i> Tendencia Semanal: Desempeño en las Últimas ${numSem} Semanas`;
            if (subTendencia) subTendencia.innerText = `Evolución Semana a Semana`;

            const fHastaStr = document.getElementById('filtro-inc-hasta')?.value;
            const dtFin = fHastaStr ? new Date(fHastaStr + 'T23:59:59') : new Date();

            const semanasData = [];
            for (let i = numSem - 1; i >= 0; i--) {
                const dtFinSem = new Date(dtFin.getTime() - i * 7 * 86400000);
                const dtIniSem = new Date(dtFinSem.getTime() - 6 * 86400000);
                const iniStr = formatoYMD(dtIniSem);
                const finStr = formatoYMD(dtFinSem);

                const evSem = evaluacionesFiltradasIncidencias.filter(e => e.Fecha && e.Fecha >= iniStr && e.Fecha <= finStr);
                const total = evSem.length;
                const limpias = evSem.filter(e => e.Estatus.includes("Sin Incidencias")).length;
                const fallas = total - limpias;
                const tasaFallas = total > 0 ? (fallas / total) * 100 : 0;
                const etiqueta = `Sem ${numSem - i} (${dtIniSem.getDate()} ${mesesCortos[dtIniSem.getMonth()]} - ${dtFinSem.getDate()} ${mesesCortos[dtFinSem.getMonth()]})`;

                semanasData.push({ etiqueta, total, limpias, fallas, tasaFallas });
            }

            chartIncTendenciaInstance = new Chart(ctxTendencia, {
                type: 'bar',
                data: {
                    labels: semanasData.map(s => s.etiqueta),
                    datasets: [
                        {
                            label: 'Operación Limpia',
                            data: semanasData.map(s => s.limpias),
                            backgroundColor: '#16a34a',
                            borderRadius: 6,
                            yAxisID: 'y'
                        },
                        {
                            label: 'Con Incidencias',
                            data: semanasData.map(s => s.fallas),
                            backgroundColor: '#ef4444',
                            borderRadius: 6,
                            yAxisID: 'y'
                        },
                        {
                            type: 'line',
                            label: '% Tasa Incidencias',
                            data: semanasData.map(s => s.tasaFallas),
                            borderColor: '#b91c1c',
                            backgroundColor: '#b91c1c',
                            borderWidth: 2.5,
                            pointRadius: 4,
                            yAxisID: 'y1'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        x: { ticks: { font: { weight: 'bold', size: 11.5 } } },
                        y: {
                            beginAtZero: true,
                            ticks: { stepSize: 1 },
                            title: { display: true, text: 'Núm. de Evaluaciones', font: { size: 11 } }
                        },
                        y1: {
                            beginAtZero: true,
                            max: 100,
                            position: 'right',
                            grid: { drawOnChartArea: false },
                            ticks: { callback: v => `${v}%` },
                            title: { display: true, text: '% Incidencias', font: { size: 11 } }
                        }
                    },
                    plugins: {
                        legend: {
                            display: true,
                            position: 'top',
                            labels: { font: { size: 11, weight: 'bold' }, boxWidth: 12 }
                        },
                        tooltip: {
                            callbacks: {
                                label: (ctx) => {
                                    if (ctx.dataset.type === 'line') return `${ctx.dataset.label}: ${ctx.raw.toFixed(1)}%`;
                                    return `${ctx.dataset.label}: ${ctx.raw} eval(s)`;
                                }
                            }
                        }
                    }
                }
            });

        } else if (modoTendenciaActivo.tipo === 'meses_ano' || modoTendenciaActivo.tipo === 'mes_vs_anteriores') {
            const fDesdeStr = document.getElementById('filtro-inc-desde')?.value || "";
            const anoRef = fDesdeStr ? fDesdeStr.substring(0, 4) : String(new Date().getFullYear());

            if (titTendencia) titTendencia.innerHTML = `<i class="ph ph-calendar-blank" style="color: #4f46e5; font-size: 18px;"></i> Evolución Mes a Mes del Año ${anoRef}`;
            if (subTendencia) subTendencia.innerText = `Comparativa Intermensual`;

            const mesesData = [];
            for (let m = 1; m <= 12; m++) {
                const mesStr = `${anoRef}-${String(m).padStart(2, '0')}`;
                const evMes = rawEvaluacionesIncidencias.filter(e => {
                    if (!e.Fecha || !e.Fecha.startsWith(mesStr)) return false;
                    const depto = document.getElementById('filtro-inc-depto')?.value || "Todos";
                    const actor = document.getElementById('filtro-inc-actor')?.value || "🌟 TODOS (Empleados y Proveedores)";
                    if (depto !== "Todos" && e.Tipo === 'Empleado' && e.Departamento !== depto) return false;
                    if (actor === "👥 TODOS LOS EMPLEADOS" && e.Tipo !== 'Empleado') return false;
                    if (actor === "🚚 TODOS LOS PROVEEDORES" && e.Tipo !== 'Proveedor') return false;
                    if (!actor.startsWith("🌟") && !actor.startsWith("👥") && !actor.startsWith("🚚") && e.Actor !== actor) return false;
                    return true;
                });

                const total = evMes.length;
                const limpias = evMes.filter(e => e.Estatus.includes("Sin Incidencias")).length;
                const fallas = total - limpias;
                const tasaFallas = total > 0 ? (fallas / total) * 100 : 0;
                mesesData.push({ mes: mesesCortos[m - 1], total, limpias, fallas, tasaFallas });
            }

            let ultimoConRegistros = -1;
            for (let i = mesesData.length - 1; i >= 0; i--) {
                if (mesesData[i].total > 0) {
                    ultimoConRegistros = i;
                    break;
                }
            }
            const mesesMostrar = ultimoConRegistros >= 0 ? mesesData.slice(0, ultimoConRegistros + 1) : mesesData;

            chartIncTendenciaInstance = new Chart(ctxTendencia, {
                type: 'bar',
                data: {
                    labels: mesesMostrar.map(m => m.mes),
                    datasets: [
                        {
                            label: 'Operación Limpia',
                            data: mesesMostrar.map(m => m.limpias),
                            backgroundColor: '#16a34a',
                            borderRadius: 6,
                            yAxisID: 'y'
                        },
                        {
                            label: 'Con Incidencias',
                            data: mesesMostrar.map(m => m.fallas),
                            backgroundColor: '#ef4444',
                            borderRadius: 6,
                            yAxisID: 'y'
                        },
                        {
                            type: 'line',
                            label: '% Tasa Incidencias',
                            data: mesesMostrar.map(m => m.tasaFallas),
                            borderColor: '#dc2626',
                            backgroundColor: '#dc2626',
                            borderWidth: 2.5,
                            pointRadius: 4,
                            yAxisID: 'y1'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        x: { ticks: { font: { weight: 'bold', size: 11.5 } } },
                        y: {
                            beginAtZero: true,
                            ticks: { stepSize: 1 },
                            title: { display: true, text: 'Núm. de Evaluaciones', font: { size: 11 } }
                        },
                        y1: {
                            beginAtZero: true,
                            max: 100,
                            position: 'right',
                            grid: { drawOnChartArea: false },
                            ticks: { callback: v => `${v}%` },
                            title: { display: true, text: '% Incidencias', font: { size: 11 } }
                        }
                    },
                    plugins: {
                        legend: {
                            display: true,
                            position: 'top',
                            labels: { font: { size: 11, weight: 'bold' }, boxWidth: 12 }
                        },
                        tooltip: {
                            callbacks: {
                                label: (ctx) => {
                                    if (ctx.dataset.type === 'line') return `${ctx.dataset.label}: ${ctx.raw.toFixed(1)}%`;
                                    return `${ctx.dataset.label}: ${ctx.raw} eval(s)`;
                                }
                            }
                        }
                    }
                }
            });

        } else if (modoTendenciaActivo.tipo === 'anos_historico') {
            if (titTendencia) titTendencia.innerHTML = `<i class="ph ph-calendar-check" style="color: #4f46e5; font-size: 18px;"></i> Comparativa Interanual (Evolución por Años)`;
            if (subTendencia) subTendencia.innerText = `Comparativa Anual`;

            const anosSet = new Set();
            rawEvaluacionesIncidencias.forEach(e => {
                if (e.Fecha && e.Fecha.length >= 4) anosSet.add(e.Fecha.substring(0, 4));
            });
            const anosLista = Array.from(anosSet).sort();

            const anosData = anosLista.map(anoStr => {
                const evAno = rawEvaluacionesIncidencias.filter(e => {
                    if (!e.Fecha || !e.Fecha.startsWith(anoStr)) return false;
                    const depto = document.getElementById('filtro-inc-depto')?.value || "Todos";
                    const actor = document.getElementById('filtro-inc-actor')?.value || "🌟 TODOS (Empleados y Proveedores)";
                    if (depto !== "Todos" && e.Tipo === 'Empleado' && e.Departamento !== depto) return false;
                    if (actor === "👥 TODOS LOS EMPLEADOS" && e.Tipo !== 'Empleado') return false;
                    if (actor === "🚚 TODOS LOS PROVEEDORES" && e.Tipo !== 'Proveedor') return false;
                    if (!actor.startsWith("🌟") && !actor.startsWith("👥") && !actor.startsWith("🚚") && e.Actor !== actor) return false;
                    return true;
                });
                const total = evAno.length;
                const limpias = evAno.filter(e => e.Estatus.includes("Sin Incidencias")).length;
                const fallas = total - limpias;
                const tasaFallas = total > 0 ? (fallas / total) * 100 : 0;
                return { anoStr, total, limpias, fallas, tasaFallas };
            });

            chartIncTendenciaInstance = new Chart(ctxTendencia, {
                type: 'bar',
                data: {
                    labels: anosData.map(a => `Año ${a.anoStr}`),
                    datasets: [
                        {
                            label: 'Operación Limpia',
                            data: anosData.map(a => a.limpias),
                            backgroundColor: '#16a34a',
                            borderRadius: 6,
                            yAxisID: 'y'
                        },
                        {
                            label: 'Con Incidencias',
                            data: anosData.map(a => a.fallas),
                            backgroundColor: '#ef4444',
                            borderRadius: 6,
                            yAxisID: 'y'
                        },
                        {
                            type: 'line',
                            label: '% Tasa Incidencias',
                            data: anosData.map(a => a.tasaFallas),
                            borderColor: '#dc2626',
                            backgroundColor: '#dc2626',
                            borderWidth: 2.5,
                            pointRadius: 5,
                            yAxisID: 'y1'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        x: { ticks: { font: { weight: 'bold', size: 12 } } },
                        y: {
                            beginAtZero: true,
                            ticks: { stepSize: 1 },
                            title: { display: true, text: 'Núm. de Evaluaciones', font: { size: 11 } }
                        },
                        y1: {
                            beginAtZero: true,
                            max: 100,
                            position: 'right',
                            grid: { drawOnChartArea: false },
                            ticks: { callback: v => `${v}%` },
                            title: { display: true, text: '% Incidencias', font: { size: 11 } }
                        }
                    },
                    plugins: {
                        legend: {
                            display: true,
                            position: 'top',
                            labels: { font: { size: 11, weight: 'bold' }, boxWidth: 12 }
                        },
                        tooltip: {
                            callbacks: {
                                label: (ctx) => {
                                    if (ctx.dataset.type === 'line') return `${ctx.dataset.label}: ${ctx.raw.toFixed(1)}%`;
                                    return `${ctx.dataset.label}: ${ctx.raw} eval(s)`;
                                }
                            }
                        }
                    }
                }
            });
        }
    } else {
        if (cardTendencia) cardTendencia.style.display = 'none';
        if (chartIncTendenciaInstance) {
            chartIncTendenciaInstance.destroy();
            chartIncTendenciaInstance = null;
        }
    }

    const ctxBalance = document.getElementById('chart-inc-balance')?.getContext('2d');
    const contBalance = document.getElementById('contenedor-canvas-balance');
    const titBalance = document.getElementById('titulo-grafica-balance');

    // 1️⃣ Gráfica 1: Balance General (Apilada 100%) - Si comparativo: 2 barras apiladas
    if (ctxBalance) {
        if (chartIncBalanceInstance) chartIncBalanceInstance.destroy();

        if (!modoComparativoIncidencias) {
            if (contBalance) contBalance.style.height = "60px";
            if (titBalance) titBalance.innerText = "Balance General de Calidad (%)";

            chartIncBalanceInstance = new Chart(ctxBalance, {
                type: 'bar',
                data: {
                    labels: ['Balance General'],
                    datasets: [
                        {
                            label: 'Sin Incidencias',
                            data: [pctLimpiasA],
                            backgroundColor: '#16a34a',
                            borderRadius: 6
                        },
                        {
                            label: 'Con Incidencias',
                            data: [pctFallasA],
                            backgroundColor: '#ef4444',
                            borderRadius: 6
                        }
                    ]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        x: {
                            stacked: true,
                            max: 100,
                            ticks: { callback: v => `${v}%` }
                        },
                        y: { stacked: true, display: false }
                    },
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                label: (ctx) => `${ctx.dataset.label}: ${ctx.raw.toFixed(1)}%`
                            }
                        }
                    }
                }
            });
        } else {
            if (contBalance) contBalance.style.height = "105px";
            if (titBalance) titBalance.innerText = "⚖️ Balance Comparativo de Calidad (%) - Periodo A vs Periodo B";

            const totalB = evaluacionesComparativasIncidencias.length;
            const limpiasB = evaluacionesComparativasIncidencias.filter(e => e.Estatus.includes("Sin Incidencias")).length;
            const fallasB = totalB - limpiasB;
            const pctLimpiasB = totalB > 0 ? ((limpiasB / totalB) * 100) : 0;
            const pctFallasB = totalB > 0 ? ((fallasB / totalB) * 100) : 0;

            chartIncBalanceInstance = new Chart(ctxBalance, {
                type: 'bar',
                data: {
                    labels: ['Periodo A (Actual)', 'Periodo B (Comparativo)'],
                    datasets: [
                        {
                            label: 'Sin Incidencias',
                            data: [pctLimpiasA, pctLimpiasB],
                            backgroundColor: '#16a34a',
                            borderRadius: 6
                        },
                        {
                            label: 'Con Incidencias',
                            data: [pctFallasA, pctFallasB],
                            backgroundColor: '#ef4444',
                            borderRadius: 6
                        }
                    ]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        x: {
                            stacked: true,
                            max: 100,
                            ticks: { callback: v => `${v}%` }
                        },
                        y: {
                            stacked: true,
                            ticks: { font: { weight: 'bold', size: 11.5 } }
                        }
                    },
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                label: (ctx) => `${ctx.dataset.label}: ${ctx.raw.toFixed(1)}%`
                            }
                        }
                    }
                }
            });
        }
    }

    // 2️⃣ Gráfica 2: Comparativa de Desempeño Operativo (Solo en Modo Comparativo)
    const ctxComp = document.getElementById('chart-inc-comparativa')?.getContext('2d');
    if (ctxComp && modoComparativoIncidencias) {
        if (chartIncComparativaInstance) chartIncComparativaInstance.destroy();

        const totalB = evaluacionesComparativasIncidencias.length;
        const limpiasB = evaluacionesComparativasIncidencias.filter(e => e.Estatus.includes("Sin Incidencias")).length;
        const fallasB = totalB - limpiasB;
        const eventosA = new Set(evaluacionesFiltradasIncidencias.map(e => e.Evento)).size;
        const eventosB = new Set(evaluacionesComparativasIncidencias.map(e => e.Evento)).size;

        chartIncComparativaInstance = new Chart(ctxComp, {
            type: 'bar',
            data: {
                labels: ['Total Evaluaciones', 'Operación Limpia', 'Con Incidencias', 'Eventos Auditados'],
                datasets: [
                    {
                        label: 'Periodo A (Actual)',
                        data: [totalA, limpiasA, fallasA, eventosA],
                        backgroundColor: '#4f46e5',
                        borderRadius: 6
                    },
                    {
                        label: 'Periodo B (Comparativo)',
                        data: [totalB, limpiasB, fallasB, eventosB],
                        backgroundColor: '#f97316',
                        borderRadius: 6
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        ticks: { font: { weight: 'bold', size: 11.5 } }
                    },
                    y: {
                        beginAtZero: true,
                        ticks: { stepSize: 1 }
                    }
                },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: (ctx) => `${ctx.dataset.label}: ${ctx.raw} registros`
                        }
                    }
                }
            }
        });
    }

    // 3️⃣ Gráfica 3: Detalle por Evento (Periodo A)
    const ctxEventos = document.getElementById('chart-inc-eventos')?.getContext('2d');
    if (ctxEventos) {
        if (chartIncEventosInstance) chartIncEventosInstance.destroy();

        const eventosMap = {};
        evaluacionesFiltradasIncidencias.forEach(e => {
            const ev = e.Evento || 'Sin Nombre';
            if (!eventosMap[ev]) eventosMap[ev] = { limpias: 0, fallas: 0 };
            if (e.Estatus.includes("Sin Incidencias")) eventosMap[ev].limpias++;
            else eventosMap[ev].fallas++;
        });

        const labels = Object.keys(eventosMap);
        const dataLimpias = labels.map(k => eventosMap[k].limpias);
        const dataFallas = labels.map(k => eventosMap[k].fallas);

        chartIncEventosInstance = new Chart(ctxEventos, {
            type: 'bar',
            data: {
                labels: labels.map(l => l.length > 28 ? l.substring(0, 26) + '...' : l),
                datasets: [
                    {
                        label: 'Sin Incidencias',
                        data: dataLimpias,
                        backgroundColor: '#16a34a',
                        borderRadius: 4
                    },
                    {
                        label: 'Con Incidencias',
                        data: dataFallas,
                        backgroundColor: '#ef4444',
                        borderRadius: 4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        ticks: {
                            autoSkip: false,
                            maxRotation: 45,
                            minRotation: 35,
                            font: { size: 10.5 }
                        }
                    },
                    y: {
                        beginAtZero: true,
                        ticks: { stepSize: 1 }
                    }
                },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            title: (items) => labels[items[0].dataIndex] || ''
                        }
                    }
                }
            }
        });
    }
}

// -------------------------------------------------------------
// BITÁCORA Y TABS DE PERIODOS
// -------------------------------------------------------------
function cambiarTabBitacora(tab) {
    tabBitacoraActual = tab;
    const tabA = document.getElementById('tab-bit-a');
    const tabB = document.getElementById('tab-bit-b');
    const tabAmbos = document.getElementById('tab-bit-ambos');

    [tabA, tabB, tabAmbos].forEach(t => t?.classList.remove('active'));
    if (tab === 'A') tabA?.classList.add('active');
    else if (tab === 'B') tabB?.classList.add('active');
    else if (tab === 'AMBOS') tabAmbos?.classList.add('active');

    renderizarTablaIncidenciasSegunTab();
}

function renderizarTablaIncidenciasSegunTab() {
    let lista = [];
    if (!modoComparativoIncidencias || tabBitacoraActual === 'A') {
        lista = evaluacionesFiltradasIncidencias.map(item => ({ ...item, _periodo: 'A' }));
    } else if (tabBitacoraActual === 'B') {
        lista = evaluacionesComparativasIncidencias.map(item => ({ ...item, _periodo: 'B' }));
    } else if (tabBitacoraActual === 'AMBOS') {
        const itemsA = evaluacionesFiltradasIncidencias.map(item => ({ ...item, _periodo: 'A' }));
        const itemsB = evaluacionesComparativasIncidencias.map(item => ({ ...item, _periodo: 'B' }));
        lista = [...itemsA, ...itemsB].sort((a, b) => (b.Fecha || '').localeCompare(a.Fecha || ''));
    }

    renderizarTablaIncidencias(lista);
}

function renderizarTablaIncidencias(lista) {
    const tbody = document.getElementById('tbody-incidencias-detallada');
    const badgeConteo = document.getElementById('inc-tabla-conteo');
    if (badgeConteo) badgeConteo.innerText = lista.length;

    if (!tbody) return;
    if (lista.length === 0) {
        tbody.innerHTML = `<tr><td colspan="6" style="text-align: center; padding: 30px; color: #16a34a; font-weight: 600;"><i class="ph ph-check-circle" style="font-size: 24px; vertical-align: middle;"></i> ✅ Operación Limpia: No se encontraron registros con los filtros actuales.</td></tr>`;
        return;
    }

    tbody.innerHTML = lista.map(item => {
        const esLimpio = item.Estatus.includes("Sin Incidencias");
        const badgeEstatus = esLimpio
            ? `<span style="background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; padding: 4px 10px; border-radius: 12px; font-weight: 700; font-size: 11.5px; display: inline-flex; align-items: center; gap: 4px;"><i class="ph ph-check-circle"></i> Sin Incidencias</span>`
            : `<span style="background: #fee2e2; color: #dc2626; border: 1px solid #fecaca; padding: 4px 10px; border-radius: 12px; font-weight: 700; font-size: 11.5px; display: inline-flex; align-items: center; gap: 4px;"><i class="ph ph-warning-circle"></i> Con Incidencias</span>`;

        const badgeTipo = item.Tipo === 'Empleado'
            ? `<span style="background: #eff6ff; color: #2563eb; font-weight: 600; font-size: 11.5px; padding: 2px 8px; border-radius: 6px;">👤 Empleado</span>`
            : `<span style="background: #fef3c7; color: #d97706; font-weight: 600; font-size: 11.5px; padding: 2px 8px; border-radius: 6px;">🚚 Proveedor</span>`;

        const badgePeriodo = (modoComparativoIncidencias && tabBitacoraActual === 'AMBOS')
            ? (item._periodo === 'A'
                ? `<span style="background: #e0e7ff; color: #4338ca; font-weight: 800; font-size: 10px; padding: 1px 5px; border-radius: 4px; margin-right: 4px;">P-A</span>`
                : `<span style="background: #ffedd5; color: #c2410c; font-weight: 800; font-size: 10px; padding: 1px 5px; border-radius: 4px; margin-right: 4px;">P-B</span>`)
            : '';

        return `
            <tr>
                <td style="font-family: monospace; font-size: 12px; color: #64748b;">${badgePeriodo}${item.Fecha || '--'}</td>
                <td style="font-weight: 600; color: #0f172a; font-size: 13px;">${item.Evento}</td>
                <td style="text-align: center;">${badgeTipo}</td>
                <td style="font-weight: 500; font-size: 13px;">${item.Actor}</td>
                <td style="text-align: center;">${badgeEstatus}</td>
                <td style="color: ${esLimpio ? '#64748b' : '#b91c1c'}; font-size: 12.5px; line-height: 1.4;">${item.Nota}</td>
            </tr>
        `;
    }).join('');
}

function filtrarTablaIncidenciasEnVivo(termino) {
    const t = (termino || "").toLowerCase().trim();
    if (!t) {
        renderizarTablaIncidencias(evaluacionesFiltradasIncidencias);
        return;
    }
    const filtrados = evaluacionesFiltradasIncidencias.filter(item =>
        (item.Evento && item.Evento.toLowerCase().includes(t)) ||
        (item.Actor && item.Actor.toLowerCase().includes(t)) ||
        (item.Nota && item.Nota.toLowerCase().includes(t)) ||
        (item.Tipo && item.Tipo.toLowerCase().includes(t)) ||
        (item.Fecha && item.Fecha.includes(t))
    );
    renderizarTablaIncidencias(filtrados);
}

