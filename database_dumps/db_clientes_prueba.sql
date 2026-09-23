--
-- PostgreSQL database dump
--

\restrict zKb9w7p5G9MTMdBEEoGkEqAwN6RpRPOIgkGNhgMgROyi44POTvKfOsw43vaTdrh

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
-- Name: clientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clientes (
    cliente_empresa text,
    gte_gral text,
    estado text,
    ciudad text,
    tel_de_ofna text,
    email_de_empresa text,
    nombre_contacto_princ text,
    cel_contact_princ character varying(15),
    nombre_contacto_a text,
    cel_contact_a character varying(15),
    id_cliente integer NOT NULL
);


ALTER TABLE public.clientes OWNER TO postgres;

--
-- Name: clientes_id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.clientes_id_cliente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.clientes_id_cliente_seq OWNER TO postgres;

--
-- Name: clientes_id_cliente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clientes_id_cliente_seq OWNED BY public.clientes.id_cliente;


--
-- Name: clientes id_cliente; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes ALTER COLUMN id_cliente SET DEFAULT nextval('public.clientes_id_cliente_seq'::regclass);


--
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clientes (cliente_empresa, gte_gral, estado, ciudad, tel_de_ofna, email_de_empresa, nombre_contacto_princ, cel_contact_princ, nombre_contacto_a, cel_contact_a, id_cliente) FROM stdin;
VPRO	Pedro Villarreal	\N	\N	\N	\N	\N	\N	\N	\N	28
IEES	Nomeacuerdo	33333333	Culiacan	33333333	Iees_nolose@nolose.com	Crmen	44444444	NoloseIees	55555555	17
ISDE	Tito	Sinaloa	Culiacan	0000000000	isdenolose@nolose.com	Tito	111111111	NoloseIsde	222222222	16
CIBACOPA	OMAR VILLANUEVA	GUADALAJARA	GUADALAJARA	1234567890	notienecibacopa@notiene.com	OMAR VILLANUEVA	0987654321	Seg contac no registrado	123456789-0	25
Coppel	Nose	Sinaloa	Culaican	11111	nosabemos.com	coppel	444444	niideaaa	111111	31
agua milller	aguadir	sinaloa	culiacan	1234567890	agua@agua.com	agua cocntact1	2345678901	noloseagu	3456789123	22
Casa ley	Nolose	Sinaloa	Culiacan	4444444444	nolose@nolose.com	nolose	5555555555	Nolose	6666666666	14
GRUPO SACSA	Nolose	Sinaloa	navolato	5555555555	gruposacsa.sacsa.com	nolose	6666666666	Tampocolose	7777777777	15
ELEVOX	nose	Sinaloa	Culiacan	11111111	nose@no.com	nose	11111122	nose	1111111	29
Agricola del Campo	Nose	mexico	aguascalientes	111111	niidea@.com	ni idea	333333	no se 	222222	30
ISJU	Nolose	Sinaloa	Culiacan	888888888	ISJU@NOLOSE	no lose	9999999	tampose	9999999	26
GRUPO PARLAMENTARIO MORENA	Nolose	sINALOA	Culiacan	55555	GNOLOSE@	NO LOSE	555555	NOLOSE	77777	27
DIF Sinaloa	Nomeacuerdo	6666666	Culiacan	7777777	Difnolose@nolose.com	DifNolose	8888888	Difnolose	9999999	18
GOBIERNO FEDERAL	GFNolose	000000	CDMX	111111	GFnolose@nolose.com	GFNolose	222222	GFNolose	333333	19
GOBIERNO DEL ESTADO DE SINALOA	Eleazar(PapiRINGO)	Sinaloa	Culiacan	22222222222	nolose@nolose.com	Papi	3333333333	Angel	6674602906	13
CESAVESIN										32
COCA - COLA	ACTUALIZAR Please elnombr del Gte. Gral.	Sinaloa	Culiacan	000000000	ccolanolose@ccola	Eunice Hernandez	222222222	Alma D. Carrillo López	333333333	21
H.AYUNTAMIENTO DE BADIRAGUATO		SINALOA	Badiraguato							33
JAPAC										34
\.


--
-- Name: clientes_id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clientes_id_cliente_seq', 25, true);


--
-- Name: clientes cliente_empresa_unico; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT cliente_empresa_unico UNIQUE (cliente_empresa);


--
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id_cliente);


--
-- PostgreSQL database dump complete
--

\unrestrict zKb9w7p5G9MTMdBEEoGkEqAwN6RpRPOIgkGNhgMgROyi44POTvKfOsw43vaTdrh

