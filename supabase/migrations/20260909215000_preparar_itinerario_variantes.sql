-- ============================================================
-- V14A - PREPARAR ITINERARIOS PARA VARIANTES
-- ============================================================
--
-- Permite que un viaje tenga diferentes itinerarios asociados
-- a diferentes opciones comerciales.
--
-- Compatibilidad:
--   Los viajes existentes mantienen opcion_id = NULL.
--
-- Antes:
--   UNIQUE (viaje_id, dia_numero)
--
-- Después:
--   UNIQUE (viaje_id, opcion_id, dia_numero)
-- ============================================================

ALTER TABLE public.viaje_itinerario
ADD COLUMN IF NOT EXISTS opcion_id UUID;

-- ============================================================
-- FOREIGN KEY
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'viaje_itinerario_opcion_fk'
    ) THEN

        ALTER TABLE public.viaje_itinerario
        ADD CONSTRAINT viaje_itinerario_opcion_fk
        FOREIGN KEY (opcion_id)
        REFERENCES public.viaje_opciones(id)
        ON DELETE CASCADE;

    END IF;
END $$;


-- ============================================================
-- ELIMINAR RESTRICCIÓN DE UNICIDAD ANTERIOR
-- ============================================================

ALTER TABLE public.viaje_itinerario
DROP CONSTRAINT IF EXISTS viaje_itinerario_unique_dia;


-- ============================================================
-- NUEVA RESTRICCIÓN DE UNICIDAD
-- ============================================================

ALTER TABLE public.viaje_itinerario
ADD CONSTRAINT viaje_itinerario_unique_dia
UNIQUE (viaje_id, opcion_id, dia_numero);


-- ============================================================
-- ÍNDICE PARA CONSULTAS POR OPCIÓN
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_viaje_itinerario_opcion
ON public.viaje_itinerario (opcion_id, dia_numero);
