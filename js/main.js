import "../css/destination-detail.css";
import { createClient } from "@supabase/supabase-js";

/* ============================================================
   CONFIGURACIÓN SUPABASE
============================================================ */

const supabaseUrl =
    import.meta.env.VITE_SUPABASE_URL;

const supabasePublishableKey =
    import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY;

let supabase = null;

if (
    !supabaseUrl ||
    !supabasePublishableKey
) {
    console.error(
        "[Supabase] Faltan las variables VITE_SUPABASE_URL o VITE_SUPABASE_PUBLISHABLE_KEY."
    );
} else {
    supabase = createClient(
        supabaseUrl,
        supabasePublishableKey
    );

    window.supabase = supabase;

    console.log(
        "[Supabase] Cliente inicializado correctamente."
    );

    inicializarSitio();
}


/* ============================================================
   INICIALIZACIÓN
============================================================ */

async function inicializarSitio() {
    configurarBuscador();

    await cargarCatalogoDestinos();

    configurarEnlacesDestinos();

    configurarEnlacesGenerales();
}


/* ============================================================
   CATÁLOGO DE DESTINOS
============================================================ */

async function cargarCatalogoDestinos() {
    if (!supabase) {
        return;
    }

    console.log(
        "[Supabase] Cargando catálogo de destinos..."
    );

    const {
        data,
        error
    } = await supabase
        .from("destinos")
        .select(`
            id,
            nombre,
            slug,
            descripcion,
            imagen_url,
            activo,
            destino_experiencia (
                experiencia_id,
                experiencias (
                    id,
                    nombre,
                    slug,
                    activo
                )
            ),
            viajes (
                id,
                nombre,
                slug,
                descripcion,
                duracion_dias,
                duracion_noches,
                precio_desde,
                moneda,
                imagen_url,
                destacado,
                activo
            )
        `)
        .eq(
            "activo",
            true
        )
        .order(
            "nombre"
        );

    if (error) {
        console.error(
            "[Supabase] Error al consultar el catálogo de destinos:",
            error
        );

        mostrarErrorCatalogo(
            "No pudimos cargar nuestro catálogo de viajes en este momento."
        );

        return;
    }

    const catalogo =
        (data || []).map(
            (destino) => ({
                ...destino,

                destino_experiencia:
                    destino.destino_experiencia?.filter(
                        (relacion) =>
                            relacion.experiencias?.activo ===
                            true
                    ) || [],

                viajes:
                    destino.viajes
                        ?.filter(
                            (viaje) =>
                                viaje.activo ===
                                true
                        )
                        .map(
                            (viaje) => ({
                                ...viaje,

                                destino_id:
                                    destino.id,

                                destino_slug:
                                    destino.slug,

                                destino_nombre:
                                    destino.nombre
                            })
                        ) || []
            })
        );

    window.catalogoDestinos =
        catalogo;

    window.catalogoExperiencias =
        construirCatalogoExperiencias(
            catalogo
        );

    window.catalogoViajes =
        construirCatalogoViajes(
            catalogo
        );

    console.log(
        `[Supabase] Destinos públicos encontrados: ${catalogo.length}`
    );

    console.log(
        `[Supabase] Experiencias disponibles: ${window.catalogoExperiencias.length}`
    );

    console.log(
        `[Supabase] Viajes disponibles: ${window.catalogoViajes.length}`
    );

    console.table(
        catalogo.map(
            (destino) => ({
                nombre:
                    destino.nombre,

                slug:
                    destino.slug,

                experiencias:
                    destino
                        .destino_experiencia
                        .length,

                viajes:
                    destino.viajes.length
            })
        )
    );

    actualizarTarjetasDestinos(
        catalogo
    );

    actualizarTarjetasOfertas();

    configurarEnlacesGenerales();

    actualizarBuscadorDesdeCatalogo();
}


/* ============================================================
   CATÁLOGO GLOBAL DE EXPERIENCIAS
============================================================ */

function construirCatalogoExperiencias(
    destinos
) {
    const experiencias =
        new Map();

    destinos.forEach(
        (destino) => {
            destino.destino_experiencia?.forEach(
                (relacion) => {
                    const experiencia =
                        relacion.experiencias;

                    if (
                        !experiencia?.activo
                    ) {
                        return;
                    }

                    if (
                        !experiencias.has(
                            experiencia.id
                        )
                    ) {
                        experiencias.set(
                            experiencia.id,
                            {
                                ...experiencia,
                                destinos: []
                            }
                        );
                    }

                    const item =
                        experiencias.get(
                            experiencia.id
                        );

                    if (
                        !item.destinos.some(
                            (
                                destinoRelacionado
                            ) =>
                                destinoRelacionado.id ===
                                destino.id
                        )
                    ) {
                        item.destinos.push({
                            id:
                                destino.id,

                            nombre:
                                destino.nombre,

                            slug:
                                destino.slug
                        });
                    }
                }
            );
        }
    );

    return Array.from(
        experiencias.values()
    ).sort(
        (a, b) =>
            a.nombre.localeCompare(
                b.nombre,
                "es"
            )
    );
}


/* ============================================================
   CATÁLOGO GLOBAL DE VIAJES
============================================================ */

function construirCatalogoViajes(
    destinos
) {
    const viajes = [];

    destinos.forEach(
        (destino) => {
            destino.viajes?.forEach(
                (viaje) => {
                    viajes.push({
                        ...viaje,

                        destino_id:
                            destino.id,

                        destino_nombre:
                            destino.nombre,

                        destino_slug:
                            destino.slug,

                        experiencias:
                            destino
                                .destino_experiencia
                                ?.map(
                                    (
                                        relacion
                                    ) =>
                                        relacion.experiencias
                                )
                                .filter(
                                    Boolean
                                ) || []
                    });
                }
            );
        }
    );

    return viajes;
}


/* ============================================================
   TARJETAS DE DESTINOS
============================================================ */

function actualizarTarjetasDestinos(
    destinos
) {
    const tarjetasPorSlug = {
        europa:
            ".destination-europe",

        caribe:
            ".destination-caribbean",

        asia:
            ".destination-asia",

        "medio-oriente":
            ".destination-dubai"
    };

    let tarjetasActualizadas =
        0;

    destinos.forEach(
        (destino) => {
            const selector =
                tarjetasPorSlug[
                    destino.slug
                ];

            if (!selector) {
                return;
            }

            const tarjeta =
                document.querySelector(
                    selector
                );

            if (!tarjeta) {
                console.warn(
                    `[Supabase] No se encontró la tarjeta para el destino "${destino.slug}".`
                );

                return;
            }

            const nombre =
                tarjeta.querySelector(
                    ".destination-content h3"
                );

            const etiqueta =
                tarjeta.querySelector(
                    ".destination-content span"
                );

            const enlace =
                tarjeta.querySelector(
                    ".destination-content a"
                );

            if (nombre) {
                nombre.textContent =
                    destino.nombre;
            }

            if (etiqueta) {
                etiqueta.textContent =
                    obtenerEtiquetaDestino(
                        destino.slug
                    );
            }

            if (enlace) {
                enlace.href =
                    `#destino-${destino.slug}`;

                enlace.setAttribute(
                    "aria-label",
                    `Explorar destino ${destino.nombre}`
                );

                enlace.dataset.destinationSlug =
                    destino.slug;
            }

            tarjeta.dataset.destinationId =
                destino.id;

            tarjeta.dataset.destinationSlug =
                destino.slug;

            tarjetasActualizadas++;
        }
    );

    console.log(
        `[Supabase] Tarjetas de destinos actualizadas: ${tarjetasActualizadas}`
    );
}


