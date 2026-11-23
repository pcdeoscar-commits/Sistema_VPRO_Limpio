--
-- PostgreSQL database dump
--

\restrict c5ka1pAXywZuCrYnfZQzRRfJMFZqx6ZIZyqfdkvAsWgXgrMSUvNmtGIpOT6ddRM

-- Dumped from database version 18.6 (Debian 18.6-1.pgdg13+2)
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.informes_gastos_detalle DROP CONSTRAINT IF EXISTS informes_gastos_detalle_id_informe_fkey;
ALTER TABLE IF EXISTS ONLY public.checkouts_detalle DROP CONSTRAINT IF EXISTS checkouts_detalle_id_maestro_fkey;
ALTER TABLE IF EXISTS ONLY public.chat_op_mensajes DROP CONSTRAINT IF EXISTS chat_op_mensajes_id_evento_fkey;
DROP INDEX IF EXISTS public.idx_chat_op_mensajes_evento;
DROP INDEX IF EXISTS public.idx_asistencia_evento;
ALTER TABLE IF EXISTS ONLY public.eventos DROP CONSTRAINT IF EXISTS uq_folio_vpro;
ALTER TABLE IF EXISTS ONLY public.eventos DROP CONSTRAINT IF EXISTS uq_folio;
ALTER TABLE IF EXISTS ONLY public.checkouts_maestro DROP CONSTRAINT IF EXISTS unique_op_empleado;
ALTER TABLE IF EXISTS ONLY public.reuniones_previas DROP CONSTRAINT IF EXISTS reuniones_previas_pkey;
ALTER TABLE IF EXISTS ONLY public.plantillas_checkout DROP CONSTRAINT IF EXISTS plantillas_checkout_pkey;
ALTER TABLE IF EXISTS ONLY public.mantenimiento_equipos DROP CONSTRAINT IF EXISTS mantenimiento_equipos_pkey;
ALTER TABLE IF EXISTS ONLY public.mantenimiento_equipos DROP CONSTRAINT IF EXISTS mantenimiento_equipos_num_servicio_key;
ALTER TABLE IF EXISTS ONLY public.kits_empleados DROP CONSTRAINT IF EXISTS kits_empleados_pkey;
ALTER TABLE IF EXISTS ONLY public.informes_gastos_maestro DROP CONSTRAINT IF EXISTS informes_gastos_maestro_pkey;
ALTER TABLE IF EXISTS ONLY public.informes_gastos_maestro DROP CONSTRAINT IF EXISTS informes_gastos_maestro_folio_vpro_key;
ALTER TABLE IF EXISTS ONLY public.informes_gastos_detalle DROP CONSTRAINT IF EXISTS informes_gastos_detalle_pkey;
ALTER TABLE IF EXISTS ONLY public.eventos DROP CONSTRAINT IF EXISTS folio;
ALTER TABLE IF EXISTS ONLY public.eventos DROP CONSTRAINT IF EXISTS eventos_pkey;
ALTER TABLE IF EXISTS ONLY public.cronogramas_eventos DROP CONSTRAINT IF EXISTS cronogramas_eventos_pkey;
ALTER TABLE IF EXISTS ONLY public.checkouts_maestro DROP CONSTRAINT IF EXISTS checkouts_maestro_pkey;
ALTER TABLE IF EXISTS ONLY public.checkouts_detalle DROP CONSTRAINT IF EXISTS checkouts_detalle_pkey;
ALTER TABLE IF EXISTS ONLY public.chat_op_mensajes DROP CONSTRAINT IF EXISTS chat_op_mensajes_pkey;
ALTER TABLE IF EXISTS ONLY public.asistencia_locacion DROP CONSTRAINT IF EXISTS asistencia_locacion_pkey;
ALTER TABLE IF EXISTS public.reuniones_previas ALTER COLUMN id_reunion DROP DEFAULT;
ALTER TABLE IF EXISTS public.plantillas_checkout ALTER COLUMN id_plantilla DROP DEFAULT;
ALTER TABLE IF EXISTS public.mantenimiento_equipos ALTER COLUMN id_solicitud DROP DEFAULT;
ALTER TABLE IF EXISTS public.kits_empleados ALTER COLUMN id_kit DROP DEFAULT;
ALTER TABLE IF EXISTS public.informes_gastos_maestro ALTER COLUMN id_informe DROP DEFAULT;
ALTER TABLE IF EXISTS public.informes_gastos_detalle ALTER COLUMN id_detalle DROP DEFAULT;
ALTER TABLE IF EXISTS public.eventos ALTER COLUMN id_evento DROP DEFAULT;
ALTER TABLE IF EXISTS public.cronogramas_eventos ALTER COLUMN id_cronograma DROP DEFAULT;
ALTER TABLE IF EXISTS public.checkouts_maestro ALTER COLUMN id_maestro DROP DEFAULT;
ALTER TABLE IF EXISTS public.checkouts_detalle ALTER COLUMN id_detalle DROP DEFAULT;
ALTER TABLE IF EXISTS public.chat_op_mensajes ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.asistencia_locacion ALTER COLUMN id_asistencia DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.reuniones_previas_id_reunion_seq;
DROP TABLE IF EXISTS public.reuniones_previas;
DROP SEQUENCE IF EXISTS public.plantillas_checkout_id_plantilla_seq;
DROP TABLE IF EXISTS public.plantillas_checkout;
DROP SEQUENCE IF EXISTS public.mantenimiento_equipos_id_solicitud_seq;
DROP TABLE IF EXISTS public.mantenimiento_equipos;
DROP SEQUENCE IF EXISTS public.kits_empleados_id_kit_seq;
DROP TABLE IF EXISTS public.kits_empleados;
DROP SEQUENCE IF EXISTS public.informes_gastos_maestro_id_informe_seq;
DROP TABLE IF EXISTS public.informes_gastos_maestro;
DROP SEQUENCE IF EXISTS public.informes_gastos_detalle_id_detalle_seq;
DROP TABLE IF EXISTS public.informes_gastos_detalle;
DROP SEQUENCE IF EXISTS public.eventos_id_evento_seq;
DROP TABLE IF EXISTS public.eventos;
DROP SEQUENCE IF EXISTS public.cronogramas_eventos_id_cronograma_seq;
DROP TABLE IF EXISTS public.cronogramas_eventos;
DROP SEQUENCE IF EXISTS public.checkouts_maestro_id_maestro_seq;
DROP TABLE IF EXISTS public.checkouts_maestro;
DROP SEQUENCE IF EXISTS public.checkouts_detalle_id_detalle_seq;
DROP TABLE IF EXISTS public.checkouts_detalle;
DROP SEQUENCE IF EXISTS public.chat_op_mensajes_id_seq;
DROP TABLE IF EXISTS public.chat_op_mensajes;
DROP SEQUENCE IF EXISTS public.asistencia_locacion_id_asistencia_seq;
DROP TABLE IF EXISTS public.asistencia_locacion;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: asistencia_locacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asistencia_locacion (
    id_asistencia integer NOT NULL,
    id_evento integer NOT NULL,
    fecha_jornada date NOT NULL,
    num_empleado integer,
    nombre_empleado character varying(150),
    depto character varying(100),
    hora_entrada time without time zone NOT NULL,
    t_desayuno numeric(4,2) DEFAULT 0,
    t_comida numeric(4,2) DEFAULT 0,
    t_cena numeric(4,2) DEFAULT 0,
    hora_salida time without time zone NOT NULL,
    observaciones text,
    fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: asistencia_locacion_id_asistencia_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.asistencia_locacion_id_asistencia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asistencia_locacion_id_asistencia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.asistencia_locacion_id_asistencia_seq OWNED BY public.asistencia_locacion.id_asistencia;


--
-- Name: chat_op_mensajes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chat_op_mensajes (
    id integer NOT NULL,
    id_evento integer NOT NULL,
    folio character varying(50),
    id_empleado character varying(50),
    autor_nombre character varying(255) NOT NULL,
    autor_rol character varying(100),
    mensaje text NOT NULL,
    tipo_mensaje character varying(50) DEFAULT 'TEXTO'::character varying,
    archivo_url text,
    fecha_hora timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    es_fijado boolean DEFAULT false,
    reacciones jsonb DEFAULT '{}'::jsonb
);


--
-- Name: chat_op_mensajes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chat_op_mensajes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chat_op_mensajes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chat_op_mensajes_id_seq OWNED BY public.chat_op_mensajes.id;


--
-- Name: checkouts_detalle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checkouts_detalle (
    id_detalle integer NOT NULL,
    id_maestro integer,
    codigo_equipo character varying(50) NOT NULL,
    cantidad integer NOT NULL,
    observaciones text,
    incidencias text DEFAULT 'Sin incidencias'::text,
    cotejado boolean DEFAULT false,
    notas_regreso text
);


--
-- Name: checkouts_detalle_id_detalle_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checkouts_detalle_id_detalle_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checkouts_detalle_id_detalle_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checkouts_detalle_id_detalle_seq OWNED BY public.checkouts_detalle.id_detalle;


--
-- Name: checkouts_maestro; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checkouts_maestro (
    id_maestro integer NOT NULL,
    folio_op integer NOT NULL,
    id_empleado character varying(3) NOT NULL,
    fecha date DEFAULT CURRENT_DATE NOT NULL,
    hora time with time zone DEFAULT CURRENT_TIME NOT NULL,
    incidencias_generales text,
    estado_bodega character varying(20) DEFAULT 'PENDIENTE'::character varying,
    nombre_kit text
);


--
-- Name: checkouts_maestro_id_maestro_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checkouts_maestro_id_maestro_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checkouts_maestro_id_maestro_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checkouts_maestro_id_maestro_seq OWNED BY public.checkouts_maestro.id_maestro;


--
-- Name: cronogramas_eventos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cronogramas_eventos (
    id_cronograma integer NOT NULL,
    folio character varying(50),
    fecha date,
    nombre_evento character varying(255),
    ubicacion_general character varying(255),
    folio_op character varying(50),
    actividades jsonb DEFAULT '[]'::jsonb,
    observaciones_generales text,
    creado_por character varying(150),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: cronogramas_eventos_id_cronograma_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cronogramas_eventos_id_cronograma_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cronogramas_eventos_id_cronograma_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cronogramas_eventos_id_cronograma_seq OWNED BY public.cronogramas_eventos.id_cronograma;


--
-- Name: eventos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eventos (
    id_evento integer NOT NULL,
    folio character varying(50) NOT NULL,
    fec_de_elaboracion_de_op date DEFAULT CURRENT_DATE,
    empleado_que_creo_la_op character varying(100),
    para_q_cliente character varying(100),
    fec_de_instalacion date,
    nombre_evento character varying(200),
    hra_de_instalacion time without time zone,
    locacion character varying(200),
    fec_del_evento date,
    inicio_del_evento time without time zone,
    quien_solicita character varying(150),
    hra_de_llamado time without time zone,
    ubicacion character varying(200),
    resp_de_produccion character varying(150),
    tipo_de_servicio text,
    produccion text,
    internet_redes text,
    actividades_de_proveedores text,
    nota text,
    elabora character varying(150),
    organiza character varying(150),
    coordina character varying(150),
    vobo character varying(150),
    proveedor_op text[] DEFAULT '{}'::text[],
    personal_convocado_op text[] DEFAULT '{}'::text[],
    carros_usados_op text[] DEFAULT '{}'::text[],
    externos_op text[] DEFAULT '{}'::text[],
    estatus character varying(50) DEFAULT 'ACTIVA'::character varying,
    reuniones_vinculadas text[] DEFAULT '{}'::text[],
    habilitada_para_edicion boolean DEFAULT false,
    fotos_evidencia text[] DEFAULT '{}'::text[],
    cronogramas_vinculados text[] DEFAULT '{}'::text[],
    chat_historial text,
    dependencia_solicita character varying(150) DEFAULT ''::character varying,
    fec_fin_evento date,
    id_cotizacion_vinculada integer,
    subtitulo_evento character varying(200) DEFAULT ''::character varying,
    detalle_llamado character varying(150) DEFAULT ''::character varying,
    rol_juegos text DEFAULT ''::text,
    vehiculo_destino character varying(100) DEFAULT ''::character varying,
    personal_roles_op jsonb DEFAULT '[]'::jsonb,
    responsable_gastos character varying(255),
    chofer character varying(255),
    horas_manejo_chofer numeric(5,2) DEFAULT 0.0,
    es_viaje_foraneo boolean DEFAULT false,
    chat_cerrado boolean DEFAULT false,
    chat_cerrado_por character varying(150),
    chat_fecha_cierre timestamp without time zone,
    choferes_por_vehiculo jsonb DEFAULT '{}'::jsonb,
    personal_remoto_foraneo text[] DEFAULT '{}'::text[],
    incidencias_por_dia jsonb DEFAULT '{}'::jsonb
);


--
-- Name: eventos_id_evento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.eventos_id_evento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eventos_id_evento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.eventos_id_evento_seq OWNED BY public.eventos.id_evento;


--
-- Name: informes_gastos_detalle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.informes_gastos_detalle (
    id_detalle integer NOT NULL,
    id_informe integer,
    dia_num integer,
    hotel numeric(10,2) DEFAULT 0,
    transporte numeric(10,2) DEFAULT 0,
    combustible numeric(10,2) DEFAULT 0,
    casetas numeric(10,2) DEFAULT 0,
    desayuno numeric(10,2) DEFAULT 0,
    comida numeric(10,2) DEFAULT 0,
    cenas numeric(10,2) DEFAULT 0,
    varios numeric(10,2) DEFAULT 0,
    total_dia numeric(10,2) DEFAULT 0
);


--
-- Name: informes_gastos_detalle_id_detalle_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.informes_gastos_detalle_id_detalle_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: informes_gastos_detalle_id_detalle_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.informes_gastos_detalle_id_detalle_seq OWNED BY public.informes_gastos_detalle.id_detalle;


--
-- Name: informes_gastos_maestro; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.informes_gastos_maestro (
    id_informe integer NOT NULL,
    folio_vpro integer NOT NULL,
    id_empleado character varying(3),
    periodo_desde date,
    periodo_hasta date,
    vehiculo character varying(100),
    km_inicial integer,
    km_final integer,
    departamento character varying(50),
    num_personas integer,
    subtotal numeric(12,2),
    monto_entregado numeric(12,2),
    restante numeric(12,2),
    fecha_registro date DEFAULT CURRENT_DATE,
    hora_registro time without time zone DEFAULT CURRENT_TIME,
    revisado boolean DEFAULT false
);


--
-- Name: informes_gastos_maestro_id_informe_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.informes_gastos_maestro_id_informe_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: informes_gastos_maestro_id_informe_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.informes_gastos_maestro_id_informe_seq OWNED BY public.informes_gastos_maestro.id_informe;


--
-- Name: kits_empleados; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kits_empleados (
    id_kit integer NOT NULL,
    id_empleado character varying(10),
    nombre_kit character varying(50),
    items jsonb
);


--
-- Name: kits_empleados_id_kit_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kits_empleados_id_kit_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kits_empleados_id_kit_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kits_empleados_id_kit_seq OWNED BY public.kits_empleados.id_kit;


--
-- Name: mantenimiento_equipos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mantenimiento_equipos (
    id_solicitud integer NOT NULL,
    num_servicio text,
    fecha_reporte timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    folio_vpro text,
    estatus_proceso text,
    codigo_equipo text,
    area_pertenece text,
    marca text,
    modelo text,
    num_serie text,
    responsable_actual text,
    quien_reporta text,
    responsiva_anterior text,
    "descripcion_daño" text,
    tipo_accion text,
    detalles_reparacion text,
    encargado_reparacion text,
    quien_recibe_equipo text,
    fecha_entrada_taller date,
    fecha_entrega_estimada date,
    costo_reparacion numeric(12,2),
    cotizacion_1 jsonb,
    cotizacion_2 jsonb,
    cotizacion_3 jsonb,
    cotizacion_seleccionada integer,
    fecha_pago date,
    fecha_llegada_nuevo date,
    nueva_responsiva text,
    firmas_digitales jsonb,
    registrado_por text,
    CONSTRAINT mantenimiento_equipos_tipo_accion_check CHECK ((tipo_accion = ANY (ARRAY['Reparación'::text, 'Reemplazo Piezas'::text, 'Adquisición Nuevo'::text, 'Baja'::text])))
);


--
-- Name: COLUMN mantenimiento_equipos.cotizacion_1; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.mantenimiento_equipos.cotizacion_1 IS 'Datos de compra: Proveedor, Cant, Costo, Importe, Plazo';


--
-- Name: mantenimiento_equipos_id_solicitud_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mantenimiento_equipos_id_solicitud_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mantenimiento_equipos_id_solicitud_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mantenimiento_equipos_id_solicitud_seq OWNED BY public.mantenimiento_equipos.id_solicitud;


--
-- Name: plantillas_checkout; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plantillas_checkout (
    id_plantilla integer NOT NULL,
    nombre_kit text NOT NULL,
    departamento text NOT NULL,
    codigo_equipo text NOT NULL,
    cantidad integer DEFAULT 1
);


--
-- Name: plantillas_checkout_id_plantilla_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plantillas_checkout_id_plantilla_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plantillas_checkout_id_plantilla_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plantillas_checkout_id_plantilla_seq OWNED BY public.plantillas_checkout.id_plantilla;


--
-- Name: reuniones_previas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reuniones_previas (
    id_reunion integer NOT NULL,
    fecha_reunion date NOT NULL,
    cliente_tentativo character varying(200) NOT NULL,
    nombre_proyecto_tentativo character varying(255) NOT NULL,
    asistentes text,
    minuta_acuerdos text,
    presupuesto_estimado numeric(12,2),
    fecha_probable_evento date,
    estatus_proyecto character varying(50) DEFAULT 'EN NEGOCIACIÓN'::character varying,
    fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    folio_op_generado integer
);


--
-- Name: reuniones_previas_id_reunion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reuniones_previas_id_reunion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reuniones_previas_id_reunion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reuniones_previas_id_reunion_seq OWNED BY public.reuniones_previas.id_reunion;


--
-- Name: asistencia_locacion id_asistencia; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asistencia_locacion ALTER COLUMN id_asistencia SET DEFAULT nextval('public.asistencia_locacion_id_asistencia_seq'::regclass);


--
-- Name: chat_op_mensajes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_op_mensajes ALTER COLUMN id SET DEFAULT nextval('public.chat_op_mensajes_id_seq'::regclass);


--
-- Name: checkouts_detalle id_detalle; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkouts_detalle ALTER COLUMN id_detalle SET DEFAULT nextval('public.checkouts_detalle_id_detalle_seq'::regclass);


--
-- Name: checkouts_maestro id_maestro; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkouts_maestro ALTER COLUMN id_maestro SET DEFAULT nextval('public.checkouts_maestro_id_maestro_seq'::regclass);


--
-- Name: cronogramas_eventos id_cronograma; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cronogramas_eventos ALTER COLUMN id_cronograma SET DEFAULT nextval('public.cronogramas_eventos_id_cronograma_seq'::regclass);


--
-- Name: eventos id_evento; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eventos ALTER COLUMN id_evento SET DEFAULT nextval('public.eventos_id_evento_seq'::regclass);


--
-- Name: informes_gastos_detalle id_detalle; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.informes_gastos_detalle ALTER COLUMN id_detalle SET DEFAULT nextval('public.informes_gastos_detalle_id_detalle_seq'::regclass);


--
-- Name: informes_gastos_maestro id_informe; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.informes_gastos_maestro ALTER COLUMN id_informe SET DEFAULT nextval('public.informes_gastos_maestro_id_informe_seq'::regclass);


--
-- Name: kits_empleados id_kit; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kits_empleados ALTER COLUMN id_kit SET DEFAULT nextval('public.kits_empleados_id_kit_seq'::regclass);


--
-- Name: mantenimiento_equipos id_solicitud; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mantenimiento_equipos ALTER COLUMN id_solicitud SET DEFAULT nextval('public.mantenimiento_equipos_id_solicitud_seq'::regclass);


--
-- Name: plantillas_checkout id_plantilla; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plantillas_checkout ALTER COLUMN id_plantilla SET DEFAULT nextval('public.plantillas_checkout_id_plantilla_seq'::regclass);


--
-- Name: reuniones_previas id_reunion; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reuniones_previas ALTER COLUMN id_reunion SET DEFAULT nextval('public.reuniones_previas_id_reunion_seq'::regclass);


--
-- Data for Name: asistencia_locacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.asistencia_locacion (id_asistencia, id_evento, fecha_jornada, num_empleado, nombre_empleado, depto, hora_entrada, t_desayuno, t_comida, t_cena, hora_salida, observaciones, fecha_registro) FROM stdin;
13	1	2026-08-16	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	09:00:00	0.00	1.00	0.00	22:00:00	Todo al chngz	2026-08-15 14:59:05.725143
14	1	2026-08-16	0	Edgar Javier Amarillas	STAFF VPRO	09:00:00	0.00	1.00	0.00	22:00:00	Todo al chngz	2026-08-15 14:59:05.725143
15	1	2026-08-16	0	Jose Francisco Torres Sanchez	STAFF VPRO	09:00:00	0.00	1.00	0.00	22:00:00	Todo al chngz	2026-08-15 14:59:05.725143
87	2	2026-08-18	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-08-19 12:00:41.793453
1	1	2026-08-13	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	09:00:00	1.00	1.00	1.00	22:00:00	Todo bien	2026-08-15 14:39:52.088462
2	1	2026-08-13	0	Edgar Javier Amarillas	STAFF VPRO	09:00:00	1.00	1.00	1.00	22:00:00	Todo bien	2026-08-15 14:39:52.088462
3	1	2026-08-13	0	Jose Francisco Torres Sanchez	STAFF VPRO	09:00:00	1.00	1.00	1.00	22:00:00	Todo bien	2026-08-15 14:39:52.088462
4	1	2026-08-14	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	09:00:00	1.00	1.00	1.00	22:00:00	Todo exceelnet	2026-08-15 14:40:05.139762
5	1	2026-08-14	0	Edgar Javier Amarillas	STAFF VPRO	09:00:00	1.00	1.00	1.00	22:00:00	Todo exceelnet	2026-08-15 14:40:05.139762
6	1	2026-08-14	0	Jose Francisco Torres Sanchez	STAFF VPRO	09:00:00	1.00	1.00	1.00	22:00:00	Todo exceelnet	2026-08-15 14:40:05.139762
7	1	2026-08-15	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	09:00:00	1.00	1.00	1.00	22:00:00	Todo al chngz	2026-08-15 14:40:22.65397
8	1	2026-08-15	0	Edgar Javier Amarillas	STAFF VPRO	09:00:00	1.00	1.00	1.00	22:00:00	Todo al chngz	2026-08-15 14:40:22.65397
9	1	2026-08-15	0	Jose Francisco Torres Sanchez	STAFF VPRO	09:00:00	1.00	1.00	1.00	22:00:00	Todo al chngz	2026-08-15 14:40:22.65397
84	2	2026-08-18	0	Edgar Javier Amarillas	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-08-19 12:00:41.793453
85	2	2026-08-18	0	Jose Daniel Torres Arroyo	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-08-19 12:00:41.793453
86	2	2026-08-18	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-08-19 12:00:41.793453
88	2	2026-08-18	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-08-19 12:00:41.793453
89	2	2026-08-18	0	Gerardo Villarreal Uribe	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-08-19 12:00:41.793453
90	2	2026-08-18	0	Martin Eduardo Sanchez Estrada	STAFF VPRO	09:00:00	0.00	2.00	0.00	19:00:00		2026-08-19 12:00:41.793453
183	8	2026-08-28	0	Martin Eduardo Sanchez Estrada	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-08-28 12:57:35.147946
184	8	2026-08-28	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	06:00:00	1.00	0.00	0.00	00:00:00		2026-08-28 12:57:35.147946
185	8	2026-08-28	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	06:00:00	1.00	0.00	0.00	00:00:00		2026-08-28 12:57:35.147946
186	8	2026-08-28	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-08-28 12:57:35.147946
187	8	2026-08-28	0	Jose Daniel Torres Arroyo	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-08-28 12:57:35.147946
188	8	2026-08-28	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-08-28 12:57:35.147946
189	8	2026-08-28	0	Gerardo Villarreal Uribe	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-08-28 12:57:35.147946
112	4	2026-08-20	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-08-20 17:10:45.736225
113	2	2026-08-19	0	Gerardo Villarreal Uribe	STAFF VPRO	09:00:00	0.00	0.50	0.00	21:25:00		2026-08-20 17:13:24.731447
114	2	2026-08-19	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	09:55:00	0.00	0.50	0.00	21:25:00		2026-08-20 17:13:24.731447
115	2	2026-08-19	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	09:00:00	0.00	0.50	0.00	21:25:00		2026-08-20 17:13:24.731447
116	2	2026-08-19	0	Jose Francisco Torres Sanchez	STAFF VPRO	09:00:00	0.00	0.50	0.00	21:25:00		2026-08-20 17:13:24.731447
117	2	2026-08-19	0	Jose Daniel Torres Arroyo	STAFF VPRO	09:00:00	0.00	0.50	0.00	21:25:00		2026-08-20 17:13:24.731447
118	2	2026-08-19	0	Edgar Javier Amarillas	STAFF VPRO	09:00:00	0.00	0.50	0.00	21:25:00		2026-08-20 17:13:24.731447
119	2	2026-08-19	0	Martin Eduardo Sanchez Estrada	STAFF VPRO	09:00:00	0.00	0.50	0.00	21:25:00		2026-08-20 17:13:24.731447
196	11	2026-09-04	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	09:00:00	0.50	0.00	0.00	23:34:00		2026-09-05 10:22:44.348451
197	11	2026-09-04	0	Edgar Javier Amarillas	STAFF VPRO	09:00:00	0.50	0.00	0.00	23:34:00		2026-09-05 10:22:44.348451
198	11	2026-09-04	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-05 10:22:44.348451
199	11	2026-09-04	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-05 10:22:44.348451
200	11	2026-09-04	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-05 10:22:44.348451
201	11	2026-09-04	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-05 10:22:44.348451
238	11	2026-09-07	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-07 11:36:14.954471
148	2	2026-08-21	0	Jose Francisco Torres Sanchez	STAFF VPRO	06:30:00	0.00	1.00	0.00	18:10:00		2026-08-22 10:16:41.253996
149	2	2026-08-21	0	Jose Daniel Torres Arroyo	STAFF VPRO	06:30:00	0.00	1.00	0.00	18:10:00		2026-08-22 10:16:41.253996
150	2	2026-08-21	0	Edgar Javier Amarillas	STAFF VPRO	06:30:00	0.00	1.00	0.00	18:10:00		2026-08-22 10:16:41.253996
151	2	2026-08-21	0	Martin Eduardo Sanchez Estrada	STAFF VPRO	06:30:00	0.00	1.00	0.00	18:10:00		2026-08-22 10:16:41.253996
152	2	2026-08-21	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	06:30:00	0.00	1.00	0.00	18:10:00		2026-08-22 10:16:41.253996
153	2	2026-08-21	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	06:30:00	0.00	1.00	0.00	18:10:00		2026-08-22 10:16:41.253996
154	2	2026-08-21	0	Gerardo Villarreal Uribe	STAFF VPRO	06:30:00	0.00	1.00	0.00	18:10:00		2026-08-22 10:16:41.253996
240	11	2026-09-07	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-07 11:36:14.954471
241	11	2026-09-07	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-07 11:36:14.954471
242	11	2026-09-07	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-07 11:36:14.954471
239	11	2026-09-07	0	Edgar Javier Amarillas	STAFF VPRO	08:36:00	1.00	0.00	0.00	13:19:06		2026-09-07 11:36:14.954471
243	11	2026-09-07	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	08:36:00	1.00	0.00	0.00	14:01:12		2026-09-07 11:36:14.954471
134	2	2026-08-20	0	Jose Daniel Torres Arroyo	STAFF VPRO	06:30:00	0.00	1.00	0.00	18:30:00		2026-08-22 10:15:54.912255
135	2	2026-08-20	0	Jose Francisco Torres Sanchez	STAFF VPRO	06:30:00	0.00	1.00	0.00	18:30:00		2026-08-22 10:15:54.912255
136	2	2026-08-20	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	06:30:00	0.00	1.00	0.00	18:30:00		2026-08-22 10:15:54.912255
137	2	2026-08-20	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	06:30:00	0.00	1.00	0.00	18:30:00		2026-08-22 10:15:54.912255
138	2	2026-08-20	0	Gerardo Villarreal Uribe	STAFF VPRO	06:30:00	0.00	1.00	0.00	18:30:00		2026-08-22 10:15:54.912255
139	2	2026-08-20	0	Martin Eduardo Sanchez Estrada	STAFF VPRO	06:30:00	0.00	1.00	0.00	18:30:00		2026-08-22 10:15:54.912255
140	2	2026-08-20	0	Edgar Javier Amarillas	STAFF VPRO	06:30:00	0.00	1.00	0.00	18:30:00		2026-08-22 10:15:54.912255
69	2	2026-08-17	0	Martin Eduardo Sanchez Estrada	STAFF VPRO	09:00:00	0.00	2.00	0.00	19:00:00	En este dia solo esta el Sr. geo en Maza	2026-08-18 17:44:02.911043
70	2	2026-08-17	0	Edgar Javier Amarillas	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00	En este dia solo esta el Sr. geo en Maza	2026-08-18 17:44:02.911043
71	2	2026-08-17	0	Jose Daniel Torres Arroyo	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00	En este dia solo esta el Sr. geo en Maza	2026-08-18 17:44:02.911043
72	2	2026-08-17	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00	En este dia solo esta el Sr. geo en Maza	2026-08-18 17:44:02.911043
73	2	2026-08-17	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00	En este dia solo esta el Sr. geo en Maza	2026-08-18 17:44:02.911043
74	2	2026-08-17	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00	En este dia solo esta el Sr. geo en Maza	2026-08-18 17:44:02.911043
75	2	2026-08-17	0	Gerardo Villarreal Uribe	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00	En este dia solo esta el Sr. geo en Maza	2026-08-18 17:44:02.911043
76	2	2026-08-17	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00	En este dia solo esta el Sr. geo en Maza	2026-08-18 17:44:02.911043
220	11	2026-09-05	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-07 11:34:39.8318
221	11	2026-09-05	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	16:00:00	0.00	0.00	0.00	22:46:00		2026-09-07 11:34:39.8318
222	11	2026-09-05	0	Edgar Javier Amarillas	STAFF VPRO	16:00:00	0.00	0.00	0.00	22:46:00		2026-09-07 11:34:39.8318
169	2	2026-08-22	0	Jose Daniel Torres Arroyo	STAFF VPRO	06:30:00	0.00	0.00	0.00	18:30:00		2026-08-24 10:09:41.151551
170	2	2026-08-22	0	Jose Francisco Torres Sanchez	STAFF VPRO	06:30:00	0.00	0.00	0.00	18:30:00		2026-08-24 10:09:41.151551
171	2	2026-08-22	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	06:30:00	0.00	0.00	0.00	18:30:00		2026-08-24 10:09:41.151551
172	2	2026-08-22	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	06:30:00	0.00	0.00	0.00	18:30:00		2026-08-24 10:09:41.151551
173	2	2026-08-22	0	Gerardo Villarreal Uribe	STAFF VPRO	06:30:00	0.00	0.00	0.00	18:30:00		2026-08-24 10:09:41.151551
174	2	2026-08-22	0	Martin Eduardo Sanchez Estrada	STAFF VPRO	06:30:00	0.00	0.00	0.00	18:30:00		2026-08-24 10:09:41.151551
175	2	2026-08-22	0	Edgar Javier Amarillas	STAFF VPRO	06:30:00	0.00	0.00	0.00	18:30:00		2026-08-24 10:09:41.151551
223	11	2026-09-05	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-07 11:34:39.8318
224	11	2026-09-05	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-07 11:34:39.8318
225	11	2026-09-05	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-07 11:34:39.8318
226	11	2026-09-06	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-07 11:35:19.166547
227	11	2026-09-06	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	15:30:00	0.00	0.00	0.00	21:40:00		2026-09-07 11:35:19.166547
228	11	2026-09-06	0	Edgar Javier Amarillas	STAFF VPRO	15:30:00	0.00	0.00	0.00	21:40:00		2026-09-07 11:35:19.166547
229	11	2026-09-06	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-07 11:35:19.166547
230	11	2026-09-06	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-07 11:35:19.166547
231	11	2026-09-06	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-09-07 11:35:19.166547
251	25	2026-10-03	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	00:00:00	0.50	0.00	0.50	00:28:00		2026-10-05 09:23:36.296342
252	25	2026-10-03	0	Edgar Javier Amarillas	STAFF VPRO	00:00:00	0.50	0.00	0.50	00:28:00		2026-10-05 09:23:36.296342
253	25	2026-10-03	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 09:23:36.296342
254	25	2026-10-03	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 09:23:36.296342
255	25	2026-10-03	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 09:23:36.296342
256	25	2026-10-03	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 09:23:36.296342
257	25	2026-10-03	0	Jose Daniel Torres Arroyo	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 09:23:36.296342
272	25	2026-10-04	0	Jose Daniel Torres Arroyo	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 09:25:29.008645
273	25	2026-10-04	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	10:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 09:25:29.008645
274	25	2026-10-04	0	Edgar Javier Amarillas	STAFF VPRO	10:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 09:25:29.008645
275	25	2026-10-04	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 09:25:29.008645
276	25	2026-10-04	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 09:25:29.008645
277	25	2026-10-04	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 09:25:29.008645
278	25	2026-10-04	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 09:25:29.008645
279	25	2026-10-05	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 17:26:04.093192
280	25	2026-10-05	0	Edgar Javier Amarillas	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 17:26:04.093192
400	43	2026-10-23	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-23 09:54:17.697021
402	43	2026-10-23	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-23 09:54:17.697021
403	43	2026-10-23	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-23 09:54:17.697021
404	43	2026-10-23	0	Jose Daniel Torres Arroyo	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-23 09:54:17.697021
281	25	2026-10-05	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 17:26:04.093192
282	25	2026-10-05	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 17:26:04.093192
283	25	2026-10-05	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 17:26:04.093192
284	25	2026-10-05	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	15:00:00		2026-10-05 17:26:04.093192
285	25	2026-10-05	0	Jose Daniel Torres Arroyo	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-05 17:26:04.093192
298	28	2026-10-08	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	09:20:00	0.00	0.00	0.00	19:00:00		2026-10-09 09:24:31.751425
299	28	2026-10-08	0	Jose Francisco Torres Sanchez	STAFF VPRO	09:12:00	0.00	0.00	0.00	19:00:00		2026-10-09 09:24:31.751425
300	28	2026-10-08	0	Jose Daniel Torres Arroyo	STAFF VPRO	08:50:00	0.00	0.00	0.00	19:00:00		2026-10-09 09:24:31.751425
350	32	2026-10-16	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	00:00:00	0.00	0.50	0.00	23:30:00		2026-10-17 09:18:44.110961
405	43	2026-10-23	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-23 09:54:17.697021
399	43	2026-10-23	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	09:12:00	0.00	0.00	0.00	14:02:06		2026-10-23 09:54:17.697021
401	43	2026-10-23	0	Edgar Javier Amarillas	STAFF VPRO	09:12:00	0.00	0.00	0.00	14:12:28		2026-10-23 09:54:17.697021
308	28	2026-10-09	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	06:00:00	0.00	0.00	0.00	18:11:09		2026-10-10 11:14:05.361111
309	28	2026-10-09	0	Jose Francisco Torres Sanchez	STAFF VPRO	06:00:00	0.00	0.00	0.00	17:50:00		2026-10-10 11:14:05.361111
310	28	2026-10-09	0	Jose Daniel Torres Arroyo	STAFF VPRO	06:00:00	0.00	0.00	0.00	17:49:23		2026-10-10 11:14:05.361111
311	29	2026-10-10	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	00:00:00	0.00	0.50	0.50	00:45:00		2026-10-12 10:28:04.740557
312	29	2026-10-10	0	Edgar Javier Amarillas	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:45:00		2026-10-12 10:28:04.740557
313	29	2026-10-10	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-12 10:28:04.740557
314	29	2026-10-10	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-12 10:28:04.740557
315	29	2026-10-10	0	Jose Daniel Torres Arroyo	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-12 10:28:04.740557
316	29	2026-10-10	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-12 10:28:04.740557
317	29	2026-10-10	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-12 10:28:04.740557
332	29	2026-10-11	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	09:00:00	0.00	0.00	0.00	11:48:00		2026-10-12 10:30:11.817116
333	29	2026-10-11	0	Edgar Javier Amarillas	STAFF VPRO	09:00:00	0.00	0.00	0.00	11:48:00		2026-10-12 10:30:11.817116
334	29	2026-10-11	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-12 10:30:11.817116
335	29	2026-10-11	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-12 10:30:11.817116
336	29	2026-10-11	0	Jose Daniel Torres Arroyo	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-12 10:30:11.817116
337	29	2026-10-11	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-12 10:30:11.817116
338	29	2026-10-11	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-12 10:30:11.817116
342	36	2026-10-14	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	00:00:00	0.00	0.00	0.00	19:30:00		2026-10-15 09:44:03.446296
351	32	2026-10-16	0	Edgar Javier Amarillas	STAFF VPRO	00:00:00	0.00	0.50	0.00	23:30:00		2026-10-17 09:18:44.110961
352	32	2026-10-16	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-17 09:18:44.110961
353	32	2026-10-16	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-17 09:18:44.110961
354	32	2026-10-16	0	Jose Daniel Torres Arroyo	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-17 09:18:44.110961
355	32	2026-10-16	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-17 09:18:44.110961
356	32	2026-10-16	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-17 09:18:44.110961
366	32	2026-10-17	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-17 09:54:23.386397
367	32	2026-10-17	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-17 09:54:23.386397
368	32	2026-10-17	0	Jose Daniel Torres Arroyo	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-17 09:54:23.386397
369	32	2026-10-17	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-17 09:54:23.386397
370	32	2026-10-17	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-17 09:54:23.386397
364	32	2026-10-17	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	09:45:00	0.00	0.00	0.00	14:01:53		2026-10-17 09:54:23.386397
365	32	2026-10-17	0	Edgar Javier Amarillas	STAFF VPRO	09:45:00	0.00	0.00	0.00	14:04:08		2026-10-17 09:54:23.386397
385	43	2026-10-22	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	00:00:00	0.00	0.50	0.00	22:30:00		2026-10-23 09:52:25.500464
386	43	2026-10-22	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-23 09:52:25.500464
387	43	2026-10-22	0	Edgar Javier Amarillas	STAFF VPRO	00:00:00	0.00	0.50	0.00	22:30:00		2026-10-23 09:52:25.500464
388	43	2026-10-22	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-23 09:52:25.500464
389	43	2026-10-22	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-23 09:52:25.500464
390	43	2026-10-22	0	Jose Daniel Torres Arroyo	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-23 09:52:25.500464
391	43	2026-10-22	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-10-23 09:52:25.500464
546	56	2026-11-14	0	Manuel Antonio Madrid Zazueta	REMOTO	15:00:00	0.00	0.00	0.00	00:00:00		2026-11-14 01:12:54.593607
547	56	2026-11-14	0	Edgar Javier Amarillas	REMOTO	15:00:00	0.00	0.00	0.00	00:00:00		2026-11-14 01:12:54.593607
568	56	2026-11-15	0	Edgar Javier Amarillas	REMOTO	10:00:00	0.00	0.00	0.00	00:00:00		2026-11-14 01:33:23.767185
569	56	2026-11-15	0	Manuel Antonio Madrid Zazueta	REMOTO	10:00:00	0.00	0.00	0.00	00:00:00		2026-11-14 01:33:23.767185
576	56	2026-11-13	0	Manuel Antonio Madrid Zazueta	REMOTO	11:30:00	0.00	0.00	0.00	00:00:00		2026-11-14 01:36:34.396525
577	56	2026-11-13	0	Edgar Javier Amarillas	REMOTO	11:30:00	0.00	0.00	0.00	00:00:00		2026-11-14 01:36:34.396525
578	56	2026-11-13	0	Osiel Cuauhtemoc Hernandez Aldape	ESTUDIO	18:00:00	0.00	0.00	0.00	00:00:00		2026-11-14 01:36:34.396525
579	56	2026-11-13	0	Cuahutémoc Rivera Agúndez	ESTUDIO	18:00:00	0.00	0.00	0.00	00:00:00		2026-11-14 01:36:34.396525
436	48	2026-11-04	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	16:00:00	0.00	0.00	0.00	23:30:00		2026-11-05 15:56:00.265101
437	48	2026-11-04	0	Edgar Javier Amarillas	STAFF VPRO	16:00:00	0.00	0.00	0.00	23:30:00		2026-11-05 15:56:00.265101
438	48	2026-11-04	0	Cuahutémoc Rivera Agúndez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-11-05 15:56:00.265101
439	48	2026-11-04	0	Jose Daniel Torres Arroyo	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-11-05 15:56:00.265101
440	48	2026-11-04	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-11-05 15:56:00.265101
441	48	2026-11-04	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-11-05 15:56:00.265101
548	56	2026-11-14	0	Osiel Cuauhtemoc Hernandez Aldape	ESTUDIO	15:00:00	0.00	0.00	0.00	00:00:00		2026-11-14 01:12:54.593607
456	48	2026-11-05	0	Cuahutémoc Rivera Agúndez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-11-05 16:48:08.892089
457	48	2026-11-05	0	Jose Daniel Torres Arroyo	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-11-05 16:48:08.892089
458	48	2026-11-05	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-11-05 16:48:08.892089
459	48	2026-11-05	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-11-05 16:48:08.892089
454	48	2026-11-05	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	09:35:00	0.00	0.00	0.00	14:00:55		2026-11-05 16:48:08.892089
455	48	2026-11-05	0	Edgar Javier Amarillas	STAFF VPRO	09:35:00	0.00	0.00	0.00	14:04:34		2026-11-05 16:48:08.892089
466	48	2026-11-03	0	Jose Francisco Torres Sanchez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-11-07 00:24:43.638964
467	48	2026-11-03	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-11-07 00:24:43.638964
468	48	2026-11-03	0	Jose Daniel Torres Arroyo	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-11-07 00:24:43.638964
469	48	2026-11-03	0	Cuahutémoc Rivera Agúndez	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-11-07 00:24:43.638964
470	48	2026-11-03	0	Edgar Javier Amarillas	STAFF VPRO	00:00:00	0.00	1.00	0.00	23:00:00		2026-11-07 00:24:43.638964
471	48	2026-11-03	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	00:00:00	0.00	1.00	0.00	23:00:00		2026-11-07 00:24:43.638964
580	56	2026-11-13	0	Carlos Jacobo Quezada Mendoza	ESTUDIO	18:00:00	0.00	0.00	0.00	00:00:00		2026-11-14 01:36:34.396525
581	56	2026-11-13	0	Jose Francisco Torres Sanchez	ESTUDIO	18:00:00	0.00	0.00	0.00	00:00:00		2026-11-14 01:36:34.396525
549	56	2026-11-14	0	Cuahutémoc Rivera Agúndez	ESTUDIO	15:00:00	0.00	0.00	0.00	00:00:00		2026-11-14 01:12:54.593607
550	56	2026-11-14	0	Carlos Jacobo Quezada Mendoza	ESTUDIO	15:00:00	0.00	0.00	0.00	00:00:00		2026-11-14 01:12:54.593607
551	56	2026-11-14	0	Jose Francisco Torres Sanchez	ESTUDIO	15:00:00	0.00	0.00	0.00	00:00:00		2026-11-14 01:12:54.593607
519	53	2026-11-09	0	Jose Daniel Torres Arroyo	STAFF VPRO	06:00:00	0.00	1.50	0.00	15:38:00		2026-11-09 23:45:34.572758
520	53	2026-11-09	0	Jose Francisco Torres Sanchez	STAFF VPRO	06:00:00	0.00	1.50	0.00	15:38:00		2026-11-09 23:45:34.572758
521	53	2026-11-09	0	Cuahutémoc Rivera Agúndez	STAFF VPRO	06:00:00	0.00	1.50	0.00	15:28:00		2026-11-09 23:45:34.572758
522	53	2026-11-09	0	Carlos Jacobo Quezada Mendoza	STAFF VPRO	06:00:00	0.00	1.50	0.00	15:32:00		2026-11-09 23:45:34.572758
523	53	2026-11-09	0	Martin Eduardo Sanchez Estrada	STAFF VPRO	06:00:00	0.00	1.50	0.00	15:35:00		2026-11-09 23:45:34.572758
524	53	2026-11-09	0	Osiel Cuauhtemoc Hernandez Aldape	STAFF VPRO	06:00:00	0.00	1.50	0.00	15:40:00		2026-11-09 23:45:34.572758
525	53	2026-11-09	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	06:00:00	0.00	1.50	0.00	15:57:00		2026-11-09 23:45:34.572758
\.


--
-- Data for Name: chat_op_mensajes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.chat_op_mensajes (id, id_evento, folio, id_empleado, autor_nombre, autor_rol, mensaje, tipo_mensaje, archivo_url, fecha_hora, es_fijado, reacciones) FROM stdin;
89	47	47	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚀 Canal operativo iniciado para la OP-47: SESION PRESENCIAL.\n📅 Fecha: 2026-11-03 | ⏰ Llamado: 09:00 hrs | 📍 Locación: Instalaciones de IEES.\nTodo reporte técnico, avisos de traslado y evidencias se registrarán en esta bitácora.	SISTEMA	\N	2026-10-30 11:13:40.958633	f	{}
91	48	48	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚀 Canal operativo iniciado para la OP-48: TORNEO DE LIGA DE BALONCESTO DEL PACIFICO 2026 ASCENSO TEBACAS.\n📅 Fecha: 2026-10-31 | ⏰ Llamado: 09:00 hrs | 📍 Locación: Arena Badiraguato.\nTodo reporte técnico, avisos de traslado y evidencias se registrarán en esta bitácora.	SISTEMA	\N	2026-10-31 09:11:03.196609	f	{}
93	49	49	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚐 Logística de Chofer: Chofer designado -> Jose Francisco Torres Sanchez.	SISTEMA	\N	2026-10-31 10:58:42.020124	f	{}
95	48	48	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚐 Logística de Chofer: Chofer designado -> Manuel Antonio Madrid Zazueta.	SISTEMA	\N	2026-10-31 11:00:54.58288	f	{}
96	48	48	203	Pedro Villarreal Uribe	ADMIN	Enerado!	TEXTO	\N	2026-10-31 11:18:07.637063	f	{}
97	48	48	201	Cuahutémoc Rivera Agúndez	ADMIN	esto	TEXTO	\N	2026-10-31 11:18:20.798901	f	{}
98	48	48	201	Cuahutémoc Rivera Agúndez	ADMIN	si	TEXTO	\N	2026-10-31 11:18:23.431104	f	{}
99	48	48	201	Cuahutémoc Rivera Agúndez	ADMIN	estaba	TEXTO	\N	2026-10-31 11:18:25.0497	f	{}
100	48	48	201	Cuahutémoc Rivera Agúndez	ADMIN	mas que probado	TEXTO	\N	2026-10-31 11:18:28.818727	f	{}
102	49	49	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	📅 Cronograma Vinculado: Se asignó (FOLIO: 04 | 03/11/2026 - Asenso TEBACAS).	SISTEMA	\N	2026-10-31 14:00:21.233847	f	{}
103	49	49	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	⏰ Recordatorio de Llamado: Faltan aproximadamente 120 minutos para la cita (08:00 hrs).\n📍 Locación: Instalaciones IEES.\n🚐 Chofer / Traslado: Jose Francisco Torres Sanchez.\nEquipo técnico: favor de reportar estatus de salida o llegada a través de este canal.	SISTEMA	\N	2026-11-03 05:59:41.527451	f	{}
104	47	47	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	⏰ Recordatorio de Llamado: Faltan aproximadamente 120 minutos para la cita (09:00 hrs).\n📍 Locación: Instalaciones de IEES.\n🚐 Chofer / Traslado: No asignado.\nEquipo técnico: favor de reportar estatus de salida o llegada a través de este canal.	SISTEMA	\N	2026-11-03 06:59:41.522087	f	{}
106	48	48	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	📅 Cronograma Vinculado: Se asignó (FOLIO: 04 | 03/11/2026 - Asenso TEBACAS).	SISTEMA	\N	2026-11-03 16:01:49.782857	f	{}
109	51	51	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	👥 Actualización de Crew: Se incorporó a: Jose Daniel Torres Arroyo, Jose Francisco Torres Sanchez.	SISTEMA	\N	2026-11-05 11:54:56.498196	f	{}
111	51	51	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚐 Logística de Chofer: Chofer designado -> Jose Francisco Torres Sanchez.	SISTEMA	\N	2026-11-05 17:02:52.374331	f	{}
113	51	51	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	⏰ Recordatorio de Llamado: Faltan aproximadamente 124 minutos para la cita (09:00 hrs).\n📍 Locación: Centro.\n🚐 Chofer / Traslado: Jose Francisco Torres Sanchez.\nEquipo técnico: favor de reportar estatus de salida o llegada a través de este canal.	SISTEMA	\N	2026-11-06 06:55:50.407772	f	{}
118	53	53	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚐 Logística de Chofer: Chofer designado -> Manuel Antonio Madrid Zazueta.	SISTEMA	\N	2026-11-11 10:34:44.939125	f	{}
122	55	55	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚀 Canal operativo iniciado para la OP-55: Fiscalia.\n📅 Fecha: 2026-11-12 | ⏰ Llamado: 08:00 hrs | 📍 Locación: Fiscalia.\nTodo reporte técnico, avisos de traslado y evidencias se registrarán en esta bitácora.	SISTEMA	\N	2026-11-12 09:12:27.612181	f	{}
125	50	50	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚐 Logística de Chofer: Chofer designado -> Jose Francisco Torres Sanchez.	SISTEMA	\N	2026-11-12 12:32:33.931038	f	{}
128	55	55	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	📍 Actualización de Locación: Nueva sede asignada -> Estacionamiento de Fiscalía.	SISTEMA	\N	2026-11-13 10:13:00.774301	f	{}
1	43	43	201	Cuauhtemoc Rivera Agundez	ADMIN	Hola Manuel Eduardo	TEXTO	\N	2026-10-26 16:51:07.121508	f	{}
2	43	43	124	Manuel Eduardo Madrid	COORDINADOR	Hola	TEXTO	\N	2026-10-26 16:52:49.460853	f	{}
3	43	43	201	Cuauhtemoc Rivera Agundez	ADMIN	Que tan rápido llega	TEXTO	\N	2026-10-26 16:55:37.066078	f	{}
4	43	43	104	Jose Francisco Torres Sanchez	PRODUCCION	Hey hay que ir a pistear	TEXTO	\N	2026-10-26 16:58:42.97324	f	{}
5	43	43	104	Jose Francisco Torres Sanchez	PRODUCCION	Ingasu	TEXTO	\N	2026-10-26 16:58:54.801638	f	{}
6	43	43	201	Cuauhtemoc Rivera Agundez	ADMIN	Ese mi pacooooo	TEXTO	\N	2026-10-26 16:59:01.582448	f	{}
7	43	43	104	Jose Francisco Torres Sanchez	PRODUCCION	📷 Foto enviada	IMAGEN	/Fotos_de_eventos/chat_op/op_43_20261026_235926_17930591502212230135.jpg	2026-10-26 16:59:26.077966	f	{}
8	43	43	119	Manuel Antonio Madrid Zazueta	ADMIN	buenas tardes	TEXTO	\N	2026-10-26 17:03:40.354884	f	{}
9	43	43	201	Cuauhtemoc Rivera Agundez	ADMIN	Hola Manuel cómo estás?	TEXTO	\N	2026-10-26 17:04:01.819889	f	{}
10	43	43	119	Manuel Antonio Madrid Zazueta	ADMIN	Aquí chateas	TEXTO	\N	2026-10-26 17:10:51.835816	f	{}
11	45	45	201	Cuauhtemoc Rivera Agundez	ADMIN	Hola sofia	TEXTO	\N	2026-10-26 17:43:33.543711	f	{}
12	45	45	121	Sofia Alejandra Villarreal Lopez	ADMIN	Buen dia, estamos realizando pruebas!	TEXTO	\N	2026-10-26 17:43:49.46462	f	{}
13	45	45	200	Andrea Maria Vilarreal Lopez	ADMIN	Hola !!	TEXTO	\N	2026-10-26 18:18:06.058158	f	{}
14	45	45	201	Cuauhtemoc Rivera Agundez	ADMIN	Hola andrea	TEXTO	\N	2026-10-26 18:19:12.068831	f	{}
15	38	38	201	Cuauhtemoc Rivera Agundez	ADMIN	hi	TEXTO	\N	2026-10-26 18:48:22.275025	f	{}
17	43	43	202	Edgar Javier Amarillas	PRODUCCION	Ke wuapos	TEXTO	\N	2026-10-27 11:01:37.302417	f	{}
16	43	43	201	Cuauhtemoc Rivera Agundez	ADMIN	📷 Foto enviada	IMAGEN	/Fotos_de_eventos/chat_op/op_43_20261027_175535_image.jpg	2026-10-27 10:55:35.458142	f	{"👍": ["Edgar Javier Amarillas", "Cuauhtemoc Rivera Agundez"]}
19	37	37	203	Pedro Villarreal Uribe	ADMIN	excelente!	TEXTO	\N	2026-10-27 17:07:06.671804	f	{}
24	37	37	203	Pedro Villarreal Uribe	ADMIN	hola	TEXTO	\N	2026-10-27 17:12:28.465489	f	{}
27	45	45	203	Pedro Villarreal Uribe	ADMIN	hola	TEXTO	\N	2026-10-27 17:14:07.89314	f	{}
18	37	37	201	Cuauhtemoc Rivera Agundez	ADMIN	Hola	TEXTO	\N	2026-10-27 17:06:59.704753	f	{}
20	37	37	201	Cuauhtemoc Rivera Agundez	ADMIN	Hola Pedro	TEXTO	\N	2026-10-27 17:07:07.864881	f	{}
21	37	37	201	Cuauhtemoc Rivera Agundez	ADMIN	📷 Foto enviada	IMAGEN	/Fotos_de_eventos/chat_op/op_37_20261028_000739_image.jpg	2026-10-27 17:07:39.24546	f	{}
22	37	37	201	Cuauhtemoc Rivera Agundez	ADMIN	Hola Ana	TEXTO	\N	2026-10-27 17:11:40.788055	f	{}
23	37	37	201	Cuauhtemoc Rivera Agundez	ADMIN	Como esta?	TEXTO	\N	2026-10-27 17:11:50.138739	f	{}
25	37	37	201	Cuauhtemoc Rivera Agundez	ADMIN	Que paso	TEXTO	\N	2026-10-27 17:12:32.699203	f	{}
26	37	37	201	Cuauhtemoc Rivera Agundez	ADMIN	Jajajaj	TEXTO	\N	2026-10-27 17:12:40.650955	f	{}
28	46	46	201	Cuauhtemoc Rivera Agundez	ADMIN	Chat Prueba.	TEXTO	\N	2026-10-28 13:00:22.586083	f	{}
90	35	35	107	SISTEMA VPRO	AUDITORÍA	🔒 El chat operativo de esta OP ha sido cerrado y sellado oficialmente por el Productor Martin Eduardo Sanchez Estrada. La bitácora ha sido integrada al expediente histórico.	SISTEMA	\N	2026-10-30 18:34:43.912838	f	{}
92	49	49	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚀 Canal operativo iniciado para la OP-49: SESION EXTRAORDINARIA PRESENCIAL.\n📅 Fecha: 2026-11-03 | ⏰ Llamado: 08:00 hrs | 📍 Locación: Instalaciones IEES.\nTodo reporte técnico, avisos de traslado y evidencias se registrarán en esta bitácora.	SISTEMA	\N	2026-10-31 09:15:27.573121	f	{}
94	48	48	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	⏱️ Cambio de Horario del Evento: Modificado de las 13:30 a las 19:00 hrs.	SISTEMA	\N	2026-10-31 11:00:54.57992	f	{}
101	48	48	202	Edgar Javier Amarillas	PRODUCCION	Enterado salida a las 9 am	TEXTO	\N	2026-10-31 13:47:44.53275	f	{}
105	48	48	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	⏰ Recordatorio de Llamado: Faltan aproximadamente 120 minutos para la cita (09:00 hrs).\n📍 Locación: Arena Badiraguato.\n🚐 Chofer / Traslado: Manuel Antonio Madrid Zazueta.\nEquipo técnico: favor de reportar estatus de salida o llegada a través de este canal.	SISTEMA	\N	2026-11-03 06:59:41.528195	f	{}
107	50	50	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚀 Canal operativo iniciado para la OP-50: SESION EXTRAORDINARIA PRESENCIAL EN IEES.\n📅 Fecha: 2026-11-12 | ⏰ Llamado: 09:00 hrs | 📍 Locación: Instalaciones de IEES.\nTodo reporte técnico, avisos de traslado y evidencias se registrarán en esta bitácora.	SISTEMA	\N	2026-11-04 18:06:33.159914	f	{}
108	51	51	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚀 Canal operativo iniciado para la OP-51: INAUGURACION DE CORREDOR DE LA SALUD "ARCANGEL "RAFAEL".\n📅 Fecha: 2026-11-06 | ⏰ Llamado: 09:00 hrs | 📍 Locación: Centro.\nTodo reporte técnico, avisos de traslado y evidencias se registrarán en esta bitácora.	SISTEMA	\N	2026-11-05 11:22:51.866529	f	{}
110	51	51	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	⏱️ Cambio de Horario del Evento: Modificado de las 17:30 a las 17:00 hrs.	SISTEMA	\N	2026-11-05 17:02:52.370099	f	{}
112	48	48	201	Cuahutémoc Rivera Agúndez	ADMIN	¿Y que los mandaran al Rosario?... ingasu.	TEXTO	\N	2026-11-05 18:12:33.484141	f	{}
116	53	53	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚀 Canal operativo iniciado para la OP-53: Rueda de prensa Harfuch.\n📅 Fecha: 2026-11-09 | ⏰ Llamado: 06:00 hrs | 📍 Locación: lll REGIÓN MILITAR CUARTEL GENERAL.\nTodo reporte técnico, avisos de traslado y evidencias se registrarán en esta bitácora.	SISTEMA	\N	2026-11-09 09:26:26.71363	f	{}
117	50	50	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	⏱️ Cambio de Horario del Evento: Modificado de las 11:00 a las 12:00 hrs.	SISTEMA	\N	2026-11-11 09:15:55.160172	f	{}
119	50	50	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	👥 Actualización de Crew: Se incorporó a: Martin Eduardo Sanchez Estrada, Manuel Antonio Madrid Zazueta, Osiel Cuauhtemoc Hernandez Aldape, Edgar Javier Amarillas, Jose Daniel Torres Arroyo, Jose Francisco Torres Sanchez, Carlos Jacobo Quezada Mendoza.	SISTEMA	\N	2026-11-11 11:04:16.289408	f	{}
121	50	50	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	⏰ Recordatorio de Llamado: Faltan aproximadamente 133 minutos para la cita (09:00 hrs).\n📍 Locación: Instalaciones de IEES.\n🚐 Chofer / Traslado: No asignado.\nEquipo técnico: favor de reportar estatus de salida o llegada a través de este canal.	SISTEMA	\N	2026-11-12 06:46:50.339578	f	{}
129	53	53	107	SISTEMA VPRO	AUDITORÍA	🔒 El chat operativo de esta OP ha sido cerrado y sellado oficialmente por el Productor Martin Eduardo Sanchez Estrada. La bitácora ha sido integrada al expediente histórico.	SISTEMA	\N	2026-11-17 16:13:03.44208	f	{}
130	57	57	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚀 Canal operativo iniciado para la OP-57: PREMIO ESTATAL DE DEPORTE 2026.\n📅 Fecha: 2026-11-19 | ⏰ Llamado: 09:00 hrs | 📍 Locación: Polideportivo Ma. del Rosario Espinoza.\nTodo reporte técnico, avisos de traslado y evidencias se registrarán en esta bitácora.	SISTEMA	\N	2026-11-19 11:38:00.723965	f	{}
120	54	177	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚀 Canal operativo iniciado para la OP-54: Asambleas informativas.\n📅 Fecha: 2026-11-12 | ⏰ Llamado: 16:30 hrs | 📍 Locación: FRACC. Paraíso, Mapilo 0123. Ref: Parque paraíso.\nTodo reporte técnico, avisos de traslado y evidencias se registrarán en esta bitácora.	SISTEMA	\N	2026-11-11 17:50:06.787146	f	{}
126	54	177	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	⏰ Recordatorio de Llamado: Faltan aproximadamente 133 minutos para la cita (16:30 hrs).\n📍 Locación: FRACC. Paraíso, Mapilo 0123. Ref: Parque paraíso.\n🚐 Chofer / Traslado: No asignado.\nEquipo técnico: favor de reportar estatus de salida o llegada a través de este canal.	SISTEMA	\N	2026-11-12 14:17:06.610436	f	{}
127	56	178	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	⏰ Recordatorio de Llamado: Faltan aproximadamente 123 minutos para la cita (08:00 hrs).\n📍 Locación: Arena de Badiraguato.\n🚐 Chofer / Traslado: Manuel Antonio Madrid Zazueta.\nEquipo técnico: favor de reportar estatus de salida o llegada a través de este canal.	SISTEMA	\N	2026-11-13 05:56:30.425569	f	{}
124	56	178	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚀 Canal operativo iniciado para la OP-56: TORNEO DE LIGA DE BALONCESTO DEL PACIFICO 2026 ASCENSO TEBACAS.\n📅 Fecha: 2026-11-13 | ⏰ Llamado: 08:00 hrs | 📍 Locación: Arena de Badiraguato.\nTodo reporte técnico, avisos de traslado y evidencias se registrarán en esta bitácora.	SISTEMA	\N	2026-11-12 12:30:49.860882	f	{}
131	58	179	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚀 Canal operativo iniciado para la OP-58: SESION EXTRAORD. VIRTUAL EN ESTUDIO TV.\n📅 Fecha: 2026-12-03 | ⏰ Llamado: 09:00 hrs | 📍 Locación: ESTUDIO TV VPRO.\nTodo reporte técnico, avisos de traslado y evidencias se registrarán en esta bitácora.	SISTEMA	\N	2026-11-20 11:58:45.248702	f	{}
133	173	180	BOT	🤖 SISTEMA VPRO	ALERTA OPERATIVA	🚀 Canal operativo iniciado para la OP-180: Rueda de prensa Harfuch.\n📅 Fecha: 2026-11-23 | ⏰ Llamado: 09:00 hrs | 📍 Locación: Hangar aéreo #10.\nTodo reporte técnico, avisos de traslado y evidencias se registrarán en esta bitácora.	SISTEMA	\N	2026-11-23 11:10:34.737683	f	{}
\.


--
-- Data for Name: checkouts_detalle; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.checkouts_detalle (id_detalle, id_maestro, codigo_equipo, cantidad, observaciones, incidencias, cotejado, notas_regreso) FROM stdin;
5046	130		1		Sin incidencias	f	
5199	135	xxxx	5		Sin incidencias	t	
3705	84	INV_ALT_1190081	1		Sin incidencias	f	
3706	84	INV_ALT_1190080	1		Sin incidencias	f	
3707	84	INV_ALT_1190049	2		Sin incidencias	f	
3708	84	INV_VPRO_ALT_00045	3		Sin incidencias	f	
3709	84	INV_VPRO_ALT_00097	4		Sin incidencias	f	
3710	84	INV_ALT_1190083	1		Sin incidencias	f	
3711	84	INV_ALT_1190084	1		Sin incidencias	f	
3673	84	INV_VPRO_ALT_00098	4		Sin incidencias	f	
3674	84	INV_VPRO_ALT_00100	1		Sin incidencias	f	
3675	84	INV_ALT_1190029	6		Sin incidencias	f	
3676	84	INV_ALT_1190006	1		Sin incidencias	f	
3677	84	INV_ALT_1190007	1		Sin incidencias	f	
3678	84	INV_ALT_1190050	12		Sin incidencias	f	
3679	84	INV_ALT_1190051	5		Sin incidencias	f	
3680	84	INV_ALT_1190052	2		Sin incidencias	f	
3681	84	INV_ALT_2020036	2		Sin incidencias	f	
3682	84	INV_VPRO_ALT_00153	1		Sin incidencias	f	
3683	84	INV_ALT_1190072	1		Sin incidencias	f	
3684	84	INV_ALT_1190073	1		Sin incidencias	f	
3685	84	INV_ALT_1090044	6		Sin incidencias	f	
3686	84	INV_ALT_1190074	4		Sin incidencias	f	
3687	84	INV_ALT_1190075	3		Sin incidencias	f	
3688	84	INV_ALT_1190076	3		Sin incidencias	f	
3689	84	INV_ALT_1190077	1		Sin incidencias	f	
3690	84	INV_ALT_1190079	2		Sin incidencias	f	
3691	84	INV_ALT_1190037	1		Sin incidencias	f	
3692	84	INV_ALT_1190082	2		Sin incidencias	f	
3693	84	INV_ALT_1190038	1		Sin incidencias	f	
3694	84	INV_ALT_1190039	2		Sin incidencias	f	
3695	84	INV_ALT_1190034	1		Sin incidencias	f	
3696	84	INV_VPRO_ALT_00151	1		Sin incidencias	f	
3697	84	INV_ALT_1190040	4		Sin incidencias	f	
3698	84	INV_ALT_1190042	4		Sin incidencias	f	
3699	84	INV_ALT_1190044	1		Sin incidencias	f	
3700	84	INV_VPRO_ALT_00202	6		Sin incidencias	f	
3701	84	INV_ALT_1190045	3		Sin incidencias	f	
1068	15	VPRO_ALT_26591	2		Sin incidencias	t	
1069	15	VPRO_ALT_26607	1		Sin incidencias	t	
1070	15	VPRO_ALT_26673	1		Sin incidencias	t	
1071	15	VPRO_ALT_26703	2		Sin incidencias	t	
1072	15	INV_ALT_1090014	1	[CUST_EQ:Transmisor de audio SONY VPNAUD009] None	Sin incidencias	t	
3702	84	INV_ALT_1190046	2		Sin incidencias	f	
3703	84	INV_ALT_1190047	5		Sin incidencias	f	
3704	84	INV_ALT_1190048	3		Sin incidencias	f	
1073	15	INV_ALT_1090015	3	[CUST_EQ:Receptor de audio SONY VPNAUD008] None	Sin incidencias	t	
1	1	INV_VPRO_ALT_00013	1		Sin incidencias	t	
2	1	INV_VPRO_ALT_00016	1		Sin incidencias	t	Estaba muy sucio y con lodo
3	1	INV_VPRO_ALT_00017	1		Sin incidencias	t	Estaba muy sucio y con lodo
4	1	INV_VPRO_ALT_00018	1		Sin incidencias	t	Estaba muy sucio y con lodo
5	1	INV_VPRO_ALT_00019	1		Sin incidencias	t	Estaba muy sucio y con lodo la tapa solamente
6	1	INV_VPRO_ALT_00021	1		Sin incidencias	t	
7	1	INV_VPRO_ALT_00022	1		Sin incidencias	t	
8	1	INV_VPRO_ALT_00023	1		Sin incidencias	t	Estaba muy sucios y con lodo
9	1	INV_VPRO_ALT_00024	1		Sin incidencias	t	
10	1	INV_VPRO_ALT_00025	1		Sin incidencias	t	Estaba muy sucio
11	1	INV_VPRO_ALT_00092	1		Sin incidencias	t	
12	1	Inv_alt_2010001	1		Sin incidencias	t	
655	2	INV_VPRO_ALT_00015	1		Sin incidencias	f	
656	2	INV_VPRO_ALT_00023	8		Sin incidencias	f	
657	2	INV_VPRO_ALT_00024	1		Sin incidencias	f	
658	2	INV_VPRO_ALT_00181	1		Sin incidencias	f	
659	2	INV_VPRO_ALT_00252	1		Sin incidencias	f	
660	2	INV_VPRO_ALT_00018	1		Sin incidencias	f	
661	2	INV_VPRO_ALT_00017	1		Sin incidencias	f	
662	2	INV_ALT_2010002	3		Sin incidencias	f	
663	2	INV_VPRO_ALT_00166	1		Sin incidencias	f	
664	2	INV_ALT_2010003	2		Sin incidencias	f	
665	2	INV_VPRO_ALT_00168	1		Sin incidencias	f	
666	2	INV_ALT_2010004	1		Sin incidencias	f	
1855	33	INV_VPRO_ALT_00181	1		Sin incidencias	f	
1148	11	INV_ALT_2020014	1		Sin incidencias	f	
1186	16	Inv_alt_1050007	1		Sin incidencias	t	
1030	14	INV_VPRO_ALT_00173	6		Sin incidencias	t	
1031	14	Inv_alt_1040004	4		Sin incidencias	t	
1032	14	INV_VPRO_ALT_00153	1		Sin incidencias	t	
1033	14	INV_VPRO_ALT_00063	3		Sin incidencias	t	
1034	14	INV_VPRO_ALT_00216	1		Sin incidencias	t	
5200	135	xxxxx	6		Sin incidencias	t	
5201	135	INV_VPRO_ALT_00023	7		Sin incidencias	t	
5202	135	xxxxxx	2		Sin incidencias	t	
5198	135	INV_VPRO_ALT_00053	4		Sin incidencias	t	
5414	133	INV_ALT_2020015	1		Sin incidencias	f	
5415	133	INV_ALT_2020019	4		Sin incidencias	f	
5416	133	INV_ALT_2020012	4		Sin incidencias	f	
5417	133	INV_ALT_2020033	1		Sin incidencias	f	
5418	133	INV_VPRO_ALT_00149	2		Sin incidencias	f	
5419	133	INV_ALT_2010003	4		Sin incidencias	f	
5420	133	Inv_alt_2020003	1		Sin incidencias	f	
1149	6	VPRO_ALT_26448	20		Sin incidencias	t	
1035	14	INV_VPRO_ALT_00254	5		Sin incidencias	t	
1036	14	INV_VPRO_ALT_00227	2		Sin incidencias	t	
1063	15	VPRO_ALT_26448	20		Sin incidencias	t	
1064	15	VPRO_ALT_26466	3		Sin incidencias	t	
1065	15	VPRO_ALT_26493	1		Sin incidencias	t	
1066	15	VPRO_ALT_26522	2		Sin incidencias	t	
800	10	INV_VPRO_ALT_00015	1		Sin incidencias	t	
801	10	INV_VPRO_ALT_00023	8		Sin incidencias	t	
802	10	INV_VPRO_ALT_00024	1		Sin incidencias	t	
803	10	INV_VPRO_ALT_00181	1		Sin incidencias	t	
804	10	INV_VPRO_ALT_00252	1		Sin incidencias	t	
805	10	INV_VPRO_ALT_00166	1		Sin incidencias	t	
1185	16	INV_VPRO_ALT_00166	1		Sin incidencias	t	
1067	15	VPRO_ALT_26558	3	Uno de los adaptadores no lleva AC	Sin incidencias	t	
949	5	INV_VPRO_ALT_00153	2		Sin incidencias	t	
950	5	INV_VPRO_ALT_00060	2		Sin incidencias	t	
951	5	INV_VPRO_ALT_00061	2		Sin incidencias	t	
952	5	INV_VPRO_ALT_00174	14		Sin incidencias	t	
953	5	INV_VPRO_ALT_00210	11		Sin incidencias	t	
954	5	INV_VPRO_ALT_00042	2		Sin incidencias	t	
955	5	INV_VPRO_ALT_00084	3		Sin incidencias	t	
956	5	VPRO_ALT_16514	11		Sin incidencias	t	
957	5	INV_VPRO_ALT_00081	2		Sin incidencias	t	
958	5	INV_VPRO_ALT_00055	2		Sin incidencias	t	
959	5	INV_VPRO_ALT_00085	2		Sin incidencias	t	
960	5	VPRO_ALT_17765	2		Sin incidencias	t	
961	5	INV_VPRO_ALT_00230	1		Sin incidencias	t	
962	5	INV_VPRO_ALT_00161	1		Sin incidencias	t	
963	5	INV_VPRO_ALT_00177	1		Sin incidencias	t	
964	5	INV_ALT_1190002	1		Sin incidencias	t	
965	5	INV_VPRO_ALT_00069	2		Sin incidencias	t	
966	5	INV_VPRO_ALT_00075	1		Sin incidencias	t	
1856	33	INV_ALT_2020021	1		Sin incidencias	f	
1857	33	INV_ALT_2010006	1		Sin incidencias	f	
1858	33	INV_VPRO_ALT_00093	1		Sin incidencias	f	
1859	33	INV_ALT_2020003	1		Sin incidencias	f	
1860	33	INV_VPRO_ALT_00139	3		Sin incidencias	f	
1861	33	INV_VPRO_ALT_00021	1		Sin incidencias	f	
1862	33	INV_ALT_2010004	1		Sin incidencias	f	
1863	33	INV_ALT_2010007	1		Sin incidencias	f	
1864	33	INV_ALT_2010008	1		Sin incidencias	f	
1865	33	INV_VPRO_ALT_00024	1		Sin incidencias	f	
1866	33	INV_VPRO_ALT_00254	8		Sin incidencias	f	
1190	18	VPRO_ALT_26361	2		Sin incidencias	t	
1191	18	VPRO_ALT_26379	1		Sin incidencias	t	
1192	18	VPRO_ALT_26418	2		Sin incidencias	t	
1193	18	VPRO_ALT_26433	1		Sin incidencias	t	
1194	18	VPRO_ALT_26448	4		Sin incidencias	t	
1195	18	VPRO_ALT_26466	2		Sin incidencias	t	
1196	18	VPRO_ALT_26493	1		Sin incidencias	t	
1197	18	VPRO_ALT_26522	1		Sin incidencias	t	
1198	18	VPRO_ALT_26591	2		Sin incidencias	t	
1199	18	VPRO_ALT_26607	1		Sin incidencias	t	
1200	18	VPRO_ALT_26673	1		Sin incidencias	t	
1201	18	VPRO_ALT_11376	1		Sin incidencias	t	
1085	15	INV_VPRO_ALT_00253	1		Sin incidencias	t	
1086	15	INV_VPRO_ALT_00255	1		Sin incidencias	t	
1087	15	INV_ALT_1090021	1		Sin incidencias	t	
670	7	INV_VPRO_ALT_00181	1		Sin incidencias	t	Por doble evento se quedo en la locación
671	7	INV_VPRO_ALT_00252	1		Sin incidencias	t	Por doble evento se quedo en la locación
672	7	INV_VPRO_ALT_00018	1		Sin incidencias	t	
673	7	INV_VPRO_ALT_00017	1		Sin incidencias	t	
674	7	INV_ALT_2010002	3		Sin incidencias	t	
675	7	INV_VPRO_ALT_00166	1		Sin incidencias	t	
676	7	Inv_alt_2010003	2		Sin incidencias	t	
677	7	INV_VPRO_ALT_00168	1		Sin incidencias	t	
678	7	Inv_alt_2010004	1		Sin incidencias	t	
925	3	INV_VPRO_ALT_00103	3		Sin incidencias	t	
926	3	INV_VPRO_ALT_00104	2		Sin incidencias	t	
927	3	INV_ALT_1190001	3		Sin incidencias	t	
928	3	INV_ALT_1190002	2		Sin incidencias	t	
929	3	INV_ALT_1190003	1		Sin incidencias	t	
930	3	INV_ALT_1190004	1		Sin incidencias	t	
931	3	INV_ALT_1190005	1		Sin incidencias	t	
932	3	INV_ALT_1190006	1		Sin incidencias	t	
933	3	INV_ALT_1190007	1		Sin incidencias	t	
934	3	INV_ALT_1190008	2		Sin incidencias	t	
935	3	INV_ALT_1190009	3		Sin incidencias	t	
936	3	INV_ALT_1190010	4		Sin incidencias	t	
937	3	INV_ALT_1190011	1		Sin incidencias	t	
938	3	INV_ALT_1190012	1		Sin incidencias	t	
939	3	INV_ALT_1190013	1		Sin incidencias	t	
1188	17	INV_ALT_1130001	1		Sin incidencias	t	
1189	17	INV_ALT_1130002	1		Sin incidencias	t	
1074	15	INV_ALT_1090016	1	[CUST_EQ:Microfono de solapa SONY VPNAUD009] None	Sin incidencias	t	
667	7	INV_VPRO_ALT_00015	1		Sin incidencias	t	Por doble evento se quedo en la locación
668	7	INV_VPRO_ALT_00023	8		Sin incidencias	t	2 pisacables se quedaron en locacion
1187	17	INV_VPRO_ALT_00256	2		Sin incidencias	t	
1075	15	INV_ALT_1090017	2	[CUST_EQ:Diademas de comunicación BEHRINGER VPNAUD065] None	Sin incidencias	t	
1076	15	INV_ALT_1090018	1	[CUST_EQ:Diadema de comunicación SONY VPNAUD019] None	Sin incidencias	t	
1077	15	VPRO_ALT_26379	1		Sin incidencias	t	
1078	15	VPRO_ALT_26418	2		Sin incidencias	t	
1079	15	VPRO_ALT_26433	2		Sin incidencias	t	
1080	15	VPRO_ALT_26256	1	Esta caja contiene el CPU que se utiliza para los eventos	Sin incidencias	t	
1081	15	VPRO_ALT_26302	1		Sin incidencias	t	
3372	66	INV_ALT_1130012	1		Sin incidencias	t	
669	7	INV_VPRO_ALT_00024	1		Sin incidencias	t	Por doble evento se quedo en la locación
1082	15	VPRO_ALT_26326	1		Sin incidencias	t	
1083	15	VPRO_ALT_26346	4		Sin incidencias	t	
967	8	INV_VPRO_ALT_00052	4		Sin incidencias	t	
968	8	INV_VPRO_ALT_00173	3		Sin incidencias	t	
789	9	INV_VPRO_ALT_00023	6		Sin incidencias	t	
790	9	INV_VPRO_ALT_00181	1		Sin incidencias	t	
791	9	INV_VPRO_ALT_00018	1		Sin incidencias	t	
792	9	INV_VPRO_ALT_00017	1		Sin incidencias	t	
793	9	INV_ALT_2010002	3		Sin incidencias	t	
794	9	INV_ALT_2010003	2		Sin incidencias	t	
795	9	INV_VPRO_ALT_00168	1		Sin incidencias	t	
796	9	INV_ALT_2010004	1		Sin incidencias	t	
969	8	Inv_alt_1130017	1		Sin incidencias	t	
970	8	Inv_alt_1130018	1		Sin incidencias	t	
971	8	Inv_alt_1130019	1		Sin incidencias	t	
972	8	Inv_alt_1130020	3		Sin incidencias	t	
973	8	Inv_alt_1130021	1		Sin incidencias	t	
974	8	Inv_alt_1130022	1		Sin incidencias	t	
975	8	Inv_alt_1130023	2		Sin incidencias	t	
976	8	VPRO_ALT_26466	5		Sin incidencias	t	
977	8	INV_ALT_1130005	1		Sin incidencias	t	
978	8	Inv_alt_1130024	2		Sin incidencias	t	
797	9	INV_VPRO_ALT_00013	1		Sin incidencias	t	
798	9	INV_ALT_2010005	1		Sin incidencias	t	
799	9	INV_VPRO_ALT_00243	1		Sin incidencias	t	
979	8	Inv_alt_1130025	4		Sin incidencias	t	
1084	15	VPRO_ALT_26361	1		Sin incidencias	t	
1088	15	INV_ALT_1090023	1		Sin incidencias	t	
2375	40	INV_VPRO_ALT_00021	1		Sin incidencias	f	
2221	41	INV_ALT_1090061	1		Sin incidencias	t	
2222	41	INV_ALT_1090062	1		Sin incidencias	t	
2208	41	INV_ALT_1090050	1		Sin incidencias	t	
2209	41	INV_ALT_1190052	2		Sin incidencias	t	
1722	29	INV_ALT_1130017	1		Sin incidencias	t	
1723	29	INV_ALT_1130018	1		Sin incidencias	t	
2210	41	INV_ALT_1090051	6		Sin incidencias	t	
1304	19	INV_VPRO_ALT_00189	1		Sin incidencias	t	
1305	19	INV_ALT_2020015	1		Sin incidencias	t	
1306	19	INV_ALT_2020019	4		Sin incidencias	t	
1307	19	INV_VPRO_ALT_00149	2		Sin incidencias	t	
1308	19	INV_ALT_2020012	2		Sin incidencias	t	
1309	19	INV_ALT_2020031	1		Sin incidencias	t	
1310	19	INV_VPRO_ALT_00016	1		Sin incidencias	t	
1311	19	INV_ALT_2020011	2		Sin incidencias	t	
1312	19	INV_ALT_2020010	1		Sin incidencias	t	
1313	19	INV_ALT_2020032	1		Sin incidencias	t	
1314	19	INV_ALT_2020033	1		Sin incidencias	t	
1315	19	INV_ALT_2020034	1		Sin incidencias	t	
1724	23	INV_ALT_2020009	1		Sin incidencias	f	
1725	23	INV_ALT_2020026	1		Sin incidencias	f	
2376	40	INV_ALT_2010004	1		Sin incidencias	f	
2377	40	INV_ALT_2020009	1		Sin incidencias	f	
1726	23	INV_ALT_2020027	1		Sin incidencias	f	
1727	23	INV_ALT_2020029	5		Sin incidencias	f	
1728	23	INV_ALT_2020030	5		Sin incidencias	f	
1291	19	INV_ALT_2020009	1		Sin incidencias	t	
2378	40	INV_ALT_2010009	1		Sin incidencias	f	
2379	40	INV_VPRO_ALT_00017	1		Sin incidencias	f	
1150	6	VPRO_ALT_26466	3		Sin incidencias	t	
1151	6	VPRO_ALT_26493	1		Sin incidencias	t	
1152	6	VPRO_ALT_26522	2		Sin incidencias	t	
1153	6	VPRO_ALT_26558	3	Uno de los adaptadores no lleva AC	Sin incidencias	t	
2380	40	INV_ALT_2010008	1		Sin incidencias	f	
1089	15	INV_ALT_1090027	1		Sin incidencias	t	
1090	15	INV_VPRO_ALT_00231	10		Sin incidencias	t	
1091	15	INV_ALT_1090028	1		Sin incidencias	t	
1092	15	INV_ALT_1090030	1		Sin incidencias	t	
1093	15	Inv_alt_1090031	1	[CUST_EQ:Laptop g7]	Sin incidencias	t	
1094	15	INV_VPRO_ALT_26708	1		Sin incidencias	t	
1154	6	VPRO_ALT_26591	2		Sin incidencias	t	
1155	6	VPRO_ALT_26607	1		Sin incidencias	t	
1156	6	VPRO_ALT_26673	1		Sin incidencias	t	
2381	40	INV_ALT_2010010	1		Sin incidencias	f	
2382	40	INV_VPRO_ALT_00013	1		Sin incidencias	f	
2383	40	INV_ALT_2020021	1	Maleta dañada, ya se reportó./Via O Equio con daño	Sin incidencias	f	
1157	6	VPRO_ALT_26703	2		Sin incidencias	t	
940	3	INV_ALT_1190014	1		Sin incidencias	t	
941	3	INV_ALT_1190015	1		Sin incidencias	t	
942	3	INV_ALT_1190016	10		Sin incidencias	t	
943	3	INV_ALT_1190017	6		Sin incidencias	t	
944	3	INV_ALT_1190018	2		Sin incidencias	t	
945	3	INV_ALT_1190019	2		Sin incidencias	t	
946	3	INV_ALT_1190020	1		Sin incidencias	t	
947	3	INV_ALT_1190021	2		Sin incidencias	t	
917	3	INV_VPRO_ALT_00045	3		Sin incidencias	t	
918	3	INV_VPRO_ALT_00001	3		Sin incidencias	t	
919	3	INV_VPRO_ALT_00097	10		Sin incidencias	t	
2293	39	INV_ALT_1040007	7		Sin incidencias	t	
2294	39	INV_ALT_1040008	15		Sin incidencias	t	
1729	23	INV_ALT_2020024	1		Sin incidencias	f	
1730	23	INV_ALT_2020023	1		Sin incidencias	f	
1731	23	INV_ALT_2020018	1		Sin incidencias	f	
1732	23	INV_ALT_2020025	1		Sin incidencias	f	
1733	23	INV_ALT_2020017	1		Sin incidencias	f	
1734	23	INV_VPRO_ALT_00245	1		Sin incidencias	f	
1735	23	INV_VPRO_ALT_00246	1		Sin incidencias	f	
1736	23	INV_VPRO_ALT_00189	1		Sin incidencias	f	
1737	23	INV_ALT_2020015	1		Sin incidencias	f	
1738	23	INV_ALT_2020019	4		Sin incidencias	f	
920	3	INV_VPRO_ALT_00098	4		Sin incidencias	t	
921	3	INV_VPRO_ALT_00099	8		Sin incidencias	t	
922	3	INV_VPRO_ALT_00100	1		Sin incidencias	t	
923	3	INV_VPRO_ALT_00101	2		Sin incidencias	t	
924	3	INV_VPRO_ALT_00102	1		Sin incidencias	t	
1158	6	INV_ALT_1090014	1		Sin incidencias	t	
1159	6	INV_ALT_1090015	3		Sin incidencias	t	
1160	6	INV_ALT_1090032	1		Sin incidencias	t	
1161	6	INV_ALT_1090016	1		Sin incidencias	t	
1162	6	INV_ALT_1090017	2		Sin incidencias	t	
1163	6	INV_ALT_1090018	1		Sin incidencias	t	
1164	6	VPRO_ALT_26379	1		Sin incidencias	t	
1165	6	VPRO_ALT_26418	2		Sin incidencias	t	
1166	6	VPRO_ALT_26433	2		Sin incidencias	t	
1167	6	VPRO_ALT_26256	1	Esta caja contiene el CPU que se utiliza para los eventos	Sin incidencias	t	
1168	6	VPRO_ALT_26302	1		Sin incidencias	t	
1169	6	VPRO_ALT_26326	1		Sin incidencias	t	
1170	6	VPRO_ALT_26346	4		Sin incidencias	t	
1171	6	VPRO_ALT_26361	2		Sin incidencias	t	
1202	18	INV_ALT_1090033	1		Sin incidencias	t	
831	4	INV_ALT_2020011	2		Sin incidencias	t	
832	4	INV_ALT_2020012	2		Sin incidencias	t	
833	4	INV_ALT_2020013	1		Sin incidencias	t	
834	4	INV_ALT_2020014	1		Sin incidencias	t	
835	4	INV_ALT_2020015	1		Sin incidencias	t	
836	4	INV_ALT_2020016	1		Sin incidencias	t	
837	4	INV_VPRO_ALT_00026	1		Sin incidencias	t	
838	4	INV_ALT_2020017	1		Sin incidencias	t	
826	4	INV_ALT_2020009	1		Sin incidencias	t	
827	4	INV_ALT_2020010	1		Sin incidencias	t	
828	4	INV_VPRO_ALT_00245	1		Sin incidencias	t	
829	4	INV_VPRO_ALT_00246	1		Sin incidencias	t	
830	4	INV_VPRO_ALT_00189	1		Sin incidencias	t	
839	4	INV_VPRO_ALT_00016	1		Sin incidencias	t	
840	4	INV_ALT_2020018	1		Sin incidencias	t	
841	4	INV_ALT_2020019	4		Sin incidencias	t	
842	4	INV_ALT_2020021	1		Sin incidencias	t	
843	4	INV_ALT_2020022	1		Sin incidencias	t	
844	4	INV_ALT_2020023	1		Sin incidencias	t	
845	4	INV_ALT_2020024	1		Sin incidencias	t	
846	4	INV_ALT_2020025	1		Sin incidencias	t	
847	4	INV_ALT_2020026	1		Sin incidencias	t	
848	4	INV_ALT_2020027	1		Sin incidencias	t	
1739	23	INV_VPRO_ALT_00149	2		Sin incidencias	f	
1740	23	INV_ALT_2020012	2		Sin incidencias	f	
1741	23	INV_ALT_2020031	1		Sin incidencias	f	
1742	23	INV_VPRO_ALT_00016	1		Sin incidencias	f	
1743	23	INV_ALT_2020011	2		Sin incidencias	f	
1744	23	INV_ALT_2020010	1		Sin incidencias	f	
948	3	INV_ALT_1190022	1		Sin incidencias	t	
849	4	INV_ALT_2020028	1		Sin incidencias	t	
1172	6	INV_VPRO_ALT_00253	1		Sin incidencias	t	
1173	6	INV_VPRO_ALT_00255	1		Sin incidencias	t	
1174	6	INV_ALT_1090021	1		Sin incidencias	t	
1175	6	INV_ALT_1090023	1		Sin incidencias	t	
1176	6	INV_ALT_1090027	1		Sin incidencias	t	
1177	6	INV_VPRO_ALT_00231	10		Sin incidencias	t	
1178	6	INV_ALT_1090028	1		Sin incidencias	t	
1179	6	INV_ALT_1090030	1		Sin incidencias	t	
1180	6	INV_ALT_1090031	1		Sin incidencias	t	
1181	6	INV_VPRO_ALT_26708	1		Sin incidencias	t	
1182	6	INV_ALT_1190010	2		Sin incidencias	t	
1183	6	INV_ALT_1090032	1		Sin incidencias	t	
1121	13	INV_VPRO_ALT_00045	3		Sin incidencias	t	
1122	13	INV_VPRO_ALT_00001	3		Sin incidencias	t	
1123	13	INV_VPRO_ALT_00097	6		Sin incidencias	t	
1124	13	INV_VPRO_ALT_00098	4		Sin incidencias	t	
1125	13	INV_VPRO_ALT_00099	6		Sin incidencias	t	
1126	13	INV_VPRO_ALT_00100	1		Sin incidencias	t	
1127	13	INV_VPRO_ALT_00101	1		Sin incidencias	t	
1128	13	INV_VPRO_ALT_00102	1		Sin incidencias	t	
1129	13	INV_VPRO_ALT_00103	3		Sin incidencias	t	
1130	13	INV_VPRO_ALT_00104	2		Sin incidencias	t	
1390	22	INV_VPRO_ALT_00023	8		Sin incidencias	t	
1391	22	INV_VPRO_ALT_00024	1		Sin incidencias	t	
1392	22	INV_VPRO_ALT_00181	1		Sin incidencias	t	
1393	22	INV_VPRO_ALT_00021	1		Sin incidencias	t	
1394	22	INV_ALT_2020015	1		Sin incidencias	t	
1395	22	INV_VPRO_ALT_00093	1		Sin incidencias	t	
1396	22	INV_ALT_2020003	1		Sin incidencias	t	
1397	22	INV_ALT_2020021	1		Sin incidencias	t	
1398	22	INV_ALT_2020022	1		Sin incidencias	t	
1399	22	INV_ALT_2010006	1		Sin incidencias	t	
1745	23	INV_ALT_2020032	1		Sin incidencias	f	
1131	13	INV_ALT_1190001	3		Sin incidencias	t	
1132	13	INV_ALT_1190002	1		Sin incidencias	t	
1133	13	INV_ALT_1190005	1		Sin incidencias	t	
1134	13	INV_ALT_1190006	1		Sin incidencias	t	
1135	13	INV_ALT_1190007	1		Sin incidencias	t	
1136	13	INV_ALT_1190008	2		Sin incidencias	t	
1137	13	INV_ALT_1190011	1		Sin incidencias	t	
1138	13	INV_ALT_1190012	1		Sin incidencias	t	
1139	13	INV_ALT_1190016	10		Sin incidencias	t	
1140	13	INV_ALT_1190017	6		Sin incidencias	t	
1141	13	INV_ALT_1190018	2		Sin incidencias	t	
1142	13	INV_ALT_1190019	2		Sin incidencias	t	
1143	13	INV_ALT_1190020	1		Sin incidencias	t	
1144	13	INV_ALT_1190021	2		Sin incidencias	t	
1145	13	INV_ALT_1190022	1		Sin incidencias	t	
1146	13	INV_ALT_1190023	2		Sin incidencias	t	
1746	23	INV_ALT_2020033	1		Sin incidencias	f	
1747	23	INV_ALT_2020034	2		Sin incidencias	f	
1748	23	INV_VPRO_ALT_00026	1		Sin incidencias	f	
1749	23	INV_ALT_2020035	1		Sin incidencias	f	
1750	23	INV_ALT_2020013	1		Sin incidencias	f	
1333	20	INV_ALT_1190033	1		Sin incidencias	t	
1334	20	INV_ALT_1190034	1		Sin incidencias	t	
1335	20	INV_VPRO_ALT_00045	1		Sin incidencias	t	
1336	20	INV_VPRO_ALT_00097	2		Sin incidencias	t	
1337	20	INV_ALT_1190024	1		Sin incidencias	t	
1338	20	INV_ALT_1190025	1		Sin incidencias	t	
1339	20	INV_ALT_1190026	1		Sin incidencias	t	
1340	20	INV_ALT_1190027	1		Sin incidencias	t	
1341	20	INV_ALT_1190028	1		Sin incidencias	t	
1342	20	INV_ALT_1190029	2		Sin incidencias	t	
1343	20	INV_ALT_1190030	2		Sin incidencias	t	
1344	20	INV_ALT_1190031	2		Sin incidencias	t	
1345	20	INV_ALT_1190005	1		Sin incidencias	t	
1346	20	INV_ALT_1190032	1		Sin incidencias	t	
1751	23	INV_ALT_2020022	1		Sin incidencias	f	
1752	23	INV_VPRO_ALT_00092	1		Sin incidencias	f	
1753	23	INV_ALT_2020036	1		Sin incidencias	f	
1754	23	INV_ALT_2020037	1		Sin incidencias	f	
1347	20	INV_ALT_1190035	2		Sin incidencias	t	
1348	20	INV_ALT_1190036	2		Sin incidencias	t	
1292	19	INV_ALT_2020026	1		Sin incidencias	t	
1293	19	INV_ALT_2020027	1		Sin incidencias	t	
1294	19	INV_ALT_2020029	5		Sin incidencias	t	
1295	19	INV_ALT_2020030	5		Sin incidencias	t	
1296	19	INV_ALT_2020021	1		Sin incidencias	t	
1297	19	INV_ALT_2020024	1		Sin incidencias	t	
1298	19	INV_ALT_2020023	1		Sin incidencias	t	
1299	19	INV_ALT_2020018	1		Sin incidencias	t	
1300	19	INV_ALT_2020025	1		Sin incidencias	t	
1301	19	INV_ALT_2020017	1		Sin incidencias	t	
1302	19	INV_VPRO_ALT_00245	1		Sin incidencias	t	
1303	19	INV_VPRO_ALT_00246	1		Sin incidencias	t	
1771	28	INV_VPRO_ALT_00237	3		Sin incidencias	f	
1772	28	INV_ALT_1050007	2		Sin incidencias	f	
1773	28	INV_ALT_1040001	1		Sin incidencias	f	
1492	24	INV_VPRO_ALT_00023	8		Sin incidencias	t	
1493	24	INV_VPRO_ALT_00024	1		Sin incidencias	t	
1494	24	INV_VPRO_ALT_00181	1		Sin incidencias	t	
1495	24	INV_VPRO_ALT_00021	1		Sin incidencias	t	
1496	24	INV_ALT_2020015	1		Sin incidencias	t	
1497	24	INV_ALT_2020021	1		Sin incidencias	t	
1498	24	INV_ALT_2010006	1		Sin incidencias	t	
1499	24	INV_ALT_2010007	1		Sin incidencias	t	
1500	24	INV_VPRO_ALT_00018	1		Sin incidencias	t	
2352	38	INV_ALT_2020023	1		Sin incidencias	t	
2353	38	INV_ALT_2020018	1		Sin incidencias	t	
2354	38	INV_ALT_2020025	1		Sin incidencias	t	
2355	38	INV_ALT_2020017	1		Sin incidencias	t	
2356	38	INV_VPRO_ALT_00245	1		Sin incidencias	t	
2357	38	INV_VPRO_ALT_00246	1		Sin incidencias	t	
2358	38	INV_VPRO_ALT_00189	1		Sin incidencias	t	
2359	38	INV_ALT_2020015	1		Sin incidencias	t	
2360	38	INV_ALT_2020019	4		Sin incidencias	t	
2844	54	Inv_alt_1130019	1	[CUST_EQ:Computadora Estudio]	Sin incidencias	f	
2361	38	INV_VPRO_ALT_00149	2		Sin incidencias	t	
2362	38	INV_ALT_2020012	4		Sin incidencias	t	
2363	38	INV_ALT_2020031	1		Sin incidencias	t	
2364	38	INV_VPRO_ALT_00016	1		Sin incidencias	t	
2365	38	INV_ALT_2020011	2		Sin incidencias	t	
2301	39	INV_VPRO_ALT_00216	1		Sin incidencias	t	
2302	39	INV_VPRO_ALT_00023	19		Sin incidencias	t	
2303	39	INV_VPRO_ALT_00216	1		Sin incidencias	t	
2304	39	INV_ALT_1040012	1		Sin incidencias	t	
2305	39	INV_ALT_1040013	1		Sin incidencias	t	
2366	38	INV_ALT_2020010	1		Sin incidencias	t	
2367	38	INV_ALT_2020033	1		Sin incidencias	t	
2368	38	INV_ALT_2020034	3		Sin incidencias	t	
2369	38	INV_VPRO_ALT_00026	1		Sin incidencias	t	
2384	42	INV_ALT_1050008	3		Sin incidencias	f	
3628	85	INV_VPRO_ALT_26708	1		Sin incidencias	f	
3847	88	INV_ALT_2020022	1		Sin incidencias	f	
3848	88	INV_VPRO_ALT_00092	1		Sin incidencias	f	
3849	88	INV_ALT_2020040	1		Sin incidencias	f	
2211	41	INV_ALT_1090052	1		Sin incidencias	t	
2212	41	INV_ALT_1090053	1		Sin incidencias	t	
2213	41	INV_ALT_1090054	1		Sin incidencias	t	
2214	41	INV_ALT_1090055	1		Sin incidencias	t	
2215	41	INV_ALT_1090056	1		Sin incidencias	t	
2216	41	INV_ALT_1090057	1		Sin incidencias	t	
2217	41	INV_ALT_1090058	2		Sin incidencias	t	
2218	41	INV_ALT_1090059	3		Sin incidencias	t	
2219	41	INV_VPRO_ALT_00198	3		Sin incidencias	t	
2220	41	INV_ALT_1090060	5		Sin incidencias	t	
2385	42	INV_ALT_1090001	3		Sin incidencias	f	
2386	37	INV_ALT_1190007	1		Sin incidencias	f	
2387	37	INV_ALT_1190068	1		Sin incidencias	f	
2388	37	INV_ALT_1190069	4		Sin incidencias	f	
2389	37	INV_ALT_1190070	2		Sin incidencias	f	
2390	37	INV_ALT_1190071	2		Sin incidencias	f	
2391	37	INV_ALT_1190055	8		Sin incidencias	f	
2392	37	INV_ALT_1190056	9		Sin incidencias	f	
2393	37	INV_ALT_1190057	1		Sin incidencias	f	
2394	37	INV_ALT_1190058	8		Sin incidencias	f	
2395	37	INV_VPRO_ALT_00102	1		Sin incidencias	f	
2396	37	INV_ALT_1190059	4		Sin incidencias	f	
2397	37	INV_VPRO_ALT_00099	8		Sin incidencias	f	
2398	37	INV_ALT_1190053	7		Sin incidencias	f	
2399	37	INV_ALT_1190054	6		Sin incidencias	f	
2400	37	INV_VPRO_ALT_00098	5		Sin incidencias	f	
2401	37	INV_VPRO_ALT_00024	8		Sin incidencias	f	
2402	37	INV_ALT_1190060	2		Sin incidencias	f	
2403	37	INV_ALT_1190042	7		Sin incidencias	f	
2404	37	INV_VPRO_ALT_00205	3		Sin incidencias	f	
2405	37	INV_VPRO_ALT_00201	1		Sin incidencias	f	
2406	37	INV_VPRO_ALT_00227	2		Sin incidencias	f	
2407	37	INV_VPRO_ALT_00104	2		Sin incidencias	f	
2408	37	INV_ALT_1190061	5		Sin incidencias	f	
2409	37	INV_ALT_1190005	1		Sin incidencias	f	
2410	37	INV_ALT_1190062	11		Sin incidencias	f	
3850	88	INV_ALT_2020041	1		Sin incidencias	f	
1774	28	INV_VPRO_ALT_00001	3		Sin incidencias	f	
3851	88	INV_ALT_2020042	1		Sin incidencias	f	
2295	39	INV_ALT_1040009	1		Sin incidencias	t	
2296	39	INV_ALT_1190050	15		Sin incidencias	t	
2297	39	INV_VPRO_ALT_00071	2		Sin incidencias	t	
2298	39	INV_ALT_1040010	5		Sin incidencias	t	
2299	39	INV_ALT_1040011	1		Sin incidencias	t	
2300	39	INV_ALT_1130011	6		Sin incidencias	t	
1879	35	INV_ALT_2010008	1		Sin incidencias	f	
1880	35	INV_VPRO_ALT_00024	1		Sin incidencias	f	
1881	35	INV_VPRO_ALT_00254	8		Sin incidencias	f	
1882	35	INV_VPRO_ALT_00181	1		Sin incidencias	f	
1883	35	INV_ALT_2020021	1		Sin incidencias	f	
1884	35	INV_ALT_2010006	1		Sin incidencias	f	
1885	35	INV_VPRO_ALT_00093	1		Sin incidencias	f	
1886	35	INV_ALT_2020003	1		Sin incidencias	f	
1887	35	INV_VPRO_ALT_00139	3		Sin incidencias	f	
1888	35	INV_VPRO_ALT_00021	1		Sin incidencias	f	
1889	35	INV_ALT_2010004	1		Sin incidencias	f	
1890	35	INV_ALT_2010007	1		Sin incidencias	f	
2411	37	INV_ALT_1190063	2		Sin incidencias	f	
2412	37	INV_ALT_1190064	6		Sin incidencias	f	
2413	37	INV_ALT_1190065	1		Sin incidencias	f	
2414	37	INV_ALT_1190066	2		Sin incidencias	f	
2415	37	INV_ALT_1190067	1		Sin incidencias	f	
1350	21	INV_VPRO_ALT_00024	1		Sin incidencias	t	
1349	21	INV_VPRO_ALT_00023	8		Sin incidencias	t	
1351	21	INV_VPRO_ALT_00181	1		Sin incidencias	t	
1352	21	INV_VPRO_ALT_00013	1		Sin incidencias	t	
1353	21	INV_VPRO_ALT_00021	1		Sin incidencias	t	
1354	21	INV_ALT_2020015	1		Sin incidencias	t	
1355	21	INV_VPRO_ALT_00093	1		Sin incidencias	t	
1356	21	INV_ALT_2020003	1		Sin incidencias	t	
1357	21	INV_ALT_2020021	1		Sin incidencias	t	
1358	21	INV_ALT_2020022	1		Sin incidencias	t	
3382	72	INV_VPRO_ALT_00175	8		Sin incidencias	t	
3383	72	INV_VPRO_ALT_00150	1		Sin incidencias	t	
3384	72	INV_ALT_1050006	1		Sin incidencias	t	
3385	72	INV_VPRO_ALT_00065	2		Sin incidencias	t	
3386	72	INV_VPRO_ALT_00254	6		Sin incidencias	t	
3387	72	VPRO_ALT_16456	1		Sin incidencias	t	
3388	72	INV_ALT_1130011	2		Sin incidencias	t	
3389	72	INV_VPRO_ALT_00230	1		Sin incidencias	t	
3390	72	INV_VPRO_ALT_00231	4		Sin incidencias	t	
3852	88	INV_ALT_2020011	2		Sin incidencias	f	
1823	26	INV_VPRO_ALT_00012	1	⚠️ [LLEVA DAÑO REPORTADO]	Sin incidencias	f	
1799	32	INV_VPRO_ALT_00181	1		Sin incidencias	t	
1800	32	INV_ALT_2020021	1		Sin incidencias	t	
1801	32	INV_ALT_2010006	1		Sin incidencias	t	
1802	32	INV_VPRO_ALT_00093	1		Sin incidencias	t	
1803	32	INV_ALT_2020003	1		Sin incidencias	t	
1804	32	INV_VPRO_ALT_00139	3		Sin incidencias	t	
1805	32	INV_VPRO_ALT_00021	1		Sin incidencias	t	
1806	32	INV_ALT_2010004	1		Sin incidencias	t	
3853	88	INV_ALT_2020010	1		Sin incidencias	f	
1807	32	INV_ALT_2010007	1		Sin incidencias	t	
1808	32	INV_ALT_2010008	1		Sin incidencias	t	
1809	32	INV_VPRO_ALT_00024	1		Sin incidencias	t	
1810	32	INV_VPRO_ALT_00254	8		Sin incidencias	t	
1824	34	Inv_alt_1130019	1	[CUST_EQ:Computadora Estudio]	Sin incidencias	f	
1825	25	INV_VPRO_ALT_00045	3		Sin incidencias	f	
1826	25	INV_VPRO_ALT_00097	4		Sin incidencias	f	
1827	25	INV_VPRO_ALT_00098	3		Sin incidencias	f	
1828	25	INV_VPRO_ALT_00099	4		Sin incidencias	f	
1829	25	INV_VPRO_ALT_00100	1		Sin incidencias	f	
1830	25	INV_ALT_1190037	1		Sin incidencias	f	
1831	25	INV_ALT_1190038	1		Sin incidencias	f	
1832	25	INV_ALT_1190039	1		Sin incidencias	f	
1833	25	INV_ALT_1190034	1		Sin incidencias	f	
1834	25	INV_VPRO_ALT_00151	2		Sin incidencias	f	
1835	25	INV_ALT_1190024	1		Sin incidencias	f	
1836	25	INV_ALT_1190040	2		Sin incidencias	f	
1837	25	INV_ALT_1190041	1		Sin incidencias	f	
1838	25	INV_ALT_1190042	3		Sin incidencias	f	
1839	25	INV_ALT_1190043	1		Sin incidencias	f	
1840	25	INV_ALT_1190044	1		Sin incidencias	f	
1841	25	INV_VPRO_ALT_00202	1		Sin incidencias	f	
1842	25	INV_ALT_1190045	3		Sin incidencias	f	
1843	25	INV_ALT_1190046	2		Sin incidencias	f	
1844	25	INV_ALT_1190047	6		Sin incidencias	f	
1845	25	INV_ALT_1190048	3		Sin incidencias	f	
1846	25	INV_ALT_1190049	2		Sin incidencias	f	
1847	25	INV_ALT_1190029	3		Sin incidencias	f	
1848	25	INV_ALT_1190006	1		Sin incidencias	f	
1849	25	INV_ALT_1190007	1		Sin incidencias	f	
1850	25	INV_ALT_1190050	10		Sin incidencias	f	
1851	25	INV_ALT_1190051	4		Sin incidencias	f	
1852	25	INV_ALT_1190052	2		Sin incidencias	f	
1853	25	INV_ALT_2020036	1		Sin incidencias	f	
1854	25	INV_VPRO_ALT_00153	1		Sin incidencias	f	
2416	43	INV_ALT_1020001	1		Sin incidencias	f	
2417	43	INV_ALT_1020004	1		Sin incidencias	f	
2418	43	INV_ALT_1130001	1		Sin incidencias	f	
2419	43	INV_VPRO_ALT_00237	1		Sin incidencias	f	
2420	43	INV_ALT_1130002	1		Sin incidencias	f	
2421	43	INV_VPRO_ALT_00235	1		Sin incidencias	f	
2422	44	INV_ALT_1130017	1		Sin incidencias	f	
2423	44	INV_VPRO_ALT_00237	2		Sin incidencias	f	
2424	44	INV_ALT_1040001	1		Sin incidencias	f	
2425	44	INV_ALT_1130001	1		Sin incidencias	f	
2426	44	INV_VPRO_ALT_00024	1	⚠️ [LLEVA DAÑO REPORTADO]	Sin incidencias	f	
2427	44	INV_ALT_1130002	1		Sin incidencias	f	
2180	41	VPRO_ALT_26418	2		Sin incidencias	t	
2181	41	VPRO_ALT_26433	2		Sin incidencias	t	
2182	41	VPRO_ALT_26379	1		Sin incidencias	t	
2183	41	INV_ALT_1090034	1		Sin incidencias	t	
2184	41	INV_ALT_1090035	2		Sin incidencias	t	
2185	41	INV_VPRO_ALT_26708	1		Sin incidencias	t	
2186	41	INV_ALT_1090036	1		Sin incidencias	t	
2187	41	VPRO_ALT_26591	2		Sin incidencias	t	
2188	41	INV_ALT_1090037	1		Sin incidencias	t	
2189	41	INV_ALT_1090038	2		Sin incidencias	t	
2190	41	INV_ALT_1090039	4		Sin incidencias	t	
2191	41	INV_ALT_1090040	3		Sin incidencias	t	
2192	41	INV_ALT_1090041	1		Sin incidencias	t	
2193	41	INV_ALT_1090042	9		Sin incidencias	t	
2194	41	INV_ALT_1090026	3		Sin incidencias	t	
2195	41	INV_ALT_1090043	5		Sin incidencias	t	
2196	41	INV_ALT_1090044	8		Sin incidencias	t	
2197	41	INV_VPRO_ALT_00211	14		Sin incidencias	t	
2198	41	INV_ALT_1090045	1		Sin incidencias	t	
2199	41	INV_ALT_1090028	1		Sin incidencias	t	
2200	41	INV_ALT_1090046	5		Sin incidencias	t	
2201	41	INV_ALT_1090047	1		Sin incidencias	t	
2202	41	INV_ALT_1090048	1		Sin incidencias	t	
2203	41	INV_ALT_1130013	3		Sin incidencias	t	
2204	41	INV_ALT_1090049	1		Sin incidencias	t	
2205	41	INV_ALT_1090031	1		Sin incidencias	t	
2206	41	VPRO_ALT_26256	1		Sin incidencias	t	
2207	41	INV_ALT_1090027	1		Sin incidencias	t	
2370	38	INV_ALT_2020013	1		Sin incidencias	t	
2371	38	INV_VPRO_ALT_00092	1		Sin incidencias	t	
2372	38	INV_ALT_2020037	1		Sin incidencias	t	
2373	38	INV_ALT_2020022	1		Sin incidencias	t	
2374	38	INV_ALT_2020039	1		Sin incidencias	t	
3854	88	INV_ALT_2020032	1		Sin incidencias	f	
3514	52	INV_ALT_1190048	3		Sin incidencias	t	
3855	88	INV_ALT_2020033	1		Sin incidencias	f	
3856	88	INV_ALT_2020034	2		Sin incidencias	f	
3857	88	INV_VPRO_ALT_00026	1		Sin incidencias	f	
2862	53	INV_ALT_2020031	1		Sin incidencias	t	
3858	88	INV_ALT_2020035	1		Sin incidencias	f	
3859	88	INV_ALT_2020013	1		Sin incidencias	f	
3860	88	INV_ALT_2020021	1		Sin incidencias	f	
3861	88	INV_ALT_2020009	1		Sin incidencias	f	
2863	53	INV_VPRO_ALT_00016	1		Sin incidencias	t	
3862	88	INV_ALT_2020026	1		Sin incidencias	f	
3381	72	INV_VPRO_ALT_00052	2		Sin incidencias	t	
3097	64	INV_ALT_2020031	1		Sin incidencias	t	
3098	64	INV_VPRO_ALT_00016	1		Sin incidencias	t	
3099	64	INV_ALT_2020011	2		Sin incidencias	t	
3100	64	INV_ALT_2020010	1		Sin incidencias	t	
3101	64	INV_ALT_2020032	1		Sin incidencias	t	
3102	64	INV_ALT_2020033	1		Sin incidencias	t	
3103	64	INV_ALT_2020034	2		Sin incidencias	t	
3104	64	INV_VPRO_ALT_00026	1		Sin incidencias	t	
3105	64	INV_ALT_2020035	1		Sin incidencias	t	
3106	64	INV_ALT_2020013	1		Sin incidencias	t	
3863	88	INV_ALT_2020027	1		Sin incidencias	f	
3864	88	INV_ALT_2020029	5		Sin incidencias	f	
3865	88	INV_ALT_2020030	5		Sin incidencias	f	
3866	88	INV_ALT_2020024	1		Sin incidencias	f	
3867	88	INV_ALT_2020023	1		Sin incidencias	f	
3868	88	INV_ALT_2020018	1		Sin incidencias	f	
3869	88	INV_ALT_2020025	1		Sin incidencias	f	
3870	88	INV_ALT_2020017	1		Sin incidencias	f	
3871	88	INV_VPRO_ALT_00245	1		Sin incidencias	f	
3872	88	INV_VPRO_ALT_00246	1		Sin incidencias	f	
3873	88	INV_VPRO_ALT_00189	1		Sin incidencias	f	
3874	88	INV_ALT_2020015	1		Sin incidencias	f	
3875	88	INV_ALT_2020019	4		Sin incidencias	f	
3876	88	INV_VPRO_ALT_00149	2		Sin incidencias	f	
3877	88	INV_ALT_2020012	4		Sin incidencias	f	
2499	27	INV_ALT_1040004	2	Television 65" Pantalla se dañado	Sin incidencias	f	
2500	27	INV_VPRO_ALT_00052	6		Sin incidencias	f	
2501	27	INV_ALT_1040005	2		Sin incidencias	f	
2502	27	INV_ALT_1040006	2		Sin incidencias	f	
2503	27	INV_VPRO_ALT_00175	5		Sin incidencias	f	
2504	27	INV_VPRO_ALT_00065	2		Sin incidencias	f	
2505	27	INV_VPRO_ALT_00023	1		Sin incidencias	f	
2506	27	VPRO_ALT_17765	2		Sin incidencias	f	
2471	46	INV_ALT_1090031	1		Sin incidencias	t	
2472	46	INV_ALT_1090065	2		Sin incidencias	t	
2473	46	INV_ALT_1090066	1		Sin incidencias	t	
2474	46	VPRO_ALT_26346	4		Sin incidencias	t	
2475	46	INV_ALT_1090038	2		Sin incidencias	t	
2476	46	INV_VPRO_ALT_00151	14		Sin incidencias	t	
2477	46	VPRO_ALT_26418	2		Sin incidencias	t	
2478	46	VPRO_ALT_26433	2		Sin incidencias	t	
2479	46	VPRO_ALT_26379	1		Sin incidencias	t	
2480	46	VPRO_ALT_26591	2		Sin incidencias	t	
2481	46	VPRO_ALT_26607	1		Sin incidencias	t	
2482	46	INV_ALT_1090067	1		Sin incidencias	t	
2483	46	INV_VPRO_ALT_00231	13		Sin incidencias	t	
2484	46	INV_ALT_1090068	5		Sin incidencias	t	
2485	46	INV_ALT_1090069	1		Sin incidencias	t	
2507	45	INV_VPRO_ALT_00151	6		Sin incidencias	f	
2508	45	INV_VPRO_ALT_00175	8		Sin incidencias	f	
2509	45	INV_VPRO_ALT_00231	1		Sin incidencias	f	
2510	45	INV_ALT_1040014	1		Sin incidencias	f	
2511	45	INV_ALT_1040015	1		Sin incidencias	f	
2512	45	VPRO_ALT_17836	2		Sin incidencias	f	
2513	45	INV_VPRO_ALT_00220	2		Sin incidencias	f	
2514	45	VPRO_ALT_17765	2		Sin incidencias	f	
2515	45	INV_VPRO_ALT_00023	6		Sin incidencias	f	
2516	45	INV_ALT_1040016	1		Sin incidencias	f	
2517	45	VPRO_ALT_74716	1		Sin incidencias	f	
2518	45	INV_ALT_1040017	1		Sin incidencias	f	
2519	45	INV_ALT_1040018	1		Sin incidencias	f	
2570	48	INV_ALT_2010007	1		Sin incidencias	t	
2571	48	INV_VPRO_ALT_00018	1		Sin incidencias	t	
2572	48	INV_VPRO_ALT_00013	1		Sin incidencias	t	
2573	48	Inv_alt_2010011	3		Sin incidencias	t	
2563	48	INV_VPRO_ALT_00023	10		Sin incidencias	t	
2564	48	INV_VPRO_ALT_00024	1		Sin incidencias	t	
2565	48	INV_VPRO_ALT_00181	1		Sin incidencias	t	
2543	47	INV_VPRO_ALT_00181	1		Sin incidencias	t	
2544	47	INV_ALT_2020021	1		Sin incidencias	t	
2545	47	INV_ALT_2010006	1		Sin incidencias	t	
2546	47	INV_VPRO_ALT_00093	1		Sin incidencias	t	
2547	47	INV_VPRO_ALT_00139	3		Sin incidencias	t	
2548	47	INV_VPRO_ALT_00021	1		Sin incidencias	t	
2549	47	INV_ALT_2010004	1		Sin incidencias	t	
2550	47	INV_ALT_2010007	1		Sin incidencias	t	
2551	47	INV_ALT_2010008	1		Sin incidencias	t	
2552	47	INV_VPRO_ALT_00024	1		Sin incidencias	t	
2553	47	INV_VPRO_ALT_00254	8		Sin incidencias	t	
2566	48	INV_VPRO_ALT_00021	1		Sin incidencias	t	
2567	48	INV_ALT_2020015	1		Sin incidencias	t	
2568	48	INV_ALT_2020021	1		Sin incidencias	t	
2569	48	INV_ALT_2010006	1		Sin incidencias	t	
2574	49	INV_ALT_2020014	1		Sin incidencias	t	
2602	51	VPRO_ALT_26361	1		Sin incidencias	t	
2603	51	VPRO_ALT_26379	1		Sin incidencias	t	
2604	51	VPRO_ALT_26418	1		Sin incidencias	t	
2605	51	VPRO_ALT_26433	1		Sin incidencias	t	
2606	51	VPRO_ALT_26448	1		Sin incidencias	t	
2607	51	VPRO_ALT_26466	1		Sin incidencias	t	
2608	51	VPRO_ALT_26493	1		Sin incidencias	t	
2609	51	VPRO_ALT_26522	1		Sin incidencias	t	
2610	51	VPRO_ALT_26591	1		Sin incidencias	t	
2611	51	VPRO_ALT_26607	1		Sin incidencias	t	
2612	51	VPRO_ALT_26673	1		Sin incidencias	t	
2613	51	VPRO_ALT_11376	1		Sin incidencias	t	
2614	51	Inv_alt_1090033	1		Sin incidencias	t	
3878	88	INV_ALT_2020031	1		Sin incidencias	f	
3879	88	INV_VPRO_ALT_00016	1		Sin incidencias	f	
4134	102	INV_VPRO_ALT_00012	1		Sin incidencias	f	
2845	53	INV_ALT_2020009	1		Sin incidencias	t	
2846	53	INV_ALT_2020026	1		Sin incidencias	t	
2847	53	INV_ALT_2020027	1		Sin incidencias	t	
2848	53	INV_ALT_2020029	5		Sin incidencias	t	
2849	53	INV_ALT_2020030	5		Sin incidencias	t	
2850	53	INV_ALT_2020024	1		Sin incidencias	t	
2851	53	INV_ALT_2020023	1		Sin incidencias	t	
2852	53	INV_ALT_2020018	1		Sin incidencias	t	
2853	53	INV_ALT_2020025	1		Sin incidencias	t	
2854	53	INV_ALT_2020017	1		Sin incidencias	t	
2855	53	INV_VPRO_ALT_00245	2		Sin incidencias	t	
2856	53	INV_VPRO_ALT_00246	1		Sin incidencias	t	
2857	53	INV_VPRO_ALT_00189	1		Sin incidencias	t	
2858	53	INV_ALT_2020015	1		Sin incidencias	t	
2859	53	INV_ALT_2020019	4		Sin incidencias	t	
2860	53	INV_VPRO_ALT_00149	2		Sin incidencias	t	
2861	53	INV_ALT_2020012	4		Sin incidencias	t	
2864	53	INV_ALT_2020011	2		Sin incidencias	t	
2865	53	INV_ALT_2020010	1		Sin incidencias	t	
2866	53	INV_ALT_2020032	1		Sin incidencias	t	
2867	53	INV_ALT_2020033	1		Sin incidencias	t	
2868	53	INV_ALT_2020034	2		Sin incidencias	t	
2869	53	INV_VPRO_ALT_00026	1		Sin incidencias	t	
2870	53	INV_ALT_2020035	1		Sin incidencias	t	
2871	53	INV_ALT_2020013	1		Sin incidencias	t	
2872	53	INV_ALT_2020021	1		Sin incidencias	t	
2873	53	INV_ALT_2020022	1		Sin incidencias	t	
2874	53	INV_VPRO_ALT_00092	1		Sin incidencias	t	
2875	53	INV_ALT_2020040	1		Sin incidencias	t	
2876	53	INV_ALT_2020041	1		Sin incidencias	t	
2877	53	INV_ALT_2020042	1		Sin incidencias	t	
2901	59	INV_ALT_1090065	1		Sin incidencias	t	
2902	59	INV_ALT_1090039	2		Sin incidencias	t	
2903	59	INV_ALT_1090038	2		Sin incidencias	t	
2904	59	INV_VPRO_ALT_00211	14		Sin incidencias	t	
2905	59	VPRO_ALT_26379	1		Sin incidencias	t	
2906	59	VPRO_ALT_26418	1		Sin incidencias	t	
2907	59	VPRO_ALT_26673	1		Sin incidencias	t	
2908	59	VPRO_ALT_26607	1		Sin incidencias	t	
2909	59	INV_ALT_1090070	2		Sin incidencias	t	
2910	59	INV_VPRO_ALT_00190	1		Sin incidencias	t	
2890	57	INV_VPRO_ALT_00175	4		Sin incidencias	t	
2891	57	VPRO_ALT_17765	1		Sin incidencias	t	
4437	110	INV_ALT_2020014	1		Sin incidencias	t	
2593	50	INV_VPRO_ALT_00023	10		Sin incidencias	f	
2892	57	INV_ALT_1040019	1		Sin incidencias	t	
2893	57	INV_VPRO_ALT_00211	4		Sin incidencias	t	
2894	57	INV_ALT_1190050	3		Sin incidencias	t	
2895	57	INV_ALT_1090067	1		Sin incidencias	t	
2896	57	VPRO_ALT_16456	1		Sin incidencias	t	
2897	57	INV_ALT_1040020	1		Sin incidencias	t	
2898	57	INV_ALT_1040021	1		Sin incidencias	t	
2899	57	INV_ALT_1040022	1		Sin incidencias	t	
3846	93	INV_VPRO_ALT_00179	1		Sin incidencias	t	
2900	59	INV_ALT_1090031	1		Sin incidencias	t	
2878	55	INV_VPRO_ALT_00023	2		Sin incidencias	f	
2879	55	INV_ALT_2020003	1		Sin incidencias	f	
4412	105	Inv_alt_1130019	1	[CUST_EQ:Computadora]	Sin incidencias	f	
4438	87	INV_ALT_2020014	1		Sin incidencias	t	Rayón en pantalla (test)
3290	63	INV_VPRO_ALT_00210	8		Sin incidencias	t	
3291	63	INV_VPRO_ALT_00211	12		Sin incidencias	t	
3292	63	INV_VPRO_ALT_00212	2		Sin incidencias	t	
3293	63	INV_VPRO_ALT_00213	1		Sin incidencias	t	
3294	63	INV_ALT_1040023	1		Sin incidencias	t	
3295	63	INV_ALT_1040024	1		Sin incidencias	t	
3296	63	INV_ALT_1040025	1		Sin incidencias	t	
3297	63	INV_ALT_1040026	2		Sin incidencias	t	
3298	63	INV_ALT_1040027	1		Sin incidencias	t	
3299	63	INV_ALT_1190050	4		Sin incidencias	t	
3300	63	INV_ALT_1040028	4		Sin incidencias	t	
3301	63	VPRO_ALT_17765	4		Sin incidencias	t	
3515	77	INV_ALT_2020015	1		Sin incidencias	f	
3516	77	INV_ALT_2020021	1		Sin incidencias	f	
3517	77	INV_ALT_2010006	1		Sin incidencias	f	
3518	77	INV_ALT_2010007	1		Sin incidencias	f	
3519	77	INV_VPRO_ALT_00018	1		Sin incidencias	f	
3880	84	INV_ALT_1190083	1		Sin incidencias	f	
3881	84	INV_ALT_1190084	1		Sin incidencias	f	
3882	84	INV_VPRO_ALT_00098	4		Sin incidencias	f	
3883	84	INV_VPRO_ALT_00100	1		Sin incidencias	f	
3884	84	INV_ALT_1190029	6		Sin incidencias	f	
3885	84	INV_ALT_1190006	1		Sin incidencias	f	
3886	84	INV_ALT_1190007	1		Sin incidencias	f	
3887	84	INV_ALT_1190050	14		Sin incidencias	f	
3888	84	INV_ALT_1190051	5		Sin incidencias	f	
3520	77	INV_VPRO_ALT_00023	8		Sin incidencias	f	
3521	77	INV_VPRO_ALT_00024	1		Sin incidencias	f	
3522	77	INV_VPRO_ALT_00181	1		Sin incidencias	f	
3523	77	INV_VPRO_ALT_00021	1		Sin incidencias	f	
3889	84	INV_ALT_1190052	2		Sin incidencias	f	
3890	84	INV_ALT_2020036	2		Sin incidencias	f	
3891	84	INV_VPRO_ALT_00153	1		Sin incidencias	f	
3892	84	INV_ALT_1190072	1		Sin incidencias	f	
3893	84	INV_ALT_1190073	1		Sin incidencias	f	
3894	84	INV_ALT_1090044	6		Sin incidencias	f	
3895	84	INV_ALT_1190074	4		Sin incidencias	f	
3896	84	INV_ALT_1190075	3		Sin incidencias	f	
3897	84	INV_ALT_1190076	3		Sin incidencias	f	
3898	84	INV_ALT_1190077	1		Sin incidencias	f	
3899	84	INV_ALT_1190079	2		Sin incidencias	f	
3900	84	INV_ALT_1190037	1		Sin incidencias	f	
3901	84	INV_ALT_1190082	2		Sin incidencias	f	
3902	84	INV_ALT_1190038	1		Sin incidencias	f	
3903	84	INV_ALT_1190039	2		Sin incidencias	f	
3904	84	INV_ALT_1190034	2		Sin incidencias	f	
3905	84	INV_VPRO_ALT_00151	1		Sin incidencias	f	
3906	84	INV_ALT_1190040	4		Sin incidencias	f	
3907	84	INV_ALT_1190042	4		Sin incidencias	f	
3908	84	INV_ALT_1190044	1		Sin incidencias	f	
3909	84	INV_VPRO_ALT_00202	6		Sin incidencias	f	
3910	84	INV_ALT_1190045	3		Sin incidencias	f	
3911	84	INV_ALT_1190046	2		Sin incidencias	f	
3541	82	INV_ALT_1130020	1		Sin incidencias	t	
3542	82	INV_ALT_1130021	1		Sin incidencias	t	
3262	60	INV_ALT_1090031	1		Sin incidencias	f	
3263	60	INV_ALT_1090065	1		Sin incidencias	f	
3264	60	INV_ALT_1090039	2		Sin incidencias	f	
3669	81	INV_VPRO_ALT_00023	8		Sin incidencias	t	
3670	81	INV_VPRO_ALT_00024	1		Sin incidencias	t	
3671	81	INV_ALT_2020021	1		Sin incidencias	t	
3672	81	INV_ALT_2010006	1		Sin incidencias	t	
3335	74	INV_VPRO_ALT_00012	1	⚠️ [LLEVA DAÑO REPORTADO]	Sin incidencias	t	
3500	52	INV_ALT_1190079	2		Sin incidencias	t	
3265	60	INV_ALT_1090038	2		Sin incidencias	f	
3266	60	INV_VPRO_ALT_00211	14		Sin incidencias	f	
3267	60	VPRO_ALT_26379	1		Sin incidencias	f	
3268	60	VPRO_ALT_26418	1		Sin incidencias	f	
3269	60	VPRO_ALT_26673	1		Sin incidencias	f	
3270	60	VPRO_ALT_26607	1		Sin incidencias	f	
3271	60	INV_ALT_1090070	2		Sin incidencias	f	
3272	60	INV_VPRO_ALT_00190	1		Sin incidencias	f	
3273	60	INV_ALT_1090067	1		Sin incidencias	f	
3274	60	INV_ALT_1130012	1		Sin incidencias	f	
3275	60	INV_ALT_1090071	1		Sin incidencias	f	
3501	52	INV_ALT_1190037	1		Sin incidencias	t	
3502	52	INV_ALT_1190038	1		Sin incidencias	t	
3503	52	INV_ALT_1190039	2		Sin incidencias	t	
3504	52	INV_ALT_1190034	1		Sin incidencias	t	
3505	52	INV_VPRO_ALT_00151	1		Sin incidencias	t	
3506	52	INV_ALT_1190040	2		Sin incidencias	t	
3327	62	INV_ALT_1040021	1		Sin incidencias	f	
3328	62	INV_ALT_1040022	1		Sin incidencias	f	
3329	62	INV_ALT_1130011	2		Sin incidencias	f	
3330	62	INV_VPRO_ALT_00175	3		Sin incidencias	f	
3331	62	INV_ALT_1040019	1		Sin incidencias	f	
3332	62	INV_VPRO_ALT_00211	4		Sin incidencias	f	
3333	62	INV_ALT_1190050	3		Sin incidencias	f	
3334	62	VPRO_ALT_16456	1		Sin incidencias	f	
3336	71	INV_VPRO_ALT_00018	1		Sin incidencias	t	
3337	71	INV_VPRO_ALT_00017	1		Sin incidencias	t	
3338	71	INV_ALT_2010002	1		Sin incidencias	t	
3339	71	INV_ALT_2010003	3		Sin incidencias	t	
3340	71	INV_VPRO_ALT_00168	1		Sin incidencias	t	
3341	71	INV_ALT_2010004	1		Sin incidencias	t	
3342	71	INV_VPRO_ALT_00013	1		Sin incidencias	t	
3343	71	INV_VPRO_ALT_00243	1		Sin incidencias	t	
3344	71	INV_ALT_2020028	1		Sin incidencias	t	
3507	52	INV_ALT_1190041	1		Sin incidencias	t	
3508	52	INV_ALT_1190042	3		Sin incidencias	t	
3509	52	INV_ALT_1190044	1		Sin incidencias	t	
3510	52	INV_VPRO_ALT_00202	6		Sin incidencias	t	
3511	52	INV_ALT_1190045	3		Sin incidencias	t	
3512	52	INV_ALT_1190046	2		Sin incidencias	t	
3513	52	INV_ALT_1190047	3		Sin incidencias	t	
3478	52	INV_ALT_1190049	2		Sin incidencias	t	
3479	52	INV_VPRO_ALT_00045	3		Sin incidencias	t	
3480	52	INV_VPRO_ALT_00097	4		Sin incidencias	t	
3481	52	INV_VPRO_ALT_00098	4		Sin incidencias	t	
3482	52	INV_VPRO_ALT_00099	6		Sin incidencias	t	
3483	52	INV_VPRO_ALT_00100	1		Sin incidencias	t	
3484	52	INV_ALT_1190029	4		Sin incidencias	t	
3485	52	INV_ALT_1190006	1		Sin incidencias	t	
3486	52	INV_ALT_1190007	1		Sin incidencias	t	
3487	52	INV_ALT_1190050	10		Sin incidencias	t	
3488	52	INV_ALT_1190051	5		Sin incidencias	t	
3489	52	INV_ALT_1190052	2		Sin incidencias	t	
3490	52	INV_ALT_2020036	2		Sin incidencias	t	
3491	52	INV_VPRO_ALT_00153	1		Sin incidencias	t	
3492	52	INV_ALT_1190072	1		Sin incidencias	t	
3493	52	INV_ALT_1190073	1		Sin incidencias	t	
3080	64	INV_ALT_2020009	1		Sin incidencias	t	
3081	64	INV_ALT_2020026	1		Sin incidencias	t	
3082	64	INV_ALT_2020027	1		Sin incidencias	t	
3083	64	INV_ALT_2020029	5		Sin incidencias	t	
3084	64	INV_ALT_2020030	5		Sin incidencias	t	
3916	84	INV_ALT_1190049	2		Sin incidencias	f	
3917	84	INV_VPRO_ALT_00045	3		Sin incidencias	f	
3918	84	INV_VPRO_ALT_00097	4		Sin incidencias	f	
3494	52	INV_ALT_1090044	5		Sin incidencias	t	
3474	65	INV_ALT_1190079	2		Sin incidencias	t	
3475	65	INV_ALT_1190037	1		Sin incidencias	t	
3495	52	INV_ALT_1190074	4		Sin incidencias	t	
3496	52	INV_ALT_1190075	3		Sin incidencias	t	
3497	52	INV_ALT_1190076	3		Sin incidencias	t	
3498	52	INV_ALT_1190077	1		Sin incidencias	t	
3499	52	INV_ALT_1190078	2		Sin incidencias	t	
3543	83	INV_ALT_1130023	1		Sin incidencias	f	
2959	61	Inv_Vpro_alt_00088	1		Sin incidencias	f	
3544	83	INV_VPRO_ALT_00024	1		Sin incidencias	f	
3545	83	INV_ALT_1130024	1		Sin incidencias	f	
3546	83	INV_ALT_1130025	1		Sin incidencias	f	
3547	83	INV_ALT_1130020	1		Sin incidencias	f	
3548	83	INV_ALT_1130021	1		Sin incidencias	f	
3549	83	INV_ALT_1130022	1		Sin incidencias	f	
3345	71	INV_VPRO_ALT_00190	1		Sin incidencias	t	
3374	70	INV_VPRO_ALT_00045	2		Sin incidencias	t	
3375	70	INV_VPRO_ALT_00001	2		Sin incidencias	t	
3376	70	INV_ALT_1050008	3		Sin incidencias	t	
3377	70	INV_ALT_1050009	3		Sin incidencias	t	
3378	70	INV_VPRO_ALT_00237	8		Sin incidencias	t	
3379	70	INV_ALT_1050010	1		Sin incidencias	t	
3380	70	Inv_alt_1050011	1	[CUST_EQ:CAJA DE RADIOS]	Sin incidencias	t	
3346	75	INV_ALT_1090031	1		Sin incidencias	t	
3347	75	INV_ALT_1090065	2		Sin incidencias	t	
3348	75	INV_ALT_1090039	2		Sin incidencias	t	
3349	75	INV_ALT_1090038	2		Sin incidencias	t	
3350	75	INV_VPRO_ALT_00211	14		Sin incidencias	t	
3351	75	VPRO_ALT_26379	1		Sin incidencias	t	
3352	75	VPRO_ALT_26418	1		Sin incidencias	t	
3353	75	VPRO_ALT_26673	1		Sin incidencias	t	
3354	75	VPRO_ALT_26607	1		Sin incidencias	t	
3355	75	INV_ALT_1090070	6		Sin incidencias	t	
3356	75	INV_ALT_1090067	1		Sin incidencias	t	
3357	75	INV_ALT_1130012	2		Sin incidencias	t	
3358	75	INV_ALT_1090071	2		Sin incidencias	t	
3359	75	Inv_alt_1090072	1	[CUST_EQ:Monitor]	Sin incidencias	t	
3360	66	INV_ALT_1090031	1		Sin incidencias	t	
3361	66	INV_ALT_1090065	1		Sin incidencias	t	
3362	66	INV_ALT_1090039	2		Sin incidencias	t	
3363	66	INV_ALT_1090038	2		Sin incidencias	t	
3364	66	INV_VPRO_ALT_00211	14		Sin incidencias	t	
3365	66	VPRO_ALT_26379	1		Sin incidencias	t	
3366	66	VPRO_ALT_26418	1		Sin incidencias	t	
3367	66	VPRO_ALT_26673	1		Sin incidencias	t	
3368	66	VPRO_ALT_26607	1		Sin incidencias	t	
3369	66	INV_ALT_1090070	1		Sin incidencias	t	
3370	66	INV_VPRO_ALT_00190	1		Sin incidencias	t	
3371	66	INV_ALT_1090067	1		Sin incidencias	t	
3373	66	INV_ALT_1090071	1		Sin incidencias	t	
3438	65	INV_ALT_1190038	1		Sin incidencias	t	
3439	65	INV_ALT_1190039	2		Sin incidencias	t	
3440	65	INV_ALT_1190034	1		Sin incidencias	t	
3441	65	INV_VPRO_ALT_00151	1		Sin incidencias	t	
3442	65	INV_ALT_1190040	4		Sin incidencias	t	
3443	65	INV_ALT_1190042	4		Sin incidencias	t	
3444	65	INV_ALT_1190044	1		Sin incidencias	t	
3445	65	INV_VPRO_ALT_00202	6		Sin incidencias	t	
3446	65	INV_ALT_1190045	3		Sin incidencias	t	
3447	65	INV_ALT_1190046	2		Sin incidencias	t	
3085	64	INV_ALT_2020024	1		Sin incidencias	t	
3086	64	INV_ALT_2020023	1		Sin incidencias	t	
3087	64	INV_ALT_2020018	1		Sin incidencias	t	
3088	64	INV_ALT_2020025	1		Sin incidencias	t	
3089	64	INV_ALT_2020017	1		Sin incidencias	t	
3090	64	INV_VPRO_ALT_00245	1		Sin incidencias	t	
3091	64	INV_VPRO_ALT_00246	1		Sin incidencias	t	
3092	64	INV_VPRO_ALT_00189	1		Sin incidencias	t	
3093	64	INV_ALT_2020015	1		Sin incidencias	t	
3094	64	INV_ALT_2020019	4		Sin incidencias	t	
3095	64	INV_VPRO_ALT_00149	2		Sin incidencias	t	
3096	64	INV_ALT_2020012	4		Sin incidencias	t	
3107	64	INV_ALT_2020021	1		Sin incidencias	t	
3108	64	INV_ALT_2020022	1		Sin incidencias	t	
3109	64	INV_VPRO_ALT_00092	1		Sin incidencias	t	
3110	64	INV_ALT_2020040	1		Sin incidencias	t	
3111	64	INV_ALT_2020041	1		Sin incidencias	t	
3112	64	Inv_alt_2020042	1		Sin incidencias	t	
3477	78	INV_ALT_1130019	1		Sin incidencias	f	
3912	84	INV_ALT_1190047	5		Sin incidencias	f	
3913	84	INV_ALT_1190048	3		Sin incidencias	f	
3914	84	INV_ALT_1190081	1		Sin incidencias	f	
3915	84	INV_ALT_1190080	1		Sin incidencias	f	
3448	65	INV_ALT_1190047	5		Sin incidencias	t	
3449	65	INV_ALT_1190048	3		Sin incidencias	t	
3450	65	INV_ALT_1190081	2		Sin incidencias	t	
3451	65	INV_ALT_1190080	1		Sin incidencias	t	
2594	50	INV_VPRO_ALT_00024	1		Sin incidencias	f	
2595	50	INV_VPRO_ALT_00181	1		Sin incidencias	f	
2596	50	INV_VPRO_ALT_00021	1		Sin incidencias	f	
2597	50	INV_ALT_2020015	1		Sin incidencias	f	
2598	50	INV_ALT_2020021	1		Sin incidencias	f	
2599	50	INV_ALT_2010006	1		Sin incidencias	f	
2600	50	INV_ALT_2010007	1		Sin incidencias	f	
2601	50	INV_VPRO_ALT_00018	1		Sin incidencias	f	
5566	134	INV_VPRO_ALT_00045	3		Sin incidencias	t	
4691	119	INV_ALT_1090047	1		Sin incidencias	t	
5567	134	INV_VPRO_ALT_00001	3		Sin incidencias	t	
5568	134	INV_VPRO_ALT_00097	4		Sin incidencias	t	
5569	134	INV_VPRO_ALT_00098	4		Sin incidencias	t	
5570	134	INV_VPRO_ALT_00100	1		Sin incidencias	t	
5571	134	INV_VPRO_ALT_00101	2		Sin incidencias	t	
5572	134	INV_VPRO_ALT_00103	4		Sin incidencias	t	
5573	134	INV_ALT_1190005	1		Sin incidencias	t	
5574	134	INV_ALT_1190006	1		Sin incidencias	t	
5575	134	Inv_Vpro_alt_00203	4		Sin incidencias	t	
5576	134	INV_ALT_1190007	1		Sin incidencias	t	
5577	134	INV_ALT_1090067	1		Sin incidencias	t	
4000	98	INV_ALT_2020009	1		Sin incidencias	t	
5578	134		2		Sin incidencias	t	
3452	65	INV_ALT_1090024	16		Sin incidencias	t	
3453	65	INV_ALT_1190049	2		Sin incidencias	t	
3454	65	INV_VPRO_ALT_00045	3		Sin incidencias	t	
3455	65	INV_VPRO_ALT_00097	4		Sin incidencias	t	
3456	65	INV_VPRO_ALT_00098	4		Sin incidencias	t	
3457	65	INV_VPRO_ALT_00100	1		Sin incidencias	t	
3458	65	INV_ALT_1190029	6		Sin incidencias	t	
3459	65	INV_ALT_1190006	1		Sin incidencias	t	
3460	65	INV_ALT_1190007	1		Sin incidencias	t	
3461	65	INV_ALT_1190050	12		Sin incidencias	t	
3462	65	INV_ALT_1190051	5		Sin incidencias	t	
3463	65	INV_ALT_1190052	2		Sin incidencias	t	
3464	65	INV_ALT_2020036	2		Sin incidencias	t	
3465	65	INV_VPRO_ALT_00153	1		Sin incidencias	t	
3466	65	INV_ALT_1190072	1		Sin incidencias	t	
3467	65	INV_ALT_1190073	1		Sin incidencias	t	
3468	65	INV_ALT_1090044	6		Sin incidencias	t	
3469	65	INV_ALT_1190074	4		Sin incidencias	t	
4001	98	INV_ALT_2020026	1		Sin incidencias	t	
4002	98	INV_ALT_2020027	1		Sin incidencias	t	
4003	98	INV_ALT_2020029	5		Sin incidencias	t	
4004	98	INV_ALT_2020030	5		Sin incidencias	t	
4005	98	INV_ALT_2020024	1		Sin incidencias	t	
4006	98	INV_ALT_2020023	1		Sin incidencias	t	
4007	98	INV_ALT_2020018	1		Sin incidencias	t	
4008	98	INV_ALT_2020025	1		Sin incidencias	t	
4009	98	INV_ALT_2020017	1		Sin incidencias	t	
3470	65	INV_ALT_1190075	3		Sin incidencias	t	
3471	65	INV_ALT_1190076	3		Sin incidencias	t	
3472	65	INV_ALT_1190077	1		Sin incidencias	t	
3473	65	INV_ALT_1190078	1		Sin incidencias	t	
3833	89	INV_VPRO_ALT_00237	4		Sin incidencias	t	
3834	89	INV_ALT_1050011	1		Sin incidencias	t	
3839	90	INV_VPRO_ALT_00236	1		Sin incidencias	t	
3840	90	INV_VPRO_ALT_00254	1		Sin incidencias	t	
3841	91	INV_ALT_1130017	1		Sin incidencias	t	
3842	91	INV_ALT_1130025	1		Sin incidencias	t	
3788	86	INV_VPRO_ALT_00023	6		Sin incidencias	t	
3789	86	INV_VPRO_ALT_00024	1		Sin incidencias	t	
3790	86	INV_ALT_2020021	1		Sin incidencias	t	
3843	91	Inv_alt_1020005	1		Sin incidencias	t	
3831	89	Inv_Vpro_alt_00138	1		Sin incidencias	t	
3832	89	INV_VPRO_ALT_00001	3		Sin incidencias	t	
3791	86	INV_ALT_2010006	1		Sin incidencias	t	
4421	107	Inv_Vpro_alt_00232	1	None	Sin incidencias	f	
5228	136	VPNBPA003	1		Sin incidencias	t	
4795	111	INV_ALT_1190080	1		Sin incidencias	f	
4796	111	INV_ALT_1190049	1		Sin incidencias	f	
4797	111	INV_ALT_1190083	1		Sin incidencias	f	
4798	111	Inv_alt_1190084	1	[CUST_EQ:Rack con vectorscopio]	Sin incidencias	f	
4097	99	INV_VPRO_ALT_00236	1		Sin incidencias	t	
4098	99	INV_ALT_1130026	1		Sin incidencias	t	
4099	99	INV_ALT_1130027	1		Sin incidencias	t	
4100	99	INV_ALT_1130028	1		Sin incidencias	t	
4799	111	INV_ALT_1190075	3		Sin incidencias	f	
4800	111	INV_ALT_1190076	3		Sin incidencias	f	
4801	111	INV_ALT_1190077	1		Sin incidencias	f	
4802	111	INV_ALT_1190079	2		Sin incidencias	f	
4803	111	INV_ALT_1190037	1		Sin incidencias	f	
4804	111	INV_ALT_1190082	3		Sin incidencias	f	
4805	111	INV_ALT_1190038	1		Sin incidencias	f	
4806	111	INV_ALT_1190039	2		Sin incidencias	f	
4807	111	INV_ALT_1190034	2		Sin incidencias	f	
4808	111	INV_ALT_1190040	4		Sin incidencias	f	
4809	111	INV_ALT_1190042	4		Sin incidencias	f	
4810	111	INV_ALT_1190044	1		Sin incidencias	f	
4811	111	INV_VPRO_ALT_00202	5		Sin incidencias	f	
4101	98	INV_ALT_2020011	2		Sin incidencias	t	
4102	98	INV_ALT_2020010	1		Sin incidencias	t	
4103	98	INV_ALT_2020009	1		Sin incidencias	t	
4104	98	INV_ALT_2020026	1		Sin incidencias	t	
4105	98	INV_ALT_2020027	1		Sin incidencias	t	
4106	98	INV_ALT_2020029	5		Sin incidencias	t	
4107	98	INV_ALT_2020030	5		Sin incidencias	t	
4108	98	INV_ALT_2020024	1		Sin incidencias	t	
4109	98	INV_ALT_2020023	1		Sin incidencias	t	
4110	98	INV_ALT_2020018	1		Sin incidencias	t	
4111	98	INV_ALT_2020025	1		Sin incidencias	t	
4112	98	INV_ALT_2020017	1		Sin incidencias	t	
4113	98	INV_ALT_2020032	1		Sin incidencias	t	
4114	98	INV_ALT_2020033	1		Sin incidencias	t	
4115	98	INV_ALT_2020034	2		Sin incidencias	t	
4116	98	INV_VPRO_ALT_00026	1		Sin incidencias	t	
4117	98	INV_ALT_2020035	1		Sin incidencias	t	
4118	98	INV_ALT_2020013	1		Sin incidencias	t	
4119	98	INV_ALT_2020021	1		Sin incidencias	t	
4121	98	INV_VPRO_ALT_00092	1		Sin incidencias	t	
4122	98	INV_ALT_2020040	1		Sin incidencias	t	
4123	98	INV_ALT_2020041	1		Sin incidencias	t	
4124	98	INV_ALT_2020042	1		Sin incidencias	t	
4125	98	INV_VPRO_ALT_00245	1		Sin incidencias	t	
4126	98	INV_VPRO_ALT_00246	1		Sin incidencias	t	
4127	98	INV_VPRO_ALT_00189	1		Sin incidencias	t	
4128	98	INV_ALT_2020015	1		Sin incidencias	t	
4129	98	INV_ALT_2020019	4		Sin incidencias	t	
4130	98	INV_VPRO_ALT_00149	2		Sin incidencias	t	
4131	98	INV_ALT_2020012	4		Sin incidencias	t	
4132	98	INV_ALT_2020031	1		Sin incidencias	t	
4133	98	INV_VPRO_ALT_00016	1		Sin incidencias	t	
5229	136	INV_VPRO_ALT_00001	4	4 son para luces y go pro	Sin incidencias	t	
5230	136	INV_ALT_1190042	1		Sin incidencias	t	
5231	136	INV_ALT_1050008	1	solo es uno	Sin incidencias	t	
5648	139	INV_ALT_1190048	3		Sin incidencias	t	
5649	139	INV_ALT_1190081	2		Sin incidencias	t	
4812	111	INV_ALT_1190045	3		Sin incidencias	f	
4813	111	INV_ALT_1190046	2		Sin incidencias	f	
4814	111	INV_ALT_1190047	3		Sin incidencias	f	
5650	139	INV_ALT_1190080	1		Sin incidencias	t	
5651	139	INV_ALT_1190049	1		Sin incidencias	t	
5652	139	INV_VPRO_ALT_00045	3		Sin incidencias	t	
5653	139	INV_VPRO_ALT_00097	5		Sin incidencias	t	
5654	139	INV_ALT_1190083	1		Sin incidencias	t	
5655	139	Inv_alt_1190084	1	[CUST_EQ:Rack con vectorscopio]	Sin incidencias	t	
5656	139		1		Sin incidencias	t	
5657	139	INV_VPRO_ALT_00098	3		Sin incidencias	t	
5658	139	INV_VPRO_ALT_00100	1		Sin incidencias	t	
4551	113	INV_VPRO_ALT_00149	2		Sin incidencias	t	
4552	113	INV_ALT_2020012	4		Sin incidencias	t	
4553	113	INV_VPRO_ALT_00016	1		Sin incidencias	t	
4554	113	INV_ALT_2020011	2		Sin incidencias	t	
4555	113	INV_ALT_2020010	1		Sin incidencias	t	
4706	112	VPRO_ALT_26379	1		Sin incidencias	f	
4707	112	VPRO_ALT_26466	3		Sin incidencias	f	
4708	112	VPRO_ALT_26522	2		Sin incidencias	f	
4709	112	VPRO_ALT_26591	1		Sin incidencias	f	
4710	112	VPRO_ALT_26607	1		Sin incidencias	f	
4711	112	VPRO_ALT_11376	1		Sin incidencias	f	
4544	113	INV_ALT_2020018	1		Sin incidencias	t	
4545	113	INV_ALT_2020025	1		Sin incidencias	t	
4654	118	VPRO_ALT_26256	1	Esta caja contiene el CPU que se utiliza para los eventos	Sin incidencias	t	
4655	118	VPRO_ALT_26379	1	None	Sin incidencias	t	
4656	118	VPRO_ALT_26448	12	None	Sin incidencias	t	
4657	118	VPRO_ALT_26466	3	None	Sin incidencias	t	
4658	118	VPRO_ALT_26558	2	None	Sin incidencias	t	
4659	118	VPRO_ALT_26591	2	Una prestada de Hector	Sin incidencias	t	
4660	118	VPRO_ALT_26607	1	None	Sin incidencias	t	
4661	118	VPRO_ALT_11376	1	sufrio golpe	Sin incidencias	t	
4662	118	VPRO_ALT_11423	1	None	Sin incidencias	t	
4663	118	VPRO_ALT_11490	1	None	Sin incidencias	t	
4664	118	VPRO_ALT_11525	1	None	Sin incidencias	t	
4665	118		12		Sin incidencias	t	
4666	118		4		Sin incidencias	t	
4667	118		1		Sin incidencias	t	
4668	118		1		Sin incidencias	t	
4669	118		1		Sin incidencias	t	
4670	118		1		Sin incidencias	t	
4671	118	VPNPRO190	1		Sin incidencias	t	
4546	113	INV_ALT_2020017	1		Sin incidencias	t	
4547	113	INV_VPRO_ALT_00246	1		Sin incidencias	t	
4548	113	INV_VPRO_ALT_00189	1		Sin incidencias	t	
4549	113	INV_ALT_2020015	1		Sin incidencias	t	
4550	113	INV_ALT_2020019	4		Sin incidencias	t	
5659	139	INV_ALT_1190029	6		Sin incidencias	t	
5660	139	INV_ALT_1190006	2		Sin incidencias	t	
5661	139	INV_ALT_1190007	1		Sin incidencias	t	
5821	150	VPRO_ALT_26256	1		Sin incidencias	f	
5822	150	Inv_Vpro_alt_00141	10		Sin incidencias	f	
5823	150	INV_VPRO_ALT_00231	10		Sin incidencias	f	
5824	150	INV_ALT_1130013	3		Sin incidencias	f	
5825	150	VPRO_ALT_26379	1		Sin incidencias	f	
5826	150	VPRO_ALT_26346	4		Sin incidencias	f	
5827	150	INV_ALT_1090065	2		Sin incidencias	f	
5828	150	VPRO_ALT_26607	1		Sin incidencias	f	
4672	118		2		Sin incidencias	t	
4673	118		1		Sin incidencias	t	
4426	106	Inv_alt_1050002	1		Sin incidencias	f	
4427	106		1		Sin incidencias	f	
4428	106	INV_ALT_1040001	1		Sin incidencias	f	
4429	106	INV_VPRO_ALT_00237	3		Sin incidencias	f	
5829	150	Inv_alt_1090002	1		Sin incidencias	f	
5830	150		2		Sin incidencias	f	
5831	150	VPRO_ALT_26418	2		Sin incidencias	f	
4674	118	INV_ALT_1190052	2		Sin incidencias	t	
4675	118	Inv_alt_1090019	1		Sin incidencias	t	
4676	118	Inv_Vpro_alt_00232	1		Sin incidencias	t	
4815	111	INV_ALT_1190048	3		Sin incidencias	f	
4816	111	INV_ALT_1190081	1		Sin incidencias	f	
4817	111	INV_VPRO_ALT_00045	3		Sin incidencias	f	
4818	111	INV_VPRO_ALT_00098	4		Sin incidencias	f	
4819	111	INV_VPRO_ALT_00100	1		Sin incidencias	f	
4820	111	INV_ALT_1190029	6		Sin incidencias	f	
4821	111	INV_ALT_1190006	2		Sin incidencias	f	
4822	111	INV_ALT_1190007	1		Sin incidencias	f	
4823	111	INV_ALT_1190050	9		Sin incidencias	f	
4824	111	INV_ALT_1190051	6		Sin incidencias	f	
4825	111	INV_ALT_1190052	2		Sin incidencias	f	
4826	111	INV_VPRO_ALT_00151	1		Sin incidencias	f	
4827	111	INV_ALT_2020036	2		Sin incidencias	f	
4828	111	INV_VPRO_ALT_00153	1		Sin incidencias	f	
4829	111	INV_ALT_1190072	1		Sin incidencias	f	
4830	111	INV_ALT_1190073	1		Sin incidencias	f	
4831	111	INV_ALT_1090044	6		Sin incidencias	f	
4832	111	INV_ALT_1190074	4		Sin incidencias	f	
4833	111	INV_VPRO_ALT_00097	5		Sin incidencias	f	
5832	150	VPRO_ALT_26433	2		Sin incidencias	f	
4677	118	INV_ALT_1090042	3		Sin incidencias	t	
4684	117	INV_ALT_1190050	7		Sin incidencias	f	
4685	117	INV_ALT_1130011	6		Sin incidencias	f	
4686	117	INV_ALT_1190006	1		Sin incidencias	f	
4687	117	INV_VPRO_ALT_00065	2		Sin incidencias	f	
4688	117	INV_VPRO_ALT_00175	5		Sin incidencias	f	
4689	117	INV_VPRO_ALT_00211	6		Sin incidencias	f	
5833	150	INV_ALT_1090040	2		Sin incidencias	f	
5834	150	INV_ALT_1090041	1		Sin incidencias	f	
5835	150	INV_ALT_1190012	1		Sin incidencias	f	
5836	150		1		Sin incidencias	f	
4834	122	Inv_alt_1190050	1		Sin incidencias	t	
4835	121	Inv_Vpro_alt_00063	2		Sin incidencias	f	
4836	121	INV_VPRO_ALT_00216	1		Sin incidencias	f	
4837	121	INV_ALT_1090031	1		Sin incidencias	f	
4838	121	VPRO_ALT_26591	1		Sin incidencias	f	
4839	121	INV_ALT_1190066	1		Sin incidencias	f	
4840	121	INV_ALT_1090039	2		Sin incidencias	f	
4841	121	INV_ALT_1190017	2		Sin incidencias	f	
4842	121		1		Sin incidencias	f	
4843	121	INV_ALT_1090034	2		Sin incidencias	f	
4844	121	VPNRED077	1		Sin incidencias	f	
4430	108	Inv_Vpro_alt_00236	1	None	Sin incidencias	f	
4431	108	Inv_Vpro_alt_00256	1	None	Sin incidencias	f	
4432	108	INV_ALT_1130007	1		Sin incidencias	f	
4433	108		1		Sin incidencias	f	
4557	114	INV_VPRO_ALT_00012	1	⚠️ [LLEVA DAÑO REPORTADO]	Sin incidencias	t	
5699	146		1		Sin incidencias	t	
4559	115	INV_VPRO_ALT_00017	1		Sin incidencias	t	
4560	115	INV_ALT_2010002	1		Sin incidencias	t	
4251	97	INV_ALT_1190085	1		Sin incidencias	t	
4252	97	INV_ALT_1190086	1		Sin incidencias	t	
4253	97	INV_ALT_1190085	1		Sin incidencias	t	
4254	97	INV_ALT_1190086	1		Sin incidencias	t	
4255	97	INV_ALT_1190081	2		Sin incidencias	t	
4256	97	INV_ALT_1190080	1		Sin incidencias	t	
4257	97	INV_ALT_1190049	2		Sin incidencias	t	
4258	97	INV_VPRO_ALT_00045	3		Sin incidencias	t	
4259	97	INV_VPRO_ALT_00097	5		Sin incidencias	t	
4260	97	INV_ALT_1190083	1		Sin incidencias	t	
4261	97	INV_ALT_1190084	1		Sin incidencias	t	
4262	97	INV_VPRO_ALT_00098	4		Sin incidencias	t	
4263	97	INV_VPRO_ALT_00100	1		Sin incidencias	t	
4264	97	INV_ALT_1190029	6		Sin incidencias	t	
4265	97	INV_ALT_1190006	1		Sin incidencias	t	
4266	97	INV_ALT_1190007	1		Sin incidencias	t	
4267	97	INV_ALT_1190050	9		Sin incidencias	t	
4268	97	INV_ALT_1190051	6		Sin incidencias	t	
4269	97	INV_ALT_1190052	2		Sin incidencias	t	
4270	97	INV_ALT_1190081	1		Sin incidencias	t	
4271	97	INV_ALT_1190080	1		Sin incidencias	t	
4272	97	INV_ALT_1190049	2		Sin incidencias	t	
4273	97	INV_VPRO_ALT_00045	3		Sin incidencias	t	
4274	97	INV_VPRO_ALT_00097	4		Sin incidencias	t	
4275	97	INV_ALT_1190083	1		Sin incidencias	t	
4276	97	INV_ALT_1190084	1		Sin incidencias	t	
4277	97	INV_VPRO_ALT_00098	4		Sin incidencias	t	
4278	97	INV_VPRO_ALT_00100	1		Sin incidencias	t	
4279	97	INV_ALT_1190029	6		Sin incidencias	t	
4280	97	INV_ALT_1190006	1		Sin incidencias	t	
4281	97	INV_ALT_1190007	1		Sin incidencias	t	
4282	97	INV_ALT_1190050	9		Sin incidencias	t	
4283	97	INV_ALT_1190051	5		Sin incidencias	t	
4561	115	INV_ALT_2010003	3		Sin incidencias	t	
4562	115	INV_VPRO_ALT_00168	1		Sin incidencias	t	
4563	115	INV_ALT_2010004	1		Sin incidencias	t	
4564	115	INV_VPRO_ALT_00013	1		Sin incidencias	t	
4565	115	INV_VPRO_ALT_00243	1		Sin incidencias	t	
5700	146		1		Sin incidencias	t	
5701	146		1		Sin incidencias	t	
5702	146		1		Sin incidencias	t	
5703	146		1		Sin incidencias	t	
5704	146		1		Sin incidencias	t	
4019	98	INV_ALT_2020011	2		Sin incidencias	t	
4558	115	INV_VPRO_ALT_00018	1		Sin incidencias	t	
4020	98	INV_ALT_2020010	1		Sin incidencias	t	
4021	98	INV_ALT_2020032	1		Sin incidencias	t	
4022	98	INV_ALT_2020033	1		Sin incidencias	t	
4023	98	INV_ALT_2020034	2		Sin incidencias	t	
4024	98	INV_VPRO_ALT_00026	1		Sin incidencias	t	
4025	98	INV_ALT_2020035	1		Sin incidencias	t	
4026	98	INV_ALT_2020013	1		Sin incidencias	t	
4027	98	INV_ALT_2020021	1		Sin incidencias	t	
4028	98	INV_ALT_2020022	1		Sin incidencias	t	
4532	113	INV_ALT_2020040	1		Sin incidencias	t	
4533	113	INV_ALT_2020041	1		Sin incidencias	t	
4523	113	INV_VPRO_ALT_00245	1		Sin incidencias	t	
4524	113	INV_ALT_2020031	1		Sin incidencias	t	
4525	113	INV_ALT_2020034	2		Sin incidencias	t	
4526	113	INV_VPRO_ALT_00026	1		Sin incidencias	t	
4527	113	INV_ALT_2020035	1		Sin incidencias	t	
4528	113	INV_ALT_2020013	1		Sin incidencias	t	
4529	113	INV_ALT_2020021	1		Sin incidencias	t	
4530	113	INV_ALT_2020022	1		Sin incidencias	t	
4531	113	INV_VPRO_ALT_00092	1		Sin incidencias	t	
4534	113	Inv_alt_2020042	1		Sin incidencias	t	
4535	113	INV_ALT_2020032	1		Sin incidencias	t	
4536	113	INV_ALT_2020033	1		Sin incidencias	t	
4537	113	INV_ALT_2020009	1		Sin incidencias	t	
4538	113	INV_ALT_2020026	1		Sin incidencias	t	
4539	113	INV_ALT_2020027	1		Sin incidencias	t	
4540	113	INV_ALT_2020029	5		Sin incidencias	t	
4541	113	INV_ALT_2020030	5		Sin incidencias	t	
4542	113	INV_ALT_2020024	1		Sin incidencias	t	
4543	113	INV_ALT_2020023	1		Sin incidencias	t	
4284	97	INV_ALT_1190052	2		Sin incidencias	t	
4285	97	INV_ALT_2020036	2		Sin incidencias	t	
4286	97	INV_VPRO_ALT_00153	1		Sin incidencias	t	
4287	97	INV_ALT_1190072	1		Sin incidencias	t	
4288	97	INV_ALT_1190073	1		Sin incidencias	t	
4289	97	INV_ALT_1090044	6		Sin incidencias	t	
4290	97	INV_ALT_1190074	4		Sin incidencias	t	
4291	97	INV_ALT_1190075	3		Sin incidencias	t	
4292	97	INV_ALT_1190076	3		Sin incidencias	t	
4293	97	INV_ALT_1190077	1		Sin incidencias	t	
4294	97	INV_ALT_1190079	2		Sin incidencias	t	
4295	97	INV_ALT_1190037	1		Sin incidencias	t	
4296	97	INV_ALT_1190082	2		Sin incidencias	t	
4297	97	INV_ALT_1190038	1		Sin incidencias	t	
4298	97	INV_ALT_1190039	2		Sin incidencias	t	
4299	97	INV_ALT_1190034	2		Sin incidencias	t	
4300	97	INV_VPRO_ALT_00151	1		Sin incidencias	t	
4301	97	INV_ALT_1190040	4		Sin incidencias	t	
4302	97	INV_ALT_1190042	4		Sin incidencias	t	
4303	97	INV_ALT_1190044	1		Sin incidencias	t	
4304	97	INV_VPRO_ALT_00202	6		Sin incidencias	t	
4305	97	INV_ALT_1190045	3		Sin incidencias	t	
4306	97	INV_ALT_1190046	2		Sin incidencias	t	
4307	97	INV_ALT_1190047	3		Sin incidencias	t	
4308	97	INV_ALT_1190048	3		Sin incidencias	t	
4309	97	INV_ALT_2020036	2		Sin incidencias	t	
4310	97	INV_VPRO_ALT_00153	1		Sin incidencias	t	
4311	97	INV_ALT_1190072	1		Sin incidencias	t	
4312	97	INV_ALT_1190073	1		Sin incidencias	t	
4313	97	INV_ALT_1090044	6		Sin incidencias	t	
4314	97	INV_ALT_1190074	4		Sin incidencias	t	
4315	97	INV_ALT_1190075	3		Sin incidencias	t	
4316	97	INV_ALT_1190076	3		Sin incidencias	t	
4317	97	INV_ALT_1190077	1		Sin incidencias	t	
4318	97	INV_ALT_1190079	2		Sin incidencias	t	
4319	97	INV_ALT_1190037	1		Sin incidencias	t	
4320	97	INV_ALT_1190082	2		Sin incidencias	t	
4321	97	INV_ALT_1190038	1		Sin incidencias	t	
4322	97	INV_ALT_1190039	2		Sin incidencias	t	
4323	97	INV_ALT_1190034	2		Sin incidencias	t	
4324	97	INV_VPRO_ALT_00151	1		Sin incidencias	t	
4325	97	INV_ALT_1190040	4		Sin incidencias	t	
4326	97	INV_ALT_1190042	4		Sin incidencias	t	
4327	97	INV_ALT_1190044	1		Sin incidencias	t	
4328	97	INV_VPRO_ALT_00202	6		Sin incidencias	t	
4329	97	INV_ALT_1190045	3		Sin incidencias	t	
4330	97	INV_ALT_1190046	2		Sin incidencias	t	
4331	97	INV_ALT_1190047	3		Sin incidencias	t	
4332	97	INV_ALT_1190048	3		Sin incidencias	t	
4333	97	INV_VPRO_ALT_00099	4		Sin incidencias	t	
5596	140	INV_VPRO_ALT_00012	1		Sin incidencias	t	
5680	138	INV_ALT_1190050	10		Sin incidencias	t	
5681	138	INV_VPRO_ALT_00211	10		Sin incidencias	t	
5682	138	INV_VPRO_ALT_00053	7		Sin incidencias	t	
5683	138	Inv_Vpro_alt_00062	1		Sin incidencias	t	
5684	138	INV_VPRO_ALT_00065	1		Sin incidencias	t	
4434	109	Inv_alt_2000001	1	[CUST_EQ:Computadora Mac] Computadora MAC asignada a Andrea	Sin incidencias	f	
4029	98	INV_VPRO_ALT_00092	1		Sin incidencias	t	
4030	98	INV_ALT_2020040	1		Sin incidencias	t	
4031	98	INV_ALT_2020041	1		Sin incidencias	t	
4032	98	Inv_alt_2020042	1		Sin incidencias	t	
4010	98	INV_VPRO_ALT_00245	1		Sin incidencias	t	
4011	98	INV_VPRO_ALT_00246	1		Sin incidencias	t	
4012	98	INV_VPRO_ALT_00189	1		Sin incidencias	t	
4013	98	INV_ALT_2020015	1		Sin incidencias	t	
4014	98	INV_ALT_2020019	4		Sin incidencias	t	
4015	98	INV_VPRO_ALT_00149	2		Sin incidencias	t	
4016	98	INV_ALT_2020012	4		Sin incidencias	t	
4017	98	INV_ALT_2020031	1		Sin incidencias	t	
4018	98	INV_VPRO_ALT_00016	1		Sin incidencias	t	
5685	138	Inv_Vpro_alt_00156	3		Sin incidencias	t	
5686	138	Inv_Vpro_alt_00218	1		Sin incidencias	t	
5687	138	Inv_Vpro_alt_00217	2		Sin incidencias	t	
5688	138	Inv_Vpro_alt_00063	2		Sin incidencias	t	
4566	116	INV_VPRO_ALT_00045	3		Sin incidencias	t	
4567	116	INV_ALT_1190081	2		Sin incidencias	t	
4568	116	VPNBPA003	1		Sin incidencias	t	
4569	116	INV_ALT_1050007	2		Sin incidencias	t	
4570	116	Inv_Vpro_alt_00097	3		Sin incidencias	t	
4571	116	INV_ALT_1190071	2		Sin incidencias	t	
4572	116	INV_VPRO_ALT_00001	7	4 son para luces y go pro	Sin incidencias	t	
4573	116	INV_ALT_1190042	2		Sin incidencias	t	
4574	116	INV_VPRO_ALT_00101	2		Sin incidencias	t	
4575	116	INV_ALT_1050008	1	solo es uno	Sin incidencias	t	
4120	98	INV_ALT_2020022	1		Sin incidencias	t	
4712	120	INV_ALT_1040001	1		Sin incidencias	f	
5837	150		2		Sin incidencias	f	
5838	150	VPNPRO339	1		Sin incidencias	f	
5839	150	VPNPRO340	1		Sin incidencias	f	
5840	150	INV_ALT_1090050	1		Sin incidencias	f	
5841	150	VPNPRO190	1		Sin incidencias	f	
5842	150	INV_ALT_1090017	3		Sin incidencias	f	
5843	150	INV_ALT_1090042	1		Sin incidencias	f	
5844	150	INV_ALT_1090021	1		Sin incidencias	f	
5845	150	INV_VPRO_ALT_00255	1		Sin incidencias	f	
4845	121	VPNRED033	1		Sin incidencias	f	
4846	121	INV_VPRO_ALT_00175	3		Sin incidencias	f	
4847	121	INV_VPRO_ALT_00211	2		Sin incidencias	f	
4848	121	INV_ALT_1190050	6		Sin incidencias	f	
4849	121	INV_VPRO_ALT_00065	1		Sin incidencias	f	
4850	121	Inv_alt_1040004	1		Sin incidencias	f	
4851	121	INV_ALT_1090060	2		Sin incidencias	f	
4852	121	INV_VPRO_ALT_00024	1		Sin incidencias	f	
4853	121	INV_VPRO_ALT_26708	1		Sin incidencias	f	
4854	121	Inv_Vpro_alt_00062	1		Sin incidencias	f	
4950	128	VIRA004	5		Sin incidencias	t	
4951	128	Inv_Vpro_alt_00054	5		Sin incidencias	t	
4952	128	Inv_alt_1040019	3		Sin incidencias	t	
4953	128	INV_VPRO_ALT_00052	15		Sin incidencias	t	
4954	128	INV_ALT_1040010	2		Sin incidencias	t	
4955	128	INV_VPRO_ALT_00053	10		Sin incidencias	t	
4956	128	INV_VPRO_ALT_00173	6		Sin incidencias	t	
5663	123	INV_VPRO_ALT_00045	3		Sin incidencias	t	
5421	133	VPNCOM007	1		Sin incidencias	f	
5422	133	VPNRED071	1		Sin incidencias	f	
5423	133	VPNEST015	1		Sin incidencias	f	
5424	133	VPNRED056	1		Sin incidencias	f	
5425	133	VPNRED057	1		Sin incidencias	f	
5426	133	VPNRED027	1		Sin incidencias	f	
5427	133	VPNRED018	1		Sin incidencias	f	
5428	133	VPNRED103	1		Sin incidencias	f	
5429	133	VPNRED076	1		Sin incidencias	f	
5430	133	INV_VPRO_ALT_00245	1		Sin incidencias	f	
5431	133	INV_VPRO_ALT_00246	1		Sin incidencias	f	
5432	133	INV_VPRO_ALT_00189	1		Sin incidencias	f	
5664	123	INV_VPRO_ALT_00001	3		Sin incidencias	t	
5665	123	INV_VPRO_ALT_00097	6		Sin incidencias	t	
5666	123	INV_VPRO_ALT_00098	4		Sin incidencias	t	
5667	123	INV_VPRO_ALT_00099	6		Sin incidencias	t	
5668	123	INV_VPRO_ALT_00100	1		Sin incidencias	t	
5669	123	INV_VPRO_ALT_00101	2		Sin incidencias	t	
5670	123	INV_VPRO_ALT_00103	4		Sin incidencias	t	
5671	123	INV_ALT_1190001	2		Sin incidencias	t	
5672	123	INV_ALT_1190005	1		Sin incidencias	t	
5673	123	INV_ALT_1190006	2		Sin incidencias	t	
5674	123	Inv_Vpro_alt_00203	4		Sin incidencias	t	
5675	123	INV_ALT_1040011	1		Sin incidencias	t	
5676	123	INV_ALT_1190039	1		Sin incidencias	t	
5677	123	Inv_Vpro_alt_00137	3		Sin incidencias	t	
5678	123	INV_ALT_1190007	1		Sin incidencias	t	
5679	123	INV_ALT_1090067	1		Sin incidencias	t	
5705	146		1		Sin incidencias	t	
5706	146		1		Sin incidencias	t	
5707	146		1		Sin incidencias	t	
5708	146		1		Sin incidencias	t	
5709	137	Inv_Vpro_alt_00236	1	None	Sin incidencias	t	
5710	137	INV_ALT_1130028	1		Sin incidencias	t	
5711	137	INV_ALT_1130026	1		Sin incidencias	t	
5712	137	INV_VPRO_ALT_00024	1		Sin incidencias	t	
5713	137	Inv_Vpro_alt_00237	2	⚠️ [LLEVA DAÑO REPORTADO]	Sin incidencias	t	
5714	137	INV_ALT_1190042	1		Sin incidencias	t	
5748	141	INV_ALT_2020026	1		Sin incidencias	t	
5749	141	INV_ALT_2020027	1		Sin incidencias	t	
5750	141	INV_ALT_2020029	5		Sin incidencias	t	
5751	141	INV_ALT_2020030	5		Sin incidencias	t	
5752	141	INV_ALT_2020024	1		Sin incidencias	t	
5753	141	INV_ALT_2020023	1		Sin incidencias	t	
5754	141	INV_ALT_2020018	1		Sin incidencias	t	
5755	141	INV_ALT_2020025	1		Sin incidencias	t	
5756	141	INV_ALT_2020017	1		Sin incidencias	t	
5757	141	INV_VPRO_ALT_00245	1		Sin incidencias	t	
5758	141	INV_VPRO_ALT_00246	1		Sin incidencias	t	
5759	141	INV_VPRO_ALT_00189	1		Sin incidencias	t	
4958	128	Inv_alt_1040022	1		Sin incidencias	t	
5153	132	INV_ALT_1130006	1		Sin incidencias	t	
5598	143	Hiace	1		Sin incidencias	t	
5275	126	INV_VPRO_ALT_00013	1		Sin incidencias	t	
5276	126	INV_VPRO_ALT_00016	1		Sin incidencias	t	
5277	126	INV_VPRO_ALT_00017	1		Sin incidencias	t	
5278	126	INV_VPRO_ALT_00018	1		Sin incidencias	t	
5279	126	INV_VPRO_ALT_00021	1		Sin incidencias	t	
5280	126	INV_VPRO_ALT_00022	1		Sin incidencias	t	
5281	126	INV_VPRO_ALT_00024	1		Sin incidencias	t	
5282	126	INV_VPRO_ALT_00025	1		Sin incidencias	t	
5283	126	INV_VPRO_ALT_00092	1		Sin incidencias	t	
5284	126	Inv_alt_2010001	1		Sin incidencias	t	
5285	126	INV_ALT_2010003	1		Sin incidencias	t	
5286	126	Inv_Vpro_alt_00020	1		Sin incidencias	t	
5287	126	INV_ALT_2020021	1	⚠️ [LLEVA DAÑO REPORTADO]	Sin incidencias	t	
5288	126	Inv_alt_2020022	1		Sin incidencias	t	
5289	126	VPNRED035	1		Sin incidencias	t	
5760	141	INV_ALT_2020015	1		Sin incidencias	t	
5761	141	INV_ALT_2020019	4		Sin incidencias	t	
5762	141	INV_VPRO_ALT_00149	2		Sin incidencias	t	
5763	141	INV_ALT_2020012	4		Sin incidencias	t	
5764	141	INV_VPRO_ALT_00016	1		Sin incidencias	t	
5765	141	INV_ALT_2020011	2		Sin incidencias	t	
5766	141	INV_ALT_2020010	1		Sin incidencias	t	
5767	141	INV_ALT_2020032	1		Sin incidencias	t	
5768	141	INV_ALT_2020033	1		Sin incidencias	t	
5769	141	INV_ALT_2020034	2		Sin incidencias	t	
5770	141	INV_VPRO_ALT_00026	1		Sin incidencias	t	
5771	141	INV_ALT_2020035	1		Sin incidencias	t	
5772	141	INV_ALT_2020013	1		Sin incidencias	t	
5773	141	INV_ALT_2020021	1	⚠️ [LLEVA DAÑO REPORTADO]	Sin incidencias	t	
5774	141	INV_ALT_2020022	1		Sin incidencias	t	
5775	141	INV_VPRO_ALT_00092	1		Sin incidencias	t	
5776	141	INV_ALT_2020040	1		Sin incidencias	t	
5777	141	INV_ALT_2020041	1		Sin incidencias	t	
5778	141	Inv_alt_2020042	1		Sin incidencias	t	
5779	141	INV_ALT_2020009	1		Sin incidencias	t	
5815	149	INV_ALT_1090047	1		Sin incidencias	t	
5816	149	Inv_Vpro_alt_00217	1		Sin incidencias	t	
5817	149	INV_VPRO_ALT_00175	1		Sin incidencias	t	
5818	149	INV_VPRO_ALT_00211	1		Sin incidencias	t	
5819	149	Inv_Vpro_alt_00156	1		Sin incidencias	t	
5846	151	INV_VPRO_ALT_00013	1		Sin incidencias	f	
5847	151	INV_VPRO_ALT_00016	2		Sin incidencias	f	
5848	151	INV_VPRO_ALT_00017	1		Sin incidencias	f	
5849	151	INV_VPRO_ALT_00018	1		Sin incidencias	f	
5850	151	INV_VPRO_ALT_00021	1		Sin incidencias	f	
5851	151	INV_VPRO_ALT_00022	1		Sin incidencias	f	
5852	151	INV_VPRO_ALT_00024	2		Sin incidencias	f	
5853	151	INV_VPRO_ALT_00025	1		Sin incidencias	f	
5854	151	INV_VPRO_ALT_00092	1		Sin incidencias	f	
5855	151	Inv_alt_2010001	1		Sin incidencias	f	
5856	151	INV_ALT_2010003	7		Sin incidencias	f	
5857	151	Inv_Vpro_alt_00020	2		Sin incidencias	f	
5858	151	INV_ALT_2020021	1	⚠️ [LLEVA DAÑO REPORTADO]	Sin incidencias	f	
5859	151	Inv_alt_2020022	1		Sin incidencias	f	
5780	142	INV_ALT_1090031	1		Sin incidencias	t	
5781	142	VPRO_ALT_26379	1		Sin incidencias	t	
5782	142	VPRO_ALT_26673	1		Sin incidencias	t	
5783	142	VPRO_ALT_26607	1		Sin incidencias	t	
5784	142	INV_VPRO_ALT_00190	1		Sin incidencias	t	
5785	142	INV_VPRO_ALT_00174	5		Sin incidencias	t	
5786	142	INV_ALT_1130013	1		Sin incidencias	t	
5802	144	VPRO_ALT_26379	1		Sin incidencias	t	
5803	144	VPRO_ALT_26466	2		Sin incidencias	t	
5804	144	VPRO_ALT_26522	1		Sin incidencias	t	
5805	144	VPRO_ALT_26591	1		Sin incidencias	t	
5806	144	VPRO_ALT_26607	1		Sin incidencias	t	
5807	144	VPRO_ALT_11376	1		Sin incidencias	t	
5808	145	Inv_alt_1130019	1	[CUST_EQ:Computadora]	Sin incidencias	t	
5820	148	INV_ALT_1190050	6		Sin incidencias	t	
5860	151	VPNRED035	1		Sin incidencias	f	
5881	152	INV_VPRO_ALT_00045	3		Sin incidencias	f	
5882	152	INV_VPRO_ALT_00001	3		Sin incidencias	f	
5883	152	INV_VPRO_ALT_00097	6		Sin incidencias	f	
5884	152	INV_VPRO_ALT_00098	1		Sin incidencias	f	
5885	152	INV_VPRO_ALT_00099	6		Sin incidencias	f	
5886	152	INV_VPRO_ALT_00100	1		Sin incidencias	f	
5887	152	INV_VPRO_ALT_00101	2		Sin incidencias	f	
5888	152	INV_VPRO_ALT_00211	3		Sin incidencias	f	
5889	152	INV_VPRO_ALT_00103	2		Sin incidencias	f	
5890	152		2	⚠️ [LLEVA DAÑO REPORTADO]	Sin incidencias	f	
5891	152	INV_VPRO_ALT_00205	2		Sin incidencias	f	
5892	152	Inv_alt_1190005	1		Sin incidencias	f	
5893	152	INV_ALT_1190007	1		Sin incidencias	f	
5894	152	INV_ALT_1190006	1		Sin incidencias	f	
5895	152	INV_ALT_1190068	1		Sin incidencias	f	
5896	152	INV_ALT_1190008	2		Sin incidencias	f	
5897	152		1		Sin incidencias	f	
5898	152	INV_VPRO_ALT_00231	3		Sin incidencias	f	
5899	152	INV_ALT_1190022	1		Sin incidencias	f	
5599	131	VPRO_ALT_11376	1		Sin incidencias	f	
5600	131	VPRO_ALT_11423	1	None	Sin incidencias	f	
5601	131	VPRO_ALT_11490	1	None	Sin incidencias	f	
5602	131	VPRO_ALT_11525	1	None	Sin incidencias	f	
5603	131	INV_ALT_1190052	3		Sin incidencias	f	
5604	131	Inv_Vpro_alt_00232	1		Sin incidencias	f	
5605	131	VPRO_ALT_26256	1	Esta caja contiene el CPU que se utiliza para los eventos	Sin incidencias	f	
5606	131	VPRO_ALT_26379	1	None	Sin incidencias	f	
5607	131	VPRO_ALT_26448	10	None	Sin incidencias	f	
5608	131	VPRO_ALT_26466	1	None	Sin incidencias	f	
5609	131	VPRO_ALT_26558	2	None	Sin incidencias	f	
5610	131	VPRO_ALT_26591	2	Una prestada de Hector	Sin incidencias	f	
5611	131	VPRO_ALT_26607	1	None	Sin incidencias	f	
5612	131	INV_ALT_1090042	3		Sin incidencias	f	
5613	131	VPNPRO190	1		Sin incidencias	f	
5614	131	Inv_alt_1190012	2		Sin incidencias	f	
5615	131	INV_ALT_1090002	1		Sin incidencias	f	
4957	128	Inv_Vpro_alt_00056	2		Sin incidencias	t	
5004	129	VPRO_ALT_26256	1		Sin incidencias	t	
5005	129	Inv_Vpro_alt_00141	10		Sin incidencias	t	
5006	129	INV_VPRO_ALT_00231	10		Sin incidencias	t	
5007	129	INV_ALT_1130013	3		Sin incidencias	t	
5008	129	VPRO_ALT_26379	1		Sin incidencias	t	
5009	129	VPRO_ALT_26346	2		Sin incidencias	t	
5010	129	INV_ALT_1090065	2		Sin incidencias	t	
5011	129	VPRO_ALT_26607	1		Sin incidencias	t	
5012	129	Inv_alt_1090002	1		Sin incidencias	t	
5013	129		2		Sin incidencias	t	
5014	129	VPRO_ALT_26418	2		Sin incidencias	t	
5015	129	VPRO_ALT_26433	2		Sin incidencias	t	
5016	129	INV_ALT_1090040	2		Sin incidencias	t	
5017	129	INV_ALT_1090041	1		Sin incidencias	t	
5018	129	INV_ALT_1190012	2		Sin incidencias	t	
5019	129		1		Sin incidencias	t	
5020	129		2		Sin incidencias	t	
5021	129	VPNPRO339	1		Sin incidencias	t	
5022	129	VPNPRO340	1		Sin incidencias	t	
5023	129	INV_ALT_1090050	1		Sin incidencias	t	
5024	129	VPNPRO190	1		Sin incidencias	t	
5025	129	INV_ALT_1090017	3		Sin incidencias	t	
5026	129	INV_ALT_1090042	3		Sin incidencias	t	
5027	129	INV_ALT_1090021	1		Sin incidencias	t	
5028	129	INV_VPRO_ALT_00255	1		Sin incidencias	t	
5787	147	Inv_Vpro_alt_00138	1	None	Sin incidencias	t	
5622	139	INV_ALT_1190050	9		Sin incidencias	t	
5623	139	INV_ALT_1190051	6		Sin incidencias	t	
5624	139	INV_ALT_1190052	2		Sin incidencias	t	
5625	139	INV_ALT_2020036	2		Sin incidencias	t	
5626	139	INV_VPRO_ALT_00153	1		Sin incidencias	t	
5627	139	INV_ALT_1190072	1		Sin incidencias	t	
5628	139	INV_ALT_1190073	1		Sin incidencias	t	
5629	139	INV_ALT_1090044	4		Sin incidencias	t	
5630	139	INV_ALT_1190074	4		Sin incidencias	t	
5631	139	INV_ALT_1190075	3		Sin incidencias	t	
5632	139	INV_ALT_1190076	3		Sin incidencias	t	
5633	139	INV_ALT_1190077	2		Sin incidencias	t	
5634	139	INV_ALT_1190037	1		Sin incidencias	t	
5635	139	INV_ALT_1190082	3		Sin incidencias	t	
5636	139	Inv_alt_1190036	2		Sin incidencias	t	
5637	139	INV_ALT_1190085	1		Sin incidencias	t	
5638	139	INV_ALT_1190038	1		Sin incidencias	t	
5639	139	INV_ALT_1190039	1		Sin incidencias	t	
5640	139	INV_ALT_1190034	2		Sin incidencias	t	
5641	139	INV_VPRO_ALT_00151	1		Sin incidencias	t	
5642	139	INV_ALT_1190042	4		Sin incidencias	t	
5643	139	INV_ALT_1190044	1		Sin incidencias	t	
5644	139	INV_VPRO_ALT_00202	1		Sin incidencias	t	
5645	139	INV_ALT_1190045	3		Sin incidencias	t	
5646	139	INV_ALT_1190046	2		Sin incidencias	t	
5647	139	INV_ALT_1190047	3		Sin incidencias	t	
5227	136	INV_ALT_1190081	1		Sin incidencias	t	
\.


--
-- Data for Name: checkouts_maestro; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.checkouts_maestro (id_maestro, folio_op, id_empleado, fecha, hora, incidencias_generales, estado_bodega, nombre_kit) FROM stdin;
1	1	201	2026-08-13	13:44:28.509346-06	[PROVEEDOR_INCIDENTE: ELEVOX | NOTA: al inicio de la transmision se escuchaba doble como eco]	RECIBIDO	KIT_STD_EVENTOS_FUERA_DE_OFICINAS
20	9	119	2026-09-01	18:10:58.339591-06	Sin incidencias	RECIBIDO	KIT TEBACAS
19	9	202	2026-09-02	10:08:55.406408-06	Sin incidencias	RECIBIDO	TEBACAS
3	2	119	2026-08-28	10:07:29.611383-06	Las tarimas para camaras muy sencibles a cualquier movimiento.\nBatalle mucho el primer dia para mantener al centro de la toma al seguir a los expositores.	RECIBIDO	KIT 3 CAMARAS OK
4	2	202	2026-08-28	10:08:43.241762-06	Sin incidencias en zoom y transmisión.\nEs necesario adquirir un cable de 50mts (otro) para starlink.\nFalló el apuntador, hay que buscar uno que sea bluetooth o de mayor alcance	RECIBIDO	CESAVESIN en Mazatlán
5	2	104	2026-08-28	10:09:23.018554-06	Sin incidencias	RECIBIDO	Cesavesin Mazatlan Simposium
29	15	113	2026-09-08	10:15:50.445222-06	Sin incidencias	RECIBIDO	JAPAC
10	5	201	2026-08-28	10:15:40.642562-06	Al llegar al evento Se me reportó que falló servicio de internet, pero no podia saberlo hasta que llegara ya que me encontraba en el evento del enlace en gobno del edo.	RECIBIDO	Jornadas de paz basico
16	8	105	2026-08-28	13:18:51.072556-06	Sin incidencias	RECIBIDO	KIT LEY GRABACION
17	8	113	2026-08-28	13:21:49.23292-06	Sin incidencias	RECIBIDO	Grabacion LEY
14	8	104	2026-08-28	13:22:58.819901-06	Sin incidencias	RECIBIDO	--- Sin plantilla ---
15	8	109	2026-08-28	13:26:48.387898-06	Sin incidencias	RECIBIDO	KIT CESAVESIN
2	3	201	2026-08-19	18:00:49.517081-06	Sin incidencias	RECIBIDO	Jornadas de paz
9	6	201	2026-08-22	12:57:41.209153-06	Hubo problemas con el internet minutos antes de comenzar y aunque habia personal de gobno apoyando, no se soluciono y el evento se cancelo al llegar RRM	RECIBIDO	Kit_p_enlace_webex
6	2	109	2026-08-28	10:10:16.942722-06	Dia 1 (jueves)\n1.Al entrar el segundo segmento, entramos sin audio pues no se estaba monitoreando\n2.Dos botonazos\nDia 2 (viernes)\n1.Tres botonazos\nDia 3 (sábado)\n1.Cuatro botonazos	RECIBIDO	KIT CESAVESIN
8	6	113	2026-08-28	10:13:36.705363-06	A la hora de colocar el tripie para la camara se le cayo una pieza y se tuvo que ajustar con cinta gris.	RECIBIDO	Enlace Presidenta
7	4	201	2026-08-28	10:15:13.560463-06	Sin incidencias	RECIBIDO	Jornadas de paz
12	2	105	2026-08-25	19:24:06.359063-06	SIN INCIDENCIAS	PENDIENTE	--- Sin plantilla ---
26	11	201	2026-09-09	17:48:04.151596-06	Dia1.- En plena transmision llovió y se cortó el envío (srt) al Estudio, caso raro: Los equipos no se apagaron en el estudio, pero las páginas a las cuales se estaba transmitiendo se cortaron... No se apagó el modem ni la señal cambió de color(de rojo a naranja), pero en la transmisión de Fbook y Youtube hubo corte.\nDia3.- corté en la transmisión… Es muy probable que haya infuído el que le pasaron a Carlos en plena transmisión a los patrocinadores y al bajarlos en la pc del estudio haya provocado el corte(aparecieron 2 transmisiones en YTube), OJO: No es la primera vez que pasa eso en algún evento… pienso que se debió entregar esa información antes y así minimizar el riesgo.	PENDIENTE	Juegos Tebacas
23	11	202	2026-09-08	11:26:20.420443-06	- El día de juego 01 (04 de sept), hubo una fuerte lluvia y se cayó el servicio de internet starlink, a regañadientes nos prestaron el servicio de internet que tienen patrocinado a la arena Badiraguato, logrando salir con una cámara y el scoreboard. Ya que regresó el servicio de starlink, cambiamos a starlink y terminamos el juego con nuestro servicio de internet.\nHubo perdida de cuadros y audio en srt, debido a que estaban modificando el proyecto de vmix.\n- El día de juego 02 (05 de sept), Tratando de quitarle trabajo a la pc de deportes (estudio) se cambió para que solo enviara un srt a un equipo en el depto de sistemas (no fue la solución), tuvimos servicio starlink durante todo el partido. Se solicitó bajaran el volumen de audio en la transmisión ya que se escuchaba saturado (se solucionó).\n- El día de juego 03 (06 de sept), Debido a que el cliente solicitó se metieran patrocinios volvió a tener perdida de cuadros y audio el srt, ya que se tuvieron que hacer modificaciones en el proyecto usando gt, nadie estuvo monitoreando la transmisión de youtube, la cual tuvo una desconexión y se generó otro link. \n- Tuvimos problemas con los audios de los conductores, subía y bajaba el audio, en ocasiones entraba el audio cuando ya estaba hablando el conductor (no subía a tiempo el volumen)\n- El presidente de Badiraguato se comprometió a que usemos su internet cómo secundario.	RECIBIDO	TEBACAS
22	12	201	2026-09-03	17:44:07.840474-06	Sin incidencias	RECIBIDO	Jornadas de paz basico
13	8	119	2026-08-28	13:29:12.266136-06	Sin incidencias	RECIBIDO	KIT BASICO 3 CAMARAS
18	7	109	2026-08-28	14:42:30.494302-06	Sin incidencias	RECIBIDO	IEES VIRTUAL (Estudio VPro)
30	11	104	2026-09-08	17:46:36.754479-06	Dia Uno, Incidencia se fue la Luz, Se fue Internet y de todo un Poco.\nDia Dos, Sin Incidencia\nDia Tres, Incidencia se Escucha la Musica de la Computadora de Fondo no se encontro como quitarla.	PENDIENTE	--- Sin plantilla ---
11	7	202	2026-08-27	18:07:40.145083-06	Sin incidencias	RECIBIDO	IEES en estudio de Vpro
21	10	201	2026-09-08	18:41:29.227475-06	Sin incidencias	RECIBIDO	Jornadas de paz basico
28	15	105	2026-09-09	10:50:00.260882-06	Sin incidencias	RECIBIDO	JAPAC
34	11	113	2026-09-09	18:52:56.381247-06	En el juego del primer día hubo un error con el tamaño de los lowers que tapaban los nombres que se le ponían, también en en el juego dos hubo un error en meter el nombre del jugador de tebanas cuando estaba Miguel (conductor) al aire y también se cometió el error ortográfico de no colocar mayusculas sobre el lower del himno nacional.	PENDIENTE	--- Sin plantilla ---
33	17	201	2026-09-10	17:28:19.010231-06	Sin incidencias	RECIBIDO	Jornadas de paz
32	16	201	2026-09-09	17:46:33.38303-06	Sin incidencias	RECIBIDO	Jornadas de paz
24	13	201	2026-09-04	18:28:04.210289-06	Sin incidencias	RECIBIDO	Jornadas de paz basico
102	43	201	2026-10-24	10:50:37.561578-07	Se cortó la transmisión 2 veces en la pagina de Facebook, la situación se ha reportado a productores y direccion general.	PENDIENTE	Kit_en_Ofna_Estudio
27	14	104	2026-09-22	10:29:23.421077-07	Television de 65" Pantalla dañada	DESPACHADO	Reunion de gabinete
31	14	105	2026-10-05	12:28:28.261035-07	TV DAÑADA 65	DESPACHADO	--- Sin plantilla ---
107	45	107	2026-10-27	17:25:33.711378+00	No hubo incidencias en la grabación.	PENDIENTE	tablet
97	43	119	2026-10-26	19:06:32.527872+00	-En esta transmisión se nos generaron tres links en Facebook.\n-Hubo dos o tres bajones de internet, se noto el leve frezeo de cámaras.\n-Seguimos con detalles de audio.\n-Tuvimos detalles en gráficos, counter, pizarra.	RECIBIDO	JUEGO TEBACAS 16 DE OCTUBRE DE 2026
108	45	113	2026-10-27	17:29:54.965333+00	Sin incidencias reportadas.	RECIBIDO	Grabación
25	11	119	2026-09-09	18:58:27.970314-06	DIA 1 JUEGO TEBACAS VS FOHR DE HERMOSILLO\nLA SEÑAL DE SRT QUE ESTABA AL AIRE SE ESTABA DROPEANDO CUANDO MANIPULABAN LA COMPUTADORA EN ESTUIO\nEN LA COMINICACION DE CAMAROGRAFOS, SE ESCUCHABA MAS FUERTE EL CONDUCTOR QUE ESTABA EN ARENA QUE EL SWITCHER EN ESTUDIO\nPEGO UN LLOVIDON, SE FUERON LAS DOS ESTARLINK, SE NOS CORTO LA TRANMISION, ESTO PASO CASI AL FINALIZAR EL SEGUNDO CUARTO, REGRESAMOS CASI AL FINAL DE EL TERCER CUARTO\nSE CONSIGUIO EL INTERNET DE EL RECINTO, SE TIRO UN CABLE, PARA PODER SACAR LA TRANSMISION., NO QUERIAN FUNCIONAR LOS 4 ENCODERS, NOS FUIMOS CON DOS, CAMARA 1 Y LA DEL OCR\nEN ESTUDIO SE METIO UN LOOP, NUNCA METIERON AL CONDUCTOR A CUADRO.\nAL FINALIZAR EL 3ER CUARTO REGRESO UNA STARLINK, SE HIZO EL CAMBIO Y CON ESA SALIMOS.\nAL FINALIZAR EL CUARTO CUARTO, SE FUE LA LUZ EN ESTUDIO,  REGRESAMOS CON LA ENTREVISTA DEL PRESIDENTE JOSE PAZ\nCONDUCTOR NO TENIA COMUNICACION CON ESTUDIO\nAL ESTAR AL AIRE CON LA ENTREVISTA, MARTHA ROQUE DE COMUNICACION, ME DECIA QUE NO ESTABAMOS AL AIRE, SE PIDIO EVIDENCIA A ESTUDIO, PARA COMPROBARLE QUE SI ESTABMOS AL AIRE.\nPRIMER ZOOM QUE HICE AL PRESIDENTE, ESTABA FUERA DE FOCO.\nCUANDO MIGUEL EL CONDUCTOR EMPEZO A HABLAR, LE PUSIERON EL SUPER DE EL PRESIDENTE.\nEL JUEGO QUEDO EN DOS PARTES EN YOUTUBE.\nHI SPORTS CORTO SU TRANSMISION, TVP REGRESO CON LA TRANSMISION\nGRACIAS A DIOS, SACAMOS EL JUEGO, SALIO LA ENTREVISTA.\nCONSEGUIMOS CUARTOS PARA LA PRODUCCION PARA DORMIR, ESTABAN EN MUY MALAS CONDICIONES Y SIN AIRE ACONDICIONADO\nTRATAMOS DE COMUNICAR CON EL ENCARGADO DE PROYECTOS ESTRATEGICOS DE BADIRAGUATO PARA VER LO DE EL INTERNET, NO SE LOCALIZO\nEL PRESIDENTE JOSE PAZ, PIDIO QUE SE QUEDARA EL CONDUCTOR UN DIA MAS., SE PIDIO LA AUTORIZACION Y SE ACEPTO\nGRABACION DEL PRIMER DIA EN IMPERDEC, SE GRABO SIN AUDIO AL PRINCIPIO.\n\nDIA 2: TEBACAS VS CORAS DE XALISCO\nENTRADA 3PLAY SATURADA\nENTRADA SE VA ANEGROS ANTES DE DRON( YA SE CHECO CON ENGARGADO)\nENTRO SATURADO AUDIO DE CONDUCTOR EN ESTUDIO\nNO ES CORRECTO COMO ESTAN PONIENDO LOS SUPERS A LOS INVITADOS\n\nDIA 3 TEBACAS VS AGAVEROS DE TEQUILA\nSATURADO AUDIO DE ENESTO, MIGUEL BAJO EL AUDIO\nMUUY INDESISOS CONDUCTORES, PARA MANDAR EL HIMNO, QUE SI, QUE NO\nAL INICIO D EL JUEGO, CAMAROGRAFO CAMARA UNO, ESTABA DESUBICADO\nSE METIO A LA TRASMISION AUDIO DE MIGUEL, ASIENDO PRUEBAS\nDESPUES ENTRO AUDIO DE MIGUEL TRONADO\nSIGUIO FALLANDO LA COMPUTADOORA DE TRANSMISION AL MANIPULAR. (GT)\nEL PRESIDENTE JOSE PAZ, ME ABORDO QUE QUERIA QUE ENTRARAN LOS PATROCINADORES DE TEBACAS, QUE TENIAN QUE ENTRAR EN ESTE JUEGO, SI SI O SI.\nNOS APOYO LUPITA DE PRESIDENCIA, Y SE PUDIERON METER LOS PATROCINADORES APARTIR DE EL TERCER CUARTO, GRACIAS TAMBIEN A LA GENTE EN ESTUDIO\nSE CORTO LA TRANSMISION EN ESTUDIO\nEL JUEGO QUEDO EN DOS PARTES EN YOUTUBE\n\nSE FUE EL AUDIO DE CONDUCTOR EN ESTUDIO, ENTRO A NARRAR CONDUCTOR EN ARENA. (SE PENSO QUE ERAN BATERIAS, PERO NO)\nALGUNOS DETALLES DE ORTOGRAFIA (YA SE HABLO CON LA PERSONA ENCARGADA)	RECIBIDO	KIT TEBACAS
35	18	201	2026-09-11	19:32:51.481852-06	Sin incidencias	RECIBIDO	Jornadas de paz
36	11	109	2026-09-12	11:24:38.60104-06	Dia 1\n*4 Botonazos\n*Detalles de audio\n*Falla de internet durante aprox un cuarto y medio del juego\n\nDia 2 \n*Detalles de audio\n\nDia 3\n\n*4 Botonazos\n*Al empezar se fue un micro, despues de buscar todas las opciones era problema de volúmen, algunos otros detalles más en el audio (en un corte no entro el audio etc)\n*Hubo fallas intermitentes en el Internet, muy leves para cortar la transmisión pero si se notó con imagen "rayada"\n*Hubo un camarazo (cam 3) y en una ocación se perdió la cámara (cam 1)	PENDIENTE	--- Sin plantilla ---
38	19	202	2026-09-17	14:25:03.453272-06	- Fallo en la planta de energía de un tercero, provocó variaciones en voltaje, lo cual provocó que el no-break tuviera poca carga.\n- Al cambiar de planta (y debido a la carga de consumo del no-break) se apagaron los equipos conectados al no-break, lo cual ocasionó daño en el archivo (grabación) en el vmix y en el 3play.	RECIBIDO	Grito de independencia 2026
40	19	201	2026-09-17	15:10:35.123605-06	Tuvimos variaciones en la corriente por parte de la planta de energia... Debido a fallas en el suministro de la planta de energia, en un espacio de la cantante se hizo el cambio de planta lo cual provocó que se apagara todo el equipo de produccion ya que fué demasiado el consumo para la capacidad del UPS: NOTA: Ese mismo dia se nos solicitó un servicio via zoom: gobernadora - Canal 11. como a las 13:00 hrs.	RECIBIDO	Kit_grito
42	19	105	2026-09-17	18:11:45.925195-06	-PROBLEMAS EN LA COMUNICACION (SE CORTABA) \n-APAGON DE PLANTA	RECIBIDO	Grito de independecia
37	19	119	2026-09-17	18:54:56.975885-06	LA COMUNICACION PARA CAMAROGRAFOS MUY MALA, SE CORTO TODO EL TIEMPO.\nTARIMAS MUCHO MEJOR QUE EN OTRAS OCACIONES, PERO SI SE OCUPAN DOS POR CAMARA. (MAS PARA ESTE TIPO DE EVENTOS)\nFALLARON CABLES SDI DE CAMARAS	RECIBIDO	DIA DEL GRITO
43	15	102	2026-09-18	13:13:14.148566-06	Sin incidencias	PENDIENTE	--- Sin plantilla ---
44	8	102	2026-09-18	13:16:07.653014-06	Sin incidencias	PENDIENTE	--- Sin plantilla ---
39	19	104	2026-09-17	12:49:27.589433-06	Sin incidencias	RECIBIDO	Dia del grito
41	19	109	2026-09-17	13:23:15.297602-06	Sin incidencias	RECIBIDO	Grito de la independencia
53	25	202	2026-10-05	12:07:12.616199-07	- Debido a lluvias en el primer tiempo no tuvimos internet mediante las antenas starlink, salimos a una cámara utilizando el servicio de internet que nos proporciona la arena.\n- Falló el cople que se usa con el cable de red en el switch del control room en el estudio de vpro, esto ocasionó que tuviera una velocidad de 100mb el equipo de transmisión. Se solucionó poniendo un cable de red desde sistemas al switch en el control room (esto fue antes de iniciar transmisión).	RECIBIDO	TEBACAS BADIRAGUATO
56	25	105	2026-10-05	12:26:22.771854-07	FALLO DE CAMARAS E INTERNET POR MOTIVOS DE LLUVIA	PENDIENTE	--- Sin plantilla ---
46	20	109	2026-09-22	10:30:27.658189-07	Sin incidencias	RECIBIDO	Evento Presidenta
45	20	104	2026-09-22	11:30:45.508128-07	Sin incidencias	RECIBIDO	Evento presidenta
57	26	104	2026-10-05	16:16:25.463643-07	Sin incidencias..	RECIBIDO	CREE
59	26	109	2026-10-05	16:16:48.214687-07	Sin incidencias.	RECIBIDO	CREE
47	22	201	2026-10-01	17:32:26.839625-07	Sin incidencias	RECIBIDO	Jornadas de paz
101	43	105	2026-10-24	10:44:47.341076-07	Sin incidencias	PENDIENTE	--- Sin plantilla ---
48	23	201	2026-10-01	17:32:57.449362-07	Sin incidencias	RECIBIDO	Jornadas de paz basico
54	25	113	2026-10-05	10:24:06.076337-07	-Hubo problemas de conexión al inicio del partido, por lo que no metí el Cody de marcador hasta que se restableció el internet. \n-Me falto acomodar los lowers para la doble caja	PENDIENTE	--- Sin plantilla ---
58	25	104	2026-10-05	14:07:51.327196-07	corte de internet por lluvia en badiraguato	DESPACHADO	--- Sin plantilla ---
55	25	201	2026-10-05	12:10:11.671106-07	Al revisar la velocidadad de interenet apareció que solo teníamos un maximo de 100Mb de bajada y 100Mb de subida por lo que se procedió a cambiar los cables del  switch a la pc (3 cables cortos), se reportó a MegaCable y se nos hizo un ticket de servicio(del sabado para caambio fisico el lunes) por lo que se procedió a colocar un cable directo del swith de sistemas  al switch del Estudio y de ahi a la pc(y asi se restablecio el servicio de 1 Gb. Por rporte de lluvia hubo interferencia en la rtansmision de las camaras por lo que se anunció en las paginas de Vpro lo sucedido pero la señal no se cortó.	DESPACHADO	kit_en_ofna
49	21	202	2026-10-01	17:59:59.024246-07	Sin incidencias	RECIBIDO	IEES en estudio de Vpro
51	21	109	2026-10-02	09:12:15.723267-07	Sin incidencias	RECIBIDO	IEES VIRTUAL (Estudio VPro)
79	29	113	2026-10-14	10:42:36.122417-07	Detalles en el audio.	RECIBIDO	--- Sin plantilla ---
71	30	201	2026-10-12	09:48:40.239692-07	Sin incidencias., pero no se llevo a cabo al hacer pruebas notificaron que Sinaloa no participaría.	RECIBIDO	Kit_p_enlace_webex
105	43	113	2026-10-27	17:24:17.753382+00	Sin incidencias reportadas.	RECIBIDO	Tebacas
109	45	200	2026-10-27	17:30:28.125847+00	Sin incidencias	PENDIENTE	Kit edición Andrea
110	46	202	2026-10-29	21:37:10.673993+00	Sin incidencias reportadas.	RECIBIDO	IEES en estudio de Vpro
50	24	201	2026-10-31	01:58:41.405078+00	Sin incidencias	RECIBIDO	Jornadas de paz basico
113	48	202	2026-11-06	16:05:44.627956+00	Sin incidencias en srt de cámaras	RECIBIDO	TEBACAS BADIRAGUATO
65	29	119	2026-10-14	10:43:10.972099-07	AL CORRER ENTRADA, NO SE METIO, SOLO EL AUDIO Y AL FINAL DE LA MISMA SOLO UN PEDASO\nVARIAS VECES CONDUCTORES DE ESTUDIO MANDARON A NETILLO EN ARENA, ENTRABA MOCHO\nVARIAS VECES NETILLO ENTRABA SIN QUE LO MANDARAN.( YA SE HABLO CON EL)\nVARIAS VECES AL CORRER PATROCINADORES ENTRABA CODY, Y LUEGO PÁTROCINADOPRES OTRA VEZ\nTODO EL PRIMER PERIODO SE ESCUCHO MUSICA DE FONDO\n1ER CORTE ENTRO TARDE AUDIO DE BLOQUE COMERCIAL ( QUE POR CIERTO SE ESCUCHA MAL DE ORIGEN)\nCAMAROGRAFO DE ARENA SE LE FUERON VARIAS JUGADAS....(SIEMPRE SE ESCUCHO MANDO)\nNO SE PUDO METER AUDIO AMBIENTAL AL 3PLAY (CUANDO YA SE HABIA CHECADO UN DIA ANTES)\nPOCAS PERP SE SIGUEN ESCUCHANDO VOCES DE LA PRODUCCION\nAL TERMINAR HIMNO NACIONAL, NO SE MANDO A CONDUCTORES, ENTRO MUSICA, AMBIENTE, RECHINIDO  DE SILLAS, TARDARON EN ENTRAR.\nHUBO DOS JUGADAS MEDIO RARAS (PARA ANALIZAR)\nAL FINALIZAR, CUNDUCTOR COMO QUE NO SE HABIA ACOMODADO Y ENTRO AL AIRE MOVIENDOSE\nENTREVISTAS AL FINAL, FALTO ILUMINACION. (O IRIS)	RECIBIDO	KIT TEBACAS OK OCTUBRE 2026
89	37	105	2026-10-16	10:23:05.702066-07	Sin incidencias	RECIBIDO	Kit del dany
75	30	109	2026-10-12	09:53:29.916642-07	Falto un adaptador display pord a hdmi, ya habia sido solicitado	RECIBIDO	CREE
52	25	119	2026-10-14	10:48:21.074131-07	NO ENTRAMOS A TIEMPO, CUANDO YA SE ESTABA ACORDADO ENTRAR A LAS 19:55\nPOR 4TA OCACION PONEN HIMNO NACIONAL MAS, (nACIONAL)\nANTES DE INICIAR EL PARTIDO SE CORTO LA SEÑAL DE CAMARAS (SE FUERON LAS STARLINK)\nTARADAMOS 10 MINUTOS EN REGRESAR \nSE FUERON DOS REPETICIONES CON AUDIO DE NARRACION\nNO MANDARON EL PRIMER CORTE AL FINAL DEL PRIMER PERIODO\nTODO EL PRIMER PERIODO SE LE PUSO EN EL MARCADOR SEGUNDO PERIODO\nMETIERON A CONDUCTORES A CUADRO SIN FONDO EN LA PANTALLA\nTODO EL JUEGO ESTUVO MUY ALTO EL AMBIENTE, SE ESCUCHABA MUY ALTA LA MUSICA DE LA ARENA\nSE PERDIO LA COMUNICACION DE CONDUCTOR Y CAMARAS\nEL GBRAFICO DE RESUMEN DE MEDIO TIEMPO MUY ENSIMADO\nNOS GANO EL REGRESO PARA EL CUARTO PERIODO ( 15 SEGUNDOS YA EMPEZADO)\nCUANDO SE CORRIO EL ROL OUT SALIO AUDIO DE CONDUCTOR\nFALLAS DEL CRONOMETRO (POR ILUMINACION EN LA ARENA)\nEN PLENO JUEGO, EN UN DESCANSO, HABIENDO NARRACION SE ESCUCHABA MUSICA DE FONDO	RECIBIDO	KIT TEBACAS 2026
69	29	105	2026-10-14	10:43:24.224392-07	Sin incidencias	RECIBIDO	--- Sin plantilla ---
61	25	109	2026-10-05	16:34:32.14987-07	Falla de comunicación.\nSe cortaba el internet.	DESPACHADO	CIBACOPA
72	30	104	2026-10-12	09:58:02.837644-07	Sin incidencias.	RECIBIDO	--- Sin plantilla ---
63	28	104	2026-10-12	09:58:26.144441-07	Sin incidencias.	RECIBIDO	Escuinapa
73	29	104	2026-10-14	10:43:36.590738-07	Sin incidencias.	RECIBIDO	--- Sin plantilla ---
60	27	109	2026-10-10	09:09:20.41695-07	Sin incidencias	RECIBIDO	CREE
66	28	109	2026-10-12	09:58:45.21946-07	Sin incidencias	RECIBIDO	CREE
62	27	104	2026-10-12	09:27:49.62607-07	Sin incidencias.	DESPACHADO	CREE
76	29	109	2026-10-14	10:43:48.081972-07	Detalles en el audio y 3 botonazos	RECIBIDO	--- Sin plantilla ---
77	33	201	2026-10-14	16:52:27.468309-07	No regreso la extensión, no la encontré al subir, revise dos veces la ubicacion done trabajé.	RECIBIDO	Jornadas de paz basico
74	29	201	2026-10-14	10:44:09.85136-07	Al inicio del streaming., estaba el Loop cuando se cortó la transmision de Facebook, pero sola se reinició.	RECIBIDO	Juegos Tebacas
64	29	202	2026-10-13	16:15:10.879183-07	Sin incidencias	RECIBIDO	TEBACAS BADIRAGUATO
70	30	105	2026-10-14	10:44:41.114411-07	Sin incidencias	RECIBIDO	ENLACE PRESIDENTA
80	30	107	2026-10-14	10:44:52.603902-07	Sin incidencias	RECIBIDO	--- Sin plantilla ---
84	32	119	2026-10-19	13:18:37.106882-07	SE SIGUE ESCUCHANDO LA VOZ DE LA PRODUCCION EN  LA TRANSMISION (PUERTA ABIERTA)\nSUPERS DE CONDUCTORES ESTA DIFERENTE EL LOGO\nNO SUPIMOS QUE ROLLO CON LA TRANSMISION DE HI SPORTS (NO SE NOS CONFIRMO)\nCONDUCTORES A CUADRO HABLANDO, SE ESCUCHA AMBIENTYE Y MUSICA A LA VEZ\nOTRA VEZ MUSICA DE FONDO, UNA PARTE DEL PRIMER PERIODO\nMAL CODY, SE PUSO EQUIPO DEL ROSARIO EN LUGAR DE LA PALMA\nNO SIRVIO MI COMUNICACION CON LA PRODUCCION, SE ESCUCHABA MAL MI MICROFONO\nNO NOS RESPETARON LOS 3 MINUTOS DE TIEMPO EN EL PRIMER CORTE, ENTRAMOS AL SEGUNDO PERIODO YA COMENZADO EL JUEGO\nJUEZ CAMBIA MUY RAPIDO PIZARRA, NO DA TIEMPO EN SACARLA.\nFACEBOK POR SEGUNDA OCACION CONSECUTIVA, CREO UN SEGUNDO LINK\nEN EL CUARTO PERIODO REGRESAMOS CON TERCER PERIODO EN MARCADOR\nCAMAROGRAFO ESTUVO APRETANDO MUCHO TOMA, EN OCACIONES NO SE MIRABA LA BOLA.	RECIBIDO	JUEGO TEBACAS 16 DE OCTUBRE DE 2026
99	44	113	2026-10-23	18:43:19.827539-07	Sin incidencias	RECIBIDO	Grabación
100	43	104	2026-10-24	10:39:02.391376-07	Sin incidencias...	PENDIENTE	--- Sin plantilla ---
90	37	113	2026-10-16	10:24:44.69097-07	Sin incidencias	RECIBIDO	Grabación
68	28	105	2026-10-12	09:21:36.88942-07	Sin incidencias	DESPACHADO	--- Sin plantilla ---
83	36	113	2026-10-15	09:38:33.5921-07	Sin incidencias.	DESPACHADO	Imagen y toma de aspectos
82	31	113	2026-10-15	09:39:00.39875-07	Sin incidencias.	RECIBIDO	Imagen y toma de aspectos
67	27	105	2026-10-12	09:21:18.638078-07	Sin incidencias	DESPACHADO	--- Sin plantilla ---
85	35	109	2026-10-15	10:42:08.414801-07	Sin incidencias	DESPACHADO	Kit de estudio
86	38	201	2026-10-16	16:19:24.590678-07	Sin incidencias	RECIBIDO	Jornadas de paz basico
81	34	201	2026-10-15	16:40:44.509129-07	Sin incidencias	RECIBIDO	Jornadas de paz basico
94	32	104	2026-10-17	11:53:45.815534-07	Sin incidencias...	PENDIENTE	--- Sin plantilla ---
78	32	113	2026-10-17	13:38:53.088421-07	Me toco monitorear el rendimiento de Daniel ya que me cubrirá dos partidos a final de mes, tuvo algunos errores pero es por la inexistencia y se tienen que pulir para los próximos juegos	RECIBIDO	Tebacas
91	37	102	2026-10-16	10:20:32.167979-07	Sin incidencias	RECIBIDO	--- Sin plantilla ---
95	32	105	2026-10-19	09:24:51.887165-07	Sin incidencias	PENDIENTE	--- Sin plantilla ---
93	32	201	2026-10-17	11:55:06.416311-07	Al inicio del streaming a las plataformas Facebook y youtube hubo una caida de la pagina de facebook solamente, generando otra url, pero se recupero la señal rapidamente.(fue antes del pitazo de inicio del partido.)	RECIBIDO	Kit_en_Ofna_Estudio
88	32	202	2026-10-19	09:27:58.313638-07	- Sin incidencias en envío de srt a oficina de vpro	RECIBIDO	TEBACAS BADIRAGUATO
96	32	109	2026-10-19	10:17:59.24798-07	Detalles en el audio, 2 botonazos, intermitencia en la conexion con facebook	PENDIENTE	--- Sin plantilla ---
87	35	202	2026-10-30	16:46:47.139196+00	Sin incidencias reportadas.	RECIBIDO	IEES en estudio de Vpro
106	45	105	2026-10-27	17:27:38.263364+00	bateria sony bloqueada	PENDIENTE	--- Sin plantilla ---
115	49	201	2026-11-03	22:20:32.911715+00	Sin incidencias reportadas.	RECIBIDO	Kit_p_enlace_webex
117	49	104	2026-11-05	16:17:21.547088+00	Sin incidencias reportadas..	RECIBIDO	CREE
114	48	201	2026-11-05	23:52:11.228259+00	Sin incidencias reportadas.	RECIBIDO	Juegos Tebacas
112	48	109	2026-11-06	01:58:28.911006+00	Detalles en el audio\nparpadeo de camaras en dos momentos	RECIBIDO	TEBACAS ESTUDIO
141	56	202	2026-11-18	23:36:49.535584+00	📅 [13/Nov - Instalación / Evento]:\nSin incidencias reportadas.\n\n📅 [14/Nov - Evento]:\nSin incidencias reportadas.\n\n📅 [15/Nov - Cierre / Retorno]:\nSin incidencias reportadas.	RECIBIDO	TEBACAS BADIRAGUATO
135	50	104	2026-11-12	23:14:36.322256+00	Sin incidencias reportadas.	RECIBIDO	IESS 12/nov/2026
136	50	105	2026-11-12	23:20:24.922579+00	Sin incidencias reportadas.	RECIBIDO	iees 2
116	49	105	2026-11-03	20:49:09.036464+00	Sin incidencias reportadas.	RECIBIDO	iees
118	49	109	2026-11-03	20:49:41.396903+00	Sin incidencias reportadas.	RECIBIDO	IEES PRESENCIAL
119	48	104	2026-11-05	23:25:49.117167+00	Sin incidencias	RECIBIDO	Kit Diario
144	56	109	2026-11-18	23:35:09.065292+00	📅 [13/Nov - Instalación / Evento]:\n1-   2 botonazos\n2-  detalles en el audio\n3.   una de las señales de transmision estuvo intermitente, no se si se corto en algun momento\n4-  apagaron la camara uno (que es la que trae el audio) y se corto el audio durante la entrevista final\n\n📅 [14/Nov - Evento]:\n1-   2 botonazos\n2-  detalles en el audio\n3.   una de las señales de transmision estuvo intermitente, no se si se corto en algun momento\n4-  la camara 3 se apago momentaneamente estando al aire\n\n📅 [15/Nov - Cierre / Retorno]:\n.....\n\n🛣️ [LOGÍSTICA Y TRASLADO]:\nSin incidencia	RECIBIDO	TEBACAS ESTUDIO
140	56	201	2026-11-17	23:29:52.571827+00	📅 [13/Nov - Instalación / Evento]:\nSin incidencias reportadas.\n\n📅 [14/Nov - Evento]:\nSe corto y se reinició dos veces la transmision a la pagina de facebook YTube ok.\n\n📅 [15/Nov - Cierre / Retorno]:\nSin incidencias reportadas.	RECIBIDO	Juegos Tebacas
98	43	202	2026-11-06	16:05:21.650481+00	- Se reinició la antena starlink02, lo cual ocasionó que se desconectaran las cámaras, esto ocurrió  antes de regresar del medio tiempo	RECIBIDO	TEBACAS BADIRAGUATO
120	48	105	2026-11-06	16:08:16.436296+00	Sin incidencias reportadas	RECIBIDO	--- Sin plantilla ---
111	48	119	2026-11-06	20:26:35.380677+00	CONDUCTOR MIGUEL LARA NO LLEGO A TIEMPO A ESTUDIO, ENTRO HASTA EL SEGUNDO PERIODO, EN EL PRIMER JUEGO\n3PLAY SE GRABO MEZCLADO CON MUSICA\nEN EL PRIMER JUEGO SE VE MAL CROMADO CONDUCTOR EN ESTUDIO (PERFORA)\nNO NOS ESTAN DANDO LOS 3 MINUTOS ACORDADOS EN EL PRIMR DSCANSO EN ARENA\nPRIMER JUEGO DOS ELENEMNTOS DE PROTECCION CIVIL ESTORBABAN MUCHO EN LA TOMA DE PROTECCION (AMARILLOS)	RECIBIDO	KIT TEBACAS SEMIFINALES
131	50	109	2026-11-17	20:04:42.576491+00	📅 [12/Nov - Evento]:\nSin incidencias reportadas.	RECIBIDO	IEES PRESENCIAL
122	51	105	2026-11-07	16:23:36.173477+00	Sin incidencias.	RECIBIDO	Asistente
121	51	104	2026-11-07	16:30:42.656612+00	Sin incidencias reportadas...	RECIBIDO	CREE
128	52	104	2026-11-11	17:34:00.334621+00	Pantalla de 65"\nse incho el Cristal de la Pantalla por el Sol,\nse despego.\nSAMSUNG DE 65"	RECIBIDO	Instalación Rueda de Prensa Harfuch
133	50	202	2026-11-13	00:01:34.934632+00	Sin incidencias en transmisión.	RECIBIDO	IEES Presencial
143	56	104	2026-11-17	23:30:10.762683+00	📅 [13/Nov - Instalación / Evento]:\naudio se corto durante transmision, se aoago un equipo en la arena tebekas\n\n📅 [14/Nov - Evento]:\nsin incidencia...\n\n📅 [15/Nov - Cierre / Retorno]:\nsin incidencia...	RECIBIDO	--- Sin plantilla ---
138	55	104	2026-11-17	23:32:15.069693+00	📅 [12/Nov - Instalación / Evento]:\nsin incidencias...\n\n📅 [13/Nov - Cierre / Retorno]:\nsin incidencias...	RECIBIDO	Kit Diario
132	53	113	2026-11-17	23:18:00.9561+00	📅 [08/Nov - Instalación]:\nEvento concluido sin incidencias.\n\n📅 [09/Nov - Evento]:\nEvento concluido sin incidencias.	RECIBIDO	--- Sin plantilla ---
129	53	109	2026-11-17	23:18:30.92846+00	📅 [08/Nov - Instalación]:\nsin incidencias.\n\n📅 [09/Nov - Evento]:\nBotonazo (shift)\n2camarazos\nlos usb de la computadora vmix dieron conflicto, cambie las cajas  usb, el stream deck no jalo y el panel antes del evento estuvo intermitente	RECIBIDO	HARFUSH MAZ
130	53	105	2026-11-17	23:18:48.05227+00	📅 [08/Nov - Instalación]:\nSin incidencias\n\n📅 [09/Nov - Evento]:\nolvide ponerme en filtro 3, foco	RECIBIDO	--- Sin plantilla ---
142	55	109	2026-11-17	23:56:38.914225+00	📅 [12/Nov - Instalación / Evento]:\nSin incidencias\n\n📅 [13/Nov - Cierre / Retorno]:\nSin incidencias	RECIBIDO	Fiscalia
123	53	119	2026-11-17	23:44:57.670391+00	📅 [08/Nov - Instalación]:\nSin incidencias\n\n📅 [09/Nov - Evento]:\nDOS VECES NOS MOVIERON LA TARIMA DONDE VA MONTADA LA CAMARA, UN FOTOGRAFO DE HARFUCH, SE LE DIJO QUE TUVIERA CUIDADO.\nESCUCHE QUE UNA CAMARA DE MIRABA MAL (CAMARA 3), AL CHECRALA OTRO DIA SE VE RARA	RECIBIDO	KIT 3 CAMARAS OK
137	54	113	2026-11-17	23:46:56.572231+00	📅 [12/Nov - Evento]:\nSin incidencias	RECIBIDO	Kit Grabaciones
134	50	119	2026-11-13	18:58:43.805184+00	MUCHA GENTE SE METIA EN LA TOMA DE LA CAMARA 4 (GO PRO)\nEN CAMARA 2 CADA VEZ QUE TOMABAN PROTESTA ME TAPABAN	RECIBIDO	KIT 2 CAMARA OK
126	53	201	2026-11-17	23:45:31.253309+00	📅 [08/Nov - Instalación]:\nSin incidencias reportadas.\n\n📅 [09/Nov - Evento]:\nSin incidencias reportadas.	RECIBIDO	KIT_STD_EVENTOS_FUERA_DE_OFICINA
146	53	104	2026-11-17	23:46:37.834151+00	📅 [08/Nov - Instalación]:\nSin incidencias\n\n📅 [09/Nov - Evento]:\nDaño en una pantalla	RECIBIDO	Instalacion Rueda de Prensa Harfuch
147	55	105	2026-11-18	00:07:35.524413+00	📅 [12/Nov - Instalación / Evento]:\nSIN INCIDENCIAS\n\n📅 [13/Nov - Cierre / Retorno]:\nSIN INCIDENCIAS	RECIBIDO	kit del dany
145	56	113	2026-11-18	23:35:18.23545+00	📅 [13/Nov - Instalación / Evento]:\nSin incidencias reportadas.\n\n📅 [14/Nov - Evento]:\nSin incidencias reportadas.\n\n📅 [15/Nov - Cierre / Retorno]:\nSin incidencias reportadas.\n\n🛣️ [LOGÍSTICA Y TRASLADO]:\nsin incidencias	RECIBIDO	Tebacas
139	56	119	2026-11-18	23:36:10.329935+00	📅 [13/Nov - Instalación / Evento]:\nAntes de arrancar la transmisión se reporto bajón de internet \nse corto el Link de Facebook\nbotonazo en doble caja al inicio, entro estudio cuando era conductor en arena\nse reporta en el chat de VPRO estaba tronado\nmuy corto el tiempo, al final del primer periodo, se tuvo que bajar a la cancha para que no arrancara el juego\nen el segundo periodo, se empalmaron audios de conductores\npor error de mio al final del juego pedí se apagara cámara 1, ya que estábamos en entrevista y la intensión era que se quedara la cámara de beuty, olvidando que era cámara que llevaba el audio. (fuero alrededor de 12 segundos), nos pidieron que saliéramos pronto de arena ya que tenían evento ellos.\nse volvió a cortar audio, casi al final al rededor de 10 segundos\nMiguel el doble caja pajarea mucho\nse subió conductor al palco de transmisión para que narrara, movía mucho el micrófono se escuchaba mal el audio\nestaba narrando conductor en arena (muchas pausas) y entre conductor de estudio sin  que se callara el de arena, se empalmaron los audios\ndespués de aser pase de entrada, se estaba acomodando conducto en arena cuando lo mandaron, no hable, se estaba acomodando\nllevaba puras baterias recicladas me las vi negras (apuros)\n\n📅 [14/Nov - Evento]:\nNuevamente se corto link de transmisión de Facebook.\nDe ultima hora cambie el guion de producción ya que estaban tardando  mucho para salir a la cancha jugadores resumen)\nHasta el segundo juego HI SPORTS confirmo que si habían transmitido.\nen varias ocasiones trono el micrófono de conductor en arena (baterías reusadas)\nnos cuatropeamos casi al final del 3er periodo, se termino tiempo entablero pero marcaron un faul, dentro del tiempo, ellos no lo pudieron regresar, marcaba 4to periodo en el 3er periodo.\ncasi al final del mismo 3er periodo mandamos a corte pensando que ya había terminado, fuimos acortes, se reanudo juego, y ya había empezado, pedí cortaran el bloque comercial, tardamos mucho, ya que regresamos se había terminado ahora si el juego, ya nos quedamos\nhubo una jugada polémica casi al final del juego, nunca metimos repetición, cuando la pidieron los dos conductores\n\n📅 [15/Nov - Cierre / Retorno]:\nNo llegaron a tiempo los encargados de arena, aprovechamos para ir a desayunar	RECIBIDO	KIT TEBACAS FINAL
149	57	104	2026-11-19	20:06:17.65018+00	📅 [19/Nov - Evento]:\nSin incidencias	RECIBIDO	Kit Diario
148	57	105	2026-11-19	20:07:11.206291+00	📅 [19/Nov - Evento]:\nSin incidencias	RECIBIDO	kit del dany
150	173	109	2026-11-23	18:14:44.249483+00		PENDIENTE	Harfush Culiacan
151	173	201	2026-11-23	18:59:03.946503+00		PENDIENTE	KIT_STD_EVENTOS_SSPC
152	173	119	2026-11-23	19:29:11.448485+00	📅 [23/Nov - Instalación / Evento]:\n[ES NECESARIO REPORTAR INCIDENCIAS]\n\n📅 [24/Nov - Cierre / Retorno]:\n[ES NECESARIO REPORTAR INCIDENCIAS]	PENDIENTE	KIT EVENTO ESPECIAL 3 CAMARAS
\.


--
-- Data for Name: cronogramas_eventos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cronogramas_eventos (id_cronograma, folio, fecha, nombre_evento, ubicacion_general, folio_op, actividades, observaciones_generales, creado_por, fecha_creacion) FROM stdin;
2	03	2026-10-28	Sesion extraordinaria IEES virtual y especial	Estudio Vpro	46	[{"evento": "Llamado", "horario": "09:00 a. m.", "vehiculo": "", "actividad": "Entrada a oficina", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández y Edgar Amarillas"}, {"evento": "Pruebas", "horario": "De 9:00 a 11:00", "vehiculo": "", "actividad": "Pruebas de streaming", "ubicacion": "Estudio Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández y Edgar Amarillas"}, {"evento": "Streaming", "horario": "De 11:00 a 14:00", "vehiculo": "", "actividad": "Transmisión vía zoom", "ubicacion": "Estudio Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández y Edgar Amarillas"}, {"evento": "Corte a comer", "horario": "De 14:00 a 16:00", "vehiculo": "", "actividad": "Descanso", "ubicacion": "Descanso", "observaciones": "", "personal_convocado": "Osiel Hernández y Edgar Amarillas"}, {"evento": "Guardar equipo", "horario": "De 16:00 a 17:00", "vehiculo": "", "actividad": "Levantamiento de equipo", "ubicacion": "Estudio Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández y Edgar Amarillas"}, {"evento": "Check Out", "horario": "De 17:00 a 18:00", "vehiculo": "", "actividad": "Registrar incidencias", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández y Edgar Amarillas"}, {"evento": "Realizar actividades", "horario": "De 18:00 a 19:00", "vehiculo": "", "actividad": "Actividades Pendientes", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández y Edgar Amarillas"}, {"evento": "Termino de actividades", "horario": "07:00 p. m.", "vehiculo": "", "actividad": "Salida de oficina", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández y Edgar Amarillas"}]	Jornada previa: Carga de equipo, traslado, instalación y ensayos de protocolo.	Admin VPRO	2026-10-27 18:51:05.205556
1	02	2026-10-22	TEBACAS VS TITANES	Arena Badiraguato	43	[{"evento": "Llamado", "horario": "09:00 a. m.", "vehiculo": "H100", "actividad": "Entrada a oficina", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar amarillas y Carlos Calixto"}, {"evento": "Combustible", "horario": "De 9:30 a 9:45", "vehiculo": "H100", "actividad": "Cargar combustible", "ubicacion": "Gasolinera", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar amarillas y Carlos Calixto"}, {"evento": "Proviciones", "horario": "De 9:45 a 10:00", "vehiculo": "H100", "actividad": "Comprar bebidas hidratantes", "ubicacion": "Oxxo", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar amarillas y Carlos Calixto"}, {"evento": "Traslado", "horario": "De 10:00 a 11:45", "vehiculo": "Descanso", "actividad": "Traslado a Badiraguato", "ubicacion": "Badiraguato", "observaciones": "Descanso", "personal_convocado": "Manuel Madrid, Edgar amarillas y Carlos Calixto"}, {"evento": "Registro en hotel", "horario": "De 11: 50", "vehiculo": "H100", "actividad": "Llegar a hotel", "ubicacion": "Hotel Royal", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar amarillas y Carlos Calixto"}, {"evento": "Instalación", "horario": "De 12:00 a 14:30", "vehiculo": "H100", "actividad": "Llegada a arena Badiraguato e instalar", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar amarillas y Carlos Calixto"}, {"evento": "Corte a comer", "horario": "De 14:30 a 15:00", "vehiculo": "", "actividad": "Descanso", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar amarillas y Carlos Calixto"}, {"evento": "Instalación", "horario": "De 15:00 16:00", "vehiculo": "H100", "actividad": "Reanudación de instalación", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar amarillas y Carlos Calixto"}, {"evento": "Llamado", "horario": "De 15:00 16:00", "vehiculo": "", "actividad": "Entrada equipo de producción", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Cuauhtémoc Rivera, Carlos Quezada, Francisco Torres, Osiel Hernandez, Daniel Torres, Javier García, Miguel Lara y Ernesto Gutierrez"}, {"evento": "Pruebas", "horario": "De 16:00 a 18:45", "vehiculo": "", "actividad": "Listos para pruebas", "ubicacion": "Estudio Vpro", "observaciones": "", "personal_convocado": "Cuauhtémoc Rivera, Carlos Quezada, Francisco Torres, Osiel Hernandez, Daniel Torres, Javier García, Miguel Lara y Ernesto Gutierrez"}, {"evento": "Intro", "horario": "De 18:45 a 19:00", "vehiculo": "", "actividad": "Inicio de loop", "ubicacion": "Estudio Vpro", "observaciones": "", "personal_convocado": "Cuauhtémoc Rivera, Carlos Quezada, Francisco Torres, Osiel Hernandez, Daniel Torres, Javier García, Miguel Lara y Ernesto Gutierrez"}, {"evento": "Transmisión", "horario": "De 19:00 a 21:30", "vehiculo": "H100", "actividad": "Inicio de Juego", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar amarillas y Carlos Calixto"}, {"evento": "Termino de actividades", "horario": "De 21:40", "vehiculo": "", "actividad": "Salida de oficina equipo de producción", "ubicacion": "Estudio Vpro", "observaciones": "", "personal_convocado": "Cuauhtémoc Rivera, Carlos Quezada, Francisco Torres, Osiel Hernandez, Daniel Torres, Javier García, Miguel Lara y Ernesto Gutierrez"}, {"evento": "Guardar equipo", "horario": "De 21:45 a 23:00", "vehiculo": "H100", "actividad": "Levantamiento de equipo", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar amarillas y Carlos Calixto"}, {"evento": "Retorno a hotel", "horario": "De 23:30 a 00:30", "vehiculo": "H100", "actividad": "Se retiran de arena Badiraguato", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar amarillas y Carlos Calixto"}, {"evento": "Terminio de actividades", "horario": "De 00:30", "vehiculo": "H100", "actividad": "Llegada a hotel", "ubicacion": "Hotel Royal", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar amarillas y Carlos Calixto"}]	Jornada estelar: Pruebas de velocidad, streaming live transmisión del Grito y desmonte nocturno.	Admin VPRO	2026-10-26 19:38:16.959093
3	04	2026-11-03	Asenso TEBACAS	Arena Badiraguato	48	[{"evento": "Llamado", "horario": "De 9:00", "vehiculo": "H100", "actividad": "Entada de oficina", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Gasolina", "horario": "De 9:00 a 9:45", "vehiculo": "H100", "actividad": "Hechar Combustible", "ubicacion": "Gasolinera", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Compra de consumos", "horario": "De 9:45 a 10:00", "vehiculo": "H100", "actividad": "Comprar rehidratantes", "ubicacion": "Oxxo", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Traslado", "horario": "De 10:00 a 11:45", "vehiculo": "H100", "actividad": "Salida a Badiraguato", "ubicacion": "Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Registro en Hotel", "horario": "De 11:45 a 11:50", "vehiculo": "H100", "actividad": "Llegada a Hotel", "ubicacion": "Hotel royal", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Traslado", "horario": "DE 11 45: a 12:00", "vehiculo": "H100", "actividad": "Traslado a arena Badiraguato", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Descargar equipo", "horario": "De 12:00", "vehiculo": "H100", "actividad": "Bajar equipo", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Instalación", "horario": "De 12:30 a 14:30", "vehiculo": "H100", "actividad": "Instalación de equipo", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Corte a comer", "horario": "De 14:30 a 15:00", "vehiculo": "", "actividad": "Descanso", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Instalación", "horario": "De 15:00 a 16:00", "vehiculo": "", "actividad": "Reanudación de instalación", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Llamado", "horario": "De 16:00", "vehiculo": "", "actividad": "Llegada a oficina equipo de producción", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández, Cuauhtemoc Rivera, Daniel Torres, Francisco Torres, Javier Garcia, Ernesto Gutierrez y Miguel Lara"}, {"evento": "Pruebas generales", "horario": "De 16:00 a 19:45", "vehiculo": "", "actividad": "Pruebas en enlaces y de audio", "ubicacion": "Estudio Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández, Cuauhtemoc Rivera, Daniel Torres, Francisco Torres, Javier Garcia, Ernesto Gutierrez y Miguel Lara"}, {"evento": "Intro", "horario": "De 19:45 a 19:55", "vehiculo": "", "actividad": "Introducción de loop", "ubicacion": "Estudio Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández, Cuauhtemoc Rivera, Daniel Torres, Francisco Torres, Javier Garcia, Ernesto Gutierrez y Miguel Lara"}, {"evento": "Intro", "horario": "De 19:55 a 20:00", "vehiculo": "", "actividad": "Introducción de loop nuevamente", "ubicacion": "Estudio Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández, Cuauhtemoc Rivera, Daniel Torres, Francisco Torres, Javier Garcia, Ernesto Gutierrez y Miguel Lara"}, {"evento": "Transmisión", "horario": "De 20:00 a 22:30", "vehiculo": "H100", "actividad": "Inicio del juego", "ubicacion": "Arena Badiraguato y Estudio Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas, Calixto Osiel Hernández, Cuauhtemoc Rivera, Daniel Torres, Francisco Torres, Javier Garcia, Ernesto Gutierrez y Miguel Lara"}, {"evento": "Fin de transmisión", "horario": "De 22:30", "vehiculo": "H100", "actividad": "Fin del juego", "ubicacion": "Arena Badiraguato y estudio vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Término de actividades", "horario": "De 22:30", "vehiculo": "", "actividad": "Salida de equipo de producción", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández, Cuauhtemoc Rivera, Daniel Torres, Francisco Torres, Javier Garcia, Ernesto Gutierrez y Miguel Lara"}, {"evento": "Resguardar equipo", "horario": "De 22:45 a 00:00", "vehiculo": "H100", "actividad": "Guardar cámaras", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Descanso", "horario": "De 00:00", "vehiculo": "H100", "actividad": "Salida de Arena y corte a cenar", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Llamado", "horario": "De 15:00 (04/11)", "vehiculo": "H100", "actividad": "Llegar a arena Badiraguato", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Llamado", "horario": "De 16:00", "vehiculo": "", "actividad": "Llegada a oficina equipo de producción", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández, Cuauhtemoc Rivera, Daniel Torres, Francisco Torres, Javier Garcia, Ernesto Gutierrez y Miguel Lara"}, {"evento": "Pruebas", "horario": "De 16:00 a 19:45", "vehiculo": "", "actividad": "Primeras pruebas de enlaces", "ubicacion": "Estudio Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández, Cuauhtemoc Rivera, Daniel Torres, Francisco Torres, Javier Garcia, Ernesto Gutierrez y Miguel Lara"}, {"evento": "Intro", "horario": "De 19:45 a 19:55", "vehiculo": "", "actividad": "Introducción de loop", "ubicacion": "Estudio Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández, Cuauhtemoc Rivera, Daniel Torres, Francisco Torres, Javier Garcia, Ernesto Gutierrez y Miguel Lara"}, {"evento": "Intro", "horario": "De 19:55 a 20:00", "vehiculo": "", "actividad": "Introducción de intro", "ubicacion": "Estudio Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández, Cuauhtemoc Rivera, Daniel Torres, Francisco Torres, Javier Garcia, Ernesto Gutierrez y Miguel Lara"}, {"evento": "Transmisión", "horario": "De 20:00", "vehiculo": "H100", "actividad": "Incio de juego", "ubicacion": "Arena Badiraguato y estudio vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas, Calixto Osiel Hernández, Cuauhtemoc Rivera, Daniel Torres, Francisco Torres, Javier Garcia, Ernesto Gutierrez y Miguel Lara"}, {"evento": "Fin de transmisión", "horario": "De 22:30", "vehiculo": "H100", "actividad": "Fin de juego", "ubicacion": "Arena Badiraguato y estudio vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas, Calixto Osiel Hernández, Cuauhtemoc Rivera, Daniel Torres, Francisco Torres, Javier Garcia, Ernesto Gutierrez y Miguel Lara"}, {"evento": "Término de actividades", "horario": "De 22:30 a 22:40", "vehiculo": "", "actividad": "Salida de oficina", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Osiel Hernández, Cuauhtemoc Rivera, Daniel Torres, Francisco Torres, Javier Garcia, Ernesto Gutierrez y Miguel Lara"}, {"evento": "Resguardar equipo", "horario": "De 22:45 a 00:00", "vehiculo": "H100", "actividad": "Juntar equipo", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Descanso", "horario": "De 00:00", "vehiculo": "H100", "actividad": "Salida de arena y corte a cenar", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Descanso", "horario": "De 9:00 a 10:00", "vehiculo": "", "actividad": "Corte a desayunar", "ubicacion": "Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Guardar equipo", "horario": "De 10:00 a 11:30", "vehiculo": "H100", "actividad": "Bajar antenas starlink", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Traslado", "horario": "De 11:30 a 13:30", "vehiculo": "H100", "actividad": "Salida de Badiraguato", "ubicacion": "Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Retorno", "horario": "De 13:30", "vehiculo": "H100", "actividad": "Llegada a oficina", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Corte a comer", "horario": "De 14:00 a 16:00", "vehiculo": "H100", "actividad": "Descanso", "ubicacion": "Descanso", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Check in", "horario": "16:00 a 17:30", "vehiculo": "H100", "actividad": "Bajar equipo", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Actividades pendientes", "horario": "De 17:30 a 19:00", "vehiculo": "", "actividad": "Realizar actividades pendientes", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}, {"evento": "Término de actividades", "horario": "De 19:00", "vehiculo": "", "actividad": "Salida de oficina", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Calixto"}]		Admin VPRO	2026-10-31 21:00:04.982856
5	05	2026-11-12	Liga de Baloncesto del pacifico 2026 Ascenso TEBACAS	Arena Badiraguato	56	[{"evento": "CHECK OUT", "horario": "16:00", "vehiculo": "", "actividad": "Registrar equipo", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Manuel Eduardo Madrid"}, {"evento": "Subir equipo", "horario": "16:30", "vehiculo": "H100", "actividad": "Cargar equipo", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas y Manuel Eduardo Madrid"}, {"evento": "Llamado", "horario": "08:00", "vehiculo": "", "actividad": "Entrada a oficina", "ubicacion": "Oficina Vpro", "observaciones": "Viernes 13 de noviembre", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Combustible", "horario": "08:30", "vehiculo": "H100", "actividad": "Cargar gasolina", "ubicacion": "Gasolinera", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Compra de hidratantes", "horario": "08:45", "vehiculo": "H100", "actividad": "Comprar rehidratantes", "ubicacion": "Oxxo", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Traslado", "horario": "09:00", "vehiculo": "H100", "actividad": "Traslado a Badiraguato", "ubicacion": "Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Llegada", "horario": "10:45", "vehiculo": "H100", "actividad": "Llegada a Badiraguato", "ubicacion": "Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Registro", "horario": "10:50", "vehiculo": "H100", "actividad": "Registro en hotel", "ubicacion": "Hotel Royal", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Traslado", "horario": "11:00", "vehiculo": "H100", "actividad": "Llegada a Arena Badiraguato", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Bajar equipo", "horario": "11:05", "vehiculo": "H100", "actividad": "Bajar equipo de unidad", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Instalación", "horario": "11:30", "vehiculo": "", "actividad": "Instalación de equipo", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Descanso", "horario": "14:30", "vehiculo": "", "actividad": "Corte a comer", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "nstalación", "horario": "15:00", "vehiculo": "", "actividad": "Reaunadación de equipo", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Llamado", "horario": "15:00", "vehiculo": "", "actividad": "Entrada a oficna", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Osiel, Hernández, Carlos Quezada, Francisco Torres y Cuauhtemoc Rivera."}, {"evento": "Pruebas", "horario": "15:10", "vehiculo": "", "actividad": "Pruebas de enlaces", "ubicacion": "Arena Badiraguato y Estudio Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas, Calixto Osiel, Hernández, Carlos Quezada, Francisco Torres y Cuauhtemoc Rivera."}, {"evento": "Loop", "horario": "17:45", "vehiculo": "", "actividad": "Se corre loop", "ubicacion": "Arena Badiraguato y Estudio Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas, Osiel, Hernández, Carlos Quezada, Francisco Torres y Cuauhtemoc Rivera."}, {"evento": "Intro", "horario": "17:55", "vehiculo": "", "actividad": "Corre intro nuevo", "ubicacion": "Arena Badiraguato y Estudio Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas, Osiel, Hernández, Carlos Quezada, Francisco Torres y Cuauhtemoc Rivera."}, {"evento": "Transmisión", "horario": "18:00", "vehiculo": "", "actividad": "Inicio de juego", "ubicacion": "Arena Badiraguato y Estudio Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas, Osiel, Hernández, Carlos Quezada, Francisco Torres, Cuauhtemoc Rivera, Javier Garcia, Calixto, Miguel Lara y Ernesto Gutierrez"}, {"evento": "Fin de Transmisión", "horario": "20:30", "vehiculo": "", "actividad": "Fin de juego", "ubicacion": "Arena Badiraguato y Estudio Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas, Osiel, Hernández, Carlos Quezada, Francisco Torres, Cuauhtemoc Rivera, Javier Garcia, Calixto, Miguel Lara y Ernesto Gutierrez"}, {"evento": "Guardar equipo", "horario": "20:45", "vehiculo": "H100", "actividad": "Juntar Camaras", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Termino de actividades", "horario": "20:45", "vehiculo": "", "actividad": "Salida de Oficina", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Osiel, Hernández, Carlos Quezada, Francisco Torres y Cuauhtemoc Rivera."}, {"evento": "Termino de actividades", "horario": "21:00", "vehiculo": "H100", "actividad": "Salida de arena", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Llamado", "horario": "15:00", "vehiculo": "H100", "actividad": "Llegada a Arena Badiraguato", "ubicacion": "Arena Badiraguato", "observaciones": "Sábado 14 de noviembre", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Llamado", "horario": "15:00", "vehiculo": "", "actividad": "Entrada a oficina", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Osiel, Hernández, Carlos Quezada, Francisco Torres y Cuauhtemoc Rivera."}, {"evento": "Pruebas", "horario": "15:10", "vehiculo": "", "actividad": "Pruebas de enlaces", "ubicacion": "Arena Badiraguato y Estudio Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas, Calixto, Osiel, Hernández, Carlos Quezada, Francisco Torres y Cuauhtemoc Rivera."}, {"evento": "Loop", "horario": "17:45", "vehiculo": "", "actividad": "Corre loop", "ubicacion": "Arena Badiraguato y Estudio Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas, Osiel, Hernández, Carlos Quezada, Francisco Torres, Cuauhtemoc Rivera, Javier Garcia, Calixto, Miguel Lara y Ernesto Gutierrez"}, {"evento": "Intro", "horario": "17:55", "vehiculo": "", "actividad": "Corre Intro", "ubicacion": "Arena Badiraguato y Estudio Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas, Osiel, Hernández, Carlos Quezada, Francisco Torres, Cuauhtemoc Rivera, Javier Garcia, Calixto, Miguel Lara y Ernesto Gutierrez"}, {"evento": "Transmisión", "horario": "18:00", "vehiculo": "", "actividad": "Inicio de juego", "ubicacion": "Arena Badiraguato y Estudio Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas, Osiel, Hernández, Carlos Quezada, Francisco Torres, Cuauhtemoc Rivera, Javier Garcia, Calixto, Miguel Lara y Ernesto Gutierrez"}, {"evento": "Fin de Transmisión", "horario": "20:30", "vehiculo": "", "actividad": "Fin de juego", "ubicacion": "Arena Badiraguato y Estudio Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas, Osiel, Hernández, Carlos Quezada, Francisco Torres, Cuauhtemoc Rivera, Javier Garcia, Calixto, Miguel Lara y Ernesto Gutierrez"}, {"evento": "Guardar equipo", "horario": "20:45", "vehiculo": "H100", "actividad": "Juntar equipo", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Termino de actividades", "horario": "20:45", "vehiculo": "", "actividad": "Salida de oficina", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Osiel, Hernández, Carlos Quezada, Francisco Torres y Cuauhtemoc Rivera."}, {"evento": "Termino de actividades", "horario": "22:00", "vehiculo": "H100", "actividad": "Salida de arena de Badiraguato", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Corte a desayunar", "horario": "09:00", "vehiculo": "H100", "actividad": "Desayuno", "ubicacion": "Badiraguato", "observaciones": "Domingo 15 de noviembre", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Guardar equipo", "horario": "10:00", "vehiculo": "H100", "actividad": "Bajar Antenas Starlink", "ubicacion": "Arena Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Retorno", "horario": "11:30", "vehiculo": "H100", "actividad": "Retorno de Badiraguato", "ubicacion": "Badiraguato", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Llegada", "horario": "13:30", "vehiculo": "H100", "actividad": "Llegada de oficina", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas Y Calixto"}, {"evento": "Termino de actividades", "horario": "14:00", "vehiculo": "", "actividad": "Salida de oficina", "ubicacion": "Oficina Vpro", "observaciones": "", "personal_convocado": "Manuel Madrid, Edgar Amarillas"}]		Admin VPRO	2026-11-12 18:49:40.953245
\.


--
-- Data for Name: eventos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.eventos (id_evento, folio, fec_de_elaboracion_de_op, empleado_que_creo_la_op, para_q_cliente, fec_de_instalacion, nombre_evento, hra_de_instalacion, locacion, fec_del_evento, inicio_del_evento, quien_solicita, hra_de_llamado, ubicacion, resp_de_produccion, tipo_de_servicio, produccion, internet_redes, actividades_de_proveedores, nota, elabora, organiza, coordina, vobo, proveedor_op, personal_convocado_op, carros_usados_op, externos_op, estatus, reuniones_vinculadas, habilitada_para_edicion, fotos_evidencia, cronogramas_vinculados, chat_historial, dependencia_solicita, fec_fin_evento, id_cotizacion_vinculada, subtitulo_evento, detalle_llamado, rol_juegos, vehiculo_destino, personal_roles_op, responsable_gastos, chofer, horas_manejo_chofer, es_viaje_foraneo, chat_cerrado, chat_cerrado_por, chat_fecha_cierre, choferes_por_vehiculo, personal_remoto_foraneo, incidencias_por_dia) FROM stdin;
59	1	2025-09-22	Ana Lilia Villarreal Uribe	ELEVOX-Empresa CDMX	2025-09-22	Reunión de Seguridad	16:00:00	Hangar Fuerza Aerea Militar no.10	2025-09-23	11:00:00		06:00:00	Aeropuerto de Culiacán		Renta de equipo audiovisual	Renta de equipo audiovisual\nMESA DE SEGURIDAD:\n6 Pantallas de 65" a piso\n2 Laptop para mat. Audiovisual\n1 Switcher Vmix mini, tipo botonera\nSALON PRIVADO CORONEL:\n1 Monitor de 65" en tripie\n1 Laptop para mat. Audiovisual				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Paco,Daniel,Valdez,Ford,Tiida}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD. No.001-Hangar.xls)		2025-09-23	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
60	2	2025-09-23	Ana Lilia Villarreal Uribe	Periodico EL DEBATE	2025-09-25	Conferencias	00:00:00	Hotel Marriot	2025-09-26	09:00:00		\N	Culiacán		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\nCircuito a 3 cámaras\n1 Switcher full HD\n1 Laptop para reproducción de power point\n5 Microfonos de Solapa\n1 Cosola de audio para streaming\nTransmisión Vía ZOOM a través de plataforma Eventbrite				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD. No.002-El Debate.xls)		2025-09-26	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
61	3	2025-09-25	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-09-26	Gira de presentación:	11:00:00	Centro de Convenciones	2025-09-27	13:00:00		08:00:00	Mazatlán, Sinaloa.		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\n1 Switcher\n3 Monitores de 65" en tripie\n2 puntos de intermet\nKUWA:\n5 pantallas led de 3x2m\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.	INTERNET:\nProveeduría de internet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Paco,Carlos,Osiel,Cuahutemoc}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.003- 1er. Informe sheinbaum.xls)		2025-09-27	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
62	4	2025-09-27	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-09-27	LA SEMANERA	06:00:00	Auditorio	2025-09-29	09:00:00		06:00:00	Culiacán,Sin		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,Edgar,Valdez,Hector,Manuel,Luis,Daniel,Paco,"TRADUCTORES LENGUAJE A SEÑAS","Cristina y José Carlos",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.004- Semanera.xls)		2025-09-29	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
63	5	2025-10-03	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-10-11	CUADRANGULAR DEL BIENESTAR	16:00:00	Estadio CHEVRON PARK en Los Mochis.	2026-10-11	17:00:00		04:00:00	Estudio TV VPRO		Producción de partidos de Beisbol desde Estudio TV y transmisión a redes sociales autorizadas.	Producción de partidos de Beisbol desde Estudio TV y transmisión a redes sociales autorizadas.\nPRODUCCION EN ESTUDIO TV:\nProducción de partidos recibiendo señal\nTransmisión a redes autorizadas\nSwitcher\nVMIX para gráficos\n3 micros de solapa\n2 chicharos para conductores				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jefe de Producción",Manuel,Redes,Edgar,Switcher,"Eduardo Valdez",Hector,"Asist. Técnico",Paco,Andrea,"Chepe Zazueta","en estudio",Bambino,"Leonardo León",Mochis,"DIF Estatal","Vuelo de Dron",Abraham,"Mochis Proveedor"}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.005 Cuadrangular del Bienestar-Los Mochis.xls)		2026-10-11	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
64	6	2025-10-07	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-10-12	CUADRANGULAR DEL BIENESTAR	03:00:00	Estadio TOMATEROS DE CULIACAN	2026-10-12	17:00:00		15:00:00	Culiacán, Sin.		Producción de partidos de Beisbol desde Estudio TV y transmisión a redes sociales autorizadas.	Producción de partidos de Beisbol desde Estudio TV y transmisión a redes sociales autorizadas.\nPRODUCCION EN ESTUDIO TV:\nProducción de partidos recibiendo señal\nTransmisión a redes autorizadas\nSwitcher\nVMIX para gráficos\n3 micros de solapa 2 chicharos para conductores comunicacion de productor con conductores computadora para musica y musica libre de derechos Green Screen deportivo tipo estudio TV Sala lounge para invitados en su entrevista Catering para invitados.\n2 chicharos para conductores				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jefe de Producción",Manuel,Redes,Cuahutemoc,Switcher,"Eduardo Valdez",Hector,"Asist. Técnico",Paco,"Transm. De vuelo",Andrea,"Chepe Zazueta","en estudio",Bambino,"Persona a cargo de números","Miguel Lugo","DIF Estatal","Carlos Quezada","Rocio Contreras"}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.006 Cuadrangular del Bienestar-Culiacán.xls)		2026-10-12	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
65	7	2025-10-10	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-10-10	Inauguración	\N		2026-10-11	09:00:00		06:00:00	Mazatlán, Sinaloa.		Circuito y transmisión	Circuito y transmisión\nPRODUCCION:\nCircuito a 4 cámaras\nTransmisión\nVmix\nComputadoras\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)	1 antena Starlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jefe de Producción",Geo,Redes,"Ing. Cuahutemoc","Luis Quintin",Carlos,Vmix,Osiel,Manriko,Ricardo,FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.007 Evento Inauguracion bombeo-Mazatlán.xls)		2026-10-11	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
66	8	2025-10-13	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-11-27	CUADRANGULAR DEL BIENESTAR	16:00:00	Estado Teodoro Mariscal en Mazatlán, Sin.	2026-11-28	19:00:00		17:00:00	Estudio TV VPRO		Producción de partidos de Beisbol desde Estudio TV y transmisión a redes sociales autorizadas.	Producción de partidos de Beisbol desde Estudio TV y transmisión a redes sociales autorizadas.\nPRODUCCION EN ESTUDIO TV:\nProducción de partidos recibiendo señal\nTransmisión a redes autorizadas\nSwitcher\nVMIX para gráficos\n3 micros de solapa\n2 chicharos para conductores	1 Antena Starlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jefe de Producción",Manuel,Redes,Cuahutemoc,Switcher,"Eduardo Valdez",Hector,"Asist. Técnico",Paco,Andrea,"Chepe Zazueta","en estudio",Bambino,"Leonardo León",Mochis,"DIF Estatal","Entrevistas de color en Estadio",Conrado}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.008 Evento Cuadrangular del Bienestar en Mazatlán Teodoro Mariscal.xls)		2026-11-28	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
67	9	2025-10-16	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-10-18	GIRAS- OBRAS	10:00:00	Blvd. Francisco Agraz y Club 20-30	2025-10-18	13:00:00		06:00:00	Los Mochis		Circuito y transmision de evento de Gobernador.	Circuito y transmision de evento de Gobernador.\nPRODUCCIÓN:\nCircuito a 3 cámaras\nTransmisión a redes autorizadas\nSwitcher\nComputadoras\n1 Modenm inalábrico p/transmision\n1 Monitor de 55" a piso	Suminsitro de internet satelital\n1 Antena Starlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jefe de Producción",Geo,Redes,Cuahutemoc,Switcher,"Eduardo Valdez",Hector,"Asist. Técnico",Paco,Cámara,Manuel,Daniel,Luis,Ford}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.009 Gob. del Edo. Giras- Los Mochis 171025.xls)		2025-10-18	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
68	10	2025-10-15	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-10-20	LA SEMANERA	06:00:00	Auditorio	2025-10-20	09:00:00		06:00:00	Culiacán,Sin		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,Edgar,Valdez,Hector,Manuel,Luis,Daniel,Paco,"TRADUCTORES LENGUAJE A SEÑAS","José Carlos y Beatriz",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.010 Semanera.xls)		2025-10-20	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
69	11	2025-10-16	Ana Lilia Villarreal Uribe	IEES	2025-03-21	IEES	08:00:00	Instalaciones IEES	2025-03-21	23:00:00		08:00:00	Culiacán		Circuito y transmision de evento de Gobernador.	Circuito y transmision de evento de Gobernador.\nPRODUCCIÓN:\n3 cámaras\nTransmisión a redes autorizadas\nVmix/Graficos\n2 Computadoras\n1 Kit de green screen para lenguaje a señas\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jefe de Producción",Geo,Redes,Edgar,Vmix,"Eduardo Valdez",Hector,"Asist. Técnico",Paco,Cámara,Manuel,Daniel,Luis,Ford,Tiida}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.011 IEES Sesion Extraordinaria PRESENCIAL 211025.xls)		2025-03-21	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
70	12	2025-10-21	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-10-18	GIRAS	10:00:00	II ZONA MILITAR CUARTEL GENERAL en MAZATLAN	2025-10-18	13:00:00		06:00:00	Mazatlán, Sin.		Circuito y transmision de evento de Gobernador.	Circuito y transmision de evento de Gobernador.\nPRODUCCIÓN:\nSALA DE REUNIONES:\n5 TV a piso de 65"\n1 TV en tripie de 65"\n2 Laptop\n1 Botonera\nSALA PRIVADA CORONEL	SUMINISTRO INTERNET\n1 Antena Starlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Redes,Cuahutemoc,Botonera,Osiel,"Asist. Técnico",Daniel,Paco,Ford}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.012 REUNION SEGURIDAD HARFUCH MAZATLAN 23-oct-25.xls)		2025-10-18	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
71	13	2025-10-21	Ana Lilia Villarreal Uribe	GRUPO PARLAMENTARIO MORENA	2025-10-25	Informe	\N	Cuartel Militar	2025-10-25	00:00:00		00:00:00	Navolato		Circuito y transmision de evento de Gobernador.	Circuito y transmision de evento de Gobernador.\nPRODUCCIÓN:\nSwitcher\n2 Laptop\n2 Monitores de 55" a piso\nProveeduría dei nternet\nKUWA\nEscenografía	SUMINISTRO INTERNET\n1 Antena Starlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Redes,Cuahutemoc,Botonera,Osiel,"Asist. Técnico",Daniel,Paco,Ford}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.013 INFORME MORENA en Navolato 25-oct-25.xls)		2025-10-25	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
72	14	2025-10-21	Ana Lilia Villarreal Uribe	ADECEM	2025-10-30	Conferencia REPSE	\N	Auditorio Aquamiller	2025-10-30	10:00:00		00:00:00	Culiacán		Circuito Streaming a 2 cámaras y ZOOM	Circuito Streaming a 2 cámaras y ZOOM\nPRODUCCIÓN:\n2 cámaras\nTransmisión Vía ZOOM\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Luz Damaris Quintero Pimentel				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Ford}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.014  CONFERECIA REPSE-Aquamiller-30-oct-25.xls)		2025-10-30	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
73	15	2025-10-21	Ana Lilia Villarreal Uribe	IEES	2025-11-01	IEES	08:00:00	Instalaciones IEES	2025-11-01	23:00:00		08:00:00	Culiacán		Transmision vía ZOOM a 2 cámaras	Transmision vía ZOOM a 2 cámaras\nPRODUCCIÓN:\n3 cámaras\nTransmisión a redes autorizadas\nVmix/Graficos\n2 Computadoras\n1 Kit de green screen para lenguaje a señas\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jefe de Producción",Geo,Redes,Edgar,Vmix,"Eduardo Valdez",Hector,"Asist. Técnico",Paco,Cámara,Manuel,Daniel,Luis,Ford,Tiida}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.015 IEES Sesion Extraordinaria PRESENCIAL 01nov25.xls)		2025-11-01	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
74	16	2025-10-21	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-03-11	CUADRANGULAR DEL BIENESTAR	16:00:00	Estadio CHEVRON PARK en Los Mochis.	2026-11-12	19:30:00		16:00:00	Estudio TV VPRO		Producción de partidos de Beisbol desde Estudio TV y transmisión a redes sociales autorizadas.	Producción de partidos de Beisbol desde Estudio TV y transmisión a redes sociales autorizadas.\nPartido: Algodoneros Vs Cañeros\nPRODUCCION EN ESTUDIO TV:\nProducción de partidos recibiendo señal\nTransmisión a redes autorizadas\nSwitcher\nVMIX para gráficos\n3 micros de solapa				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jefe de Producción",Manuel,Redes,Edgar,Switcher,"Eduardo Valdez",Hector,"Asist. Técnico",Paco,Andrea,"Chepe Zazueta","en estudio",Bambino,"Leonardo León",Mochis,"DIF Estatal","Vuelo de Dron",Abraham,"Mochis Proveedor"}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.016 Cuadrangular del Bienestar-Los Mochis 11 Y 12 NOV..xls)		2026-11-12	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
75	17	2025-10-23	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-10-27	LA SEMANERA	06:00:00	Auditorio	2025-10-27	09:00:00		06:00:00	Culiacán,Sin		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Osiel,Valdez,Graficos,Hector,Luis,Cámara,Daniel,Paco,Técnico,"TRADUCTORES LENGUAJE A SEÑAS","José Carlos y Beatriz",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.017 Semanera 27-oct-25.xls)		2025-10-27	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
76	18	2025-10-25	Ana Lilia Villarreal Uribe	AYUNTAMIENTO DE AHOME	2025-10-27	INFORME PRESIDENTE MPAL.	\N	Auditorio Ingenio de los Mochis	2025-03-28	11:00:00		00:00:00	Los Mochis, Sin.		Circuito y transmision de evento de Gobernador.	Circuito y transmision de evento de Gobernador.\nPRODUCCIÓN:\nCircuito a 3 cámaras\nStreaming\n2 Monitores de 55" a piso p/ escenario\n1 Monitor de 65" en tripie p/medios\n2 computadoras para material audiovisual\n1 Vmix/Atem mini para proveeer material a pantalla de auditorio	SUMINISTRO INTERNET\nProveeduría de internet para transmisión\n1 antena starlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de Prodcucción",Edgar,Redes,Osiel,Valdez,Switcher,Hector,Luis,Camarógrafo,Daniel,Paco,"Ayuntante Tecnico","Eduardo Araujo",Ford}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.018 INFORME PDTE. MPAL. AHOME en Los mochis 28-oct-25.xls)		2025-03-28	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
77	19	2025-11-01	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-11-03	LA SEMANERA	06:00:00	Auditorio	2025-11-03	09:00:00		06:00:00	Culiacán,Sin		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Osiel,Valdez,Graficos,Hector,Luis,Cámara,Daniel,Paco,Técnico,"TRADUCTORES LENGUAJE A SEÑAS","José Carlos y Beatriz",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.019  Semanera 031125.xls)		2025-11-03	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
78	20	2025-11-06	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-11-10	LA SEMANERA	06:00:00	Auditorio	2025-11-10	09:00:00		06:00:00	Culiacán,Sin		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Osiel,Valdez,Graficos,Hector,Luis,Cámara,Daniel,Paco,Técnico,"TRADUCTORES LENGUAJE A SEÑAS",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.020  Semanera 101125.xls)		2025-11-10	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
79	21	2025-11-06	Ana Lilia Villarreal Uribe	IEES	2025-11-12	IEES	\N	Estudio TV Vpro	2025-11-12	11:00:00		\N	Culiacán		Transmision vía ZOOM a 2 cámaras	Transmision vía ZOOM a 2 cámaras\nPRODUCCIÓN:\nAdministración de Streaming a redes autorizadas\nVmix/Graficos\n2 Computadoras\nInserción de traductor de lenguaje\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.021 IEES Sesion VIRTUAL 12nov25.xls)		2025-11-12	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
80	22	2025-11-06	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-03-25	GIRAS-	09:00:00	PLENO DEL CONGRESO	2025-11-26	11:00:00		\N	Culiacán		Circuito y transmision de evento de Gobernador.	Circuito y transmision de evento de Gobernador.\nPRODUCCIÓN:\na 6 medios de comunicacion y exclusivo para TVP\nSwitcher para material visual a pantalla\n2Computadoras par material audiovisual\nKUWA:\n1 Pantalla led 5x3m\n1 Estructura para montaje de pantalla	Suministro y proveeduría de internet con fibra optica para dos puntos\n2 Modem inalábrico de alta velocidad con capacidad de 1Gb			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jefe de Producción",Geo,Redes,Cuahutemoc,Edgar,Switcher,"Asist. Técnico",Paco,Daniel}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.022 Gob. del Edo. 4to.INFORME GOB. CONGRESO 26112025.xls)		2025-11-26	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
81	23	2025-11-06	Ana Lilia Villarreal Uribe	ISDE	2025-11-26	ENTREGA PREMIO ESTATAL AL DEPORTE	\N	CENTRO DE ALTO RENDIMIENTO: MA. DEL ROSARIO ESPINOZA	2025-11-27	11:00:00		\N	Culiacán		Circuito y transmision de evento de Gobernador.	Circuito y transmision de evento de Gobernador.\nPRODUCCIÓN:\n2 monitores de 40" a piso para escenario\n3 laptop para material audiovisual\nSwitcher para material visual a pantalla\nKUWA:\n1 Pantalla led 5x3m\n1 Estructura para montaje de pantalla				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jefe de Producción",Geo,Redes,Switcher,"Asist. Técnico",Paco,Daniel}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.023 ISDE-PREMIO ESTATAL AL DEPORTE  27112025.xls)		2025-11-27	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
82	24	2025-11-12	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-11-13	Reunión de Seguridad	\N	CUARTEL MILITAR DE MANDO ESPECIAL	2025-11-13	09:00:00		06:00:00	Badiraguato		Circuito y transmision de evento de Gobernador.	Circuito y transmision de evento de Gobernador.\nPRODUCCIÓN:\nSALA DE REUNIONES:\n5 TV a piso de 65"\n1 TV en tripie de 65"\n2 Laptop\n1 Botonera\nSALA PRIVADA CORONEL	SUMINISTRO INTERNET\n1 Antena Starlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Redes,Edgar,Botonera,Osiel,"Asist. Técnico",Daniel,Paco,FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.024 reunion seguridad badiraguato 131125.xls)		2025-11-13	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
83	25	2025-11-12	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-03-25	4TO. INFORME DE GOBIERNO	\N	Salón Constituyentes del CONGRESO DEL EDO.	2025-11-26	09:00:00		\N	Culiacán		Circuito y transmision de evento de Gobernador.	Circuito y transmision de evento de Gobernador.\nPRODUCCIÓN:\nSuministro de señal HDMI para señal de imágenes para 11 stand de medios\nSuministro de Energía eléctrica para 11 stand de medios\n1 Switcher para pantalla\n2 Laptop\nKUWA\n1 Pantalla led medida 5x3m en base	SUMINISTRO INTERNET\nProveeduría de internet fibra a 11 stand de medios\n2 Modem de 1Gb			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Redes,Switcher,"Asist. Técnico"}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.025 4TO.INFORME GOBIERNO Congreso 26NOV25.xls)		2025-11-26	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
84	26	2025-11-15	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-11-20	LIVE COPPEL	\N	en CC Coppel	2025-11-21	10:00:00		\N	Culiacán		Circuito y transmision de evento de Gobernador.	Circuito y transmision de evento de Gobernador.\nPRODUCCIÓN:\n1 Switcher para inserción de plecas y gráficos\nLaptop\nCableado HDMI\n2 Monitores de 55" a piso (escenario y público)\nEquipo de audio (2 bocinas en tripie)\n4 microfonos lavalier				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Switcher,"Asist. Técnico"}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.026 Switcher y equipo para LIVE COPPEL  21NOV25.xls)		2025-11-21	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
85	27	2025-11-10	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-03-11	LA SEMANERA	06:00:00	Auditorio	2025-11-11	09:00:00		06:00:00	Culiacán,Sin		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Osiel,Valdez,Graficos,Hector,Luis,Cámara,Daniel,Paco,Técnico,"TRADUCTORES LENGUAJE A SEÑAS",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.027  Semanera 111125.xls)		2025-11-11	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
86	28	2025-11-15	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-11-17	LA SEMANERA	06:00:00	Auditorio	2025-11-17	09:00:00		06:00:00	Culiacán,Sin		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Osiel,Valdez,Graficos,Hector,Luis,Cámara,Daniel,Paco,Técnico,"TRADUCTORES LENGUAJE A SEÑAS",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.028  Semanera 171125.xls)		2025-11-17	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
87	29	2025-11-21	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-11-24	LA SEMANERA	06:00:00	Auditorio	2025-11-24	09:00:00		06:00:00	Culiacán,Sin		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Osiel,Valdez,Graficos,Hector,Luis,Cámara,Daniel,Paco,Técnico,"TRADUCTORES LENGUAJE A SEÑAS",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.029  Semanera 241125.xls)		2025-11-24	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
88	30	2025-11-24	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-03-25	ENLACE NACIONAL CON MAÑANERA CDMX	05:30:00	Auditorio en Gbo. Del Edo.	2025-03-25	06:30:00		04:00:00	Culiacán,Sin		Circuito y transmisión	Circuito y transmisión\nPRODUCCION:\nCircuito a 2 cámaras\nTransmisión\nVmix\n1 monitor de 55" en tripie\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Cuahutemoc,Redes,Osiel,Manuel,Cámara,Daniel,Paco,Técnico,FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.030  Enlace Mañanera Secret.Gob. -Auditorio 251125.xls)		2025-03-25	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
89	31	2025-11-28	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-12-01	LA SEMANERA	06:00:00	Auditorio	2025-12-06	09:00:00		06:00:00	Culiacán,Sin		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Valdez,Osiel,Graficos,Hector,Carlos,Cámara,Daniel,Manuel,Paco,Técnico,"TRADUCTORES LENGUAJE A SEÑAS","Cuquis y Cristina",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.031  Semanera 011225.xls)		2025-12-06	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
90	32	2025-12-01	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-03-02	Evento Gobernador	\N		2025-03-02	11:30:00		06:00:00	Guasave, Sin.		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\n3 cámaras\nTransmisión\nMonitores\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Luz Damaris Quintero Pimentel				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Cuahuctemoc,Redes,Osiel,Hector,Carlos,Cámara,Manuel,Daniel,Paco,Técnico,FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.032  GIRAS  Secret. en Guasave 02-dic-25.xls)		2025-03-02	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
91	33	2025-12-08	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-12-08	ISDE	16:30:00	CAR. Ma. Del Rosario Espinoza	2025-03-09	11:00:00		09:00:00	Culiacán, Sin		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\n3 cámaras\nTransmisión\n2 Monitores de 40" a piso\n1 vmix\nBotonera Atem-mini\n3 Laptop				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Osiel,Hector,Manuel,Cámara,Paco,Técnico,"Eduardo Araujo",Camarógrafo,"Nacho García",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.033  GIRAS  Secret. ISDE CAR- Ma,. del Rosario 03-dic-25.xls)		2025-03-09	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
92	34	2025-12-03	Ana Lilia Villarreal Uribe	Coppel	2025-12-17	Entrevistas: presentación de Libro	11:00:00	CASA EN LA PRIMAVERA	2025-12-17	13:00:00		09:00:00	Culiacán, Sin		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\n2 monitores de 65" en tripie\nPREVENIRSE CON:\noperador par acone ctarse acomputadora de cliente\nDistribución de CABLEADO HDMI para conectar compu de cliente a Monitores.\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Eduardo,switcher,Paco,técnico}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.034 COPPEL present.libro en PRIMAVERA 17-dic-25.xls)		2025-12-17	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
93	35	2025-12-04	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-12-07	Reunión Seguridad	\N	Reunión en 3er. Regional Militar	2025-12-08	\N		\N	Mazatlán, Sinaloa.		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\n2 monitores de 40" a piso\n1 Switcher\n1 Vmix\n2 Computadoras\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)	Modem internet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Tecnico,Paco,Switcher,FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.035 REGION 3ER ZONA MILITAR MAZATLAN.xls)		2025-12-08	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
94	36	2025-12-02	Ana Lilia Villarreal Uribe	MAJA SPORTWEAR	2026-01-14	SORTE ANUAL 2026	\N	Por definir	2026-01-14	17:00:00		\N	Culiacán, Sin		Circuito y transmisión ZOOM (Falso en vivo) Incluye gráficos de imagen	Circuito y transmisión ZOOM (Falso en vivo) Incluye gráficos de imagen\nFALSO EN VIVO\nPRODUCCION:\n2 Cámaras\nTransmisión\n1 Monitores de 40" a piso\n2 micrófonos lavalier para presentadores\n2 Chicharos de ocmunicacion entre producción y talento	Internet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Hector,Valdez,Switcher,Manuel,Camarógrafo,Daniel,Andrea,Gerardo,FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.036  MAJA- Live Streaming Sorteo Anual 14-ene-26.xls)		2026-01-14	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
95	36-B	2025-12-08	Ana Lilia Villarreal Uribe	MERCADITO MOVIL	2025-03-09	Grabaciones	\N	Instalaciones de Aqua Miller	2026-12-13	06:00:00		05:30:00	Culiacán, Sin.		LEVANTAMIENTO DE IMÁGENES Y GRABACIONES ESPECIALES	LEVANTAMIENTO DE IMÁGENES Y GRABACIONES ESPECIALES\nEQUIPO FILMACION:\nCámara Alfa y FS/7\nEquipo de iluminación\nboom de audio (micro)\nTeleprompeter\n1 grabadora de audio\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Cámara,Gerardo,Carlos,Asistente,Daniel,TIIDA}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.036 GRABACIONES MERCADITO MOVIL.xls)		2026-12-13	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
96	37	2025-12-06	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-12-08	LA SEMANERA	06:00:00	Auditorio	2025-12-08	09:00:00		06:00:00	Culiacán,Sin		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Valdez,Osiel,Graficos,Hector,Carlos,Cámara,Daniel,Manuel,Paco,Técnico,"TRADUCTORES LENGUAJE A SEÑAS","Cuquis y José Carlos.",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.037  Semanera 081225.xls)		2025-12-08	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
97	38	2025-12-13	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-12-15	LA SEMANERA	06:00:00	Auditorio	2025-12-15	09:00:00		06:00:00	Culiacán,Sin		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Valdez,Osiel,Graficos,Hector,Carlos,Cámara,Daniel,Manuel,Paco,Técnico,"TRADUCTORES LENGUAJE A SEÑAS","Miguel y Beatriz",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.038  Semanera 151225.xls)		2025-12-15	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
98	39	2025-12-16	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-12-17	Reunión Seguridad	\N	Reunión en 3er. Regional Militar	2025-12-18	\N		04:00:00	Mazatlán, Sinaloa.		Pantallas , monitores y switcher	Pantallas , monitores y switcher\nPRODUCCION:\n2 monitores de 40" a piso\n1 Switcher\n1 Vmix\n2 Computadoras\nproveeduría dei nternet\nCircuito a 2 cámaras	antena Starlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Tecnico,Paco,Switcher,Osiel,Cámara,Manuel,Daniel,Redes,Cuauhtemoc}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.039 REGION 3ER ZONA MILITAR MAZATLAN.xlsx)		2025-12-18	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
99	40	2026-01-03	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-01-04	LA SEMANERA	02:00:00	Los Mochis, Sinaloa.	2026-01-05	09:00:00		06:00:00	Los Mochis, Sinaloa.		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Gerardo,"Jefe de produccción",Edgar,Redes,Valdez,Osiel,Graficos,Hector,Carlos,Cámara,Daniel,Manuel,Paco,Técnico,"TRADUCTORES LENGUAJE A SEÑAS",FORD,TIIDA}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.040  Semanera 050126 Mochis.xls)		2026-01-05	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
100	41	2026-01-06	Ana Lilia Villarreal Uribe	COCA - COLA	2026-01-09	FAST STAR 2026	\N	Cedi el Venadillo en Mazatlán, Sin.	2026-01-10	06:00:00		\N	Mazatlán, Sinaloa.		Circuito y transmisión	Circuito y transmisión\nPRODUCCION:\nCircuito a 3 cámaras\nTransmisión\nVuelo Dron\nEDICION VIDEO:\nGrabación y edicion de video duracion 1.30minutos\nGrabación de Clip Especial IA				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Gerardo,"Grabación color",Edgar,Valdez,Osiel,Hector,Carlos,Daniel,Manuel,Paco,Esteban,"Vuelo de Dron",Mario,Fotografo,Andrea,"Edicion IA"}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.041 FAST STAR 2026 COCA COLA MAZATLAN.xls)		2026-01-10	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
102	43	2026-01-08	Ana Lilia Villarreal Uribe	MAJA SPORTWEAR	2026-01-14	SORTEO ANUAL MAJA	\N	Estudio TV VPRO	2026-01-14	17:00:00		\N	Culiacán, Sinaloa.		Enlace con evento de Mazatlán.	Enlace con evento de Mazatlán.\nPRODUCCION:\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Luz Damaris Quintero Pimentel				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.043 GRABACIONES MAJA 14ene-25.xls)		2026-01-14	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
103	44	2026-01-09	Ana Lilia Villarreal Uribe	INSTITUTO ESTATAL ELECTORA DE SINALOA	2026-01-14	SESION EXTRAORDINARIA VIRTUAL	\N	Estudio TV VPRO	2026-01-14	11:00:00		\N	Culiacán, Sinaloa.		Enlace con evento de Mazatlán.	Enlace con evento de Mazatlán.\nPRODUCCION:\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Luz Damaris Quintero Pimentel				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.044 SESION VIRTUAL IEES- STUDIO 14ene-25.xls)		2026-01-14	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
104	45	2026-01-09	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-01-12	LA SEMANERA	06:30:00	Auditorio	2026-01-13	09:00:00		06:00:00	Culiacán, Sin.		Circuito y transmisión ZOOM	Circuito y transmisión ZOOM\nPRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Gerardo,"Jefe de produccción",Edgar,Redes,Valdez,Osiel,Graficos,Hector,Carlos,Cámara,Daniel,Manuel,Paco,Técnico,"TRADUCTORES LENGUAJE A SEÑAS",FORD,TIIDA}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.045  Semanera 120126 Auditorio.xls)		2026-01-13	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
105	46	2026-01-16	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-01-18	LA SEMANERA	\N		2026-01-19	09:00:00		06:00:00	Guasave, Sin.		STREAMING A 3 CAMARAS Y PROVEEDURIA DE INTERNET	PRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Luz Damaris Quintero Pimentel	STREAMING A 3 CAMARAS Y PROVEEDURIA DE INTERNET			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Valdez,Graficos,Hector,Carlos,Cámara,Daniel,Paco,Técnico,Calixto,cámara,Gerardo,"TRADUCTORES LENGUAJE A SEÑAS",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.046  Semanera 190126 Guasave, Sin..xls)		2026-01-19	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
106	47	2026-01-16	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-01-19	GIRAS-SECRETARIAS	\N		2026-01-19	12:00:00		\N	Sinaloa de Leyva, Sin.		STREAMING A 3 CAMARAS Y PROVEEDURIA DE INTERNET	PRODUCCION:\nTransmisión a 3 cámaras\n1Switcher\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Luz Damaris Quintero Pimentel	STREAMING A 3 CAMARAS Y PROVEEDURIA DE INTERNET\nProveeduría de internet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Gerardo,"Jefe de produccción",Cuahutemoc,Redes,Osiel,Manuel,Camarógrafo,Condor,camarógrafo,Nacho,HILUX}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.047 Entrega Titulos Propiedad, Sinaloa de Leyva.190126.xls)		2026-01-19	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
107	48	2026-01-19	Ana Lilia Villarreal Uribe	Coppel	2026-01-29	SIST.AUDIO Y MIROFONIA COPPEL 290126	\N	TORRE PERMIERE, Blvd. Pedro Infante entre agnecia KIA y Edificio Country Courts	2026-01-29	11:00:00		\N	Culiacán, Sin,.		Equipo de audio y microfonía.	Equipo de audio y microfonía.\nVPRO\n3 Micrófonos lavalier\n1 capturadora\nPRODUCCION KUWA:\nAudio lineal 2x1xlado\nRack de audio amplificado\nCentro de caga				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"jefe de produccion",Hector}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.048 SIST.AUDIO Y MIROFONIA COPPEL 290126.xls)		2026-01-29	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
108	49	2026-01-23	Ana Lilia Villarreal Uribe	Coppel	2025-02-26	AGENDA CONVENION REGIONAL 2026	\N	REGION COLIMA	2025-02-26	10:00:00		\N	MANZANILLO, COLIMA		Servicio de Switcher, internet, grabación a 2 cámaras y serv.de promana telepromter.	Salida de Switcher en autobus por la tarde noche Domingo 22 marzo ,\nllegada lunes 23 Marzo 1pm., llegada directo al ensayo.\nPRODUCCIÓN: (OSSLA) día 24 feb\nSwitcher\nPRODUCCION: CONFERENCIAS día 25 feb\nGrabación a 2 cámaras\nServicio de telepromter\nPRODUCCIÓN: 2 CONFERENCIAS Día 26 feb	Servicio de Switcher, internet, grabación a 2 cámaras y serv.de promana telepromter.\nproveeduría de internet\nInternet\ninternet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.049 CONF.COPPEL MANZANILLO COLIMA 24,25,26 FEB.xls)		2025-02-26	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
109	50	2026-01-23	Ana Lilia Villarreal Uribe	Coppel	2025-02-26	AGENDA CONVENION REGIONAL 2026	\N	REGION PACIFICO	2025-02-26	10:00:00		\N	MAZATLAN, SINALOA.		Servicio de Switcher, internet, grabación a 2 cámaras y serv.de promana telepromter.	PRODUCCIÓN: (OSSLA) día 24 feb\nSwitcher\nServicio de telepromter\nPRODUCCION: CONFERENCIAS día 25 feb\nGrabación a 2 cámaras\nPRODUCCIÓN: 2 CONFERENCIAS Día 26 feb\nRETORNO DÍA 26 feb al término del evento.\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.	Servicio de Switcher, internet, grabación a 2 cámaras y serv.de promana telepromter.\nproveeduría de internet\nInternet\ninternet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.050 CONF.COPPEL MAZATLAN,SIN 24,25,26 FEB.xls)		2025-02-26	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
110	51	2026-01-23	Ana Lilia Villarreal Uribe	Coppel	2026-03-05	AGENDA CONVENION REGIONAL 2026	\N	REGION	2026-03-05	10:00:00		\N	AGUASCALIENTES ,AGS.		Servicio de Switcher, internet, grabación a 2 cámaras y serv.de promana telepromter.	SALIDA SWITCHER: Domingo 1ero de marzo en Autobus\nENSAYO: Día 02 de Marzo\nServicio de telepromter\nPRODUCCIÓN: (OSSLA) día 03 de Marzo (Salida en automóvil de camaras)\nSwitcher\nPRODUCCIÓN: CONFERENCIA día 04 (11:00am y 12:30pm)\nGrabación a 2 cámaras\nEXTRA (fiesta , circuito para grupo musical)	Servicio de Switcher, internet, grabación a 2 cámaras y serv.de promana telepromter.\nSwitcher e internet\nproveeduría de internet\ninternet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.051 CONF.COPPEL AGUASCALIENTES,03,04 Y 05 MARZO.xls)		2026-03-05	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
111	52	2026-01-23	Ana Lilia Villarreal Uribe	Coppel	2026-03-05	AGENDA CONVENION REGIONAL 2026	\N	REGION NORTE	2026-03-05	10:00:00		\N	SAN CARLOS, SON.		Servicio de Switcher, internet, grabación a 2 cámaras y serv.de promana telepromter.	SWITCHER: Sale por tierra con Equipo KUWA domingo, instalacion 01/marzo\nSALIDA: Sábado 28 de Feb por tierra con KUWA\nMONTAJE DE ESCENOGRAFIA Y EQUIPO KUWA Domingo 1er.Marzo\nENSAYO: Día 02 de Marzo\nPRODUCCIÓN: (OSSLA) día 03 de Marzo (Salida en automóvil de camaras)\nSwitcher\nServicio de telepromter\nPRODUCCION: CONFERENCIAS día 04 de Marzo	Servicio de Switcher, internet, grabación a 2 cámaras y serv.de promana telepromter.\nSwitcher e internet\nproveeduría de internet\nInternet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.052 CONF.COPPEL  SAN CARLOS, SON.,03,04 Y 05 MARZO.xls)		2026-03-05	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
112	53	2026-01-23	Ana Lilia Villarreal Uribe	Coppel	2026-03-12	AGENDA CONVENION REGIONAL 2026	\N	REGION COLIMA	2026-03-12	10:00:00		\N	MANZANILLO COLIMA		Servicio de Switcher, internet, grabación a 2 cámaras y serv.de programa de telepromter.	SALIDA SWITCHER: Domingo 8 de marzo en Autobus\nLLEGADA: a la 1pm directo a ensayo\nENSAYO: 09 de Marzo\nPRODUCCIÓN: (OSSLA) día 10 de Marzo (Salida en automóvil de cámaras)\nSwitcher\nServicio de telepromter\nPRODUCCION: CONFERENCIAS día 11 de Marzo\nGrabación a 2 cámaras	Servicio de Switcher, internet, grabación a 2 cámaras y serv.de programa de telepromter.\nSwitcher e internet\nproveeduría de internet\nInternet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.053 CONF.COPPEL MANZANILLO,COLIMA 10,11 y 12  MARZO.xls)		2026-03-12	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
113	54	2026-01-23	Ana Lilia Villarreal Uribe	Coppel	2026-03-12	AGENDA CONVENION REGIONAL 2026	\N	REGION NORTE	2026-03-12	10:00:00		\N	DURANGO, DGO.		Servicio de Switcher, internet, grabación a 2 cámaras y serv.de programa de telepromter.	SALIDA SWITCHER: Domingo 8 de marzo en Autobus\nLLEGADA: a la 1pm directo a ensayo\nENSAYO: 09 de Marzo\nPRODUCCIÓN: (OSSLA) día 10 de Marzo (Salida en automóvil de cámaras)\nSwitcher\nServicio de telepromter\nPRODUCCION: CONFERENCIAS día 11 de Marzo\nGrabación a 2 cámaras	Servicio de Switcher, internet, grabación a 2 cámaras y serv.de programa de telepromter.\nSwitcher e internet\nproveeduría de internet\nInternet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.054 CONF.COPPEL DURANGO, DGO. 10,11 y 12  MARZO.xls)		2026-03-12	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
115	56	2026-01-23	Ana Lilia Villarreal Uribe	Coppel	2026-03-12	AGENDA CONVENION REGIONAL 2026	\N	REGION NORTE	2026-03-12	10:00:00		\N	CHIHUAHUA, CHI.		Servicio de Switcher, internet, grabación a 2 cámaras y serv.de programa de telepromter.	SALIDA: Domingo 10 de marzo en Avión\nLLEGADA: a la 1pm directo a ensayo\nENSAYO: 10 de Marzo\nPRODUCCION: CONFERENCIAS día 11 de Marzo\nGrabación a 2 cámaras\nSwitcher\nPRODUCCIÓN: 2 CONFERENCIAS día 12 (11:00am y 12:30pm)\nServicio de telepromter	Servicio de Switcher, internet, grabación a 2 cámaras y serv.de programa de telepromter.\nInternet\ninternet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.056 CONF.COPPEL, CHIHUAHUA,CH. 11 y 12  MARZO.xls)		2026-03-12	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
116	57	2026-02-03	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-02-04	SUMINISTRO INTERNET GIRAS Blv.dAgricultores	12:00:00	Blvd. Agricultores	2026-02-05	06:00:00		\N	CULIACAN		Servicio de Switcher, internet, grabación a 2 cámaras y serv.de programa de telepromter.	NOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Luz Damaris Quintero Pimentel	Servicio de Switcher, internet, grabación a 2 cámaras y serv.de programa de telepromter.\nSuministro de internet.\nStarlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.057 SUMINISTRO INTERNET GIRAS Blv.dAgricultores.xls)		2026-02-05	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
117	58	2026-02-09	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-02-09	HANGAR #10 Aniv.Fuerza Aerea Mexicana	16:00:00	Hangar #10	2026-02-10	\N		\N	CULIACAN		Circuito, proveeduría de pantallas y e internet .	VPRO:\n(circuito )\nSwitcher\n1 Consola Mini Vmix\n2 computadoras\nPeavey\n2 monitores de 65"\nKUWA:	Circuito, proveeduría de pantallas y e internet .\nSuministro de internet.\nStarlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Valdez,Cuahutemoc,Paco}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.058 HANGAR #10 Aniv.Fuerza Aerea Mexicana.xls)		2026-02-10	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
118	59	2026-02-10	Ana Lilia Villarreal Uribe	CIBACOPA	2026-02-21	PRODUCCIÓN EN ESTUDIO TV-VPRO	\N	CULIACAN- Polideportivo Juan S. Millán	2026-02-22	\N		\N	CULIACAN		Producción vía remota desde estudio y transmisión de partidos CIBACOPA.	Producción vía remota desde estudio y transmisión de partidos CIBACOPA.\nESTUDIO DE TV:\nSwitcher\nAudio\nGráficos\nRedes\nEXTERNO:\nRepeticiones				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Eduardo Valdez",Hector,Carlos,Cuauhtemoc,Javier,Manuel,Edgar}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.059 CIBACOPA- Culiacán 21 y 22 feb.xls)		2026-02-22	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
119	60	2026-02-10	Ana Lilia Villarreal Uribe	CIBACOPA	2026-02-24	PRODUCCIÓN EN ESTUDIO TV-VPRO	\N	GUASAVE	2025-02-25	\N		\N	GUASAVE		Producción vía remota desde estudio y transmisión de partidos CIBACOPA.	Producción vía remota desde estudio y transmisión de partidos CIBACOPA.\nESTUDIO DE TV:\nSwitcher\nAudio\nGráficos\nRedes\nEXTERNO:\nRepeticiones				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Eduardo Valdez",Hector,Carlos,Cuauhtemoc,Javier,Manuel,Edgar,mochis}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.060 CIBACOPA- Guasave 24 y 25 feb.xls)		2025-02-25	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
120	61	2026-02-10	Ana Lilia Villarreal Uribe	CIBACOPA	2026-02-28	PRODUCCIÓN EN ESTUDIO TV-VPRO	\N	CULIACAN- Polideportivo Juan S. Millán	2026-02-28	\N		\N	CULIACAN		Producción vía remota desde estudio y transmisión de partidos CIBACOPA.	Producción vía remota desde estudio y transmisión de partidos CIBACOPA.\nESTUDIO DE TV:\nSwitcher\nAudio\nGráficos\nProductor Deporte\nRedes\nEXTERNO:				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Eduardo Valdez",Hector,Carlos,Manuel,Edgar,Javier,"Miguel Lara","Ernesto Gutierrez","Calixo Villa","Jaime Muro","Eduardo Araujo",Ingacio}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.061 CIBACOPA- Culiacán 28feb y 01 marzo.xls)		2026-02-28	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
121	62	2026-02-10	Ana Lilia Villarreal Uribe	CIBACOPA	2026-03-06	PRODUCCIÓN EN ESTUDIO TV-VPRO	\N	CULIACAN- Polideportivo Juan S. Millán	2026-03-07	\N		\N	CULIACAN		Producción vía remota desde estudio y transmisión de partidos CIBACOPA.	Producción vía remota desde estudio y transmisión de partidos CIBACOPA.\nESTUDIO DE TV:\nSwitcher\nAudio\nGráficos\nProductor Deporte\nRedes\nEXTERNO:				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Eduardo Valdez",Hector,Carlos,Manuel,Edgar,Javier,"Miguel Lara","Ernesto Gutierrez","Calixo Villa","Jaime Muro","Eduardo Araujo",Ingacio}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.062 CIBACOPA- Culiacán 06 y 07 marzo.xls)		2026-03-07	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
122	63	2026-02-10	Ana Lilia Villarreal Uribe	CIBACOPA	2026-03-17	PRODUCCIÓN EN ESTUDIO TV-VPRO	\N	CULIACAN- Polideportivo Juan S. Millán	2026-03-18	\N		\N	CULIACAN		Producción vía remota desde estudio y transmisión de partidos CIBACOPA.	Producción vía remota desde estudio y transmisión de partidos CIBACOPA.\nESTUDIO DE TV:\nSwitcher\nAudio\nGráficos\nRedes\nEXTERNO:\nRepeticiones				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Eduardo Valdez",Hector,Carlos,Cuauhtemoc,Javier,Manuel,Edgar}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.063 CIBACOPA- Culiacán 04 y 05 abril semana santa.xls)		2026-03-18	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
123	64	2026-02-10	Ana Lilia Villarreal Uribe	CIBACOPA	2026-03-21	PRODUCCIÓN EN ESTUDIO TV-VPRO	15:00:00	CULIACAN- Polideportivo Juan S. Millán	2026-03-22	18:00:00		15:00:00	CULIACAN		Producción vía remota desde estudio y transmisión de partidos CIBACOPA.	Producción vía remota desde estudio y transmisión de partidos CIBACOPA.\nESTUDIO DE TV:\nSwitcher\nAudio\nGráficos\nRedes\nEXTERNO:\nRepeticiones				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Eduardo Valdez",Osiel,Carlos,Cuauhtemoc,Javier,"Miguel lara","Estesto Gutierrez",Manuel,Edgar,Calixo,Ignacio,"Ernesto cuen","Jaime Muro"}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.064 CIBACOPA- Culiacán 21 y 22 marzo.xls)		2026-03-22	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
124	65	2026-02-10	Ana Lilia Villarreal Uribe	CIBACOPA	2025-03-27	PRODUCCIÓN EN ESTUDIO TV-VPRO	\N	GUASAVE	2026-03-28	\N		\N	GUASAVE		Producción y transmisión de partidos CIBACOPA.	Producción y transmisión de partidos CIBACOPA.\nESTUDIO DE TV:\nSwitcher\nAudio\nGráficos\nRedes\nEXTERNO:\nRepeticiones				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Eduardo Valdez",Hector,Carlos,Cuauhtemoc,"Javier García","Miguel Lara","Ernesto Gutierrez",Manuel,Edgar,"De Mochis",Ivan,Jonathan,Ricardo}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.065 CIBACOPA- Guasave 27 y 28 marzo.xls)		2026-03-28	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
125	66	2026-04-06	Ana Lilia Villarreal Uribe	CIBACOPA	2026-04-07	PRODUCCIÓN EN ESTUDIO TV-VPRO	09:00:00	GUASAVE	2026-04-08	19:30:00		07:00:00	GUASAVE		Producción vía remota desde estudio y transmisión de partidos CIBACOPA.	Producción vía remota desde estudio y transmisión de partidos CIBACOPA.\nESTUDIO DE TV:\nSwitcher\nAudio\nGráficos\nRedes\nEXTERNO:\nRepeticiones				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Eduardo Valdez",Hector,Carlos,Cuauhtemoc,"Javier García","Ricardo Gonzalez","Ernesto Gutierrez",VPRO,Manuel,Edgar,"Ivan Martinez","Jonathan Soto","Martin Miranda"}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.066 CIBACOPA- Guasave 07 y 08 abril.xls)		2026-04-08	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
126	67	2026-02-10	Ana Lilia Villarreal Uribe	CIBACOPA	2026-04-10	PRODUCCIÓN EN ESTUDIO TV-VPRO	\N	GUASAVE	2026-04-11	\N		\N	GUASAVE		Producción vía remota desde estudio y transmisión de partidos CIBACOPA.	Producción vía remota desde estudio y transmisión de partidos CIBACOPA.\nESTUDIO DE TV:\nSwitcher\nAudio\nGráficos\nRedes\nEXTERNO:\nRepeticiones				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Eduardo Valdez",Hector,Carlos,Cuauhtemoc,Javier,Manuel,Edgar,mochis}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.067 CIBACOPA- Guasave 10 y 11 abril.xls)		2026-04-11	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
127	68	2026-02-10	Ana Lilia Villarreal Uribe	CIBACOPA	2026-04-21	PRODUCCIÓN EN ESTUDIO TV-VPRO	\N	CULIACAN- Polideportivo Juan S. Millán	2026-04-22	\N		\N	CULIACAN		Producción vía remota desde estudio y transmisión de partidos CIBACOPA.	Producción vía remota desde estudio y transmisión de partidos CIBACOPA.\nESTUDIO DE TV:\nSwitcher\nAudio\nGráficos\nRedes\nEXTERNO:\nRepeticiones				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Eduardo Valdez",Hector,Carlos,Cuauhtemoc,Javier,Manuel,Edgar}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.068 CIBACOPA- Culiacán 21 y 22 abril.xls)		2026-04-22	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
128	69	2026-02-10	Ana Lilia Villarreal Uribe	CIBACOPA	2026-04-27	PRODUCCIÓN EN ESTUDIO TV-VPRO	\N	MAZATLAN	2026-04-29	\N		\N	MAZATLÁN		Producción vía remota desde estudio y transmisión de partidos CIBACOPA.	Producción vía remota desde estudio y transmisión de partidos CIBACOPA.\nESTUDIO DE TV:\nSwitcher\nAudio\nGráficos\nRedes\nEXTERNO:\nRepeticiones				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Eduardo Valdez",Hector,Carlos,Cuauhtemoc,Javier,Manuel,Edgar,Mazatlán}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.069 CIBACOPA- Mazatlan 28 y 29 abril.xls)		2026-04-29	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
129	70	2026-02-10	Ana Lilia Villarreal Uribe	CIBACOPA	2026-05-01	PRODUCCIÓN EN ESTUDIO TV-VPRO	\N	GUASAVE	2026-05-02	\N		\N	GUASAVE		Producción vía remota desde estudio y transmisión de partidos CIBACOPA.	Producción vía remota desde estudio y transmisión de partidos CIBACOPA.\nESTUDIO DE TV:\nSwitcher\nAudio\nGráficos\nRedes\nEXTERNO:\nRepeticiones				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Eduardo Valdez",Hector,Carlos,Cuauhtemoc,Javier,Manuel,Edgar,mochis}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.070 CIBACOPA- Guasave 01 y 02 Mayo.xls)		2026-05-02	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
130	71	2026-02-10	Ana Lilia Villarreal Uribe	CIBACOPA	2026-05-05	PRODUCCIÓN EN ESTUDIO TV-VPRO	\N	CULIACAN- Polideportivo Juan S. Millán	2026-05-06	\N		\N	CULIACAN		Producción vía remota desde estudio y transmisión de partidos CIBACOPA.	Producción vía remota desde estudio y transmisión de partidos CIBACOPA.\nESTUDIO DE TV:\nSwitcher\nAudio\nGráficos\nRedes\nEXTERNO:\nRepeticiones				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Eduardo Valdez",Hector,Carlos,Cuauhtemoc,Javier,Manuel,Edgar}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.071 CIBACOPA- Culiacán 05 y 06 mayo.xls)		2026-05-06	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
131	72	2026-02-10	Ana Lilia Villarreal Uribe	CIBACOPA	2026-05-12	PRODUCCIÓN EN ESTUDIO TV-VPRO	\N	MAZATLAN	2026-05-13	\N		\N	MAZATLÁN		Producción vía remota desde estudio y transmisión de partidos CIBACOPA.	Producción vía remota desde estudio y transmisión de partidos CIBACOPA.\nESTUDIO DE TV:\nSwitcher\nAudio\nGráficos\nRedes\nEXTERNO:\nRepeticiones				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Eduardo Valdez",Hector,Carlos,Cuauhtemoc,Javier,Manuel,Edgar,Mazatlán}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.072 CIBACOPA- Mazatlan 12 y 13 mayo.xls)		2026-05-13	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
132	73	2026-02-10	Ana Lilia Villarreal Uribe	CIBACOPA	2026-05-16	PRODUCCIÓN EN ESTUDIO TV-VPRO	\N	CULIACAN- Polideportivo Juan S. Millán	2026-05-17	\N		\N	CULIACAN		Producción vía remota desde estudio y transmisión de partidos CIBACOPA.	Producción vía remota desde estudio y transmisión de partidos CIBACOPA.\nESTUDIO DE TV:\nSwitcher\nAudio\nGráficos\nRedes\nEXTERNO:\nRepeticiones				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Eduardo Valdez",Hector,Carlos,Cuauhtemoc,Javier,Manuel,Edgar}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.073 CIBACOPA- Culiacán 16 y 17 mayo.xls)		2026-05-17	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
133	74	2026-02-10	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-02-25	GIRAS-SECRET.	\N	Explanada principal palacio de gobierno	2026-02-26	17:00:00		\N	CULIACAN		Streamina a 3 cámaras y pantalla.	Streamina a 3 cámaras y pantalla.\nPRODUCCION\nCircuito cerrado a 4 cámaras y 1 fija\nStreaming\n3 monitores de 40"\nGreen screen para lenguaje de señas\nKUWA.\n1 pantalla led de 3x2m				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe producción",Hector,Valdez,Switcher,Cuauhtemoc,Redes,Paco,Tecnico,Manuel,Camarografo,Carlos,"Eduardo Araujo",Camarógrafo,Calixto}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.074- 4to..informe DIF ESTATAL explanada palacio gob..xls)		2026-02-26	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
134	75	2026-02-12	Ana Lilia Villarreal Uribe	IEES	2026-02-25	Sesiones Virtuales	\N	Estudio de TV Vpro	2026-02-25	11:00:00	Estudio TV Vpro	09:00:00	CULIACAN		Transmisión vía ZOOM de reuniones	Transmisión vía ZOOM de reuniones\nTransmision vía ZOOM\nStreaming\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Luz Damaris Quintero Pimentel				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.075- IEES Sesion Extraord. y especial -virtual 25feb26.xls)		2026-02-25	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
135	76	2026-02-16	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-02-17	GIRAS- SECRETARIAS	\N	Secundaria ETI 101 Valle Alto	2026-02-17	\N		\N	CULIACAN		STREAMING A 3 CAMARAS, PROVEEDURIA INTERNET Y PANTALLAS.	PRODUCCION:\nCircuito 3 cámaras\nTransmisión\n2 monitoresde 55" a piso\nKUWA:\n1 Pantalla led de 3x2m en base\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)	STREAMING A 3 CAMARAS, PROVEEDURIA INTERNET Y PANTALLAS.\nPoroveeduría de internet\n1 Antena Starlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.076 Eti 101 Valle Alto-Giras170226.xls)		2026-02-17	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
136	77	2026-02-16	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-02-17	GIRAS- SECRETARIAS	\N	ZONA MILITAR EL SAUZ	2026-02-17	\N		\N	Costa Rica, Sin.		PANTALLAS, PROVEEDURIA INTERNET Y SWITCHER	PRODUCCION:\n1 Switcher\nbotonera mini\n2 monitoresde 55" a piso\nKUWA:\n2 Pantalla led de 3x2m en base\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)	PANTALLAS, PROVEEDURIA INTERNET Y SWITCHER\nPoroveeduría de internet\n1 Antena Starlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.077 Día del ejercito Mexicano-Giras190226.xls)		2026-02-17	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
137	78	2026-02-21	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-02-23	LA SEMANERA	06:00:00	AUDITORIO PALACIO GOB	2026-02-23	09:00:00		06:00:00	Culiacán		STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET	PRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Juan Pablo Espino.	STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Valdez,Graficos,Hector,Carlos,Cámara,Daniel,Paco,Técnico,Gerardo,"TRADUCTORES LENGUAJE A SEÑAS",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.078  Semanera Auditorio 230226.xls)		2026-02-23	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
138	79	2026-02-23	Ana Lilia Villarreal Uribe	Coppel	2026-04-24	AGENDA CONVENION REGIONAL 2026	\N	REGION COLIMA	2026-04-24	10:00:00		\N	MANZANILLO, COLIMA		Servicio de Switcher, internet, grabación a 2 cámaras y serv.de promana telepromter.	Salida de Switcher en autobus por la tarde noche Lunes 20 Abril ,\nllegada 21 de Abril 1pm., llegada directo al ensayo.\nPRODUCCIÓN: (OSSLA) día 22/Abril\nSwitcher\nSalida de Camarógrafos en Tiida día 22 de Abril\nPRODUCCION: CONFERENCIA día 23 de Abril\nGrabación a 2 cámaras\nServicio de telepromter	Servicio de Switcher, internet, grabación a 2 cámaras y serv.de promana telepromter.\nproveeduría de internet\nInternet\ninternet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Switcher,Osiel,Camarógrafo,Gerardo,Daniel}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.079 CONF.COPPEL MANZANILLO COLIMA 22,23,y 24 Abril.xls)		2026-04-24	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
139	80	2026-02-23	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-02-24	GIRAS- SECRETARIAS	06:00:00	EXPLANADA PALACIO GOB	2026-02-24	09:00:00		06:00:00	Culiacán, Sin		PANTALLAS, PROVEEDURIA INTERNET Y SWITCHER	PRODUCCION:\nCircuito a 3 cámaras\nStreaming\nKUWA:\n1 Pantalla led de 3x2m en base\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Juan Pablo Espino	PANTALLAS, PROVEEDURIA INTERNET Y SWITCHER			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,Producción,Osiel,Switcher,Hecor,"Audio trans",Cuauhtemoc,Redes,Paco,Tecnico,Carlos,Camara,"Eduardo Araujo",Cámara,"Calixto Villa"}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.080 Día de la Bandera-Giras240226.xls)		2026-02-24	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
140	81	2026-02-10	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-02-26	MAÑANERA NACIONAL	\N	PRESIDENTA SHEINBAUM	2026-02-27	06:00:00		\N	Mazatlán, Sinaloa.		Monitores, pantalla e internet.	EVENTO #1\nPRODUCCION: LA MAÑANERA NACIONAL\n2 TV de 55" en tripie\n1 TV de 55" para medios\n1-switcher\nProveeduria dei nternet\nCATS:\n9 monitores de 55" en tripie	Monitores, pantalla e internet.\nProveeduría de internet\n1 Antena Starlink\nAntena Starlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Gerardo,Supervisa,Osiel,Switcher,Paco,Tecnico,Edgar,Redes,Daniel,Técnico}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.081 VISITA presidenta -Mazatlán.xls)		2026-02-27	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
141	82	2026-02-25	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-02-27	Anuncio de rehabilitacion Hospital General #1	\N	PRESIDENTA SHEINBAUM	2026-02-28	\N		\N	Culiacán, Sin.		Monitores, pantalla e internet.	EVENTO:#1\nEvento capacidad (3,000 personas)\n3.0\nMonitores para presidium\n6.0\nMonitores para prensa\n1.0\nswitcher para circuito	Monitores, pantalla e internet.\nProveeduría internet\nAntenas starlink\nProveduría de internet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Tecnico,Paco,Edgar,Switcher}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.082 VISITA presidenta -Culiacán.xls)		2026-02-28	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
142	83	2026-02-27	Ana Lilia Villarreal Uribe	BLAST MARKETING	2025-03-24	CONFERENCIAS	\N	RESTAURANTE CAYENA	2026-03-25	08:00:00		\N	Culiacán, Sin.		Monitores, switcher y sistema de audio	Monitores, switcher y sistema de audio\nPRODUCCION:\n2.0\nMonitores de 65" en tripie\nmicrofonos de mano inalambricos\n1.0\nvmix botonera\nclick lasser (apuntador)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.083 SERV.AUDIOVISUAL CONFERENCIAS BLAST MARKETING -REST. CAYENA.xls)		2026-03-25	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
143	84	2026-03-04	Ana Lilia Villarreal Uribe	IEES	2026-03-10	Sesiones Virtuales	09:00:00	Estudio de TV Vpro	2026-03-10	00:00:00	Estudio TV Vpro	09:00:00	CULIACAN		Transmisión vía ZOOM de reuniones	Transmisión vía ZOOM de reuniones\nTransmision vía ZOOM\nStreaming\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Luz Damaris Quintero Pimentel				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.084- IEES Sesion Extraord. y especial -virtual 11-marzo26.xls)		2026-03-10	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
144	85	2026-03-10	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-03-12	GIRAS	04:00:00	ISMUJERES	2026-03-12	06:00:00	Estudio TV Vpro	04:00:00	CULIACAN		Transmisión vía ZOOM de reuniones	Transmisión vía ZOOM de reuniones\nTransmisión a 3 cámaras\nStreaming\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Luz Damaris Quintero Pimentel	Proveduría de internet\n1 Antena starlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.085 ENLACE PRESIDENTA ISMUJERES 12MARZO26.xls)		2026-03-12	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
47	170-PRE	2026-10-30	Ana Lilia Villarreal Uribe	IEES	2026-10-30	SESION PRESENCIAL	09:30:00	Instalaciones de IEES	2026-11-03	12:00:00	Melissa León / Jennifer	09:00:00		Martin Eduardo Sanchez Estrada	trANSMISION A 3 CÁMARAS DE REUNIÓN, KIT PARA LENGUAJE DE SEÑAS				Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N	Comunicación	2026-11-03	\N				IEES	[]			0.00	f	f	\N	\N	{}	{}	{}
145	86	2026-03-13	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-03-17	LA SEMANERA	06:00:00	SALA DE USOS MULTIPLES DE USE	2026-03-17	09:00:00		06:00:00	Culiacán		STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET	PRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Juan Pablo Espino.	STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Valdez,Graficos,Hector,Carlos,Cámara,Daniel,Paco,Técnico,Gerardo,"TRADUCTORES LENGUAJE A SEÑAS",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.086  Semanera en USE 170326.xls)		2026-03-17	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
146	87	2026-03-13	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-03-19	INAUGURACION DE LA FACULTAD DE	06:00:00	FACULTAD DE MEDICINA DE LA UAS	2026-03-19	09:00:00		06:00:00	Guasave, Sinaloa.		STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET	PRODUCCION:\nCircuito a 3 cámaras\nTransmisión\n1 pantalla led de 3x2m\n2 monitores de 55"\nSatarlink\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)	STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET\nProveeduría de internet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Cuahutemoc,Redes,Osiel,Hector,Carlos,Cámara,Daniel,Manuel,Paco,Tecnico,Edgar,"En oficina captando señal",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.087 INAUGURACION FACULTAD MEDICINA EN GUASAVE.xls)		2026-03-19	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
147	88	2026-03-19	Ana Lilia Villarreal Uribe	GRUPO PARLAMENTARIO MORENA	2026-03-22	CONFERENCIA	\N	HOTEL SAN MARCOS	2026-03-22	11:00:00		\N	Culiacán		Renta de quipo audio y microfonia	Renta de quipo audio y microfonia\nPRODUCCION KUWA:\nAudio lineal 4x1 x lado para 800 personas\n06 monitores 3 x lado en pasillo con pedestal\nRack de amplificación.\n3 micrófonos inalámbricos\n01 pedestal (para podium).\nConsola de audio digital Yamaha.				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.088 GRUPO PARLAM. MORENA HOTEL SAN MARCOS.xls)		2026-03-22	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
148	89	2026-03-19	Ana Lilia Villarreal Uribe	GRUPO FGL TRADE	2026-03-24	CONFERENCIA	19:00:00	REST. CAYENA	2026-03-25	08:00:00		\N	Culiacán		Renta de quipo audio y microfonia	Renta de quipo audio y microfonia\nSERVICIO:\n2 monitores de 65" en tripie\n1 vmix botonera\n2 Laptop para descarga de archivos\n2 micrófonos de mano inalámbricos\n1 sistema de audio (2 bocinas para capacidad 30 personas)\nClicker lasser (apuntador)				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.089 GRUPO FGL TRADE .CONFERENCIA  REST. CAYENA.xls)		2026-03-25	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
149	90	2026-03-21	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-03-23	LA SEMANERA	06:00:00	AUDITORIO PALACIO GOB	2026-03-23	09:00:00		06:00:00	Culiacán		STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET	PRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción:	STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Valdez,Osiel,Graficos,Hector,Carlos,Cámara,Daniel,Paco,Técnico,Manuel,Gerardo,"TRADUCTORES LENGUAJE A SEÑAS",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.090  Semanera Auditorio 230326.xls)		2026-03-23	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
150	91	2026-03-23	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-03-24	ENLACE CON PRESIDENTA DURANTE LA MAÑANERA DEL PUEBLO	11:30:00	LOS MOCHIS	2025-03-25	06:00:00		\N	Los Mochis		STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET	PRODUCCION:\nCircuito cerrado a 3 cámaras\nTransmisión\n1 Monitor de 65" y uno de 40"\n(transmision)\nLámparas de iluminación interior (vivienda)\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)	STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET\nProveeduría internet\nantena Starlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Cuahutemoc,Redes,Valdez,Hector,Manuel,Cámara,Carlos,Calixto,EXTERNO,Paco,Técnico,"VEHICULOS A UTILIZAR",FORD,TIIDA}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.091 Enlace Presidenta mañanaera del pueblo desde Mochis 250326.xls)		2025-03-25	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
151	92	2026-03-23	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2025-03-24	BANDERAZO DE INAUGURACION	11:30:00	LOS MOCHIS	2025-03-25	\N		00:00:00	Los Mochis		Streaming a 3 cámaras y quipo audiovisual	Streaming a 3 cámaras y quipo audiovisual\nPRODUCCION:\nCircuito cerrado a 3 cámaras\nTransmisión\nSwitcher\n2 Monitor de 65" con base a piso (escenario)\nKUWA:\n1 Pantalla led de 3x2m en base a 1m. Altura	Proveeduría internet Starlink\nProveeduría de internet\nStarlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Cuahutemoc,Redes,Valdez,Hector,Manuel,Cámara,Carlos,Calixto,EXTERNO,Paco,Técnico,"VEHICULOS A UTILIZAR",FORD,TIIDA}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.092 presentacion PROGRAMA VIVIENDA BIENESTAR en Los mochis 250326.xls)		2025-03-25	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
152	93	2026-03-25	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-03-27	BANDERAZO DE INAUGURACION	\N	EN GUASAVE, SIN.	2026-03-27	\N		06:00:00	Guasave, Sin.		Streaming a 3 cámaras y quipo audiovisual	Streaming a 3 cámaras y quipo audiovisual\nPRODUCCION:\nSwitcher\n1 laptop\n2 Monitores de 55"\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción:				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Valdez,Paco,"VEHICULOS A UTILIZAR",HILUX}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.093 banderazo de inicio SEMANA SANTA en PLAYAS BELLAVISTA, GUASAVE 270326.xls)		2026-03-27	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
153	94	2026-03-27	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-03-28	ENTREGA DE TITULOS DE PROPIEDAD	14:00:00	EL DORADO	2026-03-28	16:30:00		12:00:00	El Dorado, Sin		Streaming a 3 cámaras y quipo audiovisual	Streaming a 3 cámaras y quipo audiovisual\nPRODUCCION:\nStreaming a 3 cámaras\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción:				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe producción",Osiel,Switcher,Cuahutemoc,Redes,Paco,técnico,Daniel,Camara,Calixto,Cámara,Nacho,"VEHICULOS A UTILIZAR",FORD,TIIDA}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.094 Entrega de titulos de propiedad El Dorado 280326.xls)		2026-03-28	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
154	95	2026-03-25	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-03-30	LA SEMANERA	06:00:00	AUDITORIO PALACIO GOB	2026-03-30	09:30:00		06:00:00	Culiacán		STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET	PRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Manuel Eduardo Madrid.	STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Valdez,Osiel,Graficos,Hector,Carlos,Cámara,Daniel,Paco,Técnico,Manuel,Gerardo,"TRADUCTORES LENGUAJE A SEÑAS","Beatriz y Cristina",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.095  Semanera Auditorio 300326.xls)		2026-03-30	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
155	96	2026-04-02	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-04-06	LA SEMANERA	06:00:00	AUDITORIO PALACIO GOB	2026-04-06	09:30:00		06:00:00	Culiacán		STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET	PRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Manuel Eduardo Madrid.	STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Valdez,Osiel,Graficos,Hector,Carlos,Cámara,Daniel,Paco,Técnico,Manuel,Gerardo,"TRADUCTORES LENGUAJE A SEÑAS","Beatriz y Cristina",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.096  Semanera Auditorio 060426.xls)		2026-04-06	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
156	97	2026-04-07	Ana Lilia Villarreal Uribe	IEES	2026-04-16	Transmisión de Conferencias VIA ZOOM	\N	TEATRO LINCE DE LA UA DE O	2026-04-16	10:00:00	Estudio TV Vpro	\N	CULIACAN		Transmisión vía ZOOM de reuniones	Transmisión vía ZOOM de reuniones\nPRODUCCIÓN DIA 15 DE ABRIL (mañana)\n2 cámaras (un medium ponente presencial y full a presidum\nTransmision vía ZOOM\nStreaming\nSwitcher para graficos e inserción de lenguaje de de señas\nComputadora para ponente en linea\nAdministración de Streaming a plataforma ZOOM de IEES				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.097 IEES Conferencias TEATRO UAdO.xls)		2026-04-16	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
157	98	2026-04-07	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-01-01	ENLACE CON MAÑANERA DEL PUEBLO	16:30:00	HOSPITAL GENERAL REGIONAL #1	2026-01-01	06:00:00		04:00:00	culiacan, sin		Streaming a 2 cámaras y equipo audiovisual	Streaming a 2 cámaras y equipo audiovisual\n2do.PISO\nEVENTO #1\nENLACE MAÑANERA DEL PUEBLO CON PRESIDENTA\nPRODUCCION:\n2 cámaras\nStreaming\nSwitcher	1 Starlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe producción",Cuauhtemoc,Redes,Osiel,Switcher,Paco,Técnico,Daniel,"VEHICULOS A UTILIZAR",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.098 Enlace con la mañanera del Pueblo PRESIDENTA y REUNION GOBER.xls)		2026-01-01	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
158	99	2026-04-14	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-04-15	REUNION DE SEGURIDAD	06:00:00	TEC DE MONTERREY	2026-04-16	\N		06:00:00	Culiacán		Equipo audiovisual, proveduria internet satelita y switcher.	PRODUCCION:\nSALON DE REUNIONES:\n9 TV de a piso\nSwitcher\n1 Antena Satarlink\nSALA CORONEL:_\n1 TV de en tripie\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.	Equipo audiovisual, proveduria internet satelita y switcher.\nProveeduría de internet\nsuminstro de internet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Daniel,Tecnico,Paco,Osiel,Switcher,Cuahutemoc,Redes,FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.099  Grabación Entrevista SACSA.xls)		2026-04-16	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
1	114	2026-08-13	Cuauhtemoc Rivera Agundez	GOBIERNO DEL ESTADO DE SINALOA	2026-08-13	INFORME DE RENDICION DE CUENTAS PRESIDENCIAL	18:00:00	EXPLANADA DE PALACIO DE GOBIERNO	2026-08-14	11:00:00	Giras Gobno del edo.	06:00:00	EXPLANADA DE PALACIO DE GOBIERNO	Cuauhtemoc Rivera Agundez	Produccion a 3 cmaras con streaming a plataformas oficiales	LLeven agua suficiente y checar que las pantallas de 3mm no se apaguen a cada rato	Revisar la calidad, debe de ser a 1080 minimo	Instalar 2 pantallas de 4x6 de 3mm	Reportar cualquier anomalia	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{ELEVOX,SERVIPLUS-KUWA}	{"Cuauhtemoc Rivera Agundez","Edgar Javier Amarillas","Jose Francisco Torres Sanchez"}	{"VPFord - Ford 1996","VPTiida02 - Nissan #02 2013"}	{}	CERRADA (HISTÓRICO)	\N	f	{}	{}	\N		2026-08-14	\N				EXPLANADA DE PALACIO DE GOBIERNO	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
2	131	2026-08-24	Manuel Eduardo Madrid	CESAVESIN	2026-08-17	SIMPOSIO INTERNACIONAL CONISIAPA 2026	10:00:00	Hotel el cid castilla	2026-08-20	11:00:00	Lic. Clarissa Burgeño	06:00:00	Hotel el cid castilla, Mazatlán	Martin Eduardo Sanchez Estrada	Integración de Evento: Stand, coolers, iluminacion, audio, escenografia y producción visual.	VPRO: \t\t\t\t\nCircuito cerrado a 3 cámaras\t\t\t\t\nGrabación de capacitaciones\t\t\t\t\nSistema Digital Sing para pantalla de Coffe lounge\t\t\t\t\nGrabación de video memoria de evento\t\t\t\t\nProduccion de 3 videos memoria  (Hortalizas, Acuícola y Reunión de inocuidad)		KUWA:\t\t\t\tGPO.EVENT. PACIFIC\nEscenografía de 22.50xx 4.88m \t\t\t\tPodium con TV incrustada\nAudio capacidad 1200 personas\t\t\t\tVIRA:\niluminacion arquitectónica\t\t\t\t2 Monitores 55" a piso\n2 pantallas led de 5x3m a laterales de escenografia \t\t\t\t\nAREA LAYOUT SECCION "C" SALON EL CID (Casas comerciales-exhibicion)\t\t\t\t\nKUWA:\t\t\t\t\n1 Pantalla led 3.5x2m en estructura \t\t\t\t\niluminacion arquitectónica\t\t\t\t\nSistema de audio y microfono para INAUGURACION EN ENTRADA	NOTA: EN CASO DE QUE NO QUIERAN STAN LOS EXHIBIDORES, SOLO SE REGISTRA EL MARCAJE Y SUMINISTRO DE LUZ PARA SU COBRO.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{SERVIPLUS-KUWA}	{"Martin Eduardo Sanchez Estrada","Edgar Javier Amarillas","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez","Manuel Antonio Madrid Zazueta","Osiel Cuauhtemoc Hernandez Aldape","Gerardo Villarreal Uribe"}	{"VPH100 - Hyundai 2015"}	{}	CERRADA (HISTÓRICO)	\N	f	{}	{}	\N		2026-08-20	\N				Hotel el cid castilla, Mazatlán	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
3	142-D1	2026-08-19	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-08-19	Jornadas de Paz (dia 1)	09:00:00	Costa rica, Sinaloa	2026-08-19	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:00:00	Costa rica, Sinaloa	Cuauhtemoc Rivera Agundez	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		PRODUCCIÓN:\t\t\nProveeduría de internet a 10 módulos\t\t\n2 antenas Starlink\t\t\nDistribución de linas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida04 - Nissan #04 2013"}	{}	CERRADA (HISTÓRICO)	\N	f	{}	{}	\N		2026-08-19	\N	dia 1			Costa rica, Sinaloa	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
159	100	2026-04-14	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-04-15	REUNION DE SEGURIDAD	06:00:00	TEC DE MONTERREY	2026-04-16	\N		06:00:00	Culiacán		Equipo audiovisual y 2 provedurias de internet satelita y switcher.	PRODUCCION:\nSALON DE REUNIONES:\n6 TV de a piso\nSwitcher\n1 Antena Satarlink para área reunión\nSALA CORONEL:_\n1 TV de en tripie\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.	Equipo audiovisual y 2 provedurias de internet satelita y switcher.\nProveeduría de internet\n1 Antena Starlink VIP			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Daniel,Tecnico,Paco,Osiel,Switcher,Cuahutemoc,Redes,FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.100 REUNION GABINETE-HANGAR MILITAR16 de abril.xls)		2026-04-16	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
4	142-D2	2026-08-19	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-08-20	Jornadas de paz (dia 2)	09:00:00	Costa rica, Sinaloa	2026-08-20	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:30:00	Costa rica, Sinaloa	Cuauhtemoc Rivera Agundez	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antena Starlink\t\t\nDistribución de linas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida04 - Nissan #04 2013"}	{}	CERRADA (HISTÓRICO)	\N	f	{}	{}	\N		2026-08-20	\N	dia 2			Costa rica, Sinaloa	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
5	142-D3	2026-08-20	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-08-21	Jornadas de paz (dia 3)	10:30:00	Costa Rica, Sinaloa	2026-08-21	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	10:00:00	Costa Rica, Sinaloa	Cuauhtemoc Rivera Agundez	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antena Starlink\t\t\nDistribución de linas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida04 - Nissan #04 2013"}	{}	CERRADA (HISTÓRICO)	\N	f	{}	{}	\N		2026-08-21	\N	dia 3			Costa Rica, Sinaloa	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
6	143	2026-08-22	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-08-21	ENLACE PRESIDENCIAL	06:00:00	DESPACHO DE GOBERNADOR	2026-08-21	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo) EDWIN	05:30:00	DESPACHO DE GOBERNADOR	Cuauhtemoc Rivera Agundez	Streaming a 3 cámaras, monitores de Tv.	PRODUCCIÓN:\t\tEntrada 5:30am inicia 10:00am\t\t\nStreaming\t\t\t\t\n1  cámaras c/operador\t\t\t\t\nSwitcher\t\t\t\t\nConsola de audio para transmision\t\t\t\t\nKit de refuerzo de iluminacion\t\t\t\t\n1 monitor de 50" en tripie			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez","Carlos Jacobo Quezada Mendoza"}	{}	{}	CERRADA (HISTÓRICO)	\N	f	{}	{}	\N		2026-08-21	\N				DESPACHO DE GOBERNADOR	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
7	141	2026-08-25	Manuel Eduardo Madrid	IEES	2026-08-24	Sesion virtual IEES	10:00:00	Estudio VPRO	2026-08-25	12:00:00	MELISSA-IEES	09:00:00	Estudio VPRO	Martin Eduardo Sanchez Estrada	Transmisión vía ZOOM de reunión extraordinaria y Especial		PRODUCCION:\tINCIA 12:00PM\t\t\t\nTransmision vía ZOOM\t\t\t\t\nStreaming\t\t\t\t\t\t\t\t\n\t\t\t\t\t\t\t\t\n2DA.SESION ESPECIAL EN ESTUDIO (inicia al término de la extraordinaria)		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas","Osiel Cuauhtemoc Hernandez Aldape"}	{}	{}	CERRADA (HISTÓRICO)	\N	f	{}	{}	\N		2026-08-25	\N				Estudio VPRO	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
8	144	2026-08-27	Manuel Eduardo Madrid	Casa ley	2026-08-28	COBERTURA DE 72 ANIVERSARIO LEY	07:45:00	EN PLAZA LEY SUC. (Área de Capacitación y Desarrollo)	2026-08-28	09:00:00	MANUEL CAMACHO ZAZUETA	06:00:00	EN PLAZA LEY SUC. (Área de Capacitación y Desarrollo)	Martin Eduardo Sanchez Estrada	Circuito a 3 cámaras y edición de video COLOR.	Circuito a 3 cámaras\t\tCon playera blanca los camarografos\t\t\nSwitcher\t\t\t\t\nVmix\t\t\t\t\n2 Tarimas para camarógrafos\t\t\t\t\n\t\t\t\t\n\t\t\t\t\n\t\t\t\t\nVIDEO COLOR\t\t\t\t\nVideo color de evento carlos\t\t\t\t\nGrabación a 2 cámras\t\t\t\t\nEdición y musicalización\t\t\t\t\nGráficos\t\t\t\t\nEntrega de master Full HD\t\t\t\t\nEdición máxima 1 min en vertical y horizontal			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Martin Eduardo Sanchez Estrada","Osiel Cuauhtemoc Hernandez Aldape","Manuel Antonio Madrid Zazueta","Carlos Jacobo Quezada Mendoza","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez","Gerardo Villarreal Uribe"}	{"VPTiida02 - Nissan #02 2013","VPFord - Ford 1996"}	{}	CERRADA (HISTÓRICO)	\N	f	{}	{}	\N		2026-08-28	\N				EN PLAZA LEY SUC. (Área de Capacitación y Desarrollo)	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
9	146-PRE	2026-08-31	Manuel Eduardo Madrid	H.AYUNTAMIENTO DE BADIRAGUATO	2026-09-01	SCOUTING "TEBACAS"	13:00:00	Badiraguato, Sinaloa	2026-09-01	13:00:00	H.AYUNTAMIENTO DE BADIRAGUATO	09:00:00	Badiraguato, Sinaloa	Manuel Antonio Madrid Zazueta	Pruebas de proveeduría de internet y transmisión				Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Manuel Antonio Madrid Zazueta","Edgar Javier Amarillas","Gerardo Villarreal Uribe"}	{"VPH100 - Hyundai 2015"}	{"eduardo el condor"}	CERRADA (HISTÓRICO)	\N	f	{}	{}	\N		2026-09-01	\N				Badiraguato, Sinaloa	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
160	101	2026-04-16	Ana Lilia Villarreal Uribe	IEES	2026-04-27	Sesiones Virtuales	\N	Estudio de TV Vpro	2026-04-27	14:00:00	Estudio TV Vpro	\N	CULIACAN		Transmisión vía ZOOM de reuniones	Transmisión vía ZOOM de reuniones\nTransmision vía ZOOM\nStreaming\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Luz Damaris Quintero Pimentel				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.101- IEES Sesion Virtual en estudio 27abril-26.xls)		2026-04-27	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
10	145-D1	2026-09-02	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-02	Jornada de paz (dia 1)	08:30:00	Loma de rodriguera	2026-09-02	09:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:00:00	Loma de rodriguera	Cuauhtemoc Rivera Agundez	Proveeduría de internet a módulos con Satarlink y distribución de líneas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antenas Starlink\t\t\nDistribución de linas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida04 - Nissan #04 2013"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-09-02	\N	dia 1			Loma de rodriguera	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
11	146	2026-09-12	Manuel Eduardo Madrid	H.AYUNTAMIENTO DE BADIRAGUATO	2026-09-04	LIGA DE BALONCESTO DEL PACIFICO 2026 (TEBACAS)	12:00:00	Arena de Badiraguato	2026-09-04	22:00:00	Lic. Martha Lilia Roque (área de comiunicación)	09:00:00	Arena de Badiraguato	Manuel Antonio Madrid Zazueta	Producción vía remota desde estudio y transmisión de partidos de tebacas en Badiraguato.	Switcher\t\t\t\t\nAudio\t\t\t\t\nGráficos y marcador (OCR)\t\t\t\t\nRedes\t\t\t\t\nEXTERNOS:\t\t\t\t\nRepeticiones\t\tNOTA: El 04 de Sept. 1 comentarista se va a Badiraguato acubrir la inauguración y se retorna al día siguiente para continuar en estudio.)\t\t\nComentarista #1\t\t\t\t\nComentarista #2\t\t\t\t\n\t\t\t\t\nEN CANCHA:\t\t\t\t\nProductor Deporte\t\t\t\t\n2 cámaras fijas (sin camarógrafo) para seguimiento y repeticiones	1 Antena Starlink\t\t\n4 Encoder E3 para transmisión SRT	EXTERNO:\t\t\nCamarógrafo #1 (central de seguimiento)	Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas","Carlos Jacobo Quezada Mendoza","Cuauhtemoc Rivera Agundez","Jose Francisco Torres Sanchez","Osiel Cuauhtemoc Hernandez Aldape","Manuel Antonio Madrid Zazueta"}	{}	{"eduardo el condor"}	CERRADA (HISTÓRICO)	{"2026-09-08 | H.ayuntamiento Badiraguato - Reunión para dar seguimiento a las incidencias de los eventos de liga de baloncesto del pacifico “TEBACAS”","2026-08-31 | H.ayuntamiento Badiragutao - Reunión para el arranque de los partidos de TEBACAS","2026-08-17 | H.ayuntamiento Badiraguato - Reunión para partidos de basquetbol de TEBACAS","2026-08-13 | H.ayuntamiento Badiraguato - Reunión para eventos basquetbol de TEBACAS."}	f	{}	{}	\N		2026-09-04	\N	TEBACAS			Arena de Badiraguato	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
12	145-D2	2026-09-02	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-03	Jornada de paz (dia 2)	09:00:00	LOMA DE RODRIGUERA	2026-09-03	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:30:00	LOMA DE RODRIGUERA	Cuauhtemoc Rivera Agundez	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antenas Starlink\t\t\nDistribución de linas de internet red			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida04 - Nissan #04 2013"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-09-03	\N	dia 2			LOMA DE RODRIGUERA	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
13	145-D3	2026-09-03	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-04	Jornada de la paz (dia 3)	09:00:00	LOMA DE RODRIGUERA	2026-09-04	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:30:00	LOMA DE RODRIGUERA	Cuauhtemoc Rivera Agundez	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antenas Starlink\t\t\nDistribución de linas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida04 - Nissan #04 2013"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-09-04	\N	dia 3			LOMA DE RODRIGUERA	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
161	102	2026-04-19	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-04-22	LA SEMANERA	06:00:00	AUDITORIO PALACIO GOB	2026-04-22	09:30:00		06:00:00	Culiacán		STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET	PRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nMampara de back con iserción depantalla\nAudio para auditorio\nIluminación	STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Valdez,Graficos,Hector,Carlos,Cámara,Calixto,Paco,Técnico,Manuel,"TRADUCTORES LENGUAJE A SEÑAS","Miguel y Magali","Elezar Gastelum",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.102  Semanera Auditorio 22abril26.xls)		2026-04-22	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
162	103	2026-04-21	Ana Lilia Villarreal Uribe	KUWA	2026-04-21	Evento Hotel Lucerna-KUWA- 30abril26	\N	Hotel Lucerna	2026-04-30	\N		\N	Culiacán		STREAMING A 2 CÁMARAS	STREAMING A 2 CÁMARAS\nPRODUCCION:\n2 cámaras\nTransmisión\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Manuel Eduardo Madrid.				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.103  Evento Hotel Lucerna-KUWA- 30abril26.xls)		2026-04-30	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
163	104	2026-04-21	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-04-22	CONMEMORACION DEL DIA INTERNACIONAL DEL LIBRO EVENTO : "LIBROS DE CUENTOS"	11:30:00	SALON GOBERNADORES	2026-04-22	11:20:00		\N	Culiacán		Grabación de evento.	Grabación de evento.\nPRODUCCION:\nGrabación a 3 cámaras (grabacion independiente c/u)\nSwitcher (Atenm Mini)\n1 Micro de solapa\nConsola de Audio\nENTREGA DE MATERIAL GRABADO INDEPENDIENTE DECADA CÁMARA Y ENTREGA DE MASTER SWITCHADO.\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Valdez,Graficos,Hector,Carlos,Cámara,Calixto,Paco,Técnico,Manuel,"TRADUCTORES LENGUAJE A SEÑAS",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.104  GES-cuenta cuentos 22abril26.xls)		2026-04-22	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
164	105	2026-04-22	Ana Lilia Villarreal Uribe	GRUPO PARLAMENTARIO MORENA	2025-04-24	REUNION DE INFORME SENADORA	\N	FIGLOSTASE	2025-04-25	\N		\N	Culiacán		Evento masivo	Evento masivo\nPRODUCCION VPRO:\nCircuito a 1 cámara\nSwitcher\ncomputadora\nKUWA:\n2 pantallas led de 3x2m (costado del escenario)\nMETRO:				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.105 MORENA en figlostase 25abril26.xls)		2025-04-25	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
165	106	2026-04-25	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-04-27	LA SEMANERA	06:00:00	AUDITORIO PALACIO GOB	2026-04-27	09:30:00		06:00:00	Culiacán		STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET	PRODUCCION:\nCircuito a 5 cámaras\nTransmisión\nGreen Screen para lenguaje señas\n1 monitor de 40" a piso\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Manuel Eduardo Madrid.	STREAMING A 5 CAMARAS Y PROVEEDURIA DE INTERNET			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de produccción",Edgar,Redes,Valdez,Osiel,Graficos,Hector,Carlos,Cámara,Daniel,Paco,Técnico,Manuel,"TRADUCTORES LENGUAJE A SEÑAS",FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.106  Semanera Auditorio 27abril26.xls)		2026-04-27	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
166	107	2026-05-02	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-05-04	REUNION PRIVADA DE SEGURIDAD	06:00:00	9NA ZONA MILITAR	2026-05-04	09:00:00		06:00:00	Culiacán		REPRODUCCIÓN DE MATERIAL AUDIOVISUAL DURANTE REUNIÓN.	REPRODUCCIÓN DE MATERIAL AUDIOVISUAL DURANTE REUNIÓN.\nPRODUCCION:\n3 Monitores de 65" a piso\nSwitcher\n2 computadora para material de reproducción\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Manuel Eduardo Madrid.	1 Antena Starlink para Red Wifi\nEl internet lo brindo la 9na zona con moden , solo solicitaron la Starlink para enviar Wifi a las áreas.			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Cuauhtemoc,Redes,Pedro,Switcher,Paco,Técnico,FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.107 Reunión Privada de Seguridad 9na zona militar  04mayo26.xls)		2026-05-04	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
53	174	2026-11-13	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-11-08	Firma de convenio y Rueda de Prensa	19:30:00	lll REGIÓN MILITAR CUARTEL GENERAL	2026-11-09	09:00:00	Eleazar gastelum	06:00:00	lll REGIÓN MILITAR CUARTEL GENERAL	Martin Eduardo Sanchez Estrada	STREAMING a 3 Cámaras, consola de audio, vMix y 4 pantallas de 65"	VPRO.\t\nCircuito a 3 cámaras\t\nStreaming\t\nProveeduría de internet\t\n1 Switcher\n4 monitores de 65"	2 Antenas Starlink\nProveeduría de internet		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{"VPH100 - Hyundai 2015","VPMercedes - Mercedes Benz 2022"}	{}	ACTIVA	{}	f	{/Fotos_de_eventos/evidencia_foto_OP53_1794241452219_WhatsApp_Image_2026-11-09_at_8.22.09_AM__1_.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794241452368_WhatsApp_Image_2026-11-09_at_8.22.09_AM__2_.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794241452492_WhatsApp_Image_2026-11-09_at_8.22.09_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794241452626_WhatsApp_Image_2026-11-09_at_8.22.10_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794241480213_WhatsApp_Image_2026-11-09_at_7.59.51_AM__1_.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794241480365_WhatsApp_Image_2026-11-09_at_7.59.51_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794241480512_WhatsApp_Image_2026-11-09_at_7.59.52_AM__1_.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794241480662_WhatsApp_Image_2026-11-09_at_7.59.52_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794242055730_WhatsApp_Image_2026-11-09_at_9.27.23_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794242055876_WhatsApp_Image_2026-11-09_at_9.27.24_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794242056011_WhatsApp_Image_2026-11-09_at_9.27.25_AM__1_.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794242056147_WhatsApp_Image_2026-11-09_at_9.27.25_AM__2_.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794242056293_WhatsApp_Image_2026-11-09_at_9.27.25_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794242056456_WhatsApp_Image_2026-11-09_at_9.27.26_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794242056624_WhatsApp_Image_2026-11-09_at_9.27.28_AM__1_.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794242056801_WhatsApp_Image_2026-11-09_at_9.27.28_AM__2_.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794242056946_WhatsApp_Image_2026-11-09_at_9.27.28_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794242057125_WhatsApp_Image_2026-11-09_at_9.27.29_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794242057273_WhatsApp_Image_2026-11-09_at_9.27.30_AM__1_.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794242057431_WhatsApp_Image_2026-11-09_at_9.27.30_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794242057579_WhatsApp_Image_2026-11-09_at_9.27.31_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794244315985_WhatsApp_Image_2026-11-09_at_6.47.45_AM.jpeg,/Fotos_de_eventos/evidencia_video_OP53_1794244326282_WhatsApp_Video_2026-11-09_at_6.47.33_AM.mp4,/Fotos_de_eventos/evidencia_foto_OP53_1794244335265_WhatsApp_Image_2026-11-09_at_10.05.57_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794244335482_WhatsApp_Image_2026-11-09_at_10.05.58_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794244335692_WhatsApp_Image_2026-11-09_at_10.06.00_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794244351386_WhatsApp_Image_2026-11-09_at_9.59.35_AM__1_.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794244351759_WhatsApp_Image_2026-11-09_at_9.59.35_AM__2_.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794244352166_WhatsApp_Image_2026-11-09_at_9.59.35_AM__3_.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794244352534_WhatsApp_Image_2026-11-09_at_9.59.35_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794244429480_WhatsApp_Image_2026-11-09_at_6.37.56_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP53_1794266048135_WhatsApp_Image_2026-11-09_at_3.28.49_PM.jpeg}	{}	================================================================================\nBITÁCORA OFICIAL DE CHAT OPERATIVO - VPRO WORKSPACE\nORDEN DE PRODUCCIÓN: OP-53 | EVENTO: Firma de convenio y Rueda de Prensa\nLOCACIÓN: lll REGIÓN MILITAR CUARTEL GENERAL\nFECHA DEL EVENTO: 2026-11-09 | HORA LLAMADO: 06:00:00\nPRODUCTOR RESPONSABLE: Martin Eduardo Sanchez Estrada\n--------------------------------------------------------------------------------\nESTADO: CERRADO Y SELLADO\nSELLADO POR PRODUCTOR: Martin Eduardo Sanchez Estrada\nFECHA Y HORA DE CIERRE: 2026-11-17 16:13:03\nTOTAL REGISTROS INTEGRADOS: 2 MENSAJES Y EVIDENCIAS\n================================================================================\n\n[2026-11-09 09:26:26] [ALERTA OPERATIVA] 🤖 SISTEMA VPRO:\n  🚀 Canal operativo iniciado para la OP-53: Rueda de prensa Harfuch.\n📅 Fecha: 2026-11-09 | ⏰ Llamado: 06:00 hrs | 📍 Locación: lll REGIÓN MILITAR CUARTEL GENERAL.\nTodo reporte técnico, avisos de traslado y evidencias se registrarán en esta bitácora.\n\n[2026-11-11 10:34:44] [ALERTA OPERATIVA] 🤖 SISTEMA VPRO:\n  🚐 Logística de Chofer: Chofer designado -> Manuel Antonio Madrid Zazueta.\n\n--------------------------------------------------------------------------------\nFIN DE LA BITÁCORA - EXPEDIENTE SELLADO PARA AUDITORÍA Y ACLARACIONES\n================================================================================	Giras	2026-11-09	\N				MAZATLÁN, SINALOA	[]	Martin Eduardo Sanchez Estrada	Manuel Antonio Madrid Zazueta	0.00	t	t	Martin Eduardo Sanchez Estrada	2026-11-17 16:13:03.44208	{"VPH100 - Hyundai 2015": "Manuel Antonio Madrid Zazueta", "VPMercedes - Mercedes Benz 2022": "Jose Francisco Torres Sanchez"}	{"Manuel Antonio Madrid Zazueta","Martin Eduardo Sanchez Estrada","Cuahutémoc Rivera Agúndez","Carlos Jacobo Quezada Mendoza","Osiel Cuauhtemoc Hernandez Aldape","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez"}	{"2026-11-08": "Pantalla 65 se despegó cristal por sol", "2026-11-09": "Fotografo movio tarima camara 3. Falso en puertos USB de maquina vMix."}
167	108	2026-05-02	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-05-04	RUEDA DE PRENSA DE GABINETE DE SEGURIDAD	06:00:00	9NA ZONA MILITAR	2026-05-04	10:00:00		06:00:00	Culiacán		STREAMINGA 3 CAMARAS Y EQUIPO AUDIOVISUAL	STREAMINGA 3 CAMARAS Y EQUIPO AUDIOVISUAL\nPRODUCCIÓN:\nCircuito cerrado a 3 cámaras\nStreaming\nSwitcher\n4 Tv de 65"\nKUWA:\n1 pantalla led de 3x2m	Proveduría de internet Wifi			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de producción",Osiel,Switcher,Cuahutemoc,Redes,Hector,Manuel,Cámara,Carlos,Dany,FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.108 Rueda de Prensa Gabinete de Seguridad en 9na zona militar  04mayo26.xls)		2026-05-04	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
168	109	2026-05-04	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-05-04	CLXIV ANIVERSARIO DE LA BATALLA DE PUEBLA	18:00:00	9NA ZONA MILITAR	2026-03-05	08:00:00		06:00:00	Culiacán		Circuito a 1 cámara, pantallas, monitores y proveeduria de internet.	PRODUCCIÓN:\nCircuito a 1 cámara\nStreaming (enlace con evento presidencial para toma de protesta)\nSwitcher\n2 minitores de 55" apiso\n1 M,onitor de 65" en tripie\n1 computadora para configurar enlace de imagen presidencial\nKUWA:	Circuito a 1 cámara, pantallas, monitores y proveeduria de internet.\nProveduría de internet Wifi\n2 antenas Starlink			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de producción",Osiel,Switcher,Cuahutemoc,Redes,Daniel,Camarógrafo,Paco,Técnico,FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.109 Conmemoracion Batalla de Puebla en 9na zona militar  05mayo26.xls)		2026-03-05	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
169	110	2026-05-04	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-03-05	Grabación aspectos 06mayo26	\N		2026-05-06	\N		\N	Culiacán		Circuito a 1 cámara, pantallas y monitores.	Circuito a 1 cámara, pantallas y monitores.\nPRODUCCIÓN:\nCircuito a 1 cámara\n2 monitores de 55" a piso\nSwitcher\nKUWA:\n1 pantalla 3x2m\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de producción",Osiel,Switcher,Cuahutemoc,Redes,Danie,Cámara,Paco,Técnico,FORD}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.110  Grabación aspectos   06mayo26.xls)		2026-05-06	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
170	111	2026-05-19	Ana Lilia Villarreal Uribe	ISJU	2026-05-21	Enlace de ISJU con la Conferencia del Pueblo	\N	ISJU	2026-05-22	\N		\N	Culiacán		Circuito a 1 cámara, pantallas y monitores.	Circuito a 1 cámara, pantallas y monitores.\nPRODUCCIÓN:\nStreaming\n2 cámaras\nSwitcher\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Manuel Eduardo Madrid.	Proveeduría de internet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe de producción",Osiel,Switcher,Cuahutemoc,Redes,Danie,Cámara,Manuel,Paco,Técnico}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.111 ISJU enlace presidencia  22mayo26.xls)		2026-05-22	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
14	152	2026-09-08	Cuauhtemoc Rivera Agundez	GOBIERNO DEL ESTADO DE SINALOA	2026-09-06	Reunión de gabinete	08:00:00	Salón gobernadores	2026-09-06	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	06:00:00	Salón gobernadores	Jose Francisco Torres Sanchez	MONITORES A PISO	2 monitores de 65" a piso			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez"}	{"VPFord - Ford 1996"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-09-06	\N				Salón gobernadores	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
15	153	2026-09-12	Manuel Eduardo Madrid	JAPAC	2026-09-07	Grabaciones	09:30:00	Spot para "NUEVA SUCURSAL"	2026-09-07	10:00:00	DEPTO. COMUNICACIÓN	09:00:00	Spot para "NUEVA SUCURSAL"	Gerardo Villarreal Uribe					Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Gerardo Villarreal Uribe","Jose Daniel Torres Arroyo","Carlos Jacobo Quezada Mendoza"}	{"VPTiida02 - Nissan #02 2013"}	{}	CERRADA (HISTÓRICO)	{"2026-08-31 | H.ayuntamiento Badiragutao - Reunión para el arranque de los partidos de TEBACAS","2026-08-26 | VPRO - Prueba para ISO"}	f	{}	{}	\N		2026-09-07	\N				Spot para "NUEVA SUCURSAL"	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
171	112	2026-05-19	Ana Lilia Villarreal Uribe	GOBIERNO DEL ESTADO DE SINALOA	2026-05-20	AQUATON 2026	17:00:00	EXPLANADA DE PALACIO GOBIERNO	2026-05-21	06:00:00		\N	Culiacán		Circuito a 1 cámara, pantallas y monitores.	Circuito a 1 cámara, pantallas y monitores.\nAPOYO DE VPRO\nkuwa:\n1 pantalla de 3x2m\n1 computadora\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Manuel Eduardo Madrid.				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,Supervision}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.112 AQUATON- DIF ESTATAL-APOYO  21mayo26.xls)		2026-05-21	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
172	113	2026-05-27	Ana Lilia Villarreal Uribe	IESS	2026-06-04	SESION VIRTUAL	09:00:00	ESTUDIO TV VPRO	2026-06-04	14:00:00		\N	Culiacán		Transmisión vía ZOMM de reunión extraordinaria	Transmisión vía ZOMM de reunión extraordinaria\nPRODUCCIÓN:\nTransmision vía ZOOM\nStreaming\nNOTA: Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administación y Coordinación para su debido llenado y actualización en cotización y agenda.\nElaboró: Ana Lilia Villarreal U. (Admon)\nCoordinación de Producción: Manuel Eduardo Madrid.				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{Geo,"Jefe produccion"}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.113 IEES Sesión Virtual en estudio 04-junio.xls)		2026-06-04	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
56	178	2026-11-17	Manuel Eduardo Madrid	H.AYUNTAMIENTO DE BADIRAGUATO	2026-11-13	TORNEO DE LIGA DE BALONCESTO DEL PACIFICO 2026 ASCENSO TEBACAS	11:30:00	Arena de Badiraguato	2026-11-13	18:00:00	Lic. Martha Lilia Roque	08:00:00	Arena de Badiraguato	Manuel Antonio Madrid Zazueta	Producción vía remota desde estudio y transmisión de partidos de TEBACAS en Badiraguato.	Estudio Vpro:\nSwitcher\nAudio\nGráficos y marcador (OCR)\nEN CANCHA:\t\nProductor Deporte\t\n2 cámaras fijas (sin camarógrafo) para seguimiento y repeticiones	Estudio Vpro:\nRedes\nEN CANCHA:\t\t\n1 Antena Starlink\t\n4 Encoder E3 para transmisión SRT\t\nRedes	Estudio Vpro:\nEXTERNO:\nRepeticiones\nComentarista #2\nEN CANCHA:\nComentarista #1\nCamarógrafo #1 (central de seguimiento)	Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Osiel Cuauhtemoc Hernandez Aldape","Cuahutémoc Rivera Agúndez","Carlos Jacobo Quezada Mendoza","Jose Francisco Torres Sanchez"}	{"VPToyota - Toyota Hilux"}	{"Calixto Villa","Javier Garcia","Ernesto Gutierrez","Miguel Lara"}	CERRADA (HISTÓRICO)	{}	f	{/Fotos_de_eventos/evidencia_foto_OP56_1794585994466_WhatsApp_Image_2026-11-13_at_8.18.14_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP56_1794599341777_WhatsApp_Image_2026-11-13_at_12.37.37_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP56_1794599341937_WhatsApp_Image_2026-11-13_at_12.47.52_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP56_1794958818212_WhatsApp_Image_2026-11-14_at_2.50.58_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP56_1794958818353_WhatsApp_Image_2026-11-14_at_2.52.09_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP56_1794958818472_WhatsApp_Image_2026-11-14_at_4.10.55_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP56_1794958818616_WhatsApp_Image_2026-11-15_at_1.16.49_PM.jpeg,/Fotos_de_eventos/evidencia_video_OP56_1794958819076_WhatsApp_Video_2026-11-14_at_5.34.46_PM.mp4}	{"FOLIO: 05 | 12/11/2026 - Liga de Baloncesto del pacifico 2026 Ascenso TEBACAS"}	\N	Área de comunicación	2026-11-15	\N	TEBACAS VS FOHR DE HERMOSILLO	Manuel: 8:00 AM Estudio: 3:00 PM		BADIRAGUATO	[]	Manuel Antonio Madrid Zazueta	Manuel Antonio Madrid Zazueta	0.00	t	f	\N	\N	{"VPToyota - Toyota Hilux": "Manuel Antonio Madrid Zazueta"}	{"Manuel Antonio Madrid Zazueta","Edgar Javier Amarillas"}	{"2026-11-08": "Pantalla 65 se despegó cristal por sol", "2026-11-09": "Fotografo movio tarima camara 3. Falso en puertos USB de maquina vMix.", "2026-11-13": "", "2026-11-14": "", "2026-11-15": ""}
16	154-D1	2026-09-09	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-09	Jornada de paz (Dia 1)	09:30:00	Villa Juárez	2026-09-09	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	09:00:00	Villa Juárez	Martin Eduardo Sanchez Estrada	Proveeduría de internet a módulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antenas Starlink\t\t\nDistribución de lineas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida02 - Nissan #02 2013"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-09-09	\N	Dia 1			Villa Juárez	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
17	154-D2	2026-09-10	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-10	Jornada de paz (Dia 2)	09:30:00	Villa Juárez	2026-09-10	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	09:00:00	Villa Juárez	Martin Eduardo Sanchez Estrada	Proveeduría de internet a módulos con Satarlink y distribución de líneas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antenas Starlink\t\t\nDistribución de líneas de internet red			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida02 - Nissan #02 2013"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-09-10	\N	Dia 2			Villa Juárez	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
114	55	2026-01-23	Ana Lilia Villarreal Uribe	Coppel	2026-03-12	AGENDA CONVENION REGIONAL 2026	\N	REGION NORTE	2026-03-12	10:00:00		\N	MEXICALI,BCN		Servicio de Switcher, internet, grabación a 2 cámaras y serv.de programa de telepromter.	SALIDA: Domingo 10 de marzo en Avión\nLLEGADA: a la 1pm directo a ensayo\nENSAYO: 10 de Marzo\nPRODUCCION: CONFERENCIAS día 11 de Marzo\nGrabación a 2 cámaras\nSwitcher\nPRODUCCIÓN: 2 CONFERENCIAS día 12 (11:00am y 12:30pm)\nServicio de telepromter	Servicio de Switcher, internet, grabación a 2 cámaras y serv.de programa de telepromter.\nInternet\ninternet			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	OP Histórica cerrada (migrada automáticamente desde archivo de Excel: ORDEN DE PROD.No.055 CONF.COPPEL, MEXICALI,BCN 11 y 12  MARZO.xls)		2026-03-12	\N					[]	\N	\N	0.00	f	t	Administración	\N	{}	{}	{}
18	154-D3	2026-09-10	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-11	Jornada de paz (Dia 3)	09:30:00	Villa Juárez	2026-09-11	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	09:00:00	Villa Juárez	Martin Eduardo Sanchez Estrada	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antenas Starlink\t\t\nDistribución de lineas de internet red			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida02 - Nissan #02 2013"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-09-11	\N	Dia 3			Villa Juárez	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
19	155	2026-09-17	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-14	Grito de la independencia	09:30:00	Palacio de gobierno	2026-09-15	17:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	11:00:00	Palacio de gobierno	Martin Eduardo Sanchez Estrada		Circuito a 7 cámaras\t\t\nSistema de transmision inalámbrica\t\t\nPlanta generadora de luz\t\t\t\nVuelo de Dron\t\t\nPisacables\t\t\n2 switcherTripaly para grabación\t\t\ngráficos	Distribución de lineas de internet red\nProveeduria de internet\t\nAntenas starlink	KUWA:\t\nConsola de Audio Yamaha\t\nCentro de carga\t\nSet de Cableado y extensiones	Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Martin Eduardo Sanchez Estrada","Manuel Antonio Madrid Zazueta","Osiel Cuauhtemoc Hernandez Aldape","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez","Cuauhtemoc Rivera Agundez","Carlos Jacobo Quezada Mendoza","Edgar Javier Amarillas"}	{"VPTiida02 - Nissan #02 2013","VPFord - Ford 1996","VPMercedes - Mercedes Benz 2022"}	{"Calixto Villa","eduardo el condor"}	CERRADA (HISTÓRICO)	{"2026-09-12 | Gobierno del estado de sinaloa - Instalación el 14 de septiembre para el grito de la independencia","2026-09-10 | Gobierno del estado de sinaloa - Reunión para evento del grito de la independencia","2026-09-17 | Gobierno del estado de sinaloa - Incidencias del evento grito de independencia"}	f	{}	{}	\N		2026-09-15	\N				Palacio de gobierno	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
20	157	2026-09-21	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-20	VISITA PRESIDENCIAL INFORME : Honestidad y resultados	09:30:00	Feria Ganadera	2026-09-20	13:30:00	DES.TECNOLOGICO  (Giras-Edwin)	09:00:00	Feria Ganadera	Martin Eduardo Sanchez Estrada	MONITORES Y SWITCHER	2 monitores de 65" en base elevada\t\t\n1 switcher\t\t\ndistribucion de señal			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jose Francisco Torres Sanchez","Osiel Cuauhtemoc Hernandez Aldape"}	{"VPH100 - Hyundai 2015"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-09-20	\N				Feria Ganadera	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
21	158	2026-09-29	Manuel Eduardo Madrid	IEES	2026-09-29	SESION EXTRAORDINARIA Y ESPECIAL  VIRTUAL	11:00:00	Estudio TV VPRO	2026-09-30	11:00:00	MELISSA-IEES	09:00:00	Estudio TV VPRO	Martin Eduardo Sanchez Estrada	Enlace via ZOOM  sesión Extraordinaria y Virtual desde Estudio TV		INICIA : 1ER. SESION EXTRAORDINARIA 11:00PM\t\t\t\nPRODUCCION:\t\t\t\nTransmisión vía Zoom\t\t\t\nStreaming\t\t\t\n\t\t\t\t\t\t\t\t\t\t\t\t\t\n2da.SESION ESPECIAL  ( al término de la extraordinaria)\t\t\t\nTransmisión vía Zoom\t\t\t\nStreaming		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas","Osiel Cuauhtemoc Hernandez Aldape"}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-09-30	\N				Estudio TV VPRO	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
22	159-D1	2026-09-30	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-30	Jornada de la paz (dia 1)	08:30:00	Aguaruto	2026-09-30	09:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:00:00	Estadio de futbol aguaruto	Martin Eduardo Sanchez Estrada	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n2 antenas Starlink\t\t\nDistribución de lineas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida02 - Nissan #02 2013"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-09-30	\N	dia 1			Estadio de futbol aguaruto	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
23	159-D2	2026-10-01	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-10-01	Jornada de la paz (dia 2)	09:00:00	Aguaruto	2026-10-01	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:30:00	Estadio de futbol aguaruto	Cuauhtemoc Rivera Agundez	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n2 antenas Starlink\t\t\nDistribución de lineas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-10-01	\N	dia 2			Estadio de futbol aguaruto	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
24	159-D3	2026-10-31	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-10-02	Jornada de la paz (dia 3)	09:00:00	Aguaruto	2026-10-02	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:30:00	Estadio de futbol aguaruto	Cuahutémoc Rivera Agúndez	Proveeduría de internet a módulos con Satarlink y distribución de líneas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n2 antenas Starlink\t\t\nDistribución de líneas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida02 - Nissan #02 2013"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-10-02	\N	dia 3			Estadio de futbol aguaruto	[]			0.00	f	f	\N	\N	{}	{}	{}
25	148	2026-10-05	Manuel Eduardo Madrid	H.AYUNTAMIENTO DE BADIRAGUATO	2026-10-03	TORNEO DE LIGA DE BALONCESTO DEL PACIFICO 2026  ASCENSO TEBACAS (TEBACAS VS EMPACADORES)	12:00:00	Badiraguato	2026-10-03	20:00:00	Lic. Martha Lilia Roque (área de comunicación)	09:00:00	Arena Baduraguato	Manuel Antonio Madrid Zazueta	Producción vía remota desde estudio y transmisión de partidos de tebacas en Badiraguato.	Switcher\nAudio\nGráficos\nRedes\nEXTERNO:\nRepeticiones\nComentarista #1 y #2\nEN CANCHA:\t\nProductor Deporte\t\n2 cámaras fijas (sin camarógrafo) para seguimiento y repeticiones\nEXTERNOS:\nCamarógrafo #1 (central de seguimiento)\neste esta de mas	1 Antena Starlink\n4 Encoder E3 para transmisión SRT\t\nRedes		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Manuel Antonio Madrid Zazueta","Edgar Javier Amarillas","Carlos Jacobo Quezada Mendoza","Cuauhtemoc Rivera Agundez","Jose Francisco Torres Sanchez","Osiel Cuauhtemoc Hernandez Aldape","Jose Daniel Torres Arroyo"}	{"VPFord - Ford 1996"}	{"eduardo el condor","Javier Garcia","Ernesto Gutierrez","Miguel Lara"}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-10-03	\N	TEBACAS VS EMPACADORES			Arena Baduraguato	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
26	160	2026-10-06	Manuel Eduardo Madrid	DIF Sinaloa	2026-10-05	Inauguración área de certificación	08:00:00	Cree Sinaloa	2026-10-05	10:00:00	Arq. Yadibel López Servicios Generales DIF	07:00:00	Cree Sinaloa	Martin Eduardo Sanchez Estrada	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra	Switcher	Modem	Pantallas 3x2	Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{SERVIPLUS-KUWA}	{"Osiel Cuauhtemoc Hernandez Aldape","Jose Francisco Torres Sanchez"}	{"VPFord - Ford 1996"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-10-05	\N				Cree Sinaloa	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
27	161	2026-10-06	Manuel Eduardo Madrid	ADECEM	2026-10-06	Restaurante CASA BON	09:00:00	Restaurante CASA BON	2026-10-06	11:00:00	Julio Cesar Silvas	08:30:00	Restaurante CASA BON	Martin Eduardo Sanchez Estrada	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra	Switcher\nPantallas\nConsola de audio	Modem Quantum		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jose Francisco Torres Sanchez","Osiel Cuauhtemoc Hernandez Aldape","Jose Daniel Torres Arroyo"}	{"VPFord - Ford 1996"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-10-06	\N				Restaurante CASA BON	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
28	162	2026-10-09	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-10-08	Mesa de justicia y seguridad para las mujeres	18:30:00	Ayuntamiento de Escuinapa	2026-10-09	11:00:00	Giras (Miguel)	06:00:00	Escuinapa	Martin Eduardo Sanchez Estrada	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra	PRODUCCIÓN:\n1 Switcher\t\n 4 Monitor de 65" apiso\t\nCableado de distribucion de señal			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Osiel Cuauhtemoc Hernandez Aldape","Jose Francisco Torres Sanchez","Jose Daniel Torres Arroyo"}	{"VPFord - Ford 1996"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-10-09	\N				Escuinapa	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
29	149	2026-10-12	Manuel Eduardo Madrid	H.AYUNTAMIENTO DE BADIRAGUATO	2026-10-10	TORNEO DE LIGA DE BALONCESTO DEL PACIFICO 2026  ASCENSO TEBACAS (TEBACAS VS EL ROSARIO)	12:00:00	Arena Badiraguato	2026-10-10	20:00:00	Lic. Martha Lilia Roque (área de comunicación)	09:00:00	Arena Badiraguato	Manuel Antonio Madrid Zazueta	Producción vía remota desde estudio y transmisión de partidos de tebacas en Badiraguato.	ESTUDIO DE TV:\nSwitcher\nAudio\nGráficos y marcador (OCR)\t\nRedes\nEN CANCHA:\t\nProductor Deportes\n2 cámaras fijas (sin camarógrafo) para seguimiento y repeticiones	1 Antena Starlink\t\n4 Encoder E3 para transmisión SRT\t\nRedes	EXTERNO:\nRepeticiones\nComentarista #1\nComentarista #2\nCamarógrafo #1 (central de seguimiento)	Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Manuel Antonio Madrid Zazueta","Edgar Javier Amarillas","Cuauhtemoc Rivera Agundez","Carlos Jacobo Quezada Mendoza","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez","Osiel Cuauhtemoc Hernandez Aldape"}	{"VPH100 - Hyundai 2015"}	{"Miguel Lara","Javier Garcia","Ernesto Gutierrez","eduardo el condor"}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N	DIRECCIÓN DE COMUNICACIÓN	2026-10-10	\N	TEBACAS VS EL ROSARIO	Manuel: 9:00 AM\nEstudio: 4:00 PM	Día 10/ Octubre | Partido | TEBACAS & El Rosario | Hora: 8:00 PM	BADIRAGUATO	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
30	163	2026-10-12	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-10-12	ENLACE PRESIDENCIA	05:00:00	Secretaria de seguridad publica	2026-10-12	06:00:00	DES.TECNOLOGICO (Giras-Eduardo) Edwin	04:00:00	Secretaria de seguridad publica	Martin Eduardo Sanchez Estrada	Streaming a 3 cámaras, monitores tv	2 cámaras con operador\n1 switcher\n1 vMix\n1 consola de audio para transmisión\nKit de refuerzo de iluminación\n2 computadoras\n1 monitor de 55" en tripie	Streaming\n1 Antena Starlink\nProveeduría de internet		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Martin Eduardo Sanchez Estrada","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez","Osiel Cuauhtemoc Hernandez Aldape","Cuauhtemoc Rivera Agundez"}	{"VPFord - Ford 1996"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-10-12	\N				Secretaria de seguridad publica	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
31	165	2026-10-15	Manuel Eduardo Madrid	->	2026-10-13	Rueda de prensa	09:00:00	Los portales	2026-10-13	11:00:00		08:00:00	Los portales	Pedro Villarreal Uribe	Imagen y toma de aspectos	1 cámara celular con estabilizador\nalpha\n2 micrófonos hollyland			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Carlos Jacobo Quezada Mendoza"}	{"VPTiida02 - Nissan #02 2013"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-10-13	\N				Los portales	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
32	150	2026-10-17	Manuel Eduardo Madrid	H.AYUNTAMIENTO DE BADIRAGUATO	2026-10-13	TORNEO DE LIGA DE BALONCESTO DEL PACIFICO 2026  ASCENSO TEBACAS (TEBACAS VS LA PALMA)	12:00:00	Arena Badiraguato	2026-10-13	20:00:00	Lic. Martha Lilia Roque (área de comunicación)	09:00:00	Arena Badiraguato	Manuel Antonio Madrid Zazueta	Producción vía remota desde estudio y transmisión de partidos de tebacas en Badiraguato.	ESTUDIO DE TV:\nSwitcher\nAudio\nGráficos y marcador (OCR)\nAsistente de gráficos\nRedes\nEN CANCHA:\t\t\t\nProductor Deporte\n2 cámaras fijas (sin camarógrafo) para seguimiento y repeticiones	1 Antena Starlink\n4 Encoder E3 para transmisión SRT\nRedes	EXTERNO:\nRepeticiones\nComentarista #1\nComentarista #2\nCamarógrafo #1 (central de seguimiento)	Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Manuel Antonio Madrid Zazueta","Edgar Javier Amarillas","Cuauhtemoc Rivera Agundez","Carlos Jacobo Quezada Mendoza","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez","Osiel Cuauhtemoc Hernandez Aldape"}	{"VPH100 - Hyundai 2015"}	{"Calixto Villa","Ernesto Gutierrez","Javier Garcia","Miguel Lara"}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-10-13	\N	TEBACAS VS LA PALMA			Arena Badiraguato	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
55	175	2026-11-19	Manuel Eduardo Madrid	FISCALIA GENERAL DEL ESTADO	2026-11-12	Entrega de patrullas.	16:00:00	Estacionamiento de Fiscalía	2026-11-12	10:00:00	Daniel Bustos	08:00:00	Estacionamiento de Fiscalía	Martin Eduardo Sanchez Estrada	Switcher y monitores	-2 Pantallas de 55\n-1 pantalla de 60\n-Switcher		KUWA:\n1 Pantalla led de 3x2.5m en base a1mt.	Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{SERVIPLUS-KUWA}	{"Martin Eduardo Sanchez Estrada","Osiel Cuauhtemoc Hernandez Aldape","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez"}	{"VPToyota - Toyota Hilux"}	{}	CERRADA (HISTÓRICO)	{}	f	{/Fotos_de_eventos/evidencia_foto_OP55_1794586115425_WhatsApp_Image_2026-11-12_at_6.55.17_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP55_1794586115614_WhatsApp_Image_2026-11-13_at_8.04.07_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP55_1794593791353_WhatsApp_Image_2026-11-13_at_10.16.29_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP55_1794593791531_WhatsApp_Image_2026-11-13_at_10.16.30_AM__1_.jpeg,/Fotos_de_eventos/evidencia_foto_OP55_1794593791719_WhatsApp_Image_2026-11-13_at_10.16.30_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP55_1794596749422_WhatsApp_Image_2026-11-13_at_11.47.41_AM__1_.jpeg,/Fotos_de_eventos/evidencia_foto_OP55_1794596749587_WhatsApp_Image_2026-11-13_at_11.47.41_AM__2_.jpeg,/Fotos_de_eventos/evidencia_foto_OP55_1794596749723_WhatsApp_Image_2026-11-13_at_11.47.41_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP55_1794596749846_WhatsApp_Image_2026-11-13_at_11.47.42_AM__1_.jpeg,/Fotos_de_eventos/evidencia_foto_OP55_1794596749982_WhatsApp_Image_2026-11-13_at_11.47.42_AM__2_.jpeg,/Fotos_de_eventos/evidencia_foto_OP55_1794596750111_WhatsApp_Image_2026-11-13_at_11.47.42_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP55_1794596750238_WhatsApp_Image_2026-11-13_at_11.47.43_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP55_1794596750373_WhatsApp_Image_2026-11-13_at_11.58.18_AM.jpeg}	{}	\N		2026-11-18	\N				Fiscalia	[]	Martin Eduardo Sanchez Estrada	Jose Francisco Torres Sanchez	0.00	f	f	\N	\N	{"VPToyota - Toyota Hilux": "Jose Francisco Torres Sanchez"}	{}	{"2026-11-08": "Pantalla 65 se despegó cristal por sol", "2026-11-09": "Fotografo movio tarima camara 3. Falso en puertos USB de maquina vMix."}
54	177	2026-11-12	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-11-12	Asambleas informativas	16:50:00	FRACC. Paraíso, Mapilo 0123. Ref: Parque paraíso	2026-11-12	17:00:00	Imelda Castro	16:30:00	FRACC. Paraíso, Mapilo 0123. Ref: Parque paraíso	Pedro Villarreal Uribe	Grabación				Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Carlos Jacobo Quezada Mendoza"}	{}	{}	ACTIVA	{}	f	{}	{}	\N		2026-11-12	\N				Culiacán, Sinaloa	[]	Pedro Villarreal Uribe		0.00	f	f	\N	\N	{}	{}	{"2026-11-08": "Pantalla 65 se despegó cristal por sol", "2026-11-09": "Fotografo movio tarima camara 3. Falso en puertos USB de maquina vMix."}
33	164-D1	2026-10-14	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-10-14	JORNADA DE LA PAZ (DIA 1)	09:00:00	Cedros	2026-10-14	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:00:00	Cedros	Cuauhtemoc Rivera Agundez	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\n2 antenas Starlink\nDistribución de lineas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida04 - Nissan #04 2013"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N	DIRECCION DE COMUNICACION	2026-10-14	\N	DIA 1			Cedros	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
34	164-D2	2026-10-14	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-10-15	JORNADA DE LA PAZ (DIA 2)	09:30:00	Cedros	2026-10-15	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	09:00:00	Cedros	Cuauhtemoc Rivera Agundez	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\n2 antenas Starlink\nDistribución de lineas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida04 - Nissan #04 2013"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-10-15	\N	DIA 2			Cedros	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
35	35-DIR	2026-10-15	Manuel Eduardo Madrid	ADECEM	2026-10-15	Reunión virtual con la presidenta nacional de canacintra	09:30:00	Estudio Vpro	2026-10-15	10:30:00	Julio Cesar Silva	09:00:00	Estudio Vpro	Martin Eduardo Sanchez Estrada	Enlace via ZOOM  sesión Extraordinaria y Virtual desde Estudio TV				Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas","Osiel Cuauhtemoc Hernandez Aldape","Martin Eduardo Sanchez Estrada"}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	================================================================================\nBITÁCORA OFICIAL DE CHAT OPERATIVO - VPRO WORKSPACE\nORDEN DE PRODUCCIÓN: OP-35 | EVENTO: Reunión virtual con la presidenta nacional de canacintra\nLOCACIÓN: Estudio Vpro\nFECHA DEL EVENTO: 2026-10-15 | HORA LLAMADO: 09:00:00\nPRODUCTOR RESPONSABLE: Martin Eduardo Sanchez Estrada\n--------------------------------------------------------------------------------\nESTADO: CERRADO Y SELLADO\nSELLADO POR PRODUCTOR: Martin Eduardo Sanchez Estrada\nFECHA Y HORA DE CIERRE: 2026-10-30 18:34:43\nTOTAL REGISTROS INTEGRADOS: 0 MENSAJES Y EVIDENCIAS\n================================================================================\n\n[Sin mensajes registrados durante la cobertura]\n--------------------------------------------------------------------------------\nFIN DE LA BITÁCORA - EXPEDIENTE SELLADO PARA AUDITORÍA Y ACLARACIONES\n================================================================================		2026-10-15	\N				Estudio Vpro	[]	\N	\N	0.00	f	t	Martin Eduardo Sanchez Estrada	2026-10-30 18:34:43.912838	{}	{}	{}
36	166	2026-10-15	Manuel Eduardo Madrid	->	2026-10-14	EVENTO MASIVO EN EL DORADO	14:30:00	El dorado	2026-10-14	15:00:00		14:30:00	El dorado	Pedro Villarreal Uribe	Imagen y toma de aspectos	1 cámara celular  con estabilizador de alpha\n2 micrófonos hollyland\n1 tripie			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Carlos Jacobo Quezada Mendoza"}	{"VPTiida02 - Nissan #02 2013"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-10-14	\N				El dorado	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
37	167	2026-10-15	Manuel Eduardo Madrid	Agricola del Campo	2026-10-16	Grabaciones del campo	08:30:00	Agricola del campo	2026-10-16	09:00:00	Área de comunicación	08:00:00	Agricola del campo	Gerardo Villarreal Uribe	LEVANTAMIENTO DE IMÁGENES Y GRABACIONES ESPECIALES				Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Gerardo Villarreal Uribe","Carlos Jacobo Quezada Mendoza","Jose Daniel Torres Arroyo"}	{"VPTiida02 - Nissan #02 2013"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-10-16	\N				Agricola del campo	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
38	164-D3	2026-10-15	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-10-16	JORNADAS DE LA PAZ (DIA 3)	09:30:00	Cedros	2026-10-16	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	09:00:00	Cedros	Cuauhtemoc Rivera Agundez	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\n2 antenas Starlink\nDistribución de lineas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida02 - Nissan #02 2013"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-10-16	\N	DIA 3			Cedros	[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
43	151	2026-11-07	Manuel Eduardo Madrid	H.AYUNTAMIENTO DE BADIRAGUATO	2026-10-22	TORNEO DE LIGA DE BALONCESTO DEL PACIFICO 2026  ASCENSO TEBACAS (TEBACAS VS TITANES)	11:00:00	Arena Badiraguato	2026-10-22	19:00:00	Lic. Martha Lilia Roque (área de comunicación)	09:00:00	Arena Badiraguato	Manuel Antonio Madrid Zazueta	Producción vía remota desde estudio y transmisión de partidos de tebacas en Badiraguato.	ESTUDIO DE TV: Entrada a las 15:00 pm\nSwitcher\nAudio\nGráficos y marcador (OCR)\nAsistente de gráficos\nRedes\nEN CANCHA:\nProductor Deportes\nRedes	2 Antenas Starlink\n4 Encoder E3 para transmisión SRT	EXTERNO:\nRepeticiones\nComentarista #1\nComentarista #2	Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Manuel Antonio Madrid Zazueta","Osiel Cuauhtemoc Hernandez Aldape","Edgar Javier Amarillas","Cuauhtemoc Rivera Agundez","Carlos Jacobo Quezada Mendoza","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez"}	{"VPH100 - Hyundai 2015"}	{"Javier Garcia","Miguel Lara","Ernesto Gutierrez","Calixto Villa"}	CERRADA (HISTÓRICO)	{"2026-10-19 | Ayuntamiento Badiraguato - Partidos TEBACAS"}	f	{}	{"FOLIO: 02 | 22/10/2026 - TEBACAS VS TITANES"}	\N		2026-10-22	\N	TEBACAS VS TITANES			Arena Badiraguato	[]		Manuel Antonio Madrid Zazueta	0.00	t	f	\N	\N	{"VPH100 - Hyundai 2015": "Manuel Antonio Madrid Zazueta"}	{}	{}
44	169	2026-10-23	Manuel Eduardo Madrid	RICARDO RIOS QUEVEDO	2026-10-23	Conferencia: Mtro.En Derecho Electoral José Neira García	15:00:00	Casa de los saberes jurídicos en Culiacán de la Suprema Corte de la Justicia de la Nación.	2026-10-23	16:00:00	RICARDO RIOS- Csecret. Nac, de Relaciones Públicas de CONCAAM	09:00:00	Casa de los saberes jurídicos en Culiacán de la Suprema Corte de la Justicia de la Nación.	Martin Eduardo Sanchez Estrada	Grabación de conferencia a 1 cámara.	1 cámara			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Carlos Jacobo Quezada Mendoza"}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		\N	\N					[]	\N	\N	0.00	f	f	\N	\N	{}	{}	{}
45	45-DIR	2026-10-27	Manuel Eduardo Madrid	JULIO CESAR SILVA	2026-10-26	Grabación promo diplomado	09:30:00	Estudio Vpro	2026-10-26	17:00:00	Julio Cesar Silva	09:00:00	Estudio Vpro	Martin Eduardo Sanchez Estrada		Green Screen\n1 Cámara\nkit de luz			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Martin Eduardo Sanchez Estrada","Andrea Maria Vilarreal Lopez","Carlos Jacobo Quezada Mendoza","Jose Daniel Torres Arroyo"}	{}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-10-26	\N				Estudio Vpro	[]			0.00	f	f	\N	\N	{}	{}	{}
46	168	2026-10-28	Manuel Eduardo Madrid	IEES	2026-10-27	SESION EXTRAORDINARIA Y ESPECIAL  VIRTUAL	16:00:00	Estudio Vpro	2026-10-28	11:00:00	MELISSA-IEES	09:00:00	Estudio Vpro	Martin Eduardo Sanchez Estrada	Enlace vía ZOOM  sesión Extraordinaria y Virtual desde Estudio TV		INICIA : 1ER. SESION EXTRAORDINARIA 11:00PM\t\t\t\t\nPRODUCCION:\t\t\t\t\nTransmisión vía Zoom\t\t\t\t\nStreaming\t\t\t\t\n\t\t\t\t\t\t\t\t\nINICIA 2da: SESION ESPECIAL (al termino de la extraordinaria) 13:00 PM		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas","Osiel Cuauhtemoc Hernandez Aldape"}	{}	{}	ACTIVA	{}	f	{/Fotos_de_eventos/evidencia_foto_OP46_1793217500219_evid_op_168_1.jpg,/Fotos_de_eventos/evidencia_foto_OP46_1793219571952_WhatsApp_Image_2026-10-28_at_11.31.32_AM.jpeg}	{"FOLIO: 03 | 28/10/2026 - Sesion extraordinaria IEES virtual y especial"}	\N		2026-10-28	\N		La produccion será en el Estudio Vpro		Estudio Vpro	[]			0.00	f	f	\N	\N	{}	{}	{}
48	171	2026-11-07	Manuel Eduardo Madrid	H.AYUNTAMIENTO DE BADIRAGUATO	2026-11-03	TORNEO DE LIGA DE BALONCESTO DEL PACIFICO 2026 ASCENSO TEBACAS	12:00:00	Arena Badiraguato	2026-11-03	19:00:00	Lic. Martha Lilia Roque	09:00:00	Arena Badiraguato	Manuel Antonio Madrid Zazueta	Producción vía remota desde estudio y transmisión de partidos de tebacas en Badiraguato.	Estudio Vpro:\nSwitcher\t\nAudio\t\nGráficos y marcador (OCR)\t\nAsistente de gráficos\nEN CANCHA:\t\t\t\t\nProductor Deporte\t\t\t\t\n2 cámaras fijas (sin camarógrafo) para seguimiento y repeticiones	Estudio Vpro:\nRedes\nEN CANCHA:\n1 Antena Starlink\n4 Encoder E3 para transmisión SRT\nRedes	EXTERNO:\nRepeticiones\nComentarista #1\nComentarista #2\nEXTERNO EN CANCHA:\t\t\nCamarógrafo #1 (central de seguimiento)	Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Manuel Antonio Madrid Zazueta","Edgar Javier Amarillas","Cuahutémoc Rivera Agúndez","Jose Daniel Torres Arroyo","Osiel Cuauhtemoc Hernandez Aldape","Jose Francisco Torres Sanchez"}	{"VPH100 - Hyundai 2015"}	{"Javier Garcia","Ernesto Gutierrez","Miguel Lara"}	CERRADA (HISTÓRICO)	{}	f	{/Fotos_de_eventos/evidencia_foto_OP48_1793747144968_WhatsApp_Image_2026-11-03_at_3.57.44_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP48_1793747145084_WhatsApp_Image_2026-11-03_at_3.59.14_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP48_1793808350228_WhatsApp_Image_2026-11-03_at_10.17.07_PM__1_.jpeg,/Fotos_de_eventos/evidencia_foto_OP48_1793808350395_WhatsApp_Image_2026-11-03_at_10.17.07_PM__2_.jpeg,/Fotos_de_eventos/evidencia_foto_OP48_1793808350562_WhatsApp_Image_2026-11-03_at_10.17.07_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP48_1793808350736_WhatsApp_Image_2026-11-03_at_10.17.08_PM__1_.jpeg,/Fotos_de_eventos/evidencia_foto_OP48_1793808350891_WhatsApp_Image_2026-11-03_at_10.17.08_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP48_1793923195561_WhatsApp_Image_2026-11-03_at_9.18.18_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP48_1793923195744_WhatsApp_Image_2026-11-05_at_11.48.26_AM.jpeg}	{"FOLIO: 04 | 03/11/2026 - Asenso TEBACAS"}	\N	Área de comunicación	2026-11-04	\N	Semifinales TEBACAS VS MINEROS TONICOL DEL ROSARIO	Manuel: 9:00 AM Estudio: 4:00 PM		Arena Badiraguato	[]	Manuel Antonio Madrid Zazueta	Manuel Antonio Madrid Zazueta	0.00	t	f	\N	\N	{"VPH100 - Hyundai 2015": "Manuel Antonio Madrid Zazueta"}	{}	{}
49	170	2026-11-06	Manuel Eduardo Madrid	IEES	2026-11-03	SESION EXTRAORDINARIA PRESENCIAL	08:30:00	Instalaciones IEES	2026-11-03	12:00:00	MELISSA-IEES	08:00:00	Instalaciones IEES	Martin Eduardo Sanchez Estrada	Transmisión vía ZOOM a 3 cámaras	PRODUCCIÓN:\n 3 cámaras\nVmix/Graficos\t\n2 Computadoras\t\n1 Kit de green screen para lenguaje a señas	Transmisión a redes autorizadas		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Martin Eduardo Sanchez Estrada","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez","Osiel Cuauhtemoc Hernandez Aldape","Cuahutémoc Rivera Agúndez"}	{"Hiace - Toyota "}	{"Jaime Muro","Hector Rementeria de la Rocha"}	CERRADA (HISTÓRICO)	{}	f	{/Fotos_de_eventos/evidencia_foto_OP49_1793747112122_WhatsApp_Image_2026-11-03_at_11.47.09_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP49_1793747112289_WhatsApp_Image_2026-11-03_at_11.48.01_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP49_1793747112416_WhatsApp_Image_2026-11-03_at_11.48.28_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP49_1793747112551_WhatsApp_Image_2026-11-03_at_11.49.02_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP49_1793924032658_WhatsApp_Image_2026-11-03_at_1.53.43_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP49_1793924032815_WhatsApp_Image_2026-11-03_at_8.39.15_AM.jpeg}	{}	\N		2026-11-03	\N				Instalaciones IEES	[]	Martin Eduardo Sanchez Estrada	Jose Francisco Torres Sanchez	0.00	f	f	\N	\N	{"Hiace - Toyota": "Jose Francisco Torres Sanchez"}	{}	{}
50	172	2026-11-12	Cuahutémoc Rivera Agúndez	IEES	2026-11-12	SESION EXTRAORDINARIA PRESENCIAL EN IEES	09:30:00	Instalaciones de IEES	2026-11-12	12:00:00	Melissa León / Jennifer	09:00:00	Instalaciones IEES	Martin Eduardo Sanchez Estrada	streaming 3 cámaras, kit para lenguaje de señas, graficos	-3 cámaras.\n-kit para lenguaje de señas.\n-Gráficos.\n-2 computadoras	Transmisión a redes autorizadas		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Martin Eduardo Sanchez Estrada","Manuel Antonio Madrid Zazueta","Osiel Cuauhtemoc Hernandez Aldape","Edgar Javier Amarillas","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez","Carlos Jacobo Quezada Mendoza"}	{"VPH100 - Hyundai 2015"}	{"Hector Rementeria de la Rocha"}	CERRADA (HISTÓRICO)	{}	f	{/Fotos_de_eventos/evidencia_foto_OP50_1794515618564_WhatsApp_Image_2026-11-12_at_9.51.11_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP50_1794515618706_WhatsApp_Image_2026-11-12_at_9.53.01_AM.jpeg}	{}	\N		2026-11-12	\N				Instalaciones IEES	[]	Jose Francisco Torres Sanchez	Jose Francisco Torres Sanchez	0.00	f	f	\N	\N	{"VPH100 - Hyundai 2015": "Jose Francisco Torres Sanchez"}	{}	{}
51	173	2026-11-13	Ana Lilia Villarreal Uribe	CORREDOR DE LA SALUD	2026-11-05	INAUGURACION DE CORREDOR DE LA SALUD	15:30:00	Centro	2026-11-06	17:00:00	José Valenzuela	09:00:00	Calle Hidalgo entre Callejon Coronay Aquiles Serdan	Martin Eduardo Sanchez Estrada	VPRO: Producción de video color, producción de video con imagenes, 1 monitor de 65" en base elevada,EL CID EVENTOS:  50 sillas tipo jardinera.    KUWA: suministro de escenografia templete de 3.66x2.45cm y 25cm. altura, fondo dos mamparas y lona impresa, 2 torres de iluminacion, podium, microfono cuello de ganso y sistema de audio para capacidad  de 50 personas.	VPRO:\nproduccion de video\n1 Montor de 65" en base elevada		EL CID:\n50 sillas blancas tipo jardinera\t\n\nKUWA:\t\nescenografia tipo mampara de 3.66x2.45cm y 25cm. Altura\t\nlona impresa mate\nSistema de audio capacidad 50 personas\nPodium\nMicrofono cuello de ganso para podium\t\t\t\n2 torres de iluminación con 4 luces par LED.	Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{SERVIPLUS-KUWA}	{"Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez"}	{"VPH100 - Hyundai 2015"}	{}	CERRADA (HISTÓRICO)	{}	f	{/Fotos_de_eventos/evidencia_foto_OP51_1794006638802_WhatsApp_Image_2026-11-06_at_3.28.25_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP51_1794008320046_WhatsApp_Image_2026-11-06_at_4.35.47_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP51_1794008320195_WhatsApp_Image_2026-11-06_at_4.35.48_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP51_1794008662937_WhatsApp_Image_2026-11-06_at_4.42.44_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP51_1794067408823_WhatsApp_Image_2026-11-06_at_6.07.24_PM.jpeg,/Fotos_de_eventos/evidencia_foto_OP51_1794067409223_WhatsApp_Image_2026-11-06_at_6.07.25_PM__1_.jpeg,/Fotos_de_eventos/evidencia_foto_OP51_1794067409631_WhatsApp_Image_2026-11-06_at_6.07.25_PM__2_.jpeg,/Fotos_de_eventos/evidencia_foto_OP51_1794067410016_WhatsApp_Image_2026-11-06_at_6.07.25_PM.jpeg}	{}	\N	Comite Paseo del Angel	2026-11-06	\N				Centro	[]	Jose Francisco Torres Sanchez	Jose Francisco Torres Sanchez	0.00	f	f	\N	\N	{"VPH100 - Hyundai 2015": "Jose Francisco Torres Sanchez"}	{}	{}
52	174-PRE	2026-11-11	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-11-08	Instalación de rueda de prensa	19:30:00	lll REGIÓN MILITAR CUARTEL GENERAL	2026-11-08	19:30:00		15:00:00	lll REGIÓN MILITAR CUARTEL GENERAL	Martin Eduardo Sanchez Estrada	INSTALACIÓN / STREAMING				Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{}	{"VPH100 - Hyundai 2015","VPMercedes - Mercedes Benz 2022"}	{}	CERRADA (HISTÓRICO)	{}	f	{}	{}	\N		2026-11-08	\N				MAZATLÁN, SINALOA	[]	Martin Eduardo Sanchez Estrada	Manuel Antonio Madrid Zazueta	0.00	f	f	\N	\N	{"VPH100 - Hyundai 2015": "Manuel Antonio Madrid Zazueta", "VPMercedes - Mercedes Benz 2022": "Jose Francisco Torres Sanchez"}	{}	{}
57	176	2026-11-19	Ana Lilia Villarreal Uribe	ISDE	2026-11-19	PREMIO ESTATAL DE DEPORTE 2026	11:00:00	Polideportivo Ma. del Rosario Espinoza	2026-11-19	13:30:00	Oscar	09:00:00	Polideportivo Ma. del Rosario Espinoza	Martin Eduardo Sanchez Estrada	Renta de 2 monitores de Tv de 55" en base apiso , distribucion de señal HDMI.	2 monitores a piso de 55"			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez"}	{"VPH100 - Hyundai 2015"}	{}	CERRADA (HISTÓRICO)	{}	f	{/Fotos_de_eventos/evidencia_foto_OP57_1795113380436_WhatsApp_Image_2026-11-19_at_10.59.19_AM__3_.jpeg,/Fotos_de_eventos/evidencia_foto_OP57_1795113380674_WhatsApp_Image_2026-11-19_at_10.59.19_AM__2_.jpeg,/Fotos_de_eventos/evidencia_foto_OP57_1795113380873_WhatsApp_Image_2026-11-19_at_10.59.19_AM__1_.jpeg,/Fotos_de_eventos/evidencia_foto_OP57_1795113381052_WhatsApp_Image_2026-11-19_at_10.59.19_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP57_1795114053966_WhatsApp_Image_2026-11-19_at_10.14.43_AM.jpeg}	{}	\N	Giras-	2026-11-19	\N		instalación 11:00am		Polideportivo Ma. del Rosario Espinoza	[]	Jose Francisco Torres Sanchez	Jose Francisco Torres Sanchez	0.00	f	f	\N	\N	{"VPH100 - Hyundai 2015": "Jose Francisco Torres Sanchez"}	{}	{"2026-11-08": "Pantalla 65 se despegó cristal por sol", "2026-11-09": "Fotografo movio tarima camara 3. Falso en puertos USB de maquina vMix."}
58	179	2026-11-20	Ana Lilia Villarreal Uribe	IEES	2026-12-03	SESION EXTRAORD. VIRTUAL EN ESTUDIO TV	09:30:00	ESTUDIO TV VPRO	2026-12-03	11:00:00	Melissa León	09:00:00	Estudio de TV VPRO	Martin Eduardo Sanchez Estrada					Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez"}	{"VPH100 - Hyundai 2015"}	{}	ACTIVA	{}	f	{/Fotos_de_eventos/evidencia_foto_OP57_1795113380436_WhatsApp_Image_2026-11-19_at_10.59.19_AM__3_.jpeg,/Fotos_de_eventos/evidencia_foto_OP57_1795113380674_WhatsApp_Image_2026-11-19_at_10.59.19_AM__2_.jpeg,/Fotos_de_eventos/evidencia_foto_OP57_1795113380873_WhatsApp_Image_2026-11-19_at_10.59.19_AM__1_.jpeg,/Fotos_de_eventos/evidencia_foto_OP57_1795113381052_WhatsApp_Image_2026-11-19_at_10.59.19_AM.jpeg,/Fotos_de_eventos/evidencia_foto_OP57_1795114053966_WhatsApp_Image_2026-11-19_at_10.14.43_AM.jpeg}	{}	\N	IEES-Comunicacion	2026-12-03	\N					[]		Jose Francisco Torres Sanchez	0.00	f	f	\N	\N	{"VPH100 - Hyundai 2015": "Jose Francisco Torres Sanchez"}	{}	{"2026-11-08": "Pantalla 65 se despegó cristal por sol", "2026-11-09": "Fotografo movio tarima camara 3. Falso en puertos USB de maquina vMix."}
173	180	2026-11-23	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-11-23	Rueda de prensa Harfuch	16:00:00	Hangar aéreo #10	2026-11-23	13:30:00	Eleazar gastelum	09:00:00	Hangar aéreo #10	Martin Eduardo Sanchez Estrada	STREAMING a 3 Cámaras, consola de audio, vMix y 4 pantallas de 65"	3 Camaras\nSwitcher\nvMix\n4 pantallas de 65"	2 antenas starlink\nProveeduría de internet		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Martin Eduardo Sanchez Estrada","Manuel Antonio Madrid Zazueta","Jose Daniel Torres Arroyo","Cuahutémoc Rivera Agúndez","Osiel Cuauhtemoc Hernandez Aldape","Carlos Jacobo Quezada Mendoza","Jose Francisco Torres Sanchez"}	{"VPH100 - Hyundai 2015"}	{}	ACTIVA	{}	f	{}	{}	\N	Giras	2026-11-24	\N				Culiacán, Sinaloa	[]	Martin Eduardo Sanchez Estrada	Manuel Antonio Madrid Zazueta	0.00	f	f	\N	\N	{"VPH100 - Hyundai 2015": "Manuel Antonio Madrid Zazueta"}	{}	{"2026-11-08": "Pantalla 65 se despegó cristal por sol", "2026-11-09": "Fotografo movio tarima camara 3. Falso en puertos USB de maquina vMix."}
\.


--
-- Data for Name: informes_gastos_detalle; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.informes_gastos_detalle (id_detalle, id_informe, dia_num, hotel, transporte, combustible, casetas, desayuno, comida, cenas, varios, total_dia) FROM stdin;
1	1	1	5.00	0.00	25.00	12.00	30.00	30.00	30.00	100.00	232.00
2	2	1	0.00	0.00	0.00	0.00	0.00	130.00	0.00	0.00	130.00
3	3	1	0.00	0.00	0.00	0.00	130.00	0.00	0.00	0.00	130.00
4	4	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
5	4	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
6	4	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
7	4	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
8	5	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
9	5	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
10	5	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
11	5	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
12	6	1	0.00	270.00	0.00	0.00	0.00	234.00	0.00	50.00	554.00
13	6	2	0.00	0.00	0.00	0.00	155.00	156.00	80.00	35.00	426.00
14	6	3	0.00	0.00	4000.00	1205.00	144.50	0.00	0.00	0.00	5349.50
15	6	4	0.00	0.00	0.00	0.00	650.00	630.00	900.00	0.00	2180.00
16	6	5	0.00	0.00	0.00	0.00	250.00	800.00	500.00	0.00	1550.00
17	6	6	0.00	0.00	2000.00	0.00	0.00	900.00	0.00	0.00	2900.00
18	6	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
19	6	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
20	7	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
21	8	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
22	8	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
23	8	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
24	8	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
25	8	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
26	9	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
27	9	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
28	9	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
29	9	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
30	9	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
31	9	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
32	9	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
33	9	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
39	11	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
40	11	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
41	11	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
42	11	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
43	11	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
44	11	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
45	11	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
46	12	1	1517.00	0.00	1050.29	26.00	0.00	620.00	590.00	221.00	4024.29
47	12	2	3750.00	0.00	0.00	0.00	720.00	585.00	620.00	209.00	5884.00
48	12	3	0.00	0.00	0.00	0.00	570.00	450.00	435.00	356.00	1811.00
49	12	4	0.00	0.00	0.00	0.00	450.00	0.00	0.00	78.00	528.00
50	12	5	0.00	0.00	0.00	26.00	0.00	0.00	0.00	0.00	26.00
51	12	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
52	13	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
53	14	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
54	14	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
55	15	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
56	16	1	0.00	0.00	1300.00	0.00	0.00	150.00	0.00	175.00	1625.00
57	16	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
58	16	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
59	16	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
60	17	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
61	18	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
62	18	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
63	19	1	0.00	0.00	0.00	0.00	750.00	0.00	0.00	179.00	929.00
64	19	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
65	19	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
66	20	1	1666.00	0.00	850.34	26.00	0.00	450.00	450.00	627.50	4069.84
67	20	2	0.00	0.00	0.00	26.00	500.00	0.00	0.00	0.00	526.00
68	20	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
69	20	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
70	20	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
71	20	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
72	21	1	1666.00	0.00	1000.00	26.00	0.00	470.00	470.00	338.00	3970.00
73	21	2	0.00	0.00	0.00	26.00	500.00	0.00	0.00	0.00	526.00
74	21	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
75	21	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
76	21	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
77	21	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
78	21	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
79	21	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
80	21	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
81	21	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
82	21	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
83	21	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
84	21	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
85	22	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
86	22	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
87	22	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
88	22	4	1666.00	0.00	1000.00	26.00	0.00	450.00	500.00	220.00	3862.00
89	22	5	0.00	0.00	0.00	26.00	500.00	0.00	0.00	78.00	604.00
90	22	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
91	22	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
92	23	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
93	25	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
94	26	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
95	27	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
96	28	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
97	30	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
98	31	1	1666.00	0.00	901.48	26.00	0.00	490.00	465.00	228.00	3776.48
99	31	2	2916.00	0.00	0.00	0.00	480.00	490.00	475.00	895.50	5256.50
100	31	3	0.00	0.00	0.00	26.00	490.00	0.00	0.00	0.00	516.00
101	32	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
102	33	1	0.00	0.00	1000.00	0.00	0.00	0.00	0.00	0.00	1000.00
103	34	1	2500.00	0.00	500.00	26.00	0.00	450.00	595.00	766.00	4837.00
104	34	2	2500.00	0.00	0.00	0.00	500.00	600.00	600.00	111.00	4311.00
105	34	3	0.00	0.00	0.00	26.00	600.00	0.00	0.00	0.00	626.00
106	35	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
107	36	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
108	36	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
109	36	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
110	36	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
111	36	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
112	36	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
113	36	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
\.


--
-- Data for Name: informes_gastos_maestro; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.informes_gastos_maestro (id_informe, folio_vpro, id_empleado, periodo_desde, periodo_hasta, vehiculo, km_inicial, km_final, departamento, num_personas, subtotal, monto_entregado, restante, fecha_registro, hora_registro, revisado) FROM stdin;
17	23	201	2026-10-01	2026-10-01	GENERAL (0-0)	0	0	SISTEMAS	1	0.00	0.00	0.00	2026-10-01	17:44:38.735734	t
11	10	201	2026-09-02	2026-09-08	VPTIIDA04 - NISSAN #04 2013 (152988-152988)	152988	152988	SISTEMAS	1	0.00	0.00	0.00	2026-09-08	18:41:42.124758	t
1	1	201	2026-08-13	2026-08-13	VPFORD - FORD 1996 (1-50), VPTIIDA02 - NISSAN #02 2013 (2-52)	3	102	SISTEMAS	3	232.00	500.00	268.00	2026-08-13	13:58:08.564469	t
2	3	201	2026-08-19	2026-08-19	VPTIIDA04 - NISSAN #04 2013 (152738-152823)	152738	152823	SISTEMAS	1	130.00	500.00	370.00	2026-08-19	18:08:21.591692	t
3	4	201	2026-08-20	2026-08-20	VPTIIDA04 - NISSAN #04 2013 (152823-152823)	152823	152823	SISTEMAS	1	130.00	0.00	-130.00	2026-08-20	18:14:15.802112	t
4	5	201	2026-08-21	2026-08-24	VPTIIDA04 - NISSAN #04 2013 (152905-152988)	152905	152988	SISTEMAS	1	0.00	0.00	0.00	2026-08-24	11:32:12.26162	t
5	6	201	2026-08-21	2026-08-24	GENERAL (0-0)	0	0	SISTEMAS	2	0.00	0.00	0.00	2026-08-24	11:33:04.970944	t
8	13	201	2026-09-04	2026-09-08	VPTIIDA04 - NISSAN #04 2013 (152988-152988)	152988	152988	SISTEMAS	1	0.00	0.00	0.00	2026-09-08	18:39:31.628321	t
7	12	201	2026-09-03	2026-09-03	VPTIIDA04 - NISSAN #04 2013 (152988-152988)	152988	152988	SISTEMAS	1	0.00	0.00	0.00	2026-09-03	18:04:05.032205	t
12	11	119	2026-09-04	2026-09-09	GENERAL (0-0)	0	0	PRODUCCION	6	12273.29	12500.00	226.71	2026-09-09	19:33:41.424339	t
16	19	107	2026-09-14	2026-09-17	VPTIIDA02 - NISSAN #02 2013 (102-102), VPFORD - FORD 1996 (102-102), VPMERCEDES - MERCEDES BENZ 2022	204	204	PRODUCCION	8	1625.00	1800.00	175.00	2026-09-17	19:32:52.844773	t
25	33	201	2026-10-14	2026-10-14	VPTiida04 - Nissan #04 2013 (152988-152988)	152988	152988	SISTEMAS	1	0.00	0.00	0.00	2026-10-30	01:13:06.607953	t
26	38	201	2026-10-16	2026-10-16	VPTiida02 - Nissan #02 2013 (204-204)	204	204	SISTEMAS	1	0.00	0.00	0.00	2026-10-30	01:13:07.209307	t
21	25	119	2026-10-03	2026-10-15	VPFORD - FORD 1996 (204-204)	204	204	PRODUCCION	7	4496.00	5500.00	1004.00	2026-10-15	09:19:44.560798	t
28	43	201	2026-10-22	2026-10-22	VPH100 - Hyundai 2015 (0-0)	0	0	SISTEMAS	1	0.00	0.00	0.00	2026-10-30	01:13:08.30057	t
20	29	119	2026-10-10	2026-10-15	VPH100 - HYUNDAI 2015 (0-0)	0	0	PRODUCCION	7	4595.84	5000.00	404.16	2026-10-15	09:15:24.593996	t
15	18	107	2026-09-11	2026-09-11	VPTIIDA02 - NISSAN #02 2013 (102-102)	102	102	SISTEMAS	1	0.00	0.00	0.00	2026-09-11	19:33:24.120755	t
33	50	104	2026-11-12	2026-11-12	VPH100 - Hyundai 2015 (195490-195490)	195490	195490	PRODUCCION	1	1000.00	0.00	-1000.00	2026-11-17	23:37:58.02073	t
18	22	107	2026-09-30	2026-10-01	VPTIIDA02 - NISSAN #02 2013 (204-204)	204	204	SISTEMAS	1	0.00	0.00	0.00	2026-10-01	17:45:00.95576	t
34	56	119	2026-11-13	2026-11-15	VPToyota - Toyota Hilux (195980-196136)	195980	196136	PRODUCCION	1	9774.00	9800.00	26.00	2026-11-18	23:39:31.506646	t
32	51	104	2026-11-06	2026-11-06	VPH100 - Hyundai 2015 (195490-195490)	195490	195490	PRODUCCION	1	0.00	0.00	0.00	2026-11-07	16:31:33.232426	t
31	48	119	2026-11-03	2026-11-05	VPH100 - Hyundai 2015 (195298-195490)	195298	195490	PRODUCCION	1	9548.98	10000.00	451.02	2026-11-06	20:38:46.712737	t
35	57	104	2026-11-19	2026-11-19	VPH100 - Hyundai 2015 (196173-196189)	196173	196189	PRODUCCION	1	0.00	0.00	0.00	2026-11-19	20:08:09.045497	t
23	46	107	2026-10-27	2026-10-27	VPTiida04 - Nissan #04 2013 (152988-152988)	152988	152988	SISTEMAS	1	0.00	0.00	0.00	2026-10-30	01:12:36.428241	t
27	34	119	2026-10-15	2026-10-15	VPTiida04 - Nissan #04 2013 (152988-152988)	152988	152988	SISTEMAS	1	0.00	0.00	0.00	2026-10-30	01:13:07.775091	t
36	55	107	2026-11-12	2026-11-18	VPToyota - Toyota Hilux (196136-196136)	196136	196136	PRODUCCION	1	0.00	0.00	0.00	2026-11-20	20:31:07.391142	t
30	49	107	2026-11-03	2026-11-03	VPFord - Ford 1996 (204-204)	204	204	PRODUCCION	1	0.00	0.00	0.00	2026-11-05	23:39:56.151238	t
19	30	107	2026-10-12	2026-10-14	VPFORD - FORD 1996 (204-204)	204	204	PRODUCCION	5	929.00	0.00	-929.00	2026-10-14	10:54:24.437627	t
6	2	107	2026-08-17	2026-08-24	VPH100 - HYUNDAI 2015 (0-0)	0	0	PRODUCCION	7	12959.50	14000.00	1040.50	2026-08-24	17:44:46.156212	t
22	32	119	2026-10-13	2026-10-19	VPH100 - HYUNDAI 2015 (0-0)	0	0	PRODUCCION	7	4466.00	5000.00	534.00	2026-10-19	13:23:54.074253	t
9	9	119	2026-09-01	2026-09-08	VPH100 - HYUNDAI 2015 (0-0)	0	0	SISTEMAS	3	0.00	0.00	0.00	2026-09-08	18:40:07.433828	t
13	17	107	2026-09-10	2026-09-10	VPTIIDA02 - NISSAN #02 2013 (102-102)	102	102	SISTEMAS	1	0.00	0.00	0.00	2026-09-10	17:28:43.589218	t
14	16	107	2026-09-09	2026-09-10	VPTIIDA02 - NISSAN #02 2013 (102-102)	102	102	SISTEMAS	1	0.00	0.00	0.00	2026-09-10	17:54:12.304785	t
\.


--
-- Data for Name: kits_empleados; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.kits_empleados (id_kit, id_empleado, nombre_kit, items) FROM stdin;
124	107	MEDICAMENTO	[{"ID": "VPRO_ALT_24702", "CANT": 1, "EQUIPO": "pepto", "OBSERVACIONES": null}]
95	124	Mi inventario	[{"ID": "Inv_Vpro_alt_00095", "CANT": 1, "EQUIPO": "IMPRESORA SAMSUNG EXPRESS M2022", "OBSERVACIONES": "se trabo"}, {"ID": "Inv_Vpro_alt_00096", "CANT": 1, "EQUIPO": "TELEFONO PANASONIC", "OBSERVACIONES": "no funcionaba la linea"}]
145	113	Kit paraguas	[{"ID": "Inv_Vpro_alt_00137", "CANT": 1, "EQUIPO": "paraguas", "OBSERVACIONES": "None"}]
167	107	tablet	[{"ID": "Inv_Vpro_alt_00232", "CANT": 1, "EQUIPO": "tablet", "OBSERVACIONES": "None"}]
205	113	Grabación 	[{"ID": "Inv_Vpro_alt_00236", "CANT": 1, "EQUIPO": "Camara Alpha Viii", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00254", "CANT": 1, "EQUIPO": "Estabilizador DJI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00255", "CANT": 1, "EQUIPO": "Cargador Camara Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00256", "CANT": 1, "EQUIPO": "Baterias Sony Alpha", "OBSERVACIONES": "None"}]
225	200	Kit edición Andrea	[{"ID": "Inv_alt_2000001", "CANT": 1, "EQUIPO": "Computadora Mac", "OBSERVACIONES": "[CUST_EQ:Computadora Mac] Computadora MAC asignada a Andrea"}, {"ID": "Inv_alt_2000002", "CANT": 1, "EQUIPO": "Disco Duro", "OBSERVACIONES": "[CUST_EQ:Disco Duro] Disco duro con nombre \\"Vmix\\""}]
394	201	Kit_en_Ofna_Estudio	[{"ID": "INV_VPRO_ALT_00179", "EQUIPO": "Pisa Cable", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2010011", "EQUIPO": "Inv_Vpro_alt_00140 - Cables ethernet largos", "OBSERVACIONES": "[CUST_EQ:Inv_Vpro_alt_00140 - Cables ethernet largos]"}]
415	201	Jornadas de paz basico	[{"ID": "INV_VPRO_ALT_00023", "EQUIPO": "pisacables", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "EQUIPO": "tripie", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020021", "EQUIPO": "Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010006", "EQUIPO": "UPS (No break) Koblenz CODIGO VPNRED097", "OBSERVACIONES": ""}]
85	109	Semanera	[{"ID": "Inv_Vpro_alt_00088", "CANT": 1, "EQUIPO": "vMix", "OBSERVACIONES": "None"}]
419	109	Kit de estudio	[{"ID": "INV_VPRO_ALT_26708", "EQUIPO": "Apuntador", "OBSERVACIONES": ""}]
379	105	Grito de independecia	[{"ID": "INV_ALT_1050008", "EQUIPO": "luces", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090001", "EQUIPO": "Century", "OBSERVACIONES": ""}]
421	119	JUEGO TEBACAS 16 DE OCTUBRE DE 2026	[{"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190029", "EQUIPO": "lineas de energia", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "cinta gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190007", "EQUIPO": "bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190050", "EQUIPO": "pizacables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190051", "EQUIPO": "Trpies", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190052", "EQUIPO": "Diademas camarografos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020036", "EQUIPO": "Audifonos behringer HC200 (GERARDO)", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00153", "EQUIPO": "Mesa grande", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190072", "EQUIPO": "Mesa chica", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190073", "EQUIPO": "Mochila azul", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090044", "EQUIPO": "cable SDI corto", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190074", "EQUIPO": "cable SDI mediano", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190075", "EQUIPO": "mini contactos de energía blancos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190076", "EQUIPO": "mini converter blackmagig", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190077", "EQUIPO": "escalador decimator", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190079", "EQUIPO": "abanicos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190037", "EQUIPO": "lampara portatil", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190082", "EQUIPO": "pedestales para lampara y gopro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190038", "EQUIPO": "micrófono de maraca", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190039", "EQUIPO": "atem sdi", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190034", "EQUIPO": "BARRA DE ENERGIA", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00151", "EQUIPO": "cables hdmi gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190040", "EQUIPO": "baterías para monitor", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190042", "EQUIPO": "monitores liliput", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190044", "EQUIPO": "monitor 21.5 pulgadas", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00202", "EQUIPO": "2 Sistema de comunicación (6 bodis)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190045", "EQUIPO": "memorias sxs", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190046", "EQUIPO": "cámaras miniblack", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190047", "EQUIPO": "cable SDI largos ( 3 LARGOS NEGROS Y 2 LILAS)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190048", "EQUIPO": "lineas de audio largas", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190081", "EQUIPO": "camara go pro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190080", "EQUIPO": "Hielera", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190049", "EQUIPO": "microfonos para ambiente", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00045", "EQUIPO": "CAMARAS 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "EQUIPO": "baterías para cámara 320", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190083", "EQUIPO": "memoria SD", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1190084", "EQUIPO": "Rack con vectorscopio", "OBSERVACIONES": "[CUST_EQ:Rack con vectorscopio]"}]
342	201	Juegos Tebacas	[{"ID": "INV_VPRO_ALT_00012", "EQUIPO": "Computadora de escritorio con dos monitores", "OBSERVACIONES": "⚠️ [LLEVA DAÑO REPORTADO]"}]
345	113	JAPAC	[{"ID": "Inv_alt_1130017", "EQUIPO": "Cámara FS7", "OBSERVACIONES": "[CUST_EQ:Cámara FS7]"}, {"ID": "Inv_alt_1130018", "EQUIPO": "Alpha", "OBSERVACIONES": "[CUST_EQ:Alpha]"}]
89	104	Enlace ISJU Presidencia 	[{"ID": "Inv_Vpro_alt_00042", "CANT": 1, "EQUIPO": "Pantalla  \\"", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00052", "CANT": 3, "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00053", "CANT": 3, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00055", "CANT": 1, "EQUIPO": "Base de Fierro Alta", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00059", "CANT": 4, "EQUIPO": "Pisa Cable (Yellow Jacket)", "OBSERVACIONES": "2,7,9,13"}, {"ID": "Inv_Vpro_alt_00060", "CANT": 1, "EQUIPO": "Corral", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00061", "CANT": 1, "EQUIPO": "Tela Corral", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00062", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00063", "CANT": 2, "EQUIPO": "Silla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00065", "CANT": 1, "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00067", "CANT": 4, "EQUIPO": "Cable SDI", "OBSERVACIONES": ""}]
429	201	Kit_en_Ofna_Estudio	[{"ID": "INV_VPRO_ALT_00179", "EQUIPO": "Pisa Cable", "OBSERVACIONES": ""}]
462	113	Kit Grabaciones	[{"ID": "Inv_Vpro_alt_00236", "EQUIPO": "Camara Alpha Viii", "OBSERVACIONES": "None"}, {"ID": "INV_ALT_1130028", "EQUIPO": "Jaula para cámara", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130026", "EQUIPO": "Micrófonos hollyland", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "EQUIPO": "Tripie", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00237", "EQUIPO": "Baterias Sony", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190042", "EQUIPO": "monitores liliput", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00254", "EQUIPO": "Estabilizador DJI", "OBSERVACIONES": ""}]
99	200	EQUIPO EN AREA DE EDICION	[{"ID": "Inv_Vpro_alt_00106", "CANT": 1, "EQUIPO": "Silla1", "OBSERVACIONES": "El respaldo de la silla esta dañando por lo cual no se puede sostener solo."}, {"ID": "Inv_Vpro_alt_00107", "CANT": 1, "EQUIPO": "Silla2", "OBSERVACIONES": "El respaldo de la silla esta dañando por lo cual no se puede sostener solo."}, {"ID": "Inv_Vpro_alt_00108", "CANT": 1, "EQUIPO": "Silla3", "OBSERVACIONES": "La base donde están las llantas  esta quebrada y se extravió una llanta."}, {"ID": "Inv_Vpro_alt_00109", "CANT": 1, "EQUIPO": "Silla1 de tela", "OBSERVACIONES": "La base donde están las llantas  esta quebrada y se extravió una llanta."}, {"ID": "Inv_Vpro_alt_00110", "CANT": 1, "EQUIPO": "Silla2 de tela", "OBSERVACIONES": "La base donde están las llantas  esta quebrada y se extravió  dos llantas."}]
93	119	Semanera	[{"ID": "Inv_Vpro_alt_00045", "CANT": 1, "EQUIPO": "Camaras", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00045", "CANT": 1, "EQUIPO": "Tripies", "OBSERVACIONES": ""}]
113	104	INFORME RENDICIÓN DE CUENTAS PRESIDENCIA	[{"ID": "VPRO_ALT_16389", "CANT": 7, "EQUIPO": "Cables SDI", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16418", "CANT": 6, "EQUIPO": "Extensiones", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16445", "CANT": 3, "EQUIPO": "HDMI", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16456", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16469", "CANT": 3, "EQUIPO": "Sillas", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16484", "CANT": 1, "EQUIPO": "Carpa", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16514", "CANT": 10, "EQUIPO": "Pisa Cables Yellow Jacket", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16530", "CANT": 2, "EQUIPO": "Multicontactos", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16540", "CANT": 1, "EQUIPO": "Abanico", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16556", "CANT": 1, "EQUIPO": "Grabadoras", "OBSERVACIONES": null}]
79	104	Kit 5 de mayo batalla de puebla	[{"ID": "Inv_Vpro_alt_00042", "CANT": 1, "EQUIPO": "Pantalla  \\"", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00052", "CANT": 1, "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00053", "CANT": 1, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00054", "CANT": 1, "EQUIPO": "Base de Guitarra", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00057", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 4", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00058", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 2", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00059", "CANT": 1, "EQUIPO": "Pisa Cable (Yellow Jacket)", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00062", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00063", "CANT": 1, "EQUIPO": "Silla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00065", "CANT": 1, "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00066", "CANT": 1, "EQUIPO": "Tela para Pantalla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00076", "CANT": 1, "EQUIPO": "Control Remoto Pantalla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00083", "CANT": 1, "EQUIPO": "Carpa", "OBSERVACIONES": ""}]
83	104	Reunion privada seguridad	[{"ID": "Inv_Vpro_alt_00042", "CANT": 1, "EQUIPO": "Pantalla  \\"", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00052", "CANT": 1, "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00053", "CANT": 1, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00054", "CANT": 1, "EQUIPO": "Base de Guitarra", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00055", "CANT": 1, "EQUIPO": "Base de Fierro Alta", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00057", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 4", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00058", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 2", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00059", "CANT": 1, "EQUIPO": "Pisa Cable (Yellow Jacket)", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00065", "CANT": 1, "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00066", "CANT": 1, "EQUIPO": "Tela para Pantalla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00087", "CANT": 1, "EQUIPO": "Control Remoto Pantalla", "OBSERVACIONES": ""}]
86	109	CIBACOPA	[{"ID": "Inv_Vpro_alt_00088", "CANT": 1, "EQUIPO": "vMix", "OBSERVACIONES": "None"}]
97	119	Evento Especial	[{"ID": "Inv_Vpro_alt_00045", "CANT": 2, "EQUIPO": "Tripies", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00045", "CANT": 2, "EQUIPO": "camaras 320", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00097", "CANT": 4, "EQUIPO": "baterias", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00098", "CANT": 4, "EQUIPO": "fuentes de poder", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00099", "CANT": 6, "EQUIPO": "radios", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00100", "CANT": 1, "EQUIPO": "balanceador", "OBSERVACIONES": "None"}]
80	104	Reunion informa senadora	[{"ID": "Inv_Vpro_alt_00052", "CANT": 1, "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00053", "CANT": 1, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00059", "CANT": 1, "EQUIPO": "Pisa Cable (Yellow Jacket)", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00060", "CANT": 1, "EQUIPO": "Corral", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00061", "CANT": 1, "EQUIPO": "Tela Corral", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00062", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00063", "CANT": 1, "EQUIPO": "Silla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00064", "CANT": 1, "EQUIPO": "Diablito", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00065", "CANT": 1, "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00067", "CANT": 1, "EQUIPO": "Cable SDI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00068", "CANT": 1, "EQUIPO": "Balanceador", "OBSERVACIONES": ""}]
118	200	EQUIPO AREA EDICION	[{"ID": "Inv_Vpro_alt_00106", "CANT": 1, "EQUIPO": "Silla1", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00107", "CANT": 1, "EQUIPO": "Silla2", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00108", "CANT": 1, "EQUIPO": "Silla3", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00109", "CANT": 1, "EQUIPO": "Silla1 de tela", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00110", "CANT": 1, "EQUIPO": "Silla2 de tela", "OBSERVACIONES": ""}]
84	201	Kit para CIBACOPA	[{"ID": "Inv_Vpro_alt_00012", "CANT": 1, "EQUIPO": "Computadora de escritorio con dos monitores", "OBSERVACIONES": ""}]
445	105	Asistente	[{"ID": "Inv_alt_1190050", "EQUIPO": "pizacables", "OBSERVACIONES": ""}]
120	104	INFORME RENDICION DE CUENTAS PRESIDENCIA	[{"ID": "VPRO_ALT_16389", "CANT": 7, "EQUIPO": "Cables SDI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16418", "CANT": 8, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16445", "CANT": 5, "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16456", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16469", "CANT": 3, "EQUIPO": "Sillas", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16484", "CANT": 1, "EQUIPO": "Carpa", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16514", "CANT": 10, "EQUIPO": "Pisa Cables Yellow Jacket", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16530", "CANT": 2, "EQUIPO": "Multicontactos", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16540", "CANT": 2, "EQUIPO": "Abanico", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16556", "CANT": 1, "EQUIPO": "Grabadoras", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_74716", "CANT": 1, "EQUIPO": "abanico", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_17725", "CANT": 1, "EQUIPO": "base metal para monitor", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_17765", "CANT": 1, "EQUIPO": "base de guitarra", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_17836", "CANT": 1, "EQUIPO": "monitor de 65\\"", "OBSERVACIONES": null}]
131	109	ENLACE PRESIDENTA	[{"ID": "VPRO_ALT_26256", "CANT": 1, "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26284", "CANT": 1, "EQUIPO": "laptop Vmix g7", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26302", "CANT": 1, "EQUIPO": "Atem", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26326", "CANT": 1, "EQUIPO": "consola audio (mini vMix)", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26361", "CANT": 1, "EQUIPO": "mac #3", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26418", "CANT": 1, "EQUIPO": "hub 1x7", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26466", "CANT": 3, "EQUIPO": "cables XLR", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26558", "CANT": 2, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "peavey", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26642", "CANT": 1, "EQUIPO": "modem Quantum", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": null}]
57	118	Cibacopa	[{"ID": "Inv_Vpro_alt_00043", "CANT": 1, "EQUIPO": "consola  16 canales", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00043", "CANT": 1, "EQUIPO": "transmisor sony", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00043", "CANT": 2, "EQUIPO": "Receptor Sony", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00043", "CANT": 1, "EQUIPO": "Interfase de Audio", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00043", "CANT": 1, "EQUIPO": "shark berihenger", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00043", "CANT": 1, "EQUIPO": "microfono shure de mano", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00044", "CANT": 1, "EQUIPO": "pedestal", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00044", "CANT": 1, "EQUIPO": "diadema de monitoreo", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00044", "CANT": 2, "EQUIPO": "chicharos para conduccion", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00044", "CANT": 2, "EQUIPO": "microfono lavalier sony", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00044", "CANT": 1, "EQUIPO": "pekey", "OBSERVACIONES": ""}]
59	119	cibacopa	[{"ID": "Inv_Vpro_alt_00045", "CANT": 4, "EQUIPO": "camaras", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00045", "CANT": 4, "EQUIPO": "tripies", "OBSERVACIONES": ""}]
63	105	SEMANERA 	[{"ID": "Inv_Vpro_alt_00048", "CANT": 1, "EQUIPO": "GO PRO", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00048", "CANT": 1, "EQUIPO": "LUCES", "OBSERVACIONES": ""}]
81	104	Fortalecimiento Kit Infantil	[{"ID": "Inv_Vpro_alt_00042", "CANT": 1, "EQUIPO": "Pantalla  \\"", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00052", "CANT": 1, "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00053", "CANT": 1, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00054", "CANT": 1, "EQUIPO": "Base de Guitarra", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00057", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 4", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00058", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 2", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00059", "CANT": 1, "EQUIPO": "Pisa Cable (Yellow Jacket)", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00062", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00063", "CANT": 1, "EQUIPO": "Silla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00065", "CANT": 1, "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00066", "CANT": 1, "EQUIPO": "Tela para Pantalla", "OBSERVACIONES": ""}]
414	113	Tebacas	[{"ID": "Inv_alt_1130019", "EQUIPO": "Computadora", "OBSERVACIONES": "[CUST_EQ:Computadora]"}]
67	118	Semanera	[{"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 4, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 4, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 8, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}]
438	105	iees	[{"ID": "INV_VPRO_ALT_00045", "EQUIPO": "CAMARAS 320", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190081", "EQUIPO": "camara go pro", "OBSERVACIONES": ""}, {"ID": "VPNBPA003", "EQUIPO": "(1) Green screen chico", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050007", "EQUIPO": "Baterias Z", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00097", "EQUIPO": "baterias para camaras 320", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190071", "EQUIPO": "Cargador para baterias 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00001", "EQUIPO": "tripies", "OBSERVACIONES": "4 son para luces y go pro"}, {"ID": "INV_ALT_1190042", "EQUIPO": "monitores liliput", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00101", "EQUIPO": "dollys", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050008", "EQUIPO": "LUCES", "OBSERVACIONES": "solo es uno "}]
134	109	KIT CIRCUITO CERRADO SENCILLO	[{"ID": "VPRO_ALT_26284", "CANT": 1, "EQUIPO": "laptop Vmix g7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26361", "CANT": 1, "EQUIPO": "mac #3", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26418", "CANT": 1, "EQUIPO": "hub 1x7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26466", "CANT": 3, "EQUIPO": "cables XLR", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26558", "CANT": 2, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "peavey", "OBSERVACIONES": "Una prestada de Hector"}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26642", "CANT": 1, "EQUIPO": "modem Quantum", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": "None"}]
135	109	KIT SEMANERA	[{"ID": "VPRO_ALT_26256", "CANT": 1, "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26284", "CANT": 1, "EQUIPO": "laptop Vmix g7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26302", "CANT": 1, "EQUIPO": "Atem", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26326", "CANT": 1, "EQUIPO": "consola audio (mini vMix)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26361", "CANT": 1, "EQUIPO": "mac #3", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26418", "CANT": 1, "EQUIPO": "hub 1x7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26466", "CANT": 3, "EQUIPO": "cables XLR", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26558", "CANT": 2, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "peavey", "OBSERVACIONES": "Una prestada de Hector"}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26642", "CANT": 1, "EQUIPO": "modem Quantum", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11376", "CANT": 1, "EQUIPO": "cpu de escritorio Cod. Pdte", "OBSERVACIONES": "sufrio golpe"}, {"ID": "VPRO_ALT_11423", "CANT": 1, "EQUIPO": "Monitor gamer negro plano cod pdte", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11490", "CANT": 1, "EQUIPO": "Kit de teclado mouse y receptor inalambricon cod pte", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11525", "CANT": 1, "EQUIPO": "Panel de control TYST Video cod pte", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11545", "CANT": 2, "EQUIPO": "Adaptador Display port hdmi cod Pte ", "OBSERVACIONES": "Uno de ellos no sirve"}]
143	202	IEES en área de ventas de Vpro	[{"ID": "Inv_Vpro_alt_00157", "CANT": 1, "EQUIPO": "Laptop HP", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00158", "CANT": 4, "EQUIPO": "Cables ethernet cortos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00159", "CANT": 2, "EQUIPO": "Cables ethernet largos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00160", "CANT": 1, "EQUIPO": "No break (grande)", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00161", "CANT": 1, "EQUIPO": "Switch 8 puertos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00162", "CANT": 1, "EQUIPO": "Switch 5 puertos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00163", "CANT": 1, "EQUIPO": "Extensión eléctrica 6 metros", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00164", "CANT": 1, "EQUIPO": "Celular azul", "OBSERVACIONES": "None"}]
144	109	IEES	[{"ID": "VPRO_ALT_26256", "CANT": 1, "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26361", "CANT": 1, "EQUIPO": "mac #3", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26418", "CANT": 1, "EQUIPO": "hub 1x7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26466", "CANT": 3, "EQUIPO": "cables XLR", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26558", "CANT": 2, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "peavey", "OBSERVACIONES": "Una prestada de Hector"}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11376", "CANT": 1, "EQUIPO": "cpu de escritorio Cod. Pdte", "OBSERVACIONES": "sufrio golpe"}, {"ID": "VPRO_ALT_11423", "CANT": 1, "EQUIPO": "Monitor gamer negro plano cod pdte", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11490", "CANT": 1, "EQUIPO": "Kit de teclado mouse y receptor inalambricon cod pte", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11525", "CANT": 1, "EQUIPO": "Panel de control TYST Video cod pte", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11545", "CANT": 2, "EQUIPO": "Adaptador Display port hdmi cod Pte", "OBSERVACIONES": "Uno de ellos no sirve"}]
149	202	Mundial futbol	[{"ID": "Inv_Vpro_alt_00139", "CANT": 6, "EQUIPO": "Cables ethernet cortos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00140", "CANT": 2, "EQUIPO": "Cables ethernet largos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00141", "CANT": 2, "EQUIPO": "Cables HDMI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00142", "CANT": 1, "EQUIPO": "Laptop HP, con cargador", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00143", "CANT": 1, "EQUIPO": "Laptop ASUS, con cargador", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00144", "CANT": 2, "EQUIPO": "Adaptador ethernet usb", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00145", "CANT": 1, "EQUIPO": "Switch 5 puertos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00146", "CANT": 1, "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00147", "CANT": 1, "EQUIPO": "Desarmador de pala", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00148", "CANT": 1, "EQUIPO": "Pinza ponchadora", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00149", "CANT": 1, "EQUIPO": "Bolsa con cinchos", "OBSERVACIONES": "None"}]
150	104	Estrategia Nacional de Seguridad Villa Unión	[{"ID": "Inv_Vpro_alt_00150", "CANT": 2, "EQUIPO": "pantalla 55\\"", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00151", "CANT": 6, "EQUIPO": "Cables HDMI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00152", "CANT": 6, "EQUIPO": "Cables de Corriente", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00153", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00154", "CANT": 1, "EQUIPO": "Carpa", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00155", "CANT": 5, "EQUIPO": "Pisa Cables", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00156", "CANT": 2, "EQUIPO": "Base de Madera", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00157", "CANT": 2, "EQUIPO": "Base de Guitarra", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00158", "CANT": 2, "EQUIPO": "Sillas", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00159", "CANT": 1, "EQUIPO": "Carpa", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00160", "CANT": 2, "EQUIPO": "Tela para Pantallas", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00161", "CANT": 1, "EQUIPO": "Distribuidor 1 a 4", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00162", "CANT": 1, "EQUIPO": "Distribuidor 1 a 2", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00163", "CANT": 1, "EQUIPO": "Multicontacto", "OBSERVACIONES": "None"}]
455	104	IESS 12/nov/2026	[{"ID": "INV_VPRO_ALT_00053", "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "xxxx", "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "xxxxx", "EQUIPO": "Cables SDI", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00023", "EQUIPO": "pisacables", "OBSERVACIONES": ""}, {"ID": "xxxxxx", "EQUIPO": "Multicontactos", "OBSERVACIONES": ""}]
152	109	GENERAL	[{"ID": "VPRO_ALT_26284", "CANT": 1, "EQUIPO": "laptop Vmix g7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26326", "CANT": 1, "EQUIPO": "consola audio (mini vMix)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26361", "CANT": 1, "EQUIPO": "mac #3", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26418", "CANT": 1, "EQUIPO": "hub 1x7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26466", "CANT": 2, "EQUIPO": "cables XLR", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26558", "CANT": 2, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26591", "CANT": 1, "EQUIPO": "peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26642", "CANT": 1, "EQUIPO": "modem Quantum", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_26704", "CANT": 1, "EQUIPO": "Mac #4", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_26705", "CANT": 1, "EQUIPO": "UPS", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_26706", "CANT": 4, "EQUIPO": "Cables SDI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_26707", "CANT": 1, "EQUIPO": "Monitor Lilliput", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_26708", "CANT": 1, "EQUIPO": "Apuntador", "OBSERVACIONES": "None"}]
154	109	Oficina Osiel	[{"ID": "Inv_Vpro_alt_00162", "CANT": 1, "EQUIPO": "ontrol remoto de aire acondicionado mirage", "OBSERVACIONES": "Falta de pilas"}]
155	202	Salón Gobernadores	[{"ID": "Inv_Vpro_alt_00157", "CANT": 1, "EQUIPO": "Laptop HP", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00162", "CANT": 1, "EQUIPO": "Laptop ASUS", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00163", "CANT": 1, "EQUIPO": "Switch tplink 5 puertos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00164", "CANT": 6, "EQUIPO": "Cableado utp corto", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00165", "CANT": 3, "EQUIPO": "Cableado utp Largo", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00166", "CANT": 1, "EQUIPO": "UPS", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00167", "CANT": 2, "EQUIPO": "Adaptador ETH", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00168", "CANT": 1, "EQUIPO": "Pinza ponchadora", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00169", "CANT": 1, "EQUIPO": "Celular institucional", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00170", "CANT": 1, "EQUIPO": "Ipad", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00171", "CANT": 1, "EQUIPO": "Tablet android", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00172", "CANT": 1, "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00173", "CANT": 1, "EQUIPO": "Desarmador de pala", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00174", "CANT": 1, "EQUIPO": "Laptop HP", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00175", "CANT": 2, "EQUIPO": "Pisacables", "OBSERVACIONES": "None"}]
156	104	Reunión del Consejo Protección Civil	[{"ID": "Inv_Vpro_alt_00173", "CANT": 7, "EQUIPO": "Cable SDI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00174", "CANT": 5, "EQUIPO": "CableHDMI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00175", "CANT": 5, "EQUIPO": "Extensiones", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00176", "CANT": 1, "EQUIPO": "Distribuidor HDMI 1 a 4", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00177", "CANT": 2, "EQUIPO": "Distribuidor HDMI 1 a 2", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00178", "CANT": 1, "EQUIPO": "Bolsa de Arena", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00179", "CANT": 3, "EQUIPO": "Pisa Cable", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00180", "CANT": 2, "EQUIPO": "Multicontactos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00181", "CANT": 1, "EQUIPO": "Balanceador", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00182", "CANT": 2, "EQUIPO": "Dollys", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00183", "CANT": 1, "EQUIPO": "Diablito", "OBSERVACIONES": "None"}]
158	202	Enlace y viviendas bienestar	[{"ID": "Inv_Vpro_alt_00181", "CANT": 1, "EQUIPO": "Portátil HP", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00182", "CANT": 1, "EQUIPO": "Portátil ASUS", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00183", "CANT": 1, "EQUIPO": "Switch 5 puertos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00184", "CANT": 1, "EQUIPO": "Switch 8 puertos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00185", "CANT": 8, "EQUIPO": "Cableado UTP cortos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00186", "CANT": 4, "EQUIPO": "Cableado UTP largos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00187", "CANT": 1, "EQUIPO": "UPS (No-Break)", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00188", "CANT": 2, "EQUIPO": "Adaptador ETH", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00189", "CANT": 1, "EQUIPO": "Pinza ponchadora", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00190", "CANT": 1, "EQUIPO": "Modem Quantum", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00191", "CANT": 1, "EQUIPO": "Celular institucional", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00192", "CANT": 1, "EQUIPO": "Access point tp-link omada", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00193", "CANT": 1, "EQUIPO": "Ipad", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00194", "CANT": 1, "EQUIPO": "Tablet Android", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00195", "CANT": 2, "EQUIPO": "Tripie para bocina", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00196", "CANT": 1, "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00197", "CANT": 1, "EQUIPO": "Desarmador de pala", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00198", "CANT": 2, "EQUIPO": "Antena starlink", "OBSERVACIONES": "Antenas 01 y 02"}, {"ID": "Inv_Vpro_alt_00199", "CANT": 2, "EQUIPO": "Cable largo para starlink", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00200", "CANT": 1, "EQUIPO": "Kit de terminales para starlink", "OBSERVACIONES": "None"}]
162	125	kit invntario	[{"ID": "Inv_Vpro_alt_00207", "CANT": 1, "EQUIPO": "mouse blanco", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00208", "CANT": 1, "EQUIPO": "ordenador", "OBSERVACIONES": "None"}]
296	202	CESAVESIN en Mazatlán	[{"ID": "INV_ALT_2020009", "EQUIPO": "Caja grande c/tapa azul con cables ethernet cortos y largos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020010", "EQUIPO": "Kit convertidor de medios ethernet a fibra VPNRED112", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00189", "EQUIPO": "Pinza ponchadora passthrough", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020011", "EQUIPO": "Cable de fibra óptica 120 mts completo con terminales SC/APC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020012", "EQUIPO": "Adaptadores SC/PC a SC/PC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020013", "EQUIPO": "UPS/Nobreak HIKVISION VPNRED077", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020014", "EQUIPO": "Tableta Smasung Galaxy Tabl A9 (color grafito) con adaptador de energía, cable de corriente y protector. VPNRED071", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020015", "EQUIPO": "Frasco con terminales utp cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020016", "EQUIPO": "KIT (2) Adaptadores Starlink SPX a RJ45 para generación 2", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00026", "EQUIPO": "Cable especial ethernet para StarLink (50 mts)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020017", "EQUIPO": "Equipo Celular Samsung SM-A307G #6672173818 VPNRED 027", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00016", "EQUIPO": "Access Point TP-Link modelo  AX3600 VPNRED018", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020018", "EQUIPO": "Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED056", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020019", "EQUIPO": "Adaptadores eth a eth cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020021", "EQUIPO": "Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020022", "EQUIPO": "Starlink #2 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020023", "EQUIPO": "Laptop HP Elitebook 845 G7 Notebook PC, con cargador VPNCOM007", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020024", "EQUIPO": "Laptop Asus Vivobook 15\\" D1502IA-BQ179W Ryzen 5 8GB RAM 256GB SSD con cargador VPNRED033", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020025", "EQUIPO": "Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED057", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020026", "EQUIPO": "Switch tp-link 8 puertos VPNRED095", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020027", "EQUIPO": "Switch tp-link 8 puertos VPNRED096", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2020028", "EQUIPO": "Escalera pegable", "OBSERVACIONES": "[CUST_EQ:Escalera pegable]"}]
163	119	Kit evento especial enlace presidenta a 4 cámaras	[{"ID": "Inv_Vpro_alt_00045", "CANT": 4, "EQUIPO": "Cámaras", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00045", "CANT": 4, "EQUIPO": "Tripies", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00198", "CANT": 4, "EQUIPO": "monitores", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00199", "CANT": 6, "EQUIPO": "baterias para camara 320", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00200", "CANT": 4, "EQUIPO": "fuentes de póder", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00201", "CANT": 1, "EQUIPO": "balanceador", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00202", "CANT": 6, "EQUIPO": "radios", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00203", "CANT": 6, "EQUIPO": "baterias para monitor", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00204", "CANT": 1, "EQUIPO": "monitor de ingenieria", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00205", "CANT": 2, "EQUIPO": "escaladores decimator", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00206", "CANT": 2, "EQUIPO": "convertidores blackmagic", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00207", "CANT": 4, "EQUIPO": "Forros de cámara", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00208", "CANT": 1, "EQUIPO": "Banco", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00209", "CANT": 2, "EQUIPO": "Paraguas", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00210", "CANT": 1, "EQUIPO": "monitor ingenieria", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00211", "CANT": 8, "EQUIPO": "servos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00212", "CANT": 1, "EQUIPO": "dolly", "OBSERVACIONES": "None"}]
164	104	El Sauz	[{"ID": "Inv_Vpro_alt_00210", "CANT": 3, "EQUIPO": "Extenciones", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00211", "CANT": 3, "EQUIPO": "Hdmi", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00212", "CANT": 2, "EQUIPO": "Base de Pantallas Altas", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00213", "CANT": 1, "EQUIPO": "Distribuidor HDMI", "OBSERVACIONES": "None"}]
165	104	Viviendas bienestar	[{"ID": "Inv_Vpro_alt_00210", "CANT": 19, "EQUIPO": "Extenciones", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00211", "CANT": 32, "EQUIPO": "Hdmi", "OBSERVACIONES": "1 cable sin punta"}, {"ID": "Inv_Vpro_alt_00212", "CANT": 10, "EQUIPO": "Base de Pantallas Altas", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00213", "CANT": 3, "EQUIPO": "Distribuidor HDMI \\"2\\"", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00214", "CANT": 1, "EQUIPO": "Distribuidor HDMI \\"4\\"", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00215", "CANT": 2, "EQUIPO": "Distribuidor HDMI \\"8\\"", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00216", "CANT": 1, "EQUIPO": "Carpa", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00217", "CANT": 1, "EQUIPO": "Monitor de 55''", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00218", "CANT": 1, "EQUIPO": "Monitor de 60''", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00219", "CANT": 7, "EQUIPO": "Monitor de 65''", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00220", "CANT": 10, "EQUIPO": "Base metal para monitor", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00221", "CANT": 17, "EQUIPO": "Pisa Cables", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00222", "CANT": 1, "EQUIPO": "Equipo no registrado", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00223", "CANT": 2, "EQUIPO": "Mesas pegables", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00224", "CANT": 2, "EQUIPO": "Control remoto para monitor", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00225", "CANT": 4, "EQUIPO": "Sillas", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00226", "CANT": 1, "EQUIPO": "Grabadoras", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00227", "CANT": 10, "EQUIPO": "Multicontactos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00228", "CANT": 1, "EQUIPO": "Equipo no registrado", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00229", "CANT": 1, "EQUIPO": "Monitor de 40''", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00230", "CANT": 1, "EQUIPO": "Diablito", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00231", "CANT": 11, "EQUIPO": "Cables SDI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00232", "CANT": 2, "EQUIPO": "Abanicos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00233", "CANT": 1, "EQUIPO": "Lampara 2000", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00234", "CANT": 1, "EQUIPO": "Century", "OBSERVACIONES": "None"}]
168	107	dollys	[{"ID": "Inv_Vpro_alt_00232", "CANT": 1, "EQUIPO": "dolly in", "OBSERVACIONES": "dolly back"}]
169	109	KIT DE AUDIO PARA TESTIMONIAL	[{"ID": "Inv_Vpro_alt_00232", "CANT": 1, "EQUIPO": "Transmisor Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00233", "CANT": 1, "EQUIPO": "Receptor Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00234", "CANT": 1, "EQUIPO": "Micrófono Lavalier", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00235", "CANT": 1, "EQUIPO": "Audífonos de monitoreo Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00236", "CANT": 2, "EQUIPO": "Cables de Microfóneo", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00237", "CANT": 8, "EQUIPO": "Baterias \\"AA\\"", "OBSERVACIONES": "None"}]
171	109	Kit de audio testimonial	[{"ID": "Inv_Vpro_alt_00232", "CANT": 1, "EQUIPO": "Transmisor Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00233", "CANT": 1, "EQUIPO": "Receptor Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00234", "CANT": 1, "EQUIPO": "Micrófono Lavalier", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00235", "CANT": 1, "EQUIPO": "Audífonos de monitoreo Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00236", "CANT": 2, "EQUIPO": "Cables de Microfóneo", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00237", "CANT": 8, "EQUIPO": "Baterias \\"AA\\"", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00238", "CANT": 1, "EQUIPO": "Diadema de monitoreo", "OBSERVACIONES": "None"}]
172	109	KIT ENLACE PRESIDENTA	[{"ID": "VPRO_ALT_26256", "CANT": 1, "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26284", "CANT": 1, "EQUIPO": "laptop Vmix g7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26302", "CANT": 1, "EQUIPO": "Atem", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26326", "CANT": 1, "EQUIPO": "consola audio (mini vMix)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26361", "CANT": 1, "EQUIPO": "mac #3", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26418", "CANT": 2, "EQUIPO": "hub 1x7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26466", "CANT": 2, "EQUIPO": "cables XLR", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26558", "CANT": 1, "EQUIPO": "Decimator", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26642", "CANT": 1, "EQUIPO": "HDMI splitter (1x4)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11376", "CANT": 1, "EQUIPO": "Grabadora", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_26704", "CANT": 1, "EQUIPO": "Mac #4", "OBSERVACIONES": "None"}]
173	109	Kit reunion del consejo	[{"ID": "VPRO_ALT_26256", "CANT": 1, "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26284", "CANT": 1, "EQUIPO": "laptop Vmix g7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26302", "CANT": 1, "EQUIPO": "Atem", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26326", "CANT": 1, "EQUIPO": "consola audio (mini vMix)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26361", "CANT": 1, "EQUIPO": "mac #3", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26418", "CANT": 2, "EQUIPO": "hub 1x7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26466", "CANT": 2, "EQUIPO": "cables XLR", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26558", "CANT": 1, "EQUIPO": "Decimator", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26642", "CANT": 1, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11376", "CANT": 1, "EQUIPO": "Grabadora", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_26704", "CANT": 1, "EQUIPO": "Mac #4", "OBSERVACIONES": "None"}]
200	109	Kit Audio	[{"ID": "Inv_Vpro_alt_00253", "CANT": 2, "EQUIPO": "Receptor sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00254", "CANT": 2, "EQUIPO": "Transmisor sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00255", "CANT": 2, "EQUIPO": "microfono lavalier", "OBSERVACIONES": "1 con capuchon y 1 sin capuchon"}, {"ID": "Inv_Vpro_alt_00256", "CANT": 2, "EQUIPO": "Cable XLR (3.5)", "OBSERVACIONES": "None"}]
203	102	Kit Grabaciones	[{"ID": "Inv_Vpro_alt_00236", "CANT": 1, "EQUIPO": "Camara FS7", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00237", "CANT": 1, "EQUIPO": "Tripie", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00238", "CANT": 1, "EQUIPO": "Baterias  Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00254", "CANT": 1, "EQUIPO": "Rebotador", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00255", "CANT": 1, "EQUIPO": "Kit de lentes", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00256", "CANT": 1, "EQUIPO": "Lavalier", "OBSERVACIONES": "None"}]
209	109	KIT AUDIO BOOM Y LAVALIER	[{"ID": "None", "CANT": 1, "EQUIPO": "Transmisor SONY VPNAUD002", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Receptor SONY VPNAUD002", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 2, "EQUIPO": "Cableado de MIC VPNAUDOO1 Y VPNAUD002", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Microfono Lavalier VPNAUD001", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Tripié CENTURY", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 2, "EQUIPO": "Cables XLR", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Audífonos SONY VPNAUD019", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 4, "EQUIPO": "Baterias \\"AA\\"", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Microfono Ambiental SHURE VPNAUD026", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Grabadora TASCAM VPNAUD017", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Boom para Microfono", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Bolsa de Arena", "OBSERVACIONES": "None"}]
220	113	Grabacion LEY	[{"ID": "INV_VPRO_ALT_00256", "CANT": 2, "EQUIPO": "Baterias Sony Alpha", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130001", "CANT": 1, "EQUIPO": "Camara Alpha VIII", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130002", "CANT": 1, "EQUIPO": "Estabilizador", "OBSERVACIONES": ""}]
221	109	Kit LEY	[{"ID": "INV_VPRO_ALT_00253", "CANT": 1, "EQUIPO": "Receptor sony", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00254", "CANT": 1, "EQUIPO": "Transmisor sony", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00255", "CANT": 1, "EQUIPO": "microfono lavalier", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26466", "CANT": 2, "EQUIPO": "cables XLR", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090001", "CANT": 1, "EQUIPO": "Century", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090002", "CANT": 1, "EQUIPO": "Diadema Sony", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090003", "CANT": 1, "EQUIPO": "(4) Microfonos ambientales de camara", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090004", "CANT": 1, "EQUIPO": "Grabadora TASCAM", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090005", "CANT": 1, "EQUIPO": "Boom para microfono", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00178", "CANT": 1, "EQUIPO": "Bolsa de Arena", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090006", "CANT": 2, "EQUIPO": "cableado para microfono", "OBSERVACIONES": ""}]
223	105	cocacola cine	[{"ID": "Inv_Vpro_alt_00138", "CANT": 1, "EQUIPO": "telepronter", "OBSERVACIONES": "None"}, {"ID": "Inv_alt_1050002", "CANT": 1, "EQUIPO": "lap -top pronter", "OBSERVACIONES": "[CUST_EQ:lap -top pronter] None"}, {"ID": "VPRO_ALT_26448", "CANT": 1, "EQUIPO": "hdmi", "OBSERVACIONES": "None"}]
224	109	KIT DE ESTUDIO INALAMBRICO	[{"ID": "Inv_alt_1090007", "CANT": 1, "EQUIPO": "Transmisor SONY VPNAUD002", "OBSERVACIONES": "[CUST_EQ:Transmisor SONY VPNAUD002] None"}, {"ID": "Inv_alt_1090008", "CANT": 1, "EQUIPO": "Receptor SONY VPNAUD002", "OBSERVACIONES": "[CUST_EQ:Receptor SONY VPNAUD002]"}, {"ID": "Inv_alt_1090009", "CANT": 2, "EQUIPO": "Cableado de MIC VPNAUDOO1 Y VPNAUD002", "OBSERVACIONES": "[CUST_EQ:Cableado de MIC VPNAUDOO1 Y VPNAUD002]"}, {"ID": "Inv_alt_1090010", "CANT": 1, "EQUIPO": "Tripié CENTURY", "OBSERVACIONES": "[CUST_EQ:Tripié CENTURY]"}, {"ID": "VPRO_ALT_26466", "CANT": 1, "EQUIPO": "Cables XLR", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090011", "CANT": 1, "EQUIPO": "Audífonos SONY VPNAUD019", "OBSERVACIONES": "[CUST_EQ:Audífonos SONY VPNAUD019]"}, {"ID": "Inv_alt_1090012", "CANT": 1, "EQUIPO": "Grabadora TASCAM VPNAUD017", "OBSERVACIONES": "[CUST_EQ:Grabadora TASCAM VPNAUD017]"}, {"ID": "INV_ALT_1090005", "CANT": 1, "EQUIPO": "Boom para Microfono", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00178", "CANT": 1, "EQUIPO": "Bolsa de Arena", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090013", "CANT": 1, "EQUIPO": "Audifonos VPNAUD065", "OBSERVACIONES": "[CUST_EQ:Audifonos VPNAUD065] None"}]
226	102	KIT SONY FS7	[{"ID": "Inv_alt_1020001", "CANT": 1, "EQUIPO": "CAMARA SONY FS7", "OBSERVACIONES": "[CUST_EQ:CAMARA SONY FS7] None"}, {"ID": "Inv_alt_1020002", "CANT": 2, "EQUIPO": "BATERIAS SONY V MOUNT", "OBSERVACIONES": "[CUST_EQ:BATERIAS SONY V MOUNT] None"}, {"ID": "Inv_alt_1020003", "CANT": 1, "EQUIPO": "TRIPIE LIBEC", "OBSERVACIONES": "[CUST_EQ:TRIPIE LIBEC] None"}, {"ID": "Inv_alt_1020004", "CANT": 1, "EQUIPO": "KIT DE LENTES", "OBSERVACIONES": "[CUST_EQ:KIT DE LENTES] None"}]
236	104	Grabación al campo	[{"ID": "INV_VPRO_ALT_00236", "CANT": 3, "EQUIPO": "tripies", "OBSERVACIONES": "None"}, {"ID": "Inv_alt_1040001", "CANT": 1, "EQUIPO": "kit de luces", "OBSERVACIONES": "[CUST_EQ:kit de luces] None"}, {"ID": "INV_VPRO_ALT_00237", "CANT": 3, "EQUIPO": "baterias sony", "OBSERVACIONES": "None"}, {"ID": "Inv_alt_1040002", "CANT": 2, "EQUIPO": "baterias zgzine", "OBSERVACIONES": "[CUST_EQ:baterias zgzine] None"}, {"ID": "Inv_alt_1040003", "CANT": 1, "EQUIPO": "cargador de pila", "OBSERVACIONES": "[CUST_EQ:cargador de pila] None"}]
239	105	CASA LEY	[{"ID": "INV_VPRO_ALT_00235", "CANT": 1, "EQUIPO": "KIT LUCES", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00236", "CANT": 3, "EQUIPO": "TRIPIES", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00237", "CANT": 3, "EQUIPO": "BATERIAS SONY", "OBSERVACIONES": ""}]
243	104	Kit Semanera	[{"ID": "INV_VPRO_ALT_00042", "CANT": 2, "EQUIPO": "Pantalla  55\\"", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00052", "CANT": 10, "EQUIPO": "cable hdmi", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00053", "CANT": 10, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00057", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 4", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00058", "CANT": 2, "EQUIPO": "Distribuidor de HDMI de 2", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00065", "CANT": 2, "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00081", "CANT": 2, "EQUIPO": "Base de Madera Tv", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00082", "CANT": 1, "EQUIPO": "Dolly's", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00085", "CANT": 2, "EQUIPO": "tela de base", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00086", "CANT": 8, "EQUIPO": "Yellow Jake(pisacable)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16456", "CANT": 1, "EQUIPO": "mesa", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040001", "CANT": 2, "EQUIPO": "kit de luces", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16469", "CANT": 3, "EQUIPO": "sillas", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00173", "CANT": 8, "EQUIPO": "cable sdi", "OBSERVACIONES": "None"}]
256	105	Kit enlace Presidenta	[{"ID": "INV_ALT_1050006", "CANT": 1, "EQUIPO": "base de fierro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040001", "CANT": 1, "EQUIPO": "kit de luces", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050003", "CANT": 1, "EQUIPO": "Pantalla de 50\\"", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00052", "CANT": 1, "EQUIPO": "cable hdmi", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16418", "CANT": 4, "EQUIPO": "extensiones", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050004", "CANT": 1, "EQUIPO": "hdmi 100 mts", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050005", "CANT": 1, "EQUIPO": "dolly", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16456", "CANT": 1, "EQUIPO": "mesa", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00173", "CANT": 3, "EQUIPO": "cable sdi", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "CANT": 1, "EQUIPO": "tripie", "OBSERVACIONES": "None"}]
257	109	KIT ENLACE Y CIRCUITO CERRADO	[{"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26466", "CANT": 3, "EQUIPO": "cables XLR", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26558", "CANT": 2, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090024", "CANT": 12, "EQUIPO": "Baterias AA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090014", "CANT": 1, "EQUIPO": "Transmisor de audio SONY VPNAUD009", "OBSERVACIONES": "[CUST_EQ:Transmisor de audio SONY VPNAUD009] None"}, {"ID": "INV_ALT_1090015", "CANT": 4, "EQUIPO": "Receptor de audio SONY VPNAUD008", "OBSERVACIONES": "[CUST_EQ:Receptor de audio SONY VPNAUD008] None"}, {"ID": "INV_ALT_1090016", "CANT": 1, "EQUIPO": "Microfono de solapa SONY VPNAUD001", "OBSERVACIONES": "[CUST_EQ:Microfono de solapa SONY VPNAUD001] None"}, {"ID": "INV_ALT_1090017", "CANT": 4, "EQUIPO": "Diademas de comunicaciÃÂ³n BEHRINGER VPNAUD065", "OBSERVACIONES": "[CUST_EQ:Diademas de comunicaciÃÂÃÂ³n BEHRINGER VPNAUD065] None"}, {"ID": "INV_ALT_1090018", "CANT": 1, "EQUIPO": "Diadema de comunicaciÃÂ³n SONY VPNAUD019", "OBSERVACIONES": "[CUST_EQ:Diadema de comunicaciÃÂÃÂ³n SONY VPNAUD019] None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26418", "CANT": 2, "EQUIPO": "hub 1x7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090025", "CANT": 4, "EQUIPO": "bateria AA", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26256", "CANT": 1, "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26302", "CANT": 1, "EQUIPO": "Atem HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26326", "CANT": 1, "EQUIPO": "Consola audio (mini vMix)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26361", "CANT": 2, "EQUIPO": "mac #3 y #4", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00253", "CANT": 3, "EQUIPO": "receptor sony", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00255", "CANT": 3, "EQUIPO": "microfono lavalier", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090021", "CANT": 3, "EQUIPO": "cables XLR (3.5 Milimetros)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090022", "CANT": 4, "EQUIPO": "cables xlr (5mts)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090023", "CANT": 2, "EQUIPO": "bocina con cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090026", "CANT": 3, "EQUIPO": "transmisores sony", "OBSERVACIONES": ""}]
268	202	Jornadas de la paz 1	[{"ID": "INV_VPRO_ALT_00242", "CANT": 2, "EQUIPO": "Antena starlink 03, 02", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00243", "CANT": 1, "EQUIPO": "UPS (No break) Koblenz", "OBSERVACIONES": "VPNRED099"}, {"ID": "INV_VPRO_ALT_00244", "CANT": 1, "EQUIPO": "Mesa pequeÃÂÃÂÃÂÃÂ±a", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "CANT": 1, "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "CANT": 1, "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00248", "CANT": 1, "EQUIPO": "ExtensiÃÂÃÂÃÂÃÂ³n elÃÂÃÂÃÂÃÂ©ctrica corta", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00250", "CANT": 1, "EQUIPO": "TripiÃÂÃÂÃÂÃÂ© para bocina (sin tubo extensor)", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00252", "CANT": 2, "EQUIPO": "Adaptador ethernet usb", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00254", "CANT": 10, "EQUIPO": "Pisa cables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020001", "CANT": 1, "EQUIPO": "Cable largo para starlink", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020002", "CANT": 1, "EQUIPO": "Cable ethernet corto", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020003", "CANT": 6, "EQUIPO": "Cable ethernet largo", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00189", "CANT": 1, "EQUIPO": "Pinza ponchadora", "OBSERVACIONES": "None"}, {"ID": "INV_ALT_2020005", "CANT": 2, "EQUIPO": "Swich de 8 puerto", "OBSERVACIONES": "None"}]
377	201	Kit_grito	[{"ID": "INV_VPRO_ALT_00021", "EQUIPO": "Pinza para ponchar cables ethernet", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010004", "EQUIPO": "frasco con plugs cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020009", "EQUIPO": "Caja grande c/tapa azul con cables ethernet cortos y largos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010009", "EQUIPO": "INV_VPRO_ALT_00013 - Laptop Asus con adaptador de red y cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00017", "EQUIPO": "Switch de 5 puertos metalico cod VPNRED051", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010008", "EQUIPO": "Switch de 5 puertos de plastico negro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010010", "EQUIPO": "VPNPRO152 - Laptop Del #2 Inspiron G7 7700 Gaming 17.3\\" Intel Core i5 10300H Disco duro 512 GB SSD Ram 8GB Winsows 10 Home, Mause y cargador", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00013", "EQUIPO": "Laptop Asus con adaptador de red y cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020021", "EQUIPO": "Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": "Maleta dañada, ya se reportó./Via O Equio con daño"}]
447	104	Instalacion Rueda de Prensa Harfuch	[{"ID": "", "EQUIPO": "Pantalla de 65", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Base de Guitarra", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Base de madera", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Base alta", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Cable SD", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Distribuidor de HDMI de 8", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Distribuidor de HDMI de 2", "OBSERVACIONES": ""}]
265	202	Jornadas de la paz - Bueno	[{"ID": "INV_VPRO_ALT_00236", "CANT": 1, "EQUIPO": "TRIPIES", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00242", "CANT": 2, "EQUIPO": "Antena starlink 03, 02", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00243", "CANT": 1, "EQUIPO": "UPS (No break) Koblenz", "OBSERVACIONES": "VPNRED099"}, {"ID": "INV_VPRO_ALT_00244", "CANT": 1, "EQUIPO": "Mesa pequeÃÂÃÂ±a", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "CANT": 1, "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "CANT": 1, "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00248", "CANT": 1, "EQUIPO": "ExtensiÃÂÃÂ³n elÃÂÃÂ©ctrica corta", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00250", "CANT": 2, "EQUIPO": "TripiÃÂÃÂ© para bocina (sin tubo extensor)", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00252", "CANT": 2, "EQUIPO": "Adaptador ethernet usb", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00253", "CANT": 1, "EQUIPO": "receptor sony", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00254", "CANT": 10, "EQUIPO": "Pisa cables", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00255", "CANT": 2, "EQUIPO": "microfono lavalier", "OBSERVACIONES": "VPNRED095"}, {"ID": "INV_ALT_2020001", "CANT": 1, "EQUIPO": "Cable largo para starlink", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020002", "CANT": 1, "EQUIPO": "Cable ethernet corto", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020003", "CANT": 6, "EQUIPO": "Cable ethernet largo", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020004", "CANT": 1, "EQUIPO": "Caja con cables ethernet", "OBSERVACIONES": ""}]
267	202	Jornadas de la paz	[{"ID": "INV_VPRO_ALT_00242", "CANT": 2, "EQUIPO": "Antena starlink 03, 02", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00243", "CANT": 1, "EQUIPO": "UPS (No break) Koblenz", "OBSERVACIONES": "VPNRED099"}, {"ID": "INV_VPRO_ALT_00244", "CANT": 1, "EQUIPO": "Mesa pequeÃÂÃÂÃÂÃÂ±a", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "CANT": 1, "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "CANT": 1, "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00248", "CANT": 1, "EQUIPO": "ExtensiÃÂÃÂÃÂÃÂ³n elÃÂÃÂÃÂÃÂ©ctrica corta", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00250", "CANT": 1, "EQUIPO": "TripiÃÂÃÂÃÂÃÂ© para bocina (sin tubo extensor)", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00252", "CANT": 2, "EQUIPO": "Adaptador ethernet usb", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00254", "CANT": 10, "EQUIPO": "Pisa cables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020001", "CANT": 1, "EQUIPO": "Cable largo para starlink", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020002", "CANT": 1, "EQUIPO": "Cable ethernet corto", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020003", "CANT": 6, "EQUIPO": "Cable ethernet largo", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00189", "CANT": 1, "EQUIPO": "Pinza ponchadora", "OBSERVACIONES": "None"}, {"ID": "Inv_alt_2020005", "CANT": 2, "EQUIPO": "Swich de 8 puerto", "OBSERVACIONES": "[CUST_EQ:Swich de 8 puerto] None"}]
270	201	KIT_STD_EVENTOS_FUERA_DE_OFICINAS	[{"ID": "INV_VPRO_ALT_00013", "EQUIPO": "Laptop Asus con adaptador de red y cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00016", "EQUIPO": "Access Point TP-Link modelo  AX3600", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00017", "EQUIPO": "Switch de 5 puertos metalico", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00018", "EQUIPO": "Switch de 5 puertos de plastico negro", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00019", "EQUIPO": "Caja grande c/tapa azul con 50 cables cortos y largos", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00021", "EQUIPO": "Pinza para ponchar cables ethernet", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00022", "EQUIPO": "plugs para cables ethernet", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00023", "EQUIPO": "pisacables", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "EQUIPO": "Tripie", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00025", "EQUIPO": "UPS", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00092", "EQUIPO": "escalera plegable", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2010001", "EQUIPO": "Tablet samsung para monitoreo", "OBSERVACIONES": ""}]
286	104	Cesavesin Mazatlan Simposium	[{"ID": "INV_VPRO_ALT_00153", "EQUIPO": "Mesa", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00060", "EQUIPO": "Corral", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00061", "EQUIPO": "Tela Corral", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00174", "EQUIPO": "CableHDMI", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00210", "EQUIPO": "Extenciones", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00042", "EQUIPO": "Pantalla  55\\"", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00084", "EQUIPO": "Pantalla de 40\\"", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16514", "EQUIPO": "Pisa Cables Yellow Jacket", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00081", "EQUIPO": "Base de Madera Tv", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00055", "EQUIPO": "Base de Fierro Alta", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00085", "EQUIPO": "Tela de Base", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_17765", "EQUIPO": "base de guitarra", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00230", "EQUIPO": "Diablito", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00161", "EQUIPO": "Distribuidor 1 a 4", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00177", "EQUIPO": "Distribuidor HDMI 1 a 2", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190002", "EQUIPO": "distribuidores SDI", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00069", "EQUIPO": "Cable de Fibra Optica", "OBSERVACIONES": ""}]
374	109	Grito de la independencia	[{"ID": "VPRO_ALT_26418", "EQUIPO": "HUB 1x7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26433", "EQUIPO": "HUB 1X6", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26379", "EQUIPO": "HUB USB", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090034", "EQUIPO": "ADAPTADOR USBC-HDMI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090035", "EQUIPO": "SPLITTER 1X3 OREI", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_26708", "EQUIPO": "APUNTADOR", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090036", "EQUIPO": "MINI CONSOLA STEREN", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26591", "EQUIPO": "PEAVEY", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090037", "EQUIPO": "STREAM DEACK", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090038", "EQUIPO": "MAC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090039", "EQUIPO": "CAPTURADORAS USB", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090040", "EQUIPO": "CONVERTIDORES SDI-HDMI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090041", "EQUIPO": "CONVERTIDOR BIMODAL BLACKMAGIC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090042", "EQUIPO": "RECEPTORES SONY", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090026", "EQUIPO": "TRANSMISORES SONY", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090043", "EQUIPO": "CABLE SDI 7 MTS", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090044", "EQUIPO": "CABLE SDI CORTO", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00211", "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090045", "EQUIPO": "ATEM MINI PRO SDI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090028", "EQUIPO": "MONITOR STEREN", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090046", "EQUIPO": "DIADEMA DE COMUNICACION", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090047", "EQUIPO": "DIADEMA DE AUDIO", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090048", "EQUIPO": "DIADEMA DE OSIEL", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130013", "EQUIPO": "CABLE XLR", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090049", "EQUIPO": "MICROFONO SHURE CON PEDESTAL Y CABLE", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090031", "EQUIPO": "LAPTOP G7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26256", "EQUIPO": "CAJA vMix", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090027", "EQUIPO": "CONSOLA ZEDI 8", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090050", "EQUIPO": "BOCINA PREOSUND CON CABLES", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190052", "EQUIPO": "DIADEMAS", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090051", "EQUIPO": "EXTENSORES USB", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090052", "EQUIPO": "LAPTOP", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090053", "EQUIPO": "CABLES DE RED", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090054", "EQUIPO": "MONITOR HDMI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090055", "EQUIPO": "RAC CON SWITCHER", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090056", "EQUIPO": "PANEL DE 20 ENTRADAS", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090057", "EQUIPO": "THREEPLAY CON CONTROL, TECLADO Y MOUSE", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090058", "EQUIPO": "HC 200 AUDIFONOS", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090059", "EQUIPO": "MESAS", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00198", "EQUIPO": "MONITORES", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090060", "EQUIPO": "XLR LARGO", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090061", "EQUIPO": "SOPORTE PARA GUITARRA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090062", "EQUIPO": "ZEDI 10", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090063", "EQUIPO": "Rac con 2 grabadoras \\"IMPERDEC Y SD\\"", "OBSERVACIONES": "[CUST_EQ:Rac con 2 grabadoras \\"IMPERDEC Y SD\\"]"}, {"ID": "Inv_alt_1090064", "EQUIPO": "IMPERDEC", "OBSERVACIONES": "[CUST_EQ:IMPERDEC]"}]
376	104	Dia del grito	[{"ID": "INV_ALT_1040007", "EQUIPO": "Caja azul con SDI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040008", "EQUIPO": "Caja con Extensiones", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040009", "EQUIPO": "Caja de fibra", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190050", "EQUIPO": "SDI", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00071", "EQUIPO": "Fibra caja", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040010", "EQUIPO": "Multicontactos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040011", "EQUIPO": "Grabadora", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130011", "EQUIPO": "Sillas", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00216", "EQUIPO": "Carpa", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00023", "EQUIPO": "Pisacables", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00216", "EQUIPO": "Carpa", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040012", "EQUIPO": "Voltimetro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040013", "EQUIPO": "Mesita", "OBSERVACIONES": ""}]
308	113	Enlace Presidenta	[{"ID": "INV_ALT_1130004", "EQUIPO": "Pilas AA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130005", "EQUIPO": "Kit microfono Lavalier", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130006", "EQUIPO": "Camara x320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00237", "EQUIPO": "Baterias Sony", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130007", "EQUIPO": "Tripie con chancla", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130008", "EQUIPO": "Kit de iluminacion 2000", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090001", "EQUIPO": "Century", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050003", "EQUIPO": "Pantalla de 50\\"", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00175", "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130009", "EQUIPO": "HDMI 50 MTS", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130010", "EQUIPO": "SDI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130011", "EQUIPO": "Barra de contactos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "Cinta gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130012", "EQUIPO": "Microfono de mano", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130013", "EQUIPO": "Cable XLR", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130014", "EQUIPO": "Bocina de audio con cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130015", "EQUIPO": "Cable XLR largo", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050006", "EQUIPO": "Base de fierro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130016", "EQUIPO": "Distribuidores", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00201", "EQUIPO": "Balanceador", "OBSERVACIONES": ""}]
314	119	KIT BASICO 3 CAMARAS	[{"ID": "INV_VPRO_ALT_00045", "EQUIPO": "camaras 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00001", "EQUIPO": "tripies", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "EQUIPO": "baterias", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00099", "EQUIPO": "radios", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00101", "EQUIPO": "dollys", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00102", "EQUIPO": "monitor de ingeneria", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00103", "EQUIPO": "monitor lilliput", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00104", "EQUIPO": "bancos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190001", "EQUIPO": "escaladores", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190002", "EQUIPO": "distribuidores SDI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190005", "EQUIPO": "mochila negra", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "Cinta gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190007", "EQUIPO": "bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190008", "EQUIPO": "microconverter bidireccional", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190011", "EQUIPO": "microconverter SDI A HDMI con su A/C", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190012", "EQUIPO": "microconverter HDMI A SDI con su A/C", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190016", "EQUIPO": "cables SDI cortos (6 de 1 m, 2 de 1/2 m, 1 de 5 m, 1 de 11 m )", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190017", "EQUIPO": "cables HDMI cortos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190018", "EQUIPO": "cables de corriente negros cortos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190019", "EQUIPO": "barras de energia balnacas chicas", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190020", "EQUIPO": "cable negro USB-A a USB-B", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190021", "EQUIPO": "cables de HDMI a MINI HDMI (NEGRO Y ROJO)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190022", "EQUIPO": "cajita naranja con conectores y coples (HDMI 6, SDI 7, TE SDI 3)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190023", "EQUIPO": "baterias NP-F970 para monitor", "OBSERVACIONES": ""}]
315	202	IEES en estudio de Vpro	[{"ID": "INV_ALT_2020014", "EQUIPO": "Tableta Smasung Galaxy Tabl A9 (color grafito) con adaptador de energía, cable de corriente y protector. VPNRED071", "OBSERVACIONES": ""}]
316	109	KIT CESAVESIN	[{"ID": "VPRO_ALT_26448", "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26466", "EQUIPO": "Cables XLR", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26493", "EQUIPO": "Convertidor blackmagic bimodal", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26522", "EQUIPO": "Convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26558", "EQUIPO": "Convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": "Uno de los adaptadores no lleva AC"}, {"ID": "VPRO_ALT_26591", "EQUIPO": "Interfase Peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "EQUIPO": "Stream Deck El Gato", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26673", "EQUIPO": "Adaptador tipo C a HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26703", "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090014", "EQUIPO": "Transmisor de audio SONY VPNAUD009", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090015", "EQUIPO": "Receptor de audio SONY VPNAUD008", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090032", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090016", "EQUIPO": "Microfono de solapa SONY VPNAUD009", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090017", "EQUIPO": "Diademas de comunicación BEHRINGER VPNAUD065", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090018", "EQUIPO": "Diadema de comunicación SONY VPNAUD019", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26379", "EQUIPO": "hub USB", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26418", "EQUIPO": "hub 1x7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26433", "EQUIPO": "hub 1x6", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26256", "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26302", "EQUIPO": "Atem SDI PRO ISO", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26326", "EQUIPO": "Consola audio (mini vMix)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26346", "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26361", "EQUIPO": "mac #3 y #4", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00253", "EQUIPO": "Receptor SONY VPNAUD001", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00255", "EQUIPO": "Microfono Lavalier SONY VPNAUD001", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090021", "EQUIPO": "Transmisor SONY VPNAUD001", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090023", "EQUIPO": "Bocina con Cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090027", "EQUIPO": "Consola ZEDI 8", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00231", "EQUIPO": "Cables SDI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090028", "EQUIPO": "MONITOR STEREN", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090030", "EQUIPO": "Maleta de laptop", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090031", "EQUIPO": "Laptop g7", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_26708", "EQUIPO": "apuntador", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190010", "EQUIPO": "Memorias SD", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090032", "EQUIPO": "RAC de grabación", "OBSERVACIONES": "[CUST_EQ:RAC de grabación]"}]
317	105	KIT LEY GRABACION	[{"ID": "INV_VPRO_ALT_00166", "EQUIPO": "UPS", "OBSERVACIONES": ""}]
318	109	IEES VIRTUAL (Estudio VPro)	[{"ID": "VPRO_ALT_26361", "EQUIPO": "Mac #3 Mac #4", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26379", "EQUIPO": "Hub USB", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26418", "EQUIPO": "Hub 1x7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26433", "EQUIPO": "Hub 1x6", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26448", "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26466", "EQUIPO": "cables XLR", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26493", "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26522", "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26591", "EQUIPO": "peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "EQUIPO": "stream deck", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26673", "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_11376", "EQUIPO": "VMIX de Estudio, cpu de escritorio", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090033", "EQUIPO": "Convertidor C-HDMI", "OBSERVACIONES": "[CUST_EQ:Convertidor C-HDMI]"}]
459	105	iees 2	[{"ID": "INV_ALT_1190081", "EQUIPO": "camara go pro", "OBSERVACIONES": ""}, {"ID": "VPNBPA003", "EQUIPO": "(1) Green screen chico", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00001", "EQUIPO": "tripies", "OBSERVACIONES": "4 son para luces y go pro"}, {"ID": "INV_ALT_1190042", "EQUIPO": "monitores liliput", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050008", "EQUIPO": "LUCES", "OBSERVACIONES": "solo es uno"}]
378	202	Grito de independencia 2026	[{"ID": "INV_ALT_2020023", "EQUIPO": "Laptop HP Elitebook 845 G7 Notebook PC, con cargador VPNCOM007", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020018", "EQUIPO": "Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED056", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020025", "EQUIPO": "Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED057", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020017", "EQUIPO": "Equipo Celular Samsung SM-A307G #6672173818 VPNRED 027", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00189", "EQUIPO": "Pinza ponchadora passthrough", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020015", "EQUIPO": "Frasco con terminales utp cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020019", "EQUIPO": "Adaptadores eth a eth cat 6", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00149", "EQUIPO": "Bolsa con cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020012", "EQUIPO": "Adaptadores SC/PC a SC/PC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020031", "EQUIPO": "Extension de USB", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00016", "EQUIPO": "Access Point TP-Link modelo  AX3600 VPNRED018", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020011", "EQUIPO": "Cable de fibra óptica 120 mts completo con terminales SC/APC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020010", "EQUIPO": "Kit convertidor de medios ethernet a fibra VPNRED112", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020033", "EQUIPO": "Cutter trupper", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020034", "EQUIPO": "Tripié para bocina sin tubo extersor", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00026", "EQUIPO": "Cable especial ethernet para StarLink (50 mts)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020013", "EQUIPO": "UPS/Nobreak HIKVISION VPNRED077", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00092", "EQUIPO": "Escalera de tijera grande", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020037", "EQUIPO": "VPNRED-SWITCH10/100 - Switch ethernet tp-link 10/100 tl-sf1016D (VPNRED-SWITCH10/100)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020022", "EQUIPO": "Starlink #2 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2020039", "EQUIPO": "VPNRED060 - Modem de internet ZTE Megacable VPNRED060", "OBSERVACIONES": "[CUST_EQ:VPNRED060 - Modem de internet ZTE Megacable VPNRED060]"}]
380	119	DIA DEL GRITO	[{"ID": "INV_ALT_1190007", "EQUIPO": "Bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190068", "EQUIPO": "Rollo de alambre", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190069", "EQUIPO": "Micro convertidor", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190070", "EQUIPO": "Cargador Sony para baterías NP", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190071", "EQUIPO": "Cargador para baterias 320", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190055", "EQUIPO": "Baterías ZGCINE", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190056", "EQUIPO": "Baterías GL95", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190057", "EQUIPO": "Baterías L90", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190058", "EQUIPO": "Baterías NP", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00102", "EQUIPO": "Monitor de ingeneria", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190059", "EQUIPO": "Forros para cámaras", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00099", "EQUIPO": "Radios", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190053", "EQUIPO": "Cámara 320", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190054", "EQUIPO": "Sombrilla", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "EQUIPO": "Tripie", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190060", "EQUIPO": "MiniBlackMagic", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190042", "EQUIPO": "Monitores liliput", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00205", "EQUIPO": "Escaladores decimator", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00201", "EQUIPO": "Balanceador", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00227", "EQUIPO": "Multicontactos", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00104", "EQUIPO": "Bancos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190061", "EQUIPO": "Cables SDI NEGROS 1 METRO", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190005", "EQUIPO": "mochila negra", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190062", "EQUIPO": "SDI varios tamaños", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190063", "EQUIPO": "Corriente", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190064", "EQUIPO": "HDMI cortos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190065", "EQUIPO": "USB-USB C", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190066", "EQUIPO": "USB cables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190067", "EQUIPO": "USB tipo b", "OBSERVACIONES": ""}]
381	104	Evento presidenta	[{"ID": "INV_VPRO_ALT_00151", "EQUIPO": "Cables HDMI", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00175", "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00231", "EQUIPO": "Cables SDI", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1040014", "EQUIPO": "Distribuidor de 4\\"", "OBSERVACIONES": "[CUST_EQ:Distribuidor de 4\\"]"}, {"ID": "Inv_alt_1040015", "EQUIPO": "Distribuidor de 2\\"", "OBSERVACIONES": "[CUST_EQ:Distribuidor de 2\\"]"}, {"ID": "VPRO_ALT_17836", "EQUIPO": "Monitor de 65\\"", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00220", "EQUIPO": "Base metal para monitor", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_17765", "EQUIPO": "Base de guitarra", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00023", "EQUIPO": "Pisacables", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1040016", "EQUIPO": "Mesa pegable", "OBSERVACIONES": "[CUST_EQ:Mesa pegable]"}, {"ID": "VPRO_ALT_74716", "EQUIPO": "Abanico", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1040017", "EQUIPO": "Multicontaco", "OBSERVACIONES": "[CUST_EQ:Multicontaco]"}, {"ID": "Inv_alt_1040018", "EQUIPO": "Cable de red", "OBSERVACIONES": "[CUST_EQ:Cable de red]"}]
382	109	Evento Presidenta	[{"ID": "INV_ALT_1090031", "EQUIPO": "Laptop G7", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090065", "EQUIPO": "HDMI SPLITTER 1X2 OREI", "OBSERVACIONES": "[CUST_EQ:HDMI SPLITTER 1X2 OREI]"}, {"ID": "Inv_alt_1090066", "EQUIPO": "Consola audio mini vMix", "OBSERVACIONES": "[CUST_EQ:Consola audio mini vMix]"}, {"ID": "VPRO_ALT_26346", "EQUIPO": "Capturadoras HDMI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090038", "EQUIPO": "Mac", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00151", "EQUIPO": "Cables HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26418", "EQUIPO": "Hub 1X7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26433", "EQUIPO": "Hub 1X6", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26379", "EQUIPO": "Hub USB", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26591", "EQUIPO": "Peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "EQUIPO": "Stream Deck", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090067", "EQUIPO": "Decimator", "OBSERVACIONES": "[CUST_EQ:Decimator]"}, {"ID": "INV_VPRO_ALT_00231", "EQUIPO": "Cables SDI", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090068", "EQUIPO": "Convertidores", "OBSERVACIONES": "[CUST_EQ:Convertidores]"}, {"ID": "Inv_alt_1090069", "EQUIPO": "Bidireccional", "OBSERVACIONES": "[CUST_EQ:Bidireccional]"}]
417	113	Imagen y toma de aspectos	[{"ID": "Inv_alt_1130020", "EQUIPO": "Estabilizador de celular", "OBSERVACIONES": "[CUST_EQ:Estabilizador de celular]"}, {"ID": "Inv_alt_1130021", "EQUIPO": "Microfonos hollyland", "OBSERVACIONES": "[CUST_EQ:Microfonos hollyland]"}, {"ID": "Inv_alt_1130022", "EQUIPO": "Cámara alpha", "OBSERVACIONES": "[CUST_EQ:Cámara alpha]"}, {"ID": "Inv_alt_1130023", "EQUIPO": "Estabilizador alpha", "OBSERVACIONES": "[CUST_EQ:Estabilizador alpha]"}, {"ID": "INV_VPRO_ALT_00024", "EQUIPO": "Tripie", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1130024", "EQUIPO": "Lampara", "OBSERVACIONES": "[CUST_EQ:Lampara]"}, {"ID": "Inv_alt_1130025", "EQUIPO": "Bateria Sony", "OBSERVACIONES": "[CUST_EQ:Bateria Sony]"}]
343	104	Reunion de gabinete	[{"ID": "Inv_alt_1040004", "EQUIPO": "Pantalla de 65\\"", "OBSERVACIONES": "[CUST_EQ:Pantalla de 65\\"]"}, {"ID": "INV_VPRO_ALT_00055", "EQUIPO": "Base de fierro Alta", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00052", "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1040005", "EQUIPO": "Distribuidores 1x4", "OBSERVACIONES": "[CUST_EQ:Distribuidores 1x4]"}, {"ID": "Inv_alt_1040006", "EQUIPO": "Distribuidores 1x2", "OBSERVACIONES": "[CUST_EQ:Distribuidores 1x2]"}, {"ID": "INV_VPRO_ALT_00175", "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00065", "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00023", "EQUIPO": "Pisacables", "OBSERVACIONES": ""}]
346	105	JAPAC	[{"ID": "INV_VPRO_ALT_00237", "EQUIPO": "Baterias Sony", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050007", "EQUIPO": "Baterias Z", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040001", "EQUIPO": "Kit de luces", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00001", "EQUIPO": "TRIPIES", "OBSERVACIONES": ""}]
350	119	KIT TEBACAS	[{"ID": "INV_VPRO_ALT_00045", "EQUIPO": "camaras 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "EQUIPO": "baterias", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00099", "EQUIPO": "radios", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190037", "EQUIPO": "lampara portatil con una bateria", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190038", "EQUIPO": "micrófono de maraca", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190039", "EQUIPO": "atem sdi", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190034", "EQUIPO": "BARRA D EENERGIA", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00151", "EQUIPO": "cables hdmi", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190024", "EQUIPO": "escalador", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190040", "EQUIPO": "baterías para monitor", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190041", "EQUIPO": "monitor de ing.", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190042", "EQUIPO": "monitores liliput", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190043", "EQUIPO": "distribuidor sdi", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190044", "EQUIPO": "monitor 21.5 pulgadas", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00202", "EQUIPO": "Sistema de comunicacion", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190045", "EQUIPO": "memorias sxs", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190046", "EQUIPO": "cámaras miniblack", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190047", "EQUIPO": "cables sdi largos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190048", "EQUIPO": "lineas de audio largas", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190049", "EQUIPO": "microfonos para ambiente", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190029", "EQUIPO": "lineas de energia", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "cinta gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190007", "EQUIPO": "bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190050", "EQUIPO": "pizacables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190051", "EQUIPO": "Trpies", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190052", "EQUIPO": "Diademas", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020036", "EQUIPO": "Audifonos behringer HC200", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00153", "EQUIPO": "Mesa", "OBSERVACIONES": ""}]
473	105	kit del dany	[{"ID": "INV_ALT_1190050", "EQUIPO": "Pizacables", "OBSERVACIONES": ""}]
351	201	Jornadas de paz	[{"ID": "INV_VPRO_ALT_00181", "EQUIPO": "Extension electrica", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020021", "EQUIPO": "Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010006", "EQUIPO": "UPS (No break) Koblenz CODIGO VPNRED097", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00093", "EQUIPO": "cable especial de 50 mts de starlink", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020003", "EQUIPO": "Cable ethernet largo", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00139", "EQUIPO": "Cables ethernet cortos", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00021", "EQUIPO": "Pinza para ponchar cables ethernet", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010004", "EQUIPO": "frasco con plugs cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010007", "EQUIPO": "Switch de 5 puertos metalico", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010008", "EQUIPO": "Switch de 5 puertos de plastico negro", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "EQUIPO": "Tripie", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00254", "EQUIPO": "Pisa cables", "OBSERVACIONES": ""}]
383	202	TEBACAS	[{"ID": "INV_ALT_2020009", "EQUIPO": "Caja grande c/tapa azul con cables ethernet cortos y largos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020026", "EQUIPO": "Switch tp-link 8 puertos VPNRED095", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020027", "EQUIPO": "Switch tp-link 8 puertos VPNRED096", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020029", "EQUIPO": "Encoder kiloview E3", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020030", "EQUIPO": "Cables SDI 1mt", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020024", "EQUIPO": "Laptop Asus Vivobook 15\\" D1502IA-BQ179W Ryzen 5 8GB RAM 256GB SSD con cargador VPNRED033", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020023", "EQUIPO": "Laptop HP Elitebook 845 G7 Notebook PC, con cargador VPNCOM007", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020018", "EQUIPO": "Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED056", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020025", "EQUIPO": "Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED057", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020017", "EQUIPO": "Equipo Celular Samsung SM-A307G #6672173818 VPNRED 027", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00189", "EQUIPO": "Pinza ponchadora passthrough", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020015", "EQUIPO": "Frasco con terminales utp cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020019", "EQUIPO": "Adaptadores eth a eth cat 6", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00149", "EQUIPO": "Bolsa con cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020012", "EQUIPO": "Adaptadores SC/PC a SC/PC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020031", "EQUIPO": "Extension de USB", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00016", "EQUIPO": "Access Point TP-Link modelo  AX3600 VPNRED018", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020011", "EQUIPO": "Cable de fibra óptica 120 mts completo con terminales SC/APC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020010", "EQUIPO": "Kit convertidor de medios ethernet a fibra VPNRED112", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020032", "EQUIPO": "Teradek BOND PRO con estuche VPNRED012", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020033", "EQUIPO": "Cutter trupper", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020034", "EQUIPO": "Tripié para bocina sin tubo extersor", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00026", "EQUIPO": "Cable especial ethernet para StarLink (50 mts)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020035", "EQUIPO": "UPS (No-Break) Koblenz CODIGO VPNRED100", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020013", "EQUIPO": "UPS/Nobreak HIKVISION VPNRED076", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020021", "EQUIPO": "Starlink #2 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020022", "EQUIPO": "Starlink #3 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00092", "EQUIPO": "Escalera Plegable", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2020040", "EQUIPO": "HC200 - Audifonos behringer HC200", "OBSERVACIONES": "[CUST_EQ:HC200 - Audifonos behringer HC200]"}]
396	201	kit_en_ofna	[{"ID": "INV_VPRO_ALT_00023", "EQUIPO": "Pisacables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020003", "EQUIPO": "Cable ethernet largo", "OBSERVACIONES": ""}]
428	113	Grabación	[{"ID": "INV_VPRO_ALT_00236", "EQUIPO": "Camara Alpha", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00254", "EQUIPO": "Estabilizador DJI", "OBSERVACIONES": ""}]
403	104	Escuinapa	[{"ID": "Inv_Vpro_alt_00210", "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00211", "EQUIPO": "Hdmi", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00212", "EQUIPO": "tabletas de corriente", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00213", "EQUIPO": "Distribuidor HDMI 1x2", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1040023", "EQUIPO": "Distribuidor HDMI 1x4", "OBSERVACIONES": "[CUST_EQ:Distribuidor HDMI 1x4]"}, {"ID": "Inv_alt_1040024", "EQUIPO": "Distribuidor HDMI 1x8", "OBSERVACIONES": "[CUST_EQ:Distribuidor HDMI 1x8]"}, {"ID": "Inv_alt_1040025", "EQUIPO": "tela negra", "OBSERVACIONES": "[CUST_EQ:tela negra]"}, {"ID": "Inv_alt_1040026", "EQUIPO": "sillas negras", "OBSERVACIONES": "[CUST_EQ:sillas negras]"}, {"ID": "Inv_alt_1040027", "EQUIPO": "mesa mediana", "OBSERVACIONES": "[CUST_EQ:mesa mediana]"}, {"ID": "INV_ALT_1190050", "EQUIPO": "pizacables", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1040028", "EQUIPO": "monitores de 65", "OBSERVACIONES": "[CUST_EQ:monitores de 65]"}, {"ID": "VPRO_ALT_17765", "EQUIPO": "base de guitarra", "OBSERVACIONES": ""}]
435	119	KIT TEBACAS SEMIFINALES	[{"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190029", "EQUIPO": "lineas de energia", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "cinta gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190007", "EQUIPO": "bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190050", "EQUIPO": "pizacables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190051", "EQUIPO": "Trpies", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190052", "EQUIPO": "Diademas camarografos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020036", "EQUIPO": "Audifonos behringer HC200 (GERARDO)", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00153", "EQUIPO": "Mesa grande", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190072", "EQUIPO": "Mesa chica", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190073", "EQUIPO": "Mochila azul", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090044", "EQUIPO": "cable SDI corto", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190074", "EQUIPO": "cable SDI mediano", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190075", "EQUIPO": "mini contactos de energía blancos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190076", "EQUIPO": "mini converter blackmagig", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190077", "EQUIPO": "escalador decimator", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190079", "EQUIPO": "abanicos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190037", "EQUIPO": "lampara portatil", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190082", "EQUIPO": "pedestales para lampara y gopro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190038", "EQUIPO": "micrófono de maraca", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190039", "EQUIPO": "atem sdi", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190034", "EQUIPO": "BARRA DE ENERGIA", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00151", "EQUIPO": "cables hdmi gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190040", "EQUIPO": "baterías para monitor", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190042", "EQUIPO": "monitores liliput", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190044", "EQUIPO": "monitor 21.5 pulgadas", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00202", "EQUIPO": "2 Sistema de comunicación (6 bodis)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190045", "EQUIPO": "memorias sxs", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190046", "EQUIPO": "cámaras miniblack", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190047", "EQUIPO": "cable SDI largos ( 3 LARGOS NEGROS Y 2 LILAS)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190048", "EQUIPO": "lineas de audio largas", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190081", "EQUIPO": "camara go pro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190080", "EQUIPO": "Hielera", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190049", "EQUIPO": "microfonos para ambiente", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00045", "EQUIPO": "CAMARAS 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "EQUIPO": "baterías para cámara 320", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190083", "EQUIPO": "memoria SD", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1190084", "EQUIPO": "Rack con vectorscopio", "OBSERVACIONES": "[CUST_EQ:Rack con vectorscopio]"}]
440	201	Kit para IEES Presencial.	[{"ID": "INV_VPRO_ALT_00018", "EQUIPO": "Switch de 5 puertos de plastico negro NCA TP-LINK", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00017", "EQUIPO": "Switch de 5 puertos metalico cod VPNRED051", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010002", "EQUIPO": "cables largos azules cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010003", "EQUIPO": "cables cortos ethernet cat 6", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00168", "EQUIPO": "pinza ponchadora", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010004", "EQUIPO": "frasco con plugs cat 6", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00013", "EQUIPO": "Laptop Asus con adaptador de red y cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00243", "EQUIPO": "UPS (No break) Koblenz CODIGO VPNRED099", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2010001", "EQUIPO": "Tablet samsung para monitoreo", "OBSERVACIONES": ""}]
448	104	Evento Rueda De Prensa Lic. Harfuch	[{"ID": "", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}]
405	119	KIT TEBACAS 2026	[{"ID": "INV_ALT_1190049", "EQUIPO": "microfonos para ambiente", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00045", "EQUIPO": "camaras 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "EQUIPO": "baterias", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00099", "EQUIPO": "radios", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190029", "EQUIPO": "lineas de energia", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "cinta gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190007", "EQUIPO": "bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190050", "EQUIPO": "pizacables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190051", "EQUIPO": "Trpies", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190052", "EQUIPO": "Diademas camarografos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020036", "EQUIPO": "Audifonos behringer HC200 (GERARDO)", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00153", "EQUIPO": "Mesa grande", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190072", "EQUIPO": "Mesa chica", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190073", "EQUIPO": "Mochila azul", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090044", "EQUIPO": "cable SDI corto", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190074", "EQUIPO": "cable SDI mediano", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190075", "EQUIPO": "mini contactos de energía blancos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190076", "EQUIPO": "mini converter blackmagig", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190077", "EQUIPO": "escalador decimator", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190078", "EQUIPO": "convertidores de energia 400 w y 500 w", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190079", "EQUIPO": "abanicos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190037", "EQUIPO": "lampara portatil con una bateria", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190038", "EQUIPO": "micrófono de maraca", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190039", "EQUIPO": "atem sdi", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190034", "EQUIPO": "BARRA D EENERGIA", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00151", "EQUIPO": "cables hdmi", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190040", "EQUIPO": "baterías para monitor", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190041", "EQUIPO": "monitor de ing.", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190042", "EQUIPO": "monitores liliput", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190044", "EQUIPO": "monitor 21.5 pulgadas", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00202", "EQUIPO": "2 Sistema de comunicación (6 bodis)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190045", "EQUIPO": "memorias sxs", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190046", "EQUIPO": "cámaras miniblack", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190047", "EQUIPO": "cable SDI largo", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190048", "EQUIPO": "lineas de audio largas", "OBSERVACIONES": ""}]
410	109	CREE	[{"ID": "INV_ALT_1090031", "EQUIPO": "Laptop G7", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090065", "EQUIPO": "HDMI Splitter 1x2 OREI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090039", "EQUIPO": "Capturadoras USB", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090038", "EQUIPO": "MAC", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00211", "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26379", "EQUIPO": "HUB USB", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26418", "EQUIPO": "HUB 1X7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26673", "EQUIPO": "Adaptador tipo C a HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "EQUIPO": "Stream deck", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090070", "EQUIPO": "Cable XLR 50 metros", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00190", "EQUIPO": "Modem Quantum", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090067", "EQUIPO": "Decimator", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130012", "EQUIPO": "Microfono de mano", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090071", "EQUIPO": "Consola de audio", "OBSERVACIONES": ""}]
412	201	Kit_p_enlace_webex	[{"ID": "INV_VPRO_ALT_00018", "EQUIPO": "Switch de 5 puertos de plastico negro NCA TP-LINK", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00017", "EQUIPO": "Switch de 5 puertos metalico cod VPNRED051", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010002", "EQUIPO": "cables largos azules cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010003", "EQUIPO": "cables cortos ethernet cat 6", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00168", "EQUIPO": "pinza ponchadora", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010004", "EQUIPO": "frasco con plugs cat 6", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00013", "EQUIPO": "Laptop Asus con adaptador de red y cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00243", "EQUIPO": "UPS (No break) Koblenz CODIGO VPNRED099", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020028", "EQUIPO": "Escalera pegable", "OBSERVACIONES": ""}]
411	105	ENLACE PRESIDENTA	[{"ID": "INV_VPRO_ALT_00045", "EQUIPO": "CAMARAS 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00001", "EQUIPO": "TRIPIES", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050008", "EQUIPO": "LUCES", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1050009", "EQUIPO": "TRIPIES DE LUCES", "OBSERVACIONES": "[CUST_EQ:TRIPIES DE LUCES]"}, {"ID": "INV_VPRO_ALT_00237", "EQUIPO": "BATERIAS SONY", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1050010", "EQUIPO": "FUENTE DE PODER", "OBSERVACIONES": "[CUST_EQ:FUENTE DE PODER]"}]
424	201	Jornadas de paz basico	[{"ID": "INV_VPRO_ALT_00023", "EQUIPO": "pisacables", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "EQUIPO": "tripie", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020021", "EQUIPO": "Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010006", "EQUIPO": "UPS (No break) Koblenz CODIGO VPNRED097", "OBSERVACIONES": ""}]
431	119	JUEGO TEBACAS 16 DE OCTUBRE DE 2026	[{"ID": "INV_ALT_1190081", "EQUIPO": "camara go pro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190080", "EQUIPO": "Hielera", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190049", "EQUIPO": "microfonos para ambiente", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00045", "EQUIPO": "CAMARAS 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "EQUIPO": "baterías para cámara 320", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190083", "EQUIPO": "memoria SD", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190084", "EQUIPO": "Rack con vectorscopio", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190029", "EQUIPO": "lineas de energia", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "cinta gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190007", "EQUIPO": "bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190050", "EQUIPO": "pizacables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190051", "EQUIPO": "Trpies", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190052", "EQUIPO": "Diademas camarografos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020036", "EQUIPO": "Audifonos behringer HC200 (GERARDO)", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00153", "EQUIPO": "Mesa grande", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190072", "EQUIPO": "Mesa chica", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190073", "EQUIPO": "Mochila azul", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090044", "EQUIPO": "cable SDI corto", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190074", "EQUIPO": "cable SDI mediano", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190075", "EQUIPO": "mini contactos de energía blancos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190076", "EQUIPO": "mini converter blackmagig", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190077", "EQUIPO": "escalador decimator", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190079", "EQUIPO": "abanicos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190037", "EQUIPO": "lampara portatil", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190082", "EQUIPO": "pedestales para lampara y gopro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190038", "EQUIPO": "micrófono de maraca", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190039", "EQUIPO": "atem sdi", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190034", "EQUIPO": "BARRA DE ENERGIA", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00151", "EQUIPO": "cables hdmi gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190040", "EQUIPO": "baterías para monitor", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190042", "EQUIPO": "monitores liliput", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190044", "EQUIPO": "monitor 21.5 pulgadas", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00202", "EQUIPO": "2 Sistema de comunicación (6 bodis)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190045", "EQUIPO": "memorias sxs", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190046", "EQUIPO": "cámaras miniblack", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190047", "EQUIPO": "cable SDI largos ( 3 LARGOS NEGROS Y 2 LILAS)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190048", "EQUIPO": "lineas de audio largas", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190085", "EQUIPO": "cable  HDMI de 50 metros", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1190086", "EQUIPO": "micrófono de mano USB", "OBSERVACIONES": "[CUST_EQ:micrófono de mano USB]"}]
432	113	Grabación	[{"ID": "INV_VPRO_ALT_00236", "EQUIPO": "Camara Alpha Viii", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130026", "EQUIPO": "Micrófonos hollyland", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130027", "EQUIPO": "Monitor para cámara", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130028", "EQUIPO": "Jaula para cámara", "OBSERVACIONES": ""}]
433	201	Kit_en_Ofna_Estudio	[{"ID": "INV_VPRO_ALT_00012", "EQUIPO": "Computadora de escritorio con dos monitores", "OBSERVACIONES": ""}]
413	119	KIT TEBACAS OK OCTUBRE 2026	[{"ID": "INV_ALT_1190038", "EQUIPO": "micrófono de maraca", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190039", "EQUIPO": "atem sdi", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190034", "EQUIPO": "BARRA D EENERGIA", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00151", "EQUIPO": "cables hdmi gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190040", "EQUIPO": "baterías para monitor", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190042", "EQUIPO": "monitores liliput", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190044", "EQUIPO": "monitor 21.5 pulgadas", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00202", "EQUIPO": "2 Sistema de comunicación (6 bodis)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190045", "EQUIPO": "memorias sxs", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190046", "EQUIPO": "cámaras miniblack", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190047", "EQUIPO": "cable SDI largos ( 3 LARGOS NEGROS Y 2 LILAS)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190048", "EQUIPO": "lineas de audio largas", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190081", "EQUIPO": "camara go pro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190080", "EQUIPO": "hielera", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090024", "EQUIPO": "Baterias AA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190049", "EQUIPO": "microfonos para ambiente", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00045", "EQUIPO": "CAMARAS 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "EQUIPO": "baterías para cámara 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190029", "EQUIPO": "lineas de energia", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "cinta gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190007", "EQUIPO": "bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190050", "EQUIPO": "pizacables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190051", "EQUIPO": "Trpies", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190052", "EQUIPO": "Diademas camarografos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020036", "EQUIPO": "Audifonos behringer HC200 (GERARDO)", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00153", "EQUIPO": "Mesa grande", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190072", "EQUIPO": "Mesa chica", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190073", "EQUIPO": "Mochila azul", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090044", "EQUIPO": "cable SDI corto", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190074", "EQUIPO": "cable SDI mediano", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190075", "EQUIPO": "mini contactos de energía blancos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190076", "EQUIPO": "mini converter blackmagig", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190077", "EQUIPO": "escalador decimator", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190078", "EQUIPO": "convertidores de energía   500 w", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190079", "EQUIPO": "abanicos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190037", "EQUIPO": "lampara portatil con una bateria", "OBSERVACIONES": ""}]
436	109	TEBACAS ESTUDIO	[{"ID": "VPRO_ALT_26379", "EQUIPO": "Hub USB", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26466", "EQUIPO": "cables XLR", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26522", "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26591", "EQUIPO": "peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "EQUIPO": "stream deck", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_11376", "EQUIPO": "VMIX de Estudio, cpu de escritorio", "OBSERVACIONES": ""}]
441	109	IEES VIRTUAL (STUDIO) NEW	[{"ID": "VPRO_ALT_26448", "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26466", "EQUIPO": "cables XLR", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_11376", "EQUIPO": "VMIX de Estudio, cpu de escritorio", "OBSERVACIONES": ""}, {"ID": "VPNPRO381", "EQUIPO": "USB-C Doking Station CON (1) cable USB-C (1) cable con cabeza de doble salida USB-C", "OBSERVACIONES": ""}, {"ID": "VPNAUD057", "EQUIPO": "(2) Interfaz de audio", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090011", "EQUIPO": "Audífonos SONY VPNAUD019", "OBSERVACIONES": ""}, {"ID": "VPNPRO428", "EQUIPO": "Centro de carga USB 3.0 de 7 puertos", "OBSERVACIONES": ""}, {"ID": "VPNPRO358", "EQUIPO": "Streaming Deck", "OBSERVACIONES": ""}, {"ID": "VPNPRO142", "EQUIPO": "Blackmagic Micro Convertidor SDI a HDMI", "OBSERVACIONES": ""}, {"ID": "VPNPRO261", "EQUIPO": "Blackmagic Design SDI a HDMI Micro Converter, con Fuente de alimentación", "OBSERVACIONES": ""}, {"ID": "VPNPRO401", "EQUIPO": "Panel Switcher #1, panel de conmutador, grabación de video HDMI HD 4K Virtual Studio Grabación Switcher, para producción de transmisión en vivo. (1) Cable de poder de 1.5 M", "OBSERVACIONES": ""}, {"ID": "VPNPRO339", "EQUIPO": "MAC 3 con cargador, estuche, y adaptador USB-C HDMI", "OBSERVACIONES": ""}, {"ID": "VPNPRO340", "EQUIPO": "MAC 4 con cargador, estuche, y adaptador USB-C HDMI", "OBSERVACIONES": ""}, {"ID": "VPNAUD062", "EQUIPO": "Laptop HP Elitebook 845 G7 Notebook PC, con cargador y maletín", "OBSERVACIONES": ""}, {"ID": "VPNAUD063", "EQUIPO": "Dispositivo de audio USB-P Marca PEAVEY", "OBSERVACIONES": ""}]
442	109	IEES PRESENCIAL	[{"ID": "VPRO_ALT_26256", "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26379", "EQUIPO": "hub USB", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26448", "EQUIPO": "HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26466", "EQUIPO": "cables XLR", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26558", "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26591", "EQUIPO": "peavey", "OBSERVACIONES": "Una prestada de Hector"}, {"ID": "VPRO_ALT_26607", "EQUIPO": "stream deck", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11376", "EQUIPO": "cpu de escritorio Cod. Pdte", "OBSERVACIONES": "sufrio golpe"}, {"ID": "VPRO_ALT_11423", "EQUIPO": "Monitor gamer negro plano cod pdte", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11490", "EQUIPO": "Kit de teclado mouse y receptor inalambricon cod pte", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11525", "EQUIPO": "Panel de control TYST Video cod pte", "OBSERVACIONES": "None"}, {"ID": "", "EQUIPO": "Cables SDI", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Capturadora HDMI", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Grabadora SONY XD CAMEX HD", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Escalador Decimator", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "CONVERTIDOR BIMODAL BLACKMAGIC", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "convertidor Generico (SDI-HDMI)", "OBSERVACIONES": ""}, {"ID": "VPNPRO190", "EQUIPO": "Mezcladora de 4 canales Allen and Heath ZEDi-8", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Splitter 1x2 Marca OREY", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Mic Lavalier SONY", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190052", "EQUIPO": "Diademas camarografos", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090019", "EQUIPO": "Computador de Audio EN MALETA NARANJA VPNAUD062", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00232", "EQUIPO": "Transmisor Sony", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090042", "EQUIPO": "RECEPTORES SONY", "OBSERVACIONES": ""}]
444	104	CREE	[{"ID": "INV_VPRO_ALT_00175", "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00211", "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190050", "EQUIPO": "Pizacables", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00065", "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1040004", "EQUIPO": "Pantalla de 65", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "EQUIPO": "tripie", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090060", "EQUIPO": "XLR LARGO", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_26708", "EQUIPO": "Apuntador", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00062", "EQUIPO": "Mesa", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00063", "EQUIPO": "Silla", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00216", "EQUIPO": "Carpa", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090031", "EQUIPO": "Laptop G7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26591", "EQUIPO": "peavey", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190066", "EQUIPO": "USB cables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090039", "EQUIPO": "Capturadoras USB", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190017", "EQUIPO": "cables HDMI cortos", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Atolla convertidor", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090034", "EQUIPO": "ADAPTADOR USBC-HDMI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00143", "EQUIPO": "Laptop ASUS, con cargador", "OBSERVACIONES": ""}, {"ID": "VPNRED077", "EQUIPO": "UPS no-break Smartbitt, VPNRED077", "OBSERVACIONES": ""}]
446	201	KIT_STD_EVENTOS_FUERA_DE_OFICINA	[{"ID": "INV_VPRO_ALT_00013", "EQUIPO": "Laptop Asus con adaptador de red y cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00016", "EQUIPO": "Access Point TP-Link modelo  AX3600", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00017", "EQUIPO": "Switch de 5 puertos metalico", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00018", "EQUIPO": "Switch de 5 puertos de plastico negro", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00021", "EQUIPO": "Pinza para ponchar cables ethernet", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00022", "EQUIPO": "plugs para cables ethernet", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "EQUIPO": "Tripie", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00025", "EQUIPO": "UPS", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00092", "EQUIPO": "escalera plegable", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2010001", "EQUIPO": "Tablet samsung para monitoreo", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010003", "EQUIPO": "cables cortos ethernet cat 6", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00020", "EQUIPO": "Cables ethernet largos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020021", "EQUIPO": "Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2020022", "EQUIPO": "Starlink #2 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "VPNRED035", "EQUIPO": "Starlink #3 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}]
449	104	Lic Harfuch Rueda de Prensa	[{"ID": "", "EQUIPO": "Pantalla 65\\"", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Base de Guitarra", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Base Alta", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Base de Madera", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Cable SDI", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Distribuidor HDMI de 8", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Distribuidor HDMI de 2", "OBSERVACIONES": ""}]
451	104	Instalación Rueda de Prensa Harfuch	[{"ID": "Inv_alt_1040019", "EQUIPO": "base de metal", "OBSERVACIONES": ""}, {"ID": "VIRA004", "EQUIPO": "Pantalla de 65", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00054", "EQUIPO": "Base de Guitarra", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00055", "EQUIPO": "Base de Fierro Alta", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00211", "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00065", "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00053", "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00173", "EQUIPO": "cable sdi", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00056", "EQUIPO": "Distribuidor de HDMI de 8", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00058", "EQUIPO": "Distribuidor de HDMI de 2", "OBSERVACIONES": ""}]
452	109	HARFUSH MAZ	[{"ID": "VPRO_ALT_26256", "EQUIPO": "caja Vmix", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00141", "EQUIPO": "Cables HDMI", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00231", "EQUIPO": "Cables SDI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130013", "EQUIPO": "CABLE XLR", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26379", "EQUIPO": "hub USB", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26346", "EQUIPO": "Capturadoras HDMI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090065", "EQUIPO": "HDMI Splitter 1x2 OREI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "EQUIPO": "stream deck", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090002", "EQUIPO": "Diadema Sony", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Caja Docking Station Mokin usb-c", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26418", "EQUIPO": "HUB 1X7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26433", "EQUIPO": "Hub 1X6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090040", "EQUIPO": "CONVERTIDORES SDI-HDMI Blackmagic", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090041", "EQUIPO": "CONVERTIDOR BIMODAL BLACKMAGIC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190012", "EQUIPO": "microconverter HDMI A SDI Blackmagic", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "CONVERTIDORES SDI-HDMI Generico", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Peavey USB-P Interfaz de Audio y grabación USB a Salidas XLR", "OBSERVACIONES": ""}, {"ID": "VPNPRO339", "EQUIPO": "MAC 3 con cargador, estuche, y adaptador", "OBSERVACIONES": ""}, {"ID": "VPNPRO340", "EQUIPO": "MAC 4 con cargador, estuche, y adaptador", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090050", "EQUIPO": "BOCINA PREOSUND CON CABLES", "OBSERVACIONES": ""}, {"ID": "VPNPRO190", "EQUIPO": "Mezcladora de 4 canales Allen and Heath ZEDi-8", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090017", "EQUIPO": "Diademas de comunicación BEHRINGER", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090042", "EQUIPO": "RECEPTORES SONY", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090021", "EQUIPO": "Transmisor SONY", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00255", "EQUIPO": "Microfono Lavalier SONY", "OBSERVACIONES": ""}]
458	202	IEES Presencial	[{"ID": "VPNCOM007", "EQUIPO": "Laptop HP Elitebook 845 G7 Notebook PC, con cargador", "OBSERVACIONES": ""}, {"ID": "VPNRED071", "EQUIPO": "Tableta Smasung Galaxy Tabl A9 (color grafito) con cabe de corriente, portector y correa para protector.", "OBSERVACIONES": ""}, {"ID": "VPNEST015", "EQUIPO": "Switch de escritorio 5pts con adaptador de corriente", "OBSERVACIONES": ""}, {"ID": "VPNRED056", "EQUIPO": "Adaptadora USB C a ETHERNET", "OBSERVACIONES": ""}, {"ID": "VPNRED057", "EQUIPO": "Adaptadora USB C a ETHERNET", "OBSERVACIONES": ""}, {"ID": "VPNRED027", "EQUIPO": "Equipo Celular Samsung SM-A307G #6672173818 PW:Jovasa11", "OBSERVACIONES": ""}, {"ID": "VPNRED018", "EQUIPO": "MULTI GIGABIT WI-FI ACCESS POINT", "OBSERVACIONES": ""}, {"ID": "VPNRED103", "EQUIPO": "Router WiFi AX2 - WiFi 6 1500Mbps Router", "OBSERVACIONES": ""}, {"ID": "VPNRED076", "EQUIPO": "UPS no-break HIKVISION VPNRED076", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00189", "EQUIPO": "Pinza ponchadora passthrough", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020015", "EQUIPO": "Frasco con terminales utp cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020019", "EQUIPO": "Adaptadores eth a eth cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020012", "EQUIPO": "Adaptadores SC/PC a SC/PC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020033", "EQUIPO": "Cutter trupper", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00149", "EQUIPO": "Bolsa con cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010003", "EQUIPO": "cables cortos ethernet cat 6", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2020003", "EQUIPO": "Cable ethernet largo", "OBSERVACIONES": ""}]
461	119	KIT 3 CAMARAS OK	[{"ID": "INV_VPRO_ALT_00045", "EQUIPO": "CAMARAS 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00001", "EQUIPO": "tripies", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "EQUIPO": "baterías para cámara 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00101", "EQUIPO": "dollys", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00103", "EQUIPO": "monitor lilliput", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190005", "EQUIPO": "mochila negra", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "cinta gris", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00203", "EQUIPO": "baterias para monitor", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190007", "EQUIPO": "bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090067", "EQUIPO": "Decimator", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}]
465	202	TEBACAS BADIRAGUATO	[{"ID": "INV_ALT_2020026", "EQUIPO": "Switch tp-link 8 puertos VPNRED095", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020027", "EQUIPO": "Switch tp-link 8 puertos VPNRED096", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020029", "EQUIPO": "Encoder kiloview E3", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020030", "EQUIPO": "Cables SDI 1mt", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020024", "EQUIPO": "Laptop Asus Vivobook 15\\" D1502IA-BQ179W Ryzen 5 8GB RAM 256GB SSD con cargador VPNRED033", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020023", "EQUIPO": "Laptop HP Elitebook 845 G7 Notebook PC, con cargador VPNCOM007", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020018", "EQUIPO": "Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED056", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020025", "EQUIPO": "Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED057", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020017", "EQUIPO": "Equipo Celular Samsung SM-A307G #6672173818 VPNRED 027", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00189", "EQUIPO": "Pinza ponchadora passthrough", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020015", "EQUIPO": "Frasco con terminales utp cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020019", "EQUIPO": "Adaptadores eth a eth cat 6", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00149", "EQUIPO": "Bolsa con cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020012", "EQUIPO": "Adaptadores SC/PC a SC/PC", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00016", "EQUIPO": "Access Point TP-Link modelo  AX3600 VPNRED018", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020011", "EQUIPO": "Cable de fibra óptica 120 mts completo con terminales SC/APC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020010", "EQUIPO": "Kit convertidor de medios ethernet a fibra VPNRED112", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020032", "EQUIPO": "Teradek BOND PRO con estuche VPNRED012", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020033", "EQUIPO": "Cutter trupper", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020034", "EQUIPO": "Tripié para bocina sin tubo extersor", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00026", "EQUIPO": "Cable especial ethernet para StarLink (50 mts)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020035", "EQUIPO": "UPS (No-Break) Koblenz CODIGO VPNRED100", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020013", "EQUIPO": "UPS/Nobreak HIKVISION VPNRED076", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020021", "EQUIPO": "Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020022", "EQUIPO": "Starlink #3 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00092", "EQUIPO": "Escalera de tijera pequeña", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020040", "EQUIPO": "HC200 - Audifonos behringer HC200", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020041", "EQUIPO": "VPNRED022 - ROUTER GIGABIT MULTI-WAN VPN SAFESTREAM", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2020042", "EQUIPO": "VPNRED103 - Router WiFi AX2 - WiFi 6 1500Mbps Router", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020009", "EQUIPO": "Caja grande c/tapa azul con cables ethernet cortos y largos", "OBSERVACIONES": ""}]
466	119	KIT TEBACAS FINAL	[{"ID": "INV_ALT_1190038", "EQUIPO": "micrófono de maraca", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190039", "EQUIPO": "atem sdi", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190034", "EQUIPO": "BARRA DE ENERGIA", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00151", "EQUIPO": "cables hdmi gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190042", "EQUIPO": "monitores liliput", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190044", "EQUIPO": "monitor 21.5 pulgadas", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00202", "EQUIPO": "2 Sistema de comunicación (6 bodis)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190045", "EQUIPO": "memorias sxs", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190046", "EQUIPO": "cámaras miniblack", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190047", "EQUIPO": "cable SDI largos ( 3 LARGOS NEGROS Y 2 LILAS)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190048", "EQUIPO": "lineas de audio largas", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190081", "EQUIPO": "camara go pro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190080", "EQUIPO": "Hielera", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190049", "EQUIPO": "microfonos para ambiente", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00045", "EQUIPO": "CAMARAS 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "EQUIPO": "baterías para cámara 320", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190083", "EQUIPO": "memoria SD", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1190084", "EQUIPO": "Rack con vectorscopio", "OBSERVACIONES": "[CUST_EQ:Rack con vectorscopio]"}, {"ID": "", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190029", "EQUIPO": "lineas de energia", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "cinta gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190007", "EQUIPO": "bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190050", "EQUIPO": "Pizacables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190051", "EQUIPO": "Trpies", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190052", "EQUIPO": "Diademas camarografos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020036", "EQUIPO": "Audifonos behringer HC200 (GERARDO)", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00153", "EQUIPO": "Mesa grande", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190072", "EQUIPO": "Mesa chica", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190073", "EQUIPO": "Mochila azul", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090044", "EQUIPO": "cable SDI corto", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190074", "EQUIPO": "cable SDI mediano", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190075", "EQUIPO": "mini contactos de energía blancos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190076", "EQUIPO": "mini converter blackmagig", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190077", "EQUIPO": "escalador decimator", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190037", "EQUIPO": "lampara portatil", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190082", "EQUIPO": "pedestales para lampara y gopro", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1190036", "EQUIPO": "Cable SDI LILA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190085", "EQUIPO": "cable  HDMI de 50 metros", "OBSERVACIONES": ""}]
467	119	KIT 3 CAMARA OK	[{"ID": "INV_VPRO_ALT_00045", "EQUIPO": "CAMARAS 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00001", "EQUIPO": "tripies", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "EQUIPO": "baterías para cámara 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00101", "EQUIPO": "dollys", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00103", "EQUIPO": "monitor lilliput", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190005", "EQUIPO": "mochila negra con cables ethernet varios", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "cinta gris", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00203", "EQUIPO": "baterias para monitor", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190007", "EQUIPO": "bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090067", "EQUIPO": "Decimator", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}]
470	104	TEBACAS	[{"ID": "", "EQUIPO": "Pantalla de 65", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Base de Guitarra", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Base de madera", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Base alta", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Cable SD", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Distribuidor de HDMI de 8", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Distribuidor de HDMI de 2", "OBSERVACIONES": ""}]
474	104	Kit Diario	[{"ID": "INV_ALT_1090047", "EQUIPO": "DIADEMA DE AUDIO", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00217", "EQUIPO": "Monitor de 55''", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00175", "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00211", "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00156", "EQUIPO": "Base de Madera", "OBSERVACIONES": ""}]
468	119	KIT 2 CAMARA OK	[{"ID": "INV_VPRO_ALT_00045", "EQUIPO": "CAMARAS 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00001", "EQUIPO": "tripies", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "EQUIPO": "baterías para cámara 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00101", "EQUIPO": "dollys", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00103", "EQUIPO": "monitor lilliput", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190005", "EQUIPO": "mochila negra con cables ethernet varios", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "cinta gris", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00203", "EQUIPO": "baterias para monitor", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190007", "EQUIPO": "bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090067", "EQUIPO": "Decimator", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}]
469	109	Fiscalia	[{"ID": "INV_ALT_1090031", "EQUIPO": "Laptop G7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26379", "EQUIPO": "HUB USB", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26673", "EQUIPO": "Adaptador tipo C a HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "EQUIPO": "Stream deck", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00190", "EQUIPO": "Modem Quantum", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00174", "EQUIPO": "CableHDMI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130013", "EQUIPO": "CABLE XLR", "OBSERVACIONES": ""}]
475	109	Harfush Culiacan	[{"ID": "VPRO_ALT_26256", "EQUIPO": "caja Vmix", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00141", "EQUIPO": "Cables HDMI", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00231", "EQUIPO": "Cables SDI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130013", "EQUIPO": "CABLE XLR", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26379", "EQUIPO": "hub USB", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26346", "EQUIPO": "Capturadoras HDMI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090065", "EQUIPO": "HDMI Splitter 1x2 OREI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "EQUIPO": "stream deck", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090002", "EQUIPO": "Diadema Sony", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Caja Docking Station Mokin usb-c", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26418", "EQUIPO": "HUB 1X7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26433", "EQUIPO": "Hub 1X6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090040", "EQUIPO": "CONVERTIDORES SDI-HDMI Blackmagic", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090041", "EQUIPO": "CONVERTIDOR BIMODAL BLACKMAGIC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190012", "EQUIPO": "microconverter HDMI A SDI Blackmagic", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "CONVERTIDORES SDI-HDMI Generico", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "Peavey USB-P Interfaz de Audio y grabación USB a Salidas XLR", "OBSERVACIONES": ""}, {"ID": "VPNPRO339", "EQUIPO": "MAC 3 con cargador, estuche, y adaptador", "OBSERVACIONES": ""}, {"ID": "VPNPRO340", "EQUIPO": "MAC 4 con cargador, estuche, y adaptador", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090050", "EQUIPO": "BOCINA PREOSUND CON CABLES", "OBSERVACIONES": ""}, {"ID": "VPNPRO190", "EQUIPO": "Mezcladora de 4 canales Allen and Heath ZEDi-8", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090017", "EQUIPO": "Diademas de comunicación BEHRINGER", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090042", "EQUIPO": "RECEPTORES SONY", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090021", "EQUIPO": "Transmisor SONY", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00255", "EQUIPO": "Microfono Lavalier SONY", "OBSERVACIONES": ""}]
476	201	KIT_STD_EVENTOS_SSPC	[{"ID": "INV_VPRO_ALT_00013", "EQUIPO": "Laptop Asus con adaptador de red y cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00016", "EQUIPO": "Access Point TP-Link modelo  AX3600", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00017", "EQUIPO": "Switch de 5 puertos metalico", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00018", "EQUIPO": "Switch de 5 puertos de plastico negro", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00021", "EQUIPO": "Pinza para ponchar cables ethernet", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00022", "EQUIPO": "plugs para cables ethernet", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "EQUIPO": "Tripie", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00025", "EQUIPO": "UPS", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00092", "EQUIPO": "escalera plegable", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2010001", "EQUIPO": "Tablet samsung para monitoreo", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010003", "EQUIPO": "cables cortos ethernet cat 6", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00020", "EQUIPO": "Cables ethernet largos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020021", "EQUIPO": "Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2020022", "EQUIPO": "Starlink #2 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "VPNRED035", "EQUIPO": "Starlink #3 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}]
477	119	KIT EVENTO ESPECIAL 3 CAMARAS	[{"ID": "INV_VPRO_ALT_00045", "EQUIPO": "CAMARAS 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00001", "EQUIPO": "tripies", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "EQUIPO": "baterías para cámara 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00099", "EQUIPO": "radios", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00101", "EQUIPO": "dollys", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00211", "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00103", "EQUIPO": "monitor lilliput", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "BATERIAS SONY NP-F970", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00205", "EQUIPO": "Escaladores decimator", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1190005", "EQUIPO": "mochila negra", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190007", "EQUIPO": "bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "cinta gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190068", "EQUIPO": "Rollo de alambre", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190008", "EQUIPO": "microconverter bidireccional", "OBSERVACIONES": ""}, {"ID": "", "EQUIPO": "CABLE DE ENERGIA ", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00231", "EQUIPO": "Cables SDI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190022", "EQUIPO": "cajita naranja con conectores y coples (HDMI Y SDI)", "OBSERVACIONES": ""}]
\.


--
-- Data for Name: mantenimiento_equipos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mantenimiento_equipos (id_solicitud, num_servicio, fecha_reporte, folio_vpro, estatus_proceso, codigo_equipo, area_pertenece, marca, modelo, num_serie, responsable_actual, quien_reporta, responsiva_anterior, "descripcion_daño", tipo_accion, detalles_reparacion, encargado_reparacion, quien_recibe_equipo, fecha_entrada_taller, fecha_entrega_estimada, costo_reparacion, cotizacion_1, cotizacion_2, cotizacion_3, cotizacion_seleccionada, fecha_pago, fecha_llegada_nuevo, nueva_responsiva, firmas_digitales, registrado_por) FROM stdin;
\.


--
-- Data for Name: plantillas_checkout; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.plantillas_checkout (id_plantilla, nombre_kit, departamento, codigo_equipo, cantidad) FROM stdin;
\.


--
-- Data for Name: reuniones_previas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reuniones_previas (id_reunion, fecha_reunion, cliente_tentativo, nombre_proyecto_tentativo, asistentes, minuta_acuerdos, presupuesto_estimado, fecha_probable_evento, estatus_proyecto, fecha_registro, folio_op_generado) FROM stdin;
3	2026-08-31	H.ayuntamiento Badiragutao	Reunión para el arranque de los partidos de TEBACAS	Pedro Villarreal, Manuel Madrid, Martin Estrada, Gerardo Villarreal, Manuel Eduardo Madrid, Andrea Villarreal,  Francisco Torres, Edgar Amarillas, Osiel Hernández y Carlos Quezada	Resumen de la reunión\nTema 1: Salida a Badiraguato para realizar scouting y hacer pruebas para los partidos de TEBACAS.\nTema 2: Ajustar últimos detalles y aclarar últimas dudas para el inicio de los partidos de TEBACAS.\nAcuerdos y compromisos finales\n1.\tSe acordó que el 1 de septiembre de 2026, a las 9:00 a. m., el personal deberá presentarse en la oficina para posteriormente trasladarse a Badiraguato, donde se realizará el scouting y las pruebas correspondientes. El equipo deberá estar listo para iniciar las pruebas a la 1:00 p. m.\n2.\tSe acordó dar prioridad al canal de VPRO Sports, así como realizar la transmisión de los juegos a través de las plataformas de Facebook y YouTube.\n3.\tSe acordó que producción llevará 3 cámaras 320 y 2 cámaras Blackmagic.\n4.\tSe acordó que el Switcher Osiel Hernández dejará preparado el equipo de audio para que Francisco Torres se encargue del monitoreo del audio.\n5.\tSe acordó que Lupita, del área de Comunicación Social del Ayuntamiento de Badiraguato, notificará que VPRO Sports realizará tomas aéreas con dron durante la cobertura del evento.\n6.\tSe acordó que durante el medio tiempo del primer partido se realizará una entrevista, la cual estará a cargo del conductor Miguel, quien se encontrará en la locación.\n7.\tSe acordó que se instalara el equipo SHARK para regular el audio de video.\n8.\tSe acordó llevar una lámpara para contar con la iluminación adecuada durante la realización de la entrevista.\n9.\t La jefa de edición Andrea Villarreal se comprometió a integrar las tomas en las promociones una vez que reciba el material correspondiente.\n10.\t Se acordó que se realizará solamente una promo. Así como el video de promo y carteles, junto con las portadas y lowers.\n11.\t Se acordó en realizar una escaleta.\n12.\t Se acordó expresar un agradecimiento a Martha Lilia Roque y al ayuntamiento de Badiraguato por el apoyo brindado para el arranque de los partidos de TEBACAS\n13.\t Se acordó hacer un llamado a los conductores y se presenten con anticipación, de acuerdo con el horario previamente establecido, a fin de garantizar la puntualidad y el buen desarrollo de cada evento.\n14.\t Se acordó utilizar doble caja para que se comuniquen los conductores.\n15.\t Se acordó que se utilizarán 2 equipos de vMix call.\n16.\t Se acordó en quitar la música ambiental del estadio durante la transmisión.\n17.\t La jefa de edición Andrea Villarreal se comprometió a preparar y tener disponible la música que se utilizará tanto en el loop como en la introducción de las transmisiones.\n18.\t Se acordó instalar 2 líneas de audio en el estadio con los micrófonos en el suelo.\n19.\t Carlos se comprometió a terminar los CODYS.\n20.\t Se acordó que los conductores deberán portar playeras del mismo color, con el objetivo de mantener una imagen uniforme durante las transmisiones\n21.\t Se acordó que la tela verde del estudio Vpro, la acomodaran ordenadamente.\n22.\t Se compromete el ingeniero Edgar Amarillas en enviar el streaming codificado en H.265 1080p a 2 mb de bitrate a el Switcher Osiel Hernández.\n23.\t Se acordó que el jefe de Producción de Deportes, Manuel Madrid, notificará a Lupita, del área de Comunicación, que su equipo será responsable de proporcionar las pantallas y la laptop necesarias. Asimismo, se brindará apoyo con el cableado que se requiera para la instalación y funcionamiento de los equipos.\n	0.00	2026-09-04	CONVERTIDO A OP	2026-09-12 10:59:40.60497	11
8	2026-09-12	Gobierno del estado de sinaloa	Instalación el 14 de septiembre para el grito de la independencia	Pedro Villarreal, Ana Lilia Villarreal, Andrea Villarreal, Sofia Villarreal, Martin Estrada, Manuel Madrid y Manuel Eduardo Madrid	Resumen\nTema 1: Seguimiento para la instalación del evento del grito de la independencia\n\nAcuerdos y compromisos finales\nSe acordó que el lunes 14 de septiembre de 2026 se instalara en el palacio de gobierno\nSe acordó que a las 9:00 am será la entrada a oficina y cargaran equipo\nSe acordó que se unirán al llamado los externos Eduardo y Calixto con entrada de 11:00 pm en el palacio de gobierno.\nSe acordó que el corte a comer será de 2:00 pm a 4:00 pm y regresando del corte a comer se regresan a instalar en el palacio de gobierno\nSe acordó comprar agua para la hidratación del personal de producción que asistirá a instalar\nSe acordó tener sombrillas por alguna emergencia de cambio climático como lluvias\nSe acordó el 12 de septiembre de 2026 hacer el llamado para el  14 de septiembre de 2026\nSe acordó cargar gasolina el lunes 14 de septiembre\n	0.00	2026-09-14	CONVERTIDO A OP	2026-09-12 14:16:54.261971	19
4	2026-08-13	H.ayuntamiento Badiraguato	Reunión para eventos basquetbol de TEBACAS. 	Pedro Villarreal, Manuel Madrid, Manuel Eduardo Madrid, Sofia Villarreal, Andrea Villarreal, Edgar Amarillas	Resumen de la reunión\nTema 1: La reunión tuvo como objetivo dar seguimiento y revisar los avances relacionados con los eventos de TEBACAS\nTema 2: Dar seguimiento a la operación y contenidos de los canales de VPRO Sports.\n\nAcuerdos y compromisos finales\n1.\tEl Sr. Pedro Villarreal se pondrá en contacto con TVC Deportes para coordinar la transmisión de los eventos de basquetbol de TEBACAS a través de los canales de VPRO Sports.\n2.\tSe acordó verificar la disponibilidad de los permisos necesarios para realizar las transmisiones a través de YouTube, Facebook e Instagram.\n3.\tSe acordó dar seguimiento al canal de VPRO Sports y actualizar el banner de la página de Facebook.\n4.\tSe acordó retomar y dar seguimiento a las cuentas de TikTok e Instagram. \n	0.00	2026-09-04	CONVERTIDO A OP	2026-09-12 11:02:17.264301	11
7	2026-09-10	Gobierno del estado de sinaloa	Reunión para evento del grito de la independencia	Martin Estrada, Manuel Madrid, Manuel Eduardo Madrid, Osiel Hernandez, Edgar Amarillas, Francisco Torres, Carlos Quezada y Daniel Torres	Resumen de la reunión\nTema 1: Panificación para evento del día 15 de septiembre grito de la independencia de México.\n\nAcuerdos y compromisos finales\n1.\tSe acordó que producción de Vpro, harán pruebas el 14 de septiembre dependiendo a algún cambio de último momento.\n2.\tSe acordó que a las 4:00 pm del 10 de septiembre de 2026 el ingeniero Edgar Amarillas y el jefe de producción Martin Estrada irán a realizar pruebas de internet en el palacio de gobierno.\n3.\tSe acordó que se solicitaran tarimas de buena calidad.\n4.\tEl jefe de producción de deportes Manuel Madrid se comprometió a tener las 8 comunicaciones para los camarógrafos.\n5.\tSe acordó que se grabara en vMix y una grabadora. Se utilizará la laptop G7.\n6.\tSe acordó que se utilizara para el evento una botonera para las pantallas.\n7.\tSe acordó en buscar música sin derechos para utilizarla.\n	0.00	2026-09-15	CONVERTIDO A OP	2026-09-12 11:20:05.371995	19
6	2026-09-08	H.ayuntamiento Badiraguato	Reunión para dar seguimiento a las incidencias de los eventos de liga de baloncesto del pacifico “TEBACAS”	Pedro Villarreal, Manuel Madrid, Manuel Eduardo Madrid,  Andrea Villarreal, Francisco Torres, Cuauhtemoc Rivera, Edgar Amarillas, Osiel Hernandez, Carlos Quezada, 	Resumen de la reunión\nTema 1: Incidencias en la producción de los partidos de TEBACAS\nTema 2: Cuando se ingresaron los patrocinios se dropeo la transmisión\nAcuerdos y compromisos finales \n1.\tEl ingeniero Edgar Amarillas se comprometió a realizar el traslado de las tarjetas y accesorios a la laptop I9\n2.\tSe acordó que la producción de Vprosports tendrán una mejor comunicación y tendrán un medio fijo para ello.\n3.\tSe acordó que Carlos Quezada de gráficos será el intermediario para la comunicación\n4.\tSe acordó que ajustaran los discos duros y checaran la configuración de la grabadora.\n5.\tSe acordó que harán pruebas de grabación en la computadora una vez ajustando los discos duros.\n6.\tSe acordó tener un protocolo de emergencia.\n7.\tLa jefa de edición Andrea Villarreal se comprometió a tener los separadores y entregar al Switcher Osiel Hernández.\n8.\tEl ingeniero Cuauhtemoc Rivera se compromete a monitorear las transmisiones de los partidos de la liga de baloncesto del pacifico mediante YouTube.\n9.\tSe acordó que el encargado de audio utilizara audífonos para los partidos.\n10.\tEl Switcher Osiel Hernández se comprometió a capacitar a Francisco Torres en audio.\n	0.00	2026-09-27	CONVERTIDO A OP	2026-09-12 11:09:35.56833	11
5	2026-08-17	H.ayuntamiento Badiraguato	Reunión para partidos de basquetbol de TEBACAS	Pedro Villarreal, Manuel Madrid, Manuel Eduardo Madrid, Sofia Villarreal, Andrea Villarreal, Cuauhtemoc Rivera, Edgar Amarillas y Carlos Quezada	Resumen de la reunión\nTema 1: Transmisión de partidos de basquetbol de TEBACAS.\nTema 2: Acordar las fechas de los partidos de basquetbol de TEBACAS.\nAcuerdos y compromisos finales\n1.\tSe acordó las transmisiones por HISPORTS y el canal de VPROSPORTS, junto con su respectiva campaña de promoción.\n2.\tSe acordó que el jefe de producción de deportes Manuel Madrid y el ingeniero Edgar Amarillas se trasladarán el 26 de agosto a la locación de Badiraguato para realizar el scouting de la locación.\n3.\tSe solicitará el apoyo de Gerardo Villarreal para acompañar al equipo de producción a Badiraguato y coordinar el levantamiento de video con dron.\n4.\tEl equipo de redes investigará los requerimientos y la infraestructura de conectividad disponibles en las sedes de los próximos partidos.\n5.\tSe estableció realizar pruebas técnicas de transmisión directamente en la locación seleccionada.\n6.\tSe asignó al equipo de edición la responsabilidad de elaborar los diseños gráficos para los partidos de basquetbol de TEBACAS.\n7.\tSe calendarizaron los partidos de basquetbol para los días 4, 5, 6 y 26 de septiembre, así como el 3, 10 y 16 de octubre.\n8.\t Se determinó contar con dos conductores para la cobertura de los partidos, a excepción de las fechas del 4 y 27 de septiembre, y el 16 de octubre, donde se cubrirá con un solo conductor.\n9.\tEl equipo de edición se comprometió a publicar un resumen en video de cada juego en la página de VPROSPORTS al finalizar el encuentro.\n10.\t Se acordó la producción y publicación de reels en TikTok para dar cobertura a cada uno de los partidos.\n	0.00	2026-09-04	CONVERTIDO A OP	2026-09-12 11:05:15.372223	11
9	2026-09-17	Gobierno del estado de sinaloa	Incidencias del evento grito de independencia	Pedro Villarreal, Martin Estrada, Manuel Madrid, Gerardo Villarreal, Manuel Eduardo Madrid, Osiel Hernández, Cuauhtémoc Rivera y Edgar Amarillas.	Resumen de la reunión\nTema 1: Seguimiento de incidencias del evento grito de independencia.\n\nAcuerdos y compromisos finales \n1.\tSe acordó para próximos eventos contar con ups para cualquier emergencia que suceda.\n2.\tSe acordó checar el mouse ante posibles fallos del equipo 3play.\n3.\tSe acordó montar el Switcher ATEM costellation para hacer pruebas.\n4.\tSe acordó revisar la configuración inicial para que quede grabado.\n5.\tSe acordó que se tendrá más control y organización en los futuros eventos.\n6.\tSe acordó conseguir a un ingeniero de audio más capacitado.\n7.\tSe compromete el personal de producción evitar interrumpir las actividades que se encuentren realizando para acudir en búsqueda de personal externo cuando este requiera algún apoyo, favor o atención. Será responsabilidad del personal externo acercarse o comunicarse directamente con el equipo correspondiente para solicitar el apoyo que necesite.\n	0.00	2026-09-15	CONVERTIDO A OP	2026-09-17 14:27:00.12986	19
10	2026-10-19	Ayuntamiento Badiraguato	Partidos TEBACAS	Manuel Madrid, Martin Estrada, Manuel Eduardo Madrid, Osiel Hernández, Edgar Amarillas, Andrea Villarreal, Francisco Torres, Carlos Quezada, Daniel Torres y Cuauhtémoc Rivera.	Resumen de la reunión: Se hizo una reunión en el estudio VPRO a las 11:00 AM sobre las incidencias de los partidos anteriores de TEBACAS.\nSe llevo a cabo el análisis de incidencias para así darle seguimiento y darle solución para tratar que no se presenten de nuevo.\n\nAcuerdos\nFrancisco Torres se comprometió a estar al pendiente en los partidos de TEBACAS en cuestiones del audio, se acordó que mientras no empiece el juego no debe haber el sonido ambiental. Se acordó que se cerrara el audio del comentarista Neto Gutiérrez cuando no este hablando.\nSe acordó utilizar otro vMix call (tipo VAR).\nAndrea Villarreal se comprometió a hacer la promo sobre las 14 victorias invictas que podrán alcanzar el equipo de TEBACAS y seria un récord histórico en la liga.\nCarlos Quezada se comprometió a volver hacer los lowers.\nOsiel Hernández se comprometió a hacer los lowers de los comentaristas.\nEl ing. Cuauhtémoc Rivera se compromete en apoyar con la ortografía a Carlos Quezada.\nSe acordó para la producción de TEBACAS del estudio en no ingresar los cintillos si no están hablando del tema.\nSe acordó que cuando ingresen los cintillos dejarlos que corran hasta que deje de hablar los conductores.\nSe hará un collage  de 1 minuto sobre las festividades del día 28 de octubre en Badiraguato. (ilustraciones de imágenes).\nSe acordó que el Switcher Osiel Hernández será mas claro con la comunicación con el camarógrafo respecto a las tomas.\nSe acoró que 10 minutos antes de empezar la transmisión se correrá el loop.\nSe acordó que el ing. Edgar Amarillas revisara la bitácora de vMix.\nManuel Madrid el productor de deportes se comprometió en hablar con Javier Garcia de repeticiones sobre las repes en los momentos mas cruciales.\nSe acordó que en el próximo juego Daniel Torres sumara el cargo de gráficos.\nSe acordó que el martes 20 y miércoles 21 de octubre Daniel Torres practicara con los gráficos.\nSe acordó que en el llamado de la producción del estudio al momento de llegar se hará check list del equipo que requieren y realizarán pruebas.\nSe acordó que el productor de deportes Manuel Madrid hablara con la jueza para que no ingrese de inmediato el 2do periodo al terminar el 1er periodo.\nSe acordó que el próximo juego iniciara a las 7:00 PM.\nSe acordó que el llamado para la producción que va a la arena Badiraguato será a las 8:00 AM.\nSe acordó que el llamado para la producción del estudio será a las 3:00 PM.\n	0.00	2026-10-22	VINCULADO A OP	2026-10-19 13:52:53.824007	43
\.


--
-- Name: asistencia_locacion_id_asistencia_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.asistencia_locacion_id_asistencia_seq', 592, true);


--
-- Name: chat_op_mensajes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.chat_op_mensajes_id_seq', 133, true);


--
-- Name: checkouts_detalle_id_detalle_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.checkouts_detalle_id_detalle_seq', 5899, true);


--
-- Name: checkouts_maestro_id_maestro_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.checkouts_maestro_id_maestro_seq', 152, true);


--
-- Name: cronogramas_eventos_id_cronograma_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cronogramas_eventos_id_cronograma_seq', 5, true);


--
-- Name: eventos_id_evento_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.eventos_id_evento_seq', 173, true);


--
-- Name: informes_gastos_detalle_id_detalle_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.informes_gastos_detalle_id_detalle_seq', 113, true);


--
-- Name: informes_gastos_maestro_id_informe_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.informes_gastos_maestro_id_informe_seq', 36, true);


--
-- Name: kits_empleados_id_kit_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.kits_empleados_id_kit_seq', 477, true);


--
-- Name: mantenimiento_equipos_id_solicitud_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.mantenimiento_equipos_id_solicitud_seq', 1, false);


--
-- Name: plantillas_checkout_id_plantilla_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.plantillas_checkout_id_plantilla_seq', 1, false);


--
-- Name: reuniones_previas_id_reunion_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reuniones_previas_id_reunion_seq', 10, true);


--
-- Name: asistencia_locacion asistencia_locacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asistencia_locacion
    ADD CONSTRAINT asistencia_locacion_pkey PRIMARY KEY (id_asistencia);


--
-- Name: chat_op_mensajes chat_op_mensajes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_op_mensajes
    ADD CONSTRAINT chat_op_mensajes_pkey PRIMARY KEY (id);


--
-- Name: checkouts_detalle checkouts_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkouts_detalle
    ADD CONSTRAINT checkouts_detalle_pkey PRIMARY KEY (id_detalle);


--
-- Name: checkouts_maestro checkouts_maestro_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkouts_maestro
    ADD CONSTRAINT checkouts_maestro_pkey PRIMARY KEY (id_maestro);


--
-- Name: cronogramas_eventos cronogramas_eventos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cronogramas_eventos
    ADD CONSTRAINT cronogramas_eventos_pkey PRIMARY KEY (id_cronograma);


--
-- Name: eventos eventos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eventos
    ADD CONSTRAINT eventos_pkey PRIMARY KEY (id_evento);


--
-- Name: eventos folio; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eventos
    ADD CONSTRAINT folio UNIQUE (folio);


--
-- Name: informes_gastos_detalle informes_gastos_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.informes_gastos_detalle
    ADD CONSTRAINT informes_gastos_detalle_pkey PRIMARY KEY (id_detalle);


--
-- Name: informes_gastos_maestro informes_gastos_maestro_folio_vpro_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.informes_gastos_maestro
    ADD CONSTRAINT informes_gastos_maestro_folio_vpro_key UNIQUE (folio_vpro);


--
-- Name: informes_gastos_maestro informes_gastos_maestro_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.informes_gastos_maestro
    ADD CONSTRAINT informes_gastos_maestro_pkey PRIMARY KEY (id_informe);


--
-- Name: kits_empleados kits_empleados_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kits_empleados
    ADD CONSTRAINT kits_empleados_pkey PRIMARY KEY (id_kit);


--
-- Name: mantenimiento_equipos mantenimiento_equipos_num_servicio_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mantenimiento_equipos
    ADD CONSTRAINT mantenimiento_equipos_num_servicio_key UNIQUE (num_servicio);


--
-- Name: mantenimiento_equipos mantenimiento_equipos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mantenimiento_equipos
    ADD CONSTRAINT mantenimiento_equipos_pkey PRIMARY KEY (id_solicitud);


--
-- Name: plantillas_checkout plantillas_checkout_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plantillas_checkout
    ADD CONSTRAINT plantillas_checkout_pkey PRIMARY KEY (id_plantilla);


--
-- Name: reuniones_previas reuniones_previas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reuniones_previas
    ADD CONSTRAINT reuniones_previas_pkey PRIMARY KEY (id_reunion);


--
-- Name: checkouts_maestro unique_op_empleado; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkouts_maestro
    ADD CONSTRAINT unique_op_empleado UNIQUE (folio_op, id_empleado);


--
-- Name: eventos uq_folio; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eventos
    ADD CONSTRAINT uq_folio UNIQUE (folio);


--
-- Name: eventos uq_folio_vpro; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eventos
    ADD CONSTRAINT uq_folio_vpro UNIQUE (folio);


--
-- Name: idx_asistencia_evento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asistencia_evento ON public.asistencia_locacion USING btree (id_evento);


--
-- Name: idx_chat_op_mensajes_evento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_chat_op_mensajes_evento ON public.chat_op_mensajes USING btree (id_evento, fecha_hora);


--
-- Name: chat_op_mensajes chat_op_mensajes_id_evento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_op_mensajes
    ADD CONSTRAINT chat_op_mensajes_id_evento_fkey FOREIGN KEY (id_evento) REFERENCES public.eventos(id_evento) ON DELETE CASCADE;


--
-- Name: checkouts_detalle checkouts_detalle_id_maestro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkouts_detalle
    ADD CONSTRAINT checkouts_detalle_id_maestro_fkey FOREIGN KEY (id_maestro) REFERENCES public.checkouts_maestro(id_maestro) ON DELETE CASCADE;


--
-- Name: informes_gastos_detalle informes_gastos_detalle_id_informe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.informes_gastos_detalle
    ADD CONSTRAINT informes_gastos_detalle_id_informe_fkey FOREIGN KEY (id_informe) REFERENCES public.informes_gastos_maestro(id_informe) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict c5ka1pAXywZuCrYnfZQzRRfJMFZqx6ZIZyqfdkvAsWgXgrMSUvNmtGIpOT6ddRM

