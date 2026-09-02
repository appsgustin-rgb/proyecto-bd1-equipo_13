**Sistema Gestor de Ventas - Distribuidora de Agua y Soda Envasada**

*Descripción*

El rubro elegido corresponde al de las distribuidoras de agua y soda envasada, las cuales desempeñan tareas de producción, comercialización y distribución de las mismas en el mercado, contando para ello con maquinaria (gasificadoras, purificadoras, etc), transporte (camiones, camionetas, etc), personal (operarios, conductores, etc) e instalaciones necesarios, realizando también entregas particulares mediante reparto a todo tipo de clientes.

*Reglas de negocio*

**RN01:** Un pedido no puede incluir una cantidad de unidades solicitadas menor a cero.

**RN02:** cliente no puede tener registrado más de un número de teléfono celular idéntico en el sistema.

**RN03:** La fechas de vencimiento de un pago a cuenta corriente no puede ser anterior a la fecha de emisión de la factura.

**RN04:** El inventario de cualquier producto en depósito no puede registrar una cantidad menor a cero.

**RN05:** El número de identificación de cada cliente debe ser único en todo el sistema.

**RN06:** El valor monetario asignado a un producto no puede ser inferior a cero.

**RN07:** El precio persiste para ventas realizadas ante actualizaciones.

**RN08:** La cantidad disponible de productor en stock no puede ser negativa.

## Requerimientos Funcionales

1. **Gestión de clientes.** Permitir el alta, baja, modificación y consulta de clientes (nombre, apellido, teléfono, dirección, email).
2. **Gestión de productos.** Administrar el catálogo de productos con su precio actual, stock y categoría asociada.
3. **Gestión de categorías.** Permitir crear y administrar categorías de productos (Agua, Soda, Bidones, Bebidas, etc.).
4. **Gestión de proveedores.** Registrar proveedores y asociarlos a los productos que suministran.
5. **Registro de ventas.** Permitir registrar una venta indicando el cliente, la fecha, el método de pago y los productos adquiridos con sus cantidades.
6. **Detalle de venta con precio histórico.** Al registrar una venta, almacenar el precio unitario vigente en ese momento para cada producto vendido.
7. **Actualización automática de stock.** Al confirmar una venta, el sistema debe descontar del stock la cantidad vendida de cada producto.
8. **Gestión de métodos de pago.** Permitir registrar y administrar los métodos de pago disponibles (efectivo, transferencia, tarjeta).
9. **Gestión de repartidores.** Administrar los datos de los repartidores (nombre, apellido, teléfono).
10. **Gestión de entregas.** Registrar entregas asociadas a ventas, asignar repartidor, dirección de entrega y controlar el estado de cada entrega.
11. **Consultas e informes.** Permitir consultas como ventas por cliente, productos más vendidos, entregas pendientes, estado de stock, ventas por método de pago, etc.

## Requerimientos No Funcionales
### Fiabilidad
1. **Integridad de datos.** El sistema debe garantizar la integridad referencial mediante claves primarias y foráneas en todas las tablas.
2. **Consistencia transaccional.** Las operaciones que involucren venta y descuento de stock deben ejecutarse como transacciones atómicas para evitar inconsistencias.
3. **Disponibilidad.** El sistema debe estar operativo durante el horario comercial para no interrumpir la toma de pedidos ni la asignación de entregas.
### Estandares
1. **Normalización.** La base de datos debe estar normalizada (al menos hasta 3FN) para evitar redundancia de información.
### Eficiencia
1. **Rendimiento.** Las consultas frecuentes (búsqueda de clientes, consulta de stock, listado de entregas pendientes) deben responder en tiempos razonables, apoyándose en índices donde corresponda.
2. **Escalabilidad.** El modelo debe soportar el crecimiento en cantidad de clientes, productos, ventas y entregas sin requerir rediseño estructural.
### Seguridad
1. **Seguridad.** El acceso al sistema debe estar restringido a usuarios autorizados, protegiendo los datos de clientes y transacciones.
### Usabilidad
1. **Usabilidad.** La interfaz (si la hubiera) debe ser lo suficientemente intuitiva para que los operadores registren ventas y entregas de forma ágil.
