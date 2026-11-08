USE base_distribuidora;
GO

-- ============================================================
-- ETAPA V - TRANSACCIONES
-- Transaccion 2 con error provocado.
-- Misma secuencia que transaccion_cliente.sql, pero la
-- modificacion se hace sobre un cliente inexistente: el
-- procedimiento lanza el error 50011 DESPUES de los dos INSERT.
-- Resultado esperado: ni el cliente nuevo ni su telefono quedan
-- guardados.
-- ============================================================

SET XACT_ABORT ON;

DECLARE @id_nuevo        INT;
DECLARE @clientes_antes  INT = (SELECT COUNT(*) FROM Cliente);
DECLARE @telefonos_antes INT = (SELECT COUNT(*) FROM Telefono_Cliente);

BEGIN TRY
    BEGIN TRANSACTION;

        EXEC dbo.sp_InsertarCliente
            @nombre     = 'Rocio',
            @apellido   = 'Acosta',
            @direccion  = 'Carlos Pellegrini 980',
            @email      = 'rocio.acosta@gmail.com',
            @id_cliente = @id_nuevo OUTPUT;

        INSERT INTO Telefono_Cliente (telefono, id_cliente)
        VALUES ('3795887766', @id_nuevo);

        PRINT 'Cliente ' + CAST(@id_nuevo AS VARCHAR(10)) + ' y telefono insertados (todavia sin confirmar).';

        -- ERROR PROVOCADO: el cliente -123 no existe (error 50011)
        EXEC dbo.sp_ModificarCliente
            @id_cliente = -123,
            @direccion  = 'Las Heras 570';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Ocurrio un error. Se deshicieron todos los cambios (ROLLBACK).';
    PRINT 'Detalle del error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;

-- Verificacion: no quedo el cliente ni el telefono
SELECT @clientes_antes  AS clientes_antes,
       (SELECT COUNT(*) FROM Cliente) AS clientes_despues,
       @telefonos_antes AS telefonos_antes,
       (SELECT COUNT(*) FROM Telefono_Cliente) AS telefonos_despues,
       (SELECT COUNT(*) FROM Cliente WHERE email = 'rocio.acosta@gmail.com') AS existe_rocio;
GO
