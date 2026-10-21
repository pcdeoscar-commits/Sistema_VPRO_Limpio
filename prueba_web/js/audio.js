// ==============================================================================
// MÓDULO: audio.js
// 8b. Sistema de audio programado + saludo por voz
// Líneas originales: 13321–13465 de script.js
// ==============================================================================

// ==========================================
// 8. SISTEMA DE AUDIO PROGRAMADO (AUDÍFONOS AMIGABLES)
// ==========================================
let audioCtx = null;
let ultimoAlarmaDisparada = "";

// Inicializa o reanuda el contexto de audio tras interacción
function obtenerAudioContext() {
    if (!audioCtx) {
        const AudioContextClass = window.AudioContext || window.webkitAudioContext;
        audioCtx = new AudioContextClass();
    }
    if (audioCtx.state === 'suspended') {
        audioCtx.resume();
    }
    return audioCtx;
}

// Genera una nota senoidal suave con ataque y decaimiento
function tocarNota(frecuencia, tiempoInicio, duracion, volumenMax = 0.25) {
    const ctx = obtenerAudioContext();
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();

    osc.type = 'sine'; // Onda senoidal: la más pura y suave al oído
    osc.frequency.setValueAtTime(frecuencia, tiempoInicio);

    // Curva de volumen: Fade-in suave (anti-pop) y Fade-out gradual
    gain.gain.setValueAtTime(0.0001, tiempoInicio);
    gain.gain.exponentialRampToValueAtTime(volumenMax, tiempoInicio + 0.04);
    gain.gain.exponentialRampToValueAtTime(0.0001, tiempoInicio + duracion);

    osc.connect(gain);
    gain.connect(ctx.destination);

    osc.start(tiempoInicio);
    osc.stop(tiempoInicio + duracion);
}

// 🟢 SONIDO DE ENTRADA (09:00 y 16:00) - Arpegio ascendente limpio
function sonarEntrada() {
    const ctx = obtenerAudioContext();
    const ahora = ctx.currentTime;
    // Tono 1 (ENTRADA): Campanada Brillante y Energética (5 segundos)
    tocarNota(523.25, ahora, 5.0, 0.5); // C5 (Fundamental)
    tocarNota(880.00, ahora, 4.5, 0.2); // A5 (Armónico)
    tocarNota(1046.50, ahora, 4.0, 0.15); // C6 (Brillo)
}

// 🔴 SONIDO DE SALIDA (14:00 y 19:00) - Acorde relajante de descanso
function sonarSalida() {
    const ctx = obtenerAudioContext();
    const ahora = ctx.currentTime;
    // Tono 2 (SALIDA): Campanada Grave y Relajante (5 segundos)
    tocarNota(349.23, ahora, 5.0, 0.5); // F4 (Fundamental grave)
    tocarNota(440.00, ahora, 4.5, 0.2); // A4 (Armónico)
    tocarNota(698.46, ahora, 4.0, 0.15); // F5 (Brillo suave)
}

// ⏱️ VIGILANTE DE HORARIOS (Checa cada segundo)
function verificarHorariosCampana() {
    const ahora = new Date();
    // Formato 'HH:MM' (ejemplo: '09:00', '14:00')
    const horaActual = ahora.toLocaleTimeString('es-MX', { 
        hour: '2-digit', 
        minute: '2-digit', 
        hour12: false 
    });

    // Si cambió el minuto y es una de las 4 horas clave
    if (horaActual !== ultimoAlarmaDisparada) {
        if (horaActual === "09:00" || horaActual === "16:00") {
            ultimoAlarmaDisparada = horaActual;
            sonarEntrada();
            console.log(`🔔 Sonido de ENTRADA ejecutado a las ${horaActual}`);
        } else if (horaActual === "14:00" || horaActual === "19:00") {
            ultimoAlarmaDisparada = horaActual;
            sonarSalida();
            console.log(`🔔 Sonido de SALIDA ejecutado a las ${horaActual}`);
        }
    }
}
// ==========================================
// 🔊 DICCIONARIO DE NOMBRES CORTOS Y SALUDO POR VOZ
// ==========================================
const NOMBRES_CORTOS = {
    "101": "Señora Ana Lilia",
    "102": "Gerardo",
    "104": "Paco",
    "105": "Dany",
    "107": "Geo",
    "109": "Osiel",
    "113": "Carlos",
    "115": "Ibón",
    "119": "Manny",
    "121": "Sofía",
    "122": "Andrea",
    "124": "Manuel",                // Manuel Eduardo (Coordinador)
    "125": "Diego",
    "200": "Licenciada Andrea",
    "201": "Cuauhtémoc",
    "202": "Amarillas",
    "203": "Señor Pedro Villarreal"
};

function decirSaludoKiosco(idEmpleado = "", nombreCompleto = "") {
    if (!('speechSynthesis' in window)) return;

    const idLimpio = String(idEmpleado).trim();
    let sujeto = "";

    // 1. Prioridad: Nombre corto / preferido de la lista
    if (NOMBRES_CORTOS[idLimpio]) {
        sujeto = NOMBRES_CORTOS[idLimpio];
    } 
    // 2. Si es alguien nuevo que no está en la lista, toma su primer nombre
    else if (nombreCompleto) {
        sujeto = nombreCompleto.trim().split(' ')[0];
    }

    // 3. Saludo cordial según la hora del día
    const hora = new Date().getHours();
    let saludo = "Hola";
    if (hora >= 5 && hora < 12) {
        saludo = "Buenos días";
    } else if (hora >= 12 && hora < 19) {
        saludo = "Buenas tardes";
    } else {
        saludo = "Buenas noches";
    }

    // Armamos la frase completa
    const mensajeVoz = sujeto ? `${saludo}, ${sujeto}.` : `${saludo}.`;

    const locucion = new SpeechSynthesisUtterance(mensajeVoz);
    locucion.lang = 'es-MX';  // Voz en español latino / México
    locucion.rate = 0.95;     // Ritmo natural pausado
    locucion.pitch = 1.0;     // Tono medio cálido
    locucion.volume = 0.80;   // Nivel cómodo para audífonos

    // Evita encimar voces si pasan varios rápido
    window.speechSynthesis.cancel();
    window.speechSynthesis.speak(locucion);
}

