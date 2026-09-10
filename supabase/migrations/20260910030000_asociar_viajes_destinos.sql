-- ============================================================
-- Galería de Viajes 2.0
-- Migración: Asociaciones viaje <-> destinos
-- Fecha: 2026-09-10
--
-- Objetivo:
--   Asociar los circuitos multinacionales con todos los países
--   identificables en sus recorridos.
--
-- Nota:
--   Caribe Premium queda pendiente porque su descripción actual
--   no identifica un país concreto.
--
-- La migración utiliza slug para resolver los UUID.
-- ============================================================

BEGIN;

-- ============================================================
-- ESPAÑA Y PORTUGAL
-- ============================================================

INSERT INTO public.viaje_destinos (
    viaje_id,
    destino_id,
    es_principal,
    orden
)
SELECT
    v.id,
    d.id,
    x.es_principal,
    x.orden
FROM public.viajes v
JOIN (
    VALUES
        ('espana', true, 1),
        ('portugal', false, 2)
) AS x(destino_slug, es_principal, orden)
    ON true
JOIN public.destinos d
    ON d.slug = x.destino_slug
WHERE v.slug = 'espana-portugal'
ON CONFLICT (viaje_id, destino_id) DO UPDATE
SET
    es_principal = EXCLUDED.es_principal,
    orden = EXCLUDED.orden;


-- ============================================================
-- CIUDADES IMPERIALES
-- Berlín, Dresden, Praga, Bratislava, Budapest, Viena
-- ============================================================

INSERT INTO public.viaje_destinos (
    viaje_id,
    destino_id,
    es_principal,
    orden
)
SELECT
    v.id,
    d.id,
    x.es_principal,
    x.orden
FROM public.viajes v
JOIN (
    VALUES
        ('alemania', true, 1),
        ('republica-checa', false, 2),
        ('eslovaquia', false, 3),
        ('hungria', false, 4),
        ('austria', false, 5)
) AS x(destino_slug, es_principal, orden)
    ON true
JOIN public.destinos d
    ON d.slug = x.destino_slug
WHERE v.slug = 'ciudades-imperiales-1'
ON CONFLICT (viaje_id, destino_id) DO UPDATE
SET
    es_principal = EXCLUDED.es_principal,
    orden = EXCLUDED.orden;


-- ============================================================
-- EUROPA EN BANDEJA
-- Londres, París, Bruselas, Gante, Brujas, Amberes,
-- La Haya, Amsterdam, Colonia, Rin, Frankfurt, Múnich,
-- Salzburgo, Viena, Liubliana, Venecia, Padua, Florencia,
-- Siena, Asís, Roma, Pisa, Costa Azul, Barcelona,
-- Zaragoza y Madrid.
-- ============================================================

INSERT INTO public.viaje_destinos (
    viaje_id,
    destino_id,
    es_principal,
    orden
)
SELECT
    v.id,
    d.id,
    x.es_principal,
    x.orden
FROM public.viajes v
JOIN (
    VALUES
        ('reino-unido', true, 1),
        ('francia', false, 2),
        ('belgica', false, 3),
        ('paises-bajos', false, 4),
        ('alemania', false, 5),
        ('austria', false, 6),
        ('eslovenia', false, 7),
        ('italia', false, 8),
        ('espana', false, 9)
) AS x(destino_slug, es_principal, orden)
    ON true
JOIN public.destinos d
    ON d.slug = x.destino_slug
WHERE v.slug = 'europa-en-bandeja'
ON CONFLICT (viaje_id, destino_id) DO UPDATE
SET
    es_principal = EXCLUDED.es_principal,
    orden = EXCLUDED.orden;


-- ============================================================
-- EUROPA EN BREVE "DESDE MADRID"
-- Madrid, San Sebastián, Burdeos, Loire, París, Rin,
-- Frankfurt, Heidelberg, Lucerna, Zurich, Innsbruck,
-- Venecia, Padua, Florencia, Roma, Pisa, Costa Azul,
-- Barcelona y Zaragoza.
-- ============================================================

INSERT INTO public.viaje_destinos (
    viaje_id,
    destino_id,
    es_principal,
    orden
)
SELECT
    v.id,
    d.id,
    x.es_principal,
    x.orden
FROM public.viajes v
JOIN (
    VALUES
        ('espana', true, 1),
        ('francia', false, 2),
        ('alemania', false, 3),
        ('suiza', false, 4),
        ('austria', false, 5),
        ('italia', false, 6)
) AS x(destino_slug, es_principal, orden)
    ON true
JOIN public.destinos d
    ON d.slug = x.destino_slug
WHERE v.slug = 'europa-en-breve-desde-madrid'
ON CONFLICT (viaje_id, destino_id) DO UPDATE
SET
    es_principal = EXCLUDED.es_principal,
    orden = EXCLUDED.orden;


-- ============================================================
-- EUROPA ESTILO MP 1
-- Madrid, Zaragoza, Barcelona, Costa Azul, Pisa, Roma,
-- Florencia, Padua, Venecia, Innsbruck, Lucerna, Zurich,
-- París, Lourdes y San Sebastián.
-- ============================================================

INSERT INTO public.viaje_destinos (
    viaje_id,
    destino_id,
    es_principal,
    orden
)
SELECT
    v.id,
    d.id,
    x.es_principal,
    x.orden
FROM public.viajes v
JOIN (
    VALUES
        ('espana', true, 1),
        ('francia', false, 2),
        ('italia', false, 3),
        ('austria', false, 4),
        ('suiza', false, 5)
) AS x(destino_slug, es_principal, orden)
    ON true
