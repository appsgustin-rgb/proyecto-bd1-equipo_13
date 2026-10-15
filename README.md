# Proyecto Integrador - Base de Datos 1

## Sistema Gestor de Ventas - Distribuidora de Agua y Soda Envasada

Proyecto integrador de la materia **Base de Datos 1** (Equipo 13). Implementa una
base de datos relacional en **SQL Server** para gestionar las operaciones comerciales
de una distribuidora de agua y soda envasada: clientes, productos, ventas, métodos de
pago, stock, repartidores y entregas.

---

## Descripción

El sistema da soporte al registro y consulta de la información comercial de la
distribuidora. Permite registrar clientes y productos, cargar ventas con su detalle de
líneas, conservar el **precio histórico** de cada producto al momento de la operación,
administrar métodos de pago y stock, y controlar las entregas realizadas a los clientes
junto con el repartidor asignado y su estado.

---

## Modelo de datos

La base `Distribuidora_de_Agua` está compuesta por las siguientes tablas:

| Tabla | Descripción |
|-------|-------------|
| `Cliente` | Datos del cliente (nombre, apellido, dirección, email). |
| `Telefono_Cliente` | Teléfonos de cada cliente (un cliente puede tener varios). |
| `Categoria` | Categorías de producto (agua mineral, carbonatada, de mesa, saborizada). |
| `Producto` | Productos con precio actual, stock y categoría asociada. |
| `Metodo_Pago` | Métodos de pago disponibles (efectivo, débito, crédito, transferencia). |
| `Venta` | Cabecera de la venta (fecha, cliente, método de pago). |
| `Detalle_Venta` | Líneas de la venta (producto, cantidad, precio histórico). PK compuesta `(id_venta, nro_linea)`. |
| `Repartidor` | Datos de los repartidores. |
| `Entrega` | Entregas asociadas a una venta (fecha, estado, dirección, repartidor). |

El diagrama entidad-relación se encuentra en `docs/etapa-02/der/der.png` y el modelo
relacional editable en `docs/etapa-02/modelo_relacional.erdplus`.

### Decisiones de diseño destacadas
- **Separación venta / detalle de venta:** permite registrar múltiples productos por venta.
- **Precio histórico:** se guarda en `Detalle_Venta` para que cambios futuros de precio no
  alteren ventas pasadas.
- **Normalización hasta 3FN:** categorías, métodos de pago y repartidores quedan como
  entidades independientes; los teléfonos se separan para admitir varios por cliente.

---

## Estructura del repositorio

```
proyecto-bd1-equipo_13/
├── docs/
│   ├── etapa-01/   Alcance, descripción del caso, reglas de negocio, decisiones de diseño
│   ├── etapa-02/   Modelo relacional, DER, normalización
│   ├── etapa-03/   Implementación, restricciones, pruebas
│   ├── etapa-04/
│   └── etapa-05/
└── sql/
    ├── ddl/        TABLAS.sql  (creación de tablas)
    ├── dml/        INSERT.sql  (datos de prueba)
    ├── consultas/  Consultas de negocio
    └── tecnico/
```

### Scripts SQL principales
- **`sql/ddl/TABLAS.sql`** — crea la base y todas las tablas con sus claves y restricciones.
- **`sql/dml/INSERT.sql`** — carga datos de prueba (clientes, productos, ventas, entregas, etc.).
- **`sql/consultas/comprobante-venta.sql`** — comprobante de una venta con subtotales y total.
- **`sql/consultas/ventas-por-categoria.sql`** — desempeño de ventas por categoría
  (`Categoria` + `Producto` + `Detalle_Venta`, con `WHERE`, `CASE` y `HAVING`).
- **`sql/consultas/seguimiento-entregas.sql`** — control de entregas pendientes / a revisar
  (`Entrega` + `Venta` + `Cliente`, con `WHERE`, `CASE` y `DATEDIFF`).

---

## Puesta en marcha

Requisitos: **SQL Server** y **SQL Server Management Studio (SSMS)** o Azure Data Studio.

1. Clonar el repositorio.
2. Abrir SSMS y conectarse a la instancia (ej.: `localhost\SQLEXPRESS`).
3. Ejecutar `sql/ddl/TABLAS.sql` para crear la base y las tablas.
4. Ejecutar `sql/dml/INSERT.sql` para cargar los datos de prueba.
5. Ejecutar las consultas de `sql/consultas/` según lo que se quiera analizar.

---

## Equipo

Proyecto desarrollado por el **Equipo 13** — Base de Datos 1.
