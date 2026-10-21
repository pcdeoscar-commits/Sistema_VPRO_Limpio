// ==============================================================================
// MÓDULO: manual.js
// 10. Manual / Ayuda modal
// Líneas originales: 5207–5219 de script.js
// ==============================================================================

// ==========================================
// 10. MANUAL / AYUDA MODAL
// ==========================================
function abrirManual() {
    const modal = document.getElementById("modal-manual");
    if (modal) modal.style.display = "flex";
}

function cerrarManual() {
    const modal = document.getElementById("modal-manual");
    if (modal) modal.style.display = "none";
}

