// ==============================================================================
// MÓDULO: chat_admin_ui.js
// Arista de Chat Administrativo & Recursos Humanos (Canal 1 a 1 Empleado <-> Admon)
// VPRO Workspace - ISO 9001:2015
// ==============================================================================

const CHAT_API_URL_RESOLVED = (typeof CHAT_API_URL !== 'undefined' && CHAT_API_URL) || (typeof API_URL !== 'undefined' && API_URL) || '';

const adminChatState = {
    activo: false,
    conversaciones: [],
    chatActual: null,
    mensajes: [],
    ws: null,
    esAdmin: false
};

// Determina si el usuario logueado en el chat tiene rol administrativo
function esUsuarioAdminChat() {
    const u = chatState.usuario || {};
    const rol = (u.rol || '').toUpperCase();
    const puesto = (u.puesto || '').toUpperCase();
    const depto = (u.depto || '').toUpperCase();
    const nom = (u.nombre_completo || u.nombre || '').toUpperCase()
        .normalize("NFD").replace(/[\u0300-\u036f]/g, "");

    const esDirectivo = nom.includes('VILLARREAL') || nom.includes('VILLAREAL') || nom.includes('VILARREAL') || nom.includes('AGUNDEZ');
    const esRolAdmin = rol.includes('ADMIN') || rol.includes('DIRECCION') || rol.includes('RH') || puesto.includes('ADMIN') || puesto.includes('RH') || depto.includes('DIRECCION') || depto.includes('RH');

    return esDirectivo || esRolAdmin;
}

// ==============================================================================
// CAMBIO DE ARISTA (OPs de Producción vs. Administración & RH)
// ==============================================================================
function cambiarAristaChat(arista) {
    chatState.arista = arista;
    adminChatState.activo = (arista === 'admin');

    const btnOps = document.getElementById("btn-arista-ops");
    const btnAdmin = document.getElementById("btn-arista-admin");
    const listOps = document.getElementById("chat-lista-ops");
    const listAdmin = document.getElementById("chat-lista-admin");
    const tabsBar = document.getElementById("chat-tabs-bar");
    const inputMsg = document.getElementById("chat-input-mensaje");

    if (arista === 'admin') {
        if (btnOps) { btnOps.style.background = "#111b21"; btnOps.style.color = "#8696a0"; }
        if (btnAdmin) { btnAdmin.style.background = "#6366f1"; btnAdmin.style.color = "#ffffff"; }
        if (tabsBar) tabsBar.style.display = "none";
        if (listOps) listOps.style.display = "none";
        if (listAdmin) listAdmin.style.display = "block";
        if (inputMsg) inputMsg.placeholder = "Escribe un mensaje para Administración & RH...";

        // Desconectar WebSocket de OP
        if (chatState.ws) {
            try { chatState.ws.close(); } catch(e){}
            chatState.ws = null;
        }

        cargarListaAdminChat();
    } else {
        if (btnOps) { btnOps.style.background = "#00a884"; btnOps.style.color = "#ffffff"; }
        if (btnAdmin) { btnAdmin.style.background = "#111b21"; btnAdmin.style.color = "#8696a0"; }
        if (tabsBar) tabsBar.style.display = "flex";
        if (listOps) listOps.style.display = "block";
        if (listAdmin) listAdmin.style.display = "none";
        if (inputMsg) inputMsg.placeholder = "Escribe un mensaje técnico de la OP...";

        // Desconectar WebSocket de Admin
        if (adminChatState.ws) {
            try { adminChatState.ws.close(); } catch(e){}
            adminChatState.ws = null;
        }

        // Si ya había una OP seleccionada, restaurar su cabecera y mensajes
        if (chatState.opActual) {
            actualizarCabeceraChat(chatState.opActual);
            renderizarMensajes();
            conectarWebSocketChat(chatState.opActual.id_evento);
        } else {
            limpiarVentanaConversacion();
        }
    }
}

