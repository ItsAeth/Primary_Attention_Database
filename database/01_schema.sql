/*
BASE DE DATOS PARA SISTEMA DE INFORMACIÓN DE UN CENTRO DE ATENCIÓN PRIMARIA (PostgreSQL v18)
/*
EMPLEADOS (personal sanitario y no sanitario)
	- Considera posibilidad de DNI/NIE duplicado y email compartidos.
	- ZZZ indica país de nacimiento desconocido.
*/
CREATE TABLE IF NOT EXISTS empleados (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tipo_id TEXT NOT NULL,
	num_id TEXT NOT NULL,
	nombre TEXT NOT NULL,
	apellido1 TEXT NOT NULL,
	apellido2 TEXT,
	fecha_nacimiento DATE NOT NULL,
	sexo TEXT NOT NULL,
	email TEXT,
	pais_nac TEXT DEFAULT 'ZZZ' NOT NULL,
	reside_cp TEXT NOT NULL,
	reside_muni TEXT NOT NULL
);

/* 
Teléfonos móviles de empleados. Formato con E.164 estricto (Ej. +34612345678)
*/
CREATE TABLE IF NOT EXISTS tlf_empleados (
	id_tlf BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_empleado BIGINT NOT NULL,
	num_tlf TEXT NOT NULL,

	FOREIGN KEY (id_empleado) REFERENCES empleados(id)
);

-- Información especifica de empleados sanitarios.
CREATE TABLE IF NOT EXISTS info_sanitarios (
	id_empleado BIGINT PRIMARY KEY, -- FK
	cias TEXT NOT NULL,
	num_colegiado TEXT NOT NULL ,
	especialidad TEXT NOT NULL,

	FOREIGN KEY (id_empleado) REFERENCES empleados(id)
);

/* 
Turnos (fichaje) de todo el personal del centro). 
	- Turnos ordinarios o guardias.
	- Se registra cuando el empleado ficha para entrar y para salir.
*/
CREATE TABLE IF NOT EXISTS turnos(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_empleado BIGINT NOT NULL,
	tipo_turno TEXT NOT NULL,
	inicio TIMESTAMPTZ NOT NULL,
	fin TIMESTAMPTZ NOT NULL,

	FOREIGN KEY (id_empleado) REFERENCES empleados (id)
);

/* 
Pacientes
	CIP autonómico y nº de historia clínica varian entre comunidades.
	Se considera que los pacientes pueden compartir email o no tenerlo.
	Los pacientes pueden no tener NASS.
*/
CREATE TABLE IF NOT EXISTS pacientes (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tipo_id TEXT NOT NULL,
	num_id TEXT NOT NULL,
	nombre TEXT NOT NULL,
	apellido1 TEXT NOT NULL,
	apellido2 TEXT,
	fecha_nacimiento DATE NOT NULL,
	sexo TEXT NOT NULL,
	email TEXT,
	pais_nac TEXT DEFAULT 'ZZZ' NOT NULL,
	reside_cp TEXT NOT NULL,
	reside_muni TEXT NOT NULL,
	cip_sns TEXT UNIQUE NOT NULL,
    nass TEXT UNIQUE,
    n_hc TEXT UNIQUE NOT NULL,
    med_cabecera BIGINT NOT NULL,

    FOREIGN KEY (med_cabecera) REFERENCES empleados(id)
);

-- Teléfonos fijos y móviles de pacientes. Formato con E.164 estricto (Ej. +34612345678)
CREATE TABLE IF NOT EXISTS tlfno_pacientes (
	id_tlf BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	tipo_tlf TEXT NOT NULL,
	num_tlf TEXT NOT NULL,

	FOREIGN KEY (id_paciente) REFERENCES pacientes(id)
);

/*
Citas
	Las horas de inicio y fin son previstas. 
	La hora de fin puede servir para comprobar que no hay citas solapadas para el mismo profesional.
	
	TODO: lugar puede ser un id de consulta en un centro o ser null. Tal renombrar a consulta.
*/
CREATE TABLE IF NOT EXISTS citas (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	id_sanitario BIGINT NOT NULL,
	inicio TIMESTAMPTZ NOT NULL,
	fin TIMESTAMPTZ,
	modalidad TEXT NOT NULL,
	lugar TEXT,
	estado TEXT NOT NULL,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	FOREIGN KEY (id_sanitario) REFERENCES empleados (id)
);

/* 
Episodios (ordinario y urgencias)
*/
CREATE TABLE IF NOT EXISTS episodio (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tipo_episodio TEXT NOT NULL,
	procedencia TEXT NOT NULL,
	tipo_consulta TEXT NOT NULL,

	id_snomed_motivo_consulta TEXT NOT NULL, -- Bastaria con uno (el que haya elegido el médico) y especificar cual es la terminología.
	id_cie_motivo_consulta TEXT NOT NULL,

	id_paciente BIGINT NOT NULL,
	id_sanitario BIGINT NOT NULL,
	inicio TIMESTAMPTZ NOT NULL,
	fin TIMESTAMPTZ NOT NULL,
	nivel_triaje TEXT,

	id_diag_snomed TEXT,	-- Este es snomed obligatoriamente

	observaciones TEXT,
	resultado TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes(id),
	FOREIGN KEY (id_sanitario) REFERENCES empleados(id)
);

