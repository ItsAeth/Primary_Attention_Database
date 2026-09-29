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

INSERT INTO tlf_empleados (id_empleado, num_tlf) VALUES
(1, '+34612345678'),
(2, '+34623456789'),
(3, '+34634567890'),
(4, '+34645678901'),
(5, '+34656789012'),
(6, '+34667890123');

INSERT INTO info_sanitarios (id_empleado, cias, num_colegiado, especialidad) VALUES
(1, '1234567890A', '240000001', 'Medicina Familiar y Comunitaria'),
(2, '2345678901B', '240000002', 'Enfermería Familiar y Comunitaria'),
(3, '3456789012C', '240000003', 'Pediatría'),
(6, '4567890123D', '240000004', 'Medicina Familiar y Comunitaria');

INSERT INTO turnos (id_empleado, tipo_turno, inicio, fin) VALUES
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
('NIE', 'Z2345678R', 'David', 'Pérez', 'Núñez', '2000-12-03', 'Varón', 'david.perez@paciente.test', '724', '24008', '240008', 'BBBBBBBBah123463', '241789234561', '00000008', 6);

INSERT INTO tlf_pacientes (id_paciente, tipo_tlf, num_tlf) VALUES
(1, 'Móvil', '+34678901234'),
(2, 'Móvil', '+34789012345'),
(2, 'Fijo', '+34714234567'),
(3, 'Móvil', '+34987654321'),
(3, 'Fijo', '+34712234567'),
(4, 'Móvil', '+34876543210'),
(5, 'Móvil', '+34765432109');

-- // Citas y episodios

INSERT INTO citas (id_paciente, id_sanitario, inicio, fin, modalidad, lugar, estado) VALUES
(1, 1, '2026-09-01 09:00:00+02', '2026-09-01 09:15:00+02', 'Presencial', 'Consulta 1', 'Finalizada'),
(2, 1, '2026-09-01 09:30:00+02', '2026-09-01 09:50:00+02', 'Presencial', 'Consulta 1', 'Finalizada'),
(3, 2, '2026-09-02 10:00:00+02', '2026-09-02 10:30:00+02', 'Presencial', 'Consulta 2', 'Finalizada'),
(4, 2, '2026-09-03 11:00:00+02', '2026-09-03 11:20:00+02', 'Presencial', 'Consulta 2', 'Cancelada'),
(5, 3, '2026-09-04 12:00:00+02', '2026-09-04 12:20:00+02', 'Presencial', 'Consulta 3', 'Finalizada'),
(1, 2, '2026-09-05 09:00:00+02', '2026-09-05 09:10:00+02', 'Telemática', NULL, 'Finalizada'),
(2, 3, '2026-09-05 10:30:00+02', '2026-09-05 10:45:00+02', 'Telemática', NULL, 'Finalizada'),
(3, 1, '2026-09-08 16:00:00+02', '2026-09-08 16:15:00+02', 'Telemática', NULL, 'Cancelada'),
(4, 6, '2026-09-09 09:00:00+02', '2026-09-09 09:30:00+02', 'Telemática', NULL, 'Finalizada'),
(5, 6, '2026-09-10 11:00:00+02', '2026-09-10 11:30:00+02', 'Telemática', NULL, 'No presentado'),
(1, 6, '2026-10-01 09:00:00+02', '2026-10-01 09:20:00+02', 'Presencial', 'Consulta 4', 'Pendiente_aceptación'),
(2, 6, '2026-10-01 09:30:00+02', '2026-10-01 10:00:00+02', 'Presencial', 'Consulta 4', 'Aceptada'),
(3, 1, '2026-10-02 12:00:00+02', '2026-10-02 12:20:00+02', 'Telemática', NULL, 'Aceptada'),
(4, 2, '2026-10-03 17:00:00+02', '2026-10-03 17:30:00+02', 'Telemática', NULL, 'Pendiente_aceptación'),
(5, 3, '2026-09-15 08:30:00+02', '2026-09-15 09:30:00+02', 'Presencial', 'Consulta 3', 'Finalizada'),
(1, 3, '2026-09-16 13:00:00+02', '2026-09-16 14:00:00+02', 'Presencial', 'Consulta 3', 'Finalizada'),
(2, 6, '2026-09-20 10:00:00+02', '2026-09-20 10:20:00+02', 'Presencial', 'Consulta 4', 'Aceptada'),
(3, 1, '2026-09-21 11:00:00+02', '2026-09-21 11:20:00+02', 'Presencial', NULL, 'Aceptada'),
(1, 2, '2026-09-22 09:00:00+02', '2026-09-22 09:20:00+02', 'Presencial', 'Consulta 1', 'Finalizada'),
(1, 6, '2026-09-23 10:00:00+02', '2026-09-23 10:30:00+02', 'Telemática', NULL, 'Finalizada'),
(1, 1, '2026-09-24 12:00:00+02', '2026-09-24 12:15:00+02', 'Telemática', NULL, 'Finalizada'),
(2, 1, '2026-09-25 09:00:00+02', '2026-09-25 09:20:00+02', 'Presencial', 'Consulta 1', 'Finalizada'),
(3, 3, '2026-09-25 10:00:00+02', '2026-09-25 10:30:00+02', 'Presencial', 'Consulta 3', 'Finalizada'),
(4, 6, '2026-09-26 11:00:00+02', '2026-09-26 11:20:00+02', 'Telemática', NULL, 'Finalizada'),
(5, 2, '2026-09-26 12:00:00+02', '2026-09-26 12:30:00+02', 'Telemática', NULL, 'Cancelada');

