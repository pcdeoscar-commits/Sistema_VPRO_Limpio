// ==============================================================================
// MÓDULO: catalogos.js
// 12. Catálogos ABC (clientes, autos, proveedores, inventario, empleados, reuniones, evidencias, cronogramas)
// Líneas originales: 5220–8136 de script.js
// ==============================================================================

// ==========================================
// 12. GESTIÓN DE CATÁLOGOS ABC (CLIENTES, AUTOS, PROVEEDORES, INVENTARIO)
// ==========================================

let subcatalogoActivoActual = 'clientes';
let callbackConfirmarBaja = null;

// Estados de memoria para cada catálogo
let memoriaClientes = [];
let clienteEditandoId = null;

let memoriaAutos = [];
let autoEditandoNum = null;

let memoriaProveedores = [];
let proveedorEditandoNombre = null;

let memoriaInventario = [];
let inventarioEditandoCodigo = null;

const aFechaInput = (f) => (f && f !== "None" && f !== "null") ? String(f).split('T')[0] : '';

// 🗂️ NAVEGACIÓN ENTRE SUB-CATÁLOGOS
function abrirSubcatalogo(subId) {
    if (!subId) subId = 'hub';
    subcatalogoActivoActual = subId;

    // Asegurar que la vista principal de catálogos esté visible
    const vistaCat = document.getElementById('vista-catalogos');
    if (vistaCat && (!vistaCat.classList.contains('activa') || vistaCat.style.display === 'none')) {
        cambiarVista('vista-catalogos');
    }

    const topbar = document.getElementById('subcat-topbar');
    const hub = document.getElementById('subcat-hub');

    if (subId === 'hub') {
        if (topbar) topbar.style.display = 'none';
        if (hub) hub.style.display = 'block';

        // Ocultar todos los sub-contenedores
        const contenedores = ['clientes', 'autos', 'proveedores', 'inventario', 'empleados', 'reuniones', 'cronogramas', 'historial-cotizaciones'];
        contenedores.forEach(c => {
            const el = document.getElementById(`subcat-${c}`);
            if (el) el.style.display = 'none';
        });

        // Actualizar contadores del Hub
        cargarTodosLosCatalogos();
        return;
    }

    // Modo subcatálogo específico
    if (hub) hub.style.display = 'none';
    if (topbar) topbar.style.display = 'flex';

    // Actualizar tabs superiores
    document.querySelectorAll('.subcat-tab-btn').forEach(btn => btn.classList.remove('active'));
    const btnActivo = document.getElementById(`btn-subcat-${subId}`);
    if (btnActivo) btnActivo.classList.add('active');

    // Ocultar todos los sub-contenedores excepto el activo
    const contenedores = ['clientes', 'autos', 'proveedores', 'inventario', 'empleados', 'reuniones', 'cronogramas', 'historial-cotizaciones'];
    contenedores.forEach(c => {
        const el = document.getElementById(`subcat-${c}`);
        if (el) el.style.display = (c === subId) ? 'block' : 'none';
    });

    // Carga de datos según el módulo seleccionado
    if (subId === 'clientes') {
        cargarCatalogoClientes();
    } else if (subId === 'autos') {
        cargarCatalogoAutos();
    } else if (subId === 'proveedores') {
        cargarCatalogoProveedores();
    } else if (subId === 'inventario') {
        cargarCatalogoInventario();
    } else if (subId === 'empleados') {
        cargarCatalogoEmpleados();
    } else if (subId === 'reuniones') {
        cargarCatalogoReuniones();
    } else if (subId === 'cronogramas') {
        cargarCatalogoCronogramas();
    } else if (subId === 'historial-cotizaciones') {
        cargarHistorialCotizacionesCatalogo();
    }

    // Actualizar conteos generales en las pestañas
    cargarTodosLosCatalogos();
}

// Control de Acordeones
function toggleAcordeonCat(accId) {
    const acc = document.getElementById(accId);
    const caret = document.getElementById(`caret-${accId}`);
    if (!acc) return;

    if (acc.classList.contains('open')) {
        acc.classList.remove('open');
        if (caret) caret.className = 'ph ph-caret-down';
    } else {
        acc.classList.add('open');
        if (caret) caret.className = 'ph ph-caret-up';
    }
}

// Control de Pestañas internas de formulario
function cambiarTabCat(prefijo, tabNum) {
    document.querySelectorAll(`[id^="tabbtn-${prefijo}-"]`).forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll(`[id^="tabpanel-${prefijo}-"]`).forEach(p => p.classList.remove('active'));

    const btn = document.getElementById(`tabbtn-${prefijo}-${tabNum}`);
    const panel = document.getElementById(`tabpanel-${prefijo}-${tabNum}`);
    if (btn) btn.classList.add('active');
    if (panel) panel.classList.add('active');
}

// Modal Genérico de Confirmación de Baja
function abrirModalBaja(titulo, mensaje, onConfirm) {
    document.getElementById('modal-baja-titulo').innerText = titulo;
    document.getElementById('modal-baja-mensaje').innerHTML = mensaje;
    callbackConfirmarBaja = onConfirm;
    const modal = document.getElementById('modal-confirm-baja');
    if (modal) modal.style.display = 'flex';
}

function cerrarModalBaja() {
    const modal = document.getElementById('modal-confirm-baja');
    if (modal) modal.style.display = 'none';
    callbackConfirmarBaja = null;
}

function ejecutarBajaConfirmada() {
    if (typeof callbackConfirmarBaja === 'function') {
        callbackConfirmarBaja();
    }
    cerrarModalBaja();
}

