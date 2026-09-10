-- ============================================================
-- Galería de Viajes 2.0
-- Migración: Destinos europeos adicionales
-- Fecha: 2026-09-10
--
-- Objetivo:
--   Completar el catálogo de países necesarios para los
--   circuitos europeos actualmente publicados.
--
-- No modifica viajes ni relaciones.
-- ============================================================

BEGIN;

INSERT INTO public.destinos (
    nombre,
    slug,
    region,
    pais,
    continente,
    descripcion_corta,
    destacado,
    activo,
    orden
)
VALUES
    (
        'Francia',
        'francia',
        'Europa',
        'Francia',
        'Europa',
        'Descubre Francia, su patrimonio, gastronomía, cultura y paisajes.',
        false,
        true,
        113
    ),
    (
        'Alemania',
        'alemania',
        'Europa',
        'Alemania',
        'Europa',
        'Explora Alemania, sus ciudades históricas, cultura y paisajes.',
        false,
        true,
        114
    ),
    (
        'Austria',
        'austria',
        'Europa',
        'Austria',
        'Europa',
        'Descubre Austria, sus ciudades imperiales, Alpes y patrimonio cultural.',
        false,
        true,
        115
    ),
    (
        'Eslovenia',
        'eslovenia',
        'Europa',
        'Eslovenia',
        'Europa',
        'Descubre Eslovenia, sus paisajes alpinos, ciudades y patrimonio.',
        false,
        true,
        116
    ),
    (
        'Reino Unido',
        'reino-unido',
        'Europa',
        'Reino Unido',
        'Europa',
        'Explora el Reino Unido y sus ciudades, historia y cultura.',
        false,
        true,
        117
    ),
    (
        'Bélgica',
        'belgica',
        'Europa',
        'Bélgica',
        'Europa',
        'Descubre Bélgica, sus ciudades históricas, arquitectura y gastronomía.',
        false,
        true,
        118
    ),
    (
        'Países Bajos',
        'paises-bajos',
        'Europa',
        'Países Bajos',
        'Europa',
        'Explora los Países Bajos, sus ciudades, canales y patrimonio.',
        false,
        true,
        119
    ),
    (
        'Suiza',
        'suiza',
        'Europa',
        'Suiza',
        'Europa',
        'Descubre Suiza, sus Alpes, lagos, ciudades y paisajes.',
        false,
        true,
        120
    ),
    (
        'República Checa',
        'republica-checa',
        'Europa',
        'República Checa',
        'Europa',
        'Explora la República Checa y su patrimonio histórico y cultural.',
        false,
        true,
        121
    ),
    (
        'Eslovaquia',
        'eslovaquia',
        'Europa',
        'Eslovaquia',
        'Europa',
        'Descubre Eslovaquia, sus ciudades históricas y paisajes.',
        false,
        true,
        122
    ),
    (
        'Hungría',
        'hungria',
        'Europa',
        'Hungría',
        'Europa',
        'Explora Hungría, Budapest, su patrimonio y cultura.',
        false,
        true,
        123
    )
ON CONFLICT (slug) DO UPDATE
SET
    nombre = EXCLUDED.nombre,
    region = EXCLUDED.region,
    pais = EXCLUDED.pais,
    continente = EXCLUDED.continente,
    descripcion_corta = EXCLUDED.descripcion_corta,
    activo = EXCLUDED.activo,
    updated_at = now();

COMMIT;
