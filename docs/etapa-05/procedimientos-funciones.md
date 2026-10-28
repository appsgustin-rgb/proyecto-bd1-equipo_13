Procedimientos y funciones almacenadas

1. Introducción
En esta parte del proyecto se trabajó con procedimientos almacenados y funciones en SQL Server, aplicados a la base de datos de la distribuidora de agua y soda envasada. La idea es resolver operaciones que se repiten, validar algunos datos y facilitar consultas relacionadas con los clientes y las ventas.

Los procedimientos y las funciones no cumplen exactamente el mismo propósito. Los procedimientos permiten ejecutar una secuencia de instrucciones, por ejemplo insertar, modificar o eliminar un cliente. Las funciones, en cambio, permiten devolver un valor o una tabla que después puede utilizarse en una consulta.

Para esta implementación se tomaron como base las tablas Cliente, Venta, Detalle_Venta, Metodo_Pago y Telefono_Cliente, que ya forman parte del modelo de datos del proyecto.

2. Objetivos
Los objetivos de este trabajo son:
- Crear procedimientos almacenados para insertar, modificar y eliminar clientes.
- Definir funciones que permitan calcular el total de una venta, calcular un porcentaje de descuento según las compras acumuladas de un cliente y consultar las ventas de un cliente.
- Comparar una carga de datos realizada con instrucciones INSERT directas con otra realizada mediante un procedimiento almacenado.
- Realizar pruebas para revisar el comportamiento de los objetos creados, incluidos algunos casos de error.
- Registrar los resultados obtenidos y explicar las decisiones tomadas.
3. Procedimientos almacenados
Un procedimiento almacenado es un conjunto de instrucciones SQL guardado en la base de datos y ejecutado cuando se lo invoca. Puede recibir parámetros, consultar o modificar datos y devolver información mediante parámetros de salida o consultas.

Entre sus ventajas se encuentran la posibilidad de reutilizar operaciones, centralizar validaciones y mantener las reglas de una operación en un solo lugar. También permite que distintos usuarios o aplicaciones ejecuten una operación ya definida, en lugar de repetir todas sus instrucciones.

En este proyecto se implementaron tres procedimientos sobre la tabla Cliente.
3.1. dbo.sp_InsertarCliente
Este procedimiento registra un nuevo cliente. Recibe nombre, apellido y dirección como datos obligatorios, y un correo electrónico opcional. Antes de insertar, comprueba que el nombre, el apellido y la dirección no estén vacíos. Si alguno de esos datos obligatorios falta, genera un error. Si la inserción se realiza, devuelve el identificador generado mediante el parámetro de salida @id_cliente.

Esta validación ayuda a evitar que se incorporen clientes sin los datos básicos necesarios para identificarlos y contactarlos.
3.2. dbo.sp_ModificarCliente
Este procedimiento permite actualizar los datos de un cliente existente. Recibe el identificador del cliente y los campos que se quieren modificar. Si el identificador no corresponde a un cliente registrado, genera un error.

Los parámetros de los campos modificables tienen valor predeterminado NULL. En la implementación actual, un parámetro que se deja en NULL conserva el valor que ya tenía la columna. Esto permite cambiar solamente, por ejemplo, la dirección sin tener que volver a enviar el nombre y el apellido.

Una limitación de esta decisión es que, con la lógica actual basada en ISNULL, no se puede utilizar este procedimiento para borrar el correo electrónico estableciéndolo en NULL: ese valor se interpreta como “conservar el correo anterior”.
3.3. dbo.sp_EliminarCliente
Este procedimiento elimina un cliente, pero antes comprueba que exista y que no tenga ventas registradas. La segunda validación conserva el historial comercial: si un cliente tiene ventas, el procedimiento rechaza la eliminación.

Cuando el cliente no tiene ventas, se inicia una transacción, se eliminan primero sus registros de Telefono_Cliente y después el registro de Cliente. Si la operación termina correctamente, se confirma con COMMIT. Si ocurre un error, se revierte con ROLLBACK y se vuelve a generar el error.

