# Investigación: Triggers de auditoría

## 1. Introducción

En una base de datos no siempre alcanza con conocer el estado actual de la información; en muchos casos también es necesario saber cómo se llegó a ese estado. Los triggers de auditoría permiten registrar automáticamente los cambios que se realizan sobre las tablas, indicando qué se modificó, cuándo y qué usuario lo hizo.

En el proyecto de la distribuidora, estos mecanismos permiten llevar un historial de los cambios de precio y de stock de los productos y de los cambios de estado de las entregas.

## 2. Triggers

Un trigger (o disparador) es un objeto de la base de datos asociado a una tabla que se ejecuta automáticamente cuando ocurre un evento sobre ella. En SQL Server, los triggers DML se ejecutan ante operaciones `INSERT`, `UPDATE` o `DELETE`.

A diferencia de un procedimiento almacenado, un trigger no se invoca mediante `EXEC`: lo ejecuta el motor cada vez que se produce el evento para el que fue definido.

Dentro de un trigger, SQL Server permite consultar dos tablas temporales:

- **`inserted`:** contiene las filas con los valores nuevos. Se completa en las operaciones `INSERT` y `UPDATE`.
- **`deleted`:** contiene las filas con los valores anteriores. Se completa en las operaciones `DELETE` y `UPDATE`.

En una operación `UPDATE` ambas tablas tienen datos, por lo que es posible comparar el valor anterior y el valor nuevo de cada columna.

Los triggers pueden ser de tipo `AFTER`, que se ejecutan después de realizada la operación, o `INSTEAD OF`, que reemplazan la operación original. Para la auditoría se utilizan triggers `AFTER`, ya que la operación debe realizarse normalmente y luego registrarse.

En SQL Server un trigger se ejecuta una vez por cada sentencia y no una vez por cada fila. Si una sentencia `UPDATE` modifica varios productos, el trigger se ejecuta una sola vez y las tablas `inserted` y `deleted` contienen todas las filas afectadas. Por este motivo, los triggers del proyecto registran los cambios mediante `INSERT ... SELECT` en lugar de utilizar variables.

### Triggers implementados en el proyecto

- **`trg_AuditoriaProducto_Insert`:** registra en `Auditoria_Producto` cada producto nuevo.
- **`trg_AuditoriaProducto_Update`:** registra los cambios de precio y de stock de un producto, con sus valores anteriores y nuevos.
- **`trg_AuditoriaProducto_Delete`:** registra los productos eliminados, conservando su último precio y stock.
- **`trg_AuditoriaEntrega_Update`:** registra en `Auditoria_Entrega` los cambios de estado de una entrega.

El trigger de modificación de productos solo agrega un registro cuando cambia el precio o el stock. Si una sentencia `UPDATE` no modifica esos valores, no se registra nada.

## 3. Tablas de auditoría

Los cambios de productos se guardan en la tabla `Auditoria_Producto`:

| Columna | Descripción |
|---|---|
| `id_auditoria` | Identificador del registro. |
| `fecha` | Fecha y hora del cambio. Se completa con `GETDATE()`. |
| `usuario` | Usuario de SQL Server que realizó el cambio. Se completa con `SUSER_SNAME()`. |
| `operacion` | Tipo de operación: `INSERT`, `UPDATE` o `DELETE`. |
| `id_producto`, `nombre_producto` | Producto afectado. |
| `precio_anterior`, `precio_nuevo` | Precio antes y después del cambio. |
| `stock_anterior`, `stock_nuevo` | Stock antes y después del cambio. |

La tabla `Auditoria_Entrega` guarda la fecha, el usuario, la entrega, la venta asociada y los estados anterior y nuevo.

Ninguna de las dos tablas tiene claves foráneas hacia las tablas auditadas. De esta forma, el historial se conserva aunque el producto o la entrega se eliminen.

## 4. Diferencias entre triggers y procedimientos almacenados

| Característica | Triggers | Procedimientos almacenados |
|---|---|---|
| Ejecución | Automática, cuando ocurre un `INSERT`, `UPDATE` o `DELETE` sobre la tabla. | Manual, mediante `EXEC`. |
| Parámetros | No reciben parámetros; trabajan con las tablas `inserted` y `deleted`. | Pueden recibir parámetros de entrada y de salida. |
| Asociación | Están asociados a una tabla. | No dependen de una tabla en particular. |
| Uso principal | Reaccionar ante cambios: auditoría, controles y trazabilidad. | Ejecutar operaciones y procesos de negocio. |
| Ejemplo del proyecto | `trg_AuditoriaProducto_Update` | `sp_InsertarCliente` |

