// ==============================================================================
// MÓDULO: rh.js
// 17. Recursos Humanos (nómina, vacaciones, expediente, contratos, permisos, capacitaciones)
// Líneas originales: 11103–13320 de script.js
// ==============================================================================

// ==========================================
// 17. MÓDULO RECURSOS HUMANOS
// ==========================================
let listaEmpleadosRHCache = [];
let idEmpleadoRHActual = null;

function cambiarPestanaRH(tab) {
    const tabs = ['datos', 'contratos', 'vacaciones', 'permisos', 'capacitacion', 'documentos'];
    tabs.forEach(t => {
        const btn = document.getElementById(`tab-rh-btn-${t}`);
        const view = document.getElementById(`subvista-rh-${t}`);
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
}

async function cargarModuloRH() {
    try {
        const esVillarreal = typeof esUsuarioVillarreal === 'function' ? esUsuarioVillarreal() : false;
        const miIdEmpleado = usuarioLogueado?.id_empleado ? String(usuarioLogueado.id_empleado) : null;
        const miNombre = (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || 'Colaborador');

        // Configurar la interfaz: Solo los Villarreal pueden auditar y buscar a todos los empleados
        const contBusqueda = document.getElementById("contenedor-busqueda-rh-empleado");
        const txtLabel = document.getElementById("texto-label-selector-rh");
        const subTxt = document.getElementById("subtexto-selector-rh");
        const gridSelector = document.getElementById("grid-selector-rh");
        const btnExp = document.getElementById("btn-ver-expediente-completo-rh");

        if (esVillarreal) {
            if (contBusqueda) contBusqueda.style.display = "block";
            if (txtLabel) txtLabel.textContent = "SELECCIONA O BUSCA EL EMPLEADO A AUDITAR / EDITAR EXPEDIENTE:";
            if (subTxt) {
                subTxt.textContent = "Teclea nombre, ID, departamento o puesto para filtrar rápidamente";
                subTxt.style.display = "inline";
            }
            if (gridSelector) gridSelector.style.gridTemplateColumns = "1.1fr 1fr";
            if (btnExp) {
                btnExp.innerHTML = `<i class="ph ph-folder-notch-open" style="font-size: 20px;"></i><span>📂 Ver Expediente Digital Integral (Todo lo que tenga integrado)</span>`;
            }
        } else {
            // Cada empleado no Villarreal solo ve su propia información
            if (contBusqueda) contBusqueda.style.display = "none";
            if (txtLabel) txtLabel.innerHTML = `<i class="ph ph-user"></i> Mi Expediente Digital Personal: <span style="color: #0284c7; margin-left: 4px;">${miNombre} (ID: ${miIdEmpleado || '--'})</span>`;
            if (subTxt) {
                subTxt.textContent = "Acceso privado y confidencial a tu expediente laboral, contratos y vacaciones";
                subTxt.style.display = "inline";
            }
            if (gridSelector) gridSelector.style.gridTemplateColumns = "1fr";
            if (btnExp) {
                btnExp.innerHTML = `<i class="ph ph-folder-notch-open" style="font-size: 20px;"></i><span>📂 Ver Mi Expediente Integral Completo</span>`;
            }
        }

        // Cargar alertas y lista de empleados (con filtro estricto por empleado si no es Villarreal)
        const urlAlertas = esVillarreal
            ? `${API_URL}/api/rh/alertas`
            : (miIdEmpleado ? `${API_URL}/api/rh/alertas?id_empleado=${encodeURIComponent(miIdEmpleado)}` : `${API_URL}/api/rh/alertas`);

        const urlEmps = esVillarreal
            ? `${API_URL}/api/rh/empleados`
            : (miIdEmpleado ? `${API_URL}/api/rh/empleados?id_empleado=${encodeURIComponent(miIdEmpleado)}` : `${API_URL}/api/rh/empleados`);

        const [resEmps, resAlertas] = await Promise.all([
            fetch(urlEmps),
            fetch(urlAlertas)
        ]);

        if (resAlertas.ok) {
            const alertas = await resAlertas.json();
            const banner = document.getElementById("banner-rh-alertas");
            if (banner) {
                if (alertas && alertas.length > 0) {
                    banner.style.display = "block";
                    const tituloAlertas = esVillarreal
                        ? `Alertas Activas de Recursos Humanos (${alertas.length})`
                        : `Mis Avisos y Alertas Laborales (${alertas.length})`;
                    banner.innerHTML = `
                        <div style="background: #fef2f2; border: 1px solid #fecaca; border-radius: 10px; padding: 14px 18px; color: #991b1b; font-size: 13px;">
                            <b style="display: flex; align-items: center; gap: 6px; font-size: 14px; margin-bottom: 6px;">
                                <i class="ph ph-warning-circle"></i> ${tituloAlertas}
                            </b>
                            <ul style="margin: 0; padding-left: 20px;">
                                ${alertas.map(a => `<li>${a.mensaje || a.descripcion || 'Alerta laboral'}</li>`).join("")}
                            </ul>
                        </div>
                    `;
                } else {
                    banner.style.display = "none";
                }
            }
        }

        if (resEmps.ok) {
            let rawEmps = await resEmps.json();
            if (!esVillarreal && miIdEmpleado) {
                rawEmps = rawEmps.filter(e => String(e.id_empleado) === String(miIdEmpleado));
            }
            listaEmpleadosRHCache = rawEmps;

            const selEmp = document.getElementById("sel-rh-empleado");
            if (selEmp) {
                selEmp.innerHTML = '<option value="">--- O selecciona de la lista completa ---</option>' +
                    listaEmpleadosRHCache.map(e => `<option value="${e.id_empleado}">${e.id_empleado} - ${e.nombre} (${e.depto || 'General'})</option>`).join("");
            }

            if (esVillarreal) {
                // Si el usuario actual está en la lista o hay colaboradores, autoseleccionar
                if (!idEmpleadoRHActual && listaEmpleadosRHCache.length > 0) {
                    const idDefault = usuarioLogueado?.id_empleado || listaEmpleadosRHCache[0].id_empleado;
                    if (selEmp) selEmp.value = idDefault;
                    elegirEmpleadoRHSugerencia(idDefault);
                }
            } else {
                // Si no es Villarreal, autoseleccionar exclusivamente al usuario logueado
                const targetId = miIdEmpleado || (listaEmpleadosRHCache[0]?.id_empleado);
                if (targetId) {
                    idEmpleadoRHActual = targetId;
                    if (selEmp) selEmp.value = targetId;
                    seleccionarEmpleadoRH(targetId);
                }
            }
        }
    } catch (err) {
        console.error("Error al cargar módulo RH:", err);
    }
}

// --- BÚSQUEDA INTELIGENTE DE EMPLEADO (RRHH) ---
let indiceSugerenciaRHEmpleadoActivo = -1;

function filtrarEmpleadosRHSugerencias(termino) {
    const esVillarreal = typeof esUsuarioVillarreal === 'function' ? esUsuarioVillarreal() : false;
    if (!esVillarreal) {
        const dropdown = document.getElementById("sugerencias-rh-empleados-dropdown");
        if (dropdown) dropdown.style.display = "none";
        return;
    }
    const dropdown = document.getElementById("sugerencias-rh-empleados-dropdown");
    const btnLimpiar = document.getElementById("btn-limpiar-busqueda-rh");
    if (!dropdown) return;

    if (btnLimpiar) {
        btnLimpiar.style.display = (termino && termino.trim()) ? "block" : "none";
    }

    const t = normalizarTextoBusqueda(termino);
    let coincidencias = [];
    if (!t) {
        coincidencias = listaEmpleadosRHCache.slice(0, 15);
    } else {
        const palabras = t.split(" ").filter(Boolean);
        coincidencias = listaEmpleadosRHCache.filter(e => {
            const norm = normalizarTextoBusqueda(`${e.id_empleado} ${e.nombre} ${e.depto || ''} ${e.puesto || ''}`);
            return palabras.every(pal => norm.includes(pal));
        }).slice(0, 30);
    }

    if (coincidencias.length === 0) {
        dropdown.innerHTML = `<div style="padding: 14px; text-align: center; color: #64748b; font-size: 13px;">No se encontró ningún colaborador con ese criterio.</div>`;
        dropdown.style.display = "block";
        indiceSugerenciaRHEmpleadoActivo = -1;
        return;
    }

    indiceSugerenciaRHEmpleadoActivo = -1;
    dropdown.innerHTML = coincidencias.map((e, idx) => `
        <div class="sugerencia-rh-item" data-index="${idx}" data-id="${e.id_empleado}"
             onclick="elegirEmpleadoRHSugerencia('${e.id_empleado}')"
             onmouseenter="resaltarSugerenciaRHEmpleado(${idx})"
             style="padding: 10px 14px; border-bottom: 1px solid #f1f5f9; cursor: pointer; display: flex; align-items: center; justify-content: space-between; transition: background 0.15s;">
            <div>
                <div style="font-weight: 700; color: #0f172a; font-size: 13px;">
                    <span style="background: #e2e8f0; color: #334155; padding: 2px 6px; border-radius: 4px; font-size: 11px; margin-right: 6px; font-family: monospace;">${e.id_empleado}</span>
                    ${resaltarTexto(e.nombre, termino)}
                </div>
                <div style="font-size: 11.5px; color: #64748b; margin-top: 2px;">
                    <b>Depto:</b> ${e.depto || 'General'} | <b>Puesto:</b> ${e.puesto || 'Colaborador'}
                </div>
            </div>
            <span style="font-size: 11.5px; color: #0284c7; font-weight: 600;">Auditar Expediente &rarr;</span>
        </div>
    `).join("");

    dropdown.style.display = "block";
}

function activarEmpleadosRHSugerencias() {
    const esVillarreal = typeof esUsuarioVillarreal === 'function' ? esUsuarioVillarreal() : false;
    if (!esVillarreal) return;
    const input = document.getElementById("input-buscar-rh-empleado");
    filtrarEmpleadosRHSugerencias(input ? input.value : "");
}

function resaltarSugerenciaRHEmpleado(idx) {
    indiceSugerenciaRHEmpleadoActivo = idx;
    const items = document.querySelectorAll(".sugerencia-rh-item");
    items.forEach((it, i) => {
        it.style.background = (i === idx) ? "#eff6ff" : "white";
    });
}

function manejarKeydownEmpleadosRH(event) {
    const dropdown = document.getElementById("sugerencias-rh-empleados-dropdown");
    if (!dropdown || dropdown.style.display === "none") return;

    const items = dropdown.querySelectorAll(".sugerencia-rh-item");
    if (!items || items.length === 0) return;

    if (event.key === "ArrowDown") {
        event.preventDefault();
        indiceSugerenciaRHEmpleadoActivo = (indiceSugerenciaRHEmpleadoActivo + 1) % items.length;
        resaltarSugerenciaRHEmpleado(indiceSugerenciaRHEmpleadoActivo);
        items[indiceSugerenciaRHEmpleadoActivo]?.scrollIntoView({ block: "nearest" });
    } else if (event.key === "ArrowUp") {
        event.preventDefault();
        indiceSugerenciaRHEmpleadoActivo = (indiceSugerenciaRHEmpleadoActivo - 1 + items.length) % items.length;
        resaltarSugerenciaRHEmpleado(indiceSugerenciaRHEmpleadoActivo);
        items[indiceSugerenciaRHEmpleadoActivo]?.scrollIntoView({ block: "nearest" });
    } else if (event.key === "Enter") {
        event.preventDefault();
        if (indiceSugerenciaRHEmpleadoActivo >= 0 && items[indiceSugerenciaRHEmpleadoActivo]) {
            const id = items[indiceSugerenciaRHEmpleadoActivo].getAttribute("data-id");
            if (id) elegirEmpleadoRHSugerencia(id);
        }
    } else if (event.key === "Escape") {
        dropdown.style.display = "none";
    }
}

function elegirEmpleadoRHSugerencia(idEmpleado) {
    const esVillarreal = typeof esUsuarioVillarreal === 'function' ? esUsuarioVillarreal() : false;
    const miId = usuarioLogueado?.id_empleado ? String(usuarioLogueado.id_empleado) : null;
    if (!esVillarreal && miId) {
        idEmpleado = miId;
    }
    const dropdown = document.getElementById("sugerencias-rh-empleados-dropdown");
    if (dropdown) dropdown.style.display = "none";

    const emp = listaEmpleadosRHCache.find(e => String(e.id_empleado) === String(idEmpleado));
    const input = document.getElementById("input-buscar-rh-empleado");
    const selEmp = document.getElementById("sel-rh-empleado");
    const btnLimpiar = document.getElementById("btn-limpiar-busqueda-rh");

    if (emp) {
        if (input) input.value = `${emp.id_empleado} - ${emp.nombre} (${emp.depto || 'General'})`;
        if (btnLimpiar) btnLimpiar.style.display = "block";
    }
    if (selEmp) selEmp.value = idEmpleado;

    seleccionarEmpleadoRH(idEmpleado);
}

function seleccionarEmpleadoRHOpcion(idEmpleado) {
    if (!idEmpleado) {
        limpiarBusquedaRHEmpleado();
        return;
    }
    elegirEmpleadoRHSugerencia(idEmpleado);
}

function limpiarBusquedaRHEmpleado() {
    const input = document.getElementById("input-buscar-rh-empleado");
    const btnLimpiar = document.getElementById("btn-limpiar-busqueda-rh");
    const dropdown = document.getElementById("sugerencias-rh-empleados-dropdown");
    const selEmp = document.getElementById("sel-rh-empleado");

    if (input) {
        input.value = "";
        input.focus();
    }
    if (btnLimpiar) btnLimpiar.style.display = "none";
    if (selEmp) selEmp.value = "";
    if (dropdown) dropdown.style.display = "none";

    activarEmpleadosRHSugerencias();
}

document.addEventListener("click", function(e) {
    const cont = document.getElementById("contenedor-busqueda-rh-empleado");
    const dropdown = document.getElementById("sugerencias-rh-empleados-dropdown");
    if (dropdown && cont && !cont.contains(e.target)) {
        dropdown.style.display = "none";
    }
});

async function seleccionarEmpleadoRH(idEmpleado) {
    const esVillarreal = typeof esUsuarioVillarreal === 'function' ? esUsuarioVillarreal() : false;
    const miId = usuarioLogueado?.id_empleado ? String(usuarioLogueado.id_empleado) : null;
    if (!esVillarreal && miId) {
        idEmpleado = miId;
    }

    if (!idEmpleado) {
        const cont = document.getElementById("rh-expediente-container");
        if (cont) cont.style.display = "none";
        idEmpleadoRHActual = null;
        return;
    }
    idEmpleadoRHActual = idEmpleado;

    try {
        const [resExp, resContratos, resVac, resPerm, resIncap, resCap, resEval, resDoc] = await Promise.all([
            fetch(`${API_URL}/api/rh/empleados/${idEmpleado}`),
            fetch(`${API_URL}/api/rh/contratos/${idEmpleado}`),
            fetch(`${API_URL}/api/rh/vacaciones/${idEmpleado}`),
            fetch(`${API_URL}/api/rh/permisos?id_empleado=${idEmpleado}`),
            fetch(`${API_URL}/api/rh/incapacidades/${idEmpleado}`),
            fetch(`${API_URL}/api/rh/capacitacion/${idEmpleado}`),
            fetch(`${API_URL}/api/rh/evaluaciones/${idEmpleado}`),
            fetch(`${API_URL}/api/rh/documentos/${idEmpleado}`)
        ]);

        const emp = resExp.ok ? await resExp.json() : {};

        // Sincronizar input de búsqueda y select si difieren
        const inputBuscarEmp = document.getElementById("input-buscar-rh-empleado");
        const btnLimpiar = document.getElementById("btn-limpiar-busqueda-rh");
        const selEmp = document.getElementById("sel-rh-empleado");
        if (emp && emp.nombre) {
            if (inputBuscarEmp && (!inputBuscarEmp.value || !inputBuscarEmp.value.includes(String(emp.id_empleado)))) {
                inputBuscarEmp.value = `${emp.id_empleado} - ${emp.nombre} (${emp.depto || 'General'})`;
            }
            if (btnLimpiar) btnLimpiar.style.display = "block";
            if (selEmp && selEmp.value !== idEmpleado) selEmp.value = idEmpleado;
        }

        // 1. Ficha Resumen
        const elNom = document.getElementById("rh-ficha-nombre");
        const elId = document.getElementById("rh-ficha-id");
        const elDep = document.getElementById("rh-ficha-depto");
        const elPuesto = document.getElementById("rh-ficha-puesto");
        const elEdad = document.getElementById("rh-ficha-edad");
        const elAnt = document.getElementById("rh-ficha-antiguedad");
        const elEst = document.getElementById("rh-ficha-estatus");
        const elFoto = document.getElementById("rh-ficha-foto");

        if (elNom) elNom.innerText = emp.nombre || '--';
        if (elId) elId.innerText = emp.id_empleado || idEmpleado;
        if (elDep) elDep.innerText = emp.depto || '--';
        if (elPuesto) elPuesto.innerText = emp.puesto || '--';
        if (elEdad) elEdad.innerText = emp.edad ? `${emp.edad} AÑOS` : '--';
        if (elAnt) elAnt.innerText = emp.anios_trabajados !== undefined ? `${emp.anios_trabajados} AÑOS` : '--';
        if (elEst) elEst.innerText = (emp.estatus_empleado || 'ACTIVO').toUpperCase();
        if (elFoto) elFoto.src = emp.foto_url || `${API_URL}/fotos/${idEmpleado}.jpg`;

        // 2. Datos Generales Formulario
        const setVal = (id, val) => {
            const el = document.getElementById(id);
            if (el) el.value = (val !== null && val !== undefined && val !== "None") ? val : "";
        };

        setVal("rh-gen-nombre", emp.nombre);
        setVal("rh-gen-email", emp.email);
        setVal("rh-gen-cel", emp.cel);
        setVal("rh-gen-rfc", emp.rfc);
        setVal("rh-gen-curp", emp.curp);
        setVal("rh-gen-nss", emp.nss);
        setVal("rh-gen-depto", emp.depto);
        setVal("rh-gen-puesto", emp.puesto);
        setVal("rh-gen-tipo-contrato", emp.tipo_contrato || "PLANTA");
        setVal("rh-gen-salario", emp.salario_mensual);
        setVal("rh-gen-escolaridad", emp.escolaridad || "LICENCIATURA");
        setVal("rh-gen-estado-civil", emp.estado_civil || "SOLTERO");
        setVal("rh-gen-domicilio", emp.domicilio);
        setVal("rh-gen-ciudad", emp.ciudad);
        setVal("rh-gen-cp", emp.cp);
        setVal("rh-gen-contacto-emergencia", emp.contacto_emergencia);
        setVal("rh-gen-tel-emergencia", emp.tel_emergencia);
        setVal("rh-gen-parentesco", emp.parentesco_emergencia);
        setVal("rh-gen-estatus-empleado", emp.estatus_empleado || "ACTIVO");
        setVal("rh-gen-fecha-baja", emp.fecha_baja ? String(emp.fecha_baja).substring(0, 10) : "");
        setVal("rh-gen-motivo-baja", emp.motivo_baja);

        // 3. Contratos
        if (resContratos.ok) {
            const contratos = await resContratos.json();
            const tbContratos = document.getElementById("tabla-rh-contratos-body");
            if (tbContratos) {
                if (contratos.length === 0) {
                    tbContratos.innerHTML = `<tr><td colspan="8" style="text-align: center; padding: 20px; color: var(--text-muted);">Sin historial de contratos registrados.</td></tr>`;
                } else {
                    tbContratos.innerHTML = contratos.map(c => {
                        const tieneDoc = !!c.archivo_contrato_url;
                        const docBtn = tieneDoc
                            ? `<button type="button" onclick="abrirVisorDocumentoGeneral('${c.archivo_contrato_url.replace(/'/g, "\\'")}', 'Contrato_${c.folio_contrato || c.id_contrato}')"
                                      style="background: #0284c7; color: white; border: none; padding: 5px 10px; border-radius: 5px; font-size: 11.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                                   <i class="ph ph-file-pdf"></i> Ver Contrato
                               </button>`
                            : `<button type="button" onclick="irASubirDocumentoRH('Contrato Laboral Firmado')"
                                      title="Digitalizar y subir contrato a Documentos Digitales"
                                      style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 4px 8px; border-radius: 5px; font-size: 11px; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                                   <i class="ph ph-plus-circle"></i> Digitalizar
                               </button>`;

                        return `
                        <tr>
                            <td><b>${c.folio_contrato || '--'}</b></td>
                            <td>${c.tipo_contrato || '--'}</td>
                            <td>${c.fecha_inicio || '--'}</td>
                            <td>${c.fecha_fin || 'Indefinido'}</td>
                            <td>${c.puesto_contratado || '--'}</td>
                            <td>$${Number(c.salario_mensual || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</td>
                            <td><span style="background: #dcfce7; color: #166534; font-weight: 700; font-size: 11px; padding: 2px 8px; border-radius: 4px;">${c.estatus_contrato || 'VIGENTE'}</span></td>
                            <td style="text-align: center;">${docBtn}</td>
                        </tr>
                    `;
                    }).join("");
                }
            }
        }

        // 4. Vacaciones
        if (resVac.ok) {
            const dataVac = await resVac.json();
            const resumen = dataVac.resumen || {};
            const periodos = dataVac.historial || [];

            if (document.getElementById("rh-vac-correspondientes")) {
                document.getElementById("rh-vac-correspondientes").innerText = resumen.dias_totales_correspondientes || resumen.dias_totales_acumulados || 0;
            }
            if (document.getElementById("rh-vac-tomados")) {
                document.getElementById("rh-vac-tomados").innerText = resumen.dias_tomados || 0;
            }
            if (document.getElementById("rh-vac-pendientes")) {
                document.getElementById("rh-vac-pendientes").innerText = resumen.dias_pendientes || 0;
            }

            const tbVac = document.getElementById("tabla-rh-vacaciones-body");
            if (tbVac) {
                if (periodos.length === 0) {
                    tbVac.innerHTML = `<tr><td colspan="7" style="text-align: center; padding: 20px; color: var(--text-muted);">Sin periodos vacacionales registrados en este historial.</td></tr>`;
                } else {
                    tbVac.innerHTML = periodos.map(v => {
                        const modalidad = v.tipo || 'DÍAS SUELTOS / FRACCIONADOS';
                        const obs = v.observaciones || `Año ${v.anio_periodo}`;
                        return `
                        <tr>
                            <td><b>${obs}</b></td>
                            <td><span style="background: #eff6ff; color: #1e40af; font-size: 11px; padding: 2px 8px; border-radius: 4px; font-weight: 600;">${modalidad}</span></td>
                            <td><b style="color: #b45309;">${v.dias_tomados || 0} día(s)</b></td>
                            <td>${v.fecha_inicio_goce || '--'}</td>
                            <td>${v.fecha_fin_goce || '--'}</td>
                            <td><span style="background: #dcfce7; color: #166534; font-weight: 700; font-size: 11px; padding: 2px 8px; border-radius: 4px;">${v.estatus || 'APROBADO'}</span></td>
                            <td style="text-align: center;">
                                <button type="button" onclick="imprimirPapeletaVacacionesRH(${v.id_vacacion}, '${(emp.nombre || '').replace(/'/g, "\\'")}', '${v.fecha_inicio_goce}', '${v.fecha_fin_goce}', ${v.dias_tomados}, '${(v.observaciones || '').replace(/'/g, "\\'")}')"
                                    title="Imprimir Papeleta de Conformidad LFT (Art. 78)"
                                    style="background: #f1f5f9; color: #0369a1; border: 1px solid #bae6fd; padding: 4px 10px; border-radius: 5px; font-size: 11px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                                    <i class="ph ph-printer"></i> 📄 Papeleta LFT
                                </button>
                            </td>
                        </tr>
                    `;
                    }).join("");
                }
            }
        }

        // 5. Permisos & Incapacidades
        const permisos = resPerm.ok ? await resPerm.json() : [];
        const incapacidades = resIncap.ok ? await resIncap.json() : [];
        const tbPerm = document.getElementById("tabla-rh-permisos-body");
        if (tbPerm) {
            const combined = [
                ...permisos.map(p => ({ ...p, _tipo_reg: 'PERMISO', _archivo: p.archivo_justificante })),
                ...incapacidades.map(i => ({ ...i, _tipo_reg: 'INCAPACIDAD IMSS', _archivo: i.archivo_incapacidad_url }))
            ];
            if (combined.length === 0) {
                tbPerm.innerHTML = `<tr><td colspan="8" style="text-align: center; padding: 20px; color: var(--text-muted);">Sin permisos o incapacidades registradas.</td></tr>`;
            } else {
                tbPerm.innerHTML = combined.map(item => {
                    const tieneArch = !!item._archivo;
                    const folio = item.folio_permiso || item.folio_incapacidad || 'Doc';
                    const docBtn = tieneArch
                        ? `<button type="button" onclick="abrirVisorDocumentoGeneral('${item._archivo.replace(/'/g, "\\'")}', 'Comprobante_${folio}')"
                                  style="background: #0284c7; color: white; border: none; padding: 5px 10px; border-radius: 5px; font-size: 11.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                               <i class="ph ph-file-text"></i> Ver Archivo
                           </button>`
                        : `<button type="button" onclick="irASubirDocumentoRH('${item._tipo_reg.includes('INCAPACIDAD') ? 'Certificado Médico' : 'Otro Documento Laboral'}')"
                                  title="Subir comprobante o justificante médico al expediente"
                                  style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 4px 8px; border-radius: 5px; font-size: 11px; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                               <i class="ph ph-plus-circle"></i> Adjuntar
                           </button>`;

                    return `
                        <tr>
                            <td><b>${folio}</b></td>
                            <td><span style="background: #eff6ff; color: #1e40af; font-size: 11px; padding: 2px 8px; border-radius: 4px; font-weight: 600;">${item._tipo_reg}</span></td>
                            <td>${item.fecha_inicio || item.fecha_solicitud || '--'}</td>
                            <td>${item.fecha_fin || '--'}</td>
                            <td>${item.dias_solicitados || item.dias_incapacidad || 1} días</td>
                            <td>${item.con_goce_de_sueldo ? 'Sí' : 'No'}</td>
                            <td><span style="font-weight: 700;">${item.estatus || 'REGISTRADO'}</span></td>
                            <td style="text-align: center;">${docBtn}</td>
                        </tr>
                    `;
                }).join("");
            }
        }

        // 6. Capacitaciones & Evaluaciones
        const cursos = resCap.ok ? await resCap.json() : [];
        const evalua = resEval.ok ? await resEval.json() : [];
        const tbEval = document.getElementById("tabla-rh-evaluaciones-body");
        if (tbEval) {
            const unificados = [
                ...evalua.map(ev => ({ titulo: ev.periodo || 'Evaluación', tipo: 'EVALUACIÓN DESEMPEÑO', actor: ev.evaluador || '--', cal: ev.calificacion_final, nivel: ev.nivel_desempeno, urlDoc: ev.archivo_evaluacion_url })),
                ...cursos.map(c => ({ titulo: c.nombre_curso, tipo: 'CAPACITACIÓN TÉCNICA', actor: c.institucion || '--', cal: c.calificacion, nivel: c.resultado || 'APROBADO', urlDoc: c.constancia_url }))
            ];
            if (unificados.length === 0) {
                tbEval.innerHTML = `<tr><td colspan="6" style="text-align: center; padding: 20px; color: var(--text-muted);">Sin evaluaciones o capacitaciones registradas.</td></tr>`;
            } else {
                tbEval.innerHTML = unificados.map(u => {
                    const tieneDoc = !!u.urlDoc;
                    const docBtn = tieneDoc
                        ? `<button type="button" onclick="abrirVisorDocumentoGeneral('${u.urlDoc.replace(/'/g, "\\'")}', '${u.titulo}')"
                                  style="background: #0284c7; color: white; border: none; padding: 5px 10px; border-radius: 5px; font-size: 11.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                               <i class="ph ph-certificate"></i> Ver Archivo
                           </button>`
                        : `<button type="button" onclick="irASubirDocumentoRH('${u.tipo.includes('CAPACITACIÓN') ? 'Comprobante de Estudios' : 'Otro Documento Laboral'}')"
                                  title="Subir constancia DC-3 o formato de evaluación al expediente"
                                  style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 4px 8px; border-radius: 5px; font-size: 11px; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                               <i class="ph ph-plus-circle"></i> Adjuntar
                           </button>`;

                    return `
                        <tr>
                            <td><b>${u.titulo}</b></td>
                            <td>${u.tipo}</td>
                            <td>${u.actor}</td>
                            <td style="font-weight: 700;">${u.cal !== null && u.cal !== undefined ? u.cal : '--'}</td>
                            <td><span style="background: #dcfce7; color: #166534; font-weight: 700; padding: 2px 8px; border-radius: 4px; font-size: 11px;">${u.nivel || 'APROBADO'}</span></td>
                            <td style="text-align: center;">${docBtn}</td>
                        </tr>
                    `;
                }).join("");
            }
        }

        // 7. Documentos
        if (resDoc.ok) {
            const docs = await resDoc.json();
            listaDocumentosRHActual = docs || [];
            filtrarDocumentosRHCategoria('TODOS');
        }

        const cont = document.getElementById("rh-expediente-container");
        if (cont) cont.style.display = "block";
    } catch (e) {
        console.error("Error al cargar expediente:", e);
        alert(`❌ Error al consultar expediente de empleado: ${e.message}`);
    }
}

async function guardarDatosGeneralesRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ No hay un colaborador seleccionado.");
        return;
    }

    const getVal = (id) => document.getElementById(id)?.value?.trim() || "";

    const payload = {
        nombre: getVal("rh-gen-nombre"),
        email: getVal("rh-gen-email"),
        cel: getVal("rh-gen-cel"),
        rfc: getVal("rh-gen-rfc"),
        curp: getVal("rh-gen-curp"),
        nss: getVal("rh-gen-nss"),
        depto: getVal("rh-gen-depto"),
        puesto: getVal("rh-gen-puesto"),
        tipo_contrato: getVal("rh-gen-tipo-contrato"),
        salario_mensual: parseFloat(getVal("rh-gen-salario") || 0),
        escolaridad: getVal("rh-gen-escolaridad"),
        estado_civil: getVal("rh-gen-estado-civil"),
        domicilio: getVal("rh-gen-domicilio"),
        ciudad: getVal("rh-gen-ciudad"),
        cp: getVal("rh-gen-cp"),
        contacto_emergencia: getVal("rh-gen-contacto-emergencia"),
        tel_emergencia: getVal("rh-gen-tel-emergencia"),
        parentesco_emergencia: getVal("rh-gen-parentesco"),
        estatus_empleado: getVal("rh-gen-estatus-empleado"),
        fecha_baja: getVal("rh-gen-fecha-baja") || null,
        motivo_baja: getVal("rh-gen-motivo-baja") || null,
        registrado_por: usuarioLogueado?.nombre_completo || "RH"
    };

    try {
        const res = await fetch(`${API_URL}/api/rh/empleados/${idEmpleadoRHActual}`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (res.ok) {
            alert("✅ ¡Expediente actualizado exitosamente en base de datos!");
            seleccionarEmpleadoRH(idEmpleadoRHActual);
        } else {
            const err = await res.text();
            alert(`❌ Error al actualizar expediente: ${err}`);
        }
    } catch (e) {
        alert(`❌ Error de comunicación: ${e.message}`);
    }
}

// ==============================================================================
// GESTIÓN DE VACACIONES (LFT ART. 76, 78 Y 81 - REFORMA VACACIONES DIGNAS)
// ==============================================================================
function toggleFormularioVacacionesRH() {
    const f = document.getElementById("form-registrar-vacaciones-rh");
    if (!f) return;
    f.style.display = (f.style.display === "none" || f.style.display === "") ? "block" : "none";
    if (f.style.display === "block") {
        const hoy = new Date().toISOString().split("T")[0];
        const inInicio = document.getElementById("rh-vac-inicio");
        const inFin = document.getElementById("rh-vac-fin");
        if (inInicio && !inInicio.value) inInicio.value = hoy;
        if (inFin && !inFin.value) inFin.value = hoy;
        alCambiarFechasVacacionesRH();
        inInicio?.focus();
    }
}

function alCambiarFechasVacacionesRH() {
    const fInicio = document.getElementById("rh-vac-inicio")?.value;
    const fFin = document.getElementById("rh-vac-fin")?.value;
    const inDias = document.getElementById("rh-vac-dias");

    if (fInicio && fFin && inDias) {
        const d1 = new Date(fInicio);
        const d2 = new Date(fFin);
        if (d2 >= d1) {
            const diffTime = Math.abs(d2 - d1);
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
            inDias.value = diffDays;
        } else {
            inDias.value = 1;
        }
    }
}

async function guardarSalidaVacacionesRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor selecciona primero a un colaborador.");
        return;
    }

    const tipo = document.getElementById("rh-vac-tipo")?.value || "DÍAS SUELTOS / FRACCIONADOS";
    const inicio = document.getElementById("rh-vac-inicio")?.value;
    const fin = document.getElementById("rh-vac-fin")?.value;
    const dias = parseInt(document.getElementById("rh-vac-dias")?.value || "1");
    const motivo = document.getElementById("rh-vac-motivo")?.value?.trim() || "Disfrute fraccionado a solicitud del colaborador";
    const btn = document.getElementById("btn-guardar-vac-rh");

    if (!inicio || !fin) {
        alert("⚠️ Por favor especifica la fecha de inicio y fin del periodo o día a tomar.");
        return;
    }

    if (dias <= 0) {
        alert("⚠️ El número de días debe ser mayor a 0.");
        return;
    }

    const pendientes = parseInt(document.getElementById("rh-vac-pendientes")?.innerText || "0");
    if (dias > pendientes) {
        if (!confirm(`⚠️ El colaborador tiene ${pendientes} día(s) pendientes y estás registrando ${dias} día(s). ¿Deseas continuar y registrarlo como anticipo/permiso con goce?`)) {
            return;
        }
    }

    if (btn) {
        btn.disabled = true;
        btn.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Guardando...`;
    }

    const payload = {
        id_empleado: idEmpleadoRHActual,
        anio_periodo: new Date().getFullYear(),
        dias_tomados: dias,
        fecha_inicio_goce: inicio,
        fecha_fin_goce: fin,
        tipo: tipo,
        observaciones: motivo,
        registrado_por: (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "RECURSOS HUMANOS")
    };

    try {
        const res = await fetch(`${API_URL}/api/rh/vacaciones`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (res.ok) {
            alert(`✅ ¡Se registraron exitosamente ${dias} día(s) de vacaciones! Se descontaron automáticamente de la bolsa acumulada conforme al Art. 78 de la LFT.`);
            toggleFormularioVacacionesRH();
            seleccionarEmpleadoRH(idEmpleadoRHActual);
        } else {
            const err = await res.text();
            alert(`❌ Error al registrar vacaciones: ${err}`);
        }
    } catch (e) {
        alert(`❌ Error de comunicación: ${e.message}`);
    } finally {
        if (btn) {
            btn.disabled = false;
            btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar y Descontar de Saldo`;
        }
    }
}

