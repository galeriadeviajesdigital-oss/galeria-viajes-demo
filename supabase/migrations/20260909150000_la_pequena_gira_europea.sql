-- ============================================================
-- V7 - LA PEQUENA GIRA EUROPEA
-- Fuente: galeriadeviajes.com
-- Programa: Londres / Madrid
-- Duracion: 22 dias / 21 noches
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
        RAISE EXCEPTION 'No existe el destino Europa';
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
        'La Pequeña Gira Europea',
        'la-pequena-gira-europea',
        'Circuito europeo de 22 días y 21 noches con inicio en Londres y final en Madrid. El recorrido incluye Londres, París, la región del Rin, Frankfurt, Múnich, Salzburgo, Viena, Liubliana, Venecia, Padua, Florencia, Siena, Asís, Roma, Pisa, la Costa Azul, Barcelona, Zaragoza y Madrid.',
        22,
        21,
        NULL,
        'USD',
        'Traslados del aeropuerto al hotel y viceversa a la llegada y salida. Alojamiento y desayuno buffet durante todo el recorrido en hoteles de la categoría elegida. Transporte en autobús de turismo y tren por Eurotunnel de Londres a París, indicando la fuente que en algunas salidas puede realizarse en ferry. Acompañamiento de un guía durante todo el recorrido europeo en bus. Visitas indicadas en el itinerario con guías de habla hispana. Paseo en barco por el río Rin. Visitas nocturnas de París, Roma y Madrid. Seguro de protección y asistencia en viaje MAPAPLUS. Bolsa de viaje. Visitas con servicio de audio individual.',
        'Paquete Plus P+ no incluido en el precio base.',
        NULL,
        true,
        true
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

    INSERT INTO public.viaje_itinerario
        (viaje_id, dia_numero, dia_semana, titulo, ciudad_origen, ciudad_destino, distancia_km, descripcion, alojamiento, orden)
    VALUES

    (
        v_viaje_id, 1, 'Sábado',
        'América - Londres',
        'América', 'Londres', NULL,
        'Salida en vuelo intercontinental con destino a Londres.',
        NULL, 1
    ),

    (
        v_viaje_id, 2, 'Domingo',
        'Londres',
        'Londres', 'Londres', NULL,
        'Llegada al aeropuerto de Heathrow y traslado al hotel. Alojamiento. Día libre para disfrutar de la ciudad y pasear por sus avenidas y llegar a Piccadilly Circus.',
        'Londres', 2
    ),

    (
        v_viaje_id, 3, 'Lunes',
        'Londres',
        'Londres', 'Londres', NULL,
        'Desayuno en el hotel y visita de la ciudad recorriendo Piccadilly Circus, Oxford Street, Trafalgar Square, abadía de Westminster y Palacio de Buckingham, con posibilidad de asistir al cambio de guardia si se realiza ese día. Tarde libre.',
        'Londres', 3
    ),

    (
        v_viaje_id, 4, 'Martes',
        'Londres - París por el Eurotunnel',
        'Londres', 'París', NULL,
        'Desayuno y salida hacia Folkestone donde el bus abordará el tren que conducirá a través del Canal de la Mancha por el Eurotunnel. Llegada a Calais y continuación por carretera a París. Por la tarde-noche recorrido por el París iluminado y paseo en barco por el Sena a bordo de los Bateaux Mouche, incluido en el Paquete Plus P+.',
        'París', 4
    ),

    (
        v_viaje_id, 5, 'Miércoles',
        'París',
        'París', 'París', NULL,
        'Desayuno buffet. Recorrido por la Isla de la Cité, Notre Dame, Arco de Triunfo, Campos Elíseos, Inválidos, Ópera y Torre Eiffel. La subida a la Torre Eiffel al segundo piso está incluida en el Paquete Plus P+. Tarde libre. Visita opcional a Versalles y posibilidad de espectáculo en el Molino Rojo o Lido.',
        'París', 5
    ),

    (
        v_viaje_id, 6, 'Jueves',
        'París',
        'París', 'París', NULL,
        'Desayuno buffet. Día libre para pasear por la ciudad, sus paseos y bulevares y visitar opcionalmente el Museo del Louvre.',
        'París', 6
    ),

    (
        v_viaje_id, 7, 'Viernes',
        'París - Frankfurt. Paseo por el río Rin',
        'París', 'Frankfurt', 620,
        'Salida hacia la región de Champagne y continuación hacia Alemania. Llegada a las orillas del río Rin para realizar un paseo en barco desde Boppard hasta St. Goar y continuación hacia Frankfurt. Almuerzo en el barco incluido en el Paquete Plus P+.',
        'Frankfurt o alrededores', 7
    ),

    (
        v_viaje_id, 8, 'Sábado',
        'Frankfurt - Múnich',
        'Frankfurt', 'Múnich', 440,
        'Salida hacia una de las regiones de Alemania conocida como la Alemania Romántica. Llegada a Múnich y tarde libre para conocer la ciudad, su catedral, museos, palacios y edificios históricos. Cena en cervecería típica de Baviera incluida en el Paquete Plus P+.',
        'Múnich', 8
    ),

    (
        v_viaje_id, 9, 'Domingo',
        'Múnich - Salzburgo - Viena',
        'Múnich', 'Viena', 435,
        'Salida hacia la frontera con Austria. Parada y tiempo libre en Salzburgo, ciudad natal de Mozart y Patrimonio de la Humanidad por la UNESCO. Continuación hacia Viena.',
        'Viena', 9
    ),

    (
        v_viaje_id, 10, 'Lunes',
        'Viena',
        'Viena', 'Viena', NULL,
        'Recorrido por la ciudad y los edificios del Ring hasta llegar al palacio de Schönbrunn, antigua residencia de la familia imperial. Tiempo libre. Se sugiere cena y espectáculo de valses vieneses y folklore austriaco, incluido en el Paquete Plus P+.',
        'Viena', 10
    ),

    (
        v_viaje_id, 11, 'Martes',
        'Viena - Liubliana - Venecia',
        'Viena', 'Venecia', 625,
        'Salida hacia Graz y cruce de la frontera con Eslovenia para llegar a Liubliana. Tiempo libre para conocer su casco antiguo, mercado central y catedral de San Nicolás. Continuación hacia Venecia.',
        'Venecia', 11
    ),

    (
        v_viaje_id, 12, 'Miércoles',
        'Venecia - Padua - Florencia',
        'Venecia', 'Florencia', 475,
        'Visita a pie de Venecia finalizando en la plaza de San Marcos e incluyendo visita a un taller de cristal veneciano. Tiempo libre para almorzar. Paseo en góndola opcional e incluido en P+. Salida hacia Padua con tiempo libre para visitar la basílica de San Antonio. Continuación a Florencia.',
        'Florencia', 12
    ),

    (
        v_viaje_id, 13, 'Jueves',
        'Florencia',
        'Florencia', 'Florencia', NULL,
        'Recorrido por el centro artístico de Florencia: Duomo, Campanile de Giotto, Baptisterio de San Giovanni, iglesia de San Lorenzo, plaza de la Signoria, Loggia dei Lanzi, Santa Maria dei Fiore y Ponte Vecchio. Almuerzo incluido en Paquete Plus P+. Por la tarde se sugiere visita al museo de la Academia.',
        'Florencia', 13
    ),

    (
        v_viaje_id, 14, 'Viernes',
        'Florencia - Siena - Asís - Roma',
        'Florencia', 'Roma', 382,
        'Salida hacia Siena y continuación hacia Asís, ciudad de San Francisco. Tiempo libre para almorzar y conocer las basílicas superior e inferior. Almuerzo incluido en Paquete Plus P+. Continuación a Roma y recorrido de la Roma iluminada.',
        'Roma', 14
    ),

    (
        v_viaje_id, 15, 'Sábado',
        'Roma',
        'Roma', 'Roma', NULL,
        'Visita opcional detallada del Vaticano, incluyendo museos, Capilla Sixtina y basílica. Visita al Museo Vaticano incluida en Paquete Plus P+. Recorrido panorámico de la ciudad eterna incluyendo plaza de Venecia, Foros Imperiales y Romanos, San Juan de Letrán, templo de Vesta, Coliseo, Arco de Constantino, Via Veneto y castillo de Sant Angelo. Almuerzo incluido en Paquete Plus P+.',
        'Roma', 15
    ),

    (
        v_viaje_id, 16, 'Domingo',
        'Roma',
        'Roma', 'Roma', NULL,
        'Desayuno. Día libre en Roma. Se sugiere excursión de todo el día para visitar Nápoles y la isla de Capri.',
        'Roma', 16
    ),

    (
        v_viaje_id, 17, 'Lunes',
        'Roma - Pisa - Cannes o Niza',
        'Roma', 'Cannes o Niza', 653,
        'Salida hacia Pisa con tiempo libre para visitar el conjunto histórico y su famosa Torre Inclinada. Almuerzo incluido en Paquete Plus P+. Continuación hacia el norte por la Riviera de las Flores hasta Cannes o Niza.',
        'Cannes o Niza', 17
    ),

    (
        v_viaje_id, 18, 'Martes',
        'Cannes o Niza - Barcelona',
        'Cannes o Niza', 'Barcelona', 682,
        'Salida hacia Arles, Nimes y Montpellier, continuando hasta Barcelona.',
        'Barcelona', 18
    ),

    (
        v_viaje_id, 19, 'Miércoles',
        'Barcelona',
        'Barcelona', 'Barcelona', NULL,
        'Visita de Barcelona recorriendo plaza de Cataluña, Paseo de Gracia, Diagonal, Sagrada Familia, barrio Gótico, catedral, Ramblas y parque de Montjuic. Tiempo libre para almorzar en el Puerto Olímpico. Almuerzo incluido en Paquete Plus P+.',
        'Barcelona', 19
    ),

    (
        v_viaje_id, 20, 'Jueves',
        'Barcelona - Zaragoza - Madrid',
        'Barcelona', 'Madrid', 635,
        'Salida hacia Zaragoza donde se efectuará una parada. Continuación a Madrid. Recorrido de Madrid iluminado y alrededores de la Plaza Mayor. Cena de tapas incluida en Paquete Plus P+.',
        'Madrid', 20
    ),

    (
        v_viaje_id, 21, 'Viernes',
        'Madrid',
        'Madrid', 'Madrid', NULL,
        'Visita de Madrid recorriendo Castellana, Gran Vía, Cibeles, Neptuno, Puerta de Alcalá, Cortes, Puerta del Sol y Plaza de Oriente. Tiempo libre. Excursión opcional a Toledo. Almuerzo y visita a Toledo incluidos en Paquete Plus P+.',
        'Madrid', 21
    ),

    (
        v_viaje_id, 22, 'Sábado',
        'Madrid - Salida',
        'Madrid', 'Salida', NULL,
        'Desayuno y traslado al aeropuerto para tomar el vuelo de regreso. Fin de los servicios.',
        NULL, 22
    );


    -- ========================================================
    -- HOTELES PREVISTOS O SIMILARES
    -- Se conserva el listado publicado por la fuente.
    -- ========================================================

    INSERT INTO public.viaje_hoteles
        (viaje_id, ciudad, nombre_hotel, categoria, observaciones, orden)
    VALUES

    (v_viaje_id, 'Londres', 'Ibis Earl Court', NULL, 'Hotel previsto o similar.', 1),
    (v_viaje_id, 'Londres', 'Royal National Hotel', NULL, 'Hotel previsto o similar.', 2),
    (v_viaje_id, 'Londres', 'Holiday Inn Kensington Forum', NULL, 'Hotel previsto o similar.', 3),

    (v_viaje_id, 'París', 'Ibis Porte de Orleans', NULL, 'Hotel previsto o similar.', 4),
    (v_viaje_id, 'París', 'Mercure Porte Versalles', NULL, 'Hotel previsto o similar.', 5),
    (v_viaje_id, 'París', 'Mercure Porte Orleans', NULL, 'Hotel previsto o similar.', 6),

    (v_viaje_id, 'Frankfurt', 'Novotel City', NULL, 'Hotel previsto o similar.', 7),
    (v_viaje_id, 'Frankfurt', 'Holiday Inn Express Messe', NULL, 'Hotel previsto o similar.', 8),
    (v_viaje_id, 'Frankfurt', 'Tryp By Wyndham', NULL, 'Hotel previsto o similar.', 9),
    (v_viaje_id, 'Frankfurt', 'Leonardo Royal', NULL, 'Hotel previsto o similar.', 10),
    (v_viaje_id, 'Frankfurt', 'Holiday Inn Alter Oper', NULL, 'Hotel previsto o similar.', 11),

    (v_viaje_id, 'Múnich', 'Feringapark', NULL, 'Hotel previsto o similar.', 12),
    (v_viaje_id, 'Múnich', 'Courtyard By Marriott', NULL, 'Hotel previsto o similar.', 13),
    (v_viaje_id, 'Múnich', 'Leonardo Royal', NULL, 'Hotel previsto o similar.', 14),

    (v_viaje_id, 'Viena', 'Best Western Amedia', NULL, 'Hotel previsto o similar.', 15),
    (v_viaje_id, 'Viena', 'Simms', NULL, 'Hotel previsto o similar.', 16),
    (v_viaje_id, 'Viena', 'Winberger', NULL, 'Hotel previsto o similar.', 17),
    (v_viaje_id, 'Viena', 'Kaiserwasser', NULL, 'Hotel previsto o similar.', 18),

    (v_viaje_id, 'Venecia', 'Russot', NULL, 'Hotel previsto o similar.', 19),
    (v_viaje_id, 'Venecia', 'Delfino', NULL, 'Hotel previsto o similar.', 20),
    (v_viaje_id, 'Venecia', 'Lugano Torreta', NULL, 'Hotel previsto o similar.', 21),

    (v_viaje_id, 'Florencia', 'IH Firenze Business', NULL, 'Hotel previsto o similar.', 22),
    (v_viaje_id, 'Florencia', 'Mirage', NULL, 'Hotel previsto o similar.', 23),
    (v_viaje_id, 'Florencia', 'Nil', NULL, 'Hotel previsto o similar.', 24),
    (v_viaje_id, 'Florencia', 'Raffaello', NULL, 'Hotel previsto o similar.', 25),

    (v_viaje_id, 'Roma', 'Occidental Aran Park', NULL, 'Hotel previsto o similar.', 26),
    (v_viaje_id, 'Roma', 'Barcelo Aran Mantegna', NULL, 'Hotel previsto o similar.', 27),
    (v_viaje_id, 'Roma', 'Shangrila', NULL, 'Hotel previsto o similar.', 28),

    (v_viaje_id, 'Costa Azul', 'Holiday Inn Cannes', NULL, 'Hotel previsto o similar.', 29),
    (v_viaje_id, 'Costa Azul', 'Amarante', NULL, 'Hotel previsto o similar.', 30),
    (v_viaje_id, 'Costa Azul', 'Hi Park', NULL, 'Hotel previsto o similar.', 31),

    (v_viaje_id, 'Barcelona', 'Hotel Medinacelli', NULL, 'Hotel previsto o similar.', 32),
    (v_viaje_id, 'Barcelona', 'AC Son', NULL, 'Hotel previsto o similar.', 33),

    (v_viaje_id, 'Madrid', 'Praga', NULL, 'Hotel previsto o similar.', 34),
    (v_viaje_id, 'Madrid', 'AC Cuzco', NULL, 'Hotel previsto o similar.', 35),
    (v_viaje_id, 'Madrid', 'Agumar', NULL, 'Hotel previsto o similar.', 36),
    (v_viaje_id, 'Madrid', 'Rafael Atocha', NULL, 'Hotel previsto o similar.', 37);


    -- ========================================================
    -- INCLUSIONES
    -- ========================================================

    INSERT INTO public.viaje_inclusiones
        (viaje_id, descripcion, orden)
    VALUES
    (v_viaje_id, 'Traslados del aeropuerto al hotel y viceversa a la llegada y salida.', 1),
    (v_viaje_id, 'Alojamiento y desayuno buffet durante todo el recorrido en hoteles de la categoría elegida.', 2),
    (v_viaje_id, 'Transporte en autobús de turismo y tren por Eurotunnel de Londres a París. En algunas salidas puede realizarse en ferry.', 3),
    (v_viaje_id, 'Acompañamiento de un guía durante todo el recorrido europeo en bus.', 4),
    (v_viaje_id, 'Visitas indicadas en el itinerario con guías de habla hispana.', 5),
    (v_viaje_id, 'Paseo en barco por el río Rin.', 6),
    (v_viaje_id, 'Visitas nocturnas de París, Roma y Madrid.', 7),
    (v_viaje_id, 'Seguro de protección y asistencia en viaje MAPAPLUS.', 8),
    (v_viaje_id, 'Bolsa de viaje.', 9),
    (v_viaje_id, 'Visitas con servicio de audio individual.', 10);


    -- ========================================================
    -- EXCLUSIONES
    -- ========================================================

    INSERT INTO public.viaje_exclusiones
        (viaje_id, descripcion, orden)
    VALUES
    (v_viaje_id, 'Paquete Plus P+ no incluido en el precio base.', 1);


    -- ========================================================
    -- PAQUETE PLUS
    -- ========================================================

    INSERT INTO public.viaje_opciones
        (viaje_id, nombre, descripcion, duracion_dias, duracion_noches, precio, moneda, activo, orden)
    VALUES
    (
        v_viaje_id,
        'Paquete Plus Londres / Madrid',
        'Paquete Plus P+ para el programa de 22 días Londres / Madrid. Incluye 10 comidas y 6 extras.',
        22,
        21,
        635.00,
        'USD',
        true,
        1
    )
    RETURNING id INTO v_opcion_id;


    -- ========================================================
    -- COMIDAS DEL PAQUETE PLUS
    -- ========================================================

    INSERT INTO public.viaje_opcion_items
        (opcion_id, tipo, descripcion, orden)
    VALUES
    (v_opcion_id, 'COMIDA', 'Almuerzo snack en barco.', 1),
    (v_opcion_id, 'COMIDA', 'Cena en Múnich.', 2),
    (v_opcion_id, 'COMIDA', 'Cena en Viena.', 3),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Florencia.', 4),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Siena.', 5),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Roma.', 6),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Pisa.', 7),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Puerto Olímpico.', 8),
    (v_opcion_id, 'COMIDA', 'Cena de tapas en Madrid.', 9),
    (v_opcion_id, 'COMIDA', 'Almuerzo típico en Toledo.', 10),

    -- ======================================================
    -- EXTRAS
    -- ======================================================

    (v_opcion_id, 'VISITA', 'Paseo en Bateaux Mouche.', 11),
    (v_opcion_id, 'VISITA', 'Subida a la Torre Eiffel, segundo piso.', 12),
    (v_opcion_id, 'VISITA', 'Espectáculo de valses en Viena.', 13),
    (v_opcion_id, 'VISITA', 'Paseo en góndola en Venecia.', 14),
    (v_opcion_id, 'VISITA', 'El Vaticano: su museo y Capilla Sixtina.', 15),
    (v_opcion_id, 'VISITA', 'Visita a Toledo.', 16);


    -- ========================================================
    -- SALIDA
    -- ========================================================

    INSERT INTO public.viaje_salidas
        (viaje_id, fecha_inicio, fecha_fin, texto_original, observaciones, activo)
    VALUES
    (
        v_viaje_id,
        NULL,
        NULL,
        NULL,
        'La fuente consultada no publica una fecha concreta de salida en el contenido extraído. El programa corresponde a 22 días / 21 noches Londres / Madrid.',
        true
    );


    -- ========================================================
    -- VALIDACION
    -- ========================================================

    IF (
        SELECT COUNT(*)
        FROM public.viaje_itinerario
        WHERE viaje_id = v_viaje_id
    ) <> 22 THEN
        RAISE EXCEPTION 'Validación fallida: itinerario';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_hoteles
        WHERE viaje_id = v_viaje_id
    ) <> 37 THEN
        RAISE EXCEPTION 'Validación fallida: hoteles';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_inclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 10 THEN
        RAISE EXCEPTION 'Validación fallida: inclusiones';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_exclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'Validación fallida: exclusiones';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_opciones
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'Validación fallida: opciones';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_opcion_items
        WHERE opcion_id = v_opcion_id
    ) <> 16 THEN
        RAISE EXCEPTION 'Validación fallida: items Paquete Plus';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_salidas
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'Validación fallida: salidas';
    END IF;

END $$;
