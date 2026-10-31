// ==============================================================================
// MÓDULO: chat_soporte_ui.js
// Canal Corporativo: Soporte TI, Sistemas & Consultas Generales
// VPRO Workspace
// ==============================================================================

const soporteChatState = {
    activo: false,
    mensajes: [],
    info: null,
    ws: null,
    avisoFijado: null
};

// Determina si el usuario tiene rol de Sistemas o Administración
function esPersonalSistemasOAdmin() {
    const u = chatState.usuario || {};
    const rol = (u.rol || '').toUpperCase();
    const puesto = (u.puesto || '').toUpperCase();
    const depto = (u.depto || '').toUpperCase();
    const nom = (u.nombre_completo || u.nombre || '').toUpperCase()
        .normalize("NFD").replace(/[\u0300-\u036f]/g, "");

    const esDirectivo = nom.includes('VILLARREAL') || nom.includes('AGUNDEZ');
    const esSistemas = depto.includes('SISTEMA') || puesto.includes('SISTEMA') || rol.includes('SISTEMA') || nom.includes('CUAUHTEMOC');
    const esAdmin = rol.includes('ADMIN') || depto.includes('DIRECCION');

    return esDirectivo || esSistemas || esAdmin;
}

// ==============================================================================
// CARGA Y RENDERIZADO DEL CANAL DE SOPORTE
// ==============================================================================
async function cargarCanalSoporte() {
    const contenedorLista = document.getElementById("chat-lista-soporte");
    const contenedorMsjs = document.getElementById("chat-area-mensajes");
    if (contenedorMsjs && (!soporteChatState.mensajes || soporteChatState.mensajes.length === 0)) {
        contenedorMsjs.innerHTML = `<div style="display:flex; justify-content:center; align-items:center; height:100%; color:#8696a0;"><i class="ph ph-spinner ph-spin" style="font-size:32px; color:#38bdf8;"></i></div>`;
    }
    const inputMsg = document.getElementById("chat-input-mensaje");

    if (contenedorLista) {
        contenedorLista.innerHTML = `
            <div style="text-align: center; padding: 24px 16px; color: #8696a0;">
                <i class="ph ph-spinner ph-spin" style="font-size: 26px; color: #38bdf8;"></i>
                <p style="margin-top: 8px; font-size: 13px;">Conectando a Mesa de Ayuda TI...</p>
            </div>`;
    }

    try {
        const [resInfo, resMsjs] = await Promise.all([
            fetch(`${CHAT_API_URL}/api/chat-soporte/info`),
            fetch(`${CHAT_API_URL}/api/chat-soporte/mensajes?limit=150`)
        ]);

        if (resInfo.ok) {
            soporteChatState.info = await resInfo.json();
        }
        if (resMsjs.ok) {
            soporteChatState.mensajes = await resMsjs.json();
        }

        renderizarSidebarSoporte();
        activarVentanaSoporte();
        conectarWebSocketSoporte();

        if (inputMsg) {
            inputMsg.placeholder = "¿Dudas de internet, equipos o sistemas? Escribe aquí...";
            inputMsg.focus();
        }

    } catch (err) {
        console.error("Error al cargar canal soporte:", err);
        if (contenedorLista) {
            contenedorLista.innerHTML = `
                <div style="text-align: center; padding: 24px 16px; color: #f87171;">
                    <i class="ph ph-warning-circle" style="font-size: 32px; margin-bottom: 8px;"></i>
                    <p style="font-size: 13px;">No se pudo conectar con Soporte TI.</p>
                    <button onclick="cargarCanalSoporte()" style="margin-top: 10px; padding: 6px 14px; background: #0284c7; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 12px; font-weight: 700;">Reintentar</button>
                </div>`;
        }
    }
}

