-- ============================================================
-- GALERÍA DE VIAJES CRM
-- Operación comercial completa + captura pública segura
-- Fecha: 2026-09-18
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. PERMISOS CRM PARA CATÁLOGOS Y VENDEDORES
-- ------------------------------------------------------------

ALTER TABLE public.vendedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campanas ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.vendedores TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.campanas TO authenticated;

DROP POLICY IF EXISTS vendedores_crm_select ON public.vendedores;
CREATE POLICY vendedores_crm_select ON public.vendedores FOR SELECT TO authenticated
USING (public.crm_es_admin() OR public.crm_tiene_rol('SUPERVISOR') OR public.crm_tiene_rol('ASESOR') OR public.crm_tiene_rol('OPERACIONES') OR public.crm_tiene_rol('CONTABILIDAD'));

DROP POLICY IF EXISTS vendedores_admin_write ON public.vendedores;
CREATE POLICY vendedores_admin_write ON public.vendedores FOR ALL TO authenticated
USING (public.crm_es_admin()) WITH CHECK (public.crm_es_admin());

DROP POLICY IF EXISTS campanas_crm_select ON public.campanas;
CREATE POLICY campanas_crm_select ON public.campanas FOR SELECT TO authenticated
USING (public.crm_es_admin() OR public.crm_tiene_rol('SUPERVISOR') OR public.crm_tiene_rol('ASESOR') OR public.crm_tiene_rol('OPERACIONES') OR public.crm_tiene_rol('CONTABILIDAD'));

DROP POLICY IF EXISTS campanas_comercial_write ON public.campanas;
CREATE POLICY campanas_comercial_write ON public.campanas FOR INSERT TO authenticated
WITH CHECK (public.crm_es_admin() OR public.crm_tiene_rol('SUPERVISOR'));
DROP POLICY IF EXISTS campanas_comercial_update ON public.campanas;
CREATE POLICY campanas_comercial_update ON public.campanas FOR UPDATE TO authenticated
USING (public.crm_es_admin() OR public.crm_tiene_rol('SUPERVISOR'))
WITH CHECK (public.crm_es_admin() OR public.crm_tiene_rol('SUPERVISOR'));
DROP POLICY IF EXISTS campanas_admin_delete ON public.campanas;
CREATE POLICY campanas_admin_delete ON public.campanas FOR DELETE TO authenticated
USING (public.crm_es_admin());

-- Catálogo operativo: lectura pública activa, administración CRM por rol.
GRANT SELECT, INSERT, UPDATE, DELETE ON public.destinos TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.experiencias TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.viajes TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.ofertas TO authenticated;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['destinos','experiencias','viajes','ofertas'] LOOP
    EXECUTE format('DROP POLICY IF EXISTS crm_admin_select_%s ON public.%I',t,t);
    EXECUTE format('CREATE POLICY crm_admin_select_%s ON public.%I FOR SELECT TO authenticated USING (public.crm_es_admin() OR public.crm_tiene_rol(''SUPERVISOR'') OR public.crm_tiene_rol(''OPERACIONES''))',t,t);
    EXECUTE format('DROP POLICY IF EXISTS crm_ops_insert_%s ON public.%I',t,t);
    EXECUTE format('CREATE POLICY crm_ops_insert_%s ON public.%I FOR INSERT TO authenticated WITH CHECK (public.crm_es_admin() OR public.crm_tiene_rol(''SUPERVISOR'') OR public.crm_tiene_rol(''OPERACIONES''))',t,t);
    EXECUTE format('DROP POLICY IF EXISTS crm_ops_update_%s ON public.%I',t,t);
    EXECUTE format('CREATE POLICY crm_ops_update_%s ON public.%I FOR UPDATE TO authenticated USING (public.crm_es_admin() OR public.crm_tiene_rol(''SUPERVISOR'') OR public.crm_tiene_rol(''OPERACIONES'')) WITH CHECK (public.crm_es_admin() OR public.crm_tiene_rol(''SUPERVISOR'') OR public.crm_tiene_rol(''OPERACIONES''))',t,t);
    EXECUTE format('DROP POLICY IF EXISTS crm_admin_delete_%s ON public.%I',t,t);
    EXECUTE format('CREATE POLICY crm_admin_delete_%s ON public.%I FOR DELETE TO authenticated USING (public.crm_es_admin())',t,t);
  END LOOP;