/* ============================================================
   OFERTAS
============================================================ */

function actualizarTarjetasOfertas() {
    const viajes =
        window.catalogoViajes ||
        [];

    const destacados =
        viajes.filter(
            (viaje) =>
                viaje.destacado ===
                true
        );

    console.log(
        `[Supabase] Viajes destacados encontrados: ${destacados.length}`
    );

    const tarjetas = [
        {
            selector:
                ".offer-turkey",

            slugs: [
                "turquia-en-oferta"
            ]
        },

        {
            selector:
                ".offer-europe",

            slugs: [
                "maravillas-de-europa",
                "querida-europa",
                "luces-de-europa",
                "europa-en-bandeja",
                "europa-en-breve-desde-madrid"
            ]
        },

        {
            selector:
                ".offer-dubai",

            slugs: [
                "dubai"
            ]
        }
    ];

    tarjetas.forEach(
        (configuracion) => {
            const tarjeta =
                document.querySelector(
                    configuracion.selector
                );

            if (!tarjeta) {
                return;
            }

            const viaje =
                encontrarViajeParaOferta(
                    destacados,
                    configuracion.slugs
                );

            if (!viaje) {
                return;
            }

            actualizarTarjetaOferta(
                tarjeta,
                viaje
            );
        }
    );
}


function encontrarViajeParaOferta(
    viajes,
    slugs
) {
    return (
        viajes.find(
            (viaje) =>
                slugs.includes(
                    viaje.slug
                )
        ) || null
    );
}


function actualizarTarjetaOferta(
    tarjeta,
    viaje
) {
    const tarjetaOferta =
        tarjeta.closest(
            ".offer-card"
        ) || tarjeta;

    tarjetaOferta.dataset.tripSlug =
        viaje.slug;

    tarjetaOferta.dataset.destinationSlug =
        viaje.destino_slug;

    const titulo =
        tarjetaOferta.querySelector(
            "h3"
        );

    if (titulo) {
        titulo.textContent =
            viaje.nombre;
    }

    const enlace =
        tarjetaOferta.querySelector(
            ".offer-link"
        );

    if (enlace) {
        enlace.href =
            "#destination-detail";

        enlace.dataset.tripSlug =
            viaje.slug;

        enlace.dataset.destinationSlug =
            viaje.destino_slug;

        enlace.textContent =
            "Ver detalles →";
    }
}


/* ============================================================
   ENLACES DE DESTINOS
============================================================ */

function configurarEnlacesDestinos() {
    const enlaces =
        document.querySelectorAll(
            ".destination-content a[data-destination-slug]"
        );

    enlaces.forEach(
        (enlace) => {
            if (
                enlace.dataset.destinationConfigured ===
                "true"
            ) {
                return;
            }

            enlace.addEventListener(
                "click",
                manejarClickDestino
            );

            enlace.dataset.destinationConfigured =
                "true";
        }
    );

    console.log(
        `[Supabase] Enlaces de destinos configurados: ${enlaces.length}`
    );
}


/* ============================================================
   CLICK EN DESTINO
============================================================ */

function manejarClickDestino(
    event
) {
    event.preventDefault();

    const enlace =
        event.currentTarget;

    const slug =
        enlace.dataset.destinationSlug;

    if (!slug) {
        console.warn(
            "[Supabase] El enlace de destino no tiene slug."
        );

        return;
    }

    const destino =
        window.catalogoDestinos?.find(
            (item) =>
                item.slug ===
                slug
        );

    if (!destino) {
        console.warn(
            `[Supabase] No se encontró el destino "${slug}" en el catálogo.`
        );

        return;
    }

    mostrarDetalleDestino(
        destino
    );
}


/* ============================================================
   DETALLE VISUAL DEL DESTINO
============================================================ */

function mostrarDetalleDestino(
    destino
) {
    const detalle =
        crearContenedorDetalleDestino();

    detalle.innerHTML =
        construirDetalleDestino(
            destino
        );

    detalle.classList.remove(
        "is-hidden"
    );

    detalle.dataset.destinationSlug =
        destino.slug;

    configurarAccionesDetalleDestino(
        detalle
    );

    requestAnimationFrame(
        () => {
            detalle.scrollIntoView({
                behavior:
                    "smooth",

                block:
                    "start"
            });
        }
    );
}


/* ============================================================
   CONTENEDOR DEL DETALLE
============================================================ */

function crearContenedorDetalleDestino() {
    let detalle =
        document.querySelector(
            "#destination-detail"
        );

    if (detalle) {
        return detalle;
    }

    detalle =
        document.createElement(
            "section"
        );

    detalle.id =
        "destination-detail";

    detalle.className =
        "destination-detail is-hidden";

    const ofertas =
        document.querySelector(
            "#ofertas"
        );

    if (ofertas) {
        ofertas.parentNode.insertBefore(
            detalle,
            ofertas
        );
    } else {
        const destinos =
            document.querySelector(
                "#destinos"
            );

        if (
            destinos?.parentNode
        ) {
            destinos.parentNode.insertBefore(
                detalle,
                destinos.nextSibling
            );
        } else {
            document.body.appendChild(
                detalle
            );
        }
    }

    return detalle;
}


/* ============================================================
   CONSTRUCCIÓN DEL DETALLE
============================================================ */

function construirDetalleDestino(
    destino
) {
    const experiencias =
        destino.destino_experiencia
            ?.map(
                (relacion) =>
                    relacion
                        .experiencias
                        ?.nombre
            )
            .filter(
                Boolean
            ) || [];

    const viajes =
        destino.viajes ||
        [];

    const descripcion =
        destino.descripcion ||
        `Descubre ${destino.nombre} con experiencias diseñadas para disfrutar cada destino de una manera auténtica y memorable.`;

    const experienciasHTML =
        experiencias.length > 0
            ? experiencias
                  .map(
                      (
                          experiencia
                      ) => `
                        <span class="destination-experience-tag">
                            ${escaparHTML(
                                experiencia
                            )}
                        </span>
                    `
                  )
                  .join("")
            : `
                <div class="destination-detail-empty">
                    No hay experiencias disponibles para este destino.
                </div>
            `;

    const viajesHTML =
        viajes.length > 0
            ? viajes
                  .map(
                      (viaje) =>
                          construirTarjetaViaje(
                              viaje
                          )
                  )
                  .join("")
            : `
                <div class="destination-detail-empty">
                    No hay viajes disponibles para este destino.
                </div>
            `;

    return `
        <div class="container">

            <div class="destination-detail-header">

                <span class="destination-detail-eyebrow">
                    ${escaparHTML(
                        obtenerEtiquetaDestino(
                            destino.slug
                        )
                    )}
                </span>

                <h2 class="destination-detail-title">
                    ${escaparHTML(
                        destino.nombre
                    )}
                </h2>

                <p class="destination-detail-description">
                    ${escaparHTML(
                        descripcion
                    )}
                </p>

            </div>

            <div class="destination-detail-section">

                <h3 class="destination-detail-section-title">
                    Experiencias
                </h3>

                <div class="destination-experiences">
                    ${experienciasHTML}
                </div>

            </div>

            <div class="destination-detail-section">

                <h3 class="destination-detail-section-title">
                    Viajes disponibles
                </h3>

                <div class="destination-trips">
                    ${viajesHTML}
                </div>

            </div>

            <button
                type="button"
                class="destination-detail-close"
                data-action="close-destination-detail"
            >
                Cerrar detalle
            </button>

        </div>
    `;
}


