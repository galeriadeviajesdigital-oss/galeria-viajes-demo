import { supabase } from "./auth.js";

let leads = [];
let contactos = [];
let destinos = [];
let experiencias = [];
let viajes = [];
let campanas = [];

let filtros = {
    busqueda: "",
    estado: "todos",
    prioridad: "todos",
    origen: "todos"
};


// ============================================================
// RENDER PRINCIPAL
// ============================================================

export async function renderLeads() {

    const app = document.getElementById("crmContent");

    if (!app) {
        console.error("No se encontró #crmContent");
        return;
    }

    app.innerHTML = `
        <div class="crm-content">

            <div class="crm-page-header">

                <div>
                    <span class="crm-page-eyebrow">
                        CLIENTES
                    </span>

                    <h2>Leads</h2>

                    <p>
                        Administra y da seguimiento a los prospectos
                        comerciales de Galería de Viajes.
                    </p>
                </div>

                <button
                    class="crm-btn crm-btn-primary"
                    id="btnNuevoLead"
                >
                    <span>+</span>
                    Nuevo lead
                </button>

            </div>


            <section class="crm-panel">

                <div class="crm-toolbar">

                    <div class="crm-search">

                        <span>⌕</span>

                        <input
                            type="search"
                            id="buscarLeads"
                            placeholder="Buscar por contacto, correo o teléfono..."
                        >

                    </div>


                    <select
                        id="filtroEstado"
                        class="crm-select"
                    >
                        <option value="todos">
                            Todos los estados
                        </option>

                        <option value="NUEVO">
                            Nuevo
                        </option>

                        <option value="CONTACTADO">
                            Contactado
                        </option>

                        <option value="CALIFICADO">
                            Calificado
                        </option>

                        <option value="NO_CALIFICADO">
                            No calificado
                        </option>
                    </select>


                    <select
                        id="filtroPrioridad"
                        class="crm-select"
                    >
                        <option value="todos">
                            Todas las prioridades
                        </option>

                        <option value="URGENTE">
                            Urgente
                        </option>

                        <option value="ALTA">
                            Alta
                        </option>

                        <option value="NORMAL">
                            Normal
                        </option>

                        <option value="BAJA">
                            Baja
                        </option>
                    </select>


                    <select
                        id="filtroOrigen"
                        class="crm-select"
                    >
                        <option value="todos">
                            Todos los orígenes
                        </option>

                        <option value="WEB">
                            Web
                        </option>

                        <option value="WHATSAPP">
                            WhatsApp
                        </option>

                        <option value="GOOGLE">
                            Google
                        </option>

                        <option value="FACEBOOK">
                            Facebook
                        </option>

                        <option value="INSTAGRAM">
                            Instagram
                        </option>

                        <option value="REFERIDO">
                            Referido
                        </option>

                        <option value="CAMPAÑA">
                            Campaña
                        </option>

                        <option value="EVENTO">
                            Evento
                        </option>

                        <option value="LLAMADA">
                            Llamada
                        </option>

                        <option value="OTRO">
                            Otro
                        </option>

                    </select>

                </div>


                <div id="leadsContainer">

                    <div class="crm-loading">
                        Cargando leads...
                    </div>

                </div>

            </section>

        </div>

        <div id="leadModalContainer"></div>
    `;

    configurarEventos();

    await cargarDatos();
}


// ============================================================
// EVENTOS
// ============================================================

function configurarEventos() {

    document
        .getElementById("buscarLeads")
        ?.addEventListener("input", event => {

            filtros.busqueda =
                event.target.value
                    .toLowerCase()
                    .trim();

            renderTabla();

        });


    document
        .getElementById("filtroEstado")
        ?.addEventListener("change", event => {

            filtros.estado =
                event.target.value;

            renderTabla();

        });


    document
        .getElementById("filtroPrioridad")
        ?.addEventListener("change", event => {

            filtros.prioridad =
                event.target.value;

            renderTabla();

        });


    document
        .getElementById("filtroOrigen")
        ?.addEventListener("change", event => {

            filtros.origen =
                event.target.value;

            renderTabla();

        });


    document
    .getElementById("btnNuevoLead")
    ?.addEventListener(
        "click",
        abrirNuevoLead
    );

}


// ============================================================
// CARGAR DATOS
// ============================================================

async function cargarDatos() {

    const resultadoLeads =
        await supabase
            .from("leads")
            .select(`
                id,
                contacto_id,
                destino_id,
                experiencia_id,
                viaje_id,
                campana_id,
                origen,
                estado,
                prioridad,
                fecha_viaje,
                viajeros,
                duracion_dias,
                presupuesto,
                moneda,
                mensaje,
                vendedor_id,
                created_at,
                updated_at
            `)
            .order(
                "created_at",
                {
                    ascending: false
                }
            );


    if (resultadoLeads.error) {

        console.error(
            "Error obteniendo leads:",
            resultadoLeads.error
        );

        mostrarError(
            "No fue posible cargar los leads."
        );

        return;
    }


    leads =
        resultadoLeads.data || [];


    /*
       Cargamos los catálogos por separado.

       Esto evita depender de relaciones anidadas
       de PostgREST y nos permite controlar cada
       permiso de forma independiente.
    */

    const [
        resultadoContactos,
        resultadoDestinos,
        resultadoExperiencias,
        resultadoViajes,
        resultadoCampanas
    ] = await Promise.all([

        supabase
            .from("contactos")
            .select(`
                id,
                nombre,
                apellido,
                email,
                telefono,
                whatsapp
            `),

        supabase
            .from("destinos")
            .select(`
                id,
                nombre
            `)
            .eq("activo", true)
            .order("nombre"),

        supabase
            .from("experiencias")
            .select(`
                id,
                nombre
            `)
            .eq("activo", true)
            .order("nombre"),

        supabase
            .from("viajes")
            .select(`
                id,
                nombre
            `)
            .eq("activo", true)
            .order("nombre"),

        supabase
            .from("campanas")
            .select(`
                id,
                nombre
            `)
            .eq("activa", true)
            .order("nombre")
    ]);


    if (resultadoContactos.error) {

        console.error(
            "Error obteniendo contactos:",
            resultadoContactos.error
        );

    } else {

        contactos =
            resultadoContactos.data || [];

    }


    if (resultadoDestinos.error) {

        console.error(
            "Error obteniendo destinos:",
            resultadoDestinos.error
        );

    } else {

        destinos =
            resultadoDestinos.data || [];

    }


    if (resultadoExperiencias.error) {

        console.error(
            "Error obteniendo experiencias:",
            resultadoExperiencias.error
        );

    } else {

        experiencias =
            resultadoExperiencias.data || [];

    }


    if (resultadoViajes.error) {

        console.error(
            "Error obteniendo viajes:",
            resultadoViajes.error
        );

    } else {

        viajes =
            resultadoViajes.data || [];

    }


    if (resultadoCampanas.error) {

        console.error(
            "Error obteniendo campañas:",
            resultadoCampanas.error
        );

    } else {

        campanas =
            resultadoCampanas.data || [];

    }


    console.log(
        "Leads CRM:",
        leads.length
    );


    renderTabla();
}


// ============================================================
// FILTRAR
// ============================================================

