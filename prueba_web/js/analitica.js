// ==============================================================================
// MÓDULO: analitica.js
// 16. Analítica y KPIs
// Líneas originales: 10827–11102 de script.js
// ==============================================================================

// ==========================================
// 16. MÓDULO ANALÍTICA Y KPIS
// ==========================================
let chartAnDeptosInstance = null;
let chartAnFlotaInstance = null;
let chartAnClientesInstance = null;
let chartAnOpsMesInstance = null;
let chartAnEmpleadosInstance = null;
let chartAnEfectividadInstance = null;

function cambiarPestanaAnalitica(tab) {
    const tabs = ['finanzas', 'comercial', 'operaciones', 'inventario'];
    tabs.forEach(t => {
        const btn = document.getElementById(`tab-an-btn-${t}`);
        const view = document.getElementById(`subvista-an-${t}`);
        if (btn && view) {
            if (t === tab) {
                btn.style.background = '#0f172a';
                btn.style.color = 'white';
                btn.style.border = 'none';
                view.style.display = 'block';
            } else {
                btn.style.background = '#f1f5f9';
                btn.style.color = '#475569';
                btn.style.border = '1px solid #cbd5e1';
                view.style.display = 'none';
            }
        }
    });
    const panelExtra = document.getElementById('an-panel-rrhh-equipos');
    if (panelExtra) {
        panelExtra.style.display = tab === 'inventario' ? 'none' : 'grid';
    }
    if (tab === 'inventario') {
        cargarUsoInventarioCEO();
    }
}

async function cargarModuloAnalitica() {
    const elDesde = document.getElementById("filtro-analitica-desde");
    const elHasta = document.getElementById("filtro-analitica-hasta");

    const hoy = new Date();
    const hace30d = new Date();
    hace30d.setDate(hoy.getDate() - 30);

    if (elDesde && !elDesde.value) elDesde.value = hace30d.toISOString().substring(0, 10);
    if (elHasta && !elHasta.value) elHasta.value = hoy.toISOString().substring(0, 10);

    const fIni = elDesde ? elDesde.value : "";
    const fFin = elHasta ? elHasta.value : "";

    try {
        const [res, resAv] = await Promise.all([
            fetch(`${API_URL}/api/dashboard/resumen?fecha_inicio=${fIni}&fecha_fin=${fFin}`),
            fetch(`${API_URL}/api/dashboard/estadisticas-avanzadas?fecha_inicio=${fIni}&fecha_fin=${fFin}`)
        ]);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);

        const data = await res.json();
        const fin = data.finanzas || {};
        const com = data.comercial || {};
        const op = data.operaciones || {};

        // 1. FINANZAS
        const kpiGasto = document.getElementById("kpi-an-gasto-mes");
        const kpiDesglose = document.getElementById("kpi-an-gasto-desglose");
        const kpiEqDan = document.getElementById("kpi-an-equipos-danados");
        const kpiFlota = document.getElementById("kpi-an-flota-taller");
        const kpiSeg = document.getElementById("kpi-an-seguros-vencer");

        if (kpiGasto) kpiGasto.innerText = `$${Number(fin.gasto_mes || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}`;
        if (kpiDesglose) {
            kpiDesglose.innerText = `Operación: $${Number(fin.gasto_operacion || 0).toLocaleString('es-MX', { minimumFractionDigits: 0 })} · Taller: $${Number(fin.gasto_reparaciones || 0).toLocaleString('es-MX', { minimumFractionDigits: 0 })}`;
        }

        if (resAv && resAv.ok) {
            const av = await resAv.json();
            renderEstadisticasAvanzadasFase3(av);
        }
        if (kpiEqDan) kpiEqDan.innerText = fin.equipos_danados || 0;
        if (kpiFlota) kpiFlota.innerText = fin.flota_taller || 0;
        if (kpiSeg) kpiSeg.innerText = fin.seguros_vencer || 0;

        renderGraficaDeptosDanos(fin.deptos_danos || []);
        renderGraficaFlotaFallas(fin.estado_flota || []);

        // 2. COMERCIAL
        const kpiOps = document.getElementById("kpi-an-ops-mes");
        const kpiCli = document.getElementById("kpi-an-cliente-top");
        const kpiProv = document.getElementById("kpi-an-proveedores-activos");

        if (kpiOps) kpiOps.innerText = com.ops_mes || 0;
        if (kpiCli) kpiCli.innerText = com.cliente_top || "--";
        if (kpiProv) kpiProv.innerText = com.proveedores_activos || 0;

        renderGraficaTopClientes(com.top_clientes || []);
        renderGraficaOpsMes(com.ops_por_mes || []);

        // 3. OPERACIONES
        const kpiTasa = document.getElementById("kpi-an-tasa-incidencias");
        const kpiLog = document.getElementById("kpi-an-logistica-tiempo");
        const kpiEmp = document.getElementById("kpi-an-emp-top");

        if (kpiTasa) kpiTasa.innerText = `${op.tasa_incidencias || 0}%`;
        if (kpiLog) kpiLog.innerText = `${op.logistica_tiempo || 100}%`;
        if (kpiEmp) kpiEmp.innerText = op.empleado_top || "--";

        renderGraficaTopEmpleados(op.top_empleados || []);
        renderGraficaEfectividad(op.efectividad_checkouts || []);
    } catch (e) {
        console.error("Error al cargar analítica y KPIs:", e);
    }
}

