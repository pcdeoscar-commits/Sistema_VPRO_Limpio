// ==============================================================================
// SISTEMA INTEGRAL DIGITAL - VPRO STREAMING SERVICES
// ARCHIVO: script.js (Cliente Web SPA Frontend)
// ==============================================================================

// 1. CONFIGURACIÓN Y VARIABLES GLOBALES
const API_URL = (window.location.origin && window.location.origin !== "null" && window.location.port !== "5500")
    ? window.location.origin
    : (localStorage.getItem("vpro_api_url") || `${window.location.protocol === "https:" ? "https:" : "http:"}//${window.location.hostname || "localhost"}:8521`); 

let usuarioLogueado = null;
let empleadoSeleccionado = null;
let memoriaKiosco = {}; 
let intervaloReloj = null;

// ==========================================
// 2. SISTEMA DE AUTENTICACIÓN Y LOGIN
// ==========================================
async function cargarEmpleados() {
    const contenedor = document.getElementById("contenedor-empleados");
    if (!contenedor) return;

    try {
        const respuesta = await fetch(`${API_URL}/api/empleados`);
        if (!respuesta.ok) throw new Error(`Error HTTP: ${respuesta.status}`);

        const empleados = await respuesta.json();
        contenedor.innerHTML = "";

        // Filtro para excluir bajas y proveedores
        const activos = empleados.filter(emp => {
            const rol = emp.rol ? emp.rol.toUpperCase() : "";
            return rol !== 'BAJA' && rol !== 'INACTIVO' && rol !== 'PROVEEDOR';
        });

        activos.forEach(emp => {
            const urlFoto = `${API_URL}/fotos/${emp.id_empleado}.jpg`; 
            const tarjeta = document.createElement("div");
            tarjeta.className = "card";
            tarjeta.onclick = () => abrirModal(emp, urlFoto);

            const primerNombre = emp.nombre.split(' ')[0];
            const nombreFormateado = primerNombre.charAt(0).toUpperCase() + primerNombre.slice(1).toLowerCase();

            tarjeta.innerHTML = `
                <img src="${urlFoto}" onerror="this.src='vendor/img/avatar_default.png'" alt="Foto">
                <div class="card-info">
                    <h3>${nombreFormateado}</h3>
                    <p>${emp.depto || 'SISTEMAS'}</p>
                </div>
            `;
            contenedor.appendChild(tarjeta);
        });
    } catch (error) {
        console.error("Fallo la conexión con FastAPI:", error);
        contenedor.innerHTML = `
            <div style="grid-column: 1 / -1; background: #fee2e2; border: 1px solid #f87171; padding: 20px; border-radius: 12px; color: #991b1b; text-align: center;">
                <strong>⚠️ Error de conexión:</strong> No se pudo conectar con el servidor FastAPI (${API_URL}). Verifica que el backend esté en ejecución.
            </div>`;
    }
}

function abrirModal(empleado, fotoUrl) {
    empleadoSeleccionado = empleado;
    document.getElementById("modal-nombre").innerText = empleado.nombre;
    document.getElementById("modal-depto").innerText = empleado.depto || "SISTEMAS";
    document.getElementById("modal-foto").src = fotoUrl;
    
    const inputPass = document.getElementById("modal-password");
    inputPass.value = "";
    
    document.getElementById("modal-error").style.display = "none";
    document.getElementById("modal-login").style.display = "flex";
    inputPass.focus();
}

function cerrarModal() {
    document.getElementById("modal-login").style.display = "none";
    empleadoSeleccionado = null;
}

async function verificarAcceso() {
    const password = document.getElementById("modal-password").value;
    const errorMsg = document.getElementById("modal-error");

    if (!password) {
        errorMsg.innerText = "Por favor ingresa tu contraseña.";
        errorMsg.style.display = "block";
        return;
    }

    try {
        const respuesta = await fetch(`${API_URL}/api/auth/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                usuario: empleadoSeleccionado.nombre,
                contrasena: password
            })
        });

        const resultado = await respuesta.json();

        if (respuesta.ok && resultado.autenticado) {
            if (resultado.requiere_cambio) {
                cerrarModal();
                const htmlCheck = `
                    <div style="text-align: left; font-size: 14px; margin-top: 10px;">
                        Tu contraseña actual es <b>demasiado simple</b> o insegura. Por políticas de seguridad, debes actualizarla.<br><br>
                        <b>Debe contener:</b><br>
                        - Al menos 8 caracteres<br>
                        - Una letra MAYÚSCULA<br>
                        - Una letra minúscula<br>
                        - Un número<br>
                        - Un carácter especial (ej. @, $, !, %, *, ?, &)
                        <br><br>
                        <input type="password" id="swal-new-pass" class="swal2-input" placeholder="Nueva Contraseña" style="margin-top: 0;">
                        <input type="password" id="swal-confirm-pass" class="swal2-input" placeholder="Confirmar Nueva Contraseña">
                    </div>
                `;
                
                Swal.fire({
                    title: '🛡️ Cambio de Contraseña Obligatorio',
                    html: htmlCheck,
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonText: 'Actualizar y Entrar',
                    cancelButtonText: 'Cancelar',
                    allowOutsideClick: false,
                    preConfirm: () => {
                        const pass = Swal.getPopup().querySelector('#swal-new-pass').value;
                        const confirm = Swal.getPopup().querySelector('#swal-confirm-pass').value;
                        if (!pass || !confirm) {
                            Swal.showValidationMessage('Debes ingresar la nueva contraseña y confirmarla');
                            return false;
                        }
                        if (pass !== confirm) {
                            Swal.showValidationMessage('Las contraseñas no coinciden');
                            return false;
                        }
                        if (pass.length < 8 || !/[A-Z]/.test(pass) || !/[a-z]/.test(pass) || !/[0-9]/.test(pass) || !/[\W_]/.test(pass)) {
                            Swal.showValidationMessage('La contraseña no cumple con los requisitos de seguridad');
                            return false;
                        }
                        return pass;
                    }
                }).then(async (result) => {
                    if (result.isConfirmed) {
                        try {
                            const resUpdate = await fetch(`${API_URL}/api/auth/cambiar-password`, {
                                method: "POST",
                                headers: { "Content-Type": "application/json" },
                                body: JSON.stringify({
                                    id_empleado: resultado.id_empleado,
                                    nueva_contrasena: result.value
                                })
                            });
                            if (resUpdate.ok) {
                                Swal.fire('Éxito', 'Tu contraseña ha sido actualizada y encriptada.', 'success');
                                iniciarSesionExitosa(resultado);
                            } else {
                                Swal.fire('Error', 'No se pudo actualizar la contraseña.', 'error');
                                document.getElementById("modal-login").style.display = "flex"; // Re-open login
                            }
                        } catch (e) {
                            Swal.fire('Error', 'Error de red al actualizar contraseña.', 'error');
                            document.getElementById("modal-login").style.display = "flex";
                        }
                    } else {
                        document.getElementById("modal-login").style.display = "flex"; // User cancelled, show login
                    }
                });
            } else {
                cerrarModal();
                iniciarSesionExitosa(resultado);
            }
        } else {
            errorMsg.innerText = resultado.detail || "Contraseña incorrecta.";
            errorMsg.style.display = "block";
        }
    } catch (err) {
        console.error("Error en login:", err);
        errorMsg.innerText = "Error al comunicarse con el servidor de autenticación.";
        errorMsg.style.display = "block";
    }
}

function iniciarSesionExitosa(usuario) {
    usuarioLogueado = usuario;
    document.getElementById("vista-login").style.display = "none";
    document.getElementById("sidebar").style.display = "flex";
    document.getElementById("vista-dashboard").style.display = "block";
    
    filtrarMenuPorRol(usuario.rol);
    iniciarRelojKiosco();
    inicializarLectorKiosco(); 
    cargarBadges();
    cambiarVista('vista-inicio'); 
}

function cerrarSesion() {
    document.getElementById("sidebar").style.display = "none";
    document.getElementById("vista-dashboard").style.display = "none";
    document.getElementById("vista-login").style.display = "block";
    usuarioLogueado = null;
    empleadoSeleccionado = null;
}

function filtrarMenuPorRol(rolUsuario) {
    const itemsMenu = document.querySelectorAll('.sidebar-menu .nav-item');
    itemsMenu.forEach(item => {
        const rolesPermitidos = item.getAttribute('data-roles');
        if (!rolesPermitidos || rolesPermitidos.includes('todos')) {
            item.style.display = 'flex';
            return;
        }
        if (rolesPermitidos.toUpperCase().includes((rolUsuario || '').toUpperCase())) {
            item.style.display = 'flex';
        } else {
            item.style.display = 'none';
        }
    });
}

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

// ==========================================
// 4. MÓDULO INICIO (NOTIFICACIONES Y ASISTENCIA)
// ==========================================
function formatearFechaLocal(d) {
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

function obtenerRangoSemanaActual() {
    const ahora = new Date();
    const diaSemana = ahora.getDay();
    // En JS: 0=Domingo, 1=Lunes, ..., 6=Sábado
    const diffLunes = (diaSemana === 0 ? -6 : 1 - diaSemana);
    const lunes = new Date(ahora.getFullYear(), ahora.getMonth(), ahora.getDate() + diffLunes);
    
    const dias = [];
    for (let i = 0; i < 7; i++) {
        const d = new Date(lunes.getFullYear(), lunes.getMonth(), lunes.getDate() + i);
        dias.push({
            dateObj: d,
            iso: formatearFechaLocal(d),
            diaSemanaIdx: d.getDay(),
            display: `${String(d.getDate()).padStart(2, '0')}/${String(d.getMonth() + 1).padStart(2, '0')}/${d.getFullYear()}`
        });
    }
    return { lunes: dias[0], domingo: dias[6], dias };
}

async function cargarDatosInicio() {
    if (!usuarioLogueado) return;

    // 1. Notificaciones: Radar de Bodega (Checkouts) y VPRO Transfer (Archivos Compartidos)
    const contenedorNotif = document.getElementById("inicio-notificaciones");
    if (contenedorNotif) {
        let htmlCards = [];

        // A. Archivos Compartidos Pendientes (VPRO Transfer)
        try {
            const resTrans = await fetch(`${API_URL}/api/transferencias/pendientes_notificacion/${usuarioLogueado.id_empleado}`);
            if (resTrans.ok) {
                const dataTrans = await resTrans.json();
                if (dataTrans && dataTrans.pendientes && dataTrans.pendientes.length > 0) {
                    dataTrans.pendientes.forEach(t => {
                        htmlCards.push(`
                            <div class="alerta-card info" style="background: #eff6ff; border-left: 4px solid #3b82f6; display: flex; align-items: center; gap: 14px; padding: 14px 18px; border-radius: 10px; margin-bottom: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.04);">
                                <div style="width: 42px; height: 42px; border-radius: 8px; background: #2563eb; color: white; display: flex; align-items: center; justify-content: center; font-size: 22px;">
                                    <i class="ph ph-cloud-arrow-down"></i>
                                </div>
                                <div style="flex: 1;">
                                    <div style="font-size: 14px; color: #1e3a8a;">
                                        <b>📦 Archivo compartido recibido:</b> <b>${t.nombre_archivo_original}</b> <span style="background: #dbeafe; color: #1d4ed8; padding: 2px 8px; border-radius: 4px; font-size: 12px; font-weight: 700;">${t.tamano_legible}</span>
                                    </div>
                                    <div style="font-size: 12.5px; color: #475569; margin-top: 2px;">
                                        Enviado por: <b>${t.nombre_origen}</b> • ${t.fecha_subida_str || ''} ${t.mensaje ? `— <i>"${t.mensaje}"</i>` : ''}
                                    </div>
                                    <div style="font-size: 11.5px; color: #0284c7; margin-top: 3px;">
                                        ⏱️ <i>Al descargarlo, permanecerá disponible 7 horas en el servidor antes de ser eliminado automáticamente.</i>
                                    </div>
                                </div>
                                <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
                                    <button onclick="descargarArchivoTransferenciaDirecto(${t.id_transferencia}, '${(t.nombre_archivo_original || '').replace(/'/g, "\\'")}')" style="background: #2563eb; color: white; border: none; padding: 8px 18px; border-radius: 6px; cursor: pointer; font-weight: 700; font-size: 13px; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 6px rgba(37,99,235,0.3);">
                                        <i class="ph ph-download-simple"></i> Descargar
                                    </button>
                                    ${t.folio_paquete ? `
                                    <button onclick="descargarPaqueteZip('${t.folio_paquete}')" style="background: #0284c7; color: white; border: none; padding: 8px 14px; border-radius: 6px; cursor: pointer; font-weight: 700; font-size: 13px; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 6px rgba(2,132,199,0.3);" title="Descargar paquete completo en ZIP">
                                        <i class="ph ph-file-zip"></i> Descargar ZIP
                                    </button>
                                    ` : ''}
                                    <button onclick="cambiarVista('vista-transferencias'); cambiarPestanaTransferencias('recibidos');" style="background: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; padding: 8px 14px; border-radius: 6px; cursor: pointer; font-weight: 600; font-size: 12.5px;">
                                        Ver Todo
                                    </button>
                                </div>
                            </div>
                        `);
                    });
                }
            }
        } catch (e) { console.error("Error al consultar transferencias en inicio:", e); }

        // B. Radar de Bodega (Checkouts de OPs)
        try {
            const resCheck = await fetch(`${API_URL}/api/checkout/pendientes/${usuarioLogueado.id_empleado}/${encodeURIComponent(usuarioLogueado.nombre_completo)}`);
            if (resCheck.ok) {
                const pendientes = await resCheck.json();
                if (pendientes && pendientes.length > 0) {
                    pendientes.forEach(op => {
                        htmlCards.push(`
                            <div class="alerta-card warning" style="margin-bottom: 8px;">
                                <i class="ph ph-warning-circle" style="font-size: 20px;"></i>
                                <span style="flex: 1;">⚠️ <b>${op.label || op.folio || 'Orden pendiente'}</b> | Estatus actual: <code>${op.estado || 'PENDIENTE'}</code></span>
                                <button onclick="abrirCheckoutConOP(${op.id_evento || 0}, '${(op.label || '').replace(/'/g, "\\'")}')" style="background: #b45309; color: white; border: none; padding: 6px 14px; border-radius: 6px; cursor: pointer; font-weight: 600; display: inline-flex; align-items: center; gap: 4px;">
                                    <i class="ph ph-arrow-right"></i> Ver
                                </button>
                            </div>
                        `);
                    });
                }
            }
        } catch (e) { console.error("Error al consultar checkouts en inicio:", e); }

        // C. Alertas Personales de RRHH (Licencias, Cumpleaños, Retardos)
        try {
            const resAlertas = await fetch(`${API_URL}/api/rh/alertas?id_empleado=${usuarioLogueado.id_empleado}`);
            if (resAlertas.ok) {
                const alertas = await resAlertas.json();
                if (alertas && alertas.length > 0) {
                    alertas.forEach(alerta => {
                        let icon = "ph-bell";
                        let color = "#eab308"; // default warning yellow
                        let bg = "#fef9c3";
                        let border = "#ca8a04";
                        
                        if (alerta.tipo === "CUMPLEANOS") {
                            icon = "ph-cake";
                            color = "#ec4899"; bg = "#fdf2f8"; border = "#db2777";
                        } else if (alerta.tipo === "RETARDO") {
                            icon = "ph-clock-afternoon";
                            color = "#f97316"; bg = "#fff7ed"; border = "#ea580c";
                        } else if (alerta.tipo === "DOCUMENTO_POR_VENCER") {
                            icon = "ph-identification-card";
                            if (alerta.urgencia === "ALTA") {
                                color = "#ef4444"; bg = "#fef2f2"; border = "#dc2626";
                            }
                        }

                        htmlCards.push(`
                            <div class="alerta-card info" style="background: ${bg}; border-left: 4px solid ${border}; display: flex; align-items: center; gap: 14px; padding: 14px 18px; border-radius: 10px; margin-bottom: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.04);">
                                <div style="width: 42px; height: 42px; border-radius: 8px; background: ${color}; color: white; display: flex; align-items: center; justify-content: center; font-size: 22px;">
                                    <i class="ph ${icon}"></i>
                                </div>
                                <div style="flex: 1;">
                                    <div style="font-size: 14px; color: #1e293b;">
                                        <b>${alerta.mensaje}</b>
                                    </div>
                                </div>
                            </div>
                        `);
                    });
                }
            }
        } catch (e) { console.error("Error al consultar alertas RH en inicio:", e); }

        if (htmlCards.length > 0) {
            contenedorNotif.innerHTML = htmlCards.join("");
        } else {
            contenedorNotif.innerHTML = `<div class="alerta-card success"><i class="ph ph-check-circle" style="font-size: 20px;"></i> Radar de Bodega y Notificaciones: Todo al día y sin pendientes.</div>`;
        }
    }

    // 2. Asistencia Semanal y Detección de Advertencia de Conducta
    const tbody = document.getElementById("inicio-tabla-asistencia");
    const alertaConductaContenedor = document.getElementById("inicio-alerta-conducta");
    if (!tbody) return;

    try {
        const semana = obtenerRangoSemanaActual();
        const resAsist = await fetch(`${API_URL}/api/asistencia/auditoria`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                fecha_inicio: semana.lunes.iso,
                fecha_fin: semana.domingo.iso,
                empleado: usuarioLogueado.nombre_completo
            })
        });

        const registros = resAsist.ok ? await resAsist.json() : [];
        const diasEspanol = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];
        const hoyIso = formatearFechaLocal(new Date());

        const esVillarreal = usuarioLogueado.nombre_completo.toUpperCase().includes("VILLARREAL");
        let advertenciaConductaDetectada = false;

        const limpiaHora = (h) => (h && h !== "None" && h !== "null" && h !== "--:--") ? String(h).substring(0, 5) : "--:--";

        let htmlTabla = "";
        for (let i = 0; i < 7; i++) {
            const diaInfo = semana.dias[i];
            const fIso = diaInfo.iso;
            const reg = registros.find(r => r.fecha === fIso);

            let mIn = reg ? limpiaHora(reg.hora_entrada) : "--:--";
            let mOut = reg ? limpiaHora(reg.hora_salida) : "--:--";
            let vIn = reg ? limpiaHora(reg.hora_entrada_v) : "--:--";
            let vOut = reg ? limpiaHora(reg.hora_salida_v) : "--:--";
            let obs = reg ? (reg.observaciones || "") : "";

            const esPasadoOHoy = fIso <= hoyIso;
            const esFinDeSemana = (i === 5 || i === 6); // Sábado o Domingo

            // Verificar si hubo omisión de comida
            const omitioComida = (!esVillarreal) && (
                obs.toUpperCase().includes("OMISIÓN") || 
                obs.toUpperCase().includes("ADVERTENCIA") ||
                (mIn !== "--:--" && mOut === "--:--" && vIn === "--:--" && vOut !== "--:--")
            );

            if (omitioComida) {
                advertenciaConductaDetectada = true;
                obs = "🚨 Práctica indebida: Omisión de registro de comida";
            } else if (esPasadoOHoy && mIn === "--:--" && mOut === "--:--" && vIn === "--:--" && vOut === "--:--") {
                obs = esFinDeSemana ? "Descanso" : "❌ Sin registro";
            } else if (esPasadoOHoy && !obs && (mIn !== "--:--" || vOut !== "--:--")) {
                obs = "✅ Al día";
            }

            // Resaltado de marcas faltantes
            const claseIn = (mIn === "--:--" && esPasadoOHoy && !esFinDeSemana) ? "td-error" : "";
            const claseOut = (mOut === "--:--" && mIn !== "--:--" && !omitioComida) ? "td-error" : "";

            htmlTabla += `
                <tr>
                    <td style="font-weight: 600; color: #1e293b;">${diasEspanol[i]}</td>
                    <td>${diaInfo.display}</td>
                    <td class="${claseIn}">${mIn}</td>
                    <td class="${claseOut}">${mOut}</td>
                    <td>${vIn}</td>
                    <td>${vOut}</td>
                    <td>${obs}</td>
                </tr>
            `;
        }
        tbody.innerHTML = htmlTabla;

        // Renderizar banner de advertencia de conducta si corresponde
        if (alertaConductaContenedor) {
            if (advertenciaConductaDetectada && !esVillarreal) {
                alertaConductaContenedor.innerHTML = `
                    <div style="background-color: #fef2f2; color: #991b1b; border: 1px solid #f87171; margin-bottom: 24px; padding: 18px 24px; border-radius: 12px; display: flex; align-items: flex-start; gap: 16px; box-shadow: 0 4px 6px -1px rgba(239, 68, 68, 0.1);">
                        <i class="ph ph-warning-octagon" style="font-size: 32px; color: #ef4444; flex-shrink: 0; margin-top: 2px;"></i>
                        <div style="flex: 1;">
                            <h4 style="margin: 0 0 6px 0; font-size: 16px; color: #991b1b; font-weight: 700;">🚨 ADVERTENCIA DE CONDUCTA LABORAL</h4>
                            <p style="margin: 0; font-size: 13.5px; line-height: 1.5; color: #7f1d1d;">
                                <b>Atención ${usuarioLogueado.nombre_completo}:</b> Se ha detectado una práctica incorrecta en tus registros de asistencia al registrar únicamente entrada matutina y salida vespertina omitiendo el registro de comida. El horario corrido continuo no está autorizado. Favor de pasar a Recursos Humanos para regularizar tu estatus.
                            </p>
                        </div>
                    </div>
                `;
            } else {
                alertaConductaContenedor.innerHTML = "";
            }
        }
    } catch (e) {
        console.error("Error al cargar la asistencia semanal:", e);
        tbody.innerHTML = `<tr><td colspan="7" style="color:red; text-align: center; padding: 16px;">Error de red al consultar el registro de asistencia.</td></tr>`;
    }
}

// ==========================================
// 5. MOTOR DEL RELOJ Y KIOSCO
// ==========================================
function iniciarRelojKiosco() {
    const reloj = document.getElementById("reloj-pantalla");
    const fecha = document.getElementById("fecha-pantalla");
    if (!reloj || !fecha) return;

    const actualizar = () => {
        const ahora = new Date();
        reloj.innerText = ahora.toLocaleTimeString('es-MX', { hour12: false });
        fecha.innerText = ahora.toLocaleDateString('es-MX', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
        verificarHorariosCampana();
    };
    
    actualizar();
    clearInterval(intervaloReloj);
    intervaloReloj = setInterval(actualizar, 1000);
}

async function cargarMatrizKiosco(idRecienRegistrado = null) {
    const tbody = document.getElementById("tabla-asistencia-body");
    if (!tbody) return;

    try {
        const [resEmps, resAsist] = await Promise.all([
            fetch(`${API_URL}/api/empleados`),
            fetch(`${API_URL}/api/asistencia/reporte`)
        ]);

        const empleados = await resEmps.json();
        const asistencia = await resAsist.json();

        const hoyStr = formatearFechaLocal(new Date());
        const registrosHoy = asistencia.filter(r => r.fecha && r.fecha.startsWith(hoyStr));
        tbody.innerHTML = ""; 

        // 1. Filtrar empleados activos (excluyendo bajas, inactivos, proveedores, externos)
        const esValidoActivo = (e) => {
            if (!e) return false;
            const idE = String(e.id_empleado || '').trim();
            if (idE === "529" || !idE) return false;
            const email = String(e.email || '').trim();
            if (!email.includes("@")) return false;
            const todoTexto = `${e.estatus || ''} ${e.estatus_empleado || ''} ${e.rol || ''} ${e.depto || ''}`.toUpperCase();
            if (todoTexto.includes("BAJA") || todoTexto.includes("INACT") || todoTexto.includes("PROV") || todoTexto.includes("EXTERN")) return false;
            return true;
        };

        const mapEmpleados = new Map();
        empleados.forEach(e => {
            if (esValidoActivo(e)) {
                mapEmpleados.set(String(e.id_empleado).trim(), e);
            }
        });

        // 2. Determinar si un registro tiene checada real o incidencia RH
        const esHoraValida = (h) => (h && h !== "None" && h !== "null" && h !== "--:--" && String(h).trim() !== "");
        const tieneRegistroActivoHoy = (r) => {
            if (!r) return false;
            const est = String(r.estatus || '').toUpperCase();
            if (['VACACIONES', 'PERMISO', 'INCAPACIDAD'].includes(est)) return true;
            return esHoraValida(r.hora_entrada) || esHoraValida(r.hora_salida) || esHoraValida(r.hora_entrada_v) || esHoraValida(r.hora_salida_v);
        };

        // 3. Filtrar registros de hoy: SOLO empleados activos que ya registraron asistencia o incidencia
        const registrosFiltrados = registrosHoy.filter(r => {
            const idE = String(r.id_empleado || '').trim();
            return mapEmpleados.has(idE) && tieneRegistroActivoHoy(r);
        });

        // 4. Si aún no hay registros hoy, mostrar estado esperando checadas
        if (registrosFiltrados.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="5" style="text-align: center; padding: 36px 20px; color: var(--text-muted); font-size: 13.5px;">
                        <i class="ph ph-clock-countdown" style="font-size: 28px; display: block; margin-bottom: 8px; color: #94a3b8;"></i>
                        <span>Esperando checadas del día de hoy. La lista se irá formando conforme el personal registre su asistencia.</span>
                    </td>
                </tr>
            `;
            return;
        }

        // 5. Ordenar cronológicamente conforme se van registrando (por id_registro ASC o primera hora)
        registrosFiltrados.sort((a, b) => {
            const idA = Number(a.id_registro) || 0;
            const idB = Number(b.id_registro) || 0;
            if (idA > 0 && idB > 0 && idA !== idB) return idA - idB;
            const horaA = String(a.hora_entrada || a.hora_entrada_v || '99:99');
            const horaB = String(b.hora_entrada || b.hora_entrada_v || '99:99');
            return horaA.localeCompare(horaB);
        });

        // 6. Renderizar únicamente a quienes ya checaron hoy
        registrosFiltrados.forEach(reg => {
            const emp = mapEmpleados.get(String(reg.id_empleado).trim());
            if (!emp) return;

            const esReciente = (idRecienRegistrado && String(emp.id_empleado).trim() === String(idRecienRegistrado).trim());
            const estiloFila = esReciente ? 'style="background: #f0fdf4; border-left: 4px solid #10b981; transition: background 0.6s ease;"' : '';

            // 🌴 Si el colaborador se encuentra en periodo de Vacaciones, Permiso o Incapacidad
            if (['VACACIONES', 'PERMISO', 'INCAPACIDAD'].includes(String(reg.estatus || '').toUpperCase())) {
                const est = String(reg.estatus).toUpperCase();
                let badgeTxt = '🌴 EN VACACIONES AUTORIZADAS';
                let bgStyle = 'background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0;';
                if (est === 'PERMISO') {
                    badgeTxt = '⏱️ PERMISO LABORAL AUTORIZADO';
                    bgStyle = 'background: #eff6ff; color: #1e40af; border: 1px solid #bfdbfe;';
                } else if (est === 'INCAPACIDAD') {
                    badgeTxt = '🏥 INCAPACIDAD MÉDICA (IMSS)';
                    bgStyle = 'background: #fee2e2; color: #991b1b; border: 1px solid #fecaca;';
                }

                tbody.innerHTML += `
                    <tr ${estiloFila}>
                        <td style="font-weight: 600; color: var(--text-main);">${emp.nombre}</td>
                        <td colspan="4" style="text-align: center; font-weight: 700; font-size: 12px; padding: 6px; ${bgStyle} border-radius: 6px;">
                            ${badgeTxt}
                        </td>
                    </tr>
                `;
                return;
            }

            const limpiaHora = (h) => esHoraValida(h) ? String(h).substring(0, 5) : "--:--";
            const inMat = limpiaHora(reg.hora_entrada);
            const outMat = limpiaHora(reg.hora_salida);
            const inVesp = limpiaHora(reg.hora_entrada_v);
            const outVesp = limpiaHora(reg.hora_salida_v);

            const stError = "color: #9f1239; background: #ffe4e6; font-weight: bold;";
            const tdOutMat = (outMat === "--:--" && inMat !== "--:--") ? `<td style="${stError}">--:--</td>` : `<td>${outMat}</td>`;

            tbody.innerHTML += `
                <tr ${estiloFila}>
                    <td style="font-weight: 600; color: var(--text-main);">${emp.nombre}</td>
                    <td>${inMat}</td>
                    ${tdOutMat}
                    <td>${inVesp}</td>
                    <td>${outVesp}</td>
                </tr>
            `;
        });
    } catch (error) {
        tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; color: #ef4444; padding: 16px;">Error cargando la matriz del kiosco.</td></tr>`;
    }
}

function reproducirBeepKiosco(tipo = 'ok') {
    try {
        const AudioContext = window.AudioContext || window.webkitAudioContext;
        if (!AudioContext) return;
        const audioCtx = new AudioContext();
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        if (tipo === 'ok') {
            osc.frequency.setValueAtTime(880, audioCtx.currentTime);
            gain.gain.setValueAtTime(0.2, audioCtx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.15);
            osc.start();
            osc.stop(audioCtx.currentTime + 0.15);
        } else {
            osc.frequency.setValueAtTime(440, audioCtx.currentTime);
            gain.gain.setValueAtTime(0.25, audioCtx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.3);
            osc.start();
            osc.stop(audioCtx.currentTime + 0.3);
        }
    } catch (e) {}
}

