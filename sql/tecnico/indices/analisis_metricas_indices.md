Observaciones de rendimiento primer select(sin creacion de indices agrupado sobre la fecha)

|**MEDICION**|**VALOR**|
|-|-|
|*Tiempo de CPU*|843ms|
|Tiempo total|6012ms|
|Lecturas lógicas|3585|
|Operación principal|Table Scan|

![alt text](<Captura de pantalla 2026-10-28 190626.png>)

Observaciones de rendimiento segundo select(POST-creacion de indices agrupado sobre la fecha)
|**MEDICION**|**VALOR**|
|-|-|
|*Tiempo de CPU*|687ms|
|Tiempo total|6505ms|
|Lecturas lógicas|4593|
|Operación principal|Clustered Index Scan|

![alt text](<Captura de pantalla 2026-10-28 191619.png>)

Observaciones de rendimiento segundo select(POST-eliminacion de indices agrupado sobre la fecha y creacion de un nuevo indice que cubre la consulta)
|**MEDICION**|**VALOR**|
|-|-|
|*Tiempo de CPU*|969ms|
|Tiempo total|6549ms|
|Lecturas lógicas|4579|
|Operación principal|Index seek|

![alt text](<Captura de pantalla 2026-10-28 192726.png>)

|**ESCENARIO**|**TIEMPO**|**LECTURAS LOGICAS**|**OPERACION PRINCIPAL**|
|-|-|-|-|
|Sin indice|6012|3585|Table scan|
|Indice sobre fecha|6505ms|4593|Index Seek|
|Indice sobre cobertura|6549ms|4579|index seek|