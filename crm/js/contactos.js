import { supabase } from "./auth.js";

const ESTADOS = [
    { value: "todos", label: "Todos" },
    { value: "activos", label: "Activos" },
    { value: "inactivos", label: "Inactivos" }
];

let contactos = [];
let filtroActual = {
    busqueda: "",
    estado: "todos"
};

export async function renderContactos() {
    const app = document.getElementById("crmContent");

    if (!app) {
        console.error("No se encontró .crmContent");
        return;
    }

    app.innerHTML = `
        <div class="crm-content">

            <div class="crm-page-header">
                <div>
                    <span class="crm-eyebrow">CLIENTES</span>
                    <h1>Contactos</h1>
                    <p>
                        Administra los clientes y contactos de Galería de Viajes.
                    </p>
                </div>

                <button class="crm-btn crm-btn-primary" id="btnNuevoContacto">
                    <span>+</span>
                    Nuevo contacto
                </button>
            </div>

            <section class="crm-panel">

                <div class="crm-toolbar">

                    <div class="crm-search">
                        <span>⌕</span>
                        <input
                            type="search"
                            id="buscarContactos"
                            placeholder="Buscar por nombre, correo o teléfono..."
                        >
                    </div>

                    <select id="filtroEstado" class="crm-select">
                        ${ESTADOS.map(estado => `
                            <option value="${estado.value}">
                                ${estado.label}
                            </option>
                        `).join("")}
                    </select>

                </div>

                <div id="contactosContainer">
                    <div class="crm-loading">
                        Cargando contactos...
                    </div>
                </div>

            </section>

        </div>

        <div id="contactoModalContainer"></div>
    `;

    configurarContactos();

    await cargarContactos();
}

function configurarContactos() {

    const buscador = document.getElementById("buscarContactos");
    const filtroEstado = document.getElementById("filtroEstado");
    const btnNuevo = document.getElementById("btnNuevoContacto");

    buscador?.addEventListener("input", event => {
        filtroActual.busqueda = event.target.value.toLowerCase().trim();
        renderTablaContactos();
    });

    filtroEstado?.addEventListener("change", event => {
        filtroActual.estado = event.target.value;
        renderTablaContactos();
    });

    btnNuevo?.addEventListener("click", () => {
        abrirModalContacto();
    });
}

async function cargarContactos() {

    const { data, error } = await supabase
        .from("contactos")
        .select(`
            id,
            nombre,
            apellido,
            email,
            telefono,
            whatsapp,
            pais,
            ciudad,
            idioma,
            acepta_comunicaciones,
            activo,
            created_at,
            updated_at
        `)
        .order("created_at", { ascending: false });

    if (error) {
        console.error("Error obteniendo contactos:", error);

        mostrarError(
            "No fue posible cargar los contactos."
        );

        return;
    }

    contactos = data || [];

    renderTablaContactos();
}

function obtenerContactosFiltrados() {

    return contactos.filter(contacto => {

        const texto = [
            contacto.nombre,
            contacto.apellido,
            contacto.email,
            contacto.telefono,
            contacto.whatsapp,
            contacto.pais,
            contacto.ciudad
        ]
            .filter(Boolean)
            .join(" ")
            .toLowerCase();

        const coincideBusqueda =
            !filtroActual.busqueda ||
            texto.includes(filtroActual.busqueda);

        const coincideEstado =
            filtroActual.estado === "todos" ||
            (filtroActual.estado === "activos" && contacto.activo) ||
            (filtroActual.estado === "inactivos" && !contacto.activo);

        return coincideBusqueda && coincideEstado;
    });
}