function cambiarPestanaChecador(tab) {
    const tabs = ['kiosco', 'credencial', 'auditoria'];
    tabs.forEach(t => {
        const btn = document.getElementById(`tab-checador-btn-${t}`);
        const view = document.getElementById(`subvista-checador-${t}`);
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

    if (tab === 'kiosco') {
        iniciarRelojKiosco();
        cargarMatrizKiosco();
    } else if (tab === 'credencial') {
        cargarCredencialPersonal();
    } else if (tab === 'auditoria') {
        cargarAuditoriaAsistencia();
    }
}

function filtrarMatrizKiosco(termino) {
    const t = (termino || "").toLowerCase().trim();
    const rows = document.querySelectorAll("#tabla-asistencia-body tr");
    rows.forEach(r => {
        const text = r.innerText.toLowerCase();
        r.style.display = text.includes(t) ? "" : "none";
    });
}

async function cargarCredencialPersonal() {
    if (!usuarioLogueado) return;
    const idEmp = String(usuarioLogueado.id_empleado || '000').trim();
    
    const elNombre = document.getElementById("credencial-nombre");
    const elId = document.getElementById("credencial-id");
    const elDepto = document.getElementById("credencial-depto");
    const elPuesto = document.getElementById("credencial-puesto");
    const elIngreso = document.getElementById("credencial-ingreso");
    const elRolBadge = document.getElementById("credencial-badge-rol");
    const elFoto = document.getElementById("credencial-foto");

    if (elNombre) elNombre.innerText = usuarioLogueado.nombre_completo || 'Colaborador VPRO';
    if (elId) elId.innerText = idEmp;
    if (elDepto) elDepto.innerText = usuarioLogueado.depto || 'General';
    if (elPuesto) elPuesto.innerText = usuarioLogueado.rol || 'Personal';
    if (elRolBadge) elRolBadge.innerText = (usuarioLogueado.rol || 'OPERADOR').toUpperCase();
    if (elFoto) elFoto.src = usuarioLogueado.foto_url || `${API_URL}/fotos/${idEmp}.jpg`;

    try {
        const resQr = await fetch(`${API_URL}/api/empleados/${idEmp}/qr`);
        if (resQr.ok) {
            const dataQr = await resQr.json();
            const qrImg = document.getElementById("credencial-qr-img");
            const btnDescargar = document.getElementById("credencial-btn-descargar-qr");
            if (qrImg && dataQr.qr_base64) {
                qrImg.src = dataQr.qr_base64;
            }
            if (btnDescargar && dataQr.qr_base64) {
                btnDescargar.href = dataQr.qr_base64;
                btnDescargar.download = `QR_VPRO_${idEmp}.png`;
            }
        }
    } catch (e) {
        console.warn("No se pudo cargar el QR:", e);
    }

    try {
        const resAsist = await fetch(`${API_URL}/api/asistencia/reporte`);
        if (resAsist.ok) {
            const registros = await resAsist.json();
            const hoyStr = formatearFechaLocal(new Date());
            const miReg = registros.find(r => String(r.id_empleado).trim() === idEmp && r.fecha && r.fecha.startsWith(hoyStr));
            
            const matIn = document.getElementById("mi-marca-mat-in");
            const matOut = document.getElementById("mi-marca-mat-out");
            const vespIn = document.getElementById("mi-marca-vesp-in");
            const vespOut = document.getElementById("mi-marca-vesp-out");

            const matInEst = document.getElementById("mi-marca-mat-in-est");
            const matOutEst = document.getElementById("mi-marca-mat-out-est");
            const vespInEst = document.getElementById("mi-marca-vesp-in-est");
            const vespOutEst = document.getElementById("mi-marca-vesp-out-est");

            const limpiaHora = (h) => (h && h !== "None" && h !== "null" && h !== "--:--") ? String(h).substring(0, 8) : "--:--:--";
            
            if (miReg) {
                const h1 = limpiaHora(miReg.hora_entrada);
                const h2 = limpiaHora(miReg.hora_salida);
                const h3 = limpiaHora(miReg.hora_entrada_v);
                const h4 = limpiaHora(miReg.hora_salida_v);

                if (matIn) matIn.innerText = h1;
                if (matOut) matOut.innerText = h2;
                if (vespIn) vespIn.innerText = h3;
                if (vespOut) vespOut.innerText = h4;

                if (matInEst) matInEst.innerHTML = h1 !== "--:--:--" ? '<span style="color:#16a34a; font-weight:700;">🟢 Registrada</span>' : '<span style="color:#94a3b8;">Pendiente</span>';
                if (matOutEst) matOutEst.innerHTML = h2 !== "--:--:--" ? '<span style="color:#16a34a; font-weight:700;">🟢 Registrada</span>' : '<span style="color:#94a3b8;">Pendiente</span>';
                if (vespInEst) vespInEst.innerHTML = h3 !== "--:--:--" ? '<span style="color:#16a34a; font-weight:700;">🟢 Registrada</span>' : '<span style="color:#94a3b8;">Pendiente</span>';
                if (vespOutEst) vespOutEst.innerHTML = h4 !== "--:--:--" ? '<span style="color:#16a34a; font-weight:700;">🟢 Registrada</span>' : '<span style="color:#94a3b8;">Pendiente</span>';
            }
        }
    } catch (e) {
        console.warn("No se pudieron consultar marcas de hoy:", e);
    }
}

function inicializarLectorKiosco() {
    const inputGafete = document.getElementById("input-gafete");
    const alertaKiosco = document.getElementById("kiosco-alerta");
    if (!inputGafete || !alertaKiosco) return;

    setInterval(() => {
        const vistaKiosco = document.getElementById("vista-checador");
        if (vistaKiosco && vistaKiosco.style.display !== "none" && document.activeElement !== inputGafete) {
            inputGafete.focus();
        }
    }, 1200);

    inputGafete.addEventListener("keydown", async function(event) {
        if (event.key === "Enter") {
            event.preventDefault();
            const qrCode = inputGafete.value.trim();
            inputGafete.value = ""; 
            if (!qrCode) return;

            const ahoraTS = Date.now();
            if (memoriaKiosco[qrCode] && (ahoraTS - memoriaKiosco[qrCode]) < 60000) {
                mostrarAlerta("⏱️ Asistencia ya registrada recientemente.", "#fef3c7", "#92400e", "#f59e0b");
                reproducirBeepKiosco('warn');
                return;
            }
            memoriaKiosco[qrCode] = ahoraTS;
            
            try {
                const respuesta = await fetch(`${API_URL}/api/asistencia/checar`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ id_empleado: qrCode, tipo_movimiento: "CHEQUEO", estatus: "ASISTENCIA", observaciones: "Kiosco HTML" })
                });
                const resultado = await respuesta.json();

                if (respuesta.ok && resultado.status !== "WARNING") {
                    // 🗣️ Le pasamos el ID escaneado (qrCode) y el nombre de respaldo
                    decirSaludoKiosco(qrCode, resultado.nombre_empleado || "");
                }
                
                try {
                    const resEmps = await fetch(`${API_URL}/api/empleados`);
                    const emp = (await resEmps.json()).find(e => String(e.id_empleado).trim() === qrCode);
                    if (emp) {
                        document.getElementById("scan-nombre").innerText = emp.nombre;
                        document.getElementById("scan-id").innerText = `ID: ${emp.id_empleado}`;
                        if (resultado.tipo_rh) {
                            const badge = document.getElementById("scan-badge");
                            badge.innerText = `🌴 ${resultado.tipo_rh}`;
                            badge.style.background = "#dcfce7";
                            badge.style.color = "#166534";
                        } else {
                            document.getElementById("scan-badge").innerText = resultado.status === "WARNING" ? "🚨 OMISIÓN DETECTADA" : "✅ REGISTRADO";
                        }
                        document.getElementById("scan-foto").src = `${API_URL}/fotos/${emp.id_empleado}.jpg`;
                    }
                } catch (e) {}

                if (respuesta.ok && resultado.status !== "WARNING") {
                    reproducirBeepKiosco('ok');
                    mostrarAlerta(`✅ ${resultado.mensaje}`, "#d1fae5", "#065f46", "#10b981");
                } else if (resultado.status === "WARNING") {
                    reproducirBeepKiosco('warn');
                    mostrarAlerta(`⚠️ ${resultado.mensaje}`, "#fef3c7", "#92400e", "#f59e0b");
                } else {
                    reproducirBeepKiosco('warn');
                    mostrarAlerta(`❌ ${resultado.detail || "Error al registrar."}`, "#fee2e2", "#991b1b", "#ef4444");
                }

                cargarMatrizKiosco(qrCode);
            } catch (error) { 
                reproducirBeepKiosco('warn');
                mostrarAlerta("📡 Error de conexión con el servidor.", "#fee2e2", "#991b1b", "#ef4444"); 
            }
        }
    });

    function mostrarAlerta(texto, bg, color, border) {
        alertaKiosco.style.display = "block";
        alertaKiosco.style.backgroundColor = bg;
        alertaKiosco.style.color = color;
        alertaKiosco.style.border = `1px solid ${border}`;
        alertaKiosco.innerText = texto;
        setTimeout(() => alertaKiosco.style.display = "none", 4000);
    }
}

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
        selectHtml = `
            <select class="multiselect-select" onchange="addMultiTag('${stateKey}', this.value, '${containerId}'); this.value='';">
                <option value="">${selectedList.length === 0 ? placeholder : '+ Agregar...'}</option>
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
    if (!window.opMultiSelects[stateKey].includes(val)) {
        window.opMultiSelects[stateKey].push(val);
    }
    const cats = window.vproCatalogosOP || {};
    let optionsList = [];
    if (stateKey === 'personal_vpro') { optionsList = cats.staff_vpro; actualizarCrewGira(); }
    else if (stateKey === 'vehiculos') optionsList = cats.autos;
    else if (stateKey === 'personal_externo') optionsList = cats.apoyos_externos;
    else if (stateKey === 'proveedores') optionsList = cats.proveedores;
    else if (stateKey === 'reuniones') optionsList = cats.reuniones;

    renderMultiSelectComponent(containerId, stateKey, optionsList, "Seleccionar...");
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

    renderMultiSelectComponent(containerId, stateKey, optionsList, "Seleccionar...");
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

    renderMultiSelectComponent(containerId, stateKey, optionsList, "Seleccionar...");
}

function actualizarCrewGira() {
    const el = document.getElementById("texto-crew-gira");
    if (!el) return;
    const crew = window.opMultiSelects.personal_vpro || [];
    el.innerText = crew.length > 0 ? crew.join(", ") : "Sin personal asignado en la orden";
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
    const hInicio = (data.inicio_del_evento ? String(data.inicio_del_evento).substring(0, 5) : "13:30");
    const hLlamado = (data.hra_de_llamado ? String(data.hra_de_llamado).substring(0, 5) : "09:00");

    // Autorizaciones defaults
    const defElabora = data.elabora || "Ana Lilia Villarreal Uribe";
    const defCoordina = data.coordina || "Manuel Eduardo Madrid";
    const defOrganiza = data.organiza || "Martin Eduardo Sanchez Estrada";
    const defVobo = data.vobo || "Gerardo Villarreal Uribe";

    const defaultNota = "Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.";

    // Select options helpers
    const buildOptions = (list, selectedVal, addEmpty = false) => {
        let opts = addEmpty ? '<option value="">---</option>' : '';
        (list || []).forEach(item => {
            const sel = (String(item).trim() === String(selectedVal || '').trim()) ? 'selected' : '';
            opts += `<option value="${item}" ${sel}>${item}</option>`;
        });
        return opts;
    };

    const dis = isReadOnly ? 'disabled' : '';
    const rolUsuario = (usuarioLogueado?.rol || '').toUpperCase();
    const esCoordinadorOAdmin = rolUsuario.includes('ADMIN') || rolUsuario.includes('PRODUCCION') || rolUsuario.includes('COORDINADOR') || rolUsuario.includes('COORDINACION');

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
                    <button type="button" onclick="habilitarOPParaEdicion('${folioVal}')" style="background: #16a34a; color: white; border: none; padding: 10px 18px; border-radius: 8px; font-weight: 700; font-size: 13.5px; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 4px 10px rgba(22, 163, 74, 0.3); transition: all 0.2s;">
                        <i class="ph ph-lock-key-open"></i> 🔓 Habilitar OP para Agregar Evidencias / Edición
                    </button>
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
                <h3 class="op-section-title">📝 Datos de la Orden</h3>
                
                <!-- Fila 1: Folio, Cliente, Evento -->
                <div style="display: grid; grid-template-columns: 1fr 2.5fr 3.5fr; gap: 16px; margin-bottom: 16px;">
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
                        <label class="op-form-label">🎉 EVENTO:</label>
                        <input type="text" id="op_nombre_evento" value="${data.nombre_evento || ''}" class="op-input" placeholder="Nombre completo del evento..." ${dis}>
                    </div>
                </div>

                <!-- Fila 2: Locación, Fecha Inst, Hora Inst -->
                <div style="display: grid; grid-template-columns: 2fr 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                    <div>
                        <label class="op-form-label">📍 LOCACIÓN (Lugar):</label>
                        <input type="text" id="op_locacion" value="${data.locacion || ''}" class="op-input" placeholder="Lugar o sede del evento..." ${dis}>
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

                <!-- Fila 3: Solicita, Productor Resp, Fecha Evento, H. Inicio, H. Llamado -->
                <div style="display: grid; grid-template-columns: 1.8fr 2fr 1.2fr 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                    <div>
                        <label class="op-form-label">📣 SOLICITA:</label>
                        <input type="text" id="op_quien_solicita" value="${data.quien_solicita || ''}" class="op-input" placeholder="Ej. DES.TECNOLOGICO" ${dis}>
                    </div>
                    <div>
                        <label class="op-form-label">🎬 PRODUCTOR RESP.:</label>
                        <select id="op_resp_de_produccion" class="op-select" ${dis}>
                            ${buildOptions(cats.staff_vpro, data.resp_de_produccion, true)}
                        </select>
                    </div>
                    <div>
                        <label class="op-form-label">🗓️ FECHA EVENTO:</label>
                        <input type="date" id="op_fec_del_evento" value="${fEvento}" class="op-input" ${dis}>
                    </div>
                    <div>
                        <label class="op-form-label">🚀 H. INICIO:</label>
                        <input type="time" id="op_inicio_del_evento" value="${hInicio}" class="op-input" ${dis}>
                    </div>
                    <div>
                        <label class="op-form-label">📞 H. LLAMADO:</label>
                        <input type="time" id="op_hra_de_llamado" value="${hLlamado}" class="op-input" ${dis}>
                    </div>
                </div>

                <!-- Fila 4: Ubicación Exacta -->
                <div style="margin-bottom: 16px;">
                    <label class="op-form-label">🗺️ UBICACIÓN EXACTA:</label>
                    <input type="text" id="op_ubicacion" value="${data.ubicacion || ''}" class="op-input" placeholder="Dirección precisa, salón, piso o referencias GPS..." ${dis}>
                </div>

                <!-- Fila 5: Vincular Reunión(es) -->
                <div style="margin-bottom: 16px;">
                    <label class="op-form-label">🤝 VINCULAR REUNIÓN(ES):</label>
                    <div id="ms-reuniones-${isReadOnly ? 'hist' : 'act'}"></div>
                </div>

                <!-- Fila 5.1: Vincular Cronograma(s) de Actividades -->
                <div style="margin-bottom: 16px;">
                    <label class="op-form-label">📅 VINCULAR CRONOGRAMA(S) DE ACTIVIDADES:</label>
                    <div id="ms-cronogramas-${isReadOnly ? 'hist' : 'act'}"></div>
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

            <!-- 📅 DETALLE DE CRONOGRAMAS VINCULADOS -->
            ${(data.detalle_cronogramas && data.detalle_cronogramas.length > 0) ? `
                <div class="op-section-card" style="border-left: 4px solid #0284c7;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
                        <h3 class="op-section-title" style="margin: 0; color: #0369a1;">
                            <i class="ph ph-calendar-check"></i> 📅 Cronograma(s) de Actividades Vinculado(s) a esta OP
                        </h3>
                    </div>
                    ${data.detalle_cronogramas.map(cron => `
                        <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 16px; margin-bottom: 16px;">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; flex-wrap: wrap; gap: 8px;">
                                <div>
                                    <span style="font-weight: 800; font-size: 15px; color: #0f172a;">FOLIO: ${cron.folio || cron.id_cronograma}</span>
                                    <span style="margin-left: 12px; font-weight: 600; color: #0284c7;">📅 FECHA: ${cron.fecha || '--'}</span>
                                    <span style="margin-left: 12px; color: #475569;">📍 ${cron.ubicacion_general || '--'}</span>
                                </div>
                                <button type="button" onclick="imprimirCronogramaDirecto(${cron.id_cronograma})" style="background: #0284c7; color: white; border: none; padding: 6px 14px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 6px;">
                                    <i class="ph ph-printer"></i> 🖨️ Imprimir Hoja Oficial
                                </button>
                            </div>
                            <div class="cat-table-wrap" style="max-height: 280px; overflow-y: auto;">
                                <table class="tabla-vpro" style="font-size: 11.5px;">
                                    <thead>
                                        <tr>
                                            <th>Horario</th>
                                            <th>Actividad</th>
                                            <th>Ubicación</th>
                                            <th>Evento</th>
                                            <th>Personal Convocado</th>
                                            <th>Vehículo</th>
                                            <th>Observaciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${(Array.isArray(cron.actividades) && cron.actividades.length > 0) ? cron.actividades.map(act => `
                                            <tr>
                                                <td style="font-weight: 600;">${act.horario || ''}</td>
                                                <td>${act.actividad || ''}</td>
                                                <td>${act.ubicacion || ''}</td>
                                                <td>${act.evento || ''}</td>
                                                <td>${act.personal_convocado || ''}</td>
                                                <td>${act.vehiculo || ''}</td>
                                                <td>${act.observaciones || ''}</td>
                                            </tr>
                                        `).join('') : '<tr><td colspan="7" style="text-align: center;">Sin actividades desglosadas.</td></tr>'}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    `).join('')}
                </div>
            ` : ''}

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

            <!-- 💾 BOTÓN GUARDAR MAESTRO Y ACCIÓN DE HISTORIAL -->
            ${!isReadOnly ? `
                <div style="margin-top: 14px; margin-bottom: 20px; display: flex; gap: 14px; flex-wrap: wrap;">
                    <button type="submit" style="flex: 2; min-width: 220px; background: #ef4444; color: white; border: none; padding: 16px; border-radius: 8px; font-weight: 700; font-size: 15px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; box-shadow: 0 4px 6px -1px rgba(239, 68, 68, 0.25); transition: background 0.2s;">
                        💾 GUARDAR CAMBIOS ORDEN
                    </button>
                    ${esCoordinadorOAdmin && data.folio ? `
                        <button type="button" onclick="mandarOPAlHistorial('${folioVal}')" style="flex: 1; min-width: 200px; background: #334155; color: white; border: none; padding: 16px 20px; border-radius: 8px; font-weight: 700; font-size: 14.5px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; box-shadow: 0 4px 6px -1px rgba(51, 65, 85, 0.25); transition: background 0.2s;">
                            <i class="ph ph-archive-box"></i> 📦 Mandar al Historial
                        </button>
                    ` : ''}
                </div>
            ` : ''}
        </form>
    `;
}

// -------------------------------------------------------------
// Carga del Detalle para OPs Activas
// -------------------------------------------------------------
async function cargarDetalleOP(folioId) {
    const container = document.getElementById('formulario-op-container');
    if (!container) return;

    const cats = window.vproCatalogosOP || {};

    if (!folioId) {
        // Modo Nueva Orden
        window.opMultiSelects = {
            personal_vpro: [],
            vehiculos: [],
            personal_externo: [],
            proveedores: [],
            reuniones: [],
            cronogramas: []
        };
        window.opFotosEvidenciaActuales = [];

        const proximoFolio = window.vproProximoId || 1;
        container.innerHTML = generarHtmlFormularioOP({ id_evento: proximoFolio, folio: String(proximoFolio) }, false);

        // Renderizar multi-selects en blanco
        renderMultiSelectComponent('ms-reuniones-act', 'reuniones', cats.reuniones, "Despliega y selecciona una o varias reuniones...");
        renderMultiSelectComponent('ms-cronogramas-act', 'cronogramas', cats.cronogramas, "Despliega y selecciona cronograma(s) de actividades...");
        renderMultiSelectComponent('ms-personal_vpro-act', 'personal_vpro', cats.staff_vpro, "Choose options");
        renderMultiSelectComponent('ms-personal_externo-act', 'personal_externo', cats.apoyos_externos, "Choose options");
        renderMultiSelectComponent('ms-vehiculos-act', 'vehiculos', cats.autos, "Choose options");
        renderMultiSelectComponent('ms-proveedores-act', 'proveedores', cats.proveedores, "Choose options");

        actualizarCrewGira();
        return;
    }

    container.innerHTML = `<p style="color: var(--text-muted); text-align: center; padding: 30px;">Cargando información completa del folio ${folioId}...</p>`;

    try {
        const response = await fetch(`${API_URL}/api/eventos/buscar/${encodeURIComponent(folioId)}`);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const data = await response.json();

        // Inicializar estado de multiselects con lo guardado en base de datos
        window.opMultiSelects = {
            personal_vpro: Array.isArray(data.personal_convocado_op) ? data.personal_convocado_op : [],
            vehiculos: Array.isArray(data.carros_usados_op) ? data.carros_usados_op : [],
            personal_externo: Array.isArray(data.externos_op) ? data.externos_op : [],
            proveedores: Array.isArray(data.proveedor_op) ? data.proveedor_op : [],
            reuniones: Array.isArray(data.reuniones_vinculadas) ? data.reuniones_vinculadas : [],
            cronogramas: Array.isArray(data.cronogramas_vinculados) ? data.cronogramas_vinculados : []
        };
        window.opFotosEvidenciaActuales = Array.isArray(data.fotos_evidencia) ? data.fotos_evidencia : [];
        window.opHabilitadaTemporalmenteFolio = data.habilitada_para_edicion ? data.folio : null;

        container.innerHTML = generarHtmlFormularioOP(data, false);

        // Renderizar los componentes multiselect poblados
        renderMultiSelectComponent('ms-reuniones-act', 'reuniones', cats.reuniones, "Despliega y selecciona una o varias reuniones...");
        renderMultiSelectComponent('ms-cronogramas-act', 'cronogramas', cats.cronogramas, "Despliega y selecciona cronograma(s) de actividades...");
        renderMultiSelectComponent('ms-personal_vpro-act', 'personal_vpro', cats.staff_vpro, "Choose options");
        renderMultiSelectComponent('ms-personal_externo-act', 'personal_externo', cats.apoyos_externos, "Choose options");
        renderMultiSelectComponent('ms-vehiculos-act', 'vehiculos', cats.autos, "Choose options");
        renderMultiSelectComponent('ms-proveedores-act', 'proveedores', cats.proveedores, "Choose options");

        actualizarCrewGira();

        // Consultar si tiene jornadas de gira ya registradas
        cargarJornadasGira(data.id_evento);

    } catch (error) {
        console.error("Error al cargar la orden de producción:", error);
        container.innerHTML = `<p style="color: #ef4444; text-align: center; padding: 20px;">Error al obtener los datos del folio seleccionado: ${error.message}</p>`;
    }
}

// -------------------------------------------------------------
// Carga del Detalle para Bóveda Histórica (Solo Lectura)
// -------------------------------------------------------------
async function cargarDetalleOPHistorico(folioId) {
    const container = document.getElementById('formulario-op-historico-container');
    if (!container) return;
    if (!folioId) {
        container.innerHTML = `<p style="color: var(--text-muted); text-align: center; padding: 20px;">Selecciona una orden histórica arriba para visualizar su expediente.</p>`;
        return;
    }

    container.innerHTML = `<p style="color: var(--text-muted); text-align: center; padding: 30px;">Cargando orden histórica ${folioId}...</p>`;

    try {
        const response = await fetch(`${API_URL}/api/eventos/buscar/${encodeURIComponent(folioId)}`);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const data = await response.json();

        window.opMultiSelects = {
            personal_vpro: Array.isArray(data.personal_convocado_op) ? data.personal_convocado_op : [],
            vehiculos: Array.isArray(data.carros_usados_op) ? data.carros_usados_op : [],
            personal_externo: Array.isArray(data.externos_op) ? data.externos_op : [],
            proveedores: Array.isArray(data.proveedor_op) ? data.proveedor_op : [],
            reuniones: Array.isArray(data.reuniones_vinculadas) ? data.reuniones_vinculadas : [],
            cronogramas: Array.isArray(data.cronogramas_vinculados) ? data.cronogramas_vinculados : []
        };
        window.opFotosEvidenciaActuales = Array.isArray(data.fotos_evidencia) ? data.fotos_evidencia : [];

        const cats = window.vproCatalogosOP || {};
        container.innerHTML = generarHtmlFormularioOP(data, true);

        renderMultiSelectComponent('ms-reuniones-hist', 'reuniones', cats.reuniones, "Sin reuniones", true);
        renderMultiSelectComponent('ms-cronogramas-hist', 'cronogramas', cats.cronogramas, "Sin cronogramas", true);
        renderMultiSelectComponent('ms-personal_vpro-hist', 'personal_vpro', cats.staff_vpro, "Sin personal", true);
        renderMultiSelectComponent('ms-personal_externo-hist', 'personal_externo', cats.apoyos_externos, "Sin externos", true);
        renderMultiSelectComponent('ms-vehiculos-hist', 'vehiculos', cats.autos, "Sin vehículos", true);
        renderMultiSelectComponent('ms-proveedores-hist', 'proveedores', cats.proveedores, "Sin proveedores", true);

        actualizarCrewGira();
        cargarJornadasGira(data.id_evento, true);

    } catch (error) {
        console.error("Error al cargar orden histórica:", error);
        container.innerHTML = `<p style="color: #ef4444; text-align: center; padding: 20px;">Error al obtener los datos de la orden histórica: ${error.message}</p>`;
    }
}

// -------------------------------------------------------------
// Habilitar OP del Histórico para Edición / Evidencias
// -------------------------------------------------------------
async function habilitarOPParaEdicion(folio) {
    if (!folio) {
        alert("⚠️ No se ha seleccionado una OP válida.");
        return;
    }
    const rol = (usuarioLogueado?.rol || '').toUpperCase();
    const esPermitido = rol.includes('ADMIN') || rol.includes('COORDINADOR') || rol.includes('COORDINACION') || rol.includes('PRODUCCION');
    if (!esPermitido) {
        alert("⛔ Solo el personal con rol de Coordinador o Administrador puede habilitar OPs del histórico.");
        return;
    }

    const confirmar = confirm(`¿Estás seguro de habilitar la OP "${folio}" para agregar evidencias (fotos/videos) o editar información?\n\nLa orden pasará al Panel de OPs Activas.`);
    if (!confirmar) return;

    try {
        const res = await fetch(`${API_URL}/api/eventos/habilitar-edicion`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                folio: folio,
                usuario: usuarioLogueado?.nombre_completo || "COORDINADOR",
                rol: rol
            })
        });
        const data = await res.json();
        if (res.ok && data.ok) {
            alert(`✅ ${data.mensaje}`);
            // Recargar catálogo de folios
            await inicializarModuloOP();
            // Cambiar a la pestaña de OPs Activas
            cambiarPestanaOP('activas');
            // Seleccionar y cargar la orden habilitada en el panel activo
            const selActivas = document.getElementById('select-folios-op');
            if (selActivas) {
                selActivas.value = folio;
                await cargarDetalleOP(folio);
            }
        } else {
            alert(`❌ Error al habilitar OP: ${data.detail || data.mensaje || 'Error en el servidor'}`);
        }
    } catch (err) {
        console.error("Error al habilitar OP:", err);
        alert(`❌ Error de conexión al habilitar la OP: ${err.message}`);
    }
}

// -------------------------------------------------------------
// Mandar OP al Histórico (Archivar / Modo Solo Lectura)
// -------------------------------------------------------------
async function mandarOPAlHistorial(folio, mostrarConfirmacion = true) {
    if (!folio) {
        alert("⚠️ No se ha especificado el folio de la OP.");
        return;
    }
    const rol = (usuarioLogueado?.rol || '').toUpperCase();
    const esPermitido = rol.includes('ADMIN') || rol.includes('COORDINADOR') || rol.includes('COORDINACION') || rol.includes('PRODUCCION');
    if (!esPermitido) {
        alert("⛔ Solo el personal con rol de Coordinador o Administrador puede archivar OPs en el histórico.");
        return;
    }

    if (mostrarConfirmacion) {
        const confirmar = confirm(`¿Estás seguro de enviar la OP "${folio}" al Archivo Histórico?\n\nLa orden quedará en la Bóveda Histórica en modo de solo lectura.`);
        if (!confirmar) return;
    }

    try {
        const res = await fetch(`${API_URL}/api/eventos/mandar-al-historial`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                folio: folio,
                usuario: usuarioLogueado?.nombre_completo || "COORDINADOR",
                rol: rol
            })
        });
        const data = await res.json();
        if (res.ok && data.ok) {
            alert(`📦 ${data.mensaje}`);
            window.opHabilitadaTemporalmenteFolio = null;
            // Recargar catálogo de folios
            await inicializarModuloOP();
            // Cambiar a la pestaña de Bóveda Histórica
            cambiarPestanaOP('historico');
            const selHist = document.getElementById('select-folios-historicos');
            if (selHist) {
                selHist.value = folio;
                await cargarDetalleOPHistorico(folio);
            }
        } else {
            alert(`❌ Error al archivar OP: ${data.detail || data.mensaje || 'Error en el servidor'}`);
        }
    } catch (err) {
        console.error("Error al archivar OP:", err);
        alert(`❌ Error de conexión al archivar la OP: ${err.message}`);
    }
}


// -------------------------------------------------------------
// Bitácora de Gira y Horas de Locación
// -------------------------------------------------------------
function toggleBitacoraGira() {
    const contenedor = document.getElementById("contenedor-bitacora-gira");
    const switchBg = document.getElementById("toggle-switch-gira");
    const knob = document.getElementById("knob-switch-gira");
    if (!contenedor || !switchBg || !knob) return;

    if (contenedor.style.display === "none") {
        contenedor.style.display = "block";
        switchBg.style.background = "#ef4444";
        knob.style.left = "23px";
        actualizarCrewGira();
    } else {
        contenedor.style.display = "none";
        switchBg.style.background = "#cbd5e1";
        knob.style.left = "3px";
    }
}

async function cargarJornadasGira(idEvento, isReadOnly = false) {
    const contenedor = document.getElementById("contenedor-jornadas-guardadas");
    if (!contenedor || !idEvento) return;

    try {
        const res = await fetch(`${API_URL}/api/asistencia/locacion/${idEvento}`);
        if (!res.ok) return;
        const jornadas = await res.json();

        if (jornadas && jornadas.length > 0) {
            // Activar automáticamente el toggle
            const contenedorGira = document.getElementById("contenedor-bitacora-gira");
            const switchBg = document.getElementById("toggle-switch-gira");
            const knob = document.getElementById("knob-switch-gira");
            if (contenedorGira) contenedorGira.style.display = "block";
            if (switchBg) switchBg.style.background = "#ef4444";
            if (knob) knob.style.left = "23px";

            // Agrupar por fecha_jornada
            const porFecha = {};
            jornadas.forEach(j => {
                const f = j.fecha_jornada;
                if (!porFecha[f]) porFecha[f] = [];
                porFecha[f].push(j);
            });

            const fechasOrdenadas = Object.keys(porFecha).sort();
            contenedor.innerHTML = fechasOrdenadas.map(fecha => {
                const registros = porFecha[fecha];
                const rowsHtml = registros.map(r => `
                    <tr>
                        <td style="font-weight: 600; color: #1e293b;">${r.nombre_empleado}</td>
                        <td><input type="text" class="op-input input-jornada-${fecha}" data-field="hora_entrada" data-emp="${r.nombre_empleado}" value="${(r.hora_entrada || '00:00:00').substring(0, 5)}" style="padding: 6px; width: 70px; text-align: center;" ${isReadOnly ? 'disabled' : ''}></td>
                        <td><input type="number" step="0.5" class="op-input input-jornada-${fecha}" data-field="t_desayuno" data-emp="${r.nombre_empleado}" value="${r.t_desayuno || 0}" style="padding: 6px; width: 60px; text-align: center;" ${isReadOnly ? 'disabled' : ''}></td>
                        <td><input type="number" step="0.5" class="op-input input-jornada-${fecha}" data-field="t_comida" data-emp="${r.nombre_empleado}" value="${r.t_comida || 0}" style="padding: 6px; width: 60px; text-align: center;" ${isReadOnly ? 'disabled' : ''}></td>
                        <td><input type="number" step="0.5" class="op-input input-jornada-${fecha}" data-field="t_cena" data-emp="${r.nombre_empleado}" value="${r.t_cena || 0}" style="padding: 6px; width: 60px; text-align: center;" ${isReadOnly ? 'disabled' : ''}></td>
                        <td><input type="text" class="op-input input-jornada-${fecha}" data-field="hora_salida" data-emp="${r.nombre_empleado}" value="${(r.hora_salida || '00:00:00').substring(0, 5)}" style="padding: 6px; width: 70px; text-align: center;" ${isReadOnly ? 'disabled' : ''}></td>
                        <td><input type="text" class="op-input input-jornada-${fecha}" data-field="observaciones" data-emp="${r.nombre_empleado}" value="${r.observaciones || ''}" style="padding: 6px; width: 100%;" placeholder="Notas..." ${isReadOnly ? 'disabled' : ''}></td>
                    </tr>
                `).join('');

                return `
                    <div style="border: 1px solid #cbd5e1; border-radius: 8px; margin-bottom: 16px; overflow: hidden; background: white;">
                        <div style="background: #f8fafc; padding: 12px 16px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
                            <strong style="color: #1e293b;">🔒 Jornada Registrada: ${fecha}</strong>
                            ${!isReadOnly ? `
                                <button type="button" onclick="guardarJornadaGira(${idEvento}, '${fecha}')" style="background: #10b981; color: white; border: none; padding: 6px 14px; border-radius: 4px; font-weight: 600; font-size: 12.5px; cursor: pointer;">
                                    💾 Guardar Correcciones
                                </button>
                            ` : ''}
                        </div>
                        <div class="tabla-container" style="max-height: 250px;">
                            <table class="tabla-vpro">
                                <thead>
                                    <tr>
                                        <th>Empleado</th>
                                        <th>Entrada</th>
                                        <th>Hrs Desayuno</th>
                                        <th>Hrs Comida</th>
                                        <th>Hrs Cena</th>
                                        <th>Salida</th>
                                        <th>Notas</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    ${rowsHtml}
                                </tbody>
                            </table>
                        </div>
                    </div>
                `;
            }).join('');
        } else {
            contenedor.innerHTML = '';
        }
    } catch (e) {
        console.error("Error al cargar jornadas de gira:", e);
    }
}

