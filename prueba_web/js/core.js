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

// 🔐 Interceptor global de fetch: adjunta JWT Bearer automáticamente a peticiones hacia API_URL
(function() {
    const _fetchOriginal = window.fetch;
    window.fetch = function(input, init = {}) {
        try {
            const url = typeof input === "string" ? input : (input && input.url ? input.url : "");
            if (url && url.startsWith(API_URL)) {
                const token = localStorage.getItem("vpro_token") || (usuarioLogueado && usuarioLogueado.access_token) || "";
                if (token) {
                    const headers = new Headers(init.headers || (input instanceof Request ? input.headers : undefined) || {});
                    if (!headers.has("Authorization")) {
                        headers.set("Authorization", `Bearer ${token}`);
                    }
                    init = { ...init, headers };
                }
            }
        } catch (e) {}
        return _fetchOriginal.call(this, input, init);
    };
})();

