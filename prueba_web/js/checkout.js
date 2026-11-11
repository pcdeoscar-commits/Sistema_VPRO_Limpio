
// -------------------------------------------------------------
// Gestión de Incidencias Multidía en Check-in
// -------------------------------------------------------------
function obtenerDiasDelProyecto(statusPack) {
    if (!statusPack) return [];
    const fInst = (statusPack.fec_de_instalacion || "").substring(0, 10);
    const fIni = (statusPack.fec_del_evento || "").substring(0, 10);
    const fFin = (statusPack.fec_fin_evento || fIni || "").substring(0, 10);
    const jornadas = Array.isArray(statusPack.fechas_jornadas) ? statusPack.fechas_jornadas : [];

    const setFechas = new Set();
    if (fInst) setFechas.add(fInst);
    if (fIni) setFechas.add(fIni);
    if (fFin) setFechas.add(fFin);
    jornadas.forEach(j => {
        if (j) setFechas.add(String(j).substring(0, 10));
    });

    const lista = Array.from(setFechas).filter(Boolean).sort();
    if (lista.length === 0) return [];

    return lista.map((f, idx) => {
        const parts = f.split('-');
        const fmt = parts.length === 3 ? `${parts[2]}/${parts[1]}/${parts[0]}` : f;
        let etiqueta = "Evento";
        if (fInst && f === fInst && (!fIni || f < fIni)) {
            etiqueta = "Instalación";
        } else if (fFin && f === fFin && f !== fIni) {
            etiqueta = "Cierre / Retorno";
        } else if (fIni && f === fIni && lista.length > 1) {
            etiqueta = (fInst && fInst === fIni) ? "Instalación / Evento" : "Día de Evento";
        }
        return {
            idx: idx + 1,
            fecha_iso: f,
            fecha_fmt: fmt,
            etiqueta: etiqueta
        };
    });
}

function parsearIncidenciasGuardadasPorDia(incTexto, dias) {
    const map = {};
    if (!incTexto || !incTexto.trim() || !dias || dias.length === 0) return map;

    // Regex para buscar bloques como "📅 [DD/MM/AAAA - ...]: texto" o "📅 [AAAA-MM-DD - ...]: texto"
    const regex = /📅\s*\[([^\]]+)\]:\s*([\s\S]*?)(?=(?:📅\s*\[|$))/g;
    let match;
    let huboBloques = false;
    while ((match = regex.exec(incTexto)) !== null) {
        huboBloques = true;
        const tag = match[1];
        const contenido = (match[2] || "").trim();
        const diaEncontrado = dias.find(d => tag.includes(d.fecha_fmt) || tag.includes(d.fecha_iso) || tag.toLowerCase().includes(d.etiqueta.toLowerCase()));
        if (diaEncontrado) {
            map[diaEncontrado.fecha_iso] = contenido;
        } else {
            const primerSinAsignar = dias.find(d => !map[d.fecha_iso]);
            if (primerSinAsignar) map[primerSinAsignar.fecha_iso] = contenido;
        }
    }

    // Si no contenía bloques pero hay texto libre guardado (texto heredado)
    if (!huboBloques && incTexto.trim()) {
        const textoLimpio = incTexto.trim();
        const diaInstalacion = dias.find(d => d.etiqueta.toLowerCase().includes('instalaci'));
        if (diaInstalacion) {
            map[diaInstalacion.fecha_iso] = textoLimpio;
        } else if (dias.length > 0) {
            map[dias[0].fecha_iso] = textoLimpio;
        }
    }

    return map;
}

function sincronizarIncidenciasMultidiaCheckin() {
    const inputsDias = document.querySelectorAll('.checkin-dia-incidencia');
    const masterTextarea = document.getElementById('checkout-checkin-incidencias');
    if (!inputsDias || inputsDias.length === 0 || !masterTextarea) return;

    const bloques = [];
    inputsDias.forEach(inp => {
        const eti = inp.getAttribute('data-etiqueta') || inp.getAttribute('data-fecha');
        const txt = inp.value.trim();
        if (txt) {
            bloques.push(`📅 [${eti}]:\n${txt}`);
        }
    });

    masterTextarea.value = bloques.join('\n\n');
}

