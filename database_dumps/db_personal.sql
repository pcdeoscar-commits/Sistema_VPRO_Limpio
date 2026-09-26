--
-- PostgreSQL database dump
--

\restrict XcQeh3pF7nXbrfZWNYBIXySgdYl7fYbdzOG91RlVzu6TD0UdbXic3QmGb7DvOvr

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

ALTER TABLE IF EXISTS ONLY public.control_asistencia DROP CONSTRAINT IF EXISTS fk_empleado;
ALTER TABLE IF EXISTS ONLY public.empleados DROP CONSTRAINT IF EXISTS vpro_pkey;
ALTER TABLE IF EXISTS ONLY public.control_asistencia DROP CONSTRAINT IF EXISTS uq_empleado_fecha;
ALTER TABLE IF EXISTS ONLY public.log_accesos DROP CONSTRAINT IF EXISTS log_accesos_pkey;
ALTER TABLE IF EXISTS ONLY public.departamentos DROP CONSTRAINT IF EXISTS departamentos_pkey;
ALTER TABLE IF EXISTS ONLY public.departamentos DROP CONSTRAINT IF EXISTS departamentos_nombre_key;
ALTER TABLE IF EXISTS ONLY public.control_asistencia DROP CONSTRAINT IF EXISTS control_asistencia_pkey;
ALTER TABLE IF EXISTS ONLY public.asistencia_eventos DROP CONSTRAINT IF EXISTS asistencia_eventos_pkey;
ALTER TABLE IF EXISTS public.log_accesos ALTER COLUMN id_log DROP DEFAULT;
ALTER TABLE IF EXISTS public.departamentos ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.control_asistencia ALTER COLUMN id_registro DROP DEFAULT;
ALTER TABLE IF EXISTS public.asistencia_eventos ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.log_accesos_id_log_seq;
DROP TABLE IF EXISTS public.log_accesos;
DROP TABLE IF EXISTS public.empleados;
DROP SEQUENCE IF EXISTS public.departamentos_id_seq;
DROP TABLE IF EXISTS public.departamentos;
DROP SEQUENCE IF EXISTS public.control_asistencia_id_registro_seq;
DROP TABLE IF EXISTS public.control_asistencia;
DROP SEQUENCE IF EXISTS public.asistencia_eventos_id_seq;
DROP TABLE IF EXISTS public.asistencia_eventos;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: asistencia_eventos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.asistencia_eventos (
    id integer NOT NULL,
    id_empleado character varying,
    nombre_empleado text,
    cliente text,
    fecha_evento date
);


ALTER TABLE public.asistencia_eventos OWNER TO postgres;

--
-- Name: asistencia_eventos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.asistencia_eventos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.asistencia_eventos_id_seq OWNER TO postgres;

--
-- Name: asistencia_eventos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.asistencia_eventos_id_seq OWNED BY public.asistencia_eventos.id;


--
-- Name: control_asistencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.control_asistencia (
    id_registro integer NOT NULL,
    id_empleado character varying(50) NOT NULL,
    fecha date DEFAULT CURRENT_DATE,
    hora_entrada time without time zone,
    hora_salida time without time zone,
    estatus character varying(20) DEFAULT 'ASISTENCIA'::character varying,
    observaciones text,
    hora_entrada_v time without time zone,
    hora_salida_v time without time zone
);


ALTER TABLE public.control_asistencia OWNER TO postgres;

--
-- Name: control_asistencia_id_registro_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.control_asistencia_id_registro_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.control_asistencia_id_registro_seq OWNER TO postgres;

--
-- Name: control_asistencia_id_registro_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.control_asistencia_id_registro_seq OWNED BY public.control_asistencia.id_registro;


--
-- Name: departamentos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departamentos (
    id integer NOT NULL,
    nombre text NOT NULL
);


ALTER TABLE public.departamentos OWNER TO postgres;

--
-- Name: departamentos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.departamentos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departamentos_id_seq OWNER TO postgres;

--
-- Name: departamentos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.departamentos_id_seq OWNED BY public.departamentos.id;


--
-- Name: empleados; Type: TABLE; Schema: public; Owner: vpro_dbadmin
--

CREATE TABLE public.empleados (
    id_empleado character varying(3) NOT NULL,
    nombre character varying,
    depto character varying,
    email character varying,
    cel character varying,
    fecha_nac date NOT NULL,
    fecha_ing date NOT NULL,
    licencia_vence date,
    password text,
    rol character varying(20) DEFAULT 'PRODUCTOR'::character varying
);


ALTER TABLE public.empleados OWNER TO vpro_dbadmin;

--
-- Name: log_accesos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log_accesos (
    id_log integer NOT NULL,
    fecha date DEFAULT CURRENT_DATE,
    hora time without time zone DEFAULT CURRENT_TIME,
    ip_origen text,
    id_empleado integer,
    nombre_empleado text,
    tipo_evento text
);


ALTER TABLE public.log_accesos OWNER TO postgres;

--
-- Name: log_accesos_id_log_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_accesos_id_log_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.log_accesos_id_log_seq OWNER TO postgres;

--
-- Name: log_accesos_id_log_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_accesos_id_log_seq OWNED BY public.log_accesos.id_log;


--
-- Name: asistencia_eventos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asistencia_eventos ALTER COLUMN id SET DEFAULT nextval('public.asistencia_eventos_id_seq'::regclass);


--
-- Name: control_asistencia id_registro; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.control_asistencia ALTER COLUMN id_registro SET DEFAULT nextval('public.control_asistencia_id_registro_seq'::regclass);


--
-- Name: departamentos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamentos ALTER COLUMN id SET DEFAULT nextval('public.departamentos_id_seq'::regclass);


--
-- Name: log_accesos id_log; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_accesos ALTER COLUMN id_log SET DEFAULT nextval('public.log_accesos_id_log_seq'::regclass);


--
-- Data for Name: asistencia_eventos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.asistencia_eventos (id, id_empleado, nombre_empleado, cliente, fecha_evento) FROM stdin;
\.


--
-- Data for Name: control_asistencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.control_asistencia (id_registro, id_empleado, fecha, hora_entrada, hora_salida, estatus, observaciones, hora_entrada_v, hora_salida_v) FROM stdin;
1	201	2026-07-27	17:06:39	17:07:54	RETARDO	Checada Lector USB - Turno Vespertino | Salida: Checada Lector USB - Salida Fin de Jornada	\N	\N
2	109	2026-07-27	19:00:23	\N	RETARDO	Checada Lector USB - Turno Vespertino	\N	\N
3	113	2026-07-27	19:00:32	\N	RETARDO	Checada Lector USB - Turno Vespertino	\N	\N
4	119	2026-07-27	19:00:37	\N	RETARDO	Checada Lector USB - Turno Vespertino	\N	\N
5	124	2026-07-27	19:01:02	\N	RETARDO	Checada Lector USB - Turno Vespertino	\N	\N
6	107	2026-07-27	19:01:16	\N	RETARDO	Checada Lector USB - Turno Vespertino	\N	\N
7	104	2026-07-27	19:01:29	\N	RETARDO	Checada Lector USB - Turno Vespertino	\N	\N
8	200	2026-07-27	19:01:55	\N	RETARDO	Checada Lector USB - Turno Vespertino	\N	\N
9	121	2026-07-27	19:06:29	\N	RETARDO	Checada Lector USB - Turno Vespertino	\N	\N
10	109	2026-07-28	06:52:58	\N	ASISTENCIA	Checada Lector USB - Turno Matutino	\N	\N
11	113	2026-07-28	07:09:00	\N	ASISTENCIA	Checada Lector USB - Turno Matutino	\N	\N
12	115	2026-07-28	08:40:34	\N	ASISTENCIA	Checada Lector USB - Turno Matutino	\N	\N
13	121	2026-07-28	08:40:46	\N	ASISTENCIA	Checada Lector USB - Turno Matutino	\N	\N
14	200	2026-07-28	08:41:01	13:39:01	ASISTENCIA	Checada Lector USB - Turno Matutino | Salida: Kiosco - Comida	\N	\N
18	201	2026-07-28	08:58:40	13:55:48	ASISTENCIA	Checada Lector USB - Turno Matutino | Salida: Kiosco - Comida	\N	\N
15	202	2026-07-28	08:54:51	16:39:06	ASISTENCIA	Checada Lector USB - Turno Matutino | Salida: Kiosco - Fin Jornada	\N	\N
16	104	2026-07-28	08:57:45	16:39:25	ASISTENCIA	Checada Lector USB - Turno Matutino | Salida: Kiosco - Fin Jornada	\N	\N
19	119	2026-07-28	08:58:45	16:55:23	ASISTENCIA	Checada Lector USB - Turno Matutino | Salida: Kiosco - Fin Jornada	\N	\N
17	124	2026-07-28	08:58:18	16:55:41	ASISTENCIA	Checada Lector USB - Turno Matutino | Salida: Kiosco - Fin Jornada	\N	\N
20	107	2026-07-28	09:06:57	19:00:42	RETARDO	Checada Lector USB - Turno Matutino | Salida: Kiosco - Fin Jornada	\N	\N
22	125	2026-07-29	08:55:24	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
24	115	2026-07-29	08:55:35	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
23	202	2026-07-29	08:55:30	16:01:03	ASISTENCIA	Kiosco - T. Matutino | Salida: Kiosco - Fin Jornada	\N	\N
30	119	2026-07-29	09:09:17	16:01:09	RETARDO	Kiosco - T. Matutino | Salida: Kiosco - Fin Jornada	\N	\N
27	104	2026-07-29	09:00:36	16:01:19	ASISTENCIA	Kiosco - T. Matutino | Salida: Kiosco - Fin Jornada	\N	\N
29	107	2026-07-29	09:08:54	16:02:35	RETARDO	Kiosco - T. Matutino | Salida: Kiosco - Fin Jornada	\N	\N
25	105	2026-07-29	08:55:39	16:02:54	ASISTENCIA	Kiosco - T. Matutino | Salida: Kiosco - Fin Jornada	\N	\N
33	201	2026-07-29	09:37:14	16:02:56	RETARDO	Kiosco - T. Matutino | Salida: Kiosco - Fin Jornada	\N	\N
21	121	2026-07-29	08:55:21	16:29:07	ASISTENCIA	Kiosco - T. Matutino | Salida: Kiosco - Fin Jornada	\N	\N
26	200	2026-07-29	08:56:00	16:29:13	ASISTENCIA	Kiosco - T. Matutino | Salida: Kiosco - Fin Jornada	\N	\N
28	124	2026-07-29	09:08:38	16:33:18	RETARDO	Kiosco - T. Matutino | Salida: Kiosco - Fin Jornada	\N	\N
31	113	2026-07-29	09:17:42	16:34:00	RETARDO	Kiosco - T. Matutino | Salida: Kiosco - Fin Jornada	\N	\N
32	109	2026-07-29	09:31:00	18:57:46	RETARDO	Kiosco - T. Matutino | Salida: Kiosco - Fin Jornada	\N	\N
43	125	2026-07-30	09:47:50	13:33:28	RETARDO	Kiosco - T. Matutino | Salida: Kiosco - Comida	\N	\N
49	125	2026-07-31	08:40:37	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
39	107	2026-07-30	09:01:14	14:01:39	RETARDO	Kiosco - T. Matutino | Salida: Kiosco - Comida	\N	\N
36	115	2026-07-30	08:56:17	14:01:45	ASISTENCIA	Kiosco - T. Matutino | Salida: Kiosco - Comida	\N	\N
34	119	2026-07-30	08:56:06	14:01:49	ASISTENCIA	Kiosco - T. Matutino | Salida: Kiosco - Comida	\N	\N
38	104	2026-07-30	08:59:31	14:02:09	COMPLETO	Kiosco - T. Matutino | Salida: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:24:20	16:33:11
41	113	2026-07-30	09:13:24	14:13:33	RETARDO	Kiosco - T. Matutino | Salida: Kiosco - Comida	\N	\N
40	202	2026-07-30	09:01:36	14:42:59	RETARDO	Kiosco - T. Matutino | Salida: Kiosco - Comida	\N	\N
37	124	2026-07-30	08:56:28	14:01:34	ASISTENCIA	Kiosco - T. Matutino | Salida: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino	16:56:11	\N
42	109	2026-07-30	09:26:36	15:54:17	RETARDO	Kiosco - T. Matutino | Salida: Kiosco - Fin Jornada | Entrada V: Kiosco - T. Vespertino	18:58:37	\N
35	201	2026-07-30	08:56:10	14:01:53	COMPLETO	Kiosco - T. Matutino | Salida: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:17:23	18:58:48
44	121	2026-07-30	09:48:07	13:33:22	COMPLETO	Kiosco - T. Matutino | Salida: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:36:22	18:59:22
45	200	2026-07-30	09:48:16	13:38:04	COMPLETO	Kiosco - T. Matutino | Salida: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:36:24	18:59:44
51	119	2026-07-31	08:54:56	14:00:58	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:00:23	19:00:51
47	115	2026-07-31	08:29:32	14:00:13	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
52	104	2026-07-31	08:54:58	14:23:21	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:02:59	19:02:32
54	202	2026-07-31	08:55:18	14:00:07	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:59:21	19:02:49
56	109	2026-07-31	09:08:42	17:04:50	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
57	113	2026-07-31	09:17:37	14:24:48	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
58	201	2026-07-31	09:34:54	16:08:26	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:31:45	18:59:46
48	200	2026-07-31	08:40:07	20:16:35	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
50	121	2026-07-31	08:40:51	13:17:56	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino	20:19:12	\N
53	124	2026-07-31	08:55:11	14:00:45	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:00:01	19:00:38
55	107	2026-07-31	09:01:54	14:53:32	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:50:17	19:02:37
60	125	2026-08-01	08:48:11	13:43:01	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
61	121	2026-08-01	08:48:17	13:45:04	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
64	200	2026-08-01	08:48:58	13:45:20	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
65	201	2026-08-01	08:57:15	13:55:57	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
63	109	2026-08-01	08:48:29	14:00:38	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
71	113	2026-08-01	09:13:40	14:00:55	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
59	115	2026-08-01	08:47:52	14:00:58	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
66	104	2026-08-01	08:57:24	14:00:59	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
62	202	2026-08-01	08:48:22	14:01:02	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
67	105	2026-08-01	08:58:22	14:01:07	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
68	124	2026-08-01	08:59:12	14:01:45	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
69	119	2026-08-01	09:01:17	14:01:47	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
70	107	2026-08-01	09:05:24	14:04:12	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
78	105	2026-08-03	08:55:31	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
87	201	2026-08-04	03:55:23	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
73	115	2026-08-03	08:39:56	14:00:33	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
75	125	2026-08-03	08:42:48	14:09:42	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
72	121	2026-08-03	08:39:38	14:00:10	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino	16:27:34	\N
74	200	2026-08-03	08:40:29	14:10:04	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:27:46	18:11:48
83	109	2026-08-03	09:37:37	18:15:01	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
76	104	2026-08-03	08:53:09	18:15:05	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
77	107	2026-08-03	08:53:58	18:16:17	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
82	113	2026-08-03	09:12:19	14:22:11	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino	18:17:01	\N
81	119	2026-08-03	09:02:37	18:19:21	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
79	201	2026-08-03	08:59:33	18:19:32	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
80	124	2026-08-03	09:02:15	14:00:23	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:55:12	18:20:11
88	107	2026-08-04	03:55:42	13:23:54	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
86	105	2026-08-04	03:46:44	13:24:51	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
84	104	2026-08-04	03:46:28	13:24:59	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
85	109	2026-08-04	03:46:34	13:32:07	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
94	124	2026-08-04	08:52:42	14:00:45	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:53:11	19:01:00
91	121	2026-08-04	08:44:33	13:36:28	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:36:42	19:15:34
92	200	2026-08-04	08:44:45	13:36:44	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:37:09	19:15:39
93	115	2026-08-04	08:51:39	14:00:39	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
95	202	2026-08-04	09:21:14	14:01:22	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:54:33	19:53:22
89	119	2026-08-04	03:59:07	14:01:05	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
90	125	2026-08-04	08:41:00	13:36:37	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:36:36	19:55:57
105	125	2026-08-05	08:26:07	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
96	104	2026-08-05	03:45:44	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
97	105	2026-08-05	03:45:54	11:57:32	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
98	109	2026-08-05	03:55:38	12:08:19	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
106	115	2026-08-05	08:40:47	13:00:21	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
103	121	2026-08-05	08:14:20	18:32:15	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
99	201	2026-08-05	03:56:20	14:17:37	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
100	107	2026-08-05	03:56:30	14:18:10	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
101	119	2026-08-05	03:57:54	14:18:23	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
104	200	2026-08-05	08:16:06	18:39:05	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
102	202	2026-08-05	08:14:15	18:38:03	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
107	124	2026-08-05	08:46:56	14:07:42	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:59:31	18:38:27
109	115	2026-08-06	08:34:49	14:00:52	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
110	202	2026-08-06	08:35:00	18:01:00	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
116	105	2026-08-06	09:14:54	\N	RETARDO	Kiosco - T. Matutino	\N	\N
111	200	2026-08-06	08:49:50	13:29:18	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino	16:37:17	\N
114	119	2026-08-06	09:05:37	14:01:56	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:01:48	17:10:07
108	125	2026-08-06	08:34:44	13:29:12	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
135	115	2026-08-11	08:44:14	14:00:25	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
148	125	2026-08-12	08:41:36	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
149	115	2026-08-12	08:42:09	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
115	201	2026-08-06	09:13:22	14:03:24	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:04:42	18:57:45
112	107	2026-08-06	08:55:08	14:02:18	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:01:24	18:58:25
113	124	2026-08-06	09:04:55	14:02:03	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:01:13	18:58:31
120	115	2026-08-07	08:52:43	14:01:18	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
150	121	2026-08-12	08:42:14	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
141	121	2026-08-11	10:00:02	14:01:14	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
142	200	2026-08-11	10:02:09	14:05:51	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
123	107	2026-08-07	09:13:49	14:01:52	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino	15:58:58	\N
118	124	2026-08-07	08:52:13	14:03:28	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino	16:00:43	\N
117	119	2026-08-07	08:52:00	14:02:59	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino	16:01:01	\N
119	201	2026-08-07	08:52:38	14:02:56	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino	16:02:34	\N
122	109	2026-08-07	09:12:11	14:07:26	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino	16:10:14	\N
121	202	2026-08-07	08:52:47	18:00:42	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
124	202	2026-08-08	09:05:41	13:02:44	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
125	124	2026-08-08	09:08:23	13:02:50	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
126	201	2026-08-09	15:37:25	\N	ASISTENCIA	Kiosco - T. Vespertino	\N	\N
127	104	2026-08-09	15:41:28	\N	ASISTENCIA	Kiosco - T. Vespertino	\N	\N
128	109	2026-08-09	15:51:42	\N	ASISTENCIA	Kiosco - T. Vespertino	\N	\N
129	107	2026-08-09	15:53:03	\N	ASISTENCIA	Kiosco - T. Vespertino	\N	\N
130	119	2026-08-09	15:55:44	\N	ASISTENCIA	Kiosco - T. Vespertino	\N	\N
131	115	2026-08-10	08:56:12	14:00:27	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
134	104	2026-08-11	08:38:38	15:43:32	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada | Entrada V: Kiosco - T. Vespertino	15:53:40	\N
132	124	2026-08-10	08:56:19	14:00:52	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:59:18	18:58:48
133	202	2026-08-10	08:56:39	14:00:44	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:58:37	18:59:59
138	105	2026-08-11	09:01:16	\N	RETARDO	Kiosco - T. Matutino	\N	\N
140	109	2026-08-11	09:26:38	\N	RETARDO	Kiosco - T. Matutino	\N	\N
156	101	2026-08-12	09:30:33	\N	RETARDO	Kiosco - T. Matutino	\N	\N
137	124	2026-08-11	09:01:13	14:00:35	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:03:09	17:40:21
139	119	2026-08-11	09:01:58	14:00:41	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:03:36	17:40:50
136	202	2026-08-11	08:55:51	14:00:56	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:59:32	17:42:02
143	201	2026-08-11	10:13:51	14:01:26	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:03:03	17:42:18
144	105	2026-08-12	08:38:15	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
155	201	2026-08-12	09:17:35	14:07:11	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:02:09	19:00:38
153	109	2026-08-12	09:09:23	19:00:50	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
152	119	2026-08-12	09:07:36	14:01:00	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:05:31	19:00:54
145	104	2026-08-12	08:38:55	14:07:24	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:44:10	19:01:03
146	202	2026-08-12	08:39:15	14:35:46	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:03:35	19:00:11
147	200	2026-08-12	08:41:27	19:01:00	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
151	124	2026-08-12	09:07:00	14:00:30	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:05:20	19:00:29
154	113	2026-08-12	09:17:28	15:52:59	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada | Entrada V: Kiosco - T. Vespertino	19:00:35	\N
165	105	2026-08-13	09:06:44	\N	RETARDO	Kiosco - T. Matutino	\N	\N
162	104	2026-08-13	08:54:40	14:08:16	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:45:16	19:00:16
161	125	2026-08-13	08:53:00	13:48:46	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
164	119	2026-08-13	08:56:09	14:01:15	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
168	200	2026-08-13	09:43:41	13:48:41	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:26:33	19:03:32
163	124	2026-08-13	08:55:46	13:59:56	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:50:20	19:00:31
160	201	2026-08-13	08:51:12	14:07:39	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:46:45	18:59:31
166	113	2026-08-13	09:15:51	14:07:52	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino	19:00:25	\N
157	121	2026-08-13	08:50:53	13:48:44	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	16:26:41	19:02:25
171	125	2026-08-14	08:39:55	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
173	115	2026-08-14	08:40:55	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
179	113	2026-08-14	09:10:29	19:00:08	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
175	107	2026-08-14	08:54:13	15:56:24	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada | Entrada V: Kiosco - T. Vespertino	19:00:12	\N
177	104	2026-08-14	08:54:46	14:06:02	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:32:03	19:00:26
169	121	2026-08-14	08:39:50	19:03:11	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
158	115	2026-08-13	08:51:01	14:00:20	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
159	202	2026-08-13	08:51:06	14:09:13	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:46:46	19:00:03
167	109	2026-08-13	09:32:45	14:08:43	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:46:44	19:00:39
176	105	2026-08-14	08:54:34	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
174	201	2026-08-14	08:51:25	15:52:58	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada | Entrada V: Kiosco - T. Vespertino	18:57:09	\N
178	202	2026-08-14	09:09:20	14:10:22	COMPLETO	Kiosco - T. Matutino | Salida M: Kiosco - Comida | Entrada V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino | Salida V: Kiosco - T. Vespertino	15:52:56	19:00:03
172	124	2026-08-14	08:39:59	16:01:30	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada | Entrada V: Kiosco - T. Vespertino	19:00:17	\N
180	109	2026-08-14	09:15:05	19:01:31	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada	\N	\N
170	200	2026-08-14	08:39:53	17:23:55	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Fin Jornada | Entrada V: Kiosco - T. Vespertino	19:02:59	\N
190	121	2026-08-15	10:09:25	\N	RETARDO	Kiosco - T. Matutino	\N	\N
192	125	2026-08-15	10:10:10	\N	RETARDO	Kiosco - T. Matutino	\N	\N
191	200	2026-08-15	10:09:44	13:49:41	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
183	202	2026-08-15	08:49:56	14:00:06	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
181	115	2026-08-15	08:45:13	14:00:19	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
188	113	2026-08-15	09:14:09	14:00:24	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
182	201	2026-08-15	08:45:21	14:00:35	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
185	104	2026-08-15	08:59:49	14:00:41	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
187	105	2026-08-15	09:05:57	14:00:43	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
189	109	2026-08-15	09:28:45	14:00:56	RETARDO	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
186	119	2026-08-15	09:00:23	14:01:34	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
184	107	2026-08-15	08:54:09	14:02:29	ASISTENCIA	Kiosco - T. Matutino | Salida M: Kiosco - Comida	\N	\N
193	202	2026-08-17	08:39:49	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
194	115	2026-08-17	08:40:37	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
195	105	2026-08-17	08:54:29	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
196	104	2026-08-17	08:54:36	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
197	124	2026-08-17	08:56:21	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
198	119	2026-08-17	08:59:26	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
199	107	2026-08-17	09:06:12	\N	RETARDO	Kiosco - T. Matutino	\N	\N
200	113	2026-08-17	09:11:46	\N	RETARDO	Kiosco - T. Matutino	\N	\N
201	109	2026-08-17	09:41:50	\N	RETARDO	Kiosco - T. Matutino	\N	\N
202	201	2026-08-17	10:38:20	\N	RETARDO	Kiosco - T. Matutino	\N	\N
\.


