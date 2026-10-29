# Procedimientos y Funciones Almacenadas

## 1. Definición y diferencias

Un **procedimiento almacenado** es un conjunto de instrucciones SQL guardado en la
base de datos que se ejecuta con `EXEC`. Su objetivo es **operar**: puede insertar,
modificar y borrar datos, y usar transacciones.

Una **función almacenada** recibe parámetros y **devuelve un valor** (función escalar)
o **una tabla** (función con valores de tabla). Su objetivo es **calcular**. Se usa
dentro de una consulta y no puede modificar datos.

| | Procedimiento | Función |
|---|---|---|
| Se invoca con | `EXEC` | Dentro de un `SELECT`, `WHERE`, etc. |
| Valor de retorno | Opcional (resultados o parámetros OUTPUT) | Obligatorio (valor o tabla) |
| Modifica datos (INSERT/UPDATE/DELETE) | Sí | No |
| Transacciones / TRY-CATCH | Sí | No |
| Uso en el proyecto | CRUD de clientes | Totales, descuentos, consultas |

## 2. Ventajas y aplicaciones

- **Reutilización:** la lógica se escribe una vez y se invoca donde haga falta.
- **Centralización de reglas de negocio:** por ejemplo, "no se borra un cliente con ventas".
- **Mantenibilidad:** un cambio de regla se hace en un solo lugar.
- **Seguridad:** se puede dar permiso de ejecutar un procedimiento sin acceso directo a las tablas.
- **Validación:** los datos se controlan antes de llegar a la tabla.

## 3. Procedimientos CRUD sobre `Cliente`

| Procedimiento | Operación | Validaciones |
|---|---|---|
| `sp_InsertarCliente` | INSERT | Nombre, apellido y dirección obligatorios (error 50010). Devuelve el id generado por OUTPUT. |
| `sp_ModificarCliente` | UPDATE | El cliente debe existir (50011). Los parámetros en NULL no se modifican. |
| `sp_EliminarCliente` | DELETE | El cliente debe existir (50012) y no tener ventas (50013). Borra también sus teléfonos dentro de una transacción. |

**Scripts:**
- `01_procedimientos_crud.sql`: creación de los 3 procedimientos.
- `02_lote_insert_directo.sql`: lote de 5 clientes cargados con INSERT directo.
- `03_lote_con_procedimientos.sql`: lote de 6 clientes cargados con `sp_InsertarCliente`,
  modificaciones con `sp_ModificarCliente`, bajas con `sp_EliminarCliente` y casos de error.

**Resultados:**

| Prueba | Resultado |
|---|---|
| Lote con INSERT directo | 5 clientes insertados (ids 9 a 13) |
| Lote con procedimiento | 6 clientes insertados (ids 14 a 19) |
| Modificar dirección de Joaquín Ortiz | Dirección actualizada a "Bolivar 2050" |
| Modificar email de Martina Herrera | Email actualizado |
| Eliminar a Tomás Medina | Se borran el cliente y su teléfono |
| Eliminar a Lucas Ríos | Cliente borrado |
| Eliminar a Juan Pérez (tiene ventas) | Error 50013, no se borra nada |
| Modificar cliente 999 | Error 50011 |
| Insertar sin nombre | Error 50010 |

Las capturas están en `evidencias/`.

## 4. Funciones almacenadas

En el proyecto se implementaron tres funciones almacenadas en SQL Server para calcular información y consultar datos relacionados con las ventas y los clientes.

| **Función** | **Tipo** | **Descripción** |
|---|---|---|
| `dbo.fn_TotalVenta` | Escalar | Calcula el total de una venta multiplicando la cantidad de cada producto por su precio histórico y sumando los resultados. |
| `dbo.fn_CalcularDescuentoCliente` | Escalar | Devuelve el porcentaje de descuento correspondiente a un cliente según el monto acumulado de sus ventas. |
| `dbo.fn_VentasDeCliente` | Con valores de tabla | Devuelve las ventas de un cliente, incluyendo el identificador, la fecha, el método de pago y el total. |

### 4.1. Resultado de la función `dbo.fn_TotalVenta`

La función calcula el importe total de una venta a partir de sus detalles. En la prueba realizada con la venta identificada con el número 1, se obtuvo el siguiente resultado:

