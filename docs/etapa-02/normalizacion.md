**1FN:** *Garantía de Atomicidad*

1. Atributos multivaluados/Atributos no atómicos: - teléfono en una relación Cliente\_Telefonos(id\_cliente(FK), telefono).

2. Atributos con valores repetitivos: - categoría en una relación Producto(id\_producto(PK), nombre\_producto, precio\_actual, stock, id\_categoria(FK)).

\t\t\t\t      - metodo\_pago en una relacion Venta(id\_venta(PK), fecha\_venta, id\_cliente(FK), id\_metodo\_pago(FK));



**2FN:** *Remoción de dependencias parciales*

- Detalle\_Venta: se estableció (id\_venta, nro\_linea) como PK compuesta, quedando id\_venta(FK), nro\_linea, cantidad, precio\_historico, id\_producto(FK).



**3FN:** *Abordaje de Transitividad*

- Categoria, Metodo\_Pago y Repartidor quedaron como relaciones independientes para eliminar dependencias transitivas.
- Se mantuvo precio\_historico en Detalle\_Venta y precio\_actual en Producto, evitando dependencias entre atributos no clave.
