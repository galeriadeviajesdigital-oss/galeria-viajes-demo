-- ============================================================
-- Galería de Viajes
-- Migración: catálogo demo de viajes
-- Entorno: DEV
-- ============================================================

-- ------------------------------------------------------------
-- Europa
-- ------------------------------------------------------------

INSERT INTO public.viajes (
    destino_id,
    nombre,
    slug,
    descripcion,
    duracion_dias,
    duracion_noches,
    precio_desde,
    moneda,
    incluye,
    no_incluye,
    imagen_url,
    destacado,
    activo
)
SELECT
    d.id,
    'Italia Clásica',
    'italia-clasica',
    'Un recorrido por Roma, Florencia y Venecia para descubrir historia, arte, gastronomía y cultura italiana.',
    10,
    9,
    2895,
    'USD',
    'Alojamiento, traslados, visitas seleccionadas y asistencia durante el viaje.',
    'Boletos aéreos internacionales, gastos personales y servicios no indicados.',
    NULL,
    true,
    true
FROM public.destinos d
WHERE d.slug = 'europa'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viajes v
      WHERE v.slug = 'italia-clasica'
  );


INSERT INTO public.viajes (
    destino_id,
    nombre,
    slug,
    descripcion,
    duracion_dias,
    duracion_noches,
    precio_desde,
    moneda,
    incluye,
    no_incluye,
    imagen_url,
    destacado,
    activo
)
SELECT
    d.id,
    'España y Portugal',
    'espana-portugal',
    'Una experiencia por Madrid, Sevilla, Lisboa y Oporto combinando patrimonio, gastronomía y paisajes.',
    12,
    11,
    3195,
    'USD',
    'Alojamiento, traslados, excursiones seleccionadas y asistencia durante el viaje.',
    'Boletos aéreos internacionales, gastos personales y servicios no indicados.',
    NULL,
    true,
    true
FROM public.destinos d
WHERE d.slug = 'europa'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viajes v
      WHERE v.slug = 'espana-portugal'
  );


INSERT INTO public.viajes (
    destino_id,
    nombre,
    slug,
    descripcion,
    duracion_dias,
    duracion_noches,
    precio_desde,
    moneda,
    incluye,
    no_incluye,
    imagen_url,
    destacado,
    activo
)
SELECT
    d.id,
    'Grecia Mediterránea',
    'grecia-mediterranea',
    'Descubre Atenas, las islas griegas y la esencia del Mediterráneo en un viaje diseñado para disfrutar cultura y descanso.',
    9,
    8,
    2995,
    'USD',
    'Alojamiento, traslados internos y excursiones seleccionadas.',
    'Boletos aéreos internacionales, gastos personales y servicios no indicados.',
    NULL,
    false,
    true
FROM public.destinos d
WHERE d.slug = 'europa'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viajes v
      WHERE v.slug = 'grecia-mediterranea'
  );


-- ------------------------------------------------------------
-- Caribe
-- ------------------------------------------------------------

INSERT INTO public.viajes (
    destino_id,
    nombre,
    slug,
    descripcion,
    duracion_dias,
    duracion_noches,
    precio_desde,
    moneda,
    incluye,
    no_incluye,
    imagen_url,
    destacado,
    activo
)
SELECT
    d.id,
    'Punta Cana Escape',
    'punta-cana-escape',
    'Una escapada al Caribe para disfrutar playas, descanso y experiencias tropicales.',
    6,
    5,
    1295,
    'USD',
    'Alojamiento, alimentación según plan seleccionado y traslados.',
    'Boletos aéreos, gastos personales y excursiones no indicadas.',
    NULL,
    true,
    true
FROM public.destinos d
WHERE d.slug = 'caribe'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viajes v
      WHERE v.slug = 'punta-cana-escape'
  );


INSERT INTO public.viajes (
    destino_id,
    nombre,
    slug,
    descripcion,
    duracion_dias,
    duracion_noches,
    precio_desde,
    moneda,
    incluye,
    no_incluye,
    imagen_url,
    destacado,
    activo
)
SELECT
    d.id,
    'Caribe Premium',
    'caribe-premium',
    'Una experiencia de descanso en el Caribe con alojamiento premium y opciones para disfrutar en pareja o familia.',
    7,
    6,
    1695,
    'USD',
    'Alojamiento, alimentación según plan y traslados.',
    'Boletos aéreos, gastos personales y servicios no indicados.',
    NULL,
    false,
    true
FROM public.destinos d
WHERE d.slug = 'caribe'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viajes v
      WHERE v.slug = 'caribe-premium'
  );


-- ------------------------------------------------------------
-- Asia
-- ------------------------------------------------------------

