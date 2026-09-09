-- ============================================================
-- GALERÍA DE VIAJES COSTA RICA
-- Migración inicial de base de datos
-- Fecha: 2026-09-05
-- ============================================================

BEGIN;

-- ============================================================
-- 1. EXTENSIONES
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- ============================================================
-- 2. FUNCIÓN GENERAL PARA updated_at
-- ============================================================

CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


-- ============================================================
-- 3. CONTACTOS
-- ============================================================

CREATE TABLE contactos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100),
    email VARCHAR(255),
    telefono VARCHAR(50),
    whatsapp VARCHAR(50),

    pais VARCHAR(100),
    ciudad VARCHAR(100),

    idioma VARCHAR(20) DEFAULT 'es',
    acepta_comunicaciones BOOLEAN NOT NULL DEFAULT FALSE,

    hubspot_contact_id VARCHAR(100),

    activo BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT contactos_email_valido
        CHECK (
            email IS NULL
            OR email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'
        )
);


-- ============================================================
-- 4. DESTINOS
-- ============================================================

CREATE TABLE destinos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    nombre VARCHAR(150) NOT NULL,
    slug VARCHAR(160) NOT NULL UNIQUE,

    region VARCHAR(100),
    pais VARCHAR(100),
    continente VARCHAR(100),

    descripcion TEXT,
    descripcion_corta VARCHAR(500),

    imagen_url TEXT,

    destacado BOOLEAN NOT NULL DEFAULT FALSE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    orden INTEGER NOT NULL DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 5. EXPERIENCIAS
-- ============================================================

CREATE TABLE experiencias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    nombre VARCHAR(150) NOT NULL,
    slug VARCHAR(160) NOT NULL UNIQUE,

    descripcion TEXT,
    descripcion_corta VARCHAR(500),

    imagen_url TEXT,

    activo BOOLEAN NOT NULL DEFAULT TRUE,
    destacado BOOLEAN NOT NULL DEFAULT FALSE,

    orden INTEGER NOT NULL DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 6. RELACIÓN DESTINOS ↔ EXPERIENCIAS
-- ============================================================

CREATE TABLE destino_experiencia (
    destino_id UUID NOT NULL,
    experiencia_id UUID NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (destino_id, experiencia_id),

    CONSTRAINT destino_experiencia_destino_fk
        FOREIGN KEY (destino_id)
        REFERENCES destinos(id)
        ON DELETE CASCADE,

    CONSTRAINT destino_experiencia_experiencia_fk
        FOREIGN KEY (experiencia_id)
        REFERENCES experiencias(id)
        ON DELETE CASCADE
);


-- ============================================================
-- 7. VIAJES / PRODUCTOS TURÍSTICOS
-- ============================================================

CREATE TABLE viajes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    destino_id UUID,
    nombre VARCHAR(200) NOT NULL,
    slug VARCHAR(220) NOT NULL UNIQUE,

    descripcion TEXT,

    duracion_dias INTEGER,
    duracion_noches INTEGER,

    precio_desde NUMERIC(12,2),
    moneda CHAR(3) NOT NULL DEFAULT 'USD',

    incluye TEXT,
    no_incluye TEXT,

    imagen_url TEXT,

    destacado BOOLEAN NOT NULL DEFAULT FALSE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT viajes_destino_fk
        FOREIGN KEY (destino_id)
        REFERENCES destinos(id)
        ON DELETE SET NULL,

    CONSTRAINT viajes_duracion_dias_ck
        CHECK (duracion_dias IS NULL OR duracion_dias > 0),

    CONSTRAINT viajes_duracion_noches_ck
        CHECK (duracion_noches IS NULL OR duracion_noches >= 0),

    CONSTRAINT viajes_precio_ck
        CHECK (precio_desde IS NULL OR precio_desde >= 0)
);


-- ============================================================
-- 8. OFERTAS
-- ============================================================

