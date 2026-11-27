// ==============================================================================
// MÓDULO: manual.js
// 10. Sistema de Ayuda Contextual, Guías por Rol y Buscador Rápido (Fase 4)
// ==============================================================================

const GUIA_MODULOS_VPRO = {
    "vista-inicio": {
        titulo: "🏠 Panel de Inicio y Asistencia",
        roles: ["ALL"],
        keywords: "inicio asistencia checadas permisos aclaracion notificaciones",
        resumen: "Tu resumen diario: avisos pendientes, historial de los últimos 7 días y solicitudes.",
        pasos: [
            "Revisa arriba tus <b>Pendientes de Atención</b> (transferencias, equipo por entregar, permisos en revisión).",
            "En <b>Mi Asistencia Reciente (Últimos 7 Días)</b> siempre verás el día de <b>HOY</b> hasta arriba.",
            "¿Se te pasó checar o hubo error de lectura? Usa el botón <b>📝 Solicitar Aclaración de Checada</b> para enviarlo directo a RRHH.",
            "Para pedir permisos o vacaciones, usa los accesos rápidos o el módulo de RRHH."
        ],
        tip: "Si tuviste mañana libre autorizada por OP vespertina, la entrada matutina aparece en blanco sin marcar error."
    },
    "vista-checador": {
        titulo: "⏱️ Reloj Checador / Kiosco QR",
        roles: ["ALL"],
        keywords: "kiosco checador qr gafete retardo comida tolerancia",
        resumen: "Registro de 4 marcas diarias: Entrada Matutina, Salida a Comer, Entrada Vespertina y Salida.",
        pasos: [
            "Pasa tu código QR frente al lector (espera el sonido de confirmación y el mensaje verde).",
            "<b>Tolerancia oficial:</b> 10 minutos sobre la hora de entrada (09:00 o la hora de llamado de tu OP).",
            "Si olvidas checar tu salida a comer (14:00) y regresas en la tarde, el sistema auto-regulariza tu salida a las 14:00.",
            "En la pestaña <b>Mi Credencial</b> puedes consultar o descargar tu gafete QR."
        ],
        tip: "Solo usuarios con rol ADMIN pueden ver la pestaña 'Consulta y Auditoría de Asistencia'."
    },
    "vista-eventos": {
        titulo: "🎬 Órdenes de Producción (OPs)",
        roles: ["ADMIN", "COORDINADOR", "PRODUCTOR"],
        keywords: "op evento llamado detalle instalacion traslape conflicto",
        resumen: "Planeación de eventos, asignación de personal, vehículos, llamados y seguimiento.",
        pasos: [
            "Captura Cliente, Nombre del Evento, Locación, Fechas y Productor Responsable.",
            "Selecciona el <b>Personal Convocado</b> y los <b>Vehículos</b>. Al guardar, el sistema te alertará si alguien ya tiene otra OP en esas fechas.",
            "En <b>Detalle de Llamado</b> escribe horarios claros por área o persona (ej. <i>Estudio: 15:00 | Cancha: 10:00</i>) para que el Checador evalúe puntualidad exacta.",
            "Usa la pestaña de impresión para generar el PDF oficial de la OP."
        ],
        tip: "El Productor asignado es quien queda habilitado para comprobar los gastos de esa OP."
    },
    "vista-checkout": {
        titulo: "📦 Checkout y Retorno de Equipo",
        roles: ["ALL"],
        keywords: "checkout bodega salida retorno equipo incidencias dano",
        resumen: "Control de salida de hardware a locación y revisión al regresar a bodega.",
        pasos: [
            "<b>Salida:</b> Selecciona la OP, agrega los equipos/kits que salen y confirma el despacho.",
            "<b>Retorno:</b> Al volver de evento, marca cada equipo cotejado y reporta si hubo fallas o daños.",
            "<b>Importante:</b> Todos los convocados con equipo asignado deben cerrar sus incidencias en bodega para liberar el Reporte de Gastos."
        ],
        tip: "Si un equipo regresa con falla, genera automáticamente un ticket en el Taller de Mantenimiento."
    },
    "vista-gastos": {
        titulo: "🧾 Reporte de Gastos y Viáticos",
        roles: ["ADMIN", "PRODUCTOR", "COORDINADOR"],
        keywords: "gastos viaticos facturas tickets kilometraje auditoria",
        resumen: "Comprobación de viáticos, casetas, gasolina y cierre financiero por OP.",
        pasos: [
            "Selecciona la OP pendiente (solo se habilita cuando no hay incidencias de equipo sin reportar).",
            "Registra el vehículo, kilometraje inicial/final y sube cada concepto con su ticket o factura.",
            "Envía el informe para que Dirección/Auditoría lo revise y apruebe."
        ],
        tip: "Puedes vincular una cotización previa desde el modal para comparar presupuesto vs gasto real."
    },
    "vista-cotizaciones": {
        titulo: "💼 Cotizaciones",
        roles: ["ADMIN", "COORDINADOR", "PRODUCTOR"],
        keywords: "cotizacion pdf convertir op cliente presupuesto",
        resumen: "Generación de presupuestos en PDF, historial y conversión directa a OP.",
        pasos: [
            "Elige el cliente, contacto y agrega las partidas/servicios con cantidad y precio.",
            "Presiona <b>Generar PDF</b> para guardar en Bóveda y descargar el documento.",
            "En el historial puedes usar <b>✏️ Editar</b> o <b>🚀 A OP</b> para convertir una cotización aprobada en Orden de Producción en 1 clic."
        ],
        tip: "La conversión a OP pre-llena cliente, proyecto, fecha y resumen de conceptos automáticamente."
    },
    "vista-rh": {
        titulo: "👥 Recursos Humanos (RRHH)",
        roles: ["ADMIN", "RRHH"],
        keywords: "rrhh expediente vacaciones permisos incapacidades ocr",
        resumen: "Expedientes digitales, lectura OCR de documentos, permisos y vacaciones.",
        pasos: [
            "Selecciona un colaborador para ver o editar su expediente completo.",
            "Al subir INE, licencia o constancias, usa el lector <b>OCR</b> para autocompletar datos.",
            "Autoriza o rechaza permisos y vacaciones; al aprobarse se sincronizan con el Reloj Checador."
        ],
        tip: "Las alertas de licencias por vencer y permisos pendientes también aparecen en el Inicio."
    },
    "vista-analitica": {
        titulo: "📊 Analítica y KPIs",
        roles: ["ADMIN", "COORDINADOR"],
        keywords: "analitica kpis reportes rentabilidad puntualidad equipos",
        resumen: "Indicadores ejecutivos de finanzas, operación, puntualidad RRHH e inventario.",
        pasos: [
            "Elige el rango de fechas arriba y presiona <b>Actualizar</b>.",
            "En <b>Finanzas y Activos</b> revisas el gasto real (Operación + Taller) y el desglose por OP.",
            "En <b>Operaciones y RRHH</b> ves el índice de puntualidad, horas extra autorizadas y equipos más usados."
        ],
        tip: "Los datos se actualizan en tiempo real cruzando las bases de Eventos, Personal, Inventario y Autos."
    },
    "vista-transfer": {
        titulo: "☁️ VPRO Transfer (Archivos)",
        roles: ["ALL"],
        keywords: "transfer archivos carpetas compartir 10gb descarga",
        resumen: "Envío interno de archivos y carpetas completas de hasta 10 GB.",
        pasos: [
            "Arrastra archivos o carpetas completas de Windows directamente al recuadro.",
            "Selecciona al destinatario (o varios compañeros) y presiona Enviar.",
            "Los archivos expiran automáticamente después de 24h de descargados o 72h sin descarga."
        ],
        tip: "Ideal para pasar material de grabación, gráficos o proyectos pesados sin usar ligas externas."
    },
    "vista-chat": {
        titulo: "💬 Comunicación y Soporte",
        roles: ["ALL"],
        keywords: "chat general op 1a1 soporte ayuda redes",
        resumen: "4 canales integrados: Chat General, por OP, Privado 1 a 1 y Soporte Técnico.",
        pasos: [
            "<b>General:</b> Avisos abiertos para todo el equipo.",
            "<b>Por OP:</b> Canal exclusivo de cada evento (con recordatorios automáticos 2h antes del llamado).",
            "<b>1 a 1:</b> Mensajes directos con colaboradores activos.",
            "<b>Ayuda Redes / Soporte:</b> Reporta fallas técnicas directo a Sistemas."
        ],
        tip: "Las notificaciones de mensajes nuevos llegan en tiempo real sin recargar la página."
    },
    "vista-catalogos": {
        titulo: "🗂️ Catálogos y Flota Vehicular",
        roles: ["ADMIN", "COORDINADOR"],
        keywords: "catalogos autos vehiculos clientes proveedores inventario bitacora",
        resumen: "Administración de inventario audiovisual, flotilla vehicular, clientes, proveedores y personal.",
        pasos: [
            "Entra al catálogo que necesites gestionar desde el Hub.",
            "En <b>Autos</b> puedes mantener al día pólizas, kilometraje e historial.",
            "En <b>Inventario</b> administra números de serie, kits y estatus de reparación."
        ],
        tip: "Evita borrar registros con historial operativo; si un empleado sale, cámbialo a estatus BAJA."
    }
};

