// ==============================================================================
// MÓDULO: eventos_op.js
// 6. Órdenes de Producción (formulario, guardado, búsqueda)
// Líneas originales: 1253–1998 de script.js
// ==============================================================================

// ==========================================
// 6. MÓDULO ÓRDENES DE PRODUCCIÓN
// ==========================================

// Estado global para catálogos y multi-selects de la OP
window.vproCatalogosOP = null;
window.vproFoliosActivos = [];
window.vproFoliosHistoricos = [];
window.vproProximoId = 1;

window.opMultiSelects = {
    personal_vpro: [],
    vehiculos: [],
    personal_externo: [],
    proveedores: [],
    reuniones: []
};

function cambiarPestanaOP(pestana) {
    const btnActivas = document.getElementById("tab-btn-activas");
    const btnHistorico = document.getElementById("tab-btn-historico");
    const vistaActivas = document.getElementById("subvista-op-activas");
    const vistaHistorico = document.getElementById("subvista-op-historico");

    if (!btnActivas || !btnHistorico || !vistaActivas || !vistaHistorico) return;

    if (pestana === 'activas') {
        btnActivas.classList.add('active');
        btnHistorico.classList.remove('active');
        vistaActivas.style.display = 'block';
        vistaHistorico.style.display = 'none';
    } else {
        btnHistorico.classList.add('active');
        btnActivas.classList.remove('active');
        vistaHistorico.style.display = 'block';
        vistaActivas.style.display = 'none';

        // Si la lista de históricos aún no tiene selección, seleccionar la primera
        const selectHist = document.getElementById("select-folios-historicos");
        if (selectHist && selectHist.value) {
            cargarDetalleOPHistorico(selectHist.value);
        } else if (selectHist && selectHist.options.length > 1) {
            selectHist.selectedIndex = 1;
            cargarDetalleOPHistorico(selectHist.value);
        }
    }
}

async function inicializarModuloOP() {
    if (typeof esUsuarioAutorizadoOP === 'function' && !esUsuarioAutorizadoOP()) {
        if (typeof Swal !== 'undefined') {
            Swal.fire({
                icon: 'error',
                title: '⛔ Acceso Restringido',
                html: '<p style="color: #475569; font-size: 14px;">El módulo de <b>Órdenes de Producción [VPF-PAGL-OP]</b> está reservado exclusivamente para <b>Administradores, Productores y el Coordinador</b>.</p>',
                confirmButtonColor: '#4f46e5'
            });
        } else {
            alert("⛔ Acceso Restringido: El módulo de Órdenes de Producción está reservado exclusivamente para Administradores, Productores y el Coordinador.");
        }
        if (typeof cambiarVista === 'function') cambiarVista('vista-inicio');
        return;
    }
    const selectFolios = document.getElementById('select-folios-op');
    const selectHistoricos = document.getElementById('select-folios-historicos');
    const container = document.getElementById('formulario-op-container');
    if (!selectFolios) return;

    try {
        const [resFolios, resCats, resReus, resCron] = await Promise.all([
            fetch(`${API_URL}/api/eventos/folios`),
            fetch(`${API_URL}/api/eventos/catalogos`),
            fetch(`${API_URL}/api/reuniones/catalogo`).catch(() => ({ ok: false })),
            fetch(`${API_URL}/api/cronogramas/catalogo/op`).catch(() => ({ ok: false }))
        ]);

        const dataFolios = await resFolios.json();
        const dataCats = await resCats.json();
        const dataReus = resReus.ok ? await resReus.json() : [];
        const dataCron = (resCron && resCron.ok) ? await resCron.json() : [];

        window.vproFoliosActivos = dataFolios.folios || [];
        window.vproFoliosHistoricos = dataFolios.folios_historicos || [];
        window.vproProximoId = dataFolios.proximo_id || 1;

        // Combinar catálogos
        window.vproCatalogosOP = {
            ...dataCats,
            reuniones: dataReus || [],
            cronogramas: dataCron || []
        };

        // 1. Poblar folios activos
        selectFolios.innerHTML = '<option value="">🆕 CREAR NUEVA ORDEN</option>';
        window.vproFoliosActivos.forEach(folioStr => {
            const option = document.createElement('option');
            const folioNum = folioStr.split(' - ')[0]; 
            option.value = folioNum;
            option.textContent = folioStr;
            selectFolios.appendChild(option);
        });

        // 2. Poblar folios históricos
        if (selectHistoricos) {
            selectHistoricos.innerHTML = '<option value="">Selecciona un folio histórico...</option>';
            window.vproFoliosHistoricos.forEach(folioStr => {
                const option = document.createElement('option');
                const folioNum = folioStr.split(' - ')[0]; 
                option.value = folioNum;
                option.textContent = folioStr;
                selectHistoricos.appendChild(option);
            });
        }

        // Cargar por defecto la primera orden activa si existe, o formulario nuevo
        if (window.vproFoliosActivos.length > 0) {
            const primerFolio = window.vproFoliosActivos[0].split(' - ')[0];
            selectFolios.value = primerFolio;
            cargarDetalleOP(primerFolio);
        } else {
            cargarDetalleOP("");
        }

    } catch (error) {
        console.error("Error al conectar con la API de eventos:", error);
        if (container) {
            container.innerHTML = `
                <div style="background: #fef2f2; padding: 20px; border-radius: 8px; border-left: 4px solid #ef4444; margin-top: 15px;">
                    <p style="margin: 0; color: #991b1b; font-weight: 500;">❌ Error al conectar con el servidor de OPs: ${error.message}</p>
                </div>
            `;
        }
    }
}

