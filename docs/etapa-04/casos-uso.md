# Casos de uso

## 1. Introducción

En esta etapa se desarrollaron consultas SQL para responder a necesidades de información concretas de la distribuidora. Cada consulta corresponde a un caso de uso del negocio: emitir el comprobante de una venta, analizar las ventas realizadas por categoría de producto y controlar el estado de las entregas.

Las consultas se probaron sobre la base de datos `base_distribuidora`, utilizando los datos cargados con el script `sql/dml/INSERT.sql`.

## 2. Resumen de casos de uso

| Caso de uso | Necesidad de información | Script | Documento |
|---|---|---|---|
| CU-01: Emitir comprobante de venta | Factura / Comprobante | `sql/consultas/comprobante-venta.sql` | `comprobante-venta.md` |
| CU-02: Consultar ventas por categoría | Reporte agregado | `sql/consultas/ventas-por-categoria.sql` | `informe-ventas.md` |
| CU-03: Controlar entregas | Consulta de negocio avanzada | `sql/consultas/seguimiento-entregas.sql` | `consulta-avanzada.md` |

## 3. CU-01: Emitir comprobante de venta

- **Actor:** empleado encargado de las ventas.
- **Objetivo:** obtener el comprobante de una venta con los datos del cliente, los productos vendidos, el subtotal de cada renglón y el total de la venta.
- **Datos de entrada:** número de la venta (`id_venta`).
- **Precondición:** la venta debe existir y tener al menos un renglón en `Detalle_Venta`.
- **Resultado:** una fila por cada renglón de la venta, con la cantidad, el precio, el subtotal del renglón y el total de la venta.
- **Tablas utilizadas:** `Venta`, `Cliente`, `Detalle_Venta` y `Producto`.

## 4. CU-02: Consultar ventas por categoría

- **Actor:** encargado o administración de la distribuidora.
- **Objetivo:** conocer cuánto se vendió de cada categoría de producto en un período determinado, para identificar los productos con mayor demanda.
- **Datos de entrada:** fecha de inicio y fecha de fin del período.
- **Precondición:** deben existir ventas registradas dentro del período consultado.
- **Resultado:** una fila por categoría con la cantidad de ventas, las unidades vendidas y el importe total, ordenadas de mayor a menor importe.
- **Tablas utilizadas:** `Categoria`, `Producto`, `Detalle_Venta` y `Venta`.

El modelo de datos no registra vendedores, por lo que el reporte agregado se realizó por categoría de producto, que es una de las dos opciones planteadas en la consigna.

## 5. CU-03: Controlar entregas

- **Actor:** encargado de los repartos.
- **Objetivo:** detectar las entregas que requieren seguimiento: las que siguen pendientes y las que se realizaron en una dirección distinta a la registrada para el cliente.
- **Datos de entrada:** importe mínimo de la venta a controlar.
- **Precondición:** deben existir entregas asociadas a ventas.
- **Resultado:** listado de entregas con los datos del cliente, los días transcurridos, un control de dirección, una prioridad y el total de la venta. Primero se muestran las entregas pendientes.
- **Tablas utilizadas:** `Entrega`, `Venta`, `Cliente` y `Detalle_Venta`.

## 6. Consideraciones generales

- Los importes se calculan con `precio_historico` de `Detalle_Venta` y no con `precio_actual` de `Producto`. De esta forma, el importe de una venta realizada no cambia si después se actualiza el precio del producto.
- Las consultas que reciben datos de entrada utilizan variables (`DECLARE`) o una condición en el `WHERE`, que deben modificarse para consultar otra venta, otro período u otro importe.
- Las consultas solo leen información; no modifican los datos de la base.
