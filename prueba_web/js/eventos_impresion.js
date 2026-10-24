// ==============================================================================
// MÓDULO: eventos_impresion.js
// 🖨️ Motor PDF/Impresión VPF-PAGL-OP
// Líneas originales: 1999–3591 de script.js
// ==============================================================================

// ==========================================================================
// 🖨️ MOTOR OFICIAL DE IMPRESIÓN Y EXPORTACIÓN A PDF: ORDEN DE PRODUCCIÓN [VPF-PAGL-OP]
// ==========================================================================

function formatearFechaEspanolCorta(fechaStr) {
    if (!fechaStr) return '';
    const clean = String(fechaStr).substring(0, 10);
    const parts = clean.split('-');
    if (parts.length !== 3) return fechaStr;
    const anio = parts[0].substring(2);
    const mesIdx = parseInt(parts[1], 10) - 1;
    const dia = parseInt(parts[2], 10);
    const mesesCortos = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return `${dia}-${mesesCortos[mesIdx] || parts[1]}-${anio}`;
}

function formatearFechaEspanolLarga(fechaStr) {
    if (!fechaStr) return '';
    const clean = String(fechaStr).substring(0, 10);
    const parts = clean.split('-');
    if (parts.length !== 3) return fechaStr;
    const anio = parts[0];
    const mesIdx = parseInt(parts[1], 10) - 1;
    const dia = parseInt(parts[2], 10);
    const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return `${meses[mesIdx] || parts[1]} ${dia} de ${anio}`;
}

function formatearRangoFechasEvento(fecInicioStr, fecFinStr) {
    if (!fecInicioStr) return '';
    const fIni = String(fecInicioStr).substring(0, 10);
    const fFin = fecFinStr ? String(fecFinStr).substring(0, 10) : fIni;
    if (!fFin || fIni === fFin) {
        return formatearFechaEspanolCorta(fIni).toUpperCase();
    }
    const pIni = fIni.split('-');
    const pFin = fFin.split('-');
    if (pIni.length !== 3 || pFin.length !== 3) return `${fIni} al ${fFin}`;
    
    const dIni = parseInt(pIni[2], 10);
    const dFin = parseInt(pFin[2], 10);
    const mIni = parseInt(pIni[1], 10) - 1;
    const mFin = parseInt(pFin[1], 10) - 1;
    const mesesCortos = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];

    // Mismo mes y mismo año
    if (mIni === mFin && pIni[0] === pFin[0]) {
        const difDias = dFin - dIni;
        if (difDias === 1) {
            return `${dIni} y ${dFin} ${mesesCortos[mIni]}.`;
        } else if (difDias === 2) {
            return `${dIni}, ${dIni + 1} y ${dFin} ${mesesCortos[mIni]}.`;
        } else {
            return `${dIni} al ${dFin} de ${mesesCortos[mIni]}.`;
        }
    } else {
        return `${dIni} ${mesesCortos[mIni]} al ${dFin} ${mesesCortos[mFin]}`;
    }
}

function formatearHoraAmPm(horaStr) {
    if (!horaStr) return '';
    const clean = String(horaStr).trim().substring(0, 5);
    const parts = clean.split(':');
    if (parts.length !== 2) return horaStr;
    let h = parseInt(parts[0], 10);
    const m = parts[1];
    const ampm = h >= 12 ? 'pm' : 'am';
    h = h % 12;
    if (h === 0) h = 12;
    return `${h}:${m}${ampm}`;
}

function parsearLineasLedgerJS(data) {
    if (Array.isArray(data.personal_roles_op) && data.personal_roles_op.length > 0) {
        return data.personal_roles_op;
    }
    const prod = (data.produccion || '').trim();
    const net = (data.internet_redes || '').trim();
    const act = (data.actividades_de_proveedores || '').trim();
    const convocados = Array.isArray(data.personal_convocado_op) ? data.personal_convocado_op.map(p => String(p).trim()).filter(Boolean) : [];
    const externos = Array.isArray(data.externos_op) ? data.externos_op.map(p => String(p).trim()).filter(Boolean) : [];

    const nomEv = String(data.nombre_evento || '').toUpperCase();
    const esTebacasMuestra = (nomEv.includes('TEBACAS') || prod.toUpperCase().includes('ESTUDIO DE TV')) && convocados.length === 0;

    if (esTebacasMuestra) {
        return [
            { tipo: 'seccion', titulo: 'ESTUDIO DE TV:', estilo: 'verde' },
            { req: 'Switcher', persona: 'Osiel' },
            { req: 'Audio', persona: 'Paco' },
            { req: 'Gráficos y marcador (OCR)', persona: 'Carlos' },
            { req: 'Redes', persona: 'Cuauhtemoc' },
            { tipo: 'seccion', titulo: 'EXTERNO:', estilo: 'subrayado' },
            { req: 'Repeticiones', persona: 'Javier' },
            { req: 'Comentarista #1', persona: 'Miguel Lara' },
            { req: 'Comentarista #2', persona: 'Ernesto Gutierrez' },
            { tipo: 'seccion', titulo: 'EN CANCHA:', estilo: 'amarillo' },
            { req: 'Productor Deportes', persona: 'Manuel' },
            { req: '2 cámaras fijas (sin camarógrafo) para seguimiento y repeticiones', persona: '' },
            { req: '1 Antena Starlink', persona: '' },
            { req: '4 Encoder E3 para transmisión SRT', persona: '' },
            { req: 'Redes', persona: 'Edgar' },
            { tipo: 'seccion', titulo: 'EXTERNOS:', estilo: 'subrayado' },
            { req: 'Camarógrafo #1 (central de seguimiento)', persona: 'Eduardo Araujo' }
        ];
    }

    const rows = [];
    const bloques = [];
    if (prod) bloques.push(['PRODUCCIÓN:', prod, 'verde']);
    if (net) bloques.push(['SISTEMAS / REDES:', net, 'amarillo']);
    if (act) bloques.push(['ACTIVIDADES / PROVEEDORES:', act, 'subrayado']);

    const allPeople = [...convocados, ...externos];
    let pIdx = 0;

    if (bloques.length > 0) {
        bloques.forEach(([secTitle, secText, secEstilo]) => {
            rows.push({ tipo: 'seccion', titulo: secTitle, estilo: secEstilo });
            const lines = secText.split('\n').map(l => l.trim()).filter(Boolean);
            lines.forEach(line => {
                if (line.endsWith(':') && line.length < 35) {
                    rows.push({ tipo: 'seccion', titulo: line, estilo: 'subrayado' });
                } else {
                    const personaMatch = pIdx < allPeople.length ? allPeople[pIdx] : '';
                    pIdx++;
                    rows.push({ req: line, persona: personaMatch });
                }
            });
        });
    }

    // Si aún quedan personas convocadas de VPRO que no tuvieron línea de texto asignada:
    if (pIdx < convocados.length) {
        if (bloques.length === 0) {
            rows.push({ tipo: 'seccion', titulo: 'PERSONAL VPRO ASIGNADO:', estilo: 'verde' });
        }
        while (pIdx < convocados.length) {
            rows.push({ req: '', persona: convocados[pIdx] });
            pIdx++;
        }
    }

    // Si hay personal externo que falta por listar:
    if (externos.length > 0) {
        const idxExternosStart = convocados.length;
        if (pIdx <= idxExternosStart) {
            rows.push({ tipo: 'seccion', titulo: 'PERSONAL EXTERNO / APOYOS:', estilo: 'subrayado' });
            externos.forEach(ext => {
                rows.push({ req: '', persona: ext });
            });
        } else if (pIdx < allPeople.length) {
            rows.push({ tipo: 'seccion', titulo: 'PERSONAL EXTERNO RESTANTE:', estilo: 'subrayado' });
            while (pIdx < allPeople.length) {
                rows.push({ req: '', persona: allPeople[pIdx] });
                pIdx++;
            }
        }
    }

    if (rows.length === 0) {
        rows.push({ req: '', persona: '' });
    }

    // Rellenar con filas vacías si son pocas (< 16) para mantener la estética corporativa de la hoja
    while (rows.length < 16) {
        rows.push({ req: '', persona: '' });
    }

    return rows;
}

