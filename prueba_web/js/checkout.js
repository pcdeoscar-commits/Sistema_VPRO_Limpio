// ==============================================================================
// MÓDULO: checkout.js
// 14. Checkout y logística VPF
// Líneas originales: 8145–9060 de script.js
// ==============================================================================

// ==========================================
// 14. MÓDULO DE CHECKOUT Y LOGÍSTICA [VPF]
// ==========================================

let opPreseleccionadaCheckout = null;
let ordenesCheckoutDisponibles = [];
let empleadoActivoCheckout = null;
let mapaEmpleadosNombreAId = {};
let itemsCheckoutSalida = [];
let itemsCheckoutCheckin = [];
let idMaestroCheckoutActual = null;
let estadoBodegaCheckoutActual = "NUEVO";
let pestanaActivaCheckout = 'salida';
let catalogoGlobalCheckoutCargado = false;
let radarDanosCheckoutSet = new Set();
let proveedoresAsignadosOPCheckout = [];

function abrirCheckoutConOP(idEvento, opLabel) {
    opPreseleccionadaCheckout = { id: idEvento, label: opLabel };
    cambiarVista('vista-checkout');
}

function cambiarPestanaCheckout(pestana) {
    pestanaActivaCheckout = pestana;
    const btnSalida = document.getElementById('tab-checkout-salida');
    const btnCheckin = document.getElementById('tab-checkout-checkin');
    const panelSalida = document.getElementById('checkout-panel-salida');
    const panelCheckin = document.getElementById('checkout-panel-checkin');

    if (pestana === 'salida') {
        if (btnSalida) btnSalida.classList.add('active');
        if (btnCheckin) btnCheckin.classList.remove('active');
        if (panelSalida) panelSalida.style.display = 'block';
        if (panelCheckin) panelCheckin.style.display = 'none';
    } else {
        if (btnSalida) btnSalida.classList.remove('active');
        if (btnCheckin) btnCheckin.classList.add('active');
        if (panelSalida) panelSalida.style.display = 'none';
        if (panelCheckin) panelCheckin.style.display = 'block';
    }
}

