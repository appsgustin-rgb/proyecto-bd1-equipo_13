# Restricciones de integridad

## 1. Introducción

Las restricciones de integridad son reglas definidas en la base de datos que impiden guardar información inválida o inconsistente. Al estar definidas en el motor, se aplican siempre, sin importar desde dónde se intente modificar los datos.

En el script `sql/ddl/TABLAS.sql` todas las restricciones tienen un nombre propio (por ejemplo `FK_Venta_Cliente` o `CK_Producto_stock`). De esta forma, cuando una operación falla, el mensaje de error indica exactamente qué restricción no se cumplió.

## 2. Integridad de entidad: claves primarias

Cada tabla tiene una clave primaria que identifica a cada fila de forma única y no admite valores nulos.

| Tabla | Restricción | Columnas |
|---|---|---|
| `Cliente` | `PK_Cliente` | `id_cliente` |
| `Metodo_Pago` | `PK_Metodo_Pago` | `id_metodo_pago` |
| `Categoria` | `PK_Categoria` | `id_categoria` |
| `Repartidor` | `PK_Repartidor` | `id_repartidor` |
| `Venta` | `PK_Venta` | `id_venta` |
| `Producto` | `PK_Producto` | `id_producto` |
| `Detalle_Venta` | `PK_Detalle_Venta` | `nro_linea`, `id_venta` |
| `Entrega` | `PK_Entrega` | `id_entrega` |
| `Telefono_Cliente` | `PK_Telefono_Cliente` | `telefono`, `id_cliente` |

## 3. Integridad referencial: claves foráneas

Las claves foráneas garantizan que no exista información relacionada con registros inexistentes (RN11). Para cada una se definió qué ocurre al intentar borrar o modificar el registro referenciado.

| Restricción | Relación | ON DELETE | ON UPDATE |
|---|---|---|---|
| `FK_Venta_Cliente` | `Venta.id_cliente` → `Cliente` | NO ACTION | NO ACTION |
| `FK_Venta_Metodo_Pago` | `Venta.id_metodo_pago` → `Metodo_Pago` | NO ACTION | NO ACTION |
| `FK_Producto_Categoria` | `Producto.id_categoria` → `Categoria` | NO ACTION | NO ACTION |
| `FK_Detalle_Producto` | `Detalle_Venta.id_producto` → `Producto` | NO ACTION | NO ACTION |
| `FK_Detalle_Venta` | `Detalle_Venta.id_venta` → `Venta` | CASCADE | NO ACTION |
| `FK_Entrega_Repartidor` | `Entrega.id_repartidor` → `Repartidor` | NO ACTION | NO ACTION |
| `FK_Entrega_Venta` | `Entrega.id_venta` → `Venta` | NO ACTION | NO ACTION |
| `FK_Telefono_Cliente` | `Telefono_Cliente.id_cliente` → `Cliente` | CASCADE | NO ACTION |

### Reglas de borrado

- **NO ACTION:** impide borrar un registro que tenga datos relacionados. Se utiliza para conservar el historial del negocio: no se puede eliminar un cliente con ventas, un producto que ya se vendió, una categoría con productos, un método de pago utilizado, un repartidor con entregas ni una venta que tenga una entrega registrada.
- **CASCADE:** al borrar el registro principal se borran automáticamente sus datos dependientes. Se utiliza en dos casos donde los datos dependientes no tienen sentido por sí solos:
  - **Teléfonos de un cliente:** si se elimina un cliente sin ventas, sus teléfonos se eliminan con él.
  - **Detalle de una venta:** los renglones forman parte de la venta. Si se elimina una venta que no tiene entrega registrada, se eliminan también sus renglones.

### Reglas de modificación

Todas las claves foráneas utilizan **ON UPDATE NO ACTION**. Las claves primarias referenciadas son de tipo `IDENTITY`, generadas por el motor, y no se modifican, por lo que no es necesario propagar cambios a las tablas relacionadas.

## 4. Integridad de dominio

### 4.1 Restricciones CHECK

| Restricción | Tabla | Condición | Regla de negocio |
|---|---|---|---|
| `CK_Producto_precio` | `Producto` | `precio_actual > 0` | Un producto no puede tener precio nulo o negativo. |
| `CK_Producto_stock` | `Producto` | `stock >= 0` | El stock no puede ser negativo (RN07). |
| `CK_Detalle_nro_linea` | `Detalle_Venta` | `nro_linea > 0` | Los renglones se numeran desde 1. |
| `CK_Detalle_cantidad` | `Detalle_Venta` | `cantidad > 0` | Cada renglón debe vender al menos una unidad (RN05). |
| `CK_Detalle_precio` | `Detalle_Venta` | `precio_historico > 0` | El precio registrado en la venta debe ser válido (RN06). |
| `CK_Entrega_estado` | `Entrega` | `estado_entrega IN ('Pendiente', 'En camino', 'Entregada')` | Una entrega solo puede tener uno de los estados definidos (RN09). |

### 4.2 Restricciones UNIQUE

| Restricción | Tabla | Columna | Justificación |
|---|---|---|---|
| `UQ_Categoria_nombre` | `Categoria` | `nombre_categoria` | Evita cargar dos veces la misma categoría. |
| `UQ_Metodo_Pago_descripcion` | `Metodo_Pago` | `descripcion` | Evita cargar dos veces el mismo método de pago. |

El email de los clientes no se definió como `UNIQUE` porque es un dato opcional y SQL Server solo admite un valor `NULL` en una columna con restricción `UNIQUE`.

### 4.3 NOT NULL

Todas las columnas son obligatorias (`NOT NULL`), salvo `Cliente.email`, que es opcional porque no todos los clientes tienen correo electrónico.

## 5. Relación con las reglas de negocio

| Regla | Cómo se implementa |
|---|---|
| RN01 – Registro de clientes | `PK_Cliente` con `IDENTITY`. |
| RN02 – Registro de productos | `PK_Producto`, columnas `NOT NULL` y `CK_Producto_precio`. |
| RN03 – Categorías | `FK_Producto_Categoria` e `id_categoria NOT NULL`. |
| RN04 – Registro de ventas | `FK_Venta_Cliente` y `fecha_venta NOT NULL`. |
| RN05 – Detalle de venta | `PK_Detalle_Venta`, `FK_Detalle_Venta`, `FK_Detalle_Producto` y `CK_Detalle_cantidad`. |
| RN06 – Precio histórico | Columna `precio_historico` en `Detalle_Venta`, independiente de `Producto.precio_actual`. |
| RN07 – Control de stock | `CK_Producto_stock`. La validación de que la cantidad vendida no supere el stock se realiza además en la transacción de registro de venta (etapa 5). |
| RN08 – Métodos de pago | `FK_Venta_Metodo_Pago` y `UQ_Metodo_Pago_descripcion`. |
| RN09 – Entregas | `FK_Entrega_Venta`, `FK_Entrega_Repartidor` y `CK_Entrega_estado`. |
| RN10 – Repartidores | `FK_Entrega_Repartidor`. |
| RN11 – Integridad de datos | Todas las claves foráneas con `ON DELETE NO ACTION`. |

La condición de que toda venta tenga al menos un renglón (RN05) no puede expresarse con una restricción de tabla, ya que la venta se inserta antes que sus renglones. Se controla registrando la venta y su detalle dentro de una misma transacción.

## 6. Archivo relacionado

- `sql/ddl/TABLAS.sql`