function imprimirPapeletaVacacionesRH(idVac, nombreEmp, fInicio, fFin, dias, observaciones) {
    const win = window.open("", "_blank");
    if (!win) {
        alert("⚠️ Por favor permite las ventanas emergentes en tu navegador para ver la papeleta de vacaciones.");
        return;
    }

    const hoyStr = new Date().toLocaleDateString("es-MX", { year: "numeric", month: "long", day: "numeric" });

    win.document.write(`
        <!DOCTYPE html>
        <html lang="es">
        <head>
            <meta charset="UTF-8">
            <title>Papeleta de Vacaciones LFT - ${nombreEmp}</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; margin: 40px; color: #0f172a; line-height: 1.6; }
                .card { border: 2px solid #0f172a; border-radius: 10px; padding: 30px; max-width: 750px; margin: 0 auto; }
                .header { text-align: center; border-bottom: 2px solid #e2e8f0; padding-bottom: 16px; margin-bottom: 24px; }
                .header h2 { margin: 0 0 6px 0; color: #0f172a; text-transform: uppercase; font-size: 20px; letter-spacing: 0.5px; }
                .header p { margin: 0; font-size: 13px; color: #64748b; }
                .legal-box { background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 6px; padding: 12px; font-size: 11.5px; color: #475569; margin-bottom: 20px; text-align: justify; }
                .table-data { width: 100%; border-collapse: collapse; margin-bottom: 24px; }
                .table-data td { padding: 8px 12px; border: 1px solid #cbd5e1; font-size: 13px; }
                .table-data td.lbl { background: #f1f5f9; font-weight: 700; width: 35%; color: #334155; }
                .firmas { display: flex; justify-content: space-between; margin-top: 60px; padding: 0 40px; }
                .firma-box { text-align: center; width: 40%; border-top: 1px solid #0f172a; padding-top: 8px; font-size: 12.5px; font-weight: 600; }
                .btn-print { background: #0284c7; color: white; border: none; padding: 10px 20px; border-radius: 6px; font-weight: 700; cursor: pointer; margin-bottom: 20px; display: inline-flex; align-items: center; gap: 6px; }
                @media print { .btn-print { display: none; } body { margin: 0; } .card { border: none; padding: 0; } }
            </style>
        </head>
        <body>
            <div style="text-align: center;">
                <button class="btn-print" onclick="window.print()">🖨️ Imprimir Papeleta Oficial LFT</button>
            </div>
            <div class="card">
                <div class="header">
                    <h2>VPRO STREAMING SERVICES S.A. DE C.V.</h2>
                    <p>SOLICITUD Y CONSTANCIA DE DISFRUTE DE VACACIONES (ART. 78 LFT)</p>
                </div>

                <div class="legal-box">
                    <b>FUNDAMENTO LEGAL (REFORMA VACACIONES DIGNAS):</b> De conformidad con lo dispuesto en el Artículo 78 de la Ley Federal del Trabajo reformada, la persona trabajadora manifiesta su potestad y solicitud expresa para que el periodo de vacaciones sea distribuido y fraccionado en la forma y fechas aquí señaladas, en mutuo acuerdo y sin menoscabo de sus derechos laborales.
                </div>

                <table class="table-data">
                    <tr>
                        <td class="lbl">Colaborador / Trabajador:</td>
                        <td><b>${nombreEmp}</b></td>
                    </tr>
                    <tr>
                        <td class="lbl">Fecha de Expedición:</td>
                        <td>${hoyStr}</td>
                    </tr>
                    <tr>
                        <td class="lbl">Días a Gozar / Descontar:</td>
                        <td><b>${dias} día(s)</b> hábiles</td>
                    </tr>
                    <tr>
                        <td class="lbl">Periodo de Goce:</td>
                        <td>Desde: <b>${fInicio}</b> | Hasta: <b>${fFin}</b></td>
                    </tr>
                    <tr>
                        <td class="lbl">Motivo / Observaciones:</td>
                        <td>${observaciones || 'Disfrute fraccionado acordado conforme a la LFT'}</td>
                    </tr>
                    <tr>
                        <td class="lbl">Estatus de Autorización:</td>
                        <td><b>AUTORIZADO Y CONCEDIDO</b></td>
                    </tr>
                </table>

                <div class="firmas">
                    <div class="firma-box">
                        ${nombreEmp}<br>
                        <span style="font-size: 11px; font-weight: normal; color: #64748b;">Firma del Colaborador (De Conformidad)</span>
                    </div>
                    <div class="firma-box">
                        RECURSOS HUMANOS / DIRECCIÓN<br>
                        <span style="font-size: 11px; font-weight: normal; color: #64748b;">Autorizado por VPRO</span>
                    </div>
                </div>
            </div>
        </body>
        </html>
    `);
    win.document.close();
}

