USE base_distribuidora;
GO

-- ============================================================
-- ETAPA V - OPTIMIZACION DE CONSULTAS A TRAVES DE INDICES
-- Tabla de pruebas Venta_Historica con 1.000.000 de registros.
-- Se mide la misma consulta por rango de fechas en 3 escenarios:
--   1. Sin indices (heap)
--   2. Indice agrupado sobre fecha_venta
--   3. Indice no agrupado con cobertura (fecha_venta INCLUDE importe)
-- Ver resultados en docs/etapa-05/indices.md
-- ============================================================

-- PARTE 0: preparacion. Se puede volver a ejecutar sin errores.
IF OBJECT_ID('dbo.Venta_Historica', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Venta_Historica
    (
        id_venta    BIGINT IDENTITY(1,1),
        fecha_venta DATE NOT NULL,
        importe     DECIMAL(12,2) NOT NULL
    );
END;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_VentaHistorica_Fecha'
           AND object_id = OBJECT_ID('dbo.Venta_Historica'))
    DROP INDEX IX_VentaHistorica_Fecha ON dbo.Venta_Historica;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_VentaHistorica_Fecha_Cobertura'
           AND object_id = OBJECT_ID('dbo.Venta_Historica'))
    DROP INDEX IX_VentaHistorica_Fecha_Cobertura ON dbo.Venta_Historica;
GO

-- PARTE 1: carga masiva de registros simulados (solo si la tabla esta vacia).
-- Fechas aleatorias en 5 anios desde 2020-01-01 e importes entre 0 y 10000.
SET NOCOUNT ON;   -- evita los mensajes de filas afectadas
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Venta_Historica)
BEGIN
    WITH Numeros AS
    (
        SELECT TOP (1000000)
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
        FROM sys.objects a
        CROSS JOIN sys.objects b
        CROSS JOIN sys.objects c
    )
    INSERT INTO dbo.Venta_Historica (fecha_venta, importe)
    SELECT
        DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 1825, '2020-01-01'),
        RAND(CHECKSUM(NEWID())) * 10000
    FROM Numeros;
END;
GO

-- Verificar la cantidad de registros
SELECT COUNT(*) AS cantidad_registros FROM dbo.Venta_Historica;
GO

-- Activar las estadisticas de rendimiento (se ven en la pestania Mensajes)
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

-- ============================================================
-- PARTE 2: ESCENARIO 1 - SIN INDICES (Table Scan)
-- ============================================================
CHECKPOINT;
DBCC DROPCLEANBUFFERS;   -- cache fria (requiere permisos de sysadmin)
GO

SELECT id_venta, fecha_venta, importe
FROM dbo.Venta_Historica
WHERE fecha_venta BETWEEN '2023-01-01' AND '2023-03-31';
GO

-- ============================================================
-- PARTE 3: ESCENARIO 2 - INDICE AGRUPADO SOBRE LA FECHA
-- ============================================================
CREATE CLUSTERED INDEX IX_VentaHistorica_Fecha
ON dbo.Venta_Historica (fecha_venta);
GO

CHECKPOINT;
DBCC DROPCLEANBUFFERS;
GO

SELECT fecha_venta, importe
FROM dbo.Venta_Historica
WHERE fecha_venta BETWEEN '2023-01-01' AND '2023-03-31';
GO

-- ============================================================
-- PARTE 4: ESCENARIO 3 - INDICE NO AGRUPADO CON COBERTURA
-- Se elimina el indice agrupado y se crea uno que incluye
-- todas las columnas que pide la consulta.
-- ============================================================
DROP INDEX IX_VentaHistorica_Fecha ON dbo.Venta_Historica;
GO

CREATE NONCLUSTERED INDEX IX_VentaHistorica_Fecha_Cobertura
ON dbo.Venta_Historica (fecha_venta)
INCLUDE (importe);
GO

CHECKPOINT;
DBCC DROPCLEANBUFFERS;
GO

SELECT fecha_venta, importe
FROM dbo.Venta_Historica
WHERE fecha_venta BETWEEN '2023-01-01' AND '2023-03-31';
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO
