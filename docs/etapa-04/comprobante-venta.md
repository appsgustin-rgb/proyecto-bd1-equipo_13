# Comprobante de venta

## 1. Objetivo

Obtener el comprobante de una venta consolidando en una sola consulta el encabezado (número, fecha y datos del cliente) y el detalle (productos, cantidades y precios), calculando el subtotal de cada renglón y el total de la venta.

## 2. Tablas utilizadas

| Tabla | Datos que aporta |
|---|---|
| `Venta` | Número y fecha de la venta. |
| `Cliente` | Nombre, apellido y dirección del cliente. |
| `Detalle_Venta` | Número de renglón, cantidad y precio histórico de cada producto vendido. |
| `Producto` | Nombre del producto. |

## 3. Consulta

```sql
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
```

## 4. Explicación

- **Uniones:** se combinan las cuatro tablas mediante `INNER JOIN`. `Venta` se une con `Cliente` para obtener los datos del encabezado, con `Detalle_Venta` para obtener los renglones y cada renglón con `Producto` para obtener el nombre del producto.
- **Subtotal por renglón:** se calcula multiplicando la cantidad por el precio histórico de cada renglón.
- **Total de la venta:** se calcula con `SUM(...) OVER (PARTITION BY v.id_venta)`. Esta función de ventana suma los subtotales de todos los renglones de la venta sin agrupar las filas, por lo que se conserva el detalle y el total aparece en cada renglón.
- **Precio histórico:** se utiliza `precio_historico` y no `precio_actual`, para que el comprobante muestre el precio vigente al momento de la venta.
- **Venta consultada:** la condición `WHERE v.id_venta = 1` indica qué comprobante se obtiene. Para consultar otra venta se debe cambiar ese número.
- **Orden:** los renglones se muestran según su número de línea.

## 5. Resultado obtenido

Resultado para la venta 1, con los datos de prueba:

| id_venta | fecha_venta | nombre | apellido | nombre_producto | nro_linea | cantidad | precio_historico | subtotal | total_venta |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 2026-09-01 | Juan | Perez | Agua mineral 500ml | 1 | 3 | 800 | 2400 | 4600 |
| 1 | 2026-09-01 | Juan | Perez | Soda 1.5L | 2 | 2 | 1100 | 2200 | 4600 |

La consulta también devuelve la dirección del cliente (`Av. 3 de abril 1250`), que se omitió en la tabla por espacio.

## 6. Pruebas y validación

- **Cálculo manual:** 3 × 800 + 2 × 1100 = 2400 + 2200 = 4600, que coincide con el total devuelto por la consulta.
- **Venta con un solo renglón:** al consultar la venta 7 se obtiene una única fila con subtotal y total iguales (6 × 700 = 4200).
- **Venta inexistente:** al consultar un número de venta que no existe, la consulta no devuelve filas.

## 7. Archivo relacionado

- `sql/consultas/comprobante-venta.sql`