function desglosarArrayPostgres(val) {
    if (!val) return [];
    if (Array.isArray(val)) return val.map(x => String(x).trim()).filter(Boolean);
    if (typeof val === 'string') {
        let s = val.trim();
        if (s.startsWith('{') && s.endsWith('}')) {
            s = s.slice(1, -1);
            const matches = s.match(/(".*?"|[^",\s]+)(?=\s*,|\s*$)/g);
            if (matches) {
                return matches.map(m => m.replace(/^"|"$/g, '').trim()).filter(Boolean);
            }
            return s.split(',').map(x => x.replace(/^"|"$/g, '').trim()).filter(Boolean);
        }
        if (s.startsWith('[') && s.endsWith(']')) {
            try { return JSON.parse(s).map(x => String(x).trim()).filter(Boolean); } catch(e){}
        }
        return [s.replace(/^"|"$/g, '').trim()].filter(Boolean);
    }
    return [];
}

async function inicializarModuloCheckout() {
    if (!usuarioLogueado) return;

    // 1. Cargar catálogo global y radar de daños para autocompletado si aún no se cargaron
    if (!catalogoGlobalCheckoutCargado) {
        try {
            const [resCat, resDanos, resEmp] = await Promise.allSettled([
                fetch(`${API_URL}/api/inventario/catalogo-global`).then(r => r.ok ? r.json() : []),
                fetch(`${API_URL}/api/inventario/radar-danos`).then(r => r.ok ? r.json() : []),
                fetch(`${API_URL}/api/empleados`).then(r => r.ok ? r.json() : [])
            ]);

            if (resCat.status === 'fulfilled' && Array.isArray(resCat.value)) {
                const dl = document.getElementById('dl-catalogo-global');
                if (dl) {
                    dl.innerHTML = resCat.value.map(item => `<option value="${item}">`).join('');
                }
            }

            if (resDanos.status === 'fulfilled' && Array.isArray(resDanos.value)) {
                radarDanosCheckoutSet.clear();
                resDanos.value.forEach(d => {
                    const eq = (d.EQUIPO || d.equipo || '').toUpperCase().trim();
                    if (eq) radarDanosCheckoutSet.add(eq);
                });
            }

            if (resEmp.status === 'fulfilled' && Array.isArray(resEmp.value)) {
                mapaEmpleadosNombreAId = {};
                resEmp.value.forEach(e => {
                    if (e.nombre && e.id_empleado) {
                        mapaEmpleadosNombreAId[e.nombre.toUpperCase().trim()] = String(e.id_empleado).trim();
                    }
                });
            }

            catalogoGlobalCheckoutCargado = true;
        } catch (e) {
            console.warn("Aviso inicializando catálogos para checkout:", e);
        }
    }

    // 2. Cargar lista de OPs disponibles para este empleado
    try {
        const idEmp = usuarioLogueado.id_empleado || "001";
        const resInit = await fetch(`${API_URL}/api/checkout/init-data/${idEmp}`);
        if (resInit.ok) {
            const pack = await resInit.json();
            ordenesCheckoutDisponibles = pack.ordenes || [];
            
            const selOP = document.getElementById('checkout-sel-op');
            if (selOP) {
                if (ordenesCheckoutDisponibles.length === 0) {
                    selOP.innerHTML = `<option value="">--- No hay OPs activas pendientes ---</option>`;
                } else {
                    selOP.innerHTML = `<option value="">--- Seleccione una Orden de Producción ---</option>` +
                        ordenesCheckoutDisponibles.map(op => `<option value="${op}">${op}</option>`).join('');
                }
            }

            // Si venimos referenciados desde una notificación:
            if (opPreseleccionadaCheckout) {
                const idBuscado = opPreseleccionadaCheckout.id;
                const prefijo = `OP-${String(idBuscado).padStart(3, '0')}`;
                let encontrada = ordenesCheckoutDisponibles.find(op => op.startsWith(prefijo));
                
                // Si la OP no venía en init-data (ej. ya finalizada o usuario coordinador), agregarla dinámicamente
                if (!encontrada && opPreseleccionadaCheckout.label) {
                    encontrada = opPreseleccionadaCheckout.label;
                    if (selOP) {
                        const opt = document.createElement('option');
                        opt.value = encontrada;
                        opt.textContent = encontrada;
                        selOP.appendChild(opt);
                    }
                }

                if (encontrada && selOP) {
                    selOP.value = encontrada;
                    opPreseleccionadaCheckout = null;
                    await alCambiarOPCheckout();
                    return;
                }
                opPreseleccionadaCheckout = null;
            }

            // Si ya había una OP seleccionada, mantenerla; de lo contrario seleccionar la primera disponible
            if (selOP && selOP.value) {
                await alCambiarOPCheckout();
            } else if (selOP && ordenesCheckoutDisponibles.length > 0) {
                selOP.selectedIndex = 1;
                await alCambiarOPCheckout();
            }
        }
    } catch (e) {
        console.error("Error al inicializar módulo Checkout:", e);
    }
}

async function alCambiarOPCheckout() {
    const selOP = document.getElementById('checkout-sel-op');
    if (!selOP || !selOP.value) {
        limpiarModuloCheckout();
        return;
    }

    const opVal = selOP.value;
    const match = opVal.match(/OP-(\d+)/i);
    if (!match) return;
    const idEvento = parseInt(match[1]);

    await cargarStatusCheckout(idEvento);
}

function limpiarModuloCheckout() {
    idMaestroCheckoutActual = null;
    estadoBodegaCheckoutActual = "NUEVO";
    itemsCheckoutSalida = [];
    itemsCheckoutCheckin = [];
    actualizarBadgeEstadoCheckout("NUEVO");
    
    const selEmp = document.getElementById('checkout-sel-empleado');
    if (selEmp) selEmp.innerHTML = `<option value="">--- Seleccione OP primero ---</option>`;
    
    const txtConv = document.getElementById('checkout-txt-convocados');
    if (txtConv) txtConv.innerText = "--";
    const txtProv = document.getElementById('checkout-txt-proveedores');
    if (txtProv) txtProv.innerText = "--";
    const txtPlan = document.getElementById('checkout-txt-plantilla');
    if (txtPlan) txtPlan.innerText = "---";

    const selProvSalida = document.getElementById('checkout-salida-prov');
    if (selProvSalida) selProvSalida.innerHTML = `<option value="--- Ninguno ---">--- Ninguno ---</option>`;
    const selProvCheckin = document.getElementById('checkout-checkin-prov');
    if (selProvCheckin) selProvCheckin.innerHTML = `<option value="--- Ninguno ---">--- Ninguno ---</option>`;

    const notaProvSalida = document.getElementById('checkout-salida-prov-nota');
    if (notaProvSalida) notaProvSalida.value = "";
    const notaProvCheckin = document.getElementById('checkout-checkin-prov-nota');
    if (notaProvCheckin) notaProvCheckin.value = "";
    const incSalida = document.getElementById('checkout-salida-incidencias');
    if (incSalida) incSalida.value = "";
    const incCheckin = document.getElementById('checkout-checkin-incidencias');
    if (incCheckin) incCheckin.value = "";

    renderTablaCheckoutSalida();
    renderTablaCheckoutCheckin();
}

async function alCambiarEmpleadoCheckout() {
    const selEmp = document.getElementById('checkout-sel-empleado');
    if (!selEmp || !selEmp.value) return;

    empleadoActivoCheckout = selEmp.value;
    const selOP = document.getElementById('checkout-sel-op');
    if (!selOP || !selOP.value) return;
    const match = selOP.value.match(/OP-(\d+)/i);
    if (!match) return;
    const idEvento = parseInt(match[1]);

    await cargarStatusCheckout(idEvento, empleadoActivoCheckout);
}

async function cargarStatusCheckoutActual() {
    const selOP = document.getElementById('checkout-sel-op');
    if (!selOP || !selOP.value) return;
    const match = selOP.value.match(/OP-(\d+)/i);
    if (!match) return;
    const idEvento = parseInt(match[1]);
    await cargarStatusCheckout(idEvento, empleadoActivoCheckout);
}

async function cargarStatusCheckout(idEvento, empIdOverride = null) {
    if (!idEvento) return;
    const empId = empIdOverride || (usuarioLogueado ? usuarioLogueado.id_empleado : "001");
    empleadoActivoCheckout = empId;

    try {
        const resStatus = await fetch(`${API_URL}/api/checkout/status/${idEvento}/${empId}`);
        if (!resStatus.ok) throw new Error("Error consultando status de checkout");
        const statusPack = await resStatus.json();

        idMaestroCheckoutActual = statusPack.id_maestro;
        estadoBodegaCheckoutActual = statusPack.estado_bodega || "NUEVO";
        actualizarBadgeEstadoCheckout(estadoBodegaCheckoutActual);

        // Desglosar convocados y proveedores
        const convocados = desglosarArrayPostgres(statusPack.convocados);
        const proveedores = desglosarArrayPostgres(statusPack.proveedores_op);
        proveedoresAsignadosOPCheckout = proveedores;

        // Actualizar resumen en pantalla
        const txtConv = document.getElementById('checkout-txt-convocados');
        if (txtConv) txtConv.innerText = convocados.length > 0 ? convocados.join(", ") : "Ninguno asignado";
        const txtProv = document.getElementById('checkout-txt-proveedores');
        if (txtProv) txtProv.innerText = proveedores.length > 0 ? proveedores.join(", ") : "Ninguno asignado";
        const txtPlan = document.getElementById('checkout-txt-plantilla');
        if (txtPlan) txtPlan.innerText = statusPack.nombre_kit || "--- Sin plantilla ---";

        // Poblar selector de personal convocado
        const selEmp = document.getElementById('checkout-sel-empleado');
        if (selEmp) {
            if (convocados.length === 0) {
                selEmp.innerHTML = `<option value="${empId}">${usuarioLogueado?.nombre_completo || 'Operador Actual'}</option>`;
            } else {
                let optionsHtml = '';
                convocados.forEach(nombreNom => {
                    const norm = nombreNom.toUpperCase().trim();
                    const idConvocado = mapaEmpleadosNombreAId[norm] || empId;
                    optionsHtml += `<option value="${idConvocado}">${nombreNom}</option>`;
                });
                selEmp.innerHTML = optionsHtml;
                if ([...selEmp.options].some(o => o.value === empId)) {
                    selEmp.value = empId;
                } else if (selEmp.options.length > 0) {
                    selEmp.selectedIndex = 0;
                    empleadoActivoCheckout = selEmp.value;
                }
            }
        }

        // Cargar kits del empleado activo
        await cargarKitsEmpleadoActivo(empleadoActivoCheckout, statusPack.nombre_kit);

        // Poblar dropdowns de proveedores en salida y check-in
        const optsProv = `<option value="--- Ninguno ---">--- Ninguno ---</option>` +
            proveedores.map(p => `<option value="${p.toUpperCase()}">${p.toUpperCase()}</option>`).join('');
        const selProvSalida = document.getElementById('checkout-salida-prov');
        if (selProvSalida) selProvSalida.innerHTML = optsProv;
        const selProvCheckin = document.getElementById('checkout-checkin-prov');
        if (selProvCheckin) selProvCheckin.innerHTML = optsProv;

        // Desglosar incidencias y reporte de proveedor guardado
        let incLimpia = statusPack.incidencias_generales || "";
        let provIncGuardado = "--- Ninguno ---";
        let provNotaGuardada = "";

        if (incLimpia.includes("[PROVEEDOR_INCIDENTE:")) {
            const startIdx = incLimpia.indexOf("[PROVEEDOR_INCIDENTE:");
            const endIdx = incLimpia.indexOf("]", startIdx);
            if (endIdx !== -1) {
                const rawTag = incLimpia.substring(startIdx + 21, endIdx).trim();
                if (rawTag.includes(" | NOTA: ")) {
                    const [pName, pNote] = rawTag.split(" | NOTA: ");
                    provIncGuardado = pName.trim().toUpperCase();
                    provNotaGuardada = (pNote || "").trim();
                } else {
                    provIncGuardado = rawTag.toUpperCase();
                }
                incLimpia = incLimpia.substring(0, startIdx).trim();
            }
        }

        if (selProvSalida) selProvSalida.value = provIncGuardado;
        if (selProvCheckin) selProvCheckin.value = provIncGuardado;
        const notaProvSalida = document.getElementById('checkout-salida-prov-nota');
        if (notaProvSalida) notaProvSalida.value = provNotaGuardada;
        const notaProvCheckin = document.getElementById('checkout-checkin-prov-nota');
        if (notaProvCheckin) notaProvCheckin.value = provNotaGuardada;

        // Asignar el texto a los campos editables
        const esVacia = !incLimpia || ["sin incidencias", "sin incidencias reportadas", "ninguna", "ok", "none", "null"].includes(incLimpia.toLowerCase().trim());
        const incSalida = document.getElementById('checkout-salida-incidencias');
        if (incSalida) incSalida.value = !esVacia ? incLimpia : "";
        const incCheckin = document.getElementById('checkout-checkin-incidencias');
        if (incCheckin) incCheckin.value = !esVacia ? incLimpia : "";

        // Cargar ítems de salida y checkin
        const detalle = statusPack.detalle || [];
        itemsCheckoutSalida = detalle.map(item => ({
            id_detalle: item.id_detalle,
            ID: item.ID || item.codigo || "",
            EQUIPO: item.EQUIPO || item.Equipo || item.descripcion || "Equipo sin descripción",
            CANT: parseInt(item.CANT || item.cantidad || 1) || 1,
            OBSERVACIONES: item.OBSERVACIONES || item.observaciones || ""
        }));

        itemsCheckoutCheckin = detalle.map(item => ({
            id_detalle: item.id_detalle,
            ID: item.ID || item.codigo || "",
            EQUIPO: item.EQUIPO || item.Equipo || item.descripcion || "Equipo sin descripción",
            CANT_SALIDA: parseInt(item.CANT || item.cantidad || 1) || 1,
            OBS_SALIDA: item.OBSERVACIONES || item.observaciones || "",
            COTEJADO: Boolean(item.COTEJADO || item.cotejado || false),
            OBS_REGRESO: item.OBS_REGRESO || item.notas_regreso || ""
        }));

        renderTablaCheckoutSalida();
        renderTablaCheckoutCheckin();

        // Control de botón de autorización de Coordinador
        const btnCoord = document.getElementById('btn-autorizar-salida-coordinador');
        const rolUsuario = (usuarioLogueado?.rol || '').toUpperCase();
        const esCoordinadorOAdmin = rolUsuario.includes('ADMIN') || rolUsuario.includes('PRODUCCION') || rolUsuario.includes('COORDINADOR');
        
        if (btnCoord) {
            if (esCoordinadorOAdmin && idMaestroCheckoutActual && estadoBodegaCheckoutActual !== 'DESPACHADO' && estadoBodegaCheckoutActual !== 'RECIBIDO') {
                btnCoord.style.display = 'inline-flex';
            } else {
                btnCoord.style.display = 'none';
            }
        }

        // Si el cargamento ya está DESPACHADO, cambiar a la pestaña de Check-in automáticamente
        if (estadoBodegaCheckoutActual === 'DESPACHADO' && pestanaActivaCheckout === 'salida' && detalle.length > 0) {
            cambiarPestanaCheckout('checkin');
        }

    } catch (e) {
        console.error("Error cargando status checkout:", e);
    }
}

async function cargarKitsEmpleadoActivo(idEmpleado, plantillaSeleccionada = null) {
    try {
        const res = await fetch(`${API_URL}/api/checkout/kits/${idEmpleado}`);
        const selKit = document.getElementById('checkout-sel-kit');
        if (!selKit) return;

        let kits = [];
        if (res.ok) {
            const data = await res.json();
            kits = data.kits || [];
        }

        let html = `<option value="--- Sin plantilla ---">--- Sin plantilla ---</option>`;
        kits.forEach(k => {
            html += `<option value="${k}">${k}</option>`;
        });
        selKit.innerHTML = html;

        if (plantillaSeleccionada && plantillaSeleccionada !== "--- Sin plantilla ---") {
            if ([...selKit.options].some(o => o.value === plantillaSeleccionada)) {
                selKit.value = plantillaSeleccionada;
            } else {
                const opt = document.createElement('option');
                opt.value = plantillaSeleccionada;
                opt.textContent = plantillaSeleccionada;
                selKit.appendChild(opt);
                selKit.value = plantillaSeleccionada;
            }
        }
    } catch (e) {
        console.warn("Aviso cargando kits del empleado:", e);
    }
}

function actualizarBadgeEstadoCheckout(estado) {
    const badge = document.getElementById('checkout-badge-estado');
    if (!badge) return;

    badge.className = 'badge-chk';
    const st = (estado || 'NUEVO').toUpperCase().trim();
    if (st === 'RECIBIDO') {
        badge.classList.add('recibido');
        badge.innerHTML = `<i class="ph ph-check-circle"></i> Estatus: RECIBIDO / LIBERADO`;
    } else if (st === 'DESPACHADO') {
        badge.classList.add('despachado');
        badge.innerHTML = `<i class="ph ph-truck"></i> Estatus: DESPACHADO (En Evento)`;
    } else if (st === 'PENDIENTE') {
        badge.classList.add('pendiente');
        badge.innerHTML = `<i class="ph ph-clock"></i> Estatus: PENDIENTE AUTORIZACIÓN`;
    } else {
        badge.classList.add('nuevo');
        badge.innerHTML = `<i class="ph ph-sparkle"></i> Estatus: NUEVO (Sin Salida)`;
    }
}

function renderTablaCheckoutSalida() {
    const tbody = document.getElementById('tbody-checkout-salida');
    const badgeCount = document.getElementById('checkout-conteo-items');
    if (badgeCount) badgeCount.innerText = itemsCheckoutSalida.length;

    if (!tbody) return;
    if (itemsCheckoutSalida.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="6" style="text-align: center; padding: 30px; color: #94a3b8;">
                    <i class="ph ph-package" style="font-size: 32px; display: block; margin-bottom: 8px;"></i>
                    No hay equipos agregados. Carga una plantilla o busca equipos arriba.
                </td>
            </tr>
        `;
        return;
    }

    tbody.innerHTML = itemsCheckoutSalida.map((item, idx) => `
        <tr>
            <td style="text-align: center; font-weight: 600; color: #64748b;">${idx + 1}</td>
            <td>
                <input type="text" class="op-input" value="${(item.ID || '').replace(/"/g, '&quot;')}" onchange="actualizarItemSalida(${idx}, 'ID', this.value)" style="font-family: monospace; font-size: 12px; padding: 6px 8px;">
            </td>
            <td>
                <input type="text" class="op-input" value="${(item.EQUIPO || '').replace(/"/g, '&quot;')}" onchange="actualizarItemSalida(${idx}, 'EQUIPO', this.value)" style="font-size: 13px; font-weight: 500; padding: 6px 8px;">
            </td>
            <td style="text-align: center;">
                <input type="number" min="1" class="op-input" value="${item.CANT || 1}" onchange="actualizarItemSalida(${idx}, 'CANT', parseInt(this.value)||1)" style="text-align: center; font-size: 13px; font-weight: 600; padding: 6px 4px; width: 60px;">
            </td>
            <td>
                <input type="text" class="op-input" value="${(item.OBSERVACIONES || '').replace(/"/g, '&quot;')}" onchange="actualizarItemSalida(${idx}, 'OBSERVACIONES', this.value)" placeholder="Notas..." style="font-size: 12.5px; padding: 6px 8px;">
            </td>
            <td style="text-align: center;">
                <button type="button" onclick="eliminarFilaSalida(${idx})" style="background: none; border: none; color: #ef4444; cursor: pointer; font-size: 18px; padding: 4px;" title="Eliminar fila">
                    <i class="ph ph-trash"></i>
                </button>
            </td>
        </tr>
    `).join('');
}

function actualizarItemSalida(idx, campo, valor) {
    if (itemsCheckoutSalida[idx]) {
        itemsCheckoutSalida[idx][campo] = valor;
    }
}

function eliminarFilaSalida(idx) {
    itemsCheckoutSalida.splice(idx, 1);
    renderTablaCheckoutSalida();
}

function agregarFilaVaciaCheckout() {
    itemsCheckoutSalida.push({
        ID: "",
        EQUIPO: "",
        CANT: 1,
        OBSERVACIONES: ""
    });
    renderTablaCheckoutSalida();
}

function limpiarTablaSalidaCheckout() {
    if (itemsCheckoutSalida.length === 0) return;
    if (confirm("¿Estás seguro de que deseas vaciar todos los equipos de la lista de salida?")) {
        itemsCheckoutSalida = [];
        renderTablaCheckoutSalida();
    }
}

async function alSeleccionarKitCheckout() {
    const selKit = document.getElementById('checkout-sel-kit');
    if (!selKit || !selKit.value || selKit.value === "--- Sin plantilla ---") return;

    const nombreKit = selKit.value;
    const empId = empleadoActivoCheckout || (usuarioLogueado?.id_empleado || "001");

    try {
        const res = await fetch(`${API_URL}/api/eventos/buscar_kit/${encodeURIComponent(nombreKit)}/${empId}`);
        if (!res.ok) throw new Error("Error al obtener la plantilla de kit");
        const data = await res.json();
        const rawItems = data.items || [];
        
        let parsed = [];
        if (typeof rawItems === 'string') {
            try { parsed = JSON.parse(rawItems); } catch(e) { parsed = []; }
        } else if (Array.isArray(rawItems)) {
            parsed = rawItems;
        }

        if (parsed.length === 0) {
            alert("⚠️ La plantilla seleccionada está vacía o no tiene artículos registrados.");
            return;
        }

        itemsCheckoutSalida = parsed.map(it => ({
            ID: it.ID || it.codigo || it.ID_ITEM || "",
            EQUIPO: it.EQUIPO || it.descripcion || it.DESCRIPCION || it.Equipo || "Equipo",
            CANT: parseInt(it.CANT || it.cantidad || it.CANTIDAD || 1) || 1,
            OBSERVACIONES: it.OBSERVACIONES || it.observaciones || ""
        }));

        renderTablaCheckoutSalida();
        
        const banner = document.getElementById('checkout-txt-plantilla');
        if (banner) banner.innerText = nombreKit;

    } catch (e) {
        console.error("Error cargando kit:", e);
        alert("Error cargando la plantilla de kit: " + e.message);
    }
}

function verificarDanoEquipoSeleccionado() {
    const input = document.getElementById('checkout-buscar-hw');
    const alerta = document.getElementById('checkout-alerta-dano-hw');
    if (!input || !alerta) return;

    const val = (input.value || '').trim();
    if (!val) {
        alerta.style.display = 'none';
        return;
    }

    let nombreEq = val;
    if (val.includes(' - ')) {
        nombreEq = val.split(' - ').slice(1).join(' - ').trim();
    }

    const tieneDano = [...radarDanosCheckoutSet].some(d => nombreEq.toUpperCase().includes(d) || d.includes(nombreEq.toUpperCase()));
    if (tieneDano) {
        alerta.style.display = 'block';
    } else {
        alerta.style.display = 'none';
    }
}

function inyectarHardwareCheckout() {
    const inputHw = document.getElementById('checkout-buscar-hw');
    const inputCant = document.getElementById('checkout-cant-hw');
    if (!inputHw) return;

    const val = (inputHw.value || '').trim();
    if (!val) {
        alert("Selecciona o escribe un equipo para agregar.");
        return;
    }

    const cant = parseInt(inputCant?.value || 1) || 1;
    let cod = "";
    let nombre = val;

    if (val.includes(' - ')) {
        const partes = val.split(' - ');
        cod = partes[0].trim();
        nombre = partes.slice(1).join(' - ').trim();
    }

    // Sensor de daño al vuelo
    let obsDano = "";
    const tieneDano = [...radarDanosCheckoutSet].some(d => nombre.toUpperCase().includes(d) || d.includes(nombre.toUpperCase()));
    if (tieneDano) {
        obsDano = "⚠️ [LLEVA DAÑO REPORTADO]";
    }

    // Verificar si ya existe en la lista de salida
    const yaExiste = itemsCheckoutSalida.find(it => 
        (cod && it.ID && it.ID.toUpperCase() === cod.toUpperCase()) || 
        (it.EQUIPO && it.EQUIPO.toUpperCase() === nombre.toUpperCase())
    );

    if (yaExiste) {
        yaExiste.CANT = (yaExiste.CANT || 1) + cant;
        if (obsDano && !yaExiste.OBSERVACIONES.includes("DAÑO")) {
            yaExiste.OBSERVACIONES = (yaExiste.OBSERVACIONES + " " + obsDano).trim();
        }
    } else {
        itemsCheckoutSalida.push({
            ID: cod,
            EQUIPO: nombre,
            CANT: cant,
            OBSERVACIONES: obsDano
        });
    }

    inputHw.value = "";
    if (inputCant) inputCant.value = 1;
    verificarDanoEquipoSeleccionado();
    renderTablaCheckoutSalida();
}

async function guardarComoPlantillaKit() {
    const inputNombre = document.getElementById('checkout-nuevo-kit-nombre');
    const nombre = (inputNombre?.value || '').trim();
    if (!nombre) {
        alert("⚠️ Ingresa un nombre para la nueva plantilla / kit.");
        return;
    }
    if (itemsCheckoutSalida.length === 0) {
        alert("⚠️ La lista de equipos está vacía. Agrega equipos antes de guardar la plantilla.");
        return;
    }

    const empId = empleadoActivoCheckout || (usuarioLogueado?.id_empleado || "001");
    const payload = {
        id_empleado: empId,
        nombre_kit: nombre,
        items: itemsCheckoutSalida.map(it => ({
            ID: it.ID || '',
            EQUIPO: it.EQUIPO || '',
            OBSERVACIONES: it.OBSERVACIONES || ''
        })),
        usuario_actual: usuarioLogueado?.nombre_completo || 'OPERADOR'
    };

    try {
        const res = await fetch(`${API_URL}/api/checkout/grabar-kit`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (res.ok) {
            alert(`✅ Plantilla "${nombre}" guardada con éxito en tu perfil.`);
            inputNombre.value = "";
            await cargarKitsEmpleadoActivo(empId, nombre);
        } else {
            const err = await res.text();
            alert(`❌ Error al grabar plantilla: ${err}`);
        }
    } catch (e) {
        console.error("Error al grabar kit:", e);
        alert("Error de conexión al grabar plantilla.");
    }
}

async function finalizarSalidaCheckout() {
    const selOP = document.getElementById('checkout-sel-op');
    if (!selOP || !selOP.value) {
        alert("⚠️ Debes seleccionar una Orden de Producción.");
        return;
    }

    const match = selOP.value.match(/OP-(\d+)/i);
    if (!match) return;
    const idEvento = parseInt(match[1]);

    if (itemsCheckoutSalida.length === 0) {
        alert("⚠️ La lista de equipos a salir está vacía. Carga un kit o inyecta hardware.");
        return;
    }

    const empId = empleadoActivoCheckout || (usuarioLogueado?.id_empleado || "001");
    const selKit = document.getElementById('checkout-sel-kit')?.value || "--- Sin plantilla ---";
    const notaIncidenciasInput = (document.getElementById('checkout-salida-incidencias')?.value || '').trim();
    const notaIncidencias = notaIncidenciasInput || "Sin incidencias reportadas.";

    // Proveedor
    const provSel = document.getElementById('checkout-salida-prov')?.value || "--- Ninguno ---";
    const provNota = document.getElementById('checkout-salida-prov-nota')?.value || "";
    let tagProv = "";
    if (provSel !== "--- Ninguno ---" && provNota.trim()) {
        tagProv = `\n[PROVEEDOR_INCIDENTE: ${provSel} | NOTA: ${provNota.trim()}]`;
    }

    const incidenciasFinal = `${notaIncidencias.trim()}${tagProv}`.trim();

    const itemsFinales = itemsCheckoutSalida.map(it => ({
        ID: it.ID || '',
        codigo: it.ID || '',
        CANT: it.CANT || 1,
        cantidad: it.CANT || 1,
        OBSERVACIONES: it.OBSERVACIONES || '',
        observaciones: it.OBSERVACIONES || '',
        EQUIPO: it.EQUIPO || '',
        descripcion: it.EQUIPO || ''
    }));

    const payload = {
        id_evento: idEvento,
        id_sujeto_a_revisar: empId,
        incidencias_generales: incidenciasFinal,
        nombre_kit: selKit,
        items: itemsFinales
    };

    try {
        const btn = document.getElementById('btn-finalizar-salida');
        if (btn) btn.disabled = true;

        const res = await fetch(`${API_URL}/api/checkout/finalizar-salida`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (res.ok) {
            alert("🚀 ¡Salida de hardware y Checkout registrados exitosamente!");
            await cargarStatusCheckout(idEvento, empId);
            cargarBadges();
        } else {
            const err = await res.text();
            alert(`❌ Error al registrar salida: ${err}`);
        }
    } catch (e) {
        console.error("Error al finalizar salida:", e);
        alert("Error de conexión al registrar salida.");
    } finally {
        const btn = document.getElementById('btn-finalizar-salida');
        if (btn) btn.disabled = false;
    }
}

async function autorizarSalidaCoordinador() {
    if (!idMaestroCheckoutActual) {
        alert("⚠️ No se puede autorizar: primero debe registrarse la salida base de la OP.");
        return;
    }

    const notaIncidencias = document.getElementById('checkout-salida-incidencias')?.value || "Despacho autorizado por Coordinador.";

    const itemsFinales = itemsCheckoutSalida.map(it => ({
        id_detalle: it.id_detalle,
        ID: it.ID || '',
        codigo: it.ID || '',
        CANT: it.CANT || 1,
        cantidad: it.CANT || 1,
        OBSERVACIONES: it.OBSERVACIONES || '',
        observaciones: it.OBSERVACIONES || ''
    }));

    const payload = {
        id_maestro: idMaestroCheckoutActual,
        incidencias_generales: notaIncidencias.trim(),
        items: itemsFinales
    };

    try {
        const res = await fetch(`${API_URL}/api/checkout/verificar-salida-coordinador`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (res.ok) {
            alert("🔒 ¡Cargamento DESPACHADO y autorizado por Coordinación!");
            await cargarStatusCheckoutActual();
            cargarBadges();
        } else {
            const err = await res.text();
            alert(`❌ Error al autorizar salida: ${err}`);
        }
    } catch (e) {
        console.error("Error al autorizar salida:", e);
        alert("Error de conexión al autorizar salida.");
    }
}

function renderTablaCheckoutCheckin() {
    const tbody = document.getElementById('tbody-checkout-checkin');
    if (!tbody) return;

    if (itemsCheckoutCheckin.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="6" style="text-align: center; padding: 30px; color: #94a3b8;">
                    No hay checkout de salida registrado para cotejar en esta OP.
                </td>
            </tr>
        `;
        return;
    }

    tbody.innerHTML = itemsCheckoutCheckin.map((item, idx) => `
        <tr>
            <td><code style="font-size: 12px; background: #f1f5f9; padding: 2px 6px; border-radius: 4px;">${item.ID || '--'}</code></td>
            <td style="font-weight: 500; font-size: 13px;">${item.EQUIPO || 'Equipo sin descripción'}</td>
            <td style="text-align: center; font-weight: 700; color: #0f172a;">${item.CANT_SALIDA || 1}</td>
            <td style="color: #64748b; font-size: 12.5px;">${item.OBS_SALIDA || '---'}</td>
            <td style="text-align: center;">
                <input type="checkbox" ${item.COTEJADO ? 'checked' : ''} onchange="actualizarCheckinCotejo(${idx}, this.checked)" style="width: 20px; height: 20px; cursor: pointer; accent-color: #16a34a;">
            </td>
            <td>
                <input type="text" class="op-input" value="${(item.OBS_REGRESO || '').replace(/"/g, '&quot;')}" onchange="actualizarCheckinNota(${idx}, this.value)" placeholder="Buen estado / reportar daños..." style="font-size: 12.5px; padding: 6px 8px;">
            </td>
        </tr>
    `).join('');
}