--
-- Data for Name: departamentos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departamentos (id, nombre) FROM stdin;
4	Sistemas
5	Ventas
1	Administracion
2	Edicion
3	Produccion
\.


--
-- Data for Name: empleados; Type: TABLE DATA; Schema: public; Owner: vpro_dbadmin
--

COPY public.empleados (id_empleado, nombre, depto, email, cel, fecha_nac, fecha_ing, licencia_vence, password, rol) FROM stdin;
103	Wilfrido Castro Beltran	ADMINISTRACION	notiene@hotmail.com	6676917919	1965-03-01	2016-01-28	2025-12-30	WilfridoC	BAJA
110	Eduardo Alonso Valdez Gomez	PRODUCCION	eduardo.produccion@vprovideo.mx	6677769481	1976-10-01	2022-09-04	2050-02-25	EduardoA	BAJA
116	Luz Damaris Quintero Pimentel	PRODUCCION		6674099301	2001-04-05	2025-03-10	2026-02-10	LuzD	BAJA
117	Luis Quintin Mares Lopez	PRODUCCION	luis.camarografo@vprovideo.mx	6674766575	1990-05-06	2025-04-11	2025-10-11	vpro123	BAJA
118	Hector Rementeria de la Rocha	PRODUCCION	hector.audio@vprovideo.mx	6671323708	2026-06-03	2022-11-26	2027-09-19	HectoR	BAJA
122	Andrea Rivera Rivas	ADMINISTRACION	mkt@vprovideo.mx	6672090837	2000-09-08	2025-11-26	2026-01-15	AndreaR	BAJA
123	Juan Pablo Espino Diaz	PRODUCCION	\N	6673278169	2003-06-17	2026-02-16	2026-01-31	JuanP	BAJA
517	Ricardo Gonzalez	PRODUCCION		\N	1977-09-18	2024-08-22	2052-03-18	vpro_sin_acceso	PROVEEDOR
113	Carlos Jacobo Quezada Mendoza	PRODUCCION	carlos.edicion@vprovideo.mx	6674667614	2000-02-12	2023-12-07	2027-09-19	$2b$12$0/2ZlsvvQ3VvA5iB7fKDIO3SvhQF9orN6Em70sA1TjaR2L/b0uqcu	PRODUCCION
115	Ibon Araceli Campos Medina	ADMINISTRACION	notieneemail@hotmail.com	6674305028	1973-08-16	2025-02-09	2030-03-09	IbonA	PRODUCCION
508	Jaime Muro	PRODUCCION		\N	1900-01-01	2026-03-20	2050-05-22	vpro_sin_acceso	PROVEEDOR
101	Ana Lilia Villarreal Uribe	ADMINISTRACION	contabilidad@vprovideo.com	6671022524	1973-09-29	2015-11-26	2028-01-09	$2b$12$PdjiLZAyyKN1G/Oi7nAqkeUo7tZ492LZRYIP43gg9/Q6fjxvcz5.q	ADMIN
501	eduardo el condor	PRODUCCION	direcciown@vprovideo.com	\N	2026-09-08	2026-11-02	2026-12-12	vpro_sin_acceso	PROVEEDOR
525	Carlos Castillo	PRODUCCION		\N	1981-06-07	2023-12-10	2053-10-25	vpro123	PROVEEDOR
529	Kiosco Bodega	KIOSKO		\N	2026-05-19	2026-05-09	2099-12-25	KioskO	LOGISTICA
104	Jose Francisco Torres Sanchez	PRODUCCION	francisco.tecnico@vprovideo.mx	6672072138	1975-12-06	2016-12-04	2026-12-16	$2b$12$maVMyOl/cY9wwGFeGYj5guBuA1ZEUcSeE1cTFqA0fFvjHZMPpo5rm	PRODUCCION
102	Gerardo Villarreal Uribe	EDICION	gerardo@vprovideo.com	6673291087	1979-08-31	2015-12-27	2028-06-04	$2b$12$i4sfscS821ykcQvydKKPtOP1iA8Cwhcaskv383JWmW5e418fzAEee	ADMIN
121	Sofia Alejandra Villarreal Lopez	VENTAS	sofia.ventas@vprovideo.com	6673903759	1996-08-11	1996-08-11	2050-01-09	SofiA	ADMIN
125	Diego Villareal Lopez	ADMINISTRACION	diego@gmail.com	\N	2005-09-15	2005-09-15	2050-05-27	DiegoV	ADMIN
107	Martin Eduardo Sanchez Estrada	PRODUCCION	live.ventas@vprovideo.com	6678901234	1971-03-17	2016-06-01	2050-03-31	$2b$12$HwdBh5dO5q8CU9q70F7rxO.kOl.zz4NzHcUzMqYWIatUjUr1QRZTm	ADMIN
200	Andrea Maria Vilarreal Lopez	EDICION	andrea@vprovideo.mx	6673903762	1994-07-23	1994-07-23	2050-02-10	$2b$12$lV2c85P4yc6lwnIRoCi2j.Hljo1oSHpZaKdO7PH2XsdpR/arFOtGO	ADMIN
202	Edgar Javier Amarillas	SISTEMAS	live.stream@vprovideo.com	6672090481	1975-02-03	2024-09-24	2029-01-09	$2b$12$Kfzpr9LbUuRK3dIv/HMhOunhnQ3w6MGBXydLse2wTO/XyH8gje0XG	PRODUCCION
105	Jose Daniel Torres Arroyo	PRODUCCION	daniel.produccion@vprovideo.mx	6675788854	1999-01-28	2016-03-30	2100-02-21	$2b$12$GkNreszVLLBmt67EPXrk8eq5vqp1IzUQq/DayBhrESBKrWQZK/vUS	PRODUCCION
203	Pedro Villarreal Uribe	ADMINISTRACION	direccion@vprovideo.com	6672300488	1968-08-07	1964-08-07	2050-12-24	$2b$12$fXpITFlsgHoryqPp3q4MnOpzcmPswF.sI1XYbH9xxyI/Iv20VMtHq	ADMIN
502	Javier Garcia	PRODUCCION		\N	1900-01-01	2026-03-20	2027-12-12	vpro_sin_acceso	PROVEEDOR
512	Leonardo Leon	PRODUCCION		\N	2002-07-04	2021-06-21	2051-07-26	vpro_sin_acceso	PROVEEDOR
504	Ernesto Gutierrez	PRODUCCION		\N	1900-01-01	2026-03-20	2029-01-22	vpro_sin_acceso	PROVEEDOR
505	Calixto Villa	PRODUCCION		\N	1900-01-01	2026-03-20	2030-05-31	vpro_sin_acceso	PROVEEDOR
509	Jonahtan	PRODUCCION		\N	1900-01-01	2026-03-20	2050-05-23	vpro_sin_acceso	PROVEEDOR
506	Ignacio Garcia	PRODUCCION		\N	1900-01-01	2026-03-20	2050-02-21	vpro_sin_acceso	PROVEEDOR
510	Ivan Martinez	PRODUCCION		\N	2000-05-02	2018-04-21	2050-05-24	vpro_sin_acceso	PROVEEDOR
513	Ivan Jr	PRODUCCION		\N	2003-08-05	2022-07-22	2052-07-27	vpro_sin_acceso	PROVEEDOR
109	Osiel Cuauhtemoc Hernandez Aldape	PRODUCCION	osiel.switcher@vprovideo.mx	6671520296	1970-12-20	2022-08-03	2029-09-17	$2b$12$F/bN.Tz9OO8JWdaAA0Ck3eXAx.61ynhxHzEkNS3RBVN3s5wmAvxwm	PRODUCCION
515	Cristian Soto	PRODUCCION		\N	1975-02-04	2023-08-22	2051-07-27	vpro_sin_acceso	PROVEEDOR
521	Beatriz Cota	PRODUCCION		\N	1976-02-28	2023-12-05	2041-03-18	vpro_sin_acceso	PROVEEDOR
518	Cuquis	PRODUCCION		\N	1980-03-09	2024-07-23	2040-05-19	vpro_sin_acceso	PROVEEDOR
522	Jose Carlos	PRODUCCION		\N	1980-03-30	2024-10-09	2052-02-07	vpro_sin_acceso	PROVEEDOR
526	Victor (homi)	PRODUCCION		\N	1988-02-10	2022-09-15	2051-04-30	vpro123	PROVEEDOR
124	Manuel Eduardo Madrid	PRODUCCION	coordinador@vprovideo.com	\N	1999-05-18	2026-03-23	2026-05-27	$2b$12$yi/.y4i8H7Pyg7G9icRaZuS2coy11GdoYQNWSwa8nHTkWIzQL8fuu	COORDINADOR
519	Miguel	PRODUCCION		\N	1978-08-09	2024-02-11	2051-09-18	vpro_sin_acceso	PROVEEDOR
201	Cuauhtemoc Rivera Agundez	SISTEMAS	cuauhtemoc.manager@audiovideopro.com.mx	6674305026	1970-09-30	2021-03-31	2025-03-31	$2b$12$3nqc7ExmR0y2vyo5L8Ug1OwcwLsJ.28Lep/q3RGBbJ9oR80GaaBvm	ADMIN
503	Miguel Lara	PRODUCCION		\N	1900-01-01	2026-03-20	2028-12-21	vpro_sin_acceso	PROVEEDOR
527	Hair Sanchez	PRODUCCION		\N	1979-08-09	2024-11-12	2052-07-27	vpro123	PROVEEDOR
523	Luis Silva	PRODUCCION		\N	1983-10-31	2024-11-08	2050-03-06	vpro123	PROVEEDOR
530	Lorenzo Bastidas	PRODUCCION		\N	1988-08-17	2026-05-16	2050-05-20	vpro123	PROVEEDOR
119	Manuel Antonio Madrid Zazueta	PRODUCCION	manuel@vprovideo.com	6671325182	1972-08-03	2019-11-26	2026-10-25	$2b$12$96Fw/6RABVtKdELqnoBXs.mVuGhN6LuNJJVF9TUZwMhkO5CcrQ2Qq	PRODUCTOR
507	Ernesto Cuen	PRODUCCION		\N	1900-01-01	2026-03-20	2050-12-22	vpro_sin_acceso	PROVEEDOR
511	Pony	PRODUCCION		\N	2001-06-03	2020-05-20	2050-06-25	vpro_sin_acceso	PROVEEDOR
520	Cristina	PRODUCCION		\N	1988-08-07	2023-10-01	2053-03-17	vpro_sin_acceso	PROVEEDOR
516	Martin Miranda	PRODUCCION		\N	1978-08-04	2024-08-22	2053-07-27	vpro_sin_acceso	PROVEEDOR
524	Carlos Pinzon	PRODUCCION		\N	1982-09-18	2023-11-07	2051-08-19	vpro123	PROVEEDOR
528	Carlos Aleman	PRODUCCION		\N	1981-09-08	2024-07-10	2050-04-25	vpro123	PROVEEDOR
\.


