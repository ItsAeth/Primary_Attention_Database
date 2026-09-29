---------------
-- EMPLEADOS --
---------------

INSERT INTO empleados
(tipo_id, num_id, nombre, apellido1, apellido2, fecha_nacimiento, sexo, email, pais_nac, reside_cp, reside_muni)
VALUES
-- Sanitarios españoles
('DNI', '12345678A', 'Laura', 'García', 'Martín', '1982-04-15', 'Mujer', 'laura.garcia@centro.test', '724', '24001', '240001'),
('DNI', '23456789B', 'Carlos', 'Fernández', 'López', '1978-09-22', 'Varón', 'carlos.fernandez@centro.test', '724', '24002', '240002'),
('DNI', '56789012E', 'Ana', 'Martínez', 'Ruiz', '1992-11-28', 'Mujer', 'ana.martinez@centro.test', '724', '24005', '240005'),

-- No sanitario, mismo DNI y email que otro empleado
('DNI', '67890123F', 'Miguel', 'Sánchez', 'Díaz', '1986-02-14', 'Mujer', 'personal@centro.test', '724', '24006', '240006'),
-- No sanitario, país de nacimiento desconocido
('DNI', '67890123F', 'Lucía', 'Sánchez', 'Díaz', '1988-06-17','Mujer', 'personal@centro.test', DEFAULT, '24006', '240006'),
-- Extranjero
('NIE', 'X1234567L', 'Elena', 'Costa', 'Vidal', '1995-03-09', 'Mujer', 'elena.costa@centro.test', '620', '24007', '240007');

INSERT INTO tlf_empleados 
(id_empleado, num_tlf)
VALUES
(1, '+34612345678'),
(2, '+34623456789'),
(3, '+34634567890'),
(4, '+34645678901'),
(5, '+34656789012'),
(6, '+34667890123');

INSERT INTO info_sanitarios
(id_empleado, cias, num_colegiado, especialidad)
VALUES
(1, '1234567890A', '240000001', 'Medicina Familiar y Comunitaria'),
(2, '2345678901B', '240000002', 'Enfermería Familiar y Comunitaria'),
(3, '3456789012C', '240000003', 'Pediatría'),
(6, '4567890123D', '240000004', 'Medicina Familiar y Comunitaria');

INSERT INTO turnos
(id_empleado, tipo_turno, inicio, fin)
VALUES
(1, 'Ordinario', '2026-09-28 08:00:00+02', '2026-09-28 15:00:00+02'),
(2, 'Ordinario', '2026-09-28 08:00:00+02', '2026-09-28 15:00:00+02'),
(3, 'Ordinario', '2026-09-28 09:00:00+02', '2026-09-28 16:00:00+02'),
(4, 'Ordinario', '2026-09-28 08:00:00+02', '2026-09-28 15:00:00+02'),
(5, 'Ordinario', '2026-09-28 08:00:00+02', '2026-09-28 15:00:00+02'),
(6, 'Ordinario', '2026-09-28 09:00:00+02', '2026-09-28 16:00:00+02'),
(1, 'Guardia', '2026-09-28 15:00:00+02', '2026-09-29 08:00:00+02'),
(2, 'Guardia', '2026-09-29 15:00:00+02', '2026-09-30 08:00:00+02'),
(3, 'Guardia', '2026-09-30 15:00:00+02', '2026-10-01 08:00:00+02'),
(6, 'Guardia', '2026-10-01 15:00:00+02', '2026-10-02 08:00:00+02');