function obtenerLeadsFiltrados() {

    return leads.filter(lead => {

        const contacto =
            obtenerContacto(lead.contacto_id);


        const texto = [

            contacto?.nombre,
            contacto?.apellido,
            contacto?.email,
            contacto?.telefono,
            contacto?.whatsapp,

            obtenerNombreDestino(
                lead.destino_id
            ),

            obtenerNombreExperiencia(
                lead.experiencia_id
            ),

            obtenerNombreViaje(
                lead.viaje_id
            )

        ]
            .filter(Boolean)
            .join(" ")
            .toLowerCase();


        const coincideBusqueda =
            !filtros.busqueda ||
            texto.includes(
                filtros.busqueda
            );


        const coincideEstado =
            filtros.estado === "todos" ||
            lead.estado === filtros.estado;


        const coincidePrioridad =
            filtros.prioridad === "todos" ||
            lead.prioridad === filtros.prioridad;


        const coincideOrigen =
            filtros.origen === "todos" ||
            lead.origen === filtros.origen;


        return (
            coincideBusqueda &&
            coincideEstado &&
            coincidePrioridad &&
            coincideOrigen
        );

    });

}


// ============================================================
// TABLA
// ============================================================

function renderTabla() {

    const container =
        document.getElementById(
            "leadsContainer"
        );


    if (!container) {
        return;
    }


    const filtrados =
        obtenerLeadsFiltrados();


    if (!filtrados.length) {

        container.innerHTML = `
            <div class="crm-empty-state crm-empty-state-small">

                <div class="crm-empty-icon">
                    ◎
                </div>

                <strong>
                    No hay leads
                </strong>

                <p>
                    No encontramos leads con
                    los filtros seleccionados.
                </p>

            </div>
        `;

        return;
    }


    container.innerHTML = `

        <div class="crm-table-wrapper">

            <table class="crm-table crm-leads-table">

                <thead>

                    <tr>

                        <th>Contacto</th>

                        <th>Destino</th>

                        <th>Origen</th>

                        <th>Estado</th>

                        <th>Prioridad</th>

                        <th>Viaje</th>

                        <th>Presupuesto</th>

                        <th></th>

                    </tr>

                </thead>


                <tbody>

                    ${filtrados
                        .map(renderFilaLead)
                        .join("")}

                </tbody>

            </table>

        </div>


        <div class="crm-table-footer">

            ${filtrados.length}

            lead${filtrados.length === 1 ? "" : "s"}

        </div>

    `;


    container
        .querySelectorAll("[data-lead-id]")
        .forEach(button => {

            button.addEventListener("click", () => {

                const lead = leads.find(
                    item => item.id === button.dataset.leadId
                );

                if (lead) {
                    abrirDetalleLead(lead);
                }

            });

        });

}


// ============================================================
// FILA
// ============================================================

function renderFilaLead(lead) {

    const contacto =
        obtenerContacto(
            lead.contacto_id
        );


    const nombreContacto =
        contacto
            ? [
                contacto.nombre,
                contacto.apellido
            ]
                .filter(Boolean)
                .join(" ")
            : "Contacto sin nombre";


    const destino =
        obtenerNombreDestino(
            lead.destino_id
        );


    const estado =
        obtenerEtiquetaEstado(
            lead.estado
        );


    const prioridad =
        obtenerEtiquetaPrioridad(
            lead.prioridad
        );


    const origen =
        obtenerEtiquetaOrigen(
            lead.origen
        );


    const presupuesto =
        formatearPresupuesto(
            lead.presupuesto,
            lead.moneda
        );


    return `

        <tr>

            <td>

                <div class="crm-contact-cell">

                    <div class="crm-avatar crm-avatar-small">

                        ${obtenerIniciales(
                            contacto
                        )}

                    </div>


                    <div>

                        <strong>
                            ${escapeHtml(
                                nombreContacto
                            )}
                        </strong>


                        ${
                            contacto?.email
                                ? `
                                    <small>
                                        ${escapeHtml(
                                            contacto.email
                                        )}
                                    </small>
                                `
                                : ""
                        }

                    </div>

                </div>

            </td>


            <td>
                ${
                    destino
                        ? escapeHtml(destino)
                        : "—"
                }
            </td>


            <td>
                <span class="crm-lead-origin">
                    ${escapeHtml(origen)}
                </span>
            </td>


            <td>

                <span class="crm-lead-status crm-lead-status-${lead.estado.toLowerCase()}">

                    ${escapeHtml(estado)}

                </span>

            </td>


            <td>

                <span class="crm-lead-priority crm-lead-priority-${lead.prioridad.toLowerCase()}">

                    ${escapeHtml(prioridad)}

                </span>

            </td>


            <td>

                ${
                    lead.fecha_viaje
                        ? formatearFecha(
                            lead.fecha_viaje
                        )
                        : "—"
                }

            </td>


            <td>

                ${
                    presupuesto
                        ? escapeHtml(
                            presupuesto
                        )
                        : "—"
                }

            </td>


            <td>

                <button
                    class="crm-table-action"
                    data-lead-id="${lead.id}"
                >
                    Ver
                </button>

            </td>

        </tr>

    `;

}

// ============================================================
// DETALLE DEL LEAD
// ============================================================