function generarHtmlOPInteligente(data) {
    const hoyStr = formatearFechaLocal(new Date());
    const fElabFmt = formatearFechaEspanolLarga(data.fec_de_elaboracion_de_op || hoyStr);
    const folioVal = data.folio || '001';

    const clienteVal = (data.para_q_cliente || 'SIN CLIENTE ASIGNADO').trim();
    const areaSolicitaVal = (data.dependencia_solicita || '').trim();
    const nombreEventoVal = (data.nombre_evento || 'SIN NOMBRE DE EVENTO').trim();
    const locacionVal = (data.locacion || 'POR DEFINIR').trim();
    const quienSolicitaVal = (data.quien_solicita || 'Sin contacto solicitante').trim();
    const ubicacionVal = (data.ubicacion || 'CULIACÁN, SIN').trim().toUpperCase();
    const respProduccionVal = (data.resp_de_produccion || 'Por asignar').trim();

    const fInstFmt = formatearFechaEspanolCorta(data.fec_de_instalacion || hoyStr);
    const hInstFmt = formatearHoraAmPm(data.hra_de_instalacion || '12:00');
    const rangoEventoFmt = formatearRangoFechasEvento(data.fec_del_evento || hoyStr, data.fec_fin_evento || data.fec_del_evento || hoyStr);
    const hInicioFmt = formatearHoraAmPm(data.inicio_del_evento || '20:00');
    const hLlamadoFmt = formatearHoraAmPm(data.hra_de_llamado || '09:00');

    // Subtítulo del evento (e.g. TEBACAS VS EL ROSARIO)
    let subEvVal = (data.subtitulo_evento || '').trim();
    let nomEvLimpio = nombreEventoVal;
    if (!subEvVal) {
        const m = nombreEventoVal.match(/\(([^)]+)\)/);
        if (m) {
            subEvVal = m[1].trim();
            nomEvLimpio = nombreEventoVal.replace(`(${subEvVal})`, '').trim();
        }
    } else {
        nomEvLimpio = nombreEventoVal.replace(`(${subEvVal})`, '').trim();
    }

    // Detalle de llamado multilínea
    let detLlamVal = (data.detalle_llamado || '').trim();
    if (!detLlamVal) {
        detLlamVal = hLlamadoFmt;
    }
    const detLlamHtml = detLlamVal.replace(/\n/g, '<br>').replace(/\|/g, '<br>');

    // Rol de juegos
    let rolJuegosVal = (data.rol_juegos || '').trim();
    if (!rolJuegosVal) {
        if (nomEvLimpio.toUpperCase().includes('TEBACAS')) {
            rolJuegosVal = 'Día 10/ Octubre | Partido | TEBACAS & El Rosario | Hora: 8:00 PM';
        } else {
            rolJuegosVal = 'N/A | Evento General | Sin rol de juegos asignado | ---';
        }
    }
    let rolParts = rolJuegosVal.split('|').map(s => s.trim());
    while (rolParts.length < 4) rolParts.push('');

    // Vehículos a utilizar y destino
    let vehDestVal = (data.vehiculo_destino || ubicacionVal || 'CULIACÁN').trim().toUpperCase();
    const listaCarros = (Array.isArray(data.carros_usados_op) && data.carros_usados_op.length > 0)
        ? data.carros_usados_op.map(c => String(c).trim()).filter(Boolean)
        : ['Sin vehículos asignados'];

    const tipoServicioVal = (data.tipo_de_servicio || 'Producción de evento').trim();
    const gastoVal = parseFloat(data.estimado_gasto) || 0;
    const rowsLedger = parsearLineasLedgerJS(data);

    // Firmas
    const elaboraVal = (data.elabora || 'Ana Lilia Villarreal Uribe').replace('Ana Lilia Villarreal Uribe', 'Ana Lilia Villarreal U. (Admon)');
    const coordinaVal = data.coordina || 'Manuel Eduardo Madrid';
    const organizaVal = data.organiza || 'Martin Eduardo Sanchez Estrada';
    const voboVal = (data.vobo || 'Gerardo Villarreal Uribe').replace('Gerardo Villarreal Uribe', 'Gerardo Villarreal U.');

    return `
        <div style="width: 100%; max-width: 960px; margin: 0 auto; color: #000000; font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; box-sizing: border-box; background: #ffffff;">
            <!-- CONTENEDOR MAESTRO CON BORDE NEGRO EXACTO -->
            <div style="border: 1.5px solid #000000; width: 100%; box-sizing: border-box;">
                
                <!-- 1. HEADER (3 COLUMNAS) -->
                <table style="width: 100%; border-collapse: collapse; border-bottom: 1.5px solid #000000; table-layout: fixed;">
                    <tr>
                        <!-- Columna Izquierda: Logo + Banner Formato -->
                        <td style="width: 26%; vertical-align: middle; text-align: center; border-right: 1.5px solid #000000; padding: 0;">
                            <div style="padding: 10px 8px 8px 8px; display: flex; align-items: center; justify-content: center; min-height: 58px;">
                                <img src="vendor/img/vpro_logo_oficial.png" alt="vpro® Visual Creative" style="max-height: 48px; max-width: 155px; object-fit: contain;">
                            </div>
                            <div style="background: #000000; color: #ffffff; font-weight: bold; font-size: 11px; padding: 4px 6px; text-align: center; letter-spacing: 0.5px; border-top: 1px solid #000000;">
                                FORMATO:VPF-PAGL-OP
                            </div>
                        </td>

                        <!-- Columna Central: ORDEN DE PRODUCCIÓN + Fecha de Elaboración -->
                        <td style="width: 46%; vertical-align: top; text-align: center; border-right: 1.5px solid #000000; padding: 0;">
                            <div style="padding: 10px 8px 6px 8px;">
                                <h1 style="margin: 0; font-size: 21px; font-weight: 900; letter-spacing: 0.8px; color: #000000; line-height: 1.15; text-transform: uppercase;">
                                    ORDEN DE PRODUCCIÓN
                                </h1>
                            </div>
                            <table style="width: 100%; border-collapse: collapse; border-top: 1px solid #000000;">
                                <tr>
                                    <td style="background: #0078d4; color: #ffffff; font-size: 11px; font-weight: bold; padding: 4px 6px; text-align: center; border-right: 1px solid #000000; width: 45%;">
                                        Fecha de Elaboración:
                                    </td>
                                    <td style="font-size: 11.5px; font-weight: 700; padding: 4px 6px; text-align: center; background: #ffffff;">
                                        ${fElabFmt}
                                    </td>
                                </tr>
                            </table>
                        </td>

                        <!-- Columna Derecha: Datos Fiscales + FOLIO ROJO -->
                        <td style="width: 28%; vertical-align: top; padding: 0;">
                            <div style="padding: 6px 8px; text-align: center; font-size: 9.5px; line-height: 1.35; color: #000000; min-height: 52px; display: flex; flex-direction: column; justify-content: center;">
                                <div>Laguna de Tamiahua 1344-B, Col. Las Quintas C.P.80060</div>
                                <div>Tel. (667) 258-16-85 Culiacán, Sin.</div>
                                <div style="font-weight: 700;">R.F.C. VIUP-680807-UT4</div>
                            </div>
                            <table style="width: 100%; border-collapse: collapse; border-top: 1px solid #000000;">
                                <tr>
                                    <td style="background: #e2e8f0; color: #000000; font-size: 11.5px; font-weight: 900; padding: 3px 6px; text-align: center; border-right: 1px solid #000000; width: 45%;">
                                        FOLIO:
                                    </td>
                                    <td style="font-size: 18px; font-weight: 900; color: #dc2626; padding: 2px 6px; text-align: center; background: #ffffff;">
                                        ${folioVal}
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>

                <!-- 2. DETALLES DE EVENTO (TABLA MATRIZ EXACTA AL MODELO FÍSICO) -->
                <table style="width: 100%; border-collapse: collapse; border-bottom: 1.5px solid #000000; table-layout: fixed; font-size: 11px;">
                    <!-- Cabecera de la sección -->
                    <tr>
                        <td colspan="2" style="background: #0078d4; color: #ffffff; font-weight: bold; font-size: 11.5px; padding: 4px 8px; border-right: 1px solid #000000; border-bottom: 1px solid #000000;">
                            Detalles de Evento:
                        </td>
                        <td style="width: 22%; background: #0078d4; color: #ffffff; font-weight: bold; font-size: 10px; padding: 4px 6px; text-align: center; border-right: 1px solid #000000; border-bottom: 1px solid #000000;">
                            FECHA DE INSTALACION:
                        </td>
                        <td style="width: 18%; background: #d4edda; color: #000000; font-weight: bold; font-size: 11px; padding: 4px 6px; text-align: center; border-bottom: 1px solid #000000;">
                            ${fInstFmt}
                        </td>
                    </tr>

                    <!-- Fila 1: CLIENTE vs HORA DE INSTALACION -->
                    <tr>
                        <td style="width: 18%; background: #ffffff; color: #000000; font-weight: bold; font-size: 10px; padding: 4px 8px; border-right: 1px solid #000000; border-bottom: 1px solid #000000;">
                            CLIENTE:
                        </td>
                        <td style="width: 42%; font-weight: 800; text-transform: uppercase; font-size: 11.5px; padding: 4px 8px; text-align: center; border-right: 1px solid #000000; border-bottom: 1px solid #000000;">
                            ${clienteVal}
                        </td>
                        <td style="background: #0078d4; color: #ffffff; font-weight: bold; font-size: 10px; padding: 4px 6px; text-align: center; border-right: 1px solid #000000; border-bottom: 1px solid #000000;">
                            HORA DE INSTALACION:
                        </td>
                        <td style="background: #f1f5f9; color: #000000; font-weight: 700; font-size: 11px; padding: 4px 6px; text-align: center; border-bottom: 1px solid #000000;">
                            ${hInstFmt}
                        </td>
                    </tr>

                    <!-- Fila 2: NOMBRE DE EVENTO (AMARILLO VIVO) vs FECHA EVENTO -->
                    <tr>
                        <td style="background: #ffffff; color: #000000; font-weight: bold; font-size: 10px; padding: 4px 8px; border-right: 1px solid #000000; border-bottom: 1px solid #000000;">
                            NOMBRE DE EVENTO:
                        </td>
                        <td style="background: #fde047; color: #000000; font-weight: 900; text-transform: uppercase; font-size: 11px; padding: 6px 8px; text-align: center; border-right: 1px solid #000000; border-bottom: 1px solid #000000;">
                            ${nomEvLimpio}
                        </td>
                        <td style="background: #0078d4; color: #ffffff; font-weight: bold; font-size: 10px; padding: 4px 6px; text-align: center; border-right: 1px solid #000000; border-bottom: 1px solid #000000;">
                            FECHA EVENTO:
                        </td>
                        <td style="background: #d4edda; color: #000000; font-weight: bold; font-size: 11px; padding: 4px 6px; text-align: center; border-bottom: 1px solid #000000;">
                            ${rangoEventoFmt}
                        </td>
                    </tr>

                    <!-- Fila 3: SUBTÍTULO (TEBACAS VS EL ROSARIO) vs HORA INICIO EVENTO -->
                    <tr>
                        <td colspan="2" style="background: #ffffff; font-weight: 800; font-size: 11.5px; padding: 4px 8px; text-align: center; border-right: 1px solid #000000; border-bottom: 1px solid #000000;">
                            ${subEvVal}
                        </td>
                        <td style="background: #0078d4; color: #ffffff; font-weight: bold; font-size: 10px; padding: 4px 6px; text-align: center; border-right: 1px solid #000000; border-bottom: 1px solid #000000;">
                            HORA DE INICIO EVENTO:
                        </td>
                        <td style="background: #ffffff; color: #000000; font-weight: 700; font-size: 11px; padding: 4px 6px; text-align: center; border-bottom: 1px solid #000000;">
                            ${hInicioFmt}
                        </td>
                    </tr>

                    <!-- Fila 4: LOCACION vs HORA DE LLAMADO (NEGRO / GRIS) -->
                    <tr>
                        <td style="background: #ffffff; color: #000000; font-weight: bold; font-size: 10px; padding: 4px 8px; border-right: 1px solid #000000; border-bottom: 1px solid #000000;">
                            LOCACION:
                        </td>
                        <td style="font-weight: 700; font-size: 11px; padding: 4px 8px; text-align: center; border-right: 1px solid #000000; border-bottom: 1px solid #000000;">
                            ${locacionVal}
                        </td>
                        <td style="background: #000000; color: #ffffff; font-weight: bold; font-size: 10px; padding: 4px 6px; text-align: center; border-right: 1px solid #000000; border-bottom: 1px solid #000000;">
                            HORA DE LLAMADO:
                        </td>
                        <td style="background: #9ca3af; color: #ffffff; font-weight: 900; font-size: 11.5px; padding: 4px 6px; text-align: center; border-bottom: 1px solid #000000; line-height: 1.25;">
                            ${detLlamHtml}
                        </td>
                    </tr>

                    <!-- Fila 5: Solicita el servicio vs UBICACIÓN -->
                    <tr>
                        <td colspan="2" style="background: #0078d4; color: #ffffff; font-weight: bold; font-size: 10.5px; padding: 4px 8px; border-right: 1px solid #000000; border-bottom: 1px solid #000000;">
                            Solicita el servicio:
                        </td>
                        <td style="background: #0078d4; color: #ffffff; font-weight: bold; font-size: 10px; padding: 4px 6px; border-right: 1px solid #000000; border-bottom: 1px solid #000000;">
                            UBICACIÓN:
                        </td>
                        <td style="font-weight: 800; font-size: 11px; padding: 4px 6px; text-align: center; border-bottom: 1px solid #000000;">
                            ${ubicacionVal}
                        </td>
                    </tr>

                    <!-- Fila 6: Dependencia / Contacto Solicitante vs Responsable de Producción -->
                    <tr>
                        <td colspan="2" style="padding: 6px 8px; text-align: center; border-right: 1px solid #000000; vertical-align: middle;">
                            ${areaSolicitaVal ? `<div style="font-size: 10px; font-weight: 700; color: #1e293b; text-transform: uppercase;">${areaSolicitaVal}</div>` : ''}
                            <div style="font-size: 11.5px; font-weight: 800; color: #000000; ${areaSolicitaVal ? 'margin-top: 2px;' : ''}">${quienSolicitaVal}</div>
                        </td>
                        <td colspan="2" style="vertical-align: top; padding: 0;">
                            <div style="background: #000000; color: #ffffff; font-weight: bold; font-size: 10px; padding: 3px 6px; text-align: center; border-bottom: 1px solid #000000;">
                                Responsable de Producción:
                            </div>
                            <div style="padding: 6px 8px; font-weight: 800; font-size: 11px; text-align: center;">
                                ${respProduccionVal}
                            </div>
                        </td>
                    </tr>
                </table>

                <!-- 3. DESCRIPCIÓN DEL SERVICIO -->
                <table style="width: 100%; border-collapse: collapse; border-bottom: 1.5px solid #000000; table-layout: fixed;">
                    <tr>
                        <td colspan="2" style="background: #cbd5e1; color: #000000; font-weight: 900; font-size: 11.5px; padding: 4px 8px; text-align: center; letter-spacing: 0.5px; border-bottom: 1px solid #000000;">
                            DESCRIPCIÓN DEL SERVICIO
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 20%; background: #0078d4; color: #ffffff; font-weight: bold; font-size: 10px; padding: 5px 8px; border-right: 1px solid #000000; vertical-align: middle;">
                            TIPO DE SERVICIO:
                        </td>
                        <td style="width: 80%; font-size: 11px; font-weight: 700; color: #1d4ed8; padding: 5px 10px; background: #dbeafe;">
                            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
                                <span>${tipoServicioVal}</span>
                                ${gastoVal > 0 ? `<span style="background: #1e293b; color: #a3e635; padding: 2px 8px; border-radius: 4px; font-size: 10px; font-weight: 800; white-space: nowrap;">Presupuesto Est.: $${gastoVal.toLocaleString('es-MX', {minimumFractionDigits: 2})}</span>` : ''}
                            </div>
                        </td>
                    </tr>
                </table>

                <!-- 4. DETALLE TÉCNICO Y LOGÍSTICA CONVOCADA (2 COLUMNAS LEDGER) -->
                <table style="width: 100%; border-collapse: collapse; border-bottom: 1.5px solid #000000; table-layout: fixed; font-size: 10.5px;">
                    <thead>
                        <tr style="background: #f8fafc; font-style: italic; font-size: 9.5px; color: #475569; border-bottom: 1px solid #cbd5e1;">
                            <th style="width: 55%; text-align: left; padding: 3px 8px; font-weight: normal; border-right: 1.5px solid #000000;">Servicio requerido:</th>
                            <th style="width: 45%; text-align: left; padding: 3px 8px; font-weight: normal;">Personal Convocado:</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${rowsLedger.map(r => {
                            if (r.tipo === 'seccion') {
                                let bg = '#ffffff';
                                let estilo = 'font-weight: bold;';
                                if (r.estilo === 'verde') {
                                    bg = '#a3e635';
                                } else if (r.estilo === 'amarillo') {
                                    bg = '#fde047';
                                } else if (r.estilo === 'subrayado') {
                                    estilo += 'text-decoration: underline;';
                                }
                                return `
                                    <tr style="border-bottom: 1px solid #e2e8f0; page-break-inside: avoid;">
                                        <td style="background: ${bg}; ${estilo} padding: 3px 8px; border-right: 1.5px solid #000000; font-size: 10px;">
                                            ${r.titulo}
                                        </td>
                                        <td style="padding: 3px 8px; background: #ffffff;"></td>
                                    </tr>
                                `;
                            } else {
                                return `
                                    <tr style="border-bottom: 1px solid #e2e8f0; page-break-inside: avoid;">
                                        <td style="padding: 2.5px 8px; border-right: 1.5px solid #000000; font-size: 10px; color: #1e293b;">
                                            ${r.req || ''}
                                        </td>
                                        <td style="padding: 2.5px 8px; font-weight: bold; background: #ffffff; font-size: 10px; color: #000000;">
                                            ${r.persona || ''}
                                        </td>
                                    </tr>
                                `;
                            }
                        }).join('')}
                    </tbody>
                </table>

                <!-- 4.2 ROL DE JUEGOS Y VEHÍCULOS A UTILIZAR -->
                <table style="width: 100%; border-collapse: collapse; border-bottom: 1.5px solid #000000; table-layout: fixed; font-size: 10.5px; page-break-inside: avoid;">
                    <tr>
                        <!-- Columna Izquierda: ROL DE JUEGOS -->
                        <td style="width: 55%; vertical-align: top; padding: 0; border-right: 1.5px solid #000000;">
                            <div style="background: #f59e0b; color: #000000; font-weight: 900; font-size: 11px; padding: 3px 6px; text-align: center; border-bottom: 1px solid #000000;">
                                ROL DE JUEGOS
                            </div>
                            <table style="width: 100%; border-collapse: collapse; font-size: 10px; text-align: center;">
                                <tr>
                                    <td style="padding: 4px; border-right: 1px solid #000000; font-weight: bold; width: 25%;">${rolParts[0]}</td>
                                    <td style="padding: 4px; border-right: 1px solid #000000; font-weight: bold; width: 18%;">${rolParts[1]}</td>
                                    <td style="padding: 4px; border-right: 1px solid #000000; font-weight: 800; width: 37%;">${rolParts[2]}</td>
                                    <td style="padding: 4px; font-weight: bold; width: 20%;">${rolParts[3]}</td>
                                </tr>
                            </table>
                        </td>

                        <!-- Columna Derecha: VEHÍCULOS A UTILIZAR -->
                        <td style="width: 45%; vertical-align: top; padding: 0;">
                            <table style="width: 100%; border-collapse: collapse; font-size: 10px;">
                                <tr>
                                    <td style="font-weight: 900; padding: 3px 6px; width: 45%; border-bottom: 1px solid #000000; border-right: 1px solid #000000;">
                                        VEHICULO A UTILIZAR:
                                    </td>
                                    <td colspan="4" style="font-weight: 800; padding: 3px 6px; text-align: center; border-bottom: 1px solid #000000;">
                                        ${vehDestVal}
                                    </td>
                                </tr>
                                <tr style="text-align: center; font-size: 9px; background: #f8fafc; border-bottom: 1px solid #000000;">
                                    <td style="border-right: 1px solid #000000;"></td>
                                    <td style="border-right: 1px solid #000000; width: 14%;">km</td>
                                    <td style="border-right: 1px solid #000000; width: 14%;">gas</td>
                                    <td style="border-right: 1px solid #000000; width: 14%;">km</td>
                                    <td style="width: 14%;">gas</td>
                                </tr>
                                ${listaCarros.map(carro => `
                                <tr style="border-bottom: 1px solid #000000;">
                                    <td style="padding: 3px 6px; font-weight: 800; border-right: 1px solid #000000; font-size: 9.5px;">
                                        ${carro}
                                    </td>
                                    <td style="border-right: 1px solid #000000;"></td>
                                    <td style="border-right: 1px solid #000000;"></td>
                                    <td style="border-right: 1px solid #000000;"></td>
                                    <td></td>
                                </tr>
                                `).join('')}
                            </table>
                        </td>
                    </tr>
                </table>

                <!-- 5. NOTA BANNER (NEGRO TOTAL) -->
                <div style="background: #000000; color: #ffffff; font-weight: bold; font-size: 9px; line-height: 1.35; padding: 6px 10px; border-bottom: 1.5px solid #000000; page-break-inside: avoid;">
                    NOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.
                </div>

                <!-- 6. FIRMAS DE AUTORIZACIÓN (2x2 GRID) -->
                <table style="width: 100%; border-collapse: collapse; table-layout: fixed; font-size: 10px; page-break-inside: avoid;">
                    <tr style="border-bottom: 1px solid #000000;">
                        <td style="width: 50%; padding: 6px 10px; border-right: 1px solid #000000;">
                            <b>Elaboró:</b> ${elaboraVal}
                        </td>
                        <td style="width: 50%; padding: 6px 10px;">
                            <b>Área que organiza:</b> ${organizaVal}
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 6px 10px; border-right: 1px solid #000000;">
                            <b>Coordinación de Producción:</b> ${coordinaVal}
                        </td>
                        <td style="padding: 6px 10px;">
                            <b>Vo.Bo. Gerencia :</b> ${voboVal}
                        </td>
                    </tr>
                </table>

            </div>
        </div>
    `;
}

