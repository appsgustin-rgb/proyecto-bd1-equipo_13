-- ============================================
-- COMPROBANTE
-- ============================================

SELECT
    v.id_venta,
    v.fecha_venta,
    c.nombre,
    c.apellido,
    c.direccion,
    p.nombre_producto,
    dv.nro_linea,
    dv.cantidad,
    dv.precio_historico,
    dv.cantidad * dv.precio_historico AS subtotal,
    SUM(dv.cantidad * dv.precio_historico)
        OVER (PARTITION BY v.id_venta) AS total_venta
FROM Venta v
INNER JOIN Cliente c
    ON v.id_cliente = c.id_cliente
INNER JOIN Detalle_Venta dv
    ON v.id_venta = dv.id_venta
INNER JOIN Producto p
    ON dv.id_producto = p.id_producto
WHERE v.id_venta = 1
ORDER BY dv.nro_linea;