/* ============================================================
   TARJETA DE VIAJE
============================================================ */

function construirTarjetaViaje(
    viaje
) {
    const duracion =
        construirDuracionViaje(
            viaje
        );

    const precio =
        formatearPrecio(
            viaje.precio_desde,
            viaje.moneda
        );

    const destacado =
        viaje.destacado ===
        true;

    return `
        <article
            class="destination-trip-card ${
                destacado
                    ? "is-featured"
                    : ""
            }"
            data-trip-slug="${escaparHTML(
                viaje.slug
            )}"
        >

            ${
                destacado
                    ? `
                        <span class="destination-trip-badge">
                            Destacado
                        </span>
                    `
                    : ""
            }

            <h4 class="destination-trip-title">
                ${escaparHTML(
                    viaje.nombre
                )}
            </h4>

            <p class="destination-trip-description">
                ${escaparHTML(
                    viaje.descripcion ||
                        "Consulta este itinerario y descubre una experiencia diseñada para tu viaje."
                )}
            </p>

            <div class="destination-trip-meta">

                ${
                    duracion
                        ? `
                            <span>
                                ${escaparHTML(
                                    duracion
                                )}
                            </span>
                        `
                        : ""
                }

            </div>

            ${
                precio
                    ? `
                        <div class="destination-trip-price">

                            <span class="destination-trip-price-label">
                                Desde
                            </span>

                            <span class="destination-trip-price-value">
                                ${escaparHTML(
                                    precio
                                )}
                            </span>

                        </div>
                    `
                    : ""
            }

            <div class="destination-trip-actions">

                <button
                    type="button"
                    class="destination-trip-action destination-trip-action-primary"
                    data-action="view-trip"
                    data-trip-slug="${escaparHTML(
                        viaje.slug
                    )}"
                >
                    Ver detalles →
                </button>

                <a
                    href="#planifica"
                    class="destination-trip-action destination-trip-action-secondary"
                    data-action="request-quote"
                    data-trip-slug="${escaparHTML(
                        viaje.slug
                    )}"
                >
                    Solicitar cotización
                </a>

            </div>

        </article>
    `;
}


/* ============================================================
   ACCIONES DEL DETALLE
============================================================ */

function configurarAccionesDetalleDestino(detalle) {
    if (!detalle) {
        return;
    }

    if (
        detalle.dataset.actionsConfigured ===
        "true"
    ) {
        return;
    }

    detalle.addEventListener(
        "click",
        (event) => {
            const elemento =
                event.target.closest(
                    "[data-action]"
                );

            if (!elemento) {
                return;
            }

            const accion =
                elemento.dataset.action;

            switch (accion) {

                case "close-destination-detail":
                    event.preventDefault();

                    cerrarDetalleDestino();
                    break;


                case "request-quote":
                    event.preventDefault();

                    manejarSolicitudCotizacion(
                        event
                    );
                    break;


                case "view-trip":
                    event.preventDefault();

                    manejarVerDetalleViaje(
                        event
                    );
                    break;


                case "select-trip-option":
                    event.preventDefault();

                    manejarSeleccionOpcionViaje(
                        event
                    );
                    break;

                default:
                    break;
            }
        }
    );

    detalle.dataset.actionsConfigured =
        "true";

    console.log(
        "[Detalle] Acciones configuradas correctamente."
    );
}

/* ============================================================
   DETALLE COMPLETO DEL VIAJE
============================================================ */

async function manejarVerDetalleViaje(event) {
    event.preventDefault();

    const boton =
        event.currentTarget;

    const slug =
        boton?.dataset?.tripSlug;

    if (!slug) {
        console.warn(
            "[Viaje] El enlace no tiene slug de viaje."
        );

        return;
    }

    await mostrarDetalleViaje(
        slug
    );
}


/* ============================================================
   MOSTRAR DETALLE DEL VIAJE
============================================================ */

async function mostrarDetalleViaje(
    slug
) {
    const viaje =
        buscarViajePorSlug(
            slug
        );

    if (!viaje) {
        console.warn(
            `[Viaje] No se encontró el viaje "${slug}".`
        );

        return;
    }

    const detalle =
        crearContenedorDetalleDestino();

    detalle.innerHTML = `
        <div class="container">
            <div class="trip-detail-loading">
                <div class="trip-detail-loading-spinner"></div>

                <p>
                    Cargando información del viaje...
                </p>
            </div>
        </div>
    `;

    detalle.classList.remove(
        "is-hidden"
    );

    detalle.dataset.tripSlug =
        viaje.slug;

    requestAnimationFrame(
        () => {
            detalle.scrollIntoView({
                behavior:
                    "smooth",

                block:
                    "start"
            });
        }
    );

    try {
        const datos =
            await cargarDetalleViaje(
                viaje.id
            );

        window.viajeDetalleActual = {
            viaje,
            ...datos
        };

        detalle.dataset.tripSlug =
            viaje.slug;

        detalle.innerHTML =
            construirDetalleViaje(
                viaje,
                datos
            );

        configurarAccionesDetalleDestino(
            detalle
        );

    } catch (error) {
        console.error(
            "[Viaje] Error cargando detalle:",
            error
        );

        detalle.innerHTML = `
            <div class="container">

                <div class="destination-detail-section">

                    <div class="destination-detail-empty">

                        No pudimos cargar el detalle de este viaje.

                        Intenta nuevamente.

                    </div>

                    <button
                        type="button"
                        class="destination-detail-close"
                        data-action="close-destination-detail"
                    >
                        Cerrar detalle
                    </button>

                </div>

            </div>
        `;

        configurarAccionesDetalleDestino(
            detalle
        );
    }
}


/* ============================================================
   SELECCIONAR VARIANTE DEL VIAJE
============================================================ */

