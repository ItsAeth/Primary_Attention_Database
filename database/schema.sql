/*
BASE DE DATOS PARA SISTEMA DE INFORMACIÓN DE UN CENTRO DE ATENCIÓN PRIMARIA
MOTOR: PostgreSQL v18
*/

/*
EMPLEADOS DEL CENTRO
	Considera posibilidad de DNI duplicado y email compartidos.
*/
CREATE TABLE IF NOT EXISTS empleados(
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

	CONSTRAINT tipo_id_es_valido CHECK (tipo_id IN ('DNI','NIE')),
	CONSTRAINT num_id_es_valido CHECK (
		(tipo_id = 'DNI' AND num_id ~ '^[0-9]{8}[A-Z]$') -- No valida si dígito de control es correcto
		OR
		(tipo_id = 'NIE' AND num_id ~ '^[XYZ][0-9]{7}[A-Z]$') -- Aqui tampoco.
	),
	CONSTRAINT nombre_apellidos_sin_digitos CHECK(
		(nombre !~ '[0-9]') AND 
		(apellido1 !~ '[0-9]') AND 
		(apellido2 !~ '[0-9]' OR apellido2 IS NULL)
	),
	CONSTRAINT empleado_mayor_de_edad CHECK (fecha_nacimiento <= CURRENT_DATE - INTERVAL '18 years'),
	CONSTRAINT sexo_es_valido CHECK (sexo IN ('Varón', 'Mujer', 'No especificado')),
	CONSTRAINT email_es_valido CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
	CONSTRAINT pais_nac_es_valido CHECK (length(pais_nac) = 3 OR pais_nac = "ZZZ"),
	CONSTRAINT reside_cp CHECK (length(reside_cp) = 3 OR reside_cp ~ '^53[0-9]{3}'),
	CONSTRAINT reside_muni CHECK (length(reside_muni) = 3 OR reside_muni ~ '^530[0-9]{3}')
);

-- Teléfonos fijos y móviles de empleados. Formato con E.164 estricto (Ej. +34612345678)
CREATE TABLE IF NOT EXISTS tlf_empleados(
	id_tlf BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_empleado BIGINT NOT NULL,
	tipo_tlf TEXT NOT NULL,
	num_tlf TEXT NOT NULL,

	FOREIGN KEY (id_empleado) REFERENCES empleados(id),

	CONSTRAINT tipo_tlf_es_valido CHECK (tipo_tlf IN ('Fijo', 'Móvil')),
	CONSTRAINT num_tlf_es_valido CHECK (num_tlf ~ '^\+[1-9][0-9]{1,14}$'),
);

/* 
Información especifica de empleados sanitarios.
	Sería necesaria una tabla para verificar que las especialidades sean válidas
*/
CREATE TABLE IF NOT EXISTS info_sanitarios(
	id_sanitario BIGINT PRIMARY KEY,
	cias TEXT NOT NULL,
	num_colegiado TEXT NOT NULL,
	especialidad TEXT NOT NULL,

	FOREIGN KEY (id_sanitario) REFERENCES empleados(id),

	CONSTRAINT cias_es_valido CHECK (cias ~ '^[0-9]{10}[A-Z]$'),
	CONSTRAINT num_colegiado_es_valido CHECK (length(num_colegiado) = 9)
);

/* 
Pacientes
	CIP autonómico y nº de historia clínica varian entre comunidades
	Duplica las restricciones de empleados
*/
CREATE TABLE IF NOT EXISTS pacientes (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tipo_id TEXT NOT NULL,
	num_id TEXT NOT NULL,
	fecha_alta TIMESTAMPTZ DEFAULT now(),
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
    cip_aut TEXT UNIQUE NOT NULL,
    nass TEXT UNIQUE NOT NULL,
    n_hc TEXT UNIQUE NOT NULL,
    med_cabecera BIGINT NOT NULL,

    FOREIGN KEY (med_cabecera) REFERENCES empleados(id)

	CONSTRAINT tipo_id_es_valido CHECK (tipo_id IN ('DNI','NIE')),
	CONSTRAINT num_id_es_valido CHECK (
		(tipo_id = 'DNI' AND num_id ~ '^[0-9]{8}[A-Z]$') -- No valida si dígito de control es correcto
		OR
		(tipo_id = 'NIE' AND num_id ~ '^[XYZ][0-9]{7}[A-Z]$') -- Aqui tampoco.
	),
	CONSTRAINT nombre_apellidos_sin_digitos CHECK(
		(nombre !~ '[0-9]') AND 
		(apellido1 !~ '[0-9]') AND 
		(apellido2 !~ '[0-9]' OR apellido2 IS NULL)
	),
	CONSTRAINT empleado_mayor_de_edad CHECK (fecha_nacimiento <= CURRENT_DATE - INTERVAL '18 years'),
	CONSTRAINT sexo_es_valido CHECK (sexo IN ('Varón', 'Mujer', 'No especificado')),
	CONSTRAINT email_es_valido CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
	CONSTRAINT pais_nac_es_valido CHECK (length(pais_nac) = 3 OR pais_nac = "ZZZ"),
	CONSTRAINT reside_cp CHECK (length(reside_cp) = 3 OR reside_cp ~ '^53[0-9]{3}'),
	CONSTRAINT reside_muni CHECK (length(reside_muni) = 3 OR reside_muni ~ '^530[0-9]{3}')
	CONSTRAINT cip_sns_es_valido CHECK (cip_sns ~ '^B{8}[a-z]{2}[0-9]{6}$')
	CONSTRAINT nass_es_valido CHECK (nass ~ '^[0-9]{12}$')
);

