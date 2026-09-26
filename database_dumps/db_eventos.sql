--
-- PostgreSQL database dump
--

\restrict p81KFHjzDiJycu37ZBidTehZEmsokgQGr73ooIBYvcbnV1vHasbmKoSkKR2du1R

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

ALTER TABLE IF EXISTS ONLY public.informes_gastos_detalle DROP CONSTRAINT IF EXISTS informes_gastos_detalle_id_informe_fkey;
ALTER TABLE IF EXISTS ONLY public.checkouts_detalle DROP CONSTRAINT IF EXISTS checkouts_detalle_id_maestro_fkey;
ALTER TABLE IF EXISTS ONLY public.eventos DROP CONSTRAINT IF EXISTS uq_folio_vpro;
ALTER TABLE IF EXISTS ONLY public.eventos DROP CONSTRAINT IF EXISTS uq_folio;
ALTER TABLE IF EXISTS ONLY public.checkouts_maestro DROP CONSTRAINT IF EXISTS unique_op_empleado;
ALTER TABLE IF EXISTS ONLY public.plantillas_checkout DROP CONSTRAINT IF EXISTS plantillas_checkout_pkey;
ALTER TABLE IF EXISTS ONLY public.mantenimiento_equipos DROP CONSTRAINT IF EXISTS mantenimiento_equipos_pkey;
ALTER TABLE IF EXISTS ONLY public.mantenimiento_equipos DROP CONSTRAINT IF EXISTS mantenimiento_equipos_num_servicio_key;
ALTER TABLE IF EXISTS ONLY public.kits_empleados DROP CONSTRAINT IF EXISTS kits_empleados_pkey;
ALTER TABLE IF EXISTS ONLY public.informes_gastos_maestro DROP CONSTRAINT IF EXISTS informes_gastos_maestro_pkey;
ALTER TABLE IF EXISTS ONLY public.informes_gastos_maestro DROP CONSTRAINT IF EXISTS informes_gastos_maestro_folio_vpro_key;
ALTER TABLE IF EXISTS ONLY public.informes_gastos_detalle DROP CONSTRAINT IF EXISTS informes_gastos_detalle_pkey;
ALTER TABLE IF EXISTS ONLY public.eventos DROP CONSTRAINT IF EXISTS folio;
ALTER TABLE IF EXISTS ONLY public.eventos DROP CONSTRAINT IF EXISTS eventos_pkey;
ALTER TABLE IF EXISTS ONLY public.checkouts_maestro DROP CONSTRAINT IF EXISTS checkouts_maestro_pkey;
ALTER TABLE IF EXISTS ONLY public.checkouts_detalle DROP CONSTRAINT IF EXISTS checkouts_detalle_pkey;
ALTER TABLE IF EXISTS public.plantillas_checkout ALTER COLUMN id_plantilla DROP DEFAULT;
ALTER TABLE IF EXISTS public.mantenimiento_equipos ALTER COLUMN id_solicitud DROP DEFAULT;
ALTER TABLE IF EXISTS public.kits_empleados ALTER COLUMN id_kit DROP DEFAULT;
ALTER TABLE IF EXISTS public.informes_gastos_maestro ALTER COLUMN id_informe DROP DEFAULT;
ALTER TABLE IF EXISTS public.informes_gastos_detalle ALTER COLUMN id_detalle DROP DEFAULT;
ALTER TABLE IF EXISTS public.eventos ALTER COLUMN id_evento DROP DEFAULT;
ALTER TABLE IF EXISTS public.checkouts_maestro ALTER COLUMN id_maestro DROP DEFAULT;
ALTER TABLE IF EXISTS public.checkouts_detalle ALTER COLUMN id_detalle DROP DEFAULT;
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
DROP SEQUENCE IF EXISTS public.checkouts_maestro_id_maestro_seq;
DROP TABLE IF EXISTS public.checkouts_maestro;
DROP SEQUENCE IF EXISTS public.checkouts_detalle_id_detalle_seq;
DROP TABLE IF EXISTS public.checkouts_detalle;
SET default_tablespace = '';