function manejarSeleccionOpcionViaje(event) {
    const tarjeta =
        event.target.closest(
            '[data-action="select-trip-option"]'
        );

    if (!tarjeta) {
        return;
    }

    const optionId =
        tarjeta.dataset.optionId;

    if (!optionId) {
        console.warn(
            "[Viaje] La tarjeta de variante no tiene data-option-id."
        );

        return;
    }

    const detalle =
        tarjeta.closest(
            "#destination-detail"
        );

    if (!detalle) {
        console.warn(
            "[Viaje] No se encontró el contenedor del detalle."
        );

        return;
    }

    const estado =
        window.viajeDetalleActual;

    if (!estado) {
        console.warn(
            "[Viaje] No existe viajeDetalleActual."
        );

        return;
    }

    const opciones =
        estado.opciones ||
        [];

    const opcion =
        opciones.find(
            (item) =>
                item.id ===
                optionId
        );

    if (!opcion) {
        console.warn(
            `[Viaje] No se encontró la variante ${optionId}.`
        );

        return;
    }

    console.log(
        "[Viaje] Variante seleccionada:",
        {
            id:
                opcion.id,

            nombre:
                opcion.nombre,

            dias:
                opcion.duracion_dias,

            noches:
                opcion.duracion_noches,

            precio:
                opcion.precio
        }
    );

    estado.opcionSeleccionada =
        opcion;


    /*
       Actualizar selección visual
    */

    const opcionesDOM =
        detalle.querySelectorAll(
            ".trip-detail-option"
        );

    opcionesDOM.forEach(
        (elemento) => {

            const seleccionada =
                elemento.dataset.optionId ===
                optionId;

            elemento.classList.toggle(
                "is-selected",
                seleccionada
            );

            elemento.setAttribute(
                "aria-pressed",
                seleccionada
                    ? "true"
                    : "false"
            );

            const badge =
                elemento.querySelector(
                    ".trip-detail-option-badge"
                );

            const header =
                elemento.querySelector(
                    ".trip-detail-option-header"
                );

            if (
                seleccionada &&
                !badge &&
                header
            ) {
                const nuevoBadge =
                    document.createElement(
                        "span"
                    );

                nuevoBadge.className =
                    "trip-detail-option-badge";

                nuevoBadge.textContent =
                    "Seleccionada";

                header.insertBefore(
                    nuevoBadge,
                    header.firstChild
                );
            }

            if (
                !seleccionada &&
                badge
            ) {
                badge.remove();
            }

            const hint =
                elemento.querySelector(
                    ".trip-detail-option-hint"
                );

            if (hint) {
                hint.textContent =
                    seleccionada
                        ? "Esta es la variante seleccionada"
                        : "Haz clic para seleccionar esta variante";
            }
        }
    );


    /*
       Actualizar duración y precio
    */

    actualizarMetaVariante(
        detalle,
        opcion
    );


    /*
       Actualizar itinerario
    */

    const todosLosDias =
        estado.itinerario ||
        [];

    const itinerarioVariante =
        todosLosDias.filter(
            (dia) =>
                dia.opcion_id ===
                optionId
        );

    const itinerarioBase =
        todosLosDias.filter(
            (dia) =>
                !dia.opcion_id
        );

    const itinerarioMostrar =
        itinerarioVariante.length
            ? itinerarioVariante
            : itinerarioBase.length
                ? itinerarioBase
                : todosLosDias;


    const contenedorItinerario =
        detalle.querySelector(
            "[data-trip-itinerary]"
        );

    if (
        contenedorItinerario
    ) {
        contenedorItinerario.innerHTML =
            construirItinerarioHTML(
                itinerarioMostrar
            );
    }


    const tituloItinerario =
        detalle.querySelector(
            "[data-trip-itinerary-title]"
        );

    if (
        tituloItinerario
    ) {
        tituloItinerario.textContent =
            `Itinerario — ${opcion.nombre}`;
    }
}

/* ============================================================
   Cargar Detalle Viaje
============================================================ */

async function cargarDetalleViaje(slug) {
    if (!slug) {
        throw new Error(
            "No se recibió el slug del viaje."
        );
    }

    console.log(
        `[Supabase] Cargando detalle del viaje: ${slug}`
    );

    const {
        data: viaje,
        error: errorViaje
    } = await supabaseClient
        .from("viajes")
        .select(`
            *,
            destinos (
                id,
                nombre,
                slug
            )
        `)
        .eq("slug", slug)
        .eq("activo", true)
        .single();

    if (errorViaje) {
        throw errorViaje;
    }

    if (!viaje) {
        throw new Error(
            `No se encontró el viaje "${slug}".`
        );
    }

    const viajeId =
        viaje.id;

    const [
        itinerarioResult,
        hotelesResult,
        inclusionesResult,
        exclusionesResult,
        opcionesResult,
        salidasResult
    ] = await Promise.all([

        supabaseClient
            .from("viaje_itinerario")
            .select("*")
            .eq("viaje_id", viajeId)
            .order(
                "dia_numero",
                {
                    ascending: true
                }
            ),

        supabaseClient
            .from("viaje_hoteles")
            .select("*")
            .eq("viaje_id", viajeId)
            .order(
                "orden",
                {
                    ascending: true
                }
            ),

        supabaseClient
            .from("viaje_inclusiones")
            .select("*")
            .eq("viaje_id", viajeId)
            .order(
                "orden",
                {
                    ascending: true
                }
            ),

        supabaseClient
            .from("viaje_exclusiones")
            .select("*")
            .eq("viaje_id", viajeId)
            .order(
                "orden",
                {
                    ascending: true
                }
            ),

        supabaseClient
            .from("viaje_opciones")
            .select(`
                *,
                viaje_opcion_items (
                    *
                )
            `)
            .eq("viaje_id", viajeId)
            .eq("activo", true)
            .order(
                "orden",
                {
                    ascending: true
                }
            ),

        supabaseClient
            .from("viaje_salidas")
            .select("*")
            .eq("viaje_id", viajeId)
            .eq("activo", true)
            .order(
                "fecha_inicio",
                {
                    ascending: true
                }
            )
    ]);


    const resultados = [
        {
            nombre:
                "itinerario",

            resultado:
                itinerarioResult
        },

        {
            nombre:
                "hoteles",

            resultado:
                hotelesResult
        },

        {
            nombre:
                "inclusiones",

            resultado:
                inclusionesResult
        },

        {
            nombre:
                "exclusiones",

            resultado:
                exclusionesResult
        },

        {
            nombre:
                "opciones",

            resultado:
                opcionesResult
        },

        {
            nombre:
                "salidas",

            resultado:
                salidasResult
        }
    ];

    const errores =
        resultados.filter(
            ({
                resultado
            }) =>
                resultado.error
        );

    if (errores.length) {
        console.error(
            "[Supabase] Errores cargando componentes del viaje:",
            errores
        );

        throw errores[0].resultado.error;
    }


    console.log(
        "[Supabase] Detalle cargado correctamente:",
        {
            viaje:
                viaje.nombre,

            itinerario:
                itinerarioResult.data?.length ||
                0,

            hoteles:
                hotelesResult.data?.length ||
                0,

            inclusiones:
                inclusionesResult.data?.length ||
                0,

            exclusiones:
                exclusionesResult.data?.length ||
                0,

            opciones:
                opcionesResult.data?.length ||
                0,

            salidas:
                salidasResult.data?.length ||
                0
        }
    );


    return {
        viaje,
        itinerario:
            itinerarioResult.data ||
            [],

        hoteles:
            hotelesResult.data ||
            [],

        inclusiones:
            inclusionesResult.data ||
            [],

        exclusiones:
            exclusionesResult.data ||
            [],

        opciones:
            opcionesResult.data ||
            [],

        salidas:
            salidasResult.data ||
            []
    };
}