CREATE TABLE ofertas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    viaje_id UUID,

    titulo VARCHAR(200) NOT NULL,
    slug VARCHAR(220) NOT NULL UNIQUE,

    descripcion TEXT,

    precio_anterior NUMERIC(12,2),
    precio_oferta NUMERIC(12,2),
    moneda CHAR(3) NOT NULL DEFAULT 'USD',

    fecha_inicio DATE,
    fecha_fin DATE,

    cupos INTEGER,

    imagen_url TEXT,

    destacada BOOLEAN NOT NULL DEFAULT FALSE,
    activa BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT ofertas_viaje_fk
        FOREIGN KEY (viaje_id)
        REFERENCES viajes(id)
        ON DELETE SET NULL,

    CONSTRAINT ofertas_precio_anterior_ck
        CHECK (precio_anterior IS NULL OR precio_anterior >= 0),

    CONSTRAINT ofertas_precio_oferta_ck
        CHECK (precio_oferta IS NULL OR precio_oferta >= 0),

    CONSTRAINT ofertas_fechas_ck
        CHECK (
            fecha_fin IS NULL
            OR fecha_inicio IS NULL
            OR fecha_fin >= fecha_inicio
        ),

    CONSTRAINT ofertas_cupos_ck
        CHECK (cupos IS NULL OR cupos >= 0)
);


-- ============================================================
-- 9. CAMPAÑAS
-- ============================================================

CREATE TABLE campanas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    nombre VARCHAR(200) NOT NULL,
    codigo VARCHAR(100) UNIQUE,

    origen VARCHAR(50),

    descripcion TEXT,

    fecha_inicio DATE,
    fecha_fin DATE,

    presupuesto NUMERIC(12,2),
    moneda CHAR(3) NOT NULL DEFAULT 'USD',

    activa BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT campanas_fechas_ck
        CHECK (
            fecha_fin IS NULL
            OR fecha_inicio IS NULL
            OR fecha_fin >= fecha_inicio
        ),

    CONSTRAINT campanas_presupuesto_ck
        CHECK (presupuesto IS NULL OR presupuesto >= 0)
);


-- ============================================================
-- 10. LEADS
-- ============================================================

CREATE TABLE leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    contacto_id UUID NOT NULL,
    destino_id UUID,
    experiencia_id UUID,
    viaje_id UUID,
    campana_id UUID,

    origen VARCHAR(30) NOT NULL DEFAULT 'WEB',

    estado VARCHAR(30) NOT NULL DEFAULT 'NUEVO',
    prioridad VARCHAR(20) NOT NULL DEFAULT 'NORMAL',

    fecha_viaje DATE,
    viajeros INTEGER,
    duracion_dias INTEGER,

    presupuesto NUMERIC(12,2),
    moneda CHAR(3) NOT NULL DEFAULT 'USD',

    mensaje TEXT,

    vendedor_id UUID,

    hubspot_contact_id VARCHAR(100),
    hubspot_deal_id VARCHAR(100),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT leads_contacto_fk
        FOREIGN KEY (contacto_id)
        REFERENCES contactos(id)
        ON DELETE RESTRICT,

    CONSTRAINT leads_destino_fk
        FOREIGN KEY (destino_id)
        REFERENCES destinos(id)
        ON DELETE SET NULL,

    CONSTRAINT leads_experiencia_fk
        FOREIGN KEY (experiencia_id)
        REFERENCES experiencias(id)
        ON DELETE SET NULL,

    CONSTRAINT leads_viaje_fk
        FOREIGN KEY (viaje_id)
        REFERENCES viajes(id)
        ON DELETE SET NULL,

    CONSTRAINT leads_campana_fk
        FOREIGN KEY (campana_id)
        REFERENCES campanas(id)
        ON DELETE SET NULL,

    CONSTRAINT leads_origen_ck
        CHECK (
            origen IN (
                'WEB',
                'WHATSAPP',
                'GOOGLE',
                'FACEBOOK',
                'INSTAGRAM',
                'REFERIDO',
                'CAMPAÑA',
                'EVENTO',
                'LLAMADA',
                'OTRO'
            )
        ),

    CONSTRAINT leads_estado_ck
        CHECK (
            estado IN (
                'NUEVO',
                'CONTACTADO',
                'CALIFICADO',
                'NO_CALIFICADO'
            )
        ),

    CONSTRAINT leads_prioridad_ck
        CHECK (
            prioridad IN (
                'BAJA',
                'NORMAL',
                'ALTA',
                'URGENTE'
            )
        ),

    CONSTRAINT leads_viajeros_ck
        CHECK (viajeros IS NULL OR viajeros > 0),

    CONSTRAINT leads_duracion_ck
        CHECK (duracion_dias IS NULL OR duracion_dias > 0),

    CONSTRAINT leads_presupuesto_ck
        CHECK (presupuesto IS NULL OR presupuesto >= 0)
);