async function guardarJornadaGira(idEvento, fecha) {
    const inputs = document.querySelectorAll(`.input-jornada-${fecha}`);
    if (!inputs || inputs.length === 0) return;

    // Agrupar por empleado
    const porEmp = {};
    inputs.forEach(inp => {
        const emp = inp.getAttribute('data-emp');
        const field = inp.getAttribute('data-field');
        if (!porEmp[emp]) {
            porEmp[emp] = {
                fecha_jornada: fecha,
                num_empleado: 0,
                nombre_empleado: emp,
                depto: "STAFF VPRO",
                hora_entrada: "00:00:00",
                t_desayuno: 0.0,
                t_comida: 0.0,
                t_cena: 0.0,
                hora_salida: "00:00:00",
                observaciones: ""
            };
        }
        let val = inp.value.trim();
        if (field === 'hora_entrada' || field === 'hora_salida') {
            if (val && val.length === 5) val = val + ":00";
            if (!val) val = "00:00:00";
            porEmp[emp][field] = val;
        } else if (field.startsWith('t_')) {
            porEmp[emp][field] = parseFloat(val) || 0.0;
        } else {
            porEmp[emp][field] = val;
        }
    });

    const payload = { registros: Object.values(porEmp) };

    try {
        const res = await fetch(`${API_URL}/api/asistencia/locacion/${idEvento}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });
        if (res.ok) {
            alert(`✅ Jornada de fecha ${fecha} actualizada correctamente.`);
            cargarJornadasGira(idEvento);
        } else {
            alert("❌ Error al guardar las correcciones de la jornada.");
        }
    } catch (err) {
        alert(`❌ Error de red: ${err.message}`);
    }
}

async function crearNuevoDiaGira(idEvento) {
    const crew = window.opMultiSelects.personal_vpro || [];
    if (crew.length === 0) {
        alert("⚠️ Atención: Debes seleccionar personal en 'SELECCIONAR PERSONAL VPRO' arriba para poder tomar asistencia.");
        return;
    }

    const inputFecha = document.getElementById("input-nueva-fecha-gira");
    const fechaSeleccionada = inputFecha?.value;
    if (!fechaSeleccionada) {
        alert("Selecciona una fecha válida.");
        return;
    }

    const registrosNuevos = crew.map(persona => ({
        fecha_jornada: String(fechaSeleccionada),
        num_empleado: 0,
        nombre_empleado: String(persona).trim(),
        depto: "STAFF VPRO",
        hora_entrada: "00:00:00",
        t_desayuno: 0.0,
        t_comida: 0.0,
        t_cena: 0.0,
        hora_salida: "00:00:00",
        observaciones: ""
    }));

    try {
        const res = await fetch(`${API_URL}/api/asistencia/locacion/${idEvento}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ registros: registrosNuevos })
        });
        if (res.ok) {
            alert(`✅ ¡Día ${fechaSeleccionada} agregado! Ya puedes asignar las horas.`);
            cargarJornadasGira(idEvento);
        } else {
            alert("❌ Error del servidor al crear la nueva jornada.");
        }
    } catch (e) {
        alert(`❌ Error de conexión: ${e.message}`);
    }
}

// -------------------------------------------------------------
// Guardado Maestro de la Orden de Producción
// -------------------------------------------------------------
async function guardarOrdenOP(event) {
    if (event) event.preventDefault();

    const id_evento = document.getElementById("op_id_evento")?.value;
    const folio = document.getElementById("op_folio")?.value;
    const para_q_cliente = document.getElementById("op_para_q_cliente")?.value;
    const nombre_evento = document.getElementById("op_nombre_evento")?.value;
    const locacion = document.getElementById("op_locacion")?.value;
    const fec_de_instalacion = document.getElementById("op_fec_de_instalacion")?.value;
    const hra_de_instalacion = document.getElementById("op_hra_de_instalacion")?.value;
    const quien_solicita = document.getElementById("op_quien_solicita")?.value;
    const resp_de_produccion = document.getElementById("op_resp_de_produccion")?.value;
    const fec_del_evento = document.getElementById("op_fec_del_evento")?.value;
    const inicio_del_evento = document.getElementById("op_inicio_del_evento")?.value;
    const hra_de_llamado = document.getElementById("op_hra_de_llamado")?.value;
    const ubicacion = document.getElementById("op_ubicacion")?.value;
    const tipo_de_servicio = document.getElementById("op_tipo_de_servicio")?.value;
    const produccion = document.getElementById("op_produccion")?.value;
    const internet_redes = document.getElementById("op_internet_redes")?.value;
    const actividades_de_proveedores = document.getElementById("op_actividades_de_proveedores")?.value;
    const nota = document.getElementById("op_nota")?.value;
    const elabora = document.getElementById("op_elabora")?.value;
    const coordina = document.getElementById("op_coordina")?.value;
    const organiza = document.getElementById("op_organiza")?.value;
    const vobo = document.getElementById("op_vobo")?.value;

    const payload = {
        id_evento: parseInt(id_evento) || 0,
        folio: folio || String(id_evento),
        para_q_cliente: para_q_cliente || "",
        nombre_evento: nombre_evento || "",
        locacion: locacion || "",
        fec_de_instalacion: fec_de_instalacion || null,
        hra_de_instalacion: hra_de_instalacion ? (hra_de_instalacion.length === 5 ? hra_de_instalacion + ":00" : hra_de_instalacion) : null,
        quien_solicita: quien_solicita || "",
        resp_de_produccion: resp_de_produccion || "",
        fec_del_evento: fec_del_evento || null,
        inicio_del_evento: inicio_del_evento ? (inicio_del_evento.length === 5 ? inicio_del_evento + ":00" : inicio_del_evento) : null,
        hra_de_llamado: hra_de_llamado ? (hra_de_llamado.length === 5 ? hra_de_llamado + ":00" : hra_de_llamado) : null,
        ubicacion: ubicacion || "",
        tipo_de_servicio: tipo_de_servicio || "",
        produccion: produccion || "",
        internet_redes: internet_redes || "",
        actividades_de_proveedores: actividades_de_proveedores || "",
        nota: nota || "",
        elabora: elabora || "",
        coordina: coordina || "",
        organiza: organiza || "",
        vobo: vobo || "",
        personal_convocado_op: window.opMultiSelects.personal_vpro || [],
        carros_usados_op: window.opMultiSelects.vehiculos || [],
        externos_op: window.opMultiSelects.personal_externo || [],
        proveedor_op: window.opMultiSelects.proveedores || [],
        reuniones_vinculadas: window.opMultiSelects.reuniones || [],
        cronogramas_vinculados: window.opMultiSelects.cronogramas || [],
        fotos_evidencia: window.opFotosEvidenciaActuales || [],
        empleado_que_creo_la_op: usuarioLogueado ? usuarioLogueado.nombre_completo : ""
    };

    try {
        const respuesta = await fetch(`${API_URL}/api/eventos/guardar`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        const resultado = await respuesta.json();

        if (respuesta.ok && resultado.status === "SUCCESS") {
            alert(`✅ ¡Orden de Producción "${folio || nombre_evento}" guardada exitosamente!`);

            // Si la OP fue habilitada temporalmente desde el histórico, sugerir regresarla al archivo histórico
            if (window.opHabilitadaTemporalmenteFolio && window.opHabilitadaTemporalmenteFolio === folio) {
                const regresar = confirm(`¿Deseas mandar la OP "${folio}" de nuevo al Archivo Histórico ahora que guardaste los cambios/evidencias?`);
                if (regresar) {
                    await mandarOPAlHistorial(folio, false);
                    return;
                }
            }

            // Recargar folios y seleccionar el folio guardado
            await inicializarModuloOP();
            const selectFolios = document.getElementById('select-folios-op');
            if (selectFolios) {
                selectFolios.value = folio;
                cargarDetalleOP(folio);
            }
        } else {
            alert(`❌ Error al guardar: ${resultado.detail || 'Ocurrió un error en el servidor.'}`);
        }
    } catch (err) {
        console.error("Error al guardar la orden:", err);
        alert(`❌ Error de conexión al guardar la orden: ${err.message}`);
    }
}

// ==========================================
// 7. MÓDULO EQUIPOS DAÑADOS
// ==========================================
let datosRadarDanosCache = [];
let datosDanosFiltrados = [];
let chartDanadosInstance = null;

// ==============================================================================
// BUSCADOR EN VIVO DE EQUIPOS PARA EXPEDIENTE CLÍNICO Y REPORTES DE DAÑOS
// ==============================================================================
let catalogoGlobalEquipos = [];
let indiceFocoSugerenciaExpediente = -1;
let indiceFocoSugerenciaDirecto = -1;

function normalizarTextoBusqueda(str) {
    return (str || "")
        .toString()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .toLowerCase()
        .trim();
}

function resaltarTexto(texto, query) {
    if (!query || !texto) return texto || "";
    const cleanQuery = normalizarTextoBusqueda(query);
    if (!cleanQuery) return texto;
    const re = new RegExp(`(${cleanQuery.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
    return String(texto).replace(re, '<mark style="background: #fef08a; color: #854d0e; padding: 0 2px; border-radius: 2px;">$1</mark>');
}

// --- Autocomplete Expediente Clínico ---
function activarSugerenciasExpediente() {
    const input = document.getElementById("input-expediente-buscar");
    filtrarSugerenciasExpediente(input ? input.value : "");
}

function filtrarSugerenciasExpediente(termino) {
    const dropdown = document.getElementById("sugerencias-expediente-dropdown");
    const btnLimpiar = document.getElementById("btn-limpiar-busqueda-expediente");
    if (!dropdown) return;

    if (btnLimpiar) {
        btnLimpiar.style.display = (termino && termino.trim()) ? "block" : "none";
    }

    const t = normalizarTextoBusqueda(termino);
    indiceFocoSugerenciaExpediente = -1;

    let coincidencias = [];
    if (!t) {
        coincidencias = catalogoGlobalEquipos.slice(0, 30);
    } else {
        const palabras = t.split(" ").filter(Boolean);
        coincidencias = catalogoGlobalEquipos.filter(item => {
            const norm = normalizarTextoBusqueda(item);
            return palabras.every(pal => norm.includes(pal));
        }).slice(0, 50);
    }

    if (coincidencias.length === 0) {
        dropdown.innerHTML = `
            <div style="padding: 16px; text-align: center; color: #64748b; font-size: 13px;">
                <i class="ph ph-warning-circle" style="font-size: 20px; color: #f59e0b; display: block; margin-bottom: 4px;"></i>
                No se encontraron equipos con el término: "<b>${termino}</b>"<br>
                <span style="font-size: 11.5px; color: #94a3b8;">Intenta con otra palabra clave (marca, nombre o código).</span>
            </div>
        `;
        dropdown.style.display = "block";
        return;
    }

    dropdown.innerHTML = `
        <div style="padding: 8px 12px; background: #f8fafc; border-bottom: 1px solid #e2e8f0; font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; display: flex; justify-content: space-between;">
            <span>Coincidencias encontradas (${coincidencias.length}${coincidencias.length === 50 ? '+' : ''}):</span>
            <span style="font-size: 10.5px; text-transform: none; color: #94a3b8;">Usa ↑ ↓ y Enter o haz clic</span>
        </div>
        ` + coincidencias.map((item, idx) => {
            const partes = item.split(" - ");
            const codigo = partes[0].trim();
            const nombre = partes.slice(1).join(" - ").trim() || codigo;
            return `
                <div class="sugerencia-item-exp" data-idx="${idx}" onclick="seleccionarEquipoExpediente('${codigo.replace(/'/g, "\\'")}', '${item.replace(/'/g, "\\'")}')" 
                     style="padding: 10px 14px; cursor: pointer; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center; transition: background 0.15s;"
                     onmouseover="this.style.background='#eff6ff'" onmouseout="this.style.background='white'">
                    <div style="flex: 1; padding-right: 12px;">
                        <div style="font-weight: 600; color: #0f172a; font-size: 13.5px; line-height: 1.3;">
                            ${resaltarTexto(nombre, termino)}
                        </div>
                        <div style="font-size: 11.5px; color: #64748b; margin-top: 3px; display: flex; align-items: center; gap: 6px;">
                            <span style="background: #e2e8f0; color: #334155; padding: 2px 7px; border-radius: 4px; font-family: monospace; font-weight: 700; font-size: 11px;">
                                ${resaltarTexto(codigo, termino)}
                            </span>
                        </div>
                    </div>
                    <i class="ph ph-arrow-circle-right" style="color: var(--accent-color); font-size: 18px; flex-shrink: 0;"></i>
                </div>
            `;
        }).join("");

    dropdown.style.display = "block";
}

function ocultarSugerenciasExpediente() {
    const dropdown = document.getElementById("sugerencias-expediente-dropdown");
    if (dropdown) dropdown.style.display = "none";
}

function seleccionarEquipoExpediente(codigo, itemCompleto) {
    const input = document.getElementById("input-expediente-buscar");
    const hidden = document.getElementById("sel-expediente-equipo-buscar");
    if (input) input.value = itemCompleto;
    if (hidden) hidden.value = codigo;
    ocultarSugerenciasExpediente();
    buscarExpedienteDanado();
}

function limpiarBusquedaExpediente() {
    const input = document.getElementById("input-expediente-buscar");
    const hidden = document.getElementById("sel-expediente-equipo-buscar");
    const btnLimpiar = document.getElementById("btn-limpiar-busqueda-expediente");
    if (input) {
        input.value = "";
        input.focus();
    }
    if (hidden) hidden.value = "";
    if (btnLimpiar) btnLimpiar.style.display = "none";
    filtrarSugerenciasExpediente("");
}

function manejarKeydownSugerenciasExpediente(e) {
    const dropdown = document.getElementById("sugerencias-expediente-dropdown");
    if (!dropdown || dropdown.style.display === "none") {
        if (e.key === "Enter") {
            e.preventDefault();
            buscarExpedienteDanado();
        }
        return;
    }

    const items = dropdown.querySelectorAll(".sugerencia-item-exp");
    if (items.length === 0) return;

    if (e.key === "ArrowDown") {
        e.preventDefault();
        indiceFocoSugerenciaExpediente = (indiceFocoSugerenciaExpediente + 1) % items.length;
        items.forEach((it, i) => it.style.background = i === indiceFocoSugerenciaExpediente ? "#eff6ff" : "white");
        items[indiceFocoSugerenciaExpediente].scrollIntoView({ block: "nearest" });
    } else if (e.key === "ArrowUp") {
        e.preventDefault();
        indiceFocoSugerenciaExpediente = (indiceFocoSugerenciaExpediente - 1 + items.length) % items.length;
        items.forEach((it, i) => it.style.background = i === indiceFocoSugerenciaExpediente ? "#eff6ff" : "white");
        items[indiceFocoSugerenciaExpediente].scrollIntoView({ block: "nearest" });
    } else if (e.key === "Enter") {
        e.preventDefault();
        if (indiceFocoSugerenciaExpediente >= 0 && indiceFocoSugerenciaExpediente < items.length) {
            items[indiceFocoSugerenciaExpediente].click();
        } else {
            buscarExpedienteDanado();
        }
    } else if (e.key === "Escape") {
        ocultarSugerenciasExpediente();
    }
}

// --- Autocomplete Reporte Directo ---
function activarSugerenciasDirecto() {
    const input = document.getElementById("input-danos-equipo-directo");
    filtrarSugerenciasDirecto(input ? input.value : "");
}

function filtrarSugerenciasDirecto(termino) {
    const dropdown = document.getElementById("sugerencias-directo-dropdown");
    const btnLimpiar = document.getElementById("btn-limpiar-busqueda-directo");
    if (!dropdown) return;

    if (btnLimpiar) {
        btnLimpiar.style.display = (termino && termino.trim()) ? "block" : "none";
    }

    const t = normalizarTextoBusqueda(termino);
    let coincidencias = [];
    if (!t) {
        coincidencias = catalogoGlobalEquipos.slice(0, 30);
    } else {
        const palabras = t.split(" ").filter(Boolean);
        coincidencias = catalogoGlobalEquipos.filter(item => {
            const norm = normalizarTextoBusqueda(item);
            return palabras.every(pal => norm.includes(pal));
        }).slice(0, 50);
    }

    if (coincidencias.length === 0) {
        dropdown.innerHTML = `<div style="padding: 12px; text-align: center; color: #64748b; font-size: 12.5px;">No se encontraron equipos</div>`;
        dropdown.style.display = "block";
        return;
    }

    dropdown.innerHTML = coincidencias.map((item, idx) => {
        const partes = item.split(" - ");
        const codigo = partes[0].trim();
        const nombre = partes.slice(1).join(" - ").trim() || codigo;
        return `
            <div onclick="seleccionarEquipoDirecto('${codigo.replace(/'/g, "\\'")}', '${item.replace(/'/g, "\\'")}')" 
                 style="padding: 9px 12px; cursor: pointer; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center; font-size: 13px;"
                 onmouseover="this.style.background='#eff6ff'" onmouseout="this.style.background='white'">
                <div>
                    <b>${nombre}</b>
                    <div style="font-size: 11px; color: #64748b; font-family: monospace;">${codigo}</div>
                </div>
            </div>
        `;
    }).join("");

    dropdown.style.display = "block";
}

function ocultarSugerenciasDirecto() {
    const dropdown = document.getElementById("sugerencias-directo-dropdown");
    if (dropdown) dropdown.style.display = "none";
}

function seleccionarEquipoDirecto(codigo, itemCompleto) {
    const input = document.getElementById("input-danos-equipo-directo");
    const hidden = document.getElementById("danos-sel-equipo-directo");
    if (input) input.value = itemCompleto;
    if (hidden) hidden.value = codigo;
    ocultarSugerenciasDirecto();
}

function limpiarBusquedaDirecto() {
    const input = document.getElementById("input-danos-equipo-directo");
    const hidden = document.getElementById("danos-sel-equipo-directo");
    const btnLimpiar = document.getElementById("btn-limpiar-busqueda-directo");
    if (input) {
        input.value = "";
        input.focus();
    }
    if (hidden) hidden.value = "";
    if (btnLimpiar) btnLimpiar.style.display = "none";
    filtrarSugerenciasDirecto("");
}

function manejarKeydownSugerenciasDirecto(e) {
    if (e.key === "Escape") ocultarSugerenciasDirecto();
}

// Cierre automático al hacer clic fuera
document.addEventListener("click", function(e) {
    const contExp = document.getElementById("contenedor-input-expediente");
    const dropExp = document.getElementById("sugerencias-expediente-dropdown");
    if (dropExp && contExp && !contExp.contains(e.target) && !dropExp.contains(e.target)) {
        dropExp.style.display = "none";
    }

    const contDir = document.getElementById("contenedor-input-directo");
    const dropDir = document.getElementById("sugerencias-directo-dropdown");
    if (dropDir && contDir && !contDir.contains(e.target) && !dropDir.contains(e.target)) {
        dropDir.style.display = "none";
    }

    const contInv = document.getElementById("contenedor-busqueda-inv-editor");
    const dropInv = document.getElementById("sugerencias-inv-editor-dropdown");
    if (dropInv && contInv && !contInv.contains(e.target) && !dropInv.contains(e.target)) {
        dropInv.style.display = "none";
    }
});

function cambiarPestanaDanados(tab) {
    const btnRadar = document.getElementById("tab-danados-btn-radar");
    const btnExpediente = document.getElementById("tab-danados-btn-expediente");
    const viewRadar = document.getElementById("subvista-danados-radar");
    const viewExpediente = document.getElementById("subvista-danados-expediente");

    if (tab === 'radar') {
        if (btnRadar) { btnRadar.style.background = '#0f172a'; btnRadar.style.color = 'white'; btnRadar.style.border = 'none'; }
        if (btnExpediente) { btnExpediente.style.background = '#f1f5f9'; btnExpediente.style.color = '#475569'; btnExpediente.style.border = '1px solid #cbd5e1'; }
        if (viewRadar) viewRadar.style.display = 'block';
        if (viewExpediente) viewExpediente.style.display = 'none';
    } else {
        if (btnExpediente) { btnExpediente.style.background = '#0f172a'; btnExpediente.style.color = 'white'; btnExpediente.style.border = 'none'; }
        if (btnRadar) { btnRadar.style.background = '#f1f5f9'; btnRadar.style.color = '#475569'; btnRadar.style.border = '1px solid #cbd5e1'; }
        if (viewRadar) viewRadar.style.display = 'none';
        if (viewExpediente) viewExpediente.style.display = 'block';
        setTimeout(() => document.getElementById("input-expediente-buscar")?.focus(), 100);
    }
}

async function cargarModuloDanados() {
    try {
        // Cargar catálogo global para los selectores si no se ha cargado
        const [resCat, resRadar] = await Promise.all([
            fetch(`${API_URL}/api/inventario/catalogo-global`),
            fetch(`${API_URL}/api/inventario/radar-danos`)
        ]);

        if (resCat.ok) {
            const catalogo = await resCat.json();
            catalogoGlobalEquipos = catalogo || [];
            const selDirecto = document.getElementById("danos-sel-equipo-directo");
            const selExpediente = document.getElementById("sel-expediente-equipo-buscar");

            if (selDirecto && selDirecto.tagName === 'SELECT' && selDirecto.children.length <= 1) {
                selDirecto.innerHTML = '<option value="">--- Seleccionar Activo ---</option>' +
                    catalogo.map(c => `<option value="${c}">${c}</option>`).join("");
            }
            if (selExpediente && selExpediente.tagName === 'SELECT' && selExpediente.children.length <= 1) {
                selExpediente.innerHTML = '<option value="">--- Selecciona o escribe el equipo a auditar ---</option>' +
                    catalogo.map(c => `<option value="${c}">${c}</option>`).join("");
            }
        }

        if (resRadar.ok) {
            datosRadarDanosCache = await resRadar.json();
            const badgeDanados = document.getElementById("badge-danados");
            if (badgeDanados) badgeDanados.innerText = datosRadarDanosCache.length || 0;

            // Poblar dropdown de reportantes
            const selReportante = document.getElementById("filtro-danos-reportante");
            if (selReportante) {
                const reportantes = [...new Set(datosRadarDanosCache.map(d => d["REPORTÓ"] || d["REPORTÓ_RAW"]).filter(Boolean))].sort();
                selReportante.innerHTML = '<option value="Todos">Todos</option>' +
                    reportantes.map(r => `<option value="${r}">${r}</option>`).join("");
            }

            // Poblar dropdown de tickets para resolver
            const selTicketResolver = document.getElementById("sel-ticket-danado-cerrar");
            if (selTicketResolver) {
                selTicketResolver.innerHTML = '<option value="">--- Seleccionar Ticket ---</option>' +
                    datosRadarDanosCache.map(d => `<option value="${d.NUM_SERVICIO}">#${d.NUM_SERVICIO} - ${d.EQUIPO} (${d.ESTADO})</option>`).join("");
            }

            aplicarFiltrosDanados();
        }
    } catch (err) {
        console.error("Error al cargar radar de daños:", err);
    }
}

function cargarEquiposDanados() {
    cargarModuloDanados();
}

function aplicarFiltrosDanados() {
    const fDesde = document.getElementById("filtro-danos-desde")?.value;
    const fHasta = document.getElementById("filtro-danos-hasta")?.value;
    const fDepto = document.getElementById("filtro-danos-depto")?.value || "Todos";
    const fReportante = document.getElementById("filtro-danos-reportante")?.value || "Todos";

    const hoy = new Date();

    datosDanosFiltrados = datosRadarDanosCache.filter(item => {
        const fRepStr = item.FECHA_REPORTE ? String(item.FECHA_REPORTE).substring(0, 10) : "";
        if (fDesde && fRepStr && fRepStr < fDesde) return false;
        if (fHasta && fRepStr && fRepStr > fHasta) return false;

        if (fDepto !== "Todos") {
            const dItem = String(item.DEPARTAMENTO || "").toUpperCase();
            if (dItem !== fDepto.toUpperCase()) return false;
        }

        if (fReportante !== "Todos") {
            const repItem = String(item["REPORTÓ"] || item["REPORTÓ_RAW"] || "").trim();
            if (repItem !== fReportante.trim()) return false;
        }

        return true;
    });

    // Calcular días fuera para cada registro
    datosDanosFiltrados.forEach(item => {
        if (item.FECHA_REPORTE) {
            const fItem = new Date(item.FECHA_REPORTE);
            const diffTime = Math.abs(hoy - fItem);
            item.DIAS_FUERA = Math.floor(diffTime / (1000 * 60 * 60 * 24));
        } else {
            item.DIAS_FUERA = 0;
        }
    });

    // 4 KPIs
    const elKpiTotal = document.getElementById("kpi-danados-total");
    const elKpiDias = document.getElementById("kpi-danados-dias");
    const elKpiTopRep = document.getElementById("kpi-danados-top-rep");
    const elKpiTopArea = document.getElementById("kpi-danados-top-area");

    if (elKpiTotal) elKpiTotal.innerText = datosDanosFiltrados.length;

    const promDias = datosDanosFiltrados.length > 0 
        ? Math.round(datosDanosFiltrados.reduce((acc, i) => acc + (i.DIAS_FUERA || 0), 0) / datosDanosFiltrados.length)
        : 0;
    if (elKpiDias) elKpiDias.innerText = `${promDias} Días`;

    // Conteo por reportante
    const conteoRep = {};
    const conteoDepto = {};
    datosDanosFiltrados.forEach(i => {
        const r = i["REPORTÓ"] || i["REPORTÓ_RAW"] || "Sin asignar";
        conteoRep[r] = (conteoRep[r] || 0) + 1;
        const d = i.DEPARTAMENTO || "General";
        conteoDepto[d] = (conteoDepto[d] || 0) + 1;
    });

    const topRep = Object.keys(conteoRep).sort((a,b) => conteoRep[b] - conteoRep[a])[0] || "--";
    const topDepto = Object.keys(conteoDepto).sort((a,b) => conteoDepto[b] - conteoDepto[a])[0] || "--";

    if (elKpiTopRep) elKpiTopRep.innerText = topRep;
    if (elKpiTopArea) elKpiTopArea.innerText = topDepto;

    // Actualizar gráfica Chart.js
    renderizarGraficaDanadosPersonal(conteoRep);

    // Renderizar tabla
    renderizarTablaDanados(datosDanosFiltrados);
}

function renderizarGraficaDanadosPersonal(conteoRep) {
    const canvas = document.getElementById("chart-danados-personal");
    if (!canvas || typeof Chart === 'undefined') return;

    if (chartDanadosInstance) {
        chartDanadosInstance.destroy();
        chartDanadosInstance = null;
    }

    const labels = Object.keys(conteoRep).slice(0, 10);
    const data = labels.map(l => conteoRep[l]);

    chartDanadosInstance = new Chart(canvas, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Tickets Activos',
                data: data,
                backgroundColor: 'rgba(239, 68, 68, 0.85)',
                borderColor: '#dc2626',
                borderWidth: 1.5,
                borderRadius: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: ctx => ` ${ctx.raw} ticket(s) activo(s)`
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { stepSize: 1 }
                },
                x: {
                    ticks: { maxRotation: 35, minRotation: 0 }
                }
            }
        }
    });
}

function renderizarTablaDanados(lista) {
    const tbody = document.getElementById("tabla-danados-body");
    if (!tbody) return;

    if (lista.length === 0) {
        tbody.innerHTML = `<tr><td colspan="10" style="text-align: center; padding: 24px; color: #166534; font-weight: 500;">✅ No hay equipos con daño bajo estos criterios de búsqueda.</td></tr>`;
        return;
    }

    tbody.innerHTML = lista.map(eq => {
        const estado = (eq.ESTADO || 'EN REVISIÓN').toUpperCase();
        let badgeStyle = "background: #fef3c7; color: #92400e;";
        if (estado.includes('TALLER') || estado.includes('GRAVE') || estado.includes('DAÑ')) badgeStyle = "background: #fee2e2; color: #991b1b;";
        else if (estado.includes('PIEZA') || estado.includes('ESPERA')) badgeStyle = "background: #e0e7ff; color: #3730a3;";
        else if (estado.includes('REPARADO') || estado.includes('RESUELTO')) badgeStyle = "background: #dcfce7; color: #166534;";

        return `
            <tr>
                <td style="font-weight: 700; color: #0f172a;">#${eq.NUM_SERVICIO || '--'}</td>
                <td>${eq.FECHA_REPORTE ? String(eq.FECHA_REPORTE).substring(0, 10) : '--'}</td>
                <td><span style="background: #f1f5f9; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 11px;">${eq.DIAS_FUERA || 0} d</span></td>
                <td><code>${eq.ID || '--'}</code></td>
                <td style="font-weight: 600; color: #0f172a;">${eq.EQUIPO || '--'}</td>
                <td>${eq.DEPARTAMENTO || '--'}</td>
                <td>${eq["REPORTÓ"] || eq["REPORTÓ_RAW"] || '--'}</td>
                <td><span style="display: inline-block; padding: 3px 8px; border-radius: 6px; font-size: 11px; font-weight: 700; ${badgeStyle}">${estado}</span></td>
                <td style="max-width: 240px; font-size: 12px; line-height: 1.4;">${eq.FALLA || '--'}</td>
                <td style="font-weight: 700; color: #0f172a;">$${Number(eq.COSTO || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</td>
            </tr>
        `;
    }).join("");
}

function filtrarTablaDanadosEnVivo(termino) {
    const t = (termino || "").toLowerCase().trim();
    if (!t) {
        renderizarTablaDanados(datosDanosFiltrados);
        return;
    }
    const filtrados = datosDanosFiltrados.filter(eq =>
        (eq.EQUIPO && eq.EQUIPO.toLowerCase().includes(t)) ||
        (eq.ID && eq.ID.toLowerCase().includes(t)) ||
        (eq.DEPARTAMENTO && eq.DEPARTAMENTO.toLowerCase().includes(t)) ||
        (eq["REPORTÓ"] && eq["REPORTÓ"].toLowerCase().includes(t)) ||
        (eq.FALLA && eq.FALLA.toLowerCase().includes(t)) ||
        (eq.ESTADO && eq.ESTADO.toLowerCase().includes(t)) ||
        String(eq.NUM_SERVICIO).includes(t)
    );
    renderizarTablaDanados(filtrados);
}

function resetearFiltrosDanados() {
    const fDesde = document.getElementById("filtro-danos-desde");
    const fHasta = document.getElementById("filtro-danos-hasta");
    const fDepto = document.getElementById("filtro-danos-depto");
    const fReportante = document.getElementById("filtro-danos-reportante");
    const fBuscar = document.getElementById("buscar-danados-tabla");

    if (fDesde) fDesde.value = "";
    if (fHasta) fHasta.value = "";
    if (fDepto) fDepto.value = "Todos";
    if (fReportante) fReportante.value = "Todos";
    if (fBuscar) fBuscar.value = "";

    aplicarFiltrosDanados();
}

