--
-- PostgreSQL database dump
--

\restrict 4RINXQt4VxDH7ZPJeIm58asgEfgiywEFsoEfzeodpqz60MsCGqIAQ90VbjnAn5Z

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

ALTER TABLE IF EXISTS ONLY public.rh_vacaciones DROP CONSTRAINT IF EXISTS rh_vacaciones_id_empleado_fkey;
ALTER TABLE IF EXISTS ONLY public.rh_solicitudes_empleo DROP CONSTRAINT IF EXISTS rh_solicitudes_empleo_id_empleado_resultado_fkey;
ALTER TABLE IF EXISTS ONLY public.rh_permisos DROP CONSTRAINT IF EXISTS rh_permisos_id_empleado_fkey;
ALTER TABLE IF EXISTS ONLY public.rh_incapacidades DROP CONSTRAINT IF EXISTS rh_incapacidades_id_empleado_fkey;
ALTER TABLE IF EXISTS ONLY public.rh_historial DROP CONSTRAINT IF EXISTS rh_historial_id_empleado_fkey;
ALTER TABLE IF EXISTS ONLY public.rh_evaluaciones DROP CONSTRAINT IF EXISTS rh_evaluaciones_id_empleado_fkey;
ALTER TABLE IF EXISTS ONLY public.rh_entrevistas DROP CONSTRAINT IF EXISTS rh_entrevistas_id_solicitud_fkey;
ALTER TABLE IF EXISTS ONLY public.rh_entrevistas DROP CONSTRAINT IF EXISTS rh_entrevistas_id_empleado_fkey;
ALTER TABLE IF EXISTS ONLY public.rh_documentos DROP CONSTRAINT IF EXISTS rh_documentos_id_empleado_fkey;
ALTER TABLE IF EXISTS ONLY public.rh_contratos DROP CONSTRAINT IF EXISTS rh_contratos_id_empleado_fkey;
ALTER TABLE IF EXISTS ONLY public.rh_capacitacion DROP CONSTRAINT IF EXISTS rh_capacitacion_id_empleado_fkey;
ALTER TABLE IF EXISTS ONLY public.rh_contratos DROP CONSTRAINT IF EXISTS fk_renovacion;
ALTER TABLE IF EXISTS ONLY public.control_asistencia DROP CONSTRAINT IF EXISTS fk_empleado;
DROP INDEX IF EXISTS public.idx_rh_vacaciones_empleado;
DROP INDEX IF EXISTS public.idx_rh_solicitudes_estatus;
DROP INDEX IF EXISTS public.idx_rh_permisos_estatus;
DROP INDEX IF EXISTS public.idx_rh_permisos_empleado;
DROP INDEX IF EXISTS public.idx_rh_incap_empleado;
DROP INDEX IF EXISTS public.idx_rh_historial_tipo;
DROP INDEX IF EXISTS public.idx_rh_historial_empleado;
DROP INDEX IF EXISTS public.idx_rh_contratos_estatus;
DROP INDEX IF EXISTS public.idx_rh_contratos_empleado;
DROP INDEX IF EXISTS public.idx_archivos_paquete;
DROP INDEX IF EXISTS public.idx_archivos_origen;
DROP INDEX IF EXISTS public.idx_archivos_estatus;
DROP INDEX IF EXISTS public.idx_archivos_destino;
ALTER TABLE IF EXISTS ONLY public.empleados DROP CONSTRAINT IF EXISTS vpro_pkey;
ALTER TABLE IF EXISTS ONLY public.control_asistencia DROP CONSTRAINT IF EXISTS uq_empleado_fecha;
ALTER TABLE IF EXISTS ONLY public.rh_vacaciones DROP CONSTRAINT IF EXISTS rh_vacaciones_pkey;
ALTER TABLE IF EXISTS ONLY public.rh_solicitudes_empleo DROP CONSTRAINT IF EXISTS rh_solicitudes_empleo_pkey;
ALTER TABLE IF EXISTS ONLY public.rh_solicitudes_empleo DROP CONSTRAINT IF EXISTS rh_solicitudes_empleo_folio_key;
ALTER TABLE IF EXISTS ONLY public.rh_permisos DROP CONSTRAINT IF EXISTS rh_permisos_pkey;
ALTER TABLE IF EXISTS ONLY public.rh_permisos DROP CONSTRAINT IF EXISTS rh_permisos_folio_permiso_key;
ALTER TABLE IF EXISTS ONLY public.rh_incapacidades DROP CONSTRAINT IF EXISTS rh_incapacidades_pkey;
ALTER TABLE IF EXISTS ONLY public.rh_incapacidades DROP CONSTRAINT IF EXISTS rh_incapacidades_folio_incapacidad_key;
ALTER TABLE IF EXISTS ONLY public.rh_historial DROP CONSTRAINT IF EXISTS rh_historial_pkey;
ALTER TABLE IF EXISTS ONLY public.rh_evaluaciones DROP CONSTRAINT IF EXISTS rh_evaluaciones_pkey;
ALTER TABLE IF EXISTS ONLY public.rh_entrevistas DROP CONSTRAINT IF EXISTS rh_entrevistas_pkey;
ALTER TABLE IF EXISTS ONLY public.rh_documentos DROP CONSTRAINT IF EXISTS rh_documentos_pkey;
ALTER TABLE IF EXISTS ONLY public.rh_contratos DROP CONSTRAINT IF EXISTS rh_contratos_pkey;
ALTER TABLE IF EXISTS ONLY public.rh_contratos DROP CONSTRAINT IF EXISTS rh_contratos_folio_contrato_key;
ALTER TABLE IF EXISTS ONLY public.rh_capacitacion DROP CONSTRAINT IF EXISTS rh_capacitacion_pkey;
ALTER TABLE IF EXISTS ONLY public.op_agenda DROP CONSTRAINT IF EXISTS op_agenda_pkey;
ALTER TABLE IF EXISTS ONLY public.log_accesos DROP CONSTRAINT IF EXISTS log_accesos_pkey;
ALTER TABLE IF EXISTS ONLY public.departamentos DROP CONSTRAINT IF EXISTS departamentos_pkey;
ALTER TABLE IF EXISTS ONLY public.departamentos DROP CONSTRAINT IF EXISTS departamentos_nombre_key;
ALTER TABLE IF EXISTS ONLY public.cronogramas_eventos DROP CONSTRAINT IF EXISTS cronogramas_eventos_pkey;
ALTER TABLE IF EXISTS ONLY public.control_horas_extras DROP CONSTRAINT IF EXISTS control_horas_extras_pkey;
ALTER TABLE IF EXISTS ONLY public.control_asistencia DROP CONSTRAINT IF EXISTS control_asistencia_pkey;
ALTER TABLE IF EXISTS ONLY public.asistencia_eventos DROP CONSTRAINT IF EXISTS asistencia_eventos_pkey;
ALTER TABLE IF EXISTS ONLY public.archivos_compartidos DROP CONSTRAINT IF EXISTS archivos_compartidos_pkey;
ALTER TABLE IF EXISTS public.rh_vacaciones ALTER COLUMN id_vacacion DROP DEFAULT;
ALTER TABLE IF EXISTS public.rh_solicitudes_empleo ALTER COLUMN id_solicitud DROP DEFAULT;
ALTER TABLE IF EXISTS public.rh_permisos ALTER COLUMN id_permiso DROP DEFAULT;
ALTER TABLE IF EXISTS public.rh_incapacidades ALTER COLUMN id_incapacidad DROP DEFAULT;
ALTER TABLE IF EXISTS public.rh_historial ALTER COLUMN id_historial DROP DEFAULT;
ALTER TABLE IF EXISTS public.rh_evaluaciones ALTER COLUMN id_evaluacion DROP DEFAULT;
ALTER TABLE IF EXISTS public.rh_entrevistas ALTER COLUMN id_entrevista DROP DEFAULT;
ALTER TABLE IF EXISTS public.rh_documentos ALTER COLUMN id_documento DROP DEFAULT;
ALTER TABLE IF EXISTS public.rh_contratos ALTER COLUMN id_contrato DROP DEFAULT;
ALTER TABLE IF EXISTS public.rh_capacitacion ALTER COLUMN id_capacitacion DROP DEFAULT;
ALTER TABLE IF EXISTS public.op_agenda ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.log_accesos ALTER COLUMN id_log DROP DEFAULT;
ALTER TABLE IF EXISTS public.departamentos ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.cronogramas_eventos ALTER COLUMN id_cronograma DROP DEFAULT;
ALTER TABLE IF EXISTS public.control_horas_extras ALTER COLUMN id_autorizacion DROP DEFAULT;
ALTER TABLE IF EXISTS public.control_asistencia ALTER COLUMN id_registro DROP DEFAULT;
ALTER TABLE IF EXISTS public.asistencia_eventos ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.archivos_compartidos ALTER COLUMN id_transferencia DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.rh_vacaciones_id_vacacion_seq;
DROP TABLE IF EXISTS public.rh_vacaciones;
DROP SEQUENCE IF EXISTS public.rh_solicitudes_empleo_id_solicitud_seq;
DROP TABLE IF EXISTS public.rh_solicitudes_empleo;
DROP SEQUENCE IF EXISTS public.rh_permisos_id_permiso_seq;
DROP TABLE IF EXISTS public.rh_permisos;
DROP SEQUENCE IF EXISTS public.rh_incapacidades_id_incapacidad_seq;
DROP TABLE IF EXISTS public.rh_incapacidades;
DROP SEQUENCE IF EXISTS public.rh_historial_id_historial_seq;
DROP TABLE IF EXISTS public.rh_historial;
DROP SEQUENCE IF EXISTS public.rh_evaluaciones_id_evaluacion_seq;
DROP TABLE IF EXISTS public.rh_evaluaciones;
DROP SEQUENCE IF EXISTS public.rh_entrevistas_id_entrevista_seq;
DROP TABLE IF EXISTS public.rh_entrevistas;
DROP SEQUENCE IF EXISTS public.rh_documentos_id_documento_seq;
DROP TABLE IF EXISTS public.rh_documentos;
DROP SEQUENCE IF EXISTS public.rh_contratos_id_contrato_seq;
DROP TABLE IF EXISTS public.rh_contratos;
DROP SEQUENCE IF EXISTS public.rh_capacitacion_id_capacitacion_seq;
DROP TABLE IF EXISTS public.rh_capacitacion;
DROP SEQUENCE IF EXISTS public.op_agenda_id_seq;
DROP TABLE IF EXISTS public.op_agenda;
DROP SEQUENCE IF EXISTS public.log_accesos_id_log_seq;
DROP TABLE IF EXISTS public.log_accesos;
DROP TABLE IF EXISTS public.empleados;
DROP SEQUENCE IF EXISTS public.departamentos_id_seq;
DROP TABLE IF EXISTS public.departamentos;
DROP SEQUENCE IF EXISTS public.cronogramas_eventos_id_cronograma_seq;
DROP TABLE IF EXISTS public.cronogramas_eventos;
DROP SEQUENCE IF EXISTS public.control_horas_extras_id_autorizacion_seq;
DROP TABLE IF EXISTS public.control_horas_extras;
DROP SEQUENCE IF EXISTS public.control_asistencia_id_registro_seq;
DROP TABLE IF EXISTS public.control_asistencia;
DROP SEQUENCE IF EXISTS public.asistencia_eventos_id_seq;
DROP TABLE IF EXISTS public.asistencia_eventos;
DROP SEQUENCE IF EXISTS public.archivos_compartidos_id_transferencia_seq;
DROP TABLE IF EXISTS public.archivos_compartidos;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: archivos_compartidos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.archivos_compartidos (
    id_transferencia integer NOT NULL,
    id_empleado_origen character varying(50) NOT NULL,
    nombre_origen character varying(255) NOT NULL,
    id_empleado_destino character varying(50) NOT NULL,
    nombre_destino character varying(255) NOT NULL,
    nombre_archivo_original character varying(255) NOT NULL,
    nombre_archivo_fisico character varying(255) NOT NULL,
    tamano_bytes bigint NOT NULL,
    tamano_legible character varying(50),
    tipo_mime character varying(100),
    mensaje text,
    folio_paquete character varying(100),
    fecha_subida timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    descargado boolean DEFAULT false,
    veces_descargado integer DEFAULT 0,
    fecha_primer_descarga timestamp without time zone,
    fecha_limite_borrado timestamp without time zone,
    estatus character varying(50) DEFAULT 'DISPONIBLE'::character varying,
    ip_origen character varying(50),
    es_lan_origen boolean,
    ip_descarga character varying(50),
    es_lan_descarga boolean
);


--
-- Name: archivos_compartidos_id_transferencia_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.archivos_compartidos_id_transferencia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: archivos_compartidos_id_transferencia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.archivos_compartidos_id_transferencia_seq OWNED BY public.archivos_compartidos.id_transferencia;


--
-- Name: asistencia_eventos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asistencia_eventos (
    id integer NOT NULL,
    id_empleado character varying,
    nombre_empleado text,
    cliente text,
    fecha_evento date
);


--
-- Name: asistencia_eventos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.asistencia_eventos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asistencia_eventos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.asistencia_eventos_id_seq OWNED BY public.asistencia_eventos.id;


--
-- Name: control_asistencia; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: control_asistencia_id_registro_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.control_asistencia_id_registro_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: control_asistencia_id_registro_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.control_asistencia_id_registro_seq OWNED BY public.control_asistencia.id_registro;


--
-- Name: control_horas_extras; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: control_horas_extras_id_autorizacion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.control_horas_extras_id_autorizacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: control_horas_extras_id_autorizacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.control_horas_extras_id_autorizacion_seq OWNED BY public.control_horas_extras.id_autorizacion;


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
-- Name: departamentos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departamentos (
    id integer NOT NULL,
    nombre text NOT NULL
);


--
-- Name: departamentos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.departamentos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: departamentos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.departamentos_id_seq OWNED BY public.departamentos.id;


--
-- Name: empleados; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: log_accesos; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: log_accesos_id_log_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.log_accesos_id_log_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_accesos_id_log_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_accesos_id_log_seq OWNED BY public.log_accesos.id_log;


--
-- Name: op_agenda; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.op_agenda (
    id integer NOT NULL,
    titulo character varying(255) NOT NULL,
    fecha_inicio timestamp without time zone NOT NULL,
    fecha_fin timestamp without time zone NOT NULL,
    todo_el_dia boolean DEFAULT false,
    tipo_evento character varying(50),
    color_fondo character varying(20) DEFAULT '#3788d8'::character varying,
    locacion character varying(255),
    recursos_tecnicos text,
    personal_asignado text,
    notas_adicionales text,
    creado_por character varying(100),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    estatus character varying(20) DEFAULT 'Activo'::character varying
);


--
-- Name: op_agenda_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.op_agenda_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: op_agenda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.op_agenda_id_seq OWNED BY public.op_agenda.id;


--
-- Name: rh_capacitacion; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: rh_capacitacion_id_capacitacion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rh_capacitacion_id_capacitacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rh_capacitacion_id_capacitacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rh_capacitacion_id_capacitacion_seq OWNED BY public.rh_capacitacion.id_capacitacion;


--
-- Name: rh_contratos; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: rh_contratos_id_contrato_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rh_contratos_id_contrato_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rh_contratos_id_contrato_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rh_contratos_id_contrato_seq OWNED BY public.rh_contratos.id_contrato;


--
-- Name: rh_documentos; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: rh_documentos_id_documento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rh_documentos_id_documento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rh_documentos_id_documento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rh_documentos_id_documento_seq OWNED BY public.rh_documentos.id_documento;


--
-- Name: rh_entrevistas; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: rh_entrevistas_id_entrevista_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rh_entrevistas_id_entrevista_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rh_entrevistas_id_entrevista_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rh_entrevistas_id_entrevista_seq OWNED BY public.rh_entrevistas.id_entrevista;


--
-- Name: rh_evaluaciones; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: rh_evaluaciones_id_evaluacion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rh_evaluaciones_id_evaluacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rh_evaluaciones_id_evaluacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rh_evaluaciones_id_evaluacion_seq OWNED BY public.rh_evaluaciones.id_evaluacion;


--
-- Name: rh_historial; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: rh_historial_id_historial_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rh_historial_id_historial_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rh_historial_id_historial_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rh_historial_id_historial_seq OWNED BY public.rh_historial.id_historial;


--
-- Name: rh_incapacidades; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: rh_incapacidades_id_incapacidad_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rh_incapacidades_id_incapacidad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rh_incapacidades_id_incapacidad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rh_incapacidades_id_incapacidad_seq OWNED BY public.rh_incapacidades.id_incapacidad;


--
-- Name: rh_permisos; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: rh_permisos_id_permiso_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rh_permisos_id_permiso_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rh_permisos_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rh_permisos_id_permiso_seq OWNED BY public.rh_permisos.id_permiso;


--
-- Name: rh_solicitudes_empleo; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: rh_solicitudes_empleo_id_solicitud_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rh_solicitudes_empleo_id_solicitud_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rh_solicitudes_empleo_id_solicitud_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rh_solicitudes_empleo_id_solicitud_seq OWNED BY public.rh_solicitudes_empleo.id_solicitud;


--
-- Name: rh_vacaciones; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: rh_vacaciones_id_vacacion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rh_vacaciones_id_vacacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rh_vacaciones_id_vacacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rh_vacaciones_id_vacacion_seq OWNED BY public.rh_vacaciones.id_vacacion;


--
-- Name: archivos_compartidos id_transferencia; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.archivos_compartidos ALTER COLUMN id_transferencia SET DEFAULT nextval('public.archivos_compartidos_id_transferencia_seq'::regclass);


--
-- Name: asistencia_eventos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asistencia_eventos ALTER COLUMN id SET DEFAULT nextval('public.asistencia_eventos_id_seq'::regclass);


--
-- Name: control_asistencia id_registro; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_asistencia ALTER COLUMN id_registro SET DEFAULT nextval('public.control_asistencia_id_registro_seq'::regclass);


--
-- Name: control_horas_extras id_autorizacion; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_horas_extras ALTER COLUMN id_autorizacion SET DEFAULT nextval('public.control_horas_extras_id_autorizacion_seq'::regclass);


--
-- Name: cronogramas_eventos id_cronograma; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cronogramas_eventos ALTER COLUMN id_cronograma SET DEFAULT nextval('public.cronogramas_eventos_id_cronograma_seq'::regclass);


--
-- Name: departamentos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamentos ALTER COLUMN id SET DEFAULT nextval('public.departamentos_id_seq'::regclass);


--
-- Name: log_accesos id_log; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_accesos ALTER COLUMN id_log SET DEFAULT nextval('public.log_accesos_id_log_seq'::regclass);


--
-- Name: op_agenda id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.op_agenda ALTER COLUMN id SET DEFAULT nextval('public.op_agenda_id_seq'::regclass);


--
-- Name: rh_capacitacion id_capacitacion; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_capacitacion ALTER COLUMN id_capacitacion SET DEFAULT nextval('public.rh_capacitacion_id_capacitacion_seq'::regclass);


--
-- Name: rh_contratos id_contrato; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_contratos ALTER COLUMN id_contrato SET DEFAULT nextval('public.rh_contratos_id_contrato_seq'::regclass);


--
-- Name: rh_documentos id_documento; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_documentos ALTER COLUMN id_documento SET DEFAULT nextval('public.rh_documentos_id_documento_seq'::regclass);


--
-- Name: rh_entrevistas id_entrevista; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_entrevistas ALTER COLUMN id_entrevista SET DEFAULT nextval('public.rh_entrevistas_id_entrevista_seq'::regclass);


--
-- Name: rh_evaluaciones id_evaluacion; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_evaluaciones ALTER COLUMN id_evaluacion SET DEFAULT nextval('public.rh_evaluaciones_id_evaluacion_seq'::regclass);


--
-- Name: rh_historial id_historial; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_historial ALTER COLUMN id_historial SET DEFAULT nextval('public.rh_historial_id_historial_seq'::regclass);


--
-- Name: rh_incapacidades id_incapacidad; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_incapacidades ALTER COLUMN id_incapacidad SET DEFAULT nextval('public.rh_incapacidades_id_incapacidad_seq'::regclass);


--
-- Name: rh_permisos id_permiso; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_permisos ALTER COLUMN id_permiso SET DEFAULT nextval('public.rh_permisos_id_permiso_seq'::regclass);


--
-- Name: rh_solicitudes_empleo id_solicitud; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_solicitudes_empleo ALTER COLUMN id_solicitud SET DEFAULT nextval('public.rh_solicitudes_empleo_id_solicitud_seq'::regclass);


--
-- Name: rh_vacaciones id_vacacion; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_vacaciones ALTER COLUMN id_vacacion SET DEFAULT nextval('public.rh_vacaciones_id_vacacion_seq'::regclass);