SET default_table_access_method = heap;

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
    externos_op text[]
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
-- Data for Name: checkouts_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.checkouts_detalle (id_detalle, id_maestro, codigo_equipo, cantidad, observaciones, incidencias, cotejado, notas_regreso) FROM stdin;
2417	162	VPRO_ALT_26256	1	Esta caja contiene el CPU que se utiliza para los eventos	Sin incidencias	f	\N
2418	162	VPRO_ALT_26361	1	None	Sin incidencias	f	\N
2419	162	VPRO_ALT_26379	1	None	Sin incidencias	f	\N
2420	162	VPRO_ALT_26418	1	None	Sin incidencias	f	\N
2421	162	VPRO_ALT_26433	1	None	Sin incidencias	f	\N
2422	162	VPRO_ALT_26448	14	None	Sin incidencias	f	\N
2423	162	VPRO_ALT_26466	3	None	Sin incidencias	f	\N
2424	162	VPRO_ALT_26493	1	None	Sin incidencias	f	\N
2425	162	VPRO_ALT_26522	2	None	Sin incidencias	f	\N
2426	162	VPRO_ALT_26558	2	None	Sin incidencias	f	\N
2427	162	VPRO_ALT_26591	2	Una prestada de Hector	Sin incidencias	f	\N
2428	162	VPRO_ALT_26607	1	None	Sin incidencias	f	\N
2429	162	VPRO_ALT_26673	1	None	Sin incidencias	f	\N
2430	162	VPRO_ALT_11376	1	sufrio golpe	Sin incidencias	f	\N
2431	162	VPRO_ALT_11423	1	None	Sin incidencias	f	\N
2432	162	VPRO_ALT_11490	1	None	Sin incidencias	f	\N
2433	162	VPRO_ALT_11525	1	None	Sin incidencias	f	\N
2434	162	VPRO_ALT_11545	2	Uno de ellos no sirve	Sin incidencias	f	\N
2435	159	VPRO_ALT_26256	1	Esta caja contiene el CPU que se utiliza para los eventos	Sin incidencias	f	\N
2436	159	VPRO_ALT_26284	1	None	Sin incidencias	f	\N
2437	159	VPRO_ALT_26302	1	None	Sin incidencias	f	\N
2438	159	VPRO_ALT_26326	1	None	Sin incidencias	f	\N
2439	159	VPRO_ALT_26346	3	None	Sin incidencias	f	\N
2440	159	VPRO_ALT_26361	1	None	Sin incidencias	f	\N
2441	159	VPRO_ALT_26379	1	None	Sin incidencias	f	\N
2442	159	VPRO_ALT_26418	1	None	Sin incidencias	f	\N
2443	159	VPRO_ALT_26433	1	None	Sin incidencias	f	\N
2444	159	VPRO_ALT_26448	14	None	Sin incidencias	f	\N
2445	159	VPRO_ALT_26466	3	None	Sin incidencias	f	\N
2446	159	VPRO_ALT_26493	1	None	Sin incidencias	f	\N
2447	159	VPRO_ALT_26522	2	None	Sin incidencias	f	\N
2448	159	VPRO_ALT_26558	2	None	Sin incidencias	f	\N
2449	159	VPRO_ALT_26591	2	None	Sin incidencias	f	\N
2450	159	VPRO_ALT_26607	1	None	Sin incidencias	f	\N
2451	159	VPRO_ALT_26642	1	None	Sin incidencias	f	\N
2452	159	VPRO_ALT_26673	1	None	Sin incidencias	f	\N
2453	159	VPRO_ALT_26703	1	None	Sin incidencias	f	\N
2454	163	Inv_Vpro_alt_00137	1	None	Sin incidencias	f	\N
2455	164	Inv_Vpro_alt_00138	1	None	Sin incidencias	f	\N
3026	208	Inv_Vpro_alt_00157	1		Sin incidencias	t	
3027	208	Inv_Vpro_alt_00252	1		Sin incidencias	t	
2514	168	Inv_Vpro_alt_00162	1	Falta de pilas	Sin incidencias	f	\N
2492	167	VPRO_ALT_26284	1	None	Sin incidencias	t	
2493	167	VPRO_ALT_26326	1	None	Sin incidencias	t	
2494	167	VPRO_ALT_26346	3	None	Sin incidencias	t	
2495	167	VPRO_ALT_26361	1	None	Sin incidencias	t	
2496	167	VPRO_ALT_26379	1	None	Sin incidencias	t	
2497	167	VPRO_ALT_26418	1	None	Sin incidencias	t	
2498	167	VPRO_ALT_26433	1	None	Sin incidencias	t	
2499	167	VPRO_ALT_26448	14	None	Sin incidencias	t	
2500	167	VPRO_ALT_26466	2	None	Sin incidencias	t	
2501	167	VPRO_ALT_26493	1	None	Sin incidencias	t	
2502	167	VPRO_ALT_26522	2	None	Sin incidencias	t	
2503	167	VPRO_ALT_26558	2	None	Sin incidencias	t	
2504	167	VPRO_ALT_26591	1		Sin incidencias	t	
2467	165	Inv_Vpro_alt_00139	6		Sin incidencias	t	
2468	165	Inv_Vpro_alt_00140	2		Sin incidencias	t	
2469	165	Inv_Vpro_alt_00141	2		Sin incidencias	t	
2470	165	Inv_Vpro_alt_00142	1		Sin incidencias	t	
2471	165	Inv_Vpro_alt_00143	1		Sin incidencias	t	
2472	165	Inv_Vpro_alt_00144	2		Sin incidencias	t	
2473	165	Inv_Vpro_alt_00145	1		Sin incidencias	t	
2474	165	Inv_Vpro_alt_00146	1		Sin incidencias	t	
2475	165	Inv_Vpro_alt_00147	1		Sin incidencias	t	
2476	165	Inv_Vpro_alt_00148	1		Sin incidencias	t	
2477	165	Inv_Vpro_alt_00149	1		Sin incidencias	t	
3068	211	Inv_Vpro_alt_00182	1		Sin incidencias	t	
2505	167	VPRO_ALT_26607	1	None	Sin incidencias	t	
2506	167	VPRO_ALT_26642	1		Sin incidencias	t	
2507	167	VPRO_ALT_26673	1	None	Sin incidencias	t	
2508	167	VPRO_ALT_26703	1	None	Sin incidencias	t	
2509	167	Inv_Vpro_alt_26704	1	None	Sin incidencias	t	
2510	167	Inv_Vpro_alt_26705	1	None	Sin incidencias	t	
2511	167	Inv_Vpro_alt_26706	4	None	Sin incidencias	t	
2512	167	Inv_Vpro_alt_26707	1	None	Sin incidencias	t	
2513	167	Inv_Vpro_alt_26708	1	None	Sin incidencias	t	
2515	169	Inv_Vpro_alt_00157	1	None	Sin incidencias	t	
2516	169	Inv_Vpro_alt_00162	1	None	Sin incidencias	t	
2517	169	Inv_Vpro_alt_00163	1	None	Sin incidencias	t	
2518	169	Inv_Vpro_alt_00164	6	None	Sin incidencias	t	
2519	169	Inv_Vpro_alt_00165	3	None	Sin incidencias	t	
2520	169	Inv_Vpro_alt_00166	1	None	Sin incidencias	t	
2521	169	Inv_Vpro_alt_00167	2	None	Sin incidencias	t	
2522	169	Inv_Vpro_alt_00168	1	None	Sin incidencias	t	
2523	169	Inv_Vpro_alt_00169	1	None	Sin incidencias	t	
2524	169	Inv_Vpro_alt_00170	1	None	Sin incidencias	t	
2525	169	Inv_Vpro_alt_00171	1	None	Sin incidencias	t	
2526	169	Inv_Vpro_alt_00172	1	None	Sin incidencias	t	
2527	169	Inv_Vpro_alt_00173	1	None	Sin incidencias	f	
2528	169	Inv_Vpro_alt_00174	1	None	Sin incidencias	t	
2529	169	Inv_Vpro_alt_00175	2	None	Sin incidencias	t	
2530	170	Inv_Vpro_alt_00173	7	None	Sin incidencias	f	\N
2531	170	Inv_Vpro_alt_00174	5	None	Sin incidencias	f	\N
2532	170	Inv_Vpro_alt_00175	5	None	Sin incidencias	f	\N
2533	170	Inv_Vpro_alt_00176	1	None	Sin incidencias	f	\N
2534	170	Inv_Vpro_alt_00177	2	None	Sin incidencias	f	\N
2535	170	Inv_Vpro_alt_00178	1	None	Sin incidencias	f	\N
2536	170	Inv_Vpro_alt_00179	3	None	Sin incidencias	f	\N
2537	170	Inv_Vpro_alt_00180	2	None	Sin incidencias	f	\N
2538	170	Inv_Vpro_alt_00181	1	None	Sin incidencias	f	\N
2539	170	Inv_Vpro_alt_00182	2	None	Sin incidencias	f	\N
2540	170	Inv_Vpro_alt_00183	1	None	Sin incidencias	f	\N
2541	171	Inv_Vpro_alt_00045	3		Sin incidencias	t	
2542	171	Inv_vpro_alt_00001	4		Sin incidencias	t	
2543	171	Inv_Vpro_alt_00097	6		Sin incidencias	t	
2544	171	Inv_Vpro_alt_00098	2		Sin incidencias	t	
2545	171	Inv_Vpro_alt_00099	6		Sin incidencias	t	
2546	171	Inv_Vpro_alt_00100	1		Sin incidencias	t	
2547	171	Inv_Vpro_alt_00101	1		Sin incidencias	t	
2548	171	Inv_Vpro_alt_00102	1		Sin incidencias	t	
2549	171	Inv_Vpro_alt_00103	2		Sin incidencias	t	
2550	172	Inv_Vpro_alt_00138	1	None	Sin incidencias	t	
2551	173	Inv_Vpro_alt_00138	1	None	Sin incidencias	t	
2552	174	Inv_Vpro_alt_00015	2		Sin incidencias	t	
2553	174	Inv_Vpro_alt_00017	1		Sin incidencias	t	
2554	174	Inv_Vpro_alt_00018	1		Sin incidencias	t	
2555	174	Inv_Vpro_alt_00019	6		Sin incidencias	t	
2556	174	Inv_Vpro_alt_00020	4		Sin incidencias	t	
2557	174	Inv_Vpro_alt_00021	1		Sin incidencias	t	
2558	174	Inv_Vpro_alt_00022	35		Sin incidencias	t	
2559	174	Inv_Vpro_alt_00023	12		Sin incidencias	t	
2560	174	Inv_Vpro_alt_00024	1		Sin incidencias	t	
2561	174	Inv_Vpro_alt_00025	1		Sin incidencias	t	
2562	174	Inv_Vpro_alt_00090	1		Sin incidencias	t	
2563	174	Inv_Vpro_alt_00091	1		Sin incidencias	t	
2564	174	Inv_Vpro_alt_00093	1		Sin incidencias	t	
2565	174	Inv_Vpro_alt_00181	1	None	Sin incidencias	t	
2566	174	Inv_Vpro_alt_00182	1	None	Sin incidencias	t	
2567	174	Inv_Vpro_alt_00183	1	None	Sin incidencias	t	
2774	183	Inv_Vpro_alt_00232	1	None	Sin incidencias	t	
2775	183	Inv_Vpro_alt_00233	1	None	Sin incidencias	t	
2776	183	Inv_Vpro_alt_00234	1	None	Sin incidencias	t	
2777	183	Inv_Vpro_alt_00235	1	None	Sin incidencias	t	
2778	183	Inv_Vpro_alt_00236	2	None	Sin incidencias	t	
2779	183	Inv_Vpro_alt_00237	8	None	Sin incidencias	t	
2780	183	Inv_Vpro_alt_00238	1	None	Sin incidencias	t	
3069	211	Inv_Vpro_alt_00252	1	None	Sin incidencias	t	
3070	211	Inv_Vpro_alt_00253	1	None	Sin incidencias	t	
2829	189	Inv_Vpro_alt_00236	1	None	Sin incidencias	t	
2830	189	Inv_Vpro_alt_00237	1	None	Sin incidencias	t	
2853	192	Inv_Vpro_alt_00232	1	dolly back	Sin incidencias	t	
2919	199	Inv_Vpro_alt_00248	1		Sin incidencias	t	
2920	199	Inv_Vpro_alt_00249	1		Sin incidencias	t	
2921	199	Inv_Vpro_alt_00250	1		Sin incidencias	t	
2860	195	Inv_Vpro_alt_00235	1	None	Sin incidencias	t	
2861	195	Inv_Vpro_alt_00236	3	None	Sin incidencias	t	
2862	195	Inv_Vpro_alt_00237	3	None	Sin incidencias	t	
3286	176	Inv_Vpro_alt_00194	1		Sin incidencias	t	
3293	216	Inv_Vpro_alt_00236	1		Sin incidencias	t	
3294	216	Inv_Vpro_alt_00237	1		Sin incidencias	t	
3295	216	Inv_Vpro_alt_00242	2		Sin incidencias	t	
3296	216	Inv_Vpro_alt_00243	1	VPNRED0111	Sin incidencias	t	
2659	177	Inv_Vpro_alt_00045	4		Sin incidencias	t	
2660	177	Inv_Vpro_alt_00045	4		Sin incidencias	t	
2661	177	Inv_Vpro_alt_00198	4	None	Sin incidencias	t	
2662	177	Inv_Vpro_alt_00199	6	None	Sin incidencias	t	
2663	177	Inv_Vpro_alt_00200	4	None	Sin incidencias	t	
2664	177	Inv_Vpro_alt_00201	1	None	Sin incidencias	t	
2665	177	Inv_Vpro_alt_00202	6	None	Sin incidencias	t	
2666	177	Inv_Vpro_alt_00203	6	None	Sin incidencias	t	
2667	177	Inv_Vpro_alt_00204	1	None	Sin incidencias	t	
2668	177	Inv_Vpro_alt_00205	2	None	Sin incidencias	t	
2669	177	Inv_Vpro_alt_00206	2	None	Sin incidencias	t	
2670	177	Inv_Vpro_alt_00207	4	None	Sin incidencias	t	
2671	177	Inv_Vpro_alt_00208	1	None	Sin incidencias	t	
2672	177	Inv_Vpro_alt_00209	2	None	Sin incidencias	t	
2737	180	Inv_Vpro_alt_00234	1	None	Sin incidencias	t	
2739	181	Inv_Vpro_alt_00232	1	dolly back	Sin incidencias	f	\N
2615	178	Inv_Vpro_alt_00207	1	la pila se descargo	Sin incidencias	f	\N
2616	178	Inv_Vpro_alt_00208	1	None	Sin incidencias	f	\N
3062	211	Inv_Vpro_alt_00015	1		Sin incidencias	t	
2756	185	Inv_Vpro_alt_00235	1	None	Sin incidencias	f	\N
2757	185	Inv_Vpro_alt_00236	3	None	Sin incidencias	f	\N
2758	185	Inv_Vpro_alt_00237	3	None	Sin incidencias	f	\N
2759	185	Inv_Vpro_alt_00238	1	None	Sin incidencias	f	\N
3063	211	Inv_Vpro_alt_00019	1		Sin incidencias	t	
3064	211	Inv_Vpro_alt_00023	8		Sin incidencias	t	
3065	211	Inv_Vpro_alt_00024	1		Sin incidencias	t	
3066	211	Inv_Vpro_alt_00093	1		Sin incidencias	t	
3067	211	Inv_Vpro_alt_00181	2		Sin incidencias	t	
3287	176	Inv_Vpro_alt_00195	2		Sin incidencias	t	
2634	179	Inv_Vpro_alt_00210	3	None	Sin incidencias	f	\N
2635	179	Inv_Vpro_alt_00211	3	None	Sin incidencias	f	\N
2636	179	Inv_Vpro_alt_00212	2	None	Sin incidencias	f	\N
2637	179	Inv_Vpro_alt_00213	1	None	Sin incidencias	f	\N
3125	215	VPRO_ALT_24702	1	None	Sin incidencias	t	
3288	176	Inv_Vpro_alt_00196	1		Sin incidencias	t	
3289	176	Inv_Vpro_alt_00197	1		Sin incidencias	t	
3290	176	Inv_Vpro_alt_00198	2	Antenas 01 y 02	Sin incidencias	t	
3291	176	Inv_Vpro_alt_00199	2		Sin incidencias	t	
3292	176	Inv_Vpro_alt_00200	1		Sin incidencias	t	
3297	216	Inv_Vpro_alt_00244	1		Sin incidencias	t	
3298	216	Inv_Vpro_alt_00245	1		Sin incidencias	t	
3299	216	Inv_Vpro_alt_00246	1		Sin incidencias	t	
3300	216	Inv_Vpro_alt_00248	1		Sin incidencias	t	
2831	186	VPRO_ALT_26256	1	Esta caja contiene el CPU que se utiliza para los eventos	Sin incidencias	f	\N
2832	186	VPRO_ALT_26284	1	None	Sin incidencias	f	\N
2833	186	VPRO_ALT_26302	1	None	Sin incidencias	f	\N
2834	186	VPRO_ALT_26326	1	None	Sin incidencias	f	\N
2835	186	VPRO_ALT_26346	3	None	Sin incidencias	f	\N
2836	186	VPRO_ALT_26361	1	None	Sin incidencias	f	\N
2837	186	VPRO_ALT_26379	1	None	Sin incidencias	f	\N
2838	186	VPRO_ALT_26418	2	None	Sin incidencias	f	\N
2839	186	VPRO_ALT_26433	1	None	Sin incidencias	f	\N
2840	186	VPRO_ALT_26448	14	None	Sin incidencias	f	\N
2841	186	VPRO_ALT_26466	2	None	Sin incidencias	f	\N
2842	186	VPRO_ALT_26493	1	None	Sin incidencias	f	\N
2843	186	VPRO_ALT_26522	2	None	Sin incidencias	f	\N
2844	186	VPRO_ALT_26558	1	None	Sin incidencias	f	\N
2845	186	VPRO_ALT_26591	2		Sin incidencias	f	\N
2846	186	VPRO_ALT_26607	1	None	Sin incidencias	f	\N
2847	186	VPRO_ALT_26642	1	None	Sin incidencias	f	\N
2848	186	VPRO_ALT_26673	1	None	Sin incidencias	f	\N
2849	186	VPRO_ALT_26703	1	None	Sin incidencias	f	\N
2850	186	VPRO_ALT_11376	1		Sin incidencias	f	\N
2851	186	Inv_Vpro_alt_26704	1	None	Sin incidencias	f	\N
2854	193	Inv_Vpro_alt_00236	1	None	Sin incidencias	t	
2855	193	Inv_Vpro_alt_00237	1	None	Sin incidencias	t	
2856	193	Inv_Vpro_alt_00238	3	None	Sin incidencias	t	
3301	216	Inv_Vpro_alt_00250	2		Sin incidencias	t	
3302	216	Inv_Vpro_alt_00252	2		Sin incidencias	t	
3303	216	Inv_Vpro_alt_00253	1		Sin incidencias	t	
3304	216	Inv_Vpro_alt_00254	10		Sin incidencias	t	
3305	216	Inv_Vpro_alt_00255	1		Sin incidencias	t	
2907	199	Inv_Vpro_alt_00236	1		Sin incidencias	t	
2908	199	Inv_Vpro_alt_00237	1		Sin incidencias	t	
2909	199	Inv_Vpro_alt_00238	1		Sin incidencias	t	
2910	199	Inv_Vpro_alt_00239	1		Sin incidencias	t	
2911	199	Inv_Vpro_alt_00240	10		Sin incidencias	t	
2912	199	Inv_Vpro_alt_00241	15		Sin incidencias	t	
2913	199	Inv_Vpro_alt_00242	1		Sin incidencias	t	
2914	199	Inv_Vpro_alt_00243	1		Sin incidencias	t	
2915	199	Inv_Vpro_alt_00244	1		Sin incidencias	t	
2916	199	Inv_Vpro_alt_00245	1		Sin incidencias	t	
2917	199	Inv_Vpro_alt_00246	1		Sin incidencias	t	
2918	199	Inv_Vpro_alt_00247	1		Sin incidencias	t	
2713	180	Inv_Vpro_alt_00210	19	None	Sin incidencias	t	
2714	180	Inv_Vpro_alt_00211	32	1 cable sin punta	Sin incidencias	t	
2715	180	Inv_Vpro_alt_00212	10	None	Sin incidencias	t	
2716	180	Inv_Vpro_alt_00213	3	None	Sin incidencias	t	
2717	180	Inv_Vpro_alt_00214	1	None	Sin incidencias	t	
2718	180	Inv_Vpro_alt_00215	2	None	Sin incidencias	t	
2719	180	Inv_Vpro_alt_00216	1	None	Sin incidencias	t	
2720	180	Inv_Vpro_alt_00217	1	None	Sin incidencias	t	
2721	180	Inv_Vpro_alt_00218	1	None	Sin incidencias	t	
2722	180	Inv_Vpro_alt_00219	7	None	Sin incidencias	t	
2723	180	Inv_Vpro_alt_00220	10	None	Sin incidencias	t	
2724	180	Inv_Vpro_alt_00221	17	None	Sin incidencias	t	
2725	180	Inv_Vpro_alt_00222	1	None	Sin incidencias	t	
2726	180	Inv_Vpro_alt_00223	2	None	Sin incidencias	t	
2727	180	Inv_Vpro_alt_00224	2	None	Sin incidencias	t	
2728	180	Inv_Vpro_alt_00225	4	None	Sin incidencias	t	
2729	180	Inv_Vpro_alt_00226	1	None	Sin incidencias	t	
2730	180	Inv_Vpro_alt_00227	10	None	Sin incidencias	t	
2731	180	Inv_Vpro_alt_00228	1	None	Sin incidencias	t	
2732	180	Inv_Vpro_alt_00229	1	None	Sin incidencias	t	
2733	180	Inv_Vpro_alt_00230	1	None	Sin incidencias	t	
2734	180	Inv_Vpro_alt_00231	11	None	Sin incidencias	t	
2735	180	Inv_Vpro_alt_00232	2	None	Sin incidencias	t	
2736	180	Inv_Vpro_alt_00233	1	None	Sin incidencias	t	
2752	184	Inv_Vpro_alt_00235	1	None	Sin incidencias	t	
2753	184	Inv_Vpro_alt_00236	3	None	Sin incidencias	t	
2754	184	Inv_Vpro_alt_00237	3	None	Sin incidencias	t	
2755	184	Inv_Vpro_alt_00238	1	None	Sin incidencias	t	
2802	187	VPRO_ALT_26256	1	Esta caja contiene el CPU que se utiliza para los eventos	Sin incidencias	t	
2803	187	VPRO_ALT_26284	1	None	Sin incidencias	t	
2804	187	VPRO_ALT_26302	1	None	Sin incidencias	t	
2805	187	VPRO_ALT_26326	1	None	Sin incidencias	t	
2806	187	VPRO_ALT_26346	3	None	Sin incidencias	t	
2807	187	VPRO_ALT_26361	1	None	Sin incidencias	t	
2808	187	VPRO_ALT_26379	1	None	Sin incidencias	t	
2809	187	VPRO_ALT_26418	2	None	Sin incidencias	t	
2810	187	VPRO_ALT_26433	1	None	Sin incidencias	t	
2811	187	VPRO_ALT_26448	14	None	Sin incidencias	t	
2812	187	VPRO_ALT_26466	2	None	Sin incidencias	t	
2813	187	VPRO_ALT_26493	1	None	Sin incidencias	t	
2814	187	VPRO_ALT_26522	2	None	Sin incidencias	t	
2815	187	VPRO_ALT_26558	1	None	Sin incidencias	t	
2816	187	VPRO_ALT_26591	2		Sin incidencias	t	
2817	187	VPRO_ALT_26607	1	None	Sin incidencias	t	
2818	187	VPRO_ALT_26642	1	None	Sin incidencias	t	
2819	187	VPRO_ALT_26673	1	None	Sin incidencias	t	
2820	187	VPRO_ALT_26703	1	None	Sin incidencias	t	
2821	187	VPRO_ALT_11376	1		Sin incidencias	t	
2822	187	Inv_Vpro_alt_26704	1	None	Sin incidencias	t	
2827	188	Inv_Vpro_alt_00236	1	None	Sin incidencias	t	
2828	188	Inv_Vpro_alt_00237	1	None	Sin incidencias	t	
2852	191	Inv_Vpro_alt_00232	1	dolly back	Sin incidencias	f	\N
2857	194	Inv_Vpro_alt_00236	1	None	Sin incidencias	t	
2858	194	Inv_Vpro_alt_00237	1	None	Sin incidencias	t	
2859	194	Inv_Vpro_alt_00238	3	None	Sin incidencias	t	
3258	160	Inv_Vpro_alt_00157	1		Sin incidencias	t	
3259	160	Inv_Vpro_alt_00252	1		Sin incidencias	t	
3260	175	Inv_Vpro_alt_00236	1		Sin incidencias	t	
3261	175	Inv_Vpro_alt_00237	1		Sin incidencias	t	
3262	175	Inv_Vpro_alt_00242	2		Sin incidencias	t	
3263	175	Inv_Vpro_alt_00243	1	VPNRED0111	Sin incidencias	t	
3186	217	Inv_Vpro_alt_00235	1	None	Sin incidencias	t	
3187	217	Inv_Vpro_alt_00236	3	None	Sin incidencias	t	
3188	217	Inv_Vpro_alt_00237	4	None	Sin incidencias	t	
3189	217	Inv_Vpro_alt_00254	1	None	Sin incidencias	t	
3206	220	Inv_Vpro_alt_00236	1	None	Sin incidencias	t	
3207	220	Inv_Vpro_alt_00237	1	None	Sin incidencias	t	
3208	220	Inv_Vpro_alt_00238	1	None	Sin incidencias	t	
3209	220	Inv_Vpro_alt_00254	1	None	Sin incidencias	t	
3210	220	Inv_Vpro_alt_00255	1	None	Sin incidencias	t	
3211	220	Inv_Vpro_alt_00256	1	None	Sin incidencias	t	
3224	221	Inv_Vpro_alt_00236	1	None	Sin incidencias	f	\N
3225	221	Inv_Vpro_alt_00254	1	None	Sin incidencias	f	\N
3226	221	Inv_Vpro_alt_00255	1	None	Sin incidencias	f	\N
3227	221	Inv_Vpro_alt_00256	1	None	Sin incidencias	f	\N
3216	210	Inv_Vpro_alt_00236	1	None	Sin incidencias	t	
3217	210	Inv_Vpro_alt_00254	1	None	Sin incidencias	t	
3218	210	Inv_Vpro_alt_00255	1	None	Sin incidencias	t	
3219	210	Inv_Vpro_alt_00256	1	None	Sin incidencias	t	
3264	175	Inv_Vpro_alt_00244	1		Sin incidencias	t	
3265	175	Inv_Vpro_alt_00245	1		Sin incidencias	t	
2922	199	Inv_Vpro_alt_00251	1		Sin incidencias	t	
2923	199	Inv_Vpro_alt_00252	2		Sin incidencias	t	
2924	199	Inv_Vpro_alt_00253	1		Sin incidencias	t	
2925	199	Inv_Vpro_alt_00254	12		Sin incidencias	t	
2938	200	Inv_Vpro_alt_00232	1	None	Sin incidencias	f	\N
2939	200	Inv_Vpro_alt_00233	1	None	Sin incidencias	f	\N
2940	200	Inv_Vpro_alt_00234	1	None	Sin incidencias	f	\N
2941	200	Inv_Vpro_alt_00235	1	None	Sin incidencias	f	\N
2942	200	Inv_Vpro_alt_00236	2	None	Sin incidencias	f	\N
2943	200	Inv_Vpro_alt_00237	8	None	Sin incidencias	f	\N
2944	200	Inv_Vpro_alt_00238	1	None	Sin incidencias	f	\N
2945	201	Inv_Vpro_alt_00235	1	None	Sin incidencias	f	\N
2946	201	Inv_Vpro_alt_00236	3	None	Sin incidencias	f	\N
2947	201	Inv_Vpro_alt_00237	3	None	Sin incidencias	f	\N
2948	202	Inv_Vpro_alt_00236	1	None	Sin incidencias	f	\N
2949	202	Inv_Vpro_alt_00237	1	None	Sin incidencias	f	\N
2950	203	Inv_Vpro_alt_00236	1	None	Sin incidencias	f	\N
2958	197	Inv_Vpro_alt_00236	1	None	Sin incidencias	t	
2959	197	Inv_Vpro_alt_00237	1	None	Sin incidencias	t	
2951	196	Inv_Vpro_alt_00232	1	None	Sin incidencias	t	
2952	196	Inv_Vpro_alt_00233	1	None	Sin incidencias	t	
2953	196	Inv_Vpro_alt_00234	1	None	Sin incidencias	t	
2954	196	Inv_Vpro_alt_00235	1	None	Sin incidencias	t	
2955	196	Inv_Vpro_alt_00236	2	None	Sin incidencias	t	
2956	196	Inv_Vpro_alt_00237	8	None	Sin incidencias	t	
2957	196	Inv_Vpro_alt_00238	1	None	Sin incidencias	t	
2970	205	VPRO_ALT_26418	1	None	Sin incidencias	t	
2971	205	VPRO_ALT_26433	1	None	Sin incidencias	t	
2972	205	VPRO_ALT_26448	14	None	Sin incidencias	t	
3011	207	Inv_Vpro_alt_00252	1	None	Sin incidencias	t	
2966	204	Inv_Vpro_alt_00252	1	None	Sin incidencias	t	
2967	205	VPRO_ALT_26256	1	Esta caja contiene el CPU que se utiliza para los eventos	Sin incidencias	t	
2968	205	VPRO_ALT_26361	1	None	Sin incidencias	t	
2969	205	VPRO_ALT_26379	1	None	Sin incidencias	t	
2973	205	VPRO_ALT_26466	3	None	Sin incidencias	t	
2974	205	VPRO_ALT_26493	1	None	Sin incidencias	t	
2975	205	VPRO_ALT_26522	2	None	Sin incidencias	t	
2976	205	VPRO_ALT_26558	2	None	Sin incidencias	t	
2977	205	VPRO_ALT_26591	2	Una prestada de Hector	Sin incidencias	t	
2978	205	VPRO_ALT_26607	1	None	Sin incidencias	t	
2979	205	VPRO_ALT_26673	1	None	Sin incidencias	t	
2980	205	VPRO_ALT_11376	1	sufrio golpe	Sin incidencias	t	
2981	205	VPRO_ALT_11423	1	None	Sin incidencias	t	
2982	205	VPRO_ALT_11490	1	None	Sin incidencias	t	
2983	205	VPRO_ALT_11525	1	None	Sin incidencias	t	
2984	205	VPRO_ALT_11545	2	Uno de ellos no sirve	Sin incidencias	t	
2985	206	Inv_Vpro_alt_00015	1	Se Daño la agarradera de la maleta de la starlink (Inv_Vpro_alt_00015)	Sin incidencias	t	
2986	206	Inv_Vpro_alt_00019	1		Sin incidencias	t	
2987	206	Inv_Vpro_alt_00020	3		Sin incidencias	t	
2988	206	Inv_Vpro_alt_00023	8		Sin incidencias	t	
2989	206	Inv_Vpro_alt_00024	1		Sin incidencias	t	
2990	206	Inv_Vpro_alt_00093	1		Sin incidencias	t	
2991	206	Inv_Vpro_alt_00181	1		Sin incidencias	t	
2992	206	Inv_Vpro_alt_00182	1		Sin incidencias	t	
2993	182	Inv_Vpro_alt_00232	1	None	Sin incidencias	f	\N
2994	182	Inv_Vpro_alt_00233	1	None	Sin incidencias	f	\N
2995	182	Inv_Vpro_alt_00234	1	None	Sin incidencias	f	\N
2996	182	Inv_Vpro_alt_00235	1	None	Sin incidencias	f	\N
2997	182	Inv_Vpro_alt_00236	2	None	Sin incidencias	f	\N
2998	182	Inv_Vpro_alt_00237	8	None	Sin incidencias	f	\N
2999	182	Inv_Vpro_alt_00238	1	None	Sin incidencias	f	\N
3000	198	Inv_Vpro_alt_00236	1	None	Sin incidencias	f	\N
3001	198	Inv_Vpro_alt_00237	1	None	Sin incidencias	f	\N
3002	198	Inv_Vpro_alt_00238	3	Se daño una bateria	Sin incidencias	f	\N
3003	207	Inv_Vpro_alt_00015	1		Sin incidencias	t	
3004	207	Inv_Vpro_alt_00019	1		Sin incidencias	t	
3005	207	Inv_Vpro_alt_00020	3		Sin incidencias	t	
3006	207	Inv_Vpro_alt_00023	8		Sin incidencias	t	
3007	207	Inv_Vpro_alt_00024	1		Sin incidencias	t	
3008	207	Inv_Vpro_alt_00093	1		Sin incidencias	t	
3009	207	Inv_Vpro_alt_00181	1		Sin incidencias	t	
3010	207	Inv_Vpro_alt_00182	1		Sin incidencias	t	
3012	166	Inv_Vpro_alt_00150	2	None	Sin incidencias	t	
3013	166	Inv_Vpro_alt_00151	6	None	Sin incidencias	t	
3014	166	Inv_Vpro_alt_00152	6	None	Sin incidencias	t	
3015	166	Inv_Vpro_alt_00153	1	None	Sin incidencias	t	
3016	166	Inv_Vpro_alt_00154	1	None	Sin incidencias	t	
3017	166	Inv_Vpro_alt_00155	5	None	Sin incidencias	t	
3018	166	Inv_Vpro_alt_00156	2	None	Sin incidencias	t	
3019	166	Inv_Vpro_alt_00157	2	None	Sin incidencias	t	
3020	166	Inv_Vpro_alt_00158	2	None	Sin incidencias	t	
3021	166	Inv_Vpro_alt_00159	1	None	Sin incidencias	t	
3022	166	Inv_Vpro_alt_00160	2	None	Sin incidencias	t	
3023	166	Inv_Vpro_alt_00161	1	None	Sin incidencias	t	
3024	166	Inv_Vpro_alt_00162	1	None	Sin incidencias	t	
3025	166	Inv_Vpro_alt_00163	1	None	Sin incidencias	t	
3266	175	Inv_Vpro_alt_00246	1		Sin incidencias	t	
3267	175	Inv_Vpro_alt_00248	1		Sin incidencias	t	
3268	175	Inv_Vpro_alt_00250	2		Sin incidencias	t	
3269	175	Inv_Vpro_alt_00252	2		Sin incidencias	t	
3270	175	Inv_Vpro_alt_00253	1		Sin incidencias	t	
3271	175	Inv_Vpro_alt_00254	10		Sin incidencias	t	
3272	175	Inv_Vpro_alt_00255	1		Sin incidencias	t	
3190	218	Inv_Vpro_alt_00235	1	None	Sin incidencias	t	
3191	218	Inv_Vpro_alt_00236	3	None	Sin incidencias	t	
3192	218	Inv_Vpro_alt_00237	4	None	Sin incidencias	t	
3193	218	Inv_Vpro_alt_00254	1	None	Sin incidencias	t	
3121	214	Inv_Vpro_alt_00253	2	None	Sin incidencias	t	
3122	214	Inv_Vpro_alt_00254	2	None	Sin incidencias	t	
3123	214	Inv_Vpro_alt_00255	2	1 con capuchon y 1 sin capuchon	Sin incidencias	t	
3124	214	Inv_Vpro_alt_00256	2	None	Sin incidencias	t	
3200	219	Inv_Vpro_alt_00236	1	None	Sin incidencias	t	
3201	219	Inv_Vpro_alt_00237	1	None	Sin incidencias	t	
3202	219	Inv_Vpro_alt_00238	1	None	Sin incidencias	t	
3203	219	Inv_Vpro_alt_00254	1	None	Sin incidencias	t	
3204	219	Inv_Vpro_alt_00255	1	None	Sin incidencias	t	
3205	219	Inv_Vpro_alt_00256	1	None	Sin incidencias	t	
3165	213	Inv_Vpro_alt_00236	1		Sin incidencias	f	\N
3166	213	Inv_Vpro_alt_00237	1		Sin incidencias	f	\N
3167	213	Inv_Vpro_alt_00242	2		Sin incidencias	f	\N
3168	213	Inv_Vpro_alt_00243	1	VPNRED0111	Sin incidencias	f	\N
3169	213	Inv_Vpro_alt_00244	1		Sin incidencias	f	\N
3170	213	Inv_Vpro_alt_00245	1		Sin incidencias	f	\N
3171	213	Inv_Vpro_alt_00246	1		Sin incidencias	f	\N
3172	213	Inv_Vpro_alt_00248	1		Sin incidencias	f	\N
3173	213	Inv_Vpro_alt_00250	2		Sin incidencias	f	\N
3174	213	Inv_Vpro_alt_00252	2		Sin incidencias	f	\N
3175	213	Inv_Vpro_alt_00253	1		Sin incidencias	f	\N
3176	213	Inv_Vpro_alt_00254	10		Sin incidencias	f	\N
3177	213	Inv_Vpro_alt_00255	1	None	Sin incidencias	f	\N
3139	212	Inv_Vpro_alt_00236	1		Sin incidencias	t	
3140	212	Inv_Vpro_alt_00237	1		Sin incidencias	t	
3141	212	Inv_Vpro_alt_00242	2		Sin incidencias	t	
3142	212	Inv_Vpro_alt_00243	1	VPNRED0111	Sin incidencias	t	
3143	212	Inv_Vpro_alt_00244	1		Sin incidencias	t	
3144	212	Inv_Vpro_alt_00245	1		Sin incidencias	t	
3145	212	Inv_Vpro_alt_00246	1		Sin incidencias	t	
3146	212	Inv_Vpro_alt_00248	1		Sin incidencias	t	
3147	212	Inv_Vpro_alt_00250	2		Sin incidencias	t	
3148	212	Inv_Vpro_alt_00252	2		Sin incidencias	t	
3149	212	Inv_Vpro_alt_00253	1		Sin incidencias	t	
3150	212	Inv_Vpro_alt_00254	10		Sin incidencias	t	
3151	212	Inv_Vpro_alt_00255	1	None	Sin incidencias	t	
3228	222	Inv_Vpro_alt_00236	1	None	Sin incidencias	f	\N
3229	222	Inv_Vpro_alt_00254	1	None	Sin incidencias	f	\N
3230	222	Inv_Vpro_alt_00255	1	None	Sin incidencias	f	\N
3231	222	Inv_Vpro_alt_00256	1	None	Sin incidencias	f	\N
3220	209	Inv_Vpro_alt_00236	1	None	Sin incidencias	t	
3221	209	Inv_Vpro_alt_00254	1	None	Sin incidencias	t	
3222	209	Inv_Vpro_alt_00255	1	None	Sin incidencias	t	
3223	209	Inv_Vpro_alt_00256	1	None	Sin incidencias	t	
3273	176	Inv_Vpro_alt_00181	1		Sin incidencias	t	
3274	176	Inv_Vpro_alt_00182	1		Sin incidencias	t	
3275	176	Inv_Vpro_alt_00183	1		Sin incidencias	t	
3276	176	Inv_Vpro_alt_00184	1		Sin incidencias	t	
3277	176	Inv_Vpro_alt_00185	8		Sin incidencias	t	
3278	176	Inv_Vpro_alt_00186	4		Sin incidencias	t	
3279	176	Inv_Vpro_alt_00187	1		Sin incidencias	t	
3280	176	Inv_Vpro_alt_00188	2		Sin incidencias	t	
3281	176	Inv_Vpro_alt_00189	1		Sin incidencias	t	
3282	176	Inv_Vpro_alt_00190	1		Sin incidencias	t	
3283	176	Inv_Vpro_alt_00191	1		Sin incidencias	t	
3284	176	Inv_Vpro_alt_00192	1		Sin incidencias	t	
3285	176	Inv_Vpro_alt_00193	1		Sin incidencias	t	
3988	243	INV_ALT_1090014	1	[CUST_EQ:Transmisor de audio SONY VPNAUD009] None	Sin incidencias	t	
3989	243	INV_ALT_1090015	4	[CUST_EQ:Receptor de audio SONY VPNAUD008] None	Sin incidencias	t	
3990	243	INV_ALT_1090016	1	[CUST_EQ:Microfono de solapa SONY VPNAUD001] None	Sin incidencias	t	
4227	242	INV_VPRO_ALT_00013	1		Sin incidencias	f	
4228	242	INV_VPRO_ALT_00016	1		Sin incidencias	f	
4229	242	INV_VPRO_ALT_00017	1		Sin incidencias	f	
4230	242	INV_VPRO_ALT_00018	1		Sin incidencias	f	
4231	242	INV_VPRO_ALT_00019	1		Sin incidencias	f	
4232	242	INV_VPRO_ALT_00021	1		Sin incidencias	f	
4233	242	INV_VPRO_ALT_00022	35		Sin incidencias	f	
4234	242	INV_VPRO_ALT_00025	1		Sin incidencias	f	
4235	242	INV_VPRO_ALT_00089	1		Sin incidencias	f	
4236	242	INV_ALT_2010001	1		Sin incidencias	f	
3430	227	INV_ALT_1130004	1		Sin incidencias	t	
3431	227	INV_ALT_1130005	1		Sin incidencias	t	
3432	228	Inv_alt_1070001	1	[CUST_EQ:dolly] None	Sin incidencias	f	
3393	225	INV_VPRO_ALT_00256	2		Sin incidencias	t	
3394	225	INV_ALT_1130001	1		Sin incidencias	t	
3395	225	INV_ALT_1130002	1		Sin incidencias	t	
3396	224	INV_VPRO_ALT_00253	1		Sin incidencias	t	
3397	224	INV_VPRO_ALT_00254	1		Sin incidencias	t	
3398	224	INV_VPRO_ALT_00255	1		Sin incidencias	t	
3399	224	VPRO_ALT_26466	2		Sin incidencias	t	
3400	224	INV_ALT_1090001	1		Sin incidencias	t	
3401	224	INV_ALT_1090002	1		Sin incidencias	t	
3402	224	INV_ALT_1090003	1		Sin incidencias	t	
3403	224	INV_ALT_1090004	1		Sin incidencias	t	
3404	224	INV_ALT_1090005	1		Sin incidencias	t	
3405	224	INV_VPRO_ALT_00178	1		Sin incidencias	t	
3406	224	INV_ALT_1090006	2		Sin incidencias	t	
3414	223	INV_VPRO_ALT_00235	1		Sin incidencias	f	
3415	223	INV_VPRO_ALT_00236	3		Sin incidencias	f	
3416	223	INV_VPRO_ALT_00237	4		Sin incidencias	f	
3417	223	INV_ALT_1050001	1		Sin incidencias	f	
3418	223	INV_VPRO_ALT_00230	1		Sin incidencias	f	
3419	223	INV_VPRO_ALT_00152	1		Sin incidencias	f	
3420	223	INV_VPRO_ALT_00151	2	1 DE 15 mts Y 1 DE 7mts	Sin incidencias	f	
3425	226	Inv_Vpro_alt_00138	1		Sin incidencias	t	
3426	226	INV_ALT_1050002	1		Sin incidencias	t	
3427	226	VPRO_ALT_26448	1		Sin incidencias	t	
3443	229	INV_ALT_1090007	1		Sin incidencias	t	
3444	229	INV_ALT_1090008	1		Sin incidencias	t	
3445	229	INV_ALT_1090009	2		Sin incidencias	t	
3446	229	INV_ALT_1090014	1		Sin incidencias	t	
3447	229	VPRO_ALT_26466	1		Sin incidencias	t	
3448	229	INV_ALT_1090015	1		Sin incidencias	t	
3449	229	INV_ALT_1090012	1		Sin incidencias	t	
3450	229	INV_ALT_1090005	1		Sin incidencias	t	
3451	229	INV_VPRO_ALT_00178	1		Sin incidencias	t	
3452	229	INV_ALT_1090013	1		Sin incidencias	t	
3455	231	INV_ALT_1020001	1	None	Sin incidencias	f	
3456	231	INV_ALT_1020002	2	None	Sin incidencias	f	
3457	231	INV_ALT_1020003	1	None	Sin incidencias	f	
3458	231	INV_ALT_1020004	1	None	Sin incidencias	f	
3459	230	INV_ALT_2000001	1	Computadora MAC asignada a Andrea	Sin incidencias	t	
3460	230	INV_ALT_2000002	1	Disco duro con nombre "Vmix"	Sin incidencias	t	
3978	243	VPRO_ALT_26448	14		Sin incidencias	t	
3979	243	VPRO_ALT_26466	3		Sin incidencias	t	
3980	243	VPRO_ALT_26493	1		Sin incidencias	t	
3981	243	VPRO_ALT_26522	2		Sin incidencias	t	
3982	243	VPRO_ALT_26558	2		Sin incidencias	t	
3983	243	VPRO_ALT_26591	2		Sin incidencias	t	
3581	235	VPRO_ALT_26256	1	Esta caja contiene el CPU que se utiliza para los eventos	Sin incidencias	t	
3582	235	VPRO_ALT_26284	1		Sin incidencias	t	
3583	235	VPRO_ALT_26302	1		Sin incidencias	t	
3584	235	VPRO_ALT_26326	1		Sin incidencias	t	
3585	235	VPRO_ALT_26346	3		Sin incidencias	t	
3586	235	VPRO_ALT_26361	2		Sin incidencias	t	
3587	235	VPRO_ALT_26379	1		Sin incidencias	t	
3588	235	VPRO_ALT_26418	2		Sin incidencias	t	
3589	235	VPRO_ALT_26433	1		Sin incidencias	t	
3590	235	VPRO_ALT_26448	14		Sin incidencias	t	
3591	235	VPRO_ALT_26466	3		Sin incidencias	t	
3592	235	VPRO_ALT_26493	1		Sin incidencias	t	
3593	235	VPRO_ALT_26522	2		Sin incidencias	t	
3635	236	INV_VPRO_ALT_00256	2		Sin incidencias	t	
3636	236	INV_ALT_1130001	1		Sin incidencias	t	
3637	236	INV_ALT_1130002	1		Sin incidencias	t	
3594	235	VPRO_ALT_26558	2		Sin incidencias	t	
3595	235	VPRO_ALT_26591	2		Sin incidencias	t	
3596	235	VPRO_ALT_26607	1		Sin incidencias	t	
3597	235	VPRO_ALT_26673	1		Sin incidencias	t	
3598	235	VPRO_ALT_26703	1		Sin incidencias	t	
3599	235	INV_ALT_1090014	1		Sin incidencias	t	
3600	235	INV_ALT_1090015	4		Sin incidencias	t	
3601	235	INV_ALT_1090016	1		Sin incidencias	t	
3602	235	INV_ALT_1090020	4	None	Sin incidencias	t	
3603	235	INV_ALT_1090021	1	None	Sin incidencias	t	
3984	243	VPRO_ALT_26607	1		Sin incidencias	t	
3985	243	VPRO_ALT_26673	1		Sin incidencias	t	
3986	243	VPRO_ALT_26703	1		Sin incidencias	t	
3987	243	INV_ALT_1090024	12		Sin incidencias	t	
4020	232	INV_VPRO_ALT_00024	1		Sin incidencias	t	
4021	232	INV_VPRO_ALT_00025	1		Sin incidencias	t	
4022	232	INV_VPRO_ALT_00093	1		Sin incidencias	t	
4023	232	INV_ALT_2010001	1		Sin incidencias	t	
4024	232	INV_VPRO_ALT_00013	1		Sin incidencias	t	
4025	232	INV_VPRO_ALT_00015	2		Sin incidencias	t	
4026	232	INV_VPRO_ALT_00016	1		Sin incidencias	t	
3731	234	INV_VPRO_ALT_00042	2		Sin incidencias	t	
3732	234	INV_VPRO_ALT_00052	10		Sin incidencias	t	
3733	234	INV_VPRO_ALT_00053	10		Sin incidencias	t	
3734	234	INV_VPRO_ALT_00057	1		Sin incidencias	t	
3735	234	INV_VPRO_ALT_00058	2		Sin incidencias	t	
3736	234	INV_VPRO_ALT_00065	2		Sin incidencias	t	
3737	234	INV_VPRO_ALT_00081	2		Sin incidencias	t	
4027	232	INV_VPRO_ALT_00017	1		Sin incidencias	t	
4028	232	INV_VPRO_ALT_00018	1		Sin incidencias	t	
4029	232	INV_VPRO_ALT_00019	1		Sin incidencias	t	
4030	232	INV_VPRO_ALT_00021	1		Sin incidencias	t	
4031	232	INV_VPRO_ALT_00022	35		Sin incidencias	t	
4513	249	INV_ALT_1040004	6		Sin incidencias	f	
4514	249	INV_ALT_1040005	1		Sin incidencias	f	
4135	233	INV_VPRO_ALT_00045	3		Sin incidencias	f	
4136	233	INV_VPRO_ALT_00001	4		Sin incidencias	f	
4137	233	INV_VPRO_ALT_00097	6		Sin incidencias	f	
4138	233	INV_VPRO_ALT_00098	4		Sin incidencias	f	
4139	233	INV_VPRO_ALT_00099	6		Sin incidencias	f	
4140	233	INV_VPRO_ALT_00100	1		Sin incidencias	f	
4141	233	INV_VPRO_ALT_00101	3		Sin incidencias	f	
4142	233	INV_VPRO_ALT_00102	1		Sin incidencias	f	
4143	233	INV_VPRO_ALT_00103	4		Sin incidencias	f	
4144	233	INV_VPRO_ALT_00104	1		Sin incidencias	f	
4145	233	INV_VPRO_ALT_00105	1		Sin incidencias	f	
4146	237	INV_VPRO_ALT_00045	2		Sin incidencias	f	
4147	237	INV_VPRO_ALT_00001	2		Sin incidencias	f	
4148	237	INV_VPRO_ALT_00097	6		Sin incidencias	f	
4149	237	INV_VPRO_ALT_00098	2		Sin incidencias	f	
4150	237	INV_VPRO_ALT_00100	1		Sin incidencias	f	
4151	237	INV_VPRO_ALT_00101	1		Sin incidencias	f	
4152	237	INV_VPRO_ALT_00102	1		Sin incidencias	f	
4153	237	INV_VPRO_ALT_00103	1		Sin incidencias	f	
4154	237	INV_VPRO_ALT_00104	1		Sin incidencias	f	
4155	237	INV_VPRO_ALT_00099	6		Sin incidencias	f	
3738	234	INV_VPRO_ALT_00082	1		Sin incidencias	t	
3739	234	INV_VPRO_ALT_00085	2		Sin incidencias	t	
3740	234	INV_VPRO_ALT_00086	8		Sin incidencias	t	
3741	234	VPRO_ALT_16456	1		Sin incidencias	t	
3742	234	INV_ALT_1040001	2		Sin incidencias	t	
3743	234	VPRO_ALT_16469	3		Sin incidencias	t	
3744	234	INV_VPRO_ALT_00173	8	None	Sin incidencias	t	
3604	235	INV_ALT_1090019	1		Sin incidencias	t	
3605	235	Inv_alt_1090020	1	[CUST_EQ:consola de audio zedi8] None	Sin incidencias	t	
3606	235	Inv_alt_1090021	1	[CUST_EQ:bocina] None	Sin incidencias	t	
4515	249	INV_ALT_1040006	1		Sin incidencias	f	
4516	249	INV_ALT_1050006	1		Sin incidencias	f	
4517	249	VPRO_ALT_16530	2		Sin incidencias	f	
4518	249	VPRO_ALT_16456	1		Sin incidencias	f	
4519	249	VPRO_ALT_16469	3		Sin incidencias	f	
4520	249	VPRO_ALT_16484	1		Sin incidencias	f	
4521	249	INV_ALT_1040007	1		Sin incidencias	f	
4522	249	VPRO_ALT_26448	4		Sin incidencias	f	
4523	249	VPRO_ALT_16418	4		Sin incidencias	f	
3683	238	INV_VPRO_ALT_00236	3	None	Sin incidencias	t	
3684	238	Inv_alt_1040004	1	[CUST_EQ:kit de luces] None	Sin incidencias	t	
3688	239	INV_VPRO_ALT_00235	1		Sin incidencias	t	
3689	239	INV_VPRO_ALT_00236	3		Sin incidencias	t	
3690	239	INV_VPRO_ALT_00237	3		Sin incidencias	t	
3685	238	INV_VPRO_ALT_00237	3	None	Sin incidencias	t	
3686	238	INV_ALT_1040002	2	None	Sin incidencias	t	
3687	238	INV_ALT_1040003	1	None	Sin incidencias	t	
4156	244	INV_VPRO_ALT_00236	1		Sin incidencias	t	
4157	244	INV_VPRO_ALT_00242	2		Sin incidencias	t	
4158	244	INV_VPRO_ALT_00243	1	VPNRED099	Sin incidencias	t	
4159	244	INV_VPRO_ALT_00244	1		Sin incidencias	t	
4160	244	INV_VPRO_ALT_00245	1		Sin incidencias	t	
4161	244	INV_VPRO_ALT_00246	1		Sin incidencias	t	
4162	244	INV_VPRO_ALT_00248	1		Sin incidencias	t	
4163	244	INV_VPRO_ALT_00250	2		Sin incidencias	t	
4164	244	INV_VPRO_ALT_00252	2		Sin incidencias	t	
4165	244	INV_VPRO_ALT_00253	1		Sin incidencias	t	
3968	241	INV_ALT_1050006	1		Sin incidencias	t	
3969	241	INV_ALT_1040001	1		Sin incidencias	t	
3970	241	INV_ALT_1050003	1		Sin incidencias	t	
3971	241	INV_VPRO_ALT_00052	1		Sin incidencias	t	
3972	241	VPRO_ALT_16418	4		Sin incidencias	t	
3973	241	INV_ALT_1050004	1		Sin incidencias	t	
3974	241	INV_ALT_1050005	1		Sin incidencias	t	
3975	241	VPRO_ALT_16456	1		Sin incidencias	t	
3976	241	INV_VPRO_ALT_00173	3		Sin incidencias	t	
3977	241	INV_VPRO_ALT_00024	1	None	Sin incidencias	t	
3991	243	INV_ALT_1090017	4	[CUST_EQ:Diademas de comunicaciÃÂÃÂ³n BEHRINGER VPNAUD065] None	Sin incidencias	t	
3992	243	INV_ALT_1090018	1	[CUST_EQ:Diadema de comunicaciÃÂÃÂ³n SONY VPNAUD019] None	Sin incidencias	t	
3993	243	VPRO_ALT_26379	1		Sin incidencias	t	
3994	243	VPRO_ALT_26418	2		Sin incidencias	t	
3995	243	VPRO_ALT_26433	1		Sin incidencias	t	
3996	243	INV_ALT_1090025	4		Sin incidencias	t	
3997	243	VPRO_ALT_26256	1	Esta caja contiene el CPU que se utiliza para los eventos	Sin incidencias	t	
3998	243	VPRO_ALT_26302	1		Sin incidencias	t	
3999	243	VPRO_ALT_26326	1		Sin incidencias	t	
4000	243	VPRO_ALT_26346	3		Sin incidencias	t	
4001	243	VPRO_ALT_26361	2		Sin incidencias	t	
4002	243	INV_VPRO_ALT_00253	3		Sin incidencias	t	
4003	243	INV_VPRO_ALT_00255	3		Sin incidencias	t	
4004	243	INV_ALT_1090021	3		Sin incidencias	t	
4005	243	INV_ALT_1090022	4		Sin incidencias	t	
4006	243	INV_ALT_1090023	2		Sin incidencias	t	
4007	243	INV_ALT_1090026	3		Sin incidencias	t	
4087	240	Inv_Vpro_alt_00236	1		Sin incidencias	f	
4088	240	Inv_Vpro_alt_00242	2		Sin incidencias	f	
4089	240	Inv_Vpro_alt_00243	1	VPNRED099	Sin incidencias	f	
4090	240	Inv_Vpro_alt_00244	1		Sin incidencias	f	
4091	240	Inv_Vpro_alt_00245	1		Sin incidencias	f	
4092	240	Inv_Vpro_alt_00246	1		Sin incidencias	f	
4093	240	Inv_Vpro_alt_00248	1		Sin incidencias	f	
4094	240	Inv_Vpro_alt_00250	2		Sin incidencias	f	
4095	240	Inv_Vpro_alt_00252	2		Sin incidencias	f	
4096	240	Inv_Vpro_alt_00253	1		Sin incidencias	f	
4097	240	Inv_Vpro_alt_00254	10		Sin incidencias	f	
4098	240	Inv_Vpro_alt_00255	2	VPNRED095	Sin incidencias	f	
4099	240	INV_ALT_2020001	1		Sin incidencias	f	
4100	240	INV_ALT_2020002	1		Sin incidencias	f	
4101	240	INV_ALT_2020003	6		Sin incidencias	f	
4102	240	INV_ALT_2020004	1		Sin incidencias	f	
4201	245	INV_VPRO_ALT_00242	2		Sin incidencias	t	
4202	245	INV_VPRO_ALT_00243	1	VPNRED099	Sin incidencias	t	
4203	245	INV_VPRO_ALT_00244	1		Sin incidencias	t	
4204	245	INV_VPRO_ALT_00245	1		Sin incidencias	t	
4205	245	INV_VPRO_ALT_00246	1		Sin incidencias	t	
4206	245	INV_VPRO_ALT_00248	1		Sin incidencias	t	
4207	245	INV_VPRO_ALT_00250	1		Sin incidencias	t	
4208	245	INV_VPRO_ALT_00252	2		Sin incidencias	t	
4209	245	INV_VPRO_ALT_00254	10		Sin incidencias	t	
4210	245	INV_ALT_2020001	1		Sin incidencias	t	
4211	245	INV_ALT_2020002	1		Sin incidencias	t	
4212	245	INV_ALT_2020003	6		Sin incidencias	t	
4213	245	INV_VPRO_ALT_00189	1		Sin incidencias	t	
4166	244	INV_VPRO_ALT_00254	10		Sin incidencias	t	
4167	244	INV_VPRO_ALT_00255	2	VPNRED095	Sin incidencias	t	
4168	244	INV_ALT_2020001	1		Sin incidencias	t	
4169	244	INV_ALT_2020002	1		Sin incidencias	t	
4170	244	INV_ALT_2020003	6		Sin incidencias	t	
4171	244	INV_ALT_2020004	1		Sin incidencias	t	
4214	245	INV_ALT_2020005	2		Sin incidencias	t	
4215	245	INV_VPRO_ALT_00157	1		Sin incidencias	t	
4450	248	VPRO_ALT_26448	14		Sin incidencias	f	
4451	248	VPRO_ALT_26466	3		Sin incidencias	t	
4452	248	VPRO_ALT_26493	1		Sin incidencias	t	
4453	248	VPRO_ALT_26522	2		Sin incidencias	t	
4454	248	VPRO_ALT_26558	2		Sin incidencias	t	
4455	248	VPRO_ALT_26591	2		Sin incidencias	t	
4456	248	VPRO_ALT_26607	1		Sin incidencias	t	
4457	248	VPRO_ALT_26673	1		Sin incidencias	t	
4458	248	VPRO_ALT_26703	1		Sin incidencias	t	
4459	248	INV_ALT_1090024	4		Sin incidencias	t	
4460	248	INV_ALT_1090014	1	[CUST_EQ:Transmisor de audio SONY VPNAUD009] None	Sin incidencias	t	
4461	248	INV_ALT_1090015	3	[CUST_EQ:Receptor de audio SONY VPNAUD008] None	Sin incidencias	t	
4462	248	INV_ALT_1090016	1	[CUST_EQ:Microfono de solapa SONY VPNAUD001] None	Sin incidencias	t	
4463	248	INV_ALT_1090017	3	[CUST_EQ:Diademas de comunicaciÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n BEHRINGER VPNAUD065] None	Sin incidencias	t	
4464	248	INV_ALT_1090018	1	[CUST_EQ:Diadema de comunicaciÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n SONY VPNAUD019] None	Sin incidencias	t	
4465	248	VPRO_ALT_26379	1		Sin incidencias	t	
4466	248	VPRO_ALT_26418	2		Sin incidencias	t	
4467	248	VPRO_ALT_26433	2		Sin incidencias	t	
4468	248	INV_ALT_1090025	8		Sin incidencias	t	
4469	248	VPRO_ALT_26256	1	Esta caja contiene el CPU que se utiliza para los eventos	Sin incidencias	t	
4470	248	VPRO_ALT_26326	1		Sin incidencias	t	
4524	246	INV_VPRO_ALT_00022	35		Sin incidencias	f	
4525	246	INV_VPRO_ALT_00023	10		Sin incidencias	f	
4526	246	INV_VPRO_ALT_00024	2		Sin incidencias	f	
4527	246	INV_VPRO_ALT_00025	1		Sin incidencias	f	
4528	246	INV_VPRO_ALT_00092	1		Sin incidencias	f	
4529	246	INV_VPRO_ALT_00013	1		Sin incidencias	f	
4530	246	INV_VPRO_ALT_00016	1		Sin incidencias	f	
4531	246	INV_VPRO_ALT_00017	1		Sin incidencias	f	
4532	246	INV_VPRO_ALT_00018	1		Sin incidencias	f	
4533	246	INV_VPRO_ALT_00019	1		Sin incidencias	f	
4534	246	INV_VPRO_ALT_00021	1		Sin incidencias	f	
4535	246	INV_ALT_2010002	1		Sin incidencias	f	
4471	248	VPRO_ALT_26346	3		Sin incidencias	t	
4472	248	VPRO_ALT_26361	2		Sin incidencias	t	
4473	248	INV_ALT_1090023	2		Sin incidencias	t	
4474	248	INV_ALT_1090027	1	[CUST_EQ:Consola ZENI 8] None	Sin incidencias	t	
4475	248	INV_ALT_1090028	1		Sin incidencias	t	
4476	248	Inv_alt_1090029	2	None	Sin incidencias	t	
4536	247	INV_VPRO_ALT_00045	3		Sin incidencias	f	
4537	247	INV_VPRO_ALT_00001	3		Sin incidencias	f	
4538	247	INV_VPRO_ALT_00097	10		Sin incidencias	f	
4539	247	INV_VPRO_ALT_00098	4		Sin incidencias	f	
4540	247	INV_VPRO_ALT_00099	6		Sin incidencias	f	
4541	247	INV_VPRO_ALT_00100	1		Sin incidencias	f	
4542	247	INV_VPRO_ALT_00102	1		Sin incidencias	f	
4543	247	INV_VPRO_ALT_00103	3		Sin incidencias	f	
4544	247	INV_VPRO_ALT_00104	2		Sin incidencias	f	
4545	247	VPRO_ALT_23622	3		Sin incidencias	f	
4546	247	INV_ALT_1190001	2	[CUST_EQ:tripies para paraguas] None	Sin incidencias	f	
4547	247	INV_ALT_1190002	2	[CUST_EQ:extenciones de energia] None	Sin incidencias	f	
4548	247	INV_ALT_1190003	1	[CUST_EQ:mochila negra] None	Sin incidencias	f	
4549	247	INV_ALT_1190004	2	[CUST_EQ:abanicos] None	Sin incidencias	f	
4550	247	INV_ALT_1190005	2	[CUST_EQ:decimator] None	Sin incidencias	f	
4551	247	INV_ALT_1190006	2	[CUST_EQ:distribuidores] None	Sin incidencias	f	
4552	247	INV_ALT_1190007	1	[CUST_EQ:splinter] None	Sin incidencias	f	
4553	247	INV_VPRO_ALT_00206	2		Sin incidencias	f	
4554	247	INV_ALT_1190008	8	[CUST_EQ:cables sdi varios 1 metro] None	Sin incidencias	f	
4555	247	INV_ALT_1190009	4	[CUST_EQ:cables HDMI 1 metro] None	Sin incidencias	f	
4556	247	INV_ALT_1190014	2	[CUST_EQ:energia] None	Sin incidencias	f	
4557	247	INV_ALT_1190015	1	[CUST_EQ:minicontacto de nergi blnco] None	Sin incidencias	f	
4558	247	INV_ALT_1190016	2	[CUST_EQ:cables usb mini hdmi (rojo y negro)] None	Sin incidencias	f	
\.