function abrirDetalleLead(lead) {

    const container =
        document.getElementById("leadModalContainer");

    if (!container) {
        return;
    }

    const contacto =
        obtenerContacto(lead.contacto_id);

    const destino =
        obtenerNombreDestino(lead.destino_id);

    const experiencia =
        obtenerNombreExperiencia(
            lead.experiencia_id
        );

    const viaje =
        obtenerNombreViaje(
            lead.viaje_id
        );

    const campana =
        obtenerNombreCampana(
            lead.campana_id
        );

    const estado =
        obtenerEtiquetaEstado(
            lead.estado
        );

    const prioridad =
        obtenerEtiquetaPrioridad(
            lead.prioridad
        );

    const origen =
        obtenerEtiquetaOrigen(
            lead.origen
        );

    const nombreContacto =
        contacto
            ? [
                contacto.nombre,
                contacto.apellido
            ]
                .filter(Boolean)
                .join(" ")
            : "Contacto sin nombre";


    container.innerHTML = `

        <div
            class="crm-modal-backdrop"
            id="leadDetailModal"
        >

            <div class="crm-modal crm-lead-detail-modal">

                <div class="crm-modal-header">

                    <div>

                        <span class="crm-page-eyebrow">
                            LEAD
                        </span>

                        <h2>
                            ${escapeHtml(
                                nombreContacto
                            )}
                        </h2>

                        <div class="crm-lead-detail-tags">

                            <span
                                class="crm-lead-status crm-lead-status-${lead.estado.toLowerCase()}"
                            >
                                ${escapeHtml(estado)}
                            </span>

                            <span
                                class="crm-lead-priority crm-lead-priority-${lead.prioridad.toLowerCase()}"
                            >
                                ${escapeHtml(prioridad)}
                            </span>

                        </div>

                    </div>


                    <button
                        class="crm-modal-close"
                        id="cerrarLeadDetalle"
                    >
                        ×
                    </button>

                </div>


                <div class="crm-lead-detail-body">


                    <!-- CONTACTO -->

                    <section class="crm-detail-section">

                        <div class="crm-detail-section-title">
                            <span>👤</span>
                            Contacto
                        </div>


                        <div class="crm-detail-grid">

                            <div class="crm-detail-item">

                                <span>
                                    Nombre
                                </span>

                                <strong>
                                    ${escapeHtml(
                                        nombreContacto
                                    )}
                                </strong>

                            </div>


                            <div class="crm-detail-item">

                                <span>
                                    Correo
                                </span>

                                <strong>
                                    ${
                                        contacto?.email
                                            ? escapeHtml(
                                                contacto.email
                                            )
                                            : "—"
                                    }
                                </strong>

                            </div>


                            <div class="crm-detail-item">

                                <span>
                                    Teléfono
                                </span>

                                <strong>
                                    ${
                                        contacto?.telefono
                                            ? escapeHtml(
                                                contacto.telefono
                                            )
                                            : "—"
                                    }
                                </strong>

                            </div>


                            <div class="crm-detail-item">

                                <span>
                                    WhatsApp
                                </span>

                                <strong>
                                    ${
                                        contacto?.whatsapp
                                            ? escapeHtml(
                                                contacto.whatsapp
                                            )
                                            : "—"
                                    }
                                </strong>

                            </div>

                        </div>

                    </section>


                    <!-- INTERÉS DE VIAJE -->

                    <section class="crm-detail-section">

                        <div class="crm-detail-section-title">
                            <span>✈</span>
                            Interés de viaje
                        </div>


                        <div class="crm-detail-grid">

                            <div class="crm-detail-item">

                                <span>
                                    Destino
                                </span>

                                <strong>
                                    ${
                                        destino
                                            ? escapeHtml(
                                                destino
                                            )
                                            : "—"
                                    }
                                </strong>

                            </div>


                            <div class="crm-detail-item">

                                <span>
                                    Experiencia
                                </span>

                                <strong>
                                    ${
                                        experiencia
                                            ? escapeHtml(
                                                experiencia
                                            )
                                            : "—"
                                    }
                                </strong>

                            </div>


                            <div class="crm-detail-item crm-detail-item-wide">

                                <span>
                                    Viaje
                                </span>

                                <strong>
                                    ${
                                        viaje
                                            ? escapeHtml(
                                                viaje
                                            )
                                            : "—"
                                    }
                                </strong>

                            </div>

                        </div>

                    </section>


                    <!-- PLANIFICACIÓN -->

                    <section class="crm-detail-section">

                        <div class="crm-detail-section-title">
                            <span>📅</span>
                            Planificación
                        </div>


                        <div class="crm-detail-grid">

                            <div class="crm-detail-item">

                                <span>
                                    Fecha de viaje
                                </span>

                                <strong>
                                    ${
                                        lead.fecha_viaje
                                            ? formatearFecha(
                                                lead.fecha_viaje
                                            )
                                            : "—"
                                    }
                                </strong>

                            </div>


                            <div class="crm-detail-item">

                                <span>
                                    Viajeros
                                </span>

                                <strong>
                                    ${
                                        lead.viajeros ??
                                        "—"
                                    }
                                </strong>

                            </div>


                            <div class="crm-detail-item">

                                <span>
                                    Duración
                                </span>

                                <strong>
                                    ${
                                        lead.duracion_dias
                                            ? `${lead.duracion_dias} días`
                                            : "—"
                                    }
                                </strong>

                            </div>

                        </div>

                    </section>


                    <!-- PRESUPUESTO -->

                    <section class="crm-detail-section">

                        <div class="crm-detail-section-title">
                            <span>💰</span>
                            Presupuesto
                        </div>


                        <div class="crm-detail-grid">

                            <div class="crm-detail-item">

                                <span>
                                    Presupuesto
                                </span>

                                <strong class="crm-detail-value-large">

                                    ${
                                        formatearPresupuesto(
                                            lead.presupuesto,
                                            lead.moneda
                                        ) || "—"
                                    }

                                </strong>

                            </div>


                            <div class="crm-detail-item">

                                <span>
                                    Moneda
                                </span>

                                <strong>
                                    ${
                                        lead.moneda || "—"
                                    }
                                </strong>

                            </div>

                        </div>

                    </section>


                    <!-- INFORMACIÓN COMERCIAL -->

                    <section class="crm-detail-section">

                        <div class="crm-detail-section-title">
                            <span>📌</span>
                            Información comercial
                        </div>


                        <div class="crm-detail-grid">

                            <div class="crm-detail-item">

                                <span>
                                    Origen
                                </span>

                                <strong>
                                    ${escapeHtml(origen)}
                                </strong>

                            </div>


                            <div class="crm-detail-item">

                                <span>
                                    Campaña
                                </span>

                                <strong>
                                    ${
                                        campana
                                            ? escapeHtml(
                                                campana
                                            )
                                            : "—"
                                    }
                                </strong>

                            </div>


                            <div class="crm-detail-item">

                                <span>
                                    Vendedor
                                </span>

                                <strong>
                                    ${
                                        lead.vendedor_id
                                            ? "Asignado"
                                            : "Sin asignar"
                                    }
                                </strong>

                            </div>

                        </div>

                    </section>


                    <!-- MENSAJE -->

                    <section class="crm-detail-section">

                        <div class="crm-detail-section-title">
                            <span>📝</span>
                            Mensaje del cliente
                        </div>


                        <div class="crm-detail-message">

                            ${
                                lead.mensaje
                                    ? escapeHtml(
                                        lead.mensaje
                                    )
                                    : "El cliente no agregó un mensaje."
                            }

                        </div>

                    </section>


                    <!-- METADATA -->

                    <section class="crm-detail-meta">

                        <span>
                            Creado:
                            ${
                                lead.created_at
                                    ? new Date(
                                        lead.created_at
                                    ).toLocaleString(
                                        "es-CR"
                                    )
                                    : "—"
                            }
                        </span>

                        <span>
                            Actualizado:
                            ${
                                lead.updated_at
                                    ? new Date(
                                        lead.updated_at
                                    ).toLocaleString(
                                        "es-CR"
                                    )
                                    : "—"
                            }
                        </span>

                    </section>


                </div>


                <div class="crm-modal-footer">

                    <button
                        type="button"
                        class="crm-btn crm-btn-secondary"
                        id="cerrarLeadDetalleFooter"
                    >
                        Cerrar
                    </button>

                    <button
                        type="button"
                        class="crm-btn crm-btn-primary"
                        id="editarLeadDesdeDetalle"
                    >
                        Editar lead
                    </button>

                </div>

            </div>

        </div>

    `;


    document
        .getElementById("cerrarLeadDetalle")
        ?.addEventListener(
            "click",
            cerrarDetalleLead
        );


    document
        .getElementById("cerrarLeadDetalleFooter")
        ?.addEventListener(
            "click",
            cerrarDetalleLead
        );


   document
    .getElementById("editarLeadDesdeDetalle")
    ?.addEventListener(
        "click",
        () => {

            cerrarDetalleLead();

            abrirEditorLead(lead);

        }
    );

}


function cerrarDetalleLead() {

    const container =
        document.getElementById(
            "leadModalContainer"
        );

    if (container) {
        container.innerHTML = "";
    }

}


// ============================================================
// EDITAR LEAD
// ============================================================

