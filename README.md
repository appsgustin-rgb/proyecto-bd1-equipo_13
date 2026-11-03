# Proyecto Integrador - Base de Datos 1

## Sistema Gestor de Ventas - Distribuidora de Agua y Soda Envasada

Proyecto integrador de la materia **Base de Datos 1** (Equipo 13). Implementa una
base de datos relacional en **SQL Server** para gestionar las operaciones comerciales
de una distribuidora de agua y soda envasada: clientes, productos, ventas, métodos de
pago, stock, repartidores y entregas.

Además del modelo y las consultas de negocio, el proyecto incluye temas técnicos de
SQL Server: procedimientos y funciones almacenadas, transacciones, triggers de
auditoría, optimización con índices y medidas de seguridad.

---

## Descripción

El sistema da soporte al registro y consulta de la información comercial de la
distribuidora. Permite registrar clientes y productos, cargar ventas con su detalle de
líneas, conservar el **precio histórico** de cada producto al momento de la operación,
administrar métodos de pago y stock, y controlar las entregas realizadas a los clientes
junto con el repartidor asignado y su estado.

El alcance, las reglas de negocio (RN01 a RN11) y lo que queda fuera del sistema están
documentados en `docs/etapa-01/`.

---

## Modelo de datos

La base `base_distribuidora` está compuesta por las siguientes tablas:

| Tabla | Descripción |
|-------|-------------|
| `Cliente` | Datos del cliente (nombre, apellido, dirección, email). |
| `Telefono_Cliente` | Teléfonos de cada cliente (un cliente puede tener varios). |
| `Categoria` | Categorías de producto (agua mineral, carbonatada, de mesa, saborizada). |
| `Producto` | Productos con precio actual, stock y categoría asociada. |
| `Metodo_Pago` | Métodos de pago disponibles (efectivo, débito, crédito, transferencia). |
| `Venta` | Cabecera de la venta (fecha, cliente, método de pago). |
| `Detalle_Venta` | Líneas de la venta (producto, cantidad, precio histórico). PK compuesta `(nro_linea, id_venta)`. |
| `Repartidor` | Datos de los repartidores. |
| `Entrega` | Entregas asociadas a una venta (fecha, estado, dirección, repartidor). |

Los scripts de triggers agregan dos tablas de auditoría: `Auditoria_Producto` y
`Auditoria_Entrega`.

El diagrama entidad-relación se encuentra en `docs/etapa-02/der/der.png` y el modelo
relacional editable en `docs/etapa-02/modelo_relacional.erdplus`.

### Decisiones de diseño destacadas
- **Separación venta / detalle de venta:** permite registrar múltiples productos por venta.
- **Precio histórico:** se guarda en `Detalle_Venta` para que cambios futuros de precio no
  alteren ventas pasadas.
- **Normalización hasta 3FN:** categorías, métodos de pago y repartidores quedan como
  entidades independientes; los teléfonos se separan para admitir varios por cliente.
- **Restricciones de dominio:** `precio_actual` y `precio_historico` deben ser mayores a 0
  y `stock` no puede ser negativo.

---

## Etapas del proyecto

| Etapa | Contenido | Documentación |
|-------|-----------|---------------|
| 1 | Descripción del caso, alcance, reglas de negocio y decisiones de diseño. | `docs/etapa-01/` |
| 2 | Modelo relacional, DER y normalización. | `docs/etapa-02/` |
| 3 | Implementación, restricciones de integridad y pruebas. | `docs/etapa-03/` |
| 4 | Casos de uso y consultas de negocio (comprobante, informe por categoría, seguimiento de entregas). | `docs/etapa-04/` |
| 5 | Procedimientos y funciones, transacciones, triggers de auditoría, índices y seguridad. | `docs/etapa-05/` |

### Etapa 4 - Consultas de negocio

| Caso de uso | Script | Documento |
|-------------|--------|-----------|
| CU-01: Emitir comprobante de venta | `sql/consultas/comprobante-venta.sql` | `docs/etapa-04/comprobante-venta.md` |
| CU-02: Consultar ventas por categoría | `sql/consultas/ventas-por-categoria.sql` | `docs/etapa-04/informe-ventas.md` |
| CU-03: Controlar entregas | `sql/consultas/seguimiento-entregas.sql` | `docs/etapa-04/consulta-avanzada.md` |

Las consultas usan `JOIN`, funciones de ventana (`SUM ... OVER`), agregaciones con
`GROUP BY` / `HAVING`, subconsultas, `CASE` y `DATEDIFF`. Los importes siempre se
calculan con `precio_historico`. El detalle de cada caso está en `docs/etapa-04/casos-uso.md`.

### Etapa 5 - Temas técnicos

**Procedimientos y funciones almacenadas** (`docs/etapa-05/investigacion.md`)
- CRUD sobre `Cliente`: `sp_InsertarCliente`, `sp_ModificarCliente` y `sp_EliminarCliente`,
  con validaciones y errores personalizados (50010 a 50013). No se permite eliminar
  clientes con ventas registradas.
- Funciones: `fn_TotalVenta` (total de una venta), `fn_CalcularDescuentoCliente`
  (descuento del 0 %, 5 % o 10 % según compras acumuladas) y `fn_VentasDeCliente`
  (función con valor de tabla).
