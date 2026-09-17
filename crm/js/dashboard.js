
import { supabase } from "./auth.js";
import { renderContactos } from "./contactos.js";
import { renderLeads } from "./leads.js";

// =========================================================
// CRM GALERÃA DE VIAJES
// Dashboard y estructura principal
// =========================================================


const DASHBOARD_HTML = `
<div class="crm-app">

    <!-- =================================================
         SIDEBAR
         ================================================= -->

    <aside class="crm-sidebar" id="crmSidebar">

        <div class="crm-sidebar-brand">

    <a
        href="#"
        class="crm-sidebar-logo-link"
        aria-label="GalerÃ­a de Viajes"
    >
        <img
    src="/assets/logo-B5DZdpEy.png"
    alt="GalerÃ­a de Viajes"
    class="crm-sidebar-logo-image"
>
    </a>

    <div class="crm-sidebar-brand-text">
        <span>CRM</span>
        <small>GalerÃ­a de Viajes</small>
    </div>

</div>


        <nav class="crm-sidebar-nav">

            <div class="crm-nav-section">
                <span class="crm-nav-title">
                    GENERAL
                </span>

                <button
                    class="crm-nav-item active"
                    data-module="dashboard"
                >
                    <span class="crm-nav-icon">âŒ‚</span>
                    <span>Dashboard</span>
                </button>
            </div>


            <div class="crm-nav-section">

                <span class="crm-nav-title">
                    CLIENTES
                </span>

                <button
                    class="crm-nav-item"
                    data-module="contactos"
                >
                    <span class="crm-nav-icon">â™™</span>
                    <span>Contactos</span>
                </button>

                <button
                    class="crm-nav-item"
                    data-module="leads"
                >
                    <span class="crm-nav-icon">â—Ž</span>
                    <span>Leads</span>
                </button>

                <button
                    class="crm-nav-item"
                    data-module="oportunidades"
                >
                    <span class="crm-nav-icon">â—‡</span>
                    <span>Oportunidades</span>
                </button>

            </div>


            <div class="crm-nav-section">

                <span class="crm-nav-title">
                    COMERCIAL
                </span>

                <button
                    class="crm-nav-item"
                    data-module="cotizaciones"
                >
                    <span class="crm-nav-icon">â–¤</span>
                    <span>Cotizaciones</span>
                </button>

                <button
                    class="crm-nav-item"
                    data-module="seguimientos"
                >
                    <span class="crm-nav-icon">â—·</span>
                    <span>Seguimientos</span>
                </button>

                <button
                    class="crm-nav-item"
                    data-module="ventas"
                >
                    <span class="crm-nav-icon">â–£</span>
                    <span>Ventas</span>
                </button>

            </div>


            <div class="crm-nav-section">

                <span class="crm-nav-title">
                    OPERACIÃ“N
                </span>

                <button
                    class="crm-nav-item"
                    data-module="viajes"
                >
                    <span class="crm-nav-icon">âœˆ</span>
                    <span>Viajes</span>
                </button>

                <button
                    class="crm-nav-item"
                    data-module="campanas"
                >
                    <span class="crm-nav-icon">â—‡</span>
                    <span>CampaÃ±as</span>
                </button>

            </div>


            <div class="crm-nav-section">

                <span class="crm-nav-title">
                    ANÃLISIS
                </span>

                <button
                    class="crm-nav-item"
                    data-module="reportes"
                >
                    <span class="crm-nav-icon">â–¥</span>
                    <span>Reportes</span>
                </button>

            </div>

        </nav>


        <div class="crm-sidebar-footer">

            <button
                class="crm-nav-item"
                data-module="configuracion"
            >
                <span class="crm-nav-icon">âš™</span>
                <span>ConfiguraciÃ³n</span>
            </button>

        </div>

    </aside>


    <!-- =================================================
         CONTENIDO PRINCIPAL
         ================================================= -->

    <div class="crm-main">

        <!-- TOPBAR -->

        <header class="crm-topbar">

            <div class="crm-topbar-left">

                <button
                    id="crmMenuToggle"
                    class="crm-menu-toggle"
                    aria-label="Abrir menÃº"
                >
                    â˜°
                </button>

                <div>
                    <span class="crm-topbar-section">
                        CRM
                    </span>

                    <h1 id="crmPageTitle">
                        Dashboard
                    </h1>
                </div>

            </div>


            <div class="crm-topbar-right">

                <button
                    class="crm-notification-button"
                    aria-label="Notificaciones"
                >
                    â™¢
                    <span class="crm-notification-dot"></span>
                </button>


                <div class="crm-user">

                    <div
                        class="crm-user-avatar"
                        id="crmUserAvatar"
                    >
                        GV
                    </div>

                    <div class="crm-user-info">

                        <strong id="crmUserName">
                            Usuario
                        </strong>

                        <span id="crmUserRole">
                            CRM
                        </span>

                    </div>

                    <button
                        id="crmUserMenu"
                        class="crm-user-menu"
                        aria-label="MenÃº de usuario"
                    >
                        â–¾
                    </button>

                </div>

            </div>

        </header>


        <!-- CONTENIDO -->

        <main
            class="crm-content"
            id="crmContent"
        >

            <!-- DASHBOARD -->

            <section
                class="crm-module"
                data-content="dashboard"
            >

                <div class="crm-page-header">

                    <div>
                        <span class="crm-page-eyebrow">
                            RESUMEN
                        </span>

                        <h2>
                            Panel de control
                        </h2>

                        <p>
                            Consulta la actividad comercial
                            y operativa de GalerÃ­a de Viajes.
                        </p>
                    </div>

                </div>


                <!-- MÃ‰TRICAS -->

                <div class="crm-stats-grid">

                    <article class="crm-stat-card">

                        <div class="crm-stat-header">
                            <span>Leads</span>
                            <span class="crm-stat-icon">â—Ž</span>
                        </div>

                        <strong id="statLeads">
                            â€”
                        </strong>

                        <small>
                            Leads registrados
                        </small>

                    </article>


                    <article class="crm-stat-card">

                        <div class="crm-stat-header">
                            <span>Oportunidades</span>
                            <span class="crm-stat-icon">â—‡</span>
                        </div>

                        <strong id="statOportunidades">
                            â€”
                        </strong>

                        <small>
                            Oportunidades activas
                        </small>

                    </article>


                    <article class="crm-stat-card">

                        <div class="crm-stat-header">
                            <span>Cotizaciones</span>
                            <span class="crm-stat-icon">â–¤</span>
                        </div>

                        <strong id="statCotizaciones">
                            â€”
                        </strong>

                        <small>
                            Cotizaciones registradas
                        </small>

                    </article>


                    <article class="crm-stat-card">

                        <div class="crm-stat-header">
                            <span>Ventas</span>
                            <span class="crm-stat-icon">â–£</span>
                        </div>

                        <strong id="statVentas">
                            â€”
                        </strong>

                        <small>
                            Ventas registradas
                        </small>

                    </article>

                </div>


                <!-- CUERPO DASHBOARD -->

                <div class="crm-dashboard-grid">

                    <section class="crm-panel crm-panel-large">

                        <div class="crm-panel-header">

                            <div>
                                <span class="crm-panel-eyebrow">
                                    COMERCIAL
                                </span>

                                <h3>
                                    Pipeline de oportunidades
                                </h3>
                            </div>

                            <button
                                class="crm-panel-action"
                                data-module="oportunidades"
                            >
                                Ver oportunidades
                            </button>

                        </div>


                        <div
                            id="crmPipeline"
                            class="crm-pipeline"
                        >

                            <div class="crm-pipeline-stage">

                                <span>
                                    Nuevas
                                </span>

                                <strong>
                                    â€”
                                </strong>

                            </div>


                            <div class="crm-pipeline-stage">

                                <span>
                                    En proceso
                                </span>

                                <strong>
                                    â€”
                                </strong>

                            </div>


                            <div class="crm-pipeline-stage">

                                <span>
                                    CotizaciÃ³n
                                </span>

                                <strong>
                                    â€”
                                </strong>

                            </div>


                            <div class="crm-pipeline-stage">

                                <span>
                                    Cerradas
                                </span>

                                <strong>
                                    â€”
                                </strong>

                            </div>

                        </div>

                    </section>


                    <section class="crm-panel">

                        <div class="crm-panel-header">

                            <div>
                                <span class="crm-panel-eyebrow">
                                    ACTIVIDAD
                                </span>

                                <h3>
                                    PrÃ³ximos seguimientos
                                </h3>
                            </div>

                        </div>


                        <div
                            id="crmFollowups"
                            class="crm-empty-state"
                        >

                            <div class="crm-empty-icon">
                                â—·
                            </div>

                            <strong>
                                Sin seguimientos cargados
                            </strong>

                            <p>
                                AquÃ­ aparecerÃ¡n las prÃ³ximas
                                actividades comerciales.
                            </p>

                        </div>

                    </section>

                </div>


                <!-- ACTIVIDAD RECIENTE -->

                <section class="crm-panel crm-recent-panel">

                    <div class="crm-panel-header">

                        <div>
                            <span class="crm-panel-eyebrow">
                                ACTIVIDAD RECIENTE
                            </span>

                            <h3>
                                Ãšltimos movimientos
                            </h3>
                        </div>

                    </div>


                    <div
                        id="crmRecentActivity"
                        class="crm-empty-state"
                    >

                        <div class="crm-empty-icon">
                            â—·
                        </div>

                        <strong>
                            No hay actividad reciente
                        </strong>

                        <p>
                            Las actividades del CRM aparecerÃ¡n
                            en esta secciÃ³n.
                        </p>

                    </div>

                </section>

            </section>


            <!-- MÃ“DULOS FUTUROS -->

            <section
                class="crm-module crm-module-placeholder"
                data-content="contactos"
                hidden
            >
                <span class="crm-page-eyebrow">
                    CLIENTES
                </span>

                <h2>
                    Contactos
                </h2>

                <p>
                    MÃ³dulo de contactos.
                </p>
            </section>


            <section
                class="crm-module crm-module-placeholder"
                data-content="leads"
                hidden
            >
                <span class="crm-page-eyebrow">
                    CLIENTES
                </span>

                <h2>
                    Leads
                </h2>

                <p>
                    MÃ³dulo de leads.
                </p>
            </section>


            <section
                class="crm-module crm-module-placeholder"
                data-content="oportunidades"
                hidden
            >
                <span class="crm-page-eyebrow">
                    COMERCIAL
                </span>

                <h2>
                    Oportunidades
                </h2>

                <p>
                    MÃ³dulo de oportunidades.
                </p>
            </section>


            <section
                class="crm-module crm-module-placeholder"
                data-content="cotizaciones"
                hidden
            >
                <span class="crm-page-eyebrow">
                    COMERCIAL
                </span>

                <h2>
                    Cotizaciones
                </h2>

                <p>
                    MÃ³dulo de cotizaciones.
                </p>
            </section>


            <section
                class="crm-module crm-module-placeholder"
                data-content="seguimientos"
                hidden
            >
                <span class="crm-page-eyebrow">
                    COMERCIAL
                </span>

                <h2>
                    Seguimientos
                </h2>

                <p>
                    MÃ³dulo de seguimientos.
                </p>
            </section>


            <section
                class="crm-module crm-module-placeholder"
                data-content="ventas"
                hidden
            >
                <span class="crm-page-eyebrow">
                    COMERCIAL
                </span>

                <h2>
                    Ventas
                </h2>

                <p>
                    MÃ³dulo de ventas.
                </p>
            </section>


            <section
                class="crm-module crm-module-placeholder"
                data-content="viajes"
                hidden
            >
                <span class="crm-page-eyebrow">
                    OPERACIÃ“N
                </span>

                <h2>
                    Viajes
                </h2>

                <p>
                    MÃ³dulo de viajes.
                </p>
            </section>


            <section
                class="crm-module crm-module-placeholder"
                data-content="campanas"
                hidden
            >
                <span class="crm-page-eyebrow">
                    OPERACIÃ“N
                </span>

                <h2>
                    CampaÃ±as
                </h2>

                <p>
                    MÃ³dulo de campaÃ±as.
                </p>
            </section>


            <section
                class="crm-module crm-module-placeholder"
                data-content="reportes"
                hidden
            >
                <span class="crm-page-eyebrow">
                    ANÃLISIS
                </span>

                <h2>
                    Reportes
                </h2>

                <p>
                    MÃ³dulo de reportes.
                </p>
            </section>


            <section
                class="crm-module crm-module-placeholder"
                data-content="configuracion"
                hidden
            >
                <span class="crm-page-eyebrow">
                    SISTEMA
                </span>

                <h2>
                    ConfiguraciÃ³n
                </h2>

                <p>
                    ConfiguraciÃ³n del CRM.
                </p>
            </section>

        </main>

    </div>

</div>
`;