-- ============================================================
-- 11. SOLICITUDES DE COTIZACIÓN
-- ============================================================

CREATE TABLE solicitudes_cotizacion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    lead_id UUID NOT NULL,

    tipo_viaje VARCHAR(100),
    fecha_salida DATE,
    fecha_regreso DATE,

    adultos INTEGER NOT NULL DEFAULT 1,
    ninos INTEGER NOT NULL DEFAULT 0,

    presupuesto_min NUMERIC(12,2),
    presupuesto_max NUMERIC(12,2),
    moneda CHAR(3) NOT NULL DEFAULT 'USD',

    comentarios TEXT,

    estado VARCHAR(30) NOT NULL DEFAULT 'PENDIENTE',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT solicitudes_lead_fk
        FOREIGN KEY (lead_id)
        REFERENCES leads(id)
        ON DELETE CASCADE,

    CONSTRAINT solicitudes_adultos_ck
        CHECK (adultos > 0),

    CONSTRAINT solicitudes_ninos_ck
        CHECK (ninos >= 0),

    CONSTRAINT solicitudes_presupuesto_min_ck
        CHECK (presupuesto_min IS NULL OR presupuesto_min >= 0),

    CONSTRAINT solicitudes_presupuesto_max_ck
        CHECK (presupuesto_max IS NULL OR presupuesto_max >= 0),

    CONSTRAINT solicitudes_fechas_ck
        CHECK (
            fecha_regreso IS NULL
            OR fecha_salida IS NULL
            OR fecha_regreso >= fecha_salida
        ),

    CONSTRAINT solicitudes_estado_ck
        CHECK (
            estado IN (
                'PENDIENTE',
                'EN_REVISION',
                'PROCESADA',
                'CANCELADA'
            )
        )
);


-- ============================================================
-- 12. VENDEDORES
-- ============================================================

CREATE TABLE vendedores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    nombre VARCHAR(150) NOT NULL,
    email VARCHAR(255) UNIQUE,
    telefono VARCHAR(50),

    cargo VARCHAR(100),

    hubspot_owner_id VARCHAR(100),

    activo BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 13. AGREGAR FK DE LEADS → VENDEDORES
-- ============================================================

ALTER TABLE leads
    ADD CONSTRAINT leads_vendedor_fk
    FOREIGN KEY (vendedor_id)
    REFERENCES vendedores(id)
    ON DELETE SET NULL;


-- ============================================================
-- 14. OPORTUNIDADES
-- ============================================================