--
-- Data for Name: archivos_compartidos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.archivos_compartidos (id_transferencia, id_empleado_origen, nombre_origen, id_empleado_destino, nombre_destino, nombre_archivo_original, nombre_archivo_fisico, tamano_bytes, tamano_legible, tipo_mime, mensaje, folio_paquete, fecha_subida, descargado, veces_descargado, fecha_primer_descarga, fecha_limite_borrado, estatus, ip_origen, es_lan_origen, ip_descarga, es_lan_descarga) FROM stdin;
1	001	Administrador Test	002	Destinatario Test	test_file.txt	trans_1791250223_84fe24f8_test_file.txt	54	54 B	text/plain	Mensaje de prueba automatizada	TRF-1791250223-876F72	2026-10-05 19:30:23.633041	t	1	2026-10-05 19:30:23.664906	2026-10-06 02:30:23.664906	EXPIRADO_BORRADO	\N	\N	\N	\N
2	201	Cuauhtemoc Rivera Agundez	124	Manuel Eduardo Madrid	Talking Photo.mp4	trans_1791250447_6eed46c8_Talking_Photo.mp4	459212	448.4 KB	video/mp4		TRF-1791250447-8431D3	2026-10-05 19:34:07.790939	t	1	2026-10-05 19:35:48.962733	2026-10-06 02:35:48.962733	EXPIRADO_BORRADO	\N	\N	\N	\N
4	124	Manuel Eduardo Madrid	201	Cuauhtemoc Rivera Agundez	CRONOGRAMA TEBACAS JUEGO 03DE OCTUBRE DE 2026.docx	trans_1791250678_379984b6_CRONOGRAMA_TEBACAS_JUEGO_03DE_OCTUBRE_DE_2026.docx	27185	26.5 KB	application/vnd.openxmlformats-officedocument.wordprocessingml.document	Te mando el archivo	TRF-1791250678-3B879B	2026-10-05 19:37:58.365447	t	1	2026-10-05 19:38:59.720447	2026-10-06 02:38:59.720447	EXPIRADO_BORRADO	\N	\N	\N	\N
5	201	Cuauhtemoc Rivera Agundez	200	Andrea Maria Vilarreal Lopez	Talking Photo.mp4	trans_1791250793_843e1eb8_Talking_Photo.mp4	459212	448.4 KB	video/mp4	Este archivo enviado es de prueba.. a ver que te parece.	TRF-1791250793-9C752C	2026-10-05 19:39:53.728385	t	1	2026-10-05 19:44:43.656763	2026-10-06 02:44:43.656763	EXPIRADO_BORRADO	\N	\N	\N	\N
8	201	Cuauhtemoc Rivera Agundez	121	Sofia Alejandra Villarreal Lopez	PEDRO VILLAREAL URIBE - BATERIAS DE RESPALDO.pdf	trans_1791305197_24143be1_PEDRO_VILLAREAL_URIBE_-_BATERIAS_DE_RESPALDO.pdf	141914	138.6 KB	application/pdf		TRF-1791305197-927572	2026-10-06 10:46:37.068982	t	1	2026-10-06 10:47:01.747362	2026-10-06 17:47:01.747362	EXPIRADO_BORRADO	\N	\N	\N	\N
9	001	Administrador Test	002	Destinatario Test	test_file.txt	trans_1791307336_ff8f919b_test_file.txt	54	54 B	text/plain	Mensaje de prueba automatizada	TRF-1791307336-A3F001	2026-10-06 11:22:16.497056	t	1	2026-10-06 11:22:16.530835	2026-10-06 18:22:16.530835	EXPIRADO_BORRADO	\N	\N	\N	\N
6	200	Andrea Maria Vilarreal Lopez	201	Cuauhtemoc Rivera Agundez	WhatsApp Image 2026-08-31 at 7.28.01 PM.jpeg	trans_1791251165_c3da3a50_WhatsApp_Image_2026-08-31_at_7.28.01_PM.jpeg	139486	136.2 KB	image/jpeg		TRF-1791251165-593D21	2026-10-05 19:46:05.16742	t	2	2026-10-06 12:36:02.62543	2026-10-06 19:36:02.62543	EXPIRADO_BORRADO	\N	\N	\N	\N
7	201	Cuauhtemoc Rivera Agundez	200	Andrea Maria Vilarreal Lopez	PEDRO VILLAREAL URIBE - BATERIAS DE RESPALDO.pdf	trans_1791304961_9bff926b_PEDRO_VILLAREAL_URIBE_-_BATERIAS_DE_RESPALDO.pdf	141914	138.6 KB	application/pdf		TRF-1791304961-5080BE	2026-10-06 10:42:41.251501	t	1	2026-10-06 12:53:42.896384	2026-10-06 19:53:42.896384	EXPIRADO_BORRADO	\N	\N	\N	\N
10	200	Andrea Maria Vilarreal Lopez	201	Cuauhtemoc Rivera Agundez	Firma de Correo.png	trans_1791312810_c33daa7d_Firma_de_Correo.png	83502	81.5 KB	image/png		TRF-1791312810-787E64	2026-10-06 12:53:30.508514	t	1	2026-10-06 12:54:30.1246	2026-10-06 19:54:30.1246	EXPIRADO_BORRADO	\N	\N	\N	\N
3	201	Cuauhtemoc Rivera Agundez	124	Manuel Eduardo Madrid	chechout170226.csv	trans_1791250447_4710ccf4_chechout170226.csv	968	968 B	text/csv		TRF-1791250447-8431D3	2026-10-05 19:34:07.790939	f	0	\N	\N	EXPIRADO_BORRADO	\N	\N	\N	\N
99	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No145 Proveeduria internet a 10 modulos y cableado a stand, dias 02,03 y 04 sept. Costa Rica.xls	trans_1791914705_91e837ca_ORDEN_DE_PROD.No145_Proveeduria_internet_a_10_modulos_y_cableado_a_stand__dias_02_03_y_04_sept._Costa_Rica.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:57:03.849919	2026-10-14 13:57:03.849919	DESCARGADO	189.195.177.20	f	127.0.0.1	t
15	201	Cuauhtemoc Rivera Agundez	201	Cuauhtemoc Rivera Agundez	VPRO_ENTORNO_DESARROLLO_LAPTOP.zip	trans_1791336277_6f32edeb_VPRO_ENTORNO_DESARROLLO_LAPTOP.zip	730720190	696.9 MB	application/x-zip-compressed		TRF-1791336277-1FE739	2026-10-06 19:24:41.694906	t	1	2026-10-06 19:25:20.496173	2026-10-07 02:25:20.496173	EXPIRADO_BORRADO	\N	\N	\N	\N
16	201	Cuauhtemoc Rivera Agundez	201	Cuauhtemoc Rivera Agundez	VPRO_ENTORNO_DESARROLLO_LAPTOP.zip	trans_1791418150_55555085_VPRO_ENTORNO_DESARROLLO_LAPTOP.zip	731675506	697.8 MB	application/x-zip-compressed		TRF-1791418150-F66B8E	2026-10-07 18:09:14.771763	t	1	2026-10-07 18:10:44.612963	2026-10-08 01:10:44.612963	EXPIRADO_BORRADO	172.16.0.20	t	187.149.21.234	f
17	201	Cuauhtemoc Rivera Agundez	201	Cuauhtemoc Rivera Agundez	VPRO_ENTORNO_DESARROLLO_LAPTOP.zip	trans_1791484001_5b24b335_VPRO_ENTORNO_DESARROLLO_LAPTOP.zip	732341203	698.4 MB	application/x-zip-compressed		TRF-1791484001-BA0D0F	2026-10-08 12:26:46.99644	t	1	2026-10-08 12:27:18.252555	2026-10-08 19:27:18.252555	EXPIRADO_BORRADO	172.16.0.20	t	187.149.21.80	f
11	201	Cuauhtemoc Rivera Agundez	203	Pedro Villarreal Uribe	certif_iso.jpeg	trans_1791314791_ae4fb490_certif_iso.jpeg	139486	136.2 KB	image/jpeg		TRF-1791314791-6D6333	2026-10-06 13:26:31.134411	f	0	\N	\N	EXPIRADO_BORRADO	\N	\N	\N	\N
12	201	Cuauhtemoc Rivera Agundez	203	Pedro Villarreal Uribe	GemYyotears.jpg	trans_1791314791_da59c495_GemYyotears.jpg	126258	123.3 KB	image/jpeg		TRF-1791314791-6D6333	2026-10-06 13:26:31.134411	f	0	\N	\N	EXPIRADO_BORRADO	\N	\N	\N	\N
13	201	Cuauhtemoc Rivera Agundez	203	Pedro Villarreal Uribe	Risa_de_la_pdta.webm	trans_1791314791_b6b84ec6_Risa_de_la_pdta.webm	34997556	33.4 MB	video/webm		TRF-1791314791-6D6333	2026-10-06 13:26:31.134411	f	0	\N	\N	EXPIRADO_BORRADO	\N	\N	\N	\N
14	201	Cuauhtemoc Rivera Agundez	203	Pedro Villarreal Uribe	Inventario_2025-10-13_13-50.xlsx	trans_1791314791_8b76b6ad_Inventario_2025-10-13_13-50.xlsx	76933	75.1 KB	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet		TRF-1791314791-6D6333	2026-10-06 13:26:31.134411	f	0	\N	\N	EXPIRADO_BORRADO	\N	\N	\N	\N
19	124	Manuel Eduardo Madrid	201	Cuauhtemoc Rivera Agundez	AGENDA ACTIVIDADES VPRO 2026.xlsx	trans_1791587918_23809650_AGENDA_ACTIVIDADES_VPRO_2026.xlsx	253489	247.5 KB	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet		TRF-1791587918-37AAFD	2026-10-09 17:18:38.178131	t	1	2026-10-09 17:25:47.226797	2026-10-10 00:25:47.226797	EXPIRADO_BORRADO	172.16.0.52	t	127.0.0.1	t
18	201	Cuauhtemoc Rivera Agundez	124	Manuel Eduardo Madrid	certif_iso.jpeg	trans_1791577653_c6870645_certif_iso.jpeg	139486	136.2 KB	image/jpeg		TRF-1791577653-605703	2026-10-09 14:27:33.438136	t	1	2026-10-09 18:04:18.788714	2026-10-10 01:04:18.788714	EXPIRADO_BORRADO	127.0.0.1	t	172.16.0.52	t
20	124	Manuel Eduardo Madrid	201	Cuauhtemoc Rivera Agundez	AGENDA ACTIVIDADES VPRO 2026 (1).xlsx	trans_1791828162_25444da0_AGENDA_ACTIVIDADES_VPRO_2026__1_.xlsx	253112	247.2 KB	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet		TRF-1791828162-77D726	2026-10-12 12:02:42.872107	t	2	2026-10-12 12:04:20.71538	2026-10-12 19:04:20.71538	EXPIRADO_BORRADO	172.16.0.52	t	127.0.0.1	t
31	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.011 IEES Sesion Extraordinaria PRESENCIAL 211025.xls	trans_1791914585_c478c09d_ORDEN_DE_PROD.No.011_IEES_Sesion_Extraordinaria_PRESENCIAL_211025.xls	58880	57.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:02:36.17889	2026-10-14 14:02:36.17889	DESCARGADO	189.195.177.20	f	127.0.0.1	t
32	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.012 REUNION SEGURIDAD HARFUCH MAZATLAN 23-oct-25.xls	trans_1791914585_bef293d2_ORDEN_DE_PROD.No.012_REUNION_SEGURIDAD_HARFUCH_MAZATLAN_23-oct-25.xls	58880	57.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:02:46.050957	2026-10-14 14:02:46.050957	DESCARGADO	189.195.177.20	f	127.0.0.1	t
33	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.013 INFORME MORENA en Navolato 25-oct-25.xls	trans_1791914585_d7c4ead0_ORDEN_DE_PROD.No.013_INFORME_MORENA_en_Navolato_25-oct-25.xls	58880	57.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:02:54.04496	2026-10-14 14:02:54.04496	DESCARGADO	189.195.177.20	f	127.0.0.1	t
34	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.014  CONFERECIA REPSE-Aquamiller-30-oct-25.xls	trans_1791914585_bb3be953_ORDEN_DE_PROD.No.014__CONFERECIA_REPSE-Aquamiller-30-oct-25.xls	58368	57.0 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:03:10.16878	2026-10-14 14:03:10.16878	DESCARGADO	189.195.177.20	f	127.0.0.1	t
35	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.015 IEES Sesion Extraordinaria PRESENCIAL 01nov25.xls	trans_1791914585_dad9ca8f_ORDEN_DE_PROD.No.015_IEES_Sesion_Extraordinaria_PRESENCIAL_01nov25.xls	58880	57.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:03:41.12998	2026-10-14 14:03:41.12998	DESCARGADO	189.195.177.20	f	127.0.0.1	t
36	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.016 Cuadrangular del Bienestar-Los Mochis 11 Y 12 NOV..xls	trans_1791914585_fc41c580_ORDEN_DE_PROD.No.016_Cuadrangular_del_Bienestar-Los_Mochis_11_Y_12_NOV..xls	59392	58.0 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:04:08.353972	2026-10-14 14:04:08.353972	DESCARGADO	189.195.177.20	f	127.0.0.1	t
37	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.017 Semanera 27-oct-25.xls	trans_1791914585_646714b9_ORDEN_DE_PROD.No.017_Semanera_27-oct-25.xls	60928	59.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:04:28.246271	2026-10-14 14:04:28.246271	DESCARGADO	189.195.177.20	f	127.0.0.1	t
38	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.018 INFORME PDTE. MPAL. AHOME en Los mochis 28-oct-25.xls	trans_1791914585_6f6ca6dc_ORDEN_DE_PROD.No.018_INFORME_PDTE._MPAL._AHOME_en_Los_mochis_28-oct-25.xls	61952	60.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:04:33.401746	2026-10-14 14:04:33.401746	DESCARGADO	189.195.177.20	f	127.0.0.1	t
25	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.005 Cuadrangular del Bienestar-Los Mochis.xls	trans_1791914585_9d97cc35_ORDEN_DE_PROD.No.005_Cuadrangular_del_Bienestar-Los_Mochis.xls	61440	60.0 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:01:59.211368	2026-10-14 14:01:59.211368	DESCARGADO	189.195.177.20	f	127.0.0.1	t
27	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.007 Evento Inauguracion bombeo-Mazatlán.xls	trans_1791914585_739b63db_ORDEN_DE_PROD.No.007_Evento_Inauguracion_bombeo-Mazatl_n.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:02:12.305976	2026-10-14 14:02:12.305976	DESCARGADO	189.195.177.20	f	127.0.0.1	t
28	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.008 Evento Cuadrangular del Bienestar en Mazatlán Teodoro Mariscal.xls	trans_1791914585_a6fc4a35_ORDEN_DE_PROD.No.008_Evento_Cuadrangular_del_Bienestar_en_Mazatl_n_Teodoro_Mariscal.xls	65024	63.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:02:18.921579	2026-10-14 14:02:18.921579	DESCARGADO	189.195.177.20	f	127.0.0.1	t
29	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.009 Gob. del Edo. Giras- Los Mochis 171025.xls	trans_1791914585_ee64f19a_ORDEN_DE_PROD.No.009_Gob._del_Edo._Giras-_Los_Mochis_171025.xls	58880	57.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:02:23.98467	2026-10-14 14:02:23.98467	DESCARGADO	189.195.177.20	f	127.0.0.1	t
30	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.010 Semanera.xls	trans_1791914585_8bc58650_ORDEN_DE_PROD.No.010_Semanera.xls	60416	59.0 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:02:31.171495	2026-10-14 14:02:31.171495	DESCARGADO	189.195.177.20	f	127.0.0.1	t
39	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.019  Semanera 031125.xls	trans_1791914585_d8e4b713_ORDEN_DE_PROD.No.019__Semanera_031125.xls	60928	59.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:04:41.805146	2026-10-14 14:04:41.805146	DESCARGADO	189.195.177.20	f	127.0.0.1	t
40	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.020  Semanera 101125.xls	trans_1791914585_e6b971c6_ORDEN_DE_PROD.No.020__Semanera_101125.xls	60928	59.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:04:47.04967	2026-10-14 14:04:47.04967	DESCARGADO	189.195.177.20	f	127.0.0.1	t
41	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.021 IEES Sesion VIRTUAL 12nov25.xls	trans_1791914585_22de2b40_ORDEN_DE_PROD.No.021_IEES_Sesion_VIRTUAL_12nov25.xls	58368	57.0 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:04:51.547726	2026-10-14 14:04:51.547726	DESCARGADO	189.195.177.20	f	127.0.0.1	t
42	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.022 Gob. del Edo. 4to.INFORME GOB. CONGRESO 26112025.xls	trans_1791914585_ff1be4a8_ORDEN_DE_PROD.No.022_Gob._del_Edo._4to.INFORME_GOB._CONGRESO_26112025.xls	58880	57.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:04:55.442653	2026-10-14 14:04:55.442653	DESCARGADO	189.195.177.20	f	127.0.0.1	t
43	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.023 ISDE-PREMIO ESTATAL AL DEPORTE  27112025.xls	trans_1791914585_43ad325b_ORDEN_DE_PROD.No.023_ISDE-PREMIO_ESTATAL_AL_DEPORTE__27112025.xls	58368	57.0 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:04:59.563694	2026-10-14 14:04:59.563694	DESCARGADO	189.195.177.20	f	127.0.0.1	t
44	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.024 reunion seguridad badiraguato 131125.xls	trans_1791914585_d3402c0c_ORDEN_DE_PROD.No.024_reunion_seguridad_badiraguato_131125.xls	58880	57.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:05:03.354696	2026-10-14 14:05:03.354696	DESCARGADO	189.195.177.20	f	127.0.0.1	t
45	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.025 4TO.INFORME GOBIERNO Congreso 26NOV25.xls	trans_1791914585_71256ad5_ORDEN_DE_PROD.No.025_4TO.INFORME_GOBIERNO_Congreso_26NOV25.xls	59392	58.0 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:05:07.211043	2026-10-14 14:05:07.211043	DESCARGADO	189.195.177.20	f	127.0.0.1	t
46	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.026 Switcher y equipo para LIVE COPPEL  21NOV25.xls	trans_1791914585_eafaee70_ORDEN_DE_PROD.No.026_Switcher_y_equipo_para_LIVE_COPPEL__21NOV25.xls	59904	58.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:05:11.363136	2026-10-14 14:05:11.363136	DESCARGADO	189.195.177.20	f	127.0.0.1	t
47	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.027  Semanera 111125.xls	trans_1791914585_f8428bf2_ORDEN_DE_PROD.No.027__Semanera_111125.xls	60928	59.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	2	2026-10-13 14:05:15.995809	2026-10-14 14:05:15.995809	DESCARGADO	189.195.177.20	f	127.0.0.1	t
48	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.028  Semanera 171125.xls	trans_1791914585_c332fdd7_ORDEN_DE_PROD.No.028__Semanera_171125.xls	60928	59.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:05:21.890446	2026-10-14 14:05:21.890446	DESCARGADO	189.195.177.20	f	127.0.0.1	t
49	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.029  Semanera 241125.xls	trans_1791914585_2fcf485c_ORDEN_DE_PROD.No.029__Semanera_241125.xls	60928	59.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:05:25.601309	2026-10-14 14:05:25.601309	DESCARGADO	189.195.177.20	f	127.0.0.1	t
50	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.030  Enlace Mañanera Secret.Gob. -Auditorio 251125.xls	trans_1791914585_20c2eed1_ORDEN_DE_PROD.No.030__Enlace_Ma_anera_Secret.Gob._-Auditorio_251125.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:05:29.30647	2026-10-14 14:05:29.30647	DESCARGADO	189.195.177.20	f	127.0.0.1	t
51	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.031  Semanera 011225.xls	trans_1791914585_391c0108_ORDEN_DE_PROD.No.031__Semanera_011225.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	2	2026-10-13 14:05:34.714059	2026-10-14 14:05:34.714059	DESCARGADO	189.195.177.20	f	127.0.0.1	t
52	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.032  GIRAS  Secret. en Guasave 02-dic-25.xls	trans_1791914585_9040cfd4_ORDEN_DE_PROD.No.032__GIRAS__Secret._en_Guasave_02-dic-25.xls	60416	59.0 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:05:42.739745	2026-10-14 14:05:42.739745	DESCARGADO	189.195.177.20	f	127.0.0.1	t
53	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.033  GIRAS  Secret. ISDE CAR- Ma,. del Rosario 03-dic-25.xls	trans_1791914585_4b3c2e09_ORDEN_DE_PROD.No.033__GIRAS__Secret._ISDE_CAR-_Ma_._del_Rosario_03-dic-25.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:05:47.33917	2026-10-14 14:05:47.33917	DESCARGADO	189.195.177.20	f	127.0.0.1	t
54	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.034 COPPEL present.libro en PRIMAVERA 17-dic-25.xls	trans_1791914585_69deb630_ORDEN_DE_PROD.No.034_COPPEL_present.libro_en_PRIMAVERA_17-dic-25.xls	59904	58.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:05:51.833455	2026-10-14 14:05:51.833455	DESCARGADO	189.195.177.20	f	127.0.0.1	t
61	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.114 CEPROPIES-GIRAS Informe Presidencial 31mayo26.xls	trans_1791914705_221f0bf3_ORDEN_DE_PROD.No.114_CEPROPIES-GIRAS_Informe_Presidencial_31mayo26.xls	57344	56.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:57:21.130206	2026-10-14 13:57:21.130206	DESCARGADO	189.195.177.20	f	127.0.0.1	t
67	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.120 MORENA Salon Floresta Domnigo28jun26.xls	trans_1791914705_acffdac2_ORDEN_DE_PROD.No.120_MORENA_Salon_Floresta_Domnigo28jun26.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:57:56.362402	2026-10-14 13:57:56.362402	DESCARGADO	189.195.177.20	f	127.0.0.1	t
56	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.036 GRABACIONES MERCADITO MOVIL.xls	trans_1791914585_cabb4d82_ORDEN_DE_PROD.No.036_GRABACIONES_MERCADITO_MOVIL.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:07:32.27791	2026-10-14 14:07:32.27791	DESCARGADO	189.195.177.20	f	127.0.0.1	t
55	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.035 REGION 3ER ZONA MILITAR MAZATLAN.xls	trans_1791914585_3decf996_ORDEN_DE_PROD.No.035_REGION_3ER_ZONA_MILITAR_MAZATLAN.xls	57344	56.0 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	3	2026-10-13 14:05:55.755023	2026-10-14 14:05:55.755023	DESCARGADO	189.195.177.20	f	127.0.0.1	t
57	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.037  Semanera 081225.xls	trans_1791914585_2cd79369_ORDEN_DE_PROD.No.037__Semanera_081225.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:07:37.474064	2026-10-14 14:07:37.474064	DESCARGADO	189.195.177.20	f	127.0.0.1	t
58	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.038  Semanera 151225.xls	trans_1791914585_f9d60ef4_ORDEN_DE_PROD.No.038__Semanera_151225.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:07:41.53123	2026-10-14 14:07:41.53123	DESCARGADO	189.195.177.20	f	127.0.0.1	t
59	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.039 REGION 3ER ZONA MILITAR MAZATLAN.xlsx	trans_1791914585_eb2d1161_ORDEN_DE_PROD.No.039_REGION_3ER_ZONA_MILITAR_MAZATLAN.xlsx	84273	82.3 KB	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:07:45.563492	2026-10-14 14:07:45.563492	DESCARGADO	189.195.177.20	f	127.0.0.1	t
70	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.124 Grabacion Testimonios LEY Aniv.72 dia 03-julio-26.xls	trans_1791914705_070ce62b_ORDEN_DE_PROD.No.124_Grabacion_Testimonios_LEY_Aniv.72_dia_03-julio-26.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:58:14.0342	2026-10-14 13:58:14.0342	DESCARGADO	189.195.177.20	f	127.0.0.1	t
103	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.144 Cobertura 72 ANIVERSARIO LEY    28-agosto-26.xls	trans_1791914705_ed59bee3_ORDEN_DE_PROD.No.144_Cobertura_72_ANIVERSARIO_LEY____28-agosto-26.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:56:37.929145	2026-10-14 13:56:37.929145	DESCARGADO	189.195.177.20	f	127.0.0.1	t
100	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.036  MAJA- Live Streaming Sorteo Anual 14-ene-26.xls	trans_1791914705_3a806e38_ORDEN_DE_PROD.No.036__MAJA-_Live_Streaming_Sorteo_Anual_14-ene-26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:56:59.081096	2026-10-14 13:56:59.081096	DESCARGADO	189.195.177.20	f	127.0.0.1	t
21	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD. No.001-Hangar.xls	trans_1791914585_76c33721_ORDEN_DE_PROD._No.001-Hangar.xls	59904	58.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:01:23.379099	2026-10-14 14:01:23.379099	DESCARGADO	189.195.177.20	f	127.0.0.1	t
23	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.003- 1er. Informe sheinbaum.xls	trans_1791914585_6be4f9e0_ORDEN_DE_PROD.No.003-_1er._Informe_sheinbaum.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:01:47.074417	2026-10-14 14:01:47.074417	DESCARGADO	189.195.177.20	f	127.0.0.1	t
26	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.006 Cuadrangular del Bienestar-Culiacán.xls	trans_1791914585_3b1471da_ORDEN_DE_PROD.No.006_Cuadrangular_del_Bienestar-Culiac_n.xls	60928	59.5 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:02:06.891166	2026-10-14 14:02:06.891166	DESCARGADO	189.195.177.20	f	127.0.0.1	t
62	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.115 ELEVOX -Museo Centenario 03 Y 04-junio.xls	trans_1791914705_baa8b72b_ORDEN_DE_PROD.No.115_ELEVOX_-Museo_Centenario_03_Y_04-junio.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:57:26.930163	2026-10-14 13:57:26.930163	DESCARGADO	189.195.177.20	f	127.0.0.1	t
63	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.116 Streaming y dist.de señal Mundial 11jun26.xls	trans_1791914705_eb6b5cb2_ORDEN_DE_PROD.No.116_Streaming_y_dist.de_se_al_Mundial_11jun26.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:57:33.868664	2026-10-14 13:57:33.868664	DESCARGADO	189.195.177.20	f	127.0.0.1	t
64	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.117 reprod.de material a pantallas Villa union 19jun26.xls	trans_1791914705_4e8bc10d_ORDEN_DE_PROD.No.117_reprod.de_material_a_pantallas_Villa_union_19jun26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:57:40.321442	2026-10-14 13:57:40.321442	DESCARGADO	189.195.177.20	f	127.0.0.1	t
65	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.118 Streaming a 3camaras salon gobernadores 23jun26.xls	trans_1791914705_39bc63eb_ORDEN_DE_PROD.No.118_Streaming_a_3camaras_salon_gobernadores_23jun26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:57:45.482075	2026-10-14 13:57:45.482075	DESCARGADO	189.195.177.20	f	127.0.0.1	t
71	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.125 Grabacion Testimonios LEY Aniv.72 dia 07-julio-26.xls	trans_1791914705_c7ffe6b7_ORDEN_DE_PROD.No.125_Grabacion_Testimonios_LEY_Aniv.72_dia_07-julio-26.xls	57856	56.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:58:19.760891	2026-10-14 13:58:19.760891	DESCARGADO	189.195.177.20	f	127.0.0.1	t
72	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.126 Grabacion Testimonios LEY Aniv.72 dia 08-julio-26.xls	trans_1791914705_6d44759f_ORDEN_DE_PROD.No.126_Grabacion_Testimonios_LEY_Aniv.72_dia_08-julio-26.xls	58880	57.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:58:25.04132	2026-10-14 13:58:25.04132	DESCARGADO	189.195.177.20	f	127.0.0.1	t
73	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.123 Grabacion Testimonios LEY Aniv.72 dia 02-julio-26.xls	trans_1791914705_30638d90_ORDEN_DE_PROD.No.123_Grabacion_Testimonios_LEY_Aniv.72_dia_02-julio-26.xls	57856	56.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:58:30.377968	2026-10-14 13:58:30.377968	DESCARGADO	189.195.177.20	f	127.0.0.1	t
74	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.127 IEES Sesión Virtual en estudio 09-julio-26.xls	trans_1791914705_8a10bf28_ORDEN_DE_PROD.No.127_IEES_Sesi_n_Virtual_en_estudio_09-julio-26.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:58:35.936875	2026-10-14 13:58:35.936875	DESCARGADO	189.195.177.20	f	127.0.0.1	t
75	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.128 Proveeduria internet a 10 modulos y cableado a stand Lazaro Cardenas.xls	trans_1791914705_69bcc960_ORDEN_DE_PROD.No.128_Proveeduria_internet_a_10_modulos_y_cableado_a_stand_Lazaro_Cardenas.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:58:41.578383	2026-10-14 13:58:41.578383	DESCARGADO	189.195.177.20	f	127.0.0.1	t
76	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.130 Grabacion JUAN MANUEL LEY  Aniv.72 LEY dia 23-julio-26.xls	trans_1791914705_a3a1221c_ORDEN_DE_PROD.No.130_Grabacion_JUAN_MANUEL_LEY__Aniv.72_LEY_dia_23-julio-26.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:58:46.786172	2026-10-14 13:58:46.786172	DESCARGADO	189.195.177.20	f	127.0.0.1	t
77	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.129 IEES Sesión Virtual en estudio 16-julio-26.xls	trans_1791914705_5e4fe756_ORDEN_DE_PROD.No.129_IEES_Sesi_n_Virtual_en_estudio_16-julio-26.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:59:04.73934	2026-10-14 13:59:04.73934	DESCARGADO	189.195.177.20	f	127.0.0.1	t
78	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.132 COPPEL torre premier Jurídico 21-julio-26.xls	trans_1791914705_4c27b835_ORDEN_DE_PROD.No.132_COPPEL_torre_premier_Jur_dico_21-julio-26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:59:09.858974	2026-10-14 13:59:09.858974	DESCARGADO	189.195.177.20	f	127.0.0.1	t
79	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.133  Grabaciones DEL CAMPO  en Aguascalientes dias 21 y 22-julio-26.xls	trans_1791914705_46d33471_ORDEN_DE_PROD.No.133__Grabaciones_DEL_CAMPO__en_Aguascalientes_dias_21_y_22-julio-26.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:59:18.226039	2026-10-14 13:59:18.226039	DESCARGADO	189.195.177.20	f	127.0.0.1	t
80	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.134 Proveeduria internet a 10 modulos y cableado a stand, dias 22,23 y 24julio en Vista Hermosa.xls	trans_1791914705_f87c4a32_ORDEN_DE_PROD.No.134_Proveeduria_internet_a_10_modulos_y_cableado_a_stand__dias_22_23_y_24julio_en_Vista_Hermosa.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:59:23.313985	2026-10-14 13:59:23.313985	DESCARGADO	189.195.177.20	f	127.0.0.1	t
81	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.163 ENLACE PRESICENCIAL-en Secret. Seg. Punlica 12-oct-26.xls	trans_1791914705_38396c33_ORDEN_DE_PROD.No.163_ENLACE_PRESICENCIAL-en_Secret._Seg._Punlica_12-oct-26.xls	57344	56.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:59:28.434338	2026-10-14 13:59:28.434338	DESCARGADO	189.195.177.20	f	127.0.0.1	t
82	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No162 Ayuntam. Escuinapa  09-oct-26.xls	trans_1791914705_338c4b8c_ORDEN_DE_PROD.No162_Ayuntam._Escuinapa__09-oct-26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:59:33.713685	2026-10-14 13:59:33.713685	DESCARGADO	189.195.177.20	f	127.0.0.1	t
83	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No161 Reunion ADECEM en Casa Bon  06-oct-26.xls	trans_1791914705_1b853893_ORDEN_DE_PROD.No161_Reunion_ADECEM_en_Casa_Bon__06-oct-26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:59:39.082768	2026-10-14 13:59:39.082768	DESCARGADO	189.195.177.20	f	127.0.0.1	t
84	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No160 DIF Estatal inaguracion de area de cedrtificacion 05-oct-26.xls	trans_1791914705_c61c7413_ORDEN_DE_PROD.No160_DIF_Estatal_inaguracion_de_area_de_cedrtificacion_05-oct-26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:59:44.018454	2026-10-14 13:59:44.018454	DESCARGADO	189.195.177.20	f	127.0.0.1	t
85	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No159 Proveeduria internet a 10 modulos y cableado a stand, dias 30 sept. 01 y 02 octubre 2026 Campo Aguaruto.xls	trans_1791914705_1fd70f63_ORDEN_DE_PROD.No159_Proveeduria_internet_a_10_modulos_y_cableado_a_stand__dias_30_sept._01_y_02_octubre_2026_Campo_Aguaruto.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:59:49.849927	2026-10-14 13:59:49.849927	DESCARGADO	189.195.177.20	f	127.0.0.1	t
86	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No158 SESION EXTRAORD. Y ESPECIAL  VIRTUAL IEES- ESTUDIO 30-sept-26.xls	trans_1791914705_3d90a7f1_ORDEN_DE_PROD.No158_SESION_EXTRAORD._Y_ESPECIAL__VIRTUAL_IEES-_ESTUDIO_30-sept-26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:59:54.874033	2026-10-14 13:59:54.874033	DESCARGADO	189.195.177.20	f	127.0.0.1	t
87	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No157 VISITA PRESIDENCIAL  Feria ganadera monitores y switcher   20-sep-26.xls	trans_1791914705_46812390_ORDEN_DE_PROD.No157_VISITA_PRESIDENCIAL__Feria_ganadera_monitores_y_switcher___20-sep-26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:59:59.801328	2026-10-14 13:59:59.801328	DESCARGADO	189.195.177.20	f	127.0.0.1	t
102	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.131 CONGRESO CESAVESIN- MAZATLAN 20, 21 y 22 AGOSTO-26.xls	trans_1791914705_7202041e_ORDEN_DE_PROD.No.131_CONGRESO_CESAVESIN-_MAZATLAN_20__21_y_22_AGOSTO-26.xls	64000	62.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:56:42.769579	2026-10-14 13:56:42.769579	DESCARGADO	189.195.177.20	f	127.0.0.1	t
101	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.141 SESION EXTRAORD. Y ESPECIAL  VIRTUAL IEES- ESTUDIO 25-agosto-26.xls	trans_1791914705_cd29159d_ORDEN_DE_PROD.No.141_SESION_EXTRAORD._Y_ESPECIAL__VIRTUAL_IEES-_ESTUDIO_25-agosto-26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:56:53.72921	2026-10-14 13:56:53.72921	DESCARGADO	189.195.177.20	f	127.0.0.1	t
106	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No142 Proveeduria internet a 10 modulos y cableado a stand, dias 19,20 y21 Agosto Costa Rica.xls	trans_1791914705_fa074c2f_ORDEN_DE_PROD.No142_Proveeduria_internet_a_10_modulos_y_cableado_a_stand__dias_19_20_y21_Agosto_Costa_Rica.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:56:21.704822	2026-10-14 13:56:21.704822	DESCARGADO	189.195.177.20	f	127.0.0.1	t
105	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.143 ENLACE PRESICENCIAL-despacho gobernador   21-agosto-26.xls	trans_1791914705_dadd4a2c_ORDEN_DE_PROD.No.143_ENLACE_PRESICENCIAL-despacho_gobernador___21-agosto-26.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:56:26.617414	2026-10-14 13:56:26.617414	DESCARGADO	189.195.177.20	f	127.0.0.1	t
104	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.102  Semanera Auditorio 22abril26.xls	trans_1791914705_17dfa625_ORDEN_DE_PROD.No.102__Semanera_Auditorio_22abril26.xls	56320	55.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:56:32.521453	2026-10-14 13:56:32.521453	DESCARGADO	189.195.177.20	f	127.0.0.1	t
98	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.151 Ayutam. badiraguato-TEBACAS Play Inn 21-oct.2026.xls	trans_1791914705_9ee60ec3_ORDEN_DE_PROD.No.151_Ayutam._badiraguato-TEBACAS_Play_Inn_21-oct.2026.xls	58368	57.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:57:09.097449	2026-10-14 13:57:09.097449	DESCARGADO	189.195.177.20	f	127.0.0.1	t
60	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.113 IEES Sesión Virtual en estudio 04-junio.xls	trans_1791914705_8fc9939f_ORDEN_DE_PROD.No.113_IEES_Sesi_n_Virtual_en_estudio_04-junio.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:57:14.866405	2026-10-14 13:57:14.866405	DESCARGADO	189.195.177.20	f	127.0.0.1	t
66	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.119 Proveeduria internet a 10 modulas con fibra Alturas del Sur.xls	trans_1791914705_baeb139b_ORDEN_DE_PROD.No.119_Proveeduria_internet_a_10_modulas_con_fibra_Alturas_del_Sur.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:57:50.99493	2026-10-14 13:57:50.99493	DESCARGADO	189.195.177.20	f	127.0.0.1	t
89	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No155 FESTEJOS PATRIOS 15 SEPT. 2026 PALACIO.xls	trans_1791914705_3f2d36cd_ORDEN_DE_PROD.No155_FESTEJOS_PATRIOS_15_SEPT._2026_PALACIO.xls	56320	55.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 14:00:17.761793	2026-10-14 14:00:17.761793	DESCARGADO	189.195.177.20	f	127.0.0.1	t
91	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No153 Grabaciones JAPAC 07-sep-26.xls	trans_1791914705_ab01ca1c_ORDEN_DE_PROD.No153_Grabaciones_JAPAC_07-sep-26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 14:00:29.954084	2026-10-14 14:00:29.954084	DESCARGADO	189.195.177.20	f	127.0.0.1	t
92	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No152  monitores Salon gobernadores Reunion privada domingo 06-sep-26.xls	trans_1791914705_07b6fbd7_ORDEN_DE_PROD.No152__monitores_Salon_gobernadores_Reunion_privada_domingo_06-sep-26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 14:00:35.689533	2026-10-14 14:00:35.689533	DESCARGADO	189.195.177.20	f	127.0.0.1	t
93	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.148 Ayutam. badiraguato-TEBACAS 03-oct.2026.xls	trans_1791914705_8d15bfcd_ORDEN_DE_PROD.No.148_Ayutam._badiraguato-TEBACAS_03-oct.2026.xls	58368	57.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 14:00:40.618392	2026-10-14 14:00:40.618392	DESCARGADO	189.195.177.20	f	127.0.0.1	t
94	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.146 Ayutam. badiraguato- Culiacán 04,05 y 06 sept.2026.xls	trans_1791914705_d14ee140_ORDEN_DE_PROD.No.146_Ayutam._badiraguato-_Culiac_n_04_05_y_06_sept.2026.xls	58880	57.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 14:00:45.970072	2026-10-14 14:00:45.970072	DESCARGADO	189.195.177.20	f	127.0.0.1	t
95	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.147 Ayutam. badiraguato- Culiacán 27 sept.2026.xls	trans_1791914705_c9a4a46e_ORDEN_DE_PROD.No.147_Ayutam._badiraguato-_Culiac_n_27_sept.2026.xls	58368	57.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 14:00:53.234042	2026-10-14 14:00:53.234042	DESCARGADO	189.195.177.20	f	127.0.0.1	t
96	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.149 Ayutam. badiraguato-TEBACAS 10-oct.2026.xls	trans_1791914705_a8d34c66_ORDEN_DE_PROD.No.149_Ayutam._badiraguato-TEBACAS_10-oct.2026.xls	58368	57.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	2	2026-10-13 14:00:58.257303	2026-10-14 14:00:58.257303	DESCARGADO	189.195.177.20	f	127.0.0.1	t
97	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.150 Ayutam. badiraguato-TEBACAS 16-oct.2026.xls	trans_1791914705_c18bb785_ORDEN_DE_PROD.No.150_Ayutam._badiraguato-TEBACAS_16-oct.2026.xls	58368	57.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 14:01:17.770334	2026-10-14 14:01:17.770334	DESCARGADO	189.195.177.20	f	127.0.0.1	t
68	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.121 Tripies para Monitores El SAUZ militar.xls	trans_1791914705_aaea52bc_ORDEN_DE_PROD.No.121_Tripies_para_Monitores_El_SAUZ_militar.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:58:02.121941	2026-10-14 13:58:02.121941	DESCARGADO	189.195.177.20	f	127.0.0.1	t
127	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.060 CIBACOPA- Guasave 24 y 25 feb.xls	trans_1791914705_8e8c9aaa_ORDEN_DE_PROD.No.060_CIBACOPA-_Guasave_24_y_25_feb.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:53:54.473704	2026-10-14 13:53:54.473704	DESCARGADO	189.195.177.20	f	127.0.0.1	t
126	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.059 CIBACOPA- Culiacán 21 y 22 feb.xls	trans_1791914705_4c6d510c_ORDEN_DE_PROD.No.059_CIBACOPA-_Culiac_n_21_y_22_feb.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:54:05.097135	2026-10-14 13:54:05.097135	DESCARGADO	189.195.177.20	f	127.0.0.1	t
125	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.058 HANGAR #10 Aniv.Fuerza Aerea Mexicana.xls	trans_1791914705_b650d43a_ORDEN_DE_PROD.No.058_HANGAR__10_Aniv.Fuerza_Aerea_Mexicana.xls	56320	55.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:54:13.737778	2026-10-14 13:54:13.737778	DESCARGADO	189.195.177.20	f	127.0.0.1	t
124	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.057 SUMINISTRO INTERNET GIRAS Blv.dAgricultores.xls	trans_1791914705_0ce5d42f_ORDEN_DE_PROD.No.057_SUMINISTRO_INTERNET_GIRAS_Blv.dAgricultores.xls	60416	59.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:54:22.45768	2026-10-14 13:54:22.45768	DESCARGADO	189.195.177.20	f	127.0.0.1	t
123	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.048 SIST.AUDIO Y MIROFONIA COPPEL 290126.xls	trans_1791914705_6b7261a7_ORDEN_DE_PROD.No.048_SIST.AUDIO_Y_MIROFONIA_COPPEL_290126.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:54:27.675314	2026-10-14 13:54:27.675314	DESCARGADO	189.195.177.20	f	127.0.0.1	t
122	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.056 CONF.COPPEL, CHIHUAHUA,CH. 11 y 12  MARZO.xls	trans_1791914705_99824d82_ORDEN_DE_PROD.No.056_CONF.COPPEL__CHIHUAHUA_CH._11_y_12__MARZO.xls	56320	55.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:54:34.080476	2026-10-14 13:54:34.080476	DESCARGADO	189.195.177.20	f	127.0.0.1	t
121	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.047 Entrega Titulos Propiedad, Sinaloa de Leyva.190126.xls	trans_1791914705_88d56a81_ORDEN_DE_PROD.No.047_Entrega_Titulos_Propiedad__Sinaloa_de_Leyva.190126.xls	60928	59.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:54:39.970145	2026-10-14 13:54:39.970145	DESCARGADO	189.195.177.20	f	127.0.0.1	t
120	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.046  Semanera 190126 Guasave, Sin..xls	trans_1791914705_d00d2eb5_ORDEN_DE_PROD.No.046__Semanera_190126_Guasave__Sin..xls	60928	59.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:54:48.493103	2026-10-14 13:54:48.493103	DESCARGADO	189.195.177.20	f	127.0.0.1	t
119	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.045  Semanera 120126 Auditorio.xls	trans_1791914705_d844be58_ORDEN_DE_PROD.No.045__Semanera_120126_Auditorio.xls	57856	56.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:54:54.121673	2026-10-14 13:54:54.121673	DESCARGADO	189.195.177.20	f	127.0.0.1	t
118	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.044 SESION VIRTUAL IEES- STUDIO 14ene-25.xls	trans_1791914705_612edd30_ORDEN_DE_PROD.No.044_SESION_VIRTUAL_IEES-_STUDIO_14ene-25.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:55:00.265865	2026-10-14 13:55:00.265865	DESCARGADO	189.195.177.20	f	127.0.0.1	t
117	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.043 GRABACIONES MAJA 14ene-25.xls	trans_1791914705_0eae72c9_ORDEN_DE_PROD.No.043_GRABACIONES_MAJA_14ene-25.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:55:08.243058	2026-10-14 13:55:08.243058	DESCARGADO	189.195.177.20	f	127.0.0.1	t
116	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.042 FAST STAR 2026 COCA COLA ENLACE CULIACAN.xls	trans_1791914705_f40c0707_ORDEN_DE_PROD.No.042_FAST_STAR_2026_COCA_COLA_ENLACE_CULIACAN.xls	56320	55.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:55:15.370006	2026-10-14 13:55:15.370006	DESCARGADO	189.195.177.20	f	127.0.0.1	t
115	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.041 FAST STAR 2026 COCA COLA MAZATLAN.xls	trans_1791914705_65beae7c_ORDEN_DE_PROD.No.041_FAST_STAR_2026_COCA_COLA_MAZATLAN.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:55:20.690702	2026-10-14 13:55:20.690702	DESCARGADO	189.195.177.20	f	127.0.0.1	t
114	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.040  Semanera 050126 Mochis.xls	trans_1791914705_d22d89d7_ORDEN_DE_PROD.No.040__Semanera_050126_Mochis.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:55:29.049134	2026-10-14 13:55:29.049134	DESCARGADO	189.195.177.20	f	127.0.0.1	t
113	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.135 Grabaciones en Estudio COCACOLA 29julio26.xls	trans_1791914705_50d6bff1_ORDEN_DE_PROD.No.135_Grabaciones_en_Estudio_COCACOLA_29julio26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:55:34.696923	2026-10-14 13:55:34.696923	DESCARGADO	189.195.177.20	f	127.0.0.1	t
111	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.139 ENLACE PRESIDENCIAL DESDE  BORABAMPO,Ahome    06-agosto-26.xls	trans_1791914705_8119607f_ORDEN_DE_PROD.No.139_ENLACE_PRESIDENCIAL_DESDE__BORABAMPO_Ahome____06-agosto-26.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:55:49.44332	2026-10-14 13:55:49.44332	DESCARGADO	189.195.177.20	f	127.0.0.1	t
110	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.140 Proveeduria internet a 10 modulos y cableado a stand, dias 05,06 y07 Agosto26 El Ranchito.xls	trans_1791914705_e91ad5bf_ORDEN_DE_PROD.No.140_Proveeduria_internet_a_10_modulos_y_cableado_a_stand__dias_05_06_y07_Agosto26_El_Ranchito.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:55:54.769502	2026-10-14 13:55:54.769502	DESCARGADO	189.195.177.20	f	127.0.0.1	t
109	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.138 EL CARRIZO  09-agosto-26.xls	trans_1791914705_3e037472_ORDEN_DE_PROD.No.138_EL_CARRIZO__09-agosto-26.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:56:00.338323	2026-10-14 13:56:00.338323	DESCARGADO	189.195.177.20	f	127.0.0.1	t
108	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.136 ENLACE PRESICENCIA  en AARC Y  04-agosto-26.xls	trans_1791914705_c704fa94_ORDEN_DE_PROD.No.136_ENLACE_PRESICENCIA__en_AARC_Y__04-agosto-26.xls	57344	56.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:56:07.378115	2026-10-14 13:56:07.378115	DESCARGADO	189.195.177.20	f	127.0.0.1	t
24	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.004- Semanera.xls	trans_1791914585_3a9938a8_ORDEN_DE_PROD.No.004-_Semanera.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	1	2026-10-13 14:01:53.761824	2026-10-14 14:01:53.761824	DESCARGADO	189.195.177.20	f	127.0.0.1	t
148	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.051 CONF.COPPEL AGUASCALIENTES,03,04 Y 05 MARZO.xls	trans_1791914705_2b5f1e2b_ORDEN_DE_PROD.No.051_CONF.COPPEL_AGUASCALIENTES_03_04_Y_05_MARZO.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:42:54.096536	2026-10-14 13:42:54.096536	DESCARGADO	189.195.177.20	f	127.0.0.1	t
147	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.082 VISITA presidenta -Culiacán.xls	trans_1791914705_57a767ef_ORDEN_DE_PROD.No.082_VISITA_presidenta_-Culiac_n.xls	57344	56.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:42:59.601326	2026-10-14 13:42:59.601326	DESCARGADO	189.195.177.20	f	127.0.0.1	t
146	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.074- 4to..informe DIF ESTATAL explanada palacio gob..xls	trans_1791914705_dd3da026_ORDEN_DE_PROD.No.074-_4to..informe_DIF_ESTATAL_explanada_palacio_gob..xls	57344	56.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:43:04.656717	2026-10-14 13:43:04.656717	DESCARGADO	189.195.177.20	f	127.0.0.1	t
145	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.081 VISITA presidenta -Mazatlán.xls	trans_1791914705_bc8fd1b7_ORDEN_DE_PROD.No.081_VISITA_presidenta_-Mazatl_n.xls	58368	57.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:43:09.833648	2026-10-14 13:43:09.833648	DESCARGADO	189.195.177.20	f	127.0.0.1	t
144	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.055 CONF.COPPEL, MEXICALI,BCN 11 y 12  MARZO.xls	trans_1791914705_00231240_ORDEN_DE_PROD.No.055_CONF.COPPEL__MEXICALI_BCN_11_y_12__MARZO.xls	56320	55.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:43:15.096892	2026-10-14 13:43:15.096892	DESCARGADO	189.195.177.20	f	127.0.0.1	t
143	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.054 CONF.COPPEL DURANGO, DGO. 10,11 y 12  MARZO.xls	trans_1791914705_1ad5d647_ORDEN_DE_PROD.No.054_CONF.COPPEL_DURANGO__DGO._10_11_y_12__MARZO.xls	56320	55.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:43:20.272819	2026-10-14 13:43:20.272819	DESCARGADO	189.195.177.20	f	127.0.0.1	t
142	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.053 CONF.COPPEL MANZANILLO,COLIMA 10,11 y 12  MARZO.xls	trans_1791914705_f831ab3b_ORDEN_DE_PROD.No.053_CONF.COPPEL_MANZANILLO_COLIMA_10_11_y_12__MARZO.xls	56320	55.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:43:25.392909	2026-10-14 13:43:25.392909	DESCARGADO	189.195.177.20	f	127.0.0.1	t
141	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.050 CONF.COPPEL MAZATLAN,SIN 24,25,26 FEB.xls	trans_1791914705_9123b39a_ORDEN_DE_PROD.No.050_CONF.COPPEL_MAZATLAN_SIN_24_25_26_FEB.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:43:30.576061	2026-10-14 13:43:30.576061	DESCARGADO	189.195.177.20	f	127.0.0.1	t
140	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.052 CONF.COPPEL  SAN CARLOS, SON.,03,04 Y 05 MARZO.xls	trans_1791914705_8fe95ea1_ORDEN_DE_PROD.No.052_CONF.COPPEL__SAN_CARLOS__SON._03_04_Y_05_MARZO.xls	56320	55.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:43:35.664535	2026-10-14 13:43:35.664535	DESCARGADO	189.195.177.20	f	127.0.0.1	t
139	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.049 CONF.COPPEL MANZANILLO COLIMA 24,25,26 FEB.xls	trans_1791914705_0197395f_ORDEN_DE_PROD.No.049_CONF.COPPEL_MANZANILLO_COLIMA_24_25_26_FEB.xls	58368	57.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:43:40.65694	2026-10-14 13:43:40.65694	DESCARGADO	189.195.177.20	f	127.0.0.1	t
138	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.080 Día de la Bandera-Giras240226.xls	trans_1791914705_991d3dcb_ORDEN_DE_PROD.No.080_D_a_de_la_Bandera-Giras240226.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:43:45.929186	2026-10-14 13:43:45.929186	DESCARGADO	189.195.177.20	f	127.0.0.1	t
137	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.078  Semanera Auditorio 230226.xls	trans_1791914705_d44a5feb_ORDEN_DE_PROD.No.078__Semanera_Auditorio_230226.xls	60928	59.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:43:51.152205	2026-10-14 13:43:51.152205	DESCARGADO	189.195.177.20	f	127.0.0.1	t
136	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.079 CONF.COPPEL MANZANILLO COLIMA 22,23,y 24 Abril.xls	trans_1791914705_f2de92e7_ORDEN_DE_PROD.No.079_CONF.COPPEL_MANZANILLO_COLIMA_22_23_y_24_Abril.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:43:56.176768	2026-10-14 13:43:56.176768	DESCARGADO	189.195.177.20	f	127.0.0.1	t
135	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.076 Eti 101 Valle Alto-Giras170226.xls	trans_1791914705_6390dbc4_ORDEN_DE_PROD.No.076_Eti_101_Valle_Alto-Giras170226.xls	60416	59.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:44:01.048088	2026-10-14 13:44:01.048088	DESCARGADO	189.195.177.20	f	127.0.0.1	t
134	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.077 Día del ejercito Mexicano-Giras190226.xls	trans_1791914705_8db64df9_ORDEN_DE_PROD.No.077_D_a_del_ejercito_Mexicano-Giras190226.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:44:06.312487	2026-10-14 13:44:06.312487	DESCARGADO	189.195.177.20	f	127.0.0.1	t
133	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.073 CIBACOPA- Culiacán 16 y 17 mayo.xls	trans_1791914705_b1623259_ORDEN_DE_PROD.No.073_CIBACOPA-_Culiac_n_16_y_17_mayo.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:44:11.544733	2026-10-14 13:44:11.544733	DESCARGADO	189.195.177.20	f	127.0.0.1	t
132	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.072 CIBACOPA- Mazatlan 12 y 13 mayo.xls	trans_1791914705_7864dcb2_ORDEN_DE_PROD.No.072_CIBACOPA-_Mazatlan_12_y_13_mayo.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:44:17.000329	2026-10-14 13:44:17.000329	DESCARGADO	189.195.177.20	f	127.0.0.1	t
131	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.071 CIBACOPA- Culiacán 05 y 06 mayo.xls	trans_1791914705_491510d8_ORDEN_DE_PROD.No.071_CIBACOPA-_Culiac_n_05_y_06_mayo.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:44:25.096945	2026-10-14 13:44:25.096945	DESCARGADO	189.195.177.20	f	127.0.0.1	t
130	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.070 CIBACOPA- Guasave 01 y 02 Mayo.xls	trans_1791914705_44d0462c_ORDEN_DE_PROD.No.070_CIBACOPA-_Guasave_01_y_02_Mayo.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:50:04.908489	2026-10-14 13:50:04.908489	DESCARGADO	189.195.177.20	f	127.0.0.1	t
129	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.068 CIBACOPA- Culiacán 21 y 22 abril.xls	trans_1791914705_15f63056_ORDEN_DE_PROD.No.068_CIBACOPA-_Culiac_n_21_y_22_abril.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:53:30.770141	2026-10-14 13:53:30.770141	DESCARGADO	189.195.177.20	f	127.0.0.1	t
69	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.122 ENLACE PRESICENCIA Y VIVIENDAS BIENESTAR EN MOCHIS 01-julio-26.xls	trans_1791914705_c0172efe_ORDEN_DE_PROD.No.122_ENLACE_PRESICENCIA_Y_VIVIENDAS_BIENESTAR_EN_MOCHIS_01-julio-26.xls	57856	56.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:58:07.321727	2026-10-14 13:58:07.321727	DESCARGADO	189.195.177.20	f	127.0.0.1	t
170	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.066 CIBACOPA- Guasave 07 y 08 abril.xls	trans_1791914705_53fba7eb_ORDEN_DE_PROD.No.066_CIBACOPA-_Guasave_07_y_08_abril.xls	57344	56.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:40:53.977823	2026-10-14 13:40:53.977823	DESCARGADO	189.195.177.20	f	127.0.0.1	t
169	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.091 Enlace Presidenta mañanaera del pueblo desde Mochis 250326.xls	trans_1791914705_9a638292_ORDEN_DE_PROD.No.091_Enlace_Presidenta_ma_anaera_del_pueblo_desde_Mochis_250326.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:40:58.920033	2026-10-14 13:40:58.920033	DESCARGADO	189.195.177.20	f	127.0.0.1	t
168	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.092 presentacion PROGRAMA VIVIENDA BIENESTAR en Los mochis 250326.xls	trans_1791914705_b96b423b_ORDEN_DE_PROD.No.092_presentacion_PROGRAMA_VIVIENDA_BIENESTAR_en_Los_mochis_250326.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:41:03.968298	2026-10-14 13:41:03.968298	DESCARGADO	189.195.177.20	f	127.0.0.1	t
167	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.096  Semanera Auditorio 060426.xls	trans_1791914705_fc6d2d45_ORDEN_DE_PROD.No.096__Semanera_Auditorio_060426.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:41:09.337022	2026-10-14 13:41:09.337022	DESCARGADO	189.195.177.20	f	127.0.0.1	t
166	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.095  Semanera Auditorio 300326.xls	trans_1791914705_819a4cde_ORDEN_DE_PROD.No.095__Semanera_Auditorio_300326.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:41:14.712114	2026-10-14 13:41:14.712114	DESCARGADO	189.195.177.20	f	127.0.0.1	t
165	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.094 Entrega de titulos de propiedad El Dorado 280326.xls	trans_1791914705_77f6a9ed_ORDEN_DE_PROD.No.094_Entrega_de_titulos_de_propiedad_El_Dorado_280326.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:41:20.088207	2026-10-14 13:41:20.088207	DESCARGADO	189.195.177.20	f	127.0.0.1	t
164	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.065 CIBACOPA- Guasave 27 y 28 marzo.xls	trans_1791914705_00226c4a_ORDEN_DE_PROD.No.065_CIBACOPA-_Guasave_27_y_28_marzo.xls	57344	56.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:41:25.48812	2026-10-14 13:41:25.48812	DESCARGADO	189.195.177.20	f	127.0.0.1	t
163	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.093 banderazo de inicio SEMANA SANTA en PLAYAS BELLAVISTA, GUASAVE 270326.xls	trans_1791914705_824d5371_ORDEN_DE_PROD.No.093_banderazo_de_inicio_SEMANA_SANTA_en_PLAYAS_BELLAVISTA__GUASAVE_270326.xls	54784	53.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:41:30.679924	2026-10-14 13:41:30.679924	DESCARGADO	189.195.177.20	f	127.0.0.1	t
162	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.069 CIBACOPA- Mazatlan 28 y 29 abril.xls	trans_1791914705_fc718840_ORDEN_DE_PROD.No.069_CIBACOPA-_Mazatlan_28_y_29_abril.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:41:35.744765	2026-10-14 13:41:35.744765	DESCARGADO	189.195.177.20	f	127.0.0.1	t
161	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.090  Semanera Auditorio 230326.xls	trans_1791914705_5ce8cc8c_ORDEN_DE_PROD.No.090__Semanera_Auditorio_230326.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:41:41.616903	2026-10-14 13:41:41.616903	DESCARGADO	189.195.177.20	f	127.0.0.1	t
160	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.064 CIBACOPA- Culiacán 21 y 22 marzo.xls	trans_1791914705_2f101fc4_ORDEN_DE_PROD.No.064_CIBACOPA-_Culiac_n_21_y_22_marzo.xls	57344	56.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:41:47.29616	2026-10-14 13:41:47.29616	DESCARGADO	189.195.177.20	f	127.0.0.1	t
159	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.089 GRUPO FGL TRADE .CONFERENCIA  REST. CAYENA.xls	trans_1791914705_8631e355_ORDEN_DE_PROD.No.089_GRUPO_FGL_TRADE_.CONFERENCIA__REST._CAYENA.xls	60416	59.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:41:52.328058	2026-10-14 13:41:52.328058	DESCARGADO	189.195.177.20	f	127.0.0.1	t
158	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.088 GRUPO PARLAM. MORENA HOTEL SAN MARCOS.xls	trans_1791914705_f2e46b35_ORDEN_DE_PROD.No.088_GRUPO_PARLAM._MORENA_HOTEL_SAN_MARCOS.xls	60416	59.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:41:57.504933	2026-10-14 13:41:57.504933	DESCARGADO	189.195.177.20	f	127.0.0.1	t
157	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.087 INAUGURACION FACULTAD MEDICINA EN GUASAVE.xls	trans_1791914705_ef61380b_ORDEN_DE_PROD.No.087_INAUGURACION_FACULTAD_MEDICINA_EN_GUASAVE.xls	60928	59.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:42:02.784396	2026-10-14 13:42:02.784396	DESCARGADO	189.195.177.20	f	127.0.0.1	t
156	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.086  Semanera en USE 170326.xls	trans_1791914705_bf2889cc_ORDEN_DE_PROD.No.086__Semanera_en_USE_170326.xls	60928	59.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:42:11.168207	2026-10-14 13:42:11.168207	DESCARGADO	189.195.177.20	f	127.0.0.1	t
154	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.063 CIBACOPA- Culiacán 04 y 05 abril semana santa.xls	trans_1791914705_35b5c134_ORDEN_DE_PROD.No.063_CIBACOPA-_Culiac_n_04_y_05_abril_semana_santa.xls	59392	58.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:42:22.553496	2026-10-14 13:42:22.553496	DESCARGADO	189.195.177.20	f	127.0.0.1	t
153	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.062 CIBACOPA- Culiacán 06 y 07 marzo.xls	trans_1791914705_a050baf7_ORDEN_DE_PROD.No.062_CIBACOPA-_Culiac_n_06_y_07_marzo.xls	57344	56.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:42:27.408448	2026-10-14 13:42:27.408448	DESCARGADO	189.195.177.20	f	127.0.0.1	t
152	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.061 CIBACOPA- Culiacán 28feb y 01 marzo.xls	trans_1791914705_daa59eb2_ORDEN_DE_PROD.No.061_CIBACOPA-_Culiac_n_28feb_y_01_marzo.xls	62464	61.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:42:33.017046	2026-10-14 13:42:33.017046	DESCARGADO	189.195.177.20	f	127.0.0.1	t
151	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.084- IEES Sesion Extraord. y especial -virtual 11-marzo26.xls	trans_1791914705_81c7760a_ORDEN_DE_PROD.No.084-_IEES_Sesion_Extraord._y_especial_-virtual_11-marzo26.xls	56320	55.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:42:38.616473	2026-10-14 13:42:38.616473	DESCARGADO	189.195.177.20	f	127.0.0.1	t
186	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ODS_no. 973 ELEVOX 22abril-26.xls	trans_1791917012_df1e462b_ODS_no._973_ELEVOX_22abril-26.xls	57856	56.5 KB	application/vnd.ms-excel	Este archivo es para enlazarlo en un apartado de ordenes de servicio de proveedores, donde detallo el costo de su servicio, para emlazarlo al hisorico de adeudo	TRF-1791917012-878FEA	2026-10-13 12:43:32.916616	t	1	2026-10-13 13:38:40.651002	2026-10-14 13:38:40.651002	DESCARGADO	189.195.177.20	f	127.0.0.1	t
185	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.112 AQUATON- DIF ESTATAL-APOYO  21mayo26.xls	trans_1791914705_7ce89847_ORDEN_DE_PROD.No.112_AQUATON-_DIF_ESTATAL-APOYO__21mayo26.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:38:46.512782	2026-10-14 13:38:46.512782	DESCARGADO	189.195.177.20	f	127.0.0.1	t
184	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.111 ISJU enlace presidencia  22mayo26.xls	trans_1791914705_4eb1aa16_ORDEN_DE_PROD.No.111_ISJU_enlace_presidencia__22mayo26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:39:15.568818	2026-10-14 13:39:15.568818	DESCARGADO	189.195.177.20	f	127.0.0.1	t
183	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.109 Conmemoracion Batalla de Puebla en 9na zona militar  05mayo26.xls	trans_1791914705_d408c80e_ORDEN_DE_PROD.No.109_Conmemoracion_Batalla_de_Puebla_en_9na_zona_militar__05mayo26.xls	56320	55.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:39:34.728148	2026-10-14 13:39:34.728148	DESCARGADO	189.195.177.20	f	127.0.0.1	t
182	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.110  Grabación aspectos   06mayo26.xls	trans_1791914705_277c9c0a_ORDEN_DE_PROD.No.110__Grabaci_n_aspectos___06mayo26.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:39:45.177011	2026-10-14 13:39:45.177011	DESCARGADO	189.195.177.20	f	127.0.0.1	t
181	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.108 Rueda de Prensa Gabinete de Seguridad en 9na zona militar  04mayo26.xls	trans_1791914705_f9a3db8d_ORDEN_DE_PROD.No.108_Rueda_de_Prensa_Gabinete_de_Seguridad_en_9na_zona_militar__04mayo26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:39:55.759719	2026-10-14 13:39:55.759719	DESCARGADO	189.195.177.20	f	127.0.0.1	t
180	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.107 Reunión Privada de Seguridad 9na zona militar  04mayo26.xls	trans_1791914705_933d59da_ORDEN_DE_PROD.No.107_Reuni_n_Privada_de_Seguridad_9na_zona_militar__04mayo26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:40:00.77725	2026-10-14 13:40:00.77725	DESCARGADO	189.195.177.20	f	127.0.0.1	t
179	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.106  Semanera Auditorio 27abril26.xls	trans_1791914705_039034a6_ORDEN_DE_PROD.No.106__Semanera_Auditorio_27abril26.xls	58368	57.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:40:06.032197	2026-10-14 13:40:06.032197	DESCARGADO	189.195.177.20	f	127.0.0.1	t
178	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.105 MORENA en figlostase 25abril26.xls	trans_1791914705_c5534f3c_ORDEN_DE_PROD.No.105_MORENA_en_figlostase_25abril26.xls	55296	54.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:40:10.936051	2026-10-14 13:40:10.936051	DESCARGADO	189.195.177.20	f	127.0.0.1	t
177	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.104  GES-cuenta cuentos 22abril26.xls	trans_1791914705_8991d235_ORDEN_DE_PROD.No.104__GES-cuenta_cuentos_22abril26.xls	56320	55.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:40:16.424765	2026-10-14 13:40:16.424765	DESCARGADO	189.195.177.20	f	127.0.0.1	t
176	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.103  Evento Hotel Lucerna-KUWA- 30abril26.xls	trans_1791914705_2dbcf382_ORDEN_DE_PROD.No.103__Evento_Hotel_Lucerna-KUWA-_30abril26.xls	54784	53.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:40:21.44778	2026-10-14 13:40:21.44778	DESCARGADO	189.195.177.20	f	127.0.0.1	t
175	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.101- IEES Sesion Virtual en estudio 27abril-26.xls	trans_1791914705_3749758d_ORDEN_DE_PROD.No.101-_IEES_Sesion_Virtual_en_estudio_27abril-26.xls	56320	55.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:40:27.025418	2026-10-14 13:40:27.025418	DESCARGADO	189.195.177.20	f	127.0.0.1	t
174	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.100 REUNION GABINETE-HANGAR MILITAR16 de abril.xls	trans_1791914705_b770e052_ORDEN_DE_PROD.No.100_REUNION_GABINETE-HANGAR_MILITAR16_de_abril.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:40:32.280245	2026-10-14 13:40:32.280245	DESCARGADO	189.195.177.20	f	127.0.0.1	t
173	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.099  Grabación Entrevista SACSA.xls	trans_1791914705_36e3c962_ORDEN_DE_PROD.No.099__Grabaci_n_Entrevista_SACSA.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:40:38.946054	2026-10-14 13:40:38.946054	DESCARGADO	189.195.177.20	f	127.0.0.1	t
172	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.097 IEES Conferencias TEATRO UAdO.xls	trans_1791914705_02bd02ba_ORDEN_DE_PROD.No.097_IEES_Conferencias_TEATRO_UAdO.xls	57344	56.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:40:43.945321	2026-10-14 13:40:43.945321	DESCARGADO	189.195.177.20	f	127.0.0.1	t
171	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.098 Enlace con la mañanera del Pueblo PRESIDENTA y REUNION GOBER.xls	trans_1791914705_bc0c74e9_ORDEN_DE_PROD.No.098_Enlace_con_la_ma_anera_del_Pueblo_PRESIDENTA_y_REUNION_GOBER.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:40:48.960723	2026-10-14 13:40:48.960723	DESCARGADO	189.195.177.20	f	127.0.0.1	t
155	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.085 ENLACE PRESIDENTA ISMUJERES 12MARZO26.xls	trans_1791914705_5fe3cfef_ORDEN_DE_PROD.No.085_ENLACE_PRESIDENTA_ISMUJERES_12MARZO26.xls	56320	55.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:42:17.000507	2026-10-14 13:42:17.000507	DESCARGADO	189.195.177.20	f	127.0.0.1	t
150	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.075- IEES Sesion Extraord. y especial -virtual 25feb26.xls	trans_1791914705_7aa85eff_ORDEN_DE_PROD.No.075-_IEES_Sesion_Extraord._y_especial_-virtual_25feb26.xls	56320	55.0 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:42:43.624511	2026-10-14 13:42:43.624511	DESCARGADO	189.195.177.20	f	127.0.0.1	t
149	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.083 SERV.AUDIOVISUAL CONFERENCIAS BLAST MARKETING -REST. CAYENA.xls	trans_1791914705_ffaf22ec_ORDEN_DE_PROD.No.083_SERV.AUDIOVISUAL_CONFERENCIAS_BLAST_MARKETING_-REST._CAYENA.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:42:48.984025	2026-10-14 13:42:48.984025	DESCARGADO	189.195.177.20	f	127.0.0.1	t
128	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.067 CIBACOPA- Guasave 10 y 11 abril.xls	trans_1791914705_c9dc2235_ORDEN_DE_PROD.No.067_CIBACOPA-_Guasave_10_y_11_abril.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:53:47.206069	2026-10-14 13:53:47.206069	DESCARGADO	189.195.177.20	f	127.0.0.1	t
112	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.138 GRABACIONES DEL CAMPO EN AGUASCALIENTES 06-agosto-26.xls	trans_1791914705_48f87f58_ORDEN_DE_PROD.No.138_GRABACIONES_DEL_CAMPO_EN_AGUASCALIENTES_06-agosto-26.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:55:42.096171	2026-10-14 13:55:42.096171	DESCARGADO	189.195.177.20	f	127.0.0.1	t
107	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No.137 ENLACE PRESICENCIA-despacho gobernador   05-agosto-26.xls	trans_1791914705_e271c4eb_ORDEN_DE_PROD.No.137_ENLACE_PRESICENCIA-despacho_gobernador___05-agosto-26.xls	56832	55.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 13:56:12.857404	2026-10-14 13:56:12.857404	DESCARGADO	189.195.177.20	f	127.0.0.1	t
88	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No156 Enlace vía ZOOM gobernadora y noticiero canal II,  15-sep-26.xls	trans_1791914705_b849ae4f_ORDEN_DE_PROD.No156_Enlace_v_a_ZOOM_gobernadora_y_noticiero_canal_II___15-sep-26.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 14:00:12.379174	2026-10-14 14:00:12.379174	DESCARGADO	189.195.177.20	f	127.0.0.1	t
90	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD.No154 Proveeduria internet a 10 modulos y cableado a stand, dias 09,10 y 11sept. Villa Juarez.xls	trans_1791914705_65b12d82_ORDEN_DE_PROD.No154_Proveeduria_internet_a_10_modulos_y_cableado_a_stand__dias_09_10_y_11sept._Villa_Juarez.xls	55808	54.5 KB	application/vnd.ms-excel		TRF-1791914705-CC5967	2026-10-13 12:05:05.812331	t	1	2026-10-13 14:00:24.361228	2026-10-14 14:00:24.361228	DESCARGADO	189.195.177.20	f	127.0.0.1	t
22	101	Ana Lilia Villarreal Uribe	201	Cuauhtemoc Rivera Agundez	ORDEN DE PROD. No.002-El Debate.xls	trans_1791914585_432bdf6f_ORDEN_DE_PROD._No.002-El_Debate.xls	54272	53.0 KB	application/vnd.ms-excel		TRF-1791914585-D96C68	2026-10-13 12:03:05.747693	t	2	2026-10-13 14:01:28.825873	2026-10-14 14:01:28.825873	DESCARGADO	189.195.177.20	f	127.0.0.1	t
\.


