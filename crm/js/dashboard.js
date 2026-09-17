
import { supabase } from "./auth.js";
import { renderContactos } from "./contactos.js";
import { renderLeads } from "./leads.js";

// =========================================================
// CRM GALERÍA DE VIAJES
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
        aria-label="Galería de Viajes"
    >
        <img
    src="../assets/images/sitio-actual/logotop.png"
    alt="Galería de Viajes"
    class="crm-sidebar-logo-image"
>
    </a>

    <div class="crm-sidebar-brand-text">
        <span>CRM</span>
        <small>Galería de Viajes</small>
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
                    <span class="crm-nav-icon">⌂</span>
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
                    <span class="crm-nav-icon">♙</span>
                    <span>Contactos</span>
                </button>

                <button
                    class="crm-nav-item"
                    data-module="leads"
                >
                    <span class="crm-nav-icon">◎</span>
                    <span>Leads</span>
                </button>

                <button
                    class="crm-nav-item"
                    data-module="oportunidades"
                >
                    <span class="crm-nav-icon">◇</span>
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
                    <span class="crm-nav-icon">▤</span>
                    <span>Cotizaciones</span>
                </button>

                <button
                    class="crm-nav-item"
                    data-module="seguimientos"
                >
                    <span class="crm-nav-icon">◷</span>
                    <span>Seguimientos</span>
                </button>

                <button
                    class="crm-nav-item"
                    data-module="ventas"
                >
                    <span class="crm-nav-icon">▣</span>
                    <span>Ventas</span>
                </button>

            </div>


            <div class="crm-nav-section">

                <span class="crm-nav-title">
                    OPERACIÓN
                </span>

                <button
                    class="crm-nav-item"
                    data-module="viajes"
                >
                    <span class="crm-nav-icon">✈</span>
                    <span>Viajes</span>
                </button>

                <button
                    class="crm-nav-item"
                    data-module="campanas"
                >
                    <span class="crm-nav-icon">◇</span>
                    <span>Campañas</span>
                </button>

            </div>


            <div class="crm-nav-section">

                <span class="crm-nav-title">
                    ANÁLISIS
                </span>

                <button
                    class="crm-nav-item"
                    data-module="reportes"
                >
                    <span class="crm-nav-icon">▥</span>
                    <span>Reportes</span>
                </button>

            </div>

        </nav>


        <div class="crm-sidebar-footer">

            <button
                class="crm-nav-item"
                data-module="configuracion"
            >
                <span class="crm-nav-icon">⚙</span>
                <span>Configuración</span>
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
                    aria-label="Abrir menú"
                >
                    ☰
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
                    ♢
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
                        aria-label="Menú de usuario"
                    >
                        ▾
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
                            y operativa de Galería de Viajes.
                        </p>
                    </div>

                </div>


                <!-- MÉTRICAS -->

                <div class="crm-stats-grid">

                    <article class="crm-stat-card">

                        <div class="crm-stat-header">
                            <span>Leads</span>
                            <span class="crm-stat-icon">◎</span>
                        </div>

                        <strong id="statLeads">
                            —
                        </strong>

                        <small>
                            Leads registrados
                        </small>

                    </article>


                    <article class="crm-stat-card">

                        <div class="crm-stat-header">
                            <span>Oportunidades</span>
                            <span class="crm-stat-icon">◇</span>
                        </div>

                        <strong id="statOportunidades">
                            —
                        </strong>

                        <small>
                            Oportunidades activas
                        </small>

                    </article>


                    <article class="crm-stat-card">

                        <div class="crm-stat-header">
                            <span>Cotizaciones</span>
                            <span class="crm-stat-icon">▤</span>
                        </div>

                        <strong id="statCotizaciones">
                            —
                        </strong>

                        <small>
                            Cotizaciones registradas
                        </small>

                    </article>


                    <article class="crm-stat-card">

                        <div class="crm-stat-header">
                            <span>Ventas</span>
                            <span class="crm-stat-icon">▣</span>
                        </div>

                        <strong id="statVentas">
                            —
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
                                    —
                                </strong>

                            </div>


                            <div class="crm-pipeline-stage">

                                <span>
                                    En proceso
                                </span>

                                <strong>
                                    —
                                </strong>

                            </div>


                            <div class="crm-pipeline-stage">

                                <span>
                                    Cotización
                                </span>

                                <strong>
                                    —
                                </strong>

                            </div>


                            <div class="crm-pipeline-stage">

                                <span>
                                    Cerradas
                                </span>

                                <strong>
                                    —
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
                                    Próximos seguimientos
                                </h3>
                            </div>

                        </div>


                        <div
                            id="crmFollowups"
                            class="crm-empty-state"
                        >

                            <div class="crm-empty-icon">
                                ◷
                            </div>

                            <strong>
                                Sin seguimientos cargados
                            </strong>

                            <p>
                                Aquí aparecerán las próximas
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
                                Últimos movimientos
                            </h3>
                        </div>

                    </div>


                    <div
                        id="crmRecentActivity"
                        class="crm-empty-state"
                    >

                        <div class="crm-empty-icon">
                            ◷
                        </div>

                        <strong>
                            No hay actividad reciente
                        </strong>

                        <p>
                            Las actividades del CRM aparecerán
                            en esta sección.
                        </p>

                    </div>

                </section>

            </section>


            <!-- MÓDULOS FUTUROS -->

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
                    Módulo de contactos.
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
                    Módulo de leads.
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
                    Módulo de oportunidades.
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
                    Módulo de cotizaciones.
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
                    Módulo de seguimientos.
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
                    Módulo de ventas.
                </p>
            </section>


            <section
                class="crm-module crm-module-placeholder"
                data-content="viajes"
                hidden
            >
                <span class="crm-page-eyebrow">
                    OPERACIÓN
                </span>

                <h2>
                    Viajes
                </h2>

                <p>
                    Módulo de viajes.
                </p>
            </section>


            <section
                class="crm-module crm-module-placeholder"
                data-content="campanas"
                hidden
            >
                <span class="crm-page-eyebrow">
                    OPERACIÓN
                </span>

                <h2>
                    Campañas
                </h2>

                <p>
                    Módulo de campañas.
                </p>
            </section>


            <section
                class="crm-module crm-module-placeholder"
                data-content="reportes"
                hidden
            >
                <span class="crm-page-eyebrow">
                    ANÁLISIS
                </span>

                <h2>
                    Reportes
                </h2>

                <p>
                    Módulo de reportes.
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
                    Configuración
                </h2>

                <p>
                    Configuración del CRM.
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
// NAVEGACIÓN
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
// MOSTRAR MÓDULO
// =========================================================

function mostrarModulo(module) {

    // ========================================================
    // NAVEGACIÓN ACTIVA Y TÍTULO
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
    // MÓDULOS QUE TODAVÍA SON PLACEHOLDER
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
// NOMBRE DEL MÓDULO
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
        campanas: "Campañas",
        reportes: "Reportes",
        configuracion: "Configuración"

    };

    return nombres[module] || "CRM";
}


// =========================================================
// MENÚ MÓVIL
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
// CONFIGURACIÓN DEL USUARIO
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
                    "Error cerrando sesión:",
                    error
                );
            }
        }
    );
}

// =========================================================
// INFORMACIÓN DEL USUARIO
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
// MÉTRICAS DEL DASHBOARD
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
                `Error cargando métrica ${table}:`,
                error
            );

            elemento.textContent = "—";
            continue;
        }

        elemento.textContent =
            count ?? 0;
    }
}