CREATE TABLE oportunidades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    lead_id UUID NOT NULL,
    vendedor_id UUID,

    nombre VARCHAR(200) NOT NULL,

    etapa VARCHAR(30) NOT NULL DEFAULT 'NUEVA',

    valor_estimado NUMERIC(12,2),
    moneda CHAR(3) NOT NULL DEFAULT 'USD',

    probabilidad INTEGER NOT NULL DEFAULT 10,

    fecha_cierre_estimada DATE,
    fecha_cierre_real DATE,

    hubspot_deal_id VARCHAR(100),

    motivo_perdida TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT oportunidades_lead_fk
        FOREIGN KEY (lead_id)
        REFERENCES leads(id)
        ON DELETE CASCADE,

    CONSTRAINT oportunidades_vendedor_fk
        FOREIGN KEY (vendedor_id)
        REFERENCES vendedores(id)
        ON DELETE SET NULL,

    CONSTRAINT oportunidades_etapa_ck
        CHECK (
            etapa IN (
                'NUEVA',
                'CONTACTADA',
                'CALIFICADA',
                'COTIZACION',
                'NEGOCIACION',
                'SEGUIMIENTO',
                'GANADA',
                'PERDIDA'
            )
        ),

    CONSTRAINT oportunidades_valor_ck
        CHECK (valor_estimado IS NULL OR valor_estimado >= 0),

    CONSTRAINT oportunidades_probabilidad_ck
        CHECK (probabilidad BETWEEN 0 AND 100)
);


-- ============================================================
-- 15. COTIZACIONES
-- ============================================================

CREATE TABLE cotizaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    oportunidad_id UUID NOT NULL,

    numero VARCHAR(50) NOT NULL UNIQUE,

    subtotal NUMERIC(12,2) NOT NULL DEFAULT 0,
    impuestos NUMERIC(12,2) NOT NULL DEFAULT 0,
    descuentos NUMERIC(12,2) NOT NULL DEFAULT 0,
    total NUMERIC(12,2) NOT NULL DEFAULT 0,

    moneda CHAR(3) NOT NULL DEFAULT 'USD',

    fecha_emision DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_vencimiento DATE,

    estado VARCHAR(30) NOT NULL DEFAULT 'BORRADOR',

    notas TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT cotizaciones_oportunidad_fk
        FOREIGN KEY (oportunidad_id)
        REFERENCES oportunidades(id)
        ON DELETE CASCADE,

    CONSTRAINT cotizaciones_subtotal_ck
        CHECK (subtotal >= 0),

    CONSTRAINT cotizaciones_impuestos_ck
        CHECK (impuestos >= 0),

    CONSTRAINT cotizaciones_descuentos_ck
        CHECK (descuentos >= 0),

    CONSTRAINT cotizaciones_total_ck
        CHECK (total >= 0),

    CONSTRAINT cotizaciones_estado_ck
        CHECK (
            estado IN (
                'BORRADOR',
                'ENVIADA',
                'ACEPTADA',
                'RECHAZADA',
                'VENCIDA',
                'CANCELADA'
            )
        ),

    CONSTRAINT cotizaciones_fecha_ck
        CHECK (
            fecha_vencimiento IS NULL
            OR fecha_vencimiento >= fecha_emision
        )
);


-- ============================================================
-- 16. SEGUIMIENTOS
-- ============================================================

CREATE TABLE seguimientos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    lead_id UUID,
    oportunidad_id UUID,
    vendedor_id UUID,

    tipo VARCHAR(30) NOT NULL,
    asunto VARCHAR(200),

    descripcion TEXT,

    fecha_programada TIMESTAMPTZ,
    fecha_realizada TIMESTAMPTZ,

    completado BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT seguimientos_lead_fk
        FOREIGN KEY (lead_id)
        REFERENCES leads(id)
        ON DELETE CASCADE,

    CONSTRAINT seguimientos_oportunidad_fk
        FOREIGN KEY (oportunidad_id)
        REFERENCES oportunidades(id)
        ON DELETE CASCADE,

    CONSTRAINT seguimientos_vendedor_fk
        FOREIGN KEY (vendedor_id)
        REFERENCES vendedores(id)
        ON DELETE SET NULL,

    CONSTRAINT seguimientos_tipo_ck
        CHECK (
            tipo IN (
                'LLAMADA',
                'WHATSAPP',
                'CORREO',
                'REUNION',
                'OTRO'
            )
        )
);