function abrirEditorLead(lead) {

    const container =
        document.getElementById(
            "leadModalContainer"
        );

    if (!container) {
        return;
    }


    const contacto =
        obtenerContacto(
            lead.contacto_id
        );


    const nombreContacto =
        contacto
            ? [
                contacto.nombre,
                contacto.apellido
            ]
                .filter(Boolean)
                .join(" ")
            : "Contacto";


    container.innerHTML = `

        <div
            class="crm-modal-backdrop"
            id="leadEditModal"
        >

            <div
                class="crm-modal crm-lead-edit-modal"
            >


                <!-- HEADER -->

                <div class="crm-modal-header">

                    <div>

                        <span class="crm-page-eyebrow">
                            LEAD
                        </span>

                        <h2>
                            Editar lead
                        </h2>

                        <p class="crm-modal-subtitle">
                            ${escapeHtml(
                                nombreContacto
                            )}
                        </p>

                    </div>


                    <button
                        type="button"
                        class="crm-modal-close"
                        id="cerrarLeadEditor"
                    >
                        ×
                    </button>

                </div>


                <!-- FORMULARIO -->

                <form
                    id="leadEditForm"
                    class="crm-lead-edit-form"
                >


                    <!-- ESTADO COMERCIAL -->

                    <section class="crm-form-section">

                        <div class="crm-detail-section-title">
                            <span>📌</span>
                            Estado comercial
                        </div>


                        <div class="crm-form-grid">


                            <div class="crm-form-field">

                                <label for="editLeadEstado">
                                    Estado
                                </label>

                                <select
                                    id="editLeadEstado"
                                    name="estado"
                                    required
                                >

                                    <option
                                        value="NUEVO"
                                        ${lead.estado === "NUEVO" ? "selected" : ""}
                                    >
                                        Nuevo
                                    </option>

                                    <option
                                        value="CONTACTADO"
                                        ${lead.estado === "CONTACTADO" ? "selected" : ""}
                                    >
                                        Contactado
                                    </option>

                                    <option
                                        value="CALIFICADO"
                                        ${lead.estado === "CALIFICADO" ? "selected" : ""}
                                    >
                                        Calificado
                                    </option>

                                    <option
                                        value="NO_CALIFICADO"
                                        ${lead.estado === "NO_CALIFICADO" ? "selected" : ""}
                                    >
                                        No calificado
                                    </option>

                                </select>

                            </div>


                            <div class="crm-form-field">

                                <label for="editLeadPrioridad">
                                    Prioridad
                                </label>

                                <select
                                    id="editLeadPrioridad"
                                    name="prioridad"
                                    required
                                >

                                    <option
                                        value="BAJA"
                                        ${lead.prioridad === "BAJA" ? "selected" : ""}
                                    >
                                        Baja
                                    </option>

                                    <option
                                        value="NORMAL"
                                        ${lead.prioridad === "NORMAL" ? "selected" : ""}
                                    >
                                        Normal
                                    </option>

                                    <option
                                        value="ALTA"
                                        ${lead.prioridad === "ALTA" ? "selected" : ""}
                                    >
                                        Alta
                                    </option>

                                    <option
                                        value="URGENTE"
                                        ${lead.prioridad === "URGENTE" ? "selected" : ""}
                                    >
                                        Urgente
                                    </option>

                                </select>

                            </div>


                            <div class="crm-form-field">

                                <label for="editLeadOrigen">
                                    Origen
                                </label>

                                <select
                                    id="editLeadOrigen"
                                    name="origen"
                                    required
                                >

                                    <option value="WEB" ${lead.origen === "WEB" ? "selected" : ""}>
                                        Web
                                    </option>

                                    <option value="WHATSAPP" ${lead.origen === "WHATSAPP" ? "selected" : ""}>
                                        WhatsApp
                                    </option>

                                    <option value="GOOGLE" ${lead.origen === "GOOGLE" ? "selected" : ""}>
                                        Google
                                    </option>

                                    <option value="FACEBOOK" ${lead.origen === "FACEBOOK" ? "selected" : ""}>
                                        Facebook
                                    </option>

                                    <option value="INSTAGRAM" ${lead.origen === "INSTAGRAM" ? "selected" : ""}>
                                        Instagram
                                    </option>

                                    <option value="REFERIDO" ${lead.origen === "REFERIDO" ? "selected" : ""}>
                                        Referido
                                    </option>

                                    <option value="CAMPAÑA" ${lead.origen === "CAMPAÑA" ? "selected" : ""}>
                                        Campaña
                                    </option>

                                    <option value="EVENTO" ${lead.origen === "EVENTO" ? "selected" : ""}>
                                        Evento
                                    </option>

                                    <option value="LLAMADA" ${lead.origen === "LLAMADA" ? "selected" : ""}>
                                        Llamada
                                    </option>

                                    <option value="OTRO" ${lead.origen === "OTRO" ? "selected" : ""}>
                                        Otro
                                    </option>

                                </select>

                            </div>


                            <div class="crm-form-field">

                                <label for="editLeadFecha">
                                    Fecha de viaje
                                </label>

                                <input
                                    type="date"
                                    id="editLeadFecha"
                                    name="fecha_viaje"
                                    value="${lead.fecha_viaje || ""}"
                                >

                            </div>

                        </div>

                    </section>


                    <!-- PLANIFICACIÓN -->

                    <section class="crm-form-section">

                        <div class="crm-detail-section-title">
                            <span>📅</span>
                            Planificación
                        </div>


                        <div class="crm-form-grid">


                            <div class="crm-form-field">

                                <label for="editLeadViajeros">
                                    Viajeros
                                </label>

                                <input
                                    type="number"
                                    id="editLeadViajeros"
                                    name="viajeros"
                                    min="1"
                                    value="${lead.viajeros ?? ""}"
                                >

                            </div>


                            <div class="crm-form-field">

                                <label for="editLeadDuracion">
                                    Duración en días
                                </label>

                                <input
                                    type="number"
                                    id="editLeadDuracion"
                                    name="duracion_dias"
                                    min="1"
                                    value="${lead.duracion_dias ?? ""}"
                                >

                            </div>


                            <div class="crm-form-field">

                                <label for="editLeadPresupuesto">
                                    Presupuesto
                                </label>

                                <input
                                    type="number"
                                    id="editLeadPresupuesto"
                                    name="presupuesto"
                                    min="0"
                                    step="0.01"
                                    value="${lead.presupuesto ?? ""}"
                                >

                            </div>


                            <div class="crm-form-field">

                                <label for="editLeadMoneda">
                                    Moneda
                                </label>

                                <select
                                    id="editLeadMoneda"
                                    name="moneda"
                                >

                                    <option
                                        value="USD"
                                        ${lead.moneda === "USD" ? "selected" : ""}
                                    >
                                        USD
                                    </option>

                                    <option
                                        value="CRC"
                                        ${lead.moneda === "CRC" ? "selected" : ""}
                                    >
                                        CRC
                                    </option>

                                    <option
                                        value="EUR"
                                        ${lead.moneda === "EUR" ? "selected" : ""}
                                    >
                                        EUR
                                    </option>

                                </select>

                            </div>

                        </div>

                    </section>


                    <!-- MENSAJE -->

                    <section class="crm-form-section">

                        <div class="crm-detail-section-title">
                            <span>📝</span>
                            Mensaje del cliente
                        </div>


                        <div class="crm-form-field">

                            <textarea
                                id="editLeadMensaje"
                                name="mensaje"
                                rows="5"
                                placeholder="Mensaje o información adicional..."
                            >${escapeHtml(
                                lead.mensaje || ""
                            )}</textarea>

                        </div>

                    </section>


                    <!-- ERROR -->

                    <div
                        id="leadEditError"
                        class="crm-form-message crm-form-message-error"
                        hidden
                    ></div>


                    <!-- FOOTER -->

                    <div class="crm-modal-footer">

                        <button
                            type="button"
                            class="crm-btn crm-btn-secondary"
                            id="cancelarLeadEditor"
                        >
                            Cancelar
                        </button>

                        <button
                            type="submit"
                            class="crm-btn crm-btn-primary"
                            id="guardarLead"
                        >
                            Guardar cambios
                        </button>

                    </div>


                </form>

            </div>

        </div>

    `;


    configurarEditorLead(lead);

}


// ============================================================
// EVENTOS DEL EDITOR
// ============================================================