async function guardarReporteDirectoDanado() {
    const selEq = document.getElementById("danos-sel-equipo-directo")?.value;
    const tipoEvento = document.getElementById("danos-tipo-evento")?.value;
    const estInicial = document.getElementById("danos-estado-inicial")?.value;
    const costo = parseFloat(document.getElementById("danos-costo-estimado")?.value || 0);
    const detalle = document.getElementById("danos-txt-detalle")?.value.trim();
    const fotoFile = document.getElementById("danos-input-foto")?.files?.[0];

    if (!selEq || !detalle) {
        alert("⚠️ Por favor selecciona un equipo y escribe el diagnóstico o detalle del daño.");
        return;
    }

    const codPuro = selEq.includes(" - ") ? selEq.split(" - ")[0].trim() : selEq.trim();
    const userId = usuarioLogueado?.id_empleado ? String(usuarioLogueado.id_empleado) : "000";
    const userDepto = usuarioLogueado?.depto ? String(usuarioLogueado.depto).toUpperCase() : "OFICINA";

    const payload = {
        codigo_equipo: codPuro,
        folio_vpro: "MANTENIMIENTO_INTERNO",
        id_empleado: userId,
        tipo_evento: tipoEvento,
        descripcion: detalle,
        costo_asociado: costo,
        estado_final: estInicial,
        departamento: userDepto
    };

    try {
        const res = await fetch(`${API_URL}/api/inventario/historial/guardar`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (!res.ok) {
            const err = await res.text();
            throw new Error(err);
        }

        if (fotoFile) {
            const fd = new FormData();
            fd.append("file", fotoFile);
            fd.append("codigo_equipo", codPuro);
            fd.append("folio_vpro", "MANTENIMIENTO_INTERNO");
            await fetch(`${API_URL}/api/inventario/subir-evidencia`, {
                method: "POST",
                body: fd
            });
        }

        alert("✅ ¡Ticket de falla registrado con éxito en base de datos!");
        document.getElementById("danos-txt-detalle").value = "";
        document.getElementById("danos-costo-estimado").value = "0.00";
        if (document.getElementById("danos-input-foto")) document.getElementById("danos-input-foto").value = "";
        cargarModuloDanados();
    } catch (e) {
        console.error("Error al guardar ticket directo:", e);
        alert(`❌ Error al registrar ticket: ${e.message}`);
    }
}

async function cerrarTicketDanado() {
    const selTicket = document.getElementById("sel-ticket-danado-cerrar")?.value;
    const nuevoEstado = document.getElementById("sel-estado-danado-cerrar")?.value;

    if (!selTicket) {
        alert("⚠️ Por favor selecciona el ticket que deseas resolver.");
        return;
    }

    if (!confirm(`¿Confirmas rehabilitar el equipo y marcar el ticket #${selTicket} como ${nuevoEstado}?`)) {
        return;
    }

    try {
        const res = await fetch(`${API_URL}/api/inventario/reparacion/cerrar/${selTicket}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ estado_actual: nuevoEstado })
        });

        if (res.ok) {
            alert(`✅ Ticket #${selTicket} cerrado con estado: ${nuevoEstado}. Equipo rehabilitado.`);
            cargarModuloDanados();
        } else {
            const err = await res.text();
            alert(`❌ Error al cerrar ticket: ${err}`);
        }
    } catch (e) {
        alert(`❌ Error de comunicación: ${e.message}`);
    }
}

async function buscarExpedienteDanado() {
    ocultarSugerenciasExpediente();
    let sel = document.getElementById("sel-expediente-equipo-buscar")?.value;
    const inputVal = document.getElementById("input-expediente-buscar")?.value?.trim() || "";

    let textoNombreMostrar = "";

    // Si el usuario escribió directamente en el buscador o no hay selección previa
    if (inputVal) {
        if (inputVal.includes(" - ")) {
            const p = inputVal.split(" - ");
            sel = p[0].trim();
            textoNombreMostrar = inputVal;
        } else {
            // Buscar coincidencia en el catálogo
            const norm = normalizarTextoBusqueda(inputVal);
            const matchExacto = catalogoGlobalEquipos.find(c => {
                const p = c.split(" - ");
                const cod = normalizarTextoBusqueda(p[0]);
                const nom = normalizarTextoBusqueda(p.slice(1).join(" - "));
                return cod === norm || nom === norm;
            });

            if (matchExacto) {
                sel = matchExacto.split(" - ")[0].trim();
                textoNombreMostrar = matchExacto;
                const inputEl = document.getElementById("input-expediente-buscar");
                if (inputEl) inputEl.value = matchExacto;
            } else {
                // Coincidencia parcial por palabras
                const palabras = norm.split(" ").filter(Boolean);
                const matchParcial = catalogoGlobalEquipos.find(c => {
                    const cNorm = normalizarTextoBusqueda(c);
                    return palabras.every(pal => cNorm.includes(pal));
                });
                if (matchParcial) {
                    sel = matchParcial.split(" - ")[0].trim();
                    textoNombreMostrar = matchParcial;
                    const inputEl = document.getElementById("input-expediente-buscar");
                    if (inputEl) inputEl.value = matchParcial;
                } else {
                    sel = inputVal;
                    textoNombreMostrar = inputVal;
                }
            }
        }
    }

    if (!sel) {
        alert("⚠️ Por favor teclea el nombre, descripción o código del equipo a auditar.");
        document.getElementById("input-expediente-buscar")?.focus();
        return;
    }

    const codPuro = sel.includes(" - ") ? sel.split(" - ")[0].trim() : sel.trim();
    const hidden = document.getElementById("sel-expediente-equipo-buscar");
    if (hidden) hidden.value = codPuro;

    const resultadoDiv = document.getElementById("danos-expediente-resultado");
    const codTitulo = document.getElementById("expediente-codigo-titulo");
    const nomEquipo = document.getElementById("expediente-nombre-equipo");
    const estBadge = document.getElementById("expediente-estatus-badge");
    const totMovs = document.getElementById("expediente-total-movs");
    const fotoImg = document.getElementById("expediente-foto-img");
    const sinFoto = document.getElementById("expediente-sin-foto");
    const tbody = document.getElementById("tabla-expediente-historial-body");

    try {
        const res = await fetch(`${API_URL}/api/inventario/expediente/${encodeURIComponent(codPuro)}`);
        if (!res.ok) throw new Error("Expediente no encontrado");

        const data = await res.json();
        const historial = data.historial || [];

        resultadoDiv.style.display = "block";
        codTitulo.innerText = `📁 Expediente Clínico: ${codPuro}`;
        nomEquipo.innerText = textoNombreMostrar || sel;
        totMovs.innerText = historial.length;

        const ultimoEst = historial.length > 0 ? (historial[0]["ESTADO POSTERIOR"] || "DESCONOCIDO") : "BUEN ESTADO";
        estBadge.innerText = ultimoEst;

        // Foto de evidencia
        if (historial.length > 0) {
            const folioRef = String(historial[0]["FOLIO OP / REF"] || "MANTENIMIENTO_INTERNO").replace(/[/\\ ]/g, "_").toUpperCase();
            const codSafe = codPuro.replace(/[/\\ ]/g, "_").toUpperCase();
            const nombreFoto = `Evidencia_${folioRef}_${codSafe}.jpg`;
            const urlFoto = `${API_URL}/evidencias_web/${nombreFoto}`;

            fotoImg.onload = () => {
                fotoImg.style.display = "block";
                sinFoto.style.display = "none";
            };
            fotoImg.onerror = () => {
                fotoImg.style.display = "none";
                sinFoto.style.display = "block";
                sinFoto.innerText = "Sin foto de evidencia";
            };
            fotoImg.src = urlFoto;
        } else {
            fotoImg.style.display = "none";
            sinFoto.style.display = "block";
            sinFoto.innerText = "Sin movimientos registrados";
        }

        // Renderizar tabla del historial
        if (historial.length === 0) {
            tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; padding: 20px; color: var(--text-muted);">No hay historial de movimientos para este activo.</td></tr>`;
        } else {
            tbody.innerHTML = historial.map(h => `
                <tr>
                    <td>${h["FECHA"] ? String(h["FECHA"]).substring(0, 10) : '--'}</td>
                    <td><b>${h["FOLIO OP / REF"] || '--'}</b></td>
                    <td>${h["EMPLEADO"] || '--'}</td>
                    <td><span style="background: #eff6ff; color: #1e40af; font-size: 11px; padding: 2px 8px; border-radius: 4px; font-weight: 600;">${h["TIPO EVENTO"] || '--'}</span></td>
                    <td style="max-width: 250px; font-size: 12.5px;">${h["DETALLE"] || '--'}</td>
                    <td style="font-weight: 600;">$${Number(h["COSTO"] || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</td>
                    <td><span style="font-weight: 700; font-size: 11.5px;">${h["ESTADO POSTERIOR"] || '--'}</span></td>
                </tr>
            `).join("");
        }
    } catch (e) {
        alert(`❌ Error al consultar expediente: ${e.message}`);
    }
}

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
        const elEmpRinde = document.getElementById("gastos-input-empleado");
        const elDepto = document.getElementById("gastos-input-depto");
        const elDesde = document.getElementById("gastos-input-desde");
        const elHasta = document.getElementById("gastos-input-hasta");

        if (elFolio) elFolio.innerText = `OP-${folioId}`;
        if (elCliente) elCliente.innerText = evData.cliente || "--";
        if (elEvento) elEvento.innerText = evData.nombre_evento || "--";
        if (elProductor) elProductor.innerText = evData.productor_responsable || "No asignado";
        if (elEmpRinde) elEmpRinde.value = evData.productor_responsable || usuarioLogueado?.nombre_completo || "Productor VPRO";
        if (elDepto) elDepto.value = usuarioLogueado?.depto || "PRODUCCION";

        const hoy = new Date().toISOString().substring(0, 10);
        const fInst = evData.fec_de_instalacion ? String(evData.fec_de_instalacion).substring(0, 10) : hoy;
        if (elDesde) elDesde.value = fInst;
        if (elHasta) elHasta.value = hoy;

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
    const folioId = eventoSeleccionadoGasto?.id_evento;
    if (!folioId) {
        alert("⚠️ No hay un evento seleccionado.");
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

// ==========================================
// 10. MANUAL / AYUDA MODAL
// ==========================================
function abrirManual() {
    const modal = document.getElementById("modal-manual");
    if (modal) modal.style.display = "flex";
}

function cerrarManual() {
    const modal = document.getElementById("modal-manual");
    if (modal) modal.style.display = "none";
}

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

// ==========================================
// 13. INICIALIZACIÓN GLOBAL AL CARGAR LA PÁGINA
// ==========================================
document.addEventListener('DOMContentLoaded', () => {
    cargarEmpleados();
    cargarTodosLosCatalogos();
});

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

async function cargarModuloIncidencias() {
    try {
        const tbody = document.getElementById('tbody-incidencias-detallada');
        if (tbody) {
            tbody.innerHTML = `<tr><td colspan="6" style="text-align: center; padding: 30px; color: #64748b;"><i class="ph ph-spinner" style="font-size: 24px;"></i> Cargando evaluaciones de incidencias...</td></tr>`;
        }

        const res = await fetch(`${API_URL}/api/incidencias/reporte`);
        if (!res.ok) throw new Error("Error al obtener reporte de incidencias");
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

    actualizarEstiloChipsPeriodo(null);

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

    actualizarEstiloChipsPeriodo(null);

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

    actualizarEstiloChipsPeriodo(null);

    if (modoComparativoIncidencias) {
        calcularFechasPeriodoB();
    }
    aplicarFiltrosIncidencias();
}

function establecerPreajustePeriodo(preset) {
    const inputDesde = document.getElementById('filtro-inc-desde');
    const inputHasta = document.getElementById('filtro-inc-hasta');
    if (!inputDesde || !inputHasta) return;

    // Obtener fecha de hoy o fecha máxima de la base de datos
    const fechas = rawEvaluacionesIncidencias.map(e => e.Fecha).filter(Boolean).sort();
    const hoyStr = fechas.length > 0 ? fechas[fechas.length - 1] : new Date().toISOString().substring(0, 10);
    const dtHoy = new Date(hoyStr + 'T12:00:00');

    let fDesde = "";
    let fHasta = hoyStr;

    function formatoYMD(dt) {
        const y = dt.getFullYear();
        const m = String(dt.getMonth() + 1).padStart(2, '0');
        const d = String(dt.getDate()).padStart(2, '0');
        return `${y}-${m}-${d}`;
    }

    if (preset === 'hoy') {
        fDesde = hoyStr;
        fHasta = hoyStr;
    } else if (preset === '7dias') {
        const dt7 = new Date(dtHoy.getTime() - 6 * 86400000);
        fDesde = formatoYMD(dt7);
        fHasta = hoyStr;
    } else if (preset === '30dias') {
        const dt30 = new Date(dtHoy.getTime() - 29 * 86400000);
        fDesde = formatoYMD(dt30);
        fHasta = hoyStr;
    } else if (preset === 'este_mes') {
        const ano = dtHoy.getFullYear();
        const mes = dtHoy.getMonth() + 1;
        const ultimoDia = new Date(ano, mes, 0).getDate();
        fDesde = `${ano}-${String(mes).padStart(2, '0')}-01`;
        fHasta = `${ano}-${String(mes).padStart(2, '0')}-${String(ultimoDia).padStart(2, '0')}`;
    } else if (preset === 'mes_anterior') {
        let ano = dtHoy.getFullYear();
        let mes = dtHoy.getMonth(); // mes anterior (0-indexed es mes anterior directo)
        if (mes === 0) {
            mes = 12;
            ano -= 1;
        }
        const ultimoDia = new Date(ano, mes, 0).getDate();
        fDesde = `${ano}-${String(mes).padStart(2, '0')}-01`;
        fHasta = `${ano}-${String(mes).padStart(2, '0')}-${String(ultimoDia).padStart(2, '0')}`;
    } else if (preset === 'este_ano') {
        const ano = dtHoy.getFullYear();
        fDesde = `${ano}-01-01`;
        fHasta = `${ano}-12-31`;
    } else if (preset === 'todo') {
        if (fechas.length > 0) {
            fDesde = fechas[0];
            fHasta = fechas[fechas.length - 1];
        }
    }

    inputDesde.value = fDesde;
    inputHasta.value = fHasta;

    // Sincronizar selectores si aplica
    const selMes = document.getElementById('sel-inc-mes');
    const selAno = document.getElementById('sel-inc-ano');
    if (preset === 'este_mes' || preset === 'mes_anterior') {
        if (selMes) selMes.value = fDesde.substring(0, 7);
        if (selAno) selAno.value = "";
    } else if (preset === 'este_ano') {
        if (selMes) selMes.value = "";
        if (selAno) selAno.value = String(dtHoy.getFullYear());
    } else {
        if (selMes) selMes.value = "";
        if (selAno) selAno.value = "";
    }

    actualizarEstiloChipsPeriodo(preset);

    if (modoComparativoIncidencias) {
        calcularFechasPeriodoB();
    }
    aplicarFiltrosIncidencias();
}

function actualizarEstiloChipsPeriodo(presetActivo) {
    const chips = document.querySelectorAll('.btn-filtro-chip');
    chips.forEach(c => {
        const onclickTxt = c.getAttribute('onclick') || '';
        if (presetActivo && onclickTxt.includes(`'${presetActivo}'`)) {
            c.classList.add('active');
        } else {
            c.classList.remove('active');
        }
    });
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

    actualizarEstiloChipsPeriodo(null);

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

    if (!modoComparativoIncidencias) {
        // MODO ESTÁNDAR
        if (elTotal) elTotal.innerText = totalA;
        if (elSubTotal) elSubTotal.innerText = "Total registros auditados";

        if (elLimpias) elLimpias.innerText = limpiasA;
        if (elPctLimpias) {
            elPctLimpias.innerText = `+${pctLimpiasA.toFixed(1)}%`;
            elPctLimpias.style.background = "#dcfce7";
            elPctLimpias.style.color = "#15803d";
        }
        if (elSubLimpias) elSubLimpias.innerText = "Operación sin contratiempos";

        if (elFallas) elFallas.innerText = fallasA;
        if (elPctFallas) {
            elPctFallas.innerText = `-${pctFallasA.toFixed(1)}%`;
            elPctFallas.style.background = "#fee2e2";
            elPctFallas.style.color = "#b91c1c";
        }
        if (elSubFallas) elSubFallas.innerText = "Reportes de fallas o daños";

        if (elEventos) elEventos.innerText = eventosA;
        if (elSubEventos) elSubEventos.innerText = "Órdenes de Producción con registro";
    } else {
        // MODO COMPARATIVO (Periodo A vs Periodo B)
        const totalB = evaluacionesComparativasIncidencias.length;
        const limpiasB = evaluacionesComparativasIncidencias.filter(e => e.Estatus.includes("Sin Incidencias")).length;
        const fallasB = totalB - limpiasB;
        const eventosB = new Set(evaluacionesComparativasIncidencias.map(e => e.Evento)).size;

        const pctLimpiasB = totalB > 0 ? ((limpiasB / totalB) * 100) : 0;
        const pctFallasB = totalB > 0 ? ((fallasB / totalB) * 100) : 0;

        // Deltas
        const deltaCalidad = pctLimpiasA - pctLimpiasB; // Variación en % de calidad limpia
        const deltaTotal = totalA - totalB;
        const deltaEventos = eventosA - eventosB;

        // KPI 1: Evaluaciones
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

        // KPI 2: Evaluaciones Limpias
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

        // KPI 3: Evaluaciones con Incidencias
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

        // KPI 4: Eventos
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

    if (!modoComparativoIncidencias) {
        banner.style.display = 'none';
        return;
    }

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
}

// -------------------------------------------------------------
// RENDERIZADO DE GRÁFICAS DE CALIDAD Y DESEMPEÑO
// -------------------------------------------------------------
function renderizarGraficasIncidencias() {
    if (typeof Chart === 'undefined') return;

    const totalA = evaluacionesFiltradasIncidencias.length;
    const limpiasA = evaluacionesFiltradasIncidencias.filter(e => e.Estatus.includes("Sin Incidencias")).length;
    const fallasA = totalA - limpiasA;
    const pctLimpiasA = totalA > 0 ? ((limpiasA / totalA) * 100) : 0;
    const pctFallasA = totalA > 0 ? ((fallasA / totalA) * 100) : 0;

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
            // MODO COMPARATIVO: 2 Barras Horizontales Apiladas (A vs B)
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

// ==========================================
// 17. MÓDULO RECURSOS HUMANOS
// ==========================================
let listaEmpleadosRHCache = [];
let idEmpleadoRHActual = null;

function cambiarPestanaRH(tab) {
    const tabs = ['datos', 'contratos', 'vacaciones', 'permisos', 'capacitacion', 'documentos'];
    tabs.forEach(t => {
        const btn = document.getElementById(`tab-rh-btn-${t}`);
        const view = document.getElementById(`subvista-rh-${t}`);
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

async function cargarModuloRH() {
    try {
        const [resEmps, resAlertas] = await Promise.all([
            fetch(`${API_URL}/api/rh/empleados`),
            fetch(`${API_URL}/api/rh/alertas`)
        ]);

        if (resAlertas.ok) {
            const alertas = await resAlertas.json();
            const banner = document.getElementById("banner-rh-alertas");
            if (banner) {
                if (alertas && alertas.length > 0) {
                    banner.style.display = "block";
                    banner.innerHTML = `
                        <div style="background: #fef2f2; border: 1px solid #fecaca; border-radius: 10px; padding: 14px 18px; color: #991b1b; font-size: 13px;">
                            <b style="display: flex; align-items: center; gap: 6px; font-size: 14px; margin-bottom: 6px;">
                                <i class="ph ph-warning-circle"></i> Alertas Activas de Recursos Humanos (${alertas.length})
                            </b>
                            <ul style="margin: 0; padding-left: 20px;">
                                ${alertas.map(a => `<li>${a.mensaje || a.descripcion || 'Alerta laboral'}</li>`).join("")}
                            </ul>
                        </div>
                    `;
                } else {
                    banner.style.display = "none";
                }
            }
        }

        if (resEmps.ok) {
            listaEmpleadosRHCache = await resEmps.json();
            const selEmp = document.getElementById("sel-rh-empleado");
            if (selEmp) {
                selEmp.innerHTML = '<option value="">--- O selecciona de la lista completa ---</option>' +
                    listaEmpleadosRHCache.map(e => `<option value="${e.id_empleado}">${e.id_empleado} - ${e.nombre} (${e.depto || 'General'})</option>`).join("");
                
                // Si el usuario actual está en la lista o hay colaboradores, autoseleccionar
                if (!idEmpleadoRHActual && listaEmpleadosRHCache.length > 0) {
                    const idDefault = usuarioLogueado?.id_empleado || listaEmpleadosRHCache[0].id_empleado;
                    selEmp.value = idDefault;
                    elegirEmpleadoRHSugerencia(idDefault);
                }
            }
        }
    } catch (err) {
        console.error("Error al cargar módulo RH:", err);
    }
}

// --- BÚSQUEDA INTELIGENTE DE EMPLEADO (RRHH) ---
let indiceSugerenciaRHEmpleadoActivo = -1;

function filtrarEmpleadosRHSugerencias(termino) {
    const dropdown = document.getElementById("sugerencias-rh-empleados-dropdown");
    const btnLimpiar = document.getElementById("btn-limpiar-busqueda-rh");
    if (!dropdown) return;

    if (btnLimpiar) {
        btnLimpiar.style.display = (termino && termino.trim()) ? "block" : "none";
    }

    const t = normalizarTextoBusqueda(termino);
    let coincidencias = [];
    if (!t) {
        coincidencias = listaEmpleadosRHCache.slice(0, 15);
    } else {
        const palabras = t.split(" ").filter(Boolean);
        coincidencias = listaEmpleadosRHCache.filter(e => {
            const norm = normalizarTextoBusqueda(`${e.id_empleado} ${e.nombre} ${e.depto || ''} ${e.puesto || ''}`);
            return palabras.every(pal => norm.includes(pal));
        }).slice(0, 30);
    }

    if (coincidencias.length === 0) {
        dropdown.innerHTML = `<div style="padding: 14px; text-align: center; color: #64748b; font-size: 13px;">No se encontró ningún colaborador con ese criterio.</div>`;
        dropdown.style.display = "block";
        indiceSugerenciaRHEmpleadoActivo = -1;
        return;
    }

    indiceSugerenciaRHEmpleadoActivo = -1;
    dropdown.innerHTML = coincidencias.map((e, idx) => `
        <div class="sugerencia-rh-item" data-index="${idx}" data-id="${e.id_empleado}"
             onclick="elegirEmpleadoRHSugerencia('${e.id_empleado}')"
             onmouseenter="resaltarSugerenciaRHEmpleado(${idx})"
             style="padding: 10px 14px; border-bottom: 1px solid #f1f5f9; cursor: pointer; display: flex; align-items: center; justify-content: space-between; transition: background 0.15s;">
            <div>
                <div style="font-weight: 700; color: #0f172a; font-size: 13px;">
                    <span style="background: #e2e8f0; color: #334155; padding: 2px 6px; border-radius: 4px; font-size: 11px; margin-right: 6px; font-family: monospace;">${e.id_empleado}</span>
                    ${resaltarTexto(e.nombre, termino)}
                </div>
                <div style="font-size: 11.5px; color: #64748b; margin-top: 2px;">
                    <b>Depto:</b> ${e.depto || 'General'} | <b>Puesto:</b> ${e.puesto || 'Colaborador'}
                </div>
            </div>
            <span style="font-size: 11.5px; color: #0284c7; font-weight: 600;">Auditar Expediente &rarr;</span>
        </div>
    `).join("");

    dropdown.style.display = "block";
}

function activarEmpleadosRHSugerencias() {
    const input = document.getElementById("input-buscar-rh-empleado");
    filtrarEmpleadosRHSugerencias(input ? input.value : "");
}

function resaltarSugerenciaRHEmpleado(idx) {
    indiceSugerenciaRHEmpleadoActivo = idx;
    const items = document.querySelectorAll(".sugerencia-rh-item");
    items.forEach((it, i) => {
        it.style.background = (i === idx) ? "#eff6ff" : "white";
    });
}

function manejarKeydownEmpleadosRH(event) {
    const dropdown = document.getElementById("sugerencias-rh-empleados-dropdown");
    if (!dropdown || dropdown.style.display === "none") return;

    const items = dropdown.querySelectorAll(".sugerencia-rh-item");
    if (!items || items.length === 0) return;

    if (event.key === "ArrowDown") {
        event.preventDefault();
        indiceSugerenciaRHEmpleadoActivo = (indiceSugerenciaRHEmpleadoActivo + 1) % items.length;
        resaltarSugerenciaRHEmpleado(indiceSugerenciaRHEmpleadoActivo);
        items[indiceSugerenciaRHEmpleadoActivo]?.scrollIntoView({ block: "nearest" });
    } else if (event.key === "ArrowUp") {
        event.preventDefault();
        indiceSugerenciaRHEmpleadoActivo = (indiceSugerenciaRHEmpleadoActivo - 1 + items.length) % items.length;
        resaltarSugerenciaRHEmpleado(indiceSugerenciaRHEmpleadoActivo);
        items[indiceSugerenciaRHEmpleadoActivo]?.scrollIntoView({ block: "nearest" });
    } else if (event.key === "Enter") {
        event.preventDefault();
        if (indiceSugerenciaRHEmpleadoActivo >= 0 && items[indiceSugerenciaRHEmpleadoActivo]) {
            const id = items[indiceSugerenciaRHEmpleadoActivo].getAttribute("data-id");
            if (id) elegirEmpleadoRHSugerencia(id);
        }
    } else if (event.key === "Escape") {
        dropdown.style.display = "none";
    }
}

function elegirEmpleadoRHSugerencia(idEmpleado) {
    const dropdown = document.getElementById("sugerencias-rh-empleados-dropdown");
    if (dropdown) dropdown.style.display = "none";

    const emp = listaEmpleadosRHCache.find(e => String(e.id_empleado) === String(idEmpleado));
    const input = document.getElementById("input-buscar-rh-empleado");
    const selEmp = document.getElementById("sel-rh-empleado");
    const btnLimpiar = document.getElementById("btn-limpiar-busqueda-rh");

    if (emp) {
        if (input) input.value = `${emp.id_empleado} - ${emp.nombre} (${emp.depto || 'General'})`;
        if (btnLimpiar) btnLimpiar.style.display = "block";
    }
    if (selEmp) selEmp.value = idEmpleado;

    seleccionarEmpleadoRH(idEmpleado);
}

function seleccionarEmpleadoRHOpcion(idEmpleado) {
    if (!idEmpleado) {
        limpiarBusquedaRHEmpleado();
        return;
    }
    elegirEmpleadoRHSugerencia(idEmpleado);
}

function limpiarBusquedaRHEmpleado() {
    const input = document.getElementById("input-buscar-rh-empleado");
    const btnLimpiar = document.getElementById("btn-limpiar-busqueda-rh");
    const dropdown = document.getElementById("sugerencias-rh-empleados-dropdown");
    const selEmp = document.getElementById("sel-rh-empleado");

    if (input) {
        input.value = "";
        input.focus();
    }
    if (btnLimpiar) btnLimpiar.style.display = "none";
    if (selEmp) selEmp.value = "";
    if (dropdown) dropdown.style.display = "none";

    activarEmpleadosRHSugerencias();
}

document.addEventListener("click", function(e) {
    const cont = document.getElementById("contenedor-busqueda-rh-empleado");
    const dropdown = document.getElementById("sugerencias-rh-empleados-dropdown");
    if (dropdown && cont && !cont.contains(e.target)) {
        dropdown.style.display = "none";
    }
});

async function seleccionarEmpleadoRH(idEmpleado) {
    if (!idEmpleado) {
        const cont = document.getElementById("rh-expediente-container");
        if (cont) cont.style.display = "none";
        idEmpleadoRHActual = null;
        return;
    }
    idEmpleadoRHActual = idEmpleado;

    try {
        const [resExp, resContratos, resVac, resPerm, resIncap, resCap, resEval, resDoc] = await Promise.all([
            fetch(`${API_URL}/api/rh/empleados/${idEmpleado}`),
            fetch(`${API_URL}/api/rh/contratos/${idEmpleado}`),
            fetch(`${API_URL}/api/rh/vacaciones/${idEmpleado}`),
            fetch(`${API_URL}/api/rh/permisos?id_empleado=${idEmpleado}`),
            fetch(`${API_URL}/api/rh/incapacidades/${idEmpleado}`),
            fetch(`${API_URL}/api/rh/capacitacion/${idEmpleado}`),
            fetch(`${API_URL}/api/rh/evaluaciones/${idEmpleado}`),
            fetch(`${API_URL}/api/rh/documentos/${idEmpleado}`)
        ]);

        const emp = resExp.ok ? await resExp.json() : {};

        // Sincronizar input de búsqueda y select si difieren
        const inputBuscarEmp = document.getElementById("input-buscar-rh-empleado");
        const btnLimpiar = document.getElementById("btn-limpiar-busqueda-rh");
        const selEmp = document.getElementById("sel-rh-empleado");
        if (emp && emp.nombre) {
            if (inputBuscarEmp && (!inputBuscarEmp.value || !inputBuscarEmp.value.includes(String(emp.id_empleado)))) {
                inputBuscarEmp.value = `${emp.id_empleado} - ${emp.nombre} (${emp.depto || 'General'})`;
            }
            if (btnLimpiar) btnLimpiar.style.display = "block";
            if (selEmp && selEmp.value !== idEmpleado) selEmp.value = idEmpleado;
        }

        // 1. Ficha Resumen
        const elNom = document.getElementById("rh-ficha-nombre");
        const elId = document.getElementById("rh-ficha-id");
        const elDep = document.getElementById("rh-ficha-depto");
        const elPuesto = document.getElementById("rh-ficha-puesto");
        const elEdad = document.getElementById("rh-ficha-edad");
        const elAnt = document.getElementById("rh-ficha-antiguedad");
        const elEst = document.getElementById("rh-ficha-estatus");
        const elFoto = document.getElementById("rh-ficha-foto");

        if (elNom) elNom.innerText = emp.nombre || '--';
        if (elId) elId.innerText = emp.id_empleado || idEmpleado;
        if (elDep) elDep.innerText = emp.depto || '--';
        if (elPuesto) elPuesto.innerText = emp.puesto || '--';
        if (elEdad) elEdad.innerText = emp.edad ? `${emp.edad} AÑOS` : '--';
        if (elAnt) elAnt.innerText = emp.anios_trabajados !== undefined ? `${emp.anios_trabajados} AÑOS` : '--';
        if (elEst) elEst.innerText = (emp.estatus_empleado || 'ACTIVO').toUpperCase();
        if (elFoto) elFoto.src = emp.foto_url || `${API_URL}/fotos/${idEmpleado}.jpg`;

        // 2. Datos Generales Formulario
        const setVal = (id, val) => {
            const el = document.getElementById(id);
            if (el) el.value = (val !== null && val !== undefined && val !== "None") ? val : "";
        };

        setVal("rh-gen-nombre", emp.nombre);
        setVal("rh-gen-email", emp.email);
        setVal("rh-gen-cel", emp.cel);
        setVal("rh-gen-rfc", emp.rfc);
        setVal("rh-gen-curp", emp.curp);
        setVal("rh-gen-nss", emp.nss);
        setVal("rh-gen-depto", emp.depto);
        setVal("rh-gen-puesto", emp.puesto);
        setVal("rh-gen-tipo-contrato", emp.tipo_contrato || "PLANTA");
        setVal("rh-gen-salario", emp.salario_mensual);
        setVal("rh-gen-escolaridad", emp.escolaridad || "LICENCIATURA");
        setVal("rh-gen-estado-civil", emp.estado_civil || "SOLTERO");
        setVal("rh-gen-domicilio", emp.domicilio);
        setVal("rh-gen-ciudad", emp.ciudad);
        setVal("rh-gen-cp", emp.cp);
        setVal("rh-gen-contacto-emergencia", emp.contacto_emergencia);
        setVal("rh-gen-tel-emergencia", emp.tel_emergencia);
        setVal("rh-gen-parentesco", emp.parentesco_emergencia);
        setVal("rh-gen-estatus-empleado", emp.estatus_empleado || "ACTIVO");
        setVal("rh-gen-fecha-baja", emp.fecha_baja ? String(emp.fecha_baja).substring(0, 10) : "");
        setVal("rh-gen-motivo-baja", emp.motivo_baja);

        // 3. Contratos
        if (resContratos.ok) {
            const contratos = await resContratos.json();
            const tbContratos = document.getElementById("tabla-rh-contratos-body");
            if (tbContratos) {
                if (contratos.length === 0) {
                    tbContratos.innerHTML = `<tr><td colspan="8" style="text-align: center; padding: 20px; color: var(--text-muted);">Sin historial de contratos registrados.</td></tr>`;
                } else {
                    tbContratos.innerHTML = contratos.map(c => {
                        const tieneDoc = !!c.archivo_contrato_url;
                        const docBtn = tieneDoc
                            ? `<button type="button" onclick="abrirVisorDocumentoGeneral('${c.archivo_contrato_url.replace(/'/g, "\\'")}', 'Contrato_${c.folio_contrato || c.id_contrato}')"
                                      style="background: #0284c7; color: white; border: none; padding: 5px 10px; border-radius: 5px; font-size: 11.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                                   <i class="ph ph-file-pdf"></i> Ver Contrato
                               </button>`
                            : `<button type="button" onclick="irASubirDocumentoRH('Contrato Laboral Firmado')"
                                      title="Digitalizar y subir contrato a Documentos Digitales"
                                      style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 4px 8px; border-radius: 5px; font-size: 11px; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                                   <i class="ph ph-plus-circle"></i> Digitalizar
                               </button>`;

                        return `
                        <tr>
                            <td><b>${c.folio_contrato || '--'}</b></td>
                            <td>${c.tipo_contrato || '--'}</td>
                            <td>${c.fecha_inicio || '--'}</td>
                            <td>${c.fecha_fin || 'Indefinido'}</td>
                            <td>${c.puesto_contratado || '--'}</td>
                            <td>$${Number(c.salario_mensual || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</td>
                            <td><span style="background: #dcfce7; color: #166534; font-weight: 700; font-size: 11px; padding: 2px 8px; border-radius: 4px;">${c.estatus_contrato || 'VIGENTE'}</span></td>
                            <td style="text-align: center;">${docBtn}</td>
                        </tr>
                    `;
                    }).join("");
                }
            }
        }

        // 4. Vacaciones
        if (resVac.ok) {
            const dataVac = await resVac.json();
            const resumen = dataVac.resumen || {};
            const periodos = dataVac.historial || [];

            if (document.getElementById("rh-vac-correspondientes")) {
                document.getElementById("rh-vac-correspondientes").innerText = resumen.dias_totales_correspondientes || resumen.dias_totales_acumulados || 0;
            }
            if (document.getElementById("rh-vac-tomados")) {
                document.getElementById("rh-vac-tomados").innerText = resumen.dias_tomados || 0;
            }
            if (document.getElementById("rh-vac-pendientes")) {
                document.getElementById("rh-vac-pendientes").innerText = resumen.dias_pendientes || 0;
            }

            const tbVac = document.getElementById("tabla-rh-vacaciones-body");
            if (tbVac) {
                if (periodos.length === 0) {
                    tbVac.innerHTML = `<tr><td colspan="7" style="text-align: center; padding: 20px; color: var(--text-muted);">Sin periodos vacacionales registrados en este historial.</td></tr>`;
                } else {
                    tbVac.innerHTML = periodos.map(v => {
                        const modalidad = v.tipo || 'DÍAS SUELTOS / FRACCIONADOS';
                        const obs = v.observaciones || `Año ${v.anio_periodo}`;
                        return `
                        <tr>
                            <td><b>${obs}</b></td>
                            <td><span style="background: #eff6ff; color: #1e40af; font-size: 11px; padding: 2px 8px; border-radius: 4px; font-weight: 600;">${modalidad}</span></td>
                            <td><b style="color: #b45309;">${v.dias_tomados || 0} día(s)</b></td>
                            <td>${v.fecha_inicio_goce || '--'}</td>
                            <td>${v.fecha_fin_goce || '--'}</td>
                            <td><span style="background: #dcfce7; color: #166534; font-weight: 700; font-size: 11px; padding: 2px 8px; border-radius: 4px;">${v.estatus || 'APROBADO'}</span></td>
                            <td style="text-align: center;">
                                <button type="button" onclick="imprimirPapeletaVacacionesRH(${v.id_vacacion}, '${(emp.nombre || '').replace(/'/g, "\\'")}', '${v.fecha_inicio_goce}', '${v.fecha_fin_goce}', ${v.dias_tomados}, '${(v.observaciones || '').replace(/'/g, "\\'")}')"
                                    title="Imprimir Papeleta de Conformidad LFT (Art. 78)"
                                    style="background: #f1f5f9; color: #0369a1; border: 1px solid #bae6fd; padding: 4px 10px; border-radius: 5px; font-size: 11px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                                    <i class="ph ph-printer"></i> 📄 Papeleta LFT
                                </button>
                            </td>
                        </tr>
                    `;
                    }).join("");
                }
            }
        }

        // 5. Permisos & Incapacidades
        const permisos = resPerm.ok ? await resPerm.json() : [];
        const incapacidades = resIncap.ok ? await resIncap.json() : [];
        const tbPerm = document.getElementById("tabla-rh-permisos-body");
        if (tbPerm) {
            const combined = [
                ...permisos.map(p => ({ ...p, _tipo_reg: 'PERMISO', _archivo: p.archivo_justificante })),
                ...incapacidades.map(i => ({ ...i, _tipo_reg: 'INCAPACIDAD IMSS', _archivo: i.archivo_incapacidad_url }))
            ];
            if (combined.length === 0) {
                tbPerm.innerHTML = `<tr><td colspan="8" style="text-align: center; padding: 20px; color: var(--text-muted);">Sin permisos o incapacidades registradas.</td></tr>`;
            } else {
                tbPerm.innerHTML = combined.map(item => {
                    const tieneArch = !!item._archivo;
                    const folio = item.folio_permiso || item.folio_incapacidad || 'Doc';
                    const docBtn = tieneArch
                        ? `<button type="button" onclick="abrirVisorDocumentoGeneral('${item._archivo.replace(/'/g, "\\'")}', 'Comprobante_${folio}')"
                                  style="background: #0284c7; color: white; border: none; padding: 5px 10px; border-radius: 5px; font-size: 11.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                               <i class="ph ph-file-text"></i> Ver Archivo
                           </button>`
                        : `<button type="button" onclick="irASubirDocumentoRH('${item._tipo_reg.includes('INCAPACIDAD') ? 'Certificado Médico' : 'Otro Documento Laboral'}')"
                                  title="Subir comprobante o justificante médico al expediente"
                                  style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 4px 8px; border-radius: 5px; font-size: 11px; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                               <i class="ph ph-plus-circle"></i> Adjuntar
                           </button>`;

                    return `
                        <tr>
                            <td><b>${folio}</b></td>
                            <td><span style="background: #eff6ff; color: #1e40af; font-size: 11px; padding: 2px 8px; border-radius: 4px; font-weight: 600;">${item._tipo_reg}</span></td>
                            <td>${item.fecha_inicio || item.fecha_solicitud || '--'}</td>
                            <td>${item.fecha_fin || '--'}</td>
                            <td>${item.dias_solicitados || item.dias_incapacidad || 1} días</td>
                            <td>${item.con_goce_de_sueldo ? 'Sí' : 'No'}</td>
                            <td><span style="font-weight: 700;">${item.estatus || 'REGISTRADO'}</span></td>
                            <td style="text-align: center;">${docBtn}</td>
                        </tr>
                    `;
                }).join("");
            }
        }

        // 6. Capacitaciones & Evaluaciones
        const cursos = resCap.ok ? await resCap.json() : [];
        const evalua = resEval.ok ? await resEval.json() : [];
        const tbEval = document.getElementById("tabla-rh-evaluaciones-body");
        if (tbEval) {
            const unificados = [
                ...evalua.map(ev => ({ titulo: ev.periodo || 'Evaluación', tipo: 'EVALUACIÓN DESEMPEÑO', actor: ev.evaluador || '--', cal: ev.calificacion_final, nivel: ev.nivel_desempeno, urlDoc: ev.archivo_evaluacion_url })),
                ...cursos.map(c => ({ titulo: c.nombre_curso, tipo: 'CAPACITACIÓN TÉCNICA', actor: c.institucion || '--', cal: c.calificacion, nivel: c.resultado || 'APROBADO', urlDoc: c.constancia_url }))
            ];
            if (unificados.length === 0) {
                tbEval.innerHTML = `<tr><td colspan="6" style="text-align: center; padding: 20px; color: var(--text-muted);">Sin evaluaciones o capacitaciones registradas.</td></tr>`;
            } else {
                tbEval.innerHTML = unificados.map(u => {
                    const tieneDoc = !!u.urlDoc;
                    const docBtn = tieneDoc
                        ? `<button type="button" onclick="abrirVisorDocumentoGeneral('${u.urlDoc.replace(/'/g, "\\'")}', '${u.titulo}')"
                                  style="background: #0284c7; color: white; border: none; padding: 5px 10px; border-radius: 5px; font-size: 11.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                               <i class="ph ph-certificate"></i> Ver Archivo
                           </button>`
                        : `<button type="button" onclick="irASubirDocumentoRH('${u.tipo.includes('CAPACITACIÓN') ? 'Comprobante de Estudios' : 'Otro Documento Laboral'}')"
                                  title="Subir constancia DC-3 o formato de evaluación al expediente"
                                  style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 4px 8px; border-radius: 5px; font-size: 11px; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                               <i class="ph ph-plus-circle"></i> Adjuntar
                           </button>`;

                    return `
                        <tr>
                            <td><b>${u.titulo}</b></td>
                            <td>${u.tipo}</td>
                            <td>${u.actor}</td>
                            <td style="font-weight: 700;">${u.cal !== null && u.cal !== undefined ? u.cal : '--'}</td>
                            <td><span style="background: #dcfce7; color: #166534; font-weight: 700; padding: 2px 8px; border-radius: 4px; font-size: 11px;">${u.nivel || 'APROBADO'}</span></td>
                            <td style="text-align: center;">${docBtn}</td>
                        </tr>
                    `;
                }).join("");
            }
        }

        // 7. Documentos
        if (resDoc.ok) {
            const docs = await resDoc.json();
            listaDocumentosRHActual = docs || [];
            filtrarDocumentosRHCategoria('TODOS');
        }

        const cont = document.getElementById("rh-expediente-container");
        if (cont) cont.style.display = "block";
    } catch (e) {
        console.error("Error al cargar expediente:", e);
        alert(`❌ Error al consultar expediente de empleado: ${e.message}`);
    }
}

async function guardarDatosGeneralesRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ No hay un colaborador seleccionado.");
        return;
    }

    const getVal = (id) => document.getElementById(id)?.value?.trim() || "";

    const payload = {
        nombre: getVal("rh-gen-nombre"),
        email: getVal("rh-gen-email"),
        cel: getVal("rh-gen-cel"),
        rfc: getVal("rh-gen-rfc"),
        curp: getVal("rh-gen-curp"),
        nss: getVal("rh-gen-nss"),
        depto: getVal("rh-gen-depto"),
        puesto: getVal("rh-gen-puesto"),
        tipo_contrato: getVal("rh-gen-tipo-contrato"),
        salario_mensual: parseFloat(getVal("rh-gen-salario") || 0),
        escolaridad: getVal("rh-gen-escolaridad"),
        estado_civil: getVal("rh-gen-estado-civil"),
        domicilio: getVal("rh-gen-domicilio"),
        ciudad: getVal("rh-gen-ciudad"),
        cp: getVal("rh-gen-cp"),
        contacto_emergencia: getVal("rh-gen-contacto-emergencia"),
        tel_emergencia: getVal("rh-gen-tel-emergencia"),
        parentesco_emergencia: getVal("rh-gen-parentesco"),
        estatus_empleado: getVal("rh-gen-estatus-empleado"),
        fecha_baja: getVal("rh-gen-fecha-baja") || null,
        motivo_baja: getVal("rh-gen-motivo-baja") || null,
        registrado_por: usuarioLogueado?.nombre_completo || "RH"
    };

    try {
        const res = await fetch(`${API_URL}/api/rh/empleados/${idEmpleadoRHActual}`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (res.ok) {
            alert("✅ ¡Expediente actualizado exitosamente en base de datos!");
            seleccionarEmpleadoRH(idEmpleadoRHActual);
        } else {
            const err = await res.text();
            alert(`❌ Error al actualizar expediente: ${err}`);
        }
    } catch (e) {
        alert(`❌ Error de comunicación: ${e.message}`);
    }
}

// ==============================================================================
// GESTIÓN DE VACACIONES (LFT ART. 76, 78 Y 81 - REFORMA VACACIONES DIGNAS)
// ==============================================================================
function toggleFormularioVacacionesRH() {
    const f = document.getElementById("form-registrar-vacaciones-rh");
    if (!f) return;
    f.style.display = (f.style.display === "none" || f.style.display === "") ? "block" : "none";
    if (f.style.display === "block") {
        const hoy = new Date().toISOString().split("T")[0];
        const inInicio = document.getElementById("rh-vac-inicio");
        const inFin = document.getElementById("rh-vac-fin");
        if (inInicio && !inInicio.value) inInicio.value = hoy;
        if (inFin && !inFin.value) inFin.value = hoy;
        alCambiarFechasVacacionesRH();
        inInicio?.focus();
    }
}

function alCambiarFechasVacacionesRH() {
    const fInicio = document.getElementById("rh-vac-inicio")?.value;
    const fFin = document.getElementById("rh-vac-fin")?.value;
    const inDias = document.getElementById("rh-vac-dias");

    if (fInicio && fFin && inDias) {
        const d1 = new Date(fInicio);
        const d2 = new Date(fFin);
        if (d2 >= d1) {
            const diffTime = Math.abs(d2 - d1);
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
            inDias.value = diffDays;
        } else {
            inDias.value = 1;
        }
    }
}

async function guardarSalidaVacacionesRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor selecciona primero a un colaborador.");
        return;
    }

    const tipo = document.getElementById("rh-vac-tipo")?.value || "DÍAS SUELTOS / FRACCIONADOS";
    const inicio = document.getElementById("rh-vac-inicio")?.value;
    const fin = document.getElementById("rh-vac-fin")?.value;
    const dias = parseInt(document.getElementById("rh-vac-dias")?.value || "1");
    const motivo = document.getElementById("rh-vac-motivo")?.value?.trim() || "Disfrute fraccionado a solicitud del colaborador";
    const btn = document.getElementById("btn-guardar-vac-rh");

    if (!inicio || !fin) {
        alert("⚠️ Por favor especifica la fecha de inicio y fin del periodo o día a tomar.");
        return;
    }

    if (dias <= 0) {
        alert("⚠️ El número de días debe ser mayor a 0.");
        return;
    }

    const pendientes = parseInt(document.getElementById("rh-vac-pendientes")?.innerText || "0");
    if (dias > pendientes) {
        if (!confirm(`⚠️ El colaborador tiene ${pendientes} día(s) pendientes y estás registrando ${dias} día(s). ¿Deseas continuar y registrarlo como anticipo/permiso con goce?`)) {
            return;
        }
    }

    if (btn) {
        btn.disabled = true;
        btn.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Guardando...`;
    }

    const payload = {
        id_empleado: idEmpleadoRHActual,
        anio_periodo: new Date().getFullYear(),
        dias_tomados: dias,
        fecha_inicio_goce: inicio,
        fecha_fin_goce: fin,
        tipo: tipo,
        observaciones: motivo,
        registrado_por: (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "RECURSOS HUMANOS")
    };

    try {
        const res = await fetch(`${API_URL}/api/rh/vacaciones`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (res.ok) {
            alert(`✅ ¡Se registraron exitosamente ${dias} día(s) de vacaciones! Se descontaron automáticamente de la bolsa acumulada conforme al Art. 78 de la LFT.`);
            toggleFormularioVacacionesRH();
            seleccionarEmpleadoRH(idEmpleadoRHActual);
        } else {
            const err = await res.text();
            alert(`❌ Error al registrar vacaciones: ${err}`);
        }
    } catch (e) {
        alert(`❌ Error de comunicación: ${e.message}`);
    } finally {
        if (btn) {
            btn.disabled = false;
            btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar y Descontar de Saldo`;
        }
    }
}

function imprimirPapeletaVacacionesRH(idVac, nombreEmp, fInicio, fFin, dias, observaciones) {
    const win = window.open("", "_blank");
    if (!win) {
        alert("⚠️ Por favor permite las ventanas emergentes en tu navegador para ver la papeleta de vacaciones.");
        return;
    }

    const hoyStr = new Date().toLocaleDateString("es-MX", { year: "numeric", month: "long", day: "numeric" });

    win.document.write(`
        <!DOCTYPE html>
        <html lang="es">
        <head>
            <meta charset="UTF-8">
            <title>Papeleta de Vacaciones LFT - ${nombreEmp}</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; margin: 40px; color: #0f172a; line-height: 1.6; }
                .card { border: 2px solid #0f172a; border-radius: 10px; padding: 30px; max-width: 750px; margin: 0 auto; }
                .header { text-align: center; border-bottom: 2px solid #e2e8f0; padding-bottom: 16px; margin-bottom: 24px; }
                .header h2 { margin: 0 0 6px 0; color: #0f172a; text-transform: uppercase; font-size: 20px; letter-spacing: 0.5px; }
                .header p { margin: 0; font-size: 13px; color: #64748b; }
                .legal-box { background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 6px; padding: 12px; font-size: 11.5px; color: #475569; margin-bottom: 20px; text-align: justify; }
                .table-data { width: 100%; border-collapse: collapse; margin-bottom: 24px; }
                .table-data td { padding: 8px 12px; border: 1px solid #cbd5e1; font-size: 13px; }
                .table-data td.lbl { background: #f1f5f9; font-weight: 700; width: 35%; color: #334155; }
                .firmas { display: flex; justify-content: space-between; margin-top: 60px; padding: 0 40px; }
                .firma-box { text-align: center; width: 40%; border-top: 1px solid #0f172a; padding-top: 8px; font-size: 12.5px; font-weight: 600; }
                .btn-print { background: #0284c7; color: white; border: none; padding: 10px 20px; border-radius: 6px; font-weight: 700; cursor: pointer; margin-bottom: 20px; display: inline-flex; align-items: center; gap: 6px; }
                @media print { .btn-print { display: none; } body { margin: 0; } .card { border: none; padding: 0; } }
            </style>
        </head>
        <body>
            <div style="text-align: center;">
                <button class="btn-print" onclick="window.print()">🖨️ Imprimir Papeleta Oficial LFT</button>
            </div>
            <div class="card">
                <div class="header">
                    <h2>VPRO STREAMING SERVICES S.A. DE C.V.</h2>
                    <p>SOLICITUD Y CONSTANCIA DE DISFRUTE DE VACACIONES (ART. 78 LFT)</p>
                </div>

                <div class="legal-box">
                    <b>FUNDAMENTO LEGAL (REFORMA VACACIONES DIGNAS):</b> De conformidad con lo dispuesto en el Artículo 78 de la Ley Federal del Trabajo reformada, la persona trabajadora manifiesta su potestad y solicitud expresa para que el periodo de vacaciones sea distribuido y fraccionado en la forma y fechas aquí señaladas, en mutuo acuerdo y sin menoscabo de sus derechos laborales.
                </div>

                <table class="table-data">
                    <tr>
                        <td class="lbl">Colaborador / Trabajador:</td>
                        <td><b>${nombreEmp}</b></td>
                    </tr>
                    <tr>
                        <td class="lbl">Fecha de Expedición:</td>
                        <td>${hoyStr}</td>
                    </tr>
                    <tr>
                        <td class="lbl">Días a Gozar / Descontar:</td>
                        <td><b>${dias} día(s)</b> hábiles</td>
                    </tr>
                    <tr>
                        <td class="lbl">Periodo de Goce:</td>
                        <td>Desde: <b>${fInicio}</b> | Hasta: <b>${fFin}</b></td>
                    </tr>
                    <tr>
                        <td class="lbl">Motivo / Observaciones:</td>
                        <td>${observaciones || 'Disfrute fraccionado acordado conforme a la LFT'}</td>
                    </tr>
                    <tr>
                        <td class="lbl">Estatus de Autorización:</td>
                        <td><b>AUTORIZADO Y CONCEDIDO</b></td>
                    </tr>
                </table>

                <div class="firmas">
                    <div class="firma-box">
                        ${nombreEmp}<br>
                        <span style="font-size: 11px; font-weight: normal; color: #64748b;">Firma del Colaborador (De Conformidad)</span>
                    </div>
                    <div class="firma-box">
                        RECURSOS HUMANOS / DIRECCIÓN<br>
                        <span style="font-size: 11px; font-weight: normal; color: #64748b;">Autorizado por VPRO</span>
                    </div>
                </div>
            </div>
        </body>
        </html>
    `);
    win.document.close();
}

// ==============================================================================
// GESTIÓN DE EXPEDIENTE DIGITAL Y DOCUMENTOS OFICIALES (RECURSOS HUMANOS)
// ==============================================================================
let cacheDocumentosRH = {};
let listaDocumentosRHActual = [];
let categoriaFiltroDocRHActual = 'TODOS';

function toggleFormularioSubirDocumentoRH() {
    const f = document.getElementById("form-subir-documento-rh");
    if (!f) return;
    f.style.display = (f.style.display === "none" || f.style.display === "") ? "block" : "none";
    if (f.style.display === "block") {
        document.getElementById("rh-doc-archivo")?.focus();
    }
}

function irASubirDocumentoRH(tipoSugerido) {
    cambiarPestanaRH('documentos');
    const f = document.getElementById("form-subir-documento-rh");
    if (f) f.style.display = "block";
    const selTipo = document.getElementById("rh-doc-tipo");
    if (selTipo && tipoSugerido) {
        for (let i = 0; i < selTipo.options.length; i++) {
            const opt = selTipo.options[i];
            if (opt.value.toLowerCase().includes(tipoSugerido.toLowerCase()) || tipoSugerido.toLowerCase().includes(opt.value.toLowerCase())) {
                selTipo.selectedIndex = i;
                break;
            }
        }
    }
    document.getElementById("rh-doc-archivo")?.focus();
}

function filtrarDocumentosRHCategoria(categoria) {
    categoriaFiltroDocRHActual = categoria;

    // Actualizar estilo visual de los botones de filtro
    const categorias = ['TODOS', 'IDENTIDAD', 'LABORAL', 'SALUD', 'ACADEMICO'];
    const idMap = {
        'TODOS': 'btn-filtro-doc-todos',
        'IDENTIDAD': 'btn-filtro-doc-identidad',
        'LABORAL': 'btn-filtro-doc-laboral',
        'SALUD': 'btn-filtro-doc-salud',
        'ACADEMICO': 'btn-filtro-doc-academico'
    };

    categorias.forEach(cat => {
        const btn = document.getElementById(idMap[cat]);
        if (btn) {
            if (cat === categoria) {
                btn.style.background = '#0f172a';
                btn.style.color = 'white';
                btn.style.border = 'none';
            } else {
                btn.style.background = '#f1f5f9';
                btn.style.color = '#475569';
                btn.style.border = '1px solid #cbd5e1';
            }
        }
    });

    if (!listaDocumentosRHActual || listaDocumentosRHActual.length === 0) {
        renderizarDocumentosRHTabla([]);
        return;
    }

    if (categoria === 'TODOS') {
        renderizarDocumentosRHTabla(listaDocumentosRHActual);
        return;
    }

    const docsFiltrados = listaDocumentosRHActual.filter(d => {
        const tipo = (d.tipo_documento || '').toUpperCase();
        if (categoria === 'IDENTIDAD') {
            return tipo.includes('INE') || tipo.includes('IDENTIFICACIÓN') || tipo.includes('RFC') || tipo.includes('FISCAL') || tipo.includes('CURP') || tipo.includes('NSS') || tipo.includes('IMSS') || tipo.includes('DOMICILIO') || tipo.includes('LICENCIA') || tipo.includes('ACTA');
        } else if (categoria === 'LABORAL') {
            return tipo.includes('CONTRATO') || tipo.includes('LABORAL') || tipo.includes('RECOMENDACIÓN') || tipo.includes('PENALES');
        } else if (categoria === 'SALUD') {
            return tipo.includes('MÉDICO') || tipo.includes('MEDICO') || tipo.includes('SALUD') || tipo.includes('INCAPACIDAD');
        } else if (categoria === 'ACADEMICO') {
            return tipo.includes('ESTUDIOS') || tipo.includes('TÍTULO') || tipo.includes('TITULO') || tipo.includes('CÉDULA') || tipo.includes('CEDULA') || tipo.includes('CERTIFICADO') || tipo.includes('CURSO') || tipo.includes('CAPACITACIÓN');
        }
        return true;
    });

    renderizarDocumentosRHTabla(docsFiltrados);
}

function renderizarDocumentosRHTabla(docs) {
    const tbDoc = document.getElementById("tabla-rh-documentos-body");
    if (!tbDoc) return;

    cacheDocumentosRH = {};

    if (!docs || docs.length === 0) {
        tbDoc.innerHTML = `<tr><td colspan="7" style="text-align: center; padding: 24px; color: var(--text-muted); font-size: 13px;">📁 Sin documentos digitales en esta categoría para el expediente.</td></tr>`;
        return;
    }

    tbDoc.innerHTML = docs.map(d => {
        cacheDocumentosRH[d.id_documento] = {
            url: d.archivo_url || "",
            nombre: d.nombre_archivo || `documento_${d.id_documento}`
        };

        const tipo = (d.tipo_documento || "Otro Documento").trim();
        let badgeStyle = "background: #f1f5f9; color: #334155;";
        let badgeIcon = "ph-file-text";

        if (tipo.includes("INE") || tipo.includes("Identificación")) {
            badgeStyle = "background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe;";
            badgeIcon = "ph-identification-card";
        } else if (tipo.includes("RFC") || tipo.includes("Fiscal")) {
            badgeStyle = "background: #f5f3ff; color: #6d28d9; border: 1px solid #ddd6fe;";
            badgeIcon = "ph-receipt";
        } else if (tipo.includes("CURP")) {
            badgeStyle = "background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0;";
            badgeIcon = "ph-fingerprint";
        } else if (tipo.includes("NSS") || tipo.includes("IMSS")) {
            badgeStyle = "background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca;";
            badgeIcon = "ph-first-aid-kit";
        } else if (tipo.includes("Domicilio")) {
            badgeStyle = "background: #f0fdf4; color: #15803d; border: 1px solid #bbf7d0;";
            badgeIcon = "ph-house";
        } else if (tipo.includes("Licencia")) {
            badgeStyle = "background: #fffbeb; color: #b45309; border: 1px solid #fde68a;";
            badgeIcon = "ph-car";
        } else if (tipo.includes("Contrato")) {
            badgeStyle = "background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd;";
            badgeIcon = "ph-scroll";
        } else if (tipo.includes("Estudios") || tipo.includes("Título") || tipo.includes("Cédula")) {
            badgeStyle = "background: #fdf4ff; color: #a21caf; border: 1px solid #f5d0fe;";
            badgeIcon = "ph-graduation-cap";
        } else if (tipo.includes("Médico") || tipo.includes("Salud")) {
            badgeStyle = "background: #f0fdfa; color: #0f766e; border: 1px solid #99f6e4;";
            badgeIcon = "ph-heartbeat";
        }

        // Vigencia semáforo
        let vigenciaBadge = '<span style="background: #f1f5f9; color: #475569; padding: 3px 8px; border-radius: 4px; font-size: 11.5px;">🟢 Vigente</span>';
        if (d.fecha_vencimiento) {
            const hoy = new Date();
            const fVenc = new Date(d.fecha_vencimiento);
            const diffDias = Math.ceil((fVenc - hoy) / (1000 * 60 * 60 * 24));

            if (diffDias < 0) {
                vigenciaBadge = `<span style="background: #fee2e2; color: #991b1b; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 11.5px;">🔴 Vencido (${d.fecha_vencimiento})</span>`;
            } else if (diffDias <= 30) {
                vigenciaBadge = `<span style="background: #fef3c7; color: #92400e; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 11.5px;">🟡 Vence en ${diffDias} d (${d.fecha_vencimiento})</span>`;
            } else {
                vigenciaBadge = `<span style="background: #dcfce7; color: #166534; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 11.5px;">🟢 Vigente (${d.fecha_vencimiento})</span>`;
            }
        }

        // Estatus RH
        const verificadoBadge = d.verificado_por_rh
            ? `<span style="background: #dcfce7; color: #166534; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 11.5px; display: inline-flex; align-items: center; gap: 4px;"><i class="ph ph-check-circle-fill"></i> Verificado</span>`
            : `<span style="background: #fef3c7; color: #92400e; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 11.5px; display: inline-flex; align-items: center; gap: 4px;"><i class="ph ph-clock"></i> En Revisión</span>`;

        // Formato archivo
        const formato = (d.formato || (d.nombre_archivo ? d.nombre_archivo.split('.').pop() : 'DOC')).toUpperCase();
        let formatoColor = '#64748b';
        if (formato === 'PDF') formatoColor = '#dc2626';
        else if (['PNG', 'JPG', 'JPEG'].includes(formato)) formatoColor = '#0284c7';

        return `
            <tr>
                <td>
                    <span style="display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; ${badgeStyle}">
                        <i class="ph ${badgeIcon}"></i> ${tipo}
                    </span>
                </td>
                <td>
                    <div style="display: flex; align-items: center; gap: 6px;">
                        <span style="background: #f1f5f9; color: ${formatoColor}; font-weight: 800; font-size: 10px; padding: 2px 5px; border-radius: 3px; font-family: monospace;">.${formato}</span>
                        <span style="font-weight: 600; color: #0f172a; max-width: 220px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${d.nombre_archivo || '--'}">
                            ${d.nombre_archivo || '--'}
                        </span>
                    </div>
                </td>
                <td style="font-size: 12.5px;">${d.fecha_emision ? d.fecha_emision : (d.fecha_subida ? String(d.fecha_subida).substring(0, 10) : '--')}</td>
                <td>${vigenciaBadge}</td>
                <td>${verificadoBadge}</td>
                <td style="font-size: 12px; max-width: 180px; color: #64748b; line-height: 1.3;">${d.observaciones || '<span style="color:#cbd5e1;">Sin notas</span>'}</td>
                <td style="text-align: center;">
                    <div style="display: flex; gap: 6px; justify-content: center; align-items: center;">
                        <button type="button" onclick="verDocumentoRH(${d.id_documento})" title="Ver o Descargar Archivo" 
                                style="background: #0284c7; color: white; border: none; padding: 5px 10px; border-radius: 5px; font-size: 11.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                            <i class="ph ph-eye"></i> Ver
                        </button>
                        ${!d.verificado_por_rh ? `
                        <button type="button" onclick="verificarDocumentoRH(${d.id_documento})" title="Certificar como Verificado por RH" 
                                style="background: #16a34a; color: white; border: none; padding: 5px 8px; border-radius: 5px; font-size: 11.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 3px;">
                            <i class="ph ph-check"></i>
                        </button>` : ''}
                        <button type="button" onclick="eliminarDocumentoRH(${d.id_documento}, '${(d.tipo_documento || 'documento').replace(/'/g, "\\'")}')" title="Eliminar del Expediente" 
                                style="background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; padding: 5px 8px; border-radius: 5px; font-size: 11.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center;">
                            <i class="ph ph-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `;
    }).join("");
}

async function subirDocumentoRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor selecciona primero un colaborador en el selector superior de Recursos Humanos.");
        return;
    }

    const tipoDoc = document.getElementById("rh-doc-tipo")?.value;
    const fileInput = document.getElementById("rh-doc-archivo");
    const fechaEmision = document.getElementById("rh-doc-emision")?.value || null;
    const fechaVencimiento = document.getElementById("rh-doc-vencimiento")?.value || null;
    const notas = document.getElementById("rh-doc-notas")?.value?.trim() || "";
    const btnGuardar = document.getElementById("btn-guardar-doc-rh");

    if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
        alert("⚠️ Por favor selecciona el archivo digital a cargar (PDF, JPG o PNG).");
        fileInput?.focus();
        return;
    }

    const file = fileInput.files[0];
    if (file.size > 25 * 1024 * 1024) {
        alert("⚠️ El archivo es demasiado grande. El límite máximo permitido es de 25 MB.");
        return;
    }

    if (btnGuardar) {
        btnGuardar.disabled = true;
        btnGuardar.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Subiendo...`;
    }

    try {
        const reader = new FileReader();
        reader.onload = async function(e) {
            const dataUrl = e.target.result;
            const formato = file.name.split('.').pop().toLowerCase();

            const payload = {
                id_empleado: idEmpleadoRHActual,
                tipo_documento: tipoDoc,
                nombre_archivo: file.name,
                archivo_url: dataUrl,
                formato: formato,
                fecha_emision: fechaEmision,
                fecha_vencimiento: fechaVencimiento,
                esta_vigente: true,
                observaciones: notas,
                subido_por: (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "RECURSOS HUMANOS")
            };

            try {
                const res = await fetch(`${API_URL}/api/rh/documentos`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(payload)
                });

                if (res.ok) {
                    alert(`✅ ¡Documento "${tipoDoc}" subido y vinculado exitosamente al expediente laboral!`);
                    fileInput.value = "";
                    if (document.getElementById("rh-doc-emision")) document.getElementById("rh-doc-emision").value = "";
                    if (document.getElementById("rh-doc-vencimiento")) document.getElementById("rh-doc-vencimiento").value = "";
                    if (document.getElementById("rh-doc-notas")) document.getElementById("rh-doc-notas").value = "";
                    toggleFormularioSubirDocumentoRH();
                    recargarDocumentosRH(idEmpleadoRHActual);
                } else {
                    const err = await res.text();
                    alert(`❌ Error al registrar documento: ${err}`);
                }
            } catch (err) {
                alert(`❌ Error de comunicación: ${err.message}`);
            } finally {
                if (btnGuardar) {
                    btnGuardar.disabled = false;
                    btnGuardar.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar en Expediente Digital`;
                }
            }
        };

        reader.onerror = function() {
            alert("❌ Error al leer el archivo desde el dispositivo.");
            if (btnGuardar) {
                btnGuardar.disabled = false;
                btnGuardar.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar en Expediente Digital`;
            }
        };

        reader.readAsDataURL(file);
    } catch (e) {
        alert(`❌ Error inesperado: ${e.message}`);
        if (btnGuardar) {
            btnGuardar.disabled = false;
            btnGuardar.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar en Expediente Digital`;
        }
    }
}

