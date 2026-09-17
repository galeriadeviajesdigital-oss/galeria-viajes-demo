-- =========================================================
-- CRM GALERÍA DE VIAJES
-- RLS módulos comerciales
-- Migración: 20260917150000
-- =========================================================


-- =========================================================
-- 1. OPORTUNIDADES
-- =========================================================

ALTER TABLE public.oportunidades ENABLE ROW LEVEL SECURITY;


-- ADMIN: acceso completo
CREATE POLICY oportunidades_admin_select
ON public.oportunidades
FOR SELECT
TO authenticated
USING (
    public.crm_es_admin()
);


CREATE POLICY oportunidades_admin_insert
ON public.oportunidades
FOR INSERT
TO authenticated
WITH CHECK (
    public.crm_es_admin()
);


CREATE POLICY oportunidades_admin_update
ON public.oportunidades
FOR UPDATE
TO authenticated
USING (
    public.crm_es_admin()
)
WITH CHECK (
    public.crm_es_admin()
);


CREATE POLICY oportunidades_admin_delete
ON public.oportunidades
FOR DELETE
TO authenticated
USING (
    public.crm_es_admin()
);


-- ASESOR: solamente sus oportunidades
CREATE POLICY oportunidades_asesor_select
ON public.oportunidades
FOR SELECT
TO authenticated
USING (
    public.crm_tiene_rol('ASESOR')
    AND vendedor_id = (
        SELECT cu.vendedor_id
        FROM public.crm_usuarios cu
        WHERE cu.id = auth.uid()
          AND cu.activo = true
    )
);


CREATE POLICY oportunidades_asesor_insert
ON public.oportunidades
FOR INSERT
TO authenticated
WITH CHECK (
    public.crm_tiene_rol('ASESOR')
    AND vendedor_id = (
        SELECT cu.vendedor_id
        FROM public.crm_usuarios cu
        WHERE cu.id = auth.uid()
          AND cu.activo = true
    )
);


CREATE POLICY oportunidades_asesor_update
ON public.oportunidades
FOR UPDATE
TO authenticated
USING (
    public.crm_tiene_rol('ASESOR')
    AND vendedor_id = (
        SELECT cu.vendedor_id
        FROM public.crm_usuarios cu
        WHERE cu.id = auth.uid()
          AND cu.activo = true
    )
)
WITH CHECK (
    public.crm_tiene_rol('ASESOR')
    AND vendedor_id = (
        SELECT cu.vendedor_id
        FROM public.crm_usuarios cu
        WHERE cu.id = auth.uid()
          AND cu.activo = true
    )
);


-- OPERACIONES / CONTABILIDAD: consulta
CREATE POLICY oportunidades_operaciones_contabilidad_select
ON public.oportunidades
FOR SELECT
TO authenticated
USING (
    public.crm_tiene_rol('OPERACIONES')
    OR public.crm_tiene_rol('CONTABILIDAD')
);


-- SUPERVISOR: consulta
CREATE POLICY oportunidades_supervisor_select
ON public.oportunidades
FOR SELECT
TO authenticated
USING (
    public.crm_tiene_rol('SUPERVISOR')
);


-- =========================================================
-- 2. COTIZACIONES
-- =========================================================

ALTER TABLE public.cotizaciones ENABLE ROW LEVEL SECURITY;


-- ADMIN
CREATE POLICY cotizaciones_admin_select
ON public.cotizaciones
FOR SELECT
TO authenticated
USING (
    public.crm_es_admin()
);


CREATE POLICY cotizaciones_admin_insert
ON public.cotizaciones
FOR INSERT
TO authenticated
WITH CHECK (
    public.crm_es_admin()
);


CREATE POLICY cotizaciones_admin_update
ON public.cotizaciones
FOR UPDATE
TO authenticated
USING (
    public.crm_es_admin()
)
WITH CHECK (
    public.crm_es_admin()
);


CREATE POLICY cotizaciones_admin_delete
ON public.cotizaciones
FOR DELETE
TO authenticated
USING (
    public.crm_es_admin()
);


-- ASESOR: cotizaciones de sus oportunidades
CREATE POLICY cotizaciones_asesor_select
ON public.cotizaciones
FOR SELECT
TO authenticated
USING (
    public.crm_tiene_rol('ASESOR')
    AND EXISTS (
        SELECT 1
        FROM public.oportunidades o
        JOIN public.crm_usuarios cu
            ON cu.vendedor_id = o.vendedor_id
        WHERE o.id = cotizaciones.oportunidad_id
          AND cu.id = auth.uid()
          AND cu.activo = true
    )
);


