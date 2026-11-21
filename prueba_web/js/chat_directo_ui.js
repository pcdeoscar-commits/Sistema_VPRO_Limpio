// ==============================================================================
// MÓDULO: chat_directo_ui.js
// Canal Corporativo: Mensajes Directos 1 a 1 entre Colaboradores (Sin Grupos)
// VPRO Workspace - ISO 9001:2015
// ==============================================================================

const directoChatState = {
    activo: false,
    conversaciones: [],
    directorio: [],
    chatActual: null,
    mensajes: [],
    filtroBusqueda: '',
    ws: null
};

// Filtra la lista de conversaciones o directorio
function filtrarDirectoChat(termino) {
    directoChatState.filtroBusqueda = (termino || '').toLowerCase().trim();
    renderizarSidebarDirecto();
}

// ==============================================================================
// CARGAR BANDEJA DE CONVERSACIONES DIRECTAS 1 A 1
// ==============================================================================
async function cargarCanalDirecto() {
    const contenedorLista = document.getElementById("chat-lista-directo");
    const contenedorMsjs = document.getElementById("chat-area-mensajes");
    const inputMsg = document.getElementById("chat-input-mensaje");

    if (contenedorMsjs && (!directoChatState.mensajes || directoChatState.mensajes.length === 0)) {
        contenedorMsjs.innerHTML = `<div style="display:flex; justify-content:center; align-items:center; height:100%; color:#8696a0;"><i class="ph ph-spinner ph-spin" style="font-size:32px; color:#8b5cf6;"></i></div>`;
    }

    if (contenedorLista) {
        contenedorLista.innerHTML = `
            <div style="text-align: center; padding: 24px 16px; color: #8696a0;">
                <i class="ph ph-spinner ph-spin" style="font-size: 26px; color: #8b5cf6;"></i>
                <p style="margin-top: 8px; font-size: 13px;">Cargando mensajes directos...</p>
            </div>`;
    }

    const u = chatState.usuario || {};
    const miId = String(u.id_empleado || "000").trim();

    try {
        const [resConv, resDir] = await Promise.all([
            fetch(`${CHAT_API_URL}/api/chat-directo/conversaciones?usuario_id=${encodeURIComponent(miId)}`),
            fetch(`${CHAT_API_URL}/api/chat-directo/directorio?usuario_id=${encodeURIComponent(miId)}`)
        ]);

        if (resConv.ok) {
            directoChatState.conversaciones = await resConv.json();
        }
        if (resDir.ok) {
            directoChatState.directorio = await resDir.json();
        }

        actualizarBadgeDirecto();
        renderizarSidebarDirecto();
        conectarWebSocketDirecto(miId);

        if (inputMsg) {
            inputMsg.placeholder = "Escribe un mensaje directo privado...";
            inputMsg.focus();
        }

        // Si ya hay una conversación seleccionada, conservarla; sino seleccionar la primera si existe
        if (directoChatState.chatActual) {
            const existe = directoChatState.conversaciones.find(c => String(c.companero_id) === String(directoChatState.chatActual.companero_id));
            if (existe) {
                seleccionarDirectoChat(existe);
            } else if (directoChatState.conversaciones.length > 0) {
                seleccionarDirectoChat(directoChatState.conversaciones[0]);
            } else {
                mostrarBienvenidaDirecto();
            }
        } else if (directoChatState.conversaciones.length > 0) {
            seleccionarDirectoChat(directoChatState.conversaciones[0]);
        } else {
            mostrarBienvenidaDirecto();
        }

    } catch (err) {
        console.error("Error al cargar chat directo:", err);
        if (contenedorLista) {
            contenedorLista.innerHTML = `
                <div style="text-align: center; padding: 24px 16px; color: #f87171;">
                    <i class="ph ph-warning-circle" style="font-size: 32px; margin-bottom: 8px;"></i>
                    <p style="font-size: 13px;">No se pudo conectar con Mensajes Directos.</p>
                    <button onclick="cargarCanalDirecto()" style="margin-top: 10px; padding: 6px 14px; background: #8b5cf6; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 12px; font-weight: 700;">Reintentar</button>
                </div>`;
        }
    }
}

// Actualiza el badge de notificaciones de la pestaña Directos
function actualizarBadgeDirecto() {
    const totalNoLeidos = directoChatState.conversaciones.reduce((acc, c) => acc + (c.no_leidos || 0), 0);
    const badgeEl = document.getElementById("badge-directo-no-leidos");
    if (badgeEl) {
        if (totalNoLeidos > 0) {
            badgeEl.textContent = totalNoLeidos;
            badgeEl.style.display = "inline-block";
        } else {
            badgeEl.style.display = "none";
        }
    }
}

