USE base_distribuidora;
GO

-- ============================================================
-- ETAPA V - TRANSACCIONES
-- Transaccion 1 con errores provocados.
-- Se ejecuta la misma secuencia que en transaccion_venta.sql
-- (INSERT Venta -> INSERT Detalle_Venta -> UPDATE Producto),
-- pero se provoca un error para comprobar que no queda ningun
-- cambio guardado (ROLLBACK).
-- ============================================================

SET XACT_ABORT ON;

-- ------------------------------------------------------------
-- CASO A: error del motor DESPUES del primer INSERT y ANTES del
-- UPDATE. El renglon se carga con cantidad = 0, lo que viola la
-- restriccion CK_Detalle_cantidad. La venta ya insertada debe
-- deshacerse y el stock no debe cambiar.
-- ------------------------------------------------------------
DECLARE @id_cliente   INT;
DECLARE @id_producto  INT = 5;
DECLARE @precio       DECIMAL(10,2);
DECLARE @id_venta     INT;
DECLARE @ventas_antes INT = (SELECT COUNT(*) FROM Venta);
DECLARE @stock_antes  INT = (SELECT stock FROM Producto WHERE id_producto = 5);

SELECT @id_cliente = id_cliente FROM Cliente WHERE email = 'valentina.ruiz@gmail.com';
SELECT @precio = precio_actual FROM Producto WHERE id_producto = @id_producto;

BEGIN TRY
    BEGIN TRANSACTION;

        INSERT INTO Venta (fecha_venta, id_cliente, id_metodo_pago)
        VALUES (CAST(GETDATE() AS DATE), @id_cliente, 1);

        SET @id_venta = SCOPE_IDENTITY();
        PRINT 'Venta ' + CAST(@id_venta AS VARCHAR(10)) + ' insertada dentro de la transaccion (todavia sin confirmar).';

        -- ERROR PROVOCADO: cantidad = 0 viola CK_Detalle_cantidad
        INSERT INTO Detalle_Venta (nro_linea, cantidad, precio_historico, id_producto, id_venta)
        VALUES (1, 0, @precio, @id_producto, @id_venta);

        -- Esta sentencia nunca llega a ejecutarse
        UPDATE Producto SET stock = stock - 1 WHERE id_producto = @id_producto;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'CASO A - Ocurrio un error. Se deshicieron todos los cambios (ROLLBACK).';
    PRINT 'Detalle del error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;

-- Verificacion: la cantidad de ventas y el stock no cambiaron
SELECT 'CASO A' AS prueba,
       @ventas_antes AS ventas_antes,
       (SELECT COUNT(*) FROM Venta) AS ventas_despues,
       (SELECT COUNT(*) FROM Venta WHERE id_venta = @id_venta) AS existe_venta_revertida,
       @stock_antes AS stock_antes,
       (SELECT stock FROM Producto WHERE id_producto = 5) AS stock_despues;
GO

-- ------------------------------------------------------------
-- CASO B: regla de negocio RN07. Se intenta vender 150 unidades
-- de un producto con menos stock. La validacion lanza el error
-- 50021 y la transaccion se deshace.
-- ------------------------------------------------------------
DECLARE @id_cliente   INT;
DECLARE @id_producto  INT = 5;
DECLARE @cantidad     INT = 150;
DECLARE @precio       DECIMAL(10,2);
DECLARE @stock        INT;
DECLARE @id_venta     INT;
DECLARE @ventas_antes INT = (SELECT COUNT(*) FROM Venta);
DECLARE @stock_antes  INT = (SELECT stock FROM Producto WHERE id_producto = 5);

SELECT @id_cliente = id_cliente FROM Cliente WHERE email = 'valentina.ruiz@gmail.com';

BEGIN TRY
    BEGIN TRANSACTION;

        SELECT @stock = stock, @precio = precio_actual
        FROM Producto WITH (UPDLOCK, HOLDLOCK)
        WHERE id_producto = @id_producto;

        IF @stock < @cantidad
            THROW 50021, 'Stock insuficiente para registrar la venta.', 1;

        INSERT INTO Venta (fecha_venta, id_cliente, id_metodo_pago)
        VALUES (CAST(GETDATE() AS DATE), @id_cliente, 1);
        SET @id_venta = SCOPE_IDENTITY();

        INSERT INTO Detalle_Venta (nro_linea, cantidad, precio_historico, id_producto, id_venta)
        VALUES (1, @cantidad, @precio, @id_producto, @id_venta);

        UPDATE Producto SET stock = stock - @cantidad WHERE id_producto = @id_producto;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'CASO B - Ocurrio un error. Se deshicieron todos los cambios (ROLLBACK).';
    PRINT 'Detalle del error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;

SELECT 'CASO B' AS prueba,
       @ventas_antes AS ventas_antes,
       (SELECT COUNT(*) FROM Venta) AS ventas_despues,
       @stock_antes AS stock_antes,
       (SELECT stock FROM Producto WHERE id_producto = 5) AS stock_despues;
GO
