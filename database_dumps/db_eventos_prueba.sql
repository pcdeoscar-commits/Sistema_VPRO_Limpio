--
-- PostgreSQL database dump
--

\restrict b2Mhjex3yWCeaSTPNtM7Ci4nY0lBId1lHsAc3paFsQKvjH5OlVYt5ja7ApD5LoZ

-- Dumped from database version 18.4
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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: asistencia_locacion; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.asistencia_locacion OWNER TO postgres;

--
-- Name: asistencia_locacion_id_asistencia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.asistencia_locacion_id_asistencia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.asistencia_locacion_id_asistencia_seq OWNER TO postgres;

--
-- Name: asistencia_locacion_id_asistencia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.asistencia_locacion_id_asistencia_seq OWNED BY public.asistencia_locacion.id_asistencia;


--
-- Name: checkouts_detalle; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.checkouts_detalle OWNER TO postgres;

--
-- Name: checkouts_detalle_id_detalle_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.checkouts_detalle_id_detalle_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.checkouts_detalle_id_detalle_seq OWNER TO postgres;

--
-- Name: checkouts_detalle_id_detalle_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.checkouts_detalle_id_detalle_seq OWNED BY public.checkouts_detalle.id_detalle;


--
-- Name: checkouts_maestro; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.checkouts_maestro OWNER TO postgres;

--
-- Name: checkouts_maestro_id_maestro_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.checkouts_maestro_id_maestro_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.checkouts_maestro_id_maestro_seq OWNER TO postgres;

--
-- Name: checkouts_maestro_id_maestro_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.checkouts_maestro_id_maestro_seq OWNED BY public.checkouts_maestro.id_maestro;


--
-- Name: eventos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.eventos (
    id_evento integer NOT NULL,
    folio character varying(3) NOT NULL,
    fec_de_elaboracion_de_op date DEFAULT CURRENT_DATE,
    empleado_que_creo_la_op character varying(100),
    para_q_cliente character varying(100),
    fec_de_instalacion date,
    nombre_evento character varying(100),
    hra_de_instalacion time without time zone,
    locacion character varying(100),
    fec_del_evento date,
    inicio_del_evento time without time zone,
    quien_solicita character varying(100),
    hra_de_llamado time without time zone,
    ubicacion character varying(150),
    resp_de_produccion character varying(100),
    tipo_de_servicio text,
    produccion text,
    internet_redes text,
    actividades_de_proveedores text,
    nota text,
    elabora character varying(40),
    organiza character varying(40),
    coordina character varying(40),
    vobo character varying(40),
    proveedor_op text[],
    personal_convocado_op text[],
    carros_usados_op text[],
    externos_op text[],
    estatus character varying(50) DEFAULT 'ACTIVA'::character varying,
    reuniones_vinculadas text[]
);


ALTER TABLE public.eventos OWNER TO postgres;

--
-- Name: eventos_id_evento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.eventos_id_evento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.eventos_id_evento_seq OWNER TO postgres;

--
-- Name: eventos_id_evento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.eventos_id_evento_seq OWNED BY public.eventos.id_evento;


--
-- Name: informes_gastos_detalle; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.informes_gastos_detalle OWNER TO postgres;

--
-- Name: informes_gastos_detalle_id_detalle_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.informes_gastos_detalle_id_detalle_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.informes_gastos_detalle_id_detalle_seq OWNER TO postgres;

--
-- Name: informes_gastos_detalle_id_detalle_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.informes_gastos_detalle_id_detalle_seq OWNED BY public.informes_gastos_detalle.id_detalle;


--
-- Name: informes_gastos_maestro; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.informes_gastos_maestro OWNER TO postgres;

--
-- Name: informes_gastos_maestro_id_informe_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.informes_gastos_maestro_id_informe_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.informes_gastos_maestro_id_informe_seq OWNER TO postgres;

--
-- Name: informes_gastos_maestro_id_informe_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.informes_gastos_maestro_id_informe_seq OWNED BY public.informes_gastos_maestro.id_informe;


--
-- Name: kits_empleados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kits_empleados (
    id_kit integer NOT NULL,
    id_empleado character varying(10),
    nombre_kit character varying(50),
    items jsonb
);


ALTER TABLE public.kits_empleados OWNER TO postgres;

--
-- Name: kits_empleados_id_kit_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kits_empleados_id_kit_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kits_empleados_id_kit_seq OWNER TO postgres;

--
-- Name: kits_empleados_id_kit_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kits_empleados_id_kit_seq OWNED BY public.kits_empleados.id_kit;


--
-- Name: mantenimiento_equipos; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.mantenimiento_equipos OWNER TO postgres;

--
-- Name: COLUMN mantenimiento_equipos.cotizacion_1; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.mantenimiento_equipos.cotizacion_1 IS 'Datos de compra: Proveedor, Cant, Costo, Importe, Plazo';


--
-- Name: mantenimiento_equipos_id_solicitud_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mantenimiento_equipos_id_solicitud_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mantenimiento_equipos_id_solicitud_seq OWNER TO postgres;

--
-- Name: mantenimiento_equipos_id_solicitud_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mantenimiento_equipos_id_solicitud_seq OWNED BY public.mantenimiento_equipos.id_solicitud;


--
-- Name: plantillas_checkout; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plantillas_checkout (
    id_plantilla integer NOT NULL,
    nombre_kit text NOT NULL,
    departamento text NOT NULL,
    codigo_equipo text NOT NULL,
    cantidad integer DEFAULT 1
);


ALTER TABLE public.plantillas_checkout OWNER TO postgres;

--
-- Name: plantillas_checkout_id_plantilla_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.plantillas_checkout_id_plantilla_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.plantillas_checkout_id_plantilla_seq OWNER TO postgres;

--
-- Name: plantillas_checkout_id_plantilla_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.plantillas_checkout_id_plantilla_seq OWNED BY public.plantillas_checkout.id_plantilla;


--
-- Name: reuniones_previas; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.reuniones_previas OWNER TO postgres;

--
-- Name: reuniones_previas_id_reunion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reuniones_previas_id_reunion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reuniones_previas_id_reunion_seq OWNER TO postgres;

--
-- Name: reuniones_previas_id_reunion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reuniones_previas_id_reunion_seq OWNED BY public.reuniones_previas.id_reunion;


--
-- Name: asistencia_locacion id_asistencia; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asistencia_locacion ALTER COLUMN id_asistencia SET DEFAULT nextval('public.asistencia_locacion_id_asistencia_seq'::regclass);


--
-- Name: checkouts_detalle id_detalle; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkouts_detalle ALTER COLUMN id_detalle SET DEFAULT nextval('public.checkouts_detalle_id_detalle_seq'::regclass);


--
-- Name: checkouts_maestro id_maestro; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkouts_maestro ALTER COLUMN id_maestro SET DEFAULT nextval('public.checkouts_maestro_id_maestro_seq'::regclass);


--
-- Name: eventos id_evento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eventos ALTER COLUMN id_evento SET DEFAULT nextval('public.eventos_id_evento_seq'::regclass);


--
-- Name: informes_gastos_detalle id_detalle; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.informes_gastos_detalle ALTER COLUMN id_detalle SET DEFAULT nextval('public.informes_gastos_detalle_id_detalle_seq'::regclass);


--
-- Name: informes_gastos_maestro id_informe; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.informes_gastos_maestro ALTER COLUMN id_informe SET DEFAULT nextval('public.informes_gastos_maestro_id_informe_seq'::regclass);


--
-- Name: kits_empleados id_kit; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kits_empleados ALTER COLUMN id_kit SET DEFAULT nextval('public.kits_empleados_id_kit_seq'::regclass);


--
-- Name: mantenimiento_equipos id_solicitud; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mantenimiento_equipos ALTER COLUMN id_solicitud SET DEFAULT nextval('public.mantenimiento_equipos_id_solicitud_seq'::regclass);


--
-- Name: plantillas_checkout id_plantilla; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plantillas_checkout ALTER COLUMN id_plantilla SET DEFAULT nextval('public.plantillas_checkout_id_plantilla_seq'::regclass);


--
-- Name: reuniones_previas id_reunion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reuniones_previas ALTER COLUMN id_reunion SET DEFAULT nextval('public.reuniones_previas_id_reunion_seq'::regclass);


--
-- Data for Name: asistencia_locacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.asistencia_locacion (id_asistencia, id_evento, fecha_jornada, num_empleado, nombre_empleado, depto, hora_entrada, t_desayuno, t_comida, t_cena, hora_salida, observaciones, fecha_registro) FROM stdin;
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
13	1	2026-08-16	0	Cuauhtemoc Rivera Agundez	STAFF VPRO	09:00:00	0.00	1.00	0.00	22:00:00	Todo al chngz	2026-08-15 14:59:05.725143
14	1	2026-08-16	0	Edgar Javier Amarillas	STAFF VPRO	09:00:00	0.00	1.00	0.00	22:00:00	Todo al chngz	2026-08-15 14:59:05.725143
15	1	2026-08-16	0	Jose Francisco Torres Sanchez	STAFF VPRO	09:00:00	0.00	1.00	0.00	22:00:00	Todo al chngz	2026-08-15 14:59:05.725143
87	2	2026-08-18	0	Manuel Antonio Madrid Zazueta	STAFF VPRO	00:00:00	0.00	0.00	0.00	00:00:00		2026-08-19 12:00:41.793453
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
\.


--
-- Data for Name: checkouts_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.checkouts_detalle (id_detalle, id_maestro, codigo_equipo, cantidad, observaciones, incidencias, cotejado, notas_regreso) FROM stdin;
1068	15	VPRO_ALT_26591	2		Sin incidencias	t	
1069	15	VPRO_ALT_26607	1		Sin incidencias	t	
1070	15	VPRO_ALT_26673	1		Sin incidencias	t	
1071	15	VPRO_ALT_26703	2		Sin incidencias	t	
1072	15	INV_ALT_1090014	1	[CUST_EQ:Transmisor de audio SONY VPNAUD009] None	Sin incidencias	t	
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
1763	27	INV_ALT_1040004	2	Television 65" Pantalla se dañado	Sin incidencias	t	
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
1764	27	INV_VPRO_ALT_00052	6		Sin incidencias	t	
1765	27	INV_ALT_1040005	2		Sin incidencias	t	
1766	27	INV_ALT_1040006	2		Sin incidencias	t	
1767	27	INV_VPRO_ALT_00175	5		Sin incidencias	t	
1768	27	INV_VPRO_ALT_00065	2		Sin incidencias	t	
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
1769	27	INV_VPRO_ALT_00023	1		Sin incidencias	t	
1774	28	INV_VPRO_ALT_00001	3		Sin incidencias	f	
1770	27	VPRO_ALT_17765	2		Sin incidencias	t	
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
2441	46	INV_ALT_1090031	1		Sin incidencias	t	
2442	46	INV_ALT_1090065	2		Sin incidencias	t	
2443	46	INV_ALT_1090066	1		Sin incidencias	t	
2444	46	VPRO_ALT_26346	4		Sin incidencias	t	
2445	46	INV_ALT_1090038	2		Sin incidencias	t	
2446	46	INV_VPRO_ALT_00151	14		Sin incidencias	t	
2447	46	VPRO_ALT_26418	2		Sin incidencias	t	
2448	46	VPRO_ALT_26433	2		Sin incidencias	t	
2449	46	VPRO_ALT_26379	1		Sin incidencias	t	
2450	46	VPRO_ALT_26591	2		Sin incidencias	t	
1823	26	INV_VPRO_ALT_00012	1	⚠️ [LLEVA DAÑO REPORTADO]	Sin incidencias	f	
1799	32	INV_VPRO_ALT_00181	1		Sin incidencias	t	
1800	32	INV_ALT_2020021	1		Sin incidencias	t	
1801	32	INV_ALT_2010006	1		Sin incidencias	t	
1802	32	INV_VPRO_ALT_00093	1		Sin incidencias	t	
1803	32	INV_ALT_2020003	1		Sin incidencias	t	
1804	32	INV_VPRO_ALT_00139	3		Sin incidencias	t	
1805	32	INV_VPRO_ALT_00021	1		Sin incidencias	t	
1806	32	INV_ALT_2010004	1		Sin incidencias	t	
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
2451	46	VPRO_ALT_26607	1		Sin incidencias	t	
2452	46	INV_ALT_1090067	1		Sin incidencias	t	
2453	46	INV_VPRO_ALT_00231	13		Sin incidencias	t	
2454	46	INV_ALT_1090068	5		Sin incidencias	t	
2455	46	INV_ALT_1090069	1		Sin incidencias	t	
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
2428	45	INV_VPRO_ALT_00151	6		Sin incidencias	f	
2429	45	INV_VPRO_ALT_00175	8		Sin incidencias	f	
2430	45	INV_VPRO_ALT_00231	1		Sin incidencias	f	
2431	45	INV_ALT_1040014	1		Sin incidencias	f	
2432	45	INV_ALT_1040015	1		Sin incidencias	f	
2433	45	VPRO_ALT_17836	2		Sin incidencias	f	
2434	45	INV_VPRO_ALT_00220	2		Sin incidencias	f	
2435	45	VPRO_ALT_17765	2		Sin incidencias	f	
2436	45	INV_VPRO_ALT_00023	6		Sin incidencias	f	
2437	45	INV_ALT_1040016	1		Sin incidencias	f	
2438	45	VPRO_ALT_74716	1		Sin incidencias	f	
2439	45	INV_ALT_1040017	1		Sin incidencias	f	
2440	45	INV_ALT_1040018	1		Sin incidencias	f	
\.