// -------------------------------------------------------------
// Componente Multi-Select con Etiquetas Rojas y Removibles
// -------------------------------------------------------------
function renderMultiSelectComponent(containerId, stateKey, allOptions, placeholder, isReadOnly = false) {
    const cont = document.getElementById(containerId);
    if (!cont) return;

    const selectedList = window.opMultiSelects[stateKey] || [];
    const availableOptions = (allOptions || []).filter(opt => !selectedList.includes(opt));

    let tagsHtml = selectedList.map(item => `
        <span class="tag-pill">
            <span>${item}</span>
            ${!isReadOnly ? `<span class="tag-close" onclick="removeMultiTag('${stateKey}', '${item.replace(/'/g, "\\'")}', '${containerId}')" title="Eliminar">✖</span>` : ''}
        </span>
    `).join('');

    let selectHtml = '';
    if (!isReadOnly) {
        const defaultOptionLabel = selectedList.length === 0
            ? placeholder
            : (stateKey === 'cronogramas' ? '🔄 Cambiar cronograma...' : '+ Agregar...');

        selectHtml = `
            <select class="multiselect-select" onchange="addMultiTag('${stateKey}', this.value, '${containerId}'); this.value='';">
                <option value="">${defaultOptionLabel}</option>
                ${availableOptions.map(opt => `<option value="${opt}">${opt}</option>`).join('')}
            </select>
            ${selectedList.length > 0 ? `<span class="multiselect-clear" title="Limpiar todos" onclick="clearMultiTags('${stateKey}', '${containerId}')">✖</span>` : ''}
            <span style="color: #94a3b8; font-size: 11px; margin-left: 4px; pointer-events: none;">▼</span>
        `;
    }

    cont.innerHTML = `
        <div class="multiselect-box">
            ${tagsHtml}
            ${selectHtml}
        </div>
    `;
}

function addMultiTag(stateKey, val, containerId) {
    if (!val) return;
    if (!window.opMultiSelects[stateKey]) window.opMultiSelects[stateKey] = [];
    
    if (stateKey === 'cronogramas') {
        window.opMultiSelects[stateKey] = [val];
    } else {
        if (!window.opMultiSelects[stateKey].includes(val)) {
            window.opMultiSelects[stateKey].push(val);
        }
    }
    const cats = window.vproCatalogosOP || {};
    let optionsList = [];
    if (stateKey === 'personal_vpro') { optionsList = cats.staff_vpro; actualizarCrewGira(); }
    else if (stateKey === 'vehiculos') optionsList = cats.autos;
    else if (stateKey === 'personal_externo') optionsList = cats.apoyos_externos;
    else if (stateKey === 'proveedores') optionsList = cats.proveedores;
    else if (stateKey === 'reuniones') optionsList = cats.reuniones;
    else if (stateKey === 'cronogramas') {
        optionsList = cats.cronogramas;
        actualizarVistaCronogramaAccordion(val, containerId, null, false);
    }

    renderMultiSelectComponent(containerId, stateKey, optionsList, stateKey === 'cronogramas' ? "Despliega y selecciona cronograma de actividades..." : "Seleccionar...");
}

function removeMultiTag(stateKey, val, containerId) {
    if (!window.opMultiSelects[stateKey]) return;
    window.opMultiSelects[stateKey] = window.opMultiSelects[stateKey].filter(x => x !== val);

    const cats = window.vproCatalogosOP || {};
    let optionsList = [];
    if (stateKey === 'personal_vpro') { optionsList = cats.staff_vpro; actualizarCrewGira(); }
    else if (stateKey === 'vehiculos') optionsList = cats.autos;
    else if (stateKey === 'personal_externo') optionsList = cats.apoyos_externos;
    else if (stateKey === 'proveedores') optionsList = cats.proveedores;
    else if (stateKey === 'reuniones') optionsList = cats.reuniones;
    else if (stateKey === 'cronogramas') {
        optionsList = cats.cronogramas;
        actualizarVistaCronogramaAccordion(null, containerId, null, false);
    }

    renderMultiSelectComponent(containerId, stateKey, optionsList, stateKey === 'cronogramas' ? "Despliega y selecciona cronograma de actividades..." : "Seleccionar...");
}

function clearMultiTags(stateKey, containerId) {
    window.opMultiSelects[stateKey] = [];
    const cats = window.vproCatalogosOP || {};
    let optionsList = [];
    if (stateKey === 'personal_vpro') { optionsList = cats.staff_vpro; actualizarCrewGira(); }
    else if (stateKey === 'vehiculos') optionsList = cats.autos;
    else if (stateKey === 'personal_externo') optionsList = cats.apoyos_externos;
    else if (stateKey === 'proveedores') optionsList = cats.proveedores;
    else if (stateKey === 'reuniones') optionsList = cats.reuniones;
    else if (stateKey === 'cronogramas') {
        optionsList = cats.cronogramas;
        actualizarVistaCronogramaAccordion(null, containerId, null, false);
    }

    renderMultiSelectComponent(containerId, stateKey, optionsList, stateKey === 'cronogramas' ? "Despliega y selecciona cronograma de actividades..." : "Seleccionar...");
}

// -------------------------------------------------------------
// Componente Acordeón para Cronograma Vinculado (Estilo Auditoría)
// -------------------------------------------------------------
function generarHtmlCronogramaAccordion(cron, isReadOnly = false) {
    if (!cron) return '';
    const folio = cron.folio || cron.id_cronograma || '--';
    const fecha = cron.fecha || '--';
    const ubicacion = cron.ubicacion_general || 'Estudio / Por definir';
    const nombre = cron.nombre_evento || 'Sin título';
    const idCronograma = cron.id_cronograma;
    const actividades = Array.isArray(cron.actividades) ? cron.actividades : [];
    const totalActividades = actividades.length;

    return `
        <details class="cronograma-op-accordion" style="background: #ffffff; border-radius: 12px; border: 1px solid #e2e8f0; box-shadow: 0 2px 8px rgba(0,0,0,0.04); margin-top: 10px; margin-bottom: 12px; border-left: 5px solid #0284c7; overflow: hidden; transition: all 0.2s ease;">
            <summary style="padding: 13px 18px; cursor: pointer; user-select: none; font-weight: 700; color: #0f172a; font-size: 14.5px; display: flex; align-items: center; justify-content: space-between; gap: 12px; background: #fafafa; transition: background 0.2s;" onmouseover="this.style.background='#f1f5f9'" onmouseout="this.style.background='#fafafa'">
                <span style="display: inline-flex; align-items: center; gap: 10px; flex-wrap: wrap;">
                    <i class="ph ph-calendar-check" style="color: #0284c7; font-size: 20px;"></i>
                    <span style="color: #0f172a; font-weight: 700;">Cronograma de Actividades Vinculado (Folio: ${folio})</span>
                    <span style="font-size: 13px; color: #64748b; font-weight: 500;">
                        📅 ${fecha} &nbsp;|&nbsp; 📍 ${ubicacion}
                    </span>
                </span>
                <span style="display: inline-flex; align-items: center; gap: 10px;">
                    ${idCronograma ? `
                        <button type="button" onclick="event.stopPropagation(); imprimirCronogramaDirecto(${idCronograma})" style="background: #0284c7; color: white; border: none; padding: 5px 12px; border-radius: 6px; font-size: 11.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; box-shadow: 0 1px 3px rgba(2,132,199,0.3); transition: background 0.2s;" onmouseover="this.style.background='#0369a1'" onmouseout="this.style.background='#0284c7'" title="Imprimir Hoja Oficial">
                            <i class="ph ph-printer"></i> 🖨️ Imprimir Hoja Oficial
                        </button>
                    ` : ''}
                    <span style="background: #e0f2fe; color: #0284c7; border: 1px solid #bae6fd; font-size: 11.5px; font-weight: 700; padding: 4px 12px; border-radius: 20px; letter-spacing: 0.3px; display: inline-flex; align-items: center; gap: 5px;">
                        <i class="ph ph-list-dashes"></i> ${totalActividades} Actividades &nbsp;▾
                    </span>
                </span>
            </summary>
            <div style="padding: 16px 20px; border-top: 1px solid #f1f5f9; background: #ffffff;">
                ${cron.observaciones_generales ? `
                    <div style="margin-bottom: 12px; padding: 10px 14px; background: #fffbeb; border: 1px solid #fef3c7; border-radius: 8px; font-size: 12.5px; color: #92400e;">
                        <strong>⚠️ Observaciones Generales:</strong> ${cron.observaciones_generales}
                    </div>
                ` : ''}
                <div class="cat-table-wrap" style="max-height: 340px; overflow-y: auto; border: 1px solid #e2e8f0; border-radius: 8px;">
                    <table class="tabla-vpro" style="font-size: 12px; width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #0f172a; color: white;">
                                <th style="padding: 8px 10px; text-align: left;">Horario</th>
                                <th style="padding: 8px 10px; text-align: left;">Actividad</th>
                                <th style="padding: 8px 10px; text-align: left;">Ubicación</th>
                                <th style="padding: 8px 10px; text-align: left;">Evento</th>
                                <th style="padding: 8px 10px; text-align: left;">Personal Convocado</th>
                                <th style="padding: 8px 10px; text-align: left;">Vehículo</th>
                                <th style="padding: 8px 10px; text-align: left;">Observaciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${actividades.length > 0 ? actividades.map(act => `
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 8px 10px; font-weight: 700; color: #0284c7; white-space: nowrap;">${act.horario || '--'}</td>
                                    <td style="padding: 8px 10px; font-weight: 600; color: #1e293b;">${act.actividad || '--'}</td>
                                    <td style="padding: 8px 10px; color: #475569;">${act.ubicacion || '--'}</td>
                                    <td style="padding: 8px 10px; color: #475569;">${act.evento || '--'}</td>
                                    <td style="padding: 8px 10px; color: #334155; font-weight: 500;">${act.personal_convocado || '--'}</td>
                                    <td style="padding: 8px 10px; color: #475569;">${act.vehiculo || '--'}</td>
                                    <td style="padding: 8px 10px; color: #64748b; font-style: italic;">${act.observaciones || '--'}</td>
                                </tr>
                            `).join('') : `
                                <tr>
                                    <td colspan="7" style="padding: 16px; text-align: center; color: #94a3b8; font-style: italic;">
                                        Sin actividades desglosadas registradas en este cronograma.
                                    </td>
                                </tr>
                            `}
                        </tbody>
                    </table>
                </div>
            </div>
        </details>
    `;
}
window.generarHtmlCronogramaAccordion = generarHtmlCronogramaAccordion;

async function actualizarVistaCronogramaAccordion(firma, containerId, detallePreexistente = null, isReadOnly = false) {
    const sufijo = (containerId && containerId.includes('hist')) ? 'hist' : 'act';
    const contAccordion = document.getElementById(`contenedor-cronograma-accordion-${sufijo}`);
    if (!contAccordion) return;

    if (!firma || !String(firma).trim()) {
        contAccordion.innerHTML = '';
        contAccordion.style.display = 'none';
        return;
    }

    const firmaStr = String(firma).trim();

    // 1. Verificar si viene detalle preexistente
    if (detallePreexistente && typeof detallePreexistente === 'object') {
        const fol = String(detallePreexistente.folio || detallePreexistente.id_cronograma || '').trim();
        if (fol && (firmaStr.includes(fol) || String(detallePreexistente.id_cronograma) === firmaStr)) {
            contAccordion.innerHTML = generarHtmlCronogramaAccordion(detallePreexistente, isReadOnly);
            contAccordion.style.display = 'block';
            return;
        }
    }

    // 2. Verificar si está en memoria window.currentOPData.detalle_cronogramas
    if (window.currentOPData && Array.isArray(window.currentOPData.detalle_cronogramas)) {
        const encontrado = window.currentOPData.detalle_cronogramas.find(c => {
            const fol = String(c.folio || c.id_cronograma || '').trim();
            return fol && (firmaStr.includes(fol) || String(c.id_cronograma) === firmaStr);
        });
        if (encontrado) {
            contAccordion.innerHTML = generarHtmlCronogramaAccordion(encontrado, isReadOnly);
            contAccordion.style.display = 'block';
            return;
        }
    }

    // 3. Consultar vía API al endpoint /api/cronogramas/detalle/buscar
    contAccordion.innerHTML = `
        <div style="background: #ffffff; border-radius: 12px; border: 1px solid #e2e8f0; padding: 14px 18px; margin-top: 10px; border-left: 5px solid #0284c7; color: #64748b; font-size: 13px; display: flex; align-items: center; gap: 8px;">
            <i class="ph ph-spinner ph-spin" style="font-size: 18px; color: #0284c7;"></i>
            <span>Cargando actividades del cronograma seleccionado...</span>
        </div>
    `;
    contAccordion.style.display = 'block';

    try {
        const res = await fetch(`${API_URL}/api/cronogramas/detalle/buscar?firma=${encodeURIComponent(firmaStr)}`);
        if (!res.ok) throw new Error("No encontrado");
        const cron = await res.json();
        
        if (!window.currentOPData) window.currentOPData = {};
        if (!Array.isArray(window.currentOPData.detalle_cronogramas)) window.currentOPData.detalle_cronogramas = [];
        window.currentOPData.detalle_cronogramas = [cron];

        contAccordion.innerHTML = generarHtmlCronogramaAccordion(cron, isReadOnly);
    } catch (e) {
        contAccordion.innerHTML = `
            <div style="background: #fff1f2; border-radius: 12px; border: 1px solid #fecdd3; padding: 12px 16px; margin-top: 10px; border-left: 5px solid #e11d48; color: #be123c; font-size: 13px;">
                ⚠️ No se pudo obtener el desglose de actividades para el cronograma seleccionado (${firmaStr}).
            </div>
        `;
    }
}
window.actualizarVistaCronogramaAccordion = actualizarVistaCronogramaAccordion;

function actualizarCrewGira(choferGuardado) {
    const el = document.getElementById("texto-crew-gira");
    const crew = window.opMultiSelects.personal_vpro || [];
    if (el) {
        el.innerText = crew.length > 0 ? crew.join(", ") : "Sin personal asignado en la orden";
    }

    const selectChofer = document.getElementById("op_chofer");
    if (selectChofer) {
        const actual = (choferGuardado !== undefined && choferGuardado !== null) ? String(choferGuardado).trim() : (selectChofer.value || '').trim();
        let html = '<option value="">-- Selecciona chofer del personal convocado --</option>';
        let found = false;
        crew.forEach(nombre => {
            const nTrim = String(nombre).trim();
            const sel = (nTrim.toLowerCase() === actual.toLowerCase() && actual) ? 'selected' : '';
            if (sel) found = true;
            html += `<option value="${nTrim}" ${sel}>${nTrim}</option>`;
        });
        // Si viene un chofer asignado previamente desde la base de datos, incluirlo aunque no esté en el multiselect
        if (choferGuardado && actual && !found) {
            html += `<option value="${actual}" selected>${actual}</option>`;
        }
        selectChofer.innerHTML = html;
        alCambiarChoferDesignado(selectChofer.value);
    }
}

function alCambiarChoferDesignado(nombre) {
    const badge = document.getElementById("badge-chofer-info");
    const texto = document.getElementById("texto-chofer-designado");
    if (!badge) return;
    if (nombre && String(nombre).trim()) {
        badge.style.display = "flex";
        if (texto) texto.innerText = String(nombre).trim();
    } else {
        badge.style.display = "none";
    }
}

function alCambiarFechaInicioEvento(input) {
    if (!input || !input.value) return;
    const fFin = document.getElementById("op_fec_fin_evento");
    if (fFin && (!fFin.value || fFin.value < input.value)) {
        fFin.value = input.value;
    }
}

function copiarPresupuestoReunionAOP(monto) {
    const el = document.getElementById("op_estimado_gasto");
    if (el) {
        el.value = Number(monto).toFixed(2);
        el.focus();
    }
}

// -------------------------------------------------------------
// Generador Completo del Formulario de Orden de Producción
// -------------------------------------------------------------
function generarHtmlFormularioOP(data, isReadOnly = false) {
    const cats = window.vproCatalogosOP || {};
    const hoyStr = formatearFechaLocal(new Date());

    const idEvento = data.id_evento || window.vproProximoId || 1;
    const folioVal = data.folio || String(idEvento);

    // Fechas y Horas limpias
    const fInstalacion = (data.fec_de_instalacion ? String(data.fec_de_instalacion).substring(0, 10) : hoyStr);
    const hInstalacion = (data.hra_de_instalacion ? String(data.hra_de_instalacion).substring(0, 5) : "09:30");
    const fEvento = (data.fec_del_evento ? String(data.fec_del_evento).substring(0, 10) : hoyStr);
    const fEventoFin = (data.fec_fin_evento ? String(data.fec_fin_evento).substring(0, 10) : fEvento);
    const hInicio = (data.inicio_del_evento ? String(data.inicio_del_evento).substring(0, 5) : "13:30");
    const hLlamado = (data.hra_de_llamado ? String(data.hra_de_llamado).substring(0, 5) : "09:00");
    const depSolicitaVal = data.dependencia_solicita || '';
    const quienSolicitaVal = data.quien_solicita || '';
    const respGastosVal = data.responsable_gastos || '';
    const choferVal = data.chofer || '';

    // Autorizaciones defaults
    const defElabora = data.elabora || "Ana Lilia Villarreal Uribe";
    const defCoordina = data.coordina || "Manuel Eduardo Madrid";
    const defOrganiza = data.organiza || "Martin Eduardo Sanchez Estrada";
    const defVobo = data.vobo || "Gerardo Villarreal Uribe";

    const defaultNota = "Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.";

    // Inyectar botones de acción en el recuadro superior (a la misma altura que el dropdown)
    setTimeout(() => {
        actualizarCrewGira(choferVal);
        const tieneGira = Boolean(data && (data.es_viaje_foraneo || Number(data.horas_manejo_chofer) > 0 || (data.chofer && String(data.chofer).trim() !== '')));
        if (tieneGira && typeof toggleBitacoraGira === 'function') {
            toggleBitacoraGira(true);
        }
        const contBotonesId = isReadOnly ? 'op-historico-header-botones-accion' : 'op-header-botones-accion';
        const contBotones = document.getElementById(contBotonesId);
        if (contBotones) {
            if (data && data.folio) {
                contBotones.innerHTML = `
                    <button type="button" onclick="imprimirOrdenProduccionActual('${folioVal}')" style="background: #0078d4; color: white; border: none; height: 38px; padding: 0 18px; border-radius: 6px; font-weight: 700; font-size: 13px; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 6px rgba(0, 120, 212, 0.25); transition: all 0.2s;">
                        <i class="ph ph-printer" style="font-size: 17px;"></i> 🖨️ Imprimir esta OP
                    </button>
                `;
            } else {
                contBotones.innerHTML = '';
            }
        }
    }, 10);

    // Select options helpers
    const buildOptions = (list, selectedVal, addEmpty = false) => {
        let opts = addEmpty ? '<option value="">---</option>' : '';
        let found = false;
        (list || []).forEach(item => {
            const sel = (String(item).trim() === String(selectedVal || '').trim()) ? 'selected' : '';
            if (sel) found = true;
            opts += `<option value="${item}" ${sel}>${item}</option>`;
        });
        if (selectedVal && !found) {
            opts += `<option value="${selectedVal}" selected>${selectedVal}</option>`;
        }
        return opts;
    };

    const dis = isReadOnly ? 'disabled' : '';
    const rolUsuario = (usuarioLogueado?.rol || '').toUpperCase();
    const nombreUsuario = (usuarioLogueado?.nombre_completo || '').toUpperCase();
    const esCoordinadorOAdmin = (typeof esUsuarioAutorizadoOP === 'function') 
        ? esUsuarioAutorizadoOP() 
        : (rolUsuario.includes('ADMIN') || rolUsuario.includes('PRODUCTOR') || rolUsuario.includes('COORDINADOR') || rolUsuario.includes('COORDINACION'));
    // Estricto: Solo Coordinador o Villarreal o Agundez pueden integrar chats
    const esPuedeIntegrarChat = rolUsuario.includes('COORDINADOR') || rolUsuario.includes('COORDINACION') || nombreUsuario.includes('VILLARREAL') || nombreUsuario.includes('AGUNDEZ');
    // Estricto: Solo Villarreal o Agundez pueden abrir el chat sellado
    const esVillarrealOAgundez = nombreUsuario.includes('VILLARREAL') || nombreUsuario.includes('AGUNDEZ');

    return `
        <form id="form-orden-produccion-${isReadOnly ? 'hist' : 'act'}" onsubmit="guardarOrdenOP(event)">
            <input type="hidden" id="op_id_evento" value="${idEvento}">

            ${isReadOnly && data.folio && esCoordinadorOAdmin ? `
                <!-- 🔓 BANNER DE HABILITACIÓN PARA EDICIÓN / EVIDENCIAS DESDE EL HISTÓRICO -->
                <div style="background: #f0fdf4; border: 1px solid #bbf7d0; border-left: 5px solid #16a34a; padding: 16px 20px; border-radius: 10px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px; box-shadow: 0 2px 6px rgba(0,0,0,0.04);">
                    <div>
                        <div style="font-weight: 700; color: #166534; font-size: 14.5px; display: flex; align-items: center; gap: 8px;">
                            <i class="ph ph-archive-box" style="font-size: 20px;"></i>
                            <span>OP EN ARCHIVO HISTÓRICO (MODO CONSULTA / SOLO LECTURA)</span>
                        </div>
                        <div style="font-size: 13px; color: #15803d; margin-top: 4px; line-height: 1.4;">
                            ¿Faltó adjuntar evidencias multimedia (fotos o videos) o requieres agregar/corregir información?
                        </div>
                    </div>
                    <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                        <button type="button" onclick="imprimirOrdenProduccionActual('${folioVal}')" style="background: #0078d4; color: white; border: none; padding: 10px 18px; border-radius: 8px; font-weight: 700; font-size: 13.5px; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 4px 10px rgba(0, 120, 212, 0.25); transition: all 0.2s;">
                            <i class="ph ph-printer" style="font-size: 18px;"></i> 🖨️ Imprimir esta OP
                        </button>
                        <button type="button" onclick="habilitarOPParaEdicion('${folioVal}')" style="background: #16a34a; color: white; border: none; padding: 10px 18px; border-radius: 8px; font-weight: 700; font-size: 13.5px; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 4px 10px rgba(22, 163, 74, 0.3); transition: all 0.2s;">
                            <i class="ph ph-lock-key-open"></i> 🔓 Habilitar OP para Agregar Evidencias / Edición
                        </button>
                    </div>
                </div>
            ` : ''}

            ${!isReadOnly && data.habilitada_para_edicion ? `
                <!-- 🟡 BANNER DE OP HABILITADA TEMPORALMENTE -->
                <div style="background: #fefce8; border: 1px solid #fef08a; border-left: 5px solid #eab308; padding: 16px 20px; border-radius: 10px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px; box-shadow: 0 2px 6px rgba(0,0,0,0.04);">
                    <div>
                        <div style="font-weight: 700; color: #854d0e; font-size: 14.5px; display: flex; align-items: center; gap: 8px;">
                            <i class="ph ph-warning-circle" style="font-size: 20px;"></i>
                            <span>OP HABILITADA TEMPORALMENTE DESDE EL HISTÓRICO</span>
                        </div>
                        <div style="font-size: 13px; color: #713f12; margin-top: 4px; line-height: 1.4;">
                            Esta orden ya cuenta con cierre financiero/gastos. Agrega las evidencias (fotos/videos) o información pendiente. Al concluir, regrésala al archivo histórico.
                        </div>
                    </div>
                    ${esCoordinadorOAdmin ? `
                        <button type="button" onclick="mandarOPAlHistorial('${folioVal}')" style="background: #475569; color: white; border: none; padding: 10px 18px; border-radius: 8px; font-weight: 700; font-size: 13.5px; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.2); transition: all 0.2s;">
                            <i class="ph ph-archive-box"></i> 📦 Mandar de Nuevo al Historial
                        </button>
                    ` : ''}
                </div>
            ` : ''}

            <!-- 📝 1. DATOS DE LA ORDEN -->
            <div class="op-section-card">
                <div style="margin-bottom: 16px;">
                    <h3 class="op-section-title" style="margin: 0;">📝 Datos de la Orden</h3>
                </div>
                
                <!-- Fila 1: Folio, Cliente, Evento y Subtítulo -->
                <div style="display: grid; grid-template-columns: 1fr 2fr 2.5fr 2fr; gap: 14px; margin-bottom: 16px;">
                    <div>
                        <label class="op-form-label">🔢 FOLIO VPRO:</label>
                        <input type="text" id="op_folio" value="${folioVal}" class="op-input" disabled>
                    </div>
                    <div>
                        <label class="op-form-label">👤 CLIENTE:</label>
                        <select id="op_para_q_cliente" class="op-select" ${dis}>
                            <option value="">-> Seleccionar cliente...</option>
                            ${buildOptions(cats.clientes, data.para_q_cliente)}
                        </select>
                    </div>
                    <div>
                        <label class="op-form-label">🎉 NOMBRE DE EVENTO:</label>
                        <input type="text" id="op_nombre_evento" value="${data.nombre_evento || ''}" class="op-input" placeholder="Nombre principal del torneo o evento..." ${dis}>
                    </div>
                    <div>
                        <label class="op-form-label">🏀 SUBTÍTULO / PARTIDO / SERIE:</label>
                        <input type="text" id="op_subtitulo_evento" value="${data.subtitulo_evento || ''}" class="op-input" placeholder="Ej. TEBACAS VS EL ROSARIO..." ${dis}>
                    </div>
                </div>

                <!-- Fila 2: Locación y Detalle Llamado -->
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                    <div>
                        <label class="op-form-label">📍 LOCACIÓN (Lugar):</label>
                        <input type="text" id="op_locacion" value="${data.locacion || ''}" class="op-input" placeholder="Lugar o sede del evento..." ${dis}>
                    </div>
                    <div>
                        <label class="op-form-label">⏱️ DETALLE LLAMADO:</label>
                        <input type="text" id="op_detalle_llamado" value="${data.detalle_llamado || ''}" class="op-input" placeholder="Ej. Manuel: 9:00 AM | Estudio: 4:00 PM..." ${dis}>
                    </div>
                </div>

                <!-- Fila 3: Dependencia/Área, Persona que solicita (Contacto / Responsable), Productor Resp. y Responsable de Gastos -->
                <div style="display: grid; grid-template-columns: 1.2fr 1.3fr 1.25fr 1.25fr; gap: 14px; margin-bottom: 16px;">
                    <div>
                        <label class="op-form-label">🏢 DEPENDENCIA O ÁREA SOLICITA:</label>
                        <input type="text" id="op_dependencia_solicita" value="${depSolicitaVal}" class="op-input" placeholder="Ej. Presidencia, Comunicación Social, Giras..." ${dis}>
                    </div>
                    <div>
                        <label class="op-form-label">👤 PERSONA QUE SOLICITA:</label>
                        <input type="text" id="op_quien_solicita" value="${quienSolicitaVal}" class="op-input" placeholder="Nombre completo del contacto / responsable..." ${dis}>
                    </div>
                    <div>
                        <label class="op-form-label">🎬 PRODUCTOR RESP.:</label>
                        <select id="op_resp_de_produccion" class="op-select" ${dis}>
                            ${buildOptions(cats.staff_vpro, data.resp_de_produccion, true)}
                        </select>
                    </div>
                    <div>
                        <label class="op-form-label">💳 RESPONSABLE DE GASTOS:</label>
                        <select id="op_responsable_gastos" class="op-select" ${dis}>
                            <option value="">-> Mismo productor o asignar...</option>
                            ${buildOptions(cats.staff_vpro, respGastosVal, true)}
                        </select>
                    </div>
                </div>

                <!-- Fila 4: Calendario Completo del Evento (Fechas y Horarios) -->
                <div style="display: grid; grid-template-columns: 1fr 1fr 0.9fr 0.9fr 1fr 0.9fr; gap: 12px; margin-bottom: 16px;">
                    <div>
                        <label class="op-form-label">🗓️ FECHA INICIO:</label>
                        <input type="date" id="op_fec_del_evento" value="${fEvento}" class="op-input" ${dis} onchange="alCambiarFechaInicioEvento(this)">
                    </div>
                    <div>
                        <label class="op-form-label">🏁 FECHA FIN:</label>
                        <input type="date" id="op_fec_fin_evento" value="${fEventoFin}" class="op-input" ${dis}>
                    </div>
                    <div>
                        <label class="op-form-label">🚀 H. INICIO:</label>
                        <input type="time" id="op_inicio_del_evento" value="${hInicio}" class="op-input" ${dis}>
                    </div>
                    <div>
                        <label class="op-form-label">📞 H. LLAMADO:</label>
                        <input type="time" id="op_hra_de_llamado" value="${hLlamado}" class="op-input" ${dis}>
                    </div>
                    <div>
                        <label class="op-form-label">📅 FECHA INSTALACIÓN:</label>
                        <input type="date" id="op_fec_de_instalacion" value="${fInstalacion}" class="op-input" ${dis}>
                    </div>
                    <div>
                        <label class="op-form-label">⏰ HORA INSTALACIÓN:</label>
                        <input type="time" id="op_hra_de_instalacion" value="${hInstalacion}" class="op-input" ${dis}>
                    </div>
                </div>

                <!-- Fila 5: Ubicación Exacta y Destino Vehicular -->
                <div style="display: grid; grid-template-columns: 1.3fr 1fr; gap: 16px; margin-bottom: 16px;">
                    <div>
                        <label class="op-form-label">🗺️ UBICACIÓN EXACTA:</label>
                        <input type="text" id="op_ubicacion" value="${data.ubicacion || ''}" class="op-input" placeholder="Dirección precisa, salón, piso o referencias GPS..." ${dis}>
                    </div>
                    <div>
                        <label class="op-form-label">🎯 DESTINO VEHICULAR / CIUDAD:</label>
                        <input type="text" id="op_vehiculo_destino" value="${data.vehiculo_destino || ''}" class="op-input" placeholder="Ej. BADIRAGUATO, SIN..." ${dis}>
                    </div>
                </div>

                <!-- Fila 5: Vincular Reunión(es) -->
                <div style="margin-bottom: 16px;">
                    <label class="op-form-label">🤝 VINCULAR REUNIÓN(ES):</label>
                    <div id="ms-reuniones-${isReadOnly ? 'hist' : 'act'}"></div>
                    ${(data.detalle_reuniones && data.detalle_reuniones.length > 0) ? `
                        <div style="margin-top: 10px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px 14px;">
                            <div style="font-size: 12.5px; font-weight: 700; color: #334155; margin-bottom: 6px;">
                                📋 Minutas Previas Vinculadas a esta OP:
                            </div>
                            ${data.detalle_reuniones.map(dr => `
                                <div style="display: flex; justify-content: space-between; align-items: center; font-size: 12px; padding: 4px 0; border-bottom: 1px dashed #cbd5e1; gap: 8px; flex-wrap: wrap;">
                                    <span><strong>${dr.nombre_proyecto_tentativo || 'Reunión'}</strong> (${dr.fecha_reunion || 'S/F'})</span>
                                    ${(dr.presupuesto_estimado && Number(dr.presupuesto_estimado) > 0) ? `
                                        <div style="display: flex; align-items: center; gap: 6px;">
                                            <span style="color: #166534; font-weight: 700;">Presupuesto Minuta: $ ${Number(dr.presupuesto_estimado).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</span>
                                            ${!isReadOnly ? `
                                                <button type="button" onclick="copiarPresupuestoReunionAOP(${dr.presupuesto_estimado})" style="background: #16a34a; color: white; border: none; padding: 2px 8px; border-radius: 4px; font-size: 11px; cursor: pointer; font-weight: 600;">
                                                    📥 Aplicar a OP
                                                </button>
                                            ` : ''}
                                        </div>
                                    ` : ''}
                                </div>
                            `).join('')}
                        </div>
                    ` : ''}
                </div>

                <!-- Fila 5.1: Vincular Cronograma de Actividades (con Acordeón Integrado) -->
                <div style="margin-bottom: 16px;">
                    <label class="op-form-label">📅 VINCULAR CRONOGRAMA DE ACTIVIDADES:</label>
                    <div id="ms-cronogramas-${isReadOnly ? 'hist' : 'act'}"></div>
                    <div id="contenedor-cronograma-accordion-${isReadOnly ? 'hist' : 'act'}" style="display: none; margin-top: 10px;"></div>
                </div>

                <!-- Fila 5.2: Evidencias Multimedia del Evento (Fotos y Videos MP4) -->
                <div style="margin-bottom: 20px; background: #ffffff; border: 1.5px solid #cbd5e1; border-radius: 10px; padding: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; flex-wrap: wrap; gap: 8px;">
                        <label class="op-form-label" style="margin: 0; font-size: 13.5px; font-weight: 700; color: #0f172a; display: flex; align-items: center; gap: 6px;">
                            <i class="ph ph-film-slate" style="color: #0284c7; font-size: 18px;"></i>
                            <span>📸 / 🎥 EVIDENCIAS MULTIMEDIA (FOTOS Y VIDEOS MP4):</span>
                        </label>
                        <span id="op-fotos-badge-${isReadOnly ? 'hist' : 'act'}" style="font-size: 12px; font-weight: 700; color: #0284c7; background: #e0f2fe; padding: 3px 10px; border-radius: 20px; border: 1px solid #bae6fd;">
                            ${formatearTextoBadgeEvidencias(data.fotos_evidencia || [])}
                        </span>
                    </div>

                    ${!isReadOnly ? `
                        <div style="display: flex; gap: 12px; align-items: center; margin-bottom: 14px; flex-wrap: wrap;">
                            <label style="background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%); color: white; border-radius: 6px; padding: 9px 18px; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 700; box-shadow: 0 2px 4px rgba(2,132,199,0.25); transition: opacity 0.2s;">
                                <i class="ph ph-plus-circle" style="font-size: 17px;"></i>
                                <span>➕ Subir Fotos o Videos MP4</span>
                                <input type="file" id="input-fotos-evidencia-${data.id_evento}" multiple accept="image/jpeg,image/png,image/webp,video/mp4" style="display: none;" onchange="alSubirFotosEvidenciaOP(this, ${data.id_evento})">
                            </label>
                            <span style="font-size: 12px; color: #64748b; line-height: 1.4;">
                                <i class="ph ph-shield-check" style="color: #0284c7;"></i> Límite estricto: <strong>Fotos máx. 1 MB</strong> (JPG, PNG, WebP) | <strong>Videos máx. 5 MB</strong> (MP4) para evitar saturación de disco.
                            </span>
                        </div>
                    ` : ''}

                    <!-- Cuadrícula / Galería de Evidencias Multimedia -->
                    <div id="galeria-fotos-evidencia-${isReadOnly ? 'hist' : 'act'}" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(130px, 1fr)); gap: 12px; min-height: 80px; align-items: start;">
                        ${generarHtmlGaleriaFotosEvidencia(data.fotos_evidencia || [], isReadOnly, data.id_evento)}
                    </div>
                </div>

                <!-- Fila 6: Tipo de Servicio -->
                <div>
                    <label class="op-form-label">🛠️ TIPO DE SERVICIO:</label>
                    <textarea id="op_tipo_de_servicio" rows="2" class="op-textarea" placeholder="Descripción resumida del servicio contratado..." ${dis}>${data.tipo_de_servicio || ''}</textarea>
                </div>
            </div>

            <!-- 👥 2. ASIGNACIÓN DE EQUIPO Y LOGÍSTICA -->
            <div class="op-section-card">
                <h3 class="op-section-title">👥 Asignación de Equipo y Logística</h3>

                <!-- Grilla de Convocados: Personal VPRO, Vehículos, Externos, Proveedores -->
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                    <!-- Columna Izquierda -->
                    <div>
                        <div style="margin-bottom: 16px;">
                            <label class="op-form-label">SELECCIONAR PERSONAL VPRO:</label>
                            <div id="ms-personal_vpro-${isReadOnly ? 'hist' : 'act'}"></div>
                        </div>
                        <div>
                            <label class="op-form-label">SELECCIONAR PERSONAL EXTERNO:</label>
                            <div id="ms-personal_externo-${isReadOnly ? 'hist' : 'act'}"></div>
                        </div>
                    </div>

                    <!-- Columna Derecha -->
                    <div>
                        <div style="margin-bottom: 16px;">
                            <label class="op-form-label">VEHÍCULOS:</label>
                            <div id="ms-vehiculos-${isReadOnly ? 'hist' : 'act'}"></div>
                        </div>
                        <div>
                            <label class="op-form-label">PROVEEDORES CO-CONVOCADOS:</label>
                            <div id="ms-proveedores-${isReadOnly ? 'hist' : 'act'}"></div>
                        </div>
                    </div>
                </div>

                <!-- Textareas Técnicos -->
                <div style="margin-bottom: 16px;">
                    <label class="op-form-label">📦 PRODUCCIÓN:(LEER las INSTRUCCIONES y SI HAY DUDAS PREGUNTAR a su jefe inmediato)</label>
                    <textarea id="op_produccion" rows="6" class="op-textarea" style="background: #f1f5f9;" placeholder="Instrucciones técnicas de producción, audio, video y pantallas..." ${dis}>${data.produccion || ''}</textarea>
                </div>

                <div style="margin-bottom: 16px;">
                    <label class="op-form-label">💻 SISTEMAS / REDES:</label>
                    <textarea id="op_internet_redes" rows="5" class="op-textarea" style="background: #f1f5f9;" placeholder="Instrucciones para streaming, enlaces satelitales, modems y switches..." ${dis}>${data.internet_redes || ''}</textarea>
                </div>

                <div style="margin-bottom: 16px;">
                    <label class="op-form-label">🏗️ ACTIVIDADES PROVEEDORES:</label>
                    <textarea id="op_actividades_de_proveedores" rows="5" class="op-textarea" style="background: #f1f5f9;" placeholder="Servicios externos, montajes o requerimientos de terceros..." ${dis}>${data.actividades_de_proveedores || ''}</textarea>
                </div>

                <div style="margin-bottom: 16px;">
                    <label class="op-form-label">🏆 ROL DE JUEGOS / ENCUENTROS DEL EVENTO:</label>
                    <input type="text" id="op_rol_juegos" value="${data.rol_juegos || ''}" class="op-input" style="background: #fefce8; border-color: #fde047;" placeholder="Ej. Día 10/ Octubre | Partido | TEBACAS & El Rosario | Hora: 8:00 PM" ${dis}>
                </div>

                <div>
                    <label class="op-form-label">📝 NOTAS ADICIONALES:</label>
                    <textarea id="op_nota" rows="4" class="op-textarea" style="background: #f1f5f9;" ${dis}>${data.nota || defaultNota}</textarea>
                </div>
            </div>

            <!-- ✈️ 3. LOGÍSTICA DE VIAJES Y BITÁCORA DE HORAS -->
            <div class="op-section-card">
                <h3 class="op-section-title">✈️ Logística de Viajes y Bitácora de Horas</h3>

                <!-- Switch Activador de Gira -->
                <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 16px;">
                    <div id="toggle-switch-gira" onclick="toggleBitacoraGira()" style="width: 44px; height: 24px; background: #cbd5e1; border-radius: 24px; position: relative; cursor: pointer; transition: background 0.3s;">
                        <div id="knob-switch-gira" style="width: 18px; height: 18px; background: white; border-radius: 50%; position: absolute; top: 3px; left: 3px; transition: left 0.3s; box-shadow: 0 1px 3px rgba(0,0,0,0.2);"></div>
                    </div>
                    <span style="font-size: 13px; font-weight: 700; color: #475569; text-transform: uppercase; letter-spacing: 0.3px;">
                        💼 SI EL EVENTO ES FUERA DE LA CIUDAD ... ACTIVE ESTA BITÁCORA
                    </span>
                </div>

                <!-- Panel Oculto / Desplegable de Bitácora -->
                <div id="contenedor-bitacora-gira" style="display: none; padding-top: 10px;">
                    <!-- 🚐 LOGÍSTICA DE TRASLADO Y CONDUCTOR ASIGNADO (CONFIDENCIAL) -->
                    <div style="background: #ffffff; border: 1.5px solid #cbd5e1; border-left: 5px solid #0284c7; border-radius: 10px; padding: 16px 20px; margin-bottom: 20px; box-shadow: 0 2px 6px rgba(0,0,0,0.03);">
                        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 14px;">
                            <span style="font-size: 20px;">🚐</span>
                            <h4 style="margin: 0; font-size: 14.5px; font-weight: 700; color: #0f172a;">Logística de Traslado y Conductor Asignado</h4>
                        </div>

                        <div style="display: grid; grid-template-columns: 1.8fr 1.2fr; gap: 18px; align-items: flex-start;">
                            <div>
                                <label class="op-form-label">CONDUCTOR ASIGNADO (PERSONAL CONVOCADO):</label>
                                <select id="op_chofer" class="op-select" onchange="alCambiarChoferDesignado(this.value)" ${dis} style="font-weight: 600; color: #0f172a;">
                                    <option value="">-- Seleccionar conductor del personal convocado --</option>
                                </select>
                                <p style="font-size: 11.5px; color: #64748b; margin: 4px 0 0 0;">
                                    <em>Solo aparecen los colaboradores asignados arriba en <b>"SELECCIONAR PERSONAL VPRO"</b>.</em>
                                </p>
                            </div>
                            <div>
                                <label class="op-form-label">⏱️ HORAS ESTIMADAS DE CONDUCCIÓN (IDA + VUELTA):</label>
                                <div style="position: relative;">
                                    <input type="number" step="0.5" min="0" id="op_horas_manejo_chofer" value="${data.horas_manejo_chofer || ''}" class="op-input" placeholder="Ej. 6.0" style="font-weight: 700; color: #0f172a; padding-right: 40px;" ${dis}>
                                    <span style="position: absolute; right: 12px; top: 50%; transform: translateY(-50%); font-weight: 600; color: #64748b; pointer-events: none; font-size: 12px;">hrs</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div style="background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 8px; padding: 14px 18px; margin-bottom: 20px; color: #1e40af; font-size: 13.5px;">
                        <strong>👥 Crew activo en esta locación:</strong> <span id="texto-crew-gira">Cargando convocados...</span>
                    </div>

                    <!-- Contenedor dinámico de jornadas guardadas -->
                    <div id="contenedor-jornadas-guardadas" style="margin-bottom: 24px;"></div>

                    <!-- Agregar nuevo día -->
                    ${!isReadOnly ? `
                        <div style="background: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 10px; padding: 20px;">
                            <h4 style="margin: 0 0 6px 0; font-size: 15px; color: #1e293b;">📅 Agregar Nuevo Día a la Bitácora</h4>
                            <p style="margin: 0 0 16px 0; font-size: 13px; color: #64748b;">Selecciona el día de la gira que deseas registrar. Se creará una plantilla vacía para todo el Crew activo.</p>
                            
                            <div style="display: flex; gap: 16px; align-items: center; flex-wrap: wrap;">
                                <div>
                                    <label class="op-form-label">Selecciona la fecha:</label>
                                    <input type="date" id="input-nueva-fecha-gira" value="${hoyStr}" class="op-input" style="width: 220px; background: white;">
                                </div>
                                <div style="margin-top: 22px;">
                                    <button type="button" onclick="crearNuevoDiaGira(${idEvento})" style="background: #ef4444; color: white; border: none; padding: 10px 20px; border-radius: 6px; font-weight: 700; cursor: pointer; display: flex; align-items: center; gap: 6px; box-shadow: 0 2px 4px rgba(239,68,68,0.2);">
                                        ➕ Crear Bitácora para esta fecha
                                    </button>
                                </div>
                            </div>
                        </div>
                    ` : ''}
                </div>
            </div>



            <!-- 🖊️ 4. AUTORIZACIONES -->
            <div class="op-section-card">
                <h3 class="op-section-title">🖊️ Autorizaciones</h3>

                <div style="display: grid; grid-template-columns: 1fr 1fr 1fr 1fr; gap: 16px;">
                    <div>
                        <label class="op-form-label">📝 Elaboró:</label>
                        <select id="op_elabora" class="op-select" ${dis}>
                            ${buildOptions(cats.staff_vpro, defElabora, true)}
                        </select>
                    </div>
                    <div>
                        <label class="op-form-label">🔀 Coordina:</label>
                        <select id="op_coordina" class="op-select" ${dis}>
                            ${buildOptions(cats.staff_vpro, defCoordina, true)}
                        </select>
                    </div>
                    <div>
                        <label class="op-form-label">👔 Organiza:</label>
                        <select id="op_organiza" class="op-select" ${dis}>
                            ${buildOptions(cats.staff_vpro, defOrganiza, true)}
                        </select>
                    </div>
                    <div>
                        <label class="op-form-label">✅ Vo.Bo.:</label>
                        <select id="op_vobo" class="op-select" ${dis}>
                            ${buildOptions(cats.staff_vpro, defVobo, true)}
                        </select>
                    </div>
                </div>
            </div>



            <!-- 💾 BOTÓN GUARDAR MAESTRO, ACCIÓN DE HISTORIAL E IMPRESIÓN OFICIAL -->
            <div style="margin-top: 14px; margin-bottom: 20px; display: flex; gap: 14px; flex-wrap: wrap;">
                ${!isReadOnly ? `
                    <button type="submit" style="flex: 2; min-width: 220px; background: #ef4444; color: white; border: none; padding: 16px; border-radius: 8px; font-weight: 700; font-size: 15px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; box-shadow: 0 4px 6px -1px rgba(239, 68, 68, 0.25); transition: background 0.2s;">
                        💾 GUARDAR CAMBIOS ORDEN
                    </button>
                    ${esCoordinadorOAdmin && data.folio ? `
                        <button type="button" onclick="mandarOPAlHistorial('${folioVal}')" style="flex: 1; min-width: 180px; background: #334155; color: white; border: none; padding: 16px 20px; border-radius: 8px; font-weight: 700; font-size: 14.5px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; box-shadow: 0 4px 6px -1px rgba(51, 65, 85, 0.25); transition: background 0.2s;">
                            <i class="ph ph-archive-box"></i> 📦 Mandar al Historial
                        </button>
                    ` : ''}
                ` : ''}
                ${(data.folio || !isReadOnly) ? `
                    <button type="button" onclick="imprimirOrdenProduccionActual('${folioVal}')" style="flex: 1; min-width: 200px; background: #0078d4; color: white; border: none; padding: 16px 22px; border-radius: 8px; font-weight: 700; font-size: 15px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; box-shadow: 0 4px 10px rgba(0, 120, 212, 0.3); transition: background 0.2s;">
                        <i class="ph ph-printer" style="font-size: 20px;"></i> 🖨️ Imprimir esta OP
                    </button>
                ` : ''}
                ${isReadOnly ? `
                    ${(data.chat_cerrado || data.tiene_chat || data.tiene_chat_historial || data.chat_historial || (data.total_mensajes_chat && data.total_mensajes_chat > 0)) ? `
                        <button type="button" onclick="solicitarDesellarChat('${folioVal}')" style="flex: 1; min-width: 220px; background: #1e293b; color: #f8fafc; border: 1px solid #334155; padding: 16px 22px; border-radius: 8px; font-weight: 700; font-size: 14.5px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.15); transition: background 0.2s;" title="Consultar bitácora oficial sellada (Solo lectura)">
                            <i class="ph ph-lock-key" style="font-size: 19px; color: #fbbf24;"></i> 🔒 Abrir Chat Sellado
                        </button>
                    ` : `
                        <div style="flex: 1; min-width: 220px; background: #f8fafc; color: #94a3b8; border: 1.5px dashed #cbd5e1; padding: 16px 20px; border-radius: 8px; font-weight: 600; font-size: 13.5px; display: flex; align-items: center; justify-content: center; gap: 8px; user-select: none;" title="Esta orden de producción no cuenta con mensajes de chat registrados">
                            <i class="ph ph-chat-slash" style="font-size: 18px; color: #94a3b8;"></i> Chat sin contenido en esta OP
                        </div>
                    `}
                ` : ''}
            </div>
        </form>
    `;
}


function abrirChatOPParaFolio(folio) {
    if (!folio) return;
    let url = `chat.html?folio=${encodeURIComponent(folio)}`;
    if (typeof usuarioLogueado !== 'undefined' && usuarioLogueado && usuarioLogueado.id_empleado) {
        try { localStorage.setItem('vpro_chat_usuario', JSON.stringify(usuarioLogueado)); } catch (e) {}
        url += `&u=${encodeURIComponent(usuarioLogueado.id_empleado)}`;
    }
    window.open(url, '_blank');
}