async function imprimirOrdenProduccionActual(folio) {
    let opData = null;

    // 1. Intentar consultar datos desde la API si hay folio
    if (folio) {
        try {
            const resp = await fetch(`${API_URL}/api/eventos/op/${folio}`);
            if (resp.ok) {
                opData = await resp.json();
            }
        } catch (e) {
            console.warn("No se pudo obtener OP desde API, usando datos en vivo del DOM:", e);
        }
    }

    // 2. Complementar o sustituir con datos en vivo del formulario activo en pantalla
    const formActivo = document.getElementById('form-orden-produccion-act') || document.getElementById('form-orden-produccion-hist');
    if (formActivo) {
        const getVal = (id) => document.getElementById(id)?.value || '';
        const folioForm = getVal('op_folio') || folio || '001';

        opData = opData || {};
        opData.folio = folioForm;
        opData.id_evento = document.getElementById('op_id_evento')?.value || opData.id_evento || 1;
        opData.para_q_cliente = getVal('op_para_q_cliente') || opData.para_q_cliente || '';
        opData.nombre_evento = getVal('op_nombre_evento') || opData.nombre_evento || '';
        opData.subtitulo_evento = getVal('op_subtitulo_evento') || opData.subtitulo_evento || '';
        opData.locacion = getVal('op_locacion') || opData.locacion || '';
        opData.fec_de_instalacion = getVal('op_fec_de_instalacion') || opData.fec_de_instalacion || '';
        opData.hra_de_instalacion = getVal('op_hra_de_instalacion') || opData.hra_de_instalacion || '';
        opData.dependencia_solicita = getVal('op_dependencia_solicita') || opData.dependencia_solicita || '';
        opData.quien_solicita = getVal('op_quien_solicita') || opData.quien_solicita || '';
        opData.resp_de_produccion = getVal('op_resp_de_produccion') || opData.resp_de_produccion || '';
        opData.fec_del_evento = getVal('op_fec_del_evento') || opData.fec_del_evento || '';
        opData.fec_fin_evento = getVal('op_fec_fin_evento') || opData.fec_fin_evento || opData.fec_del_evento;
        opData.inicio_del_evento = getVal('op_inicio_del_evento') || opData.inicio_del_evento || '';
        opData.hra_de_llamado = getVal('op_hra_de_llamado') || opData.hra_de_llamado || '';
        opData.detalle_llamado = getVal('op_detalle_llamado') || opData.detalle_llamado || '';
        opData.estimado_gasto = getVal('op_estimado_gasto') || opData.estimado_gasto || 0;
        opData.ubicacion = getVal('op_ubicacion') || opData.ubicacion || '';
        opData.vehiculo_destino = getVal('op_vehiculo_destino') || opData.vehiculo_destino || '';
        opData.rol_juegos = getVal('op_rol_juegos') || opData.rol_juegos || '';
        opData.tipo_de_servicio = getVal('op_tipo_de_servicio') || opData.tipo_de_servicio || '';
        opData.produccion = getVal('op_produccion') || opData.produccion || '';
        opData.internet_redes = getVal('op_internet_redes') || opData.internet_redes || '';
        opData.actividades_de_proveedores = getVal('op_actividades_de_proveedores') || opData.actividades_de_proveedores || '';
        opData.nota = getVal('op_nota') || opData.nota || '';
        opData.elabora = getVal('op_elabora') || opData.elabora || '';
        opData.coordina = getVal('op_coordina') || opData.coordina || '';
        opData.organiza = getVal('op_organiza') || opData.organiza || '';
        opData.vobo = getVal('op_vobo') || opData.vobo || '';

        if (window.opMultiSelects) {
            if (window.opMultiSelects.personal_vpro && window.opMultiSelects.personal_vpro.length > 0) {
                opData.personal_convocado_op = window.opMultiSelects.personal_vpro;
            }
            if (window.opMultiSelects.personal_externo && window.opMultiSelects.personal_externo.length > 0) {
                opData.externos_op = window.opMultiSelects.personal_externo;
            }
            if (window.opMultiSelects.vehiculos && window.opMultiSelects.vehiculos.length > 0) {
                opData.carros_usados_op = window.opMultiSelects.vehiculos;
            }
            if (window.opMultiSelects.proveedores && window.opMultiSelects.proveedores.length > 0) {
                opData.proveedor_op = window.opMultiSelects.proveedores;
            }
        }
    }

    if (!opData) {
        Swal.fire({
            icon: 'warning',
            title: 'Sin datos disponibles',
            text: 'Por favor selecciona o guarda una Orden de Producción para generar su formato imprimible.'
        });
        return;
    }

    const htmlImpresion = generarHtmlOPInteligente(opData);
    const contenedor = document.getElementById('op-hoja-oficial');
    const modal = document.getElementById('modal-op-impresion');

    if (contenedor && modal) {
        window.opFolioActivoImpresion = opData.folio || folio || '001';
        contenedor.innerHTML = htmlImpresion;
        modal.style.display = 'flex';
    }
}