function renderTarjetasIncidenciasCheckin(statusPack, incLimpia, esVacia) {
    const contenedor = document.getElementById('checkout-checkin-incidencias-container');
    if (!contenedor) return;

    const dias = obtenerDiasDelProyecto(statusPack);

    // Si es un evento de 1 solo día o sin fechas específicas:
    if (dias.length <= 1) {
        contenedor.innerHTML = `
            <textarea id="checkout-checkin-incidencias" class="op-textarea" rows="4" placeholder="Reporte cualquier percance, detalle técnico o imprevisto ocurrido en el evento (ej. fallas de internet/red, cambios de set, retrasos de programa, etc.)...">${!esVacia ? incLimpia : ''}</textarea>
        `;
        return;
    }

    // Evento Multidía: construir bloques por fecha
    const mapaDias = parsearIncidenciasGuardadasPorDia(incLimpia, dias);

    let cardsHtml = `
        <textarea id="checkout-checkin-incidencias" style="display: none;">${!esVacia ? incLimpia : ''}</textarea>
        <div style="display: flex; flex-direction: column; gap: 10px; margin-top: 4px;">
    `;

    dias.forEach(d => {
        const valDia = mapaDias[d.fecha_iso] || "";
        cardsHtml += `
            <div style="background: white; border: 1px solid #bfdbfe; border-left: 4px solid #3b82f6; border-radius: 8px; padding: 11px 15px; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; flex-wrap: wrap; gap: 6px;">
                    <strong style="color: #1e40af; font-size: 13.5px; display: flex; align-items: center; gap: 6px;">
                        <i class="ph ph-calendar-check" style="font-size: 17px; color: #2563eb;"></i>
                        📅 Día ${d.idx} (${d.fecha_fmt} - ${d.etiqueta}):
                    </strong>
                    <button type="button" onclick="marcarDiaCheckinSinIncidencias('${d.fecha_iso}')" style="background: #f0fdf4; color: #15803d; border: 1px solid #bbf7d0; padding: 4px 10px; border-radius: 5px; font-size: 11.5px; font-weight: 700; cursor: pointer; display: flex; align-items: center; gap: 4px; transition: background .15s;" onmouseover="this.style.background='#dcfce7'" onmouseout="this.style.background='#f0fdf4'">
                        <i class="ph ph-check-circle"></i> Sin incidencias este día
                    </button>
                </div>
                <textarea class="op-textarea checkin-dia-incidencia" id="checkin-dia-${d.fecha_iso}" data-fecha="${d.fecha_iso}" data-etiqueta="${d.fecha_fmt} - ${d.etiqueta}" rows="2" placeholder="Área de texto para incidencias de ${d.etiqueta.toLowerCase()} (${d.fecha_fmt})..." style="width: 100%; font-size: 12.5px; border: 1px solid #cbd5e1; border-radius: 6px; padding: 8px 12px; background: #f8fafc;" onfocus="this.style.background='#ffffff'; this.style.borderColor='#3b82f6';" onblur="this.style.background='#f8fafc'; this.style.borderColor='#cbd5e1';" oninput="sincronizarIncidenciasMultidiaCheckin()">${valDia}</textarea>
            </div>
        `;
    });

    cardsHtml += `</div>`;
    contenedor.innerHTML = cardsHtml;

    sincronizarIncidenciasMultidiaCheckin();
}

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
let esConvocadoActual = true;
let mapaEmpleadosNombreAId = {};
let itemsCheckoutSalida = [];
let itemsCheckoutCheckin = [];
let idMaestroCheckoutActual = null;
let estadoBodegaCheckoutActual = "NUEVO";
let pestanaActivaCheckout = 'salida';
let catalogoGlobalCheckoutCargado = false;
let radarDanosCheckoutSet = new Set();
let radarDanosActivosList = [];
let proveedoresAsignadosOPCheckout = [];

function esCoordinadorActivo() {
    const rolUsuario = (usuarioLogueado?.rol || '').toUpperCase().trim();
    const puestoUsuario = (usuarioLogueado?.puesto || '').toUpperCase().trim();
    const nomUsuarioUpper = (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || '').toUpperCase().trim();
    const idUsuario = String(usuarioLogueado?.id_empleado || '').trim();
    return rolUsuario === 'COORDINADOR' || rolUsuario.includes('COORDINADOR') || rolUsuario.includes('COORDINACION') ||
           puestoUsuario.includes('COORDINADOR') || puestoUsuario.includes('COORDINACION') ||
           idUsuario === '124' || idUsuario === '000' ||
           nomUsuarioUpper === 'MANUEL EDUARDO MADRID';
}