// ==============================================================================
// CARGAR BANDEJA DE CONVERSACIONES ADMINISTRATIVAS
// ==============================================================================
async function cargarListaAdminChat() {
    const contenedor = document.getElementById("chat-lista-admin");
    if (!contenedor) return;

    contenedor.innerHTML = `
        <div style="text-align: center; padding: 30px 16px; color: #8696a0;">
            <i class="ph ph-spinner ph-spin" style="font-size: 28px; color: #6366f1;"></i>
            <p style="margin-top: 10px; font-size: 13px;">Cargando canal administrativo...</p>
        </div>`;

    const u = chatState.usuario || {};
    const idEmp = String(u.id_empleado || "000").trim();
    const esAdmin = esUsuarioAdminChat();
    adminChatState.esAdmin = esAdmin;

    try {
        const resp = await fetch(`${CHAT_API_URL}/api/chat-admin/conversaciones?usuario_id=${idEmp}&es_admin=${esAdmin ? 'true' : 'false'}`);
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);

        const data = await resp.json();
        adminChatState.conversaciones = data || [];
        renderizarListaAdmin();

        // Actualizar badge de notificaciones de Admon & RH
        const totalAlertas = adminChatState.conversaciones.reduce((acc, c) => acc + (c.no_leidos || 0) + (c.permisos_pendientes || 0), 0);
        const badgeEl = document.getElementById("badge-admin-no-leidos");
        if (badgeEl) {
            if (totalAlertas > 0) {
                badgeEl.textContent = totalAlertas;
                badgeEl.style.display = "inline-block";
            } else {
                badgeEl.style.display = "none";
            }
        }

        // Si es un empleado regular (no admin), auto-seleccionar su conversación directa de inmediato
        if (!esAdmin && adminChatState.conversaciones.length > 0) {
            seleccionarAdminChat(adminChatState.conversaciones[0]);
        }
    } catch (err) {
        console.error("Error al cargar lista admin chat:", err);
        contenedor.innerHTML = `
            <div style="text-align: center; padding: 24px 16px; color: #f87171;">
                <i class="ph ph-warning-circle" style="font-size: 32px; margin-bottom: 8px;"></i>
                <p style="font-size: 13px;">No se pudo conectar con el canal de Administración.</p>
                <button onclick="cargarListaAdminChat()" style="margin-top: 10px; padding: 6px 14px; background: #6366f1; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 12px; font-weight: 700;">Reintentar</button>
            </div>`;
    }
}

function renderizarListaAdmin() {
    const contenedor = document.getElementById("chat-lista-admin");
    if (!contenedor) return;

    if (adminChatState.conversaciones.length === 0) {
        contenedor.innerHTML = `
            <div style="text-align: center; padding: 40px 16px; color: #8696a0;">
                <i class="ph ph-buildings" style="font-size: 40px; color: #6366f1; opacity: 0.6; margin-bottom: 8px;"></i>
                <h4 style="color: #e9edef; font-size: 14px; margin-bottom: 4px;">Sin solicitudes activas</h4>
                <p style="font-size: 12px; line-height: 1.4;">No hay colaboradores con mensajes o permisos pendientes en este momento.</p>
            </div>`;
        return;
    }

    const html = adminChatState.conversaciones.map(conv => {
        const esSeleccionado = adminChatState.chatActual && (adminChatState.chatActual.id_empleado === conv.id_empleado);
        const foto = conv.foto_url ? conv.foto_url : `${CHAT_API_URL}/fotos/${conv.id_empleado}.jpg`;
        const tienePermiso = conv.permisos_pendientes > 0;
        const noLeidos = conv.no_leidos || 0;

        let badgeHtml = "";
        if (tienePermiso) {
            badgeHtml += `<span style="background: #f59e0b; color: #ffffff; padding: 1.5px 6px; border-radius: 8px; font-size: 10px; font-weight: 800; display: inline-flex; align-items: center; gap: 3px;"><i class="ph ph-hourglass"></i> Permiso</span>`;
        }
        if (noLeidos > 0) {
            badgeHtml += `<span style="background: #6366f1; color: #ffffff; padding: 1.5px 6px; border-radius: 10px; font-size: 10px; font-weight: 800; margin-left: 4px;">${noLeidos}</span>`;
        }

        return `
            <div class="chat-op-item ${esSeleccionado ? 'active' : ''}" 
                 onclick="seleccionarAdminChatPorId('${conv.id_empleado}')"
                 style="display: flex; align-items: center; gap: 12px; padding: 12px 14px; cursor: pointer; border-bottom: 1px solid #1f2c34; transition: background .15s; background: ${esSeleccionado ? '#2a3942' : 'transparent'};">
                <div style="position: relative; flex-shrink: 0;">
                    <img src="${foto}" 
                         onerror="this.src='vendor/img/avatar_default.png'" 
                         style="width: 44px; height: 44px; border-radius: 50%; object-fit: cover; border: 2px solid ${tienePermiso ? '#f59e0b' : '#6366f1'};">
                    ${tienePermiso ? '<span style="position: absolute; bottom: -2px; right: -2px; width: 14px; height: 14px; background: #f59e0b; border-radius: 50%; border: 2px solid #111b21;"></span>' : ''}
                </div>
                <div style="flex: 1; min-width: 0;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 3px;">
                        <h4 style="margin: 0; font-size: 13.5px; font-weight: 700; color: #e9edef; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                            ${conv.nombre}
                        </h4>
                        <span style="font-size: 10.5px; color: #8696a0; flex-shrink: 0;">${conv.ultima_hora ? conv.ultima_hora.split(' ')[1]?.substring(0,5) || '' : ''}</span>
                    </div>
                    <div style="font-size: 11.5px; color: #8696a0; margin-bottom: 3px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                        ${conv.puesto || ''} • ${conv.depto || ''}
                    </div>
                    <div style="display: flex; justify-content: space-between; align-items: center; font-size: 12px; color: ${tienePermiso ? '#fde68a' : '#a0aec0'}; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                        <span style="overflow: hidden; text-overflow: ellipsis;">${conv.ultimo_mensaje || 'Canal abierto'}</span>
                        <div style="flex-shrink: 0; display: flex; align-items: center; margin-left: 6px;">
                            ${badgeHtml}
                        </div>
                    </div>
                </div>
            </div>
        `;
    }).join("");

    contenedor.innerHTML = html;
}

