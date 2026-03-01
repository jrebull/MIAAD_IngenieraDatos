-- ============================================================
-- Archivo: WK06_01_creacion_bd.sql
-- Materia: Ingeniería de Datos Avanzada
-- Profesor: Dr. Vicente García Jiménez
-- Alumno:  Javier Augusto Rebull Saucedo (263483)
-- Fecha:   27 de febrero de 2026
-- Descripción: Creación de la base de datos tienda_tx,
--              definición de tablas productos y ordenes,
--              e inserción del producto inicial (Laptop).
-- ============================================================

-- -----------------------------------------------
-- 1. Crear la base de datos tienda_tx
-- -----------------------------------------------
DROP DATABASE IF EXISTS tienda_tx;
CREATE DATABASE tienda_tx
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_general_ci;

USE tienda_tx;

-- -----------------------------------------------
-- 2. Crear la tabla productos
--    Motor InnoDB para soporte de transacciones,
--    bloqueos a nivel de fila y claves foráneas.
-- -----------------------------------------------
CREATE TABLE productos (
    id      INT            PRIMARY KEY AUTO_INCREMENT,
    nombre  VARCHAR(50)    NOT NULL,
    stock   INT            NOT NULL,
    precio  DECIMAL(10,2)  NOT NULL
) ENGINE = InnoDB;

-- -----------------------------------------------
-- 3. Crear la tabla ordenes
--    Clave foránea hacia productos(id) para
--    garantizar la integridad referencial.
--    Motor InnoDB para soporte transaccional.
-- -----------------------------------------------
CREATE TABLE ordenes (
    id          INT            PRIMARY KEY AUTO_INCREMENT,
    cliente     VARCHAR(50)    NOT NULL,
    producto_id INT            NOT NULL,
    cantidad    INT            NOT NULL,
    total       DECIMAL(10,2)  NOT NULL,
    estado      VARCHAR(20)    NOT NULL,
    FOREIGN KEY (producto_id) REFERENCES productos(id)
) ENGINE = InnoDB;

-- -----------------------------------------------
-- 4. Insertar el producto inicial: Laptop
--    Stock: 5 unidades | Precio: $1,200.00
-- -----------------------------------------------
INSERT INTO productos (nombre, stock, precio)
VALUES ('Laptop', 5, 1200.00);

-- -----------------------------------------------
-- 5. Verificar la inserción del producto
-- -----------------------------------------------
SELECT * FROM productos;
-- Resultado esperado:
-- +----+--------+-------+---------+
-- | id | nombre | stock | precio  |
-- +----+--------+-------+---------+
-- |  1 | Laptop |     5 | 1200.00 |
-- +----+--------+-------+---------+