async function recargarDocumentosRH(idEmp) {
    if (!idEmp) return;
    try {
        const res = await fetch(`${API_URL}/api/rh/documentos/${idEmp}`);
        if (res.ok) {
            const docs = await res.json();
            listaDocumentosRHActual = docs || [];
            filtrarDocumentosRHCategoria(categoriaFiltroDocRHActual || 'TODOS');
        }
    } catch (e) {
        console.error("Error al recargar documentos:", e);
    }
}

function abrirVisorDocumentoGeneral(url, nombre) {
    if (!url) {
        alert("⚠️ No se encontró el archivo digital adjunto.");
        return;
    }

    nombre = nombre || "documento";

    if (url.startsWith("data:")) {
        const win = window.open();
        if (win) {
            win.document.write(`
                <!DOCTYPE html>
                <html lang="es">
                <head>
                    <meta charset="UTF-8">
                    <title>${nombre} - VPRO Expediente Digital</title>
                    <style>
                        body { margin: 0; background: #0f172a; display: flex; flex-direction: column; height: 100vh; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
                        .topbar { background: #1e293b; color: white; padding: 12px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #334155; }
                        .btn-dl { background: #0284c7; color: white; padding: 8px 16px; text-decoration: none; border-radius: 6px; font-size: 13px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; }
                        .btn-dl:hover { background: #0369a1; }
                    </style>
                </head>
                <body>
                    <div class="topbar">
                        <span style="font-weight: 600; font-size: 14px;">📁 Expediente Laboral VPRO: ${nombre}</span>
                        <a href="${url}" download="${nombre}" class="btn-dl">⬇ Descargar Archivo Original</a>
                    </div>
                    ${url.startsWith("data:application/pdf") 
                        ? `<iframe src="${url}" style="flex: 1; border: none; width: 100%; height: 100%;"></iframe>`
                        : `<div style="flex: 1; display: flex; justify-content: center; align-items: center; overflow: auto; padding: 24px;"><img src="${url}" style="max-width: 90%; max-height: 90vh; border-radius: 8px; box-shadow: 0 12px 32px rgba(0,0,0,0.6);"></div>`
                    }
                </body>
                </html>
            `);
        } else {
            const a = document.createElement("a");
            a.href = url;
            a.download = nombre;
            a.target = "_blank";
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
        }
    } else {
        window.open(url.startsWith("http") ? url : `${API_URL}${url}`, "_blank");
    }
}

