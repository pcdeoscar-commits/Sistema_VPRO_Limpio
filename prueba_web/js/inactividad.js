// ==============================================================================
// MÓDULO: inactividad.js
// Control de Seguridad: Cierre y bloqueo automático de sesión por inactividad
// Estándar ISO 27001 / ISO 9001 - VPRO Workspace
// ==============================================================================

const VPRO_INACTIVIDAD_CONFIG = {
    TIEMPO_TOTAL_MS: 5 * 60 * 1000,    // 5 minutos exactos (300,000 ms)
    TIEMPO_PREAVISO_MS: 45 * 1000,     // Mostrar alerta 45 segundos antes (a los 4m 15s)
    THROTTLE_EVENTOS_MS: 1000          // Límite de procesamiento de eventos (1 por segundo)
};

const vproInactividadState = {
    activo: false,
    timerTotal: null,
    timerPreaviso: null,
    intervaloRegresiva: null,
    segundosRestantes: 45,
    ultimaActividad: Date.now(),
    usuarioMonitoreado: null
};

// Eventos que indican actividad real del usuario
const VPRO_EVENTOS_ACTIVIDAD = ['mousemove', 'mousedown', 'keydown', 'touchstart', 'scroll', 'wheel'];

/**
 * Inicia el monitoreo de inactividad para el usuario actual.
 * Excluye explícitamente terminales públicas (Kiosco Checador).
 */
function iniciarMonitoreoInactividad(usuario) {
    if (!usuario) return;

    // Regla de seguridad: Si es Kiosco físico de checador en bodega, NUNCA bloquear
    const rol = (usuario.rol || '').toUpperCase();
    const depto = (usuario.depto || '').toUpperCase();
    const idEmp = String(usuario.id_empleado || '').trim();
    if (rol === 'KIOSKO' || depto === 'KIOSKO' || idEmp === '529') {
        detenerMonitoreoInactividad();
        return;
    }

    vproInactividadState.usuarioMonitoreado = usuario;
    vproInactividadState.activo = true;
    vproInactividadState.ultimaActividad = Date.now();

    // Registrar escuchadores de eventos globales
    VPRO_EVENTOS_ACTIVIDAD.forEach(evt => {
        window.addEventListener(evt, registrarActividadUsuario, { passive: true });
    });

    reiniciarTemporizadorInactividad();
}

/**
 * Detiene y limpia todos los temporizadores activos.
 */
function detenerMonitoreoInactividad() {
    vproInactividadState.activo = false;
    vproInactividadState.usuarioMonitoreado = null;

    if (vproInactividadState.timerTotal) clearTimeout(vproInactividadState.timerTotal);
    if (vproInactividadState.timerPreaviso) clearTimeout(vproInactividadState.timerPreaviso);
    if (vproInactividadState.intervaloRegresiva) clearInterval(vproInactividadState.intervaloRegresiva);

    VPRO_EVENTOS_ACTIVIDAD.forEach(evt => {
        window.removeEventListener(evt, registrarActividadUsuario);
    });

    ocultarAvisoInactividad();
}

/**
 * Registra actividad y reinicia los contadores (con throttle para no saturar CPU).
 */
function registrarActividadUsuario() {
    if (!vproInactividadState.activo) return;

    const ahora = Date.now();
    if (ahora - vproInactividadState.ultimaActividad < VPRO_INACTIVIDAD_CONFIG.THROTTLE_EVENTOS_MS) {
        return;
    }
    vproInactividadState.ultimaActividad = ahora;

    // Si había un preaviso en pantalla, se oculta inmediatamente al detectar actividad
    ocultarAvisoInactividad();
    reiniciarTemporizadorInactividad();
}

/**
 * Reinicia las cuentas atrás de 5 minutos y de preaviso.
 */
function reiniciarTemporizadorInactividad() {
    if (!vproInactividadState.activo) return;

    if (vproInactividadState.timerTotal) clearTimeout(vproInactividadState.timerTotal);
    if (vproInactividadState.timerPreaviso) clearTimeout(vproInactividadState.timerPreaviso);
    if (vproInactividadState.intervaloRegresiva) clearInterval(vproInactividadState.intervaloRegresiva);

    const tiempoHastaAviso = VPRO_INACTIVIDAD_CONFIG.TIEMPO_TOTAL_MS - VPRO_INACTIVIDAD_CONFIG.TIEMPO_PREAVISO_MS;

    // 1. Temporizador del preaviso (dispara a los 4m 15s)
    vproInactividadState.timerPreaviso = setTimeout(() => {
        mostrarAvisoInactividad();
    }, tiempoHastaAviso);

    // 2. Temporizador final (dispara a los 5 minutos exactos)
    vproInactividadState.timerTotal = setTimeout(() => {
        ejecutarCierrePorInactividad();
    }, VPRO_INACTIVIDAD_CONFIG.TIEMPO_TOTAL_MS);
}

/**
 * Despliega la tarjeta flotante de advertencia con cuenta regresiva de 45 segundos.
 */
