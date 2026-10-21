// ==============================================================================
// MÓDULO: auth.js
// 2. Autenticación, login, logout, monitor ejecutivo
// Líneas originales: 16–463 de script.js
// ==============================================================================

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

function alternarVisibilidadPassword(iconEl, inputId) {
    const input = document.getElementById(inputId);
    if (!input || !iconEl) return;
    if (input.type === 'password') {
        input.type = 'text';
        iconEl.classList.remove('ph-eye');
        iconEl.classList.add('ph-eye-slash');
    } else {
        input.type = 'password';
        iconEl.classList.remove('ph-eye-slash');
        iconEl.classList.add('ph-eye');
    }
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
    
    // Registrar acceso en log
    try {
        fetch(`${API_URL}/api/auth/registrar-acceso`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                id_empleado: usuario.id_empleado,
                nombre: usuario.nombre_completo || usuario.nombre,
                tipo_evento: "LOGIN_PLATAFORMA",
                ip_origen: "WEB_PORTAL"
            })
        }).catch(() => {});
    } catch(e) {}

    filtrarMenuPorRol(usuario.rol);
    actualizarMonitorAccesosCEO();
    const elFotoInicio = document.getElementById("inicio-foto-empleado");
    if (elFotoInicio) {
        const idEmp = String(usuario.id_empleado || '000').trim();
        elFotoInicio.src = usuario.foto_url || `${API_URL}/fotos/${idEmp}.jpg`;
    }
    iniciarRelojKiosco();
    inicializarLectorKiosco(); 
    cargarBadges();
    cambiarVista('vista-inicio'); 
}

function cerrarSesion() {
    document.getElementById("sidebar").style.display = "none";
    document.getElementById("vista-dashboard").style.display = "none";
    document.getElementById("vista-login").style.display = "block";
    const btnAgenda = document.getElementById("contenedor-boton-agenda-drive");
    if (btnAgenda) btnAgenda.style.display = "none";
    const contCEO = document.getElementById("contenedor-monitor-accesos-ceo");
    if (contCEO) contCEO.style.display = "none";
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
    actualizarVisibilidadAgendaDrive();
}

function actualizarVisibilidadAgendaDrive() {
    const btnAgenda = document.getElementById("contenedor-boton-agenda-drive");
    if (!btnAgenda) return;

    if (!usuarioLogueado) {
        btnAgenda.style.display = "none";
        return;
    }

    const rol = (usuarioLogueado.rol || '').toUpperCase().trim();
    const nombre = (usuarioLogueado.nombre || usuarioLogueado.nombre_completo || '').toUpperCase().trim();

    // FILTRO AUTORIZADO: Solo Villarreal, Agundez, Coordinador y Productores
    const esVillarreal = nombre.includes('VILLARREAL') || nombre.includes('VILLAREAL') || nombre.includes('VILARREAL');
    const esAgundez = nombre.includes('AGUNDEZ') || nombre.includes('AGÚNDEZ');
    const esCoordinador = rol === 'COORDINADOR' || rol.includes('COORDINADOR') || rol.includes('COORDINACION');
    // Productor: por rol 'PRODUCTOR' o nombre asignado como Productor (Manuel Antonio Madrid Zazueta / Madrid)
    const esProductor = rol === 'PRODUCTOR' || nombre.includes('MADRID');

    if (esVillarreal || esAgundez || esCoordinador || esProductor) {
        btnAgenda.style.display = "flex";
    } else {
        btnAgenda.style.display = "none";
    }
}

// ==========================================
// 👑 MONITOR EJECUTIVO DE ACCESOS (CEO & CUAUHTEMOC)
// ==========================================
function actualizarMonitorAccesosCEO() {
    const contenedor = document.getElementById("contenedor-monitor-accesos-ceo");
    if (!contenedor) return;

    if (!usuarioLogueado) {
        contenedor.style.display = "none";
        return;
    }

    const idEmp = String(usuarioLogueado.id_empleado || '').trim();
    const nombre = String(usuarioLogueado.nombre_completo || usuarioLogueado.nombre || '').toUpperCase()
        .normalize("NFD").replace(/[\u0300-\u036f]/g, "");

    const esPedro = (nombre.includes("PEDRO") && nombre.includes("VILLARREAL")) || idEmp === "203";
    const esCuauhtemoc = (nombre.includes("CUAUHTEMOC") && nombre.includes("RIVERA")) || idEmp === "201";

    if (esPedro || esCuauhtemoc) {
        contenedor.style.display = "block";
        cargarSelectorPersonalCEO();
    } else {
        contenedor.style.display = "none";
    }
}

async function cargarSelectorPersonalCEO() {
    const dropdown = document.getElementById("dropdown-personal-ceo");
    if (!dropdown) return;
    
    // Si ya tiene las opciones del personal cargadas, no recargar innecesariamente
    if (dropdown.options.length > 1) return;

    try {
        const res = await fetch(`${API_URL}/api/auth/personal-selector`);
        if (res.ok) {
            const personal = await res.json();
            dropdown.innerHTML = '<option value="">-- Selecciona un colaborador --</option>';
            personal.forEach(p => {
                const opt = document.createElement("option");
                opt.value = p.id_empleado;
                opt.textContent = `${p.nombre} - ${p.depto} (ID: ${p.id_empleado})`;
                dropdown.appendChild(opt);
            });
        }
    } catch (e) {
        console.error("Error al cargar selector de personal CEO:", e);
    }
}

