// ==============================================================================
// MÓDULO: chat_op.js
// Chat Operativo de Producción (Estilo WhatsApp) vinculado por Folio de OP
// VPRO Workspace - ISO 9001:2015
// ==============================================================================

const CHAT_API_URL = typeof API_URL !== 'undefined' ? API_URL : '';

const chatState = {
    usuario: null,
    ops: [],
    opActual: null,
    mensajes: [],
    ws: null,
    pollInterval: null,
    filtroBusqueda: '',
    filtroSoloMias: true
};

// Paleta de colores para nombres estilo WhatsApp
const COLORES_NOMBRES = [
    "#25d366", "#34b7f1", "#e542a3", "#f59f00", "#7950f2", 
    "#20c997", "#ff6b6b", "#4dabf7", "#fab005", "#12b886"
];

function obtenerColorAutor(nombre) {
    if (!nombre) return "#10b981";
    let hash = 0;
    for (let i = 0; i < nombre.length; i++) {
        hash = nombre.charCodeAt(i) + ((hash << 5) - hash);
    }
    const idx = Math.abs(hash) % COLORES_NOMBRES.length;
    return COLORES_NOMBRES[idx];
}

function formatearHoraChat(fechaStr) {
    if (!fechaStr) return "";
    try {
        const d = new Date(fechaStr.replace(/-/g, '/'));
        if (isNaN(d.getTime())) return fechaStr;
        return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true });
    } catch {
        return fechaStr;
    }
}

function autolinkTexto(texto) {
    if (!texto) return "";
    // Escapar HTML para evitar XSS
    const div = document.createElement('div');
    div.innerText = texto;
    let limpio = div.innerHTML;

    // Detectar URLs http/https
    const urlPattern = /(https?:\/\/[^\s<]+)/g;
    return limpio.replace(urlPattern, url => {
        return `<a href="${url}" target="_blank" rel="noopener noreferrer" class="chat-link">${url}</a>`;
    });
}

// ==============================================================================
// INICIALIZACIÓN Y SESIÓN
// ==============================================================================
async function inicializarChatOP() {
    // 1. Obtener usuario actual
    let user = null;
    if (typeof usuarioLogueado !== 'undefined' && usuarioLogueado) {
        user = usuarioLogueado;
    } else {
        try {
            const guardado = localStorage.getItem("vpro_chat_usuario");
            if (guardado) user = JSON.parse(guardado);
        } catch (e) {
            console.warn("No se pudo leer usuario local:", e);
        }
    }

    if (!user) {
        // Mostrar selector rápido de usuario si está en standalone
        mostrarSelectorUsuarioChat();
        return;
    }

    chatState.usuario = user;
    actualizarInfoUsuarioEnChat();
    await cargarListaOPsChat();
}

function guardarSesionChatUsuario(usuario) {
    chatState.usuario = usuario;
    try {
        localStorage.setItem("vpro_chat_usuario", JSON.stringify(usuario));
    } catch (e) {}
    actualizarInfoUsuarioEnChat();
    cargarListaOPsChat();
}

function actualizarInfoUsuarioEnChat() {
    const elNom = document.getElementById("chat-usuario-nombre");
    const elFoto = document.getElementById("chat-usuario-foto");
    if (!chatState.usuario) return;

    const nombre = chatState.usuario.nombre_completo || chatState.usuario.nombre || "Usuario VPRO";
    const idE = String(chatState.usuario.id_empleado || "000").trim();
    if (elNom) elNom.innerText = nombre;
    if (elFoto) {
        elFoto.src = `${CHAT_API_URL}/fotos/${idE}.jpg`;
        elFoto.onerror = () => { elFoto.src = "vendor/img/avatar_default.png"; };
    }
}

