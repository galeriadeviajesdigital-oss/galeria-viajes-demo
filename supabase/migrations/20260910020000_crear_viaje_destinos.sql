-- ============================================================
-- Galería de Viajes 2.0
-- Migración: Relación viajes <-> destinos
-- Fecha: 2026-09-10
--
-- Objetivo:
--   Permitir que un viaje esté asociado a múltiples destinos.
--
-- viajes.destino_id:
--   Se conserva como destino principal/comercial.
--
-- viaje_destinos:
--   Contiene todos los destinos por país asociados al viaje.
-- ============================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.viaje_destinos (
    viaje_id UUID NOT NULL,
    destino_id UUID NOT NULL,
    es_principal BOOLEAN NOT NULL DEFAULT false,
    orden INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT viaje_destinos_pkey
        PRIMARY KEY (viaje_id, destino_id),

    CONSTRAINT viaje_destinos_viaje_fk
        FOREIGN KEY (viaje_id)
        REFERENCES public.viajes(id)
        ON DELETE CASCADE,

    CONSTRAINT viaje_destinos_destino_fk
        FOREIGN KEY (destino_id)
        REFERENCES public.destinos(id)
        ON DELETE CASCADE,

    CONSTRAINT viaje_destinos_orden_check
        CHECK (orden >= 0)
);

CREATE INDEX IF NOT EXISTS viaje_destinos_destino_idx
    ON public.viaje_destinos (destino_id);

CREATE INDEX IF NOT EXISTS viaje_destinos_viaje_idx
    ON public.viaje_destinos (viaje_id);

COMMIT;
