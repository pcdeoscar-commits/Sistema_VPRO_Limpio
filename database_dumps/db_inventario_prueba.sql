--
-- PostgreSQL database dump
--

\restrict hIMNAfOs5vDGyKi2ylgwSKlsi7yn5gF9P3dhkVENmZ3E2qRK6YQCptA08wQECGv

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
-- Name: historial_equipo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historial_equipo (
    id_registro integer NOT NULL,
    codigo_equipo text NOT NULL,
    fecha date DEFAULT CURRENT_DATE,
    folio_vpro character varying(50),
    id_empleado character varying(50),
    tipo_evento character varying(50),
    descripcion text,
    costo_asociado numeric(10,2) DEFAULT 0,
    estado_final character varying(50),
    departamento character varying(50)
);


ALTER TABLE public.historial_equipo OWNER TO postgres;

--
-- Name: historial_clinico_equipo_id_registro_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.historial_clinico_equipo_id_registro_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.historial_clinico_equipo_id_registro_seq OWNER TO postgres;

--
-- Name: historial_clinico_equipo_id_registro_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.historial_clinico_equipo_id_registro_seq OWNED BY public.historial_equipo.id_registro;


--
-- Name: inventario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventario (
    codigo text NOT NULL,
    responsiva text,
    fecha_compra text,
    descripcion text,
    marca text,
    modelo text,
    serie text,
    responsable text,
    estado text,
    ubicacion text,
    observaciones text
);


ALTER TABLE public.inventario OWNER TO postgres;

