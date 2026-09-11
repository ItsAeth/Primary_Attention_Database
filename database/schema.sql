/*
BASE DE DATOS PARA SISTEMA DE INFORMACIÓN DE UN CENTRO DE ATENCIÓN PRIMARIA (PostgreSQL v18)

Funciones: 
	Registro de pacientes y personal (
		identificación, 
		domicilio, 
		contacto
	)
	Registro de actividad asistencial (
		turnos del personal, 
		citas, 
		episodios
	)
	Registro de HCE (
		antecedentes, 
		alergias, 
		dispositivos, 
		tratamientos, 
		vacunaciones, 
		hábitos perjudiciales, 
		uso de sustancias tóxicas
	)
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
	Dígito de control de DNI debe ser validado externamente
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
    -- cip_aut TEXT UNIQUE NOT NULL,
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
	CONSTRAINT fecha_nacimiento_valida CHECK (fecha_nacimiento <= CURRENT_DATE),
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
	id_paciente BIGINT NOT NULL,
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

/* 
Episodios (ordinario y urgencias)
Revisar hora de atención y de alta no superiores a la actual
*/
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

/*

Existiendo una API para acceder a la terminologia, estas tablas no son útiles si solo se pretende buscar los términos.
Las dejo estar por ahora.

RESTRICCIONES SNOMED CT
https://docs.snomed.org/snomed-ct-specifications/snomed-ct-release-file-specification/snomed-ct-identifiers/6.3-sctid-constraints
SCTID empieza por digito que no sea 0. El resto son dígitos hasta sumar de 6 a 18 caracteres.
Solo se almacenan conceptos de SNOMED CT. Los dos penúltimos dígitos son 00 o 10.
El check digit de un SCTID se valida mediante el algoritmo de Verhoeff (validar esto con python).

CIE-10-ES
https://www.sanidad.gob.es/estadEstudios/estadisticas/normalizacion/CIE10/2026/2026_CIE10ES_Tomo_I_Diagnosticos.pdf
ID CIE puede tener 7 dígitos en la variante española (CIE-10-ES)
*/

/*
CREATE TABLE IF NOT EXISTS antecendentes(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tipo TEXT NOT NULL,
	id_snomed TEXT NOT NULL ,
	concepto_snomed TEXT NOT NULL,
	id_cie TEXT,
	literal_cie TEXT,

	CONSTRAINT tipo_antecedente_valido CHECK (tipo IN ('Enfermedad', 'Neonatal', 'Obstétrico', 'Familiar', 'Quirúrgico', 'Social', 'Profesional')),
	CONSTRAINT id_snomed_valido CHECK (id_snomed ~ '^[1-9][0-9]{5,17}$'),
	CONSTRAINT id_snomed_identifica_concepto CHECK (RIGHT(snomed_id, 3) ~ '^(00|10)[0-9]$'),
	CONSTRAINT id_cie_valido CHECK (length(id_cie) BETWEEN 3 AND 7)
);

CREATE TABLE IF NOT EXISTS alergeno(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_snomed TEXT NOT NULL CHECK (length(id_snomed) >= 6),
	concepto_snomed TEXT NOT NULL,

	CONSTRAINT id_snomed_valido CHECK (id_snomed ~ '^[1-9][0-9]{5,17}$'),
	CONSTRAINT id_snomed_identifica_concepto CHECK (RIGHT(snomed_id, 3) ~ '^(00|10)[0-9]$'),

);

-- Validar los del EMDN
CREATE TABLE IF NOT EXISTS dispositivo(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_snomed TEXT NOT NULL CHECK (length(id_snomed) >= 6),
	concepto_snomed TEXT NOT NULL,
	id_emdn VARCHAR(13),
	desc_emdn TEXT

	CONSTRAINT id_snomed_valido CHECK (id_snomed ~ '^[1-9][0-9]{5,17}$'),
	CONSTRAINT id_snomed_identifica_concepto CHECK (RIGHT(snomed_id, 3) ~ '^(00|10)[0-9]$')

);

-- Cambiar tipo a palabras completas
CREATE TABLE IF NOT EXISTS perjudicial(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tipo CHAR(1) NOT NULL CHECK (tipo IN ('H', 'T')),
	id_snomed TEXT NOT NULL CHECK (length(id_snomed) >= 6),
	concepto_snomed TEXT NOT NULL

	CONSTRAINT id_snomed_valido CHECK (id_snomed ~ '^[1-9][0-9]{5,17}$'),
	CONSTRAINT id_snomed_identifica_concepto CHECK (RIGHT(snomed_id, 3) ~ '^(00|10)[0-9]$'),

);

-- Cambiar tipo a palabras completas y cambiar lo de AEMPS
CREATE TABLE IF NOT EXISTS farmaco(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tipo CHAR(1) NOT NULL CHECK (tipo IN ('V', 'T')),
	id_snomed TEXT NOT NULL CHECK (length(id_snomed) >= 6),
	concepto_snomed TEXT NOT NULL,
	cod_aemps VARCHAR(7) NOT NULL,
	nom_comercial TEXT NOT NULL

	CONSTRAINT id_snomed_valido CHECK (id_snomed ~ '^[1-9][0-9]{5,17}$'),
	CONSTRAINT id_snomed_identifica_concepto CHECK (RIGHT(snomed_id, 3) ~ '^(00|10)[0-9]$')
);

*/