function equipoTieneDanoEnRadar(cod, nombre) {
    if (!radarDanosActivosList || radarDanosActivosList.length === 0) return false;
    const cUp = (cod || '').toUpperCase().trim();
    const nUp = (nombre || '').toUpperCase().trim();

    return radarDanosActivosList.some(d => {
        // 1. Coincidencia EXACTA por código ID (previene que INV_VPRO_ALT_00 coincida con INV_VPRO_ALT_00237)
        if (cUp && d.id && cUp === d.id) return true;
        
        // 2. Coincidencia estricta por nombre de equipo
        if (nUp && d.equipo) {
            if (nUp === d.equipo) return true;
            // Solo si ambos nombres son largos y no son palabras genéricas
            if (nUp.length >= 10 && d.equipo.length >= 10) {
                const genericos = ['COMPUTADORA', 'MONITOR', 'MOUSE', 'TECLADO', 'CABLE', 'BATERIA', 'BATERIAS', 'TRIPOD', 'TRIPIE', 'MICROFONO', 'CAMARA'];
                const esGenerico = genericos.some(g => nUp === g || d.equipo === g);
                if (!esGenerico && (nUp === d.equipo || d.equipo.startsWith(nUp) || nUp.startsWith(d.equipo))) {
                    return true;
                }
            }
        }
        return false;
    });
}

function abrirCheckoutConOP(idEvento, opLabel) {
    opPreseleccionadaCheckout = { id: idEvento, label: opLabel };
    cambiarVista('vista-checkout');
}