function mostrarAvisoInactividad() {
    let avisoEl = document.getElementById("vpro-inactividad-aviso");
    if (!avisoEl) {
        avisoEl = document.createElement("div");
        avisoEl.id = "vpro-inactividad-aviso";
        avisoEl.style.cssText = `
            position: fixed;
            top: 24px;
            right: 24px;
            z-index: 9999999;
            background: rgba(30, 27, 75, 0.96);
            backdrop-filter: blur(8px);
            border: 2px solid #818cf8;
            border-radius: 14px;
            padding: 16px 20px;
            box-shadow: 0 14px 35px rgba(0, 0, 0, 0.6);
            color: #ffffff;
            display: flex;
            align-items: center;
            gap: 16px;
            font-family: inherit;
            animation: vproInactividadEntrada 0.3s ease-out;
            max-width: 420px;
        `;

        // Inyectar animación CSS una sola vez
        if (!document.getElementById("vpro-inactividad-style")) {
            const st = document.createElement("style");
            st.id = "vpro-inactividad-style";
            st.innerHTML = `
                @keyframes vproInactividadEntrada {
                    from { opacity: 0; transform: translateY(-20px) scale(0.95); }
                    to { opacity: 1; transform: translateY(0) scale(1); }
                }
            `;
            document.head.appendChild(st);
        }

        document.body.appendChild(avisoEl);
    }

    vproInactividadState.segundosRestantes = Math.floor(VPRO_INACTIVIDAD_CONFIG.TIEMPO_PREAVISO_MS / 1000);

    avisoEl.innerHTML = `
        <div style="width: 44px; height: 44px; border-radius: 10px; background: rgba(251, 191, 36, 0.18); display: flex; align-items: center; justify-content: center; font-size: 26px; color: #fbbf24; flex-shrink: 0;">
            <i class="ph ph-hourglass-medium"></i>
        </div>
        <div style="flex: 1; min-width: 0;">
            <div style="font-size: 14px; font-weight: 700; color: #f8fafc; display: flex; align-items: center; gap: 6px;">
                <span>Bloqueo por Inactividad</span>
            </div>
            <div style="font-size: 12.5px; color: #cbd5e1; margin-top: 3px; line-height: 1.35;">
                Tu sesión se cerrará en <b id="vpro-inactividad-segundos" style="color: #facc15; font-size: 14px;">${vproInactividadState.segundosRestantes}</b>s por seguridad.
            </div>
        </div>
        <button id="btn-inactividad-seguir" 
                onclick="registrarActividadUsuario()" 
                style="background: #6366f1; color: white; border: none; padding: 8px 14px; border-radius: 8px; font-weight: 700; font-size: 12px; cursor: pointer; flex-shrink: 0; box-shadow: 0 2px 8px rgba(99,102,241,0.4); transition: background 0.15s;"
                onmouseover="this.style.background='#4f46e5'" 
                onmouseout="this.style.background='#6366f1'">
            Continuar
        </button>
    `;

    avisoEl.style.display = "flex";

    // Intervalo para actualizar el contador de segundos en pantalla
    if (vproInactividadState.intervaloRegresiva) clearInterval(vproInactividadState.intervaloRegresiva);
    vproInactividadState.intervaloRegresiva = setInterval(() => {
        vproInactividadState.segundosRestantes--;
        const numEl = document.getElementById("vpro-inactividad-segundos");
        if (numEl) numEl.textContent = vproInactividadState.segundosRestantes;

        if (vproInactividadState.segundosRestantes <= 0) {
            clearInterval(vproInactividadState.intervaloRegresiva);
        }
    }, 1000);
}

/**
 * Oculta el aviso de preaviso si estaba visible.
 */
function ocultarAvisoInactividad() {
    if (vproInactividadState.intervaloRegresiva) {
        clearInterval(vproInactividadState.intervaloRegresiva);
        vproInactividadState.intervaloRegresiva = null;
    }
    const avisoEl = document.getElementById("vpro-inactividad-aviso");
    if (avisoEl) {
        avisoEl.style.display = "none";
    }
}

/**
 * Ejecuta el cierre de sesión seguro cuando se agotan los 5 minutos.
 */
function ejecutarCierrePorInactividad() {
    const usuario = vproInactividadState.usuarioMonitoreado || (typeof usuarioLogueado !== 'undefined' ? usuarioLogueado : null);
    detenerMonitoreoInactividad();

    const idEmpleado = usuario ? String(usuario.id_empleado || '').trim() : '';

    // CASO 1: Estamos en el Dashboard principal (index.html)
    if (typeof cerrarSesion === 'function') {
        cerrarSesion();

        // Si tenemos el usuario, preparamos inmediatamente el modal de PIN para cuando vuelva
        if (idEmpleado && typeof abrirModal === 'function') {
            try {
                const urlFoto = `${API_URL}/fotos/${idEmpleado}.jpg`;
                setTimeout(() => {
                    abrirModal(usuario, urlFoto);
                    const errorEl = document.getElementById("modal-error");
                    if (errorEl) {
                        errorEl.innerHTML = `🔒 <b>Sesión bloqueada tras 5 minutos de inactividad.</b><br>Ingresa tu contraseña para continuar trabajando.`;
                        errorEl.style.display = "block";
                        errorEl.style.background = "#fef3c7";
                        errorEl.style.color = "#92400e";
                        errorEl.style.border = "1px solid #f59e0b";
                        errorEl.style.borderRadius = "8px";
                        errorEl.style.padding = "10px";
                        errorEl.style.fontSize = "12px";
                        errorEl.style.lineHeight = "1.4";
                    }
                }, 200);
            } catch(e) {}
        }
        return;
    }

    // CASO 2: Estamos en la pantalla de chat (chat.html)
    if (typeof cerrarSesionChat === 'function') {
        cerrarSesionChat();
    } else {
        try {
            localStorage.removeItem("vpro_chat_usuario");
            localStorage.removeItem("usuarioLogueado");
            sessionStorage.removeItem("usuarioLogueado");
        } catch(e) {}
    }

    // Redirigir al login con el ID del empleado para que pida el PIN al instante
    if (idEmpleado) {
        window.location.href = `index.html?login_emp=${encodeURIComponent(idEmpleado)}&bloqueo=1`;
    } else {
        window.location.href = "index.html";
    }
}
