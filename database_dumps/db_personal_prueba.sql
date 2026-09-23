--
-- PostgreSQL database dump
--

\restrict b32TiRGcc6Ljh2Y27FeYLtgJIOOr3QMpod08vhg0jBCU35whnlkdNiCNSBNyudn

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
-- Name: control_horas_extras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.control_horas_extras (
    id_autorizacion integer NOT NULL,
    id_registro_asistencia integer,
    id_empleado character varying(50),
    nombre_empleado character varying(255),
    id_evento integer,
    folio_op character varying(50),
    nombre_evento character varying(255),
    productor_responsable character varying(255),
    fecha_jornada date,
    hora_entrada time without time zone,
    hora_salida_madrugada time without time zone,
    corte_ordinario time without time zone,
    horas_extra_calculadas numeric(5,2),
    estatus_aprobacion character varying(50) DEFAULT 'PENDIENTE'::character varying,
    aprobado_por character varying(255),
    fecha_aprobacion timestamp without time zone,
    observaciones text
);


ALTER TABLE public.control_horas_extras OWNER TO postgres;

--
-- Name: control_horas_extras_id_autorizacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.control_horas_extras_id_autorizacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.control_horas_extras_id_autorizacion_seq OWNER TO postgres;

--
-- Name: control_horas_extras_id_autorizacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.control_horas_extras_id_autorizacion_seq OWNED BY public.control_horas_extras.id_autorizacion;


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
-- Name: empleados; Type: TABLE; Schema: public; Owner: postgres
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
    rol character varying(20) DEFAULT 'PRODUCTOR'::character varying,
    rfc character varying(13),
    curp character varying(18),
    nss character varying(11),
    estado_civil character varying(20),
    domicilio text,
    ciudad character varying(100),
    cp character varying(5),
    contacto_emergencia character varying(150),
    tel_emergencia character varying(20),
    parentesco_emergencia character varying(50),
    escolaridad character varying(50),
    puesto character varying(100),
    tipo_contrato character varying(30),
    salario_mensual numeric(12,2),
    foto_url text,
    estatus_empleado character varying(20) DEFAULT 'ACTIVO'::character varying,
    fecha_baja date,
    motivo_baja text
);


ALTER TABLE public.empleados OWNER TO postgres;

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
-- Name: rh_capacitacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rh_capacitacion (
    id_capacitacion integer NOT NULL,
    id_empleado character varying(3) NOT NULL,
    nombre_curso character varying(200) NOT NULL,
    tipo character varying(50) DEFAULT 'INTERNA'::character varying,
    institucion character varying(150),
    fecha_inicio date,
    fecha_fin date,
    horas_duracion integer,
    resultado character varying(30) DEFAULT 'EN CURSO'::character varying,
    calificacion numeric(5,2),
    tiene_constancia boolean DEFAULT false,
    constancia_url text,
    costo numeric(12,2) DEFAULT 0,
    pagado_por_empresa boolean DEFAULT true,
    observaciones text,
    registrado_por character varying(100),
    fecha_registro timestamp without time zone DEFAULT now()
);


ALTER TABLE public.rh_capacitacion OWNER TO postgres;

--
-- Name: rh_capacitacion_id_capacitacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rh_capacitacion_id_capacitacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rh_capacitacion_id_capacitacion_seq OWNER TO postgres;

--
-- Name: rh_capacitacion_id_capacitacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rh_capacitacion_id_capacitacion_seq OWNED BY public.rh_capacitacion.id_capacitacion;


--
-- Name: rh_contratos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rh_contratos (
    id_contrato integer NOT NULL,
    id_empleado character varying(3) NOT NULL,
    folio_contrato character varying(30),
    tipo_contrato character varying(50) DEFAULT 'PLANTA'::character varying,
    fecha_inicio date NOT NULL,
    fecha_fin date,
    es_indefinido boolean DEFAULT false,
    puesto_contratado character varying(100),
    departamento character varying(100),
    salario_mensual numeric(12,2),
    dias_vacaciones_anuales integer DEFAULT 12,
    jornada character varying(50) DEFAULT 'COMPLETA'::character varying,
    horario character varying(100),
    clausulas_especiales text,
    archivo_contrato_url text,
    firmado_empleado boolean DEFAULT false,
    firmado_empresa boolean DEFAULT false,
    fecha_firma date,
    estatus_contrato character varying(30) DEFAULT 'VIGENTE'::character varying,
    renovacion_de integer,
    observaciones text,
    registrado_por character varying(100),
    fecha_registro timestamp without time zone DEFAULT now()
);


ALTER TABLE public.rh_contratos OWNER TO postgres;

--
-- Name: rh_contratos_id_contrato_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rh_contratos_id_contrato_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rh_contratos_id_contrato_seq OWNER TO postgres;

--
-- Name: rh_contratos_id_contrato_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rh_contratos_id_contrato_seq OWNED BY public.rh_contratos.id_contrato;


--
-- Name: rh_documentos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rh_documentos (
    id_documento integer NOT NULL,
    id_empleado character varying(3) NOT NULL,
    tipo_documento character varying(80),
    nombre_archivo character varying(200),
    archivo_url text,
    formato character varying(10),
    fecha_emision date,
    fecha_vencimiento date,
    esta_vigente boolean DEFAULT true,
    verificado_por_rh boolean DEFAULT false,
    observaciones text,
    subido_por character varying(100),
    fecha_subida timestamp without time zone DEFAULT now()
);


ALTER TABLE public.rh_documentos OWNER TO postgres;

--
-- Name: rh_documentos_id_documento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rh_documentos_id_documento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rh_documentos_id_documento_seq OWNER TO postgres;

--
-- Name: rh_documentos_id_documento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rh_documentos_id_documento_seq OWNED BY public.rh_documentos.id_documento;


--
-- Name: rh_entrevistas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rh_entrevistas (
    id_entrevista integer NOT NULL,
    id_solicitud integer,
    id_empleado character varying(3),
    tipo_entrevista character varying(50) DEFAULT 'INICIAL'::character varying,
    fecha_entrevista date,
    hora_inicio time without time zone,
    hora_fin time without time zone,
    entrevistador character varying(150),
    modalidad character varying(30) DEFAULT 'PRESENCIAL'::character varying,
    link_videollamada text,
    resultado character varying(30) DEFAULT 'PENDIENTE'::character varying,
    calificacion_general numeric(4,2),
    puntualidad numeric(4,2),
    presentacion numeric(4,2),
    conocimientos_tecnicos numeric(4,2),
    actitud numeric(4,2),
    comunicacion numeric(4,2),
    comentarios text,
    recomendacion text,
    archivo_prueba_url text,
    registrado_por character varying(100),
    fecha_registro timestamp without time zone DEFAULT now()
);


ALTER TABLE public.rh_entrevistas OWNER TO postgres;

--
-- Name: rh_entrevistas_id_entrevista_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rh_entrevistas_id_entrevista_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rh_entrevistas_id_entrevista_seq OWNER TO postgres;

--
-- Name: rh_entrevistas_id_entrevista_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rh_entrevistas_id_entrevista_seq OWNED BY public.rh_entrevistas.id_entrevista;


--
-- Name: rh_evaluaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rh_evaluaciones (
    id_evaluacion integer NOT NULL,
    id_empleado character varying(3) NOT NULL,
    periodo character varying(30),
    tipo character varying(50) DEFAULT 'SEMESTRAL'::character varying,
    evaluador character varying(150),
    puesto_evaluador character varying(100),
    puntualidad numeric(4,2),
    calidad_trabajo numeric(4,2),
    trabajo_equipo numeric(4,2),
    responsabilidad numeric(4,2),
    iniciativa numeric(4,2),
    comunicacion numeric(4,2),
    cumplimiento_objetivos numeric(4,2),
    calificacion_final numeric(4,2),
    nivel_desempeno character varying(30),
    fortalezas text,
    areas_mejora text,
    plan_accion text,
    comentarios_empleado text,
    firma_empleado boolean DEFAULT false,
    archivo_evaluacion_url text,
    registrado_por character varying(100),
    fecha_registro timestamp without time zone DEFAULT now()
);


ALTER TABLE public.rh_evaluaciones OWNER TO postgres;

--
-- Name: rh_evaluaciones_id_evaluacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rh_evaluaciones_id_evaluacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rh_evaluaciones_id_evaluacion_seq OWNER TO postgres;

--
-- Name: rh_evaluaciones_id_evaluacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rh_evaluaciones_id_evaluacion_seq OWNED BY public.rh_evaluaciones.id_evaluacion;


--
-- Name: rh_historial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rh_historial (
    id_historial integer NOT NULL,
    id_empleado character varying(3) NOT NULL,
    fecha_evento timestamp without time zone DEFAULT now(),
    tipo_evento character varying(60) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    referencia_tabla character varying(60),
    referencia_id integer,
    registrado_por character varying(100),
    es_automatico boolean DEFAULT false
);


ALTER TABLE public.rh_historial OWNER TO postgres;

--
-- Name: rh_historial_id_historial_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rh_historial_id_historial_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rh_historial_id_historial_seq OWNER TO postgres;

--
-- Name: rh_historial_id_historial_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rh_historial_id_historial_seq OWNED BY public.rh_historial.id_historial;


