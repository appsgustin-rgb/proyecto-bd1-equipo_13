USE master;
go

go
USE base_distribuidora;
go

DECLARE @idv INT;
DECLARE @stock_actual INT;
DECLARE @cantidad INT;

SET XACT_ABORT ON; --para abotar transaccion en caso de errores de sintaxis
BEGIN TRANSACTION;

	--Registrar venta
	INSERT INTO Venta(fecha_venta, id_cliente, id_metodo_pago) VALUES (GETDATE(), 9, 1);
	SET @idv = SCOPE_IDENTITY();
	--Registrar detalle
	INSERT INTO Detalle_Venta(nro_linea, cantidad, precio_historico, id_producto, id_venta) VALUES (11, 150, 150, 5, @idv); --error: el segundo parametros, correspondiente a la cantidad adjunta a una venta es mayor a 77, cantidad de stock actual del producto cuyo i es 5

	SET @stock_actual = (SELECT stock FROM producto WHERE id_producto = 5);
	SET @cantidad = 150;
	--Descontar stock
	UPDATE Producto
	SET stock = @stock_actual - @cantidad  -- descuenta stock del producto cuyo id sea 5
	WHERE id_producto = 5;

IF @stock_actual < @cantidad
BEGIN 
	ROLLBACK TRANSACTION;
	PRINT('ERROR: stock insuficiente, rollback ejecutado, cambios deshechos');
END
ELSE
BEGIN
COMMIT TRANSACTION;
END

select * from Producto;
select * from Venta;
select * from Detalle_Venta;