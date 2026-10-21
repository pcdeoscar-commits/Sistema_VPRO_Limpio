// ==============================================================================
// MÓDULO: transfer.js
// 📦 VPRO Transfer (archivos hasta 5GB)
// Líneas originales: 13466–14248 de script.js
// ==============================================================================

// ==========================================
// 📦 MÓDULO VPRO TRANSFER (COMPARTIR ARCHIVOS HASTA 5GB CON BORRADO EN 7H POST-DESCARGA)
// ==========================================
let archivosTransferenciaSeleccionados = [];
let peticionSubidaXHR = null;

function cambiarPestanaTransferencias(pestana) {
    const subvistas = {
        'enviar': document.getElementById('subvista-transfer-enviar'),
        'recibidos': document.getElementById('subvista-transfer-recibidos'),
        'enviados': document.getElementById('subvista-transfer-enviados'),
        'historial': document.getElementById('subvista-transfer-historial')
    };
    const botones = {
        'enviar': document.getElementById('tab-transfer-btn-enviar'),
        'recibidos': document.getElementById('tab-transfer-btn-recibidos'),
        'enviados': document.getElementById('tab-transfer-btn-enviados'),
        'historial': document.getElementById('tab-transfer-btn-historial')
    };

    Object.keys(subvistas).forEach(k => {
        if (subvistas[k]) subvistas[k].style.display = (k === pestana) ? 'block' : 'none';
        if (botones[k]) {
            if (k === pestana) {
                botones[k].style.background = '#0f172a';
                botones[k].style.color = '#ffffff';
                botones[k].style.border = 'none';
            } else {
                botones[k].style.background = '#f1f5f9';
                botones[k].style.color = '#475569';
                botones[k].style.border = '1px solid #cbd5e1';
            }
        }
    });

    if (pestana === 'recibidos') {
        cargarTransferenciasRecibidos();
    } else if (pestana === 'enviados') {
        cargarTransferenciasEnviados();
    } else if (pestana === 'historial') {
        cargarHistorialTransferencias();
    }
}

async function cargarTransferenciasModulo() {
    if (!usuarioLogueado) return;
    
    // Configurar Dropzone Drag & Drop
    const dropzone = document.getElementById("transfer-dropzone");
    if (dropzone && !dropzone.dataset.dragInit) {
        dropzone.dataset.dragInit = "true";
        dropzone.addEventListener("dragover", (e) => {
            e.preventDefault();
            dropzone.style.borderColor = "var(--accent-color)";
            dropzone.style.background = "#eef2ff";
        });
        dropzone.addEventListener("dragleave", (e) => {
            e.preventDefault();
            dropzone.style.borderColor = "#94a3b8";
            dropzone.style.background = "#f8fafc";
        });
        dropzone.addEventListener("drop", (e) => {
            e.preventDefault();
            dropzone.style.borderColor = "#94a3b8";
            dropzone.style.background = "#f8fafc";
            if (e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files.length > 0) {
                procesarNuevosArchivosTransferencia(e.dataTransfer.files);
            }
        });
    }

    // Cargar selector de empleados activos (excluyendo al usuario actual)
    const selectDestino = document.getElementById("transfer-select-destino");
    if (selectDestino) {
        try {
            // Intentar primero el endpoint directo de destinatarios para transferencias
            let res = await fetch(`${API_URL}/api/transferencias/destinatarios`);
            if (!res.ok) {
                // Fallback al endpoint general de empleados
                res = await fetch(`${API_URL}/api/empleados`);
            }
            if (res.ok) {
                const empleados = await res.json();
                const actual = selectDestino.value;
                selectDestino.innerHTML = '<option value="">-- Selecciona un colaborador activo --</option>' + 
                    empleados
                        .map(e => {
                            const esUsuarioActual = String(e.id_empleado).trim() === String(usuarioLogueado.id_empleado).trim();
                            const textoNombre = esUsuarioActual ? `${e.nombre} (Tú / Guardar aquí)` : e.nombre;
                            return `<option value="${e.id_empleado}" data-nombre="${e.nombre}">${textoNombre} (${e.depto || 'General'} - ID ${e.id_empleado})</option>`;
                        })
                        .join("");
                if (actual) selectDestino.value = actual;
            }
        } catch (e) {
            console.error("Error al cargar empleados para transferencia:", e);
        }
    }

    cargarTransferenciasRecibidos();
    cargarTransferenciasEnviados();
    cargarBadges();
}

