-- ============================================================
-- V16 - TURQUÍA EN OFERTA
-- Fuente: galeriadeviajes.com
-- URL: https://www.galeriadeviajes.com/es/packets/turquia-en-oferta
--
-- Fuente:
-- 10 días | 8 noches
-- Salidas desde América: viernes y sábado, todo el año
-- Datos históricos publicados para 2022
--
-- IMPORTANTE:
-- La fuente no publica precio.
-- La fuente no publica nombres concretos de hoteles.
-- Se conservan las categorías hoteleras publicadas.
-- ============================================================

DO $$
DECLARE
    v_destino_id UUID;
    v_viaje_id UUID;
BEGIN

    -- ========================================================
    -- DESTINO
    -- ========================================================

    SELECT id
    INTO v_destino_id
    FROM public.destinos
    WHERE slug = 'medio-oriente'
    LIMIT 1;

    IF v_destino_id IS NULL THEN
        SELECT id
        INTO v_destino_id
        FROM public.destinos
        WHERE slug = 'medio-oriente'
        LIMIT 1;
    END IF;

    IF v_destino_id IS NULL THEN
        RAISE EXCEPTION 'No existe el destino Medio Oriente. Verificar catálogo de destinos.';
    END IF;


    -- ========================================================
    -- VIAJE
    -- ========================================================

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
    VALUES (
        v_destino_id,
        'Turquía en Oferta',
        'turquia-en-oferta',
        'Circuito de 10 días y 8 noches por Estambul, Ankara, Capadocia, Konya, Pamukkale, Éfeso, zona de Izmir y Bursa, con regreso a Estambul.',
        10,
        8,
        NULL,
        'USD',
        '03 noches en Estambul en hoteles de 4*. 03 noches en Capadocia en hoteles de 4*/5*. 01 noche en Pamukkale en hoteles de 4*/5*. 01 noche en la zona de Izmir en hoteles de 4*/5*. Visitas en Ankara, Konya, Pamukkale, Éfeso y zona Izmir. Tour Capadocia oculta y tour Capadocia Fantástica. Traslados en todo el recorrido. 8 desayunos y 5 cenas sin bebidas. Visitas según itinerario con guía de habla hispana.',
        'Tarifa aérea América-Estambul-América. Gastos personales. Ningún servicio no mencionado en el apartado incluye. Cuota de servicio obligatoria de USD 50 por persona, pagadera en destino. Traslados que no se especifiquen en itinerario. Tours opcionales, actividades ni alimentos durante los días libres. Ningún servicio que no esté especificado. Propinas voluntarias.',
        NULL,
        TRUE,
        TRUE
    )
    ON CONFLICT (slug)
    DO UPDATE SET
        destino_id = EXCLUDED.destino_id,
        nombre = EXCLUDED.nombre,
        descripcion = EXCLUDED.descripcion,
        duracion_dias = EXCLUDED.duracion_dias,
        duracion_noches = EXCLUDED.duracion_noches,
        precio_desde = EXCLUDED.precio_desde,
        moneda = EXCLUDED.moneda,
        incluye = EXCLUDED.incluye,
        no_incluye = EXCLUDED.no_incluye,
        imagen_url = EXCLUDED.imagen_url,
        destacado = EXCLUDED.destacado,
        activo = EXCLUDED.activo
    RETURNING id INTO v_viaje_id;


    -- ========================================================
    -- LIMPIEZA DE DETALLE
    -- ========================================================

    DELETE FROM public.viaje_opcion_items
    WHERE opcion_id IN (
        SELECT id
        FROM public.viaje_opciones
        WHERE viaje_id = v_viaje_id
    );

    DELETE FROM public.viaje_itinerario
    WHERE viaje_id = v_viaje_id;

    DELETE FROM public.viaje_hoteles
    WHERE viaje_id = v_viaje_id;

    DELETE FROM public.viaje_inclusiones
    WHERE viaje_id = v_viaje_id;

    DELETE FROM public.viaje_exclusiones
    WHERE viaje_id = v_viaje_id;

    DELETE FROM public.viaje_salidas
    WHERE viaje_id = v_viaje_id;

    DELETE FROM public.viaje_opciones
    WHERE viaje_id = v_viaje_id;


    -- ========================================================
    -- ITINERARIO
    -- ========================================================

    INSERT INTO public.viaje_itinerario (
        viaje_id,
        dia_numero,
        dia_semana,
        titulo,
        ciudad_origen,
        ciudad_destino,
        descripcion,
        orden
    )
    VALUES

    (
        v_viaje_id,
        1,
        NULL,
        'América – Estambul',
        'América',
        'Estambul',
        'Salida en vuelo internacional hacia Estambul. El vuelo no está incluido.',
        1
    ),

    (
        v_viaje_id,
        2,
        NULL,
        'Estambul',
        'Estambul',
        'Estambul',
        'Llegada al aeropuerto de Estambul. Recepción por personal del equipo y traslado al hotel. Tiempo libre para descanso o actividades personales. Alojamiento.',
        2
    ),

    (
        v_viaje_id,
        3,
        NULL,
        'Estambul',
        'Estambul',
        'Estambul',
        'Desayuno. Día libre para actividades personales. La fuente propone tours opcionales: Estambul Clásico, Estambul Bósforo y Estambul Bohemio, con guías y explicaciones en español.',
        3
    ),

    (
        v_viaje_id,
        4,
        NULL,
        'Estambul – Ankara – Capadocia',
        'Estambul',
        'Capadocia',
        'Desayuno. Salida hacia Ankara pasando por las montañas de Bolu. Visita del Mausoleo de Atatürk. Continuación hacia Capadocia pasando por el lago Salado. Llegada al hotel, cena y alojamiento.',
        4
    ),

    (
        v_viaje_id,
        5,
        NULL,
        'Capadocia',
        'Capadocia',
        'Capadocia',
        'Desayuno y visita de la región. Museo al aire libre de Göreme, valles de Avcilar y Güvercinlik, y talleres de alfombras, ónix y turquesas. Cena y alojamiento. Opcionales: globo, safari 4x4 y noche turca.',
        5
    ),

    (
        v_viaje_id,
        6,
        NULL,
        'Capadocia',
        'Capadocia',
        'Capadocia',
        'Desayuno. Visita de la ciudad subterránea de Özkonak o Mazı, Çavusin, valle de Pasabag, valle de Uçhisar y Valle de Amor. Cena y alojamiento.',
        6
    ),

    (
        v_viaje_id,
        7,
        NULL,
        'Capadocia – Konya – Pamukkale',
        'Capadocia',
        'Pamukkale',
        'Desayuno. Salida hacia Konya. Visita de una posada medieval de la Ruta de Seda. Continuación hacia Pamukkale y llegada a la zona de las cascadas blancas, estalactitas y piscinas naturales termales. Cena y alojamiento.',
        7
    ),

    (
        v_viaje_id,
        8,
        NULL,
        'Pamukkale – Éfeso – Zona Izmir',
        'Pamukkale',
        'Zona Izmir',
        'Desayuno. Visita de Pamukkale y Hierápolis. Salida hacia Éfeso, visita de los vestigios arqueológicos, templo de Adriano y biblioteca de Celso. Visita de la Casa de la Virgen María y centro de productos de piel. Traslado al hotel, cena y alojamiento.',
        8
    ),

    (
        v_viaje_id,
        9,
        NULL,
        'Zona Izmir – Bursa – Estambul',
        'Zona Izmir',
        'Estambul',
        'Desayuno y salida hacia Bursa, primera capital de los otomanos. Visita de la Mezquita Verde, Mausoleo Verde y Bazar de Seda. Continuación hacia Estambul cruzando la bahía de Izmir por ferry o puente. Llegada al hotel y alojamiento.',
        9
    ),

    (
        v_viaje_id,
        10,
        NULL,
        'Estambul',
        'Estambul',
        'América',
        'Desayuno. A la hora indicada, traslado al aeropuerto. Fin de nuestros servicios.',
        10
    );


    -- ========================================================
    -- HOTELES
    -- La fuente no publica nombres concretos.
    -- Se conserva la categoría hotelera publicada.
    -- ========================================================

    INSERT INTO public.viaje_hoteles (
        viaje_id,
        orden,
        ciudad,
        nombre_hotel,
        categoria
    )
    VALUES
    (
        v_viaje_id,
        1,
        'Estambul',
        'Hoteles 4*',
        '4*'
    ),
    (
        v_viaje_id,
        2,
        'Capadocia',
        'Hoteles 4*/5*',
        '4*/5*'
    ),
    (
        v_viaje_id,
        3,
        'Pamukkale',
        'Hoteles 4*/5*',
        '4*/5*'
    ),
    (
        v_viaje_id,
        4,
        'Zona Izmir',
        'Hoteles 4*/5*',
        '4*/5*'
    );


    -- ========================================================
    -- INCLUYE
    -- ========================================================

    INSERT INTO public.viaje_inclusiones (
        viaje_id,
        orden,
        descripcion
    )
    VALUES
    (
        v_viaje_id,
        1,
        '03 noches en Estambul en hoteles de 4*.'
    ),
    (
        v_viaje_id,
        2,
        '03 noches en Capadocia en hoteles de 4*/5*.'
    ),
    (
        v_viaje_id,
        3,
        '01 noche en Pamukkale en hoteles de 4*/5*.'
    ),
    (
        v_viaje_id,
        4,
        '01 noche en la zona de Izmir en hoteles de 4*/5*.'
    ),
    (
        v_viaje_id,
        5,
        'Visitas en Ankara, Konya, Pamukkale, Éfeso y zona Izmir. Tour Capadocia oculta y tour Capadocia Fantástica. Traslados en todo el recorrido.'
    ),
    (
        v_viaje_id,
        6,
        '8 desayunos y 5 cenas sin bebidas. Visitas según itinerario con guía de habla hispana.'
    );


    -- ========================================================
    -- NO INCLUYE
    -- ========================================================

    INSERT INTO public.viaje_exclusiones (
        viaje_id,
        orden,
        descripcion
    )
    VALUES
    (
        v_viaje_id,
        1,
        'Tarifa aérea América-Estambul-América.'
    ),
    (
        v_viaje_id,
        2,
        'Gastos personales.'
    ),
    (
        v_viaje_id,
        3,
        'Ningún servicio no mencionado en el apartado “incluye”.'
    ),
    (
        v_viaje_id,
        4,
        'Cuota de servicio obligatoria de USD 50 por persona, pagadera en destino.'
    ),
    (
        v_viaje_id,
        5,
        'Traslados que no se especifiquen en el itinerario.'
    ),
    (
        v_viaje_id,
        6,
        'Tours opcionales, actividades ni alimentos durante los días libres.'
    ),
    (
        v_viaje_id,
        7,
        'Ningún servicio que no esté especificado.'
    ),
    (
        v_viaje_id,
        8,
        'Propinas voluntarias.'
    );


    -- ========================================================
    -- SALIDAS
    -- ========================================================

    INSERT INTO public.viaje_salidas (
        viaje_id,
        fecha_inicio,
        fecha_fin,
        texto_original,
        observaciones,
        activo
    )
    VALUES
    (
        v_viaje_id,
        NULL,
        NULL,
        'Viernes y sábado, todo el año',
        'La fuente corresponde a un programa publicado para 2022. Se conserva como información histórica/comercial.',
        TRUE
    );


    -- ========================================================
    -- VALIDACIÓN INTERNA
    -- ========================================================

    IF (
        SELECT COUNT(*)
        FROM public.viaje_itinerario
        WHERE viaje_id = v_viaje_id
    ) <> 10 THEN
        RAISE EXCEPTION 'V16: cantidad de itinerarios incorrecta.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_hoteles
        WHERE viaje_id = v_viaje_id
    ) <> 4 THEN
        RAISE EXCEPTION 'V16: cantidad de hoteles incorrecta.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_inclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 6 THEN
        RAISE EXCEPTION 'V16: cantidad de inclusiones incorrecta.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_exclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 8 THEN
        RAISE EXCEPTION 'V16: cantidad de exclusiones incorrecta.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_salidas
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'V16: cantidad de salidas incorrecta.';
    END IF;

END $$;

