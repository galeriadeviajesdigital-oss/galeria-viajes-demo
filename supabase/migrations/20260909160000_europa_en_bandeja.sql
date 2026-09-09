-- ============================================================
-- V8 - EUROPA EN BANDEJA
-- Fuente: galeriadeviajes.com
-- Duracion: 26 dias / 25 noches
-- Precio publicado: USD 2165
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
        'Europa en Bandeja',
        'europa-en-bandeja',
        'Circuito europeo de 26 días y 25 noches con inicio en Londres y final en Madrid. El recorrido incluye Londres, París, Bruselas, Gante, Brujas, Amberes, La Haya, Amsterdam, Colonia, el Rin, Frankfurt, Múnich, Salzburgo, Viena, Liubliana, Venecia, Padua, Florencia, Siena, Asís, Roma, Pisa, Costa Azul, Barcelona, Zaragoza y Madrid.',
        26,
        25,
        2165.00,
        'USD',
        'Traslados del aeropuerto al hotel y viceversa a la llegada y salida. Alojamiento y desayuno buffet durante todo el recorrido en hoteles de la categoría elegida. Transporte en autobús de turismo con guía acompañante durante el recorrido de bus. Visitas guiadas con guía de habla hispana. Visitas nocturnas en París, Roma y Madrid. Trayecto en bus y tren en Eurotunnel de Londres a París; en algunas salidas puede realizarse en Ferry. Paseo en barco por el río Rin. Seguro de protección y asistencia en viaje MAPAPLUS. Bolsa de viaje. Visitas con servicio de audio individual.',
        'Tasas de estancia en Italia (Venecia, Florencia y Roma). Ningún servicio no mencionado en el apartado incluye. Paquete Plus P+.',
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
        v_viaje_id, 1, 'Martes',
        'América',
        'América', 'Londres', NULL,
        'Salida en vuelo internacional con destino a Londres.',
        NULL, 1
    ),

    (
        v_viaje_id, 2, 'Miércoles',
        'Llegada a Londres',
        'Londres', 'Londres', NULL,
        'Llegada al aeropuerto de Heathrow. Día libre para tomar contacto con la ciudad y pasear por el centro comercial de esta gran urbe.',
        'Londres', 2
    ),

    (
        v_viaje_id, 3, 'Jueves',
        'Londres',
        'Londres', 'Londres', NULL,
        'Desayuno en el hotel y visita de la ciudad recorriendo Piccadilly Circus, Oxford Street, Trafalgar Square, Abadía de Westminster y terminando frente al Palacio de Buckingham para asistir al cambio de guardia si se realiza ese día. Tarde libre.',
        'Londres', 3
    ),

    (
        v_viaje_id, 4, 'Viernes',
        'Londres - París por el Eurotunnel',
        'Londres', 'París', NULL,
        'Salida hacia Folkestone donde el bus abordará el tren que conducirá a través del Canal de la Mancha por el Eurotunnel. Llegada a Calais y continuación por carretera a París. Por la tarde recorrido por el París iluminado y paseo en barco por el Sena a bordo de los Bateaux Mouche, incluido en el Paquete Plus P+.',
        'París', 4
    ),

    (
        v_viaje_id, 5, 'Sábado',
        'París',
        'París', 'París', NULL,
        'Desayuno buffet. Recorrido de la ciudad y sus principales avenidas y monumentos, con oportunidad de subir a la Torre Eiffel. La subida al segundo piso está incluida en el Paquete Plus P+. Tarde libre. Se sugiere visita opcional a Versalles.',
        'París', 5
    ),

    (
        v_viaje_id, 6, 'Domingo',
        'París',
        'París', 'París', NULL,
        'Desayuno buffet. Día libre para pasear por la ciudad, sus paseos y bulevares. Se sugiere visitar opcionalmente Montmartre y la catedral de Notre Dame. Por la noche posibilidad de asistir a un espectáculo en un cabaret parisino. Cabaret Paradis Latin con bebidas incluido en el Paquete Plus P+.',
        'París', 6
    ),

    (
        v_viaje_id, 7, 'Lunes',
        'París - Bruselas',
        'París', 'Bruselas', 252,
        'Desayuno buffet y salida hacia Bruselas. Llegada y visita panorámica de la ciudad. Tiempo libre. Posibilidad de cena típica en el entorno de la Grand Platz, incluida en el Paquete Plus P+.',
        'Bruselas', 7
    ),

    (
        v_viaje_id, 8, 'Martes',
        'Bruselas - Gante - Brujas',
        'Bruselas', 'Brujas', 168,
        'Salida hacia Gante, con su catedral de San Bavon y casco antiguo medieval. Continuación a Brujas, ciudad de canales. Almuerzo incluido en Paquete Plus P+. Visita de la ciudad incluyendo el Lago de Amor, Beaterio, Plaza Mayor y torre de la Atalaya. Posibilidad de paseo en barco por los canales, incluido en Paquete Plus P+.',
        'Brujas', 8
    ),

    (
        v_viaje_id, 9, 'Miércoles',
        'Brujas - Amberes - La Haya - Amsterdam',
        'Brujas', 'Amsterdam', 280,
        'Salida hacia Amberes, ciudad de Rubens y puerto de importancia europea. Tiempo libre y continuación a La Haya, capital administrativa de Holanda. Llegada a Amsterdam al mediodía. Por la tarde visita de la ciudad a bordo de un barco por sus canales y visita a una fábrica de talla de diamantes.',
        'Amsterdam', 9
    ),

    (
        v_viaje_id, 10, 'Jueves',
        'Amsterdam',
        'Amsterdam', 'Amsterdam', NULL,
        'Desayuno buffet. Día libre para disfrutar de la ciudad. Se sugiere visita a Volendam y Marken, además de una fábrica de queso holandés. Visita y almuerzo incluidos en el Paquete Plus P+.',
        'Amsterdam', 10
    ),

    (
        v_viaje_id, 11, 'Viernes',
        'Amsterdam - Colonia - El Rin - Frankfurt',
        'Amsterdam', 'Frankfurt', 510,
        'Salida hacia Colonia. Tiempo libre para visitar su catedral. Continuación bordeando el río Rin hasta Boppard, donde se embarcará para realizar un crucero por el río hasta St. Goar. Almuerzo snack en el barco incluido en Paquete Plus P+. Continuación a Frankfurt.',
        'Frankfurt', 11
    ),

    (
        v_viaje_id, 12, 'Sábado',
        'Frankfurt - Múnich',
        'Frankfurt', 'Múnich', 440,
        'Salida hacia una de las más bellas regiones de Alemania, conocida como la Alemania Romántica. Llegada a Múnich. Tarde libre para conocer la ciudad, su catedral, museos, palacios y edificios históricos. Cena en cervecería típica de Baviera incluida en Paquete Plus P+.',
        'Múnich', 12
    ),

    (
        v_viaje_id, 13, 'Domingo',
        'Múnich - Salzburgo - Viena',
        'Múnich', 'Viena', 435,
        'Salida hacia la frontera con Austria. Parada y tiempo libre en Salzburgo, ciudad natal de Mozart y Patrimonio de la Humanidad por la UNESCO. Continuación hacia Viena.',
        'Viena', 13
    ),

    (
        v_viaje_id, 14, 'Lunes',
        'Viena',
        'Viena', 'Viena', NULL,
        'Desayuno buffet y recorrido por la ciudad a lo largo de los Rings hasta llegar al palacio de Schönbrunn, antigua residencia de la familia imperial. Tiempo libre. Cena y espectáculo de valses vieneses y folklore austriaco incluidos en Paquete Plus P+.',
        'Viena', 14
    ),

    (
        v_viaje_id, 15, 'Martes',
        'Viena - Liubliana - Venecia',
        'Viena', 'Venecia', 625,
        'Salida hacia Graz y cruce de la frontera con Eslovenia hasta Liubliana. Tiempo libre para recorrer su casco antiguo, mercado central y catedral de San Nicolás. Continuación hacia Venecia.',
        'Venecia', 15
    ),

    (
        v_viaje_id, 16, 'Miércoles',
        'Venecia - Padua - Florencia',
        'Venecia', 'Florencia', 475,
        'Visita a pie de Venecia finalizando en la plaza de San Marcos e incluyendo visita a un taller de cristal veneciano. Tiempo libre para almorzar. Paseo en góndola incluido en Paquete Plus P+. Salida hacia Padua con tiempo libre para visitar la basílica de San Antonio. Continuación a Florencia.',
        'Florencia', 16
    ),

    (
        v_viaje_id, 17, 'Jueves',
        'Florencia',
        'Florencia', 'Florencia', NULL,
        'Recorrido por el centro artístico de la ciudad con su Duomo, Campanile de Giotto, Baptisterio de San Giovanni, iglesia de San Lorenzo, plaza de la Signoria, Loggia dei Lanzi y Ponte Vecchio. Almuerzo incluido en Paquete Plus P+. Por la tarde se sugiere visitar el museo de la Academia para admirar el David de Miguel Ángel.',
        'Florencia', 17
    ),

    (
        v_viaje_id, 18, 'Viernes',
        'Florencia - Siena - Asís - Roma',
        'Florencia', 'Roma', 382,
        'Salida hacia Siena y continuación a Asís, ciudad de San Francisco. Tiempo libre para almorzar y conocer las basílicas superior e inferior. Almuerzo incluido en Paquete Plus P+. Continuación a Roma y recorrido de la Roma iluminada.',
        'Roma', 18
    ),

    (
        v_viaje_id, 19, 'Sábado',
        'Roma',
        'Roma', 'Roma', NULL,
        'Desayuno. Día libre en Roma. Se sugiere excursión de todo el día para visitar Nápoles y la isla de Capri.',
        'Roma', 19
    ),

    (
        v_viaje_id, 20, 'Domingo',
        'Roma',
        'Roma', 'Roma', NULL,
        'Desayuno. Día libre en Roma. Se sugiere excursión de todo el día para visitar Nápoles y la isla de Capri.',
        'Roma', 20
    ),

    (
        v_viaje_id, 21, 'Lunes',
        'Roma - Pisa - Cannes o Costa Azul',
        'Roma', 'Costa Azul o Cannes', 653,
        'Salida hacia Pisa. Tiempo libre para visitar el conjunto histórico y su famosa Torre Inclinada. Almuerzo incluido en Paquete Plus P+. Continuación hacia el norte siguiendo la costa por la Riviera de las Flores hasta Costa Azul o Cannes.',
        'Costa Azul o Cannes', 21
    ),

    (
        v_viaje_id, 22, 'Martes',
        'Cannes o Costa Azul - Barcelona',
        'Costa Azul o Cannes', 'Barcelona', 682,
        'Salida hacia Arles, Nimes y Montpellier y continuación hacia Barcelona, donde se llegará a media tarde.',
        'Barcelona', 22
    ),

    (
        v_viaje_id, 23, 'Miércoles',
        'Barcelona',
        'Barcelona', 'Barcelona', NULL,
        'Visita de Barcelona recorriendo Plaza de Cataluña, Paseo de Gracia, Diagonal, Sagrada Familia, barrio Gótico, catedral, Ramblas y parque de Montjuic. Tiempo libre para almorzar en el Puerto Olímpico. Almuerzo incluido en Paquete Plus P+.',
        'Barcelona', 23
    ),

    (
        v_viaje_id, 24, 'Jueves',
        'Barcelona - Zaragoza - Madrid',
        'Barcelona', 'Madrid', 635,
        'Salida hacia Zaragoza donde se efectuará una parada. Continuación a Madrid. Llegada y alojamiento. Recorrido de Madrid iluminado y alrededores de la Plaza Mayor. Cena de tapas incluida en Paquete Plus P+.',
        'Madrid', 24
    ),

    (
        v_viaje_id, 25, 'Viernes',
        'Madrid',
        'Madrid', 'Madrid', NULL,
        'Visita de Madrid recorriendo Castellana, Gran Vía, Cibeles, Neptuno, Puerta de Alcalá, Cortes, Puerta del Sol y Plaza de Oriente. Tiempo libre para almorzar. Excursión opcional a Toledo. Almuerzo y visita a Toledo incluidos en Paquete Plus P+.',
        'Madrid', 25
    ),

    (
        v_viaje_id, 26, 'Sábado',
        'Madrid - Salida',
        'Madrid', 'Salida', NULL,
        'Desayuno. Traslado al aeropuerto para tomar el vuelo de regreso. Fin de nuestros servicios.',
        NULL, 26
    );


    -- ========================================================
    -- HOTELES PREVISTOS O SIMILARES
    -- Se conservan los nombres publicados.
    -- No se asigna categoria porque la estructura extraida
    -- mezcla las columnas Confort y Superior.
    -- ========================================================

    INSERT INTO public.viaje_hoteles
        (viaje_id, ciudad, nombre_hotel, categoria, observaciones, orden)
    VALUES

    (v_viaje_id, 'Londres', 'Ibis Earl Court', NULL, 'Hotel previsto o similar.', 1),
    (v_viaje_id, 'Londres', 'Royal National', NULL, 'Hotel previsto o similar.', 2),
    (v_viaje_id, 'Londres', 'Holiday Inn Kensington Forum', NULL, 'Hotel previsto o similar.', 3),

    (v_viaje_id, 'París', 'Ibis Porte de Orleans', NULL, 'Hotel previsto o similar.', 4),
    (v_viaje_id, 'París', 'Mercure Porte Orleans', NULL, 'Hotel previsto o similar.', 5),

    (v_viaje_id, 'Bruselas', 'Hilton Garden Inn Louise', NULL, 'Hotel previsto o similar.', 6),
    (v_viaje_id, 'Bruselas', 'Novotel Center Midi Station', NULL, 'Hotel previsto o similar.', 7),
    (v_viaje_id, 'Bruselas', 'Hilton Garden Inn Louise', NULL, 'Hotel previsto o similar.', 8),
    (v_viaje_id, 'Bruselas', 'Novotel Center Midi Station', NULL, 'Hotel previsto o similar.', 9),

    (v_viaje_id, 'Brujas', 'Green Park', NULL, 'Hotel previsto o similar.', 10),
    (v_viaje_id, 'Brujas', 'Floris Velotel', NULL, 'Hotel previsto o similar.', 11),

    (v_viaje_id, 'Amsterdam', 'Corendon', NULL, 'Hotel previsto o similar.', 12),
    (v_viaje_id, 'Amsterdam', 'Courtyard Marriott', NULL, 'Hotel previsto o similar.', 13),
    (v_viaje_id, 'Amsterdam', 'Corendon', NULL, 'Hotel previsto o similar.', 14),
    (v_viaje_id, 'Amsterdam', 'Courtyard Marriott', NULL, 'Hotel previsto o similar.', 15),

    (v_viaje_id, 'Frankfurt', 'Holiday Inn Express Messe', NULL, 'Hotel previsto o similar.', 16),
    (v_viaje_id, 'Frankfurt', 'Tryp By Wyndham', NULL, 'Hotel previsto o similar.', 17),
    (v_viaje_id, 'Frankfurt', 'Leonardo Royal', NULL, 'Hotel previsto o similar.', 18),
    (v_viaje_id, 'Frankfurt', 'Holiday Inn Frankfurt-Alte Oper', NULL, 'Hotel previsto o similar.', 19),
    (v_viaje_id, 'Frankfurt', 'Maritim', NULL, 'Hotel previsto o similar.', 20),

    (v_viaje_id, 'Múnich', 'Feringapark', NULL, 'Hotel previsto o similar.', 21),
    (v_viaje_id, 'Múnich', 'Super 8', NULL, 'Hotel previsto o similar.', 22),
    (v_viaje_id, 'Múnich', 'Courtyard By Marriott', NULL, 'Hotel previsto o similar.', 23),
    (v_viaje_id, 'Múnich', 'Leonard Royal', NULL, 'Hotel previsto o similar.', 24),

    (v_viaje_id, 'Viena', 'Best Western Amedia', NULL, 'Hotel previsto o similar.', 25),
    (v_viaje_id, 'Viena', 'Simms', NULL, 'Hotel previsto o similar.', 26),
    (v_viaje_id, 'Viena', 'Winberger', NULL, 'Hotel previsto o similar.', 27),
    (v_viaje_id, 'Viena', 'Kaiserwasser', NULL, 'Hotel previsto o similar.', 28),

    (v_viaje_id, 'Venecia', 'Russot', NULL, 'Hotel previsto o similar.', 29),
    (v_viaje_id, 'Venecia', 'Delfino', NULL, 'Hotel previsto o similar.', 30),
    (v_viaje_id, 'Venecia', 'Lugano Torreta', NULL, 'Hotel previsto o similar.', 31),

    (v_viaje_id, 'Florencia', 'IH Firenze Business', NULL, 'Hotel previsto o similar.', 32),
    (v_viaje_id, 'Florencia', 'Mirage', NULL, 'Hotel previsto o similar.', 33),
    (v_viaje_id, 'Florencia', 'Nil', NULL, 'Hotel previsto o similar.', 34),
    (v_viaje_id, 'Florencia', 'Raffaelo', NULL, 'Hotel previsto o similar.', 35),

    (v_viaje_id, 'Roma', 'Occidental Aran Park', NULL, 'Hotel previsto o similar.', 36),
    (v_viaje_id, 'Roma', 'Barcelo Aran Mantegna', NULL, 'Hotel previsto o similar.', 37),
    (v_viaje_id, 'Roma', 'Shangrila', NULL, 'Hotel previsto o similar.', 38),

    (v_viaje_id, 'Costa Azul', 'Holiday Inn Cannes', NULL, 'Hotel previsto o similar.', 39),
    (v_viaje_id, 'Costa Azul', 'Amarante', NULL, 'Hotel previsto o similar.', 40),
    (v_viaje_id, 'Costa Azul', 'Hi Park', NULL, 'Hotel previsto o similar.', 41),
    (v_viaje_id, 'Costa Azul', 'Holiday Inn Cannes', NULL, 'Hotel previsto o similar.', 42),
    (v_viaje_id, 'Costa Azul', 'Amarante', NULL, 'Hotel previsto o similar.', 43),
    (v_viaje_id, 'Costa Azul', 'Hi Park', NULL, 'Hotel previsto o similar.', 44),

    (v_viaje_id, 'Barcelona', 'Rafael Badalona', NULL, 'Hotel previsto o similar.', 45),
    (v_viaje_id, 'Barcelona', 'Exe Sant Cugat', NULL, 'Hotel previsto o similar.', 46),
    (v_viaje_id, 'Barcelona', 'Hotel Medinacelli', NULL, 'Hotel previsto o similar.', 47),
    (v_viaje_id, 'Barcelona', 'AC Som', NULL, 'Hotel previsto o similar.', 48),

    (v_viaje_id, 'Madrid', 'Praga', NULL, 'Hotel previsto o similar.', 49),
    (v_viaje_id, 'Madrid', 'Holiday Inn Piramides', NULL, 'Hotel previsto o similar.', 50),
    (v_viaje_id, 'Madrid', 'Muralto', NULL, 'Hotel previsto o similar.', 51),
    (v_viaje_id, 'Madrid', 'AC Cuzco', NULL, 'Hotel previsto o similar.', 52),
    (v_viaje_id, 'Madrid', 'Agumar', NULL, 'Hotel previsto o similar.', 53),
    (v_viaje_id, 'Madrid', 'Rafael Atocha', NULL, 'Hotel previsto o similar.', 54);


    -- ========================================================
    -- INCLUSIONES
    -- ========================================================

    INSERT INTO public.viaje_inclusiones
        (viaje_id, descripcion, orden)
    VALUES
    (v_viaje_id, 'Traslados del aeropuerto al hotel y viceversa a la llegada y salida.', 1),
    (v_viaje_id, 'Alojamiento y desayuno buffet durante todo el recorrido en hoteles de la categoría elegida.', 2),
    (v_viaje_id, 'Transporte en autobús de turismo con guía acompañante durante el recorrido de bus.', 3),
    (v_viaje_id, 'Visitas guiadas con guía de habla hispana.', 4),
    (v_viaje_id, 'Visitas nocturnas en París, Roma y Madrid.', 5),
    (v_viaje_id, 'Trayecto en bus y tren en Eurotunnel de Londres a París. En algunas salidas puede realizarse en Ferry.', 6),
    (v_viaje_id, 'Paseo en barco por el río Rin.', 7),
    (v_viaje_id, 'Seguro de protección y asistencia en viaje MAPAPLUS.', 8),
    (v_viaje_id, 'Bolsa de viaje.', 9),
    (v_viaje_id, 'Visitas con servicio de audio individual.', 10);


    -- ========================================================
    -- EXCLUSIONES
    -- ========================================================

    INSERT INTO public.viaje_exclusiones
        (viaje_id, descripcion, orden)
    VALUES
    (v_viaje_id, 'Tasas de estancia en Italia (Venecia, Florencia y Roma).', 1),
    (v_viaje_id, 'Ningún servicio no mencionado en el apartado incluye.', 2),
    (v_viaje_id, 'Paquete Plus P+.', 3);


    -- ========================================================
    -- PAQUETE PLUS
    -- ========================================================

    INSERT INTO public.viaje_opciones
        (viaje_id, nombre, descripcion, duracion_dias, duracion_noches, precio, moneda, activo, orden)
    VALUES
    (
        v_viaje_id,
        'Paquete Plus Londres / Madrid',
        'Paquete Plus P+ para el programa de 26 días Londres / Madrid. Incluye 13 comidas y 8 extras.',
        26,
        25,
        840.00,
        'USD',
        true,
        1
    )
    RETURNING id INTO v_opcion_id;


    -- ========================================================
    -- COMIDAS
    -- ========================================================

    INSERT INTO public.viaje_opcion_items
        (opcion_id, tipo, descripcion, orden)
    VALUES
    (v_opcion_id, 'COMIDA', 'Cena típica en Bruselas.', 1),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Brujas.', 2),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Volendam.', 3),
    (v_opcion_id, 'COMIDA', 'Almuerzo snack en crucero por el Rin.', 4),
    (v_opcion_id, 'COMIDA', 'Cena en Múnich.', 5),
    (v_opcion_id, 'COMIDA', 'Cena en Viena.', 6),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Florencia.', 7),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Asís.', 8),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Roma.', 9),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Pisa.', 10),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Puerto Olímpico.', 11),
    (v_opcion_id, 'COMIDA', 'Cena de tapas en Madrid.', 12),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Toledo.', 13),

    -- ======================================================
    -- EXTRAS
    -- ======================================================

    (v_opcion_id, 'VISITA', 'Subida a la Torre Eiffel, segundo piso.', 14),
    (v_opcion_id, 'VISITA', 'Cabaret Paradis Latin.', 15),
    (v_opcion_id, 'VISITA', 'Paseo en barco por el Sena.', 16),
    (v_opcion_id, 'VISITA', 'Excursión a Marken y Volendam.', 17),
    (v_opcion_id, 'VISITA', 'Espectáculo de valses en Viena.', 18),
    (v_opcion_id, 'VISITA', 'Paseo en góndola en Venecia.', 19),
    (v_opcion_id, 'VISITA', 'Vaticano: museos y Capilla Sixtina.', 20),
    (v_opcion_id, 'VISITA', 'Visita a Toledo.', 21);


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
        'Martes hasta abril del 2023',
        'La fuente publica salidas los martes hasta abril de 2023. Se conserva como texto original por tratarse de una programación histórica.',
        true
    );


    -- ========================================================
    -- VALIDACION
    -- ========================================================

    IF (
        SELECT COUNT(*)
        FROM public.viaje_itinerario
        WHERE viaje_id = v_viaje_id
    ) <> 26 THEN
        RAISE EXCEPTION 'Validación fallida: itinerario';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_hoteles
        WHERE viaje_id = v_viaje_id
    ) <> 54 THEN
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
    ) <> 3 THEN
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
    ) <> 21 THEN
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

