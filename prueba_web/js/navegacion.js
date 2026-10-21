// ==============================================================================
// MÓDULO: navegacion.js
// 3. Menú lateral, tabs, modals de navegación
// Líneas originales: 464–571 de script.js
// ==============================================================================

// ==========================================
// 3. NAVEGACIÓN Y MENÚ LATERAL
// ==========================================
function cambiarVista(idVista) {
    if (!idVista) return;

    // Actualizar item activo en el menú lateral
    document.querySelectorAll('.sidebar-menu .nav-item').forEach(item => {
        const onclickAttr = item.getAttribute('onclick') || '';
        if (onclickAttr.includes(idVista)) {
            item.classList.add('active');
        } else {
            item.classList.remove('active');
        }
    });

    if (idVista !== 'vista-catalogos') {
        document.querySelectorAll('#sidebar-sub-catalogos .nav-subitem').forEach(el => el.classList.remove('active'));
    }

    // Ocultar todas las vistas
    const vistas = document.querySelectorAll('.vista-modulo');
    vistas.forEach(vista => {
        vista.classList.remove('activa');
        vista.style.display = 'none';
    });

    // Activar vista seleccionada
    const vistaDestino = document.getElementById(idVista);
    if (vistaDestino) {
        vistaDestino.classList.add('activa');
        vistaDestino.style.display = 'block';

        // Disparar carga de datos específica
        if (idVista === 'vista-inicio') {
            cargarDatosInicio();
        } else if (idVista === 'vista-checador') {
            iniciarRelojKiosco();
            cargarMatrizKiosco();
            cargarCredencialPersonal();
        } else if (idVista === 'vista-ops') {
            inicializarModuloOP();
        } else if (idVista === 'vista-danados') {
            cargarModuloDanados();
        } else if (idVista === 'vista-gastos') {
            cargarModuloGastos();
        } else if (idVista === 'vista-auditoria') {
            cambiarVista('vista-checador');
            cambiarPestanaChecador('auditoria');
            return;
        } else if (idVista === 'vista-catalogos') {
            abrirSubcatalogo((typeof subcatalogoActivoActual !== 'undefined' && subcatalogoActivoActual) ? subcatalogoActivoActual : 'hub');
        } else if (idVista === 'vista-checkout') {
            inicializarModuloCheckout();
        } else if (idVista === 'vista-incidencias') {
            cargarModuloIncidencias();
        } else if (idVista === 'vista-analitica') {
            cargarModuloAnalitica();
        } else if (idVista === 'vista-rh') {
            cargarModuloRH();
        } else if (idVista === 'vista-transferencias') {
            cargarTransferenciasModulo();
        } else if (idVista === 'vista-cotizaciones') {
            if (!window._preventCotizacionesInit) {
                inicializarModuloCotizaciones();
            }
            window._preventCotizacionesInit = false;
        }
    } else {
        console.warn(`Vista no encontrada: ${idVista}`);
    }
}

async function cargarBadges() {
    try {
        const resDanados = await fetch(`${API_URL}/api/inventario/radar-danos`);
        if (resDanados.ok) {
            const dataDanados = await resDanados.json();
            const badgeDanados = document.getElementById("badge-danados");
            if (badgeDanados) badgeDanados.innerText = dataDanados.length || 0;
        }
    } catch (e) { console.error("Error al cargar badge dañados:", e); }

    try {
        const resGastos = await fetch(`${API_URL}/api/gastos/pendientes/conteo`);
        if (resGastos.ok) {
            const conteo = await resGastos.json();
            const badgeGastos = document.getElementById("badge-gastos");
            if (badgeGastos) badgeGastos.innerText = (typeof conteo === 'number') ? conteo : (conteo?.conteo || 0);
        }
    } catch (e) { console.error("Error al cargar badge gastos:", e); }

    try {
        if (usuarioLogueado && usuarioLogueado.id_empleado) {
            const resTrans = await fetch(`${API_URL}/api/transferencias/pendientes_notificacion/${usuarioLogueado.id_empleado}`);
            if (resTrans.ok) {
                const dataTrans = await resTrans.json();
                const badgeTrans = document.getElementById("badge-transferencias");
                if (badgeTrans) {
                    const cant = dataTrans.total_pendientes || 0;
                    badgeTrans.innerText = cant;
                    badgeTrans.style.display = cant > 0 ? "inline-block" : "none";
                }
            }
        }
    } catch (e) { console.error("Error al cargar badge transferencias:", e); }
}