// Renderiza la tarjeta fija en el panel izquierdo
function renderizarSidebarSoporte() {
    const contenedor = document.getElementById("chat-lista-soporte");
    if (!contenedor) return;

    const info = soporteChatState.info || {};
    const fijado = info.aviso_fijado;

    contenedor.innerHTML = `
        <div onclick="activarVentanaSoporte()" style="background: linear-gradient(135deg, #0c4a6e 0%, #0369a1 100%); border-radius: 12px; padding: 14px 16px; margin: 10px; color: white; cursor: pointer; box-shadow: 0 4px 12px rgba(2, 132, 199, 0.25); border: 1px solid #38bdf8;">
            <div style="display: flex; align-items: center; gap: 12px;">
                <div style="width: 44px; height: 44px; border-radius: 10px; background: rgba(255,255,255,0.18); display: flex; align-items: center; justify-content: center; font-size: 24px; flex-shrink: 0; box-shadow: 0 2px 6px rgba(0,0,0,0.2);">
                    <i class="ph ph-laptop"></i>
                </div>
                <div style="flex: 1; min-width: 0;">
                    <div style="display: flex; align-items: center; justify-content: space-between; gap: 6px;">
                        <h4 style="margin: 0; font-size: 14px; font-weight: 700; color: #ffffff; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                            Mesa de Ayuda TI
                        </h4>
                        <span style="background: #22c55e; color: #052e16; font-size: 10px; font-weight: 800; padding: 2px 7px; border-radius: 10px;">EN LÍNEA</span>
                    </div>
                    <p style="margin: 3px 0 0 0; font-size: 11.5px; color: #bae6fd; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                        Consultas directas a Sistemas y red
                    </p>
                </div>
            </div>
            
            ${fijado ? `
                <div style="margin-top: 10px; background: rgba(15, 23, 42, 0.45); border-left: 3px solid #facc15; padding: 6px 10px; border-radius: 6px; font-size: 11px; color: #fef08a; display: flex; align-items: center; gap: 6px;">
                    <i class="ph ph-push-pin" style="font-size: 13px; color: #facc15;"></i>
                    <span style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><b>Aviso:</b> ${fijado}</span>
                </div>
            ` : ''}

            <div style="margin-top: 10px; display: flex; justify-content: space-between; align-items: center; font-size: 11px; color: #7dd3fc; border-top: 1px solid rgba(255,255,255,0.15); padding-top: 8px;">
                <span><i class="ph ph-chat-circle-dots"></i> ${info.total_mensajes || soporteChatState.mensajes.length} mensajes</span>
                <span style="color: #ffffff; font-weight: 600;">Canal Abierto ➔</span>
            </div>
        </div>

        <div style="padding: 12px 16px; color: #8696a0; font-size: 12px; line-height: 1.4;">
            <div style="background: #182229; border: 1px solid #222e35; border-radius: 10px; padding: 12px;">
                <b style="color: #e9edef; display: flex; align-items: center; gap: 6px; margin-bottom: 6px;">
                    <i class="ph ph-info" style="color: #38bdf8; font-size: 15px;"></i> ¿Para qué sirve este canal?
                </b>
                Usa este espacio para consultas inmediatas como:
                <ul style="margin: 6px 0 0 0; padding-left: 18px; color: #aebac1; font-size: 11.5px;">
                    <li>Reportes de internet o red lenta/caída.</li>
                    <li>Dudas sobre PCs, proyectores o cables.</li>
                    <li>Solicitud de contraseñas de red o accesos.</li>
                    <li>Avisos de mantenimiento técnico general.</li>
                </ul>
            </div>
        </div>
    `;
}

// Activa la ventana de conversación de soporte en el panel central
function activarVentanaSoporte() {
    // En pantallas móviles, contraer barra lateral y desplegar chat
    const panelLateral = document.getElementById("chat-panel-lateral");
    const panelConversacion = document.getElementById("chat-panel-conversacion");
    if (panelLateral && panelConversacion && window.innerWidth < 768) {
        panelLateral.style.display = "none";
        panelConversacion.style.display = "flex";
    }

    actualizarCabeceraSoporte();
    renderizarMensajesSoporte();
}

