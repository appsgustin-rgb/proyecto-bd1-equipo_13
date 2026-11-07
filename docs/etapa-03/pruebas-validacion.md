# Pruebas y validación

## 1. Introducción

Para comprobar que la implementación funciona correctamente se realizaron tres tipos de pruebas:

1. **Carga de datos:** verificar que cada tabla tenga la cantidad de registros esperada.
2. **Coherencia de los datos:** verificar que los datos de prueba respeten las reglas de negocio.
3. **Restricciones de integridad:** intentar guardar datos inválidos y comprobar que el motor los rechace.

Las pruebas se ejecutan después de `sql/ddl/TABLAS.sql` y `sql/dml/INSERT.sql`, sobre la base `base_distribuidora`.

## 2. Prueba de carga de datos

```sql
SELECT 'Cliente' AS tabla, COUNT(*) AS registros FROM Cliente
UNION ALL SELECT 'Telefono_Cliente', COUNT(*) FROM Telefono_Cliente
UNION ALL SELECT 'Categoria', COUNT(*) FROM Categoria
UNION ALL SELECT 'Producto', COUNT(*) FROM Producto
UNION ALL SELECT 'Metodo_Pago', COUNT(*) FROM Metodo_Pago
UNION ALL SELECT 'Repartidor', COUNT(*) FROM Repartidor
UNION ALL SELECT 'Venta', COUNT(*) FROM Venta
UNION ALL SELECT 'Detalle_Venta', COUNT(*) FROM Detalle_Venta
UNION ALL SELECT 'Entrega', COUNT(*) FROM Entrega;
```

| Tabla | Registros esperados |
|---|---|
| `Cliente` | 8 |
| `Telefono_Cliente` | 9 |
| `Categoria` | 8 |
| `Producto` | 10 |
| `Metodo_Pago` | 8 |
| `Repartidor` | 8 |
| `Venta` | 10 |
| `Detalle_Venta` | 19 |
| `Entrega` | 10 |

## 3. Pruebas de coherencia

Cada consulta busca datos que no respeten una regla de negocio. El resultado esperado en todas es **cero filas**.

```sql
-- Ventas sin renglones de detalle (RN05)
SELECT v.id_venta
FROM Venta v
WHERE NOT EXISTS (SELECT 1 FROM Detalle_Venta dv WHERE dv.id_venta = v.id_venta);

-- Renglones cuyo precio historico no coincide con el precio del producto
-- al momento de la carga (RN06)
SELECT dv.id_venta, dv.nro_linea, dv.precio_historico, p.precio_actual
FROM Detalle_Venta dv
INNER JOIN Producto p ON p.id_producto = dv.id_producto
WHERE dv.precio_historico <> p.precio_actual;

-- Ventas sin entrega registrada (RN09)
SELECT v.id_venta
FROM Venta v
WHERE NOT EXISTS (SELECT 1 FROM Entrega e WHERE e.id_venta = v.id_venta);
```

La segunda consulta solo devuelve cero filas con los datos recién cargados. Si después se modifica el precio actual de un producto, es correcto que aparezcan diferencias: justamente eso es lo que permite el precio histórico.

## 4. Pruebas de restricciones

Cada prueba intenta realizar una operación inválida. El resultado esperado es un **error** del motor que indica la restricción violada. Como la operación se rechaza, los datos no se modifican.

Las pruebas utilizan `UPDATE` y `DELETE` sobre registros existentes o `INSERT` en tablas sin `IDENTITY`. De esta forma no se consumen valores de las columnas `IDENTITY`, que en SQL Server se pierden aunque el `INSERT` falle.

```sql
-- PRUEBA 1: clave primaria duplicada (telefono ya cargado para el cliente 1)
INSERT INTO Telefono_Cliente (telefono, id_cliente) VALUES ('3794123456', 1);
GO

-- PRUEBA 2: clave primaria compuesta duplicada (renglon 1 de la venta 1)
INSERT INTO Detalle_Venta (id_venta, nro_linea, cantidad, precio_historico, id_producto)
VALUES (1, 1, 1, 800.00, 1);
GO

-- PRUEBA 3: clave foranea hacia un cliente inexistente
INSERT INTO Telefono_Cliente (telefono, id_cliente) VALUES ('3794000000', 999);
GO

-- PRUEBA 4: ON DELETE NO ACTION, cliente con ventas
DELETE FROM Cliente WHERE id_cliente = 1;
GO

-- PRUEBA 5: ON DELETE NO ACTION, producto ya vendido
DELETE FROM Producto WHERE id_producto = 1;
GO

-- PRUEBA 6: ON DELETE NO ACTION, venta con entrega registrada
DELETE FROM Venta WHERE id_venta = 1;
GO

-- PRUEBA 7: CHECK de stock negativo
UPDATE Producto SET stock = -5 WHERE id_producto = 1;
GO

-- PRUEBA 8: CHECK de precio igual a cero
UPDATE Producto SET precio_actual = 0 WHERE id_producto = 1;
GO

-- PRUEBA 9: CHECK de cantidad igual a cero
UPDATE Detalle_Venta SET cantidad = 0 WHERE id_venta = 1 AND nro_linea = 1;
GO

-- PRUEBA 10: CHECK de estado de entrega no permitido
UPDATE Entrega SET estado_entrega = 'Perdida' WHERE id_entrega = 1;
GO

-- PRUEBA 11: UNIQUE de categoria repetida
UPDATE Categoria SET nombre_categoria = 'agua mineral' WHERE id_categoria = 2;
GO

-- PRUEBA 12: UNIQUE de metodo de pago repetido
UPDATE Metodo_Pago SET descripcion = 'Efectivo' WHERE id_metodo_pago = 2;
GO

-- PRUEBA 13: NOT NULL en el nombre del cliente
UPDATE Cliente SET nombre = NULL WHERE id_cliente = 1;
GO
```