function verDocumentoRH(idDoc) {
    const item = cacheDocumentosRH[idDoc];
    if (!item || !item.url) {
        alert("⚠️ No se encontró el archivo digital adjunto para este documento.");
        return;
    }
    abrirVisorDocumentoGeneral(item.url, item.nombre);
}

async function verificarDocumentoRH(idDoc) {
    if (!confirm("¿Deseas certificar y marcar este documento como VERIFICADO POR RH?")) return;

    try {
        const res = await fetch(`${API_URL}/api/rh/documentos/${idDoc}`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ verificado_por_rh: true })
        });

        if (res.ok) {
            alert("✅ Documento validado y certificado por Recursos Humanos.");
            recargarDocumentosRH(idEmpleadoRHActual);
        } else {
            const err = await res.text();
            alert(`❌ Error al verificar documento: ${err}`);
        }
    } catch (e) {
        alert(`❌ Error de comunicación: ${e.message}`);
    }
}

async function eliminarDocumentoRH(idDoc, tipoNombre) {
    if (!confirm(`¿Confirmas eliminar el documento "${tipoNombre}" del expediente laboral? Esta acción no se puede deshacer.`)) return;

    try {
        const res = await fetch(`${API_URL}/api/rh/documentos/${idDoc}`, {
            method: "DELETE"
        });

        if (res.ok) {
            alert(`✅ Documento "${tipoNombre}" eliminado del expediente.`);
            recargarDocumentosRH(idEmpleadoRHActual);
        } else {
            const err = await res.text();
            alert(`❌ Error al eliminar documento: ${err}`);
        }
    } catch (e) {
        alert(`❌ Error de comunicación: ${e.message}`);
    }
}

// ==============================================================================
// GESTIÓN DE CONTRATOS LABORALES (RECURSOS HUMANOS)
// ==============================================================================
function toggleFormularioContratoRH() {
    const f = document.getElementById("form-registrar-contrato-rh");
    if (!f) return;
    f.style.display = (f.style.display === "none" || f.style.display === "") ? "block" : "none";
    if (f.style.display === "block") {
        const hoy = new Date().toISOString().split("T")[0];
        const inInicio = document.getElementById("rh-ctr-inicio");
        if (inInicio && !inInicio.value) inInicio.value = hoy;
        const depto = document.getElementById("rh-ficha-depto")?.innerText;
        const puesto = document.getElementById("rh-ficha-puesto")?.innerText;
        if (depto && depto !== "--" && document.getElementById("rh-ctr-depto")) {
            document.getElementById("rh-ctr-depto").value = depto;
        }
        if (puesto && puesto !== "--" && document.getElementById("rh-ctr-puesto")) {
            document.getElementById("rh-ctr-puesto").value = puesto;
        }
        document.getElementById("rh-ctr-tipo")?.focus();
    }
}

async function subirNuevoContratoRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor selecciona primero un colaborador en el selector de Recursos Humanos.");
        return;
    }

    const tipo = document.getElementById("rh-ctr-tipo")?.value;
    const inicio = document.getElementById("rh-ctr-inicio")?.value;
    const fin = document.getElementById("rh-ctr-fin")?.value || null;
    const puesto = document.getElementById("rh-ctr-puesto")?.value?.trim();
    const depto = document.getElementById("rh-ctr-depto")?.value?.trim();
    const salario = parseFloat(document.getElementById("rh-ctr-salario")?.value || 0);
    const jornada = document.getElementById("rh-ctr-jornada")?.value?.trim() || "L-V 09:00 a 18:00";
    const obs = document.getElementById("rh-ctr-observaciones")?.value?.trim() || "";
    const fileInput = document.getElementById("rh-ctr-archivo");
    const btn = document.getElementById("btn-guardar-ctr-rh");

    if (!inicio) {
        alert("⚠️ Por favor captura la fecha de inicio del contrato.");
        document.getElementById("rh-ctr-inicio")?.focus();
        return;
    }
    if (!puesto) {
        alert("⚠️ Por favor captura el puesto o cargo contratado.");
        document.getElementById("rh-ctr-puesto")?.focus();
        return;
    }
    if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
        alert("⚠️ Por favor selecciona el archivo digital del contrato firmado (PDF, JPG o PNG).");
        fileInput?.focus();
        return;
    }

    const file = fileInput.files[0];
    if (file.size > 25 * 1024 * 1024) {
        alert("⚠️ El archivo es demasiado grande (máximo 25 MB).");
        return;
    }

    if (btn) {
        btn.disabled = true;
        btn.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Guardando...`;
    }

    try {
        const reader = new FileReader();
        reader.onload = async function(e) {
            const dataUrl = e.target.result;

            const payload = {
                id_empleado: idEmpleadoRHActual,
                tipo_contrato: tipo,
                fecha_inicio: inicio,
                fecha_fin: fin,
                es_indefinido: !fin,
                puesto_contratado: puesto,
                departamento: depto,
                salario_mensual: salario,
                jornada: jornada,
                archivo_contrato_url: dataUrl,
                observaciones: obs,
                registrado_por: (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "RECURSOS HUMANOS")
            };

            try {
                const res = await fetch(`${API_URL}/api/rh/contratos`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(payload)
                });

                if (res.ok) {
                    const data = await res.json();
                    alert(`✅ ¡Contrato laboral ${data.folio || ''} registrado exitosamente en el expediente!`);
                    fileInput.value = "";
                    if (document.getElementById("rh-ctr-salario")) document.getElementById("rh-ctr-salario").value = "";
                    if (document.getElementById("rh-ctr-observaciones")) document.getElementById("rh-ctr-observaciones").value = "";
                    toggleFormularioContratoRH();
                    seleccionarEmpleadoRH(idEmpleadoRHActual);
                } else {
                    const err = await res.text();
                    alert(`❌ Error al registrar contrato: ${err}`);
                }
            } catch (err) {
                alert(`❌ Error de comunicación: ${err.message}`);
            } finally {
                if (btn) {
                    btn.disabled = false;
                    btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar Contrato en Expediente`;
                }
            }
        };

        reader.onerror = function() {
            alert("❌ Error al procesar el archivo en el navegador.");
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar Contrato en Expediente`;
            }
        };

        reader.readAsDataURL(file);
    } catch (e) {
        alert(`❌ Error inesperado: ${e.message}`);
        if (btn) {
            btn.disabled = false;
            btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar Contrato en Expediente`;
        }
    }
}

// ==============================================================================
// GESTIÓN DE PERMISOS E INCAPACIDADES (RECURSOS HUMANOS)
// ==============================================================================
function toggleFormularioPermisoRH() {
    const f = document.getElementById("form-registrar-permiso-rh");
    if (!f) return;
    f.style.display = (f.style.display === "none" || f.style.display === "") ? "block" : "none";
    if (f.style.display === "block") {
        const hoy = new Date().toISOString().split("T")[0];
        const inInicio = document.getElementById("rh-per-inicio");
        const inFin = document.getElementById("rh-per-fin");
        if (inInicio && !inInicio.value) inInicio.value = hoy;
        if (inFin && !inFin.value) inFin.value = hoy;
        alCambiarFechasPermisoRH();
        inInicio?.focus();
    }
}

function alCambiarFechasPermisoRH() {
    const fIni = document.getElementById("rh-per-inicio")?.value;
    const fFin = document.getElementById("rh-per-fin")?.value;
    const inDias = document.getElementById("rh-per-dias");
    if (fIni && fFin && inDias) {
        const d1 = new Date(fIni);
        const d2 = new Date(fFin);
        if (d2 >= d1) {
            inDias.value = Math.ceil((d2 - d1) / (1000 * 60 * 60 * 24)) + 1;
        } else {
            inDias.value = 1;
        }
    }
}

async function subirNuevoPermisoRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor selecciona primero a un colaborador.");
        return;
    }

    const tipo = document.getElementById("rh-per-tipo")?.value;
    const inicio = document.getElementById("rh-per-inicio")?.value;
    const fin = document.getElementById("rh-per-fin")?.value;
    const dias = parseInt(document.getElementById("rh-per-dias")?.value || "1");
    const goce = document.getElementById("rh-per-goce")?.value === "true";
    const estatus = document.getElementById("rh-per-estatus")?.value || "APROBADO";
    const motivo = document.getElementById("rh-per-motivo")?.value?.trim();
    const impacta = document.getElementById("rh-per-impacta") ? document.getElementById("rh-per-impacta").checked : true;
    const fileInput = document.getElementById("rh-per-archivo");
    const btn = document.getElementById("btn-guardar-per-rh");

    if (!inicio || !fin) {
        alert("⚠️ Por favor especifica las fechas de inicio y fin del permiso.");
        return;
    }
    if (!motivo) {
        alert("⚠️ Por favor captura el motivo o justificación del permiso.");
        document.getElementById("rh-per-motivo")?.focus();
        return;
    }

    if (btn) {
        btn.disabled = true;
        btn.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Guardando...`;
    }

    const enviar = async (archivoUrl = null) => {
        const payload = {
            id_empleado: idEmpleadoRHActual,
            tipo_permiso: tipo,
            fecha_solicitud: new Date().toISOString().split("T")[0],
            fecha_inicio: inicio,
            fecha_fin: fin,
            con_goce_de_sueldo: goce,
            justificacion: motivo,
            archivo_justificante: archivoUrl,
            estatus: estatus,
            impacta_asistencia: impacta,
            registrado_por: (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "RECURSOS HUMANOS")
        };

        try {
            const res = await fetch(`${API_URL}/api/rh/permisos`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            });

            if (res.ok) {
                const data = await res.json();
                alert(`✅ ¡Permiso laboral ${data.folio || ''} registrado exitosamente! ${impacta ? 'Sincronizado con el Reloj Checador.' : ''}`);
                if (fileInput) fileInput.value = "";
                if (document.getElementById("rh-per-motivo")) document.getElementById("rh-per-motivo").value = "";
                toggleFormularioPermisoRH();
                seleccionarEmpleadoRH(idEmpleadoRHActual);
            } else {
                const err = await res.text();
                alert(`❌ Error al registrar permiso: ${err}`);
            }
        } catch (e) {
            alert(`❌ Error de comunicación: ${e.message}`);
        } finally {
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar Permiso y Sincronizar`;
            }
        }
    };

    if (fileInput && fileInput.files && fileInput.files.length > 0) {
        const file = fileInput.files[0];
        const reader = new FileReader();
        reader.onload = (e) => enviar(e.target.result);
        reader.onerror = () => {
            alert("❌ Error al leer archivo adjunto.");
            if (btn) btn.disabled = false;
        };
        reader.readAsDataURL(file);
    } else {
        enviar(null);
    }
}

function toggleFormularioIncapacidadRH() {
    const f = document.getElementById("form-registrar-incapacidad-rh");
    if (!f) return;
    f.style.display = (f.style.display === "none" || f.style.display === "") ? "block" : "none";
    if (f.style.display === "block") {
        const hoy = new Date().toISOString().split("T")[0];
        const inInicio = document.getElementById("rh-inc-inicio");
        const inFin = document.getElementById("rh-inc-fin");
        if (inInicio && !inInicio.value) inInicio.value = hoy;
        if (inFin && !inFin.value) inFin.value = hoy;
        alCambiarFechasIncapacidadRH();
        inInicio?.focus();
    }
}

function alCambiarFechasIncapacidadRH() {
    const fIni = document.getElementById("rh-inc-inicio")?.value;
    const fFin = document.getElementById("rh-inc-fin")?.value;
    const inDias = document.getElementById("rh-inc-dias");
    if (fIni && fFin && inDias) {
        const d1 = new Date(fIni);
        const d2 = new Date(fFin);
        if (d2 >= d1) {
            inDias.value = Math.ceil((d2 - d1) / (1000 * 60 * 60 * 24)) + 1;
        } else {
            inDias.value = 1;
        }
    }
}

async function subirNuevaIncapacidadRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor selecciona primero a un colaborador.");
        return;
    }

    const tipo = document.getElementById("rh-inc-tipo")?.value;
    const folioImss = document.getElementById("rh-inc-imss-folio")?.value?.trim() || "";
    const inicio = document.getElementById("rh-inc-inicio")?.value;
    const fin = document.getElementById("rh-inc-fin")?.value;
    const diagnostico = document.getElementById("rh-inc-diagnostico")?.value?.trim() || "Incapacidad Médica";
    const medico = document.getElementById("rh-inc-medico")?.value?.trim() || "";
    const fileInput = document.getElementById("rh-inc-archivo");
    const btn = document.getElementById("btn-guardar-inc-rh");

    if (!inicio || !fin) {
        alert("⚠️ Por favor captura las fechas de inicio y fin amparadas por el IMSS.");
        return;
    }
    if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
        alert("⚠️ Por favor adjunta la boleta o certificado de incapacidad IMSS (PDF, JPG o PNG).");
        fileInput?.focus();
        return;
    }

    const file = fileInput.files[0];
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Guardando...`;
    }

    try {
        const reader = new FileReader();
        reader.onload = async function(e) {
            const dataUrl = e.target.result;

            const payload = {
                id_empleado: idEmpleadoRHActual,
                tipo: tipo,
                fecha_inicio: inicio,
                fecha_fin: fin,
                numero_imss: folioImss,
                medico_tratante: medico,
                diagnostico: diagnostico,
                porcentaje_pago_imss: tipo.includes("RIESGO") ? 100.0 : 60.0,
                archivo_incapacidad_url: dataUrl,
                registrado_por: (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "RECURSOS HUMANOS")
            };

            try {
                const res = await fetch(`${API_URL}/api/rh/incapacidades`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(payload)
                });

                if (res.ok) {
                    const data = await res.json();
                    alert(`✅ ¡Incapacidad médica ${data.folio || ''} registrada y sincronizada con el Kiosco!`);
                    fileInput.value = "";
                    if (document.getElementById("rh-inc-diagnostico")) document.getElementById("rh-inc-diagnostico").value = "";
                    toggleFormularioIncapacidadRH();
                    seleccionarEmpleadoRH(idEmpleadoRHActual);
                } else {
                    const err = await res.text();
                    alert(`❌ Error al registrar incapacidad: ${err}`);
                }
            } catch (err) {
                alert(`❌ Error de comunicación: ${err.message}`);
            } finally {
                if (btn) {
                    btn.disabled = false;
                    btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar Incapacidad IMSS`;
                }
            }
        };

        reader.readAsDataURL(file);
    } catch (e) {
        alert(`❌ Error inesperado: ${e.message}`);
        if (btn) btn.disabled = false;
    }
}

// ==============================================================================
// GESTIÓN DE CAPACITACIONES Y EVALUACIONES (RECURSOS HUMANOS)
// ==============================================================================
function toggleFormularioCapacitacionRH() {
    const f = document.getElementById("form-registrar-capacitacion-rh");
    if (!f) return;
    f.style.display = (f.style.display === "none" || f.style.display === "") ? "block" : "none";
    if (f.style.display === "block") {
        const hoy = new Date().toISOString().split("T")[0];
        const inInicio = document.getElementById("rh-cap-inicio");
        if (inInicio && !inInicio.value) inInicio.value = hoy;
        document.getElementById("rh-cap-nombre")?.focus();
    }
}

async function subirNuevaCapacitacionRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor selecciona primero a un colaborador.");
        return;
    }

    const nombre = document.getElementById("rh-cap-nombre")?.value?.trim();
    const tipo = document.getElementById("rh-cap-tipo")?.value;
    const horas = parseFloat(document.getElementById("rh-cap-horas")?.value || 8);
    const institucion = document.getElementById("rh-cap-institucion")?.value?.trim() || "";
    const inicio = document.getElementById("rh-cap-inicio")?.value;
    const fin = document.getElementById("rh-cap-fin")?.value || null;
    const resultado = document.getElementById("rh-cap-resultado")?.value || "APROBADO";
    const costo = parseFloat(document.getElementById("rh-cap-costo")?.value || 0);
    const pagado = document.getElementById("rh-cap-pagado")?.value === "true";
    const fileInput = document.getElementById("rh-cap-archivo");
    const btn = document.getElementById("btn-guardar-cap-rh");

    if (!nombre) {
        alert("⚠️ Por favor captura el nombre del curso o certificación.");
        document.getElementById("rh-cap-nombre")?.focus();
        return;
    }
    if (!inicio) {
        alert("⚠️ Por favor captura la fecha de inicio de la capacitación.");
        document.getElementById("rh-cap-inicio")?.focus();
        return;
    }
    if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
        alert("⚠️ Por favor adjunta la constancia DC-3 o diploma oficial (PDF, JPG o PNG).");
        fileInput?.focus();
        return;
    }

    const file = fileInput.files[0];
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Guardando...`;
    }

    try {
        const reader = new FileReader();
        reader.onload = async function(e) {
            const dataUrl = e.target.result;

            const payload = {
                id_empleado: idEmpleadoRHActual,
                nombre_curso: nombre,
                tipo: tipo,
                institucion: institucion,
                fecha_inicio: inicio,
                fecha_fin: fin,
                horas_duracion: horas,
                resultado: resultado,
                calificacion: 10.0,
                tiene_constancia: true,
                constancia_url: dataUrl,
                costo: costo,
                pagado_por_empresa: pagado,
                registrado_por: (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "RECURSOS HUMANOS")
            };

            try {
                const res = await fetch(`${API_URL}/api/rh/capacitacion`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(payload)
                });

                if (res.ok) {
                    alert(`✅ ¡Capacitación / DC-3 "${nombre}" registrada exitosamente en el expediente!`);
                    fileInput.value = "";
                    if (document.getElementById("rh-cap-nombre")) document.getElementById("rh-cap-nombre").value = "";
                    toggleFormularioCapacitacionRH();
                    seleccionarEmpleadoRH(idEmpleadoRHActual);
                } else {
                    const err = await res.text();
                    alert(`❌ Error al registrar curso: ${err}`);
                }
            } catch (err) {
                alert(`❌ Error de comunicación: ${err.message}`);
            } finally {
                if (btn) {
                    btn.disabled = false;
                    btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar Capacitación en Expediente`;
                }
            }
        };

        reader.readAsDataURL(file);
    } catch (e) {
        alert(`❌ Error: ${e.message}`);
        if (btn) btn.disabled = false;
    }
}

function toggleFormularioEvaluacionRH() {
    const f = document.getElementById("form-registrar-evaluacion-rh");
    if (!f) return;
    f.style.display = (f.style.display === "none" || f.style.display === "") ? "block" : "none";
    if (f.style.display === "block") {
        alCambiarCalificacionesEvaluacionRH();
        if (!document.getElementById("rh-eval-evaluador")?.value) {
            document.getElementById("rh-eval-evaluador").value = usuarioLogueado?.nombre_completo || "Dirección de Operaciones";
        }
        document.getElementById("rh-eval-periodo")?.focus();
    }
}

function alCambiarCalificacionesEvaluacionRH() {
    const c1 = parseFloat(document.getElementById("rh-eval-puntualidad")?.value || 10);
    const c2 = parseFloat(document.getElementById("rh-eval-calidad")?.value || 10);
    const c3 = parseFloat(document.getElementById("rh-eval-equipo")?.value || 10);
    const c4 = parseFloat(document.getElementById("rh-eval-responsabilidad")?.value || 10);
    const c5 = parseFloat(document.getElementById("rh-eval-iniciativa")?.value || 10);
    const c6 = parseFloat(document.getElementById("rh-eval-comunicacion")?.value || 10);
    const c7 = parseFloat(document.getElementById("rh-eval-cumplimiento")?.value || 10);

    const prom = (c1 + c2 + c3 + c4 + c5 + c6 + c7) / 7.0;
    const promFmt = prom.toFixed(1);

    let nivel = "EXCELENTE";
    if (prom >= 9) nivel = "EXCELENTE";
    else if (prom >= 7) nivel = "BUENO";
    else if (prom >= 5) nivel = "REGULAR";
    else nivel = "DEFICIENTE";

    const elProm = document.getElementById("rh-eval-promedio-calc");
    const elNivel = document.getElementById("rh-eval-nivel-calc");
    if (elProm) elProm.innerText = promFmt;
    if (elNivel) elNivel.innerText = nivel;
}

async function subirNuevaEvaluacionRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor selecciona primero a un colaborador.");
        return;
    }

    const periodo = document.getElementById("rh-eval-periodo")?.value?.trim();
    const evaluador = document.getElementById("rh-eval-evaluador")?.value?.trim();
    const puestoEval = document.getElementById("rh-eval-puesto")?.value?.trim() || "Evaluador RH";

    const c1 = parseFloat(document.getElementById("rh-eval-puntualidad")?.value || 10);
    const c2 = parseFloat(document.getElementById("rh-eval-calidad")?.value || 10);
    const c3 = parseFloat(document.getElementById("rh-eval-equipo")?.value || 10);
    const c4 = parseFloat(document.getElementById("rh-eval-responsabilidad")?.value || 10);
    const c5 = parseFloat(document.getElementById("rh-eval-iniciativa")?.value || 10);
    const c6 = parseFloat(document.getElementById("rh-eval-comunicacion")?.value || 10);
    const c7 = parseFloat(document.getElementById("rh-eval-cumplimiento")?.value || 10);

    const fortalezas = document.getElementById("rh-eval-fortalezas")?.value?.trim() || "";
    const mejora = document.getElementById("rh-eval-mejora")?.value?.trim() || "";
    const fileInput = document.getElementById("rh-eval-archivo");
    const btn = document.getElementById("btn-guardar-eval-rh");

    if (!periodo) {
        alert("⚠️ Por favor indica el periodo evaluado (ej. 2026-Q1).");
        document.getElementById("rh-eval-periodo")?.focus();
        return;
    }
    if (!evaluador) {
        alert("⚠️ Por favor indica el nombre del evaluador.");
        document.getElementById("rh-eval-evaluador")?.focus();
        return;
    }

    if (btn) {
        btn.disabled = true;
        btn.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Guardando...`;
    }

    const enviar = async (archivoUrl = null) => {
        const payload = {
            id_empleado: idEmpleadoRHActual,
            periodo: periodo,
            tipo: "DESEMPEÑO PERIÓDICO",
            evaluador: evaluador,
            puesto_evaluador: puestoEval,
            puntualidad: c1,
            calidad_trabajo: c2,
            trabajo_equipo: c3,
            responsabilidad: c4,
            iniciativa: c5,
            comunicacion: c6,
            cumplimiento_objetivos: c7,
            fortalezas: fortalezas,
            areas_mejora: mejora,
            archivo_evaluacion_url: archivoUrl,
            registrado_por: (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "RECURSOS HUMANOS")
        };

        try {
            const res = await fetch(`${API_URL}/api/rh/evaluaciones`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            });

            if (res.ok) {
                const data = await res.json();
                alert(`✅ ¡Evaluación de desempeño del periodo "${periodo}" registrada exitosamente! Calificación: ${data.calificacion_final} (${data.nivel_desempeno})`);
                if (fileInput) fileInput.value = "";
                toggleFormularioEvaluacionRH();
                seleccionarEmpleadoRH(idEmpleadoRHActual);
            } else {
                const err = await res.text();
                alert(`❌ Error al registrar evaluación: ${err}`);
            }
        } catch (e) {
            alert(`❌ Error de comunicación: ${e.message}`);
        } finally {
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar Evaluación de Desempeño`;
            }
        }
    };

    if (fileInput && fileInput.files && fileInput.files.length > 0) {
        const file = fileInput.files[0];
        const reader = new FileReader();
        reader.onload = (e) => enviar(e.target.result);
        reader.readAsDataURL(file);
    } else {
        enviar(null);
    }
}

// ==============================================================================
// VISOR DE EXPEDIENTE DIGITAL INTEGRAL COMPLETO (TODO LO INTEGRADO)
// ==============================================================================
let datosExpedienteCompletoActual = null;

async function verMiExpedientePropio() {
    if (!usuarioLogueado) return;
    idEmpleadoRHActual = usuarioLogueado.id_empleado;
    await abrirExpedienteCompletoRH();
}

async function abrirExpedienteCompletoRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor primero busca o selecciona a un colaborador para abrir su expediente integral.");
        document.getElementById("input-buscar-rh-empleado")?.focus();
        return;
    }

    const modal = document.getElementById("modal-expediente-completo-rh");
    const contenedor = document.getElementById("exp-completo-contenido");
    if (!modal || !contenedor) return;

    modal.style.display = "flex";
    contenedor.innerHTML = `
        <div style="text-align: center; padding: 50px 20px; color: #64748b;">
            <i class="ph ph-spinner ph-spin" style="font-size: 36px; color: #0284c7;"></i>
            <p style="margin-top: 14px; font-weight: 600; font-size: 14px;">Extrayendo expediente integral desde base de datos segura...</p>
        </div>
    `;

    try {
        const [resExp, resContratos, resVac, resPerm, resIncap, resEval, resCap, resDocs] = await Promise.all([
            fetch(`${API_URL}/api/rh/expediente/${idEmpleadoRHActual}`),
            fetch(`${API_URL}/api/rh/contratos/${idEmpleadoRHActual}`).catch(() => ({ ok: false })),
            fetch(`${API_URL}/api/rh/vacaciones/${idEmpleadoRHActual}`).catch(() => ({ ok: false })),
            fetch(`${API_URL}/api/rh/permisos?id_empleado=${idEmpleadoRHActual}`).catch(() => ({ ok: false })),
            fetch(`${API_URL}/api/rh/incapacidades/${idEmpleadoRHActual}`).catch(() => ({ ok: false })),
            fetch(`${API_URL}/api/rh/evaluaciones/${idEmpleadoRHActual}`).catch(() => ({ ok: false })),
            fetch(`${API_URL}/api/rh/capacitacion/${idEmpleadoRHActual}`).catch(() => ({ ok: false })),
            fetch(`${API_URL}/api/rh/documentos/${idEmpleadoRHActual}`).catch(() => ({ ok: false }))
        ]);

        if (!resExp.ok) {
            throw new Error(await resExp.text());
        }

        const dataExp = await resExp.json();
        const contratos = resContratos.ok ? await resContratos.json() : [];
        const dataVac = resVac.ok ? await resVac.json() : {};
        const permisos = resPerm.ok ? await resPerm.json() : [];
        const incapacidades = resIncap.ok ? await resIncap.json() : [];
        const evaluaciones = resEval.ok ? await resEval.json() : [];
        const capacitaciones = resCap.ok ? await resCap.json() : [];
        const documentos = resDocs.ok ? await resDocs.json() : (dataExp.documentos || []);

        datosExpedienteCompletoActual = {
            exp: dataExp,
            contratos,
            vacaciones: dataVac,
            permisos,
            incapacidades,
            evaluaciones,
            capacitaciones,
            documentos
        };

        renderizarExpedienteCompletoModal(datosExpedienteCompletoActual);
    } catch (e) {
        console.error("Error al cargar expediente completo:", e);
        contenedor.innerHTML = `
            <div style="background: #fee2e2; border: 1px solid #fca5a5; padding: 20px; border-radius: 10px; color: #991b1b; text-align: center;">
                <b>❌ No se pudo cargar el expediente completo:</b> ${e.message}
            </div>
        `;
    }
}

function cerrarExpedienteCompletoRH() {
    const modal = document.getElementById("modal-expediente-completo-rh");
    if (modal) modal.style.display = "none";
}

