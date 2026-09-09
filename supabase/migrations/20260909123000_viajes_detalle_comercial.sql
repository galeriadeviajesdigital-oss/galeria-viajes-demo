-- ============================================================
-- Galería de Viajes
-- Migración V4
-- Detalle comercial y operativo de viajes/programas
-- ============================================================

-- ============================================================
-- 1. ITINERARIO
-- ============================================================

CREATE TABLE IF NOT EXISTS public.viaje_itinerario (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    viaje_id uuid NOT NULL,
    dia_numero integer NOT NULL,
    dia_semana varchar(20),
    titulo varchar(255) NOT NULL,
    ciudad_origen varchar(255),
    ciudad_destino varchar(255),
    distancia_km integer,
    descripcion text,
    alojamiento text,
    orden integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT viaje_itinerario_viaje_fk
        FOREIGN KEY (viaje_id)
        REFERENCES public.viajes(id)
        ON DELETE CASCADE,

    CONSTRAINT viaje_itinerario_dia_ck
        CHECK (dia_numero > 0),

    CONSTRAINT viaje_itinerario_distancia_ck
        CHECK (
            distancia_km IS NULL
            OR distancia_km >= 0
        ),

    CONSTRAINT viaje_itinerario_orden_ck
        CHECK (orden >= 0),

    CONSTRAINT viaje_itinerario_unique_dia
        UNIQUE (viaje_id, dia_numero)
);


-- ============================================================
-- 2. HOTELES DEL VIAJE
-- ============================================================

CREATE TABLE IF NOT EXISTS public.viaje_hoteles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    viaje_id uuid NOT NULL,
    ciudad varchar(255) NOT NULL,
    nombre_hotel varchar(500) NOT NULL,
    categoria varchar(100),
    observaciones text,
    orden integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT viaje_hoteles_viaje_fk
        FOREIGN KEY (viaje_id)
        REFERENCES public.viajes(id)
        ON DELETE CASCADE,

    CONSTRAINT viaje_hoteles_orden_ck
        CHECK (orden >= 0)
);


-- ============================================================
-- 3. OPCIONES / COMPLEMENTOS DEL VIAJE
-- ============================================================

CREATE TABLE IF NOT EXISTS public.viaje_opciones (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    viaje_id uuid NOT NULL,
    nombre varchar(255) NOT NULL,
    descripcion text,
    duracion_dias integer,
    duracion_noches integer,
    precio numeric(12,2),
    moneda varchar(3) NOT NULL DEFAULT 'USD',
    activo boolean NOT NULL DEFAULT true,
    orden integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT viaje_opciones_viaje_fk
        FOREIGN KEY (viaje_id)
        REFERENCES public.viajes(id)
        ON DELETE CASCADE,

    CONSTRAINT viaje_opciones_duracion_dias_ck
        CHECK (
            duracion_dias IS NULL
            OR duracion_dias > 0
        ),

    CONSTRAINT viaje_opciones_duracion_noches_ck
        CHECK (
            duracion_noches IS NULL
            OR duracion_noches >= 0
        ),

    CONSTRAINT viaje_opciones_precio_ck
        CHECK (
            precio IS NULL
            OR precio >= 0
        ),

    CONSTRAINT viaje_opciones_orden_ck
        CHECK (orden >= 0)
);


-- ============================================================
-- 4. ELEMENTOS DE LAS OPCIONES
-- ============================================================

CREATE TABLE IF NOT EXISTS public.viaje_opcion_items (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    opcion_id uuid NOT NULL,
    tipo varchar(30) NOT NULL,
    descripcion text NOT NULL,
    orden integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT viaje_opcion_items_opcion_fk
        FOREIGN KEY (opcion_id)
        REFERENCES public.viaje_opciones(id)
        ON DELETE CASCADE,

    CONSTRAINT viaje_opcion_items_tipo_ck
        CHECK (
            tipo IN (
                'COMIDA',
                'VISITA',
                'ACTIVIDAD',
                'OTRO'
            )
        ),

    CONSTRAINT viaje_opcion_items_orden_ck
        CHECK (orden >= 0)
);