// ==============================================================================
// GESTIÓN DE EXPEDIENTE DIGITAL Y DOCUMENTOS OFICIALES (RECURSOS HUMANOS)
// ==============================================================================
let cacheDocumentosRH = {};
let listaDocumentosRHActual = [];
let categoriaFiltroDocRHActual = 'TODOS';

function toggleFormularioSubirDocumentoRH() {
    const f = document.getElementById("form-subir-documento-rh");
    if (!f) return;
    f.style.display = (f.style.display === "none" || f.style.display === "") ? "block" : "none";
    if (f.style.display === "block") {
        document.getElementById("rh-doc-archivo")?.focus();
    }
}

function irASubirDocumentoRH(tipoSugerido) {
    cambiarPestanaRH('documentos');
    const f = document.getElementById("form-subir-documento-rh");
    if (f) f.style.display = "block";
    const selTipo = document.getElementById("rh-doc-tipo");
    if (selTipo && tipoSugerido) {
        for (let i = 0; i < selTipo.options.length; i++) {
            const opt = selTipo.options[i];
            if (opt.value.toLowerCase().includes(tipoSugerido.toLowerCase()) || tipoSugerido.toLowerCase().includes(opt.value.toLowerCase())) {
                selTipo.selectedIndex = i;
                break;
            }
        }
    }
    document.getElementById("rh-doc-archivo")?.focus();
}