function seleccionarAdminChatPorId(idEmpleado) {
    const conv = adminChatState.conversaciones.find(c => String(c.id_empleado) === String(idEmpleado));
    if (conv) seleccionarAdminChat(conv);
}

// ==============================================================================
// SELECCIÓN DE CONVERSACIÓN ADMINISTRATIVA
// ==============================================================================
async function seleccionarAdminChat(conv) {
    adminChatState.chatActual = conv;
    renderizarListaAdmin();

    // En móviles, mostrar el panel de chat y ocultar la lista
    const panelLat = document.getElementById("chat-panel-lateral");
    const panelConv = document.getElementById("chat-panel-conversacion");
    if (window.innerWidth <= 768) {
        if (panelLat) panelLat.style.display = "none";
        if (panelConv) panelConv.style.display = "flex";
    }

    // Actualizar Cabecera
    const elFolio = document.getElementById("chat-header-folio");
    const elTit = document.getElementById("chat-header-titulo");
    const elDet = document.getElementById("chat-header-detalles");
    const elLlam = document.getElementById("chat-header-llamado");
    const elAcc = document.getElementById("chat-header-acciones");

    if (elFolio) {
        elFolio.innerText = "ADMON-RH";
        elFolio.style.background = "#6366f1";
    }
    if (elTit) elTit.innerText = conv.nombre;
    if (elDet) elDet.innerText = `${conv.puesto || 'Colaborador'} • ${conv.depto || 'General'}`;
    if (elLlam) elLlam.innerHTML = `<i class="ph ph-shield-check"></i> Canal Oficial Confidencial 1 a 1`;

    if (elAcc) {
        elAcc.innerHTML = `
            <button onclick="window.open('index.html?vista=rh', '_blank')" 
                    title="Abrir Expediente en Recursos Humanos"
                    style="background: #202c33; color: #e9edef; border: 1px solid #374045; padding: 6px 12px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 5px;">
                <i class="ph ph-folder-user" style="font-size: 15px; color: #818cf8;"></i> Ir a RH
            </button>
        `;
    }

    // Cargar mensajes
    await cargarMensajesAdmin(conv.id_empleado);

    // Conectar WebSocket en tiempo real
    conectarWebSocketAdmin(conv.id_empleado);
}