/*
HCE REGISTROS
FK hacia tablas tesauro comentadas por ahora porque no se estan usando (ver inicio de la sección de tablas tesauro)

Cambiar los campos id_antecedente, id_dispositivo, etc.
Se deberia comprobar que la edad de inicio y de fin no sean inferiores a la edad de nacimiento del paciente, pero
con CHECK no se puede. Usar un trigger o python.
*/

CREATE TABLE IF NOT EXISTS registro_antecedente(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	-- id_antecedente BIGINT NOT NULL,
	id_snomed_antecedente TEXT NOT NULL ,
	concepto_snomed_antecedente TEXT NOT NULL,
	fecha_inicio DATE,
	fecha_fin DATE,
	edad_inicio SMALLINT,
	edad_fin SMALLINT,
	observaciones TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	-- FOREIGN KEY (id_antecedente) REFERENCES antecendentes (id),

	CONSTRAINT id_snomed_valido CHECK (id_snomed_antecedente ~ '^[1-9][0-9]{5,17}$'),
	CONSTRAINT id_snomed_identifica_concepto CHECK (RIGHT(id_snomed_antecedente, 3) ~ '^(00|10)[0-9]$')

	CONSTRAINT fecha_inicio_fin_validas CHECK(
		(fecha_inicio IS NULL AND fecha_fin IS NULL) 
		OR
		(fecha_fin IS NULL AND fecha_inicio <= CURRENT_DATE)
		OR
		(fecha_fin <= CURRENT_DATE AND fecha_inicio <= CURRENT_DATE)
	)
	CONSTRAINT edad_inicio_fin_validas CHECK(edad_fin >= edad_inicio)
);

CREATE TABLE IF NOT EXISTS registro_alergias(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	-- id_alergeno BIGINT NOT NULL,
	id_snomed_alérgeno TEXT NOT NULL ,
	concepto_snomed_alérgeno TEXT NOT NULL,
	tipo_reacc_ehdsi TEXT,
	id_snomed_man_clin TEXT
	man_clin_snomed TEXT,
	id_cie_man_clin TEXT
	man_clin_CIE TEXT,

	-- Estos van por categorías. Comprobar cuáles son y meter CHECK
	gravedad_ehdsi VARCHAR(30),
	criticidad VARCHAR(30),
	certeza VARCHAR(12),
	estado VARCHAR(8),

	fecha_inicio DATE,
	fecha_fin DATE,
	observaciones TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	FOREIGN KEY (id_alergeno) REFERENCES alergeno (id),

	CONSTRAINT ids_snomed_valido CHECK (
		(id_snomed_alérgeno ~ '^[1-9][0-9]{5,17}$')
		AND
		((id_snomed_man_clin IS NULL) OR (id_snomed_man_clin ~ '^[1-9][0-9]{5,17}$'))
	),
	CONSTRAINT ids_snomed_identifica_concepto CHECK (
		(RIGHT(id_snomed_alérgeno, 3) ~ '^(00|10)[0-9]$') 
		AND
		((id_snomed_man_clin IS NULL) OR (RIGHT(id_cie_man_clin, 3) ~ '^(00|10)[0-9]$'))
	),
	CONSTRAINT id_cie_valido CHECK (length(id_cie_man_clin) BETWEEN 3 AND 7)

	-- CHECK para comprobar EDHSI aquí --

	CONSTRAINT fecha_inicio_fin_validas CHECK(
		(fecha_inicio IS NULL AND fecha_fin IS NULL) 
		OR
		(fecha_fin IS NULL AND fecha_inicio <= CURRENT_DATE)
		OR
		(fecha_fin <= CURRENT_DATE AND fecha_inicio <= CURRENT_DATE)
	)
);

