## *SQL - Transacciones*

* ### *Concepto*

##### Una transacción es una **unidad lógica** que **agrupa** una o mas **instrucciones DML** para ejecutarlas como un solo bloque, siguiendo un principio fundamental de "todo o nada" en el cual se especifica que se harán efectivos los cambios en la base de datos de las instrucciones siempre y cuando ni una presente fallos en la ejecución o una condición de control admita el cambio.

* ### Propiedades ACID

##### Las propiedades con las que las transacciones cumplen para garantizar la integridad de la base de datos son:

1. ##### **A**tomicidad: Para que los cambios se guarden en la db, todas las operaciones deben ser completadas con éxito.
2. ##### **C**onsistencia: Las transacciones deben respetar las     restricciones de claves y de dominio de la db.
3. ##### Aislamiento(**I**solation): Las transacciones que se ejecutan dentro de la transacción tienen nulo acoplamiento entre si, operando como si fueran únicas en el sistema.
4. ##### **D**urabilidad: Los cambios confirmados por la transacción en el sistema son permanentes en la db con respecto a situaciones externas que no sean una modificación intencional por medio de operaciones de la db.

* #### Conclusiones

##### En base a pruebas realizadas con las transacciones especificadas en transaccion\_venta.sql, transaccion\_clientes.sql con sus respectivas pruebas de errores, concluimos que sobre todo por una de sus propiedades mas características, siendo esta la **atomicidad,** una trasaccion bien definida sobre un bloque de consultas mitiga el riesgo de perdida de consistencia y defectos de integridad de la bd ante los mas minimos errores de sintaxis y lógica en las consultas asociadas, mediante un rollback total de todos los cambios que fueron realizados por el bloque en si.