function filtrarDocumentosRHCategoria(categoria) {
    categoriaFiltroDocRHActual = categoria;

    // Actualizar estilo visual de los botones de filtro
    const categorias = ['TODOS', 'IDENTIDAD', 'LABORAL', 'SALUD', 'ACADEMICO'];
    const idMap = {
        'TODOS': 'btn-filtro-doc-todos',
        'IDENTIDAD': 'btn-filtro-doc-identidad',
        'LABORAL': 'btn-filtro-doc-laboral',
        'SALUD': 'btn-filtro-doc-salud',
        'ACADEMICO': 'btn-filtro-doc-academico'
    };

    categorias.forEach(cat => {
        const btn = document.getElementById(idMap[cat]);
        if (btn) {
            if (cat === categoria) {
                btn.style.background = '#0f172a';
                btn.style.color = 'white';
                btn.style.border = 'none';
            } else {
                btn.style.background = '#f1f5f9';
                btn.style.color = '#475569';
                btn.style.border = '1px solid #cbd5e1';
            }
        }
    });

    if (!listaDocumentosRHActual || listaDocumentosRHActual.length === 0) {
        renderizarDocumentosRHTabla([]);
        return;
    }

    if (categoria === 'TODOS') {
        renderizarDocumentosRHTabla(listaDocumentosRHActual);
        return;
    }

    const docsFiltrados = listaDocumentosRHActual.filter(d => {
        const tipo = (d.tipo_documento || '').toUpperCase();
        if (categoria === 'IDENTIDAD') {
            return tipo.includes('INE') || tipo.includes('IDENTIFICACIÓN') || tipo.includes('RFC') || tipo.includes('FISCAL') || tipo.includes('CURP') || tipo.includes('NSS') || tipo.includes('IMSS') || tipo.includes('DOMICILIO') || tipo.includes('LICENCIA') || tipo.includes('ACTA');
        } else if (categoria === 'LABORAL') {
            return tipo.includes('CONTRATO') || tipo.includes('LABORAL') || tipo.includes('RECOMENDACIÓN') || tipo.includes('PENALES');
        } else if (categoria === 'SALUD') {
            return tipo.includes('MÉDICO') || tipo.includes('MEDICO') || tipo.includes('SALUD') || tipo.includes('INCAPACIDAD');
        } else if (categoria === 'ACADEMICO') {
            return tipo.includes('ESTUDIOS') || tipo.includes('TÍTULO') || tipo.includes('TITULO') || tipo.includes('CÉDULA') || tipo.includes('CEDULA') || tipo.includes('CERTIFICADO') || tipo.includes('CURSO') || tipo.includes('CAPACITACIÓN');
        }
        return true;
    });

    renderizarDocumentosRHTabla(docsFiltrados);
}

function renderizarDocumentosRHTabla(docs) {
    const tbDoc = document.getElementById("tabla-rh-documentos-body");
    if (!tbDoc) return;

    cacheDocumentosRH = {};

    if (!docs || docs.length === 0) {
        tbDoc.innerHTML = `<tr><td colspan="7" style="text-align: center; padding: 24px; color: var(--text-muted); font-size: 13px;">📁 Sin documentos digitales en esta categoría para el expediente.</td></tr>`;
        return;
    }

    tbDoc.innerHTML = docs.map(d => {
        cacheDocumentosRH[d.id_documento] = {
            url: d.archivo_url || "",
            nombre: d.nombre_archivo || `documento_${d.id_documento}`
        };

        const tipo = (d.tipo_documento || "Otro Documento").trim();
        let badgeStyle = "background: #f1f5f9; color: #334155;";
        let badgeIcon = "ph-file-text";

        if (tipo.includes("INE") || tipo.includes("Identificación")) {
            badgeStyle = "background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe;";
            badgeIcon = "ph-identification-card";
        } else if (tipo.includes("RFC") || tipo.includes("Fiscal")) {
            badgeStyle = "background: #f5f3ff; color: #6d28d9; border: 1px solid #ddd6fe;";
            badgeIcon = "ph-receipt";
        } else if (tipo.includes("CURP")) {
            badgeStyle = "background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0;";
            badgeIcon = "ph-fingerprint";
        } else if (tipo.includes("NSS") || tipo.includes("IMSS")) {
            badgeStyle = "background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca;";
            badgeIcon = "ph-first-aid-kit";
        } else if (tipo.includes("Domicilio")) {
            badgeStyle = "background: #f0fdf4; color: #15803d; border: 1px solid #bbf7d0;";
            badgeIcon = "ph-house";
        } else if (tipo.includes("Licencia")) {
            badgeStyle = "background: #fffbeb; color: #b45309; border: 1px solid #fde68a;";
            badgeIcon = "ph-car";
        } else if (tipo.includes("Contrato")) {
            badgeStyle = "background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd;";
            badgeIcon = "ph-scroll";
        } else if (tipo.includes("Estudios") || tipo.includes("Título") || tipo.includes("Cédula")) {
            badgeStyle = "background: #fdf4ff; color: #a21caf; border: 1px solid #f5d0fe;";
            badgeIcon = "ph-graduation-cap";
        } else if (tipo.includes("Médico") || tipo.includes("Salud")) {
            badgeStyle = "background: #f0fdfa; color: #0f766e; border: 1px solid #99f6e4;";
            badgeIcon = "ph-heartbeat";
        }

        // Vigencia semáforo
        let vigenciaBadge = '<span style="background: #f1f5f9; color: #475569; padding: 3px 8px; border-radius: 4px; font-size: 11.5px;">🟢 Vigente</span>';
        if (d.fecha_vencimiento) {
            const hoy = new Date();
            const fVenc = new Date(d.fecha_vencimiento);
            const diffDias = Math.ceil((fVenc - hoy) / (1000 * 60 * 60 * 24));

            if (diffDias < 0) {
                vigenciaBadge = `<span style="background: #fee2e2; color: #991b1b; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 11.5px;">🔴 Vencido (${d.fecha_vencimiento})</span>`;
            } else if (diffDias <= 30) {
                vigenciaBadge = `<span style="background: #fef3c7; color: #92400e; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 11.5px;">🟡 Vence en ${diffDias} d (${d.fecha_vencimiento})</span>`;
            } else {
                vigenciaBadge = `<span style="background: #dcfce7; color: #166534; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 11.5px;">🟢 Vigente (${d.fecha_vencimiento})</span>`;
            }
        }

        // Estatus RH
        const verificadoBadge = d.verificado_por_rh
            ? `<span style="background: #dcfce7; color: #166534; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 11.5px; display: inline-flex; align-items: center; gap: 4px;"><i class="ph ph-check-circle-fill"></i> Verificado</span>`
            : `<span style="background: #fef3c7; color: #92400e; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 11.5px; display: inline-flex; align-items: center; gap: 4px;"><i class="ph ph-clock"></i> En Revisión</span>`;

        // Formato archivo
        const formato = (d.formato || (d.nombre_archivo ? d.nombre_archivo.split('.').pop() : 'DOC')).toUpperCase();
        let formatoColor = '#64748b';
        if (formato === 'PDF') formatoColor = '#dc2626';
        else if (['PNG', 'JPG', 'JPEG'].includes(formato)) formatoColor = '#0284c7';

        return `
            <tr>
                <td>
                    <span style="display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; ${badgeStyle}">
                        <i class="ph ${badgeIcon}"></i> ${tipo}
                    </span>
                </td>
                <td>
                    <div style="display: flex; align-items: center; gap: 6px;">
                        <span style="background: #f1f5f9; color: ${formatoColor}; font-weight: 800; font-size: 10px; padding: 2px 5px; border-radius: 3px; font-family: monospace;">.${formato}</span>
                        <span style="font-weight: 600; color: #0f172a; max-width: 220px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${d.nombre_archivo || '--'}">
                            ${d.nombre_archivo || '--'}
                        </span>
                    </div>
                </td>
                <td style="font-size: 12.5px;">${d.fecha_emision ? d.fecha_emision : (d.fecha_subida ? String(d.fecha_subida).substring(0, 10) : '--')}</td>
                <td>${vigenciaBadge}</td>
                <td>${verificadoBadge}</td>
                <td style="font-size: 12px; max-width: 180px; color: #64748b; line-height: 1.3;">${d.observaciones || '<span style="color:#cbd5e1;">Sin notas</span>'}</td>
                <td style="text-align: center;">
                    <div style="display: flex; gap: 6px; justify-content: center; align-items: center;">
                        <button type="button" onclick="verDocumentoRH(${d.id_documento})" title="Ver o Descargar Archivo" 
                                style="background: #0284c7; color: white; border: none; padding: 5px 10px; border-radius: 5px; font-size: 11.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                            <i class="ph ph-eye"></i> Ver
                        </button>
                        ${!d.verificado_por_rh ? `
                        <button type="button" onclick="verificarDocumentoRH(${d.id_documento})" title="Certificar como Verificado por RH" 
                                style="background: #16a34a; color: white; border: none; padding: 5px 8px; border-radius: 5px; font-size: 11.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 3px;">
                            <i class="ph ph-check"></i>
                        </button>` : ''}
                        <button type="button" onclick="eliminarDocumentoRH(${d.id_documento}, '${(d.tipo_documento || 'documento').replace(/'/g, "\\'")}')" title="Eliminar del Expediente" 
                                style="background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; padding: 5px 8px; border-radius: 5px; font-size: 11.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center;">
                            <i class="ph ph-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `;
    }).join("");
}

async function subirDocumentoRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor selecciona primero un colaborador en el selector superior de Recursos Humanos.");
        return;
    }

    const tipoDoc = document.getElementById("rh-doc-tipo")?.value;
    const fileInput = document.getElementById("rh-doc-archivo");
    const fechaEmision = document.getElementById("rh-doc-emision")?.value || null;
    const fechaVencimiento = document.getElementById("rh-doc-vencimiento")?.value || null;
    const notas = document.getElementById("rh-doc-notas")?.value?.trim() || "";
    const btnGuardar = document.getElementById("btn-guardar-doc-rh");

    if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
        alert("⚠️ Por favor selecciona el archivo digital a cargar (PDF, JPG o PNG).");
        fileInput?.focus();
        return;
    }

    const file = fileInput.files[0];
    if (file.size > 25 * 1024 * 1024) {
        alert("⚠️ El archivo es demasiado grande. El límite máximo permitido es de 25 MB.");
        return;
    }

    if (btnGuardar) {
        btnGuardar.disabled = true;
        btnGuardar.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Subiendo...`;
    }

    try {
        const reader = new FileReader();
        reader.onload = async function(e) {
            const dataUrl = e.target.result;
            const formato = file.name.split('.').pop().toLowerCase();

            const payload = {
                id_empleado: idEmpleadoRHActual,
                tipo_documento: tipoDoc,
                nombre_archivo: file.name,
                archivo_url: dataUrl,
                formato: formato,
                fecha_emision: fechaEmision,
                fecha_vencimiento: fechaVencimiento,
                esta_vigente: true,
                observaciones: notas,
                subido_por: (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "RECURSOS HUMANOS")
            };

            try {
                const res = await fetch(`${API_URL}/api/rh/documentos`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(payload)
                });

                if (res.ok) {
                    alert(`✅ ¡Documento "${tipoDoc}" subido y vinculado exitosamente al expediente laboral!`);
                    fileInput.value = "";
                    if (document.getElementById("rh-doc-emision")) document.getElementById("rh-doc-emision").value = "";
                    if (document.getElementById("rh-doc-vencimiento")) document.getElementById("rh-doc-vencimiento").value = "";
                    if (document.getElementById("rh-doc-notas")) document.getElementById("rh-doc-notas").value = "";
                    toggleFormularioSubirDocumentoRH();
                    recargarDocumentosRH(idEmpleadoRHActual);
                } else {
                    const err = await res.text();
                    alert(`❌ Error al registrar documento: ${err}`);
                }
            } catch (err) {
                alert(`❌ Error de comunicación: ${err.message}`);
            } finally {
                if (btnGuardar) {
                    btnGuardar.disabled = false;
                    btnGuardar.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar en Expediente Digital`;
                }
            }
        };

        reader.onerror = function() {
            alert("❌ Error al leer el archivo desde el dispositivo.");
            if (btnGuardar) {
                btnGuardar.disabled = false;
                btnGuardar.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar en Expediente Digital`;
            }
        };

        reader.readAsDataURL(file);
    } catch (e) {
        alert(`❌ Error inesperado: ${e.message}`);
        if (btnGuardar) {
            btnGuardar.disabled = false;
            btnGuardar.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar en Expediente Digital`;
        }
    }
}

async function recargarDocumentosRH(idEmp) {
    if (!idEmp) return;
    try {
        const res = await fetch(`${API_URL}/api/rh/documentos/${idEmp}`);
        if (res.ok) {
            const docs = await res.json();
            listaDocumentosRHActual = docs || [];
            filtrarDocumentosRHCategoria(categoriaFiltroDocRHActual || 'TODOS');
        }
    } catch (e) {
        console.error("Error al recargar documentos:", e);
    }
}

