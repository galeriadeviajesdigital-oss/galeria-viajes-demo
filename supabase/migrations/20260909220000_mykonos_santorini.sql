-- ============================================================
-- V14 - MYKONOS & SANTORINI
-- ============================================================
--
-- Fuente:
-- https://www.galeriadeviajes.com/es/packets/mykonos-santorini
--
-- Programa:
-- MYKONOS & SANTORINI
--
-- Variante 1:
-- GRECIA Y SUS ISLAS, MYKONOS & SANTORINI
-- 10 días / 09 noches
-- Desde USD 1,400 por persona en ocupación doble
--
-- Variante 2:
-- ATENAS, MYKONOS & SANTORINI
-- 08 días / 07 noches
-- Desde USD 1,240 por persona en ocupación doble
--
-- La fuente indica:
-- Salidas diarias hasta el 31 de octubre del 2022.
--
-- Esta fecha se conserva como información histórica.
-- ============================================================


DO $$
DECLARE
    v_destino_id UUID;
    v_viaje_id UUID;
    v_opcion_1_id UUID;
    v_opcion_2_id UUID;
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
        RAISE EXCEPTION 'V14: No se encontró el destino Europa.';
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
        'Mykonos & Santorini',
        'mykonos-santorini',
        'Programa por Grecia con dos variantes: Grecia y sus Islas, Mykonos & Santorini de 10 días y 9 noches, y Atenas, Mykonos & Santorini de 8 días y 7 noches.',
        8,
        7,
        1240.00,
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


    -- ========================================================
    -- OPCIONES EXISTENTES
    -- ========================================================
    --
    -- Se limpian primero los registros dependientes para que
    -- la migración sea repetible.
    -- ========================================================

    DELETE FROM public.viaje_opcion_items
    WHERE opcion_id IN (
        SELECT id
        FROM public.viaje_opciones
        WHERE viaje_id = v_viaje_id
    );


    DELETE FROM public.viaje_itinerario
    WHERE viaje_id = v_viaje_id;


    DELETE FROM public.viaje_opciones
    WHERE viaje_id = v_viaje_id;


    -- ========================================================
    -- HOTELES
    -- ========================================================

    DELETE FROM public.viaje_hoteles
    WHERE viaje_id = v_viaje_id;


    -- ========================================================
    -- INCLUSIONES / EXCLUSIONES
    -- ========================================================

    DELETE FROM public.viaje_inclusiones
    WHERE viaje_id = v_viaje_id;


    DELETE FROM public.viaje_exclusiones
    WHERE viaje_id = v_viaje_id;


    -- ========================================================
    -- SALIDAS
    -- ========================================================

    DELETE FROM public.viaje_salidas
    WHERE viaje_id = v_viaje_id;


    -- ========================================================
    -- OPCIÓN 1
    -- ========================================================

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
    VALUES (
        v_viaje_id,
        'Grecia y sus Islas, Mykonos & Santorini',
        '10 días y 9 noches. Desde USD 1,400 por persona en ocupación doble.',
        10,
        9,
        1400.00,
        'USD',
        TRUE,
        1
    )
    RETURNING id INTO v_opcion_1_id;


    -- ========================================================
    -- OPCIÓN 1 - INCLUYE
    -- ========================================================

    INSERT INTO public.viaje_opcion_items (
        opcion_id,
        tipo,
        descripcion,
        orden
    )
    VALUES
    (
        v_opcion_1_id,
        'OTRO',
        '3 noches en Atenas en base BB',
        1
    ),
    (
        v_opcion_1_id,
        'OTRO',
        '3 noches en Mykonos en base BB',
        2
    ),
    (
        v_opcion_1_id,
        'OTRO',
        '3 noches en Santorini en base BB',
        3
    ),
    (
        v_opcion_1_id,
        'VISITA',
        'Visita de Atenas con Museo Nuevo en regular en español, entradas incluidas',
        4
    ),
    (
        v_opcion_1_id,
        'ACTIVIDAD',
        'Traslados privados en Atenas apt/htl/pto/htl/apt (sin asistencia excepto el traslado de llegada)',
        5
    ),
    (
        v_opcion_1_id,
        'ACTIVIDAD',
        'Traslados compartidos en Mykonos & Santorini pto/htl/pto',
        6
    ),
    (
        v_opcion_1_id,
        'ACTIVIDAD',
        'Billetes de barco ferry Atenas (Pireo)/Mykonos & Santorini/Atenas (Pireo) en asientos numerados',
        7
    ),
    (
        v_opcion_1_id,
        'ACTIVIDAD',
        'Billete de barco hydrofoil Mykonos/Santorini (economy)',
        8
    );


    -- ========================================================
    -- OPCIÓN 1 - ITINERARIO
    -- ========================================================

    INSERT INTO public.viaje_itinerario (
        viaje_id,
        opcion_id,
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
        v_opcion_1_id,
        1,
        NULL,
        'Llegada a Atenas',
        NULL,
        'Atenas',
        NULL,
        'Llegada al aeropuerto, asistencia y traslado al hotel. Alojamiento.',
        'Atenas',
        1
    ),

    (
        v_viaje_id,
        v_opcion_1_id,
        2,
        NULL,
        'Atenas',
        'Atenas',
        'Atenas',
        NULL,
        'Desayuno. Salida para realizar la visita de la ciudad de Atenas. Kalimármaro, el Arco de Adriano, Parlamento-Monumento del Soldado Desconocido y el tradicional Cambio de Guardia en la Plaza de la Constitución-Plaza Syntagma. Plaza de la Concordia, Plaza Omonia. Acrópolis; los Propileos, el templo Jónico de Atenea Nike, el Erecteion, Partenón y Museo Nuevo. Tarde libre.',
        'Atenas',
        2
    ),

    (
        v_viaje_id,
        v_opcion_1_id,
        3,
        NULL,
        'Atenas - Mykonos',
        'Atenas',
        'Mykonos',
        NULL,
        'Salida hacia el puerto del Pireo para tomar el barco de línea regular hacia Mykonos. Llegada a Mykonos y traslado al hotel. Alojamiento.',
        'Mykonos',
        3
    ),

    (
        v_viaje_id,
        v_opcion_1_id,
        4,
        NULL,
        'Mykonos',
        'Mykonos',
        'Mykonos',
        NULL,
        'Estancia en la isla de Mykonos.',
        'Mykonos',
        4
    ),

    (
        v_viaje_id,
        v_opcion_1_id,
        5,
        NULL,
        'Mykonos',
        'Mykonos',
        'Mykonos',
        NULL,
        'Estancia en la isla de Mykonos.',
        'Mykonos',
        5
    ),

    (
        v_viaje_id,
        v_opcion_1_id,
        6,
        NULL,
        'Mykonos - Santorini',
        'Mykonos',
        'Santorini',
        NULL,
        'A la hora convenida traslado al puerto con destino a Santorini. Llegada y traslado al hotel.',
        'Santorini',
        6
    ),

    (
        v_viaje_id,
        v_opcion_1_id,
        7,
        NULL,
        'Santorini',
        'Santorini',
        'Santorini',
        NULL,
        'Día libre para explorar la isla y contemplar las maravillosas vistas desde lo alto del acantilado. Alojamiento.',
        'Santorini',
        7
    ),

    (
        v_viaje_id,
        v_opcion_1_id,
        8,
        NULL,
        'Santorini',
        'Santorini',
        'Santorini',
        NULL,
        'Día libre para explorar la isla y contemplar las maravillosas vistas desde lo alto del acantilado. Alojamiento.',
        'Santorini',
        8
    ),

    (
        v_viaje_id,
        v_opcion_1_id,
        9,
        NULL,
        'Santorini - Atenas',
        'Santorini',
        'Atenas',
        NULL,
        'A la hora convenida traslado al puerto con destino a Atenas. Llegada y traslado al hotel y alojamiento.',
        'Atenas',
        9
    ),

    (
        v_viaje_id,
        v_opcion_1_id,
        10,
        NULL,
        'Atenas',
        'Atenas',
        NULL,
        NULL,
        'Traslado de salida hacia el aeropuerto.',
        NULL,
        10
    );


    -- ========================================================
    -- OPCIÓN 2
    -- ========================================================

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
    VALUES (
        v_viaje_id,
        'Atenas, Mykonos & Santorini',
        '8 días y 7 noches. Desde USD 1,240 por persona en ocupación doble.',
        8,
        7,
        1240.00,
        'USD',
        TRUE,
        2
    )
    RETURNING id INTO v_opcion_2_id;


    -- ========================================================
    -- OPCIÓN 2 - INCLUYE
    -- ========================================================

    INSERT INTO public.viaje_opcion_items (
        opcion_id,
        tipo,
        descripcion,
        orden
    )
    VALUES
    (
        v_opcion_2_id,
        'OTRO',
        '3 noches en Atenas en base BB',
        1
    ),
    (
        v_opcion_2_id,
        'OTRO',
        '2 noches en Mykonos en base BB',
        2
    ),
    (
        v_opcion_2_id,
        'OTRO',
        '2 noches en Santorini en base BB',
        3
    ),
    (
        v_opcion_2_id,
        'VISITA',
        'Visita de Atenas con Museo Nuevo en regular en español, entradas incluidas',
        4
    ),
    (
        v_opcion_2_id,
        'ACTIVIDAD',
        'Traslados privados en Atenas apt/htl/pto/htl/apt (sin asistencia excepto el traslado de llegada)',
        5
    ),
    (
        v_opcion_2_id,
        'ACTIVIDAD',
        'Traslados compartidos en Mykonos & Santorini pto/htl/pto',
        6
    ),
    (
        v_opcion_2_id,
        'ACTIVIDAD',
        'Billetes de barco ferry Atenas (Pireo)/Mykonos & Santorini/Atenas (Pireo) en asientos numerados',
        7
    ),
    (
        v_opcion_2_id,
        'ACTIVIDAD',
        'Billete de barco hydrofoil Mykonos/Santorini (economy)',
        8
    );


    -- ========================================================
    -- OPCIÓN 2 - ITINERARIO
    -- ========================================================

    INSERT INTO public.viaje_itinerario (
        viaje_id,
        opcion_id,
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
        v_opcion_2_id,
        1,
        NULL,
        'Atenas',
        NULL,
        'Atenas',
        NULL,
        'Llegada al aeropuerto, asistencia y traslado al hotel. Alojamiento.',
        'Atenas',
        1
    ),

    (
        v_viaje_id,
        v_opcion_2_id,
        2,
        NULL,
        'Atenas',
        'Atenas',
        'Atenas',
        NULL,
        'Desayuno. Salida para realizar la visita de la ciudad de Atenas y Museo Nuevo. Kalimármaro, el Arco de Adriano, Parlamento-Monumento del Soldado Desconocido y el tradicional Cambio de Guardia en la Plaza de la Constitución-Plaza Syntagma. Plaza de la Concordia, Plaza Omonia. Acrópolis; los Propileos, el templo Jónico de Atenea Nike, el Erecteion y Partenón. Tarde libre.',
        'Atenas',
        2
    ),

    (
        v_viaje_id,
        v_opcion_2_id,
        3,
        NULL,
        'Atenas - Mykonos',
        'Atenas',
        'Mykonos',
        NULL,
        'Salida hacia el puerto del Pireo para tomar el barco de línea regular hacia Mykonos. Llegada a Mykonos y traslado al hotel. Alojamiento.',
        'Mykonos',
        3
    ),

    (
        v_viaje_id,
        v_opcion_2_id,
        4,
        NULL,
        'Mykonos',
        'Mykonos',
        'Mykonos',
        NULL,
        'Estancia en la isla de Mykonos.',
        'Mykonos',
        4
    ),

    (
        v_viaje_id,
        v_opcion_2_id,
        5,
        NULL,
        'Mykonos - Santorini',
        'Mykonos',
        'Santorini',
        NULL,
        'A la hora convenida traslado al puerto con destino a Santorini. Llegada y traslado al hotel.',
        'Santorini',
        5
    ),

    (
        v_viaje_id,
        v_opcion_2_id,
        6,
        NULL,
        'Santorini',
        'Santorini',
        'Santorini',
        NULL,
        'Día libre para explorar la isla y contemplar las maravillosas vistas desde lo alto del acantilado. Alojamiento.',
        'Santorini',
        6
    ),

    (
        v_viaje_id,
        v_opcion_2_id,
        7,
        NULL,
        'Santorini - Atenas',
        'Santorini',
        'Atenas',
        NULL,
        'A la hora convenida traslado al puerto con destino a Atenas. Llegada y traslado al hotel y alojamiento.',
        'Atenas',
        7
    ),

    (
        v_viaje_id,
        v_opcion_2_id,
        8,
        NULL,
        'Atenas',
        'Atenas',
        NULL,
        NULL,
        'Traslado de salida hacia el aeropuerto.',
        NULL,
        8
    );


    -- ========================================================
    -- HOTELES
    -- ========================================================
    --
    -- La fuente publica tres categorías:
    -- BRONCE / PLATA / ORO
    --
    -- Se mantienen como hotelería prevista o similar.
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
        'Atenas',
        'Jason Inn',
        'BRONCE'
    ),
    (
        v_viaje_id,
        2,
        'Mykonos',
        'Mykonos View',
        'BRONCE'
    ),
    (
        v_viaje_id,
        3,
        'Santorini',
        'Veggera',
        'BRONCE'
    ),
    (
        v_viaje_id,
        4,
        'Atenas',
        'Melia',
        'PLATA'
    ),
    (
        v_viaje_id,
        5,
        'Mykonos',
        'Yiannaki',
        'PLATA'
    ),
    (
        v_viaje_id,
        6,
        'Santorini',
        'El Greco',
        'PLATA'
    ),
    (
        v_viaje_id,
        7,
        'Atenas',
        'Grand Hyatt',
        'ORO'
    ),
    (
        v_viaje_id,
        8,
        'Mykonos',
        'K Hotels',
        'ORO'
    ),
    (
        v_viaje_id,
        9,
        'Santorini',
        'Aressana',
        'ORO'
    );


    -- ========================================================
    -- NO INCLUYE
    -- ========================================================

    INSERT INTO public.viaje_exclusiones (
        viaje_id,
        orden,
        descripcion
    )
    VALUES (
        v_viaje_id,
        1,
        'Ningún servicio no mencionado en el apartado “incluye”.'
    );


    -- ========================================================
    -- SALIDA HISTÓRICA
    -- ========================================================

    INSERT INTO public.viaje_salidas (
        viaje_id,
        fecha_inicio,
        fecha_fin,
        texto_original,
        observaciones,
        activo
    )
    VALUES (
        v_viaje_id,
        NULL,
        NULL,
        'Salidas diarias hasta el 31 de octubre del 2022',
        'Información histórica publicada por la fuente original. No representa una salida vigente.',
        FALSE
    );


    -- ========================================================
    -- VALIDACIONES
    -- ========================================================

    IF (
        SELECT COUNT(*)
        FROM public.viaje_opciones
        WHERE viaje_id = v_viaje_id
    ) <> 2 THEN
        RAISE EXCEPTION 'V14: Se esperaban 2 opciones.';
    END IF;


    IF (
        SELECT COUNT(*)
        FROM public.viaje_opcion_items oi
        INNER JOIN public.viaje_opciones o
            ON o.id = oi.opcion_id
        WHERE o.viaje_id = v_viaje_id
    ) <> 16 THEN
        RAISE EXCEPTION 'V14: Se esperaban 16 items de opciones.';
    END IF;


    IF (
        SELECT COUNT(*)
        FROM public.viaje_itinerario
        WHERE viaje_id = v_viaje_id
          AND opcion_id = v_opcion_1_id
    ) <> 10 THEN
        RAISE EXCEPTION 'V14: La opción 1 debe tener 10 días.';
    END IF;


    IF (
        SELECT COUNT(*)
        FROM public.viaje_itinerario
        WHERE viaje_id = v_viaje_id
          AND opcion_id = v_opcion_2_id
    ) <> 8 THEN
        RAISE EXCEPTION 'V14: La opción 2 debe tener 8 días.';
    END IF;


    IF (
        SELECT COUNT(*)
        FROM public.viaje_hoteles
        WHERE viaje_id = v_viaje_id
    ) <> 9 THEN
        RAISE EXCEPTION 'V14: Se esperaban 9 hoteles.';
    END IF;


    IF (
        SELECT COUNT(*)
        FROM public.viaje_exclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'V14: Se esperaba 1 exclusión.';
    END IF;


    IF (
        SELECT COUNT(*)
        FROM public.viaje_salidas
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'V14: Se esperaba 1 salida histórica.';
    END IF;


END $$;