function configurarEditorLead(lead) {

    document
        .getElementById("cerrarLeadEditor")
        ?.addEventListener(
            "click",
            cerrarEditorLead
        );


    document
        .getElementById("cancelarLeadEditor")
        ?.addEventListener(
            "click",
            cerrarEditorLead
        );


    document
        .getElementById("leadEditForm")
        ?.addEventListener(
            "submit",
            async event => {

                event.preventDefault();

                await guardarCambiosLead(
                    lead
                );

            }
        );

}


// ============================================================
// GUARDAR CAMBIOS
// ============================================================

async function guardarCambiosLead(
    lead
) {

    const button =
        document.getElementById(
            "guardarLead"
        );

    const errorElement =
        document.getElementById(
            "leadEditError"
        );


    if (!button) {
        return;
    }


    if (errorElement) {

        errorElement.hidden = true;

        errorElement.textContent = "";

    }


    button.disabled = true;

    button.textContent =
        "Guardando...";


    const datos = {

        estado:
            document.getElementById(
                "editLeadEstado"
            )?.value,

        prioridad:
            document.getElementById(
                "editLeadPrioridad"
            )?.value,

        origen:
            document.getElementById(
                "editLeadOrigen"
            )?.value,

        fecha_viaje:
            document.getElementById(
                "editLeadFecha"
            )?.value || null,

        viajeros:
            convertirNumeroONull(
                document.getElementById(
                    "editLeadViajeros"
                )?.value
            ),

        duracion_dias:
            convertirNumeroONull(
                document.getElementById(
                    "editLeadDuracion"
                )?.value
            ),

        presupuesto:
            convertirDecimalONull(
                document.getElementById(
                    "editLeadPresupuesto"
                )?.value
            ),

        moneda:
            document.getElementById(
                "editLeadMoneda"
            )?.value || "USD",

        mensaje:
            document.getElementById(
                "editLeadMensaje"
            )?.value.trim() || null

    };


    const {
        data,
        error
    } = await supabase

        .from("leads")

        .update(datos)

        .eq("id", lead.id)

        .select()
        
        .single();


    if (error) {

        console.error(
            "Error actualizando lead:",
            error
        );


        if (errorElement) {

            errorElement.hidden = false;

            errorElement.textContent =
                "No fue posible guardar los cambios. " +
                (error.message || "");

        }


        button.disabled = false;

        button.textContent =
            "Guardar cambios";

        return;
    }


    /*
       Actualizamos el registro local para que
       la tabla y el detalle reflejen inmediatamente
       los cambios.
    */

    const indice =
        leads.findIndex(
            item =>
                item.id === lead.id
        );


    if (indice !== -1) {

        leads[indice] = {
            ...leads[indice],
            ...data
        };

    }


    cerrarEditorLead();

    renderTabla();


    /*
       Mostramos nuevamente el detalle
       actualizado.
    */

    const leadActualizado =
        leads.find(
            item =>
                item.id === lead.id
        );


    if (leadActualizado) {

        abrirDetalleLead(
            leadActualizado
        );

    }

}


// ============================================================
// CERRAR EDITOR
// ============================================================

function cerrarEditorLead() {

    const container =
        document.getElementById(
            "leadModalContainer"
        );

    if (container) {

        container.innerHTML = "";

    }

}


// ============================================================
// CONVERSIONES
// ============================================================

function convertirNumeroONull(
    valor
) {

    if (
        valor === null ||
        valor === undefined ||
        valor === ""
    ) {

        return null;

    }


    const numero =
        Number.parseInt(
            valor,
            10
        );


    return Number.isNaN(numero)
        ? null
        : numero;

}


function convertirDecimalONull(
    valor
) {

    if (
        valor === null ||
        valor === undefined ||
        valor === ""
    ) {

        return null;

    }


    const numero =
        Number.parseFloat(
            valor
        );


    return Number.isNaN(numero)
        ? null
        : numero;

}



// ============================================================
// CATÁLOGOS
// ============================================================

function obtenerContacto(id) {

    return contactos.find(
        contacto =>
            contacto.id === id
    );

}


function obtenerNombreDestino(id) {

    return destinos.find(
        destino =>
            destino.id === id
    )?.nombre || "";

}


function obtenerNombreExperiencia(id) {

    return experiencias.find(
        experiencia =>
            experiencia.id === id
    )?.nombre || "";

}


function obtenerNombreViaje(id) {

    return viajes.find(
        viaje =>
            viaje.id === id
    )?.nombre || "";

}


function obtenerNombreCampana(id) {

    return campanas.find(
        campana =>
            campana.id === id
    )?.nombre || "";

}


// ============================================================
// ETIQUETAS
// ============================================================

function obtenerEtiquetaEstado(estado) {

    const etiquetas = {

        NUEVO: "Nuevo",

        CONTACTADO: "Contactado",

        CALIFICADO: "Calificado",

        NO_CALIFICADO: "No calificado"

    };


    return etiquetas[estado] || estado;

}


function obtenerEtiquetaPrioridad(prioridad) {

    const etiquetas = {

        BAJA: "Baja",

        NORMAL: "Normal",

        ALTA: "Alta",

        URGENTE: "Urgente"

    };


    return etiquetas[prioridad] || prioridad;

}


function obtenerEtiquetaOrigen(origen) {

    const etiquetas = {

        WEB: "Web",

        WHATSAPP: "WhatsApp",

        GOOGLE: "Google",

        FACEBOOK: "Facebook",

        INSTAGRAM: "Instagram",

        REFERIDO: "Referido",

        CAMPAÑA: "Campaña",

        EVENTO: "Evento",

        LLAMADA: "Llamada",

        OTRO: "Otro"

    };


    return etiquetas[origen] || origen;

}


// ============================================================
// FORMATO
// ============================================================

function formatearFecha(fecha) {

    if (!fecha) {
        return "";
    }


    const partes =
        fecha.split("-");


    if (partes.length !== 3) {
        return fecha;
    }


    return `${partes[2]}/${partes[1]}/${partes[0]}`;

}


function formatearPresupuesto(
    presupuesto,
    moneda
) {

    if (
        presupuesto === null ||
        presupuesto === undefined
    ) {
        return "";
    }


    const valor =
        Number(presupuesto);


    if (Number.isNaN(valor)) {
        return "";
    }


    return new Intl.NumberFormat(
        "es-CR",
        {
            style: "currency",
            currency: moneda || "USD",
            maximumFractionDigits: 2
        }
    ).format(valor);

}


// ============================================================
// INICIALES
// ============================================================

function obtenerIniciales(contacto) {

    if (!contacto) {
        return "LE";
    }


    const nombre =
        contacto.nombre?.trim() || "";

    const apellido =
        contacto.apellido?.trim() || "";


    if (!nombre && !apellido) {
        return "LE";
    }


    return (
        nombre.charAt(0) +
        (
            apellido.charAt(0) ||
            nombre.charAt(1)
        )
    ).toUpperCase();

}


// ============================================================
// ERROR
// ============================================================

function mostrarError(mensaje) {

    const container =
        document.getElementById(
            "leadsContainer"
        );


    if (!container) {
        return;
    }


    container.innerHTML = `

        <div class="crm-empty-state crm-empty-state-small">

            <strong>
                No fue posible cargar los leads
            </strong>

            <p>
                ${escapeHtml(mensaje)}
            </p>

        </div>

    `;

}


// ============================================================
// SEGURIDAD HTML
// ============================================================