| # | Restricción probada | Resultado esperado |
|---|---|---|
| 1 | `PK_Telefono_Cliente` | Error 2627: clave primaria duplicada. |
| 2 | `PK_Detalle_Venta` | Error 2627: clave primaria duplicada. |
| 3 | `FK_Telefono_Cliente` | Error 547: conflicto con la restricción FOREIGN KEY. |
| 4 | `FK_Venta_Cliente` | Error 547: conflicto con la restricción REFERENCE. |
| 5 | `FK_Detalle_Producto` | Error 547: conflicto con la restricción REFERENCE. |
| 6 | `FK_Entrega_Venta` | Error 547: la venta tiene una entrega y no se puede eliminar. |
| 7 | `CK_Producto_stock` | Error 547: conflicto con la restricción CHECK. |
| 8 | `CK_Producto_precio` | Error 547: conflicto con la restricción CHECK. |
| 9 | `CK_Detalle_cantidad` | Error 547: conflicto con la restricción CHECK. |
| 10 | `CK_Entrega_estado` | Error 547: conflicto con la restricción CHECK. |
| 11 | `UQ_Categoria_nombre` | Error 2627: valor duplicado en restricción UNIQUE. |
| 12 | `UQ_Metodo_Pago_descripcion` | Error 2627: valor duplicado en restricción UNIQUE. |
| 13 | `Cliente.nombre NOT NULL` | Error 515: no se puede insertar el valor NULL. |

La prueba 6 muestra que, aunque el detalle de venta se borra en cascada, la regla `NO ACTION` de `Entrega` impide eliminar una venta que ya tiene una entrega registrada.

## 5. Prueba de borrado en cascada

Esta prueba se realiza dentro de una transacción que se deshace al final, para no modificar los datos de prueba.

```sql
BEGIN TRANSACTION;

    -- Venta nueva sin entrega, con dos renglones
    INSERT INTO Venta (fecha_venta, id_cliente, id_metodo_pago)
    VALUES ('2026-09-15', 2, 1);

    DECLARE @id_venta INT = SCOPE_IDENTITY();

    INSERT INTO Detalle_Venta (id_venta, nro_linea, cantidad, precio_historico, id_producto)
    VALUES (@id_venta, 1, 2, 800.00, 1),
           (@id_venta, 2, 1, 4500.00, 7);

    SELECT COUNT(*) AS renglones_antes FROM Detalle_Venta WHERE id_venta = @id_venta;

    -- Al borrar la venta se borran sus renglones (ON DELETE CASCADE)
    DELETE FROM Venta WHERE id_venta = @id_venta;

    SELECT COUNT(*) AS renglones_despues FROM Detalle_Venta WHERE id_venta = @id_venta;

ROLLBACK TRANSACTION;
```

**Resultado esperado:** `renglones_antes` = 2 y `renglones_despues` = 0. La venta se elimina sin error porque no tiene entrega, y sus renglones se borran automáticamente.

## 6. Conclusión

Las pruebas confirmaron que:

- Todas las tablas tienen entre 8 y 19 registros de prueba, cargados de forma coherente con las reglas de negocio.
- Las claves primarias impiden registros duplicados.
- Las claves foráneas impiden datos relacionados con registros inexistentes y protegen el historial de ventas.
- Las restricciones `CHECK`, `UNIQUE` y `NOT NULL` rechazan valores inválidos.
- El borrado en cascada elimina los datos dependientes solo en los casos definidos.

## 7. Archivos relacionados

- `sql/ddl/TABLAS.sql`
- `sql/dml/INSERT.sql`
- `docs/etapa-03/restricciones-integridad.md`