-- ============================================================
-- 5. SALIDAS
-- ============================================================

CREATE TABLE IF NOT EXISTS public.viaje_salidas (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    viaje_id uuid NOT NULL,
    fecha_inicio date,
    fecha_fin date,
    texto_original text,
    observaciones text,
    activo boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT viaje_salidas_viaje_fk
        FOREIGN KEY (viaje_id)
        REFERENCES public.viajes(id)
        ON DELETE CASCADE,

    CONSTRAINT viaje_salidas_fechas_ck
        CHECK (
            fecha_inicio IS NULL
            OR fecha_fin IS NULL
            OR fecha_fin >= fecha_inicio
        )
);


-- ============================================================
-- 6. INCLUSIONES
-- ============================================================

CREATE TABLE IF NOT EXISTS public.viaje_inclusiones (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    viaje_id uuid NOT NULL,
    descripcion text NOT NULL,
    orden integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT viaje_inclusiones_viaje_fk
        FOREIGN KEY (viaje_id)
        REFERENCES public.viajes(id)
        ON DELETE CASCADE,

    CONSTRAINT viaje_inclusiones_orden_ck
        CHECK (orden >= 0)
);


-- ============================================================
-- 7. EXCLUSIONES
-- ============================================================

CREATE TABLE IF NOT EXISTS public.viaje_exclusiones (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    viaje_id uuid NOT NULL,
    descripcion text NOT NULL,
    orden integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT viaje_exclusiones_viaje_fk
        FOREIGN KEY (viaje_id)
        REFERENCES public.viajes(id)
        ON DELETE CASCADE,

    CONSTRAINT viaje_exclusiones_orden_ck
        CHECK (orden >= 0)
);


-- ============================================================
-- 8. PASAJEROS DE UNA SOLICITUD DE COTIZACIÓN
-- ============================================================

CREATE TABLE IF NOT EXISTS public.solicitud_cotizacion_pasajeros (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    solicitud_cotizacion_id uuid NOT NULL,
    tipo varchar(20) NOT NULL,
    titulo varchar(20),
    nombre varchar(150) NOT NULL,
    apellidos varchar(150),
    edad integer,
    orden integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT solicitud_cotizacion_pasajeros_solicitud_fk
        FOREIGN KEY (solicitud_cotizacion_id)
        REFERENCES public.solicitudes_cotizacion(id)
        ON DELETE CASCADE,

    CONSTRAINT solicitud_cotizacion_pasajeros_tipo_ck
        CHECK (
            tipo IN (
                'ADULTO',
                'NINO'
            )
        ),

    CONSTRAINT solicitud_cotizacion_pasajeros_edad_ck
        CHECK (
            edad IS NULL
            OR edad >= 0
        ),

    CONSTRAINT solicitud_cotizacion_pasajeros_orden_ck
        CHECK (orden >= 0)
);


-- ============================================================
-- ÍNDICES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_viaje_itinerario_viaje
    ON public.viaje_itinerario(viaje_id);

CREATE INDEX IF NOT EXISTS idx_viaje_itinerario_orden
    ON public.viaje_itinerario(viaje_id, orden);

CREATE INDEX IF NOT EXISTS idx_viaje_hoteles_viaje
    ON public.viaje_hoteles(viaje_id);

CREATE INDEX IF NOT EXISTS idx_viaje_hoteles_orden
    ON public.viaje_hoteles(viaje_id, orden);

CREATE INDEX IF NOT EXISTS idx_viaje_opciones_viaje
    ON public.viaje_opciones(viaje_id);

CREATE INDEX IF NOT EXISTS idx_viaje_opciones_activo
    ON public.viaje_opciones(viaje_id, activo);

CREATE INDEX IF NOT EXISTS idx_viaje_opcion_items_opcion
    ON public.viaje_opcion_items(opcion_id);

CREATE INDEX IF NOT EXISTS idx_viaje_opcion_items_orden
    ON public.viaje_opcion_items(opcion_id, orden);

