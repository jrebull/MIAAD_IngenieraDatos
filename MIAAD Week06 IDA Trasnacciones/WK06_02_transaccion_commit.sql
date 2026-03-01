-- ============================================================
-- Archivo: WK06_02_transaccion_commit.sql
-- Materia: Ingeniería de Datos Avanzada
-- Profesor: Dr. Vicente García Jiménez
-- Alumno:  Javier Augusto Rebull Saucedo (263483)
-- Fecha:   27 de febrero de 2026
-- Descripción: Transacción para simular la compra de 3 Laptops
--              por la cliente "Ana". Se usa START TRANSACTION,
--              SELECT ... FOR UPDATE para bloqueo de fila,
--              y COMMIT para confirmar la operación.
-- ============================================================

-- Prerequisito: ejecutar primero WK06_01_creacion_bd.sql
USE tienda_tx;

-- -----------------------------------------------
-- Estado inicial antes de la transacción
-- -----------------------------------------------
SELECT '=== ESTADO INICIAL ===' AS info;
SELECT * FROM productos;
SELECT * FROM ordenes;

-- -----------------------------------------------
-- 1. Iniciar la transacción
-- -----------------------------------------------
START TRANSACTION;

-- -----------------------------------------------
-- 2. Verificar stock disponible y bloquear la fila
--    del producto con FOR UPDATE para evitar que
--    otra transacción concurrente modifique el stock
--    mientras esta transacción está en curso.
--    (Previene condiciones de carrera / sobreventa)
-- -----------------------------------------------
SELECT id, nombre, stock, precio
FROM productos
WHERE id = 1
FOR UPDATE;
-- Resultado esperado: Laptop con stock = 5
-- Como 5 >= 3 (cantidad solicitada), hay stock suficiente.

-- -----------------------------------------------
-- 3. Hay stock suficiente (5 >= 3), procedemos:
--    a) Insertar la orden para Ana
--       - cliente: Ana
--       - producto_id: 1 (Laptop)
--       - cantidad: 3
--       - total: 3 * 1200.00 = 3600.00
--       - estado: Confirmada
-- -----------------------------------------------
INSERT INTO ordenes (cliente, producto_id, cantidad, total, estado)
VALUES ('Ana', 1, 3, 3600.00, 'Confirmada');

-- -----------------------------------------------
--    b) Descontar el stock de productos
--       Stock anterior: 5  →  Stock nuevo: 5 - 3 = 2
-- -----------------------------------------------
UPDATE productos
SET stock = stock - 3
WHERE id = 1;

-- -----------------------------------------------
-- 4. Confirmar la transacción con COMMIT
--    Todos los cambios se vuelven permanentes.
-- -----------------------------------------------
COMMIT;

-- -----------------------------------------------
-- 5. Verificar resultados finales
-- -----------------------------------------------
SELECT '=== RESULTADO DESPUÉS DEL COMMIT (Ana) ===' AS info;

-- El stock de Laptop debe ser 2 (5 - 3 = 2)
SELECT * FROM productos;

-- Debe existir una orden para Ana con estado 'Confirmada'
SELECT * FROM ordenes;

-- Resultado esperado en productos:
-- +----+--------+-------+---------+
-- | id | nombre | stock | precio  |
-- +----+--------+-------+---------+
-- |  1 | Laptop |     2 | 1200.00 |
-- +----+--------+-------+---------+

-- Resultado esperado en ordenes:
-- +----+---------+-------------+----------+---------+------------+
-- | id | cliente | producto_id | cantidad | total   | estado     |
-- +----+---------+-------------+----------+---------+------------+
-- |  1 | Ana     |           1 |        3 | 3600.00 | Confirmada |
-- +----+---------+-------------+----------+---------+------------+