| **Campo** | **Resultado** |
|---|---:|
| `TotalVenta` | 4600 |

Este resultado indica que el total calculado para la venta 1 fue de **4600**.

**Evidencia:** `totalVenta.png`.

### 4.2. Resultado de la función `dbo.fn_CalcularDescuentoCliente`

La prueba de la función de descuento devolvió el siguiente valor:

| **Campo** | **Resultado** |
|---|---:|
| `Descuento` | 0.10 |
| Descuento expresado en porcentaje | 10 % |

El resultado `0.10` representa un descuento del **10 %** para el cliente consultado, de acuerdo con las reglas definidas en la función.

**Evidencia:** `descuentoCliente.png`.

### 4.3. Resultado de la función `dbo.fn_VentasDeCliente`

La consulta de las ventas del cliente devolvió los siguientes registros:

| **ID de venta** | **Fecha de venta** | **Método de pago** | **Total de venta** |
|---:|---|---|---:|
| 1 | 2026-09-01 | Efectivo | 4600 |
| 9 | 2026-09-09 | Transferencia | 7300 |
| 11 | 2026-10-27 | Efectivo | 2800 |
| 12 | 2026-10-27 | Efectivo | 2800 |

La función permite consultar las ventas asociadas al cliente y visualizar sus fechas, métodos de pago e importes totales.

**Evidencia:** `ventasCliente.png`.

## 5. Comparación de eficiencia

Para comparar las alternativas de implementación se ejecutó el script `04_comparacion_eficiencia.sql`, que mide el tiempo de ejecución de 1000 repeticiones de cada operación.

Los resultados obtenidos fueron los siguientes:

| **Operación** | **Repeticiones** | **Tiempo (ms)** |
|---|---:|---:|
| A. INSERT directo en `Cliente` | 1000 | 20 |
| B. `EXEC dbo.sp_InsertarCliente` | 1000 | 39 |
| C. Consulta directa del total | 1000 | 11 |
| D. `dbo.fn_TotalVenta` | 1000 | 23 |

### 5.1. Análisis de los resultados

En la prueba de inserción, el `INSERT` directo tardó **20 ms**, mientras que las llamadas al procedimiento `sp_InsertarCliente` tardaron **39 ms**. En esta ejecución, el procedimiento necesitó 19 ms adicionales para completar las 1000 operaciones.

En la prueba de cálculo del total, la consulta directa tardó **11 ms**, mientras que el uso de `dbo.fn_TotalVenta` tardó **23 ms**. La diferencia fue de 12 ms para las 1000 repeticiones.

En estas mediciones, las operaciones directas presentaron un menor tiempo de ejecución. Sin embargo, esto no significa que los procedimientos y las funciones sean innecesarios: permiten centralizar la lógica, reutilizar código y mantener las reglas de negocio en un único lugar. Además, los resultados corresponden a una ejecución específica y pueden variar según las condiciones de prueba.

### 5.2. Verificación de los datos utilizados

| **Dato** | **Resultado** |
|---|---|
| Venta utilizada | 1 |
| Último total calculado | 4600 |
| Observación | Las inserciones de prueba fueron revertidas. |

Las inserciones se ejecutaron dentro de una transacción que luego se revirtió, por lo que los registros de prueba no quedaron guardados en la tabla. Esto permite realizar la comparación sin conservar esos registros de prueba.

**Evidencia:** `ComparacionOptimizaciones.png`.

## 6. Conclusión

Las pruebas permitieron comprobar el funcionamiento de las tres funciones almacenadas y comparar los tiempos de ejecución de las operaciones directas con los de los procedimientos y las funciones.

La función `dbo.fn_TotalVenta` calculó un total de 4600 para la venta 1; `dbo.fn_CalcularDescuentoCliente` devolvió un descuento de 0.10, equivalente al 10 %; y `dbo.fn_VentasDeCliente` mostró cuatro ventas con sus respectivas fechas, métodos de pago e importes.

En la comparación de eficiencia, las operaciones directas registraron menores tiempos en la ejecución realizada. Aun así, los procedimientos y las funciones ofrecen ventajas de organización, reutilización y centralización de las reglas de negocio. Por lo tanto, la elección de cada alternativa debe considerar tanto el rendimiento medido como las necesidades de mantenimiento y funcionamiento del sistema.

