// ==============================================================================
// MÓDULO: core.js
// 1. Config global, API_URL, estado, helpers de fecha
// Líneas originales: 1–15 de script.js
// ==============================================================================

// ==============================================================================
// SISTEMA INTEGRAL DIGITAL - VPRO STREAMING SERVICES
// ARCHIVO: script.js (Cliente Web SPA Frontend)
// ==============================================================================

// 1. CONFIGURACIÓN Y VARIABLES GLOBALES
const API_URL = (window.location.origin && window.location.origin !== "null" && window.location.port !== "5500")
    ? window.location.origin
    : (localStorage.getItem("vpro_api_url") || `${window.location.protocol === "https:" ? "https:" : "http:"}//${window.location.hostname || "localhost"}:8521`); 

let usuarioLogueado = null;
let empleadoSeleccionado = null;
let memoriaKiosco = {}; 
let intervaloReloj = null;

