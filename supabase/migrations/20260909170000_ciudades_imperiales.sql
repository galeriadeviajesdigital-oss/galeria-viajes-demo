-- ============================================================
-- V9 - CIUDADES IMPERIALES
-- Fuente:
-- https://www.galeriadeviajes.com/es/packets/ciudades-imperiales-1
--
-- Datos histÃ³ricos preservados segÃºn fuente original.
-- No se corrigen discrepancias comerciales de la fuente.
-- ============================================================

DO $$
DECLARE
    v_destino_id UUID;
    v_viaje_id UUID;
    v_opcion_id UUID;
BEGIN

    -- ========================================================
    -- DESTINO
    -- ========================================================

    SELECT id
    INTO v_destino_id
    FROM public.destinos
    WHERE slug = 'europa'
    LIMIT 1;

    IF v_destino_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro el destino Europa';
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
        'Ciudades Imperiales',
        'ciudades-imperiales-1',
        'Circuito europeo con inicio en Berlin y recorrido por Berlin, Dresden, Praga, Bratislava, Budapest y Viena.',
        10,
        8,
        NULL,
        'USD',
        'Transporte durante todo el recorrido europeo; acompanamiento de guia correo; traslados de aeropuerto; alojamiento y desayuno; tasas turisticas; guias locales; seguro de asistencia Trabax; bolsa de viaje.',
        'Boletos aereos.',
        '/picture/image/0000/8243/medium_widescreen/1.CIUDADES-IMPERIALES-I-INSIDE.jpg',
        TRUE,
        TRUE
    )
    RETURNING id INTO v_viaje_id;


    -- ========================================================
    -- ITINERARIO
    -- ========================================================

    INSERT INTO public.viaje_itinerario
        (
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
    VALUES

    (
        v_viaje_id,
        1,
        'Sabado',
        'America',
        'America',
        'Berlin',
        NULL,
        'Salida en vuelo intercontinental con destino a Berlin.',
        NULL,
        1
    ),

    (
        v_viaje_id,
        2,
        'Domingo',
        'Berlin',
        'Berlin',
        'Berlin',
        NULL,
        'Llegada al aeropuerto y traslado al hotel. Dia libre.',
        'Berlin',
        2
    ),

    (
        v_viaje_id,
        3,
        'Lunes',
        'Berlin',
        'Berlin',
        'Berlin',
        NULL,
        'Desayuno buffet en el hotel. Por la manana visita panoramica de la ciudad con guia local para conocer los principales monumentos, calles y avenidas de esta importante ciudad, simbolo de la reunificacion: la puerta de Brandemburgo, la iglesia memorial del Kaiser Guillermo, el Reichstag y los restos del famoso muro que dividia la ciudad hasta 1989. Almuerzo opcional incluido en el Europack. Tarde libre para realizar opcionalmente una visita a la ciudad de Potsdam y los jardines del Palacio Sanssouci, residencia de verano de Federico II el Grande. Visita a Potsdam y Jardines del Palacio Sanssouci incluida en el Europack.',
        'Berlin',
        3
    ),

    (
        v_viaje_id,
        4,
        'Martes',
        'Berlin - Dresden - Praga',
        'Berlin',
        'Praga',
        340,
        'Desayuno buffet en el hotel. Salida hacia Dresden, la antigua capital de Sajonia, a orillas del rio Elba, que fue practicamente destruida durante los bombardeos en la II Guerra Mundial. Tiempo libre y continuacion hacia la Republica Checa para llegar a Praga.',
        'Praga',
        4
    ),

    (
        v_viaje_id,
        5,
        'Miercoles',
        'Praga',
        'Praga',
        'Praga',
        NULL,
        'Desayuno buffet en el hotel. Por la manana visita panoramica de la ciudad con guia local, recorriendo el pintoresco Barrio Pequeno Mala Strana, Iglesia de la Victoria del Nino Jesus de Praga, Puente de Carlos, Ciudad Vieja y su Reloj Astronomico. Almuerzo opcional en un tipico restaurante, incluido en el Europack. Tarde libre para realizar opcionalmente una visita al Castillo de Praga y Catedral de San Vito.',
        'Praga',
        5
    ),

    (
        v_viaje_id,
        6,
        'Jueves',
        'Praga - Bratislava - Budapest',
        'Praga',
        'Budapest',
        529,
        'Desayuno buffet en el hotel. Salida hacia Bratislava, capital de Eslovaquia. Breve parada. Continuacion del viaje hasta Budapest, capital de Hungria. Por la noche se ofrecera opcionalmente una cena hungara, incluida en el Europack.',
        'Budapest',
        6
    ),

    (
        v_viaje_id,
        7,
        'Viernes',
        'Budapest',
        'Budapest',
        'Budapest',
        NULL,
        'Desayuno buffet en el hotel. Visita panoramica de la ciudad con guia local. La ciudad se divide en dos zonas, Buda donde se encuentra la ciudad vieja y Pest, zona moderna comercial. Recorrido por la Colina del Castillo en Buda para contemplar el Danubio y toda la extension de Pest. Recorrido por el Barrio Antiguo, pasando por la Catedral de Matias y el Bastion de los Pescadores. Tarde libre para disfrutar de la ciudad.',
        'Budapest',
        7
    ),

    (
        v_viaje_id,
        8,
        'Sabado',
        'Budapest - Viena',
        'Budapest',
        'Viena',
        243,
        'Desayuno buffet. Salida en autobus hacia la capital de Austria donde llegaremos a primera hora de la tarde. Tarde libre. Por la noche se sugiere asistir opcionalmente a una cena con espectaculo musical austriaco donde no faltara el famoso vals vienes. Cena y espectaculo incluidos en el Europack.',
        'Viena',
        8
    ),

    (
        v_viaje_id,
        9,
        'Domingo',
        'Viena',
        'Viena',
        'Viena',
        NULL,
        'Desayuno buffet. Visita panoramica con guia local de la ciudad con la majestuosa Ringstrasse, el Danubio y sus diversos brazos y un paseo por el casco historico, incluyendo Albertina, Hofburg y Plaza de Maria Teresa. Tarde libre para seguir disfrutando de la ciudad.',
        'Viena',
        9
    ),

    (
        v_viaje_id,
        10,
        'Lunes',
        'Viena',
        'Viena',
        'Viena',
        NULL,
        'Desayuno buffet. Tiempo libre hasta la hora de realizar el traslado al aeropuerto para tomar el vuelo de regreso.',
        NULL,
        10
    );


    -- ========================================================
    -- HOTELES
    -- ========================================================

    INSERT INTO public.viaje_hoteles
        (
            viaje_id,
            ciudad,
            nombre_hotel,
            categoria,
            orden
        )
    VALUES
    (
        v_viaje_id,
        'Berlin',
        'Hampton By Hilton Berlin City East Side Gallery',
        'Primera',
        1
    ),
    (
        v_viaje_id,
        'Praga',
        'Don Giovanni',
        'Primera',
        2
    ),
    (
        v_viaje_id,
        'Budapest',
        'Holiday Inn Budaors',
        'Primera',
        3
    ),
    (
        v_viaje_id,
        'Viena',
        'Senator',
        'Primera',
        4
    );


    -- ========================================================
    -- INCLUSIONES
    -- ========================================================

    INSERT INTO public.viaje_inclusiones
        (
            viaje_id,
            descripcion,
            orden
        )
    VALUES
    (
        v_viaje_id,
        'Transporte durante todo el recorrido europeo en unidades de gran confort con WI-FI incluido y choferes experimentados.',
        1
    ),
    (
        v_viaje_id,
        'Acompanamiento de guia correo desde el inicio hasta el fin del circuito.',
        2
    ),
    (
        v_viaje_id,
        'Traslados de llegada y salida del aeropuerto al hotel y viceversa.',
        3
    ),
    (
        v_viaje_id,
        'Alojamiento y desayuno buffet en los hoteles indicados o de similar categoria Superior.',
        4
    ),
    (
        v_viaje_id,
        'Todas las tasas turisticas en las ciudades de pernocte.',
        5
    ),
    (
        v_viaje_id,
        'Guias locales para las visitas de las ciudades tal como se indica en el itinerario.',
        6
    ),
    (
        v_viaje_id,
        'Seguro de Asistencia Trabax.',
        7
    ),
    (
        v_viaje_id,
        'Bolsa de viaje.',
        8
    );


    -- ========================================================
    -- EXCLUSIONES
    -- ========================================================

    INSERT INTO public.viaje_exclusiones
        (
            viaje_id,
            descripcion,
            orden
        )
    VALUES
    (
        v_viaje_id,
        'Boletos aereos.',
        1
    );


    -- ========================================================
    -- EUROPACK
    --
    -- La fuente indica:
    -- BERLIN / VIENA
    -- 10 dias
    -- 4 comidas y 1 visita
    -- USD 210 por persona
    --
    -- La misma fuente muestra al final:
    -- 10 dias / 9 noches
    --
    -- Se conserva la discrepancia en descripcion.
    -- ========================================================

    INSERT INTO public.viaje_opciones
        (
            viaje_id,
            nombre,
            descripcion,
            duracion_dias,
            duracion_noches,
            precio,
            moneda,
            orden
        )
    VALUES
    (
        v_viaje_id,
        'Europack Berlin / Viena',
        'Europack Berlin / Viena. La fuente publica 10 dias, 4 comidas y 1 visita por USD 210. En el cierre de la pagina tambien aparece 10 dias / 9 noches.',
        10,
        9,
        210,
        'USD',
        1
    )
    RETURNING id INTO v_opcion_id;


    -- ========================================================
    -- ITEMS EUROPACK
    -- ========================================================

    INSERT INTO public.viaje_opcion_items
        (
            opcion_id,
            tipo,
            descripcion,
            orden
        )
    VALUES
    (
        v_opcion_id,
        'COMIDA',
        'Almuerzo en Berlin.',
        1
    ),
    (
        v_opcion_id,
        'COMIDA',
        'Almuerzo tipico en Praga.',
        2
    ),
    (
        v_opcion_id,
        'COMIDA',
        'Cena tipica en Budapest.',
        3
    ),
    (
        v_opcion_id,
        'COMIDA',
        'Cena y espectaculo en Viena.',
        4
    ),
    (
        v_opcion_id,
        'VISITA',
        'Visita a Potsdam y Jardines de Sanssouci.',
        5
    );


    -- ========================================================
    -- SALIDA
    -- ========================================================

    INSERT INTO public.viaje_salidas
        (
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
        '18 de febrero - 18 de marzo',
        'Salida publicada en la fuente original sin anio especificado.',
        TRUE
    );


    -- ========================================================
    -- VALIDACION INTERNA
    -- ========================================================

    IF (
        SELECT COUNT(*)
        FROM public.viaje_itinerario
        WHERE viaje_id = v_viaje_id
    ) <> 10 THEN
        RAISE EXCEPTION 'V9: cantidad de itinerarios incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_hoteles
        WHERE viaje_id = v_viaje_id
    ) <> 4 THEN
        RAISE EXCEPTION 'V9: cantidad de hoteles incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_inclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 8 THEN
        RAISE EXCEPTION 'V9: cantidad de inclusiones incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_exclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'V9: cantidad de exclusiones incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_opciones
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'V9: cantidad de opciones incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_opcion_items oi
        JOIN public.viaje_opciones o
            ON o.id = oi.opcion_id
        WHERE o.viaje_id = v_viaje_id
    ) <> 5 THEN
        RAISE EXCEPTION 'V9: cantidad de items de opcion incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_salidas
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'V9: cantidad de salidas incorrecta';
    END IF;


    RAISE NOTICE 'V9 CIUDADES IMPERIALES cargada correctamente.';
    RAISE NOTICE 'Viaje ID: %', v_viaje_id;
    RAISE NOTICE 'Itinerario: 10';
    RAISE NOTICE 'Hoteles: 4';
    RAISE NOTICE 'Inclusiones: 8';
    RAISE NOTICE 'Exclusiones: 1';
    RAISE NOTICE 'Opciones: 1';
    RAISE NOTICE 'Items opcion: 5';
    RAISE NOTICE 'Salidas: 1';

END $$;

