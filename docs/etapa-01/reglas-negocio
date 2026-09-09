# Reglas de negocio

## RN01 - Registro de clientes

Todo cliente deberá estar registrado en el sistema antes de poder asociarle una venta.

Cada cliente deberá poseer un identificador único.

---

## RN02 - Registro de productos

Todo producto deberá poseer un identificador único, nombre, precio actual, stock y una categoría asociada.

---

## RN03 - Categorías

Cada producto deberá pertenecer a una categoría.

Una categoría podrá contener múltiples productos.

Ejemplos de categorías: Agua, Soda, Bidones y Bebidas.

---

## RN04 - Registro de ventas

Toda venta deberá estar asociada a un cliente registrado y deberá indicar la fecha en la que fue realizada.

---

## RN05 - Detalle de venta

Toda venta deberá contener uno o más productos.

Para cada producto vendido se deberá registrar:

- producto;
- cantidad;
- precio unitario histórico.

---

## RN06 - Precio histórico

El precio unitario registrado en el detalle de una venta deberá corresponder al precio vigente del producto al momento de realizarse la operación.

Las modificaciones posteriores del precio actual del producto no deberán alterar el precio registrado en ventas anteriores.

---

## RN07 - Control de stock

No se podrá registrar una venta de una cantidad superior al stock disponible de un producto.

Al confirmar una venta, el stock del producto deberá disminuir según la cantidad vendida.

---

## RN08 - Métodos de pago

Toda venta deberá utilizar un método de pago previamente registrado en el sistema.

Los métodos de pago podrán ser, por ejemplo:

- efectivo;
- transferencia;
- tarjeta.

Un mismo método de pago podrá ser utilizado en múltiples ventas.

---

## RN09 - Entregas

Una entrega deberá estar asociada a una venta registrada.

Cada entrega deberá registrar:

- fecha;
- dirección;
- estado;
- repartidor asignado.

---

## RN10 - Repartidores

Todo repartidor deberá estar registrado previamente antes de ser asignado a una entrega.

Un repartidor podrá realizar múltiples entregas.

---

## RN11 - Proveedores

Todo proveedor deberá estar registrado en el sistema.

Un proveedor podrá suministrar múltiples productos y un producto podrá ser suministrado por uno o más proveedores.

---

## RN12 - Integridad de datos

No deberá existir información relacionada con entidades inexistentes.

Por ejemplo:

- no podrá existir una venta asociada a un cliente inexistente;
- no podrá existir un detalle de venta asociado a una venta inexistente;
- no podrá existir una entrega asociada a una venta inexistente.