/*
REGISTRO DE ANTECEDENTES
	- Enfermedades previas, neonatales, obstétricos, quirúrgicos, social, profesional comparten el mismo esquema y se agrupan en esta tabla.
	- Antecedentes familiares y dispositivos van aparte por diferencias.
	- Fecha de fin para entecedentes sociales o profesionales. 
	- También para saber si la enfermedad sigue activa en el caso de antecedentes de enfermedad.
	- No se incluye edad de inicio porque podria calcularse con la tabla de pacientes.
*/
CREATE TABLE IF NOT EXISTS registro_antecedente (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	tipo_antecedente TEXT NOT NULL,

	id_snomed_antecedente TEXT NOT NULL,	-- Igual, solo 1 y registrar cual es la terminología.
	id_CIE TEXT,

	fecha_inicio DATE,
	fecha_fin DATE,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id)
);

-- Antecedentes familiares.
CREATE TABLE IF NOT EXISTS registro_antecedentes_familiares(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,

	id_snomed_antecedente TEXT NOT NULL,	-- Igual, solo 1 y registrar cual es la terminología.
	id_cie_antecedente TEXT NOT NULL,

	id_gr_parentesco_snomed TEXT NOT NULL,
	edad_inicio SMALLINT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id)
)

/*
Registro de dispositivos:
	- Separados del resto de antecedentes al necesitar almecenar códigos de EMDN e ID de fábrica.
*/
CREATE TABLE IF NOT EXISTS registro_dispositivo (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,

	id_snomed_dispositivo TEXT NOT NULL,	-- Igual, solo 1 y registrar cual es la terminología.
	cod_emdn_dispositivo TEXT NOT NULL,

	fecha_implantacion DATE,
	fecha_retirada DATE,
	id_dispositivo_fábrica TEXT

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id)
);

/* 
Registro de alergias. 
	- Tablas eHDSI para alergias recopilan los valores válidos: https://art-decor.ehdsi.eu/publication/epsos-html-20201215T191920/terminology.html
*/
CREATE TABLE IF NOT EXISTS registro_alergias (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,

	id_snomed_alérgeno TEXT NOT NULL,

	id_snomed_man_clin TEXT,
	id_cie_man_clin TEXT,

	cod_tipo_reacc_ehdsi TEXT NOT NULL,
	cod_gravedad_ehdsi TEXT,
	cod_criticidad_ehdsi TEXT,
	cod_certeza_ehdsi TEXT,
	cod_estado_ehdsi TEXT,

	fecha_inicio DATE,
	fecha_fin DATE,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id)
);

/* 
Registro de vacunaciones.
Solo se registran vacunas administradas, no planificadas ni pendientes en la cartilla de vacunación.
*/
CREATE TABLE IF NOT EXISTS registro_vacunaciones (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	id_snomed_vacuna TEXT NOT NULL,
	cod_nom_comercial TEXT,
	fecha_admin DATE NOT NULL,
	num_lote TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id)
);

/* 
Registro de hábitos perjudiciales.
	- Se registra año de inicio y fin solamente porque los informes no solicitan la fecha completa.
*/
CREATE TABLE IF NOT EXISTS registro_habitos (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	id_snomed_habito TEXT NOT NULL,
	anno_inicio SMALLINT,
	anno_fin SMALLINT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
);

/* 
Registro de consumo de sustancias tóxicas.
	- Se registra año de inicio y fin solamente porque los informes no solicitan la fecha completa.
	- Separado de hábitos tóxicos porque solicita más detalles a parte de la fecha de inicio y fin.
*/
CREATE TABLE IF NOT EXISTS registro_toxicos (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,

	id_snomed_toxico TEXT NOT NULL,
	id_snomed_patron_consumo TEXT
	dosis DECIMAL,
	ud_dosis TEXT,
	anno_inicio SMALLINT,
	anno_fin SMALLINT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id)
);

/*
Registro de medicamentos
	- El codigo de fármaco se refiere al principio activo. El nombre comercial es el combre comercial. 
	- Ambos segun nomenclator. Dosis con EDQM.
*/
CREATE TABLE IF NOT EXISTS registro_medicamentos (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	cod_fármaco TEXT NOT NULL,
	cod_nombre_comercial TEXT,

	fecha_inicio DATE NOT NULL,
	fecha_fin DATE,
	cod_via_admin_aemps, TEXT,
	cod_dosis_edqm TEXT NOT NULL,
	Posología TEXT NOT NULL,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id)
);

/*
Registro de formulas magistrales
	Similar a medicamentos, pero la dosis no usa EDQM y solo se incluye la frecuencia en lugar de la posología completa.
*/
CREATE TABLE registro_formulas_magistrales (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_paciente BIGINT NOT NULL,

    id_formula TEXT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    id_via_administracion TEXT,
    dosis TEXT NOT NULL,
    frecuencia TEXT NOT NULL,

    FOREIGN KEY (id_paciente) REFERENCES pacientes(id)
);

-- Registro de situaciones funcionales de pacientes
CREATE TABLE registro_situaciones_funcionales (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_paciente BIGINT NOT NULL,
	id_snomed_escala TEXT NOT NULL,
	resultado TEXT NOT NULL,
	interpretacion TEXT NOT NULL,
	id_snomed_situacion_funcional TEXT NOT NULL,
	
	FOREIGN KEY (id_paciente) REFERENCES pacientes(id)
)