--
-- Name: rh_incapacidades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rh_incapacidades (
    id_incapacidad integer NOT NULL,
    id_empleado character varying(3) NOT NULL,
    folio_incapacidad character varying(30),
    tipo character varying(50) DEFAULT 'ENFERMEDAD GENERAL'::character varying,
    fecha_inicio date NOT NULL,
    fecha_fin date,
    dias_incapacidad integer,
    numero_imss character varying(20),
    medico_tratante character varying(150),
    diagnostico text,
    porcentaje_pago_imss numeric(5,2) DEFAULT 60.00,
    archivo_incapacidad_url text,
    estatus character varying(30) DEFAULT 'ACTIVA'::character varying,
    validado_por_rh boolean DEFAULT false,
    fecha_validacion date,
    observaciones text,
    registrado_por character varying(100),
    fecha_registro timestamp without time zone DEFAULT now()
);


ALTER TABLE public.rh_incapacidades OWNER TO postgres;

--
-- Name: rh_incapacidades_id_incapacidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rh_incapacidades_id_incapacidad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rh_incapacidades_id_incapacidad_seq OWNER TO postgres;

--
-- Name: rh_incapacidades_id_incapacidad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rh_incapacidades_id_incapacidad_seq OWNED BY public.rh_incapacidades.id_incapacidad;


--
-- Name: rh_permisos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rh_permisos (
    id_permiso integer NOT NULL,
    id_empleado character varying(3) NOT NULL,
    folio_permiso character varying(20),
    tipo_permiso character varying(50) DEFAULT 'PERSONAL'::character varying,
    fecha_solicitud date DEFAULT CURRENT_DATE,
    fecha_inicio date NOT NULL,
    fecha_fin date NOT NULL,
    dias_solicitados integer,
    con_goce_de_sueldo boolean DEFAULT true,
    justificacion text,
    archivo_justificante text,
    estatus character varying(30) DEFAULT 'PENDIENTE'::character varying,
    aprobado_por character varying(150),
    fecha_aprobacion date,
    motivo_rechazo text,
    impacta_asistencia boolean DEFAULT true,
    observaciones_rh text,
    registrado_por character varying(100),
    fecha_registro timestamp without time zone DEFAULT now()
);


ALTER TABLE public.rh_permisos OWNER TO postgres;

--
-- Name: rh_permisos_id_permiso_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rh_permisos_id_permiso_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rh_permisos_id_permiso_seq OWNER TO postgres;

--
-- Name: rh_permisos_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rh_permisos_id_permiso_seq OWNED BY public.rh_permisos.id_permiso;


--
-- Name: rh_solicitudes_empleo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rh_solicitudes_empleo (
    id_solicitud integer NOT NULL,
    folio character varying(20),
    fecha_solicitud date DEFAULT CURRENT_DATE,
    nombre_completo character varying(200) NOT NULL,
    email character varying(150),
    tel_celular character varying(20),
    fecha_nac date,
    rfc character varying(13),
    curp character varying(18),
    domicilio text,
    escolaridad character varying(50),
    carrera_especialidad character varying(150),
    cedula_profesional character varying(30),
    puesto_solicitado character varying(100),
    depto_solicitado character varying(100),
    experiencia_anios integer DEFAULT 0,
    experiencia_descripcion text,
    habilidades text,
    pretension_salarial numeric(12,2),
    como_se_entero character varying(100),
    referido_por character varying(150),
    disponibilidad_inmediata boolean DEFAULT false,
    fecha_disponible date,
    tiene_auto boolean DEFAULT false,
    tiene_licencia boolean DEFAULT false,
    cv_url text,
    estatus character varying(30) DEFAULT 'RECIBIDA'::character varying,
    observaciones_rh text,
    id_empleado_resultado character varying(3),
    creado_por character varying(100),
    fecha_creacion timestamp without time zone DEFAULT now()
);


ALTER TABLE public.rh_solicitudes_empleo OWNER TO postgres;

--
-- Name: rh_solicitudes_empleo_id_solicitud_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rh_solicitudes_empleo_id_solicitud_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rh_solicitudes_empleo_id_solicitud_seq OWNER TO postgres;

--
-- Name: rh_solicitudes_empleo_id_solicitud_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rh_solicitudes_empleo_id_solicitud_seq OWNED BY public.rh_solicitudes_empleo.id_solicitud;


--
-- Name: rh_vacaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rh_vacaciones (
    id_vacacion integer NOT NULL,
    id_empleado character varying(3) NOT NULL,
    anio_periodo integer NOT NULL,
    dias_correspondientes integer NOT NULL,
    dias_tomados integer DEFAULT 0,
    dias_pendientes integer,
    fecha_inicio_goce date,
    fecha_fin_goce date,
    fecha_limite_goce date,
    tipo character varying(30) DEFAULT 'ORDINARIA'::character varying,
    estatus character varying(30) DEFAULT 'SOLICITADA'::character varying,
    aprobado_por character varying(150),
    fecha_aprobacion date,
    notificado_admon boolean DEFAULT false,
    fecha_notif_admon date,
    observaciones text,
    registrado_por character varying(100),
    fecha_registro timestamp without time zone DEFAULT now()
);


ALTER TABLE public.rh_vacaciones OWNER TO postgres;

--
-- Name: rh_vacaciones_id_vacacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rh_vacaciones_id_vacacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rh_vacaciones_id_vacacion_seq OWNER TO postgres;

--
-- Name: rh_vacaciones_id_vacacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rh_vacaciones_id_vacacion_seq OWNED BY public.rh_vacaciones.id_vacacion;


--
-- Name: asistencia_eventos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asistencia_eventos ALTER COLUMN id SET DEFAULT nextval('public.asistencia_eventos_id_seq'::regclass);


--
-- Name: control_asistencia id_registro; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.control_asistencia ALTER COLUMN id_registro SET DEFAULT nextval('public.control_asistencia_id_registro_seq'::regclass);


--
-- Name: control_horas_extras id_autorizacion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.control_horas_extras ALTER COLUMN id_autorizacion SET DEFAULT nextval('public.control_horas_extras_id_autorizacion_seq'::regclass);


--
-- Name: departamentos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamentos ALTER COLUMN id SET DEFAULT nextval('public.departamentos_id_seq'::regclass);


--
-- Name: log_accesos id_log; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_accesos ALTER COLUMN id_log SET DEFAULT nextval('public.log_accesos_id_log_seq'::regclass);


--
-- Name: rh_capacitacion id_capacitacion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_capacitacion ALTER COLUMN id_capacitacion SET DEFAULT nextval('public.rh_capacitacion_id_capacitacion_seq'::regclass);


--
-- Name: rh_contratos id_contrato; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_contratos ALTER COLUMN id_contrato SET DEFAULT nextval('public.rh_contratos_id_contrato_seq'::regclass);


--
-- Name: rh_documentos id_documento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_documentos ALTER COLUMN id_documento SET DEFAULT nextval('public.rh_documentos_id_documento_seq'::regclass);


--
-- Name: rh_entrevistas id_entrevista; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_entrevistas ALTER COLUMN id_entrevista SET DEFAULT nextval('public.rh_entrevistas_id_entrevista_seq'::regclass);


--
-- Name: rh_evaluaciones id_evaluacion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_evaluaciones ALTER COLUMN id_evaluacion SET DEFAULT nextval('public.rh_evaluaciones_id_evaluacion_seq'::regclass);


--
-- Name: rh_historial id_historial; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_historial ALTER COLUMN id_historial SET DEFAULT nextval('public.rh_historial_id_historial_seq'::regclass);


--
-- Name: rh_incapacidades id_incapacidad; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_incapacidades ALTER COLUMN id_incapacidad SET DEFAULT nextval('public.rh_incapacidades_id_incapacidad_seq'::regclass);


--
-- Name: rh_permisos id_permiso; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_permisos ALTER COLUMN id_permiso SET DEFAULT nextval('public.rh_permisos_id_permiso_seq'::regclass);


--
-- Name: rh_solicitudes_empleo id_solicitud; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_solicitudes_empleo ALTER COLUMN id_solicitud SET DEFAULT nextval('public.rh_solicitudes_empleo_id_solicitud_seq'::regclass);


--
-- Name: rh_vacaciones id_vacacion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_vacaciones ALTER COLUMN id_vacacion SET DEFAULT nextval('public.rh_vacaciones_id_vacacion_seq'::regclass);


--
-- Data for Name: asistencia_eventos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.asistencia_eventos (id, id_empleado, nombre_empleado, cliente, fecha_evento) FROM stdin;
\.


