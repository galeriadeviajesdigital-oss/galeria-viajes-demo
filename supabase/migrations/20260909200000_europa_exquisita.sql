-- ============================================================
-- V12 - EUROPA EXQUISITA
-- Fuente:
-- https://www.galeriadeviajes.com/es/packets/europa-exquisita
--
-- 11 días / 10 noches
-- Ruta:
-- París | Dijon | Zúrich | Lucerna | Venecia | Padua |
-- Florencia | Asís | Roma
--
-- No se inventan fechas ni precio base.
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
        'Europa Exquisita',
        'europa-exquisita',
        'Recorrido por París, Dijon, Zúrich, Lucerna, Venecia, Padua, Florencia, Asís y Roma. Incluye visitas panorámicas, traslados, alojamiento y servicios de guía durante el recorrido.',
        11,
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
        WHERE slug = 'europa-exquisita'
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
        'Ámerica / París',
        'Salida en vuelo intercontinental con destino a París. Noche a bordo.',
        1
    ),
    (
        v_viaje_id,
        2,
        'París',
        'Llegada a París. Recibimiento y traslado al hotel previsto. Resto del día libre. Alojamiento.',
        2
    ),
    (
        v_viaje_id,
        3,
        'París',
        'Desayuno, a la hora convenida visita panorámica de la ciudad de la Luz, recorriendo la Avenida de los Campos Eliseos, Arco del Triunfo, Torre Eiffel, Isla de la Ciudad, breve tiempo para visitar la Medalla Milagrosa, etc. Tarde libre para actividades personales. Alojamiento.',
        3
    ),
    (
        v_viaje_id,
        4,
        'París',
        'Desayuno. Día libre a disposición para efectuar excursiones opcionales y continuar descubriendo esta fascinante ciudad. Alojamiento.',
        4
    ),
    (
        v_viaje_id,
        5,
        'París / Dijon / Zúrich',
        'Desayuno. Salida hacia Dijon, ciudad mundialmente conocida por su famosa mostaza. Se podrá pasear por su centro histórico medieval donde se encuentra uno de los museos más antiguos de Francia, el Museo de Bellas Artes. Continuamos viaje hasta Zurich. Llegada y tiempo libre para recorrer esta hermosa ciudad Suiza. Opcionalmente pueden realizar la visita guiada donde visitaremos la Bahnhofstrasse, la colina Lindenhof, el viejo barrio de marineros y pescadores Schippe; y el puente más antiguo de Zurich Rathaus-Brucke donde se encuentra el Ayuntamiento a orilla de su lago, etc.',
        5
    ),
    (
        v_viaje_id,
        6,
        'Zúrich / Lucerna / Venecia',
        'Desayuno y salida hacia Lucerna, situada a orillas del lago de los Cuatro Cantones y ha conservado en sus edificaciones, plazas y callejuelas el encanto medieval. Opcionalmente puede realizar excursión al monte Titlis: subirán en teleférico a lo alto de las montañas nevadas de los Alpes Suizos, apreciando los hermosos paisajes y disfrutando de la nieve y de las diferentes atracciones que allí se encuentran. A la hora indicada viaje hacia Venecia. Una de las ciudades más bellas del mundo. Alojamiento.',
        6
    ),
    (
        v_viaje_id,
        7,
        'Venecia / Padua / Florencia',
        'Desayuno. Mañana dedicada a visita de Venecia, ciudad de las 118 islas. Traslado en vaporeto hacia Plaza San Marco. Visita a pie recorriendo la Plaza de San Marcos, Palacio Ducal, Puente de los Suspiros, etc. Tiempo libre para recorrer por su cuenta las laberínticas calles y canales y admirar los contrastes entre los bellos Palacios situados en el Gran Canal y las pequeñas iglesias. Opcionalmente le sugerimos completar su tiempo con un paseo en góndola. A la hora indicada salida hacia Padua, ciudad conocida por el Santo, tiempo en su catedral. Continuación hacia Florencia. Llegada y alojamiento en el hotel previsto.',
        7
    ),
    (
        v_viaje_id,
        8,
        'Florencia / Asís / Roma',
        'Desayuno. Panorámica de la ciudad, cuna del renacimiento y de la lengua italiana. Pasearemos por esta ciudad rebosante de Arte, Historia y Cultura, admirando la Catedral de Santa María dei Fiori con su bello Campanille, el Baptisterio decorado con las famosas puertas del paraíso, por donde pasaron personajes tan conocidos como Miguel Ángel o Dante Alighieri. A la hora indicada salida en dirección a Asís, donde visitaremos la ciudad y la Basílica de San Francisco para proseguir hasta Roma, la Ciudad Eterna. Alojamiento.',
        8
    ),
    (
        v_viaje_id,
        9,
        'Roma',
        'Desayuno. Día libre durante el que se podrá realizar opcionalmente una de las visitas más interesantes de Italia: Capri y Nápoles - Pompeya, una excursión de día completo para conocer Nápoles, la más típica ciudad italiana; Capri, una pintoresca isla del Mediterráneo; y Pompeya, espléndida y mitológica ciudad romana. Alojamiento.',
        9
    ),
    (
        v_viaje_id,
        10,
        'Roma (Audiencia Papal)',
        'Desayuno y salida hacia Ciudad del Vaticano, para asistir a audiencia del Santo Padre, siempre y cuando el Papa se encuentre en Roma. Continuación visita panorámica de la Ciudad Imperial, recorriendo los Foros Romanos, Coliseo, Arco de Constantino, Plaza de Venecia y Plaza de San Pedro en la Ciudad-Estado de El Vaticano. Resto del día libre para visitar los famosos Museos Vaticanos y la obra cumbre de Miguel Ángel, la Capilla Sixtina. Alojamiento.',
        10
    ),
    (
        v_viaje_id,
        11,
        'Roma / Salida',
        'Desayuno, a la hora indicada traslado del hotel al aeropuerto para tomar el vuelo de salida. Fin de nuestros servicios.',
        11
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
        'París',
        'B&B Paris Porte de Choisy',
        NULL
    ),
    (
        v_viaje_id,
        2,
        'Zürich',
        'Mövenpick Zürich',
        NULL
    ),
    (
        v_viaje_id,
        3,
        'Venecia',
        'Lugano Torretta',
        NULL
    ),
    (
        v_viaje_id,
        4,
        'Florencia',
        'B&B Firenze Centre',
        NULL
    ),
    (
        v_viaje_id,
        5,
        'Roma',
        'IH Roma Z3',
        NULL
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
        'Alojamiento en hoteles de categoría TS/P'
    ),
    (
        v_viaje_id,
        2,
        'Desayuno diario'
    ),
    (
        v_viaje_id,
        3,
        'Guía acompañante durante todo el recorrido'
    ),
    (
        v_viaje_id,
        4,
        'Transporte en autocar turístico'
    ),
    (
        v_viaje_id,
        5,
        'Traslados Aeropuerto - Hotel - Aeropuerto'
    ),
    (
        v_viaje_id,
        6,
        'Traslados en Vaporetto en Venecia'
    ),
    (
        v_viaje_id,
        7,
        'Visita con guía local en los lugares indicados'
    );


    -- ========================================================
    -- NO INCLUYE
    -- ========================================================

    INSERT INTO public.viaje_exclusiones
        (viaje_id, orden, descripcion)
    VALUES
    (
        v_viaje_id,
        1,
        'Ningún servicio no mencionado en el apartado “incluye”'
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
        NULL,
        'La fuente no publica en el contenido extraído una fecha de salida concreta.',
        TRUE
    );


    -- ========================================================
    -- VALIDACIÓN INTERNA
    -- ========================================================

    IF (
        SELECT COUNT(*)
        FROM public.viaje_itinerario
        WHERE viaje_id = v_viaje_id
    ) <> 11 THEN
        RAISE EXCEPTION 'V12: cantidad de itinerarios incorrecta.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_hoteles
        WHERE viaje_id = v_viaje_id
    ) <> 5 THEN
        RAISE EXCEPTION 'V12: cantidad de hoteles incorrecta.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_inclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 7 THEN
        RAISE EXCEPTION 'V12: cantidad de inclusiones incorrecta.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_exclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'V12: cantidad de exclusiones incorrecta.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_salidas
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'V12: cantidad de salidas incorrecta.';
    END IF;

END $$;