// Renderiza la barra lateral con botón para nuevo chat y lista de chats
function renderizarSidebarDirecto() {
    const contenedor = document.getElementById("chat-lista-directo");
    if (!contenedor) return;

    let lista = directoChatState.conversaciones || [];

    if (directoChatState.filtroBusqueda) {
        const q = directoChatState.filtroBusqueda;
        lista = lista.filter(c => 
            (c.companero_nombre || '').toLowerCase().includes(q) ||
            String(c.companero_id || '').toLowerCase().includes(q) ||
            (c.companero_puesto || '').toLowerCase().includes(q) ||
            (c.companero_depto || '').toLowerCase().includes(q)
        );
    }

    let itemsHtml = "";
    if (lista.length === 0) {
        itemsHtml = `
            <div style="text-align: center; padding: 32px 16px; color: #8696a0;">
                <i class="ph ph-chat-circle-dots" style="font-size: 40px; color: #8b5cf6; opacity: 0.6; margin-bottom: 8px;"></i>
                <h4 style="color: #e9edef; font-size: 14px; margin-bottom: 4px;">
                    ${directoChatState.filtroBusqueda ? 'Sin coincidencias' : 'Sin chats directos aún'}
                </h4>
                <p style="font-size: 12px; line-height: 1.4; margin-bottom: 14px;">
                    ${directoChatState.filtroBusqueda ? 'No se encontraron colaboradores con ese término.' : 'Inicia una conversación privada 1 a 1 con cualquier compañero tocando el botón de arriba.'}
                </p>
                <button onclick="abrirModalNuevoChatDirecto()" style="background: linear-gradient(135deg, #8b5cf6 0%, #6366f1 100%); color: white; border: none; padding: 8px 16px; border-radius: 8px; font-weight: 700; font-size: 12px; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 8px rgba(139,92,246,0.3);">
                    <i class="ph ph-user-plus" style="font-size: 16px;"></i> Nuevo Mensaje
                </button>
            </div>
        `;
    } else {
        itemsHtml = lista.map(conv => {
            const esSeleccionado = directoChatState.chatActual && (String(directoChatState.chatActual.companero_id) === String(conv.companero_id));
            const foto = conv.foto_url ? conv.foto_url : `${CHAT_API_URL}/fotos/${conv.companero_id}.jpg`;
            const noLeidos = conv.no_leidos || 0;

            return `
                <div class="chat-op-item ${esSeleccionado ? 'active' : ''}" 
                     onclick="seleccionarDirectoChatPorId('${conv.companero_id}')"
                     style="display: flex; align-items: center; gap: 12px; padding: 12px 14px; cursor: pointer; border-bottom: 1px solid #1f2c34; transition: background .15s; background: ${esSeleccionado ? '#2a3942' : 'transparent'};">
                    <div style="position: relative; flex-shrink: 0;">
                        <img src="${foto}" 
                             onerror="this.src='vendor/img/avatar_default.png'" 
                             style="width: 44px; height: 44px; border-radius: 50%; object-fit: cover; border: 2px solid ${noLeidos > 0 ? '#8b5cf6' : '#334155'};">
                        ${noLeidos > 0 ? '<span style="position: absolute; bottom: -2px; right: -2px; width: 14px; height: 14px; background: #8b5cf6; border-radius: 50%; border: 2px solid #111b21;"></span>' : ''}
                    </div>
                    <div style="flex: 1; min-width: 0;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 3px;">
                            <h4 style="margin: 0; font-size: 13.5px; font-weight: 700; color: #e9edef; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                ${conv.companero_nombre}
                            </h4>
                            <span style="font-size: 10.5px; color: #8696a0; flex-shrink: 0;">${conv.ultima_hora ? conv.ultima_hora.split(' ')[1]?.substring(0,5) || '' : ''}</span>
                        </div>
                        <div style="font-size: 11.5px; color: #8696a0; margin-bottom: 3px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                            ${conv.companero_puesto || 'Colaborador'} • ${conv.companero_depto || 'General'}
                        </div>
                        <div style="display: flex; justify-content: space-between; align-items: center; font-size: 12px; color: ${noLeidos > 0 ? '#f3e8ff' : '#8696a0'}; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                            <span style="overflow: hidden; text-overflow: ellipsis; ${noLeidos > 0 ? 'font-weight: 600;' : ''}">${conv.ultimo_mensaje || 'Conversación iniciada'}</span>
                            <div style="flex-shrink: 0; display: flex; align-items: center; margin-left: 6px;">
                                ${noLeidos > 0 ? `
                                    <span style="background: #8b5cf6; color: #ffffff; padding: 1.5px 7px; border-radius: 10px; font-size: 10.5px; font-weight: 800;">${noLeidos}</span>
                                ` : ''}
                            </div>
                        </div>
                    </div>
                </div>
            `;
        }).join("");
    }

    contenedor.innerHTML = `
        <div style="padding: 10px 14px; background: #111b21; border-bottom: 1px solid #1f2c34; display: flex; justify-content: space-between; align-items: center; gap: 8px;">
            <span style="font-size: 11.5px; font-weight: 700; color: #a78bfa; text-transform: uppercase; letter-spacing: 0.5px; display: flex; align-items: center; gap: 5px;">
                <i class="ph ph-chat-circle-dots"></i> Chats 1 a 1 (${directoChatState.conversaciones.length})
            </span>
            <button onclick="abrirModalNuevoChatDirecto()" 
                    title="Iniciar conversación con cualquier compañero"
                    style="background: linear-gradient(135deg, #8b5cf6 0%, #6366f1 100%); color: white; border: none; padding: 5px 12px; border-radius: 6px; font-weight: 700; font-size: 11.5px; cursor: pointer; display: flex; align-items: center; gap: 5px; box-shadow: 0 2px 6px rgba(139,92,246,0.3);">
                <i class="ph ph-user-plus" style="font-size: 14px;"></i> Nuevo
            </button>
        </div>
        ${itemsHtml}
    `;
}

