-- ============================================================
-- Corrección RLS de leads
-- Evita que las políticas de leads requieran permisos directos
-- sobre public.vendedores para el rol authenticated.
-- ============================================================

CREATE OR REPLACE FUNCTION public.crm_asesor_puede_ver_lead(
    p_vendedor_id UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
    SELECT EXISTS (
        SELECT 1
        FROM public.crm_usuarios cu
        JOIN public.vendedores v
            ON v.id = cu.vendedor_id
        WHERE cu.id = auth.uid()
          AND cu.activo = true
          AND cu.rol = 'ASESOR'
          AND cu.vendedor_id = p_vendedor_id
          AND v.activo = true
    );
$function$;

REVOKE ALL
ON FUNCTION public.crm_asesor_puede_ver_lead(UUID)
FROM PUBLIC;

GRANT EXECUTE
ON FUNCTION public.crm_asesor_puede_ver_lead(UUID)
TO authenticated;


DROP POLICY IF EXISTS leads_asesor_select
ON public.leads;

CREATE POLICY leads_asesor_select
ON public.leads
FOR SELECT
TO authenticated
USING (
    public.crm_asesor_puede_ver_lead(vendedor_id)
);


DROP POLICY IF EXISTS leads_asesor_insert
ON public.leads;

CREATE POLICY leads_asesor_insert
ON public.leads
FOR INSERT
TO authenticated
WITH CHECK (
    public.crm_asesor_puede_ver_lead(vendedor_id)
);


DROP POLICY IF EXISTS leads_asesor_update
ON public.leads;

CREATE POLICY leads_asesor_update
ON public.leads
FOR UPDATE
TO authenticated
USING (
    public.crm_asesor_puede_ver_lead(vendedor_id)
)
WITH CHECK (
    public.crm_asesor_puede_ver_lead(vendedor_id)
);