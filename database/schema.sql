/*
BASE DE DATOS PARA SISTEMA DE INFORMACIÓN DE UN CENTRO DE ATENCIÓN PRIMARIA
MOTOR: PostgreSQL v18
*/

/*
EMPLEADOS DEL CENTRO
Considera posibilidad de DNI duplicado y email compartidos.

	Si el Nº de identificación es información sensible, ¿deberia ir cifrado?
	Separar el domicilio en varios campos con codigos ISO
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
	CONSTRAINT sexo_es_valido CHECK (sexo IN ('Masculino', 'Femenino', 'No especificado')),
	CONSTRAINT email_es_valido CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
	CONSTRAINT pais_nac_es_valido CHECK (length(pais_nac) = 3),
	CONSTRAINT reside_cp CHECK (length(reside_cp) = 3 OR reside_cp ~ '^53[0-9]{3}'),
	CONSTRAINT reside_muni CHECK (length(reside_muni) = 3 OR reside_muni ~ '^530[0-9]{3}')
);

-- Teléfonos fijos (F) y móviles (M).
CREATE TABLE IF NOT EXISTS tlfno_empleados(
	id_tlfno BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_empleado BIGINT NOT NULL,
	tipo CHAR(1) NOT NULL CHECK (tipo IN ('F', 'M')),
	tlf VARCHAR(16) NOT NULL CHECK (tlf ~ '^\+[0-9]{1,15}$'),

	FOREIGN KEY (id_empleado) REFERENCES empleados(id)
);

-- Información especifica de empleados sanitarios.
-- Añadir horario de atención en pacientes mediante cita (no incluye urgencias)
CREATE TABLE IF NOT EXISTS info_sanitarios(
	id_sanitario BIGINT PRIMARY KEY,
	num_colegiado CHAR(9) NOT NULL,
	especialidad TEXT NOT NULL,

	FOREIGN KEY (id_sanitario) REFERENCES empleados(id)
);

CREATE TABLE IF NOT EXISTS pacientes (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo_id CHAR(3) NOT NULL CHECK (tipo_id IN ('DNI','NIE')),
    num_id CHAR(9) UNIQUE NOT NULL CHECK (
        (tipo_id = 'DNI' AND num_id ~ '^[0-9]{8}[A-Z]$')			-- Igual que con empleados. No valida digito de control
        OR
        (tipo_id = 'NIE' AND num_id ~ '^[XYZ][0-9]{7}[A-Z]$')
    ),
    fecha_alta TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    nombre TEXT NOT NULL,											-- Igual que empleados
    apellido1 TEXT NOT NULL,
    apellido2 TEXT,
    fecha_nacimiento DATE NOT NULL,									-- No puede ser futura
    sexo CHAR(1) NOT NULL CHECK (sexo IN ('M','F','I')),			-- DOcumentar
    domicilio TEXT NOT NULL,										-- separar
    email TEXT CHECK (
        email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    ),
    fax VARCHAR(30),
    cip_aut CHAR(16) UNIQUE NOT NULL,								-- Validar estos campos
    cip_sns CHAR(16) UNIQUE NOT NULL,
    nass CHAR(12) UNIQUE NOT NULL,
    n_hc VARCHAR(20) UNIQUE NOT NULL,
    med_cabecera BIGINT NOT NULL,

    FOREIGN KEY (med_cabecera) REFERENCES empleados(id)
);

CREATE TABLE IF NOT EXISTS tlfno_pacientes(
	id_tlfno BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	tipo CHAR(1) NOT NULL CHECK (tipo IN ('F', 'M')),
	tlf VARCHAR(16) NOT NULL CHECK (tlf ~ '^\+[0-9]{1,15}$'),

	FOREIGN KEY (id_paciente) REFERENCES pacientes(id)
);

CREATE TABLE IF NOT EXISTS citas(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	id_sanitario BIGINT NOT NULL,
	inicio TIMESTAMP NOT NULL,
	fin TIMESTAMP,
	modalidad CHAR(1) NOT NULL CHECK (modalidad IN ('P', 'T')),
	lugar TEXT,
	estado CHAR(2) NOT NULL CHECK (estado IN ('PA', 'AC', 'CA', 'FN', 'NP')),

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	FOREIGN KEY (id_sanitario) REFERENCES empleados (id)
);

-- Turnos de todo el personal del centro de atención primaria
-- Se consideran turnos nocturnos que incluyen la medianoche.
-- Se pueden añadir una columna de tipo para distinguir si son guardias o turnos normales. 
CREATE TABLE IF NOT EXISTS turnos(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_sanitario BIGINT NOT NULL,							-- Esto debe ser para empleados en general, tabla correcta pero cambiar el nombre
	fecha_inicio DATE NOT NULL,								-- No puede ser superior a la actual
	fecha_fin DATE NOT NULL,								-- No puede ser superior a la actual
	hora_inicio TIME NOT NULL,
	hora_fin TIME NOT NULL,

	FOREIGN KEY (id_sanitario) REFERENCES empleados (id)

);

CREATE TABLE IF NOT EXISTS episodio(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tipo CHAR(1) NOT NULL CHECK (tipo IN ('S','E', 'U', 'P', 'A')), -- Documentar esto
	id_paciente BIGINT NOT NULL,
	id_sanitario BIGINT NOT NULL,
	fecha_atencion DATE NOT NULL,									-- No superior a la actual
	hora_atencion TIME NOT NULL,
	hora_alta TIME NOT NULL,
	nivel_triaje VARCHAR(8) CHECK (nivel_triaje IN ('azul', 'verde', 'amarillo', 'naranja', 'rojo')),
	diag_snomed TEXT,
	observaciones TEXT,
	resultado CHAR(1) CHECK (resultado IN ('A', 'D', 'P')), -- Documentar

	FOREIGN KEY (id_paciente) REFERENCES pacientes(id),
	FOREIGN KEY (id_sanitario) REFERENCES empleados(id)
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
