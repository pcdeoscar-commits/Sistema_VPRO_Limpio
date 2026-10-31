// ==============================================================================
// MÓDULO: gastos.js
// 8. Reporte de gastos y conciliación financiera
// Líneas originales: 4457–5057 de script.js
// ==============================================================================

// ==========================================
// 8. MÓDULO REPORTE DE GASTOS
// ==========================================
let foliosPendientesGastosCache = [];
let eventoSeleccionadoGasto = null;
let vehiculosGastoCache = [];
let filasDiasGastos = [];
let informeAuditoriaSeleccionado = null;
let informesAuditoriaCache = [];

function cambiarPestanaGastos(tab) {
    const btnCaptura = document.getElementById("tab-gastos-btn-captura");
    const btnAuditoria = document.getElementById("tab-gastos-btn-auditoria");
    const viewCaptura = document.getElementById("subvista-gastos-captura");
    const viewAuditoria = document.getElementById("subvista-gastos-auditoria");

    if (tab === 'captura') {
        if (btnCaptura) { btnCaptura.style.background = '#0f172a'; btnCaptura.style.color = 'white'; btnCaptura.style.border = 'none'; }
        if (btnAuditoria) { btnAuditoria.style.background = '#f1f5f9'; btnAuditoria.style.color = '#475569'; btnAuditoria.style.border = '1px solid #cbd5e1'; }
        if (viewCaptura) viewCaptura.style.display = 'block';
        if (viewAuditoria) viewAuditoria.style.display = 'none';
    } else {
        if (btnAuditoria) { btnAuditoria.style.background = '#0f172a'; btnAuditoria.style.color = 'white'; btnAuditoria.style.border = 'none'; }
        if (btnCaptura) { btnCaptura.style.background = '#f1f5f9'; btnCaptura.style.color = '#475569'; btnCaptura.style.border = '1px solid #cbd5e1'; }
        if (viewCaptura) viewCaptura.style.display = 'none';
        if (viewAuditoria) viewAuditoria.style.display = 'block';
    }
}

async function cargarModuloGastos() {
    if (typeof esUsuarioAutorizadoGastos === 'function' && !esUsuarioAutorizadoGastos()) {
        console.warn("Acceso denegado a cargarModuloGastos: Usuario no autorizado.");
        return;
    }
    try {
        const [resPend, resFolios, resInformes] = await Promise.all([
            fetch(`${API_URL}/api/gastos/pendientes/conteo`),
            fetch(`${API_URL}/api/gastos/folios-pendientes`),
            fetch(`${API_URL}/api/gastos/informes-auditoria`)
        ]);

        if (resPend.ok) {
            const conteo = await resPend.json();
            const num = (typeof conteo === 'number') ? conteo : (conteo?.conteo || 0);
            const kpiPend = document.getElementById("kpi-gastos-pendientes");
            if (kpiPend) kpiPend.innerText = num;
            const badgeGastos = document.getElementById("badge-gastos");
            if (badgeGastos) badgeGastos.innerText = num;
        }

        if (resFolios.ok) {
            foliosPendientesGastosCache = await resFolios.json();
            const selFolio = document.getElementById("sel-gastos-folio-op");
            if (selFolio) {
                const miNombre = (usuarioLogueado?.nombre_completo || "").trim().toLowerCase();
                
                // Dividir OPs: Mis OPs asignadas (donde soy el productor) vs Otras OPs
                const misOps = [];
                const otrasOps = [];

                foliosPendientesGastosCache.forEach(f => {
                    const prod = (f.productor || "").trim().toLowerCase();
                    if (miNombre && prod && (prod.includes(miNombre) || miNombre.includes(prod))) {
                        misOps.push(f);
                    } else {
                        otrasOps.push(f);
                    }
                });

                let optionsHtml = '<option value="">--- Seleccionar Folio Pendiente ---</option>';
                
                if (misOps.length > 0) {
                    optionsHtml += `<optgroup label="⭐ MIS ÓRDENES DE PRODUCCIÓN ASIGNADAS (${misOps.length})">`;
                    misOps.forEach(f => {
                        optionsHtml += `<option value="${f.id_evento}">OP-${f.id_evento} | ${f.nombre_evento} (${f.cliente}) - Productor: ${f.productor}</option>`;
                    });
                    optionsHtml += `</optgroup>`;
                }

                if (otrasOps.length > 0) {
                    const labelGrupo = misOps.length > 0 ? "OTRAS ÓRDENES PENDIENTES DE GASTOS" : "ÓRDENES DE PRODUCCIÓN PENDIENTES";
                    optionsHtml += `<optgroup label="📋 ${labelGrupo} (${otrasOps.length})">`;
                    otrasOps.forEach(f => {
                        optionsHtml += `<option value="${f.id_evento}">OP-${f.id_evento} | ${f.nombre_evento} (${f.cliente}) - Productor: ${f.productor || 'No asignado'}</option>`;
                    });
                    optionsHtml += `</optgroup>`;
                }

                selFolio.innerHTML = optionsHtml;
            }
        }

        if (resInformes.ok) {
            informesAuditoriaCache = await resInformes.json();
            const elAuditados = document.getElementById("kpi-gastos-auditados");
            const auditadosCount = informesAuditoriaCache.filter(i => i.revisado).length;
            if (elAuditados) elAuditados.innerText = auditadosCount;
            renderizarTablaGastosAuditoria(informesAuditoriaCache);
        }
    } catch (err) {
        console.error("Error al cargar módulo de gastos:", err);
    }
}