function abrirVisorDocumentoGeneral(url, nombre) {
    if (!url) {
        alert("⚠️ No se encontró el archivo digital adjunto.");
        return;
    }

    nombre = nombre || "documento";

    if (url.startsWith("data:")) {
        const win = window.open();
        if (win) {
            win.document.write(`
                <!DOCTYPE html>
                <html lang="es">
                <head>
                    <meta charset="UTF-8">
                    <title>${nombre} - VPRO Expediente Digital</title>
                    <style>
                        body { margin: 0; background: #0f172a; display: flex; flex-direction: column; height: 100vh; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
                        .topbar { background: #1e293b; color: white; padding: 12px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #334155; }
                        .btn-dl { background: #0284c7; color: white; padding: 8px 16px; text-decoration: none; border-radius: 6px; font-size: 13px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; }
                        .btn-dl:hover { background: #0369a1; }
                    </style>
                </head>
                <body>
                    <div class="topbar">
                        <span style="font-weight: 600; font-size: 14px;">📁 Expediente Laboral VPRO: ${nombre}</span>
                        <a href="${url}" download="${nombre}" class="btn-dl">⬇ Descargar Archivo Original</a>
                    </div>
                    ${url.startsWith("data:application/pdf") 
                        ? `<iframe src="${url}" style="flex: 1; border: none; width: 100%; height: 100%;"></iframe>`
                        : `<div style="flex: 1; display: flex; justify-content: center; align-items: center; overflow: auto; padding: 24px;"><img src="${url}" style="max-width: 90%; max-height: 90vh; border-radius: 8px; box-shadow: 0 12px 32px rgba(0,0,0,0.6);"></div>`
                    }
                </body>
                </html>
            `);
        } else {
            const a = document.createElement("a");
            a.href = url;
            a.download = nombre;
            a.target = "_blank";
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
        }
    } else {
        window.open(url.startsWith("http") ? url : `${API_URL}${url}`, "_blank");
    }
}

function verDocumentoRH(idDoc) {
    const item = cacheDocumentosRH[idDoc];
    if (!item || !item.url) {
        alert("⚠️ No se encontró el archivo digital adjunto para este documento.");
        return;
    }
    abrirVisorDocumentoGeneral(item.url, item.nombre);
}

async function verificarDocumentoRH(idDoc) {
    if (!confirm("¿Deseas certificar y marcar este documento como VERIFICADO POR RH?")) return;

    try {
        const res = await fetch(`${API_URL}/api/rh/documentos/${idDoc}`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ verificado_por_rh: true })
        });

        if (res.ok) {
            alert("✅ Documento validado y certificado por Recursos Humanos.");
            recargarDocumentosRH(idEmpleadoRHActual);
        } else {
            const err = await res.text();
            alert(`❌ Error al verificar documento: ${err}`);
        }
    } catch (e) {
        alert(`❌ Error de comunicación: ${e.message}`);
    }
}

async function eliminarDocumentoRH(idDoc, tipoNombre) {
    if (!confirm(`¿Confirmas eliminar el documento "${tipoNombre}" del expediente laboral? Esta acción no se puede deshacer.`)) return;

    try {
        const res = await fetch(`${API_URL}/api/rh/documentos/${idDoc}`, {
            method: "DELETE"
        });

        if (res.ok) {
            alert(`✅ Documento "${tipoNombre}" eliminado del expediente.`);
            recargarDocumentosRH(idEmpleadoRHActual);
        } else {
            const err = await res.text();
            alert(`❌ Error al eliminar documento: ${err}`);
        }
    } catch (e) {
        alert(`❌ Error de comunicación: ${e.message}`);
    }
}

// ==============================================================================
// GESTIÓN DE CONTRATOS LABORALES (RECURSOS HUMANOS)
// ==============================================================================
function toggleFormularioContratoRH() {
    const f = document.getElementById("form-registrar-contrato-rh");
    if (!f) return;
    f.style.display = (f.style.display === "none" || f.style.display === "") ? "block" : "none";
    if (f.style.display === "block") {
        const hoy = new Date().toISOString().split("T")[0];
        const inInicio = document.getElementById("rh-ctr-inicio");
        if (inInicio && !inInicio.value) inInicio.value = hoy;
        const depto = document.getElementById("rh-ficha-depto")?.innerText;
        const puesto = document.getElementById("rh-ficha-puesto")?.innerText;
        if (depto && depto !== "--" && document.getElementById("rh-ctr-depto")) {
            document.getElementById("rh-ctr-depto").value = depto;
        }
        if (puesto && puesto !== "--" && document.getElementById("rh-ctr-puesto")) {
            document.getElementById("rh-ctr-puesto").value = puesto;
        }
        document.getElementById("rh-ctr-tipo")?.focus();
    }
}

async function subirNuevoContratoRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor selecciona primero un colaborador en el selector de Recursos Humanos.");
        return;
    }

    const tipo = document.getElementById("rh-ctr-tipo")?.value;
    const inicio = document.getElementById("rh-ctr-inicio")?.value;
    const fin = document.getElementById("rh-ctr-fin")?.value || null;
    const puesto = document.getElementById("rh-ctr-puesto")?.value?.trim();
    const depto = document.getElementById("rh-ctr-depto")?.value?.trim();
    const salario = parseFloat(document.getElementById("rh-ctr-salario")?.value || 0);
    const jornada = document.getElementById("rh-ctr-jornada")?.value?.trim() || "L-V 09:00 a 18:00";
    const obs = document.getElementById("rh-ctr-observaciones")?.value?.trim() || "";
    const fileInput = document.getElementById("rh-ctr-archivo");
    const btn = document.getElementById("btn-guardar-ctr-rh");

    if (!inicio) {
        alert("⚠️ Por favor captura la fecha de inicio del contrato.");
        document.getElementById("rh-ctr-inicio")?.focus();
        return;
    }
    if (!puesto) {
        alert("⚠️ Por favor captura el puesto o cargo contratado.");
        document.getElementById("rh-ctr-puesto")?.focus();
        return;
    }
    if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
        alert("⚠️ Por favor selecciona el archivo digital del contrato firmado (PDF, JPG o PNG).");
        fileInput?.focus();
        return;
    }

    const file = fileInput.files[0];
    if (file.size > 25 * 1024 * 1024) {
        alert("⚠️ El archivo es demasiado grande (máximo 25 MB).");
        return;
    }

    if (btn) {
        btn.disabled = true;
        btn.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Guardando...`;
    }

    try {
        const reader = new FileReader();
        reader.onload = async function(e) {
            const dataUrl = e.target.result;

            const payload = {
                id_empleado: idEmpleadoRHActual,
                tipo_contrato: tipo,
                fecha_inicio: inicio,
                fecha_fin: fin,
                es_indefinido: !fin,
                puesto_contratado: puesto,
                departamento: depto,
                salario_mensual: salario,
                jornada: jornada,
                archivo_contrato_url: dataUrl,
                observaciones: obs,
                registrado_por: (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "RECURSOS HUMANOS")
            };

            try {
                const res = await fetch(`${API_URL}/api/rh/contratos`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(payload)
                });

                if (res.ok) {
                    const data = await res.json();
                    alert(`✅ ¡Contrato laboral ${data.folio || ''} registrado exitosamente en el expediente!`);
                    fileInput.value = "";
                    if (document.getElementById("rh-ctr-salario")) document.getElementById("rh-ctr-salario").value = "";
                    if (document.getElementById("rh-ctr-observaciones")) document.getElementById("rh-ctr-observaciones").value = "";
                    toggleFormularioContratoRH();
                    seleccionarEmpleadoRH(idEmpleadoRHActual);
                } else {
                    const err = await res.text();
                    alert(`❌ Error al registrar contrato: ${err}`);
                }
            } catch (err) {
                alert(`❌ Error de comunicación: ${err.message}`);
            } finally {
                if (btn) {
                    btn.disabled = false;
                    btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar Contrato en Expediente`;
                }
            }
        };

        reader.onerror = function() {
            alert("❌ Error al procesar el archivo en el navegador.");
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar Contrato en Expediente`;
            }
        };

        reader.readAsDataURL(file);
    } catch (e) {
        alert(`❌ Error inesperado: ${e.message}`);
        if (btn) {
            btn.disabled = false;
            btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar Contrato en Expediente`;
        }
    }
}

// ==============================================================================
// GESTIÓN DE PERMISOS E INCAPACIDADES (RECURSOS HUMANOS)
// ==============================================================================
function toggleFormularioPermisoRH() {
    const f = document.getElementById("form-registrar-permiso-rh");
    if (!f) return;
    f.style.display = (f.style.display === "none" || f.style.display === "") ? "block" : "none";
    if (f.style.display === "block") {
        const hoy = new Date().toISOString().split("T")[0];
        const inInicio = document.getElementById("rh-per-inicio");
        const inFin = document.getElementById("rh-per-fin");
        if (inInicio && !inInicio.value) inInicio.value = hoy;
        if (inFin && !inFin.value) inFin.value = hoy;
        alCambiarFechasPermisoRH();
        inInicio?.focus();
    }
}

function alCambiarFechasPermisoRH() {
    const fIni = document.getElementById("rh-per-inicio")?.value;
    const fFin = document.getElementById("rh-per-fin")?.value;
    const inDias = document.getElementById("rh-per-dias");
    if (fIni && fFin && inDias) {
        const d1 = new Date(fIni);
        const d2 = new Date(fFin);
        if (d2 >= d1) {
            inDias.value = Math.ceil((d2 - d1) / (1000 * 60 * 60 * 24)) + 1;
        } else {
            inDias.value = 1;
        }
    }
}

async function subirNuevoPermisoRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor selecciona primero a un colaborador.");
        return;
    }

    const tipo = document.getElementById("rh-per-tipo")?.value;
    const inicio = document.getElementById("rh-per-inicio")?.value;
    const fin = document.getElementById("rh-per-fin")?.value;
    const dias = parseInt(document.getElementById("rh-per-dias")?.value || "1");
    const goce = document.getElementById("rh-per-goce")?.value === "true";
    const estatus = document.getElementById("rh-per-estatus")?.value || "APROBADO";
    const motivo = document.getElementById("rh-per-motivo")?.value?.trim();
    const impacta = document.getElementById("rh-per-impacta") ? document.getElementById("rh-per-impacta").checked : true;
    const fileInput = document.getElementById("rh-per-archivo");
    const btn = document.getElementById("btn-guardar-per-rh");

    if (!inicio || !fin) {
        alert("⚠️ Por favor especifica las fechas de inicio y fin del permiso.");
        return;
    }
    if (!motivo) {
        alert("⚠️ Por favor captura el motivo o justificación del permiso.");
        document.getElementById("rh-per-motivo")?.focus();
        return;
    }

    if (btn) {
        btn.disabled = true;
        btn.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Guardando...`;
    }

    const enviar = async (archivoUrl = null) => {
        const payload = {
            id_empleado: idEmpleadoRHActual,
            tipo_permiso: tipo,
            fecha_solicitud: new Date().toISOString().split("T")[0],
            fecha_inicio: inicio,
            fecha_fin: fin,
            con_goce_de_sueldo: goce,
            justificacion: motivo,
            archivo_justificante: archivoUrl,
            estatus: estatus,
            impacta_asistencia: impacta,
            registrado_por: (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "RECURSOS HUMANOS")
        };

        try {
            const res = await fetch(`${API_URL}/api/rh/permisos`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            });

            if (res.ok) {
                const data = await res.json();
                alert(`✅ ¡Permiso laboral ${data.folio || ''} registrado exitosamente! ${impacta ? 'Sincronizado con el Reloj Checador.' : ''}`);
                if (fileInput) fileInput.value = "";
                if (document.getElementById("rh-per-motivo")) document.getElementById("rh-per-motivo").value = "";
                toggleFormularioPermisoRH();
                seleccionarEmpleadoRH(idEmpleadoRHActual);
            } else {
                const err = await res.text();
                alert(`❌ Error al registrar permiso: ${err}`);
            }
        } catch (e) {
            alert(`❌ Error de comunicación: ${e.message}`);
        } finally {
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar Permiso y Sincronizar`;
            }
        }
    };

    if (fileInput && fileInput.files && fileInput.files.length > 0) {
        const file = fileInput.files[0];
        const reader = new FileReader();
        reader.onload = (e) => enviar(e.target.result);
        reader.onerror = () => {
            alert("❌ Error al leer archivo adjunto.");
            if (btn) btn.disabled = false;
        };
        reader.readAsDataURL(file);
    } else {
        enviar(null);
    }
}

function toggleFormularioIncapacidadRH() {
    const f = document.getElementById("form-registrar-incapacidad-rh");
    if (!f) return;
    f.style.display = (f.style.display === "none" || f.style.display === "") ? "block" : "none";
    if (f.style.display === "block") {
        const hoy = new Date().toISOString().split("T")[0];
        const inInicio = document.getElementById("rh-inc-inicio");
        const inFin = document.getElementById("rh-inc-fin");
        if (inInicio && !inInicio.value) inInicio.value = hoy;
        if (inFin && !inFin.value) inFin.value = hoy;
        alCambiarFechasIncapacidadRH();
        inInicio?.focus();
    }
}

function alCambiarFechasIncapacidadRH() {
    const fIni = document.getElementById("rh-inc-inicio")?.value;
    const fFin = document.getElementById("rh-inc-fin")?.value;
    const inDias = document.getElementById("rh-inc-dias");
    if (fIni && fFin && inDias) {
        const d1 = new Date(fIni);
        const d2 = new Date(fFin);
        if (d2 >= d1) {
            inDias.value = Math.ceil((d2 - d1) / (1000 * 60 * 60 * 24)) + 1;
        } else {
            inDias.value = 1;
        }
    }
}

async function subirNuevaIncapacidadRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor selecciona primero a un colaborador.");
        return;
    }

    const tipo = document.getElementById("rh-inc-tipo")?.value;
    const folioImss = document.getElementById("rh-inc-imss-folio")?.value?.trim() || "";
    const inicio = document.getElementById("rh-inc-inicio")?.value;
    const fin = document.getElementById("rh-inc-fin")?.value;
    const diagnostico = document.getElementById("rh-inc-diagnostico")?.value?.trim() || "Incapacidad Médica";
    const medico = document.getElementById("rh-inc-medico")?.value?.trim() || "";
    const fileInput = document.getElementById("rh-inc-archivo");
    const btn = document.getElementById("btn-guardar-inc-rh");

    if (!inicio || !fin) {
        alert("⚠️ Por favor captura las fechas de inicio y fin amparadas por el IMSS.");
        return;
    }
    if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
        alert("⚠️ Por favor adjunta la boleta o certificado de incapacidad IMSS (PDF, JPG o PNG).");
        fileInput?.focus();
        return;
    }

    const file = fileInput.files[0];
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Guardando...`;
    }

    try {
        const reader = new FileReader();
        reader.onload = async function(e) {
            const dataUrl = e.target.result;

            const payload = {
                id_empleado: idEmpleadoRHActual,
                tipo: tipo,
                fecha_inicio: inicio,
                fecha_fin: fin,
                numero_imss: folioImss,
                medico_tratante: medico,
                diagnostico: diagnostico,
                porcentaje_pago_imss: tipo.includes("RIESGO") ? 100.0 : 60.0,
                archivo_incapacidad_url: dataUrl,
                registrado_por: (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "RECURSOS HUMANOS")
            };

            try {
                const res = await fetch(`${API_URL}/api/rh/incapacidades`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(payload)
                });

                if (res.ok) {
                    const data = await res.json();
                    alert(`✅ ¡Incapacidad médica ${data.folio || ''} registrada y sincronizada con el Kiosco!`);
                    fileInput.value = "";
                    if (document.getElementById("rh-inc-diagnostico")) document.getElementById("rh-inc-diagnostico").value = "";
                    toggleFormularioIncapacidadRH();
                    seleccionarEmpleadoRH(idEmpleadoRHActual);
                } else {
                    const err = await res.text();
                    alert(`❌ Error al registrar incapacidad: ${err}`);
                }
            } catch (err) {
                alert(`❌ Error de comunicación: ${err.message}`);
            } finally {
                if (btn) {
                    btn.disabled = false;
                    btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar Incapacidad IMSS`;
                }
            }
        };

        reader.readAsDataURL(file);
    } catch (e) {
        alert(`❌ Error inesperado: ${e.message}`);
        if (btn) btn.disabled = false;
    }
}

// ==============================================================================
// GESTIÓN DE CAPACITACIONES Y EVALUACIONES (RECURSOS HUMANOS)
// ==============================================================================
function toggleFormularioCapacitacionRH() {
    const f = document.getElementById("form-registrar-capacitacion-rh");
    if (!f) return;
    f.style.display = (f.style.display === "none" || f.style.display === "") ? "block" : "none";
    if (f.style.display === "block") {
        const hoy = new Date().toISOString().split("T")[0];
        const inInicio = document.getElementById("rh-cap-inicio");
        if (inInicio && !inInicio.value) inInicio.value = hoy;
        document.getElementById("rh-cap-nombre")?.focus();
    }
}

async function subirNuevaCapacitacionRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor selecciona primero a un colaborador.");
        return;
    }

    const nombre = document.getElementById("rh-cap-nombre")?.value?.trim();
    const tipo = document.getElementById("rh-cap-tipo")?.value;
    const horas = parseFloat(document.getElementById("rh-cap-horas")?.value || 8);
    const institucion = document.getElementById("rh-cap-institucion")?.value?.trim() || "";
    const inicio = document.getElementById("rh-cap-inicio")?.value;
    const fin = document.getElementById("rh-cap-fin")?.value || null;
    const resultado = document.getElementById("rh-cap-resultado")?.value || "APROBADO";
    const costo = parseFloat(document.getElementById("rh-cap-costo")?.value || 0);
    const pagado = document.getElementById("rh-cap-pagado")?.value === "true";
    const fileInput = document.getElementById("rh-cap-archivo");
    const btn = document.getElementById("btn-guardar-cap-rh");

    if (!nombre) {
        alert("⚠️ Por favor captura el nombre del curso o certificación.");
        document.getElementById("rh-cap-nombre")?.focus();
        return;
    }
    if (!inicio) {
        alert("⚠️ Por favor captura la fecha de inicio de la capacitación.");
        document.getElementById("rh-cap-inicio")?.focus();
        return;
    }
    if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
        alert("⚠️ Por favor adjunta la constancia DC-3 o diploma oficial (PDF, JPG o PNG).");
        fileInput?.focus();
        return;
    }

    const file = fileInput.files[0];
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Guardando...`;
    }

    try {
        const reader = new FileReader();
        reader.onload = async function(e) {
            const dataUrl = e.target.result;

            const payload = {
                id_empleado: idEmpleadoRHActual,
                nombre_curso: nombre,
                tipo: tipo,
                institucion: institucion,
                fecha_inicio: inicio,
                fecha_fin: fin,
                horas_duracion: horas,
                resultado: resultado,
                calificacion: 10.0,
                tiene_constancia: true,
                constancia_url: dataUrl,
                costo: costo,
                pagado_por_empresa: pagado,
                registrado_por: (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "RECURSOS HUMANOS")
            };

            try {
                const res = await fetch(`${API_URL}/api/rh/capacitacion`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(payload)
                });

                if (res.ok) {
                    alert(`✅ ¡Capacitación / DC-3 "${nombre}" registrada exitosamente en el expediente!`);
                    fileInput.value = "";
                    if (document.getElementById("rh-cap-nombre")) document.getElementById("rh-cap-nombre").value = "";
                    toggleFormularioCapacitacionRH();
                    seleccionarEmpleadoRH(idEmpleadoRHActual);
                } else {
                    const err = await res.text();
                    alert(`❌ Error al registrar curso: ${err}`);
                }
            } catch (err) {
                alert(`❌ Error de comunicación: ${err.message}`);
            } finally {
                if (btn) {
                    btn.disabled = false;
                    btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar Capacitación en Expediente`;
                }
            }
        };

        reader.readAsDataURL(file);
    } catch (e) {
        alert(`❌ Error: ${e.message}`);
        if (btn) btn.disabled = false;
    }
}

function toggleFormularioEvaluacionRH() {
    const f = document.getElementById("form-registrar-evaluacion-rh");
    if (!f) return;
    f.style.display = (f.style.display === "none" || f.style.display === "") ? "block" : "none";
    if (f.style.display === "block") {
        alCambiarCalificacionesEvaluacionRH();
        if (!document.getElementById("rh-eval-evaluador")?.value) {
            document.getElementById("rh-eval-evaluador").value = usuarioLogueado?.nombre_completo || "Dirección de Operaciones";
        }
        document.getElementById("rh-eval-periodo")?.focus();
    }
}

function alCambiarCalificacionesEvaluacionRH() {
    const c1 = parseFloat(document.getElementById("rh-eval-puntualidad")?.value || 10);
    const c2 = parseFloat(document.getElementById("rh-eval-calidad")?.value || 10);
    const c3 = parseFloat(document.getElementById("rh-eval-equipo")?.value || 10);
    const c4 = parseFloat(document.getElementById("rh-eval-responsabilidad")?.value || 10);
    const c5 = parseFloat(document.getElementById("rh-eval-iniciativa")?.value || 10);
    const c6 = parseFloat(document.getElementById("rh-eval-comunicacion")?.value || 10);
    const c7 = parseFloat(document.getElementById("rh-eval-cumplimiento")?.value || 10);

    const prom = (c1 + c2 + c3 + c4 + c5 + c6 + c7) / 7.0;
    const promFmt = prom.toFixed(1);

    let nivel = "EXCELENTE";
    if (prom >= 9) nivel = "EXCELENTE";
    else if (prom >= 7) nivel = "BUENO";
    else if (prom >= 5) nivel = "REGULAR";
    else nivel = "DEFICIENTE";

    const elProm = document.getElementById("rh-eval-promedio-calc");
    const elNivel = document.getElementById("rh-eval-nivel-calc");
    if (elProm) elProm.innerText = promFmt;
    if (elNivel) elNivel.innerText = nivel;
}