function renderTablaContactos() {

    const container = document.getElementById("contactosContainer");

    if (!container) {
        return;
    }

    const filtrados = obtenerContactosFiltrados();

    if (!filtrados.length) {

        container.innerHTML = `
            <div class="crm-empty-state crm-empty-state-small">
                <div class="crm-empty-icon">○</div>

                <h3>No hay contactos</h3>

                <p>
                    No encontramos contactos con los filtros seleccionados.
                </p>
            </div>
        `;

        return;
    }

    container.innerHTML = `
        <div class="crm-table-wrapper">

            <table class="crm-table crm-contacts-table">

                <thead>
                    <tr>
                        <th>Contacto</th>
                        <th>Correo</th>
                        <th>Teléfono</th>
                        <th>Ubicación</th>
                        <th>Idioma</th>
                        <th>Estado</th>
                        <th></th>
                    </tr>
                </thead>

                <tbody>

                    ${filtrados.map(contacto => `
                        <tr data-contacto-id="${contacto.id}">

                            <td>
                                <div class="crm-contact-cell">

                                    <div class="crm-avatar crm-avatar-small">
                                        ${obtenerIniciales(contacto)}
                                    </div>

                                    <div>
                                        <strong>
                                            ${escapeHtml(
                                                obtenerNombre(contacto)
                                            )}
                                        </strong>

                                        ${
                                            contacto.whatsapp
                                                ? `<small>WhatsApp: ${escapeHtml(contacto.whatsapp)}</small>`
                                                : ""
                                        }
                                    </div>

                                </div>
                            </td>

                            <td>
                                ${
                                    contacto.email
                                        ? escapeHtml(contacto.email)
                                        : "—"
                                }
                            </td>

                            <td>
                                ${
                                    contacto.telefono
                                        ? escapeHtml(contacto.telefono)
                                        : "—"
                                }
                            </td>

                            <td>
                                ${
                                    [contacto.ciudad, contacto.pais]
                                        .filter(Boolean)
                                        .map(escapeHtml)
                                        .join(", ") || "—"
                                }
                            </td>

                            <td>
                                ${
                                    contacto.idioma
                                        ? escapeHtml(contacto.idioma)
                                        : "—"
                                }
                            </td>

                            <td>
                                <span class="crm-status ${
                                    contacto.activo
                                        ? "crm-status-success"
                                        : "crm-status-muted"
                                }">
                                    ${
                                        contacto.activo
                                            ? "Activo"
                                            : "Inactivo"
                                    }
                                </span>
                            </td>

                            <td>
                                <button
                                    class="crm-table-action"
                                    data-action="editar"
                                    data-id="${contacto.id}"
                                >
                                    Ver
                                </button>
                            </td>

                        </tr>
                    `).join("")}

                </tbody>

            </table>

        </div>

        <div class="crm-table-footer">
            ${filtrados.length}
            contacto${filtrados.length === 1 ? "" : "s"}
        </div>
    `;

    container
        .querySelectorAll('[data-action="editar"]')
        .forEach(button => {

            button.addEventListener("click", () => {

                const contacto = contactos.find(
                    item => item.id === button.dataset.id
                );

                if (contacto) {
                    abrirModalContacto(contacto);
                }
            });
        });
}

function abrirModalContacto(contacto = null) {

    const container = document.getElementById(
        "contactoModalContainer"
    );

    if (!container) {
        return;
    }

    const editar = Boolean(contacto);

    container.innerHTML = `
        <div class="crm-modal-backdrop" id="contactoModal">

            <div class="crm-modal">

                <div class="crm-modal-header">

                    <div>
                        <span class="crm-eyebrow">
                            ${editar ? "CONTACTO" : "NUEVO CONTACTO"}
                        </span>

                        <h2>
                            ${editar ? "Editar contacto" : "Crear contacto"}
                        </h2>
                    </div>

                    <button
                        class="crm-modal-close"
                        id="cerrarContactoModal"
                    >
                        ×
                    </button>

                </div>

                <form id="contactoForm">

                    <div class="crm-form-grid">

                        <div class="crm-form-group">
                            <label>Nombre *</label>
                            <input
                                type="text"
                                name="nombre"
                                required
                                value="${editar ? escapeAttribute(contacto.nombre) : ""}"
                            >
                        </div>

                        <div class="crm-form-group">
                            <label>Apellido</label>
                            <input
                                type="text"
                                name="apellido"
                                value="${editar ? escapeAttribute(contacto.apellido) : ""}"
                            >
                        </div>

                        <div class="crm-form-group">
                            <label>Correo</label>
                            <input
                                type="email"
                                name="email"
                                value="${editar ? escapeAttribute(contacto.email) : ""}"
                            >
                        </div>

                        <div class="crm-form-group">
                            <label>Teléfono</label>
                            <input
                                type="text"
                                name="telefono"
                                value="${editar ? escapeAttribute(contacto.telefono) : ""}"
                            >
                        </div>

                        <div class="crm-form-group">
                            <label>WhatsApp</label>
                            <input
                                type="text"
                                name="whatsapp"
                                value="${editar ? escapeAttribute(contacto.whatsapp) : ""}"
                            >
                        </div>

                        <div class="crm-form-group">
                            <label>País</label>
                            <input
                                type="text"
                                name="pais"
                                value="${editar ? escapeAttribute(contacto.pais) : ""}"
                            >
                        </div>

                        <div class="crm-form-group">
                            <label>Ciudad</label>
                            <input
                                type="text"
                                name="ciudad"
                                value="${editar ? escapeAttribute(contacto.ciudad) : ""}"
                            >
                        </div>

                        <div class="crm-form-group">
                            <label>Idioma</label>
                            <input
                                type="text"
                                name="idioma"
                                value="${editar ? escapeAttribute(contacto.idioma) : ""}"
                            >
                        </div>

                    </div>

                    <label class="crm-checkbox">
                        <input
                            type="checkbox"
                            name="acepta_comunicaciones"
                            ${
                                editar && contacto.acepta_comunicaciones
                                    ? "checked"
                                    : ""
                            }
                        >
                        <span>
                            Acepta comunicaciones comerciales
                        </span>
                    </label>

                    ${
                        editar
                            ? `
                                <label class="crm-checkbox">
                                    <input
                                        type="checkbox"
                                        name="activo"
                                        ${
                                            contacto.activo
                                                ? "checked"
                                                : ""
                                        }
                                    >
                                    <span>
                                        Contacto activo
                                    </span>
                                </label>
                            `
                            : ""
                    }

                    <div
                        id="contactoFormMessage"
                        class="crm-form-message"
                    ></div>

                    <div class="crm-modal-footer">

                        <button
                            type="button"
                            class="crm-btn crm-btn-secondary"
                            id="cancelarContacto"
                        >
                            Cancelar
                        </button>

                        <button
                            type="submit"
                            class="crm-btn crm-btn-primary"
                            id="guardarContacto"
                        >
                            ${editar ? "Guardar cambios" : "Crear contacto"}
                        </button>

                    </div>

                </form>

            </div>

        </div>
    `;

    document
        .getElementById("cerrarContactoModal")
        ?.addEventListener("click", cerrarModalContacto);

    document
        .getElementById("cancelarContacto")
        ?.addEventListener("click", cerrarModalContacto);

    document
        .getElementById("contactoForm")
        ?.addEventListener("submit", event => {

            event.preventDefault();

            guardarContacto(
                event.target,
                contacto?.id || null
            );
        });
}

