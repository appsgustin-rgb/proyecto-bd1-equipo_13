USE master;
go

go
USE base_distribuidora;
go
--Transaccion que utiliza procedimientos para insertar y modificar parte de las insntancias de la tabla cliente

DECLARE @idt INT;
BEGIN TRY
	BEGIN TRANSACTION;
		EXEC dbo.sp_InsertarCliente 
			@nombre = 'Hector', 
			@apellido = 'Perez', 
			@direccion = 'Madrid 576', 
			@email = 'hectorrom@gmail.com',
			@id_cliente = @idt OUTPUT;
		INSERT INTO Telefono_Cliente(telefono, id_cliente) VALUES ('3795-991100', @idt);

		EXEC dbo.sp_ModificarCliente 
			@id_cliente = -123,                 --ERROR de prueba: intentar modificar un cliente inexistente (id no valido)
			@nombre = 'Juan', 
			@apellido = 'Perez', 
			@direccion = 'Las Heras 570', 
			@email = 'juanjope@gmail.com'

		EXEC dbo.sp_ModificarCliente
			@id_cliente = 2,
			@nombre = 'Juan', 
			@apellido = 'Perez', 
			@direccion = 'Las Heras 570', 
			@email = 'juanjope@gmail.com'
		
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH

	IF @@TRANCOUNT > 0
	BEGIN
	ROLLBACK TRANSACTION;                      --rollback por error de sgbd
	END
	PRINT 'Ocurrió un error. Se deshicieron los cambios.';
    PRINT 'Detalle del error: ' + ERROR_MESSAGE();
END CATCH;
select * from Cliente;
select * from Telefono_Cliente;