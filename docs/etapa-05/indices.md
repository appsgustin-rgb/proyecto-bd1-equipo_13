# Informe: Optimización de consultas mediante índices (SQL Server)

**Base:** `base_consorcio_2025` · **Tabla de pruebas:** `Venta_Historica` (1.000.000 de registros simulados)
**Tema:** Etapa V – Optimización de consultas a través de índices
**Fecha de las mediciones:** 29/10/2026

---

## 1. Objetivo

Evaluar cómo cambia el rendimiento de una consulta de rango por fecha sobre una tabla de gran volumen según la estructura de índices disponible, comparando tres escenarios:

1. Sin índices (tabla *heap*).
2. Índice agrupado (*clustered*) sobre `fecha_venta`.
3. Índice no agrupado con cobertura sobre `fecha_venta` + `INCLUDE (importe)`.

## 2. Descripción del script (`indices.sql`)

| Parte | Acción | Detalle |
|-|-|-|
| 0 | Preparación | Crea `Venta_Historica(id_venta BIGINT IDENTITY, fecha_venta DATE, importe DECIMAL(12,2))` si no existe, elimina índices previos y carga datos solo si la tabla está vacía. La tabla no tiene clave primaria, por lo que parte como *heap*. |
| 1 | Carga masiva | CTE `Numeros` con `TOP (1000000)` sobre un `CROSS JOIN` de `sys.objects`. Fechas aleatorias dentro de 1825 días (5 años) desde `2020-01-01`; importes aleatorios entre 0 y 10.000. |
| 2 | Escenario 1 | Medición sin índices. |
| 3 | Escenario 2 | `CREATE CLUSTERED INDEX IX_VentaHistorica_Fecha ON Venta_Historica(fecha_venta)` y medición. |
| 4 | Escenario 3 | `DROP INDEX IX_VentaHistorica_Fecha`; `CREATE NONCLUSTERED INDEX IX_VentaHistorica_Fecha_Cobertura ON Venta_Historica(fecha_venta) INCLUDE (importe)` y medición. |

Antes de cada medición se ejecutó `CHECKPOINT; DBCC DROPCLEANBUFFERS;` para partir con caché fría, y se activaron `SET STATISTICS TIME ON` y `SET STATISTICS IO ON`.

**Consulta medida (filtro por fecha, según la guía):**

```sql
-- Escenarios 2 y 3
SELECT fecha_venta, importe
FROM Venta_Historica
WHERE fecha_venta BETWEEN '2023-01-01' AND '2023-03-31';

-- Escenario 1 (variante de la guía que además pide id_venta)
SELECT id_venta, fecha_venta, importe
FROM Venta_Historica
WHERE fecha_venta BETWEEN '2023-01-01' AND '2023-03-31';
```

> **Nota:** en el escenario 1 (heap) el motor siempre recorre todas las páginas de la tabla, sin importar cuántas columnas se pidan, por lo que las lecturas lógicas son iguales con ambas variantes de la consulta. Aun así, la comparación es más estricta si se usa la misma consulta en los tres escenarios.

La consulta devuelve **49.433 filas**, aproximadamente el **4,9 %** de la tabla (si contiene 1.000.000 de registros), un filtro muy selectivo, ideal para evaluar índices.

## 3. Resultados obtenidos

### 3.1 Cuadro comparativo

| Escenario | Tiempo CPU | Tiempo total | Lecturas lógicas | Operación principal | Costo relativo en el plan |
|-|-|-|-|-|-|
| 1. Sin índice | 141 ms | 161 ms | 4579 | Table Scan (Recorrido de tabla) | 100 % |
| 2. Índice agrupado sobre fecha | 0 ms | 36 ms | 231 | Clustered Index Seek | 100 % |
| 3. Índice con cobertura | 16 ms | 38 ms | 164 | Index Seek (NonClustered) | 100 % |

Tiempo de ejecución del operador principal según el plan: Table Scan 0,136 s · Clustered Index Seek 0,019 s · Index Seek (NonClustered) 0,018 s.