--
-- Data for Name: control_asistencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.control_asistencia (id_registro, id_empleado, fecha, hora_entrada, hora_salida, estatus, observaciones, hora_entrada_v, hora_salida_v) FROM stdin;
1	201	2026-08-13	05:00:00	22:00:00	ASISTENCIA	Llamado Locación (OP-1) a las 05:00 | Salida Locación: 22:00:00	\N	\N
2	202	2026-08-13	05:00:00	22:00:00	ASISTENCIA	Llamado Locación (OP-1) a las 05:00 | Salida Locación: 22:00:00	\N	\N
3	104	2026-08-13	05:00:00	22:00:00	ASISTENCIA	Llamado Locación (OP-1) a las 05:00 | Salida Locación: 22:00:00	\N	\N
4	201	2026-08-17	17:04:09	\N	RETARDO	Kiosco - T. Vespertino	\N	\N
5	119	2026-08-17	19:00:29	\N	RETARDO	Kiosco - T. Vespertino	\N	\N
6	124	2026-08-17	19:00:32	\N	RETARDO	Kiosco - T. Vespertino	\N	\N
7	113	2026-08-17	19:00:35	\N	RETARDO	Kiosco - T. Vespertino	\N	\N
8	109	2026-08-17	19:00:42	\N	RETARDO	Kiosco - T. Vespertino	\N	\N
15	105	2026-08-18	08:54:49	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
41	113	2026-08-21	05:35:28	12:33:11	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
39	201	2026-08-21	05:33:36	15:33:26	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
13	125	2026-08-18	08:53:41	13:44:32	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
28	115	2026-08-19	08:54:09	14:00:10	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
10	115	2026-08-18	08:46:50	14:00:28	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
38	200	2026-08-20	09:04:54	13:43:38	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	16:38:59	\N
37	121	2026-08-20	09:04:36	13:43:57	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	16:39:03	\N
33	201	2026-08-20	08:54:34	14:39:38	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:55:42	18:44:50
34	124	2026-08-20	08:56:10	14:00:24	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:07:56	19:02:06
21	201	2026-08-19	07:59:45	14:53:09	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:45:21	18:00:51
26	121	2026-08-19	08:46:00	13:20:04	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:28:52	18:48:58
29	124	2026-08-19	09:01:24	14:00:06	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:59:42	18:49:05
31	113	2026-08-19	09:22:10	16:46:07	COMPLETO	Kiosco - T. Matutino | Kiosco - Fin Jornada | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:59:46	18:49:48
27	200	2026-08-19	08:52:36	13:20:15	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:28:50	18:50:29
11	200	2026-08-18	08:46:53	13:44:28	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:36:18	18:34:57
12	121	2026-08-18	08:47:09	13:44:30	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:35:38	18:34:58
9	201	2026-08-18	08:46:46	14:22:52	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:54:24	18:56:33
19	113	2026-08-18	09:16:06	14:01:08	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:00:17	\N
16	202	2026-08-18	08:58:28	14:00:34	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:55:09	19:00:21
17	124	2026-08-18	09:00:42	14:00:25	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:00:02	19:00:24
18	119	2026-08-18	09:04:54	14:00:21	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:00:10	19:00:28
14	104	2026-08-18	08:54:28	14:22:13	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:52:00	19:05:19
20	109	2026-08-18	09:57:19	19:32:56	RETARDO	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
22	105	2026-08-19	08:20:44	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
23	104	2026-08-19	08:21:42	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
24	202	2026-08-19	08:41:34	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
30	119	2026-08-19	09:01:40	\N	RETARDO	Kiosco - T. Matutino	\N	\N
25	125	2026-08-19	08:45:49	13:17:36	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
35	113	2026-08-20	08:58:58	14:02:48	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:15:26	19:02:55
36	125	2026-08-20	09:04:34	13:43:36	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
45	201	2026-08-22	09:01:01	13:56:25	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
32	115	2026-08-20	08:54:27	14:00:10	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
46	124	2026-08-22	09:04:06	14:00:27	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
42	125	2026-08-21	08:49:40	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
43	121	2026-08-21	08:50:05	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
44	200	2026-08-21	08:52:26	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
40	124	2026-08-21	05:34:10	12:30:15	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
48	200	2026-08-22	09:22:35	14:00:45	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
47	113	2026-08-22	09:14:27	14:00:59	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
49	119	2026-08-22	18:36:52	\N	RETARDO	Kiosco - T. Vespertino	\N	\N
50	104	2026-08-22	18:37:42	\N	RETARDO	Kiosco - T. Vespertino	\N	\N
56	105	2026-08-24	08:55:09	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
59	119	2026-08-24	08:58:31	14:02:05	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:03:21	19:02:44
52	202	2026-08-24	08:41:45	14:01:03	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
51	115	2026-08-24	08:41:11	14:01:24	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
116	201	2026-08-31	13:47:52	\N	RETARDO	Kiosco - T. Matutino	\N	\N
55	200	2026-08-24	08:54:02	19:11:00	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
61	201	2026-08-24	09:41:18	13:47:23	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:58:36	18:54:21
54	121	2026-08-24	08:52:56	16:37:39	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Fin Jornada | Kiosco - T. Vespertino	19:11:08	\N
60	113	2026-08-24	09:16:42	14:17:02	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:00:22	\N
88	201	2026-08-27	08:48:13	14:01:41	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:07:24	18:52:09
57	104	2026-08-24	08:55:12	14:32:20	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:45:35	19:00:18
53	107	2026-08-24	08:52:48	14:02:58	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:59:31	19:02:30
58	124	2026-08-24	08:58:14	14:02:15	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:03:00	19:02:37
62	125	2026-08-24	19:09:17	\N	RETARDO	Kiosco - T. Vespertino	\N	\N
69	105	2026-08-25	08:56:43	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
72	109	2026-08-25	09:05:43	\N	RETARDO	Kiosco - T. Matutino	\N	\N
87	115	2026-08-27	08:44:29	14:00:45	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
65	115	2026-08-25	08:38:39	14:01:05	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
86	104	2026-08-27	08:37:51	14:18:18	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:52:54	18:58:42
95	113	2026-08-27	09:16:57	14:04:52	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	18:58:49	\N
91	200	2026-08-27	09:01:01	13:41:30	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:30:05	18:59:01
94	202	2026-08-27	09:09:30	14:01:58	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:58:07	18:59:53
74	121	2026-08-25	14:19:35	\N	RETARDO	Kiosco - T. Matutino	\N	\N
93	107	2026-08-27	09:01:28	14:01:18	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:57:46	19:00:41
89	124	2026-08-27	08:56:51	14:01:09	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:02:08	19:00:45
76	200	2026-08-26	08:22:32	14:23:24	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:22:08	17:12:22
78	201	2026-08-26	08:35:17	14:23:14	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:10:13	18:07:54
83	113	2026-08-26	09:11:34	14:09:37	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:21:49	19:01:05
81	104	2026-08-26	08:50:07	14:28:15	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:43:58	19:01:34
79	202	2026-08-26	08:48:57	14:07:25	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:56:19	19:03:38
77	107	2026-08-26	08:33:40	15:42:14	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Fin Jornada | Kiosco - T. Vespertino	19:03:46	\N
75	119	2026-08-26	08:18:35	14:21:51	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:24:12	19:04:37
63	200	2026-08-25	08:03:06	14:20:15	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:23:13	18:02:12
70	201	2026-08-25	08:57:07	13:49:32	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:02:46	18:59:24
68	104	2026-08-25	08:56:41	15:28:12	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:54:49	19:00:06
73	113	2026-08-25	09:19:39	14:11:44	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:00:19	\N
71	107	2026-08-25	08:58:25	14:04:52	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:43:17	19:00:59
66	202	2026-08-25	08:39:17	15:43:02	COMPLETO	Kiosco - T. Matutino | Kiosco - Fin Jornada | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:54:45	19:01:06
67	124	2026-08-25	08:56:20	14:05:33	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:02:50	19:01:09
64	119	2026-08-25	08:29:49	14:07:42	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:04:03	19:01:17
80	105	2026-08-26	08:49:59	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
84	121	2026-08-26	14:23:28	\N	RETARDO	Kiosco - T. Matutino	\N	\N
82	124	2026-08-26	08:58:04	14:21:53	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:22:56	19:04:43
85	105	2026-08-27	08:37:18	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
105	121	2026-08-28	13:39:25	\N	RETARDO	Kiosco - T. Matutino	\N	\N
92	121	2026-08-27	09:01:04	16:30:09	RETARDO	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
90	119	2026-08-27	08:57:17	14:01:05	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:02:01	19:00:53
97	105	2026-08-28	05:36:52	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
98	107	2026-08-28	05:41:43	14:00:34	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
96	104	2026-08-28	05:36:41	14:00:40	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
103	115	2026-08-28	08:58:48	14:00:48	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
106	119	2026-08-28	14:01:01	\N	RETARDO	Kiosco - T. Matutino	\N	\N
102	124	2026-08-28	08:48:54	14:01:08	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
99	113	2026-08-28	05:58:15	14:01:50	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
101	202	2026-08-28	08:39:52	14:08:53	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	15:17:08	\N
100	200	2026-08-28	08:39:39	13:39:21	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	21:13:03	\N
107	109	2026-08-28	14:10:25	\N	RETARDO	Kiosco - T. Matutino	\N	\N
104	201	2026-08-28	09:00:28	14:08:45	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	15:15:41	\N
111	105	2026-08-31	08:55:43	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
113	202	2026-08-31	08:57:47	14:23:51	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:51:21	19:05:10
108	115	2026-08-31	08:50:57	14:03:13	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
112	104	2026-08-31	08:55:53	15:37:19	COMPLETO	Kiosco - T. Matutino | Kiosco - Fin Jornada | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:07:22	19:02:32
115	113	2026-08-31	09:18:09	14:26:24	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:01:31	\N
117	200	2026-08-31	14:00:02	19:02:02	RETARDO	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
118	109	2026-08-31	19:04:09	\N	RETARDO	Kiosco - T. Vespertino	\N	\N
109	124	2026-08-31	08:51:01	14:02:02	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:05:59	19:04:25
110	119	2026-08-31	08:51:07	14:02:00	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:06:10	19:04:31
114	107	2026-08-31	09:04:55	14:03:07	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:51:35	19:05:44
119	115	2026-09-01	08:43:37	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
120	121	2026-09-01	08:46:17	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
123	105	2026-09-01	08:51:34	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
130	201	2026-09-02	08:03:14	14:36:28	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:59:01	17:35:15
132	121	2026-09-02	08:40:40	14:00:30	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:30:14	18:04:40
133	200	2026-09-02	08:42:22	14:00:37	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:30:25	18:05:46
134	124	2026-09-02	08:50:47	14:01:44	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:58:27	18:32:28
126	201	2026-09-01	08:58:10	14:15:05	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	15:55:47	\N
140	119	2026-09-02	09:39:22	14:01:40	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:59:22	18:32:34
135	202	2026-09-02	08:56:20	14:01:47	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:56:22	18:35:09
125	202	2026-09-01	08:54:12	17:17:17	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
122	119	2026-09-01	08:50:28	17:34:28	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
129	200	2026-09-01	18:45:08	\N	RETARDO	Kiosco - T. Vespertino	\N	\N
124	104	2026-09-01	08:51:56	14:52:31	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:55:42	19:00:28
127	113	2026-09-01	09:17:18	14:21:24	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:00:57	\N
128	109	2026-09-01	09:23:37	19:01:14	RETARDO	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
121	124	2026-09-01	08:50:19	15:56:32	COMPLETO	Kiosco - T. Matutino | Kiosco - Fin Jornada | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:00:29	19:01:25
136	105	2026-09-02	09:02:15	\N	RETARDO	Kiosco - T. Matutino	\N	\N
139	109	2026-09-02	09:33:37	\N	RETARDO	Kiosco - T. Matutino	\N	\N
131	115	2026-09-02	08:40:21	14:01:22	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
138	113	2026-09-02	09:17:43	14:10:50	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	18:37:30	\N
137	104	2026-09-02	09:02:25	14:10:42	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:47:21	18:38:02
149	200	2026-09-03	09:37:37	13:31:29	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	16:31:33	\N
141	201	2026-09-03	08:27:05	15:10:40	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:11:32	18:10:18
145	104	2026-09-03	08:55:42	14:53:54	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:39:54	19:00:37
147	119	2026-09-03	09:02:54	14:00:12	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:15:03	19:04:27
144	105	2026-09-03	08:55:30	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
150	121	2026-09-03	09:37:57	13:30:48	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
157	104	2026-09-04	12:50:34	\N	RETARDO	Kiosco - T. Matutino	\N	\N
154	124	2026-09-04	08:59:55	14:00:05	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:54:53	18:59:53
152	121	2026-09-04	08:57:09	13:30:50	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
143	115	2026-09-03	08:38:55	14:00:21	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
156	200	2026-09-04	09:09:07	13:30:48	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:50:52	19:16:59
151	201	2026-09-04	08:32:17	14:52:54	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:54:56	23:01:28
158	113	2026-09-04	15:02:42	\N	ASISTENCIA	Kiosco - T. Vespertino	\N	\N
146	124	2026-09-03	09:02:01	14:00:38	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:14:53	19:04:43
148	113	2026-09-03	09:16:04	14:15:12	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:13:46	\N
142	202	2026-09-03	08:34:24	14:00:10	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:56:18	19:16:45
159	109	2026-09-04	15:09:46	23:37:00	ASISTENCIA	Kiosco - T. Vespertino | Kiosco - Fin Jornada	\N	\N
163	105	2026-09-05	09:02:46	\N	RETARDO	Kiosco - T. Matutino	\N	\N
164	200	2026-09-05	09:05:51	\N	RETARDO	Kiosco - T. Matutino	\N	\N
162	124	2026-09-05	09:00:20	11:07:33	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
160	104	2026-09-05	00:03:02	15:54:37	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
166	109	2026-09-05	16:56:26	22:48:04	RETARDO	Kiosco - T. Vespertino | Kiosco - Fin Jornada	\N	\N
165	201	2026-09-05	15:39:23	22:33:20	ASISTENCIA	Kiosco - T. Vespertino | Kiosco - Fin Jornada	\N	\N
161	113	2026-09-05	00:03:05	17:14:51	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Fin Jornada | Kiosco - T. Vespertino	22:47:23	\N
168	105	2026-09-06	06:03:55	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
169	201	2026-09-06	15:32:35	20:29:46	ASISTENCIA	Kiosco - T. Vespertino | Kiosco - Fin Jornada	\N	\N
153	202	2026-09-04	08:57:48	\N	ASISTENCIA	Kiosco - T. Matutino | [EN GIRA] Salida Fin Jornada 23:34	\N	23:34:00
170	109	2026-09-06	16:00:29	\N	ASISTENCIA	Kiosco - T. Vespertino	\N	\N
171	113	2026-09-06	16:45:44	20:28:52	RETARDO	Kiosco - T. Vespertino | Kiosco - Fin Jornada	\N	\N
167	104	2026-09-06	05:57:31	13:37:48	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:32:56	20:31:24
174	121	2026-09-07	08:57:06	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
175	105	2026-09-07	09:00:04	12:10:41	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
177	113	2026-09-07	09:07:40	12:11:28	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
173	115	2026-09-07	08:56:28	14:00:49	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
176	200	2026-09-07	09:00:45	14:05:35	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
204	200	2026-09-10	08:47:42	13:52:56	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	16:23:57	\N
172	124	2026-09-07	08:56:09	14:01:16	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:53:38	17:59:24
184	105	2026-09-08	08:59:00	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
203	115	2026-09-10	08:36:53	14:00:56	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
182	115	2026-09-08	08:36:51	14:00:53	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
205	201	2026-09-10	08:57:51	14:35:01	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:14:21	18:52:17
187	119	2026-09-08	09:17:05	14:04:02	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
202	107	2026-09-10	08:27:41	14:00:36	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:01:21	18:58:25
196	107	2026-09-09	09:15:11	14:03:11	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	16:02:41	\N
208	113	2026-09-10	09:13:09	14:06:26	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:08:05	18:58:45
207	119	2026-09-10	09:03:07	14:01:39	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:00:20	18:59:39
206	124	2026-09-10	09:00:18	14:01:08	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:00:15	18:59:51
191	200	2026-09-09	08:54:24	13:46:47	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:32:12	18:12:21
197	113	2026-09-09	09:20:27	14:09:23	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:00:44	\N
198	109	2026-09-09	09:23:36	19:00:51	RETARDO	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
181	201	2026-09-08	08:34:38	14:04:08	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:53:28	18:57:30
186	202	2026-09-08	09:03:05	14:06:38	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:52:49	19:00:10
183	124	2026-09-08	08:40:43	14:02:31	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:07:54	19:00:22
188	113	2026-09-08	09:17:53	14:18:51	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:00:43	\N
185	104	2026-09-08	08:59:11	14:06:59	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:53:38	19:00:50
180	200	2026-09-08	08:32:59	13:00:16	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:28:23	19:01:49
194	105	2026-09-09	09:10:02	\N	RETARDO	Kiosco - T. Matutino	\N	\N
200	104	2026-09-10	08:15:27	14:17:19	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:44:12	15:59:21
189	115	2026-09-09	08:44:34	14:01:51	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
195	104	2026-09-09	09:10:31	14:09:28	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:41:10	19:00:55
193	119	2026-09-09	09:01:15	14:02:07	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:03:16	19:01:43
192	124	2026-09-09	09:00:17	14:01:42	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:02:45	19:01:46
190	201	2026-09-09	08:53:38	14:28:32	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:53:31	19:03:26
199	105	2026-09-10	08:13:51	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
211	200	2026-09-11	08:49:19	13:19:59	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
201	202	2026-09-10	08:16:06	14:00:10	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:03:22	19:00:00
217	119	2026-09-11	09:48:13	13:58:39	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:01:23	19:00:02
212	201	2026-09-11	08:50:40	14:12:53	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:57:04	18:54:13
209	202	2026-09-11	08:48:27	15:46:46	COMPLETO	Kiosco - T. Matutino | Kiosco - Fin Jornada | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:57:27	19:00:10
210	115	2026-09-11	08:48:36	14:00:09	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
216	107	2026-09-11	09:44:00	13:57:07	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:49:19	19:00:22
214	124	2026-09-11	09:43:03	13:59:10	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:00:59	19:00:15
215	104	2026-09-11	09:43:10	14:12:31	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:45:22	19:00:28
218	113	2026-09-11	14:01:24	19:01:22	RETARDO	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
219	105	2026-09-11	19:00:44	\N	RETARDO	Kiosco - T. Vespertino	\N	\N
213	109	2026-09-11	09:40:38	14:16:28	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:44:17	19:00:49
178	202	2026-09-07	08:36:00	13:19:06	GIRA / COMIDA	📍 [EN GIRA] Entrada Coord. 08:36 | Kiosco - Salida Matutina 13:19	\N	\N
179	119	2026-09-07	08:36:00	14:01:12	GIRA / COMIDA	📍 [EN GIRA] Entrada Coord. 08:36 | Kiosco - Salida Matutina 14:01	\N	\N
223	109	2026-09-12	09:04:40	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
155	119	2026-09-04	09:00:09	\N	ASISTENCIA	Kiosco - T. Matutino | [EN GIRA] Salida Fin Jornada 23:34	\N	23:34:00
222	201	2026-09-12	09:04:36	13:39:24	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
226	105	2026-09-12	09:07:38	14:00:10	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
228	113	2026-09-12	09:21:17	14:00:11	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
225	202	2026-09-12	09:04:50	14:00:17	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
220	119	2026-09-12	09:04:20	14:00:33	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
221	124	2026-09-12	09:04:24	14:00:36	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
227	104	2026-09-12	09:19:06	14:00:55	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
229	107	2026-09-12	14:01:12	\N	RETARDO	Kiosco - T. Matutino	\N	\N
224	115	2026-09-12	09:04:44	14:05:54	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
234	201	2026-09-14	08:44:54	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
230	121	2026-09-14	08:40:37	12:07:33	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
233	115	2026-09-14	08:44:24	13:00:22	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
252	121	2026-09-15	09:22:45	\N	RETARDO	Kiosco - T. Matutino	\N	\N
251	200	2026-09-15	09:22:41	12:53:21	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
247	115	2026-09-15	08:58:18	14:01:13	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
245	124	2026-09-15	08:58:06	14:01:42	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
235	124	2026-09-14	08:55:52	16:02:43	COMPLETO	Kiosco - T. Matutino | Kiosco - Fin Jornada | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:14:00	19:01:24
231	200	2026-09-14	08:40:42	12:07:44	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:02:11	\N
236	104	2026-09-14	08:55:56	19:27:27	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
238	105	2026-09-14	08:56:28	19:27:40	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
239	107	2026-09-14	09:00:37	14:10:29	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:00:24	19:28:08
237	119	2026-09-14	08:56:12	14:06:03	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:03:07	19:28:19
232	202	2026-09-14	08:41:17	14:09:13	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:57:34	19:28:28
240	113	2026-09-14	09:13:55	14:05:48	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:03:05	19:28:44
241	109	2026-09-14	09:28:03	14:08:27	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:28:58	\N
262	105	2026-09-17	09:05:18	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
266	115	2026-09-17	09:05:52	14:00:58	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
244	201	2026-09-15	08:58:00	\N	ASISTENCIA	Kiosco - T. Matutino | 📍 [EN GIRA] OP-19 - Grito de la independencia	\N	23:59:59
243	202	2026-09-15	08:57:57	\N	ASISTENCIA	Kiosco - T. Matutino | 📍 [EN GIRA] OP-19 - Grito de la independencia	\N	23:59:59
269	113	2026-09-17	09:20:59	14:21:27	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
242	104	2026-09-15	08:57:47	\N	ASISTENCIA	Kiosco - T. Matutino | 📍 [EN GIRA] OP-19 - Grito de la independencia	\N	23:59:59
250	109	2026-09-15	09:15:48	\N	RETARDO	Kiosco - T. Matutino | 📍 [EN GIRA] OP-19 - Grito de la independencia	\N	23:59:59
270	200	2026-09-17	09:28:55	13:45:36	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	18:42:58	\N
265	201	2026-09-17	09:05:30	14:07:14	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:53:29	18:58:59
263	104	2026-09-17	09:05:20	14:07:19	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	15:53:36	\N
267	202	2026-09-17	09:05:59	14:01:53	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	15:55:40	\N
264	107	2026-09-17	09:05:22	14:01:47	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	16:05:29	\N
268	119	2026-09-17	09:06:00	14:01:23	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	16:08:11	\N
261	124	2026-09-17	09:05:13	14:01:28	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	16:08:19	\N
292	201	2026-09-21	09:00:00	\N	A TIEMPO	Kiosco - T. Matutino | Ajuste manual (Sin luz)	\N	\N
293	202	2026-09-21	09:00:00	\N	A TIEMPO	Kiosco - T. Matutino | Ajuste manual (Sin luz)	\N	\N
294	115	2026-09-21	09:00:00	\N	A TIEMPO	Kiosco - T. Matutino | Ajuste manual (Sin luz)	\N	\N
272	201	2026-09-16	00:00:00	\N	GIRA / LOCACIÓN	🗓️ Día no laborable (Independencia) | 📍 [EN GIRA] OP-19 - Grito de la independencia | 🌙 Continuación jornada nocturna	\N	02:14:36
273	202	2026-09-16	00:00:00	\N	GIRA / LOCACIÓN	🗓️ Día no laborable (Independencia) | 📍 [EN GIRA] OP-19 - Grito de la independencia | 🌙 Continuación jornada nocturna	\N	02:15:25
274	104	2026-09-16	00:00:00	\N	GIRA / LOCACIÓN	🗓️ Día no laborable (Independencia) | 📍 [EN GIRA] OP-19 - Grito de la independencia | 🌙 Continuación jornada nocturna	\N	02:15:28
275	109	2026-09-16	00:00:00	\N	GIRA / LOCACIÓN	🗓️ Día no laborable (Independencia) | 📍 [EN GIRA] OP-19 - Grito de la independencia | 🌙 Continuación jornada nocturna	\N	02:15:32
248	113	2026-09-15	09:05:51	\N	ASISTENCIA	Kiosco - T. Matutino | 📍 [EN GIRA] OP-19 - Grito de la independencia	\N	23:59:59
276	113	2026-09-16	00:00:00	\N	GIRA / LOCACIÓN	🗓️ Día no laborable (Independencia) | 📍 [EN GIRA] OP-19 - Grito de la independencia | 🌙 Continuación jornada nocturna	\N	02:15:35
246	119	2026-09-15	08:58:11	\N	ASISTENCIA	Kiosco - T. Matutino | 📍 [EN GIRA] OP-19 - Grito de la independencia	\N	23:59:59
277	119	2026-09-16	00:00:00	\N	GIRA / LOCACIÓN	🗓️ Día no laborable (Independencia) | 📍 [EN GIRA] OP-19 - Grito de la independencia | 🌙 Continuación jornada nocturna	\N	02:15:58
249	107	2026-09-15	09:06:08	\N	RETARDO	Kiosco - T. Matutino | 📍 [EN GIRA] OP-19 - Grito de la independencia	\N	23:59:59
278	107	2026-09-16	00:00:00	\N	GIRA / LOCACIÓN	🗓️ Día no laborable (Independencia) | 📍 [EN GIRA] OP-19 - Grito de la independencia | 🌙 Continuación jornada nocturna	\N	02:16:10
271	105	2026-09-15	11:00:00	\N	GIRA / LOCACIÓN	Kiosco - T. Matutino | 📍 [EN GIRA] OP-19 - Grito de la independencia	\N	23:59:59
279	105	2026-09-16	00:00:00	\N	GIRA / LOCACIÓN	🗓️ Día no laborable (Independencia) | 📍 [EN GIRA] OP-19 - Grito de la independencia | 🌙 Continuación jornada nocturna	\N	02:16:47
296	104	2026-09-21	09:00:00	\N	A TIEMPO	Kiosco - T. Matutino | Ajuste manual (Sin luz)	\N	\N
297	119	2026-09-21	09:00:00	\N	A TIEMPO	Kiosco - T. Matutino | Ajuste manual (Sin luz)	\N	\N
302	104	2026-09-19	09:00:00	14:00:00	A TIEMPO	Ajuste manual: Turno Matutino (09:00 a 14:00)	\N	\N
303	121	2026-09-19	09:00:00	14:00:00	A TIEMPO	Ajuste manual: Turno Matutino (09:00 a 14:00)	\N	\N
298	124	2026-09-21	09:00:00	\N	A TIEMPO	Kiosco - T. Matutino | Ajuste manual (Sin luz)	\N	\N
299	107	2026-09-21	09:00:00	\N	A TIEMPO	Kiosco - T. Matutino | Ajuste manual (Sin luz)	\N	\N
300	109	2026-09-21	09:00:00	\N	A TIEMPO	Kiosco - T. Matutino | Ajuste manual (Sin luz)	\N	\N
304	200	2026-09-19	09:00:00	14:00:00	A TIEMPO	Ajuste manual: Turno Matutino (09:00 a 14:00)	\N	\N
290	104	2026-09-18	15:47:25	15:55:17	ASISTENCIA	Kiosco - T. Vespertino | Kiosco - Fin Jornada	\N	\N
305	109	2026-09-19	09:00:00	14:00:00	A TIEMPO	Ajuste manual: Turno Matutino (09:00 a 14:00)	\N	\N
306	113	2026-09-19	09:00:00	14:00:00	A TIEMPO	Ajuste manual: Turno Matutino (09:00 a 14:00)	\N	\N
307	202	2026-09-19	09:00:00	14:00:00	A TIEMPO	Ajuste manual: Turno Matutino (09:00 a 14:00)	\N	\N
308	107	2026-09-19	09:00:00	14:00:00	A TIEMPO	Ajuste manual: Turno Matutino (09:00 a 14:00)	\N	\N
288	121	2026-09-18	09:28:23	16:43:04	RETARDO	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
289	200	2026-09-18	09:28:26	16:43:26	RETARDO	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
309	201	2026-09-19	09:00:00	14:00:00	A TIEMPO	Ajuste manual: Turno Matutino (09:00 a 14:00)	\N	\N
310	124	2026-09-19	09:00:00	14:00:00	A TIEMPO	Ajuste manual: Turno Matutino (09:00 a 14:00)	\N	\N
301	113	2026-09-21	09:15:00	\N	RETARDO	Kiosco - T. Matutino | Ajuste manual | Kiosco - Comida	\N	\N
295	105	2026-09-21	09:00:00	\N	A TIEMPO	Kiosco - T. Matutino | Ajuste manual (Sin luz) | Kiosco - Comida	\N	\N
285	109	2026-09-18	09:08:01	\N	RETARDO	Kiosco - T. Matutino | Ajuste manual: Salida 19:00 (Sin luz)	\N	19:00:00
311	119	2026-09-19	09:00:00	14:00:00	A TIEMPO	Ajuste manual: Turno Matutino (09:00 a 14:00)	\N	\N
287	113	2026-09-18	09:17:23	14:02:12	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Ajuste manual: Salida 19:00 (Sin luz)	\N	19:00:00
281	202	2026-09-18	09:04:44	14:01:07	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Ajuste manual: Salida 19:00 (Sin luz)	15:54:57	19:00:00
284	107	2026-09-18	09:06:13	14:04:58	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Ajuste manual: Salida 19:00 (Sin luz)	15:59:38	19:00:00
280	201	2026-09-18	09:03:42	13:55:02	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Ajuste manual: Salida 19:00 (Sin luz)	16:02:36	19:00:00
283	124	2026-09-18	09:05:32	14:04:26	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Ajuste manual: Salida 19:00 (Sin luz)	16:04:43	19:00:00
286	119	2026-09-18	09:12:24	14:04:22	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Ajuste manual: Salida 19:00 (Sin luz)	16:05:02	19:00:00
282	115	2026-09-18	09:05:27	14:01:11	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Ajuste manual: Salida 19:00 (Sin luz)	\N	\N
312	115	2026-09-19	09:00:00	14:00:00	A TIEMPO	Ajuste manual: Turno Matutino (09:00 a 14:00)	\N	\N
313	105	2026-09-19	09:00:00	14:00:00	A TIEMPO	Ajuste manual: Turno Matutino (09:00 a 14:00)	\N	\N
314	104	2026-09-20	09:00:00	16:08:00	A TIEMPO	Ajuste manual: Turno 09:00 a 16:08	\N	\N
315	109	2026-09-20	09:00:00	16:08:00	A TIEMPO	Ajuste manual: Turno 09:00 a 16:08	\N	\N
\.