async function guardarContacto(form, contactoId) {

    const boton = document.getElementById("guardarContacto");
    const mensaje = document.getElementById("contactoFormMessage");

    const datos = new FormData(form);

    const payload = {
        nombre: datos.get("nombre")?.trim(),
        apellido: datos.get("apellido")?.trim() || null,
        email: datos.get("email")?.trim() || null,
        telefono: datos.get("telefono")?.trim() || null,
        whatsapp: datos.get("whatsapp")?.trim() || null,
        pais: datos.get("pais")?.trim() || null,
        ciudad: datos.get("ciudad")?.trim() || null,
        idioma: datos.get("idioma")?.trim() || null,
        acepta_comunicaciones:
            datos.get("acepta_comunicaciones") === "on"
    };

    if (contactoId) {
        payload.activo =
            datos.get("activo") === "on";
    }

    boton.disabled = true;
    boton.textContent = "Guardando...";

    const query = contactoId
        ? supabase
            .from("contactos")
            .update(payload)
            .eq("id", contactoId)
        : supabase
            .from("contactos")
            .insert(payload);

    const { error } = await query;

    if (error) {

        console.error("Error guardando contacto:", error);

        mensaje.textContent =
            "No fue posible guardar el contacto.";

        mensaje.className =
            "crm-form-message crm-form-message-error";

        boton.disabled = false;
        boton.textContent =
            contactoId
                ? "Guardar cambios"
                : "Crear contacto";

        return;
    }

    cerrarModalContacto();

    await cargarContactos();
}

function cerrarModalContacto() {

    const container = document.getElementById(
        "contactoModalContainer"
    );

    if (container) {
        container.innerHTML = "";
    }
}

function obtenerNombre(contacto) {

    return [
        contacto.nombre,
        contacto.apellido
    ]
        .filter(Boolean)
        .join(" ");
}

function obtenerIniciales(contacto) {

    const nombre = contacto.nombre?.trim() || "";
    const apellido = contacto.apellido?.trim() || "";

    return (
        `${nombre.charAt(0)}${apellido.charAt(0) || nombre.charAt(1)}`
    ).toUpperCase();
}

function mostrarError(mensaje) {

    const container =
        document.getElementById("contactosContainer");

    if (!container) {
        return;
    }

    container.innerHTML = `
        <div class="crm-empty-state crm-empty-state-small">
            <h3>No fue posible cargar los contactos</h3>
            <p>${escapeHtml(mensaje)}</p>
        </div>
    `;
}

function escapeHtml(value) {

    if (value === null || value === undefined) {
        return "";
    }

    return String(value)
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;")
        .replaceAll("'", "&#039;");
}

function escapeAttribute(value) {
    return escapeHtml(value);
}