function formatearTamanoBytes(bytes) {
    if (bytes < 1024 * 1024) {
        return (bytes / 1024).toFixed(1) + " KB";
    } else if (bytes < 1024 * 1024 * 1024) {
        return (bytes / (1024 * 1024)).toFixed(1) + " MB";
    } else {
        return (bytes / (1024 * 1024 * 1024)).toFixed(2) + " GB";
    }
}

function alSeleccionarArchivosTransferencia(input) {
    if (!input.files || input.files.length === 0) return;
    procesarNuevosArchivosTransferencia(input.files);
    input.value = ""; // Permite seleccionar los mismos archivos o más después
}

function procesarNuevosArchivosTransferencia(fileList) {
    const LIMITE_5GB = 5 * 1024 * 1024 * 1024; // 5 GB
    let totalActual = archivosTransferenciaSeleccionados.reduce((acc, f) => acc + f.size, 0);

    for (let i = 0; i < fileList.length; i++) {
        const file = fileList[i];
        if (totalActual + file.size > LIMITE_5GB) {
            alert(`⚠️ No se pudo agregar "${file.name}".\nEl tamaño combinado superaría el límite de 5.0 GB.\nTamaño actual acumulado: ${formatearTamanoBytes(totalActual)}.`);
            break;
        }
        // Evitar duplicados por nombre y tamaño exacto
        const yaExiste = archivosTransferenciaSeleccionados.some(f => f.name === file.name && f.size === file.size);
        if (!yaExiste) {
            archivosTransferenciaSeleccionados.push(file);
            totalActual += file.size;
        }
    }

    renderizarListaArchivosSeleccionados();
}

function quitarArchivoDeTransferencia(indice) {
    if (indice >= 0 && indice < archivosTransferenciaSeleccionados.length) {
        archivosTransferenciaSeleccionados.splice(indice, 1);
        renderizarListaArchivosSeleccionados();
    }
}

function limpiarArchivosTransferencia() {
    archivosTransferenciaSeleccionados = [];
    const input = document.getElementById("transfer-input-file");
    if (input) input.value = "";
    renderizarListaArchivosSeleccionados();
}

function renderizarListaArchivosSeleccionados() {
    const box = document.getElementById("transfer-archivos-seleccionados-box");
    const container = document.getElementById("transfer-lista-archivos-items");
    const lblTotal = document.getElementById("transfer-total-archivos-lbl");
    const lblPeso = document.getElementById("transfer-total-peso-lbl");

    if (!box || !container) return;

    if (archivosTransferenciaSeleccionados.length === 0) {
        box.style.display = "none";
        container.innerHTML = "";
        if (lblTotal) lblTotal.innerText = "0";
        if (lblPeso) lblPeso.innerText = "0 MB";
        return;
    }

    const totalBytes = archivosTransferenciaSeleccionados.reduce((acc, f) => acc + f.size, 0);
    if (lblTotal) lblTotal.innerText = archivosTransferenciaSeleccionados.length;
    if (lblPeso) lblPeso.innerText = formatearTamanoBytes(totalBytes);

    container.innerHTML = archivosTransferenciaSeleccionados.map((f, idx) => {
        let icono = "ph-file";
        const n = f.name.toLowerCase();
        if (n.endsWith(".mp4") || n.endsWith(".mov") || n.endsWith(".mkv") || n.endsWith(".avi")) icono = "ph-video";
        else if (n.endsWith(".jpg") || n.endsWith(".jpeg") || n.endsWith(".png") || n.endsWith(".webp")) icono = "ph-image";
        else if (n.endsWith(".zip") || n.endsWith(".rar") || n.endsWith(".7z") || n.endsWith(".tar")) icono = "ph-archive";
        else if (n.endsWith(".pdf")) icono = "ph-file-pdf";
        else if (n.endsWith(".xlsx") || n.endsWith(".xls") || n.endsWith(".csv")) icono = "ph-file-xls";

        return `
            <div style="display: flex; align-items: center; justify-content: space-between; background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 8px 12px; gap: 10px;">
                <div style="display: flex; align-items: center; gap: 10px; overflow: hidden; flex: 1;">
                    <i class="ph ${icono}" style="font-size: 20px; color: var(--accent-color); flex-shrink: 0;"></i>
                    <span style="font-weight: 600; font-size: 13px; color: #1e293b; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${f.name}">${f.name}</span>
                    <span style="background: #f1f5f9; color: #475569; padding: 2px 6px; border-radius: 4px; font-size: 11px; font-weight: 600; flex-shrink: 0;">${formatearTamanoBytes(f.size)}</span>
                </div>
                <button type="button" onclick="quitarArchivoDeTransferencia(${idx})" style="background: none; border: none; color: #ef4444; cursor: pointer; padding: 4px; border-radius: 4px; display: flex; align-items: center;" title="Quitar archivo">
                    <i class="ph ph-trash" style="font-size: 16px;"></i>
                </button>
            </div>
        `;
    }).join("");

    box.style.display = "block";
}