--
-- Data for Name: control_horas_extras; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.control_horas_extras (id_autorizacion, id_registro_asistencia, id_empleado, nombre_empleado, id_evento, folio_op, nombre_evento, productor_responsable, fecha_jornada, hora_entrada, hora_salida_madrugada, corte_ordinario, horas_extra_calculadas, estatus_aprobacion, aprobado_por, fecha_aprobacion, observaciones) FROM stdin;
1	244	201	Cuauhtemoc Rivera Agundez	19	19	Grito de la independencia	Martin Eduardo Sanchez Estrada	2026-09-15	08:58:00	02:14:36	19:00:00	7.23	AUTORIZADO	Martin Eduardo Sanchez Estrada	2026-09-17 17:15:24.845773	Horas extras jornada extendida OP-19 (434 mins) | AUTORIZADO por Martin Eduardo Sanchez Estrada
2	243	202	Edgar Javier Amarillas	19	19	Grito de la independencia	Martin Eduardo Sanchez Estrada	2026-09-15	08:57:57	02:15:25	19:00:00	7.25	AUTORIZADO	Martin Eduardo Sanchez Estrada	2026-09-17 17:15:24.845773	Horas extras jornada extendida OP-19 (435 mins) | AUTORIZADO por Martin Eduardo Sanchez Estrada
3	242	104	Jose Francisco Torres Sanchez	19	19	Grito de la independencia	Martin Eduardo Sanchez Estrada	2026-09-15	08:57:47	02:15:28	19:00:00	7.25	AUTORIZADO	Martin Eduardo Sanchez Estrada	2026-09-17 17:15:24.845773	Horas extras jornada extendida OP-19 (435 mins) | AUTORIZADO por Martin Eduardo Sanchez Estrada
4	250	109	Osiel Cuauhtemoc Hernandez Aldape	19	19	Grito de la independencia	Martin Eduardo Sanchez Estrada	2026-09-15	09:15:48	02:15:32	19:00:00	7.25	AUTORIZADO	Martin Eduardo Sanchez Estrada	2026-09-17 17:15:24.845773	Horas extras jornada extendida OP-19 (435 mins) | AUTORIZADO por Martin Eduardo Sanchez Estrada
5	248	113	Carlos Jacobo Quezada Mendoza	19	19	Grito de la independencia	Martin Eduardo Sanchez Estrada	2026-09-15	09:05:51	02:15:35	19:00:00	7.25	AUTORIZADO	Martin Eduardo Sanchez Estrada	2026-09-17 17:15:24.845773	Horas extras jornada extendida OP-19 (435 mins) | AUTORIZADO por Martin Eduardo Sanchez Estrada
6	246	119	Manuel Antonio Madrid Zazueta	19	19	Grito de la independencia	Martin Eduardo Sanchez Estrada	2026-09-15	08:58:11	02:15:58	19:00:00	7.25	AUTORIZADO	Martin Eduardo Sanchez Estrada	2026-09-17 17:15:24.845773	Horas extras jornada extendida OP-19 (435 mins) | AUTORIZADO por Martin Eduardo Sanchez Estrada
7	249	107	Martin Eduardo Sanchez Estrada	19	19	Grito de la independencia	Martin Eduardo Sanchez Estrada	2026-09-15	09:06:08	02:16:10	19:00:00	7.27	AUTORIZADO	Martin Eduardo Sanchez Estrada	2026-09-17 17:15:24.845773	Horas extras jornada extendida OP-19 (436 mins) | AUTORIZADO por Martin Eduardo Sanchez Estrada
8	271	105	Jose Daniel Torres Arroyo	19	19	Grito de la independencia	Martin Eduardo Sanchez Estrada	2026-09-15	11:00:00	02:16:47	19:00:00	7.27	AUTORIZADO	Martin Eduardo Sanchez Estrada	2026-09-17 17:15:24.845773	Horas extras jornada extendida OP-19 (436 mins) | AUTORIZADO por Martin Eduardo Sanchez Estrada
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
-- Data for Name: empleados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.empleados (id_empleado, nombre, depto, email, cel, fecha_nac, fecha_ing, licencia_vence, password, rol, rfc, curp, nss, estado_civil, domicilio, ciudad, cp, contacto_emergencia, tel_emergencia, parentesco_emergencia, escolaridad, puesto, tipo_contrato, salario_mensual, foto_url, estatus_empleado, fecha_baja, motivo_baja) FROM stdin;
103	Wilfrido Castro Beltran	ADMINISTRACION	notiene@hotmail.com	6676917919	1965-03-01	2016-01-28	2025-12-30	WilfridoC	BAJA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
110	Eduardo Alonso Valdez Gomez	PRODUCCION	eduardo.produccion@vprovideo.mx	6677769481	1976-10-01	2022-09-04	2050-02-25	EduardoA	BAJA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
116	Luz Damaris Quintero Pimentel	PRODUCCION		6674099301	2001-04-05	2025-03-10	2026-02-10	LuzD	BAJA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
117	Luis Quintin Mares Lopez	PRODUCCION	luis.camarografo@vprovideo.mx	6674766575	1990-05-06	2025-04-11	2025-10-11	vpro123	BAJA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
118	Hector Rementeria de la Rocha	PRODUCCION	hector.audio@vprovideo.mx	6671323708	2026-06-03	2022-11-26	2027-09-19	HectoR	BAJA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
122	Andrea Rivera Rivas	ADMINISTRACION	mkt@vprovideo.mx	6672090837	2000-09-08	2025-11-26	2026-01-15	AndreaR	BAJA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
123	Juan Pablo Espino Diaz	PRODUCCION	\N	6673278169	2003-06-17	2026-02-16	2026-01-31	JuanP	BAJA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
517	Ricardo Gonzalez	PRODUCCION		\N	1977-09-18	2024-08-22	2052-03-18	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
113	Carlos Jacobo Quezada Mendoza	PRODUCCION	carlos.edicion@vprovideo.mx	6674667614	2000-02-12	2023-12-07	2027-09-19	$2b$12$0/2ZlsvvQ3VvA5iB7fKDIO3SvhQF9orN6Em70sA1TjaR2L/b0uqcu	PRODUCCION	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
115	Ibon Araceli Campos Medina	ADMINISTRACION	notieneemail@hotmail.com	6674305028	1973-08-16	2025-02-09	2030-03-09	IbonA	PRODUCCION	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
508	Jaime Muro	PRODUCCION		\N	1900-01-01	2026-03-20	2050-05-22	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
101	Ana Lilia Villarreal Uribe	ADMINISTRACION	contabilidad@vprovideo.com	6671022524	1973-09-29	2015-11-26	2028-01-09	$2b$12$PdjiLZAyyKN1G/Oi7nAqkeUo7tZ492LZRYIP43gg9/Q6fjxvcz5.q	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
501	eduardo el condor	PRODUCCION	direcciown@vprovideo.com	\N	2026-09-08	2026-11-02	2026-12-12	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
525	Carlos Castillo	PRODUCCION		\N	1981-06-07	2023-12-10	2053-10-25	vpro123	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
529	Kiosco Bodega	KIOSKO		\N	2026-05-19	2026-05-09	2099-12-25	KioskO	LOGISTICA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
104	Jose Francisco Torres Sanchez	PRODUCCION	francisco.tecnico@vprovideo.mx	6672072138	1975-12-06	2016-12-04	2026-12-16	$2b$12$maVMyOl/cY9wwGFeGYj5guBuA1ZEUcSeE1cTFqA0fFvjHZMPpo5rm	PRODUCCION	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
102	Gerardo Villarreal Uribe	EDICION	gerardo@vprovideo.com	6673291087	1979-08-31	2015-12-27	2028-06-04	$2b$12$i4sfscS821ykcQvydKKPtOP1iA8Cwhcaskv383JWmW5e418fzAEee	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
121	Sofia Alejandra Villarreal Lopez	VENTAS	sofia.ventas@vprovideo.com	6673903759	1996-08-11	1996-08-11	2050-01-09	SofiA	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
125	Diego Villareal Lopez	ADMINISTRACION	diego@gmail.com	\N	2005-09-15	2005-09-15	2050-05-27	DiegoV	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
200	Andrea Maria Vilarreal Lopez	EDICION	andrea@vprovideo.mx	6673903762	1994-07-23	1994-07-23	2050-02-10	$2b$12$lV2c85P4yc6lwnIRoCi2j.Hljo1oSHpZaKdO7PH2XsdpR/arFOtGO	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
202	Edgar Javier Amarillas	SISTEMAS	live.stream@vprovideo.com	6672090481	1975-02-03	2024-09-24	2029-01-09	$2b$12$Kfzpr9LbUuRK3dIv/HMhOunhnQ3w6MGBXydLse2wTO/XyH8gje0XG	PRODUCCION	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
105	Jose Daniel Torres Arroyo	PRODUCCION	daniel.produccion@vprovideo.mx	6675788854	1999-01-28	2016-03-30	2100-02-21	$2b$12$GkNreszVLLBmt67EPXrk8eq5vqp1IzUQq/DayBhrESBKrWQZK/vUS	PRODUCCION	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
203	Pedro Villarreal Uribe	ADMINISTRACION	direccion@vprovideo.com	6672300488	1968-08-07	1964-08-07	2050-12-24	$2b$12$fXpITFlsgHoryqPp3q4MnOpzcmPswF.sI1XYbH9xxyI/Iv20VMtHq	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
502	Javier Garcia	PRODUCCION		\N	1900-01-01	2026-03-20	2027-12-12	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
512	Leonardo Leon	PRODUCCION		\N	2002-07-04	2021-06-21	2051-07-26	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
504	Ernesto Gutierrez	PRODUCCION		\N	1900-01-01	2026-03-20	2029-01-22	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
505	Calixto Villa	PRODUCCION		\N	1900-01-01	2026-03-20	2030-05-31	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
509	Jonahtan	PRODUCCION		\N	1900-01-01	2026-03-20	2050-05-23	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
506	Ignacio Garcia	PRODUCCION		\N	1900-01-01	2026-03-20	2050-02-21	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
510	Ivan Martinez	PRODUCCION		\N	2000-05-02	2018-04-21	2050-05-24	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
513	Ivan Jr	PRODUCCION		\N	2003-08-05	2022-07-22	2052-07-27	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
109	Osiel Cuauhtemoc Hernandez Aldape	PRODUCCION	osiel.switcher@vprovideo.mx	6671520296	1970-12-20	2022-08-03	2029-09-17	$2b$12$F/bN.Tz9OO8JWdaAA0Ck3eXAx.61ynhxHzEkNS3RBVN3s5wmAvxwm	PRODUCCION	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
515	Cristian Soto	PRODUCCION		\N	1975-02-04	2023-08-22	2051-07-27	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
521	Beatriz Cota	PRODUCCION		\N	1976-02-28	2023-12-05	2041-03-18	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
518	Cuquis	PRODUCCION		\N	1980-03-09	2024-07-23	2040-05-19	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
522	Jose Carlos	PRODUCCION		\N	1980-03-30	2024-10-09	2052-02-07	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
526	Victor (homi)	PRODUCCION		\N	1988-02-10	2022-09-15	2051-04-30	vpro123	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
519	Miguel	PRODUCCION		\N	1978-08-09	2024-02-11	2051-09-18	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
201	Cuauhtemoc Rivera Agundez	SISTEMAS	cuauhtemoc.manager@audiovideopro.com.mx	6674305026	1970-09-30	2021-03-31	2025-03-31	$2b$12$3nqc7ExmR0y2vyo5L8Ug1OwcwLsJ.28Lep/q3RGBbJ9oR80GaaBvm	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
503	Miguel Lara	PRODUCCION		\N	1900-01-01	2026-03-20	2028-12-21	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
527	Hair Sanchez	PRODUCCION		\N	1979-08-09	2024-11-12	2052-07-27	vpro123	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
523	Luis Silva	PRODUCCION		\N	1983-10-31	2024-11-08	2050-03-06	vpro123	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
530	Lorenzo Bastidas	PRODUCCION		\N	1988-08-17	2026-05-16	2050-05-20	vpro123	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
507	Ernesto Cuen	PRODUCCION		\N	1900-01-01	2026-03-20	2050-12-22	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
511	Pony	PRODUCCION		\N	2001-06-03	2020-05-20	2050-06-25	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
520	Cristina	PRODUCCION		\N	1988-08-07	2023-10-01	2053-03-17	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
516	Martin Miranda	PRODUCCION		\N	1978-08-04	2024-08-22	2053-07-27	vpro_sin_acceso	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
524	Carlos Pinzon	PRODUCCION		\N	1982-09-18	2023-11-07	2051-08-19	vpro123	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
528	Carlos Aleman	PRODUCCION		\N	1981-09-08	2024-07-10	2050-04-25	vpro123	PROVEEDOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
107	Martin Eduardo Sanchez Estrada	PRODUCCION	live.ventas@vprovideo.com	6678901234	1971-03-17	2016-06-01	2050-03-31	$2b$12$x2.aABcDfquVMc3gjo3JR.H5/lGp5gaLoYqNqgDeLbJvWJ1PGL7le	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
119	Manuel Antonio Madrid Zazueta	PRODUCCION	manuel@vprovideo.com	6671325182	1972-08-03	2019-11-26	2026-10-25	$2b$12$96Fw/6RABVtKdELqnoBXs.mVuGhN6LuNJJVF9TUZwMhkO5CcrQ2Qq	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
124	Manuel Eduardo Madrid	PRODUCCION	coordinador@vprovideo.com		1999-05-18	2026-03-23	2028-08-21	$2b$12$yi/.y4i8H7Pyg7G9icRaZuS2coy11GdoYQNWSwa8nHTkWIzQL8fuu	COORDINADOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
\.