function cerrarModalOPImpresion() {
    const modal = document.getElementById('modal-op-impresion');
    if (modal) modal.style.display = 'none';
    document.body.classList.remove('imprimiendo-modo-op');
}

function ejecutarImpresionOP() {
    document.body.classList.add('imprimiendo-modo-op');
    window.print();
    setTimeout(() => {
        document.body.classList.remove('imprimiendo-modo-op');
    }, 1200);
}

function abrirOPEntestañaImprimible() {
    const hoja = document.getElementById('op-hoja-oficial');
    if (!hoja) return;
    const win = window.open('', '_blank');
    if (!win) {
        Swal.fire({
            icon: 'info',
            title: 'Ventana emergente bloqueada',
            text: 'Por favor permite ventanas emergentes en tu navegador para ver la hoja oficial en una pestaña independiente.'
        });
        return;
    }
    win.document.write(`<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Orden de Producción VPRO - VPF-PAGL-OP</title>
    <style>
        body { margin: 0; padding: 24px; background: #ffffff; color: #000000; font-family: Arial, sans-serif; }
        .no-print-bar {
            max-width: 960px;
            margin: 0 auto 16px auto;
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }
        .btn-print-action {
            background: #0078d4;
            color: #ffffff;
            border: none;
            padding: 10px 22px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            box-shadow: 0 2px 6px rgba(0, 120, 212, 0.3);
        }
        @media print {
            body { padding: 0 !important; margin: 0 !important; }
            .no-print-bar { display: none !important; }
            @page { size: letter portrait; margin: 8mm 8mm 8mm 8mm; }
            table { page-break-inside: auto; }
            tr { page-break-inside: avoid; }
            * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
        }
    </style>
</head>
<body>
    <div class="no-print-bar">
        <button class="btn-print-action" onclick="window.print()">🖨️ Mandar a Imprimir / Guardar en PDF</button>
    </div>
    ${hoja.innerHTML}
</body>
</html>`);
    win.document.close();
}

function descargarPDFDirectoOP() {
    const folio = window.opFolioActivoImpresion || document.getElementById('op_folio')?.value || '1';
    window.open(`${API_URL}/api/eventos/pdf/${encodeURIComponent(folio)}`, '_blank');
}

