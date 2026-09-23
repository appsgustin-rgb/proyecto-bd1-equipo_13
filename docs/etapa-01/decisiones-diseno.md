# Decisiones de diseño

Durante el análisis inicial del sistema se tomaron las siguientes decisiones.

## 1. Separación entre venta y detalle de venta

Se decidió representar la venta mediante dos conceptos diferentes:

- Venta: contiene la información general de la operación.
- Detalle de venta: contiene los productos incluidos, cantidades y precios unitarios históricos.

Esta separación permite registrar múltiples productos dentro de una misma venta.

---

## 2. Conservación del precio histórico

Se decidió almacenar el precio unitario dentro del detalle de venta.

Esto evita que una modificación posterior del precio actual del producto afecte las ventas realizadas anteriormente.

---

## 3. Separación entre producto y categoría

Se decidió modelar las categorías de forma independiente de los productos.

Esto permite que múltiples productos pertenezcan a una misma categoría sin repetir el nombre de la categoría en cada registro.

---

## 4. Separación de métodos de pago

Los métodos de pago se gestionarán de forma independiente.

De esta manera, un mismo método de pago podrá utilizarse en múltiples ventas.

---

## 5. Gestión separada de repartidores y entregas

Se decidió representar los repartidores independientemente de las entregas.

Esto permitirá que un repartidor pueda participar en múltiples entregas a lo largo del tiempo.

---

## 6. Registro separado de teléfonos de clientes

Se contempla la posibilidad de que un cliente pueda poseer más de un número telefónico.

Por este motivo, los teléfonos podrán administrarse separadamente de los datos principales del cliente.

---

## 7. Proveedores y productos

Debido a que un proveedor puede suministrar varios productos y un producto puede ser suministrado por diferentes proveedores, esta relación será considerada durante la etapa de modelado.