function _obtenerVistaActualAyuda() {
    if (window._vproVistaActual && GUIA_MODULOS_VPRO[window._vproVistaActual]) {
        return window._vproVistaActual;
    }
    const visible = Array.from(document.querySelectorAll(".vista-modulo")).find(v => v.style.display !== "none" && v.offsetParent !== null);
    return (visible && GUIA_MODULOS_VPRO[visible.id]) ? visible.id : "vista-inicio";
}

function _renderContenidoGuia(idVista) {
    const g = GUIA_MODULOS_VPRO[idVista] || GUIA_MODULOS_VPRO["vista-inicio"];
    return `
        <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:10px; padding:16px; text-align:left;">
            <div style="font-size:16px; font-weight:800; color:#0f172a; margin-bottom:4px;">${g.titulo}</div>
            <div style="font-size:12.5px; color:#475569; margin-bottom:12px;">${g.resumen}</div>
            <ol style="margin:0; padding-left:20px; font-size:13px; color:#1e293b; line-height:1.65;">
                ${g.pasos.map(p => `<li style="margin-bottom:6px;">${p}</li>`).join("")}
            </ol>
            ${g.tip ? `<div style="margin-top:12px; background:#eff6ff; border-left:4px solid #3b82f6; padding:8px 12px; border-radius:6px; font-size:12px; color:#1e40af;"><b>💡 Tip:</b> ${g.tip}</div>` : ""}
        </div>
    `;
}