INSERT INTO episodio
(tipo_episodio, procedencia, tipo_consulta, id_snomed_motivo_consulta, id_cie_motivo_consulta, id_paciente, id_sanitario, inicio, fin, nivel_triaje, id_diag_snomed, observaciones, resultado)
VALUES
('Consulta', 'Demanda propia', 'Consulta médica', '22298006', 'R51.9', 1, 1, '2026-09-01 09:00:00+02', '2026-09-01 09:20:00+02', NULL, '22298006', 'Cefalea de varios días de evolución.', 'Pruebas'),
('Seguimiento', 'Atención primaria', 'Seguimiento de enfermedad', '38341003', 'I10', 2, 1, '2026-09-02 10:00:00+02', '2026-09-02 10:20:00+02', NULL, '38341003', 'Revisión de hipertensión arterial.', NULL),
('Consulta', 'Demanda propia', 'Consulta de enfermería', '84229001', 'R53.83', 3, 2, '2026-09-03 11:00:00+02', '2026-09-03 11:30:00+02', NULL, '84229001', 'Refiere cansancio y debilidad.', 'Alta'),
('Urgencia', 'Urgencias', 'Consulta urgente', '21522001', 'R10.9', 4, 1, '2026-09-04 12:00:00+02', '2026-09-04 12:45:00+02', 'Amarillo', '21522001', 'Dolor abdominal de inicio reciente.', 'Derivación'),
('Prevención', 'Programa de prevención', 'Consulta preventiva', '268565007', 'Z00.00', 5, 3, '2026-09-05 09:00:00+02', '2026-09-05 09:30:00+02', NULL, '268565007', 'Revisión médica preventiva.', 'Alta'),
('Administrativo', 'Atención primaria', 'Consulta administrativa', '308335008', 'Z02.9', 1, 6, '2026-09-08 10:00:00+02', '2026-09-08 10:15:00+02', NULL, NULL, 'Gestión de documentación sanitaria.', 'Alta'),
('Consulta', 'Demanda propia', 'Consulta médica', '49727002', 'R05.9', 2, 1, '2026-09-09 16:00:00+02', '2026-09-09 16:20:00+02', NULL, '49727002', 'Tos persistente.', 'Pruebas'),
('Urgencia', '112', 'Consulta urgente', '404640003', 'R42', 3, 6, '2026-09-10 18:00:00+02', '2026-09-10 18:30:00+02', 'Naranja', '404640003', 'Mareo de aparición brusca.', 'Derivación'),
('Seguimiento', 'Atención primaria', 'Seguimiento de enfermedad', '44054006', 'E11.9', 4, 1, '2026-09-11 09:30:00+02', '2026-09-11 09:50:00+02', NULL, '44054006', 'Seguimiento de diabetes mellitus tipo 2.', NULL),
('Consulta', 'Demanda propia', 'Consulta de enfermería', '84229001', 'R53.83', 5, 2, '2026-09-12 11:00:00+02', '2026-09-12 11:25:00+02', NULL, '84229001', 'Cansancio referido por el paciente.', 'Alta'),
('Urgencia', 'Centro de salud', 'Consulta urgente', '386661006', 'R50.9', 1, 1, '2026-09-15 13:00:00+02', '2026-09-15 13:40:00+02', 'Verde', '386661006', 'Fiebre sin foco aparente.', 'Pruebas'),
('Prevención', 'Programa de prevención', 'Revisión preventiva', '268565007', 'Z00.00', 2, 3, '2026-09-16 10:00:00+02', '2026-09-16 10:30:00+02', NULL, '268565007', 'Revisión general del estado de salud.', 'Alta'),
('Seguimiento', 'Atención primaria', 'Seguimiento de enfermedad', '195967001', 'J45.909', 3, 1, '2026-09-17 09:00:00+02', '2026-09-17 09:20:00+02', NULL, '195967001', 'Control de evolución del asma.', NULL),
('Consulta', 'Demanda propia', 'Consulta médica', '279039007', 'M54.50', 4, 1, '2026-09-18 12:00:00+02', '2026-09-18 12:25:00+02', NULL, '279039007', 'Dolor lumbar.', 'Alta'),
('Administrativo', 'Atención primaria', 'Consulta administrativa', '308335008', 'Z02.9', 5, 6, '2026-09-19 09:00:00+02', '2026-09-19 09:15:00+02', NULL, NULL, 'Actualización de documentación sanitaria.', 'Alta'),
('Urgencia', 'Urgencias', 'Consulta urgente', '422587007', 'R11.2', 5, 6, '2026-09-20 17:00:00+02', '2026-09-20 17:35:00+02', 'Amarillo', '422587007', 'Náuseas y vómitos.', 'Derivación'),
('Consulta', 'Demanda propia', 'Consulta médica', '29857009', 'R07.9', 1, 1, '2026-09-22 10:00:00+02', '2026-09-22 10:30:00+02', NULL, '29857009', 'Molestias torácicas.', 'Pruebas'),
('Seguimiento', 'Atención primaria', 'Seguimiento de enfermedad', '55822004', 'E78.5', 2, 1, '2026-09-23 11:00:00+02', '2026-09-23 11:20:00+02', NULL, '55822004', 'Control de hipercolesterolemia.', NULL),
('Urgencia', 'Centro de salud', 'Consulta urgente', '422587007', 'R11.0', 3, 2, '2026-09-24 15:00:00+02', '2026-09-24 15:30:00+02', 'Verde', '422587007', 'Náuseas sin otros síntomas de alarma.', 'Alta'),
('Prevención', 'Programa de prevención', 'Consulta preventiva', '268565007', 'Z00.00', 4, 3, '2026-09-25 09:00:00+02', '2026-09-25 09:30:00+02', NULL, '268565007', 'Revisión médica preventiva.', 'Alta');