function renderGraficaDeptosDanos(deptos) {
    const canvas = document.getElementById("chart-an-deptos-danos");
    if (!canvas || typeof Chart === 'undefined') return;
    if (chartAnDeptosInstance) chartAnDeptosInstance.destroy();

    const labels = deptos.map(d => d.depto || 'General');
    const values = deptos.map(d => d.total || 0);

    chartAnDeptosInstance = new Chart(canvas, {
        type: 'doughnut',
        data: {
            labels: labels.length ? labels : ['Sin daños'],
            datasets: [{
                data: values.length ? values : [1],
                backgroundColor: ['#ef4444', '#f59e0b', '#3b82f6', '#10b981', '#8b5cf6', '#ec4899']
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'bottom' }
            }
        }
    });
}

function renderGraficaFlotaFallas(flota) {
    const canvas = document.getElementById("chart-an-flota-fallas");
    if (!canvas || typeof Chart === 'undefined') return;
    if (chartAnFlotaInstance) chartAnFlotaInstance.destroy();

    const fallas = flota.filter(f => {
        const t = String(f.estado || "").toLowerCase();
        return !t.includes("excelente") && !t.includes("ok") && t !== "e c" && t !== "ec";
    });

    const labels = fallas.map(f => `${f.num_control} (${f.marca})`);
    const values = fallas.map(() => 1);

    chartAnFlotaInstance = new Chart(canvas, {
        type: 'bar',
        data: {
            labels: labels.length ? labels : ['Flota Operativa al 100%'],
            datasets: [{
                label: 'Unidades',
                data: values.length ? values : [0],
                backgroundColor: 'rgba(245, 158, 11, 0.85)',
                borderColor: '#d97706',
                borderWidth: 1.5,
                borderRadius: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
        }
    });
}

function renderGraficaTopClientes(clientes) {
    const canvas = document.getElementById("chart-an-top-clientes");
    if (!canvas || typeof Chart === 'undefined') return;
    if (chartAnClientesInstance) chartAnClientesInstance.destroy();

    const labels = clientes.map(c => c.cliente || 'Desconocido');
    const values = clientes.map(c => c.total || 0);

    chartAnClientesInstance = new Chart(canvas, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Eventos Realizados',
                data: values,
                backgroundColor: 'rgba(16, 185, 129, 0.85)',
                borderColor: '#059669',
                borderWidth: 1.5,
                borderRadius: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: { y: { beginAtZero: true } }
        }
    });
}

function renderGraficaOpsMes(ops) {
    const canvas = document.getElementById("chart-an-ops-mes");
    if (!canvas || typeof Chart === 'undefined') return;
    if (chartAnOpsMesInstance) chartAnOpsMesInstance.destroy();

    const labels = ops.map(o => o.mes || '');
    const values = ops.map(o => o.total || 0);

    chartAnOpsMesInstance = new Chart(canvas, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Órdenes de Producción',
                data: values,
                borderColor: '#8b5cf6',
                backgroundColor: 'rgba(139, 92, 246, 0.15)',
                tension: 0.3,
                fill: true,
                pointRadius: 5
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: { y: { beginAtZero: true } }
        }
    });
}

function renderGraficaTopEmpleados(empleados) {
    const canvas = document.getElementById("chart-an-top-empleados");
    if (!canvas || typeof Chart === 'undefined') return;
    if (chartAnEmpleadosInstance) chartAnEmpleadosInstance.destroy();

    const labels = empleados.map(e => e.empleado || '');
    const values = empleados.map(e => e.total || 0);

    chartAnEmpleadosInstance = new Chart(canvas, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Checkouts Asignados',
                data: values,
                backgroundColor: 'rgba(59, 130, 246, 0.85)',
                borderColor: '#2563eb',
                borderWidth: 1.5,
                borderRadius: 6
            }]
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: { x: { beginAtZero: true } }
        }
    });
}

function renderGraficaEfectividad(efectividad) {
    const canvas = document.getElementById("chart-an-efectividad");
    if (!canvas || typeof Chart === 'undefined') return;
    if (chartAnEfectividadInstance) chartAnEfectividadInstance.destroy();

    const labels = efectividad.map(e => e.estado || '');
    const values = efectividad.map(e => e.total || 0);

    chartAnEfectividadInstance = new Chart(canvas, {
        type: 'doughnut',
        data: {
            labels: labels.length ? labels : ['Sin datos'],
            datasets: [{
                data: values.length ? values : [1],
                backgroundColor: ['#10b981', '#ef4444']
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { position: 'bottom' } }
        }
    });
}

function renderEstadisticasAvanzadasFase3(av) {
    // 1. Tabla Rentabilidad / Gastos por OP
    const tbodyRent = document.getElementById("tbody-an-rentabilidad-ops");
    if (tbodyRent) {
        const ops = av.ops_gastos || [];
        if (ops.length === 0) {
            tbodyRent.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#64748b;">Sin gastos comprobados en el rango seleccionado.</td></tr>';
        } else {
            tbodyRent.innerHTML = ops.map(o => `
                <tr>
                    <td style="font-weight:700; color:#1e40af;">OP-${o.folio}</td>
                    <td>${o.nombre_evento}</td>
                    <td>${o.cliente}</td>
                    <td>${o.fecha}</td>
                    <td>$${Number(o.viatico_entregado || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</td>
                    <td style="font-weight:700; color:#047857;">$${Number(o.gasto_comprobado || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</td>
                </tr>
            `).join('');
        }
    }

    // 2. Resumen RRHH
    const contRrhh = document.getElementById("an-rrhh-resumen");
    if (contRrhh && av.rrhh) {
        const r = av.rrhh;
        const tot = (r.a_tiempo || 0) + (r.retardos || 0);
        const pctPunt = tot > 0 ? ((r.a_tiempo / tot) * 100).toFixed(1) : "100.0";
        const deptosHtml = (r.por_depto || []).slice(0, 6).map(d => `
            <div style="display:flex; justify-content:space-between; padding:6px 0; border-bottom:1px solid #f1f5f9;">
                <span style="font-weight:600;">${d.depto}</span>
                <span>✅ ${d.a_tiempo} · ⚠️ ${d.retardos} ret.</span>
            </div>
        `).join('');
        contRrhh.innerHTML = `
            <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap:10px; margin-bottom:14px;">
                <div style="background:#f0fdf4; padding:10px; border-radius:8px; text-align:center;">
                    <div style="font-size:11px; color:#166534; font-weight:700;">PUNTUALIDAD</div>
                    <div style="font-size:20px; font-weight:800; color:#15803d;">${pctPunt}%</div>
                </div>
                <div style="background:#fef3c7; padding:10px; border-radius:8px; text-align:center;">
                    <div style="font-size:11px; color:#92400e; font-weight:700;">RETARDOS</div>
                    <div style="font-size:20px; font-weight:800; color:#b45309;">${r.retardos || 0}</div>
                </div>
                <div style="background:#eef2ff; padding:10px; border-radius:8px; text-align:center;">
                    <div style="font-size:11px; color:#3730a3; font-weight:700;">HRS EXTRA AUT.</div>
                    <div style="font-size:20px; font-weight:800; color:#4338ca;">${Number(r.horas_extra_totales || 0).toFixed(1)}h</div>
                </div>
            </div>
            ${deptosHtml || '<div style="color:#64748b;">Sin checadas en este rango.</div>'}
        `;
    }

    // 3. Top Equipos Más Utilizados
    const contEq = document.getElementById("an-top-equipos-lista");
    if (contEq) {
        const eqs = av.top_equipos || [];
        if (eqs.length === 0) {
            contEq.innerHTML = '<div style="color:#64748b;">Sin historial de salidas de equipo aún.</div>';
        } else {
            contEq.innerHTML = eqs.map((eq, idx) => `
                <div style="display:flex; justify-content:space-between; align-items:center; padding:7px 0; border-bottom:1px solid #f1f5f9;">
                    <span><b>#${idx + 1}</b> ${eq.codigo}</span>
                    <span style="background:#e0f2fe; color:#0369a1; padding:2px 8px; border-radius:10px; font-size:11.5px; font-weight:700;">${eq.usos} salidas</span>
                </div>
            `).join('');
        }
    }
}

// ==========================================
// 16B. REPORTE USO DE INVENTARIO (CEO)
// ==========================================
let memoriaUsoInventarioCEO = [];
let filtrosUsoInventarioCargados = false;

async function cargarUsoInventarioCEO() {
    const tbody = document.getElementById("tbody-uso-inventario-ceo");
    if (tbody) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; padding:24px; color:#64748b;">Cargando uso de inventario y expedientes...</td></tr>';
    }

    const fIni = document.getElementById("filtro-analitica-desde")?.value || "";
    const fFin = document.getElementById("filtro-analitica-hasta")?.value || "";
    const depto = document.getElementById("filtro-uso-inv-depto")?.value || "";
    const emp = document.getElementById("filtro-uso-inv-emp")?.value || "";
    const soloMaestro = document.getElementById("filtro-uso-inv-solo-maestro")?.checked ? "true" : "false";

    const params = new URLSearchParams();
    if (fIni) params.append("fecha_inicio", fIni);
    if (fFin) params.append("fecha_fin", fFin);
    if (depto) params.append("departamento", depto);
    if (emp) params.append("id_empleado", emp);
    params.append("solo_maestro", soloMaestro);

    try {
        const res = await fetch(`${API_URL}/api/analitica/uso-inventario?${params.toString()}`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = await res.json();

        if (!filtrosUsoInventarioCargados && data.filtros) {
            const selDepto = document.getElementById("filtro-uso-inv-depto");
            if (selDepto && Array.isArray(data.filtros.departamentos)) {
                selDepto.innerHTML = '<option value="">Todos los deptos</option>' +
                    data.filtros.departamentos.map(d => `<option value="${d}">${d}</option>`).join('');
            }
            const selEmp = document.getElementById("filtro-uso-inv-emp");
            if (selEmp && Array.isArray(data.filtros.empleados)) {
                selEmp.innerHTML = '<option value="">Todas las personas</option>' +
                    data.filtros.empleados.map(e => `<option value="${e.id_empleado}">${e.nombre} (${e.depto})</option>`).join('');
            }
            filtrosUsoInventarioCargados = true;
        }

        const kpis = data.kpis || {};
        const elSal = document.getElementById("kpi-uso-inv-salidas");
        const elDis = document.getElementById("kpi-uso-inv-distintos");
        const elDan = document.getElementById("kpi-uso-inv-danos");
        const elInc = document.getElementById("kpi-uso-inv-incidencias");
        if (elSal) elSal.innerText = kpis.total_salidas || 0;
        if (elDis) elDis.innerText = kpis.equipos_distintos || 0;
        if (elDan) elDan.innerText = kpis.equipos_con_dano || 0;
        if (elInc) elInc.innerText = kpis.incidencias_checkouts || 0;

        memoriaUsoInventarioCEO = data.movimientos || [];
        filtrarUsoInventarioLocal();
    } catch (e) {
        console.error("Error en uso de inventario:", e);
        if (tbody) {
            tbody.innerHTML = `<tr><td colspan="7" style="text-align:center; padding:24px; color:#dc2626;">Error al cargar reporte: ${e.message}</td></tr>`;
        }
    }
}

function filtrarUsoInventarioLocal() {
    const q = (document.getElementById("filtro-uso-inv-busq")?.value || "").trim().toUpperCase();
    const filtrados = !q ? memoriaUsoInventarioCEO : memoriaUsoInventarioCEO.filter(m =>
        (m.codigo || "").toUpperCase().includes(q) ||
        (m.descripcion || "").toUpperCase().includes(q) ||
        String(m.folio_op || "").toUpperCase().includes(q) ||
        (m.nombre_evento || "").toUpperCase().includes(q) ||
        (m.cliente || "").toUpperCase().includes(q) ||
        (m.empleado || "").toUpperCase().includes(q) ||
        (m.depto || "").toUpperCase().includes(q)
    );
    renderTablaUsoInventarioCEO(filtrados);
}

function _badgeEstadoInventarioCEO(estado) {
    const e = (estado || "").toLowerCase();
    if (e.includes("fuera") || e.includes("dañ") || e.includes("dan")) {
        return `<span style="background:#fee2e2; color:#991b1b; padding:3px 9px; border-radius:999px; font-size:11.5px; font-weight:700;">${estado}</span>`;
    }
    if (e.includes("limit") || e.includes("repar")) {
        return `<span style="background:#fef3c7; color:#92400e; padding:3px 9px; border-radius:999px; font-size:11.5px; font-weight:700;">${estado}</span>`;
    }
    if (e.includes("baja")) {
        return `<span style="background:#e2e8f0; color:#475569; padding:3px 9px; border-radius:999px; font-size:11.5px; font-weight:700;">${estado}</span>`;
    }
    return `<span style="background:#dcfce7; color:#166534; padding:3px 9px; border-radius:999px; font-size:11.5px; font-weight:700;">${estado || "Funcional"}</span>`;
}

function renderTablaUsoInventarioCEO(lista) {
    const tbody = document.getElementById("tbody-uso-inventario-ceo");
    const cont = document.getElementById("uso-inv-contador-filas");
    if (cont) cont.innerText = `${lista.length} movimiento(s)`;
    if (!tbody) return;

    if (!lista || lista.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; padding:24px; color:#64748b;">No se encontraron movimientos de inventario con esos filtros.</td></tr>';
        return;
    }

    tbody.innerHTML = lista.map(m => {
        const reporteParts = [];
        if (m.dano_taller) reporteParts.push(`<div style="color:${m.dano_abierto ? '#dc2626' : '#92400e'}; font-weight:700; font-size:11.5px;">${m.dano_taller}</div>`);
        if (m.incidencia_checkout) reporteParts.push(`<div style="color:#b91c1c; font-size:12px;">Check-in: ${m.incidencia_checkout}</div>`);
        if (!reporteParts.length && m.notas_regreso) reporteParts.push(`<div style="color:#475569; font-size:12px;">Check-in: ${m.notas_regreso}</div>`);
        const reporteHtml = reporteParts.length ? reporteParts.join('') : '<span style="color:#64748b; font-size:12px;">Sin reporte de daño</span>';

        const statusBodegaTxt = `${m.estado_bodega || 'ENTREGADO'}${m.cotejado ? ' · ✅ Cotejado' : ' · ⏳ Pendiente'}`;

        return `
            <tr style="border-bottom:1px solid #e2e8f0;" onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='white'">
                <td style="padding:10px 12px; white-space:nowrap;"><b>${m.fecha}</b><br><span style="color:#64748b; font-size:11.5px;">${m.hora || ''}</span></td>
                <td style="padding:10px 12px; font-weight:700; color:#1d4ed8; white-space:nowrap;">OP-${m.folio_op}</td>
                <td style="padding:10px 12px;"><b>${m.nombre_evento}</b><br><span style="color:#64748b; font-size:11.5px;">${m.cliente}</span></td>
                <td style="padding:10px 12px;"><span style="font-weight:700; color:#0f172a;">${m.codigo}</span><br><span style="color:#475569; font-size:12px;">${m.descripcion}</span></td>
                <td style="padding:10px 12px;"><b>${m.empleado}</b><br><span style="color:#64748b; font-size:11.5px;">${m.depto}</span></td>
                <td style="padding:10px 12px; text-align:center;">${_badgeEstadoInventarioCEO(m.estado_equipo)}<div style="font-size:11px; color:#64748b; margin-top:4px;">${statusBodegaTxt}</div></td>
                <td style="padding:10px 12px;">${reporteHtml}</td>
            </tr>
        `;
    }).join('');
}

function exportarUsoInventarioCSV() {
    if (!memoriaUsoInventarioCEO || memoriaUsoInventarioCEO.length === 0) {
        alert("No hay datos cargados para exportar.");
        return;
    }
    const headers = ["Fecha", "Hora", "OP", "Evento", "Cliente", "Codigo_Equipo", "Descripcion_Equipo", "Checkout_Por", "Depto", "Status_Equipo", "Status_Bodega", "Cotejado", "Reporte_de_Dano_Incidencia", "Historial_Taller"];
    const filas = [headers.join(",")];
    const esc = v => `"${String(v ?? "").replace(/"/g, '""')}"`;

    memoriaUsoInventarioCEO.forEach(m => {
        filas.push([
            esc(m.fecha), esc(m.hora), esc(`OP-${m.folio_op}`), esc(m.nombre_evento),
            esc(m.cliente), esc(m.codigo), esc(m.descripcion), esc(m.empleado), esc(m.depto),
            esc(m.estado_equipo), esc(m.estado_bodega), esc(m.cotejado ? "SI" : "NO"),
            esc(m.incidencia_checkout || m.notas_regreso || "Sin reporte"), esc(m.dano_taller || "Sin tickets")
        ].join(","));
    });

    const blob = new Blob(["\uFEFF" + filas.join("\n")], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `Expediente_Uso_Inventario_${new Date().toISOString().slice(0, 10)}.csv`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}