--
-- Data for Name: checkouts_maestro; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.checkouts_maestro (id_maestro, folio_op, id_empleado, fecha, hora, incidencias_generales, estado_bodega, nombre_kit) FROM stdin;
1	1	201	2026-08-13	13:44:28.509346-06	[PROVEEDOR_INCIDENTE: ELEVOX | NOTA: al inicio de la transmision se escuchaba doble como eco]	RECIBIDO	KIT_STD_EVENTOS_FUERA_DE_OFICINAS
20	9	119	2026-09-01	18:10:58.339591-06	Sin incidencias	RECIBIDO	KIT TEBACAS
19	9	202	2026-09-02	10:08:55.406408-06	Sin incidencias	RECIBIDO	TEBACAS
3	2	119	2026-08-28	10:07:29.611383-06	Las tarimas para camaras muy sencibles a cualquier movimiento.\nBatalle mucho el primer dia para mantener al centro de la toma al seguir a los expositores.	RECIBIDO	KIT 3 CAMARAS OK
4	2	202	2026-08-28	10:08:43.241762-06	Sin incidencias en zoom y transmisión.\nEs necesario adquirir un cable de 50mts (otro) para starlink.\nFalló el apuntador, hay que buscar uno que sea bluetooth o de mayor alcance	RECIBIDO	CESAVESIN en Mazatlán
5	2	104	2026-08-28	10:09:23.018554-06	Sin incidencias	RECIBIDO	Cesavesin Mazatlan Simposium
9	6	201	2026-08-22	12:57:41.209153-06	Hubo problemas con el internet minutos antes de comenzar y aunque habia personal de gobno apoyando, no se soluciono y el evento se cancelo al llegar RRM	RECIBIDO	Kit_p_enlace_webex
6	2	109	2026-08-28	10:10:16.942722-06	Dia 1 (jueves)\n1.Al entrar el segundo segmento, entramos sin audio pues no se estaba monitoreando\n2.Dos botonazos\nDia 2 (viernes)\n1.Tres botonazos\nDia 3 (sábado)\n1.Cuatro botonazos	RECIBIDO	KIT CESAVESIN
27	14	104	2026-09-21	11:11:57.386891-06	Television de 65" Pantalla dañada	RECIBIDO	Reunion de gabinete
8	6	113	2026-08-28	10:13:36.705363-06	A la hora de colocar el tripie para la camara se le cayo una pieza y se tuvo que ajustar con cinta gris.	RECIBIDO	Enlace Presidenta
29	15	113	2026-09-08	10:15:50.445222-06	Sin incidencias	RECIBIDO	JAPAC
7	4	201	2026-08-28	10:15:13.560463-06	Sin incidencias	RECIBIDO	Jornadas de paz
12	2	105	2026-08-25	19:24:06.359063-06	SIN INCIDENCIAS	PENDIENTE	--- Sin plantilla ---
26	11	201	2026-09-09	17:48:04.151596-06	Dia1.- En plena transmision llovió y se cortó el envío (srt) al Estudio, caso raro: Los equipos no se apagaron en el estudio, pero las páginas a las cuales se estaba transmitiendo se cortaron... No se apagó el modem ni la señal cambió de color(de rojo a naranja), pero en la transmisión de Fbook y Youtube hubo corte.\nDia3.- corté en la transmisión… Es muy probable que haya infuído el que le pasaron a Carlos en plena transmisión a los patrocinadores y al bajarlos en la pc del estudio haya provocado el corte(aparecieron 2 transmisiones en YTube), OJO: No es la primera vez que pasa eso en algún evento… pienso que se debió entregar esa información antes y así minimizar el riesgo.	PENDIENTE	Juegos Tebacas
23	11	202	2026-09-08	11:26:20.420443-06	- El día de juego 01 (04 de sept), hubo una fuerte lluvia y se cayó el servicio de internet starlink, a regañadientes nos prestaron el servicio de internet que tienen patrocinado a la arena Badiraguato, logrando salir con una cámara y el scoreboard. Ya que regresó el servicio de starlink, cambiamos a starlink y terminamos el juego con nuestro servicio de internet.\nHubo perdida de cuadros y audio en srt, debido a que estaban modificando el proyecto de vmix.\n- El día de juego 02 (05 de sept), Tratando de quitarle trabajo a la pc de deportes (estudio) se cambió para que solo enviara un srt a un equipo en el depto de sistemas (no fue la solución), tuvimos servicio starlink durante todo el partido. Se solicitó bajaran el volumen de audio en la transmisión ya que se escuchaba saturado (se solucionó).\n- El día de juego 03 (06 de sept), Debido a que el cliente solicitó se metieran patrocinios volvió a tener perdida de cuadros y audio el srt, ya que se tuvieron que hacer modificaciones en el proyecto usando gt, nadie estuvo monitoreando la transmisión de youtube, la cual tuvo una desconexión y se generó otro link. \n- Tuvimos problemas con los audios de los conductores, subía y bajaba el audio, en ocasiones entraba el audio cuando ya estaba hablando el conductor (no subía a tiempo el volumen)\n- El presidente de Badiraguato se comprometió a que usemos su internet cómo secundario.	RECIBIDO	TEBACAS
22	12	201	2026-09-03	17:44:07.840474-06	Sin incidencias	RECIBIDO	Jornadas de paz basico
10	5	201	2026-08-28	10:15:40.642562-06	Al llegar al evento Se me reportó que falló servicio de internet, pero no podia saberlo hasta que llegara ya que me encontraba en el evento del enlace en gobno del edo.	RECIBIDO	Jornadas de paz basico
16	8	105	2026-08-28	13:18:51.072556-06	Sin incidencias	RECIBIDO	KIT LEY GRABACION
17	8	113	2026-08-28	13:21:49.23292-06	Sin incidencias	RECIBIDO	Grabacion LEY
14	8	104	2026-08-28	13:22:58.819901-06	Sin incidencias	RECIBIDO	--- Sin plantilla ---
15	8	109	2026-08-28	13:26:48.387898-06	Sin incidencias	RECIBIDO	KIT CESAVESIN
13	8	119	2026-08-28	13:29:12.266136-06	Sin incidencias	RECIBIDO	KIT BASICO 3 CAMARAS
18	7	109	2026-08-28	14:42:30.494302-06	Sin incidencias	RECIBIDO	IEES VIRTUAL (Estudio VPro)
2	3	201	2026-08-19	18:00:49.517081-06	Sin incidencias	RECIBIDO	Jornadas de paz
30	11	104	2026-09-08	17:46:36.754479-06	Dia Uno, Incidencia se fue la Luz, Se fue Internet y de todo un Poco.\nDia Dos, Sin Incidencia\nDia Tres, Incidencia se Escucha la Musica de la Computadora de Fondo no se encontro como quitarla.	PENDIENTE	--- Sin plantilla ---
11	7	202	2026-08-27	18:07:40.145083-06	Sin incidencias	RECIBIDO	IEES en estudio de Vpro
21	10	201	2026-09-08	18:41:29.227475-06	Sin incidencias	RECIBIDO	Jornadas de paz basico
31	14	105	2026-09-09	10:47:34.410728-06	TV DAÑADA 65	PENDIENTE	--- Sin plantilla ---
28	15	105	2026-09-09	10:50:00.260882-06	Sin incidencias	RECIBIDO	JAPAC
34	11	113	2026-09-09	18:52:56.381247-06	En el juego del primer día hubo un error con el tamaño de los lowers que tapaban los nombres que se le ponían, también en en el juego dos hubo un error en meter el nombre del jugador de tebanas cuando estaba Miguel (conductor) al aire y también se cometió el error ortográfico de no colocar mayusculas sobre el lower del himno nacional.	PENDIENTE	--- Sin plantilla ---
33	17	201	2026-09-10	17:28:19.010231-06	Sin incidencias	RECIBIDO	Jornadas de paz
32	16	201	2026-09-09	17:46:33.38303-06	Sin incidencias	RECIBIDO	Jornadas de paz
24	13	201	2026-09-04	18:28:04.210289-06	Sin incidencias	RECIBIDO	Jornadas de paz basico
25	11	119	2026-09-09	18:58:27.970314-06	DIA 1 JUEGO TEBACAS VS FOHR DE HERMOSILLO\nLA SEÑAL DE SRT QUE ESTABA AL AIRE SE ESTABA DROPEANDO CUANDO MANIPULABAN LA COMPUTADORA EN ESTUIO\nEN LA COMINICACION DE CAMAROGRAFOS, SE ESCUCHABA MAS FUERTE EL CONDUCTOR QUE ESTABA EN ARENA QUE EL SWITCHER EN ESTUDIO\nPEGO UN LLOVIDON, SE FUERON LAS DOS ESTARLINK, SE NOS CORTO LA TRANMISION, ESTO PASO CASI AL FINALIZAR EL SEGUNDO CUARTO, REGRESAMOS CASI AL FINAL DE EL TERCER CUARTO\nSE CONSIGUIO EL INTERNET DE EL RECINTO, SE TIRO UN CABLE, PARA PODER SACAR LA TRANSMISION., NO QUERIAN FUNCIONAR LOS 4 ENCODERS, NOS FUIMOS CON DOS, CAMARA 1 Y LA DEL OCR\nEN ESTUDIO SE METIO UN LOOP, NUNCA METIERON AL CONDUCTOR A CUADRO.\nAL FINALIZAR EL 3ER CUARTO REGRESO UNA STARLINK, SE HIZO EL CAMBIO Y CON ESA SALIMOS.\nAL FINALIZAR EL CUARTO CUARTO, SE FUE LA LUZ EN ESTUDIO,  REGRESAMOS CON LA ENTREVISTA DEL PRESIDENTE JOSE PAZ\nCONDUCTOR NO TENIA COMUNICACION CON ESTUDIO\nAL ESTAR AL AIRE CON LA ENTREVISTA, MARTHA ROQUE DE COMUNICACION, ME DECIA QUE NO ESTABAMOS AL AIRE, SE PIDIO EVIDENCIA A ESTUDIO, PARA COMPROBARLE QUE SI ESTABMOS AL AIRE.\nPRIMER ZOOM QUE HICE AL PRESIDENTE, ESTABA FUERA DE FOCO.\nCUANDO MIGUEL EL CONDUCTOR EMPEZO A HABLAR, LE PUSIERON EL SUPER DE EL PRESIDENTE.\nEL JUEGO QUEDO EN DOS PARTES EN YOUTUBE.\nHI SPORTS CORTO SU TRANSMISION, TVP REGRESO CON LA TRANSMISION\nGRACIAS A DIOS, SACAMOS EL JUEGO, SALIO LA ENTREVISTA.\nCONSEGUIMOS CUARTOS PARA LA PRODUCCION PARA DORMIR, ESTABAN EN MUY MALAS CONDICIONES Y SIN AIRE ACONDICIONADO\nTRATAMOS DE COMUNICAR CON EL ENCARGADO DE PROYECTOS ESTRATEGICOS DE BADIRAGUATO PARA VER LO DE EL INTERNET, NO SE LOCALIZO\nEL PRESIDENTE JOSE PAZ, PIDIO QUE SE QUEDARA EL CONDUCTOR UN DIA MAS., SE PIDIO LA AUTORIZACION Y SE ACEPTO\nGRABACION DEL PRIMER DIA EN IMPERDEC, SE GRABO SIN AUDIO AL PRINCIPIO.\n\nDIA 2: TEBACAS VS CORAS DE XALISCO\nENTRADA 3PLAY SATURADA\nENTRADA SE VA ANEGROS ANTES DE DRON( YA SE CHECO CON ENGARGADO)\nENTRO SATURADO AUDIO DE CONDUCTOR EN ESTUDIO\nNO ES CORRECTO COMO ESTAN PONIENDO LOS SUPERS A LOS INVITADOS\n\nDIA 3 TEBACAS VS AGAVEROS DE TEQUILA\nSATURADO AUDIO DE ENESTO, MIGUEL BAJO EL AUDIO\nMUUY INDESISOS CONDUCTORES, PARA MANDAR EL HIMNO, QUE SI, QUE NO\nAL INICIO D EL JUEGO, CAMAROGRAFO CAMARA UNO, ESTABA DESUBICADO\nSE METIO A LA TRASMISION AUDIO DE MIGUEL, ASIENDO PRUEBAS\nDESPUES ENTRO AUDIO DE MIGUEL TRONADO\nSIGUIO FALLANDO LA COMPUTADOORA DE TRANSMISION AL MANIPULAR. (GT)\nEL PRESIDENTE JOSE PAZ, ME ABORDO QUE QUERIA QUE ENTRARAN LOS PATROCINADORES DE TEBACAS, QUE TENIAN QUE ENTRAR EN ESTE JUEGO, SI SI O SI.\nNOS APOYO LUPITA DE PRESIDENCIA, Y SE PUDIERON METER LOS PATROCINADORES APARTIR DE EL TERCER CUARTO, GRACIAS TAMBIEN A LA GENTE EN ESTUDIO\nSE CORTO LA TRANSMISION EN ESTUDIO\nEL JUEGO QUEDO EN DOS PARTES EN YOUTUBE\n\nSE FUE EL AUDIO DE CONDUCTOR EN ESTUDIO, ENTRO A NARRAR CONDUCTOR EN ARENA. (SE PENSO QUE ERAN BATERIAS, PERO NO)\nALGUNOS DETALLES DE ORTOGRAFIA (YA SE HABLO CON LA PERSONA ENCARGADA)	RECIBIDO	KIT TEBACAS
35	18	201	2026-09-11	19:32:51.481852-06	Sin incidencias	RECIBIDO	Jornadas de paz
36	11	109	2026-09-12	11:24:38.60104-06	Dia 1\n*4 Botonazos\n*Detalles de audio\n*Falla de internet durante aprox un cuarto y medio del juego\n\nDia 2 \n*Detalles de audio\n\nDia 3\n\n*4 Botonazos\n*Al empezar se fue un micro, despues de buscar todas las opciones era problema de volúmen, algunos otros detalles más en el audio (en un corte no entro el audio etc)\n*Hubo fallas intermitentes en el Internet, muy leves para cortar la transmisión pero si se notó con imagen "rayada"\n*Hubo un camarazo (cam 3) y en una ocación se perdió la cámara (cam 1)	PENDIENTE	--- Sin plantilla ---
38	19	202	2026-09-17	14:25:03.453272-06	- Fallo en la planta de energía de un tercero, provocó variaciones en voltaje, lo cual provocó que el no-break tuviera poca carga.\n- Al cambiar de planta (y debido a la carga de consumo del no-break) se apagaron los equipos conectados al no-break, lo cual ocasionó daño en el archivo (grabación) en el vmix y en el 3play.	RECIBIDO	Grito de independencia 2026
40	19	201	2026-09-17	15:10:35.123605-06	Tuvimos variaciones en la corriente por parte de la planta de energia... Debido a fallas en el suministro de la planta de energia, en un espacio de la cantante se hizo el cambio de planta lo cual provocó que se apagara todo el equipo de produccion ya que fué demasiado el consumo para la capacidad del UPS: NOTA: Ese mismo dia se nos solicitó un servicio via zoom: gobernadora - Canal 11. como a las 13:00 hrs.	RECIBIDO	Kit_grito
42	19	105	2026-09-17	18:11:45.925195-06	-PROBLEMAS EN LA COMUNICACION (SE CORTABA) \n-APAGON DE PLANTA	RECIBIDO	Grito de independecia
37	19	119	2026-09-17	18:54:56.975885-06	LA COMUNICACION PARA CAMAROGRAFOS MUY MALA, SE CORTO TODO EL TIEMPO.\nTARIMAS MUCHO MEJOR QUE EN OTRAS OCACIONES, PERO SI SE OCUPAN DOS POR CAMARA. (MAS PARA ESTE TIPO DE EVENTOS)\nFALLARON CABLES SDI DE CAMARAS	RECIBIDO	DIA DEL GRITO
43	15	102	2026-09-18	13:13:14.148566-06	Sin incidencias	PENDIENTE	--- Sin plantilla ---
44	8	102	2026-09-18	13:16:07.653014-06	Sin incidencias	PENDIENTE	--- Sin plantilla ---
45	20	104	2026-09-21	11:10:17.58972-06	Sin incidencias	DESPACHADO	Evento presidenta
46	20	109	2026-09-21	11:17:53.489123-06	Sin incidencias	RECIBIDO	Evento Presidenta
39	19	104	2026-09-17	12:49:27.589433-06	Sin incidencias	RECIBIDO	Dia del grito
41	19	109	2026-09-17	13:23:15.297602-06	Sin incidencias	RECIBIDO	Grito de la independencia
\.