function actualizarCheckinCotejo(idx, checked) {
    if (itemsCheckoutCheckin[idx]) {
        itemsCheckoutCheckin[idx].COTEJADO = checked;
    }
}

function actualizarCheckinNota(idx, valor) {
    if (itemsCheckoutCheckin[idx]) {
        itemsCheckoutCheckin[idx].OBS_REGRESO = valor;
    }
}

function marcarTodosCheckin(valor) {
    itemsCheckoutCheckin.forEach(it => {
        it.COTEJADO = valor;
    });
    renderTablaCheckoutCheckin();
}

async function finalizarCheckinCheckout() {
    if (!idMaestroCheckoutActual) {
        alert("⚠️ No hay registro maestro de salida para cotejar en esta OP.");
        return;
    }

    const selOP = document.getElementById('checkout-sel-op');
    const match = selOP?.value?.match(/OP-(\d+)/i);
    if (!match) return;
    const idEvento = parseInt(match[1]);

    // Verificar si algún artículo no fue cotejado
    const sinCotejar = itemsCheckoutCheckin.filter(it => !it.COTEJADO);
    if (sinCotejar.length > 0) {
        const confirmar = confirm(`⚠️ Atención: Hay ${sinCotejar.length} artículo(s) que NO marcaste como recibidos. ¿Deseas finalizar el Check-in de todas formas?`);
        if (!confirmar) return;
    }

    const notaRecepcionInput = (document.getElementById('checkout-checkin-incidencias')?.value || '').trim();
    const notaRecepcion = notaRecepcionInput || "Sin incidencias reportadas.";

    // Proveedor
    const provSel = document.getElementById('checkout-checkin-prov')?.value || "--- Ninguno ---";
    const provNota = document.getElementById('checkout-checkin-prov-nota')?.value || "";
    let tagProv = "";
    if (provSel !== "--- Ninguno ---" && provNota.trim()) {
        tagProv = `\n[PROVEEDOR_INCIDENTE: ${provSel} | NOTA: ${provNota.trim()}]`;
    }

    const incidenciasFinal = `${notaRecepcion.trim()}${tagProv}`.trim();

    const itemsFinales = itemsCheckoutCheckin.map(it => {
        const nota = (it.OBS_REGRESO || '').trim();
        const textoAnalisis = nota.toLowerCase();
        const tieneDano = ["dañ", "dan", "rot", "quebrad", "fall", "perd", "golp"].some(p => textoAnalisis.includes(p));
        
        return {
            id_detalle: it.id_detalle,
            ID: it.ID || '',
            COTEJADO: Boolean(it.COTEJADO),
            cotejado: Boolean(it.COTEJADO),
            OBS_REGRESO: nota,
            notas_regreso: nota,
            estatus_equipo: tieneDano ? "DAÑADO" : ""
        };
    });

    const payload = {
        id_maestro: idMaestroCheckoutActual,
        id_evento: idEvento,
        incidencias_generales: incidenciasFinal,
        items: itemsFinales
    };

    try {
        const res = await fetch(`${API_URL}/api/checkout/finalizar-checkin`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (res.ok) {
            alert("🔒 ¡Check-in y retorno de hardware registrado con éxito! La OP ha quedado LIBERADA.");
            await cargarStatusCheckoutActual();
            cargarBadges();
            if (typeof cargarDatosInicio === 'function') cargarDatosInicio();
        } else {
            const err = await res.text();
            alert(`❌ Error al finalizar check-in: ${err}`);
        }
    } catch (e) {
        console.error("Error al finalizar check-in:", e);
        alert("Error de conexión al finalizar check-in.");
    }
}