--
-- Data for Name: log_accesos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log_accesos (id_log, fecha, hora, ip_origen, id_empleado, nombre_empleado, tipo_evento) FROM stdin;
1	2026-02-13	12:16:06.921711	172.16.0.20	121	Sofía Alejandra Villarreal L├│pez	INTENTO FALLIDO
2	2026-02-13	12:16:37.642568	172.16.0.20	121	Sofía Alejandra Villarreal L├│pez	INTENTO FALLIDO
3	2026-02-13	12:16:42.036623	172.16.0.20	121	Sofía Alejandra Villarreal L├│pez	INTENTO FALLIDO
4	2026-02-13	12:57:46.468075	172.16.0.20	203	Pedro Villarreal Uribe	LOGIN EXITOSO
5	2026-02-13	12:58:19.38731	172.16.0.20	202	Edgar Javier Amarillas	LOGIN EXITOSO
6	2026-02-13	12:58:36.518993	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
7	2026-02-13	12:58:44.847445	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
8	2026-02-13	12:59:05.560962	172.16.0.20	200	Andrea María Vilarreal Lopez	LOGIN EXITOSO
9	2026-02-13	12:59:28.436577	172.16.0.20	122	Andrea Rivera Rivas	LOGIN EXITOSO
10	2026-02-13	12:59:54.462366	172.16.0.20	121	Sofía Alejandra Villarreal L├│pez	LOGIN EXITOSO
11	2026-02-13	13:00:20.4167	172.16.0.20	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
12	2026-02-13	13:00:42.862423	172.16.0.20	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
13	2026-02-13	13:01:04.722754	172.16.0.20	116	Luz Damaris Quintero Pimentel	LOGIN EXITOSO
14	2026-02-13	13:01:26.054443	172.16.0.20	115	Ibon Araceli Campos Medina	LOGIN EXITOSO
15	2026-02-13	13:01:41.097119	172.16.0.20	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
16	2026-02-13	13:01:59.452026	172.16.0.20	110	Eduardo Alonso Valdéz G├│mez	LOGIN EXITOSO
17	2026-02-13	13:02:23.438167	172.16.0.20	109	Osiel Cuauhtémoc Hern├índez Aldape	LOGIN EXITOSO
18	2026-02-13	13:02:42.008827	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
19	2026-02-13	13:03:07.108061	172.16.0.20	105	José Daniel Torres Arroyo	LOGIN EXITOSO
20	2026-02-13	13:03:24.2548	172.16.0.20	104	José Francisco Torres Sanchez	LOGIN EXITOSO
21	2026-02-13	13:03:41.289999	172.16.0.20	103	Wilfrido Castro Beltr├ín	LOGIN EXITOSO
22	2026-02-13	13:03:57.108021	172.16.0.20	102	Gerardo Villarreal Uribe	LOGIN EXITOSO
23	2026-02-13	13:04:20.20699	172.16.0.20	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
24	2026-02-13	13:25:55.199233	172.16.0.20	101	Ana Lilia Villarreal Uribe	INTENTO FALLIDO
25	2026-02-13	13:25:58.497394	172.16.0.20	101	Ana Lilia Villarreal Uribe	INTENTO FALLIDO
26	2026-02-13	13:26:01.477966	172.16.0.20	101	Ana Lilia Villarreal Uribe	INTENTO FALLIDO
27	2026-02-13	13:56:11.355603	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
28	2026-02-13	13:56:13.778205	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
29	2026-02-13	13:56:15.995526	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
30	2026-02-13	14:33:55.03795	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
31	2026-02-13	14:33:57.167904	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
32	2026-02-13	14:33:58.486235	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
33	2026-02-13	14:42:09.00035	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
34	2026-02-13	14:42:12.098749	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
35	2026-02-13	14:42:13.127221	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
36	2026-02-13	14:51:51.477106	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
37	2026-02-13	14:51:53.867543	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
38	2026-02-13	14:51:54.804728	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
39	2026-02-14	10:00:53.755175	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
40	2026-02-14	13:46:00.052366	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
41	2026-02-14	13:46:59.719533	172.16.0.20	121	Sofía Alejandra Villarreal L├│pez	INTENTO FALLIDO
42	2026-02-14	13:47:15.499397	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
43	2026-02-14	13:47:46.175666	172.16.0.20	101	Ana Lilia Villarreal Uribe	INTENTO FALLIDO
44	2026-02-14	13:48:20.940424	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
45	2026-02-14	13:50:46.021149	172.16.0.20	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
46	2026-02-14	13:52:01.075559	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
47	2026-02-14	13:52:04.03971	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
48	2026-02-14	13:52:07.848957	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
49	2026-02-14	13:52:13.40824	172.16.0.20	201	Cuauhtémoc Rivera Agundez	RECUPERACION
50	2026-02-14	13:52:47.159737	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
51	2026-02-14	13:59:51.829806	172.16.0.20	0	ADMINISTRADOR	INTENTO FALLIDO
52	2026-02-14	14:04:08.276709	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
53	2026-02-16	12:02:41.129213	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
54	2026-02-16	12:15:02.28277	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
55	2026-02-16	12:15:35.163276	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
56	2026-02-16	12:16:57.564226	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
57	2026-02-16	12:18:19.674698	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
58	2026-02-16	12:20:40.078229	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
59	2026-02-16	13:06:54.557154	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
60	2026-02-16	13:08:25.013253	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
61	2026-02-16	13:22:29.25632	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
62	2026-02-16	13:22:57.638215	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
63	2026-02-16	13:23:11.687641	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
64	2026-02-16	13:23:28.556413	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
65	2026-02-16	13:24:57.728677	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
66	2026-02-16	13:31:45.38233	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
67	2026-02-16	13:32:08.737707	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
68	2026-02-16	13:38:25.423427	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
69	2026-02-16	14:50:14.211863	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
70	2026-02-16	14:51:03.351961	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
71	2026-02-16	14:51:36.429841	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
72	2026-02-16	14:52:32.323779	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
73	2026-02-16	14:53:25.565591	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
74	2026-02-16	14:56:59.086804	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
75	2026-02-16	15:01:58.47993	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
76	2026-02-16	15:09:10.714335	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
77	2026-02-16	15:14:57.611118	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
78	2026-02-16	15:19:51.271602	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
79	2026-02-16	15:44:45.122274	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
80	2026-02-16	17:25:52.98877	172.16.0.20	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
81	2026-02-16	18:10:52.430289	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
82	2026-02-16	18:24:02.906276	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
83	2026-02-16	18:37:27.738513	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
84	2026-02-16	18:46:55.860304	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
85	2026-02-16	18:57:53.683359	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
86	2026-02-16	19:22:07.386038	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
87	2026-02-16	19:28:28.868904	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
88	2026-02-16	19:33:50.163653	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
89	2026-02-16	19:50:10.814795	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
90	2026-02-17	15:51:52.669444	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
91	2026-02-17	15:59:15.030047	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
92	2026-02-17	16:00:09.549888	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
93	2026-02-17	17:08:53.524055	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
94	2026-02-17	17:13:18.585472	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
95	2026-02-17	17:27:32.865934	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
96	2026-02-17	17:36:22.829551	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
97	2026-02-17	17:41:07.705418	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
98	2026-02-17	18:50:07.874929	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
99	2026-02-18	10:42:41.935589	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
100	2026-02-18	13:02:30.118218	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
101	2026-02-18	13:48:01.762547	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
102	2026-02-18	14:22:55.111124	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
103	2026-02-18	14:55:46.104174	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
104	2026-02-18	15:04:48.057006	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
105	2026-02-18	15:14:15.566271	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
106	2026-02-19	14:58:48.555562	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
107	2026-02-20	10:08:06.61545	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
108	2026-02-20	10:10:48.448835	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
109	2026-02-20	10:14:02.259983	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
110	2026-02-20	10:18:26.214571	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
111	2026-02-20	10:26:55.509738	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
112	2026-02-20	13:02:19.944559	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
113	2026-02-20	13:58:04.377029	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
114	2026-02-20	14:31:39.916558	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
115	2026-02-20	14:38:19.494536	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
116	2026-02-20	17:22:37.939461	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
117	2026-02-20	17:31:48.692122	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
118	2026-02-20	17:33:46.657751	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
119	2026-02-20	17:39:17.127094	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
120	2026-02-20	17:41:49.904394	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
121	2026-02-20	17:46:56.213976	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
122	2026-02-20	17:50:18.618573	172.16.0.20	202	Edgar Javier Amarillas	INTENTO FALLIDO
123	2026-02-20	17:51:14.778407	172.16.0.20	202	Edgar Javier Amarillas	LOGIN EXITOSO
124	2026-02-20	18:26:22.894265	172.16.0.20	202	Edgar Javier Amarillas	LOGIN EXITOSO
125	2026-02-20	19:06:27.085921	172.16.0.20	202	Edgar Javier Amarillas	LOGIN EXITOSO
126	2026-02-20	19:14:40.693711	172.16.0.20	202	Edgar Javier Amarillas	LOGIN EXITOSO
127	2026-02-20	19:27:38.182529	172.16.0.20	202	Edgar Javier Amarillas	LOGIN EXITOSO
128	2026-02-20	19:32:17.633433	172.16.0.20	202	Edgar Javier Amarillas	LOGIN EXITOSO
129	2026-02-21	12:57:47.153951	172.16.0.20	202	Edgar Javier Amarillas	LOGIN EXITOSO
130	2026-02-21	14:01:51.664258	172.16.0.20	202	Edgar Javier Amarillas	LOGIN EXITOSO
131	2026-02-21	14:02:31.384896	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
132	2026-02-21	14:02:40.418372	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
133	2026-02-21	14:03:21.822785	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
134	2026-02-21	14:23:56.318897	172.16.0.20	202	Edgar Javier Amarillas	LOGIN EXITOSO
135	2026-02-21	14:24:32.802169	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
136	2026-02-21	14:24:50.605699	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
137	2026-02-21	14:25:03.748374	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
138	2026-02-21	14:36:10.513463	172.16.0.20	202	Edgar Javier Amarillas	LOGIN EXITOSO
139	2026-02-21	14:36:44.489632	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
140	2026-02-21	14:45:06.967668	172.16.0.20	202	Edgar Javier Amarillas	LOGIN EXITOSO
141	2026-02-21	14:45:20.579942	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
142	2026-02-21	15:09:32.517123	172.16.0.20	202	Edgar Javier Amarillas	LOGIN EXITOSO
143	2026-02-21	15:09:46.686059	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
144	2026-03-02	12:05:40.436365	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
145	2026-03-02	12:13:20.973169	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
146	2026-03-02	12:18:31.056135	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
147	2026-03-02	12:33:09.28644	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
148	2026-03-02	18:20:30.286304	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
149	2026-03-02	18:39:29.633598	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
150	2026-03-02	18:44:46.77034	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
151	2026-03-02	19:10:38.421298	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
152	2026-03-02	19:14:01.743069	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
153	2026-03-02	19:19:37.935747	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
154	2026-03-02	19:21:09.956581	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
155	2026-03-02	19:29:14.362521	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
156	2026-03-03	10:48:40.964427	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
157	2026-03-03	10:51:37.249325	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
158	2026-03-03	11:02:25.138454	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
159	2026-03-03	11:14:49.63733	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
160	2026-03-03	11:28:19.493151	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
161	2026-03-03	11:59:03.550529	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
162	2026-03-03	12:05:36.502913	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
163	2026-03-03	12:12:23.115573	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
164	2026-03-03	12:14:42.446708	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
165	2026-03-03	12:38:54.967125	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
166	2026-03-03	13:41:03.961081	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
167	2026-03-03	14:07:46.291454	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
168	2026-03-03	14:16:42.509264	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
169	2026-03-03	14:23:39.923666	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
170	2026-03-03	14:28:44.262577	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
171	2026-03-03	14:39:13.31053	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
172	2026-03-03	14:42:19.54423	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
173	2026-03-03	14:48:34.71838	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
174	2026-03-03	14:59:02.81094	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
175	2026-03-03	16:50:27.809038	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
176	2026-03-03	16:59:13.250842	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
177	2026-03-03	17:04:27.305509	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
178	2026-03-03	17:10:23.993287	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
179	2026-03-03	17:15:18.587384	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
180	2026-03-03	17:28:23.291326	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
181	2026-03-03	17:38:51.373685	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
182	2026-03-03	17:42:08.993905	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
183	2026-03-03	17:44:29.150846	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
184	2026-03-03	17:52:07.441286	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
185	2026-03-03	17:55:24.958162	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
186	2026-03-03	18:18:05.086914	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
187	2026-03-03	18:31:38.152938	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
188	2026-03-03	18:38:21.164556	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
189	2026-03-03	18:57:09.564953	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
190	2026-03-04	10:36:32.39399	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
191	2026-03-04	10:38:56.230973	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
192	2026-03-04	12:08:22.767327	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
193	2026-03-04	12:15:57.263368	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
194	2026-03-04	12:29:24.664357	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
195	2026-03-04	12:38:43.773268	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
196	2026-03-04	12:43:49.595113	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
197	2026-03-04	12:46:56.225461	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
198	2026-03-04	12:49:59.877383	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
199	2026-03-04	12:54:54.445618	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
200	2026-03-04	14:05:14.933389	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
201	2026-03-04	14:05:35.476089	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
202	2026-03-04	14:05:51.430078	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
203	2026-03-04	14:20:46.476944	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
204	2026-03-04	17:02:22.773471	172.16.0.20	107	Martin Eduardo Sanchez Estrada	INTENTO FALLIDO
205	2026-03-04	17:02:42.167721	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
206	2026-03-04	17:22:24.520317	172.16.0.20	107	Martin Eduardo Sanchez Estrada	INTENTO FALLIDO
207	2026-03-04	17:22:29.318073	172.16.0.20	107	Martin Eduardo Sanchez Estrada	INTENTO FALLIDO
208	2026-03-04	17:22:34.623343	172.16.0.20	107	Martin Eduardo Sanchez Estrada	INTENTO FALLIDO
209	2026-03-04	17:23:20.370074	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
210	2026-03-04	17:27:34.357275	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
211	2026-03-04	17:29:04.472354	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
212	2026-03-04	17:41:58.471766	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
213	2026-03-04	17:58:52.528299	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
214	2026-03-04	18:12:27.15822	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
215	2026-03-04	18:33:30.245744	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
216	2026-03-04	18:46:42.849534	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
217	2026-03-05	10:09:59.155574	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
218	2026-03-05	11:19:53.092661	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
219	2026-03-05	11:32:49.505078	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
220	2026-03-05	11:46:37.724016	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
221	2026-03-05	11:53:25.335147	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
222	2026-03-05	12:00:25.394879	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
223	2026-03-05	12:04:38.674612	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
224	2026-03-05	12:05:35.432454	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
225	2026-03-05	12:06:53.97941	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
226	2026-03-05	12:23:17.388875	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
227	2026-03-05	12:31:13.456526	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
228	2026-03-05	12:37:40.112475	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
229	2026-03-05	12:40:41.275951	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
230	2026-03-05	12:40:54.817173	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
231	2026-03-05	12:42:15.226679	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
232	2026-03-05	12:43:45.889076	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
233	2026-03-05	12:58:39.141781	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
234	2026-03-05	13:46:25.688471	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
235	2026-03-05	14:13:52.287504	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
236	2026-03-05	14:24:15.866229	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
237	2026-03-05	14:36:37.414823	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
238	2026-03-05	14:46:45.196033	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
239	2026-03-05	15:03:24.759568	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
240	2026-03-05	17:59:14.94578	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
241	2026-03-05	18:08:00.278448	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
242	2026-03-05	18:45:27.773945	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
243	2026-03-05	18:50:12.478865	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
244	2026-03-05	18:57:50.584653	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
245	2026-03-05	19:09:57.819424	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
246	2026-03-05	19:19:36.571613	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
247	2026-03-05	19:33:17.876498	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
248	2026-03-05	19:39:05.184016	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
249	2026-03-05	19:49:20.788321	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
250	2026-03-05	19:52:33.34285	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
251	2026-03-07	10:12:54.493642	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
252	2026-03-07	10:46:53.02832	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
253	2026-03-07	10:57:55.570662	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
254	2026-03-07	11:03:32.620854	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
255	2026-03-07	11:12:43.861048	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
256	2026-03-07	12:15:37.967746	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
257	2026-03-07	12:21:57.651654	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
258	2026-03-07	12:27:48.850897	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
259	2026-03-07	12:29:04.428072	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
260	2026-03-07	12:31:19.759502	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
261	2026-03-07	12:37:02.463706	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
262	2026-03-07	12:39:40.030291	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
263	2026-03-07	12:43:09.467515	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
264	2026-03-07	12:45:49.121155	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
265	2026-03-07	12:47:27.681014	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
266	2026-03-07	12:59:11.73444	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
267	2026-03-07	13:13:10.632581	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
268	2026-03-07	13:31:25.627585	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
269	2026-03-07	13:40:00.884213	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
270	2026-03-09	10:31:33.62991	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
271	2026-03-09	13:48:05.61757	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
272	2026-03-09	13:48:23.937759	172.16.0.20	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
273	2026-03-09	13:53:32.002067	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
274	2026-03-09	13:55:50.48323	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
275	2026-03-09	13:55:57.874091	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
276	2026-03-09	13:56:00.6329	172.16.0.20	201	Cuauhtémoc Rivera Agundez	INTENTO FALLIDO
277	2026-03-09	13:56:22.043343	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
278	2026-03-09	14:21:41.435835	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
279	2026-03-09	14:24:20.189479	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
280	2026-03-09	14:33:37.426599	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
281	2026-03-09	14:46:08.199285	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
282	2026-03-09	14:55:34.907514	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
283	2026-03-09	14:58:44.279454	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
284	2026-03-09	17:09:52.863067	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
285	2026-03-09	17:12:27.621733	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
286	2026-03-09	17:13:56.309295	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
287	2026-03-09	17:31:48.380134	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
288	2026-03-09	17:41:37.765751	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
289	2026-03-09	17:44:42.079787	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
290	2026-03-09	17:51:51.698283	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
291	2026-03-09	17:55:27.336458	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
292	2026-03-09	18:01:41.665809	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
293	2026-03-09	19:14:17.653332	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
294	2026-03-09	19:24:04.080353	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
295	2026-03-09	19:54:24.409505	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
296	2026-03-10	14:02:30.100545	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
297	2026-03-10	14:20:57.799417	172.16.0.20	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
298	2026-03-10	18:21:34.064194	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
299	2026-03-10	18:23:51.547165	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
300	2026-03-10	18:37:32.173216	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
301	2026-03-10	18:38:12.262367	N/A	115	Ibon Araceli Campos Medina	LOGIN EXITOSO
302	2026-03-10	18:43:26.080828	N/A	115	Ibon Araceli Campos Medina	LOGIN EXITOSO
303	2026-03-11	17:52:34.710033	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
304	2026-03-11	17:53:53.615673	N/A	123	Juan Pablo Espino Diaz	LOGIN EXITOSO
305	2026-03-11	18:06:55.32539	N/A	123	Juan Pablo Espino Diaz	LOGIN EXITOSO
306	2026-03-11	18:09:08.872176	N/A	123	Juan Pablo Espino Diaz	LOGIN EXITOSO
307	2026-03-11	18:23:27.760767	N/A	123	Juan Pablo Espino Diaz	LOGIN EXITOSO
308	2026-03-11	18:30:44.834476	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
309	2026-03-11	18:32:01.828746	N/A	109	Osiel Cuauhtémoc Hern├índez Aldape	LOGIN EXITOSO
310	2026-03-11	18:54:56.108851	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
311	2026-03-11	19:10:02.790779	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
312	2026-03-11	19:20:09.147455	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
313	2026-03-11	19:27:55.14282	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
314	2026-03-11	19:29:30.772817	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
315	2026-03-11	19:30:46.548115	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
316	2026-03-11	19:36:20.029947	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
317	2026-03-12	14:23:05.106403	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
318	2026-03-13	11:15:08.867967	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
319	2026-03-13	12:28:21.654633	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
320	2026-03-13	14:02:22.069431	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
321	2026-03-13	14:12:29.689978	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
322	2026-03-13	14:18:10.974046	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
323	2026-03-13	14:24:45.259667	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
324	2026-03-13	14:27:39.271626	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
325	2026-03-13	14:41:06.306863	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
326	2026-03-13	14:49:55.8911	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
327	2026-03-13	15:05:29.485157	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
328	2026-03-13	17:08:54.132051	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
329	2026-03-13	17:18:22.552346	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
330	2026-03-13	17:25:38.686887	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
331	2026-03-13	18:00:53.725118	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
332	2026-03-13	18:05:15.106023	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
333	2026-03-13	18:13:24.83447	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
334	2026-03-13	18:18:05.962486	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
335	2026-03-13	18:25:38.149963	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
336	2026-03-13	18:36:39.230299	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
337	2026-03-13	19:01:29.802718	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
338	2026-03-13	19:16:29.928597	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
339	2026-03-13	19:17:35.326415	N/A	102	Gerardo Villarreal Uribe	LOGIN EXITOSO
340	2026-03-13	19:18:50.085616	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
341	2026-03-14	10:08:42.068344	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
342	2026-03-14	13:10:12.776749	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
343	2026-03-14	13:10:46.949603	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
344	2026-03-14	13:11:25.139138	N/A	102	Gerardo Villarreal Uribe	LOGIN EXITOSO
345	2026-03-14	13:11:52.642372	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
346	2026-03-14	13:15:15.326593	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
347	2026-03-14	13:21:09.053702	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
348	2026-03-14	13:21:54.112405	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
349	2026-03-14	13:22:19.907811	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
350	2026-03-14	13:22:46.375939	N/A	109	Osiel Cuauhtémoc Hern├índez Aldape	LOGIN EXITOSO
351	2026-03-14	13:23:53.434664	N/A	110	Eduardo Alonso Valdéz G├│mez	LOGIN EXITOSO
352	2026-03-14	13:24:17.444231	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
353	2026-03-14	14:10:14.794776	N/A	109	Osiel Cuauhtémoc Hern├índez Aldape	LOGIN EXITOSO
354	2026-03-14	14:11:58.289645	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
355	2026-03-14	14:15:36.213338	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
356	2026-03-14	14:26:35.446859	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
357	2026-03-14	14:31:36.510288	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
358	2026-03-14	14:36:07.87656	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
359	2026-03-14	14:50:43.746388	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
360	2026-03-14	14:55:50.160587	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
361	2026-03-17	07:11:46.255516	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
362	2026-03-17	08:44:04.832973	N/A	0	ADMINISTRADOR	FALLO DE LOGIN
363	2026-03-17	08:44:12.470844	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
364	2026-03-17	08:46:07.392088	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
365	2026-03-17	08:47:13.908069	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
366	2026-03-17	08:55:21.817851	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
367	2026-03-17	12:56:27.612887	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
368	2026-03-17	15:23:59.273159	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
369	2026-03-17	15:24:27.32142	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
370	2026-03-18	10:49:55.173367	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
371	2026-03-18	10:55:04.167551	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
372	2026-03-18	11:17:46.026474	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
373	2026-03-18	11:27:14.548246	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
374	2026-03-18	11:31:15.726013	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
375	2026-03-18	11:41:58.510487	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
376	2026-03-18	12:01:20.395868	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
377	2026-03-18	12:04:42.0382	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
378	2026-03-18	12:06:57.330168	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
379	2026-03-18	14:27:21.207302	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
380	2026-03-18	14:30:06.037205	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
381	2026-03-18	14:31:50.247224	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
382	2026-03-18	14:33:12.93765	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
383	2026-03-18	14:40:08.007837	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
384	2026-03-18	14:41:22.461224	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
385	2026-03-18	14:43:42.33013	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
386	2026-03-18	14:53:12.973296	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
387	2026-03-18	14:54:22.963219	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
388	2026-03-18	14:58:14.917306	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
389	2026-03-18	16:07:13.929364	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
390	2026-03-18	16:38:00.208056	N/A	0	Carlos Jacobo Quezada Mendoza	FALLO DE LOGIN
391	2026-03-18	16:38:10.56182	N/A	0	Carlos Jacobo Quezada Mendoza	FALLO DE LOGIN
392	2026-03-18	16:38:49.195395	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
393	2026-03-18	16:39:34.732522	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
394	2026-03-18	16:57:14.009986	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
395	2026-03-18	17:05:50.60871	N/A	110	Eduardo Alonso Valdéz G├│mez	LOGIN EXITOSO
396	2026-03-18	17:09:51.186734	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
397	2026-03-18	17:13:22.294479	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
398	2026-03-18	17:36:27.287831	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
399	2026-03-18	17:37:14.248376	N/A	110	Eduardo Alonso Valdéz G├│mez	LOGIN EXITOSO
400	2026-03-18	17:47:57.215708	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
401	2026-03-18	17:49:08.204176	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
402	2026-03-18	17:57:11.70586	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
403	2026-03-18	18:05:51.757795	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
404	2026-03-18	18:09:54.425785	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
405	2026-03-18	18:31:57.850256	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
406	2026-03-18	18:36:27.713546	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
407	2026-03-18	18:42:07.630705	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
408	2026-03-18	18:47:18.273965	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
409	2026-03-18	18:55:14.125981	N/A	0	Carlos Jacobo Quezada Mendoza	FALLO DE LOGIN
410	2026-03-18	18:55:15.091947	N/A	0	Carlos Jacobo Quezada Mendoza	FALLO DE LOGIN
411	2026-03-18	18:55:17.789224	N/A	0	Carlos Jacobo Quezada Mendoza	FALLO DE LOGIN
412	2026-03-18	18:57:18.412199	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
413	2026-03-18	19:33:11.956956	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
414	2026-03-19	17:47:11.478529	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
415	2026-03-19	18:13:18.213256	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
416	2026-03-19	18:14:15.762589	N/A	200	Andrea María Vilarreal Lopez	LOGIN EXITOSO
417	2026-03-19	18:56:57.952972	N/A	200	Andrea María Vilarreal Lopez	LOGIN EXITOSO
418	2026-03-19	19:07:10.094592	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
419	2026-03-19	19:17:46.672865	N/A	200	Andrea María Vilarreal Lopez	LOGIN EXITOSO
420	2026-03-20	10:11:03.392084	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
421	2026-03-20	11:16:36.448036	N/A	0	Edgar Javier Amarillas	FALLO DE LOGIN
422	2026-03-20	11:16:50.808493	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
423	2026-03-20	11:17:15.868412	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
424	2026-03-20	11:20:38.457564	N/A	115	Ibon Araceli Campos Medina	LOGIN EXITOSO
425	2026-03-20	11:21:22.888985	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
426	2026-03-20	11:22:55.474469	N/A	110	Eduardo Alonso Valdéz G├│mez	LOGIN EXITOSO
427	2026-03-20	11:29:56.85225	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
428	2026-03-20	12:01:55.406704	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
429	2026-03-20	12:03:12.928341	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
430	2026-03-20	12:12:56.20211	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
431	2026-03-20	12:54:32.593434	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
432	2026-03-20	13:15:07.230403	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
433	2026-03-20	13:42:07.727029	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
434	2026-03-20	13:57:18.959206	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
435	2026-03-20	14:01:36.17181	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
436	2026-03-20	14:05:35.528683	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
437	2026-03-20	14:19:12.728143	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
438	2026-03-20	14:21:29.342212	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
439	2026-03-20	14:33:33.316984	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
440	2026-03-20	17:45:09.286792	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
441	2026-03-20	17:51:34.122696	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
442	2026-03-20	17:57:24.579595	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
443	2026-03-20	18:11:10.046741	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
444	2026-03-20	18:16:25.820215	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
445	2026-03-20	18:52:39.391173	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
446	2026-03-20	18:54:29.086499	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
447	2026-03-20	19:16:44.634063	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
448	2026-03-21	12:24:45.01229	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
449	2026-03-21	12:39:58.887982	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
450	2026-03-21	13:19:46.807748	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
451	2026-03-21	13:46:26.500127	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
452	2026-03-21	13:49:06.650361	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
453	2026-03-21	13:49:54.391022	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
454	2026-03-21	13:51:03.703174	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
455	2026-03-21	13:59:29.586734	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
456	2026-03-21	14:29:50.625794	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
457	2026-03-21	14:31:06.542921	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
458	2026-03-21	14:32:30.402296	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
459	2026-03-21	14:41:43.825456	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
460	2026-03-21	14:53:26.434932	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
461	2026-03-21	15:01:57.972292	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
462	2026-03-21	15:11:11.059352	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
463	2026-03-21	15:16:41.425351	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
464	2026-03-21	15:19:55.783878	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
465	2026-03-21	15:26:27.11289	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
466	2026-03-21	15:35:35.96331	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
467	2026-03-21	15:36:18.413692	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
468	2026-03-21	15:48:21.203049	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
469	2026-03-21	15:48:51.013314	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
470	2026-03-21	15:49:58.011871	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
471	2026-03-21	15:57:45.444813	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
472	2026-03-23	11:21:08.771884	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
473	2026-03-23	12:08:40.826235	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
474	2026-03-23	12:26:09.795924	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
475	2026-03-23	13:17:13.048759	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
476	2026-03-23	13:37:47.177914	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
477	2026-03-23	13:39:46.597792	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
478	2026-03-23	13:40:14.752449	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
479	2026-03-23	13:47:28.504483	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
480	2026-03-23	13:58:07.021584	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
481	2026-03-23	14:01:44.412347	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
482	2026-03-23	14:02:27.916152	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
483	2026-03-23	14:03:11.169987	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
484	2026-03-23	14:33:30.238265	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
485	2026-03-23	15:09:05.95643	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
486	2026-03-23	17:21:28.184366	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
487	2026-03-23	17:59:23.016152	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
488	2026-03-23	18:11:23.416205	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
489	2026-03-23	18:16:57.586028	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
490	2026-03-23	18:27:36.849665	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
491	2026-03-23	18:36:39.664566	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
492	2026-03-23	18:48:24.875128	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
493	2026-03-23	18:50:27.759391	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
494	2026-03-23	18:57:42.661175	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
495	2026-03-23	19:09:51.351682	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
496	2026-03-23	19:33:42.980468	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
497	2026-03-26	10:44:31.909541	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
498	2026-03-26	10:46:03.714933	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
499	2026-03-26	11:23:08.642429	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
500	2026-03-26	11:34:01.502774	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
501	2026-03-26	11:41:59.848514	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
502	2026-03-26	11:43:16.466308	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
503	2026-03-26	11:44:13.787624	N/A	0	Cuauhtémoc Rivera Agundez	FALLO DE LOGIN
504	2026-03-26	11:44:25.783055	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
505	2026-03-26	11:47:26.014299	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
506	2026-03-26	11:48:06.571442	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
507	2026-03-26	11:58:12.34973	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
508	2026-03-26	14:18:22.906313	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
509	2026-03-26	14:18:47.96259	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
510	2026-03-26	14:19:58.92435	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
511	2026-03-26	14:21:41.759463	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
512	2026-03-26	14:24:30.738988	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
513	2026-03-26	14:25:23.932661	N/A	0	Martin Eduardo Sanchez Estrada	FALLO DE LOGIN
514	2026-03-26	14:25:34.96513	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
515	2026-03-26	14:26:45.284778	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
516	2026-03-26	14:50:49.742117	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
517	2026-03-26	17:14:03.86962	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
518	2026-03-26	17:26:52.260251	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
519	2026-03-26	17:49:07.359042	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
520	2026-03-26	18:06:49.019942	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
521	2026-03-26	18:13:23.446442	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
522	2026-03-26	18:20:33.812315	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
523	2026-03-26	18:21:06.89021	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
524	2026-03-26	18:31:25.222983	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
525	2026-03-26	18:54:51.953032	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
526	2026-03-26	19:30:01.501663	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
527	2026-03-26	19:30:17.716676	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
528	2026-03-27	13:59:33.286709	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
529	2026-03-27	14:31:34.475792	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
530	2026-03-27	14:45:10.416881	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
531	2026-03-27	15:04:42.702439	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
532	2026-03-27	16:59:15.278892	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
533	2026-03-27	17:03:42.310478	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
534	2026-03-27	17:12:13.295304	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
535	2026-03-27	17:12:26.578582	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
536	2026-03-27	17:13:25.39647	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
537	2026-03-27	17:18:52.446954	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
538	2026-03-27	19:54:58.780347	N/A	0	Pedro Villarreal Uribe	FALLO DE LOGIN
539	2026-03-27	19:55:11.189574	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
540	2026-03-27	20:07:36.999116	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
541	2026-03-27	20:11:32.534218	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
542	2026-03-28	13:28:24.772568	N/A	0	Sofía Alejandra Villarreal L├│pez	FALLO DE LOGIN
543	2026-03-28	13:28:39.220258	N/A	121	Sofía Alejandra Villarreal L├│pez	LOGIN EXITOSO
544	2026-03-30	10:35:25.47694	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
545	2026-03-30	10:39:48.646615	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
546	2026-03-30	12:54:12.704064	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
547	2026-03-30	14:05:13.46876	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
548	2026-03-30	14:13:09.283629	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
549	2026-03-30	14:21:40.689608	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
550	2026-03-30	14:24:34.736089	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
551	2026-03-30	14:29:34.546238	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
552	2026-03-30	14:33:56.745798	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
553	2026-03-30	14:37:25.651258	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
554	2026-03-30	14:42:19.880541	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
555	2026-03-30	17:07:40.557078	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
556	2026-03-30	17:09:20.328201	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
557	2026-03-30	17:09:36.291769	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
558	2026-03-30	17:19:30.338787	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
559	2026-03-30	17:19:43.006624	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
560	2026-03-30	17:20:53.280724	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
561	2026-03-30	17:21:06.257968	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
562	2026-03-30	17:22:51.468842	N/A	110	Eduardo Alonso Valdéz G├│mez	LOGIN EXITOSO
563	2026-03-30	17:23:32.234267	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
564	2026-03-30	17:23:48.933653	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
565	2026-03-30	17:23:57.814153	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
566	2026-03-30	17:24:56.393108	N/A	110	Eduardo Alonso Valdéz G├│mez	LOGIN EXITOSO
567	2026-03-30	17:26:14.699976	N/A	110	Eduardo Alonso Valdéz G├│mez	LOGIN EXITOSO
568	2026-03-30	17:55:09.963021	N/A	110	Eduardo Alonso Valdéz G├│mez	LOGIN EXITOSO
569	2026-03-30	18:01:02.260593	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
570	2026-03-30	18:01:24.853627	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
571	2026-03-30	18:02:09.470189	N/A	110	Eduardo Alonso Valdéz G├│mez	LOGIN EXITOSO
572	2026-03-30	18:10:08.354208	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
573	2026-03-30	18:20:43.421597	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
574	2026-03-30	18:20:52.024248	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
575	2026-03-30	18:21:29.904952	N/A	109	Osiel Cuauhtémoc Hern├índez Aldape	LOGIN EXITOSO
576	2026-03-30	18:30:55.427049	N/A	109	Osiel Cuauhtémoc Hern├índez Aldape	LOGIN EXITOSO
577	2026-03-30	18:32:01.821643	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
578	2026-03-30	18:33:00.139282	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
579	2026-03-30	18:33:57.493008	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
580	2026-03-30	18:44:44.509856	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
581	2026-03-30	18:44:54.343527	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
582	2026-03-30	18:47:48.18479	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
583	2026-03-30	18:52:59.501972	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
584	2026-03-30	18:54:02.886577	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
585	2026-03-30	19:02:31.940623	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
586	2026-03-30	19:03:57.167473	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
587	2026-03-30	19:04:05.696605	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
588	2026-03-31	10:34:44.148075	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
589	2026-03-31	10:45:00.732984	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
590	2026-03-31	10:46:03.365567	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
591	2026-03-31	10:46:58.462628	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
592	2026-03-31	11:44:26.540087	N/A	0	Pedro Villarreal Uribe	FALLO DE LOGIN
593	2026-03-31	11:44:38.838607	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
594	2026-03-31	11:46:54.4957	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
595	2026-03-31	11:52:02.093106	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
596	2026-03-31	12:18:58.249646	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
597	2026-03-31	12:31:05.453393	N/A	0	Carlos Jacobo Quezada Mendoza	FALLO DE LOGIN
598	2026-03-31	12:31:15.569553	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
599	2026-03-31	13:23:45.549006	N/A	0	Carlos Jacobo Quezada Mendoza	FALLO DE LOGIN
600	2026-03-31	13:23:55.39323	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
601	2026-03-31	13:25:10.019632	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
602	2026-03-31	13:25:40.993527	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
603	2026-03-31	13:34:49.757667	N/A	0	Carlos Jacobo Quezada Mendoza	FALLO DE LOGIN
604	2026-03-31	13:35:01.904619	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
605	2026-03-31	13:35:55.013167	N/A	0	Carlos Jacobo Quezada Mendoza	FALLO DE LOGIN
606	2026-03-31	13:36:03.477674	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
607	2026-03-31	13:43:06.227541	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
608	2026-03-31	13:59:39.866086	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
609	2026-03-31	14:17:31.691566	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
610	2026-03-31	14:22:02.513687	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
611	2026-03-31	14:22:58.764855	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
612	2026-03-31	14:52:34.047653	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
613	2026-03-31	17:21:49.523928	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
614	2026-03-31	17:42:44.161231	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
615	2026-03-31	17:43:51.991727	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
616	2026-03-31	17:44:23.9235	N/A	0	Edgar Javier Amarillas	FALLO DE LOGIN
617	2026-03-31	17:44:48.487439	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
618	2026-03-31	17:45:28.987676	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
619	2026-03-31	17:46:08.238173	N/A	110	Eduardo Alonso Valdéz G├│mez	LOGIN EXITOSO
620	2026-03-31	17:49:28.170033	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
621	2026-03-31	17:50:40.681382	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
622	2026-03-31	17:51:19.116051	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
623	2026-03-31	17:51:42.065282	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
624	2026-03-31	17:52:46.546465	N/A	109	Osiel Cuauhtémoc Hern├índez Aldape	LOGIN EXITOSO
625	2026-03-31	17:53:36.816722	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
626	2026-03-31	17:54:29.264551	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
627	2026-03-31	17:54:58.388446	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
628	2026-03-31	17:57:39.393118	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
629	2026-03-31	18:01:46.756355	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
630	2026-03-31	19:02:31.81037	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
631	2026-03-31	19:16:17.517061	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
632	2026-03-31	19:17:08.988025	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
633	2026-03-31	19:17:43.280687	N/A	0	José Francisco Torres Sanchez	FALLO DE LOGIN
634	2026-03-31	19:17:55.387495	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
635	2026-03-31	19:18:16.874109	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
636	2026-03-31	19:19:03.901093	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
637	2026-03-31	19:20:54.477327	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
638	2026-03-31	19:21:35.591267	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
639	2026-03-31	19:22:19.405495	N/A	0	Eduardo Alonso Valdéz G├│mez	FALLO DE LOGIN
640	2026-03-31	19:22:29.802474	N/A	110	Eduardo Alonso Valdéz G├│mez	LOGIN EXITOSO
641	2026-03-31	19:23:03.814966	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
642	2026-03-31	19:23:43.057871	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
643	2026-03-31	19:24:23.621086	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
644	2026-03-31	19:24:54.644818	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
645	2026-03-31	19:54:22.519225	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
646	2026-04-01	10:33:40.59079	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
647	2026-04-01	11:17:37.939004	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
648	2026-04-01	11:33:54.061358	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
649	2026-04-01	11:46:21.63473	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
650	2026-04-01	12:06:49.987715	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
651	2026-04-01	12:19:28.264026	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
652	2026-04-01	12:43:10.494865	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
653	2026-04-01	12:46:11.193843	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
654	2026-04-01	12:46:40.2294	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
655	2026-04-01	12:51:10.983392	N/A	0	Héctor Rementeria de la Rocha	FALLO DE LOGIN
656	2026-04-01	12:51:21.870233	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
657	2026-04-01	13:06:13.185434	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
658	2026-04-01	13:08:12.203414	N/A	0	Héctor Rementeria de la Rocha	FALLO DE LOGIN
659	2026-04-01	13:08:21.476066	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
660	2026-04-01	13:10:39.058351	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
661	2026-04-01	13:10:52.260407	N/A	0	Héctor Rementeria de la Rocha	FALLO DE LOGIN
662	2026-04-01	13:11:02.197797	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
663	2026-04-01	13:17:10.654662	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
664	2026-04-01	13:22:44.85327	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
665	2026-04-01	13:23:49.251943	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
666	2026-04-01	13:24:13.978507	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
667	2026-04-01	13:28:45.554869	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
668	2026-04-01	13:48:12.710161	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
669	2026-04-01	13:49:29.060435	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
670	2026-04-01	13:49:41.505032	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
671	2026-04-01	13:55:44.968442	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
672	2026-04-01	13:56:15.18187	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
673	2026-04-01	13:56:30.872666	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
674	2026-04-01	13:58:57.854563	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
675	2026-04-01	14:07:09.114922	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
676	2026-04-01	14:22:21.076037	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
677	2026-04-01	14:24:36.775923	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
678	2026-04-01	14:28:20.383856	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
679	2026-04-01	14:43:27.180072	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
680	2026-04-01	14:45:09.63924	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
681	2026-04-01	14:50:57.973711	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
682	2026-04-01	14:55:52.858659	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
683	2026-04-01	15:05:28.617964	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
684	2026-04-01	17:30:07.731768	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
685	2026-04-01	17:30:44.900275	N/A	115	Ibon Araceli Campos Medina	LOGIN EXITOSO
686	2026-04-01	17:39:01.458063	N/A	0	Ibon Araceli Campos Medina	FALLO DE LOGIN
687	2026-04-01	17:39:38.036023	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
688	2026-04-01	17:40:02.472242	N/A	115	Ibon Araceli Campos Medina	LOGIN EXITOSO
689	2026-04-01	17:41:59.983381	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
690	2026-04-01	17:42:38.113062	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
691	2026-04-01	17:43:15.750434	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
692	2026-04-01	17:43:51.517553	N/A	109	Osiel Cuauhtémoc Hern├índez Aldape	LOGIN EXITOSO
693	2026-04-01	17:44:38.94509	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
694	2026-04-01	17:45:02.671321	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
695	2026-04-01	17:45:34.41491	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
696	2026-04-01	17:46:19.843295	N/A	0	José Daniel Torres Arroyo	FALLO DE LOGIN
697	2026-04-01	17:46:30.06619	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
698	2026-04-01	17:47:07.29091	N/A	0	Ibon Araceli Campos Medina	FALLO DE LOGIN
699	2026-04-01	17:47:15.566167	N/A	115	Ibon Araceli Campos Medina	LOGIN EXITOSO
700	2026-04-01	17:47:41.465037	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
701	2026-04-01	17:48:20.856426	N/A	102	Gerardo Villarreal Uribe	LOGIN EXITOSO
702	2026-04-01	17:48:41.839603	N/A	110	Eduardo Alonso Valdéz G├│mez	LOGIN EXITOSO
703	2026-04-01	17:49:16.962127	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
704	2026-04-01	18:01:30.511862	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
705	2026-04-01	18:06:10.804596	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
706	2026-04-01	18:11:05.487418	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
707	2026-04-01	18:14:06.198481	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
708	2026-04-01	18:16:55.641796	N/A	0	Carlos Jacobo Quezada Mendoza	FALLO DE LOGIN
709	2026-04-01	18:17:22.265167	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
710	2026-04-01	18:27:47.108255	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
711	2026-04-01	18:27:55.251172	N/A	109	Osiel Cuauhtémoc Hern├índez Aldape	LOGIN EXITOSO
712	2026-04-01	18:40:38.054955	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
713	2026-04-01	18:50:45.729419	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
714	2026-04-01	18:54:24.355288	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
715	2026-04-01	19:02:14.627979	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
716	2026-04-01	19:05:40.675738	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
717	2026-04-01	19:09:44.369655	N/A	0	Pedro Villarreal Uribe	FALLO DE LOGIN
718	2026-04-01	19:09:46.970089	N/A	0	Pedro Villarreal Uribe	FALLO DE LOGIN
719	2026-04-01	19:09:55.050329	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
720	2026-04-01	19:18:19.258461	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
721	2026-04-01	19:23:56.12003	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
722	2026-04-01	19:36:17.699487	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
723	2026-04-01	19:43:08.658063	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
724	2026-04-01	19:45:56.267496	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
725	2026-04-01	19:48:56.333583	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
726	2026-04-01	19:50:15.771166	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
727	2026-04-05	17:53:57.009217	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
728	2026-04-05	18:00:49.010779	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
729	2026-04-05	18:11:17.067164	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
730	2026-04-05	19:57:19.867914	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
731	2026-04-06	12:41:23.455013	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
732	2026-04-06	12:43:23.528742	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
733	2026-04-06	12:57:40.610221	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
734	2026-04-06	13:06:20.762676	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
735	2026-04-06	14:07:55.189539	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
736	2026-04-06	14:12:07.637265	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
737	2026-04-06	14:30:01.901199	N/A	0	Sofía Alejandra Villarreal L├│pez	FALLO DE LOGIN
738	2026-04-06	14:30:13.819401	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
739	2026-04-06	14:30:55.996399	N/A	121	Sofía Alejandra Villarreal L├│pez	LOGIN EXITOSO
740	2026-04-06	17:13:53.927471	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
741	2026-04-06	17:24:44.853365	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
742	2026-04-06	17:26:06.403799	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
743	2026-04-06	17:35:24.794616	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
744	2026-04-06	17:36:27.893545	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
745	2026-04-06	17:56:33.070132	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
746	2026-04-06	17:59:56.050079	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
747	2026-04-06	18:06:08.796188	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
748	2026-04-06	18:07:07.983108	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
749	2026-04-06	18:17:03.747643	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
750	2026-04-06	18:18:41.372239	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
751	2026-04-06	18:40:13.815494	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
752	2026-04-06	18:41:09.259491	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
753	2026-04-06	18:41:32.794807	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
754	2026-04-06	18:42:39.229815	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
755	2026-04-06	18:43:57.200878	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
756	2026-04-06	19:08:40.993594	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
757	2026-04-06	19:09:18.973583	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
758	2026-04-06	19:11:32.86486	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
759	2026-04-06	19:13:55.759894	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
760	2026-04-07	17:38:02.817566	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
761	2026-04-07	17:44:31.577759	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
762	2026-04-07	17:46:33.575951	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
763	2026-04-07	17:54:44.267504	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
764	2026-04-07	18:01:51.403123	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
765	2026-04-07	18:02:36.59277	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
766	2026-04-07	18:03:09.467071	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
767	2026-04-07	18:10:48.451688	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
768	2026-04-09	11:35:35.783921	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
769	2026-04-09	11:48:36.942314	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
770	2026-04-09	12:06:58.373736	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
771	2026-04-09	12:47:28.800511	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
772	2026-04-09	12:57:04.630054	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
773	2026-04-10	17:14:17.830626	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
774	2026-04-10	17:15:58.374867	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
775	2026-04-10	17:16:46.320575	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
776	2026-04-11	17:29:16.279366	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
777	2026-04-11	17:31:15.904255	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
778	2026-04-11	17:40:31.53257	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
779	2026-04-11	17:42:04.752765	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
780	2026-04-11	18:36:37.927053	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
781	2026-04-11	19:03:36.737813	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
782	2026-04-11	20:01:22.219713	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
783	2026-04-11	20:52:57.989096	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
784	2026-04-11	21:01:26.0955	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
785	2026-04-11	21:07:10.764446	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
786	2026-04-11	21:18:06.683144	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
787	2026-04-11	21:18:51.090477	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
788	2026-04-13	10:56:55.240975	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
789	2026-04-13	11:25:33.177954	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
790	2026-04-13	11:31:33.263387	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
791	2026-04-13	11:46:07.206553	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
792	2026-04-13	11:47:13.084723	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
793	2026-04-13	11:51:19.155743	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
794	2026-04-13	11:51:56.996972	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
795	2026-04-13	11:55:52.604721	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
796	2026-04-13	11:56:22.24896	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
797	2026-04-13	12:15:04.022438	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
798	2026-04-13	12:16:24.66549	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
799	2026-04-13	12:18:36.813235	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
800	2026-04-13	12:19:11.462145	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
801	2026-04-13	13:51:35.763523	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
802	2026-04-13	13:52:20.510946	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
803	2026-04-13	13:53:06.274472	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
804	2026-04-13	15:36:33.750728	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
805	2026-04-13	15:41:31.152159	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
806	2026-04-13	15:46:30.919572	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
807	2026-04-13	15:50:56.008723	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
808	2026-04-13	16:09:38.593771	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
809	2026-04-13	16:11:06.089192	N/A	0	Edgar Javier Amarillas	FALLO DE LOGIN
810	2026-04-13	16:11:30.056055	N/A	0	Edgar Javier Amarillas	FALLO DE LOGIN
811	2026-04-13	16:11:55.570547	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
812	2026-04-13	16:12:33.105321	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
813	2026-04-13	16:18:35.527321	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
814	2026-04-13	16:23:01.456233	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
815	2026-04-13	16:25:10.682445	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
816	2026-04-13	16:26:07.214738	N/A	110	Eduardo Alonso Valdéz G├│mez	LOGIN EXITOSO
817	2026-04-13	16:30:46.093965	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
818	2026-04-13	16:31:46.685588	N/A	0	Héctor Rementeria de la Rocha	FALLO DE LOGIN
819	2026-04-13	16:31:58.028117	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
820	2026-04-13	16:34:21.583244	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
821	2026-04-13	16:36:00.750768	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
822	2026-04-13	16:37:58.581428	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
823	2026-04-13	16:38:32.232508	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
824	2026-04-13	16:40:53.279821	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
825	2026-04-13	16:41:26.47919	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
826	2026-04-13	16:42:30.648944	N/A	0	Manuel Antonio Madrid Zazueta	FALLO DE LOGIN
827	2026-04-13	16:42:44.796093	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
828	2026-04-13	16:46:16.340965	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
829	2026-04-13	16:46:42.836309	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
830	2026-04-13	16:47:37.11166	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
831	2026-04-13	16:48:44.897414	N/A	109	Osiel Cuauhtémoc Hern├índez Aldape	LOGIN EXITOSO
832	2026-04-13	16:53:39.168958	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
833	2026-04-13	16:54:20.536005	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
834	2026-04-13	16:55:44.411628	N/A	109	Osiel Cuauhtémoc Hern├índez Aldape	LOGIN EXITOSO
835	2026-04-13	16:56:30.6892	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
836	2026-04-13	16:57:14.853893	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
837	2026-04-13	16:58:01.930678	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
838	2026-04-13	16:58:35.837535	N/A	0	José Francisco Torres Sanchez	FALLO DE LOGIN
839	2026-04-13	16:58:55.179228	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
840	2026-04-13	16:59:34.07139	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
841	2026-04-13	17:00:13.220544	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
842	2026-04-13	17:00:48.448729	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
843	2026-04-13	17:01:17.084803	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
844	2026-04-13	17:01:57.665774	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
845	2026-04-13	17:02:24.714081	N/A	0	Eduardo Alonso Valdéz G├│mez	FALLO DE LOGIN
846	2026-04-13	17:02:38.828472	N/A	110	Eduardo Alonso Valdéz G├│mez	LOGIN EXITOSO
847	2026-04-13	17:03:13.858181	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
848	2026-04-13	17:03:51.633463	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
849	2026-04-13	17:04:28.62604	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
850	2026-04-13	17:04:54.036077	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
851	2026-04-13	17:05:23.65245	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
852	2026-04-13	17:10:02.750915	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
853	2026-04-13	17:11:31.495397	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
854	2026-04-13	17:12:56.648005	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
855	2026-04-13	17:25:23.035729	N/A	0	Ana Lilia Villarreal Uribe	FALLO DE LOGIN
856	2026-04-13	17:25:34.218494	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
857	2026-04-13	18:26:16.025218	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
858	2026-04-13	18:41:15.908484	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
859	2026-04-13	18:47:28.656002	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
860	2026-04-13	18:50:59.129463	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
861	2026-04-13	18:56:08.587037	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
862	2026-04-13	18:57:36.26969	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
863	2026-04-13	18:58:44.744953	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
864	2026-04-13	19:26:23.640541	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
865	2026-04-13	19:28:25.308094	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
866	2026-04-13	19:30:33.698261	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
867	2026-04-13	19:33:23.005248	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
868	2026-04-13	19:39:10.31268	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
869	2026-04-14	10:58:17.59505	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
870	2026-04-14	11:03:59.405054	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
871	2026-04-14	11:35:21.138182	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
872	2026-04-14	11:56:56.205287	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
873	2026-04-14	12:43:13.777215	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
874	2026-04-14	13:30:37.488464	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
875	2026-04-14	13:34:16.362277	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
876	2026-04-14	13:57:35.680556	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
877	2026-04-14	14:08:21.354654	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
878	2026-04-14	14:13:16.152389	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
879	2026-04-14	14:39:38.152235	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
880	2026-04-14	14:47:02.279169	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
881	2026-04-14	14:53:18.21624	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
882	2026-04-14	14:54:56.762855	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
883	2026-04-14	15:11:23.123192	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
884	2026-04-14	16:49:21.997732	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
885	2026-04-14	16:52:48.83047	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
886	2026-04-14	17:18:08.429094	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
887	2026-04-14	17:45:43.933386	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
888	2026-04-14	17:55:08.437059	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
889	2026-04-14	17:59:44.35011	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
890	2026-04-14	18:07:24.193779	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
891	2026-04-14	18:28:29.880049	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
892	2026-04-14	18:30:39.356589	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
893	2026-04-14	18:31:44.04331	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
894	2026-04-14	18:32:51.899749	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
895	2026-04-14	18:45:07.949791	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
896	2026-04-14	18:46:52.099701	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
897	2026-04-14	18:48:47.832526	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
898	2026-04-14	18:49:13.232273	N/A	0	Edgar Javier Amarillas	FALLO DE LOGIN
899	2026-04-14	18:49:20.834093	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
900	2026-04-14	18:50:28.579493	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
901	2026-04-14	18:52:52.563045	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
902	2026-04-14	18:53:09.060828	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
903	2026-04-14	18:53:40.31265	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
904	2026-04-14	18:54:08.469216	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
905	2026-04-14	19:07:35.217754	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
906	2026-04-14	19:21:39.352699	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
907	2026-04-14	19:24:22.218182	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
908	2026-04-14	19:41:31.000638	N/A	0	Pedro Villarreal Uribe	FALLO DE LOGIN
909	2026-04-14	19:41:38.003703	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
910	2026-04-14	19:43:35.071779	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
911	2026-04-14	19:49:11.754193	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
912	2026-04-14	19:52:12.704082	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
913	2026-04-15	10:52:44.742909	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
914	2026-04-15	10:58:44.900456	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
915	2026-04-15	11:48:08.226523	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
916	2026-04-15	11:50:38.190232	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
917	2026-04-15	11:55:03.892855	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
918	2026-04-15	11:59:58.741283	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
919	2026-04-15	12:06:31.200272	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
920	2026-04-15	12:17:14.646557	N/A	0	Cuauhtémoc Rivera Agundez	FALLO DE LOGIN
921	2026-04-15	12:17:18.32639	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
922	2026-04-15	13:14:18.915005	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
923	2026-04-15	14:15:14.059949	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
924	2026-04-15	14:25:10.973579	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
925	2026-04-15	14:34:12.07471	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
926	2026-04-15	14:35:18.158934	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
927	2026-04-15	14:35:26.104227	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
928	2026-04-15	14:35:39.053914	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
929	2026-04-15	14:36:45.040022	N/A	0	Pedro Villarreal Uribe	FALLO DE LOGIN
930	2026-04-15	14:36:52.606538	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
931	2026-04-15	14:38:28.432055	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
932	2026-04-15	14:40:43.526421	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
933	2026-04-15	14:40:52.904737	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
934	2026-04-15	15:00:13.296828	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
935	2026-04-15	15:01:56.456589	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
936	2026-04-15	15:03:41.391344	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
937	2026-04-15	15:04:05.583632	N/A	200	Andrea María Vilarreal L├│pez	LOGIN EXITOSO
938	2026-04-15	15:04:44.230765	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
939	2026-04-15	15:10:19.278278	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
940	2026-04-15	15:11:25.715943	N/A	0	Pedro Villarreal Uribe	FALLO DE LOGIN
941	2026-04-15	15:11:35.202551	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
942	2026-04-15	15:12:47.881077	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
943	2026-04-15	17:30:29.528268	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
944	2026-04-15	17:31:00.181205	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
945	2026-04-15	17:32:24.13351	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
946	2026-04-15	17:33:02.902761	N/A	0	Cuauhtémoc Rivera Agundez	FALLO DE LOGIN
947	2026-04-15	17:33:14.834579	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
948	2026-04-15	18:40:09.805788	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
949	2026-04-17	10:19:18.938756	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
950	2026-04-17	10:23:22.475732	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
951	2026-04-17	12:35:58.730625	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
952	2026-04-17	12:49:59.403366	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
953	2026-04-17	14:53:53.035196	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
954	2026-04-17	17:31:26.23662	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
955	2026-04-17	18:25:20.885838	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
956	2026-04-17	18:42:04.577457	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
957	2026-04-17	19:09:17.978901	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
958	2026-04-17	19:09:52.258811	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
959	2026-04-17	19:11:25.324146	N/A	0	Manuel Antonio Madrid Zazueta	FALLO DE LOGIN
960	2026-04-17	19:11:37.854339	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
961	2026-04-17	19:29:44.752927	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
962	2026-04-17	19:30:17.665431	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
963	2026-04-17	19:35:25.929098	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
964	2026-04-17	19:37:40.422519	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
965	2026-04-17	19:45:22.659806	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
966	2026-04-17	19:51:10.769486	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
967	2026-04-18	10:01:24.031878	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
968	2026-04-18	10:12:01.861532	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
969	2026-04-18	10:35:19.717501	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
970	2026-04-20	10:21:37.882771	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
971	2026-04-20	10:25:08.306417	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
972	2026-04-20	10:31:07.467741	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
973	2026-04-20	11:48:06.436765	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
974	2026-04-20	12:03:40.338397	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
975	2026-04-20	12:06:56.021135	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
976	2026-04-20	13:24:39.645339	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
977	2026-04-20	13:36:06.286652	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
978	2026-04-20	17:51:08.690124	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
979	2026-04-20	17:56:10.237668	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
980	2026-04-20	18:21:01.788938	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
981	2026-04-20	18:22:42.808209	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
982	2026-04-20	18:23:06.890254	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
983	2026-04-21	15:05:42.723674	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
984	2026-04-21	18:43:01.297155	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
985	2026-04-21	19:46:37.659146	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
986	2026-04-22	14:30:43.364399	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
987	2026-04-22	15:22:18.057557	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
988	2026-04-22	15:31:21.009323	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
989	2026-04-23	10:22:20.447979	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
990	2026-04-23	10:23:28.164243	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
991	2026-04-23	10:30:14.252585	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
992	2026-04-23	10:31:08.720555	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
993	2026-04-23	10:39:24.978848	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
994	2026-04-23	11:39:51.522599	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
995	2026-04-23	11:48:46.223201	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
996	2026-04-23	11:55:40.336417	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
997	2026-04-23	11:58:10.837758	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
998	2026-04-23	13:17:51.764723	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
999	2026-04-23	13:32:58.549103	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1000	2026-04-23	14:26:44.65284	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1001	2026-04-23	14:55:02.26531	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1002	2026-04-23	14:56:04.15962	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1003	2026-04-23	14:58:01.520931	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1004	2026-04-23	17:09:12.102839	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1005	2026-04-23	17:13:30.253303	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1006	2026-04-23	17:17:59.225312	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1007	2026-04-23	17:25:24.209181	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1008	2026-04-23	17:31:27.538374	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1009	2026-04-23	19:00:02.693333	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1010	2026-04-23	19:03:24.471976	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1011	2026-04-23	19:20:52.619107	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1012	2026-04-23	19:21:33.044086	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1013	2026-04-23	19:35:32.173452	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1014	2026-04-23	19:40:32.838116	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1015	2026-04-23	19:47:23.153792	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1016	2026-04-23	19:53:29.385215	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1017	2026-04-24	10:34:18.474484	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1018	2026-04-24	10:36:01.008303	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1019	2026-04-24	10:43:01.431424	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1020	2026-04-24	10:54:39.84946	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1021	2026-04-24	11:02:28.33375	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1022	2026-04-24	11:18:49.837395	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1023	2026-04-24	11:20:41.419481	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1024	2026-04-24	12:05:32.368016	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1025	2026-04-24	12:13:36.8632	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1026	2026-04-24	12:15:29.613985	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1027	2026-04-24	12:18:10.619608	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1028	2026-04-24	12:50:29.434531	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1029	2026-04-24	12:54:09.796479	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1030	2026-04-24	13:17:45.821258	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1031	2026-04-24	13:25:05.704284	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1032	2026-04-24	13:36:46.714957	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1033	2026-04-24	13:41:39.466925	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1034	2026-04-24	13:49:28.560065	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1035	2026-04-24	13:50:53.520793	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1036	2026-04-24	14:14:34.212021	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1037	2026-04-24	14:14:57.639382	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1038	2026-04-24	14:31:03.78822	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1039	2026-04-24	17:27:41.84691	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1040	2026-04-24	17:40:45.706554	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1041	2026-04-24	17:52:01.774553	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1042	2026-04-24	18:08:56.408537	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1043	2026-04-24	18:13:01.630929	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1044	2026-04-24	18:29:12.687212	N/A	0	Cuauhtémoc Rivera Agundez	FALLO DE LOGIN
1045	2026-04-24	18:29:34.237845	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1046	2026-04-24	18:48:06.976723	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1047	2026-04-24	19:03:53.210534	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1048	2026-04-24	19:17:43.788988	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1049	2026-04-24	19:18:22.614332	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1050	2026-04-24	19:29:50.608408	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1051	2026-04-25	10:42:38.330131	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1052	2026-04-25	10:44:10.89837	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1053	2026-04-25	11:00:20.955452	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1054	2026-04-25	12:47:33.3503	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1055	2026-04-25	12:48:04.343461	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1056	2026-04-25	12:49:08.813208	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1057	2026-04-25	12:51:09.524339	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1058	2026-04-25	12:57:31.991587	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1059	2026-04-25	13:02:17.395913	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1060	2026-04-25	13:03:20.834873	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1061	2026-04-25	13:14:14.996246	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1062	2026-04-25	13:15:13.404126	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1063	2026-04-25	14:20:05.118207	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1064	2026-04-25	14:32:53.174326	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1065	2026-04-25	14:35:20.796424	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1066	2026-04-25	14:39:20.91142	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1067	2026-04-27	18:20:38.574468	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1068	2026-04-27	18:22:59.652784	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1069	2026-04-27	18:24:54.2159	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1070	2026-04-27	18:26:21.964642	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1071	2026-04-27	18:27:20.589863	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1072	2026-04-27	18:30:37.942242	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1073	2026-04-27	18:34:54.961908	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1074	2026-04-27	18:36:11.305621	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1075	2026-04-27	18:51:01.713742	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1076	2026-04-27	18:51:40.199402	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1077	2026-04-27	18:55:11.90169	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1078	2026-04-27	18:58:02.726229	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1079	2026-04-27	18:59:17.95226	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1080	2026-04-27	19:03:53.495983	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1081	2026-04-27	19:19:37.458951	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1082	2026-04-27	19:33:14.229566	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1083	2026-04-27	19:36:04.501339	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1084	2026-04-27	19:39:05.949996	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1085	2026-04-27	19:46:14.295581	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1086	2026-04-27	19:49:07.821672	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1087	2026-04-30	12:28:02.426692	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1088	2026-04-30	12:32:48.051196	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1089	2026-04-30	12:34:47.962128	N/A	0	Cuauhtémoc Rivera Agundez	FALLO DE LOGIN
1090	2026-04-30	12:34:55.878225	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1091	2026-04-30	12:40:24.754068	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1092	2026-04-30	12:53:49.595906	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1093	2026-04-30	13:23:04.187381	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1094	2026-04-30	13:27:06.784093	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1095	2026-04-30	14:12:00.232065	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1096	2026-04-30	14:12:43.890174	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1097	2026-04-30	15:29:32.778175	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1098	2026-04-30	17:20:16.949693	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1099	2026-04-30	17:23:32.620711	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1100	2026-05-01	18:14:15.252823	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1101	2026-05-05	13:25:10.482609	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1102	2026-05-05	14:05:18.726868	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1103	2026-05-05	14:08:18.770609	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1104	2026-05-05	14:44:39.977303	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1105	2026-05-05	17:25:24.487051	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1106	2026-05-06	17:26:55.43323	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1107	2026-05-06	17:33:31.69038	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1108	2026-05-06	18:37:57.172327	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1109	2026-05-06	19:52:33.827577	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1110	2026-05-06	19:53:34.110592	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1111	2026-05-06	19:59:00.055223	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1112	2026-05-07	10:37:24.478911	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1113	2026-05-07	11:47:00.701693	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1114	2026-05-07	11:52:41.322594	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1115	2026-05-07	12:02:43.235507	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1116	2026-05-07	12:08:36.898846	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1117	2026-05-07	12:13:57.60778	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1118	2026-05-07	12:31:09.358203	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1119	2026-05-07	12:50:46.71189	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1120	2026-05-07	12:53:50.07804	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1121	2026-05-07	18:13:35.285732	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1122	2026-05-07	18:14:35.167262	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1123	2026-05-07	18:20:56.466093	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1124	2026-05-07	18:52:20.93258	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1125	2026-05-07	18:53:43.84357	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1126	2026-05-08	13:19:57.786583	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1127	2026-05-08	14:45:04.84491	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1128	2026-05-08	15:08:28.757724	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1129	2026-05-08	17:22:50.166554	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1130	2026-05-08	18:02:55.559889	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1131	2026-05-08	18:37:25.083638	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1132	2026-05-08	18:40:28.126253	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1133	2026-05-08	19:38:01.239754	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1134	2026-05-08	19:45:19.777847	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1135	2026-05-08	19:46:49.453458	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1136	2026-05-08	19:49:41.60668	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1137	2026-05-09	10:16:19.94408	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1138	2026-05-09	10:24:04.291563	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1139	2026-05-09	10:32:03.191031	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1140	2026-05-09	10:37:34.590389	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1141	2026-05-09	10:41:06.325481	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
1142	2026-05-09	10:41:40.016363	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1143	2026-05-09	10:42:23.685537	N/A	0	Carlos Jacobo Quezada Mendoza	FALLO DE LOGIN
1144	2026-05-09	10:42:56.258414	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1145	2026-05-09	11:04:55.825509	N/A	0	Carlos Jacobo Quezada Mendoza	FALLO DE LOGIN
1146	2026-05-09	11:09:29.452698	N/A	0	Héctor Rementeria de la Rocha	FALLO DE LOGIN
1147	2026-05-09	11:13:30.646654	N/A	0	Héctor Rementeria de la Rocha	FALLO DE LOGIN
1148	2026-05-09	11:13:51.508958	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1149	2026-05-09	11:13:55.747588	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1150	2026-05-09	11:15:14.451504	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
1151	2026-05-09	11:16:04.280351	N/A	0	Manuel Antonio Madrid Zazueta	FALLO DE LOGIN
1152	2026-05-09	11:16:21.841731	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1153	2026-05-09	11:16:47.289147	N/A	0	Andrea María Vilarreal L├│pez	FALLO DE LOGIN
1154	2026-05-09	11:16:51.599653	N/A	0	Manuel Antonio Madrid Zazueta	FALLO DE LOGIN
1155	2026-05-09	11:16:54.712976	N/A	0	Manuel Antonio Madrid Zazueta	FALLO DE LOGIN
1156	2026-05-09	11:17:18.761581	N/A	121	Sofía Alejandra Villarreal L├│pez	LOGIN EXITOSO
1157	2026-05-09	11:17:32.797905	N/A	0	Andrea María Vilarreal L├│pez	FALLO DE LOGIN
1158	2026-05-09	11:19:30.72878	N/A	0	Martin Eduardo Sanchez Estrada	FALLO DE LOGIN
1159	2026-05-09	11:19:38.309932	N/A	0	Martin Eduardo Sanchez Estrada	FALLO DE LOGIN
1160	2026-05-09	11:19:54.905598	N/A	0	Martin Eduardo Sanchez Estrada	FALLO DE LOGIN
1161	2026-05-09	11:20:03.319069	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1162	2026-05-09	11:20:58.418627	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1163	2026-05-09	11:26:41.14312	N/A	0	Martin Eduardo Sanchez Estrada	FALLO DE LOGIN
1164	2026-05-09	11:26:57.387255	N/A	0	Martin Eduardo Sanchez Estrada	FALLO DE LOGIN
1165	2026-05-09	11:26:58.109224	N/A	0	Martin Eduardo Sanchez Estrada	FALLO DE LOGIN
1166	2026-05-09	11:27:36.10491	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1167	2026-05-09	11:28:21.850189	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1168	2026-05-09	11:28:26.70246	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
1169	2026-05-09	11:32:01.280306	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1170	2026-05-09	11:34:38.210874	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1171	2026-05-09	11:35:57.198098	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1172	2026-05-09	11:36:08.183064	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1173	2026-05-09	11:38:23.681851	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1174	2026-05-09	11:38:54.441984	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1175	2026-05-09	11:42:42.06202	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1176	2026-05-09	11:42:42.763446	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
1177	2026-05-09	11:45:10.280802	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1178	2026-05-09	11:46:25.968701	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1179	2026-05-09	11:54:26.514722	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1180	2026-05-09	11:56:02.065838	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
1181	2026-05-09	11:56:56.353584	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
1182	2026-05-09	12:01:01.403387	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1183	2026-05-09	12:19:22.465906	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1184	2026-05-09	12:32:02.512691	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1185	2026-05-09	13:05:51.55602	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1186	2026-05-09	13:07:56.609746	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1187	2026-05-09	13:10:16.71112	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1188	2026-05-09	13:14:25.557091	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1189	2026-05-09	13:30:38.307464	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1190	2026-05-09	13:46:19.738935	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1191	2026-05-09	13:49:24.530704	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1192	2026-05-09	13:51:55.421751	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1193	2026-05-09	13:53:53.215405	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1194	2026-05-09	13:55:13.041862	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1195	2026-05-09	14:05:57.611536	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1196	2026-05-09	14:27:13.144446	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1197	2026-05-11	13:01:44.957699	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1198	2026-05-11	13:48:04.882441	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1199	2026-05-11	17:24:15.43836	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1200	2026-05-11	17:26:20.549539	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1201	2026-05-11	17:29:18.06445	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1202	2026-05-11	17:29:40.059099	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1203	2026-05-11	17:33:28.530747	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1204	2026-05-11	17:35:41.09778	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1205	2026-05-11	17:41:58.325231	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1206	2026-05-11	17:46:57.700686	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1207	2026-05-11	18:03:29.395964	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1208	2026-05-11	18:15:46.024539	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1209	2026-05-11	18:42:43.46684	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1210	2026-05-11	18:50:01.964462	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1211	2026-05-11	19:38:56.423283	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1212	2026-05-12	15:57:19.765944	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1213	2026-05-12	17:04:33.434474	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1214	2026-05-12	19:26:49.434112	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1215	2026-05-13	17:52:47.019057	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1216	2026-05-13	17:54:42.73391	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1217	2026-05-13	17:59:10.98536	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1218	2026-05-13	18:17:04.315232	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1219	2026-05-13	18:18:43.897423	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1220	2026-05-13	18:19:54.528688	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1221	2026-05-13	18:23:06.661429	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1222	2026-05-13	18:29:38.425097	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1223	2026-05-13	18:35:30.882133	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1224	2026-05-13	18:47:02.528689	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1225	2026-05-13	18:56:14.276606	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1226	2026-05-13	19:07:53.356491	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1227	2026-05-14	10:45:29.738329	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1228	2026-05-14	10:45:46.921947	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1229	2026-05-14	10:49:10.919734	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1230	2026-05-14	10:53:12.260386	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1231	2026-05-14	11:00:23.569679	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1232	2026-05-14	11:01:03.282071	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1233	2026-05-14	11:02:15.334886	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1234	2026-05-14	11:02:51.425662	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1235	2026-05-14	11:04:13.199309	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1236	2026-05-14	11:05:49.983456	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1237	2026-05-14	11:17:29.264786	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1238	2026-05-14	11:18:24.748703	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1239	2026-05-14	11:19:50.672454	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1240	2026-05-14	11:33:00.930428	N/A	0	Ana Lilia Villarreal Uribe	FALLO DE LOGIN
1241	2026-05-14	11:33:17.132605	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
1242	2026-05-14	12:13:23.166932	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
1243	2026-05-14	12:13:59.697314	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1244	2026-05-14	12:19:43.761763	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
1245	2026-05-14	12:32:38.598886	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
1246	2026-05-14	13:15:51.795842	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1247	2026-05-14	13:25:17.627881	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
1248	2026-05-14	14:06:51.38603	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
1249	2026-05-14	14:10:30.475061	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
1250	2026-05-14	14:30:57.005487	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1251	2026-05-14	15:03:11.889351	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1252	2026-05-14	17:06:34.812354	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
1253	2026-05-14	17:16:33.436529	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1254	2026-05-14	17:40:31.176599	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
1255	2026-05-14	18:34:57.849982	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1256	2026-05-14	18:36:08.261881	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1257	2026-05-14	18:39:14.231285	N/A	0	José Francisco Torres Sanchez	FALLO DE LOGIN
1258	2026-05-14	18:39:27.237529	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1259	2026-05-14	18:40:02.245962	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1260	2026-05-14	18:47:54.067491	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1261	2026-05-14	18:49:19.439142	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1262	2026-05-14	18:56:57.516075	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1263	2026-05-14	19:02:30.063456	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1264	2026-05-14	19:05:53.984477	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1265	2026-05-14	19:07:38.048665	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1266	2026-05-14	19:26:56.28321	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1267	2026-05-14	19:29:33.887697	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1268	2026-05-14	19:32:48.733699	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1269	2026-05-15	15:27:30.768751	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1270	2026-05-15	15:29:44.44151	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1271	2026-05-15	15:30:31.93433	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1272	2026-05-15	15:37:20.240086	N/A	0	José Francisco Torres Sanchez	FALLO DE LOGIN
1273	2026-05-15	15:37:29.790083	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1274	2026-05-15	15:42:27.624299	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1275	2026-05-15	15:53:12.937715	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1276	2026-05-15	15:56:42.86747	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1277	2026-05-15	15:57:57.535016	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1278	2026-05-15	16:12:07.497561	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1279	2026-05-15	16:31:18.563517	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1280	2026-05-15	16:38:17.898118	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1281	2026-05-15	18:44:20.351667	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1282	2026-05-15	18:46:34.611251	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1283	2026-05-15	18:48:22.26756	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1284	2026-05-15	18:50:00.81763	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO - DEPTO: PRODUCCION
1285	2026-05-15	19:00:33.401477	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1286	2026-05-15	19:06:21.862529	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1287	2026-05-15	19:07:43.152361	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO - DEPTO: PRODUCCION
1288	2026-05-15	19:41:56.867096	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO - DEPTO: PRODUCCION
1289	2026-05-16	18:33:06.589574	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1290	2026-05-16	18:35:14.41684	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1291	2026-05-19	11:39:04.351365	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1292	2026-05-19	11:39:29.79324	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO - DEPTO: PRODUCCION
1293	2026-05-19	13:52:21.473782	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1294	2026-05-19	14:05:41.80698	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO - DEPTO: PRODUCCION
1295	2026-05-19	15:07:44.719858	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1296	2026-05-19	15:11:33.311037	N/A	0	Cuauhtémoc Rivera Agundez	FALLO DE LOGIN
1297	2026-05-19	15:11:48.253444	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1298	2026-05-19	15:16:09.253622	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1299	2026-05-19	16:15:24.711732	N/A	0	Cuauhtémoc Rivera Agundez	FALLO DE LOGIN
1300	2026-05-19	16:15:42.136956	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1301	2026-05-19	16:50:14.70459	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1302	2026-05-19	16:50:46.824281	N/A	0	Cuauhtémoc Rivera Agundez	FALLO DE LOGIN
1303	2026-05-19	16:51:00.707723	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1304	2026-05-19	16:55:42.057342	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1305	2026-05-19	17:05:57.260443	N/A	999	ADMINISTRADOR	LOGIN EXITOSO
1306	2026-05-19	18:06:15.905801	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1307	2026-05-19	18:32:29.20148	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1308	2026-05-19	18:38:19.582929	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1309	2026-05-19	18:47:03.768414	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1310	2026-05-19	19:35:39.986421	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1311	2026-05-19	19:36:58.806614	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1312	2026-05-19	19:41:57.547442	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1313	2026-05-20	11:57:05.743228	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO - DEPTO: PRODUCCION
1314	2026-05-20	11:58:33.064967	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO - DEPTO: PRODUCCION
1315	2026-05-20	12:01:56.83478	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1316	2026-05-20	12:02:57.878874	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1317	2026-05-20	12:06:30.390798	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1318	2026-05-20	12:06:39.521856	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1319	2026-05-20	12:07:38.670087	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1320	2026-05-20	12:10:49.085911	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1321	2026-05-20	12:11:26.329923	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1322	2026-05-20	12:31:53.653327	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1323	2026-05-20	12:36:46.07697	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1324	2026-05-20	12:38:51.220771	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1325	2026-05-20	13:03:38.453362	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1326	2026-05-20	13:04:17.232521	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1327	2026-05-20	13:09:23.545489	N/A	0	Kiosco Bodega	FALLO DE LOGIN
1328	2026-05-20	13:09:32.024631	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1329	2026-05-20	13:10:56.247088	N/A	0	Kiosco Bodega	FALLO DE LOGIN
1330	2026-05-20	13:11:05.28929	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1331	2026-05-20	13:16:18.924606	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1332	2026-05-20	13:16:28.05636	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1333	2026-05-20	13:18:54.362218	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1334	2026-05-20	13:46:38.270142	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1335	2026-05-20	13:48:31.387414	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1336	2026-05-20	13:51:08.457538	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1337	2026-05-20	13:54:17.735193	N/A	0	Kiosco Bodega	FALLO DE LOGIN
1338	2026-05-20	13:54:27.825802	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1339	2026-05-20	13:55:52.237131	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1340	2026-05-20	14:01:50.909546	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1341	2026-05-20	14:07:57.754388	N/A	0	Kiosco Bodega	FALLO DE LOGIN
1342	2026-05-20	14:08:07.198178	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1343	2026-05-20	14:20:07.625842	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1344	2026-05-20	14:21:47.317469	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1345	2026-05-20	14:22:30.340857	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1346	2026-05-20	14:30:20.602963	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1347	2026-05-20	14:35:03.307495	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1348	2026-05-20	14:42:33.184841	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1349	2026-05-20	14:43:22.648292	N/A	529	Kiosco Bodega	LOGIN EXITOSO
1350	2026-05-20	14:44:34.748441	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1351	2026-05-20	14:51:58.022992	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1352	2026-05-20	15:05:55.628897	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1353	2026-05-20	17:10:17.304446	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1354	2026-05-20	17:31:18.367303	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1355	2026-05-20	17:42:22.81993	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1356	2026-05-20	18:02:59.904332	N/A	118	Héctor Rementeria de la Rocha	LOGIN EXITOSO
1357	2026-05-20	18:05:51.453673	N/A	529	Kiosco Bodega	LOGIN EXITOSO
1358	2026-05-20	18:07:09.087244	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1359	2026-05-20	18:07:52.359178	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1360	2026-05-20	18:08:22.067526	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1361	2026-05-20	18:11:58.599378	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1362	2026-05-20	18:16:28.130096	N/A	0	Kiosco Bodega	FALLO DE LOGIN
1363	2026-05-20	18:16:38.256545	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1364	2026-05-20	18:17:11.208215	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1365	2026-05-20	18:20:46.006259	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1366	2026-05-20	18:20:50.154018	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
1367	2026-05-20	18:22:54.84507	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1368	2026-05-20	18:27:18.130525	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1369	2026-05-20	18:35:38.944734	N/A	105	José Daniel Torres Arroyo	LOGIN EXITOSO
1370	2026-05-20	18:42:11.582667	N/A	109	Osiel Cuauhtémoc Hern├índez Aldape	LOGIN EXITOSO
1371	2026-05-20	19:12:13.050007	N/A	0	Kiosco Bodega	FALLO DE LOGIN
1372	2026-05-20	19:12:27.51512	N/A	529	Kiosco Bodega	LOGIN EXITOSO - DEPTO: KIOSKO
1373	2026-05-20	19:33:17.043044	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1374	2026-05-21	15:05:48.297445	N/A	529	Kiosco Bodega	LOGIN EXITOSO
1375	2026-05-21	18:06:33.100343	N/A	0	José Francisco Torres Sanchez	FALLO DE LOGIN
1376	2026-05-21	18:06:43.831708	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1377	2026-05-21	18:06:48.056888	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1378	2026-05-21	18:11:50.472789	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1379	2026-05-21	18:13:33.582364	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1380	2026-05-21	18:14:41.152798	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1381	2026-05-21	18:25:04.841236	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1382	2026-05-21	18:47:48.108571	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1383	2026-05-21	19:06:18.767734	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1384	2026-05-22	09:39:39.611353	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO - DEPTO: PRODUCCION
1385	2026-05-22	09:42:05.791284	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1386	2026-05-22	10:36:42.530629	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1387	2026-05-22	10:37:36.842446	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1388	2026-05-22	11:14:27.312069	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1389	2026-05-22	11:14:54.472233	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1390	2026-05-22	11:16:46.263545	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1391	2026-05-22	11:22:30.162826	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1392	2026-05-22	11:28:51.624193	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1393	2026-05-22	11:33:48.297689	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1394	2026-05-22	11:34:13.109163	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1395	2026-05-22	11:46:40.687692	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1396	2026-05-22	11:46:58.914719	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1397	2026-05-22	11:53:55.447965	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1398	2026-05-22	12:35:37.309125	N/A	0	Edgar Javier Amarillas	FALLO DE LOGIN
1399	2026-05-22	12:46:36.871262	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1400	2026-05-22	12:48:33.017891	N/A	0	Cuauhtémoc Rivera Agundez	FALLO DE LOGIN
1401	2026-05-22	12:48:43.337813	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1402	2026-05-23	12:07:09.770865	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1403	2026-05-23	13:01:57.634409	N/A	529	Kiosco Bodega	LOGIN EXITOSO
1404	2026-05-23	13:34:33.309345	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO - DEPTO: SISTEMAS
1405	2026-05-25	12:09:03.404553	N/A	104	José Francisco Torres Sanchez	LOGIN EXITOSO
1406	2026-05-25	12:24:39.858474	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1407	2026-05-26	10:33:00.467306	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1408	2026-05-26	11:00:53.558078	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1409	2026-05-26	11:06:43.604515	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1410	2026-05-26	11:15:42.17178	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1411	2026-05-26	11:19:30.453976	N/A	0	Cuauhtémoc Rivera Agundez	FALLO DE LOGIN
1412	2026-05-26	11:19:35.682433	N/A	201	Cuauhtémoc Rivera Agundez	LOGIN EXITOSO
1413	2026-05-26	13:41:45.235327	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1414	2026-05-26	13:43:53.716573	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1415	2026-05-26	13:46:14.227022	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1416	2026-05-26	13:46:54.078791	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1417	2026-05-26	14:08:15.473809	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1418	2026-05-26	14:10:30.237804	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1419	2026-05-26	14:18:39.607192	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1420	2026-05-26	14:18:57.109905	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1421	2026-05-26	14:19:14.304411	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1422	2026-05-26	14:23:19.157816	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1423	2026-05-26	17:16:14.787126	N/A	0	Martin Eduardo Sanchez Estrada	FALLO DE LOGIN
1424	2026-05-26	17:16:25.577897	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1425	2026-05-26	17:19:32.066917	N/A	0	Manuel Antonio Madrid Zazueta	FALLO DE LOGIN
1426	2026-05-26	17:19:44.942767	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1427	2026-05-26	17:22:09.137151	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1428	2026-05-26	17:25:30.996101	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1429	2026-05-26	17:27:35.790384	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1430	2026-05-26	17:38:56.873121	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1431	2026-05-26	17:39:22.410128	N/A	200	Andrea Maria Vilarreal Lopez	LOGIN EXITOSO
1432	2026-05-26	17:43:18.7797	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1433	2026-05-26	17:56:57.302213	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1434	2026-05-26	18:11:29.316456	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1435	2026-05-26	18:14:34.777752	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1436	2026-05-26	18:19:32.116211	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1437	2026-05-26	19:04:49.909746	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1438	2026-05-26	19:10:32.891209	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1439	2026-05-26	19:34:50.208187	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1440	2026-05-26	19:39:26.837236	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1441	2026-05-27	10:25:21.273582	N/A	0	Manuel Antonio Madrid Zazueta	FALLO DE LOGIN
1442	2026-05-27	10:25:42.66514	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1443	2026-05-27	11:07:45.984034	N/A	200	Andrea Maria Vilarreal Lopez	LOGIN EXITOSO
1444	2026-05-27	11:47:46.248896	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1445	2026-05-27	12:52:11.703475	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1446	2026-05-27	13:19:25.616321	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1447	2026-05-27	14:12:47.048858	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1448	2026-05-27	17:37:50.662279	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1449	2026-05-27	18:25:49.951244	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1450	2026-05-27	18:39:20.176921	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1451	2026-06-05	13:48:02.571628	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1452	2026-06-05	13:53:23.314486	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1453	2026-06-05	16:12:57.508285	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1454	2026-06-05	16:21:25.452912	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1455	2026-06-05	16:22:56.224731	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1456	2026-06-05	16:23:55.287595	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1457	2026-06-05	16:24:19.43077	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1458	2026-06-05	16:24:33.37667	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1459	2026-06-05	16:26:36.068319	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1460	2026-06-05	16:26:46.113422	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1461	2026-06-05	16:32:33.079182	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1462	2026-06-05	16:46:15.848526	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1463	2026-06-05	16:46:48.83924	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1464	2026-06-05	16:48:13.87117	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1465	2026-06-05	16:52:39.83483	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1466	2026-06-05	17:13:05.223705	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1467	2026-06-05	17:14:59.136935	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1468	2026-06-05	17:25:27.739871	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1469	2026-06-05	17:25:46.062584	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1470	2026-06-05	17:26:56.866448	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1471	2026-06-05	17:32:55.246369	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1472	2026-06-05	17:34:56.376903	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1473	2026-06-05	17:36:48.649795	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1474	2026-06-05	17:43:57.986705	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1475	2026-06-05	18:01:44.43307	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1476	2026-06-05	18:03:51.384362	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1477	2026-06-05	18:07:48.009074	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1478	2026-06-05	18:08:48.64381	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1479	2026-06-05	18:14:12.677874	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1480	2026-06-05	18:20:41.43925	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1481	2026-06-05	18:37:49.347631	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1482	2026-06-05	18:48:27.099771	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1483	2026-06-05	18:51:44.97799	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1484	2026-06-05	18:54:19.284704	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1485	2026-06-05	18:57:06.409559	N/A	0	Jose Daniel Torres Arroyo	FALLO DE LOGIN
1486	2026-06-05	18:57:12.596977	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1487	2026-06-05	18:58:19.637196	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1488	2026-06-06	09:35:06.079663	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1489	2026-06-06	11:10:47.07472	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1490	2026-06-06	11:23:15.772646	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1491	2026-06-08	10:00:41.161157	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1492	2026-06-08	13:16:53.659037	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1493	2026-06-10	16:44:18.933081	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1494	2026-06-10	16:48:23.914625	N/A	200	Andrea Maria Vilarreal Lopez	LOGIN EXITOSO
1495	2026-06-10	17:56:19.234688	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
1496	2026-06-10	17:58:04.015326	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
1497	2026-06-10	17:58:43.758848	N/A	0	Andrea Maria Vilarreal Lopez	FALLO DE LOGIN
1498	2026-06-10	17:58:52.382612	N/A	0	Andrea Maria Vilarreal Lopez	FALLO DE LOGIN
1499	2026-06-10	17:59:02.687396	N/A	0	Andrea Maria Vilarreal Lopez	FALLO DE LOGIN
1500	2026-06-10	17:59:54.847627	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1501	2026-06-10	18:00:23.412095	N/A	0	Edgar Javier Amarillas	FALLO DE LOGIN
1502	2026-06-10	18:00:34.332357	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1503	2026-06-10	18:01:07.125195	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1504	2026-06-10	18:01:35.068128	N/A	104	Jose Francisco Torres Sanchez	LOGIN EXITOSO
1505	2026-06-11	10:00:26.250619	N/A	0	Jose Daniel Torres Arroyo	FALLO DE LOGIN
1506	2026-06-11	10:00:34.851581	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1507	2026-06-11	16:10:04.360437	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1508	2026-06-11	16:16:11.208624	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1509	2026-06-11	16:28:04.63282	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1510	2026-06-11	16:28:47.794093	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1511	2026-06-11	16:28:55.080932	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1512	2026-06-12	10:50:45.157775	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1513	2026-06-12	11:10:11.544522	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1514	2026-06-12	11:51:11.323493	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1515	2026-06-12	11:51:23.374804	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1516	2026-06-12	11:54:53.476572	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1517	2026-06-13	11:43:24.497644	N/A	121	Sofia Alejandra Villarreal Lopez	LOGIN EXITOSO
1518	2026-06-13	12:35:10.413758	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1519	2026-06-15	09:09:30.808171	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1520	2026-06-15	15:29:32.970356	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1521	2026-06-18	18:54:21.515276	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1522	2026-06-19	09:01:39.519595	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1523	2026-06-19	10:54:01.244419	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1524	2026-06-19	10:54:08.871288	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1525	2026-06-20	09:36:43.453845	N/A	104	Jose Francisco Torres Sanchez	LOGIN EXITOSO
1526	2026-06-20	09:49:45.970781	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1527	2026-06-20	10:08:02.357179	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1528	2026-06-20	10:27:25.782657	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1529	2026-06-20	10:30:16.942867	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1530	2026-06-20	11:16:01.584492	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1531	2026-06-20	11:19:50.945639	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1532	2026-06-20	11:20:22.738689	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1533	2026-06-20	11:25:05.3676	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1534	2026-06-20	11:27:04.452257	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1535	2026-06-20	11:35:16.252931	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1536	2026-06-20	12:43:44.789817	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1537	2026-06-23	09:21:38.462906	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1538	2026-06-23	09:45:38.367677	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1539	2026-06-23	10:44:27.146421	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1540	2026-06-23	18:42:15.734266	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1541	2026-06-23	18:44:39.230231	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1542	2026-06-24	10:48:37.550352	N/A	104	Jose Francisco Torres Sanchez	LOGIN EXITOSO
1543	2026-06-24	11:08:22.243984	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1544	2026-06-24	11:16:24.569249	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1545	2026-06-24	17:26:17.074257	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1546	2026-06-25	09:27:26.853243	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1547	2026-06-25	09:29:06.136243	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1548	2026-06-25	09:42:01.553578	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1549	2026-06-25	09:44:12.624526	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1550	2026-06-25	09:44:56.936004	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1551	2026-06-25	13:21:56.342638	N/A	0	Jose Daniel Torres Arroyo	FALLO DE LOGIN
1552	2026-06-25	13:22:06.868411	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1553	2026-06-25	13:23:36.04971	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1554	2026-06-25	18:32:19.917658	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1555	2026-06-25	18:36:48.998595	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1556	2026-06-25	18:36:55.351576	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1557	2026-06-27	11:08:30.544491	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1558	2026-06-27	11:09:43.643872	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1559	2026-06-27	11:10:33.967008	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1560	2026-06-27	11:29:42.147055	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1561	2026-06-27	11:30:28.237187	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1562	2026-06-27	11:31:21.507416	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1563	2026-06-27	11:38:28.211192	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1564	2026-06-29	12:17:12.786888	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1565	2026-06-29	15:17:38.054648	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1566	2026-06-29	15:21:47.727236	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1567	2026-06-29	17:18:29.525739	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1568	2026-06-29	18:43:32.814335	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1569	2026-06-29	18:44:44.351622	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1570	2026-06-29	18:48:40.168077	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1571	2026-06-30	09:06:08.208808	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1572	2026-06-30	10:10:58.16359	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1573	2026-06-30	10:16:03.922141	N/A	0	Manuel Antonio Madrid Zazueta	FALLO DE LOGIN
1574	2026-06-30	10:16:15.057557	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1575	2026-06-30	10:29:44.767952	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1576	2026-07-01	10:36:58.664423	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1577	2026-07-01	11:35:17.674287	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1578	2026-07-01	11:35:45.272337	N/A	0	Cuauhtemoc Rivera Agundez	FALLO DE LOGIN
1579	2026-07-01	11:35:51.473575	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1580	2026-07-01	11:40:05.465138	N/A	0	Cuauhtemoc Rivera Agundez	FALLO DE LOGIN
1581	2026-07-01	11:40:17.693798	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1582	2026-07-01	11:40:56.556922	N/A	125	Diego Villareal Lopez	LOGIN EXITOSO
1583	2026-07-01	11:41:33.510716	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1584	2026-07-01	11:43:07.590748	N/A	125	Diego Villareal Lopez	LOGIN EXITOSO
1585	2026-07-01	11:48:12.790222	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1586	2026-07-01	11:48:19.272364	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1587	2026-07-01	11:52:36.496304	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1588	2026-07-01	11:57:23.04911	N/A	125	Diego Villareal Lopez	LOGIN EXITOSO
1589	2026-07-01	11:59:18.824856	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1590	2026-07-01	11:59:25.757206	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1591	2026-07-01	11:59:40.909787	N/A	0	Edgar Javier Amarillas	FALLO DE LOGIN
1592	2026-07-01	11:59:54.885839	N/A	0	Edgar Javier Amarillas	FALLO DE LOGIN
1593	2026-07-01	12:00:03.286446	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1594	2026-07-01	12:04:58.498719	N/A	125	Diego Villareal Lopez	LOGIN EXITOSO
1595	2026-07-01	12:05:57.103014	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1596	2026-07-01	12:09:21.580417	N/A	125	Diego Villareal Lopez	LOGIN EXITOSO
1597	2026-07-01	16:16:20.580991	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1598	2026-07-01	17:46:01.411156	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1599	2026-07-02	09:14:59.953334	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1600	2026-07-02	09:24:39.656404	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1601	2026-07-02	09:27:39.553142	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1602	2026-07-02	09:28:06.83425	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1603	2026-07-02	09:28:25.688386	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1604	2026-07-02	09:28:58.393864	N/A	0	Martin Eduardo Sanchez Estrada	FALLO DE LOGIN
1605	2026-07-02	09:29:05.494092	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1606	2026-07-02	10:35:50.182543	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1607	2026-07-02	10:36:13.056637	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1608	2026-07-02	10:41:31.094479	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1609	2026-07-02	10:49:01.17877	N/A	104	Jose Francisco Torres Sanchez	LOGIN EXITOSO
1610	2026-07-02	11:26:01.686601	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1611	2026-07-02	11:27:54.082103	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1612	2026-07-02	11:35:15.075671	N/A	0	Manuel Antonio Madrid Zazueta	FALLO DE LOGIN
1613	2026-07-02	11:35:20.463258	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1614	2026-07-02	11:42:24.349245	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1615	2026-07-02	11:43:52.572381	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1616	2026-07-02	11:48:12.902249	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1617	2026-07-02	13:00:50.61503	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1618	2026-07-02	13:05:17.26542	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1619	2026-07-02	13:11:10.505872	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1620	2026-07-02	13:13:42.864173	N/A	104	Jose Francisco Torres Sanchez	LOGIN EXITOSO
1621	2026-07-02	13:16:04.103509	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1622	2026-07-02	13:18:34.443991	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1623	2026-07-02	13:19:44.767548	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1624	2026-07-02	13:21:19.468219	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1625	2026-07-02	13:27:13.304676	N/A	0	Jose Daniel Torres Arroyo	FALLO DE LOGIN
1626	2026-07-02	13:27:19.949597	N/A	0	Jose Daniel Torres Arroyo	FALLO DE LOGIN
1627	2026-07-02	13:27:26.570242	N/A	104	Jose Francisco Torres Sanchez	LOGIN EXITOSO
1628	2026-07-02	13:27:43.800184	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1629	2026-07-02	13:31:59.645999	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1630	2026-07-02	13:38:20.959353	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1631	2026-07-02	16:40:01.244139	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1632	2026-07-02	16:40:38.31596	N/A	0	Edgar Javier Amarillas	FALLO DE LOGIN
1633	2026-07-02	16:40:51.721911	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1634	2026-07-02	16:47:06.546999	N/A	0	Martin Eduardo Sanchez Estrada	FALLO DE LOGIN
1635	2026-07-02	16:48:06.820901	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1636	2026-07-02	17:12:59.403055	N/A	0	Martin Eduardo Sanchez Estrada	FALLO DE LOGIN
1637	2026-07-02	17:13:46.813105	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1638	2026-07-02	17:17:28.590489	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1639	2026-07-02	17:18:21.994579	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1640	2026-07-02	17:20:00.27951	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1641	2026-07-02	17:46:38.12402	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1642	2026-07-02	17:59:07.744191	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1643	2026-07-03	09:36:28.428343	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1644	2026-07-03	12:08:53.6511	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1645	2026-07-03	12:11:30.158053	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1646	2026-07-03	12:42:10.256163	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1647	2026-07-03	13:37:12.868901	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1648	2026-07-03	16:56:18.039001	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1649	2026-07-03	17:02:38.201726	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1650	2026-07-03	17:09:07.478155	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1651	2026-07-03	17:09:56.426889	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1652	2026-07-03	17:48:44.038834	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1653	2026-07-03	17:52:48.127171	N/A	0	Jose Daniel Torres Arroyo	FALLO DE LOGIN
1654	2026-07-03	17:52:59.284168	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1655	2026-07-03	17:58:46.152308	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1656	2026-07-03	18:00:16.04832	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1657	2026-07-03	18:00:53.049587	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1658	2026-07-03	18:03:02.193154	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1659	2026-07-03	18:13:35.412577	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1660	2026-07-03	18:17:38.680555	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1661	2026-07-03	18:19:48.606707	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1662	2026-07-03	18:22:03.004169	N/A	0	Carlos Jacobo Quezada Mendoza	FALLO DE LOGIN
1663	2026-07-03	18:22:08.656525	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1664	2026-07-03	18:29:19.656149	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1665	2026-07-03	18:30:02.118256	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1666	2026-07-03	18:36:28.487363	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1667	2026-07-03	18:38:50.73537	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1668	2026-07-03	18:54:24.175831	N/A	0	Osiel Cuauhtemoc Hernandez Aldape	FALLO DE LOGIN
1669	2026-07-03	18:54:38.521453	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1670	2026-07-04	10:47:20.667064	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1671	2026-07-04	11:22:48.083715	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1672	2026-07-06	08:56:48.422627	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1673	2026-07-06	09:03:30.461914	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1674	2026-07-06	09:03:46.575736	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1675	2026-07-06	09:04:20.926612	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1676	2026-07-06	10:27:46.257497	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1677	2026-07-06	11:31:12.760624	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1678	2026-07-06	12:06:40.368803	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1679	2026-07-06	12:09:18.860528	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1680	2026-07-06	12:09:27.414444	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1681	2026-07-06	12:12:14.911046	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1682	2026-07-06	12:14:49.114558	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1683	2026-07-06	12:14:59.107651	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1684	2026-07-06	12:17:26.906181	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1685	2026-07-06	12:47:25.112253	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1686	2026-07-06	12:49:09.9019	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1687	2026-07-06	12:49:13.042785	N/A	0	Gerardo Villarreal Uribe	FALLO DE LOGIN
1688	2026-07-06	12:49:38.905795	N/A	102	Gerardo Villarreal Uribe	LOGIN EXITOSO
1689	2026-07-06	12:50:11.648599	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1690	2026-07-06	12:51:34.610592	N/A	0	Gerardo Villarreal Uribe	FALLO DE LOGIN
1691	2026-07-06	12:51:38.050365	N/A	102	Gerardo Villarreal Uribe	LOGIN EXITOSO
1692	2026-07-06	12:52:01.893799	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1693	2026-07-06	13:00:26.004335	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1694	2026-07-06	13:04:04.111029	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1695	2026-07-06	13:04:09.806978	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1696	2026-07-06	13:09:53.874232	N/A	0	Carlos Jacobo Quezada Mendoza	FALLO DE LOGIN
1697	2026-07-06	16:12:52.019306	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1698	2026-07-06	16:58:06.891509	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1699	2026-07-06	16:58:14.195447	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1700	2026-07-06	16:58:51.802525	N/A	0	Osiel Cuauhtemoc Hernandez Aldape	FALLO DE LOGIN
1701	2026-07-06	16:58:59.109239	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1702	2026-07-06	18:27:10.08536	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1703	2026-07-06	18:55:13.099656	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1704	2026-07-07	09:25:34.780811	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1705	2026-07-07	12:09:03.374219	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1706	2026-07-07	16:06:10.297422	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1707	2026-07-07	16:06:15.866521	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1708	2026-07-07	16:06:47.275639	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1709	2026-07-07	16:48:27.23289	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1710	2026-07-07	16:55:08.349599	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1711	2026-07-07	16:56:01.640419	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1712	2026-07-07	16:56:46.531094	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1713	2026-07-07	16:57:09.76564	N/A	102	Gerardo Villarreal Uribe	LOGIN EXITOSO
1714	2026-07-07	16:57:36.766566	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1715	2026-07-07	17:35:14.333327	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1716	2026-07-07	17:39:51.825578	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1717	2026-07-07	17:45:01.377179	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1718	2026-07-07	17:48:49.532976	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1719	2026-07-07	17:51:39.228303	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1720	2026-07-07	17:54:46.900345	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1721	2026-07-07	17:56:00.670358	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1722	2026-07-07	17:56:12.795202	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1723	2026-07-07	17:57:37.826784	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1724	2026-07-07	17:58:06.461858	N/A	102	Gerardo Villarreal Uribe	LOGIN EXITOSO
1725	2026-07-07	17:59:05.744498	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1726	2026-07-07	17:59:45.953389	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1727	2026-07-07	18:00:31.424905	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1728	2026-07-07	18:01:36.230283	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1729	2026-07-07	18:03:21.046699	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1730	2026-07-08	09:10:34.491411	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1731	2026-07-08	09:10:58.144452	N/A	102	Gerardo Villarreal Uribe	LOGIN EXITOSO
1732	2026-07-08	09:11:45.799358	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1733	2026-07-08	09:13:13.499033	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1734	2026-07-08	09:17:16.651045	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1735	2026-07-08	16:01:47.83883	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1736	2026-07-08	16:16:47.135458	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1737	2026-07-08	17:36:11.378844	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1738	2026-07-08	18:02:24.07168	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1739	2026-07-08	18:02:30.455268	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1740	2026-07-08	18:03:06.602125	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1741	2026-07-08	18:03:35.785898	N/A	0	Jose Daniel Torres Arroyo	FALLO DE LOGIN
1742	2026-07-08	18:03:40.966886	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1743	2026-07-08	18:04:05.043612	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1744	2026-07-08	18:04:29.056989	N/A	0	Gerardo Villarreal Uribe	FALLO DE LOGIN
1745	2026-07-08	18:04:34.936931	N/A	102	Gerardo Villarreal Uribe	LOGIN EXITOSO
1746	2026-07-08	18:05:08.175077	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1747	2026-07-08	18:05:23.532747	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1748	2026-07-08	18:05:56.223425	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1749	2026-07-08	18:06:22.525967	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1750	2026-07-08	18:07:09.208058	N/A	102	Gerardo Villarreal Uribe	LOGIN EXITOSO
1751	2026-07-08	18:07:38.884645	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1752	2026-07-08	18:07:43.058046	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1753	2026-07-08	18:08:20.859244	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1754	2026-07-09	09:36:23.502888	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1755	2026-07-09	09:36:52.185651	N/A	0	Jose Daniel Torres Arroyo	FALLO DE LOGIN
1756	2026-07-09	09:36:57.28645	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1757	2026-07-09	09:39:41.418423	N/A	102	Gerardo Villarreal Uribe	LOGIN EXITOSO
1758	2026-07-09	09:40:37.891614	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1759	2026-07-09	09:40:56.11339	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1760	2026-07-09	09:42:14.549844	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1761	2026-07-09	11:01:53.663786	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1762	2026-07-09	11:05:48.380759	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1763	2026-07-09	11:06:40.194566	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1764	2026-07-09	11:06:44.929342	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1765	2026-07-09	16:08:24.322527	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1766	2026-07-09	16:08:33.201179	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1767	2026-07-09	16:21:08.42205	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1768	2026-07-09	16:27:34.907767	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1769	2026-07-09	16:29:52.540177	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1770	2026-07-09	16:43:35.37657	N/A	101	Ana Lilia Villarreal Uribe	LOGIN EXITOSO
1771	2026-07-09	16:46:27.766014	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1772	2026-07-09	16:49:49.086784	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1773	2026-07-09	16:50:19.833316	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1774	2026-07-09	16:51:22.991855	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1775	2026-07-09	16:51:51.948324	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1776	2026-07-09	16:51:57.196013	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1777	2026-07-09	16:52:03.024619	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1778	2026-07-09	16:52:13.306228	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1779	2026-07-10	09:38:41.828579	N/A	102	Gerardo Villarreal Uribe	LOGIN EXITOSO
1780	2026-07-10	11:42:14.110626	N/A	0	Jose Daniel Torres Arroyo	FALLO DE LOGIN
1781	2026-07-10	11:42:29.85075	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1782	2026-07-10	11:44:07.883126	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1783	2026-07-10	16:21:24.097867	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1784	2026-07-10	16:22:34.459814	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1785	2026-07-10	16:28:25.360813	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1786	2026-07-10	18:11:22.629951	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1787	2026-07-10	18:14:08.50501	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1788	2026-07-11	10:51:33.798582	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1789	2026-07-13	09:39:33.890548	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1790	2026-07-13	09:49:25.796384	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1791	2026-07-13	09:57:14.127545	N/A	104	Jose Francisco Torres Sanchez	LOGIN EXITOSO
1792	2026-07-13	09:57:57.490425	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1793	2026-07-13	12:44:44.581369	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1794	2026-07-14	09:31:48.049278	N/A	0	Ana Lilia Villarreal Uribe	FALLO DE LOGIN
1795	2026-07-14	09:31:53.298003	N/A	0	Ana Lilia Villarreal Uribe	FALLO DE LOGIN
1796	2026-07-14	09:32:03.315513	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1797	2026-07-14	11:06:34.082668	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1798	2026-07-14	11:07:11.229928	N/A	203	Pedro Villarreal Uribe	LOGIN EXITOSO
1799	2026-07-14	11:18:31.133626	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1800	2026-07-15	09:20:53.325383	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1801	2026-07-15	09:29:42.464497	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1802	2026-07-15	09:46:50.468922	N/A	0	Manuel Eduardo Madrid	FALLO DE LOGIN
1803	2026-07-15	09:46:55.778817	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1804	2026-07-15	10:44:23.562494	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1805	2026-07-15	11:11:30.553619	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1806	2026-07-15	12:56:03.005468	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1807	2026-07-15	15:40:49.333264	N/A	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN EXITOSO
1808	2026-07-16	09:06:33.478009	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1809	2026-07-16	10:16:13.306325	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1810	2026-07-16	10:34:53.6764	N/A	0	Martin Eduardo Sanchez Estrada	FALLO DE LOGIN
1811	2026-07-16	10:34:54.314885	N/A	0	Martin Eduardo Sanchez Estrada	FALLO DE LOGIN
1812	2026-07-16	10:34:54.459394	N/A	0	Martin Eduardo Sanchez Estrada	FALLO DE LOGIN
1813	2026-07-16	12:31:21.082226	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1814	2026-07-16	12:36:46.831706	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1815	2026-07-16	17:04:14.121648	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1816	2026-07-16	18:36:49.37179	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1817	2026-07-17	13:03:54.164916	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1818	2026-07-18	09:28:20.469213	N/A	119	Manuel Antonio Madrid Zazueta	LOGIN EXITOSO
1819	2026-07-18	09:42:52.36424	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1820	2026-07-18	09:43:42.414361	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1821	2026-07-18	09:45:18.603781	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1822	2026-07-18	10:07:34.452136	N/A	202	Edgar Javier Amarillas	LOGIN EXITOSO
1823	2026-07-18	10:14:13.816095	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1824	2026-07-18	10:14:46.01836	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1825	2026-07-18	10:15:40.398321	N/A	113	Carlos Jacobo Quezada Mendoza	LOGIN EXITOSO
1826	2026-07-18	10:39:37.784612	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1827	2026-07-18	11:01:43.361341	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1828	2026-07-18	11:49:11.682247	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1829	2026-07-20	04:56:28.604612	N/A	105	Jose Daniel Torres Arroyo	LOGIN EXITOSO
1830	2026-07-20	12:45:15.874906	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1831	2026-07-20	16:17:02.424303	N/A	107	Martin Eduardo Sanchez Estrada	LOGIN EXITOSO
1832	2026-07-20	18:57:16.401637	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1833	2026-07-20	18:57:39.866649	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1834	2026-07-20	18:59:04.776936	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1835	2026-07-21	16:35:36.742073	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1836	2026-07-21	16:46:34.663507	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1837	2026-07-21	17:15:57.92697	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1838	2026-07-21	18:03:25.73704	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1839	2026-07-21	18:06:48.045813	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1840	2026-07-21	18:09:16.469778	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1841	2026-07-21	18:11:41.432053	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1842	2026-07-21	18:14:40.113433	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
1843	2026-07-21	18:17:56.595969	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1844	2026-07-21	18:19:02.271272	N/A	201	Cuauhtemoc Rivera Agundez	LOGIN EXITOSO
1845	2026-07-21	18:19:17.911974	N/A	124	Manuel Eduardo Madrid	LOGIN EXITOSO
\.