--
-- Data for Name: log_accesos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log_accesos (id_log, fecha, hora, ip_origen, id_empleado, nombre_empleado, tipo_evento) FROM stdin;
\.


--
-- Data for Name: rh_capacitacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rh_capacitacion (id_capacitacion, id_empleado, nombre_curso, tipo, institucion, fecha_inicio, fecha_fin, horas_duracion, resultado, calificacion, tiene_constancia, constancia_url, costo, pagado_por_empresa, observaciones, registrado_por, fecha_registro) FROM stdin;
\.


--
-- Data for Name: rh_contratos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rh_contratos (id_contrato, id_empleado, folio_contrato, tipo_contrato, fecha_inicio, fecha_fin, es_indefinido, puesto_contratado, departamento, salario_mensual, dias_vacaciones_anuales, jornada, horario, clausulas_especiales, archivo_contrato_url, firmado_empleado, firmado_empresa, fecha_firma, estatus_contrato, renovacion_de, observaciones, registrado_por, fecha_registro) FROM stdin;
\.


--
-- Data for Name: rh_documentos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rh_documentos (id_documento, id_empleado, tipo_documento, nombre_archivo, archivo_url, formato, fecha_emision, fecha_vencimiento, esta_vigente, verificado_por_rh, observaciones, subido_por, fecha_subida) FROM stdin;
\.


