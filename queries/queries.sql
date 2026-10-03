-- ACTIVIDAD DEL CENTRO

--¿Cuántas citas hay por estado y modalidad (número y porcentaje del total)?
SELECT
    estado, 
    COUNT(id) AS Numero_de_citas, 
    ROUND(COUNT(id) * 100 / (SELECT COUNT(id) FROM citas), 2) AS porcentaje
FROM citas
GROUP BY estado;

SELECT
    modalidad, 
    COUNT(id) AS Numero_de_citas, 
    ROUND(COUNT(id) * 100 / (SELECT COUNT(id) FROM citas), 2) AS porcentaje
FROM citas
GROUP BY modalidad;

-- Porcentaje de no presentados respecto al resto de las citas planificadas
SELECT
    CASE 
        WHEN estado = 'No presentado' THEN 'No presentado'
        ELSE 'Resto'
    END AS presentado_o_no,
    COUNT(*) as num_citas,
    ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM citas), 2) AS porcentaje
FROM citas
GROUP BY presentado_o_no;

-- Días de la semana con más citas
WITH dias_semana AS (
    SELECT EXTRACT('ISODOW' FROM inicio) as dia
    FROM citas
)
SELECT ds.dia, COUNT(*) AS num_citas
FROM dias_semana ds
GROUP BY ds.dia
ORDER BY num_citas DESC;

-- ¿Quieren son los profesionales de cada especialidad que más citas atienden (Aceptadas y Finalizadas)?

WITH
emp_sanitarios AS (
    SELECT 
        e.id,
        s.especialidad
    FROM empleados e 
    JOIN info_sanitarios s ON e.id = s.id_empleado
),
emp_sanitarios_ranked AS (
    SELECT
        es.id,
        es.especialidad,
        COUNT(c.id) as num_citas_atendidas,
        RANK() OVER (
            PARTITION BY es.especialidad
            ORDER BY COUNT(c.id) DESC
        ) AS ranking
    FROM citas c JOIN emp_sanitarios es ON c.id_sanitario = es.id
    WHERE c.estado IN ('Finalizada', 'Aceptada')
    GROUP BY es.especialidad, es.id
)
SELECT
    esr.ranking as ranking_en_especialidad,
    esr.num_citas_atendidas,
    esr.especialidad,
    e.num_id,
    COALESCE (
        e.nombre || ' ' || e.apellido1 || ' ' || e.apellido2,
        e.nombre || ' ' || e.apellido1 ) 
    as nombre_completo
FROM emp_sanitarios_ranked esr JOIN empleados e ON e.id = esr.id
ORDER BY esr.especialidad ASC, esr.ranking ASC;

-- EPISODIOS

-- Recuento y duración promedio de cada tipo de episodio.
SELECT 
    tipo_episodio,
    COUNT(*) AS recuento,
    TO_CHAR(AVG(fin - inicio), 'HH24:MI:SS') AS duracion_media
FROM episodio
GROUP BY tipo_episodio
ORDER BY recuento DESC, duracion_media ASC;

-- Los 2 diagnósticos más frecuentes por tipo de episodio (con empates)
WITH ranked as (
    SELECT 
        tipo_episodio,
        COALESCE(id_diag_snomed, 'Sin diagnóstico') AS diagnostico,
        RANK() OVER (
            PARTITION BY tipo_episodio
            ORDER BY COUNT(*) DESC
        ) as ranking
    FROM episodio
    GROUP BY tipo_episodio, id_diag_snomed
)
SELECT *
FROM ranked
WHERE ranking <= 2
ORDER BY tipo_episodio, ranking;

-- ¿Qué nivel de triaje y resultado tienen los episodios de urgencias que más duran en promedio?
SELECT 
    nivel_triaje,
    resultado, 
    COUNT(*) AS recuento,
    TO_CHAR(AVG(fin-inicio), 'HH24:MI:SS') as duracion_media
FROM episodio
WHERE tipo_episodio = 'Urgencia'
GROUP BY nivel_triaje, resultado
ORDER BY duracion_media DESC

-- Evolución de episodios por periodo
-- Citas asociadas a episodios



-- PACIENTES

-- Perfil del paciente más habitual en el centro
-- Tasa de no presentación del paciente
-- Pacientes con más citas
-- Pacientes sin vacunaciones
-- Distribución de edad

-- HCE

-- Medicamentos y principio activo más comunes entre los pacientes.
-- Alergias más comunes entre los pacientes.
-- Nº de vacunas administradas por (periodo de tiempo)
-- Hábitos perjudiciales y tóxicos más frecuentes entre los pacientes.
-- Antecedentes más frecuentes entre los pacientes
-- Distribución por tipo de antecedente

/*
Obtener todos los registros relacionados con la historia clínica deL paciente con DNI '44556677D'.
Mostrar todas la información de cada regisstro, el nombre y los apellidos del paciente.

Las diferencias en la cantidad de columnas impide usar UNION ALL
*/

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_antecedentes r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_antecedentes_familiares r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_dispositivos r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_alergias r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_situaciones_funcionales r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_habitos r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_toxicos r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_vacunaciones r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_medicamentos r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_formulas_magistrales r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';