function seleccionarDirectoChatPorId(companeroId) {
    let conv = directoChatState.conversaciones.find(c => String(c.companero_id) === String(companeroId));
    if (!conv) {
        // Si no está en conversaciones activas pero está en el directorio
        const emp = directoChatState.directorio.find(e => String(e.id_empleado) === String(companeroId));
        if (emp) {
            conv = {
                companero_id: String(emp.id_empleado),
                companero_nombre: emp.nombre,
                companero_puesto: emp.puesto,
                companero_depto: emp.depto,
                foto_url: emp.foto_url,
                no_leidos: 0,
                ultimo_mensaje: "",
                ultima_hora: ""
            };
        }
    }
    if (conv) seleccionarDirectoChat(conv);
}

// Activa una conversación directa en el panel principal
async function seleccionarDirectoChat(conv) {
    if (!conv) return;

    directoChatState.chatActual = conv;
    renderizarSidebarDirecto();

    // En pantallas móviles, contraer barra lateral y desplegar chat
    const panelLateral = document.getElementById("chat-panel-lateral");
    const panelConversacion = document.getElementById("chat-panel-conversacion");
    if (panelLateral && panelConversacion && window.innerWidth < 768) {
        panelLateral.style.display = "none";
        panelConversacion.style.display = "flex";
    }

    actualizarCabeceraDirecto(conv);

    const u = chatState.usuario || {};
    const miId = String(u.id_empleado || "000").trim();
    const cid = String(conv.companero_id).trim();

    // Cargar mensajes de esta conversación directa
    const contenedorMsjs = document.getElementById("chat-area-mensajes");
    if (contenedorMsjs) {
        contenedorMsjs.innerHTML = `<div style="display:flex; justify-content:center; align-items:center; height:100%; color:#8696a0;"><i class="ph ph-spinner ph-spin" style="font-size:32px; color:#8b5cf6;"></i></div>`;
    }

    try {
        const resp = await fetch(`${CHAT_API_URL}/api/chat-directo/mensajes/${encodeURIComponent(cid)}?usuario_id=${encodeURIComponent(miId)}&limit=150`);
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);

        directoChatState.mensajes = await resp.json();

        // Limpiar contador no leídos de esta conversación localmente
        conv.no_leidos = 0;
        actualizarBadgeDirecto();
        renderizarSidebarDirecto();

        renderizarMensajesDirecto();

    } catch (err) {
        console.error("Error al cargar mensajes directos:", err);
        if (contenedorMsjs) {
            contenedorMsjs.innerHTML = `
                <div style="text-align: center; padding: 30px; color: #f87171;">
                    <i class="ph ph-warning-circle" style="font-size: 32px; margin-bottom: 8px;"></i>
                    <p>No se pudieron cargar los mensajes de este chat.</p>
                </div>`;
        }
    }
}

