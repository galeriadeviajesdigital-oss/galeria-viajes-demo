-- ============================================================
-- Galeria de Viajes
-- Migracion V5
-- Contenido comercial: MARAVILLAS DE EUROPA
-- ============================================================

-- ============================================================
-- 1. VIAJE PRINCIPAL
-- ============================================================

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
    'Maravillas de Europa',
    'maravillas-de-europa',
    'Programa europeo que visita Amsterdam, Berlin, Dresden, Praga, Bratislava, Budapest, Viena, Salzburgo, Zurich, Neuschwanstein, Munich, Nuremberg y Frankfurt. La fuente original presenta distintas variantes comerciales de duracion y recorrido. En el encabezado del programa se indica Frankfurt | Paris: 17 dias | 15 noches y Frankfurt | Viena: 12 dias | 10 noches; el itinerario detallado disponible comienza en Amsterdam y finaliza en Frankfurt, con una variante que termina en Viena y otra en Munich.',
    NULL,
    NULL,
    NULL,
    'USD',
    'Transporte europeo con Wi-Fi y conductores experimentados; guia acompanante; traslados aeropuerto/hotel; alojamiento con desayuno buffet en hoteles indicados o similares de categoria superior; tasas turisticas en las ciudades donde se pernocta; guias locales para las visitas indicadas; asistencia de viaje Trabax; bolsa de viaje.',
    NULL,
    NULL,
    TRUE,
    TRUE
FROM public.destinos d
WHERE d.slug = 'europa'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viajes v
      WHERE v.slug = 'maravillas-de-europa'
  );


-- ============================================================
-- 2. ITINERARIO
-- ============================================================

INSERT INTO public.viaje_itinerario (
    viaje_id,
    dia_numero,
    dia_semana,
    titulo,
    ciudad_origen,
    ciudad_destino,
    distancia_km,
    descripcion,
    alojamiento,
    orden
)
SELECT
    v.id,
    x.dia_numero,
    x.dia_semana,
    x.titulo,
    x.ciudad_origen,
    x.ciudad_destino,
    x.distancia_km,
    x.descripcion,
    x.alojamiento,
    x.dia_numero