Aunque el tema principal de esta sección son los procedimientos y las funciones, esta operación utiliza una transacción para que las dos eliminaciones se traten como una sola operación.
4. Funciones almacenadas
Una función almacenada es un objeto de la base de datos que recibe parámetros y devuelve un resultado. Ese resultado puede ser un valor único o una tabla. Las funciones son útiles para reutilizar cálculos y consultas dentro de otras instrucciones SQL.

En este proyecto se crearon tres funciones.
4.1. dbo.fn_TotalVenta
Esta función recibe el identificador de una venta y calcula su importe total sumando el resultado de multiplicar la cantidad de cada producto por su precio histórico:

cantidad * precio_historico

El cálculo se realiza sobre Detalle_Venta. Se utiliza el precio histórico porque representa el precio guardado cuando se registró la venta y evita que un cambio posterior del precio actual del producto modifique el importe de una operación anterior.

Si la venta no tiene detalles o el identificador no encuentra filas, la suma devuelve NULL. La función utiliza ISNULL para devolver 0 en ese caso.
4.2. dbo.fn_CalcularDescuentoCliente
Esta función calcula un porcentaje de descuento a partir del importe acumulado de las ventas de un cliente. Para obtener ese importe, relaciona Venta con Detalle_Venta y suma las cantidades multiplicadas por sus precios históricos.

Las reglas que actualmente figuran en el código son:
Compras acumuladas	Porcentaje devuelto
Menos de $10.000	0 %
Desde $10.000 y menos de $15.000	5 %
Desde $15.000	10 %


La función devuelve 0.00, 0.05 o 0.10. No aplica el descuento directamente a una venta ni guarda el resultado en una tabla; solamente calcula el porcentaje correspondiente.

Importante: la guía de la Etapa V presenta como ejemplo otros umbrales ($200.000 y $500.000). Antes de entregar, el equipo debe confirmar cuáles son los importes definidos para el caso de negocio. El código, este informe y las pruebas deben utilizar la misma regla. En este informe se describió la lógica que actualmente está implementada en 01_funciones.sql.
4.3. dbo.fn_VentasDeCliente
Esta es una función con valor de tabla. Recibe el identificador de un cliente y devuelve las ventas encontradas con el identificador de venta, la fecha, el método de pago y el total calculado para cada venta.

Para obtener los datos relaciona Venta, Metodo_Pago y Detalle_Venta, y agrupa por venta, fecha y método de pago para calcular el total.

La función utiliza INNER JOIN, por lo que devuelve las ventas que tienen detalles asociados y un método de pago relacionado. Una venta sin detalles no aparecerá en el resultado. Esta decisión debe mantenerse si ese es el comportamiento esperado para las consultas del proyecto.
5. Aplicación al sistema de la distribuidora
Los objetos creados están relacionados con operaciones habituales del sistema:
- El alta, la modificación y la eliminación controlada de clientes se resuelven mediante procedimientos.
- El importe de una venta se calcula usando los detalles y el precio histórico.
- El porcentaje de descuento se obtiene a partir del total acumulado de compras de un cliente.
- Las ventas de un cliente se pueden consultar mediante una función que reúne la fecha, el medio de pago y el importe.
De esta manera, las operaciones y los cálculos quedan definidos en la base de datos y pueden reutilizarse sin escribir toda la lógica cada vez que se necesitan.
6. Pruebas previstas y verificaciones
Los scripts del proyecto incluyen consultas de prueba y operaciones de ejemplo. Para completar la entrega, se deben ejecutar en una base preparada con los datos del proyecto y guardar las evidencias reales de los resultados.
6.1. Pruebas de procedimientos
Procedimiento	Prueba	Resultado esperado
sp_InsertarCliente	Insertar un cliente con los datos obligatorios completos	Se crea el cliente y se puede consultar su identificador
sp_InsertarCliente	Enviar el nombre vacío	Se genera el error de validación
sp_ModificarCliente	Modificar la dirección de un cliente existente	Se actualiza la dirección
sp_ModificarCliente	Usar un identificador inexistente	Se genera un error indicando que el cliente no existe
sp_EliminarCliente	Eliminar un cliente sin ventas	Se eliminan el cliente y sus teléfonos asociados
sp_EliminarCliente	Intentar eliminar un cliente con ventas	La eliminación se rechaza para conservar el historial


