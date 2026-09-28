**1FN:** *Garantía de Atomicidad*

1. Atributos multivaluados: Implementación de la relación cliente\_telefonos para asociar una tupla cliente a mas de un teléfono.          

2\. Atributos no atómicos: Sin cambios; los atributos del esquema se consideran atómicos.

3\. Atributos con valores repetitivos: Implementación de las relaciones Categoría y Metodo\_Pago para evitar la repetición de valores en Producto y Venta.



**2FN:** *Remoción de dependencias parciales*

- Detalle\_Venta: definición de una clave compuesta (id\_venta, nro\_linea), ya que nro\_linea se repite entre distintas ventas.



**3FN:** *Abordaje de Transitividad*

- Separación de Categoria, Metodo\_Pago y Repartidor en relaciones independientes para evitar dependencias transitivas.
- Mantener precio\_historico en Detalle\_Venta y precio\_actual en Producto para evitar dependencias entre atributos no clave.