-- Teléfonos fijos y móviles de pacientes. Formato con E.164 estricto (Ej. +34612345678)
CREATE TABLE IF NOT EXISTS tlfno_pacientes(
	id_tlf BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_pacinte BIGINT NOT NULL,
	tipo_tlf TEXT NOT NULL,
	num_tlf TEXT NOT NULL,

	FOREIGN KEY (id_paciente) REFERENCES pacientes(id),

	CONSTRAINT tipo_tlf_es_valido CHECK (tipo_tlf IN ('Fijo', 'Móvil')),
	CONSTRAINT num_tlf_es_valido CHECK (num_tlf ~ '^\+[1-9][0-9]{1,14}$'),
);

/*
Citas
	El profesional puede aproximar la hora de fin de la cita y permitiria comprobar que no se solape con otra.
*/
CREATE TABLE IF NOT EXISTS citas(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	id_sanitario BIGINT NOT NULL,
	inicio TIMESTAMPTZ NOT NULL,
	fin TIMESTAMPTZ,
	modalidad TEXT NOT NULL 
	lugar TEXT,
	estado TEXT NOT NULL,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	FOREIGN KEY (id_sanitario) REFERENCES empleados (id),
	
	CONSTRAINT fecha_fin_mayor_inicio CHECK (fin > inicio)
	CONSTRAINT modalidad_es_valida CHECK (modalidad IN ('Presencial', 'Telemática')),
	CONSTRAINT estado_es_valido CHECK (estado IN ('Pendiente_aceptación', 'Aceptada', 'Cancelada', 'Finalizada', 'No presentado'))
);

/* 
Turnos (fichaje) de todo el personal del centro
*/
CREATE TABLE IF NOT EXISTS turnos(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_empleado BIGINT NOT NULL,
	tipo_turno TEXT NOT NULL,
	inicio TIMESTAMPTZ NOT NULL,
	fin TIMESTAMPTZ,

	FOREIGN KEY (id_empleado) REFERENCES empleados (id),

	CONSTRAINT tipo_turno_válido CHECK (tipo_turno IN ("Ordinario", "Guardia")),
	CONSTRAINT fin_mayor_inicio CHECK (fin IS NULL OR fin > inicio)
)

CREATE TABLE IF NOT EXISTS episodio(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tipo TEXT NOT NULL,
	id_paciente BIGINT NOT NULL,
	id_sanitario BIGINT NOT NULL,
	fecha_atencion DATE NOT NULL,
	hora_atencion TIME NOT NULL,
	hora_alta TIME NOT NULL,
	nivel_triaje TEXT,
	diag_snomed TEXT,
	observaciones TEXT,
	resultado TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes(id),
	FOREIGN KEY (id_sanitario) REFERENCES empleados(id),

	CONSTRAINT tipo_episodio_valido CHECK (tipo IN ('Seguimiento', 'Consulta', 'Urgencia', 'Prevención', 'Administrativo')),
	CONSTRAINT nivel_triaje_valido CHECK (nivel_triaje IS NULL OR nivel_triaje IN ('Azul', 'Verde', 'Amarillo', 'Naranja', 'Rojo'))
	CONSTRAINT resultado_valido CHECK (resultado IN ('Alta', 'Derivación', 'Pruebas')),
);

-- HCE TESAUROS