async function subirNuevaEvaluacionRH() {
    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor selecciona primero a un colaborador.");
        return;
    }

    const periodo = document.getElementById("rh-eval-periodo")?.value?.trim();
    const evaluador = document.getElementById("rh-eval-evaluador")?.value?.trim();
    const puestoEval = document.getElementById("rh-eval-puesto")?.value?.trim() || "Evaluador RH";

    const c1 = parseFloat(document.getElementById("rh-eval-puntualidad")?.value || 10);
    const c2 = parseFloat(document.getElementById("rh-eval-calidad")?.value || 10);
    const c3 = parseFloat(document.getElementById("rh-eval-equipo")?.value || 10);
    const c4 = parseFloat(document.getElementById("rh-eval-responsabilidad")?.value || 10);
    const c5 = parseFloat(document.getElementById("rh-eval-iniciativa")?.value || 10);
    const c6 = parseFloat(document.getElementById("rh-eval-comunicacion")?.value || 10);
    const c7 = parseFloat(document.getElementById("rh-eval-cumplimiento")?.value || 10);

    const fortalezas = document.getElementById("rh-eval-fortalezas")?.value?.trim() || "";
    const mejora = document.getElementById("rh-eval-mejora")?.value?.trim() || "";
    const fileInput = document.getElementById("rh-eval-archivo");
    const btn = document.getElementById("btn-guardar-eval-rh");

    if (!periodo) {
        alert("⚠️ Por favor indica el periodo evaluado (ej. 2026-Q1).");
        document.getElementById("rh-eval-periodo")?.focus();
        return;
    }
    if (!evaluador) {
        alert("⚠️ Por favor indica el nombre del evaluador.");
        document.getElementById("rh-eval-evaluador")?.focus();
        return;
    }

    if (btn) {
        btn.disabled = true;
        btn.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Guardando...`;
    }

    const enviar = async (archivoUrl = null) => {
        const payload = {
            id_empleado: idEmpleadoRHActual,
            periodo: periodo,
            tipo: "DESEMPEÑO PERIÓDICO",
            evaluador: evaluador,
            puesto_evaluador: puestoEval,
            puntualidad: c1,
            calidad_trabajo: c2,
            trabajo_equipo: c3,
            responsabilidad: c4,
            iniciativa: c5,
            comunicacion: c6,
            cumplimiento_objetivos: c7,
            fortalezas: fortalezas,
            areas_mejora: mejora,
            archivo_evaluacion_url: archivoUrl,
            registrado_por: (usuarioLogueado?.nombre_completo || usuarioLogueado?.nombre || "RECURSOS HUMANOS")
        };

        try {
            const res = await fetch(`${API_URL}/api/rh/evaluaciones`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            });

            if (res.ok) {
                const data = await res.json();
                alert(`✅ ¡Evaluación de desempeño del periodo "${periodo}" registrada exitosamente! Calificación: ${data.calificacion_final} (${data.nivel_desempeno})`);
                if (fileInput) fileInput.value = "";
                toggleFormularioEvaluacionRH();
                seleccionarEmpleadoRH(idEmpleadoRHActual);
            } else {
                const err = await res.text();
                alert(`❌ Error al registrar evaluación: ${err}`);
            }
        } catch (e) {
            alert(`❌ Error de comunicación: ${e.message}`);
        } finally {
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = `<i class="ph ph-floppy-disk"></i> Guardar Evaluación de Desempeño`;
            }
        }
    };

    if (fileInput && fileInput.files && fileInput.files.length > 0) {
        const file = fileInput.files[0];
        const reader = new FileReader();
        reader.onload = (e) => enviar(e.target.result);
        reader.readAsDataURL(file);
    } else {
        enviar(null);
    }
}

// ==============================================================================
// VISOR DE EXPEDIENTE DIGITAL INTEGRAL COMPLETO (TODO LO INTEGRADO)
// ==============================================================================
let datosExpedienteCompletoActual = null;

async function verMiExpedientePropio() {
    if (!usuarioLogueado) return;
    idEmpleadoRHActual = usuarioLogueado.id_empleado;
    await abrirExpedienteCompletoRH();
}

async function abrirExpedienteCompletoRH() {
    const esVillarreal = typeof esUsuarioVillarreal === 'function' ? esUsuarioVillarreal() : false;
    const miId = usuarioLogueado?.id_empleado ? String(usuarioLogueado.id_empleado) : null;
    if (!esVillarreal && miId) {
        idEmpleadoRHActual = miId;
    }

    if (!idEmpleadoRHActual) {
        alert("⚠️ Por favor primero busca o selecciona a un colaborador para abrir su expediente integral.");
        document.getElementById("input-buscar-rh-empleado")?.focus();
        return;
    }

    const modal = document.getElementById("modal-expediente-completo-rh");
    const contenedor = document.getElementById("exp-completo-contenido");
    if (!modal || !contenedor) return;

    modal.style.display = "flex";
    contenedor.innerHTML = `
        <div style="text-align: center; padding: 50px 20px; color: #64748b;">
            <i class="ph ph-spinner ph-spin" style="font-size: 36px; color: #0284c7;"></i>
            <p style="margin-top: 14px; font-weight: 600; font-size: 14px;">Extrayendo expediente integral desde base de datos segura...</p>
        </div>
    `;

    try {
        const [resExp, resContratos, resVac, resPerm, resIncap, resEval, resCap, resDocs] = await Promise.all([
            fetch(`${API_URL}/api/rh/expediente/${idEmpleadoRHActual}`),
            fetch(`${API_URL}/api/rh/contratos/${idEmpleadoRHActual}`).catch(() => ({ ok: false })),
            fetch(`${API_URL}/api/rh/vacaciones/${idEmpleadoRHActual}`).catch(() => ({ ok: false })),
            fetch(`${API_URL}/api/rh/permisos?id_empleado=${idEmpleadoRHActual}`).catch(() => ({ ok: false })),
            fetch(`${API_URL}/api/rh/incapacidades/${idEmpleadoRHActual}`).catch(() => ({ ok: false })),
            fetch(`${API_URL}/api/rh/evaluaciones/${idEmpleadoRHActual}`).catch(() => ({ ok: false })),
            fetch(`${API_URL}/api/rh/capacitacion/${idEmpleadoRHActual}`).catch(() => ({ ok: false })),
            fetch(`${API_URL}/api/rh/documentos/${idEmpleadoRHActual}`).catch(() => ({ ok: false }))
        ]);

        if (!resExp.ok) {
            throw new Error(await resExp.text());
        }

        const dataExp = await resExp.json();
        const contratos = resContratos.ok ? await resContratos.json() : [];
        const dataVac = resVac.ok ? await resVac.json() : {};
        const permisos = resPerm.ok ? await resPerm.json() : [];
        const incapacidades = resIncap.ok ? await resIncap.json() : [];
        const evaluaciones = resEval.ok ? await resEval.json() : [];
        const capacitaciones = resCap.ok ? await resCap.json() : [];
        const documentos = resDocs.ok ? await resDocs.json() : (dataExp.documentos || []);

        datosExpedienteCompletoActual = {
            exp: dataExp,
            contratos,
            vacaciones: dataVac,
            permisos,
            incapacidades,
            evaluaciones,
            capacitaciones,
            documentos
        };

        renderizarExpedienteCompletoModal(datosExpedienteCompletoActual);
    } catch (e) {
        console.error("Error al cargar expediente completo:", e);
        contenedor.innerHTML = `
            <div style="background: #fee2e2; border: 1px solid #fca5a5; padding: 20px; border-radius: 10px; color: #991b1b; text-align: center;">
                <b>❌ No se pudo cargar el expediente completo:</b> ${e.message}
            </div>
        `;
    }
}

function cerrarExpedienteCompletoRH() {
    const modal = document.getElementById("modal-expediente-completo-rh");
    if (modal) modal.style.display = "none";
}

function renderizarExpedienteCompletoModal(datos) {
    const contenedor = document.getElementById("exp-completo-contenido");
    if (!contenedor) return;

    const emp = datos.exp.datos_personales || {};
    const contrato = datos.exp.contrato_vigente || {};
    const vacResumen = datos.vacaciones?.resumen || datos.exp.resumen_vacaciones || {};
    const vacHistorial = datos.vacaciones?.historial || [];
    const contratos = datos.contratos || [];
    const permisos = datos.permisos || [];
    const incapacidades = datos.incapacidades || [];
    const evaluaciones = datos.evaluaciones || [];
    const capacitaciones = datos.capacitaciones || [];
    const docs = datos.documentos || [];

    const badgeEst = document.getElementById("exp-completo-badge-estatus");
    if (badgeEst) {
        badgeEst.innerText = emp.estatus_empleado || "ACTIVO";
        badgeEst.style.background = emp.estatus_empleado === "BAJA" ? "#fee2e2" : "#dcfce7";
        badgeEst.style.color = emp.estatus_empleado === "BAJA" ? "#991b1b" : "#166534";
    }

    const foto = emp.foto_url || `${API_URL}/fotos/${emp.id_empleado}.jpg`;

    // Calculo seguro de edad y antiguedad (soporta tanto datos directos como calculo desde fecha_nac y fecha_ing)
    let edadDisplay = '--';
    if (emp.edad !== undefined && emp.edad !== null && emp.edad !== '') {
        edadDisplay = `${emp.edad} AÑOS`;
    } else if (emp.fecha_nac) {
        const fn = new Date(emp.fecha_nac);
        if (!isNaN(fn.getTime())) {
            const hoy = new Date();
            let edad = hoy.getFullYear() - fn.getFullYear();
            const m = hoy.getMonth() - fn.getMonth();
            if (m < 0 || (m === 0 && hoy.getDate() < fn.getDate())) edad--;
            if (edad > 0) edadDisplay = `${edad} AÑOS`;
        }
    }

    let antiguedadDisplay = '--';
    if (emp.anios_trabajados !== undefined && emp.anios_trabajados !== null && emp.anios_trabajados !== '') {
        antiguedadDisplay = `${emp.anios_trabajados} AÑOS`;
    } else if (emp.fecha_ing) {
        const fi = new Date(emp.fecha_ing);
        if (!isNaN(fi.getTime())) {
            const hoy = new Date();
            let ant = hoy.getFullYear() - fi.getFullYear();
            const m = hoy.getMonth() - fi.getMonth();
            if (m < 0 || (m === 0 && hoy.getDate() < fi.getDate())) ant--;
            if (ant >= 0) antiguedadDisplay = `${ant} AÑOS`;
        }
    }

    let html = `
        <!-- FICHA PRINCIPAL -->
        <div style="background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%); border-radius: 12px; padding: 20px 24px; color: white; display: flex; flex-wrap: wrap; gap: 20px; align-items: center; margin-bottom: 20px; box-shadow: 0 4px 14px rgba(0,0,0,0.1);">
            <img src="${foto}" onerror="this.src='vendor/img/avatar_default.png'" style="width: 86px; height: 86px; border-radius: 50%; object-fit: cover; border: 3px solid #38bdf8;">
            <div style="flex: 1; min-width: 250px;">
                <h2 style="margin: 0 0 4px 0; font-size: 22px; color: #ffffff;">${emp.nombre || '--'}</h2>
                <div style="font-size: 13.5px; color: #94a3b8; display: flex; flex-wrap: wrap; gap: 14px; margin-top: 4px;">
                    <span><b>ID:</b> <code style="color: #38bdf8; font-weight: 700;">${emp.id_empleado || '--'}</code></span>
                    <span><b>Depto:</b> <span style="color: #f8fafc;">${emp.depto || '--'}</span></span>
                    <span><b>Puesto:</b> <span style="color: #f8fafc;">${emp.puesto || '--'}</span></span>
                    <span><b>Ingreso:</b> <span style="color: #f8fafc;">${emp.fecha_ing || '--'}</span></span>
                </div>
            </div>
            <div style="display: flex; gap: 12px;">
                <div style="background: rgba(255,255,255,0.08); padding: 8px 14px; border-radius: 8px; text-align: center;">
                    <div style="font-size: 11px; color: #94a3b8;">EDAD</div>
                    <b style="font-size: 16px; color: #38bdf8;">${edadDisplay}</b>
                </div>
                <div style="background: rgba(255,255,255,0.08); padding: 8px 14px; border-radius: 8px; text-align: center;">
                    <div style="font-size: 11px; color: #94a3b8;">ANTIGÜEDAD</div>
                    <b style="font-size: 16px; color: #4ade80;">${antiguedadDisplay}</b>
                </div>
            </div>
        </div>

        <!-- SECCIÓN 1: DATOS GENERALES Y FISCALES -->
        <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 10px; padding: 18px; margin-bottom: 20px;">
            <h4 style="margin: 0 0 14px 0; color: #0f172a; font-size: 15px; display: flex; align-items: center; gap: 8px; border-bottom: 1px dashed #cbd5e1; padding-bottom: 8px;">
                <i class="ph ph-identification-card" style="color: #0284c7;"></i> 1. Identificación Oficial, Fiscal y Contacto
            </h4>
            <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; font-size: 13px; margin-bottom: 14px;">
                <div><span style="color: #64748b;">RFC:</span> <b>${emp.rfc || '--'}</b></div>
                <div><span style="color: #64748b;">CURP:</span> <b>${emp.curp || '--'}</b></div>
                <div><span style="color: #64748b;">NSS (IMSS):</span> <b>${emp.nss || '--'}</b></div>
                <div><span style="color: #64748b;">Celular:</span> <b>${emp.cel || '--'}</b></div>
            </div>
            <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; font-size: 13px;">
                <div style="word-break: break-word;"><span style="color: #64748b;">Correo:</span> <b>${emp.email || '--'}</b></div>
                <div><span style="color: #64748b;">Domicilio:</span> <b>${emp.domicilio || '--'}, ${emp.ciudad || ''} (CP: ${emp.cp || '--'})</b></div>
                <div><span style="color: #64748b;">Contacto Emergencia:</span> <b>${emp.contacto_emergencia || '--'} (${emp.parentesco_emergencia || 'Familiar'}) - Tel: ${emp.tel_emergencia || '--'}</b></div>
                <div><span style="color: #64748b;">Escolaridad / Estado Civil:</span> <b>${emp.escolaridad || '--'} / ${emp.estado_civil || '--'}</b></div>
            </div>
        </div>

        <!-- SECCIÓN 2: CONTRATO LABORAL VIGENTE -->
        <div style="background: #ffffff; border: 1px solid #cbd5e1; border-radius: 10px; padding: 18px; margin-bottom: 20px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; border-bottom: 1px dashed #cbd5e1; padding-bottom: 8px;">
                <h4 style="margin: 0; color: #0f172a; font-size: 15px; display: flex; align-items: center; gap: 8px;">
                    <i class="ph ph-scroll" style="color: #0284c7;"></i> 2. Régimen Contractual y Salario
                </h4>
                <span style="font-size: 11.5px; font-weight: 700; padding: 3px 8px; border-radius: 4px; background: #e0f2fe; color: #0369a1;">
                    ${contratos.length} contrato(s) en historial
                </span>
            </div>
            ${contrato && contrato.folio_contrato ? `
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px; font-size: 13px; align-items: center;">
                    <div><span style="color: #64748b;">Folio Vigente:</span> <b style="color: #0369a1;">${contrato.folio_contrato}</b></div>
                    <div><span style="color: #64748b;">Tipo Contrato:</span> <b>${contrato.tipo_contrato || emp.tipo_contrato || '--'}</b></div>
                    <div><span style="color: #64748b;">Inicio / Fin:</span> <b>${contrato.fecha_inicio || '--'} a ${contrato.fecha_fin || 'Indefinido'}</b></div>
                    <div><span style="color: #64748b;">Salario Mensual Bruto:</span> <b style="color: #166534; font-size: 14px;">$${Number(contrato.salario_mensual || emp.salario_mensual || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</b></div>
                    <div><span style="color: #64748b;">Jornada:</span> <b>${contrato.jornada || 'L-V 09:00 a 18:00'}</b></div>
                    <div>
                        ${contrato.archivo_contrato_url ? `
                            <button type="button" onclick="abrirVisorDocumentoGeneral('${contrato.archivo_contrato_url.replace(/'/g, "\\'")}', 'Contrato_${contrato.folio_contrato}')"
                                style="background: #0284c7; color: white; border: none; padding: 6px 12px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                                <i class="ph ph-file-pdf"></i> Ver Contrato Firmado
                            </button>
                        ` : `<span style="color: #94a3b8; font-size: 12px;">Sin archivo adjunto</span>`}
                    </div>
                </div>
            ` : `
                <div style="font-size: 13px; color: #64748b;">
                    Tipo: <b>${emp.tipo_contrato || 'PLANTA'}</b> | Salario Registrado: <b>$${Number(emp.salario_mensual || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</b> | Sin contrato formal registrado aún.
                </div>
            `}
        </div>

        <!-- SECCIÓN 3: BALANCE VACACIONES LFT -->
        <div style="background: #ffffff; border: 1px solid #cbd5e1; border-radius: 10px; padding: 18px; margin-bottom: 20px;">
            <h4 style="margin: 0 0 14px 0; color: #0f172a; font-size: 15px; display: flex; align-items: center; gap: 8px; border-bottom: 1px dashed #cbd5e1; padding-bottom: 8px;">
                <i class="ph ph-sun-horizon" style="color: #ea580c;"></i> 3. Saldo de Vacaciones LFT (Artículos 76, 78 y 81)
            </h4>
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; margin-bottom: 14px; text-align: center;">
                <div style="background: #eff6ff; padding: 10px; border-radius: 8px; border: 1px solid #bfdbfe;">
                    <div style="font-size: 11px; font-weight: 700; color: #1e40af;">CORRESPONDIENTES</div>
                    <b style="font-size: 22px; color: #1d4ed8;">${vacResumen.dias_totales_correspondientes || vacResumen.dias_totales_acumulados || 0}</b> días
                </div>
                <div style="background: #fef3c7; padding: 10px; border-radius: 8px; border: 1px solid #fde68a;">
                    <div style="font-size: 11px; font-weight: 700; color: #92400e;">DISFRUTADOS</div>
                    <b style="font-size: 22px; color: #b45309;">${vacResumen.dias_tomados || 0}</b> días
                </div>
                <div style="background: #ecfdf5; padding: 10px; border-radius: 8px; border: 1px solid #a7f3d0;">
                    <div style="font-size: 11px; font-weight: 700; color: #065f46;">SALDO PENDIENTE</div>
                    <b style="font-size: 22px; color: #047857;">${vacResumen.dias_pendientes || 0}</b> días
                </div>
            </div>
            ${vacHistorial.length > 0 ? `
                <div style="max-height: 140px; overflow-y: auto; font-size: 12.5px;">
                    <table style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f1f5f9; color: #475569; text-align: left;">
                                <th style="padding: 6px;">Periodo / Motivo</th>
                                <th style="padding: 6px;">Días</th>
                                <th style="padding: 6px;">Fechas</th>
                                <th style="padding: 6px; text-align: center;">Comprobante</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${vacHistorial.map(v => `
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 6px;">${v.observaciones || `Año ${v.anio_periodo}`}</td>
                                    <td style="padding: 6px;"><b>${v.dias_tomados} día(s)</b></td>
                                    <td style="padding: 6px;">${v.fecha_inicio_goce} al ${v.fecha_fin_goce}</td>
                                    <td style="padding: 6px; text-align: center;">
                                        <button type="button" onclick="imprimirPapeletaVacacionesRH(${v.id_vacacion}, '${(emp.nombre || '').replace(/'/g, "\\'")}', '${v.fecha_inicio_goce}', '${v.fecha_fin_goce}', ${v.dias_tomados}, '${(v.observaciones || '').replace(/'/g, "\\'")}')"
                                            style="background: #f1f5f9; border: 1px solid #cbd5e1; border-radius: 4px; padding: 2px 8px; font-size: 11px; cursor: pointer;">
                                            📄 Papeleta LFT
                                        </button>
                                    </td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            ` : `<div style="font-size: 12.5px; color: #94a3b8;">Sin periodos vacacionales gozados registrados.</div>`}
        </div>

        <!-- SECCIÓN 4: PERMISOS E INCAPACIDADES -->
        <div style="background: #ffffff; border: 1px solid #cbd5e1; border-radius: 10px; padding: 18px; margin-bottom: 20px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; border-bottom: 1px dashed #cbd5e1; padding-bottom: 8px;">
                <h4 style="margin: 0; color: #0f172a; font-size: 15px; display: flex; align-items: center; gap: 8px;">
                    <i class="ph ph-clock-user" style="color: #6366f1;"></i> 4. Permisos Laborales e Incapacidades Médicas (${permisos.length + incapacidades.length})
                </h4>
            </div>
            ${(permisos.length === 0 && incapacidades.length === 0) ? `
                <div style="font-size: 12.5px; color: #94a3b8;">Sin permisos ni incapacidades médicas registradas.</div>
            ` : `
                <div style="max-height: 160px; overflow-y: auto; font-size: 12.5px;">
                    <table style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f1f5f9; color: #475569; text-align: left;">
                                <th style="padding: 6px;">Folio</th>
                                <th style="padding: 6px;">Tipo</th>
                                <th style="padding: 6px;">Motivo / Diagnóstico</th>
                                <th style="padding: 6px;">Fechas</th>
                                <th style="padding: 6px;">Días</th>
                                <th style="padding: 6px; text-align: center;">Adjunto</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${permisos.map(p => `
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 6px;"><b>${p.folio_permiso || 'PER'}</b></td>
                                    <td style="padding: 6px;"><span style="background: #eff6ff; color: #1e40af; padding: 2px 6px; border-radius: 4px; font-size: 11px;">PERMISO</span></td>
                                    <td style="padding: 6px;">${p.justificacion || '--'}</td>
                                    <td style="padding: 6px;">${p.fecha_inicio} al ${p.fecha_fin}</td>
                                    <td style="padding: 6px;">${p.dias_solicitados} d</td>
                                    <td style="padding: 6px; text-align: center;">
                                        ${p.archivo_justificante ? `
                                            <button type="button" onclick="abrirVisorDocumentoGeneral('${p.archivo_justificante.replace(/'/g, "\\'")}', 'Justificante_${p.folio_permiso}')" style="background: #0284c7; color: white; border: none; padding: 3px 8px; border-radius: 4px; font-size: 11px; cursor: pointer;">
                                                Ver
                                            </button>
                                        ` : '<span style="color:#cbd5e1;">--</span>'}
                                    </td>
                                </tr>
                            `).join('')}
                            ${incapacidades.map(i => `
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 6px;"><b>${i.folio_incapacidad || 'INC'}</b></td>
                                    <td style="padding: 6px;"><span style="background: #fee2e2; color: #991b1b; padding: 2px 6px; border-radius: 4px; font-size: 11px;">INCAPACIDAD IMSS</span></td>
                                    <td style="padding: 6px;">${i.diagnostico || i.tipo || '--'}</td>
                                    <td style="padding: 6px;">${i.fecha_inicio} al ${i.fecha_fin}</td>
                                    <td style="padding: 6px;">${i.dias_incapacidad} d</td>
                                    <td style="padding: 6px; text-align: center;">
                                        ${i.archivo_incapacidad_url ? `
                                            <button type="button" onclick="abrirVisorDocumentoGeneral('${i.archivo_incapacidad_url.replace(/'/g, "\\'")}', 'Incapacidad_${i.folio_incapacidad}')" style="background: #ef4444; color: white; border: none; padding: 3px 8px; border-radius: 4px; font-size: 11px; cursor: pointer;">
                                                Ver
                                            </button>
                                        ` : '<span style="color:#cbd5e1;">--</span>'}
                                    </td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            `}
        </div>

        <!-- SECCIÓN 5: CAPACITACIÓN Y EVALUACIONES -->
        <div style="background: #ffffff; border: 1px solid #cbd5e1; border-radius: 10px; padding: 18px; margin-bottom: 20px;">
            <h4 style="margin: 0 0 14px 0; color: #0f172a; font-size: 15px; display: flex; align-items: center; gap: 8px; border-bottom: 1px dashed #cbd5e1; padding-bottom: 8px;">
                <i class="ph ph-graduation-cap" style="color: #8b5cf6;"></i> 5. Capacitaciones Técnicas, DC-3 y Evaluaciones (${capacitaciones.length + evaluaciones.length})
            </h4>
            ${(capacitaciones.length === 0 && evaluaciones.length === 0) ? `
                <div style="font-size: 12.5px; color: #94a3b8;">Sin cursos, constancias DC-3 o evaluaciones registradas.</div>
            ` : `
                <div style="max-height: 160px; overflow-y: auto; font-size: 12.5px;">
                    <table style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f1f5f9; color: #475569; text-align: left;">
                                <th style="padding: 6px;">Concepto / Periodo</th>
                                <th style="padding: 6px;">Tipo</th>
                                <th style="padding: 6px;">Institución / Evaluador</th>
                                <th style="padding: 6px;">Resultado</th>
                                <th style="padding: 6px; text-align: center;">Constancia</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${capacitaciones.map(c => `
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 6px;"><b>${c.nombre_curso}</b></td>
                                    <td style="padding: 6px;"><span style="background: #f5f3ff; color: #6d28d9; padding: 2px 6px; border-radius: 4px; font-size: 11px;">${c.tipo}</span></td>
                                    <td style="padding: 6px;">${c.institucion || '--'}</td>
                                    <td style="padding: 6px;"><b style="color: #166534;">${c.resultado || 'APROBADO'}</b></td>
                                    <td style="padding: 6px; text-align: center;">
                                        ${c.constancia_url ? `
                                            <button type="button" onclick="abrirVisorDocumentoGeneral('${c.constancia_url.replace(/'/g, "\\'")}', 'Constancia_${c.nombre_curso}')" style="background: #8b5cf6; color: white; border: none; padding: 3px 8px; border-radius: 4px; font-size: 11px; cursor: pointer;">
                                                Ver
                                            </button>
                                        ` : '<span style="color:#cbd5e1;">--</span>'}
                                    </td>
                                </tr>
                            `).join('')}
                            ${evaluaciones.map(ev => `
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 6px;"><b>${ev.periodo}</b></td>
                                    <td style="padding: 6px;"><span style="background: #f8fafc; color: #334155; padding: 2px 6px; border-radius: 4px; font-size: 11px;">EVALUACIÓN</span></td>
                                    <td style="padding: 6px;">${ev.evaluador || '--'}</td>
                                    <td style="padding: 6px;"><b style="color: #1e40af;">${ev.calificacion_final} (${ev.nivel_desempeno})</b></td>
                                    <td style="padding: 6px; text-align: center;">
                                        ${ev.archivo_evaluacion_url ? `
                                            <button type="button" onclick="abrirVisorDocumentoGeneral('${ev.archivo_evaluacion_url.replace(/'/g, "\\'")}', 'Evaluacion_${ev.periodo}')" style="background: #0f172a; color: white; border: none; padding: 3px 8px; border-radius: 4px; font-size: 11px; cursor: pointer;">
                                                Ver
                                            </button>
                                        ` : '<span style="color:#cbd5e1;">--</span>'}
                                    </td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            `}
        </div>

        <!-- SECCIÓN 6: BÓVEDA INTEGRAL DE DOCUMENTOS DIGITALES (TODO LO QUE TENGA) -->
        <div style="background: #f8fafc; border: 1.5px solid #cbd5e1; border-radius: 12px; padding: 20px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; border-bottom: 1px dashed #cbd5e1; padding-bottom: 8px;">
                <h4 style="margin: 0; color: #0f172a; font-size: 16px; display: flex; align-items: center; gap: 8px;">
                    <i class="ph ph-folder-open" style="color: var(--accent-color);"></i>
                    <span>6. Bóveda Integral de Documentos Digitales Oficiales (${docs.length} archivos)</span>
                </h4>
                ${['ADMIN', 'COORDINADOR', 'RH'].includes(usuarioLogueado.rol) ? `
                <button type="button" onclick="cerrarExpedienteCompletoRH(); cambiarPestanaRH('documentos');" style="background: #e2e8f0; color: #1e293b; border: none; padding: 5px 12px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer;">
                    ➕ Subir Más Documentos
                </button>
                ` : ''}
            </div>
            ${docs.length === 0 ? `
                <div style="text-align: center; padding: 30px; color: #94a3b8; font-size: 13px;">
                    📁 Sin documentos digitales cargados todavía en el expediente laboral.
                </div>
            ` : `
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 14px;">
                    ${docs.map(d => {
                        const fmt = (d.formato || (d.nombre_archivo ? d.nombre_archivo.split('.').pop() : 'DOC')).toUpperCase();
                        const esPdf = fmt === 'PDF';
                        const url = d.archivo_url || '';
                        return `
                            <div style="background: white; border: 1px solid #cbd5e1; border-radius: 8px; padding: 12px 14px; display: flex; flex-direction: column; justify-content: space-between; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 8px; margin-bottom: 8px;">
                                    <div>
                                        <b style="color: #0f172a; font-size: 13px; display: block;">${d.tipo_documento || 'Documento'}</b>
                                        <span style="font-size: 11px; color: #64748b; font-family: monospace;">${d.nombre_archivo || '--'}</span>
                                    </div>
                                    <span style="background: ${esPdf ? '#fee2e2' : '#e0f2fe'}; color: ${esPdf ? '#991b1b' : '#0369a1'}; font-size: 10px; font-weight: 800; padding: 2px 6px; border-radius: 4px;">
                                        .${fmt}
                                    </span>
                                </div>
                                <div style="font-size: 11.5px; color: #64748b; margin-bottom: 10px;">
                                    ${d.fecha_vencimiento ? `Caducidad: <b>${d.fecha_vencimiento}</b>` : `Subido: <b>${String(d.fecha_subida || '').substring(0, 10) || '--'}</b>`}
                                    ${d.verificado_por_rh ? ` • <span style="color:#16a34a; font-weight:700;">✓ Verificado</span>` : ''}
                                </div>
                                <div style="display: flex; gap: 6px;">
                                    <button type="button" onclick="abrirVisorDocumentoGeneral('${url.replace(/'/g, "\\'")}', '${(d.tipo_documento || 'Documento').replace(/'/g, "\\'")}')"
                                        style="flex: 1; background: #0284c7; color: white; border: none; padding: 6px; border-radius: 5px; font-size: 12px; font-weight: 600; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 4px;">
                                        <i class="ph ph-eye"></i> Ver
                                    </button>
                                    <a href="${url}" download="${d.nombre_archivo || 'documento'}"
                                        style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 6px 10px; border-radius: 5px; font-size: 12px; text-decoration: none; display: flex; align-items: center; justify-content: center;"
                                        title="Descargar archivo original">
                                        <i class="ph ph-download-simple"></i>
                                    </a>
                                </div>
                            </div>
                        `;
                    }).join('')}
                </div>
            `}
        </div>
    `;

    contenedor.innerHTML = html;
}

