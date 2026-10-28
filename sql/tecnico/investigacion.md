# Investigación: Procedimientos y funciones almacenadas

## 1. Introducción

En los sistemas de bases de datos, los procedimientos y las funciones almacenadas permiten guardar instrucciones SQL en el servidor para reutilizarlas cuando sea necesario. Su utilización ayuda a organizar el código, centralizar las reglas de negocio y facilitar el mantenimiento de la base de datos.

En el proyecto de la distribuidora, estos mecanismos permiten administrar clientes y realizar cálculos relacionados con las ventas, los descuentos y el historial de compras.

## 2. Procedimientos almacenados

Un procedimiento almacenado es un conjunto de instrucciones SQL que se guarda en la base de datos y se ejecuta cuando se lo invoca mediante una instrucción como `EXEC`.

Los procedimientos pueden recibir parámetros, realizar inserciones, modificaciones y eliminaciones, consultar información y controlar errores.

### Procedimientos implementados en el proyecto

- **`sp_InsertarCliente`:** registra un nuevo cliente en la tabla `Cliente`.
- **`sp_ModificarCliente`:** permite modificar los datos de un cliente existente.
- **`sp_EliminarCliente`:** elimina un cliente identificado mediante su identificador, siempre que se cumplan las restricciones de la base de datos.

Estos procedimientos centralizan las operaciones de mantenimiento de clientes y permiten reutilizar las mismas instrucciones desde diferentes consultas o aplicaciones.

## 3. Funciones almacenadas

Una función almacenada es un objeto de la base de datos que recibe parámetros y devuelve un valor o una tabla. Puede utilizarse para realizar cálculos o proporcionar resultados que después se incorporan a consultas SQL.

### Funciones implementadas en el proyecto

- **`dbo.fn_TotalVenta(@id_venta)`:** calcula el importe total de una venta sumando el producto de la cantidad por el precio histórico de cada detalle.
- **`dbo.fn_CalcularDescuentoCliente(@id_cliente)`:** calcula el porcentaje de descuento correspondiente al cliente de acuerdo con el importe acumulado de sus compras.
- **`dbo.fn_VentasDeCliente(@id_cliente)`:** devuelve información de las ventas asociadas a un cliente, incluyendo datos de la venta, el medio de pago y su importe calculado.

La función de descuento devuelve un porcentaje; por sí sola no aplica el descuento ni modifica los registros de una venta.

## 4. Diferencias entre procedimientos y funciones

| Característica | Procedimientos almacenados | Funciones almacenadas |
|---|---|---|
| Ejecución | Se invocan normalmente mediante `EXEC`. | Pueden utilizarse dentro de consultas, según el tipo de función. |
| Resultado | Pueden devolver parámetros de salida, resultados de consultas o mensajes. | Devuelven un valor o una tabla. |
| Uso principal | Ejecutar operaciones y procesos de negocio. | Calcular valores y devolver información. |
| Modificación de datos | Pueden realizar operaciones de inserción, modificación y eliminación, sujetas a las reglas de la base de datos. | En SQL Server, las funciones definidas por el usuario tienen restricciones para modificar el estado de la base de datos. |
| Ejemplo del proyecto | `sp_InsertarCliente` | `dbo.fn_TotalVenta` |

## 5. Ventajas

### Procedimientos almacenados

- **Reutilización:** permiten ejecutar una operación sin escribir nuevamente todo el código SQL.
- **Mantenimiento:** concentran las operaciones de clientes en objetos identificables.
- **Seguridad:** permiten conceder permisos de ejecución sin otorgar necesariamente permisos directos sobre todas las tablas.
- **Validación:** pueden incorporar controles para evitar operaciones con datos inválidos.
- **Organización:** facilitan separar las operaciones de mantenimiento de los clientes de las consultas de análisis.

### Funciones almacenadas

- **Reutilización de cálculos:** evitan repetir la fórmula para calcular el total de una venta.
- **Consistencia:** centralizan las reglas utilizadas para calcular descuentos.
- **Integración con consultas:** permiten incorporar resultados calculados en otras consultas SQL.
- **Legibilidad:** ayudan a expresar operaciones de negocio mediante nombres descriptivos.
- **Mantenimiento:** permiten modificar una fórmula en un único objeto en lugar de actualizar cada consulta que la utiliza.

