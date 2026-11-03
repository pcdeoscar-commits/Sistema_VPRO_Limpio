// ==============================================================================
// MÓDULO: chat_soporte_ui.js
// Canal Corporativo: Soporte TI & Mesa de Ayuda (1 a 1 Privado y Confidencial)
// VPRO Workspace
// ==============================================================================

const soporteChatState = {
    activo: false,
    conversaciones: [],
    chatActual: null,
    mensajes: [],
    filtroBusqueda: '',
    info: null,
    ws: null,
    esTI: false
};

// Determina si el usuario tiene rol de Sistemas, TI o Administración / Dirección
function esPersonalSistemasOAdmin() {
    const u = chatState.usuario || {};
    const rol = (u.rol || '').toUpperCase();
    const puesto = (u.puesto || '').toUpperCase();
    const depto = (u.depto || '').toUpperCase();
    const nom = (u.nombre_completo || u.nombre || '').toUpperCase()
        .normalize("NFD").replace(/[\u0300-\u036f]/g, "");

    const esDirectivo = nom.includes('VILLARREAL') || nom.includes('AGUNDEZ');
    const esSistemas = depto.includes('SISTEMA') || puesto.includes('SISTEMA') || rol.includes('SISTEMA') || nom.includes('CUAUHTEMOC') || puesto.includes('TI') || depto.includes('TI');
    const esAdmin = rol.includes('ADMIN') || depto.includes('DIRECCION');

    return esDirectivo || esSistemas || esAdmin;
}

// Filtra la lista de conversaciones de soporte para el personal de TI
function filtrarSoporteChat(termino) {
    soporteChatState.filtroBusqueda = (termino || '').toLowerCase().trim();
    renderizarSidebarSoporte();
}

