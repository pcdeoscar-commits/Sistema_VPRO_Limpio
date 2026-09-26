--
-- PostgreSQL database dump
--

\restrict ezcvPBc0VZneFOYRd07htDc7WGCxihwQNnDeNSTT5l8aEM0R4FjCPZwK8tMTZO9

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

ALTER TABLE IF EXISTS ONLY public.autos DROP CONSTRAINT IF EXISTS autos_pkey;
DROP TABLE IF EXISTS public.autos;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: autos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.autos (
    num_control character varying(15) NOT NULL,
    marca character varying(20),
    modelo character varying(20),
    serie character varying(20),
    fecha_compra date,
    estado_actual character varying(50),
    servicios_hechos character varying(200),
    observaciones_comentarios character varying(200),
    seguro_vence date,
    mantenimiento_fecha date
);


ALTER TABLE public.autos OWNER TO postgres;

--
-- Data for Name: autos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.autos (num_control, marca, modelo, serie, fecha_compra, estado_actual, servicios_hechos, observaciones_comentarios, seguro_vence, mantenimiento_fecha) FROM stdin;
VPFord	Ford	1996	Vans	2019-10-11	SE APAGA A VECES	Revision General de motor / Encendido	Como decia se apaga a veces	2026-01-05	2025-01-05
VPH100	Hyundai	2015	Tenis vans	2021-03-15	EXCELENTE	rutinasrios	ok	2026-05-14	2025-06-10
VPMercedes	Mercedes Benz	2021	Vans	2021-02-14	E C	Rutinarios	Todo Ok.	2026-01-10	2025-02-06
VPTiida02	Nissan #02	2013	perronciooooo	2018-12-12	Excelentes condiciones	Se le reparo la transmision	Ya no presenta problemas de transmision	2026-02-11	2025-03-07
VPTiida04	Nissan #04	2013	perronciaaaaa	2017-01-13	Excelentes condiciones	Se le reviso la  pero no se presento problema de transmision	Todo ok	2026-03-12	2025-04-08
VPToyota	Toyota	Hilux	Camionetona	2020-02-14	le truena la primera	Rutinarios	todo okay	2026-04-13	2025-05-09
\.


--
-- Name: autos autos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.autos
    ADD CONSTRAINT autos_pkey PRIMARY KEY (num_control);


--
-- PostgreSQL database dump complete
--

\unrestrict ezcvPBc0VZneFOYRd07htDc7WGCxihwQNnDeNSTT5l8aEM0R4FjCPZwK8tMTZO9