async function consultarAccesosPersonalCEO(idEmpleado) {
    const contResultado = document.getElementById("resultado-accesos-ceo");
    if (!contResultado) return;

    if (!idEmpleado) {
        contResultado.style.display = "none";
        contResultado.innerHTML = "";
        return;
    }

    contResultado.style.display = "block";
    contResultado.innerHTML = `
        <div style="padding: 16px; text-align: center; color: #64748b; font-size: 14px;">
            <i class="ph ph-spinner" style="font-size: 22px;"></i> Consultando bitácora de accesos de los últimos 7 días...
        </div>
    `;

    try {
        const res = await fetch(`${API_URL}/api/auth/accesos-recientes/${idEmpleado}?dias=7`);
        if (!res.ok) {
            contResultado.innerHTML = `<div class="alerta-card alert">Error al consultar accesos del servidor.</div>`;
            return;
        }

        const data = await res.json();
        const total = data.total_accesos || 0;
        const totalERP = data.total_sesiones_erp || 0;
        const totalAsis = data.total_checadas_asistencia || 0;
        const diasActivos = data.dias_con_acceso || 0;
        const historial = data.historial || [];
        const nombre = data.nombre || `ID: ${idEmpleado}`;
        const depto = data.depto || 'GENERAL';
        const puesto = data.puesto || 'Personal';

        const colorBorde = total > 0 ? '#10b981' : '#ef4444';
        const colorFondo = total > 0 ? '#f0fdf4' : '#fef2f2';
        const colorTexto = total > 0 ? '#166534' : '#991b1b';

        let html = `
            <div style="background: ${colorFondo}; border-left: 5px solid ${colorBorde}; border-radius: 10px; padding: 16px 20px; margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
                <div>
                    <span style="font-size: 11.5px; text-transform: uppercase; font-weight: 700; color: ${colorTexto}; letter-spacing: 0.5px;">Resultado de los últimos 7 días</span>
                    <h4 style="margin: 3px 0 4px 0; color: #0f172a; font-size: 18px;">${nombre}</h4>
                    <p style="margin: 0; font-size: 13px; color: #475569;">
                        Departamento: <b>${depto}</b> | Puesto: <b>${puesto}</b>
                    </p>
                </div>
                <div style="text-align: right; background: white; padding: 10px 18px; border-radius: 8px; border: 1px solid rgba(0,0,0,0.08); box-shadow: 0 2px 4px rgba(0,0,0,0.04);">
                    <div style="font-size: 11px; text-transform: uppercase; font-weight: 700; color: #64748b;">Total de Accesos</div>
                    <div style="font-size: 26px; font-weight: 800; color: ${colorTexto}; line-height: 1.1;">${total} veces</div>
                    <span style="font-size: 12px; color: #64748b;">en los últimos 7 días</span>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin-bottom: 16px;">
                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; text-align: center;">
                    <span style="font-size: 12px; color: #64748b; font-weight: 600;">📊 Total Accesos</span>
                    <div style="font-size: 20px; font-weight: 700; color: #0f172a; margin-top: 4px;">${total} veces</div>
                </div>
                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; text-align: center;">
                    <span style="font-size: 12px; color: #64748b; font-weight: 600;">📅 Días con Actividad</span>
                    <div style="font-size: 20px; font-weight: 700; color: #0f172a; margin-top: 4px;">${diasActivos} de 7 días</div>
                </div>
                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; text-align: center;">
                    <span style="font-size: 12px; color: #64748b; font-weight: 600;">🖥️ Inicios de Sesión (ERP)</span>
                    <div style="font-size: 20px; font-weight: 700; color: #2563eb; margin-top: 4px;">${totalERP}</div>
                </div>
                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; text-align: center;">
                    <span style="font-size: 12px; color: #64748b; font-weight: 600;">🕒 Checador / Asistencia</span>
                    <div style="font-size: 20px; font-weight: 700; color: #059669; margin-top: 4px;">${totalAsis}</div>
                </div>
            </div>
        `;

        if (historial.length > 0) {
            html += `
                <details style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px 16px;">
                    <summary style="font-size: 13.5px; font-weight: 600; color: #1e293b; cursor: pointer;">
                        📋 Ver Bitácora Detallada de Registros (${historial.length} eventos en los últimos 7 días)
                    </summary>
                    <div style="overflow-x: auto; margin-top: 12px;">
                        <table class="tabla-vpro" style="width: 100%; font-size: 13px;">
                            <thead>
                                <tr style="background: #f1f5f9;">
                                    <th style="padding: 8px;">Fecha</th>
                                    <th style="padding: 8px;">Hora</th>
                                    <th style="padding: 8px;">Tipo de Acceso</th>
                                    <th style="padding: 8px;">Detalle</th>
                                </tr>
                            </thead>
                            <tbody>
            `;
            historial.forEach(h => {
                html += `
                    <tr>
                        <td style="padding: 8px; font-weight: 600;">${h.fecha}</td>
                        <td style="padding: 8px;">${h.hora}</td>
                        <td style="padding: 8px;">${h.tipo}</td>
                        <td style="padding: 8px; color: #475569;">${h.detalle}</td>
                    </tr>
                `;
            });
            html += `
                            </tbody>
                        </table>
                    </div>
                </details>
            `;
        } else {
            html += `
                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 14px; text-align: center; color: #64748b; font-size: 13px;">
                    ℹ️ No se encontraron registros de accesos a la plataforma ni al checador en los últimos 7 días para este colaborador.
                </div>
            `;
        }

        contResultado.innerHTML = html;
    } catch (err) {
        console.error("Error al consultar accesos:", err);
        contResultado.innerHTML = `<div class="alerta-card alert">Error de conexión al obtener los datos.</div>`;
    }
}