// ==============================================================================
// CARGA Y RENDERIZADO DEL CANAL DE SOPORTE (1 A 1)
// ==============================================================================
async function cargarCanalSoporte() {
    const contenedorLista = document.getElementById("chat-lista-soporte");
    const contenedorMsjs = document.getElementById("chat-area-mensajes");
    const inputMsg = document.getElementById("chat-input-mensaje");

    if (contenedorMsjs && (!soporteChatState.mensajes || soporteChatState.mensajes.length === 0)) {
        contenedorMsjs.innerHTML = `<div style="display:flex; justify-content:center; align-items:center; height:100%; color:#8696a0;"><i class="ph ph-spinner ph-spin" style="font-size:32px; color:#38bdf8;"></i></div>`;
    }

    if (contenedorLista) {
        contenedorLista.innerHTML = `
            <div style="text-align: center; padding: 24px 16px; color: #8696a0;">
                <i class="ph ph-spinner ph-spin" style="font-size: 26px; color: #38bdf8;"></i>
                <p style="margin-top: 8px; font-size: 13px;">Conectando a Mesa de Ayuda TI 1-1...</p>
            </div>`;
    }

    const u = chatState.usuario || {};
    const miId = String(u.id_empleado || "000").trim();
    const esTI = esPersonalSistemasOAdmin();
    soporteChatState.esTI = esTI;

    try {
        const [resConv, resInfo] = await Promise.all([
            fetch(`${CHAT_API_URL}/api/chat-soporte/conversaciones?usuario_id=${encodeURIComponent(miId)}&es_ti=${esTI ? 'true' : 'false'}`),
            fetch(`${CHAT_API_URL}/api/chat-soporte/info`)
        ]);

        if (resConv.ok) {
            soporteChatState.conversaciones = await resConv.json();
        }
        if (resInfo.ok) {
            soporteChatState.info = await resInfo.json();
        }

        // Actualizar badge de mensajes no leídos de Soporte TI
        actualizarBadgeSoporte();

        // Renderizar barra lateral
        renderizarSidebarSoporte();

        if (inputMsg) {
            inputMsg.placeholder = "¿Dudas de internet, equipos o sistemas? Escribe aquí...";
            inputMsg.focus();
        }

        // Si es un empleado regular (no TI), seleccionar automáticamente su sala privada 1 a 1
        if (!esTI) {
            const miCanal = (soporteChatState.conversaciones && soporteChatState.conversaciones.length > 0)
                ? soporteChatState.conversaciones[0]
                : {
                    id_empleado: miId,
                    id_empleado_consulta: miId,
                    nombre: "Mesa de Ayuda TI",
                    puesto: "Sistemas, Redes & Soporte Técnico 1-1",
                    depto: "TI & Soporte",
                    foto_url: "vendor/img/avatar_default.png"
                };
            seleccionarSoporteChat(miCanal);
        } else {
            // Si es TI / Sistemas: si ya tenía una seleccionada, conservarla; sino seleccionar la primera que tenga mensajes
            if (soporteChatState.chatActual) {
                const existe = soporteChatState.conversaciones.find(c => String(c.id_empleado_consulta) === String(soporteChatState.chatActual.id_empleado_consulta));
                if (existe) {
                    seleccionarSoporteChat(existe);
                } else if (soporteChatState.conversaciones.length > 0) {
                    seleccionarSoporteChat(soporteChatState.conversaciones[0]);
                }
            } else if (soporteChatState.conversaciones.length > 0) {
                seleccionarSoporteChat(soporteChatState.conversaciones[0]);
            } else {
                mostrarEstadoVacioSoporteTI();
            }
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

// Actualiza el badge de notificaciones de Soporte TI
function actualizarBadgeSoporte() {
    const totalNoLeidos = soporteChatState.conversaciones.reduce((acc, c) => acc + (c.no_leidos || 0), 0);
    const badgeEl = document.getElementById("badge-soporte-no-leidos");
    if (badgeEl) {
        if (totalNoLeidos > 0) {
            badgeEl.textContent = totalNoLeidos;
            badgeEl.style.display = "inline-block";
        } else {
            badgeEl.style.display = "none";
        }
    }
}

// Renderiza la barra lateral según si es usuario normal o TI
function renderizarSidebarSoporte() {
    const contenedor = document.getElementById("chat-lista-soporte");
    if (!contenedor) return;

    // --- MODO 1: EMPLEADO REGULAR (Canal 1 a 1 único y privado) ---
    if (!soporteChatState.esTI) {
        const info = soporteChatState.info || {};
        const fijado = info.aviso_fijado;
        const miConv = soporteChatState.conversaciones[0] || {};
        const noLeidos = miConv.no_leidos || 0;

        contenedor.innerHTML = `
            <div onclick="seleccionarSoporteChat(soporteChatState.conversaciones[0])" 
                 style="background: linear-gradient(135deg, #0c4a6e 0%, #0369a1 100%); border-radius: 12px; padding: 14px 16px; margin: 10px; color: white; cursor: pointer; box-shadow: 0 4px 12px rgba(2, 132, 199, 0.25); border: 1px solid #38bdf8; transition: transform 0.15s;">
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
                            Consultas directas a Sistemas (1 a 1)
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
                    <span><i class="ph ph-lock-key"></i> Chat Privado 1-1</span>
                    ${noLeidos > 0 ? `
                        <span style="background: #38bdf8; color: #0c4a6e; font-weight: 800; padding: 2px 8px; border-radius: 10px;">
                            ${noLeidos} nuevo${noLeidos > 1 ? 's' : ''}
                        </span>
                    ` : `
                        <span style="color: #ffffff; font-weight: 600;">Ver Chat ➔</span>
                    `}
                </div>
            </div>

            <div style="padding: 12px 16px; color: #8696a0; font-size: 12px; line-height: 1.4;">
                <div style="background: #182229; border: 1px solid #222e35; border-radius: 10px; padding: 12px;">
                    <b style="color: #e9edef; display: flex; align-items: center; gap: 6px; margin-bottom: 6px;">
                        <i class="ph ph-shield-check" style="color: #38bdf8; font-size: 15px;"></i> Chat 1 a 1 Confidencial
                    </b>
                    Este canal es privado entre tú y el área de Sistemas. Nadie más puede ver tus mensajes o solicitudes:
                    <ul style="margin: 6px 0 0 0; padding-left: 18px; color: #aebac1; font-size: 11.5px;">
                        <li>Reportes de internet lento o red caída.</li>
                        <li>Dudas sobre tu PC, cables o proyector.</li>
                        <li>Solicitud de contraseñas de red o accesos.</li>
                        <li>Asistencia técnica personalizada.</li>
                    </ul>
                </div>
            </div>
        `;
        return;
    }

    // --- MODO 2: PERSONAL DE TI / SISTEMAS (Bandeja de consultas de colaboradores) ---
    let lista = soporteChatState.conversaciones || [];

    if (soporteChatState.filtroBusqueda) {
        const q = soporteChatState.filtroBusqueda;
        lista = lista.filter(c => 
            (c.nombre || '').toLowerCase().includes(q) ||
            String(c.id_empleado_consulta || '').toLowerCase().includes(q) ||
            (c.puesto || '').toLowerCase().includes(q) ||
            (c.depto || '').toLowerCase().includes(q)
        );
    }

    if (lista.length === 0) {
        contenedor.innerHTML = `
            <div style="text-align: center; padding: 40px 16px; color: #8696a0;">
                <i class="ph ph-headset" style="font-size: 40px; color: #38bdf8; opacity: 0.6; margin-bottom: 8px;"></i>
                <h4 style="color: #e9edef; font-size: 14px; margin-bottom: 4px;">Sin consultas pendientes</h4>
                <p style="font-size: 12px; line-height: 1.4;">
                    ${soporteChatState.filtroBusqueda ? 'No se encontraron colaboradores con ese término.' : 'No hay colaboradores con solicitudes de soporte técnico en este momento.'}
                </p>
            </div>`;
        return;
    }

    const html = `
        <div style="padding: 10px 14px 4px; font-size: 11px; font-weight: 700; color: #38bdf8; text-transform: uppercase; letter-spacing: 0.5px; display: flex; align-items: center; justify-content: space-between;">
            <span><i class="ph ph-chats-circle"></i> Solicitudes Soporte TI (${lista.length})</span>
        </div>
        ${lista.map(conv => {
            const esSeleccionado = soporteChatState.chatActual && (String(soporteChatState.chatActual.id_empleado_consulta) === String(conv.id_empleado_consulta));
            const foto = conv.foto_url ? conv.foto_url : `${CHAT_API_URL}/fotos/${conv.id_empleado_consulta}.jpg`;
            const noLeidos = conv.no_leidos || 0;

            return `
                <div class="chat-op-item ${esSeleccionado ? 'active' : ''}" 
                     onclick="seleccionarSoporteChatPorId('${conv.id_empleado_consulta}')"
                     style="display: flex; align-items: center; gap: 12px; padding: 12px 14px; cursor: pointer; border-bottom: 1px solid #1f2c34; transition: background .15s; background: ${esSeleccionado ? '#2a3942' : 'transparent'};">
                    <div style="position: relative; flex-shrink: 0;">
                        <img src="${foto}" 
                             onerror="this.src='vendor/img/avatar_default.png'" 
                             style="width: 44px; height: 44px; border-radius: 50%; object-fit: cover; border: 2px solid ${noLeidos > 0 ? '#38bdf8' : '#0284c7'};">
                        ${noLeidos > 0 ? '<span style="position: absolute; bottom: -2px; right: -2px; width: 14px; height: 14px; background: #38bdf8; border-radius: 50%; border: 2px solid #111b21;"></span>' : ''}
                    </div>
                    <div style="flex: 1; min-width: 0;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 3px;">
                            <h4 style="margin: 0; font-size: 13.5px; font-weight: 700; color: #e9edef; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                ${conv.nombre}
                            </h4>
                            <span style="font-size: 10.5px; color: #8696a0; flex-shrink: 0;">${conv.ultima_hora ? conv.ultima_hora.split(' ')[1]?.substring(0,5) || '' : ''}</span>
                        </div>
                        <div style="font-size: 11.5px; color: #8696a0; margin-bottom: 3px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                            ${conv.puesto || 'Colaborador'} • ${conv.depto || 'General'}
                        </div>
                        <div style="display: flex; justify-content: space-between; align-items: center; font-size: 12px; color: ${noLeidos > 0 ? '#e0f2fe' : '#8696a0'}; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                            <span style="overflow: hidden; text-overflow: ellipsis; ${noLeidos > 0 ? 'font-weight: 600;' : ''}">${conv.ultimo_mensaje || 'Canal 1-1'}</span>
                            <div style="flex-shrink: 0; display: flex; align-items: center; margin-left: 6px;">
                                ${noLeidos > 0 ? `
                                    <span style="background: #0284c7; color: #ffffff; padding: 1.5px 7px; border-radius: 10px; font-size: 10.5px; font-weight: 800;">${noLeidos}</span>
                                ` : ''}
                            </div>
                        </div>
                    </div>
                </div>
            `;
        }).join("")}
    `;

    contenedor.innerHTML = html;
}

function seleccionarSoporteChatPorId(idEmpleadoConsulta) {
    const conv = soporteChatState.conversaciones.find(c => String(c.id_empleado_consulta) === String(idEmpleadoConsulta));
    if (conv) seleccionarSoporteChat(conv);
}

// Activa una sala 1 a 1 de soporte en el panel principal
async function seleccionarSoporteChat(conv) {
    if (!conv) return;

    soporteChatState.chatActual = conv;
    renderizarSidebarSoporte();

    // En pantallas móviles, contraer barra lateral y desplegar chat
    const panelLateral = document.getElementById("chat-panel-lateral");
    const panelConversacion = document.getElementById("chat-panel-conversacion");
    if (panelLateral && panelConversacion && window.innerWidth < 768) {
        panelLateral.style.display = "none";
        panelConversacion.style.display = "flex";
    }

    actualizarCabeceraSoporte(conv);

    const u = chatState.usuario || {};
    const miId = String(u.id_empleado || "000").trim();
    const esTI = soporteChatState.esTI;
    const roomEmpId = String(conv.id_empleado_consulta || miId);

    // Conectar WebSocket a esta sala 1 a 1 específica
    conectarWebSocketSoporte(roomEmpId);

    // Cargar mensajes de esta sala privada
    const contenedorMsjs = document.getElementById("chat-area-mensajes");
    if (contenedorMsjs) {
        contenedorMsjs.innerHTML = `<div style="display:flex; justify-content:center; align-items:center; height:100%; color:#8696a0;"><i class="ph ph-spinner ph-spin" style="font-size:32px; color:#38bdf8;"></i></div>`;
    }

    try {
        const resp = await fetch(`${CHAT_API_URL}/api/chat-soporte/mensajes/${encodeURIComponent(roomEmpId)}?lector_id=${encodeURIComponent(miId)}&es_ti=${esTI ? 'true' : 'false'}&limit=150`);
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);

        soporteChatState.mensajes = await resp.json();

        // Limpiar contador no leídos de esta conversación
        conv.no_leidos = 0;
        actualizarBadgeSoporte();
        renderizarSidebarSoporte();

        renderizarMensajesSoporte();

    } catch (err) {
        console.error("Error al cargar mensajes de sala soporte:", err);
        if (contenedorMsjs) {
            contenedorMsjs.innerHTML = `
                <div style="text-align: center; padding: 30px; color: #f87171;">
                    <i class="ph ph-warning-circle" style="font-size: 32px; margin-bottom: 8px;"></i>
                    <p>No se pudieron cargar los mensajes de este canal.</p>
                </div>`;
        }
    }
}

function mostrarEstadoVacioSoporteTI() {
    const contenedorMsjs = document.getElementById("chat-area-mensajes");
    if (contenedorMsjs) {
        contenedorMsjs.innerHTML = `
            <div style="text-align: center; padding: 40px 20px; color: #8696a0; height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                <div style="width: 68px; height: 68px; border-radius: 50%; background: #182229; display: flex; align-items: center; justify-content: center; font-size: 34px; margin-bottom: 14px; color: #38bdf8;">
                    <i class="ph ph-laptop"></i>
                </div>
                <h3 style="color: #e9edef; font-size: 16px; margin-bottom: 6px;">Mesa de Ayuda TI (Panel de Sistemas)</h3>
                <p style="font-size: 13px; max-width: 380px; line-height: 1.5;">
                    Selecciona a un colaborador en la lista lateral para atender su consulta técnica 1 a 1.
                </p>
            </div>`;
    }
}

function actualizarCabeceraSoporte(conv) {
    const elFolio = document.getElementById("chat-header-folio");
    const elTitulo = document.getElementById("chat-header-titulo");
    const elSub = document.getElementById("chat-header-detalles");
    const elLlamado = document.getElementById("chat-header-llamado");
    const elAcciones = document.getElementById("chat-header-acciones");
    const btnCerrarOp = document.getElementById("btn-cerrar-op-chat");

    if (btnCerrarOp) btnCerrarOp.style.display = "none";

    if (elFolio) {
        elFolio.innerText = soporteChatState.esTI ? `ID: ${conv.id_empleado_consulta}` : "TI-SOPORTE";
        elFolio.style.background = "#0284c7";
        elFolio.style.color = "#ffffff";
    }

    if (elTitulo) {
        const tituloTexto = soporteChatState.esTI ? conv.nombre : "Mesa de Ayuda TI";
        elTitulo.innerHTML = `
            <span style="display: flex; align-items: center; gap: 8px;">
                <i class="ph ph-laptop" style="color: #38bdf8;"></i> ${escaparHTML(tituloTexto)}
            </span>`;
    }

    if (elSub) {
        if (soporteChatState.esTI) {
            elSub.innerText = `${conv.puesto || 'Colaborador'} • ${conv.depto || 'General'}`;
        } else {
            elSub.innerText = "Canal directo y privado 1 a 1 con el área de Sistemas.";
        }
    }

    if (elLlamado) {
        elLlamado.innerHTML = `
            <span style="background: rgba(56, 189, 248, 0.15); color: #38bdf8; border: 1px solid #0284c7; padding: 2px 8px; border-radius: 6px; font-weight: 700; font-size: 11px;">
                ● 1 a 1 Privado
            </span>`;
    }

    if (elAcciones) {
        elAcciones.innerHTML = `
            <button class="chat-btn-icon" onclick="cargarCanalSoporte()" title="Actualizar consultas">
                <i class="ph ph-arrow-clockwise"></i>
            </button>
        `;
    }
}

// Funciones auxiliares para formato y seguridad
function escaparHTML(texto) {
    if (!texto) return "";
    const div = document.createElement("div");
    div.innerText = String(texto);
    return div.innerHTML;
}

function formatearFechaSeparador(fechaStr) {
    try {
        if (!fechaStr) return "";
        const partes = fechaStr.split("-");
        if (partes.length < 3) return fechaStr;
        const y = parseInt(partes[0], 10);
        const m = parseInt(partes[1], 10) - 1;
        const d = parseInt(partes[2], 10);
        const fecha = new Date(y, m, d);
        const hoy = new Date();
        const ayer = new Date();
        ayer.setDate(hoy.getDate() - 1);

        if (fecha.toDateString() === hoy.toDateString()) return "HOY";
        if (fecha.toDateString() === ayer.toDateString()) return "AYER";

        return fecha.toLocaleDateString("es-MX", { weekday: "long", day: "numeric", month: "long" }).toUpperCase();
    } catch {
        return fechaStr;
    }
}

// Renderiza la lista cronológica de mensajes con estilo WhatsApp 1-1
function renderizarMensajesSoporte() {
    const contenedor = document.getElementById("chat-area-mensajes");
    if (!contenedor) return;

    const msjs = soporteChatState.mensajes || [];
    const u = chatState.usuario || {};
    const miId = String(u.id_empleado || "000").trim();
    const miNombreNorm = (u.nombre_completo || u.nombre || "").toUpperCase().trim();
    const esTI = soporteChatState.esTI;
    const convActual = soporteChatState.chatActual || {};

    if (msjs.length === 0) {
        contenedor.innerHTML = `
            <div style="text-align: center; padding: 40px 20px; color: #8696a0;">
                <div style="width: 60px; height: 60px; border-radius: 50%; background: #182229; display: flex; align-items: center; justify-content: center; font-size: 32px; margin: 0 auto 12px; color: #38bdf8;">
                    <i class="ph ph-chats-circle"></i>
                </div>
                <h3 style="color: #e9edef; font-size: 16px; margin-bottom: 6px;">
                    ${esTI ? `Consulta 1-1 con ${convActual.nombre || 'Colaborador'}` : '¡Bienvenido a la Mesa de Ayuda TI!'}
                </h3>
                <p style="font-size: 13px; max-width: 420px; margin: 0 auto; line-height: 1.5;">
                    ${esTI 
                        ? 'Este hilo es una conversación directa y privada 1 a 1 entre Sistemas y este colaborador.'
                        : '¿Tienes dudas sobre internet, tu equipo de cómputo o necesitas contraseñas? Escribe tu mensaje abajo. Este chat es completamente privado entre tú y Sistemas.'}
                </p>
            </div>`;
        return;
    }

    let html = "";
    let ultimaFecha = "";

    // Banner de mensaje fijado (si existe en esta conversación)
    const fijado = msjs.slice().reverse().find(m => m.es_fijado);
    if (fijado) {
        html += `
            <div style="position: sticky; top: 0; z-index: 10; background: #0c4a6e; border-left: 4px solid #38bdf8; border-radius: 8px; padding: 8px 12px; margin-bottom: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.3); display: flex; align-items: center; justify-content: space-between; gap: 10px;">
                <div style="display: flex; align-items: center; gap: 8px; font-size: 12.5px; color: #e0f2fe; overflow: hidden;">
                    <i class="ph ph-push-pin" style="color: #38bdf8; font-size: 16px; flex-shrink: 0;"></i>
                    <span style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                        <b>Aviso de ${escaparHTML(fijado.autor_nombre)}:</b> "${escaparHTML(fijado.mensaje)}"
                    </span>
                </div>
                ${esTI ? `
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
        const autId = String(m.autor_id || m.id_empleado || "").trim();
        const esMio = (autId === miId && miId !== "000") || (autorNorm === miNombreNorm);
        const horaStr = m.fecha_hora_str ? m.fecha_hora_str.substring(11, 16) : "";
        const esSistemasAutor = (m.autor_rol || "").toUpperCase().includes("SISTEMA") || autorNorm.includes("CUAUHTEMOC");

        const bubbleClass = esMio ? "mio" : "otro";
        const bubbleBg = esMio ? "var(--wa-msg-out-bg)" : "var(--wa-msg-in-bg)";
        const fotoAutor = m.foto_url || `${CHAT_API_URL}/fotos/${autId}.jpg`;

        // Renderizado de contenido (texto, foto, link, archivo)
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
                <a href="${m.archivo_url}" target="_blank" style="display: flex; align-items: center; gap: 8px; background: rgba(0,0,0,0.2); padding: 8px 12px; border-radius: 6px; color: #38bdf8; text-decoration: none; margin-bottom: 4px;">
                    <i class="ph ph-file-text" style="font-size: 20px;"></i>
                    <span style="font-size: 12.5px; font-weight: 600; text-decoration: underline;">${escaparHTML(m.mensaje || 'Descargar archivo adjunto')}</span>
                </a>
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
                        ${esMio ? `<i class="ph ph-check-double" style="color: ${m.leido_por_ti || m.leido_por_empleado ? '#53bdeb' : 'var(--wa-accent)'};"></i>` : ''}
                    </div>

                    <!-- Botones de reacción al pasar el mouse -->
                    <div class="chat-msg-acciones">
                        <button onclick="reaccionarMensajeSoporte(${m.id}, '👍')" title="De acuerdo">👍</button>
                        <button onclick="reaccionarMensajeSoporte(${m.id}, '🆗')" title="Entendido">🆗</button>
                        <button onclick="reaccionarMensajeSoporte(${m.id}, '⚠️')" title="Importante">⚠️</button>
                        ${esTI ? `
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
// ENVIAR MENSAJE A LA SALA 1 A 1
// ==============================================================================
async function enviarMensajeSoporte() {
    const input = document.getElementById("chat-input-mensaje");
    if (!input) return;

    const texto = input.value.trim();
    if (!texto) return;

    const u = chatState.usuario || {};
    const miId = String(u.id_empleado || "000").trim();
    const esTI = soporteChatState.esTI;

    // Destino: si no hay sala seleccionada y no es TI, enviar a su propia sala
    const idConsulta = soporteChatState.chatActual?.id_empleado_consulta || miId;

    input.value = "";
    input.focus();

    const payload = {
        autor_id: miId,
        autor_nombre: u.nombre_completo || u.nombre || "Colaborador VPRO",
        autor_rol: esTI ? "SISTEMAS" : (u.rol || u.puesto || "COLABORADOR"),
        mensaje: texto,
        tipo_mensaje: "TEXTO",
        es_fijado: false
    };

    try {
        const resp = await fetch(`${CHAT_API_URL}/api/chat-soporte/mensajes/${encodeURIComponent(idConsulta)}`, {
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

        // Actualizar último mensaje en la barra lateral
        if (soporteChatState.chatActual) {
            soporteChatState.chatActual.ultimo_mensaje = texto;
            soporteChatState.chatActual.ultima_hora = resData.mensaje?.fecha_hora_str || "";
            renderizarSidebarSoporte();
        }

    } catch (err) {
        console.error("Error al enviar mensaje a soporte:", err);
        input.value = texto;
        alert("No se pudo enviar el mensaje a Soporte TI. Verifica tu conexión.");
    }
}

// ==============================================================================
// SUBIR FOTO O ARCHIVO A LA SALA 1 A 1
// ==============================================================================
async function subirArchivoSoporte(archivo) {
    if (!archivo) return;
    const u = chatState.usuario || {};
    const miId = String(u.id_empleado || "000").trim();
    const esTI = soporteChatState.esTI;
    const idConsulta = soporteChatState.chatActual?.id_empleado_consulta || miId;

    const formData = new FormData();
    formData.append("archivo", archivo);

    try {
        const resUpload = await fetch(`${CHAT_API_URL}/api/chat-soporte/subir-adjunto/${encodeURIComponent(idConsulta)}`, {
            method: "POST",
            body: formData
        });

        if (!resUpload.ok) throw new Error("Error al subir archivo");
        const dataUpload = await resUpload.json();

        const esImagen = archivo.type.startsWith("image/");
        const payload = {
            autor_id: miId,
            autor_nombre: u.nombre_completo || u.nombre || "Colaborador VPRO",
            autor_rol: esTI ? "SISTEMAS" : (u.rol || u.puesto || "COLABORADOR"),
            mensaje: esImagen ? "📸 Captura adjunta" : `📎 ${archivo.name}`,
            tipo_mensaje: esImagen ? "FOTO" : "ARCHIVO",
            archivo_url: dataUpload.archivo_url,
            es_fijado: false
        };

        const resp = await fetch(`${CHAT_API_URL}/api/chat-soporte/mensajes/${encodeURIComponent(idConsulta)}`, {
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
// CONEXIÓN WEBSOCKET PRIVADA 1 A 1
// ==============================================================================
function conectarWebSocketSoporte(idEmpleadoConsulta) {
    if (soporteChatState.ws) {
        try { soporteChatState.ws.close(); } catch(e){}
        soporteChatState.ws = null;
    }

    try {
        const room = String(idEmpleadoConsulta || "000").trim();
        const esTI = soporteChatState.esTI;
        let wsUrl = "";
        if (CHAT_API_URL && CHAT_API_URL.startsWith("http")) {
            wsUrl = CHAT_API_URL.replace(/^http/, "ws") + `/api/chat-soporte/ws/${room}?es_ti=${esTI ? 'true' : 'false'}`;
        } else {
            const loc = window.location;
            const proto = loc.protocol === "https:" ? "wss:" : "ws:";
            wsUrl = `${proto}//${loc.host}/api/chat-soporte/ws/${room}?es_ti=${esTI ? 'true' : 'false'}`;
        }

        const ws = new WebSocket(wsUrl);
        soporteChatState.ws = ws;

        ws.onopen = () => {
            console.log(`🟢 Conectado en tiempo real a sala 1-1 Soporte TI (${room})`);
        };

        ws.onmessage = (event) => {
            try {
                const data = JSON.parse(event.data);

                // Mensaje en la conversación activa actual
                if (data.tipo === "NUEVO_MENSAJE_SOPORTE" && data.mensaje) {
                    const nuevo = data.mensaje;
                    const salaMsg = String(nuevo.id_empleado_consulta || nuevo.id_empleado).trim();
                    const salaActiva = String(soporteChatState.chatActual?.id_empleado_consulta || "").trim();

                    if (salaMsg === salaActiva) {
                        if (!soporteChatState.mensajes.some(m => m.id === nuevo.id)) {
                            soporteChatState.mensajes.push(nuevo);
                            
                            // Sonido si el mensaje viene de otra persona
                            const miId = String(chatState.usuario?.id_empleado || "000").trim();
                            if (String(nuevo.autor_id || nuevo.id_empleado).trim() !== miId) {
                                if (typeof reproducirTimbreVPRO === 'function') {
                                    reproducirTimbreVPRO();
                                }
                            }

                            if (chatState.arista === 'soporte') {
                                renderizarMensajesSoporte();
                            }
                        }
                    } else if (soporteChatState.esTI) {
                        // Alerta para TI de otra sala: actualizar badge y lista
                        let conv = soporteChatState.conversaciones.find(c => String(c.id_empleado_consulta) === salaMsg);
                        if (conv) {
                            conv.no_leidos = (conv.no_leidos || 0) + 1;
                            conv.ultimo_mensaje = nuevo.mensaje;
                            conv.ultima_hora = nuevo.fecha_hora_str;
                        }
                        if (typeof reproducirTimbreVPRO === 'function') {
                            reproducirTimbreVPRO();
                        }
                        actualizarBadgeSoporte();
                        renderizarSidebarSoporte();
                    }
                } else if (data.tipo_alerta === "NUEVO_MENSAJE_SOPORTE" && soporteChatState.esTI) {
                    // Notificación global a TI
                    const salaMsg = String(data.id_empleado_consulta).trim();
                    let conv = soporteChatState.conversaciones.find(c => String(c.id_empleado_consulta) === salaMsg);
                    if (conv) {
                        conv.no_leidos = (conv.no_leidos || 0) + 1;
                        if (data.data && data.data.mensaje) {
                            conv.ultimo_mensaje = data.data.mensaje.mensaje;
                            conv.ultima_hora = data.data.mensaje.fecha_hora_str;
                        }
                    }
                    if (typeof reproducirTimbreVPRO === 'function') {
                        reproducirTimbreVPRO();
                    }
                    actualizarBadgeSoporte();
                    renderizarSidebarSoporte();

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
            console.log(`🔴 Desconectado de sala 1-1 Soporte TI (${room})`);
        };

    } catch (e) {
        console.error("Error al abrir socket de soporte:", e);
    }
}