--
-- Data for Name: rh_entrevistas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rh_entrevistas (id_entrevista, id_solicitud, id_empleado, tipo_entrevista, fecha_entrevista, hora_inicio, hora_fin, entrevistador, modalidad, link_videollamada, resultado, calificacion_general, puntualidad, presentacion, conocimientos_tecnicos, actitud, comunicacion, comentarios, recomendacion, archivo_prueba_url, registrado_por, fecha_registro) FROM stdin;
\.


--
-- Data for Name: rh_evaluaciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rh_evaluaciones (id_evaluacion, id_empleado, periodo, tipo, evaluador, puesto_evaluador, puntualidad, calidad_trabajo, trabajo_equipo, responsabilidad, iniciativa, comunicacion, cumplimiento_objetivos, calificacion_final, nivel_desempeno, fortalezas, areas_mejora, plan_accion, comentarios_empleado, firma_empleado, archivo_evaluacion_url, registrado_por, fecha_registro) FROM stdin;
\.


--
-- Data for Name: rh_historial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rh_historial (id_historial, id_empleado, fecha_evento, tipo_evento, descripcion, datos_anteriores, datos_nuevos, referencia_tabla, referencia_id, registrado_por, es_automatico) FROM stdin;
\.


--
-- Data for Name: rh_incapacidades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rh_incapacidades (id_incapacidad, id_empleado, folio_incapacidad, tipo, fecha_inicio, fecha_fin, dias_incapacidad, numero_imss, medico_tratante, diagnostico, porcentaje_pago_imss, archivo_incapacidad_url, estatus, validado_por_rh, fecha_validacion, observaciones, registrado_por, fecha_registro) FROM stdin;
\.