function actualizarCabeceraSoporte() {
    const elFolio = document.getElementById("chat-header-folio");
    const elTitulo = document.getElementById("chat-header-titulo");
    const elSub = document.getElementById("chat-header-detalles");
    const elLlamado = document.getElementById("chat-header-llamado");
    const elAcciones = document.getElementById("chat-header-acciones");
    const btnCerrarOp = document.getElementById("btn-cerrar-op-chat");

    if (btnCerrarOp) btnCerrarOp.style.display = "none";

    if (elFolio) {
        elFolio.innerText = "TI-SOPORTE";
        elFolio.style.background = "#0284c7";
        elFolio.style.color = "#ffffff";
    }

    if (elTitulo) {
        elTitulo.innerHTML = `
            <span style="display: flex; align-items: center; gap: 8px;">
                <i class="ph ph-laptop" style="color: #38bdf8;"></i> Mesa de Ayuda TI & Consultas Generales
            </span>`;
    }

    if (elSub) {
        elSub.innerText = "Canal directo con Sistemas para internet, equipos de oficina, software y avisos.";
    }

    if (elLlamado) {
        elLlamado.innerHTML = `
            <span style="background: rgba(34, 197, 94, 0.15); color: #4ade80; border: 1px solid #22c55e; padding: 2px 8px; border-radius: 6px; font-weight: 700; font-size: 11px;">
                ● Soporte Activo
            </span>`;
    }

    if (elAcciones) {
        elAcciones.innerHTML = `
            <button class="chat-btn-icon" onclick="cargarCanalSoporte()" title="Actualizar mensajes">
                <i class="ph ph-arrow-clockwise"></i>
            </button>
        `;
    }
}