JOIN public.destinos d
    ON d.slug = x.destino_slug
WHERE v.slug = 'europa-estilo-mp-1-desde-madrid-a-madrid'
ON CONFLICT (viaje_id, destino_id) DO UPDATE
SET
    es_principal = EXCLUDED.es_principal,
    orden = EXCLUDED.orden;


-- ============================================================
-- EUROPA EXQUISITA
-- París, Dijon, Zúrich, Lucerna, Venecia, Padua,
-- Florencia, Asís y Roma.
-- ============================================================

INSERT INTO public.viaje_destinos (
    viaje_id,
    destino_id,
    es_principal,
    orden
)
SELECT
    v.id,
    d.id,
    x.es_principal,
    x.orden
FROM public.viajes v
JOIN (
    VALUES
        ('francia', true, 1),
        ('suiza', false, 2),
        ('italia', false, 3)
) AS x(destino_slug, es_principal, orden)
    ON true
JOIN public.destinos d
    ON d.slug = x.destino_slug
WHERE v.slug = 'europa-exquisita'
ON CONFLICT (viaje_id, destino_id) DO UPDATE
SET
    es_principal = EXCLUDED.es_principal,
    orden = EXCLUDED.orden;


-- ============================================================
-- LA PEQUEÑA GIRA EUROPEA
-- Londres, París, Rin, Frankfurt, Múnich, Salzburgo,
-- Viena, Liubliana, Venecia, Padua, Florencia, Siena,
-- Asís, Roma, Pisa, Costa Azul, Barcelona, Zaragoza y Madrid.
-- ============================================================

INSERT INTO public.viaje_destinos (
    viaje_id,
    destino_id,
    es_principal,
    orden
)
SELECT
    v.id,
    d.id,
    x.es_principal,
    x.orden
FROM public.viajes v
JOIN (
    VALUES
        ('reino-unido', true, 1),
        ('francia', false, 2),
        ('alemania', false, 3),
        ('austria', false, 4),
        ('eslovenia', false, 5),
        ('italia', false, 6),
        ('espana', false, 7)
) AS x(destino_slug, es_principal, orden)
    ON true
JOIN public.destinos d
    ON d.slug = x.destino_slug
WHERE v.slug = 'la-pequena-gira-europea'
ON CONFLICT (viaje_id, destino_id) DO UPDATE
SET
    es_principal = EXCLUDED.es_principal,
    orden = EXCLUDED.orden;


-- ============================================================
-- LUCES DE EUROPA
-- Londres, París, Mont Saint Michel, Caen, Bruselas,
-- Brujas, Amsterdam, Colonia, Rin y Frankfurt.
-- ============================================================

INSERT INTO public.viaje_destinos (
    viaje_id,
    destino_id,
    es_principal,
    orden
)
SELECT
    v.id,
    d.id,
    x.es_principal,
    x.orden
FROM public.viajes v
JOIN (
    VALUES
        ('reino-unido', true, 1),
        ('francia', false, 2),
        ('belgica', false, 3),
        ('paises-bajos', false, 4),
        ('alemania', false, 5)
) AS x(destino_slug, es_principal, orden)
    ON true
JOIN public.destinos d
    ON d.slug = x.destino_slug
WHERE v.slug = 'luces-de-europa'
ON CONFLICT (viaje_id, destino_id) DO UPDATE
SET
    es_principal = EXCLUDED.es_principal,
    orden = EXCLUDED.orden;


-- ============================================================
-- MARAVILLAS DE EUROPA
-- Amsterdam, Berlin, Dresden, Praga, Bratislava,
-- Budapest, Viena, Salzburgo, Zurich, Neuschwanstein,
-- Munich, Nuremberg y Frankfurt.
-- ============================================================

INSERT INTO public.viaje_destinos (
    viaje_id,
    destino_id,
    es_principal,
    orden
)
SELECT
    v.id,
    d.id,
    x.es_principal,
    x.orden
FROM public.viajes v
JOIN (
    VALUES
        ('paises-bajos', true, 1),
        ('alemania', false, 2),
        ('republica-checa', false, 3),
        ('eslovaquia', false, 4),
        ('hungria', false, 5),
        ('austria', false, 6),
        ('suiza', false, 7)
) AS x(destino_slug, es_principal, orden)
    ON true
JOIN public.destinos d
    ON d.slug = x.destino_slug
WHERE v.slug = 'maravillas-de-europa'
ON CONFLICT (viaje_id, destino_id) DO UPDATE
SET
    es_principal = EXCLUDED.es_principal,
    orden = EXCLUDED.orden;


-- ============================================================
-- QUERIDA EUROPA
-- España, Francia, Alemania, Austria, Eslovenia e Italia.
-- ============================================================

INSERT INTO public.viaje_destinos (
    viaje_id,
    destino_id,
    es_principal,
    orden
)
SELECT
    v.id,
    d.id,
    x.es_principal,
    x.orden
FROM public.viajes v
JOIN (
    VALUES
        ('espana', true, 1),
        ('francia', false, 2),
        ('alemania', false, 3),
        ('austria', false, 4),
        ('eslovenia', false, 5),
        ('italia', false, 6)
) AS x(destino_slug, es_principal, orden)
    ON true
JOIN public.destinos d
    ON d.slug = x.destino_slug
WHERE v.slug = 'querida-europa'
ON CONFLICT (viaje_id, destino_id) DO UPDATE
SET
    es_principal = EXCLUDED.es_principal,
    orden = EXCLUDED.orden;


COMMIT;