CREATE POLICY cotizaciones_asesor_insert
ON public.cotizaciones
FOR INSERT
TO authenticated
WITH CHECK (
    public.crm_tiene_rol('ASESOR')
    AND EXISTS (
        SELECT 1
        FROM public.oportunidades o
        JOIN public.crm_usuarios cu
            ON cu.vendedor_id = o.vendedor_id
        WHERE o.id = cotizaciones.oportunidad_id
          AND cu.id = auth.uid()
          AND cu.activo = true
    )
);


CREATE POLICY cotizaciones_asesor_update
ON public.cotizaciones
FOR UPDATE
TO authenticated
USING (
    public.crm_tiene_rol('ASESOR')
    AND EXISTS (
        SELECT 1
        FROM public.oportunidades o
        JOIN public.crm_usuarios cu
            ON cu.vendedor_id = o.vendedor_id
        WHERE o.id = cotizaciones.oportunidad_id
          AND cu.id = auth.uid()
          AND cu.activo = true
    )
)
WITH CHECK (
    public.crm_tiene_rol('ASESOR')
    AND EXISTS (
        SELECT 1
        FROM public.oportunidades o
        JOIN public.crm_usuarios cu
            ON cu.vendedor_id = o.vendedor_id
        WHERE o.id = cotizaciones.oportunidad_id
          AND cu.id = auth.uid()
          AND cu.activo = true
    )
);


-- OPERACIONES / CONTABILIDAD: consulta
CREATE POLICY cotizaciones_operaciones_contabilidad_select
ON public.cotizaciones
FOR SELECT
TO authenticated
USING (
    public.crm_tiene_rol('OPERACIONES')
    OR public.crm_tiene_rol('CONTABILIDAD')
);


-- SUPERVISOR: consulta
CREATE POLICY cotizaciones_supervisor_select
ON public.cotizaciones
FOR SELECT
TO authenticated
USING (
    public.crm_tiene_rol('SUPERVISOR')
);


-- =========================================================
-- 3. SEGUIMIENTOS
-- =========================================================

ALTER TABLE public.seguimientos ENABLE ROW LEVEL SECURITY;


-- ADMIN
CREATE POLICY seguimientos_admin_select
ON public.seguimientos
FOR SELECT
TO authenticated
USING (
    public.crm_es_admin()
);


CREATE POLICY seguimientos_admin_insert
ON public.seguimientos
FOR INSERT
TO authenticated
WITH CHECK (
    public.crm_es_admin()
);


CREATE POLICY seguimientos_admin_update
ON public.seguimientos
FOR UPDATE
TO authenticated
USING (
    public.crm_es_admin()
)
WITH CHECK (
    public.crm_es_admin()
);


CREATE POLICY seguimientos_admin_delete
ON public.seguimientos
FOR DELETE
TO authenticated
USING (
    public.crm_es_admin()
);


-- ASESOR: solamente sus seguimientos
CREATE POLICY seguimientos_asesor_select
ON public.seguimientos
FOR SELECT
TO authenticated
USING (
    public.crm_tiene_rol('ASESOR')
    AND vendedor_id = (
        SELECT cu.vendedor_id
        FROM public.crm_usuarios cu
        WHERE cu.id = auth.uid()
          AND cu.activo = true
    )
);


CREATE POLICY seguimientos_asesor_insert
ON public.seguimientos
FOR INSERT
TO authenticated
WITH CHECK (
    public.crm_tiene_rol('ASESOR')
    AND vendedor_id = (
        SELECT cu.vendedor_id
        FROM public.crm_usuarios cu
        WHERE cu.id = auth.uid()
          AND cu.activo = true
    )
);


CREATE POLICY seguimientos_asesor_update
ON public.seguimientos
FOR UPDATE
TO authenticated
USING (
    public.crm_tiene_rol('ASESOR')
    AND vendedor_id = (
        SELECT cu.vendedor_id
        FROM public.crm_usuarios cu
        WHERE cu.id = auth.uid()
          AND cu.activo = true
    )
)
WITH CHECK (
    public.crm_tiene_rol('ASESOR')
    AND vendedor_id = (
        SELECT cu.vendedor_id
        FROM public.crm_usuarios cu
        WHERE cu.id = auth.uid()
          AND cu.activo = true
    )
);