// Renderiza la lista cronológica de mensajes con estilo WhatsApp
function renderizarMensajesSoporte() {
    const contenedor = document.getElementById("chat-area-mensajes");
    if (!contenedor) return;

    const msjs = soporteChatState.mensajes || [];
    const u = chatState.usuario || {};
    const miId = String(u.id_empleado || "000").trim();
    const miNombreNorm = (u.nombre_completo || u.nombre || "").toUpperCase().trim();
    const esSistemas = esPersonalSistemasOAdmin();

    if (msjs.length === 0) {
        contenedor.innerHTML = `
            <div style="text-align: center; padding: 40px 20px; color: #8696a0;">
                <div style="width: 60px; height: 60px; border-radius: 50%; background: #182229; display: flex; align-items: center; justify-content: center; font-size: 32px; margin: 0 auto 12px; color: #38bdf8;">
                    <i class="ph ph-chats-circle"></i>
                </div>
                <h3 style="color: #e9edef; font-size: 16px; margin-bottom: 6px;">¡Bienvenido a la Mesa de Ayuda TI!</h3>
                <p style="font-size: 13px; max-width: 420px; margin: 0 auto; line-height: 1.5;">
                    ¿Tienes dudas sobre internet, tu equipo de cómputo o necesitas asistencia de Sistemas? Escribe tu mensaje abajo para que todo el equipo te pueda apoyar.
                </p>
            </div>`;
        return;
    }

    let html = "";
    let ultimaFecha = "";

    // Banner de mensaje fijado (si existe)
    const fijado = msjs.slice().reverse().find(m => m.es_fijado);
    if (fijado) {
        html += `
            <div style="position: sticky; top: 0; z-index: 10; background: #0c4a6e; border-left: 4px solid #38bdf8; border-radius: 8px; padding: 8px 12px; margin-bottom: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.3); display: flex; align-items: center; justify-content: space-between; gap: 10px;">
                <div style="display: flex; align-items: center; gap: 8px; font-size: 12.5px; color: #e0f2fe; overflow: hidden;">
                    <i class="ph ph-push-pin" style="color: #38bdf8; font-size: 16px; flex-shrink: 0;"></i>
                    <span style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                        <b>Aviso de ${fijado.autor_nombre}:</b> "${fijado.mensaje}"
                    </span>
                </div>
                ${esSistemas ? `
                    <button onclick="alternarFijadoSoporte(${fijado.id})" style="background: none; border: none; color: #94a3b8; cursor: pointer; font-size: 12px; text-decoration: underline;">
                        Desfijar
                    </button>
                ` : ''}
            </div>
        `;
    }

    msjs.forEach((m) => {
        const fechaMsg = m.fecha_hora_str ? m.fecha_hora_str.substring(0, 10) : "";
        if (fechaMsg && fechaMsg !== ultimaFecha) {
            ultimaFecha = fechaMsg;
            html += `
                <div class="chat-separador-fecha">
                    <span>${formatearFechaSeparador(fechaMsg)}</span>
                </div>`;
        }

        const autorNorm = (m.autor_nombre || "").toUpperCase().trim();
        const esMio = (String(m.id_empleado).trim() === miId && miId !== "000") || (autorNorm === miNombreNorm);
        const horaStr = m.fecha_hora_str ? m.fecha_hora_str.substring(11, 16) : "";
        const esSistemasAutor = (m.autor_rol || "").toUpperCase().includes("SISTEMA") || autorNorm.includes("CUAUHTEMOC");

        const bubbleClass = esMio ? "mio" : "otro";
        const bubbleBg = esMio ? "var(--wa-msg-out-bg)" : "var(--wa-msg-in-bg)";
        const fotoAutor = m.foto_url || `/fotos/${m.id_empleado}.jpg`;

        // Renderizado de contenido (texto, foto, link)
        let contenidoHtml = "";
        if (m.tipo_mensaje === "FOTO" && m.archivo_url) {
            contenidoHtml = `
                <div style="margin-bottom: 6px; border-radius: 8px; overflow: hidden; max-width: 320px;">
                    <img src="${m.archivo_url}" alt="Foto" style="width: 100%; display: block; cursor: pointer;" onclick="abrirVisorFotoChat('${m.archivo_url}')">
                </div>
                ${m.mensaje ? `<div style="font-size: 13.5px; line-height: 1.4;">${escaparHTML(m.mensaje)}</div>` : ''}
            `;
        } else if (m.tipo_mensaje === "LINK") {
            const urlDetectada = m.mensaje.match(/https?:\/\/[^\s]+/i)?.[0] || m.mensaje;
            contenidoHtml = `
                <div style="font-size: 13.5px; line-height: 1.4;">
                    <a href="${urlDetectada}" target="_blank" style="color: #38bdf8; text-decoration: underline; word-break: break-all;">
                        <i class="ph ph-link"></i> ${escaparHTML(m.mensaje)}
                    </a>
                </div>`;
        } else {
            contenidoHtml = `<div style="font-size: 13.5px; line-height: 1.4; word-break: break-word;">${escaparHTML(m.mensaje)}</div>`;
        }

        // Renderizado de reacciones
        let reaccionesHtml = "";
        const reacs = m.reacciones || {};
        const tieneReacs = Object.keys(reacs).length > 0;
        if (tieneReacs) {
            reaccionesHtml = `<div style="display: flex; gap: 4px; margin-top: 4px; flex-wrap: wrap;">`;
            for (const [emoji, uids] of Object.entries(reacs)) {
                if (Array.isArray(uids) && uids.length > 0) {
                    const yoReaccione = uids.includes(miId);
                    reaccionesHtml += `
                        <span onclick="reaccionarMensajeSoporte(${m.id}, '${emoji}')" 
                              style="background: ${yoReaccione ? 'rgba(56, 189, 248, 0.25)' : 'rgba(255,255,255,0.08)'}; border: 1px solid ${yoReaccione ? '#38bdf8' : 'rgba(255,255,255,0.15)'}; border-radius: 12px; padding: 1px 6px; font-size: 11px; cursor: pointer; display: inline-flex; align-items: center; gap: 2px;">
                            ${emoji} <b style="font-size: 10px;">${uids.length}</b>
                        </span>`;
                }
            }
            reaccionesHtml += `</div>`;
        }

        html += `
            <div class="chat-msg-wrapper ${bubbleClass}" id="soporte-msg-${m.id}">
                ${!esMio ? `
                    <img src="${fotoAutor}" class="chat-msg-avatar" alt="Foto" onerror="this.src='vendor/img/avatar_default.png'">
                ` : ''}

                <div class="chat-bubble" style="background-color: ${bubbleBg}; position: relative; padding: 6px 9px 8px 9px; border-radius: 8px;">
                    ${!esMio ? `
                        <div style="font-size: 11.5px; font-weight: 700; color: ${esSistemasAutor ? '#38bdf8' : '#25d366'}; margin-bottom: 2px; display: flex; align-items: center; gap: 6px;">
                            <span>${escaparHTML(m.autor_nombre)}</span>
                            ${esSistemasAutor ? `<span style="background: #0284c7; color: white; padding: 1px 5px; border-radius: 4px; font-size: 9.5px; font-weight: 800;">SISTEMAS</span>` : ''}
                        </div>
                    ` : ''}

                    ${contenidoHtml}
                    ${reaccionesHtml}

                    <div style="display: flex; justify-content: flex-end; align-items: center; gap: 4px; margin-top: 2px; font-size: 10.5px; color: var(--wa-text-secondary);">
                        <span>${horaStr}</span>
                        ${esMio ? `<i class="ph ph-check-double" style="color: var(--wa-accent);"></i>` : ''}
                    </div>

                    <!-- Botones de reacción al pasar el mouse -->
                    <div class="chat-msg-acciones">
                        <button onclick="reaccionarMensajeSoporte(${m.id}, '👍')" title="De acuerdo">👍</button>
                        <button onclick="reaccionarMensajeSoporte(${m.id}, '🆗')" title="Entendido">🆗</button>
                        <button onclick="reaccionarMensajeSoporte(${m.id}, '⚠️')" title="Importante">⚠️</button>
                        ${esSistemas ? `
                            <button onclick="alternarFijadoSoporte(${m.id})" title="${m.es_fijado ? 'Desfijar' : 'Fijar como aviso'}">📌</button>
                        ` : ''}
                    </div>
                </div>
            </div>
        `;
    });

    contenedor.innerHTML = html;
    if (typeof desplazarAlFondo === 'function') {
        desplazarAlFondo();
    } else {
        setTimeout(() => { contenedor.scrollTop = contenedor.scrollHeight; }, 50);
    }
}