// ==============================================================================
// LISTADO DE ÓRDENES DE PRODUCCIÓN (CANALES DE CHAT)
// ==============================================================================
async function cargarListaOPsChat() {
    const contenedor = document.getElementById("chat-lista-ops");
    if (!contenedor) return;

    contenedor.innerHTML = `
        <div style="padding: 24px; text-align: center; color: #9ca3af;">
            <i class="ph ph-spinner-gap" style="font-size: 28px; animation: spin 1s linear infinite; display: inline-block;"></i>
            <p style="margin-top: 8px; font-size: 13px;">Cargando tus eventos...</p>
        </div>
    `;

    try {
        const u = chatState.usuario;
        const nombreParam = u ? encodeURIComponent(u.nombre_completo || u.nombre) : '';
        const rolParam = u ? encodeURIComponent(u.rol || '') : '';
        const idEmpParam = u ? encodeURIComponent(u.id_empleado || '') : '';

        const resp = await fetch(`${CHAT_API_URL}/api/chat-op/ops?usuario_nombre=${nombreParam}&rol=${rolParam}&id_empleado=${idEmpParam}`);
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
        const data = await resp.json();

        chatState.ops = data.ops || [];
        renderizarListaOPs();

        // Si se especificó folio en la URL (ej. chat.html?folio=43), abrirla directamente
        const urlParams = new URLSearchParams(window.location.search);
        const paramFolio = urlParams.get('folio') || urlParams.get('id');
        if (paramFolio && !chatState.opActual) {
            const opEncontrada = chatState.ops.find(o => String(o.folio) === String(paramFolio) || String(o.id_evento) === String(paramFolio));
            if (opEncontrada) {
                seleccionarOPParaChat(opEncontrada.id_evento);
            }
        }
    } catch (err) {
        console.error("Error al cargar OPs para chat:", err);
        contenedor.innerHTML = `
            <div style="padding: 16px; margin: 12px; background: #fee2e2; color: #991b1b; border-radius: 8px; font-size: 13px; text-align: center;">
                ⚠️ No se pudieron cargar los chats de producción.
                <button onclick="cargarListaOPsChat()" style="margin-top: 8px; display: block; width: 100%; padding: 6px; background: #dc2626; color: white; border: none; border-radius: 6px; cursor: pointer;">Reintentar</button>
            </div>
        `;
    }
}

function filtrarOPsChat(termino) {
    chatState.filtroBusqueda = (termino || '').toLowerCase().trim();
    renderizarListaOPs();
}

function renderizarListaOPs() {
    const contenedor = document.getElementById("chat-lista-ops");
    if (!contenedor) return;

    let filtradas = chatState.ops;
    if (chatState.filtroBusqueda) {
        const q = chatState.filtroBusqueda;
        filtradas = filtradas.filter(op => 
            String(op.folio).toLowerCase().includes(q) ||
            (op.nombre_evento || '').toLowerCase().includes(q) ||
            (op.subtitulo_evento || '').toLowerCase().includes(q) ||
            (op.locacion || '').toLowerCase().includes(q)
        );
    }

    if (filtradas.length === 0) {
        contenedor.innerHTML = `
            <div style="padding: 32px 16px; text-align: center; color: #9ca3af;">
                <i class="ph ph-chats-circle" style="font-size: 36px; opacity: 0.5; margin-bottom: 8px; display: block;"></i>
                <p style="margin: 0; font-size: 14px; font-weight: 500;">No hay chats disponibles</p>
                <p style="margin: 4px 0 0; font-size: 12px; opacity: 0.8;">No tienes OPs asignadas actualmente</p>
            </div>
        `;
        return;
    }

    let html = "";
    filtradas.forEach(op => {
        const esActiva = chatState.opActual && chatState.opActual.id_evento === op.id_evento;
        const horaStr = op.ultima_hora ? formatearHoraChat(op.ultima_hora) : (op.fec_del_evento ? op.fec_del_evento.split('-').reverse().slice(0,2).join('/') : '');
        const ultimoTexto = op.ultimo_mensaje 
            ? `${op.ultimo_autor ? op.ultimo_autor.split(' ')[0] + ': ' : ''}${op.ultimo_mensaje}`
            : '<i>Sin mensajes aún. Inicia la conversación...</i>';

        html += `
            <div class="chat-op-item ${esActiva ? 'active' : ''}" onclick="seleccionarOPParaChat(${op.id_evento})">
                <div class="chat-op-avatar">
                    <span class="chat-op-folio-badge">OP-${op.folio}</span>
                </div>
                <div class="chat-op-info">
                    <div class="chat-op-row-top">
                        <span class="chat-op-titulo" title="${op.nombre_evento}">${op.nombre_evento}</span>
                        <span class="chat-op-hora">${horaStr}</span>
                    </div>
                    <div class="chat-op-row-sub">
                        <span class="chat-op-locacion"><i class="ph ph-map-pin"></i> ${op.locacion || 'Sin locación'}</span>
                        ${op.fijados_count > 0 ? '<i class="ph ph-push-pin" title="Mensaje fijado" style="color: #fbbf24; font-size: 13px;"></i>' : ''}
                    </div>
                    <div class="chat-op-row-last">
                        <span class="chat-op-preview">${ultimoTexto}</span>
                        ${op.total_mensajes > 0 ? `<span class="chat-op-msg-count">${op.total_mensajes}</span>` : ''}
                    </div>
                </div>
            </div>
        `;
    });

    contenedor.innerHTML = html;
}