--
-- Data for Name: checkouts_maestro; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.checkouts_maestro (id_maestro, folio_op, id_empleado, fecha, hora, incidencias_generales, estado_bodega, nombre_kit) FROM stdin;
162	44	109	2026-06-05	18:43:58.340585-07	La cámara Go Pro se apagó por sobrecalentamiento en un punto de la transmisión	PENDIENTE	\N
168	42	109	2026-06-20	10:33:35.427295-07		PENDIENTE	\N
171	48	119	2026-06-25	09:42:39.890015-07	sin incidencias	RECIBIDO	\N
174	49	201	2026-06-27	11:39:28.667104-07	Un cliente tuvo problemas para ingresar a su pagina vía ethernet y pudo ingresar vía wifi hasta el 3er día 	RECIBIDO	\N
218	64	105	2026-07-24	09:20:53.078815-07	SIN INCIDENCIAS 	RECIBIDO	\N
165	46	202	2026-07-01	10:56:41.551216-07	Sin incidencias	RECIBIDO	\N
221	63		2026-07-24	11:16:28.980951-07	Sin incidencias 	PENDIENTE	\N
177	50	119	2026-07-02	13:09:47.432115-07	TARIMAS MUY GUANGAS, TRES GENTES SE RECARGARON EN MI TARIMA., EN UNA DE ELLAS POR MI DESCUIDO SE ME MOVIO MI TOMA, SE ME AVISO QUE LA GRABADORA BLACKMAGIC QUE SE LLEVO NO GRABO, SE CHECO...LAS MEMORIAS TENIAN EL SEGURO... SE HIZO UNA PRUEBA Y OK.	RECIBIDO	\N
209	64	113	2026-07-24	11:16:56.633821-07	Sin Incidencias 	RECIBIDO	\N
180	50	104	2026-07-02	13:38:55.283632-07	incidencias\nCable HDMI sin Punta\nCasa Negra se Quebro\nBase de Pantallas sin una LLanta	RECIBIDO	\N
183	54	109	2026-07-03	18:19:36.203037-07	Sin Incidencias	RECIBIDO	\N
189	54	113	2026-07-03	18:39:25.790436-07	Sin incidencias 	RECIBIDO	\N
186	50	109	2026-07-03	18:54:03.655388-07	EL ENLACE PARA LAS PRUEBAS TARDO MUCHISIMO EN LLEGAR Y ESO ATRASSO EL TERMINO DE LA INSTALACIÓN.\nA 5 MINUTOS DE INICIAR PIDIERON CONFIRMAR LAS CUENTAS Y NO ESTABAN PORQUE SE USO UNA SESION NUEVA, POR LO QUE OPTO POR ENVIAR SOLAMENTE POR FACEBOOK, POR NO REQUERIR CONFIRMACION Y ES MAS RAPIDO.	PENDIENTE	\N
192	48	107	2026-07-06	12:19:50.529225-07	*  no se pudo sacar audio de regreso ( no tuvimos videos)\n	RECIBIDO	\N
200	56	109	2026-07-08	18:03:24.727415-07	Sin incidencias	PENDIENTE	\N
203	56	102	2026-07-08	18:04:58.294652-07	Sin incidencias	PENDIENTE	\N
195	55	105	2026-07-08	18:08:02.369604-07	Sin incidencias	RECIBIDO	\N
206	60	201	2026-07-09	16:31:28.043201-07	Sin incidencias.	RECIBIDO	\N
198	55	102	2026-07-10	09:39:17.805033-07	Sin incidencias,	RECIBIDO	\N
215	65	107	2026-07-23	10:38:16.383774-07	Sin incidencias	RECIBIDO	\N
212	68	202	2026-07-23	16:56:45.228297-07	Sin incidencias	RECIBIDO	\N
163	43	113	2026-06-05	18:52:50.374091-07	Sin incidencias	PENDIENTE	\N
172	48	105	2026-06-25	09:45:19.864117-07	Sin incidencias	RECIBIDO	\N
169	48	202	2026-06-23	18:45:20.3675-07	Sin incidencias en transmisión\nNOTA: Por parte de redes de Gobierno del Edo. se instaló un cable directo del site para las transmisiones por parte de vpro (cable azul)	RECIBIDO	\N
178	42	125	2026-07-01	11:46:46.431092-07		PENDIENTE	\N
181	50	107	2026-07-02	18:38:33.132072-07	ENLACE PRESIDENTE:\n*  en las pruebas con cepropie no escuchabamos al productor de cdmx, era una opcion de webex\n\nVIVIENDA PARA EL BIENESTAR\n*el productor de cepropie no nos escuchaba por estar mal el micro  (problema de provedor elevox)\n* no estaban las cuentas de gobierno por abrir un proyecto nuevo en vimix (se mando a una sola plataforma)\n* no se puso monitor para checar lo que se envia a pantallas y/o monitores\n* tarimas debiles\n* persona le pego a tarima. el camarografo al informarle a esa persona se le fue la toma hacia abajo (se vio al aire.)\n\n	PENDIENTE	\N
184	53	105	2026-07-03	17:59:44.481396-07	SIN INCIDENCIAS 	RECIBIDO	\N
187	48	109	2026-07-03	18:18:23.464505-07	sin incidencias	RECIBIDO	\N
190	50	113	2026-07-03	18:37:12.142279-07	Sin incidencias	PENDIENTE	\N
193	53	102	2026-07-06	12:52:22.91486-07	Sin incidencias	RECIBIDO	\N
219	63	102	2026-07-24	09:24:28.139561-07	Sin incidencias	RECIBIDO	\N
199	58	202	2026-07-08	16:07:41.945696-07	Sin incidencias	RECIBIDO	\N
201	56	105	2026-07-08	18:03:56.249693-07	Sin incidencias	PENDIENTE	\N
210	63	113	2026-07-24	11:16:39.026724-07	Sin incidencias 	RECIBIDO	\N
196	55	109	2026-07-08	18:06:58.775424-07	Sin incidencias	RECIBIDO	\N
204	59	202	2026-07-09	11:07:10.516176-07	Sin incidencias de transmisión	RECIBIDO	\N
207	61	201	2026-07-10	16:30:18.912287-07	Sin incidencias.	RECIBIDO	\N
222	64		2026-07-24	11:16:49.880711-07	Sin Incidencias 	PENDIENTE	\N
166	47	104	2026-07-13	10:01:51.920092-07	   - -Sin Incidencias en Equipo--\n* Incidencia en Equipo de Pantalla de los proveedores\nse vio diferencia en la mitad de pantalla, oscuro arriba y brillante abajo	RECIBIDO	\N
213	68		2026-07-23	16:56:34.460951-07	Sin incidencias	PENDIENTE	\N
175	49	202	2026-07-27	12:21:06.419256-07		RECIBIDO	Jornadas de la paz
216	69	202	2026-07-27	13:05:44.778857-07		RECIBIDO	Jornadas de la paz
205	59	109	2026-07-09	11:07:34.30041-07	Sin incidencias	RECIBIDO	\N
159	43	109	2026-06-05	18:46:53.129264-07	Buen dia, envío reporte del dia domingo 31 de mayo Enlace informe presidencial en explanada de palacio de gobierno:\n\n1, El audio se desconecto de la consola, al parecer alguien piso el cable, porque se arremilino la gente entre nuestra mesa y la consola de audio, se corrigió, fue antes del mensaje de la presidenta\n\n2, al reiniciar el video de youtube,  se activó la entrada en vmix al mismo tiempo que navegador de Internet, lo que provocó el audio doble por unos segundos, fue antes del mensaje de la presidenta.\n\nQuedo pendiente para cualquier duda o aclaración	RECIBIDO	KIT SEMANERA
164	43	105	2026-06-05	18:58:08.168132-07	Sin Incidencias	PENDIENTE	\N
167	47	109	2026-06-20	11:26:49.272185-07	1, EL modem tardo en dar servicio de internet, se cambiaron cables y adaptadores y se reinició en varias ocasiones, al final en una reiniciada agarro, se bajaron algunos archivos con el teléfono personal mientras tanto.\n2, La pantalla led de 3 mm empezó viéndose la mitad bien y la mitad deslavada, durante todo el evento estuvieron moviéndole tratando de arreglarlo, mejorando y empeorando en momentos, hasta el final del evento, al parecer, se arregló, nosotros en las pantallas nuestras no tuvimos problema alguno	RECIBIDO	\N
170	48	104	2026-06-24	10:58:33.732703-07	Sin Incidencias	PENDIENTE	\N
173	45	105	2026-06-25	13:24:39.241296-07	SIN INCIDENCIAS	RECIBIDO	\N
179	51	104	2026-07-02	10:51:32.678217-07	Sin Incidencias	PENDIENTE	\N
182	53	109	2026-07-09	16:51:42.008944-07	Sin Incidencias	RECIBIDO	\N
217	63	105	2026-07-24	09:20:39.743921-07	SIN INCIDENCIAS 	RECIBIDO	\N
157	43	107	2026-06-02	12:21:26.059791-06	* Al momento  de poner el informe de youtube se escucho doble el audio al menos 40 seg.\n* personal de gobierno no se poniian de acuerdo para encuadre de camara que se deberia  mmandar al aire\n* minutos antes de iniciar se fue internet de palacio de gob.	PENDIENTE	\N
220	64	102	2026-07-24	09:24:39.738023-07	Sin incidencias	RECIBIDO	\N
156	43	104	2026-06-02	12:43:08.871307-06	Sin Incidencia	RECIBIDO	\N
153	43	201	2026-06-03	10:16:25.353932-06	Trabajamos con el internet de starlink ya que gobierno del edo restauro su internet hasta despues de las 10:00 - 10:30 am	RECIBIDO	KIT_STD_EVENTOS_FUERA_DE_OFICINAS
154	43	119	2026-06-05	16:22:38.569233-07	incidencia 1 hubo cambios de posición de cámaras.	RECIBIDO	KIT EVENTO ESPECIAL 3 CAMARAS
185	54	105	2026-07-03	17:54:46.532581-07	SIN INCIDENCIAS 	PENDIENTE	\N
160	44	202	2026-07-27	12:19:08.789085-07		RECIBIDO	IEES en estudio de Vpro
188	53	113	2026-07-03	18:39:08.905689-07	Sin incidencias 	RECIBIDO	\N
191	52	107	2026-07-06	12:11:24.87756-07	sin incidencias	PENDIENTE	\N
194	54	102	2026-07-06	12:52:13.944003-07	Sin incidencias	RECIBIDO	\N
176	50	202	2026-07-27	12:23:53.65326-07		RECIBIDO	Enlace y viviendas bienestar
211	66	201	2026-07-22	17:37:20.568315-07	\nSin incidencias.	RECIBIDO	\N
202	56	113	2026-07-08	18:04:17.46899-07	Sin incidencias	PENDIENTE	\N
197	55	113	2026-07-08	18:06:39.429848-07	Sin incidencias.	RECIBIDO	\N
214	65	109	2026-07-23	10:37:22.221379-07	Sin incidencias.	RECIBIDO	\N
208	62	202	2026-07-23	10:39:50.711435-07	- Sin incidencias en transmisión.\nINCIDENCIAS CON INTERPRETES:\n- José Carlos llegó a un minuto de iniciar transmisión.\n- José Carlos volteó al estar al aire cuando pregunté cuanto tiempo faltaba para el cambio de interprete.\n- José Carlos volteó al estar al aire cuando se indicó que estaba muy pegado al green.	RECIBIDO	\N
243	75	109	2026-08-05	11:33:04.130258-06	Sin incidencias	RECIBIDO	KIT ENLACE Y CIRCUITO CERRADO
232	72	201	2026-08-05	12:26:56.577367-06	Sin incidencias	RECIBIDO	KIT_STD_EVENTOS_FUERA_DE_OFICINAS
238	74	104	2026-08-07	17:05:14.896259-06	Sin incidencias	RECIBIDO	Grabación al campo
225	70	113	2026-07-28	14:42:58.74132-06	Sin incidencias	RECIBIDO	Grabacion LEY
224	70	109	2026-07-28	14:43:20.500287-06	Sin incidencias	RECIBIDO	Kit LEY
245	78	202	2026-08-07	17:11:08.570645-06		RECIBIDO	Jornadas de la paz 1
223	70	105	2026-07-28	14:52:48.248604-06	sin incidencias	RECIBIDO	CASA LEY
226	71	105	2026-07-30	11:28:41.339003-06		RECIBIDO	cocacola cine
240	76	202	2026-08-05	18:23:13.281697-06	Sin incidencias	RECIBIDO	Jornadas de la paz
227	71	113	2026-07-30	12:25:34.907679-06		RECIBIDO	--- Sin plantilla ---
228	58	107	2026-07-31	10:53:47.420087-06	Sin incidencias	PENDIENTE	--- Sin plantilla ---
233	72	119	2026-08-06	14:52:51.450696-06	Al principio no se escuchaba el audio enlace beber,\nSe olvido un pizacable en  Auditorio AARC\nSe extravio una mochila con una laptop\nNo iba monitor de vMix en su caja\nSe golpio caja de vMix	RECIBIDO	KIT EVENTO ESPECIAL 3 CAMARAS
229	71	109	2026-07-31	12:15:09.484555-06		RECIBIDO	KIT DE ESTUDIO INALAMBRICO
231	70	102	2026-08-02	19:36:37.529631-06	Sin incidencias	PENDIENTE	KIT SONY FS7
237	75	119	2026-08-06	14:55:56.65845-06	Tuvimos detalle en el enlace con el beber con nuestros equipos, se resolvio con equipo de gobierno.	RECIBIDO	KIT EVENTO ESPECIAL 3 CAMARAS
230	71	200	2026-08-03	12:22:57.093054-06	Sin incidencias	RECIBIDO	Kit ediciÃ³n Andrea
244	77	202	2026-08-06	17:36:35.000265-06		RECIBIDO	Jornadas de la paz - Bueno
235	72	109	2026-08-05	10:41:53.795691-06	Sin incidencias	RECIBIDO	KIT ENLACE Y CIRCUITO CERRADO
234	72	104	2026-08-05	10:51:19.928756-06	Sin incidencias	RECIBIDO	Kit Semanera
236	73	113	2026-08-03	18:16:05.045571-06	Sin incidencias	RECIBIDO	Grabacion LEY
242	75	201	2026-08-07	13:27:36.146287-06	El enlace se realizo con una laptop de Gobno del edo., aun cuando en las pruebas de enlace con equipo mac se llevaron a cabo sin problemas. Se olvido un pizacable en  Auditorio AARC(recuperado),Se extravio una mochila con una laptop(recuperada)	RECIBIDO	KIT_STD_EVENTOS_FUERA_DE_OFICINAS
239	73	105	2026-08-05	11:21:30.140526-06		RECIBIDO	CASA LEY
248	79	109	2026-08-11	11:02:39.325544-06		RECIBIDO	KIT ENLACE PRESIDENTA MOCHIS
241	75	105	2026-08-05	11:32:19.178102-06	Sin incidencias	RECIBIDO	Kit enlace Presidenta
249	79	104	2026-08-11	12:01:14.967933-06	Incidencias\nCarpa lona se Rompio, Estructura se daño\nLa Ford se le Desprendio un Amortiguador con todo y base	RECIBIDO	Enlace en el carrizo
246	79	201	2026-08-11	12:22:33.198333-06	Sin incidencias	RECIBIDO	KIT_STD_EVENTOS_FUERA_DE_OFICINAS
247	79	119	2026-08-11	13:12:09.539015-06	El dia de pruebas nos llovio, se nos quebro la carpa, se enlodaron los carros, H100 trae una falla en el cuerpo de acelaracion.\nEl dia del evento se hizo en otro lugar, no donde fueron las pruebas, casi al final del evento se escuchaba audio duplicado y se cortaba, al parcer era el regreso.	RECIBIDO	KIT EVENTO ESPECIAL 3 CAMARAS
\.