CREATE TABLE IF NOT EXISTS antecendentes(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tipo VARCHAR(8) NOT NULL CHECK (tipo IN ('Enfermedad', 'Neonatal', 'Obstétrico', 'Familiar', 'Quirúrgico', 'Social', 'Profesional')),
	id_snomed TEXT NOT NULL CHECK (length(id_snomed) >= 6),
	concepto_snomed TEXT NOT NULL,
	id_cie VARCHAR(7),
	literal_cie TEXT
);

CREATE TABLE IF NOT EXISTS alergeno(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_snomed TEXT NOT NULL CHECK (length(id_snomed) >= 6),
	concepto_snomed TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dispositivo(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_snomed TEXT NOT NULL CHECK (length(id_snomed) >= 6),
	concepto_snomed TEXT NOT NULL,
	id_emdn VARCHAR(13),
	desc_emdn TEXT
);

CREATE TABLE IF NOT EXISTS perjudicial(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tipo CHAR(1) NOT NULL CHECK (tipo IN ('H', 'T')),
	id_snomed TEXT NOT NULL CHECK (length(id_snomed) >= 6),
	concepto_snomed TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS farmaco(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tipo CHAR(1) NOT NULL CHECK (tipo IN ('V', 'T')),
	id_snomed TEXT NOT NULL CHECK (length(id_snomed) >= 6),
	concepto_snomed TEXT NOT NULL,
	cod_aemps VARCHAR(7) NOT NULL,
	nom_comercial TEXT NOT NULL
);

-- HCE REGISTROS

CREATE TABLE IF NOT EXISTS registro_antecedente(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	id_antecedente BIGINT NOT NULL,
	fecha_inicio DATE,
	fecha_fin DATE,
	edad_inicio SMALLINT,
	edad_fin SMALLINT,
	observaciones TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	FOREIGN KEY (id_antecedente) REFERENCES antecendentes (id)
);

CREATE TABLE IF NOT EXISTS registro_alergias(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	id_alergeno BIGINT NOT NULL,
	tipo_reacc_ehdsi TEXT,
	man_clin_snomed TEXT,
	man_clin_CIE TEXT,
	gravedad_ehdsi VARCHAR(30),
	criticidad VARCHAR(30),
	certeza VARCHAR(12),
	estado VARCHAR(8),
	fecha_inicio DATE,
	fecha_fin DATE,
	observaciones TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	FOREIGN KEY (id_alergeno) REFERENCES alergeno (id)
);

CREATE TABLE IF NOT EXISTS registro_dispositivo(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	id_dispositivo BIGINT NOT NULL,
	fecha_implantacion DATE NOT NULL,
	fecha_retirada DATE,
	id_dispositivo_fábrica VARCHAR(20) NOT NULL,
	observaciones TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	FOREIGN KEY (id_dispositivo) REFERENCES dispositivo (id)
);

CREATE TABLE IF NOT EXISTS registro_habitos(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	id_habito BIGINT NOT NULL,
	anno_inicio SMALLINT NOT NULL,
	anno_fin SMALLINT,
	edad_inicio SMALLINT,
	edad_fin SMALLINT,
	observaciones TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	FOREIGN KEY (id_habito) REFERENCES perjudicial (id)
);

CREATE TABLE IF NOT EXISTS registro_toxico(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	id_toxico BIGINT NOT NULL,
	dosis DECIMAL,
	ud_dosis VARCHAR(15),
	patron_snomed TEXT,
	anno_inicio SMALLINT NOT NULL,
	anno_fin SMALLINT,
	edad_inicio SMALLINT,
	edad_fin SMALLINT,
	observaciones TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	FOREIGN KEY (id_toxico) REFERENCES perjudicial (id)
);

CREATE TABLE IF NOT EXISTS registro_vacunación(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	id_vacuna BIGINT NOT NULL,
	fecha_admin DATE NOT NULL,
	fecha_validez DATE,
	num_repeticion SMALLINT NOT NULL,
	num_lote VARCHAR(30) NOT NULL,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	FOREIGN KEY (id_vacuna) REFERENCES farmaco (id)
);

CREATE TABLE IF NOT EXISTS registro_tratamiento(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	id_tratamiento BIGINT NOT NULL,
	fecha_inicio DATE NOT NULL,
	fecha_fin DATE NOT NULL,
	via_admin_aemps VARCHAR(26) NOT NULL,
	dosis DECIMAL NOT NULL,
	frecuencia SMALLINT NOT NULL,
	ud_dosis VARCHAR(15) NOT NULL,
	ud_frecuencia VARCHAR(15) NOT NULL,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	FOREIGN KEY (id_tratamiento) REFERENCES farmaco (id)
);
