USE base_distribuidora;
GO

-- ============================================================
-- ETAPA V - PRUEBAS DE LOS TRIGGERS DE AUDITORIA
-- ============================================================
-- Ejecutar despues de 01_triggers_auditoria.sql.
-- Estas pruebas modifican datos de Producto y Entrega.
-- Al final se vuelven los datos a los valores de INSERT.sql.
-- ============================================================


-- PRUEBA 1

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


-- PRUEBA 2

UPDATE dbo.Producto
SET stock = stock - 3
WHERE id_producto = 1;

SELECT TOP (1) *
FROM dbo.Auditoria_Producto
ORDER BY id_auditoria DESC;
GO


-- PRUEBA 3 

UPDATE dbo.Producto
SET precio_actual = precio_actual * 1.10
WHERE id_categoria = 1;

SELECT TOP (3) *
FROM dbo.Auditoria_Producto
ORDER BY id_auditoria DESC;
GO


-- PRUEBA 3B

UPDATE dbo.Producto
SET precio_actual = precio_actual
WHERE id_producto = 2;

SELECT TOP (1) *
FROM dbo.Auditoria_Producto
ORDER BY id_auditoria DESC;
GO


-- PRUEBA 4

INSERT INTO dbo.Producto (nombre_producto, precio_actual, stock, id_categoria)
VALUES ('Producto de prueba', 1000.00, 10, 1);

DELETE FROM dbo.Producto
WHERE nombre_producto = 'Producto de prueba';

SELECT TOP (2) *
FROM dbo.Auditoria_Producto
ORDER BY id_auditoria DESC;
GO


-- PRUEBA 5

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


-- PRUEBA 6

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


-- CONSULTA 1 

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


-- CONSULTA 2 

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


-- CONSULTA 3

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