CREATE TABLE IF NOT EXISTS registro_dispositivo(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	-- id_dispositivo BIGINT NOT NULL,
	id_snomed_dispositivo TEXT NOT NULL,
	concepto_snomed_dispositivo TEXT NOT NULL,
	fecha_implantacion DATE NOT NULL,
	fecha_retirada DATE,
	id_dispositivo_fábrica TEXT NOT NULL,
	observaciones TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	-- FOREIGN KEY (id_dispositivo) REFERENCES dispositivo (id)

	CONSTRAINT id_snomed_valido CHECK (id_snomed_dispositivo ~ '^[1-9][0-9]{5,17}$'),
	CONSTRAINT id_snomed_identifica_concepto CHECK (RIGHT(id_snomed_dispositivo, 3) ~ '^(00|10)[0-9]$')

	CONSTRAINT fecha_implantación_retirada_validas CHECK(
		(fecha_retirada IS NULL AND fecha_implantacion <= CURRENT_DATE)
		OR
		(fecha_retirada <= CURRENT_DATE AND fecha_implantacion <= CURRENT_DATE)
	)

	-- Tiene que ser menor igual a 20, o exactamente 20 caracteres??
	CONSTRAINT id_fábrica_valido CHECK (length(id_dispositivo_fábrica) = 20)

);

CREATE TABLE IF NOT EXISTS registro_habitos(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	-- id_habito BIGINT NOT NULL,
	id_snomed_habito TEXT NOT NULL,
	concepto_snomed_habito TEXT NOT NULL,
	anno_inicio SMALLINT,
	anno_fin SMALLINT,
	edad_inicio SMALLINT,
	edad_fin SMALLINT,
	observaciones TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	-- FOREIGN KEY (id_habito) REFERENCES perjudicial (id)

	CONSTRAINT id_snomed_valido CHECK (id_snomed_habito ~ '^[1-9][0-9]{5,17}$'),
	CONSTRAINT id_snomed_identifica_concepto CHECK (RIGHT(id_snomed_habito, 3) ~ '^(00|10)[0-9]$'),

	-- Sería más lógico comprobar que no son inferiores al año de nacimiento del paciente.
	CONSTRAINT anno_inicio_fin_válidos CHECK(
		(anno_inicio IS NULL AND anno_fin IS NULL) 
		OR
		(anno_fin IS NULL AND anno_inicio >= 0)
		OR
		(anno_inicio >= 0 AND anno_fin >= 0 AND anno_inicio <= anno_fin)
	),

	-- Habría que comprobar que la edad coincide con las posibilidades según la sfecha de inicio y fin 
	--(un año +- dependiendo de la fecha de nacimiento del paciente)
	CONSTRAINT edad_inicio_fin_validas CHECK(
		(edad_inicio IS NULL AND edad_fin IS NULL) 
		OR
		(edad_fin IS NULL AND edad_inicio >= 0)
		OR
		(edad_fin >= 0 AND edad_inicio >= 0 AND edad_inicio <= edad_fin)
	)
);