function imprimirExpedienteCompletoRH() {
    if (!datosExpedienteCompletoActual) {
        alert("⚠️ No hay datos cargados del expediente.");
        return;
    }

    const emp = datosExpedienteCompletoActual.exp.datos_personales || {};
    const win = window.open("", "_blank");
    if (!win) {
        alert("⚠️ Permite las ventanas emergentes en tu navegador para imprimir el expediente.");
        return;
    }

    const contenido = document.getElementById("exp-completo-contenido")?.innerHTML || "";

    win.document.write(`
        <!DOCTYPE html>
        <html lang="es">
        <head>
            <meta charset="UTF-8">
            <title>Expediente Laboral Digital - ${emp.nombre || 'Empleado'}</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 30px; color: #0f172a; line-height: 1.5; font-size: 13px; }
                h2, h3, h4 { margin-top: 0; color: #0f172a; }
                .btn-print { background: #0284c7; color: white; border: none; padding: 10px 20px; border-radius: 6px; font-weight: 700; cursor: pointer; margin-bottom: 20px; }
                table { width: 100%; border-collapse: collapse; margin-bottom: 14px; }
                th, td { border: 1px solid #cbd5e1; padding: 6px 10px; font-size: 12px; }
                th { background: #f1f5f9; }
                button { display: none !important; }
                @media print { .btn-print { display: none; } body { margin: 0; } }
            </style>
        </head>
        <body>
            <div style="text-align: center;">
                <button class="btn-print" onclick="window.print()">🖨️ Imprimir Expediente Integral</button>
            </div>
            <div style="text-align: center; border-bottom: 2px solid #0f172a; padding-bottom: 12px; margin-bottom: 20px;">
                <h2 style="margin: 0;">VPRO STREAMING SERVICES S.A. DE C.V.</h2>
                <h4 style="margin: 4px 0 0 0; color: #64748b;">EXPEDIENTE DIGITAL INTEGRAL Y AUDITORÍA DE PERSONAL</h4>
            </div>
            ${contenido}
        </body>
        </html>
    `);
    win.document.close();
}