// ==============================================================================
// CARGA Y RENDERIZADO DE MENSAJES ADMINISTRATIVOS
// ==============================================================================
async function cargarMensajesAdmin(idEmpleado, esSilencioso = false) {
    const area = document.getElementById("chat-area-mensajes");
    if (!area) return;

    if (!esSilencioso) {
        area.innerHTML = `
            <div style="display:flex; justify-content:center; align-items:center; height:100%; color:#8696a0;">
                <i class="ph ph-spinner ph-spin" style="font-size:32px; color:#6366f1;"></i>
            </div>`;
    }

    const u = chatState.usuario || {};
    const idEmpLector = String(u.id_empleado || "000").trim();
    const esAdmin = adminChatState.esAdmin;

    try {
        const resp = await fetch(`${CHAT_API_URL}/api/chat-admin/mensajes/${idEmpleado}?es_admin=${esAdmin ? 'true' : 'false'}&lector_id=${idEmpLector}`);
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);

        adminChatState.mensajes = await resp.json() || [];
        renderizarMensajesAdmin();
    } catch(err) {
        console.error("Error al cargar mensajes admin:", err);
        if (!esSilencioso) {
            area.innerHTML = `<div style="text-align:center; padding:20px; color:#f87171;">Error al cargar mensajes del canal.</div>`;
        }
    }
}