// Compatibilidad con llamada singular y plural
const CHUNK_SIZE_TRANSFERENCIA = 20 * 1024 * 1024; // 20 MB por bloque (100% amigable con Cloudflare)
let peticionSubidaCancelada = false;
let peticionSubidaActualUploadId = null;

function cancelarSubidaTransferenciaActual() {
    peticionSubidaCancelada = true;
    if (peticionSubidaXHR) {
        try {
            peticionSubidaXHR.abort();
        } catch (_) {}
        peticionSubidaXHR = null;
    }
    if (peticionSubidaActualUploadId) {
        try {
            fetch(`${API_URL}/api/transferencias/cancelar_chunk/${peticionSubidaActualUploadId}`, { method: 'DELETE' });
        } catch (_) {}
        peticionSubidaActualUploadId = null;
    }
    const btnEnviar = document.getElementById("btn-enviar-transferencia");
    if (btnEnviar) {
        btnEnviar.disabled = false;
        btnEnviar.innerHTML = `<i class="ph ph-paper-plane-tilt"></i> Enviar Archivo(s)`;
    }
    const progresoBox = document.getElementById("transfer-progreso-box");
    if (progresoBox) progresoBox.style.display = "none";
    alert("⚠️ Subida de archivos cancelada.");
}

function enviarTransferenciaArchivo() {
    enviarTransferenciaArchivos();
}