/* ============================================================
   CONSTRUIR DETALLE COMPLETO
============================================================ */

function construirDetalleViaje(
    viaje,
    datos
) {
    const {
        itinerario,
        hoteles,
        inclusiones,
        exclusiones,
        opciones,
        salidas
    } = datos;

    const opcionesActivas =
        opciones.filter(
            (opcion) =>
                opcion.activo !==
                false
        );

    const opcionInicial =
        opcionesActivas[0] ||
        null;

    const itinerarioBase =
        itinerario.filter(
            (dia) =>
                !dia.opcion_id
        );

    const itinerarioInicial =
        opcionInicial
            ? itinerario.filter(
                (dia) =>
                    dia.opcion_id ===
                    opcionInicial.id
            )
            : itinerarioBase.length
                ? itinerarioBase
                : itinerario;

    const duracion =
        opcionInicial
            ? construirDuracionViaje(
                {
                    duracion_dias:
                        opcionInicial.duracion_dias,

                    duracion_noches:
                        opcionInicial.duracion_noches
                }
            )
            : construirDuracionViaje(
                viaje
            );

    const precio =
        opcionInicial
            ? formatearPrecio(
                opcionInicial.precio,
                opcionInicial.moneda
            )
            : formatearPrecio(
                viaje.precio_desde,
                viaje.moneda
            );

    return `
        <div class="container trip-detail">

            <div class="trip-detail-hero">

                <div class="trip-detail-hero-content">

                    <span class="trip-detail-eyebrow">
                        ${escaparHTML(
                            viaje.destino_nombre ||
                            "GALERÍA DE VIAJES"
                        )}
                    </span>

                    <h2 class="trip-detail-title">
                        ${escaparHTML(
                            viaje.nombre
                        )}
                    </h2>

                    ${
                        viaje.descripcion
                            ? `
                                <p class="trip-detail-description">
                                    ${escaparHTML(
                                        viaje.descripcion
                                    )}
                                </p>
                            `
                            : ""
                    }

                    <div
                        class="trip-detail-meta"
                        data-trip-meta
                    >

                        ${
                            duracion
                                ? `
                                    <span>
                                        ${escaparHTML(
                                            duracion
                                        )}
                                    </span>
                                `
                                : ""
                        }

                        ${
                            precio
                                ? `
                                    <span>
                                        Desde
                                        ${escaparHTML(
                                            precio
                                        )}
                                    </span>
                                `
                                : ""
                        }

                    </div>

                </div>

            </div>


            ${
                opcionesActivas.length
                    ? construirOpcionesHTML(
                        opcionesActivas
                    )
                    : ""
            }


            ${
                itinerarioInicial.length
                    ? `
                        <section
                            class="trip-detail-section trip-detail-itinerary-section"
                            data-trip-itinerary-section
                        >

                            <div class="trip-detail-section-heading">

                                <span class="trip-detail-section-kicker">
                                    EL VIAJE
                                </span>

                                <h3 data-trip-itinerary-title>
                                    ${
                                        opcionInicial
                                            ? `Itinerario · ${escaparHTML(
                                                opcionInicial.nombre
                                            )}`
                                            : "Itinerario"
                                    }
                                </h3>

                            </div>

                            <div
                                class="trip-detail-itinerary"
                                data-trip-itinerary
                            >
                                ${construirItinerarioHTML(
                                    itinerarioInicial
                                )}
                            </div>

                        </section>
                    `
                    : ""
            }


            ${
                hoteles.length
                    ? `
                        <section class="trip-detail-section">

                            <div class="trip-detail-section-heading">

                                <span class="trip-detail-section-kicker">
                                    ALOJAMIENTO
                                </span>

                                <h3>
                                    Hoteles previstos
                                </h3>

                            </div>

                            ${construirHotelesHTML(
                                hoteles
                            )}

                        </section>
                    `
                    : ""
            }


            <div class="trip-detail-columns">

                ${
                    inclusiones.length
                        ? `
                            <section class="trip-detail-section">

                                <div class="trip-detail-section-heading">

                                    <span class="trip-detail-section-kicker">
                                        INCLUYE
                                    </span>

                                    <h3>
                                        Tu viaje incluye
                                    </h3>

                                </div>

                                ${construirListaCaracteristicasHTML(
                                    inclusiones
                                )}

                            </section>
                        `
                        : ""
                }


                ${
                    exclusiones.length
                        ? `
                            <section class="trip-detail-section">

                                <div class="trip-detail-section-heading">

                                    <span class="trip-detail-section-kicker">
                                        NO INCLUYE
                                    </span>

                                    <h3>
                                        Consideraciones
                                    </h3>

                                </div>

                                ${construirListaCaracteristicasHTML(
                                    exclusiones
                                )}

                            </section>
                        `
                        : ""
                }

            </div>


            ${
                salidas.length
                    ? construirSalidasHTML(
                        salidas
                    )
                    : ""
            }


            <div class="trip-detail-actions">

                <a
                    href="#planifica"
                    class="destination-trip-action"
                    data-action="request-quote"
                    data-trip-slug="${escaparHTML(
                        viaje.slug
                    )}"
                >
                    Solicitar cotización
                </a>

                <button
                    type="button"
                    class="destination-detail-close"
                    data-action="close-destination-detail"
                >
                    Cerrar detalle
                </button>

            </div>

        </div>
    `;
}


/* ============================================================
   ITINERARIO
============================================================ */

function construirItinerarioHTML(
    itinerario
) {
    return itinerario
        .map(
            (dia) => {

                const ruta =
                    construirRutaItinerario(
                        dia
                    );

                return `
                    <article class="trip-detail-day">

                        <div class="trip-detail-day-number">
                            ${escaparHTML(
                                String(
                                    dia.dia_numero
                                )
                            )}
                        </div>

                        <div class="trip-detail-day-content">

                            ${
                                dia.dia_semana
                                    ? `
                                        <span class="trip-detail-day-weekday">
                                            ${escaparHTML(
                                                dia.dia_semana
                                            )}
                                        </span>
                                    `
                                    : ""
                            }

                            <h4>
                                ${escaparHTML(
                                    dia.titulo
                                )}
                            </h4>

                            ${
                                ruta
                                    ? `
                                        <div class="trip-detail-route">
                                            ${escaparHTML(
                                                ruta
                                            )}
                                        </div>
                                    `
                                    : ""
                            }

                            ${
                                dia.descripcion
                                    ? `
                                        <p>
                                            ${escaparHTML(
                                                dia.descripcion
                                            )}
                                        </p>
                                    `
                                    : ""
                            }

                            ${
                                dia.alojamiento
                                    ? `
                                        <div class="trip-detail-accommodation">

                                            <strong>
                                                Alojamiento:
                                            </strong>

                                            ${escaparHTML(
                                                dia.alojamiento
                                            )}

                                        </div>
                                    `
                                    : ""
                            }

                        </div>

                    </article>
                `;
            }
        )
        .join("");
}


