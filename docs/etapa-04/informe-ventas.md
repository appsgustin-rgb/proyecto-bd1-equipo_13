# Informe de ventas por categoría

## 1. Objetivo

Obtener un reporte agregado con el total de ventas realizadas por cada categoría de producto dentro de un rango de fechas, indicando la cantidad de ventas, las unidades vendidas y el importe total.

El modelo de datos no registra vendedores, por lo que el reporte se realizó por categoría de producto, que es una de las opciones planteadas en la consigna.

## 2. Tablas utilizadas

| Tabla | Datos que aporta |
|---|---|
| `Categoria` | Nombre de la categoría. |
| `Producto` | Relación entre cada producto y su categoría. |
| `Detalle_Venta` | Cantidades y precios históricos vendidos. |
| `Venta` | Fecha de la venta, utilizada para filtrar el período. |

## 3. Consulta

```sql
DECLARE @fecha_desde DATE = '2026-09-01';
DECLARE @fecha_hasta DATE = '2026-09-30';

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
    WHERE v.fecha_venta BETWEEN @fecha_desde AND @fecha_hasta
GROUP BY c.id_categoria, c.nombre_categoria
ORDER BY total_vendido DESC;
```

## 4. Explicación

- **Rango de fechas:** el período se define con las variables `@fecha_desde` y `@fecha_hasta`, y se filtra con `BETWEEN` sobre la fecha de la venta. Para consultar otro período se deben modificar esas variables.
- **Uniones:** se combinan cuatro tablas mediante `INNER JOIN` para llegar desde cada categoría hasta las ventas de sus productos.
- **Agrupamiento:** `GROUP BY` agrupa los renglones vendidos por categoría.
- **Cantidad de ventas:** se utiliza `COUNT(DISTINCT v.id_venta)` porque una misma venta puede tener varios renglones de la misma categoría. Por ejemplo, la venta 3 incluye dos productos de la categoría agua carbonatada y debe contarse una sola vez.
- **Unidades vendidas:** `SUM(dv.cantidad)` suma las cantidades de todos los renglones de la categoría.
- **Total vendido:** `SUM(dv.cantidad * dv.precio_historico)` suma los subtotales de todos los renglones de la categoría.
- **Orden:** las categorías se muestran de mayor a menor importe vendido.

## 5. Resultado obtenido

Resultado para el período del 01/09/2026 al 30/09/2026, con los datos de prueba:

| id_categoria | nombre_categoria | cantidad_ventas | unidades_vendidas | total_vendido |
|---|---|---|---|---|
| 3 | agua de mesa | 5 | 7 | 37500 |
| 1 | agua mineral | 6 | 20 | 21000 |
| 2 | agua carbonatada | 5 | 20 | 18800 |
| 4 | agua saborizada | 2 | 6 | 8400 |

La categoría agua de mesa es la de mayor importe vendido aunque tiene menos unidades, porque incluye los bidones, que son los productos de mayor precio.

## 6. Pruebas y validación

- **Control del total:** la suma de los importes de las cuatro categorías (37500 + 21000 + 18800 + 8400 = 85700) coincide con la suma de los totales de las diez ventas del período.
- **Conteo sin duplicados:** la categoría agua carbonatada tiene seis renglones vendidos, pero la consulta informa cinco ventas, ya que la venta 3 tiene dos renglones de esa categoría.
- **Período sin ventas:** al consultar un período sin ventas registradas, por ejemplo del 01/08/2026 al 31/08/2026, la consulta no devuelve filas.

## 7. Archivo relacionado

- `sql/consultas/ventas-por-categoria.sql`
