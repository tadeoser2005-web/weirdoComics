// ===== Menú lateral compartido =====
// Cada pantalla solo pone <aside id="sidebar" data-activo="Inicio"></aside>
// y este script dibuja el menú. Si cambia el menú, se cambia aquí una sola vez.

const MODULOS = [
    { nombre: "Inicio",          archivo: "inicio.html" },
    { nombre: "Ventas",          archivo: "ventas.html" },
    { nombre: "Inventario",      archivo: "inventario.html" },
    { nombre: "Proveedores",     archivo: "proveedores.html" },
    { nombre: "Pedidos",         archivo: "pedidos.html" },
    { nombre: "Reportes",        archivo: "reportes.html", separar: true },
    { nombre: "Usuarios",        archivo: "usuarios.html" },
    { nombre: "Roles y permisos", archivo: "roles.html" }
];

function pintarSidebar() {
    const aside = document.getElementById("sidebar");
    const activo = aside.dataset.activo;

    // El rol se guarda al iniciar sesión; si no hay, por ahora es Administrador
    // try/catch: algunos navegadores/vistas previas bloquean sessionStorage y el menú no debe morir por eso
    let rol = "Administrador";
    try {
        rol = sessionStorage.getItem("rol") || "Administrador";
    } catch (e) {
        console.warn("sessionStorage no disponible, uso rol por defecto");
    }

    const enlaces = MODULOS.map(m => {
        const clases = [
            m.nombre === activo ? "activo" : "",
            m.separar ? "separar" : ""
        ].join(" ").trim();
        return `<a href="${m.archivo}" class="${clases}">${m.nombre}</a>`;
    }).join("");

    aside.className = "sidebar";
    aside.innerHTML = `
    <div class="logo">
      <span class="rojo">WEIRDO</span>
      <span class="blanco">COMICS</span>
    </div>
    <div class="rol">${rol}</div>
    <nav>${enlaces}</nav>
    <a href="./index.php" class="cerrar" id="cerrar-sesion">Cerrar sesión</a>
  `;

    // Al cerrar sesión se limpia lo guardado
    document.getElementById("cerrar-sesion").addEventListener("click", () => {
        try { sessionStorage.clear(); } catch (e) { /* nada que limpiar */ }
    });
}

pintarSidebar();