// --------------------------------------------------------------------------
// 🏢 1. CATÁLOGO DE CLIENTES
// --------------------------------------------------------------------------
async function cargarCatalogoClientes() {
    const tbody = document.getElementById('tabla-clientes-body');
    const badge = document.getElementById('badge-count-clientes');
    if (tbody) tbody.innerHTML = `<tr><td colspan="11" style="text-align: center; padding: 20px;">Cargando catálogo de clientes...</td></tr>`;

    try {
        const res = await fetch(`${API_URL}/api/clientes`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        memoriaClientes = await res.json();

        if (badge) badge.innerText = memoriaClientes.length;
        const tbCli = document.getElementById('tab-count-clientes');
        if (tbCli) tbCli.innerText = memoriaClientes.length;
        renderTablaClientes(memoriaClientes);
        poblarSelectorClientes();
    } catch (e) {
        console.error("Error al cargar clientes:", e);
        if (tbody) tbody.innerHTML = `<tr><td colspan="11" style="text-align: center; color: #ef4444; padding: 20px;">Error al conectar con la base de datos de clientes: ${e.message}</td></tr>`;
    }
}

function renderTablaClientes(lista) {
    const tbody = document.getElementById('tabla-clientes-body');
    if (!tbody) return;

    if (!lista || lista.length === 0) {
        tbody.innerHTML = `<tr><td colspan="11" style="text-align: center; padding: 20px; color: var(--text-muted);">Sin clientes registrados actualmente.</td></tr>`;
        return;
    }

    tbody.innerHTML = lista.map(c => `
        <tr style="cursor: pointer;" onclick="seleccionarClienteDirecto(${c.id_cliente})" title="Clic para editar este cliente">
            <td style="font-weight: 700; color: #0f172a;">${c.id_cliente}</td>
            <td style="font-weight: 600; color: #2563eb;">${c.cliente_empresa || '--'}</td>
            <td>${c.gte_gral || '--'}</td>
            <td>${c.ciudad || '--'}</td>
            <td>${c.estado || '--'}</td>
            <td>${c.tel_de_ofna || '--'}</td>
            <td>${c.email_de_empresa || '--'}</td>
            <td>${c.nombre_contacto_princ || '--'}</td>
            <td>${c.cel_contact_princ || '--'}</td>
            <td>${c.nombre_contacto_a || '--'}</td>
            <td>${c.cel_contact_a || '--'}</td>
        </tr>
    `).join('');
}

function filtrarTablaClientes() {
    const q = (document.getElementById('filtro-clientes')?.value || '').toLowerCase().trim();
    if (!q) {
        renderTablaClientes(memoriaClientes);
        return;
    }
    const filtrados = memoriaClientes.filter(c => {
        const texto = `${c.id_cliente} ${c.cliente_empresa || ''} ${c.gte_gral || ''} ${c.ciudad || ''} ${c.estado || ''} ${c.nombre_contacto_princ || ''} ${c.cel_contact_princ || ''}`.toLowerCase();
        return texto.includes(q);
    });
    renderTablaClientes(filtrados);
}

function poblarSelectorClientes() {
    const sel = document.getElementById('selector-cliente-editor');
    if (!sel) return;
    const valorPrevio = sel.value;
    sel.innerHTML = `<option value="nuevo">➕ Registrar Nuevo Cliente</option>` +
        memoriaClientes.map(c => `<option value="${c.id_cliente}">${c.id_cliente} - ${c.cliente_empresa}</option>`).join('');

    if (valorPrevio && memoriaClientes.some(c => String(c.id_cliente) === String(valorPrevio))) {
        sel.value = valorPrevio;
    } else {
        sel.value = 'nuevo';
    }
}

function seleccionarClienteDirecto(id) {
    const sel = document.getElementById('selector-cliente-editor');
    if (sel) {
        sel.value = id;
        alCambiarSelectorCliente();
        sel.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
}

function alCambiarSelectorCliente() {
    const sel = document.getElementById('selector-cliente-editor');
    const val = sel ? sel.value : 'nuevo';

    if (val === 'nuevo') {
        limpiarFormCliente();
        return;
    }

    const c = memoriaClientes.find(item => String(item.id_cliente) === String(val));
    if (!c) return;

    clienteEditandoId = c.id_cliente;
    const idInput = document.getElementById('cli-id');
    if (idInput) {
        idInput.value = c.id_cliente;
        idInput.disabled = true;
    }
    document.getElementById('cli-empresa').value = c.cliente_empresa || '';
    document.getElementById('cli-gte-gral').value = c.gte_gral || '';
    document.getElementById('cli-ciudad').value = c.ciudad || '';
    document.getElementById('cli-estado').value = c.estado || '';
    document.getElementById('cli-tel').value = c.tel_de_ofna || '';
    document.getElementById('cli-email').value = c.email_de_empresa || '';
    document.getElementById('cli-contacto-princ').value = c.nombre_contacto_princ || '';
    document.getElementById('cli-cel-princ').value = c.cel_contact_princ || '';
    document.getElementById('cli-contacto-a').value = c.nombre_contacto_a || '';
    document.getElementById('cli-cel-a').value = c.cel_contact_a || '';

    document.getElementById('btn-eliminar-cliente').style.display = 'inline-flex';
    document.getElementById('lbl-btn-guardar-cli').innerText = 'Actualizar Cliente';
}

function limpiarFormCliente() {
    clienteEditandoId = null;
    const idInput = document.getElementById('cli-id');
    if (idInput) {
        idInput.value = '';
        idInput.disabled = false;
    }
    ['cli-empresa', 'cli-gte-gral', 'cli-ciudad', 'cli-estado', 'cli-tel', 'cli-email', 'cli-contacto-princ', 'cli-cel-princ', 'cli-contacto-a', 'cli-cel-a'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.value = '';
    });

    const btnDel = document.getElementById('btn-eliminar-cliente');
    if (btnDel) btnDel.style.display = 'none';

    const lbl = document.getElementById('lbl-btn-guardar-cli');
    if (lbl) lbl.innerText = 'Guardar Cliente Nuevo';

    const sel = document.getElementById('selector-cliente-editor');
    if (sel) sel.value = 'nuevo';
    cambiarTabCat('cli', 1);
}

async function guardarClienteForm() {
    const idInput = document.getElementById('cli-id');
    const idVal = parseInt(idInput?.value || 0, 10);
    const empresa = (document.getElementById('cli-empresa')?.value || '').trim();

    if (!idVal || idVal <= 0) {
        alert("⚠️ El ID Cliente debe ser un número entero mayor a 0.");
        idInput?.focus();
        return;
    }
    if (!empresa) {
        alert("⚠️ La Razón Social / Nombre de la Empresa es obligatoria.");
        document.getElementById('cli-empresa')?.focus();
        return;
    }

    const payload = {
        id_cliente: idVal,
        cliente_empresa: empresa.toUpperCase(),
        gte_gral: (document.getElementById('cli-gte-gral')?.value || '').trim(),
        estado: (document.getElementById('cli-estado')?.value || '').trim(),
        ciudad: (document.getElementById('cli-ciudad')?.value || '').trim(),
        tel_de_ofna: (document.getElementById('cli-tel')?.value || '').trim(),
        email_de_empresa: (document.getElementById('cli-email')?.value || '').trim(),
        nombre_contacto_princ: (document.getElementById('cli-contacto-princ')?.value || '').trim(),
        cel_contact_princ: (document.getElementById('cli-cel-princ')?.value || '').trim(),
        nombre_contacto_a: (document.getElementById('cli-contacto-a')?.value || '').trim(),
        cel_contact_a: (document.getElementById('cli-cel-a')?.value || '').trim()
    };

    const btn = document.getElementById('btn-guardar-cliente');
    if (btn) btn.disabled = true;

    try {
        const res = await fetch(`${API_URL}/api/clientes/guardar`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (!res.ok) {
            const err = await res.json().catch(() => ({ detail: res.statusText }));
            throw new Error(err.detail || "Error al guardar el cliente.");
        }

        alert(`✅ ¡Cliente "${payload.cliente_empresa}" (ID: ${payload.id_cliente}) guardado con éxito!`);
        await cargarCatalogoClientes();
        seleccionarClienteDirecto(payload.id_cliente);
    } catch (e) {
        alert(`❌ Error al guardar cliente: ${e.message}`);
    } finally {
        if (btn) btn.disabled = false;
    }
}

function confirmarBajaCliente() {
    if (!clienteEditandoId) return;
    const c = memoriaClientes.find(item => item.id_cliente === clienteEditandoId);
    const nombre = c ? c.cliente_empresa : `ID ${clienteEditandoId}`;

    abrirModalBaja(
        "🚨 Confirmación de Baja de Cliente",
        `¿Está seguro de que desea eliminar permanentemente al cliente <strong>${nombre}</strong> (ID: ${clienteEditandoId})?<br><br><span style="color: #991b1b; font-size: 12px;">⚠️ Esta acción borrará la empresa del catálogo maestro corporativo.</span>`,
        async () => {
            try {
                const res = await fetch(`${API_URL}/api/clientes/eliminar/${clienteEditandoId}`, { method: 'DELETE' });
                if (!res.ok) {
                    const err = await res.json().catch(() => ({ detail: res.statusText }));
                    throw new Error(err.detail || "Error al eliminar");
                }
                alert(`💥 Cliente ${nombre} eliminado exitosamente.`);
                limpiarFormCliente();
                await cargarCatalogoClientes();
            } catch (e) {
                alert(`❌ No se pudo eliminar el cliente: ${e.message}`);
            }
        }
    );
}

// --------------------------------------------------------------------------
// 🚗 2. FLOTILLA DE VEHÍCULOS
// --------------------------------------------------------------------------
async function cargarCatalogoAutos() {
    const tbody = document.getElementById('tabla-autos-body');
    const badge = document.getElementById('badge-count-autos');
    if (tbody) tbody.innerHTML = `<tr><td colspan="11" style="text-align: center; padding: 20px;">Cargando flota vehicular...</td></tr>`;

    try {
        const res = await fetch(`${API_URL}/api/autos`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        memoriaAutos = await res.json();

        if (badge) badge.innerText = memoriaAutos.length;
        const tbAutos = document.getElementById('tab-count-autos');
        if (tbAutos) tbAutos.innerText = memoriaAutos.length;
        renderTablaAutos(memoriaAutos);
        poblarSelectorAutos();
    } catch (e) {
        console.error("Error al cargar autos:", e);
        if (tbody) tbody.innerHTML = `<tr><td colspan="11" style="text-align: center; color: #ef4444; padding: 20px;">Error al conectar con la flota vehicular: ${e.message}</td></tr>`;
    }
}

function renderTablaAutos(lista) {
    const tbody = document.getElementById('tabla-autos-body');
    if (!tbody) return;

    if (!lista || lista.length === 0) {
        tbody.innerHTML = `<tr><td colspan="11" style="text-align: center; padding: 20px; color: var(--text-muted);">Sin vehículos registrados actualmente.</td></tr>`;
        return;
    }

    tbody.innerHTML = lista.map(a => {
        let badgeColor = "#16a34a";
        const est = (a.estado_actual || '').toUpperCase();
        if (est.includes("REPAR") || est.includes("REGULAR")) badgeColor = "#d97706";
        if (est.includes("FUERA") || est.includes("BAJA")) badgeColor = "#dc2626";

        return `
            <tr style="cursor: pointer;" onclick="seleccionarAutoDirecto('${a.num_control}')" title="Clic para editar esta unidad">
                <td style="font-weight: 700; color: #0f172a;">${a.num_control}</td>
                <td>${a.tipo_vehiculo || '--'}</td>
                <td style="font-weight: 600; color: #2563eb;">${a.marca || ''} ${a.modelo || ''}</td>
                <td>${a.anio || '--'}</td>
                <td style="font-weight: 600;">${a.placa || 'S/P'}</td>
                <td>${a.color || '--'}</td>
                <td><small>${a.serie || '--'}</small></td>
                <td>${a.kilometraje_actual ? Number(a.kilometraje_actual).toLocaleString() + ' km' : '--'}</td>
                <td><span style="background: ${badgeColor}20; color: ${badgeColor}; padding: 3px 8px; border-radius: 6px; font-weight: 700; font-size: 11px;">${a.estado_actual || '--'}</span></td>
                <td>${a.aseguradora || '--'}</td>
                <td>${aFechaInput(a.seguro_vence) || '--'}</td>
            </tr>
        `;
    }).join('');
}

function filtrarTablaAutos() {
    const q = (document.getElementById('filtro-autos')?.value || '').toLowerCase().trim();
    if (!q) {
        renderTablaAutos(memoriaAutos);
        return;
    }
    const filtrados = memoriaAutos.filter(a => {
        const texto = `${a.num_control} ${a.marca || ''} ${a.modelo || ''} ${a.placa || ''} ${a.color || ''} ${a.estado_actual || ''} ${a.aseguradora || ''}`.toLowerCase();
        return texto.includes(q);
    });
    renderTablaAutos(filtrados);
}

function poblarSelectorAutos() {
    const sel = document.getElementById('selector-auto-editor');
    if (!sel) return;
    const valorPrevio = sel.value;
    sel.innerHTML = `<option value="nuevo">➕ Registrar Nuevo Vehículo</option>` +
        memoriaAutos.map(a => `<option value="${a.num_control}">${a.num_control} - ${a.marca || ''} ${a.modelo || ''} (${a.placa || 'S/P'})</option>`).join('');

    if (valorPrevio && memoriaAutos.some(a => a.num_control === valorPrevio)) {
        sel.value = valorPrevio;
    } else {
        sel.value = 'nuevo';
    }
}

function seleccionarAutoDirecto(numControl) {
    const sel = document.getElementById('selector-auto-editor');
    if (sel) {
        sel.value = numControl;
        alCambiarSelectorAuto();
        sel.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
}

function alCambiarSelectorAuto() {
    const sel = document.getElementById('selector-auto-editor');
    const val = sel ? sel.value : 'nuevo';

    if (val === 'nuevo') {
        limpiarFormAuto();
        return;
    }

    const a = memoriaAutos.find(item => item.num_control === val);
    if (!a) return;

    autoEditandoNum = a.num_control;
    const numInput = document.getElementById('auto-num-control');
    if (numInput) {
        numInput.value = a.num_control;
        numInput.disabled = true;
    }
    document.getElementById('auto-tipo').value = a.tipo_vehiculo || 'Auto';
    document.getElementById('auto-marca').value = a.marca || '';
    document.getElementById('auto-modelo').value = a.modelo || '';
    document.getElementById('auto-anio').value = a.anio || '';
    document.getElementById('auto-placa').value = a.placa || '';
    document.getElementById('auto-serie').value = a.serie || '';
    document.getElementById('auto-color').value = a.color || '';
    document.getElementById('auto-carga').value = a.carga_maxima || '';
    document.getElementById('auto-km').value = a.kilometraje_actual || 0;
    document.getElementById('auto-estado').value = a.estado_actual || 'EXCELENTE';
    document.getElementById('auto-fecha-compra').value = aFechaInput(a.fecha_compra);
    document.getElementById('auto-estado-mant').value = a.estado_mant_preventivo || '';

    // Póliza
    document.getElementById('auto-aseguradora').value = a.aseguradora || '';
    document.getElementById('auto-no-poliza').value = a.no_poliza || '';
    document.getElementById('auto-status-seguro').value = a.status_seguro || 'ACTIVA';
    document.getElementById('auto-forma-pago').value = a.forma_pago_seguro || 'Anual';
    document.getElementById('auto-prima-total').value = a.prima_total || 0;
    document.getElementById('auto-seguro-inicio').value = aFechaInput(a.seguro_inicio);
    document.getElementById('auto-seguro-vence').value = aFechaInput(a.seguro_vence);

    // Impuestos
    document.getElementById('auto-impuesto-anio').value = a.impuesto_anio || '';
    document.getElementById('auto-impuesto-monto').value = a.impuesto_monto || 0;
    document.getElementById('auto-impuesto-pago').value = aFechaInput(a.impuesto_fecha_pago);
    document.getElementById('auto-impuesto-vence').value = aFechaInput(a.impuesto_fecha_vencimiento);

    // Bitácora
    document.getElementById('auto-mant-fecha').value = aFechaInput(a.mantenimiento_fecha);
    document.getElementById('auto-servicios').value = a.servicios_hechos || '';
    document.getElementById('auto-observaciones').value = a.observaciones_comentarios || '';

    // Alerta de Póliza Vencida
    const alertaBox = document.getElementById('alerta-poliza-auto');
    if (alertaBox) {
        const venceStr = aFechaInput(a.seguro_vence);
        if (venceStr) {
            const hoy = new Date();
            hoy.setHours(0,0,0,0);
            const fechaVence = new Date(venceStr + 'T00:00:00');
            const diffDias = Math.round((fechaVence - hoy) / (1000 * 60 * 60 * 24));

            if (diffDias < 0) {
                alertaBox.className = 'alerta-card alert';
                alertaBox.style.display = 'flex';
                alertaBox.innerHTML = `<i class="ph ph-warning-octagon" style="font-size: 20px;"></i> <div><strong>🚨 ¡ATENCIÓN!</strong> La póliza de seguro de esta unidad VENCIÓ el ${venceStr} (${Math.abs(diffDias)} días atrás). Se requiere renovación urgente.</div>`;
            } else if (diffDias <= 30) {
                alertaBox.className = 'alerta-card warning';
                alertaBox.style.display = 'flex';
                alertaBox.innerHTML = `<i class="ph ph-warning" style="font-size: 20px;"></i> <div><strong>⚠️ AVISO DE VENCIMIENTO:</strong> La póliza vence próximamente el ${venceStr} (le quedan ${diffDias} días).</div>`;
            } else {
                alertaBox.style.display = 'none';
            }
        } else {
            alertaBox.style.display = 'none';
        }
    }

    document.getElementById('btn-eliminar-auto').style.display = 'inline-flex';
    document.getElementById('lbl-btn-guardar-auto').innerText = 'Actualizar Vehículo';
}

function limpiarFormAuto() {
    autoEditandoNum = null;
    const numInput = document.getElementById('auto-num-control');
    if (numInput) {
        numInput.value = '';
        numInput.disabled = false;
    }
    ['auto-marca', 'auto-modelo', 'auto-anio', 'auto-placa', 'auto-serie', 'auto-color', 'auto-carga', 'auto-estado-mant', 'auto-aseguradora', 'auto-no-poliza', 'auto-impuesto-anio', 'auto-servicios', 'auto-observaciones'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.value = '';
    });
    ['auto-km', 'auto-prima-total', 'auto-impuesto-monto'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.value = 0;
    });
    ['auto-fecha-compra', 'auto-seguro-inicio', 'auto-seguro-vence', 'auto-impuesto-pago', 'auto-impuesto-vence', 'auto-mant-fecha'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.value = '';
    });

    const alertaBox = document.getElementById('alerta-poliza-auto');
    if (alertaBox) alertaBox.style.display = 'none';

    const btnDel = document.getElementById('btn-eliminar-auto');
    if (btnDel) btnDel.style.display = 'none';

    const lbl = document.getElementById('lbl-btn-guardar-auto');
    if (lbl) lbl.innerText = 'Guardar Vehículo Nuevo';

    const sel = document.getElementById('selector-auto-editor');
    if (sel) sel.value = 'nuevo';
    cambiarTabCat('auto', 1);
}

async function guardarAutoForm() {
    const numInput = document.getElementById('auto-num-control');
    const numControl = (numInput?.value || '').trim();

    if (!numControl) {
        alert("⚠️ El Número de Control es obligatorio (Ej. VPF150).");
        numInput?.focus();
        return;
    }

    const payload = {
        num_control: numControl,
        tipo_vehiculo: document.getElementById('auto-tipo')?.value || 'Auto',
        marca: (document.getElementById('auto-marca')?.value || '').trim(),
        modelo: (document.getElementById('auto-modelo')?.value || '').trim(),
        anio: (document.getElementById('auto-anio')?.value || '').trim(),
        placa: (document.getElementById('auto-placa')?.value || '').trim().toUpperCase(),
        serie: (document.getElementById('auto-serie')?.value || '').trim().toUpperCase(),
        color: (document.getElementById('auto-color')?.value || '').trim(),
        carga_maxima: (document.getElementById('auto-carga')?.value || '').trim(),
        kilometraje_actual: parseInt(document.getElementById('auto-km')?.value || 0, 10),
        estado_actual: document.getElementById('auto-estado')?.value || 'EXCELENTE',
        fecha_compra: document.getElementById('auto-fecha-compra')?.value || null,
        estado_mant_preventivo: (document.getElementById('auto-estado-mant')?.value || '').trim(),
        aseguradora: (document.getElementById('auto-aseguradora')?.value || '').trim(),
        no_poliza: (document.getElementById('auto-no-poliza')?.value || '').trim(),
        status_seguro: document.getElementById('auto-status-seguro')?.value || 'ACTIVA',
        forma_pago_seguro: document.getElementById('auto-forma-pago')?.value || 'Anual',
        prima_total: parseFloat(document.getElementById('auto-prima-total')?.value || 0),
        seguro_inicio: document.getElementById('auto-seguro-inicio')?.value || null,
        seguro_vence: document.getElementById('auto-seguro-vence')?.value || null,
        impuesto_anio: (document.getElementById('auto-impuesto-anio')?.value || '').trim(),
        impuesto_monto: parseFloat(document.getElementById('auto-impuesto-monto')?.value || 0),
        impuesto_fecha_pago: document.getElementById('auto-impuesto-pago')?.value || null,
        impuesto_fecha_vencimiento: document.getElementById('auto-impuesto-vence')?.value || null,
        mantenimiento_fecha: document.getElementById('auto-mant-fecha')?.value || null,
        servicios_hechos: (document.getElementById('auto-servicios')?.value || '').trim(),
        observaciones_comentarios: (document.getElementById('auto-observaciones')?.value || '').trim()
    };

    const btn = document.getElementById('btn-guardar-auto');
    if (btn) btn.disabled = true;

    try {
        const res = await fetch(`${API_URL}/api/autos/guardar`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (!res.ok) {
            const err = await res.json().catch(() => ({ detail: res.statusText }));
            throw new Error(err.detail || "Error al guardar el vehículo.");
        }

        alert(`✅ ¡Vehículo ${payload.num_control} guardado exitosamente!`);
        await cargarCatalogoAutos();
        seleccionarAutoDirecto(payload.num_control);
    } catch (e) {
        alert(`❌ Error al guardar vehículo: ${e.message}`);
    } finally {
        if (btn) btn.disabled = false;
    }
}

function confirmarBajaAuto() {
    if (!autoEditandoNum) return;
    abrirModalBaja(
        "🚨 Confirmación de Baja Vehicular",
        `¿Está seguro de que desea eliminar permanentemente la unidad <strong>${autoEditandoNum}</strong>?<br><br><span style="color: #991b1b; font-size: 12px;">⚠️ Esta acción no se puede deshacer y borrará el registro de la flota vehicular.</span>`,
        async () => {
            try {
                const res = await fetch(`${API_URL}/api/autos/${autoEditandoNum}`, { method: 'DELETE' });
                if (!res.ok) {
                    const err = await res.json().catch(() => ({ detail: res.statusText }));
                    throw new Error(err.detail || "Error al eliminar");
                }
                alert(`💥 Unidad ${autoEditandoNum} eliminada exitosamente.`);
                limpiarFormAuto();
                await cargarCatalogoAutos();
            } catch (e) {
                alert(`❌ No se pudo eliminar la unidad: ${e.message}`);
            }
        }
    );
}

// --------------------------------------------------------------------------
// 🚚 3. CATÁLOGO DE PROVEEDORES
// --------------------------------------------------------------------------
async function cargarCatalogoProveedores() {
    const tbody = document.getElementById('tabla-proveedores-body');
    const badge = document.getElementById('badge-count-prov');
    if (tbody) tbody.innerHTML = `<tr><td colspan="10" style="text-align: center; padding: 20px;">Cargando catálogo de proveedores...</td></tr>`;

    try {
        const res = await fetch(`${API_URL}/api/proveedores`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        memoriaProveedores = await res.json();

        if (badge) badge.innerText = memoriaProveedores.length;
        const tbProv = document.getElementById('tab-count-prov');
        if (tbProv) tbProv.innerText = memoriaProveedores.length;
        renderTablaProveedores(memoriaProveedores);
        poblarSelectorProveedores();
    } catch (e) {
        console.error("Error al cargar proveedores:", e);
        if (tbody) tbody.innerHTML = `<tr><td colspan="10" style="text-align: center; color: #ef4444; padding: 20px;">Error al conectar con la base de datos de proveedores: ${e.message}</td></tr>`;
    }
}

function renderTablaProveedores(lista) {
    const tbody = document.getElementById('tabla-proveedores-body');
    if (!tbody) return;

    if (!lista || lista.length === 0) {
        tbody.innerHTML = `<tr><td colspan="10" style="text-align: center; padding: 20px; color: var(--text-muted);">Sin proveedores registrados actualmente.</td></tr>`;
        return;
    }

    tbody.innerHTML = lista.map(p => `
        <tr style="cursor: pointer;" onclick="seleccionarProveedorDirecto('${p.nombre_del_proveedor}')" title="Clic para editar este proveedor">
            <td style="font-weight: 700; color: #0f172a;">${p.nombre_del_proveedor}</td>
            <td>${p.gte_gral || '--'}</td>
            <td>${p.ciudad || '--'}</td>
            <td>${p.estado || '--'}</td>
            <td>${p.tel_de_ofna || '--'}</td>
            <td>${p.email_de_empresa || '--'}</td>
            <td>${p.nombre_contacto_princ || '--'}</td>
            <td>${p.cel_contact_princ || '--'}</td>
            <td>${p.nombre_contacto_a || '--'}</td>
            <td>${p.cel_contact_a || '--'}</td>
        </tr>
    `).join('');
}

function filtrarTablaProveedores() {
    const q = (document.getElementById('filtro-proveedores')?.value || '').toLowerCase().trim();
    if (!q) {
        renderTablaProveedores(memoriaProveedores);
        return;
    }
    const filtrados = memoriaProveedores.filter(p => {
        const texto = `${p.nombre_del_proveedor} ${p.gte_gral || ''} ${p.ciudad || ''} ${p.estado || ''} ${p.nombre_contacto_princ || ''} ${p.cel_contact_princ || ''}`.toLowerCase();
        return texto.includes(q);
    });
    renderTablaProveedores(filtrados);
}

function poblarSelectorProveedores() {
    const sel = document.getElementById('selector-prov-editor');
    if (!sel) return;
    const valorPrevio = sel.value;
    sel.innerHTML = `<option value="nuevo">➕ Registrar Nuevo Proveedor</option>` +
        memoriaProveedores.map(p => `<option value="${p.nombre_del_proveedor}">${p.nombre_del_proveedor}</option>`).join('');

    if (valorPrevio && memoriaProveedores.some(p => p.nombre_del_proveedor === valorPrevio)) {
        sel.value = valorPrevio;
    } else {
        sel.value = 'nuevo';
    }
}

function seleccionarProveedorDirecto(nombre) {
    const sel = document.getElementById('selector-prov-editor');
    if (sel) {
        sel.value = nombre;
        alCambiarSelectorProveedor();
        sel.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
}

function alCambiarSelectorProveedor() {
    const sel = document.getElementById('selector-prov-editor');
    const val = sel ? sel.value : 'nuevo';

    if (val === 'nuevo') {
        limpiarFormProveedor();
        return;
    }

    const p = memoriaProveedores.find(item => item.nombre_del_proveedor === val);
    if (!p) return;

    proveedorEditandoNombre = p.nombre_del_proveedor;
    const nombreInput = document.getElementById('prov-nombre');
    if (nombreInput) {
        nombreInput.value = p.nombre_del_proveedor;
        nombreInput.disabled = true;
    }
    document.getElementById('prov-gte-gral').value = p.gte_gral || '';
    document.getElementById('prov-ciudad').value = p.ciudad || '';
    document.getElementById('prov-estado').value = p.estado || '';
    document.getElementById('prov-tel').value = p.tel_de_ofna || '';
    document.getElementById('prov-email').value = p.email_de_empresa || '';
    document.getElementById('prov-contacto-princ').value = p.nombre_contacto_princ || '';
    document.getElementById('prov-cel-princ').value = p.cel_contact_princ || '';
    document.getElementById('prov-contacto-a').value = p.nombre_contacto_a || '';
    document.getElementById('prov-cel-a').value = p.cel_contact_a || '';

    document.getElementById('btn-eliminar-prov').style.display = 'inline-flex';
    document.getElementById('lbl-btn-guardar-prov').innerText = 'Actualizar Proveedor';
}

function limpiarFormProveedor() {
    proveedorEditandoNombre = null;
    const nombreInput = document.getElementById('prov-nombre');
    if (nombreInput) {
        nombreInput.value = '';
        nombreInput.disabled = false;
    }
    ['prov-gte-gral', 'prov-ciudad', 'prov-estado', 'prov-tel', 'prov-email', 'prov-contacto-princ', 'prov-cel-princ', 'prov-contacto-a', 'prov-cel-a'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.value = '';
    });

    const btnDel = document.getElementById('btn-eliminar-prov');
    if (btnDel) btnDel.style.display = 'none';

    const lbl = document.getElementById('lbl-btn-guardar-prov');
    if (lbl) lbl.innerText = 'Guardar Proveedor Nuevo';

    const sel = document.getElementById('selector-prov-editor');
    if (sel) sel.value = 'nuevo';
    cambiarTabCat('prov', 1);
}

async function guardarProveedorForm() {
    const nombreInput = document.getElementById('prov-nombre');
    const nombre = (nombreInput?.value || '').trim();

    if (!nombre) {
        alert("⚠️ El Nombre del Proveedor / Razón Social es obligatorio.");
        nombreInput?.focus();
        return;
    }

    const payload = {
        nombre_del_proveedor: nombre.toUpperCase(),
        gte_gral: (document.getElementById('prov-gte-gral')?.value || '').trim(),
        estado: (document.getElementById('prov-estado')?.value || '').trim(),
        ciudad: (document.getElementById('prov-ciudad')?.value || '').trim(),
        tel_de_ofna: (document.getElementById('prov-tel')?.value || '').trim(),
        email_de_empresa: (document.getElementById('prov-email')?.value || '').trim(),
        nombre_contacto_princ: (document.getElementById('prov-contacto-princ')?.value || '').trim(),
        cel_contact_princ: (document.getElementById('prov-cel-princ')?.value || '').trim(),
        nombre_contacto_a: (document.getElementById('prov-contacto-a')?.value || '').trim(),
        cel_contact_a: (document.getElementById('prov-cel-a')?.value || '').trim()
    };

    const btn = document.getElementById('btn-guardar-prov');
    if (btn) btn.disabled = true;

    try {
        const res = await fetch(`${API_URL}/api/proveedores/guardar`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (!res.ok) {
            const err = await res.json().catch(() => ({ detail: res.statusText }));
            throw new Error(err.detail || "Error al guardar el proveedor.");
        }

        alert(`✅ ¡Proveedor "${payload.nombre_del_proveedor}" guardado correctamente!`);
        await cargarCatalogoProveedores();
        seleccionarProveedorDirecto(payload.nombre_del_proveedor);
    } catch (e) {
        alert(`❌ Error al guardar proveedor: ${e.message}`);
    } finally {
        if (btn) btn.disabled = false;
    }
}

function confirmarBajaProveedor() {
    if (!proveedorEditandoNombre) return;
    abrirModalBaja(
        "🚨 Confirmación de Baja de Proveedor",
        `¿Está seguro de que desea eliminar permanentemente al proveedor <strong>${proveedorEditandoNombre}</strong>?<br><br><span style="color: #991b1b; font-size: 12px;">⚠️ Esta acción no se puede deshacer y borrará la empresa del directorio comercial.</span>`,
        async () => {
            try {
                const res = await fetch(`${API_URL}/api/proveedores/eliminar/${encodeURIComponent(proveedorEditandoNombre)}`, { method: 'DELETE' });
                if (!res.ok) {
                    const err = await res.json().catch(() => ({ detail: res.statusText }));
                    throw new Error(err.detail || "Error al eliminar");
                }
                alert(`💥 Proveedor ${proveedorEditandoNombre} eliminado exitosamente.`);
                limpiarFormProveedor();
                await cargarCatalogoProveedores();
            } catch (e) {
                alert(`❌ No se pudo eliminar el proveedor: ${e.message}`);
            }
        }
    );
}

// --------------------------------------------------------------------------
// 🛠️ 4. INVENTARIO MAESTRO DE HARDWARE
// --------------------------------------------------------------------------
async function cargarCatalogoInventario() {
    const tbody = document.getElementById('tabla-inventario-body');
    const badge = document.getElementById('badge-count-inv');
    if (tbody) tbody.innerHTML = `<tr><td colspan="11" style="text-align: center; padding: 20px;">Cargando inventario maestro...</td></tr>`;

    try {
        const res = await fetch(`${API_URL}/api/inventario`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        memoriaInventario = await res.json();

        if (badge) badge.innerText = memoriaInventario.length;
        const tbInv = document.getElementById('tab-count-inv');
        if (tbInv) tbInv.innerText = memoriaInventario.length;
        renderTablaInventario(memoriaInventario);
        poblarSelectorInventario();
    } catch (e) {
        console.error("Error al cargar inventario:", e);
        if (tbody) tbody.innerHTML = `<tr><td colspan="11" style="text-align: center; color: #ef4444; padding: 20px;">Error al conectar con la base de datos de inventario: ${e.message}</td></tr>`;
    }
}

function renderTablaInventario(lista) {
    const tbody = document.getElementById('tabla-inventario-body');
    if (!tbody) return;

    if (!lista || lista.length === 0) {
        tbody.innerHTML = `<tr><td colspan="11" style="text-align: center; padding: 20px; color: var(--text-muted);">Sin piezas registradas en el inventario actualmente.</td></tr>`;
        return;
    }

    tbody.innerHTML = lista.map(i => {
        let badgeBg = "#dcfce7";
        let badgeColor = "#166534";
        const est = (i.estado || '').toUpperCase();

        if (est.includes("REVIS") || est.includes("REPAR")) {
            badgeBg = "#fef3c7";
            badgeColor = "#92400e";
        } else if (est.includes("DAN") || est.includes("DAÑ") || est.includes("BAJA")) {
            badgeBg = "#fee2e2";
            badgeColor = "#991b1b";
        }

        return `
            <tr style="cursor: pointer;" onclick="seleccionarInventarioDirecto('${i.codigo}')" title="Clic para editar esta pieza">
                <td style="font-weight: 700; color: #0f172a;">${i.codigo}</td>
                <td style="font-weight: 600; color: #2563eb;">${i.descripcion || '--'}</td>
                <td>${i.marca || '--'}</td>
                <td>${i.modelo || '--'}</td>
                <td><small>${i.serie || '--'}</small></td>
                <td>${i.responsable || '--'}</td>
                <td><span style="background: ${badgeBg}; color: ${badgeColor}; padding: 3px 8px; border-radius: 6px; font-weight: 700; font-size: 11px;">${i.estado || 'BUEN ESTADO'}</span></td>
                <td>${i.ubicacion || '--'}</td>
                <td>${i.responsiva || '--'}</td>
                <td>${aFechaInput(i.fecha_compra) || '--'}</td>
                <td>${i.observaciones ? i.observaciones.substring(0, 30) + '...' : '--'}</td>
            </tr>
        `;
    }).join('');
}

function filtrarTablaInventario() {
    const q = (document.getElementById('filtro-inventario')?.value || '').toLowerCase().trim();
    if (!q) {
        renderTablaInventario(memoriaInventario);
        return;
    }
    const filtrados = memoriaInventario.filter(i => {
        const texto = `${i.codigo} ${i.descripcion || ''} ${i.marca || ''} ${i.modelo || ''} ${i.serie || ''} ${i.responsable || ''} ${i.estado || ''} ${i.ubicacion || ''}`.toLowerCase();
        return texto.includes(q);
    });
    renderTablaInventario(filtrados);
}

let indiceSeleccionInvEditor = -1;

function activarInventarioEditorSugerencias() {
    const input = document.getElementById('input-buscar-inv-editor');
    filtrarInventarioEditorSugerencias(input ? input.value : '');
}

function filtrarInventarioEditorSugerencias(query) {
    const dropdown = document.getElementById('sugerencias-inv-editor-dropdown');
    const btnLimpiar = document.getElementById('btn-limpiar-busqueda-inv');
    if (!dropdown) return;

    if (btnLimpiar) {
        btnLimpiar.style.display = (query && query.trim()) ? 'block' : 'none';
    }

    const t = normalizarTextoBusqueda(query || '');
    indiceSeleccionInvEditor = -1;

    let resultados = [];
    if (!t) {
        resultados = (memoriaInventario || []).slice(0, 30);
    } else {
        const palabras = t.split(" ").filter(Boolean);
        resultados = (memoriaInventario || []).filter(item => {
            const texto = normalizarTextoBusqueda(`${item.codigo || ''} ${item.descripcion || ''} ${item.marca || ''} ${item.modelo || ''} ${item.serie || ''} ${item.responsable || ''} ${item.ubicacion || ''}`);
            return palabras.every(p => texto.includes(p));
        }).slice(0, 40);
    }

    let html = `
        <div onclick="limpiarFormInventario()" style="padding: 11px 14px; border-bottom: 1px solid #e2e8f0; background: #f0fdf4; color: #166534; font-weight: 700; font-size: 13px; cursor: pointer; display: flex; align-items: center; gap: 8px;">
            <i class="ph ph-plus-circle" style="font-size: 18px; color: #16a34a;"></i>
            <span>➕ Registrar Nuevo Hardware (Crear pieza desde cero)</span>
        </div>
    `;

    if (resultados.length === 0) {
        const qEscaped = (query || '').replace(/</g, "&lt;").replace(/>/g, "&gt;");
        const qParam = (query || '').replace(/'/g, "\\'").replace(/"/g, "&quot;");
        html += `
            <div style="padding: 20px; text-align: center; color: #64748b; font-size: 13px;">
                <i class="ph ph-magnifying-glass" style="font-size: 26px; color: #94a3b8; display: block; margin: 0 auto 6px auto;"></i>
                No se encontró ningún equipo con el criterio "<b>${qEscaped}</b>".<br>
                <button type="button" onclick="crearHardwareConTexto('${qParam}')" style="margin-top: 10px; background: #0284c7; color: white; border: none; padding: 7px 14px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer;">
                    ➕ Registrar nuevo equipo con este dato
                </button>
            </div>
        `;
    } else {
        html += resultados.map((item, idx) => {
            let badgeBg = "#dcfce7";
            let badgeColor = "#166534";
            const est = (item.estado || 'BUEN ESTADO').toUpperCase();
            if (est.includes("REVIS") || est.includes("REPAR")) {
                badgeBg = "#fef3c7";
                badgeColor = "#92400e";
            } else if (est.includes("DAN") || est.includes("DAÑ") || est.includes("BAJA")) {
                badgeBg = "#fee2e2";
                badgeColor = "#991b1b";
            }

            const marcaModelo = [item.marca, item.modelo].filter(Boolean).join(" · ");
            const descSegura = (item.descripcion || 'Sin descripción').replace(/</g, "&lt;").replace(/>/g, "&gt;");
            const codigoSeguro = (item.codigo || '').replace(/'/g, "\\'");

            return `
                <div class="opcion-inv-sugerencia" data-codigo="${item.codigo}" onclick="seleccionarInventarioDirecto('${codigoSeguro}')"
                    style="padding: 10px 14px; border-bottom: 1px solid #f1f5f9; cursor: pointer; transition: background 0.15s; display: flex; justify-content: space-between; align-items: center; gap: 12px;"
                    onmouseover="this.style.background='#eff6ff'" onmouseout="this.style.background='white'">
                    <div style="display: flex; flex-direction: column; gap: 2px; flex: 1; overflow: hidden;">
                        <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                            <span style="background: #0f172a; color: #38bdf8; font-weight: 800; font-family: monospace; font-size: 12px; padding: 2px 7px; border-radius: 4px;">
                                ${item.codigo}
                            </span>
                            <span style="font-weight: 700; color: #1e293b; font-size: 13.5px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                ${descSegura}
                            </span>
                        </div>
                        <div style="font-size: 12px; color: #64748b; display: flex; gap: 10px; flex-wrap: wrap; margin-top: 2px;">
                            ${marcaModelo ? `<span><b>Equipo:</b> ${marcaModelo}</span>` : ''}
                            ${item.serie ? `<span><b>Serie:</b> ${item.serie}</span>` : ''}
                            ${item.ubicacion ? `<span>📍 ${item.ubicacion}</span>` : ''}
                        </div>
                    </div>
                    <div>
                        <span style="background: ${badgeBg}; color: ${badgeColor}; padding: 3px 8px; border-radius: 12px; font-weight: 700; font-size: 11px; white-space: nowrap;">
                            ${item.estado || 'BUEN ESTADO'}
                        </span>
                    </div>
                </div>
            `;
        }).join('');
    }

    dropdown.innerHTML = html;
    dropdown.style.display = 'block';
}

function manejarKeydownInventarioEditor(e) {
    const dropdown = document.getElementById('sugerencias-inv-editor-dropdown');
    if (!dropdown || dropdown.style.display === 'none') {
        if (e.key === 'ArrowDown') {
            activarInventarioEditorSugerencias();
            e.preventDefault();
        }
        return;
    }

    const items = dropdown.querySelectorAll('.opcion-inv-sugerencia');
    if (items.length === 0) return;

    if (e.key === 'ArrowDown') {
        e.preventDefault();
        indiceSeleccionInvEditor = (indiceSeleccionInvEditor + 1) % items.length;
        resaltarOpcionInvEditor(items);
    } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        indiceSeleccionInvEditor = (indiceSeleccionInvEditor - 1 + items.length) % items.length;
        resaltarOpcionInvEditor(items);
    } else if (e.key === 'Enter') {
        e.preventDefault();
        if (indiceSeleccionInvEditor >= 0 && items[indiceSeleccionInvEditor]) {
            items[indiceSeleccionInvEditor].click();
        }
    } else if (e.key === 'Escape') {
        cerrarSugerenciasInventarioEditor();
    }
}

function resaltarOpcionInvEditor(items) {
    items.forEach((it, idx) => {
        if (idx === indiceSeleccionInvEditor) {
            it.style.background = '#e0f2fe';
            it.scrollIntoView({ block: 'nearest' });
        } else {
            it.style.background = 'white';
        }
    });
}

function cerrarSugerenciasInventarioEditor() {
    const dropdown = document.getElementById('sugerencias-inv-editor-dropdown');
    if (dropdown) dropdown.style.display = 'none';
}

function actualizarBannerEditandoInv(item) {
    const banner = document.getElementById('banner-editando-inv');
    if (!banner) return;
    if (item) {
        let badgeBg = "#dcfce7";
        let badgeColor = "#166534";
        const est = (item.estado || 'BUEN ESTADO').toUpperCase();
        if (est.includes("REVIS") || est.includes("REPAR")) {
            badgeBg = "#fef3c7";
            badgeColor = "#92400e";
        } else if (est.includes("DAN") || est.includes("DAÑ") || est.includes("BAJA")) {
            badgeBg = "#fee2e2";
            badgeColor = "#991b1b";
        }

        banner.style.display = 'flex';
        banner.innerHTML = `
            <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
                <span style="font-size: 11.5px; font-weight: 700; color: #0284c7; background: #e0f2fe; padding: 3px 8px; border-radius: 4px; display: inline-flex; align-items: center; gap: 4px;">
                    <i class="ph ph-wrench"></i> EDITANDO PIEZA
                </span>
                <span style="font-weight: 800; font-family: monospace; font-size: 13.5px; color: #0f172a; background: #e2e8f0; padding: 2px 7px; border-radius: 4px;">
                    ${item.codigo}
                </span>
                <span style="font-size: 13.5px; font-weight: 700; color: #1e293b;">
                    ${item.descripcion || 'Sin descripción'}
                </span>
                ${item.marca ? `<span style="font-size: 12.5px; color: #64748b;">(${item.marca})</span>` : ''}
                <span style="background: ${badgeBg}; color: ${badgeColor}; padding: 2px 8px; border-radius: 12px; font-weight: 700; font-size: 11px;">
                    ${item.estado || 'BUEN ESTADO'}
                </span>
            </div>
            <button type="button" onclick="limpiarFormInventario()" style="background: #ffffff; border: 1px solid #cbd5e1; border-radius: 6px; padding: 5px 12px; font-size: 12px; font-weight: 600; color: #475569; cursor: pointer; display: flex; align-items: center; gap: 6px; box-shadow: 0 1px 2px rgba(0,0,0,0.05);">
                <i class="ph ph-plus-circle" style="color: #0284c7;"></i> Nuevo Hardware
            </button>
        `;
    } else {
        banner.style.display = 'none';
    }
}

function crearHardwareConTexto(texto) {
    limpiarFormInventario();
    const descInput = document.getElementById('inv-descripcion');
    if (descInput) {
        descInput.value = texto;
        descInput.focus();
    }
}

function poblarSelectorInventario() {
    const sel = document.getElementById('selector-inv-editor');
    if (!sel) return;
    const valorPrevio = sel.value;
    sel.innerHTML = `<option value="nuevo">➕ Registrar Nuevo Hardware</option>` +
        memoriaInventario.map(i => `<option value="${i.codigo}">${i.codigo} - ${i.descripcion || ''} (${i.marca || 'S/M'})</option>`).join('');

    if (valorPrevio && memoriaInventario.some(i => i.codigo === valorPrevio)) {
        sel.value = valorPrevio;
        const itemActual = memoriaInventario.find(i => i.codigo === valorPrevio);
        actualizarBannerEditandoInv(itemActual);
    } else {
        sel.value = 'nuevo';
        actualizarBannerEditandoInv(null);
    }
}

function seleccionarInventarioDirecto(codigo) {
    const sel = document.getElementById('selector-inv-editor');
    if (sel) {
        sel.value = codigo;
        alCambiarSelectorInventario();
    }
    cerrarSugerenciasInventarioEditor();
    const editor = document.getElementById('editor-activos-seccion');
    if (editor) {
        editor.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}

function alCambiarSelectorInventario() {
    const sel = document.getElementById('selector-inv-editor');
    const val = sel ? sel.value : 'nuevo';

    if (val === 'nuevo') {
        limpiarFormInventario();
        return;
    }

    const i = memoriaInventario.find(item => item.codigo === val);
    if (!i) return;

    inventarioEditandoCodigo = i.codigo;
    const codInput = document.getElementById('inv-codigo');
    if (codInput) {
        codInput.value = i.codigo;
        codInput.disabled = true;
    }
    document.getElementById('inv-descripcion').value = i.descripcion || '';
    document.getElementById('inv-marca').value = i.marca || '';
    document.getElementById('inv-modelo').value = i.modelo || '';
    document.getElementById('inv-serie').value = i.serie || '';
    document.getElementById('inv-responsiva').value = i.responsiva || '';
    document.getElementById('inv-responsable').value = i.responsable || '';
    document.getElementById('inv-fecha-compra').value = aFechaInput(i.fecha_compra);
    document.getElementById('inv-estado').value = (i.estado || 'BUEN ESTADO').toUpperCase();
    document.getElementById('inv-ubicacion').value = i.ubicacion || '';
    document.getElementById('inv-observaciones').value = i.observaciones || '';

    document.getElementById('btn-eliminar-inv').style.display = 'inline-flex';
    document.getElementById('lbl-btn-guardar-inv').innerText = 'Actualizar Hardware';

    const inputBusqueda = document.getElementById('input-buscar-inv-editor');
    if (inputBusqueda) {
        inputBusqueda.value = `${i.codigo} - ${i.descripcion || ''}`;
        const btnLimpiar = document.getElementById('btn-limpiar-busqueda-inv');
        if (btnLimpiar) btnLimpiar.style.display = 'block';
    }
    actualizarBannerEditandoInv(i);
    cerrarSugerenciasInventarioEditor();
}

function limpiarFormInventario() {
    inventarioEditandoCodigo = null;
    const codInput = document.getElementById('inv-codigo');
    if (codInput) {
        codInput.value = '';
        codInput.disabled = false;
        setTimeout(() => codInput.focus(), 50);
    }
    ['inv-descripcion', 'inv-marca', 'inv-modelo', 'inv-serie', 'inv-responsiva', 'inv-responsable', 'inv-ubicacion', 'inv-observaciones'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.value = '';
    });
    const fecInput = document.getElementById('inv-fecha-compra');
    if (fecInput) fecInput.value = '';

    const estInput = document.getElementById('inv-estado');
    if (estInput) estInput.value = 'BUEN ESTADO';

    const btnDel = document.getElementById('btn-eliminar-inv');
    if (btnDel) btnDel.style.display = 'none';

    const lbl = document.getElementById('lbl-btn-guardar-inv');
    if (lbl) lbl.innerText = 'Guardar Hardware Nuevo';

    const sel = document.getElementById('selector-inv-editor');
    if (sel) sel.value = 'nuevo';

    const inputBusqueda = document.getElementById('input-buscar-inv-editor');
    if (inputBusqueda) inputBusqueda.value = '';
    const btnLimpiar = document.getElementById('btn-limpiar-busqueda-inv');
    if (btnLimpiar) btnLimpiar.style.display = 'none';

    actualizarBannerEditandoInv(null);
    cerrarSugerenciasInventarioEditor();
}

async function guardarInventarioForm() {
    const codInput = document.getElementById('inv-codigo');
    const codigo = (codInput?.value || '').trim();
    const desc = (document.getElementById('inv-descripcion')?.value || '').trim();

    if (!codigo) {
        alert("⚠️ El Código del Hardware es obligatorio (Ej. CAM-01).");
        codInput?.focus();
        return;
    }
    if (!desc) {
        alert("⚠️ La Descripción del Hardware es obligatoria.");
        document.getElementById('inv-descripcion')?.focus();
        return;
    }

    const payload = {
        codigo: codigo.toUpperCase(),
        descripcion: desc,
        marca: (document.getElementById('inv-marca')?.value || '').trim(),
        modelo: (document.getElementById('inv-modelo')?.value || '').trim(),
        serie: (document.getElementById('inv-serie')?.value || '').trim(),
        responsiva: (document.getElementById('inv-responsiva')?.value || '').trim(),
        responsable: (document.getElementById('inv-responsable')?.value || '').trim(),
        fecha_compra: document.getElementById('inv-fecha-compra')?.value || null,
        estado: document.getElementById('inv-estado')?.value || 'BUEN ESTADO',
        ubicacion: (document.getElementById('inv-ubicacion')?.value || '').trim(),
        observaciones: (document.getElementById('inv-observaciones')?.value || '').trim()
    };

    const btn = document.getElementById('btn-guardar-inv');
    if (btn) btn.disabled = true;

    try {
        const res = await fetch(`${API_URL}/api/inventario/guardar`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (!res.ok) {
            const err = await res.json().catch(() => ({ detail: res.statusText }));
            throw new Error(err.detail || "Error al guardar el hardware.");
        }

        alert(`✅ ¡Hardware "${payload.codigo}" sincronizado con éxito!`);
        await cargarCatalogoInventario();
        seleccionarInventarioDirecto(payload.codigo);
    } catch (e) {
        alert(`❌ Error al guardar hardware: ${e.message}`);
    } finally {
        if (btn) btn.disabled = false;
    }
}

function confirmarBajaInventario() {
    if (!inventarioEditandoCodigo) return;
    abrirModalBaja(
        "🚨 Confirmación de Baja de Hardware",
        `¿Está seguro de que desea eliminar la pieza <strong>${inventarioEditandoCodigo}</strong>?<br><br><span style="color: #991b1b; font-size: 12px;">⚠️ Esta acción borrará permanentemente el equipo del inventario maestro.</span>`,
        async () => {
            try {
                const res = await fetch(`${API_URL}/api/inventario/eliminar/${encodeURIComponent(inventarioEditandoCodigo)}`, { method: 'DELETE' });
                if (!res.ok) {
                    const err = await res.json().catch(() => ({ detail: res.statusText }));
                    throw new Error(err.detail || "Error al eliminar");
                }
                alert(`💥 Equipo ${inventarioEditandoCodigo} eliminado exitosamente.`);
                limpiarFormInventario();
                await cargarCatalogoInventario();
            } catch (e) {
                alert(`❌ No se pudo eliminar la pieza: ${e.message}`);
            }
        }
    );
}

// ==========================================================================
// 🦺 SUB-MÓDULO: CATÁLOGO DE EMPLEADOS Y ACCESOS
// ==========================================================================
let memoriaEmpleados = [];
let empleadoEditandoId = null;

async function cargarCatalogoEmpleados() {
    const tbody = document.getElementById('tabla-empleados-body');
    const badge = document.getElementById('badge-count-empleados');
    const tabBadge = document.getElementById('tab-count-emp');
    const hubBadge = document.getElementById('hub-count-emp');
    const metricTotal = document.getElementById('emp-metric-total');
    const metricActivos = document.getElementById('emp-metric-activos');
    const metricBajas = document.getElementById('emp-metric-bajas');

    try {
        const res = await fetch(`${API_URL}/api/empleados`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = await res.json();
        memoriaEmpleados = Array.isArray(data) ? data : [];

        const total = memoriaEmpleados.length;
        const activos = memoriaEmpleados.filter(e => (e.rol || '').toUpperCase() !== 'BAJA').length;
        const bajas = total - activos;

        if (badge) badge.innerText = total;
        if (tabBadge) tabBadge.innerText = total;
        if (hubBadge) hubBadge.innerText = `${total} colaboradores`;
        if (metricTotal) metricTotal.innerText = total;
        if (metricActivos) metricActivos.innerText = activos;
        if (metricBajas) metricBajas.innerText = bajas;

        poblarSelectorEmpleados();
        renderTablaEmpleados(memoriaEmpleados);
    } catch (e) {
        console.error("Error al cargar empleados:", e);
        if (tbody) {
            tbody.innerHTML = `<tr><td colspan="9" style="text-align: center; color: #ef4444; padding: 20px;">
                <i class="ph ph-warning-circle"></i> Error al conectar con el servidor: ${e.message}
            </td></tr>`;
        }
    }
}

function poblarSelectorEmpleados() {
    const sel = document.getElementById('selector-emp-editor');
    if (!sel) return;
    const valActual = sel.value;
    sel.innerHTML = '<option value="nuevo">➕ Alta de Nuevo Empleado al Sistema</option>';

    const ordenados = [...memoriaEmpleados].sort((a, b) => (a.nombre || '').localeCompare(b.nombre || ''));
    ordenados.forEach(emp => {
        const opt = document.createElement('option');
        opt.value = emp.id_empleado;
        const esBaja = (emp.rol || '').toUpperCase() === 'BAJA';
        opt.textContent = `${esBaja ? '🚪 [BAJA] ' : '👤 '}${emp.nombre || 'Sin Nombre'} (ID: ${emp.id_empleado}) — ${emp.depto || 'Sin Depto'}`;
        sel.appendChild(opt);
    });

    if (valActual && Array.from(sel.options).some(o => o.value === valActual)) {
        sel.value = valActual;
    }
}

function renderTablaEmpleados(lista) {
    const tbody = document.getElementById('tabla-empleados-body');
    if (!tbody) return;

    if (!lista || lista.length === 0) {
        tbody.innerHTML = '<tr><td colspan="9" style="text-align: center; color: #64748b; padding: 20px;">No se encontraron colaboradores.</td></tr>';
        return;
    }

    tbody.innerHTML = lista.map(e => {
        const esBaja = (e.rol || '').toUpperCase() === 'BAJA';
        const badgeEstatus = esBaja
            ? '<span style="background: #fee2e2; color: #991b1b; padding: 3px 8px; border-radius: 12px; font-size: 11.5px; font-weight: 700;">🚪 Baja</span>'
            : '<span style="background: #dcfce7; color: #166534; padding: 3px 8px; border-radius: 12px; font-size: 11.5px; font-weight: 700;">✅ Activo</span>';

        return `<tr onclick="seleccionarEmpleadoDirecto('${e.id_empleado}')" style="cursor: pointer;" title="Clic para editar este colaborador">
            <td><strong>${e.id_empleado || '—'}</strong></td>
            <td>${e.nombre || '—'}</td>
            <td>${e.depto || '—'}</td>
            <td><span style="background: #f1f5f9; padding: 2px 6px; border-radius: 4px; font-size: 12px; font-weight: 600;">${e.rol || '—'}</span></td>
            <td>${e.cel || '—'}</td>
            <td>${e.email || '—'}</td>
            <td>${e.fecha_ing || '—'}</td>
            <td>${e.licencia_vence || '—'}</td>
            <td>${badgeEstatus}</td>
        </tr>`;
    }).join('');
}

function filtrarTablaEmpleados() {
    const q = (document.getElementById('filtro-empleados')?.value || '').toLowerCase().trim();
    if (!q) {
        renderTablaEmpleados(memoriaEmpleados);
        return;
    }
    const filtrados = memoriaEmpleados.filter(e => {
        return (e.nombre || '').toLowerCase().includes(q) ||
               String(e.id_empleado || '').toLowerCase().includes(q) ||
               (e.depto || '').toLowerCase().includes(q) ||
               (e.rol || '').toLowerCase().includes(q) ||
               (e.email || '').toLowerCase().includes(q) ||
               (e.cel || '').toLowerCase().includes(q);
    });
    renderTablaEmpleados(filtrados);
}

function seleccionarEmpleadoDirecto(id) {
    const sel = document.getElementById('selector-emp-editor');
    if (sel) {
        sel.value = id;
        alCambiarSelectorEmpleado();
        sel.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
}

function alCambiarSelectorEmpleado() {
    const sel = document.getElementById('selector-emp-editor');
    const val = sel?.value;

    if (!val || val === 'nuevo') {
        limpiarFormEmpleado();
        return;
    }

    const emp = memoriaEmpleados.find(e => String(e.id_empleado) === String(val));
    if (!emp) return;

    empleadoEditandoId = emp.id_empleado;

    const inpId = document.getElementById('emp-id');
    if (inpId) {
        inpId.value = emp.id_empleado || '';
        inpId.disabled = true;
    }
    const inpNombre = document.getElementById('emp-nombre');
    if (inpNombre) inpNombre.value = emp.nombre || '';

    const inpDepto = document.getElementById('emp-depto');
    if (inpDepto && emp.depto) inpDepto.value = emp.depto;

    const inpRol = document.getElementById('emp-rol');
    if (inpRol && emp.rol) inpRol.value = emp.rol;

    const inpCel = document.getElementById('emp-cel');
    if (inpCel) inpCel.value = emp.cel || '';

    const inpEmail = document.getElementById('emp-email');
    if (inpEmail) inpEmail.value = emp.email || '';

    const inpIng = document.getElementById('emp-fecha-ing');
    if (inpIng) inpIng.value = emp.fecha_ing || '';

    const inpNac = document.getElementById('emp-fecha-nac');
    if (inpNac) inpNac.value = emp.fecha_nac || '';

    const inpLic = document.getElementById('emp-licencia-vence');
    if (inpLic) inpLic.value = emp.licencia_vence || '';

    const inpPwd = document.getElementById('emp-password');
    if (inpPwd) inpPwd.value = emp.password || '';

    const lblBtn = document.getElementById('lbl-btn-guardar-emp');
    if (lblBtn) lblBtn.innerText = 'Actualizar Acceso / Colaborador';

    const btnDel = document.getElementById('btn-eliminar-emp');
    if (btnDel) btnDel.style.display = 'inline-flex';
}

function limpiarFormEmpleado() {
    empleadoEditandoId = null;
    const sel = document.getElementById('selector-emp-editor');
    if (sel) sel.value = 'nuevo';

    const inpId = document.getElementById('emp-id');
    if (inpId) {
        inpId.value = '';
        inpId.disabled = false;
    }
    const inpNombre = document.getElementById('emp-nombre');
    if (inpNombre) inpNombre.value = '';

    const inpDepto = document.getElementById('emp-depto');
    if (inpDepto) inpDepto.selectedIndex = 0;

    const inpRol = document.getElementById('emp-rol');
    if (inpRol) inpRol.selectedIndex = 0;

    const inpCel = document.getElementById('emp-cel');
    if (inpCel) inpCel.value = '';

    const inpEmail = document.getElementById('emp-email');
    if (inpEmail) inpEmail.value = '';

    const inpIng = document.getElementById('emp-fecha-ing');
    if (inpIng) inpIng.value = new Date().toISOString().split('T')[0];

    const inpNac = document.getElementById('emp-fecha-nac');
    if (inpNac) inpNac.value = '';

    const inpLic = document.getElementById('emp-licencia-vence');
    if (inpLic) inpLic.value = '';

    const inpPwd = document.getElementById('emp-password');
    if (inpPwd) inpPwd.value = 'vpro123';

    const lblBtn = document.getElementById('lbl-btn-guardar-emp');
    if (lblBtn) lblBtn.innerText = 'Dar de Alta al Sistema';

    const btnDel = document.getElementById('btn-eliminar-emp');
    if (btnDel) btnDel.style.display = 'none';
}

async function guardarEmpleadoForm() {
    const id = document.getElementById('emp-id')?.value?.trim();
    const nombre = document.getElementById('emp-nombre')?.value?.trim();
    const depto = document.getElementById('emp-depto')?.value;
    const rol = document.getElementById('emp-rol')?.value;
    const cel = document.getElementById('emp-cel')?.value?.trim();
    const email = document.getElementById('emp-email')?.value?.trim();
    const fecha_ing = document.getElementById('emp-fecha-ing')?.value || null;
    const fecha_nac = document.getElementById('emp-fecha-nac')?.value || null;
    const licencia_vence = document.getElementById('emp-licencia-vence')?.value || null;
    const password = document.getElementById('emp-password')?.value?.trim() || 'vpro123';

    if (!id || !nombre) {
        alert("⚠️ El ID de empleado y el Nombre Completo son obligatorios.");
        return;
    }

    if (!empleadoEditandoId && memoriaEmpleados.some(e => String(e.id_empleado) === id)) {
        alert(`⚠️ Ya existe un empleado con el ID '${id}'. Usa una clave diferente.`);
        return;
    }

    if (!password.startsWith("$2b$")) {
        if (password.length < 8 || !/[A-Z]/.test(password) || !/[a-z]/.test(password) || !/[0-9]/.test(password) || !/[\W_]/.test(password)) {
            alert("⚠️ La contraseña es demasiado simple. Debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un carácter especial.");
            return;
        }
    }

    const payload = {
        id_empleado: id,
        nombre: nombre,
        depto: depto,
        rol: rol,
        cel: cel,
        email: email,
        fecha_ing: fecha_ing,
        fecha_nac: fecha_nac,
        licencia_vence: licencia_vence,
        password: password
    };

    const btn = document.getElementById('btn-guardar-emp');
    if (btn) btn.disabled = true;

    try {
        const res = await fetch(`${API_URL}/api/empleados/guardar`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        if (!res.ok) {
            const err = await res.json().catch(() => ({ detail: res.statusText }));
            throw new Error(err.detail || "Error al guardar");
        }
        alert(`✅ Empleado '${nombre}' guardado exitosamente.`);
        await cargarCatalogoEmpleados();
        seleccionarEmpleadoDirecto(id);
    } catch (e) {
        alert(`❌ No se pudo guardar el empleado: ${e.message}`);
    } finally {
        if (btn) btn.disabled = false;
    }
}

function confirmarBajaEmpleado() {
    if (!empleadoEditandoId) return;
    const emp = memoriaEmpleados.find(e => String(e.id_empleado) === String(empleadoEditandoId));
    const nom = emp ? emp.nombre : empleadoEditandoId;

    abrirModalBaja(
        "🚨 Confirmación de Eliminación de Empleado",
        `¿Está seguro de que desea eliminar a <strong>${nom}</strong> (ID: ${empleadoEditandoId})?<br><br><span style="color: #991b1b; font-size: 12px;">⚠️ Esta acción eliminará permanentemente al colaborador y sus accesos al sistema.</span>`,
        async () => {
            try {
                const res = await fetch(`${API_URL}/api/empleados/eliminar/${encodeURIComponent(empleadoEditandoId)}`, { method: 'DELETE' });
                if (!res.ok) {
                    const err = await res.json().catch(() => ({ detail: res.statusText }));
                    throw new Error(err.detail || "Error al eliminar");
                }
                alert(`💥 Empleado ${nom} eliminado exitosamente.`);
                limpiarFormEmpleado();
                await cargarCatalogoEmpleados();
            } catch (e) {
                alert(`❌ No se pudo eliminar el empleado: ${e.message}`);
            }
        }
    );
}

// ==========================================================================
// 🤝 SUB-MÓDULO: REUNIONES / PROSPECTOS
// ==========================================================================
let memoriaReuniones = [];
let asistentesReunionSeleccionados = [];

async function cargarCatalogoReuniones() {
    const tbody = document.getElementById('tabla-reuniones-body');
    const badge = document.getElementById('badge-count-reuniones');
    const tabBadge = document.getElementById('tab-count-reu');
    const hubBadge = document.getElementById('hub-count-reu');

    try {
        const res = await fetch(`${API_URL}/api/reuniones/historial`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = await res.json();
        memoriaReuniones = Array.isArray(data) ? data : [];

        const total = memoriaReuniones.length;
        if (badge) badge.innerText = total;
        if (tabBadge) tabBadge.innerText = total;
        if (hubBadge) hubBadge.innerText = `${total} minutas`;

        poblarSelectorReuniones();
        await poblarClientesDropdownReunion();
        await poblarAsistentesDropdownReunion();
        renderTablaReuniones(memoriaReuniones);
    } catch (e) {
        console.error("Error al cargar reuniones:", e);
        if (tbody) {
            tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: #ef4444; padding: 20px;">
                <i class="ph ph-warning-circle"></i> Error al conectar con el servidor: ${e.message}
            </td></tr>`;
        }
    }
}

async function poblarClientesDropdownReunion() {
    const sel = document.getElementById('reu-cliente');
    if (!sel) return;
    const valActual = sel.value;

    let listaClientes = [];
    if (typeof memoriaClientes !== 'undefined' && memoriaClientes && memoriaClientes.length > 0) {
        listaClientes = memoriaClientes.map(c => c.cliente_empresa || '').filter(Boolean);
    } else {
        try {
            const res = await fetch(`${API_URL}/api/reuniones/clientes`);
            if (res.ok) {
                const data = await res.json();
                listaClientes = Array.isArray(data) ? data : [];
            }
        } catch (e) {
            console.warn("No se pudieron cargar clientes para reunión:", e);
        }
    }

    const unicos = [...new Set(listaClientes)].sort((a, b) => a.localeCompare(b));

    sel.innerHTML = '<option value="">-- Seleccionar Cliente Registrado --</option>';
    unicos.forEach(c => {
        const opt = document.createElement('option');
        opt.value = c;
        opt.textContent = c;
        sel.appendChild(opt);
    });

    const optOtro = document.createElement('option');
    optOtro.value = '__otro__';
    optOtro.textContent = '➕ [Otro / Prospecto no registrado...]';
    sel.appendChild(optOtro);

    if (valActual && Array.from(sel.options).some(o => o.value === valActual)) {
        sel.value = valActual;
    }
}

function alCambiarClienteReunion() {
    const sel = document.getElementById('reu-cliente');
    const wrapOtro = document.getElementById('wrap-reu-cliente-otro');
    const inpOtro = document.getElementById('reu-cliente-otro');
    if (!sel || !wrapOtro) return;

    if (sel.value === '__otro__') {
        wrapOtro.style.display = 'block';
        if (inpOtro) inpOtro.focus();
    } else {
        wrapOtro.style.display = 'none';
        if (inpOtro) inpOtro.value = '';
    }
}

async function poblarAsistentesDropdownReunion() {
    const sel = document.getElementById('sel-reu-empleado-agregar');
    if (!sel) return;

    let listaAsistentes = [];
    if (typeof memoriaEmpleados !== 'undefined' && memoriaEmpleados && memoriaEmpleados.length > 0) {
        listaAsistentes = memoriaEmpleados
            .filter(e => (e.rol || '').toUpperCase() !== 'BAJA' && (e.rol || '').toUpperCase() !== 'PROVEEDOR')
            .map(e => e.nombre || '')
            .filter(Boolean);
    } else {
        try {
            const res = await fetch(`${API_URL}/api/reuniones/asistentes`);
            if (res.ok) {
                const data = await res.json();
                listaAsistentes = Array.isArray(data) ? data : [];
            }
        } catch (e) {
            console.warn("No se pudieron cargar asistentes activos:", e);
        }
    }

    const unicos = [...new Set(listaAsistentes)].sort((a, b) => a.localeCompare(b));
    sel.innerHTML = '<option value="">+ Seleccionar Colaborador Activo...</option>';
    unicos.forEach(nombre => {
        const opt = document.createElement('option');
        opt.value = nombre;
        opt.textContent = `👤 ${nombre}`;
        sel.appendChild(opt);
    });
}

function renderAsistentesTagsReunion() {
    const cont = document.getElementById('wrap-reu-asistentes-tags');
    if (!cont) return;

    if (!asistentesReunionSeleccionados || asistentesReunionSeleccionados.length === 0) {
        cont.innerHTML = '<span id="reu-asistentes-placeholder" style="color: #94a3b8; font-size: 12.5px;">Ningún asistente seleccionado aún.</span>';
        return;
    }

    cont.innerHTML = asistentesReunionSeleccionados.map(nombre => `
        <span class="tag-pill" style="background: #e0e7ff; color: #3730a3; border: 1px solid #c7d2fe; padding: 4px 10px; border-radius: 16px; font-size: 12px; display: inline-flex; align-items: center; gap: 6px;">
            <span>${nombre}</span>
            <span style="cursor: pointer; font-weight: bold; color: #4338ca; font-size: 11px;" onclick="removerAsistenteReunion('${nombre.replace(/'/g, "\\'")}')" title="Quitar">✖</span>
        </span>
    `).join('');
}

function agregarAsistenteReunion(nombre) {
    if (!nombre) return;
    const n = nombre.trim();
    if (!asistentesReunionSeleccionados.includes(n)) {
        asistentesReunionSeleccionados.push(n);
        renderAsistentesTagsReunion();
    }
}

function removerAsistenteReunion(nombre) {
    asistentesReunionSeleccionados = asistentesReunionSeleccionados.filter(item => item !== nombre);
    renderAsistentesTagsReunion();
}

function agregarAsistenteExternoPrompt() {
    const ext = prompt("Ingrese el nombre completo del asistente o contacto externo:");
    if (ext && ext.trim()) {
        agregarAsistenteReunion(ext.trim());
    }
}

function poblarSelectorReuniones() {
    const sel = document.getElementById('selector-reu-editor');
    if (!sel) return;
    const valActual = sel.value;
    sel.innerHTML = '<option value="nuevo">✨ --- REGISTRAR NUEVA REUNIÓN ---</option>';

    memoriaReuniones.forEach(r => {
        const opt = document.createElement('option');
        opt.value = r.id_reunion;
        opt.textContent = `🗓️ ${r.fecha_reunion || ''} | ${r.cliente_tentativo || 'Sin Cliente'} - ${r.nombre_proyecto_tentativo || 'Sin Proyecto'}`;
        sel.appendChild(opt);
    });

    if (valActual && Array.from(sel.options).some(o => o.value === valActual)) {
        sel.value = valActual;
    }
}

function renderTablaReuniones(lista) {
    const tbody = document.getElementById('tabla-reuniones-body');
    if (!tbody) return;

    if (!lista || lista.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #64748b; padding: 20px;">No hay prospectos activos. Todas las minutas están convertidas a OPs.</td></tr>';
        return;
    }

    tbody.innerHTML = lista.map(r => {
        const pres = parseFloat(r.presupuesto_estimado) || 0;
        const presFmt = pres ? `$${pres.toLocaleString('es-MX', { minimumFractionDigits: 2 })}` : '$0.00';

        return `<tr onclick="seleccionarReunionDirecto(${r.id_reunion})" style="cursor: pointer;" title="Clic para editar esta minuta">
            <td><strong>${r.fecha_reunion || '—'}</strong></td>
            <td><strong>${r.cliente_tentativo || '—'}</strong></td>
            <td>${r.nombre_proyecto_tentativo || '—'}</td>
            <td>${r.asistentes || '—'}</td>
            <td><span style="color: #059669; font-weight: 700;">${presFmt}</span></td>
            <td>${r.fecha_probable_evento || '—'}</td>
            <td style="max-width: 250px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">${r.minuta_acuerdos || '—'}</td>
        </tr>`;
    }).join('');
}

function seleccionarReunionDirecto(id) {
    const sel = document.getElementById('selector-reu-editor');
    if (sel) {
        sel.value = id;
        alCambiarSelectorReunion();
        sel.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
}

function alCambiarSelectorReunion() {
    const sel = document.getElementById('selector-reu-editor');
    const val = sel?.value;

    if (!val || val === 'nuevo') {
        limpiarFormReunion();
        return;
    }

    const r = memoriaReuniones.find(item => String(item.id_reunion) === String(val));
    if (!r) return;

    const inpId = document.getElementById('reu-id');
    if (inpId) inpId.value = r.id_reunion || '';

    const inpFecha = document.getElementById('reu-fecha');
    if (inpFecha) inpFecha.value = r.fecha_reunion || '';

    // Manejar Cliente Tentativo (dropdown existente o nuevo prospecto)
    const selCliente = document.getElementById('reu-cliente');
    const wrapOtro = document.getElementById('wrap-reu-cliente-otro');
    const inpOtro = document.getElementById('reu-cliente-otro');
    if (selCliente) {
        const valorCliente = (r.cliente_tentativo || '').trim();
        const existeEnOpciones = Array.from(selCliente.options).some(o => o.value === valorCliente);
        if (existeEnOpciones && valorCliente) {
            selCliente.value = valorCliente;
            if (wrapOtro) wrapOtro.style.display = 'none';
            if (inpOtro) inpOtro.value = '';
        } else if (valorCliente) {
            selCliente.value = '__otro__';
            if (wrapOtro) wrapOtro.style.display = 'block';
            if (inpOtro) inpOtro.value = valorCliente;
        } else {
            selCliente.value = '';
            if (wrapOtro) wrapOtro.style.display = 'none';
            if (inpOtro) inpOtro.value = '';
        }
    }

    const inpProy = document.getElementById('reu-proyecto');
    if (inpProy) inpProy.value = r.nombre_proyecto_tentativo || '';

    // Manejar Asistentes interactivos
    if (r.asistentes) {
        asistentesReunionSeleccionados = String(r.asistentes)
            .split(',')
            .map(s => s.trim())
            .filter(Boolean);
    } else {
        asistentesReunionSeleccionados = [];
    }
    renderAsistentesTagsReunion();

    const inpPres = document.getElementById('reu-presupuesto');
    if (inpPres) inpPres.value = r.presupuesto_estimado || 0;

    const inpProb = document.getElementById('reu-fecha-probable');
    if (inpProb) inpProb.value = r.fecha_probable_evento || '';

    const inpMin = document.getElementById('reu-minuta');
    if (inpMin) inpMin.value = r.minuta_acuerdos || '';

    const lblBtn = document.getElementById('lbl-btn-guardar-reu');
    if (lblBtn) lblBtn.innerText = '🔄 Actualizar Minuta de Reunión';

    const btnDel = document.getElementById('btn-eliminar-reu');
    if (btnDel) btnDel.style.display = 'inline-flex';
}

function limpiarFormReunion() {
    const sel = document.getElementById('selector-reu-editor');
    if (sel) sel.value = 'nuevo';

    const inpId = document.getElementById('reu-id');
    if (inpId) inpId.value = '';

    const inpFecha = document.getElementById('reu-fecha');
    if (inpFecha) inpFecha.value = new Date().toISOString().split('T')[0];

    const selCliente = document.getElementById('reu-cliente');
    if (selCliente) selCliente.value = '';

    const wrapOtro = document.getElementById('wrap-reu-cliente-otro');
    if (wrapOtro) wrapOtro.style.display = 'none';

    const inpOtro = document.getElementById('reu-cliente-otro');
    if (inpOtro) inpOtro.value = '';

    const inpProy = document.getElementById('reu-proyecto');
    if (inpProy) inpProy.value = '';

    asistentesReunionSeleccionados = [];
    renderAsistentesTagsReunion();

    const inpPres = document.getElementById('reu-presupuesto');
    if (inpPres) inpPres.value = '';

    const inpProb = document.getElementById('reu-fecha-probable');
    if (inpProb) inpProb.value = '';

    const inpMin = document.getElementById('reu-minuta');
    if (inpMin) inpMin.value = '';

    const lblBtn = document.getElementById('lbl-btn-guardar-reu');
    if (lblBtn) lblBtn.innerText = '💾 Guardar Nueva Reunión';

    const btnDel = document.getElementById('btn-eliminar-reu');
    if (btnDel) btnDel.style.display = 'none';
}

async function guardarReunionForm() {
    const id = document.getElementById('reu-id')?.value;
    const fecha = document.getElementById('reu-fecha')?.value;

    const selCliente = document.getElementById('reu-cliente')?.value;
    let cliente = selCliente;
    if (selCliente === '__otro__') {
        cliente = document.getElementById('reu-cliente-otro')?.value?.trim();
    }

    const proyecto = document.getElementById('reu-proyecto')?.value?.trim();
    const asistentes = asistentesReunionSeleccionados.join(', ');
    const presupuesto = document.getElementById('reu-presupuesto')?.value;
    const fecha_probable = document.getElementById('reu-fecha-probable')?.value || null;
    const minuta = document.getElementById('reu-minuta')?.value?.trim();

    if (!fecha || !cliente || !proyecto || !asistentes || !minuta) {
        alert("⚠️ Por favor completa los campos obligatorios (*):\n- Fecha de Reunión\n- Cliente Tentativo\n- Nombre de la Reunión / Proyecto\n- Al menos un Asistente seleccionado\n- Minuta y Acuerdos");
        return;
    }

    const payload = {
        id_reunion: id ? parseInt(id) : null,
        fecha_reunion: fecha,
        cliente_tentativo: cliente,
        nombre_proyecto_tentativo: proyecto,
        asistentes: asistentes,
        minuta_acuerdos: minuta,
        presupuesto_estimado: parseFloat(presupuesto) || 0.0,
        fecha_probable_evento: fecha_probable
    };

    const btn = document.getElementById('btn-guardar-reu');
    if (btn) btn.disabled = true;

    try {
        const res = await fetch(`${API_URL}/api/reuniones`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        if (!res.ok) {
            const err = await res.json().catch(() => ({ detail: res.statusText }));
            throw new Error(err.detail || "Error al guardar");
        }
        alert(id ? "✅ Minuta de reunión actualizada correctamente." : "✅ Minuta de reunión registrada exitosamente.");
        await cargarCatalogoReuniones();
        limpiarFormReunion();
    } catch (e) {
        alert(`❌ Error al guardar minuta: ${e.message}`);
    } finally {
        if (btn) btn.disabled = false;
    }
}

function confirmarEliminarReunion() {
    const id = document.getElementById('reu-id')?.value;
    if (!id) return;

    const r = memoriaReuniones.find(item => String(item.id_reunion) === String(id));
    const tituloReu = r ? `${r.cliente_tentativo} - ${r.nombre_proyecto_tentativo}` : `Reunión #${id}`;

    abrirModalBaja(
        "🚨 Confirmación de Eliminación de Minuta",
        `¿Está seguro de que desea eliminar la minuta de <strong>${tituloReu}</strong>?<br><br><span style="color: #991b1b; font-size: 12px;">⚠️ Esta minuta se borrará permanentemente de la lista de prospectos activos.</span>`,
        async () => {
            try {
                const res = await fetch(`${API_URL}/api/reuniones/${id}`, { method: 'DELETE' });
                if (!res.ok) {
                    const err = await res.json().catch(() => ({ detail: res.statusText }));
                    throw new Error(err.detail || "Error al eliminar");
                }
                alert(`💥 Minuta de reunión eliminada correctamente.`);
                limpiarFormReunion();
                await cargarCatalogoReuniones();
            } catch (e) {
                alert(`❌ No se pudo eliminar la minuta: ${e.message}`);
            }
        }
    );
}

// ==========================================================================
// 📸 / 🎥 GESTIÓN DE EVIDENCIAS MULTIMEDIA (FOTOS MÁX 1MB Y VIDEOS MP4 MÁX 5MB)
// ==========================================================================
window.opFotosEvidenciaActuales = [];

function formatearTextoBadgeEvidencias(fotos) {
    if (!fotos || !Array.isArray(fotos) || fotos.length === 0) {
        return '0 evidencias registradas';
    }
    const videos = fotos.filter(u => String(u).toLowerCase().endsWith('.mp4')).length;
    const fotoss = fotos.length - videos;
    let partes = [];
    if (fotoss > 0) partes.push(`${fotoss} foto(s)`);
    if (videos > 0) partes.push(`${videos} video(s) MP4`);
    return `${fotos.length} evidencia(s) [${partes.join(', ')}]`;
}

function generarHtmlGaleriaFotosEvidencia(fotos, isReadOnly = false, idEvento = null) {
    if (!fotos || !Array.isArray(fotos) || fotos.length === 0) {
        return `
            <div style="grid-column: 1 / -1; text-align: center; padding: 22px; color: #94a3b8; font-size: 13px; font-style: italic; background: #ffffff; border-radius: 8px; border: 1.5px dashed #cbd5e1;">
                <i class="ph ph-film-slate" style="font-size: 26px; color: #94a3b8; display: block; margin-bottom: 4px;"></i>
                No hay fotografías o videos de evidencia integrados para este evento.
            </div>
        `;
    }

    return fotos.map((url, idx) => {
        const urlLimpia = String(url).trim();
        const nombreArchivo = urlLimpia.split('/').pop() || `Evidencia ${idx + 1}`;
        let nombreLegible = nombreArchivo;
        if (nombreArchivo.includes('_')) {
            const parts = nombreArchivo.split('_');
            nombreLegible = parts.slice(4).join('_') || parts.slice(3).join('_') || parts.slice(2).join('_') || nombreArchivo;
        }

        const esVideo = urlLimpia.toLowerCase().endsWith('.mp4');

        if (esVideo) {
            return `
                <div class="foto-evidencia-card" style="position: relative; border-radius: 8px; overflow: hidden; background: #020617; box-shadow: 0 3px 8px rgba(0,0,0,0.18); aspect-ratio: 4/3; cursor: pointer; border: 1.5px solid #0284c7;" onclick="abrirVisorEvidencia('${urlLimpia}', '${nombreLegible}', 'video')">
                    <video src="${urlLimpia}#t=0.5" preload="metadata" muted style="width: 100%; height: 100%; object-fit: cover; display: block; pointer-events: none;"></video>
                    <!-- Overlay de Reproducción -->
                    <div style="position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; background: rgba(0, 0, 0, 0.35); transition: background 0.2s;" onmouseover="this.style.background='rgba(0,0,0,0.15)'" onmouseout="this.style.background='rgba(0,0,0,0.35)'">
                        <i class="ph-fill ph-play-circle" style="font-size: 38px; color: #38bdf8; filter: drop-shadow(0 2px 5px rgba(0,0,0,0.8));"></i>
                    </div>
                    <!-- Badge MP4 -->
                    <span style="position: absolute; top: 5px; left: 5px; background: rgba(2, 132, 199, 0.92); color: white; font-size: 9.5px; font-weight: 800; padding: 2px 6px; border-radius: 4px; display: inline-flex; align-items: center; gap: 3px; backdrop-filter: blur(2px);">
                        <i class="ph ph-video-camera"></i> MP4
                    </span>
                    <div style="position: absolute; bottom: 0; left: 0; right: 0; background: linear-gradient(transparent, rgba(15, 23, 42, 0.9)); padding: 4px 6px; color: white; font-size: 10px; font-weight: 600; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;">
                        ${nombreLegible}
                    </div>
                    ${!isReadOnly ? `
                        <button type="button" onclick="event.stopPropagation(); confirmarEliminarFotoEvidencia(${idEvento}, '${urlLimpia}')" style="position: absolute; top: 4px; right: 4px; background: rgba(239, 68, 68, 0.92); color: white; border: none; border-radius: 4px; width: 24px; height: 24px; display: flex; align-items: center; justify-content: center; font-size: 12px; cursor: pointer; box-shadow: 0 2px 4px rgba(0,0,0,0.25);" title="Eliminar video">
                            <i class="ph ph-trash"></i>
                        </button>
                    ` : ''}
                </div>
            `;
        }

        return `
            <div class="foto-evidencia-card" style="position: relative; border-radius: 8px; overflow: hidden; background: #0f172a; box-shadow: 0 3px 8px rgba(0,0,0,0.12); aspect-ratio: 4/3; cursor: pointer; border: 1px solid #cbd5e1;" onclick="abrirVisorEvidencia('${urlLimpia}', '${nombreLegible}', 'foto')">
                <img src="${urlLimpia}" alt="Evidencia" style="width: 100%; height: 100%; object-fit: cover; display: block; transition: transform 0.25s;" onmouseover="this.style.transform='scale(1.06)'" onmouseout="this.style.transform='scale(1)'">
                <div style="position: absolute; bottom: 0; left: 0; right: 0; background: linear-gradient(transparent, rgba(15, 23, 42, 0.85)); padding: 4px 6px; color: white; font-size: 10px; font-weight: 600; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;">
                    ${nombreLegible}
                </div>
                ${!isReadOnly ? `
                    <button type="button" onclick="event.stopPropagation(); confirmarEliminarFotoEvidencia(${idEvento}, '${urlLimpia}')" style="position: absolute; top: 4px; right: 4px; background: rgba(239, 68, 68, 0.92); color: white; border: none; border-radius: 4px; width: 24px; height: 24px; display: flex; align-items: center; justify-content: center; font-size: 12px; cursor: pointer; box-shadow: 0 2px 4px rgba(0,0,0,0.25);" title="Eliminar fotografía">
                        <i class="ph ph-trash"></i>
                    </button>
                ` : ''}
            </div>
        `;
    }).join('');
}

async function alSubirFotosEvidenciaOP(input, idEvento) {
    if (!input || !input.files || input.files.length === 0) return;
    if (!idEvento) {
        alert("⚠️ Guarda primero la Orden de Producción antes de adjuntar fotografías o videos de evidencia.");
        input.value = '';
        return;
    }

    const MAX_FOTO_BYTES = 1 * 1024 * 1024;    // 1 MB
    const MAX_VIDEO_BYTES = 5 * 1024 * 1024;   // 5 MB

    const archivos = Array.from(input.files);
    let subidos = 0;
    let omitidos = [];

    for (const archivo of archivos) {
        const nombre = archivo.name || 'archivo';
        const ext = nombre.slice((nombre.lastIndexOf(".") - 1 >>> 0) + 2).toLowerCase();

        const esFoto = ['jpg', 'jpeg', 'png', 'webp'].includes(ext);
        const esVideo = ext === 'mp4';

        if (!esFoto && !esVideo) {
            omitidos.push(`❌ "${nombre}": Formato no permitido. Solo se aceptan fotos (.jpg, .png, .webp) y videos (.mp4).`);
            continue;
        }

        if (esFoto && archivo.size > MAX_FOTO_BYTES) {
            const tamanoMb = (archivo.size / (1024 * 1024)).toFixed(2);
            omitidos.push(`⚠️ "${nombre}": Pesa ${tamanoMb} MB. Excede el límite de 1.0 MB para fotos.`);
            continue;
        }

        if (esVideo && archivo.size > MAX_VIDEO_BYTES) {
            const tamanoMb = (archivo.size / (1024 * 1024)).toFixed(2);
            omitidos.push(`⚠️ "${nombre}": Pesa ${tamanoMb} MB. Excede el límite de 5.0 MB para videos MP4.`);
            continue;
        }

        const formData = new FormData();
        formData.append("file", archivo);

        try {
            const res = await fetch(`${API_URL}/api/eventos/subir_foto_evidencia/${idEvento}`, {
                method: "POST",
                body: formData
            });
            if (res.ok) {
                const data = await res.json();
                if (data.url) {
                    if (!window.opFotosEvidenciaActuales) window.opFotosEvidenciaActuales = [];
                    if (!window.opFotosEvidenciaActuales.includes(data.url)) {
                        window.opFotosEvidenciaActuales.push(data.url);
                    }
                    subidos++;
                }
            } else {
                const errData = await res.json().catch(() => ({ detail: res.statusText }));
                omitidos.push(`❌ "${nombre}": ${errData.detail || 'Error al procesar en servidor'}`);
            }
        } catch (e) {
            console.error("Error de conexión al subir evidencia:", e);
            omitidos.push(`❌ "${nombre}": Error de red o servidor.`);
        }
    }

    // Refrescar cuadrícula en tiempo real
    const galeria = document.getElementById('galeria-fotos-evidencia-act');
    if (galeria) {
        galeria.innerHTML = generarHtmlGaleriaFotosEvidencia(window.opFotosEvidenciaActuales, false, idEvento);
    }
    const badge = document.getElementById('op-fotos-badge-act');
    if (badge) {
        badge.innerText = formatearTextoBadgeEvidencias(window.opFotosEvidenciaActuales || []);
    }

    input.value = '';

    let mensaje = "";
    if (subidos > 0) {
        mensaje += `✅ ${subidos} archivo(s) de evidencia integrado(s) con éxito.\n`;
    }
    if (omitidos.length > 0) {
        mensaje += `\n⚠️ Observaciones al cargar archivos:\n` + omitidos.join('\n');
    }
    if (mensaje) {
        alert(mensaje);
    }
}

async function confirmarEliminarFotoEvidencia(idEvento, url) {
    const esVideo = String(url).toLowerCase().endsWith('.mp4');
    const tipoTxt = esVideo ? "video MP4" : "fotografía";
    if (!confirm(`¿Deseas eliminar este ${tipoTxt} de evidencia del evento?`)) return;

    try {
        const res = await fetch(`${API_URL}/api/eventos/eliminar_foto_evidencia/${idEvento}?url=${encodeURIComponent(url)}`, {
            method: "DELETE"
        });
        if (res.ok) {
            if (window.opFotosEvidenciaActuales) {
                window.opFotosEvidenciaActuales = window.opFotosEvidenciaActuales.filter(u => u !== url);
            }
            const galeria = document.getElementById('galeria-fotos-evidencia-act');
            if (galeria) {
                galeria.innerHTML = generarHtmlGaleriaFotosEvidencia(window.opFotosEvidenciaActuales, false, idEvento);
            }
            const badge = document.getElementById('op-fotos-badge-act');
            if (badge) {
                badge.innerText = formatearTextoBadgeEvidencias(window.opFotosEvidenciaActuales || []);
            }
        } else {
            alert("No se pudo eliminar el archivo del servidor.");
        }
    } catch (e) {
        alert("Error de conexión al eliminar archivo: " + e.message);
    }
}

function abrirVisorEvidencia(url, titulo, tipo) {
    const modal = document.getElementById('modal-visor-foto-evidencia');
    const img = document.getElementById('visor-foto-img');
    const video = document.getElementById('visor-video-player');
    const tit = document.getElementById('visor-foto-titulo');
    const btn = document.getElementById('visor-foto-btn-abrir');
    if (!modal) return;

    const esVideo = tipo === 'video' || String(url).toLowerCase().endsWith('.mp4');

    if (esVideo) {
        if (img) img.style.display = 'none';
        if (video) {
            video.src = url;
            video.style.display = 'block';
            video.currentTime = 0;
            video.play().catch(() => {});
        }
        if (tit) tit.innerHTML = `<i class="ph ph-video-camera" style="color: #38bdf8;"></i> Evidencia Video: ${titulo || 'Video MP4'}`;
    } else {
        if (video) {
            video.pause();
            video.src = '';
            video.style.display = 'none';
        }
        if (img) {
            img.src = url;
            img.style.display = 'block';
        }
        if (tit) tit.innerHTML = `<i class="ph ph-camera" style="color: #38bdf8;"></i> Evidencia Fotográfica: ${titulo || 'Fotografía'}`;
    }

    if (btn) btn.href = url;
    modal.style.display = 'flex';
}

function abrirVisorFotoEvidencia(url, titulo) {
    abrirVisorEvidencia(url, titulo, 'foto');
}

function cerrarVisorFotoEvidencia() {
    const modal = document.getElementById('modal-visor-foto-evidencia');
    const video = document.getElementById('visor-video-player');
    if (video) {
        video.pause();
        video.src = '';
    }
    if (modal) modal.style.display = 'none';
}

// ==========================================================================
// 📅 12.7 SUB-CATÁLOGO DE CRONOGRAMAS DE EVENTOS (7 COLUMNAS OFICIALES)
// ==========================================================================
let memoriaCronogramas = [];
let cronogramaEditandoId = null;

async function cargarCatalogoCronogramas() {
    const tbody = document.getElementById('tabla-cronogramas-body');
    const badge = document.getElementById('badge-count-cronogramas');
    const tabBadge = document.getElementById('tab-count-cron');
    const hubBadge = document.getElementById('hub-count-cron');

    try {
        const res = await fetch(`${API_URL}/api/cronogramas`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = await res.json();
        memoriaCronogramas = Array.isArray(data) ? data : [];

        const total = memoriaCronogramas.length;
        if (badge) badge.innerText = total;
        if (tabBadge) tabBadge.innerText = total;
        if (hubBadge) hubBadge.innerText = `${total} cronogramas`;

        poblarSelectorCronogramas();
        renderTablaCronogramas(memoriaCronogramas);

        const tbodyEditor = document.getElementById('tbody-actividades-cronograma');
        if (tbodyEditor && tbodyEditor.children.length === 0) {
            agregarFilaActividadCronograma();
        }
    } catch (e) {
        console.error("Error al cargar cronogramas:", e);
        if (tbody) {
            tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: #ef4444; padding: 20px;">
                <i class="ph ph-warning-circle"></i> Error al conectar con el servidor: ${e.message}
            </td></tr>`;
        }
    }
}

function renderTablaCronogramas(lista) {
    const tbody = document.getElementById('tabla-cronogramas-body');
    if (!tbody) return;

    if (!lista || lista.length === 0) {
        tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; padding: 24px; color: var(--text-muted);">
            No hay cronogramas registrados en el catálogo. Usa el formulario inferior para registrar uno nuevo.
        </td></tr>`;
        return;
    }

    tbody.innerHTML = lista.map(c => {
        const cantAct = Array.isArray(c.actividades) ? c.actividades.length : 0;
        const opStr = c.folio_op ? `<span style="background: #e0f2fe; color: #0369a1; padding: 2px 8px; border-radius: 4px; font-weight: 700; font-size: 11px;">OP: ${c.folio_op}</span>` : '<span style="color: #94a3b8; font-size: 11px;">Sin asignar</span>';
        
        return `
            <tr>
                <td style="font-weight: 800; color: #0284c7; white-space: nowrap;">FOLIO: ${c.folio || c.id_cronograma}</td>
                <td style="white-space: nowrap; font-weight: 600;">${c.fecha || '--'}</td>
                <td><strong>${c.nombre_evento || 'Sin título'}</strong></td>
                <td>${c.ubicacion_general || '--'}</td>
                <td style="text-align: center;"><span style="background: #f1f5f9; padding: 3px 10px; border-radius: 12px; font-weight: 600; font-size: 12px;">${cantAct} actividades</span></td>
                <td>${opStr}</td>
                <td style="white-space: nowrap;">
                    <div style="display: flex; gap: 6px;">
                        <button type="button" class="btn-cat-new" style="padding: 4px 10px; font-size: 11.5px;" onclick="seleccionarCronogramaParaEditar(${c.id_cronograma})" title="Cargar en el editor">
                            <i class="ph ph-pencil"></i> Editar
                        </button>
                        <button type="button" class="btn-cat-new" style="padding: 4px 10px; font-size: 11.5px; background: #0284c7; color: white; border-color: #0284c7;" onclick="imprimirCronogramaDirecto(${c.id_cronograma})" title="Imprimir Formato Oficial">
                            <i class="ph ph-printer"></i> Imprimir
                        </button>
                    </div>
                </td>
            </tr>
        `;
    }).join('');
}

function filtrarTablaCronogramas() {
    const q = (document.getElementById('filtro-cronogramas')?.value || '').toLowerCase().trim();
    if (!q) {
        renderTablaCronogramas(memoriaCronogramas);
        return;
    }

    const filtrados = memoriaCronogramas.filter(c => {
        const fol = String(c.folio || '').toLowerCase();
        const ev = String(c.nombre_evento || '').toLowerCase();
        const ub = String(c.ubicacion_general || '').toLowerCase();
        const f = String(c.fecha || '').toLowerCase();
        const op = String(c.folio_op || '').toLowerCase();
        return fol.includes(q) || ev.includes(q) || ub.includes(q) || f.includes(q) || op.includes(q);
    });

    renderTablaCronogramas(filtrados);
}

function poblarSelectorCronogramas() {
    const sel = document.getElementById('selector-cron-editor');
    if (!sel) return;
    const valActual = sel.value;

    sel.innerHTML = '<option value="nuevo">✨ --- REGISTRAR NUEVO CRONOGRAMA ---</option>';
    memoriaCronogramas.forEach(c => {
        const opt = document.createElement('option');
        opt.value = c.id_cronograma;
        opt.textContent = `FOLIO: ${c.folio || c.id_cronograma} | ${c.fecha || ''} - ${c.nombre_evento || 'Sin título'} (${(c.actividades || []).length} acts)`;
        sel.appendChild(opt);
    });

    if (valActual && Array.from(sel.options).some(o => o.value === valActual)) {
        sel.value = valActual;
    }
}

function alCambiarSelectorCronograma() {
    const sel = document.getElementById('selector-cron-editor');
    if (!sel) return;

    if (sel.value === 'nuevo') {
        limpiarFormCronograma();
    } else {
        seleccionarCronogramaParaEditar(parseInt(sel.value));
    }
}

async function seleccionarCronogramaParaEditar(id) {
    cronogramaEditandoId = id;

    let c = memoriaCronogramas.find(x => x.id_cronograma === id);
    if (!c) {
        try {
            const res = await fetch(`${API_URL}/api/cronogramas/${id}`);
            if (res.ok) c = await res.json();
        } catch (e) {
            console.error("Error al obtener detalle de cronograma:", e);
        }
    }
    if (!c) return;

    const inpId = document.getElementById('cron-id');
    if (inpId) inpId.value = c.id_cronograma || '';

    const inpFolio = document.getElementById('cron-folio');
    if (inpFolio) inpFolio.value = c.folio || '';

    const inpFecha = document.getElementById('cron-fecha');
    if (inpFecha) inpFecha.value = aFechaInput(c.fecha);

    const inpEvento = document.getElementById('cron-evento');
    if (inpEvento) inpEvento.value = c.nombre_evento || '';

    const inpUbicacion = document.getElementById('cron-ubicacion');
    if (inpUbicacion) inpUbicacion.value = c.ubicacion_general || '';

    const inpFolioOp = document.getElementById('cron-folio-op');
    if (inpFolioOp) inpFolioOp.value = c.folio_op || '';

    const inpObs = document.getElementById('cron-observaciones-gen');
    if (inpObs) inpObs.value = c.observaciones_generales || '';

    const sel = document.getElementById('selector-cron-editor');
    if (sel) sel.value = String(c.id_cronograma);

    const tbody = document.getElementById('tbody-actividades-cronograma');
    if (tbody) {
        tbody.innerHTML = '';
        const acts = Array.isArray(c.actividades) && c.actividades.length > 0 ? c.actividades : [{}];
        acts.forEach(act => agregarFilaActividadCronograma(act));
    }

    const lblBtn = document.getElementById('lbl-btn-guardar-cron');
    if (lblBtn) lblBtn.innerText = '💾 Actualizar Cronograma';

    const btnDel = document.getElementById('btn-eliminar-cron');
    if (btnDel) btnDel.style.display = 'inline-flex';

    const btnPrint = document.getElementById('btn-imprimir-cron');
    if (btnPrint) btnPrint.style.display = 'inline-flex';

    document.getElementById('selector-cron-editor')?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

function limpiarFormCronograma() {
    cronogramaEditandoId = null;

    const inpId = document.getElementById('cron-id');
    if (inpId) inpId.value = '';

    const inpFolio = document.getElementById('cron-folio');
    if (inpFolio) inpFolio.value = '';

    const inpFecha = document.getElementById('cron-fecha');
    if (inpFecha) inpFecha.value = new Date().toISOString().split('T')[0];

    const inpEvento = document.getElementById('cron-evento');
    if (inpEvento) inpEvento.value = '';

    const inpUbicacion = document.getElementById('cron-ubicacion');
    if (inpUbicacion) inpUbicacion.value = '';

    const inpFolioOp = document.getElementById('cron-folio-op');
    if (inpFolioOp) inpFolioOp.value = '';

    const inpObs = document.getElementById('cron-observaciones-gen');
    if (inpObs) inpObs.value = '';

    const sel = document.getElementById('selector-cron-editor');
    if (sel) sel.value = 'nuevo';

    const tbody = document.getElementById('tbody-actividades-cronograma');
    if (tbody) {
        tbody.innerHTML = '';
        agregarFilaActividadCronograma();
    }

    const lblBtn = document.getElementById('lbl-btn-guardar-cron');
    if (lblBtn) lblBtn.innerText = '💾 Guardar Nuevo Cronograma';

    const btnDel = document.getElementById('btn-eliminar-cron');
    if (btnDel) btnDel.style.display = 'none';

    const btnPrint = document.getElementById('btn-imprimir-cron');
    if (btnPrint) btnPrint.style.display = 'none';
}

function agregarFilaActividadCronograma(datos = {}) {
    const tbody = document.getElementById('tbody-actividades-cronograma');
    if (!tbody) return;

    const tr = document.createElement('tr');
    tr.innerHTML = `
        <td>
            <input type="text" class="form-input row-horario" value="${datos.horario || ''}" placeholder="Ej. 09:00 a. m. o De 9:00 a 11:00" style="padding: 6px 8px; font-size: 12px; font-weight: 600;">
        </td>
        <td>
            <input type="text" class="form-input row-actividad" value="${datos.actividad || ''}" placeholder="Ej. Entrada a oficina, Check out, Instalación..." style="padding: 6px 8px; font-size: 12px;">
        </td>
        <td>
            <input type="text" class="form-input row-ubicacion" value="${datos.ubicacion || ''}" placeholder="Ej. Oficina Vpro, Palacio..." style="padding: 6px 8px; font-size: 12px;">
        </td>
        <td>
            <input type="text" class="form-input row-evento" value="${datos.evento || ''}" placeholder="Ej. Llamado, Ensayos, Descanso..." style="padding: 6px 8px; font-size: 12px;">
        </td>
        <td>
            <input type="text" class="form-input row-personal" value="${datos.personal_convocado || ''}" placeholder="Personal convocado..." style="padding: 6px 8px; font-size: 12px;">
        </td>
        <td>
            <input type="text" class="form-input row-vehiculo" value="${datos.vehiculo || ''}" placeholder="Ej. TIIDA #2, HILUX, SPRINTER..." style="padding: 6px 8px; font-size: 12px;">
        </td>
        <td>
            <input type="text" class="form-input row-observaciones" value="${datos.observaciones || ''}" placeholder="Observaciones o notas..." style="padding: 6px 8px; font-size: 12px;">
        </td>
        <td style="text-align: center;">
            <button type="button" onclick="removerFilaActividadCronograma(this)" style="background: none; border: none; color: #ef4444; font-size: 16px; cursor: pointer; padding: 4px;" title="Eliminar renglón">
                <i class="ph ph-trash"></i>
            </button>
        </td>
    `;
    tbody.appendChild(tr);
}

function removerFilaActividadCronograma(btn) {
    const tr = btn.closest('tr');
    const tbody = document.getElementById('tbody-actividades-cronograma');
    if (tr) tr.remove();
    if (tbody && tbody.children.length === 0) {
        agregarFilaActividadCronograma();
    }
}

function obtenerActividadesDeTabla() {
    const tbody = document.getElementById('tbody-actividades-cronograma');
    if (!tbody) return [];

    const acts = [];
    Array.from(tbody.querySelectorAll('tr')).forEach(tr => {
        const horario = tr.querySelector('.row-horario')?.value?.trim() || '';
        const actividad = tr.querySelector('.row-actividad')?.value?.trim() || '';
        const ubicacion = tr.querySelector('.row-ubicacion')?.value?.trim() || '';
        const evento = tr.querySelector('.row-evento')?.value?.trim() || '';
        const personal = tr.querySelector('.row-personal')?.value?.trim() || '';
        const vehiculo = tr.querySelector('.row-vehiculo')?.value?.trim() || '';
        const observaciones = tr.querySelector('.row-observaciones')?.value?.trim() || '';

        if (horario || actividad || ubicacion || evento || personal || vehiculo || observaciones) {
            acts.push({
                horario,
                actividad,
                ubicacion,
                evento,
                personal_convocado: personal,
                vehiculo,
                observaciones
            });
        }
    });

    return acts;
}

function cargarPlantillaEjemploCronograma(num) {
    const tbody = document.getElementById('tbody-actividades-cronograma');
    if (!tbody) return;
    tbody.innerHTML = '';

    if (num === 1) {
        document.getElementById('cron-folio').value = '01';
        document.getElementById('cron-fecha').value = '2026-09-14';
        document.getElementById('cron-evento').value = 'Grito de Independencia 2026 - Montaje y Ensayos';
        document.getElementById('cron-ubicacion').value = 'Palacio de gobierno';
        document.getElementById('cron-observaciones-gen').value = 'Jornada previa: Carga de equipo, traslado, instalación y ensayos de protocolo.';

        const plantilla1 = [
            { horario: "09:00 a. m.", actividad: "Entrada a oficina", ubicacion: "Oficina Vpro", evento: "Llamado", personal_convocado: "Martin Estrada, Osiel Hernandez, Edgar Amarillas, Cuauhtémoc Rivera, Manuel Madrid, Carlos Quezada, Francisco Torres y Daniel Torres", vehiculo: "TIIDA #2, HILUX, SPRINTER Y FORD", observaciones: "SPRINTER y FORD se quedaran en locación para almacenar y proteger equipos." },
            { horario: "De 9:00 a 11:00", actividad: "Check out", ubicacion: "Oficina Vpro", evento: "Registrar equipo y cargar", personal_convocado: "", vehiculo: "", observaciones: "" },
            { horario: "De 11:30 a 12:00", actividad: "Traslado a evento", ubicacion: "Palacio de gobierno", evento: "Traslado", personal_convocado: "", vehiculo: "", observaciones: "" },
            { horario: "De 12:00 a 14:00", actividad: "Instalación", ubicacion: "Palacio de gobierno", evento: "Instalación ensayo Protocolo", personal_convocado: "", vehiculo: "", observaciones: "" },
            { horario: "De 14:00 a 16:00", actividad: "Descanso", ubicacion: "Descanso", evento: "Corte a comer", personal_convocado: "Descanso", vehiculo: "Descanso", observaciones: "" },
            { horario: "De 16:00 a 18:30", actividad: "Reanudación de instalación", ubicacion: "Palacio de gobierno", evento: "Seguimiento de actividades", personal_convocado: "Martin Estrada, Osiel Hernandez, Edgar Amarillas, Cuauhtémoc Rivera, Manuel Madrid, Carlos Quezada, Francisco Torres y Daniel Torres", vehiculo: "TIIDA #2 Y HILUX", observaciones: "" },
            { horario: "De 18:30 a 19:00", actividad: "Retorno a oficina", ubicacion: "Oficina Vpro", evento: "Retorno", personal_convocado: "", vehiculo: "", observaciones: "" },
            { horario: "07:00 p. m.", actividad: "Salida de oficina", ubicacion: "Oficina Vpro", evento: "Termino de actividades", personal_convocado: "", vehiculo: "", observaciones: "" }
        ];

        plantilla1.forEach(act => agregarFilaActividadCronograma(act));
        alert("✅ Plantilla Folio 01 (14/Sep) cargada correctamente en el editor.");
    } else if (num === 2) {
        document.getElementById('cron-folio').value = '02';
        document.getElementById('cron-fecha').value = '2026-09-15';
        document.getElementById('cron-evento').value = 'Grito de Independencia 2026 - Transmisión en Vivo';
        document.getElementById('cron-ubicacion').value = 'Palacio de gobierno';
        document.getElementById('cron-observaciones-gen').value = 'Jornada estelar: Pruebas de velocidad, streaming live transmisión del Grito y desmonte nocturno.';

        const plantilla2 = [
            { horario: "09:00 a. m.", actividad: "Entrada a oficina", ubicacion: "Oficina Vpro", evento: "Llamado", personal_convocado: "Martin Estrada, Gerardo Viillarreal Osiel Hernandez, Edgar Amarillas, Cuauhtémoc Rivera, Manuel Madrid, Carlos Quezada, Francisco Torres y Daniel Torres", vehiculo: "TIIDA #2 Y HILUX", observaciones: "Se trasladaron en los 2 vehiculos disponibles" },
            { horario: "De 9:40 a 10:00", actividad: "Traslado a evento", ubicacion: "Palacio de gobierno", evento: "Traslado", personal_convocado: "", vehiculo: "", observaciones: "" },
            { horario: "De 10:00 a 14:30", actividad: "Pruebas", ubicacion: "Palacio de gobierno", evento: "Pruebas de velocidad", personal_convocado: "", vehiculo: "", observaciones: "" },
            { horario: "De 14:30 a 15:00", actividad: "Descanso", ubicacion: "Descanso", evento: "Corte a comer", personal_convocado: "Descanso", vehiculo: "Descanso", observaciones: "Descanso" },
            { horario: "De 15:00 a 22:00", actividad: "Reanudación de pruebas", ubicacion: "Palacio de gobierno", evento: "Seguimiento de actividades", personal_convocado: "Martin Estrada, Osiel Hernandez, Edgar Amarillas, Cuauhtémoc Rivera, Manuel Madrid, Carlos Quezada, Francisco Torres y Daniel Torres", vehiculo: "TIIDA #2, HILUX, SPRINTER Y FORD", observaciones: "Se retornaran con todos los vehiculos a oficina." },
            { horario: "De 22:45 a 24:00", actividad: "Transmisión grito de independencia", ubicacion: "Palacio de gobierno", evento: "Transmisión Live streaming", personal_convocado: "", vehiculo: "", observaciones: "" },
            { horario: "De 24:00 a 01:30", actividad: "Levantamiento de equipo", ubicacion: "Palacio de gobierno", evento: "Guardar equipo", personal_convocado: "", vehiculo: "", observaciones: "" },
            { horario: "De 01:30 a 02:00", actividad: "Retorno oficina", ubicacion: "Oficina Vpro", evento: "Retorno", personal_convocado: "", vehiculo: "", observaciones: "" },
            { horario: "02:15 a. m.", actividad: "Salida de oficina", ubicacion: "Oficina Vpro", evento: "Termino de actividades", personal_convocado: "", vehiculo: "", observaciones: "" }
        ];

        plantilla2.forEach(act => agregarFilaActividadCronograma(act));
        alert("✅ Plantilla Folio 02 (15/Sep) cargada correctamente en el editor.");
    }
}

async function guardarCronogramaForm() {
    const id = document.getElementById('cron-id')?.value;
    const folio = document.getElementById('cron-folio')?.value?.trim();
    const fecha = document.getElementById('cron-fecha')?.value;
    const evento = document.getElementById('cron-evento')?.value?.trim();
    const ubicacion = document.getElementById('cron-ubicacion')?.value?.trim();
    const folio_op = document.getElementById('cron-folio-op')?.value?.trim() || null;
    const observaciones_generales = document.getElementById('cron-observaciones-gen')?.value?.trim() || "";

    const actividades = obtenerActividadesDeTabla();

    if (!folio || !fecha || !evento || !ubicacion) {
        alert("⚠️ Por favor completa los campos obligatorios (*):\n- Folio del Cronograma\n- Fecha de Ejecución\n- Nombre del Evento / Proyecto\n- Ubicación General");
        return;
    }

    if (actividades.length === 0) {
        alert("⚠️ Agrega al menos un renglón de actividad con horario o descripción en la tabla de cronograma.");
        return;
    }

    const payload = {
        id_cronograma: id ? parseInt(id) : null,
        folio: folio,
        fecha: fecha,
        nombre_evento: evento,
        ubicacion_general: ubicacion,
        folio_op: folio_op,
        observaciones_generales: observaciones_generales,
        actividades: actividades
    };

    const btn = document.getElementById('btn-guardar-cron');
    if (btn) btn.disabled = true;

    try {
        const res = await fetch(`${API_URL}/api/cronogramas`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        if (!res.ok) {
            const err = await res.json().catch(() => ({ detail: res.statusText }));
            throw new Error(err.detail || "Error al guardar");
        }
        const dataRes = await res.json();
        alert(id ? `✅ Cronograma "${folio}" actualizado con éxito.` : `✅ Cronograma "${folio}" registrado exitosamente.`);
        
        await cargarCatalogoCronogramas();
        if (dataRes && dataRes.id_cronograma) {
            seleccionarCronogramaParaEditar(dataRes.id_cronograma);
        } else {
            limpiarFormCronograma();
        }
    } catch (e) {
        alert(`❌ Error al guardar cronograma: ${e.message}`);
    } finally {
        if (btn) btn.disabled = false;
    }
}

function confirmarEliminarCronograma() {
    const id = document.getElementById('cron-id')?.value;
    if (!id) return;

    const c = memoriaCronogramas.find(item => String(item.id_cronograma) === String(id));
    const titulo = c ? `Folio: ${c.folio} - ${c.nombre_evento}` : `Cronograma #${id}`;

    abrirModalBaja(
        "🚨 Confirmación de Eliminación de Cronograma",
        `¿Está seguro de que desea eliminar el cronograma de <strong>${titulo}</strong>?<br><br><span style="color: #991b1b; font-size: 12px;">⚠️ Esta acción eliminará permanentemente las actividades registradas.</span>`,
        async () => {
            try {
                const res = await fetch(`${API_URL}/api/cronogramas/${id}`, { method: 'DELETE' });
                if (!res.ok) {
                    const err = await res.json().catch(() => ({ detail: res.statusText }));
                    throw new Error(err.detail || "Error al eliminar");
                }
                alert(`💥 Cronograma eliminado correctamente.`);
                limpiarFormCronograma();
                await cargarCatalogoCronogramas();
            } catch (e) {
                alert(`❌ No se pudo eliminar el cronograma: ${e.message}`);
            }
        }
    );
}

function imprimirCronogramaDirecto(id) {
    imprimirCronogramaOficial(id);
}

async function imprimirCronogramaOficial(id) {
    let cron = null;
    if (id) {
        cron = memoriaCronogramas.find(c => c.id_cronograma === id);
        if (!cron) {
            try {
                const res = await fetch(`${API_URL}/api/cronogramas/${id}`);
                if (res.ok) cron = await res.json();
            } catch (e) {
                console.error("Error al obtener cronograma para imprimir:", e);
            }
        }
    } else {
        cron = {
            id_cronograma: document.getElementById('cron-id')?.value || '',
            folio: document.getElementById('cron-folio')?.value || 'S/F',
            fecha: document.getElementById('cron-fecha')?.value || '',
            nombre_evento: document.getElementById('cron-evento')?.value || 'Sin título',
            ubicacion_general: document.getElementById('cron-ubicacion')?.value || 'No especificada',
            observaciones_generales: document.getElementById('cron-observaciones-gen')?.value || '',
            actividades: obtenerActividadesDeTabla()
        };
    }

    if (!cron) {
        alert("No se pudo cargar la información del cronograma para impresión.");
        return;
    }

    let fechaFmt = cron.fecha || '';
    if (fechaFmt && fechaFmt.includes('-')) {
        const parts = fechaFmt.split('-');
        if (parts.length === 3) fechaFmt = `${parts[2]}/${parts[1]}/${parts[0]}`;
    }

    const modal = document.getElementById('modal-cronograma-impresion');
    const hoja = document.getElementById('cronograma-hoja-oficial');
    if (!modal || !hoja) return;

    const acts = Array.isArray(cron.actividades) ? cron.actividades : [];

    const rowsHtml = acts.map(a => `
        <tr style="border-bottom: 1px solid #cbd5e1;">
            <td style="border: 1px solid #94a3b8; padding: 7px 9px; font-weight: 700; white-space: nowrap;">${a.horario || ''}</td>
            <td style="border: 1px solid #94a3b8; padding: 7px 9px; font-weight: 600;">${a.actividad || ''}</td>
            <td style="border: 1px solid #94a3b8; padding: 7px 9px;">${a.ubicacion || ''}</td>
            <td style="border: 1px solid #94a3b8; padding: 7px 9px;">${a.evento || ''}</td>
            <td style="border: 1px solid #94a3b8; padding: 7px 9px; font-size: 11px; line-height: 1.35;">${a.personal_convocado || ''}</td>
            <td style="border: 1px solid #94a3b8; padding: 7px 9px; font-size: 11px;">${a.vehiculo || ''}</td>
            <td style="border: 1px solid #94a3b8; padding: 7px 9px; font-size: 11px; font-style: italic;">${a.observaciones || ''}</td>
        </tr>
    `).join('');

    hoja.innerHTML = `
        <div style="max-width: 1000px; margin: 0 auto; color: #0f172a; font-family: Arial, Helvetica, sans-serif;">
            <div style="border: 2px solid #0f172a; padding: 14px 18px; margin-bottom: 14px; background: #f8fafc;">
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #0f172a; padding-bottom: 8px; margin-bottom: 10px;">
                    <div style="font-size: 14px; font-weight: 800; letter-spacing: 0.5px;">FECHA: ${fechaFmt}</div>
                    <div style="font-size: 18px; font-weight: 900; letter-spacing: 1px; text-transform: uppercase;">CRONOGRAMA DE EVENTO</div>
                    <div style="font-size: 14px; font-weight: 800; letter-spacing: 0.5px;">FOLIO: ${cron.folio || '01'}</div>
                </div>
                <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 8px; font-size: 12.5px;">
                    <div><strong>EVENTO:</strong> ${cron.nombre_evento || '---'}</div>
                    <div><strong>UBICACIÓN GENERAL:</strong> ${cron.ubicacion_general || '---'}</div>
                </div>
                ${cron.observaciones_generales ? `
                    <div style="margin-top: 6px; font-size: 11.5px; color: #475569; border-top: 1px dashed #cbd5e1; padding-top: 4px;">
                        <strong>Directrices / Observaciones Generales:</strong> ${cron.observaciones_generales}
                    </div>
                ` : ''}
            </div>

            <table style="width: 100%; border-collapse: collapse; font-size: 11.5px; border: 1.5px solid #0f172a;">
                <thead>
                    <tr style="background: #0f172a; color: white;">
                        <th style="border: 1px solid #475569; padding: 7px 8px; text-align: left; width: 120px;">Horario</th>
                        <th style="border: 1px solid #475569; padding: 7px 8px; text-align: left; width: 140px;">Actividad</th>
                        <th style="border: 1px solid #475569; padding: 7px 8px; text-align: left; width: 130px;">Ubicación</th>
                        <th style="border: 1px solid #475569; padding: 7px 8px; text-align: left; width: 140px;">Evento</th>
                        <th style="border: 1px solid #475569; padding: 7px 8px; text-align: left;">Personal convocado</th>
                        <th style="border: 1px solid #475569; padding: 7px 8px; text-align: left; width: 140px;">Vehículo</th>
                        <th style="border: 1px solid #475569; padding: 7px 8px; text-align: left; width: 180px;">Observaciones</th>
                    </tr>
                </thead>
                <tbody>
                    ${rowsHtml}
                </tbody>
            </table>

            <div style="margin-top: 14px; display: flex; justify-content: space-between; font-size: 10.5px; color: #64748b; border-top: 1px solid #e2e8f0; padding-top: 8px;">
                <span>VPRO Producciones · Logística y Operación Técnica</span>
                <span>Generado desde VPRO Dashboard V2</span>
            </div>
        </div>
    `;

    modal.style.display = 'flex';
}

function cerrarModalCronogramaImpresion() {
    const modal = document.getElementById('modal-cronograma-impresion');
    if (modal) modal.style.display = 'none';
}

function ejecutarImpresionCronograma() {
    window.print();
}

// --------------------------------------------------------------------------
// 🌐 CARGA INTEGRAL DE CATÁLOGOS (PARA CONTADORES DEL HUB Y TABS)
// --------------------------------------------------------------------------
async function cargarTodosLosCatalogos() {
    try {
        const [resCli, resAutos, resProv, resInv, resEmp, resReu, resCron, resCotiz] = await Promise.allSettled([
            fetch(`${API_URL}/api/clientes`).then(r => r.json()),
            fetch(`${API_URL}/api/autos`).then(r => r.json()),
            fetch(`${API_URL}/api/proveedores`).then(r => r.json()),
            fetch(`${API_URL}/api/inventario`).then(r => r.json()),
            fetch(`${API_URL}/api/empleados`).then(r => r.json()),
            fetch(`${API_URL}/api/reuniones/historial`).then(r => r.json()),
            fetch(`${API_URL}/api/cronogramas`).then(r => r.json()),
            fetch(`${API_URL}/api/cotizaciones/lista`).then(r => r.json())
        ]);

        if (resCli.status === 'fulfilled' && Array.isArray(resCli.value)) {
            memoriaClientes = resCli.value;
            const b = document.getElementById('badge-count-clientes');
            if (b) b.innerText = memoriaClientes.length;
            const tb = document.getElementById('tab-count-clientes');
            if (tb) tb.innerText = memoriaClientes.length;
            const hb = document.getElementById('hub-count-clientes');
            if (hb) hb.innerText = `${memoriaClientes.length} registros`;
        }
        if (resAutos.status === 'fulfilled' && Array.isArray(resAutos.value)) {
            memoriaAutos = resAutos.value;
            const b = document.getElementById('badge-count-autos');
            if (b) b.innerText = memoriaAutos.length;
            const tb = document.getElementById('tab-count-autos');
            if (tb) tb.innerText = memoriaAutos.length;
            const hb = document.getElementById('hub-count-autos');
            if (hb) hb.innerText = `${memoriaAutos.length} unidades`;
        }
        if (resProv.status === 'fulfilled' && Array.isArray(resProv.value)) {
            memoriaProveedores = resProv.value;
            const b = document.getElementById('badge-count-prov');
            if (b) b.innerText = memoriaProveedores.length;
            const tb = document.getElementById('tab-count-prov');
            if (tb) tb.innerText = memoriaProveedores.length;
            const hb = document.getElementById('hub-count-prov');
            if (hb) hb.innerText = `${memoriaProveedores.length} proveedores`;
        }
        if (resInv.status === 'fulfilled' && Array.isArray(resInv.value)) {
            memoriaInventario = resInv.value;
            const b = document.getElementById('badge-count-inv');
            if (b) b.innerText = memoriaInventario.length;
            const tb = document.getElementById('tab-count-inv');
            if (tb) tb.innerText = memoriaInventario.length;
            const hb = document.getElementById('hub-count-inv');
            if (hb) hb.innerText = `${memoriaInventario.length} piezas`;
        }
        if (resEmp.status === 'fulfilled' && Array.isArray(resEmp.value)) {
            memoriaEmpleados = resEmp.value;
            const b = document.getElementById('badge-count-empleados');
            if (b) b.innerText = memoriaEmpleados.length;
            const tb = document.getElementById('tab-count-emp');
            if (tb) tb.innerText = memoriaEmpleados.length;
            const hb = document.getElementById('hub-count-emp');
            if (hb) hb.innerText = `${memoriaEmpleados.length} colaboradores`;
        }
        if (resReu.status === 'fulfilled' && Array.isArray(resReu.value)) {
            memoriaReuniones = resReu.value;
            const b = document.getElementById('badge-count-reuniones');
            if (b) b.innerText = memoriaReuniones.length;
            const tb = document.getElementById('tab-count-reu');
            if (tb) tb.innerText = memoriaReuniones.length;
            const hb = document.getElementById('hub-count-reu');
            if (hb) hb.innerText = `${memoriaReuniones.length} minutas`;
        }
        if (resCron.status === 'fulfilled' && Array.isArray(resCron.value)) {
            const hb = document.getElementById('hub-count-cron');
            if (hb) hb.innerText = `${resCron.value.length} cronogramas`;
        }
        if (resCotiz.status === 'fulfilled' && Array.isArray(resCotiz.value)) {
            const hb = document.getElementById('hub-count-cotiz');
            if (hb) hb.innerText = `${resCotiz.value.length} cotizaciones`;
        }
    } catch (e) {
        console.warn("Error cargando contadores de catálogos:", e);
    }
}

