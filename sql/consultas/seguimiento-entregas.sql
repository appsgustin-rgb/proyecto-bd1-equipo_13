USE master;
go
USE base_distribuidora;
go

-- ============================================================
-- Consulta avanzada: seguimiento / control de entregas
-- Une 3 tablas: Entrega + Venta + Cliente
-- Usa Detalle_Venta en subconsultas para obtener el total de la venta
-- Aplica filtros condicionales con WHERE, CASE, subconsulta y HAVING
-- ============================================================

-- Importe minimo de la venta para incluir la entrega en el control
DECLARE @importe_minimo FLOAT = 4000;

SELECT
    e.id_entrega,
    e.fecha_entrega,
    e.estado_entrega,
    c.nombre,
    c.apellido,
    c.direccion            AS direccion_cliente,
    e.direccion_entrega,
    -- Dias transcurridos desde la fecha de entrega hasta hoy
    DATEDIFF(DAY, e.fecha_entrega, GETDATE()) AS dias_desde_entrega,
    -- Columna condicional: marca si se entrego en otra direccion
    CASE
        WHEN e.direccion_entrega <> c.direccion THEN 'Direccion distinta'
        ELSE 'Direccion del cliente'
    END AS control_direccion,
    -- Columna condicional: prioridad segun estado y antiguedad
    CASE
        WHEN e.estado_entrega = 'Pendiente'
             AND DATEDIFF(DAY, e.fecha_entrega, GETDATE()) > 30 THEN 'Urgente'
        WHEN e.estado_entrega = 'Pendiente' THEN 'En seguimiento'
        ELSE 'Finalizada'
    END AS prioridad,
    -- Subconsulta: total de la venta asociada a la entrega
    (SELECT SUM(dv.cantidad * dv.precio_historico)
     FROM Detalle_Venta dv
     WHERE dv.id_venta = v.id_venta) AS total_venta
FROM Entrega e
INNER JOIN Venta v
    ON e.id_venta = v.id_venta
INNER JOIN Cliente c
    ON v.id_cliente = c.id_cliente
-- Filtro condicional: pendientes, o entregas hechas a una direccion
-- distinta a la registrada del cliente
WHERE (e.estado_entrega = 'Pendiente'
       OR e.direccion_entrega <> c.direccion)
  -- Filtro con subconsulta y HAVING: solo ventas cuyo total
  -- alcanza el importe minimo
  AND v.id_venta IN (
        SELECT dv2.id_venta
        FROM Detalle_Venta dv2
        GROUP BY dv2.id_venta
        HAVING SUM(dv2.cantidad * dv2.precio_historico) >= @importe_minimo
  )
ORDER BY
    CASE WHEN e.estado_entrega = 'Pendiente' THEN 0 ELSE 1 END,
    e.fecha_entrega ASC;