--
-- Data for Name: eventos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.eventos (id_evento, folio, fec_de_elaboracion_de_op, empleado_que_creo_la_op, para_q_cliente, fec_de_instalacion, nombre_evento, hra_de_instalacion, locacion, fec_del_evento, inicio_del_evento, quien_solicita, hra_de_llamado, ubicacion, resp_de_produccion, tipo_de_servicio, produccion, internet_redes, actividades_de_proveedores, nota, elabora, organiza, coordina, vobo, proveedor_op, personal_convocado_op, carros_usados_op, externos_op) FROM stdin;
56	56	2026-07-07	Manuel Eduardo Madrid	Casa ley	2026-07-08	GRABACIONES 72 ANIVERSARIO LEY (Día 4) FILMACION DE ENTREVISTAS TESTIMONIALES A PERSONAL	08:00:00	LEY SENDERO (ACUDIRAN DE DIVERSAS UNIDADES)	2026-07-08	08:00:00	Área de comunicación LEY	07:30:00	LEY SENDERO (ACUDIRAN DE DIVERSAS UNIDADES)	Gerardo Villarreal Uribe	Filmación de testimonios	1er.ENTREVISTA: \t\tHora: 8:00am  \tUnidad: SXL universitarios\t\nEntrevistado: Imelda Bonifacia Herrera Hernandez (Empleada de Cocina)\t\t\t\t\n2da.ENTREVISTA:\t\tHora: 9:00am\t\t\n Entrevistado: Oyuki Yuceli Ceniceros Villa (jefe de panadería) \t\t\t\t\n3er.ENTREVISTA: \t\t Hora: 10:00am  UNIDAD: Ley Plaza Culiacán \t\t\nEntrevistado: Norma Alicia Peraza Madrid (tablajero de pescado y mariscos)\t\t\t\t\n4ta.ENTREVISTA: \t\tHora: 11:00pm    UNIDAD:Ley Humaya\t\t\n Entrevistado: Jesús Atadeo Celis Media (Jefe de Recibo General) \t\t\t\t\n5ta.ENTREVISTA: \t\tHora: 12:00p m \t\t\nEntrevistado:Elsi Guadalupe Martinez Rojo (administrador del Sirca) \t\t\t\t\n 6ta.ENTREVISTA:\t\tHora: 2:00pm\tUNIDAD: Ley Plaza Sur\t\nEntrevistado: Oscar Martel Zepeeda García (Jefe de Bodega) \t\t\t\t\n7ma.ENTREVISTA: \t\tHora: 3:00pm  \t\t\nEntrevistado:Fabiola Margarita Zamora Rodriguez (Jefe de Damas)   \t\t\t\t\n8va.ENTREVISTA: \t\tHora: 4:00pm  \tUNIDAD: Ley Calzada\t\n Entrevistado: Carolina Martinez Hdez. (Blanquera) \t\t\t\t\n9na.ENTREVISTA: \t\tHora: 5:00pm  \t\t\nEntrevistado:  Nataly Alvarez Rubio (Jefe de higiene y Belleza)  \t\t\t\t\n\t\t\t\t\nEQUIPO FILMACION:\t\t\t\t\nCámara Alfa y  FS/7\t\t\t\t\nEquipo de iluminación\t\t\t\t\nboom de audio\t\t\t\t\nTeleprompeter\t\t\t\t			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Gerardo Villarreal Uribe","Jose Daniel Torres Arroyo","Carlos Jacobo Quezada Mendoza","Osiel Cuauhtemoc Hernandez Aldape"}	{"Nissan #02 2013"}	{}
60	60	2026-07-08	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-07-09	JORNADAS DE PAZ (DIA 2)	08:30:00	Escuela Primaria General Lazaro Cardenas	2026-07-09	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:00:00	Escuela Primaria General Lazaro Cardenas	Martin Eduardo Sanchez Estrada	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet red		Proveeduría de internet a 10 módulos\t\t\n2 antenas Starlink\t\t\nDistribución de linas de internet red\t\t		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"Nissan #04 2013"}	{}
70	70	2026-07-27	Manuel Eduardo Madrid	Casa ley	2026-07-28	VIDEO 72 ANIVERSARIO LEY (GRABACION DE MENSAJE : JUAN MANUEL LEY)	07:30:00	CENTRO COORPORATIVO LEY	2026-07-28	09:00:00	Área de comunicación LEY	07:00:00	CENTRO COORPORATIVO LEY	Gerardo Villarreal Uribe	Filmación de testimonios	1er.ENTREVISTA: \t\tHora: 9:00am  \n Entrevistado: Juan Manuel Ley  (hijo) \t\t\nEQUIPO FILMACION:\t\t\t\nCámara Alfa y  FS/7\t\t\t\nEquipo de iluminación\t\t\t\nboom de audio\t\t\t\nTeleprompter			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Gerardo Villarreal Uribe","Carlos Jacobo Quezada Mendoza","Osiel Cuauhtemoc Hernandez Aldape","Jose Daniel Torres Arroyo"}	{"Nissan #02 2013"}	{}
61	61	2026-07-08	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-07-08	JORNADAS DE PAZ (DIA 3)	09:00:00	Escuela Primaria General Lazaro Cardenas	2026-07-08	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	06:00:00	Escuela Primaria General Lazaro Cardenas	Martin Eduardo Sanchez Estrada	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet red		Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"Nissan #04 2013"}	{}
62	62	2026-07-15	Manuel Eduardo Madrid	IEES	2026-07-14	SESION VIRTUAL EXTRAORDINARIA	10:00:00	ESTUDIO TV VPRO	2026-07-16	11:00:00	Melissa León	08:00:00	ESTUDIO TV VPRO	Martin Eduardo Sanchez Estrada	Transmisión vía ZOOM de reunión extraordinaria		Transmision vía ZOOM\t\nStreaming\t		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas","Osiel Cuauhtemoc Hernandez Aldape"}	{}	{}
59	59	2026-07-08	Manuel Eduardo Madrid	IEES	2026-07-09	IEES SESION VIRTUAL	09:00:00	ESTUDIO TV VPRO	2026-07-09	10:00:00	Melissa León	08:00:00	ESTUDIO TV VPRO	Martin Eduardo Sanchez Estrada	Transmisión vía ZOMM de reunión extraordinaria		Transmision vía ZOOM\t\nStreaming\t		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Osiel Cuauhtemoc Hernandez Aldape","Edgar Javier Amarillas"}	{}	{}
63	63	2026-07-21	Manuel Eduardo Madrid	Agricola del Campo	2026-07-20	LEVANTAMIENTO DE IMAGEN	17:00:00	RANCHO EL ESLABON	2026-07-22	08:00:00	Área de comunicación	05:00:00	RANCHO EL ESLABON (Aguascalientes)	Gerardo Villarreal Uribe	Filmación de testimonios	EQUIPO FILMACION:\t\t\t\nCámara Alfa y  FS/7\t\t\t\nEquipo de iluminación\t\t\t\nboom de audio\t\t\t\nTeleprompeter\t\t\t			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Gerardo Villarreal Uribe","Jose Daniel Torres Arroyo","Carlos Jacobo Quezada Mendoza"}	{"Nissan #02 2013"}	{}
64	64	2026-07-24	Manuel Eduardo Madrid	Agricola del Campo	2026-07-20	LEVANTAMIENTO DEI MAGEN (Día 2)	08:00:00	RANCHO EL ESLABON	2026-07-22	08:00:00	Área de comunicación	08:00:00	RANCHO EL ESLABON (Aguascalientes)	Gerardo Villarreal Uribe	Filmación de testimonios	EQUIPO FILMACION:\t\t\t\nCámara Alfa y  FS/7\t\t\t\nEquipo de iluminación\t\t\t\nboom de audio\t\t\t\nTeleprompeter\t\t\t			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Carlos Jacobo Quezada Mendoza","Gerardo Villarreal Uribe","Jose Daniel Torres Arroyo"}	{"Nissan #02 2013"}	{}
65	65	2026-07-23	Manuel Eduardo Madrid	Coppel	2026-07-21	HISTORIAS JURIDICO COPPEL (KUWA)	09:30:00	TORRE PREMIER	2026-07-21	11:00:00	MAYUMI SALINAS Y YASHMIN MORONES	09:00:00	TORRE PREMIER	Martin Eduardo Sanchez Estrada	Audio y microfonía	VPRO\t\n2 Microfonos lavalier\t\n2 Receptores Sony\t\n2 Transmisores Sony\t		PRODUCCION KUWA:\t\n\t\naudio lineal 2x1 lado\t\nRack de audio amplificado\t\nCentro de carga\t\nSet de cableado y extensiones\t\n1 microfono inalambrico\t\nconsola de audio yamaha\t\nIng. de audio\t	Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{SERVIPLUS-KUWA}	{"Martin Eduardo Sanchez Estrada","Osiel Cuauhtemoc Hernandez Aldape"}	{"Nissan #04 2013"}	{}
42	42	2026-07-01	Manuel Eduardo Madrid	VPRO	2026-05-26	Reporte de situaciones en Oficina	13:15:00	Culiacán, Sinaloa	2026-05-26	13:30:00	VPRO	09:00:00		Pedro Villarreal Uribe						Ana Lilia Villarreal Uribe	Pedro Villarreal Uribe	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Ana Lilia Villarreal Uribe","Andrea Maria Vilarreal Lopez","Carlos Jacobo Quezada Mendoza","Cuauhtemoc Rivera Agundez","Edgar Javier Amarillas","Gerardo Villarreal Uribe","Ibon Araceli Campos Medina","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez","Manuel Antonio Madrid Zazueta","Manuel Eduardo Madrid","Martin Eduardo Sanchez Estrada","Osiel Cuauhtemoc Hernandez Aldape","Sofia Alejandra Villarreal Lopez","Pedro Villarreal Uribe","Diego Villareal Lopez"}	{}	{}
43	43	2026-05-30	Cuauhtemoc Rivera Agundez	Gobierno del Estado de Sinaloa	2026-05-30	INFORME DE RENDICION DE CUENTAS PRESIDENCIAL	11:00:00	EXPLANADA DE PALACIO DE GOBIERNO	2026-05-31	08:00:00	ISSAC DE PRESIDENCIA, Eliazar giras,  CEPROPIES Y EDWIN	05:00:00	EXPLANADA DE PALACIO DE GOBIERNO	Martin Eduardo Sanchez Estrada	Envió vía liga WEBEX de Transmisión, enlace en vivo de Informe y vuelo de dron.	PRODUCCIÓN:\t\t\n3 cámaras\t\t\nVmix\t\t\ncomputadora exclusiva para WEBEX\t\t\nConsola de audio\t\t\nBotonera para cambios en pantalla\nVuelo de dron	Streaming\t\t\nProveeduría de internet\t\t\n1 antena starlink		SABADO 30/MAYO\t\t\t\t\nEnsayo 11:00am Hora Pacífico / 12:00am Hora CDMX\t\t\t\t\nDOMINGO 31/MAYO\t\t\t\t\nInstalación- 2da- pruebas 7:00am Hora Pacifico / 8:00am Hora CDMX\t\t\t\t\nENTREGADA AL AIRE 1ER BLOCKE : 8:00am Hora Pacifico/ 9:00am Hora CDMX.\nToda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Carlos Jacobo Quezada Mendoza","Cuauhtemoc Rivera Agundez","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez","Manuel Antonio Madrid Zazueta","Osiel Cuauhtemoc Hernandez Aldape","Martin Eduardo Sanchez Estrada"}	{"Hyundai 2015","Nissan #02 2013"}	{}
44	44	2026-06-05	Manuel Eduardo Madrid	IEES	2026-06-04	SESION VIRTUAL	09:00:00	ESTUDIO TV VPRO	2026-06-04	14:00:00	Melissa León	09:00:00	ESTUDIO TV VPRO	Martin Eduardo Sanchez Estrada	Transmisión vía ZOMM de reunión extraordinaria		Transmision vía ZOOM\t\nStreaming		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Osiel Cuauhtemoc Hernandez Aldape","Edgar Javier Amarillas"}	{}	{}
66	66	2026-07-21	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-07-22	Jornadas de la paz (Día 1)	09:00:00	De los Rosales, Vista Hermosa	2026-07-22	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:00:00	De los Rosales, Vista Hermosa	Martin Eduardo Sanchez Estrada	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n2 antenas Starlink\t\t\nDistribución de linas de internet red\t\t		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez"}	{"Nissan #04 2013"}	{}
51	51	2026-06-29	Manuel Eduardo Madrid	->	2026-06-29	Evento en ZONA MILITAR EL SAUZ	09:30:00	ZONA MILITAR EL SAUZ	2026-06-29	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	09:00:00	ZONA MILITAR EL SAUZ	Martin Eduardo Sanchez Estrada		2 tripie para monitor			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jose Francisco Torres Sanchez"}	{"Hyundai 2015"}	{}
46	46	2026-06-11	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-06-11	Evento Mundial de futbol 	11:00:00	Patio interior palacio de gobierno	2026-06-11	12:00:00	EDWIN	11:00:00	Patio interior palacio de gobierno	Martin Eduardo Sanchez Estrada	Streaming para inauguración Mundial futbol méxico 2026		Streaming\n1 laptop\nDistribuidor de señal		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas"}	{"Nissan #04 2013"}	{}
47	47	2026-06-19	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-06-19	Estrategia Nacional De Seguridad	09:00:00	VILLA UNION	2026-06-19	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	06:00:00	VILLA UNION	Martin Eduardo Sanchez Estrada	Reproducción de material audiovisual a pantallas.	PRODUCCIÓN:\t\t\t\n1 Switcher\t\t\t\n2 Monitores de 65"\t\t\t\n1 Laptop\t\t\t\nModem inalambrico\t\t\t\nproveeduría internet\t\t(pendiente si se requiere)\t			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jose Francisco Torres Sanchez","Osiel Cuauhtemoc Hernandez Aldape"}	{"Hyundai 2015"}	{}
48	48	2026-06-25	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-06-23	REUNION DEL CONSEJO DE PROTECCION CIVIL E INSTALACION DEL PUESTO DE COMANDO EN EL ESTADO DE SINALOA	13:00:00	Palacio de gobierno	2026-06-23	15:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	11:00:00	Palacio de gobierno "Salón Gobernadores"	Martin Eduardo Sanchez Estrada	Streaming a 3 Cámaras	Streaming\n3 cámaras\nSwitcher			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas","Jose Daniel Torres Arroyo","Jose Francisco Torres Sanchez","Manuel Antonio Madrid Zazueta","Martin Eduardo Sanchez Estrada","Osiel Cuauhtemoc Hernandez Aldape"}	{"Hyundai 2015"}	{}
54	54	2026-07-06	Manuel Eduardo Madrid	Casa ley	2026-07-03	GRABACIONES 72 ANIVERSARIO LEY, (Día 2) FILMACION DE ENTREVISTAS TESTIMONIALES A PERSONAL 	08:30:00	MAYOREO LEY ABASTOS	2026-07-03	08:30:00	Área de comunicación LEY	08:00:00	MAYOREO LEY ABASTOS	Gerardo Villarreal Uribe	Filmación de testimonios	EQUIPO FILMACION:\t\t\t\t\nCámara Alfa y  FS/7\t\t\t\t\nEquipo de iluminación\t\t\t\t\nboom de audio\t\t\t\t\nTeleprompter\t\t\t\t			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.\n\n1er.ENTREVISTA: \t\tHora: 8:30am  \t\t\nEntrevistado: Alan Ricardo Ochoa Guerrero (Vigilante de Mayoreo)                                      \t\t\t\t\n2da.ENTREVISTA:\t\tHora: 9:30am\t\t\nEntrevistado: Celia Simons Pillado   (Jéfe de Crédito\t\t\t\t\n3er.ENTREVISTA: \t\t Hora: 11:00am\t\t\n Entrevistado:  Minerva Olea Acevedo  (Surtidor de Mayoreo)  \t	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Gerardo Villarreal Uribe","Carlos Jacobo Quezada Mendoza","Jose Daniel Torres Arroyo","Osiel Cuauhtemoc Hernandez Aldape"}	{"Nissan #02 2013"}	{}
45	45	2026-06-25	Manuel Eduardo Madrid	ELEVOX	2026-06-01	Evento en museo centenario	12:00:00	MUSEO CENTENARIO	2026-06-03	11:00:00	Eliazar Gastelum, (Elevox)	09:00:00	MUSEO CENTENARIO	Martin Eduardo Sanchez Estrada	Renta de equipo audiovisual	32 monitores de 65"\t\nen tripie o base\t			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jose Francisco Torres Sanchez","Jose Daniel Torres Arroyo"}	{"Hyundai 2015"}	{}
49	49	2026-06-25	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-06-24	JORNADAS DE PAZ	11:30:00	Alturas del sur	2026-06-25	09:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:30:00	Alturas del sur	Martin Eduardo Sanchez Estrada	Proveeduría de internet a módulos con Satarlink y distribución de líneas de internet red		Proveeduría de internet a 10 módulos\t\t\n2 antenas Starlink\t\t\nDistribución de linas de internet red\t\t		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Cuauhtemoc Rivera Agundez","Edgar Javier Amarillas"}	{"Nissan #02 2013"}	{}
50	50	2026-07-02	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-06-30	ENLACE PRESIDENCIAL Y INAGURACION DE VIVIENDAS BIENESTAR	14:00:00	Los Mochis Centro Alphabiotico CALM	2026-07-01	06:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	04:00:00	Los Mochis Centro Alphabiotico CALM	Martin Eduardo Sanchez Estrada		PRODUCCIÓN:\tEVENTO #1 (Enlace presidenta) -Entrada 4:00am inicia 6:00am\nStreaming\t\n3 cámaras c/operador\t\n1 cámara fija\t\nSwitcher\t\n2 Monitores de 65" en tripie\t\nPRODUCCIÓN:\tEVENTO #2 (Viviendas bienestar) -Entada 10:30am\tInicia 11:00am\t\nStreaming\t\n3 cámaras c/operador\t\nSwitcher\t\n8 Monitores de 65" en tripie\t	Evento #1\nProveduría de internet\t\n1 antena Starlink\t\nEvento #2\nProveduría de internet\t\n1 antena Starlink\t		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Martin Eduardo Sanchez Estrada","Carlos Jacobo Quezada Mendoza","Edgar Javier Amarillas","Jose Francisco Torres Sanchez","Osiel Cuauhtemoc Hernandez Aldape","Manuel Antonio Madrid Zazueta"}	{"Hyundai 2015","Mercedes Benz 2021"}	{Jonahtan}
53	53	2026-07-02	Manuel Eduardo Madrid	Casa ley	2026-07-02	GRABACIONES 72 ANIVERSARIO LEY, (Día 1) FILMACION DE ENTREVISTAS TESTIMONIALES A PERSONAL 	08:00:00	CEDIS 80 	2026-07-02	08:00:00	Área de comunicación LEY	07:00:00	CEDIS 80 	Gerardo Villarreal Uribe	Filmación de testimonios	1er.ENTREVISTA: \t\tHora: 8:00am  \t\t\n Entrevistado: Jesús Roberto Manajarrez Arana (subgerente) \t\t\t\t\n2da.ENTREVISTA:\t\tHora: 9:30am\t\t\nEntrevistado: Juan Ramón Osuna Chaidez (mecánico)                                       \t\t\t\t\n3er.ENTREVISTA: \t\t Hora: 11:00am\t\t\n  Entrevistado: Esteban Ochoa Grande (Surtidor de Vinos)  \t\t\t\t\n4ta.ENTREVISTA: \t\tHora: 12:00pm\t\t\nEntrevistado: Heriberto Hdez. Salas (Montacargas)\t\t\t\t\nUNIDAD TRAFICO/ CEDIS 80\t\t\t\t\n5ta.ENTREVISTA: \t\tHora: 3:00p m \t\t\n  Entrevistado: Yarertzi Sanchez Benitez   (Auxiliar RH)\t\t\t\t\n 6ta.ENTREVISTA:\t\tHora: 4:00pm\t\t\n Entrevistado: Jamileth Aguirre Angulo (Chofer)  \t\t\t\t\n7ma.ENTREVISTA: \t\tHora: 5:00pm  \t\t\nEntrevistado: Karina Nava Soria (Empleada de lavado) \t\t\t\t\n\t\t\t\t\nEQUIPO FILMACION:\t\t\t\t\nCámara Alfa y  FS/7\t\t\t\t\nEquipo de iluminación\t\t\t\t\nboom de audio\t\t\t\t\nTeleprompeter\t\t\t\t			 Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Gerardo Villarreal Uribe","Jose Daniel Torres Arroyo","Carlos Jacobo Quezada Mendoza","Osiel Cuauhtemoc Hernandez Aldape"}	{"Nissan #02 2013"}	{}
68	68	2026-07-22	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-07-23	JORNADA DE LA PAZ (Día 2)	09:00:00	Col. Vista Hermosa	2026-07-23	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:30:00	Col. Vista Hermosa	Martin Eduardo Sanchez Estrada	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n2 antenas Starlink\t\t\nDistribución de linas de internet red\t\t		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas"}	{"Nissan #04 2013"}	{}
52	52	2026-07-03	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-06-27	En defensa de la transformación y la soberanía nacional	11:30:00	Salón Floresta de  Hotel Wyndham (Ejecutivo)	2026-06-28	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	09:00:00	Salón Floresta de  Hotel Wyndham (Ejecutivo)	Martin Eduardo Sanchez Estrada	Escenografía y Audio para capacidad 1000 personas	PRODUCCIÓN:\tKUWA\t\t\t\n\t\t\t\t\nESCENARIO:\t\t\t\t\n1 Templete de 6.10x3.66x.60cm aforado con tela negra y cubierto de lona negra\t\t\t\t\n1 Templete de 6.120x1.22x1m aforado con tela negra uy cubierta lona negra\t\t\t\t\n1 back de mampara de 6.10x2.44m con lona impres a diseño\t\t\t\t\nAUDIO:\t\t\t\t\nAudio lineal 3x2xlado\t\t\t\t\n6 monitores de audio JBL von pedestal para distr.lateral\t\t\t\t\n2 rack de audio amplificación\t\t\t\t\nConsola de audio digital Yamaha\t\t\t\t\n3 Micrófonos inalámbricos\t\t\t\t\n1 micrófono de cuello de ganzo podium\t\t\t\t\n2 centros de carga\t\t\t\t\n6 set de cableado y extensiones\t\t\t\t\n2 staff\t\t\t\t\n1ing. De audio\t\t\t\t\n06 lúces par led para escenario\t\t\t\t			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{SERVIPLUS-KUWA}	{"Martin Eduardo Sanchez Estrada"}	{"Nissan #02 2013"}	{}
55	55	2026-07-07	Manuel Eduardo Madrid	Casa ley	2026-07-07	GRABACIONES 72 ANIVERSARIO LEY (Día 3) FILMACION DE ENTREVISTAS TESTIMONIALES A PERSONAL	08:00:00	FRESH MARKET PRIMAVERA Y LAS QUINTAS	2026-07-07	08:00:00	Área de comunicación LEY	07:00:00	FRESH MARKET PRIMAVERA Y LAS QUINTAS	Gerardo Villarreal Uribe	Filmación de testimonios	EQUIPO FILMACION:\t\t\t\nCámara Alfa y  FS/7\t\t\t\nEquipo de iluminación\t\t\t\nboom de audio\t\t\t\nTeleprompeter\t\t\t			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.\n\n1er.ENTREVISTA: \t\tHora: 8:00am  \t\t\nEntrevistado: Imelda Castañeda López (líder de servicio de cajas)\t\t\t\t\n2da.ENTREVISTA:\t\tHora: 9:30am\t\t\nEntrevistado: Irma Rocio Rodriguez Zazueta (Barra de cocina)\t\t\t\t\n3er.ENTREVISTA: \t\t Hora: 11:00am\t\t\n Entrevistado: Yamileth Guadalupe Cázarez Mendoza (Subjefa de Frutas y verduras)\t\t\t\t\n4ta.ENTREVISTA: \t\tHora: 12:00pm\t\t\n Entrevistado: Olivia García Toscano (Empleada Abarrotes\t\t\t\t\nLUGAR FRESH MARKET LAS QUINTAS\t\t\t\t\n5ta.ENTREVISTA: \t\tHora: 03:00p m \t\t\nEntrevistado: Edgar Enrique Cebreros Ureta (Simmiter Especialista) \t\t\t\t\n 6ta.ENTREVISTA:\t\tHora: 4:00pm\t\t\nEntrevistado: Irving Emir Urias Chang (Repostero) \t\t\t\t\n7ma.ENTREVISTA: \t\tHora: 5:00pm  \t\t\nEntrevistado: Francisco José Castro Aguilar (Jefe de control de inventarios) \t\t\t\t\n\t\t\t\t	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Carlos Jacobo Quezada Mendoza","Gerardo Villarreal Uribe","Jose Daniel Torres Arroyo","Osiel Cuauhtemoc Hernandez Aldape"}	{}	{}
69	69	2026-07-23	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-07-24	JORNADA DE LA PAZ (Día 3)	09:00:00	Colonia Vista Hermosa	2026-07-24	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:30:00	Colonia Vista Hermosa	Martin Eduardo Sanchez Estrada	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n2 antenas Starlink\t\t\nDistribución de linas de internet red\t\t		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas"}	{"Nissan #04 2013"}	{}
71	71	2026-07-30	Manuel Eduardo Madrid	COCA - COLA	2026-07-29	GRABACIONES MENSAJE PARA PROYECCION EN CINE	09:00:00	Estudio VPRO	2026-07-29	11:00:00	COCACOLA	09:00:00	Estudio VPRO	Gerardo Villarreal Uribe	Grabaciones de video testimonial	Grabación de testimonios.			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Osiel Cuauhtemoc Hernandez Aldape","Carlos Jacobo Quezada Mendoza","Jose Daniel Torres Arroyo","Andrea Maria Vilarreal Lopez"}	{}	{}
58	58	2026-07-31	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-07-08	JORNADAS DE LA PAZ (DIA 1)	08:30:00	Escuela Primaria General Lazaro Cardenas	2026-07-08	10:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:00:00	Escuela Primaria General Lazaro Cardenas	Martin Eduardo Sanchez Estrada	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet red		Proveeduría de internet a 10 módulos\t\t\n2 antenas Starlink\t\t\nDistribución de linas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas","Martin Eduardo Sanchez Estrada"}	{"Nissan #04 2013"}	{}
73	73	2026-08-03	Manuel Eduardo Madrid	Casa ley	2026-08-03	Grabación 72 aniversario LEY	10:30:00	Leymaralago	2026-08-03	11:00:00	Área de comunicación LEY	10:00:00	Leymaralago	Gerardo Villarreal Uribe	Filmación de testimonios					Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Carlos Jacobo Quezada Mendoza","Gerardo Villarreal Uribe","Jose Daniel Torres Arroyo"}	{"Nissan #04 2013"}	{}
74	74	2026-08-04	Manuel Eduardo Madrid	Agricola del Campo	2026-08-05	Grabaciones especiales (el campo)	09:00:00	Aguascalientes el rancho el eslabón	2026-08-06	09:00:00	Área de comunicación	05:00:00	Aguascalientes el rancho el eslabón	Gerardo Villarreal Uribe	LEVANTAMIENTO DE IMÁGENES Y GRABACIONES ESPECIALES	EQUIPO FILMACION:\t\t\t\nCámara Alfa y  FS/7\t\t\t\nEquipo de iluminación\t\t\t\nboom de audio				Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Gerardo Villarreal Uribe","Jose Francisco Torres Sanchez"}	{"Nissan #02 2013"}	{}
75	75	2026-08-06	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-08-04	Enlace presidenta (Salon gobernadores)	12:30:00	Salón gobernadores	2026-08-05	06:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	04:00:00	Salón gobernadores	Martin Eduardo Sanchez Estrada	Streaming a 3 cámaras, monitores de Tv.	PRODUCCIÓN:\t\tEntrada 4:00am inicia 6:00am\t\t\nStreaming\t\t\t\t\n1 cámara c/operador\t\t\t\t\t\t\t\t\nSwitcher\t\t\t\t\n1 Monitores de 50"			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Martin Eduardo Sanchez Estrada","Manuel Antonio Madrid Zazueta","Jose Daniel Torres Arroyo","Cuauhtemoc Rivera Agundez","Osiel Cuauhtemoc Hernandez Aldape"}	{"Ford 1996","Hyundai 2015"}	{}
79	79	2026-08-07	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-08-09	ENLACE PRESIDENCIAL CON GOBERNADORA	11:30:00	EL CARRIZO	2026-08-10	06:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	04:00:00	EL CARRIZO	Martin Eduardo Sanchez Estrada	Streaming a 3 cámaras, monitores de Tv, proveeduria de internet.	Salida el día 08 de agosto al carrizo: A las 6:00 AM\t\t\t\n\t\t\t\t\nENLACE CON PRESIDENCIA LLAMADO A LAS  4:00am INICIA 6:00am\t\t\nPRODUCCIÓN:\t\t\t\nStreaming\t\t\t\t\n3 cámaras c/operador\t\t\t\t\n1 cámara fija\t\t\t\t\nSwitcher\t\t\t\t\n2 Monitores de 65" en tripie	1 Antena Starlink		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Martin Eduardo Sanchez Estrada","Osiel Cuauhtemoc Hernandez Aldape","Manuel Antonio Madrid Zazueta","Jose Francisco Torres Sanchez","Cuauhtemoc Rivera Agundez"}	{"Hyundai 2015"}	{}
77	77	2026-08-05	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-08-06	Jornadas de la paz (Dia 2)	09:00:00	El Ranchito	2026-08-06	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:30:00	El Ranchito	Martin Eduardo Sanchez Estrada	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		PRODUCCIÓN:\t\t\nProveeduría de internet a 10 módulos\t\t\n2 antenas Starlink\t\t\nDistribución de linas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas"}	{}	{}
76	76	2026-08-05	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-08-05	Jornadas de la paz (Dia 1)	09:00:00	El Ranchito	2026-08-05	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:00:00	El Ranchito	Martin Eduardo Sanchez Estrada	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		PRODUCCIÓN:\t\t\nProveeduría de internet a 10 módulos\t\t\n2 antenas Starlink\t\t\nDistribución de linas de internet red			Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas"}	{"Hyundai 2015"}	{}
72	72	2026-08-06	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-08-03	Enlace presidencial	15:00:00	Auditorio de la AARC	2026-08-04	06:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	04:00:00	Auditorio de la AARC	Martin Eduardo Sanchez Estrada	Streaming a 3 cámaras, monitores de Tv, y proveeduria de internet.	PRODUCCIÓN:\tEVENTO #1\tEntrada 4:00am inicia 6:00am\t\t\nStreaming\t\t\t\t\n3 cámaras c/operador\t\t\t\t\n1 cámara fija\t\t\t\t\nSwitcher\t\t\t\t\n2 Monitores de 65" en tripie\t\t\t\t\nProveduría de internet\t\t\t\t\n2 antena Starlink			Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Jose Francisco Torres Sanchez","Osiel Cuauhtemoc Hernandez Aldape","Jose Daniel Torres Arroyo","Manuel Antonio Madrid Zazueta","Martin Eduardo Sanchez Estrada","Cuauhtemoc Rivera Agundez"}	{"Ford 1996","Hyundai 2015"}	{}
78	78	2026-08-06	Manuel Eduardo Madrid	Gobierno del Estado de Sinaloa	2026-08-07	Jornadas de la paz (dia 3)	09:00:00	El ranchito	2026-08-07	11:00:00	DES.TECNOLOGICO  (Giras-Eduardo)	08:30:00	El ranchito	---	Proveeduría de internet a modulos con Satarlink y disribucion de lineas de internet fibra		Proveeduría de internet a 10 módulos\t\t\n2 antenas Starlink\t\t\nDistribución de linas de internet red		Toda orden de producción esta sujeta a supervisión permanente hasta el término del evento, por cambios generados de último minuto por el cliente, siendo reportado de inmediato a Administración y Coordinación para su debido llenado y actualización en cotización y agenda.	Ana Lilia Villarreal Uribe	Martin Eduardo Sanchez Estrada	Manuel Eduardo Madrid	Gerardo Villarreal Uribe	{}	{"Edgar Javier Amarillas"}	{"Nissan #04 2013"}	{}
\.


