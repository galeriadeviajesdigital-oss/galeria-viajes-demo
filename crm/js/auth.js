// =========================================================
// CRM GALERÍA DE VIAJES
// Autenticación con Supabase
// =========================================================

import { createClient } from "@supabase/supabase-js";


// =========================================================
// CONFIGURACIÓN SUPABASE
// =========================================================

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabasePublishableKey =
    import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY;

if (!supabaseUrl || !supabasePublishableKey) {
    throw new Error(
        "No se encontraron las variables de entorno de Supabase."
    );
}

export const supabase = createClient(
    supabaseUrl,
    supabasePublishableKey
);


// =========================================================
// ELEMENTOS DEL LOGIN
// =========================================================

const loginForm = document.getElementById("loginForm");
const loginButton = document.getElementById("loginButton");
const loginError = document.getElementById("loginError");
const forgotPassword = document.getElementById("forgotPassword");


// =========================================================
// UTILIDADES
// =========================================================

function mostrarError(mensaje) {

    if (!loginError) {
        return;
    }

    loginError.textContent = mensaje;
    loginError.hidden = false;
}


function ocultarError() {

    if (!loginError) {
        return;
    }

    loginError.textContent = "";
    loginError.hidden = true;
}


function cambiarEstadoLogin(cargando) {

    if (!loginButton) {
        return;
    }

    loginButton.disabled = cargando;

    loginButton.textContent =
        cargando
            ? "Iniciando sesión..."
            : "Iniciar sesión";
}


// =========================================================
// LOGIN
// =========================================================

async function iniciarSesion(email, password) {

    ocultarError();
    cambiarEstadoLogin(true);

    try {

        const { data, error } =
            await supabase.auth.signInWithPassword({
                email,
                password
            });

        if (error) {
            throw error;
        }

        if (!data?.user) {
            throw new Error(
                "No fue posible obtener el usuario autenticado."
            );
        }

        // La identidad de Supabase Auth ya fue validada.
        // El registro CRM y su rol se validarán posteriormente
        // desde la aplicación principal.

        window.location.href = "./";

    } catch (error) {

        console.error(
            "Error de autenticación:",
            error
        );

        let mensaje =
            "No fue posible iniciar sesión.";

        if (
            error?.message?.toLowerCase()
                .includes("invalid login credentials")
        ) {
            mensaje =
                "El correo electrónico o la contraseña no son correctos.";
        }
        else if (
            error?.message?.toLowerCase()
                .includes("email not confirmed")
        ) {
            mensaje =
                "El correo electrónico todavía no ha sido confirmado.";
        }

        mostrarError(mensaje);

    } finally {

        cambiarEstadoLogin(false);
    }
}


// =========================================================
// EVENTO FORMULARIO
// =========================================================

if (loginForm) {

    loginForm.addEventListener(
        "submit",
        async (event) => {

            event.preventDefault();

            const formData =
                new FormData(loginForm);

            const email =
                String(
                    formData.get("email") || ""
                ).trim();

            const password =
                String(
                    formData.get("password") || ""
                );

            if (!email || !password) {

                mostrarError(
                    "Ingresa tu correo electrónico y contraseña."
                );

                return;
            }

            await iniciarSesion(
                email,
                password
            );
        }
    );
}


// =========================================================
// RECUPERACIÓN DE CONTRASEÑA
// =========================================================

if (forgotPassword) {

    forgotPassword.addEventListener(
        "click",
        async (event) => {

            event.preventDefault();

            ocultarError();

            const emailInput =
                document.getElementById("email");

            const email =
                String(
                    emailInput?.value || ""
                ).trim();

            if (!email) {

                mostrarError(
                    "Ingresa primero tu correo electrónico para recuperar la contraseña."
                );

                emailInput?.focus();

                return;
            }

            try {

                const { error } =
                    await supabase.auth.resetPasswordForEmail(
                        email,
                        {
                            redirectTo:
                                `${window.location.origin}/crm/`
                        }
                    );

                if (error) {
                    throw error;
                }

                mostrarError(
                    "Si el correo existe, recibirás instrucciones para restablecer tu contraseña."
                );

                if (loginError) {
                    loginError.classList.remove(
                        "crm-auth-message-error"
                    );
                }

            } catch (error) {

                console.error(
                    "Error recuperando contraseña:",
                    error
                );

                mostrarError(
                    "No fue posible iniciar el proceso de recuperación."
                );
            }
        }
    );
}