// ==============================================================================
// ENVIAR MENSAJE A SOPORTE
// ==============================================================================
async function enviarMensajeSoporte() {
    const input = document.getElementById("chat-input-mensaje");
    if (!input) return;

    const texto = input.value.trim();
    if (!texto) return;

    input.value = "";
    input.focus();

    const u = chatState.usuario || {};
    const payload = {
        id_empleado: String(u.id_empleado || "000"),
        autor_nombre: u.nombre_completo || u.nombre || "Colaborador VPRO",
        autor_rol: u.rol || u.puesto || "COLABORADOR",
        mensaje: texto,
        tipo_mensaje: "TEXTO",
        es_fijado: false
    };

    try {
        const resp = await fetch(`${CHAT_API_URL}/api/chat-soporte/mensajes`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
        const resData = await resp.json();

        if (resData.mensaje && !soporteChatState.mensajes.some(m => m.id === resData.mensaje.id)) {
            soporteChatState.mensajes.push(resData.mensaje);
            renderizarMensajesSoporte();
        }
    } catch (err) {
        console.error("Error al enviar mensaje a soporte:", err);
        input.value = texto;
        alert("No se pudo enviar el mensaje a Soporte TI. Verifica tu conexión.");
    }
}

// ==============================================================================
// SUBIR FOTO O CAPTURA A SOPORTE
// ==============================================================================
async function subirArchivoSoporte(archivo) {
    if (!archivo) return;
    const u = chatState.usuario || {};

    const formData = new FormData();
    formData.append("archivo", archivo);
    formData.append("id_empleado", String(u.id_empleado || "000"));

    try {
        const resUpload = await fetch(`${CHAT_API_URL}/api/chat-soporte/subir-adjunto`, {
            method: "POST",
            body: formData
        });

        if (!resUpload.ok) throw new Error("Error al subir archivo");
        const dataUpload = await resUpload.json();

        const esImagen = archivo.type.startsWith("image/");
        const payload = {
            id_empleado: String(u.id_empleado || "000"),
            autor_nombre: u.nombre_completo || u.nombre || "Colaborador VPRO",
            autor_rol: u.rol || u.puesto || "COLABORADOR",
            mensaje: esImagen ? "📸 Captura adjunta" : `📎 ${archivo.name}`,
            tipo_mensaje: esImagen ? "FOTO" : "ARCHIVO",
            archivo_url: dataUpload.archivo_url,
            es_fijado: false
        };

        const resp = await fetch(`${CHAT_API_URL}/api/chat-soporte/mensajes`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (resp.ok) {
            const resData = await resp.json();
            if (resData.mensaje && !soporteChatState.mensajes.some(m => m.id === resData.mensaje.id)) {
                soporteChatState.mensajes.push(resData.mensaje);
                renderizarMensajesSoporte();
            }
        }
    } catch (e) {
        console.error("Error al subir adjunto a soporte:", e);
        alert("Error al subir el archivo a Soporte TI.");
    }
}

// ==============================================================================
// REACCIONAR Y FIJAR
// ==============================================================================
async function reaccionarMensajeSoporte(mensajeId, emoji) {
    const u = chatState.usuario || {};
    try {
        const resp = await fetch(`${CHAT_API_URL}/api/chat-soporte/mensajes/${mensajeId}/reaccionar`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                emoji: emoji,
                usuario_id: String(u.id_empleado || "000"),
                usuario_nombre: u.nombre_completo || u.nombre || "Colaborador"
            })
        });

        if (resp.ok) {
            const data = await resp.json();
            const msg = soporteChatState.mensajes.find(m => m.id === mensajeId);
            if (msg) {
                msg.reacciones = data.reacciones;
                renderizarMensajesSoporte();
            }
        }
    } catch (e) {
        console.error("Error al reaccionar:", e);
    }
}

