-- ============================================================
-- V17 - Permisos públicos para detalle de viajes
-- ============================================================
-- Permite que el sitio público consulte la información
-- comercial de viajes mediante el rol anon.
--
-- Seguridad:
-- Solo se exponen registros pertenecientes a viajes activos.
-- Las opciones deben estar activas.
-- Las salidas deben estar activas.
-- ============================================================


-- ============================================================
-- 1. PRIVILEGIOS SELECT
-- ============================================================

GRANT SELECT ON TABLE public.viaje_itinerario
TO anon, authenticated;

GRANT SELECT ON TABLE public.viaje_hoteles
TO anon, authenticated;

GRANT SELECT ON TABLE public.viaje_inclusiones
TO anon, authenticated;

GRANT SELECT ON TABLE public.viaje_exclusiones
TO anon, authenticated;

GRANT SELECT ON TABLE public.viaje_opciones
TO anon, authenticated;

GRANT SELECT ON TABLE public.viaje_opcion_items
TO anon, authenticated;

GRANT SELECT ON TABLE public.viaje_salidas
TO anon, authenticated;


-- ============================================================
-- 2. ACTIVAR RLS
-- ============================================================

ALTER TABLE public.viaje_itinerario
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.viaje_hoteles
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.viaje_inclusiones
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.viaje_exclusiones
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.viaje_opciones
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.viaje_opcion_items
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.viaje_salidas
ENABLE ROW LEVEL SECURITY;


-- ============================================================
-- 3. ITINERARIO
-- ============================================================

DROP POLICY IF EXISTS "Public read active trip itinerary"
ON public.viaje_itinerario;

CREATE POLICY "Public read active trip itinerary"
ON public.viaje_itinerario
FOR SELECT
TO anon, authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.viajes v
        WHERE v.id = viaje_itinerario.viaje_id
          AND v.activo = true
    )
);


-- ============================================================
-- 4. HOTELES
-- ============================================================

DROP POLICY IF EXISTS "Public read active trip hotels"
ON public.viaje_hoteles;

CREATE POLICY "Public read active trip hotels"
ON public.viaje_hoteles
FOR SELECT
TO anon, authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.viajes v
        WHERE v.id = viaje_hoteles.viaje_id
          AND v.activo = true
    )
);


-- ============================================================
-- 5. INCLUSIONES
-- ============================================================

DROP POLICY IF EXISTS "Public read active trip inclusions"
ON public.viaje_inclusiones;

CREATE POLICY "Public read active trip inclusions"
ON public.viaje_inclusiones
FOR SELECT
TO anon, authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.viajes v
        WHERE v.id = viaje_inclusiones.viaje_id
          AND v.activo = true
    )
);


-- ============================================================
-- 6. EXCLUSIONES
-- ============================================================

DROP POLICY IF EXISTS "Public read active trip exclusions"
ON public.viaje_exclusiones;

CREATE POLICY "Public read active trip exclusions"
ON public.viaje_exclusiones
FOR SELECT
TO anon, authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.viajes v
        WHERE v.id = viaje_exclusiones.viaje_id
          AND v.activo = true
    )
);


-- ============================================================
-- 7. OPCIONES / VARIANTES
-- ============================================================

DROP POLICY IF EXISTS "Public read active trip options"
ON public.viaje_opciones;

CREATE POLICY "Public read active trip options"
ON public.viaje_opciones
FOR SELECT
TO anon, authenticated
USING (
    viaje_opciones.activo = true
    AND EXISTS (
        SELECT 1
        FROM public.viajes v
        WHERE v.id = viaje_opciones.viaje_id
          AND v.activo = true
    )
);


-- ============================================================
-- 8. ITEMS DE OPCIONES
-- ============================================================

DROP POLICY IF EXISTS "Public read active option items"
ON public.viaje_opcion_items;

CREATE POLICY "Public read active option items"
ON public.viaje_opcion_items
FOR SELECT
TO anon, authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.viaje_opciones o
        INNER JOIN public.viajes v
            ON v.id = o.viaje_id
        WHERE o.id = viaje_opcion_items.opcion_id
          AND o.activo = true
          AND v.activo = true
    )
);


-- ============================================================
-- 9. SALIDAS
-- ============================================================

DROP POLICY IF EXISTS "Public read active trip departures"
ON public.viaje_salidas;

CREATE POLICY "Public read active trip departures"
ON public.viaje_salidas
FOR SELECT
TO anon, authenticated
USING (
    viaje_salidas.activo = true
    AND EXISTS (
        SELECT 1
        FROM public.viajes v
        WHERE v.id = viaje_salidas.viaje_id
          AND v.activo = true
    )
);
