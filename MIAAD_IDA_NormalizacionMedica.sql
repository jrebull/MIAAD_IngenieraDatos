-- ============================================================
-- PASO 0: Crear Base de Datos y Área de Staging (0NF)
-- ============================================================
DROP DATABASE IF EXISTS ida_medicina;
CREATE DATABASE ida_medicina CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ida_medicina;


CREATE TABLE consultas_raw (
    id_paciente VARCHAR(10),
    nombre VARCHAR(100),
    telefono VARCHAR(100),
    diagnostico VARCHAR(200),
    medico VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

USE ida_medicina;

INSERT INTO consultas_raw (id_paciente, nombre, telefono, diagnostico, medico) VALUES
('P001', 'Ana Torres',      '111-111|222-222', 'Diabetes|Hipertensión',    'Dr. López'),
('P002', 'Juan Pérez',      '333-333',          'Asma',                     'Dra. Ruiz'),
('P003', 'María Gómez',     '444-444|555-555', 'Hipertensión|Obesidad',    'Dr. López'),
('P004', 'Luis Fernández',  '666-666',          'Diabetes',                 'Dr. Torres'),
('P005', 'Laura Martínez',  '777-777',          'Hipertensión|Asma',        'Dra. Ruiz'),
('P006', 'Pedro Ramírez',   '888-888|999-999', 'Obesidad',                 'Dr. López');


-- ============================================================
-- PASO 1: Tablas catálogo (3FN)
-- ============================================================

CREATE TABLE Medicos (
    id_medico INT PRIMARY KEY AUTO_INCREMENT,
    nombre_medico VARCHAR(100) UNIQUE
);

CREATE TABLE Diagnosticos (
    id_diagnostico INT PRIMARY KEY AUTO_INCREMENT,
    nombre_diagnostico VARCHAR(100) UNIQUE
);


-- ============================================================
-- Tabla de Pacientes (2FN)
-- ============================================================

CREATE TABLE Pacientes (
    id_paciente VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_medico INT NOT NULL,
    FOREIGN KEY (id_medico) REFERENCES Medicos(id_medico)
);


-- ============================================================
-- Tablas de relación (1FN — atomicidad)
-- ============================================================

CREATE TABLE Telefonos (
    id_telefono INT PRIMARY KEY AUTO_INCREMENT,
    id_paciente VARCHAR(10) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente)
);


CREATE TABLE Paciente_Diagnostico (
    id_paciente VARCHAR(10) NOT NULL,
    id_diagnostico INT NOT NULL,
    PRIMARY KEY (id_paciente, id_diagnostico),
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente),
    FOREIGN KEY (id_diagnostico) REFERENCES Diagnosticos(id_diagnostico)
);

-- ============================================================
-- PASO 2: Alimentar las Tablas Normalizadas
-- Orden de inserción: respeta dependencias de llaves foráneas
-- ============================================================

-- ============================================================
-- 1) Médicos       (catálogo, sin dependencias)
-- ============================================================
INSERT INTO Medicos (nombre_medico)
SELECT DISTINCT medico
FROM consultas_raw
WHERE medico IS NOT NULL AND medico <> '';
-- ============================================================
-- 2) Diagnósticos  (catálogo, sin dependencias)
-- ============================================================
INSERT INTO Diagnosticos (nombre_diagnostico)
VALUES ('Diabetes'), ('Hipertensión'), ('Asma'), ('Obesidad');
-- ============================================================
-- 3) Pacientes     (depende de Médicos)
-- ============================================================
INSERT INTO Pacientes (id_paciente, nombre, id_medico)
SELECT DISTINCT
    r.id_paciente,
    r.nombre,
    m.id_medico
FROM consultas_raw r
JOIN Medicos m ON m.nombre_medico = r.medico;
-- ============================================================
-- 4) Teléfonos     (depende de Pacientes, atomicidad 1FN)
-- ============================================================
INSERT INTO Telefonos (id_paciente, telefono)
SELECT id_paciente, SUBSTRING_INDEX(telefono, '|', 1)
FROM consultas_raw
UNION ALL
SELECT id_paciente, SUBSTRING_INDEX(telefono, '|', -1)
FROM consultas_raw
WHERE telefono LIKE '%|%';
-- ============================================================
-- 5) Paciente_Diagnostico (depende de Pacientes y Diagnósticos, atomicidad 1FN)
-- ============================================================
INSERT INTO Paciente_Diagnostico (id_paciente, id_diagnostico)
SELECT DISTINCT r.id_paciente, d.id_diagnostico
FROM consultas_raw r
JOIN Diagnosticos d ON r.diagnostico LIKE CONCAT('%', d.nombre_diagnostico, '%');

-- ====================
-- Validacion
-- ====================
SELECT * FROM Medicos;
SELECT * FROM Diagnosticos;
SELECT * FROM Pacientes;
SELECT * FROM Telefonos;
SELECT * FROM Paciente_Diagnostico;