--
-- Data for Name: informes_gastos_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.informes_gastos_detalle (id_detalle, id_informe, dia_num, hotel, transporte, combustible, casetas, desayuno, comida, cenas, varios, total_dia) FROM stdin;
1	1	1	1.00	1.00	1.00	1.00	1.00	1.00	1.00	1.00	8.00
2	1	2	1.00	1.00	1.00	1.00	1.00	1.00	1.00	1.00	8.00
3	1	3	1.00	1.00	1.00	1.00	1.00	1.00	1.00	1.00	8.00
4	2	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
5	2	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
6	2	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
7	2	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
8	2	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
9	2	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
10	2	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
11	2	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
12	2	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
13	2	10	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
14	2	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
15	2	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
16	2	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
17	2	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
18	2	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
19	2	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
20	2	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
21	2	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
22	2	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
23	2	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
24	2	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
25	2	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
26	2	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
27	2	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
28	2	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
29	2	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
30	2	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
31	2	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
32	2	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
33	2	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
34	2	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
35	2	32	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
36	2	33	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
37	2	34	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
38	2	35	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
39	2	36	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
40	2	37	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
41	2	38	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
42	2	39	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
43	2	40	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
44	2	41	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
45	2	42	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
46	2	43	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
47	2	44	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
48	2	45	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
49	2	46	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
50	2	47	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
51	2	48	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
52	2	49	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
53	2	50	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
54	2	51	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
55	3	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
56	3	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
57	3	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
58	3	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
59	3	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
60	3	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
61	3	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
62	3	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
63	3	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
64	3	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
65	3	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
66	3	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
67	3	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
68	3	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
69	3	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
70	3	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
71	3	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
72	3	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
73	3	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
74	3	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
75	3	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
76	3	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
77	3	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
78	3	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
79	3	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
80	3	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
81	3	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
82	3	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
83	3	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
84	3	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
85	3	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
86	3	32	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
87	3	33	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
88	3	34	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
89	3	35	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
90	3	36	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
91	3	37	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
92	3	38	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
93	3	39	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
94	3	40	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
95	3	41	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
96	3	42	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
97	3	43	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
98	3	44	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
99	3	45	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
100	3	46	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
101	3	47	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
102	4	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
103	4	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
104	4	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
105	4	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
106	4	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
107	4	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
108	4	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
109	4	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
110	4	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
111	4	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
112	4	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
113	4	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
114	4	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
115	4	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
116	4	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
117	4	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
118	4	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
119	4	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
120	4	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
121	4	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
122	4	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
123	4	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
124	4	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
125	4	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
126	4	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
127	4	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
128	4	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
129	4	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
130	4	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
131	4	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
132	4	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
133	4	32	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
134	4	33	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
135	4	34	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
136	4	35	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
137	4	36	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
138	4	37	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
139	4	38	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
140	4	39	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
141	4	40	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
142	4	41	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
143	4	42	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
144	4	43	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
145	4	44	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
146	4	45	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
147	4	46	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
148	5	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
149	5	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
150	5	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
151	5	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
152	5	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
153	5	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
154	5	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
155	5	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
156	5	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
157	5	10	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
158	5	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
159	5	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
160	5	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
161	5	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
162	5	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
163	5	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
164	5	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
165	5	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
166	5	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
167	5	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
168	5	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
169	5	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
170	5	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
171	5	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
172	5	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
173	5	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
174	5	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
175	5	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
176	5	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
177	5	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
178	5	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
179	5	32	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
180	5	33	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
181	5	34	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
182	5	35	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
183	5	36	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
184	5	37	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
185	5	38	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
186	5	39	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
187	5	40	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
188	5	41	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
189	5	42	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
190	5	43	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
191	5	44	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
192	5	45	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
193	5	46	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
194	6	1	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
195	6	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
196	6	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
197	6	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
198	6	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
199	6	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
200	6	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
201	6	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
202	6	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
203	6	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
204	6	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
205	6	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
206	6	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
207	6	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
208	6	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
209	6	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
210	6	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
211	6	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
212	6	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
213	6	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
214	6	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
215	6	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
216	6	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
217	6	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
218	6	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
219	6	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
220	6	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
221	6	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
222	6	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
223	6	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
224	6	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
225	6	32	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
226	6	33	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
227	6	34	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
228	6	35	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
229	6	36	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
230	6	37	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
231	6	38	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
232	6	39	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
233	6	40	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
234	6	41	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
235	6	42	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
236	6	43	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
237	6	44	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
238	6	45	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
239	6	46	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
240	7	1	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
241	7	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
242	7	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
243	7	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
244	7	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
245	7	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
246	7	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
247	7	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
248	7	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
249	7	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
250	7	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
251	7	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
252	7	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
253	7	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
254	7	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
255	7	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
256	7	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
257	7	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
258	7	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
259	7	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
260	7	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
261	7	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
262	7	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
263	7	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
264	7	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
265	7	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
266	7	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
267	7	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
268	7	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
269	7	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
270	7	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
271	7	32	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
272	7	33	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
273	7	34	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
274	7	35	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
275	7	36	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
276	7	37	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
277	7	38	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
278	7	39	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
279	7	40	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
280	7	41	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
281	7	42	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
282	7	43	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
283	7	44	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
284	7	45	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
285	7	46	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
286	8	1	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
287	8	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
288	8	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
289	8	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
290	8	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
291	8	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
292	8	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
293	8	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
294	8	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
295	8	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
296	8	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
297	8	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
298	8	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
299	8	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
300	8	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
301	8	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
302	8	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
303	8	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
304	8	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
305	8	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
306	8	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
307	8	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
308	8	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
309	8	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
310	8	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
311	8	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
312	8	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
313	8	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
314	8	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
315	8	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
316	8	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
317	8	32	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
318	8	33	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
319	8	34	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
320	8	35	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
321	8	36	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
322	8	37	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
323	8	38	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
324	8	39	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
325	9	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
326	9	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
327	9	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
328	9	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
329	9	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
330	9	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
331	9	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
332	9	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
333	9	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
334	9	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
335	9	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
336	9	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
337	9	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
338	9	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
339	9	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
340	9	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
341	9	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
342	9	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
343	9	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
344	9	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
345	9	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
346	9	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
347	9	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
348	9	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
349	9	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
350	9	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
351	9	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
352	9	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
353	9	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
354	9	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
355	9	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
356	9	32	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
357	9	33	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
358	10	1	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
359	10	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
360	10	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
361	10	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
362	10	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
363	10	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
364	10	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
365	10	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
366	10	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
367	10	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
368	10	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
369	10	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
370	10	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
371	10	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
372	10	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
373	10	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
374	10	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
375	10	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
376	10	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
377	10	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
378	10	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
379	10	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
380	10	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
381	10	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
382	10	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
383	10	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
384	10	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
385	10	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
386	10	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
387	10	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
388	10	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
389	10	32	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
390	10	33	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
391	11	1	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
392	11	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
393	11	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
394	11	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
395	11	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
396	11	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
397	11	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
398	11	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
399	11	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
400	11	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
401	11	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
402	11	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
403	11	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
404	11	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
405	11	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
406	11	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
407	11	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
408	11	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
409	11	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
410	11	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
411	11	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
412	11	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
413	11	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
414	11	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
415	11	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
416	11	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
417	11	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
418	11	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
419	11	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
420	11	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
421	11	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
422	12	1	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
423	12	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
424	12	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
425	12	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
426	12	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
427	12	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
428	12	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
429	12	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
430	12	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
431	12	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
432	12	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
433	12	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
434	12	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
435	12	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
436	12	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
437	12	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
438	12	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
439	12	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
440	12	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
441	12	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
442	12	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
443	12	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
444	12	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
445	12	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
446	12	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
447	12	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
448	12	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
449	12	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
450	12	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
451	12	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
452	12	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
453	13	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
454	13	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
455	13	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
456	13	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
457	13	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
458	13	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
459	13	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
460	13	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
461	13	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
462	13	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
463	13	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
464	13	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
465	13	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
466	13	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
467	13	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
468	13	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
469	13	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
470	13	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
471	13	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
472	13	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
473	13	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
474	13	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
475	13	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
476	13	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
477	13	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
478	13	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
479	13	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
480	13	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
481	13	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
482	13	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
483	13	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
484	13	32	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
485	13	33	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
486	13	34	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
487	13	35	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
488	13	36	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
489	13	37	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
490	13	38	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
491	14	1	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
492	14	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
493	14	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
494	14	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
495	14	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
496	14	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
497	14	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
498	14	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
499	14	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
500	14	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
501	14	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
502	14	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
503	14	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
504	14	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
505	14	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
506	14	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
507	14	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
508	14	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
509	14	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
510	14	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
511	14	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
512	14	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
513	14	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
514	14	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
515	14	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
516	14	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
517	14	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
518	14	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
519	14	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
520	14	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
521	14	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
522	14	32	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
523	14	33	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
524	15	1	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
525	15	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
526	15	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
527	15	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
528	15	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
529	15	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
530	15	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
531	15	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
532	15	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
533	15	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
534	15	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
535	15	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
536	15	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
537	15	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
538	15	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
539	15	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
540	15	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
541	15	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
542	15	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
543	15	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
544	15	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
545	15	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
546	15	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
547	15	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
548	15	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
549	15	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
550	15	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
551	15	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
552	15	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
553	15	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
554	15	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
555	15	32	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
556	15	33	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
557	16	1	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
558	16	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
559	16	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
560	16	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
561	16	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
562	16	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
563	16	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
564	16	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
565	16	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
566	16	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
567	16	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
568	16	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
569	16	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
570	16	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
571	16	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
572	16	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
573	16	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
574	16	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
575	16	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
576	16	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
577	16	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
578	16	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
579	16	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
580	16	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
581	16	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
582	16	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
583	16	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
584	16	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
585	16	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
586	17	1	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
587	17	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
588	17	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
589	17	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
590	17	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
591	17	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
592	17	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
593	17	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
594	17	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
595	17	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
596	17	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
597	17	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
598	17	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
599	17	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
600	17	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
601	17	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
602	17	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
603	17	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
604	17	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
605	17	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
606	17	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
607	17	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
608	17	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
609	17	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
610	17	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
611	17	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
612	17	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
613	17	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
614	17	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
615	17	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
616	17	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
617	17	32	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
618	17	33	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
619	17	34	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
620	17	35	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
621	17	36	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
622	17	37	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
623	17	38	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
624	17	39	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
625	17	40	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
626	17	41	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
627	17	42	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
628	17	43	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
629	17	44	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
630	17	45	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
631	17	46	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
632	17	47	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
633	17	48	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
634	17	49	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
635	17	50	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
636	17	51	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
637	17	52	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
638	18	1	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
639	18	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
640	18	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
641	18	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
642	18	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
643	18	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
644	18	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
645	18	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
646	18	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
647	18	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
648	18	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
649	18	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
650	18	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
651	18	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
652	18	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
653	18	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
654	18	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
655	18	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
656	18	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
657	18	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
658	18	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
659	18	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
660	18	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
661	18	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
662	18	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
663	18	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
664	18	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
665	18	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
666	18	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
667	18	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
668	18	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
669	18	32	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
670	18	33	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
671	19	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
672	19	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
673	19	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
674	19	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
675	19	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
676	19	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
677	19	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
678	19	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
679	19	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
680	19	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
681	19	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
682	19	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
683	19	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
684	19	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
685	19	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
686	19	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
687	19	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
688	19	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
689	19	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
690	19	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
691	19	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
692	19	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
693	19	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
694	19	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
695	19	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
696	19	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
697	19	27	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
698	19	28	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
699	19	29	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
700	19	30	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
701	19	31	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
702	19	32	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
703	19	33	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
704	20	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
705	20	2	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
706	20	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
707	20	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
708	20	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
709	20	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
710	20	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
711	20	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
712	20	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
713	20	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
714	20	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
715	20	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
716	20	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
717	20	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
718	20	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
719	20	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
720	20	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
721	20	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
722	20	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
723	20	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
724	20	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
725	20	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
726	20	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
727	20	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
728	20	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
729	20	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
730	21	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
731	21	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
732	21	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
733	21	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
734	21	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
735	21	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
736	21	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
737	21	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
738	21	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
739	21	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
740	21	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
741	21	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
742	21	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
743	21	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
744	21	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
745	21	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
746	21	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
747	21	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
748	21	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
749	21	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
750	21	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
751	21	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
752	21	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
753	21	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
754	21	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
755	21	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
756	22	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
757	22	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
758	22	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
759	22	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
760	22	5	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
761	22	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
762	22	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
763	22	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
764	22	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
765	22	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
766	22	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
767	22	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
768	22	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
769	22	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
770	22	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
771	22	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
772	22	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
773	22	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
774	22	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
775	22	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
776	22	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
777	22	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
778	22	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
779	22	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
780	22	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
781	23	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
782	23	2	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
783	23	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
784	23	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
785	23	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
786	23	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
787	23	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
788	23	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
789	23	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
790	23	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
791	23	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
792	23	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
793	23	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
794	23	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
795	23	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
796	23	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
797	23	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
798	23	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
799	23	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
800	23	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
801	23	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
802	23	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
803	23	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
804	23	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
805	23	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
806	24	1	1.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00
807	24	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
808	24	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
809	24	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
810	24	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
811	24	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
812	24	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
813	24	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
814	24	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
815	24	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
816	24	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
817	24	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
818	24	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
819	24	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
820	24	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
821	24	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
822	24	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
823	24	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
824	24	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
825	24	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
826	24	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
827	24	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
828	25	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
829	26	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
830	27	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
831	28	1	1.00	0.00	0.00	0.00	1.00	0.00	0.00	0.00	2.00
832	29	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
833	29	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
834	29	3	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
835	29	4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
836	29	5	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
837	29	6	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
838	29	7	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
839	29	8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
840	29	9	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
841	29	10	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
842	29	11	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
843	29	12	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
844	29	13	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
845	29	14	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
846	29	15	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
847	29	16	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
848	29	17	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
849	29	18	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
850	29	19	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
851	29	20	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
852	29	21	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
853	29	22	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
854	29	23	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
855	29	24	0.00	500.00	0.00	0.00	500.00	0.00	0.00	0.00	1000.00
856	29	25	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
857	29	26	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
858	30	1	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
859	30	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00	1.00
\.