Los resultados de esta tabla son los resultados esperados según el código. En la entrega final se deben completar con las capturas de las ejecuciones realizadas.
6.2. Pruebas de funciones
Función	Prueba	Qué se debe verificar
fn_TotalVenta	Consultar una venta existente	El total coincide con la suma de cantidades por precio histórico
fn_TotalVenta	Consultar un identificador inexistente	Devuelve 0
fn_CalcularDescuentoCliente	Consultar clientes con distintos importes acumulados	Devuelve el porcentaje que corresponde según los umbrales definidos
fn_VentasDeCliente	Consultar un cliente que tenga ventas con detalles	Devuelve los datos de esas ventas y su total
fn_VentasDeCliente	Consultar un identificador inexistente	Devuelve cero filas


También es conveniente probar importes acumulados exactamente iguales a cada umbral del descuento, porque permiten verificar que los operadores >= se comportan como se definió.
7. Comparación de inserciones y cálculos
El archivo 04_comparacion_eficiencia.sql prepara una comparación entre cuatro operaciones:
1. Realizar 1.000 inserciones directas en Cliente.
2. Realizar 1.000 inserciones invocando sp_InsertarCliente.
3. Calcular 1.000 veces el total de una venta mediante una consulta directa.
4. Calcular 1.000 veces el total mediante fn_TotalVenta.
El script mide el tiempo transcurrido en milisegundos para cada operación y muestra los resultados en una tabla. Para las inserciones utiliza una transacción que termina con ROLLBACK, de modo que los registros de prueba no permanezcan en la tabla. Sin embargo, los valores IDENTITY pueden avanzar aunque las inserciones se reviertan.

La comparación debe ejecutarse después de crear los procedimientos y las funciones y de cargar los datos necesarios. El script necesita al menos una venta con detalles para hacer la comparación de totales.

Resultados: los tiempos no se incluyen en este informe porque deben obtenerse ejecutando el script en el entorno del equipo. Una vez realizada la prueba, se debe copiar la tabla de resultados o incluir una captura y explicar cuál operación tardó menos en esa ejecución.

El tiempo medido puede variar según el equipo, el estado de la base, la caché y otras condiciones de ejecución. Por eso, una única medición no alcanza para afirmar que un procedimiento o una función siempre será más rápido que una consulta directa. El objetivo de esta prueba es observar el comportamiento de las alternativas en las mismas condiciones.
8. Archivos utilizados
La implementación de este tema se encuentra en los siguientes archivos del repositorio:
- sql/tecnico/procedimientos_funciones/01_procedimientos_crud.sql: definición de los tres procedimientos.
- sql/tecnico/procedimientos_funciones/02_lote_insert_directo.sql: lote de inserciones directas.
- sql/tecnico/procedimientos_funciones/03_lote_con_procedimientos.sql: inserciones mediante procedimiento y pruebas de modificación, eliminación y errores.
- sql/tecnico/procedimientos_funciones/04_comparacion_eficiencia.sql: comparación de tiempos.
- sql/tecnico/funciones/01_funciones.sql: definición y consultas de prueba de las tres funciones.
9. Conclusión
El trabajo permitió implementar procedimientos para administrar clientes y funciones para resolver cálculos y consultas vinculados con las ventas. Los procedimientos reúnen operaciones que se pueden reutilizar y agregan validaciones para evitar algunas acciones incorrectas, como eliminar un cliente que ya tiene ventas. Las funciones permiten calcular el importe de una venta a partir del precio histórico, obtener un porcentaje de descuento y consultar las ventas de un cliente.

Las pruebas son necesarias para comprobar que estos objetos funcionan tanto con datos válidos como ante situaciones de error. La comparación de tiempos permite observar las diferencias entre las operaciones directas y las realizadas mediante procedimientos o funciones, aunque los resultados deben interpretarse según el entorno en el que se ejecutaron.

Antes de cerrar la entrega, queda confirmar los umbrales de descuento establecidos para el negocio, ejecutar las pruebas, incorporar los tiempos medidos y guardar las capturas como evidencia. De esa manera, el informe reflejará no solo el código desarrollado, sino también su comportamiento comprobado en la base de datos.
