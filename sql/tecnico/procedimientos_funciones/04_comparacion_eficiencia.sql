USE base_distribuidora;
GO

SET NOCOUNT ON;

/* ============================================================
   ETAPA V - COMPARACION DE EFICIENCIA

   A) 1000 inserciones directas en Cliente.
   B) 1000 ejecuciones de dbo.sp_InsertarCliente 
   C) 1000 calculos del total con una consulta SQL directa.
   D) 1000 calculos del total usando dbo.fn_TotalVenta 

   Las inserciones de prueba se revierten mediante ROLLBACK.
   Los valores IDENTITY pueden avanzar aunque se reviertan
   las inserciones.

   Ejecutar despues de crear las funciones y los procedimientos.
   ============================================================ */

DECLARE @inicio DATETIME2(7);
DECLARE @i INT;
DECLARE @id_nuevo INT;
DECLARE @total FLOAT;
DECLARE @id_venta_prueba INT;

DECLARE @resultados TABLE
(
    operacion VARCHAR(100),
    repeticiones INT,
    milisegundos BIGINT
);


/* ------------------------------------------------------------
   VERIFICACIONES PREVIAS
   ------------------------------------------------------------ */

IF OBJECT_ID(N'dbo.sp_InsertarCliente', N'P') IS NULL
BEGIN
    THROW 51001,
        'No existe dbo.sp_InsertarCliente. Ejecute primero el script de Joa.',
        1;
END;

IF OBJECT_ID(N'dbo.fn_TotalVenta', N'FN') IS NULL
BEGIN
    THROW 51002,
        'No existe dbo.fn_TotalVenta. Ejecute primero 01_funciones.sql.',
        1;
END;

-- Buscar una venta que tenga al menos un detalle.
SELECT TOP (1)
    @id_venta_prueba = v.id_venta
FROM dbo.Venta AS v
INNER JOIN dbo.Detalle_Venta AS dv
    ON dv.id_venta = v.id_venta
ORDER BY v.id_venta;

IF @id_venta_prueba IS NULL
BEGIN
    THROW 51003,
        'No hay ventas con detalles para comparar. Cargue datos primero.',
        1;
END;


/* ============================================================
   A Y B: COMPARACION DE INSERCIONES
   ============================================================ */

BEGIN TRY

    BEGIN TRANSACTION;

    /* A. 1000 inserciones directas */

    SET @i = 1;
    SET @inicio = SYSDATETIME();

    WHILE @i <= 1000
    BEGIN
        INSERT INTO dbo.Cliente
        (
            nombre,
            apellido,
            direccion,
            email
        )
        VALUES
        (
            'Prueba',
            'Directo',
            'Calle Test 123',
            NULL
        );

        SET @i = @i + 1;
    END;

    INSERT INTO @resultados
    (
        operacion,
        repeticiones,
        milisegundos
    )
    VALUES
    (
        'A. INSERT directo en Cliente',
        1000,
        DATEDIFF_BIG(MILLISECOND, @inicio, SYSDATETIME())
    );


   

    SET @i = 1;
    SET @inicio = SYSDATETIME();

    WHILE @i <= 1000
    BEGIN
        EXEC dbo.sp_InsertarCliente
            @nombre = 'Prueba',
            @apellido = 'Procedimiento',
            @direccion = 'Calle Test 123',
            @id_cliente = @id_nuevo OUTPUT;

        SET @i = @i + 1;
    END;

    INSERT INTO @resultados
    (
        operacion,
        repeticiones,
        milisegundos
    )
    VALUES
    (
        'B. EXEC dbo.sp_InsertarCliente',
        1000,
        DATEDIFF_BIG(MILLISECOND, @inicio, SYSDATETIME())
    );

    -- Revertir todas las inserciones realizadas en esta prueba.
    ROLLBACK TRANSACTION;


    /* ========================================================
       C: 1000 CONSULTAS DIRECTAS DEL TOTAL
       ======================================================== */

    SET @i = 1;
    SET @inicio = SYSDATETIME();

    WHILE @i <= 1000
    BEGIN
        SELECT @total =
            SUM(dv.cantidad * dv.precio_historico)
        FROM dbo.Detalle_Venta AS dv
        WHERE dv.id_venta = @id_venta_prueba;

        SET @i = @i + 1;
    END;

    INSERT INTO @resultados
    (
        operacion,
        repeticiones,
        milisegundos
    )
    VALUES
    (
        'C. Consulta directa del total',
        1000,
        DATEDIFF_BIG(MILLISECOND, @inicio, SYSDATETIME())
    );


    /* ========================================================
       D: 1000 LLAMADAS A LA FUNCION fn_TotalVenta
       ======================================================== */

    SET @i = 1;
    SET @inicio = SYSDATETIME();

    WHILE @i <= 1000
    BEGIN
        SET @total = dbo.fn_TotalVenta(@id_venta_prueba);

        SET @i = @i + 1;
    END;

    INSERT INTO @resultados
    (
        operacion,
        repeticiones,
        milisegundos
    )
    VALUES
    (
        'D. dbo.fn_TotalVenta',
        1000,
        DATEDIFF_BIG(MILLISECOND, @inicio, SYSDATETIME())
    );


    /* ========================================================
       RESULTADOS
       ======================================================== */

    SELECT
        operacion,
        repeticiones,
        milisegundos
    FROM @resultados
    ORDER BY operacion;

    SELECT
        @id_venta_prueba AS venta_utilizada,
        @total AS ultimo_total_calculado,
        'Las inserciones de prueba fueron revertidas.' AS observacion;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO
