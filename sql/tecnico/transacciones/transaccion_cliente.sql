USE base_distribuidora;
GO

-- ============================================================
-- ETAPA V - TRANSACCIONES
-- Transaccion 2: alta de un cliente con su telefono y
-- modificacion de otro cliente, invocando los procedimientos
-- almacenados dentro de una misma transaccion.
--   1. EXEC sp_InsertarCliente   (INSERT en Cliente)
--   2. INSERT en Telefono_Cliente
--   3. EXEC sp_ModificarCliente  (UPDATE en Cliente)
-- Ejecutar despues de 01_procedimientos_crud.sql y de
-- 02_lote_insert_directo.sql (modifica a Florencia Vega).
-- ============================================================

SET XACT_ABORT ON;

DECLARE @id_nuevo     INT;
DECLARE @id_modificar INT;

SELECT @id_modificar = id_cliente
FROM Cliente
WHERE email = 'florencia.vega@gmail.com';

BEGIN TRY
    BEGIN TRANSACTION;

        -- 1. Alta del cliente; el procedimiento devuelve el id generado
        EXEC dbo.sp_InsertarCliente
            @nombre     = 'Hector',
            @apellido   = 'Romero',
            @direccion  = 'Madrid 576',
            @email      = 'hector.romero@gmail.com',
            @id_cliente = @id_nuevo OUTPUT;

        -- 2. Telefono del cliente nuevo
        INSERT INTO Telefono_Cliente (telefono, id_cliente)
        VALUES ('3795991100', @id_nuevo);

        -- 3. Cambio de domicilio de otro cliente
        EXEC dbo.sp_ModificarCliente
            @id_cliente = @id_modificar,
            @direccion  = 'Mendoza 1200';

    COMMIT TRANSACTION;
    PRINT 'Transaccion confirmada (COMMIT). Cliente nuevo: ' + CAST(@id_nuevo AS VARCHAR(10));
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Ocurrio un error. Se deshicieron todos los cambios (ROLLBACK).';
    PRINT 'Detalle del error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;

-- Verificacion
SELECT c.id_cliente, c.nombre, c.apellido, c.direccion, c.email, t.telefono
FROM Cliente c
LEFT JOIN Telefono_Cliente t ON t.id_cliente = c.id_cliente
WHERE c.email IN ('hector.romero@gmail.com', 'florencia.vega@gmail.com');
GO