function mostrarBienvenidaDirecto() {
    const contenedorMsjs = document.getElementById("chat-area-mensajes");
    if (contenedorMsjs) {
        contenedorMsjs.innerHTML = `
            <div style="text-align: center; padding: 40px 20px; color: #8696a0; height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                <div style="width: 70px; height: 70px; border-radius: 50%; background: #182229; display: flex; align-items: center; justify-content: center; font-size: 36px; margin-bottom: 14px; color: #8b5cf6;">
                    <i class="ph ph-chats-circle"></i>
                </div>
                <h3 style="color: #e9edef; font-size: 16px; margin-bottom: 6px;">Mensajes Directos 1 a 1</h3>
                <p style="font-size: 13px; max-width: 380px; line-height: 1.5; margin-bottom: 16px;">
                    Comunícate en privado con cualquier compañero de la empresa sin crear grupos.
                </p>
                <button onclick="abrirModalNuevoChatDirecto()" style="background: linear-gradient(135deg, #8b5cf6 0%, #6366f1 100%); color: white; border: none; padding: 8px 18px; border-radius: 8px; font-weight: 700; font-size: 13px; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 10px rgba(139,92,246,0.3);">
                    <i class="ph ph-user-plus" style="font-size: 16px;"></i> Iniciar Conversación
                </button>
            </div>`;
    }
}

function actualizarCabeceraDirecto(conv) {
    const elFolio = document.getElementById("chat-header-folio");
    const elTitulo = document.getElementById("chat-header-titulo");
    const elSub = document.getElementById("chat-header-detalles");
    const elLlamado = document.getElementById("chat-header-llamado");
    const elAcciones = document.getElementById("chat-header-acciones");
    const btnCerrarOp = document.getElementById("btn-cerrar-op-chat");

    if (btnCerrarOp) btnCerrarOp.style.display = "none";

    if (elFolio) {
        elFolio.innerText = "1 a 1";
        elFolio.style.background = "#8b5cf6";
        elFolio.style.color = "#ffffff";
    }

    if (elTitulo) {
        elTitulo.innerHTML = `
            <span style="display: flex; align-items: center; gap: 8px;">
                <i class="ph ph-chat-circle-dots" style="color: #a78bfa;"></i> ${escaparHTML(conv.companero_nombre)}
            </span>`;
    }

    if (elSub) {
        elSub.innerText = `${conv.companero_puesto || 'Colaborador'} • ${conv.companero_depto || 'General'}`;
    }

    if (elLlamado) {
        elLlamado.innerHTML = `
            <span style="background: rgba(139, 92, 246, 0.15); color: #c4b5fd; border: 1px solid #8b5cf6; padding: 2px 8px; border-radius: 6px; font-weight: 700; font-size: 11px;">
                ● Privado Directo
            </span>`;
    }

    if (elAcciones) {
        elAcciones.innerHTML = `
            <button class="chat-btn-icon" onclick="cargarCanalDirecto()" title="Actualizar mensajes">
                <i class="ph ph-arrow-clockwise"></i>
            </button>
            <button class="chat-btn-icon" onclick="abrirModalNuevoChatDirecto()" title="Abrir otro chat">
                <i class="ph ph-user-plus" style="color: #a78bfa;"></i>
            </button>
        `;
    }
}