--
-- Data for Name: asistencia_eventos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.asistencia_eventos (id, id_empleado, nombre_empleado, cliente, fecha_evento) FROM stdin;
\.


--
-- Data for Name: control_asistencia; Type: TABLE DATA; Schema: public; Owner: -
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
302	104	2026-09-19	09:00:00	14:00:00	A TIEMPO	Ajuste manual: Turno Matutino (09:00 a 14:00)	\N	\N
303	121	2026-09-19	09:00:00	14:00:00	A TIEMPO	Ajuste manual: Turno Matutino (09:00 a 14:00)	\N	\N
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
293	202	2026-09-21	09:00:00	14:26:45	COMPLETO	Kiosco - T. Matutino | Ajuste manual (Sin luz) | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:04:12	19:01:02
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
300	109	2026-09-21	09:00:00	18:58:49	A TIEMPO	Kiosco - T. Matutino | Ajuste manual (Sin luz) | Kiosco - Fin Jornada	\N	\N
294	115	2026-09-21	09:00:00	14:00:41	A TIEMPO	Kiosco - T. Matutino | Ajuste manual (Sin luz) | Kiosco - Comida	\N	\N
298	124	2026-09-21	09:00:00	14:01:07	COMPLETO	Kiosco - T. Matutino | Ajuste manual (Sin luz) | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:04:17	18:59:47
301	113	2026-09-21	09:15:00	14:02:27	COMPLETO	Kiosco - T. Matutino | Ajuste manual | Kiosco - Comida | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:01:40	18:59:28
297	119	2026-09-21	09:00:00	14:01:20	COMPLETO	Kiosco - T. Matutino | Ajuste manual (Sin luz) | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:04:45	18:59:36
299	107	2026-09-21	09:00:00	14:00:54	COMPLETO	Kiosco - T. Matutino | Ajuste manual (Sin luz) | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:04:31	18:59:10
324	121	2026-09-22	10:00:34	\N	RETARDO	Kiosco - T. Matutino	\N	\N
292	201	2026-09-21	09:00:00	13:49:40	A TIEMPO	Kiosco - T. Matutino | Ajuste manual (Sin luz) | Kiosco - Comida | Kiosco - T. Vespertino	16:04:57	19:00:00
317	202	2026-09-22	08:58:24	14:02:06	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:58:09	19:00:07
322	105	2026-09-22	09:22:00	\N	RETARDO	Kiosco - T. Matutino	\N	\N
323	104	2026-09-22	09:54:35	14:03:33	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:38:36	19:00:14
325	200	2026-09-22	10:01:04	13:51:50	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
328	121	2026-09-23	08:46:51	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
335	104	2026-09-23	08:59:12	14:18:33	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	15:49:14	\N
329	115	2026-09-23	08:46:54	14:01:25	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
318	201	2026-09-22	08:58:39	14:15:42	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:01:24	18:58:32
320	107	2026-09-22	09:08:01	14:00:39	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:49:32	18:58:37
326	109	2026-09-22	09:30:00	18:58:46	RETARDO	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
319	119	2026-09-22	08:59:06	14:00:57	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:02:02	18:59:35
316	124	2026-09-22	08:57:59	14:01:01	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:59:41	18:59:50
321	113	2026-09-22	09:22:00	14:04:15	COMPLETO	Kiosco - T. Matutino | Ajuste manual | Kiosco - Comida | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:25:24	18:59:52
336	105	2026-09-23	09:04:34	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
334	107	2026-09-23	08:58:28	14:01:13	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:49:02	18:59:55
338	109	2026-09-23	09:34:14	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	19:00:40
331	124	2026-09-23	08:52:30	14:01:45	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:09:46	19:00:10
332	119	2026-09-23	08:53:15	14:01:36	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:09:54	18:59:37
337	113	2026-09-23	09:16:06	14:13:19	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:00:04	\N
333	202	2026-09-23	08:57:36	14:18:21	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:00:20	19:00:02
330	201	2026-09-23	08:50:57	14:01:50	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:04:29	18:59:32
396	121	2026-09-29	10:20:51	\N	RETARDO	Kiosco - T. Matutino	\N	\N
394	109	2026-09-29	09:19:01	14:02:19	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
327	200	2026-09-23	08:46:24	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos) | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	19:00:50
342	121	2026-09-24	08:51:57	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
371	113	2026-09-26	09:21:20	14:00:27	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
367	124	2026-09-26	09:08:59	14:00:36	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
365	115	2026-09-26	08:56:18	14:00:51	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
369	105	2026-09-26	09:10:01	14:00:58	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
344	119	2026-09-24	09:02:49	14:01:32	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
339	115	2026-09-24	08:50:38	08:58:18	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Matutino	14:01:37	\N
366	107	2026-09-26	08:59:06	14:01:17	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
370	109	2026-09-26	09:19:50	14:01:47	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
352	201	2026-09-25	08:58:16	14:05:00	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:00:04	18:57:39
356	105	2026-09-25	09:06:56	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	18:59:46
348	104	2026-09-24	09:06:55	14:04:36	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	15:49:43	\N
358	113	2026-09-25	09:19:35	14:02:32	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:08:47	19:00:03
351	124	2026-09-25	08:57:48	13:58:37	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:04:30	19:00:08
359	202	2026-09-25	09:32:35	14:11:08	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:54:09	19:00:13
354	119	2026-09-25	08:58:49	13:58:34	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:00:27	\N
360	109	2026-09-25	09:43:59	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	19:00:32
361	200	2026-09-25	10:08:40	13:32:52	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:24:56	19:00:35
341	200	2026-09-24	08:50:46	13:47:59	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:45:45	18:54:18
343	201	2026-09-24	08:58:29	14:04:51	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:06:44	18:58:41
340	202	2026-09-24	08:50:41	14:04:59	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:53:01	19:00:15
345	124	2026-09-24	09:02:53	14:01:15	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:06:17	19:00:27
349	113	2026-09-24	09:14:20	14:02:00	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:07:38	19:00:30
346	107	2026-09-24	09:03:30	14:01:28	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:03:55	19:00:36
350	109	2026-09-24	09:23:49	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	19:00:46
347	105	2026-09-24	09:03:40	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	19:01:09
362	104	2026-09-26	08:55:54	14:02:33	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
372	200	2026-09-26	09:25:14	14:03:26	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
364	201	2026-09-26	08:56:06	14:04:25	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
363	202	2026-09-26	08:56:00	14:05:10	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
353	115	2026-09-25	08:58:23	13:59:00	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
357	107	2026-09-25	09:09:20	13:57:51	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:49:25	19:01:00
355	104	2026-09-25	09:00:06	14:11:24	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	15:40:13	\N
368	119	2026-09-26	09:09:22	09:52:30	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
379	201	2026-09-28	09:06:17	13:59:54	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:48:37	19:00:33
380	113	2026-09-28	09:12:38	14:02:03	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:00:02	\N
373	124	2026-09-28	08:53:52	14:00:56	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:05:59	19:00:04
375	115	2026-09-28	08:54:09	14:01:07	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
377	105	2026-09-28	09:05:28	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	19:00:10
376	202	2026-09-28	08:54:34	14:02:30	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
382	200	2026-09-28	09:50:37	13:48:09	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	16:00:57	\N
381	109	2026-09-28	09:46:14	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	19:00:38
374	119	2026-09-28	08:53:55	14:00:49	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:06:39	19:00:20
383	121	2026-09-28	09:50:43	16:00:49	RETARDO	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	\N
384	107	2026-09-28	14:00:41	15:56:26	RETARDO	Kiosco - T. Matutino | Kiosco - Fin Jornada | Kiosco - T. Vespertino	19:00:12	\N
378	104	2026-09-28	09:06:11	15:21:25	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:48:41	19:01:58
387	105	2026-09-29	08:59:59	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
389	107	2026-09-29	09:07:22	14:03:25	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
386	104	2026-09-29	08:59:53	14:03:29	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
390	124	2026-09-29	09:08:37	14:00:53	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
385	115	2026-09-29	08:59:51	14:01:04	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
393	113	2026-09-29	09:12:56	14:01:30	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
388	202	2026-09-29	09:04:11	14:02:01	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
391	119	2026-09-29	09:09:25	14:02:08	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
392	201	2026-09-29	09:11:25	14:02:13	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
395	200	2026-09-29	10:20:48	14:10:48	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
405	109	2026-09-30	09:44:54	\N	RETARDO	Kiosco - T. Matutino	\N	\N
428	115	2026-10-02	09:18:47	14:00:46	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
407	121	2026-09-30	13:28:09	\N	RETARDO	Kiosco - T. Matutino	\N	\N
403	115	2026-09-30	09:18:27	14:00:25	RETARDO	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
432	200	2026-10-03	08:57:41	14:01:40	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
400	124	2026-09-30	08:57:14	14:00:49	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
419	121	2026-10-01	16:43:33	\N	RETARDO	Kiosco - T. Vespertino	\N	\N
420	201	2026-10-02	08:05:31	15:16:05	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:19:19	18:08:22
409	200	2026-10-01	08:43:52	12:47:43	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:43:43	18:59:11
416	107	2026-10-01	09:03:46	13:59:02	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:58:46	18:59:26
413	119	2026-10-01	08:56:16	14:01:09	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:04:17	18:59:32
417	113	2026-10-01	09:13:43	14:05:49	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:22:00	18:59:34
415	104	2026-10-01	08:59:46	14:19:53	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:55:25	18:59:37
401	104	2026-09-30	09:10:32	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	19:00:04
398	105	2026-09-30	08:50:48	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	19:00:11
406	107	2026-09-30	09:47:54	14:00:38	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:14:44	19:00:12
402	113	2026-09-30	09:15:36	14:13:52	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:00:20	\N
399	202	2026-09-30	08:54:18	14:24:14	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:03:58	19:01:15
404	200	2026-09-30	09:40:06	13:28:04	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:25:32	19:03:03
397	201	2026-09-30	08:08:33	14:53:32	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	17:07:57	19:04:41
414	105	2026-10-01	08:58:44	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
418	109	2026-10-01	09:46:09	\N	RETARDO	Kiosco - T. Matutino	\N	\N
430	200	2026-10-02	09:39:17	13:12:26	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:45:48	18:25:05
412	124	2026-10-01	08:55:55	14:00:40	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:04:03	18:59:46
408	201	2026-10-01	07:46:57	15:11:05	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:06:00	19:00:00
410	115	2026-10-01	08:44:17	14:01:00	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
411	202	2026-10-01	08:50:49	14:01:42	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:55:01	19:00:47
427	113	2026-10-02	09:18:26	14:04:01	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:27:06	19:03:41
421	105	2026-10-02	08:54:14	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
423	124	2026-10-02	08:55:07	14:00:28	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:06:00	19:03:47
426	107	2026-10-02	09:09:31	14:01:02	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:05:49	\N
433	202	2026-10-03	08:57:50	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
434	121	2026-10-03	08:57:57	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
424	119	2026-10-02	08:55:48	14:00:14	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:06:11	19:03:55
422	104	2026-10-02	08:54:25	14:58:08	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:43:47	19:04:13
425	202	2026-10-02	08:57:05	14:06:40	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:46:20	19:05:34
436	119	2026-10-03	09:01:14	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
429	109	2026-10-02	09:26:26	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	19:05:48
435	124	2026-10-03	09:00:59	14:00:07	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
431	115	2026-10-03	08:56:38	14:00:09	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
437	107	2026-10-03	09:04:05	14:00:36	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
440	109	2026-10-03	15:53:05	\N	ASISTENCIA	Kiosco - T. Vespertino	\N	\N
438	201	2026-10-03	15:28:57	\N	OMISIÓN COMIDA	Kiosco - T. Vespertino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	22:33:52
441	105	2026-10-03	16:01:51	\N	OMISIÓN COMIDA	Kiosco - T. Vespertino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	22:35:55
442	113	2026-10-03	16:13:23	\N	OMISIÓN COMIDA	Kiosco - T. Vespertino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	22:38:00
439	104	2026-10-03	15:31:02	\N	OMISIÓN COMIDA	Kiosco - T. Vespertino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	22:39:17
443	119	2026-10-04	12:27:46	\N	RETARDO	Kiosco - T. Matutino	\N	\N
444	202	2026-10-04	12:30:09	\N	RETARDO	Kiosco - T. Matutino	\N	\N
446	109	2026-10-05	06:54:44	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
450	115	2026-10-05	08:55:30	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
457	105	2026-10-06	08:25:14	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	19:00:03
462	124	2026-10-06	08:54:33	14:00:24	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:55:15	19:01:28
463	107	2026-10-06	08:59:48	15:58:17	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Fin Jornada | Kiosco - T. Vespertino	19:01:43	\N
456	104	2026-10-06	08:22:50	14:50:40	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:55:31	19:01:46
465	201	2026-10-06	09:39:59	14:01:34	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:01:20	19:01:58
460	200	2026-10-06	08:44:19	13:34:56	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:59:06	19:10:02
459	121	2026-10-06	08:43:39	\N	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Fin Jornada | Kiosco - Fin Jornada	\N	19:10:13
445	104	2026-10-05	06:49:02	15:02:42	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
452	201	2026-10-05	09:04:12	14:25:47	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:01:54	18:55:24
449	202	2026-10-05	08:55:27	14:27:20	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:00:08	19:00:04
451	105	2026-10-05	09:04:10	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	19:00:05
454	113	2026-10-05	09:15:58	14:05:34	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:00:06	\N
455	200	2026-10-05	10:15:02	14:09:04	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:55:14	19:00:41
447	119	2026-10-05	08:54:44	14:06:51	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:05:41	19:01:21
448	124	2026-10-05	08:55:07	14:06:53	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:03:44	19:01:32
453	107	2026-10-05	09:11:28	14:00:01	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:57:33	19:02:08
461	115	2026-10-06	08:47:24	14:00:14	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Comida	\N	\N
479	104	2026-10-08	08:50:38	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
466	121	2026-10-07	08:44:52	\N	ASISTENCIA	Kiosco - T. Matutino | Kiosco - Fin Jornada	\N	16:41:59
476	201	2026-10-07	10:43:12	14:16:51	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:08:45	18:59:56
475	107	2026-10-07	09:15:14	13:59:41	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:55:38	19:00:00
473	105	2026-10-07	09:00:53	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	19:00:01
474	113	2026-10-07	09:15:12	14:11:40	RETARDO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino	19:00:11	\N
458	109	2026-10-06	08:33:53	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	18:58:43
464	113	2026-10-06	09:17:28	14:07:41	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:03:13	18:59:53
470	124	2026-10-07	08:52:14	13:59:54	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:14:56	19:00:13
471	119	2026-10-07	08:52:52	13:59:45	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:15:11	19:00:20
469	202	2026-10-07	08:47:53	14:48:54	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:53:44	19:00:24
468	104	2026-10-07	08:47:31	15:00:37	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:38:17	19:00:25
472	109	2026-10-07	08:56:17	\N	OMISIÓN COMIDA	Kiosco - T. Matutino | 🚨 ADVERTENCIA: OMISIÓN DE COMIDA (Entrada 09:00 - Salida 19:00 sin registrar alimentos)	\N	19:07:40
467	200	2026-10-07	08:45:42	13:38:21	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:41:45	19:14:22
485	105	2026-10-08	09:12:47	\N	RETARDO	Kiosco - T. Matutino	\N	\N
487	109	2026-10-08	09:20:20	\N	RETARDO	Kiosco - T. Matutino	\N	\N
477	121	2026-10-08	08:44:21	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
486	113	2026-10-08	09:13:45	14:00:02	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:19:00	19:00:32
488	124	2026-10-09	08:57:07	\N	ASISTENCIA	Kiosco - T. Matutino	\N	\N
478	202	2026-10-08	08:45:46	14:03:41	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:54:01	19:03:33
483	107	2026-10-08	08:58:36	14:01:20	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	15:55:19	19:00:29
480	201	2026-10-08	08:51:12	14:17:44	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:04:25	19:01:48
481	124	2026-10-08	08:56:24	14:01:38	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:08:50	19:02:06
482	119	2026-10-08	08:56:53	14:01:39	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:09:24	19:01:56
484	200	2026-10-08	09:05:28	13:47:15	COMPLETO	Kiosco - T. Matutino | Kiosco - Comida | Kiosco - T. Vespertino | Kiosco - T. Vespertino	16:29:37	19:04:38
491	113	2026-10-09	09:09:24	\N	RETARDO	Kiosco - T. Matutino	\N	\N
492	107	2026-10-09	09:09:41	\N	RETARDO	Kiosco - T. Matutino	\N	\N
493	201	2026-10-09	09:17:59	\N	RETARDO	Kiosco - T. Matutino	\N	\N
494	200	2026-10-09	09:34:26	\N	RETARDO	Kiosco - T. Matutino	\N	\N
495	119	2026-10-09	10:58:14	\N	RETARDO	Kiosco - T. Matutino	\N	\N
490	202	2026-10-09	09:03:01	12:51:18	ASISTENCIA	Kiosco - T. Matutino | Kiosco HTML	\N	\N
489	115	2026-10-09	08:57:17	12:52:14	ASISTENCIA	Kiosco - T. Matutino | Kiosco HTML	\N	\N
496	102	2026-10-09	12:55:00	12:58:03	ASISTENCIA	Kiosco HTML | Kiosco HTML	\N	\N
497	103	2026-10-09	12:58:14	\N	ASISTENCIA	Kiosco HTML	\N	\N
498	104	2026-10-09	06:00:00	12:58:18	GIRA / COMIDA	📍 [EN GIRA] Entrada: 06:00 | Kiosco - Salida Matutina / Comida	\N	\N
\.