function cargarReporteGastos() {
    cargarModuloGastos();
}

async function seleccionarFolioParaGastos(folioId) {
    const formPanel = document.getElementById("gastos-panel-captura-formulario");
    if (!folioId) {
        if (formPanel) formPanel.style.display = "none";
        return;
    }

    try {
        const res = await fetch(`${API_URL}/api/gastos/evento/${folioId}`);
        if (!res.ok) throw new Error("No se pudo obtener datos del evento.");

        const evData = await res.json();
        eventoSeleccionadoGasto = { id_evento: folioId, ...evData };

        const elFolio = document.getElementById("gastos-info-folio");
        const elCliente = document.getElementById("gastos-info-cliente");
        const elEvento = document.getElementById("gastos-info-evento");
        const elProductor = document.getElementById("gastos-info-productor");
        const elEstimado = document.getElementById("gastos-info-estimado");
        const elEmpRinde = document.getElementById("gastos-input-empleado");
        const elDepto = document.getElementById("gastos-input-depto");
        const elDesde = document.getElementById("gastos-input-desde");
        const elHasta = document.getElementById("gastos-input-hasta");

        if (elFolio) elFolio.innerText = `OP-${folioId}`;
        if (elCliente) elCliente.innerText = evData.cliente || "--";
        if (elEvento) elEvento.innerText = evData.nombre_evento || "--";
        if (elProductor) elProductor.innerText = evData.productor_responsable || "No asignado";
        if (elEstimado) {
            const estNum = Number(evData.estimado_gasto || 0);
            elEstimado.innerText = `$ ${estNum.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
        }
        if (elEmpRinde) elEmpRinde.value = evData.responsable_gastos || evData.productor_responsable || usuarioLogueado?.nombre_completo || "Productor VPRO";
        if (elDepto) elDepto.value = usuarioLogueado?.depto || "PRODUCCION";

        const hoy = new Date().toISOString().substring(0, 10);
        const fIni = evData.fec_del_evento ? String(evData.fec_del_evento).substring(0, 10) : (evData.fec_de_instalacion ? String(evData.fec_de_instalacion).substring(0, 10) : hoy);
        const fFin = evData.fec_fin_evento ? String(evData.fec_fin_evento).substring(0, 10) : (evData.fec_del_evento ? String(evData.fec_del_evento).substring(0, 10) : hoy);
        if (elDesde) elDesde.value = fIni;
        if (elHasta) elHasta.value = fFin;
        recalcularDiasGastos();

        // Cargar autos y sus últimos odómetros
        let autos = [];
        if (Array.isArray(evData.carros_usados_op)) {
            autos = evData.carros_usados_op;
        } else if (typeof evData.carros_usados_op === 'string') {
            try {
                autos = JSON.parse(evData.carros_usados_op.replace(/'/g, '"'));
            } catch (e) {
                const limpio = evData.carros_usados_op.replace(/[{}\"\']/g, '').trim();
                autos = limpio ? limpio.split(',').map(s => s.trim()) : [];
            }
        }
        autos = autos.filter(Boolean);
        if (autos.length === 0) autos = ["Unidad General"];

        vehiculosGastoCache = autos;
        const contOdometros = document.getElementById("gastos-odometros-lista");
        if (contOdometros) {
            contOdometros.innerHTML = '<p style="color: var(--text-muted);">Consultando odómetros iniciales...</p>';
            const cardsHtml = await Promise.all(autos.map(async (auto, idx) => {
                let ultKm = 0;
                try {
                    const resKm = await fetch(`${API_URL}/api/gastos/ultimo-km/${encodeURIComponent(auto)}`);
                    if (resKm.ok) {
                        const dataKm = await resKm.json();
                        ultKm = dataKm.ultimo_km || 0;
                    }
                } catch (e) {}

                return `
                    <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 10px; padding: 14px;">
                        <div style="font-size: 13px; font-weight: 700; color: #0f172a; margin-bottom: 8px;">🚙 ${auto}</div>
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
                            <div>
                                <label style="font-size: 11px; color: #64748b; font-weight: 600;">KM Inicial:</label>
                                <input type="number" id="odo-ini-${idx}" value="${ultKm}" min="0" style="width: 100%; padding: 6px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 12.5px;">
                            </div>
                            <div>
                                <label style="font-size: 11px; color: #64748b; font-weight: 600;">KM Final:</label>
                                <input type="number" id="odo-fin-${idx}" value="${ultKm}" min="0" style="width: 100%; padding: 6px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 12.5px;">
                            </div>
                        </div>
                    </div>
                `;
            }));
            contOdometros.innerHTML = cardsHtml.join("");
        }

        recalcularDiasGastos();
        if (formPanel) formPanel.style.display = "block";

        // 🔒 Validar si el usuario logueado es el Productor Responsable o Responsable de Gastos de la OP
        const miNombreNorm = (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "").trim().toLowerCase()
            .normalize("NFD").replace(/[\u0300-\u036f]/g, "");
        const prodOpNorm = (evData.responsable_gastos || evData.productor_responsable || "").trim().toLowerCase()
            .normalize("NFD").replace(/[\u0300-\u036f]/g, "");

        const esElAsignado = miNombreNorm && prodOpNorm && (prodOpNorm.includes(miNombreNorm) || miNombreNorm.includes(prodOpNorm));

        const btnEnviarGasto = document.getElementById("btn-guardar-informe-gastos") || document.querySelector('button[onclick*="guardarInformeGastosProductor"]');
        const avisoRestriccion = document.getElementById("aviso-restriccion-productor-gasto");

        if (!esElAsignado) {
            if (btnEnviarGasto) {
                btnEnviarGasto.disabled = true;
                btnEnviarGasto.style.opacity = "0.45";
                btnEnviarGasto.style.cursor = "not-allowed";
                btnEnviarGasto.title = "Solo el Productor Responsable o Responsable de Gastos asignado puede elaborar y enviar este reporte.";
            }
            if (avisoRestriccion) {
                avisoRestriccion.style.display = "block";
                avisoRestriccion.innerHTML = `<i class="ph ph-shield-warning" style="font-size: 18px; vertical-align: middle;"></i> <b>Modo de Consulta Restringido:</b> Esta OP está asignada al Productor <b>${evData.productor_responsable || 'No asignado'}</b>. Por estrictas políticas de trazabilidad financiera, únicamente el productor asignado puede elaborar y remitir este reporte de gastos.`;
            }
        } else {
            if (btnEnviarGasto) {
                btnEnviarGasto.disabled = false;
                btnEnviarGasto.style.opacity = "1";
                btnEnviarGasto.style.cursor = "pointer";
                btnEnviarGasto.removeAttribute("title");
            }
            if (avisoRestriccion) {
                avisoRestriccion.style.display = "none";
            }
        }
    } catch (e) {
        alert(`❌ Error al cargar datos del evento: ${e.message}`);
    }
}

function recalcularDiasGastos() {
    const fDesdeStr = document.getElementById("gastos-input-desde")?.value;
    const fHastaStr = document.getElementById("gastos-input-hasta")?.value;
    if (!fDesdeStr || !fHastaStr) return;

    const f1 = new Date(fDesdeStr);
    const f2 = new Date(fHastaStr);
    const diffDias = Math.max(1, Math.floor((f2 - f1) / (1000 * 60 * 60 * 24)) + 1);

    filasDiasGastos = [];
    const tbody = document.getElementById("tabla-gastos-dias-body");
    if (!tbody) return;

    let html = "";
    for (let i = 1; i <= Math.min(diffDias, 30); i++) {
        const fechaDia = new Date(f1);
        fechaDia.setDate(f1.getDate() + (i - 1));
        const fechaIso = fechaDia.toISOString().substring(0, 10);

        html += `
            <tr data-dia="${i}">
                <td style="font-weight: 700; text-align: center;">Día ${i}</td>
                <td><input type="date" value="${fechaIso}" style="border: 1px solid #cbd5e1; border-radius: 4px; padding: 4px; font-size: 12px;"></td>
                <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-hotel" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
                <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-transp" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
                <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-combust" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
                <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-casetas" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
                <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-desay" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
                <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-comida" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
                <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-cenas" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
                <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-varios" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
                <td class="total-dia-cell" style="font-weight: 700; text-align: right; color: #0f172a;">$0.00</td>
            </tr>
        `;
    }
    tbody.innerHTML = html;
    recalcularTotalesGastos();
}

function agregarFilaDiaGasto() {
    const tbody = document.getElementById("tabla-gastos-dias-body");
    if (!tbody) return;
    const numDia = tbody.querySelectorAll("tr").length + 1;
    const hoyIso = new Date().toISOString().substring(0, 10);

    const tr = document.createElement("tr");
    tr.setAttribute("data-dia", numDia);
    tr.innerHTML = `
        <td style="font-weight: 700; text-align: center;">Día ${numDia}</td>
        <td><input type="date" value="${hoyIso}" style="border: 1px solid #cbd5e1; border-radius: 4px; padding: 4px; font-size: 12px;"></td>
        <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-hotel" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
        <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-transp" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
        <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-combust" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
        <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-casetas" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
        <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-desay" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
        <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-comida" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
        <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-cenas" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
        <td><input type="number" min="0" step="50" value="0.00" oninput="recalcularTotalesGastos()" class="gasto-cell gasto-varios" style="width: 75px; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;"></td>
        <td class="total-dia-cell" style="font-weight: 700; text-align: right; color: #0f172a;">$0.00</td>
    `;
    tbody.appendChild(tr);
    recalcularTotalesGastos();
}

function recalcularTotalesGastos() {
    const rows = document.querySelectorAll("#tabla-gastos-dias-body tr");
    let totHotel = 0, totTransp = 0, totCombust = 0, totCasetas = 0, totDesay = 0, totComida = 0, totCenas = 0, totVarios = 0;

    rows.forEach(tr => {
        const val = (cls) => parseFloat(tr.querySelector(`.${cls}`)?.value || 0);
        const h = val('gasto-hotel');
        const t = val('gasto-transp');
        const c = val('gasto-combust');
        const cs = val('gasto-casetas');
        const d = val('gasto-desay');
        const cm = val('gasto-comida');
        const cn = val('gasto-cenas');
        const v = val('gasto-varios');

        const totalDia = h + t + c + cs + d + cm + cn + v;
        const celTotal = tr.querySelector('.total-dia-cell');
        if (celTotal) celTotal.innerText = `$${totalDia.toLocaleString('es-MX', { minimumFractionDigits: 2 })}`;

        totHotel += h; totTransp += t; totCombust += c; totCasetas += cs;
        totDesay += d; totComida += cm; totCenas += cn; totVarios += v;
    });

    const granTotal = totHotel + totTransp + totCombust + totCasetas + totDesay + totComida + totCenas + totVarios;

    const fmt = n => `$${n.toLocaleString('es-MX', { minimumFractionDigits: 2 })}`;
    if (document.getElementById("tot-gasto-hotel")) document.getElementById("tot-gasto-hotel").innerText = fmt(totHotel);
    if (document.getElementById("tot-gasto-transp")) document.getElementById("tot-gasto-transp").innerText = fmt(totTransp);
    if (document.getElementById("tot-gasto-combust")) document.getElementById("tot-gasto-combust").innerText = fmt(totCombust);
    if (document.getElementById("tot-gasto-casetas")) document.getElementById("tot-gasto-casetas").innerText = fmt(totCasetas);
    if (document.getElementById("tot-gasto-desay")) document.getElementById("tot-gasto-desay").innerText = fmt(totDesay);
    if (document.getElementById("tot-gasto-comida")) document.getElementById("tot-gasto-comida").innerText = fmt(totComida);
    if (document.getElementById("tot-gasto-cenas")) document.getElementById("tot-gasto-cenas").innerText = fmt(totCenas);
    if (document.getElementById("tot-gasto-varios")) document.getElementById("tot-gasto-varios").innerText = fmt(totVarios);
    if (document.getElementById("tot-gasto-gran-total")) document.getElementById("tot-gasto-gran-total").innerText = fmt(granTotal);

    // Resumen y remanente
    const entregado = parseFloat(document.getElementById("gastos-input-entregado")?.value || 0);
    const remanente = entregado - granTotal;

    if (document.getElementById("resumen-gasto-entregado")) document.getElementById("resumen-gasto-entregado").innerText = fmt(entregado);
    if (document.getElementById("resumen-gasto-subtotal")) document.getElementById("resumen-gasto-subtotal").innerText = fmt(granTotal);

    const elRemanente = document.getElementById("resumen-gasto-remanente");
    const cardRemanente = document.getElementById("card-gasto-remanente");
    const lblRemanente = document.getElementById("lbl-gasto-remanente");

    if (elRemanente) elRemanente.innerText = fmt(Math.abs(remanente));
    if (cardRemanente && lblRemanente) {
        if (remanente >= 0) {
            cardRemanente.style.background = "#dcfce7";
            cardRemanente.style.borderColor = "#86efac";
            if (elRemanente) elRemanente.style.color = "#15803d";
            lblRemanente.style.color = "#166534";
            lblRemanente.innerText = "Remanente a Devolver a VPRO";
        } else {
            cardRemanente.style.background = "#fee2e2";
            cardRemanente.style.borderColor = "#fca5a5";
            if (elRemanente) elRemanente.style.color = "#b91c1c";
            lblRemanente.style.color = "#991b1b";
            lblRemanente.innerText = "Saldo a Favor del Empleado (Reembolso)";
        }
    }
}

async function guardarInformeGastosProductor() {
    if (typeof esUsuarioAutorizadoGastos === 'function' && !esUsuarioAutorizadoGastos()) {
        alert("⛔ Acceso Restringido: El módulo de Reporte de Gastos está reservado para Productores autorizados de VPRO.");
        return;
    }
    const folioId = eventoSeleccionadoGasto?.id_evento;
    if (!folioId) {
        alert("⚠️ No hay un evento seleccionado.");
        return;
    }

    // 🔒 REGLA ESTRICTA: Solo el Productor Responsable o el Responsable de Gastos de la OP puede elaborar este reporte
    const miNombreNorm = (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "").trim().toLowerCase()
        .normalize("NFD").replace(/[\u0300-\u036f]/g, "");
    const prodOpNorm = (eventoSeleccionadoGasto?.responsable_gastos || eventoSeleccionadoGasto?.productor_responsable || "").trim().toLowerCase()
        .normalize("NFD").replace(/[\u0300-\u036f]/g, "");

    const esElAsignado = miNombreNorm && prodOpNorm && (prodOpNorm.includes(miNombreNorm) || miNombreNorm.includes(prodOpNorm));
    if (!esElAsignado) {
        alert(`⛔ Acción no permitida: Solo el Productor Responsable o Responsable de Gastos asignado a esta OP (${eventoSeleccionadoGasto?.productor_responsable || 'No asignado'}) está facultado para elaborar y remitir este reporte.`);
        return;
    }

    const fDesde = document.getElementById("gastos-input-desde")?.value;
    const fHasta = document.getElementById("gastos-input-hasta")?.value;
    const entregado = parseFloat(document.getElementById("gastos-input-entregado")?.value || 0);
    const userId = usuarioLogueado?.id_empleado ? String(usuarioLogueado.id_empleado) : "000";
    const userDepto = usuarioLogueado?.depto || "PRODUCCION";

    // Recolectar odómetros
    let totalKmIni = 0, totalKmFin = 0;
    const vehiculoDetalle = vehiculosGastoCache.map((auto, idx) => {
        const ki = parseInt(document.getElementById(`odo-ini-${idx}`)?.value || 0);
        const kf = parseInt(document.getElementById(`odo-fin-${idx}`)?.value || 0);
        totalKmIni += ki;
        totalKmFin += kf;
        return `${auto} (${ki}-${kf})`;
    }).join(", ");

    // Recolectar filas de días
    const rows = document.querySelectorAll("#tabla-gastos-dias-body tr");
    let detalles = [];
    let subtotal = 0;

    rows.forEach(tr => {
        const diaNum = parseInt(tr.getAttribute("data-dia") || 1);
        const val = (cls) => parseFloat(tr.querySelector(`.${cls}`)?.value || 0);
        const h = val('gasto-hotel');
        const t = val('gasto-transp');
        const c = val('gasto-combust');
        const cs = val('gasto-casetas');
        const d = val('gasto-desay');
        const cm = val('gasto-comida');
        const cn = val('gasto-cenas');
        const v = val('gasto-varios');
        const totalDia = h + t + c + cs + d + cm + cn + v;
        subtotal += totalDia;

        detalles.push({
            dia_num: diaNum,
            hotel: h,
            transporte: t,
            combustible: c,
            casetas: cs,
            desayuno: d,
            comida: cm,
            cenas: cn,
            varios: v,
            total_dia: totalDia
        });
    });

    const restante = entregado - subtotal;

    const payload = {
        maestro: {
            folio_vpro: parseInt(folioId),
            id_empleado: userId,
            nombre_usuario: usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "",
            periodo_desde: fDesde,
            periodo_hasta: fHasta,
            vehiculo: vehiculoDetalle || "General",
            km_inicial: totalKmIni,
            km_final: totalKmFin,
            departamento: userDepto,
            num_personas: 1,
            subtotal: subtotal,
            monto_entregado: entregado,
            restante: restante
        },
        detalles: detalles
    };

    if (!confirm(`¿Confirmas enviar el informe de gastos por $${subtotal.toLocaleString('es-MX')} y remitirlo a Dirección?`)) {
        return;
    }

    try {
        const res = await fetch(`${API_URL}/api/gastos/guardar`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (res.ok) {
            alert("✅ ¡Informe de gastos guardado y remitido a Auditoría exitosamente!");
            document.getElementById("gastos-panel-captura-formulario").style.display = "none";
            cargarModuloGastos();
            cambiarPestanaGastos('auditoria');
        } else {
            const err = await res.text();
            alert(`❌ Error al guardar informe: ${err}`);
        }
    } catch (e) {
        alert(`❌ Error de comunicación: ${e.message}`);
    }
}

function renderizarTablaGastosAuditoria(lista) {
    const tbody = document.getElementById("tabla-gastos-body");
    if (!tbody) return;

    if (lista.length === 0) {
        tbody.innerHTML = `<tr><td colspan="6" style="text-align: center; padding: 24px; color: #166534; font-weight: 500;">✅ No hay informes de gastos registrados.</td></tr>`;
        return;
    }

    tbody.innerHTML = lista.map(inf => {
        const revisado = Boolean(inf.revisado);
        const stBadge = revisado 
            ? `<span style="background: #dcfce7; color: #166534; padding: 3px 8px; border-radius: 6px; font-weight: 700; font-size: 11px;">✅ AUDITADO</span>`
            : `<span style="background: #fef3c7; color: #92400e; padding: 3px 8px; border-radius: 6px; font-weight: 700; font-size: 11px;">⏳ PENDIENTE</span>`;

        return `
            <tr>
                <td style="font-weight: 700;">#${inf.id_informe}</td>
                <td><b>OP-${inf.folio_vpro}</b></td>
                <td style="color: #0f172a; font-weight: 500;">${inf.nombre_evento || 'Evento'}</td>
                <td>${inf.nombre_empleado || 'Responsable'}</td>
                <td>${stBadge}</td>
                <td>
                    <button onclick="abrirModalGastoExpediente(${inf.id_informe})" style="background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; padding: 5px 12px; border-radius: 6px; font-size: 11.5px; font-weight: 600; cursor: pointer;">
                        👁️ Ver Expediente
                    </button>
                </td>
            </tr>
        `;
    }).join("");
}

function filtrarTablaGastosAuditoria(termino) {
    const t = (termino || "").toLowerCase().trim();
    if (!t) {
        renderizarTablaGastosAuditoria(informesAuditoriaCache);
        return;
    }
    const filtrados = informesAuditoriaCache.filter(inf =>
        (inf.nombre_evento && inf.nombre_evento.toLowerCase().includes(t)) ||
        (inf.nombre_empleado && inf.nombre_empleado.toLowerCase().includes(t)) ||
        String(inf.folio_vpro).includes(t) ||
        String(inf.id_informe).includes(t)
    );
    renderizarTablaGastosAuditoria(filtrados);
}

async function abrirModalGastoExpediente(idInforme) {
    try {
        const res = await fetch(`${API_URL}/api/gastos/informe-completo/${idInforme}`);
        if (!res.ok) throw new Error("No se pudo obtener el expediente.");

        const data = await res.json();
        const m = data.maestro || {};
        const d = data.detalles || [];
        informeAuditoriaSeleccionado = idInforme;
        window.eventoActualVincular = m.id_evento;

        const titulo = document.getElementById("modal-gasto-titulo");
        if (titulo) titulo.innerHTML = `<i class="ph ph-receipt" style="color: #3b82f6;"></i> Expediente de Comprobación: #${m.id_informe} (OP-${m.folio_vpro})`;

        const cont = document.getElementById("modal-gasto-contenido");
        if (cont) {
            const btnAprobar = document.getElementById("btn-aprobar-sellar-gasto");
            if (btnAprobar) {
                btnAprobar.style.display = m.revisado ? "none" : "flex";
            }

            cont.innerHTML = `
                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 16px; margin-bottom: 20px;">
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; font-size: 13px;">
                        <div><span style="color: #64748b;">Responsable:</span> <b>${m.nombre_empleado}</b></div>
                        <div><span style="color: #64748b;">Departamento:</span> <b>${m.departamento}</b></div>
                        <div><span style="color: #64748b;">Periodo:</span> <b>${m.periodo_desde} a ${m.periodo_hasta}</b></div>
                        <div><span style="color: #64748b;">Vehículos:</span> <b>${m.vehiculo}</b></div>
                        <div><span style="color: #64748b;">Odómetros:</span> <b>${m.km_inicial} km inicial - ${m.km_final} km final</b></div>
                        <div><span style="color: #64748b;">Estado:</span> <b>${m.revisado ? '✅ AUDITADO Y SELLADO' : '⏳ PENDIENTE DE REVISIÓN'}</b></div>
                    </div>
                </div>

                <h4 style="margin: 0 0 12px 0; color: #0f172a;">📊 Desglose Diario Comprobado</h4>
                <div class="tabla-container" style="max-height: 260px; margin-bottom: 20px;">
                    <table class="tabla-vpro">
                        <thead>
                            <tr>
                                <th>Día</th>
                                <th>Hotel</th>
                                <th>Transp.</th>
                                <th>Combust.</th>
                                <th>Casetas</th>
                                <th>Desayuno</th>
                                <th>Comida</th>
                                <th>Cenas</th>
                                <th>Varios</th>
                                <th>Total Día</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${d.map(row => `
                                <tr>
                                    <td>Día ${row.dia_num}</td>
                                    <td>$${row.hotel.toFixed(2)}</td>
                                    <td>$${row.transporte.toFixed(2)}</td>
                                    <td>$${row.combustible.toFixed(2)}</td>
                                    <td>$${row.casetas.toFixed(2)}</td>
                                    <td>$${row.desayuno.toFixed(2)}</td>
                                    <td>$${row.comida.toFixed(2)}</td>
                                    <td>$${row.cenas.toFixed(2)}</td>
                                    <td>$${row.varios.toFixed(2)}</td>
                                    <td style="font-weight: 700;">$${row.total_dia.toFixed(2)}</td>
                                </tr>
                            `).join("")}
                        </tbody>
                    </table>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 14px;">
                    <div style="background: #eff6ff; padding: 14px; border-radius: 8px;">
                        <div style="font-size: 11px; color: #1e40af; font-weight: 700;">PRESUPUESTO ENTREGADO</div>
                        <div style="font-size: 20px; font-weight: 800; color: #1d4ed8; margin-top: 4px;">$${m.monto_entregado.toLocaleString('es-MX', { minimumFractionDigits: 2 })}</div>
                    </div>
                    <div style="background: #f1f5f9; padding: 14px; border-radius: 8px;">
                        <div style="font-size: 11px; color: #475569; font-weight: 700;">TOTAL GASTADO / COMPROBADO</div>
                        <div style="font-size: 20px; font-weight: 800; color: #0f172a; margin-top: 4px;">$${m.subtotal.toLocaleString('es-MX', { minimumFractionDigits: 2 })}</div>
                    </div>
                    <div style="background: ${m.restante >= 0 ? '#dcfce7' : '#fee2e2'}; padding: 14px; border-radius: 8px;">
                        <div style="font-size: 11px; color: ${m.restante >= 0 ? '#166534' : '#991b1b'}; font-weight: 700;">${m.restante >= 0 ? 'REMANENTE A DEVOLVER' : 'REEMBOLSO A FAVOR'}</div>
                        <div style="font-size: 20px; font-weight: 800; color: ${m.restante >= 0 ? '#15803d' : '#b91c1c'}; margin-top: 4px;">$${Math.abs(m.restante).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</div>
                    </div>
                </div>
            `;
        }

        const modal = document.getElementById("modal-gastos-expediente");
        if (modal) modal.style.display = "flex";
    } catch (e) {
        alert(`❌ Error al consultar expediente: ${e.message}`);
    }
}

function cerrarModalGastoExpediente() {
    const modal = document.getElementById("modal-gastos-expediente");
    if (modal) modal.style.display = "none";
}

async function ejecutarAprobacionGasto() {
    if (!informeAuditoriaSeleccionado) return;

    if (!confirm("¿Confirmas aprobar y sellar este informe de gastos? La Orden de Producción será transferida a la Bóveda Histórica.")) {
        return;
    }

    try {
        const res = await fetch(`${API_URL}/api/gastos/revisar/${informeAuditoriaSeleccionado}`, {
            method: "POST"
        });

        if (res.ok) {
            alert("✅ ¡Informe de gastos sellado y aprobado exitosamente! Evento archivado en Bóveda Histórica.");
            cerrarModalGastoExpediente();
            cargarModuloGastos();
        } else {
            const err = await res.text();
            alert(`❌ Error al aprobar informe: ${err}`);
        }
    } catch (e) {
        alert(`❌ Error de comunicación: ${e.message}`);
    }
}

