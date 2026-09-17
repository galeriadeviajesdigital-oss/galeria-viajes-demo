-- ============================================================
-- GALERÍA DE VIAJES CRM
-- Migración: Identidad y roles del CRM
-- Fecha: 2026-09-17
--
-- Objetivo:
--   Vincular usuarios autenticados de Supabase con el CRM
--   y establecer su rol y vendedor asociado.
--
-- IMPORTANTE:
--   Esta migración NO modifica las tablas comerciales existentes.
-- ============================================================


-- ============================================================
-- 1. TABLA DE USUARIOS DEL CRM
-- ============================================================

CREATE TABLE IF NOT EXISTS public.crm_usuarios (
    id UUID PRIMARY KEY
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    vendedor_id UUID NULL
        REFERENCES public.vendedores(id)
        ON DELETE SET NULL,

    rol VARCHAR(30) NOT NULL DEFAULT 'ASESOR',

    activo BOOLEAN NOT NULL DEFAULT true,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT crm_usuarios_rol_check
        CHECK (
            rol IN (
                'ADMIN',
                'SUPERVISOR',
                'ASESOR',
                'OPERACIONES',
                'CONTABILIDAD'
            )
        )
);


-- ============================================================
-- 2. ÍNDICES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_crm_usuarios_vendedor_id
    ON public.crm_usuarios(vendedor_id);

CREATE INDEX IF NOT EXISTS idx_crm_usuarios_rol
    ON public.crm_usuarios(rol);

CREATE INDEX IF NOT EXISTS idx_crm_usuarios_activo
    ON public.crm_usuarios(activo);


-- ============================================================
-- 3. TRIGGER updated_at
-- ============================================================

DROP TRIGGER IF EXISTS trg_crm_usuarios_updated_at
    ON public.crm_usuarios;

CREATE TRIGGER trg_crm_usuarios_updated_at
BEFORE UPDATE ON public.crm_usuarios
FOR EACH ROW
EXECUTE FUNCTION public.actualizar_fecha_modificacion();


-- ============================================================
-- 4. RLS
-- ============================================================

ALTER TABLE public.crm_usuarios ENABLE ROW LEVEL SECURITY;


-- ============================================================
-- 5. FUNCIÓN: OBTENER USUARIO CRM ACTUAL
-- ============================================================

CREATE OR REPLACE FUNCTION public.crm_usuario_actual()
RETURNS public.crm_usuarios
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT cu.*
    FROM public.crm_usuarios cu
    WHERE cu.id = auth.uid()
      AND cu.activo = true
    LIMIT 1;
$$;


-- ============================================================
-- 6. FUNCIÓN: COMPROBAR ROL DEL USUARIO ACTUAL
-- ============================================================

CREATE OR REPLACE FUNCTION public.crm_tiene_rol(
    p_rol VARCHAR
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.crm_usuarios cu
        WHERE cu.id = auth.uid()
          AND cu.activo = true
          AND cu.rol = p_rol
    );
$$;


-- ============================================================
-- 7. FUNCIÓN: COMPROBAR SI ES ADMIN
-- ============================================================

CREATE OR REPLACE FUNCTION public.crm_es_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.crm_usuarios cu
        WHERE cu.id = auth.uid()
          AND cu.activo = true
          AND cu.rol = 'ADMIN'
    );
$$;


-- ============================================================
-- 8. POLÍTICA DE LECTURA
-- ============================================================

DROP POLICY IF EXISTS crm_usuarios_select_propio
    ON public.crm_usuarios;

CREATE POLICY crm_usuarios_select_propio
ON public.crm_usuarios
FOR SELECT
TO authenticated
USING (
    id = auth.uid()
);


-- ============================================================
-- 9. POLÍTICA ADMINISTRADORES
-- ============================================================

DROP POLICY IF EXISTS crm_usuarios_admin_select
    ON public.crm_usuarios;

CREATE POLICY crm_usuarios_admin_select
ON public.crm_usuarios
FOR SELECT
TO authenticated
USING (
    public.crm_es_admin()
);


-- ============================================================
-- 10. PERMISOS API
-- ============================================================

-- Evitar acceso accidental por permisos heredados
REVOKE ALL
ON TABLE public.crm_usuarios
FROM anon, authenticated;

REVOKE ALL
ON FUNCTION public.crm_usuario_actual()
FROM PUBLIC;

REVOKE ALL
ON FUNCTION public.crm_tiene_rol(VARCHAR)
FROM PUBLIC;

REVOKE ALL
ON FUNCTION public.crm_es_admin()
FROM PUBLIC;

-- Permisos mínimos necesarios
GRANT SELECT
ON TABLE public.crm_usuarios
TO authenticated;

GRANT EXECUTE
ON FUNCTION public.crm_usuario_actual()
TO authenticated;

GRANT EXECUTE
ON FUNCTION public.crm_tiene_rol(VARCHAR)
TO authenticated;

GRANT EXECUTE
ON FUNCTION public.crm_es_admin()
TO authenticated;


-- ============================================================
-- 11. COMENTARIOS
-- ============================================================

COMMENT ON TABLE public.crm_usuarios IS
'Usuarios internos autorizados para acceder al CRM de Galería de Viajes.';

COMMENT ON COLUMN public.crm_usuarios.id IS
'UUID del usuario correspondiente a auth.users.id.';

COMMENT ON COLUMN public.crm_usuarios.vendedor_id IS
'Vendedor comercial asociado al usuario, cuando corresponda.';

COMMENT ON COLUMN public.crm_usuarios.rol IS
'Rol de seguridad dentro del CRM.';

COMMENT ON COLUMN public.crm_usuarios.activo IS
'Indica si el usuario puede operar dentro del CRM.';