Estas ventajas no implican que un procedimiento o una función sea siempre más rápido que una consulta directa. El rendimiento depende del diseño, los índices, la cantidad de datos, el plan de ejecución y la forma en que se utiliza cada objeto.

## 6. Aplicación en la distribuidora

En una distribuidora de agua, los procedimientos y funciones pueden utilizarse para resolver necesidades concretas:

1. **Administración de clientes:** registrar nuevos clientes, actualizar sus datos y eliminarlos cuando corresponda.
2. **Control de ventas:** calcular el importe de una venta utilizando las cantidades y los precios históricos de sus productos.
3. **Descuentos comerciales:** determinar el porcentaje de descuento que corresponde según el total de compras acumuladas.
4. **Consulta del historial:** recuperar las ventas de un cliente y consultar los medios de pago asociados.
5. **Comparación de alternativas:** medir el tiempo de ejecución de operaciones realizadas directamente y mediante procedimientos o funciones.

Las reglas comerciales, como los importes mínimos para obtener descuentos, deben estar documentadas y coincidir con la implementación SQL.

## 7. Pruebas y validación

Para verificar el funcionamiento de los objetos se proponen las siguientes pruebas:

- Insertar un cliente de prueba y comprobar que se haya registrado correctamente.
- Modificar sus datos y verificar que los cambios se hayan aplicado.
- Eliminar el cliente de prueba y comprobar que ya no exista.
- Intentar modificar o eliminar un identificador inexistente y observar el comportamiento del procedimiento.
- Calcular el total de una venta cuyos detalles se conozcan y comparar el resultado con el cálculo manual.
- Probar el cálculo del descuento con clientes cuyos importes acumulados estén por debajo, en el límite y por encima de los umbrales definidos.
- Consultar las ventas de un cliente que tenga registros asociados y de otro que no tenga ventas.
- Comparar los tiempos de ejecución de operaciones equivalentes, registrando los resultados reales.

Las pruebas deben realizarse en una base de datos de desarrollo y con identificadores verificados para evitar modificar información importante.

## 8. Comparación de eficiencia

El proyecto incluye un script para comparar operaciones directas con operaciones realizadas mediante procedimientos y funciones almacenadas.

Para que la comparación sea válida, deben utilizarse operaciones equivalentes, condiciones similares y datos de prueba controlados. Conviene realizar varias ejecuciones y registrar los tiempos medidos en milisegundos.

Los resultados deben presentarse en una tabla con el tipo de operación, el método utilizado y el tiempo obtenido. No se deben afirmar mejoras de rendimiento sin evidencia experimental.

Además del tiempo transcurrido, pueden analizarse el tiempo de CPU, las lecturas lógicas y los planes de ejecución mediante las herramientas de SQL Server Management Studio.

## 9. Conclusión

Los procedimientos y las funciones almacenadas permiten organizar la lógica de acceso y procesamiento de datos de la distribuidora. Los procedimientos del proyecto se orientan a las operaciones de mantenimiento de clientes, mientras que las funciones permiten calcular totales, determinar descuentos y consultar las ventas de un cliente.

Su correcta implementación requiere nombres claros, comentarios, validaciones y pruebas de éxito y error. La comparación de rendimiento debe basarse en mediciones reales, ya que el uso de objetos almacenados no garantiza por sí mismo una mayor velocidad de ejecución.

## 10. Archivos relacionados

Los scripts relacionados con este tema se encuentran en las carpetas del proyecto:

- `sql/tecnico/procedimientos_funciones/01_procedimientos_crud.sql`
- `sql/tecnico/procedimientos_funciones/02_lote_insert_directo.sql`
- `sql/tecnico/procedimientos_funciones/03_lote_con_procedimientos.sql`
- `sql/tecnico/procedimientos_funciones/04_comparacion_eficiencia.sql`
- `sql/tecnico/funciones/01_funciones.sql`

Estos archivos contienen la implementación y las pruebas. Deben revisarse antes de ejecutarlos para verificar sus dependencias y evitar duplicar operaciones.