> El "100 %" del costo no sirve para comparar entre escenarios: es el costo relativo **dentro del lote**, y cada lote contiene una sola consulta. Para comparar escenarios se usan las lecturas lógicas y los tiempos.

### 3.2 Mejora respecto al escenario sin índice

| Escenario | Δ Lecturas lógicas | Reducción de lecturas | Δ Tiempo total | Δ CPU |
|-|-|-|-|-|
| Índice agrupado | 4579 → 231 | **−95,0 %** (≈ 19,8 veces menos) | −125 ms (−77,6 %) | −141 ms (−100 %) |
| Índice con cobertura | 4579 → 164 | **−96,4 %** (≈ 27,9 veces menos) | −123 ms (−76,4 %) | −125 ms (−88,7 %) |

### 3.3 Cobertura frente a agrupado

| Métrica | Agrupado | Cobertura | Diferencia |
|-|-|-|-|
| Lecturas lógicas | 231 | 164 | −67 (−29,0 %) a favor de la cobertura |
| Tiempo total | 36 ms | 38 ms | Sin diferencia relevante |
| Tiempo de CPU | 0 ms | 16 ms | Sin diferencia relevante (ver 5.2) |

## 4. Análisis comparativo

### 4.1 Escenario 1: sin índice (Table Scan)
La tabla es un *heap* sin ningún orden, por lo que para encontrar las ventas del primer trimestre de 2023 el motor debe leer **todas** las páginas (4579 lecturas lógicas, con *read-ahead* en todas ellas) y evaluar el filtro fila por fila. Se examinan 1.000.000 de filas para devolver menos de 50.000. Es el escenario más costoso: 141 ms de CPU y 161 ms de tiempo total.

### 4.2 Escenario 2: índice agrupado sobre `fecha_venta` (Clustered Index Seek)
El índice agrupado ordena físicamente la tabla por fecha. Como el filtro es un rango sobre esa misma columna, el motor navega el árbol B hasta la primera fecha del rango y lee solo las páginas contiguas que contienen el trimestre buscado: **231 lecturas** frente a 4579. El *scan* completo se transforma en un *seek*, la lectura es secuencial y el tiempo baja de 161 ms a 36 ms. Además, al ser el índice agrupado, la tabla misma está ordenada, por lo que **no requiere acceso adicional** para obtener las otras columnas (`id_venta`, `importe`).

### 4.3 Escenario 3: índice no agrupado con cobertura (Index Seek NonClustered)
El índice `(fecha_venta) INCLUDE (importe)` almacena solo las dos columnas que necesita la consulta. Es más angosto que la tabla completa, por lo que el mismo rango de fechas ocupa menos páginas: **164 lecturas**, la menor cantidad de los tres escenarios. Como contiene todas las columnas pedidas, el motor responde la consulta **solo con el índice**, sin acceder a la tabla (no hay *lookup*). Es la razón por la que se llama índice "con cobertura".

La condición es que la consulta pida únicamente columnas del índice. Si además se pidiera `id_venta`, que no forma parte del índice, el motor necesitaría acceder a la tabla por cada fila (RID lookup, al ser la tabla un *heap*); con ~49.000 filas probablemente preferiría un Table Scan. Para cubrir esa variante habría que agregar `id_venta` en el `INCLUDE`. Este caso no fue medido.

### 4.4 Conclusión general

| Criterio | Sin índice | Agrupado | Cobertura |
|-|-|-|-|
| Páginas leídas | Todas (4579) | Solo el rango (231) | Solo el rango, en estructura angosta (164) |
| Operación del plan | Scan | Seek | Seek |
| Acceso a la tabla | Total | Directo (la tabla es el índice) | Ninguno |
| Mejora de lecturas | — | −95,0 % | −96,4 % |

