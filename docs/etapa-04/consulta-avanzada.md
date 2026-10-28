# Consulta de negocio avanzada: seguimiento de entregas

## 1. Objetivo

Detectar las entregas que requieren seguimiento por parte del encargado de los repartos:

- las entregas que siguen pendientes, indicando si ya pasó demasiado tiempo desde la fecha prevista;
- las entregas que se realizaron en una dirección distinta a la registrada para el cliente.

Además, se consideran solo las ventas que alcanzan un importe mínimo, para concentrar el control en las ventas de mayor valor.

## 2. Tablas utilizadas

| Tabla | Datos que aporta |
|---|---|
| `Entrega` | Fecha, estado y dirección de la entrega. |
| `Venta` | Relación entre la entrega y el cliente. |
| `Cliente` | Nombre, apellido y dirección registrada del cliente. |
| `Detalle_Venta` | Importes de la venta, utilizados en las subconsultas. |

## 3. Consulta

```sql
DECLARE @importe_minimo FLOAT = 4000;

SELECT
    e.id_entrega,
    e.fecha_entrega,
    e.estado_entrega,
    c.nombre,
    c.apellido,
    c.direccion            AS direccion_cliente,
    e.direccion_entrega,
    DATEDIFF(DAY, e.fecha_entrega, GETDATE()) AS dias_desde_entrega,
    CASE
        WHEN e.direccion_entrega <> c.direccion THEN 'Direccion distinta'
        ELSE 'Direccion del cliente'
    END AS control_direccion,
    CASE
        WHEN e.estado_entrega = 'Pendiente'
             AND DATEDIFF(DAY, e.fecha_entrega, GETDATE()) > 30 THEN 'Urgente'
        WHEN e.estado_entrega = 'Pendiente' THEN 'En seguimiento'
        ELSE 'Finalizada'
    END AS prioridad,
    (SELECT SUM(dv.cantidad * dv.precio_historico)
     FROM Detalle_Venta dv
     WHERE dv.id_venta = v.id_venta) AS total_venta
FROM Entrega e
INNER JOIN Venta v
    ON e.id_venta = v.id_venta
INNER JOIN Cliente c
    ON v.id_cliente = c.id_cliente
WHERE (e.estado_entrega = 'Pendiente'
       OR e.direccion_entrega <> c.direccion)
  AND v.id_venta IN (
        SELECT dv2.id_venta
        FROM Detalle_Venta dv2
        GROUP BY dv2.id_venta
        HAVING SUM(dv2.cantidad * dv2.precio_historico) >= @importe_minimo
  )
ORDER BY
    CASE WHEN e.estado_entrega = 'Pendiente' THEN 0 ELSE 1 END,
    e.fecha_entrega ASC;
```

## 4. Explicación

- **Uniones:** se combinan las tablas `Entrega`, `Venta` y `Cliente` mediante `INNER JOIN`. La tabla `Detalle_Venta` se utiliza dentro de las subconsultas.
- **Filtro condicional con `WHERE`:** se seleccionan las entregas pendientes o las realizadas en una dirección distinta a la del cliente. Las dos condiciones se agrupan entre paréntesis para que el `OR` no afecte al resto del filtro.
- **Filtro con subconsulta y `HAVING`:** la subconsulta agrupa los renglones de `Detalle_Venta` por venta y, mediante `HAVING`, conserva solo las ventas cuyo total alcanza el valor de `@importe_minimo`. La consulta principal incluye únicamente las entregas de esas ventas (`IN`).
- **Subconsulta correlacionada:** la columna `total_venta` se obtiene con una subconsulta que suma los renglones de la venta de cada fila.
- **Días transcurridos:** `DATEDIFF` calcula los días desde la fecha de entrega hasta la fecha actual.
- **Columnas condicionales con `CASE`:** `control_direccion` indica si la entrega se hizo en otra dirección, y `prioridad` marca como urgentes las entregas pendientes con más de 30 días.
- **Orden:** primero se muestran las entregas pendientes y luego las finalizadas, en ambos casos por fecha de entrega.

## 5. Resultado obtenido

Resultado con los datos de prueba, `@importe_minimo = 4000` y ejecutado el 28/10/2026:

| id_entrega | estado_entrega | cliente | direccion_entrega | dias_desde_entrega | control_direccion | prioridad | total_venta |
|---|---|---|---|---|---|---|---|
| 9 | Pendiente | Juan Perez | Av. Italia 1250 | 49 | Direccion distinta | Urgente | 7300 |
| 10 | Pendiente | Carlos Rodriguez | Junin 1320 | 48 | Direccion del cliente | Urgente | 10000 |
| 1 | Entregada | Juan Perez | Av. Italia 1250 | 57 | Direccion distinta | Finalizada | 4600 |

Los días transcurridos y, por lo tanto, la prioridad dependen de la fecha en que se ejecuta la consulta.

Las entregas 9 y 10 aparecen por estar pendientes. La entrega 1 ya fue realizada, pero aparece porque se entregó en una dirección distinta a la registrada para el cliente (`Av. 3 de abril 1250`).

## 6. Pruebas y validación

- **Filtro por importe:** al cambiar `@importe_minimo` a 8000, la consulta devuelve solo la entrega 10, ya que la venta 9 (7300) y la venta 1 (4600) no alcanzan ese importe.
- **Control del total:** el total de la venta 9 coincide con el cálculo manual: 3 × 1500 + 2 × 1400 = 7300.
- **Entregas excluidas:** las entregas 2 a 8 no aparecen porque ya fueron realizadas y su dirección coincide con la del cliente.

## 7. Archivo relacionado

- `sql/consultas/seguimiento-entregas.sql`
