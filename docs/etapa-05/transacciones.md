# Manejo de transacciones

## 1. Concepto

Una **transacción** es una unidad lógica de trabajo que agrupa una o más instrucciones (`INSERT`, `UPDATE`, `DELETE`) para que se ejecuten como un solo bloque, bajo el principio de **"todo o nada"**: los cambios se guardan solo si todas las instrucciones terminan correctamente; si alguna falla, se deshacen todas.

En SQL Server se controlan con:

| Instrucción | Función |
|---|---|
| `BEGIN TRANSACTION` | Inicia la transacción. |
| `COMMIT TRANSACTION` | Confirma los cambios y los vuelve permanentes. |
| `ROLLBACK TRANSACTION` | Deshace todos los cambios realizados desde el `BEGIN TRANSACTION`. |
| `BEGIN TRY ... END TRY` / `BEGIN CATCH ... END CATCH` | Capturan el error para decidir el `ROLLBACK` y mostrar un mensaje. |
| `SET XACT_ABORT ON` | Ante un error del motor (por ejemplo, la violación de una restricción), marca la transacción para que se deshaga completa. |
| `@@TRANCOUNT` | Indica si hay una transacción abierta, para no ejecutar un `ROLLBACK` sin transacción. |

## 2. Propiedades ACID

1. **Atomicidad:** la transacción se ejecuta completa o no se ejecuta. Si falla una instrucción, se deshacen también las anteriores.
2. **Consistencia:** la base pasa de un estado válido a otro estado válido, respetando claves, restricciones y reglas de negocio (por ejemplo, el stock nunca queda negativo).
3. **Aislamiento (Isolation):** las transacciones que se ejecutan al mismo tiempo no ven los cambios no confirmados de las otras; cada una opera como si fuera la única en el sistema.
4. **Durabilidad:** una vez confirmados con `COMMIT`, los cambios permanecen aunque luego se produzca una falla del sistema.

## 3. Transacciones implementadas

Se desarrollaron dos transacciones, cada una con una versión correcta y una versión con un error provocado. Todas siguen la misma estructura:

```sql
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;
        -- 1. INSERT en una tabla
        -- 2. INSERT en otra tabla
        -- 3. UPDATE en otra tabla
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    PRINT 'Detalle del error: ' + ERROR_MESSAGE();
END CATCH;
```

### 3.1 Transacción 1: registro de una venta (`transaccion_venta.sql`)

Registra una venta completa de 13 unidades del producto 5 (Soda 1.5L) a la clienta Valentina Ruiz:

| Paso | Operación | Tabla | Regla de negocio |
|---|---|---|---|
| 0 | Validar que el producto exista y tenga stock suficiente. Si no, se lanza el error 50020 o 50021. | `Producto` | RN07 |
| 1 | `INSERT` de la cabecera de la venta. | `Venta` | RN04 |
| 2 | `INSERT` del renglón, guardando el precio actual del producto como precio histórico. | `Detalle_Venta` | RN05, RN06 |
| 3 | `UPDATE` que descuenta la cantidad vendida del stock. | `Producto` | RN07 |

La lectura del stock se hace con `WITH (UPDLOCK, HOLDLOCK)` para que otra sesión no pueda modificarlo entre la validación y el descuento (aislamiento).

**Resultado esperado:** el stock del producto 5 pasa de 90 a 77 y se registra una venta nueva con un renglón de 13 unidades a 1100.

### 3.2 Transacción 1 con error (`transaccion_venta_ERROR.sql`)

| Caso | Error provocado | Momento | Resultado esperado |
|---|---|---|---|
| A | El renglón se inserta con `cantidad = 0`, lo que viola `CK_Detalle_cantidad` (error 547). | Después del `INSERT` en `Venta` y antes del `UPDATE` en `Producto`. | La venta ya insertada se deshace: la cantidad de ventas y el stock quedan iguales que antes. |
| B | Se intenta vender 150 unidades con menos stock disponible (error 50021). | En la validación previa. | No se inserta la venta ni se modifica el stock. |

Al final de cada caso, una consulta muestra la cantidad de ventas y el stock **antes** y **después**, que deben coincidir.

### 3.3 Transacción 2: alta y modificación de clientes (`transaccion_cliente.sql`)

Usa los procedimientos almacenados del tema 1 dentro de una transacción:

| Paso | Operación | Tabla |
|---|---|---|
| 1 | `EXEC sp_InsertarCliente` da de alta a Héctor Romero y devuelve su id por `OUTPUT`. | `Cliente` |
| 2 | `INSERT` del teléfono del cliente nuevo. | `Telefono_Cliente` |
| 3 | `EXEC sp_ModificarCliente` cambia el domicilio de Florencia Vega. | `Cliente` |

**Resultado esperado:** Héctor Romero queda registrado con su teléfono y Florencia Vega con la dirección `Mendoza 1200`.

### 3.4 Transacción 2 con error (`transaccion_cliente_ERROR.sql`)

Se da de alta a Rocío Acosta con su teléfono y luego se intenta modificar el cliente `-123`, que no existe. El procedimiento `sp_ModificarCliente` lanza el error **50011** después de los dos `INSERT`.

**Resultado esperado:** el `ROLLBACK` deshace el alta y el teléfono. La consulta final muestra la misma cantidad de clientes y teléfonos que antes y `existe_rocio = 0`.

## 4. Orden de ejecución

Las transacciones usan los procedimientos de `01_procedimientos_crud.sql` y los clientes cargados por `02_lote_insert_directo.sql`, por lo que se ejecutan después de esos scripts (paso 8 del `README.md`):

1. `transaccion_venta.sql`
2. `transaccion_venta_ERROR.sql`
3. `transaccion_cliente.sql`
4. `transaccion_cliente_ERROR.sql`

Los valores `IDENTITY` consumidos por las inserciones que se deshacen no se recuperan, por lo que pueden quedar "saltos" en la numeración de ventas y clientes. Esto es un comportamiento normal de SQL Server y no afecta la integridad.

## 5. Conclusiones

- La **atomicidad** fue la propiedad más visible en las pruebas: en todos los casos con error, las inserciones realizadas antes de la falla se deshicieron y la base quedó igual que antes de comenzar.
- Combinar `TRY/CATCH` con `SET XACT_ABORT ON` asegura que se deshaga la transacción tanto ante errores del motor (restricciones `CHECK`, claves foráneas) como ante errores de negocio lanzados con `THROW` (stock insuficiente, cliente inexistente).
- Validar el stock **antes** de modificar los datos y con un bloqueo de actualización evita vender más de lo disponible aun con varios usuarios trabajando a la vez.
- Las restricciones de la etapa III (`CK_Detalle_cantidad`, `CK_Producto_stock`) y las transacciones se complementan: las restricciones detectan el dato inválido y la transacción garantiza que no queden operaciones a medias.
- Registrar una venta y su detalle dentro de una misma transacción es también la forma de asegurar la regla RN05 (toda venta tiene al menos un renglón), que no puede expresarse con una restricción de tabla.

## 6. Archivos relacionados

- `sql/tecnico/transacciones/transaccion_venta.sql`
- `sql/tecnico/transacciones/transaccion_venta_ERROR.sql`
- `sql/tecnico/transacciones/transaccion_cliente.sql`
- `sql/tecnico/transacciones/transaccion_cliente_ERROR.sql`