async function enviarTransferenciaArchivos() {
    if (!usuarioLogueado) {
        alert("Debes iniciar sesión para transferir archivos.");
        return;
    }

    const selectDestino = document.getElementById("transfer-select-destino");
    if (!selectDestino || !selectDestino.value) {
        alert("Por favor selecciona al empleado destinatario que recibirá el archivo.");
        return;
    }

    if (archivosTransferenciaSeleccionados.length === 0) {
        alert("Por favor selecciona o arrastra al menos un archivo para transferir (máximo 5.0 GB).");
        return;
    }

    const optionSel = selectDestino.options[selectDestino.selectedIndex];
    const nombreDestino = optionSel ? (optionSel.getAttribute("data-nombre") || optionSel.text) : "Destinatario";
    const mensaje = document.getElementById("transfer-input-mensaje")?.value || "";

    const btnEnviar = document.getElementById("btn-enviar-transferencia");
    const progresoBox = document.getElementById("transfer-progreso-box");
    const barraProgreso = document.getElementById("transfer-progreso-barra");
    const textoPorcentaje = document.getElementById("transfer-progreso-porcentaje");
    const textoDetalle = document.getElementById("transfer-progreso-detalle");
    const textoProgreso = document.getElementById("transfer-progreso-texto");
    const textoVel = document.getElementById("transfer-progreso-velocidad");

    if (btnEnviar) {
        btnEnviar.disabled = true;
        btnEnviar.innerHTML = `<i class="ph ph-spinner ph-spin"></i> Subiendo archivos...`;
    }
    if (progresoBox) progresoBox.style.display = "block";
    if (barraProgreso) barraProgreso.style.width = "0%";
    if (textoPorcentaje) textoPorcentaje.innerText = "0%";
    if (textoVel) textoVel.innerText = "⚡ Iniciando transferencia en bloques...";

    peticionSubidaCancelada = false;

    const formatoBytes = (b) => {
        if (b < 1024 * 1024) return (b / 1024).toFixed(1) + " KB";
        if (b < 1024 * 1024 * 1024) return (b / (1024 * 1024)).toFixed(1) + " MB";
        return (b / (1024 * 1024 * 1024)).toFixed(2) + " GB";
    };

    const totalBytesTodos = archivosTransferenciaSeleccionados.reduce((acc, f) => acc + f.size, 0);
    const totalStr = formatoBytes(totalBytesTodos);
    const folioPaquete = "TRF-" + Math.floor(Date.now() / 1000) + "-" + Math.random().toString(36).substring(2, 8).toUpperCase();
    const tiempoInicio = Date.now();
    let bytesSubidosAcumulados = 0;

    try {
        for (let fileIdx = 0; fileIdx < archivosTransferenciaSeleccionados.length; fileIdx++) {
            const file = archivosTransferenciaSeleccionados[fileIdx];
            const uploadId = "up_" + Date.now() + "_" + Math.random().toString(36).substring(2, 9);
            peticionSubidaActualUploadId = uploadId;

            const totalChunks = Math.max(1, Math.ceil(file.size / CHUNK_SIZE_TRANSFERENCIA));

            for (let chunkIdx = 0; chunkIdx < totalChunks; chunkIdx++) {
                if (peticionSubidaCancelada) return;

                const start = chunkIdx * CHUNK_SIZE_TRANSFERENCIA;
                const end = Math.min(file.size, start + CHUNK_SIZE_TRANSFERENCIA);
                const chunkBlob = file.slice(start, end);
                const chunkBytes = end - start;

                const chunkFormData = new FormData();
                chunkFormData.append("upload_id", uploadId);
                chunkFormData.append("folio_paquete", folioPaquete);
                chunkFormData.append("chunk_index", chunkIdx);
                chunkFormData.append("total_chunks", totalChunks);
                chunkFormData.append("nombre_archivo", file.name);
                chunkFormData.append("tamano_total", file.size);
                chunkFormData.append("id_empleado_origen", usuarioLogueado.id_empleado);
                chunkFormData.append("nombre_origen", usuarioLogueado.nombre_completo);
                chunkFormData.append("id_empleado_destino", selectDestino.value);
                chunkFormData.append("nombre_destino", nombreDestino);
                chunkFormData.append("mensaje", mensaje);
                chunkFormData.append("tipo_mime", file.type || "application/octet-stream");
                chunkFormData.append("chunk", chunkBlob, file.name);

                let subidaExitosa = false;
                let intentos = 0;
                while (!subidaExitosa && intentos < 3) {
                    if (peticionSubidaCancelada) return;
                    intentos++;

                    await new Promise((resolve, reject) => {
                        const xhr = new XMLHttpRequest();
                        peticionSubidaXHR = xhr;

                        xhr.upload.onprogress = function(e) {
                            if (e.lengthComputable && !peticionSubidaCancelada) {
                                const cargadoEsteBloque = e.loaded;
                                const cargadoTotalActual = bytesSubidosAcumulados + cargadoEsteBloque;
                                const pctExacto = totalBytesTodos > 0 ? (cargadoTotalActual / totalBytesTodos) * 100 : 0;
                                const pctStr = pctExacto < 10 ? pctExacto.toFixed(1) : Math.round(pctExacto);

                                if (barraProgreso) barraProgreso.style.width = Math.min(100, Math.max(0.5, pctExacto)) + "%";
                                if (textoPorcentaje) textoPorcentaje.innerText = pctStr + "%";

                                const tiempoSeg = (Date.now() - tiempoInicio) / 1000;
                                if (tiempoSeg > 0.5) {
                                    const velBps = cargadoTotalActual / tiempoSeg;
                                    const mbps = (velBps / (1024 * 1024)).toFixed(1);
                                    const bytesRestantes = Math.max(0, totalBytesTodos - cargadoTotalActual);
                                    const segRestantes = velBps > 0 ? Math.round(bytesRestantes / velBps) : 0;

                                    let etaStr = "";
                                    if (segRestantes >= 3600) {
                                        const h = Math.floor(segRestantes / 3600);
                                        const m = Math.floor((segRestantes % 3600) / 60);
                                        etaStr = `~${h}h ${m}m restantes`;
                                    } else if (segRestantes >= 60) {
                                        const m = Math.floor(segRestantes / 60);
                                        const s = segRestantes % 60;
                                        etaStr = `~${m}m ${s}s restantes`;
                                    } else {
                                        etaStr = `~${segRestantes}s restantes`;
                                    }

                                    if (textoVel) {
                                        const infoBloque = totalChunks > 1 ? ` (Bloque ${chunkIdx + 1}/${totalChunks})` : "";
                                        textoVel.innerText = pctExacto >= 100 ? "Procesando en servidor..." : `⚡ ${mbps} MB/s • ${etaStr}${infoBloque}`;
                                    }
                                }

                                if (textoDetalle) {
                                    textoDetalle.innerText = `${formatoBytes(cargadoTotalActual)} / ${totalStr}`;
                                }
                                if (textoProgreso) {
                                    textoProgreso.innerText = pctExacto >= 100 
                                        ? "Procesando y registrando en servidor..." 
                                        : `Subiendo archivo(s): ${pctStr}%`;
                                }
                            }
                        };

                        xhr.onload = function() {
                            peticionSubidaXHR = null;
                            if (xhr.status === 200) {
                                subidaExitosa = true;
                                resolve();
                            } else {
                                let errDetail = `Error ${xhr.status}`;
                                try {
                                    const errObj = JSON.parse(xhr.responseText);
                                    errDetail = errObj.detail || errDetail;
                                } catch (_) {}
                                reject(new Error(errDetail));
                            }
                        };

                        xhr.onerror = function() {
                            peticionSubidaXHR = null;
                            reject(new Error("Error de conexión durante el bloque"));
                        };

                        xhr.onabort = function() {
                            peticionSubidaXHR = null;
                            reject(new Error("ABORTADO"));
                        };

                        xhr.open("POST", `${API_URL}/api/transferencias/subir_chunk`, true);
                        xhr.send(chunkFormData);
                    }).catch(err => {
                        if (err.message === "ABORTADO" || peticionSubidaCancelada) return;
                        if (intentos >= 3) throw err;
                    });
                }

                if (!subidaExitosa && !peticionSubidaCancelada) {
                    throw new Error(`No se pudo subir el bloque ${chunkIdx + 1} de ${file.name}`);
                }

                bytesSubidosAcumulados += chunkBytes;
            }
        }

        if (peticionSubidaCancelada) return;

        const cantArchivos = archivosTransferenciaSeleccionados.length;
        const descArchivos = cantArchivos > 1 
            ? `${cantArchivos} archivos (${totalStr})` 
            : `"${archivosTransferenciaSeleccionados[0].name}" (${totalStr})`;

        alert(`✅ ¡Transferencia completada con éxito por bloques!

Se envió ${descArchivos} a ${nombreDestino}.
El destinatario ya puede ver la notificación para descargarlo.`);

        limpiarArchivosTransferencia();
        if (document.getElementById("transfer-input-mensaje")) {
            document.getElementById("transfer-input-mensaje").value = "";
        }
        if (progresoBox) progresoBox.style.display = "none";

        cambiarPestanaTransferencias("enviados");
        cargarTransferenciasRecibidos();
        cargarDatosInicio();
        cargarBadges();

    } catch (e) {
        if (peticionSubidaCancelada || e.message === "ABORTADO") return;
        alert(`❌ Error al subir archivo(s): ${e.message}`);
        if (progresoBox) progresoBox.style.display = "none";
    } finally {
        peticionSubidaActualUploadId = null;
        if (btnEnviar) {
            btnEnviar.disabled = false;
            btnEnviar.innerHTML = `<i class="ph ph-paper-plane-tilt"></i> Enviar Archivo(s)`;
        }
    }
}

