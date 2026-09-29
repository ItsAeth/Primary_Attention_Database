-- // EMPLEADOS

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

-- // PACIENTES

INSERT INTO pacientes
(tipo_id, num_id, nombre, apellido1, apellido2, fecha_nacimiento, sexo, email, pais_nac, reside_cp, reside_muni, cip_sns, nass, n_hc, med_cabecera)
VALUES
-- DNI, nacimiento en España, todos los opcionales informados
('DNI', '11223344A', 'María', 'Gómez', 'Fernández', '1975-03-12', 'Mujer', 'maria.gomez@paciente.test', '724', '24001', '240001', 'BBBBBBBBaa123456', '241234567890', '00000001', 1),
-- DNI, sin apellido2
('DNI', '44556677D', 'Miguel', 'Sánchez', NULL, '1959-01-14', 'Varón', 'miguel.sanchez@paciente.test', '724', '24006', '240006', 'BBBBBBBBaf123461', '241234567895', '00000006', 2),
-- NIE, nacimiento en Portugal
('NIE', 'X1234567L', 'Ana', 'Costa', 'Silva', '1991-11-08', 'Mujer', 'ana.costa@paciente.test', '620', '24003', '240003', 'BBBBBBBBac123458', '241234567892', '00000003', 3),
-- NIE, país de nacimiento desconocido, sin email ni NASS
('NIE', 'Y7654321Z', 'Laura', 'Vega', NULL, '1995-09-30', 'Mujer', NULL, 'ZZZ', '24005', '240005', 'BBBBBBBBae123460', NULL, 'HC000005', 1),
-- NIE, nacimiento en España, sin NASS
('NIE', 'Z2345678R', 'David', 'Pérez', 'Núñez', '2000-12-03', 'Varón', 'david.perez@paciente.test', '724', '24008', '240008', 'BBBBBBBBah123463', "241789234561", '00000008', 6);

INSERT INTO tlf_pacientes
(id_paciente, tipo_tlf, num_tlf)
VALUES
(1, 'Móvil', '+34678901234'),
(2, 'Móvil', '+34789012345'),
(2, 'Fijo', '+34714234567'),
(3, 'Móvil', '+34987654321'),
(3, 'Fijo', '+34712234567'),
(4, 'Móvil', '+34876543210'),
(5, 'Móvil', '+34765432109');