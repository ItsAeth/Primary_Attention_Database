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
CREATE TABLE IF NOT EXISTS tlfno_pacientes(
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
	
	TODO: lugar puede ser un id de consulta en un centro o ser null. Tal renombrar  a consulta.
*/
CREATE TABLE IF NOT EXISTS citas(
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
CREATE TABLE IF NOT EXISTS episodio(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tipo_episodio TEXT NOT NULL,
	procedencia TEXT NOT NULL,
	tipo_consulta TEXT NOT NULL,
	id_snomed_motivo_consulta TEXT NOT NULL,
	id_cie_motivo_consulta TEXT NOT NULL,
	id_paciente BIGINT NOT NULL,
	id_sanitario BIGINT NOT NULL,
	inicio TIMESTAMPTZ NOT NULL,
	fin TIMESTAMPTZ NOT NULL,
	nivel_triaje TEXT,
	id_diag_snomed TEXT,
	observaciones TEXT,
	resultado TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes(id),
	FOREIGN KEY (id_sanitario) REFERENCES empleados(id)
);

-- //// TERMINADO HASTA AQUÍ. REVISAR EL RESTO

/*
HCE REGISTROS
FK hacia tablas tesauro comentadas por ahora porque no se estan usando (ver inicio de la sección de tablas tesauro)

Cambiar los campos id_antecedente, id_dispositivo, etc.
Se deberia comprobar que la edad de inicio y de fin no sean inferiores a la edad de nacimiento del paciente, pero
con CHECK no se puede. Usar un trigger o python.

*/

/*
REGISTRO DE ANTECEDENTES
Enfermedades previas, neonatales, obstétricos, quirúrgicos, social, profesional comparten el mismo esquema y se agrupan en esta tabla.
Antecedentes familiares y dispositivos van aparte por diferencias.s

*/
CREATE TABLE IF NOT EXISTS registro_antecedente(

	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	tipo_antecedente TEXT NOT NULL,
	id_snomed_antecedente TEXT NOT NULL,
	concepto_snomed_antecedente TEXT NOT NULL,
	id_CIE TEXT,
	term_CIE TEXT,

	fecha_inicio DATE,
	edad_inicio SMALLINT,
	fecha_fin DATE,			-- Para entecedentes sociales o profesionales. También para saber si la enfermedad sigue activa en el caso de antecedentes de enfermedad.

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),

	/*
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
	*/
);

CREATE TABLE IF NOT EXISTS registro_dispositivo(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	id_snomed_dispositivo TEXT NOT NULL,
	concepto_snomed_dispositivo TEXT NOT NULL,
	cod_emdn_dispositivo TEXT NOT NULL, TEXT NOT NULL
	term_emdn_dispositivo TEXT NOT NULL,

	fecha_implantacion DATE,
	fecha_retirada DATE,
	id_dispositivo_fábrica TEXT,

	/*
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
	CONSTRAINT id_fábrica_valido CHECK (length(id_dispositivo_fábrica) = 20) */
);

CREATE TABLE IF NOT EXISTS registro_antecedentes_familiares(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	id_snomed_dispositivo TEXT NOT NULL,
	concepto_snomed_dispositivo TEXT NOT NULL,

)

/* 
Registro de alergias. 
Tablas eHDSI para alergias: https://art-decor.ehdsi.eu/publication/epsos-html-20201215T191920/terminology.html
*/
CREATE TABLE IF NOT EXISTS registro_alergias(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	id_snomed_alérgeno TEXT NOT NULL ,
	concepto_snomed_alérgeno TEXT NOT NULL,
	cod_tipo_reacc_ehdsi TEXT NOT NULL,
	term_tipo_reacc_ehdsi TEXT NOT NULL,

	-- Recomendados
	id_snomed_man_clin TEXT,
	man_clin_snomed TEXT,
	id_cie_man_clin TEXT
	man_clin_CIE TEXT,

	cod_gravedad_ehdsi TEXT
	term_gravedad_ehdsi TEXT,

	cod_criticidad_ehdsi TEXT,
	term_criticidad_ehdsi TEXT,

	cod_certeza_ehdsi TEXT,
	term_certeza_ehdsi TEXT,

	cod_estado_ehdsi TEXT,
	term_estado_ehdsi TEXT,

	fecha_inicio DATE,
	fecha_fin DATE,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	FOREIGN KEY (id_alergeno) REFERENCES alergeno (id),

	/* CONSTRAINT ids_snomed_valido CHECK (
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
	)*/
);

CREATE TABLE IF NOT EXISTS registro_vacunación(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,

	id_snomed_vacuna TEXT NOT NULL,
	concepto_snomed_vacuna TEXT NOT NULL,

	cod_nom_comercial TEXT
	nom_comercial TEXT
	fecha_admin DATE NOT NULL,
	num_lote TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),
	-- FOREIGN KEY (id_vacuna) REFERENCES farmaco (id)

	/*CONSTRAINT id_snomed_valido CHECK (id_snomed_vacuna ~ '^[1-9][0-9]{5,17}$'),
	CONSTRAINT id_snomed_identifica_concepto CHECK (RIGHT(id_snomed_vacuna, 3) ~ '^(00|10)[0-9]$'),

	CONSTRAINT fecha_admin_validez_validas CHECK(
		(fecha_validez IS NULL AND fecha_admin <= CURRENT_DATE)
		OR
		(fecha_admin <= CURRENT_DATE AND fecha_validez > fecha_admin)
	),

	CONSTRAINT num_repeticion_positivo CHECK (num_repeticion > 0),
	CHECK num_lote_valido CHECK (length(num_lote) =< 30)*/

);