function escapeHtml(value) {

    if (
        value === null ||
        value === undefined
    ) {
        return "";
    }


    return String(value)

        .replaceAll(
            "&",
            "&amp;"
        )

        .replaceAll(
            "<",
            "&lt;"
        )

        .replaceAll(
            ">",
            "&gt;"
        )

        .replaceAll(
            '"',
            "&quot;"
        )

        .replaceAll(
            "'",
            "&#039;"
        );

}

// ============================================================
// NUEVO LEAD
// ============================================================

function abrirNuevoLead() {

    const container =
        document.getElementById(
            "leadModalContainer"
        );

    if (!container) {
        return;
    }

    container.innerHTML = `

        <div
            class="crm-modal-backdrop"
            id="nuevoLeadModal"
        >

            <div
                class="crm-modal crm-lead-edit-modal"
            >

                <div class="crm-modal-header">

                    <div>

                        <span class="crm-page-eyebrow">
                            NUEVO LEAD
                        </span>

                        <h2>
                            Crear lead
                        </h2>

                        <p class="crm-modal-subtitle">
                            Registra un nuevo prospecto comercial.
                        </p>

                    </div>

                    <button
                        type="button"
                        class="crm-modal-close"
                        id="cerrarNuevoLead"
                    >
                        ×
                    </button>

                </div>


                <div class="crm-lead-detail-body">

                    <form id="formNuevoLead">


                        <!-- ================================================= -->
                        <!-- CONTACTO -->
                        <!-- ================================================= -->

                        <section class="crm-form-section">

                            <div class="crm-detail-section-title">
                                <span>👤</span>
                                Contacto
                            </div>


                            <div class="crm-form-field">

                                <label>
                                    Contacto existente
                                </label>

                                <select
                                    id="nuevoLeadContacto"
                                    class="crm-select"
                                >

                                    <option value="">
                                        Seleccionar contacto...
                                    </option>

                                    ${contactos
                                        .map(contacto => {

                                            const nombre = [
                                                contacto.nombre,
                                                contacto.apellido
                                            ]
                                                .filter(Boolean)
                                                .join(" ");

                                            const datos = [
                                                nombre || "Sin nombre",
                                                contacto.email,
                                                contacto.telefono
                                            ]
                                                .filter(Boolean)
                                                .join(" · ");

                                            return `
                                                <option
                                                    value="${escapeHtml(contacto.id)}"
                                                >
                                                    ${escapeHtml(datos)}
                                                </option>
                                            `;

                                        })
                                        .join("")}

                                </select>

                                <small>
                                    Selecciona un contacto existente para evitar duplicados.
                                </small>

                            </div>


                            <div class="crm-form-grid">

                                <div class="crm-form-field">

                                    <label for="nuevoLeadNombre">
                                        Nombre
                                    </label>

                                    <input
                                        type="text"
                                        id="nuevoLeadNombre"
                                        class="crm-input"
                                        placeholder="Nombre"
                                    >

                                </div>


                                <div class="crm-form-field">

                                    <label for="nuevoLeadApellido">
                                        Apellido
                                    </label>

                                    <input
                                        type="text"
                                        id="nuevoLeadApellido"
                                        class="crm-input"
                                        placeholder="Apellido"
                                    >

                                </div>


                                <div class="crm-form-field">

                                    <label for="nuevoLeadEmail">
                                        Correo
                                    </label>

                                    <input
                                        type="email"
                                        id="nuevoLeadEmail"
                                        class="crm-input"
                                        placeholder="correo@ejemplo.com"
                                    >

                                </div>


                                <div class="crm-form-field">

                                    <label for="nuevoLeadTelefono">
                                        Teléfono
                                    </label>

                                    <input
                                        type="text"
                                        id="nuevoLeadTelefono"
                                        class="crm-input"
                                        placeholder="+506..."
                                    >

                                </div>


                                <div class="crm-form-field">

                                    <label for="nuevoLeadWhatsapp">
                                        WhatsApp
                                    </label>

                                    <input
                                        type="text"
                                        id="nuevoLeadWhatsapp"
                                        class="crm-input"
                                        placeholder="+506..."
                                    >

                                </div>

                            </div>

                        </section>



                        <!-- ================================================= -->
                        <!-- INTERÉS -->
                        <!-- ================================================= -->

                        <section class="crm-form-section">

                            <div class="crm-detail-section-title">
                                <span>✈</span>
                                Interés de viaje
                            </div>


                            <div class="crm-form-grid">

                                <div class="crm-form-field">

                                    <label for="nuevoLeadDestino">
                                        Destino
                                    </label>

                                    <select
                                        id="nuevoLeadDestino"
                                        class="crm-select"
                                    >

                                        <option value="">
                                            Seleccionar destino...
                                        </option>

                                        ${destinos
                                            .map(destino => `
                                                <option value="${escapeHtml(destino.id)}">
                                                    ${escapeHtml(destino.nombre)}
                                                </option>
                                            `)
                                            .join("")}

                                    </select>

                                </div>


                                <div class="crm-form-field">

                                    <label for="nuevoLeadExperiencia">
                                        Experiencia
                                    </label>

                                    <select
                                        id="nuevoLeadExperiencia"
                                        class="crm-select"
                                    >

                                        <option value="">
                                            Seleccionar experiencia...
                                        </option>

                                        ${experiencias
                                            .map(experiencia => `
                                                <option value="${escapeHtml(experiencia.id)}">
                                                    ${escapeHtml(experiencia.nombre)}
                                                </option>
                                            `)
                                            .join("")}

                                    </select>

                                </div>


                                <div class="crm-form-field">

                                    <label for="nuevoLeadViaje">
                                        Viaje
                                    </label>

                                    <select
                                        id="nuevoLeadViaje"
                                        class="crm-select"
                                    >

                                        <option value="">
                                            Seleccionar viaje...
                                        </option>

                                        ${viajes
                                            .map(viaje => `
                                                <option value="${escapeHtml(viaje.id)}">
                                                    ${escapeHtml(viaje.nombre)}
                                                </option>
                                            `)
                                            .join("")}

                                    </select>

                                </div>


                                <div class="crm-form-field">

                                    <label for="nuevoLeadCampana">
                                        Campaña
                                    </label>

                                    <select
                                        id="nuevoLeadCampana"
                                        class="crm-select"
                                    >

                                        <option value="">
                                            Sin campaña
                                        </option>

                                        ${campanas
                                            .map(campana => `
                                                <option value="${escapeHtml(campana.id)}">
                                                    ${escapeHtml(campana.nombre)}
                                                </option>
                                            `)
                                            .join("")}

                                    </select>

                                </div>


                                <div class="crm-form-field">

                                    <label for="nuevoLeadOrigen">
                                        Origen
                                    </label>

                                    <select
                                        id="nuevoLeadOrigen"
                                        class="crm-select"
                                    >

                                        <option value="WEB">
                                            Web
                                        </option>

                                        <option value="WHATSAPP">
                                            WhatsApp
                                        </option>

                                        <option value="GOOGLE">
                                            Google
                                        </option>

                                        <option value="FACEBOOK">
                                            Facebook
                                        </option>

                                        <option value="INSTAGRAM">
                                            Instagram
                                        </option>

                                        <option value="REFERIDO">
                                            Referido
                                        </option>

                                        <option value="CAMPAÑA">
                                            Campaña
                                        </option>

                                        <option value="EVENTO">
                                            Evento
                                        </option>

                                        <option value="LLAMADA">
                                            Llamada
                                        </option>

                                        <option value="OTRO">
                                            Otro
                                        </option>

                                    </select>

                                </div>

                            </div>

                        </section>



                        <!-- ================================================= -->
                        <!-- PLANIFICACIÓN -->
                        <!-- ================================================= -->

                        <section class="crm-form-section">

                            <div class="crm-detail-section-title">
                                <span>📅</span>
                                Planificación
                            </div>


                            <div class="crm-form-grid">

                                <div class="crm-form-field">

                                    <label for="nuevoLeadFecha">
                                        Fecha de viaje
                                    </label>

                                    <input
                                        type="date"
                                        id="nuevoLeadFecha"
                                        class="crm-input"
                                    >

                                </div>


                                <div class="crm-form-field">

                                    <label for="nuevoLeadViajeros">
                                        Viajeros
                                    </label>

                                    <input
                                        type="number"
                                        id="nuevoLeadViajeros"
                                        class="crm-input"
                                        min="1"
                                        step="1"
                                        value="1"
                                    >

                                </div>


                                <div class="crm-form-field">

                                    <label for="nuevoLeadDuracion">
                                        Duración (días)
                                    </label>

                                    <input
                                        type="number"
                                        id="nuevoLeadDuracion"
                                        class="crm-input"
                                        min="1"
                                        step="1"
                                    >

                                </div>


                                <div class="crm-form-field">

                                    <label for="nuevoLeadPresupuesto">
                                        Presupuesto
                                    </label>

                                    <input
                                        type="number"
                                        id="nuevoLeadPresupuesto"
                                        class="crm-input"
                                        min="0"
                                        step="0.01"
                                        placeholder="0.00"
                                    >

                                </div>


                                <div class="crm-form-field">

                                    <label for="nuevoLeadMoneda">
                                        Moneda
                                    </label>

                                    <select
                                        id="nuevoLeadMoneda"
                                        class="crm-select"
                                    >

                                        <option value="USD">
                                            USD
                                        </option>

                                        <option value="CRC">
                                            CRC
                                        </option>

                                        <option value="EUR">
                                            EUR
                                        </option>

                                    </select>

                                </div>

                            </div>

                        </section>



                        <!-- ================================================= -->
                        <!-- GESTIÓN COMERCIAL -->
                        <!-- ================================================= -->

                        <section class="crm-form-section">

                            <div class="crm-detail-section-title">
                                <span>📌</span>
                                Gestión comercial
                            </div>


                            <div class="crm-form-grid">

                                <div class="crm-form-field">

                                    <label for="nuevoLeadEstado">
                                        Estado
                                    </label>

                                    <select
                                        id="nuevoLeadEstado"
                                        class="crm-select"
                                    >

                                        <option value="NUEVO">
                                            Nuevo
                                        </option>

                                        <option value="CONTACTADO">
                                            Contactado
                                        </option>

                                        <option value="CALIFICADO">
                                            Calificado
                                        </option>

                                        <option value="NO_CALIFICADO">
                                            No calificado
                                        </option>

                                    </select>

                                </div>


                                <div class="crm-form-field">

                                    <label for="nuevoLeadPrioridad">
                                        Prioridad
                                    </label>

                                    <select
                                        id="nuevoLeadPrioridad"
                                        class="crm-select"
                                    >

                                        <option value="NORMAL">
                                            Normal
                                        </option>

                                        <option value="URGENTE">
                                            Urgente
                                        </option>

                                        <option value="ALTA">
                                            Alta
                                        </option>

                                        <option value="BAJA">
                                            Baja
                                        </option>

                                    </select>

                                </div>


                                <div class="crm-form-field">

                                    <label for="nuevoLeadVendedor">
                                        Vendedor
                                    </label>

                                    <select
                                        id="nuevoLeadVendedor"
                                        class="crm-select"
                                    >

                                        <option value="">
                                            Sin asignar
                                        </option>

                                    </select>

                                </div>

                            </div>


                            <div class="crm-form-field">

                                <label for="nuevoLeadMensaje">
                                    Mensaje / notas
                                </label>

                                <textarea
                                    id="nuevoLeadMensaje"
                                    class="crm-input"
                                    rows="4"
                                    placeholder="Información proporcionada por el cliente..."
                                ></textarea>

                            </div>

                        </section>


                        <div
                            id="nuevoLeadError"
                            class="crm-form-message crm-form-message-error"
                            style="display:none;"
                        ></div>


                    </form>

                </div>


                <div class="crm-modal-footer">

                    <button
                        type="button"
                        class="crm-btn crm-btn-secondary"
                        id="cancelarNuevoLead"
                    >
                        Cancelar
                    </button>

                    <button
                        type="button"
                        class="crm-btn crm-btn-primary"
                        id="guardarNuevoLead"
                    >
                        Guardar lead
                    </button>

                </div>

            </div>

        </div>

    `;


    configurarNuevoLead();

}