## 5. Ventajas y desventajas

### Ventajas

- **Registro automático:** los cambios se registran sin depender de que el usuario o la aplicación lo hagan.
- **Trazabilidad:** permiten responder quién modificó un precio, cuándo se eliminó un producto y qué valor tenía antes de la modificación.
- **Independencia del origen:** el cambio se registra aunque se realice desde SQL Server Management Studio, desde un procedimiento almacenado o desde otra aplicación.
- **Consistencia:** el trigger forma parte de la misma transacción que la operación que lo dispara. Si la operación se deshace, el registro de auditoría también se deshace.
- **Mantenimiento:** la regla de auditoría queda definida en un único objeto por tabla y evento.

### Desventajas

- **Trabajo adicional:** cada operación sobre una tabla auditada realiza también una inserción en la tabla de auditoría.
- **Poca visibilidad:** quien ejecuta una sentencia no ve que se está ejecutando un trigger, por lo que estos objetos deben estar documentados.
- **Crecimiento de las tablas:** las tablas de auditoría aumentan de tamaño con el tiempo y conviene definir un criterio para depurarlas o archivarlas.

## 6. Aplicación en la distribuidora

En una distribuidora de agua, los triggers de auditoría pueden utilizarse para resolver necesidades concretas:

1. **Control de precios:** registrar cada actualización de precios de los productos con el valor anterior y el nuevo.
2. **Control de stock:** registrar los descuentos de stock producidos por las ventas y los ajustes manuales.
3. **Altas y bajas de productos:** conocer cuándo se incorporó o se eliminó un producto del catálogo y qué usuario lo hizo.
4. **Seguimiento de entregas:** conocer en qué momento una entrega pasó de `Pendiente` a `Entregada`. Esta información complementa la consulta de seguimiento de entregas de la etapa IV.

## 7. Pruebas y validación

Para verificar el funcionamiento de los triggers se realizaron las siguientes pruebas:

- Modificar el precio de un producto y comprobar que se registren el precio anterior y el nuevo.
- Descontar stock de un producto, simulando una venta, y comprobar que se registren el stock anterior y el nuevo.
- Actualizar el precio de todos los productos de una categoría y comprobar que se registre una fila por cada producto.
- Ejecutar un `UPDATE` que no cambie ningún valor y comprobar que no se agregue ningún registro.
- Insertar y eliminar un producto de prueba y comprobar que se registren ambas operaciones.
- Modificar un precio dentro de una transacción, deshacerla con `ROLLBACK` y comprobar que no quede ningún registro.
- Cambiar el estado de una entrega pendiente y comprobar que se registren el estado anterior y el nuevo.

Al finalizar, el script vuelve los precios, el stock y el estado de la entrega a sus valores originales. Estas modificaciones también quedan registradas en las tablas de auditoría.

Las pruebas deben realizarse en una base de datos de desarrollo, ya que modifican datos de las tablas `Producto` y `Entrega`.

## 8. Relación con otros temas técnicos

- **Transacciones:** el trigger se ejecuta dentro de la misma transacción que la operación. Si la venta o la modificación se deshace con `ROLLBACK`, el registro de auditoría también se deshace, por lo que la auditoría solo refleja operaciones confirmadas.
- **Procedimientos almacenados:** si un procedimiento descuenta stock al registrar una venta, el cambio queda auditado sin necesidad de modificar el procedimiento.
- **Seguridad:** los usuarios comunes no deberían tener permisos de `UPDATE` ni `DELETE` sobre las tablas de auditoría, para que el historial no pueda alterarse.

## 9. Conclusión

Los triggers de auditoría permiten registrar de forma automática los cambios realizados sobre los datos de la distribuidora. En el proyecto se aplicaron sobre la tabla `Producto`, para controlar precios, stock, altas y bajas, y sobre la tabla `Entrega`, para seguir los cambios de estado de cada envío.

Su correcta implementación requiere tener en cuenta que el trigger se ejecuta una vez por sentencia, registrar solo los cambios relevantes y documentar su existencia. De esta forma es posible responder quién realizó un cambio, cuándo lo hizo y qué valor tenía antes la información.

## 10. Archivos relacionados

Los scripts relacionados con este tema se encuentran en las carpetas del proyecto:

- `sql/tecnico/triggers/01_triggers_auditoria.sql`
- `sql/tecnico/triggers/02_pruebas_triggers.sql`

El primer archivo crea las tablas de auditoría y los triggers. El segundo contiene las pruebas y debe ejecutarse después del primero.