// ==============================================================================
// SALA DE CHAT DE LA OP
// ==============================================================================
async function seleccionarOPParaChat(id_evento) {
    const op = chatState.ops.find(o => o.id_evento === id_evento);
    if (!op) return;

    chatState.opActual = op;
    renderizarListaOPs();

    // En móviles, ocultar la lista y mostrar la sala de chat
    const panelLateral = document.getElementById("chat-panel-lateral");
    const panelConversacion = document.getElementById("chat-panel-conversacion");
    if (panelLateral && panelConversacion && window.innerWidth < 768) {
        panelLateral.style.display = "none";
        panelConversacion.style.display = "flex";
    }

    // Cabecera del chat
    actualizarCabeceraChat(op);

    // Conectar WebSocket y cargar mensajes
    conectarWebSocketChat(id_evento);
    await cargarMensajesOP(id_evento);

    // Iniciar polling seguro de respaldo
    if (chatState.pollInterval) clearInterval(chatState.pollInterval);
    chatState.pollInterval = setInterval(() => {
        cargarMensajesOP(id_evento, true);
    }, 4500);

    // Foco en el input
    setTimeout(() => {
        const inp = document.getElementById("chat-input-mensaje");
        if (inp) inp.focus();
    }, 150);
}

function regresarAListaOPsMovil() {
    const panelLateral = document.getElementById("chat-panel-lateral");
    const panelConversacion = document.getElementById("chat-panel-conversacion");
    if (panelLateral && panelConversacion) {
        panelLateral.style.display = "flex";
        panelConversacion.style.display = "none";
    }
    if (chatState.pollInterval) clearInterval(chatState.pollInterval);
    if (chatState.ws) {
        try { chatState.ws.close(); } catch(e){}
        chatState.ws = null;
    }
    chatState.opActual = null;
    renderizarListaOPs();
}

function actualizarCabeceraChat(op) {
    const elFolio = document.getElementById("chat-header-folio");
    const elTitulo = document.getElementById("chat-header-titulo");
    const elSub = document.getElementById("chat-header-detalles");
    const elLlamado = document.getElementById("chat-header-llamado");

    if (elFolio) elFolio.innerText = `OP-${op.folio}`;
    if (elTitulo) elTitulo.innerText = op.nombre_evento;
    if (elSub) {
        const prod = op.resp_de_produccion ? `Resp: ${op.resp_de_produccion}` : '';
        const chof = op.chofer ? `🚐 Chofer: ${op.chofer}` : '';
        elSub.innerText = [prod, chof].filter(Boolean).join(' | ') || (op.locacion || 'Locación no especificada');
    }
    if (elLlamado) {
        elLlamado.innerText = op.hra_de_llamado ? `Llamado: ${op.hra_de_llamado}` : (op.fec_del_evento || '');
    }
}

async function cargarMensajesOP(id_evento, esSilencioso = false) {
    try {
        const resp = await fetch(`${CHAT_API_URL}/api/chat-op/mensajes/${id_evento}`);
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
        const data = await resp.json();

        // Si es silencioso y no cambió la cantidad, evitar rerender brusco
        if (esSilencioso && chatState.mensajes.length === data.mensajes.length) {
            return;
        }

        chatState.mensajes = data.mensajes || [];
        renderizarMensajes(esSilencioso);
    } catch (err) {
        console.error("Error al cargar mensajes:", err);
    }
}

