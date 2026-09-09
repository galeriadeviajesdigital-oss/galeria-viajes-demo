-- ============================================================
-- V11 - EUROPA ESTILO MP 1 "DESDE MADRID A MADRID"
-- Fuente:
-- https://www.galeriadeviajes.com/es/packets/europa-estilo-mp-1-desde-madrid-a-madrid
--
-- Datos preservados segun la fuente original.
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
        'Europa Estilo MP 1 "Desde Madrid a Madrid"',
        'europa-estilo-mp-1-desde-madrid-a-madrid',
        'Circuito europeo de 19 dias con inicio y final en Madrid, recorriendo Zaragoza, Barcelona, Costa Azul, Pisa, Roma, Florencia, Padua, Venecia, Innsbruck, Lucerna, Zurich, Paris, Lourdes y San Sebastian.',
        19,
        18,
        NULL,
        'USD',
        'Traslados de aeropuerto al hotel y viceversa; alojamiento y desayuno en hoteles de la categoria elegida; transporte en autobus de turismo con guia; visitas indicadas con guias locales de habla hispana; camarote en ferry Barcelona-Roma; seguro de proteccion y asistencia en viaje MAPAPLUS; bolsa de viaje; visitas con servicio de audio individual.',
        'Tasas de estancia en Italia en Venecia, Florencia y Roma; servicios no mencionados en incluye; Paquete Plus.',
        NULL,
        TRUE,
        TRUE
    )
    RETURNING id INTO v_viaje_id;


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
        distancia_km,
        descripcion,
        alojamiento,
        orden
    )
    VALUES
    (
        v_viaje_id, 1, 'Domingo',
        'America / Madrid',
        'America', 'Madrid', NULL,
        'Salida en vuelo intercontinental con destino a Madrid.',
        NULL, 1
    ),
    (
        v_viaje_id, 2, 'Lunes',
        'Madrid',
        'Madrid', 'Madrid', NULL,
        'Llegada al aeropuerto y traslado al hotel. Dia libre. A ultima hora de la tarde recorrido por el Madrid iluminado y alrededores de la Plaza Mayor. Cena de tapas incluida en Paquete Plus.',
        'Madrid', 2
    ),
    (
        v_viaje_id, 3, 'Martes',
        'Madrid',
        'Madrid', 'Madrid', NULL,
        'Visita de la ciudad recorriendo Castellana, Gran Via, Cibeles y Neptuno, Puerta de Alcala, Las Cortes, Puerta del Sol, Plaza Mayor, Plaza de Oriente y Madrid moderno. Tarde libre con sugerencia de excursion a Toledo.',
        'Madrid', 3
    ),
    (
        v_viaje_id, 4, 'Miercoles',
        'Madrid / Zaragoza / Barcelona',
        'Madrid', 'Barcelona', 630,
        'Salida hacia Zaragoza. Tiempo libre para visitar la Basilica del Pilar antes de continuar hacia Barcelona.',
        'Barcelona', 4
    ),
    (
        v_viaje_id, 5, 'Jueves',
        'Barcelona / Roma (en barco)',
        'Barcelona', 'Roma', NULL,
        'Visita de Barcelona recorriendo Plaza de Cataluña, Paseo de Gracia, Diagonal, Sagrada Familia, barrio gotico, Ramblas y Montjuic. Almuerzo en Puerto Olimpico incluido en Paquete Plus. Traslado al puerto para tomar el barco direccion Civitavecchia. Noche a bordo.',
        NULL, 5
    ),
    (
        v_viaje_id, 6, 'Viernes',
        'Roma',
        'Civitavecchia', 'Roma', NULL,
        'Desayuno en el barco y llegada a Roma a media tarde. Traslado al hotel.',
        'Roma', 6
    ),
    (
        v_viaje_id, 7, 'Sabado',
        'Roma',
        'Roma', 'Roma', NULL,
        'Visita opcional detallada del Vaticano incluyendo museos, Capilla Sixtina y Basilica del Vaticano. Visita al Museo Vaticano incluida en Paquete Plus. Recorrido panoramico de Roma y almuerzo incluido en Paquete Plus. Tarde libre.',
        'Roma', 7
    ),
    (
        v_viaje_id, 8, 'Domingo',
        'Roma',
        'Roma', 'Roma', NULL,
        'Dia libre en Roma. Se sugiere excursion a Napoles y Capri.',
        'Roma', 8
    ),
    (
        v_viaje_id, 9, 'Lunes',
        'Roma / Florencia',
        'Roma', 'Florencia', 290,
        'Salida hacia Florencia. Por la tarde recorrido por el centro artistico de la ciudad con Duomo, Campanile de Giotto, Baptisterio, Iglesia de San Lorenzo, Plaza de la Signoria, Loggia dei Lanzi, Santa Maria dei Fiore y Ponte Vecchio. Cena incluida en Paquete Plus.',
        'Florencia', 9
    ),
    (
        v_viaje_id, 10, 'Martes',
        'Florencia / Padua / Venecia',
        'Florencia', 'Venecia', 310,
        'Salida hacia Padua. Tiempo libre para visitar la Basilica de San Antonio. Llegada a Venecia y visita a pie de la ciudad incluyendo taller de cristal veneciano. Paseo en gondola incluido en Paquete Plus.',
        'Venecia', 10
    ),
    (
        v_viaje_id, 11, 'Miercoles',
        'Venecia / Innsbruck',
        'Venecia', 'Innsbruck', 390,
        'Salida hacia la frontera austriaca bordeando las Dolomitas. Llegada a Innsbruck. Paseo con guia por el centro historico y visita del Tejadillo de Oro. Cena y espectaculo de folklore austriaco incluidos en Paquete Plus.',
        'Innsbruck', 11
    ),
    (
        v_viaje_id, 12, 'Jueves',
        'Innsbruck / Lucerna / Zurich',
        'Innsbruck', 'Zurich', 360,
        'Salida hacia Suiza para llegar a Lucerna. Tiempo libre y continuacion hacia Zurich.',
        'Zurich', 12
    ),
    (
        v_viaje_id, 13, 'Viernes',
        'Zurich / Basilea / Paris',
        'Zurich', 'Paris', 610,
        'Salida hacia Basilea, ciudad fronteriza entre Alemania, Suiza y Francia. Continuacion hacia Paris. Recorrido por la ciudad iluminada y paseo opcional por el Sena en Bateaux Mouche, incluido en Paquete Plus.',
        'Paris', 13
    ),
    (
        v_viaje_id, 14, 'Sabado',
        'Paris',
        'Paris', 'Paris', NULL,
        'Recorrido de Paris y principales monumentos. Subida a la Torre Eiffel, segundo piso, incluida en Paquete Plus. Tarde libre y posibilidad de excursion a Versalles y espectaculos nocturnos.',
        'Paris', 14
    ),
    (
        v_viaje_id, 15, 'Domingo',
        'Paris',
        'Paris', 'Paris', NULL,
        'Dia libre para pasear por la ciudad, sus paseos y bulevares y visitar opcionalmente el Museo del Louvre.',
        'Paris', 15
    ),
    (
        v_viaje_id, 16, 'Lunes',
        'Paris / Lourdes',
        'Paris', 'Lourdes', 850,
        'Salida hacia la region del Loire y continuacion hacia Lourdes. Llegada a ultima hora de la tarde. Tiempo libre para presenciar la Procesion de las Antorchas y la Gruta de la Virgen entre abril y octubre. Cena incluida en Paquete Plus.',
        'Lourdes', 16
    ),
    (
        v_viaje_id, 17, 'Martes',
        'Lourdes / San Sebastian / Madrid',
        'Lourdes', 'Madrid', 660,
        'Salida hacia San Sebastian. Parada y continuacion a Madrid. Tiempo libre en San Sebastian. Llegada a Madrid y recorrido por el Madrid iluminado. Cena de tapas incluida en Paquete Plus.',
        'Madrid', 17
    ),
    (
        v_viaje_id, 18, 'Miercoles',
        'Madrid',
        'Madrid', 'Madrid', NULL,
        'Visita de Madrid recorriendo Castellana, Gran Via, Cibeles y Neptuno, Puerta de Alcala, Las Cortes, Puerta del Sol, Plaza Mayor, Plaza de Oriente y Madrid moderno. Tarde libre con sugerencia de excursion a Toledo.',
        'Madrid', 18
    ),
    (
        v_viaje_id, 19, 'Jueves',
        'Madrid / Salida',
        'Madrid', 'Madrid', NULL,
        'Desayuno buffet. Traslado al aeropuerto a la hora prevista.',
        NULL, 19
    );


    -- ========================================================
    -- HOTELES
    -- ========================================================
    -- La fuente presenta un hotel por ciudad, con Madrid al inicio
    -- y nuevamente al final del recorrido.

    INSERT INTO public.viaje_hoteles (
        viaje_id,
        ciudad,
        nombre_hotel,
        categoria,
        orden
    )
    VALUES
    (v_viaje_id, 'Madrid', 'Praga', NULL, 1),
    (v_viaje_id, 'Barcelona', 'Rialto', NULL, 2),
    (v_viaje_id, 'Costa Azul', 'Amarante', NULL, 3),
    (v_viaje_id, 'Roma', 'IH Z3', NULL, 4),
    (v_viaje_id, 'Florencia', 'Grifone', NULL, 5),
    (v_viaje_id, 'Venecia', 'Alexander', NULL, 6),
    (v_viaje_id, 'Innsbruck', 'Alpinpark', NULL, 7),
    (v_viaje_id, 'Zurich', 'Holiday Inn Messe', NULL, 8),
    (v_viaje_id, 'Paris', 'Mercure Porte D'' Orleans', NULL, 9),
    (v_viaje_id, 'Lourdes', 'Mercure Imperial', NULL, 10),
    (v_viaje_id, 'Madrid', 'Praga', NULL, 11);


    -- ========================================================
    -- INCLUSIONES
    -- ========================================================

    INSERT INTO public.viaje_inclusiones (
        viaje_id,
        descripcion,
        orden
    )
    VALUES
    (v_viaje_id, 'Traslados del aeropuerto al hotel y viceversa a la llegada y salida.', 1),
    (v_viaje_id, 'Alojamiento y desayuno en hoteles de la categoria elegida.', 2),
    (v_viaje_id, 'Transporte en autobus de turismo con guia durante todo el recorrido.', 3),
    (v_viaje_id, 'Visitas indicadas en el itinerario con guias locales de habla hispana.', 4),
    (v_viaje_id, 'Camarote en ferry Barcelona-Roma.', 5),
    (v_viaje_id, 'Seguro de proteccion y asistencia en viaje MAPAPLUS.', 6),
    (v_viaje_id, 'Bolsa de viaje.', 7),
    (v_viaje_id, 'Visitas con servicio de audio individual.', 8);


    -- ========================================================
    -- EXCLUSIONES
    -- ========================================================

    INSERT INTO public.viaje_exclusiones (
        viaje_id,
        descripcion,
        orden
    )
    VALUES
    (v_viaje_id, 'Tasas de estancia en Italia (Venecia, Florencia y Roma).', 1),
    (v_viaje_id, 'Ningun servicio no mencionado en el apartado incluye.', 2),
    (v_viaje_id, 'Paquete Plus (P+).', 3);


    -- ========================================================
    -- PAQUETE PLUS
    -- ========================================================

    INSERT INTO public.viaje_opciones (
        viaje_id,
        nombre,
        descripcion,
        duracion_dias,
        duracion_noches,
        precio,
        moneda,
        orden
    )
    VALUES (
        v_viaje_id,
        'Paquete Plus Madrid / Madrid',
        'Paquete Plus Madrid / Madrid. Incluye 06 comidas y 05 extras por USD 395.',
        19,
        18,
        395,
        'USD',
        1
    )
    RETURNING id INTO v_opcion_id;


    -- ========================================================
    -- ITEMS PAQUETE PLUS
    -- ========================================================

    INSERT INTO public.viaje_opcion_items (
        opcion_id,
        tipo,
        descripcion,
        orden
    )
    VALUES
    (v_opcion_id, 'COMIDA', 'Cena de tapas en Madrid.', 1),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Roma.', 2),
    (v_opcion_id, 'COMIDA', 'Cena en Florencia.', 3),
    (v_opcion_id, 'COMIDA', 'Cena en Innsbruck.', 4),
    (v_opcion_id, 'COMIDA', 'Cena en Lourdes.', 5),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Puerto Olimpico de Barcelona.', 6),
    (v_opcion_id, 'VISITA', 'Vaticano: Museos y Capilla Sixtina.', 7),
    (v_opcion_id, 'VISITA', 'Paseo en Gondola en Venecia.', 8),
    (v_opcion_id, 'VISITA', 'Espectaculo folklore tiroles en Innsbruck.', 9),
    (v_opcion_id, 'VISITA', 'Paseo en Bateaux Mouche.', 10),
    (v_opcion_id, 'VISITA', 'Subida a la Torre Eiffel, segundo piso.', 11);


    -- ========================================================
    -- SALIDA
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
        NULL,
        'La fuente no publica en el contenido extraido una fecha de salida concreta.',
        TRUE
    );


    -- ========================================================
    -- VALIDACION INTERNA
    -- ========================================================

    IF (
        SELECT COUNT(*)
        FROM public.viaje_itinerario
        WHERE viaje_id = v_viaje_id
    ) <> 19 THEN
        RAISE EXCEPTION 'V11: cantidad de itinerarios incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_hoteles
        WHERE viaje_id = v_viaje_id
    ) <> 11 THEN
        RAISE EXCEPTION 'V11: cantidad de hoteles incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_inclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 8 THEN
        RAISE EXCEPTION 'V11: cantidad de inclusiones incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_exclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 3 THEN
        RAISE EXCEPTION 'V11: cantidad de exclusiones incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_opciones
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'V11: cantidad de opciones incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_opcion_items oi
        JOIN public.viaje_opciones o
            ON o.id = oi.opcion_id
        WHERE o.viaje_id = v_viaje_id
    ) <> 11 THEN
        RAISE EXCEPTION 'V11: cantidad de items de opcion incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_salidas
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'V11: cantidad de salidas incorrecta';
    END IF;


    RAISE NOTICE 'V11 EUROPA ESTILO MP 1 cargada correctamente.';
    RAISE NOTICE 'Viaje ID: %', v_viaje_id;
    RAISE NOTICE 'Itinerario: 19';
    RAISE NOTICE 'Hoteles: 11';
    RAISE NOTICE 'Inclusiones: 8';
    RAISE NOTICE 'Exclusiones: 3';
    RAISE NOTICE 'Opciones: 1';
    RAISE NOTICE 'Items opcion: 11';
    RAISE NOTICE 'Salidas: 1';

END $$;