--
-- Name: inventario_kits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventario_kits (
    id_inv_kits integer NOT NULL,
    codigo_inv_kits character varying(100),
    responsiva_inv_kits character varying(50),
    fecha_de_compra_inv_kits date,
    descripcion_inv_kits text NOT NULL,
    marca_inv_kits character varying(50),
    modelo_inv_kits character varying(50),
    serie_inv_kits character varying(100),
    responsable_inv_kits character varying(100),
    id_empleado_ref_inv_kits character varying(10),
    estado_inv_kits character varying(50),
    ubicacion_inv_kits character varying(50),
    observaciones_inv_kits text,
    fecha_registro_inv_kits timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.inventario_kits OWNER TO postgres;

--
-- Name: inventario_kits_id_inv_kits_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventario_kits_id_inv_kits_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventario_kits_id_inv_kits_seq OWNER TO postgres;

--
-- Name: inventario_kits_id_inv_kits_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventario_kits_id_inv_kits_seq OWNED BY public.inventario_kits.id_inv_kits;


--
-- Name: reparaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reparaciones (
    num_d_servicio text NOT NULL,
    fecha_d_reporte date,
    equipo_n_reparacion text,
    area_q_pertenece character varying(100),
    marca character varying(50),
    folio_vpro text,
    modelo character varying(50),
    responsiva character varying(50),
    responsable_d_equipo character varying(100),
    reportante character varying(100),
    estado_actual character varying(50),
    descripcion_del_dano text,
    accion_a_seguir character varying(100),
    detalles_de_reparacion text,
    encargado_d_reparacion character varying(100),
    recibe_equipo character varying(100),
    fec_d_ent_a_reparacion date,
    costo_d_reparacion numeric(12,2),
    importe numeric(12,2),
    fecha_d_entrega date,
    proveedor1 character varying(100),
    proveedor2 character varying(100),
    proveedor3 character varying(100),
    cant1 integer,
    cant2 integer,
    cant3 integer,
    costo1 numeric(12,2),
    costo2 numeric(12,2),
    costo3 numeric(12,2),
    importe1 numeric(12,2),
    importe2 numeric(12,2),
    importe3 numeric(12,2),
    plazo_de_entrega1 character varying(100),
    plazo_de_entrega2 character varying(100),
    plazo_de_entrega3 character varying(100),
    llegada1 date,
    llegada2 date,
    llegada3 date,
    fecha_d_pago1 date,
    fecha_d_pago2 date,
    fecha_d_pago3 date,
    firma_resp character varying(100),
    firma_jefe_inmediato character varying(100),
    firma_admon character varying(100),
    firma_entrega_equipo character varying(100),
    num_responsiva_nva character varying(50)
);


ALTER TABLE public.reparaciones OWNER TO postgres;

--
-- Name: historial_equipo id_registro; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_equipo ALTER COLUMN id_registro SET DEFAULT nextval('public.historial_clinico_equipo_id_registro_seq'::regclass);


--
-- Name: inventario_kits id_inv_kits; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario_kits ALTER COLUMN id_inv_kits SET DEFAULT nextval('public.inventario_kits_id_inv_kits_seq'::regclass);


--
-- Data for Name: historial_equipo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.historial_equipo (id_registro, codigo_equipo, fecha, folio_vpro, id_empleado, tipo_evento, descripcion, costo_asociado, estado_final, departamento) FROM stdin;
1	INV_VPRO_ALT_00016	2026-08-13	OP-1	000	CHECKIN_REVISIÓN	Estaba muy sucio y con lodo	0.00	RESUELTO	BODEGA
2	INV_VPRO_ALT_00017	2026-08-13	OP-1	000	CHECKIN_REVISIÓN	Estaba muy sucio y con lodo	0.00	RESUELTO	BODEGA
3	INV_VPRO_ALT_00018	2026-08-13	OP-1	000	CHECKIN_REVISIÓN	Estaba muy sucio y con lodo	0.00	RESUELTO	BODEGA
4	INV_VPRO_ALT_00019	2026-08-13	OP-1	000	CHECKIN_REVISIÓN	Estaba muy sucio y con lodo la tapa solamente	0.00	RESUELTO	BODEGA
5	INV_VPRO_ALT_00023	2026-08-13	OP-1	000	CHECKIN_REVISIÓN	Estaba muy sucios y con lodo	0.00	RESUELTO	BODEGA
6	INV_VPRO_ALT_00025	2026-08-13	OP-1	000	CHECKIN_REVISIÓN	Estaba muy sucio	0.00	RESUELTO	BODEGA
7	INV_VPRO_ALT_00015	2026-08-20	OP-4	000	CHECKIN_REVISIÓN	Por doble evento se quedo en la locación	0.00	RESUELTO	BODEGA
8	INV_VPRO_ALT_00023	2026-08-20	OP-4	000	CHECKIN_REVISIÓN	2 pisacables se quedaron en locacion	0.00	RESUELTO	BODEGA
9	INV_VPRO_ALT_00024	2026-08-20	OP-4	000	CHECKIN_REVISIÓN	Por doble evento se quedo en la locación	0.00	RESUELTO	BODEGA
10	INV_VPRO_ALT_00181	2026-08-20	OP-4	000	CHECKIN_REVISIÓN	Por doble evento se quedo en la locación	0.00	RESUELTO	BODEGA
11	INV_VPRO_ALT_00252	2026-08-20	OP-4	000	CHECKIN_REVISIÓN	Por doble evento se quedo en la locación	0.00	RESUELTO	BODEGA
12	COMPUTADORA DE ESCRITORIO CON DOS MONITORES	2026-08-25	MANTENIMIENTO_INTERNO	201	MANTENIMIENTO_TÉCNICO	zumbaba machin.	0.00	PENDIENTE	SISTEMAS
15	AIRE ACONDICIONADO TIPO MINI SPLIT DE 2 TON. MARCA MIRAGE ABSOLUT	2026-08-25	MANTENIMIENTO_INTERNO	201	FALLA_OPERATIVA	Tira un chorro de agua que no se puede contener y casi nos ahogamos aqui en el departamento de sistemas, periferia, lugares cercanos y aledaños.. en un caos total.	0.00	PENDIENTE	SISTEMAS
16	MONITOR LCD, AOC,TECLADO ASSY P/697737-161 CT:BCYSTOAHH7132V. MOUSE 24GHZ WIRELESS OPTICAL	2026-08-26	MANTENIMIENTO_INTERNO	201	FALLA_OPERATIVA	Se ve mal la imagen, Daña la vista lo tenia Geo Estrada.... Se acordó que se le instalará otro por mientras pero si hay evento se llevará al evento, quedandose el momentaneamente sin monitor.	0.00	DAÑADO	SISTEMAS
17	MONITOR LCD, AOC,TECLADO ASSY P/697737-161 CT:BCYSTOAHH7132V. MOUSE 24GHZ WIRELESS OPTICAL	2026-08-26	MANTENIMIENTO_INTERNO	201	FALLA_OPERATIVA	Se ve mal la imagen, Daña la vista lo tenia Geo Estrada.... Se acordó que se le instalará otro por mientras pero si hay evento se llevará al evento, quedandose el momentaneamente sin monitor.	0.00	DAÑADO	SISTEMAS
18	MONITOR LCD, AOC,TECLADO ASSY P/697737-161 CT:BCYSTOAHH7132V. MOUSE 24GHZ WIRELESS OPTICAL	2026-08-27	MANTENIMIENTO_INTERNO	201	FALLA_OPERATIVA	Se ve mal la imagen, Daña la vista lo tenia Geo Estrada.... Se acordó que se le instalará otro por mientras pero si hay evento se llevará al evento, quedandose el momentaneamente sin monitor.	0.00	DAÑADO	SISTEMAS
19	INV_VPRO_ALT_00024	2026-08-28	OP-4	000	CHECKIN_REVISIÓN	Por doble evento se quedo en la locación	0.00	RESUELTO	BODEGA
20	INV_VPRO_ALT_00181	2026-08-28	OP-4	000	CHECKIN_REVISIÓN	Por doble evento se quedo en la locación	0.00	RESUELTO	BODEGA
21	INV_VPRO_ALT_00252	2026-08-28	OP-4	000	CHECKIN_REVISIÓN	Por doble evento se quedo en la locación	0.00	RESUELTO	BODEGA
22	INV_VPRO_ALT_00015	2026-08-28	OP-4	000	CHECKIN_REVISIÓN	Por doble evento se quedo en la locación	0.00	RESUELTO	BODEGA
23	INV_VPRO_ALT_00023	2026-08-28	OP-4	000	CHECKIN_REVISIÓN	2 pisacables se quedaron en locacion	0.00	RESUELTO	BODEGA
24	A/ACONDICIOADO MARCA MIRAGE EN LA OFNA DEL DEPTO DE SISTEMAS	2026-08-31	MANTENIMIENTO_INTERNO	201	MANTENIMIENTO_TÉCNICO	El AA tira agua sobre la estanteria	0.00	DAÑADO	SISTEMAS
25	A/ACONDICIOADO MARCA MIRAGE EN LA OFNA DEL DEPTO DE SISTEMAS	2026-08-31	MANTENIMIENTO_INTERNO	201	MANTENIMIENTO_TÉCNICO	El AA tira agua sobre la estanteria	0.00	DAÑADO	SISTEMAS
26	A/ACONDICIOADO MARCA MIRAGE EN LA OFNA DEL DEPTO DE SISTEMAS	2026-08-31	MANTENIMIENTO_INTERNO	201	MANTENIMIENTO_TÉCNICO	El AA tira agua sobre la estanteria	0.00	PENDIENTE	SISTEMAS
27	TELMEX-SERCOMM-GN25L95	2026-09-11	MANTENIMIENTO_INTERNO	202	FALLA_OPERATIVA	Se reportó a telmex el 11/09/2026 , reporte 11522457	0.00	DAÑADO	SISTEMAS
28	VPNRED039	2026-09-17	MANTENIMIENTO_INTERNO	201	DAÑO_FÍSICO_OFICINA	Se daño al bajar de la camioneta... se me soltó/desprendió el sujetador.	0.00	DAÑADO	SISTEMAS
\.


--
-- Data for Name: inventario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventario (codigo, responsiva, fecha_compra, descripcion, marca, modelo, serie, responsable, estado, ubicacion, observaciones) FROM stdin;
VIRA017		03/07/2025	Pantalla de 55" LED LCD	PHILIPHS	55PFL5765/F8	CC2A2104116994	104.0	Bien	Bodega 2	
VIRA018		03/07/2025	Pantalla de 55" LED LCD	HISENSE	55R6000GM	55G21260RH03316	104.0	BAJA	Bodega 2	No funciona la pantalla
VIRA019		03/07/2025	Pantalla de 40" FHD CON ROKU TV	JVC	SI40FR	COJVC20240841673	104.0	Bien	Bodega 2	
VIRA020		03/07/2025	Pantalla de 40" FHD CON ROKU TV	JVC	SI40FR	COJVC20240841676	104.0		Bodega 2	
VIRA021		03/07/2025	Panatalla de 40"	PHILIPHS	40PFL4708/F8	XA1A1321108186	104.0	BAJA	Bodega 2	No enciende
VIRA022		03/07/2025	Pantalla de 40"	PHILIPHS	40PFL4707/F8	XA1A1233117552		BAJA		No enciende
VIRA023		03/07/2025	Panatalla de 40"	PHILIPHS	40PFL4708/F8	XA1A1316101578		BAJA		No enciende
VIRA024		03/07/2025	(9) Bases de madera para pantallas de	Hechas a la medida	S/M	S/N	104.0		Bodega 2	
VIRA025		15/07/2025	(8) Bases de soporte para televisión con ruedas y (2) baras metalicas cada una	Hechas a la medida						
VIRA027			(3) Soportes de TV de 42" a 85"	Link Bits	C3275N41B	S/N				
VIRA028			Compresor de aire de trasmisión directa de 25 Litros	MH	Master Hardware	S/N				
VIRA029			Monitor	AOC	215LM004O	AEJF79A002282		SIN CABLE		
VIRA030			(6) base a piso para TV	High Resistance						
VIRA031			(8) Soportes para monitor de 65"		Commercial electric	(6) XD2165-1       (2) Master				
VPNADM001			Laptop DELL INSPIRON 3558 y cargador.	Dell	Dell inspiron 15	24095400914	121	Bueno	Administracion	
VPNADM002			Impresora COLOR LASER JET PRO MFP M176N	HP	MFP M176N	S/N		Baja	Administracion	
VPNADM003	Resp.01		HP Pavilion All-in-One, Teclado y Mouse	HP	23-9151LA	8CC609059V	101	Bueno	Administracion	
VPNADM004	Resp.01		Impresora BROTHER Multi-fuction copier	Brother	DCP7055	U62715E1N475679	101	Sin uso	Bodega de Pedro	
VPNADM005	Resp.01	29/07/2024	Impresora a color HP smart Tank 520	HP	520	CN2CP1B1RJ	101	Bueno	Anministracion	
VPNADM006	Resp.01		Trituradora	Shredder	SES-C1506X	90600333	101	Dañado	Recepción	
VPNADM007	Resp.001		Impresora Lasser SAMSUNG, Mod. Xpress M2022	Samsung	Xpress M2020	074FB8GH4A00E6M	101	Bueno	Administracion	
VPNADM008	Resp.002		HP Pavilion All-in-One, Teclado y Mouse	HP	23-q151la	4CI60404HP	Juan Pablo Espino Diaz	Bueno	Administracion	
VPNADM009	Resp.002		Impresora Lasser SAMSUNG, Mod. Xpress M2022	Samsung	Xpress M2020	074FB8GH3B00QXE	Juan Pablo Espino Diaz	Bueno	Administracion	
VPNADM010		11/03/2024	Scanner mate	KODAK	I940	52861799	Bodega	Sin uso	Bodega de Pedro	
VPNADM011		26/06/2025	TV Hitachi de 43"	Hitachi	LE43M4S9		101	Buena	Administracion	
VPNAUD002		08/09/2023	(KIT) micrófono Lavalier con cable estéreo, mini BMP y adaptador para zapato (transmisor y receptor)	SONY	URX-P03                   UTX-B03	108717                                            107167	118	Funcional	Departamento de audio	
VPNDGF007		21/06/2025	Lente 24mm T1.5 Full Frame Wide Angle Cine DS ED AS IF UMC II	ROKINON	DS24M-NEX	S/N	102	Bueno	Closet comercialización	MALETA PELICAN GRIS
VPNDGF008		21/06/2025	Lente 35mm T1.5 Full Frame Wide Angle Cine AS UMC II	ROKINON	DS35M-NEX	S/N	102	Bueno	Closet comercialización	
VPNDGF035		23/06/2025	Dron DJI (1) Control Remoto (4) Baterias para dron 4, 5, 6 ,7 (1) Adaptador (1) Fuente de poder (1) Filtro de dron ND 8 (1) Filtro de dorn ND 16 (1) Filtro de dron ND 32 (2) Lectores de memoria micro SD (2) Memorias micro SD de 128 GB (1) Memoria micro SD con lector (VPNPRO014) (2) Elices extra (1) Adaptador SD a Apple Ligthning (1) Cargador USB 3.0 USB C (1) Maleta protectora PGYTECH	DJI	*Dron: Mavic 2 Pro L1P                       *Memorias: SandDisk.                  *Baterias 4, 5 ,6 ,7:  FB2-3850.                *Adaptador Apple: A1595	*Dron: 183CGAT - R0A4BWG.                 *Memoria miscro SD 1: 0193YVETR057                     *Memoria micro SD 2:      4444DFT8222N                            *Bateria 4: 0P2DG9G641L7YJ.               *Bateria 5:  0P2AKB8537014S.       *Bateria 6: 0P2AKB853701KD.              *Bateria 7: 0P2AKB55370279.         *Filtro ND 8: X002AIQSCZ               *Filtro ND 16: X002AMI9SH.           *Filtro ND 32: X002AMI9RX          *Control Remoto: 13MDGAKROAJ8TK              *Adaptador de fuente de poder: 13YFGAEA41012T	102	Bueno	Digital Films	
VPNDIR019		24/06/2025	KIT DRONE #1 Inspire 1 (1) Vontro Remoto (4) Baterias DJI 1, 4, 6, 8 (1) Bateria Phantom 1 (1) Cámara Cardán DJI Zenmuse X3 (1) Filtro para cámara cardán	DJI	Dron: T600.                      Bateria DJI: TB47.              Baterias Phantom:  PH2-5200mAh-11.1V.            Control Remoto: GL658A	Drone: W13DCC28030031                 Control Remoto: W14DCC17040071          Bateria DJI 1: 7421160405381                         Bateria DJI 4:  7421161001810                Bateria DJI 6: 7421161801699                Bateria DJI 8:  7421145012366        Baeria Phantom 1: 3221144471657	203.0		Bodega Dirección	
VPNPRO048	PRO-001	07/09/2023	(15) - Baterías de ion-litio BP-GL95A (95 Wh)	Sony	BP-GL95A	1 - 0120546                                           2 - 0128268                                           3 - 0127585                                           4 - 0128264                                           5 - 0128269                                           6 - 0128265                                              7 - 0128267                                            8 - 0120574                                           9 - 0127586                                         10 - 0120548                                           11 - 0128270                                       12 - 0128263                                          13 - 0127587                                          14 - 0115198                                         15 - 0110033	119	Funcional	Estante de Baterias, 2 tiene Gerardo (buscarlas)	TIENE 13 de  estas la 10 no sirve,  2 TIENE gerando
VPNCAR018			4 - Cable de audio estereo de 35mm a 35mm	KRAMER	C-A35M/A35M	S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR019			UGREEN Printer Cable, 6.6 FT USB A to B Nylon Braided USB B Cable High Speed USB 2.0	UGREEN	USB A to B	S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR020			U DIN 1.0/2.3 Mini BNC to HD SDI BNC RG179 75ohm RF Coaxial Cable Video Cable for Blackmagic HyperDeck Shuttle TV Antennas	S/M	S/M	S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNDGF009		22/06/2025	(1) Latigo Follow Focus chico de 8" (1) Latigo Follow Focus largo de 12" (1) Micro Follow focus (1) Cable IEEE 1394a FireWire	Red Rock Micro	1-13-0281R	S/N	102	Bueno	Closet comercialización	
VPNDGF010		22/06/2025	(1) Cargador de baterias Sony 100V-240V output 8.4V 0.28A (1) cargador de baterias output 4.2V (8.4V) (1) Cargador de bateria FM50/70/90/QM7/1D/91D	SONY.                                Travel Charger                                    S/M	*SONY: BC- VH1                        *Travel charger: S/M.	*SONY: F811053                            *Travel charger: S/N	102	Bueno	Closet comercialización	
VPNDGF011		24/06/2025	Deslizador de cámara de 60 cm	SEVENOAK	SKGT01	S/N	102	Bueno	Closet comercialización	
VPNDGF023		23/06/2025	Disco Duro	LA100	LRDOTU3	NL100G08	102	Bueno	Digital Films	
VIRA016		03/07/2025	Pantalla de 55" LED LCD	HISESNSE	55R6000GM	55G21260RH03315	104.0	Bien	Bodega 2	
VIRA026			(5) Bases de hierro a piso							
VPNAUD038		27/02/2024	Microfono inalambrico con transmisor de mano, con receptor UHF, transmisor de mano slxd2 con la cápsula de micrófono dinámico supercardioide beta 58a y (1) receptor slxd4 de un solo canal con antena y accesorios de montaje en rack, (1) bolsa con cremallera y (2) pilas aa	SHURE	SLXD24 B58-G58 SLXD2 G58 PS43US	3CK07942469 3CK07932239	118	Funcional	Departamento de audio	se cambio el perico por el VPNAUD054
VPNCAR017			Convertidor Micro Usb A Hdmi 5 Pin Adaptador Mhl Tv Celular	MHL	Micro USB a HDMI	S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNDGF033		23/06/2025	Adaptador a USB 3.0, HDMI y lector de tarjetas SD Y TF	UGREEN	S/M	S/N	102	Bueno	Digital Films	
VPNDGF034		23/06/2025	Cámara SONY (1) Unidad de Extención (1) Control Remoto de Empuñadura (1) Visor Ocular, (1) Batería Portatíl (VPNPRO049) (1) Caja de transportación PELICAN 1550 negra	SONY	*Cámara:  PXWF7                                  *Unidad de Extención: XDCA-FS7                    *Bateria: BP-L60A	*Cámara: 20312                                            *Unidad de Extención:  2015-02.               *Bateria: 020046	102	Bueno	Digital Films	
VPNDGF037		21/07/2025	(7) Adaptadores CA para Seagate Freeagent FW External HDD Disco Duro - Negro - Positiva Punta	Product Smith	WA-24E12	(1) : 539001333                            (2): 539002154                           (3): 129004648                             (4): 129061296                            (5): 129059107.                           (6): 3B9005127                           (7): 299027095	102		Digital Films	
VPNDGF039		21/07/2025	Adaptador AC/AC	Powertron Electronics	PA'1024-120IB200	B20170500071517	102			
VPNDGF040		21/07/2025	Adaptador CA para SEAGATE, WESTERN DIGITAL	SHENZHEN HONOR ELECTRONICS	ADS-40J-12 12036EPCU	100800452FH15WJB25945	102			
VPNDGF041		21/07/2025	Adaptador 12v /100v Hasta 240v / Cad-2412	SOLYTECH ENTERPRISE	CAD2412C	S/N	102			
VPNDGF042		21/07/2025	(1) Cable HDMI de 1,30 mts y (1) cable HDMI de 2m mts (1) 3MTS	M y CM	S/M	S/N	102			
VPNDGF044		21/07/2025	(3) cables para discos duros externos	S/M	S/M	S/N	102			
VPNDGF045		21/07/2025	Cable USB a USB-B 1.0 - 2.0 Gris	S/M	S/M	S/N	102			
VPNDGF046		21/07/2025	(4) Atenuadores para lampara de mesa	LEVITON	TBL03	S/N	102			
VPNDIR004		24/06/2025	Osciloscopio de dominio mixto 100 MHz, 4 canales y analizador de espectros de 100MHz, (1) Sonda de plomo de prueba	TEKTRONIX	Osciloscopio: MDO3014                           Sonda de plomo: Chesoon P6100	Osciloscopio: MDO3014 C011030.                     Sonda de plomo: Chesoon: X0036LPN3	203.0		Bodega Dirección	
VPNDIR005		24/06/2025	Rasterizador Multi-SDI	LEADER	LV 7330	5427259	203.0		Bodega Dirección	
VPNDIR010		24/06/2025	Cable HDMI de 33" 4k active optical armored CRS- PlugNView- H 3	KRAMER	CRS- PlugNView- H 3	E208-KBRL-P-JCH7-S0-611-21/12/03-20M/00058	203.0	BAJA	Bodega Dirección	
VPNDIR011		24/06/2025	Laptop Dell Inspiron G7 7700 Gaming 17.3" Intel Core i5 10300H Disco duro 512 GB SSD Ram 8GB Winsows 10 Home	Dell	G7 7700	GRMDHX2346498685430	203.0	BAJA	Bodega Dirección	Se utilizara para piezas
VPNPRO074	PRO-001	07/09/2023	(TRIPIE 1) Sistema de Tripie Libec, Cabezal Modelo RH-45R y Piernas Modelo RT-30B, Con 2 brazos	Libec	RH-45R                                                RT-30B	S/N	119	Funcional	Bodega 1	
VPNAUD028		08/09/2023	Grabadora de VHS	ALESIS	002-AD-01	4D7119339	109	Funcional	Departamento de audio	
VPNAUD029		08/09/2023	Kit: Microfono con Antipopeo y tripie	SHURE	KSM44E	S/N	109	Funcional	Departamento de audio	
VPNDIR012		24/06/2025	Computadora HP All-in-One 18-5202la - 18.5" - AMD E1-6010 - 4GB - 500GB - Windows 8.1 - Plata/Negro - J5U02AA	HP	18-5202la	4CE447085W	203.0	BAJA	Bodega	Sin mouse ni teclado
VPNAUD027		08/09/2023	Interfaz de grabación Pro TOOLS, MBOX PRO	MBOXPRO	9100-65007-00	BXDJN11300824F	109	Funcional	Departamento de audio	
VPNDIR013		24/06/2025	Cámara de cardán ZENMUSE X5 (1) lente para DJI 0,2/066 ft MICRO 4/3	DJI	ZENMUSE X5	822000138	203.0		Bodega Dirección	
VPNDIR014		24/06/2025	Cable de audio optico con una punta extra	STEREN	260-006	S/N	203.0		Bodega Dirección	
VPNDIR015		24/06/2025	Proyector LCD-1920x1200-3500 Lumens con fuente de poder y (1) Control Remoto (1) Cable VGA	MAXWELL	MP-JW3501	FOFU03148	203.0		Bodega Dirección	
VPNDIR016		24/06/2025	Proyector LCD-1920x1200-3500 Lumens con fuente de poder y (1) Control Remoto (1) Cable VGA	MAXWELL	MP-JW3501	FOFU03178	203.0		Bodega Dirección	
VPNDIR017		24/06/2025	Proyector LCD-1920x1200-3500 Lumens con fuente de poder y (1) Control Remoto (1) Cable VGA	MAXWELL	MP-JW3501	FOFU03179	203.0		Bodega Dirección	
VPNDIR020		24/06/2025	(5) Cajas con (50 c/u) Conectores Bradcast BNC, 15RGB/ Mini Coax (Belden 1855A) compresión de una pieza de 6GHz, tamaño del cable RGB/mini 22-24 AWG	BELDEN	1855ABHD1              1694ABHD1	S/N	203.0	Caja 1:  2 piezas                        Caja dos: 46 piezas                           Caja 3: 50 piezas                       Caja 4: 50 piezas.             Caja 5 (verdes):50 piezas	Bodega Dirección	
VPNDIR021		30/06/2025	Computadora Notebook sin cargador, cable USB C con 4 salidas USB, convertidor USC tipo C a Ethernet y maletin	ASUS	L410M	M2N0CX100370087	203.0			
VPNEDI001			Pc De Escritorio (todo En Uno) Apple iMac A1419, Teclado y Mouse	Apple	A1419	C02PF0NQF8J4     22311001068		Bueno	Edición HD	
VPNEDI003	Resp.12		iMac Apple A2115 con teclado y mouse inalámbrico	Apple	A2115	C02FT11MPN7C	200	Bueno	Edición HD	
VPNEDI004	Resp.15		Memoria de 6 Tb Segate back up pub plus	Segate	SRD0PV1	NA9R8MC3	113	Bueno	Edición HD	
VPNEDI005	Resp.15	12/03/2024	MAC STUDIO	APPLE	A2901	F6KYFQ5T44	113	Bueno	Edición HD	
VPNEDI006	Resp.15	12/03/2024	Computadora Asus ProArt Display DE 27" coon cable USB C, HDMI, Display port, fuente de energia con mouse y teclado Apple.	ASUS                        APPLE	PA279CV	RBLMTF087121	113	Bueno	Edición HD	
VPNEDI007	Resp.13	29/07/2024	Memoria de 6 Tb	ADATA	HM9009T	NA8T9G32	Fijo-banco de data	Bueno	Edición HD	
VPNEDI008		29/07/2024	Unidad de disco duro externa 4Tb	Adata	HM800	1M2820821413	Fijo-banco de data	Bueno	Edición HD	
VPNEDI009		29/07/2024	Memoria de 6T	SEGATE	SRD0PV1	NA8T86J2	Fijo-banco de data	Bueno	Edición HD	
VPNEDI010		29/07/2024	Memoria de 5 Tb	NEMCO	SR00F2	NA7H0HHX	Fijo-banco de data	Bueno	Edición HD	
VPNEDI011		29/07/2024	Memoria de 5 Tb	NEMCO	SR00F2	NA7H0HFJ	Fijo-banco de data	Bueno	Edición HD	
VPNEDI012		29/07/2024	Memoria de 5 Tb	NEMCO	SR00F2	NA7H0HF9	Fijo-banco de data	Bueno	Edición HD	
VPNEDI013		29/07/2024	Memoria Nobility de 3 Tb	ADATA	NH03	1F3220176901	Fijo-banco de data	Bueno	Edición HD	
VPNEDI014		29/07/2024	Memoria Nobility de 3 Tb	ADATA	NH03	1F3220176875	Fijo-banco de data	Bueno	Edición HD	
VPNEDI015		29/07/2024	Memoria Nobility de 3 Tb	ADATA	NH03	ID2220030719	Fijo-banco de data	Bueno	Edición HD	
VPNEDI016		30/06/2025	Monitor DELL de 195 pulgadas sin cable de corriente	DELL	E214Hc	CN-012MWY-64180-537-0GZL	201	Bueno	Redes	
VPNEST001			TriCaster	NEWTEK	455 MULTISTANDAR	NA2056026334262		Bueno	Estudio TV	
VPNEST002			Panel de control TriCaster con teclado y mouse inhalambrico	NEWTEK	XD460 CONTROL SURFACE Teclado y mouse: COM-6200NE	N1AN138844990796		Bueno	Estudio TV	
VPNEST003			Televisión de 28.6" x 19.03"	VIZIO	E32-C1	LTB7SJER3202666		Bueno	Estudio TV	
VPNEST004			Televisión de 28.6" x 19.03"	VIZIO	E32-C1	LTB7SJER320669		Bueno	Estudio TV	
VPNEST008			Interfaz de audio con cable (VPNAUD003) audio 2.0	PEAVEY	S/M	0DB1M226327		Bueno	Estudio TV	
VPNEST009			Hibrido digital Broadcast Host	JK-AUDIO	S/M	BH07961		Bueno	Estudio TV	
VPNEST010			CPU armado	S/M	S/M	S/N		Bueno	Estudio TV	
VPNEST011			Microfono inalambrico de podium	S/M	MX890	S/N		Bueno	Estudio TV	
VPNEST012			Receptor inalambrico con cable de corriente	SHURE	SLX4	1MA1033908-01		Bueno	Estudio TV	
VPNEST013	VPNEST014		(2) Bocinas	KRK	ROKIT 5	HAE1018025 HAE1120398	Hector Rementeria	Bueno	Estudio TV	
VPNEST015			Switch de escritorio con cabes de corriente	TPLINK	LS105G	S/N		Bueno	Estudio TV	
VPNEST017			Web caster x2 con HDMI, antena, y cable HDMI.	EPHIPAN VIDEO	WEBCASTER X2	HWCX17124656		Bueno	Estudio TV	
VPNEST019			Convertidor VGA a HDMI con adaptador y auxiliar	STEREN	208144	S/N		Bueno	Estudio TV	checar con osiel
VPNEST020			Adaptador THUNDERBOLT a HDMI	STEREN	D020673	S/N	Pedro Villarreal	Bueno	Dirección	
VPNEST021			3 Monitor LCD 5" X3	TOTEVISION	LED-504HDMX3	T51170156		Bueno	Estudio TV	
VPNEST022			No Break	SOLA BASIC	XR 21202	E-17D02431		Resguardo	Estudio TV	No fuenciona y es necesario cambiar la tarjeta mandre
VPNEST023			Audifonos alambricos	GIBSON INNOVACIONES	S/M	NL5616L2400SFI14		Bueno	Estudio TV	
VPNPRO192	Resp. 010	11/04/2023	CPU armado con cargador, tarjeta de video asus GEFORCE RTX, tarjeta madre ASUS PRIME b660M-AD4, procesador, abanico, 4 memorias RAM 32 GB / 49 GB, Disco duro M2 de 500 GB	S/M	S/M	T.V: R9YVNC017413M3Y                                      T.M :R7M0CS000247G4A	109	Bueno	Caja VMIX	Se cambio la tarjeta de video y tarjeta madre
VPNCOM003			Disponible							
VPNEDI017		29/07/2024	Pc De Escritorio (todo En Uno) Apple iMac A1419, Teclado y Mouse	Apple.    Teclado:Macally	A1419	IMAC:D25PL1GDFY14                       Teclado: 22311001421	110	Bueno	Edición HD	
VPNEST024			(10) Cable de audio	S/M	S/M	S/N		Bueno	Estudio TV	
VPNAUD022		08/09/2023	Consola de audio de 4 canales	STEREN	MIX-160	25492	118	Funcional	bodega 1	
VPNEST025			Convertidor SDI a HDMI	BLACK MAGIC	S/M	7569032		Bueno	Estudio TV	
VPNEST026			Television 32" LED LCD	PHILIPS	32PFL4508F8	ZA1A1317130441		Bueno	Estudio TV	
VPNEST032			Tripie con bolsas de arena	AVENGER	D520	S/N		Bueno	Estudio TV	
VPNEST033			(4) Mini prensa	S/M	S/M	S/N		Bueno	Estudio TV	
VPNEST034			Multicontacto de 10 salidas	S/M	S/M	S/N		Bueno	Estudio TV	
VPNEST035	RES-PRO-001	07/09/2023	CAMARA#5 Sony PMW-320K XDCAM EX Camcorder w/16x Zoom & CBK-CE01, SONY CBK-VF01 viewfinder HD camera PMW-350 PMW-320	Sony	PMW-320                                            CBK-VF01	106637        176482 (view finder en kit camera #4)	119	Bueno	Estudio TV	El viewfinder es del Kit de camara #4 VPNPRO037
VPNEST036	RES-PRO-001	07/09/2023	LENTE FUJINON XS16x5.8A-XB8A (CAMARA #3)	Fujinon	A-XB8A	B62406463	119	Bueno	Estudio TV	KIT CAMARA PRODUCCIÓN  #3
VPNEST037	RES-PRO-001	07/09/2023	VariZoom VZPGF | Fujinon Zoom Control | Lens Control	VariZoom	VZPGF	S/N	119	Bueno	Estudio TV	
VPNEST038	RES-PRO-001	07/09/2023	Control de Enfoque	VariZoom	VZ-FCC	S/N	119	Bueno	Estudio TV	EN CAMARA #4
VPNEST039	RES-PRO-001	07/09/2023	(CAMARA #6 ) Sony PMW-320K XDCAM EX Camcorder w/16x Zoom & CBK-CE01, SONY CBK-VF01 viewfinder HD camera PMW-350 PMW-320	Sony	PMW-320                 CBK-VF01	106434                        0101858	119	Bueno	Estudio TV	PRODUCCIÓN
VPNEST042	RES-PRO-001	07/09/2023	Control de Enfoque	VariZoom	VZ-FCC	S/N	119	Bueno	Estudio TV	
VPNEST043	RES-PRO-001	07/09/2023	(CAMARA#7) Sony PMW-320K XDCAM EX Camcorder w/16x Zoom & CBK-CE01, SONY CBK-VF01 viewfinder HD camera PMW-350 PMW-320	Sony	PMW-320                 CBK-VF01	106645    176816 (viewfinder en camara #4)	119	Bueno	Estudio TV	El viewfinder esta en la camara de producción #4
VPNEST044	RES-PRO-001	07/09/2023	LENTE FUJINON XS16x5.8A-XB8A (CÁMARA #1 PRODUCCIÓN)	Fujinon	A-XB8A	B62400719	119	Bueno	Estudio TV	EN PRODUCCION ESTA EL LENTE DE LA CAMARA #1 DE PRODUCCION
VPNEST045	RES-PRO-001	07/09/2023	VariZoom VZPGF | Fujinon Zoom Control | Lens Control	VariZoom	VZPGF	S/N	119	Bueno	kit de camara PRODUCCIÓN #4	
VPNEST046	RES-PRO-001	07/09/2023	Control de Enfoque	VariZoom	VZ-FCC	S/N	119	Bueno	Estudio TV	ESTE ZOOM ESTA EN LA CAMARA #1 DE PRODUCCION
VPNEST047	RES-PRO-001	07/09/2023	(MONITOR #5) Kit de monitor LCD Field Monitor 7 pulgadas: Monitor, para sol, adaptador de bateria, fuente de poder con adaptador, cable HDMI.	LILIPUT	LI663OP2	63PB77598061	119	Bueno	Estudio TV	Sin adaptador de corriente a camara
VPNEST049	RES-PRO-001	07/09/2023	(MONITOR #6) Kit de monitor LCD Field Monitor 7 pulgadas: Monitor, para sol, adaptador de bateria, fuente de poder con adaptador, cable HDMI.	LILIPUT	LI663OP2	663A6141R005	119	Bueno	Estudio TV	Sin adaptador de corriente a camara
VPNEST051	RES-PRO-001	07/09/2023	Tripie Libec T-72 (T72) Two-stage aluminium tripod with 75mm bowl	Libec	T72	S/N	119	Bueno	Estudio TV	
VPNEST052	RES-PRO-001	07/09/2023	Tripie Libec T-72 (T72) Two-stage aluminium tripod with 75mm bowl	Libec	T72	S/N	119	Bueno	Estudio TV	
VPNEST054	RES-PRO-001	07/09/2023	Adaptador de CA/cargador AC-DN10 - Sony Pro	SONY	AC-DN10	02290-14Z	119	Bueno	Estudio TV	
VPNEST055		01/07/2025	Mezcladora de audio con convertidor AD/DA de 16 bits/48 kHz.	ALLEN&HEATH	ZED16FX	Z16FXX-1002521		Bueno	Cabina de estudio	
VPNFIJ003			Mini Split de 1 ton. Mod. Absolut	Mirage	EXF121D	EXF121D8051404980 CXF121D8081401595	Fijo	Bueno	Coordinacion de Producción	
VPNFIJ004			Mini Split de 1 ton. Mod. Absolut	Mirage	SMEC1221F		Fijo	Bueno	Producción	
VPNFIJ005			Aire acondicionado tipo Mini Split de 2 ton. Marca Mirage Absolut	Mirage	Absolut	EXF261d8021400928 CXF261D8021400234	Fijo	Activo	Recepción	
VPNPRO001	Resp.004	15/02/2023	All in One Lenovo IdeaCentre 300-22ACL, Procesador AMD A6 7310 (hasta 2.4 GHz), Memoria de 4GB DDR3L, Disco Duro de 1TB, Pantalla de 21.5" LED, Video Radeon R4 Graphics, Unidad Óptica DVD±R/RW,	Lenovo	F0BW	P9019CSA		Bueno	Coordinacion de Producción	
VPNPRO002	Resp.004	15/02/2023	Kingston HyperX 3 K sh103s3/240G 2,5 240 GB SATA III, MLC interna unidad de estado sólido (SSD)	Kingston	Hyperx	50026B724C08AD58	116	Bueno	Coordinacion de Producción	
VPNPRO003	Resp.004	15/02/2023	Kingston SQ500S37/480G 480GB Q500 SATA3 2.5 SSD	Kingston	SBFKQ1.3	50026B7785089FED	201	Bueno	Redes	Instalado en el Servidor
VPNPRO004	Resp.004	15/02/2023	Kingston HyperX 3 K sh103s3/240G 2,5 240 GB SATA III, MLC interna unidad de estado sólido (SSD)	Kingston	Hyperx	50026B7252009C27	116	Bueno	Coordinacion de Producción	
VPNPRO005	Resp.004	15/02/2023	Sony 64GB SxS-1 (G1C) Memory Card SBS64G1C	Sony	SBS-64G1B	SKC96014	116	Bueno	Coordinacion de Producción	
VPNPRO006	Resp.004	15/02/2023	Sony 64GB SxS-1 (G1C) Memory Card SBS64G1C	Sony	SBS-64G1B	9EDN1063	116	Bueno	Coordinacion de Producción	
VPNPRO007	Resp.004	15/02/2023	Sony 64GB SxS-1 (G1C) Memory Card SBS64G1C	Sony	SBS-64G1B	SKEB7012	116	Bueno	Coordinacion de Producción	
VPNPRO008	Resp.004	15/02/2023	Sony 64GB SxS-1 (G1C) Memory Card SBS64G1C	Sony	SBS-64G1B	DEKZ1254	116	Bueno	Coordinacion de Producción	
VPNPRO009	Resp.004	15/02/2023	Sony 64GB SxS-1 (G1C) Memory Card SBS64G1C	Sony	SBS-64G1B	DELB1013	116	Bueno	Coordinacion de Producción	
VPNPRO010	Resp.004	15/02/2023	Sony 64GB SxS-1 (G1C) Memory Card SBS64G1C	Sony	SBS-64G1B	9EDN1064	116	Bueno	Coordinacion de Producción	
VPNPRO011	Resp.004	15/02/2023	Sony 16GB SxS Memory Card SBS-16G1B	Sony	SBS-16G1B	EFEH1079	116	Bueno	Coordinacion de Producción	Esta quebrada la parte donde va el N0 de serie
VPNPRO016	Resp.004	15/02/2023	SanDisk Tarjeta Extreme PRO SDXC UHS-I de 256 GB - C10, U3, V30, 4K UHD, tarjeta SD - SDSDXXY-256G-GN4IN	SanDisk	Extreme PRO	S/N	116	Bueno	Coordinacion de Producción	
VPNAUD024		08/09/2023	Computadora MAC de 27" con teclado y mouse	APPLE	MAC OSX YOSEMITE	C02K60ABDNCV	109	Funcional	Departamento de audio	
VPNAUD030		08/09/2023	ATRIL	S/M	S/M	S/N	109	Funcional	Departamento de audio	
VPNEST053	RES-PRO-001	07/09/2023	Adaptador de CA/cargador AC-DN10 - Sony Pro	SONY	AC-DN10	025289-14Z	119	Bueno	Estudio TV	
VPNPRO018	Resp.004	15/02/2023	SanDisk RAM-3074 Memoria Extreme 64GB Micro SDXC 160Mb/S 4K Clase 10 A2 V31	SanDisk	Micro SD	6376DPGAJ0J4	116	Bueno	Coordinacion de Producción	
VPNAUD023		08/09/2023	Par de bocinas KRK para edición	ROKIT	AMPK00053	HAFD052403 HAFD052213	109	Funcional	Departamento de audio	
VPNPRO019	Resp.004	15/02/2023	Disco Duro Externo HV620S, Capacidad 1TB (1,000GB), Interfaz USB 3.1	ADATA	HV620S	1J3520345442	116	Bueno	Coordinacion de Producción	
VPNPRO021	Resp.004	15/02/2023	SSD SanDisk Ultra 3D, 250GB, SATA III, 2.5'', 7mm, SDSSDH3-250G-G25	SanDisk	SDSSDH3	21107B802460	119	Bueno		
VPNPRO022	Resp.004	15/02/2023	SSD SanDisk Ultra 3D, 250GB, SATA III, 2.5'', 7mm, SDSSDH3-250G-G25	SanDisk	SDSSDH3	21107B802366	116	Bueno	pendiente	
VPNPRO023			Video capturadora con mini stand	PIBOX	INPIRE	S/N	109			
VPNPRO024			Cable HDMI	S/M	S/M	S/N	119			
VPNPRO025	PRO-001	07/09/2023	(CAMARA #3) Sony PXW-320K XDCAM EX Camcorder w/16x Zoom & CBK-CE01, SONY CBK-VF01 viewfinder HD camera PMW-350 PMW-320	Sony	PMW-320                                 CBK-VF01	101904 - 101904	119	Funcional	Bodega 1	Viewfinder anteriormente en el kit #2, presentaba daños en la mira.
VPNPRO026	PRO-001	07/09/2023	VZGF Zoom Control	VariZoom	S/M	S/N	119	Funcional	Bodega 1	KIT ESTUDIO COMARA #5
VPNPRO027	PRO-001	07/09/2023	Cable de Control de Enfoque	VariZoom	VZ-FCC	S/N	119	Funcional	Bodega 1	
VPNPRO028	PRO-001	07/09/2023	LENTE FUJINON XS16x5.8A-XB8	Fujinon	A-XB8	B62400588	119	Funcional	Estudio	KIT CAMARA #5 ESTUDIO
VPNPRO030	PRO-001	07/09/2023	LENTE FUJINON XS16x5.8A-XB8	Fujinon	A-XB8	A62411254	119	Funcional	Bodega 1	EN PRODUCCION ESTA EL LENTE DE LA CAMARA #7 DEL ESTUDIO
VPNPRO031	PRO-001	07/09/2023	VZGF Zoom Control	VariZoom	S/M	S/N	119	Funcional	Bodega 1	KIT CAMARA PRODUCCIÓN #2
VPNPRO032	PRO-001	07/09/2023	Cable de Control de Enfoque	VariZoom	VZ-FCC	S/N	119	Funcional	Bodega 1	KIT CÁMARA PRODUCCIÓN#2
VPNPRO037	PRO-001	07/09/2023	(CAMARA #4) Sony PMW-320K XDCAM EX Camcorder w/16x Zoom & CBK-CE01, SONY CBK-VF01 viewfinder HD camera PMW-350 PMW-320	Sony	PMW-320                                 CBK-VF01	106623                                                                                  176830 (viewfinder en kit camara #5)	119	Funcional	Bodega 1	EN ESTA CAMARA ESTA EL ZOOM DE LA CAMARA #7 DEL ESTUDIO VPNEST046, y el viefinder es del VPNEST043
VPNPRO039	PRO-001	07/09/2023	(2) VZPGF Compact 8-pin Fujinon Pro Zoom Control with swivel Clamp	VariZoom	PG-F                          G-F	S/N	119	Funcional	Bodega 1	KIT CAMARA PRODUCCIÓN #1
VPNPRO040	PRO-001	07/09/2023	(CAMARA 01 EX3) Sony PMW-EX3 XDCAM EX HD Camcorder	Sony	PMW-EX3	134187	119	Esta en Reparacion	Bodega 1	Esta en reparacion
VPNPRO046	PRO-001	07/09/2023	(CAMARA 02 H1) XL H1A - Canon Camera	Canon	XL-H1A	4724723000 58	119	Funcional	Bodega 1	
VPNPRO050	PRO-001	07/09/2023	Sony BP L90A Battery Rebuild	Sony	BP-L90A	30308	119	Funcional	Estante de Baterias	
VPNPRO053	PRO-001	07/09/2023	Cargador de batería de iones de litio Sony BC-L70 Y fuente de poder para camaras	Sony	BC-L70	0122647 138	119	Funcional	Estante de Baterias	
VPNPRO054	PRO-001	07/09/2023	Sony BC-L50 Battery Charger	Sony	BC-L50	101646Z	119	Funcional	Estante de Baterias	
VPNPRO055	PRO-001	07/09/2023	IDX VL-2Plus (VL2 Plus) 2-Channel Endura Sequential V-Mount Quick Charger with AC Adaptor (60W)	Endura Sistem	VL-2Plus	K-01215	119	Funcional	Estante de Baterias	
VPNPRO056	PRO-001	07/09/2023	(3) - Baterías Sony de larga duración XDCAM EX BP-U60 para camara EX3	Sony	BP-U60	2012C124                                 20130318                                  20110616	119	Funcional	Estante de Baterias	La tiene el Ing. Sandoval
VPNPRO057	PRO-001	07/09/2023	(2) - Baterías Sony BP-U30 para camara EX3	Sony	BP-U30	20120615                                             20140922	119	Funcional	Estante de Baterias	
VPNPRO058	PRO-001	07/09/2023	(2) - Battery Pack BP-970G Para camara Canon H1	Canon	BP-970G	201307                                         201308	119	Funcional	Estante de Baterias	
VPNPRO059	PRO-001	07/09/2023	(2) - Canon Bp-930 Otb Batarya Fiyat Para camara Canon H1	Canon	BP-930	S/N	119	Funcional	Estante de Baterias	1 bateria no le sirve
VPNPRO060	PRO-001	07/09/2023	Canon Power Accessories VIDEO BATT. PACK BP-950G 0971B002AA Para camara Canon H1	Canon	BP-950G	S/N	119	Funcional	Estante de Baterias	
VPNPRO061	PRO-001	07/09/2023	(2) - Cargadrores de baterias Canon CA-900A	Canon	CA-900A	ME204573                               ME102555	119	Funcional	Estante de Baterias	
VPNPRO062	PRO-001	07/09/2023	(2) - Cargadrores de baterias Canon CA-920	Canon	CA-920	TL201250                               ML502024	119	Funcional	Estante de Baterias	Falta 1 cable de corriente
VPNPRO063	PRO-001	07/09/2023	(3) - Cargador De Batería Sony BC-U1 BP-U30/U35/U60/U70/U90/U100 FX6/EX1R/fx3/FS7/EX280/EX260 Cámara	Sony	BC-U1	12063000282                             10123002127                             14093003072	119	Funcional	Estante de Baterias	
VPNPRO193	Resp. 010	11/04/2023	"KIT SEMANERA #2" (1) Monitor Gamer Xzeal XZ4015-1 / Negro / 27" / 1MS / 165HZ / Full HD, y (1) Gabinete Acteck Kiruna II - Media Torre #2, (1) Teclado con mouse, (1) Panel de control SWITCHER #2, con (1) cable de poder de 1.5 M	Monitor: XZEAL REAL GAMING                                     Gabinete: ACTECK                                                       Switcher: TYST VIDEO	XZ4015-1                                       GM420                                TY-1500HD	X2401521092468                                              00233568004528	110	Bueno	Caja VMIX	
VPNPRO367		05/04/2024	Spliter de 4 puertos de alta velociad HDMI con audio	STARTECH	S1124HDMI2	MM0811XD00604	104			
VPNAUD004		08/09/2023	(KIT) Microfono receptor de mano con cable estereo, (1) cable cannon a 3.5, microfono y soporte de microfono	SONY	Microfono: UTX-M03 Receptor: URX-B03	102122                                            108718	118	Funcional	Se utilizó el cable estereo y cannon del VPNAUD007	
VPNAUD005		08/09/2023	(KIT) Microfono receptor de mano con cable estereo, (1) cable cannon a 3.5, microfono y soporte de microfono	SONY	Microfono: UTX-M03 Receptor: URX-B03	102125                                            109992	118	Funcional	Departamento de audio	
VPNAUD006		08/09/2023	(KIT) Microfono receptor de mano con cable estereo, (1) cable cannon a 3.5, microfono y soporte de microfono	SONY	Microfono: UTX-M03 Receptor: URX-B03	102749                                            114345	118	Funcional	Departamento de audio	
VPNAUD007		08/09/2023	(KIT) Microfono receptor de mano con cable estereo, (1) cable cannon a 3.5, microfono y soporte de microfono	SONY	Microfono: UTX-M03 Receptor: URX-B03	Mic: 102124 ,                                          Receptor: 112214	118	Dañado	Se utilizara para reparar VPNAUD001	No enciende
VPNAUD009		08/09/2023	(3) Transmisores Lavalier analogicos (2) micrófonos	SONY	UTX-B2	142053 , 117881 , 117880	118	Funcional	Bodega 1	Solo son 2 microfonos y uno de ellos no tiene malla protectora Y SOLO UNO TIENE BROCHE
VPNAUD010		08/09/2023	(4) Microfonos alambricos con esponja y bolsa/estuche	SHURE	SM58	S/N	118	Uno no tiene esponja	Bodega 1	
VPNPRO042	PRO-001	07/09/2023	(CAMARA 02 EX3) Sony PMW-EX3 XDCAM EX HD Camcorder	Sony	PMW-EX3	123167	119	Funcional	Bodega 1	
VPNPRO043	PRO-001	07/09/2023	(2) Control de Zoom para camara PMW-EX3	Libec                                             PG-F	ZC-9EX	S/N	119	Funcional	Bodega 1	KIT ESTUDIO #7
VPNPRO044	PRO-001	07/09/2023	2 (CAMARA 01 H1) XL H1A - Canon Camera	Canon	XL-H1A	4721220001 59	119	Funcional	Bodega 1	No le sirve el lente
VPNPRO047	PRO-001	07/09/2023	Control de Zoom para camara XL-H1A	Libec	ZC-3DV	S/N	119	Funcional	Bodega 1	
VPNPRO391			(12) Radios Negros (8) Radios Gris (4) Radios Naranjas	Midland	TX4S                               T51A	P2006078026 (1)      P2009130287 (2)    P1910012864(3)    P2009130275 (4)   P2006078094 (5)   P2009129138 (6)   P2009130277 (7)   02008078051 (8)     A1701059652 (9)    1701059652 (10)    a1701059649 (11)   a1701059651(12)	119			
VPNAUD011		08/09/2023	Microfono inalambrico con receptor y adaptador de Carga, stand para microfono y esponja	SHURE	BLX4 K12	3RK3099285	118	Funcional	Bodega 1	
VPNAUD012		08/09/2023	Microfono inalambrico con receptor y adaptador de Carga, stand para microfono y esponja	SURE	BLX4 K12	3RL1142116	118	Funcional	Bodega 1	
VPNAUD025		08/09/2023	Pantalla de 32"	HISENSE	32H3	3TE32G1229143104781	109	Funcional	Departamento de audio	
VPNPRO033	PRO-001	07/09/2023	(CAMARA #1) Sony PXW-320K XDCAM EX Camcorder w/16x Zoom & CBK-CE01, SONY CBK-VF01 viewfinder HD camera PMW-350 PMW-320	Sony	PMW-320                                 CBK-VF01	101899	119	Funcional	Bodega 1	PRODUCCIÓN
VPNPRO034	PRO-001	07/09/2023	LENTE FUJINON XS16x5.8A-XB8	Fujinon	A-XB8	B62400649	119	Funcional	Bodega 1	EN PRODUCCION ESTA EL LENTE DE LA CAMARA #6 DEL ESTUDIO
VPNPRO035	PRO-001	07/09/2023	VZGF Zoom Control	VariZoom	S/M	S/N	119	Funcional	Bodega 1	CAMARA PRODUCCIÓN #3
VPNPRO036	PRO-001	07/09/2023	Cable de Control de Enfoque	VariZoom	VZ-FCC	S/N	119	Funcional	Bodega 1	CAMARA PRODUCCIÓN #1
VPNPRO038	PRO-001	07/09/2023	LENTE FUJINON XS16x5.8A-XB8	Fujinon	A-XB8	B62406242	119	Funcional	Bodega 1	KIT CAMARA PRODUCCIÓN #4
VPNPRO041	PRO-001	07/09/2023	(2) Control de Zoom para camara PMW-EX3	Libec                                             PG-F	ZC-9EX	S/N	119	Funcional	Bodega 1	
VPNPRO049	PRO-001	07/09/2023	Sony BP L60A Battery Rebuild	Sony	BP-L60A	20046	102	Funcional	Estante de Baterias	
VPNPRO052	PRO-001	07/09/2023	Cargador de batería de iones de litio Sony BC-L70 Y fuente de poder para camaras	Sony	BC-L70	0109359 07Y	119	Funcional	Estante de Baterias	
VPNPRO064	PRO-001	07/09/2023	(4) - Neewer 6600mAh Li-ion Battery Replacement for Sony NP-F970 NP-F960 NP-F975 (Baterias No. 1, 2, 3 y 4)	Neewer	NP-F970	S/N	119	Funcional	Estante de Baterias	
VPNAUD031		08/09/2023	Microfono alambrico	SHURE	S/M	S/N	118	No funciona	Departamento de audio	Se harán pruebas
VPNPRO065	PRO-001	07/09/2023	(6) - Batería para videocámara Sony NP-F970 serie L la dcrvx2100, hdrfx1, hdrfx7, HD1000U & hvrz1u (Baterias No. 5, 6, 7, 8, 9 y 10)	Sony	NP-F970	S/N	119	Funcional	Estante de Baterias	Preguntar cuales no sirven
VPNPRO067	PRO-001	07/09/2023	(2) - Sony AC-VQ1051D Twin Battery Charger/AC Adapter for L-series Batteries - Digital Camera Warehouse	Sony	AC-VQ1051D	14083000352                 14083000339	119	Funcional	Estante de Baterias	
VPNPRO068	PRO-001	07/09/2023	KIT de lampara portatil, (1) cargador, (1) bateria, y (1) base para camara	LS Photography	S/M	S/N	119	Funcional	Estante de Baterias	
VPNPRO069	PRO-001	07/09/2023	KIT de lampara portatil, (1) cargador, (1) bateria, y (1) base para camara	LS Photography	S/M	S/N	119	Baja	Estante de Baterias	Hace tiempo se dio de baja la bateria
VPNPRO070	PRO-001	07/09/2023	(MONITOR #1) Kit de monitor LCD Field Monitor 7 pulgadas: (1) Monitor, (1) para sol, (1) adaptador de bateria, (1) fuente de poder con adaptador, (1) cable HDMI.	LILIPUT	LI663OP2	663PB7442C013	119	Funcional	Bodega 1	Sin adaptador de corriente a camara
VPNPRO071	PRO-001	07/09/2023	(MONITOR #2) Kit de monitor LCD Field Monitor 7 pulgadas: (1) Monitor, (1) para sol, (1) adaptador de bateria, (1) fuente de poder con adaptador, (1) cable HDMI.	LILIPUT	LI663OP2	663SA61417031	119	Funcional	Bodega 1	sin cable de corriente
VPNPRO072	PRO-001	07/09/2023	(MONITOR #3) Kit de monitor LCD Field Monitor 7 pulgadas: (1) Monitor, (1) para sol, (1) adaptador de bateria, (1) fuente de poder con adaptador, (1) cable HDMI.	LILIPUT	LI663OP2	663PB7442C031	119	Funcional	Bodega 1	Sin adaptador de corriente a camara
VPNPRO073	PRO-001	07/09/2023	(MONITOR #4) Kit de monitor LCD Field Monitor 7 pulgadas: (1) Monitor, (1) para sol, (1) adaptador de bateria, (1) fuente de poder con adaptador, (1) cable HDMI.	LILIPUT	LI663OP2	663PB61076013	119	Funcional	Bodega 1	
VPNPRO075	PRO-001	07/09/2023	(TRIPIE 2) Sistema de Tripie Libec, (1) Cabezal Modelo RH-45D y (2) Piernas Modelo RT-40RB, Con (2) brazos y chancla	Libec	RH-45D                                           RT-40RB	S/N	119	Funcional	Bodega 1	
VPNPRO076	PRO-001	07/09/2023	(TRIPIE 3) Sistema de Tripie Libec, (1) Cabezal Modelo RH-45R y (2) Piernas (1) Modelo RT-40RB, Con (2) brazos y chancla	Libec	RH-45R                                                RT-40RB	S/N	119	Funcional	Bodega 1	
VPNPRO077	PRO-001	07/09/2023	(TRIPIE 4) Sistema de Tripie Libec, (1) Cabezal Modelo RH-45R y (2) Piernas (1) Modelo RT-40RB, Con (2) brazos y chancla	Libec	RH-45R                                                RT-40RB	S/N	119	Funcional	Bodega 1	
VPNPRO078	PRO-001	07/09/2023	(TRIPIE 2) Sistema de Tripie Libec, (1) Cabezal Modelo RH-45D y (2) Piernas Modelo RT-40RB, Con (2) brazos y chancla	Libec	RH-45D                                                RT-40RB	S/N	119	Funcional	Bodega 1	
VPNPRO079	PRO-001	07/09/2023	(TRIPIE 6) Sistema de Tripie Vinten, (1) Cabezal, (2) Piernas, Con (1) brazo y chancla	Vinten	S/M	V4092-00860	119	Reutilizado	Bodega 1	Se remplazaron las patas, y se utilizó el cabezal para otro tripie
VPNPRO080	PRO-001	07/09/2023	Kit de iluminación RGB (3) Luces RGB (3) Tripies (3) Cargadores (1) Control (1) Yoyo (1) Brazo Extensor	Newtek	BH-20RGB-2.4G	S/N	119	Funcional	Bodega 1	Uno de los tripies se intercabió con el tripie de Gerardo ya que presentó una falla en el tornillo para embonar
VPNPRO081		07/09/2023	Kit de Iluminacion LED Blancas (3) Luces led (3) Tripies (3) Cargadores	DraCast	DRSP-5008	VPNPRO081	119	Funcional		En Re paracion eliminador de corriente y pedestal vencido
VPNPRO082	PRO-001	07/09/2023	KIT LUCES LED (3) luces LED Dracast Complex High Color Rendering Index SMD Max Bi-Color On-Camera, Blue (DR-CAML-MaxSB Combo)	DraCast	DR-CAML-MAXB	S/N	119	Funcional	Bodega 1	
VPNPRO083	PRO-001	07/09/2023	(8) - Radios de comunicacion	KenWood	TK-3202	70500216 - 60101672  - 71201344   60101679  -  71008106  -  60101680  91107616  - 71204251	119	Funcional	Bodega 1	1 Radio de baja
VPNPRO084	PRO-001	07/09/2023	(5) - Radios de Comuniacion	KenWood	TK-3302-1	A8A12454  -  00202437             A8A09149   -   B1406738                 81102649	119	baja	Bodega 1	1 Radio de baja,
VPNPRO085	PRO-001	07/09/2023	(9) - Diademas de Comunacacion Dobles	Earthec	S/M	S/N	119		Bodega 1	Anteriormente 10 pero 1 Esta quebrada
VPNPRO086	PRO-001	07/09/2023	(3) - Diademas de Comuniacion Sencilla	Earthec	S/M	S/N	119	Funcional	Bodega 1	
VPNPRO087	PRO-001	07/09/2023	(8) - Cargadores para Radios de comunicación	KenWood	KSC-35	S/N	119	Funcional	Bodega 1	
VPNPRO088		07/06/2025	Computadora All in One Lenovo IdeaCentre 300-22ACL, (1) Teclado (1) Mouse	Lenovo	F0BW	P901L1UZ	104	Funcional	Produccion	
VPNPRO089	PRO-001	07/09/2023	Libec DL5RB Camera Tripod Dolly - Cameragrip	Libec	DL-5RB	S/N	119	Funcional	Bodega 1	
VPNPRO090	PRO-001	07/09/2023	Libec DL5RB Camera Tripod Dolly - Cameragrip	Libec	DL-5RB	S/N	119	Funcional	Bodega 1	
VPNPRO091	PRO-001	07/09/2023	Libec DL5RB Camera Tripod Dolly - Cameragrip	Libec	DL-5RB	S/N	119	Funcional	Bodega 1	
VPNPRO092	PRO-001	07/09/2023	(2) - Balanceador	Lastolite	S/M	S/N	119	Funcional	Bodega 1	
VPNPRO093	Resp. 009	11/03/2023	(10) - Conector Mecanico SC-SC SIMPLET pata carrete de fibra optica	LINKEDPRO	EFUNIONSC	S/N	104	Bueno	Bodega 1	
VPNPRO094	Resp. 006	04/04/2023	HDMI Splitter de 4 Puertos	KANEXPRO	SP-HDIX44K	S/N	110	Bueno	Mochila Roja	
VPNPRO095	Resp. 006	04/04/2023	Splitter Hdmi 1x2 Divisor De Señal 2k 4k 3d Conecta 2 Tv - ELE-GATE	ELE-GATE	HDMI 1X2	S/N	110	Bueno	Mochila Roja	Darla de baja porque no funciona
VPNPRO096	Resp. 006	04/04/2023	(1) Capturadora de video - (1) Adaptador video UNISHEEN 5.8x4x2.1" 1080P USB 3.0	UNISHEEN	VC32005	202030 138912529	110	Bueno	Mochila Roja	baja
VPNAUD036		27/02/2024	Snake medusa de 40 canales 32 entradas y 8 salidas, longitud de 30 metros.	PROEL	EBN3208	S/N	118	Funcional	Bodega 1	
VPNPRO097	Resp. 006	04/04/2023	(1) Capturadora de video - (1) Adaptador video UNISHEEN 5.8x4x2.1" 1080P USB 3.0	UNISHEEN	VC32005	202030 13812499	110	Bueno	Mochila Roja	baja
VPNAUD026		08/09/2023	Microfono boom completo, con esponja y caña	Neewer	VP89	S/N	109		Departamento de audio	
VPNPRO098	Resp. 006	04/04/2023	Cable USB miniDisplay a HDMI	S/M	S/M	S/N	110	Bueno	Mochila Roja	
VPNPRO099	Resp. 006	04/04/2023	Switches y Conversores - Switch TP-Link TL-SG1008D, 8 Puertos 10/100/1000 Mbps	TP-LINK	TL-SG1008D	S/N	110	Bueno	Mochila Roja	
VPNPRO100	Resp. 006	04/04/2023	Mouse para computadora	S/M	S/M	S/N	110	Bueno	Mochila Roja	
VPNPRO101	Resp. 006	04/04/2023	(3) LinkBand Audio Video Capture Cards HDMI a USB 2.0 1080P, grabación a través de DSLR, videocámara, cámara de acción para transmisión en vivo	S/M	S/M	S/N	110	Bueno	Mochila Roja	
VPNPRO102	Resp. 006	04/04/2023	Convertidor Hdmi A Rca Hdmi2av	VIMI	HDMI2AV	S/N	110	Bueno	Mochila Roja	
VPNPRO103	Resp. 006	04/04/2023	Convertidor de CANON a PLUG 1/4	S/M	S/M	S/N	110	Bueno	Mochila Roja	
VPNPRO104	Resp. 006	04/04/2023	Hub USB Tipo C Spectra UH 62C 4 puertos Negro	SPECTRA	UH-62C	85684	110	Bueno	Mochila Roja	
VPNPRO105	Resp. 006	04/04/2023	Cople HDMI a HDMI	S/M	UGREEN	S/N	110	Bueno	Mochila Roja	
VPNPRO106	Resp. 006	04/04/2023	(1) Adaptador Rca A Plug 1/4	S/M	S/M	S/N	110	Bueno	Mochila Roja	
VPNPRO107	Resp. 006	04/04/2023	Lexar Professional Tarjeta SDXC UHS-II de 2000 x 128 GB, hasta 300 MB/s de Lectura, para cámaras DSLR, cámaras de vídeo de Calidad de Cine (LSD2000128G-BNNNU)	LEXAR	L030671	S/N	110	Bueno	Mochila Roja	
VPNPRO108	Resp. 006	04/04/2023	Consola de audio de 2 canales	STEREN	MIX-150	69301846	110	Bueno	Mochila Roja	
VPNPRO109	Resp. 006	04/04/2023	Extension de USB	S/M	S/M	S/N	110	Bueno	Mochila Roja	
VPNPRO110	Resp. 006	04/04/2023	Extencion de USB	S/M	S/M	S/N	110	Bueno	Mochila Roja	
VPNPRO111	Resp. 006	04/04/2023	Extencion de USB	UGREEN	S/M	S/N	110	Bueno	Mochila Roja	
VPNPRO112	Resp. 006	04/04/2023	Micro Convertidor SDI a HDMI	BlackMagic Desing	SDI a HDMI	7174265	110	Bueno	Mochila Roja	
VPNPRO113	Resp. 006	04/04/2023	Micro Convertidor SDI a HDMI 3G	BlackMagic Desing	SDI a HDMI	7546795	110	Bueno	Mochila Roja	
VPNPRO114	Resp. 006	04/04/2023	AV-Cables 3G/6G HD SDI BNC RG59 Cable Belden 1505A - Azul	BELDEN	SDI	S/N	110	Bueno	Mochila Roja	
VPNPRO115	Resp. 006	04/04/2023	(2) Cables de Ethernet	S/M	S/M	S/N	110	Bueno	Mochila Roja	
VPNPRO116	Resp. 006	04/04/2023	Peavey USB-P Interfaz de Audio y grabación USB a Salidas XLR	PEAVEY	USB-P	ODBIK216225	110	Bueno	Mochila Roja	
VPNPRO120	Resp. 006	04/04/2023	Cable de Audio CANON a PLUG 3.5	S/M	S/M	S/N	110	Bueno	Mochila Roja	
VPNPRO121	Resp. 006	04/04/2023	Cable de Audio RCA a RCA	S/M	S/M	S/N	110	Bueno	Mochila Roja	
VPNPRO122	Resp. 010	04/04/2023	Capturadora de video - Adaptador video UNISHEEN 5.8x4x2.1" 1080P USB 3.0	UNISHEEN	VC32005	202030 13812534	119	BAJA	Mochila Plata	Obsoletas
VPNPRO123	Resp. 010	04/04/2023	Capturadora de video - Adaptador video UNISHEEN 5.8x4x2.1" 1080P USB 3.0	UNISHEEN	VC32005	202030 13812503	119	Baja	Mochila Plata	Obsoletas
VPNPRO125	Resp. 010	04/04/2023	Mouse para computadora	S/M	S/M	S/N	109	Baja	Mochila Plata	Dejó de funcionar
VPNPRO126	Resp. 010	04/04/2023	HDMI Splitter 4 Puertos	STEREN	BOS-304	S/N	109	Bueno	Mochila Plata	
VPNPRO127	Resp. 010	04/04/2023	Switches y Conversores - Switch TP-Link TL-SG1008D, 8 Puertos 10/100/1000 Mbps	TP-LINK	TL-SG1008D	21634810 01735	109	Bueno	Mochila Plata	
VPNPRO130	Resp. 010	04/04/2023	Extencion de USB	UGREEN	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO131	Resp. 010	04/04/2023	Extencion de USB	S/M	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO132	Resp. 010	04/04/2023	Extension de USB	S/M	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO133	Resp. 010	04/04/2023	(3) LinkBand Audio Video Capture Cards HDMI a USB 2.0 1080P, grabación a través de DSLR, videocámara, cámara de acción para transmisión en vivo	S/M	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO134	Resp. 010	04/04/2023	Convertidor Hdmi A Rca Hdmi2av	VIMI	HDMI2AV	S/N	109	Bueno	Mochila Plata	
VPNPRO135	Resp. 010	04/04/2023	Hub USB Tipo C Spectra UH 62C 4 puertos PC Laptop Negro	SPECTRA	UH-62C	S/N	109	Bueno	Mochila Plata	
VPNPRO136	Resp. 010	04/04/2023	(2) Adaptador Rca A Plug 1/4	S/M	S/M	S/N	110	Bueno	Mochila Plata	No se encontro
VPNPRO137	Resp. 010	04/04/2023	(2) Cople HDMI a HDMI	S/M	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO138	Resp. 010	04/04/2023	Convertidor de CANON a PLUG 3/4	S/M	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO139	Resp. 010	04/04/2023	Audífonos manos libres con control de volumen	STEREN	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO140	Resp. 010	04/04/2023	(4) Cables de Ethernet	S/M	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO141	Resp. 010	04/04/2023	Consola de audio de 2 canales	STEREN	MIX-150	69301846	109	Bueno	Mochila Plata	
VPNPRO142	Resp. 010	04/04/2023	Micro Convertidor SDI a HDMI	BlackMagic Desing	SDI a HDMI	7174251	109	Bueno	Mochila Plata	
VPNPRO143	Resp. 010	04/04/2023	Micro Convertidor SDI a HDMI 3G	BlackMagic Desing	SDI a HDMI	7546809	109	Bueno	Mochila Plata	
VPNPRO144	Resp. 010	04/04/2023	Peavey USB-P Interfaz de Audio y grabación USB a Salidas XLR	PEAVEY	USB-P	ODBJM303675	109	Bueno	Mochila Plata	
VPNPRO145	Resp. 010	04/04/2023	(10) Cables HDMI variados	S/M	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO146	Resp. 010	04/04/2023	Cable de Audio CANON a CANON	S/M	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO147	Resp. 010	04/04/2023	(2) Cable de Audio CANON a PLUG 3/4	S/M	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO148	Resp. 010	04/04/2023	Cable de Audio CANON a PLUG 3/4	S/M	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO149	Resp. 010	04/04/2023	Cable de Audio RCA a RCA	S/M	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO150	Resp. 010	04/04/2023	Adaptador de audio CANON a RCA	S/M	S/M	S/N	109	Bueno	Mochila Plata	Estudio TV
VPNPRO151	Resp. 010	04/04/2023	Cable de Audio CANON a PLUG 3.5	S/M	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO152	Resp. 006	04/04/2023	Laptop Del #2 Inspiron G7 7700 Gaming 17.3" Intel Core i5 10300H Disco duro 512 GB SSD Ram 8GB Winsows 10 Home, Mause y cargador	DELL	G7 7700	39028513718	110	Bueno	Estante de Baterias	
VPNPRO066	PRO-001	07/09/2023	(1) - Bateria 7.5V 5200mHA LI-ION	---	S/M	S/N	119	Funcional	Estante de Baterias	Eran 2 baterias, 1 Ya no sirve y se dio de baja
VPNPRO153	Resp. 010	04/04/2023	Laptop Dell #3 Inspiron G7 7700 Gaming 17.3" Intel Core i5 10300H Disco duro 512 GB SSD Ram 8GB Winsows 10 Home, Mause y cargador	DELL	G7 7700	6Q5HHHX2	109	Bueno	Estante de Baterias	
VPNPRO154	Resp. 010	11/04/2023	Laptop notebook con cargador	ASUS	L410M	S/N	119	Bueno	Mochilas semanera	Checarsi la tengo yo o pedro
VPNPRO155		22/12/2025	(2) Fuente de poder para cámara	SONY	AC-DN10	02528914Z            02529014Z	119	Bueno	KIT CAMARA #2 Y #3	
VPNPRO156	Resp. 010	11/04/2023	(2) Cable Thunderbolt a HDMI (1) corto y (1) largo	BELKING Y UPGROWN	S/M	S/N	203	Bueno	Dirección	
VPNPRO158	Resp. 010	11/04/2023	Distribuidor splitter con cargador	S/M	S/M	S/N	109	Bueno	Mochilas semanera	
VPNPRO159	Resp. 010	11/04/2023	(3) Extensores USB	UGREEN Y GIGAWARE	S/M	S/N	109	Bueno	Mochilas semanera	
VPNPRO160	Resp. 010	11/04/2023	Adaptador USB-C a RED "60"	S/M	S/M	S/N	109	Bueno	Mochilas semanera	
VPNPRO161	Resp. 010	11/04/2023	Adaptador USB-C A Thunderbolt	MAC	S/M	S/N	109	Bueno	Mochilas semanera	
VPNPRO162	Resp. 010	11/04/2023	Adaptador display port	S/M	S/M	S/N	109	Bueno	Mochilas semanera	No se encontro
VPNPRO163	Resp. 010	11/04/2023	Apuntador inalambrico para presentaciones	TARGUS	N2953	S/N	109	Bueno	Mochilas semanera	
VPNPRO164	Resp. 010	11/04/2023	Apuntador inalambrico para presentaciones	LOGTECH	PRESENTADOR	1829WD0D5558	109	Bueno	Mochilas semanera	
VPNPRO165	Resp. 010	11/04/2023	Cable DVI a HDMI	MANHATTAN PRO	S/M	S/N	201	No funciona	Mochilas semanera	no se encontro
VPNPRO166	Resp. 010	11/04/2023	Adaptador USB a RED	S/M	S/M	S/N	109	Bueno	Mochilas semanera	No sirve
VPNPRO167	Resp. 010	11/04/2023	(6) Cable Mini HDMI a HDMI	S/M	S/M	S/N	109	Bueno	Mochilas semanera	
VPNPRO168	Resp. 010	11/04/2023	(2) Cable USB a USB-B macho	S/M	S/M	S/N	109	Bueno	Mochilas semanera	Falló de 1
VPNPRO169	Resp. 010	11/04/2023	Cable thunderbolt	STARTECH	S/M	S/N	109	Bueno	Mochilas semanera	
VPNPRO170	Resp. 010	11/04/2023	Multicontacto	STEREN	S/M	S/N	109	Bueno	Mochilas semanera	
VPNPRO171	Resp. 010	11/04/2023	Cable USB a USB-B	S/M	S/M	S/N	109	Bueno	Mochilas semanera	
VPNPRO172	Resp. 010	11/04/2023	Cable display port	S/M	S/M	S/N	109	Bueno	Mochilas semanera	
VPNPRO173	Resp. 010	11/04/2023	RCA a PLUG 3/4	S/M	S/M	S/N	109	Bueno	Mochilas semanera	
VPNPRO180	Resp. 010	11/04/2023	Adaptador RCA a CANON	S/M	S/M	S/N	109	Bueno	Caja Splitter	
VPNPRO183	Resp. 010	11/04/2023	Splitter de 5 HDMI de 5 puertos 1x4 con cargador	STEREN	BOS-304	S/N	109	No funciona	Caja Splitter	Baja
VPNPRO189	Resp. 010	11/04/2023	Cable de RED de medio metro	S/M	S/M	S/N	109	Bueno	Caja Splitter	
VPNPRO190	Resp. 010	11/04/2023	Mezcladora de 4 canales Allen and Heath ZEDi-8	ALLEN	ZEDI.8	ZI8X-959134	118	Bueno	Caja Splitter	
VPNPRO191	Resp. 010	11/04/2023	Adaptador CANON a PLUG 3/4	S/M	S/M	S/N	109	Bueno	Caja Splitter	
VPNPRO194	Resp. 010	11/04/2023	Teclado para juegos RGB	PRODIGY LOGTECH	G213	2032SCK0B9T8	109	Bueno	Caja VMIX	
VPNPRO195	Resp. 010	11/04/2023	Mouse con cable	HP	MODGUO	S/N	109	Bueno	Caja VMIX	
VPNPRO196	Resp. 010	11/04/2023	Panel de contro TriCaster con cable	NEWTEK	LC-11	H1AF19612710983	109	Bueno	Caja VMIX	
VPNPRO197	Resp. 010	11/04/2023	Cable USB a USB-B	S/M	S/M	S/N	109	Bueno	Caja VMIX	
VPNPRO198	Resp. 010	11/04/2023	(2) Display port a HDMI con adaptador	S/M	S/M	S/N	109	no funciona	Caja VMIX	baja
VPNPRO199	Resp. 010	11/04/2023	Monitor Curvo pantalla LED 32├ó┬Ç┬Ø con cable	SAMSUNG	C32F391FWL	0AF3HCPN900076V	109	Bueno	Caja VMIX	
VPNPRO200	Resp. 014		SSD SanDisk Ultra 3D, 250GB, SATA III, 2.5'', 7mm, SDSSDH3-250G-G25	SanDisk	SDSSDH3	21107B803965	119	Bueno	Gabinete Produccion	
VPNPRO201	Resp. 014		SSD SanDisk Ultra 3D, 250GB, SATA III, 2.5'', 7mm, SDSSDH3-250G-G25	SanDisk	SDSSDH3	210745800333	119	Bueno	Gabinete Produccion	
VPNPRO202	Resp. 014		SSD SanDisk Ultra 3D, 250GB, SATA III, 2.5'', 7mm, SDSSDH3-250G-G25	SanDisk	SDSSDH3	210202A00196	119	Bueno	Gabinete Produccion	
VPNPRO203	Resp. 014		SSD SanDisk Ultra 3D, 250GB, SATA III, 2.5'', 7mm, SDSSDH3-250G-G25	SanDisk	SDSSDH3	21107B801833	119	Bueno	Gabinete Produccion	
VPNPRO204	Resp. 014		Lector de discos duro SATA	NEWERTECH	Voyager S3	1403014138	119	Bueno	Gabinete Produccion	
VPNPRO205	Resp. 014		Lector de discos duro SATA	NEWERTECH	Voyager S3		119	Bueno	Gabinete Produccion	
VPNPRO207	Resp. 014		Decimator Md-hx Convertidor Cruzado Hdmi / Sdi En Miniatura (COMPLETO)	DECIMATOR	MD-HX	CLD15468	119	Bueno	Gabinete Produccion	
VPNPRO208	Resp. 014		Decimator Md-hx Convertidor Cruzado Hdmi / Sdi En Miniatura (COMPLETO)	DECIMATOR	MD-HX	CLD15469	119	Bueno	Gabinete Produccion	
VPNPRO209	Resp. 014		Decimator Md-hx Convertidor Cruzado Hdmi / Sdi En Miniatura (FALTA HDMI)	DECIMATOR	MD-HX	CLD15467	119	Bueno	Gabinete Produccion	Respaldo para piezas
VPNPRO210	Resp. 014		(6) Cable extensor USB de repetición activa 2.0 y 3.0 con (6) cables micro USB	LMYAN G	B08HZF31B2	S/N	119	Bueno	Gabinete Produccion	
VPNPRO211	Resp. 014		Disco Duro Externo Seagate 1 TB STEA1000400	SEAGATE	SRD0NF1	NA87J219	119	Bueno	Gabinete Produccion	
VPNPRO182	Resp. 010	11/04/2023	(2) Cable HDMI a HDMI	UGREEN	S/M	S/N	109	No funcionan	Caja Splitter	Baja (no funcionan)
VPNPRO212	Resp. 014		Lector de tarjetas 64 en 1	OFFICE MAX	62175	S/N	119	Bueno	Gabinete Produccion	
VPNCOM008	Resp.24	14/01/2025	Laptop HP Elitebook 845 G7 Notebook PC, con cargador, mousepad, y mouse inalambrico	HP	Elitebook 845 G8	S/N,  WECJN0AR449Z1 (cargador)	122.0	Activo	Ventas	Contaseña: Vproventas
VPNPRO213	Resp. 014		Cable Atomos Coiled Right-Angle Micro-HDMI to HDMI 30CM Cable ATOMCAB007	ATOMOS	ATOMCAB007	S/N	119	Bueno	Gabinete Produccion	
VPNPRO214	Resp. 014		Cable USB 2.0 a USB tipo C 3Metros trensado	URGEEN	30883	S/N	119	Bueno	Gabinete Produccion	
VPNPRO215	Resp. 014		Cable micro HDMI a HDMI 4K de 6 pies, carcasa de aluminio trenzada de alta velocidad 18 Gbps, 4K 60Hz HDR 3D ARC compatible con GoPro Hero 7, 6, 5,	URGEEN	10600	S/N	119	Bueno	Gabinete Produccion	
VPNPRO216	Resp. 014		Cable USB 2.0 a USB tipo C 3Metros trensado	URGEEN	30883	S/N	119	Bueno	Gabinete Produccion	
VPNPRO217	Resp. 014		Cable HDMI a Micro HDMI	GOPRO	HDMI a Micro HDMI	S/N	119	Bueno	Gabinete Produccion	
VPNPRO218	Resp. 014		GoPro HERO8 Black - Cámara de acción Impermeable con Pantalla táctil 4K Ultra HD Video 12MP Fotos 1080p Live Streaming estabilización (Camara, Carcasa, Adaptador, Bateria, Adaptador Corriente)	GOPRO	Hero Black 8	C3331351743533	119	Bueno	Gabinete Produccion	
VPNPRO219	Resp. 014		GoPro HERO8 Black - Cámara de acción Impermeable con Pantalla táctil 4K Ultra HD Video 12MP Fotos 1080p Live Streaming estabilización (1) Camara, (1) Carcasa, (1) Adaptador, (1) Bateria, (1) Adaptador Corriente, (1) Brazo adaptador)	GOPRO	Hero Black 8	C3331352703554	119	Bueno	Gabinete Produccion	
VPNPRO220	Resp. 014		Cámara para Go Pro lente marco protector parasol marco para Gopro Hero 4 3 + 3 accesorios de Cámara de Acción (1) Camara, (1) Carcasa, (1) Bateria, (1) Adaptador de corriente, (1) USB MINI, (1) Cable hdmi A micro HDMI	GOPRO	Hero Black 4	C3121125213200	119	Bueno	Gabinete Produccion	
VPNPRO234	Resp. 014		Regulador de Voltaje 1350 V 120 V Smartbitt AVR1350 SBAVR1350	SMARTBIT	AVR1350	S/N	119	Bueno	Switcher Grande	
VPNPRO235	Resp. 014		(2) Cables Ethernet	S/M	S/M	S/N	119	Bueno	Switcher Grande	
VPNPRO236	Resp. 014		(4) Cables SDI a SDI	S/M	S/M	S/N	119	Bueno	Switcher Grande	
VPNPRO237	Resp. 014		(2) Cables CANON a CANON	NEUTRONIK	S/M	S/N	119	Bueno	Switcher Grande	
VPNPRO238	Resp. 014		Gator G-PRO-12U-19 12-Space Rotationally Molded Rack	G-PRO-12U-19 12	GA12RMRC	S/N	119	Bueno	Switcher Grande	
VPNPRO239	Resp. 014		Blackmagic ATEM 1 M/E Broadcast Switcher Panel - BMD	BlackMagic Desing	SWPANEL1ME	2314566	119	Bueno	Switcher Mediano	
VPNPRO240	Resp. 014		Monitores Blackmagic SmartScope Duo 4K 2	BlackMagic Desing	HDL-SMTWSCOPEDUO4K2	2885144	119	Bueno	Switcher Mediano	
VPNPRO241	Resp. 014		Blackmagic Design Hyperdeck Studio 2 (Gravadoras de Video)	BlackMagic Desing	Hyperd/st2	S/N	119	Bueno	Switcher Mediano	
VPNPRO242	Resp. 014		Blackmagic Design ATEM Production Studio 4K Live Switcher	BlackMagic Desing	ATEM	2213354	119	Bueno	Switcher Mediano	
VPNPRO243	Resp. 014		(15) Amp Power Supply Power Strip with 1800VA Rack Mountable 9 Outlets	PYLE	PDBC70	S/N	119	Bueno	Switcher Mediano	
VPNPRO245	Resp. 014		Laptop para switcher, con cargador	DELL	TTIFJA00	3536832	119	Bueno	Switcher Mediano	
VPNPRO246	Resp. 014		Laptop Dell Inspiron 15 7559 - Core i7-6700HQ (Negra)	DELL	INSPIRION 15	11395824338	119	Bueno	Switcher Mediano	
VPNPRO247	Resp. 014		Blackmagic ATEM Television Studio Switcher	BlackMagic Desing	SWATEMTVSTU - BMD	1256632	119	Bueno	Switcher Chico	
VPNPRO248	Resp. 014		Blackmagic Design Hyperdeck Studio 2 (Gravadoras de Video)	BlackMagic Desing	Hyperd/st2	2372057	119	Bueno	Switcher Chico	
VPNPRO249	Resp. 014		Smart Video Buff 12x12	BlackMagic Desing	BMD-VHUBSMTCS6G1212	7174778	119	Bueno	Switcher Chico	
VPNPRO250	Resp. 014		DISCO DURO 6TB	SAEGATE	6TB	NA8TVZPG	119	Bueno	Escritorio Manuel	
VPNPRO251	Resp. 014		DISCO DURO 8TB	SAEGATE	8TB	NA9R6LKJ	119	Bueno	Escritorio Manuel	
VPNPRO252	Resp. 014		Computadora Armada (Monitor NOC, CPU, Teclado, mouse Bocinas)	Armada	Armada	ACJF79A002988                                                     088416319709	119	Bueno	Escritorio Manuel	
VPNPRO253	Resp. 009		Blackmagic Mini Converter SDI Distribution 4K	BlackMagic Desing	CONVMSDIDA 4K	8242617	119	Bueno	Bodega 1	
VPNPRO254	Resp. 009		Blackmagic Mini Converter SDI Distribution 4K	BlackMagic Desing	CONVMSDIDA 4K	8242311	110	Bueno	Bodega 1	
VPNPRO255	Resp. 009		Blackmagic Design - Conmutador ATEM Mini HDMI de transmisión en vivo	BlackMagic Desing	ATEM Mini	8162048	109	Bueno	Bodega 1	
VPNPRO256	Resp. 009		Extensor ultra HD HDMI 4K@60Hz con IR; Distancia de 30 metros	TEPCOM TITANIUM	TT672	SKH20050259	104	Funcional	Bodega externa	Se almaceno en la bodega externa
VPNPRO257	Resp. 009		Extensor ultra HD HDMI 4K@60Hz con IR; Distancia de 30 metros	TEPCOM TITANIUM	TT672	SKG20050264	101	Bueno	Bodega 1	Se estan usando para extender la pantalla de las camaras
VPNPRO258	Resp. 009		Blackamgic Micro Converter BiDirectional SDI/HDMI wPSU 12G	BlackMagic Desing	SDI/HDMI wPSU 12G	5040186	110	Bueno	Bodega 1	
VPNPRO259	Resp. 009		Blackamgic Micro Converter BiDirectional SDI/HDMI wPSU 12G	BlackMagic Desing	SDI/HDMI wPSU 12G	5040163	109	Bueno	Bodega 1	
VPNPRO260	Resp. 009		Blackmagic Design SDI a HDMI Micro Converter, con Fuente de alimentación	BlackMagic Desing	SDI a HDMI Micro Converter	7041439	104	Bueno	Bodega 1	
VPNPRO261	Resp. 009		Blackmagic Design SDI a HDMI Micro Converter, con Fuente de alimentación	BlackMagic Desing	SDI a HDMI Micro Converter	7041518	109	Bueno	Bodega 1	Caja en cabina de estudio
VPNPRO264	Resp. 010	04/11/2023	Mini splitter HDMI 1x2 con cargador	ELE-GATE	S/M	S/N	109	Bueno	Mochila semanera	no se escontro
VPNPRO265	Resp. 009	04/11/2023	Mini splitter HDMI 1x2 con cargador	ELE-GATE	S/M	S/N	110	Bueno	Mochila semanera	no se encontro
VPNPRO266	Resp. 009	04/11/2023	Mini convertidor SDI a HDMI 4k	BlackMagic Desing	Mini Converter	S/N	104	Bueno	Bodega 1	
VPNPRO267	Resp. 009	04/11/2023	Mini convertidor SDI a HDMI 4k	BlackMagic Desing	Mini Converter	2362479	104	Bueno	Estudio TV	
VPNCOM010	Resp.22		Bolso Maletín Negro				121.0	Activo	Ventas	
VPNPRO244	Resp. 014		(3) Cables SDI a SDI	S/M	S/M	S/N	119	Bueno	Switcher Mediano	
VPNPRO268	Resp. 009	04/11/2023	Mini convertidor HDMI a SDI 4k con cargador	BlackMagic Desing	Mini Converter	2258436	104	Bueno	Bodega 1	
VPNCOM009	Resp.24		Bolso Maletín Negro				121.0	Activo	Ventas	
VPNPRO269	Resp. 009	04/11/2023	Mini convertidor HDMI a SDI 4k con cargador	BlackMagic Desing	Mini Converter	1330239	104	Bueno	Bodega 1	
VPNPRO270	Resp. 009	04/11/2023	Mini convertidor SDI a ANALOGO 4k con cargador	BlackMagic Desing	Mini Converter	2360529	104	Bueno	Bodega 1	
VPNPRO278	Resp. 009	04/11/2023	(10) Jumper de fibra sencillos	LINKEDPRO	LPFOLCUSCA03	S/N	104	Bueno	Bodega 1	
VPNPRO279	Resp. 009		(10) Adaptador de bateria para fibra optica	S/M	S/M	S/N	104	Bueno	Bodega 1	
VPNPRO280	Resp. 009		Convertidor de fibra optica 12 G con cargador y adaptador	Black magic design	S/M	7087276	104	Bueno	Bodega 1	
VPNPRO281	Resp. 009		Convertidor de fibra optica 12 G con cargador y adaptador	Black magic design	S/M	6037375	104	Bueno	Bodega 1	
VPNPRO282	Resp. 009		Convertidor de fibra optica 12 G con cargador y adaptador	Black magic design	S/M	7087344	104	Bueno	Bodega 1	
VPNPRO286	Resp. 009		Convertidor de fibra optica 12 G con cargador y adaptador	Black magic design	S/M	7087222	104	Bueno	Bodega 1	
VPNPRO287	Resp. 009		Convertidor de fibra optica 12 G con cargador y adaptador	Black magic design	S/M	7087212	104	Bueno	Bodega 1	
VPNPRO288	Resp. 009		Convertidor de fibra optica 12 G con cargador y adaptador	Black magic design	S/M	6037376	104	Bueno	Bodega 1	
VPNPRO289	Resp. 009		Convertidor de fibra optica 12 G con cargador y adaptador	Black magic design	S/M	6038519	104	Bueno	Bodega 1	
VPNPRO290	Resp. 009		Convertidor de fibra optica 12 G con cargador y adaptador	Black magic design	S/M	7087270	104	Bueno	Bodega 1	
VPNPRO291	Resp. 009		Interruptor HDMI de 3 dispositivos, uso con TV inteligente 4K 1080p 30 FPS, Ultra HD, HDCP 1.4	Philips	SWV9283A/27	S/N	104	Funcional	Bodega externa	Se almaceno en la bodega externa
VPNPRO292	Resp. 009		Interruptor HDMI de 3 dispositivos, uso con TV inteligente 4K 1080p 30 FPS, Ultra HD, HDCP 1.4	Philips	SWV9283A/28	S/N	104	Funcional	Bodega externa	Se almaceno en la bodega externa
VPNPRO297	Resp. 009		Selector HDMI de 3 puertos	BINARY	B-220-HDSWTCH3X1	ST1603036603371D	104	Funcional	Bodega externa	Se almaceno en la bodega externa
VPNPRO298	Resp. 009		Wireless HDMI Transmitter and Receiver	HDMI WIRELESS	HDCX001 6MI	20201118212	104	Funcional	Bodega externa	Se almaceno en la bodega externa
VPNPRO299	Resp. 009		Escalador digital de video HDMI	KRAMER Electronics	VP-425	12140844900018	104	Funcional	Bodega externa	Se almaceno en la bodega externa
VPNPRO300	Resp. 009		Escalador digital de video HDMI	KRAMER Electronics	VP-425	12140844900021	104	Funcional	Bodega externa	Se almaceno en la bodega externa
VPNPRO301	Resp. 009		Grafico de video HDTV computadora HDMI	KRAMER Electronics	VP-426	8140151600807	104	Funcional	Bodega externa	Se almaceno en la bodega externa
VPNPRO302	Resp. 009		Splitter HDMI de 4 puertos 1x4 con CAT5E	KANEXPRO	HD4PSPE	cos2713050006	104	Funcional	Bodega externa	Se almaceno en la bodega externa
VPNPRO303	Resp. 009		Splitter HDMI de 2 puertos 1x2 con CAT5E	KANEXPRO	HD2PSPE	COS2713050007	104	Funcional	Bodega externa	Se almaceno en la bodega externa
VPNPRO304	Resp. 009		Transmisor de señal sin limites	TERADEK	VIDIU	24516261	104	Funcional	Bodega externa	Se almaceno en la bodega externa
VPNPRO305	Resp. 009		Convertidor HDMI	STEREN	208-150	S/N	104	Bueno	Bodega externa	
VPNPRO306	Resp. 009		Splitter SDI de 3 puertos	KRAMER Electronics	VM-3VN	5100137700119	104	Funcional	Bodega externa	Se almaceno en la bodega externa
VPNPRO307	Resp. 009		Splitter SDI de 4 puertos	KRAMER Electronics	123VXL	309094348	104	Funcional	Bodega EXTERNA	Se almaceno en la bodega externa
VPNPRO308	Resp. 009		Splitter SDI de 4 puertos	KRAMER Electronics	123VXL	3010943523	104	Funcional	Bodega EXTERNA	Se almaceno en la bodega externa
VPNPRO309	Resp. 009		Splitter SDI de 4 puertos	KRAMER Electronics	123VXL	3090943542	104	Funcional	Bodega EXTERNA	Se almaceno en la bodega externa
VPNPRO310	Resp. 009		Splitter SDI de 3 puertos	KRAMER Electronics	VM-3VN	5100137700198	104	Funcional	Bodega EXTERNA	Se almaceno en la bodega externa
VPNPRO311	Resp. 009		Splitter SDI de 3 puertos	KRAMER Electronics	VM-3VN	5100137700140	104	Funcional	Bodega EXTERNA	Se almaceno en la bodega externa
VPNPRO313	Resp. 009		Amplificador con antena	STEREN	BOS-800	PO29432	104	Bueno	Bodega Externa	
VPNPRO314	Resp. 009		Sistema de prueba para cables multiple	CONNECT	MCT-7	S/N	104	Bueno	Bodega 1	
VPNPRO315			Laptop con cargador y mouse para teleprompter	DELL/ Logitesh	INSPIRION 15 5100	42783555134	105	Bueno	Bodega 1	Falta mouse
VPNPRO316	Resp. 010		MAC #3 Laptop con cargador	APPLE	A1278	C02H6858DVI4.                                            Cargador: LA0423121202AD00877	203	Bueno	Dirección	
VPNPRO317	Resp. 010		Cable HDMI a THUNDERBOLT	AMAZON	S/M	S/N	109	Bueno	Bodega 1	
VPNPRO318	Resp. 009		Notebook procesador Intel Atom N455 (1.66 GHz), Memoria de 2GB DDR3, DD 320GB, Pantalla LED de 10.1"	SAMSUNG	NP-NF210	ZWSM93LB500889H	104	BAJA	Se otorgó a Daniel	
VPNPRO319	Resp. 009		Splitter HDMI de 4 puertos 1x4	STEREN	BOS-304	S/N	104	Bueno	Bodega 1	
VPNPRO320	Resp. 009		Antena para T.V	RCA	ANTIZIE	SX36KE	104	Bueno	Bodega 1	Revisar para ver si se dan de baja
VPNPRO321	Resp. 009		Antena para T.V	RCA	ANTIZIE	4X28ICE	104	Bueno	Bodega 1	Revisar para ver si se dan de baja
VPNPRO323	Resp. 009		Splitter HDMI 1x2 con EDID y cargador	OREI	HDS-102	S/N	109	Bueno	Bodega 1	Volver a consultar
VPNPRO324	Resp. 009		Splitter HDMI 1x2 con EDID y cargador	OREI	HDS-102	S/N	109	Bueno	Bodega 1	Volver a consultar
VPNPRO325	Resp. 009		Splitter HDMI 1x4 con EDID y cargador	OREI	HDS-104	S/N	110	Bueno	Bodega 1	checar con eduardo s la tiene
VPNPRO326	Resp. 009		Splitter HDMI 1x4 con EDID y cargador	OREI	HDS-104	S/N	104	Bueno	Bodega 1	checar con eduardo s la tiene
VPNPRO274	Resp. 009	04/11/2023	Cable de fibra optica de 200 m con cable jumper doble	LINKEDPRO	EF200M	S/N	104	Bueno	Bodega 1	
VPNPRO275	Resp. 009	04/11/2023	Cable de fibra optica de 200 m con cable jumper doble	LINKEDPRO	EF200M	S/N	104	Bueno	Bodega 1	
VPNPRO276	Resp. 009	04/11/2023	Cable de fibra optica de 200 m con cable jumper doble	LINKEDPRO	EF200M	S/N	104	Bueno	Bodega 1	
VPNPRO277	Resp. 009	04/11/2023	Cable de fibra optica de 200 m con cable jumper doble	LINKEDPRO	EF200M	S/N	104	Bueno	Bodega 1	
VPNPRO327	Resp. 009		Splitter HDMI 1x4 con EDID y cargador	REI	HDS-104	S/N	104	Bueno	Bodega 1	checar con eduardo s la tiene
VPNPRO328	Resp. 009		Splitter HDMI 1x4 con EDID y cargador	REI	HDS-104	S/N	104	Bueno	Bodega 1	checar con eduardo s la tiene
VPNPRO329	Resp. 009		Splitter HDMI 1.4 1x8 con cargador	NOWBOTUCH	S/M	S/N	104	Bueno	Bodega 1	
VPNPRO335		21/08/2023	Pantalla de proyector con Soporte Pantalla de película portátil Plegable de 120 Pulgadas (16 : 9), Pantalla de películas de proyección de Doble Cara HD 4K con Bolsa de Transporte para Cine	GYUEM	120 Inch	S/N	203	Bueno	Regadera de Pedro	Regadera de Pedro
VPNPRO181	Resp. 010	11/04/2023	Cable RCA	S/M	S/M	S/N	109	Bueno	Caja Splitter	
VPNPRO271	Resp. 009	04/11/2023	Mini convertidor SDI a ANALOGO 4k con cargador	BlackMagic Desing	Mini Converter	S/N	104	Bueno	Bodega 1	
VPNPRO272	Resp. 009	04/11/2023	Distribuidor de señal SDI con cargador	BlackMagic Desing	Mini Converter	1401526	104	Bueno	Bodega 1	
VPNPRO273	Resp. 009	04/11/2023	Convertidor de fibra optica con cargador	BlackMagic Desing	Mini Converter	2377145	104	Bueno	Bodega 1	
VPNPRO336	PRO-001	07/09/2023	Control Zoom Fujinon	FUJINON	SRD-92B	S/N	119	Bueno	Bodega 2	
VPNPRO338	PRO-003	13/10/2023	Adaptador ATEM	S/M	S/M	S/N	110			
VPNPRO339			MAC 3 con cargador, estuche, y adaptador USB-C HDMI	APPLE	A2337	FVFLM4Q01WFV	109			
VPNPRO342			MAC 2 con cargador, estuche, y adaptador USB-C HDMI	APPLE	A2337	FVFLM6561WFV	110			
VPNPRO343			(20) Pisacables de 2 canales	S/M	S/N	S/N	104			
VPNPRO344		15/07/2025	Disco duro de 240GB OWC	OWC	OWCSSD7P6G240	OW16192410022DEE9	116	Funcional	Producción	
VPNPRO345		20/02/2024	( 7 ) NEEWER Soporte Monitor Campo con Zapata Fría, Tornillo Antigiro 1/4" para Monitor de 5" y 7"	NEEWER	MA006	S/N	119			
VPNPRO346		27/02/2024	Switcher ATEM 2 M/E con 20 entradas 12 salidas AUX 6 DVE's 8 chroma keyers 2 multiview	BlackMagic Desing	CONSTELLATION HD	11950701	119			
VPNPRO347		27/02/2024	Panel avanzado ATEM 2 M/E de dos bancos de mezcla y efectos con 20 botones para fuentes y dos pantallas LCD independiente	BlackMagic Desing	ADVANCED PANEL 20	11912209	119			
VPNPRO348		07/03/2024	KIT ESTUDIO #1: (1) Camara profesional de estudio 4K con fuente de poder, (1) C5 LE CCUPS V Montaje Fuente de alimentación ininterrumpida BP Cargador de placa de batería con abrazadera de varilla de 15 mm, 4 adaptadores de poder. (!) Lente de 12mm T2.2, (1) Lente de 45 mm f1.8, (1) Lente 40-150mm f/4.0-5.6 R(1) Brazo con abrazadera de 7" (1) Pinza de cangrejo	BLACK MAGIC DESING               JTZ               UTEBIT     ULANZI           OLYMPUS          ROKINON	Camara: G2                                               Montaje: DP30                                         Pinza cangrejo: R096	Camara: 12094195        FP:Y3A23N35021894                 Lente 45mm: ABMA46248        Lente 40-150mm: ABKE60181	119			
VPNPRO349		07/03/2024	KIT ESTUDIO #2: (1) Camara profesional de estudio 4K con fuente de poder, (1) C5 LE CCUPS V Montaje Fuente de alimentación ininterrumpida BP Cargador de placa de batería con abrazadera de varilla de 15 mm, 4 adaptadores de poder. (!) Lente de 12mm T2.2, (1) Lente de 45 mm f1.8, (1) Lente 40-150mm f/4.0-5.6 R(1) Brazo con abrazadera de 7" (1) Pinza de cangrejo	BLACK MAGIC DESING               JTZ               UTEBIT     ULANZI           OLYMPUS          ROKINON	Camara: G2                                               Montaje: DP30                                         Pinza cangrejo: R097	Camara: 12094171        FP:Y3A23N35021646             Lente 45mm: ABMA46152        Lente 40-150mm: ABKE60308	119			
VPNPRO350	10	08/03/2024	KIT SWITCHER #1: (1) Monitor portatil de 15.6 cable HDMI. (1) Convertidor SDI a HDMI+SDI - -Micro HDMI a SDI+SDI (1) ATEM SDI pro ISO, (2) base 3D para ATEM	GHIA                                                    Black Magic Design	Monitor : MG2223          ATEM: Atem SDI pro ISO	ATEM: 11407446                                Monitor: S2558LG331100954	109			
VPNPRO351	11	11/03/2024	KIT SWITCHER #2: (1) Monitor portatil de 15.6 cable HDMI. (1) Convertidor SDI a HDMI+SDI - -Micro HDMI a SDI+SDI (1) ATEM SDI pro ISO, (2) base 3D para ATEM	GHIA                                                        Black Magic Design	Monitor : MG2223          ATEM: Atem SDI pro ISO	ATEM: 11407374                                Monitor: S2558LG331100700	110			
VPNPRO352		19/03/2024	(16) cables HDMI con ethernet de 7.6 mts	KRAMER Electronics	CMHM/MHM-25	S/N	104			(2) tiene pedro y (2) en caja semanera
VPNPRO354		21/03/2024	(6) Cables HDMI de 20 mts	KRAMER Electronics	CRS PlugNView H-66	S/N	104			5 buenas y una falla
VPNPRO355		22/03/2024	KIT VPRO SPORTS #1 (1) Gabinete Acteck Kiruna II GM420 - Media Torre y (1) Monitor de 21.5"	AKTECK	KIRUNA II GM420               MG2223	Gabinete: 00233568004662            Monitor: S2558LG331100700	Fijo		Unidad Movil	
VPNPRO356		22/03/2024	KIT SEMANERA #3 (1) Gabinete Acteck Kiruna II GM420 - Media Torre y (1) Monitor de 21.5" (1) Teclado con mouse	AKTECK	KIRUNA II GM420               MG2223                    Teclado_ GHIA GT5000	Gabinete: 00233568004664                                              Monitor: S2558LG331100954                                           Teclado: S2754-7910300162                                 Mouse:S2754-7910300162	109			
VPNPRO357		25/03/2024	Streaming Deck	ELEGATO	20GBA9901	A00SA3272JBQCB0	109			
VPNPRO312	Resp. 009		Convertidor HDMI a VGA	STEREN	208-155	S/N	104	Bueno	Bodega 1	
VPNPRO358		25/03/2024	Streaming Deck	ELEGATO	20GBA9901	A00SA3272JG4GB	110			
VPNPRO359		01/04/2024	(3) Punteros laser inalambricos	DOOSL	MEOL15887	S/N	116	Bueno		SE QUEDARON CON 4 SEPROPIES
VPNPRO360		05/04/2024	(2) Fuentes de contacto montables de 12 entradas	INTELLINET	713955	S/N	104		caja azul	
VPNPRO361		05/04/2024	(5) Fuentes de contacto montables de 15 entradas	INTELLINET	714075	S/N	104			
VPNPRO362		05/04/2024	Splitter de 4 canales HDMI con audio	STARTECH	D6F300MM08	MM0811XD00136	104			
VPNPRO363		05/04/2024	Splitter de 8 canales HDMI con audio 7.1	STARTECH	ST128HD20	S/N	104			
VPNPRO364		05/04/2024	Splitter de 8 canales HDMI con audio 7.1	STARTECH	ST128HD20	S/N	104			
VPNPRO365		05/04/2024	(4) Splitter de 2 puertos de audio y video	STARTECH	ST122HD205	S/N	104			
VPNPRO366		05/04/2024	Splitter de 8 canales HDMI con audio 7.1	STARTECH	ST128HD20	S/N	104			
VPNPRO368		05/04/2024	Spliter de 4 puertos de alta velociad HDMI con audio	STARTECH	S1124HDMI2	MM0811XD00573	104			
VPNPRO369		05/04/2024	Spliter de 4 puertos de alta velociad HDMI con audio	STARTECH	S1124HDMI2	MM0811XD00105	104			
VPNPRO370		05/04/2024	(10) Cables HDMI	WIRELOGIC	S/M	S/N	109			
VPNPRO371		05/04/2024	(10) Cables HDMI	WIRELOGIC	S/M	S/N	110			
VPNPRO372		05/04/2024	KIT - (1) Adaptador HDMI USB-C (1) Apuntador inhalambrico (1) repetidor activvo USB	STEREN	S/M	S/N	109			
VPNPRO373			KIT - (1) Adaptador HDMI USB-C (1) Apuntador inhalambrico (1) repetidor activvo USB	STEREN	S/M	S/N	110			
VPNPRO374		16/04/2024	Tripie con (2) manerales	LIBEC	RHP75	S/N	119			Tiene el maneral del tripie VPNPRO375
VPNPRO375		16/04/2024	Tripie con (2) manerales	LIBEC	RHP75	S/N	119			Se le asignaron 2 manerales de otro tripie
VPNPRO376		24/04/2024	(2) Adaptador 4k DP a HDMI	UGREEN	MM137	S/N	110			
VPNPRO377		03/05/2024	(2) Cable Micro BNC-BNC coaxialp ara Black Magic SDI HD	ALVINS CABLES	S/M	S/N	119			
VPNPRO379			Caja transportadora	S/M	S/M	S/N	110			
VPNPRO382		20/06/2024	USB-C Doking Station CON (1) cable USB-C (1) cable con cabeza de doble salida USB-C	MOKIN	MUDL0104	S/N	109			
VPNPRO383		20/06/2024	USB-C Doking Station CON (1) cable USB-C (1) cable con cabeza de doble salida USB-C	MOKIN	MUDL0104	S/N	110			
VPNPRO384		20/06/2024	USB-C Doking Station CON (1) cable USB-C (1) cable con cabeza de doble salida USB-C	MOKIN	MUDL0104	S/N	110			
VPNPRO385		18/02/2025	Computarora de escritorio con teclado y mouse alambricos y adaptador	LENOVO	F0BW	Monitor: P901L1UZ                      Teclado: 60319220.             Mouse: 60626430	104			
VPNPRO388		08/06/2025	Micro Convertidor Bi Directional SDI a HDMI 3G Blackmagic Design	Black Magic	BiDirectional SDI/HDMI 3G	12855113	119			
VPNPRO389		08/06/2025	Micro Convertidor Bi Directional SDI a HDMI 3G Blackmagic Design	Black Magic	BiDirectional SDI/HDMI 3G	1285116	119			
VPNPRO390			Lector de discos Hyperx SNA-DCH/U3	Kingston		8737143302227	119			
VPNPRO392			Cable Black Magic design cable micro BNC a BNC hembra	Black Magic	S/M	S/N	119			
VPNPRO393			Impresora Laser	Samsung	xpress 2022	06YBBGG1FMW	116			
VPNPRO394			Mezclador de audio profesional para DJ, mezclador de sonido Phenyx Pro de 6 canales	Phenyx Pro	PTX-20	Pendiente				
VPNPRO395			(13) CABLES HDMI (2) NEGROS DE 3,60, (1) NEGRO DE .90 STEREN, (2) GRIS KRAMER DE 1.80, (1) NEGRO 1.50, (1) ROJO DE 1.80 HIGH, (1) NEGRO-AZUL 1.80, (1) NEGRO STERE .90, (1) NEGRO-AZUL .90, (2) NEGROS DE 1,80, (1) NEGRO DE 1,40	Ethernet LM	E205663	S/N	119			
VPNPRO396			(14) CABLES NEGROS SDI (2) DE 1,50, (1) DE 4,50, (1) DE 5,40, (1) DE 2,40. (1) DE 1,30, (1) DE 13 (1) DE 2,30 (1) DE 6,10 (1) DE 2,20 (1) DE 5,50 (1) DE 17,60 (1) DE 2,90 (1) DE 3	Belden	1855ABHDI	S/N	119			
VPNPRO397			(3) CABLES SDI AZULES (1) DE 3,05, (2) DE 2,05	BELDEN	1855ABHDI	S/N	119			
VPNPRO398			(7) CABLES SDI LILAS (3) DE 1.10, (1) DE 1,50, (2) DE 1,40, (1) DE 2,10	BELDEN	1694ABHDI	S/N	119			
VPNPRO399			(11) CABLES SDI GRUESOS (10) Belden (1) Coaxial	Belden                                                                                                          Canare	1694ABDHI                   75Q            Coaxial:  L-5CFB	S/N	119			
VPNPRO400			CABLES SDI TRIPLAY (1) GRUESO (1) MORADO DELGADO (2) DELGADOS Plateados	BELDEN	1694AB HDL                                   18555AB HDI	S/N	119			
VPNPRO401		26/06/2025	Panel Switcher #1, panel de conmutador, grabación de video HDMI HD 4K Virtual Studio Grabación Switcher, para producción de transmisión en vivo. (1) Cable de poder de 1.5 M	TYST Video	TY-1500HDI	S/N	110	Bueno		
VPNPRO403			Cable SDI 10.80 MTRS		ARSA RG-59/U 75OHMS 562	S/N	119			
VPNPRO404			(10) Cables HDI	Belden	1855ABDHI	S/N	119			
VPNPRO405			(2) Capturadoras con cable dhmi 4K Ultra hd USB3.3	Conocel                                                      VGA	M-300	S/N	119			
VPNPRO406			(2) Capturadoras con cable dhmi 4K Ultra hd USB3.3	EDID	HDCP22	x0047cg3xl	110			
VPNPRO407			Monitor Samsung con CPU Armado, on teclado y mouse (combo creator mk440)	Acteck	Monitor: C27FG73FQL Teclado y mouse: Combo Creator MK440	Monitor: CW4NH4ZM900044J                                            Teclado: 368631751794                                                  Mouse: 368631751794	116			
VPNPRO408			Tarjetero par Switches con tarjeta N0. 2	CEFC	OWCHELIOS3S	S/N	110			
VPNPRO409			Steren Adaptador de Red USB, Inalámbrica, WLAN, 867Mbit/s, COM-8235	STEREN	COM-8235	S/N	116			
VPNPRO410			LAMPARA RED TOP DE ESCRITORIO CAMPANA LED GRIS	Red Top	LA30196V	S/N	119			
VPNPRO411			Monitor chico	Elvid	WDM-758G	758G140969	119			
VPNPRO412			Multicontactos koblenz	Koblenz	SS-090-C	5526-08-16 00:00:00	119			
VPNPRO415			1 CABLE USB PARA FUENTE DE PODER	Shielder	S/M	S/N	119			
VPNPRO413			6 Cables RCA (2 Gris, 1 morado y 3 azul marino)	RCA	S/M	S/N	119			
VPNPRO414			RCA A MINI PLUS	S/M	S/M	S/N	119			
VPNPRO416			(1) Cable MINI USB	Shielder	S/M	S/N	119			
VPNPRO417			2 Cables HDMI tm A mini	Ethernet	E321484	20276	119			
VPNPRO418			19 cables de RED consumibles 5 azules, 5 amarillos, 4 negros, 4 grises, 1 blanco)	S/M	S/M	S/N	119			
VPNPRO419			4 cables de energia	S/M	S/M	S/N	119			
VPNPRO420			MONITOR LCD, AOC,Teclado ASSY P/697737-161 CT:BCYSTOAHH7132V. Mouse 24ghz Wireless optical	AOC	TFT22W90PS	S/N	107			
VPNPRO421			CPU ARMADO	Cooles Master	S/M	S/N	107			
VPNPRO423			Linea de audio de canon a plug Hembra	S/M	S/M	S/N				
VPNREC003	Resp.03	03/12/2021	Pantalla 43 pulgadas	Hitachi	LE43M4S9	MK5LF02713	Fijo	Activo	Recepción	
VPNRED001			#6 Modem Banda Ancha USB #6674798449 (Telcel) PW: Jovasa11	Huawei	E3276s-500	V7UDW15504000955	201	Baja	Bodega exterior	
VPNRED002			#5 Modem Banda Ancha USB #6677907940 (Telcel) PW: Jovasa11	Huawei	E3276s-500	V7UDW15321000933	201	Baja	Bodega exterior	
VPNRED003			#4 Modem Banda Ancha USB #6674202610 (Telcel) PW: Jovasa11	Huawei	E3276s-500	V7UDW15619000636	201	Baja	Bodega exterior	
VPNRED005			#2 Modem Banda Ancha USB #6675402616 (AT&T) PW: 1qaz2WSX	Huawei	E3276s-500	V7UDW15619000143	201	Baja	Bodega exterior	
VPNRED006			#1 Modem Banda Ancha USB #6675402461 (At&T) PW: 1qaz2WSX	Huawei	E3276s-500	V7UDW15504000104	201	Baja	Bodega exterior	
VPNRED007			#1 Modem 4G Router 2 #6671000373 PW(Jovasa11)	Huawei	B311-521	XKR7S20B30000505	201	Baja	Bodega exterior	
VPNRED008			#2 Modem 4G Router 2 #6675029050 PW(streaming01)	Huawei	B311-521	XKR7S20B30000501	201	Baja	Bodega exterior	
VPNRED009			#3 Ruter Huawei Internet #6674769251 PW: streaming04	Huawei	B311-521	XKR7S20B30001595	201	Baja	Bodega exterior	
VPNRED010			#4 Ruter Huawei Internet #6677673708 PW: streaming03	Huawei	B311-521	XKR7S20B30001598	201	Baja	Bodega exterior	
VPNRED014	Resp.17		Ipad Mini 4 con cargador	APPLE	A1538	F9FX66L6GHKJ		Activo	Sistemas y redes	1344
VPNRED016	Resp.16		MULTI GIGABIT WI-FI ACCESS POINT	TP-LINK	EAP660HD	2214391000359	201	Activo	Sistemas y redes	
VPNRED017	Resp.16		MULTI GIGABIT WI-FI ACCESS POINT	TP-LINK	EAP660HD	220D400001219	201	Activo	Sistemas y redes	
VPNRED022	Resp.16		SAFE STREAM GIGABIT MULTI-WAN VPN ROUTER	TP-LINK	TL-ER6020	218B208000200	201	Activo	Sistemas y redes	COMPRADO USADO
VPNRED023	Resp.16		SAFE STREAM GIGABIT MULTI-WAN VPN ROUTER 10/100	TP-LINK	TL-R480T+	2167609002375	201	BAJA	Sistemas y redes	El equipo ya no cumple con las caracteristicas para lo que es requerido
VPNRED024	Resp.16		Router de 8 puertos con fuente de poder	D-LINK	DSR-250N	QBDM3FA000212	201	BAJA	Sistemas y redes	
VPNRED025	Resp.16		Router de 16 puertos con fuente de poder	TP-LINK	TL-SG1016	2188167001696	201	Activo		
VPNRED026	Resp.16		SWITCH MANAGER 48 PUERTOS	CISCO	SF 300-48	DNI194307MU	201	Activo	Sistemas y redes	COMPRADO USADO
VPNRED027	Resp.16		Equipo Celular Samsung SM-A307G #6672173818 PW:Jovasa11	Samsung	SM-A307G	RF8MA2XEHVW	201	Activo	Sistemas y redes	
VPNRED028	Resp.16		Audifonos Alambricos 2.1	Panasonic	RP-HT260	S/N	201	Activo	Sistemas y redes	
VPNRED029	Resp.16		GSD-1002M - L2/L4 Gigabit Ethernet Switch - PLANET Technology	PLANET	GSD-1002M	A350169C00004	201	Activo	Sistemas y redes	
VPNRED031	Resp.16		(2) TP-Link TL-SM311LM Módulo Gigabit SFP, Multi-Modo, MiniGBIC, Interface LC, 550/275m	TP-LINK	TL-SM311LM	219A940000451                 219A940000448	201	Activo	Sistemas y redes	
VPNRED032	Resp.16	None	Starlink CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA	STARLINK	UTA-211	KIT00271713	201	Baja	Sistemas y redes	
VPNRED033	Resp.16		Laptop Asus Vivobook 15" D1502IA-BQ179W Ryzen 5 8GB RAM 256GB SSD con cargador, mochila y estuche.	ASUS	D1502I	N7N0CV06W988284	201	OPERATIVO	Sistemas y redes	PIN 1344
VPNRED034	Resp.17		Laptop Asus Vivobook 15" D1502IA-BQ179W Ryzen 5 8GB RAM 256GB SSD con cargador con mochila y estuche	ASUS	D1502I	N7N0CV06W70728G	201	Activo	Sistemas y redes	PIN 1344
VPNRED035	Resp.16	01/02/2024	Starlink #3 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA	STARLINK	UTR-212	2DUNI00000135789	201	Activo	Sistemas y redes	KIT: KIT302940819
VPNRED036	Resp.16	01/02/2024	Starlink #2 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA	STARLINK	UTR-212	2DWC234600005834	201	Activo	Sistemas y redes	KIT: KIT302941447
VPNRED040		20/02/2024	Tarjeta para capturar contenidos con calidad cinematográfica con dos entradas y dos salidas SDI 12G para señales en formato DCI 4K. Cable multiconector para señales analógicas y control de dispositivos mediante la conexión RS-422. Cable para alimentación externa	BLACKMAGICDESINGN	Decklink 4k Extreme 12	11737794	203	Inactivo	Sistemas y redes	
VPNRED041		20/02/2024	Tarjeta para capturar contenidos con calidad cinematográfica con dos entradas y dos salidas SDI 12G para señales en formato DCI 4K. Cable multiconector para señales analógicas y control de dispositivos mediante la conexión RS-422. Cable para alimentación externa	BLACKMAGICDESINGN	Decklink 4k Extreme 12	11737672	203	Inactivo	Sistemas y redes	
VPNRED061	Resp.16	01/08/2024	Power supply de 500W	ACTECK	S/M	S/N	201	Inactivo	Sistemas y redes	
VPNRED062	Resp.16		Router inhalambrico de 300 MBPS	MERCUSYS	MW330HPCUN	223CA68000255	201	Bueno	Sistemas y redes	
VPNRED063	Resp.21	22/10/2024	Teclado alambrico con mouse	Microsoft	Wired Keyboard 200	66907242513	202	Bueno	Sistemas y redes	Se le quebro una patita
VPNRED064	Resp.21	22/10/2024	Mouse pad Ergonomico	PERFECT CHOICE	S/M	S/N	202	Bueno	Sistemas y redes	
VPNRED065	Resp.16	25/10/2024	Tarjeta capturadora 4K HD y cale USB	PACOXI	PX-C7	S/N	109	Bueno	Sistemas y redes	
VPNRED066	Resp.16	25/10/2024	Tarjeta capturadora 4K HD y cale USB	PACOXI	PX-C7	S/N	109	Bueno	Sistemas y redes	
VPNEST005			Monitor de 32" con mouse y teclado	SAMSUNG	C32F391FWL	0AF3HCPN900063V		Bueno	Estudio TV	sin mouse
VPNEST014	VPNEST014		Disponible							
VPNPRO402			(5) CABLES SDI PARA SWITCHER PARA (Unidad Movil) (4) DE 6 MTRS Y (1) DE 7 MTRS	Belden	1855ABHDI	S/N	119			
VPNRED013			Adaptador de USB a RED	STEREN	506-430	S/N	201	Baja	Sistemas y redes	
VPNRED067		29/01/2025	(2) Adaptadores Starlink SPX a RJ45 para generación 2	STARLINK	SPX a RJ45	S/N	201	Bueno	Sistemas y redes	
VPNRED068		30/01/2025	Wire tracker, con (1) Emitidor (1) Recibidor (1) Audifonos (1) Cable con pinza de cocodrilo (1) Cable adaptador RJ45 (1) Cable adaptador RJ11	S/M	MJ-868	S/N	201	Bueno	Sistemas y redes	
VPNRED069		04/02/2025	Adaptador ethernet USB tipo C a RJ45 Gigabit	TPLINK	UE300C	S/N	201		Sistemas y redes	
VPNRED070		30/05/2025	Tableta Smasung Galaxy Tabl A9 (color plata) con cabe de corriente, portector y correa para protector.	SMASUNG	Galaxy Tab A9	R83Y30NQGPD	201	Nuevo	Sistemas y redes	
VPNRED071		30/05/2025	Tableta Smasung Galaxy Tabl A9 (color grafito) con cabe de corriente, portector y correa para protector.	SMASUNG	Galaxy Tab A10	R8YXA12BPQM	201	Nuevo	Sistemas y redes	
VPNRED080		02/07/2025	(2) Brazalete antiestatica	S/M	S/M	S/N	201	Bueno	Sistemas y redes	
VPNRED081		25/08/2025	TP-Link Omada VPN Router con Puertos 10G (ER8411) - Omada SDN gestión centralizada, Dos Puertos 10GE SFP+, hasta 10 Puertos WAN (2) Cables de fuente de poder (1) Cable VGA a Ethernet	TP-LINK	ER8411	22341S1000644	201	Bueno	Sistemas y redes	
VPNRED082			Monitor de 22"	GHIA	MG2223	S2558LG331100954	202	Bueno	Sistemas y redes	Era antes parte del kit semanera
VPNRED083			Lector de dicos duros	Startech	SDOCK2U33HFB	RB79259411021310280295	202	Bueno	Sistemas y redes	
VPNRED094	S/R	18/03/2026	ENCODER 4K HDMI-3G-SDI video encoder	Kiloview	E3	2009130021942	202	Bueno	Sistemas y Redes	nuevo de paquete
VPNAUD008		08/09/2023	( 6 ) Receptor bodies	SONY	URX-P2	144141 , 143291 , 119982 , 138215,  119981, 109777	118	Funcional	Bodega 1	No tiene cables ni microfono 2 NO TIENE BROCHESs
VPNCOM001	Resp.14	30/01/2024	Macbook air de 13 pulgadas con el chip m1 de apple 256GB, gris espacial, con cargador y adaptador USB a USB C	APPLE	A2337	FVFLM6GA1WFV	121.0	BUENO	Ventas	
VPNCOM004	Resp.14	29/07/2024	Impresora Lasser SAMSUNG, Mod. Xpress M2022	Samsung	Xpress M2020	074FB8GH9E01G5Y	121.0	Bueno	Ventas	
VPNDGF004		21/06/2025	Lente 1.5/50mm T1.5 AS UMC con protector de lente	ROKINON	S/M	S/N	102	Bueno	Closet comercialización	MALETA PELICAN GRIS
VPNRED072		09/06/2025	(2) Switch 4 puertos	STEREN	S/M	S/N	201	Bueno	Sistemas y redes	
VPNRED073		09/06/2025	MSI059 SWICH 5 PUERTOS	MERCUSYS	MSI059	S/N	201	Bueno	Sistemas y redes	
VPNRED074		09/06/2025	Pinza ponchadora	Intelinet	S/M	S/N	201	Bueno	Sistemas y redes	
VPNRED075		09706/25	Pinza Ponchadora	Snapplug	S/M	S/N	201	Bueno	Sistemas y redes	
VPNRED077		10/12/2025	UPS (Sistema de energia ininterrumpible)	SMARTBITT	SBNB2400	7722410500749	201	Bueno	Sistemas y redes	
VPNRED078		12/06/2025	Carcasa de disco duro 2.5 con cable USB A a mini USB B	STEREN	S/M	S/N	201	Bueno	Sistemas y redes	
VPNRED079		12/06/2025	Estación de acoplamiento Thunderbolt 3, 4 entredas USB, 2 USB C, 1 entrada DP, 1 entrada DP IN y una ethernet	PLUGABLE	TBT3-UDV	K19-0045221	201	Bueno	Sistemas y redes	
VPNRED095	12	26/02/2026	Switch de escritorio de 8 puertos	TP-Link	TL-sg108	Y255072001969	201	Nuevo	Sistemas y redes	Se compro para eventos de Cibacopa
VPNCAR012			External battery extender OSMO	DJI	External battery	300110162510250 3	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR013			Epic Pro/Raw Adaptador de vídeo con cable - Parte 94 Drone Flyer	DJI	Raw Adaptador	S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR015			DJI Osmo - Extensor de batería externo	DJI		S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR016			Libec ZC-3DV | Zoom control for LANC and Panasonic cameras	Libec	ZC-3DV	S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR021			MutecPower Cable USB 3.0 activo macho a hembra de 3 pies, cable extensor USB A, color negro, 1 metro, compatible con portátiles, discos duros, Xbox, PS4, VR, impresoras, Oculus Rift, etc. :	S/M	S/M	S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR022			ATOMOS Cable micro HDMI a HDMI completo	ATOMOS	S/M	S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR023			pearstone 5" ángulo recto mini HDMI (tipo C) macho a HDMI (tipo A) Cable Adaptador Hembra	PEARTONE	HD-ARACMAF	S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR024			Osmo Cargador	DJI	BATERY ADAPTADOR	S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR025			DJI Ronin-S Part 12 - Cable de control multicámara (mini USB)	DJI	Mini USB a USB	S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR026			Olympus M. Zuiko Digital ED 45mm f/1.8 Lens for E Series DSLR Cameras	OLYMPUS	45mm f1.8	ABMA46248	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCOM005	Resp.19	30/07/2024	Laptop MAC #2 con cargador	APPLE	A1278	C1MQ2HJCDTY3	203.0	BUENO	Dirección	
VPNCOM006	Resp.22		Telefono Axon ZTE Morado pantalla 6.6" con 256 GB de memoria, con cargador.	ZTE	AXON 50 lite	LZ0V50MXPBB006995	121.0	BUENO	Ventas	6674093878                                         Clave:
VPNDGF028		23/06/2025	Estabilizador en tres ejes para cámaras DSLR y sin espejo	DJI	DJI RS 4	6ZYCM920093HDG	102	Bueno	Digital Films	
VPNDGF029		23/06/2025	Adaptador para ATOMOS FLAME/INFERNO/V-LOK FITTING KIT/REG	V-LOK HAWK WOODS	VL-AS1	S/N	102	Bueno	Digital Films	
VPNDGF030		23/06/2025	Monitor de Video 4K con 4 discos duros, docking station y maletin	ATOMOS	SHOGUN FLAME 7      Docking tation:ATOMDCK003	K3A94SHF50K98.                   Docking tation:K524DCK036542	102	Bueno	Digital Films	
VPNDGF031		23/06/2025	MACBOOK PRO 15" con forro protector y cargador	APPLE	A2991	H41W62GJQL	102	Bueno	Digital Films	
VPNDGF032		23/06/2025	Audífonos PIONEER	PIONEER DJ	HDJ-CUE1	S/N	102	Bueno	Digital Films	
VPNCOM007	Resp.22	14/01/2025	Laptop HP Elitebook 845 G7 Notebook PC, con cargador, mousepad, y mouse inalambrico	HP	Elitebook 845 G7	S/N,  WGMTU0F1RCW7G5 (cargador)	202.0	Activo	Ventas	Contaseña: Vpromovil
VPNRED076		2025-09-06	UPS (Sistema de energia ininterrumpible)	HIKVISION	DS-UPS3000-X	30153063364	201	REVISION	Sistemas y redes	Daño en pilas, es necesario reemplazarlas
VPNDGF001	Resp-03	20/06/2025	KIT MATTE BOX, (1) Matte box, (2) cañas de fibra de carbono SmallRig de 15 mm (12") , (1) Placa base de 1/4" y 3/8" con placa para cámara (1) Dial de holgura FF con caja abatible y topes rígidos (1) Almohadilla para hombro con montaje en barra (1) Placa de "queso" con 2 contrapesos de 2 lb (1) MicroMount para monitor externo (1) Manillares de 4" y 8" (1) filtro ND0.6 GRAD SE, (1) filtro circular POLARISER, (1) filtro ND0.6, (1) Kit de engranajes para lentes tamaño A, B, C, y D, (1) Maleta reforz	Red Rock Micro	2003-12-01 00:00:00	S/N	'102	Bueno	Closet comercialización	Matte box se encuentra en el estante del closet, el resto de las piezas se encuentran en la caja
VPNDGF002		21/06/2025	(1) Videocámara XDCAM con sensor CMOS Exmor 4K Super de 35 mm, sistema de lentes con montura  y opciones de grabación en formato RAW 4K/2K y XAVC, (1) Adaptador (1) Tapa de estructura (1) Visor Ocular (1) Control remoto de empuñadura (1) Caja de trasportación Pelican 1550 negra	SONY	PXW-FS7	*Cámara: 21537                         *Adaptador: 0009175S	102	Bueno	Closet comercialización	MALETA PELICAN NEGRA
VPNDGF005		21/06/2025	Lente 1.5/85mm T1.5 AS 1F UMC II con protector de lente	ROKINON	RO8515SE	e217e2210	102	Bueno	Closet comercialización	MALETA PELICAN GRIS
VPNAUD035		27/02/2024	Destructor de Feedback automatico con microfono integrado, delay line, noisegate y compresor con cargador	SHARK	FBQ100	S1100695A3Q	118	Funcional	Bodega 1	
VPNAUD037		27/02/2024	Microfono inalambrico con transmisor de mano, con receptor UHF, transmisor de mano slxd2 con la cápsula de micrófono dinámico supercardioide beta 58a y (1) receptor slxd4 de un solo canal con antena y accesorios de montaje en rack, (1) bolsa con cremallera y (2) pilas aa	SHURE	SLXD24 B58-G58 SLXD2 G58 PS43US	3CK07940823 3CK07932176	118	Funcional	Departamento de audio	
VPNAUD040		24/04/2024	(2) Cargadores de bateria con (48) baterias recargables	AMAZON BASICS CITYORK	PL-NC30	S/N	118		Departamento de audio	
VPNAUD042		26/01/2022	Ipad Mini	APPLE	A1489	F9FQT55WFCMS				Revisar si esta con Pedro
VPNAUD043		26/01/2022	AUDIFONOS	SENNHEISER	HD206	S/N	118	Funcional	Departamento de audio	
VPNAUD044		08/02/2022	Mezclsador de 5 canales	ALLEN&HEALTH	ZEDi10FX	ZI10FX-1003374	118		Bodega 1	
VPNAUD070		22/10/2025	Interruptor para microfono	steren	S/M	S/N	118	Funcional	Bodega 1	Dentro de Arturito
VPNBOG005			Huawei E3276s-500 4G LTE FDD Band 2/4/5/7(1900/AWS(1700/2100)/850/2600MHz) 3G 850/1900/2100Mhz USB Stick Modem	Huawei	E3276s-500	V7UDW15619000143		Funcional	Bodega	
VPNBOG006			Huawei E3276s-500 4G LTE FDD Band 2/4/5/7(1900/AWS(1700/2100)/850/2600MHz) 3G 850/1900/2100Mhz USB Stick Modem	Huawei	E3276s-500	V7UDW15504000104		Funcional	Bodega	
VPNBOG007			Huawei B311-521 Enrutador Wi-Fi móvil 4G LTE 150 Mbps desbloqueado (3G/4G LTE	Huawei	B311-521	XKR7S20B30000505		Funcional	Bodega	
VPNBOG008			Huawei B311-521 Enrutador Wi-Fi móvil 4G LTE 150 Mbps desbloqueado (3G/4G LTE	Huawei	B311-521	XKR7S20B30001595		Funcional	Bodega	
VPNBOG009			Huawei B311-521 Enrutador Wi-Fi móvil 4G LTE 150 Mbps desbloqueado (3G/4G LTE	Huawei	B311-521	XKR7S20B30001598		Funcional	Bodega	
VPNBOG010			Huawei B311-521 Enrutador Wi-Fi móvil 4G LTE 150 Mbps desbloqueado (3G/4G LTE	Huawei	B311-521	MCNUT20417006147		Funcional	Bodega	
VPNDGF036		23/06/2025	Cargador de baterias para Mavic 2 Pro	ENERGEN	DRON MAX M221A	S/N	102	Bueno	Digital Films	
VPNDGF038		21/07/2025	Adaptador AC/AC	Asian Power Devises	WA-18Q12FU	Y942712910070450200	102			
VPNDGF043		21/07/2025	(3) Cable adaptador USB a USB B 3.0 -3.1	S/M	S/M	S/N	102			
VPNBOG014			Modem Megacable	ZTE	ZXHN F670L	ZTEEQHEMBX04817		Funcional	Bodega	
VPNCAR010			4 Pares de helices Drone INSPIRE 1 (usadas)	DJI	1345T Quick-Release	S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR011			6 hecices	S/M	S/M	S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR014			DJI Osmo - Extensor de batería externo	DJI		S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNEDI018		24/10/2025	Memoria de 6 Tb	Segate	SRD0PV1	NA8T9G2R	Fijo-banco de data			
VPNDGF012		23/06/2025	Montura Universal Gold Mount: Soporte de tamaño completo con cables positivos y negativos abiertos para aplicaciones personalizadas. Montaje ciego, con tornillos de 6/32.	ANTON BAUER	8375-0093	S/N	102	Bueno	Closet comercialización	
VPNDGF013		23/06/2025	IMAC DE 27" con teclado y mouse inalambrico	APPLE	MAC: iMAC 20,1 Teclado: A1843	MAC: C02FT11LPN7C               Teclado: BCGA1843	102	Bueno	Digital Films	
VPNDGF014		23/06/2025	(2) Bocinas	KRK Systems	Rokit 5	14E1   y   13L1	102	Bueno	Digital Films	
VPNDGF015		23/06/2025	Impresora blanco y negro	SAMSUNG	XpressM2022	06YJB8GF1F01M2H	102	Bueno	Digital Films	
VPNDGF016		23/06/2025	Disco duro de 3 Terabytes	ADATA	NOBILITY NH03	ID2220030719.	102	Bueno	Digital Films	
VPNDGF017		23/06/2025	Disco duro de 3 Terabytes	ADATA	MOBILITY NH03	1E4620125485	102	Bueno	Digital Films	
VPNDGF018		23/06/2025	Disco Duro de 8 Terabytes	SEAGATE	R-41011746	NA9RDJYN	102	Bueno	Digital Films	
VPNDGF019		23/06/2025	Disco duro de 6 Terabytes	SEAGATE	R-41011746	NA9RP35N	102	Bueno	Digital Films	
VPNDGF020		23/06/2025	Disco duro de 6 Terabytes	SEAGATE	SRD0PW1	NA8T86DT	102	Bueno	Digital Films	
VPNDGF021		23/06/2025	Disco duro de 6 Terabytes	SEAGATE	SRD0PW1	NA9QFQFD	102	Bueno	Digital Films	
VPNDGF022		23/06/2025	Disco Duro	LACIED2	LRDMU03	NT280RA0	102	Bueno	Digital Films	
VPNDGF024		23/06/2025	Interfaz de Audio	BERHRINGER	U-PHORIA UNC22	S200610647AUX	102	Bueno	Digital Films	
VPNDGF025		23/06/2025	Memoria de 2 Terabytes	SANDIS	SDSSDE30-2TOO	2339LH400521	102	Bueno	Digital Films	
VPNDGF026		23/06/2025	Cámara ALPHA 7 III	SONY	ALPHA 7 III	4905069	102	Bueno	Digital Films	
VPNDGF027		23/06/2025	Lente SONY FE 4/16-35	SONY	SEL1635Z	1824793	102	Bueno	Digital Films	
VPNDGF047			Tripie	DRACAST	S/M	S/N	102			anteriormente Tripe VPNPRO080, se intercambió debido a una falla el tornillo para embonar
VPNDIR001		05/08/2024	Laptop MAC #2 con cargador y mouse	MAC	A1278	CIMQ2HVHDTY34                                             CARGADOR: LA0423121202AD00877	203.0	Bueno	Direccioón	
VPNDIR002		05/08/2024	DJI OM4 con (1) tripie, (1) cable adaptador, (1) adaptador para celurar, (1) correa, (1) bolsa de trasporte de tela y (1) caja protectora	DJI	OK100	5CNZJ9N0003UFT	122.0	Bueno	Marketing	
VPNDIR003		24/06/2025	KIT Drone #2 Inspire 1 V2,0, (4) Baterias para dron Phantom 2, 5 ,3 y 6 (4) Baterias para dron 2, 3, 5, 7 DJI TB47 (2) Controles Remotos (2) Pares de Aspas para dron	DJI	*Dron: T601                 Controles Remoto: GL658C           Bateria Phantom: PH2-5200mAh-11.1V                    Baterias DJI: TB47-4500-22.2-65	Dron: W09HB014PY                            Control Remoto 2: W14JCI21060706                 Control Remoto 1: W14JDC23060162           Bateria 2: 7421161001793                         Bateria 3: 7421161001991                    Bateria 7: 7421144902961              Bateria 5: 7421161001850               Baeria Phantom 2: 3221144448239              Bateria Phantom 3: 3221144449131                          Bateria Phantom 5: 3221144448094             Bateria Phantom 6: 3221144448154	203.0		Bodega Dirección	Enviar a reparación
VPNDIR006		24/06/2025	Conversor AD A/D y audio integrado con fuente de poder y cabe de audio XLR macho	LEADER	LV 7700	S/N	203.0		Bodega Dirección	
VPNDIR008		24/06/2025	Reproductor y grabadora de video con cable de corriente	SONY	HVR-M25N	1411501	203.0		Bodega Dirección	
VPNDIR009			Disponible				203.0			
VPNEDI019		24/10/2025	Memoria de 6 Tb	Segate	SRD0PV1	NA0T86EO	Fijo-banco de data			
VPNEST027			Base de T.V con ruedas y cable	S/M	S/M	S/N		Bueno	Estudio TV	
VPNEST029			(5) Cable SDI	S/M	S/M	S/N		Bueno	Estudio TV	
VPNEST030			Cable HDMI	S/M	S/M	S/N		Bueno	Estudio TV	
VPNEST031			(4) Prensas	TRUPER	S/M	S/N		Bueno	Estudio TV	
VPNPRO017	Resp.004	15/02/2023	SanDisk RAM-3074 Memoria Extreme 64GB Micro SDXC 160Mb/S 4K Clase 10 A2 V30	SanDisk	Micro SD	6376DPGAQ08R	116	Bueno	Coordinacion de Producción	
VPNBOG011			Laptop Dell Inspiron G7 7700 Gaming 17.3" Intel Core i5 10300H Disco duro 512 GB SSD Ram 8GB Winsows 10 Home	Dell	P46E	GRMDHX2346498685430	VPRODIR011	NO Funciona	Bodega	Para Piezas
VPNBOG012			Router de 16 puertos con fuente de poder	TP-LINK	TL-SG1016	218816700169 6	VPRODIR009	Funcional	Baño Pedro	Sustituido por  VPNDIR009
VPNBOG013			Wireless FPV 7" LCD Monitor receptor con antena y cargador	ALCATEL	HH41NH 2BTGMXI	S/N		Funcional	Bodega	
VPNPRO012	Resp.004	15/02/2023	Kingston HyperX 3 K sh103s3/240G 2,5 240 GB SATA III, MLC interna unidad de estado sólido (SSD)	Kingston	Hyperx	50026B724C08A0B9	116	Bueno	Coordinacion de Producción	Integrado como disco duro en la computadora DELL VPNAUD018
VPNPRO013	Resp.004	15/02/2023	SanDisk Tarjeta Extreme PRO SDXC UHS-I de 256 GB - C10, U3, V30, 4K UHD, tarjeta SD - SDSDXXY-256G-GN4IN	SanDisk	Extreme PRO	S/N	116	Bueno	Coordinacion de Producción	
VPNPRO014	Resp.004	15/02/2023	SanDisk Tarjeta Extreme PRO SDXC UHS-I de 256 GB - C10, U3, V30, 4K UHD, tarjeta SD - SDSDXXY-256G-GN4IN	SanDisk	Extreme PRO	S/N	102	Bueno	KIT Dron	
VPNPRO015	Resp.004	15/02/2023	SanDisk Tarjeta Extreme PRO SDXC UHS-I de 256 GB - C10, U3, V30, 4K UHD, tarjeta SD - SDSDXXY-256G-GN4IN	SanDisk	Extreme PRO	S/N	116	Bueno	Coordinacion de Producción	
VPNPRO020	Resp.004	15/02/2023	APUNTADOR LASER STEREN COM 561 CON	STEREN	COM-561	PO25909	116	Bueno	Coordinacion de Producción	
VPNPRO045	PRO-001	07/09/2023	(2) Control de Zoom para camara XL-H1A	Libec	ZC-3DV	S/N	119	Funcional	Bodega 1	
VPNPRO051	PRO-001	07/09/2023	Cargador de batería de iones de litio Sony BC-L70 Y fuente de poder para camaras	Sony	BC-L70	0122553 138	119	Funcional	Estante de Baterias	
VPNPRO124	Resp. 010	04/04/2023	Splitter Hdmi 1x2 Divisor De Señal 2k 4k 3d Conecta 2 Tv - ELE-GATE	ELE-GATE	HDMI 1X2	S/N	109	Bueno	Mochila Plata	
VPNPRO128	Resp. 010	04/04/2023	(8) Cable SDI negro	BELDEN	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO179	Resp. 010	11/04/2023	Extractor de audio HDMI 2.0 support SDDF+L/R	TESUN	S/M	S/N	109	Bueno	Caja Splitter	
VPNPRO184	Resp. 010	11/04/2023	Switcher ATEM mini con gargador y adaptadores	BLACK MAGIC	ATEM MINI	8162169	109	Bueno	Caja Splitter	
VPNPRO185	Resp. 010	11/04/2023	Convertidor SDI a HDMI con cargador	S/M	S/M	S/N	109	Bueno	Caja Splitter	
VPNPRO186	Resp. 010	11/04/2023	Interfaz de audio	PEAVEY	S/M	ODBJM303659	109	Bueno	Caja Splitter	No se encontro
VPNPRO187	Resp. 010	11/04/2023	(15) Cable HDMI	S/M	S/M	S/N	119	Bueno	Caja Splitter	
VPNPRO188	Resp. 010	11/04/2023	Adaptador Rca A Plug 3/4	S/M	S/M	S/N	109	Bueno	Caja Splitter	
VPNEST056		01/07/2025	Pantalla Smart TV de 65" 4k UHD	PHILIPS	65PFL5765/F8	CC1A2036119715		Bueno	Estudio TV	
VPNEST057		01/07/2025	Tripie para televisión con 2 estantes	S/M	S/M	S/N		Bueno	Estudio TV	
VPNEST058		01/07/2025	QIAN Monitor Led HD 19.5' HD+ (1600 x 900) 60Hz 5ms Panel VA, 1000:1, 1xVGA 1xHDMI, 16.7M de Colores, VESA 100 x 100 QM191704	QIAN	QM191704			Bueno	Cabina de estudio	
VPNEST059		01/07/2025	QIAN Monitor Led HD 19.5' HD+ (1600 x 900) 60Hz 5ms Panel VA, 1000:1, 1xVGA 1xHDMI, 16.7M de Colores, VESA 100 x 100 QM191704	QIAN	QM191704			Bueno	Cabina de estudio	
VPNEST060		01/07/2025	Tela para proyección blanca con velcro	S/M	S/M	S/N		Bueno	Estudio TV	
VPNEST061		01/07/2025	Panel de luz bi-color con fuente de poder y estuche original de tela	DRACAST	KALA2000A	S/N		Bueno	Estudio TV	Cables estan el en estuche de VPNEST061
VPNEST062		01/07/2025	Panel de luz bi-color con fuente de poder y estuche original de tela	DRACAST	DRSP 500B	S/N		Bueno	Estudio TV	
VPNFIJ001			Mini Split de 1 ton. Mod. Absolut	Mirage	EXF121D	EXF121D8031405623	Fijo	Bueno	Administracion	
VPNFIJ002			Pantalla 43 pulgadas	Hitachi	LE43M4S9	MK5LF02707	Fijo	Bueno	Administracion	
VPNPRO222	Resp. 014		Blackmagic Design Hyperdeck Studio 2 (Gravadoras de Video)	BlackMagic Desing	Hyperd/st2	3245557	119	Bueno	Caja de Grabadoras	
VPNPRO223	Resp. 014		Blackmagic Design Hyperdeck Studio 2 (Gravadoras de Video)	BlackMagic Desing	Hyperd/st2	3111516	119	Bueno	Caja de Grabadoras	
VPNPRO224	Resp. 014		Blackmagic Design Hyperdeck Studio 2 (Gravadoras de Video)	BlackMagic Desing	Hyperd/st2	3173371	119	Bueno	Caja de Grabadoras	
VPNPRO225	Resp. 014		Blackmagic Design Hyperdeck Studio 2 (Gravadoras de Video)	BlackMagic Desing	Hyperd/st2	3246648	119	Bueno	Caja de Grabadoras	
VPNPRO226	Resp. 014		Laptop Acer Aspire E5-575-34 - 15.6" - i3-6006U - 8GB	ACER	E5-575-34ZM	NXGE1AL0037101B4B57600	119	Bueno	Switcher Grande	
VPNPRO227	Resp. 014		Blackmagic SmartView 4K - HDL-SMTV4K12G - BMD	BlackMagic Desing	HDL-SMTV4KSG	5130544	119	Bueno	Switcher Grande	
VPNPRO228	Resp. 014		Teranex Mini Rack Shelf - Blackmagic Design	BlackMagic Desing	CONVNTRM/YA/RSH	4513121	119	Bueno	Switcher Grande	
VPNPRO229	Resp. 014		Blackmagic SmartScope Duo 4K 2	BlackMagic Desing	HDL-SMTWSCOPEDUO4K2	5209485	119	Bueno	Switcher Grande	
VPNPRO230	Resp. 014		(2) Mezcladora Estereo Profesional de 2 Canales	BEHRINGER	ZMX2600	S170800910B3P	118	Bueno	Dp. De Audio y Arturito.	
VPNPRO231	Resp. 014		(15) Amp Power Supply Power Strip with 1800VA Rack Mountable 9 Outlets	PYLE		S/N	119	Bueno	Switcher Grande	
VPNEST006			Mouse con cable	MICROSOFT	S/M	S/N		Bueno	Estudio TV	
VPNEST007			Teclado con cable	NEWTEK	S/M	S/N		Bueno	Estudio TV	
VPNEST018			Disponible							
VPNBOG015			Refurbished) Dell E2014Hc 1600x900 HD Widescreen monitor	DELL	E2014Hc	CN-012MWY-64180-537-0FZL		Funcional	Bodega	Sin cable de Corriente
VPNBOG016			Computadora HP All-in-One 18-5202la - 18.5" - AMD E1-6010 - 4GB - 500GB - Windows 8.1 - Plata/Negro - J5U02AA	HP	18-5202la	4CE447085W		Funcional	Bodega	Sin Mause ni Teclado
VPNPRO129	Resp. 010	04/04/2023	Cable USB a USB tipo C	STEREN	S/M	S/N	109	Bueno	Mochila Plata	
VPNPRO293	Resp. 009		Memoria USB	S/M	S/M	S/N	109	Bueno	Mochila semanera	
VPNPRO294	Resp. 009		Selector HDMI de 4 puertos	STEREN	200-384	26432	109	Funcional	Bodega externa	Se almaceno en la bodega externa
VPNPRO295	Resp. 009		(2) Extensor HDMI a ETHERNET	AVEN VIEW	HDM-C61P-5	HDMC6IPR12373066093                      HDMC6IPS12373006100	104	Funcional	Bodega externa	Se almaceno en la bodega externa
VPNPRO296	Resp. 009		(2) Extensor HDMI a ETHERNET	AVEN VIEW	HDM-C61P-6	HDMC6IPR12373066296                     HDMC6IPS12373006295	104	Bueno	Bodega 1	
VPNBPA001		19/06/2025	(2) Green screen con elastico, esquinas redondeadas.	S/M	S/M	S/N		Bueno	Bodega baño planata alta, dentro de la caja verde.	
VPNBPA002		19/06/2025	(1) Green screen con velcro	S/M	S/M	S/N		Bueno	Bodega baño planata alta, dentro de la caja verde.	
VPNBPA003		19/06/2025	(1) Green screen chico	S/M	S/M	S/N		Bueno	Bodega baño planata alta, dentro de la caja verde.	
VPNBPA004		19/06/2025	(1) Green Screen extra grande para estudio	S/M	S/M	S/N		Bueno	Bodega baño planata alta, dentro de la caja verde.	
VPNBPA005		19/06/2025	(3) Mantel gris	S/M	S/M	S/N		Bueno	Bodega baño planata alta, dentro de la caja de cartón	
VPNBPA006		19/06/2025	(1) Matel grande blanco	S/M	S/M	S/N		Bueno	Bodega baño planata alta, dentro de la caja de cartón	
VPNBPA007		19/06/2025	(1) Mantel chico blanco	S/M	S/M	S/N		Bueno	Bodega baño planata alta, dentro de la caja verde.	
VPNBPA008		19/06/2025	(1) Matel Rojo	S/M	S/M	S/N		Bueno	Bodega baño planata alta, dentro de la caja de cartón	
VPNBPA009		19/06/2025	(1) Cesped artifical para set	S/M	S/M	S/N			Bodega baño planta alta	
VPNBPA010		19/06/2025	Escritorio de cristal negro (desensamblado)	S/M	S/M	S/N			Bodega baño planta alta	
VPNBPA011		19/06/2025	Luces para estudio	S/M	S/M	S/N			Bodega baño planta alta	
VPNCAR006			Brazo De Extension Recto DJI - Straight Extensión Arm Para Osmo Parte 5	DJI	Straight Extensión	S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR007			External battery extender OSMO	DJI	External battery	300110163010701 5	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR008			Cargador de bateria Dji Osmo	DJI	Cargadro de Bateria	S/N	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNCAR009			External battery extender OSMO	DJI	External battery	310110163010754 0	Concepcion Castro Mendoza	Bueno	Carton 001	
VPNPRO330	Resp. 009		Splitter HDMI 1.4 1x8 con cargador	NOWBOTUCH	S/M	S/N	104	Bueno	Bodega 1	
VPNPRO331	Resp.008	22/07/2023	CPU Armado, CORE I3 QUAD CORE 3.60 GHZ / 16 GB / SSD 240 GB	INTEL	H87					
VPNPRO332		14/08/2023	Trípode para proyector de 23.5 a 46.5 pulgadas, soporte de trípode para portátil en altura	DECOSIS	S/M	S/N	203	Bueno	Bodega 1	Regadera de Pedro
VPNPRO333		14/08/2023	Trípode para proyector de 23.5 a 46.5 pulgadas, soporte de trípode para portátil en altura	DECOSIS	S/M	S/N	203	Bueno	Bodega 1	Regadera de Pedro
VPNPRO334		21/08/2023	Pantalla de proyector con Soporte Pantalla de película portátil Plegable de 120 Pulgadas (16 : 9), Pantalla de películas de proyección de Doble Cara HD 4K con Bolsa de Transporte para Cine	GYUEM	120 Inch	S/N	203	Bueno	Regadera de Pedro	Regadera de Pedro
VPNPRO337	PRO-002	13/10/2023	Adaptador ATEM	S/M	S/M	S/N	109			
VPNPRO340			MAC 4 con cargador, estuche, y adaptador USB-C HDMI	APPLE	A2337	FVLM4Y91WFV	109			
VPNPRO341			MAC 1 con cargador, estuche, y adaptador USB-C HDMI	APPLE	A2337	FVFLM6K01WFV	110			
VPNPRO353		21/03/2024	(2) Cables HDMI fibra optica de 100 mts	KRAMER Electronics	CRS PlugNView H-328	S/N	104			
VPNAUD068		22/10/2025	(4) Microfonos ambientales de camara	SONY	ECM-NV1.                ECM-XM1.                                 1-542-296	S/N	118	Funcional	Bodega 1	
VPNAUD069		22/10/2025	Interruptor para microfono	steren	S/M	S/N	118	Funcional	Bodega 1	Dentro de Arturito
VPNPRO206	Resp. 014		Decimator Md-hx Convertidor Cruzado Hdmi / Sdi En Miniatura (COMPLETO)	DECIMATOR	MD-HX	CLD15478	119	Bueno	Gabinete Produccion	
VPNPRO378			Caja transportadora	S/M	S/M	S/N	109			
VPNPRO380			Router para red de 300 mbps, con cable ethernet y fuente de poder	GHIA	GNW-W1	y305-w1-06164	119			Nombre de Wifi: GHIA-W1CC6G                                         Contraseña: 12345678
VPNPRO381		20/06/2024	USB-C Doking Station CON (1) cable USB-C (1) cable con cabeza de doble salida USB-C	MOKIN	MUDL0104	S/N	109			
VPNPRO387		08/06/2025	Rack de metal				119			
VPNCOM002	Resp.14	02/02/2024	Adaptador USB C para HDMI, USB y tipo C	SELECT POWER	S/M	S/N	121.0	BUENO	Ventas	
VPNEST016			Web caster x2 con HDMI, antena, adaptador y cable.	EPHIPAN VIDEO	WEBCASTER X2	WCX21723665		Bueno	Estudio TV	
VPNPRO422			Linea de Audio de Canon (azul)a plus Macho	S/M	S/M	S/N				
VPNPRO424		10/07/2025	Par de bocinas HP	HP	DHS-2111	211124537H347	116	Nuevo	Producción	
VPNPRO425		10/07/2025	Telefono Axon ZTE Morado pantalla 6.6" con 256 GB de memoria, con cargador y protector.	ZTE	AXON 50 lite	LZ0V50MXPB007027	116	BUENO	Producción	6674099301. Clave 1234
VPNPRO426		15/07/2025	Tarjeta de memoria SD 32GB, 633X	LEXAR	LEXAR PROFESSIONAL	771802101A01	116	Bueno	Producción	
VPNPRO427		08/09/2025	Cable de poder D-tep to DC	ZGCINE	DT-DC	S/N	119	Bueno	Producción	
VPNPRO428		06/10/2025	Centro de carga USB 3.0 de 7 puertos	ATOLLA	CH-207U3	S/N	109	Bueno	Producción	
VPNPRO429		06/10/2025	Centro de carga USB 3.0 de 7 puertos	ATOLLA	CH-207U3	S/N	110	Bueno	Producción	
VPNPRO430		12/01/2026	(2) Memoria USB de 64GB	Kingston	ExodiaM	S/M	110			
VPNPRO431		12/01/2026	(2) Memoria USB de 64GB	Kingston	ExodiaM	S/M	109			
VPNREC001	Resp.03	03/12/2021	Monitor para vigilancia, LG 22"	LG	22MT-48DF-PU	603MXMTKS139	Fijo	Activo	Recepción	
VPNREC002	Resp.03	03/12/2021	Grabador de camaras de vigilancia	Provision ISR	S/M	S/N	Fijo	Activo	Recepción	
VPNRED011			#5 Ruter Huawei Internet con amplificador	Huawei	B311-521	MCNUT20417006147	201	Baja	Bodega exterior	
VPNAUD001		08/09/2023	(KIT) micrófono Lavalier con cable estéreo, mini BMP y adaptador para zapato (transmisor y receptor)	SONY	URX-P03                  UTX-B03	109990                                               107168	118	Funcional	Departamento de audio	Portapilas quebrada (se utilizara la pieza del VPNAUD007 ara reemplazarla)
VPNAUD003		08/09/2023	(KIT) micrófono Lavalier con cable estéreo, mini BMP y adaptador para zapato (transmisor y receptor)	SONY	URX-P03                   UTX-B03	109993                                                110443	118	Funcional	Departamento de audio	
VPNAUD013		08/09/2023	Microfono inalambrico con receptor y adaptador de Carga, stand para microfono y esponja	SURE	BLX4 K12	3RL1142127	118	Funcional	Bodega 1	El stan de microfono se utilizó en otro equipo EN VNAUD054
VPNAUD014		08/09/2023	Microfono inalambrico con receptor y adaptador de Carga, stand para microfono y esponja	SURE	BLX4 K12	3RL1142130	118	Funcional	Bodega 1	
VPNAUD015		08/09/2023	(4) Microfonos de oreja electrico condensador, con clip y estuche	SONY	ECM-322BMP	S/N	118	No funciona	Departamento de audio	
VPNAUD016		08/09/2023	INTERFACE DE AUDIO USB	PAVEY ELECTRONICS	USB-P	0DBIM303675	118	Funcional	Estudio	
VPNAUD017		08/09/2023	Grabadora portatil de 6 pistas para camara, con estuche	TASCAM	DR-701D	1680016	109	Funcional	Departamento de audio	
VPNAUD018		08/09/2023	Laptop negra con cargador	DELL	INSPIRON 15	42414972626	203	Funcional	Dirección	En resguardo
VPNAUD019		08/09/2023	Audifono profesional	SONY	MDR-7506	S/N	109	Funcional	Departamento de audio	
VPNAUD020		08/09/2023	Disco duro de 6 TB	SEAGATE	S/M	NA8T9FP0	109	Funcional	Departamento de audio	
VPNAUD021		08/09/2023	Consola de audio de 16 canales con eliminador de corriente	YAMAHA	MG166CX	UCCNY01150	109	Funcional	Departamento de audio	fallas en el hardware (falla en los faders)
VPNAUD032		14/09/2023	Extensor 4 canales y 3 pines multired, XLR de 3 pines a RJ45, para escenario en vivo, grabación de estudio en casa, XLR, AES, canales DMX a través	COLUBER CABLE	4MF3XLRETO	S/N	118	Funcional	Bodega 1	Caja "Arturito"
VPNAUD033			Gearit Outdoor Waterproof Cat 6 Ethernet Cable Black 200Ft Gi-Cat6-Cca-Out- Ldpe-Bk-200F	GEAR IT	GI-CAT6-CCA-OUT-LDPE-BK-200F	S/N	118	Funcional		No se encontro
VPNAUD034		08/12/2023	Destructor de Feedback automatico con microfono integrado, delay line, noisegate y compresor con cargador	SHARK	FBQ100	S1100731A3Q	118	Funcional	Departamento de audio	
VPNAUD039		10/04/2024	Par de Bocinas	SAMSON	S/M	S/N	118		Departamento de audio y Bodega 1	
VPNRED030	Resp.16		Covertidor TP-Link MC220L Gigabit Ethernet Media	TP-LINK	MC220L	218C588000949	201	Activo	Sistemas y redes	
VPNRED038	Resp.16	15/02/2024	Gabinete de media torre Kiruna II (V8)	ACTECK	GM420	233568004662	201	Activo	Sistemas y redes	
VIRA001		29/04/2024	Monitor de 21.5" sin marco, con cable de fuente de poder, HDMI y stand de metal	IAN	QM215F	QM202023480106206	104.0	Bien		estudio
VIRA002		30/04/2024	Monitor de 21.5" sin marco, con cable de fuente de poder, HDMI y stand de metal	IAN	QM215F	QM202023480104812	104.0	Bien		estudio
VIRA003		01/05/2024	Monitor de 21.5" sin marco, con cable de fuente de poder, HDMI y stand de metal	IAN	QM215F	QM202023480104861	104.0	Bien	Bodega 2	bodega 2
VIRA004		26/06/2025	Pantalla de 65" 4K con ROKU TV - hace mucho que TV	Philiphs	65PFL5765-F8	CC1A2049114653	104.0	Bien	Bodega 2	No tiene control remoto
VIRA005		26/06/2025	Pantalla de 65" 4K con ROKU TV	Philiphs	65PFL5765-F8	CC1A2036119715	104.0	Bien	Bodega 2	No tiene control remoto
VIRA006		26/06/2025	Pantalla de 65" 4K con ROKU TV	Philiphs	65PFL5765-F8	CC1A2049114655	104.0	Bien	Bodega 2	No tiene control remoto
VIRA007		26/06/2025	Pantalla de 65" 4K con ROKU TV	Philiphs	65PFL5765-F8	CC2A2105117622	104.0	Bien	Bodega 2	Control lo tiene Paco
VIRA008		26/06/2025	Pantalla de 65" Crystal UHD Sin marco	SAMSUNG	UN65AU8200F	0BQF3CUT201947V	104.0	Bien	Bodega 2	
VIRA009		26/06/2025	Pantalla de 65" Crystal UHD Sin marco	SAMSUNG	UN65CU8200F	0F193CUX200369P	104.0	Bien	Bodega 2	
VIRA010		26/06/2025	Pantalla de 65" Crystal UHD con marco	SAMSUNG	UN65CU8200F	0F193CUX200354H	104.0	Bien	Bodega 2	
VIRA011		26/06/2025	Pantalla 65" 4K UHD serie A4	TLC	65A445	2105NTL000837A00905	104.0	Bien	Bodega 2	
VIRA012		26/06/2025	Pantalla 65" 4K UHD serie A4	TLC	65A445	2104NTL000804A00780	104.0	Bien	Bodega 2	
VIRA013		03/07/2025	Pantalla de 40" LED LCD	PHILIPHS	40PGL4708/F8	XA1A1321107874	104.0	Bien	Bodega 2	
VIRA014		03/07/2025	Pantalla de 40" LED LCD	PHILIPHS	40PGL4708/F8	XA1A1316101611	104.0	Bien	Bodega 2	
VIRA015		03/07/2025	Pantalla de 50" con control remoto	HISESNSE	50H6D	50G170483H00466	104.0	Bien	Bodega 2	
VPNAUD045			Laptop acer aspire con cargador	ACER	R3 13IT C5MT	NXG0YAL01153705A1E6599	direccion	Funcional	direccion	
VPNAUD046			5 Cables XLR6 Cable para micrófono ó dmx canon canon 6m - Wahrgenomen.com	WAHRGENOMEN	DMX CAB-WAW-00001	S/N	118	1 de 5 no sirve	Departamento de audio	
VPNAUD048			(12) Cables XLR6 Cable para micrófono ó dmx canon canon 50m negros - y (1) de 100mts , (1) verde de 50 mts (1) azul de 50 mts	SM	SM	SN	118	Funcional	Bodega 1	
VPNAUD049		07/06/2022	Audifonos inalambricos Hi-Fi con cancelacion activa de ruido ANC, con cable para cargar, clable auxiliar y estuche	BILLBOARD	ANC-X	SN	118	no funciona, esta quebrado		
VPNAUD050		07/06/2022	Audifonos inalambricos Hi-Fi con cancelacion activa de ruido ANC	BILLBOARD	ANC-X	SN	118	Funcional	Departamento de audio	
VPNAUD051		07/06/2022	Audifonos inalambricos Hi-Fi con cancelacion activa de ruido ANC	BILLBOARD	ANC-X	SN	118	Funcional	Departamento de audio	
VPNRED037	Resp.16	01/02/2024	Cable conector Router a Antena de 150 pies	STARLINK	S/M	S/N	201	Activo	Sistemas y redes	Rentado de martes a jueves
VPNAUD052		07/06/2022	Audifonos inalambricos Hi-Fi con cancelacion activa de ruido ANC	BILLBOARD	ANC-X	SN	118	Funcional	Departamento de audio	
VPNAUD053		09/06/2022	(5) Stand para microfono chico (1) mediano	NEEWER	S/M	S/N	118	BODEGA 1	Bodega 1	
VPNAUD054		09/06/2022	(2) stand para microfono Hercules para microfono MS-100B	HERCULES	MS-100B	S/N	118		Bodega 1	Se remplazaron piezas por VPNAUD030 Y VPNAUD013
VPNAUD055			(5) Cable Auxiliar, 3.5mm Cable Macho Macho, Nylon Trenzado	UGREEN	50355	S/N	118	Funcional	Departamento de audio	Repartidos en los audifonos billboard
VPNAUD056			Audifonos inalambricos Hi-Fi con cancelacion activa de ruido ANC	BILLBOARD	BB-H37448	S/N	118	BAJA	Dto. de Audio	Se re utilizo la caja
VPNAUD057		23/07/2025	(2) Interfaz de audio	AUDIOTEK	mkz-interaudineg	S/N	118		Departamento de audio y bodega 1	
VPNAUD058		23/09/2022	Audífonos Inalámbricos Billboard	BILLBOARD	BB-H75020-BLACK	S/N	118	Funcional	Departamento de audio	
VPNAUD059		23/09/2022	Audífonos Inalámbricos	BILLBOARD	BB-H75020-BLACK	S/N	118	Funcional	Departamento de audio	Esta reparado con cinta negra
VPNAUD060		23/09/2022	Audífonos Inalámbricos	BILLBOARD	BB-H75020-BLACK	S/N	118	Funcional	Departamento de audio	
VPNAUD061		23/09/2022	Audífonos Inalámbricos	BILLBOARD	BB-H75020-BLACK	S/N	118	Funcional	Departamento de audio	
VPNAUD062		14/01/2025	Laptop HP Elitebook 845 G7 Notebook PC, con cargador y maletín	HP	Elitebook 845 G7	S/N, WGMTU0F1RA3CBB (cargador)	118	Funcional	Departamento de audio	Contaseña: Vpromovil
VPNAUD063		24/02/2025	Dispositivo de audio USB-P	PEAVEY	S/M	0DCEE050253	118	Funcional	Departamento de audio	
VPNAUD064		09/06/2025	(4) cables convertidor ALR Macho a miniplug	UGREEN	S/M	S/N	118	Funcional	Departamento de audio	
VPNAUD065		09/06/2025	(6) Audifonos diadema HP1100 mULTI-PORPOSE Headphones	Behringer	HPM 1100	S/N	118	Funcional	Departamento de audio	
VPNAUD066		09/06/2025	(2) Audifonos 2HC200 hIGH-Quality Profesional DJ	behringer	HC.200	S/N	118	Funcional	Departamento de audio	
VPNAUD067		22/10/2025	(2) Cbale XLR Macho a Miniplug	S/M	S/M	S/N	118	Funcional	Bodega 1	
VPNAUD071		22/10/2025	Mezclasdora de 6 monos y 2 stereos	soundbarrier	MCX10USD	MCX10USD08110025	118	Funcional	Bodega 1	
VPNBOG001			Huawei E3276s-500 4G LTE FDD Band 2/4/5/7(1900/AWS(1700/2100)/850/2600MHz) 3G 850/1900/2100Mhz USB Stick Modem	Huawei	E3276s-500	V7UDW15504000955		Funcional	Bodega	
VPNBOG002			Huawei E3276s-500 4G LTE FDD Band 2/4/5/7(1900/AWS(1700/2100)/850/2600MHz) 3G 850/1900/2100Mhz USB Stick Modem	Huawei	E3276s-500	V7UDW15321000933		Funcional	Bodega	
VPNBOG003			Huawei E3276s-500 4G LTE FDD Band 2/4/5/7(1900/AWS(1700/2100)/850/2600MHz) 3G 850/1900/2100Mhz USB Stick Modem	Huawei	E3276s-500	V7UDW15619000636		Funcional	Bodega	
VPNBOG004			Huawei E3276s-500 4G LTE FDD Band 2/4/5/7(1900/AWS(1700/2100)/850/2600MHz) 3G 850/1900/2100Mhz USB Stick Modem	Huawei	E3276s-500	V7UDW15504000314		Funcional	Bodega	
VPNPRO386		08/06/2025	Switcher Black Magic				119			
VPNRED042		20/02/2024	Tarjeta para capturar contenidos con calidad cinematográfica con dos entradas y dos salidas SDI 12G para señales en formato DCI 4K. Cable multiconector para señales analógicas y control de dispositivos mediante la conexión RS-422. Cable para alimentación externa	BLACKMAGICDESINGN	Decklink 4k Extreme 12	11737742	201	Inactivo	Sistemas y redes	
VPNRED043	Resp.16	18/05/2024	(3) pares trenzados Cable UTP 305 gris	Brobotix	CAT6	S/N	201		Sistemas y redes	se termino
VPNRED044	Resp.16	19/06/2024	ATEM streaming bridge	BLACK MAGIC DESIGN	SWATEMMINISBPR	10949353	201	Activo	Sistemas y redes	
VPNRED045	Resp.16	19/06/2024	ATEM streaming bridge	BLACK MAGIC DESIGN	SWATEMMINISBPR	10949355	201	Activo	Sistemas y redes	
VPNRED046	Resp.16	19/06/2024	ATEM streaming bridge	BLACK MAGIC DESIGN	SWATEMMINISBPR	10949441	201	Activo	Sistemas y redes	
VPNRED048	Resp.16	19/06/2024	Capturadora DckLink 8k Pro, 12G-SDI	BLACK MAGIC DESIGN	BDLKHCHPRO8K12G	12182036	201	Funcional	Sistemas y redes	
VPNRED049	Resp.16	01/08/2024	Cable de 4 pares trenzados linea premium de 100 M	Brobotix	CAT5	S/N	201	Activo	Sistemas y redes	se termino
VPNRED050	Resp.16	01/08/2024	Cable U / UTP azul	WMW	CAT6	S/N	201	Inactiva	Sistemas y redes	
VPNRED051	Resp.16	01/08/2024	Switch de 5 puertos con cargador	TPLINK	LS1059	220C313006510	201	Activo	Sistemas y redes	
VPNRED052	Resp.16	01/08/2024	Monitor AOC de 21.5"	AOC	215LM0041	AEJF79A003401	201	Activo	Sistemas y redes	
VPNRED053	Resp.16	01/08/2024	CPU armadoPU armado CON PROCESADOR Intel Core i7-6700 , 16GB RAM y procesador de 64 bits.	S/N	S/M	S/N	201	Activo	Sistemas y redes	
VPNRED054	Resp.16	01/08/2024	# 1 Router 5G #66-71-00-03-73	QUAMTUM CONNECT 1	RUTER 5G	135588256109305 7	201	Funcional	Sistemas y redes	
VPNRED055	Resp.16	01/08/2024	# 2 Router 5G #66-75-02-90-50	QUAMTUM CONNECT 2	RUTER 5G	135588256104275 7	Se regaló a Hector Rementeria	BAJA	Sistemas y redes	Se regaló
VPNRED056	Resp.17	01/08/2024	Adaptadora USB C a ETHERNET	TP-LINK	UE300C	22382A4008461	202	Activo	Sistemas y redes	
VPNRED057	Resp.17	01/08/2024	Adaptadora USB C a ETHERNET	TP-LINK	UE300C	22382A4008502	202	Activo	Sistemas y redes	
VPNRED058	Resp.17	01/08/2024	Pantalla HP de 19"	HP	W1907	CNN7232TQN	201	Activo	Sistemas y redes	
VPNRED059	Resp.16	01/08/2024	Procesador intel core I5 (en la caja del procesador I7)	INTEL	S/M	S/N	201	Inactivo	Sistemas y redes	De la compuatdora de Manuel almacenada en la caja de el nuevo procesador
VPNDGF003		21/06/2025	(1) Lente SONY con montura tipo E con formato Full Frame, Lente de zoom teleobjetivo G Lens, Capacidad de macro medio en todo el alcance del zoom, montura tipo E con formato Full Frame, lente de zoom teleobjetivo G Lens y capacidad de macro medio en todo el alcance del zoom con (1) Parasol de lente frontal	SONY	*Lente: FE 4/70-200 G OSS                                *Parasol: ALC-SH133	Lente: 1836152	102	Bueno	Closet comercialización	MALETA PELICAN GRIS
VPNDGF006		21/06/2025	Lente Sonnar T* FE 55 mm F1.8 ZA con protector de lente	SONY	*Lente: SEL55F18Z                               *Protector de lente:	242809	102	Bueno	Closet comercialización	MALETA PELICAN GRIS
VPNEST040	RES-PRO-001	07/09/2023	LENTE FUJINON XS16x5.8A-XB8A (CÁMARA #2 PRODUCCIÓN)	Fujinon	A-XB8A	B62406181	119	Bueno	Estudio TV	EL LENTE DE LA CAMARA #2 DE PRODUCCION
VPNEST041	RES-PRO-001	07/09/2023	VariZoom VZPGF | Fujinon Zoom Control | Lens Control	VariZoom	VZPGF	S/N	119	Bueno	Estudio TV	KIT CAMARA ESTUDIO #5
VPNPRO029	PRO-001	07/09/2023	(CAMARA #2) Sony PXW-320K XDCAM EX Camcorder w/16x Zoom & CBK-CE01, SONY CBK-VF01 viewfinder HD camera PMW-350 PMW-320	Sony	PMW-320                                 CBK-VF01	0101888                                                                                176838	119	Funcional	Bodega 1	Se intercambio el viewfinder del kit #2 el cual presentaba daños, por uno sin daños.
VPNPRO117	Resp. 006	04/04/2023	(10) Cables HDMI variados	S/M	S/M	S/N	110	Bueno	Mochila Roja	
VPNPRO118	Resp. 006	04/04/2023	Cable de audio XLR a CANON	S/M	S/M	S/N	110	Bueno	Mochila Roja	
VPNPRO119	Resp. 006	04/04/2023	Cable de Audio CANON a PLUG 3/4	S/M	S/M	S/N	109	Bueno	Mochila Roja	
VPNPRO174	Resp. 010	11/04/2023	Cable de RED de medio metro	S/M	S/M	S/N	109	Bueno	Mochilas semanera	
VPNPRO175	Resp. 010	11/04/2023	Splitter HDMI dos puertos 1x2 con cargador	KANEXPRO	S/M	S/N	109	Bueno	Caja Splitter	
VPNPRO176	Resp. 010	11/04/2023	(2) Video capturadores HDMI con cable	S/M	S/M	S/N	109	Bueno	Caja Splitter	1 se dio de baja (checar cual)
VPNPRO177	Resp. 010	11/04/2023	(3) Video capturadores HDMI sin cable	S/M	S/M	S/N	109	Bueno	Caja Splitter	
VPNPRO178	Resp. 010	11/04/2023	Splitter HDMI 4 puertos 4K con cargador	KANEXPRO	S/M	S/N	109	Bueno	Caja Splitter	No se encontro
VPNPRO221	Resp. 014		NewTek 3Play 425 Replay System with Control Surface (1)Teclado, (1) Mouse, (2) cables de corriente y (3) cables de USB a USB tipo B	NEWTEC	3PXD425	M8AF12714881042	119	Bueno	Bodega 1	
VPNPRO232	Resp. 014		Grabadora Hyperdeck Studio HD Mini Blackmagic Design	BlackMagic Desing	Studio HD Mini	5257015	119	Bueno	Switcher Grande	
VPNPRO233	Resp. 014		Tricaster Atem Television Studio	BlackMagic Desing	ATEM	4581391	119	Bueno	Switcher Grande	
VPNPRO283	Resp. 009		Convertidor de fibra optica 12 G con cargador y adaptador	Black magic design	S/M	7087333	104	Bueno	Bodega 1	
VPNPRO284	Resp. 009		Convertidor de fibra optica 12 G con cargador y adaptador	Black magic design	S/M	7087310	104	Bueno	Bodega 1	
VPNPRO285	Resp. 009		Convertidor de fibra optica 12 G con cargador y adaptador	Black magic design	S/M	7087201	104	Bueno	Bodega 1	
VPNRED018	Resp.16		MULTI GIGABIT WI-FI ACCESS POINT	TP-LINK	EAP660HD	2214391000367	201	Activo	Estudio	
VPNRED019	Resp.16		MULTI GIGABIT WI-FI ACCESS POINT	TP-LINK	EAP660HD	2214391000436	201	Activo	Sistemas y redes	
VPNRED020			Laptop con cargador	HP	RTL8723BE	5CG71530NS	Chepe Zazueta	Funcional	VPRO SPORTS	
VPNRED021			Adaptador de USB a RED	STEREN	506-430	S/N	201	Funcional	Sistemas y redes	
VPNEDI002	Resp.12		Memoria de 3 Tb	ADATA	HM9009T	1G2120121231	200	Bueno	Edición HD	
VPNEST048	RES-PRO-001	07/09/2023	(MONITOR #7) Kit de monitor LCD Field Monitor 7 pulgadas: Monitor, para sol, adaptador de bateria, fuente de poder con adaptador, cable HDMI.	LILIPUT	LI663OP2	663A6141R004	119	Bueno	Estudio TV	Sin adaptador de corriente a camara
VPNEST050	RES-PRO-001	07/09/2023	Tripie Libec T-72 (T72) Two-stage aluminium tripod with 75mm bowl	Libec	T72	S/N	119	Bueno	Estudio TV	
VPNPRO157	Resp. 010	11/04/2023	(3) Cables HDMI	S/M	S/M	S/N	109	Bueno	Mochilas semanera	
VPNAUD041		24/04/2024	(3) Cables Plug In de audio	UGREEN	15514	S/N	118		Departamento de audio	
VPNPRO262	Resp. 009		Micro Convertidor SDI a HDMI 3G Blackmagic Design	BlackMagic Desing	SDI a HDMI 3G	7516799	104	Bueno	Bodega 1	
VPNPRO263	Resp. 009		Micro Convertidor SDI a HDMI 3G Blackmagic Design	BlackMagic Desing	SDI a HDMI 3G	7546791	104	Bueno	Bodega 1	
VPNPRO322	Resp. 009		Consola de audio de 4 canales	TEYUN	A4	S/N	104	Bueno	Bodega 1	
VPNRED004			#3 Modem Banda Ancha USB #6675403204 (AT&T) PW: 1qaz2WSX	Huawei	E3276s-500	V7UDW15504000314	201	Baja	Bodega exterior	
VPNRED084			Laptop MAC #1 con mochila y adaptador	MAC	A1278	CIMQ2HVHDTY34	202	Bueno	Sistemas y redes	1344
VPNRED6JY		12/20/2026	EXPANSION CARD THUNDERBOLTEX 4(PCI)	ASUS	PCI	SCC0KC0018692RG	201	Bueno	Sistemas y redes	Se agrego a la pc del estudio
VPNRED999	VPNRED999	09/06/2025	ESTE LO HICE DE PRUEBA - VPNRED999	MER-VPNRED999	MSI059 -VPNRED999	S/N -VPNRED999	201	baja	Sistemas y redes	observac - VPNRED999
VPNSITE001		26/12/2024	Sistema Electrónico de Energia Ininterrumpida en Line con Regulador Integrado, con Stand (6zs) y cable thunderbolt a USB	KOBLENZ	20015 OL USB/R	23-04-24655	201.0	Nuevo	SITE	
VPNRED047	Resp.16	19/06/2024	Capturadora DckLink 8k Pro, 12G-SDI	BLACK MAGIC DESIGN	BDLKHCHPRO8K12G	12182005	201	Funcional	Sistemas y redes	
VPNRED039	Resp.16	20/02/2024	Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA	STARLINK	UTR-212	2DWC230900004657	201	DAÑADO	Sistemas y redes	KIT: KIT301582937
VPRO-AA-SISTEMAS	VPRO-AA-Sistemas-001	2023-07-31	A/Acondicioado Marca Mirage en la Ofna del Depto de Sistemas	Mirage	AATX	SIN N/S	Cuauhtemoc Rivera A.	DANADO	Instalacion Eeidifcio Vpro	Tira agua., ya se limpiaron los filtros.
VPNRED012		\N	BOND PRO HD/SDI V-MOUNT INTEGRADO HD-SDI CELLULAR BONDING SOLUTION 6 MODEM SUPPORT	TERADEK	BOND PRO	5900500	201	BUEN ESTADO	Sistemas y redes	
VPNRED097	VPNRED097	2026-08-01	UPS (No break) Koblenz CODIGO VPNRED097	Koblenz	4816 R	19-10-11217	Cuauhtemoc Rivera A.	BUEN ESTADO	OFICINA DE SISTEMAS	Se le reemplazaron las pilas el 01/08/2026
VPNRED100		\N	UPS (No-Break) Koblenz CODIGO VPNRED100	Koblenz	7011 USB/R	19-01-01-350	201	BUEN ESTADO	Depto. de SISTEMAS	Asignado a SISTEMAS, uso móvil
HC200		\N	Audifonos behringer HC200	behringer	HC200			BUEN ESTADO	BODEGA PRINCIPAL	
TELMEX-SERCOMM-GN25L95		\N	Modem infinitum telmex SERCOMM GN25L95	SERCOMM	GN25L95	SCOM207905D4	Sistemas	DAÑADO	SISTEMAS	Se dañó, ya se levantó reporte a telmex, reporte 11522457
VPNRED-SWITCH10/100		\N	Switch ethernet tp-link 10/100 tl-sf1016D (VPNRED-SWITCH10/100)	TP-LINK	TL-SF1016D	2237460008664	SISTEMAS	BUEN ESTADO	SISTEMAS	Sin cargador, se tomó prestado el de un switch tp-link de 5 pts (VPNEST015)
VPNRED060	Resp.16	2024-01-08	Modem de internet ZTE Megacable VPNRED060	ZTE	ZXHNF670L	ZTEEQHEMBX04817	201	BUEN ESTADO	Sistemas y redes	Equipo para uso en eventos en cln
\.


--
-- Data for Name: inventario_kits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventario_kits (id_inv_kits, codigo_inv_kits, responsiva_inv_kits, fecha_de_compra_inv_kits, descripcion_inv_kits, marca_inv_kits, modelo_inv_kits, serie_inv_kits, responsable_inv_kits, id_empleado_ref_inv_kits, estado_inv_kits, ubicacion_inv_kits, observaciones_inv_kits, fecha_registro_inv_kits) FROM stdin;
2630	Inv_Vpro_alt_00176	\N	\N	Distribuidor HDMI 1 a 4	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	\N	None	2026-06-24 10:58:22.619324
2631	Inv_Vpro_alt_00177	\N	\N	Distribuidor HDMI 1 a 2	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	\N	None	2026-06-24 10:58:22.619324
2632	Inv_Vpro_alt_00178	\N	\N	Bolsa de Arena	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	\N	None	2026-06-24 10:58:22.619324
2633	Inv_Vpro_alt_00179	\N	\N	Pisa Cable	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	\N	None	2026-06-24 10:58:22.619324
2634	Inv_Vpro_alt_00180	\N	\N	Multicontactos	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	\N	None	2026-06-24 10:58:22.619324
869	Inv_Vpro_alt_00042	\N	\N	Pantalla  55"	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	BODEGA		2026-05-08 19:51:12.846571
269	Inv_Vpro_alt_00026	\N	\N	Cable especial ethernet para StarLink (50 mts)	\N	\N	\N	Cuauhtémoc Rivera Agundez	201	Buen Estado	\N		2026-05-08 14:15:44.460662
2525	Inv_Vpro_alt_00145	\N	\N	Switch 5 puertos	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-11 16:20:51.652539
2526	Inv_Vpro_alt_00146	\N	\N	Desarmador de estrella	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-11 16:20:51.652539
2527	Inv_Vpro_alt_00147	\N	\N	Desarmador de pala	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-11 16:20:51.652539
2528	Inv_Vpro_alt_00148	\N	\N	Pinza ponchadora	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-11 16:20:51.652539
2529	Inv_Vpro_alt_00149	\N	\N	Bolsa con cinchos	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-11 16:20:51.652539
111	Inv_Vpro_alt_00014	resp_124	\N	Celular	\N	\N	\N	Manuel Eduardo Madrid	124	Buen Estado	En Evento	None	2026-05-07 12:15:33.980018
1375	Inv_Vpro_alt_00051	\N	\N	Carpa	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 13:36:51.648408
1035	Inv_Vpro_alt_00047	\N	\N	Extensiones	\N	\N	\N	José Francisco Torres Sanchez	118	Buen Estado	\N		2026-05-09 11:53:24.612385
873	Inv_Vpro_alt_00043	\N	\N	microfono shure de mano	\N	\N	\N	Héctor Rementeria de la Rocha	113	Buen Estado	\N		2026-05-09 11:23:05.495326
1603	Inv_Vpro_alt_00072	\N	\N	Abanico	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
1604	Inv_Vpro_alt_00073	\N	\N	Carpa	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
283	Inv_Vpro_alt_00027	\N	\N	Cuando el registro(ID,Descripción,Cantidad,Observaciones) se muestra así entonces si se graba	\N	\N	\N	Cuauhtémoc Rivera Agundez	201	Buen Estado	\N		2026-05-08 14:26:40.153743
2957	Inv_Vpro_alt_00238	\N	\N	Baterias  Sony	\N	\N	\N	Gerardo Villarreal Uribe	105	Buen Estado	BODEGA	None	2026-07-03 17:50:57.116765
1605	Inv_Vpro_alt_00074	\N	\N	Paragua	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
1606	Inv_Vpro_alt_00075	\N	\N	Caja de Herramientas	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
108	Inv_Vpro_alt_00012	resp_201	\N	Computadora de escritorio con dos monitores	\N	\N	\N	Cuauhtémoc Rivera Agundez	201	Buen Estado	BODEGA		2026-04-24 13:50:41.298362
1585	Inv_Vpro_alt_00054	\N	\N	Base de Guitarra	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
897	Inv_Vpro_alt_00044	\N	\N	pekey	\N	\N	\N	Héctor Rementeria de la Rocha	118	Buen Estado	\N		2026-05-09 11:26:37.178143
170	Inv_Vpro_alt_00020	\N	\N	Cables ethernet largos	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-05-07 19:50:19.936783
2637	Inv_Vpro_alt_00183	\N	\N	Switch 5 puertos	\N	\N	\N	Edgar Javier Amarillas	104	BUEN ESTADO	BODEGA		2026-06-24 10:58:22.619324
1587	Inv_Vpro_alt_00056	\N	\N	Distribuidor de HDMI de 8	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
1597	Inv_Vpro_alt_00066	\N	\N	Tela para Pantalla	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
1077	Inv_Vpro_alt_00048	\N	\N	Diablito	\N	\N	\N	José Francisco Torres Sanchez	105	Buen Estado	\N		2026-05-09 11:58:47.250621
1588	Inv_Vpro_alt_00057	\N	\N	Distribuidor de HDMI de 4	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
2269	VPRO_ALT_26642	\N	\N	convertidor blackmagic (SDI-HDMI)	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
2937	Inv_Vpro_alt_00237	\N	\N	BATERIAS SONY	\N	\N	\N	Jose Daniel Torres Arroyo	109	BUEN ESTADO	BODEGA		2026-07-03 17:06:31.415674
2926	Inv_Vpro_alt_00232	\N	\N	Transmisor Sony	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2927	Inv_Vpro_alt_00233	\N	\N	Receptor Sony	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2928	Inv_Vpro_alt_00234	\N	\N	Micrófono Lavalier	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
1589	Inv_Vpro_alt_00058	\N	\N	Distribuidor de HDMI de 2	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
1595	Inv_Vpro_alt_00064	\N	\N	Diablito	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
1583	Inv_Vpro_alt_00052	\N	\N	Cable HDMI	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	BODEGA		2026-05-11 19:14:08.613472
1584	Inv_Vpro_alt_00053	\N	\N	Extensiones	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	BODEGA		2026-05-11 19:14:08.613472
1600	Inv_Vpro_alt_00069	\N	\N	Cable de Fibra Optica	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
1601	Inv_Vpro_alt_00070	\N	\N	Convertidores de Fibra Optica	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
997	Inv_Vpro_alt_00046	resp_105	\N	TRIPIES	\N	\N	\N	José Daniel Torres Arroyo	105	Buen Estado	En Evento		2026-05-09 11:31:30.928329
1602	Inv_Vpro_alt_00071	\N	\N	Centro de Carga	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
110	Inv_Vpro_alt_00013	\N	\N	Laptop Asus con adaptador de red y cable de corriente	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-05-07 10:50:38.245716
1586	Inv_Vpro_alt_00055	\N	\N	Base de Fierro Alta	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	BODEGA		2026-05-11 19:14:08.613472
1590	Inv_Vpro_alt_00059	\N	\N	Pisa Cable (Yellow Jacket)	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	BODEGA		2026-05-11 19:14:08.613472
1591	Inv_Vpro_alt_00060	\N	\N	Corral	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	BODEGA		2026-05-11 19:14:08.613472
1299	Inv_Vpro_alt_00050	\N	\N	Control Remoto Pantalla	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 13:29:39.108573
1592	Inv_Vpro_alt_00061	\N	\N	Tela Corral	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	BODEGA		2026-05-11 19:14:08.613472
1599	Inv_Vpro_alt_00068	\N	\N	Balanceador	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
1593	Inv_Vpro_alt_00062	\N	\N	Mesa	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	BODEGA		2026-05-11 19:14:08.613472
1594	Inv_Vpro_alt_00063	\N	\N	Silla	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	BODEGA		2026-05-11 19:14:08.613472
1596	Inv_Vpro_alt_00065	\N	\N	Multicontacto	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	BODEGA		2026-05-11 19:14:08.613472
1598	Inv_Vpro_alt_00067	\N	\N	Cable SDI	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	BODEGA		2026-05-11 19:14:08.613472
2271	VPRO_ALT_26703	\N	\N	HDMI splitter (1x2)	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
1608	Inv_Vpro_alt_00077	\N	\N	Proyector	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
1609	Inv_Vpro_alt_00078	\N	\N	Base de Proyector	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
1610	Inv_Vpro_alt_00079	\N	\N	Pantalla Latex y Cuadro con Tripie	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
1611	Inv_Vpro_alt_00080	\N	\N	Bolsa contra Peso	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
1607	Inv_Vpro_alt_00076	\N	\N	Control Remoto Pantalla	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
1658	Inv_Vpro_alt_00083	\N	\N	Carpa	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:20:41.219445
2111	VPRO_ALT_16389	\N	\N	Cables SDI	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-05-28 19:03:18.717785
2113	VPRO_ALT_16445	\N	\N	HDMI	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-05-28 19:03:18.717785
1750	Inv_Vpro_alt_00087	\N	\N	Control Remoto Pantalla	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:37:25.948566
1612	Inv_Vpro_alt_00081	\N	\N	Base de Madera Tv	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
1613	Inv_Vpro_alt_00082	\N	\N	Dolly's	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:14:08.613472
1725	Inv_Vpro_alt_00084	\N	\N	Pantalla de 40"	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:34:46.130221
1726	Inv_Vpro_alt_00085	\N	\N	Tela de Base	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:34:46.130221
1727	Inv_Vpro_alt_00086	\N	\N	Yellow Jake(pisacable)	\N	\N	\N	José Francisco Torres Sanchez	104	Buen Estado	\N		2026-05-11 19:34:46.130221
1778	Inv_Vpro_alt_00088	\N	\N	vMix	\N	\N	\N	Osiel Cuauhtémoc Hernández Aldape	109	Buen Estado	\N	None	2026-05-20 18:44:02.78216
1873	Inv_Vpro_alt_00095	\N	\N	IMPRESORA SAMSUNG EXPRESS M2022	\N	\N	\N	Manuel Eduardo Madrid	124	Buen Estado	\N	None	2026-05-26 14:24:37.090349
1875	Inv_Vpro_alt_00096	\N	\N	TELEFONO PANASONIC	\N	\N	\N	Manuel Eduardo Madrid	124	Buen Estado	\N	no funcionaba la linea	2026-05-26 14:27:41.384826
2702	Inv_Vpro_alt_00184	\N	\N	Switch 8 puertos	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2703	Inv_Vpro_alt_00185	\N	\N	Cableado UTP cortos	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2092	VPRO_ALT_14873	\N	\N	Accesorio extra	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	None	2026-05-28 18:35:41.937688
2116	VPRO_ALT_16484	\N	\N	Carpa	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-05-28 19:03:18.717785
1899	Inv_Vpro_alt_00106	\N	\N	Silla1	\N	\N	\N	Andrea Maria Vilarreal Lopez	200	Buen Estado	BODEGA	El respaldo de la silla esta dañando por lo cual no se puede sostener solo.	2026-05-27 11:52:46.634474
1900	Inv_Vpro_alt_00107	\N	\N	Silla2	\N	\N	\N	Andrea Maria Vilarreal Lopez	200	Buen Estado	BODEGA	El respaldo de la silla esta dañando por lo cual no se puede sostener solo.	2026-05-27 11:52:46.634474
1901	Inv_Vpro_alt_00108	\N	\N	Silla3	\N	\N	\N	Andrea Maria Vilarreal Lopez	200	Buen Estado	BODEGA	La base donde están las llantas  esta quebrada y se extravió una llanta.	2026-05-27 11:52:46.634474
1902	Inv_Vpro_alt_00109	\N	\N	Silla1 de tela	\N	\N	\N	Andrea Maria Vilarreal Lopez	200	Buen Estado	BODEGA	La base donde están las llantas  esta quebrada y se extravió una llanta.	2026-05-27 11:52:46.634474
1903	Inv_Vpro_alt_00110	\N	\N	Silla2 de tela	\N	\N	\N	Andrea Maria Vilarreal Lopez	200	Buen Estado	BODEGA	La base donde están las llantas  esta quebrada y se extravió  dos llantas.	2026-05-27 11:52:46.634474
2136	VPRO_ALT_75546	\N	\N	Lampara Techo 1	\N	\N	\N	Andrea Maria Vilarreal Lopez	200	Buen Estado	BODEGA	Lampara de techo cuadrada, luz led.	2026-05-29 11:27:01.503177
2118	VPRO_ALT_16530	\N	\N	Multicontactos	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-05-28 19:03:18.717785
2119	VPRO_ALT_16540	\N	\N	Abanico	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-05-28 19:03:18.717785
2120	VPRO_ALT_16556	\N	\N	Grabadoras	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-05-28 19:03:18.717785
2180	VPRO_ALT_17725	\N	\N	base metal para monitor	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-06-02 10:31:15.940205
2112	VPRO_ALT_16418	\N	\N	extensiones	\N	\N	\N	Jose Daniel Torres Arroyo	104	Buen Estado	BODEGA	None	2026-05-28 19:03:18.717785
2115	VPRO_ALT_16469	\N	\N	sillas	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-05-28 19:03:18.717785
2114	VPRO_ALT_16456	\N	\N	mesa	\N	\N	\N	Jose Daniel Torres Arroyo	104	Buen Estado	BODEGA	None	2026-05-28 19:03:18.717785
1894	Inv_Vpro_alt_00101	\N	\N	dollys	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-05-26 19:09:20.517456
1895	Inv_Vpro_alt_00102	\N	\N	monitor de ingeneria	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-05-26 19:09:20.517456
2771	Inv_Vpro_alt_00210	\N	\N	Extenciones	\N	\N	\N	Jose Francisco Torres Sanchez	119	Buen Estado	BODEGA	None	2026-07-02 10:39:10.678835
2772	Inv_Vpro_alt_00211	\N	\N	Hdmi	\N	\N	\N	Jose Francisco Torres Sanchez	119	Buen Estado	BODEGA	None	2026-07-02 10:39:10.678835
2773	Inv_Vpro_alt_00212	\N	\N	Base de Pantallas Altas	\N	\N	\N	Jose Francisco Torres Sanchez	119	Buen Estado	BODEGA	None	2026-07-02 10:39:10.678835
1850	Inv_Vpro_alt_00090	\N	\N	bolsa de sinchos	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	None	2026-05-21 18:35:58.324156
1851	Inv_Vpro_alt_00091	\N	\N	desarmador estrella	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	None	2026-05-21 18:35:58.324156
2488	Inv_Vpro_alt_00157	\N	\N	Laptop HP	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-06-05 16:12:12.421551
2712	Inv_Vpro_alt_00194	\N	\N	Tablet Android	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2713	Inv_Vpro_alt_00195	\N	\N	Tripie para bocina	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2714	Inv_Vpro_alt_00196	\N	\N	Desarmador de estrella	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2715	Inv_Vpro_alt_00197	\N	\N	Desarmador de pala	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2718	Inv_Vpro_alt_00200	\N	\N	fuentes de póder	\N	\N	\N	Manuel Antonio Madrid Zazueta	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2709	Inv_Vpro_alt_00191	\N	\N	Celular institucional	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2716	Inv_Vpro_alt_00198	\N	\N	monitores	\N	\N	\N	Manuel Antonio Madrid Zazueta	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2717	Inv_Vpro_alt_00199	\N	\N	baterias para camara 320	\N	\N	\N	Manuel Antonio Madrid Zazueta	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2182	VPRO_ALT_17836	\N	\N	Monitor de 65"	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-06-02 10:31:15.940205
2168	VPRO_ALT_74716	\N	\N	Abanico	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-05-30 14:59:20.355648
1880	Inv_Vpro_alt_00099	\N	\N	radios	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-05-26 17:34:48.755318
1881	Inv_Vpro_alt_00100	\N	\N	balanceador	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-05-26 17:34:48.755318
2710	Inv_Vpro_alt_00192	\N	\N	Access point tp-link omada	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2711	Inv_Vpro_alt_00193	\N	\N	Ipad	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2935	Inv_Vpro_alt_00235	\N	\N	KIT LUCES	\N	\N	\N	Jose Daniel Torres Arroyo	109	Buen Estado	BODEGA	None	2026-07-03 17:06:31.415674
2041	VPRO_ALT_13165	\N	\N	miniblack	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-05-28 18:27:41.493889
2042	VPRO_ALT_13273	\N	\N	baterias para monitor	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-05-28 18:27:41.493889
2209	VPRO_ALT_23622	\N	\N	paraguas	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-06-02 12:07:28.347029
2519	Inv_Vpro_alt_00139	\N	\N	Cables ethernet cortos	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-11 16:20:51.652539
2517	Inv_Vpro_alt_00137	\N	\N	paraguas	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	\N	None	2026-06-05 18:52:47.239713
2552	Inv_Vpro_alt_00150	\N	\N	pantalla 55"	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-06-20 09:43:54.792002
2777	Inv_Vpro_alt_00213	\N	\N	Distribuidor HDMI "2"	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 10:51:20.317205
2724	Inv_Vpro_alt_00201	\N	\N	balanceador	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-06-29 18:57:01.349101
2725	Inv_Vpro_alt_00202	\N	\N	radios	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-06-29 18:57:01.349101
2726	Inv_Vpro_alt_00203	\N	\N	baterias para monitor	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-06-29 18:57:01.349101
2727	Inv_Vpro_alt_00204	\N	\N	monitor de ingenieria	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-06-29 18:57:01.349101
2498	Inv_Vpro_alt_00164	\N	\N	Cableado utp corto	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-05 17:51:27.117652
2520	Inv_Vpro_alt_00140	\N	\N	Cables ethernet largos	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-11 16:20:51.652539
2521	Inv_Vpro_alt_00141	\N	\N	Cables HDMI	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-11 16:20:51.652539
2522	Inv_Vpro_alt_00142	\N	\N	Laptop HP, con cargador	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-11 16:20:51.652539
2523	Inv_Vpro_alt_00143	\N	\N	Laptop ASUS, con cargador	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-11 16:20:51.652539
2524	Inv_Vpro_alt_00144	\N	\N	Adaptador ethernet usb	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-11 16:20:51.652539
2584	Inv_Vpro_alt_26705	\N	\N	UPS	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-20 10:17:53.895261
2728	Inv_Vpro_alt_00205	\N	\N	escaladores decimator	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-06-29 18:57:01.349101
2729	Inv_Vpro_alt_00206	\N	\N	convertidores blackmagic	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-06-29 18:57:01.349101
2518	Inv_Vpro_alt_00138	\N	\N	telepronter	\N	\N	\N	Jose Daniel Torres Arroyo	105	Buen Estado	BODEGA	None	2026-06-05 18:57:57.362458
1869	Inv_Vpro_alt_00093	\N	\N	cable especial de 50 mts de starlink	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	None	2026-05-21 18:42:44.941739
2936	Inv_Vpro_alt_00236	\N	\N	Laptop HP	\N	\N	\N	Edgar Javier Amarillas	109	BUEN ESTADO	BODEGA		2026-07-03 17:06:31.415674
2254	VPRO_ALT_26284	\N	\N	laptop Vmix g7	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
2553	Inv_Vpro_alt_00151	\N	\N	Cables HDMI	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-06-20 09:43:54.792002
2554	Inv_Vpro_alt_00152	\N	\N	Cables de Corriente	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-06-20 09:43:54.792002
2555	Inv_Vpro_alt_00153	\N	\N	Mesa	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-06-20 09:43:54.792002
2556	Inv_Vpro_alt_00154	\N	\N	Carpa	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-06-20 09:43:54.792002
2557	Inv_Vpro_alt_00155	\N	\N	Pisa Cables	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-06-20 09:43:54.792002
2558	Inv_Vpro_alt_00156	\N	\N	Base de Madera	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-06-20 09:43:54.792002
2492	Inv_Vpro_alt_00158	\N	\N	Sillas	\N	\N	\N	Jose Francisco Torres Sanchez	202	Buen Estado	BODEGA	None	2026-06-05 17:51:27.117652
2583	Inv_Vpro_alt_26704	\N	\N	Mac #4	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-20 10:17:53.895261
2493	Inv_Vpro_alt_00159	\N	\N	Carpa	\N	\N	\N	Jose Francisco Torres Sanchez	202	Buen Estado	BODEGA	None	2026-06-05 17:51:27.117652
2494	Inv_Vpro_alt_00160	\N	\N	Tela para Pantallas	\N	\N	\N	Jose Francisco Torres Sanchez	202	Buen Estado	BODEGA	None	2026-06-05 17:51:27.117652
2495	Inv_Vpro_alt_00161	\N	\N	Distribuidor 1 a 4	\N	\N	\N	Jose Francisco Torres Sanchez	202	Buen Estado	BODEGA	None	2026-06-05 17:51:27.117652
2496	Inv_Vpro_alt_00162	\N	\N	Laptop ASUS	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-05 17:51:27.117652
2585	Inv_Vpro_alt_26706	\N	\N	Cables SDI	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-20 10:17:53.895261
2586	Inv_Vpro_alt_26707	\N	\N	Monitor Lilliput	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-20 10:17:53.895261
2587	Inv_Vpro_alt_26708	\N	\N	Apuntador	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-20 10:17:53.895261
2624	Inv_Vpro_alt_00173	\N	\N	Cable SDI	\N	\N	\N	Jose Francisco Torres Sanchez	202	Buen Estado	\N	None	2026-06-23 10:50:55.31206
2616	Inv_Vpro_alt_00165	\N	\N	Cableado utp Largo	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-23 10:50:55.31206
2617	Inv_Vpro_alt_00166	\N	\N	UPS	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-23 10:50:55.31206
2618	Inv_Vpro_alt_00167	\N	\N	Adaptador ETH	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-23 10:50:55.31206
2619	Inv_Vpro_alt_00168	\N	\N	Pinza ponchadora	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-23 10:50:55.31206
2620	Inv_Vpro_alt_00169	\N	\N	Celular institucional	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-23 10:50:55.31206
2621	Inv_Vpro_alt_00170	\N	\N	Ipad	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-23 10:50:55.31206
2253	VPRO_ALT_26256	\N	\N	CAJA vMix	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
2360	VPRO_ALT_11376	\N	\N	VMIX de Estudio, cpu de escritorio	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-03 12:52:16.757568
968	Inv_Vpro_alt_00045	\N	\N	camaras 320	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-05-09 11:29:11.050718
1878	Inv_Vpro_alt_00097	\N	\N	baterias para camaras 320	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-05-26 17:34:48.755318
2622	Inv_Vpro_alt_00171	\N	\N	Tablet android	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-23 10:50:55.31206
2623	Inv_Vpro_alt_00172	\N	\N	Desarmador de estrella	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-23 10:50:55.31206
2754	Inv_Vpro_alt_00209	\N	\N	Paraguas	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-06-30 10:29:32.346857
2625	Inv_Vpro_alt_00174	\N	\N	CableHDMI	\N	\N	\N	Jose Francisco Torres Sanchez	202	Buen Estado	BODEGA	None	2026-06-23 10:50:55.31206
2626	Inv_Vpro_alt_00175	\N	\N	Extensiones	\N	\N	\N	Jose Francisco Torres Sanchez	202	Buen Estado	BODEGA	None	2026-06-23 10:50:55.31206
2919	Inv_Vpro_alt_00225	\N	\N	Sillas	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2920	Inv_Vpro_alt_00226	\N	\N	Grabadoras	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2921	Inv_Vpro_alt_00227	\N	\N	Multicontactos	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2908	Inv_Vpro_alt_00214	\N	\N	Distribuidor HDMI "4"	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2909	Inv_Vpro_alt_00215	\N	\N	Distribuidor HDMI "8"	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2910	Inv_Vpro_alt_00216	\N	\N	Carpa	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2911	Inv_Vpro_alt_00217	\N	\N	Monitor de 55''	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2912	Inv_Vpro_alt_00218	\N	\N	Monitor de 60''	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2913	Inv_Vpro_alt_00219	\N	\N	Monitor de 65''	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2914	Inv_Vpro_alt_00220	\N	\N	Base metal para monitor	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2915	Inv_Vpro_alt_00221	\N	\N	Pisa Cables	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2916	Inv_Vpro_alt_00222	\N	\N	Equipo no registrado	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2752	Inv_Vpro_alt_00207	\N	\N	Forros de cámara	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-06-30 10:29:32.346857
2753	Inv_Vpro_alt_00208	\N	\N	Banco	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-06-30 10:29:32.346857
2917	Inv_Vpro_alt_00223	\N	\N	Mesas pegables	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2918	Inv_Vpro_alt_00224	\N	\N	Control remoto para monitor	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2922	Inv_Vpro_alt_00228	\N	\N	Equipo no registrado	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2923	Inv_Vpro_alt_00229	\N	\N	Monitor de 40''	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2924	Inv_Vpro_alt_00230	\N	\N	Diablito	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
2925	Inv_Vpro_alt_00231	\N	\N	Cables SDI	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-07-02 13:37:57.791634
3018	Inv_Vpro_alt_00239	\N	\N	Switch tplink 5 puertos	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-07-07 17:19:18.190358
3019	Inv_Vpro_alt_00240	\N	\N	Cable utp corto	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-07-07 17:19:18.190358
3020	Inv_Vpro_alt_00241	\N	\N	Cable utp largo	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-07-07 17:19:18.190358
3021	Inv_Vpro_alt_00242	\N	\N	Antena starlink 03, 02	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-07-07 17:19:18.190358
2497	Inv_Vpro_alt_00163	\N	\N	Switch tplink 5 puertos	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-06-05 17:51:27.117652
3248	Inv_Vpro_alt_00256	\N	\N	Baterias Sony Alpha	\N	\N	\N	Carlos Jacobo Quezada Mendoza	109	Buen Estado	BODEGA	None	2026-07-23 10:36:32.585113
3028	Inv_Vpro_alt_00249	\N	\N	Multicontacto pequeño	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-07-07 17:19:18.190358
3026	Inv_Vpro_alt_00247	\N	\N	Extensión larga	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	None	2026-07-07 17:19:18.190358
3060	Inv_Vpro_alt_00251	\N	\N	Router inalámbrico Mercusys	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-07-07 17:43:42.97186
2361	VPRO_ALT_11423	\N	\N	Monitor gamer negro plano cod pdte	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-03 12:52:16.757568
2362	VPRO_ALT_11490	\N	\N	Kit de teclado mouse y receptor inalambricon cod pte	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-03 12:52:16.757568
2363	VPRO_ALT_11525	\N	\N	Panel de control TYST Video cod pte	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-03 12:52:16.757568
2364	VPRO_ALT_11545	\N	\N	Adaptador Display port hdmi cod Pte	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	Uno de ellos no sirve	2026-06-03 12:52:16.757568
2704	Inv_Vpro_alt_00186	\N	\N	Cableado UTP largos	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2705	Inv_Vpro_alt_00187	\N	\N	UPS (No-Break)	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2706	Inv_Vpro_alt_00188	\N	\N	Adaptador ETH	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2707	Inv_Vpro_alt_00189	\N	\N	Pinza ponchadora	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2708	Inv_Vpro_alt_00190	\N	\N	Modem Quantum	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-06-29 18:52:05.296436
2474	Inv_alt_00001	\N	\N	tripies	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-06-05 10:03:58.096702
3347	Inv_alt_1050001	\N	\N	Laptop con cargador y mouse para teleprompter	\N	\N	\N	Jose Daniel Torres Arroyo	105	Buen Estado	BODEGA	[CUST_EQ:Laptop con cargador y mouse para teleprompter]	2026-07-28 12:13:29.287264
3025	Inv_Vpro_alt_00246	\N	\N	Desarmador de pala	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-07-07 17:19:18.190358
3027	Inv_Vpro_alt_00248	\N	\N	Extensión eléctrica corta	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-07-07 17:19:18.190358
3029	Inv_Vpro_alt_00250	\N	\N	Tripié para bocina (sin tubo extensor)	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-07-07 17:19:18.190358
3371	Inv_alt_1130001	\N	\N	Camara Alpha VIII	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:Camara Alpha VIII] None	2026-07-28 12:34:54.671444
3372	Inv_alt_1130002	\N	\N	Estabilizador	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:Estabilizador] None	2026-07-28 12:34:54.671444
3346	INV_VPRO_ALT_00254	\N	\N	Pisa cables	\N	\N	\N	Cuauhtemoc Rivera Agundez	105	BUEN ESTADO	BODEGA		2026-07-28 12:13:29.287264
2259	VPRO_ALT_26379	\N	\N	Hub USB	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
3373	Inv_alt_1130003	\N	\N	Cargador Sony Alpha	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:Cargador Sony Alpha] None	2026-07-28 12:34:54.671444
3344	INV_VPRO_ALT_00236	\N	\N	TRIPIES	\N	\N	\N	Manuel Eduardo Madrid	105	BUEN ESTADO	BODEGA		2026-07-28 12:13:29.287264
3357	INV_VPRO_ALT_00152	\N	\N	Cables de Corriente	\N	\N	\N	Jose Daniel Torres Arroyo	105	BUEN ESTADO	BODEGA		2026-07-28 12:22:52.919869
3354	INV_ALT_1050001	\N	\N	Laptop con cargador y mouse para teleprompter	\N	\N	\N	Jose Daniel Torres Arroyo	105	Buen Estado	BODEGA		2026-07-28 12:22:52.919869
3022	Inv_Vpro_alt_00243	\N	\N	UPS (No break) Koblenz	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-07-07 17:19:18.190358
3023	Inv_Vpro_alt_00244	\N	\N	Mesa pequeña	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-07-07 17:19:18.190358
3343	INV_VPRO_ALT_00235	\N	\N	KIT LUCES	\N	\N	\N	Jose Daniel Torres Arroyo	105	BUEN ESTADO	BODEGA		2026-07-28 12:13:29.287264
3024	Inv_Vpro_alt_00245	\N	\N	Desarmador de estrella	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-07-07 17:19:18.190358
3080	Inv_Vpro_alt_00254	\N	\N	Pisa cables	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-07-07 17:47:56.7174
3218	Inv_Vpro_alt_00255	\N	\N	Switch tp-link 8 puertos	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-07-22 18:16:36.689942
3363	Inv_alt_1090001	\N	\N	Century	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Century] None	2026-07-28 12:30:23.673469
3364	Inv_alt_1090002	\N	\N	Diadema Sony	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Diadema Sony] None	2026-07-28 12:30:23.673469
3365	Inv_alt_1090003	\N	\N	(4) Microfonos ambientales de camara	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:(4) Microfonos ambientales de camara]	2026-07-28 12:30:23.673469
3366	Inv_alt_1090004	\N	\N	Grabadora TASCAM	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Grabadora TASCAM] None	2026-07-28 12:30:23.673469
3367	Inv_alt_1090005	\N	\N	Body para microfono	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Body para microfono] None	2026-07-28 12:30:23.673469
3369	Inv_alt_1090006	\N	\N	cableado sin espesificar	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:cableado sin espesificar] None	2026-07-28 12:30:23.673469
3390	INV_ALT_1130001	\N	\N	Camara Alpha VIII	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA		2026-07-28 14:37:55.922312
3391	INV_ALT_1130002	\N	\N	Estabilizador	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA		2026-07-28 14:37:55.922312
3397	INV_ALT_1090002	\N	\N	Diadema Sony	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA		2026-07-28 14:40:15.940233
3398	INV_ALT_1090003	\N	\N	(4) Microfonos ambientales de camara	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA		2026-07-28 14:40:15.940233
3399	INV_ALT_1090004	\N	\N	Grabadora TASCAM	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA		2026-07-28 14:40:15.940233
3402	INV_ALT_1090006	\N	\N	cableado para microfono	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA		2026-07-28 14:40:15.940233
3411	Inv_alt_1050002	\N	\N	lap -top pronter	\N	\N	\N	Jose Daniel Torres Arroyo	105	Buen Estado	BODEGA	[CUST_EQ:lap -top pronter] None	2026-07-30 11:27:29.576065
3413	Inv_alt_1090007	\N	\N	Transmisor SONY VPNAUD002	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Transmisor SONY VPNAUD002] None	2026-07-31 11:55:24.973743
3414	Inv_alt_1090008	\N	\N	Receptor SONY VPNAUD002	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Receptor SONY VPNAUD002]	2026-07-31 11:55:24.973743
3415	Inv_alt_1090009	\N	\N	Cableado de MIC VPNAUDOO1 Y VPNAUD002	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Cableado de MIC VPNAUDOO1 Y VPNAUD002]	2026-07-31 11:55:24.973743
3416	Inv_alt_1090010	\N	\N	Tripié CENTURY	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Tripié CENTURY]	2026-07-31 11:55:24.973743
3418	Inv_alt_1090011	\N	\N	Audífonos SONY VPNAUD019	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Audífonos SONY VPNAUD019]	2026-07-31 11:55:24.973743
3419	Inv_alt_1090012	\N	\N	Grabadora TASCAM VPNAUD017	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Grabadora TASCAM VPNAUD017]	2026-07-31 11:55:24.973743
3400	INV_ALT_1090005	\N	\N	Boom para Microfono	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA		2026-07-28 14:40:15.940233
3422	Inv_alt_1090013	\N	\N	Audifonos VPNAUD065	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Audifonos VPNAUD065] None	2026-07-31 11:55:24.973743
3368	INV_VPRO_ALT_00178	\N	\N	Bolsa de Arena	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	BUEN ESTADO	BODEGA		2026-07-28 12:30:23.673469
3423	Inv_alt_2000001	\N	\N	Computadora Mac	\N	\N	\N	Andrea Maria Vilarreal Lopez	200	Buen Estado	BODEGA	[CUST_EQ:Computadora Mac] Computadora MAC asignada a Andrea	2026-08-01 10:51:37.792208
3424	Inv_alt_2000002	\N	\N	Disco Duro	\N	\N	\N	Andrea Maria Vilarreal Lopez	200	Buen Estado	BODEGA	[CUST_EQ:Disco Duro] Disco duro con nombre "Vmix"	2026-08-01 10:51:37.792208
3425	Inv_alt_1020001	\N	\N	CAMARA SONY FS7	\N	\N	\N	Gerardo Villarreal Uribe	102	Buen Estado	BODEGA	[CUST_EQ:CAMARA SONY FS7] None	2026-08-02 19:36:04.543658
3426	Inv_alt_1020002	\N	\N	BATERIAS SONY V MOUNT	\N	\N	\N	Gerardo Villarreal Uribe	102	Buen Estado	BODEGA	[CUST_EQ:BATERIAS SONY V MOUNT] None	2026-08-02 19:36:04.543658
3427	Inv_alt_1020003	\N	\N	TRIPIE LIBEC	\N	\N	\N	Gerardo Villarreal Uribe	102	Buen Estado	BODEGA	[CUST_EQ:TRIPIE LIBEC] None	2026-08-02 19:36:04.543658
3428	Inv_alt_1020004	\N	\N	KIT DE LENTES	\N	\N	\N	Gerardo Villarreal Uribe	102	Buen Estado	BODEGA	[CUST_EQ:KIT DE LENTES] None	2026-08-02 19:36:04.543658
118	Inv_Vpro_alt_00016	\N	\N	Access Point TP-Link modelo  AX3600	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-05-07 18:58:59.936589
128	Inv_Vpro_alt_00017	\N	\N	Switch de 5 puertos metalico	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-05-07 19:02:14.85114
3349	INV_VPRO_ALT_00230	\N	\N	Diablito	\N	\N	\N	Jose Francisco Torres Sanchez	105	BUEN ESTADO	BODEGA		2026-07-28 12:13:29.287264
2258	VPRO_ALT_26361	\N	\N	Mac #3 Mac #4	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
3396	INV_ALT_1090001	\N	\N	Century	\N	\N	\N	Jose Daniel Torres Arroyo	109	Buen Estado	BODEGA		2026-07-28 14:40:15.940233
3370	INV_VPRO_ALT_00256	\N	\N	Baterias Sony Alpha	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	BUEN ESTADO	BODEGA		2026-07-28 12:34:54.671444
3348	INV_VPRO_ALT_00101	\N	\N	dollys	\N	\N	\N	Manuel Antonio Madrid Zazueta	105	BUEN ESTADO	BODEGA		2026-07-28 12:13:29.287264
3358	INV_VPRO_ALT_00151	\N	\N	Cables HDMI	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	105	BUEN ESTADO	BODEGA		2026-07-28 12:22:52.919869
3345	INV_VPRO_ALT_00237	\N	\N	Baterias Sony	\N	\N	\N	Jose Daniel Torres Arroyo	105	BUEN ESTADO	BODEGA		2026-07-28 12:13:29.287264
2262	VPRO_ALT_26448	\N	\N	HDMI	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
141	Inv_Vpro_alt_00018	\N	\N	Switch de 5 puertos de plastico negro	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-05-07 19:06:33.756905
185	Inv_Vpro_alt_00021	\N	\N	Pinza para ponchar cables ethernet	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-05-07 19:52:03.242922
194	Inv_Vpro_alt_00022	\N	\N	plugs para cables ethernet	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-05-08 14:06:44.256234
256	Inv_Vpro_alt_00025	\N	\N	UPS	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-05-08 14:14:16.863199
1849	Inv_Vpro_alt_00089	\N	\N	Adaptador ethernet	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	None	2026-05-21 18:35:58.324156
1852	Inv_Vpro_alt_00092	\N	\N	escalera plegable	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	None	2026-05-21 18:35:58.324156
1870	Inv_Vpro_alt_00094	\N	\N	celular azul	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	None	2026-05-21 18:42:44.941739
1898	Inv_Vpro_alt_00105	\N	\N	cabezal	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-05-26 19:09:20.517456
3494	Inv_alt_1090019	\N	\N	Computador de Audio EN MALETA NARANJA VPNAUD062	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Computador de Audio EN MALETA NARANJA VPNAUD062] None	2026-08-03 14:02:15.415783
3461	Inv_vpro_alt_00001	\N	\N	tripies	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-03 13:44:29.477541
1896	Inv_Vpro_alt_00103	\N	\N	monitor lilliput	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-05-26 19:09:20.517456
1897	Inv_Vpro_alt_00104	\N	\N	bancos	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-05-26 19:09:20.517456
3497	INV_VPRO_ALT_00053	\N	\N	Extensiones	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-03 14:08:18.075597
3498	INV_VPRO_ALT_00057	\N	\N	Distribuidor de HDMI de 4	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-03 14:08:18.075597
3489	Inv_alt_1090014	\N	\N	Transmisor de audio SONY VPNAUD009	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Transmisor de audio SONY VPNAUD009] None	2026-08-03 14:02:15.415783
3490	Inv_alt_1090015	\N	\N	Receptor de audio SONY VPNAUD008	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Receptor de audio SONY VPNAUD008] None	2026-08-03 14:02:15.415783
3491	Inv_alt_1090016	\N	\N	Microfono de solapa SONY VPNAUD001	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Microfono de solapa SONY VPNAUD001] None	2026-08-03 14:02:15.415783
3492	Inv_alt_1090017	\N	\N	Diademas de comunicación BEHRINGER VPNAUD065	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Diademas de comunicación BEHRINGER VPNAUD065] None	2026-08-03 14:02:15.415783
3493	Inv_alt_1090018	\N	\N	Diadema de comunicación SONY VPNAUD019	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Diadema de comunicación SONY VPNAUD019] None	2026-08-03 14:02:15.415783
3755	INV_ALT_1090025	\N	\N	bateria AA	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA		2026-08-04 17:46:09.06974
3554	Inv_alt_1040001	\N	\N	kit de luces	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:kit de luces] None	2026-08-04 14:05:50.678728
3556	Inv_alt_1040002	\N	\N	baterias zgzine	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:baterias zgzine] None	2026-08-04 14:05:50.678728
3557	Inv_alt_1040003	\N	\N	cargador de pila	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:cargador de pila] None	2026-08-04 14:05:50.678728
233	Inv_Vpro_alt_00024	\N	\N	Tripie	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-05-08 14:12:17.06438
2263	VPRO_ALT_26466	\N	\N	cables XLR	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
2268	VPRO_ALT_26607	\N	\N	Stream Deck	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
3773	INV_ALT_1090014	\N	\N	Transmisor de audio SONY VPNAUD009	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	[CUST_EQ:Transmisor de audio SONY VPNAUD009] None	2026-08-04 17:46:09.06974
157	Inv_Vpro_alt_00019	\N	\N	Caja con 50 cables de red de dif tamaños	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-05-07 19:11:53.797351
222	Inv_Vpro_alt_00023	\N	\N	pisacables	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-05-08 14:09:41.16263
2266	VPRO_ALT_26558	\N	\N	Convertidor blackmagic (SDI-HDMI)	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
3774	INV_ALT_1090015	\N	\N	Receptor de audio SONY VPNAUD008	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	[CUST_EQ:Receptor de audio SONY VPNAUD008] None	2026-08-04 17:46:09.06974
2256	VPRO_ALT_26326	\N	\N	Consola audio (mini vMix)	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
3495	INV_VPRO_ALT_00042	\N	\N	Pantalla  55"	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-03 14:08:18.075597
3503	INV_VPRO_ALT_00084	\N	\N	Pantalla de 40"	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-03 14:08:18.075597
3496	INV_VPRO_ALT_00052	\N	\N	Cable HDMI	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-03 14:08:18.075597
2270	VPRO_ALT_26673	\N	\N	adaptador tipo C a HDMI	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
3445	INV_VPRO_ALT_00015	\N	\N	Starklink con maleta, modem,soporte, adaptador a ethernet, cable especial ethernet-par starlink de 18 mts.	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	BUEN ESTADO	BODEGA		2026-08-03 13:41:37.988359
3500	INV_VPRO_ALT_00065	\N	\N	Multicontacto	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-03 14:08:18.075597
3457	INV_VPRO_ALT_00093	\N	\N	cable especial de 50 mts de starlink	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	BUEN ESTADO	BODEGA		2026-08-03 13:41:37.988359
2257	VPRO_ALT_26346	\N	\N	Capturadoras HDMI	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
2267	VPRO_ALT_26591	\N	\N	Peavey	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
3582	Inv_alt_2020001	\N	\N	Cable largo para starlink	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Cable largo para starlink]	2026-08-04 16:48:59.867395
3599	Inv_alt_2020002	\N	\N	Cable ethernet corto	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Cable ethernet corto]	2026-08-04 17:08:21.436245
3600	Inv_alt_2020003	\N	\N	Cable ethernet largo	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Cable ethernet largo] None	2026-08-04 17:08:21.436245
3616	Inv_alt_1050003	\N	\N	Pantalla de 50"	\N	\N	\N	Jose Daniel Torres Arroyo	105	Buen Estado	BODEGA	[CUST_EQ:Pantalla de 50"] None	2026-08-04 17:13:45.193679
3619	Inv_alt_1050004	\N	\N	hdmi 100 mts	\N	\N	\N	Jose Daniel Torres Arroyo	105	Buen Estado	BODEGA	[CUST_EQ:hdmi 100 mts] None	2026-08-04 17:13:45.193679
3620	Inv_alt_1050005	\N	\N	dolly	\N	\N	\N	Jose Daniel Torres Arroyo	105	Buen Estado	BODEGA	[CUST_EQ:dolly] None	2026-08-04 17:13:45.193679
3717	Inv_alt_1090020	\N	\N	Baterias AA	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Baterias AA] None	2026-08-04 17:42:08.236575
3625	Inv_alt_1050006	\N	\N	base de fierro	\N	\N	\N	Jose Daniel Torres Arroyo	105	Buen Estado	BODEGA	[CUST_EQ:base de fierro] None	2026-08-04 17:13:45.193679
3721	Inv_alt_1090021	\N	\N	cables XLR (3.5 MTS)	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:cables XLR (3.5 MTS)] None	2026-08-04 17:42:08.236575
3722	Inv_alt_1090022	\N	\N	cables xlr (5mts)	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:cables xlr (5mts)] None	2026-08-04 17:42:08.236575
3723	Inv_alt_1090023	\N	\N	bocina con cable de corriente	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:bocina con cable de corriente] None	2026-08-04 17:42:08.236575
3458	INV_VPRO_ALT_00094	\N	\N	celular azul	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-08-03 13:41:37.988359
3459	Inv_alt_2010001	\N	\N	Tablet samsung para monitoreo	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	[CUST_EQ:Tablet samsung para monitoreo] None	2026-08-03 13:41:37.988359
3724	Inv_alt_1090024	\N	\N	baterias AA	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:baterias AA] None	2026-08-04 17:42:08.236575
3754	Inv_alt_1090025	\N	\N	bateria AA	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:bateria AA] None	2026-08-04 17:42:27.190588
3455	INV_VPRO_ALT_00089	\N	\N	Adaptador ethernet	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	BUEN ESTADO	BODEGA		2026-08-03 13:41:37.988359
3598	INV_ALT_2020001	\N	\N	Cable largo para starlink	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA		2026-08-04 17:08:21.436245
3614	INV_ALT_2020002	\N	\N	Cable ethernet corto	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA		2026-08-04 17:10:23.357356
3499	INV_VPRO_ALT_00058	\N	\N	Distribuidor de HDMI de 2	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-03 14:08:18.075597
3502	INV_VPRO_ALT_00082	\N	\N	Dolly's	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-03 14:08:18.075597
3643	INV_ALT_1050004	\N	\N	hdmi 100 mts	\N	\N	\N	Jose Daniel Torres Arroyo	105	Buen Estado	BODEGA		2026-08-04 17:17:26.254009
3644	INV_ALT_1050005	\N	\N	dolly	\N	\N	\N	Jose Daniel Torres Arroyo	105	Buen Estado	BODEGA		2026-08-04 17:17:26.254009
3505	INV_VPRO_ALT_00086	\N	\N	Yellow Jake(pisacable)	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-03 14:08:18.075597
3814	Inv_alt_1090026	\N	\N	transmisores sony	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:transmisores sony] None	2026-08-04 17:46:53.622346
4052	Inv_alt_2020005	\N	\N	Swich de 8 puerto	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA	[CUST_EQ:Swich de 8 puerto] None	2026-08-06 18:18:51.425966
3840	INV_VPRO_ALT_00242	\N	\N	Antena starlink 03, 02	\N	\N	\N	Manuel Eduardo Madrid	202	BUEN ESTADO	BODEGA		2026-08-04 17:56:45.729766
3747	INV_ALT_1090024	\N	\N	Baterias AA	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-08-04 17:42:27.190588
3752	INV_ALT_1090022	\N	\N	cables xlr (5mts)	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-08-04 17:42:27.190588
3842	INV_VPRO_ALT_00244	\N	\N	Mesa pequeÃÂÃÂÃÂÃÂ±a	\N	\N	\N	Manuel Eduardo Madrid	202	BUEN ESTADO	BODEGA		2026-08-04 17:56:45.729766
3775	INV_ALT_1090016	\N	\N	Microfono de solapa SONY VPNAUD009	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	[CUST_EQ:Microfono de solapa SONY VPNAUD001] None	2026-08-04 17:46:09.06974
3776	INV_ALT_1090017	\N	\N	Diademas de comunicación BEHRINGER VPNAUD065	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	[CUST_EQ:Diademas de comunicaciÃ³n BEHRINGER VPNAUD065] None	2026-08-04 17:46:09.06974
3624	INV_VPRO_ALT_00173	\N	\N	cable sdi	\N	\N	\N	Jose Daniel Torres Arroyo	105	BUEN ESTADO	BODEGA		2026-08-04 17:13:45.193679
3777	INV_ALT_1090018	\N	\N	Diadema de comunicación SONY VPNAUD019	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	[CUST_EQ:Diadema de comunicaciÃ³n SONY VPNAUD019] None	2026-08-04 17:46:09.06974
3904	INV_ALT_1090026	\N	\N	TRANSMISORES SONY	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-08-05 11:31:27.429006
3649	INV_ALT_1050006	\N	\N	Base de fierro	\N	\N	\N	Manuel Eduardo Madrid	105	Buen Estado	BODEGA		2026-08-04 17:17:26.254009
3841	INV_VPRO_ALT_00243	\N	\N	UPS (No break) Koblenz CODIGO VPNRED099	\N	\N	\N	Cuauhtemoc Rivera Agundez	202	BUEN ESTADO	BODEGA		2026-08-04 17:56:45.729766
3507	INV_ALT_1040001	\N	\N	Kit de luces	\N	\N	\N	Jose Daniel Torres Arroyo	104	Buen Estado	BODEGA		2026-08-03 14:08:18.075597
3501	INV_VPRO_ALT_00081	\N	\N	Base de Madera Tv	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-03 14:08:18.075597
3504	INV_VPRO_ALT_00085	\N	\N	Tela de Base	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-03 14:08:18.075597
3543	INV_VPRO_ALT_00045	\N	\N	camaras 320	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	BUEN ESTADO	BODEGA		2026-08-04 13:56:50.098541
3615	INV_ALT_2020003	\N	\N	Cable ethernet largo	\N	\N	\N	Cuauhtemoc Rivera Agundez	202	Buen Estado	BODEGA		2026-08-04 17:10:23.357356
3751	INV_ALT_1090021	\N	\N	Transmisor SONY VPNAUD001	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	None	2026-08-04 17:42:27.190588
3640	INV_ALT_1050003	\N	\N	Pantalla de 50"	\N	\N	\N	Manuel Eduardo Madrid	105	Buen Estado	BODEGA		2026-08-04 17:17:26.254009
3753	INV_ALT_1090023	\N	\N	Bocina con Cable de corriente	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	None	2026-08-04 17:42:27.190588
3845	INV_VPRO_ALT_00248	\N	\N	ExtensiÃÂÃÂÃÂÃÂ³n elÃÂÃÂÃÂÃÂ©ctrica corta	\N	\N	\N	Manuel Eduardo Madrid	202	BUEN ESTADO	BODEGA		2026-08-04 17:56:45.729766
3846	INV_VPRO_ALT_00250	\N	\N	TripiÃÂÃÂÃÂÃÂ© para bocina (sin tubo extensor)	\N	\N	\N	Manuel Eduardo Madrid	202	BUEN ESTADO	BODEGA		2026-08-04 17:56:45.729766
3959	INV_ALT_2020004	\N	\N	Caja con cables ethernet	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA		2026-08-05 18:20:09.256338
4066	INV_ALT_2020005	\N	\N	Swich de 8 puerto	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA	None	2026-08-06 18:19:03.133499
3864	Inv_alt_2020004	\N	\N	Caja con cables ethernet	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Caja con cables ethernet] Contiene cables largos	2026-08-05 11:23:33.539082
3449	INV_VPRO_ALT_00019	\N	\N	Caja grande c/tapa azul con 50 cables cortos y largos	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	BUEN ESTADO	BODEGA	Estaba muy sucio y con lodo la tapa solamente	2026-08-03 13:41:37.988359
3451	INV_VPRO_ALT_00022	\N	\N	plugs para cables ethernet	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	BUEN ESTADO	BODEGA		2026-08-03 13:41:37.988359
3454	INV_VPRO_ALT_00025	\N	\N	UPS	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	BUEN ESTADO	BODEGA	Estaba muy sucio	2026-08-03 13:41:37.988359
4102	Inv_alt_1190002	\N	\N	distribuidores SDI	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:distribuidores SDI] None	2026-08-18 10:56:04.961021
4104	Inv_alt_1190004	\N	\N	RACK con 4 grabadoras	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:RACK con 4 grabadoras] None	2026-08-18 10:56:04.961021
113	Inv_Vpro_alt_00015	\N	\N	Starklink con maleta, modem,soporte, adaptador a ethernet, cable especial ethernet-par starlink de 18 mts.	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-05-07 18:57:48.30238
2635	Inv_Vpro_alt_00181	\N	\N	Extension electrica	\N	\N	\N	Cuauhtemoc Rivera Agundez	104	BUEN ESTADO	BODEGA		2026-06-24 10:58:22.619324
2636	Inv_Vpro_alt_00182	\N	\N	Switch de 48 puertos	\N	\N	\N	Cuauhtemoc Rivera Agundez	104	BUEN ESTADO	BODEGA		2026-06-24 10:58:22.619324
3061	Inv_Vpro_alt_00252	\N	\N	Mesita plegable de 1 mts.	\N	\N	\N	Cuauhtemoc Rivera Agundez	202	BUEN ESTADO	BODEGA		2026-07-07 17:43:42.97186
3079	Inv_Vpro_alt_00253	\N	\N	Ups marca guia	\N	\N	\N	Cuauhtemoc Rivera Agundez	202	BUEN ESTADO	BODEGA		2026-07-07 17:47:56.7174
3450	INV_VPRO_ALT_00021	\N	\N	Pinza para ponchar cables ethernet	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	BUEN ESTADO	BODEGA		2026-08-03 13:41:37.988359
3546	INV_VPRO_ALT_00098	\N	\N	fuentes de poder	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	BUEN ESTADO	BODEGA		2026-08-04 13:56:50.098541
3453	INV_VPRO_ALT_00024	\N	\N	Tripie	\N	\N	\N	Manuel Antonio Madrid Zazueta	201	BUEN ESTADO	BODEGA		2026-08-03 13:41:37.988359
3552	INV_VPRO_ALT_00104	\N	\N	Bancos	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	BUEN ESTADO	BODEGA		2026-08-04 13:56:50.098541
3452	INV_VPRO_ALT_00023	\N	\N	Pisacables	\N	\N	\N	Jose Francisco Torres Sanchez	201	BUEN ESTADO	BODEGA		2026-08-03 13:41:37.988359
3843	INV_VPRO_ALT_00245	\N	\N	Desarmador de estrella	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-08-04 17:56:45.729766
4101	Inv_alt_1190001	\N	\N	escaladores	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:escaladores] None	2026-08-18 10:56:04.961021
3447	INV_VPRO_ALT_00017	\N	\N	Switch de 5 puertos metalico cod VPNRED051	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	BUEN ESTADO	BODEGA		2026-08-03 13:41:37.988359
3551	INV_VPRO_ALT_00103	\N	\N	monitor lilliput	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	BUEN ESTADO	BODEGA		2026-08-04 13:56:50.098541
3844	INV_VPRO_ALT_00246	\N	\N	Desarmador de pala	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-08-04 17:56:45.729766
3545	INV_VPRO_ALT_00097	\N	\N	baterias	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	BUEN ESTADO	BODEGA		2026-08-04 13:56:50.098541
3444	INV_VPRO_ALT_00013	\N	\N	Laptop Asus con adaptador de red y cable de corriente	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	BUEN ESTADO	BODEGA		2026-08-03 13:41:37.988359
3448	INV_VPRO_ALT_00018	\N	\N	Switch de 5 puertos de plastico negro NCA TP-LINK	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	BUEN ESTADO	BODEGA		2026-08-03 13:41:37.988359
4051	INV_VPRO_ALT_00189	\N	\N	Pinza ponchadora passthrough	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-08-06 18:18:51.425966
3446	INV_VPRO_ALT_00016	\N	\N	Access Point TP-Link modelo  AX3600 VPNRED018	\N	\N	\N	Edgar Javier Amarillas	201	BUEN ESTADO	BODEGA		2026-08-03 13:41:37.988359
3548	INV_VPRO_ALT_00100	\N	\N	balanceador	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	BUEN ESTADO	BODEGA		2026-08-04 13:56:50.098541
3847	INV_VPRO_ALT_00252	\N	\N	Mesita plegable de 1 mts.	\N	\N	\N	Cuauhtemoc Rivera Agundez	202	BUEN ESTADO	BODEGA		2026-08-04 17:56:45.729766
3456	INV_VPRO_ALT_00092	\N	\N	Escalera de tijera grande	\N	\N	\N	Edgar Javier Amarillas	201	BUEN ESTADO	BODEGA		2026-08-03 13:41:37.988359
3550	INV_VPRO_ALT_00102	\N	\N	Monitor de ingeneria	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	BUEN ESTADO	BODEGA		2026-08-04 13:56:50.098541
3547	INV_VPRO_ALT_00099	\N	\N	Radios	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	BUEN ESTADO	BODEGA		2026-08-04 13:56:50.098541
3544	INV_VPRO_ALT_00001	\N	\N	TRIPIES	\N	\N	\N	Jose Daniel Torres Arroyo	119	BUEN ESTADO	BODEGA		2026-08-04 13:56:50.098541
4231	INV_ALT_1190001	\N	\N	escaladores	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:escaladores] None	2026-08-18 12:17:18.777231
4232	INV_ALT_1190002	\N	\N	distribuidores SDI	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:distribuidores SDI] None	2026-08-18 12:17:18.777231
4209	INV_VPRO_ALT_00184	\N	\N	Switch 8 puertos	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 12:11:03.486403
4114	INV_VPRO_ALT_00181	\N	\N	Extension electrica	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	BUEN ESTADO	BODEGA		2026-08-18 10:59:19.357
4115	INV_VPRO_ALT_00182	\N	\N	Switch de 48 puertos	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-08-18 10:59:19.357
4103	Inv_alt_1190003	\N	\N	RACK con SW, grabadora SD, grabadora imperdec,	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:RACK con SW, grabadora SD, grabadora imperdec,] None	2026-08-18 10:56:04.961021
4105	Inv_alt_1190005	\N	\N	mochila negra	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:mochila negra] None	2026-08-18 10:56:04.961021
4106	Inv_alt_1190006	\N	\N	cinta gris	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:cinta gris] None	2026-08-18 10:56:04.961021
4107	Inv_alt_1190007	\N	\N	bolsa de cinchos	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:bolsa de cinchos] None	2026-08-18 10:56:04.961021
4108	Inv_alt_1190008	\N	\N	microconverter bidireccional	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:microconverter bidireccional] None	2026-08-18 10:56:04.961021
4109	Inv_alt_1190009	\N	\N	imperdecs	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:imperdecs] None	2026-08-18 10:56:04.961021
4110	Inv_alt_1190010	\N	\N	memorias SD	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:memorias SD] None	2026-08-18 10:56:04.961021
4233	INV_ALT_1190003	\N	\N	RACK con SW, grabadora SD, grabadora imperdec,	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:RACK con SW, grabadora SD, grabadora imperdec,] None	2026-08-18 12:17:18.777231
4206	Inv_alt_2010002	\N	\N	cables largos azules	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	[CUST_EQ:cables largos azules] None	2026-08-18 11:37:38.372514
4207	Inv_alt_2020006	\N	\N	Portátil HP	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Portátil HP]	2026-08-18 12:11:03.486403
4208	Inv_alt_2020007	\N	\N	Portátil ASUS	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Portátil ASUS]	2026-08-18 12:11:03.486403
4210	Inv_alt_2020008	\N	\N	Adaptador ethernet usb c	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Adaptador ethernet usb c]	2026-08-18 12:11:03.486403
4211	Inv_alt_2020009	\N	\N	Caja grande c/tapa azul con cables ethernet cortos y largos	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Caja grande c/tapa azul con cables ethernet cortos y largos]	2026-08-18 12:11:03.486403
4212	Inv_alt_2020010	\N	\N	Kit convertidor de medios ethernet a fibra	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Kit convertidor de medios ethernet a fibra]	2026-08-18 12:11:03.486403
4217	Inv_alt_2020011	\N	\N	Cable de fibra óptica 120 mts	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Cable de fibra óptica 120 mts]	2026-08-18 12:11:03.486403
4218	Inv_alt_2020012	\N	\N	Adaptadores SC/PC a SC/PC	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Adaptadores SC/PC a SC/PC]	2026-08-18 12:11:03.486403
4219	Inv_alt_2020013	\N	\N	Nobreak	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Nobreak]	2026-08-18 12:11:03.486403
4220	Inv_alt_2020014	\N	\N	Tableta Smasung Galaxy Tabl A9 (color grafito) con adaptador de energía, cable de corriente y protector.	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Tableta Smasung Galaxy Tabl A9 (color grafito) con adaptador de energía, cable de corriente y protector.]	2026-08-18 12:11:03.486403
4234	INV_ALT_1190004	\N	\N	RACK con 4 grabadoras	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:RACK con 4 grabadoras] None	2026-08-18 12:17:18.777231
4235	INV_ALT_1190005	\N	\N	mochila negra	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:mochila negra] None	2026-08-18 12:17:18.777231
4244	INV_ALT_2020008	\N	\N	Adaptador ethernet usb c	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 12:21:05.617014
4255	Inv_alt_2020015	\N	\N	Frasco con terminales utp cat 6	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Frasco con terminales utp cat 6]	2026-08-18 12:21:05.617014
4256	Inv_alt_2020016	\N	\N	(2) Adaptadores Starlink SPX a RJ45 para generación 2	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:(2) Adaptadores Starlink SPX a RJ45 para generación 2]	2026-08-18 12:21:05.617014
2117	VPRO_ALT_16514	\N	\N	Pisa Cables Yellow Jacket	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-05-28 19:03:18.717785
4252	INV_ALT_2020012	\N	\N	Adaptadores SC/PC a SC/PC	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 12:21:05.617014
4267	INV_VPRO_ALT_00055	\N	\N	Base de fierro Alta	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-18 12:49:00.126422
4251	INV_ALT_2020011	\N	\N	Cable de fibra óptica 120 mts completo con terminales SC/APC	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 12:21:05.617014
4237	INV_ALT_1190007	\N	\N	Bolsa de cinchos	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:bolsa de cinchos] None	2026-08-18 12:17:18.777231
4236	INV_ALT_1190006	\N	\N	cinta gris	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:cinta gris] None	2026-08-18 12:17:18.777231
4295	Inv_alt_1190011	\N	\N	microconverter SDI A HDMI con su A/C	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:microconverter SDI A HDMI con su A/C] None	2026-08-18 12:55:36.616297
4296	Inv_alt_1190012	\N	\N	microconverter HDMI A SDI con su A/C	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:microconverter HDMI A SDI con su A/C] None	2026-08-18 12:55:36.616297
4297	Inv_alt_1190013	\N	\N	lector de memorias para SD con su cable USB	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:lector de memorias para SD con su cable USB] None	2026-08-18 12:55:36.616297
4298	Inv_alt_1190014	\N	\N	lector de memorias para imperdec con su cable USB y A/C	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:lector de memorias para imperdec con su cable USB y A/C] None	2026-08-18 12:55:36.616297
4241	INV_ALT_2020006	\N	\N	Portátil HP	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 12:21:05.617014
4242	INV_ALT_2020007	\N	\N	Portátil ASUS	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 12:21:05.617014
4246	INV_ALT_2020010	\N	\N	Kit convertidor de medios ethernet a fibra VPNRED112	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 12:21:05.617014
2181	VPRO_ALT_17765	\N	\N	Base de guitarra	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	None	2026-06-02 10:31:15.940205
4253	INV_ALT_2020013	\N	\N	UPS/Nobreak HIKVISION VPNRED077	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 12:21:05.617014
4240	INV_ALT_1190010	\N	\N	Memorias SD	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA	[CUST_EQ:memorias SD] None	2026-08-18 12:17:18.777231
4245	INV_ALT_2020009	\N	\N	Caja grande c/tapa azul con cables ethernet cortos y largos	\N	\N	\N	Cuauhtemoc Rivera Agundez	202	Buen Estado	BODEGA		2026-08-18 12:21:05.617014
4315	Inv_alt_2020017	\N	\N	Equipo Celular Samsung SM-A307G #6672173818 PW:Jovasa11	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Equipo Celular Samsung SM-A307G #6672173818 PW:Jovasa11]	2026-08-18 12:56:46.246729
4317	Inv_alt_2020018	\N	\N	Adaptador ethernet USB tipo C a RJ45 Gigabit	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Adaptador ethernet USB tipo C a RJ45 Gigabit]	2026-08-18 12:56:46.246729
4318	Inv_alt_2020019	\N	\N	Adaptadores eth a eth cat 6	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Adaptadores eth a eth cat 6]	2026-08-18 12:56:46.246729
4312	INV_ALT_2020015	\N	\N	Frasco con terminales utp cat 6	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 12:56:46.246729
4259	INV_VPRO_ALT_00060	\N	\N	Corral	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-18 12:49:00.126422
4260	INV_VPRO_ALT_00061	\N	\N	Tela Corral	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-18 12:49:00.126422
4261	INV_VPRO_ALT_00174	\N	\N	CableHDMI	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-18 12:49:00.126422
4343	Inv_alt_1190015	\N	\N	laptop acer azul	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:laptop acer azul] None	2026-08-18 13:20:58.44271
4344	Inv_alt_1190016	\N	\N	cables SDI cortos	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:cables SDI cortos] None	2026-08-18 13:20:58.44271
4258	INV_VPRO_ALT_00153	\N	\N	Mesa	\N	\N	\N	Manuel Antonio Madrid Zazueta	104	BUEN ESTADO	BODEGA		2026-08-18 12:49:00.126422
4238	INV_ALT_1190008	\N	\N	microconverter bidireccional	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:microconverter bidireccional] None	2026-08-18 12:17:18.777231
4239	INV_ALT_1190009	\N	\N	imperdecs	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:imperdecs] None	2026-08-18 12:17:18.777231
4339	INV_ALT_1190011	\N	\N	microconverter SDI A HDMI con su A/C	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-18 13:20:58.44271
4340	INV_ALT_1190012	\N	\N	microconverter HDMI A SDI con su A/C	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-18 13:20:58.44271
4341	INV_ALT_1190013	\N	\N	lector de memorias para SD con su cable USB	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-18 13:20:58.44271
4262	INV_VPRO_ALT_00210	\N	\N	Extenciones	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-18 12:49:00.126422
4271	INV_VPRO_ALT_00161	\N	\N	Distribuidor 1 a 4	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-18 12:49:00.126422
4272	INV_VPRO_ALT_00177	\N	\N	Distribuidor HDMI 1 a 2	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-18 12:49:00.126422
4274	INV_VPRO_ALT_00069	\N	\N	Cable de Fibra Optica	\N	\N	\N	Jose Francisco Torres Sanchez	104	BUEN ESTADO	BODEGA		2026-08-18 12:49:00.126422
4345	Inv_alt_1190017	\N	\N	cables HDMI cortos	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:cables HDMI cortos] None	2026-08-18 13:20:58.44271
4346	Inv_alt_1190018	\N	\N	cables de corriente negros cortos	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:cables de corriente negros cortos] None	2026-08-18 13:20:58.44271
4347	Inv_alt_1190019	\N	\N	barras de energia balnacas chicas	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:barras de energia balnacas chicas] None	2026-08-18 13:20:58.44271
4348	Inv_alt_1190020	\N	\N	cable negro USB-A a USB-B	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:cable negro USB-A a USB-B] None	2026-08-18 13:20:58.44271
4349	Inv_alt_1190021	\N	\N	cables de HDMI a MINI HDMI (NEGRO Y ROJO)	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:cables de HDMI a MINI HDMI (NEGRO Y ROJO)] None	2026-08-18 13:20:58.44271
4350	Inv_alt_1190022	\N	\N	cajita naranja con conectores y coples (HDMI 6, SDI 7, TE SDI 3)	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:cajita naranja con conectores y coples (HDMI 6, SDI 7, TE SDI 3)] None	2026-08-18 13:20:58.44271
4367	Inv_alt_2020020	\N	\N	Switch tp-link 8 puertos	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Switch tp-link 8 puertos]	2026-08-18 13:35:02.845495
4368	Inv_alt_2020021	\N	\N	Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA]	2026-08-18 13:35:02.845495
4369	Inv_alt_2020022	\N	\N	Starlink #2 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Starlink #2 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA]	2026-08-18 13:35:02.845495
4370	Inv_alt_2020023	\N	\N	Laptop HP Elitebook 845 G7 Notebook PC, con cargador VPNCOM007	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Laptop HP Elitebook 845 G7 Notebook PC, con cargador VPNCOM007]	2026-08-18 13:35:02.845495
4371	Inv_alt_2020024	\N	\N	Laptop Asus Vivobook 15" D1502IA-BQ179W Ryzen 5 8GB RAM 256GB SSD con cargador VPNRED033	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Laptop Asus Vivobook 15" D1502IA-BQ179W Ryzen 5 8GB RAM 256GB SSD con cargador VPNRED033]	2026-08-18 13:35:02.845495
4366	INV_ALT_2020019	\N	\N	Adaptadores eth a eth cat 6	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 13:35:02.845495
4452	INV_ALT_1090027	\N	\N	CONSOLA ZEDI 8	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-08-18 14:06:47.98422
2264	VPRO_ALT_26493	\N	\N	convertidor blackmagic vimodal	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
2265	VPRO_ALT_26522	\N	\N	convertidor blackmagic (HDMI-SDI)	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
4392	Inv_alt_2020025	\N	\N	Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED057	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED057]	2026-08-18 13:52:45.398156
4393	Inv_alt_2020026	\N	\N	Switch tp-link 8 puertos VPNRED095	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Switch tp-link 8 puertos VPNRED095]	2026-08-18 13:52:45.398156
4394	Inv_alt_2020027	\N	\N	Switch tp-link 8 puertos VPNRED096	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Switch tp-link 8 puertos VPNRED096]	2026-08-18 13:52:45.398156
4422	Inv_alt_1090027	\N	\N	Consola ZEDI 8	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Consola ZEDI 8]	2026-08-18 14:03:32.746627
4424	Inv_alt_1090028	\N	\N	MONITOR STEREN	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:MONITOR STEREN]	2026-08-18 14:03:32.746627
2261	VPRO_ALT_26433	\N	\N	Hub 1X6	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
3392	INV_VPRO_ALT_00253	\N	\N	Receptor SONY VPNAUD001	\N	\N	\N	Manuel Eduardo Madrid	109	BUEN ESTADO	BODEGA		2026-07-28 14:40:15.940233
3394	INV_VPRO_ALT_00255	\N	\N	Microfono Lavalier SONY VPNAUD001	\N	\N	\N	Manuel Eduardo Madrid	109	BUEN ESTADO	BODEGA		2026-07-28 14:40:15.940233
4423	INV_VPRO_ALT_00231	\N	\N	Cables SDI	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	BUEN ESTADO	BODEGA		2026-08-18 14:03:32.746627
4257	INV_VPRO_ALT_00026	\N	\N	Cable especial ethernet para StarLink (50 mts)	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-08-18 12:21:05.617014
4455	Inv_alt_1090029	\N	\N	Laptop de audio	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	[CUST_EQ:Laptop de audio]	2026-08-18 14:06:47.98422
2255	VPRO_ALT_26302	\N	\N	Atem SDI PRO ISO	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
4313	INV_ALT_2020016	\N	\N	KIT (2) Adaptadores Starlink SPX a RJ45 para generación 2	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA		2026-08-18 12:56:46.246729
4388	INV_ALT_2020021	\N	\N	Starlink #1 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA	\N	\N	\N	Cuauhtemoc Rivera Agundez	202	Buen Estado	BODEGA		2026-08-18 13:52:45.398156
4365	INV_ALT_2020018	\N	\N	Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED056	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 13:35:02.845495
2260	VPRO_ALT_26418	\N	\N	Hub 1X7	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	None	2026-06-02 12:58:42.325288
4254	INV_ALT_2020014	\N	\N	Tableta Smasung Galaxy Tabl A9 (color grafito) con adaptador de energía, cable de corriente y protector. VPNRED071	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 12:21:05.617014
4363	INV_ALT_2020017	\N	\N	Equipo Celular Samsung SM-A307G #6672173818 VPNRED 027	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 13:35:02.845495
4486	Inv_alt_1090030	\N	\N	Maleta de laptop	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	[CUST_EQ:Maleta de laptop]	2026-08-18 14:07:12.039833
4540	INV_ALT_2020026	\N	\N	Switch tp-link 8 puertos VPNRED095	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA		2026-08-18 14:33:39.287465
4517	Inv_alt_1090031	\N	\N	Laptop g7	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	[CUST_EQ:Laptop g7]	2026-08-18 14:10:19.069803
4542	Inv_alt_2020028	\N	\N	Escalera pegable	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA	[CUST_EQ:Escalera pegable]	2026-08-18 14:33:39.287465
4604	INV_ALT_1130007	\N	\N	Tripie con chancla	\N	\N	\N	Manuel Eduardo Madrid	113	Buen Estado	BODEGA		2026-08-20 18:24:37.877984
4605	INV_ALT_1130008	\N	\N	Kit de iluminacion 2000	\N	\N	\N	Manuel Eduardo Madrid	113	Buen Estado	BODEGA		2026-08-20 18:24:37.877984
4569	Inv_alt_2010003	\N	\N	cables cortos	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	[CUST_EQ:cables cortos]	2026-08-18 18:05:18.017301
4568	INV_VPRO_ALT_00166	\N	\N	UPS	\N	\N	\N	Jose Daniel Torres Arroyo	201	BUEN ESTADO	BODEGA		2026-08-18 18:05:18.017301
4614	INV_ALT_1130013	\N	\N	CABLE XLR	\N	\N	\N	Manuel Eduardo Madrid	113	Buen Estado	BODEGA		2026-08-20 18:24:37.877984
4551	INV_ALT_2010002	\N	\N	cables largos azules cat 6	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-08-18 14:35:07.160033
4541	INV_ALT_2020027	\N	\N	Switch tp-link 8 puertos VPNRED096	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA		2026-08-18 14:33:39.287465
4571	Inv_alt_2010004	\N	\N	frasco con plugs cat 6	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	[CUST_EQ:frasco con plugs cat 6]	2026-08-18 18:05:18.017301
4539	INV_ALT_2020025	\N	\N	Adaptador ethernet USB tipo C a RJ45 Gigabit TP-LINK VPNRED057	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 14:33:39.287465
4600	INV_ALT_1130004	\N	\N	Pilas AA	\N	\N	\N	Manuel Eduardo Madrid	113	Buen Estado	BODEGA		2026-08-20 18:24:37.877984
4584	Inv_alt_1130004	\N	\N	Pilas AA	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:Pilas AA]	2026-08-20 18:19:39.804972
4585	Inv_alt_1130005	\N	\N	Kit microfono Lavalier	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:Kit microfono Lavalier]	2026-08-20 18:19:39.804972
4586	Inv_alt_1130006	\N	\N	Camara x320	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:Camara x320]	2026-08-20 18:19:39.804972
4588	Inv_alt_1130007	\N	\N	Tripie con chancla	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:Tripie con chancla]	2026-08-20 18:19:39.804972
4589	Inv_alt_1130008	\N	\N	Kit de iluminacion 2000	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:Kit de iluminacion 2000]	2026-08-20 18:19:39.804972
4593	Inv_alt_1130009	\N	\N	HDMI 50 MTS	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:HDMI 50 MTS]	2026-08-20 18:19:39.804972
4594	Inv_alt_1130010	\N	\N	SDI	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:SDI]	2026-08-20 18:19:39.804972
4595	Inv_alt_1130011	\N	\N	Barra de contactos	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:Barra de contactos]	2026-08-20 18:19:39.804972
4597	Inv_alt_1130012	\N	\N	Microfono de mano	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:Microfono de mano]	2026-08-20 18:19:39.804972
4598	Inv_alt_1130013	\N	\N	Cable XLR	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:Cable XLR]	2026-08-20 18:19:39.804972
4599	Inv_alt_1130014	\N	\N	Bocina de 1 con cable de corriente	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:Bocina de 1 con cable de corriente]	2026-08-20 18:19:39.804972
4616	Inv_alt_1130015	\N	\N	Cable XLR largo	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:Cable XLR largo]	2026-08-20 18:24:37.877984
4627	Inv_alt_2010005	\N	\N	Laptop HP Elitebook 845 G7 Notebook PC, con cargador y maletín	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	[CUST_EQ:Laptop HP Elitebook 845 G7 Notebook PC, con cargador y maletín]	2026-08-20 18:35:15.047362
4601	INV_ALT_1130005	\N	\N	Kit microfono Lavalier	\N	\N	\N	Manuel Eduardo Madrid	113	Buen Estado	BODEGA		2026-08-20 18:24:37.877984
4602	INV_ALT_1130006	\N	\N	Camara x320	\N	\N	\N	Manuel Eduardo Madrid	113	Buen Estado	BODEGA		2026-08-20 18:24:37.877984
4609	INV_ALT_1130009	\N	\N	HDMI 50 MTS	\N	\N	\N	Manuel Eduardo Madrid	113	Buen Estado	BODEGA		2026-08-20 18:24:37.877984
4610	INV_ALT_1130010	\N	\N	SDI	\N	\N	\N	Manuel Eduardo Madrid	113	Buen Estado	BODEGA		2026-08-20 18:24:37.877984
4389	INV_ALT_2020022	\N	\N	Starlink #2 CON TRIPIE, ROUTER, CABLES DE CORRIENTE Y ADAPTADOR ETHERNET EN MALETA	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 13:52:45.398156
4613	INV_ALT_1130012	\N	\N	Microfono de mano	\N	\N	\N	Manuel Eduardo Madrid	113	Buen Estado	BODEGA		2026-08-20 18:24:37.877984
4611	INV_ALT_1130011	\N	\N	Sillas	\N	\N	\N	Manuel Eduardo Madrid	113	Buen Estado	BODEGA		2026-08-20 18:24:37.877984
4391	INV_ALT_2020024	\N	\N	Laptop Asus Vivobook 15" D1502IA-BQ179W Ryzen 5 8GB RAM 256GB SSD con cargador VPNRED033	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA		2026-08-18 13:52:45.398156
4518	INV_VPRO_ALT_26708	\N	\N	APUNTADOR	\N	\N	\N	Manuel Eduardo Madrid	109	BUEN ESTADO	BODEGA		2026-08-18 14:10:19.069803
4615	INV_ALT_1130014	\N	\N	Bocina de audio con cable de corriente	\N	\N	\N	Manuel Eduardo Madrid	113	Buen Estado	BODEGA		2026-08-20 18:24:37.877984
4516	INV_ALT_1090030	\N	\N	Maleta de laptop	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-08-18 14:10:19.069803
4570	INV_VPRO_ALT_00168	\N	\N	pinza ponchadora	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	BUEN ESTADO	BODEGA		2026-08-18 18:05:18.017301
4390	INV_ALT_2020023	\N	\N	Laptop HP Elitebook 845 G7 Notebook PC, con cargador VPNCOM007	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-18 13:52:45.398156
4592	INV_VPRO_ALT_00175	\N	\N	Extensiones	\N	\N	\N	Jose Francisco Torres Sanchez	113	BUEN ESTADO	BODEGA		2026-08-20 18:19:39.804972
4454	INV_ALT_1090028	\N	\N	MONITOR STEREN	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-08-18 14:06:47.98422
4734	INV_ALT_1190021	\N	\N	cables de HDMI a MINI HDMI (NEGRO Y ROJO)	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-25 19:55:48.442458
4664	Inv_alt_1130016	\N	\N	Distribuidores	\N	\N	\N	Manuel Eduardo Madrid	113	Buen Estado	BODEGA	[CUST_EQ:Distribuidores]	2026-08-22 10:27:06.640334
4677	INV_ALT_2010003	\N	\N	cables cortos ethernet cat 6	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-08-22 10:45:29.765678
4681	INV_ALT_2010005	\N	\N	Laptop HP Elitebook 845 G7 Notebook con cargador y maletín CODIGO VPNPRO125	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-08-22 10:45:29.765678
4735	INV_ALT_1190022	\N	\N	cajita naranja con conectores y coples (HDMI 6, SDI 7, TE SDI 3)	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-25 19:55:48.442458
4644	INV_ALT_1130015	\N	\N	Cable XLR largo	\N	\N	\N	Manuel Eduardo Madrid	113	Buen Estado	BODEGA		2026-08-22 10:23:36.433576
4701	INV_ALT_1130016	\N	\N	Distribuidores	\N	\N	\N	Manuel Eduardo Madrid	113	Buen Estado	BODEGA		2026-08-22 11:16:21.86769
4837	INV_ALT_1190023	\N	\N	baterias NP-F970 para monitor	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-27 17:57:43.821365
4850	INV_ALT_1090032	\N	\N	Equipo no registrado	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-08-27 18:27:47.777376
4342	INV_ALT_1190014	\N	\N	lector de memorias para imperdec con su cable USB y A/C	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-18 13:20:58.44271
4728	INV_ALT_1190015	\N	\N	laptop acer azul	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-25 19:55:48.442458
4873	Inv_alt_1090032	\N	\N	RAC de grabación	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	[CUST_EQ:RAC de grabación]	2026-08-27 18:27:47.777376
4887	Inv_alt_1090033	\N	\N	Convertidor C-HDMI	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Convertidor C-HDMI]	2026-08-28 14:39:12.728256
4891	Inv_alt_2020029	\N	\N	Encoder kiloview E3	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Encoder kiloview E3]	2026-08-31 18:09:49.190037
4892	Inv_alt_2020030	\N	\N	Cables SDI 1mt	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Cables SDI 1mt]	2026-08-31 18:09:49.190037
4906	Inv_alt_2020031	\N	\N	Extension de USB	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Extension de USB]	2026-08-31 18:09:49.190037
4986	Inv_alt_1190024	\N	\N	ESCALADOR	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:ESCALADOR]	2026-08-31 18:20:40.678865
4932	Inv_alt_2020032	\N	\N	Teradek BOND PRO con estuche VPNRED012	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Teradek BOND PRO con estuche VPNRED012]	2026-08-31 18:11:53.983874
4987	Inv_alt_1190025	\N	\N	MONITOR LILIPUT	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:MONITOR LILIPUT]	2026-08-31 18:20:40.678865
4988	Inv_alt_1190026	\N	\N	MICROFONO SHURE	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:MICROFONO SHURE]	2026-08-31 18:20:40.678865
4989	Inv_alt_1190027	\N	\N	MICROFONO PARA AMBIENTE	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:MICROFONO PARA AMBIENTE]	2026-08-31 18:20:40.678865
4990	Inv_alt_1190028	\N	\N	PEDESTAL	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:PEDESTAL]	2026-08-31 18:20:40.678865
4991	Inv_alt_1190029	\N	\N	LINEAS DE ENERGIA	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:LINEAS DE ENERGIA]	2026-08-31 18:20:40.678865
4992	Inv_alt_1190030	\N	\N	LINEAS DE AUDIO	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:LINEAS DE AUDIO]	2026-08-31 18:20:40.678865
4993	Inv_alt_1190031	\N	\N	CABLES HDMI (UNO DE 50 M Y UNO DE 7 M)	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:CABLES HDMI (UNO DE 50 M Y UNO DE 7 M)]	2026-08-31 18:20:40.678865
4995	Inv_alt_1190032	\N	\N	MICROFONO DE MARACA	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:MICROFONO DE MARACA]	2026-08-31 18:20:40.678865
4996	Inv_alt_1190033	\N	\N	SISTEMA INALAMBRICO DE COMUNICACION	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:SISTEMA INALAMBRICO DE COMUNICACION]	2026-08-31 18:20:40.678865
4811	Inv_alt_1190023	\N	\N	baterias NP-F970 para monitor	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:baterias NP-F970 para monitor]	2026-08-27 14:49:54.016349
4729	INV_ALT_1190016	\N	\N	cables SDI cortos (6 de 1 m, 2 de 1/2 m, 1 de 5 m, 1 de 11 m )	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-25 19:55:48.442458
4730	INV_ALT_1190017	\N	\N	cables HDMI cortos	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-25 19:55:48.442458
4731	INV_ALT_1190018	\N	\N	cables de corriente negros cortos	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-25 19:55:48.442458
4732	INV_ALT_1190019	\N	\N	barras de energia balnacas chicas	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-25 19:55:48.442458
4733	INV_ALT_1190020	\N	\N	cable negro USB-A a USB-B	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-25 19:55:48.442458
4997	Inv_alt_1190034	\N	\N	BARRA D EENERGIA	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:BARRA D EENERGIA]	2026-08-31 18:20:40.678865
4913	INV_ALT_2020029	\N	\N	Encoder kiloview E3	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA		2026-08-31 18:11:53.983874
5024	INV_ALT_1190033	\N	\N	SISTEMA INALAMBRICO DE COMUNICACION	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA		2026-08-31 18:35:31.663859
5030	INV_ALT_1190025	\N	\N	MONITOR LILIPUT	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA		2026-08-31 18:35:31.663859
5031	INV_ALT_1190026	\N	\N	MICROFONO SHURE	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA		2026-08-31 18:35:31.663859
4979	Inv_alt_2020033	\N	\N	Cutter trupper	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Cutter trupper]	2026-08-31 18:15:44.654044
4665	INV_VPRO_ALT_00201	\N	\N	Balanceador	\N	\N	\N	Manuel Antonio Madrid Zazueta	113	BUEN ESTADO	BODEGA		2026-08-22 10:27:06.640334
5025	INV_ALT_1190034	\N	\N	BARRA D EENERGIA	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-31 18:35:31.663859
4870	INV_ALT_1090031	\N	\N	Laptop G7	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA		2026-08-27 18:27:47.777376
5029	INV_ALT_1190024	\N	\N	escalador	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-31 18:35:31.663859
5032	INV_ALT_1190027	\N	\N	MICROFONO PARA AMBIENTE	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA		2026-08-31 18:35:31.663859
5033	INV_ALT_1190028	\N	\N	PEDESTAL	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA		2026-08-31 18:35:31.663859
4679	INV_ALT_2010004	\N	\N	frasco con plugs cat 6	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-08-22 10:45:29.765678
5035	INV_ALT_1190030	\N	\N	LINEAS DE AUDIO	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA		2026-08-31 18:35:31.663859
5036	INV_ALT_1190031	\N	\N	CABLES HDMI (UNO DE 50 M Y UNO DE 7 M)	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA		2026-08-31 18:35:31.663859
5038	INV_ALT_1190032	\N	\N	MICROFONO DE MARACA	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA		2026-08-31 18:35:31.663859
5039	Inv_alt_1190035	\N	\N	Diademas de comunicación	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA	[CUST_EQ:Diademas de comunicación]	2026-08-31 18:35:31.663859
5040	Inv_alt_1190036	\N	\N	Cable SDI LILA	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA	[CUST_EQ:Cable SDI LILA]	2026-08-31 18:35:31.663859
5061	Inv_alt_2010006	\N	\N	UPS (No break) Koblenz CODIGO VPNRED097	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	[CUST_EQ:UPS (No break) Koblenz CODIGO VPNRED097]	2026-09-02 17:43:16.055093
5023	Inv_alt_2020034	\N	\N	Tripié para bocina sin tubo extersor	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:Tripié para bocina sin tubo extersor]	2026-08-31 18:21:49.457829
5161	INV_ALT_2020035	\N	\N	UPS (No-Break) Koblenz CODIGO VPNRED100	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA		2026-09-03 17:41:24.863142
5268	Inv_alt_2020036	\N	\N	Audifonos behringer HC200	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA	[CUST_EQ:Audifonos behringer HC200]	2026-09-03 18:12:55.424238
1879	Inv_Vpro_alt_00098	\N	\N	fuentes de poder	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	None	2026-05-26 17:34:48.755318
5275	Inv_alt_1190037	\N	\N	lampara portatil con una bateria	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:lampara portatil con una bateria]	2026-09-03 18:45:01.908018
5276	Inv_alt_1190038	\N	\N	micrófono de maraca	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:micrófono de maraca]	2026-09-03 18:45:01.908018
5134	Inv_alt_2020035	\N	\N	UPS (No-Break) Koblenz CODIGO VPNRED100	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:UPS (No-Break) Koblenz CODIGO VPNRED100]	2026-09-03 17:39:50.742295
5277	Inv_alt_1190039	\N	\N	atem sdi	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:atem sdi]	2026-09-03 18:45:01.908018
5281	Inv_alt_1190040	\N	\N	baterías para monitor	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:baterías para monitor]	2026-09-03 18:45:01.908018
5282	Inv_alt_1190041	\N	\N	monitor de ing.	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:monitor de ing.]	2026-09-03 18:45:01.908018
5283	Inv_alt_1190042	\N	\N	monitores liliput	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:monitores liliput]	2026-09-03 18:45:01.908018
5285	Inv_alt_1190043	\N	\N	distribuidor sdi	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:distribuidor sdi]	2026-09-03 18:45:01.908018
5286	Inv_alt_1190044	\N	\N	monitor 21.5 pulgadas	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:monitor 21.5 pulgadas]	2026-09-03 18:45:01.908018
5288	Inv_alt_1190045	\N	\N	memorias sxs	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:memorias sxs]	2026-09-03 18:45:01.908018
5289	Inv_alt_1190046	\N	\N	cámaras miniblack	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:cámaras miniblack]	2026-09-03 18:45:01.908018
5290	Inv_alt_1190047	\N	\N	cables sdi largos	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:cables sdi largos]	2026-09-03 18:45:01.908018
5291	Inv_alt_1190048	\N	\N	lineas de audio largas	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:lineas de audio largas]	2026-09-03 18:45:01.908018
5292	Inv_alt_1190049	\N	\N	microfonos para ambiente	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:microfonos para ambiente]	2026-09-03 18:45:01.908018
5296	Inv_alt_1190050	\N	\N	pizacables	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:pizacables]	2026-09-03 18:45:01.908018
5236	Inv_alt_2010007	\N	\N	Switch de 5 puertos metalico	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	[CUST_EQ:Switch de 5 puertos metalico]	2026-09-03 18:11:55.096798
4914	INV_ALT_2020030	\N	\N	Cables SDI 1mt	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA		2026-08-31 18:11:53.983874
4955	INV_ALT_2020032	\N	\N	Teradek BOND PRO con estuche VPNRED012	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA		2026-08-31 18:14:18.04195
5324	Inv_alt_1190051	\N	\N	Trpies	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA	[CUST_EQ:Trpies]	2026-09-03 19:07:32.564943
5325	Inv_alt_1190052	\N	\N	Diademas	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA	[CUST_EQ:Diademas]	2026-09-03 19:07:32.564943
4928	INV_ALT_2020031	\N	\N	Extension de USB	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-31 18:11:53.983874
5022	INV_ALT_2020033	\N	\N	Cutter trupper	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-08-31 18:21:49.457829
5132	INV_ALT_2020034	\N	\N	Tripié para bocina sin tubo extersor	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-09-03 17:39:50.742295
5302	INV_ALT_1190037	\N	\N	lampara portatil con una bateria	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-03 19:07:32.564943
5303	INV_ALT_1190038	\N	\N	micrófono de maraca	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-03 19:07:32.564943
5071	INV_ALT_2010006	\N	\N	UPS (No break) Koblenz CODIGO VPNRED097	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-09-02 17:45:06.932722
4904	INV_VPRO_ALT_00149	\N	\N	Bolsa con cinchos	\N	\N	\N	Edgar Javier Amarillas	202	BUEN ESTADO	BODEGA		2026-08-31 18:09:49.190037
5481	Inv_alt_1190053	\N	\N	Cámara 320	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:Cámara 320]	2026-09-14 10:19:25.345903
5482	Inv_alt_1190054	\N	\N	Sombrilla	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:Sombrilla]	2026-09-14 10:19:25.345903
5485	Inv_alt_1190055	\N	\N	Baterías ZGCINE	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:Baterías ZGCINE]	2026-09-14 10:19:25.345903
5486	Inv_alt_1190056	\N	\N	Baterías GL95	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:Baterías GL95]	2026-09-14 10:19:25.345903
5487	Inv_alt_1190057	\N	\N	Baterías L90	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:Baterías L90]	2026-09-14 10:19:25.345903
5488	Inv_alt_1190058	\N	\N	Baterías NP	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:Baterías NP]	2026-09-14 10:19:25.345903
5304	INV_ALT_1190039	\N	\N	atem sdi	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-03 19:07:32.564943
5490	Inv_alt_1190059	\N	\N	Forros para cámaras	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:Forros para cámaras]	2026-09-14 10:19:25.345903
5492	Inv_alt_1190060	\N	\N	MiniBlackMagic	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:MiniBlackMagic]	2026-09-14 10:19:25.345903
5385	INV_VPRO_ALT_00012	\N	\N	Computadora de escritorio con dos monitores	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	⚠️ [LLEVA DAÑO REPORTADO]	2026-09-05 17:13:53.784014
5353	INV_ALT_1190052	\N	\N	DIADEMAS	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA		2026-09-03 19:27:22.684987
5386	Inv_alt_1040004	\N	\N	Pantalla de 65"	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:Pantalla de 65"]	2026-09-08 10:12:11.761852
5389	Inv_alt_1040005	\N	\N	Distribuidores 1x4	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:Distribuidores 1x4]	2026-09-08 10:12:11.761852
5390	Inv_alt_1040006	\N	\N	Distribuidores 1x2	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:Distribuidores 1x2]	2026-09-08 10:12:11.761852
5395	Inv_alt_1050007	\N	\N	Baterias Z	\N	\N	\N	Jose Daniel Torres Arroyo	105	Buen Estado	BODEGA	[CUST_EQ:Baterias Z]	2026-09-08 10:13:46.748362
5397	Inv_alt_1130017	\N	\N	Cámara FS7	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:Cámara FS7]	2026-09-08 10:14:51.556756
5398	Inv_alt_1130018	\N	\N	Alpha	\N	\N	\N	Carlos Jacobo Quezada Mendoza	113	Buen Estado	BODEGA	[CUST_EQ:Alpha]	2026-09-08 10:14:51.556756
5400	INV_ALT_1050007	\N	\N	Baterias Z	\N	\N	\N	Jose Daniel Torres Arroyo	105	Buen Estado	BODEGA		2026-09-09 10:49:41.631786
5308	INV_ALT_1190040	\N	\N	baterías para monitor	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-03 19:07:32.564943
5309	INV_ALT_1190041	\N	\N	monitor de ing.	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-03 19:07:32.564943
5412	Inv_alt_2010008	\N	\N	Switch de 5 puertos de plastico negro	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	[CUST_EQ:Switch de 5 puertos de plastico negro]	2026-09-09 16:38:46.473641
5312	INV_ALT_1190043	\N	\N	distribuidor sdi	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-03 19:07:32.564943
5313	INV_ALT_1190044	\N	\N	monitor 21.5 pulgadas	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-03 19:07:32.564943
5287	INV_VPRO_ALT_00202	\N	\N	Sistema de comunicacion	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	BUEN ESTADO	BODEGA		2026-09-03 18:45:01.908018
5315	INV_ALT_1190045	\N	\N	memorias sxs	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-03 19:07:32.564943
5316	INV_ALT_1190046	\N	\N	cámaras miniblack	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-03 19:07:32.564943
5317	INV_ALT_1190047	\N	\N	cables sdi largos	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-03 19:07:32.564943
5318	INV_ALT_1190048	\N	\N	lineas de audio largas	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-03 19:07:32.564943
5319	INV_ALT_1190049	\N	\N	microfonos para ambiente	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-03 19:07:32.564943
5034	INV_ALT_1190029	\N	\N	lineas de energia	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-08-31 18:35:31.663859
5323	INV_ALT_1190050	\N	\N	SDI	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA		2026-09-03 19:07:32.564943
5352	INV_ALT_1190051	\N	\N	Trpies	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-03 19:27:22.684987
5354	INV_ALT_2020036	\N	\N	Audifonos behringer HC200	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-03 19:27:22.684987
5500	INV_ALT_1190058	\N	\N	Baterías NP	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 10:23:05.044909
5411	INV_ALT_2010007	\N	\N	Switch de 5 puertos metalico	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-09-09 16:38:46.473641
5436	INV_ALT_2010008	\N	\N	Switch de 5 puertos de plastico negro	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-09-09 17:41:15.151989
5408	INV_VPRO_ALT_00139	\N	\N	Cables ethernet cortos	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	BUEN ESTADO	BODEGA		2026-09-09 16:38:46.473641
5502	INV_ALT_1190059	\N	\N	Forros para cámaras	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 10:23:05.044909
5493	INV_ALT_1190053	\N	\N	Cámara 320	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 10:23:05.044909
5497	INV_ALT_1190055	\N	\N	Baterías ZGCINE	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 10:23:05.044909
5498	INV_ALT_1190056	\N	\N	Baterías GL95	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 10:23:05.044909
5499	INV_ALT_1190057	\N	\N	Baterías L90	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 10:23:05.044909
5494	INV_ALT_1190054	\N	\N	Sombrilla	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 10:23:05.044909
5504	INV_ALT_1190060	\N	\N	MiniBlackMagic	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 10:23:05.044909
5814	Inv_alt_1090034	\N	\N	ADAPTADOR USBC-HDMI	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:ADAPTADOR USBC-HDMI]	2026-09-14 18:00:05.097918
5815	Inv_alt_1090035	\N	\N	SPLITTER 1X3 OREI	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:SPLITTER 1X3 OREI]	2026-09-14 18:00:05.097918
5817	Inv_alt_1090036	\N	\N	MINI CONSOLA STEREN	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:MINI CONSOLA STEREN]	2026-09-14 18:00:05.097918
5564	Inv_alt_1190061	\N	\N	Cables SDI NEGROS 1 METRO	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA	[CUST_EQ:Cables SDI NEGROS 1 METRO]	2026-09-14 10:37:29.832978
5819	Inv_alt_1090037	\N	\N	STREAM DEACK	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:STREAM DEACK]	2026-09-14 18:00:05.097918
5604	Inv_alt_2020037	\N	\N	VPNRED-SWITCH10/100 - Switch ethernet tp-link 10/100 tl-sf1016D (VPNRED-SWITCH10/100)	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:VPNRED-SWITCH10/100 - Switch ethernet tp-link 10/100 tl-sf1016D (VPNRED-SWITCH10/100)]	2026-09-14 10:37:47.640785
5627	Inv_alt_1040007	\N	\N	Caja azul con SDI	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:Caja azul con SDI]	2026-09-14 10:45:10.061543
5628	Inv_alt_1040008	\N	\N	Caja con Extensiones	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:Caja con Extensiones]	2026-09-14 10:45:10.061543
5629	Inv_alt_1040009	\N	\N	Caja de fibra	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:Caja de fibra]	2026-09-14 10:45:10.061543
5632	Inv_alt_1040010	\N	\N	Hdmi de 100 metros	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:Hdmi de 100 metros]	2026-09-14 10:45:10.061543
5633	Inv_alt_1040011	\N	\N	Hdmi de 50 metros	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:Hdmi de 50 metros]	2026-09-14 10:45:10.061543
5639	Inv_alt_2010009	\N	\N	INV_VPRO_ALT_00013 - Laptop Asus con adaptador de red y cable de corriente	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	[CUST_EQ:INV_VPRO_ALT_00013 - Laptop Asus con adaptador de red y cable de corriente]	2026-09-14 10:47:16.726046
5642	Inv_alt_2010010	\N	\N	VPNPRO152 - Laptop Del #2 Inspiron G7 7700 Gaming 17.3" Intel Core i5 10300H Disco duro 512 GB SSD Ram 8GB Winsows 10 Home, Mause y cargador	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA	[CUST_EQ:VPNPRO152 - Laptop Del #2 Inspiron G7 7700 Gaming 17.3" Intel Core i5 10300H Disco duro 512 GB SSD Ram 8GB Winsows 10 Home, Mause y cargador]	2026-09-14 10:47:16.726046
5666	Inv_alt_2020038	\N	\N	Modem ZTE megacable 529640	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA	[CUST_EQ:Modem ZTE megacable 529640]	2026-09-14 11:01:19.039659
5508	INV_VPRO_ALT_00227	\N	\N	Multicontactos	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	BUEN ESTADO	BODEGA		2026-09-14 10:23:05.044909
5626	INV_ALT_2020037	\N	\N	VPNRED-SWITCH10/100 - Switch ethernet tp-link 10/100 tl-sf1016D (VPNRED-SWITCH10/100)	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA		2026-09-14 10:39:19.870566
5310	INV_ALT_1190042	\N	\N	Monitores liliput	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-03 19:07:32.564943
5697	Inv_alt_1190062	\N	\N	SDI varios tamaños	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA	[CUST_EQ:SDI varios tamaños]	2026-09-14 11:15:17.778584
5698	Inv_alt_1190063	\N	\N	Corriente	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA	[CUST_EQ:Corriente]	2026-09-14 11:15:17.778584
5699	Inv_alt_1190064	\N	\N	HDMI cortos	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA	[CUST_EQ:HDMI cortos]	2026-09-14 11:15:17.778584
5700	Inv_alt_1190065	\N	\N	USB-USB C	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA	[CUST_EQ:USB-USB C]	2026-09-14 11:15:17.778584
5701	Inv_alt_1190066	\N	\N	USB cables	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA	[CUST_EQ:USB cables]	2026-09-14 11:15:17.778584
5702	Inv_alt_1190067	\N	\N	USB tipo b	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA	[CUST_EQ:USB tipo b]	2026-09-14 11:15:17.778584
5704	Inv_alt_1190068	\N	\N	Rollo de alambre	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA	[CUST_EQ:Rollo de alambre]	2026-09-14 11:15:17.778584
5705	Inv_alt_1190069	\N	\N	Micro convertidor	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA	[CUST_EQ:Micro convertidor]	2026-09-14 11:15:17.778584
5582	INV_ALT_1190061	\N	\N	Cables SDI NEGROS 1 METRO	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 10:37:34.976974
5728	INV_ALT_2020038	\N	\N	Modem ZTE megacable 529640	\N	\N	\N	Manuel Eduardo Madrid	202	Buen Estado	BODEGA		2026-09-14 11:16:21.967078
5506	INV_VPRO_ALT_00205	\N	\N	Escaladores decimator	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	BUEN ESTADO	BODEGA		2026-09-14 10:23:05.044909
5748	INV_ALT_1190062	\N	\N	SDI varios tamaños	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 11:16:44.949657
5749	INV_ALT_1190063	\N	\N	Corriente	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 11:16:44.949657
5750	INV_ALT_1190064	\N	\N	HDMI cortos	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 11:16:44.949657
5785	Inv_alt_1190070	\N	\N	Cargador Sony para baterías NP	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA	[CUST_EQ:Cargador Sony para baterías NP]	2026-09-14 11:17:53.544071
5820	Inv_alt_1090038	\N	\N	MAC	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:MAC]	2026-09-14 18:00:05.097918
5821	Inv_alt_1090039	\N	\N	CAPTURADORAS USB	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:CAPTURADORAS USB]	2026-09-14 18:00:05.097918
5822	Inv_alt_1090040	\N	\N	CONVERTIDORES SDI-HDMI	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:CONVERTIDORES SDI-HDMI]	2026-09-14 18:00:05.097918
5823	Inv_alt_1090041	\N	\N	CONVERTIDOR BIMODAL BLACKMAGIC	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:CONVERTIDOR BIMODAL BLACKMAGIC]	2026-09-14 18:00:05.097918
5810	Inv_alt_1040012	\N	\N	Voltimetro	\N	\N	\N	Manuel Eduardo Madrid	104	Buen Estado	BODEGA	[CUST_EQ:Voltimetro]	2026-09-14 17:15:10.65542
5824	Inv_alt_1090042	\N	\N	RECEPTORES SONY	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:RECEPTORES SONY]	2026-09-14 18:00:05.097918
5826	Inv_alt_1090043	\N	\N	CABLE SDI 7 MTS	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:CABLE SDI 7 MTS]	2026-09-14 18:00:05.097918
5827	Inv_alt_1090044	\N	\N	CABLE SDI CORTO	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:CABLE SDI CORTO]	2026-09-14 18:00:05.097918
5829	Inv_alt_1090045	\N	\N	ATEM MINI PRO SDI	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:ATEM MINI PRO SDI]	2026-09-14 18:00:05.097918
5831	Inv_alt_1090046	\N	\N	DIADEMA DE COMUNICACION	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:DIADEMA DE COMUNICACION]	2026-09-14 18:00:05.097918
5832	Inv_alt_1090047	\N	\N	DIADEMA DE AUDIO	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:DIADEMA DE AUDIO]	2026-09-14 18:00:05.097918
5833	Inv_alt_1090048	\N	\N	DIADEMA DE OSIEL	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:DIADEMA DE OSIEL]	2026-09-14 18:00:05.097918
5835	Inv_alt_1090049	\N	\N	MICROFONO SHURE CON PEDESTAL Y CABLE	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:MICROFONO SHURE CON PEDESTAL Y CABLE]	2026-09-14 18:00:05.097918
5839	Inv_alt_1090050	\N	\N	BOCINA PREOSUND CON CABLES	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:BOCINA PREOSUND CON CABLES]	2026-09-14 18:00:05.097918
5841	Inv_alt_1090051	\N	\N	EXTENSORES USB	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:EXTENSORES USB]	2026-09-14 18:00:05.097918
5842	Inv_alt_1090052	\N	\N	LAPTOP	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:LAPTOP]	2026-09-14 18:00:05.097918
5843	Inv_alt_1090053	\N	\N	CABLES DE RED	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:CABLES DE RED]	2026-09-14 18:00:05.097918
5844	Inv_alt_1090054	\N	\N	MONITOR HDMI	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:MONITOR HDMI]	2026-09-14 18:00:05.097918
5845	Inv_alt_1090055	\N	\N	RAC CON SWITCHER	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:RAC CON SWITCHER]	2026-09-14 18:00:05.097918
5846	Inv_alt_1090056	\N	\N	PANEL DE 20 ENTRADAS	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:PANEL DE 20 ENTRADAS]	2026-09-14 18:00:05.097918
5847	Inv_alt_1090057	\N	\N	THREEPLAY CON CONTROL, TECLADO Y MOUSE	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:THREEPLAY CON CONTROL, TECLADO Y MOUSE]	2026-09-14 18:00:05.097918
5848	Inv_alt_1090058	\N	\N	HC 200 AUDIFONOS	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:HC 200 AUDIFONOS]	2026-09-14 18:00:05.097918
5849	Inv_alt_1090059	\N	\N	MESAS	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:MESAS]	2026-09-14 18:00:05.097918
5851	Inv_alt_1090060	\N	\N	XLR LARGO	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:XLR LARGO]	2026-09-14 18:00:05.097918
5852	Inv_alt_1090061	\N	\N	SOPORTE PARA GUITARRA	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:SOPORTE PARA GUITARRA]	2026-09-14 18:00:05.097918
5853	Inv_alt_1090062	\N	\N	ZEDI 10	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:ZEDI 10]	2026-09-14 18:00:05.097918
5910	INV_ALT_1190070	\N	\N	Cargador Sony para baterías NP	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-15 10:07:57.82351
5867	Inv_alt_1040013	\N	\N	Mesita	\N	\N	\N	Manuel Eduardo Madrid	104	Buen Estado	BODEGA	[CUST_EQ:Mesita]	2026-09-15 10:02:08.780974
5828	INV_VPRO_ALT_00211	\N	\N	HDMI	\N	\N	\N	Manuel Eduardo Madrid	109	BUEN ESTADO	BODEGA		2026-09-14 18:00:05.097918
5635	INV_VPRO_ALT_00216	\N	\N	Carpa	\N	\N	\N	Manuel Eduardo Madrid	104	BUEN ESTADO	BODEGA		2026-09-14 10:45:10.061543
5631	INV_VPRO_ALT_00071	\N	\N	Fibra caja	\N	\N	\N	Manuel Eduardo Madrid	104	BUEN ESTADO	BODEGA		2026-09-14 10:45:10.061543
5850	INV_VPRO_ALT_00198	\N	\N	MONITORES	\N	\N	\N	Manuel Eduardo Madrid	109	BUEN ESTADO	BODEGA		2026-09-14 18:00:05.097918
5755	INV_ALT_1190068	\N	\N	Rollo de alambre	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 11:16:44.949657
5756	INV_ALT_1190069	\N	\N	Micro convertidor	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 11:16:44.949657
5751	INV_ALT_1190065	\N	\N	USB-USB C	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 11:16:44.949657
5752	INV_ALT_1190066	\N	\N	USB cables	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 11:16:44.949657
5753	INV_ALT_1190067	\N	\N	USB tipo b	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-14 11:16:44.949657
5911	Inv_alt_1190071	\N	\N	Cargador para baterias 320	\N	\N	\N	Manuel Eduardo Madrid	119	Buen Estado	BODEGA	[CUST_EQ:Cargador para baterias 320]	2026-09-15 10:07:57.82351
5915	INV_ALT_1090034	\N	\N	ADAPTADOR USBC-HDMI	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5916	INV_ALT_1090035	\N	\N	SPLITTER 1X3 OREI	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5918	INV_ALT_1090036	\N	\N	MINI CONSOLA STEREN	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5920	INV_ALT_1090037	\N	\N	STREAM DEACK	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5922	INV_ALT_1090039	\N	\N	CAPTURADORAS USB	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5923	INV_ALT_1090040	\N	\N	CONVERTIDORES SDI-HDMI	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5667	INV_ALT_1040007	\N	\N	Caja azul con SDI	\N	\N	\N	Manuel Eduardo Madrid	104	Buen Estado	BODEGA		2026-09-14 11:03:49.576732
5668	INV_ALT_1040008	\N	\N	Caja con Extensiones	\N	\N	\N	Manuel Eduardo Madrid	104	Buen Estado	BODEGA		2026-09-14 11:03:49.576732
5669	INV_ALT_1040009	\N	\N	Caja de fibra	\N	\N	\N	Manuel Eduardo Madrid	104	Buen Estado	BODEGA		2026-09-14 11:03:49.576732
5921	INV_ALT_1090038	\N	\N	Mac	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5672	INV_ALT_1040010	\N	\N	Multicontactos	\N	\N	\N	Manuel Eduardo Madrid	104	Buen Estado	BODEGA		2026-09-14 11:03:49.576732
5673	INV_ALT_1040011	\N	\N	Grabadora	\N	\N	\N	Manuel Eduardo Madrid	104	Buen Estado	BODEGA		2026-09-14 11:03:49.576732
5866	INV_ALT_1040012	\N	\N	Voltimetro	\N	\N	\N	Manuel Eduardo Madrid	104	Buen Estado	BODEGA		2026-09-15 10:02:08.780974
5881	INV_ALT_1040013	\N	\N	Mesita	\N	\N	\N	Manuel Eduardo Madrid	104	Buen Estado	BODEGA		2026-09-15 10:03:37.819346
5924	INV_ALT_1090041	\N	\N	CONVERTIDOR BIMODAL BLACKMAGIC	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5925	INV_ALT_1090042	\N	\N	RECEPTORES SONY	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5927	INV_ALT_1090043	\N	\N	CABLE SDI 7 MTS	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5928	INV_ALT_1090044	\N	\N	CABLE SDI CORTO	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5930	INV_ALT_1090045	\N	\N	ATEM MINI PRO SDI	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5932	INV_ALT_1090046	\N	\N	DIADEMA DE COMUNICACION	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5933	INV_ALT_1090047	\N	\N	DIADEMA DE AUDIO	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5934	INV_ALT_1090048	\N	\N	DIADEMA DE OSIEL	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5936	INV_ALT_1090049	\N	\N	MICROFONO SHURE CON PEDESTAL Y CABLE	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5940	INV_ALT_1090050	\N	\N	BOCINA PREOSUND CON CABLES	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5942	INV_ALT_1090051	\N	\N	EXTENSORES USB	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5943	INV_ALT_1090052	\N	\N	LAPTOP	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5944	INV_ALT_1090053	\N	\N	CABLES DE RED	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5945	INV_ALT_1090054	\N	\N	MONITOR HDMI	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5946	INV_ALT_1090055	\N	\N	RAC CON SWITCHER	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5947	INV_ALT_1090056	\N	\N	PANEL DE 20 ENTRADAS	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5948	INV_ALT_1090057	\N	\N	THREEPLAY CON CONTROL, TECLADO Y MOUSE	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5949	INV_ALT_1090058	\N	\N	HC 200 AUDIFONOS	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5950	INV_ALT_1090059	\N	\N	MESAS	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5952	INV_ALT_1090060	\N	\N	XLR LARGO	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5953	INV_ALT_1090061	\N	\N	SOPORTE PARA GUITARRA	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5954	INV_ALT_1090062	\N	\N	ZEDI 10	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA		2026-09-15 10:09:05.946333
5955	Inv_alt_1090063	\N	\N	Rac con 2 grabadoras "IMPERDEC Y SD"	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	[CUST_EQ:Rac con 2 grabadoras "IMPERDEC Y SD"]	2026-09-15 10:09:05.946333
5956	Inv_alt_1090064	\N	\N	IMPERDEC	\N	\N	\N	Manuel Eduardo Madrid	109	Buen Estado	BODEGA	[CUST_EQ:IMPERDEC]	2026-09-15 10:09:05.946333
5957	Inv_alt_1050008	\N	\N	Tripie para luces	\N	\N	\N	Manuel Eduardo Madrid	105	Buen Estado	BODEGA	[CUST_EQ:Tripie para luces]	2026-09-15 10:13:03.445217
5974	INV_ALT_2010009	\N	\N	INV_VPRO_ALT_00013 - Laptop Asus con adaptador de red y cable de corriente	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-09-17 13:28:07.558745
5977	INV_ALT_2010010	\N	\N	VPNPRO152 - Laptop Del #2 Inspiron G7 7700 Gaming 17.3" Intel Core i5 10300H Disco duro 512 GB SSD Ram 8GB Winsows 10 Home, Mause y cargador	\N	\N	\N	Cuauhtemoc Rivera Agundez	201	Buen Estado	BODEGA		2026-09-17 13:28:07.558745
6002	Inv_alt_2020039	\N	\N	VPNRED060 - Modem de internet ZTE Megacable VPNRED060	\N	\N	\N	Edgar Javier Amarillas	202	Buen Estado	BODEGA	[CUST_EQ:VPNRED060 - Modem de internet ZTE Megacable VPNRED060]	2026-09-17 14:05:53.18048
6003	INV_ALT_1050008	\N	\N	luces	\N	\N	\N	Jose Daniel Torres Arroyo	105	Buen Estado	BODEGA		2026-09-17 18:11:36.961475
6009	INV_ALT_1190071	\N	\N	Cargador para baterias 320	\N	\N	\N	Manuel Antonio Madrid Zazueta	119	Buen Estado	BODEGA		2026-09-17 18:54:53.77961
6038	Inv_alt_1040014	\N	\N	Distribuidor de 4"	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:Distribuidor de 4"]	2026-09-21 11:10:13.481647
6039	Inv_alt_1040015	\N	\N	Distribuidor de 2"	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:Distribuidor de 2"]	2026-09-21 11:10:13.481647
6041	INV_VPRO_ALT_00220	\N	\N	Base metal para monitor	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA		2026-09-21 11:10:13.481647
6044	Inv_alt_1040016	\N	\N	Mesa pegable	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:Mesa pegable]	2026-09-21 11:10:13.481647
6046	Inv_alt_1040017	\N	\N	Multicontaco	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:Multicontaco]	2026-09-21 11:10:13.481647
6047	Inv_alt_1040018	\N	\N	Cable de red	\N	\N	\N	Jose Francisco Torres Sanchez	104	Buen Estado	BODEGA	[CUST_EQ:Cable de red]	2026-09-21 11:10:13.481647
6049	Inv_alt_1090065	\N	\N	HDMI SPLITTER 1X2 OREI	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:HDMI SPLITTER 1X2 OREI]	2026-09-21 11:16:49.422839
6050	Inv_alt_1090066	\N	\N	Consola audio mini vMix	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Consola audio mini vMix]	2026-09-21 11:16:49.422839
6059	Inv_alt_1090067	\N	\N	Decimator	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Decimator]	2026-09-21 11:16:49.422839
6061	Inv_alt_1090068	\N	\N	Convertidores	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Convertidores]	2026-09-21 11:16:49.422839
6062	Inv_alt_1090069	\N	\N	Bidireccional	\N	\N	\N	Osiel Cuauhtemoc Hernandez Aldape	109	Buen Estado	BODEGA	[CUST_EQ:Bidireccional]	2026-09-21 11:16:49.422839
\.