// =========================================================
// RENDER DASHBOARD
// =========================================================

export function renderDashboard() {

    document.body.innerHTML =
        DASHBOARD_HTML;

    configurarNavegacion();
    configurarMenuMovil();
    configurarUsuario();

    cargarInformacionUsuario();

    cargarMetricas();
}


// =========================================================
// NAVEGACIÃ“N
// =========================================================

function configurarNavegacion() {

    const navItems =
        document.querySelectorAll(
            ".crm-nav-item[data-module]"
        );

    navItems.forEach((item) => {

        item.addEventListener(
            "click",
            () => {

                const module =
                    item.dataset.module;

                mostrarModulo(module);
            }
        );

    });


    const panelActions =
        document.querySelectorAll(
            "[data-module].crm-panel-action"
        );

    panelActions.forEach((button) => {

        button.addEventListener(
            "click",
            () => {

                mostrarModulo(
                    button.dataset.module
                );
            }
        );

    });
}


// =========================================================
// MOSTRAR MÃ“DULO
// =========================================================

function mostrarModulo(module) {

    // ========================================================
    // NAVEGACIÃ“N ACTIVA Y TÃTULO
    // ========================================================

    const navItems =
        document.querySelectorAll(
            ".crm-nav-item[data-module]"
        );

    navItems.forEach(
        item => {

            item.classList.toggle(
                "active",
                item.dataset.module ===
                module
            );

        }
    );

    const pageTitle =
        document.getElementById(
            "crmPageTitle"
        );

    if (pageTitle) {

        pageTitle.textContent =
            obtenerNombreModulo(
                module
            );

    }


    // ========================================================
    // DASHBOARD
    // ========================================================

    if (module === "dashboard") {

        renderDashboard();

        return;
    }


    // ========================================================
    // CONTACTOS
    // ========================================================

    if (module === "contactos") {

        renderContactos();

        return;
    }


    // ========================================================
    // LEADS
    // ========================================================

    if (module === "leads") {

        renderLeads();

        return;
    }


    // ========================================================
    // MÃ“DULOS QUE TODAVÃA SON PLACEHOLDER
    // ========================================================

    const modules =
        document.querySelectorAll(
            ".crm-module"
        );


    modules.forEach(
        section => {

            section.hidden =
                section.dataset.content !==
                module;

        }
    );


    // ========================================================
    // MOBILE
    // ========================================================

    document
        .getElementById("crmSidebar")
        ?.classList.remove(
            "mobile-open"
        );

}