END $$;

-- ------------------------------------------------------------
-- 2. SOLICITUDES DE COTIZACIÓN: CRM
-- ------------------------------------------------------------
ALTER TABLE public.solicitudes_cotizacion ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.solicitudes_cotizacion TO authenticated;
DROP POLICY IF EXISTS solicitudes_crm_select ON public.solicitudes_cotizacion;
CREATE POLICY solicitudes_crm_select ON public.solicitudes_cotizacion FOR SELECT TO authenticated
USING (public.crm_es_admin() OR public.crm_tiene_rol('SUPERVISOR') OR public.crm_tiene_rol('OPERACIONES') OR public.crm_tiene_rol('CONTABILIDAD') OR public.crm_tiene_rol('ASESOR'));
DROP POLICY IF EXISTS solicitudes_crm_insert ON public.solicitudes_cotizacion;
CREATE POLICY solicitudes_crm_insert ON public.solicitudes_cotizacion FOR INSERT TO authenticated
WITH CHECK (public.crm_es_admin() OR public.crm_tiene_rol('SUPERVISOR') OR public.crm_tiene_rol('OPERACIONES'));
DROP POLICY IF EXISTS solicitudes_crm_update ON public.solicitudes_cotizacion;
CREATE POLICY solicitudes_crm_update ON public.solicitudes_cotizacion FOR UPDATE TO authenticated
USING (public.crm_es_admin() OR public.crm_tiene_rol('SUPERVISOR') OR public.crm_tiene_rol('OPERACIONES') OR public.crm_tiene_rol('CONTABILIDAD'))
WITH CHECK (public.crm_es_admin() OR public.crm_tiene_rol('SUPERVISOR') OR public.crm_tiene_rol('OPERACIONES') OR public.crm_tiene_rol('CONTABILIDAD'));
DROP POLICY IF EXISTS solicitudes_crm_delete ON public.solicitudes_cotizacion;
CREATE POLICY solicitudes_crm_delete ON public.solicitudes_cotizacion FOR DELETE TO authenticated USING (public.crm_es_admin());

-- ------------------------------------------------------------
-- 3. ADMINISTRACIÓN DE PERFILES CRM
-- ------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON public.crm_usuarios TO authenticated;
DROP POLICY IF EXISTS crm_usuarios_admin_insert ON public.crm_usuarios;
CREATE POLICY crm_usuarios_admin_insert ON public.crm_usuarios FOR INSERT TO authenticated WITH CHECK (public.crm_es_admin());
DROP POLICY IF EXISTS crm_usuarios_admin_update ON public.crm_usuarios;
CREATE POLICY crm_usuarios_admin_update ON public.crm_usuarios FOR UPDATE TO authenticated USING (public.crm_es_admin()) WITH CHECK (public.crm_es_admin());
DROP POLICY IF EXISTS crm_usuarios_admin_delete ON public.crm_usuarios;
CREATE POLICY crm_usuarios_admin_delete ON public.crm_usuarios FOR DELETE TO authenticated USING (public.crm_es_admin());