// -------------------------------------------------------------
// Carga del Detalle para OPs Activas
// -------------------------------------------------------------
async function cargarDetalleOP(folioId) {
    const container = document.getElementById('formulario-op-container');
    if (!container) return;

    const cats = window.vproCatalogosOP || {};

    if (!folioId) {
        // Modo Nueva Orden
        window.opMultiSelects = {
            personal_vpro: [],
            vehiculos: [],
            personal_externo: [],
            proveedores: [],
            reuniones: [],
            cronogramas: []
        };
        window.opFotosEvidenciaActuales = [];

        const proximoFolio = window.vproProximoId || 1;
        container.innerHTML = generarHtmlFormularioOP({ id_evento: proximoFolio, folio: String(proximoFolio) }, false);

        // Renderizar multi-selects en blanco
        renderMultiSelectComponent('ms-reuniones-act', 'reuniones', cats.reuniones, "Despliega y selecciona una o varias reuniones...");
        renderMultiSelectComponent('ms-cronogramas-act', 'cronogramas', cats.cronogramas, "Despliega y selecciona cronograma(s) de actividades...");
        renderMultiSelectComponent('ms-personal_vpro-act', 'personal_vpro', cats.staff_vpro, "Choose options");
        renderMultiSelectComponent('ms-personal_externo-act', 'personal_externo', cats.apoyos_externos, "Choose options");
        renderMultiSelectComponent('ms-vehiculos-act', 'vehiculos', cats.autos, "Choose options");
        renderMultiSelectComponent('ms-proveedores-act', 'proveedores', cats.proveedores, "Choose options");

        actualizarCrewGira();
        return;
    }

    container.innerHTML = `<p style="color: var(--text-muted); text-align: center; padding: 30px;">Cargando información completa del folio ${folioId}...</p>`;

    try {
        const response = await fetch(`${API_URL}/api/eventos/buscar/${encodeURIComponent(folioId)}`);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const data = await response.json();

        // Inicializar estado de multiselects con lo guardado en base de datos
        window.opMultiSelects = {
            personal_vpro: Array.isArray(data.personal_convocado_op) ? data.personal_convocado_op : [],
            vehiculos: Array.isArray(data.carros_usados_op) ? data.carros_usados_op : [],
            personal_externo: Array.isArray(data.externos_op) ? data.externos_op : [],
            proveedores: Array.isArray(data.proveedor_op) ? data.proveedor_op : [],
            reuniones: Array.isArray(data.reuniones_vinculadas) ? data.reuniones_vinculadas : [],
            cronogramas: Array.isArray(data.cronogramas_vinculados) ? data.cronogramas_vinculados : []
        };
        window.opFotosEvidenciaActuales = Array.isArray(data.fotos_evidencia) ? data.fotos_evidencia : [];
        window.opHabilitadaTemporalmenteFolio = data.habilitada_para_edicion ? data.folio : null;

        container.innerHTML = generarHtmlFormularioOP(data, false);

        // Renderizar los componentes multiselect poblados
        renderMultiSelectComponent('ms-reuniones-act', 'reuniones', cats.reuniones, "Despliega y selecciona una o varias reuniones...");
        renderMultiSelectComponent('ms-cronogramas-act', 'cronogramas', cats.cronogramas, "Despliega y selecciona cronograma(s) de actividades...");
        renderMultiSelectComponent('ms-personal_vpro-act', 'personal_vpro', cats.staff_vpro, "Choose options");
        renderMultiSelectComponent('ms-personal_externo-act', 'personal_externo', cats.apoyos_externos, "Choose options");
        renderMultiSelectComponent('ms-vehiculos-act', 'vehiculos', cats.autos, "Choose options");
        renderMultiSelectComponent('ms-proveedores-act', 'proveedores', cats.proveedores, "Choose options");

        actualizarCrewGira();

        // Consultar si tiene jornadas de gira ya registradas
        cargarJornadasGira(data.id_evento);

    } catch (error) {
        console.error("Error al cargar la orden de producción:", error);
        container.innerHTML = `<p style="color: #ef4444; text-align: center; padding: 20px;">Error al obtener los datos del folio seleccionado: ${error.message}</p>`;
    }
}

// -------------------------------------------------------------
// Carga del Detalle para Bóveda Histórica (Solo Lectura)
// -------------------------------------------------------------
async function cargarDetalleOPHistorico(folioId) {
    const container = document.getElementById('formulario-op-historico-container');
    if (!container) return;
    if (!folioId) {
        container.innerHTML = `<p style="color: var(--text-muted); text-align: center; padding: 20px;">Selecciona una orden histórica arriba para visualizar su expediente.</p>`;
        return;
    }

    container.innerHTML = `<p style="color: var(--text-muted); text-align: center; padding: 30px;">Cargando orden histórica ${folioId}...</p>`;

    try {
        const response = await fetch(`${API_URL}/api/eventos/buscar/${encodeURIComponent(folioId)}`);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const data = await response.json();

        window.opMultiSelects = {
            personal_vpro: Array.isArray(data.personal_convocado_op) ? data.personal_convocado_op : [],
            vehiculos: Array.isArray(data.carros_usados_op) ? data.carros_usados_op : [],
            personal_externo: Array.isArray(data.externos_op) ? data.externos_op : [],
            proveedores: Array.isArray(data.proveedor_op) ? data.proveedor_op : [],
            reuniones: Array.isArray(data.reuniones_vinculadas) ? data.reuniones_vinculadas : [],
            cronogramas: Array.isArray(data.cronogramas_vinculados) ? data.cronogramas_vinculados : []
        };
        window.opFotosEvidenciaActuales = Array.isArray(data.fotos_evidencia) ? data.fotos_evidencia : [];

        const cats = window.vproCatalogosOP || {};
        container.innerHTML = generarHtmlFormularioOP(data, true);

        renderMultiSelectComponent('ms-reuniones-hist', 'reuniones', cats.reuniones, "Sin reuniones", true);
        renderMultiSelectComponent('ms-cronogramas-hist', 'cronogramas', cats.cronogramas, "Sin cronogramas", true);
        renderMultiSelectComponent('ms-personal_vpro-hist', 'personal_vpro', cats.staff_vpro, "Sin personal", true);
        renderMultiSelectComponent('ms-personal_externo-hist', 'personal_externo', cats.apoyos_externos, "Sin externos", true);
        renderMultiSelectComponent('ms-vehiculos-hist', 'vehiculos', cats.autos, "Sin vehículos", true);
        renderMultiSelectComponent('ms-proveedores-hist', 'proveedores', cats.proveedores, "Sin proveedores", true);

        actualizarCrewGira();
        cargarJornadasGira(data.id_evento, true);

    } catch (error) {
        console.error("Error al cargar orden histórica:", error);
        container.innerHTML = `<p style="color: #ef4444; text-align: center; padding: 20px;">Error al obtener los datos de la orden histórica: ${error.message}</p>`;
    }
}

// -------------------------------------------------------------
// Habilitar OP del Histórico para Edición / Evidencias
// -------------------------------------------------------------
async function habilitarOPParaEdicion(folio) {
    if (!folio) {
        alert("⚠️ No se ha seleccionado una OP válida.");
        return;
    }
    const rol = (usuarioLogueado?.rol || '').toUpperCase();
    const esPermitido = (typeof esUsuarioAutorizadoOP === 'function') 
        ? esUsuarioAutorizadoOP() 
        : (rol.includes('ADMIN') || rol.includes('COORDINADOR') || rol.includes('COORDINACION') || rol.includes('PRODUCTOR'));
    if (!esPermitido) {
        alert("⛔ Solo el personal con rol de Coordinador o Administrador puede habilitar OPs del histórico.");
        return;
    }

    const confirmar = confirm(`¿Estás seguro de habilitar la OP "${folio}" para agregar evidencias (fotos/videos) o editar información?\n\nLa orden pasará al Panel de OPs Activas.`);
    if (!confirmar) return;

    try {
        const res = await fetch(`${API_URL}/api/eventos/habilitar-edicion`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                folio: folio,
                usuario: usuarioLogueado?.nombre_completo || "COORDINADOR",
                rol: rol
            })
        });
        const data = await res.json();
        if (res.ok && data.ok) {
            alert(`✅ ${data.mensaje}`);
            // Recargar catálogo de folios
            await inicializarModuloOP();
            // Cambiar a la pestaña de OPs Activas
            cambiarPestanaOP('activas');
            // Seleccionar y cargar la orden habilitada en el panel activo
            const selActivas = document.getElementById('select-folios-op');
            if (selActivas) {
                selActivas.value = folio;
                await cargarDetalleOP(folio);
            }
        } else {
            alert(`❌ Error al habilitar OP: ${data.detail || data.mensaje || 'Error en el servidor'}`);
        }
    } catch (err) {
        console.error("Error al habilitar OP:", err);
        alert(`❌ Error de conexión al habilitar la OP: ${err.message}`);
    }
}

// -------------------------------------------------------------
// Mandar OP al Histórico (Archivar / Modo Solo Lectura)
// -------------------------------------------------------------
async function mandarOPAlHistorial(folio, mostrarConfirmacion = true) {
    if (!folio) {
        alert("⚠️ No se ha especificado el folio de la OP.");
        return;
    }
    const rol = (usuarioLogueado?.rol || '').toUpperCase();
    const esPermitido = (typeof esUsuarioAutorizadoOP === 'function') 
        ? esUsuarioAutorizadoOP() 
        : (rol.includes('ADMIN') || rol.includes('COORDINADOR') || rol.includes('COORDINACION') || rol.includes('PRODUCTOR'));
    if (!esPermitido) {
        alert("⛔ Solo el personal con rol de Coordinador o Administrador puede archivar OPs en el histórico.");
        return;
    }

    if (mostrarConfirmacion) {
        const confirmar = confirm(`¿Estás seguro de enviar la OP "${folio}" al Archivo Histórico?\n\nLa orden quedará en la Bóveda Histórica en modo de solo lectura.`);
        if (!confirmar) return;
    }

    try {
        const res = await fetch(`${API_URL}/api/eventos/mandar-al-historial`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                folio: folio,
                usuario: usuarioLogueado?.nombre_completo || "COORDINADOR",
                rol: rol
            })
        });
        const data = await res.json();
        if (res.ok && data.ok) {
            alert(`📦 ${data.mensaje}`);
            window.opHabilitadaTemporalmenteFolio = null;
            // Recargar catálogo de folios
            await inicializarModuloOP();
            // Cambiar a la pestaña de Bóveda Histórica
            cambiarPestanaOP('historico');
            const selHist = document.getElementById('select-folios-historicos');
            if (selHist) {
                selHist.value = folio;
                await cargarDetalleOPHistorico(folio);
            }
        } else {
            alert(`❌ Error al archivar OP: ${data.detail || data.mensaje || 'Error en el servidor'}`);
        }
    } catch (err) {
        console.error("Error al archivar OP:", err);
        alert(`❌ Error de conexión al archivar la OP: ${err.message}`);
    }
}