function abrirAyudaContextual(vistaForzada = null) {
    const idActual = vistaForzada || _obtenerVistaActualAyuda();
    const rolActual = ((typeof usuarioLogueado !== "undefined" && usuarioLogueado && usuarioLogueado.rol) ? usuarioLogueado.rol : "PRODUCCION").toUpperCase();

    if (typeof Swal === "undefined") {
        abrirManualCompleto();
        return;
    }

    const renderBuscador = (termino = "") => {
        const q = termino.trim().toLowerCase();
        const entradas = Object.entries(GUIA_MODULOS_VPRO).filter(([id, g]) => {
            const matchTxt = !q || g.titulo.toLowerCase().includes(q) || g.resumen.toLowerCase().includes(q) || g.keywords.toLowerCase().includes(q) || g.pasos.join(" ").toLowerCase().includes(q);
            if (!q) {
                return g.roles.includes("ALL") || g.roles.some(r => rolActual.includes(r));
            }
            return matchTxt;
        });

        if (entradas.length === 0) {
            return `<div style="text-align:center; padding:20px; color:#64748b; font-size:13px;">No se encontraron guías para "${termino}".</div>`;
        }
        return entradas.map(([id, g]) => `
            <div onclick="document.getElementById('ayuda-detalle-dinamico').innerHTML = _renderContenidoGuia('${id}'); document.getElementById('ayuda-tab-actual').click();"
                 style="padding:10px 12px; border:1px solid #e2e8f0; border-radius:8px; margin-bottom:8px; cursor:pointer; background:white; transition:background .15s;"
                 onmouseover="this.style.background='#f1f5f9'" onmouseout="this.style.background='white'">
                <div style="font-weight:700; font-size:13px; color:#0f172a;">${g.titulo}</div>
                <div style="font-size:12px; color:#64748b;">${g.resumen}</div>
            </div>
        `).join("");
    };

    Swal.fire({
        title: '🛟 Centro de Ayuda Rápida VPRO',
        width: 680,
        html: `
            <div style="text-align:left;">
                <div style="display:flex; gap:8px; margin-bottom:14px; border-bottom:1px solid #e2e8f0; padding-bottom:10px;">
                    <button type="button" id="ayuda-tab-actual" style="background:#0f172a; color:white; border:none; padding:7px 14px; border-radius:7px; font-size:12.5px; font-weight:700; cursor:pointer;">📍 Guía de esta Pantalla</button>
                    <button type="button" id="ayuda-tab-todas" style="background:#f1f5f9; color:#334155; border:1px solid #cbd5e1; padding:7px 14px; border-radius:7px; font-size:12.5px; font-weight:700; cursor:pointer;">🔍 Buscar otras Guías</button>
                    <button type="button" id="ayuda-btn-completo" style="margin-left:auto; background:#eff6ff; color:#1d4ed8; border:1px solid #bfdbfe; padding:7px 12px; border-radius:7px; font-size:12px; font-weight:700; cursor:pointer;">📖 Manual Completo</button>
                </div>
                <div id="ayuda-panel-actual">
                    <div id="ayuda-detalle-dinamico">${_renderContenidoGuia(idActual)}</div>
                </div>
                <div id="ayuda-panel-todas" style="display:none;">
                    <input type="text" id="ayuda-buscador-input" placeholder="🔍 Busca: permiso, ticket, kiosco, cotización, op..." style="width:100%; box-sizing:border-box; padding:9px 12px; border:1px solid #cbd5e1; border-radius:8px; font-size:13px; margin-bottom:10px;">
                    <div id="ayuda-lista-resultados" style="max-height:300px; overflow-y:auto;">${renderBuscador("")}</div>
                </div>
            </div>
        `,
        showConfirmButton: true,
        confirmButtonText: 'Cerrar',
        confirmButtonColor: '#334155',
        didOpen: () => {
            const tabAct = document.getElementById("ayuda-tab-actual");
            const tabTod = document.getElementById("ayuda-tab-todas");
            const panAct = document.getElementById("ayuda-panel-actual");
            const panTod = document.getElementById("ayuda-panel-todas");
            const btnComp = document.getElementById("ayuda-btn-completo");
            const inpBusq = document.getElementById("ayuda-buscador-input");

            tabAct.onclick = () => {
                panAct.style.display = "block"; panTod.style.display = "none";
                tabAct.style.background = "#0f172a"; tabAct.style.color = "white"; tabAct.style.border = "none";
                tabTod.style.background = "#f1f5f9"; tabTod.style.color = "#334155"; tabTod.style.border = "1px solid #cbd5e1";
            };
            tabTod.onclick = () => {
                panAct.style.display = "none"; panTod.style.display = "block";
                tabTod.style.background = "#0f172a"; tabTod.style.color = "white"; tabTod.style.border = "none";
                tabAct.style.background = "#f1f5f9"; tabAct.style.color = "#334155"; tabAct.style.border = "1px solid #cbd5e1";
                if (inpBusq) inpBusq.focus();
            };
            btnComp.onclick = () => {
                Swal.close();
                abrirManualCompleto();
            };
            if (inpBusq) {
                inpBusq.oninput = () => {
                    document.getElementById("ayuda-lista-resultados").innerHTML = renderBuscador(inpBusq.value);
                };
            }
        }
    });
}

