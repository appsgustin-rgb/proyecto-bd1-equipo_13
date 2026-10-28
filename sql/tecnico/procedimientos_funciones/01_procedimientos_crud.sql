USE base_distribuidora;
go

-- ============================================================
-- Etapa V - Procedimientos almacenados: CRUD sobre Cliente
-- ============================================================

-- ------------------------------------------------------------
-- 1. dbo.sp_InsertarCliente
-- Inserta un cliente validando los datos obligatorios.
-- Devuelve el id generado en el parametro OUTPUT @id_cliente.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_InsertarCliente
    @nombre     VARCHAR(35),
    @apellido   VARCHAR(35),
    @direccion  VARCHAR(50),
    @email      VARCHAR(50) = NULL,
    @id_cliente INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(LTRIM(RTRIM(@nombre)), '') = ''
       OR ISNULL(LTRIM(RTRIM(@apellido)), '') = ''
       OR ISNULL(LTRIM(RTRIM(@direccion)), '') = ''
        THROW 50010, 'Nombre, apellido y direccion son obligatorios.', 1;

    INSERT INTO Cliente (nombre, apellido, direccion, email)
    VALUES (@nombre, @apellido, @direccion, @email);

    SET @id_cliente = SCOPE_IDENTITY();
END;
go

-- ------------------------------------------------------------
-- 2. dbo.sp_ModificarCliente
-- Modifica los datos de un cliente existente.
-- Los parametros que se dejan en NULL conservan su valor actual.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_ModificarCliente
    @id_cliente INT,
    @nombre     VARCHAR(35) = NULL,
    @apellido   VARCHAR(35) = NULL,
    @direccion  VARCHAR(50) = NULL,
    @email      VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id_cliente = @id_cliente)
        THROW 50011, 'El cliente a modificar no existe.', 1;

    UPDATE Cliente
    SET nombre    = ISNULL(@nombre, nombre),
        apellido  = ISNULL(@apellido, apellido),
        direccion = ISNULL(@direccion, direccion),
        email     = ISNULL(@email, email)
    WHERE id_cliente = @id_cliente;
END;
go

-- ------------------------------------------------------------
-- 3. dbo.sp_EliminarCliente
-- Elimina un cliente y sus telefonos.
-- Regla de negocio: no se puede eliminar un cliente con ventas,
-- para no perder el historial de ventas.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_EliminarCliente
    @id_cliente INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id_cliente = @id_cliente)
        THROW 50012, 'El cliente a eliminar no existe.', 1;

    IF EXISTS (SELECT 1 FROM Venta WHERE id_cliente = @id_cliente)
        THROW 50013, 'No se puede eliminar: el cliente tiene ventas registradas.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM Telefono_Cliente WHERE id_cliente = @id_cliente;
        DELETE FROM Cliente          WHERE id_cliente = @id_cliente;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