function renderizarMensajesAdmin(mantenerScroll = false) {
    const area = document.getElementById("chat-area-mensajes");
    if (!area) return;

    const u = chatState.usuario || {};
    const miId = String(u.id_empleado || "").trim();
    const esAdmin = adminChatState.esAdmin;

    if (adminChatState.mensajes.length === 0) {
        area.innerHTML = `
            <div style="text-align: center; margin: auto; padding: 24px; color: #8696a0; background: rgba(32,44,51,0.85); backdrop-filter: blur(4px); border-radius: 12px; max-width: 400px; border: 1px solid #2a3942;">
                <i class="ph ph-buildings" style="font-size: 40px; color: #6366f1; margin-bottom: 8px; display: block;"></i>
                <h4 style="margin: 0 0 6px; color: #e9edef;">Canal de Administración & RH</h4>
                <p style="margin: 0; font-size: 12.5px; line-height: 1.4;">
                    Este es el canal oficial y privado para solicitar permisos, enviar justificantes médicos y recibir resoluciones directamente de Administración.
                </p>
            </div>`;
        return;
    }

    const html = adminChatState.mensajes.map(m => {
        const esMio = (String(m.autor_id).trim() === miId);
        const hora = m.fecha_hora_str ? m.fecha_hora_str.split(' ')[1]?.substring(0,5) || '' : '';

        // Tarjetas interactivas de Solicitud de Permiso
        if (m.tipo_mensaje === 'SOLICITUD_PERMISO') {
            const meta = m.metadata_extra || {};
            const idPer = meta.id_permiso || 0;
            const tieneArch = !!m.archivo_url;

            return `
                <div class="chat-msg-row ${esMio ? 'me' : 'other'}" style="display:flex; justify-content:${esMio ? 'flex-end' : 'flex-start'}; margin-bottom:10px;">
                    <div style="max-width: 85%; width: 440px; background: #1e1b4b; border: 1.5px solid #818cf8; border-radius: 12px; padding: 14px; box-shadow: 0 4px 12px rgba(99,102,241,0.25); color: #e0e7ff;">
                        <div style="display:flex; align-items:center; justify-content:space-between; border-bottom:1px solid #3730a3; padding-bottom:8px; margin-bottom:10px;">
                            <div style="display:flex; align-items:center; gap:8px; font-weight:800; font-size:13.5px; color:#c7d2fe;">
                                <i class="ph ph-clipboard-text" style="font-size:20px; color:#818cf8;"></i>
                                <span>SOLICITUD DE PERMISO LABORAL</span>
                            </div>
                            <span style="background:#fef3c7; color:#92400e; font-size:10.5px; font-weight:800; padding:2px 8px; border-radius:10px;">PENDIENTE</span>
                        </div>
                        <div style="font-size:12.5px; line-height:1.55; white-space:pre-line; color:#f1f5f9;">
                            ${m.mensaje}
                        </div>
                        ${tieneArch ? `
                            <div style="margin-top:10px;">
                                <a href="${m.archivo_url}" target="_blank" style="display:inline-flex; align-items:center; gap:6px; background:#312e81; color:#a5b4fc; border:1px solid #4338ca; padding:6px 12px; border-radius:6px; font-size:12px; font-weight:700; text-decoration:none;">
                                    <i class="ph ph-file-text"></i> Ver Justificante / Receta Adjunta
                                </a>
                            </div>` : ''}
                        ${esAdmin ? `
                            <div style="margin-top:12px; padding-top:10px; border-top:1px dashed #4338ca; display:flex; justify-content:flex-end;">
                                <button onclick="irARHParaDictaminar('${m.id_empleado}', ${idPer})" 
                                        style="background:#6366f1; color:white; border:none; padding:8px 16px; border-radius:6px; font-size:12.5px; font-weight:700; cursor:pointer; display:inline-flex; align-items:center; gap:6px; box-shadow:0 2px 6px rgba(99,102,241,0.4); transition:all .15s;"
                                        onmouseover="this.style.background='#4f46e5'" onmouseout="this.style.background='#6366f1'">
                                    <i class="ph ph-scales" style="font-size:16px;"></i> Revisar y Dictaminar en RH
                                </button>
                            </div>` : ''}
                        <div style="text-align:right; font-size:10px; color:#a5b4fc; margin-top:6px;">${hora}</div>
                    </div>
                </div>
            `;
        }

        // Tarjetas interactivas de Resolución de Permiso
        if (m.tipo_mensaje === 'RESOLUCION_PERMISO') {
            const esAprobado = (m.mensaje || '').includes('APROBADA');
            const bgCard = esAprobado ? '#064e3b' : '#7f1d1d';
            const borderCard = esAprobado ? '#10b981' : '#ef4444';
            const titleColor = esAprobado ? '#6ee7b7' : '#fca5a5';

            return `
                <div class="chat-msg-row ${esMio ? 'me' : 'other'}" style="display:flex; justify-content:${esMio ? 'flex-end' : 'flex-start'}; margin-bottom:10px;">
                    <div style="max-width: 85%; width: 420px; background: ${bgCard}; border: 1.5px solid ${borderCard}; border-radius: 12px; padding: 14px; box-shadow: 0 4px 12px rgba(0,0,0,0.25); color: #ffffff;">
                        <div style="display:flex; align-items:center; gap:8px; font-weight:800; font-size:13.5px; color:${titleColor}; border-bottom:1px solid rgba(255,255,255,0.15); padding-bottom:8px; margin-bottom:8px;">
                            <i class="ph ${esAprobado ? 'ph-check-circle' : 'ph-x-circle'}" style="font-size:20px;"></i>
                            <span>DICTAMEN DE PERMISO LABORAL</span>
                        </div>
                        <div style="font-size:12.5px; line-height:1.55; white-space:pre-line; color:#f8fafc;">
                            ${m.mensaje}
                        </div>
                        <div style="text-align:right; font-size:10px; color:rgba(255,255,255,0.7); margin-top:6px;">${hora}</div>
                    </div>
                </div>
            `;
        }

        // Mensajes regulares (Texto, Imágenes, Archivos)
        const bgBubble = esMio ? '#005c4b' : '#202c33';
        let adjuntoHtml = "";
        if (m.tipo_mensaje === 'IMAGEN' && m.archivo_url) {
            adjuntoHtml = `
                <div style="margin-bottom:6px; border-radius:8px; overflow:hidden; cursor:pointer;" onclick="window.open('${m.archivo_url}', '_blank')">
                    <img src="${m.archivo_url}" style="max-width:100%; max-height:260px; object-fit:cover; display:block;">
                </div>`;
        } else if (m.tipo_mensaje === 'ARCHIVO' && m.archivo_url) {
            adjuntoHtml = `
                <a href="${m.archivo_url}" target="_blank" style="display:flex; align-items:center; gap:8px; background:rgba(0,0,0,0.2); padding:8px 12px; border-radius:6px; color:#38bdf8; text-decoration:none; margin-bottom:6px; font-size:12px; font-weight:600;">
                    <i class="ph ph-file-arrow-down" style="font-size:20px;"></i>
                    <span>Descargar archivo adjunto</span>
                </a>`;
        }

        return `
            <div class="chat-msg-row ${esMio ? 'me' : 'other'}" style="display:flex; justify-content:${esMio ? 'flex-end' : 'flex-start'}; margin-bottom:8px;">
                <div style="max-width:75%; min-width:140px; background:${bgBubble}; padding:8px 12px; border-radius:8px; color:#e9edef; font-size:13px; line-height:1.4; box-shadow:0 1px 3px rgba(0,0,0,0.2);">
                    ${!esMio ? `<div style="font-size:11px; font-weight:700; color:#818cf8; margin-bottom:2px;">${m.autor_nombre}</div>` : ''}
                    ${adjuntoHtml}
                    ${m.mensaje && m.tipo_mensaje !== 'IMAGEN' && m.tipo_mensaje !== 'ARCHIVO' ? `<div style="white-space:pre-wrap; word-break:break-word;">${m.mensaje}</div>` : (m.mensaje ? `<div style="font-size:12px; margin-top:4px;">${m.mensaje}</div>` : '')}
                    <div style="display:flex; justify-content:flex-end; align-items:center; gap:4px; font-size:10px; color:#8696a0; margin-top:4px;">
                        <span>${hora}</span>
                        ${esMio ? '<i class="ph ph-checks" style="color:#53bdeb; font-size:14px;"></i>' : ''}
                    </div>
                </div>
            </div>
        `;
    }).join("");

    area.innerHTML = html;
    if (!mantenerScroll) {
        area.scrollTop = area.scrollHeight;
    }
}

