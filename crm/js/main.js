// =========================================================
// CRM GALERÍA DE VIAJES
// Control principal de la aplicación
// =========================================================

import { supabase } from "./auth.js";
import { renderDashboard } from "./dashboard.js";


// =========================================================
// EXPONER SUPABASE AL CRM
// =========================================================

window.crmSupabase = supabase;


// =========================================================
// ESTADO GLOBAL DEL CRM
// =========================================================

window.crm = {
    usuario: null,
    perfil: null,
    rol: null
};


// =========================================================
// ELEMENTOS
// =========================================================

const loginForm =
    document.getElementById("loginForm");


// =========================================================
// OBTENER PERFIL CRM
// =========================================================

async function obtenerPerfilCRM(userId) {

    const { data, error } = await supabase
        .from("crm_usuarios")
        .select(`
            id,
            vendedor_id,
            rol,
            activo,
            created_at,
            updated_at
        `)
        .eq("id", userId)
        .maybeSingle();

    if (error) {

        console.error(
            "Error consultando perfil CRM:",
            error
        );

        throw new Error(
            "No fue posible verificar el perfil del usuario."
        );
    }

    return data;
}


// =========================================================
// VALIDAR ACCESO CRM
// =========================================================

async function validarAccesoCRM(user) {

    if (!user) {
        return false;
    }

    const perfil =
        await obtenerPerfilCRM(user.id);

    // -----------------------------------------------------
    // El usuario existe en Auth pero no en crm_usuarios
    // -----------------------------------------------------

    if (!perfil) {

        console.error(
            "El usuario autenticado no tiene un perfil CRM."
        );

        await supabase.auth.signOut();

        mostrarErrorAcceso(
            "Tu cuenta no tiene acceso al CRM."
        );

        return false;
    }


    // -----------------------------------------------------
    // Usuario CRM inactivo
    // -----------------------------------------------------

    if (!perfil.activo) {

        console.error(
            "El usuario CRM está inactivo."
        );

        await supabase.auth.signOut();

        mostrarErrorAcceso(
            "Tu cuenta CRM está inactiva. Contacta al administrador."
        );

        return false;
    }


    // -----------------------------------------------------
    // Guardar información de sesión
    // -----------------------------------------------------

    window.crm.usuario = user;
    window.crm.perfil = perfil;
    window.crm.rol = perfil.rol;


    console.log(
        "Usuario CRM validado:",
        {
            email: user.email,
            rol: perfil.rol,
            activo: perfil.activo
        }
    );


    return true;
}


// =========================================================
// MENSAJE DE ACCESO
// =========================================================

function mostrarErrorAcceso(mensaje) {

    const loginError =
        document.getElementById("loginError");

    if (!loginError) {
        return;
    }

    loginError.textContent =
        mensaje;

    loginError.hidden =
        false;

    loginError.classList.add(
        "crm-auth-message-error"
    );
}


// =========================================================
// IR AL DASHBOARD
// =========================================================

function abrirDashboard() {

    console.log(
        "Abriendo dashboard CRM..."
    );

    renderDashboard();
}


// =========================================================
// SESIÓN ACTUAL
// =========================================================

async function verificarSesion() {

    try {

        const {
            data: {
                session
            }
        } = await supabase.auth.getSession();


        // -------------------------------------------------
        // No existe sesión
        // -------------------------------------------------

        if (!session?.user) {

            console.log(
                "No existe una sesión CRM activa."
            );

            return;
        }


        // -------------------------------------------------
        // Validar usuario CRM
        // -------------------------------------------------

        const acceso =
            await validarAccesoCRM(
                session.user
            );


        if (!acceso) {
            return;
        }


        // -------------------------------------------------
        // Usuario válido → Dashboard
        // -------------------------------------------------

        abrirDashboard();

    }
    catch (error) {

        console.error(
            "Error verificando sesión CRM:",
            error
        );

        mostrarErrorAcceso(
            "No fue posible verificar tu acceso al CRM."
        );
    }
}


// =========================================================
// CAMBIOS DE SESIÓN
// =========================================================

supabase.auth.onAuthStateChange(
    async (event, session) => {

        console.log(
            "Cambio de autenticación:",
            event
        );


        // -------------------------------------------------
        // Cerrar sesión
        // -------------------------------------------------

        if (event === "SIGNED_OUT") {

            window.crm.usuario = null;
            window.crm.perfil = null;
            window.crm.rol = null;

            return;
        }


        // -------------------------------------------------
        // Login
        // -------------------------------------------------

        if (
            event === "SIGNED_IN" &&
            session?.user
        ) {

            try {

                const acceso =
                    await validarAccesoCRM(
                        session.user
                    );


                if (!acceso) {
                    return;
                }


                abrirDashboard();

            }
            catch (error) {

                console.error(
                    "Error validando sesión:",
                    error
                );

                mostrarErrorAcceso(
                    "No fue posible verificar tu acceso al CRM."
                );
            }
        }
    }
);


// =========================================================
// INICIALIZACIÓN
// =========================================================

async function inicializarCRM() {

    console.log(
        "Inicializando CRM Galería de Viajes..."
    );

    await verificarSesion();

    console.log(
        "CRM inicializado."
    );
}


// =========================================================
// INICIAR
// =========================================================

if (loginForm) {

    inicializarCRM();

}