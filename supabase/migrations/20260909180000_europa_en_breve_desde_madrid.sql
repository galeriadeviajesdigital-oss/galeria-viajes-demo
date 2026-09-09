-- ============================================================
-- V10 - EUROPA EN BREVE "DESDE MADRID"
-- Fuente:
-- https://www.galeriadeviajes.com/es/packets/europa-en-breve-desde-madrid
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
        'Europa en Breve "desde Madrid"',
        'europa-en-breve-desde-madrid',
        'Circuito europeo con inicio y final en Madrid recorriendo San Sebastian, Burdeos, region del Loire, Paris, Rin, Frankfurt, Heidelberg, Lucerna, Zurich, Innsbruck, Venecia, Padua, Florencia, Roma, Pisa, Costa Azul, Barcelona y Zaragoza.',
        18,
        17,
        NULL,
        'USD',
        'Traslados de aeropuerto; alojamiento y desayuno; transporte en autobus de turismo; acompanamiento de guia; visitas indicadas con guias locales de habla hispana; paseo en barco por el Rin; camarote en ferry Roma-Barcelona opcion en barco; seguro de proteccion y asistencia en viaje; bolsa de viaje; visitas con servicio de audio individual.',
        'Tasas de estancia e impuestos hoteleros cobrados por autoridades locales; servicios no mencionados en incluye; Paquete Plus.',
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
        v_viaje_id, 1, 'Viernes',
        'San Jose / Madrid',
        'San Jose', 'Madrid', NULL,
        'Salida en vuelo internacional con destino a Madrid. Noche a bordo.',
        NULL, 1
    ),
    (
        v_viaje_id, 2, 'Sabado',
        'Madrid',
        'Madrid', 'Madrid', NULL,
        'Llegada al aeropuerto y traslado al hotel. Dia libre. A ultima hora de la tarde recorrido por el Madrid iluminado y alrededores de la Plaza Mayor. Cena de tapas incluida en el Paquete Plus.',
        'Madrid', 2
    ),
    (
        v_viaje_id, 3, 'Domingo',
        'Madrid',
        'Madrid', 'Madrid', NULL,
        'Desayuno buffet. Visita de la ciudad recorriendo Castellana, Gran Via, Cibeles y Neptuno, Puerta de Alcala, Las Cortes, Puerta del Sol, Plaza Mayor, Plaza de Oriente y Madrid moderno. Tarde libre. Excursion opcional a Toledo con almuerzo tipico y visita incluida en Paquete Plus.',
        'Madrid', 3
    ),
    (
        v_viaje_id, 4, 'Lunes',
        'Madrid / San Sebastian / Burdeos',
        'Madrid', 'Burdeos', 690,
        'Desayuno buffet y salida hacia San Sebastian. Tiempo libre para comer, con almuerzo incluido en Paquete Plus. Continuacion hacia Francia y llegada a Burdeos.',
        'Burdeos', 4
    ),
    (
        v_viaje_id, 5, 'Martes',
        'Burdeos / Region del Loire / Paris',
        'Burdeos', 'Paris', 610,
        'Salida hacia la region de los castillos del Loire con parada para admirar exteriormente uno de sus famosos castillos. Continuacion a Paris. Recorrido por el Paris iluminado y posibilidad de paseo en Bateaux Mouche, incluido en Paquete Plus.',
        'Paris', 5
    ),
    (
        v_viaje_id, 6, 'Miercoles',
        'Paris',
        'Paris', 'Paris', NULL,
        'Recorrido de la ciudad y principales monumentos. Subida a la Torre Eiffel hasta el segundo piso incluida en Paquete Plus. Tarde libre. Posibilidad de excursion a Versalles y espectaculo nocturno.',
        'Paris', 6
    ),
    (
        v_viaje_id, 7, 'Jueves',
        'Paris',
        'Paris', 'Paris', NULL,
        'Dia libre en Paris para pasear por la ciudad, visitar museos o realizar excursiones opcionales.',
        'Paris', 7
    ),
    (
        v_viaje_id, 8, 'Viernes',
        'Paris / Frankfurt - Paseo por el Rin',
        'Paris', 'Frankfurt', 620,
        'Salida hacia la region de Champagne y Alemania. Paseo en barco por el Rin entre Boppard y St Goar con almuerzo snack incluido en Paquete Plus. Continuacion a Frankfurt.',
        'Frankfurt', 8
    ),
    (
        v_viaje_id, 9, 'Sabado',
        'Frankfurt / Heidelberg / Lucerna / Zurich',
        'Frankfurt', 'Zurich', 514,
        'Salida hacia Heidelberg. Tiempo libre y continuacion bordeando la Selva Negra hacia Basilea para entrar en Suiza. Continuacion a Lucerna y Zurich.',
        'Zurich', 9
    ),
    (
        v_viaje_id, 10, 'Domingo',
        'Zurich / Innsbruck / Venecia',
        'Zurich', 'Venecia', 685,
        'Salida hacia la region del Tirol austriaco llegando a Innsbruck. Tiempo libre para almuerzo y paseo por el centro historico. Almuerzo incluido en Paquete Plus. Llegada a Venecia.',
        'Venecia', 10
    ),
    (
        v_viaje_id, 11, 'Lunes',
        'Venecia / Padua / Florencia',
        'Venecia', 'Florencia', NULL,
        'Visita a pie de Venecia finalizando en Plaza de San Marcos e incluyendo visita a taller de cristal veneciano. Posibilidad de paseo en gondola incluido en Paquete Plus. Salida a Padua y continuacion a Florencia.',
        'Florencia', 11
    ),
    (
        v_viaje_id, 12, 'Martes',
        'Florencia / Roma',
        'Florencia', 'Roma', 290,
        'Recorrido por el centro artistico de Florencia. Almuerzo incluido en Paquete Plus. Por la tarde salida hacia Roma. Recorrido de la Roma iluminada.',
        'Roma', 12
    ),
    (
        v_viaje_id, 13, 'Miercoles',
        'Roma',
        'Roma', 'Roma', NULL,
        'Visita panoramica de Roma y posibilidad de visita al Vaticano, incluyendo museos y Capilla Sixtina, incluida en Paquete Plus. Almuerzo incluido en Paquete Plus. Tarde libre.',
        'Roma', 13
    ),
    (
        v_viaje_id, 14, 'Jueves',
        'Roma',
        'Roma', 'Roma', NULL,
        'Dia libre en Roma. Se sugiere excursion de todo el dia a Napoles y Capri.',
        'Roma', 14
    ),
    (
        v_viaje_id, 15, 'Viernes',
        'Roma / Pisa / Cannes o Costa Azul',
        'Roma', 'Costa Azul', 680,
        'Salida hacia Pisa. Tiempo libre para visitar el conjunto historico y la torre inclinada. Almuerzo incluido en Paquete Plus. Continuacion hacia la Riviera de las Flores y Costa Azul o Cannes.',
        'Costa Azul', 15
    ),
    (
        v_viaje_id, 16, 'Sabado',
        'Cannes o Costa Azul / Barcelona',
        'Costa Azul', 'Barcelona', 648,
        'Salida hacia la frontera con Espana. Llegada a Barcelona y breve recorrido panoramico para admirar la Sagrada Familia y la panoramica desde Montjuic.',
        'Barcelona', 16
    ),
    (
        v_viaje_id, 17, 'Domingo',
        'Barcelona / Zaragoza / Madrid',
        'Barcelona', 'Madrid', 630,
        'Salida hacia Zaragoza con breve parada junto a la Basilica del Pilar. Continuacion a Madrid.',
        'Madrid', 17
    ),
    (
        v_viaje_id, 18, 'Lunes',
        'Madrid / Salida',
        'Madrid', 'Madrid', NULL,
        'Desayuno. Traslado al aeropuerto para tomar el vuelo de salida. Fin de nuestros servicios.',
        NULL, 18
    );


    -- ========================================================
    -- HOTELES
    -- ========================================================
    -- La fuente presenta varias alternativas agrupadas por ciudad.
    -- Debido al formato de origen, se preservan los nombres sin
    -- asignar categorias cuando la asociacion no es inequívoca.

    INSERT INTO public.viaje_hoteles (
        viaje_id,
        ciudad,
        nombre_hotel,
        categoria,
        orden
    )
    VALUES

    -- Madrid - inicio
    (v_viaje_id, 'Madrid', 'Praga / Holiday Inn Piramides / Muralto / Mayorazgo / Cuzco / Agumar / Rafael Atocha', NULL, 1),

    -- Burdeos
    (v_viaje_id, 'Burdeos', 'Novotel Bordeaux Le Lac', NULL, 2),

    -- Paris
    (v_viaje_id, 'Paris', 'Ibis Porte de Orleans', NULL, 3),
    (v_viaje_id, 'Paris', 'Mercure Porte Versalles / Mercure Porte Orleans', NULL, 4),

    -- Frankfurt
    (v_viaje_id, 'Frankfurt', 'NH Morfelden / Holiday Inn Express Messe / Tryp By Wyndham / Dorint', NULL, 5),
    (v_viaje_id, 'Frankfurt', 'Leonardo Royal / Holiday Inn Frankfurt-Alte Oper / Qgreen By Melia / Maritim', NULL, 6),

    -- Zurich
    (v_viaje_id, 'Zurich', 'Dorint / Novotel Airport Messe / Holiday Inn Messe / NH Messe / Zuri by Fassbind', NULL, 7),

    -- Venecia
    (v_viaje_id, 'Venecia', 'Russot / Alexander', NULL, 8),
    (v_viaje_id, 'Venecia', 'Lugano Torreta / Delfino', NULL, 9),

    -- Florencia
    (v_viaje_id, 'Florencia', 'IH Florence Business / Grifone', NULL, 10),
    (v_viaje_id, 'Florencia', 'Palazzo Ricasolli / Nill', NULL, 11),

    -- Roma
    (v_viaje_id, 'Roma', 'Occidental Aran Park / Sheraton Parco de Medici', NULL, 12),
    (v_viaje_id, 'Roma', 'Barcelo Aran Mantegna / Cristoforo Colombo', NULL, 13),

    -- Costa Azul
    (v_viaje_id, 'Costa Azul', 'Holiday Inn Cannes / Amarante / Hi Park / Cannes Palace / Hipark Suites Nice', NULL, 14),

    -- Barcelona
    (v_viaje_id, 'Barcelona', 'Barbera Park / Rafael Badalona', NULL, 15),
    (v_viaje_id, 'Barcelona', 'Porta Fira / AC Som', NULL, 16),

    -- Madrid - regreso
    (v_viaje_id, 'Madrid', 'Praga / Holiday Inn Piramides / Muralto / Chamartin', NULL, 17),
    (v_viaje_id, 'Madrid', 'Mayorazgo / Cuzco / Agumar / Rafael Atocha', NULL, 18);


    -- ========================================================
    -- INCLUSIONES
    -- ========================================================

    INSERT INTO public.viaje_inclusiones (
        viaje_id,
        descripcion,
        orden
    )
    VALUES
    (v_viaje_id, 'Traslados del aeropuerto al hotel y viceversa.', 1),
    (v_viaje_id, 'Alojamiento y desayuno durante todo el recorrido en hoteles de la categoria elegida.', 2),
    (v_viaje_id, 'Transporte en autobus de turismo.', 3),
    (v_viaje_id, 'Acompanamiento de un guia durante todo el recorrido europeo en bus.', 4),
    (v_viaje_id, 'Visitas indicadas en el itinerario con guias locales de habla hispana.', 5),
    (v_viaje_id, 'Paseo en barco por el rio Rin.', 6),
    (v_viaje_id, 'Camarote en ferry Roma-Barcelona opcion en barco.', 7),
    (v_viaje_id, 'Seguro de proteccion y asistencia en viaje.', 8),
    (v_viaje_id, 'Bolsa de viaje.', 9),
    (v_viaje_id, 'Visitas con servicio de audio individual.', 10);


    -- ========================================================
    -- EXCLUSIONES
    -- ========================================================

    INSERT INTO public.viaje_exclusiones (
        viaje_id,
        descripcion,
        orden
    )
    VALUES
    (v_viaje_id, 'Tasas de estancia e impuestos de los establecimientos hoteleros que se cobran por las autoridades locales en determinadas ciudades.', 1),
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
        'Paquete Plus Madrid / Madrid. Incluye 07 comidas y 05 extras por USD 425.',
        18,
        17,
        425,
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
    (v_opcion_id, 'COMIDA', 'Almuerzo en Toledo.', 2),
    (v_opcion_id, 'COMIDA', 'Almuerzo en San Sebastian.', 3),
    (v_opcion_id, 'COMIDA', 'Almuerzo snack en barco por el Rin.', 4),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Florencia.', 5),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Roma.', 6),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Pisa.', 7),
    (v_opcion_id, 'VISITA', 'Visita a Toledo.', 8),
    (v_opcion_id, 'VISITA', 'Paseo en Bateaux Mouche.', 9),
    (v_opcion_id, 'VISITA', 'Subida a la Torre Eiffel, segundo piso.', 10),
    (v_opcion_id, 'VISITA', 'Paseo en Gondola en Venecia.', 11),
    (v_opcion_id, 'VISITA', 'Vaticano: museos y Capilla Sixtina.', 12);


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
    ) <> 18 THEN
        RAISE EXCEPTION 'V10: cantidad de itinerarios incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_hoteles
        WHERE viaje_id = v_viaje_id
    ) <> 18 THEN
        RAISE EXCEPTION 'V10: cantidad de hoteles incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_inclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 10 THEN
        RAISE EXCEPTION 'V10: cantidad de inclusiones incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_exclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 3 THEN
        RAISE EXCEPTION 'V10: cantidad de exclusiones incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_opciones
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'V10: cantidad de opciones incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_opcion_items oi
        JOIN public.viaje_opciones o
            ON o.id = oi.opcion_id
        WHERE o.viaje_id = v_viaje_id
    ) <> 12 THEN
        RAISE EXCEPTION 'V10: cantidad de items de opcion incorrecta';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_salidas
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'V10: cantidad de salidas incorrecta';
    END IF;


    RAISE NOTICE 'V10 EUROPA EN BREVE DESDE MADRID cargada correctamente.';
    RAISE NOTICE 'Viaje ID: %', v_viaje_id;
    RAISE NOTICE 'Itinerario: 18';
    RAISE NOTICE 'Hoteles: 18';
    RAISE NOTICE 'Inclusiones: 10';
    RAISE NOTICE 'Exclusiones: 3';
    RAISE NOTICE 'Opciones: 1';
    RAISE NOTICE 'Items opcion: 12';
    RAISE NOTICE 'Salidas: 1';

END $$;
