--
-- PostgreSQL database dump
--

\restrict aRlTaTXbf85dSFuPEQWayItRAHXIGrgR6OWGp0rLv5twRvtdbkt5P4jHLv4dteR

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
-- Name: proveedores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proveedores (
    nombre_del_proveedor character varying(50) NOT NULL,
    gte_gral character varying(40),
    estado character varying(20),
    ciudad character varying(30),
    tel_de_ofna character varying(15),
    email_de_empresa character varying(50),
    nombre_contacto_princ character varying(40),
    cel_contact_princ character varying(15),
    nombre_contacto_a character varying(40),
    cel_contact_a character varying(15)
);


ALTER TABLE public.proveedores OWNER TO postgres;

--
-- Data for Name: proveedores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.proveedores (nombre_del_proveedor, gte_gral, estado, ciudad, tel_de_ofna, email_de_empresa, nombre_contacto_princ, cel_contact_princ, nombre_contacto_a, cel_contact_a) FROM stdin;
EVENMEX	EvenMex	Sinaloa	Culiacan	6674567890	EVENM@evemex.com	EVENMExP	66756789012	EVENMEXA	6676789012
METRO	M	ME	MEt	4444123456	METRO@metro.com	METR_P	5555756670	ME_Al	6666789012
SERVIPLUS-KUWA	Ponchote	Sinaloa	Culiacan	6677890123	SERVIP@servip.com	SERVIPL_P	6678901234	SERVIPLUS	6679012345
VIEWHAUS SISTEMAS  - XXX	VIEWHAUS SISTEMA	VIEWHAUS SISTEM	VIEWHAUS SISTE	8899012345	VIEWHAUS SIS	VIEWHAUS SI	8890123456	VIEWHAUS	7788990011
ELEVOX	Eleazar	Sinaloa	Culiacan	6671234567	elevox@elevox.com	Minion	66723467890	Juanito	6673456789
\.


--
-- Name: proveedores proveedores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_pkey PRIMARY KEY (nombre_del_proveedor);


--
-- PostgreSQL database dump complete
--

\unrestrict aRlTaTXbf85dSFuPEQWayItRAHXIGrgR6OWGp0rLv5twRvtdbkt5P4jHLv4dteR