CREATE INDEX IF NOT EXISTS idx_viaje_salidas_viaje
    ON public.viaje_salidas(viaje_id);

CREATE INDEX IF NOT EXISTS idx_viaje_salidas_fecha
    ON public.viaje_salidas(fecha_inicio);

CREATE INDEX IF NOT EXISTS idx_viaje_inclusiones_viaje
    ON public.viaje_inclusiones(viaje_id);

CREATE INDEX IF NOT EXISTS idx_viaje_inclusiones_orden
    ON public.viaje_inclusiones(viaje_id, orden);

CREATE INDEX IF NOT EXISTS idx_viaje_exclusiones_viaje
    ON public.viaje_exclusiones(viaje_id);

CREATE INDEX IF NOT EXISTS idx_viaje_exclusiones_orden
    ON public.viaje_exclusiones(viaje_id, orden);

CREATE INDEX IF NOT EXISTS idx_solicitud_cotizacion_pasajeros_solicitud
    ON public.solicitud_cotizacion_pasajeros(
        solicitud_cotizacion_id
    );


-- ============================================================
-- TRIGGERS updated_at
-- ============================================================

DROP TRIGGER IF EXISTS viaje_itinerario_updated_at
ON public.viaje_itinerario;

CREATE TRIGGER viaje_itinerario_updated_at
BEFORE UPDATE ON public.viaje_itinerario
FOR EACH ROW
EXECUTE FUNCTION public.actualizar_fecha_modificacion();


DROP TRIGGER IF EXISTS viaje_hoteles_updated_at
ON public.viaje_hoteles;

CREATE TRIGGER viaje_hoteles_updated_at
BEFORE UPDATE ON public.viaje_hoteles
FOR EACH ROW
EXECUTE FUNCTION public.actualizar_fecha_modificacion();


DROP TRIGGER IF EXISTS viaje_opciones_updated_at
ON public.viaje_opciones;

CREATE TRIGGER viaje_opciones_updated_at
BEFORE UPDATE ON public.viaje_opciones
FOR EACH ROW
EXECUTE FUNCTION public.actualizar_fecha_modificacion();


DROP TRIGGER IF EXISTS viaje_opcion_items_updated_at
ON public.viaje_opcion_items;

CREATE TRIGGER viaje_opcion_items_updated_at
BEFORE UPDATE ON public.viaje_opcion_items
FOR EACH ROW
EXECUTE FUNCTION public.actualizar_fecha_modificacion();


DROP TRIGGER IF EXISTS viaje_salidas_updated_at
ON public.viaje_salidas;

CREATE TRIGGER viaje_salidas_updated_at
BEFORE UPDATE ON public.viaje_salidas
FOR EACH ROW
EXECUTE FUNCTION public.actualizar_fecha_modificacion();


DROP TRIGGER IF EXISTS viaje_inclusiones_updated_at
ON public.viaje_inclusiones;

CREATE TRIGGER viaje_inclusiones_updated_at
BEFORE UPDATE ON public.viaje_inclusiones
FOR EACH ROW
EXECUTE FUNCTION public.actualizar_fecha_modificacion();


DROP TRIGGER IF EXISTS viaje_exclusiones_updated_at
ON public.viaje_exclusiones;

CREATE TRIGGER viaje_exclusiones_updated_at
BEFORE UPDATE ON public.viaje_exclusiones
FOR EACH ROW
EXECUTE FUNCTION public.actualizar_fecha_modificacion();


DROP TRIGGER IF EXISTS solicitud_cotizacion_pasajeros_updated_at
ON public.solicitud_cotizacion_pasajeros;

CREATE TRIGGER solicitud_cotizacion_pasajeros_updated_at
BEFORE UPDATE ON public.solicitud_cotizacion_pasajeros
FOR EACH ROW
EXECUTE FUNCTION public.actualizar_fecha_modificacion();


-- ============================================================
-- FIN MIGRACIÓN V4
-- ============================================================