// =========================================================
// NOMBRE DEL MÃ“DULO
// =========================================================

function obtenerNombreModulo(module) {

    const nombres = {

        dashboard: "Dashboard",
        contactos: "Contactos",
        leads: "Leads",
        oportunidades: "Oportunidades",
        cotizaciones: "Cotizaciones",
        seguimientos: "Seguimientos",
        ventas: "Ventas",
        viajes: "Viajes",
        campanas: "CampaÃ±as",
        reportes: "Reportes",
        configuracion: "ConfiguraciÃ³n"

    };

    return nombres[module] || "CRM";
}


// =========================================================
// MENÃš MÃ“VIL
// =========================================================

function configurarMenuMovil() {

    const button =
        document.getElementById(
            "crmMenuToggle"
        );

    const sidebar =
        document.getElementById(
            "crmSidebar"
        );

    if (!button || !sidebar) {
        return;
    }

    button.addEventListener(
        "click",
        () => {

            sidebar.classList.toggle(
                "mobile-open"
            );

        }
    );
}

// =========================================================
// CONFIGURACIÃ“N DEL USUARIO
// =========================================================

function configurarUsuario() {

    const userMenu =
        document.getElementById("crmUserMenu");

    if (!userMenu) {
        return;
    }

    userMenu.addEventListener(
        "click",
        async () => {

            const { error } =
                await supabase.auth.signOut();

            if (error) {
                console.error(
                    "Error cerrando sesiÃ³n:",
                    error
                );
            }
        }
    );
}