-- // Registros de historia clínica electronica

-- Antecedentes (en general)
INSERT INTO registro_antecedentes
(id_paciente, tipo_antecedente, id_snomed_antecedente, id_CIE, fecha_inicio, fecha_fin)
VALUES
(1, 'Enfermedad previa', '38341003', 'I10', '2018-04-12', NULL),
(2, 'Quirúrgico', '1337319005', 'Z98.89', '2015-06-20', NULL),
(3, 'Social', '160903007', 'Z72.0', '2010-01-01', '2018-12-31'),
(4, 'Profesional', '160903007', 'Z57.9', '2017-09-01', NULL),
(5, 'Neonatal', '276654001', 'P07.3', '2000-12-03', NULL),
(1, 'Obstétrico', '169320002', 'Z87.59', '2005-05-10', NULL);

-- Antecedentes familiares
INSERT INTO registro_antecedentes_familiares
(id_paciente, id_snomed_antecedente, id_cie_antecedente, id_gr_parentesco_snomed, edad_inicio)
VALUES
(1, '38341003', 'I10', '72705000', 52),
(2, '73211009', 'E11.9', '72704001', 61),
(3, '56265001', 'C50.9', '72705000', 48),
(4, '267432004', 'J45.909', '145341000119100', 35),
(5, '44054006', 'E11.9', '72705000', 55);

-- Dispositivos
INSERT INTO registro_dispositivos
(id_paciente, id_snomed_dispositivo, cod_emdn_dispositivo, fecha_implantacion, fecha_retirada, id_dispositivo_fabrica)
VALUES
(1, '36014003', 'P030301', '2020-03-15', NULL, 'SN001234567890123456'),
(2, '86184003', 'P030101', '2018-07-20', '2024-05-10', 'SN002345678901234567'),
(3, '70678003', 'P030201', '2022-11-04', NULL, 'SN003456789012345678'),
(5, '36014003', 'P030301', '2021-02-18', NULL, NULL);

-- Alergias
INSERT INTO registro_alergias
(id_paciente, id_snomed_alérgeno, id_snomed_man_clin, id_cie_man_clin, cod_tipo_reacc_ehdsi, cod_gravedad_ehdsi, cod_criticidad_ehdsi, cod_certeza_ehdsi, cod_estado_ehdsi, fecha_inicio, fecha_fin)
VALUES
(1, '387517004', '39579001', 'T88.7', 'ALLERGIC_REACTION', 'MILD', 'LOW', 'CONFIRMED', 'ACTIVE', '2019-06-12', NULL),
(2, '300916003', '271807003', 'T78.1', 'ALLERGIC_REACTION', 'MODERATE', 'LOW', 'CONFIRMED', 'ACTIVE', '2021-03-20', NULL),
(3, '764146007', '247472004', 'L27.0', 'ALLERGIC_REACTION', 'MILD', 'LOW', 'SUSPECTED', 'INACTIVE', '2018-05-01', '2020-08-15'),
(5, '300916003', '39579001', 'T88.7', 'ALLERGIC_REACTION', 'MILD', 'LOW', 'CONFIRMED', 'ACTIVE', '2023-01-10', NULL);

