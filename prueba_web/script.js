// ==============================================================================
// SISTEMA INTEGRAL DIGITAL - VPRO STREAMING SERVICES
// ARCHIVO: script.js (Cliente Web SPA Frontend)
// ==============================================================================

// 1. CONFIGURACIÓN Y VARIABLES GLOBALES
const API_URL = "https://172.16.0.20:8000"; 

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
                <img src="${urlFoto}" onerror="this.src='https://cdn-icons-png.flaticon.com/512/3135/3135715.png'" alt="Foto">
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
            cerrarModal();
            iniciarSesionExitosa(resultado);
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
        } else if (idVista === 'vista-ops') {
            inicializarModuloOP();
        } else if (idVista === 'vista-danados') {
            cargarEquiposDanados();
        } else if (idVista === 'vista-gastos') {
            cargarReporteGastos();
        } else if (idVista === 'vista-auditoria') {
            cargarAuditoriaAsistencia();
        } else if (idVista === 'vista-catalogos') {
            abrirSubcatalogo((typeof subcatalogoActivoActual !== 'undefined' && subcatalogoActivoActual) ? subcatalogoActivoActual : 'hub');
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

    // 1. Radar de Bodega (Checkouts)
    const contenedorNotif = document.getElementById("inicio-notificaciones");
    if (contenedorNotif) {
        try {
            const resCheck = await fetch(`${API_URL}/api/checkout/pendientes/${usuarioLogueado.id_empleado}/${encodeURIComponent(usuarioLogueado.nombre_completo)}`);
            if (resCheck.ok) {
                const pendientes = await resCheck.json();
                if (pendientes && pendientes.length > 0) {
                    contenedorNotif.innerHTML = pendientes.map(op => `
                        <div class="alerta-card warning">
                            <i class="ph ph-warning-circle" style="font-size: 20px;"></i>
                            <span style="flex: 1;">⚠️ <b>${op.label || op.folio || 'Orden pendiente'}</b> | Estatus actual: <code>${op.estado || 'PENDIENTE'}</code></span>
                            <button onclick="cambiarVista('vista-checkout')" style="background: #b45309; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer; font-weight: 600;">Ver</button>
                        </div>
                    `).join("");
                } else {
                    contenedorNotif.innerHTML = `<div class="alerta-card success"><i class="ph ph-check-circle" style="font-size: 20px;"></i> Radar de Bodega: 100% de Checkouts al día (Operación Limpia)</div>`;
                }
            } else {
                contenedorNotif.innerHTML = `<div class="alerta-card success"><i class="ph ph-check-circle" style="font-size: 20px;"></i> Radar de Bodega: 100% de Checkouts al día (Operación Limpia)</div>`;
            }
        } catch (e) {
            contenedorNotif.innerHTML = `<div class="alerta-card success"><i class="ph ph-check-circle" style="font-size: 20px;"></i> Radar de Bodega: 100% de Checkouts al día (Operación Limpia)</div>`;
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
    };
    
    actualizar();
    clearInterval(intervaloReloj);
    intervaloReloj = setInterval(actualizar, 1000);
}

async function cargarMatrizKiosco() {
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

        const empleadosValidos = empleados.filter(e => 
            String(e.id_empleado).trim() !== "529" && 
            e.email && e.email.includes("@") && 
            !String(e.estatus || '').toUpperCase().includes("BAJA")
        ).sort((a, b) => (a.nombre || '').localeCompare(b.nombre || ''));

        empleadosValidos.forEach(emp => {
            const reg = registrosHoy.find(r => String(r.id_empleado).trim() === String(emp.id_empleado).trim());
            let inMat = "--:--", outMat = "--:--", inVesp = "--:--", outVesp = "--:--";
            
            if (reg) {
                const limpiaHora = (h) => (h && h !== "None" && h !== "null" && h !== "--:--") ? String(h).substring(0, 5) : "--:--";
                inMat = limpiaHora(reg.hora_entrada);
                outMat = limpiaHora(reg.hora_salida);
                inVesp = limpiaHora(reg.hora_entrada_v);
                outVesp = limpiaHora(reg.hora_salida_v);
            }

            const stError = "color: #9f1239; background: #ffe4e6; font-weight: bold;";
            const tdOutMat = (outMat === "--:--" && inMat !== "--:--") ? `<td style="${stError}">--:--</td>` : `<td>${outMat}</td>`;

            tbody.innerHTML += `
                <tr>
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
                
                try {
                    const resEmps = await fetch(`${API_URL}/api/empleados`);
                    const emp = (await resEmps.json()).find(e => String(e.id_empleado).trim() === qrCode);
                    if (emp) {
                        document.getElementById("scan-nombre").innerText = emp.nombre;
                        document.getElementById("scan-id").innerText = `ID: ${emp.id_empleado}`;
                        document.getElementById("scan-badge").innerText = resultado.status === "WARNING" ? "🚨 OMISIÓN DETECTADA" : "✅ REGISTRADO";
                        document.getElementById("scan-foto").src = `${API_URL}/fotos/${emp.id_empleado}.jpg`;
                    }
                } catch (e) {}

                if (respuesta.ok && resultado.status !== "WARNING") {
                    mostrarAlerta(`✅ ${resultado.mensaje}`, "#d1fae5", "#065f46", "#10b981");
                } else if (resultado.status === "WARNING") {
                    mostrarAlerta(`⚠️ ${resultado.mensaje}`, "#fef3c7", "#92400e", "#f59e0b");
                } else {
                    mostrarAlerta(`❌ ${resultado.detail || "Error al registrar."}`, "#fee2e2", "#991b1b", "#ef4444");
                }

                cargarMatrizKiosco();
            } catch (error) { 
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
        const [resFolios, resCats, resReus] = await Promise.all([
            fetch(`${API_URL}/api/eventos/folios`),
            fetch(`${API_URL}/api/eventos/catalogos`),
            fetch(`${API_URL}/api/reuniones/catalogo`).catch(() => ({ ok: false }))
        ]);

        const dataFolios = await resFolios.json();
        const dataCats = await resCats.json();
        const dataReus = resReus.ok ? await resReus.json() : [];

        window.vproFoliosActivos = dataFolios.folios || [];
        window.vproFoliosHistoricos = dataFolios.folios_historicos || [];
        window.vproProximoId = dataFolios.proximo_id || 1;

        // Combinar catálogos
        window.vproCatalogosOP = {
            ...dataCats,
            reuniones: dataReus || []
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

    return `
        <form id="form-orden-produccion-${isReadOnly ? 'hist' : 'act'}" onsubmit="guardarOrdenOP(event)">
            <input type="hidden" id="op_id_evento" value="${idEvento}">

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

            <!-- 💾 BOTÓN GUARDAR MAESTRO -->
            ${!isReadOnly ? `
                <div style="margin-top: 10px; margin-bottom: 20px;">
                    <button type="submit" style="width: 100%; background: #ef4444; color: white; border: none; padding: 16px; border-radius: 8px; font-weight: 700; font-size: 15px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; box-shadow: 0 4px 6px -1px rgba(239, 68, 68, 0.25); transition: background 0.2s;">
                        💾 GUARDAR CAMBIOS ORDEN
                    </button>
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
            reuniones: []
        };

        const proximoFolio = window.vproProximoId || 1;
        container.innerHTML = generarHtmlFormularioOP({ id_evento: proximoFolio, folio: String(proximoFolio) }, false);

        // Renderizar multi-selects en blanco
        renderMultiSelectComponent('ms-reuniones-act', 'reuniones', cats.reuniones, "Despliega y selecciona una o varias reuniones...");
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
            reuniones: Array.isArray(data.reuniones_vinculadas) ? data.reuniones_vinculadas : []
        };

        container.innerHTML = generarHtmlFormularioOP(data, false);

        // Renderizar los componentes multiselect poblados
        renderMultiSelectComponent('ms-reuniones-act', 'reuniones', cats.reuniones, "Despliega y selecciona una o varias reuniones...");
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
            reuniones: Array.isArray(data.reuniones_vinculadas) ? data.reuniones_vinculadas : []
        };

        const cats = window.vproCatalogosOP || {};
        container.innerHTML = generarHtmlFormularioOP(data, true);

        renderMultiSelectComponent('ms-reuniones-hist', 'reuniones', cats.reuniones, "Sin reuniones", true);
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
async function cargarEquiposDanados() {
    const tbody = document.getElementById("tabla-danados-body");
    if (!tbody) return;

    try {
        const res = await fetch(`${API_URL}/api/inventario/radar-danos`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);

        const equipos = await res.json();
        const badgeDanados = document.getElementById("badge-danados");
        if (badgeDanados) badgeDanados.innerText = equipos.length || 0;

        if (equipos.length === 0) {
            tbody.innerHTML = `<tr><td colspan="9" style="text-align: center; padding: 24px; color: #166534; font-weight: 500;">✅ No hay equipos reportados con daño actualmente. Almacén 100% operativo.</td></tr>`;
            return;
        }

        tbody.innerHTML = equipos.map(eq => {
            const estado = (eq.ESTADO || 'EN REVISIÓN').toUpperCase();
            let badgeClass = "background: #fef3c7; color: #92400e;";
            if (estado.includes('TALLER') || estado.includes('GRAVE')) badgeClass = "background: #fee2e2; color: #991b1b;";
            else if (estado.includes('PIEZA') || estado.includes('ESPERA')) badgeClass = "background: #e0e7ff; color: #3730a3;";

            return `
                <tr>
                    <td style="font-weight: 600;">#${eq.NUM_SERVICIO || '--'}</td>
                    <td>${eq.FECHA_REPORTE ? String(eq.FECHA_REPORTE).substring(0, 10) : '--'}</td>
                    <td><code>${eq.ID || '--'}</code></td>
                    <td style="font-weight: 500; color: #0f172a;">${eq.EQUIPO || '--'}</td>
                    <td>${eq.DEPARTAMENTO || '--'}</td>
                    <td>${eq["REPORTÓ"] || '--'}</td>
                    <td><span style="display: inline-block; padding: 3px 8px; border-radius: 6px; font-size: 11px; font-weight: 700; ${badgeClass}">${estado}</span></td>
                    <td style="max-width: 250px; font-size: 12.5px;">${eq.FALLA || '--'}</td>
                    <td style="font-weight: 600; color: #0f172a;">$${Number(eq.COSTO || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</td>
                </tr>
            `;
        }).join("");
    } catch (err) {
        console.error("Error al cargar equipos dañados:", err);
        tbody.innerHTML = `<tr><td colspan="9" style="text-align: center; color: #ef4444; padding: 20px;">Error al conectar con el inventario de reparaciones.</td></tr>`;
    }
}

// ==========================================
// 8. MÓDULO REPORTE DE GASTOS
// ==========================================
async function cargarReporteGastos() {
    const tbody = document.getElementById("tabla-gastos-body");
    const kpiPendientes = document.getElementById("kpi-gastos-pendientes");
    if (!tbody) return;

    try {
        const [resPend, resLista] = await Promise.all([
            fetch(`${API_URL}/api/gastos/pendientes/conteo`),
            fetch(`${API_URL}/api/gastos/informes-auditoria`)
        ]);

        if (resPend.ok) {
            const conteo = await resPend.json();
            const num = (typeof conteo === 'number') ? conteo : (conteo?.conteo || 0);
            if (kpiPendientes) kpiPendientes.innerText = num;
            const badgeGastos = document.getElementById("badge-gastos");
            if (badgeGastos) badgeGastos.innerText = num;
        }

        if (resLista.ok) {
            const informes = await resLista.json();
            if (informes.length === 0) {
                tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; padding: 24px; color: #166534; font-weight: 500;">✅ No hay informes de gastos pendientes de auditar.</td></tr>`;
                return;
            }

            tbody.innerHTML = informes.map(inf => {
                const revisado = Boolean(inf.revisado);
                const stBadge = revisado 
                    ? `<span style="background: #dcfce7; color: #166534; padding: 3px 8px; border-radius: 6px; font-weight: 700; font-size: 11px;">✅ AUDITADO</span>`
                    : `<span style="background: #fef3c7; color: #92400e; padding: 3px 8px; border-radius: 6px; font-weight: 700; font-size: 11px;">⏳ PENDIENTE</span>`;

                return `
                    <tr>
                        <td style="font-weight: 600;">#${inf.id_informe}</td>
                        <td><b>OP-${inf.folio_vpro}</b></td>
                        <td style="color: #0f172a; font-weight: 500;">${inf.nombre_evento || 'Evento'}</td>
                        <td>${inf.nombre_empleado || 'Responsable'}</td>
                        <td>${stBadge}</td>
                    </tr>
                `;
            }).join("");
        }
    } catch (err) {
        console.error("Error al cargar reporte de gastos:", err);
        tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; color: #ef4444; padding: 20px;">Error al consultar el módulo de gastos.</td></tr>`;
    }
}

// ==========================================
// 9. MÓDULO AUDITORÍA DE ASISTENCIA
// ==========================================
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
                             opt.innerText = e.nombre;
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
    const tbody = document.getElementById("tabla-auditoria-body");
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
        const data = await res.json();

        if (data.length === 0) {
            tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; padding: 20px; color: var(--text-muted);">No se encontraron registros de asistencia para los filtros seleccionados.</td></tr>`;
            return;
        }

        const limpiaHora = (h) => (h && h !== "None" && h !== "null" && h !== "--:--") ? String(h).substring(0, 5) : "--:--";

        tbody.innerHTML = data.map(r => {
            const mIn = limpiaHora(r.hora_entrada);
            const mOut = limpiaHora(r.hora_salida);
            const vIn = limpiaHora(r.hora_entrada_v);
            const vOut = limpiaHora(r.hora_salida_v);

            const omitio = (r.observaciones || '').toUpperCase().includes("OMISIÓN") || (r.observaciones || '').toUpperCase().includes("ADVERTENCIA");
            const obsTexto = omitio ? `<span style="color: #991b1b; font-weight: 600;">🚨 ${r.observaciones}</span>` : (r.observaciones || '--');

            return `
                <tr>
                    <td style="font-weight: 600; color: #0f172a;">${r.nombre || '--'}</td>
                    <td>${r.fecha || '--'}</td>
                    <td>${mIn}</td>
                    <td>${mOut}</td>
                    <td>${vIn}</td>
                    <td>${vOut}</td>
                    <td>${obsTexto}</td>
                </tr>
            `;
        }).join("");
    } catch (err) {
        console.error("Error en consulta auditoría:", err);
        tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: #ef4444; padding: 20px;">Error al consultar registros de asistencia.</td></tr>`;
    }
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
        const contenedores = ['clientes', 'autos', 'proveedores', 'inventario', 'empleados', 'reuniones'];
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
    const contenedores = ['clientes', 'autos', 'proveedores', 'inventario', 'empleados', 'reuniones'];
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

function poblarSelectorInventario() {
    const sel = document.getElementById('selector-inv-editor');
    if (!sel) return;
    const valorPrevio = sel.value;
    sel.innerHTML = `<option value="nuevo">➕ Registrar Nuevo Hardware</option>` +
        memoriaInventario.map(i => `<option value="${i.codigo}">${i.codigo} - ${i.descripcion || ''} (${i.marca || 'S/M'})</option>`).join('');

    if (valorPrevio && memoriaInventario.some(i => i.codigo === valorPrevio)) {
        sel.value = valorPrevio;
    } else {
        sel.value = 'nuevo';
    }
}

function seleccionarInventarioDirecto(codigo) {
    const sel = document.getElementById('selector-inv-editor');
    if (sel) {
        sel.value = codigo;
        alCambiarSelectorInventario();
        sel.scrollIntoView({ behavior: 'smooth', block: 'center' });
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
}

function limpiarFormInventario() {
    inventarioEditandoCodigo = null;
    const codInput = document.getElementById('inv-codigo');
    if (codInput) {
        codInput.value = '';
        codInput.disabled = false;
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

    const inpCliente = document.getElementById('reu-cliente');
    if (inpCliente) inpCliente.value = r.cliente_tentativo || '';

    const inpProy = document.getElementById('reu-proyecto');
    if (inpProy) inpProy.value = r.nombre_proyecto_tentativo || '';

    const inpAsis = document.getElementById('reu-asistentes');
    if (inpAsis) inpAsis.value = r.asistentes || '';

    const inpPres = document.getElementById('reu-presupuesto');
    if (inpPres) inpPres.value = r.presupuesto_estimado || 0;

    const inpProb = document.getElementById('reu-fecha-probable');
    if (inpProb) inpProb.value = r.fecha_probable_evento || '';

    const inpMin = document.getElementById('reu-minuta');
    if (inpMin) inpMin.value = r.minuta_acuerdos || '';

    const lblBtn = document.getElementById('lbl-btn-guardar-reu');
    if (lblBtn) lblBtn.innerText = '🔄 Actualizar Minuta de Reunión';
}

function limpiarFormReunion() {
    const sel = document.getElementById('selector-reu-editor');
    if (sel) sel.value = 'nuevo';

    const inpId = document.getElementById('reu-id');
    if (inpId) inpId.value = '';

    const inpFecha = document.getElementById('reu-fecha');
    if (inpFecha) inpFecha.value = new Date().toISOString().split('T')[0];

    const inpCliente = document.getElementById('reu-cliente');
    if (inpCliente) inpCliente.value = '';

    const inpProy = document.getElementById('reu-proyecto');
    if (inpProy) inpProy.value = '';

    const inpAsis = document.getElementById('reu-asistentes');
    if (inpAsis) inpAsis.value = '';

    const inpPres = document.getElementById('reu-presupuesto');
    if (inpPres) inpPres.value = '';

    const inpProb = document.getElementById('reu-fecha-probable');
    if (inpProb) inpProb.value = '';

    const inpMin = document.getElementById('reu-minuta');
    if (inpMin) inpMin.value = '';

    const lblBtn = document.getElementById('lbl-btn-guardar-reu');
    if (lblBtn) lblBtn.innerText = '💾 Guardar Nueva Reunión';
}

async function guardarReunionForm() {
    const id = document.getElementById('reu-id')?.value;
    const fecha = document.getElementById('reu-fecha')?.value;
    const cliente = document.getElementById('reu-cliente')?.value?.trim();
    const proyecto = document.getElementById('reu-proyecto')?.value?.trim();
    const asistentes = document.getElementById('reu-asistentes')?.value?.trim();
    const presupuesto = document.getElementById('reu-presupuesto')?.value;
    const fecha_probable = document.getElementById('reu-fecha-probable')?.value || null;
    const minuta = document.getElementById('reu-minuta')?.value?.trim();

    if (!fecha || !cliente || !proyecto || !asistentes || !minuta) {
        alert("⚠️ Por favor, llena todos los campos marcados con asterisco (*).");
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
        alert(id ? "✅ Minuta actualizada correctamente." : "✅ Minuta de reunión registrada exitosamente.");
        await cargarCatalogoReuniones();
        limpiarFormReunion();
    } catch (e) {
        alert(`❌ Error al guardar minuta: ${e.message}`);
    } finally {
        if (btn) btn.disabled = false;
    }
}

// --------------------------------------------------------------------------
// 🌐 CARGA INTEGRAL DE CATÁLOGOS (PARA CONTADORES DEL HUB Y TABS)
// --------------------------------------------------------------------------
async function cargarTodosLosCatalogos() {
    try {
        const [resCli, resAutos, resProv, resInv, resEmp, resReu] = await Promise.allSettled([
            fetch(`${API_URL}/api/clientes`).then(r => r.json()),
            fetch(`${API_URL}/api/autos`).then(r => r.json()),
            fetch(`${API_URL}/api/proveedores`).then(r => r.json()),
            fetch(`${API_URL}/api/inventario`).then(r => r.json()),
            fetch(`${API_URL}/api/empleados`).then(r => r.json()),
            fetch(`${API_URL}/api/reuniones/historial`).then(r => r.json())
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