// ==============================================================================
// MÓDULO: cotizaciones.js
// Cotizaciones VPF-PSC-COT
// Líneas originales: 14249–14601 de script.js
// ==============================================================================

// ==========================================
// MÓDULO DE COTIZACIONES (VPF-PSC-COT)
// ==========================================
let clientesCotizacion = [];

async function inicializarModuloCotizaciones() {
    // 1. Cargar catálogo de clientes
    try {
        const res = await fetch(`${API_URL}/api/clientes/catalogo`);
        if (res.ok) {
            clientesCotizacion = await res.json();
            const selectCliente = document.getElementById("cot-cliente");
            if (selectCliente) {
                selectCliente.innerHTML = '<option value="">--- Selecciona un Cliente ---</option>' + 
                    clientesCotizacion.map(c => `<option value="${c}">${c}</option>`).join("");
            }
        }
    } catch (e) {
        console.error("Error al cargar clientes:", e);
    }

    // 2. Fecha por defecto (hoy)
    document.getElementById("cot-fecha").valueAsDate = new Date();

    // 3. Inicializar con una fila vacía
    document.getElementById("cot-tabla-body").innerHTML = "";
    agregarFilaCotizacion();
}

async function cargarContactosCotizacion() {
    const nombreCliente = document.getElementById("cot-cliente").value;
    const selectContacto = document.getElementById("cot-contacto");
    
    // Si no hay contacto select (quizas no está en el HTML) ignoramos
    if (!selectContacto) return;

    selectContacto.innerHTML = '<option value="">--- Selecciona un Contacto ---</option>';
    
    if (!nombreCliente) return;

    try {
        const res = await fetch(`${API_URL}/api/clientes/contactos/${encodeURIComponent(nombreCliente)}`);
        if (res.ok) {
            const contactos = await res.json();
            if (contactos.length > 0) {
                selectContacto.innerHTML += contactos.map(c => `<option value="${c}">${c}</option>`).join("");
            }
        }
    } catch (e) {
        console.error("Error al cargar contactos:", e);
    }
}

function agregarFilaCotizacion() {
    const tbody = document.getElementById("cot-tabla-body");
    const tr = document.createElement("tr");
    tr.className = "fila-cot";
    tr.innerHTML = `
        <td><input type="number" class="form-input cot-cant" style="text-align: center; font-size: 13px;" value="1" min="1" onchange="calcularTotalesCotizacion()" onkeyup="calcularTotalesCotizacion()"></td>
        <td><input type="text" class="form-input cot-desc" style="font-size: 13px;" placeholder="Descripción del servicio o equipo..."></td>
        <td><input type="number" class="form-input cot-precio" style="text-align: right; font-size: 13px;" value="0.00" min="0" step="100" onchange="calcularTotalesCotizacion()" onkeyup="calcularTotalesCotizacion()"></td>
        <td style="text-align: right; font-weight: 600; color: #0f172a;" class="cot-importe">$0.00</td>
        <td style="text-align: center;">
            <button type="button" onclick="this.closest('tr').remove(); calcularTotalesCotizacion();" style="background: #fee2e2; color: #dc2626; border: none; padding: 6px; border-radius: 6px; cursor: pointer;"><i class="ph ph-trash"></i></button>
        </td>
    `;
    tbody.appendChild(tr);
    calcularTotalesCotizacion();
}

function calcularTotalesCotizacion() {
    let subtotal = 0;
    document.querySelectorAll(".fila-cot").forEach(tr => {
        const cant = parseFloat(tr.querySelector(".cot-cant").value) || 0;
        const precio = parseFloat(tr.querySelector(".cot-precio").value) || 0;
        const importe = cant * precio;
        tr.querySelector(".cot-importe").innerText = "$" + importe.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        subtotal += importe;
    });

    const iva = subtotal * 0.16;
    const total = subtotal + iva;

    document.getElementById("cot-subtotal").innerText = "$" + subtotal.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
    document.getElementById("cot-iva").innerText = "$" + iva.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
    document.getElementById("cot-total").innerText = "$" + total.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
}

