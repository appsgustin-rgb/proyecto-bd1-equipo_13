## *SQL - Transacciones*

* ### *Concepto*

##### Una transacción es una **unidad lógica** que **agrupa** una o mas **instrucciones DML** para ejecutarlas como un solo bloque, siguiendo un principio fundamental de "todo o nada" en el cual se especifica que se harán efectivos los cambios en la base de datos de las instrucciones siempre y cuando ni una presente fallos en la ejecución o una condición de control admita el cambio.

* ### Propiedades ACID

##### Las propiedades con las que las transacciones cumplen para garantizar la integridad de la base de datos son:

1. ##### **A**tomicidad: Para que los cambios se guarden en la db, todas las operaciones deben ser completadas con éxito.
2. ##### **C**onsistencia: Las transacciones deben respetar las     restricciones de claves y de dominio de la db.
3. ##### Aislamiento(**I**solation): Las transacciones que se ejecutan dentro de la transacción tienen nulo acoplamiento entre si, operando como si fueran únicas en el sistema.
4. ##### **D**urabilidad: Los cambios confirmados por la transacción en el sistema son permanentes en la db con respecto a situaciones externas que no sean una modificación intencional por medio de operaciones de la db.

