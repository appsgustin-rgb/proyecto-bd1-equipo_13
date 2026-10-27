USE base_distribuidora;
go

-- ============================================================
-- Lote 2: carga de clientes invocando sp_InsertarCliente
-- ============================================================

EXEC dbo.sp_InsertarCliente @nombre = 'Bruno',    @apellido = 'Silva',   @direccion = 'Lavalle 870',     @email = 'bruno.silva@gmail.com';
EXEC dbo.sp_InsertarCliente @nombre = 'Martina',  @apellido = 'Herrera', @direccion = 'Pellegrini 1340', @email = 'martina.herrera@gmail.com';
EXEC dbo.sp_InsertarCliente @nombre = 'Lucas',    @apellido = 'Rios',    @direccion = 'Mitre 515',       @email = 'lucas.rios@gmail.com';
EXEC dbo.sp_InsertarCliente @nombre = 'Julieta',  @apellido = 'Navarro', @direccion = 'Yrigoyen 1190',   @email = 'julieta.navarro@gmail.com';
-- Sin email (es opcional)
EXEC dbo.sp_InsertarCliente @nombre = 'Santiago', @apellido = 'Molina',  @direccion = 'Necochea 760';

-- Ejemplo usando el parametro OUTPUT
DECLARE @id_nuevo INT;
EXEC dbo.sp_InsertarCliente @nombre = 'Paula', @apellido = 'Sosa', @direccion = 'Belgrano 2210',
     @email = 'paula.sosa@gmail.com', @id_cliente = @id_nuevo OUTPUT;
SELECT @id_nuevo AS id_cliente_generado;

-- Verificacion: los dos lotes
SELECT * FROM Cliente WHERE id_cliente > 8;
go

-- ============================================================
-- UPDATE invocando sp_ModificarCliente
-- ============================================================
DECLARE @id INT;

-- Cambiar la direccion de Joaquin Ortiz (cargado con INSERT directo)
SELECT @id = id_cliente FROM Cliente WHERE email = 'joaquin.ortiz@gmail.com';
EXEC dbo.sp_ModificarCliente @id_cliente = @id, @direccion = 'Bolivar 2050';

-- Cambiar el email de Martina Herrera (cargada con el procedimiento)
SELECT @id = id_cliente FROM Cliente WHERE email = 'martina.herrera@gmail.com';
EXEC dbo.sp_ModificarCliente @id_cliente = @id, @email = 'martina.h@hotmail.com';

-- Verificacion
SELECT * FROM Cliente
WHERE email IN ('joaquin.ortiz@gmail.com', 'martina.h@hotmail.com');
go

-- ============================================================
-- DELETE invocando sp_EliminarCliente
-- ============================================================
DECLARE @id INT;

-- Tomas Medina tiene un telefono: se borran el telefono y el cliente
SELECT @id = id_cliente FROM Cliente WHERE email = 'tomas.medina@gmail.com';
EXEC dbo.sp_EliminarCliente @id_cliente = @id;

SELECT @id = id_cliente FROM Cliente WHERE email = 'lucas.rios@gmail.com';
EXEC dbo.sp_EliminarCliente @id_cliente = @id;

-- Verificacion: ya no existen
SELECT * FROM Cliente
WHERE email IN ('tomas.medina@gmail.com', 'lucas.rios@gmail.com');   -- 0 filas
SELECT * FROM Telefono_Cliente WHERE telefono = '3794300400';           -- 0 filas
go

-- ============================================================
-- Casos de error (cada uno en su propio lote, porque el error
-- corta la ejecucion del lote)
-- ============================================================

-- Error 50013: Juan Perez (id 1) tiene ventas, no se puede borrar
EXEC dbo.sp_EliminarCliente @id_cliente = 1;
go

-- Error 50011: cliente inexistente
EXEC dbo.sp_ModificarCliente @id_cliente = 999, @nombre = 'Nadie';
go

-- Error 50010: falta el nombre
EXEC dbo.sp_InsertarCliente @nombre = '', @apellido = 'Gomez', @direccion = 'Junin 100';
go

-- Estado final de la tabla
SELECT * FROM Cliente ORDER BY id_cliente;
