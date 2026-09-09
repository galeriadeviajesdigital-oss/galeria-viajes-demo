-- ============================================================
-- Galería de Viajes
-- Migración: permisos y RLS del catálogo público
-- ============================================================

-- ------------------------------------------------------------
-- 1. Permisos PostgreSQL
-- ------------------------------------------------------------
-- RLS determina QUÉ registros puede ver el usuario.
-- GRANT determina si el rol puede consultar la tabla.
-- Ambas capas son necesarias.

GRANT SELECT ON TABLE public.destinos TO anon;
GRANT SELECT ON TABLE public.destinos TO authenticated;

GRANT SELECT ON TABLE public.experiencias TO anon;
GRANT SELECT ON TABLE public.experiencias TO authenticated;

GRANT SELECT ON TABLE public.destino_experiencia TO anon;
GRANT SELECT ON TABLE public.destino_experiencia TO authenticated;

GRANT SELECT ON TABLE public.viajes TO anon;
GRANT SELECT ON TABLE public.viajes TO authenticated;

GRANT SELECT ON TABLE public.ofertas TO anon;
GRANT SELECT ON TABLE public.ofertas TO authenticated;


-- ------------------------------------------------------------
-- 2. Activar Row Level Security
-- ------------------------------------------------------------

ALTER TABLE public.destinos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.experiencias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.destino_experiencia ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.viajes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ofertas ENABLE ROW LEVEL SECURITY;


-- ------------------------------------------------------------
-- 3. Destinos
-- ------------------------------------------------------------

DROP POLICY IF EXISTS catalogo_publico_destinos_select
ON public.destinos;

CREATE POLICY catalogo_publico_destinos_select
ON public.destinos
FOR SELECT
TO anon, authenticated
USING (
    activo = true
);


-- ------------------------------------------------------------
-- 4. Experiencias
-- ------------------------------------------------------------

DROP POLICY IF EXISTS catalogo_publico_experiencias_select
ON public.experiencias;

CREATE POLICY catalogo_publico_experiencias_select
ON public.experiencias
FOR SELECT
TO anon, authenticated
USING (
    activo = true
);


-- ------------------------------------------------------------
-- 5. Relación destino-experiencia
-- ------------------------------------------------------------

DROP POLICY IF EXISTS catalogo_publico_destino_experiencia_select
ON public.destino_experiencia;

CREATE POLICY catalogo_publico_destino_experiencia_select
ON public.destino_experiencia
FOR SELECT
TO anon, authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.destinos d
        WHERE d.id = destino_experiencia.destino_id
          AND d.activo = true
    )
    AND EXISTS (
        SELECT 1
        FROM public.experiencias e
        WHERE e.id = destino_experiencia.experiencia_id
          AND e.activo = true
    )
);


-- ------------------------------------------------------------
-- 6. Viajes
-- ------------------------------------------------------------

DROP POLICY IF EXISTS catalogo_publico_viajes_select
ON public.viajes;

CREATE POLICY catalogo_publico_viajes_select
ON public.viajes
FOR SELECT
TO anon, authenticated
USING (
    activo = true
);


-- ------------------------------------------------------------
-- 7. Ofertas
-- ------------------------------------------------------------

DROP POLICY IF EXISTS catalogo_publico_ofertas_select
ON public.ofertas;

CREATE POLICY catalogo_publico_ofertas_select
ON public.ofertas
FOR SELECT
TO anon, authenticated
USING (
    activa = true
);


-- ============================================================
-- Fin de la migración
-- ============================================================