function renderizarMensajes(mantenerScroll = false) {
    const area = document.getElementById("chat-area-mensajes");
    if (!area) return;

    if (chatState.mensajes.length === 0) {
        area.innerHTML = `
            <div style="text-align: center; margin: auto; padding: 24px; color: #64748b; background: rgba(255,255,255,0.7); backdrop-filter: blur(4px); border-radius: 12px; max-width: 380px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);">
                <i class="ph ph-chat-circle-dots" style="font-size: 40px; color: #10b981; margin-bottom: 8px; display: block;"></i>
                <h4 style="margin: 0 0 6px; color: #1e293b;">Bitácora de OP Iniciada</h4>
                <p style="margin: 0; font-size: 13px; line-height: 1.4;">Este es el canal exclusivo de la <strong>OP-${chatState.opActual?.folio || ''}</strong>. Todo comentario, link de vMix o foto quedará archivado como evidencia técnica del evento.</p>
            </div>
        `;
        return;
    }

    const miNombre = (chatState.usuario?.nombre_completo || chatState.usuario?.nombre || '').toUpperCase().trim();
    let html = "";
    let ultimaFecha = "";

    // Banner de mensajes fijados arriba
    const fijados = chatState.mensajes.filter(m => m.es_fijado);
    actualizarBannerFijados(fijados);

    chatState.mensajes.forEach(m => {
        // Separador de fecha si cambia de día
        const fechaDia = m.fecha_hora ? m.fecha_hora.split(' ')[0] : '';
        if (fechaDia && fechaDia !== ultimaFecha) {
            ultimaFecha = fechaDia;
            html += `
                <div class="chat-separador-fecha">
                    <span>${formatearFechaDia(fechaDia)}</span>
                </div>
            `;
        }

        const esMio = miNombre && m.autor_nombre && miNombre.includes(m.autor_nombre.toUpperCase().trim());
        const colorAutor = obtenerColorAutor(m.autor_nombre);
        const hora = formatearHoraChat(m.fecha_hora);
        const fotoAutor = m.id_empleado ? `${CHAT_API_URL}/fotos/${m.id_empleado}.jpg` : "vendor/img/avatar_default.png";

        let contenidoHtml = "";
        if (m.tipo_mensaje === 'IMAGEN' && m.archivo_url) {
            contenidoHtml = `
                <div class="chat-bubble-img" onclick="abrirVisorImagen('${m.archivo_url}')">
                    <img src="${m.archivo_url}" alt="Foto adjunta" loading="lazy">
                </div>
                ${m.mensaje ? `<p class="chat-bubble-texto">${autolinkTexto(m.mensaje)}</p>` : ''}
            `;
        } else if (m.tipo_mensaje === 'ARCHIVO' && m.archivo_url) {
            contenidoHtml = `
                <a href="${m.archivo_url}" target="_blank" class="chat-bubble-archivo">
                    <i class="ph ph-file-arrow-down" style="font-size: 24px;"></i>
                    <span>${m.mensaje || 'Descargar archivo'}</span>
                </a>
            `;
        } else {
            contenidoHtml = `<p class="chat-bubble-texto">${autolinkTexto(m.mensaje)}</p>`;
        }

        // Renderizar reacciones existentes
        let reaccionesHtml = "";
        if (m.reacciones && Object.keys(m.reacciones).length > 0) {
            reaccionesHtml = `<div class="chat-reacciones-row">`;
            for (const [emoji, usuarios] of Object.entries(m.reacciones)) {
                if (usuarios && usuarios.length > 0) {
                    const yaReaccione = usuarios.includes(chatState.usuario?.nombre || '');
                    reaccionesHtml += `
                        <span class="chat-reaccion-pill ${yaReaccione ? 'active' : ''}" onclick="reaccionarAMensaje(${m.id}, '${emoji}')" title="${usuarios.join(', ')}">
                            ${emoji} <small>${usuarios.length}</small>
                        </span>
                    `;
                }
            }
            reaccionesHtml += `</div>`;
        }

        html += `
            <div class="chat-msg-wrapper ${esMio ? 'mio' : 'otro'}" id="msg-${m.id}">
                ${!esMio ? `
                    <img src="${fotoAutor}" class="chat-msg-avatar" onerror="this.src='vendor/img/avatar_default.png'" alt="Avatar">
                ` : ''}
                <div class="chat-bubble ${esMio ? 'bubble-mio' : 'bubble-otro'} ${m.es_fijado ? 'fijado' : ''}">
                    ${m.es_fijado ? '<div class="chat-pin-tag"><i class="ph ph-push-pin"></i> Fijado</div>' : ''}
                    ${!esMio ? `
                        <div class="chat-bubble-header" style="color: ${colorAutor};">
                            <span class="chat-autor-nombre">${m.autor_nombre}</span>
                            <span class="chat-autor-rol">${m.autor_rol || 'STAFF'}</span>
                        </div>
                    ` : ''}
                    
                    ${contenidoHtml}
                    
                    <div class="chat-bubble-footer">
                        ${reaccionesHtml}
                        <span class="chat-hora">${hora}</span>
                        ${esMio ? '<i class="ph ph-checks chat-checks"></i>' : ''}
                    </div>

                    <div class="chat-msg-acciones">
                        <button onclick="reaccionarAMensaje(${m.id}, '👍')" title="Me gusta">👍</button>
                        <button onclick="alternarFijarMensaje(${m.id})" title="${m.es_fijado ? 'Desfijar' : 'Fijar mensaje'}">
                            <i class="ph ph-push-pin"></i>
                        </button>
                    </div>
                </div>
            </div>
        `;
    });

    area.innerHTML = html;

    if (!mantenerScroll) {
        desplazarAlFondo();
    }
}

