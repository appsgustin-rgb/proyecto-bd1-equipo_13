USE master;
go

go
USE base_consorcio_2025;
GO
--PARTE 1: creacion tabla de pruebas
CREATE TABLE Venta_Historica
(
	id_venta BIGINT IDENTITY(1,1),
	fecha_venta DATE NOT NULL,
	importe DECIMAL(12, 2) NOT NULL
);
GO


--PARTE 2: Carga masiva de registros con informacion simulada a la tabla de prueba 
SET NOCOUNT ON; --evitar que el sgbd devuelva mensaje de filas afectadas
 GO

 WITH Numeros AS
 (
	SELECT TOP (1000000)
		ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n
	FROM sys.objects a
	CROSS JOIN sys.objects b
	CROSS JOIN sys.objects c
 )
 INSERT INTO Venta_Historica(fecha_venta, importe)
 SELECT
	DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 1825, '2020-01-01'),
	RAND(CHECKSUM(NEWID())) * 10000
FROM Numeros;
GO

--Verificar cantidad de registros de la tabla de pruebas
SELECT COUNT(*) AS CantidadRegistros 
FROM Venta_Historica;
GO

--PARTE 3: Consultas sin indices
--activar estadisticas de rendimiento para informar metricas del mismo via mensajes
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

SELECT
	id_venta,
	fecha_venta,
	importe
	FROM Venta_Historica
	WHERE fecha_venta BETWEEN '2023-01-01' AND '2023-03-31';

--Parte 4: Creacion de indice agrupado sobe la fecha
CREATE CLUSTERED INDEX IX_VentaHistorica_Fecha
ON Venta_Historica(fecha_venta);
GO
--repetimos la consulta SELECT previa post ejecucion de la creacion de indice

--Parte 5: Eliminar el indice definido anteriormente
DROP INDEX IX_VentaHistorica_Fecha
ON Venta_Historica;
GO
--Parte 6: Crear un indice que cubra la consulta
CREATE NONCLUSTERED INDEX IX_VentaHistorica_Fecha_Cobertura
ON Venta_Historica(fecha_venta)
INCLUDE (importe);
GO
--repetimos la consulta que venimos usando
