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
    const tabs = ['finanzas', 'comercial', 'operaciones'];
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
        const url = `${API_URL}/api/dashboard/resumen?fecha_inicio=${fIni}&fecha_fin=${fFin}`;
        const res = await fetch(url);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);

        const data = await res.json();
        const fin = data.finanzas || {};
        const com = data.comercial || {};
        const op = data.operaciones || {};

        // 1. FINANZAS
        const kpiGasto = document.getElementById("kpi-an-gasto-mes");
        const kpiEqDan = document.getElementById("kpi-an-equipos-danados");
        const kpiFlota = document.getElementById("kpi-an-flota-taller");
        const kpiSeg = document.getElementById("kpi-an-seguros-vencer");

        if (kpiGasto) kpiGasto.innerText = `$${Number(fin.gasto_mes || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}`;
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

