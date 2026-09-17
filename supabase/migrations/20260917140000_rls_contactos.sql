-- ============================================================
-- GALERÍA DE VIAJES CRM
-- Migración: RLS de Contactos
-- Fecha: 2026-09-17
--
-- Objetivo:
--   Proteger los contactos del CRM según el rol del usuario.
--
-- Reglas iniciales:
--   ADMIN  -> todos los contactos
--   ASESOR -> contactos que tengan al menos un lead propio
--
-- La propiedad del contacto se determina mediante leads.
-- ============================================================


-- ============================================================
-- 1. FUNCIÓN: COMPROBAR ACCESO DEL ASESOR AL CONTACTO
-- ============================================================

CREATE OR REPLACE FUNCTION public.crm_puede_ver_contacto(
    p_contacto_id UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.leads l
        JOIN public.crm_usuarios cu
            ON cu.vendedor_id = l.vendedor_id
        JOIN public.vendedores v
            ON v.id = l.vendedor_id
        WHERE l.contacto_id = p_contacto_id
          AND cu.id = auth.uid()
          AND cu.activo = true
          AND cu.rol = 'ASESOR'
          AND v.activo = true
    );
$$;


-- ============================================================
-- 2. HABILITAR RLS
-- ============================================================

ALTER TABLE public.contactos ENABLE ROW LEVEL SECURITY;


-- ============================================================
-- 3. POLÍTICA ADMIN - SELECT
-- ============================================================

DROP POLICY IF EXISTS contactos_admin_select
    ON public.contactos;

CREATE POLICY contactos_admin_select
ON public.contactos
FOR SELECT
TO authenticated
USING (
    public.crm_es_admin()
);


-- ============================================================
-- 4. POLÍTICA ASESOR - SELECT
-- ============================================================

DROP POLICY IF EXISTS contactos_asesor_select
    ON public.contactos;

CREATE POLICY contactos_asesor_select
ON public.contactos
FOR SELECT
TO authenticated
USING (
    public.crm_puede_ver_contacto(id)
);


-- ============================================================
-- 5. POLÍTICA ADMIN - INSERT
-- ============================================================

DROP POLICY IF EXISTS contactos_admin_insert
    ON public.contactos;

CREATE POLICY contactos_admin_insert
ON public.contactos
FOR INSERT
TO authenticated
WITH CHECK (
    public.crm_es_admin()
);


-- ============================================================
-- 6. POLÍTICA ADMIN - UPDATE
-- ============================================================

DROP POLICY IF EXISTS contactos_admin_update
    ON public.contactos;

CREATE POLICY contactos_admin_update
ON public.contactos
FOR UPDATE
TO authenticated
USING (
    public.crm_es_admin()
)
WITH CHECK (
    public.crm_es_admin()
);


-- ============================================================
-- 7. POLÍTICA ADMIN - DELETE
-- ============================================================

DROP POLICY IF EXISTS contactos_admin_delete
    ON public.contactos;

CREATE POLICY contactos_admin_delete
ON public.contactos
FOR DELETE
TO authenticated
USING (
    public.crm_es_admin()
);


-- ============================================================
-- 8. PERMISOS API
-- ============================================================

REVOKE ALL
ON TABLE public.contactos
FROM anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLE public.contactos
TO authenticated;


-- ============================================================
-- 9. PERMISO DE EJECUCIÓN DE LA FUNCIÓN
-- ============================================================

REVOKE ALL
ON FUNCTION public.crm_puede_ver_contacto(UUID)
FROM PUBLIC;

GRANT EXECUTE
ON FUNCTION public.crm_puede_ver_contacto(UUID)
TO authenticated;


-- ============================================================
-- FIN
-- ============================================================