--
-- Name: asistencia_eventos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.asistencia_eventos_id_seq', 1, false);


--
-- Name: control_asistencia_id_registro_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.control_asistencia_id_registro_seq', 202, true);


--
-- Name: departamentos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.departamentos_id_seq', 5, true);


--
-- Name: log_accesos_id_log_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_accesos_id_log_seq', 1845, true);


--
-- Name: asistencia_eventos asistencia_eventos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asistencia_eventos
    ADD CONSTRAINT asistencia_eventos_pkey PRIMARY KEY (id);


--
-- Name: control_asistencia control_asistencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.control_asistencia
    ADD CONSTRAINT control_asistencia_pkey PRIMARY KEY (id_registro);


--
-- Name: departamentos departamentos_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_nombre_key UNIQUE (nombre);


--
-- Name: departamentos departamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_pkey PRIMARY KEY (id);


--
-- Name: log_accesos log_accesos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_accesos
    ADD CONSTRAINT log_accesos_pkey PRIMARY KEY (id_log);


--
-- Name: control_asistencia uq_empleado_fecha; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.control_asistencia
    ADD CONSTRAINT uq_empleado_fecha UNIQUE (id_empleado, fecha);


--
-- Name: empleados vpro_pkey; Type: CONSTRAINT; Schema: public; Owner: vpro_dbadmin
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT vpro_pkey PRIMARY KEY (id_empleado);