-- Vacunaciones
INSERT INTO registro_vacunaciones
(id_paciente, id_snomed_vacuna, cod_nom_comercial, fecha_admin, num_lote)
VALUES
(1, '111525008', 'COVID19-VAC', '2025-10-15', 'AB12345'),
(1, 'IMM-001', 'GRIPE-VAC', '2025-10-20', 'GRI2025A01'),
(2, '111525008', 'COVID19-VAC', '2025-09-18', 'AB67890'),
(3, '111525008', 'COVID19-VAC', '2024-11-12', 'CD12345'),
(4, 'IMM-001', 'GRIPE-VAC', '2025-10-22', NULL),
(5, '111525008', 'COVID19-VAC', '2025-08-30', 'EF54321');

-- Hábitos perjudiciales
INSERT INTO registro_habitos
(id_paciente, id_snomed_habito, anno_inicio, anno_fin)
VALUES
(1, '77176002', 1998, 2010),
(2, '77176002', 1980, 2015),
(3, '229819007', 2015, NULL),
(4, '77176002', NULL, NULL),
(5, '229819007', 2020, NULL);

-- Tóxicos
INSERT INTO registro_toxicos
(id_paciente, id_snomed_toxico, id_snomed_patron_consumo, dosis, ud_dosis, anno_inicio, anno_fin)
VALUES
(1, '77176002', '225799002', 10, 'cigarrillos/día', 1998, 2010),
(2, '56246009', '228276006', 2, 'unidades/día', 2000, 2018),
(3, '266918002', '228276006', 1, 'unidades/semana', 2020, NULL),
(4, '77176002', NULL, NULL, NULL, NULL, NULL),
(5, '56246009', '225799002', 3, 'unidades/semana', 2022, NULL);

-- Medicamentos
INSERT INTO registro_medicamentos
(id_paciente, cod_farmaco, cod_nombre_comercial, fecha_inicio, fecha_fin, cod_via_admin_aemps, cod_dosis_edqm, posologia)
VALUES
(1, 'C09AA05', 'ENALAPRIL', '2018-04-12', NULL, 'ORAL', 'MG', '1 comprimido cada 24 horas'),
(2, 'C10AA01', 'SIMVASTATINA', '2020-02-01', NULL, 'ORAL', 'MG', '1 comprimido cada 24 horas'),
(3, 'R03AC02', 'SALBUTAMOL', '2022-05-10', '2022-06-10', 'INHALACION', 'MG', '1 inhalación cuando sea necesario'),
(4, 'N02BE01', 'PARACETAMOL', '2025-01-15', '2025-01-20', 'ORAL', 'MG', '1 comprimido cada 8 horas'),
(5, 'A10BA02', 'METFORMINA', '2024-03-01', NULL, 'ORAL', 'MG', '1 comprimido cada 12 horas');

-- Fórmulas magistrales
INSERT INTO registro_formulas_magistrales
(id_paciente, id_formula, fecha_inicio, fecha_fin, id_via_administracion, dosis, frecuencia)
VALUES
(1, 'FM-0001', '2024-01-10', '2024-01-20', 'ORAL', '10 mg', 'Cada 24 horas'),
(2, 'FM-0002', '2023-06-15', NULL, 'TOPICA', '2%', 'Cada 12 horas'),
(3, 'FM-0003', '2025-02-01', '2025-02-15', 'ORAL', '5 ml', 'Cada 8 horas'),
(5, 'FM-0004', '2025-04-20', NULL, 'TOPICA', '1 aplicación', 'Cada 24 horas');

-- Situaciones funcionales
INSERT INTO registro_situaciones_funcionales
(id_paciente, id_snomed_escala, resultado, interpretacion, id_snomed_situacion_funcional)
VALUES
(1, '273295006', '95', 'Independiente', '284196006'),
(2, '273295006', '70', 'Dependencia leve', '248010001'),
(3, '273295006', '100', 'Independiente', '284196006'),
(4, '273295006', '45', 'Dependencia moderada', '248010001'),
(5, '273295006', '85', 'Dependencia leve', '248010001');