// -------------------------------------------------------------
// Bitácora y Chat de WhatsApp Sellado (Captura y Desellado Seguro)
// -------------------------------------------------------------
function filtrarChatPorFechaTexto(textoCompleto, fechaStr) {
    if (!textoCompleto || !fechaStr) return textoCompleto;
    // fechaStr format: YYYY-MM-DD
    const partes = fechaStr.split('-');
    if (partes.length !== 3) return textoCompleto;
    const yyyy = partes[0];
    const mm = partes[1];
    const dd = partes[2];
    const dInt = parseInt(dd, 10);
    const mInt = parseInt(mm, 10);

    // Formato estándar WhatsApp México / Hispanoamérica:
    // [dd/mm/yy, hh:mm:ss] o dd/mm/yy, hh:mm - Nombre:
    const yy = yyyy.substring(2);
    const ddPad = String(dInt).padStart(2, '0');
    const mmPad = String(mInt).padStart(2, '0');

    // Expresión regular estricta: coincide con el inicio de línea o corchete [dd/mm/yyyy o [dd/mm/yy
    const regexEstricto = new RegExp(`^\\[?\\s*0?${dInt}\\/${mmPad}\\/(${yyyy}|${yy})\\b`, 'i');

    const patronNuevoMensaje = /^\s*\[?\s*\d{1,2}\/\d{1,2}\/\d{2,4}\b/;

    const lineas = textoCompleto.split(/\r?\n/);
    const resultado = [];
    let incluyendoMensaje = false;

    for (let i = 0; i < lineas.length; i++) {
        const linea = lineas[i];
        // ¿Inicia un nuevo mensaje con fecha?
        if (patronNuevoMensaje.test(linea)) {
            // Verificar si coincide estrictamente con la fecha Día/Mes/Año objetivo
            if (regexEstricto.test(linea)) {
                incluyendoMensaje = true;
                resultado.push(linea);
            } else {
                incluyendoMensaje = false;
            }
        } else if (incluyendoMensaje) {
            // Línea de continuación de un mensaje del día seleccionado
            resultado.push(linea);
        }
    }

    return resultado.join('\n');
}

async function abrirModalCapturaChat(folio) {
    if (!folio) {
        Swal.fire('Atención', 'No se ha especificado el folio de la OP.', 'warning');
        return;
    }

    // Obtener fecha del evento de la OP si existe en pantalla
    const fechaEventoInput = document.getElementById('op_fec_del_evento')?.value || '';
    const hoyStr = new Date().toISOString().substring(0, 10);
    const fechaSugerida = fechaEventoInput || hoyStr;

    window._rawChatTextoCompleto = '';

    const { value: formValues } = await Swal.fire({
        title: `📥 Integrar Chat WhatsApp - OP ${folio}`,
        html: `
            <div style="text-align: left; font-size: 13.5px; color: #334155;">
                <p style="margin-bottom: 12px; color: #475569; line-height: 1.4;">
                    Sube el archivo <strong>_chat.txt</strong>. El sistema filtrará automáticamente los mensajes del día seleccionado:
                </p>
                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; margin-bottom: 12px;">
                    <label style="font-weight: 600; display: block; margin-bottom: 6px; color: #0f172a;">
                        1. Seleccionar archivo _chat.txt:
                    </label>
                    <input type="file" id="swal-chat-file" accept=".txt" style="width: 100%; padding: 7px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px;" onchange="
                        const f = this.files[0];
                        if (f) {
                            const reader = new FileReader();
                            reader.onload = function(e) {
                                window._rawChatTextoCompleto = e.target.result;
                                const fSel = document.getElementById('swal-chat-fecha')?.value;
                                if (fSel) {
                                    const filtrado = filtrarChatPorFechaTexto(window._rawChatTextoCompleto, fSel);
                                    document.getElementById('swal-chat-text').value = filtrado;
                                    const cLineas = filtrado.trim() ? filtrado.split('\\n').length : 0;
                                    document.getElementById('swal-chat-status').innerText = '✅ ' + cLineas + ' líneas extraídas para el ' + fSel;
                                } else {
                                    document.getElementById('swal-chat-text').value = window._rawChatTextoCompleto;
                                }
                            };
                            reader.readAsText(f, 'UTF-8');
                        }
                    ">
                </div>

                <div style="background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 12px; margin-bottom: 12px;">
                    <label style="font-weight: 600; display: block; margin-bottom: 6px; color: #166534;">
                        📅 2. Filtrar únicamente este día:
                    </label>
                    <div style="display: flex; gap: 8px; align-items: center;">
                        <input type="date" id="swal-chat-fecha" value="${fechaSugerida}" style="padding: 8px 12px; border: 1px solid #86efac; border-radius: 6px; font-size: 13.5px; font-weight: 600; outline: none;" onchange="
                            if (window._rawChatTextoCompleto) {
                                const filtrado = filtrarChatPorFechaTexto(window._rawChatTextoCompleto, this.value);
                                document.getElementById('swal-chat-text').value = filtrado;
                                const cLineas = filtrado.trim() ? filtrado.split('\\n').length : 0;
                                document.getElementById('swal-chat-status').innerText = '✅ ' + cLineas + ' líneas extraídas para el ' + this.value;
                            }
                        ">
                        <button type="button" style="background: #16a34a; color: white; border: none; padding: 8px 14px; border-radius: 6px; font-weight: 600; font-size: 12.5px; cursor: pointer;" onclick="
                            const fSel = document.getElementById('swal-chat-fecha')?.value;
                            const tOrigen = window._rawChatTextoCompleto || document.getElementById('swal-chat-text')?.value;
                            if (fSel && tOrigen) {
                                const filtrado = filtrarChatPorFechaTexto(tOrigen, fSel);
                                document.getElementById('swal-chat-text').value = filtrado;
                                const cLineas = filtrado.trim() ? filtrado.split('\\n').length : 0;
                                document.getElementById('swal-chat-status').innerText = '✅ ' + cLineas + ' líneas extraídas para el ' + fSel;
                            }
                        ">
                            Filtrar este día
                        </button>
                    </div>
                    <div id="swal-chat-status" style="font-size: 12px; color: #15803d; font-weight: 600; margin-top: 6px;"></div>
                </div>

                <div>
                    <label style="font-weight: 600; display: block; margin-bottom: 4px; color: #0f172a;">
                        Vista previa de los mensajes que se sellarán:
                    </label>
                    <textarea id="swal-chat-text" rows="8" placeholder="Aquí aparecerán filtrados solo los mensajes del día elegido..." style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-family: monospace; font-size: 12px; box-sizing: border-box; resize: vertical; background: #ffffff;"></textarea>
                </div>
            </div>
        `,
        width: '680px',
        showCancelButton: true,
        confirmButtonText: '💾 Sellar Chat Filtrado en Historial',
        cancelButtonText: 'Cancelar',
        confirmButtonColor: '#25D366',
        preConfirm: () => {
            const chatTexto = document.getElementById('swal-chat-text')?.value?.trim();
            if (!chatTexto) {
                Swal.showValidationMessage('No hay mensajes seleccionados para sellar. Revisa el archivo o la fecha.');
                return false;
            }
            return { chatTexto };
        }
    });

    if (formValues && formValues.chatTexto) {
        Swal.fire({
            title: 'Guardando y sellando chat...',
            text: 'Por favor espera un momento.',
            allowOutsideClick: false,
            didOpen: () => Swal.showLoading()
        });

        try {
            const rol = (usuarioLogueado?.rol || '').toUpperCase();
            const usuario = usuarioLogueado?.nombre_completo || 'COORDINADOR';
            const res = await fetch(`${API_URL}/api/eventos/guardar-chat`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    folio: folio,
                    chat_texto: formValues.chatTexto,
                    usuario: usuario,
                    rol: rol
                })
            });
            const data = await res.json();
            if (res.ok && data.ok) {
                Swal.fire({
                    icon: 'success',
                    title: '¡Chat Sellado con Éxito!',
                    text: data.mensaje || 'La bitácora de chat ha sido integrada y sellada en el expediente de la OP.',
                    confirmButtonColor: '#16a34a'
                });
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error al sellar chat',
                    text: data.detail || 'Ocurrió un error en el servidor.'
                });
            }
        } catch (err) {
            Swal.fire({
                icon: 'error',
                title: 'Error de conexión',
                text: err.message
            });
        }
    }
}

