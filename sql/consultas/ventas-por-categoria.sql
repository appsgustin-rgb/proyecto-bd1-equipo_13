USE master;
go
USE base_distribuidora;
go

-- ============================================================
-- Reporte agregado: total de ventas por categoria de producto
-- Une 4 tablas: Categoria + Producto + Detalle_Venta + Venta
-- Usa GROUP BY, SUM y COUNT
-- ============================================================

SELECT
    c.id_categoria,
    c.nombre_categoria,
    COUNT(DISTINCT v.id_venta)                AS cantidad_ventas,
    SUM(dv.cantidad)                          AS unidades_vendidas,
    SUM(dv.cantidad * dv.precio_historico)    AS total_vendido
FROM Categoria c
INNER JOIN Producto p
    ON p.id_categoria = c.id_categoria
INNER JOIN Detalle_Venta dv
    ON dv.id_producto = p.id_producto
INNER JOIN Venta v
    ON v.id_venta = dv.id_venta
GROUP BY c.id_categoria, c.nombre_categoria
ORDER BY total_vendido DESC;