-- ------------------------------------------------------------
-- 4. CAPTURA PÚBLICA: FUNCIÓN ÚNICA Y SEGURA
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.crear_lead_web(
    p_nombre varchar,
    p_apellido varchar DEFAULT NULL,
    p_email varchar DEFAULT NULL,
    p_telefono varchar DEFAULT NULL,
    p_whatsapp varchar DEFAULT NULL,
    p_destino_id uuid DEFAULT NULL,
    p_experiencia_id uuid DEFAULT NULL,
    p_viaje_id uuid DEFAULT NULL,
    p_fecha_salida date DEFAULT NULL,
    p_fecha_regreso date DEFAULT NULL,
    p_adultos integer DEFAULT 1,
    p_ninos integer DEFAULT 0,
    p_presupuesto_min numeric DEFAULT NULL,
    p_presupuesto_max numeric DEFAULT NULL,
    p_moneda char(3) DEFAULT 'USD',
    p_comentarios text DEFAULT NULL,
    p_acepta_comunicaciones boolean DEFAULT false
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_contacto_id uuid;
    v_lead_id uuid;
    v_existente uuid;
    v_viajeros integer;
    v_duracion integer;
BEGIN
    IF nullif(trim(p_nombre), '') IS NULL THEN
        RAISE EXCEPTION 'El nombre es obligatorio';
    END IF;
    IF p_email IS NULL AND p_telefono IS NULL AND p_whatsapp IS NULL THEN
        RAISE EXCEPTION 'Debe proporcionar correo, teléfono o WhatsApp';
    END IF;
    IF p_adultos IS NULL OR p_adultos < 1 THEN
        RAISE EXCEPTION 'La cantidad de adultos debe ser al menos 1';
    END IF;
    IF p_ninos IS NULL OR p_ninos < 0 THEN
        RAISE EXCEPTION 'La cantidad de niños no puede ser negativa';
    END IF;
    IF p_fecha_regreso IS NOT NULL AND p_fecha_salida IS NOT NULL AND p_fecha_regreso < p_fecha_salida THEN
        RAISE EXCEPTION 'La fecha de regreso no puede ser anterior a la fecha de salida';
    END IF;

    SELECT id INTO v_existente FROM public.contactos
    WHERE (p_email IS NOT NULL AND lower(email)=lower(trim(p_email)))
       OR (p_telefono IS NOT NULL AND telefono=trim(p_telefono))
       OR (p_whatsapp IS NOT NULL AND whatsapp=trim(p_whatsapp))
    ORDER BY created_at DESC LIMIT 1;

    IF v_existente IS NULL THEN
        INSERT INTO public.contactos(nombre,apellido,email,telefono,whatsapp,pais,idioma,acepta_comunicaciones,activo)
        VALUES(trim(p_nombre),nullif(trim(p_apellido),''),nullif(trim(p_email),''),nullif(trim(p_telefono),''),nullif(trim(p_whatsapp),''),'Costa Rica','es',coalesce(p_acepta_comunicaciones,false),true)
        RETURNING id INTO v_contacto_id;
    ELSE
        v_contacto_id := v_existente;
        UPDATE public.contactos SET
            nombre=coalesce(nullif(trim(p_nombre),''),nombre),
            apellido=coalesce(nullif(trim(p_apellido),''),apellido),
            email=coalesce(nullif(trim(p_email),''),email),
            telefono=coalesce(nullif(trim(p_telefono),''),telefono),
            whatsapp=coalesce(nullif(trim(p_whatsapp),''),whatsapp),
            acepta_comunicaciones=(acepta_comunicaciones OR coalesce(p_acepta_comunicaciones,false)),
            activo=true
        WHERE id=v_contacto_id;
    END IF;

    v_viajeros := p_adultos + p_ninos;
    IF p_fecha_salida IS NOT NULL AND p_fecha_regreso IS NOT NULL THEN
        v_duracion := greatest(1, p_fecha_regreso - p_fecha_salida);
    ELSE
        v_duracion := NULL;
    END IF;

    INSERT INTO public.leads(
        contacto_id,destino_id,experiencia_id,viaje_id,origen,estado,prioridad,
        fecha_viaje,viajeros,duracion_dias,presupuesto,moneda,mensaje
    ) VALUES (
        v_contacto_id,p_destino_id,p_experiencia_id,p_viaje_id,'WEB','NUEVO','NORMAL',
        p_fecha_salida,v_viajeros,v_duracion,p_presupuesto_max,coalesce(p_moneda,'USD'),p_comentarios
    ) RETURNING id INTO v_lead_id;

    INSERT INTO public.solicitudes_cotizacion(
        lead_id,fecha_salida,fecha_regreso,adultos,ninos,presupuesto_min,presupuesto_max,moneda,comentarios,estado
    ) VALUES (
        v_lead_id,p_fecha_salida,p_fecha_regreso,p_adultos,p_ninos,p_presupuesto_min,p_presupuesto_max,coalesce(p_moneda,'USD'),p_comentarios,'PENDIENTE'
    );

    RETURN v_lead_id;
END;
$$;

REVOKE ALL ON FUNCTION public.crear_lead_web(varchar,varchar,varchar,varchar,varchar,uuid,uuid,uuid,date,date,integer,integer,numeric,numeric,char,text,boolean) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.crear_lead_web(varchar,varchar,varchar,varchar,varchar,uuid,uuid,uuid,date,date,integer,integer,numeric,numeric,char,text,boolean) TO anon, authenticated;

COMMIT;