async function generarCotizacionPDF() {
    const btn = document.getElementById("btn-descargar-cotizacion");
    
    // Recopilar datos
    const selectC = document.getElementById("cot-cliente");
    const empresa = selectC.options[selectC.selectedIndex]?.text;
    const selectCont = document.getElementById("cot-contacto");
    const contacto = selectCont.options[selectCont.selectedIndex]?.text || selectCont.value;

    if (!selectC.value || empresa === "--- Selecciona un Cliente ---") {
        alert("⚠️ Por favor selecciona un Cliente/Empresa.");
        return;
    }

    const items = [];
    let subtotal = 0;
    document.querySelectorAll(".fila-cot").forEach(tr => {
        const cant = parseFloat(tr.querySelector(".cot-cant").value) || 0;
        const desc = tr.querySelector(".cot-desc").value.trim();
        const precio = parseFloat(tr.querySelector(".cot-precio").value) || 0;
        if (cant > 0 && precio > 0 && desc) {
            const imp = cant * precio;
            items.push({ cantidad: cant, concepto: desc, precio_unitario: precio, importe: imp });
            subtotal += imp;
        }
    });

    if (items.length === 0) {
        alert("⚠️ Por favor agrega al menos un concepto con cantidad, descripción y precio.");
        return;
    }

    const iva = subtotal * 0.16;
    const data = {
        empresa: empresa,
        contacto: contacto,
        departamento: document.getElementById("cot-depto").value,
        fecha: document.getElementById("cot-fecha").value,
        introduccion: document.getElementById("cot-intro").value,
        tecnica: document.getElementById("cot-tecnica").value,
        entregables: document.getElementById("cot-entregables").value,
        items: items,
        subtotal: subtotal,
        iva: iva,
        total: subtotal + iva,
        politicas: document.getElementById("cot-politicas").value
    };

    try {
        btn.innerHTML = '<i class="ph ph-spinner ph-spin"></i> GENERANDO PDF...';
        btn.style.opacity = '0.7';
        btn.disabled = true;

        const res = await fetch(`${API_URL}/api/cotizaciones/generar_pdf`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });

        if (!res.ok) {
            const err = await res.json();
            throw new Error(err.detail || "Error al generar PDF");
        }

        // Descargar el archivo
        const blob = await res.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = `Cotizacion_VPRO_${empresa.replace(/\\s+/g, '_')}.pdf`;
        document.body.appendChild(a);
        a.click();
        a.remove();
        window.URL.revokeObjectURL(url);

    } catch (e) {
        alert("❌ Error: " + e.message);
    } finally {
        btn.innerHTML = '<i class="ph ph-download-simple"></i> DESCARGAR COTIZACIÓN EN PDF';
        btn.style.opacity = '1';
        btn.disabled = false;
    }
}
async function abrirModalVincularCotizacionDesdeGastos() {
    if (!window.eventoActualVincular) {
        alert("Error: No se pudo identificar el evento actual (OP).");
        return;
    }
    document.getElementById("modal-vincular-cotizacion").style.display = "flex";
    const select = document.getElementById("select-cotizacion-vincular");
    select.innerHTML = '<option value="">Cargando cotizaciones...</option>';
    try {
        const res = await fetch(`${API_URL}/api/cotizaciones/lista`);
        if (res.ok) {
            const cotizaciones = await res.json();
            if (cotizaciones.length > 0) {
                select.innerHTML = '<option value="">-- Seleccione una Cotización --</option>' + 
                    cotizaciones.map(c => `<option value="${c.id_cotizacion}">${c.folio} - ${c.cliente} | Contacto: ${c.contacto || 'N/A'} | Fecha: ${c.fecha || 'N/A'} | Importe: $${(c.total||0).toLocaleString('en-US', {minimumFractionDigits: 2})}</option>`).join("");
            } else {
                select.innerHTML = '<option value="">No hay cotizaciones disponibles</option>';
            }
        }
    } catch (e) {
        console.error("Error al cargar cotizaciones:", e);
        select.innerHTML = '<option value="">Error al cargar</option>';
    }
}

async function guardarVinculoCotizacion() {
    const idCotizacion = document.getElementById("select-cotizacion-vincular").value;
    const idEvento = window.eventoActualVincular;
    if (!idCotizacion || !idEvento) {
        alert("Por favor seleccione una cotización.");
        return;
    }
    
    try {
        const res = await fetch(`${API_URL}/api/eventos/${idEvento}/vincular_cotizacion`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id_cotizacion: parseInt(idCotizacion) })
        });
        
        if (res.ok) {
            alert("Cotización vinculada correctamente a la OP.");
            document.getElementById("modal-vincular-cotizacion").style.display = "none";
        } else {
            const data = await res.json();
            alert("Error al vincular: " + (data.detail || "Error desconocido"));
        }
    } catch (e) {
        console.error(e);
        alert("Error de red al vincular cotización.");
    }
}

let memoriaHistorialCotizaciones = [];

async function cargarHistorialCotizacionesCatalogo() {
    try {
        const res = await fetch(`${API_URL}/api/cotizaciones/lista`);
        if (!res.ok) throw new Error("Error fetching cotizaciones");
        const data = await res.json();
        memoriaHistorialCotizaciones = data;
        renderTablaCotizacionesBoveda();
    } catch (e) {
        console.error(e);
        document.getElementById('tbody-cotizaciones-boveda').innerHTML = '<tr><td colspan="6" class="td-error">Error al cargar Bóveda</td></tr>';
    }
}