let cacheTransferenciasRecibidos = [];
let cacheTransferenciasEnviados = [];

function filtrarTransferencias(tipo) {
    if (tipo === 'recibidos') {
        const input = document.getElementById("transfer-buscar-recibidos");
        const query = (input ? input.value : "").trim().toLowerCase();
        const lbl = document.getElementById("transfer-contador-recibidos");
        let filtrados = cacheTransferenciasRecibidos;
        if (query) {
            filtrados = cacheTransferenciasRecibidos.filter(r => 
                (r.nombre_archivo_original || "").toLowerCase().includes(query) ||
                (r.nombre_origen || "").toLowerCase().includes(query) ||
                (r.folio_paquete || "").toLowerCase().includes(query) ||
                (r.mensaje || "").toLowerCase().includes(query)
            );
        }
        if (lbl) {
            lbl.innerText = query 
                ? `${filtrados.length} de ${cacheTransferenciasRecibidos.length} archivos`
                : `${cacheTransferenciasRecibidos.length} archivos recibidos`;
        }
        renderizarFilasTransferenciasRecibidos(filtrados);
    } else if (tipo === 'enviados') {
        const input = document.getElementById("transfer-buscar-enviados");
        const query = (input ? input.value : "").trim().toLowerCase();
        const lbl = document.getElementById("transfer-contador-enviados");
        let filtrados = cacheTransferenciasEnviados;
        if (query) {
            filtrados = cacheTransferenciasEnviados.filter(e => 
                (e.nombre_archivo_original || "").toLowerCase().includes(query) ||
                (e.nombre_destino || "").toLowerCase().includes(query) ||
                (e.folio_paquete || "").toLowerCase().includes(query) ||
                (e.mensaje || "").toLowerCase().includes(query)
            );
        }
        if (lbl) {
            lbl.innerText = query 
                ? `${filtrados.length} de ${cacheTransferenciasEnviados.length} archivos`
                : `${cacheTransferenciasEnviados.length} archivos enviados`;
        }
        renderizarFilasTransferenciasEnviados(filtrados);
    }
}