FROM public.viajes v
CROSS JOIN (
    VALUES
    (
        1,
        NULL,
        'America',
        'America',
        'Amsterdam',
        NULL,
        'Vuelo intercontinental con destino a Amsterdam.',
        NULL
    ),
    (
        2,
        NULL,
        'Amsterdam',
        'Amsterdam',
        'Amsterdam',
        NULL,
        'Llegada a Amsterdam. Traslado al hotel y tiempo libre. Alojamiento.',
        'Amsterdam'
    ),
    (
        3,
        NULL,
        'Amsterdam',
        'Amsterdam',
        'Amsterdam',
        NULL,
        'Visita de los canales, monumentos y principales iglesias de la ciudad, ademas del antiguo puerto y una fabrica de diamantes. Opcionalmente se puede realizar la excursion a Volendam y Marken con almuerzo, incluida en el Europack.',
        'Amsterdam'
    ),
    (
        4,
        NULL,
        'Amsterdam / Berlin',
        'Amsterdam',
        'Berlin',
        655,
        'Salida desde Amsterdam con destino a Berlin. Recorrido por carretera de aproximadamente 655 km.',
        'Berlin'
    ),
    (
        5,
        NULL,
        'Berlin',
        'Berlin',
        'Berlin',
        NULL,
        'Visita panoramica de Berlin. Opcionalmente se ofrece almuerzo incluido en el Europack y excursion a Potsdam y Sanssouci incluida en el Europack.',
        'Berlin'
    ),
    (
        6,
        NULL,
        'Berlin / Dresden / Prague',
        'Berlin',
        'Prague',
        340,
        'Salida de Berlin hacia Dresden y continuacion hacia Praga. Recorrido aproximado de 340 km.',
        'Prague'
    ),
    (
        7,
        NULL,
        'Prague',
        'Prague',
        'Prague',
        NULL,
        'Visita panoramica de Praga. Opcionalmente se ofrece almuerzo en restaurante tipico incluido en el Europack y visita al Castillo de Praga y San Vito.',
        'Prague'
    ),
    (
        8,
        NULL,
        'Prague / Bratislava / Budapest',
        'Prague',
        'Budapest',
        529,
        'Salida de Praga hacia Bratislava y continuacion a Budapest. Recorrido aproximado de 529 km. Opcionalmente se ofrece cena hungara incluida en el Europack.',
        'Budapest'
    ),
    (
        9,
        NULL,
        'Budapest',
        'Budapest',
        'Budapest',
        NULL,
        'Visita panoramica de Budapest.',
        'Budapest'
    ),
    (
        10,
        NULL,
        'Budapest / Vienna',
        'Budapest',
        'Vienna',
        243,
        'Salida de Budapest hacia Viena. Recorrido aproximado de 243 km. Opcionalmente se ofrece cena austriaca con espectaculo incluida en el Europack.',
        'Vienna'
    ),
    (
        11,
        NULL,
        'Vienna',
        'Vienna',
        'Vienna',
        NULL,
        'Visita panoramica de Viena.',
        'Vienna'
    ),
    (
        12,
        NULL,
        'Vienna / Salzburg / Zurich',
        'Vienna',
        'Zurich',
        774,
        'Salida de Viena hacia Salzburgo y continuacion a Zurich. Recorrido aproximado de 774 km. Para los pasajeros que finalizan el programa en Viena, tiempo libre hasta el traslado al aeropuerto.',
        'Zurich'
    ),
    (
        13,
        NULL,
        'Zurich / Neuschwanstein / Munich',
        'Zurich',
        'Munich',
        360,
        'Salida de Zurich hacia Neuschwanstein y continuacion a Munich. Recorrido aproximado de 360 km.',
        'Munich'
    ),
    (
        14,
        NULL,
        'Munich',
        'Munich',
        'Munich',
        NULL,
        'Visita panoramica de Munich. Opcionalmente se ofrece cena en una cerveceria tipica.',
        'Munich'
    ),
    (
        15,
        NULL,
        'Munich / Nuremberg / Frankfurt',
        'Munich',
        'Frankfurt',
        392,
        'Salida de Munich hacia Nuremberg y continuacion a Frankfurt. Recorrido aproximado de 392 km. Para los pasajeros que finalizan el programa en Munich, tiempo libre hasta el traslado al aeropuerto.',
        'Frankfurt'
    ),
    (
        16,
        NULL,
        'Frankfurt',
        'Frankfurt',
        'Frankfurt',
        NULL,
        'Tiempo libre hasta el traslado al aeropuerto.',
        'Frankfurt'
    )
) AS x(
    dia_numero,
    dia_semana,
    titulo,
    ciudad_origen,
    ciudad_destino,
    distancia_km,
    descripcion,
    alojamiento
)
WHERE v.slug = 'maravillas-de-europa'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viaje_itinerario i
      WHERE i.viaje_id = v.id
        AND i.dia_numero = x.dia_numero
  );


-- ============================================================
-- 3. HOTELES
-- ============================================================

INSERT INTO public.viaje_hoteles (
    viaje_id,
    ciudad,
    nombre_hotel,
    categoria,
    observaciones,
    orden
)
SELECT
    v.id,
    x.ciudad,
    x.nombre_hotel,
    'Categoria superior',
    x.observaciones,
    x.orden
FROM public.viajes v
CROSS JOIN (
    VALUES
    ('Amsterdam', 'Moxy Amsterdam Airport', 'Hotel indicado en el programa original.', 1),
    ('Amsterdam', 'NH Amsterdam Zuid', 'Hotel indicado en el programa original como alternativa.', 2),
    ('Berlin', 'Hampton By Hilton Berlin City East Side Gallery', 'Hotel indicado en el programa original.', 3),
    ('Prague', 'Don Giovanni', 'Hotel indicado en el programa original.', 4),
    ('Budapest', 'Intercity Hotel Budapest', 'Hotel indicado en el programa original.', 5),
    ('Vienna', 'Senator', 'Hotel indicado en el programa original.', 6),
    ('Zurich', 'Courtyard By Marriott Zurich North', 'Hotel indicado en el programa original.', 7),
    ('Zurich', 'A-ja Zurich Das City-Resort', 'Hotel indicado en el programa original como alternativa.', 8),
    ('Munich', 'Achat Hotel Munchen Sud', 'Hotel indicado en el programa original.', 9),
    ('Munich', 'Achat Hotel Schreiberhof Munchen', 'Hotel indicado en el programa original como alternativa.', 10),
    ('Frankfurt', 'Holiday Inn Express Frankfurt Messe', 'Hotel indicado en el programa original.', 11)
) AS x(
    ciudad,
    nombre_hotel,
    observaciones,
    orden
)
WHERE v.slug = 'maravillas-de-europa'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viaje_hoteles h
      WHERE h.viaje_id = v.id
        AND h.ciudad = x.ciudad
        AND h.nombre_hotel = x.nombre_hotel
  );