function abrirManualCompleto() {
    const modal = document.getElementById("modal-manual");
    if (modal) modal.style.display = "flex";
}

function abrirManual() {
    abrirAyudaContextual();
}

function cerrarManual() {
    const modal = document.getElementById("modal-manual");
    if (modal) modal.style.display = "none";
}

// Botón flotante discreto de Ayuda Contextual (?)
(function initBotonAyudaContextual() {
    const crearBoton = () => {
        if (document.getElementById("btn-ayuda-contextual-vpro")) return;
        const btn = document.createElement("button");
        btn.id = "btn-ayuda-contextual-vpro";
        btn.type = "button";
        btn.title = "Ayuda rápida de esta pantalla";
        btn.innerHTML = `<i class="ph ph-question" style="font-size:20px;"></i>`;
        btn.style.cssText = "position:fixed; bottom:24px; right:92px; width:44px; height:44px; border-radius:50%; background:#0f172a; color:#38bdf8; border:2px solid #38bdf8; box-shadow:0 4px 12px rgba(15,23,42,0.28); cursor:pointer; display:flex; align-items:center; justify-content:center; z-index:990; transition:transform .15s;";
        btn.onmouseover = () => { btn.style.transform = "scale(1.08)"; };
        btn.onmouseout = () => { btn.style.transform = "scale(1)"; };
        btn.onclick = () => abrirAyudaContextual();
        document.body.appendChild(btn);
    };
    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", crearBoton);
    } else {
        crearBoton();
    }
})();