// ============================================================
// EVENTOS NUEVO LEAD
// ============================================================

function configurarNuevoLead() {

    const cerrar =
        () => {

            const container =
                document.getElementById(
                    "leadModalContainer"
                );

            if (container) {
                container.innerHTML = "";
            }

        };


    // ----------------------------------------------------------
    // BOTÓN X
    // ----------------------------------------------------------

    document
        .getElementById("cerrarNuevoLead")
        ?.addEventListener(
            "click",
            cerrar
        );


    // ----------------------------------------------------------
    // BOTÓN CANCELAR
    // ----------------------------------------------------------

    document
        .getElementById("cancelarNuevoLead")
        ?.addEventListener(
            "click",
            cerrar
        );


    // ----------------------------------------------------------
    // CLIC EN EL FONDO
    // ----------------------------------------------------------

    document
        .getElementById("nuevoLeadModal")
        ?.addEventListener(
            "click",
            event => {

                if (
                    event.target.id ===
                    "nuevoLeadModal"
                ) {
                    cerrar();
                }

            }
        );


    // ----------------------------------------------------------
    // TECLA ESC
    // ----------------------------------------------------------

    document.addEventListener(
        "keydown",
        function manejarEscape(event) {

            if (
                event.key !== "Escape"
            ) {
                return;
            }


            const modal =
                document.getElementById(
                    "nuevoLeadModal"
                );


            if (!modal) {
                return;
            }


            cerrar();


            document.removeEventListener(
                "keydown",
                manejarEscape
            );

        }
    );

    document
        .getElementById("guardarNuevoLead")
        ?.addEventListener(
            "click",
            guardarNuevoLead
        );

}

// ============================================================
// GUARDAR NUEVO LEAD
// ============================================================