-- ============================================================
-- 4. INCLUSIONES
-- ============================================================

INSERT INTO public.viaje_inclusiones (
    viaje_id,
    descripcion,
    orden
)
SELECT
    v.id,
    x.descripcion,
    x.orden
FROM public.viajes v
CROSS JOIN (
    VALUES
    ('Transporte europeo con Wi-Fi y conductores experimentados.', 1),
    ('Guia acompanante.', 2),
    ('Traslados aeropuerto / hotel.', 3),
    ('Alojamiento y desayuno buffet en los hoteles indicados o similares de categoria superior.', 4),
    ('Tasas turisticas en las ciudades donde se pernocta.', 5),
    ('Guias locales para las visitas indicadas.', 6),
    ('Asistencia de viaje Trabax.', 7),
    ('Bolsa de viaje.', 8)
) AS x(
    descripcion,
    orden
)
WHERE v.slug = 'maravillas-de-europa'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viaje_inclusiones i
      WHERE i.viaje_id = v.id
        AND i.descripcion = x.descripcion
  );


-- ============================================================
-- 5. EXCLUSIONES
-- ============================================================
-- No se cargan porque la fuente no proporciona una lista
-- explicita de exclusiones.


-- ============================================================
-- 6. OPCIONES COMERCIALES / EUROPACK
-- ============================================================

INSERT INTO public.viaje_opciones (
    viaje_id,
    nombre,
    descripcion,
    duracion_dias,
    duracion_noches,
    precio,
    moneda,
    activo,
    orden
)
SELECT
    v.id,
    x.nombre,
    x.descripcion,
    x.duracion_dias,
    x.duracion_noches,
    x.precio,
    'USD',
    TRUE,
    x.orden
FROM public.viajes v
CROSS JOIN (
    VALUES
    (
        'Europack Amsterdam / Frankfurt',
        'Europack para la ruta Amsterdam / Frankfurt. Incluye 5 comidas y 2 visitas.',
        16,
        NULL::integer,
        275.00::numeric,
        1
    ),
    (
        'Europack Amsterdam / Munich',
        'Europack para la ruta Amsterdam / Munich. Incluye 5 comidas y 2 visitas.',
        15,
        NULL::integer,
        275.00::numeric,
        2
    ),
    (
        'Europack Amsterdam / Vienna',
        'Europack para la ruta Amsterdam / Vienna. Incluye 5 comidas y 2 visitas.',
        12,
        NULL::integer,
        275.00::numeric,
        3
    )
) AS x(
    nombre,
    descripcion,
    duracion_dias,
    duracion_noches,
    precio,
    orden
)
WHERE v.slug = 'maravillas-de-europa'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viaje_opciones o
      WHERE o.viaje_id = v.id
        AND o.nombre = x.nombre
  );


-- ============================================================
-- 7. ITEMS DEL EUROPACK
-- ============================================================

INSERT INTO public.viaje_opcion_items (
    opcion_id,
    tipo,
    descripcion,
    orden
)
SELECT
    o.id,
    x.tipo,
    x.descripcion,
    x.orden
FROM public.viaje_opciones o
CROSS JOIN (
    VALUES
    ('COMIDA', 'Almuerzo en Volendam.', 1),
    ('COMIDA', 'Almuerzo en Berlin.', 2),
    ('COMIDA', 'Almuerzo tipico en Praga.', 3),
    ('COMIDA', 'Cena tipica en Budapest.', 4),
    ('COMIDA', 'Cena y espectaculo en Viena.', 5),
    ('VISITA', 'Volendam y Marken.', 6),
    ('VISITA', 'Potsdam y Sanssouci.', 7)
) AS x(
    tipo,
    descripcion,
    orden
)
WHERE o.nombre IN (
    'Europack Amsterdam / Frankfurt',
    'Europack Amsterdam / Munich',
    'Europack Amsterdam / Vienna'
)
AND NOT EXISTS (
    SELECT 1
    FROM public.viaje_opcion_items oi
    WHERE oi.opcion_id = o.id
      AND oi.descripcion = x.descripcion
);