--
-- Data for Name: reparaciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reparaciones (num_d_servicio, fecha_d_reporte, equipo_n_reparacion, area_q_pertenece, marca, folio_vpro, modelo, responsiva, responsable_d_equipo, reportante, estado_actual, descripcion_del_dano, accion_a_seguir, detalles_de_reparacion, encargado_d_reparacion, recibe_equipo, fec_d_ent_a_reparacion, costo_d_reparacion, importe, fecha_d_entrega, proveedor1, proveedor2, proveedor3, cant1, cant2, cant3, costo1, costo2, costo3, importe1, importe2, importe3, plazo_de_entrega1, plazo_de_entrega2, plazo_de_entrega3, llegada1, llegada2, llegada3, fecha_d_pago1, fecha_d_pago2, fecha_d_pago3, firma_resp, firma_jefe_inmediato, firma_admon, firma_entrega_equipo, num_responsiva_nva) FROM stdin;
REP-INT-1787853272	2026-08-27	MONITOR LCD, AOC,TECLADO ASSY P/697737-161 CT:BCYSTOAHH7132V. MOUSE 24GHZ WIRELESS OPTICAL	SISTEMAS	\N	MANTENIMIENTO_INTERNO	\N	\N	\N	Empleado ID: 201	RESUELTO	Se ve mal la imagen, Daña la vista lo tenia Geo Estrada.... Se acordó que se le instalará otro por mientras pero si hay evento se llevará al evento, quedandose el momentaneamente sin monitor.	\N	\N	\N	\N	\N	0.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
REP-INT-1787791104	2026-08-26	MONITOR LCD, AOC,TECLADO ASSY P/697737-161 CT:BCYSTOAHH7132V. MOUSE 24GHZ WIRELESS OPTICAL	SISTEMAS	\N	MANTENIMIENTO_INTERNO	\N	\N	\N	Empleado ID: 201	RESUELTO	Se ve mal la imagen, Daña la vista lo tenia Geo Estrada.... Se acordó que se le instalará otro por mientras pero si hay evento se llevará al evento, quedandose el momentaneamente sin monitor.	\N	\N	\N	\N	\N	0.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
REP-INT-1788212086	2026-08-31	A/ACONDICIOADO MARCA MIRAGE EN LA OFNA DEL DEPTO DE SISTEMAS	SISTEMAS	\N	MANTENIMIENTO_INTERNO	\N	\N	\N	Empleado ID: 201	RESUELTO	El AA tira agua sobre la estanteria	\N	\N	\N	\N	\N	0.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
REP-INT-1788212369	2026-08-31	A/ACONDICIOADO MARCA MIRAGE EN LA OFNA DEL DEPTO DE SISTEMAS	SISTEMAS	\N	MANTENIMIENTO_INTERNO	\N	\N	\N	Empleado ID: 201	REPARADO	El AA tira agua sobre la estanteria	\N	\N	\N	\N	\N	0.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
REP-INT-1788212124	2026-08-31	A/ACONDICIOADO MARCA MIRAGE EN LA OFNA DEL DEPTO DE SISTEMAS	SISTEMAS	\N	MANTENIMIENTO_INTERNO	\N	\N	\N	Empleado ID: 201	RESUELTO	El AA tira agua sobre la estanteria	\N	\N	\N	\N	\N	0.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
REP-INT-1787791185	2026-08-26	MONITOR LCD, AOC,TECLADO ASSY P/697737-161 CT:BCYSTOAHH7132V. MOUSE 24GHZ WIRELESS OPTICAL	SISTEMAS	\N	MANTENIMIENTO_INTERNO	\N	\N	\N	Empleado ID: 201	REPARADO	Se ve mal la imagen, Daña la vista lo tenia Geo Estrada.... Se acordó que se le instalará otro por mientras pero si hay evento se llevará al evento, quedandose el momentaneamente sin monitor.	\N	\N	\N	\N	\N	0.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
REP-INT-1787684298	2026-08-25	COMPUTADORA DE ESCRITORIO CON DOS MONITORES	SISTEMAS	\N	MANTENIMIENTO_INTERNO	\N	\N	\N	Empleado ID: 201	REPARADO	zumbaba machin.	\N	\N	\N	\N	\N	0.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
REP-PRV-1786650268	2026-08-13	INCIDENCIA/FALTA DE SERVICIO	PROVEEDORES	\N	OP-1	\N	\N	\N	ELEVOX	BAJA DEFINITIVA	Falta/Daño reportado en Check-in de OP-1: al inicio de la transmision se escuchaba doble como eco	\N	\N	\N	\N	\N	0.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
REP-INT-1789166629	2026-09-11	TELMEX-SERCOMM-GN25L95	SISTEMAS	\N	MANTENIMIENTO_INTERNO	\N	\N	\N	Empleado ID: 202	⚙️ DAÑADO	Se reportó a telmex el 11/09/2026 , reporte 11522457	\N	\N	\N	\N	\N	0.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
REP-INT-1789673154	2026-09-17	VPNRED039	SISTEMAS	\N	MANTENIMIENTO_INTERNO	\N	\N	\N	Empleado ID: 201	⚙️ DAÑADO	Se daño al bajar de la camioneta... se me soltó/desprendió el sujetador.	\N	\N	\N	\N	\N	0.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Name: historial_clinico_equipo_id_registro_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.historial_clinico_equipo_id_registro_seq', 28, true);


--
-- Name: inventario_kits_id_inv_kits_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventario_kits_id_inv_kits_seq', 6062, true);


--
-- Name: historial_equipo historial_clinico_equipo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_equipo
    ADD CONSTRAINT historial_clinico_equipo_pkey PRIMARY KEY (id_registro);


--
-- Name: inventario_kits inventario_kits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario_kits
    ADD CONSTRAINT inventario_kits_pkey PRIMARY KEY (id_inv_kits);


--
-- Name: inventario inventario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario
    ADD CONSTRAINT inventario_pkey PRIMARY KEY (codigo);


--
-- Name: reparaciones reparaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reparaciones
    ADD CONSTRAINT reparaciones_pkey PRIMARY KEY (num_d_servicio);


--
-- Name: inventario_kits unique_codigo_inv_kits; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario_kits
    ADD CONSTRAINT unique_codigo_inv_kits UNIQUE (codigo_inv_kits);


--
-- PostgreSQL database dump complete
--

\unrestrict hIMNAfOs5vDGyKi2ylgwSKlsi7yn5gF9P3dhkVENmZ3E2qRK6YQCptA08wQECGv