function desplazarAlFondo() {
    const area = document.getElementById("chat-area-mensajes");
    if (area) {
        setTimeout(() => {
            area.scrollTop = area.scrollHeight;
        }, 50);
    }
}

function formatearFechaDia(fechaStr) {
    try {
        const d = new Date(fechaStr + 'T00:00:00');
        const hoy = new Date();
        if (d.toDateString() === hoy.toDateString()) return "Hoy";
        const ayer = new Date(hoy);
        ayer.setDate(hoy.getDate() - 1);
        if (d.toDateString() === ayer.toDateString()) return "Ayer";
        return d.toLocaleDateString('es-MX', { weekday: 'long', day: 'numeric', month: 'short', year: 'numeric' });
    } catch {
        return fechaStr;
    }
}

function actualizarBannerFijados(fijados) {
    const banner = document.getElementById("chat-banner-fijados");
    if (!banner) return;

    if (!fijados || fijados.length === 0) {
        banner.style.display = "none";
        return;
    }

    const ultimoFijado = fijados[fijados.length - 1];
    banner.style.display = "flex";
    banner.innerHTML = `
        <div class="chat-fijado-content">
            <i class="ph ph-push-pin" style="color: #fbbf24; font-size: 16px;"></i>
            <div>
                <strong>${ultimoFijado.autor_nombre}:</strong> ${ultimoFijado.mensaje.substring(0, 80)}${ultimoFijado.mensaje.length > 80 ? '...' : ''}
            </div>
        </div>
        <button onclick="alternarFijarMensaje(${ultimoFijado.id})" title="Desfijar"><i class="ph ph-x"></i></button>
    `;
}