-- ============================================================
-- 17. VENTAS
-- ============================================================

CREATE TABLE ventas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    oportunidad_id UUID NOT NULL,
    contacto_id UUID NOT NULL,

    numero VARCHAR(50) NOT NULL UNIQUE,

    fecha_venta DATE NOT NULL DEFAULT CURRENT_DATE,

    monto_total NUMERIC(12,2) NOT NULL,
    monto_pagado NUMERIC(12,2) NOT NULL DEFAULT 0,

    moneda CHAR(3) NOT NULL DEFAULT 'USD',

    estado_pago VARCHAR(30) NOT NULL DEFAULT 'PENDIENTE',

    notas TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT ventas_oportunidad_fk
        FOREIGN KEY (oportunidad_id)
        REFERENCES oportunidades(id)
        ON DELETE RESTRICT,

    CONSTRAINT ventas_contacto_fk
        FOREIGN KEY (contacto_id)
        REFERENCES contactos(id)
        ON DELETE RESTRICT,

    CONSTRAINT ventas_monto_total_ck
        CHECK (monto_total >= 0),

    CONSTRAINT ventas_monto_pagado_ck
        CHECK (
            monto_pagado >= 0
            AND monto_pagado <= monto_total
        ),

    CONSTRAINT ventas_estado_pago_ck
        CHECK (
            estado_pago IN (
                'PENDIENTE',
                'PARCIAL',
                'PAGADO',
                'CANCELADO'
            )
        )
);


-- ============================================================
-- 18. CONVERSACIONES WHATSAPP
-- ============================================================

CREATE TABLE conversaciones_whatsapp (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    contacto_id UUID,
    lead_id UUID,

    whatsapp_phone VARCHAR(50) NOT NULL,

    proveedor VARCHAR(50),
    proveedor_conversation_id VARCHAR(150),

    estado VARCHAR(30) NOT NULL DEFAULT 'ACTIVA',

    fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_ultima_actividad TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT conversaciones_contacto_fk
        FOREIGN KEY (contacto_id)
        REFERENCES contactos(id)
        ON DELETE SET NULL,

    CONSTRAINT conversaciones_lead_fk
        FOREIGN KEY (lead_id)
        REFERENCES leads(id)
        ON DELETE SET NULL,

    CONSTRAINT conversaciones_estado_ck
        CHECK (
            estado IN (
                'ACTIVA',
                'CERRADA',
                'PAUSADA'
            )
        )
);


-- ============================================================
-- 19. MENSAJES WHATSAPP
-- ============================================================

CREATE TABLE mensajes_whatsapp (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    conversacion_id UUID NOT NULL,

    direccion VARCHAR(20) NOT NULL,

    tipo VARCHAR(30) NOT NULL DEFAULT 'TEXT',

    contenido TEXT,

    proveedor_message_id VARCHAR(150),

    fecha_mensaje TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT mensajes_conversacion_fk
        FOREIGN KEY (conversacion_id)
        REFERENCES conversaciones_whatsapp(id)
        ON DELETE CASCADE,

    CONSTRAINT mensajes_direccion_ck
        CHECK (
            direccion IN (
                'ENTRANTE',
                'SALIENTE'
            )
        ),

    CONSTRAINT mensajes_tipo_ck
        CHECK (
            tipo IN (
                'TEXT',
                'IMAGE',
                'DOCUMENT',
                'AUDIO',
                'VIDEO',
                'LOCATION',
                'TEMPLATE',
                'OTHER'
            )
        )
);


-- ============================================================
-- 20. EVENTOS WEB
-- ============================================================

