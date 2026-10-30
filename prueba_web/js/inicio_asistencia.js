// ==============================================================================
// MÓDULO: inicio_asistencia.js
// 4-5. Módulo Inicio, notificaciones, reloj, kiosco, asistencia
// Líneas originales: 572–1252 de script.js
// ==============================================================================

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

    // Auto-apertura si se proviene de una alerta del Chat de Administración
    try {
        const urlP = new URLSearchParams(window.location.search);
        const urlEmp = urlP.get('dictaminar_emp');
        const urlPer = urlP.get('dictaminar_permiso');
        if (urlEmp && urlPer && !window._dictamenUrlProcesado) {
            window._dictamenUrlProcesado = true;
            setTimeout(() => {
                if (typeof abrirDictamenPermisoDesdeNotif === 'function') {
                    abrirDictamenPermisoDesdeNotif(urlEmp, parseInt(urlPer));
                }
            }, 600);
        }
    } catch(e) {}
    actualizarVisibilidadAgendaDrive();
    actualizarMonitorAccesosCEO();

    // Foto de perfil del empleado en banner de inicio
    const elFotoInicio = document.getElementById("inicio-foto-empleado");
    if (elFotoInicio) {
        const idEmp = String(usuarioLogueado.id_empleado || '000').trim();
        elFotoInicio.src = usuarioLogueado.foto_url || `${API_URL}/fotos/${idEmp}.jpg`;
    }

    // ══════════════════════════════════════════════════════════════════
    // CENTRO DE NOTIFICACIONES — Sistema de Dropdowns por Categoría
    // Categorías: Transfer, OPs/Checkout, Licencia, Docs oficiales,
    //             Vacaciones disponibles, Gastos sin comprobar
    // ══════════════════════════════════════════════════════════════════
    const contenedorNotif = document.getElementById("inicio-notificaciones");
    if (contenedorNotif) {
        contenedorNotif.innerHTML = `<div style="text-align:center;color:#94a3b8;padding:12px;font-size:13px;">⏳ Cargando notificaciones...</div>`;

        const idEmp = usuarioLogueado.id_empleado;

        // Determinar si el usuario tiene rol administrativo o directivo
        const esAdminRH = (typeof esUsuarioAutorizadoDireccion === 'function' && esUsuarioAutorizadoDireccion()) || 
                          ((usuarioLogueado?.rol || '').toUpperCase().includes('ADMIN')) ||
                          ((usuarioLogueado?.puesto || '').toUpperCase().includes('ADMIN'));

        const esSeguimientoMantenimiento = ['201', '202'].includes(String(idEmp).trim());

        // Lanzar todas las peticiones en paralelo
        const [resTrans, resCheck, resAlertas, resVac, resGastos, resPermisosPend, resDanosTodos] = await Promise.allSettled([
            fetch(`${API_URL}/api/transferencias/pendientes_notificacion/${idEmp}`),
            fetch(`${API_URL}/api/checkout/pendientes/${idEmp}/${encodeURIComponent(usuarioLogueado.nombre_completo || usuarioLogueado.nombre || '')}`),
            fetch(`${API_URL}/api/rh/alertas?id_empleado=${idEmp}`),
            fetch(`${API_URL}/api/rh/vacaciones/${idEmp}`),
            fetch(`${API_URL}/api/gastos/pendientes-auditoria`),
            esAdminRH ? fetch(`${API_URL}/api/rh/permisos/pendientes`) : Promise.resolve({ ok: false }),
            esSeguimientoMantenimiento ? fetch(`${API_URL}/api/inventario/radar-danos`) : Promise.resolve({ ok: false })
        ]);

        // ── Helper: construir tarjeta-grupo tipo accordion/dropdown ──────
        let _notifUID = 0;
        function buildDropdownCard({ icon, color, bg, border, titulo, badge, badgeColor, items, renderItem }) {
            if (!items || items.length === 0) return '';
            const uid = `notif-drop-${++_notifUID}`;
            const itemsHtml = items.map((it, idx) => renderItem(it, idx)).join('');
            return `
            <div class="notif-dropdown-card" style="background:${bg}; border-left:4px solid ${border}; border-radius:10px; margin-bottom:10px; box-shadow:0 2px 6px rgba(0,0,0,0.06); overflow:hidden;">
                <div onclick="toggleNotifDropdown('${uid}')" style="display:flex; align-items:center; gap:14px; padding:14px 18px; cursor:pointer; user-select:none;">
                    <div style="width:42px;height:42px;border-radius:8px;background:${color};color:white;display:flex;align-items:center;justify-content:center;font-size:22px;flex-shrink:0;">
                        <i class="ph ${icon}"></i>
                    </div>
                    <div style="flex:1;">
                        <div style="font-size:14px;font-weight:700;color:#1e293b;">${titulo}</div>
                    </div>
                    <span style="background:${badgeColor||border};color:white;border-radius:20px;padding:3px 11px;font-size:12px;font-weight:700;margin-right:6px;">${badge}</span>
                    <i class="ph ph-caret-down" id="${uid}-caret" style="font-size:18px;color:${color};transition:transform .25s;"></i>
                </div>
                <div id="${uid}" style="display:none; border-top:1px solid rgba(0,0,0,0.07); padding:8px 14px 12px;">
                    ${itemsHtml}
                </div>
            </div>`;
        }

        let gruposHtml = [];
        // ── ⭐ ACCESO DESTACADO: Chat Operativo de OPs (WhatsApp) ─────────────
        gruposHtml.push(`
            <div class="notif-card-chat-op" style="background: linear-gradient(135deg, #064e3b 0%, #0f766e 100%); border-left: 5px solid #10b981; border-radius: 12px; margin-bottom: 14px; box-shadow: 0 4px 14px rgba(16, 185, 129, 0.25); padding: 14px 18px; color: white;">
                <div style="display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap;">
                    <div style="display: flex; align-items: center; gap: 14px; flex: 1; min-width: 220px;">
                        <div style="width: 44px; height: 44px; border-radius: 10px; background: rgba(255, 255, 255, 0.18); backdrop-filter: blur(4px); color: white; display: flex; align-items: center; justify-content: center; font-size: 24px; flex-shrink: 0; box-shadow: 0 2px 6px rgba(0,0,0,0.15);">
                            <i class="ph ph-chat-teardrop-dots"></i>
                        </div>
                        <div>
                            <div style="font-size: 15px; font-weight: 700; color: #ffffff; display: flex; align-items: center; gap: 8px;">
                                💬 Chat Operativo de OPs
                                <span style="background: #10b981; color: #064e3b; font-size: 10px; font-weight: 800; padding: 2px 8px; border-radius: 10px; letter-spacing: 0.5px;">WHATSAPP OP</span>
                            </div>
                            <div style="font-size: 12px; color: #a7f3d0; margin-top: 3px; line-height: 1.3;">
                                Indicaciones técnicas, enlaces vMix y bitácora de tus eventos asignados
                            </div>
                        </div>
                    </div>
                    <div>
                        <button onclick="window.open('chat.html', '_blank')" 
                                style="background: #ffffff; color: #065f46; border: none; padding: 10px 18px; border-radius: 8px; cursor: pointer; font-weight: 700; font-size: 13.5px; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.15); transition: all 0.2s ease;">
                            <i class="ph ph-chats-circle" style="font-size: 18px; color: #059669;"></i> Entrar a mis Chats <i class="ph ph-arrow-right" style="font-size: 14px;"></i>
                        </button>
                    </div>
                </div>
            </div>
        `);


        // ── A. VPRO Transfer — Archivos pendientes de bajar ──────────────
        try {
            if (resTrans.status === 'fulfilled' && resTrans.value.ok) {
                const dataTrans = await resTrans.value.json();
                const pendientes = dataTrans?.pendientes || [];
                if (pendientes.length > 0) {
                    const cant = pendientes.length;
                    gruposHtml.push(`
                        <div class="notif-card-transfer" style="background:#eff6ff; border-left:4px solid #3b82f6; border-radius:10px; margin-bottom:12px; box-shadow:0 2px 6px rgba(0,0,0,0.06); padding:14px 18px; display:flex; align-items:center; justify-content:space-between; gap:16px; flex-wrap:wrap;">
                            <div style="display:flex; align-items:center; gap:14px; flex:1; min-width:280px;">
                                <div style="width:44px; height:44px; border-radius:8px; background:#2563eb; color:white; display:flex; align-items:center; justify-content:center; font-size:24px; flex-shrink:0; box-shadow:0 2px 6px rgba(37,99,235,0.3);">
                                    <i class="ph ph-cloud-arrow-down"></i>
                                </div>
                                <div>
                                    <div style="font-size:15px; font-weight:700; color:#1e3a8a;">
                                        En buzón hay <span style="background:#2563eb; color:white; padding:2px 8px; border-radius:12px; font-size:13px; font-weight:800;">${cant}</span> archivo${cant !== 1 ? 's' : ''} por descargar
                                    </div>
                                    <div style="font-size:12px; color:#b45309; background:#fffbeb; border:1px solid #fde68a; padding:3px 8px; border-radius:6px; display:inline-flex; align-items:center; gap:6px; margin-top:6px; font-weight:600;">
                                        ⚠️ <b>RECUERDA:</b> Los archivos permanecerán por solo 24 hrs. después que los has bajado
                                    </div>
                                </div>
                            </div>
                            <div>
                                <button onclick="cambiarVista('vista-transferencias'); cambiarPestanaTransferencias('recibidos');" 
                                        style="background:#2563eb; color:white; border:none; padding:10px 18px; border-radius:8px; cursor:pointer; font-weight:700; font-size:13.5px; display:inline-flex; align-items:center; gap:8px; box-shadow:0 3px 8px rgba(37,99,235,0.35); transition:all 0.2s ease;">
                                    <i class="ph ph-tray" style="font-size:18px;"></i> Ir a buzón <i class="ph ph-arrow-right" style="font-size:15px;"></i>
                                </button>
                            </div>
                        </div>
                    `);
                }
            }
        } catch(e) { console.error('Transfer notif:', e); }

        // ── 🛠️ SEGUIMIENTO DE EQUIPOS DAÑADOS Y TALLER (EXCLUSIVO EMPLEADOS 201 Y 202) ──────
        try {
            if (esSeguimientoMantenimiento && resDanosTodos.status === 'fulfilled' && resDanosTodos.value.ok) {
                const danosActivos = await resDanosTodos.value.json();
                if (Array.isArray(danosActivos) && danosActivos.length > 0) {
                    gruposHtml.push(buildDropdownCard({
                        icon: 'ph-wrench',
                        color: '#dc2626',
                        bg: '#fef2f2',
                        border: '#ef4444',
                        titulo: '🛠️ Reportes de Equipos Dañados y Taller (Seguimiento)',
                        badge: `${danosActivos.length} equipo${danosActivos.length !== 1 ? 's' : ''}`,
                        badgeColor: '#dc2626',
                        items: danosActivos,
                        renderItem: (d) => `
                            <div style="display:flex; align-items:center; justify-content:space-between; gap:12px; padding:12px 14px; border-bottom:1px solid #fee2e2; background:white; border-radius:8px; margin-bottom:8px; box-shadow:0 1px 3px rgba(0,0,0,0.05); flex-wrap:wrap;">
                                <div style="display:flex; align-items:center; gap:12px; flex:1; min-width:240px;">
                                    <div style="width:38px; height:38px; border-radius:8px; background:#fee2e2; color:#b91c1c; display:flex; align-items:center; justify-content:center; font-size:20px; flex-shrink:0;">
                                        <i class="ph ph-warning-octagon"></i>
                                    </div>
                                    <div>
                                        <div style="font-size:13.5px; font-weight:700; color:#0f172a;">
                                            ${d.EQUIPO || d.ID} 
                                            <span style="font-size:11px; font-family:monospace; font-weight:700; color:#2563eb; background:#eff6ff; padding:2px 6px; border-radius:4px; margin-left:4px;">${d.ID}</span>
                                            <span style="font-size:10.5px; font-weight:700; color:#b91c1c; background:#fee2e2; padding:2px 6px; border-radius:4px; margin-left:4px;">${d.ESTADO || 'EN REVISIÓN'}</span>
                                        </div>
                                        <div style="font-size:12px; color:#475569; margin-top:3px; line-height:1.3;">
                                            <b>Falla detectada:</b> "${d.FALLA || 'Sin detalle registrado'}"
                                        </div>
                                        <div style="font-size:11.5px; color:#64748b; margin-top:2px;">
                                            Reportó: <b>${d['REPORTÓ'] || 'Personal'}</b> (${d.DEPARTAMENTO || 'General'}) • Fecha: <b>${d.FECHA_REPORTE ? String(d.FECHA_REPORTE).substring(0, 10) : 'N/A'}</b>
                                        </div>
                                    </div>
                                </div>
                                <div style="display:flex; align-items:center; gap:8px;">
                                    <button type="button" onclick="irASeguimientoTaller('${d.ID}', '${d.NUM_SERVICIO}')" 
                                            style="background:#dc2626; color:white; border:none; padding:8px 14px; border-radius:6px; cursor:pointer; font-weight:700; font-size:12px; display:inline-flex; align-items:center; gap:6px; box-shadow:0 2px 4px rgba(220,38,38,0.25); transition:all .15s;"
                                            onmouseover="this.style.background='#b91c1c'" onmouseout="this.style.background='#dc2626'">
                                        <i class="ph ph-wrench" style="font-size:14px;"></i> Dar Seguimiento en Taller ➔
                                    </button>
                                </div>
                            </div>
                        `
                    }));
                }
            }
        } catch(e) { console.error('Danos seguimiento notif:', e); }

        // ── B. OPs convocadas (Checkout pendiente) ────────────────────────
        try {
            if (resCheck.status === 'fulfilled' && resCheck.value.ok) {
                const ops = await resCheck.value.json();
                gruposHtml.push(buildDropdownCard({
                    icon: 'ph-clipboard-text',
                    color: '#b45309', bg: '#fffbeb', border: '#d97706',
                    titulo: '📋 Órdenes de Producción asignadas',
                    badge: `${ops.length} OP${ops.length !== 1 ? 's' : ''}`,
                    badgeColor: '#b45309',
                    items: ops,
                    renderItem: (op) => `
                        <div style="display:flex;align-items:center;gap:10px;padding:8px 8px;border-radius:8px;margin-bottom:4px;background:#ffffff;border:1px solid #fef3c7;">
                            <div onclick="abrirCheckoutConOP(${op.id_evento||0}, '${(op.label||'').replace(/'/g, "\'")}')" style="flex:1;cursor:pointer;">
                                <div style="font-size:13px;font-weight:700;color:#78350f;display:flex;align-items:center;gap:6px;">
                                    <i class="ph ph-clipboard-text" style="color:#d97706;"></i> ${op.label||op.folio||'Orden pendiente'}
                                </div>
                                <div style="font-size:11.5px;color:#92400e;margin-top:2px;">Estatus: <b>${op.estado||'PENDIENTE'}</b></div>
                            </div>
                            <button type="button" onclick="event.stopPropagation(); window.open('chat.html?folio=${op.folio||op.id_evento}', '_blank');" 
                                    style="background:#059669;color:white;border:none;padding:6px 12px;border-radius:6px;font-size:12px;font-weight:700;cursor:pointer;display:inline-flex;align-items:center;gap:5px;flex-shrink:0;box-shadow:0 2px 4px rgba(5,150,105,0.25);">
                                <i class="ph ph-chat-teardrop-dots" style="font-size:15px;"></i> Chat OP
                            </button>
                        </div>`
                }));
            }
        } catch(e) { console.error('Checkout notif:', e); }

        // ── C. Alertas RH: Licencia de manejo + Documentos oficiales ──────
        try {
            if (resAlertas.status === 'fulfilled' && resAlertas.value.ok) {
                const alertas = await resAlertas.value.json();
                const docsAlerta = (alertas || []).filter(a => a.tipo === 'DOCUMENTO_POR_VENCER');
                const licencias  = docsAlerta.filter(a => (a.mensaje||'').toUpperCase().includes('LICENCIA'));
                const otrosDocs  = docsAlerta.filter(a => !(a.mensaje||'').toUpperCase().includes('LICENCIA'));

                // Licencia de manejo/chofer
                const licUrgente = licencias.some(a => a.urgencia === 'ALTA');
                gruposHtml.push(buildDropdownCard({
                    icon: 'ph-steering-wheel',
                    color: licUrgente ? '#dc2626' : '#d97706',
                    bg: licUrgente ? '#fef2f2' : '#fffbeb',
                    border: licUrgente ? '#ef4444' : '#f59e0b',
                    titulo: '🚗 Licencia de manejo — Aviso',
                    badge: licUrgente ? '⚠️ VENCIDA' : 'Vence pronto',
                    badgeColor: licUrgente ? '#dc2626' : '#d97706',
                    items: licencias,
                    renderItem: (a) => `
                        <div onclick="cambiarVista('vista-rh'); setTimeout(()=>activarPestanaRH('expediente'),300);"
                             style="display:flex;align-items:center;gap:10px;padding:9px 6px;border-radius:8px;cursor:pointer;transition:background .15s;"
                             onmouseover="this.style.background='#fee2e2'" onmouseout="this.style.background='transparent'">
                            <i class="ph ph-identification-card" style="font-size:18px;color:${a.urgencia==='ALTA'?'#dc2626':'#d97706'};flex-shrink:0;"></i>
                            <div style="flex:1;">
                                <div style="font-size:13px;font-weight:600;color:#7f1d1d;">${a.mensaje}</div>
                                <div style="font-size:11.5px;color:#991b1b;">👉 Ir a RH → Expediente Digital para actualizar</div>
                            </div>
                            <i class="ph ph-arrow-right" style="color:#dc2626;font-size:16px;flex-shrink:0;"></i>
                        </div>`
                }));

                // Otros documentos oficiales (INE, NSS, etc.)
                gruposHtml.push(buildDropdownCard({
                    icon: 'ph-files',
                    color: '#7c3aed', bg: '#f5f3ff', border: '#8b5cf6',
                    titulo: '📄 Documentos oficiales por vencer',
                    badge: `${otrosDocs.length} doc${otrosDocs.length !== 1 ? 's' : ''}`,
                    badgeColor: '#7c3aed',
                    items: otrosDocs,
                    renderItem: (a) => `
                        <div onclick="cambiarVista('vista-rh'); setTimeout(()=>activarPestanaRH('expediente'),300);"
                             style="display:flex;align-items:center;gap:10px;padding:9px 6px;border-radius:8px;cursor:pointer;transition:background .15s;"
                             onmouseover="this.style.background='#ede9fe'" onmouseout="this.style.background='transparent'">
                            <i class="ph ph-identification-badge" style="font-size:18px;color:#7c3aed;flex-shrink:0;"></i>
                            <div style="flex:1;">
                                <div style="font-size:13px;font-weight:600;color:#4c1d95;">${a.mensaje}</div>
                                <div style="font-size:11.5px;color:#6d28d9;">👉 Ir a RH → Expediente Digital</div>
                            </div>
                            <i class="ph ph-arrow-right" style="color:#7c3aed;font-size:16px;flex-shrink:0;"></i>
                        </div>`
                }));
            }
        } catch(e) { console.error('Alertas RH notif:', e); }

        // ── D. Vacaciones disponibles ──────────────────────────────────────
        try {
            if (resVac.status === 'fulfilled' && resVac.value.ok) {
                const dataVac = await resVac.value.json();
                const resumen = dataVac?.resumen;
                const diasDisp = resumen?.dias_pendientes || 0;
                if (diasDisp > 0) {
                    gruposHtml.push(buildDropdownCard({
                        icon: 'ph-beach',
                        color: '#059669', bg: '#f0fdf4', border: '#34d399',
                        titulo: '🏖️ Vacaciones disponibles',
                        badge: `${diasDisp} día${diasDisp !== 1 ? 's' : ''}`,
                        badgeColor: '#059669',
                        items: [resumen],
                        renderItem: (r) => `
                            <div onclick="cambiarVista('vista-rh'); setTimeout(()=>activarPestanaRH('vacaciones'),300);"
                                 style="display:flex;align-items:center;gap:10px;padding:9px 6px;border-radius:8px;cursor:pointer;transition:background .15s;"
                                 onmouseover="this.style.background='#dcfce7'" onmouseout="this.style.background='transparent'">
                                <i class="ph ph-sun-horizon" style="font-size:18px;color:#059669;flex-shrink:0;"></i>
                                <div style="flex:1;">
                                    <div style="font-size:13px;font-weight:600;color:#14532d;">
                                        Tienes <b>${r.dias_pendientes}</b> días de vacaciones disponibles (LFT)
                                    </div>
                                    <div style="font-size:11.5px;color:#166534;">
                                        Correspondientes: ${r.dias_totales_correspondientes} · Tomados: ${r.dias_tomados}
                                    </div>
                                    <div style="font-size:11px;color:#15803d;">👉 Ir a RH → Vacaciones para solicitar</div>
                                </div>
                                <i class="ph ph-arrow-right" style="color:#059669;font-size:16px;flex-shrink:0;"></i>
                            </div>`
                    }));
                }
            }
        } catch(e) { console.error('Vacaciones notif:', e); }

        // ── E. Gastos pendientes de comprobación ──────────────────────────
        try {
            if (typeof esUsuarioAutorizadoGastos === 'function' && esUsuarioAutorizadoGastos() && resGastos.status === 'fulfilled' && resGastos.value.ok) {
                const todosGastos = await resGastos.value.json();
                const misGastos = (todosGastos || []).filter(g =>
                    String(g.id_empleado).trim() === String(idEmp).trim()
                );
                gruposHtml.push(buildDropdownCard({
                    icon: 'ph-receipt',
                    color: '#0891b2', bg: '#f0f9ff', border: '#38bdf8',
                    titulo: '🧾 Gastos pendientes de comprobación',
                    badge: `${misGastos.length} OP${misGastos.length !== 1 ? 's' : ''}`,
                    badgeColor: '#0891b2',
                    items: misGastos,
                    renderItem: (g) => `
                        <div onclick="cambiarVista('vista-gastos');"
                             style="display:flex;align-items:center;gap:10px;padding:9px 6px;border-radius:8px;cursor:pointer;transition:background .15s;"
                             onmouseover="this.style.background='#e0f2fe'" onmouseout="this.style.background='transparent'">
                            <i class="ph ph-money" style="font-size:18px;color:#0891b2;flex-shrink:0;"></i>
                            <div style="flex:1;">
                                <div style="font-size:13px;font-weight:600;color:#0c4a6e;">
                                    OP-${g.folio_op} · ${g.evento||'Evento'}
                                </div>
                                <div style="font-size:11.5px;color:#0369a1;">Pendiente de revisión de auditoría</div>
                                <div style="font-size:11px;color:#0284c7;">👉 Ir a Gastos para comprobar</div>
                            </div>
                            <i class="ph ph-arrow-right" style="color:#0891b2;font-size:16px;flex-shrink:0;"></i>
                        </div>`
                }));
            }
        } catch(e) { console.error('Gastos notif:', e); }

        // ── Render final ───────────────────────────────────────────────────
                // ─── F. Permisos Laborales Pendientes de Revisión (Para Administración) ───
        try {
            if (resPermisosPend && resPermisosPend.status === 'fulfilled' && resPermisosPend.value.ok) {
                const pendientesPermisos = await resPermisosPend.value.json();
                if (Array.isArray(pendientesPermisos) && pendientesPermisos.length > 0) {
                    gruposHtml.push(buildDropdownCard({
                        icon: 'ph-clipboard-text',
                        color: '#6366f1', bg: '#f5f3ff', border: '#818cf8',
                        titulo: '📋 Solicitudes de Permisos Laborales Pendientes',
                        badge: `${pendientesPermisos.length} pendiente${pendientesPermisos.length !== 1 ? 's' : ''}`,
                        badgeColor: '#6366f1',
                        items: pendientesPermisos,
                        renderItem: (p) => `
                            <div style="display:flex; align-items:center; justify-content:space-between; gap:12px; padding:12px; border-bottom:1px solid #e0e7ff; background:white; border-radius:8px; margin-bottom:8px; box-shadow:0 1px 3px rgba(0,0,0,0.05); flex-wrap:wrap;">
                                <div style="display:flex; align-items:center; gap:12px; flex:1; min-width:240px;">
                                    <img src="${p.empleado_foto || 'vendor/img/avatar_default.png'}" 
                                         onerror="this.src='vendor/img/avatar_default.png'" 
                                         style="width:42px; height:42px; border-radius:50%; object-fit:cover; border:2px solid #c7d2fe; flex-shrink:0;">
                                    <div>
                                        <div style="font-size:13.5px; font-weight:700; color:#1e1b4b;">
                                            ${p.empleado_nombre || 'Colaborador'} 
                                            <span style="font-size:11px; font-weight:700; color:#4338ca; background:#e0e7ff; padding:2px 8px; border-radius:10px; margin-left:4px;">${p.folio_permiso}</span>
                                        </div>
                                        <div style="font-size:12px; color:#475569; margin-top:2px;">
                                            <b>${p.tipo_permiso}</b> • Del <b>${p.fecha_inicio}</b> al <b>${p.fecha_fin}</b> (${p.dias_solicitados} día${p.dias_solicitados !== 1 ? 's' : ''})
                                        </div>
                                        <div style="font-size:11.5px; color:#6b7280; font-style:italic; margin-top:2px;">
                                            "${p.justificacion || 'Sin motivo especificado'}"
                                        </div>
                                    </div>
                                </div>
                                <div style="display:flex; align-items:center; gap:8px;">
                                    <button onclick="abrirDictamenPermisoDesdeNotif('${p.id_empleado}', ${p.id_permiso})" 
                                            style="background:#6366f1; color:white; border:none; padding:8px 14px; border-radius:6px; cursor:pointer; font-weight:700; font-size:12px; display:inline-flex; align-items:center; gap:6px; box-shadow:0 2px 4px rgba(99,102,241,0.25); transition:all .15s;"
                                            onmouseover="this.style.background='#4f46e5'" onmouseout="this.style.background='#6366f1'">
                                        <i class="ph ph-magnifying-glass" style="font-size:15px;"></i> Revisar Solicitud en RH
                                    </button>
                                </div>
                            </div>`
                    }));
                }
            }
        } catch(e) { console.error('Error al renderizar permisos pendientes:', e); }

const gruposFiltrados = gruposHtml.filter(Boolean);
        if (gruposFiltrados.length > 0) {
            contenedorNotif.innerHTML = gruposFiltrados.join('');
        } else {
            contenedorNotif.innerHTML = `
                <div style="display:flex;align-items:center;gap:12px;padding:14px 18px;background:#f0fdf4;border-left:4px solid #34d399;border-radius:10px;">
                    <i class="ph ph-check-circle" style="font-size:24px;color:#059669;"></i>
                    <span style="font-size:14px;color:#065f46;font-weight:600;">✅ Todo al día — Sin notificaciones pendientes.</span>
                </div>`;
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
                empleado: usuarioLogueado.nombre_completo || usuarioLogueado.nombre || ''
            })
        });

        const registros = resAsist.ok ? await resAsist.json() : [];
        const diasEspanol = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];
        const hoyIso = formatearFechaLocal(new Date());

        const nombreUpper = String(usuarioLogueado.nombre_completo || usuarioLogueado.nombre || '').toUpperCase();
        const esVillarreal = nombreUpper.includes("VILLARREAL");
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
                                <b>Atención ${usuarioLogueado.nombre_completo || usuarioLogueado.nombre || ''}:</b> Se ha detectado una práctica incorrecta en tus registros de asistencia al registrar únicamente entrada matutina y salida vespertina omitiendo el registro de comida. El horario corrido continuo no está autorizado. Favor de pasar a Recursos Humanos para regularizar tu estatus.
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

    // 3. Cargar Equipos Dañados en el Dashboard
    const dropdownDanos = document.getElementById("dropdown-mis-danos");
    const contenedorDanosInicio = document.getElementById("inicio-equipos-danados");
    const esSeguimiento201202 = ['201', '202'].includes(String(usuarioLogueado?.id_empleado || '').trim());

    if (contenedorDanosInicio) {
        if (!esSeguimiento201202) {
            // Para empleados que NO son 201 ni 202: solo deben reportar
            contenedorDanosInicio.innerHTML = `
                <div style="display: flex; justify-content: space-between; align-items: center; background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 10px; padding: 14px 18px; margin-top: 20px; flex-wrap: wrap; gap: 10px;">
                    <div>
                        <h4 style="margin: 0; color: #0f172a; font-size: 14.5px; display: flex; align-items: center; gap: 8px;">
                            <i class="ph ph-wrench" style="color: #ef4444;"></i> ¿Detectaste un equipo con falla o daño?
                        </h4>
                        <p style="margin: 3px 0 0 0; color: #64748b; font-size: 12.5px;">
                            Genera un ticket directo para que el área de Mantenimiento y Taller le dé seguimiento.
                        </p>
                    </div>
                    <button type="button" onclick="cambiarVista('vista-danados'); setTimeout(() => { if(typeof alternarFormularioReporteDirecto === 'function') alternarFormularioReporteDirecto(); }, 300);" 
                            style="background: #2563eb; color: white; border: none; padding: 9px 18px; border-radius: 6px; font-weight: 700; font-size: 13px; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 5px rgba(37,99,235,0.25);">
                        <i class="ph ph-plus-circle" style="font-size: 16px;"></i> Levantar Reporte de Falla
                    </button>
                </div>
            `;
        } else {
            // Para 201 y 202: seguimiento general
            if (dropdownDanos) {
                try {
                    const resDanos = await fetch(`${API_URL}/api/inventario/radar-danos`);
                    if (resDanos.ok) {
                        const danos = await resDanos.json();
                        if (danos && danos.length > 0) {
                            dropdownDanos.innerHTML = `<option value="">-- Seguimiento de Equipos en Taller (${danos.length} activos) --</option>` + 
                                danos.map(d => `<option value="${d.NUM_SERVICIO}" data-equipo="${d.ID}">Ticket #${d.NUM_SERVICIO}: ${d.ID} - ${d.EQUIPO || 'Sin nombre'} [Reportó: ${d['REPORTÓ'] || 'Personal'}] (${d.ESTADO})</option>`).join("");
                                
                            dropdownDanos.onchange = function() {
                                const selectedOption = dropdownDanos.options[dropdownDanos.selectedIndex];
                                if (selectedOption && selectedOption.value) {
                                    const codigoEquipo = selectedOption.getAttribute("data-equipo");
                                    const numServ = selectedOption.value;
                                    irASeguimientoTaller(codigoEquipo, numServ);
                                    dropdownDanos.value = "";
                                }
                            };
                        } else {
                            dropdownDanos.innerHTML = `<option value="">✅ No hay equipos con daño o en taller actualmente.</option>`;
                        }
                    }
                } catch (e) {
                    console.error("Error al cargar radar de daños en inicio:", e);
                }
            }
        }
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

// ── HELPERS DE PUNTUALIDAD Y ESTATUS DEL KIOSCO ───────────────────────
function calcularEstatusEntradaKiosco(horaStr, turno) {
    if (!horaStr || horaStr === "--:--:--" || horaStr === "--:--") return "";
    try {
        const parts = horaStr.split(':').map(Number);
        const h = parts[0] || 0;
        const m = parts[1] || 0;
        const s = parts[2] || 0;
        const horaSecs = h * 3600 + m * 60 + s;
        
        const baseH = (turno === "Matutino") ? 9 : 16;
        const baseSecs = baseH * 3600;
        const limiteSecs = baseSecs + (5 * 60) + 59; // 5 minutos y 59 segundos de tolerancia
        
        if (horaSecs > limiteSecs) {
            const retraso = horaSecs - baseSecs;
            const mins = Math.floor(retraso / 60);
            const secs = retraso % 60;
            return `<span style="background: #fee2e2; color: #991b1b; padding: 3px 8px; border-radius: 6px; font-weight: 700; font-size: 11px; border: 1px solid #fecaca; white-space: nowrap; display: inline-block;">🔴 TARDE (${mins}m ${secs}s)</span>`;
        } else {
            return `<span style="background: #dcfce7; color: #166534; padding: 3px 8px; border-radius: 6px; font-weight: 700; font-size: 11px; border: 1px solid #bbf7d0; white-space: nowrap; display: inline-block;">🟢 A TIEMPO</span>`;
        }
    } catch(e) {
        return `<span style="background: #dcfce7; color: #166534; padding: 3px 8px; border-radius: 6px; font-weight: 700; font-size: 11px; border: 1px solid #bbf7d0;">🟢 A TIEMPO</span>`;
    }
}

function calcularEstatusSalidaVespKiosco(horaStr, observaciones = "", estatus = "") {
    if (!horaStr || horaStr === "--:--:--" || horaStr === "--:--") return "";
    const obs = `${observaciones || ""} ${estatus || ""}`.toUpperCase();
    if (obs.includes("OMISI")) {
        return `<span style="background: #fee2e2; color: #b91c1c; padding: 3px 8px; border-radius: 6px; font-weight: 700; font-size: 11px; border: 1px solid #fca5a5; white-space: nowrap; display: inline-block;">🚨 OMISIÓN COMIDA</span>`;
    }
    try {
        const parts = horaStr.split(':').map(Number);
        const h = parts[0] || 0;
        const m = parts[1] || 0;
        if ((h === 19 && m >= 50) || h >= 20) {
            return `<span style="background: #fef3c7; color: #92400e; padding: 3px 8px; border-radius: 6px; font-weight: 700; font-size: 11px; border: 1px solid #fde68a; white-space: nowrap; display: inline-block;">🌙 Revisar T. Extra</span>`;
        }
        return `<span style="background: #f1f5f9; color: #334155; padding: 3px 8px; border-radius: 6px; font-weight: 600; font-size: 11px; border: 1px solid #cbd5e1; white-space: nowrap; display: inline-block;">🏠 Descansa</span>`;
    } catch(e) {
        return `<span style="background: #f1f5f9; color: #334155; padding: 3px 8px; border-radius: 6px; font-weight: 600; font-size: 11px;">🏠 Descansa</span>`;
    }
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
        const esHoraValida = (h) => (h && h !== "None" && h !== "null" && h !== "--:--" && h !== "--:--:--" && String(h).trim() !== "");
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
                    <td colspan="8" style="text-align: center; padding: 36px 20px; color: var(--text-muted); font-size: 13.5px;">
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
                        <td style="font-weight: 600; color: var(--text-main); text-align: left;">${emp.nombre}</td>
                        <td colspan="7" style="text-align: center; font-weight: 700; font-size: 12px; padding: 6px; ${bgStyle} border-radius: 6px;">
                            ${badgeTxt}
                        </td>
                    </tr>
                `;
                return;
            }

            const limpiaHora = (h) => esHoraValida(h) ? String(h).substring(0, 8) : "--:--:--";
            const inMat = limpiaHora(reg.hora_entrada);
            const outMat = limpiaHora(reg.hora_salida);
            const inVesp = limpiaHora(reg.hora_entrada_v);
            const outVesp = limpiaHora(reg.hora_salida_v);

            const estInMat = inMat !== "--:--:--" ? calcularEstatusEntradaKiosco(inMat, "Matutino") : `<span style="color: #94a3b8; font-size: 11px;">--</span>`;
            const estInVesp = inVesp !== "--:--:--" ? calcularEstatusEntradaKiosco(inVesp, "Vespertino") : `<span style="color: #94a3b8; font-size: 11px;">--</span>`;
            const estOutVesp = outVesp !== "--:--:--" ? calcularEstatusSalidaVespKiosco(outVesp, reg.observaciones, reg.estatus) : `<span style="color: #94a3b8; font-size: 11px;">--</span>`;

            const stError = "color: #9f1239; background: #ffe4e6; font-weight: bold;";
            const tdOutMat = (outMat === "--:--:--" && inMat !== "--:--:--") ? `<td style="${stError}">--:--:--</td>` : `<td>${outMat}</td>`;

            tbody.innerHTML += `
                <tr ${estiloFila}>
                    <td style="font-weight: 600; color: var(--text-main); text-align: left;">${emp.nombre}</td>
                    <td><b>${inMat}</b></td>
                    <td>${estInMat}</td>
                    ${tdOutMat}
                    <td><b>${inVesp}</b></td>
                    <td>${estInVesp}</td>
                    <td><b>${outVesp}</b></td>
                    <td>${estOutVesp}</td>
                </tr>
            `;

            // Si es la persona recién registrada, actualizar detalles en la tarjeta izquierda
            if (esReciente) {
                const detTurno = document.getElementById("scan-detalles-turno");
                const scanMatIn = document.getElementById("scan-mat-in");
                const scanMatOut = document.getElementById("scan-mat-out");
                const scanVespIn = document.getElementById("scan-vesp-in");
                const scanVespOut = document.getElementById("scan-vesp-out");
                if (detTurno && scanMatIn && scanMatOut && scanVespIn && scanVespOut) {
                    scanMatIn.innerText = inMat;
                    scanMatOut.innerText = outMat;
                    scanVespIn.innerText = inVesp;
                    scanVespOut.innerText = outVesp;
                    detTurno.style.display = "block";
                }
            }
        });
    } catch (error) {
        tbody.innerHTML = `<tr><td colspan="8" style="text-align: center; color: #ef4444; padding: 16px;">Error cargando la matriz del kiosco.</td></tr>`;
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
    // Protección estricta: Auditoría de Asistencia solo permitida para Villarreal o Agundez
    if (tab === 'auditoria') {
        const autorizado = (typeof esUsuarioAutorizadoDireccion === 'function') ? esUsuarioAutorizadoDireccion() : false;
        if (!autorizado) {
            tab = 'kiosco';
        }
    }

    if (typeof actualizarVisibilidadPestanasChecador === 'function') {
        actualizarVisibilidadPestanasChecador();
    }

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


// ══════════════════════════════════════════════════════════════════════
// HELPERS CENTRO DE NOTIFICACIONES
// ══════════════════════════════════════════════════════════════════════

/**
 * Abre/cierra el dropdown de una tarjeta de notificación.
 * Rota el icono caret al abrir.
 */
function toggleNotifDropdown(uid) {
    const panel = document.getElementById(uid);
    const caret = document.getElementById(uid + '-caret');
    if (!panel) return;
    const open = panel.style.display === 'none' || panel.style.display === '';
    panel.style.display = open ? 'block' : 'none';
    if (caret) caret.style.transform = open ? 'rotate(180deg)' : 'rotate(0deg)';
}

/**
 * Navega a la vista de RH y activa la pestaña indicada.
 * pestana: 'expediente' | 'vacaciones' | 'contratos' | 'permisos' | 'capacitacion' | 'documentos'
 */
function activarPestanaRH(pestana) {
    // Mapeo de nombre a valor que usa cambiarPestanaRH() en index.html
    const tabMap = {
        'expediente':     'documentos',
        'vacaciones':     'vacaciones',
        'contratos':      'contratos',
        'permisos':       'permisos',
        'capacitacion':   'capacitacion',
        'documentos':     'documentos'
    };
    const tabVal = tabMap[pestana] || pestana;
    if (typeof cambiarPestanaRH === 'function') {
        cambiarPestanaRH(tabVal);
    }
}

// ─── Helper de Enlace Directo: Notificación -> Dictamen de Permiso en RH ────
async function abrirDictamenPermisoDesdeNotif(idEmpleado, idPermiso) {
    try {
        if (typeof cambiarVista === 'function') {
            cambiarVista('vista-rh');
        }
        if (typeof seleccionarEmpleadoRH === 'function') {
            await seleccionarEmpleadoRH(idEmpleado);
        }
        if (typeof cambiarPestanaRH === 'function') {
            cambiarPestanaRH('permisos');
        }
        setTimeout(() => {
            if (typeof abrirModalDictamenPermiso === 'function') {
                abrirModalDictamenPermiso(idPermiso);
            }
        }, 350);
    } catch (e) {
        console.error('Error al abrir dictamen desde notificación:', e);
    }
}

// ==============================================================================
// REDIRECCIÓN A SEGUIMIENTO DE TALLER (EMPLEADOS 201 Y 202)
// ==============================================================================
function irASeguimientoTaller(idEquipo, numServicio) {
    cambiarVista('vista-danados');
    setTimeout(() => {
        if (typeof abrirExpedienteEquipoModal === 'function') {
            abrirExpedienteEquipoModal(idEquipo, idEquipo, numServicio);
        }
    }, 350);
}