--
-- Data for Name: eventos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.eventos (id_evento, folio, fec_de_elaboracion_de_op, empleado_que_creo_la_op, para_q_cliente, fec_de_instalacion, nombre_evento, hra_de_instalacion, locacion, fec_del_evento, inicio_del_evento, quien_solicita, hra_de_llamado, ubicacion, resp_de_produccion, tipo_de_servicio, produccion, internet_redes, actividades_de_proveedores, nota, elabora, organiza, coordina, vobo, proveedor_op, personal_convocado_op, carros_usados_op, externos_op, estatus, reuniones_vinculadas) FROM stdin;
3	3	2026-08-19	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-08-19	Jornadas de Paz (dia 1)	09:00:00	Costa rica, Sinaloa	2026-08-19	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:00:00	Costa rica, Sinaloa	Cuauhtemoc Rivera Agundez	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		PRODUCCIÓN:\t\t\nProveeduría de internet a 10 módulos\t\t\n2 antenas Starlink\t\t\nDistribución de linas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida04 - Nissan #04 2013"}	{}	ACTIVA	\N
1	1	2026-08-13	Cuauhtemoc Rivera Agundez	GOBIERNO DEL ESTADO DE SINALOA	2026-08-13	INFORME DE RENDICION DE CUENTAS PRESIDENCIAL	18:00:00	EXPLANADA DE PALACIO DE GOBIERNO	2026-08-14	11:00:00	Giras Gobno del edo.	06:00:00	EXPLANADA DE PALACIO DE GOBIERNO	Cuauhtemoc Rivera Agundez	Produccion a 3 cmaras con streaming a plataformas oficiales	LLeven agua suficiente y checar que las pantallas de 3mm no se apaguen a cada rato	Revisar la calidad, debe de ser a 1080 minimo	Instalar 2 pantallas de 4x6 de 3mm	Reportar cualquier anomalia	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{ELEVOX,SERVIPLUS-KUWA}	{"Cuauhtemoc Rivera Agundez","Edgar Javier Amarillas","Jose Francisco Torres Sanchez"}	{"VPFord - Ford 1996","VPTiida02 - Nissan #02 2013"}	{}	ACTIVO	\N
4	4	2026-08-19	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-08-20	Jornadas de paz (dia 2)	09:00:00	Costa rica, Sinaloa	2026-08-20	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:30:00	Costa rica, Sinaloa	Cuauhtemoc Rivera Agundez	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antena Starlink\t\t\nDistribución de linas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida04 - Nissan #04 2013"}	{}	ACTIVA	\N
5	5	2026-08-20	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-08-21	Jornadas de paz (dia 3)	10:30:00	Costa Rica, Sinaloa	2026-08-21	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	10:00:00	Costa Rica, Sinaloa	Cuauhtemoc Rivera Agundez	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antena Starlink\t\t\nDistribución de linas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida04 - Nissan #04 2013"}	{}	ACTIVA	\N
6	6	2026-08-22	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-08-21	ENLACE PRESIDENCIAL	06:00:00	DESPACHO DE GOBERNADOR	2026-08-21	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo) EDWIN	05:30:00	DESPACHO DE GOBERNADOR	Cuauhtemoc Rivera Agundez	Streaming a 3 cámaras, monitores de Tv.	PRODUCCIÓN:\t\tEntrada 5:30am inicia 10:00am\t\t\nStreaming\t\t\t\t\n1  cámaras c/operador\t\t\t\t\nSwitcher\t\t\t\t\nConsola de audio para transmision\t\t\t\t\nKit de refuerzo de iluminacion\t\t\t\t\n1 monitor de 50" en tripie			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez","Carlos Jacobo Quezada Mendoza"}	{}	{}	ACTIVA	\N
7	7	2026-08-25	Manuel Eduardo Madrid	IEES	2026-08-24	Sesion virtual IEES	10:00:00	Estudio VPRO	2026-08-25	12:00:00	MELISSA-IEES	09:00:00	Estudio VPRO	Martin Eduardo Sanchez Estrada	Transmisión vía ZOOM de reunión extraordinaria y Especial		PRODUCCION:\tINCIA 12:00PM\t\t\t\nTransmision vía ZOOM\t\t\t\t\nStreaming\t\t\t\t\t\t\t\t\n\t\t\t\t\t\t\t\t\n2DA.SESION ESPECIAL EN ESTUDIO (inicia al término de la extraordinaria)		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas","Osiel Cuauhtemoc Hernandez Aldape"}	{}	{}	ACTIVA	\N
2	2	2026-08-24	Manuel Eduardo Madrid	CESAVESIN	2026-08-17	SIMPOSIO INTERNACIONAL CONISIAPA 2026	10:00:00	Hotel el cid castilla	2026-08-20	11:00:00	Lic. Clarissa Burgeño	06:00:00	Hotel el cid castilla, Mazatlán	Martin Eduardo Sanchez Estrada	Integración de Evento: Stand, coolers, iluminacion, audio, escenografia y producción visual.	VPRO: \t\t\t\t\nCircuito cerrado a 3 cámaras\t\t\t\t\nGrabación de capacitaciones\t\t\t\t\nSistema Digital Sing para pantalla de Coffe lounge\t\t\t\t\nGrabación de video memoria de evento\t\t\t\t\nProduccion de 3 videos memoria  (Hortalizas, Acuícola y Reunión de inocuidad)		KUWA:\t\t\t\tGPO.EVENT. PACIFIC\nEscenografía de 22.50xx 4.88m \t\t\t\tPodium con TV incrustada\nAudio capacidad 1200 personas\t\t\t\tVIRA:\niluminacion arquitectónica\t\t\t\t2 Monitores 55" a piso\n2 pantallas led de 5x3m a laterales de escenografia \t\t\t\t\nAREA LAYOUT SECCION "C" SALON EL CID (Casas comerciales-exhibicion)\t\t\t\t\nKUWA:\t\t\t\t\n1 Pantalla led 3.5x2m en estructura \t\t\t\t\niluminacion arquitectónica\t\t\t\t\nSistema de audio y microfono para INAUGURACION EN ENTRADA	NOTA: EN CASO DE QUE NO QUIERAN STAN LOS EXHIBIDORES, SOLO SE REGISTRA EL MARCAJE Y SUMINISTRO DE LUZ PARA SU COBRO.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{SERVIPLUS-KUWA}	{"Martin Eduardo Sanchez Estrada","Edgar Javier Amarillas","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez","Manuel Antonio Madrid Zazueta","Osiel Cuauhtemoc Hernandez Aldape","Gerardo Villarreal Uribe"}	{"VPH100 - Hyundai 2015"}	{}	ACTIVA	\N
8	8	2026-08-27	Manuel Eduardo Madrid	Casa ley	2026-08-28	COBERTURA DE 72 ANIVERSARIO LEY	07:45:00	EN PLAZA LEY SUC. (Área de Capacitación y Desarrollo)	2026-08-28	09:00:00	MANUEL CAMACHO ZAZUETA	06:00:00	EN PLAZA LEY SUC. (Área de Capacitación y Desarrollo)	Martin Eduardo Sanchez Estrada	Circuito a 3 cámaras y edición de video COLOR.	Circuito a 3 cámaras\t\tCon playera blanca los camarografos\t\t\nSwitcher\t\t\t\t\nVmix\t\t\t\t\n2 Tarimas para camarógrafos\t\t\t\t\n\t\t\t\t\n\t\t\t\t\n\t\t\t\t\nVIDEO COLOR\t\t\t\t\nVideo color de evento carlos\t\t\t\t\nGrabación a 2 cámras\t\t\t\t\nEdición y musicalización\t\t\t\t\nGráficos\t\t\t\t\nEntrega de master Full HD\t\t\t\t\nEdición máxima 1 min en vertical y horizontal			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Martin Eduardo Sanchez Estrada","Osiel Cuauhtemoc Hernandez Aldape","Manuel Antonio Madrid Zazueta","Carlos Jacobo Quezada Mendoza","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez","Gerardo Villarreal Uribe"}	{"VPTiida02 - Nissan #02 2013","VPFord - Ford 1996"}	{}	ACTIVA	\N
9	9	2026-08-31	Manuel Eduardo Madrid	H.AYUNTAMIENTO DE BADIRAGUATO	2026-09-01	SCOUTING "TEBACAS"	13:00:00	Badiraguato, Sinaloa	2026-09-01	13:00:00	H.AYUNTAMIENTO DE BADIRAGUATO	09:00:00	Badiraguato, Sinaloa	Manuel Antonio Madrid Zazueta	Pruebas de proveeduría de internet y transmisión				Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Manuel Antonio Madrid Zazueta","Edgar Javier Amarillas","Gerardo Villarreal Uribe"}	{"VPH100 - Hyundai 2015"}	{"eduardo el condor"}	ACTIVA	\N
10	10	2026-09-02	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-02	Jornada de paz (dia 1)	08:30:00	Loma de rodriguera	2026-09-02	09:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:00:00	Loma de rodriguera	Cuauhtemoc Rivera Agundez	Proveeduría de internet a módulos con Satarlink y distribución de líneas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antenas Starlink\t\t\nDistribución de linas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida04 - Nissan #04 2013"}	{}	ACTIVA	{}
12	12	2026-09-02	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-03	Jornada de paz (dia 2)	09:00:00	LOMA DE RODRIGUERA	2026-09-03	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:30:00	LOMA DE RODRIGUERA	Cuauhtemoc Rivera Agundez	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antenas Starlink\t\t\nDistribución de linas de internet red			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida04 - Nissan #04 2013"}	{}	ACTIVA	{}
13	13	2026-09-03	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-04	Jornada de la paz (dia 3)	09:00:00	LOMA DE RODRIGUERA	2026-09-04	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:30:00	LOMA DE RODRIGUERA	Cuauhtemoc Rivera Agundez	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antenas Starlink\t\t\nDistribución de linas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida04 - Nissan #04 2013"}	{}	ACTIVA	{}
17	17	2026-09-10	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-10	Jornada de paz (Dia 2)	09:30:00	Villa Juárez	2026-09-10	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	09:00:00	Villa Juárez	Martin Eduardo Sanchez Estrada	Proveeduría de internet a módulos con Satarlink y distribución de líneas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antenas Starlink\t\t\nDistribución de líneas de internet red			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida02 - Nissan #02 2013"}	{}	ACTIVA	{}
14	14	2026-09-08	Cuauhtemoc Rivera Agundez	GOBIERNO DEL ESTADO DE SINALOA	2026-09-06	Reunión de gabinete	08:00:00	Salón gobernadores	2026-09-06	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	06:00:00	Salón gobernadores	Jose Francisco Torres Sanchez	MONITORES A PISO	2 monitores de 65" a piso			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez"}	{"VPFord - Ford 1996"}	{}	ACTIVA	{}
16	16	2026-09-09	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-09	Jornada de paz (Dia 1)	09:30:00	Villa Juárez	2026-09-09	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	09:00:00	Villa Juárez	Martin Eduardo Sanchez Estrada	Proveeduría de internet a módulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antenas Starlink\t\t\nDistribución de lineas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida02 - Nissan #02 2013"}	{}	ACTIVA	{}
15	15	2026-09-12	Manuel Eduardo Madrid	JAPAC	2026-09-07	Grabaciones	09:30:00	Spot para "NUEVA SUCURSAL"	2026-09-07	10:00:00	DEPTO. COMUNICACIÓN	09:00:00	Spot para "NUEVA SUCURSAL"	Gerardo Villarreal Uribe					Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Gerardo Villarreal Uribe","Jose Daniel Torres Arroyo","Carlos Jacobo Quezada Mendoza"}	{"VPTiida02 - Nissan #02 2013"}	{}	ACTIVA	{"2026-08-31 | H.ayuntamiento Badiragutao - Reunión para el arranque de los partidos de TEBACAS","2026-08-26 | VPRO - Prueba para ISO"}
11	11	2026-09-12	Manuel Eduardo Madrid	H.AYUNTAMIENTO DE BADIRAGUATO	2026-09-04	LIGA DE BALONCESTO DEL PACIFICO 2026 (TEBACAS)	12:00:00	Arena de Badiraguato	2026-09-04	22:00:00	Lic. Martha Lilia Roque (área de comiunicación)	09:00:00	Arena de Badiraguato	Manuel Antonio Madrid Zazueta	Producción vía remota desde estudio y transmisión de partidos de tebacas en Badiraguato.	Switcher\t\t\t\t\nAudio\t\t\t\t\nGráficos y marcador (OCR)\t\t\t\t\nRedes\t\t\t\t\nEXTERNOS:\t\t\t\t\nRepeticiones\t\tNOTA: El 04 de Sept. 1 comentarista se va a Badiraguato acubrir la inauguración y se retorna al día siguiente para continuar en estudio.)\t\t\nComentarista #1\t\t\t\t\nComentarista #2\t\t\t\t\n\t\t\t\t\nEN CANCHA:\t\t\t\t\nProductor Deporte\t\t\t\t\n2 cámaras fijas (sin camarógrafo) para seguimiento y repeticiones	1 Antena Starlink\t\t\n4 Encoder E3 para transmisión SRT	EXTERNO:\t\t\nCamarógrafo #1 (central de seguimiento)	Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas","Carlos Jacobo Quezada Mendoza","Cuauhtemoc Rivera Agundez","Jose Francisco Torres Sanchez","Osiel Cuauhtemoc Hernandez Aldape","Manuel Antonio Madrid Zazueta"}	{}	{"eduardo el condor"}	CERRADA (HISTÓRICO)	{"2026-09-08 | H.ayuntamiento Badiraguato - Reunión para dar seguimiento a las incidencias de los eventos de liga de baloncesto del pacifico “TEBACAS”","2026-08-31 | H.ayuntamiento Badiragutao - Reunión para el arranque de los partidos de TEBACAS","2026-08-17 | H.ayuntamiento Badiraguato - Reunión para partidos de basquetbol de TEBACAS","2026-08-13 | H.ayuntamiento Badiraguato - Reunión para eventos basquetbol de TEBACAS."}
20	20	2026-09-21	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-20	VISITA PRESIDENCIAL INFORME : Honestidad y resultados	09:30:00	Feria Ganadera	2026-09-20	13:30:00	DES.TECNOLOGICO  (Giras-Edwin)	09:00:00	Feria Ganadera	Martin Eduardo Sanchez Estrada	MONITORES Y SWITCHER	2 monitores de 65" en base elevada\t\t\n1 switcher\t\t\ndistribucion de señal			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jose Francisco Torres Sanchez","Osiel Cuauhtemoc Hernandez Aldape"}	{"VPH100 - Hyundai 2015"}	{}	ACTIVA	{}
18	18	2026-09-10	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-11	Jornada de paz (Dia 3)	09:30:00	Villa Juárez	2026-09-11	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	09:00:00	Villa Juárez	Martin Eduardo Sanchez Estrada	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n1 antenas Starlink\t\t\nDistribución de lineas de internet red			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"VPTiida02 - Nissan #02 2013"}	{}	CERRADA (HISTÓRICO)	{}
19	19	2026-09-17	Manuel Eduardo Madrid	GOBIERNO DEL ESTADO DE SINALOA	2026-09-14	Grito de la independencia	09:30:00	Palacio de gobierno	2026-09-15	17:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	11:00:00	Palacio de gobierno	Martin Eduardo Sanchez Estrada		Circuito a 7 cámaras\t\t\nSistema de transmision inalámbrica\t\t\nPlanta generadora de luz\t\t\t\nVuelo de Dron\t\t\nPisacables\t\t\n2 switcherTripaly para grabación\t\t\ngráficos	Distribución de lineas de internet red\nProveeduria de internet\t\nAntenas starlink	KUWA:\t\nConsola de Audio Yamaha\t\nCentro de carga\t\nSet de Cableado y extensiones	Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Martin Eduardo Sanchez Estrada","Manuel Antonio Madrid Zazueta","Osiel Cuauhtemoc Hernandez Aldape","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez","Cuauhtemoc Rivera Agundez","Carlos Jacobo Quezada Mendoza","Edgar Javier Amarillas"}	{"VPTiida02 - Nissan #02 2013","VPFord - Ford 1996","VPMercedes - Mercedes Benz 2022"}	{"Calixto Villa","eduardo el condor"}	CERRADA (HISTÓRICO)	{"2026-09-12 | Gobierno del estado de sinaloa - Instalación el 14 de septiembre para el grito de la independencia","2026-09-10 | Gobierno del estado de sinaloa - Reunión para evento del grito de la independencia","2026-09-17 | Gobierno del estado de sinaloa - Incidencias del evento grito de independencia"}
\.


--
-- Data for Name: informes_gastos_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
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
\.


--
-- Data for Name: informes_gastos_maestro; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.informes_gastos_maestro (id_informe, folio_vpro, id_empleado, periodo_desde, periodo_hasta, vehiculo, km_inicial, km_final, departamento, num_personas, subtotal, monto_entregado, restante, fecha_registro, hora_registro, revisado) FROM stdin;
1	1	201	2026-08-13	2026-08-13	VPFORD - FORD 1996 (1-50), VPTIIDA02 - NISSAN #02 2013 (2-52)	3	102	SISTEMAS	3	232.00	500.00	268.00	2026-08-13	13:58:08.564469	f
2	3	201	2026-08-19	2026-08-19	VPTIIDA04 - NISSAN #04 2013 (152738-152823)	152738	152823	SISTEMAS	1	130.00	500.00	370.00	2026-08-19	18:08:21.591692	f
3	4	201	2026-08-20	2026-08-20	VPTIIDA04 - NISSAN #04 2013 (152823-152823)	152823	152823	SISTEMAS	1	130.00	0.00	-130.00	2026-08-20	18:14:15.802112	f
4	5	201	2026-08-21	2026-08-24	VPTIIDA04 - NISSAN #04 2013 (152905-152988)	152905	152988	SISTEMAS	1	0.00	0.00	0.00	2026-08-24	11:32:12.26162	f
5	6	201	2026-08-21	2026-08-24	GENERAL (0-0)	0	0	SISTEMAS	2	0.00	0.00	0.00	2026-08-24	11:33:04.970944	f
6	2	107	2026-08-17	2026-08-24	VPH100 - HYUNDAI 2015 (0-0)	0	0	PRODUCCION	7	12959.50	14000.00	1040.50	2026-08-24	17:44:46.156212	f
7	12	201	2026-09-03	2026-09-03	VPTIIDA04 - NISSAN #04 2013 (152988-152988)	152988	152988	SISTEMAS	1	0.00	0.00	0.00	2026-09-03	18:04:05.032205	t
8	13	201	2026-09-04	2026-09-08	VPTIIDA04 - NISSAN #04 2013 (152988-152988)	152988	152988	SISTEMAS	1	0.00	0.00	0.00	2026-09-08	18:39:31.628321	f
9	9	201	2026-09-01	2026-09-08	VPH100 - HYUNDAI 2015 (0-0)	0	0	SISTEMAS	3	0.00	0.00	0.00	2026-09-08	18:40:07.433828	f
11	10	201	2026-09-02	2026-09-08	VPTIIDA04 - NISSAN #04 2013 (152988-152988)	152988	152988	SISTEMAS	1	0.00	0.00	0.00	2026-09-08	18:41:42.124758	f
14	16	201	2026-09-09	2026-09-10	VPTIIDA02 - NISSAN #02 2013 (102-102)	102	102	SISTEMAS	1	0.00	0.00	0.00	2026-09-10	17:54:12.304785	t
13	17	201	2026-09-10	2026-09-10	VPTIIDA02 - NISSAN #02 2013 (102-102)	102	102	SISTEMAS	1	0.00	0.00	0.00	2026-09-10	17:28:43.589218	t
15	18	201	2026-09-11	2026-09-11	VPTIIDA02 - NISSAN #02 2013 (102-102)	102	102	SISTEMAS	1	0.00	0.00	0.00	2026-09-11	19:33:24.120755	t
12	11	119	2026-09-04	2026-09-09	GENERAL (0-0)	0	0	PRODUCCION	6	12273.29	12500.00	226.71	2026-09-09	19:33:41.424339	t
16	19	107	2026-09-14	2026-09-17	VPTIIDA02 - NISSAN #02 2013 (102-102), VPFORD - FORD 1996 (102-102), VPMERCEDES - MERCEDES BENZ 2022	204	204	PRODUCCION	8	1625.00	1800.00	175.00	2026-09-17	19:32:52.844773	t
\.