CREATE TABLE eventos_web (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    contacto_id UUID,
    lead_id UUID,

    session_id VARCHAR(150),

    evento VARCHAR(100) NOT NULL,

    pagina VARCHAR(500),
    url TEXT,

    destino_id UUID,
    experiencia_id UUID,
    viaje_id UUID,
    oferta_id UUID,

    metadata JSONB,

    ip_hash VARCHAR(128),
    user_agent TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT eventos_contacto_fk
        FOREIGN KEY (contacto_id)
        REFERENCES contactos(id)
        ON DELETE SET NULL,

    CONSTRAINT eventos_lead_fk
        FOREIGN KEY (lead_id)
        REFERENCES leads(id)
        ON DELETE SET NULL,

    CONSTRAINT eventos_destino_fk
        FOREIGN KEY (destino_id)
        REFERENCES destinos(id)
        ON DELETE SET NULL,

    CONSTRAINT eventos_experiencia_fk
        FOREIGN KEY (experiencia_id)
        REFERENCES experiencias(id)
        ON DELETE SET NULL,

    CONSTRAINT eventos_viaje_fk
        FOREIGN KEY (viaje_id)
        REFERENCES viajes(id)
        ON DELETE SET NULL,

    CONSTRAINT eventos_oferta_fk
        FOREIGN KEY (oferta_id)
        REFERENCES ofertas(id)
        ON DELETE SET NULL
);


-- ============================================================
-- 21. ÍNDICES
-- ============================================================

CREATE INDEX idx_contactos_email
    ON contactos(email);

CREATE INDEX idx_contactos_whatsapp
    ON contactos(whatsapp);

CREATE INDEX idx_destinos_activo
    ON destinos(activo);

CREATE INDEX idx_destinos_destacado
    ON destinos(destacado);

CREATE INDEX idx_experiencias_activo
    ON experiencias(activo);

CREATE INDEX idx_viajes_destino
    ON viajes(destino_id);

CREATE INDEX idx_viajes_activo
    ON viajes(activo);

CREATE INDEX idx_ofertas_viaje
    ON ofertas(viaje_id);

CREATE INDEX idx_ofertas_activa
    ON ofertas(activa);

CREATE INDEX idx_campanas_activa
    ON campanas(activa);

CREATE INDEX idx_leads_contacto
    ON leads(contacto_id);

CREATE INDEX idx_leads_estado
    ON leads(estado);

CREATE INDEX idx_leads_origen
    ON leads(origen);

CREATE INDEX idx_leads_vendedor
    ON leads(vendedor_id);

CREATE INDEX idx_leads_created_at
    ON leads(created_at);

CREATE INDEX idx_oportunidades_lead
    ON oportunidades(lead_id);

CREATE INDEX idx_oportunidades_vendedor
    ON oportunidades(vendedor_id);

CREATE INDEX idx_oportunidades_etapa
    ON oportunidades(etapa);

CREATE INDEX idx_cotizaciones_oportunidad
    ON cotizaciones(oportunidad_id);

CREATE INDEX idx_cotizaciones_estado
    ON cotizaciones(estado);

CREATE INDEX idx_seguimientos_lead
    ON seguimientos(lead_id);

CREATE INDEX idx_seguimientos_oportunidad
    ON seguimientos(oportunidad_id);

CREATE INDEX idx_seguimientos_fecha_programada
    ON seguimientos(fecha_programada);

CREATE INDEX idx_ventas_oportunidad
    ON ventas(oportunidad_id);

CREATE INDEX idx_ventas_contacto
    ON ventas(contacto_id);

CREATE INDEX idx_ventas_fecha
    ON ventas(fecha_venta);

CREATE INDEX idx_whatsapp_contacto
    ON conversaciones_whatsapp(contacto_id);

CREATE INDEX idx_whatsapp_lead
    ON conversaciones_whatsapp(lead_id);

CREATE INDEX idx_whatsapp_phone
    ON conversaciones_whatsapp(whatsapp_phone);

CREATE INDEX idx_mensajes_conversacion
    ON mensajes_whatsapp(conversacion_id);

CREATE INDEX idx_mensajes_fecha
    ON mensajes_whatsapp(fecha_mensaje);

CREATE INDEX idx_eventos_web_evento
    ON eventos_web(evento);

