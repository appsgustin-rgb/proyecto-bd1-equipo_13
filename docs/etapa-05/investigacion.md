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

En el proyecto se implementaron tres funciones almacenadas en SQL Server para realizar cálculos y consultar información relacionada con las ventas y los clientes.

| **Función** | **Tipo** | **Descripción** |
|---|---|---|
| `dbo.fn_TotalVenta` | Escalar | Calcula el total de una venta sumando la cantidad de cada producto multiplicada por su precio histórico. Si la venta no tiene detalles, devuelve 0. |
| `dbo.fn_CalcularDescuentoCliente` | Escalar | Calcula el porcentaje de descuento correspondiente a un cliente según el monto acumulado de sus ventas. |
| `dbo.fn_VentasDeCliente` | Con valores de tabla | Devuelve información de las ventas de un cliente, incluyendo el identificador, la fecha, el método de pago y el total. |

### 4.1. Cálculo del total de una venta

La función `dbo.fn_TotalVenta(@id_venta INT)` recibe el identificador de una venta y calcula su importe total a partir de los detalles registrados en `Detalle_Venta`.

Para cada detalle, multiplica la cantidad vendida por el precio histórico del producto y suma los resultados. Esto permite consultar el total sin repetir la fórmula en cada consulta.

### 4.2. Cálculo del descuento de un cliente

La función `dbo.fn_CalcularDescuentoCliente(@id_cliente INT)` determina el porcentaje de descuento de acuerdo con el monto acumulado de las ventas del cliente.

Las reglas implementadas son:

- Si las ventas acumuladas son iguales o superiores a 15.000, devuelve un descuento del 10 %.
- Si las ventas acumuladas son iguales o superiores a 10.000, devuelve un descuento del 5 %.
- Si no alcanza esos importes, devuelve 0 %.

La función devuelve el porcentaje calculado, pero no aplica ni guarda el descuento automáticamente en una venta.

### 4.3. Consulta de ventas por cliente

La función `dbo.fn_VentasDeCliente(@id_cliente INT)` devuelve una tabla con las ventas asociadas a un cliente. Incluye el identificador de la venta, la fecha, el método de pago y el importe total.

Al devolver una tabla, permite utilizarse dentro de consultas SQL para consultar o filtrar las ventas de un cliente.

**Script:** `sql/tecnico/funciones/01_funciones.sql`.

## 5. Comparación de eficiencia

Para analizar las diferencias entre las operaciones directas y el uso de procedimientos y funciones almacenadas, el proyecto incluye el script `04_comparacion_eficiencia.sql`.

La comparación contempla dos pruebas:

1. **Inserciones de clientes:** compara la inserción directa mediante instrucciones `INSERT` con la inserción mediante llamadas al procedimiento `sp_InsertarCliente`.
2. **Cálculo de totales:** compara las consultas que calculan directamente el total de una venta con las consultas que utilizan `dbo.fn_TotalVenta`.

El script mide el tiempo de ejecución de cada alternativa en milisegundos y permite observar las diferencias obtenidas en las pruebas.

Las inserciones de prueba se realizan dentro de una transacción que luego se revierte, por lo que los registros de prueba no quedan guardados. Sin embargo, los valores de identidad pueden avanzar.

**Importante:** los tiempos deben completarse con los resultados obtenidos al ejecutar el script. No se debe afirmar que una alternativa es más rápida sin comprobar las mediciones. El resultado puede variar según el equipo, los datos y las condiciones de ejecución.

**Script:** `sql/tecnico/procedimientos_funciones/04_comparacion_eficiencia.sql`.


Las evidencias de las pruebas se encuentran en la carpeta `evidencias/evidencia-funciones` del proyecto.