async function guardarNuevoLead() {

    const boton =
        document.getElementById(
            "guardarNuevoLead"
        );

    const errorContainer =
        document.getElementById(
            "nuevoLeadError"
        );


    const mostrarErrorNuevoLead =
        (mensaje) => {

            if (!errorContainer) {
                return;
            }

            errorContainer.textContent =
                mensaje;

            errorContainer.style.display =
                "block";
        };


    const ocultarError =
        () => {

            if (!errorContainer) {
                return;
            }

            errorContainer.textContent =
                "";

            errorContainer.style.display =
                "none";
        };


    ocultarError();


    const contactoId =
        document.getElementById(
            "nuevoLeadContacto"
        )?.value || "";


    const nombre =
        document.getElementById(
            "nuevoLeadNombre"
        )?.value.trim() || "";


    const apellido =
        document.getElementById(
            "nuevoLeadApellido"
        )?.value.trim() || "";


    const email =
        document.getElementById(
            "nuevoLeadEmail"
        )?.value.trim() || "";


    const telefono =
        document.getElementById(
            "nuevoLeadTelefono"
        )?.value.trim() || "";


    const whatsapp =
        document.getElementById(
            "nuevoLeadWhatsapp"
        )?.value.trim() || "";


    const destinoId =
        document.getElementById(
            "nuevoLeadDestino"
        )?.value || null;


    const experienciaId =
        document.getElementById(
            "nuevoLeadExperiencia"
        )?.value || null;


    const viajeId =
        document.getElementById(
            "nuevoLeadViaje"
        )?.value || null;


    const campanaId =
        document.getElementById(
            "nuevoLeadCampana"
        )?.value || null;


    const origen =
        document.getElementById(
            "nuevoLeadOrigen"
        )?.value || "WEB";


    const fechaViaje =
        document.getElementById(
            "nuevoLeadFecha"
        )?.value || null;


    const viajeros =
        convertirNumeroONull(
            document.getElementById(
                "nuevoLeadViajeros"
            )?.value
        );


    const duracionDias =
        convertirNumeroONull(
            document.getElementById(
                "nuevoLeadDuracion"
            )?.value
        );


    const presupuesto =
        convertirDecimalONull(
            document.getElementById(
                "nuevoLeadPresupuesto"
            )?.value
        );


    const moneda =
        document.getElementById(
            "nuevoLeadMoneda"
        )?.value || "USD";


    const estado =
        document.getElementById(
            "nuevoLeadEstado"
        )?.value || "NUEVO";


    const prioridad =
        document.getElementById(
            "nuevoLeadPrioridad"
        )?.value || "NORMAL";


    const vendedorId =
        document.getElementById(
            "nuevoLeadVendedor"
        )?.value || null;


    const mensaje =
        document.getElementById(
            "nuevoLeadMensaje"
        )?.value.trim() || null;


    // ========================================================
    // VALIDACIONES
    // ========================================================

    if (!contactoId && !nombre) {

        mostrarErrorNuevoLead(
            "Debe seleccionar un contacto existente o ingresar el nombre del nuevo contacto."
        );

        return;
    }


    if (
        !contactoId &&
        !email &&
        !telefono &&
        !whatsapp
    ) {

        mostrarErrorNuevoLead(
            "Para crear un nuevo contacto debe ingresar al menos correo, teléfono o WhatsApp."
        );

        return;
    }


    if (
        !viajeros ||
        viajeros < 1
    ) {

        mostrarErrorNuevoLead(
            "La cantidad de viajeros debe ser al menos 1."
        );

        return;
    }


    // ========================================================
    // DESHABILITAR BOTÓN
    // ========================================================

    if (boton) {

        boton.disabled = true;

        boton.dataset.textoOriginal =
            boton.textContent;

        boton.textContent =
            "Guardando...";
    }


    try {

        let contactoFinalId =
            contactoId;


        // ====================================================
        // CONTACTO EXISTENTE
        // ====================================================

        if (!contactoFinalId) {

            let contactoExistente =
                null;


            // ------------------------------------------------
            // BUSCAR POR EMAIL
            // ------------------------------------------------

            if (email) {

                const resultadoEmail =
                    await supabase
                        .from("contactos")
                        .select(`
                            id,
                            nombre,
                            apellido,
                            email,
                            telefono,
                            whatsapp
                        `)
                        .ilike(
                            "email",
                            email
                        )
                        .limit(1)
                        .maybeSingle();


                if (
                    resultadoEmail.error &&
                    resultadoEmail.error.code !==
                    "PGRST116"
                ) {

                    throw resultadoEmail.error;
                }


                contactoExistente =
                    resultadoEmail.data;
            }


            // ------------------------------------------------
            // BUSCAR POR TELÉFONO
            // ------------------------------------------------

            if (
                !contactoExistente &&
                telefono
            ) {

                const resultadoTelefono =
                    await supabase
                        .from("contactos")
                        .select(`
                            id,
                            nombre,
                            apellido,
                            email,
                            telefono,
                            whatsapp
                        `)
                        .eq(
                            "telefono",
                            telefono
                        )
                        .limit(1)
                        .maybeSingle();


                if (
                    resultadoTelefono.error &&
                    resultadoTelefono.error.code !==
                    "PGRST116"
                ) {

                    throw resultadoTelefono.error;
                }


                contactoExistente =
                    resultadoTelefono.data;
            }


            // ------------------------------------------------
            // SI EXISTE → REUTILIZAR
            // ------------------------------------------------

            if (contactoExistente) {

                contactoFinalId =
                    contactoExistente.id;

            }

            // ------------------------------------------------
            // SI NO EXISTE → CREAR
            // ------------------------------------------------

            else {

                const resultadoContacto =
                    await supabase
                        .from("contactos")
                        .insert({
                            nombre:
                                nombre || null,

                            apellido:
                                apellido || null,

                            email:
                                email || null,

                            telefono:
                                telefono || null,

                            whatsapp:
                                whatsapp || null,

                            activo:
                                true
                        })
                        .select()
                        .single();


                if (
                    resultadoContacto.error
                ) {

                    throw resultadoContacto.error;
                }


                contactoFinalId =
                    resultadoContacto.data.id;


                // Agregarlo al catálogo local

                contactos.push(
                    resultadoContacto.data
                );
            }
        }


        // ====================================================
        // INSERTAR LEAD
        // ====================================================

        const datosLead = {

            contacto_id:
                contactoFinalId,

            destino_id:
                destinoId,

            experiencia_id:
                experienciaId,

            viaje_id:
                viajeId,

            campana_id:
                campanaId,

            origen:
                origen,

            estado:
                estado,

            prioridad:
                prioridad,

            fecha_viaje:
                fechaViaje,

            viajeros:
                viajeros,

            duracion_dias:
                duracionDias,

            presupuesto:
                presupuesto,

            moneda:
                moneda,

            mensaje:
                mensaje,

            vendedor_id:
                vendedorId
        };


        const resultadoLead =
            await supabase
                .from("leads")
                .insert(datosLead)
                .select()
                .single();


        if (resultadoLead.error) {

            throw resultadoLead.error;
        }


        const nuevoLead =
            resultadoLead.data;


        // ====================================================
        // ACTUALIZAR LISTA LOCAL
        // ====================================================

        leads.unshift(
            nuevoLead
        );


        // ====================================================
        // CERRAR MODAL
        // ====================================================

        const container =
            document.getElementById(
                "leadModalContainer"
            );


        if (container) {
            container.innerHTML = "";
        }


        // ====================================================
        // ACTUALIZAR TABLA
        // ====================================================

        renderTabla();


        // ====================================================
        // MOSTRAR DETALLE DEL NUEVO LEAD
        // ====================================================

        abrirDetalleLead(
            nuevoLead
        );


        console.log(
            "Lead creado correctamente:",
            nuevoLead
        );

    }
    catch (error) {

        console.error(
            "Error creando Lead:",
            error
        );


        let mensajeError =
            "No fue posible crear el lead.";


        if (
            error?.code ===
            "42501"
        ) {

            mensajeError =
                "No tienes permisos para realizar esta operación con tu usuario.";

        }
        else if (
            error?.code ===
            "23505"
        ) {

            mensajeError =
                "Ya existe un registro con esos datos.";

        }
        else if (
            error?.message
        ) {

            mensajeError =
                error.message;
        }


        mostrarErrorNuevoLead(
            mensajeError
        );

    }
    finally {

        if (boton) {

            boton.disabled =
                false;

            boton.textContent =
                boton.dataset
                    .textoOriginal ||
                "Guardar lead";
        }

    }



}