function renderizarFilasTransferenciasRecibidos(recibidos) {
    const tbody = document.getElementById("tabla-transfer-recibidos-body");
    if (!tbody) return;

    if (!recibidos || recibidos.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #94a3b8; padding: 32px;">📭 No hay archivos compartidos recibidos que coincidan.</td></tr>';
        return;
    }

    tbody.innerHTML = recibidos.map(item => {
        let estatusBadge = "";
        let btnDescarga = "";

        if (!item.descargado) {
            estatusBadge = `
                <span style="background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; padding: 4px 10px; border-radius: 6px; font-weight: 700; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;">
                    <i class="ph ph-sparkle"></i> Nuevo (Sin descargar)
                </span>
                <div style="font-size: 11px; color: #64748b; margin-top: 3px;">Se iniciará cuenta de 24h al descargar</div>
            `;
            btnDescarga = `
                <div style="display: flex; gap: 6px; justify-content: center; flex-wrap: wrap;">
                    <button onclick="descargarArchivoTransferenciaDirecto(${item.id_transferencia}, '${(item.nombre_archivo_original || '').replace(/'/g, "\\'")}')" style="background: #2563eb; color: white; border: none; padding: 8px 14px; border-radius: 6px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; font-size: 13px;">
                        <i class="ph ph-download-simple"></i> Descargar
                    </button>
                    ${item.folio_paquete ? `
                    <button onclick="descargarPaqueteZip('${item.folio_paquete}')" style="background: #0284c7; color: white; border: none; padding: 8px 10px; border-radius: 6px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; font-size: 12px;" title="Descargar paquete completo en ZIP">
                        <i class="ph ph-file-zip"></i> ZIP Paquete
                    </button>` : ''}
                </div>
            `;
        } else {
            estatusBadge = `
                <span style="background: #fffbeb; color: #b45309; border: 1px solid #fde68a; padding: 4px 10px; border-radius: 6px; font-weight: 700; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;">
                    <i class="ph ph-clock-countdown"></i> ${item.tiempo_restante_texto}
                </span>
                <div style="font-size: 11px; color: #d97706; margin-top: 3px;">Descargado ${item.veces_descargado || 1} vez(ces)</div>
            `;
            btnDescarga = `
                <div style="display: flex; gap: 6px; justify-content: center; flex-wrap: wrap;">
                    <button onclick="descargarArchivoTransferenciaDirecto(${item.id_transferencia}, '${(item.nombre_archivo_original || '').replace(/'/g, "\\'")}')" style="background: #0284c7; color: white; border: none; padding: 7px 12px; border-radius: 6px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; font-size: 12px;">
                        <i class="ph ph-arrow-counter-clockwise"></i> Re-descargar
                    </button>
                    ${item.folio_paquete ? `
                    <button onclick="descargarPaqueteZip('${item.folio_paquete}')" style="background: #475569; color: white; border: none; padding: 7px 10px; border-radius: 6px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; font-size: 11.5px;" title="Descargar paquete completo en ZIP">
                        <i class="ph ph-file-zip"></i> ZIP
                    </button>` : ''}
                </div>
            `;
        }

        return `
            <tr>
                <td style="font-weight: 600; color: #0f172a;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <div style="width: 32px; height: 32px; border-radius: 50%; background: #e0e7ff; color: #4338ca; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 12px;">
                            ${(item.nombre_origen || 'U').charAt(0).toUpperCase()}
                        </div>
                        <div>
                            <div>${item.nombre_origen}</div>
                            <span style="font-size: 11px; color: #64748b;">ID: ${item.id_empleado_origen}</span>
                        </div>
                    </div>
                </td>
                <td style="font-weight: 600; color: #1e3a8a; max-width: 250px; word-break: break-all;">
                    <i class="ph ph-file-text" style="color: #3b82f6; margin-right: 4px;"></i>
                    ${item.nombre_archivo_original}
                    ${item.folio_paquete ? `<div style="font-size: 10.5px; color: #6366f1; font-weight: 500;"><i class="ph ph-package"></i> Paquete: ${item.folio_paquete}</div>` : ''}
                </td>
                <td style="white-space: nowrap;"><span style="background: #f1f5f9; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: 600; color: #334155;">${item.tamano_legible}</span></td>
                <td style="font-size: 12.5px; color: #475569; white-space: nowrap;">${item.fecha_subida_str || ''}</td>
                <td style="font-size: 12.5px; color: #475569; max-width: 220px;">${item.mensaje ? `"${item.mensaje}"` : '<span style="color:#cbd5e1;">Sin notas</span>'}</td>
                <td>${estatusBadge}</td>
                <td style="text-align: center; white-space: nowrap;">${btnDescarga}</td>
            </tr>
        `;
    }).join("");
}