CREATE TABLE IF NOT EXISTS registro_toxico(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	-- id_toxico BIGINT NOT NULL,
	id_snomed TEXT NOT NULL,
	concepto_snomed TEXT NOT NULL,
	dosis DECIMAL,
	ud_dosis VARCHAR(15),
	id_snomed_patron TEXT,
	concepto_patron_snomed TEXT,
	anno_inicio SMALLINT,
	anno_fin SMALLINT,
	edad_inicio SMALLINT,
	edad_fin SMALLINT,
	observaciones TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	-- FOREIGN KEY (id_toxico) REFERENCES perjudicial (id)

	CONSTRAINT ids_snomed_validos CHECK (
		(id_snomed ~ '^[1-9][0-9]{5,17}$')
		AND
		(id_snomed_patron IS NULL OR (id_snomed_patron ~ '^[1-9][0-9]{5,17}$'))
	),
	CONSTRAINT ids_snomed_identifican_conceptos CHECK (
		(RIGHT(snomed_id, 3) ~ '^(00|10)[0-9]$')
		AND
		((id_snomed_patron) IS NULL OR (RIGHT(id_snomed_patron, 3) ~ '^(00|10)[0-9]$'))
	),

	-- Sería más lógico comprobar que no son inferiores al año de nacimiento del paciente.
	CONSTRAINT anno_inicio_fin_válidos CHECK(
		(anno_inicio IS NULL AND anno_fin IS NULL) 
		OR
		(anno_fin IS NULL AND anno_inicio >= 0)
		OR
		(anno_inicio >= 0 AND anno_fin >= 0 AND anno_inicio <= anno_fin)
	),

	-- Habría que comprobar que la edad coincide con las posibilidades según la sfecha de inicio y fin 
	--(un año +- dependiendo de la fecha de nacimiento del paciente)
	CONSTRAINT edad_inicio_fin_validas CHECK(
		(edad_inicio IS NULL AND edad_fin IS NULL) 
		OR
		(edad_fin IS NULL AND edad_inicio >= 0)
		OR
		(edad_fin >= 0 AND edad_inicio >= 0 AND edad_inicio <= edad_fin)
	)
);

CREATE TABLE IF NOT EXISTS registro_vacunación(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	-- id_vacuna BIGINT NOT NULL,
	id_snomed_vacuna TEXT NOT NULL,
	concepto_snomed_vacuna TEXT NOT NULL,
	fecha_admin DATE NOT NULL,
	fecha_validez DATE,
	num_repeticion SMALLINT NOT NULL,		-- Hay que comprobar que sea > 0 ???
	num_lote VARCHAR(30) NOT NULL,			-- Cambiar por TEXT y poner check para el formato

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	-- FOREIGN KEY (id_vacuna) REFERENCES farmaco (id)

	CONSTRAINT id_snomed_valido CHECK (id_snomed_vacuna ~ '^[1-9][0-9]{5,17}$'),
	CONSTRAINT id_snomed_identifica_concepto CHECK (RIGHT(id_snomed_vacuna, 3) ~ '^(00|10)[0-9]$'),

	CONSTRAINT fecha_admin_validez_validas CHECK(
		(fecha_validez IS NULL AND fecha_admin <= CURRENT_DATE)
		OR
		(fecha_admin <= CURRENT_DATE AND fecha_validez > fecha_admin)
	)

);

CREATE TABLE IF NOT EXISTS registro_tratamiento(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	-- id_tratamiento BIGINT NOT NULL,
	id_snomed TEXT NOT NULL,
	concepto_snomed TEXT NOT NULL,
	fecha_inicio DATE NOT NULL,
	fecha_fin DATE NOT NULL,				-- Esto puede ser la fecha en la que tiene que renovar y se crea otro registro, o puede ponerse en null??
	via_admin_aemps VARCHAR(26) NOT NULL,
	dosis DECIMAL NOT NULL,
	frecuencia SMALLINT NOT NULL,
	ud_dosis VARCHAR(15) NOT NULL,
	ud_frecuencia VARCHAR(15) NOT NULL,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	-- FOREIGN KEY (id_tratamiento) REFERENCES farmaco (id)

	CONSTRAINT id_snomed_valido CHECK (id_snomed ~ '^[1-9][0-9]{5,17}$'),
	CONSTRAINT id_snomed_identifica_concepto CHECK (RIGHT(snomed_id, 3) ~ '^(00|10)[0-9]$')

);