--
-- Data for Name: rh_permisos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rh_permisos (id_permiso, id_empleado, folio_permiso, tipo_permiso, fecha_solicitud, fecha_inicio, fecha_fin, dias_solicitados, con_goce_de_sueldo, justificacion, archivo_justificante, estatus, aprobado_por, fecha_aprobacion, motivo_rechazo, impacta_asistencia, observaciones_rh, registrado_por, fecha_registro) FROM stdin;
\.


--
-- Data for Name: rh_solicitudes_empleo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rh_solicitudes_empleo (id_solicitud, folio, fecha_solicitud, nombre_completo, email, tel_celular, fecha_nac, rfc, curp, domicilio, escolaridad, carrera_especialidad, cedula_profesional, puesto_solicitado, depto_solicitado, experiencia_anios, experiencia_descripcion, habilidades, pretension_salarial, como_se_entero, referido_por, disponibilidad_inmediata, fecha_disponible, tiene_auto, tiene_licencia, cv_url, estatus, observaciones_rh, id_empleado_resultado, creado_por, fecha_creacion) FROM stdin;
\.


--
-- Data for Name: rh_vacaciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rh_vacaciones (id_vacacion, id_empleado, anio_periodo, dias_correspondientes, dias_tomados, dias_pendientes, fecha_inicio_goce, fecha_fin_goce, fecha_limite_goce, tipo, estatus, aprobado_por, fecha_aprobacion, notificado_admon, fecha_notif_admon, observaciones, registrado_por, fecha_registro) FROM stdin;
\.


--
-- Name: asistencia_eventos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.asistencia_eventos_id_seq', 1, false);


--
-- Name: control_asistencia_id_registro_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.control_asistencia_id_registro_seq', 315, true);


--
-- Name: control_horas_extras_id_autorizacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.control_horas_extras_id_autorizacion_seq', 8, true);


--
-- Name: departamentos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.departamentos_id_seq', 5, true);


--
-- Name: log_accesos_id_log_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_accesos_id_log_seq', 1, false);


--
-- Name: rh_capacitacion_id_capacitacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rh_capacitacion_id_capacitacion_seq', 1, false);


--
-- Name: rh_contratos_id_contrato_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rh_contratos_id_contrato_seq', 1, false);


--
-- Name: rh_documentos_id_documento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rh_documentos_id_documento_seq', 1, false);


--
-- Name: rh_entrevistas_id_entrevista_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rh_entrevistas_id_entrevista_seq', 1, false);


--
-- Name: rh_evaluaciones_id_evaluacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rh_evaluaciones_id_evaluacion_seq', 1, false);


--
-- Name: rh_historial_id_historial_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rh_historial_id_historial_seq', 1, false);


--
-- Name: rh_incapacidades_id_incapacidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rh_incapacidades_id_incapacidad_seq', 1, false);


--
-- Name: rh_permisos_id_permiso_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rh_permisos_id_permiso_seq', 1, false);


--
-- Name: rh_solicitudes_empleo_id_solicitud_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rh_solicitudes_empleo_id_solicitud_seq', 1, false);


--
-- Name: rh_vacaciones_id_vacacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rh_vacaciones_id_vacacion_seq', 1, false);


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
-- Name: control_horas_extras control_horas_extras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.control_horas_extras
    ADD CONSTRAINT control_horas_extras_pkey PRIMARY KEY (id_autorizacion);


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
-- Name: rh_capacitacion rh_capacitacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_capacitacion
    ADD CONSTRAINT rh_capacitacion_pkey PRIMARY KEY (id_capacitacion);


--
-- Name: rh_contratos rh_contratos_folio_contrato_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_contratos
    ADD CONSTRAINT rh_contratos_folio_contrato_key UNIQUE (folio_contrato);


--
-- Name: rh_contratos rh_contratos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_contratos
    ADD CONSTRAINT rh_contratos_pkey PRIMARY KEY (id_contrato);


--
-- Name: rh_documentos rh_documentos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_documentos
    ADD CONSTRAINT rh_documentos_pkey PRIMARY KEY (id_documento);


--
-- Name: rh_entrevistas rh_entrevistas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_entrevistas
    ADD CONSTRAINT rh_entrevistas_pkey PRIMARY KEY (id_entrevista);


--
-- Name: rh_evaluaciones rh_evaluaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_evaluaciones
    ADD CONSTRAINT rh_evaluaciones_pkey PRIMARY KEY (id_evaluacion);


--
-- Name: rh_historial rh_historial_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_historial
    ADD CONSTRAINT rh_historial_pkey PRIMARY KEY (id_historial);


--
-- Name: rh_incapacidades rh_incapacidades_folio_incapacidad_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_incapacidades
    ADD CONSTRAINT rh_incapacidades_folio_incapacidad_key UNIQUE (folio_incapacidad);


--
-- Name: rh_incapacidades rh_incapacidades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_incapacidades
    ADD CONSTRAINT rh_incapacidades_pkey PRIMARY KEY (id_incapacidad);


--
-- Name: rh_permisos rh_permisos_folio_permiso_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_permisos
    ADD CONSTRAINT rh_permisos_folio_permiso_key UNIQUE (folio_permiso);


--
-- Name: rh_permisos rh_permisos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_permisos
    ADD CONSTRAINT rh_permisos_pkey PRIMARY KEY (id_permiso);


--
-- Name: rh_solicitudes_empleo rh_solicitudes_empleo_folio_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_solicitudes_empleo
    ADD CONSTRAINT rh_solicitudes_empleo_folio_key UNIQUE (folio);


--
-- Name: rh_solicitudes_empleo rh_solicitudes_empleo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_solicitudes_empleo
    ADD CONSTRAINT rh_solicitudes_empleo_pkey PRIMARY KEY (id_solicitud);


--
-- Name: rh_vacaciones rh_vacaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_vacaciones
    ADD CONSTRAINT rh_vacaciones_pkey PRIMARY KEY (id_vacacion);


--
-- Name: control_asistencia uq_empleado_fecha; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.control_asistencia
    ADD CONSTRAINT uq_empleado_fecha UNIQUE (id_empleado, fecha);


--
-- Name: empleados vpro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT vpro_pkey PRIMARY KEY (id_empleado);


--
-- Name: idx_rh_contratos_empleado; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rh_contratos_empleado ON public.rh_contratos USING btree (id_empleado);


--
-- Name: idx_rh_contratos_estatus; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rh_contratos_estatus ON public.rh_contratos USING btree (estatus_contrato);


--
-- Name: idx_rh_historial_empleado; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rh_historial_empleado ON public.rh_historial USING btree (id_empleado);


--
-- Name: idx_rh_historial_tipo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rh_historial_tipo ON public.rh_historial USING btree (tipo_evento);


--
-- Name: idx_rh_incap_empleado; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rh_incap_empleado ON public.rh_incapacidades USING btree (id_empleado);


--
-- Name: idx_rh_permisos_empleado; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rh_permisos_empleado ON public.rh_permisos USING btree (id_empleado);


--
-- Name: idx_rh_permisos_estatus; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rh_permisos_estatus ON public.rh_permisos USING btree (estatus);


--
-- Name: idx_rh_solicitudes_estatus; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rh_solicitudes_estatus ON public.rh_solicitudes_empleo USING btree (estatus);


--
-- Name: idx_rh_vacaciones_empleado; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rh_vacaciones_empleado ON public.rh_vacaciones USING btree (id_empleado);


--
-- Name: control_asistencia fk_empleado; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.control_asistencia
    ADD CONSTRAINT fk_empleado FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado) ON DELETE CASCADE;


--
-- Name: rh_contratos fk_renovacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_contratos
    ADD CONSTRAINT fk_renovacion FOREIGN KEY (renovacion_de) REFERENCES public.rh_contratos(id_contrato);


--
-- Name: rh_capacitacion rh_capacitacion_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_capacitacion
    ADD CONSTRAINT rh_capacitacion_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_contratos rh_contratos_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_contratos
    ADD CONSTRAINT rh_contratos_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_documentos rh_documentos_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_documentos
    ADD CONSTRAINT rh_documentos_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_entrevistas rh_entrevistas_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_entrevistas
    ADD CONSTRAINT rh_entrevistas_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_entrevistas rh_entrevistas_id_solicitud_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_entrevistas
    ADD CONSTRAINT rh_entrevistas_id_solicitud_fkey FOREIGN KEY (id_solicitud) REFERENCES public.rh_solicitudes_empleo(id_solicitud);


--
-- Name: rh_evaluaciones rh_evaluaciones_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_evaluaciones
    ADD CONSTRAINT rh_evaluaciones_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_historial rh_historial_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_historial
    ADD CONSTRAINT rh_historial_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_incapacidades rh_incapacidades_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_incapacidades
    ADD CONSTRAINT rh_incapacidades_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_permisos rh_permisos_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_permisos
    ADD CONSTRAINT rh_permisos_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_solicitudes_empleo rh_solicitudes_empleo_id_empleado_resultado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_solicitudes_empleo
    ADD CONSTRAINT rh_solicitudes_empleo_id_empleado_resultado_fkey FOREIGN KEY (id_empleado_resultado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_vacaciones rh_vacaciones_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rh_vacaciones
    ADD CONSTRAINT rh_vacaciones_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- PostgreSQL database dump complete
--

\unrestrict b32TiRGcc6Ljh2Y27FeYLtgJIOOr3QMpod08vhg0jBCU35whnlkdNiCNSBNyudn

