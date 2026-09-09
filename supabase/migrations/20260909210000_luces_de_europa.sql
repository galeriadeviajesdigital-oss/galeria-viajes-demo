-- ============================================================
-- V13 - LUCES DE EUROPA
-- Fuente:
-- https://www.galeriadeviajes.com/es/packets/luces-de-europa
--
-- Variante principal:
-- Londres -> Frankfurt
-- 12 días / 10 noches
--
-- Variante publicada:
-- Londres -> Amsterdam
-- 11 días / 9 noches
--
-- Se conserva la información de ambas variantes sin
-- inventar ni corregir fechas publicadas por la fuente.
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
        RAISE EXCEPTION 'No se encontró el destino Europa.';
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
        imagen_url,
        destacado,
        activo
    )
    VALUES (
        v_destino_id,
        'Luces de Europa',
        'luces-de-europa',
        'Circuito europeo con inicio en Londres o París y variantes de recorrido Londres / Frankfurt de 12 días y 10 noches, y Londres / Ámsterdam de 11 días y 9 noches. Visitando Londres, París, Mont Saint Michel, Caen, Bruselas, Brujas, Ámsterdam, Colonia, crucero por el Rhin y Frankfurt. La fuente original publica ambas variantes y sus respectivas condiciones comerciales.',
        12,
        10,
        NULL,
        'USD',
        NULL,
        TRUE,
        TRUE
    )
    ON CONFLICT (slug) DO UPDATE SET
        destino_id = EXCLUDED.destino_id,
        nombre = EXCLUDED.nombre,
        descripcion = EXCLUDED.descripcion,
        duracion_dias = EXCLUDED.duracion_dias,
        duracion_noches = EXCLUDED.duracion_noches,
        precio_desde = EXCLUDED.precio_desde,
        moneda = EXCLUDED.moneda,
        destacado = EXCLUDED.destacado,
        activo = EXCLUDED.activo
    RETURNING id INTO v_viaje_id;

    IF v_viaje_id IS NULL THEN
        SELECT id
        INTO v_viaje_id
        FROM public.viajes
        WHERE slug = 'luces-de-europa'
        LIMIT 1;
    END IF;


    -- ========================================================
    -- LIMPIEZA PARA IDEMPOTENCIA
    -- ========================================================

    DELETE FROM public.viaje_opcion_items
    WHERE opcion_id IN (
        SELECT id
        FROM public.viaje_opciones
        WHERE viaje_id = v_viaje_id
    );

    DELETE FROM public.viaje_opciones
    WHERE viaje_id = v_viaje_id;

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


    -- ========================================================
    -- ITINERARIO
    -- ========================================================

    INSERT INTO public.viaje_itinerario
        (viaje_id, dia_numero, titulo, descripcion, orden)
    VALUES
    (
        v_viaje_id,
        1,
        'América',
        'Salida en vuelo intercontinental con destino a Londres.',
        1
    ),
    (
        v_viaje_id,
        2,
        'Londres',
        'Llegada al aeropuerto y traslado al hotel. Día libre para pasear por la ciudad o hacer compras. Alojamiento.',
        2
    ),
    (
        v_viaje_id,
        3,
        'Londres',
        'Desayuno buffet. Visita panorámica de la ciudad con guía local recorriendo sus principales avenidas y monumentos, Piccadilly Circus, Oxford Street, Trafalgar Square, Abadía de Westminster y Palacio de Buckingham, donde se podrá asistir al cambio de guardia si se realiza ese día. Opcionalmente subida al London Eye. Tarde libre y alojamiento.',
        3
    ),
    (
        v_viaje_id,
        4,
        'Londres / París',
        'Desayuno buffet. Por la mañana salida hacia el Canal de la Mancha. Este tramo se podrá realizar en Ferry, Eurotúnel o Eurostar. Continuación hacia París, con llegada prevista a primera hora de la tarde. París, la Ciudad de la Luz. Alojamiento. Esta noche se recomienda una visita opcional a la Torre Eiffel y posteriormente una visita iluminada de París.',
        4
    ),
    (
        v_viaje_id,
        5,
        'París',
        'Desayuno buffet. Visita panorámica con guía local de la ciudad de París: la Ópera, el Museo de Orsay, la Plaza de la Concordia, los Campos Elíseos, el Arco del Triunfo, los Inválidos, etc. Opcionalmente paseo en barco por el río Sena a bordo de los Bateaux Parisiens. También se recomienda un almuerzo opcional en un bistró de Montmartre. Tarde libre y alojamiento.',
        5
    ),
    (
        v_viaje_id,
        6,
        'París',
        'Desayuno buffet. Día libre para seguir recorriendo esta bella ciudad. Se recomienda realizar opcionalmente una excursión a Versalles para visitar los Grandes Aposentos Reales, la Galería de los Espejos y los jardines de estilo francés. Tarde libre. Alojamiento.',
        6
    ),
    (
        v_viaje_id,
        7,
        'París / Mont Saint Michel / Caen',
        'Desayuno buffet. Salida hacia Mont Saint Michel. Tiempo libre para recorrer las callejuelas adoquinadas y visitar la abadía situada en la cima de la roca. Almuerzo libre. Continuación hasta Caen, con 1000 años de historia. Alojamiento.',
        7
    ),
    (
        v_viaje_id,
        8,
        'Caen / Bruselas / Brujas',
        'Desayuno buffet en el hotel. Salida hacia Bruselas, capital Europea. Tiempo libre para dar un paseo por la Grand Place y acercarse hasta el famoso Manneken Pis. Continuación hacia Brujas. Se recomienda opcionalmente navegar por sus canales, contemplar sus monumentos y relajarse en el lago del amor. Alojamiento.',
        8
    ),
    (
        v_viaje_id,
        9,
        'Brujas / Amsterdam',
        'Desayuno buffet en el hotel. Visita a pie con guía local por la ciudad de Brujas, con su impactante casco histórico medieval. Almuerzo opcional. Salida hacia Amsterdam. Alojamiento.',
        9
    ),
    (
        v_viaje_id,
        10,
        'Amsterdam',
        'Desayuno buffet. Visita de la Venecia del Norte a bordo de un barco por sus canales, admirando monumentos, iglesias y el puerto antiguo de la ciudad. La visita termina en una fábrica de talla de diamantes. Resto del día libre. Se sugiere excursión opcional a los pueblos pesqueros de Volendam y Marken con almuerzo. Alojamiento.',
        10
    ),
    (
        v_viaje_id,
        11,
        'Amsterdam / Colonia / Crucero por el Rhin / Frankfurt',
        'Desayuno buffet y salida hacia Colonia. Breve parada en esta ciudad, destacando su famosa Catedral. Continuación para embarcar en un crucero por el río Rhin, con vistas a la Roca de Loreley, castillos y viñedos. Desembarque y continuación hacia Frankfurt, capital financiera de Alemania y cuna de Goethe. Alojamiento. Para los pasajeros terminando en Ámsterdam, tiempo libre hasta la hora de realizar el traslado al aeropuerto para tomar el vuelo de regreso.',
        11
    ),
    (
        v_viaje_id,
        12,
        'Frankfurt',
        'Desayuno buffet. Tiempo libre hasta la hora de realizar el traslado al aeropuerto para tomar el vuelo de regreso.',
        12
    );


    -- ========================================================
    -- HOTELES PREVISTOS O SIMILARES
    -- ========================================================

    INSERT INTO public.viaje_hoteles
        (viaje_id, orden, ciudad, nombre_hotel, categoria)
    VALUES
    (
        v_viaje_id,
        1,
        'Londres',
        'Holiday Inn London West',
        'P'
    ),
    (
        v_viaje_id,
        2,
        'Paris',
        'Mercure Paris Porte de Pantin / Novotel Paris Est',
        'P'
    ),
    (
        v_viaje_id,
        3,
        'Caen',
        'Ibis Caen Porte D´Angleterre',
        'TS'
    ),
    (
        v_viaje_id,
        4,
        'Brujas',
        'Velotel',
        'P'
    ),
    (
        v_viaje_id,
        5,
        'Amsterdam',
        'NH Amsterdam Zuid / Moxy Amsterdam Airport',
        'P'
    ),
    (
        v_viaje_id,
        6,
        'Frankfurt',
        'Holiday Inn Express Frankfurt Messe',
        'TS'
    );


    -- ========================================================
    -- INCLUYE
    -- ========================================================

    INSERT INTO public.viaje_inclusiones
        (viaje_id, orden, descripcion)
    VALUES
    (
        v_viaje_id,
        1,
        'Transporte durante todo el recorrido Europeo en unidades de gran Confort con WI-FI incluido y choferes experimentados.'
    ),
    (
        v_viaje_id,
        2,
        'Acompañamiento de un Guía correo desde el inicio al fin del circuito'
    ),
    (
        v_viaje_id,
        3,
        'Traslados privados de llegada y salida del aeropuerto a Hotel y viceversa'
    ),
    (
        v_viaje_id,
        4,
        'Alojamiento y desayuno Buffet en los Hoteles indicados o de similar categoría Superior.'
    ),
    (
        v_viaje_id,
        5,
        'Todas las tasas turísticas en las ciudades de pernocte'
    ),
    (
        v_viaje_id,
        6,
        'Guías locales para las visitas de las ciudades tal como se indica en el itinerario'
    ),
    (
        v_viaje_id,
        7,
        'Seguro de Asistencia Trabax'
    ),
    (
        v_viaje_id,
        8,
        'Bolsa de Viaje.'
    );


    -- ========================================================
    -- NO INCLUYE
    -- ========================================================

    -- La fuente no publica elementos específicos bajo
    -- "NO INCLUYE" antes del bloque EUROPACK.
    -- No se inventan exclusiones.


    -- ========================================================
    -- EUROPACK - LONDRES / FRANKFURT
    -- ========================================================

    INSERT INTO public.viaje_opciones
        (viaje_id, orden, nombre, descripcion, precio, moneda, duracion_dias, duracion_noches)
    VALUES
    (
        v_viaje_id,
        1,
        'Europack Londres / Frankfurt',
        'Europack para la variante Londres / Frankfurt.',
        290.00,
        'USD',
        12,
        10
    )
    RETURNING id INTO v_opcion_id;

    INSERT INTO public.viaje_opcion_items
        (opcion_id, orden, tipo, descripcion)
    VALUES
    (
        v_opcion_id,
        1,
        'COMIDA',
        'Almuerzo en Montmartre'
    ),
    (
        v_opcion_id,
        2,
        'COMIDA',
        'Almuerzo en Brujas'
    ),
    (
        v_opcion_id,
        3,
        'COMIDA',
        'Almuerzo en Volendam'
    ),
    (
        v_opcion_id,
        4,
        'VISITA',
        'Iluminaciones de París'
    ),
    (
        v_opcion_id,
        5,
        'VISITA',
        'Paseo en Bateaux Parisiens'
    ),
    (
        v_opcion_id,
        6,
        'VISITA',
        'Subida Torre Eiffel 2º Piso'
    ),
    (
        v_opcion_id,
        7,
        'VISITA',
        'Excursión a Volendam y Marken'
    ),
    (
        v_opcion_id,
        8,
        'VISITA',
        'Subida al London Eye en Londres'
    );


    -- ========================================================
    -- EUROPACK - LONDRES / AMSTERDAM
    -- ========================================================

    INSERT INTO public.viaje_opciones
        (viaje_id, orden, nombre, descripcion, precio, moneda, duracion_dias, duracion_noches)
    VALUES
    (
        v_viaje_id,
        2,
        'Europack Londres / Amsterdam',
        'Europack para la variante Londres / Amsterdam.',
        290.00,
        'USD',
        11,
        9
    )
    RETURNING id INTO v_opcion_id;

    INSERT INTO public.viaje_opcion_items
        (opcion_id, orden, tipo, descripcion)
    VALUES
    (
        v_opcion_id,
        1,
        'COMIDA',
        'Almuerzo en Montmartre'
    ),
    (
        v_opcion_id,
        2,
        'COMIDA',
        'Almuerzo en Brujas'
    ),
    (
        v_opcion_id,
        3,
        'COMIDA',
        'Almuerzo en Volendam'
    ),
    (
        v_opcion_id,
        4,
        'VISITA',
        'Iluminaciones de París'
    ),
    (
        v_opcion_id,
        5,
        'VISITA',
        'Paseo en Bateaux Parisiens'
    ),
    (
        v_opcion_id,
        6,
        'VISITA',
        'Subida Torre Eiffel 2º Piso'
    ),
    (
        v_opcion_id,
        7,
        'VISITA',
        'Excursión a Volendam y Marken'
    ),
    (
        v_opcion_id,
        8,
        'VISITA',
        'Subida al London Eye en Londres'
    );


    -- ========================================================
    -- SALIDAS
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
        'Febrero 02.09.16 | Marzo 09.16',
        'La fuente publica las salidas con este texto original. No se reinterpretan ni corrigen las fechas.',
        TRUE
    );


    -- ========================================================
    -- VALIDACIONES INTERNAS
    -- ========================================================

    IF (
        SELECT COUNT(*)
        FROM public.viaje_itinerario
        WHERE viaje_id = v_viaje_id
    ) <> 12 THEN
        RAISE EXCEPTION 'V13: cantidad de itinerarios incorrecta.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_hoteles
        WHERE viaje_id = v_viaje_id
    ) <> 6 THEN
        RAISE EXCEPTION 'V13: cantidad de hoteles incorrecta.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_inclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 8 THEN
        RAISE EXCEPTION 'V13: cantidad de inclusiones incorrecta.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_opciones
        WHERE viaje_id = v_viaje_id
    ) <> 2 THEN
        RAISE EXCEPTION 'V13: cantidad de opciones incorrecta.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_opcion_items oi
        JOIN public.viaje_opciones o
          ON o.id = oi.opcion_id
        WHERE o.viaje_id = v_viaje_id
    ) <> 16 THEN
        RAISE EXCEPTION 'V13: cantidad de items de Europack incorrecta.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_salidas
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'V13: cantidad de salidas incorrecta.';
    END IF;

END $$;