async function alternarFijadoSoporte(mensajeId) {
    try {
        const resp = await fetch(`${CHAT_API_URL}/api/chat-soporte/mensajes/${mensajeId}/fijar`, {
            method: "POST"
        });
        if (resp.ok) {
            const data = await resp.json();
            const msg = soporteChatState.mensajes.find(m => m.id === mensajeId);
            if (msg) {
                msg.es_fijado = data.es_fijado;
                renderizarMensajesSoporte();
                renderizarSidebarSoporte();
            }
        }
    } catch (e) {
        console.error("Error al fijar aviso:", e);
    }
}

// ==============================================================================
// CONEXIÓN WEBSOCKET EN TIEMPO REAL
// ==============================================================================
function conectarWebSocketSoporte() {
    if (soporteChatState.ws) {
        try { soporteChatState.ws.close(); } catch(e){}
        soporteChatState.ws = null;
    }

    try {
        let wsUrl = "";
        if (CHAT_API_URL && CHAT_API_URL.startsWith("http")) {
            wsUrl = CHAT_API_URL.replace(/^http/, "ws") + "/api/chat-soporte/ws";
        } else {
            const loc = window.location;
            const proto = loc.protocol === "https:" ? "wss:" : "ws:";
            wsUrl = `${proto}//${loc.host}/api/chat-soporte/ws`;
        }

        const ws = new WebSocket(wsUrl);
        soporteChatState.ws = ws;

        ws.onopen = () => {
            console.log("🟢 Conectado en tiempo real a Mesa de Ayuda TI");
        };

        ws.onmessage = (event) => {
            try {
                const data = JSON.parse(event.data);
                if (data.tipo === "NUEVO_MENSAJE_SOPORTE" && data.mensaje) {
                    const nuevo = data.mensaje;
                    if (!soporteChatState.mensajes.some(m => m.id === nuevo.id)) {
                        soporteChatState.mensajes.push(nuevo);
                        
                        // Sonido si el mensaje viene de otra persona
                        const miId = String(chatState.usuario?.id_empleado || "000").trim();
                        if (String(nuevo.id_empleado).trim() !== miId) {
                            if (typeof reproducirTimbreVPRO === 'function') {
                                reproducirTimbreVPRO();
                            }
                        }

                        if (chatState.arista === 'soporte') {
                            renderizarMensajesSoporte();
                        }
                    }
                } else if (data.tipo === "REACCION_SOPORTE") {
                    const msg = soporteChatState.mensajes.find(m => m.id === data.mensaje_id);
                    if (msg) {
                        msg.reacciones = data.reacciones;
                        if (chatState.arista === 'soporte') renderizarMensajesSoporte();
                    }
                } else if (data.tipo === "FIJADO_SOPORTE_CAMBIO") {
                    const msg = soporteChatState.mensajes.find(m => m.id === data.mensaje_id);
                    if (msg) {
                        msg.es_fijado = data.es_fijado;
                        if (chatState.arista === 'soporte') {
                            renderizarMensajesSoporte();
                            renderizarSidebarSoporte();
                        }
                    }
                }
            } catch (err) {
                console.error("Error al procesar socket soporte:", err);
            }
        };

        ws.onclose = () => {
            console.log("🔴 Desconectado de Mesa de Ayuda TI");
        };

    } catch (e) {
        console.error("Error al abrir socket de soporte:", e);
    }
}