CREATE INDEX idx_eventos_web_created_at
    ON eventos_web(created_at);

CREATE INDEX idx_eventos_web_session
    ON eventos_web(session_id);


-- ============================================================
-- 22. TRIGGERS updated_at
-- ============================================================

CREATE TRIGGER trg_contactos_updated_at
BEFORE UPDATE ON contactos
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_destinos_updated_at
BEFORE UPDATE ON destinos
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_experiencias_updated_at
BEFORE UPDATE ON experiencias
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_viajes_updated_at
BEFORE UPDATE ON viajes
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_ofertas_updated_at
BEFORE UPDATE ON ofertas
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_campanas_updated_at
BEFORE UPDATE ON campanas
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_leads_updated_at
BEFORE UPDATE ON leads
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_solicitudes_updated_at
BEFORE UPDATE ON solicitudes_cotizacion
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_vendedores_updated_at
BEFORE UPDATE ON vendedores
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_oportunidades_updated_at
BEFORE UPDATE ON oportunidades
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_cotizaciones_updated_at
BEFORE UPDATE ON cotizaciones
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_seguimientos_updated_at
BEFORE UPDATE ON seguimientos
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_ventas_updated_at
BEFORE UPDATE ON ventas
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_conversaciones_updated_at
BEFORE UPDATE ON conversaciones_whatsapp
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();


-- ============================================================
-- 23. FUNCIÓN: CREAR OPORTUNIDAD DESDE UN LEAD
-- ============================================================