async function solicitarDesellarChat(folio) {
    if (!folio) {
        Swal.fire('Atención', 'No se ha especificado el folio de la OP.', 'warning');
        return;
    }

    const nombreUsuario = (usuarioLogueado?.nombre_completo || '').toUpperCase();
    const esAutorizado = nombreUsuario.includes('VILLARREAL') || nombreUsuario.includes('AGUNDEZ');

    if (!esAutorizado) {
        Swal.fire({
            icon: 'error',
            title: 'Acceso Restringido',
            html: `
                <div style="font-size: 14px; color: #475569; text-align: center;">
                    <p>🔒 Este registro de chat se encuentra <strong>sellado bajo custodia</strong> para fines de aclaraciones y auditoría.</p>
                    <p style="margin-top: 8px; color: #b91c1c; font-weight: 600;">
                        Solo personal de Dirección con apellido <u>Villarreal</u> o <u>Agundez</u> tiene autorización para abrirlo.
                    </p>
                </div>
            `,
            confirmButtonColor: '#334155'
        });
        return;
    }

    // Si es Villarreal o Agundez, solicitar contraseña
    const { value: passIngresada } = await Swal.fire({
        title: '🔐 Autorización de Seguridad',
        html: `
            <div style="font-size: 13.5px; color: #334155; text-align: left; margin-bottom: 12px;">
                <p>Hola <strong>${usuarioLogueado?.nombre_completo || 'Usuario'}</strong>,</p>
                <p>Para desellar y consultar la bitácora de chat de la <strong>OP ${folio}</strong>, ingresa tu contraseña de acceso:</p>
            </div>
            <input type="password" id="swal-pass-chat" class="swal2-input" placeholder="Tu contraseña de usuario" style="margin: 0 auto; width: 85%;">
        `,
        focusConfirm: false,
        showCancelButton: true,
        confirmButtonText: '🔓 Desellar y Consultar',
        cancelButtonText: 'Cancelar',
        confirmButtonColor: '#1e293b',
        preConfirm: () => {
            const pass = document.getElementById('swal-pass-chat')?.value;
            if (!pass) {
                Swal.showValidationMessage('Debes ingresar tu contraseña.');
                return false;
            }
            return pass;
        }
    });

    if (passIngresada) {
        Swal.fire({
            title: 'Verificando credenciales...',
            allowOutsideClick: false,
            didOpen: () => Swal.showLoading()
        });

        try {
            const usuario = usuarioLogueado?.nombre_completo || '';
            const res = await fetch(`${API_URL}/api/eventos/consultar-chat`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    folio: folio,
                    usuario: usuario,
                    password: passIngresada
                })
            });

            const data = await res.json();
            if (res.ok && data.ok) {
                const contenido = data.chat_historial || '';
                if (!contenido.trim()) {
                    Swal.fire({
                        icon: 'info',
                        title: 'Expediente Sellado Vacío',
                        text: `La OP ${folio} no cuenta aún con chat de WhatsApp registrado.`,
                        confirmButtonColor: '#334155'
                    });
                    return;
                }

                const lineas = contenido.split('\n');
                const totalLineas = lineas.length;

                // Escapar HTML seguro
                const seguroHtml = contenido
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;');

                Swal.fire({
                    title: `📜 Chat WhatsApp Sellado - OP ${folio}`,
                    html: `
                        <div style="text-align: left; font-size: 13px;">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; background: #f1f5f9; padding: 8px 12px; border-radius: 6px;">
                                <span style="color: #475569; font-weight: 600;">📊 ${totalLineas} línea(s) registradas</span>
                                <span style="color: #16a34a; font-weight: 600;">🔒 Desellado por: ${usuarioLogueado?.nombre_completo || 'Dirección'}</span>
                            </div>
                            <div id="contenedor-texto-chat-sellado" style="max-height: 420px; overflow-y: auto; background: #0f172a; color: #e2e8f0; padding: 14px; border-radius: 8px; font-family: 'Consolas', 'Courier New', monospace; font-size: 12px; line-height: 1.6; white-space: pre-wrap; word-break: break-word; text-align: left; border: 1px solid #334155;">${seguroHtml}</div>
                            <div style="margin-top: 12px; display: flex; justify-content: space-between; align-items: center;">
                                <span style="font-size: 11.5px; color: #94a3b8;">⚠️ Documento Confidencial - Exclusivo para aclaraciones de la OP.</span>
                                <button type="button" id="btn-copiar-chat-sellado" style="background: #334155; color: white; border: none; padding: 6px 14px; border-radius: 6px; font-size: 12px; cursor: pointer; display: flex; align-items: center; gap: 6px;">
                                    📋 Copiar Texto
                                </button>
                            </div>
                        </div>
                    `,
                    width: '850px',
                    confirmButtonText: 'Cerrar Bitácora',
                    confirmButtonColor: '#1e293b',
                    didOpen: () => {
                        const btnCopiar = document.getElementById('btn-copiar-chat-sellado');
                        if (btnCopiar) {
                            btnCopiar.onclick = () => {
                                const texto = document.getElementById('contenedor-texto-chat-sellado')?.innerText || '';
                                navigator.clipboard.writeText(texto).then(() => {
                                    btnCopiar.innerText = '✅ ¡Copiado!';
                                    setTimeout(() => { btnCopiar.innerText = '📋 Copiar Texto'; }, 2000);
                                });
                            };
                        }
                    }
                });
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Acceso Denegado',
                    text: data.detail || 'Contraseña incorrecta o permisos insuficientes.',
                    confirmButtonColor: '#ef4444'
                });
            }
        } catch (err) {
            Swal.fire({
                icon: 'error',
                title: 'Error de conexión',
                text: err.message
            });
        }
    }
}

// -------------------------------------------------------------
// Bitácora de Gira y Horas de Locación
// -------------------------------------------------------------
function toggleBitacoraGira() {
    const contenedor = document.getElementById("contenedor-bitacora-gira");
    const switchBg = document.getElementById("toggle-switch-gira");
    const knob = document.getElementById("knob-switch-gira");
    if (!contenedor || !switchBg || !knob) return;

    if (contenedor.style.display === "none") {
        contenedor.style.display = "block";
        switchBg.style.background = "#ef4444";
        knob.style.left = "23px";
        actualizarCrewGira();
    } else {
        contenedor.style.display = "none";
        switchBg.style.background = "#cbd5e1";
        knob.style.left = "3px";
    }
}

async function cargarJornadasGira(idEvento, isReadOnly = false) {
    const contenedor = document.getElementById("contenedor-jornadas-guardadas");
    if (!contenedor || !idEvento) return;

    try {
        const res = await fetch(`${API_URL}/api/asistencia/locacion/${idEvento}`);
        if (!res.ok) return;
        const jornadas = await res.json();

        if (jornadas && jornadas.length > 0) {
            // Activar automáticamente el toggle
            const contenedorGira = document.getElementById("contenedor-bitacora-gira");
            const switchBg = document.getElementById("toggle-switch-gira");
            const knob = document.getElementById("knob-switch-gira");
            if (contenedorGira) contenedorGira.style.display = "block";
            if (switchBg) switchBg.style.background = "#ef4444";
            if (knob) knob.style.left = "23px";

            // Agrupar por fecha_jornada
            const porFecha = {};
            jornadas.forEach(j => {
                const f = j.fecha_jornada;
                if (!porFecha[f]) porFecha[f] = [];
                porFecha[f].push(j);
            });

            const fechasOrdenadas = Object.keys(porFecha).sort();
            contenedor.innerHTML = fechasOrdenadas.map(fecha => {
                const registros = porFecha[fecha];
                const rowsHtml = registros.map(r => `
                    <tr>
                        <td style="font-weight: 600; color: #1e293b;">${r.nombre_empleado}</td>
                        <td><input type="text" class="op-input input-jornada-${fecha}" data-field="hora_entrada" data-emp="${r.nombre_empleado}" value="${(r.hora_entrada || '00:00:00').substring(0, 5)}" style="padding: 6px; width: 70px; text-align: center;" ${isReadOnly ? 'disabled' : ''}></td>
                        <td><input type="number" step="0.5" class="op-input input-jornada-${fecha}" data-field="t_desayuno" data-emp="${r.nombre_empleado}" value="${r.t_desayuno || 0}" style="padding: 6px; width: 60px; text-align: center;" ${isReadOnly ? 'disabled' : ''}></td>
                        <td><input type="number" step="0.5" class="op-input input-jornada-${fecha}" data-field="t_comida" data-emp="${r.nombre_empleado}" value="${r.t_comida || 0}" style="padding: 6px; width: 60px; text-align: center;" ${isReadOnly ? 'disabled' : ''}></td>
                        <td><input type="number" step="0.5" class="op-input input-jornada-${fecha}" data-field="t_cena" data-emp="${r.nombre_empleado}" value="${r.t_cena || 0}" style="padding: 6px; width: 60px; text-align: center;" ${isReadOnly ? 'disabled' : ''}></td>
                        <td><input type="text" class="op-input input-jornada-${fecha}" data-field="hora_salida" data-emp="${r.nombre_empleado}" value="${(r.hora_salida || '00:00:00').substring(0, 5)}" style="padding: 6px; width: 70px; text-align: center;" ${isReadOnly ? 'disabled' : ''}></td>
                        <td><input type="text" class="op-input input-jornada-${fecha}" data-field="observaciones" data-emp="${r.nombre_empleado}" value="${r.observaciones || ''}" style="padding: 6px; width: 100%;" placeholder="Notas..." ${isReadOnly ? 'disabled' : ''}></td>
                    </tr>
                `).join('');

                return `
                    <div style="border: 1px solid #cbd5e1; border-radius: 8px; margin-bottom: 16px; overflow: hidden; background: white;">
                        <div style="background: #f8fafc; padding: 12px 16px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
                            <strong style="color: #1e293b;">🔒 Jornada Registrada: ${fecha}</strong>
                            ${!isReadOnly ? `
                                <button type="button" onclick="guardarJornadaGira(${idEvento}, '${fecha}')" style="background: #10b981; color: white; border: none; padding: 6px 14px; border-radius: 4px; font-weight: 600; font-size: 12.5px; cursor: pointer;">
                                    💾 Guardar Correcciones
                                </button>
                            ` : ''}
                        </div>
                        <div class="tabla-container" style="max-height: 250px;">
                            <table class="tabla-vpro">
                                <thead>
                                    <tr>
                                        <th>Empleado</th>
                                        <th>Entrada</th>
                                        <th>Hrs Desayuno</th>
                                        <th>Hrs Comida</th>
                                        <th>Hrs Cena</th>
                                        <th>Salida</th>
                                        <th>Notas</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    ${rowsHtml}
                                </tbody>
                            </table>
                        </div>
                    </div>
                `;
            }).join('');
        } else {
            contenedor.innerHTML = '';
            const contenedorGira = document.getElementById("contenedor-bitacora-gira");
            const switchBg = document.getElementById("toggle-switch-gira");
            const knob = document.getElementById("knob-switch-gira");
            if (contenedorGira) contenedorGira.style.display = "none";
            if (switchBg) switchBg.style.background = "#cbd5e1";
            if (knob) knob.style.left = "3px";
        }
    } catch (e) {
        console.error("Error al cargar jornadas de gira:", e);
    }
}

