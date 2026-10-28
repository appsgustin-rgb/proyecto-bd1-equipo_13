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