function renderizarExpedienteCompletoModal(datos) {
    const contenedor = document.getElementById("exp-completo-contenido");
    if (!contenedor) return;

    const emp = datos.exp.datos_personales || {};
    const contrato = datos.exp.contrato_vigente || {};
    const vacResumen = datos.vacaciones?.resumen || datos.exp.resumen_vacaciones || {};
    const vacHistorial = datos.vacaciones?.historial || [];
    const contratos = datos.contratos || [];
    const permisos = datos.permisos || [];
    const incapacidades = datos.incapacidades || [];
    const evaluaciones = datos.evaluaciones || [];
    const capacitaciones = datos.capacitaciones || [];
    const docs = datos.documentos || [];

    const badgeEst = document.getElementById("exp-completo-badge-estatus");
    if (badgeEst) {
        badgeEst.innerText = emp.estatus_empleado || "ACTIVO";
        badgeEst.style.background = emp.estatus_empleado === "BAJA" ? "#fee2e2" : "#dcfce7";
        badgeEst.style.color = emp.estatus_empleado === "BAJA" ? "#991b1b" : "#166534";
    }

    const foto = emp.foto_url || `${API_URL}/fotos/${emp.id_empleado}.jpg`;

    let html = `
        <!-- FICHA PRINCIPAL -->
        <div style="background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%); border-radius: 12px; padding: 20px 24px; color: white; display: flex; flex-wrap: wrap; gap: 20px; align-items: center; margin-bottom: 20px; box-shadow: 0 4px 14px rgba(0,0,0,0.1);">
            <img src="${foto}" onerror="this.src='vendor/img/avatar_default.png'" style="width: 86px; height: 86px; border-radius: 50%; object-fit: cover; border: 3px solid #38bdf8;">
            <div style="flex: 1; min-width: 250px;">
                <h2 style="margin: 0 0 4px 0; font-size: 22px; color: #ffffff;">${emp.nombre || '--'}</h2>
                <div style="font-size: 13.5px; color: #94a3b8; display: flex; flex-wrap: wrap; gap: 14px; margin-top: 4px;">
                    <span><b>ID:</b> <code style="color: #38bdf8; font-weight: 700;">${emp.id_empleado || '--'}</code></span>
                    <span><b>Depto:</b> <span style="color: #f8fafc;">${emp.depto || '--'}</span></span>
                    <span><b>Puesto:</b> <span style="color: #f8fafc;">${emp.puesto || '--'}</span></span>
                    <span><b>Ingreso:</b> <span style="color: #f8fafc;">${emp.fecha_ing || '--'}</span></span>
                </div>
            </div>
            <div style="display: flex; gap: 12px;">
                <div style="background: rgba(255,255,255,0.08); padding: 8px 14px; border-radius: 8px; text-align: center;">
                    <div style="font-size: 11px; color: #94a3b8;">EDAD</div>
                    <b style="font-size: 16px; color: #38bdf8;">${emp.edad ? `${emp.edad} años` : '--'}</b>
                </div>
                <div style="background: rgba(255,255,255,0.08); padding: 8px 14px; border-radius: 8px; text-align: center;">
                    <div style="font-size: 11px; color: #94a3b8;">ANTIGÜEDAD</div>
                    <b style="font-size: 16px; color: #4ade80;">${emp.anios_trabajados !== undefined ? `${emp.anios_trabajados} año(s)` : '--'}</b>
                </div>
            </div>
        </div>

        <!-- SECCIÓN 1: DATOS GENERALES Y FISCALES -->
        <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 10px; padding: 18px; margin-bottom: 20px;">
            <h4 style="margin: 0 0 14px 0; color: #0f172a; font-size: 15px; display: flex; align-items: center; gap: 8px; border-bottom: 1px dashed #cbd5e1; padding-bottom: 8px;">
                <i class="ph ph-identification-card" style="color: #0284c7;"></i> 1. Identificación Oficial, Fiscal y Contacto
            </h4>
            <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; font-size: 13px; margin-bottom: 14px;">
                <div><span style="color: #64748b;">RFC:</span> <b>${emp.rfc || '--'}</b></div>
                <div><span style="color: #64748b;">CURP:</span> <b>${emp.curp || '--'}</b></div>
                <div><span style="color: #64748b;">NSS (IMSS):</span> <b>${emp.nss || '--'}</b></div>
                <div><span style="color: #64748b;">Celular:</span> <b>${emp.cel || '--'}</b></div>
            </div>
            <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; font-size: 13px;">
                <div style="word-break: break-word;"><span style="color: #64748b;">Correo:</span> <b>${emp.email || '--'}</b></div>
                <div><span style="color: #64748b;">Domicilio:</span> <b>${emp.domicilio || '--'}, ${emp.ciudad || ''} (CP: ${emp.cp || '--'})</b></div>
                <div><span style="color: #64748b;">Contacto Emergencia:</span> <b>${emp.contacto_emergencia || '--'} (${emp.parentesco_emergencia || 'Familiar'}) - Tel: ${emp.tel_emergencia || '--'}</b></div>
                <div><span style="color: #64748b;">Escolaridad / Estado Civil:</span> <b>${emp.escolaridad || '--'} / ${emp.estado_civil || '--'}</b></div>
            </div>
        </div>

        <!-- SECCIÓN 2: CONTRATO LABORAL VIGENTE -->
        <div style="background: #ffffff; border: 1px solid #cbd5e1; border-radius: 10px; padding: 18px; margin-bottom: 20px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; border-bottom: 1px dashed #cbd5e1; padding-bottom: 8px;">
                <h4 style="margin: 0; color: #0f172a; font-size: 15px; display: flex; align-items: center; gap: 8px;">
                    <i class="ph ph-scroll" style="color: #0284c7;"></i> 2. Régimen Contractual y Salario
                </h4>
                <span style="font-size: 11.5px; font-weight: 700; padding: 3px 8px; border-radius: 4px; background: #e0f2fe; color: #0369a1;">
                    ${contratos.length} contrato(s) en historial
                </span>
            </div>
            ${contrato && contrato.folio_contrato ? `
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px; font-size: 13px; align-items: center;">
                    <div><span style="color: #64748b;">Folio Vigente:</span> <b style="color: #0369a1;">${contrato.folio_contrato}</b></div>
                    <div><span style="color: #64748b;">Tipo Contrato:</span> <b>${contrato.tipo_contrato || emp.tipo_contrato || '--'}</b></div>
                    <div><span style="color: #64748b;">Inicio / Fin:</span> <b>${contrato.fecha_inicio || '--'} a ${contrato.fecha_fin || 'Indefinido'}</b></div>
                    <div><span style="color: #64748b;">Salario Mensual Bruto:</span> <b style="color: #166534; font-size: 14px;">$${Number(contrato.salario_mensual || emp.salario_mensual || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</b></div>
                    <div><span style="color: #64748b;">Jornada:</span> <b>${contrato.jornada || 'L-V 09:00 a 18:00'}</b></div>
                    <div>
                        ${contrato.archivo_contrato_url ? `
                            <button type="button" onclick="abrirVisorDocumentoGeneral('${contrato.archivo_contrato_url.replace(/'/g, "\\'")}', 'Contrato_${contrato.folio_contrato}')"
                                style="background: #0284c7; color: white; border: none; padding: 6px 12px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                                <i class="ph ph-file-pdf"></i> Ver Contrato Firmado
                            </button>
                        ` : `<span style="color: #94a3b8; font-size: 12px;">Sin archivo adjunto</span>`}
                    </div>
                </div>
            ` : `
                <div style="font-size: 13px; color: #64748b;">
                    Tipo: <b>${emp.tipo_contrato || 'PLANTA'}</b> | Salario Registrado: <b>$${Number(emp.salario_mensual || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</b> | Sin contrato formal registrado aún.
                </div>
            `}
        </div>

        <!-- SECCIÓN 3: BALANCE VACACIONES LFT -->
        <div style="background: #ffffff; border: 1px solid #cbd5e1; border-radius: 10px; padding: 18px; margin-bottom: 20px;">
            <h4 style="margin: 0 0 14px 0; color: #0f172a; font-size: 15px; display: flex; align-items: center; gap: 8px; border-bottom: 1px dashed #cbd5e1; padding-bottom: 8px;">
                <i class="ph ph-sun-horizon" style="color: #ea580c;"></i> 3. Saldo de Vacaciones LFT (Artículos 76, 78 y 81)
            </h4>
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; margin-bottom: 14px; text-align: center;">
                <div style="background: #eff6ff; padding: 10px; border-radius: 8px; border: 1px solid #bfdbfe;">
                    <div style="font-size: 11px; font-weight: 700; color: #1e40af;">CORRESPONDIENTES</div>
                    <b style="font-size: 22px; color: #1d4ed8;">${vacResumen.dias_totales_correspondientes || vacResumen.dias_totales_acumulados || 0}</b> días
                </div>
                <div style="background: #fef3c7; padding: 10px; border-radius: 8px; border: 1px solid #fde68a;">
                    <div style="font-size: 11px; font-weight: 700; color: #92400e;">DISFRUTADOS</div>
                    <b style="font-size: 22px; color: #b45309;">${vacResumen.dias_tomados || 0}</b> días
                </div>
                <div style="background: #ecfdf5; padding: 10px; border-radius: 8px; border: 1px solid #a7f3d0;">
                    <div style="font-size: 11px; font-weight: 700; color: #065f46;">SALDO PENDIENTE</div>
                    <b style="font-size: 22px; color: #047857;">${vacResumen.dias_pendientes || 0}</b> días
                </div>
            </div>
            ${vacHistorial.length > 0 ? `
                <div style="max-height: 140px; overflow-y: auto; font-size: 12.5px;">
                    <table style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f1f5f9; color: #475569; text-align: left;">
                                <th style="padding: 6px;">Periodo / Motivo</th>
                                <th style="padding: 6px;">Días</th>
                                <th style="padding: 6px;">Fechas</th>
                                <th style="padding: 6px; text-align: center;">Comprobante</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${vacHistorial.map(v => `
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 6px;">${v.observaciones || `Año ${v.anio_periodo}`}</td>
                                    <td style="padding: 6px;"><b>${v.dias_tomados} día(s)</b></td>
                                    <td style="padding: 6px;">${v.fecha_inicio_goce} al ${v.fecha_fin_goce}</td>
                                    <td style="padding: 6px; text-align: center;">
                                        <button type="button" onclick="imprimirPapeletaVacacionesRH(${v.id_vacacion}, '${(emp.nombre || '').replace(/'/g, "\\'")}', '${v.fecha_inicio_goce}', '${v.fecha_fin_goce}', ${v.dias_tomados}, '${(v.observaciones || '').replace(/'/g, "\\'")}')"
                                            style="background: #f1f5f9; border: 1px solid #cbd5e1; border-radius: 4px; padding: 2px 8px; font-size: 11px; cursor: pointer;">
                                            📄 Papeleta LFT
                                        </button>
                                    </td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            ` : `<div style="font-size: 12.5px; color: #94a3b8;">Sin periodos vacacionales gozados registrados.</div>`}
        </div>

        <!-- SECCIÓN 4: PERMISOS E INCAPACIDADES -->
        <div style="background: #ffffff; border: 1px solid #cbd5e1; border-radius: 10px; padding: 18px; margin-bottom: 20px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; border-bottom: 1px dashed #cbd5e1; padding-bottom: 8px;">
                <h4 style="margin: 0; color: #0f172a; font-size: 15px; display: flex; align-items: center; gap: 8px;">
                    <i class="ph ph-clock-user" style="color: #6366f1;"></i> 4. Permisos Laborales e Incapacidades Médicas (${permisos.length + incapacidades.length})
                </h4>
            </div>
            ${(permisos.length === 0 && incapacidades.length === 0) ? `
                <div style="font-size: 12.5px; color: #94a3b8;">Sin permisos ni incapacidades médicas registradas.</div>
            ` : `
                <div style="max-height: 160px; overflow-y: auto; font-size: 12.5px;">
                    <table style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f1f5f9; color: #475569; text-align: left;">
                                <th style="padding: 6px;">Folio</th>
                                <th style="padding: 6px;">Tipo</th>
                                <th style="padding: 6px;">Motivo / Diagnóstico</th>
                                <th style="padding: 6px;">Fechas</th>
                                <th style="padding: 6px;">Días</th>
                                <th style="padding: 6px; text-align: center;">Adjunto</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${permisos.map(p => `
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 6px;"><b>${p.folio_permiso || 'PER'}</b></td>
                                    <td style="padding: 6px;"><span style="background: #eff6ff; color: #1e40af; padding: 2px 6px; border-radius: 4px; font-size: 11px;">PERMISO</span></td>
                                    <td style="padding: 6px;">${p.justificacion || '--'}</td>
                                    <td style="padding: 6px;">${p.fecha_inicio} al ${p.fecha_fin}</td>
                                    <td style="padding: 6px;">${p.dias_solicitados} d</td>
                                    <td style="padding: 6px; text-align: center;">
                                        ${p.archivo_justificante ? `
                                            <button type="button" onclick="abrirVisorDocumentoGeneral('${p.archivo_justificante.replace(/'/g, "\\'")}', 'Justificante_${p.folio_permiso}')" style="background: #0284c7; color: white; border: none; padding: 3px 8px; border-radius: 4px; font-size: 11px; cursor: pointer;">
                                                Ver
                                            </button>
                                        ` : '<span style="color:#cbd5e1;">--</span>'}
                                    </td>
                                </tr>
                            `).join('')}
                            ${incapacidades.map(i => `
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 6px;"><b>${i.folio_incapacidad || 'INC'}</b></td>
                                    <td style="padding: 6px;"><span style="background: #fee2e2; color: #991b1b; padding: 2px 6px; border-radius: 4px; font-size: 11px;">INCAPACIDAD IMSS</span></td>
                                    <td style="padding: 6px;">${i.diagnostico || i.tipo || '--'}</td>
                                    <td style="padding: 6px;">${i.fecha_inicio} al ${i.fecha_fin}</td>
                                    <td style="padding: 6px;">${i.dias_incapacidad} d</td>
                                    <td style="padding: 6px; text-align: center;">
                                        ${i.archivo_incapacidad_url ? `
                                            <button type="button" onclick="abrirVisorDocumentoGeneral('${i.archivo_incapacidad_url.replace(/'/g, "\\'")}', 'Incapacidad_${i.folio_incapacidad}')" style="background: #ef4444; color: white; border: none; padding: 3px 8px; border-radius: 4px; font-size: 11px; cursor: pointer;">
                                                Ver
                                            </button>
                                        ` : '<span style="color:#cbd5e1;">--</span>'}
                                    </td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            `}
        </div>

        <!-- SECCIÓN 5: CAPACITACIÓN Y EVALUACIONES -->
        <div style="background: #ffffff; border: 1px solid #cbd5e1; border-radius: 10px; padding: 18px; margin-bottom: 20px;">
            <h4 style="margin: 0 0 14px 0; color: #0f172a; font-size: 15px; display: flex; align-items: center; gap: 8px; border-bottom: 1px dashed #cbd5e1; padding-bottom: 8px;">
                <i class="ph ph-graduation-cap" style="color: #8b5cf6;"></i> 5. Capacitaciones Técnicas, DC-3 y Evaluaciones (${capacitaciones.length + evaluaciones.length})
            </h4>
            ${(capacitaciones.length === 0 && evaluaciones.length === 0) ? `
                <div style="font-size: 12.5px; color: #94a3b8;">Sin cursos, constancias DC-3 o evaluaciones registradas.</div>
            ` : `
                <div style="max-height: 160px; overflow-y: auto; font-size: 12.5px;">
                    <table style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f1f5f9; color: #475569; text-align: left;">
                                <th style="padding: 6px;">Concepto / Periodo</th>
                                <th style="padding: 6px;">Tipo</th>
                                <th style="padding: 6px;">Institución / Evaluador</th>
                                <th style="padding: 6px;">Resultado</th>
                                <th style="padding: 6px; text-align: center;">Constancia</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${capacitaciones.map(c => `
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 6px;"><b>${c.nombre_curso}</b></td>
                                    <td style="padding: 6px;"><span style="background: #f5f3ff; color: #6d28d9; padding: 2px 6px; border-radius: 4px; font-size: 11px;">${c.tipo}</span></td>
                                    <td style="padding: 6px;">${c.institucion || '--'}</td>
                                    <td style="padding: 6px;"><b style="color: #166534;">${c.resultado || 'APROBADO'}</b></td>
                                    <td style="padding: 6px; text-align: center;">
                                        ${c.constancia_url ? `
                                            <button type="button" onclick="abrirVisorDocumentoGeneral('${c.constancia_url.replace(/'/g, "\\'")}', 'Constancia_${c.nombre_curso}')" style="background: #8b5cf6; color: white; border: none; padding: 3px 8px; border-radius: 4px; font-size: 11px; cursor: pointer;">
                                                Ver
                                            </button>
                                        ` : '<span style="color:#cbd5e1;">--</span>'}
                                    </td>
                                </tr>
                            `).join('')}
                            ${evaluaciones.map(ev => `
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 6px;"><b>${ev.periodo}</b></td>
                                    <td style="padding: 6px;"><span style="background: #f8fafc; color: #334155; padding: 2px 6px; border-radius: 4px; font-size: 11px;">EVALUACIÓN</span></td>
                                    <td style="padding: 6px;">${ev.evaluador || '--'}</td>
                                    <td style="padding: 6px;"><b style="color: #1e40af;">${ev.calificacion_final} (${ev.nivel_desempeno})</b></td>
                                    <td style="padding: 6px; text-align: center;">
                                        ${ev.archivo_evaluacion_url ? `
                                            <button type="button" onclick="abrirVisorDocumentoGeneral('${ev.archivo_evaluacion_url.replace(/'/g, "\\'")}', 'Evaluacion_${ev.periodo}')" style="background: #0f172a; color: white; border: none; padding: 3px 8px; border-radius: 4px; font-size: 11px; cursor: pointer;">
                                                Ver
                                            </button>
                                        ` : '<span style="color:#cbd5e1;">--</span>'}
                                    </td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            `}
        </div>

        <!-- SECCIÓN 6: BÓVEDA INTEGRAL DE DOCUMENTOS DIGITALES (TODO LO QUE TENGA) -->
        <div style="background: #f8fafc; border: 1.5px solid #cbd5e1; border-radius: 12px; padding: 20px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; border-bottom: 1px dashed #cbd5e1; padding-bottom: 8px;">
                <h4 style="margin: 0; color: #0f172a; font-size: 16px; display: flex; align-items: center; gap: 8px;">
                    <i class="ph ph-folder-open" style="color: var(--accent-color);"></i>
                    <span>6. Bóveda Integral de Documentos Digitales Oficiales (${docs.length} archivos)</span>
                </h4>
                ${['ADMIN', 'COORDINADOR', 'RH'].includes(usuarioLogueado.rol) ? `
                <button type="button" onclick="cerrarExpedienteCompletoRH(); cambiarPestanaRH('documentos');" style="background: #e2e8f0; color: #1e293b; border: none; padding: 5px 12px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer;">
                    ➕ Subir Más Documentos
                </button>
                ` : ''}
            </div>
            ${docs.length === 0 ? `
                <div style="text-align: center; padding: 30px; color: #94a3b8; font-size: 13px;">
                    📁 Sin documentos digitales cargados todavía en el expediente laboral.
                </div>
            ` : `
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 14px;">
                    ${docs.map(d => {
                        const fmt = (d.formato || (d.nombre_archivo ? d.nombre_archivo.split('.').pop() : 'DOC')).toUpperCase();
                        const esPdf = fmt === 'PDF';
                        const url = d.archivo_url || '';
                        return `
                            <div style="background: white; border: 1px solid #cbd5e1; border-radius: 8px; padding: 12px 14px; display: flex; flex-direction: column; justify-content: space-between; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 8px; margin-bottom: 8px;">
                                    <div>
                                        <b style="color: #0f172a; font-size: 13px; display: block;">${d.tipo_documento || 'Documento'}</b>
                                        <span style="font-size: 11px; color: #64748b; font-family: monospace;">${d.nombre_archivo || '--'}</span>
                                    </div>
                                    <span style="background: ${esPdf ? '#fee2e2' : '#e0f2fe'}; color: ${esPdf ? '#991b1b' : '#0369a1'}; font-size: 10px; font-weight: 800; padding: 2px 6px; border-radius: 4px;">
                                        .${fmt}
                                    </span>
                                </div>
                                <div style="font-size: 11.5px; color: #64748b; margin-bottom: 10px;">
                                    ${d.fecha_vencimiento ? `Caducidad: <b>${d.fecha_vencimiento}</b>` : `Subido: <b>${String(d.fecha_subida || '').substring(0, 10) || '--'}</b>`}
                                    ${d.verificado_por_rh ? ` • <span style="color:#16a34a; font-weight:700;">✓ Verificado</span>` : ''}
                                </div>
                                <div style="display: flex; gap: 6px;">
                                    <button type="button" onclick="abrirVisorDocumentoGeneral('${url.replace(/'/g, "\\'")}', '${(d.tipo_documento || 'Documento').replace(/'/g, "\\'")}')"
                                        style="flex: 1; background: #0284c7; color: white; border: none; padding: 6px; border-radius: 5px; font-size: 12px; font-weight: 600; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 4px;">
                                        <i class="ph ph-eye"></i> Ver
                                    </button>
                                    <a href="${url}" download="${d.nombre_archivo || 'documento'}"
                                        style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 6px 10px; border-radius: 5px; font-size: 12px; text-decoration: none; display: flex; align-items: center; justify-content: center;"
                                        title="Descargar archivo original">
                                        <i class="ph ph-download-simple"></i>
                                    </a>
                                </div>
                            </div>
                        `;
                    }).join('')}
                </div>
            `}
        </div>
    `;

    contenedor.innerHTML = html;
}

function imprimirExpedienteCompletoRH() {
    if (!datosExpedienteCompletoActual) {
        alert("⚠️ No hay datos cargados del expediente.");
        return;
    }

    const emp = datosExpedienteCompletoActual.exp.datos_personales || {};
    const win = window.open("", "_blank");
    if (!win) {
        alert("⚠️ Permite las ventanas emergentes en tu navegador para imprimir el expediente.");
        return;
    }

    const contenido = document.getElementById("exp-completo-contenido")?.innerHTML || "";

    win.document.write(`
        <!DOCTYPE html>
        <html lang="es">
        <head>
            <meta charset="UTF-8">
            <title>Expediente Laboral Digital - ${emp.nombre || 'Empleado'}</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 30px; color: #0f172a; line-height: 1.5; font-size: 13px; }
                h2, h3, h4 { margin-top: 0; color: #0f172a; }
                .btn-print { background: #0284c7; color: white; border: none; padding: 10px 20px; border-radius: 6px; font-weight: 700; cursor: pointer; margin-bottom: 20px; }
                table { width: 100%; border-collapse: collapse; margin-bottom: 14px; }
                th, td { border: 1px solid #cbd5e1; padding: 6px 10px; font-size: 12px; }
                th { background: #f1f5f9; }
                button { display: none !important; }
                @media print { .btn-print { display: none; } body { margin: 0; } }
            </style>
        </head>
        <body>
            <div style="text-align: center;">
                <button class="btn-print" onclick="window.print()">🖨️ Imprimir Expediente Integral</button>
            </div>
            <div style="text-align: center; border-bottom: 2px solid #0f172a; padding-bottom: 12px; margin-bottom: 20px;">
                <h2 style="margin: 0;">VPRO STREAMING SERVICES S.A. DE C.V.</h2>
                <h4 style="margin: 4px 0 0 0; color: #64748b;">EXPEDIENTE DIGITAL INTEGRAL Y AUDITORÍA DE PERSONAL</h4>
            </div>
            ${contenido}
        </body>
        </html>
    `);
    win.document.close();
}
// ==========================================
// 8. SISTEMA DE AUDIO PROGRAMADO (AUDÍFONOS AMIGABLES)
// ==========================================
let audioCtx = null;
let ultimoAlarmaDisparada = "";

// Inicializa o reanuda el contexto de audio tras interacción
function obtenerAudioContext() {
    if (!audioCtx) {
        const AudioContextClass = window.AudioContext || window.webkitAudioContext;
        audioCtx = new AudioContextClass();
    }
    if (audioCtx.state === 'suspended') {
        audioCtx.resume();
    }
    return audioCtx;
}

// Genera una nota senoidal suave con ataque y decaimiento
function tocarNota(frecuencia, tiempoInicio, duracion, volumenMax = 0.25) {
    const ctx = obtenerAudioContext();
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();

    osc.type = 'sine'; // Onda senoidal: la más pura y suave al oído
    osc.frequency.setValueAtTime(frecuencia, tiempoInicio);

    // Curva de volumen: Fade-in suave (anti-pop) y Fade-out gradual
    gain.gain.setValueAtTime(0.0001, tiempoInicio);
    gain.gain.exponentialRampToValueAtTime(volumenMax, tiempoInicio + 0.04);
    gain.gain.exponentialRampToValueAtTime(0.0001, tiempoInicio + duracion);

    osc.connect(gain);
    gain.connect(ctx.destination);

    osc.start(tiempoInicio);
    osc.stop(tiempoInicio + duracion);
}

// 🟢 SONIDO DE ENTRADA (09:00 y 16:00) - Arpegio ascendente limpio
function sonarEntrada() {
    const ctx = obtenerAudioContext();
    const ahora = ctx.currentTime;
    // Tono 1 (ENTRADA): Campanada Brillante y Energética (5 segundos)
    tocarNota(523.25, ahora, 5.0, 0.5); // C5 (Fundamental)
    tocarNota(880.00, ahora, 4.5, 0.2); // A5 (Armónico)
    tocarNota(1046.50, ahora, 4.0, 0.15); // C6 (Brillo)
}

// 🔴 SONIDO DE SALIDA (14:00 y 19:00) - Acorde relajante de descanso
function sonarSalida() {
    const ctx = obtenerAudioContext();
    const ahora = ctx.currentTime;
    // Tono 2 (SALIDA): Campanada Grave y Relajante (5 segundos)
    tocarNota(349.23, ahora, 5.0, 0.5); // F4 (Fundamental grave)
    tocarNota(440.00, ahora, 4.5, 0.2); // A4 (Armónico)
    tocarNota(698.46, ahora, 4.0, 0.15); // F5 (Brillo suave)
}

// ⏱️ VIGILANTE DE HORARIOS (Checa cada segundo)
function verificarHorariosCampana() {
    const ahora = new Date();
    // Formato 'HH:MM' (ejemplo: '09:00', '14:00')
    const horaActual = ahora.toLocaleTimeString('es-MX', { 
        hour: '2-digit', 
        minute: '2-digit', 
        hour12: false 
    });

    // Si cambió el minuto y es una de las 4 horas clave
    if (horaActual !== ultimoAlarmaDisparada) {
        if (horaActual === "09:00" || horaActual === "16:00") {
            ultimoAlarmaDisparada = horaActual;
            sonarEntrada();
            console.log(`🔔 Sonido de ENTRADA ejecutado a las ${horaActual}`);
        } else if (horaActual === "14:00" || horaActual === "19:00") {
            ultimoAlarmaDisparada = horaActual;
            sonarSalida();
            console.log(`🔔 Sonido de SALIDA ejecutado a las ${horaActual}`);
        }
    }
}
// ==========================================
// 🔊 DICCIONARIO DE NOMBRES CORTOS Y SALUDO POR VOZ
// ==========================================
const NOMBRES_CORTOS = {
    "101": "Señora Ana Lilia",
    "102": "Gerardo",
    "104": "Paco",
    "105": "Dany",
    "107": "Geo",
    "109": "Osiel",
    "113": "Carlos",
    "115": "Ibón",
    "119": "Manny",
    "121": "Sofía",
    "122": "Andrea",
    "124": "Manuel",                // Manuel Eduardo (Coordinador)
    "125": "Diego",
    "200": "Licenciada Andrea",
    "201": "Cuauhtémoc",
    "202": "Amarillas",
    "203": "Señor Pedro Villarreal"
};

function decirSaludoKiosco(idEmpleado = "", nombreCompleto = "") {
    if (!('speechSynthesis' in window)) return;

    const idLimpio = String(idEmpleado).trim();
    let sujeto = "";

    // 1. Prioridad: Nombre corto / preferido de la lista
    if (NOMBRES_CORTOS[idLimpio]) {
        sujeto = NOMBRES_CORTOS[idLimpio];
    } 
    // 2. Si es alguien nuevo que no está en la lista, toma su primer nombre
    else if (nombreCompleto) {
        sujeto = nombreCompleto.trim().split(' ')[0];
    }

    // 3. Saludo cordial según la hora del día
    const hora = new Date().getHours();
    let saludo = "Hola";
    if (hora >= 5 && hora < 12) {
        saludo = "Buenos días";
    } else if (hora >= 12 && hora < 19) {
        saludo = "Buenas tardes";
    } else {
        saludo = "Buenas noches";
    }

    // Armamos la frase completa
    const mensajeVoz = sujeto ? `${saludo}, ${sujeto}.` : `${saludo}.`;

    const locucion = new SpeechSynthesisUtterance(mensajeVoz);
    locucion.lang = 'es-MX';  // Voz en español latino / México
    locucion.rate = 0.95;     // Ritmo natural pausado
    locucion.pitch = 1.0;     // Tono medio cálido
    locucion.volume = 0.80;   // Nivel cómodo para audífonos

    // Evita encimar voces si pasan varios rápido
    window.speechSynthesis.cancel();
    window.speechSynthesis.speak(locucion);
}

// ==========================================
// 📦 MÓDULO VPRO TRANSFER (COMPARTIR ARCHIVOS HASTA 5GB CON BORRADO EN 7H POST-DESCARGA)
// ==========================================
let archivosTransferenciaSeleccionados = [];
let peticionSubidaXHR = null;

function cambiarPestanaTransferencias(pestana) {
    const subvistas = {
        'enviar': document.getElementById('subvista-transfer-enviar'),
        'recibidos': document.getElementById('subvista-transfer-recibidos'),
        'enviados': document.getElementById('subvista-transfer-enviados'),
        'historial': document.getElementById('subvista-transfer-historial')
    };
    const botones = {
        'enviar': document.getElementById('tab-transfer-btn-enviar'),
        'recibidos': document.getElementById('tab-transfer-btn-recibidos'),
        'enviados': document.getElementById('tab-transfer-btn-enviados'),
        'historial': document.getElementById('tab-transfer-btn-historial')
    };

    Object.keys(subvistas).forEach(k => {
        if (subvistas[k]) subvistas[k].style.display = (k === pestana) ? 'block' : 'none';
        if (botones[k]) {
            if (k === pestana) {
                botones[k].style.background = '#0f172a';
                botones[k].style.color = '#ffffff';
                botones[k].style.border = 'none';
            } else {
                botones[k].style.background = '#f1f5f9';
                botones[k].style.color = '#475569';
                botones[k].style.border = '1px solid #cbd5e1';
            }
        }
    });

    if (pestana === 'recibidos') {
        cargarTransferenciasRecibidos();
    } else if (pestana === 'enviados') {
        cargarTransferenciasEnviados();
    } else if (pestana === 'historial') {
        cargarHistorialTransferencias();
    }
}

async function cargarTransferenciasModulo() {
    if (!usuarioLogueado) return;
    
    // Configurar Dropzone Drag & Drop
    const dropzone = document.getElementById("transfer-dropzone");
    if (dropzone && !dropzone.dataset.dragInit) {
        dropzone.dataset.dragInit = "true";
        dropzone.addEventListener("dragover", (e) => {
            e.preventDefault();
            dropzone.style.borderColor = "var(--accent-color)";
            dropzone.style.background = "#eef2ff";
        });
        dropzone.addEventListener("dragleave", (e) => {
            e.preventDefault();
            dropzone.style.borderColor = "#94a3b8";
            dropzone.style.background = "#f8fafc";
        });
        dropzone.addEventListener("drop", (e) => {
            e.preventDefault();
            dropzone.style.borderColor = "#94a3b8";
            dropzone.style.background = "#f8fafc";
            if (e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files.length > 0) {
                procesarNuevosArchivosTransferencia(e.dataTransfer.files);
            }
        });
    }

    // Cargar selector de empleados activos (excluyendo al usuario actual)
    const selectDestino = document.getElementById("transfer-select-destino");
    if (selectDestino) {
        try {
            // Intentar primero el endpoint directo de destinatarios para transferencias
            let res = await fetch(`${API_URL}/api/transferencias/destinatarios`);
            if (!res.ok) {
                // Fallback al endpoint general de empleados
                res = await fetch(`${API_URL}/api/empleados`);
            }
            if (res.ok) {
                const empleados = await res.json();
                const actual = selectDestino.value;
                selectDestino.innerHTML = '<option value="">-- Selecciona un colaborador activo --</option>' + 
                    empleados
                        .map(e => {
                            const esUsuarioActual = String(e.id_empleado).trim() === String(usuarioLogueado.id_empleado).trim();
                            const textoNombre = esUsuarioActual ? `${e.nombre} (Tú / Guardar aquí)` : e.nombre;
                            return `<option value="${e.id_empleado}" data-nombre="${e.nombre}">${textoNombre} (${e.depto || 'General'} - ID ${e.id_empleado})</option>`;
                        })
                        .join("");
                if (actual) selectDestino.value = actual;
            }
        } catch (e) {
            console.error("Error al cargar empleados para transferencia:", e);
        }
    }

    cargarTransferenciasRecibidos();
    cargarTransferenciasEnviados();
    cargarBadges();
}

function formatearTamanoBytes(bytes) {
    if (bytes < 1024 * 1024) {
        return (bytes / 1024).toFixed(1) + " KB";
    } else if (bytes < 1024 * 1024 * 1024) {
        return (bytes / (1024 * 1024)).toFixed(1) + " MB";
    } else {
        return (bytes / (1024 * 1024 * 1024)).toFixed(2) + " GB";
    }
}

function alSeleccionarArchivosTransferencia(input) {
    if (!input.files || input.files.length === 0) return;
    procesarNuevosArchivosTransferencia(input.files);
    input.value = ""; // Permite seleccionar los mismos archivos o más después
}

function procesarNuevosArchivosTransferencia(fileList) {
    const LIMITE_5GB = 5 * 1024 * 1024 * 1024; // 5 GB
    let totalActual = archivosTransferenciaSeleccionados.reduce((acc, f) => acc + f.size, 0);

    for (let i = 0; i < fileList.length; i++) {
        const file = fileList[i];
        if (totalActual + file.size > LIMITE_5GB) {
            alert(`⚠️ No se pudo agregar "${file.name}".\nEl tamaño combinado superaría el límite de 5.0 GB.\nTamaño actual acumulado: ${formatearTamanoBytes(totalActual)}.`);
            break;
        }
        // Evitar duplicados por nombre y tamaño exacto
        const yaExiste = archivosTransferenciaSeleccionados.some(f => f.name === file.name && f.size === file.size);
        if (!yaExiste) {
            archivosTransferenciaSeleccionados.push(file);
            totalActual += file.size;
        }
    }

    renderizarListaArchivosSeleccionados();
}

function quitarArchivoDeTransferencia(indice) {
    if (indice >= 0 && indice < archivosTransferenciaSeleccionados.length) {
        archivosTransferenciaSeleccionados.splice(indice, 1);
        renderizarListaArchivosSeleccionados();
    }
}

function limpiarArchivosTransferencia() {
    archivosTransferenciaSeleccionados = [];
    const input = document.getElementById("transfer-input-file");
    if (input) input.value = "";
    renderizarListaArchivosSeleccionados();
}

function renderizarListaArchivosSeleccionados() {
    const box = document.getElementById("transfer-archivos-seleccionados-box");
    const container = document.getElementById("transfer-lista-archivos-items");
    const lblTotal = document.getElementById("transfer-total-archivos-lbl");
    const lblPeso = document.getElementById("transfer-total-peso-lbl");

    if (!box || !container) return;

    if (archivosTransferenciaSeleccionados.length === 0) {
        box.style.display = "none";
        container.innerHTML = "";
        if (lblTotal) lblTotal.innerText = "0";
        if (lblPeso) lblPeso.innerText = "0 MB";
        return;
    }

    const totalBytes = archivosTransferenciaSeleccionados.reduce((acc, f) => acc + f.size, 0);
    if (lblTotal) lblTotal.innerText = archivosTransferenciaSeleccionados.length;
    if (lblPeso) lblPeso.innerText = formatearTamanoBytes(totalBytes);

    container.innerHTML = archivosTransferenciaSeleccionados.map((f, idx) => {
        let icono = "ph-file";
        const n = f.name.toLowerCase();
        if (n.endsWith(".mp4") || n.endsWith(".mov") || n.endsWith(".mkv") || n.endsWith(".avi")) icono = "ph-video";
        else if (n.endsWith(".jpg") || n.endsWith(".jpeg") || n.endsWith(".png") || n.endsWith(".webp")) icono = "ph-image";
        else if (n.endsWith(".zip") || n.endsWith(".rar") || n.endsWith(".7z") || n.endsWith(".tar")) icono = "ph-archive";
        else if (n.endsWith(".pdf")) icono = "ph-file-pdf";
        else if (n.endsWith(".xlsx") || n.endsWith(".xls") || n.endsWith(".csv")) icono = "ph-file-xls";

        return `
            <div style="display: flex; align-items: center; justify-content: space-between; background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 8px 12px; gap: 10px;">
                <div style="display: flex; align-items: center; gap: 10px; overflow: hidden; flex: 1;">
                    <i class="ph ${icono}" style="font-size: 20px; color: var(--accent-color); flex-shrink: 0;"></i>
                    <span style="font-weight: 600; font-size: 13px; color: #1e293b; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${f.name}">${f.name}</span>
                    <span style="background: #f1f5f9; color: #475569; padding: 2px 6px; border-radius: 4px; font-size: 11px; font-weight: 600; flex-shrink: 0;">${formatearTamanoBytes(f.size)}</span>
                </div>
                <button type="button" onclick="quitarArchivoDeTransferencia(${idx})" style="background: none; border: none; color: #ef4444; cursor: pointer; padding: 4px; border-radius: 4px; display: flex; align-items: center;" title="Quitar archivo">
                    <i class="ph ph-trash" style="font-size: 16px;"></i>
                </button>
            </div>
        `;
    }).join("");

    box.style.display = "block";
}

// Compatibilidad con llamada singular y plural
function enviarTransferenciaArchivo() {
    enviarTransferenciaArchivos();
}

function enviarTransferenciaArchivos() {
    if (!usuarioLogueado) {
        alert("Debes iniciar sesión para transferir archivos.");
        return;
    }

    const selectDestino = document.getElementById("transfer-select-destino");
    if (!selectDestino || !selectDestino.value) {
        alert("Por favor selecciona al empleado destinatario que recibirá el archivo.");
        return;
    }

    if (archivosTransferenciaSeleccionados.length === 0) {
        alert("Por favor selecciona o arrastra al menos un archivo para transferir (máximo 5.0 GB).");
        return;
    }

    const optionSel = selectDestino.options[selectDestino.selectedIndex];
    const nombreDestino = optionSel ? (optionSel.getAttribute("data-nombre") || optionSel.text) : "Destinatario";
    const mensaje = document.getElementById("transfer-input-mensaje")?.value || "";

    const formData = new FormData();
    formData.append("id_empleado_origen", usuarioLogueado.id_empleado);
    formData.append("nombre_origen", usuarioLogueado.nombre_completo);
    formData.append("id_empleado_destino", selectDestino.value);
    formData.append("nombre_destino", nombreDestino);
    formData.append("mensaje", mensaje);

    // Adjuntar todos los archivos
    archivosTransferenciaSeleccionados.forEach(f => {
        formData.append("files", f);
    });

    const btnEnviar = document.getElementById("btn-enviar-transferencia");
    const progresoBox = document.getElementById("transfer-progreso-box");
    const barraProgreso = document.getElementById("transfer-progreso-barra");
    const textoPorcentaje = document.getElementById("transfer-progreso-porcentaje");
    const textoDetalle = document.getElementById("transfer-progreso-detalle");
    const textoProgreso = document.getElementById("transfer-progreso-texto");

    if (btnEnviar) {
        btnEnviar.disabled = true;
        btnEnviar.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Subiendo archivos...`;
    }
    if (progresoBox) progresoBox.style.display = "block";
    if (barraProgreso) barraProgreso.style.width = "0%";
    if (textoPorcentaje) textoPorcentaje.innerText = "0%";

    const xhr = new XMLHttpRequest();
    peticionSubidaXHR = xhr;

    xhr.upload.onprogress = function(e) {
        if (e.lengthComputable) {
            const porcentaje = Math.round((e.loaded / e.total) * 100);
            if (barraProgreso) barraProgreso.style.width = porcentaje + "%";
            if (textoPorcentaje) textoPorcentaje.innerText = porcentaje + "%";
            
            const subidoMB = (e.loaded / (1024 * 1024)).toFixed(1);
            const totalMB = (e.total / (1024 * 1024)).toFixed(1);
            if (textoDetalle) {
                if (e.total >= 1024 * 1024 * 1024) {
                    const subidoGB = (e.loaded / (1024 * 1024 * 1024)).toFixed(2);
                    const totalGB = (e.total / (1024 * 1024 * 1024)).toFixed(2);
                    textoDetalle.innerText = `${subidoGB} GB / ${totalGB} GB`;
                } else {
                    textoDetalle.innerText = `${subidoMB} MB / ${totalMB} MB`;
                }
            }
            if (textoProgreso) {
                textoProgreso.innerText = (porcentaje >= 100) 
                    ? "Procesando y registrando en servidor..." 
                    : `Subiendo archivo(s): ${porcentaje}%`;
            }
        }
    };

    xhr.onload = function() {
        if (btnEnviar) {
            btnEnviar.disabled = false;
            btnEnviar.innerHTML = `<i class="ph ph-paper-plane-tilt"></i> Enviar Archivo(s)`;
        }
        if (xhr.status === 200) {
            try {
                const res = JSON.parse(xhr.responseText);
                const descArchivos = res.total_archivos > 1 ? `${res.total_archivos} archivos (${res.tamano_total})` : `"${res.nombre_archivo || 'archivo'}" (${res.tamano_total || res.tamano})`;
                alert(`✅ Transferencia enviada con éxito!\n\nSe envió ${descArchivos} a ${res.destinatario}.\nEl destinatario ya puede ver la notificación para descargarlo.`);
                
                // Limpiar formulario
                limpiarArchivosTransferencia();
                if (document.getElementById("transfer-input-mensaje")) {
                    document.getElementById("transfer-input-mensaje").value = "";
                }
                if (progresoBox) progresoBox.style.display = "none";

                // Cambiar a pestaña de Enviados
                cambiarPestanaTransferencias("enviados");
            } catch (err) {
                alert("Transferencia completada correctamente.");
                limpiarArchivosTransferencia();
                if (progresoBox) progresoBox.style.display = "none";
                cambiarPestanaTransferencias("enviados");
            }
        } else {
            let errorMsg = "Error al subir archivos.";
            try {
                const errObj = JSON.parse(xhr.responseText);
                errorMsg = errObj.detail || errorMsg;
            } catch (_) {}
            alert("❌ " + errorMsg);
            if (progresoBox) progresoBox.style.display = "none";
        }
    };

    xhr.onerror = function() {
        if (btnEnviar) {
            btnEnviar.disabled = false;
            btnEnviar.innerHTML = `<i class="ph ph-paper-plane-tilt"></i> Enviar Archivo(s)`;
        }
        if (progresoBox) progresoBox.style.display = "none";
        alert("❌ Error de conexión al intentar subir los archivos.");
    };

    xhr.open("POST", `${API_URL}/api/transferencias/subir`, true);
    xhr.send(formData);
}

async function cargarTransferenciasRecibidos() {
    if (!usuarioLogueado) return;
    const tbody = document.getElementById("tabla-transfer-recibidos-body");
    if (!tbody) return;

    try {
        const res = await fetch(`${API_URL}/api/transferencias/recibidos/${usuarioLogueado.id_empleado}`);
        if (!res.ok) {
            tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #ef4444; padding: 24px;">Error al consultar archivos recibidos.</td></tr>';
            return;
        }

        const recibidos = await res.json();
        const badgeCount = document.getElementById("badge-transfer-recibidos-count");
        const noDescargados = recibidos.filter(r => !r.descargado);
        if (badgeCount) {
            if (noDescargados.length > 0) {
                badgeCount.innerText = noDescargados.length;
                badgeCount.style.display = "inline-block";
            } else {
                badgeCount.style.display = "none";
            }
        }

        if (!recibidos || recibidos.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #94a3b8; padding: 32px;">📭 No tienes archivos compartidos recibidos por el momento.</td></tr>';
            return;
        }

        tbody.innerHTML = recibidos.map(item => {
            let estatusBadge = "";
            let btnDescarga = "";

            if (!item.descargado) {
                estatusBadge = `
                    <span style="background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; padding: 4px 10px; border-radius: 6px; font-weight: 700; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;">
                        <i class="ph ph-sparkle"></i> Nuevo (Sin descargar)
                    </span>
                    <div style="font-size: 11px; color: #64748b; margin-top: 3px;">Se iniciará cuenta de 7h al descargar</div>
                `;
                btnDescarga = `
                    <div style="display: flex; gap: 6px; justify-content: center; flex-wrap: wrap;">
                        <button onclick="descargarArchivoTransferenciaDirecto(${item.id_transferencia}, '${(item.nombre_archivo_original || '').replace(/'/g, "\\'")}')" style="background: #2563eb; color: white; border: none; padding: 8px 14px; border-radius: 6px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; font-size: 13px;">
                            <i class="ph ph-download-simple"></i> Descargar
                        </button>
                        ${item.folio_paquete ? `
                        <button onclick="descargarPaqueteZip('${item.folio_paquete}')" style="background: #0284c7; color: white; border: none; padding: 8px 10px; border-radius: 6px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; font-size: 12px;" title="Descargar paquete completo en ZIP">
                            <i class="ph ph-file-zip"></i> ZIP Paquete
                        </button>` : ''}
                    </div>
                `;
            } else {
                estatusBadge = `
                    <span style="background: #fffbeb; color: #b45309; border: 1px solid #fde68a; padding: 4px 10px; border-radius: 6px; font-weight: 700; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;">
                        <i class="ph ph-clock-countdown"></i> ${item.tiempo_restante_texto}
                    </span>
                    <div style="font-size: 11px; color: #d97706; margin-top: 3px;">Descargado ${item.veces_descargado || 1} vez(ces)</div>
                `;
                btnDescarga = `
                    <div style="display: flex; gap: 6px; justify-content: center; flex-wrap: wrap;">
                        <button onclick="descargarArchivoTransferenciaDirecto(${item.id_transferencia}, '${(item.nombre_archivo_original || '').replace(/'/g, "\\'")}')" style="background: #0284c7; color: white; border: none; padding: 7px 12px; border-radius: 6px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; font-size: 12px;">
                            <i class="ph ph-arrow-counter-clockwise"></i> Re-descargar
                        </button>
                        ${item.folio_paquete ? `
                        <button onclick="descargarPaqueteZip('${item.folio_paquete}')" style="background: #475569; color: white; border: none; padding: 7px 10px; border-radius: 6px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; font-size: 11.5px;" title="Descargar paquete completo en ZIP">
                            <i class="ph ph-file-zip"></i> ZIP
                        </button>` : ''}
                    </div>
                `;
            }

            return `
                <tr>
                    <td style="font-weight: 600; color: #0f172a;">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <div style="width: 32px; height: 32px; border-radius: 50%; background: #e0e7ff; color: #4338ca; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 12px;">
                                ${(item.nombre_origen || 'U').charAt(0).toUpperCase()}
                            </div>
                            <div>
                                <div>${item.nombre_origen}</div>
                                <span style="font-size: 11px; color: #64748b;">ID: ${item.id_empleado_origen}</span>
                            </div>
                        </div>
                    </td>
                    <td style="font-weight: 600; color: #1e3a8a; max-width: 250px; word-break: break-all;">
                        <i class="ph ph-file-text" style="color: #3b82f6; margin-right: 4px;"></i>
                        ${item.nombre_archivo_original}
                        ${item.folio_paquete ? `<div style="font-size: 10.5px; color: #6366f1; font-weight: 500;"><i class="ph ph-package"></i> Paquete: ${item.folio_paquete}</div>` : ''}
                    </td>
                    <td style="white-space: nowrap;"><span style="background: #f1f5f9; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: 600; color: #334155;">${item.tamano_legible}</span></td>
                    <td style="font-size: 12.5px; color: #475569; white-space: nowrap;">${item.fecha_subida_str || ''}</td>
                    <td style="font-size: 12.5px; color: #475569; max-width: 220px;">${item.mensaje ? `"${item.mensaje}"` : '<span style="color:#cbd5e1;">Sin notas</span>'}</td>
                    <td>${estatusBadge}</td>
                    <td style="text-align: center; white-space: nowrap;">${btnDescarga}</td>
                </tr>
            `;
        }).join("");

    } catch (e) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #ef4444; padding: 24px;">Error al cargar archivos recibidos.</td></tr>';
    }
}

async function cargarTransferenciasEnviados() {
    if (!usuarioLogueado) return;
    const tbody = document.getElementById("tabla-transfer-enviados-body");
    if (!tbody) return;

    try {
        const res = await fetch(`${API_URL}/api/transferencias/enviados/${usuarioLogueado.id_empleado}`);
        if (!res.ok) {
            tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #ef4444; padding: 24px;">Error al consultar archivos enviados.</td></tr>';
            return;
        }

        const enviados = await res.json();
        if (!enviados || enviados.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #94a3b8; padding: 32px;">No has enviado archivos recientemente.</td></tr>';
            return;
        }

        tbody.innerHTML = enviados.map(item => {
            const puedeEliminar = item.estatus !== 'EXPIRADO_BORRADO' && item.estatus !== 'CANCELADO';
            const btnAccion = puedeEliminar ? `
                <button onclick="eliminarTransferencia(${item.id_transferencia})" style="background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; padding: 5px 12px; border-radius: 6px; font-weight: 600; cursor: pointer; font-size: 12px;" title="Eliminar archivo del servidor">
                    <i class="ph ph-trash"></i> Cancelar / Borrar
                </button>
            ` : `<span style="font-size: 12px; color: #94a3b8;">Finalizado</span>`;

            return `
                <tr>
                    <td style="font-weight: 600; color: #0f172a;">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <div style="width: 32px; height: 32px; border-radius: 50%; background: #f1f5f9; color: #475569; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 12px;">
                                ${(item.nombre_destino || 'U').charAt(0).toUpperCase()}
                            </div>
                            <div>
                                <div>${item.nombre_destino}</div>
                                <span style="font-size: 11px; color: #64748b;">ID: ${item.id_empleado_destino}</span>
                            </div>
                        </div>
                    </td>
                    <td style="font-weight: 600; color: #1e3a8a; max-width: 250px; word-break: break-all;">
                        <i class="ph ph-file" style="color: #64748b; margin-right: 4px;"></i>
                        ${item.nombre_archivo_original}
                        ${item.folio_paquete ? `<div style="font-size: 10.5px; color: #6366f1; font-weight: 500;"><i class="ph ph-package"></i> Paquete: ${item.folio_paquete}</div>` : ''}
                    </td>
                    <td style="white-space: nowrap;"><span style="background: #f1f5f9; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: 600; color: #334155;">${item.tamano_legible}</span></td>
                    <td style="font-size: 12.5px; color: #475569; white-space: nowrap;">${item.fecha_subida_str || ''}</td>
                    <td style="font-size: 12.5px; color: #475569; max-width: 220px;">${item.mensaje ? `"${item.mensaje}"` : '<span style="color:#cbd5e1;">Sin notas</span>'}</td>
                    <td>
                        <span style="font-size: 12.5px; font-weight: 600; color: #334155;">
                            ${item.estado_display}
                        </span>
                    </td>
                    <td style="text-align: center; white-space: nowrap;">${btnAccion}</td>
                </tr>
            `;
        }).join("");

    } catch (e) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #ef4444; padding: 24px;">Error al cargar archivos enviados.</td></tr>';
    }
}

function descargarPaqueteZip(folioPaquete) {
    if (!folioPaquete) return;
    const urlDescarga = `${API_URL}/api/transferencias/descargar_paquete/${folioPaquete}`;
    
    const a = document.createElement("a");
    a.href = urlDescarga;
    a.setAttribute("download", `paquete_${folioPaquete}.zip`);
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);

    setTimeout(() => {
        alert(`📥 Tu descarga del paquete ZIP ha comenzado.\n\n⚠️ RECUERDA: Todos los archivos de este paquete permanecerán disponibles en el servidor por 7 horas a partir de este momento. Después de ese lapso, el sistema los borrará automáticamente.`);
        cargarTransferenciasRecibidos();
        cargarDatosInicio();
        cargarBadges();
    }, 800);
}

function descargarArchivoTransferenciaDirecto(idTransferencia, nombreArchivo = "") {
    const urlDescarga = `${API_URL}/api/transferencias/descargar/${idTransferencia}`;
    
    const a = document.createElement("a");
    a.href = urlDescarga;
    a.setAttribute("download", nombreArchivo || "archivo");
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);

    setTimeout(() => {
        alert(`📥 Tu descarga ha comenzado.\n\n⚠️ RECUERDA: Este archivo permanecerá disponible en el servidor por 7 horas a partir de este momento. Después de ese lapso, el sistema lo borrará automáticamente para mantener limpio el almacenamiento.`);
        cargarTransferenciasRecibidos();
        cargarDatosInicio();
        cargarBadges();
    }, 800);
}

async function eliminarTransferencia(idTransferencia) {
    if (!confirm("¿Deseas cancelar esta transferencia y borrar el archivo físico del servidor ahora mismo?")) {
        return;
    }
    try {
        const res = await fetch(`${API_URL}/api/transferencias/eliminar/${idTransferencia}`, {
            method: 'DELETE'
        });
        if (res.ok) {
            cargarTransferenciasEnviados();
            cargarTransferenciasRecibidos();
            cargarDatosInicio();
            cargarBadges();
        } else {
            alert("No se pudo eliminar la transferencia.");
        }
    } catch (e) {
        alert("Error de conexión al eliminar transferencia.");
    }
}

async function cargarHistorialTransferencias() {
    if (!usuarioLogueado) return;
    const tbody = document.getElementById("tabla-transfer-historial-body");
    if (!tbody) return;

    try {
        const res = await fetch(`${API_URL}/api/transferencias/historial/${usuarioLogueado.id_empleado}`);
        if (!res.ok) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #ef4444; padding: 24px;">Error al consultar el historial.</td></tr>';
            return;
        }

        const historial = await res.json();
        if (!historial || historial.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #94a3b8; padding: 32px;">No hay historial de transferencias.</td></tr>';
            return;
        }

        tbody.innerHTML = historial.map(item => {
            const esEnvio = item.tipo === 'ENVIADO';
            const iconoTipo = esEnvio ? '<i class="ph ph-arrow-up-right" style="color: #10b981;"></i>' : '<i class="ph ph-arrow-down-left" style="color: #3b82f6;"></i>';
            const colorTipo = esEnvio ? '#10b981' : '#3b82f6';
            const dePara = esEnvio ? `Para: ${item.nombre_destino}` : `De: ${item.nombre_origen}`;
            const infoRed = item.red_info === 'LAN' ? '<span style="background: #dcfce7; color: #166534; padding: 2px 6px; border-radius: 4px; font-size: 11px; font-weight: bold;">LAN</span>' : '<span style="background: #fef08a; color: #854d0e; padding: 2px 6px; border-radius: 4px; font-size: 11px; font-weight: bold;">EXTERNO</span>';

            return `
                <tr>
                    <td style="font-weight: 600; color: ${colorTipo}; font-size: 13px;">
                        ${iconoTipo} ${item.tipo}
                    </td>
                    <td style="font-weight: 600; color: #0f172a; font-size: 13px;">
                        ${dePara}
                    </td>
                    <td style="font-weight: 600; color: #1e3a8a; max-width: 250px; word-break: break-all; font-size: 13px;">
                        <i class="ph ph-file" style="color: #64748b; margin-right: 4px;"></i>
                        ${item.nombre_archivo_original}
                    </td>
                    <td style="white-space: nowrap;"><span style="background: #f1f5f9; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: 600; color: #334155;">${item.tamano_legible}</span></td>
                    <td style="font-size: 12.5px; color: #475569; white-space: nowrap;">${item.fecha_subida_str || ''}</td>
                    <td style="text-align: center;">${infoRed}</td>
                </tr>
            `;
        }).join("");

    } catch (e) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #ef4444; padding: 24px;">Error al cargar el historial.</td></tr>';
    }
}

