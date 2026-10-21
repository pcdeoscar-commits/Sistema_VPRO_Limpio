// ==============================================================================
// MÓDULO: asistencia.js
// 9. Auditoría de asistencia unificada / checador
// Líneas originales: 5058–5206 de script.js
// ==============================================================================

// ==========================================
// 9. MÓDULO AUDITORÍA DE ASISTENCIA (UNIFICADO EN CHECADOR)
// ==========================================
let registrosAuditoriaCache = [];

async function cargarAuditoriaAsistencia() {
    const fIniInput = document.getElementById("filtro-auditoria-inicio");
    const fFinInput = document.getElementById("filtro-auditoria-fin");
    const selectEmp = document.getElementById("filtro-auditoria-emp");

    if (fIniInput && fFinInput) {
        const semana = obtenerRangoSemanaActual();
        if (!fIniInput.value) fIniInput.value = semana.lunes.iso;
        if (!fFinInput.value) fFinInput.value = semana.domingo.iso;
    }

    if (selectEmp && selectEmp.options.length <= 1) {
        try {
            const resEmps = await fetch(`${API_URL}/api/empleados`);
            if (resEmps.ok) {
                const empleados = await resEmps.json();
                empleados.filter(e => !String(e.estatus || '').toUpperCase().includes('BAJA'))
                         .sort((a,b) => (a.nombre || '').localeCompare(b.nombre || ''))
                         .forEach(e => {
                             const opt = document.createElement("option");
                             opt.value = e.nombre;
                             opt.innerText = `${e.nombre} (${e.depto || 'General'})`;
                             selectEmp.appendChild(opt);
                         });
            }
        } catch (e) { console.error("Error cargando empleados para auditoría:", e); }
    }

    ejecutarConsultaAuditoria();
}

async function ejecutarConsultaAuditoria() {
    const fIni = document.getElementById("filtro-auditoria-inicio")?.value;
    const fFin = document.getElementById("filtro-auditoria-fin")?.value;
    const emp = document.getElementById("filtro-auditoria-emp")?.value || "👥 TODOS";
    const depto = document.getElementById("filtro-auditoria-depto")?.value || "TODOS";
    const tbody = document.getElementById("tabla-auditoria-body");
    const contador = document.getElementById("contador-auditoria-registros");
    if (!tbody) return;

    if (!fIni || !fFin) {
        tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: #991b1b; padding: 16px;">Selecciona fechas de inicio y fin válidas.</td></tr>`;
        return;
    }

    tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; padding: 20px; color: var(--text-muted);">Consultando registros de auditoría...</td></tr>`;

    try {
        const res = await fetch(`${API_URL}/api/asistencia/auditoria`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ fecha_inicio: fIni, fecha_fin: fFin, empleado: emp })
        });

        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        let data = await res.json();

        // Filtro por departamento si aplica
        if (depto && depto !== "TODOS" && Array.isArray(memoriaEmpleados) && memoriaEmpleados.length > 0) {
            const empsDepto = new Set(
                memoriaEmpleados
                    .filter(e => (e.depto || '').toUpperCase().includes(depto.toUpperCase()))
                    .map(e => (e.nombre || '').toUpperCase().trim())
            );
            if (empsDepto.size > 0) {
                data = data.filter(r => empsDepto.has((r.nombre || '').toUpperCase().trim()));
            }
        }

        registrosAuditoriaCache = data;
        renderizarTablaAuditoria(registrosAuditoriaCache);

    } catch (err) {
        console.error("Error en consulta auditoría:", err);
        tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: #ef4444; padding: 20px;">Error al consultar registros de asistencia.</td></tr>`;
        if (contador) contador.innerText = '';
    }
}

function renderizarTablaAuditoria(lista) {
    const tbody = document.getElementById("tabla-auditoria-body");
    const contador = document.getElementById("contador-auditoria-registros");
    if (!tbody) return;

    if (!lista || lista.length === 0) {
        tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; padding: 20px; color: var(--text-muted);">No se encontraron registros de asistencia para los filtros seleccionados.</td></tr>`;
        if (contador) contador.innerText = "0 registros encontrados";
        return;
    }

    if (contador) {
        contador.innerText = `Mostrando ${lista.length} registro(s)`;
    }

    const limpiaHora = (h) => (h && h !== "None" && h !== "null" && h !== "--:--") ? String(h).substring(0, 5) : "--:--";

    tbody.innerHTML = lista.map(r => {
        const mIn = limpiaHora(r.hora_entrada);
        const mOut = limpiaHora(r.hora_salida);
        const vIn = limpiaHora(r.hora_entrada_v);
        const vOut = limpiaHora(r.hora_salida_v);

        const obs = (r.observaciones || '').toUpperCase();
        let badgeObs = r.observaciones || '--';

        if (obs.includes("VACACIONES")) {
            badgeObs = `<span style="background: #dcfce7; color: #166534; padding: 2px 8px; border-radius: 6px; font-weight: 700; font-size: 11.5px;">🌴 VACACIONES</span>`;
        } else if (obs.includes("PERMISO")) {
            badgeObs = `<span style="background: #e0f2fe; color: #0369a1; padding: 2px 8px; border-radius: 6px; font-weight: 700; font-size: 11.5px;">⏱️ PERMISO</span>`;
        } else if (obs.includes("INCAPACIDAD")) {
            badgeObs = `<span style="background: #ffedd5; color: #c2410c; padding: 2px 8px; border-radius: 6px; font-weight: 700; font-size: 11.5px;">🏥 INCAPACIDAD</span>`;
        } else if (obs.includes("OMISIÓN") || obs.includes("OMISION") || obs.includes("ADVERTENCIA")) {
            badgeObs = `<span style="color: #991b1b; font-weight: 600;">🚨 ${r.observaciones}</span>`;
        } else if (r.folio_op) {
            badgeObs = `<span style="background: #f1f5f9; color: #0f172a; padding: 2px 8px; border-radius: 6px; font-weight: 600; font-size: 11.5px;">📍 OP-${r.folio_op}: ${r.nombre_evento || ''}</span>`;
        }

        return `
            <tr>
                <td style="font-weight: 600; color: #475569; white-space: nowrap;">${r.fecha || '--'}</td>
                <td style="font-weight: 700; color: #0f172a;">${r.nombre || '--'}</td>
                <td>${mIn}</td>
                <td>${mOut}</td>
                <td>${vIn}</td>
                <td>${vOut}</td>
                <td>${badgeObs}</td>
            </tr>
        `;
    }).join("");
}

function filtrarTablaAuditoria(termino) {
    const t = (termino || "").toLowerCase().trim();
    if (!t) {
        renderizarTablaAuditoria(registrosAuditoriaCache);
        return;
    }
    const filtrados = (registrosAuditoriaCache || []).filter(r => {
        const str = `${r.fecha || ''} ${r.nombre || ''} ${r.observaciones || ''} ${r.folio_op || ''} ${r.nombre_evento || ''}`.toLowerCase();
        return str.includes(t);
    });
    renderizarTablaAuditoria(filtrados);
}

