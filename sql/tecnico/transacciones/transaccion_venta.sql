USE base_distribuidora;
GO

-- ============================================================
-- ETAPA V - TRANSACCIONES
-- Transaccion 1: registro de una venta completa.
--   1. INSERT en Venta          (cabecera)
--   2. INSERT en Detalle_Venta  (renglon, con el precio vigente
--                                como precio historico - RN06)
--   3. UPDATE en Producto       (descuento de stock - RN07)
-- Los cambios se confirman solo si las tres operaciones terminan
-- bien ("todo o nada").
-- Ejecutar despues de 02_lote_insert_directo.sql (usa a la
-- clienta Valentina Ruiz).
-- ============================================================

SET XACT_ABORT ON;   -- ante cualquier error del motor la transaccion se marca para deshacerse

DECLARE @id_cliente     INT;
DECLARE @id_metodo_pago INT = 1;    -- Efectivo
DECLARE @id_producto    INT = 5;    -- Soda 1.5L
DECLARE @cantidad       INT = 13;
DECLARE @precio         DECIMAL(10,2);
DECLARE @stock          INT;
DECLARE @id_venta       INT;

SELECT @id_cliente = id_cliente
FROM Cliente
WHERE email = 'valentina.ruiz@gmail.com';

-- Estado ANTES de la transaccion
SELECT 'ANTES' AS momento, id_producto, nombre_producto, precio_actual, stock
FROM Producto
WHERE id_producto = @id_producto;

BEGIN TRY
    BEGIN TRANSACTION;

        -- Validacion previa: el producto debe existir y tener stock suficiente.
        -- UPDLOCK evita que otra sesion modifique el stock entre la lectura
        -- y el descuento.
        SELECT @stock  = stock,
               @precio = precio_actual
        FROM Producto WITH (UPDLOCK, HOLDLOCK)
        WHERE id_producto = @id_producto;

        IF @stock IS NULL
            THROW 50020, 'El producto no existe.', 1;

        IF @stock < @cantidad
            THROW 50021, 'Stock insuficiente para registrar la venta.', 1;

        -- 1. Cabecera de la venta
        INSERT INTO Venta (fecha_venta, id_cliente, id_metodo_pago)
        VALUES (CAST(GETDATE() AS DATE), @id_cliente, @id_metodo_pago);

        SET @id_venta = SCOPE_IDENTITY();

        -- 2. Renglon de la venta con el precio vigente
        INSERT INTO Detalle_Venta (nro_linea, cantidad, precio_historico, id_producto, id_venta)
        VALUES (1, @cantidad, @precio, @id_producto, @id_venta);

        -- 3. Descuento de stock
        UPDATE Producto
        SET stock = stock - @cantidad
        WHERE id_producto = @id_producto;

    COMMIT TRANSACTION;
    PRINT 'Venta ' + CAST(@id_venta AS VARCHAR(10)) + ' registrada correctamente. Cambios confirmados (COMMIT).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Ocurrio un error. Se deshicieron todos los cambios (ROLLBACK).';
    PRINT 'Detalle del error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;

-- Estado DESPUES de la transaccion
SELECT 'DESPUES' AS momento, id_producto, nombre_producto, precio_actual, stock
FROM Producto
WHERE id_producto = @id_producto;

SELECT v.id_venta, v.fecha_venta, v.id_cliente, dv.nro_linea, dv.id_producto,
       dv.cantidad, dv.precio_historico
FROM Venta v
INNER JOIN Detalle_Venta dv ON dv.id_venta = v.id_venta
WHERE v.id_venta = @id_venta;
GO