-- ============================================================
-- 8. SALIDA
-- ============================================================

INSERT INTO public.viaje_salidas (
    viaje_id,
    fecha_inicio,
    fecha_fin,
    texto_original,
    observaciones,
    activo
)
SELECT
    v.id,
    NULL,
    NULL,
    'Febrero 16 - Marzo 16',
    'El material original no especifica el ano de la salida.',
    TRUE
FROM public.viajes v
WHERE v.slug = 'maravillas-de-europa'
  AND NOT EXISTS (
      SELECT 1
      FROM public.viaje_salidas s
      WHERE s.viaje_id = v.id
        AND s.texto_original = 'Febrero 16 - Marzo 16'
  );


-- ============================================================
-- 9. VALIDACION INTERNA
-- ============================================================

DO $$
DECLARE
    v_viaje_id UUID;
    v_itinerario INTEGER;
    v_hoteles INTEGER;
    v_inclusiones INTEGER;
    v_opciones INTEGER;
    v_opcion_items INTEGER;
    v_salidas INTEGER;
BEGIN

    SELECT id
    INTO v_viaje_id
    FROM public.viajes
    WHERE slug = 'maravillas-de-europa';

    IF v_viaje_id IS NULL THEN
        RAISE EXCEPTION
            'No se encontro el viaje maravillas-de-europa.';
    END IF;

    SELECT COUNT(*)
    INTO v_itinerario
    FROM public.viaje_itinerario
    WHERE viaje_id = v_viaje_id;

    SELECT COUNT(*)
    INTO v_hoteles
    FROM public.viaje_hoteles
    WHERE viaje_id = v_viaje_id;

    SELECT COUNT(*)
    INTO v_inclusiones
    FROM public.viaje_inclusiones
    WHERE viaje_id = v_viaje_id;

    SELECT COUNT(*)
    INTO v_opciones
    FROM public.viaje_opciones
    WHERE viaje_id = v_viaje_id;

    SELECT COUNT(*)
    INTO v_opcion_items
    FROM public.viaje_opcion_items oi
    INNER JOIN public.viaje_opciones o
        ON o.id = oi.opcion_id
    WHERE o.viaje_id = v_viaje_id;

    SELECT COUNT(*)
    INTO v_salidas
    FROM public.viaje_salidas
    WHERE viaje_id = v_viaje_id;

    IF v_itinerario <> 16 THEN
        RAISE EXCEPTION
            'Se esperaban 16 dias de itinerario y se encontraron %.',
            v_itinerario;
    END IF;

    IF v_hoteles <> 11 THEN
        RAISE EXCEPTION
            'Se esperaban 11 registros de hoteles y se encontraron %.',
            v_hoteles;
    END IF;

    IF v_inclusiones <> 8 THEN
        RAISE EXCEPTION
            'Se esperaban 8 inclusiones y se encontraron %.',
            v_inclusiones;
    END IF;

    IF v_opciones <> 3 THEN
        RAISE EXCEPTION
            'Se esperaban 3 opciones Europack y se encontraron %.',
            v_opciones;
    END IF;

    IF v_opcion_items <> 21 THEN
        RAISE EXCEPTION
            'Se esperaban 21 items Europack y se encontraron %.',
            v_opcion_items;
    END IF;

    IF v_salidas <> 1 THEN
        RAISE EXCEPTION
            'Se esperaba 1 registro de salida y se encontraron %.',
            v_salidas;
    END IF;

    RAISE NOTICE
        'Maravillas de Europa cargado correctamente. Viaje: % | Itinerario: % | Hoteles: % | Inclusiones: % | Opciones: % | Items: % | Salidas: %',
        v_viaje_id,
        v_itinerario,
        v_hoteles,
        v_inclusiones,
        v_opciones,
        v_opcion_items,
        v_salidas;

END $$;