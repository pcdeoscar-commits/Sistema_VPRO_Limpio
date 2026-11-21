// ==============================================================================
// MÓDULO: notificaciones_flotantes.js
// Sistema Global de Notificaciones en Tiempo Real (Sonido Tilín-Tilín + Toast Flotante)
// VPRO Workspace - ISO 9001:2015
// ==============================================================================

(function () {
    let wsNotificaciones = null;
    let reconnectTimeout = null;
    let usuarioActualId = null;
    let audioCtxVpro = null;
    let noLeidosCount = 0;

    // Inicializar o reanudar AudioContext con interacción del usuario para evitar bloqueo del navegador
    function obtenerAudioContext() {
        if (!audioCtxVpro) {
            const AudioClass = window.AudioContext || window.webkitAudioContext;
            if (AudioClass) {
                audioCtxVpro = new AudioClass();
            }
        }
        if (audioCtxVpro && audioCtxVpro.state === 'suspended') {
            audioCtxVpro.resume().catch(() => {});
        }
        return audioCtxVpro;
    }

    // Desbloquear audio con el primer clic del usuario en la pantalla
    ['click', 'keydown', 'touchstart'].forEach(evt => {
        window.addEventListener(evt, () => {
            obtenerAudioContext();
        }, { once: true, passive: true });
    });

    // 🔔 GENERADOR DE SONIDO "TILÍN TILÍN" (Campanadas dulces y cristalinas con Web Audio API)
    function sonarCampanilla(ctx, freq, tInicio, duracion, volMax) {
        try {
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();

            osc.type = 'sine'; // Onda pura tipo campana
            osc.frequency.setValueAtTime(freq, tInicio);

            // Envolvente de decaimiento exponencial suave
            gain.gain.setValueAtTime(0.0001, tInicio);
            gain.gain.exponentialRampToValueAtTime(volMax, tInicio + 0.02);
            gain.gain.exponentialRampToValueAtTime(0.0001, tInicio + duracion);

            osc.connect(gain);
            gain.connect(ctx.destination);

            osc.start(tInicio);
            osc.stop(tInicio + duracion);
        } catch (e) {
            console.warn("Error generando tono campana:", e);
        }
    }

    function tocarTilinTilinVPRO() {
        try {
            const ctx = obtenerAudioContext();
            if (!ctx) return;

            const t0 = ctx.currentTime;

            // Primer "Ti" (D6 cristalino + armónico D7)
            sonarCampanilla(ctx, 1174.66, t0, 0.38, 0.28);
            sonarCampanilla(ctx, 2349.32, t0, 0.25, 0.12);

            // Segundo "Lín" (F#6 brillante con resonancia + armónico F#7)
            const t1 = t0 + 0.16;
            sonarCampanilla(ctx, 1479.98, t1, 0.55, 0.32);
            sonarCampanilla(ctx, 2959.96, t1, 0.40, 0.15);
        } catch (err) {
            console.warn("Fallo al reproducir tilín tilín:", err);
        }
    }

    // Obtener información del usuario logueado en VPRO Workspace
    function obtenerUsuarioActual() {
        if (typeof usuarioLogueado !== 'undefined' && usuarioLogueado && usuarioLogueado.id_empleado) {
            return usuarioLogueado;
        }
        try {
            const raw = localStorage.getItem("vpro_chat_usuario") || localStorage.getItem("usuarioLogueado");
            if (raw) return JSON.parse(raw);
        } catch (e) {}
        return null;
    }

    // Contenedor flotante para los Toasts de avisos
    function asegurarContenedorToasts() {
        let contenedor = document.getElementById("vpro-toasts-container");
        if (!contenedor) {
            contenedor = document.createElement("div");
            contenedor.id = "vpro-toasts-container";
            contenedor.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                z-index: 9999999;
                display: flex;
                flex-direction: column;
                gap: 12px;
                pointer-events: none;
                max-width: 390px;
                width: calc(100vw - 40px);
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            `;
            document.body.appendChild(contenedor);
        }
        return contenedor;
    }

    // Actualizar badge visual en el sidebar de index.html
    function actualizarBadgeNavSidebar(incrementar = true) {
        if (incrementar) noLeidosCount++;
        else noLeidosCount = 0;

        const navChat = document.getElementById("nav-item-chat-op");
        if (!navChat) return;

        let badge = navChat.querySelector(".vpro-toast-nav-badge");
        if (!badge) {
            badge = document.createElement("span");
            badge.className = "vpro-toast-nav-badge";
            badge.style.cssText = `
                background: #ef4444;
                color: #ffffff;
                font-size: 10px;
                font-weight: 800;
                padding: 2px 7px;
                border-radius: 12px;
                margin-left: auto;
                box-shadow: 0 0 10px rgba(239, 68, 68, 0.6);
                animation: vproBadgePulse 1.8s infinite;
            `;
            navChat.appendChild(badge);
        }

        if (noLeidosCount > 0) {
            badge.textContent = noLeidosCount > 99 ? '99+' : noLeidosCount;
            badge.style.display = "inline-block";
        } else {
            badge.style.display = "none";
        }
    }

    // Mostrar el Toast flotante visual
    function mostrarToastFlotanteVPRO(data) {
        const contenedor = asegurarContenedorToasts();

        // Si ya estamos en chat.html y en la misma sala, no saturar con popup si está visible
        const esPaginaChat = window.location.pathname.includes("chat.html");
        if (esPaginaChat && document.visibilityState === 'visible') {
            if (typeof chatState !== 'undefined') {
                const arista = data.origen || '';
                if (chatState.arista === arista) {
                    // Ya está en la misma arista viendo la pantalla, omitir toast invasivo
                    return;
                }
            }
        }

        // Tocar campanada tilín-tilín
        tocarTilinTilinVPRO();

        // Incrementar badge en sidebar
        actualizarBadgeNavSidebar(true);

        const card = document.createElement("div");
        card.className = "vpro-toast-card";
        card.style.cssText = `
            pointer-events: auto;
            background: rgba(15, 23, 42, 0.96);
            backdrop-filter: blur(14px);
            -webkit-backdrop-filter: blur(14px);
            border: 1px solid rgba(255, 255, 255, 0.14);
            border-left: 4px solid ${data.badge_color || '#3b82f6'};
            border-radius: 12px;
            padding: 13px 15px;
            box-shadow: 0 14px 35px rgba(0, 0, 0, 0.55), 0 0 1px rgba(255,255,255,0.2);
            color: #f8fafc;
            display: flex;
            flex-direction: column;
            gap: 9px;
            transform: translateX(115%);
            opacity: 0;
            transition: transform 0.35s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.35s ease;
            position: relative;
            overflow: hidden;
            cursor: pointer;
        `;

        const fotoUrl = data.foto_url || 'vendor/img/avatar_default.png';
        const autor = data.autor || 'Sistema VPRO';
        const titulo = data.titulo || 'Nuevo Mensaje';
        const mensaje = data.mensaje || '';
        const badgeTexto = data.badge_texto || 'CHAT';
        const badgeColor = data.badge_color || '#3b82f6';
        const urlChat = data.url_chat || 'chat.html';

        card.innerHTML = `
            <div style="display: flex; align-items: center; justify-content: space-between; gap: 8px;">
                <div style="display: flex; align-items: center; gap: 6px;">
                    <span style="background: ${badgeColor}; color: #ffffff; font-size: 10px; font-weight: 800; padding: 2px 7px; border-radius: 6px; letter-spacing: 0.3px; text-transform: uppercase;">
                        ${badgeTexto}
                    </span>
                    <span style="font-size: 11.5px; color: #94a3b8; font-weight: 500; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 190px;">
                        ${titulo}
                    </span>
                </div>
                <button class="vpro-toast-btn-cerrar" style="background: transparent; border: none; color: #94a3b8; font-size: 15px; cursor: pointer; padding: 2px 4px; border-radius: 4px; line-height: 1;" title="Cerrar aviso">✕</button>
            </div>

            <div style="display: flex; align-items: flex-start; gap: 11px;">
                <img src="${fotoUrl}" onerror="this.onerror=null; this.src='vendor/img/avatar_default.png';" 
                     style="width: 38px; height: 38px; border-radius: 50%; object-fit: cover; border: 1.5px solid ${badgeColor}; flex-shrink: 0;" />
                <div style="flex: 1; min-width: 0;">
                    <div style="font-size: 13px; font-weight: 700; color: #ffffff; line-height: 1.25; margin-bottom: 3px;">
                        ${autor}
                    </div>
                    <div style="font-size: 12px; color: #cbd5e1; line-height: 1.35; overflow: hidden; text-overflow: ellipsis; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; word-break: break-word;">
                        ${mensaje}
                    </div>
                </div>
            </div>

            <div style="display: flex; justify-content: flex-end; align-items: center; gap: 8px; margin-top: 2px; padding-top: 6px; border-top: 1px solid rgba(255,255,255,0.08);">
                <button class="vpro-toast-btn-abrir" style="background: #2563eb; color: #ffffff; border: none; border-radius: 6px; padding: 6px 13px; font-size: 11.5px; font-weight: 700; cursor: pointer; display: flex; align-items: center; gap: 5px; transition: background 0.2s;">
                    Abrir Chat 💬
                </button>
            </div>

            <!-- Barra de progreso de auto-cierre -->
            <div class="vpro-toast-progress" style="position: absolute; bottom: 0; left: 0; height: 3px; background: ${badgeColor}; width: 100%; transition: width 7.5s linear;"></div>
        `;

        contenedor.appendChild(card);

        // Animar entrada
        requestAnimationFrame(() => {
            card.style.transform = "translateX(0)";
            card.style.opacity = "1";
            const barra = card.querySelector(".vpro-toast-progress");
            if (barra) {
                requestAnimationFrame(() => {
                    barra.style.width = "0%";
                });
            }
        });

        const cerrarToast = () => {
            card.style.transform = "translateX(115%)";
            card.style.opacity = "0";
            setTimeout(() => {
                try { card.remove(); } catch(e){}
            }, 350);
        };

        const abrirChat = (e) => {
            if (e) e.stopPropagation();
            actualizarBadgeNavSidebar(false);
            window.open(urlChat, '_blank');
            cerrarToast();
        };

        // Eventos
        const btnCerrar = card.querySelector(".vpro-toast-btn-cerrar");
        if (btnCerrar) {
            btnCerrar.onclick = (e) => {
                e.stopPropagation();
                cerrarToast();
            };
        }

        const btnAbrir = card.querySelector(".vpro-toast-btn-abrir");
        if (btnAbrir) {
            btnAbrir.onclick = abrirChat;
        }

        card.onclick = abrirChat;

        // Auto-cerrar después de 7.5 segundos
        const autoCierre = setTimeout(cerrarToast, 7500);

        card.onmouseenter = () => {
            clearTimeout(autoCierre);
            const barra = card.querySelector(".vpro-toast-progress");
            if (barra) barra.style.transition = 'none';
        };
        card.onmouseleave = () => {
            setTimeout(cerrarToast, 3500);
        };
    }

    // ==============================================================================
    // CONEXIÓN WEBSOCKET DE NOTIFICACIONES PRIVADAS
    // ==============================================================================
    function conectarWebSocketNotificaciones() {
        const usuario = obtenerUsuarioActual();
        if (!usuario || !usuario.id_empleado) {
            // Usuario aún no logueado, esperar
            return;
        }

        const idEmp = String(usuario.id_empleado).trim();
        if (usuarioActualId === idEmp && wsNotificaciones && (wsNotificaciones.readyState === WebSocket.OPEN || wsNotificaciones.readyState === WebSocket.CONNECTING)) {
            return;
        }

        usuarioActualId = idEmp;

        if (wsNotificaciones) {
            try { wsNotificaciones.close(); } catch(e){}
            wsNotificaciones = null;
        }

        const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const host = window.location.host;
        const wsUrl = `${wsProtocol}//${host}/api/notificaciones/ws/${encodeURIComponent(idEmp)}`;

        try {
            wsNotificaciones = new WebSocket(wsUrl);

            wsNotificaciones.onopen = () => {
                console.log(`🔔 [VPRO Notificaciones] Conectado en tiempo real para empleado #${idEmp}`);
                if (reconnectTimeout) {
                    clearTimeout(reconnectTimeout);
                    reconnectTimeout = null;
                }
            };

            wsNotificaciones.onmessage = (event) => {
                try {
                    const data = JSON.parse(event.data);
                    if (data && data.tipo === "AVISO_CHAT_VPRO") {
                        mostrarToastFlotanteVPRO(data);
                    }
                } catch (err) {
                    console.error("Error procesando mensaje de notificación:", err);
                }
            };

            wsNotificaciones.onclose = () => {
                wsNotificaciones = null;
                programarReconexion();
            };

            wsNotificaciones.onerror = () => {
                try { wsNotificaciones.close(); } catch(e){}
            };

        } catch (err) {
            console.warn("Fallo al crear WebSocket de notificaciones:", err);
            programarReconexion();
        }
    }

    function programarReconexion() {
        if (!reconnectTimeout) {
            reconnectTimeout = setTimeout(() => {
                reconnectTimeout = null;
                conectarWebSocketNotificaciones();
            }, 4500);
        }
    }

    // Inicializar listeners al cargar la ventana
    document.addEventListener("DOMContentLoaded", () => {
        conectarWebSocketNotificaciones();

        // Si el usuario da clic en el menú Chat de OP, limpiar badge
        const navChat = document.getElementById("nav-item-chat-op");
        if (navChat) {
            navChat.addEventListener("click", () => {
                actualizarBadgeNavSidebar(false);
            });
        }
    });

    // Monitorear cambios de pestaña / visibilidad para asegurar conexión activa
    document.addEventListener("visibilitychange", () => {
        if (document.visibilityState === 'visible') {
            conectarWebSocketNotificaciones();
        }
    });

    // Inyectar animación CSS para el pulso del badge si no existe
    if (!document.getElementById("vpro-toast-css-keyframes")) {
        const style = document.createElement("style");
        style.id = "vpro-toast-css-keyframes";
        style.textContent = `
            @keyframes vproBadgePulse {
                0% { transform: scale(1); opacity: 1; }
                50% { transform: scale(1.18); opacity: 0.85; }
                100% { transform: scale(1); opacity: 1; }
            }
        `;
        document.head.appendChild(style);
    }

    // Exponer función de conexión global para ser llamada tras el login en auth.js
    window.iniciarNotificacionesVPRO = conectarWebSocketNotificaciones;
    window.tocarTilinTilinVPRO = tocarTilinTilinVPRO;
    window.mostrarToastFlotanteVPRO = mostrarToastFlotanteVPRO;

})();