// ==========================================
// MÓDULO DE COTIZACIONES (VPF-PSC-COT)
// ==========================================
let clientesCotizacion = [];

async function inicializarModuloCotizaciones() {
    // 1. Cargar catálogo de clientes
    try {
        const res = await fetch(`${API_URL}/api/clientes/catalogo`);
        if (res.ok) {
            clientesCotizacion = await res.json();
            const selectCliente = document.getElementById("cot-cliente");
            if (selectCliente) {
                selectCliente.innerHTML = '<option value="">--- Selecciona un Cliente ---</option>' + 
                    clientesCotizacion.map(c => `<option value="${c}">${c}</option>`).join("");
            }
        }
    } catch (e) {
        console.error("Error al cargar clientes:", e);
    }

    // 2. Fecha por defecto (hoy)
    document.getElementById("cot-fecha").valueAsDate = new Date();

    // 3. Inicializar con una fila vacía
    document.getElementById("cot-tabla-body").innerHTML = "";
    agregarFilaCotizacion();
}

async function cargarContactosCotizacion() {
    const nombreCliente = document.getElementById("cot-cliente").value;
    const selectContacto = document.getElementById("cot-contacto");
    
    // Si no hay contacto select (quizas no está en el HTML) ignoramos
    if (!selectContacto) return;

    selectContacto.innerHTML = '<option value="">--- Selecciona un Contacto ---</option>';
    
    if (!nombreCliente) return;

    try {
        const res = await fetch(`${API_URL}/api/clientes/contactos/${encodeURIComponent(nombreCliente)}`);
        if (res.ok) {
            const contactos = await res.json();
            if (contactos.length > 0) {
                selectContacto.innerHTML += contactos.map(c => `<option value="${c}">${c}</option>`).join("");
            }
        }
    } catch (e) {
        console.error("Error al cargar contactos:", e);
    }
}

function agregarFilaCotizacion() {
    const tbody = document.getElementById("cot-tabla-body");
    const tr = document.createElement("tr");
    tr.className = "fila-cot";
    tr.innerHTML = `
        <td><input type="number" class="form-input cot-cant" style="text-align: center; font-size: 13px;" value="1" min="1" onchange="calcularTotalesCotizacion()" onkeyup="calcularTotalesCotizacion()"></td>
        <td><input type="text" class="form-input cot-desc" style="font-size: 13px;" placeholder="Descripción del servicio o equipo..."></td>
        <td><input type="number" class="form-input cot-precio" style="text-align: right; font-size: 13px;" value="0.00" min="0" step="100" onchange="calcularTotalesCotizacion()" onkeyup="calcularTotalesCotizacion()"></td>
        <td style="text-align: right; font-weight: 600; color: #0f172a;" class="cot-importe">$0.00</td>
        <td style="text-align: center;">
            <button type="button" onclick="this.closest('tr').remove(); calcularTotalesCotizacion();" style="background: #fee2e2; color: #dc2626; border: none; padding: 6px; border-radius: 6px; cursor: pointer;"><i class="ph ph-trash"></i></button>
        </td>
    `;
    tbody.appendChild(tr);
    calcularTotalesCotizacion();
}

function calcularTotalesCotizacion() {
    let subtotal = 0;
    document.querySelectorAll(".fila-cot").forEach(tr => {
        const cant = parseFloat(tr.querySelector(".cot-cant").value) || 0;
        const precio = parseFloat(tr.querySelector(".cot-precio").value) || 0;
        const importe = cant * precio;
        tr.querySelector(".cot-importe").innerText = "$" + importe.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        subtotal += importe;
    });

    const iva = subtotal * 0.16;
    const total = subtotal + iva;

    document.getElementById("cot-subtotal").innerText = "$" + subtotal.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
    document.getElementById("cot-iva").innerText = "$" + iva.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
    document.getElementById("cot-total").innerText = "$" + total.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
}

async function generarCotizacionPDF() {
    const btn = document.getElementById("btn-descargar-cotizacion");
    
    // Recopilar datos
    const selectC = document.getElementById("cot-cliente");
    const empresa = selectC.options[selectC.selectedIndex]?.text;
    const selectCont = document.getElementById("cot-contacto");
    const contacto = selectCont.options[selectCont.selectedIndex]?.text || selectCont.value;

    if (!selectC.value || empresa === "--- Selecciona un Cliente ---") {
        alert("⚠️ Por favor selecciona un Cliente/Empresa.");
        return;
    }

    const items = [];
    let subtotal = 0;
    document.querySelectorAll(".fila-cot").forEach(tr => {
        const cant = parseFloat(tr.querySelector(".cot-cant").value) || 0;
        const desc = tr.querySelector(".cot-desc").value.trim();
        const precio = parseFloat(tr.querySelector(".cot-precio").value) || 0;
        if (cant > 0 && precio > 0 && desc) {
            const imp = cant * precio;
            items.push({ cantidad: cant, concepto: desc, precio_unitario: precio, importe: imp });
            subtotal += imp;
        }
    });

    if (items.length === 0) {
        alert("⚠️ Por favor agrega al menos un concepto con cantidad, descripción y precio.");
        return;
    }

    const iva = subtotal * 0.16;
    const data = {
        empresa: empresa,
        contacto: contacto,
        departamento: document.getElementById("cot-depto").value,
        fecha: document.getElementById("cot-fecha").value,
        introduccion: document.getElementById("cot-intro").value,
        tecnica: document.getElementById("cot-tecnica").value,
        entregables: document.getElementById("cot-entregables").value,
        items: items,
        subtotal: subtotal,
        iva: iva,
        total: subtotal + iva,
        politicas: document.getElementById("cot-politicas").value
    };

    try {
        btn.innerHTML = '<i class="ph ph-spinner ph-spin"></i> GENERANDO PDF...';
        btn.style.opacity = '0.7';
        btn.disabled = true;

        const res = await fetch(`${API_URL}/api/cotizaciones/generar_pdf`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });

        if (!res.ok) {
            const err = await res.json();
            throw new Error(err.detail || "Error al generar PDF");
        }

        // Descargar el archivo
        const blob = await res.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = `Cotizacion_VPRO_${empresa.replace(/\\s+/g, '_')}.pdf`;
        document.body.appendChild(a);
        a.click();
        a.remove();
        window.URL.revokeObjectURL(url);

    } catch (e) {
        alert("❌ Error: " + e.message);
    } finally {
        btn.innerHTML = '<i class="ph ph-download-simple"></i> DESCARGAR COTIZACIÓN EN PDF';
        btn.style.opacity = '1';
        btn.disabled = false;
    }
}
async function abrirModalVincularCotizacionDesdeGastos() {
    if (!window.eventoActualVincular) {
        alert("Error: No se pudo identificar el evento actual (OP).");
        return;
    }
    document.getElementById("modal-vincular-cotizacion").style.display = "flex";
    const select = document.getElementById("select-cotizacion-vincular");
    select.innerHTML = '<option value="">Cargando cotizaciones...</option>';
    try {
        const res = await fetch(`${API_URL}/api/cotizaciones/lista`);
        if (res.ok) {
            const cotizaciones = await res.json();
            if (cotizaciones.length > 0) {
                select.innerHTML = '<option value="">-- Seleccione una Cotización --</option>' + 
                    cotizaciones.map(c => `<option value="${c.id_cotizacion}">${c.folio} - ${c.cliente} | Contacto: ${c.contacto || 'N/A'} | Fecha: ${c.fecha || 'N/A'} | Importe: $${(c.total||0).toLocaleString('en-US', {minimumFractionDigits: 2})}</option>`).join("");
            } else {
                select.innerHTML = '<option value="">No hay cotizaciones disponibles</option>';
            }
        }
    } catch (e) {
        console.error("Error al cargar cotizaciones:", e);
        select.innerHTML = '<option value="">Error al cargar</option>';
    }
}

async function guardarVinculoCotizacion() {
    const idCotizacion = document.getElementById("select-cotizacion-vincular").value;
    const idEvento = window.eventoActualVincular;
    if (!idCotizacion || !idEvento) {
        alert("Por favor seleccione una cotización.");
        return;
    }
    
    try {
        const res = await fetch(`${API_URL}/api/eventos/${idEvento}/vincular_cotizacion`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id_cotizacion: parseInt(idCotizacion) })
        });
        
        if (res.ok) {
            alert("Cotización vinculada correctamente a la OP.");
            document.getElementById("modal-vincular-cotizacion").style.display = "none";
        } else {
            const data = await res.json();
            alert("Error al vincular: " + (data.detail || "Error desconocido"));
        }
    } catch (e) {
        console.error(e);
        alert("Error de red al vincular cotización.");
    }
}

let memoriaHistorialCotizaciones = [];

async function cargarHistorialCotizacionesCatalogo() {
    try {
        const res = await fetch(`${API_URL}/api/cotizaciones/lista`);
        if (!res.ok) throw new Error("Error fetching cotizaciones");
        const data = await res.json();
        memoriaHistorialCotizaciones = data;
        renderTablaCotizacionesBoveda();
    } catch (e) {
        console.error(e);
        document.getElementById('tbody-cotizaciones-boveda').innerHTML = '<tr><td colspan="6" class="td-error">Error al cargar Bóveda</td></tr>';
    }
}

function renderTablaCotizacionesBoveda() {
    const tbody = document.getElementById('tbody-cotizaciones-boveda');
    if (!tbody) return;
    tbody.innerHTML = '';
    const filtro = (document.getElementById('filtro-cotizaciones')?.value || '').toLowerCase();
    
    const filtrados = memoriaHistorialCotizaciones.filter(c => {
        const str = `${c.folio || ''} ${c.cliente || ''} ${c.contacto || ''}`.toLowerCase();
        return str.includes(filtro);
    });

    if (filtrados.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center;">No hay cotizaciones</td></tr>';
        return;
    }

    filtrados.forEach(c => {
        const tr = document.createElement('tr');
        const pdfUrl = c.archivo_pdf ? `${API_URL}${c.archivo_pdf}` : '#';
        const pdfBtn = c.archivo_pdf ? `<a href="${pdfUrl}" target="_blank" style="color: #ef4444; text-decoration: none;" title="Descargar PDF">📄</a>` : '';
        
        tr.innerHTML = `
            <td style="font-weight: bold;">${c.folio}</td>
            <td>${c.cliente || ''}</td>
            <td>${c.contacto || ''}</td>
            <td>${c.fecha || ''}</td>
            <td>$${(c.total || 0).toLocaleString('en-US', {minimumFractionDigits: 2})}</td>
            <td style="display:flex; gap:10px;">
                ${pdfBtn}
                <button onclick="cargarCotizacionParaEdicion(${c.id_cotizacion})" style="background: none; border: none; cursor: pointer; color: #3b82f6;" title="Cargar a formulario">✏️</button>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

function filtrarTablaCotizacionesBoveda() {
    renderTablaCotizacionesBoveda();
}

async function cargarCotizacionParaEdicion(idCotizacion) {
    if (!confirm("Esto reemplazará los datos actuales en el formulario de cotizaciones. ¿Deseas continuar?")) return;
    try {
        const res = await fetch(`${API_URL}/api/cotizaciones/${idCotizacion}`);
        if (!res.ok) throw new Error("Error fetching");
        const data = await res.json();
        
        if (!data.datos_json) {
            alert("Esta cotización no tiene datos_json guardados. (Versión antigua)");
            return;
        }

        const j = data.datos_json;
        
        // Función helper para asegurar que la opción exista en el select
        const setSelectValue = (id, val) => {
            if (!val) return;
            const select = document.getElementById(id);
            if (select) {
                if (!Array.from(select.options).some(opt => opt.value === val)) {
                    const opt = document.createElement('option');
                    opt.value = val;
                    opt.text = val;
                    select.add(opt);
                }
                select.value = val;
            }
        };

        // Llenar formulario
        if (document.getElementById('cot-fecha')) document.getElementById('cot-fecha').value = j.fecha || '';
        setSelectValue('cot-cliente', j.empresa);
        setSelectValue('cot-contacto', j.contacto);
        if (document.getElementById('cot-depto')) document.getElementById('cot-depto').value = j.departamento || '';
        if (document.getElementById('cot-intro')) document.getElementById('cot-intro').value = j.introduccion || '';
        if (document.getElementById('cot-tecnica')) document.getElementById('cot-tecnica').value = j.tecnica || '';
        if (document.getElementById('cot-entregables')) document.getElementById('cot-entregables').value = j.entregables || '';
        if (document.getElementById('cot-politicas')) document.getElementById('cot-politicas').value = j.politicas || '';

        // Llenar tabla dynamic
        const tbody = document.getElementById('cot-tabla-body');
        if (tbody) {
            tbody.innerHTML = ''; // Limpiar
            if (j.items && j.items.length > 0) {
                j.items.forEach(it => {
                    const tr = document.createElement('tr');
                    tr.className = "fila-cot";
                    tr.innerHTML = `
                        <td><input type="number" class="form-input cot-cant" style="text-align: center; font-size: 13px;" value="${it.cantidad || 1}" min="1" onchange="calcularTotalesCotizacion()" onkeyup="calcularTotalesCotizacion()"></td>
                        <td><input type="text" class="form-input cot-desc" style="font-size: 13px;" placeholder="Descripción del servicio o equipo..." value="${it.concepto || ''}"></td>
                        <td><input type="number" class="form-input cot-precio" style="text-align: right; font-size: 13px;" value="${it.precio_unitario || 0}" min="0" step="100" onchange="calcularTotalesCotizacion()" onkeyup="calcularTotalesCotizacion()"></td>
                        <td style="text-align: right; font-weight: 600; color: #0f172a;" class="cot-importe">$0.00</td>
                        <td style="text-align: center;">
                            <button type="button" onclick="this.closest('tr').remove(); calcularTotalesCotizacion();" style="background: #fee2e2; color: #dc2626; border: none; padding: 6px; border-radius: 6px; cursor: pointer;"><i class="ph ph-trash"></i></button>
                        </td>
                    `;
                    tbody.appendChild(tr);
                });
            } else {
                agregarFilaCotizacion();
            }
        }
        
        if (typeof calcularTotalesCotizacion === 'function') {
            calcularTotalesCotizacion();
        }
        
        window._preventCotizacionesInit = true;
        cambiarVista('vista-cotizaciones');
    } catch (e) {
        console.error(e);
        alert("Error al cargar la cotización para edición.");
    }
}