INSERT INTO public.viajes (
    destino_id,
    nombre,
    slug,
    descripcion,
    duracion_dias,
    duracion_noches,
    precio_desde,
    moneda,
    incluye,
    no_incluye,
    imagen_url,
    destacado,
    activo
)
SELECT
    d.id,
    'Japón Tradicional',
    'japon-tradicional',
    'Una inmersión en Japón combinando Tokio, Kioto y experiencias que muestran la tradición y modernidad del país.',
    11,
    10,
    3895,
    'USD',
    'Alojamiento, traslados internos y experiencias seleccionadas.',
    'Boletos aéreos internacionales, gastos personales y servicios no indicados.',
    NULL,
    true,
    true
FROM public.destinos d
WHERE d.slug = 'asia'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viajes v
      WHERE v.slug = 'japon-tradicional'
  );


INSERT INTO public.viajes (
    destino_id,
    nombre,
    slug,
    descripcion,
    duracion_dias,
    duracion_noches,
    precio_desde,
    moneda,
    incluye,
    no_incluye,
    imagen_url,
    destacado,
    activo
)
SELECT
    d.id,
    'Tailandia Esencial',
    'tailandia-esencial',
    'Explora Bangkok, templos, mercados y playas tropicales en una experiencia que combina cultura y naturaleza.',
    10,
    9,
    2795,
    'USD',
    'Alojamiento, traslados y excursiones seleccionadas.',
    'Boletos aéreos internacionales, gastos personales y servicios no indicados.',
    NULL,
    false,
    true
FROM public.destinos d
WHERE d.slug = 'asia'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viajes v
      WHERE v.slug = 'tailandia-esencial'
  );


-- ------------------------------------------------------------
-- América
-- ------------------------------------------------------------

INSERT INTO public.viajes (
    destino_id,
    nombre,
    slug,
    descripcion,
    duracion_dias,
    duracion_noches,
    precio_desde,
    moneda,
    incluye,
    no_incluye,
    imagen_url,
    destacado,
    activo
)
SELECT
    d.id,
    'Patagonia Inolvidable',
    'patagonia-inolvidable',
    'Una aventura por paisajes espectaculares de la Patagonia combinando naturaleza, aventura y experiencias únicas.',
    9,
    8,
    2495,
    'USD',
    'Alojamiento, traslados y excursiones seleccionadas.',
    'Boletos aéreos internacionales, gastos personales y servicios no indicados.',
    NULL,
    true,
    true
FROM public.destinos d
WHERE d.slug = 'america'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viajes v
      WHERE v.slug = 'patagonia-inolvidable'
  );


INSERT INTO public.viajes (
    destino_id,
    nombre,
    slug,
    descripcion,
    duracion_dias,
    duracion_noches,
    precio_desde,
    moneda,
    incluye,
    no_incluye,
    imagen_url,
    destacado,
    activo
)
SELECT
    d.id,
    'México Cultural',
    'mexico-cultural',
    'Descubre ciudades históricas, gastronomía y cultura mexicana en un recorrido lleno de experiencias.',
    8,
    7,
    1795,
    'USD',
    'Alojamiento, traslados y visitas seleccionadas.',
    'Boletos aéreos internacionales, gastos personales y servicios no indicados.',
    NULL,
    false,
    true
FROM public.destinos d
WHERE d.slug = 'america'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viajes v
      WHERE v.slug = 'mexico-cultural'
  );


-- ------------------------------------------------------------
-- África
-- ------------------------------------------------------------

INSERT INTO public.viajes (
    destino_id,
    nombre,
    slug,
    descripcion,
    duracion_dias,
    duracion_noches,
    precio_desde,
    moneda,
    incluye,
    no_incluye,
    imagen_url,
    destacado,
    activo
)
SELECT
    d.id,
    'Safari en Kenia',
    'safari-en-kenia',
    'Una experiencia de aventura y naturaleza para descubrir la vida silvestre de Kenia.',
    9,
    8,
    3295,
    'USD',
    'Alojamiento, traslados, safari y experiencias seleccionadas.',
    'Boletos aéreos internacionales, gastos personales y servicios no indicados.',
    NULL,
    true,
    true
FROM public.destinos d
WHERE d.slug = 'africa'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viajes v
      WHERE v.slug = 'safari-en-kenia'
  );


-- ------------------------------------------------------------
-- Medio Oriente
-- ------------------------------------------------------------

INSERT INTO public.viajes (
    destino_id,
    nombre,
    slug,
    descripcion,
    duracion_dias,
    duracion_noches,
    precio_desde,
    moneda,
    incluye,
    no_incluye,
    imagen_url,
    destacado,
    activo
)
SELECT
    d.id,
    'Dubái y Abu Dabi',
    'dubai-abu-dabi',
    'Descubre arquitectura, cultura, gastronomía y experiencias extraordinarias en Emiratos Árabes Unidos.',
    7,
    6,
    2395,
    'USD',
    'Alojamiento, traslados y visitas seleccionadas.',
    'Boletos aéreos internacionales, gastos personales y servicios no indicados.',
    NULL,
    true,
    true
FROM public.destinos d
WHERE d.slug = 'medio-oriente'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viajes v
      WHERE v.slug = 'dubai-abu-dabi'
  );