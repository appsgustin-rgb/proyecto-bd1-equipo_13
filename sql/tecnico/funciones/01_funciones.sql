USE base_distribuidora;
GO

/* ============================================================
   ETAPA V - FUNCIONES ALMACENADAS
   ============================================================

   Funcion 1: fn_TotalVenta
   Calcula el total de una venta usando el precio historico.

   Funcion 2: fn_CalcularDescuentoCliente
   Calcula el porcentaje de descuento segun las compras
   acumuladas del cliente.

   Funcion 3: fn_VentasDeCliente
   Devuelve las ventas de un cliente con fecha, medio de pago
   y total de cada venta.
   ============================================================ */


/* ============================================================
   FUNCION 1: TOTAL DE UNA VENTA
   ============================================================ */

CREATE OR ALTER FUNCTION dbo.fn_TotalVenta
(
    @id_venta INT
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @total FLOAT;

    SELECT @total = SUM(dv.cantidad * dv.precio_historico)
    FROM dbo.Detalle_Venta AS dv
    WHERE dv.id_venta = @id_venta;

    RETURN ISNULL(@total, 0);
END;
GO


/* ============================================================
   FUNCION 2: DESCUENTO SEGUN COMPRAS ACUMULADAS DEL CLIENTE

   Reglas:
   - Total acumulado >= 15000: 10 %
   - Total acumulado >= 10000: 5 %
   - Total acumulado < 10000: 0 %

   Devuelve 0.10, 0.05 o 0.00.
   Esta funcion calcula el porcentaje; no lo aplica ni guarda.
   ============================================================ */

CREATE OR ALTER FUNCTION dbo.fn_CalcularDescuentoCliente
(
    @id_cliente INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @total_acumulado FLOAT;

    SELECT @total_acumulado =
        SUM(dv.cantidad * dv.precio_historico)
    FROM dbo.Venta AS v
    INNER JOIN dbo.Detalle_Venta AS dv
        ON dv.id_venta = v.id_venta
    WHERE v.id_cliente = @id_cliente;

    RETURN
        CASE
            WHEN ISNULL(@total_acumulado, 0) >= 15000 THEN 0.10
            WHEN ISNULL(@total_acumulado, 0) >= 10000 THEN 0.05
            ELSE 0.00
        END;
END;
GO


/* ============================================================
   FUNCION 3: VENTAS DE UN CLIENTE

   Es una funcion con valor de tabla. Permite consultar las
   ventas de un cliente y calcular el total de cada una.
   ============================================================ */

CREATE OR ALTER FUNCTION dbo.fn_VentasDeCliente
(
    @id_cliente INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        v.id_venta,
        v.fecha_venta,
        mp.descripcion AS metodo_pago,
        SUM(dv.cantidad * dv.precio_historico) AS total_venta
    FROM dbo.Venta AS v
    INNER JOIN dbo.Metodo_Pago AS mp
        ON mp.id_metodo_pago = v.id_metodo_pago
    INNER JOIN dbo.Detalle_Venta AS dv
        ON dv.id_venta = v.id_venta
    WHERE v.id_cliente = @id_cliente
    GROUP BY
        v.id_venta,
        v.fecha_venta,
        mp.descripcion
);
GO


/* ============================================================
   PRUEBAS DE LAS FUNCIONES
   Estas consultas no modifican los datos.
   ============================================================ */


/* PRUEBA 1: total de cada venta */

SELECT
    v.id_venta,
    v.fecha_venta,
    dbo.fn_TotalVenta(v.id_venta) AS total_venta
FROM dbo.Venta AS v
ORDER BY v.id_venta;
GO


/* PRUEBA 1B: venta inexistente.
   Resultado esperado: 0. */

SELECT dbo.fn_TotalVenta(999999) AS total_venta_inexistente;
GO


/* PRUEBA 2: porcentaje de descuento por cliente */

SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,
    dbo.fn_CalcularDescuentoCliente(c.id_cliente)
        AS porcentaje_descuento
FROM dbo.Cliente AS c
ORDER BY
    porcentaje_descuento DESC,
    c.apellido,
    c.nombre;
GO


/* PRUEBA 3: ventas del cliente con ID 1 */

SELECT *
FROM dbo.fn_VentasDeCliente(1)
ORDER BY fecha_venta, id_venta;
GO


/* PRUEBA 3B: cliente inexistente.
   Resultado esperado: cero filas. */

SELECT *
FROM dbo.fn_VentasDeCliente(999999);
GO