--
-- Data for Name: control_horas_extras; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: cronogramas_eventos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cronogramas_eventos (id_cronograma, folio, fecha, nombre_evento, ubicacion_general, folio_op, actividades, observaciones_generales, creado_por, fecha_creacion) FROM stdin;
\.


--
-- Data for Name: departamentos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departamentos (id, nombre) FROM stdin;
4	Sistemas
5	Ventas
1	Administracion
2	Edicion
3	Produccion
\.


--
-- Data for Name: empleados; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.empleados (id_empleado, nombre, depto, email, cel, fecha_nac, fecha_ing, licencia_vence, password, rol, rfc, curp, nss, estado_civil, domicilio, ciudad, cp, contacto_emergencia, tel_emergencia, parentesco_emergencia, escolaridad, puesto, tipo_contrato, salario_mensual, foto_url, estatus_empleado, fecha_baja, motivo_baja) FROM stdin;
103	Wilfrido Castro Beltran	ADMINISTRACION	notiene@hotmail.com	6676917919	1965-03-01	2016-01-28	2025-12-30	WilfridoC	BAJA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
110	Eduardo Alonso Valdez Gomez	PRODUCCION	eduardo.produccion@vprovideo.mx	6677769481	1976-10-01	2022-09-04	2050-02-25	EduardoA	BAJA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
116	Luz Damaris Quintero Pimentel	PRODUCCION		6674099301	2001-04-05	2025-03-10	2026-02-10	LuzD	BAJA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
117	Luis Quintin Mares Lopez	PRODUCCION	luis.camarografo@vprovideo.mx	6674766575	1990-05-06	2025-04-11	2025-10-11	vpro123	BAJA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
118	Hector Rementeria de la Rocha	PRODUCCION	hector.audio@vprovideo.mx	6671323708	2026-06-03	2022-11-26	2027-09-19	HectoR	BAJA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
122	Andrea Rivera Rivas	ADMINISTRACION	mkt@vprovideo.mx	6672090837	2000-09-08	2025-11-26	2026-01-15	AndreaR	BAJA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
123	Juan Pablo Espino Diaz	PRODUCCION	\N	6673278169	2003-06-17	2026-02-16	2026-01-31	JuanP	BAJA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
113	Carlos Jacobo Quezada Mendoza	PRODUCCION	carlos.edicion@vprovideo.mx	6674667614	2000-02-12	2023-12-07	2027-09-19	$2b$12$0/2ZlsvvQ3VvA5iB7fKDIO3SvhQF9orN6Em70sA1TjaR2L/b0uqcu	PRODUCCION	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
115	Ibon Araceli Campos Medina	ADMINISTRACION	notieneemail@hotmail.com	6674305028	1973-08-16	2025-02-09	2030-03-09	IbonA	PRODUCCION	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
529	Kiosco Bodega	KIOSKO		\N	2026-05-19	2026-05-09	2099-12-25	KioskO	LOGISTICA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
104	Jose Francisco Torres Sanchez	PRODUCCION	francisco.tecnico@vprovideo.mx	6672072138	1975-12-06	2016-12-04	2026-12-16	$2b$12$maVMyOl/cY9wwGFeGYj5guBuA1ZEUcSeE1cTFqA0fFvjHZMPpo5rm	PRODUCCION	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
102	Gerardo Villarreal Uribe	EDICION	gerardo@vprovideo.com	6673291087	1979-08-31	2015-12-27	2028-06-04	$2b$12$i4sfscS821ykcQvydKKPtOP1iA8Cwhcaskv383JWmW5e418fzAEee	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
121	Sofia Alejandra Villarreal Lopez	VENTAS	sofia.ventas@vprovideo.com	6673903759	1996-08-11	1996-08-11	2050-01-09	SofiA	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
125	Diego Villareal Lopez	ADMINISTRACION	diego@gmail.com	\N	2005-09-15	2005-09-15	2050-05-27	DiegoV	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
200	Andrea Maria Vilarreal Lopez	EDICION	andrea@vprovideo.mx	6673903762	1994-07-23	1994-07-23	2050-02-10	$2b$12$lV2c85P4yc6lwnIRoCi2j.Hljo1oSHpZaKdO7PH2XsdpR/arFOtGO	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
202	Edgar Javier Amarillas	SISTEMAS	live.stream@vprovideo.com	6672090481	1975-02-03	2024-09-24	2029-01-09	$2b$12$Kfzpr9LbUuRK3dIv/HMhOunhnQ3w6MGBXydLse2wTO/XyH8gje0XG	PRODUCCION	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
105	Jose Daniel Torres Arroyo	PRODUCCION	daniel.produccion@vprovideo.mx	6675788854	1999-01-28	2016-03-30	2100-02-21	$2b$12$GkNreszVLLBmt67EPXrk8eq5vqp1IzUQq/DayBhrESBKrWQZK/vUS	PRODUCCION	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
203	Pedro Villarreal Uribe	ADMINISTRACION	direccion@vprovideo.com	6672300488	1968-08-07	1964-08-07	2050-12-24	$2b$12$fXpITFlsgHoryqPp3q4MnOpzcmPswF.sI1XYbH9xxyI/Iv20VMtHq	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
201	Cuauhtemoc Rivera Agundez	SISTEMAS	cuauhtemoc.manager@audiovideopro.com.mx	6674305026	1970-09-30	2021-03-31	2025-03-31	$2b$12$3nqc7ExmR0y2vyo5L8Ug1OwcwLsJ.28Lep/q3RGBbJ9oR80GaaBvm	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
124	Manuel Eduardo Madrid	PRODUCCION	coordinador@vprovideo.com		1999-05-18	2026-03-23	2028-08-21	$2b$12$yi/.y4i8H7Pyg7G9icRaZuS2coy11GdoYQNWSwa8nHTkWIzQL8fuu	COORDINADOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
107	Martin Eduardo Sanchez Estrada	PRODUCCION	live.ventas@vprovideo.com	6678901234	1971-03-17	2016-06-01	2050-03-31	$2b$12$x2.aABcDfquVMc3gjo3JR.H5/lGp5gaLoYqNqgDeLbJvWJ1PGL7le	PRODUCTOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
109	Osiel Cuauhtemoc Hernandez Aldape	PRODUCCION	osiel.switcher@vprovideo.mx	6671520296	1970-12-20	2022-08-03	2029-09-17	$2b$12$F/bN.Tz9OO8JWdaAA0Ck3eXAx.61ynhxHzEkNS3RBVN3s5wmAvxwm	PRODUCCION	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
119	Manuel Antonio Madrid Zazueta	PRODUCCION	manuel@vprovideo.com	6671325182	1972-08-03	2019-11-26	2026-10-25	$2b$12$96Fw/6RABVtKdELqnoBXs.mVuGhN6LuNJJVF9TUZwMhkO5CcrQ2Qq	PRODUCTOR	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
101	Ana Lilia Villarreal Uribe	ADMINISTRACION	contabilidad@vprovideo.com	6671022524	1973-09-29	2015-11-26	2028-01-09	$2b$12$5s4UH59kZ6phWxloq7O4x.JxjFVL.Ypij9goubCAnJp2ngGwFHXcS	ADMIN	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVO	\N	\N
\.


--
-- Data for Name: log_accesos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.log_accesos (id_log, fecha, hora, ip_origen, id_empleado, nombre_empleado, tipo_evento) FROM stdin;
2	2026-10-10	22:22:45.637257	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
3	2026-10-10	22:23:51.521369	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
4	2026-10-10	22:24:59.336949	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
5	2026-10-10	22:33:13.214905	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
6	2026-10-10	22:33:13.305373	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
7	2026-10-10	22:43:10.190852	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
8	2026-10-10	22:43:10.286247	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
9	2026-10-10	22:59:48.852192	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
10	2026-10-10	22:59:48.943058	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
11	2026-10-12	10:08:54.167926	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
12	2026-10-12	10:08:54.257331	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
13	2026-10-12	10:13:49.963063	INTRANET	107	Martin Eduardo Sanchez Estrada	LOGIN_SISTEMA
14	2026-10-12	10:13:50.088334	WEB_PORTAL	107	Martin Eduardo Sanchez Estrada	LOGIN_PLATAFORMA
15	2026-10-12	10:32:51.833704	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
16	2026-10-12	10:32:51.919348	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
17	2026-10-12	12:02:08.425875	INTRANET	124	Manuel Eduardo Madrid	LOGIN_SISTEMA
18	2026-10-12	12:02:08.550355	WEB_PORTAL	124	Manuel Eduardo Madrid	LOGIN_PLATAFORMA
19	2026-10-12	12:22:23.571223	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
20	2026-10-12	12:22:23.669835	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
21	2026-10-12	12:23:23.906868	INTRANET	124	Manuel Eduardo Madrid	LOGIN_SISTEMA
22	2026-10-12	12:23:24.123849	WEB_PORTAL	124	Manuel Eduardo Madrid	LOGIN_PLATAFORMA
23	2026-10-12	12:44:37.509707	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
24	2026-10-12	12:44:37.681947	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
25	2026-10-13	09:59:33.067342	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
26	2026-10-13	09:59:33.156969	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
27	2026-10-13	10:48:20.994087	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
28	2026-10-13	10:48:21.094988	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
29	2026-10-13	10:59:36.728693	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
30	2026-10-13	10:59:36.854546	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
31	2026-10-13	11:19:10.220261	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
32	2026-10-13	11:19:10.321151	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
33	2026-10-13	11:33:08.284037	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
34	2026-10-13	11:33:08.374553	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
35	2026-10-13	11:35:51.173147	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
36	2026-10-13	11:35:51.311348	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
37	2026-10-13	11:37:42.515147	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
38	2026-10-13	11:37:42.636299	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
39	2026-10-13	11:39:23.401635	INTRANET	101	Ana Lilia Villarreal Uribe	LOGIN_SISTEMA
40	2026-10-13	11:39:23.529893	WEB_PORTAL	101	Ana Lilia Villarreal Uribe	LOGIN_PLATAFORMA
41	2026-10-13	11:47:35.333561	INTRANET	101	Ana Lilia Villarreal Uribe	LOGIN_SISTEMA
42	2026-10-13	11:47:35.474456	WEB_PORTAL	101	Ana Lilia Villarreal Uribe	LOGIN_PLATAFORMA
43	2026-10-13	12:25:06.310636	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
44	2026-10-13	12:25:06.450457	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
45	2026-10-13	12:38:18.436361	INTRANET	101	Ana Lilia Villarreal Uribe	LOGIN_SISTEMA
46	2026-10-13	12:38:18.574581	WEB_PORTAL	101	Ana Lilia Villarreal Uribe	LOGIN_PLATAFORMA
47	2026-10-13	12:46:23.587676	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
48	2026-10-13	12:46:23.722592	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
49	2026-10-13	13:36:23.340217	INTRANET	107	Martin Eduardo Sanchez Estrada	LOGIN_SISTEMA
50	2026-10-13	13:36:23.455634	WEB_PORTAL	107	Martin Eduardo Sanchez Estrada	LOGIN_PLATAFORMA
51	2026-10-13	13:37:08.396796	INTRANET	101	Ana Lilia Villarreal Uribe	LOGIN_SISTEMA
52	2026-10-13	13:37:08.479217	WEB_PORTAL	101	Ana Lilia Villarreal Uribe	LOGIN_PLATAFORMA
53	2026-10-13	13:38:35.652412	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
54	2026-10-13	13:38:35.845272	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
55	2026-10-13	14:03:37.526855	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
56	2026-10-13	14:03:37.648835	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
57	2026-10-13	14:04:06.451032	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
58	2026-10-13	14:04:06.548027	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
59	2026-10-13	14:28:28.833785	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
60	2026-10-13	14:28:28.916433	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
61	2026-10-13	14:31:42.30014	INTRANET	101	Ana Lilia Villarreal Uribe	LOGIN_SISTEMA
62	2026-10-13	14:31:42.423556	WEB_PORTAL	101	Ana Lilia Villarreal Uribe	LOGIN_PLATAFORMA
63	2026-10-13	14:33:53.801629	INTRANET	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN_SISTEMA
64	2026-10-13	14:33:53.890528	WEB_PORTAL	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN_PLATAFORMA
65	2026-10-13	14:35:39.833742	INTRANET	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN_SISTEMA
66	2026-10-13	14:35:39.923049	WEB_PORTAL	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN_PLATAFORMA
67	2026-10-13	14:46:45.577345	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
68	2026-10-13	14:46:45.662258	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
69	2026-10-13	14:53:40.509859	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
70	2026-10-13	14:53:40.603901	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
71	2026-10-13	14:54:34.884638	INTRANET	107	Martin Eduardo Sanchez Estrada	LOGIN_SISTEMA
72	2026-10-13	14:54:35.061561	WEB_PORTAL	107	Martin Eduardo Sanchez Estrada	LOGIN_PLATAFORMA
73	2026-10-13	14:56:08.097512	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
74	2026-10-13	14:56:08.194279	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
75	2026-10-13	14:58:21.213132	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
76	2026-10-13	14:58:21.302156	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
77	2026-10-13	14:58:38.385526	INTRANET	107	Martin Eduardo Sanchez Estrada	LOGIN_SISTEMA
78	2026-10-13	14:58:38.476508	WEB_PORTAL	107	Martin Eduardo Sanchez Estrada	LOGIN_PLATAFORMA
79	2026-10-13	15:01:25.541202	INTRANET	107	Martin Eduardo Sanchez Estrada	LOGIN_SISTEMA
80	2026-10-13	15:01:25.621413	WEB_PORTAL	107	Martin Eduardo Sanchez Estrada	LOGIN_PLATAFORMA
81	2026-10-13	15:04:46.20662	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
82	2026-10-13	15:04:46.322229	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
83	2026-10-13	15:05:29.809594	INTRANET	101	Ana Lilia Villarreal Uribe	LOGIN_SISTEMA
84	2026-10-13	15:05:29.90346	WEB_PORTAL	101	Ana Lilia Villarreal Uribe	LOGIN_PLATAFORMA
85	2026-10-13	17:14:19.084247	INTRANET	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN_SISTEMA
86	2026-10-13	17:14:19.291403	WEB_PORTAL	109	Osiel Cuauhtemoc Hernandez Aldape	LOGIN_PLATAFORMA
87	2026-10-13	17:17:11.381937	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
88	2026-10-13	17:17:11.473481	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
89	2026-10-13	17:23:06.70254	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
90	2026-10-13	17:23:06.905268	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
91	2026-10-13	17:46:54.879337	INTRANET	201	Cuauhtemoc Rivera Agundez	LOGIN_SISTEMA
92	2026-10-13	17:46:54.972709	WEB_PORTAL	201	Cuauhtemoc Rivera Agundez	LOGIN_PLATAFORMA
93	2026-10-13	17:53:42.457799	INTRANET	101	Ana Lilia Villarreal Uribe	LOGIN_SISTEMA
94	2026-10-13	17:53:42.556524	WEB_PORTAL	101	Ana Lilia Villarreal Uribe	LOGIN_PLATAFORMA
95	2026-10-13	18:10:31.065506	INTRANET	124	Manuel Eduardo Madrid	LOGIN_SISTEMA
96	2026-10-13	18:10:31.179559	WEB_PORTAL	124	Manuel Eduardo Madrid	LOGIN_PLATAFORMA
\.