--
-- Data for Name: kits_empleados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kits_empleados (id_kit, id_empleado, nombre_kit, items) FROM stdin;
78	104	Kit Diario	[{"ID": "Inv_Vpro_alt_00042", "CANT": 1, "EQUIPO": "Pantalla  \\"", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00052", "CANT": 1, "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00053", "CANT": 1, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00054", "CANT": 1, "EQUIPO": "Base de Guitarra", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00055", "CANT": 1, "EQUIPO": "Base de Fierro Alta", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00056", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 8", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00057", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 4", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00058", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 2", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00059", "CANT": 1, "EQUIPO": "Pisa Cable (Yellow Jacket)", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00060", "CANT": 1, "EQUIPO": "Corral", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00061", "CANT": 1, "EQUIPO": "Tela Corral", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00062", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00063", "CANT": 1, "EQUIPO": "Silla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00064", "CANT": 1, "EQUIPO": "Diablito", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00065", "CANT": 1, "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00066", "CANT": 1, "EQUIPO": "Tela para Pantalla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00067", "CANT": 1, "EQUIPO": "Cable SDI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00068", "CANT": 1, "EQUIPO": "Balanceador", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00069", "CANT": 1, "EQUIPO": "Cable de Fibra Optica", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00070", "CANT": 1, "EQUIPO": "Convertidores de Fibra Optica", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00071", "CANT": 1, "EQUIPO": "Centro de Carga", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00072", "CANT": 1, "EQUIPO": "Abanico", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00073", "CANT": 1, "EQUIPO": "Carpa", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00074", "CANT": 1, "EQUIPO": "Paragua", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00075", "CANT": 1, "EQUIPO": "Caja de Herramientas", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00076", "CANT": 1, "EQUIPO": "Control Remoto Pantalla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00077", "CANT": 1, "EQUIPO": "Proyector", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00078", "CANT": 1, "EQUIPO": "Base de Proyector", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00079", "CANT": 1, "EQUIPO": "Pantalla Latex y Cuadro con Tripie", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00080", "CANT": 1, "EQUIPO": "Bolsa contra Peso", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00081", "CANT": 1, "EQUIPO": "Base de Madera", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00082", "CANT": 1, "EQUIPO": "Dolly's", "OBSERVACIONES": ""}]
85	109	Semanera	[{"ID": "Inv_Vpro_alt_00088", "CANT": 1, "EQUIPO": "vMix", "OBSERVACIONES": "None"}]
89	104	Enlace ISJU Presidencia 	[{"ID": "Inv_Vpro_alt_00042", "CANT": 1, "EQUIPO": "Pantalla  \\"", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00052", "CANT": 3, "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00053", "CANT": 3, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00055", "CANT": 1, "EQUIPO": "Base de Fierro Alta", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00059", "CANT": 4, "EQUIPO": "Pisa Cable (Yellow Jacket)", "OBSERVACIONES": "2,7,9,13"}, {"ID": "Inv_Vpro_alt_00060", "CANT": 1, "EQUIPO": "Corral", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00061", "CANT": 1, "EQUIPO": "Tela Corral", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00062", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00063", "CANT": 2, "EQUIPO": "Silla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00065", "CANT": 1, "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00067", "CANT": 4, "EQUIPO": "Cable SDI", "OBSERVACIONES": ""}]
93	119	Semanera	[{"ID": "Inv_Vpro_alt_00045", "CANT": 1, "EQUIPO": "Camaras", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00045", "CANT": 1, "EQUIPO": "Tripies", "OBSERVACIONES": ""}]
99	200	EQUIPO EN AREA DE EDICION	[{"ID": "Inv_Vpro_alt_00106", "CANT": 1, "EQUIPO": "Silla1", "OBSERVACIONES": "El respaldo de la silla esta dañando por lo cual no se puede sostener solo."}, {"ID": "Inv_Vpro_alt_00107", "CANT": 1, "EQUIPO": "Silla2", "OBSERVACIONES": "El respaldo de la silla esta dañando por lo cual no se puede sostener solo."}, {"ID": "Inv_Vpro_alt_00108", "CANT": 1, "EQUIPO": "Silla3", "OBSERVACIONES": "La base donde están las llantas  esta quebrada y se extravió una llanta."}, {"ID": "Inv_Vpro_alt_00109", "CANT": 1, "EQUIPO": "Silla1 de tela", "OBSERVACIONES": "La base donde están las llantas  esta quebrada y se extravió una llanta."}, {"ID": "Inv_Vpro_alt_00110", "CANT": 1, "EQUIPO": "Silla2 de tela", "OBSERVACIONES": "La base donde están las llantas  esta quebrada y se extravió  dos llantas."}]
113	104	INFORME RENDICIÓN DE CUENTAS PRESIDENCIA	[{"ID": "VPRO_ALT_16389", "CANT": 7, "EQUIPO": "Cables SDI", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16418", "CANT": 6, "EQUIPO": "Extensiones", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16445", "CANT": 3, "EQUIPO": "HDMI", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16456", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16469", "CANT": 3, "EQUIPO": "Sillas", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16484", "CANT": 1, "EQUIPO": "Carpa", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16514", "CANT": 10, "EQUIPO": "Pisa Cables Yellow Jacket", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16530", "CANT": 2, "EQUIPO": "Multicontactos", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16540", "CANT": 1, "EQUIPO": "Abanico", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_16556", "CANT": 1, "EQUIPO": "Grabadoras", "OBSERVACIONES": null}]
124	107	MEDICAMENTO	[{"ID": "VPRO_ALT_24702", "CANT": 1, "EQUIPO": "pepto", "OBSERVACIONES": null}]
79	104	Kit 5 de mayo batalla de puebla	[{"ID": "Inv_Vpro_alt_00042", "CANT": 1, "EQUIPO": "Pantalla  \\"", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00052", "CANT": 1, "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00053", "CANT": 1, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00054", "CANT": 1, "EQUIPO": "Base de Guitarra", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00057", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 4", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00058", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 2", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00059", "CANT": 1, "EQUIPO": "Pisa Cable (Yellow Jacket)", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00062", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00063", "CANT": 1, "EQUIPO": "Silla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00065", "CANT": 1, "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00066", "CANT": 1, "EQUIPO": "Tela para Pantalla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00076", "CANT": 1, "EQUIPO": "Control Remoto Pantalla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00083", "CANT": 1, "EQUIPO": "Carpa", "OBSERVACIONES": ""}]
83	104	Reunion privada seguridad	[{"ID": "Inv_Vpro_alt_00042", "CANT": 1, "EQUIPO": "Pantalla  \\"", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00052", "CANT": 1, "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00053", "CANT": 1, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00054", "CANT": 1, "EQUIPO": "Base de Guitarra", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00055", "CANT": 1, "EQUIPO": "Base de Fierro Alta", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00057", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 4", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00058", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 2", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00059", "CANT": 1, "EQUIPO": "Pisa Cable (Yellow Jacket)", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00065", "CANT": 1, "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00066", "CANT": 1, "EQUIPO": "Tela para Pantalla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00087", "CANT": 1, "EQUIPO": "Control Remoto Pantalla", "OBSERVACIONES": ""}]
86	109	CIBACOPA	[{"ID": "Inv_Vpro_alt_00088", "CANT": 1, "EQUIPO": "vMix", "OBSERVACIONES": "None"}]
95	124	Mi inventario	[{"ID": "Inv_Vpro_alt_00095", "CANT": 1, "EQUIPO": "IMPRESORA SAMSUNG EXPRESS M2022", "OBSERVACIONES": "se trabo"}, {"ID": "Inv_Vpro_alt_00096", "CANT": 1, "EQUIPO": "TELEFONO PANASONIC", "OBSERVACIONES": "no funcionaba la linea"}]
97	119	Evento Especial	[{"ID": "Inv_Vpro_alt_00045", "CANT": 2, "EQUIPO": "Tripies", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00045", "CANT": 2, "EQUIPO": "camaras 320", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00097", "CANT": 4, "EQUIPO": "baterias", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00098", "CANT": 4, "EQUIPO": "fuentes de poder", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00099", "CANT": 6, "EQUIPO": "radios", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00100", "CANT": 1, "EQUIPO": "balanceador", "OBSERVACIONES": "None"}]
80	104	Reunion informa senadora	[{"ID": "Inv_Vpro_alt_00052", "CANT": 1, "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00053", "CANT": 1, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00059", "CANT": 1, "EQUIPO": "Pisa Cable (Yellow Jacket)", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00060", "CANT": 1, "EQUIPO": "Corral", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00061", "CANT": 1, "EQUIPO": "Tela Corral", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00062", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00063", "CANT": 1, "EQUIPO": "Silla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00064", "CANT": 1, "EQUIPO": "Diablito", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00065", "CANT": 1, "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00067", "CANT": 1, "EQUIPO": "Cable SDI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00068", "CANT": 1, "EQUIPO": "Balanceador", "OBSERVACIONES": ""}]
84	201	Kit para CIBACOPA	[{"ID": "Inv_Vpro_alt_00012", "CANT": 1, "EQUIPO": "Computadora de escritorio con dos monitores", "OBSERVACIONES": ""}]
118	200	EQUIPO AREA EDICION	[{"ID": "Inv_Vpro_alt_00106", "CANT": 1, "EQUIPO": "Silla1", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00107", "CANT": 1, "EQUIPO": "Silla2", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00108", "CANT": 1, "EQUIPO": "Silla3", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00109", "CANT": 1, "EQUIPO": "Silla1 de tela", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00110", "CANT": 1, "EQUIPO": "Silla2 de tela", "OBSERVACIONES": ""}]
120	104	INFORME RENDICION DE CUENTAS PRESIDENCIA	[{"ID": "VPRO_ALT_16389", "CANT": 7, "EQUIPO": "Cables SDI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16418", "CANT": 8, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16445", "CANT": 5, "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16456", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16469", "CANT": 3, "EQUIPO": "Sillas", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16484", "CANT": 1, "EQUIPO": "Carpa", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16514", "CANT": 10, "EQUIPO": "Pisa Cables Yellow Jacket", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16530", "CANT": 2, "EQUIPO": "Multicontactos", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16540", "CANT": 2, "EQUIPO": "Abanico", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16556", "CANT": 1, "EQUIPO": "Grabadoras", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_74716", "CANT": 1, "EQUIPO": "abanico", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_17725", "CANT": 1, "EQUIPO": "base metal para monitor", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_17765", "CANT": 1, "EQUIPO": "base de guitarra", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_17836", "CANT": 1, "EQUIPO": "monitor de 65\\"", "OBSERVACIONES": null}]
131	109	ENLACE PRESIDENTA	[{"ID": "VPRO_ALT_26256", "CANT": 1, "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26284", "CANT": 1, "EQUIPO": "laptop Vmix g7", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26302", "CANT": 1, "EQUIPO": "Atem", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26326", "CANT": 1, "EQUIPO": "consola audio (mini vMix)", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26361", "CANT": 1, "EQUIPO": "mac #3", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26418", "CANT": 1, "EQUIPO": "hub 1x7", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26466", "CANT": 3, "EQUIPO": "cables XLR", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26558", "CANT": 2, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "peavey", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26642", "CANT": 1, "EQUIPO": "modem Quantum", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": null}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": null}]
57	118	Cibacopa	[{"ID": "Inv_Vpro_alt_00043", "CANT": 1, "EQUIPO": "consola  16 canales", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00043", "CANT": 1, "EQUIPO": "transmisor sony", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00043", "CANT": 2, "EQUIPO": "Receptor Sony", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00043", "CANT": 1, "EQUIPO": "Interfase de Audio", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00043", "CANT": 1, "EQUIPO": "shark berihenger", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00043", "CANT": 1, "EQUIPO": "microfono shure de mano", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00044", "CANT": 1, "EQUIPO": "pedestal", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00044", "CANT": 1, "EQUIPO": "diadema de monitoreo", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00044", "CANT": 2, "EQUIPO": "chicharos para conduccion", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00044", "CANT": 2, "EQUIPO": "microfono lavalier sony", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00044", "CANT": 1, "EQUIPO": "pekey", "OBSERVACIONES": ""}]
59	119	cibacopa	[{"ID": "Inv_Vpro_alt_00045", "CANT": 4, "EQUIPO": "camaras", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00045", "CANT": 4, "EQUIPO": "tripies", "OBSERVACIONES": ""}]
63	105	SEMANERA 	[{"ID": "Inv_Vpro_alt_00048", "CANT": 1, "EQUIPO": "GO PRO", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00048", "CANT": 1, "EQUIPO": "LUCES", "OBSERVACIONES": ""}]
81	104	Fortalecimiento Kit Infantil	[{"ID": "Inv_Vpro_alt_00042", "CANT": 1, "EQUIPO": "Pantalla  \\"", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00052", "CANT": 1, "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00053", "CANT": 1, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00054", "CANT": 1, "EQUIPO": "Base de Guitarra", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00057", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 4", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00058", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 2", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00059", "CANT": 1, "EQUIPO": "Pisa Cable (Yellow Jacket)", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00062", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00063", "CANT": 1, "EQUIPO": "Silla", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00065", "CANT": 1, "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00066", "CANT": 1, "EQUIPO": "Tela para Pantalla", "OBSERVACIONES": ""}]
67	118	Semanera	[{"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 4, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 4, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 8, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00047", "CANT": 1, "EQUIPO": "laptop hp", "OBSERVACIONES": ""}]
134	109	KIT CIRCUITO CERRADO SENCILLO	[{"ID": "VPRO_ALT_26284", "CANT": 1, "EQUIPO": "laptop Vmix g7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26361", "CANT": 1, "EQUIPO": "mac #3", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26418", "CANT": 1, "EQUIPO": "hub 1x7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26466", "CANT": 3, "EQUIPO": "cables XLR", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26558", "CANT": 2, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "peavey", "OBSERVACIONES": "Una prestada de Hector"}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26642", "CANT": 1, "EQUIPO": "modem Quantum", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": "None"}]
135	109	KIT SEMANERA	[{"ID": "VPRO_ALT_26256", "CANT": 1, "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26284", "CANT": 1, "EQUIPO": "laptop Vmix g7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26302", "CANT": 1, "EQUIPO": "Atem", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26326", "CANT": 1, "EQUIPO": "consola audio (mini vMix)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26361", "CANT": 1, "EQUIPO": "mac #3", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26418", "CANT": 1, "EQUIPO": "hub 1x7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26466", "CANT": 3, "EQUIPO": "cables XLR", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26558", "CANT": 2, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "peavey", "OBSERVACIONES": "Una prestada de Hector"}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26642", "CANT": 1, "EQUIPO": "modem Quantum", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11376", "CANT": 1, "EQUIPO": "cpu de escritorio Cod. Pdte", "OBSERVACIONES": "sufrio golpe"}, {"ID": "VPRO_ALT_11423", "CANT": 1, "EQUIPO": "Monitor gamer negro plano cod pdte", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11490", "CANT": 1, "EQUIPO": "Kit de teclado mouse y receptor inalambricon cod pte", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11525", "CANT": 1, "EQUIPO": "Panel de control TYST Video cod pte", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11545", "CANT": 2, "EQUIPO": "Adaptador Display port hdmi cod Pte ", "OBSERVACIONES": "Uno de ellos no sirve"}]
143	202	IEES en área de ventas de Vpro	[{"ID": "Inv_Vpro_alt_00157", "CANT": 1, "EQUIPO": "Laptop HP", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00158", "CANT": 4, "EQUIPO": "Cables ethernet cortos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00159", "CANT": 2, "EQUIPO": "Cables ethernet largos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00160", "CANT": 1, "EQUIPO": "No break (grande)", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00161", "CANT": 1, "EQUIPO": "Switch 8 puertos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00162", "CANT": 1, "EQUIPO": "Switch 5 puertos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00163", "CANT": 1, "EQUIPO": "Extensión eléctrica 6 metros", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00164", "CANT": 1, "EQUIPO": "Celular azul", "OBSERVACIONES": "None"}]
144	109	IEES	[{"ID": "VPRO_ALT_26256", "CANT": 1, "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26361", "CANT": 1, "EQUIPO": "mac #3", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26418", "CANT": 1, "EQUIPO": "hub 1x7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26466", "CANT": 3, "EQUIPO": "cables XLR", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26558", "CANT": 2, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "peavey", "OBSERVACIONES": "Una prestada de Hector"}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11376", "CANT": 1, "EQUIPO": "cpu de escritorio Cod. Pdte", "OBSERVACIONES": "sufrio golpe"}, {"ID": "VPRO_ALT_11423", "CANT": 1, "EQUIPO": "Monitor gamer negro plano cod pdte", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11490", "CANT": 1, "EQUIPO": "Kit de teclado mouse y receptor inalambricon cod pte", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11525", "CANT": 1, "EQUIPO": "Panel de control TYST Video cod pte", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11545", "CANT": 2, "EQUIPO": "Adaptador Display port hdmi cod Pte", "OBSERVACIONES": "Uno de ellos no sirve"}]
145	113	Kit paraguas	[{"ID": "Inv_Vpro_alt_00137", "CANT": 1, "EQUIPO": "paraguas", "OBSERVACIONES": "None"}]
146	105	Kit del dany	[{"ID": "Inv_Vpro_alt_00138", "CANT": 1, "EQUIPO": "Dany tienes que póner algo please", "OBSERVACIONES": "None"}]
149	202	Mundial futbol	[{"ID": "Inv_Vpro_alt_00139", "CANT": 6, "EQUIPO": "Cables ethernet cortos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00140", "CANT": 2, "EQUIPO": "Cables ethernet largos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00141", "CANT": 2, "EQUIPO": "Cables HDMI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00142", "CANT": 1, "EQUIPO": "Laptop HP, con cargador", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00143", "CANT": 1, "EQUIPO": "Laptop ASUS, con cargador", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00144", "CANT": 2, "EQUIPO": "Adaptador ethernet usb", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00145", "CANT": 1, "EQUIPO": "Switch 5 puertos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00146", "CANT": 1, "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00147", "CANT": 1, "EQUIPO": "Desarmador de pala", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00148", "CANT": 1, "EQUIPO": "Pinza ponchadora", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00149", "CANT": 1, "EQUIPO": "Bolsa con cinchos", "OBSERVACIONES": "None"}]
150	104	Estrategia Nacional de Seguridad Villa Unión	[{"ID": "Inv_Vpro_alt_00150", "CANT": 2, "EQUIPO": "pantalla 55\\"", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00151", "CANT": 6, "EQUIPO": "Cables HDMI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00152", "CANT": 6, "EQUIPO": "Cables de Corriente", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00153", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00154", "CANT": 1, "EQUIPO": "Carpa", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00155", "CANT": 5, "EQUIPO": "Pisa Cables", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00156", "CANT": 2, "EQUIPO": "Base de Madera", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00157", "CANT": 2, "EQUIPO": "Base de Guitarra", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00158", "CANT": 2, "EQUIPO": "Sillas", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00159", "CANT": 1, "EQUIPO": "Carpa", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00160", "CANT": 2, "EQUIPO": "Tela para Pantallas", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00161", "CANT": 1, "EQUIPO": "Distribuidor 1 a 4", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00162", "CANT": 1, "EQUIPO": "Distribuidor 1 a 2", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00163", "CANT": 1, "EQUIPO": "Multicontacto", "OBSERVACIONES": "None"}]
152	109	GENERAL	[{"ID": "VPRO_ALT_26284", "CANT": 1, "EQUIPO": "laptop Vmix g7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26326", "CANT": 1, "EQUIPO": "consola audio (mini vMix)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26361", "CANT": 1, "EQUIPO": "mac #3", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26418", "CANT": 1, "EQUIPO": "hub 1x7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26466", "CANT": 2, "EQUIPO": "cables XLR", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26558", "CANT": 2, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26591", "CANT": 1, "EQUIPO": "peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26642", "CANT": 1, "EQUIPO": "modem Quantum", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_26704", "CANT": 1, "EQUIPO": "Mac #4", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_26705", "CANT": 1, "EQUIPO": "UPS", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_26706", "CANT": 4, "EQUIPO": "Cables SDI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_26707", "CANT": 1, "EQUIPO": "Monitor Lilliput", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_26708", "CANT": 1, "EQUIPO": "Apuntador", "OBSERVACIONES": "None"}]
154	109	Oficina Osiel	[{"ID": "Inv_Vpro_alt_00162", "CANT": 1, "EQUIPO": "ontrol remoto de aire acondicionado mirage", "OBSERVACIONES": "Falta de pilas"}]
155	202	Salón Gobernadores	[{"ID": "Inv_Vpro_alt_00157", "CANT": 1, "EQUIPO": "Laptop HP", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00162", "CANT": 1, "EQUIPO": "Laptop ASUS", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00163", "CANT": 1, "EQUIPO": "Switch tplink 5 puertos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00164", "CANT": 6, "EQUIPO": "Cableado utp corto", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00165", "CANT": 3, "EQUIPO": "Cableado utp Largo", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00166", "CANT": 1, "EQUIPO": "UPS", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00167", "CANT": 2, "EQUIPO": "Adaptador ETH", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00168", "CANT": 1, "EQUIPO": "Pinza ponchadora", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00169", "CANT": 1, "EQUIPO": "Celular institucional", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00170", "CANT": 1, "EQUIPO": "Ipad", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00171", "CANT": 1, "EQUIPO": "Tablet android", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00172", "CANT": 1, "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00173", "CANT": 1, "EQUIPO": "Desarmador de pala", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00174", "CANT": 1, "EQUIPO": "Laptop HP", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00175", "CANT": 2, "EQUIPO": "Pisacables", "OBSERVACIONES": "None"}]
156	104	Reunión del Consejo Protección Civil	[{"ID": "Inv_Vpro_alt_00173", "CANT": 7, "EQUIPO": "Cable SDI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00174", "CANT": 5, "EQUIPO": "CableHDMI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00175", "CANT": 5, "EQUIPO": "Extensiones", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00176", "CANT": 1, "EQUIPO": "Distribuidor HDMI 1 a 4", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00177", "CANT": 2, "EQUIPO": "Distribuidor HDMI 1 a 2", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00178", "CANT": 1, "EQUIPO": "Bolsa de Arena", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00179", "CANT": 3, "EQUIPO": "Pisa Cable", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00180", "CANT": 2, "EQUIPO": "Multicontactos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00181", "CANT": 1, "EQUIPO": "Balanceador", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00182", "CANT": 2, "EQUIPO": "Dollys", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00183", "CANT": 1, "EQUIPO": "Diablito", "OBSERVACIONES": "None"}]
158	202	Enlace y viviendas bienestar	[{"ID": "Inv_Vpro_alt_00181", "CANT": 1, "EQUIPO": "Portátil HP", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00182", "CANT": 1, "EQUIPO": "Portátil ASUS", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00183", "CANT": 1, "EQUIPO": "Switch 5 puertos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00184", "CANT": 1, "EQUIPO": "Switch 8 puertos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00185", "CANT": 8, "EQUIPO": "Cableado UTP cortos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00186", "CANT": 4, "EQUIPO": "Cableado UTP largos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00187", "CANT": 1, "EQUIPO": "UPS (No-Break)", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00188", "CANT": 2, "EQUIPO": "Adaptador ETH", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00189", "CANT": 1, "EQUIPO": "Pinza ponchadora", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00190", "CANT": 1, "EQUIPO": "Modem Quantum", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00191", "CANT": 1, "EQUIPO": "Celular institucional", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00192", "CANT": 1, "EQUIPO": "Access point tp-link omada", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00193", "CANT": 1, "EQUIPO": "Ipad", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00194", "CANT": 1, "EQUIPO": "Tablet Android", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00195", "CANT": 2, "EQUIPO": "Tripie para bocina", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00196", "CANT": 1, "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00197", "CANT": 1, "EQUIPO": "Desarmador de pala", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00198", "CANT": 2, "EQUIPO": "Antena starlink", "OBSERVACIONES": "Antenas 01 y 02"}, {"ID": "Inv_Vpro_alt_00199", "CANT": 2, "EQUIPO": "Cable largo para starlink", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00200", "CANT": 1, "EQUIPO": "Kit de terminales para starlink", "OBSERVACIONES": "None"}]
162	125	kit invntario	[{"ID": "Inv_Vpro_alt_00207", "CANT": 1, "EQUIPO": "mouse blanco", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00208", "CANT": 1, "EQUIPO": "ordenador", "OBSERVACIONES": "None"}]
163	119	Kit evento especial enlace presidenta a 4 cámaras	[{"ID": "Inv_Vpro_alt_00045", "CANT": 4, "EQUIPO": "Cámaras", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00045", "CANT": 4, "EQUIPO": "Tripies", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00198", "CANT": 4, "EQUIPO": "monitores", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00199", "CANT": 6, "EQUIPO": "baterias para camara 320", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00200", "CANT": 4, "EQUIPO": "fuentes de póder", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00201", "CANT": 1, "EQUIPO": "balanceador", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00202", "CANT": 6, "EQUIPO": "radios", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00203", "CANT": 6, "EQUIPO": "baterias para monitor", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00204", "CANT": 1, "EQUIPO": "monitor de ingenieria", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00205", "CANT": 2, "EQUIPO": "escaladores decimator", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00206", "CANT": 2, "EQUIPO": "convertidores blackmagic", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00207", "CANT": 4, "EQUIPO": "Forros de cámara", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00208", "CANT": 1, "EQUIPO": "Banco", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00209", "CANT": 2, "EQUIPO": "Paraguas", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00210", "CANT": 1, "EQUIPO": "monitor ingenieria", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00211", "CANT": 8, "EQUIPO": "servos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00212", "CANT": 1, "EQUIPO": "dolly", "OBSERVACIONES": "None"}]
164	104	El Sauz	[{"ID": "Inv_Vpro_alt_00210", "CANT": 3, "EQUIPO": "Extenciones", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00211", "CANT": 3, "EQUIPO": "Hdmi", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00212", "CANT": 2, "EQUIPO": "Base de Pantallas Altas", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00213", "CANT": 1, "EQUIPO": "Distribuidor HDMI", "OBSERVACIONES": "None"}]
165	104	Viviendas bienestar	[{"ID": "Inv_Vpro_alt_00210", "CANT": 19, "EQUIPO": "Extenciones", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00211", "CANT": 32, "EQUIPO": "Hdmi", "OBSERVACIONES": "1 cable sin punta"}, {"ID": "Inv_Vpro_alt_00212", "CANT": 10, "EQUIPO": "Base de Pantallas Altas", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00213", "CANT": 3, "EQUIPO": "Distribuidor HDMI \\"2\\"", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00214", "CANT": 1, "EQUIPO": "Distribuidor HDMI \\"4\\"", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00215", "CANT": 2, "EQUIPO": "Distribuidor HDMI \\"8\\"", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00216", "CANT": 1, "EQUIPO": "Carpa", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00217", "CANT": 1, "EQUIPO": "Monitor de 55''", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00218", "CANT": 1, "EQUIPO": "Monitor de 60''", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00219", "CANT": 7, "EQUIPO": "Monitor de 65''", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00220", "CANT": 10, "EQUIPO": "Base metal para monitor", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00221", "CANT": 17, "EQUIPO": "Pisa Cables", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00222", "CANT": 1, "EQUIPO": "Equipo no registrado", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00223", "CANT": 2, "EQUIPO": "Mesas pegables", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00224", "CANT": 2, "EQUIPO": "Control remoto para monitor", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00225", "CANT": 4, "EQUIPO": "Sillas", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00226", "CANT": 1, "EQUIPO": "Grabadoras", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00227", "CANT": 10, "EQUIPO": "Multicontactos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00228", "CANT": 1, "EQUIPO": "Equipo no registrado", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00229", "CANT": 1, "EQUIPO": "Monitor de 40''", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00230", "CANT": 1, "EQUIPO": "Diablito", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00231", "CANT": 11, "EQUIPO": "Cables SDI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00232", "CANT": 2, "EQUIPO": "Abanicos", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00233", "CANT": 1, "EQUIPO": "Lampara 2000", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00234", "CANT": 1, "EQUIPO": "Century", "OBSERVACIONES": "None"}]
167	107	tablet	[{"ID": "Inv_Vpro_alt_00232", "CANT": 1, "EQUIPO": "tablet", "OBSERVACIONES": "None"}]
168	107	dollys	[{"ID": "Inv_Vpro_alt_00232", "CANT": 1, "EQUIPO": "dolly in", "OBSERVACIONES": "dolly back"}]
169	109	KIT DE AUDIO PARA TESTIMONIAL	[{"ID": "Inv_Vpro_alt_00232", "CANT": 1, "EQUIPO": "Transmisor Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00233", "CANT": 1, "EQUIPO": "Receptor Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00234", "CANT": 1, "EQUIPO": "Micrófono Lavalier", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00235", "CANT": 1, "EQUIPO": "Audífonos de monitoreo Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00236", "CANT": 2, "EQUIPO": "Cables de Microfóneo", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00237", "CANT": 8, "EQUIPO": "Baterias \\"AA\\"", "OBSERVACIONES": "None"}]
171	109	Kit de audio testimonial	[{"ID": "Inv_Vpro_alt_00232", "CANT": 1, "EQUIPO": "Transmisor Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00233", "CANT": 1, "EQUIPO": "Receptor Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00234", "CANT": 1, "EQUIPO": "Micrófono Lavalier", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00235", "CANT": 1, "EQUIPO": "Audífonos de monitoreo Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00236", "CANT": 2, "EQUIPO": "Cables de Microfóneo", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00237", "CANT": 8, "EQUIPO": "Baterias \\"AA\\"", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00238", "CANT": 1, "EQUIPO": "Diadema de monitoreo", "OBSERVACIONES": "None"}]
172	109	KIT ENLACE PRESIDENTA	[{"ID": "VPRO_ALT_26256", "CANT": 1, "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26284", "CANT": 1, "EQUIPO": "laptop Vmix g7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26302", "CANT": 1, "EQUIPO": "Atem", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26326", "CANT": 1, "EQUIPO": "consola audio (mini vMix)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26361", "CANT": 1, "EQUIPO": "mac #3", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26418", "CANT": 2, "EQUIPO": "hub 1x7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26466", "CANT": 2, "EQUIPO": "cables XLR", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26558", "CANT": 1, "EQUIPO": "Decimator", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26642", "CANT": 1, "EQUIPO": "HDMI splitter (1x4)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11376", "CANT": 1, "EQUIPO": "Grabadora", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_26704", "CANT": 1, "EQUIPO": "Mac #4", "OBSERVACIONES": "None"}]
173	109	Kit reunion del consejo	[{"ID": "VPRO_ALT_26256", "CANT": 1, "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26284", "CANT": 1, "EQUIPO": "laptop Vmix g7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26302", "CANT": 1, "EQUIPO": "Atem", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26326", "CANT": 1, "EQUIPO": "consola audio (mini vMix)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26361", "CANT": 1, "EQUIPO": "mac #3", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26418", "CANT": 2, "EQUIPO": "hub 1x7", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26466", "CANT": 2, "EQUIPO": "cables XLR", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26558", "CANT": 1, "EQUIPO": "Decimator", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26642", "CANT": 1, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_11376", "CANT": 1, "EQUIPO": "Grabadora", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_26704", "CANT": 1, "EQUIPO": "Mac #4", "OBSERVACIONES": "None"}]
192	113	Kit Grabaciones	[{"ID": "Inv_Vpro_alt_00236", "CANT": 1, "EQUIPO": "Sony Alpha VIII", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00237", "CANT": 1, "EQUIPO": "Estabilizador DJI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00252", "CANT": 1, "EQUIPO": "botella de agua etiqueta azul de 600 ml", "OBSERVACIONES": "esta botella la tome de la mesa y nadie s dio cuenta cod vpned"}, {"ID": "Inv_Vpro_alt_00253", "CANT": 1, "EQUIPO": "este es de pilon", "OBSERVACIONES": "None"}]
200	109	Kit Audio	[{"ID": "Inv_Vpro_alt_00253", "CANT": 2, "EQUIPO": "Receptor sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00254", "CANT": 2, "EQUIPO": "Transmisor sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00255", "CANT": 2, "EQUIPO": "microfono lavalier", "OBSERVACIONES": "1 con capuchon y 1 sin capuchon"}, {"ID": "Inv_Vpro_alt_00256", "CANT": 2, "EQUIPO": "Cable XLR (3.5)", "OBSERVACIONES": "None"}]
203	102	Kit Grabaciones	[{"ID": "Inv_Vpro_alt_00236", "CANT": 1, "EQUIPO": "Camara FS7", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00237", "CANT": 1, "EQUIPO": "Tripie", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00238", "CANT": 1, "EQUIPO": "Baterias  Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00254", "CANT": 1, "EQUIPO": "Rebotador", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00255", "CANT": 1, "EQUIPO": "Kit de lentes", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00256", "CANT": 1, "EQUIPO": "Lavalier", "OBSERVACIONES": "None"}]
205	113	Grabación 	[{"ID": "Inv_Vpro_alt_00236", "CANT": 1, "EQUIPO": "Camara Alpha Viii", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00254", "CANT": 1, "EQUIPO": "Estabilizador DJI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00255", "CANT": 1, "EQUIPO": "Cargador Camara Sony", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00256", "CANT": 1, "EQUIPO": "Baterias Sony Alpha", "OBSERVACIONES": "None"}]
209	109	KIT AUDIO BOOM Y LAVALIER	[{"ID": "None", "CANT": 1, "EQUIPO": "Transmisor SONY VPNAUD002", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Receptor SONY VPNAUD002", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 2, "EQUIPO": "Cableado de MIC VPNAUDOO1 Y VPNAUD002", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Microfono Lavalier VPNAUD001", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Tripié CENTURY", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 2, "EQUIPO": "Cables XLR", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Audífonos SONY VPNAUD019", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 4, "EQUIPO": "Baterias \\"AA\\"", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Microfono Ambiental SHURE VPNAUD026", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Grabadora TASCAM VPNAUD017", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Boom para Microfono", "OBSERVACIONES": "None"}, {"ID": "None", "CANT": 1, "EQUIPO": "Bolsa de Arena", "OBSERVACIONES": "None"}]
220	113	Grabacion LEY	[{"ID": "INV_VPRO_ALT_00256", "CANT": 2, "EQUIPO": "Baterias Sony Alpha", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130001", "CANT": 1, "EQUIPO": "Camara Alpha VIII", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130002", "CANT": 1, "EQUIPO": "Estabilizador", "OBSERVACIONES": ""}]
221	109	Kit LEY	[{"ID": "INV_VPRO_ALT_00253", "CANT": 1, "EQUIPO": "Receptor sony", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00254", "CANT": 1, "EQUIPO": "Transmisor sony", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00255", "CANT": 1, "EQUIPO": "microfono lavalier", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26466", "CANT": 2, "EQUIPO": "cables XLR", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090001", "CANT": 1, "EQUIPO": "Century", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090002", "CANT": 1, "EQUIPO": "Diadema Sony", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090003", "CANT": 1, "EQUIPO": "(4) Microfonos ambientales de camara", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090004", "CANT": 1, "EQUIPO": "Grabadora TASCAM", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090005", "CANT": 1, "EQUIPO": "Boom para microfono", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00178", "CANT": 1, "EQUIPO": "Bolsa de Arena", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090006", "CANT": 2, "EQUIPO": "cableado para microfono", "OBSERVACIONES": ""}]
223	105	cocacola cine	[{"ID": "Inv_Vpro_alt_00138", "CANT": 1, "EQUIPO": "telepronter", "OBSERVACIONES": "None"}, {"ID": "Inv_alt_1050002", "CANT": 1, "EQUIPO": "lap -top pronter", "OBSERVACIONES": "[CUST_EQ:lap -top pronter] None"}, {"ID": "VPRO_ALT_26448", "CANT": 1, "EQUIPO": "hdmi", "OBSERVACIONES": "None"}]
224	109	KIT DE ESTUDIO INALAMBRICO	[{"ID": "Inv_alt_1090007", "CANT": 1, "EQUIPO": "Transmisor SONY VPNAUD002", "OBSERVACIONES": "[CUST_EQ:Transmisor SONY VPNAUD002] None"}, {"ID": "Inv_alt_1090008", "CANT": 1, "EQUIPO": "Receptor SONY VPNAUD002", "OBSERVACIONES": "[CUST_EQ:Receptor SONY VPNAUD002]"}, {"ID": "Inv_alt_1090009", "CANT": 2, "EQUIPO": "Cableado de MIC VPNAUDOO1 Y VPNAUD002", "OBSERVACIONES": "[CUST_EQ:Cableado de MIC VPNAUDOO1 Y VPNAUD002]"}, {"ID": "Inv_alt_1090010", "CANT": 1, "EQUIPO": "Tripié CENTURY", "OBSERVACIONES": "[CUST_EQ:Tripié CENTURY]"}, {"ID": "VPRO_ALT_26466", "CANT": 1, "EQUIPO": "Cables XLR", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090011", "CANT": 1, "EQUIPO": "Audífonos SONY VPNAUD019", "OBSERVACIONES": "[CUST_EQ:Audífonos SONY VPNAUD019]"}, {"ID": "Inv_alt_1090012", "CANT": 1, "EQUIPO": "Grabadora TASCAM VPNAUD017", "OBSERVACIONES": "[CUST_EQ:Grabadora TASCAM VPNAUD017]"}, {"ID": "INV_ALT_1090005", "CANT": 1, "EQUIPO": "Boom para Microfono", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00178", "CANT": 1, "EQUIPO": "Bolsa de Arena", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090013", "CANT": 1, "EQUIPO": "Audifonos VPNAUD065", "OBSERVACIONES": "[CUST_EQ:Audifonos VPNAUD065] None"}]
225	200	Kit edición Andrea	[{"ID": "Inv_alt_2000001", "CANT": 1, "EQUIPO": "Computadora Mac", "OBSERVACIONES": "[CUST_EQ:Computadora Mac] Computadora MAC asignada a Andrea"}, {"ID": "Inv_alt_2000002", "CANT": 1, "EQUIPO": "Disco Duro", "OBSERVACIONES": "[CUST_EQ:Disco Duro] Disco duro con nombre \\"Vmix\\""}]
226	102	KIT SONY FS7	[{"ID": "Inv_alt_1020001", "CANT": 1, "EQUIPO": "CAMARA SONY FS7", "OBSERVACIONES": "[CUST_EQ:CAMARA SONY FS7] None"}, {"ID": "Inv_alt_1020002", "CANT": 2, "EQUIPO": "BATERIAS SONY V MOUNT", "OBSERVACIONES": "[CUST_EQ:BATERIAS SONY V MOUNT] None"}, {"ID": "Inv_alt_1020003", "CANT": 1, "EQUIPO": "TRIPIE LIBEC", "OBSERVACIONES": "[CUST_EQ:TRIPIE LIBEC] None"}, {"ID": "Inv_alt_1020004", "CANT": 1, "EQUIPO": "KIT DE LENTES", "OBSERVACIONES": "[CUST_EQ:KIT DE LENTES] None"}]
235	119	KIT EVENTO ESPECIAL 3 CAMARAS	[{"ID": "INV_VPRO_ALT_00045", "CANT": 2, "EQUIPO": "camaras 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00001", "CANT": 2, "EQUIPO": "tripies", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "CANT": 6, "EQUIPO": "baterias", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "CANT": 2, "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00099", "CANT": 6, "EQUIPO": "radios", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "CANT": 1, "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00101", "CANT": 1, "EQUIPO": "dollys", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00102", "CANT": 1, "EQUIPO": "monitor de ingeneria", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00103", "CANT": 1, "EQUIPO": "monitor lilliput", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00104", "CANT": 1, "EQUIPO": "bancos", "OBSERVACIONES": ""}]
236	104	Grabación al campo	[{"ID": "INV_VPRO_ALT_00236", "CANT": 3, "EQUIPO": "tripies", "OBSERVACIONES": "None"}, {"ID": "Inv_alt_1040001", "CANT": 1, "EQUIPO": "kit de luces", "OBSERVACIONES": "[CUST_EQ:kit de luces] None"}, {"ID": "INV_VPRO_ALT_00237", "CANT": 3, "EQUIPO": "baterias sony", "OBSERVACIONES": "None"}, {"ID": "Inv_alt_1040002", "CANT": 2, "EQUIPO": "baterias zgzine", "OBSERVACIONES": "[CUST_EQ:baterias zgzine] None"}, {"ID": "Inv_alt_1040003", "CANT": 1, "EQUIPO": "cargador de pila", "OBSERVACIONES": "[CUST_EQ:cargador de pila] None"}]
239	105	CASA LEY	[{"ID": "INV_VPRO_ALT_00235", "CANT": 1, "EQUIPO": "KIT LUCES", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00236", "CANT": 3, "EQUIPO": "TRIPIES", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00237", "CANT": 3, "EQUIPO": "BATERIAS SONY", "OBSERVACIONES": ""}]
243	104	Kit Semanera	[{"ID": "INV_VPRO_ALT_00042", "CANT": 2, "EQUIPO": "Pantalla  55\\"", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00052", "CANT": 10, "EQUIPO": "cable hdmi", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00053", "CANT": 10, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00057", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 4", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00058", "CANT": 2, "EQUIPO": "Distribuidor de HDMI de 2", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00065", "CANT": 2, "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00081", "CANT": 2, "EQUIPO": "Base de Madera Tv", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00082", "CANT": 1, "EQUIPO": "Dolly's", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00085", "CANT": 2, "EQUIPO": "tela de base", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00086", "CANT": 8, "EQUIPO": "Yellow Jake(pisacable)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16456", "CANT": 1, "EQUIPO": "mesa", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040001", "CANT": 2, "EQUIPO": "kit de luces", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16469", "CANT": 3, "EQUIPO": "sillas", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00173", "CANT": 8, "EQUIPO": "cable sdi", "OBSERVACIONES": "None"}]
256	105	Kit enlace Presidenta	[{"ID": "INV_ALT_1050006", "CANT": 1, "EQUIPO": "base de fierro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040001", "CANT": 1, "EQUIPO": "kit de luces", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050003", "CANT": 1, "EQUIPO": "Pantalla de 50\\"", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00052", "CANT": 1, "EQUIPO": "cable hdmi", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16418", "CANT": 4, "EQUIPO": "extensiones", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050004", "CANT": 1, "EQUIPO": "hdmi 100 mts", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050005", "CANT": 1, "EQUIPO": "dolly", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16456", "CANT": 1, "EQUIPO": "mesa", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00173", "CANT": 3, "EQUIPO": "cable sdi", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "CANT": 1, "EQUIPO": "tripie", "OBSERVACIONES": "None"}]
257	109	KIT ENLACE Y CIRCUITO CERRADO	[{"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26466", "CANT": 3, "EQUIPO": "cables XLR", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26558", "CANT": 2, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090024", "CANT": 12, "EQUIPO": "Baterias AA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090014", "CANT": 1, "EQUIPO": "Transmisor de audio SONY VPNAUD009", "OBSERVACIONES": "[CUST_EQ:Transmisor de audio SONY VPNAUD009] None"}, {"ID": "INV_ALT_1090015", "CANT": 4, "EQUIPO": "Receptor de audio SONY VPNAUD008", "OBSERVACIONES": "[CUST_EQ:Receptor de audio SONY VPNAUD008] None"}, {"ID": "INV_ALT_1090016", "CANT": 1, "EQUIPO": "Microfono de solapa SONY VPNAUD001", "OBSERVACIONES": "[CUST_EQ:Microfono de solapa SONY VPNAUD001] None"}, {"ID": "INV_ALT_1090017", "CANT": 4, "EQUIPO": "Diademas de comunicaciÃÂ³n BEHRINGER VPNAUD065", "OBSERVACIONES": "[CUST_EQ:Diademas de comunicaciÃÂÃÂ³n BEHRINGER VPNAUD065] None"}, {"ID": "INV_ALT_1090018", "CANT": 1, "EQUIPO": "Diadema de comunicaciÃÂ³n SONY VPNAUD019", "OBSERVACIONES": "[CUST_EQ:Diadema de comunicaciÃÂÃÂ³n SONY VPNAUD019] None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26418", "CANT": 2, "EQUIPO": "hub 1x7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090025", "CANT": 4, "EQUIPO": "bateria AA", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26256", "CANT": 1, "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26302", "CANT": 1, "EQUIPO": "Atem HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26326", "CANT": 1, "EQUIPO": "Consola audio (mini vMix)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26361", "CANT": 2, "EQUIPO": "mac #3 y #4", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00253", "CANT": 3, "EQUIPO": "receptor sony", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00255", "CANT": 3, "EQUIPO": "microfono lavalier", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090021", "CANT": 3, "EQUIPO": "cables XLR (3.5 Milimetros)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090022", "CANT": 4, "EQUIPO": "cables xlr (5mts)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090023", "CANT": 2, "EQUIPO": "bocina con cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090026", "CANT": 3, "EQUIPO": "transmisores sony", "OBSERVACIONES": ""}]
268	202	Jornadas de la paz 1	[{"ID": "INV_VPRO_ALT_00242", "CANT": 2, "EQUIPO": "Antena starlink 03, 02", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00243", "CANT": 1, "EQUIPO": "UPS (No break) Koblenz", "OBSERVACIONES": "VPNRED099"}, {"ID": "INV_VPRO_ALT_00244", "CANT": 1, "EQUIPO": "Mesa pequeÃÂÃÂÃÂÃÂ±a", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "CANT": 1, "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "CANT": 1, "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00248", "CANT": 1, "EQUIPO": "ExtensiÃÂÃÂÃÂÃÂ³n elÃÂÃÂÃÂÃÂ©ctrica corta", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00250", "CANT": 1, "EQUIPO": "TripiÃÂÃÂÃÂÃÂ© para bocina (sin tubo extensor)", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00252", "CANT": 2, "EQUIPO": "Adaptador ethernet usb", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00254", "CANT": 10, "EQUIPO": "Pisa cables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020001", "CANT": 1, "EQUIPO": "Cable largo para starlink", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020002", "CANT": 1, "EQUIPO": "Cable ethernet corto", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020003", "CANT": 6, "EQUIPO": "Cable ethernet largo", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00189", "CANT": 1, "EQUIPO": "Pinza ponchadora", "OBSERVACIONES": "None"}, {"ID": "INV_ALT_2020005", "CANT": 2, "EQUIPO": "Swich de 8 puerto", "OBSERVACIONES": "None"}]
265	202	Jornadas de la paz - Bueno	[{"ID": "INV_VPRO_ALT_00236", "CANT": 1, "EQUIPO": "TRIPIES", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00242", "CANT": 2, "EQUIPO": "Antena starlink 03, 02", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00243", "CANT": 1, "EQUIPO": "UPS (No break) Koblenz", "OBSERVACIONES": "VPNRED099"}, {"ID": "INV_VPRO_ALT_00244", "CANT": 1, "EQUIPO": "Mesa pequeÃÂÃÂ±a", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "CANT": 1, "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "CANT": 1, "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00248", "CANT": 1, "EQUIPO": "ExtensiÃÂÃÂ³n elÃÂÃÂ©ctrica corta", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00250", "CANT": 2, "EQUIPO": "TripiÃÂÃÂ© para bocina (sin tubo extensor)", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00252", "CANT": 2, "EQUIPO": "Adaptador ethernet usb", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00253", "CANT": 1, "EQUIPO": "receptor sony", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00254", "CANT": 10, "EQUIPO": "Pisa cables", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00255", "CANT": 2, "EQUIPO": "microfono lavalier", "OBSERVACIONES": "VPNRED095"}, {"ID": "INV_ALT_2020001", "CANT": 1, "EQUIPO": "Cable largo para starlink", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020002", "CANT": 1, "EQUIPO": "Cable ethernet corto", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020003", "CANT": 6, "EQUIPO": "Cable ethernet largo", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020004", "CANT": 1, "EQUIPO": "Caja con cables ethernet", "OBSERVACIONES": ""}]
267	202	Jornadas de la paz	[{"ID": "INV_VPRO_ALT_00242", "CANT": 2, "EQUIPO": "Antena starlink 03, 02", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00243", "CANT": 1, "EQUIPO": "UPS (No break) Koblenz", "OBSERVACIONES": "VPNRED099"}, {"ID": "INV_VPRO_ALT_00244", "CANT": 1, "EQUIPO": "Mesa pequeÃÂÃÂÃÂÃÂ±a", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "CANT": 1, "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "CANT": 1, "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00248", "CANT": 1, "EQUIPO": "ExtensiÃÂÃÂÃÂÃÂ³n elÃÂÃÂÃÂÃÂ©ctrica corta", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00250", "CANT": 1, "EQUIPO": "TripiÃÂÃÂÃÂÃÂ© para bocina (sin tubo extensor)", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00252", "CANT": 2, "EQUIPO": "Adaptador ethernet usb", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00254", "CANT": 10, "EQUIPO": "Pisa cables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020001", "CANT": 1, "EQUIPO": "Cable largo para starlink", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020002", "CANT": 1, "EQUIPO": "Cable ethernet corto", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020003", "CANT": 6, "EQUIPO": "Cable ethernet largo", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00189", "CANT": 1, "EQUIPO": "Pinza ponchadora", "OBSERVACIONES": "None"}, {"ID": "Inv_alt_2020005", "CANT": 2, "EQUIPO": "Swich de 8 puerto", "OBSERVACIONES": "[CUST_EQ:Swich de 8 puerto] None"}]
270	201	KIT_STD_EVENTOS_FUERA_DE_OFICINAS	[{"ID": "INV_VPRO_ALT_00013", "EQUIPO": "Laptop Asus con adaptador de red y cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00016", "EQUIPO": "Access Point TP-Link modelo  AX3600", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00017", "EQUIPO": "Switch de 5 puertos metalico", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00018", "EQUIPO": "Switch de 5 puertos de plastico negro", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00019", "EQUIPO": "Caja grande c/tapa azul con 50 cables cortos y largos", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00021", "EQUIPO": "Pinza para ponchar cables ethernet", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00022", "EQUIPO": "plugs para cables ethernet", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00023", "EQUIPO": "pisacables", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "EQUIPO": "Tripie", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00025", "EQUIPO": "UPS", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00092", "EQUIPO": "escalera plegable", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2010001", "EQUIPO": "Tablet samsung para monitoreo", "OBSERVACIONES": ""}]
286	104	Cesavesin Mazatlan Simposium	[{"ID": "INV_VPRO_ALT_00153", "EQUIPO": "Mesa", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00060", "EQUIPO": "Corral", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00061", "EQUIPO": "Tela Corral", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00174", "EQUIPO": "CableHDMI", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00210", "EQUIPO": "Extenciones", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00042", "EQUIPO": "Pantalla  55\\"", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00084", "EQUIPO": "Pantalla de 40\\"", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16514", "EQUIPO": "Pisa Cables Yellow Jacket", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00081", "EQUIPO": "Base de Madera Tv", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00055", "EQUIPO": "Base de Fierro Alta", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00085", "EQUIPO": "Tela de Base", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_17765", "EQUIPO": "base de guitarra", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00230", "EQUIPO": "Diablito", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00161", "EQUIPO": "Distribuidor 1 a 4", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00177", "EQUIPO": "Distribuidor HDMI 1 a 2", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190002", "EQUIPO": "distribuidores SDI", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00069", "EQUIPO": "Cable de Fibra Optica", "OBSERVACIONES": ""}]
374	109	Grito de la independencia	[{"ID": "VPRO_ALT_26418", "EQUIPO": "HUB 1x7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26433", "EQUIPO": "HUB 1X6", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26379", "EQUIPO": "HUB USB", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090034", "EQUIPO": "ADAPTADOR USBC-HDMI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090035", "EQUIPO": "SPLITTER 1X3 OREI", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_26708", "EQUIPO": "APUNTADOR", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090036", "EQUIPO": "MINI CONSOLA STEREN", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26591", "EQUIPO": "PEAVEY", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090037", "EQUIPO": "STREAM DEACK", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090038", "EQUIPO": "MAC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090039", "EQUIPO": "CAPTURADORAS USB", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090040", "EQUIPO": "CONVERTIDORES SDI-HDMI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090041", "EQUIPO": "CONVERTIDOR BIMODAL BLACKMAGIC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090042", "EQUIPO": "RECEPTORES SONY", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090026", "EQUIPO": "TRANSMISORES SONY", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090043", "EQUIPO": "CABLE SDI 7 MTS", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090044", "EQUIPO": "CABLE SDI CORTO", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00211", "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090045", "EQUIPO": "ATEM MINI PRO SDI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090028", "EQUIPO": "MONITOR STEREN", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090046", "EQUIPO": "DIADEMA DE COMUNICACION", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090047", "EQUIPO": "DIADEMA DE AUDIO", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090048", "EQUIPO": "DIADEMA DE OSIEL", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130013", "EQUIPO": "CABLE XLR", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090049", "EQUIPO": "MICROFONO SHURE CON PEDESTAL Y CABLE", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090031", "EQUIPO": "LAPTOP G7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26256", "EQUIPO": "CAJA vMix", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090027", "EQUIPO": "CONSOLA ZEDI 8", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090050", "EQUIPO": "BOCINA PREOSUND CON CABLES", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190052", "EQUIPO": "DIADEMAS", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090051", "EQUIPO": "EXTENSORES USB", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090052", "EQUIPO": "LAPTOP", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090053", "EQUIPO": "CABLES DE RED", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090054", "EQUIPO": "MONITOR HDMI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090055", "EQUIPO": "RAC CON SWITCHER", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090056", "EQUIPO": "PANEL DE 20 ENTRADAS", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090057", "EQUIPO": "THREEPLAY CON CONTROL, TECLADO Y MOUSE", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090058", "EQUIPO": "HC 200 AUDIFONOS", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090059", "EQUIPO": "MESAS", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00198", "EQUIPO": "MONITORES", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090060", "EQUIPO": "XLR LARGO", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090061", "EQUIPO": "SOPORTE PARA GUITARRA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090062", "EQUIPO": "ZEDI 10", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090063", "EQUIPO": "Rac con 2 grabadoras \\"IMPERDEC Y SD\\"", "OBSERVACIONES": "[CUST_EQ:Rac con 2 grabadoras \\"IMPERDEC Y SD\\"]"}, {"ID": "Inv_alt_1090064", "EQUIPO": "IMPERDEC", "OBSERVACIONES": "[CUST_EQ:IMPERDEC]"}]
296	202	CESAVESIN en Mazatlán	[{"ID": "INV_ALT_2020009", "EQUIPO": "Caja grande c/tapa azul con cables ethernet cortos y largos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020010", "EQUIPO": "Kit convertidor de medios ethernet a fibra VPNRED112", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00189", "EQUIPO": "Pinza ponchadora passthrough", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020011", "EQUIPO": "Cable de fibra óptica 120 mts completo con terminales SC/APC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020012", "EQUIPO": "Adaptadores SC/PC a SC/PC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020013", "EQUIPO": "UPS/Nobreak HIKVISION VPNRED077", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020014", "EQUIPO": "Tableta Smasung Galaxy Tabl A9 (color grafito) con adaptador de energía, cable de corriente y protector. VPNRED071", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020015", "EQUIPO": "Frasco con terminales utp cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020016", "EQUIPO": "KIT (2) Adaptadores Starlink SPX a RJ45 para generación 2", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00026", "EQUIPO": "Cable especial ethernet para StarLink (50 mts)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020017", "EQUIPO": "Equipo Celular Samsung SM-A307G #6672173818 VPNRED 027", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00016", "EQUIPO": "Access Point TP-Link modelo  AX3600 VPNRED018", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020018", "EQUIPO": "Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED056", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020019", "EQUIPO": "Adaptadores eth a eth cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020021", "EQUIPO": "Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020022", "EQUIPO": "Starlink #2 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020023", "EQUIPO": "Laptop HP Elitebook 845 G7 Notebook PC, con cargador VPNCOM007", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020024", "EQUIPO": "Laptop Asus Vivobook 15\\" D1502IA-BQ179W Ryzen 5 8GB RAM 256GB SSD con cargador VPNRED033", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020025", "EQUIPO": "Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED057", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020026", "EQUIPO": "Switch tp-link 8 puertos VPNRED095", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020027", "EQUIPO": "Switch tp-link 8 puertos VPNRED096", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2020028", "EQUIPO": "Escalera pegable", "OBSERVACIONES": "[CUST_EQ:Escalera pegable]"}]
377	201	Kit_grito	[{"ID": "INV_VPRO_ALT_00021", "EQUIPO": "Pinza para ponchar cables ethernet", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010004", "EQUIPO": "frasco con plugs cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020009", "EQUIPO": "Caja grande c/tapa azul con cables ethernet cortos y largos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010009", "EQUIPO": "INV_VPRO_ALT_00013 - Laptop Asus con adaptador de red y cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00017", "EQUIPO": "Switch de 5 puertos metalico cod VPNRED051", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010008", "EQUIPO": "Switch de 5 puertos de plastico negro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010010", "EQUIPO": "VPNPRO152 - Laptop Del #2 Inspiron G7 7700 Gaming 17.3\\" Intel Core i5 10300H Disco duro 512 GB SSD Ram 8GB Winsows 10 Home, Mause y cargador", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00013", "EQUIPO": "Laptop Asus con adaptador de red y cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020021", "EQUIPO": "Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": "Maleta dañada, ya se reportó./Via O Equio con daño"}]
376	104	Dia del grito	[{"ID": "INV_ALT_1040007", "EQUIPO": "Caja azul con SDI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040008", "EQUIPO": "Caja con Extensiones", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040009", "EQUIPO": "Caja de fibra", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190050", "EQUIPO": "SDI", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00071", "EQUIPO": "Fibra caja", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040010", "EQUIPO": "Multicontactos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040011", "EQUIPO": "Grabadora", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130011", "EQUIPO": "Sillas", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00216", "EQUIPO": "Carpa", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00023", "EQUIPO": "Pisacables", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00216", "EQUIPO": "Carpa", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040012", "EQUIPO": "Voltimetro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040013", "EQUIPO": "Mesita", "OBSERVACIONES": ""}]
307	201	Kit_p_enlace_webex	[{"ID": "INV_VPRO_ALT_00023", "EQUIPO": "pisacables", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00181", "EQUIPO": "Extension electrica", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00018", "EQUIPO": "Switch de 5 puertos de plastico negro NCA TP-LINK", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00017", "EQUIPO": "Switch de 5 puertos metalico cod VPNRED051", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010002", "EQUIPO": "cables largos azules cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010003", "EQUIPO": "cables cortos ethernet cat 6", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00168", "EQUIPO": "pinza ponchadora", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010004", "EQUIPO": "frasco con plugs cat 6", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00013", "EQUIPO": "Laptop Asus con adaptador de red y cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010005", "EQUIPO": "Laptop HP Elitebook 845 G7 Notebook con cargador y maletín CODIGO VPNPRO125", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00243", "EQUIPO": "UPS (No break) Koblenz CODIGO VPNRED099", "OBSERVACIONES": ""}]
308	113	Enlace Presidenta	[{"ID": "INV_ALT_1130004", "EQUIPO": "Pilas AA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130005", "EQUIPO": "Kit microfono Lavalier", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130006", "EQUIPO": "Camara x320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00237", "EQUIPO": "Baterias Sony", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130007", "EQUIPO": "Tripie con chancla", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130008", "EQUIPO": "Kit de iluminacion 2000", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090001", "EQUIPO": "Century", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050003", "EQUIPO": "Pantalla de 50\\"", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00175", "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130009", "EQUIPO": "HDMI 50 MTS", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130010", "EQUIPO": "SDI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130011", "EQUIPO": "Barra de contactos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "Cinta gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130012", "EQUIPO": "Microfono de mano", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130013", "EQUIPO": "Cable XLR", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130014", "EQUIPO": "Bocina de audio con cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130015", "EQUIPO": "Cable XLR largo", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050006", "EQUIPO": "Base de fierro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1130016", "EQUIPO": "Distribuidores", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00201", "EQUIPO": "Balanceador", "OBSERVACIONES": ""}]
310	119	KIT 3 CAMARAS OK	[{"ID": "INV_VPRO_ALT_00045", "EQUIPO": "camaras 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00001", "EQUIPO": "tripies", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "EQUIPO": "baterias", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00099", "EQUIPO": "radios", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00101", "EQUIPO": "dollys", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00102", "EQUIPO": "monitor de ingeneria", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00103", "EQUIPO": "monitor lilliput", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00104", "EQUIPO": "bancos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190001", "EQUIPO": "escaladores", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190002", "EQUIPO": "distribuidores SDI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190003", "EQUIPO": "RACK con SW, grabadora SD, grabadora imperdec,", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190004", "EQUIPO": "RACK con 4 grabadoras", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190005", "EQUIPO": "mochila negra", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "Cinta gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190007", "EQUIPO": "bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190008", "EQUIPO": "microconverter bidireccional", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190009", "EQUIPO": "imperdecs", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190010", "EQUIPO": "memorias SD", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190011", "EQUIPO": "microconverter SDI A HDMI con su A/C", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190012", "EQUIPO": "microconverter HDMI A SDI con su A/C", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190013", "EQUIPO": "lector de memorias para SD con su cable USB", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190014", "EQUIPO": "lector de memorias para imperdec con su cable USB y A/C", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190015", "EQUIPO": "laptop acer azul", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190016", "EQUIPO": "cables SDI cortos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190017", "EQUIPO": "cables HDMI cortos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190018", "EQUIPO": "cables de corriente negros cortos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190019", "EQUIPO": "barras de energia balnacas chicas", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190020", "EQUIPO": "cable negro USB-A a USB-B", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190021", "EQUIPO": "cables de HDMI a MINI HDMI (NEGRO Y ROJO)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190022", "EQUIPO": "cajita naranja con conectores y coples (HDMI 6, SDI 7, TE SDI 3)", "OBSERVACIONES": ""}]
314	119	KIT BASICO 3 CAMARAS	[{"ID": "INV_VPRO_ALT_00045", "EQUIPO": "camaras 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00001", "EQUIPO": "tripies", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "EQUIPO": "baterias", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00099", "EQUIPO": "radios", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00101", "EQUIPO": "dollys", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00102", "EQUIPO": "monitor de ingeneria", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00103", "EQUIPO": "monitor lilliput", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00104", "EQUIPO": "bancos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190001", "EQUIPO": "escaladores", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190002", "EQUIPO": "distribuidores SDI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190005", "EQUIPO": "mochila negra", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "Cinta gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190007", "EQUIPO": "bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190008", "EQUIPO": "microconverter bidireccional", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190011", "EQUIPO": "microconverter SDI A HDMI con su A/C", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190012", "EQUIPO": "microconverter HDMI A SDI con su A/C", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190016", "EQUIPO": "cables SDI cortos (6 de 1 m, 2 de 1/2 m, 1 de 5 m, 1 de 11 m )", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190017", "EQUIPO": "cables HDMI cortos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190018", "EQUIPO": "cables de corriente negros cortos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190019", "EQUIPO": "barras de energia balnacas chicas", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190020", "EQUIPO": "cable negro USB-A a USB-B", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190021", "EQUIPO": "cables de HDMI a MINI HDMI (NEGRO Y ROJO)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190022", "EQUIPO": "cajita naranja con conectores y coples (HDMI 6, SDI 7, TE SDI 3)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190023", "EQUIPO": "baterias NP-F970 para monitor", "OBSERVACIONES": ""}]
315	202	IEES en estudio de Vpro	[{"ID": "INV_ALT_2020014", "EQUIPO": "Tableta Smasung Galaxy Tabl A9 (color grafito) con adaptador de energía, cable de corriente y protector. VPNRED071", "OBSERVACIONES": ""}]
316	109	KIT CESAVESIN	[{"ID": "VPRO_ALT_26448", "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26466", "EQUIPO": "Cables XLR", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26493", "EQUIPO": "Convertidor blackmagic bimodal", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26522", "EQUIPO": "Convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26558", "EQUIPO": "Convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": "Uno de los adaptadores no lleva AC"}, {"ID": "VPRO_ALT_26591", "EQUIPO": "Interfase Peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "EQUIPO": "Stream Deck El Gato", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26673", "EQUIPO": "Adaptador tipo C a HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26703", "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090014", "EQUIPO": "Transmisor de audio SONY VPNAUD009", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090015", "EQUIPO": "Receptor de audio SONY VPNAUD008", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090032", "EQUIPO": "Equipo no registrado", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090016", "EQUIPO": "Microfono de solapa SONY VPNAUD009", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090017", "EQUIPO": "Diademas de comunicación BEHRINGER VPNAUD065", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090018", "EQUIPO": "Diadema de comunicación SONY VPNAUD019", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26379", "EQUIPO": "hub USB", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26418", "EQUIPO": "hub 1x7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26433", "EQUIPO": "hub 1x6", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26256", "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26302", "EQUIPO": "Atem SDI PRO ISO", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26326", "EQUIPO": "Consola audio (mini vMix)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26346", "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26361", "EQUIPO": "mac #3 y #4", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00253", "EQUIPO": "Receptor SONY VPNAUD001", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00255", "EQUIPO": "Microfono Lavalier SONY VPNAUD001", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090021", "EQUIPO": "Transmisor SONY VPNAUD001", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090023", "EQUIPO": "Bocina con Cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090027", "EQUIPO": "Consola ZEDI 8", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00231", "EQUIPO": "Cables SDI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090028", "EQUIPO": "MONITOR STEREN", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090030", "EQUIPO": "Maleta de laptop", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090031", "EQUIPO": "Laptop g7", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_26708", "EQUIPO": "apuntador", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190010", "EQUIPO": "Memorias SD", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090032", "EQUIPO": "RAC de grabación", "OBSERVACIONES": "[CUST_EQ:RAC de grabación]"}]
317	105	KIT LEY GRABACION	[{"ID": "INV_VPRO_ALT_00166", "EQUIPO": "UPS", "OBSERVACIONES": ""}]
318	109	IEES VIRTUAL (Estudio VPro)	[{"ID": "VPRO_ALT_26361", "EQUIPO": "Mac #3 Mac #4", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26379", "EQUIPO": "Hub USB", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26418", "EQUIPO": "Hub 1x7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26433", "EQUIPO": "Hub 1x6", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26448", "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26466", "EQUIPO": "cables XLR", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26493", "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26522", "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26591", "EQUIPO": "peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "EQUIPO": "stream deck", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26673", "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_11376", "EQUIPO": "VMIX de Estudio, cpu de escritorio", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090033", "EQUIPO": "Convertidor C-HDMI", "OBSERVACIONES": "[CUST_EQ:Convertidor C-HDMI]"}]
378	202	Grito de independencia 2026	[{"ID": "INV_ALT_2020023", "EQUIPO": "Laptop HP Elitebook 845 G7 Notebook PC, con cargador VPNCOM007", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020018", "EQUIPO": "Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED056", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020025", "EQUIPO": "Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED057", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020017", "EQUIPO": "Equipo Celular Samsung SM-A307G #6672173818 VPNRED 027", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00189", "EQUIPO": "Pinza ponchadora passthrough", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020015", "EQUIPO": "Frasco con terminales utp cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020019", "EQUIPO": "Adaptadores eth a eth cat 6", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00149", "EQUIPO": "Bolsa con cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020012", "EQUIPO": "Adaptadores SC/PC a SC/PC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020031", "EQUIPO": "Extension de USB", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00016", "EQUIPO": "Access Point TP-Link modelo  AX3600 VPNRED018", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020011", "EQUIPO": "Cable de fibra óptica 120 mts completo con terminales SC/APC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020010", "EQUIPO": "Kit convertidor de medios ethernet a fibra VPNRED112", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020033", "EQUIPO": "Cutter trupper", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020034", "EQUIPO": "Tripié para bocina sin tubo extersor", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00026", "EQUIPO": "Cable especial ethernet para StarLink (50 mts)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020013", "EQUIPO": "UPS/Nobreak HIKVISION VPNRED077", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00092", "EQUIPO": "Escalera de tijera grande", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020037", "EQUIPO": "VPNRED-SWITCH10/100 - Switch ethernet tp-link 10/100 tl-sf1016D (VPNRED-SWITCH10/100)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020022", "EQUIPO": "Starlink #2 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2020039", "EQUIPO": "VPNRED060 - Modem de internet ZTE Megacable VPNRED060", "OBSERVACIONES": "[CUST_EQ:VPNRED060 - Modem de internet ZTE Megacable VPNRED060]"}]
379	105	Grito de independecia	[{"ID": "INV_ALT_1050008", "EQUIPO": "luces", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090001", "EQUIPO": "Century", "OBSERVACIONES": ""}]
380	119	DIA DEL GRITO	[{"ID": "INV_ALT_1190007", "EQUIPO": "Bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190068", "EQUIPO": "Rollo de alambre", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190069", "EQUIPO": "Micro convertidor", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190070", "EQUIPO": "Cargador Sony para baterías NP", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190071", "EQUIPO": "Cargador para baterias 320", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190055", "EQUIPO": "Baterías ZGCINE", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190056", "EQUIPO": "Baterías GL95", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190057", "EQUIPO": "Baterías L90", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190058", "EQUIPO": "Baterías NP", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00102", "EQUIPO": "Monitor de ingeneria", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190059", "EQUIPO": "Forros para cámaras", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00099", "EQUIPO": "Radios", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190053", "EQUIPO": "Cámara 320", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190054", "EQUIPO": "Sombrilla", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "EQUIPO": "Tripie", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190060", "EQUIPO": "MiniBlackMagic", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190042", "EQUIPO": "Monitores liliput", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00205", "EQUIPO": "Escaladores decimator", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00201", "EQUIPO": "Balanceador", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00227", "EQUIPO": "Multicontactos", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00104", "EQUIPO": "Bancos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190061", "EQUIPO": "Cables SDI NEGROS 1 METRO", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190005", "EQUIPO": "mochila negra", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190062", "EQUIPO": "SDI varios tamaños", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190063", "EQUIPO": "Corriente", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190064", "EQUIPO": "HDMI cortos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190065", "EQUIPO": "USB-USB C", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190066", "EQUIPO": "USB cables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190067", "EQUIPO": "USB tipo b", "OBSERVACIONES": ""}]
381	104	Evento presidenta	[{"ID": "INV_VPRO_ALT_00151", "EQUIPO": "Cables HDMI", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00175", "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00231", "EQUIPO": "Cables SDI", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1040014", "EQUIPO": "Distribuidor de 4\\"", "OBSERVACIONES": "[CUST_EQ:Distribuidor de 4\\"]"}, {"ID": "Inv_alt_1040015", "EQUIPO": "Distribuidor de 2\\"", "OBSERVACIONES": "[CUST_EQ:Distribuidor de 2\\"]"}, {"ID": "VPRO_ALT_17836", "EQUIPO": "Monitor de 65\\"", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00220", "EQUIPO": "Base metal para monitor", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_17765", "EQUIPO": "Base de guitarra", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00023", "EQUIPO": "Pisacables", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1040016", "EQUIPO": "Mesa pegable", "OBSERVACIONES": "[CUST_EQ:Mesa pegable]"}, {"ID": "VPRO_ALT_74716", "EQUIPO": "Abanico", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1040017", "EQUIPO": "Multicontaco", "OBSERVACIONES": "[CUST_EQ:Multicontaco]"}, {"ID": "Inv_alt_1040018", "EQUIPO": "Cable de red", "OBSERVACIONES": "[CUST_EQ:Cable de red]"}]
382	109	Evento Presidenta	[{"ID": "INV_ALT_1090031", "EQUIPO": "Laptop G7", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090065", "EQUIPO": "HDMI SPLITTER 1X2 OREI", "OBSERVACIONES": "[CUST_EQ:HDMI SPLITTER 1X2 OREI]"}, {"ID": "Inv_alt_1090066", "EQUIPO": "Consola audio mini vMix", "OBSERVACIONES": "[CUST_EQ:Consola audio mini vMix]"}, {"ID": "VPRO_ALT_26346", "EQUIPO": "Capturadoras HDMI", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090038", "EQUIPO": "Mac", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00151", "EQUIPO": "Cables HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26418", "EQUIPO": "Hub 1X7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26433", "EQUIPO": "Hub 1X6", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26379", "EQUIPO": "Hub USB", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26591", "EQUIPO": "Peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "EQUIPO": "Stream Deck", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090067", "EQUIPO": "Decimator", "OBSERVACIONES": "[CUST_EQ:Decimator]"}, {"ID": "INV_VPRO_ALT_00231", "EQUIPO": "Cables SDI", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1090068", "EQUIPO": "Convertidores", "OBSERVACIONES": "[CUST_EQ:Convertidores]"}, {"ID": "Inv_alt_1090069", "EQUIPO": "Bidireccional", "OBSERVACIONES": "[CUST_EQ:Bidireccional]"}]
336	201	Jornadas de paz basico	[{"ID": "INV_VPRO_ALT_00023", "EQUIPO": "pisacables", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "EQUIPO": "tripie", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00181", "EQUIPO": "Extension electrica", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00021", "EQUIPO": "Pinza para ponchar cables ethernet", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020015", "EQUIPO": "Frasco con terminales utp cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020021", "EQUIPO": "Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010006", "EQUIPO": "UPS (No break) Koblenz CODIGO VPNRED097", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2010007", "EQUIPO": "Switch de 5 puertos metalico", "OBSERVACIONES": "[CUST_EQ:Switch de 5 puertos metalico]"}, {"ID": "INV_VPRO_ALT_00018", "EQUIPO": "Switch de 5 puertos de plastico negro NCA TP-LINK", "OBSERVACIONES": ""}]
337	202	TEBACAS	[{"ID": "INV_ALT_2020009", "EQUIPO": "Caja grande c/tapa azul con cables ethernet cortos y largos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020026", "EQUIPO": "Switch tp-link 8 puertos VPNRED095", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020027", "EQUIPO": "Switch tp-link 8 puertos VPNRED096", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020029", "EQUIPO": "Encoder kiloview E3", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020030", "EQUIPO": "Cables SDI 1mt", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020024", "EQUIPO": "Laptop Asus Vivobook 15\\" D1502IA-BQ179W Ryzen 5 8GB RAM 256GB SSD con cargador VPNRED033", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020023", "EQUIPO": "Laptop HP Elitebook 845 G7 Notebook PC, con cargador VPNCOM007", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020018", "EQUIPO": "Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED056", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020025", "EQUIPO": "Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED057", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020017", "EQUIPO": "Equipo Celular Samsung SM-A307G #6672173818 VPNRED 027", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00189", "EQUIPO": "Pinza ponchadora passthrough", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020015", "EQUIPO": "Frasco con terminales utp cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020019", "EQUIPO": "Adaptadores eth a eth cat 6", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00149", "EQUIPO": "Bolsa con cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020012", "EQUIPO": "Adaptadores SC/PC a SC/PC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020031", "EQUIPO": "Extension de USB", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00016", "EQUIPO": "Access Point TP-Link modelo  AX3600 VPNRED018", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020011", "EQUIPO": "Cable de fibra óptica 120 mts completo con terminales SC/APC", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020010", "EQUIPO": "Kit convertidor de medios ethernet a fibra VPNRED112", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020032", "EQUIPO": "Teradek BOND PRO con estuche VPNRED012", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020033", "EQUIPO": "Cutter trupper", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020034", "EQUIPO": "Tripié para bocina sin tubo extersor", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00026", "EQUIPO": "Cable especial ethernet para StarLink (50 mts)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020035", "EQUIPO": "UPS (No-Break) Koblenz CODIGO VPNRED100", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020013", "EQUIPO": "UPS/Nobreak HIKVISION VPNRED077", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020021", "EQUIPO": "Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020022", "EQUIPO": "Starlink #2 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00092", "EQUIPO": "Escalera Plegable", "OBSERVACIONES": ""}, {"ID": "Inv_alt_2020036", "EQUIPO": "Audifonos behringer HC200", "OBSERVACIONES": "[CUST_EQ:Audifonos behringer HC200]"}]
342	201	Juegos Tebacas	[{"ID": "INV_VPRO_ALT_00012", "EQUIPO": "Computadora de escritorio con dos monitores", "OBSERVACIONES": "⚠️ [LLEVA DAÑO REPORTADO]"}]
343	104	Reunion de gabinete	[{"ID": "Inv_alt_1040004", "EQUIPO": "Pantalla de 65\\"", "OBSERVACIONES": "[CUST_EQ:Pantalla de 65\\"]"}, {"ID": "INV_VPRO_ALT_00055", "EQUIPO": "Base de fierro Alta", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00052", "EQUIPO": "Cable HDMI", "OBSERVACIONES": ""}, {"ID": "Inv_alt_1040005", "EQUIPO": "Distribuidores 1x4", "OBSERVACIONES": "[CUST_EQ:Distribuidores 1x4]"}, {"ID": "Inv_alt_1040006", "EQUIPO": "Distribuidores 1x2", "OBSERVACIONES": "[CUST_EQ:Distribuidores 1x2]"}, {"ID": "INV_VPRO_ALT_00175", "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00065", "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00023", "EQUIPO": "Pisacables", "OBSERVACIONES": ""}]
345	113	JAPAC	[{"ID": "Inv_alt_1130017", "EQUIPO": "Cámara FS7", "OBSERVACIONES": "[CUST_EQ:Cámara FS7]"}, {"ID": "Inv_alt_1130018", "EQUIPO": "Alpha", "OBSERVACIONES": "[CUST_EQ:Alpha]"}]
346	105	JAPAC	[{"ID": "INV_VPRO_ALT_00237", "EQUIPO": "Baterias Sony", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050007", "EQUIPO": "Baterias Z", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040001", "EQUIPO": "Kit de luces", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00001", "EQUIPO": "TRIPIES", "OBSERVACIONES": ""}]
350	119	KIT TEBACAS	[{"ID": "INV_VPRO_ALT_00045", "EQUIPO": "camaras 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "EQUIPO": "baterias", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00099", "EQUIPO": "radios", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190037", "EQUIPO": "lampara portatil con una bateria", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190038", "EQUIPO": "micrófono de maraca", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190039", "EQUIPO": "atem sdi", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190034", "EQUIPO": "BARRA D EENERGIA", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00151", "EQUIPO": "cables hdmi", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190024", "EQUIPO": "escalador", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190040", "EQUIPO": "baterías para monitor", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190041", "EQUIPO": "monitor de ing.", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190042", "EQUIPO": "monitores liliput", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190043", "EQUIPO": "distribuidor sdi", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190044", "EQUIPO": "monitor 21.5 pulgadas", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00202", "EQUIPO": "Sistema de comunicacion", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190045", "EQUIPO": "memorias sxs", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190046", "EQUIPO": "cámaras miniblack", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190047", "EQUIPO": "cables sdi largos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190048", "EQUIPO": "lineas de audio largas", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190049", "EQUIPO": "microfonos para ambiente", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190029", "EQUIPO": "lineas de energia", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190006", "EQUIPO": "cinta gris", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190007", "EQUIPO": "bolsa de cinchos", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190050", "EQUIPO": "pizacables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190051", "EQUIPO": "Trpies", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190052", "EQUIPO": "Diademas", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020036", "EQUIPO": "Audifonos behringer HC200", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00153", "EQUIPO": "Mesa", "OBSERVACIONES": ""}]
351	201	Jornadas de paz	[{"ID": "INV_VPRO_ALT_00181", "EQUIPO": "Extension electrica", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020021", "EQUIPO": "Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010006", "EQUIPO": "UPS (No break) Koblenz CODIGO VPNRED097", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00093", "EQUIPO": "cable especial de 50 mts de starlink", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020003", "EQUIPO": "Cable ethernet largo", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00139", "EQUIPO": "Cables ethernet cortos", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00021", "EQUIPO": "Pinza para ponchar cables ethernet", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010004", "EQUIPO": "frasco con plugs cat 6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010007", "EQUIPO": "Switch de 5 puertos metalico", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010008", "EQUIPO": "Switch de 5 puertos de plastico negro", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "EQUIPO": "Tripie", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00254", "EQUIPO": "Pisa cables", "OBSERVACIONES": ""}]
\.


--
-- Data for Name: mantenimiento_equipos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mantenimiento_equipos (id_solicitud, num_servicio, fecha_reporte, folio_vpro, estatus_proceso, codigo_equipo, area_pertenece, marca, modelo, num_serie, responsable_actual, quien_reporta, responsiva_anterior, "descripcion_daño", tipo_accion, detalles_reparacion, encargado_reparacion, quien_recibe_equipo, fecha_entrada_taller, fecha_entrega_estimada, costo_reparacion, cotizacion_1, cotizacion_2, cotizacion_3, cotizacion_seleccionada, fecha_pago, fecha_llegada_nuevo, nueva_responsiva, firmas_digitales, registrado_por) FROM stdin;
\.


--
-- Data for Name: plantillas_checkout; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plantillas_checkout (id_plantilla, nombre_kit, departamento, codigo_equipo, cantidad) FROM stdin;
\.


--
-- Data for Name: reuniones_previas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reuniones_previas (id_reunion, fecha_reunion, cliente_tentativo, nombre_proyecto_tentativo, asistentes, minuta_acuerdos, presupuesto_estimado, fecha_probable_evento, estatus_proyecto, fecha_registro, folio_op_generado) FROM stdin;
8	2026-09-12	Gobierno del estado de sinaloa	Instalación el 14 de septiembre para el grito de la independencia	Pedro Villarreal, Ana Lilia Villarreal, Andrea Villarreal, Sofia Villarreal, Martin Estrada, Manuel Madrid y Manuel Eduardo Madrid	Resumen\nTema 1: Seguimiento para la instalación del evento del grito de la independencia\n\nAcuerdos y compromisos finales\nSe acordó que el lunes 14 de septiembre de 2026 se instalara en el palacio de gobierno\nSe acordó que a las 9:00 am será la entrada a oficina y cargaran equipo\nSe acordó que se unirán al llamado los externos Eduardo y Calixto con entrada de 11:00 pm en el palacio de gobierno.\nSe acordó que el corte a comer será de 2:00 pm a 4:00 pm y regresando del corte a comer se regresan a instalar en el palacio de gobierno\nSe acordó comprar agua para la hidratación del personal de producción que asistirá a instalar\nSe acordó tener sombrillas por alguna emergencia de cambio climático como lluvias\nSe acordó el 12 de septiembre de 2026 hacer el llamado para el  14 de septiembre de 2026\nSe acordó cargar gasolina el lunes 14 de septiembre\n	0.00	2026-09-14	CONVERTIDO A OP	2026-09-12 14:16:54.261971	19
4	2026-08-13	H.ayuntamiento Badiraguato	Reunión para eventos basquetbol de TEBACAS. 	Pedro Villarreal, Manuel Madrid, Manuel Eduardo Madrid, Sofia Villarreal, Andrea Villarreal, Edgar Amarillas	Resumen de la reunión\nTema 1: La reunión tuvo como objetivo dar seguimiento y revisar los avances relacionados con los eventos de TEBACAS\nTema 2: Dar seguimiento a la operación y contenidos de los canales de VPRO Sports.\n\nAcuerdos y compromisos finales\n1.\tEl Sr. Pedro Villarreal se pondrá en contacto con TVC Deportes para coordinar la transmisión de los eventos de basquetbol de TEBACAS a través de los canales de VPRO Sports.\n2.\tSe acordó verificar la disponibilidad de los permisos necesarios para realizar las transmisiones a través de YouTube, Facebook e Instagram.\n3.\tSe acordó dar seguimiento al canal de VPRO Sports y actualizar el banner de la página de Facebook.\n4.\tSe acordó retomar y dar seguimiento a las cuentas de TikTok e Instagram. \n	0.00	2026-09-04	CONVERTIDO A OP	2026-09-12 11:02:17.264301	11
3	2026-08-31	H.ayuntamiento Badiragutao	Reunión para el arranque de los partidos de TEBACAS	Pedro Villarreal, Manuel Madrid, Martin Estrada, Gerardo Villarreal, Manuel Eduardo Madrid, Andrea Villarreal,  Francisco Torres, Edgar Amarillas, Osiel Hernández y Carlos Quezada	Resumen de la reunión\nTema 1: Salida a Badiraguato para realizar scouting y hacer pruebas para los partidos de TEBACAS.\nTema 2: Ajustar últimos detalles y aclarar últimas dudas para el inicio de los partidos de TEBACAS.\nAcuerdos y compromisos finales\n1.\tSe acordó que el 1 de septiembre de 2026, a las 9:00 a. m., el personal deberá presentarse en la oficina para posteriormente trasladarse a Badiraguato, donde se realizará el scouting y las pruebas correspondientes. El equipo deberá estar listo para iniciar las pruebas a la 1:00 p. m.\n2.\tSe acordó dar prioridad al canal de VPRO Sports, así como realizar la transmisión de los juegos a través de las plataformas de Facebook y YouTube.\n3.\tSe acordó que producción llevará 3 cámaras 320 y 2 cámaras Blackmagic.\n4.\tSe acordó que el Switcher Osiel Hernández dejará preparado el equipo de audio para que Francisco Torres se encargue del monitoreo del audio.\n5.\tSe acordó que Lupita, del área de Comunicación Social del Ayuntamiento de Badiraguato, notificará que VPRO Sports realizará tomas aéreas con dron durante la cobertura del evento.\n6.\tSe acordó que durante el medio tiempo del primer partido se realizará una entrevista, la cual estará a cargo del conductor Miguel, quien se encontrará en la locación.\n7.\tSe acordó que se instalara el equipo SHARK para regular el audio de video.\n8.\tSe acordó llevar una lámpara para contar con la iluminación adecuada durante la realización de la entrevista.\n9.\t La jefa de edición Andrea Villarreal se comprometió a integrar las tomas en las promociones una vez que reciba el material correspondiente.\n10.\t Se acordó que se realizará solamente una promo. Así como el video de promo y carteles, junto con las portadas y lowers.\n11.\t Se acordó en realizar una escaleta.\n12.\t Se acordó expresar un agradecimiento a Martha Lilia Roque y al ayuntamiento de Badiraguato por el apoyo brindado para el arranque de los partidos de TEBACAS\n13.\t Se acordó hacer un llamado a los conductores y se presenten con anticipación, de acuerdo con el horario previamente establecido, a fin de garantizar la puntualidad y el buen desarrollo de cada evento.\n14.\t Se acordó utilizar doble caja para que se comuniquen los conductores.\n15.\t Se acordó que se utilizarán 2 equipos de vMix call.\n16.\t Se acordó en quitar la música ambiental del estadio durante la transmisión.\n17.\t La jefa de edición Andrea Villarreal se comprometió a preparar y tener disponible la música que se utilizará tanto en el loop como en la introducción de las transmisiones.\n18.\t Se acordó instalar 2 líneas de audio en el estadio con los micrófonos en el suelo.\n19.\t Carlos se comprometió a terminar los CODYS.\n20.\t Se acordó que los conductores deberán portar playeras del mismo color, con el objetivo de mantener una imagen uniforme durante las transmisiones\n21.\t Se acordó que la tela verde del estudio Vpro, la acomodaran ordenadamente.\n22.\t Se compromete el ingeniero Edgar Amarillas en enviar el streaming codificado en H.265 1080p a 2 mb de bitrate a el Switcher Osiel Hernández.\n23.\t Se acordó que el jefe de Producción de Deportes, Manuel Madrid, notificará a Lupita, del área de Comunicación, que su equipo será responsable de proporcionar las pantallas y la laptop necesarias. Asimismo, se brindará apoyo con el cableado que se requiera para la instalación y funcionamiento de los equipos.\n	0.00	2026-09-04	CONVERTIDO A OP	2026-09-12 10:59:40.60497	11
7	2026-09-10	Gobierno del estado de sinaloa	Reunión para evento del grito de la independencia	Martin Estrada, Manuel Madrid, Manuel Eduardo Madrid, Osiel Hernandez, Edgar Amarillas, Francisco Torres, Carlos Quezada y Daniel Torres	Resumen de la reunión\nTema 1: Panificación para evento del día 15 de septiembre grito de la independencia de México.\n\nAcuerdos y compromisos finales\n1.\tSe acordó que producción de Vpro, harán pruebas el 14 de septiembre dependiendo a algún cambio de último momento.\n2.\tSe acordó que a las 4:00 pm del 10 de septiembre de 2026 el ingeniero Edgar Amarillas y el jefe de producción Martin Estrada irán a realizar pruebas de internet en el palacio de gobierno.\n3.\tSe acordó que se solicitaran tarimas de buena calidad.\n4.\tEl jefe de producción de deportes Manuel Madrid se comprometió a tener las 8 comunicaciones para los camarógrafos.\n5.\tSe acordó que se grabara en vMix y una grabadora. Se utilizará la laptop G7.\n6.\tSe acordó que se utilizara para el evento una botonera para las pantallas.\n7.\tSe acordó en buscar música sin derechos para utilizarla.\n	0.00	2026-09-15	CONVERTIDO A OP	2026-09-12 11:20:05.371995	19
6	2026-09-08	H.ayuntamiento Badiraguato	Reunión para dar seguimiento a las incidencias de los eventos de liga de baloncesto del pacifico “TEBACAS”	Pedro Villarreal, Manuel Madrid, Manuel Eduardo Madrid,  Andrea Villarreal, Francisco Torres, Cuauhtemoc Rivera, Edgar Amarillas, Osiel Hernandez, Carlos Quezada, 	Resumen de la reunión\nTema 1: Incidencias en la producción de los partidos de TEBACAS\nTema 2: Cuando se ingresaron los patrocinios se dropeo la transmisión\nAcuerdos y compromisos finales \n1.\tEl ingeniero Edgar Amarillas se comprometió a realizar el traslado de las tarjetas y accesorios a la laptop I9\n2.\tSe acordó que la producción de Vprosports tendrán una mejor comunicación y tendrán un medio fijo para ello.\n3.\tSe acordó que Carlos Quezada de gráficos será el intermediario para la comunicación\n4.\tSe acordó que ajustaran los discos duros y checaran la configuración de la grabadora.\n5.\tSe acordó que harán pruebas de grabación en la computadora una vez ajustando los discos duros.\n6.\tSe acordó tener un protocolo de emergencia.\n7.\tLa jefa de edición Andrea Villarreal se comprometió a tener los separadores y entregar al Switcher Osiel Hernández.\n8.\tEl ingeniero Cuauhtemoc Rivera se compromete a monitorear las transmisiones de los partidos de la liga de baloncesto del pacifico mediante YouTube.\n9.\tSe acordó que el encargado de audio utilizara audífonos para los partidos.\n10.\tEl Switcher Osiel Hernández se comprometió a capacitar a Francisco Torres en audio.\n	0.00	2026-09-27	CONVERTIDO A OP	2026-09-12 11:09:35.56833	11
5	2026-08-17	H.ayuntamiento Badiraguato	Reunión para partidos de basquetbol de TEBACAS	Pedro Villarreal, Manuel Madrid, Manuel Eduardo Madrid, Sofia Villarreal, Andrea Villarreal, Cuauhtemoc Rivera, Edgar Amarillas y Carlos Quezada	Resumen de la reunión\nTema 1: Transmisión de partidos de basquetbol de TEBACAS.\nTema 2: Acordar las fechas de los partidos de basquetbol de TEBACAS.\nAcuerdos y compromisos finales\n1.\tSe acordó las transmisiones por HISPORTS y el canal de VPROSPORTS, junto con su respectiva campaña de promoción.\n2.\tSe acordó que el jefe de producción de deportes Manuel Madrid y el ingeniero Edgar Amarillas se trasladarán el 26 de agosto a la locación de Badiraguato para realizar el scouting de la locación.\n3.\tSe solicitará el apoyo de Gerardo Villarreal para acompañar al equipo de producción a Badiraguato y coordinar el levantamiento de video con dron.\n4.\tEl equipo de redes investigará los requerimientos y la infraestructura de conectividad disponibles en las sedes de los próximos partidos.\n5.\tSe estableció realizar pruebas técnicas de transmisión directamente en la locación seleccionada.\n6.\tSe asignó al equipo de edición la responsabilidad de elaborar los diseños gráficos para los partidos de basquetbol de TEBACAS.\n7.\tSe calendarizaron los partidos de basquetbol para los días 4, 5, 6 y 26 de septiembre, así como el 3, 10 y 16 de octubre.\n8.\t Se determinó contar con dos conductores para la cobertura de los partidos, a excepción de las fechas del 4 y 27 de septiembre, y el 16 de octubre, donde se cubrirá con un solo conductor.\n9.\tEl equipo de edición se comprometió a publicar un resumen en video de cada juego en la página de VPROSPORTS al finalizar el encuentro.\n10.\t Se acordó la producción y publicación de reels en TikTok para dar cobertura a cada uno de los partidos.\n	0.00	2026-09-04	CONVERTIDO A OP	2026-09-12 11:05:15.372223	11
9	2026-09-17	Gobierno del estado de sinaloa	Incidencias del evento grito de independencia	Pedro Villarreal, Martin Estrada, Manuel Madrid, Gerardo Villarreal, Manuel Eduardo Madrid, Osiel Hernández, Cuauhtémoc Rivera y Edgar Amarillas.	Resumen de la reunión\nTema 1: Seguimiento de incidencias del evento grito de independencia.\n\nAcuerdos y compromisos finales \n1.\tSe acordó para próximos eventos contar con ups para cualquier emergencia que suceda.\n2.\tSe acordó checar el mouse ante posibles fallos del equipo 3play.\n3.\tSe acordó montar el Switcher ATEM costellation para hacer pruebas.\n4.\tSe acordó revisar la configuración inicial para que quede grabado.\n5.\tSe acordó que se tendrá más control y organización en los futuros eventos.\n6.\tSe acordó conseguir a un ingeniero de audio más capacitado.\n7.\tSe compromete el personal de producción evitar interrumpir las actividades que se encuentren realizando para acudir en búsqueda de personal externo cuando este requiera algún apoyo, favor o atención. Será responsabilidad del personal externo acercarse o comunicarse directamente con el equipo correspondiente para solicitar el apoyo que necesite.\n	0.00	2026-09-15	CONVERTIDO A OP	2026-09-17 14:27:00.12986	19
\.


--
-- Name: asistencia_locacion_id_asistencia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.asistencia_locacion_id_asistencia_seq', 243, true);


--
-- Name: checkouts_detalle_id_detalle_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.checkouts_detalle_id_detalle_seq', 2455, true);


--
-- Name: checkouts_maestro_id_maestro_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.checkouts_maestro_id_maestro_seq', 46, true);


--
-- Name: eventos_id_evento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.eventos_id_evento_seq', 1, false);


--
-- Name: informes_gastos_detalle_id_detalle_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.informes_gastos_detalle_id_detalle_seq', 59, true);


--
-- Name: informes_gastos_maestro_id_informe_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.informes_gastos_maestro_id_informe_seq', 16, true);


--
-- Name: kits_empleados_id_kit_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kits_empleados_id_kit_seq', 382, true);


--
-- Name: mantenimiento_equipos_id_solicitud_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mantenimiento_equipos_id_solicitud_seq', 1, false);


--
-- Name: plantillas_checkout_id_plantilla_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.plantillas_checkout_id_plantilla_seq', 1, false);


--
-- Name: reuniones_previas_id_reunion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reuniones_previas_id_reunion_seq', 9, true);


--
-- Name: asistencia_locacion asistencia_locacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asistencia_locacion
    ADD CONSTRAINT asistencia_locacion_pkey PRIMARY KEY (id_asistencia);


--
-- Name: checkouts_detalle checkouts_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkouts_detalle
    ADD CONSTRAINT checkouts_detalle_pkey PRIMARY KEY (id_detalle);


--
-- Name: checkouts_maestro checkouts_maestro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkouts_maestro
    ADD CONSTRAINT checkouts_maestro_pkey PRIMARY KEY (id_maestro);


--
-- Name: eventos eventos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eventos
    ADD CONSTRAINT eventos_pkey PRIMARY KEY (id_evento);


--
-- Name: eventos folio; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eventos
    ADD CONSTRAINT folio UNIQUE (folio);


--
-- Name: informes_gastos_detalle informes_gastos_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.informes_gastos_detalle
    ADD CONSTRAINT informes_gastos_detalle_pkey PRIMARY KEY (id_detalle);


--
-- Name: informes_gastos_maestro informes_gastos_maestro_folio_vpro_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.informes_gastos_maestro
    ADD CONSTRAINT informes_gastos_maestro_folio_vpro_key UNIQUE (folio_vpro);


--
-- Name: informes_gastos_maestro informes_gastos_maestro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.informes_gastos_maestro
    ADD CONSTRAINT informes_gastos_maestro_pkey PRIMARY KEY (id_informe);


--
-- Name: kits_empleados kits_empleados_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kits_empleados
    ADD CONSTRAINT kits_empleados_pkey PRIMARY KEY (id_kit);


--
-- Name: mantenimiento_equipos mantenimiento_equipos_num_servicio_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mantenimiento_equipos
    ADD CONSTRAINT mantenimiento_equipos_num_servicio_key UNIQUE (num_servicio);


--
-- Name: mantenimiento_equipos mantenimiento_equipos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mantenimiento_equipos
    ADD CONSTRAINT mantenimiento_equipos_pkey PRIMARY KEY (id_solicitud);


--
-- Name: plantillas_checkout plantillas_checkout_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plantillas_checkout
    ADD CONSTRAINT plantillas_checkout_pkey PRIMARY KEY (id_plantilla);


--
-- Name: reuniones_previas reuniones_previas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reuniones_previas
    ADD CONSTRAINT reuniones_previas_pkey PRIMARY KEY (id_reunion);


--
-- Name: checkouts_maestro unique_op_empleado; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkouts_maestro
    ADD CONSTRAINT unique_op_empleado UNIQUE (folio_op, id_empleado);


--
-- Name: eventos uq_folio; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eventos
    ADD CONSTRAINT uq_folio UNIQUE (folio);


--
-- Name: eventos uq_folio_vpro; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eventos
    ADD CONSTRAINT uq_folio_vpro UNIQUE (folio);


--
-- Name: idx_asistencia_evento; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_asistencia_evento ON public.asistencia_locacion USING btree (id_evento);


--
-- Name: checkouts_detalle checkouts_detalle_id_maestro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkouts_detalle
    ADD CONSTRAINT checkouts_detalle_id_maestro_fkey FOREIGN KEY (id_maestro) REFERENCES public.checkouts_maestro(id_maestro) ON DELETE CASCADE;


--
-- Name: informes_gastos_detalle informes_gastos_detalle_id_informe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.informes_gastos_detalle
    ADD CONSTRAINT informes_gastos_detalle_id_informe_fkey FOREIGN KEY (id_informe) REFERENCES public.informes_gastos_maestro(id_informe) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict b2Mhjex3yWCeaSTPNtM7Ci4nY0lBId1lHsAc3paFsQKvjH5OlVYt5ja7ApD5LoZ