// Renderiza los mensajes con estilo WhatsApp 1-1
function renderizarMensajesDirecto() {
    const contenedor = document.getElementById("chat-area-mensajes");
    if (!contenedor) return;

    const msjs = directoChatState.mensajes || [];
    const u = chatState.usuario || {};
    const miId = String(u.id_empleado || "000").trim();
    const convActual = directoChatState.chatActual || {};

    if (msjs.length === 0) {
        contenedor.innerHTML = `
            <div style="text-align: center; padding: 40px 20px; color: #8696a0;">
                <div style="width: 60px; height: 60px; border-radius: 50%; background: #182229; display: flex; align-items: center; justify-content: center; font-size: 32px; margin: 0 auto 12px; color: #8b5cf6;">
                    <i class="ph ph-chats-circle"></i>
                </div>
                <h3 style="color: #e9edef; font-size: 16px; margin-bottom: 6px;">
                    Conversación con ${escaparHTML(convActual.companero_nombre || 'Colaborador')}
                </h3>
                <p style="font-size: 13px; max-width: 400px; margin: 0 auto; line-height: 1.5;">
                    Este canal es privado 1 a 1 entre ustedes dos. Escribe abajo para iniciar la conversación.
                </p>
            </div>`;
        return;
    }

    let html = "";
    let ultimaFecha = "";

    msjs.forEach((m) => {
        const fechaMsg = m.fecha_hora_str ? m.fecha_hora_str.substring(0, 10) : "";
        if (fechaMsg && fechaMsg !== ultimaFecha) {
            ultimaFecha = fechaMsg;
            html += `
                <div class="chat-separador-fecha">
                    <span>${formatearFechaSeparador(fechaMsg)}</span>
                </div>`;
        }

        const autId = String(m.remitente_id || "").trim();
        const esMio = (autId === miId);
        const horaStr = m.fecha_hora_str ? m.fecha_hora_str.substring(11, 16) : "";

        const bubbleClass = esMio ? "mio" : "otro";
        const bubbleBg = esMio ? "var(--wa-msg-out-bg)" : "var(--wa-msg-in-bg)";
        const fotoAutor = m.foto_url || `${CHAT_API_URL}/fotos/${autId}.jpg`;

        let contenidoHtml = "";
        if (m.tipo_mensaje === "FOTO" && m.archivo_url) {
            contenidoHtml = `
                <div style="margin-bottom: 6px; border-radius: 8px; overflow: hidden; max-width: 320px;">
                    <img src="${m.archivo_url}" alt="Foto" style="width: 100%; display: block; cursor: pointer;" onclick="window.open('${m.archivo_url}', '_blank')">
                </div>
                ${m.mensaje ? `<div style="font-size: 13.5px; line-height: 1.4;">${escaparHTML(m.mensaje)}</div>` : ''}
            `;
        } else if (m.tipo_mensaje === "ARCHIVO" && m.archivo_url) {
            contenidoHtml = `
                <a href="${m.archivo_url}" target="_blank" style="display: flex; align-items: center; gap: 8px; background: rgba(0,0,0,0.2); padding: 8px 12px; border-radius: 6px; color: #a78bfa; text-decoration: none; margin-bottom: 4px;">
                    <i class="ph ph-file-text" style="font-size: 20px;"></i>
                    <span style="font-size: 12.5px; font-weight: 600; text-decoration: underline;">${escaparHTML(m.mensaje || 'Descargar archivo')}</span>
                </a>
            `;
        } else if (m.tipo_mensaje === "LINK") {
            const urlDetectada = m.mensaje.match(/https?:\/\/[^\s]+/i)?.[0] || m.mensaje;
            contenidoHtml = `
                <div style="font-size: 13.5px; line-height: 1.4;">
                    <a href="${urlDetectada}" target="_blank" style="color: #a78bfa; text-decoration: underline; word-break: break-all;">
                        <i class="ph ph-link"></i> ${escaparHTML(m.mensaje)}
                    </a>
                </div>`;
        } else {
            contenidoHtml = `<div style="font-size: 13.5px; line-height: 1.4; word-break: break-word;">${escaparHTML(m.mensaje)}</div>`;
        }

        // Reacciones emoji
        let reaccionesHtml = "";
        const reacs = m.reacciones || {};
        if (Object.keys(reacs).length > 0) {
            reaccionesHtml = `<div style="display: flex; gap: 4px; margin-top: 4px; flex-wrap: wrap;">`;
            for (const [emoji, uids] of Object.entries(reacs)) {
                if (Array.isArray(uids) && uids.length > 0) {
                    const yoReaccione = uids.includes(miId);
                    reaccionesHtml += `
                        <span onclick="reaccionarMensajeDirecto(${m.id}, '${emoji}')" 
                              style="background: ${yoReaccione ? 'rgba(139, 92, 246, 0.25)' : 'rgba(255,255,255,0.08)'}; border: 1px solid ${yoReaccione ? '#8b5cf6' : 'rgba(255,255,255,0.15)'}; border-radius: 12px; padding: 1px 6px; font-size: 11px; cursor: pointer; display: inline-flex; align-items: center; gap: 2px;">
                            ${emoji} <b style="font-size: 10px;">${uids.length}</b>
                        </span>`;
                }
            }
            reaccionesHtml += `</div>`;
        }

        html += `
            <div class="chat-msg-wrapper ${bubbleClass}" id="directo-msg-${m.id}">
                ${!esMio ? `
                    <img src="${fotoAutor}" class="chat-msg-avatar" alt="Foto" onerror="this.src='vendor/img/avatar_default.png'">
                ` : ''}

                <div class="chat-bubble" style="background-color: ${bubbleBg}; position: relative; padding: 6px 9px 8px 9px; border-radius: 8px;">
                    ${!esMio ? `
                        <div style="font-size: 11.5px; font-weight: 700; color: #a78bfa; margin-bottom: 2px;">
                            <span>${escaparHTML(m.remitente_nombre)}</span>
                        </div>
                    ` : ''}

                    ${contenidoHtml}
                    ${reaccionesHtml}

                    <div style="display: flex; justify-content: flex-end; align-items: center; gap: 4px; margin-top: 2px; font-size: 10.5px; color: var(--wa-text-secondary);">
                        <span>${horaStr}</span>
                        ${esMio ? `<i class="ph ph-check-double" style="color: ${m.leido ? '#53bdeb' : 'var(--wa-accent)'};"></i>` : ''}
                    </div>

                    <div class="chat-msg-acciones">
                        <button onclick="reaccionarMensajeDirecto(${m.id}, '👍')" title="De acuerdo">👍</button>
                        <button onclick="reaccionarMensajeDirecto(${m.id}, '❤️')" title="Me gusta">❤️</button>
                        <button onclick="reaccionarMensajeDirecto(${m.id}, '🆗')" title="Entendido">🆗</button>
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
// ENVIAR MENSAJE DIRECTO
// ==============================================================================
async function enviarMensajeDirecto() {
    const input = document.getElementById("chat-input-mensaje");
    if (!input) return;

    const texto = input.value.trim();
    if (!texto) return;

    if (!directoChatState.chatActual) {
        alert("Por favor selecciona a un compañero primero.");
        return;
    }

    const u = chatState.usuario || {};
    const miId = String(u.id_empleado || "000").trim();
    const cid = String(directoChatState.chatActual.companero_id).trim();

    input.value = "";
    input.focus();

    const payload = {
        remitente_id: miId,
        remitente_nombre: u.nombre_completo || u.nombre || "Colaborador VPRO",
        mensaje: texto,
        tipo_mensaje: "TEXTO"
    };

    try {
        const resp = await fetch(`${CHAT_API_URL}/api/chat-directo/mensajes/${encodeURIComponent(cid)}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
        const resData = await resp.json();

        if (resData.mensaje && !directoChatState.mensajes.some(m => m.id === resData.mensaje.id)) {
            directoChatState.mensajes.push(resData.mensaje);
            renderizarMensajesDirecto();
        }

        // Actualizar último mensaje en la barra lateral
        if (directoChatState.chatActual) {
            directoChatState.chatActual.ultimo_mensaje = texto;
            directoChatState.chatActual.ultima_hora = resData.mensaje?.fecha_hora_str || "";
            // Si la conversación no estaba en la lista, agregarla
            if (!directoChatState.conversaciones.some(c => String(c.companero_id) === cid)) {
                directoChatState.conversaciones.unshift(directoChatState.chatActual);
            }
            renderizarSidebarDirecto();
        }

    } catch (err) {
        console.error("Error al enviar mensaje directo:", err);
        input.value = texto;
        alert("No se pudo enviar el mensaje. Verifica tu conexión.");
    }
}

// ==============================================================================
// SUBIR ARCHIVO O FOTO A CHAT DIRECTO
// ==============================================================================
async function subirArchivoDirecto(archivo) {
    if (!archivo || !directoChatState.chatActual) return;
    const u = chatState.usuario || {};
    const miId = String(u.id_empleado || "000").trim();
    const cid = String(directoChatState.chatActual.companero_id).trim();

    const formData = new FormData();
    formData.append("archivo", archivo);
    formData.append("remitente_id", miId);

    try {
        const resUpload = await fetch(`${CHAT_API_URL}/api/chat-directo/subir-adjunto`, {
            method: "POST",
            body: formData
        });

        if (!resUpload.ok) throw new Error("Error al subir archivo");
        const dataUpload = await resUpload.json();

        const esImagen = archivo.type.startsWith("image/");
        const payload = {
            remitente_id: miId,
            remitente_nombre: u.nombre_completo || u.nombre || "Colaborador VPRO",
            mensaje: esImagen ? "📸 Foto adjunta" : `📎 ${archivo.name}`,
            tipo_mensaje: esImagen ? "FOTO" : "ARCHIVO",
            archivo_url: dataUpload.archivo_url
        };

        const resp = await fetch(`${CHAT_API_URL}/api/chat-directo/mensajes/${encodeURIComponent(cid)}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (resp.ok) {
            const resData = await resp.json();
            if (resData.mensaje && !directoChatState.mensajes.some(m => m.id === resData.mensaje.id)) {
                directoChatState.mensajes.push(resData.mensaje);
                renderizarMensajesDirecto();
            }
        }
    } catch (e) {
        console.error("Error al subir adjunto directo:", e);
        alert("Error al subir el archivo.");
    }
}

// ==============================================================================
// REACCIONES EMOJI
// ==============================================================================
async function reaccionarMensajeDirecto(mensajeId, emoji) {
    const u = chatState.usuario || {};
    try {
        const resp = await fetch(`${CHAT_API_URL}/api/chat-directo/mensajes/${mensajeId}/reaccionar`, {
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
            const msg = directoChatState.mensajes.find(m => m.id === mensajeId);
            if (msg) {
                msg.reacciones = data.reacciones;
                renderizarMensajesDirecto();
            }
        }
    } catch (e) {
        console.error("Error al reaccionar:", e);
    }
}

// ==============================================================================
// MODAL / DIRECTORIO: INICIAR NUEVO CHAT 1 A 1
// ==============================================================================
function abrirModalNuevoChatDirecto() {
    const directorio = directoChatState.directorio || [];

    const contenidoHtml = `
        <div style="text-align: left;">
            <p style="font-size: 13px; color: #64748b; margin-bottom: 12px;">
                Selecciona a cualquier compañero de la empresa para iniciar una conversación directa y privada 1 a 1:
            </p>
            <div style="margin-bottom: 12px;">
                <input type="text" id="filtro-modal-directorio" 
                       placeholder="Buscar por nombre, puesto o depto..." 
                       oninput="filtrarModalDirectorio(this.value)"
                       style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; outline: none; box-sizing: border-box;">
            </div>
            <div id="lista-modal-directorio" style="max-height: 340px; overflow-y: auto; display: flex; flex-direction: column; gap: 6px;">
                ${renderizarItemsModalDirectorio(directorio)}
            </div>
        </div>
    `;

    if (typeof Swal !== 'undefined') {
        Swal.fire({
            title: '👥 Iniciar Chat Directo 1 a 1',
            html: contenidoHtml,
            showConfirmButton: false,
            showCloseButton: true,
            width: 520,
            didOpen: () => {
                const inp = document.getElementById("filtro-modal-directorio");
                if (inp) inp.focus();
            }
        });
    } else {
        alert("Abre el directorio para seleccionar un compañero.");
    }
}

function renderizarItemsModalDirectorio(lista) {
    if (!lista || lista.length === 0) {
        return `<div style="text-align: center; padding: 20px; color: #94a3b8; font-size: 13px;">No se encontraron colaboradores.</div>`;
    }

    return lista.map(emp => {
        const foto = emp.foto_url || `${CHAT_API_URL}/fotos/${emp.id_empleado}.jpg`;
        return `
            <div onclick="iniciarChatDesdeDirectorio('${emp.id_empleado}')"
                 style="display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 8px; border: 1px solid #e2e8f0; cursor: pointer; transition: all .15s; background: #ffffff;"
                 onmouseover="this.style.background='#f1f5f9'" onmouseout="this.style.background='#ffffff'">
                <img src="${foto}" 
                     onerror="this.src='vendor/img/avatar_default.png'" 
                     style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover; border: 1px solid #cbd5e1;">
                <div style="flex: 1; min-width: 0;">
                    <h5 style="margin: 0; font-size: 13.5px; font-weight: 700; color: #1e293b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                        ${emp.nombre}
                    </h5>
                    <p style="margin: 2px 0 0; font-size: 11.5px; color: #64748b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                        ${emp.puesto || 'Colaborador'} • ${emp.depto || 'General'}
                    </p>
                </div>
                <div style="color: #8b5cf6; font-size: 18px;">
                    <i class="ph ph-chat-circle-dots"></i>
                </div>
            </div>
        `;
    }).join("");
}

function filtrarModalDirectorio(query) {
    const q = (query || '').toLowerCase().trim();
    const contenedor = document.getElementById("lista-modal-directorio");
    if (!contenedor) return;

    let lista = directoChatState.directorio || [];
    if (q) {
        lista = lista.filter(e => 
            (e.nombre || '').toLowerCase().includes(q) ||
            String(e.id_empleado || '').toLowerCase().includes(q) ||
            (e.puesto || '').toLowerCase().includes(q) ||
            (e.depto || '').toLowerCase().includes(q)
        );
    }
    contenedor.innerHTML = renderizarItemsModalDirectorio(lista);
}

function iniciarChatDesdeDirectorio(idEmpleado) {
    if (typeof Swal !== 'undefined') Swal.close();
    seleccionarDirectoChatPorId(idEmpleado);
}

// ==============================================================================
// WEBSOCKET EN TIEMPO REAL
// ==============================================================================
function conectarWebSocketDirecto(usuarioId) {
    if (directoChatState.ws) {
        try { directoChatState.ws.close(); } catch(e){}
        directoChatState.ws = null;
    }

    try {
        const uid = String(usuarioId || "000").trim();
        let wsUrl = "";
        if (CHAT_API_URL && CHAT_API_URL.startsWith("http")) {
            wsUrl = CHAT_API_URL.replace(/^http/, "ws") + `/api/chat-directo/ws/${uid}`;
        } else {
            const loc = window.location;
            const proto = loc.protocol === "https:" ? "wss:" : "ws:";
            wsUrl = `${proto}//${loc.host}/api/chat-directo/ws/${uid}`;
        }

        const ws = new WebSocket(wsUrl);
        directoChatState.ws = ws;

        ws.onopen = () => {
            console.log(`🟢 Conectado en tiempo real a Mensajes Directos (${uid})`);
        };

        ws.onmessage = (event) => {
            try {
                const data = JSON.parse(event.data);

                if (data.tipo === "NUEVO_MENSAJE_DIRECTO" && data.mensaje) {
                    const nuevo = data.mensaje;
                    const remId = String(nuevo.remitente_id).trim();
                    const destId = String(nuevo.destinatario_id).trim();
                    const chatActivoCid = String(directoChatState.chatActual?.companero_id || "").trim();

                    // Si pertenece a la conversación abierta actualmente
                    if (chatActivoCid === remId || chatActivoCid === destId) {
                        if (!directoChatState.mensajes.some(m => m.id === nuevo.id)) {
                            directoChatState.mensajes.push(nuevo);
                            
                            const miId = String(chatState.usuario?.id_empleado || "000").trim();
                            if (remId !== miId && typeof reproducirTimbreVPRO === 'function') {
                                reproducirTimbreVPRO();
                            }

                            if (chatState.arista === 'directo') {
                                renderizarMensajesDirecto();
                            }
                        }
                    } else {
                        // Mensaje de otro compañero: actualizar barra lateral y badge
                        const companeroRemoto = (remId === String(chatState.usuario?.id_empleado || "000").trim()) ? destId : remId;
                        let conv = directoChatState.conversaciones.find(c => String(c.companero_id) === companeroRemoto);
                        if (conv) {
                            conv.no_leidos = (conv.no_leidos || 0) + 1;
                            conv.ultimo_mensaje = nuevo.mensaje;
                            conv.ultima_hora = nuevo.fecha_hora_str;
                        } else {
                            // Si no existía, buscar en directorio para añadirlo
                            const emp = directoChatState.directorio.find(e => String(e.id_empleado) === companeroRemoto);
                            if (emp) {
                                directoChatState.conversaciones.unshift({
                                    companero_id: String(emp.id_empleado),
                                    companero_nombre: emp.nombre,
                                    companero_puesto: emp.puesto,
                                    companero_depto: emp.depto,
                                    foto_url: emp.foto_url,
                                    no_leidos: 1,
                                    ultimo_mensaje: nuevo.mensaje,
                                    ultima_hora: nuevo.fecha_hora_str,
                                    sala_id: nuevo.sala_id
                                });
                            }
                        }

                        if (typeof reproducirTimbreVPRO === 'function') {
                            reproducirTimbreVPRO();
                        }
                        actualizarBadgeDirecto();
                        renderizarSidebarDirecto();
                    }
                } else if (data.tipo === "REACCION_DIRECTO") {
                    const msg = directoChatState.mensajes.find(m => m.id === data.mensaje_id);
                    if (msg) {
                        msg.reacciones = data.reacciones;
                        if (chatState.arista === 'directo') renderizarMensajesDirecto();
                    }
                }
            } catch (err) {
                console.error("Error al procesar socket directo:", err);
            }
        };

        ws.onclose = () => {
            console.log(`🔴 Desconectado de Mensajes Directos (${uid})`);
        };

    } catch (e) {
        console.error("Error al abrir socket directo:", e);
    }
}
