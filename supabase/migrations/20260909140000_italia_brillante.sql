-- ============================================================
-- V6 - ITALIA BRILLANTE
-- Fuente: galeriadeviajes.com/es/packets/italia-brillante
-- ============================================================

DO $$
DECLARE
    v_destino_id uuid;
    v_viaje_id uuid;
    v_opcion_id uuid;
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
        RAISE EXCEPTION 'No se encontró el destino Europa';
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
        'Italia Brillante',
        'italia-brillante',
        'Circuito por Italia con inicio en Venecia y recorrido por Venecia, Pisa, Florencia, Asís y Roma.',
        8,
        6,
        NULL,
        'USD',
        'Transporte durante todo el recorrido europeo en unidades de gran confort con WI-FI incluido y choferes experimentados. Acompañamiento de guía correo desde el inicio hasta el fin del circuito. Traslados de llegada y salida del aeropuerto a hotel y viceversa. Alojamiento y desayuno buffet en los hoteles indicados o de similar categoría superior. Todas las tasas turísticas en las ciudades de pernocte. Guías locales para las visitas de las ciudades tal como se indica en el itinerario. Seguro de asistencia Trabax. Bolsa de viaje.',
        NULL,
        '/picture/image/0000/8244/medium_widescreen/2.ITALIA-BRILLANTE-INSIDE.jpg',
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

    IF v_viaje_id IS NULL THEN
        SELECT id
        INTO v_viaje_id
        FROM public.viajes
        WHERE slug = 'italia-brillante'
        LIMIT 1;
    END IF;


    -- ========================================================
    -- ITINERARIO
    -- ========================================================

    DELETE FROM public.viaje_itinerario
    WHERE viaje_id = v_viaje_id;

    INSERT INTO public.viaje_itinerario
        (viaje_id, dia_numero, dia_semana, titulo,
         ciudad_origen, ciudad_destino, distancia_km,
         descripcion, alojamiento, orden)
    VALUES
    (
        v_viaje_id, 1, 'Lunes',
        'América / Venecia',
        'América', 'Venecia', NULL,
        'Salida en vuelo internacional con destino a Venecia.',
        NULL, 1
    ),
    (
        v_viaje_id, 2, 'Martes',
        'Venecia',
        NULL, 'Venecia', NULL,
        'Llegada al aeropuerto. Traslado privado al hotel en Mestre. Resto del día libre.',
        'Alojamiento', 2
    ),
    (
        v_viaje_id, 3, 'Miércoles',
        'Venecia',
        NULL, 'Venecia', NULL,
        'Desayuno buffet. Traslado para tomar el Vaporetto hasta la Plaza de San Marcos. Visita a pie con guía local al Puente de los Suspiros, la Basílica de San Marcos, el Palacio Ducal y una fábrica de cristal. Tiempo libre para actividades opcionales como paseo en góndola. Almuerzo opcional. Regreso al hotel.',
        'Alojamiento', 3
    ),
    (
        v_viaje_id, 4, 'Jueves',
        'Venecia / Pisa / Florencia',
        'Venecia', 'Florencia', 414,
        'Salida hacia Pisa, conocida por su peculiar torre inclinada. Tiempo libre para visitar la ciudad. Opcionalmente almuerzo en uno de sus restaurantes típicos. Continuación hacia Florencia y entrada por el mirador de Miguel Ángel. Visita a pie con guía local por Piazza del Duomo, Catedral de Florencia, Cúpula de Brunelleschi, Campanile de Giotto, Battistero di San Giovanni, Ponte Vecchio, Piazza della Signoria y Palazzo Vecchio.',
        'Alojamiento', 4
    ),
    (
        v_viaje_id, 5, 'Viernes',
        'Florencia / Asís / Roma',
        'Florencia', 'Roma', 439,
        'Desayuno buffet. Tiempo libre en Florencia. Salida por la tarde hacia Asís, centro espiritual y de paz, conocido por ser el lugar donde nacieron y murieron San Francisco y Santa Clara. Tiempo libre para conocer la Basílica. Continuación hacia Roma.',
        'Alojamiento', 5
    ),
    (
        v_viaje_id, 6, 'Sábado',
        'Roma',
        NULL, 'Roma', NULL,
        'Desayuno buffet. Visita panorámica con guía local por Plaza de Venecia, Vía Veneto, Foros Romanos, Coliseo exterior, Arco de Constantino, Castillo de Sant Angelo y otros lugares importantes. Se recomienda opcionalmente visitar los Museos Vaticanos y la Capilla Sixtina. Tiempo libre para almorzar y tarde libre para descubrir la Roma Barroca y la Fontana de Trevi.',
        'Alojamiento', 6
    ),
    (
        v_viaje_id, 7, 'Domingo',
        'Roma',
        NULL, 'Roma', NULL,
        'Desayuno buffet. Día libre para continuar recorriendo la ciudad o realizar una excursión opcional. Se recomienda visitar Nápoles y Capri.',
        'Alojamiento', 7
    ),
    (
        v_viaje_id, 8, 'Lunes',
        'Roma',
        'Roma', 'Aeropuerto', NULL,
        'Desayuno buffet. Tiempo libre hasta la hora de realizar el traslado al aeropuerto para tomar el vuelo de regreso.',
        NULL, 8
    );


    -- ========================================================
    -- HOTELES
    -- ========================================================

    DELETE FROM public.viaje_hoteles
    WHERE viaje_id = v_viaje_id;

    INSERT INTO public.viaje_hoteles
        (viaje_id, ciudad, nombre_hotel, categoria, observaciones, orden)
    VALUES
    (v_viaje_id, 'Venecia (Mestre)',
     'Holiday Inn Venezia Marghera / Delfino / Lugano Torreta',
     'Primera', NULL, 1),

    (v_viaje_id, 'Florencia',
     'Nil / Mirage',
     'Primera', NULL, 2),

    (v_viaje_id, 'Roma',
     'Belstay Rome Aurelia / Gran Hotel Fleming',
     'Primera', NULL, 3),

    (v_viaje_id, 'Milán',
     'Barceló Milán / IH Hotel Milano Gioia',
     'Turista Superior',
     NULL,
     4),

    (v_viaje_id, 'Venecia (Mestre)',
     'LH Sirio / Michelangelo / Campanile Hotel Venice Mestre',
     'Turista Superior',
     NULL,
     5),

    (v_viaje_id, 'Florencia',
     'West Florence / Ibis Firenze Nord / B&B Firenze Novoli / Palazzo di Giustizia',
     'Turista Superior',
     NULL,
     6),

    (v_viaje_id, 'Roma',
     'Excel Montemario / IH 3 Roma Z3',
     'Turista Superior',
     NULL,
     7);


    -- ========================================================
    -- INCLUSIONES
    -- ========================================================

    DELETE FROM public.viaje_inclusiones
    WHERE viaje_id = v_viaje_id;

    INSERT INTO public.viaje_inclusiones
        (viaje_id, descripcion, orden)
    VALUES
    (v_viaje_id,
     'Transporte durante todo el recorrido europeo en unidades de gran confort con WI-FI incluido y choferes experimentados.',
     1),

    (v_viaje_id,
     'Acompañamiento de guía correo desde el inicio hasta el fin del circuito.',
     2),

    (v_viaje_id,
     'Traslados de llegada y salida del aeropuerto a hotel y viceversa.',
     3),

    (v_viaje_id,
     'Alojamiento y desayuno buffet en los hoteles indicados o de similar categoría superior.',
     4),

    (v_viaje_id,
     'Todas las tasas turísticas en las ciudades de pernocte.',
     5),

    (v_viaje_id,
     'Guías locales para las visitas de las ciudades tal como se indica en el itinerario.',
     6),

    (v_viaje_id,
     'Seguro de asistencia Trabax.',
     7),

    (v_viaje_id,
     'Bolsa de viaje.',
     8);


    -- ========================================================
    -- EUROPACK
    -- ========================================================

    DELETE FROM public.viaje_opciones
    WHERE viaje_id = v_viaje_id;

    INSERT INTO public.viaje_opciones
        (viaje_id, nombre, descripcion,
         duracion_dias, duracion_noches,
         precio, moneda, activo, orden)
    VALUES
    (
        v_viaje_id,
        'Europack Venecia / Roma',
        'Europack publicado por persona: 4 comidas y 2 visitas. La fuente enumera posteriormente cinco comidas, por lo que se conserva esa discrepancia.',
        8,
        6,
        230,
        'USD',
        true,
        1
    )
    RETURNING id INTO v_opcion_id;


    -- ========================================================
    -- ITEMS DEL EUROPACK
    -- ========================================================

    INSERT INTO public.viaje_opcion_items
        (opcion_id, tipo, descripcion, orden)
    VALUES
    (v_opcion_id, 'COMIDA', 'Almuerzo en Sirmione', 1),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Venecia', 2),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Pisa', 3),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Florencia', 4),
    (v_opcion_id, 'COMIDA', 'Almuerzo en Roma', 5),
    (v_opcion_id, 'VISITA', 'Paseo en Góndola', 6),
    (v_opcion_id, 'VISITA', 'Visita Museos Vaticanos', 7);


    -- ========================================================
    -- SALIDAS
    -- ========================================================

    DELETE FROM public.viaje_salidas
    WHERE viaje_id = v_viaje_id;

    INSERT INTO public.viaje_salidas
        (viaje_id, fecha_inicio, fecha_fin,
         texto_original, observaciones, activo)
    VALUES
    (
        v_viaje_id,
        NULL,
        NULL,
        'Febrero 18, 27 - marzo 13, 20',
        'La fuente publica las salidas sin indicar año.',
        true
    );


    -- ========================================================
    -- VALIDACIÓN
    -- ========================================================

    IF (
        SELECT COUNT(*)
        FROM public.viaje_itinerario
        WHERE viaje_id = v_viaje_id
    ) <> 8 THEN
        RAISE EXCEPTION 'Italia Brillante: se esperaban 8 días de itinerario';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_hoteles
        WHERE viaje_id = v_viaje_id
    ) <> 7 THEN
        RAISE EXCEPTION 'Italia Brillante: se esperaban 7 registros de hoteles';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_inclusiones
        WHERE viaje_id = v_viaje_id
    ) <> 8 THEN
        RAISE EXCEPTION 'Italia Brillante: se esperaban 8 inclusiones';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_opciones
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'Italia Brillante: se esperaba 1 Europack';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_opcion_items
        WHERE opcion_id = v_opcion_id
    ) <> 7 THEN
        RAISE EXCEPTION 'Italia Brillante: se esperaban 7 items del Europack';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.viaje_salidas
        WHERE viaje_id = v_viaje_id
    ) <> 1 THEN
        RAISE EXCEPTION 'Italia Brillante: se esperaba 1 salida';
    END IF;

    RAISE NOTICE 'Italia Brillante cargado correctamente. ID=%', v_viaje_id;

END $$;