async function guardarJornadaGira(idEvento, fecha) {
    const inputs = document.querySelectorAll(`.input-jornada-${fecha}`);
    if (!inputs || inputs.length === 0) return;

    // Agrupar por empleado
    const porEmp = {};
    inputs.forEach(inp => {
        const emp = inp.getAttribute('data-emp');
        const field = inp.getAttribute('data-field');
        if (!porEmp[emp]) {
            porEmp[emp] = {
                fecha_jornada: fecha,
                num_empleado: 0,
                nombre_empleado: emp,
                depto: "STAFF VPRO",
                hora_entrada: "00:00:00",
                t_desayuno: 0.0,
                t_comida: 0.0,
                t_cena: 0.0,
                hora_salida: "00:00:00",
                observaciones: ""
            };
        }
        let val = inp.value.trim();
        if (field === 'hora_entrada' || field === 'hora_salida') {
            if (val && val.length === 5) val = val + ":00";
            if (!val) val = "00:00:00";
            porEmp[emp][field] = val;
        } else if (field.startsWith('t_')) {
            porEmp[emp][field] = parseFloat(val) || 0.0;
        } else {
            porEmp[emp][field] = val;
        }
    });

    const payload = { registros: Object.values(porEmp) };

    try {
        const res = await fetch(`${API_URL}/api/asistencia/locacion/${idEvento}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });
        if (res.ok) {
            alert(`✅ Jornada de fecha ${fecha} actualizada correctamente.`);
            cargarJornadasGira(idEvento);
        } else {
            alert("❌ Error al guardar las correcciones de la jornada.");
        }
    } catch (err) {
        alert(`❌ Error de red: ${err.message}`);
    }
}

async function crearNuevoDiaGira(idEvento) {
    const crew = window.opMultiSelects.personal_vpro || [];
    if (crew.length === 0) {
        alert("⚠️ Atención: Debes seleccionar personal en 'SELECCIONAR PERSONAL VPRO' arriba para poder tomar asistencia.");
        return;
    }

    const inputFecha = document.getElementById("input-nueva-fecha-gira");
    const fechaSeleccionada = inputFecha?.value;
    if (!fechaSeleccionada) {
        alert("Selecciona una fecha válida.");
        return;
    }

    const registrosNuevos = crew.map(persona => ({
        fecha_jornada: String(fechaSeleccionada),
        num_empleado: 0,
        nombre_empleado: String(persona).trim(),
        depto: "STAFF VPRO",
        hora_entrada: "00:00:00",
        t_desayuno: 0.0,
        t_comida: 0.0,
        t_cena: 0.0,
        hora_salida: "00:00:00",
        observaciones: ""
    }));

    try {
        const res = await fetch(`${API_URL}/api/asistencia/locacion/${idEvento}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ registros: registrosNuevos })
        });
        if (res.ok) {
            alert(`✅ ¡Día ${fechaSeleccionada} agregado! Ya puedes asignar las horas.`);
            cargarJornadasGira(idEvento);
        } else {
            alert("❌ Error del servidor al crear la nueva jornada.");
        }
    } catch (e) {
        alert(`❌ Error de conexión: ${e.message}`);
    }
}

// -------------------------------------------------------------
// Guardado Maestro de la Orden de Producción
// -------------------------------------------------------------
async function guardarOrdenOP(event) {
    if (event) event.preventDefault();

    const id_evento = document.getElementById("op_id_evento")?.value;
    const folio = document.getElementById("op_folio")?.value;
    const para_q_cliente = document.getElementById("op_para_q_cliente")?.value;
    const nombre_evento = document.getElementById("op_nombre_evento")?.value;
    const locacion = document.getElementById("op_locacion")?.value;
    const fec_de_instalacion = document.getElementById("op_fec_de_instalacion")?.value;
    const hra_de_instalacion = document.getElementById("op_hra_de_instalacion")?.value;
    const dependencia_solicita = document.getElementById("op_dependencia_solicita")?.value;
    const quien_solicita = document.getElementById("op_quien_solicita")?.value;
    const resp_de_produccion = document.getElementById("op_resp_de_produccion")?.value;
    const fec_del_evento = document.getElementById("op_fec_del_evento")?.value;
    const fec_fin_evento = document.getElementById("op_fec_fin_evento")?.value;
    const estimado_gasto = document.getElementById("op_estimado_gasto")?.value;
    const inicio_del_evento = document.getElementById("op_inicio_del_evento")?.value;
    const hra_de_llamado = document.getElementById("op_hra_de_llamado")?.value;
    const ubicacion = document.getElementById("op_ubicacion")?.value;
    const tipo_de_servicio = document.getElementById("op_tipo_de_servicio")?.value;
    const produccion = document.getElementById("op_produccion")?.value;
    const internet_redes = document.getElementById("op_internet_redes")?.value;
    const actividades_de_proveedores = document.getElementById("op_actividades_de_proveedores")?.value;
    const nota = document.getElementById("op_nota")?.value;
    const elabora = document.getElementById("op_elabora")?.value;
    const coordina = document.getElementById("op_coordina")?.value;
    const organiza = document.getElementById("op_organiza")?.value;
    const vobo = document.getElementById("op_vobo")?.value;

    const subtitulo_evento = document.getElementById("op_subtitulo_evento")?.value;
    const detalle_llamado = document.getElementById("op_detalle_llamado")?.value;
    const rol_juegos = document.getElementById("op_rol_juegos")?.value;
    const vehiculo_destino = document.getElementById("op_vehiculo_destino")?.value;

    const payload = {
        id_evento: parseInt(id_evento) || 0,
        folio: folio || String(id_evento),
        para_q_cliente: para_q_cliente || "",
        nombre_evento: nombre_evento || "",
        subtitulo_evento: (subtitulo_evento || "").trim(),
        locacion: locacion || "",
        fec_de_instalacion: fec_de_instalacion || null,
        hra_de_instalacion: hra_de_instalacion ? (hra_de_instalacion.length === 5 ? hra_de_instalacion + ":00" : hra_de_instalacion) : null,
        dependencia_solicita: (dependencia_solicita || "").trim(),
        quien_solicita: (quien_solicita || "").trim(),
        resp_de_produccion: resp_de_produccion || "",
        fec_del_evento: fec_del_evento || null,
        fec_fin_evento: fec_fin_evento || fec_del_evento || null,
        estimado_gasto: parseFloat(estimado_gasto) || 0.0,
        inicio_del_evento: inicio_del_evento ? (inicio_del_evento.length === 5 ? inicio_del_evento + ":00" : inicio_del_evento) : null,
        hra_de_llamado: hra_de_llamado ? (hra_de_llamado.length === 5 ? hra_de_llamado + ":00" : hra_de_llamado) : null,
        detalle_llamado: (detalle_llamado || "").trim(),
        ubicacion: ubicacion || "",
        vehiculo_destino: (vehiculo_destino || "").trim(),
        rol_juegos: (rol_juegos || "").trim(),
        tipo_de_servicio: tipo_de_servicio || "",
        produccion: produccion || "",
        internet_redes: internet_redes || "",
        actividades_de_proveedores: actividades_de_proveedores || "",
        nota: nota || "",
        elabora: elabora || "",
        coordina: coordina || "",
        organiza: organiza || "",
        vobo: vobo || "",
        personal_convocado_op: window.opMultiSelects.personal_vpro || [],
        carros_usados_op: window.opMultiSelects.vehiculos || [],
        externos_op: window.opMultiSelects.personal_externo || [],
        proveedor_op: window.opMultiSelects.proveedores || [],
        reuniones_vinculadas: window.opMultiSelects.reuniones || [],
        cronogramas_vinculados: window.opMultiSelects.cronogramas || [],
        fotos_evidencia: window.opFotosEvidenciaActuales || [],
        empleado_que_creo_la_op: usuarioLogueado ? usuarioLogueado.nombre_completo : ""
    };

    try {
        const respuesta = await fetch(`${API_URL}/api/eventos/guardar`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        const resultado = await respuesta.json();

        if (respuesta.ok && resultado.status === "SUCCESS") {
            alert(`✅ ¡Orden de Producción "${folio || nombre_evento}" guardada exitosamente!`);

            // Si la OP fue habilitada temporalmente desde el histórico, sugerir regresarla al archivo histórico
            if (window.opHabilitadaTemporalmenteFolio && window.opHabilitadaTemporalmenteFolio === folio) {
                const regresar = confirm(`¿Deseas mandar la OP "${folio}" de nuevo al Archivo Histórico ahora que guardaste los cambios/evidencias?`);
                if (regresar) {
                    await mandarOPAlHistorial(folio, false);
                    return;
                }
            }

            // Recargar folios y seleccionar el folio guardado
            await inicializarModuloOP();
            const selectFolios = document.getElementById('select-folios-op');
            if (selectFolios) {
                selectFolios.value = folio;
                cargarDetalleOP(folio);
            }
        } else {
            alert(`❌ Error al guardar: ${resultado.detail || 'Ocurrió un error en el servidor.'}`);
        }
    } catch (err) {
        console.error("Error al guardar la orden:", err);
        alert(`❌ Error de conexión al guardar la orden: ${err.message}`);
    }
}