--
-- Name: control_asistencia fk_empleado; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.control_asistencia
    ADD CONSTRAINT fk_empleado FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO vpro_dbadmin;


--
-- Name: TABLE asistencia_eventos; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.asistencia_eventos TO vpro_dbadmin;


--
-- Name: SEQUENCE asistencia_eventos_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.asistencia_eventos_id_seq TO vpro_dbadmin;


--
-- Name: TABLE control_asistencia; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.control_asistencia TO vpro_dbadmin;


--
-- Name: SEQUENCE control_asistencia_id_registro_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.control_asistencia_id_registro_seq TO vpro_dbadmin;


--
-- Name: TABLE departamentos; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.departamentos TO vpro_dbadmin;


--
-- Name: SEQUENCE departamentos_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.departamentos_id_seq TO vpro_dbadmin;


--
-- Name: TABLE log_accesos; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.log_accesos TO vpro_dbadmin;


--
-- Name: SEQUENCE log_accesos_id_log_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.log_accesos_id_log_seq TO vpro_dbadmin;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO vpro_dbadmin;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO vpro_dbadmin;


--
-- PostgreSQL database dump complete
--

\unrestrict XcQeh3pF7nXbrfZWNYBIXySgdYl7fYbdzOG91RlVzu6TD0UdbXic3QmGb7DvOvr