function renderizarFilasTransferenciasEnviados(enviados) {
    const tbody = document.getElementById("tabla-transfer-enviados-body");
    if (!tbody) return;

    if (!enviados || enviados.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #94a3b8; padding: 32px;">No has enviado archivos recientemente o no hay coincidencias.</td></tr>';
        return;
    }

    tbody.innerHTML = enviados.map(item => {
        const puedeEliminar = item.estatus !== 'EXPIRADO_BORRADO' && item.estatus !== 'CANCELADO';
        const btnAccion = puedeEliminar ? `
            <button onclick="eliminarTransferencia(${item.id_transferencia})" style="background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; padding: 5px 12px; border-radius: 6px; font-weight: 600; cursor: pointer; font-size: 12px;" title="Eliminar archivo del servidor">
                <i class="ph ph-trash"></i> Cancelar / Borrar
            </button>
        ` : `<span style="font-size: 12px; color: #94a3b8;">Finalizado</span>`;

        return `
            <tr>
                <td style="font-weight: 600; color: #0f172a;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <div style="width: 32px; height: 32px; border-radius: 50%; background: #f1f5f9; color: #475569; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 12px;">
                            ${(item.nombre_destino || 'U').charAt(0).toUpperCase()}
                        </div>
                        <div>
                            <div>${item.nombre_destino}</div>
                            <span style="font-size: 11px; color: #64748b;">ID: ${item.id_empleado_destino}</span>
                        </div>
                    </div>
                </td>
                <td style="font-weight: 600; color: #1e3a8a; max-width: 250px; word-break: break-all;">
                    <i class="ph ph-file" style="color: #64748b; margin-right: 4px;"></i>
                    ${item.nombre_archivo_original}
                    ${item.folio_paquete ? `<div style="font-size: 10.5px; color: #6366f1; font-weight: 500;"><i class="ph ph-package"></i> Paquete: ${item.folio_paquete}</div>` : ''}
                </td>
                <td style="white-space: nowrap;"><span style="background: #f1f5f9; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: 600; color: #334155;">${item.tamano_legible}</span></td>
                <td style="font-size: 12.5px; color: #475569; white-space: nowrap;">${item.fecha_subida_str || ''}</td>
                <td style="font-size: 12.5px; color: #475569; max-width: 220px;">${item.mensaje ? `"${item.mensaje}"` : '<span style="color:#cbd5e1;">Sin notas</span>'}</td>
                <td>
                    <span style="font-size: 12.5px; font-weight: 600; color: #334155;">
                        ${item.estado_display}
                    </span>
                </td>
                <td style="text-align: center; white-space: nowrap;">${btnAccion}</td>
            </tr>
        `;
    }).join("");
}

async function cargarTransferenciasRecibidos() {
    if (!usuarioLogueado) return;
    const tbody = document.getElementById("tabla-transfer-recibidos-body");
    if (!tbody) return;

    try {
        const res = await fetch(`${API_URL}/api/transferencias/recibidos/${usuarioLogueado.id_empleado}`);
        if (!res.ok) {
            tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #ef4444; padding: 24px;">Error al consultar archivos recibidos.</td></tr>';
            return;
        }

        const recibidos = await res.json();
        cacheTransferenciasRecibidos = Array.isArray(recibidos) ? recibidos : [];
        const badgeCount = document.getElementById("badge-transfer-recibidos-count");
        const noDescargados = cacheTransferenciasRecibidos.filter(r => !r.descargado);
        if (badgeCount) {
            if (noDescargados.length > 0) {
                badgeCount.innerText = noDescargados.length;
                badgeCount.style.display = "inline-block";
            } else {
                badgeCount.style.display = "none";
            }
        }

        filtrarTransferencias('recibidos');
    } catch (e) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #ef4444; padding: 24px;">Error al cargar archivos recibidos.</td></tr>';
    }
}

async function cargarTransferenciasEnviados() {
    if (!usuarioLogueado) return;
    const tbody = document.getElementById("tabla-transfer-enviados-body");
    if (!tbody) return;

    try {
        const res = await fetch(`${API_URL}/api/transferencias/enviados/${usuarioLogueado.id_empleado}`);
        if (!res.ok) {
            tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #ef4444; padding: 24px;">Error al consultar archivos enviados.</td></tr>';
            return;
        }

        const enviados = await res.json();
        cacheTransferenciasEnviados = Array.isArray(enviados) ? enviados : [];
        filtrarTransferencias('enviados');
    } catch (e) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #ef4444; padding: 24px;">Error al cargar archivos enviados.</td></tr>';
    }
}