CREATE TABLE IF NOT EXISTS registro_habitos(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,

	id_snomed_habito TEXT NOT NULL,
	concepto_snomed_habito TEXT NOT NULL,

	anno_inicio SMALLINT,
	anno_fin SMALLINT,
	edad_inicio SMALLINT,
	edad_fin SMALLINT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),

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

	id_snomed TEXT NOT NULL,
	concepto_snomed TEXT NOT NULL,

	dosis DECIMAL,
	ud_dosis TEXT,
	anno_inicio SMALLINT,
	anno_fin SMALLINT,
	edad_inicio SMALLINT,
	edad_fin SMALLINT,

	id_snomed_patron TEXT,
	concepto_patron_snomed TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),

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

	-- Habría que comprobar que la edad coincide con las posibilidades según la fecha de inicio y fin 
	--(un año +- dependiendo de la fecha de nacimiento del paciente)
	CONSTRAINT edad_inicio_fin_validas CHECK(
		(edad_inicio IS NULL AND edad_fin IS NULL) 
		OR
		(edad_fin IS NULL AND edad_inicio >= 0)
		OR
		(edad_fin >= 0 AND edad_inicio >= 0 AND edad_inicio <= edad_fin)
	)
);

/*
En el caso de las fórmulas magistrales, la fecha de inicio no es obligatoria.
*/
CREATE TABLE IF NOT EXISTS registro_tratamiento(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_paciente BIGINT NOT NULL,
	tipo_tratamiento TEXT NOT NULL,
	cod_fármaco TEXT NOT NULL,
	nombre_fármaco TEXT NOT NULL,
	cod_nombre_comercial TEXT,
	nombre_comercial TEXT,

	fecha_inicio DATE NOT NULL,
	fecha_fin DATE,
	
	cod_via_admin_aemps, TEXT,
	via_admin_aemps TEXT,

	-- Estos no deben ser NULL si el tratamiento es un medicamente, pero pueden serlo en caso de una fórmula magistral
	cod_dosis TEXT,
	dosis TEXT ,
	Posología TEXT,

	FOREIGN KEY (id_paciente) REFERENCES pacientes (id),

	CONSTRAINT id_snomed_valido CHECK (id_snomed ~ '^[1-9][0-9]{5,17}$'),
	CONSTRAINT id_snomed_identifica_concepto CHECK (RIGHT(snomed_id, 3) ~ '^(00|10)[0-9]$')
	CONSTRAINT fecha_inicio_fin_validas CHECK(fecha_fin > fecha_inicio),
);

/* ================== TO-DO ===================

Falta prubas, alertas, enfermería y situación funcional.

registro_prueba_laboratorio	
registro_resultado_laboratorio
registro_cuidados_enfermeria

Alertas: 
valor codificado de la alerta en CIE, SNOMED CT, CIAP.

Enfermería:  
Diagnósticos activos y no activos (aunque el informe solo pide activos). 
OBLIGATORIO: tratamiento, recomendaciones
Opcional: diagnóstico, fecha, intervencion, fecha, resultados, fecha, recomendaciones de cuidados enfermeros
Puede hacer intervenciones no vinculadasa diagnóstico

Situación funcional
Escala (SNOMED CT), resultado, interpretación --> situación funcional (SNOMED CT)

*/

-- =======================================================================================================================
-- =======================================================================================================================


-- HCE TESAUROS EN DESUSO

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

