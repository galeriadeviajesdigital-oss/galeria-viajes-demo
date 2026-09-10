-- ============================================================
-- Galería de Viajes 2.0
-- Migración: Normalización de destinos por país
-- Fecha: 2026-09-10
--
-- Objetivo:
--   1. Mantener las regiones existentes.
--   2. Crear destinos por país.
--   3. Reasignar viajes claramente asociados a un solo país.
--   4. No modificar todavía los circuitos multinacionales.
--
-- Convención actual:
--   pais IS NULL     -> destino regional
--   pais IS NOT NULL -> destino por país
-- ============================================================

BEGIN;

-- ============================================================
-- 1. DESTINOS POR PAÍS
-- ============================================================

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
        'Italia',
        'italia',
        'Europa',
        'Italia',
        'Europa',
        'Descubre Italia, su patrimonio, gastronomía, arte y ciudades históricas.',
        false,
        true,
        101
    ),
    (
        'España',
        'espana',
        'Europa',
        'España',
        'Europa',
        'Explora España y sus ciudades, cultura, gastronomía y paisajes.',
        false,
        true,
        102
    ),
    (
        'Portugal',
        'portugal',
        'Europa',
        'Portugal',
        'Europa',
        'Descubre Portugal, su patrimonio, gastronomía y paisajes atlánticos.',
        false,
        true,
        103
    ),
    (
        'Grecia',
        'grecia',
        'Europa',
        'Grecia',
        'Europa',
        'Vive la historia, las islas y el Mediterráneo de Grecia.',
        false,
        true,
        104
    ),
    (
        'Japón',
        'japon',
        'Asia',
        'Japón',
        'Asia',
        'Descubre la tradición, cultura y modernidad de Japón.',
        false,
        true,
        105
    ),
    (
        'Tailandia',
        'tailandia',
        'Asia',
        'Tailandia',
        'Asia',
        'Explora la cultura, templos, playas y paisajes de Tailandia.',
        false,
        true,
        106
    ),
    (
        'México',
        'mexico',
        'América',
        'México',
        'América',
        'Descubre la riqueza cultural, histórica y gastronómica de México.',
        false,
        true,
        107
    ),
    (
        'Kenia',
        'kenia',
        'África',
        'Kenia',
        'África',
        'Vive la experiencia de los safaris y la naturaleza de Kenia.',
        false,
        true,
        108
    ),
    (
        'Argentina',
        'argentina',
        'América',
        'Argentina',
        'América',
        'Descubre los paisajes y destinos de Argentina.',
        false,
        true,
        109
    ),
    (
        'República Dominicana',
        'republica-dominicana',
        'Caribe',
        'República Dominicana',
        'América',
        'Disfruta playas, resorts y experiencias inolvidables en República Dominicana.',
        false,
        true,
        110
    ),
    (
        'Emiratos Árabes Unidos',
        'emiratos-arabes-unidos',
        'Medio Oriente',
        'Emiratos Árabes Unidos',
        'Asia',
        'Descubre Dubái, Abu Dabi y la modernidad de los Emiratos Árabes Unidos.',
        false,
        true,
        111
    ),
    (
        'Turquía',
        'turquia',
        'Medio Oriente',
        'Turquía',
        'Asia',
        'Descubre Turquía, entre Europa y Asia, con su historia, cultura y paisajes.',
        false,
        true,
        112
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


-- ============================================================
-- 2. REASIGNACIÓN DE VIAJES DE UN SOLO PAÍS
-- ============================================================

-- Italia
UPDATE public.viajes
SET destino_id = (
    SELECT id
    FROM public.destinos
    WHERE slug = 'italia'
)
WHERE slug IN (
    'italia-clasica',
    'italia-brillante'
);


-- Grecia
UPDATE public.viajes
SET destino_id = (
    SELECT id
    FROM public.destinos
    WHERE slug = 'grecia'
)
WHERE slug IN (
    'grecia-mediterranea',
    'mykonos-santorini'
);


-- Japón
UPDATE public.viajes
SET destino_id = (
    SELECT id
    FROM public.destinos
    WHERE slug = 'japon'
)
WHERE slug = 'japon-tradicional';


-- Tailandia
UPDATE public.viajes
SET destino_id = (
    SELECT id
    FROM public.destinos
    WHERE slug = 'tailandia'
)
WHERE slug = 'tailandia-esencial';


-- México
UPDATE public.viajes
SET destino_id = (
    SELECT id
    FROM public.destinos
    WHERE slug = 'mexico'
)
WHERE slug = 'mexico-cultural';


-- Kenia
UPDATE public.viajes
SET destino_id = (
    SELECT id
    FROM public.destinos
    WHERE slug = 'kenia'
)
WHERE slug = 'safari-en-kenia';


-- Argentina
UPDATE public.viajes
SET destino_id = (
    SELECT id
    FROM public.destinos
    WHERE slug = 'argentina'
)
WHERE slug = 'patagonia-inolvidable';


-- República Dominicana
UPDATE public.viajes
SET destino_id = (
    SELECT id
    FROM public.destinos
    WHERE slug = 'republica-dominicana'
)
WHERE slug = 'punta-cana-escape';


-- Emiratos Árabes Unidos
UPDATE public.viajes
SET destino_id = (
    SELECT id
    FROM public.destinos
    WHERE slug = 'emiratos-arabes-unidos'
)
WHERE slug = 'dubai-y-abu-dabi';


-- Turquía
UPDATE public.viajes
SET destino_id = (
    SELECT id
    FROM public.destinos
    WHERE slug = 'turquia'
)
WHERE slug = 'turquia-en-oferta';


COMMIT;