- Comparación de eficiencia entre operaciones directas y su versión con procedimientos
  o funciones (1000 repeticiones de cada una).

**Transacciones** (`docs/etapa-05/transacciones.md`)
- Registro de una venta con descuento de stock y alta/modificación de clientes, cada una
  con una versión que provoca un error para comprobar el `ROLLBACK`.

**Triggers de auditoría** (`docs/etapa-05/triggers-auditoria.md`)
- `trg_AuditoriaProducto_Insert`, `trg_AuditoriaProducto_Update` y
  `trg_AuditoriaProducto_Delete` registran altas, cambios de precio o stock y bajas de
  productos.
- `trg_AuditoriaEntrega_Update` registra los cambios de estado de las entregas.

**Optimización con índices** (`docs/etapa-05/indices.md`)
- Prueba sobre una tabla de 1.000.000 de registros simulados (`Venta_Historica`),
  comparando una consulta por rango de fechas sin índice, con índice agrupado y con
  índice no agrupado con cobertura. Los índices redujeron las lecturas lógicas en
  alrededor de un 95 %.

**Seguridad** (`docs/etapa-05/Seguridad/informe-seguridad-bdd.md`)
- Control de acceso y mínimo privilegio, enmascaramiento dinámico de datos (DDM),
  seguridad a nivel de fila (RLS), cifrado a nivel de columna, auditoría con
  SQL Server Audit y copias de seguridad. Los scripts de cada medida están incluidos en
  el informe y las capturas en `docs/etapa-05/Seguridad/images/`.

---

## Estructura del repositorio

```
proyecto-bd1-equipo_13/
├── docs/
│   ├── etapa-01/   Alcance, descripción del caso, reglas de negocio, decisiones de diseño
│   ├── etapa-02/   Modelo relacional (ERDPlus), DER, normalización
│   ├── etapa-03/   Implementación, restricciones de integridad, pruebas
│   ├── etapa-04/   Casos de uso, comprobante, informe de ventas, consulta avanzada
│   └── etapa-05/
│       ├── Seguridad/    Informe de seguridad y capturas
│       ├── evidencias/   Capturas de errores y de las funciones
│       ├── investigacion.md        Procedimientos y funciones
│       ├── transacciones.md
│       ├── triggers-auditoria.md
│       └── indices.md
└── sql/
    ├── ddl/        TABLAS.sql  (creación de la base y las tablas)
    ├── dml/        INSERT.sql  (datos de prueba)
    ├── consultas/  Consultas de negocio (etapa 4)
    └── tecnico/
        ├── procedimientos_funciones/  CRUD, lotes de carga y comparación de eficiencia
        ├── funciones/                 Funciones almacenadas
        ├── transacciones/             Transacciones y sus pruebas de error
        ├── triggers/                  Triggers de auditoría y sus pruebas
        └── indices/                   Prueba de rendimiento con índices
```

---

## Puesta en marcha

Requisitos: **SQL Server** (las pruebas se realizaron sobre SQL Server 2025) y
**SQL Server Management Studio (SSMS)** o Azure Data Studio.

1. Clonar el repositorio.
2. Abrir SSMS y conectarse a la instancia (ej.: `localhost\SQLEXPRESS`).
3. Ejecutar los scripts en este orden:

| Paso | Script | Qué hace |
|------|--------|----------|
| 1 | `sql/ddl/TABLAS.sql` | Crea la base `base_distribuidora` y sus tablas. |
| 2 | `sql/dml/INSERT.sql` | Carga los datos de prueba. |
| 3 | `sql/consultas/*.sql` | Consultas de negocio de la etapa 4 (solo lectura). |
| 4 | `sql/tecnico/procedimientos_funciones/01_procedimientos_crud.sql` | Crea los procedimientos CRUD de `Cliente`. |
| 5 | `sql/tecnico/funciones/01_funciones.sql` | Crea las funciones y ejecuta sus pruebas. |
| 6 | `sql/tecnico/procedimientos_funciones/02_lote_insert_directo.sql` y `03_lote_con_procedimientos.sql` | Cargan clientes adicionales, con `INSERT` directo y con `sp_InsertarCliente`. |
| 7 | `sql/tecnico/procedimientos_funciones/04_comparacion_eficiencia.sql` | Mide los tiempos (las inserciones de prueba se revierten). |
| 8 | `sql/tecnico/transacciones/*.sql` | Transacciones correctas y con error. Usan `sp_InsertarCliente` y clientes cargados en el paso 6. |
| 9 | `sql/tecnico/triggers/01_triggers_auditoria.sql` y `02_pruebas_triggers.sql` | Crean las tablas y triggers de auditoría y los prueban. |
| 10 | `sql/tecnico/indices/indices.sql` | Prueba de rendimiento con índices sobre una tabla de 1.000.000 de registros (tarda en cargar). |

Las consultas que reciben datos de entrada usan variables (`DECLARE`) o condiciones en el
`WHERE` que se pueden modificar para consultar otra venta, otro período u otro importe.

---

## Equipo

Proyecto desarrollado por el **Equipo 13** — Base de Datos 1.