/* ============================================================
   RUTA DEL ITINERARIO
============================================================ */

function construirRutaItinerario(
    dia
) {
    const origen =
        dia.ciudad_origen?.trim();

    const destino =
        dia.ciudad_destino?.trim();

    if (
        origen &&
        destino
    ) {
        return `${origen} → ${destino}`;
    }

    if (destino) {
        return destino;
    }

    if (origen) {
        return origen;
    }

    return "";
}

/* ============================================================
   HOTELES
============================================================ */

function construirHotelesHTML(
    hoteles
) {
    return `
        <div class="trip-detail-hotels">

            ${hoteles
                .map(
                    (hotel) => `
                        <article class="trip-detail-hotel">

                            <div class="trip-detail-hotel-city">
                                ${escaparHTML(
                                    hotel.ciudad ||
                                    ""
                                )}
                            </div>

                            <h4>
                                ${escaparHTML(
                                    hotel.nombre_hotel ||
                                    ""
                                )}
                            </h4>

                            ${
                                hotel.categoria
                                    ? `
                                        <span>
                                            ${escaparHTML(
                                                hotel.categoria
                                            )}
                                        </span>
                                    `
                                    : ""
                            }

                        </article>
                    `
                )
                .join("")}

        </div>
    `;
}


/* ============================================================
   INCLUYE / NO INCLUYE
============================================================ */

function construirListaCaracteristicasHTML(
    elementos
) {
    return `
        <ul class="trip-detail-features">

            ${elementos
                .map(
                    (elemento) => `
                        <li>

                            <span class="trip-detail-feature-icon">
                                ✓
                            </span>

                            <span>
                                ${escaparHTML(
                                    elemento.descripcion
                                )}
                            </span>

                        </li>
                    `
                )
                .join("")}

        </ul>
    `;
}


/* ============================================================
   OPCIONES / VARIANTES
============================================================ */

function construirOpcionesHTML(opciones) {
    return `
        <section class="trip-detail-section trip-detail-options">

            <div class="trip-detail-section-heading">

                <span class="trip-detail-section-kicker">
                    OPCIONES
                </span>

                <h3>
                    Elige tu versión del viaje
                </h3>

            </div>

            <div class="trip-detail-options-grid">

                ${opciones
                    .map(
                        (opcion, indice) => {

                            const seleccionada =
                                indice === 0;

                            const items =
                                [
                                    ...(opcion.viaje_opcion_items ||
                                    [])
                                ].sort(
                                    (a, b) =>
                                        (a.orden || 0) -
                                        (b.orden || 0)
                                );

                            return `
                                <article
                                    class="trip-detail-option ${
                                        seleccionada
                                            ? "is-selected"
                                            : ""
                                    }"
                                    data-action="select-trip-option"
                                    data-option-id="${escaparHTML(
                                        opcion.id
                                    )}"
                                    tabindex="0"
                                    role="button"
                                    aria-pressed="${
                                        seleccionada
                                            ? "true"
                                            : "false"
                                    }"
                                >

                                    <div class="trip-detail-option-header">

                                        ${
                                            seleccionada
                                                ? `
                                                    <span class="trip-detail-option-badge">
                                                        Seleccionada
                                                    </span>
                                                `
                                                : ""
                                        }

                                        <h4>
                                            ${escaparHTML(
                                                opcion.nombre
                                            )}
                                        </h4>

                                    </div>

                                    ${
                                        opcion.descripcion
                                            ? `
                                                <p>
                                                    ${escaparHTML(
                                                        opcion.descripcion
                                                    )}
                                                </p>
                                            `
                                            : ""
                                    }

                                    <div class="trip-detail-option-meta">

                                        ${
                                            opcion.duracion_dias
                                                ? `
                                                    <span>
                                                        ${opcion.duracion_dias}
                                                        ${
                                                            opcion.duracion_noches !==
                                                                null &&
                                                            opcion.duracion_noches !==
                                                                undefined
                                                                ? ` días / ${opcion.duracion_noches} noches`
                                                                : " días"
                                                        }
                                                    </span>
                                                `
                                                : opcion.duracion_noches !==
                                                      null &&
                                                  opcion.duracion_noches !==
                                                      undefined
                                                    ? `
                                                        <span>
                                                            ${opcion.duracion_noches}
                                                            noches
                                                        </span>
                                                    `
                                                    : ""
                                        }

                                        ${
                                            opcion.precio !==
                                                null &&
                                            opcion.precio !==
                                                undefined
                                                ? `
                                                    <strong>
                                                        ${escaparHTML(
                                                            formatearPrecio(
                                                                opcion.precio,
                                                                opcion.moneda
                                                            )
                                                        )}
                                                    </strong>
                                                `
                                                : ""
                                        }

                                    </div>

                                    ${
                                        items.length
                                            ? `
                                                <ul class="trip-detail-option-items">

                                                    ${items
                                                        .map(
                                                            (item) => `
                                                                <li>

                                                                    <span>
                                                                        ${escaparHTML(
                                                                            obtenerEtiquetaTipoOpcion(
                                                                                item.tipo
                                                                            )
                                                                        )}
                                                                    </span>

                                                                    ${escaparHTML(
                                                                        item.descripcion
                                                                    )}

                                                                </li>
                                                            `
                                                        )
                                                        .join("")}

                                                </ul>
                                            `
                                            : ""
                                    }

                                    <div class="trip-detail-option-hint">
                                        ${
                                            seleccionada
                                                ? "Esta es la variante seleccionada"
                                                : "Haz clic para seleccionar esta variante"
                                        }
                                    </div>

                                </article>
                            `;
                        }
                    )
                    .join("")}

            </div>

        </section>
    `;
}

/* ============================================================
   ETIQUETA DE TIPO DE OPCIÓN
============================================================ */

function obtenerEtiquetaTipoOpcion(
    tipo
) {
    const etiquetas = {
        COMIDA:
            "Comida",

        VISITA:
            "Visita",

        ACTIVIDAD:
            "Actividad",

        OTRO:
            "Incluye"
    };

    return (
        etiquetas[tipo] ||
        "Servicio"
    );
}


/* ============================================================
   SALIDAS
============================================================ */

