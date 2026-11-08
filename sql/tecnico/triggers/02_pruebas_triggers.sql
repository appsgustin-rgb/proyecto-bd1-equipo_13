USE base_distribuidora;
GO

-- ============================================================
-- ETAPA V - PRUEBAS DE LOS TRIGGERS DE AUDITORIA
-- ============================================================
-- Ejecutar despues de 01_triggers_auditoria.sql.
-- Estas pruebas modifican datos de Producto y Entrega.
-- Al final se vuelven los datos a los valores de INSERT.sql.
-- ============================================================


-- PRUEBA 1: cambio de precio de un producto.
-- Esperado: fila UPDATE con precio_anterior 800 y precio_nuevo 900.

SELECT id_producto, nombre_producto, precio_actual, stock
FROM dbo.Producto
WHERE id_producto = 1;

UPDATE dbo.Producto
SET precio_actual = 900
WHERE id_producto = 1;

SELECT TOP (1) *
FROM dbo.Auditoria_Producto
ORDER BY id_auditoria DESC;
GO


-- PRUEBA 2: descuento de stock (simula una venta).
-- Esperado: fila UPDATE con stock_anterior 100 y stock_nuevo 97.

UPDATE dbo.Producto
SET stock = stock - 3
WHERE id_producto = 1;

SELECT TOP (1) *
FROM dbo.Auditoria_Producto
ORDER BY id_auditoria DESC;
GO


-- PRUEBA 3: aumento del 10 % a toda la categoria 1 (3 productos).
-- Esperado: una fila por cada producto modificado.

UPDATE dbo.Producto
SET precio_actual = precio_actual * 1.10
WHERE id_categoria = 1;

SELECT TOP (3) *
FROM dbo.Auditoria_Producto
ORDER BY id_auditoria DESC;
GO


-- PRUEBA 3B: UPDATE que no cambia ningun valor.
-- Esperado: no se agrega ningun registro (la ultima fila sigue siendo la de la prueba 3).

UPDATE dbo.Producto
SET precio_actual = precio_actual
WHERE id_producto = 2;

SELECT TOP (1) *
FROM dbo.Auditoria_Producto
ORDER BY id_auditoria DESC;
GO


-- PRUEBA 4: alta y baja de un producto de prueba.
-- Esperado: una fila INSERT y una fila DELETE.

INSERT INTO dbo.Producto (nombre_producto, precio_actual, stock, id_categoria)
VALUES ('Producto de prueba', 1000.00, 10, 1);

DELETE FROM dbo.Producto
WHERE nombre_producto = 'Producto de prueba';

SELECT TOP (2) *
FROM dbo.Auditoria_Producto
ORDER BY id_auditoria DESC;
GO


-- PRUEBA 5: cambio de precio dentro de una transaccion deshecha.
-- Esperado: el registro existe dentro de la transaccion y desaparece con el ROLLBACK.

BEGIN TRANSACTION;

    UPDATE dbo.Producto
    SET precio_actual = 99999
    WHERE id_producto = 2;

    SELECT *
    FROM dbo.Auditoria_Producto
    WHERE precio_nuevo = 99999;

ROLLBACK TRANSACTION;

SELECT *
FROM dbo.Auditoria_Producto
WHERE precio_nuevo = 99999;
GO


-- PRUEBA 6: cambios de estado de la entrega 9 (Pendiente -> En camino -> Entregada).
-- Esperado: dos filas en Auditoria_Entrega.

UPDATE dbo.Entrega
SET estado_entrega = 'En camino'
WHERE id_entrega = 9;

UPDATE dbo.Entrega
SET estado_entrega = 'Entregada'
WHERE id_entrega = 9;

SELECT *
FROM dbo.Auditoria_Entrega
WHERE id_entrega = 9
ORDER BY id_auditoria;
GO


-- ============================================================
-- VUELTA A LOS DATOS A SUS VALORES ORIGINALES
-- ============================================================

UPDATE dbo.Producto SET precio_actual = 800.00 WHERE id_producto = 1;
UPDATE dbo.Producto SET precio_actual = 1200.00 WHERE id_producto = 2;
UPDATE dbo.Producto SET precio_actual = 1500.00 WHERE id_producto = 3;

UPDATE dbo.Producto
SET stock = stock + 3
WHERE id_producto = 1;

UPDATE dbo.Entrega
SET estado_entrega = 'Pendiente'
WHERE id_entrega = 9;
GO


-- ============================================================
-- CONSULTAS DE AUDITORIA
-- ============================================================


-- CONSULTA 1: historial de cambios de precio.

SELECT
    a.fecha,
    a.usuario,
    a.id_producto,
    a.nombre_producto,
    a.precio_anterior,
    a.precio_nuevo
FROM dbo.Auditoria_Producto AS a
WHERE a.operacion = 'UPDATE'
  AND a.precio_anterior <> a.precio_nuevo
ORDER BY a.fecha DESC;
GO


-- CONSULTA 2: productos eliminados con su ultimo precio y stock.

SELECT
    a.fecha,
    a.usuario,
    a.id_producto,
    a.nombre_producto,
    a.precio_anterior AS ultimo_precio,
    a.stock_anterior AS ultimo_stock
FROM dbo.Auditoria_Producto AS a
WHERE a.operacion = 'DELETE'
ORDER BY a.fecha DESC;
GO


-- CONSULTA 3: historial de estados de la entrega 9.

SELECT
    a.fecha,
    a.usuario,
    a.id_entrega,
    a.id_venta,
    a.estado_anterior,
    a.estado_nuevo
FROM dbo.Auditoria_Entrega AS a
WHERE a.id_entrega = 9
ORDER BY a.id_auditoria;
GO