CREATE OR REPLACE FUNCTION crear_oportunidad_desde_lead(
    p_lead_id UUID,
    p_vendedor_id UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_oportunidad_id UUID;
    v_nombre VARCHAR(200);
BEGIN

    SELECT
        COALESCE(
            NULLIF(
                TRIM(
                    c.nombre || ' ' || COALESCE(c.apellido, '')
                ),
                ''
            ),
            'Cliente sin nombre'
        )
        || ' - '
        || COALESCE(d.nombre, 'Viaje')
    INTO v_nombre
    FROM leads l
    JOIN contactos c
        ON c.id = l.contacto_id
    LEFT JOIN destinos d
        ON d.id = l.destino_id
    WHERE l.id = p_lead_id;

    IF v_nombre IS NULL THEN
        RAISE EXCEPTION 'El lead % no existe', p_lead_id;
    END IF;

    INSERT INTO oportunidades (
        lead_id,
        vendedor_id,
        nombre,
        etapa,
        valor_estimado,
        moneda
    )
    SELECT
        l.id,
        COALESCE(p_vendedor_id, l.vendedor_id),
        v_nombre,
        'NUEVA',
        l.presupuesto,
        l.moneda
    FROM leads l
    WHERE l.id = p_lead_id
    RETURNING id INTO v_oportunidad_id;

    RETURN v_oportunidad_id;
END;
$$;


-- ============================================================
-- 24. VISTA: RESUMEN DE LEADS
-- ============================================================

CREATE OR REPLACE VIEW vista_resumen_leads AS
SELECT
    l.id,
    l.created_at,
    l.estado,
    l.prioridad,
    l.origen,

    c.nombre,
    c.apellido,
    c.email,
    c.telefono,
    c.whatsapp,

    d.nombre AS destino,
    e.nombre AS experiencia,
    v.nombre AS viaje,

    ve.nombre AS vendedor,

    l.fecha_viaje,
    l.viajeros,
    l.duracion_dias,
    l.presupuesto,
    l.moneda

FROM leads l
JOIN contactos c
    ON c.id = l.contacto_id

LEFT JOIN destinos d
    ON d.id = l.destino_id

LEFT JOIN experiencias e
    ON e.id = l.experiencia_id

LEFT JOIN viajes v
    ON v.id = l.viaje_id

LEFT JOIN vendedores ve
    ON ve.id = l.vendedor_id;


-- ============================================================
-- 25. VISTA: PIPELINE COMERCIAL
-- ============================================================

CREATE OR REPLACE VIEW vista_pipeline_comercial AS
SELECT
    o.id,
    o.created_at,

    o.nombre,
    o.etapa,
    o.valor_estimado,
    o.moneda,
    o.probabilidad,

    l.id AS lead_id,
    l.estado AS lead_estado,
    l.origen,

    c.nombre AS contacto_nombre,
    c.apellido AS contacto_apellido,
    c.email,
    c.telefono,
    c.whatsapp,

    v.nombre AS vendedor,

    o.fecha_cierre_estimada,
    o.fecha_cierre_real

FROM oportunidades o

JOIN leads l
    ON l.id = o.lead_id

JOIN contactos c
    ON c.id = l.contacto_id

LEFT JOIN vendedores v
    ON v.id = o.vendedor_id;


-- ============================================================
-- 26. VISTA: RESUMEN DE VENTAS
-- ============================================================

CREATE OR REPLACE VIEW vista_resumen_ventas AS
SELECT
    v.id,
    v.numero,
    v.fecha_venta,

    c.nombre,
    c.apellido,
    c.email,

    v.monto_total,
    v.monto_pagado,
    v.moneda,
    v.estado_pago,

    o.nombre AS oportunidad,
    o.etapa

FROM ventas v

JOIN contactos c
    ON c.id = v.contacto_id

JOIN oportunidades o
    ON o.id = v.oportunidad_id;


-- ============================================================
-- 27. DATOS INICIALES: EXPERIENCIAS
-- ============================================================

INSERT INTO experiencias (
    nombre,
    slug,
    descripcion_corta,
    destacado,
    orden
)
VALUES
(
    'Playa',
    'playa',
    'Escapadas de playa, descanso y experiencias frente al mar.',
    TRUE,
    1
),
(
    'Aventura',
    'aventura',
    'Viajes para quienes buscan adrenalina, naturaleza y exploración.',
    TRUE,
    2
),
(
    'Cultura',
    'cultura',
    'Descubre historia, arte, patrimonio y tradiciones.',
    TRUE,
    3
),
(
    'Gastronomía',
    'gastronomia',
    'Experiencias para descubrir sabores y cocinas del mundo.',
    FALSE,
    4
),
(
    'Naturaleza',
    'naturaleza',
    'Paisajes, parques naturales y experiencias al aire libre.',
    TRUE,
    5
),
(
    'Luna de miel',
    'luna-de-miel',
    'Viajes románticos diseñados para celebrar momentos especiales.',
    TRUE,
    6
)
ON CONFLICT (slug) DO NOTHING;


-- ============================================================
-- 28. DATOS INICIALES: DESTINOS
-- ============================================================

INSERT INTO destinos (
    nombre,
    slug,
    continente,
    descripcion_corta,
    destacado,
    orden
)
VALUES
(
    'Europa',
    'europa',
    'Europa',
    'Descubre ciudades históricas, cultura, gastronomía y grandes rutas europeas.',
    TRUE,
    1
),
(
    'América',
    'america',
    'América',
    'Explora destinos de Norte, Centro y Sudamérica.',
    TRUE,
    2
),
(
    'Asia',
    'asia',
    'Asia',
    'Una combinación de cultura, tradición, naturaleza y modernidad.',
    TRUE,
    3
),
(
    'Medio Oriente',
    'medio-oriente',
    'Asia',
    'Historia, arquitectura, desiertos y experiencias únicas.',
    FALSE,
    4
),
(
    'África',
    'africa',
    'África',
    'Safaris, naturaleza y culturas extraordinarias.',
    FALSE,
    5
),
(
    'Caribe',
    'caribe',
    'América',
    'Playas, resorts y experiencias tropicales.',
    TRUE,
    6
)
ON CONFLICT (slug) DO NOTHING;


COMMIT;

-- ============================================================
-- FIN DE MIGRACIÓN
-- ============================================================