function construirSalidasHTML(
    salidas
) {
    return `
        <section class="trip-detail-section trip-detail-departures">

            <div class="trip-detail-section-heading">

                <span class="trip-detail-section-kicker">
                    SALIDAS
                </span>

                <h3>
                    Fechas disponibles
                </h3>

            </div>

            <div class="trip-detail-departures-list">

                ${salidas
                    .map(
                        (salida) => `
                            <div class="trip-detail-departure">

                                <strong>
                                    ${escaparHTML(
                                        formatearRangoFechas(
                                            salida
                                        )
                                    )}
                                </strong>

                                ${
                                    salida.texto_original
                                        ? `
                                            <span>
                                                ${escaparHTML(
                                                    salida.texto_original
                                                )}
                                            </span>
                                        `
                                        : ""
                                }

                                ${
                                    salida.observaciones
                                        ? `
                                            <small>
                                                ${escaparHTML(
                                                    salida.observaciones
                                                )}
                                            </small>
                                        `
                                        : ""
                                }

                            </div>
                        `
                    )
                    .join("")}

            </div>

        </section>
    `;
}


/* ============================================================
   FORMATEAR RANGO DE FECHAS
============================================================ */

function formatearRangoFechas(
    salida
) {
    if (
        salida.fecha_inicio &&
        salida.fecha_fin &&
        salida.fecha_inicio !==
            salida.fecha_fin
    ) {
        return `${formatearFecha(
            salida.fecha_inicio
        )} – ${formatearFecha(
            salida.fecha_fin
        )}`;
    }

    if (
        salida.fecha_inicio
    ) {
        return formatearFecha(
            salida.fecha_inicio
        );
    }

    if (
        salida.texto_original
    ) {
        return salida.texto_original;
    }

    return "Fecha por confirmar";
}


/* ============================================================
   FORMATEAR FECHA
============================================================ */

function formatearFecha(
    fecha
) {
    if (!fecha) {
        return "";
    }

    const valor =
        new Date(
            `${fecha}T00:00:00`
        );

    if (
        Number.isNaN(
            valor.getTime()
        )
    ) {
        return fecha;
    }

    return valor.toLocaleDateString(
        "es-CR",
        {
            day:
                "numeric",

            month:
                "long",

            year:
                "numeric"
        }
    );
}


/* ============================================================
   CERRAR DETALLE
============================================================ */

function cerrarDetalleDestino() {
    const detalle =
        document.querySelector(
            "#destination-detail"
        );

    if (!detalle) {
        return;
    }

    detalle.classList.add(
        "is-hidden"
    );

    const destinos =
        document.querySelector(
            "#destinos"
        );

    if (destinos) {
        destinos.scrollIntoView({
            behavior:
                "smooth",

            block:
                "start"
        });
    }
}


/* ============================================================
   SOLICITAR COTIZACIÓN
============================================================ */

function manejarSolicitudCotizacion(
    event
) {
    event.preventDefault();

    const boton =
        event.currentTarget;

    const slug =
        boton.dataset.tripSlug;

    const viaje =
        buscarViajePorSlug(
            slug
        );

    if (!viaje) {
        console.warn(
            `[Supabase] No se encontró el viaje "${slug}".`
        );

        return;
    }

    window.viajeSeleccionadoParaCotizacion =
        viaje;

    console.log(
        "[Supabase] Solicitud de cotización iniciada:",
        {
            viaje:
                viaje.nombre,

            slug:
                viaje.slug,

            destino:
                viaje.destino_nombre
        }
    );

    const planifica =
        document.querySelector(
            "#planifica"
        );

    if (planifica) {
        planifica.scrollIntoView({
            behavior:
                "smooth",

            block:
                "start"
        });
    }
}


/* ============================================================
   BUSCAR VIAJE
============================================================ */

function buscarViajePorSlug(
    slug
) {
    if (!slug) {
        return null;
    }

    return (
        window.catalogoViajes?.find(
            (viaje) =>
                viaje.slug ===
                slug
        ) || null
    );
}


/* ============================================================
   DURACIÓN
============================================================ */

function construirDuracionViaje(
    viaje
) {
    const dias =
        viaje.duracion_dias;

    const noches =
        viaje.duracion_noches;

    if (
        dias &&
        noches !== null &&
        noches !== undefined
    ) {
        return `${dias} días / ${noches} noches`;
    }

    if (dias) {
        return `${dias} días`;
    }

    if (
        noches !== null &&
        noches !== undefined
    ) {
        return `${noches} noches`;
    }

    return "";
}


/* ============================================================
   FORMATO DE PRECIO
============================================================ */

function formatearPrecio(
    precio,
    moneda
) {
    if (
        precio === null ||
        precio === undefined ||
        precio === ""
    ) {
        return "";
    }

    const valor =
        Number(precio);

    if (
        Number.isNaN(valor)
    ) {
        return `${moneda || ""} ${precio}`.trim();
    }

    const codigoMoneda =
        moneda ||
        "USD";

    try {
        return new Intl.NumberFormat(
            "en-US",
            {
                style:
                    "currency",

                currency:
                    codigoMoneda,

                maximumFractionDigits:
                    0
            }
        ).format(valor);

    } catch (error) {
        return `${codigoMoneda} ${valor.toLocaleString(
            "en-US"
        )}`;
    }
}

/* ============================================================
   BUSCADOR
============================================================ */

function configurarBuscador() {
    const buscador =
        document.querySelector(
            "#buscador"
        );

    if (!buscador) {
        console.warn(
            "[Buscador] No se encontró #buscador."
        );

        return;
    }

    const boton =
        document.querySelector(
            "#searchTravelBtn"
        );

    if (!boton) {
        console.warn(
            "[Buscador] No se encontró #searchTravelBtn."
        );

        return;
    }

    if (
        boton.dataset.searchConfigured ===
        "true"
    ) {
        return;
    }

    boton.addEventListener(
        "click",
        manejarBusqueda
    );

    boton.dataset.searchConfigured =
        "true";

    console.log(
        "[Buscador] Buscador configurado correctamente."
    );
}


/* ============================================================
   EJECUTAR BÚSQUEDA
============================================================ */

function manejarBusqueda() {
    const destinoSelect =
        document.querySelector(
            "#destinationSelect"
        );

    const experienciaSelect =
        document.querySelector(
            "#experienceSelect"
        );

    const fechaInput =
        document.querySelector(
            "#travelDate"
        );

    const destinoSlug =
        destinoSelect?.value?.trim() ||
        "";

    const experienciaSlug =
        experienciaSelect?.value?.trim() ||
        "";

    const mes =
        fechaInput?.value?.trim() ||
        "";

    console.log(
        "[Buscador] Búsqueda solicitada:",
        {
            destino:
                destinoSlug,

            experiencia:
                experienciaSlug,

            mes
        }
    );

    const resultados =
        filtrarViajes({
            destinoSlug,
            experienciaSlug
        });

    mostrarResultadosBusqueda(
        resultados,
        {
            destinoSlug,
            experienciaSlug,
            mes
        }
    );
}


/* ============================================================
   FILTRAR VIAJES
============================================================ */