let timerRecargaTransferencias = null;
function programarRecargaTransferencias(delay = 2000) {
    if (timerRecargaTransferencias) clearTimeout(timerRecargaTransferencias);
    timerRecargaTransferencias = setTimeout(() => {
        cargarTransferenciasRecibidos();
        cargarDatosInicio();
        cargarBadges();
    }, delay);
}

function descargarPaqueteZip(folioPaquete) {
    if (!folioPaquete) return;
    const urlDescarga = `${API_URL}/api/transferencias/descargar_paquete/${folioPaquete}`;
    
    const a = document.createElement("a");
    a.href = urlDescarga;
    a.setAttribute("download", `paquete_${folioPaquete}.zip`);
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);

    programarRecargaTransferencias(2000);
}

function descargarArchivoTransferenciaDirecto(idTransferencia, nombreArchivo = "") {
    const urlDescarga = `${API_URL}/api/transferencias/descargar/${idTransferencia}`;
    
    const a = document.createElement("a");
    a.href = urlDescarga;
    a.setAttribute("download", nombreArchivo || "archivo");
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);

    programarRecargaTransferencias(2000);
}

async function eliminarTransferencia(idTransferencia) {
    if (!confirm("¿Deseas cancelar esta transferencia y borrar el archivo físico del servidor ahora mismo?")) {
        return;
    }
    try {
        const res = await fetch(`${API_URL}/api/transferencias/eliminar/${idTransferencia}`, {
            method: 'DELETE'
        });
        if (res.ok) {
            cargarTransferenciasEnviados();
            cargarTransferenciasRecibidos();
            cargarDatosInicio();
            cargarBadges();
        } else {
            alert("No se pudo eliminar la transferencia.");
        }
    } catch (e) {
        alert("Error de conexión al eliminar transferencia.");
    }
}

async function cargarHistorialTransferencias() {
    if (!usuarioLogueado) return;
    const tbody = document.getElementById("tabla-transfer-historial-body");
    if (!tbody) return;

    try {
        const res = await fetch(`${API_URL}/api/transferencias/historial/${usuarioLogueado.id_empleado}`);
        if (!res.ok) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #ef4444; padding: 24px;">Error al consultar el historial.</td></tr>';
            return;
        }

        const historial = await res.json();
        if (!historial || historial.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #94a3b8; padding: 32px;">No hay historial de transferencias.</td></tr>';
            return;
        }

        tbody.innerHTML = historial.map(item => {
            const esEnvio = item.tipo === 'ENVIADO';
            const iconoTipo = esEnvio ? '<i class="ph ph-arrow-up-right" style="color: #10b981;"></i>' : '<i class="ph ph-arrow-down-left" style="color: #3b82f6;"></i>';
            const colorTipo = esEnvio ? '#10b981' : '#3b82f6';
            const dePara = esEnvio ? `Para: ${item.nombre_destino}` : `De: ${item.nombre_origen}`;
            const infoRed = item.red_info === 'LAN' ? '<span style="background: #dcfce7; color: #166534; padding: 2px 6px; border-radius: 4px; font-size: 11px; font-weight: bold;">LAN</span>' : '<span style="background: #fef08a; color: #854d0e; padding: 2px 6px; border-radius: 4px; font-size: 11px; font-weight: bold;">EXTERNO</span>';

            return `
                <tr>
                    <td style="font-weight: 600; color: ${colorTipo}; font-size: 13px;">
                        ${iconoTipo} ${item.tipo}
                    </td>
                    <td style="font-weight: 600; color: #0f172a; font-size: 13px;">
                        ${dePara}
                    </td>
                    <td style="font-weight: 600; color: #1e3a8a; max-width: 250px; word-break: break-all; font-size: 13px;">
                        <i class="ph ph-file" style="color: #64748b; margin-right: 4px;"></i>
                        ${item.nombre_archivo_original}
                    </td>
                    <td style="white-space: nowrap;"><span style="background: #f1f5f9; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: 600; color: #334155;">${item.tamano_legible}</span></td>
                    <td style="font-size: 12.5px; color: #475569; white-space: nowrap;">${item.fecha_subida_str || ''}</td>
                    <td style="text-align: center;">${infoRed}</td>
                </tr>
            `;
        }).join("");

    } catch (e) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #ef4444; padding: 24px;">Error al cargar el historial.</td></tr>';
    }
}

