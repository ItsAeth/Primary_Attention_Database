/* 
Restricciones de empleados:
    - Tener DNI/NIE válidos
    - Nombre y apellidos no tienen dígitos
    - Ser mayor de edad
    - Datos de contacto: formato de email y códigos ISO de domicilio válidos.
*/
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
ADD CONSTRAINT empleado_mayor_de_edad CHECK (fecha_nacimiento <= CURRENT_DATE - INTERVAL '18 years'),
ADD CONSTRAINT sexo_es_valido CHECK (sexo IN ('Varón', 'Mujer', 'No especificado')),
ADD CONSTRAINT email_es_valido CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
ADD CONSTRAINT pais_nac_es_valido CHECK (length(pais_nac) = 3 OR pais_nac = "ZZZ"),
ADD CONSTRAINT reside_cp CHECK (length(reside_cp) = 3 OR reside_cp ~ '^53[0-9]{3}'),
ADD CONSTRAINT reside_muni CHECK (length(reside_muni) = 3 OR reside_muni ~ '^530[0-9]{3}')