function cambiarPestanaCheckout(pestana) {
    // Regla de Negocio: Solo el coordinador tiene acceso a la pestaña de Check-in (Retorno a Bodega)
    if (pestana === 'checkin' && !esCoordinadorActivo()) {
        if (typeof Swal !== 'undefined') {
            Swal.fire({
                icon: 'warning',
                title: '⛔ Retorno Restringido',
                text: 'Solo el Coordinador de Bodega tiene autorización para recibir equipos y realizar Check-in.',
                confirmButtonColor: '#3b82f6'
            });
        } else {
            alert('⛔ Solo el Coordinador de Bodega tiene autorización para recibir equipos y realizar Check-in.');
        }
        return;
    }

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
                radarDanosActivosList = [];
                resDanos.value.forEach(d => {
                    const eq = (d.EQUIPO || d.equipo || '').toUpperCase().trim();
                    const id = (d.ID || d.id || '').toUpperCase().trim();
                    if (eq && eq.length > 2) radarDanosCheckoutSet.add(eq);
                    if (id && id.length > 2) radarDanosCheckoutSet.add(id);
                    radarDanosActivosList.push({ id, equipo: eq });
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

    // Regla de Negocio: Pestaña Retorno a Bodega (Check-in) visible EXCLUSIVAMENTE para el Coordinador
    const tabCheckin = document.getElementById('tab-checkout-checkin');
    if (tabCheckin) {
        tabCheckin.style.display = esCoordinadorActivo() ? 'inline-flex' : 'none';
    }
    if (!esCoordinadorActivo()) {
        cambiarPestanaCheckout('salida');
    }

    // 2. Cargar lista de OPs disponibles para este empleado
    try {
        const idEmp = usuarioLogueado.id_empleado || "001";
        const nomEmp = usuarioLogueado.nombre_completo || usuarioLogueado.nombre || "";
        const rolEmp = usuarioLogueado.rol || "";
        const resInit = await fetch(`${API_URL}/api/checkout/init-data/${encodeURIComponent(idEmp)}?usuario_nombre=${encodeURIComponent(nomEmp)}&rol=${encodeURIComponent(rolEmp)}`);
        if (resInit.ok) {
            const pack = await resInit.json();
            ordenesCheckoutDisponibles = pack.ordenes || [];
            
            const selOP = document.getElementById('checkout-sel-op');
            if (selOP) {
                if (ordenesCheckoutDisponibles.length === 0) {
                    selOP.innerHTML = `<option value="">--- No tienes OPs activas donde estés convocado ---</option>`;
                    limpiarModuloCheckout();
                    return;
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

    const btnCoord = document.getElementById('btn-autorizar-salida-coordinador');
    if (btnCoord) btnCoord.style.display = 'none';

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
        const nomUser = usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "";
        const rolUsuario = (usuarioLogueado?.rol || '').toUpperCase().trim();
        const puestoUsuario = (usuarioLogueado?.puesto || '').toUpperCase().trim();
        const nomUsuarioUpper = nomUser.toUpperCase().trim();
        const idUsuario = String(usuarioLogueado?.id_empleado || '').trim();
        const esCoordinador = rolUsuario === 'COORDINADOR' || rolUsuario.includes('COORDINADOR') || rolUsuario.includes('COORDINACION') ||
                              puestoUsuario.includes('COORDINADOR') || puestoUsuario.includes('COORDINACION') ||
                              idUsuario === '124' || idUsuario === '000' ||
                              nomUsuarioUpper === 'MANUEL EDUARDO MADRID';

        const resStatus = await fetch(`${API_URL}/api/checkout/status/${idEvento}/${empId}?usuario_nombre=${encodeURIComponent(nomUser)}&rol=${encodeURIComponent(rolUsuario)}`);
        if (!resStatus.ok) throw new Error("Error consultando status de checkout");
        const statusPack = await resStatus.json();

        idMaestroCheckoutActual = statusPack.id_maestro;
        estadoBodegaCheckoutActual = statusPack.estado_bodega || "NUEVO";
        actualizarBadgeEstadoCheckout(estadoBodegaCheckoutActual);

        // Desglosar convocados y proveedores
        const convocados = desglosarArrayPostgres(statusPack.convocados);
        const proveedores = desglosarArrayPostgres(statusPack.proveedores_op);
        proveedoresAsignadosOPCheckout = proveedores;

        // Determinar si el usuario logueado está convocado en esta OP o si es Coordinador con acceso total
        let esConvocado = statusPack.hasOwnProperty('es_convocado') ? Boolean(statusPack.es_convocado) : true;
        if (esCoordinador || Boolean(statusPack.es_coordinador)) {
            esConvocado = true;
        }
        esConvocadoActual = esConvocado;

        // Actualizar resumen en pantalla
        const txtConv = document.getElementById('checkout-txt-convocados');
        if (txtConv) txtConv.innerText = convocados.length > 0 ? convocados.join(", ") : "Ninguno asignado";
        const txtProv = document.getElementById('checkout-txt-proveedores');
        if (txtProv) txtProv.innerText = proveedores.length > 0 ? proveedores.join(", ") : "Ninguno asignado";
        const txtPlan = document.getElementById('checkout-txt-plantilla');
        if (txtPlan) txtPlan.innerText = statusPack.nombre_kit || "--- Sin plantilla ---";

        // Mostrar / Ocultar banner de restricción si no está convocado
        const alertaNoConv = document.getElementById('checkout-alerta-no-convocado');
        if (alertaNoConv) {
            alertaNoConv.style.display = esConvocado ? 'none' : 'flex';
        }

        // Regla de Negocio: Pestaña Retorno a Bodega (Check-in) visible EXCLUSIVAMENTE para el Coordinador
        const tabCheckin = document.getElementById('tab-checkout-checkin');
        if (tabCheckin) {
            tabCheckin.style.display = esCoordinador ? 'inline-flex' : 'none';
        }
        if (!esCoordinador && pestanaActivaCheckout === 'checkin') {
            cambiarPestanaCheckout('salida');
        }

        // Poblar selector de personal convocado
        const selEmp = document.getElementById('checkout-sel-empleado');
        if (selEmp) {
            if (convocados.length === 0) {
                if (esCoordinador) {
                    selEmp.innerHTML = `<option value="" disabled selected>⚠️ OP sin personal convocado aún</option>`;
                } else if (esConvocado) {
                    selEmp.innerHTML = `<option value="${empId}">${usuarioLogueado?.nombre_completo || 'Operador Actual'}</option>`;
                } else {
                    selEmp.innerHTML = `<option value="" disabled selected>⚠️ No convocado en esta OP</option>`;
                }
            } else {
                let optionsHtml = '';
                convocados.forEach(nombreNom => {
                    const norm = nombreNom.toUpperCase().trim();
                    const idConvocado = mapaEmpleadosNombreAId[norm] || empId;
                    optionsHtml += `<option value="${idConvocado}">${nombreNom}</option>`;
                });

                if (!esConvocado) {
                    selEmp.innerHTML = `<option value="" disabled selected>⚠️ No estás convocado en esta OP</option>` + optionsHtml;
                    empleadoActivoCheckout = null;
                } else if (!esCoordinador) {
                    // Operador ordinario convocado: solo se selecciona y ve a sí mismo
                    const normUser = nomUser.toUpperCase().trim();
                    const miNombre = convocados.find(c => {
                        const cNorm = c.toUpperCase().trim();
                        return cNorm === normUser || cNorm.includes(normUser) || normUser.includes(cNorm);
                    }) || nomUser;
                    selEmp.innerHTML = `<option value="${empId}">${miNombre}</option>`;
                    selEmp.value = empId;
                    empleadoActivoCheckout = empId;
                } else {
                    // Coordinador: puede elegir a cualquiera de los convocados de la OP
                    selEmp.innerHTML = optionsHtml;
                    if (empIdOverride && [...selEmp.options].some(o => o.value === empIdOverride)) {
                        selEmp.value = empIdOverride;
                        empleadoActivoCheckout = empIdOverride;
                    } else if (selEmp.options.length > 0) {
                        const primerId = selEmp.options[0].value;
                        if (!empIdOverride || empIdOverride === empId) {
                            selEmp.value = primerId;
                            empleadoActivoCheckout = primerId;
                            if (primerId !== empId) {
                                await cargarStatusCheckout(idEvento, primerId);
                                return;
                            }
                        } else {
                            selEmp.value = empIdOverride;
                            empleadoActivoCheckout = empIdOverride;
                        }
                    }
                }
            }
        }

        // Habilitar o deshabilitar controles de checkout según autorización
        const btnFinalizarSalida = document.getElementById('btn-finalizar-salida');
        const btnAgregarHw = document.querySelector('button[onclick="inyectarHardwareCheckout()"]');
        const inputBuscarHw = document.getElementById('checkout-buscar-hw');
        const inputCantHw = document.getElementById('checkout-cant-hw');
        const btnFilaVacia = document.querySelector('button[onclick="agregarFilaVaciaCheckout()"]');
        const btnVaciarLista = document.querySelector('button[onclick="limpiarTablaSalidaCheckout()"]');
        const btnGrabarPlantilla = document.querySelector('button[onclick="guardarComoPlantillaKit()"]');
        const selKit = document.getElementById('checkout-sel-kit');

        if (!esConvocado) {
            // Usuario bloqueado: no convocado en la OP
            if (btnFinalizarSalida) {
                btnFinalizarSalida.disabled = true;
                btnFinalizarSalida.style.opacity = '0.5';
                btnFinalizarSalida.style.cursor = 'not-allowed';
                btnFinalizarSalida.innerHTML = '<i class="ph ph-prohibit"></i> <span>No Convocado</span>';
                btnFinalizarSalida.title = "No puedes realizar salida de hardware porque no estás convocado en esta OP.";
            }
            if (btnAgregarHw) btnAgregarHw.disabled = true;
            if (inputBuscarHw) inputBuscarHw.disabled = true;
            if (inputCantHw) inputCantHw.disabled = true;
            if (btnFilaVacia) btnFilaVacia.disabled = true;
            if (btnVaciarLista) btnVaciarLista.disabled = true;
            if (btnGrabarPlantilla) btnGrabarPlantilla.disabled = true;
            if (selKit) selKit.disabled = true;
        } else if (esCoordinador) {
            // Regla de Negocio: El coordinador no puede elaborar checkout desde cero, pero sí modificar/alterar/revisar los que el personal ha hecho
            const tieneCheckoutElaborado = Boolean(idMaestroCheckoutActual);

            if (!tieneCheckoutElaborado) {
                if (btnFinalizarSalida) {
                    btnFinalizarSalida.disabled = true;
                    btnFinalizarSalida.style.opacity = '0.6';
                    btnFinalizarSalida.style.cursor = 'not-allowed';
                    btnFinalizarSalida.innerHTML = '<i class="ph ph-clock"></i> <span>⏳ Esperando que el Operador elabore su Checkout</span>';
                    btnFinalizarSalida.title = "El operador convocado debe elaborar primero su checkout de salida para que Coordinación pueda revisarlo o modificarlo.";
                }
                if (btnAgregarHw) btnAgregarHw.disabled = true;
                if (inputBuscarHw) inputBuscarHw.disabled = true;
                if (inputCantHw) inputCantHw.disabled = true;
                if (btnFilaVacia) btnFilaVacia.disabled = true;
                if (btnVaciarLista) btnVaciarLista.disabled = true;
                if (btnGrabarPlantilla) btnGrabarPlantilla.disabled = true;
                if (selKit) selKit.disabled = true;
            } else {
                // El personal ya elaboró su checkout: el coordinador PUEDE modificar, alterar y revisar
                if (btnFinalizarSalida) {
                    btnFinalizarSalida.disabled = false;
                    btnFinalizarSalida.style.opacity = '1';
                    btnFinalizarSalida.style.cursor = 'pointer';
                    btnFinalizarSalida.innerHTML = '<i class="ph ph-floppy-disk"></i> <span>💾 Guardar Modificaciones al Checkout</span>';
                    btnFinalizarSalida.title = "Guardar cambios realizados al checkout del operador convocado";
                }
                if (btnAgregarHw) btnAgregarHw.disabled = false;
                if (inputBuscarHw) inputBuscarHw.disabled = false;
                if (inputCantHw) inputCantHw.disabled = false;
                if (btnFilaVacia) btnFilaVacia.disabled = false;
                if (btnVaciarLista) btnVaciarLista.disabled = false;
                if (btnGrabarPlantilla) btnGrabarPlantilla.disabled = false;
                if (selKit) selKit.disabled = false;
            }
        } else {
            // Operador convocado legítimo
            if (btnFinalizarSalida) {
                btnFinalizarSalida.disabled = false;
                btnFinalizarSalida.style.opacity = '1';
                btnFinalizarSalida.style.cursor = 'pointer';
                btnFinalizarSalida.innerHTML = idMaestroCheckoutActual 
                    ? '<i class="ph ph-floppy-disk"></i> <span>💾 Actualizar mi Salida de Bodega</span>' 
                    : '<i class="ph ph-paper-plane-tilt"></i> <span>🚀 Finalizar y Registrar Salida de Bodega</span>';
                btnFinalizarSalida.title = "Registrar o actualizar la salida física de tus equipos";
            }
            if (btnAgregarHw) btnAgregarHw.disabled = false;
            if (inputBuscarHw) inputBuscarHw.disabled = false;
            if (inputCantHw) inputCantHw.disabled = false;
            if (btnFilaVacia) btnFilaVacia.disabled = false;
            if (btnVaciarLista) btnVaciarLista.disabled = false;
            if (btnGrabarPlantilla) btnGrabarPlantilla.disabled = false;
            if (selKit) selKit.disabled = false;
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
        renderTarjetasIncidenciasCheckin(statusPack, incLimpia, esVacia);

        // Cargar ítems de salida y checkin
        const detalle = statusPack.detalle || [];
        itemsCheckoutSalida = detalle.map(item => {
            const cod = item.ID || item.codigo || "";
            const nom = item.EQUIPO || item.Equipo || item.descripcion || "Equipo sin descripción";
            let obs = item.OBSERVACIONES || item.observaciones || "";
            // Si tiene leyenda de daño pero el equipo ya no está en radar de daños (ya fue reparado), limpiar la nota
            if (obs.includes("DAÑO REPORTADO") && !equipoTieneDanoEnRadar(cod, nom)) {
                obs = obs.replace(/⚠️?\s*\[LLEVA DAÑO REPORTADO\]/gi, '').trim();
            }
            return {
                id_detalle: item.id_detalle,
                ID: cod,
                EQUIPO: nom,
                CANT: parseInt(item.CANT || item.cantidad || 1) || 1,
                OBSERVACIONES: obs
            };
        });

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

        // Control de botón de autorización de Coordinador (EXCLUSIVO COORDINADOR)
        const btnCoord = document.getElementById('btn-autorizar-salida-coordinador');
        
        if (btnCoord) {
            if (esCoordinador && idMaestroCheckoutActual && estadoBodegaCheckoutActual !== 'DESPACHADO' && estadoBodegaCheckoutActual !== 'RECIBIDO') {
                btnCoord.style.display = 'inline-flex';
            } else {
                btnCoord.style.display = 'none';
            }
        }

        // 🔒 Gestión de Bloqueo de Checkout por Incidencias Pendientes
        window.checkoutBloqueadoActual = Boolean(statusPack.checkout_bloqueado);
        window.opsDeudaIncidenciasActual = statusPack.ops_deuda_incidencias || [];

        const alertaBloqueo = document.getElementById('alerta-bloqueo-salida-checkout');
        const txtBloqueo = document.getElementById('texto-bloqueo-salida-checkout');

        if (window.checkoutBloqueadoActual && window.opsDeudaIncidenciasActual.length > 0) {
            const foliosStr = window.opsDeudaIncidenciasActual.map(x => `<b>OP-${x.folio}</b> (${x.evento})`).join(", ");
            if (alertaBloqueo) {
                alertaBloqueo.style.display = 'flex';
                if (txtBloqueo) txtBloqueo.innerHTML = `Tienes pendiente el reporte de incidencias en: ${foliosStr}. Por reglamento de bodega, debes completar tu bitácora antes de retirar nuevo hardware.`;
            }
            if (btnFinalizarSalida) {
                btnFinalizarSalida.style.opacity = '0.5';
                btnFinalizarSalida.title = "Salida bloqueada por incidencias pendientes de eventos anteriores.";
            }
        } else {
            if (alertaBloqueo) alertaBloqueo.style.display = 'none';
            if (btnFinalizarSalida) {
                btnFinalizarSalida.style.opacity = '1';
                btnFinalizarSalida.removeAttribute('title');
            }
        }

        // ⚠️ Si esta OP específica ya fue recibida pero tiene incidencias vacías, mostrar banner de resolución
        const bannerIncPend = document.getElementById('banner-incidencias-pendientes-checkout');
        if (bannerIncPend) {
            if (estadoBodegaCheckoutActual === 'RECIBIDO' && (!incLimpia || esVacia)) {
                bannerIncPend.style.display = 'flex';
            } else {
                bannerIncPend.style.display = 'none';
            }
        }

        // Si el cargamento ya está DESPACHADO, cambiar a la pestaña de Check-in automáticamente SOLO SI ES COORDINADOR
        if (esCoordinador && estadoBodegaCheckoutActual === 'DESPACHADO' && pestanaActivaCheckout === 'salida' && detalle.length > 0) {
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

        itemsCheckoutSalida = parsed.map(it => {
            const nom = it.EQUIPO || it.descripcion || it.DESCRIPCION || it.Equipo || "Equipo";
            const cod = it.ID || it.codigo || it.ID_ITEM || "";
            // Limpiar etiquetas de daño estáticas previas
            let obs = (it.OBSERVACIONES || it.observaciones || '')
                .replace(/⚠️?\s*\[LLEVA DAÑO REPORTADO\]/gi, '')
                .trim();

            // Evaluar en tiempo real si el equipo actualmente tiene ticket abierto en taller (usando coincidencia exacta)
            const tieneDano = equipoTieneDanoEnRadar(cod, nom);

            if (tieneDano) {
                obs = obs ? `⚠️ [LLEVA DAÑO REPORTADO] ${obs}` : `⚠️ [LLEVA DAÑO REPORTADO]`;
            }

            return {
                ID: cod,
                EQUIPO: nom,
                CANT: parseInt(it.CANT || it.cantidad || it.CANTIDAD || 1) || 1,
                OBSERVACIONES: obs
            };
        });

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

    let cod = "";
    let nombreEq = val;
    if (val.includes(' - ')) {
        const partes = val.split(' - ');
        cod = partes[0].trim();
        nombreEq = partes.slice(1).join(' - ').trim();
    }

    const tieneDano = equipoTieneDanoEnRadar(cod, nombreEq);
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

    // Sensor de daño al vuelo con validación estricta
    let obsDano = "";
    if (equipoTieneDanoEnRadar(cod, nombre)) {
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
            OBSERVACIONES: (it.OBSERVACIONES || '')
                .replace(/⚠️?\s*\[LLEVA DAÑO REPORTADO\]/gi, '')
                .trim()
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

    if (!esConvocadoActual) {
        alert("⚠️ No formas parte del personal convocado en esta Orden de Producción. No tienes autorización para realizar checkouts de hardware en este evento.");
        return;
    }

    if (window.checkoutBloqueadoActual && window.opsDeudaIncidenciasActual?.length > 0) {
        const foliosTxt = window.opsDeudaIncidenciasActual.map(x => `OP-${x.folio}`).join(", ");
        if (typeof Swal !== 'undefined') {
            Swal.fire({
                icon: 'error',
                title: '⛔ Salida Bloqueada',
                html: `<p style="font-size: 14px; color: #475569;">Tienes pendiente reportar las incidencias de eventos anteriores: <b>${foliosTxt}</b>.</p><p style="font-size: 12.5px; color: #64748b;">Por reglamento de bodega, debes completar tu bitácora de incidencias antes de realizar un nuevo checkout.</p>`,
                confirmButtonColor: '#ef4444'
            });
        } else {
            alert(`⛔ Salida Bloqueada: Tienes pendiente reportar las incidencias de: ${foliosTxt}. Debes completar tu bitácora antes de retirar nuevo equipo.`);
        }
        return;
    }

    if (itemsCheckoutSalida.length === 0) {
        alert("⚠️ La lista de equipos a salir está vacía. Carga un kit o inyecta hardware.");
        return;
    }

    const empId = empleadoActivoCheckout || (usuarioLogueado?.id_empleado || "001");
    const selKit = document.getElementById('checkout-sel-kit')?.value || "--- Sin plantilla ---";
    const notaIncidenciasInput = (document.getElementById('checkout-salida-incidencias')?.value || '').trim();
    const notaIncidencias = notaIncidenciasInput;

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
        items: itemsFinales,
        usuario_actual: usuarioLogueado?.nombre_completo || 'COORDINADOR'
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
    const rolUsuario = (usuarioLogueado?.rol || '').toUpperCase().trim();
    const puestoUsuario = (usuarioLogueado?.puesto || '').toUpperCase().trim();
    const nomUsuarioUpper = (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || '').toUpperCase().trim();
    const idUsuario = String(usuarioLogueado?.id_empleado || '').trim();
    const esCoordinador = rolUsuario === 'COORDINADOR' || rolUsuario.includes('COORDINADOR') || rolUsuario.includes('COORDINACION') ||
                          puestoUsuario.includes('COORDINADOR') || puestoUsuario.includes('COORDINACION') ||
                          idUsuario === '124' || idUsuario === '000' ||
                          nomUsuarioUpper === 'MANUEL EDUARDO MADRID';

    if (!esCoordinador) {
        alert("⚠️ Acción restringida: Solo el personal con rol de Coordinador puede autorizar la salida.");
        return;
    }

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
    // Regla de Negocio: Únicamente el Coordinador puede hacer Check-in / Retorno a Bodega
    if (!esCoordinadorActivo()) {
        alert("⚠️ Acción restringida: Solo el personal con rol de Coordinador de Bodega puede recibir equipos y finalizar el Check-in.");
        return;
    }

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

    // 🔒 REGLA DE OBLIGATORIEDAD: No permitir finalizar Check-in si el campo de incidencias está en blanco
    const diasTextareas = document.querySelectorAll('.checkin-dia-incidencia');
    if (diasTextareas && diasTextareas.length > 0) {
        let diasVacios = [];
        diasTextareas.forEach(ta => {
            if (!ta.value.trim()) {
                const eti = ta.getAttribute('data-etiqueta') || ta.getAttribute('data-fecha') || 'Jornada';
                diasVacios.push(eti);
            }
        });
        if (diasVacios.length > 0) {
            alert(`⚠️ Reporte de Incidencias Obligatorio:\n\nEl sistema requiere que el colaborador capture el informe operativo de cada jornada.\nFalta capturar incidencias en:\n• ${diasVacios.join('\n• ')}\n\n(Si en ese día no ocurrió ningún percance, presione el botón "Sin incidencias este día" en la tarjeta correspondiente).`);
            const primerVacio = Array.from(diasTextareas).find(ta => !ta.value.trim());
            if (primerVacio) primerVacio.focus();
            return;
        }
    }

    const notaRecepcionInput = (document.getElementById('checkout-checkin-incidencias')?.value || '').trim();
    if (!notaRecepcionInput) {
        alert("⚠️ Reporte de Incidencias Obligatorio:\n\nEl sistema requiere que el colaborador capture el reporte de incidencias o eventualidades del servicio antes de finalizar el Check-in.\n\n(Si no ocurrió ninguna novedad técnica o logística, capture el reporte o presione 'Concluido Sin Incidencias').");
        const elInc = document.getElementById('checkout-checkin-incidencias');
        if (elInc) elInc.focus();
        return;
    }
    const notaRecepcion = notaRecepcionInput;

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
        items: itemsFinales,
        usuario_actual: usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || '',
        id_usuario: usuarioLogueado?.id_empleado || ''
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

function marcarCheckinSinIncidencias(tipo = 'checkin') {
    const el = document.getElementById(tipo === 'salida' ? 'checkout-salida-incidencias' : 'checkout-checkin-incidencias');
    if (el) {
        el.value = "Evento concluido sin incidencias.";
    }
    // Si hay tarjetas multidía en check-in, marcarlas todas sin incidencias
    if (tipo === 'checkin') {
        const diasTextareas = document.querySelectorAll('.checkin-dia-incidencia');
        if (diasTextareas && diasTextareas.length > 0) {
            diasTextareas.forEach(t => {
                t.value = "Sin incidencias reportadas.";
            });
            sincronizarIncidenciasMultidiaCheckin();
        }
    }
}

function marcarDiaCheckinSinIncidencias(fecIso) {
    const ta = document.getElementById(`checkin-dia-${fecIso}`);
    if (ta) {
        ta.value = "Sin incidencias reportadas.";
        sincronizarIncidenciasMultidiaCheckin();
    }
}

async function guardarIncidenciasPendientesCheckout() {
    const selOP = document.getElementById('checkout-sel-op');
    const match = selOP?.value?.match(/OP-(\d+)/i);
    if (!match) return;
    const idEvento = parseInt(match[1]);
    const empId = empleadoActivoCheckout || (usuarioLogueado?.id_empleado || "001");
    
    const txt = (document.getElementById('checkout-salida-incidencias')?.value || document.getElementById('checkout-checkin-incidencias')?.value || '').trim();
    if (!txt) {
        alert("⚠️ Por favor escribe el reporte de incidencias o pulsa 'Concluido Sin Incidencias' antes de guardar.");
        return;
    }
    
    try {
        const res = await fetch(`${API_URL}/api/checkout/guardar-incidencia-pendiente`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                id_evento: idEvento,
                id_empleado: empId,
                incidencias: txt
            })
        });
        if (res.ok) {
            if (typeof Swal !== 'undefined') {
                Swal.fire({
                    icon: 'success',
                    title: '✅ Incidencias Registradas',
                    text: 'Se ha registrado la bitácora correctamente. Tus siguientes checkouts han quedado desbloqueados.',
                    confirmButtonColor: '#16a34a'
                });
            } else {
                alert("✅ Se ha registrado la bitácora correctamente. Tus siguientes checkouts han quedado desbloqueados.");
            }
            await cargarStatusCheckoutActual();
            cargarBadges();
            if (typeof cargarDatosInicio === 'function') cargarDatosInicio();
        } else {
            const err = await res.text();
            alert(`❌ Error al guardar incidencias: ${err}`);
        }
    } catch (e) {
        console.error("Error al guardar incidencias pendientes:", e);
        alert("Error de conexión al guardar incidencias.");
    }
}


