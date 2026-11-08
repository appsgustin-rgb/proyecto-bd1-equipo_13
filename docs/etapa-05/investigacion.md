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

Las capturas están en `evidencias/` (`error_50010.png`, `error_50011.png`, `error_50013.png` y `errores.png`).

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

Este resultado indica que el total calculado para la venta 1 fue de **4600** (3 × 800 + 2 × 1100). Para una venta inexistente la función devuelve **0**.

**Evidencia:** `evidencias/evidencia-funciones/totalVentas.png`.

### 4.2. Resultado de la función `dbo.fn_CalcularDescuentoCliente`

La función aplica las siguientes reglas sobre el total acumulado de compras del cliente: 10 % desde 15000, 5 % desde 10000 y 0 % por debajo de 10000.

Resultado de la PRUEBA 2 de `01_funciones.sql` con los datos de `INSERT.sql`:

| **Cliente** | **Ventas** | **Total acumulado** | **Descuento** |
|---|---|---:|---:|
| Camila Lopez | 8 | 16800 | 0.10 |
| Carlos Rodriguez | 3 y 10 | 16300 | 0.10 |
| Sofia Martinez | 6 | 12300 | 0.05 |
| Juan Perez | 1 y 9 | 11900 | 0.05 |
| Lucia Fernandez | 4 | 10500 | 0.05 |
| Maria Gomez | 2 | 6900 | 0.00 |
| Matias Benitez | 5 | 6800 | 0.00 |
| Diego Gonzalez | 7 | 4200 | 0.00 |

Los clientes sin compras (por ejemplo, los cargados en los lotes del punto 3) obtienen 0.00.

**Evidencia:** `evidencias/evidencia-funciones/descuentoCliente.png`. La captura se tomó sobre una base en la que el cliente 1 tenía, además, dos ventas de prueba de 2800 cada una (ventas 11 y 12), por lo que su total acumulado era 17500 y la función devolvió **0.10**, de acuerdo con la regla del 10 %.

### 4.3. Resultado de la función `dbo.fn_VentasDeCliente`

La consulta de las ventas del cliente 1 con los datos de `INSERT.sql` devuelve:

| **ID de venta** | **Fecha de venta** | **Método de pago** | **Total de venta** |
|---:|---|---|---:|
| 1 | 2026-09-01 | Efectivo | 4600 |
| 9 | 2026-09-09 | Transferencia | 7300 |

La función permite consultar las ventas asociadas al cliente y visualizar sus fechas, métodos de pago e importes totales. Para un cliente inexistente devuelve cero filas.

**Evidencia:** `evidencias/evidencia-funciones/ventaCliente.png`. La captura incluye además las ventas de prueba 11 y 12 mencionadas en el punto 4.2.

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

**Evidencia:** `evidencias/evidencia-funciones/ComparacionOptimizacion.png`.