1. **Los dos índices mejoraron de forma drástica la consulta**: más de un 95 % menos de lecturas y cerca de un 77 % menos de tiempo total, y el plan pasó de un escaneo completo a una búsqueda.
2. **El índice con cobertura fue el más eficiente en lecturas** (29 % menos que el agrupado), aunque en tiempo ambos son equivalentes con este volumen.
3. La ventaja del agrupado es que sirve para cualquier consulta por fecha sin importar las columnas pedidas, pero solo puede haber **uno por tabla**. El de cobertura es más específico: acelera solo las consultas cuyas columnas estén contenidas en el índice, a costa de espacio adicional.
4. Los índices tienen un costo que **no se midió** en esta prueba: ocupan espacio y deben mantenerse en cada `INSERT`, `UPDATE` y `DELETE`. La decisión de crearlos debe tomar en cuenta las consultas más frecuentes del sistema.

## 5. Observaciones metodológicas

### 5.1 Consulta del escenario 1
El plan del escenario 1 corresponde a la variante que pide `id_venta`, mientras que los escenarios 2 y 3 se midieron con la variante sin `id_venta`. Como el escaneo de un *heap* lee todas las páginas en ambos casos, esto no modifica las lecturas lógicas, y el CPU/tiempo es prácticamente equivalente.

### 5.2 Precisión de los tiempos
Se tomó **una sola medición por escenario**. Los tiempos de CPU de los escenarios 2 y 3 (0 ms y 16 ms) están por debajo de la resolución del medidor, por lo que **no permiten concluir** que uno sea más rápido que el otro. Las **lecturas lógicas** son la métrica determinista y la más confiable para comparar. Para reforzar los resultados se recomienda repetir cada medición 3 veces y promediar.

### 5.3 Prueba inicial (filtro por `importe`): caso contrastante
Una primera prueba usó `WHERE importe BETWEEN 2000 AND 8500`, una columna distinta a la indexada y un rango que devuelve cerca del 65 % de la tabla.

| Escenario | Tiempo CPU | Tiempo total | Lecturas lógicas | Operación real |
|-|-|-|-|-|
| Sin índice | 843 ms | 6012 ms | 3585 | Table Scan |
| Índice agrupado sobre fecha | 687 ms | 6505 ms | 4593 | Clustered Index Scan |
| Índice con cobertura | 969 ms | 6549 ms | 4579 | Table Scan (probable) |

Ningún índice mejoró esa consulta, y el resultado es coherente con la teoría:

- **Columna indexada ≠ columna filtrada:** los índices estaban sobre `fecha_venta`, pero el filtro era por `importe`, por lo que el motor no podía hacer un *seek*.
- **Baja selectividad:** al devolver ~650.000 filas, incluso un índice sobre `importe` habría sido ignorado en favor de un escaneo completo.
- **El tiempo total (~6 s) estaba dominado por mostrar 650.000 filas en SSMS**, no por el acceso a los datos.
- En el escenario con cobertura se había anotado "Index Seek", pero con un filtro por `importe` y `id_venta` fuera del índice un *seek* no era posible, y sus 4579 lecturas coinciden exactamente con el recorrido completo del *heap* de la prueba actual, por lo que se trató con mucha probabilidad de un Table Scan.
- Las 3585 lecturas del *heap* de aquella prueba difieren de las 4579 de la actual, por lo que ambas series no son comparables entre sí.

**Lección:** un índice solo ayuda cuando su columna clave es la que se filtra y el filtro es suficientemente selectivo.

## 6. Conclusión final

Los resultados confirman lo esperado por la guía: pasar de un Table Scan a un Seek redujo las lecturas lógicas en más de un 95 % y el tiempo total cerca de un 77 %. El índice con cobertura obtuvo el mejor resultado en lecturas (164, el 3,6 % de las del escenario base) al resolver la consulta sin acceder a la tabla. La prueba con `importe` muestra la contracara: un índice mal alineado con el filtro no aporta beneficio y solo agrega costos de espacio y mantenimiento. La elección de los índices debe basarse en las consultas reales del sistema de ventas: columnas filtradas con frecuencia, selectividad del filtro y columnas que se devuelven.