--
-- Data for Name: op_agenda; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.op_agenda (id, titulo, fecha_inicio, fecha_fin, todo_el_dia, tipo_evento, color_fondo, locacion, recursos_tecnicos, personal_asignado, notas_adicionales, creado_por, fecha_creacion, estatus) FROM stdin;
1	INHABIL AÑO NUEVO	2026-01-01 00:00:00	2026-01-01 00:00:00	t	Inhábil	#95a5a6	\N	\N	\N	INHABIL AÑO NUEVO	Script de Importación	2026-10-09 19:38:29.895989	Activo
2	VACACIONES DANIEL Y GEO	2026-01-02 00:00:00	2026-01-02 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES DANIEL Y GEO	Script de Importación	2026-10-09 19:38:29.895989	Activo
3	VACACIONES DANIEL Y GEO	2026-01-03 00:00:00	2026-01-03 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES DANIEL Y GEO	Script de Importación	2026-10-09 19:38:29.895989	Activo
4	INSTALACIÓN: LA SEMANERA                                                     En Los Mochis, Sinaloa.	2026-01-04 00:00:00	2026-01-04 00:00:00	t	Semanera	#3498db	\N	\N	\N	INSTALACIÓN: LA SEMANERA                                                     En Los Mochis, Sinaloa.                                                                Llamado de Salida: 02:00pm                                                                                                                                           Gerardo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Edgar (internet)                                                                                                                                           Carlos (graficos)                                                                                           Hector (Audio)                                                                                                                                                                                                                                                                                                                                                                                    Dany (camara)                                                                                                                                                                                                                                                             Paco   (camara y tecnico)                                                                                                                                                                                                                                                            Osiel (switcher)                                        \nLuis Mares (camara)                               EXTERNO:Eduardo A. (camara)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             CIRCUITO CERRADO A 5 CÁMARAS, STREAMING, LENGUAJE DE SEÑAS     ,  1 MONITOR DE 40" A PISO          \n Lenguaje de señas:                                                                                                                  \nCONTRATO NUEVO 2025  65 emisiones                                   GES-06/2025-9                                                        Extensión de emision #24	Script de Importación	2026-10-09 19:38:29.895989	Activo
5	VACACIONES GEO	2026-01-05 00:00:00	2026-01-05 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES GEO	Script de Importación	2026-10-09 19:38:29.895989	Activo
6	VACACIONES GEO Y OSIEL	2026-01-06 00:00:00	2026-01-06 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES GEO Y OSIEL	Script de Importación	2026-10-09 19:38:29.895989	Activo
7	VACACIONES GEO	2026-01-07 00:00:00	2026-01-07 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES GEO	Script de Importación	2026-10-09 19:38:29.895989	Activo
8	VACACIONES ANA LILIA	2026-01-10 00:00:00	2026-01-10 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES ANA LILIA	Script de Importación	2026-10-09 19:38:29.895989	Activo
9	LA SEMANERA                                                   H. Ayuntamiento en Los Mochis, Sinaloa	2026-01-05 00:00:00	2026-01-05 00:00:00	t	Semanera	#3498db	\N	\N	\N	LA SEMANERA                                                   H. Ayuntamiento en Los Mochis, Sinaloa.                                                                Entrada: 06:00am                                                                         Inicia 09:00am                                                                     Gerardo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Edgar (internet)                                                                                                                                           Carlos (graficos)                                                                                           Hector (Audio)                                                                                                                                                                                                                                                                                                                                                                                    Dany (camara)                                                                                                                                                                                                                                                             Paco   (camara y tecnico)                                                                                                                                                                                                                                                            Osiel (switcher)                                        \nLuis Mares (camara)                               EXTERNO:Eduardo A. (camara)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             CIRCUITO CERRADO A 5 CÁMARAS, STREAMING, LENGUAJE DE SEÑAS     ,  1 MONITOR DE 40" A PISO          \n Lenguaje de señas:                                                                                                                  \nCONTRATO NUEVO 2025  65 emisiones                                   GES-06/2025-9                                                 Extensión de emision #24	Script de Importación	2026-10-09 19:38:29.895989	Activo
10	TRASLADO E INSTALACIÓN PARA PRUEBAS DE EVENTO: FAST STAR  CEDI EL VENADILLO EN MAZATLAN, SINALOA.   	2026-01-09 00:00:00	2026-01-09 00:00:00	t	Gira	#e74c3c	\N	\N	\N	TRASLADO E INSTALACIÓN PARA PRUEBAS DE EVENTO: FAST STAR  CEDI EL VENADILLO EN MAZATLAN, SINALOA.      ENSAYO GENERAL CON CULIACAN 4:00PM	Script de Importación	2026-10-09 19:38:29.895989	Activo
11	INSTALACION: CEDI PLANTA CULIACAN TALLER MOTRIZ    INICIO DE ENSAYO : 4PM  EVENTO FAST STAR COCA COL	2026-01-09 00:00:00	2026-01-09 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTALACION: CEDI PLANTA CULIACAN TALLER MOTRIZ    INICIO DE ENSAYO : 4PM  EVENTO FAST STAR COCA COLA	Script de Importación	2026-10-09 19:38:29.895989	Activo
12	LA SEMANERA                                                  en Auditorio                           	2026-01-13 00:00:00	2026-01-13 00:00:00	t	Semanera	#3498db	\N	\N	\N	LA SEMANERA                                                  en Auditorio                                                               Entrada: 06:00am                                                                         Inicia 09:00am                                                                     Gerardo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Edgar (internet)                                                                                                                                           Carlos (graficos)                                                                                           Hector (Audio)                                                                                                                                                                                                                                                                                                                                                                                    Dany (camara)                                                                                                                                                                                                                                                             Paco   (camara y tecnico)                                                                                                                                                                                                                                                            Osiel (switcher)                                        \nLuis Mares (camara)                               EXTERNO:Eduardo A. (camara)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             CIRCUITO CERRADO A 5 CÁMARAS, STREAMING, LENGUAJE DE SEÑAS     ,  1 MONITOR DE 40" A PISO          \n Lenguaje de señas:                                                                                                                  \nCONTRATO NUEVO 2025                                          65 emisiones                                   GES-06/2025-9                                                 SE CANCELO YA INSTALADOS (se aviso a Lenguaje 7:45am)	Script de Importación	2026-10-09 19:38:29.895989	Activo
13	SESION EXTRAORDINARIA VIRTUAL IEES:  Inicia 11:00am en ESTUDIO	2026-01-14 00:00:00	2026-01-14 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SESION EXTRAORDINARIA VIRTUAL IEES:  Inicia 11:00am en ESTUDIO	Script de Importación	2026-10-09 19:38:29.895989	Activo
14	SALIDA A INSTALAR: LA SEMANERA  en Guasave, Sin.                                                    	2026-01-18 00:00:00	2026-01-18 00:00:00	t	Semanera	#3498db	\N	\N	\N	SALIDA A INSTALAR: LA SEMANERA  en Guasave, Sin.                                                                                                          Hora de llamado:                                Hora de instalación:                                                                        Geo                                                       Valdez Switcher                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Cuauhtemoc (internet)                                                                                                                                                                                                                                                  Hector (Audio)                                                                                                                                                                                                                                                                                                                                                                                    Dany (camara)                                                                                                                                                                                                                                                             Paco   (camara y tecnico)                               Carlos (graficos)                                                                                                                                                                                                                                                                                                 EXTERNO:                                                       Calixto. (camara)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             CIRCUITO CERRADO A 5 CÁMARAS, STREAMING, LENGUAJE DE SEÑAS     ,  1 MONITOR DE 40" A PISO          \n Lenguaje de señas:                                                                                                                  \nCONTRATO NUEVO 2025                                          65 emisiones                                   GES-06/2025-9                                               Extensión de Emision #25	Script de Importación	2026-10-09 19:38:29.895989	Activo
15	Valdez  (switcher)	2026-01-18 00:00:00	2026-01-18 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	Valdez  (switcher)	Script de Importación	2026-10-09 19:38:29.895989	Activo
16	LA SEMANERA  en Guasave, Sin.                                                                       	2026-01-19 00:00:00	2026-01-19 00:00:00	t	Semanera	#3498db	\N	\N	\N	LA SEMANERA  en Guasave, Sin.                                                                                                          Entrada: 06:00am                                                                         Inicia 09:00am                                                CIRCUITO CERRADO A 5 CÁMARAS, STREAMING, LENGUAJE DE SEÑAS     ,                   1 MONITOR DE 40" A PISO          \n Lenguaje de señas:                                                                                                                                                              Gerardo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Edgar (internet)                                                                                                                                           Carlos (graficos)                                                                                           Hector (Audio)                                                                                                                                                                                                                                                                                                                                                                                    Dany (camara)                                                                                                                                                                                                                                                             Paco   (camara y tecnico)                                                                                                                                                                                                                                                            Osiel (switcher)                                        \nLuis Mares (camara)                               EXTERNO:Calixto (camara)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           \nCONTRATO NUEVO 2025                                          65 emisiones                                   GES-06/2025-9                                               Extensión de Emision #25	Script de Importación	2026-10-09 19:38:29.895989	Activo
17	EVENTO: GIRAS-SECRETARIAS Entrega de 3,187 acciones de certeza Jurídica en Sinaloa de Leyva         	2026-01-19 00:00:00	2026-01-19 00:00:00	t	Gira	#e74c3c	\N	\N	\N	EVENTO: GIRAS-SECRETARIAS Entrega de 3,187 acciones de certeza Jurídica en Sinaloa de Leyva                                                        Llamado:  06am                                                               inicio de evento:    12:00pm                                   Transmisión a 3 cámaras                                   Switcher                                                     Proveeduria  de internet                                             1 antena Starlink                                              Osiel, Cuahutemoc  y  Manuel                                                   EXTERNOS:  Condor y Nacho	Script de Importación	2026-10-09 19:38:29.895989	Activo
18	LA SEMANERA  en Auditorio                                                                           	2026-01-26 00:00:00	2026-01-26 00:00:00	t	Semanera	#3498db	\N	\N	\N	LA SEMANERA  en Auditorio                                                                                                         Entrada: 06:00am                                                                         Inicia 09:00am                                                CIRCUITO CERRADO A 5 CÁMARAS, STREAMING, LENGUAJE DE SEÑAS     ,                   1 MONITOR DE 40" A PISO          \n Lenguaje de señas:                                                                                                                                                              Gerardo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Edgar (internet)                                                                                                                                           Carlos (graficos)                                                                                           Hector (Audio)                                                                                                                                                                                                                                                                                                                                                                                    Dany (camara)                                                                                                                                                                                                                                                             Paco   (camara y tecnico)                                                                                                                                                                                                                                                            Osiel (switcher)                                        \nLuis Mares (camara)                               EXTERNO:Calixto (camara)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           \nCONTRATO NUEVO 2025                                          65 emisiones                                   GES-06/2025-9                                               Extensión de Emision #26	Script de Importación	2026-10-09 19:38:29.895989	Activo
19	VACACIONES CUAUHTEMOC	2026-02-04 00:00:00	2026-02-04 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CUAUHTEMOC	Script de Importación	2026-10-09 19:38:29.895989	Activo
20	VACACIONES CUAUHTEMOC	2026-02-05 00:00:00	2026-02-05 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CUAUHTEMOC	Script de Importación	2026-10-09 19:38:29.895989	Activo
21	NO HUBO SEMANERA	2026-02-02 00:00:00	2026-02-02 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
22	GIRAS-SECRETARIAS:   DIF   INSTALACION Y PRUEBAS: 12pm  , ubicación blvd. Agricultores (Luz noticias	2026-02-04 00:00:00	2026-02-04 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS-SECRETARIAS:   DIF   INSTALACION Y PRUEBAS: 12pm  , ubicación blvd. Agricultores (Luz noticias transmitirá)                           Suministro dei nternet	Script de Importación	2026-10-09 19:38:29.895989	Activo
23	GIRAS-SECRETARIAS:   DIF  INICIA TRANMSION DE 6 A 9AM, Ubicación Blvd. Agricultores (Luz noticias tr	2026-02-05 00:00:00	2026-02-05 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS-SECRETARIAS:   DIF  INICIA TRANMSION DE 6 A 9AM, Ubicación Blvd. Agricultores (Luz noticias transmitirá)                              Suministro de internet	Script de Importación	2026-10-09 19:38:29.895989	Activo
24	LA SEMANERA  en Auditorio                                                                           	2026-02-09 00:00:00	2026-02-09 00:00:00	t	Semanera	#3498db	\N	\N	\N	LA SEMANERA  en Auditorio                                                                                                         Entrada: 06:00am                                                                         Inicia 09:00am                                                CIRCUITO CERRADO A 5 CÁMARAS, STREAMING, LENGUAJE DE SEÑAS     ,                   1 MONITOR DE 40" A PISO          \n Lenguaje de señas:                                                                                                                                                              Gerardo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Edgar (internet)                                                                                                                                           Carlos (graficos)                                                                                           Hector (Audio)                                                                                                                                                                                                                                                                                                                                                                                    Dany (camara)                                                                 Manuel (cámara)                                                                                                                                                                                                                                                       Paco   (camara y tecnico)                                                                                                                                                                                                                                                            Osiel (switcher)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               \nCONTRATO NUEVO 2025                                          65 emisiones                                   GES-06/2025-9                                               Extensión de Emision #27	Script de Importación	2026-10-09 19:38:29.895989	Activo
25	EVENTO: HANGAR MILITAR #10, " Aniversario de la Fuerza Aerea Mexicana"                              	2026-02-10 00:00:00	2026-02-10 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	EVENTO: HANGAR MILITAR #10, " Aniversario de la Fuerza Aerea Mexicana"                                   Llamado:  6:00am              Inicio:10am                      Switcher                                                   2 computadora                                        2 Monitores de 55"                                        1 antena Starlink                                  Proveeduría de internet                             KUWA:                                                            2 pantallas led medida 3x2m en base 1m. altura	Script de Importación	2026-10-09 19:38:29.895989	Activo
26	INSTALACION: HANGAR MILITAR #10   INSTALACIÓN: Pantallas 12:00pm   Switcher :4pm                    	2026-02-09 00:00:00	2026-02-09 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTALACION: HANGAR MILITAR #10   INSTALACIÓN: Pantallas 12:00pm   Switcher :4pm                                       Switcher                                                   2 computadoras                                          2 monitores de 55"                                      1 antena Starlink                                  Proveeduría de internet                             KUWA:                                                            2 pantallas led medida 3x2m en base 1m. alturaA	Script de Importación	2026-10-09 19:38:29.895989	Activo
27	NO HUBO SEMANERA	2026-02-16 00:00:00	2026-02-16 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
28	SECRET. GIRAS: Evento:  INAUGURACION DE SECUNDARIA TECNICA 101 de Valle Alto                        	2026-02-17 00:00:00	2026-02-17 00:00:00	t	Gira	#e74c3c	\N	\N	\N	SECRET. GIRAS: Evento:  INAUGURACION DE SECUNDARIA TECNICA 101 de Valle Alto                                   Streaming a 3 cámaras                                  2 monitores de 55" a piso                      KUWA:                                                 1 pantalla led 3x2m en base	Script de Importación	2026-10-09 19:38:29.895989	Activo
29	INSTALACIÓN: SECRET. GIRAS: Evento:  Día del Ejercito Mexicano    CUARTEL MILITAR EL SAUZ en COSTA R	2026-02-18 00:00:00	2026-02-18 00:00:00	t	Gira	#e74c3c	\N	\N	\N	INSTALACIÓN: SECRET. GIRAS: Evento:  Día del Ejercito Mexicano    CUARTEL MILITAR EL SAUZ en COSTA RICA                                  Switcher                             Vmix mini botonera                                  2 monitores de 55" a piso                             Proveeduría de Internet                  1 antena Starlink                         KUWA:                                                 2 pantalla led 3x2m en base	Script de Importación	2026-10-09 19:38:29.895989	Activo
30	SECRET. GIRAS: Evento:  Día del Ejercito Mexicano    CUARTEL MILITAR EL SAUZ en COSTA RICA          	2026-02-19 00:00:00	2026-02-19 00:00:00	t	Gira	#e74c3c	\N	\N	\N	SECRET. GIRAS: Evento:  Día del Ejercito Mexicano    CUARTEL MILITAR EL SAUZ en COSTA RICA                                  Switcher                                           Vmix mini botonera                                  2 monitores de 55" a piso                             Proveeduría de Internet                  1 antena Starlink                         KUWA:                                                 2 pantalla led 3x2m en base	Script de Importación	2026-10-09 19:38:29.895989	Activo
31	ARRANQUE DE CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. M	2026-02-21 00:00:00	2026-02-21 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	ARRANQUE DE CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán                                       Partido: Culiacán-Mazatlán                 ESTUDIO TV:                      Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                             Redes-Cuahutemoc          EXTERNO:                Comentariosta #1                                Miguel lópez                             Comentarista #2                Ernesto Gutierrez                        Repes-Javier García                  EN CAMPO:            Producción -Manuel      Redes- Edgar                    EXTERNOS:                                   Camarógrafo#1  Calixo Villa                     Camarógrafo #2 Jiaime Muro	Script de Importación	2026-10-09 19:38:29.895989	Activo
32	SWITCHER  :Salida a Colima con Kuwa                                               Instalación de esc	2026-02-22 00:00:00	2026-02-22 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SWITCHER  :Salida a Colima con Kuwa                                               Instalación de escenografia y pantallas.          Externo:   LORENZO SUSPENDIDO CAMBIA DE FECHA X SEGURIDAD Y SE RETORNA EQUIPO	Script de Importación	2026-10-09 19:38:29.895989	Activo
33	ARRANQUE DE CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. M	2026-02-22 00:00:00	2026-02-22 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	ARRANQUE DE CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán                                       Partido: Culiacán-Mazatlán                 ESTUDIO TV:                      Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                             Redes-Cuahutemoc          EXTERNO:                Comentariosta #1                                Miguel lópez                             Comentarista #2                Ernesto Gutierrez                        Repes-Javier García                  EN CAMPO:            Producción -Manuel      Redes- Edgar                    EXTERNOS:                                   Camarógrafo#1  Calixo Villa                     Camarógrafo #2 Jiaime Muro	Script de Importación	2026-10-09 19:38:29.895989	Activo
34	SWITCHER  A MAZATLAN :       EXTERNO: Switcher Lorenzo                                              	2026-02-23 00:00:00	2026-02-23 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SWITCHER  A MAZATLAN :       EXTERNO: Switcher Lorenzo                                               Pruebas y ensayo general.	Script de Importación	2026-10-09 19:38:29.895989	Activo
48	NO HUBO SEMANERA	2026-03-09 00:00:00	2026-03-09 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
35	LA SEMANERA  en Auditorio                                                                           	2026-02-23 00:00:00	2026-02-23 00:00:00	t	Semanera	#3498db	\N	\N	\N	LA SEMANERA  en Auditorio                                                                                                         Entrada: 06:00am                                                                         Inicia 09:00am                                                CIRCUITO CERRADO A 5 CÁMARAS, STREAMING, LENGUAJE DE SEÑAS     ,                   1 MONITOR DE 40" A PISO          \n Lenguaje de señas:                                                                                                                                                              Gerardo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Edgar (internet)                                                                                                                                           Carlos (graficos)                                                                                           Hector (Audio)                                                                                                                                                                                                                                                                                                                                                                                    Dany (camara)                                                                 Manuel (cámara)                                                                                                                                                                                                                                                       Paco   (camara y tecnico)                                                                                                                                                                                                                                                            Osiel (switcher)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               \nCONTRATO NUEVO 2025                                          65 emisiones                                   GES-06/2025-9                                               Extensión de Emision #28	Script de Importación	2026-10-09 19:38:29.895989	Activo
36	TRALADO DE SWITCHER  A SAN CARLOS  con KUWA,                     Motaje de kuwa escenografia        	2026-03-01 00:00:00	2026-03-01 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	TRALADO DE SWITCHER  A SAN CARLOS  con KUWA,                     Motaje de kuwa escenografia                                                           PERSONAL EXTERNO: Lorenzo	Script de Importación	2026-10-09 19:38:29.895989	Activo
37	TRASLADO EN AUTOBUS DE SWITCHER  a AGUASCALIENTES ,                                                 	2026-03-01 00:00:00	2026-03-01 00:00:00	t	Gira	#e74c3c	\N	\N	\N	TRASLADO EN AUTOBUS DE SWITCHER  a AGUASCALIENTES ,                                                                                     PERSONAL VPRO: Osiel	Script de Importación	2026-10-09 19:38:29.895989	Activo
38	CIBACOPA PRODUCCIÓN EN CANCHA: Locación: Culiacán, Polideportivo  Juan S. Millán      Partido: Culia	2026-03-01 00:00:00	2026-03-01 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN CANCHA: Locación: Culiacán, Polideportivo  Juan S. Millán      Partido: Culiacán-CDMX                                   EN CAMPO:                     Producción -Manuel                  Redes- Edgar                                                       Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                               Redes-Cuahutemoc          EXTERNOS:                Comentariosta #1                Miguel Lara                       Comentarista #2                   Ernesto Gutierrez                        Repes-Javier García                                                                       Camarógrafo#1   Calixto Villa                   Camarógrafo #2 Jaime Muro                Camarógrafo #3 Eduardo                     Camarógrafo #4: Ingacio           Camara #5 Fija   NOTA: POR UNICA OCASION DE ANEXAN 2 CAMARAS EN TERRENO Y LA PRODUCCION PASA A CANCHA EN LO QUE LLEGAN LOS EQUIPOS DIGITALES.	Script de Importación	2026-10-09 19:38:29.895989	Activo
39	Llegada  de SWITCHER  EN AGUASCALIENTES                                             Pruebas y ensayo	2026-03-02 00:00:00	2026-03-02 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	Llegada  de SWITCHER  EN AGUASCALIENTES                                             Pruebas y ensayo general.                   PERSONAL VPRO: Osiel	Script de Importación	2026-10-09 19:38:29.895989	Activo
40	RETORNO DE AGUASCALIENTES	2026-03-06 00:00:00	2026-03-06 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	RETORNO DE AGUASCALIENTES	Script de Importación	2026-10-09 19:38:29.895989	Activo
41	CIBACOPA PRODUCCIÓN EN CANCHA: Locación: Culiacán, Polideportivo  Juan S. Millán      Partido: Culia	2026-03-07 00:00:00	2026-03-07 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN CANCHA: Locación: Culiacán, Polideportivo  Juan S. Millán      Partido: Culiacán-CDMX                                   EN CAMPO:                     Producción -Manuel                  Redes- Edgar                                                       Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                               Redes-Cuahutemoc          EXTERNOS:                Comentariosta #1                Miguel lopez                     Comentarista #2                   Ernesto Gutierrez                        Repes-Javier García                                                                       Camarógrafo#1   Calixto Villa                   Camarógrafo #2 Jaime Muro                Camarógrafo #3  Ernesto Cuen                  Camarógrafo #4: Ignacio G.           Camara #5 Fija   NOTA: POR UNICA OCASION DE ANEXAN 2 CAMARAS EN TERRENO Y LA PRODUCCION PASA A CANCHA EN LO QUE LLEGAN LOS EQUIPOS DIGITALES.	Script de Importación	2026-10-09 19:38:29.895989	Activo
42	TRASLADO DE SWITCHER  a MANZANILLO  en autobus                                             Lllegada 	2026-03-08 00:00:00	2026-03-08 00:00:00	t	Gira	#e74c3c	\N	\N	\N	TRASLADO DE SWITCHER  a MANZANILLO  en autobus                                             Lllegada e   instalación                      PERSONAL EXTERNO: Ivan	Script de Importación	2026-10-09 19:38:29.895989	Activo
43	LA SEMANERA  en Auditorio                                                                           	2026-03-02 00:00:00	2026-03-02 00:00:00	t	Semanera	#3498db	\N	\N	\N	LA SEMANERA  en Auditorio                                                                                                         Entrada: 06:00am                                                                         Inicia 09:00am                                                CIRCUITO CERRADO A 5 CÁMARAS, STREAMING, LENGUAJE DE SEÑAS     ,                   1 MONITOR DE 40" A PISO          \n Lenguaje de señas:                                                                                                                                                              Gerardo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Edgar (internet)                                                                                                                                           Carlos (graficos)                                                                                           Hector (Audio)                                                                                                                                                                                                                                                                                                                                                                                    Dany (camara)                                                                 Manuel (cámara)                                                                                                                                                                                                                                                       Paco   (camara y tecnico)                                                                                                                                                                                                                                                            Osiel (switcher)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               \nCONTRATO NUEVO 2025                                          65 emisiones                                   GES-06/2025-9                                               Extensión de Emision #29	Script de Importación	2026-10-09 19:38:29.895989	Activo
44	TRASLADO DE CAMAROGRAFOS A  AGUASCALIENTES, AGS.                            PERSONAL VPRO:          	2026-03-03 00:00:00	2026-03-03 00:00:00	t	Gira	#e74c3c	\N	\N	\N	TRASLADO DE CAMAROGRAFOS A  AGUASCALIENTES, AGS.                            PERSONAL VPRO:                                    Gerardo                                           Daniel                                                                     TRASLADO DE CAMARÓGRAFOS A SAN CARLOS , SON           EXTERNOS:                                  Eduardo Araujo                                          Miguel Alemán	Script de Importación	2026-10-09 19:38:29.895989	Activo
45	CIBACOPA PRODUCCIÓN EN CANCHA: Locación: Culiacán, Polideportivo  Juan S. Millán      Partido: Culia	2026-03-06 00:00:00	2026-03-06 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN CANCHA: Locación: Culiacán, Polideportivo  Juan S. Millán      Partido: Culiacán-CDMX                                   EN CAMPO:                     Producción -Manuel                  Redes- Edgar                                                       Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                               Redes-Cuahutemoc          EXTERNOS:                Comentariosta #1                Miguel lopez                     Comentarista #2                   Ernesto Gutierrez                        Repes-Javier García                                                                       Camarógrafo#1   Calixto Villa                   Camarógrafo #2 Jaime Muro                Camarógrafo #3  Ernesto Cuen                  Camarógrafo #4: Ignacio G.           Camara #5 Fija   NOTA: POR UNICA OCASION DE ANEXAN 2 CAMARAS EN TERRENO Y LA PRODUCCION PASA A CANCHA EN LO QUE LLEGAN LOS EQUIPOS DIGITALES.	Script de Importación	2026-10-09 19:38:29.895989	Activo
46	SWITCHER  A SAN CARLOS  con KUWA,                                                 Ensayo y pruebas e	2026-03-02 00:00:00	2026-03-02 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SWITCHER  A SAN CARLOS  con KUWA,                                                 Ensayo y pruebas en General                                   PERSONAL EXTERNO: Lorenzo	Script de Importación	2026-10-09 19:38:29.895989	Activo
47	INSTALACION EN POLIDEPORTIVO PARA CIBACOPA	2026-03-05 00:00:00	2026-03-05 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTALACION EN POLIDEPORTIVO PARA CIBACOPA	Script de Importación	2026-10-09 19:38:29.895989	Activo
49	RETORNO DE TODAS LAS CONFERENCIAS. VACACIONES HECTOR	2026-03-13 00:00:00	2026-03-13 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	RETORNO DE TODAS LAS CONFERENCIAS. VACACIONES HECTOR	Script de Importación	2026-10-09 19:38:29.895989	Activo
50	VACACIONES HECTOR	2026-03-14 00:00:00	2026-03-14 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES HECTOR	Script de Importación	2026-10-09 19:38:29.895989	Activo
51	SWITCHER  a MANZANILLO                                               Ensayo y pruebas en general    	2026-03-09 00:00:00	2026-03-09 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SWITCHER  a MANZANILLO                                               Ensayo y pruebas en general                       PERSONAL EXTERNO:  Ivan                                                                             o	Script de Importación	2026-10-09 19:38:29.895989	Activo
52	SCAUTING A USE PARA SEMANERA   Geo y -Edgar	2026-03-13 00:00:00	2026-03-13 00:00:00	t	Semanera	#3498db	\N	\N	\N	SCAUTING A USE PARA SEMANERA   Geo y -Edgar	Script de Importación	2026-10-09 19:38:29.895989	Activo
53	TRASLADO  Y LLEGADA A LA 1:30PM DE SWITCHER  A DURANGO en autobus      Pruebas y ensayo             	2026-03-09 00:00:00	2026-03-09 00:00:00	t	Gira	#e74c3c	\N	\N	\N	TRASLADO  Y LLEGADA A LA 1:30PM DE SWITCHER  A DURANGO en autobus      Pruebas y ensayo                                                                     PERSONAL  VPRO: Valdez	Script de Importación	2026-10-09 19:38:29.895989	Activo
54	SESION ESPECIAL Y EXTRAORDINARIA VIRTUAL IEES:  Inicia 12:00am en ESTUDIO	2026-03-10 00:00:00	2026-03-10 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SESION ESPECIAL Y EXTRAORDINARIA VIRTUAL IEES:  Inicia 12:00am en ESTUDIO	Script de Importación	2026-10-09 19:38:29.895989	Activo
55	ENLACE MAÑANERA CON PRESIDENTA CON ISMUJERES:                                     Transmisión a 3 cá	2026-03-12 00:00:00	2026-03-12 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	ENLACE MAÑANERA CON PRESIDENTA CON ISMUJERES:                                     Transmisión a 3 cámaras                       proveeduría de internet                                   1 Antena Starlink                        PERSONAL VPRO:                                 Geo                                                          Osiel                                                        Edgar                                             Paco                                           EXTERNO: Eduardo Araujo	Script de Importación	2026-10-09 19:38:29.895989	Activo
56	CUMPLEAÑOS GEO	2026-03-17 00:00:00	2026-03-17 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CUMPLEAÑOS GEO	Script de Importación	2026-10-09 19:38:29.895989	Activo
57	VACACIONES HECTOR, MANUEL.	2026-03-20 00:00:00	2026-03-20 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES HECTOR, MANUEL.	Script de Importación	2026-10-09 19:38:29.895989	Activo
58	VACACIONES HECTOR	2026-03-21 00:00:00	2026-03-21 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES HECTOR	Script de Importación	2026-10-09 19:38:29.895989	Activo
59	NO HABIL	2026-03-16 00:00:00	2026-03-16 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	NO HABIL	Script de Importación	2026-10-09 19:38:29.895989	Activo
60	GIRAS: INAUGURACION DE FACULTAD DE MEDICINA DE LA UNIVERSIDAD AUTONOMA DE SINLOA EXTESIÓN GUASAVE.  	2026-03-19 00:00:00	2026-03-19 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: INAUGURACION DE FACULTAD DE MEDICINA DE LA UNIVERSIDAD AUTONOMA DE SINLOA EXTESIÓN GUASAVE.                                             Circuito Cerado a 3 cámaras                   Streaming                                                               2 monitores de 55" a piso             KUWA: 1 Pantalla led de 3x2m en base a piso	Script de Importación	2026-10-09 19:38:29.895989	Activo
61	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      P	2026-03-21 00:00:00	2026-03-21 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      Partido: Culiacán-Tijuana                                  ESTUDIO TV:                      Switcher- Valdez                   Audio- Osiel                      Gráficos- Carlos                               Redes-Cuahutemoc          EXTERNO:                Comentariosta #1   Comentarista #2                          Repes-Javier García                        EN CAMPO:                           Producción -Manuel                  Redes- Edgar                    EXTERNOS:                                   Camarógrafo#1                      Camarógrafo #2                                     Camarógrafo #3                        Camarógrafo #4	Script de Importación	2026-10-09 19:38:29.895989	Activo
62	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      P	2026-03-22 00:00:00	2026-03-22 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      Partido: Culiacán-Tijuana                                  ESTUDIO TV:                      Switcher- Valdez                   Audio- Osiel                      Gráficos- Carlos                               Redes-Cuahutemoc          EXTERNO:                Comentariosta #1   Comentarista #2                          Repes-Javier García                        EN CAMPO:                           Producción -Manuel                  Redes- Edgar                    EXTERNOS:                                   Camarógrafo#1                      Camarógrafo #2                                     Camarógrafo #3                        Camarógrafo #4	Script de Importación	2026-10-09 19:38:29.895989	Activo
63	LA SEMANERA  en AUDITORIO USE                                                                       	2026-03-17 00:00:00	2026-03-17 00:00:00	t	Semanera	#3498db	\N	\N	\N	LA SEMANERA  en AUDITORIO USE                                                                                                       Entrada: 06:00am                                                                         Inicia 09:00am                                                CIRCUITO CERRADO A 5 CÁMARAS, STREAMING, LENGUAJE DE SEÑAS     ,                   1 MONITOR DE 40" A PISO          \n Lenguaje de señas:                                                                                                                                                              Gerardo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Edgar (internet)                                                                                                                                           Carlos (graficos)                                                                                           Hector (Audio)                                                                                                                                                                                                                                                                                                                                                                                    Dany (camara)                                                                 Manuel (cámara)                                                                                                                                                                                                                                                       Paco   (camara y tecnico)                                                                                                                                                                                                                                                            Osiel (switcher)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               \nCONTRATO NUEVO 2025                                          65 emisiones                                   GES-06/2025-9                                               Extensión de Emision #30	Script de Importación	2026-10-09 19:38:29.895989	Activo
64	EVENTO: GRUPO PARLAMENTARIO DE MORENA: Hotel San Marcos Conferencia 11:00am inicia          KUWA:   	2026-03-22 00:00:00	2026-03-22 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	EVENTO: GRUPO PARLAMENTARIO DE MORENA: Hotel San Marcos Conferencia 11:00am inicia          KUWA:                                Audio lineal 4x1 x lado para (800 pers)                                                                                            6 monitores de audio 3xlado pasillo pedestal                                                                      Rack de amplificacion                                                                                                      3 microfonos inlámbricos                                                                                                  1 pesdestal para popdium                                                                                              Consola de audio digital yamaha                                                                                   ing.  de audio                                                                                                        stad. y dst. cableado                                                      6 yellow jacket de audio	Script de Importación	2026-10-09 19:38:29.895989	Activo
138	VACACIONES DANIEL, ANDREA,CUAHUTEMOC, SOFIA Y ANA LILIA	2026-05-18 00:00:00	2026-05-18 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES DANIEL, ANDREA,CUAHUTEMOC, SOFIA Y ANA LILIA	Script de Importación	2026-10-09 19:38:29.895989	Activo
139	NO HUBO SEMANERA	2026-05-18 00:00:00	2026-05-18 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
65	LA SEMANERA  en Auditorio                                                                           	2026-03-23 00:00:00	2026-03-23 00:00:00	t	Semanera	#3498db	\N	\N	\N	LA SEMANERA  en Auditorio                                                                                                         Entrada: 06:00am                                                                         Inicia 09:00am                                                CIRCUITO CERRADO A 5 CÁMARAS, STREAMING, LENGUAJE DE SEÑAS     ,                   1 MONITOR DE 40" A PISO          \n Lenguaje de señas:                                                                                                                                                              Gerardo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Edgar (internet)                                                                                                                                           Carlos (graficos)                                                                                           Hector (Audio)                                                                                                                                                                                                                                                                                                                                                                                    Dany (camara)                                                                 Manuel (cámara)                                                                                                                                                                                                                                                       Paco   (camara y tecnico)                                                                                                                                                                                                                                                            Osiel (switcher)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               \nCONTRATO NUEVO 2025                                          65 emisiones                                   GES-06/2025-9                                               Extensión de Emision #31	Script de Importación	2026-10-09 19:38:29.895989	Activo
66	INSTALACION EN REST. CAYENA  A PARTIR DE LAS 7PM	2026-03-24 00:00:00	2026-03-24 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTALACION EN REST. CAYENA  A PARTIR DE LAS 7PM	Script de Importación	2026-10-09 19:38:29.895989	Activo
67	EVENTO BLAST MARKETING EN RESTAURAN CAYENA INICIO: 8AM TERMINO 5:00PM                               	2026-03-25 00:00:00	2026-03-25 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	EVENTO BLAST MARKETING EN RESTAURAN CAYENA INICIO: 8AM TERMINO 5:00PM                                        PRODUCCION:                                      2 Pantallas led de 65" en tripie                                   1 Vmix botonera                                      2 laptop                                                2 micrófonos de mano inalambricos                                       1 sistema de audio                                         (bocinas  capac.30 personas)                              clicker lasser (apuntador.)	Script de Importación	2026-10-09 19:38:29.895989	Activo
68	SALIDA A MOCHIS,  INSTALAR  ENLACE CON PRESIDENTA DURANTE LA MAÑANERA DEL PUEBLO  (DESDE LOS MOCHIS)	2026-03-24 00:00:00	2026-03-24 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SALIDA A MOCHIS,  INSTALAR  ENLACE CON PRESIDENTA DURANTE LA MAÑANERA DEL PUEBLO  (DESDE LOS MOCHIS)	Script de Importación	2026-10-09 19:38:29.895989	Activo
69	ENLACE CON PRESIDENTA DURANTE LA MAÑANERA DEL PUEBLO  (DESDE LOS MOCHIS)                            	2026-03-25 00:00:00	2026-03-25 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	ENLACE CON PRESIDENTA DURANTE LA MAÑANERA DEL PUEBLO  (DESDE LOS MOCHIS)                                          HORA: 6:00am                                                            PRODUCCION:                \nCircuito cerrado a 3 cámaras                \nTransmisión                \nSwitcher                \nProveeduría internet                                        1 antena Starlink                \n              \n2 Monitor de 65"                  (transmision)\n1 Monitor de 40"                \n                \n                                         PERSONAL VPRO: Geo, Cuahutemoc, Hector, Valdez, Carlos, Paco                                                     EXTERNO. Calixto	Script de Importación	2026-10-09 19:38:29.895989	Activo
70	EVENTO DE INAUGURACION DE VIVIENDAS BIENESTAR (EN LOS MOCHIS)                                       	2026-03-25 00:00:00	2026-03-25 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	EVENTO DE INAUGURACION DE VIVIENDAS BIENESTAR (EN LOS MOCHIS)                                               HORA:                                     PRODUCCION:                \nCircuito cerrado a 3 cámaras                 \nTransmisión                \nSwitcher                \nProveeduría internet                             1 antena Starlink                \n2  Monitor de 65" con base a piso (escenario)                               \n                \nKUWA:                \n1 Pantalla led de 3x2m en base a 1m. Altura                                                                          PERSONAL VPRO: Geo, Cuahutemoc, Hector, Valdez, Carlos y Paco                        EXTERNO:  Calixto	Script de Importación	2026-10-09 19:38:29.895989	Activo
71	Jueves Santo	2026-04-02 00:00:00	2026-04-02 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	Jueves Santo	Script de Importación	2026-10-09 19:38:29.895989	Activo
72	Viernes santo	2026-04-03 00:00:00	2026-04-03 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	Viernes santo	Script de Importación	2026-10-09 19:38:29.895989	Activo
73	Sabado de gloria	2026-04-04 00:00:00	2026-04-04 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	Sabado de gloria	Script de Importación	2026-10-09 19:38:29.895989	Activo
74	Domingo de resurrección	2026-04-05 00:00:00	2026-04-05 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	Domingo de resurrección	Script de Importación	2026-10-09 19:38:29.895989	Activo
75	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      P	2026-04-04 00:00:00	2026-04-04 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      Partido: Culiacán-Cd.Obregón                                   ESTUDIO TV:                      Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                               Redes-Cuahutemoc          EXTERNO:                Comentariosta #1   Miguel Lara             Comentarista #2  Ernesto Gutierrez                          Repes-Javier García                                                      EN CAMPO:                           Producción -Manuel                  Redes- Edgar                    EXTERNOS:                                   Camarógrafo#1 Calixto Villa                     Camarógrafo #2 Eduardo Araujo           Camarógrafo#3  Jaime Muro                    Camarógrafo #4  Ignacio García	Script de Importación	2026-10-09 19:38:29.895989	Activo
76	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      P	2026-04-05 00:00:00	2026-04-05 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      Partido: Culiacán-Cd.Obregón                                   ESTUDIO TV:                      Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                               Redes-Cuahutemoc          EXTERNO:                Comentariosta #1  Miguel Lara  Comentarista #2  Ernesto Gutierrez                        Repes-Javier García                        EN CAMPO:                           Producción -Manuel                  Redes- Edgar                    EXTERNOS:    Camarógrafo#1 Calixto Villa                     Camarógrafo #2 Eduardo Araujo           Camarógrafo#3  Jaime Muro                    Camarógrafo #4  Ignacio García	Script de Importación	2026-10-09 19:38:29.895989	Activo
77	VACACIONES ANDREA Y SOFIA	2026-04-09 00:00:00	2026-04-09 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES ANDREA Y SOFIA	Script de Importación	2026-10-09 19:38:29.895989	Activo
78	VACACIONES ANDREA Y SOFIA	2026-04-10 00:00:00	2026-04-10 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES ANDREA Y SOFIA	Script de Importación	2026-10-09 19:38:29.895989	Activo
79	VACACIONES ANDREA Y SOFIA	2026-04-11 00:00:00	2026-04-11 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES ANDREA Y SOFIA	Script de Importación	2026-10-09 19:38:29.895989	Activo
80	LA SEMANERA  en Auditorio                                                                           	2026-04-06 00:00:00	2026-04-06 00:00:00	t	Semanera	#3498db	\N	\N	\N	LA SEMANERA  en Auditorio                                                                                                         Entrada: 06:00am                                                                         Inicia 09:00am                                                CIRCUITO CERRADO A 5 CÁMARAS, STREAMING, LENGUAJE DE SEÑAS     ,                   1 MONITOR DE 40" A PISO          \n                                                                                                                                                            Geo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   Edgar (internet)                                                       Valdez (switcher)                                                                                                                                Carlos (graficos)                                                                                           Hector (Audio)                                                                                                                                                                                                                                                                                                                                                                                    Dany (camara)                                                                 Manuel (cámara)                                                                                                                                                                                                                                   Paco   (camara y tecnico)                                               Gerardo y Osiel    se integran después           Interpretes: Beatriz y Cristina                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              \nCONTRATO NUEVO 2025                                          65 emisiones                                   GES-06/2025-9                                               Extensión de Emision #33	Script de Importación	2026-10-09 19:38:29.895989	Activo
142	NO HUBO SEMANERA	2026-05-25 00:00:00	2026-05-25 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
81	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: GUASAVE                         Partido: Guasa	2026-04-07 00:00:00	2026-04-07 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: GUASAVE                         Partido: Guasave-Los Mochis          ESTUDIO TV:                      Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                             Redes-Cuahutemoc          EXTERNO:                Comentariosta #1  Ricardo Gonzalez                                       Comentarista #2  Ernesto Gutierrez                     Repes-Javier García                               EN CAMPO:                             Producción -Manuel                    Redes- Edgar                    EXTERNOS:                                   Camarógrafo#1    Ivan Martinez                   Camarógrafo #2    Francsico Ayala (pony)                Camarógrafo#3   Cristhian  Soto                     Camarógrafo #4   Martin Miranda	Script de Importación	2026-10-09 19:38:29.895989	Activo
82	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: GUASAVE                         Partido: Guasa	2026-04-08 00:00:00	2026-04-08 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: GUASAVE                         Partido: Guasave-Los Mochis          ESTUDIO TV:                      Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                             Redes-Cuahutemoc          EXTERNO:                Comentariosta #1    Ricardo Gonzalez       Comentarista #2  Ernesto Gutierrez                     Repes-Javier García                               EN CAMPO:                             Producción -Manuel                    Redes- Edgar                    EXTERNOS:                                   Camarógrafo#1    Ivan Martinez                   Camarógrafo #2    Francsico Ayala (pony)                Camarógrafo#3  Cristhian Soto                                  Camarógrafo #4   Martin Miranda	Script de Importación	2026-10-09 19:38:29.895989	Activo
83	ENLACE CON PRESIDENTA DURANTE MAÑANERA DEL PUEBLO, DESDE HOSP. REGIONAL NO.1                        	2026-04-09 00:00:00	2026-04-09 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	ENLACE CON PRESIDENTA DURANTE MAÑANERA DEL PUEBLO, DESDE HOSP. REGIONAL NO.1                             (salón 2do. piso)                       INICIA : 6:00am                                                      2 Cámaras                                   Streaming                                           Switcher                                                   1  Tv de 50" en tripie         Proveeduría internet                         1 antena Starlink	Script de Importación	2026-10-09 19:38:29.895989	Activo
84	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: GUASAVE                         Partido: Guasa	2026-04-10 00:00:00	2026-04-10 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: GUASAVE                         Partido: Guasave-Los Mochis          ESTUDIO TV:                      Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                             Redes-Cuahutemoc          EXTERNO:                Comentariosta #1   Ernesto Gutierrez            Comentarista #2     Miguel Lara                         Repes-Javier García                               EN CAMPO:                             Producción -Manuel                    Redes- Edgar               EXTERNOS:    (de mochis)                                Camarógrafo#1    Ivan Martinez                   Camarógrafo #2    Francsico Ayala (pony)                Camarógrafo#3    Cristina Soto                                  Camarógrafo #4     Martin Miranda	Script de Importación	2026-10-09 19:38:29.895989	Activo
85	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: GUASAVE                         Partido: Guasa	2026-04-11 00:00:00	2026-04-11 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: GUASAVE                         Partido: Guasave-Los Mochis          ESTUDIO TV:                      Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                             Redes-Cuahutemoc          EXTERNO:                Comentariosta #1   Ernesto Gutierrez            Comentarista #2     Miguel Lara                         Repes-Javier García                               EN CAMPO:                             Producción -Manuel                    Redes- Edgar               EXTERNOS:   (De Mochis)                                 Camarógrafo#1    Ivan Martinez                   Camarógrafo #2    Francsico Ayala (pony)                Camarógrafo#3    Ivan Jr.                                  Camarógrafo #4 Leonardo León	Script de Importación	2026-10-09 19:38:29.895989	Activo
86	INSTALACION Y PRUEBAS EN HOSPITAL REGIONAL #1 BINESTAR IMSS  HORA DE INSTALACION:12:00 A 2:00PM    P	2026-04-08 00:00:00	2026-04-08 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTALACION Y PRUEBAS EN HOSPITAL REGIONAL #1 BINESTAR IMSS  HORA DE INSTALACION:12:00 A 2:00PM    PRUEBAS 4:00PM	Script de Importación	2026-10-09 19:38:29.895989	Activo
87	REUNION DE PRESENTACION GOBERNADOR, IMSS BIENESTAR                                        ( Salón en	2026-04-09 00:00:00	2026-04-09 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	REUNION DE PRESENTACION GOBERNADOR, IMSS BIENESTAR                                        ( Salón en 1er. piso )                                                  2 TV de 55" en tripie                                           1 Tv de 55" a piso                                            Switcher                           Proveeduría internet modem	Script de Importación	2026-10-09 19:38:29.895989	Activo
88	VACACIONES ANDREA Y SOFIA	2026-04-13 00:00:00	2026-04-13 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES ANDREA Y SOFIA	Script de Importación	2026-10-09 19:38:29.895989	Activo
89	VACACIONES ANDREA Y SOFIA	2026-04-14 00:00:00	2026-04-14 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES ANDREA Y SOFIA	Script de Importación	2026-10-09 19:38:29.895989	Activo
90	VACACIONES ANDREA Y SOFIA	2026-04-15 00:00:00	2026-04-15 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES ANDREA Y SOFIA	Script de Importación	2026-10-09 19:38:29.895989	Activo
91	VACACIONES ANDREA Y SOFIA	2026-04-16 00:00:00	2026-04-16 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES ANDREA Y SOFIA	Script de Importación	2026-10-09 19:38:29.895989	Activo
92	VACACIONES ANDREA, SOFIA Y OSIEL	2026-04-17 00:00:00	2026-04-17 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES ANDREA, SOFIA Y OSIEL	Script de Importación	2026-10-09 19:38:29.895989	Activo
93	VACACIONES ANDREA, SOFIA Y DANIEL	2026-04-18 00:00:00	2026-04-18 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES ANDREA, SOFIA Y DANIEL	Script de Importación	2026-10-09 19:38:29.895989	Activo
94	NO HUBO SEMANERA	2026-04-13 00:00:00	2026-04-13 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
95	PRUEBAS PARA IEES EN UA DE O  y SACSA EN TEC DE MONTERREY	2026-04-14 00:00:00	2026-04-14 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	PRUEBAS PARA IEES EN UA DE O  y SACSA EN TEC DE MONTERREY	Script de Importación	2026-10-09 19:38:29.895989	Activo
96	GRABACION DE ENTREVISTA: LUIS ALBERTO DIAZ A SACSA, EN TEC DE MONTERREY:                3 cámaras co	2026-04-15 00:00:00	2026-04-15 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	GRABACION DE ENTREVISTA: LUIS ALBERTO DIAZ A SACSA, EN TEC DE MONTERREY:                3 cámaras con grabación independiente                         consola de audio                                       2 micros de solapa y                                        lamparas de  Refuerzo de iluminación.	Script de Importación	2026-10-09 19:38:29.895989	Activo
185	SESION EXTRAORDINARIA VIRTUAL IEES:  Inicia 10:00am en ESTUDIO	2026-07-09 00:00:00	2026-07-09 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SESION EXTRAORDINARIA VIRTUAL IEES:  Inicia 10:00am en ESTUDIO	Script de Importación	2026-10-09 19:38:29.895989	Activo
97	REUNION DE GABINETE DE SEGURIDAD EN HANGAR MILITAR #10 EN AEROPUERTO CULIACAN   PRODUCCION:	2026-04-16 00:00:00	2026-04-16 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	REUNION DE GABINETE DE SEGURIDAD EN HANGAR MILITAR #10 EN AEROPUERTO CULIACAN   PRODUCCION:        \nSALON DE REUNIONES:        \n6 TV de  a piso 65"       \nSwitcher        \nProveeduría de internet        \n1 Antena Satarlink        \n        \nSALA CORONEL:_        \n1 TV de en tripie  65"          Proveeduría de internet        \n1 Antena Satarlink	Script de Importación	2026-10-09 19:38:29.895989	Activo
98	INSTALACIÓN EN HANGAR: REUNION DE GABINETE DE SEGURIDAD EN HANGAR MILITAR #10 EN AEROPUERTO CULIACAN	2026-04-15 00:00:00	2026-04-15 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTALACIÓN EN HANGAR: REUNION DE GABINETE DE SEGURIDAD EN HANGAR MILITAR #10 EN AEROPUERTO CULIACAN	Script de Importación	2026-10-09 19:38:29.895989	Activo
99	VACACIONES ANDREA Y SOFIA	2026-04-21 00:00:00	2026-04-21 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES ANDREA Y SOFIA	Script de Importación	2026-10-09 19:38:29.895989	Activo
100	VACACIONES ANDREA Y SOFIA	2026-04-22 00:00:00	2026-04-22 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES ANDREA Y SOFIA	Script de Importación	2026-10-09 19:38:29.895989	Activo
101	VACACIONES ANDREA Y SOFIA	2026-04-23 00:00:00	2026-04-23 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES ANDREA Y SOFIA	Script de Importación	2026-10-09 19:38:29.895989	Activo
102	VACACIONES ANDREA, SOFIA Y EDUARDO VALDEZ	2026-04-24 00:00:00	2026-04-24 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES ANDREA, SOFIA Y EDUARDO VALDEZ	Script de Importación	2026-10-09 19:38:29.895989	Activo
103	VACACIONES ANDREA, SOFIA Y EDUARDO VALDEZ	2026-04-25 00:00:00	2026-04-25 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES ANDREA, SOFIA Y EDUARDO VALDEZ	Script de Importación	2026-10-09 19:38:29.895989	Activo
104	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      P	2026-04-21 00:00:00	2026-04-21 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      Partido: Culiacán-Guasave                                  ESTUDIO TV:                      Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                               Redes-Cuahutemoc          EXTERNO:                Comentariosta #1   Comentarista #2                          Repes-Javier García                        EN CAMPO:                           Producción -Manuel                  Redes- Edgar                    EXTERNOS:                                   Camarógrafo#1                      Camarógrafo #2                                                     Camarógrafo#3                      Camarógrafo #4	Script de Importación	2026-10-09 19:38:29.895989	Activo
105	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      P	2026-04-22 00:00:00	2026-04-22 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      Partido: Culiacán-Guasave                                  ESTUDIO TV:                      Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                               Redes-Cuahutemoc          EXTERNO:                Comentariosta #1   Comentarista #2                          Repes-Javier García                        EN CAMPO:                           Producción -Manuel                  Redes- Edgar                    EXTERNOS:                                   Camarógrafo#1                      Camarógrafo #2                                                     Camarógrafo#3                      Camarógrafo #4	Script de Importación	2026-10-09 19:38:29.895989	Activo
106	RETORNO DE PERSONAL DE MANZANILLO y CIERRE DE TEMPORADA DE CONFERENCIAS COPPEL	2026-04-24 00:00:00	2026-04-24 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	RETORNO DE PERSONAL DE MANZANILLO y CIERRE DE TEMPORADA DE CONFERENCIAS COPPEL	Script de Importación	2026-10-09 19:38:29.895989	Activo
107	EVENTO DE MORENA EN FIGLOSTASE                               VPRO:                                  	2026-04-25 00:00:00	2026-04-25 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	EVENTO DE MORENA EN FIGLOSTASE                               VPRO:                                     Circuito a 1 cámara                      Switcher                          Computadora                                         METRO:                                    Escenografia y Audio                                                                    2 pantallas led 3x2m	Script de Importación	2026-10-09 19:38:29.895989	Activo
108	INSTALACION PARA EVENTO DE MORENA EN FIGLOSTASE                     HORA:                           	2026-04-24 00:00:00	2026-04-24 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTALACION PARA EVENTO DE MORENA EN FIGLOSTASE                     HORA:                                  VPRO:                                     Circuito a 1 cámara    Switcher                          Computadora                                         METRO:                                    Escenografia y Audio                                                                   2 pantallas led 3x2m	Script de Importación	2026-10-09 19:38:29.895989	Activo
109	TRASLADO DE CAMAROGRAFOS A MANZANILLO	2026-04-21 00:00:00	2026-04-21 00:00:00	t	Gira	#e74c3c	\N	\N	\N	TRASLADO DE CAMAROGRAFOS A MANZANILLO	Script de Importación	2026-10-09 19:38:29.895989	Activo
110	LA SEMANERA  en Auditorio                                                                           	2026-04-22 00:00:00	2026-04-22 00:00:00	t	Semanera	#3498db	\N	\N	\N	LA SEMANERA  en Auditorio                                                                                                         Entrada: 06:00am                                                                         Inicia 09:00am                                                CIRCUITO CERRADO A 5 CÁMARAS, STREAMING, LENGUAJE DE SEÑAS     ,                   1 MONITOR DE 40" A PISO          \n                                                                                                                                                            Geo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   Edgar (internet)                                                       Valdez (switcher)                                                                                                                                Carlos (graficos)                                                                                           Hector (Audio)                                                                                                                                                                                                                                                                                                                                                                                    Dany (camara)                                                                 Manuel (cámara)                                                                                                                                                                                                                                   Paco   (camara y tecnico)                                               Gerardo y Osiel    se integran después           Interpretes:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               \nCONTRATO NUEVO 2025                                          65 emisiones                                   GES-06/2025-9                                               Extensión de Emision #34	Script de Importación	2026-10-09 19:38:29.895989	Activo
111	EVENTO DIF:  "CONMEMORACION DEL DIA INTERNACIONAL DEL LIBRO" en SALON GOBERNADORES: GRABACION DE EVE	2026-04-22 00:00:00	2026-04-22 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	EVENTO DIF:  "CONMEMORACION DEL DIA INTERNACIONAL DEL LIBRO" en SALON GOBERNADORES: GRABACION DE EVENTO: CUENTA CUENTOS:                         Grabación a 3 cámaras                           Switcher(botonera)                            Consola de Audio                                       1 micrófono de Solapa                                                    NOTA: Se grabo independiente cada cámara y se entrego material tambien MASTER switcheado.	Script de Importación	2026-10-09 19:38:29.895989	Activo
112	VACACIONES GEO	2026-04-28 00:00:00	2026-04-28 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES GEO	Script de Importación	2026-10-09 19:38:29.895989	Activo
113	VACACIONES GEO	2026-04-29 00:00:00	2026-04-29 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES GEO	Script de Importación	2026-10-09 19:38:29.895989	Activo
114	VACACIONES GEO	2026-04-30 00:00:00	2026-04-30 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES GEO	Script de Importación	2026-10-09 19:38:29.895989	Activo
140	INSTALACIÓN PREVIA POR LA TARDE DE EVENTO DE ENLACE A PRESIDENCIA DE ISJU	2026-05-21 00:00:00	2026-05-21 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTALACIÓN PREVIA POR LA TARDE DE EVENTO DE ENLACE A PRESIDENCIA DE ISJU	Script de Importación	2026-10-09 19:38:29.895989	Activo
141	INSTITUTO SINALOENSE DE LA JUVENTUD (ISJU)  Evento: Enlace con la Conferencia del Pueblo en la mañan	2026-05-22 00:00:00	2026-05-22 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTITUTO SINALOENSE DE LA JUVENTUD (ISJU)  Evento: Enlace con la Conferencia del Pueblo en la mañanaera de la presidenta Sheinbaum al ISJU.         Transmisión a 2 cámaras   y proveeduría de internet.	Script de Importación	2026-10-09 19:38:29.895989	Activo
115	LA SEMANERA  en Auditorio                                                                           	2026-04-27 00:00:00	2026-04-27 00:00:00	t	Semanera	#3498db	\N	\N	\N	LA SEMANERA  en Auditorio                                                                                                         Entrada: 06:00am                                                                         Inicia 09:00am                                                CIRCUITO CERRADO A 5 CÁMARAS, STREAMING, LENGUAJE DE SEÑAS     ,                   1 MONITOR DE 40" A PISO          \n                                                                                                                                                            Geo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   Edgar (internet)                                                       Valdez (switcher)                                                                                                                                Carlos (graficos)                                                                                           Hector (Audio)                                                                                                                                                                                                                                                                                                                                                                                    Dany (camara)                                                                 Manuel (cámara)                                                                                                                                                                                                                                   Paco   (camara y tecnico)                                               Gerardo    se integra después           Interpretes:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               \nCONTRATO NUEVO 2025                                          65 emisiones                                   GES-06/2025-9                                               Extensión de Emision #35                  (SEMANERA SE GRABO PARA SUBIRLO POSTERIOR A PLATAFORMA, NO SE PUDO TRANSMITIR EN VIVO, FALLA DE EQUIPO)	Script de Importación	2026-10-09 19:38:29.895989	Activo
116	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:                        Locación: MAZATLÁN                	2026-04-28 00:00:00	2026-04-28 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:                        Locación: MAZATLÁN                         Partido: Mazatlán-Cd.Obregón         ESTUDIO TV:                      Switcher- Valdez y Osiel                                    Audio- Hector                       Gráficos- Carlos                             Redes-Cuahutemoc                        EXTERNO:                Comentariosta #1                                Comentarista #2                          Repes-Javier García                               EN CAMPO:                             Producción -Manuel                    Redes- Edgar                    EXTERNOS:  (Maza)                                    Camarógrafo#1                      Camarógrafo #2                          Camarógrafo#3                      Camarógrafo #4	Script de Importación	2026-10-09 19:38:29.895989	Activo
117	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:                        Locación: MAZATLÁN                	2026-04-29 00:00:00	2026-04-29 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:                        Locación: MAZATLÁN                         Partido: Mazatlán-Cd.Obregón         ESTUDIO TV:                      Switcher- Valdez y Osiel                                    Audio- Hector                       Gráficos- Carlos                             Redes-Cuahutemoc                        EXTERNO:                Comentariosta #1                                Comentarista #2                          Repes-Javier García                               EN CAMPO:                             Producción -Manuel                    Redes- Edgar                    EXTERNOS: (Maza)                                     Camarógrafo#1                      Camarógrafo #2                          Camarógrafo#3                      Camarógrafo #4	Script de Importación	2026-10-09 19:38:29.895989	Activo
118	EVENTO  para KUWA: SALON LUCERNA                                             Streaming a 2 cámaras  	2026-04-30 00:00:00	2026-04-30 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	EVENTO  para KUWA: SALON LUCERNA                                             Streaming a 2 cámaras                   SUSPENDIDO HASTA NUEVA FECHA	Script de Importación	2026-10-09 19:38:29.895989	Activo
119	SESION ESPECIAL VIRTUAL IEES:  Inicia 1:00pm en ESTUDIO	2026-04-27 00:00:00	2026-04-27 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SESION ESPECIAL VIRTUAL IEES:  Inicia 1:00pm en ESTUDIO	Script de Importación	2026-10-09 19:38:29.895989	Activo
120	INHABIL	2026-05-01 00:00:00	2026-05-01 00:00:00	t	Inhábil	#95a5a6	\N	\N	\N	INHABIL	Script de Importación	2026-10-09 19:38:29.895989	Activo
121	VACACIONES DANIEL,GEO Y HECTOR	2026-05-02 00:00:00	2026-05-02 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES DANIEL,GEO Y HECTOR	Script de Importación	2026-10-09 19:38:29.895989	Activo
122	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:                        Locación: GUASAVE                 	2026-05-01 00:00:00	2026-05-01 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:                        Locación: GUASAVE                         Partido: Guasave-CDMX          ESTUDIO TV:                                            Switcher- Valdez                                    Audio- Hector                                         Gráficos- Carlos                              Redes-Cuahutemoc                        EXTERNO:                                   Comentariosta #1                                Comentarista #2                          Repes-Javier García                               EN CAMPO:                             Producción -Manuel                    Redes- Edgar                                EXTERNOS:                                   Camarógrafo#1                      Camarógrafo #2	Script de Importación	2026-10-09 19:38:29.895989	Activo
123	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:                        Locación: GUASAVE                 	2026-05-02 00:00:00	2026-05-02 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:                        Locación: GUASAVE                         Partido: Guasave-CDMX          ESTUDIO TV:                                            Switcher- Valdez                                    Audio- Hector                                         Gráficos- Carlos                              Redes-Cuahutemoc                        EXTERNO:                                   Comentariosta #1                                Comentarista #2                          Repes-Javier García                               EN CAMPO:                             Producción -Manuel                    Redes- Edgar                                EXTERNOS:                                   Camarógrafo#1                      Camarógrafo #2	Script de Importación	2026-10-09 19:38:29.895989	Activo
124	NO HUBO SEMANERA	2026-05-04 00:00:00	2026-05-04 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
125	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      P	2026-05-05 00:00:00	2026-05-05 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      Partido: Culiacán-Los Mochis                                  ESTUDIO TV:                      Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                               Redes-Cuahutemoc          EXTERNO:                Comentariosta #1   Comentarista #2                          Repes-Javier García                       EN CAMPO:                       Producción -Manuel                   Redes- Edgar                    EXTERNOS:                                   Camarógrafo#1                      Camarógrafo #2                                        Camarógrafo#3                      Camarógrafo #4	Script de Importación	2026-10-09 19:38:29.895989	Activo
126	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      P	2026-05-06 00:00:00	2026-05-06 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      Partido: Culiacán-Los Mochis                                  ESTUDIO TV:                      Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                               Redes-Cuahutemoc          EXTERNO:                Comentariosta #1   Comentarista #2                          Repes-Javier García                       EN CAMPO:                       Producción -Manuel                   Redes- Edgar                    EXTERNOS:                                   Camarógrafo#1                      Camarógrafo #2                                      Camarógrafo#3                      Camarógrafo #4	Script de Importación	2026-10-09 19:38:29.895989	Activo
127	GES-GIRAS: REUNIÓN PRIVADA DE GABINETE DE SEGURIDA, EN 9NA ZONA MILITAR:  Inicia 9:00am             	2026-05-04 00:00:00	2026-05-04 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GES-GIRAS: REUNIÓN PRIVADA DE GABINETE DE SEGURIDA, EN 9NA ZONA MILITAR:  Inicia 9:00am                           3 Monitores de 65" a piso         Switcher                                                2 laptop para material audiovisual                                   1 antena Starlink para distribuir el internet Wifi a las áreas                   (ellos proporcionaron el internet modem)                                                    Personal: Cuahutemoc, Pedro, Paco y Edgar	Script de Importación	2026-10-09 19:38:29.895989	Activo
128	GIRAS- SECRET. EVENTO: TEATRO MASIN:                             Circuito cerrado a 1 cámara        	2026-05-06 00:00:00	2026-05-06 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS- SECRET. EVENTO: TEATRO MASIN:                             Circuito cerrado a 1 cámara                                   2 Monitores de 55" a piso                                     1 Switcher                                     KUWA:                                                         1  pantalla led de 3x2m.	Script de Importación	2026-10-09 19:38:29.895989	Activo
129	ELEVOX: RUEDA DE PRENSA EN 9NA ZONA MILITAR DE HARFUCH, GABINETE DE SEGURIDAD ....SECRET. DE SEGURID	2026-05-04 00:00:00	2026-05-04 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	ELEVOX: RUEDA DE PRENSA EN 9NA ZONA MILITAR DE HARFUCH, GABINETE DE SEGURIDAD ....SECRET. DE SEGURIDAD Y PROTECCION CIUDADANA:  Horario Inicio: 10.00am                           Circuito cerrado a 3 cámaras                       Streaming                                                 Switcher                                                       4 Monitores de 65"                                                         Proveeduría internet  modem                                      KUWA:                                                                1 Pantalla led de 3x2m                      PERSONAL: Geo, Osiel, Hector, Edgar, Paco, Manuel Daniel, Carlos	Script de Importación	2026-10-09 19:38:29.895989	Activo
130	INSTALACION TEATRO MASIN:                             Circuito cerrado a 1 cámara                   	2026-05-05 00:00:00	2026-05-05 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTALACION TEATRO MASIN:                             Circuito cerrado a 1 cámara                                   2 Monitores de 55" a piso                                     1 Switcher                                     KUWA:                                                         1  pantalla led de 3x2m.	Script de Importación	2026-10-09 19:38:29.895989	Activo
131	INSTALACION  EN 9NA ZONA MILITAR CONMEMORACION DE BATALLA DE PUEBLA Horario 6:0opm                  	2026-05-04 00:00:00	2026-05-04 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTALACION  EN 9NA ZONA MILITAR CONMEMORACION DE BATALLA DE PUEBLA Horario 6:0opm                                             Circuito cerrado a 1 cámara                                                                Switcher                 1 computadora para inserciónn dei magen presidencial                                                  1 Monitores de 65"                                                   2 Monitores de 55"                                                                Proveeduría internet                               1 antena Starlink                                     KUWA:                                                                1 Pantalla led de 3x2m                      PERSONAL: Geo, Osiel, Cuahutemoc Paco, Daniel.	Script de Importación	2026-10-09 19:38:29.895989	Activo
132	VACACIONES HECTOR	2026-05-16 00:00:00	2026-05-16 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES HECTOR	Script de Importación	2026-10-09 19:38:29.895989	Activo
133	NO HUBO SEMANERA	2026-05-11 00:00:00	2026-05-11 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
134	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:                        Locación: MAZATLÁN                	2026-05-12 00:00:00	2026-05-12 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:                        Locación: MAZATLÁN                         Partido: Mazatlán-Torreón         ESTUDIO TV:                      Switcher- Valdez                                    Audio- Hector                       Gráficos- Carlos                             Redes-Cuahutemoc                        EXTERNO:                Comentariosta #1                                Comentarista #2                          Repes-Javier García                               EN CAMPO:                             Producción -Manuel                    Redes- Edgar                    EXTERNOS:                                   Camarógrafo#1                      Camarógrafo #2                                        Camarógrafo#3                     Camarógrafo #4	Script de Importación	2026-10-09 19:38:29.895989	Activo
135	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:                        Locación: MAZATLÁN                	2026-05-13 00:00:00	2026-05-13 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:                        Locación: MAZATLÁN                         Partido: Mazatlán-Torreón         ESTUDIO TV:                      Switcher- Valdez                                    Audio- Hector                       Gráficos- Carlos                             Redes-Cuahutemoc                        EXTERNO:                Comentariosta #1                                Comentarista #2                          Repes-Javier García                               EN CAMPO:                             Producción -Manuel                    Redes- Edgar                    EXTERNOS:                                   Camarógrafo#1                      Camarógrafo #2     Camarógrafo#3                      Camarógrafo #4	Script de Importación	2026-10-09 19:38:29.895989	Activo
136	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán   HORA	2026-05-15 00:00:00	2026-05-15 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán   HORA: 7:30 PM    Partido: Culiacán-Guaymas                                  ESTUDIO TV:                      Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                               Redes-Cuahutemoc          EXTERNO:                Comentariosta #1   Comentarista #2                          Repes-Javier García                       EN CAMPO:                       Producción -Manuel                   Redes- Edgar                    EXTERNOS:                                   Camarógrafo#1                      Camarógrafo #2                     Camarógrafo#3                     Camarógrafo #4	Script de Importación	2026-10-09 19:38:29.895989	Activo
137	CIERRE DE CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Mil	2026-05-16 00:00:00	2026-05-16 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	CIERRE DE CIBACOPA PRODUCCIÓN EN ESTUDIO VIA REMOTA:: Locación: Culiacán, Polideportivo  Juan S. Millán      Partido: Culiacán-Guaymas        hora:7:00pm                          ESTUDIO TV:                      Switcher- Valdez                   Audio- Hector                       Gráficos- Carlos                               Redes-Cuahutemoc          EXTERNO:                Comentariosta #1   Comentarista #2                          Repes-Javier García                       EN CAMPO:                       Producción -Manuel                   Redes- Edgar                    EXTERNOS:                                   Camarógrafo#1                      Camarógrafo #2    Camarógrafo#3                      Camarógrafo #4	Script de Importación	2026-10-09 19:38:29.895989	Activo
143	ENLACE : INFORME PRESIDENCIAL "RENDICION DE CUENTAS" DE Dra. Claudia Sheinbaum en explanada de palac	2026-05-31 00:00:00	2026-05-31 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	ENLACE : INFORME PRESIDENCIAL "RENDICION DE CUENTAS" DE Dra. Claudia Sheinbaum en explanada de palacio de Gobierno.                              PRODUCCIÓN:                \n3 cámaras                \nStreaming                \nProveeduría dei nternet                \n1 antena starlink                \nVmix                \ncomputadora exclusiva para WEBEX                \nConsola de audio                \nBotonera para cambios en pantalla y material                          Vuelo de Dron                                   \n                                     \nENTRADA AL AIRE 1ER BLOCKE : 8:00am Hora Pacifico                                \n    / 9:00am Hora CDMX        \nAL TERMINO DEL ENLACE SE SOLICITO:  CONTINUAR CON CIRCUITO CERRADO Y GRABACION.	Script de Importación	2026-10-09 19:38:29.895989	Activo
144	ELEVOX: Museo Centenario.                         Instalacion de 2 monitore de 65" Hora:12:00am	2026-06-01 00:00:00	2026-06-01 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	ELEVOX: Museo Centenario.                         Instalacion de 2 monitore de 65" Hora:12:00am	Script de Importación	2026-10-09 19:38:29.895989	Activo
145	ELEVOX: Evento en Museo Centenario.    Hora:                         2 monitores de 65"	2026-06-02 00:00:00	2026-06-02 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	ELEVOX: Evento en Museo Centenario.    Hora:                         2 monitores de 65"	Script de Importación	2026-10-09 19:38:29.895989	Activo
146	ELEVOX: Evento en Museo Centenario.    Hora:                         2 monitore sde 65"	2026-06-03 00:00:00	2026-06-03 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	ELEVOX: Evento en Museo Centenario.    Hora:                         2 monitore sde 65"	Script de Importación	2026-10-09 19:38:29.895989	Activo
147	IEES, SESION EXTRAORDINARIA VIRTUAL (estudio)                                          Hora: 2:00pm	2026-06-04 00:00:00	2026-06-04 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	IEES, SESION EXTRAORDINARIA VIRTUAL (estudio)                                          Hora: 2:00pm	Script de Importación	2026-10-09 19:38:29.895989	Activo
148	DESCANSO PARA PERSONAL QUE LABORO DOMINGO EN ENLACE PRESIDENCIAL.  Geo, Manuel, Osiel, Cuahutemoc, P	2026-06-01 00:00:00	2026-06-01 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	DESCANSO PARA PERSONAL QUE LABORO DOMINGO EN ENLACE PRESIDENCIAL.  Geo, Manuel, Osiel, Cuahutemoc, Paco, Daniel y Gerardo.	Script de Importación	2026-10-09 19:38:29.895989	Activo
149	SALIDA: 6am    A MAZATLAN PARA SCOUNTING HOTEL EL CID , COTIZ. CONVENCIONES CESAVESIN   Personal: Pe	2026-06-03 00:00:00	2026-06-03 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SALIDA: 6am    A MAZATLAN PARA SCOUNTING HOTEL EL CID , COTIZ. CONVENCIONES CESAVESIN   Personal: Pedro, gerardo, Geo yPaco	Script de Importación	2026-10-09 19:38:29.895989	Activo
150	NO HUBO SEMANERA	2026-06-01 00:00:00	2026-06-01 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
151	NO HUBO SEMANERA	2026-06-08 00:00:00	2026-06-08 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
152	NO HUBO SEMANERA	2026-06-15 00:00:00	2026-06-15 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
153	SAL	2026-06-18 00:00:00	2026-06-18 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SAL	Script de Importación	2026-10-09 19:38:29.895989	Activo
154	GIRAS: evento Estrategia Nacional de Seguridad "Atencion a las causas", Jornadas de PAZ y desarme vo	2026-06-19 00:00:00	2026-06-19 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: evento Estrategia Nacional de Seguridad "Atencion a las causas", Jornadas de PAZ y desarme voluntario, llevado a cabo en  Villa union, Mazatlánsin.                               2 Monitores de 65" en base                    Switcher, proveeduría de internet con modem inalámbrico.       Personal:                                           Osiel                                                Paco	Script de Importación	2026-10-09 19:38:29.895989	Activo
155	VACACIONES CUAHUTEMOC	2026-06-22 00:00:00	2026-06-22 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CUAHUTEMOC	Script de Importación	2026-10-09 19:38:29.895989	Activo
156	VACACIONES CUAHUTEMOC	2026-06-23 00:00:00	2026-06-23 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CUAHUTEMOC	Script de Importación	2026-10-09 19:38:29.895989	Activo
157	NO HUBO SEMANERA	2026-06-22 00:00:00	2026-06-22 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
158	GIRAS: Reunión en Salón Gobernadores Hora:3pm    Streaming a 3 cámaras	2026-06-23 00:00:00	2026-06-23 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: Reunión en Salón Gobernadores Hora:3pm    Streaming a 3 cámaras	Script de Importación	2026-10-09 19:38:29.895989	Activo
159	GIRAS: EVENTOS JORNADAS DE LA PAZ   en Alturas del Sur de                                          P	2026-06-24 00:00:00	2026-06-24 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE LA PAZ   en Alturas del Sur de                                          Proveeduría de internete a 10 stand,                                                        1 antenas starlink	Script de Importación	2026-10-09 19:38:29.895989	Activo
160	GIRAS: EVENTOS JORNADAS DE LA PAZ   en Alturas del Sur de    Proveeduría de internete a 10 stand,   	2026-06-25 00:00:00	2026-06-25 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE LA PAZ   en Alturas del Sur de    Proveeduría de internete a 10 stand,                                           1 antenas starlink	Script de Importación	2026-10-09 19:38:29.895989	Activo
161	GIRAS: EVENTOS JORNADAS DE LA PAZ   en Alturas del Sur de    Proveeduría de internete a 10 stand,   	2026-06-26 00:00:00	2026-06-26 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE LA PAZ   en Alturas del Sur de    Proveeduría de internete a 10 stand,                                                  1 antenas starlink	Script de Importación	2026-10-09 19:38:29.895989	Activo
162	INSTALACION SALON FLORESTA DEL HOTEL EXECUTIVO:          KUWA:  Escenografia de 6x3m mamapra de back	2026-06-27 00:00:00	2026-06-27 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTALACION SALON FLORESTA DEL HOTEL EXECUTIVO:          KUWA:  Escenografia de 6x3m mamapra de back con lona impresa  y altura 60cm. con escaleras laterales y sistema de Audio para capacidad 1000 personas.	Script de Importación	2026-10-09 19:38:29.895989	Activo
163	EVENTO: MORENA ASAMBLEA SALON FLORESTA DEL HOTEL EXECUTIVO:          KUWA:  Escenografia de 6x3m mam	2026-06-28 00:00:00	2026-06-28 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	EVENTO: MORENA ASAMBLEA SALON FLORESTA DEL HOTEL EXECUTIVO:          KUWA:  Escenografia de 6x3m mamapra de back con lona impresa  y altura 60cm. con escaleras laterales y sistema de Audio para capacidad 1000 personas.	Script de Importación	2026-10-09 19:38:29.895989	Activo
164	VACACIONES CUAHUTEMOC	2026-06-29 00:00:00	2026-06-29 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CUAHUTEMOC	Script de Importación	2026-10-09 19:38:29.895989	Activo
165	VACACIONES CUAHUTEMOC	2026-06-30 00:00:00	2026-06-30 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CUAHUTEMOC	Script de Importación	2026-10-09 19:38:29.895989	Activo
166	NO HUBO SEMANERA	2026-06-29 00:00:00	2026-06-29 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
167	Salida a las 11:00am INSTALACION EN MOCHIS EVENTOS GIRAS: ENLACE PRESIDENCIAL A CONFEENCIAS DEL PUEB	2026-06-30 00:00:00	2026-06-30 00:00:00	t	Gira	#e74c3c	\N	\N	\N	Salida a las 11:00am INSTALACION EN MOCHIS EVENTOS GIRAS: ENLACE PRESIDENCIAL A CONFEENCIAS DEL PUEBLO Y EVENTO GOBERNADORA ENTREGA VIVIENDAS DEL BIENESTAR.   Streaming a 3 cámaras y monitores	Script de Importación	2026-10-09 19:38:29.895989	Activo
213	SCAUTING : ENLACE PRESIDECIAL CON AUDITORIO DE AARC	2026-07-30 00:00:00	2026-07-30 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SCAUTING : ENLACE PRESIDECIAL CON AUDITORIO DE AARC	Script de Importación	2026-10-09 19:38:29.895989	Activo
168	GIRAS: CUARTEL MILITAR EL SAUZ:                                               2 tripies para TV	2026-06-29 00:00:00	2026-06-29 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: CUARTEL MILITAR EL SAUZ:                                               2 tripies para TV	Script de Importación	2026-10-09 19:38:29.895989	Activo
169	VACACIONES IBON	2026-07-01 00:00:00	2026-07-01 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES IBON	Script de Importación	2026-10-09 19:38:29.895989	Activo
170	VACACIONES IBON	2026-07-02 00:00:00	2026-07-02 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES IBON	Script de Importación	2026-10-09 19:38:29.895989	Activo
171	VACACIONES IBON	2026-07-03 00:00:00	2026-07-03 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES IBON	Script de Importación	2026-10-09 19:38:29.895989	Activo
172	VACACIONES IBON	2026-07-04 00:00:00	2026-07-04 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES IBON	Script de Importación	2026-10-09 19:38:29.895989	Activo
173	EVENTO #1-GIRAS EN LOS MOCHIS: ENLACE CON PRESIDENCIA DURANTE LA CONFERENCIA DE PRENSA MATUTINA  DEL	2026-07-01 00:00:00	2026-07-01 00:00:00	t	Gira	#e74c3c	\N	\N	\N	EVENTO #1-GIRAS EN LOS MOCHIS: ENLACE CON PRESIDENCIA DURANTE LA CONFERENCIA DE PRENSA MATUTINA  DEL PUEBLO, CON GOBERNADORA  YERALDINE BONILLA     INICIA :06.AM.,      Centro alphabiotico CALM                       Streaming profesional                                        3 cámaras                                     1 cámara fija                                  Switcher                                                2 Monitores de TV de 65"    Proveeduría dei nternet                          1 Antena Starlink                      VPRO:   Geo, Osiel, Daniel, Manuel, Carlos, Edgar  y Paco.	Script de Importación	2026-10-09 19:38:29.895989	Activo
174	GRABACIONES LEY 72 ANIVERSARIO, LUGAR: CEDIS 80                                      1er.ENTREVISTA:	2026-07-02 00:00:00	2026-07-02 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	GRABACIONES LEY 72 ANIVERSARIO, LUGAR: CEDIS 80                                      1er.ENTREVISTA:                 Hora: 8:00am                       Entrevistado: Jesús Roberto Manajarrez Arana (subgerente)                                     2da.ENTREVISTA:                   Hora: 9:30am                                    Entrevistado: Juan Ramón Osuna Chaidez (mecánico)                                         3er.ENTREVISTA:                                    Hora: 11:00am                             Entrevistado: Esteban Ochoa Grande (Surtidor de Vinos)                            4ta.ENTREVISTA:                     Hora: 12:00pm                                   Entrevistado: Heriberto Hdez. Salas (Montacargas)                              LUGAR: TRAFICO/CEDIS 80   5ta.ENTREVISTA:                             Hora: 03:00p m                               Entrevistado: Yarertzi Sanchez Benitez   (Auxiliar RH)                                 6ta.ENTREVISTA:                                  Hora: 4:00pm                            Entrevistado: Jamileth Aguirre Angulo (Chofer)                                        7ma.ENTREVISTA:                                         Hora: 5:00pm                                   Entrevistado: Karina Nava Soria (Empleada de lavado)                           PRODUCCION: Gerardo, Osiel, Carlos y Daniel	Script de Importación	2026-10-09 19:38:29.895989	Activo
175	EVENTO #2: GIRAS-PROGRAMA VIVIENDAS PARA EL BIENESTAR EN LOS MOCHIS CON GOBERNADORA  YERALDINE BONIL	2026-07-01 00:00:00	2026-07-01 00:00:00	t	Gira	#e74c3c	\N	\N	\N	EVENTO #2: GIRAS-PROGRAMA VIVIENDAS PARA EL BIENESTAR EN LOS MOCHIS CON GOBERNADORA  YERALDINE BONILLA           INICIA :11.AM.,                                 Streaming profesional                                        3 cámaras                                                          Switcher                                                8 Monitores de TV de 65"    Proveeduría dei nternet                          1 Antena Starlink                      VPRO:   Geo, Osiel, Daniel, Manuel, Carlos, Edgar  y Paco.	Script de Importación	2026-10-09 19:38:29.895989	Activo
176	VACACIONES IBON	2026-07-06 00:00:00	2026-07-06 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES IBON	Script de Importación	2026-10-09 19:38:29.895989	Activo
177	VACACIONES IBON Y CUAHUTEMOC	2026-07-07 00:00:00	2026-07-07 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES IBON Y CUAHUTEMOC	Script de Importación	2026-10-09 19:38:29.895989	Activo
178	VACACIONES IBON Y CUAHUTEMOC	2026-07-08 00:00:00	2026-07-08 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES IBON Y CUAHUTEMOC	Script de Importación	2026-10-09 19:38:29.895989	Activo
179	VACACIONES IBON	2026-07-09 00:00:00	2026-07-09 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES IBON	Script de Importación	2026-10-09 19:38:29.895989	Activo
180	VACACIONES IBON	2026-07-10 00:00:00	2026-07-10 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES IBON	Script de Importación	2026-10-09 19:38:29.895989	Activo
181	VACACIONES IBON	2026-07-11 00:00:00	2026-07-11 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES IBON	Script de Importación	2026-10-09 19:38:29.895989	Activo
182	NO HUBO SEMANERA	2026-07-06 00:00:00	2026-07-06 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
183	GRABACIONES LEY 72 ANIVERSARIO, LUGAR: FRESH MARKET PRIMAVERA                                     1e	2026-07-07 00:00:00	2026-07-07 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	GRABACIONES LEY 72 ANIVERSARIO, LUGAR: FRESH MARKET PRIMAVERA                                     1er.ENTREVISTA:                 Hora: 8:00am                       Entrevistado: Imelda Castañeda López (líder de servicio de cajas)                                     2da.ENTREVISTA:                   Hora: 9:30am                                    Entrevistado: Irma Rocio Rodriguez Zazueta (Barra de cocina)                                         3er.ENTREVISTA:                                    Hora: 11:00am                             Entrevistado: Yamileth Guadalupe Cázarez Mendoza (Subjefa de Frutas y verduras))                            4ta.ENTREVISTA:                     Hora: 12:00am                                   Entrevistado: Olivia García Toscano (Empleada Abarrotes)                             LUGAR: FRESH MARKET LAS QUINTAS                  5ta.ENTREVISTA:                             Hora: 03:00p m                               Entrevistado: Edgar Enrique Cebreros Ureta (Simmiter Especialista)                                 6ta.ENTREVISTA:                                  Hora: 4:00pm                            Entrevistado: Irving Emir Urias Chang (Repostero)                                       7ma.ENTREVISTA:                                         Hora: 5:00pm                                   Entrevistado: Francisco José Castro Aguilar (Jefe de control de inventarios)                           PRODUCCION: Gerardo, Osiel, Carlos y Daniel	Script de Importación	2026-10-09 19:38:29.895989	Activo
184	GRABACIONES LEY 72 ANIVERSARIO, LUGAR: LEY SENDERO:                                       UNIDAD SLX	2026-07-08 00:00:00	2026-07-08 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	GRABACIONES LEY 72 ANIVERSARIO, LUGAR: LEY SENDERO:                                       UNIDAD SLX Universitarios:                                     1er.ENTREVISTA:                 Hora: 8:00am                       Entrevistado: Imelda Bonifacia Herrera Hernandez (Empleada de Cocina)                                     2da.ENTREVISTA:                   Hora: 9:00am                                    Entrevistado: Oyuki Yuceli Ceniceros Villa (jefe de panadería)                         UNIDAD: Ley Plaza Culiacán                                  3er.ENTREVISTA:                                    Hora: 10:00am                             Entrevistado: Norma Alicia Peraza Madrid (tablajero de pescado y mariscos)                  UNIDAD: Ley Humaya                    4ta.ENTREVISTA:                     Hora: 11:00am                                   Entrevistado: Jesús Atadeo Celis Media (Jefe de Recibo General)                                      5ta.ENTREVISTA:                             Hora: 12:00p m                               Entrevistado:Elsi Guadalupe Martinez Rojo (administrador del Sirca)                          UNIDAD:Ley Plaza Sur                6ta.ENTREVISTA:                                  Hora: 2:00pm                            Entrevistado: Oscar Martel Zepeeda García (Jefe de Bodega)                                      7ma.ENTREVISTA:                                         Hora: 3:00pm                                   Entrevistado:Fabiola Margarita Zamora Rodriguez (Jefe de Damas)                             UNIDAD: Ley Calzada                8va.ENTREVISTA:                                         Hora: 4:00pm                                   Entrevistado: Carolina Martinez Hdez. (Blanquera)          9na.ENTREVISTA:                                         Hora: 5:00pm                                   Entrevistado:  Nataly Alvarez Rubio (Jefe de higiene y Belleza)                PRODUCCION: Gerardo, osiel, Carlos y Daniel	Script de Importación	2026-10-09 19:38:29.895989	Activo
186	GIRAS: EVENTOS JORNADAS DE LA PAZ   en horario de 8:00am a 2:00pm en                                	2026-07-10 00:00:00	2026-07-10 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE LA PAZ   en horario de 8:00am a 2:00pm en                                           Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antenas starlink	Script de Importación	2026-10-09 19:38:29.895989	Activo
187	GIRAS: EVENTOS JORNADAS DE LA PAZ   en horario de 8:00am a 2:00pm en                                	2026-07-08 00:00:00	2026-07-08 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE LA PAZ   en horario de 8:00am a 2:00pm en                                           Proveeduría de internet y acceso a 10 stand,                                                        1 antenas starlink	Script de Importación	2026-10-09 19:38:29.895989	Activo
188	GIRAS: EVENTOS JORNADAS DE LA PAZ   en horario de 8:00am a 2:00pm en                                	2026-07-09 00:00:00	2026-07-09 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE LA PAZ   en horario de 8:00am a 2:00pm en                                           Proveeduría de internet y acceso a 10 stand,                                                        1 antenas starlink	Script de Importación	2026-10-09 19:38:29.895989	Activo
189	VACACIONES IBON	2026-07-13 00:00:00	2026-07-13 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES IBON	Script de Importación	2026-10-09 19:38:29.895989	Activo
190	VACACIONES IBON	2026-07-14 00:00:00	2026-07-14 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES IBON	Script de Importación	2026-10-09 19:38:29.895989	Activo
191	VACACIONES MANUEL	2026-07-16 00:00:00	2026-07-16 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES MANUEL	Script de Importación	2026-10-09 19:38:29.895989	Activo
192	INCAPACIDAD IBON POR DENGUE	2026-07-18 00:00:00	2026-07-18 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INCAPACIDAD IBON POR DENGUE	Script de Importación	2026-10-09 19:38:29.895989	Activo
193	NO HUBO SEMANERA	2026-07-13 00:00:00	2026-07-13 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
194	SESION EXTRAORDINARIA VIRTUAL IEES:  Inicia 11:00am en ESTUDIO	2026-07-16 00:00:00	2026-07-16 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SESION EXTRAORDINARIA VIRTUAL IEES:  Inicia 11:00am en ESTUDIO	Script de Importación	2026-10-09 19:38:29.895989	Activo
195	INCAPACIDAD IBON POR DENGUE	2026-07-20 00:00:00	2026-07-20 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INCAPACIDAD IBON POR DENGUE	Script de Importación	2026-10-09 19:38:29.895989	Activo
196	INCAPACIDAD IBON POR DENGUE	2026-07-21 00:00:00	2026-07-21 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INCAPACIDAD IBON POR DENGUE	Script de Importación	2026-10-09 19:38:29.895989	Activo
197	INCAPACIDAD IBON POR DENGUE	2026-07-22 00:00:00	2026-07-22 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INCAPACIDAD IBON POR DENGUE	Script de Importación	2026-10-09 19:38:29.895989	Activo
198	INCAPACIDAD IBON POR DENGUE	2026-07-23 00:00:00	2026-07-23 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INCAPACIDAD IBON POR DENGUE	Script de Importación	2026-10-09 19:38:29.895989	Activo
199	INCAPACIDAD IBON POR DENGUE	2026-07-24 00:00:00	2026-07-24 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INCAPACIDAD IBON POR DENGUE	Script de Importación	2026-10-09 19:38:29.895989	Activo
200	ACUDE AL IMSS PARA VER SI CONTINUA INCAPACIDAD IBON O SE DA TERMINO.	2026-07-25 00:00:00	2026-07-25 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	ACUDE AL IMSS PARA VER SI CONTINUA INCAPACIDAD IBON O SE DA TERMINO.	Script de Importación	2026-10-09 19:38:29.895989	Activo
201	NO HUBO SEMANERA	2026-07-20 00:00:00	2026-07-20 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
202	EVENTO. JURIDICO COPPEL EN TORRE PREMIER Hora de inicio 11:00am                            KUWA:  Si	2026-07-21 00:00:00	2026-07-21 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	EVENTO. JURIDICO COPPEL EN TORRE PREMIER Hora de inicio 11:00am                            KUWA:  Sistema de audio capacidad 150 personas                     1 microfono de mano            VPRO: 2 microfonos lavalier	Script de Importación	2026-10-09 19:38:29.895989	Activo
203	GRABACIONES EN AGUASCALIENTES: de video para DEL CAMPO                                        Gerard	2026-07-22 00:00:00	2026-07-22 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	GRABACIONES EN AGUASCALIENTES: de video para DEL CAMPO                                        Gerardo                                               Carlos                                            Daniel	Script de Importación	2026-10-09 19:38:29.895989	Activo
204	RETORNO DE GRABACIONES DE AGUASCALIENTES	2026-07-23 00:00:00	2026-07-23 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	RETORNO DE GRABACIONES DE AGUASCALIENTES	Script de Importación	2026-10-09 19:38:29.895989	Activo
205	GIRAS: EVENTOS JORNADAS DE LA PAZ   en Col. Vista Hermosa                                        Pro	2026-07-24 00:00:00	2026-07-24 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE LA PAZ   en Col. Vista Hermosa                                        Proveeduría de internete a 10 stand,                                                        1 antenas starlink	Script de Importación	2026-10-09 19:38:29.895989	Activo
206	SALIDA :5AM RUMBO A AGUSCALIENTES PARAGABACIONES DEL CAMPO                    VPRO.                 	2026-07-20 00:00:00	2026-07-20 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SALIDA :5AM RUMBO A AGUSCALIENTES PARAGABACIONES DEL CAMPO                    VPRO.                                         Gerardo                                               Carlos                                                    Daniel                                                      Vehiculo Tiida #2	Script de Importación	2026-10-09 19:38:29.895989	Activo
207	GRABACIONES EN AGUASCALIENTES: de video para DEL CAMPO                                        Gerard	2026-07-21 00:00:00	2026-07-21 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	GRABACIONES EN AGUASCALIENTES: de video para DEL CAMPO                                        Gerardo                                               Carlos                                            Daniel	Script de Importación	2026-10-09 19:38:29.895989	Activo
208	GIRAS: EVENTOS JORNADAS DE LA PAZ   en Col. Vista Hermosa                                        Pro	2026-07-22 00:00:00	2026-07-22 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE LA PAZ   en Col. Vista Hermosa                                        Proveeduría de internete a 10 stand,                                                        1 antenas starlink	Script de Importación	2026-10-09 19:38:29.895989	Activo
209	GIRAS: EVENTOS JORNADAS DE LA PAZ   en Col. Vista Hermosa                                        Pro	2026-07-23 00:00:00	2026-07-23 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE LA PAZ   en Col. Vista Hermosa                                        Proveeduría de internete a 10 stand,                                                        1 antenas starlink	Script de Importación	2026-10-09 19:38:29.895989	Activo
210	NO HUBO SEMANERA	2026-07-27 00:00:00	2026-07-27 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
211	GRABACIONES LEY 72 ANIVERSARIO, LUGAR, CENTRO CORPORATIVO LEY       1er.ENTREVISTA:                 	2026-07-28 00:00:00	2026-07-28 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	GRABACIONES LEY 72 ANIVERSARIO, LUGAR, CENTRO CORPORATIVO LEY       1er.ENTREVISTA:                 Hora: 9:00am  \nEntrevistado: Juan Manuel Ley  (hijo)                             PRODUCCION: Gerardo, Osiel, Carlos y Daniel	Script de Importación	2026-10-09 19:38:29.895989	Activo
212	GRABACION COCA-COLA, LUGAR, ESTUDIO VPRO.       Gabación de Testimonios para SKETCH DEL CINE        	2026-07-29 00:00:00	2026-07-29 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	GRABACION COCA-COLA, LUGAR, ESTUDIO VPRO.       Gabación de Testimonios para SKETCH DEL CINE            Hora: 11:00am  \nPRODUCCION: Osiel, Carlos, Daniel Y Andrea.	Script de Importación	2026-10-09 19:38:29.895989	Activo
214	VACACIONES CARLOS	2026-08-04 00:00:00	2026-08-04 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CARLOS	Script de Importación	2026-10-09 19:38:29.895989	Activo
215	VACACIONES CARLOS	2026-08-05 00:00:00	2026-08-05 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CARLOS	Script de Importación	2026-10-09 19:38:29.895989	Activo
216	VACACIONES CARLOS Y OSIEL	2026-08-06 00:00:00	2026-08-06 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CARLOS Y OSIEL	Script de Importación	2026-10-09 19:38:29.895989	Activo
217	VACACIONES, CARLOS, ANA, PEDRO, SOFIA, ANDREA Y DANIEL,	2026-08-07 00:00:00	2026-08-07 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES, CARLOS, ANA, PEDRO, SOFIA, ANDREA Y DANIEL,	Script de Importación	2026-10-09 19:38:29.895989	Activo
218	VACACIONES, CARLOS,  ANA,PEDRO, SOFIA ,ANDREA Y DANIEL,	2026-08-08 00:00:00	2026-08-08 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES, CARLOS,  ANA,PEDRO, SOFIA ,ANDREA Y DANIEL,	Script de Importación	2026-10-09 19:38:29.895989	Activo
219	INSTALACION  3:00PM: ENLACE PRESIDENCIAL CON AUDITORIO DE AARC	2026-08-03 00:00:00	2026-08-03 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTALACION  3:00PM: ENLACE PRESIDENCIAL CON AUDITORIO DE AARC	Script de Importación	2026-10-09 19:38:29.895989	Activo
220	PRIMER AUDITORIA PARA CERTIFICACION ISO 9001-20  VIA REMOTA, EL COMITE DE CALIDAD SE PRESENTA	2026-08-05 00:00:00	2026-08-05 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	PRIMER AUDITORIA PARA CERTIFICACION ISO 9001-20  VIA REMOTA, EL COMITE DE CALIDAD SE PRESENTA	Script de Importación	2026-10-09 19:38:29.895989	Activo
221	DEL CAMPO, GRABACIONES ESPECIALES EN AGUSCALIENTES RANCHO EL ESLABON,                     Grabacione	2026-08-06 00:00:00	2026-08-06 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	DEL CAMPO, GRABACIONES ESPECIALES EN AGUSCALIENTES RANCHO EL ESLABON,                     Grabaciones extras  a zurco de siembra de tomate.                                 Gerardo                                 Paco                                         Tiida #2	Script de Importación	2026-10-09 19:38:29.895989	Activo
222	RETORNO DE AGUASCALIENTES	2026-08-07 00:00:00	2026-08-07 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	RETORNO DE AGUASCALIENTES	Script de Importación	2026-10-09 19:38:29.895989	Activo
223	INSTALACIÓN Y SALIDA A RUMBO A BORABAMPO EVENTO: ENLACE DESDE MAÑANERA CON GOBERNADORA POR PROGRAMA 	2026-08-08 00:00:00	2026-08-08 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTALACIÓN Y SALIDA A RUMBO A BORABAMPO EVENTO: ENLACE DESDE MAÑANERA CON GOBERNADORA POR PROGRAMA SEMBRANDO VIDA  .              salida de oficina 6:00 AM                  VPRO:   Geo, Osiel, Manuel, Cuauhtemóc  y Paco.	Script de Importación	2026-10-09 19:38:29.895989	Activo
224	EVENTO:SEMBRANDO VIDA,  ENLACE DESDE MAÑANERA  CON GOBERNADORA DESDE BORABAMPO, SIN          horario	2026-08-09 00:00:00	2026-08-09 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	EVENTO:SEMBRANDO VIDA,  ENLACE DESDE MAÑANERA  CON GOBERNADORA DESDE BORABAMPO, SIN          horario: llamado 4:30am, pruebas 7:30am, inicia 9:00   Streaming profesional                                        3 cámaras                                     1 cámara fija                                  Switcher                                                1 Monitor de TV de 55"    Proveeduría de internet                          2 Antenas Starlink                      VPRO:   Geo, Osiel, Manuel, Cuauhtemóc  y Paco.	Script de Importación	2026-10-09 19:38:29.895989	Activo
225	NO HUBO SEMANERA	2026-08-03 00:00:00	2026-08-03 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
226	INSTALACION EN DESPACHO GOBERNADOR - 12:30 PM                               VPRO:   Geo, Osiel, Dani	2026-08-04 00:00:00	2026-08-04 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTALACION EN DESPACHO GOBERNADOR - 12:30 PM                               VPRO:   Geo, Osiel, Daniel, Manuel, Cuauhtemoc  y Paco.	Script de Importación	2026-10-09 19:38:29.895989	Activo
227	SALIDA A AGUASCALIENTES RANCHO EL ESLABON, SALIDA 5:00AM                                    Grabacio	2026-08-05 00:00:00	2026-08-05 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SALIDA A AGUASCALIENTES RANCHO EL ESLABON, SALIDA 5:00AM                                    Grabaciones extras y especiales a zurco de siembra de tomate.                                                  Gerardo y Paco                                  Tiida #2	Script de Importación	2026-10-09 19:38:29.895989	Activo
228	GIRAS: EVENTOS JORNADAS DE LA PAZ  En EL RANCHITO  en horario de 8:30am a 2:00pm en                 	2026-08-06 00:00:00	2026-08-06 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE LA PAZ  En EL RANCHITO  en horario de 8:30am a 2:00pm en                                           Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antena starlink                                          Edgar	Script de Importación	2026-10-09 19:38:29.895989	Activo
229	GIRAS: EVENTOS JORNADAS DE LA PAZ  En EL RANCHITO  en horario de 8:30am a 2:00pm en                 	2026-08-07 00:00:00	2026-08-07 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE LA PAZ  En EL RANCHITO  en horario de 8:30am a 2:00pm en                                           Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antena starlink                                          Edgar	Script de Importación	2026-10-09 19:38:29.895989	Activo
230	ENLACE CON PRESIDENCIA CON GOBERNADORES DESDE PALACIO A EN DESPACHO DE GOBERNADOR: Informe  Nacional	2026-08-05 00:00:00	2026-08-05 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	ENLACE CON PRESIDENCIA CON GOBERNADORES DESDE PALACIO A EN DESPACHO DE GOBERNADOR: Informe  Nacional de Gobernadores         Streaming profesional            horario: llamado 4:00am inicia 6:00am                                        3 cámaras                                     Kit de refuerzo de iluminacion                                  Switcher                                 1 Consola de audio para transmision                                               1 Monitor de TV de 50"                        VPRO:   Geo, Osiel, Daniel, Manuel, Cuauhtemoc                    FORD	Script de Importación	2026-10-09 19:38:29.895989	Activo
231	GIRAS: EVENTOS JORNADAS DE LA PAZ  En EL RANCHITO  en horario de 8:00am a 2:00pm en                 	2026-08-05 00:00:00	2026-08-05 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE LA PAZ  En EL RANCHITO  en horario de 8:00am a 2:00pm en                                           Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antena starlink                                          Edgar	Script de Importación	2026-10-09 19:38:29.895989	Activo
232	VACACIONES, CARLOS ANA,PEDRO, SOFIA ,ANDREA Y DANIEL,	2026-08-10 00:00:00	2026-08-10 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES, CARLOS ANA,PEDRO, SOFIA ,ANDREA Y DANIEL,	Script de Importación	2026-10-09 19:38:29.895989	Activo
233	VACACIONES CARLOS	2026-08-11 00:00:00	2026-08-11 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CARLOS	Script de Importación	2026-10-09 19:38:29.895989	Activo
234	2do.CUMPLEAÑOS DE MANUEL	2026-08-13 00:00:00	2026-08-13 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	2do.CUMPLEAÑOS DE MANUEL	Script de Importación	2026-10-09 19:38:29.895989	Activo
235	VACACIONES MANUEL	2026-08-14 00:00:00	2026-08-14 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES MANUEL	Script de Importación	2026-10-09 19:38:29.895989	Activo
236	NO HUBO SEMANERA	2026-08-10 00:00:00	2026-08-10 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
237	SALIDA DE GEO A INSTALACION CESAVESIN, EN MAZATLAN  Hora: 10:00am	2026-08-17 00:00:00	2026-08-17 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SALIDA DE GEO A INSTALACION CESAVESIN, EN MAZATLAN  Hora: 10:00am	Script de Importación	2026-10-09 19:38:29.895989	Activo
238	SALIDA DE GEO A INSTALACION CESAVESIN, EN MAZATLAN	2026-08-18 00:00:00	2026-08-18 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SALIDA DE GEO A INSTALACION CESAVESIN, EN MAZATLAN	Script de Importación	2026-10-09 19:38:29.895989	Activo
239	RETORNO DE EL PERSONAL	2026-08-23 00:00:00	2026-08-23 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	RETORNO DE EL PERSONAL	Script de Importación	2026-10-09 19:38:29.895989	Activo
240	NO HUBO SEMANERA	2026-08-17 00:00:00	2026-08-17 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
241	GIRAS: EVENTOS JORNADAS DE LA PAZ  EN COSTA RICA  en horario de 8:00am a 2:00pm en                  	2026-08-19 00:00:00	2026-08-19 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE LA PAZ  EN COSTA RICA  en horario de 8:00am a 2:00pm en                                           Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antena starlink                                          Cuautemóc	Script de Importación	2026-10-09 19:38:29.895989	Activo
242	GIRAS: EVENTOS JORNADAS DE LA PAZ  EN COSTA RICA  en horario de 8:30am a 2:00pm en                  	2026-08-20 00:00:00	2026-08-20 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE LA PAZ  EN COSTA RICA  en horario de 8:30am a 2:00pm en                                           Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antena starlink                                          Cuautemóc	Script de Importación	2026-10-09 19:38:29.895989	Activo
243	GIRAS: EVENTOS JORNADAS DE LA PAZ  EN COSTA RICA  en horario de 8:30am a 2:00pm en                  	2026-08-21 00:00:00	2026-08-21 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE LA PAZ  EN COSTA RICA  en horario de 8:30am a 2:00pm en                                           Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antena starlink                                          Cuautemóc	Script de Importación	2026-10-09 19:38:29.895989	Activo
244	GIRAS: ENLACE PRESIDENCIAL CON GOBERNADORA, DESPACHO DEL GOBERNADOR   llamado 5:30am                	2026-08-21 00:00:00	2026-08-21 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: ENLACE PRESIDENCIAL CON GOBERNADORA, DESPACHO DEL GOBERNADOR   llamado 5:30am                                            Enlace :10:00am                           Transmisión a 1 cámara                                     1 switcher                                             Consola de audio                                               1 kit de iluminacion                                    1 Monitor de 50" en tripie                              Pedro, Carlos y Cuahutemoc                          SUSPENSION POR CAUSAS AJENAS A NUESTRO SERVICIO: -(presidenta e enfermo y se presento el exgobernador a retomar cargo)	Script de Importación	2026-10-09 19:38:29.895989	Activo
245	VACACIONES GERARDO	2026-08-28 00:00:00	2026-08-28 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES GERARDO	Script de Importación	2026-10-09 19:38:29.895989	Activo
246	VACACIONES GERARDO	2026-08-29 00:00:00	2026-08-29 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES GERARDO	Script de Importación	2026-10-09 19:38:29.895989	Activo
247	NO HUBO SEMANERA	2026-08-24 00:00:00	2026-08-24 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
248	SESION VIRTUAL IEES EN Estudio,  Horario inicio 12:00pm	2026-08-25 00:00:00	2026-08-25 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SESION VIRTUAL IEES EN Estudio,  Horario inicio 12:00pm	Script de Importación	2026-10-09 19:38:29.895989	Activo
249	2DA. AUDITORIA Y TERMINO  PARA CERTIFICACION ISO 9001-20  VIA REMOTA, EL COMITE DE CALIDAD SE PRESEN	2026-08-26 00:00:00	2026-08-26 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	2DA. AUDITORIA Y TERMINO  PARA CERTIFICACION ISO 9001-20  VIA REMOTA, EL COMITE DE CALIDAD SE PRESENTA	Script de Importación	2026-10-09 19:38:29.895989	Activo
250	COBERTURA DE ANIVERSARIO LEY    Entrada 6:00am    Instalación  7:45am   INICIO 9:00am      Circuito 	2026-08-28 00:00:00	2026-08-28 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	COBERTURA DE ANIVERSARIO LEY    Entrada 6:00am    Instalación  7:45am   INICIO 9:00am      Circuito a 3 cámaras y VIDEO COLOR.                                            VPRO: GEO, GERARDO, OSIEL, MANUEL, CARLOS, DANIEL Y PACO	Script de Importación	2026-10-09 19:38:29.895989	Activo
251	2DA. AUDITORIA Y TERMINO  PARA CERTIFICACION ISO 9001-20  VIA REMOTA, EL COMITE DE CALIDAD SE PRESEN	2026-08-25 00:00:00	2026-08-25 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	2DA. AUDITORIA Y TERMINO  PARA CERTIFICACION ISO 9001-20  VIA REMOTA, EL COMITE DE CALIDAD SE PRESENTA	Script de Importación	2026-10-09 19:38:29.895989	Activo
252	NO HUBO SEMANERA	2026-08-31 00:00:00	2026-08-31 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
253	VACACIONES GEO	2026-09-01 00:00:00	2026-09-01 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES GEO	Script de Importación	2026-10-09 19:38:29.895989	Activo
254	VACACIONES GEO	2026-09-02 00:00:00	2026-09-02 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES GEO	Script de Importación	2026-10-09 19:38:29.895989	Activo
255	VACACIONES GEO	2026-09-03 00:00:00	2026-09-03 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES GEO	Script de Importación	2026-10-09 19:38:29.895989	Activo
256	VACACIONES GEO	2026-09-04 00:00:00	2026-09-04 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES GEO	Script de Importación	2026-10-09 19:38:29.895989	Activo
257	VACACIONES GEO	2026-09-05 00:00:00	2026-09-05 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES GEO	Script de Importación	2026-10-09 19:38:29.895989	Activo
258	SALIDA A PRUEBAS EN BADIRAGUATO                           Hora de salida: 9:00 AM                   	2026-09-01 00:00:00	2026-09-01 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SALIDA A PRUEBAS EN BADIRAGUATO                           Hora de salida: 9:00 AM                         Hora de pruebas: 1:00 PM                  SE RETORNAN EL MISMO DIA          VPRO: Manuel, Gerardo y Edgar.                                 Externos: Eduardo Araujo	Script de Importación	2026-10-09 19:38:29.895989	Activo
259	GIRAS: EVENTOS JORNADAS DE  PAZ  LOMA DE RODRIGUERA  en horario de 8:00am a 2:00pm en               	2026-09-02 00:00:00	2026-09-02 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE  PAZ  LOMA DE RODRIGUERA  en horario de 8:00am a 2:00pm en                                           Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antena starlink                                                Personal: Cuauhtemoc	Script de Importación	2026-10-09 19:38:29.895989	Activo
260	GIRAS: EVENTOS JORNADAS DE  PAZ  LOMA DE RODRIGUERA  en horario de 8:00am a 2:00pm en               	2026-09-03 00:00:00	2026-09-03 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE  PAZ  LOMA DE RODRIGUERA  en horario de 8:00am a 2:00pm en                                           Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antena starlink                                                Personal: Cuauhtemoc	Script de Importación	2026-10-09 19:38:29.895989	Activo
261	GIRAS: EVENTOS JORNADAS DE  PAZ  LOMA DE RODRIGUERA  en horario de 8:00am a 2:00pm en               	2026-09-04 00:00:00	2026-09-04 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADAS DE  PAZ  LOMA DE RODRIGUERA  en horario de 8:00am a 2:00pm en                                           Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antena starlink                                                Personal: Cuauhtemoc	Script de Importación	2026-10-09 19:38:29.895989	Activo
262	GIRAS (Eduardo) Instalación 6:30am inicia :10.-00am   Reunión Privada en Salón Gobernadores         	2026-09-06 00:00:00	2026-09-06 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS (Eduardo) Instalación 6:30am inicia :10.-00am   Reunión Privada en Salón Gobernadores                                                 2 Monitores de 65" a piso .                                                 Paco y Daniel	Script de Importación	2026-10-09 19:38:29.895989	Activo
263	VACACIONES GEO	2026-09-07 00:00:00	2026-09-07 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES GEO	Script de Importación	2026-10-09 19:38:29.895989	Activo
264	VACACIONES GEO	2026-09-08 00:00:00	2026-09-08 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES GEO	Script de Importación	2026-10-09 19:38:29.895989	Activo
265	NO HUBO SEMANERA	2026-09-07 00:00:00	2026-09-07 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
266	RETORNO DE BADIRAGUATO Y DESCANSO DE PERSONAL QUE LABORO EN DOMINGO	2026-09-07 00:00:00	2026-09-07 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	RETORNO DE BADIRAGUATO Y DESCANSO DE PERSONAL QUE LABORO EN DOMINGO	Script de Importación	2026-10-09 19:38:29.895989	Activo
267	Grabación JAPAC	2026-09-07 00:00:00	2026-09-07 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	Grabación JAPAC\nSpot Nueva Sucursal\n\nEntrada: 9:00am\n\nGerardo\nDaniel \nCarlos\n\nInició de grabación: 10:00am	Script de Importación	2026-10-09 19:38:29.895989	Activo
268	GIRAS: EVENTOS JORNADA DE  PAZ en Villa Juárez  en horario de 9:00am a 2:00pm en                    	2026-09-09 00:00:00	2026-09-09 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADA DE  PAZ en Villa Juárez  en horario de 9:00am a 2:00pm en                                           Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antena starlink                                                   Personal: Cuauhtemoc	Script de Importación	2026-10-09 19:38:29.895989	Activo
269	GIRAS: EVENTOS JORNADA DE  PAZ en Villa Juárez  en horario de 9:00am a 2:00pm en                    	2026-09-10 00:00:00	2026-09-10 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADA DE  PAZ en Villa Juárez  en horario de 9:00am a 2:00pm en                                           Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antena starlink                                                   Personal: Cuauhtemoc	Script de Importación	2026-10-09 19:38:29.895989	Activo
270	GIRAS: EVENTOS JORNADA DE  PAZ en Villa Juárez  en horario de 9:00am a 2:00pm en                    	2026-09-11 00:00:00	2026-09-11 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADA DE  PAZ en Villa Juárez  en horario de 9:00am a 2:00pm en                                           Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antena starlink                                                   Personal: Cuauhtemoc	Script de Importación	2026-10-09 19:38:29.895989	Activo
271	INSTALACION DE EQUIPO DE PRODUCCION PARA FESTEJOS CULTURALES, ARTISTICOS Y PROTOCOLARIOS DEL GRITO D	2026-09-14 00:00:00	2026-09-14 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	INSTALACION DE EQUIPO DE PRODUCCION PARA FESTEJOS CULTURALES, ARTISTICOS Y PROTOCOLARIOS DEL GRITO DE INDEPENDENCIA EN PALACIO DE GOBIERNO                                                   PRODUCCIÓN VPRO:        \nCircuito a 7 cámaras        \nSistema de transmision inalámbrica        \nDistribución de lineas de internet red        \nPlanta generadora de luz        \nProveeduria dei nternet        \nAntenas starlink        \nVuelo de Dron        \nPisacables        \n2 switcherTripaly para grabación        \ngráficos        \n        \nKUWA:        \nConsola de Audio Yamaha        \nCentro de carga        \nSet de Cableado y extensiones	Script de Importación	2026-10-09 19:38:29.895989	Activo
272	PRODUCCION PARA FESTEJOS CULTURALES, ARTISTICOS Y PROTOCOLARIOS DEL GRITO DE INDEPENDENCIA EN PALACI	2026-09-15 00:00:00	2026-09-15 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	PRODUCCION PARA FESTEJOS CULTURALES, ARTISTICOS Y PROTOCOLARIOS DEL GRITO DE INDEPENDENCIA EN PALACIO DE GOBIERNO                                                   PRODUCCIÓN VPRO:        \nCircuito a 7 cámaras        \nSistema de transmision inalámbrica        \nDistribución de lineas de internet red        \nPlanta generadora de luz        \nProveeduria dei nternet        \nAntenas starlink        \nVuelo de Dron        \nPisacables        \n2 switcherTripaly para grabación        \ngráficos        \n        \nKUWA:        \nConsola de Audio Yamaha        \nCentro de carga        \nSet de Cableado y extensiones	Script de Importación	2026-10-09 19:38:29.895989	Activo
273	DESCANSO LABORAL	2026-09-16 00:00:00	2026-09-16 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	DESCANSO LABORAL	Script de Importación	2026-10-09 19:38:29.895989	Activo
274	VISITA PRESIDENCIAL:2do. INFORME DE PRESIDENCIA SEPROPIES- GIRAS-EDWIN:    Locación: Feria Ganadera 	2026-09-20 00:00:00	2026-09-20 00:00:00	t	Gira	#e74c3c	\N	\N	\N	VISITA PRESIDENCIAL:2do. INFORME DE PRESIDENCIA SEPROPIES- GIRAS-EDWIN:    Locación: Feria Ganadera         Equipo:                                                   2 monitores de 65"                                2 bases  elevada                                  1 Switcher                 dfistribucion de señal para pantallas	Script de Importación	2026-10-09 19:38:29.895989	Activo
275	NO HUBO SEMANERA	2026-09-14 00:00:00	2026-09-14 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
276	GOB.EDO. -GIRAS            ENLACE VIA ZOOM DE GOBERNADORA Y NOTICIERO CANAL 11 :  A LAS 1:00pm      	2026-09-15 00:00:00	2026-09-15 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GOB.EDO. -GIRAS            ENLACE VIA ZOOM DE GOBERNADORA Y NOTICIERO CANAL 11 :  A LAS 1:00pm                                    1 Cámara                                  Transmisión Vía ZOOM                                 Consola de Audio                                        proveed. intgernet modem                                  Refuerzo de  iluminación                              Vmix    1 monitor de 22"                              y 2 computadoras	Script de Importación	2026-10-09 19:38:29.895989	Activo
277	NO HUBO SEMANERA	2026-09-21 00:00:00	2026-09-21 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
278	NO HUBO SEMANERA	2026-09-28 00:00:00	2026-09-28 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
279	SESION EXTRAORDINARIA IEES VIRTUAL EN ESTUDIO Horario 1:00pm                       VPRO: OSIEL Y EDG	2026-09-30 00:00:00	2026-09-30 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SESION EXTRAORDINARIA IEES VIRTUAL EN ESTUDIO Horario 1:00pm                       VPRO: OSIEL Y EDGAR	Script de Importación	2026-10-09 19:38:29.895989	Activo
280	SESION ESPECIAL IEES VIRTUAL EN ESTUDIO Horario :(al término de la extraordinaria)                  	2026-09-30 00:00:00	2026-09-30 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	SESION ESPECIAL IEES VIRTUAL EN ESTUDIO Horario :(al término de la extraordinaria)                                       VPRO: OSIEL Y EDGAR	Script de Importación	2026-10-09 19:38:29.895989	Activo
281	GIRAS: EVENTOS JORNADA DE  PAZ en Campo de futbol aguaruto  en horario de 8:00am a 2:00pm           	2026-09-30 00:00:00	2026-09-30 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADA DE  PAZ en Campo de futbol aguaruto  en horario de 8:00am a 2:00pm                                            Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antena starlink                                                   Personal: Cuauhtemoc	Script de Importación	2026-10-09 19:38:29.895989	Activo
282	GIRAS: EVENTOS JORNADA DE  PAZ en Campo de futbol aguaruto  en horario de 8:30am a 2:00pm           	2026-10-01 00:00:00	2026-10-01 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADA DE  PAZ en Campo de futbol aguaruto  en horario de 8:30am a 2:00pm                                            Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antena starlink                                                   Personal: Cuauhtemoc	Script de Importación	2026-10-09 19:38:29.895989	Activo
283	GIRAS: EVENTOS JORNADA DE  PAZ en Campo de futbol aguaruto  en horario de 8:30am a 2:00pm           	2026-10-02 00:00:00	2026-10-02 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS: EVENTOS JORNADA DE  PAZ en Campo de futbol aguaruto  en horario de 8:30am a 2:00pm                                            Proveeduría de internet y distribución de señal por fibra a 10 stand,                                                        1 antena starlink                                                   Personal: Cuauhtemoc	Script de Importación	2026-10-09 19:38:29.895989	Activo
284	RETORNO DE BADIRAGUATO	2026-10-04 00:00:00	2026-10-04 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	RETORNO DE BADIRAGUATO	Script de Importación	2026-10-09 19:38:29.895989	Activo
285	DIF ESTATAL Evento de Inauguración de Área en CREE                          Entrada: 7:00 AM        	2026-10-05 00:00:00	2026-10-05 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	DIF ESTATAL Evento de Inauguración de Área en CREE                          Entrada: 7:00 AM                          Preparados: 11:00 AM                      VPRO:\n1 Swithcer\n1 TV de 65" a piso\n\nKUWA:\n 1 pantalla led de 3x2m\n\nPERSONAL VPRO:  Osiel y Paco	Script de Importación	2026-10-09 19:38:29.895989	Activo
286	RESTAURANTE CASA BON                          Entrada: 8:30 AM                          Inicio: 11:0	2026-10-06 00:00:00	2026-10-06 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	RESTAURANTE CASA BON                          Entrada: 8:30 AM                          Inicio: 11:00 AM                      VPRO:\n1 Swithcer\n1 TV de 65" a piso\n1 Consola de audio                                        1 microfono de mano                                                 1 Sistema de audio\n\n\nPERSONAL VPRO:  Osiel,  Paco y Daniel	Script de Importación	2026-10-09 19:38:29.895989	Activo
287	SALIDA :  llamado 3:00pm  TRASLADO E INSTALACION:      GIRAS- EVENTO  Ayuntamiento de Escuinapa     	2026-10-08 00:00:00	2026-10-08 00:00:00	t	Gira	#e74c3c	\N	\N	\N	SALIDA :  llamado 3:00pm  TRASLADO E INSTALACION:      GIRAS- EVENTO  Ayuntamiento de Escuinapa        4 monitores de 65" a piso          1 Switcher              Personal:  Osiel, Paco y Daniel	Script de Importación	2026-10-09 19:38:29.895989	Activo
288	GIRAS- EVENTO  Ayuntamiento de Escuinapa    Inicia : 9am                            4 monitores de 6	2026-10-09 00:00:00	2026-10-09 00:00:00	t	Gira	#e74c3c	\N	\N	\N	GIRAS- EVENTO  Ayuntamiento de Escuinapa    Inicia : 9am                            4 monitores de 65" a piso                            1 Switcher                                                            Personal:  Osiel, Paco y Daniel	Script de Importación	2026-10-09 19:38:29.895989	Activo
289	RETORNO DE BADIRAGUATO	2026-10-11 00:00:00	2026-10-11 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	RETORNO DE BADIRAGUATO	Script de Importación	2026-10-09 19:38:29.895989	Activo
290	NO HUBO SEMANERA	2026-10-05 00:00:00	2026-10-05 00:00:00	t	Semanera	#3498db	\N	\N	\N	NO HUBO SEMANERA	Script de Importación	2026-10-09 19:38:29.895989	Activo
291	RETORNO DE BADIRAGUATO	2026-10-17 00:00:00	2026-10-17 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	RETORNO DE BADIRAGUATO	Script de Importación	2026-10-09 19:38:29.895989	Activo
292	VACACIONES CARLOS	2026-10-29 00:00:00	2026-10-29 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CARLOS	Script de Importación	2026-10-09 19:38:29.895989	Activo
293	VACACIONES CARLOS	2026-10-30 00:00:00	2026-10-30 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CARLOS	Script de Importación	2026-10-09 19:38:29.895989	Activo
294	VACACIONES CARLOS	2026-10-31 00:00:00	2026-10-31 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CARLOS	Script de Importación	2026-10-09 19:38:29.895989	Activo
295	RETORNO DE BADIRAGUATO	2026-10-30 00:00:00	2026-10-30 00:00:00	t	Eventos	#2ecc71	\N	\N	\N	RETORNO DE BADIRAGUATO	Script de Importación	2026-10-09 19:38:29.895989	Activo
296	VACACIONES CARLOS	2026-11-02 00:00:00	2026-11-02 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CARLOS	Script de Importación	2026-10-09 19:38:29.895989	Activo
297	VACACIONES CARLOS	2026-11-03 00:00:00	2026-11-03 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CARLOS	Script de Importación	2026-10-09 19:38:29.895989	Activo
298	VACACIONES CARLOS	2026-11-04 00:00:00	2026-11-04 00:00:00	t	Vacaciones	#f39c12	\N	\N	\N	VACACIONES CARLOS	Script de Importación	2026-10-09 19:38:29.895989	Activo
\.


--
-- Data for Name: rh_capacitacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rh_capacitacion (id_capacitacion, id_empleado, nombre_curso, tipo, institucion, fecha_inicio, fecha_fin, horas_duracion, resultado, calificacion, tiene_constancia, constancia_url, costo, pagado_por_empresa, observaciones, registrado_por, fecha_registro) FROM stdin;
\.


--
-- Data for Name: rh_contratos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rh_contratos (id_contrato, id_empleado, folio_contrato, tipo_contrato, fecha_inicio, fecha_fin, es_indefinido, puesto_contratado, departamento, salario_mensual, dias_vacaciones_anuales, jornada, horario, clausulas_especiales, archivo_contrato_url, firmado_empleado, firmado_empresa, fecha_firma, estatus_contrato, renovacion_de, observaciones, registrado_por, fecha_registro) FROM stdin;
\.


--
-- Data for Name: rh_documentos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rh_documentos (id_documento, id_empleado, tipo_documento, nombre_archivo, archivo_url, formato, fecha_emision, fecha_vencimiento, esta_vigente, verificado_por_rh, observaciones, subido_por, fecha_subida) FROM stdin;
\.


--
-- Data for Name: rh_entrevistas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rh_entrevistas (id_entrevista, id_solicitud, id_empleado, tipo_entrevista, fecha_entrevista, hora_inicio, hora_fin, entrevistador, modalidad, link_videollamada, resultado, calificacion_general, puntualidad, presentacion, conocimientos_tecnicos, actitud, comunicacion, comentarios, recomendacion, archivo_prueba_url, registrado_por, fecha_registro) FROM stdin;
\.


--
-- Data for Name: rh_evaluaciones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rh_evaluaciones (id_evaluacion, id_empleado, periodo, tipo, evaluador, puesto_evaluador, puntualidad, calidad_trabajo, trabajo_equipo, responsabilidad, iniciativa, comunicacion, cumplimiento_objetivos, calificacion_final, nivel_desempeno, fortalezas, areas_mejora, plan_accion, comentarios_empleado, firma_empleado, archivo_evaluacion_url, registrado_por, fecha_registro) FROM stdin;
\.


--
-- Data for Name: rh_historial; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rh_historial (id_historial, id_empleado, fecha_evento, tipo_evento, descripcion, datos_anteriores, datos_nuevos, referencia_tabla, referencia_id, registrado_por, es_automatico) FROM stdin;
1	201	2026-10-05 18:57:13.938479	ACTUALIZACION_DATOS	Actualización de datos: nombre, depto, email, cel, rfc, curp, nss, estado_civil, domicilio, ciudad, cp, contacto_emergencia, tel_emergencia, parentesco_emergencia, escolaridad, puesto, tipo_contrato, salario_mensual, estatus_empleado	\N	\N	empleados	201	SISTEMA	t
2	201	2026-10-08 11:37:46.528559	ACTUALIZACION_DATOS	Actualización de datos: nombre, depto, email, cel, rfc, curp, nss, estado_civil, domicilio, ciudad, cp, contacto_emergencia, tel_emergencia, parentesco_emergencia, escolaridad, puesto, tipo_contrato, salario_mensual, estatus_empleado	\N	\N	empleados	201	SISTEMA	t
3	201	2026-10-08 11:38:15.678649	ACTUALIZACION_DATOS	Actualización de datos: nombre, depto, email, cel, rfc, curp, nss, estado_civil, domicilio, ciudad, cp, contacto_emergencia, tel_emergencia, parentesco_emergencia, escolaridad, puesto, tipo_contrato, salario_mensual, estatus_empleado	\N	\N	empleados	201	SISTEMA	t
4	118	2026-10-08 13:58:21.459777	ACTUALIZACION_DATOS	Actualización de datos: nombre, depto, email, cel, rfc, curp, nss, estado_civil, domicilio, ciudad, cp, contacto_emergencia, tel_emergencia, parentesco_emergencia, escolaridad, puesto, tipo_contrato, salario_mensual, estatus_empleado	\N	\N	empleados	118	SISTEMA	t
5	118	2026-10-08 14:04:10.375251	ACTUALIZACION_DATOS	Actualización de datos: nombre, depto, email, cel, rfc, curp, nss, estado_civil, domicilio, ciudad, cp, contacto_emergencia, tel_emergencia, parentesco_emergencia, escolaridad, puesto, tipo_contrato, salario_mensual, estatus_empleado	\N	\N	empleados	118	SISTEMA	t
7	201	2026-10-08 14:09:15.333036	SOLICITUD_VACACIONES	Periodo 2026-10-08 a 2026-10-15	\N	\N	rh_vacaciones	1	Cuauhtemoc Rivera Agundez	t
\.


--
-- Data for Name: rh_incapacidades; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rh_incapacidades (id_incapacidad, id_empleado, folio_incapacidad, tipo, fecha_inicio, fecha_fin, dias_incapacidad, numero_imss, medico_tratante, diagnostico, porcentaje_pago_imss, archivo_incapacidad_url, estatus, validado_por_rh, fecha_validacion, observaciones, registrado_por, fecha_registro) FROM stdin;
\.


--
-- Data for Name: rh_permisos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rh_permisos (id_permiso, id_empleado, folio_permiso, tipo_permiso, fecha_solicitud, fecha_inicio, fecha_fin, dias_solicitados, con_goce_de_sueldo, justificacion, archivo_justificante, estatus, aprobado_por, fecha_aprobacion, motivo_rechazo, impacta_asistencia, observaciones_rh, registrado_por, fecha_registro) FROM stdin;
\.


--
-- Data for Name: rh_solicitudes_empleo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rh_solicitudes_empleo (id_solicitud, folio, fecha_solicitud, nombre_completo, email, tel_celular, fecha_nac, rfc, curp, domicilio, escolaridad, carrera_especialidad, cedula_profesional, puesto_solicitado, depto_solicitado, experiencia_anios, experiencia_descripcion, habilidades, pretension_salarial, como_se_entero, referido_por, disponibilidad_inmediata, fecha_disponible, tiene_auto, tiene_licencia, cv_url, estatus, observaciones_rh, id_empleado_resultado, creado_por, fecha_creacion) FROM stdin;
\.


--
-- Data for Name: rh_vacaciones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rh_vacaciones (id_vacacion, id_empleado, anio_periodo, dias_correspondientes, dias_tomados, dias_pendientes, fecha_inicio_goce, fecha_fin_goce, fecha_limite_goce, tipo, estatus, aprobado_por, fecha_aprobacion, notificado_admon, fecha_notif_admon, observaciones, registrado_por, fecha_registro) FROM stdin;
1	201	2026	20	8	12	2026-10-08	2026-10-15	\N	PERIODO CONTINUO	APROBADO	\N	\N	f	\N	Disfrute fraccionado a solicitud del colaborador	Cuauhtemoc Rivera Agundez	2026-10-08 14:09:15.333036
\.


--
-- Name: archivos_compartidos_id_transferencia_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.archivos_compartidos_id_transferencia_seq', 186, true);


--
-- Name: asistencia_eventos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.asistencia_eventos_id_seq', 1, false);


--
-- Name: control_asistencia_id_registro_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.control_asistencia_id_registro_seq', 498, true);


--
-- Name: control_horas_extras_id_autorizacion_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.control_horas_extras_id_autorizacion_seq', 8, true);


--
-- Name: cronogramas_eventos_id_cronograma_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cronogramas_eventos_id_cronograma_seq', 1, false);


--
-- Name: departamentos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.departamentos_id_seq', 5, true);


--
-- Name: log_accesos_id_log_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.log_accesos_id_log_seq', 96, true);


--
-- Name: op_agenda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.op_agenda_id_seq', 298, true);


--
-- Name: rh_capacitacion_id_capacitacion_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rh_capacitacion_id_capacitacion_seq', 1, false);


--
-- Name: rh_contratos_id_contrato_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rh_contratos_id_contrato_seq', 1, false);


--
-- Name: rh_documentos_id_documento_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rh_documentos_id_documento_seq', 1, false);


--
-- Name: rh_entrevistas_id_entrevista_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rh_entrevistas_id_entrevista_seq', 1, false);


--
-- Name: rh_evaluaciones_id_evaluacion_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rh_evaluaciones_id_evaluacion_seq', 1, false);


--
-- Name: rh_historial_id_historial_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rh_historial_id_historial_seq', 7, true);


--
-- Name: rh_incapacidades_id_incapacidad_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rh_incapacidades_id_incapacidad_seq', 1, false);


--
-- Name: rh_permisos_id_permiso_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rh_permisos_id_permiso_seq', 1, false);


--
-- Name: rh_solicitudes_empleo_id_solicitud_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rh_solicitudes_empleo_id_solicitud_seq', 1, false);


--
-- Name: rh_vacaciones_id_vacacion_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rh_vacaciones_id_vacacion_seq', 1, true);


--
-- Name: archivos_compartidos archivos_compartidos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.archivos_compartidos
    ADD CONSTRAINT archivos_compartidos_pkey PRIMARY KEY (id_transferencia);


--
-- Name: asistencia_eventos asistencia_eventos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asistencia_eventos
    ADD CONSTRAINT asistencia_eventos_pkey PRIMARY KEY (id);


--
-- Name: control_asistencia control_asistencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_asistencia
    ADD CONSTRAINT control_asistencia_pkey PRIMARY KEY (id_registro);


--
-- Name: control_horas_extras control_horas_extras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_horas_extras
    ADD CONSTRAINT control_horas_extras_pkey PRIMARY KEY (id_autorizacion);


--
-- Name: cronogramas_eventos cronogramas_eventos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cronogramas_eventos
    ADD CONSTRAINT cronogramas_eventos_pkey PRIMARY KEY (id_cronograma);


--
-- Name: departamentos departamentos_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_nombre_key UNIQUE (nombre);


--
-- Name: departamentos departamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_pkey PRIMARY KEY (id);


--
-- Name: log_accesos log_accesos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_accesos
    ADD CONSTRAINT log_accesos_pkey PRIMARY KEY (id_log);


--
-- Name: op_agenda op_agenda_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.op_agenda
    ADD CONSTRAINT op_agenda_pkey PRIMARY KEY (id);


--
-- Name: rh_capacitacion rh_capacitacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_capacitacion
    ADD CONSTRAINT rh_capacitacion_pkey PRIMARY KEY (id_capacitacion);


--
-- Name: rh_contratos rh_contratos_folio_contrato_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_contratos
    ADD CONSTRAINT rh_contratos_folio_contrato_key UNIQUE (folio_contrato);


--
-- Name: rh_contratos rh_contratos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_contratos
    ADD CONSTRAINT rh_contratos_pkey PRIMARY KEY (id_contrato);


--
-- Name: rh_documentos rh_documentos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_documentos
    ADD CONSTRAINT rh_documentos_pkey PRIMARY KEY (id_documento);


--
-- Name: rh_entrevistas rh_entrevistas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_entrevistas
    ADD CONSTRAINT rh_entrevistas_pkey PRIMARY KEY (id_entrevista);


--
-- Name: rh_evaluaciones rh_evaluaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_evaluaciones
    ADD CONSTRAINT rh_evaluaciones_pkey PRIMARY KEY (id_evaluacion);


--
-- Name: rh_historial rh_historial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_historial
    ADD CONSTRAINT rh_historial_pkey PRIMARY KEY (id_historial);


--
-- Name: rh_incapacidades rh_incapacidades_folio_incapacidad_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_incapacidades
    ADD CONSTRAINT rh_incapacidades_folio_incapacidad_key UNIQUE (folio_incapacidad);


--
-- Name: rh_incapacidades rh_incapacidades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_incapacidades
    ADD CONSTRAINT rh_incapacidades_pkey PRIMARY KEY (id_incapacidad);


--
-- Name: rh_permisos rh_permisos_folio_permiso_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_permisos
    ADD CONSTRAINT rh_permisos_folio_permiso_key UNIQUE (folio_permiso);


--
-- Name: rh_permisos rh_permisos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_permisos
    ADD CONSTRAINT rh_permisos_pkey PRIMARY KEY (id_permiso);


--
-- Name: rh_solicitudes_empleo rh_solicitudes_empleo_folio_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_solicitudes_empleo
    ADD CONSTRAINT rh_solicitudes_empleo_folio_key UNIQUE (folio);


--
-- Name: rh_solicitudes_empleo rh_solicitudes_empleo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_solicitudes_empleo
    ADD CONSTRAINT rh_solicitudes_empleo_pkey PRIMARY KEY (id_solicitud);


--
-- Name: rh_vacaciones rh_vacaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_vacaciones
    ADD CONSTRAINT rh_vacaciones_pkey PRIMARY KEY (id_vacacion);


--
-- Name: control_asistencia uq_empleado_fecha; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_asistencia
    ADD CONSTRAINT uq_empleado_fecha UNIQUE (id_empleado, fecha);


--
-- Name: empleados vpro_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT vpro_pkey PRIMARY KEY (id_empleado);


--
-- Name: idx_archivos_destino; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_archivos_destino ON public.archivos_compartidos USING btree (id_empleado_destino);


--
-- Name: idx_archivos_estatus; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_archivos_estatus ON public.archivos_compartidos USING btree (estatus);


--
-- Name: idx_archivos_origen; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_archivos_origen ON public.archivos_compartidos USING btree (id_empleado_origen);


--
-- Name: idx_archivos_paquete; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_archivos_paquete ON public.archivos_compartidos USING btree (folio_paquete);


--
-- Name: idx_rh_contratos_empleado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rh_contratos_empleado ON public.rh_contratos USING btree (id_empleado);


--
-- Name: idx_rh_contratos_estatus; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rh_contratos_estatus ON public.rh_contratos USING btree (estatus_contrato);


--
-- Name: idx_rh_historial_empleado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rh_historial_empleado ON public.rh_historial USING btree (id_empleado);


--
-- Name: idx_rh_historial_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rh_historial_tipo ON public.rh_historial USING btree (tipo_evento);


--
-- Name: idx_rh_incap_empleado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rh_incap_empleado ON public.rh_incapacidades USING btree (id_empleado);


--
-- Name: idx_rh_permisos_empleado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rh_permisos_empleado ON public.rh_permisos USING btree (id_empleado);


--
-- Name: idx_rh_permisos_estatus; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rh_permisos_estatus ON public.rh_permisos USING btree (estatus);


--
-- Name: idx_rh_solicitudes_estatus; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rh_solicitudes_estatus ON public.rh_solicitudes_empleo USING btree (estatus);


--
-- Name: idx_rh_vacaciones_empleado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rh_vacaciones_empleado ON public.rh_vacaciones USING btree (id_empleado);


--
-- Name: control_asistencia fk_empleado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_asistencia
    ADD CONSTRAINT fk_empleado FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado) ON DELETE CASCADE;


--
-- Name: rh_contratos fk_renovacion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_contratos
    ADD CONSTRAINT fk_renovacion FOREIGN KEY (renovacion_de) REFERENCES public.rh_contratos(id_contrato);


--
-- Name: rh_capacitacion rh_capacitacion_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_capacitacion
    ADD CONSTRAINT rh_capacitacion_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_contratos rh_contratos_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_contratos
    ADD CONSTRAINT rh_contratos_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_documentos rh_documentos_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_documentos
    ADD CONSTRAINT rh_documentos_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_entrevistas rh_entrevistas_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_entrevistas
    ADD CONSTRAINT rh_entrevistas_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_entrevistas rh_entrevistas_id_solicitud_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_entrevistas
    ADD CONSTRAINT rh_entrevistas_id_solicitud_fkey FOREIGN KEY (id_solicitud) REFERENCES public.rh_solicitudes_empleo(id_solicitud);


--
-- Name: rh_evaluaciones rh_evaluaciones_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_evaluaciones
    ADD CONSTRAINT rh_evaluaciones_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_historial rh_historial_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_historial
    ADD CONSTRAINT rh_historial_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_incapacidades rh_incapacidades_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_incapacidades
    ADD CONSTRAINT rh_incapacidades_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_permisos rh_permisos_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_permisos
    ADD CONSTRAINT rh_permisos_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_solicitudes_empleo rh_solicitudes_empleo_id_empleado_resultado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_solicitudes_empleo
    ADD CONSTRAINT rh_solicitudes_empleo_id_empleado_resultado_fkey FOREIGN KEY (id_empleado_resultado) REFERENCES public.empleados(id_empleado);


--
-- Name: rh_vacaciones rh_vacaciones_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rh_vacaciones
    ADD CONSTRAINT rh_vacaciones_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- PostgreSQL database dump complete
--

\unrestrict 4RINXQt4VxDH7ZPJeIm58asgEfgiywEFsoEfzeodpqz60MsCGqIAQ90VbjnAn5Z