function renderTablaCotizacionesBoveda() {
    const tbody = document.getElementById('tbody-cotizaciones-boveda');
    if (!tbody) return;
    tbody.innerHTML = '';
    const filtro = (document.getElementById('filtro-cotizaciones')?.value || '').toLowerCase();
    
    const filtrados = memoriaHistorialCotizaciones.filter(c => {
        const str = `${c.folio || ''} ${c.cliente || ''} ${c.contacto || ''}`.toLowerCase();
        return str.includes(filtro);
    });

    if (filtrados.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center;">No hay cotizaciones</td></tr>';
        return;
    }

    filtrados.forEach(c => {
        const tr = document.createElement('tr');
        const pdfUrl = c.archivo_pdf ? `${API_URL}${c.archivo_pdf}` : '#';
        const pdfBtn = c.archivo_pdf ? `<a href="${pdfUrl}" target="_blank" style="color: #ef4444; text-decoration: none;" title="Descargar PDF">📄</a>` : '';
        
        tr.innerHTML = `
            <td style="font-weight: bold;">${c.folio}</td>
            <td>${c.cliente || ''}</td>
            <td>${c.contacto || ''}</td>
            <td>${c.fecha || ''}</td>
            <td>$${(c.total || 0).toLocaleString('en-US', {minimumFractionDigits: 2})}</td>
            <td style="display:flex; gap:10px;">
                ${pdfBtn}
                <button onclick="cargarCotizacionParaEdicion(${c.id_cotizacion})" style="background: none; border: none; cursor: pointer; color: #3b82f6;" title="Cargar a formulario">✏️</button>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

function filtrarTablaCotizacionesBoveda() {
    renderTablaCotizacionesBoveda();
}

async function cargarCotizacionParaEdicion(idCotizacion) {
    if (!confirm("Esto reemplazará los datos actuales en el formulario de cotizaciones. ¿Deseas continuar?")) return;
    try {
        const res = await fetch(`${API_URL}/api/cotizaciones/${idCotizacion}`);
        if (!res.ok) throw new Error("Error fetching");
        const data = await res.json();
        
        if (!data.datos_json) {
            alert("Esta cotización no tiene datos_json guardados. (Versión antigua)");
            return;
        }

        const j = data.datos_json;
        
        // Función helper para asegurar que la opción exista en el select
        const setSelectValue = (id, val) => {
            if (!val) return;
            const select = document.getElementById(id);
            if (select) {
                if (!Array.from(select.options).some(opt => opt.value === val)) {
                    const opt = document.createElement('option');
                    opt.value = val;
                    opt.text = val;
                    select.add(opt);
                }
                select.value = val;
            }
        };

        // Llenar formulario
        if (document.getElementById('cot-fecha')) document.getElementById('cot-fecha').value = j.fecha || '';
        setSelectValue('cot-cliente', j.empresa);
        setSelectValue('cot-contacto', j.contacto);
        if (document.getElementById('cot-depto')) document.getElementById('cot-depto').value = j.departamento || '';
        if (document.getElementById('cot-intro')) document.getElementById('cot-intro').value = j.introduccion || '';
        if (document.getElementById('cot-tecnica')) document.getElementById('cot-tecnica').value = j.tecnica || '';
        if (document.getElementById('cot-entregables')) document.getElementById('cot-entregables').value = j.entregables || '';
        if (document.getElementById('cot-politicas')) document.getElementById('cot-politicas').value = j.politicas || '';

        // Llenar tabla dynamic
        const tbody = document.getElementById('cot-tabla-body');
        if (tbody) {
            tbody.innerHTML = ''; // Limpiar
            if (j.items && j.items.length > 0) {
                j.items.forEach(it => {
                    const tr = document.createElement('tr');
                    tr.className = "fila-cot";
                    tr.innerHTML = `
                        <td><input type="number" class="form-input cot-cant" style="text-align: center; font-size: 13px;" value="${it.cantidad || 1}" min="1" onchange="calcularTotalesCotizacion()" onkeyup="calcularTotalesCotizacion()"></td>
                        <td><input type="text" class="form-input cot-desc" style="font-size: 13px;" placeholder="Descripción del servicio o equipo..." value="${it.concepto || ''}"></td>
                        <td><input type="number" class="form-input cot-precio" style="text-align: right; font-size: 13px;" value="${it.precio_unitario || 0}" min="0" step="100" onchange="calcularTotalesCotizacion()" onkeyup="calcularTotalesCotizacion()"></td>
                        <td style="text-align: right; font-weight: 600; color: #0f172a;" class="cot-importe">$0.00</td>
                        <td style="text-align: center;">
                            <button type="button" onclick="this.closest('tr').remove(); calcularTotalesCotizacion();" style="background: #fee2e2; color: #dc2626; border: none; padding: 6px; border-radius: 6px; cursor: pointer;"><i class="ph ph-trash"></i></button>
                        </td>
                    `;
                    tbody.appendChild(tr);
                });
            } else {
                agregarFilaCotizacion();
            }
        }
        
        if (typeof calcularTotalesCotizacion === 'function') {
            calcularTotalesCotizacion();
        }
        
        window._preventCotizacionesInit = true;
        cambiarVista('vista-cotizaciones');
    } catch (e) {
        console.error(e);
        alert("Error al cargar la cotización para edición.");
    }
}
