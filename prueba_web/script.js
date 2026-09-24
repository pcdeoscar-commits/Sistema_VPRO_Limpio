const API_URL = "https://172.16.0.20:8000"; 
let empleadoSeleccionado = null;

async function cargarEmpleados() {
    const contenedor = document.getElementById("contenedor-empleados");

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
                <img src="${urlFoto}" onerror="this.src='https://cdn-icons-png.flaticon.com/512/3135/3135715.png'" alt="Foto">
                <h3>${nombreFormateado}</h3>
                <p style="margin-bottom: 0;">${emp.depto || 'SISTEMAS'}</p>
            `;
            
            contenedor.appendChild(tarjeta);
        });

    } catch (error) {
        console.error("Fallo la conexión con FastAPI:", error);
        contenedor.innerHTML = `
            <div style="grid-column: 1 / -1; background: #fee2e2; border: 1px solid #f87171; padding: 16px; border-radius: 8px; color: #991b1b;">
                <strong>Error de conexión:</strong> No se pudo conectar con el servidor FastAPI.
            </div>`;
    }
}

// Control de apertura de la ventana emergente
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

// Cierre de la ventana
function cerrarModal() {
    document.getElementById("modal-login").style.display = "none";
    empleadoSeleccionado = null;
}

// Validación de la contraseña con FastAPI
async function verificarAcceso() {
    const password = document.getElementById("modal-password").value;
    const errorMsg = document.getElementById("modal-error");

    if (!password) {
        errorMsg.innerText = "Por favor ingresa tu contraseña.";
        errorMsg.style.display = "block";
        return;
    }

    try {
        // Apuntamos a la ruta completa: /api/auth/login
        const respuesta = await fetch(`${API_URL}/api/auth/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                usuario: empleadoSeleccionado.nombre, // Tu backend busca por nombre completo
                contrasena: password                 // Campo esperado por LoginRequest
            })
        });

        const resultado = await respuesta.json();

        if (respuesta.ok && resultado.autenticado) {
            cerrarModal();
            iniciarSesionExitosa(resultado); // Esta línea es la que hace la magia de cambiar la pantalla
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

cargarEmpleados();
// Transición hacia el interior del sistema
function iniciarSesionExitosa(usuario) {
    // 1. Ocultar la vista de login
    document.getElementById("vista-login").style.display = "none";
    
    // 2. Mostrar el menú lateral y el dashboard
    document.getElementById("sidebar").style.display = "flex";
    document.getElementById("vista-dashboard").style.display = "block";
    
    // 3. Personalizar el área de trabajo con los datos del usuario
    const primerNombre = usuario.nombre_completo.split(' ')[0];
    const nombreFormateado = primerNombre.charAt(0).toUpperCase() + primerNombre.slice(1).toLowerCase();
    
    document.getElementById("dash-titulo").innerText = `¡Hola, ${nombreFormateado}!`;
    document.getElementById("dash-subtitulo").innerText = `Nivel de acceso: ${usuario.rol}`;
}

// Botón para salir y volver al inicio
function cerrarSesion() {
    document.getElementById("sidebar").style.display = "none";
    document.getElementById("vista-dashboard").style.display = "none";
    document.getElementById("vista-login").style.display = "block";
    empleadoSeleccionado = null;
}