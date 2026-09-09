-- ============================================================
-- V15 - QUERIDA EUROPA
-- ============================================================
--
-- Fuente:
-- https://www.galeriadeviajes.com/es/packets/querida-europa
--
-- Programa:
-- QUERIDA EUROPA
--
-- 22 días / 20 noches
-- Desde USD 2,510
--
-- Nota de fuente:
-- La fuente original contiene un error de numeración:
-- utiliza "Día 21" para Barcelona / Zaragoza / Madrid
-- y nuevamente "Día 21" para Madrid / Salida.
--
-- Para el modelo se corrige la numeración a:
-- Día 21 = Barcelona / Zaragoza / Madrid
-- Día 22 = Madrid / Salida
--
-- La fuente indica:
-- Salidas: todos los viernes hasta abril de 2023.
-- Se conserva como información histórica.
-- ============================================================

DO $$
DECLARE
    v_destino_id UUID;
    v_viaje_id UUID;
    v_opcion_plus_id UUID;
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
        RAISE EXCEPTION 'V15: No se encontró el destino Europa.';
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
        'Querida Europa',
        'querida-europa',
        'Circuito europeo de 22 días y 20 noches desde Madrid, recorriendo España, Francia, Alemania, Austria, Eslovenia e Italia antes de regresar a Madrid.',
        22,
        20,
        2510.00,
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
    -- LIMPIEZA DE DATOS PREVIOS
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
        NULL,
        1,
        'Viernes',
        'América',
        NULL,
        'Madrid',
        NULL,
        'Salida en vuelo intercontinental con destino a Madrid.',
        NULL,
        1
    ),

    (
        v_viaje_id,
        NULL,
        2,
        'Sábado',
        'Madrid',
        'Madrid',
        'Madrid',
        NULL,
        'Llegada al aeropuerto y traslado al hotel. Día libre. A última hora de la tarde recorrido por el Madrid iluminado y por los alrededores de la Plaza Mayor. Regreso al hotel. Opcionalmente se puede degustar tapas en uno de los múltiples mesones. Alojamiento.',
        'Madrid',
        2
    ),

    (
        v_viaje_id,
        NULL,
        3,
        'Domingo',
        'Madrid',
        'Madrid',
        'Madrid',
        NULL,
        'Desayuno buffet. Por la mañana visita de la ciudad recorriendo la Castellana, Gran Vía, Cibeles y Neptuno, Puerta de Alcalá, Las Cortes, Puerta del Sol, Plaza Mayor, Plaza de Oriente y el Madrid moderno. Tarde libre. Se sugiere excursión a Toledo. Alojamiento.',
        'Madrid',
        3
    ),

    (
        v_viaje_id,
        NULL,
        4,
        'Lunes',
        'Madrid / San Sebastián / Burdeos',
        'Madrid',
        'Burdeos',
        NULL,
        'Desayuno buffet y salida hacia San Sebastián, la bella Easo. Tiempo libre para pasear por el paseo de la Concha y almorzar. Continuación hacia Francia. Llegada a Burdeos. Alojamiento.',
        'Burdeos',
        4
    ),

    (
        v_viaje_id,
        NULL,
        5,
        'Martes',
        'Burdeos / Región del Loire / París',
        'Burdeos',
        'París',
        610,
        'Desayuno buffet y salida hacia la región de los castillos del Loire. Parada para admirar exteriormente uno de sus famosos castillos. Continuación a París. A última hora de la tarde recorrido por el París iluminado. Alojamiento.',
        'París',
        5
    ),

    (
        v_viaje_id,
        NULL,
        6,
        'Miércoles',
        'París',
        'París',
        'París',
        NULL,
        'Desayuno buffet. Recorrido de la ciudad, sus principales avenidas y monumentos: Isla de la Cité, Notre Dame, Arco de Triunfo, Campos Elíseos, Inválidos, Ópera y Torre Eiffel. Tarde libre. Se sugiere visita opcional a Versalles y espectáculo del Molino Rojo o Lido. Alojamiento.',
        'París',
        6
    ),

    (
        v_viaje_id,
        NULL,
        7,
        'Jueves',
        'París',
        'París',
        'París',
        NULL,
        'Desayuno buffet. Día destinado a pasear libremente por la ciudad, sus paseos y bulevares, y visitar opcionalmente el Museo del Louvre. Alojamiento.',
        'París',
        7
    ),

    (
        v_viaje_id,
        NULL,
        8,
        'Viernes',
        'París / Frankfurt - Paseo por el río Rin',
        'París',
        'Frankfurt',
        620,
        'Desayuno buffet y salida hacia la región del Champagne, prosiguiendo el viaje hacia Alemania. Llegada a las orillas del río Rin para realizar un paseo en barco desde Boppard hasta St. Goar. Continuación hacia Frankfurt. Tiempo libre en el centro de Frankfurt. Alojamiento en Frankfurt o alrededores.',
        'Frankfurt',
        8
    ),

    (
        v_viaje_id,
        NULL,
        9,
        'Sábado',
        'Frankfurt / Múnich',
        'Frankfurt',
        'Múnich',
        440,
        'Desayuno buffet y salida hacia una de las más bellas regiones de Alemania, conocida como la Alemania Romántica. Llegada a Múnich. Tarde libre para conocer la ciudad, su catedral, museos, palacios y edificios históricos. Alojamiento.',
        'Múnich',
        9
    ),

    (
        v_viaje_id,
        NULL,
        10,
        'Domingo',
        'Múnich / Salzburgo / Viena',
        'Múnich',
        'Viena',
        435,
        'Desayuno buffet. Salida hacia la frontera con Austria. Parada y tiempo libre en Salzburgo, ciudad natal de Mozart y Patrimonio de la Humanidad por la UNESCO. Continuación hacia Viena. Llegada y alojamiento.',
        'Viena',
        10
    ),

    (
        v_viaje_id,
        NULL,
        11,
        'Lunes',
        'Viena',
        'Viena',
        'Viena',
        NULL,
        'Desayuno buffet. Recorrido por la ciudad a lo largo de los Rings, admirando edificios como el museo de las artes aplicadas, la ópera, museos de bellas artes y ciencias, parlamento y ayuntamiento, hasta llegar al palacio de Schönbrunn. Tiempo libre. Alojamiento.',
        'Viena',
        11
    ),

    (
        v_viaje_id,
        NULL,
        12,
        'Martes',
        'Viena / Liubliana / Venecia',
        'Viena',
        'Venecia',
        625,
        'Desayuno y salida hacia Graz para cruzar la frontera con Eslovenia y llegar a Liubliana al mediodía. Tiempo libre para conocer su casco antiguo, mercado central y catedral de San Nicolás. Continuación a Venecia. Llegada a media tarde. Alojamiento.',
        'Venecia',
        12
    ),

    (
        v_viaje_id,
        NULL,
        13,
        'Miércoles',
        'Venecia / Padua / Florencia',
        'Venecia',
        'Florencia',
        475,
        'Desayuno buffet. Visita a pie de Venecia finalizando en la plaza de San Marcos e incluyendo visita a un taller del famoso cristal veneciano. Tiempo libre. Salida a Padua, con tiempo libre para visitar la basílica de San Antonio. Continuación a Florencia. Alojamiento.',
        'Florencia',
        13
    ),

    (
        v_viaje_id,
        NULL,
        14,
        'Jueves',
        'Florencia',
        'Florencia',
        'Florencia',
        NULL,
        'Desayuno. Recorrido por el centro artístico de la ciudad con su Duomo, Campanile de Giotto, Baptisterio de San Giovanni, iglesia de San Lorenzo, plaza de la Signoria, Loggia dei Lanzi y Santa Maria dei Fiore, terminando en el Ponte Vecchio. Tarde libre. Alojamiento.',
        'Florencia',
        14
    ),

    (
        v_viaje_id,
        NULL,
        15,
        'Viernes',
        'Florencia / Siena / Asís / Roma',
        'Florencia',
        'Roma',
        382,
        'Desayuno buffet y salida hacia Siena. Continuación hacia Asís, ciudad de San Francisco. Tiempo libre para almorzar y conocer las basílicas superior e inferior. Continuación a Roma. A última hora recorrido por la Roma iluminada. Alojamiento.',
        'Roma',
        15
    ),

    (
        v_viaje_id,
        NULL,
        16,
        'Sábado',
        'Roma',
        'Roma',
        'Roma',
        NULL,
        'Desayuno buffet. Visita panorámica de la ciudad eterna, incluyendo plaza de Venecia, monumento a Víctor Emmanuel II, Foros Imperiales y Romanos, San Juan de Letrán, templo de Vesta, Coliseo, Arco de Constantino, Via Veneto y castillo de Sant Angelo. Alojamiento.',
        'Roma',
        16
    ),

    (
        v_viaje_id,
        NULL,
        17,
        'Domingo',
        'Roma',
        'Roma',
        'Roma',
        NULL,
        'Desayuno. Día libre en Roma. Se sugiere excursión de todo el día para visitar Nápoles y la isla de Capri. Alojamiento.',
        'Roma',
        17
    ),

    (
        v_viaje_id,
        NULL,
        18,
        'Lunes',
        'Roma / Pisa / Cannes o Niza',
        'Roma',
        'Costa Azul',
        653,
        'Desayuno buffet y salida hacia Pisa. Tiempo libre para visitar el conjunto histórico con su famosa Torre Inclinada. Continuación hacia el norte siguiendo la costa por la Riviera de las Flores hasta Niza o Cannes. Alojamiento.',
        'Costa Azul',
        18
    ),

    (
        v_viaje_id,
        NULL,
        19,
        'Martes',
        'Cannes o Costa Azul / Barcelona',
        'Costa Azul',
        'Barcelona',
        682,
        'Desayuno. Salida hacia Arles, Nimes, Montpellier y Barcelona, donde se llegará a media tarde. Alojamiento.',
        'Barcelona',
        19
    ),

    (
        v_viaje_id,
        NULL,
        20,
        'Miércoles',
        'Barcelona',
        'Barcelona',
        'Barcelona',
        NULL,
        'Desayuno buffet. Visita de la ciudad recorriendo Plaza de Cataluña, Paseo de Gracia, Diagonal, Sagrada Familia de Gaudí, barrio Gótico con la catedral, Ramblas y parque de Montjuic. Tiempo libre. Alojamiento.',
        'Barcelona',
        20
    ),

    (
        v_viaje_id,
        NULL,
        21,
        'Jueves',
        'Barcelona / Zaragoza / Madrid',
        'Barcelona',
        'Madrid',
        635,
        'Desayuno y salida hacia Zaragoza, donde se realizará una breve parada junto a la basílica del Pilar. Continuación a Madrid. Alojamiento.',
        'Madrid',
        21
    ),

    (
        v_viaje_id,
        NULL,
        22,
        'Viernes',
        'Madrid / Salida',
        'Madrid',
        NULL,
        NULL,
        'Desayuno buffet. A la hora prevista traslado al aeropuerto para tomar vuelo de regreso. Fin de nuestros servicios.',
        NULL,
        22
    );


    -- ========================================================
    -- HOTELES
    -- ========================================================

    INSERT INTO public.viaje_hoteles (
        viaje_id,
        orden,
        ciudad,
        nombre_hotel,
        categoria
    )
    VALUES
        (v_viaje_id, 1, 'Madrid', 'Praga Hotel Mayorazgo', 'CONFORT'),
        (v_viaje_id, 2, 'Madrid', 'Praga Hotel Mayorazgo', 'SUPERIOR'),
        (v_viaje_id, 3, 'Burdeos', 'Novotel Bordeaux', 'CONFORT'),
        (v_viaje_id, 4, 'Burdeos', 'Novotel Bordeaux', 'SUPERIOR'),
        (v_viaje_id, 5, 'París', 'Ibis Porte D''Orleans', 'CONFORT'),
        (v_viaje_id, 6, 'París', 'Mercure Porte Orleans', 'SUPERIOR'),
        (v_viaje_id, 7, 'Frankfurt', 'Dorint', 'CONFORT'),
        (v_viaje_id, 8, 'Frankfurt', 'Leonardo Royal', 'SUPERIOR'),
        (v_viaje_id, 9, 'Múnich', 'Super 8 City West', 'CONFORT'),
        (v_viaje_id, 10, 'Múnich', 'Courtyard By Marriott', 'SUPERIOR'),
        (v_viaje_id, 11, 'Viena', 'Best Western Amedia', 'CONFORT'),
        (v_viaje_id, 12, 'Viena', 'Roomz Prater', 'SUPERIOR'),
        (v_viaje_id, 13, 'Venecia', 'Russot', 'CONFORT'),
        (v_viaje_id, 14, 'Venecia', 'Delfino', 'SUPERIOR'),
        (v_viaje_id, 15, 'Florencia', 'In Firenze Business', 'CONFORT'),
        (v_viaje_id, 16, 'Florencia', 'Nill', 'SUPERIOR'),
        (v_viaje_id, 17, 'Roma', 'Occidental Aran Park', 'CONFORT'),
        (v_viaje_id, 18, 'Roma', 'Barcelo Aran Mantegna', 'SUPERIOR'),
        (v_viaje_id, 19, 'Costa Azul', 'Amarante', 'CONFORT'),
        (v_viaje_id, 20, 'Costa Azul', 'Amarante', 'SUPERIOR'),
        (v_viaje_id, 21, 'Barcelona', 'Rialto', 'CONFORT'),
        (v_viaje_id, 22, 'Barcelona', 'Ac Som', 'SUPERIOR');


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
            'Traslados del aeropuerto al hotel y viceversa a la llegada y salida.'
        ),
        (
            v_viaje_id,
            2,
            'Alojamiento y desayuno buffet durante todo el recorrido en hoteles de la categoría elegida.'
        ),
        (
            v_viaje_id,
            3,
            'Transporte en autobús de turismo.'
        ),
        (
            v_viaje_id,
            4,
            'Acompañamiento de un guía durante todo el recorrido europeo en bus desde Madrid.'
        ),
        (
            v_viaje_id,
            5,
            'Visitas indicadas en el itinerario con guías de habla hispana.'
        ),
        (
            v_viaje_id,
            6,
            'Recorrido nocturno en Madrid, París y Roma.'
        ),
        (
            v_viaje_id,
            7,
            'Paseo en barco por el río Rin.'
        ),
        (
            v_viaje_id,
            8,
            'Seguro de protección y asistencia en viaje.'
        ),
        (
            v_viaje_id,
            9,
            'Bolsa de viaje.'
        ),
        (
            v_viaje_id,
            10,
            'Visitas con servicio de audio individual.'
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
            'Tasas de estancia.'
        ),
        (
            v_viaje_id,
            2,
            'Ningún servicio no mencionado en el apartado “incluye”.'
        );


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
        activo,
        orden
    )
    VALUES (
        v_viaje_id,
        'Paquete Plus (P+)',
        'Paquete Plus para el programa Querida Europa de 22 días / Madrid - Madrid. Incluye 11 comidas y 6 extras.',
        22,
        20,
        680.00,
        'USD',
        TRUE,
        1
    )
    RETURNING id INTO v_opcion_plus_id;


    -- ========================================================
    -- PAQUETE PLUS - COMIDAS
    -- ========================================================

    INSERT INTO public.viaje_opcion_items (
        opcion_id,
        tipo,
        descripcion,
        orden
    )
    VALUES
        (
            v_opcion_plus_id,
            'COMIDA',
            'Cena de tapas en Madrid.',
            1
        ),
        (
            v_opcion_plus_id,
            'COMIDA',
            'Almuerzo típico en Toledo.',
            2
        ),
        (
            v_opcion_plus_id,
            'COMIDA',
            'Almuerzo en San Sebastián.',
            3
        ),
        (
            v_opcion_plus_id,
            'COMIDA',
            'Almuerzo en crucero por el Rin.',
            4
        ),
        (
            v_opcion_plus_id,
            'COMIDA',
            'Cena en Múnich.',
            5
        ),
        (
            v_opcion_plus_id,
            'COMIDA',
            'Cena en Viena.',
            6
        ),
        (
            v_opcion_plus_id,
            'COMIDA',
            'Almuerzo en Florencia.',
            7
        ),
        (
            v_opcion_plus_id,
            'COMIDA',
            'Almuerzo en Asís.',
            8
        ),
        (
            v_opcion_plus_id,
            'COMIDA',
            'Almuerzo en Roma.',
            9
        ),
        (
            v_opcion_plus_id,
            'COMIDA',
            'Almuerzo en Pisa.',
            10
        ),
        (
            v_opcion_plus_id,
            'COMIDA',
            'Almuerzo en Puerto Olímpico.',
            11
        );


    -- ========================================================
    -- PAQUETE PLUS - EXTRAS
    -- ========================================================

    INSERT INTO public.viaje_opcion_items (
        opcion_id,
        tipo,
        descripcion,
        orden
    )
    VALUES
        (
            v_opcion_plus_id,
            'VISITA',
            'Visita a Toledo.',
            12
        ),
        (
            v_opcion_plus_id,
            'VISITA',
            'Paseo en Bateaux Mouche.',
            13
        ),
        (
            v_opcion_plus_id,
            'VISITA',
            'Subida a la Torre Eiffel, segundo piso.',
            14
        ),
        (
            v_opcion_plus_id,
            'VISITA',
            'Espectáculo de valses en Viena.',
            15
        ),
        (
            v_opcion_plus_id,
            'VISITA',
            'Paseo en góndola en Venecia.',
            16
        ),
        (
            v_opcion_plus_id,
            'VISITA',
            'El Vaticano: su museo y Capilla Sixtina.',
            17
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
        'Todos los viernes hasta abril de 2023',
        'Información histórica publicada por la fuente original. No representa una salida vigente.',
        FALSE
    );


    -- ========================================================
    -- VALIDACIONES
    -- ========================================================

    IF (
        SELECT COUNT(*)
        FROM public.viaje_itinerario
        WHERE viaje_id = v_viaje_id
    ) <> 22 THEN
        RAISE EXCEPTION 'V15: Se esperaban 22 días de itinerario.';
    END IF;


    IF (
        SELECT COUNT(*)
        FROM public.viaje_hoteles
        WHERE viaje_id = v_viaje_id
    ) <> 22 THEN
        RAISE EXCEPTION 'V15: Se esperaban 22 registros de hotel.';
    END IF;


    IF (
        SELECT COUNT(*)
        FROM public.viaje_inclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 10 THEN
        RAISE EXCEPTION 'V15: Se esperaban 10 inclusiones.';
    END IF;


    IF (
        SELECT COUNT(*)
        FROM public.viaje_exclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 2 THEN
        RAISE EXCEPTION 'V15: Se esperaban 2 exclusiones.';
    END IF;


    IF (
        SELECT COUNT(*)
        FROM public.viaje_opciones
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'V15: Se esperaba 1 opción comercial.';
    END IF;


    IF (
        SELECT COUNT(*)
        FROM public.viaje_opcion_items oi
        INNER JOIN public.viaje_opciones o
            ON o.id = oi.opcion_id
        WHERE o.viaje_id = v_viaje_id
    ) <> 17 THEN
        RAISE EXCEPTION 'V15: Se esperaban 17 items del Paquete Plus.';
    END IF;


    IF (
        SELECT COUNT(*)
        FROM public.viaje_salidas
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'V15: Se esperaba 1 salida histórica.';
    END IF;

END $$;