function filtrarViajes({
    destinoSlug = "",
    experienciaSlug = ""
}) {
    const viajes =
        window.catalogoViajes ||
        [];

    return viajes.filter(
        (viaje) => {

            const coincideDestino =
                !destinoSlug ||
                viaje.destino_slug ===
                    destinoSlug;

            const coincideExperiencia =
                !experienciaSlug ||
                viaje.experiencias?.some(
                    (
                        experiencia
                    ) =>
                        experiencia.slug ===
                        experienciaSlug
                );

            return (
                coincideDestino &&
                coincideExperiencia
            );
        }
    );
}


/* ============================================================
   MOSTRAR RESULTADOS
============================================================ */

function mostrarResultadosBusqueda(
    resultados,
    filtros
) {
    const detalle =
        crearContenedorDetalleDestino();

    const destino =
        window.catalogoDestinos?.find(
            (item) =>
                item.slug ===
                filtros.destinoSlug
        );

    const titulo =
        destino?.nombre ||
        "Resultados de búsqueda";

    const textoResultado =
        resultados.length ===
        1
            ? "Encontramos 1 opción para tu búsqueda."
            : `Encontramos ${resultados.length} opciones para tu búsqueda.`;

    detalle.innerHTML = `
        <div class="container">

            <div class="destination-detail-header">

                <span class="destination-detail-eyebrow">
                    RESULTADOS
                </span>

                <h2 class="destination-detail-title">
                    ${escaparHTML(
                        titulo
                    )}
                </h2>

                <p class="destination-detail-description">
                    ${escaparHTML(
                        textoResultado
                    )}
                </p>

            </div>

            <div class="destination-detail-section">

                <h3 class="destination-detail-section-title">
                    Viajes disponibles
                </h3>

                <div class="destination-trips">

                    ${
                        resultados.length
                            ? resultados
                                  .map(
                                      (
                                          viaje
                                      ) =>
                                          construirTarjetaViaje(
                                              viaje
                                          )
                                  )
                                  .join(
                                      ""
                                  )
                            : `
                                <div class="destination-detail-empty">

                                    No encontramos viajes
                                    con esos criterios.

                                    Prueba seleccionando otro
                                    destino o experiencia.

                                </div>
                            `
                    }

                </div>

            </div>

            <button
                type="button"
                class="destination-detail-close"
                data-action="close-destination-detail"
            >
                Cerrar resultados
            </button>

        </div>
    `;

    detalle.classList.remove(
        "is-hidden"
    );

    configurarAccionesDetalleDestino(
        detalle
    );

    requestAnimationFrame(
        () => {
            detalle.scrollIntoView({
                behavior:
                    "smooth",

                block:
                    "start"
            });
        }
    );
}


/* ============================================================
   ACTUALIZAR BUSCADOR
============================================================ */

function actualizarBuscadorDesdeCatalogo() {
    const destinos =
        window.catalogoDestinos ||
        [];

    const experiencias =
        window.catalogoExperiencias ||
        [];

    const destinoSelect =
        document.querySelector(
            "#destinationSelect"
        );

    const experienciaSelect =
        document.querySelector(
            "#experienceSelect"
        );

    /*
       Conservamos las opciones visuales
       existentes en el HTML.

       Solo actualizamos las opciones
       cuando encontramos equivalencias
       reales en Supabase.
    */

    if (destinoSelect) {
        sincronizarOpcionesSelect(
            destinoSelect,
            destinos
        );
    }

    if (experienciaSelect) {
        sincronizarOpcionesSelect(
            experienciaSelect,
            experiencias
        );
    }
}


/* ============================================================
   SINCRONIZAR SELECT
============================================================ */

function sincronizarOpcionesSelect(
    select,
    elementos
) {
    const valorActual =
        select.value;

    const opcionesExistentes =
        Array.from(
            select.options
        );

    const opcionInicial =
        opcionesExistentes[0];

    select.innerHTML = "";

    if (opcionInicial) {
        select.appendChild(
            opcionInicial
        );
    }

    elementos.forEach(
        (elemento) => {

            const option =
                document.createElement(
                    "option"
                );

            option.value =
                elemento.slug;

            option.textContent =
                elemento.nombre;

            select.appendChild(
                option
            );
        }
    );

    if (
        elementos.some(
            (elemento) =>
                elemento.slug ===
                valorActual
        )
    ) {
        select.value =
            valorActual;
    }
}


/* ============================================================
   ENLACES GENERALES
============================================================ */

function configurarEnlacesGenerales() {
    const enlaces =
        document.querySelectorAll(
            "a[data-trip-slug]"
        );

    enlaces.forEach(
        (enlace) => {

            if (
                enlace.dataset.tripConfigured ===
                "true"
            ) {
                return;
            }

            enlace.addEventListener(
                "click",
                manejarEnlaceViaje
            );

            enlace.dataset.tripConfigured =
                "true";
        }
    );
}


/* ============================================================
   MANEJAR ENLACE DE VIAJE
============================================================ */

function manejarEnlaceViaje(
    event
) {
    const enlace =
        event.currentTarget;

    const slug =
        enlace.dataset.tripSlug;

    if (!slug) {
        return;
    }

    const viaje =
        buscarViajePorSlug(
            slug
        );

    if (!viaje) {
        return;
    }

    event.preventDefault();

    const destino =
        window.catalogoDestinos?.find(
            (item) =>
                item.slug ===
                viaje.destino_slug
        );

    if (destino) {
        mostrarDetalleViaje(
            slug
        );
    }
}


/* ============================================================
   ERROR CATÁLOGO
============================================================ */

function mostrarErrorCatalogo(
    mensaje
) {
    console.error(
        `[Supabase] ${mensaje}`
    );

    const buscador =
        document.querySelector(
            "#buscador"
        );

    if (!buscador) {
        return;
    }

    buscador.dataset.catalogError =
        "true";
}


/* ============================================================
   ESCAPAR HTML
============================================================ */

function escaparHTML(
    valor
) {
    if (
        valor === null ||
        valor === undefined
    ) {
        return "";
    }

    return String(valor)
        .replace(
            /&/g,
            "&amp;"
        )
        .replace(
            /</g,
            "&lt;"
        )
        .replace(
            />/g,
            "&gt;"
        )
        .replace(
            /"/g,
            "&quot;"
        )
        .replace(
            /'/g,
            "&#039;"
        );
}


/* ============================================================
   ETIQUETAS VISUALES
============================================================ */

function obtenerEtiquetaDestino(
    slug
) {
    const etiquetas = {
        europa:
            "DESCUBRE",

        caribe:
            "RELÁJATE",

        asia:
            "AVENTÚRATE",

        "medio-oriente":
            "VIVE",

        africa:
            "DESCUBRE",

        america:
            "DESCUBRE"
    };

    return (
        etiquetas[slug] ||
        "DESCUBRE"
    );
}


/* ============================================================
   API PÚBLICA PARA DEBUG
============================================================ */

window.galeriaViajes = {
    buscarViajePorSlug,
    filtrarViajes,
    mostrarDetalleDestino,
    cerrarDetalleDestino,
    mostrarDetalleViaje,
    cargarDetalleViaje,
    construirDetalleViaje,
    formatearPrecio
};