// ==============================================================================
// ENVIAR MENSAJE
// ==============================================================================
async function enviarMensajeChat() {
    if (!chatState.opActual) return;
    const input = document.getElementById("chat-input-mensaje");
    if (!input) return;

    const texto = input.value.trim();
    if (!texto) return;

    input.value = "";
    input.focus();

    const u = chatState.usuario || {};
    const payload = {
        id_empleado: String(u.id_empleado || ''),
        autor_nombre: u.nombre_completo || u.nombre || "Producción VPRO",
        autor_rol: u.rol || u.puesto || "STAFF",
        mensaje: texto,
        tipo_mensaje: "TEXTO",
        es_fijado: false
    };

    try {
        const id_ev = chatState.opActual.id_evento;
        const resp = await fetch(`${CHAT_API_URL}/api/chat-op/mensajes/${id_ev}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
        const resData = await resp.json();

        // Agregar de inmediato si no llegó por socket
        if (!chatState.mensajes.some(m => m.id === resData.mensaje.id)) {
            chatState.mensajes.push(resData.mensaje);
            renderizarMensajes();
        }
    } catch (err) {
        console.error("Error al enviar mensaje:", err);
        input.value = texto; // Restaurar texto si falló
        alert("No se pudo enviar el mensaje. Verifica tu conexión.");
    }
}

// ==============================================================================
// SUBIR FOTO O ARCHIVO DIRECTO
// ==============================================================================
async function seleccionarYSubirAdjunto() {
    if (!chatState.opActual) return;
    const fileInput = document.getElementById("chat-file-input");
    if (fileInput) fileInput.click();
}

async function procesarAdjuntoSeleccionado(inputEl) {
    if (!inputEl || !inputEl.files || !inputEl.files[0] || !chatState.opActual) return;
    const archivo = inputEl.files[0];
    const u = chatState.usuario || {};

    const formData = new FormData();
    formData.append("archivo", archivo);
    formData.append("autor_nombre", u.nombre_completo || u.nombre || "Producción VPRO");
    formData.append("id_empleado", String(u.id_empleado || ''));
    formData.append("autor_rol", u.rol || "STAFF");
    formData.append("comentario", "");

    // Mostrar feedback visual de subida
    const btnAdj = document.getElementById("btn-chat-adjunto");
    if (btnAdj) btnAdj.innerHTML = '<i class="ph ph-spinner-gap" style="animation: spin 1s linear infinite;"></i>';

    try {
        const id_ev = chatState.opActual.id_evento;
        const resp = await fetch(`${CHAT_API_URL}/api/chat-op/subir-adjunto/${id_ev}`, {
            method: "POST",
            body: formData
        });

        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
        const resData = await resp.json();

        if (!chatState.mensajes.some(m => m.id === resData.mensaje.id)) {
            chatState.mensajes.push(resData.mensaje);
            renderizarMensajes();
        }
    } catch (err) {
        console.error("Error al subir archivo:", err);
        alert("Error al subir la fotografía o archivo.");
    } finally {
        inputEl.value = "";
        if (btnAdj) btnAdj.innerHTML = '<i class="ph ph-camera"></i>';
    }
}

// ==============================================================================
// REACCIONES Y MENSAJES FIJADOS
// ==============================================================================
async function alternarFijarMensaje(id_mensaje) {
    try {
        const resp = await fetch(`${CHAT_API_URL}/api/chat-op/toggle-fijar/${id_mensaje}`, {
            method: "POST"
        });
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
        const data = await resp.json();

        const m = chatState.mensajes.find(msj => msj.id === id_mensaje);
        if (m) {
            m.es_fijado = data.es_fijado;
            renderizarMensajes(true);
        }
    } catch (err) {
        console.error("Error al fijar mensaje:", err);
    }
}

async function reaccionarAMensaje(id_mensaje, emoji = "👍") {
    const u = chatState.usuario || {};
    const nom = u.nombre_completo || u.nombre || "Usuario";

    const formData = new FormData();
    formData.append("emoji", emoji);
    formData.append("usuario_nombre", nom);

    try {
        const resp = await fetch(`${CHAT_API_URL}/api/chat-op/reaccion/${id_mensaje}`, {
            method: "POST",
            body: formData
        });
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
        const data = await resp.json();

        const m = chatState.mensajes.find(msj => msj.id === id_mensaje);
        if (m) {
            m.reacciones = data.reacciones;
            renderizarMensajes(true);
        }
    } catch (err) {
        console.error("Error al reaccionar:", err);
    }
}

// ==============================================================================
// WEBSOCKETS EN TIEMPO REAL
// ==============================================================================
function conectarWebSocketChat(id_evento) {
    if (chatState.ws) {
        try { chatState.ws.close(); } catch (e) {}
        chatState.ws = null;
    }

    try {
        const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
        const host = window.location.host;
        const wsUrl = `${protocol}//${host}/api/chat-op/ws/${id_evento}`;

        const ws = new WebSocket(wsUrl);
        chatState.ws = ws;

        ws.onopen = () => {
            console.log(`[WS] Conectado a canal de chat OP-${id_evento}`);
        };

        ws.onmessage = (event) => {
            try {
                const data = JSON.parse(event.data);
                if (data.tipo === "NUEVO_MENSAJE" && data.mensaje) {
                    if (!chatState.mensajes.some(m => m.id === data.mensaje.id)) {
                        chatState.mensajes.push(data.mensaje);
                        renderizarMensajes();
                    }
                } else if (data.tipo === "MENSAJE_FIJADO_CAMBIO") {
                    const m = chatState.mensajes.find(msj => msj.id === data.id_mensaje);
                    if (m) {
                        m.es_fijado = data.es_fijado;
                        renderizarMensajes(true);
                    }
                } else if (data.tipo === "REACCION_CAMBIO") {
                    const m = chatState.mensajes.find(msj => msj.id === data.id_mensaje);
                    if (m) {
                        m.reacciones = data.reacciones;
                        renderizarMensajes(true);
                    }
                }
            } catch (err) {
                console.warn("[WS] Error al parsear mensaje:", err);
            }
        };

        ws.onclose = () => {
            console.log(`[WS] Desconectado de canal OP-${id_evento}`);
        };

        ws.onerror = (e) => {
            console.warn("[WS] Error de socket:", e);
        };
    } catch (e) {
        console.warn("[WS] No se pudo inicializar WebSocket:", e);
    }
}

// ==============================================================================
// MODAL DE VISOR DE IMÁGENES
// ==============================================================================
function abrirVisorImagen(url) {
    let visor = document.getElementById("chat-visor-modal");
    if (!visor) {
        visor = document.createElement("div");
        visor.id = "chat-visor-modal";
        visor.className = "chat-visor-overlay";
        visor.onclick = () => { visor.style.display = "none"; };
        visor.innerHTML = `
            <div class="chat-visor-content" onclick="event.stopPropagation()">
                <button class="chat-visor-close" onclick="document.getElementById('chat-visor-modal').style.display='none'"><i class="ph ph-x"></i></button>
                <img id="chat-visor-img" src="" alt="Visor de imagen">
                <a id="chat-visor-descargar" href="" download class="chat-visor-btn-descargar"><i class="ph ph-download-simple"></i> Guardar Imagen</a>
            </div>
        `;
        document.body.appendChild(visor);
    }

    const img = document.getElementById("chat-visor-img");
    const aDesc = document.getElementById("chat-visor-descargar");
    if (img) img.src = url;
    if (aDesc) aDesc.href = url;
    visor.style.display = "flex";
}

// Selector de usuario para modo standalone / directo
async function mostrarSelectorUsuarioChat() {
    try {
        const resp = await fetch(`${CHAT_API_URL}/api/empleados`);
        if (!resp.ok) return;
        const empleados = await resp.json();
        const activos = empleados.filter(e => e.rol !== 'BAJA' && e.rol !== 'PROVEEDOR');

        let selectHtml = `<select id="swal-user-select" class="swal2-input" style="font-size: 14px;">`;
        activos.forEach(e => {
            selectHtml += `<option value="${e.id_empleado}">${e.nombre} (${e.puesto || e.depto || 'Staff'})</option>`;
        });
        selectHtml += `</select>`;

        if (typeof Swal !== 'undefined') {
            Swal.fire({
                title: '¿Quién eres?',
                text: 'Selecciona tu usuario para acceder a tus chats de OP:',
                html: selectHtml,
                icon: 'question',
                confirmButtonText: 'Entrar al Chat',
                allowOutsideClick: false
            }).then((result) => {
                if (result.isConfirmed) {
                    const selId = document.getElementById("swal-user-select").value;
                    const encontrado = activos.find(e => String(e.id_empleado) === String(selId));
                    if (encontrado) {
                        guardarSesionChatUsuario(encontrado);
                    }
                }
            });
        }
    } catch (e) {
        console.error("Error al mostrar selector de usuario:", e);
    }
}