--
-- Data for Name: informes_gastos_maestro; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.informes_gastos_maestro (id_informe, folio_vpro, id_empleado, periodo_desde, periodo_hasta, vehiculo, km_inicial, km_final, departamento, num_personas, subtotal, monto_entregado, restante, fecha_registro, hora_registro, revisado) FROM stdin;
29	48	107	2026-07-16	2026-07-18	['HYUNDAI 2015'] (0-0)	0	0	PRODUCCION	6	1000.00	1000.00	0.00	2026-07-18	11:55:40.304082	t
7	7	201	2026-04-07	2026-05-22	['HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	6	1.00	1.00	0.00	2026-05-22	11:20:57.740835	t
9	9	201	2026-04-20	2026-05-22	['HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	6	0.00	1.00	1.00	2026-05-22	11:21:54.422491	t
14	14	201	2026-04-20	2026-05-22	GENERAL (0-0)	0	0	SISTEMAS	1	1.00	1.00	0.00	2026-05-22	12:49:44.77439	t
3	3	201	2026-04-06	2026-05-22	['FORD 1996'] (0-0)	0	0	SISTEMAS	8	1.00	1.00	0.00	2026-05-22	11:18:05.152259	t
22	22	201	2026-04-28	2026-05-22	['HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	7	1.00	1.00	0.00	2026-05-22	12:51:59.247356	t
23	23	201	2026-04-28	2026-05-22	['HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	7	1.00	1.00	0.00	2026-05-22	12:52:15.693379	t
4	4	201	2026-04-07	2026-05-22	['HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	5	1.00	1.00	0.00	2026-05-22	11:19:39.706506	t
16	16	201	2026-04-24	2026-05-22	['FORD 1996'] (0-0)	0	0	SISTEMAS	3	1.00	1.00	0.00	2026-05-22	12:50:22.516037	t
6	6	201	2026-04-07	2026-05-22	['HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	6	1.00	1.00	0.00	2026-05-22	11:20:23.058307	t
25	28	201	2026-05-29	2026-05-29	GENERAL (0-0)	0	0	SISTEMAS	0	0.00	0.00	0.00	2026-05-29	16:04:10.173061	t
8	8	201	2026-04-14	2026-05-22	['HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	3	1.00	1.00	0.00	2026-05-22	11:21:27.045132	t
24	24	201	2026-05-01	2026-05-22	['HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	6	1.00	1.00	0.00	2026-05-22	12:52:41.057516	t
19	19	201	2026-04-20	2026-05-22	['HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	5	0.00	1.00	1.00	2026-05-22	12:51:11.179961	t
5	5	201	2026-04-07	2026-05-22	['HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	6	1.00	1.00	0.00	2026-05-22	11:20:01.942842	t
21	21	201	2026-04-27	2026-05-22	GENERAL (0-0)	0	0	SISTEMAS	2	0.00	1.00	1.00	2026-05-22	12:51:45.974522	t
13	13	201	2026-04-15	2026-05-22	['FORD 1996'] (0-0)	0	0	SISTEMAS	4	0.00	1.00	1.00	2026-05-22	12:49:20.204716	t
15	15	201	2026-04-20	2026-05-22	['NISSAN #02 2013'] (0-0)	0	0	SISTEMAS	2	1.00	1.00	0.00	2026-05-22	12:50:07.119475	t
2	2	201	2026-04-01	2026-05-21	['HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	5	1.00	1.00	0.00	2026-05-21	18:44:39.422122	t
18	18	201	2026-04-20	2026-05-22	['HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	5	1.00	1.00	0.00	2026-05-22	12:50:54.501685	t
10	10	201	2026-04-20	2026-05-22	['HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	6	1.00	1.00	0.00	2026-05-22	11:23:00.316943	t
12	12	201	2026-04-22	2026-05-22	['FORD 1996' (0-0), 'HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	4	1.00	1.00	0.00	2026-05-22	12:49:04.09272	t
1	33	119	2026-05-12	2026-05-14	['HYUNDAI 2015' (0-0), 'FORD 1996' (0-0), 'MERCEDES BENZ 2021' (0-0), 'NISSAN #02 2013'] (0-0)	0	0	Producción	6	24.00	25.00	1.00	2026-05-14	11:24:34.763103	t
17	17	201	2026-04-01	2026-05-22	['HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	5	1.00	1.00	0.00	2026-05-22	12:50:39.481202	t
11	11	201	2026-04-22	2026-05-22	['FORD 1996' (0-0), 'HYUNDAI 2015'] (0-0)	0	0	SISTEMAS	6	1.00	1.00	0.00	2026-05-22	11:23:23.723255	t
28	27	201	2026-05-29	2026-05-29	GENERAL (0-0)	0	0	SISTEMAS	0	2.00	5.00	3.00	2026-05-29	16:52:24.408804	t
27	26	201	2026-05-29	2026-05-29	GENERAL (0-0)	0	0	SISTEMAS	0	0.00	0.00	0.00	2026-05-29	16:04:57.617421	t
26	25	201	2026-05-29	2026-05-29	GENERAL (0-0)	0	0	SISTEMAS	0	0.00	0.00	0.00	2026-05-29	16:04:33.648024	t
20	20	201	2026-04-27	2026-05-22	['NISSAN #04 2013' (0-0), 'FORD 1996'] (0-0)	0	0	SISTEMAS	7	1.00	1.00	0.00	2026-05-22	12:51:32.934721	t
30	71	102	2026-07-29	2026-07-30	GENERAL (0-0)	0	0	EDICION	4	1.00	1.00	0.00	2026-07-30	13:43:35.002395	t
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
189	202	IEES en estudio de Vpro	[{"ID": "Inv_Vpro_alt_00157", "CANT": 1, "EQUIPO": "Laptop HP", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00252", "CANT": 1, "EQUIPO": "Tablet Android", "OBSERVACIONES": ""}]
192	113	Kit Grabaciones	[{"ID": "Inv_Vpro_alt_00236", "CANT": 1, "EQUIPO": "Sony Alpha VIII", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00237", "CANT": 1, "EQUIPO": "Estabilizador DJI", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00252", "CANT": 1, "EQUIPO": "botella de agua etiqueta azul de 600 ml", "OBSERVACIONES": "esta botella la tome de la mesa y nadie s dio cuenta cod vpned"}, {"ID": "Inv_Vpro_alt_00253", "CANT": 1, "EQUIPO": "este es de pilon", "OBSERVACIONES": "None"}]
195	201	Jornadas de paz	[{"ID": "Inv_Vpro_alt_00015", "CANT": 1, "EQUIPO": "Starklink con maleta, modem,soporte, adaptador a ethernet, cable especial ethernet-par starlink de 18 mts.", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00019", "CANT": 1, "EQUIPO": "Caja con 50 cables de red de dif tamaños", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00023", "CANT": 8, "EQUIPO": "pisacables", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00024", "CANT": 1, "EQUIPO": "Tripie", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00093", "CANT": 1, "EQUIPO": "cable especial de 50 mts de starlink", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00181", "CANT": 2, "EQUIPO": "Extension electrica", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00182", "CANT": 1, "EQUIPO": "Switch de 48 puertos", "OBSERVACIONES": ""}, {"ID": "Inv_Vpro_alt_00252", "CANT": 1, "EQUIPO": "Mesita plegable de 1 mts.", "OBSERVACIONES": "None"}, {"ID": "Inv_Vpro_alt_00253", "CANT": 1, "EQUIPO": "Ups marca guia", "OBSERVACIONES": "None"}]
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
276	109	KIT ENLACE PRESIDENTA MOCHIS	[{"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "Cables HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26466", "CANT": 3, "EQUIPO": "cables XLR", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26558", "CANT": 2, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "Peavey Interfase", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "Stream Deck", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "Adaptador tipo C a HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090024", "CANT": 4, "EQUIPO": "Baterias AA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090014", "CANT": 1, "EQUIPO": "Transmisor de audio SONY VPNAUD009", "OBSERVACIONES": "[CUST_EQ:Transmisor de audio SONY VPNAUD009] None"}, {"ID": "INV_ALT_1090015", "CANT": 3, "EQUIPO": "Receptor de audio SONY VPNAUD008", "OBSERVACIONES": "[CUST_EQ:Receptor de audio SONY VPNAUD008] None"}, {"ID": "INV_ALT_1090016", "CANT": 1, "EQUIPO": "Microfono de solapa SONY VPNAUD001", "OBSERVACIONES": "[CUST_EQ:Microfono de solapa SONY VPNAUD001] None"}, {"ID": "INV_ALT_1090017", "CANT": 3, "EQUIPO": "Diademas de comunicaciÃÂÃÂ³n BEHRINGER VPNAUD065", "OBSERVACIONES": "[CUST_EQ:Diademas de comunicaciÃÂÃÂÃÂÃÂ³n BEHRINGER VPNAUD065] None"}, {"ID": "INV_ALT_1090018", "CANT": 1, "EQUIPO": "Diadema de comunicaciÃÂÃÂ³n SONY VPNAUD019", "OBSERVACIONES": "[CUST_EQ:Diadema de comunicaciÃÂÃÂÃÂÃÂ³n SONY VPNAUD019] None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "Hub USB", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26418", "CANT": 2, "EQUIPO": "Hub 1x7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26433", "CANT": 2, "EQUIPO": "Hub 1x6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090025", "CANT": 8, "EQUIPO": "bateria AA", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26256", "CANT": 1, "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26326", "CANT": 1, "EQUIPO": "Consola audio (mini vMix)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26361", "CANT": 2, "EQUIPO": "mac #3 y #4", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090023", "CANT": 2, "EQUIPO": "bocina con cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090027", "CANT": 1, "EQUIPO": "Consola ZENI 8", "OBSERVACIONES": "[CUST_EQ:Consola ZENI 8] None"}, {"ID": "Inv_alt_1090028", "CANT": 1, "EQUIPO": "Laptop G7", "OBSERVACIONES": "[CUST_EQ:Laptop G7] None"}]
236	104	Grabación al campo	[{"ID": "INV_VPRO_ALT_00236", "CANT": 3, "EQUIPO": "tripies", "OBSERVACIONES": "None"}, {"ID": "Inv_alt_1040001", "CANT": 1, "EQUIPO": "kit de luces", "OBSERVACIONES": "[CUST_EQ:kit de luces] None"}, {"ID": "INV_VPRO_ALT_00237", "CANT": 3, "EQUIPO": "baterias sony", "OBSERVACIONES": "None"}, {"ID": "Inv_alt_1040002", "CANT": 2, "EQUIPO": "baterias zgzine", "OBSERVACIONES": "[CUST_EQ:baterias zgzine] None"}, {"ID": "Inv_alt_1040003", "CANT": 1, "EQUIPO": "cargador de pila", "OBSERVACIONES": "[CUST_EQ:cargador de pila] None"}]
239	105	CASA LEY	[{"ID": "INV_VPRO_ALT_00235", "CANT": 1, "EQUIPO": "KIT LUCES", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00236", "CANT": 3, "EQUIPO": "TRIPIES", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00237", "CANT": 3, "EQUIPO": "BATERIAS SONY", "OBSERVACIONES": ""}]
243	104	Kit Semanera	[{"ID": "INV_VPRO_ALT_00042", "CANT": 2, "EQUIPO": "Pantalla  55\\"", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00052", "CANT": 10, "EQUIPO": "cable hdmi", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00053", "CANT": 10, "EQUIPO": "Extensiones", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00057", "CANT": 1, "EQUIPO": "Distribuidor de HDMI de 4", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00058", "CANT": 2, "EQUIPO": "Distribuidor de HDMI de 2", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00065", "CANT": 2, "EQUIPO": "Multicontacto", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00081", "CANT": 2, "EQUIPO": "Base de Madera Tv", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00082", "CANT": 1, "EQUIPO": "Dolly's", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00085", "CANT": 2, "EQUIPO": "tela de base", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00086", "CANT": 8, "EQUIPO": "Yellow Jake(pisacable)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16456", "CANT": 1, "EQUIPO": "mesa", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040001", "CANT": 2, "EQUIPO": "kit de luces", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16469", "CANT": 3, "EQUIPO": "sillas", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00173", "CANT": 8, "EQUIPO": "cable sdi", "OBSERVACIONES": "None"}]
279	201	KIT_STD_EVENTOS_FUERA_DE_OFICINAS	[{"ID": "INV_VPRO_ALT_00013", "CANT": 1, "EQUIPO": "Laptop Asus con adaptador de red y cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00016", "CANT": 1, "EQUIPO": "Access Point TP-Link modelo  AX3600", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00017", "CANT": 1, "EQUIPO": "Switch de 5 puertos metalico", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00018", "CANT": 1, "EQUIPO": "Switch de 5 puertos de plastico negro", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00019", "CANT": 1, "EQUIPO": "Caja grande c/tapa azul con 50 cables cortos y largos", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00021", "CANT": 1, "EQUIPO": "Pinza para ponchar cables ethernet", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00022", "CANT": 35, "EQUIPO": "plugs para cables ethernet", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00023", "CANT": 10, "EQUIPO": "pisacables", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "CANT": 2, "EQUIPO": "Tripie", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00025", "CANT": 1, "EQUIPO": "UPS", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00092", "CANT": 1, "EQUIPO": "escalera plegable", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2010002", "CANT": 1, "EQUIPO": "Tablet", "OBSERVACIONES": ""}]
280	119	KIT EVENTO ESPECIAL 3 CAMARAS	[{"ID": "INV_VPRO_ALT_00045", "CANT": 3, "EQUIPO": "camaras 320", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00001", "CANT": 3, "EQUIPO": "tripies", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00097", "CANT": 10, "EQUIPO": "baterias", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00098", "CANT": 4, "EQUIPO": "fuentes de poder", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00099", "CANT": 6, "EQUIPO": "radios", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00100", "CANT": 1, "EQUIPO": "balanceador", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00102", "CANT": 1, "EQUIPO": "monitor de ingeneria", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00103", "CANT": 3, "EQUIPO": "monitor lilliput", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00104", "CANT": 2, "EQUIPO": "bancos", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_23622", "CANT": 3, "EQUIPO": "paraguas", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190001", "CANT": 2, "EQUIPO": "tripies para paraguas", "OBSERVACIONES": "[CUST_EQ:tripies para paraguas] None"}, {"ID": "INV_ALT_1190002", "CANT": 2, "EQUIPO": "extenciones de energia", "OBSERVACIONES": "[CUST_EQ:extenciones de energia] None"}, {"ID": "INV_ALT_1190003", "CANT": 1, "EQUIPO": "mochila negra", "OBSERVACIONES": "[CUST_EQ:mochila negra] None"}, {"ID": "INV_ALT_1190004", "CANT": 2, "EQUIPO": "abanicos", "OBSERVACIONES": "[CUST_EQ:abanicos] None"}, {"ID": "INV_ALT_1190005", "CANT": 2, "EQUIPO": "decimator", "OBSERVACIONES": "[CUST_EQ:decimator] None"}, {"ID": "INV_ALT_1190006", "CANT": 2, "EQUIPO": "distribuidores", "OBSERVACIONES": "[CUST_EQ:distribuidores] None"}, {"ID": "INV_ALT_1190007", "CANT": 1, "EQUIPO": "splinter", "OBSERVACIONES": "[CUST_EQ:splinter] None"}, {"ID": "INV_VPRO_ALT_00206", "CANT": 2, "EQUIPO": "convertidores blackmagic", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1190008", "CANT": 8, "EQUIPO": "cables sdi varios 1 metro", "OBSERVACIONES": "[CUST_EQ:cables sdi varios 1 metro] None"}, {"ID": "INV_ALT_1190009", "CANT": 4, "EQUIPO": "cables HDMI 1 metro", "OBSERVACIONES": "[CUST_EQ:cables HDMI 1 metro] None"}, {"ID": "INV_ALT_1190014", "CANT": 2, "EQUIPO": "energia", "OBSERVACIONES": "[CUST_EQ:energia] None"}, {"ID": "INV_ALT_1190015", "CANT": 1, "EQUIPO": "minicontacto de nergi blnco", "OBSERVACIONES": "[CUST_EQ:minicontacto de nergi blnco] None"}, {"ID": "INV_ALT_1190016", "CANT": 2, "EQUIPO": "cables usb mini hdmi (rojo y negro)", "OBSERVACIONES": "[CUST_EQ:cables usb mini hdmi (rojo y negro)] None"}]
256	105	Kit enlace Presidenta	[{"ID": "INV_ALT_1050006", "CANT": 1, "EQUIPO": "base de fierro", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1040001", "CANT": 1, "EQUIPO": "kit de luces", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050003", "CANT": 1, "EQUIPO": "Pantalla de 50\\"", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00052", "CANT": 1, "EQUIPO": "cable hdmi", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16418", "CANT": 4, "EQUIPO": "extensiones", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050004", "CANT": 1, "EQUIPO": "hdmi 100 mts", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1050005", "CANT": 1, "EQUIPO": "dolly", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_16456", "CANT": 1, "EQUIPO": "mesa", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00173", "CANT": 3, "EQUIPO": "cable sdi", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00024", "CANT": 1, "EQUIPO": "tripie", "OBSERVACIONES": "None"}]
257	109	KIT ENLACE Y CIRCUITO CERRADO	[{"ID": "VPRO_ALT_26448", "CANT": 14, "EQUIPO": "HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26466", "CANT": 3, "EQUIPO": "cables XLR", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26493", "CANT": 1, "EQUIPO": "convertidor blackmagic vimodal", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26522", "CANT": 2, "EQUIPO": "convertidor blackmagic (HDMI-SDI)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26558", "CANT": 2, "EQUIPO": "convertidor blackmagic (SDI-HDMI)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26591", "CANT": 2, "EQUIPO": "peavey", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26607", "CANT": 1, "EQUIPO": "stream deck", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26673", "CANT": 1, "EQUIPO": "adaptador tipo C a HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26703", "CANT": 1, "EQUIPO": "HDMI splitter (1x2)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090024", "CANT": 12, "EQUIPO": "Baterias AA", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090014", "CANT": 1, "EQUIPO": "Transmisor de audio SONY VPNAUD009", "OBSERVACIONES": "[CUST_EQ:Transmisor de audio SONY VPNAUD009] None"}, {"ID": "INV_ALT_1090015", "CANT": 4, "EQUIPO": "Receptor de audio SONY VPNAUD008", "OBSERVACIONES": "[CUST_EQ:Receptor de audio SONY VPNAUD008] None"}, {"ID": "INV_ALT_1090016", "CANT": 1, "EQUIPO": "Microfono de solapa SONY VPNAUD001", "OBSERVACIONES": "[CUST_EQ:Microfono de solapa SONY VPNAUD001] None"}, {"ID": "INV_ALT_1090017", "CANT": 4, "EQUIPO": "Diademas de comunicaciÃÂ³n BEHRINGER VPNAUD065", "OBSERVACIONES": "[CUST_EQ:Diademas de comunicaciÃÂÃÂ³n BEHRINGER VPNAUD065] None"}, {"ID": "INV_ALT_1090018", "CANT": 1, "EQUIPO": "Diadema de comunicaciÃÂ³n SONY VPNAUD019", "OBSERVACIONES": "[CUST_EQ:Diadema de comunicaciÃÂÃÂ³n SONY VPNAUD019] None"}, {"ID": "VPRO_ALT_26379", "CANT": 1, "EQUIPO": "hub USB", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26418", "CANT": 2, "EQUIPO": "hub 1x7", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26433", "CANT": 1, "EQUIPO": "hub 1x6", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090025", "CANT": 4, "EQUIPO": "bateria AA", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26256", "CANT": 1, "EQUIPO": "caja Vmix", "OBSERVACIONES": "Esta caja contiene el CPU que se utiliza para los eventos"}, {"ID": "VPRO_ALT_26302", "CANT": 1, "EQUIPO": "Atem HDMI", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26326", "CANT": 1, "EQUIPO": "Consola audio (mini vMix)", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26346", "CANT": 3, "EQUIPO": "capturadoras hdmi", "OBSERVACIONES": ""}, {"ID": "VPRO_ALT_26361", "CANT": 2, "EQUIPO": "mac #3 y #4", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00253", "CANT": 3, "EQUIPO": "receptor sony", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00255", "CANT": 3, "EQUIPO": "microfono lavalier", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090021", "CANT": 3, "EQUIPO": "cables XLR (3.5 Milimetros)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090022", "CANT": 4, "EQUIPO": "cables xlr (5mts)", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090023", "CANT": 2, "EQUIPO": "bocina con cable de corriente", "OBSERVACIONES": ""}, {"ID": "INV_ALT_1090026", "CANT": 3, "EQUIPO": "transmisores sony", "OBSERVACIONES": ""}]
268	202	Jornadas de la paz 1	[{"ID": "INV_VPRO_ALT_00242", "CANT": 2, "EQUIPO": "Antena starlink 03, 02", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00243", "CANT": 1, "EQUIPO": "UPS (No break) Koblenz", "OBSERVACIONES": "VPNRED099"}, {"ID": "INV_VPRO_ALT_00244", "CANT": 1, "EQUIPO": "Mesa pequeÃÂÃÂÃÂÃÂ±a", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "CANT": 1, "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "CANT": 1, "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00248", "CANT": 1, "EQUIPO": "ExtensiÃÂÃÂÃÂÃÂ³n elÃÂÃÂÃÂÃÂ©ctrica corta", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00250", "CANT": 1, "EQUIPO": "TripiÃÂÃÂÃÂÃÂ© para bocina (sin tubo extensor)", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00252", "CANT": 2, "EQUIPO": "Adaptador ethernet usb", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00254", "CANT": 10, "EQUIPO": "Pisa cables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020001", "CANT": 1, "EQUIPO": "Cable largo para starlink", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020002", "CANT": 1, "EQUIPO": "Cable ethernet corto", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020003", "CANT": 6, "EQUIPO": "Cable ethernet largo", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00189", "CANT": 1, "EQUIPO": "Pinza ponchadora", "OBSERVACIONES": "None"}, {"ID": "INV_ALT_2020005", "CANT": 2, "EQUIPO": "Swich de 8 puerto", "OBSERVACIONES": "None"}]
265	202	Jornadas de la paz - Bueno	[{"ID": "INV_VPRO_ALT_00236", "CANT": 1, "EQUIPO": "TRIPIES", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00242", "CANT": 2, "EQUIPO": "Antena starlink 03, 02", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00243", "CANT": 1, "EQUIPO": "UPS (No break) Koblenz", "OBSERVACIONES": "VPNRED099"}, {"ID": "INV_VPRO_ALT_00244", "CANT": 1, "EQUIPO": "Mesa pequeÃÂÃÂ±a", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "CANT": 1, "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "CANT": 1, "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00248", "CANT": 1, "EQUIPO": "ExtensiÃÂÃÂ³n elÃÂÃÂ©ctrica corta", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00250", "CANT": 2, "EQUIPO": "TripiÃÂÃÂ© para bocina (sin tubo extensor)", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00252", "CANT": 2, "EQUIPO": "Adaptador ethernet usb", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00253", "CANT": 1, "EQUIPO": "receptor sony", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00254", "CANT": 10, "EQUIPO": "Pisa cables", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00255", "CANT": 2, "EQUIPO": "microfono lavalier", "OBSERVACIONES": "VPNRED095"}, {"ID": "INV_ALT_2020001", "CANT": 1, "EQUIPO": "Cable largo para starlink", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020002", "CANT": 1, "EQUIPO": "Cable ethernet corto", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020003", "CANT": 6, "EQUIPO": "Cable ethernet largo", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020004", "CANT": 1, "EQUIPO": "Caja con cables ethernet", "OBSERVACIONES": ""}]
267	202	Jornadas de la paz	[{"ID": "INV_VPRO_ALT_00242", "CANT": 2, "EQUIPO": "Antena starlink 03, 02", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00243", "CANT": 1, "EQUIPO": "UPS (No break) Koblenz", "OBSERVACIONES": "VPNRED099"}, {"ID": "INV_VPRO_ALT_00244", "CANT": 1, "EQUIPO": "Mesa pequeÃÂÃÂÃÂÃÂ±a", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00245", "CANT": 1, "EQUIPO": "Desarmador de estrella", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00246", "CANT": 1, "EQUIPO": "Desarmador de pala", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00248", "CANT": 1, "EQUIPO": "ExtensiÃÂÃÂÃÂÃÂ³n elÃÂÃÂÃÂÃÂ©ctrica corta", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00250", "CANT": 1, "EQUIPO": "TripiÃÂÃÂÃÂÃÂ© para bocina (sin tubo extensor)", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00252", "CANT": 2, "EQUIPO": "Adaptador ethernet usb", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00254", "CANT": 10, "EQUIPO": "Pisa cables", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020001", "CANT": 1, "EQUIPO": "Cable largo para starlink", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020002", "CANT": 1, "EQUIPO": "Cable ethernet corto", "OBSERVACIONES": ""}, {"ID": "INV_ALT_2020003", "CANT": 6, "EQUIPO": "Cable ethernet largo", "OBSERVACIONES": ""}, {"ID": "INV_VPRO_ALT_00189", "CANT": 1, "EQUIPO": "Pinza ponchadora", "OBSERVACIONES": "None"}, {"ID": "Inv_alt_2020005", "CANT": 2, "EQUIPO": "Swich de 8 puerto", "OBSERVACIONES": "[CUST_EQ:Swich de 8 puerto] None"}]
278	104	Enlace en el carrizo	[{"ID": "VPRO_ALT_26448", "CANT": 4, "EQUIPO": "Cables hdmi", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_16418", "CANT": 4, "EQUIPO": "Extensiones", "OBSERVACIONES": "None"}, {"ID": "Inv_alt_1040004", "CANT": 6, "EQUIPO": "SDI", "OBSERVACIONES": "[CUST_EQ:SDI] None"}, {"ID": "Inv_alt_1040005", "CANT": 1, "EQUIPO": "Distribuidor hdmi 4", "OBSERVACIONES": "[CUST_EQ:Distribuidor hdmi 4] None"}, {"ID": "Inv_alt_1040006", "CANT": 1, "EQUIPO": "Monitor de 55\\"", "OBSERVACIONES": "[CUST_EQ:Monitor de 55\\"] None"}, {"ID": "INV_ALT_1050006", "CANT": 1, "EQUIPO": "Base de fierro", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_16530", "CANT": 2, "EQUIPO": "Multicontactos", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_16456", "CANT": 1, "EQUIPO": "Mesa", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_16469", "CANT": 3, "EQUIPO": "Sillas", "OBSERVACIONES": "None"}, {"ID": "VPRO_ALT_16484", "CANT": 1, "EQUIPO": "Carpa", "OBSERVACIONES": "None"}, {"ID": "Inv_alt_1040007", "CANT": 1, "EQUIPO": "Abaniquito", "OBSERVACIONES": "[CUST_EQ:Abaniquito] None"}]
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
-- Name: checkouts_detalle_id_detalle_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.checkouts_detalle_id_detalle_seq', 4558, true);


--
-- Name: checkouts_maestro_id_maestro_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.checkouts_maestro_id_maestro_seq', 249, true);


--
-- Name: eventos_id_evento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.eventos_id_evento_seq', 1, false);


--
-- Name: informes_gastos_detalle_id_detalle_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.informes_gastos_detalle_id_detalle_seq', 859, true);


--
-- Name: informes_gastos_maestro_id_informe_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.informes_gastos_maestro_id_informe_seq', 30, true);


--
-- Name: kits_empleados_id_kit_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kits_empleados_id_kit_seq', 280, true);


--
-- Name: mantenimiento_equipos_id_solicitud_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mantenimiento_equipos_id_solicitud_seq', 1, false);


--
-- Name: plantillas_checkout_id_plantilla_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.plantillas_checkout_id_plantilla_seq', 1, false);


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

\unrestrict p81KFHjzDiJycu37ZBidTehZEmsokgQGr73ooIBYvcbnV1vHasbmKoSkKR2du1R

