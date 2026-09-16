/* 
Restricciones de empleados:
    - Tener DNI/NIE válidos
    - Nombre y apellidos no tienen dígitos
    - Sexo dentro de las categorias aceptadas
    - Datos de contacto: formato de email y códigos ISO de domicilio país.
        - pais_nac: Código ISO de país de nacimiento. 3 dígitos o ZZZ si se desconoce.
        - reside_cp: Código postal de 5 letras, o 53 + cod. ISO para extranjeros.
        - reside_muni: Código ISO de municipio de residencia de 6 letras, o 530 + ISO para extranjeros.
*/

-- // PERSONAL DEL CENTRO Y TURNOS

ALTER TABLE IF EXISTS empleados
ADD CONSTRAINT tipo_id_es_valido CHECK (tipo_id IN ('DNI','NIE')),
ADD CONSTRAINT num_id_es_valido CHECK (
    (tipo_id = 'DNI' AND num_id ~ '^[0-9]{8}[A-Z]$')
		OR
	(tipo_id = 'NIE' AND num_id ~ '^[XYZ][0-9]{7}[A-Z]$')
),
ADD CONSTRAINT nombre_apellidos_sin_digitos CHECK(
		(nombre !~ '[0-9]') AND 
		(apellido1 !~ '[0-9]') AND 
		(apellido2 !~ '[0-9]' OR apellido2 IS NULL)
),
ADD CONSTRAINT sexo_es_valido CHECK (sexo IN ('Varón', 'Mujer', 'No especificado')),
ADD CONSTRAINT email_es_valido CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR email IS NULL),
ADD CONSTRAINT pais_nac_es_valido CHECK (pais_nac ~ '^[0-9]{3}$' OR pais_nac = 'ZZZ'),
ADD CONSTRAINT reside_cp_es_valido CHECK (reside_cp ~ '^[0-9]{5}$' OR reside_cp ~ '^53[0-9]{3}$'),
ADD CONSTRAINT reside_muni_es_valido CHECK (reside_muni ~ '^[0-9]{6}$' OR reside_muni ~ '^530[0-9]{3}$');

-- Restricciones teléfono de empleados: tipo y formato E.164.
ALTER TABLE IF EXISTS tlf_empleados
ADD CONSTRAINT num_tlf_formato_E164 CHECK (num_tlf ~ '^\+[1-9][0-9]{1,14}$');

-- Restricciones para info de sanitarios: formato de cias y nº de colegiado
ALTER TABLE IF EXISTS info_sanitarios
ADD CONSTRAINT cias_es_valido CHECK (cias ~ '^[0-9]{10}[A-Z]$'),
ADD CONSTRAINT num_colegiado_es_valido CHECK (length(num_colegiado) = 9);   -- TODO: validar más a parte de longitud

-- Restricciones turnos: tipo de turno válido. Fecha de salida debe ser mayor a fecha de entrada
ALTER TABLE IF EXISTS turnos
ADD	CONSTRAINT tipo_turno_valido CHECK (tipo_turno IN ('Ordinario', 'Guardia')),
ADD CONSTRAINT fin_mayor_inicio CHECK (fin > inicio);

-- // PACIENTES

-- Mismas restricciones que empleados, a parte del formato del CIP_SNS y el NASS.
ALTER TABLE IF EXISTS pacientes
ADD	CONSTRAINT tipo_id_es_valido CHECK (tipo_id IN ('DNI','NIE')),
ADD	CONSTRAINT num_id_es_valido CHECK (
		(tipo_id = 'DNI' AND num_id ~ '^[0-9]{8}[A-Z]$')
		OR
		(tipo_id = 'NIE' AND num_id ~ '^[XYZ][0-9]{7}[A-Z]$')
	),
ADD CONSTRAINT nombre_apellidos_sin_digitos CHECK(
		(nombre !~ '[0-9]') AND 
		(apellido1 !~ '[0-9]') AND 
		(apellido2 !~ '[0-9]' OR apellido2 IS NULL)
	),
ADD CONSTRAINT sexo_es_valido CHECK (sexo IN ('Varón', 'Mujer', 'No especificado')),
ADD CONSTRAINT email_es_valido CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR email IS NULL),
ADD CONSTRAINT pais_nac_es_valido CHECK (pais_nac ~ '^[0-9]{3}$' OR pais_nac = 'ZZZ'),
ADD CONSTRAINT reside_cp_es_valido CHECK (reside_cp ~ '^[0-9]{5}$' OR reside_cp ~ '^53[0-9]{3}$'),
ADD CONSTRAINT reside_muni_es_valido CHECK (reside_muni ~ '^[0-9]{6}$' OR reside_muni ~ '^530[0-9]{3}$'),
ADD	CONSTRAINT cip_sns_es_valido CHECK (cip_sns ~ '^B{8}[a-z]{2}[0-9]{6}$'),
ADD	CONSTRAINT nass_es_valido CHECK (nass ~ '^[0-9]{12}$');

-- Teléfonos fijos y móviles de pacientes: categorias válidas y formato
ALTER TABLE IF EXISTS tlfno_pacientes
ADD	CONSTRAINT tipo_tlf_es_valido CHECK (tipo_tlf IN ('Fijo', 'Móvil')),
ADD	CONSTRAINT num_tlf_es_valido CHECK (num_tlf ~ '^\+[1-9][0-9]{1,14}$');

-- Citas: categorias válidas de modalidad y estado. Timestamp de fin posterior a timestamp de inicio.
ALTER TABLE IF EXISTS citas
ADD	CONSTRAINT modalidad_es_valida CHECK (modalidad IN ('Presencial', 'Telemática')),
ADD	CONSTRAINT fecha_fin_mayor_inicio CHECK (fin > inicio),
ADD	CONSTRAINT estado_es_valido CHECK (estado IN ('Pendiente_aceptación', 'Aceptada', 'Cancelada', 'Finalizada', 'No presentado'));

-- Episodios: categorias válidas. Timestamp de fin posterior a timestamp de inicio.
ALTER TABLE IF EXISTS episodios
ADD	CONSTRAINT tipo_episodio_valido CHECK (tipo IN ('Seguimiento', 'Consulta', 'Urgencia', 'Prevención', 'Administrativo')),
ADD	CONSTRAINT fecha_fin_mayor_inicio CHECK (fin > inicio),
ADD	CONSTRAINT nivel_triaje_valido CHECK (nivel_triaje IS NULL OR nivel_triaje IN ('Azul', 'Verde', 'Amarillo', 'Naranja', 'Rojo')),
ADD	CONSTRAINT resultado_valido CHECK (resultado IN ('Alta', 'Derivación', 'Pruebas'));