-- OPERACIONES / CONTABILIDAD: consulta
CREATE POLICY seguimientos_operaciones_contabilidad_select
ON public.seguimientos
FOR SELECT
TO authenticated
USING (
    public.crm_tiene_rol('OPERACIONES')
    OR public.crm_tiene_rol('CONTABILIDAD')
);


-- SUPERVISOR: consulta
CREATE POLICY seguimientos_supervisor_select
ON public.seguimientos
FOR SELECT
TO authenticated
USING (
    public.crm_tiene_rol('SUPERVISOR')
);


-- =========================================================
-- 4. VENTAS
-- =========================================================

ALTER TABLE public.ventas ENABLE ROW LEVEL SECURITY;


-- ADMIN: acceso completo
CREATE POLICY ventas_admin_select
ON public.ventas
FOR SELECT
TO authenticated
USING (
    public.crm_es_admin()
);


CREATE POLICY ventas_admin_insert
ON public.ventas
FOR INSERT
TO authenticated
WITH CHECK (
    public.crm_es_admin()
);


CREATE POLICY ventas_admin_update
ON public.ventas
FOR UPDATE
TO authenticated
USING (
    public.crm_es_admin()
)
WITH CHECK (
    public.crm_es_admin()
);


CREATE POLICY ventas_admin_delete
ON public.ventas
FOR DELETE
TO authenticated
USING (
    public.crm_es_admin()
);


-- OPERACIONES / CONTABILIDAD:
-- acceso completo
CREATE POLICY ventas_operaciones_contabilidad_select
ON public.ventas
FOR SELECT
TO authenticated
USING (
    public.crm_tiene_rol('OPERACIONES')
    OR public.crm_tiene_rol('CONTABILIDAD')
);


CREATE POLICY ventas_operaciones_contabilidad_insert
ON public.ventas
FOR INSERT
TO authenticated
WITH CHECK (
    public.crm_tiene_rol('OPERACIONES')
    OR public.crm_tiene_rol('CONTABILIDAD')
);


CREATE POLICY ventas_operaciones_contabilidad_update
ON public.ventas
FOR UPDATE
TO authenticated
USING (
    public.crm_tiene_rol('OPERACIONES')
    OR public.crm_tiene_rol('CONTABILIDAD')
)
WITH CHECK (
    public.crm_tiene_rol('OPERACIONES')
    OR public.crm_tiene_rol('CONTABILIDAD')
);


CREATE POLICY ventas_operaciones_contabilidad_delete
ON public.ventas
FOR DELETE
TO authenticated
USING (
    public.crm_tiene_rol('OPERACIONES')
    OR public.crm_tiene_rol('CONTABILIDAD')
);


-- SUPERVISOR: consulta
CREATE POLICY ventas_supervisor_select
ON public.ventas
FOR SELECT
TO authenticated
USING (
    public.crm_tiene_rol('SUPERVISOR')
);


-- ASESOR: solamente sus ventas
CREATE POLICY ventas_asesor_select
ON public.ventas
FOR SELECT
TO authenticated
USING (
    public.crm_tiene_rol('ASESOR')
    AND EXISTS (
        SELECT 1
        FROM public.oportunidades o
        JOIN public.crm_usuarios cu
            ON cu.vendedor_id = o.vendedor_id
        WHERE o.id = ventas.oportunidad_id
          AND cu.id = auth.uid()
          AND cu.activo = true
    )
);


-- =========================================================
-- 5. PERMISOS DE TABLA
-- =========================================================

REVOKE ALL ON TABLE public.oportunidades
FROM anon, authenticated;

REVOKE ALL ON TABLE public.cotizaciones
FROM anon, authenticated;

REVOKE ALL ON TABLE public.seguimientos
FROM anon, authenticated;

REVOKE ALL ON TABLE public.ventas
FROM anon, authenticated;


GRANT
    SELECT,
    INSERT,
    UPDATE,
    DELETE
ON TABLE public.oportunidades
TO authenticated;


GRANT
    SELECT,
    INSERT,
    UPDATE,
    DELETE
ON TABLE public.cotizaciones
TO authenticated;


GRANT
    SELECT,
    INSERT,
    UPDATE,
    DELETE
ON TABLE public.seguimientos
TO authenticated;


GRANT
    SELECT,
    INSERT,
    UPDATE,
    DELETE
ON TABLE public.ventas
TO authenticated;