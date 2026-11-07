# Implementación física

## 1. Introducción

En esta etapa se implementó en SQL Server el modelo relacional definido en la etapa 2. La implementación se divide en dos scripts:

- **Script DDL** (`sql/ddl/TABLAS.sql`): crea la base de datos `base_distribuidora`, sus tablas, las claves primarias y foráneas y las restricciones de integridad.
- **Script DML** (`sql/dml/INSERT.sql`): carga los datos de prueba con los que se validan las restricciones y se ejecutan las consultas de las etapas siguientes.

## 2. Orden de ejecución

1. `sql/ddl/TABLAS.sql`
2. `sql/dml/INSERT.sql`

El script DDL verifica si la base `base_distribuidora` existe y la crea solo si no existe. Las tablas se crean en orden de dependencia: primero las que no tienen claves foráneas (`Cliente`, `Metodo_Pago`, `Categoria` y `Repartidor`) y después las que las referencian (`Venta`, `Producto`, `Detalle_Venta`, `Entrega` y `Telefono_Cliente`).

El script DML respeta el mismo orden, ya que no es posible insertar una fila que haga referencia a un registro que todavía no existe.

## 3. Tablas implementadas

| Tabla | Clave primaria | Claves foráneas | Descripción |
|---|---|---|---|
| `Cliente` | `id_cliente` | — | Datos de los clientes. |
| `Telefono_Cliente` | `(telefono, id_cliente)` | `id_cliente` → `Cliente` | Teléfonos de cada cliente. Un cliente puede tener varios. |
| `Categoria` | `id_categoria` | — | Categorías de producto. |
| `Producto` | `id_producto` | `id_categoria` → `Categoria` | Productos con su precio actual y stock. |
| `Metodo_Pago` | `id_metodo_pago` | — | Métodos de pago aceptados. |
| `Venta` | `id_venta` | `id_cliente` → `Cliente`, `id_metodo_pago` → `Metodo_Pago` | Encabezado de cada venta. |
| `Detalle_Venta` | `(nro_linea, id_venta)` | `id_venta` → `Venta`, `id_producto` → `Producto` | Renglones de cada venta. |
| `Repartidor` | `id_repartidor` | — | Repartidores de la distribuidora. |
| `Entrega` | `id_entrega` | `id_venta` → `Venta`, `id_repartidor` → `Repartidor` | Entregas asociadas a cada venta. |

## 4. Tipos de datos

| Tipo | Columnas | Justificación |
|---|---|---|
| `INT IDENTITY(1,1)` | Claves primarias simples (`id_cliente`, `id_venta`, etc.) | Identificadores numéricos generados automáticamente por el motor, sin intervención del usuario. |
| `INT` | `stock`, `cantidad`, `nro_linea` y claves foráneas | Valores enteros: unidades de producto, número de renglón y referencias a otras tablas. |
| `VARCHAR(n)` | Nombres, direcciones, email, teléfonos, descripciones y estado | Textos de longitud variable. Se definió un largo máximo acorde a cada dato: 35 para nombres, 50 para direcciones, email y nombre de producto, 20 para teléfonos y estado. |
| `DECIMAL(10,2)` | `precio_actual`, `precio_historico` | Importes en pesos con dos decimales. Se utiliza `DECIMAL` porque guarda los valores de forma exacta; los tipos de punto flotante (`FLOAT`) pueden generar errores de redondeo en cálculos de dinero. |
| `DATE` | `fecha_venta`, `fecha_entrega` | Solo se necesita la fecha; la hora no forma parte de las reglas del negocio. |

Los teléfonos se guardan como `VARCHAR` y no como número, porque no se realizan cálculos con ellos y pueden contener ceros iniciales o guiones.

## 5. Claves primarias compuestas

- **`Detalle_Venta (nro_linea, id_venta)`:** el número de renglón se repite entre distintas ventas (todas tienen un renglón 1), por lo que solo identifica una fila junto con el número de venta.
- **`Telefono_Cliente (telefono, id_cliente)`:** un cliente puede tener varios teléfonos, y la combinación de ambos valores identifica cada registro.

## 6. Datos de prueba

El script `INSERT.sql` carga los siguientes registros:

| Tabla | Registros | Contenido |
|---|---|---|
| `Cliente` | 8 | Clientes con nombre, apellido, dirección y email. |
| `Telefono_Cliente` | 9 | Un teléfono por cliente; el cliente 1 tiene dos. |
| `Categoria` | 8 | Agua mineral, carbonatada, de mesa, saborizada, alcalina, hielo, dispensers y accesorios. |
| `Producto` | 10 | Botellas de agua y soda de distintos tamaños, bidones de 12 y 20 litros y aguas saborizadas. |
| `Metodo_Pago` | 8 | Efectivo, débito, crédito, transferencia, Mercado Pago, QR, cuenta corriente y cheque. |
| `Repartidor` | 8 | Repartidores con nombre, apellido y teléfono. |
| `Venta` | 10 | Ventas realizadas entre el 01/09/2026 y el 10/09/2026. |
| `Detalle_Venta` | 19 | Entre uno y dos renglones por venta. |
| `Entrega` | 10 | Una entrega por venta: 8 entregadas y 2 pendientes. |

Los datos se cargaron de forma coherente con las reglas de negocio:

- Todas las ventas tienen al menos un renglón de detalle (RN05).
- El precio histórico de cada renglón coincide con el precio actual del producto al momento de la carga (RN06).
- Todas las ventas, entregas y teléfonos hacen referencia a clientes, ventas, métodos de pago y repartidores existentes (RN11).
- Algunas categorías y métodos de pago todavía no tienen productos o ventas asociados, como ocurre en un catálogo real.
- La entrega 1 se realizó en una dirección distinta a la registrada del cliente, lo que permite probar la consulta de seguimiento de entregas de la etapa 4.

## 7. Archivos relacionados

- `sql/ddl/TABLAS.sql`
- `sql/dml/INSERT.sql`
- `docs/etapa-03/restricciones-integridad.md`
- `docs/etapa-03/pruebas-validacion.md`
