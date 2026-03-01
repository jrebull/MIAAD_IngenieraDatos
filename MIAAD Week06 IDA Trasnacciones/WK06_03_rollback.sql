-- ============================================================
-- Archivo: WK06_03_rollback.sql
-- Materia: Ingeniería de Datos Avanzada
-- Profesor: Dr. Vicente García Jiménez
-- Alumno:  Javier Augusto Rebull Saucedo (263483)
-- Fecha:   27 de febrero de 2026
-- Descripción: Transacción para simular la compra de 4 Laptops
--              por el cliente "Luis". Se demuestra el uso de
--              ROLLBACK cuando el stock es insuficiente.
--              (Prerequisito: ejecutar scripts 01 y 02 primero)
-- ============================================================

-- Prerequisito: ejecutar WK06_01 y WK06_02 previamente
USE tienda_tx;

-- -----------------------------------------------
-- Estado actual antes de la transacción de Luis
-- (Después de la compra de Ana, el stock es 2)
-- -----------------------------------------------
SELECT '=== ESTADO ACTUAL (después de la compra de Ana) ===' AS info;
SELECT * FROM productos;
SELECT * FROM ordenes;

-- -----------------------------------------------
-- 1. Iniciar la transacción para Luis
-- -----------------------------------------------
START TRANSACTION;

-- -----------------------------------------------
-- 2. Verificar stock disponible y bloquear la fila
--    con FOR UPDATE para evitar condiciones de carrera.
--    Luis desea comprar 4 Laptops.
-- -----------------------------------------------
SELECT id, nombre, stock, precio
FROM productos
WHERE id = 1
FOR UPDATE;
-- Resultado esperado: Laptop con stock = 2
-- Como 2 < 4 (cantidad solicitada por Luis),
-- NO hay stock suficiente para completar la compra.

-- -----------------------------------------------
-- 3. Stock insuficiente (2 < 4):
--    Se debe aplicar ROLLBACK para revertir
--    la transacción y liberar el bloqueo FOR UPDATE.
--    La base de datos regresa al estado anterior
--    sin ningún cambio.
-- -----------------------------------------------

-- NOTA EXPLICATIVA:
-- En un escenario real con procedimiento almacenado,
-- se usaría un IF para verificar el stock y decidir
-- entre COMMIT o ROLLBACK automáticamente.
-- Aquí simulamos el flujo manual:
-- Al verificar que stock (2) < cantidad solicitada (4),
-- el operador decide NO insertar la orden y revierte.

ROLLBACK;

-- -----------------------------------------------
-- 4. Verificar que NO hubo cambios tras el ROLLBACK
-- -----------------------------------------------
SELECT '=== RESULTADO DESPUÉS DEL ROLLBACK (Luis) ===' AS info;

-- El stock de Laptop debe seguir en 2
SELECT * FROM productos;

-- Solo debe existir la orden de Ana; Luis no tiene orden
SELECT * FROM ordenes;

-- Resultado esperado en productos (sin cambios):
-- +----+--------+-------+---------+
-- | id | nombre | stock | precio  |
-- +----+--------+-------+---------+
-- |  1 | Laptop |     2 | 1200.00 |
-- +----+--------+-------+---------+

-- Resultado esperado en ordenes (sin cambios):
-- +----+---------+-------------+----------+---------+------------+
-- | id | cliente | producto_id | cantidad | total   | estado     |
-- +----+---------+-------------+----------+---------+------------+
-- |  1 | Ana     |           1 |        3 | 3600.00 | Confirmada |
-- +----+---------+-------------+----------+---------+------------+

-- ============================================================
-- CONCLUSIÓN:
-- La transacción de Luis fue revertida con ROLLBACK porque
-- el stock disponible (2 unidades) era menor a la cantidad
-- solicitada (4 unidades). Gracias al mecanismo de transacciones
-- y al bloqueo FOR UPDATE, la integridad de los datos se
-- mantuvo intacta: no se generó ninguna orden fantasma ni se
-- descontó inventario de forma incorrecta.
--
-- Este escenario demuestra la propiedad de Atomicidad (ACID):
-- la transacción se ejecuta completa o no se ejecuta en absoluto.
-- ============================================================
