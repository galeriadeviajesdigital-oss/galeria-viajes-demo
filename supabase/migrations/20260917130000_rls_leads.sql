-- ============================================================
-- GALERÍA DE VIAJES CRM
-- Migración: RLS de Leads
-- Fecha: 2026-09-17
--
-- Objetivo:
--   Proteger los leads del CRM según el rol del usuario.
--
-- Reglas iniciales:
--   ADMIN  -> todos los leads
--   ASESOR -> únicamente sus propios leads
--
-- SUPERVISOR:
--   Se implementará cuando exista la estructura de equipos.
--
-- OPERACIONES / CONTABILIDAD:
--   Se definirán según las necesidades de cada módulo.
-- ============================================================


-- ============================================================
-- 1. HABILITAR RLS
-- ============================================================

ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;


-- ============================================================
-- 2. POLÍTICA ADMIN - LECTURA
-- ============================================================

DROP POLICY IF EXISTS leads_admin_select
    ON public.leads;

CREATE POLICY leads_admin_select
ON public.leads
FOR SELECT
TO authenticated
USING (
    public.crm_es_admin()
);


-- ============================================================
-- 3. POLÍTICA ASESOR - LECTURA
-- ============================================================

DROP POLICY IF EXISTS leads_asesor_select
    ON public.leads;

CREATE POLICY leads_asesor_select
ON public.leads
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.crm_usuarios cu
        JOIN public.vendedores v
            ON v.id = cu.vendedor_id
        WHERE cu.id = auth.uid()
          AND cu.activo = true
          AND cu.rol = 'ASESOR'
          AND public.leads.vendedor_id = cu.vendedor_id
          AND v.activo = true
    )
);


-- ============================================================
-- 4. POLÍTICA ADMIN - INSERT
-- ============================================================

DROP POLICY IF EXISTS leads_admin_insert
    ON public.leads;

CREATE POLICY leads_admin_insert
ON public.leads
FOR INSERT
TO authenticated
WITH CHECK (
    public.crm_es_admin()
);


-- ============================================================
-- 5. POLÍTICA ASESOR - INSERT
-- ============================================================

DROP POLICY IF EXISTS leads_asesor_insert
    ON public.leads;

CREATE POLICY leads_asesor_insert
ON public.leads
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.crm_usuarios cu
        JOIN public.vendedores v
            ON v.id = cu.vendedor_id
        WHERE cu.id = auth.uid()
          AND cu.activo = true
          AND cu.rol = 'ASESOR'
          AND public.leads.vendedor_id = cu.vendedor_id
          AND v.activo = true
    )
);


-- ============================================================
-- 6. POLÍTICA ADMIN - UPDATE
-- ============================================================

DROP POLICY IF EXISTS leads_admin_update
    ON public.leads;

CREATE POLICY leads_admin_update
ON public.leads
FOR UPDATE
TO authenticated
USING (
    public.crm_es_admin()
)
WITH CHECK (
    public.crm_es_admin()
);


-- ============================================================
-- 7. POLÍTICA ASESOR - UPDATE
-- ============================================================

DROP POLICY IF EXISTS leads_asesor_update
    ON public.leads;

CREATE POLICY leads_asesor_update
ON public.leads
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.crm_usuarios cu
        JOIN public.vendedores v
            ON v.id = cu.vendedor_id
        WHERE cu.id = auth.uid()
          AND cu.activo = true
          AND cu.rol = 'ASESOR'
          AND public.leads.vendedor_id = cu.vendedor_id
          AND v.activo = true
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.crm_usuarios cu
        JOIN public.vendedores v
            ON v.id = cu.vendedor_id
        WHERE cu.id = auth.uid()
          AND cu.activo = true
          AND cu.rol = 'ASESOR'
          AND public.leads.vendedor_id = cu.vendedor_id
          AND v.activo = true
    )
);


-- ============================================================
-- 8. POLÍTICA ADMIN - DELETE
-- ============================================================

DROP POLICY IF EXISTS leads_admin_delete
    ON public.leads;

CREATE POLICY leads_admin_delete
ON public.leads
FOR DELETE
TO authenticated
USING (
    public.crm_es_admin()
);


-- ============================================================
-- 9. PERMISOS API
-- ============================================================

REVOKE ALL
ON TABLE public.leads
FROM anon;

GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLE public.leads
TO authenticated;


-- ============================================================
-- FIN
-- ============================================================