// =========================================================
// INFORMACIÃ“N DEL USUARIO
// =========================================================

function cargarInformacionUsuario() {

    const nombre =
        document.getElementById("crmUserName");

    const rol =
        document.getElementById("crmUserRole");

    const avatar =
        document.getElementById("crmUserAvatar");

    const user =
        window.crm?.usuario;

    const perfil =
        window.crm?.perfil;

    if (nombre) {
        nombre.textContent =
            user?.email ||
            "Usuario";
    }

    if (rol) {
        rol.textContent =
            perfil?.rol ||
            "CRM";
    }

    if (avatar) {

        const texto =
            user?.email
                ? user.email
                    .split("@")[0]
                    .slice(0, 2)
                    .toUpperCase()
                : "GV";

        avatar.textContent =
            texto;
    }
}

// =========================================================
// MÃ‰TRICAS DEL DASHBOARD
// =========================================================

async function cargarMetricas() {

    const consultas = [
        ["statLeads", "leads"],
        ["statOportunidades", "oportunidades"],
        ["statCotizaciones", "cotizaciones"],
        ["statVentas", "ventas"]
    ];

    for (const [elementId, table] of consultas) {

        const elemento =
            document.getElementById(elementId);

        if (!elemento) {
            continue;
        }

        const { count, error } =
            await supabase
                .from(table)
                .select("*", {
                    count: "exact",
                    head: true
                });

        if (error) {

            console.error(
                `Error cargando mÃ©trica ${table}:`,
                error
            );

            elemento.textContent = "â€”";
            continue;
        }

        elemento.textContent =
            count ?? 0;
    }
}