// ==============================================================================
// ENVIAR MENSAJE EN CHAT ADMINISTRATIVO
// ==============================================================================
async function enviarMensajeAdmin() {
    const input = document.getElementById("chat-input-mensaje");
    if (!input || !adminChatState.chatActual) return;

    const texto = input.value.trim();
    if (!texto) return;

    input.value = "";
    input.focus();

    const u = chatState.usuario || {};
    const idEmpLector = String(u.id_empleado || "000").trim();
    const esAdmin = adminChatState.esAdmin;

    const payload = {
        autor_id: idEmpLector,
        autor_nombre: u.nombre_completo || u.nombre || (esAdmin ? "Administración" : "Colaborador"),
        autor_rol: esAdmin ? "ADMIN" : (u.rol || "EMPLEADO"),
        mensaje: texto,
        tipo_mensaje: "TEXTO",
        archivo_url: null,
        metadata_extra: {}
    };

    try {
        const idDest = adminChatState.chatActual.id_empleado;
        const resp = await fetch(`${CHAT_API_URL}/api/chat-admin/mensajes/${idDest}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
        const resData = await resp.json();

        // Agregar de inmediato si el socket no lo entregó ya
        if (resData.data && !adminChatState.mensajes.some(m => m.id === resData.data.id)) {
            adminChatState.mensajes.push(resData.data);
            renderizarMensajesAdmin();
        }
    } catch(err) {
        console.error("Error al enviar mensaje admin:", err);
        alert("Error al enviar mensaje al canal administrativo.");
    }
}

// ==============================================================================
// SUBIR ARCHIVO O FOTO EN CHAT ADMINISTRATIVO
// ==============================================================================
async function subirArchivoAdmin(file) {
    if (!file || !adminChatState.chatActual) return;

    const btnAdj = document.getElementById("btn-chat-adjunto");
    if (btnAdj) btnAdj.innerHTML = '<i class="ph ph-spinner ph-spin"></i>';

    const idDest = adminChatState.chatActual.id_empleado;
    const formData = new FormData();
    formData.append("archivo", file);

    try {
        const resUp = await fetch(`${CHAT_API_URL}/api/chat-admin/subir-adjunto/${idDest}`, {
            method: "POST",
            body: formData
        });

        if (!resUp.ok) throw new Error("Error al subir archivo");
        const dataUp = await resUp.json();

        const esImg = file.type.startsWith("image/");
        const u = chatState.usuario || {};
        const idEmpLector = String(u.id_empleado || "000").trim();

        const payload = {
            autor_id: idEmpLector,
            autor_nombre: u.nombre_completo || u.nombre || "Usuario",
            autor_rol: adminChatState.esAdmin ? "ADMIN" : (u.rol || "EMPLEADO"),
            mensaje: esImg ? "" : file.name,
            tipo_mensaje: esImg ? "IMAGEN" : "ARCHIVO",
            archivo_url: dataUp.archivo_url,
            metadata_extra: { filename: file.name, size: file.size }
        };

        const resp = await fetch(`${CHAT_API_URL}/api/chat-admin/mensajes/${idDest}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (resp.ok) {
            const resData = await resp.json();
            if (resData.data) {
                adminChatState.mensajes.push(resData.data);
                renderizarMensajesAdmin();
            }
        }
    } catch(e) {
        console.error("Error en subirArchivoAdmin:", e);
        alert("No se pudo enviar el archivo adjunto.");
    } finally {
        if (btnAdj) btnAdj.innerHTML = '<i class="ph ph-camera"></i>';
    }
}

// ==============================================================================
// WEBSOCKET DEL CHAT ADMINISTRATIVO
// ==============================================================================
function conectarWebSocketAdmin(idEmpleado) {
    if (adminChatState.ws) {
        try { adminChatState.ws.close(); } catch(e){}
        adminChatState.ws = null;
    }

    try {
        const wsProtocol = window.location.protocol === "https:" ? "wss:" : "ws:";
        const wsHost = window.location.host;
        const esAdmin = adminChatState.esAdmin;
        const wsUrl = `${wsProtocol}//${wsHost}/api/chat-admin/ws/${idEmpleado}?es_admin=${esAdmin ? 'true' : 'false'}`;

        adminChatState.ws = new WebSocket(wsUrl);

        adminChatState.ws.onmessage = (event) => {
            try {
                const data = JSON.parse(event.data);
                if (data.id && adminChatState.chatActual && String(adminChatState.chatActual.id_empleado) === String(data.id_empleado)) {
                    // Evitar duplicados
                    if (!adminChatState.mensajes.some(m => m.id === data.id)) {
                        adminChatState.mensajes.push(data);
                        renderizarMensajesAdmin();
                        if (typeof reproducirTimbreVPRO === 'function') {
                            reproducirTimbreVPRO();
                        }
                    }
                } else if (data.tipo_alerta === "NUEVO_MENSAJE_ADMIN") {
                    // Actualizar contador global y lista de conversaciones
                    cargarListaAdminChat();
                    if (typeof reproducirTimbreVPRO === 'function') {
                        reproducirTimbreVPRO();
                    }
                }
            } catch(e){}
        };
    } catch(e) {
        console.warn("WebSocket admin error:", e);
    }
}

// ==============================================================================
// ENLACE DIRECTO DESDE EL CHAT HACIA EL MÓDULO RH PARA DICTAMINAR
// ==============================================================================
function irARHParaDictaminar(idEmpleado, idPermiso) {
    const urlDest = `/?vista=rh&dictaminar_emp=${idEmpleado}&dictaminar_permiso=${idPermiso}`;
    window.location.href = urlDest;
}



// ==============================================================================
// VERIFICAR NOTIFICACIONES GLOBALES DE ADMINISTRACIÓN & RH
// ==============================================================================
async function actualizarBadgeAdminGlobal() {
    try {
        const u = chatState.usuario || {};
        const idEmp = String(u.id_empleado || "").trim();
        if (!idEmp) return;
        const esAdmin = esUsuarioAdminChat();
        const base = (typeof CHAT_API_URL !== 'undefined' && CHAT_API_URL) || (typeof API_URL !== 'undefined' && API_URL) || '';
        const resp = await fetch(`${base}/api/chat-admin/conversaciones?usuario_id=${idEmp}&es_admin=${esAdmin ? 'true' : 'false'}`);
        if (!resp.ok) return;
        const convs = await resp.json();
        const total = (convs || []).reduce((acc, c) => acc + (c.no_leidos || 0) + (c.permisos_pendientes || 0), 0);
        const badgeEl = document.getElementById("badge-admin-no-leidos");
        if (badgeEl) {
            if (total > 0) {
                badgeEl.textContent = total;
                badgeEl.style.display = "inline-block";
            } else {
                badgeEl.style.display = "none";
            }
        }
    } catch(e) {}
}
