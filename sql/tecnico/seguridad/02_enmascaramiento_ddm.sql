/* ============================================================================
   02_enmascaramiento_ddm.sql
   Medida 2 — Dynamic Data Masking (DDM)
   Oculta datos personales en los resultados a quien no tenga UNMASK.
   El dato real NO se modifica en la tabla.
   Requiere: 00_preparacion.sql
   ============================================================================ */
USE [base_distribuidora];
GO

/* --- Cliente: email, direccion, nombre y apellido --- */
ALTER TABLE dbo.Cliente ALTER COLUMN email
    ADD MASKED WITH (FUNCTION = 'email()');
ALTER TABLE dbo.Cliente ALTER COLUMN direccion
    ADD MASKED WITH (FUNCTION = 'default()');
ALTER TABLE dbo.Cliente ALTER COLUMN apellido
    ADD MASKED WITH (FUNCTION = 'partial(1,"****",0)');   -- deja la inicial
GO

/* --- Telefono_Cliente: telefono (ultimos 2 digitos) --- */
ALTER TABLE dbo.Telefono_Cliente ALTER COLUMN telefono
    ADD MASKED WITH (FUNCTION = 'partial(0,"XXXX",2)');
GO

/* --- Repartidor: telefono --- */
ALTER TABLE dbo.Repartidor ALTER COLUMN telefono
    ADD MASKED WITH (FUNCTION = 'partial(0,"XXXX",2)');
GO

/* --- Entrega: direccion_entrega --- */
ALTER TABLE dbo.Entrega ALTER COLUMN direccion_entrega
    ADD MASKED WITH (FUNCTION = 'default()');
GO

/* --- Quitar el permiso de ver en claro a los perfiles no autorizados --- */
DENY UNMASK TO usuario_limitado;
DENY UNMASK TO usuario_auditor;
GO

/* ----------------------- VERIFICACION --------------------------- */
-- Administrador: datos reales
SELECT id_cliente, nombre, apellido, email, direccion FROM dbo.Cliente;

-- Usuario limitado: datos enmascarados
EXECUTE AS USER = 'usuario_limitado';
    SELECT id_cliente, nombre, apellido, email, direccion FROM dbo.Cliente;
REVERT;
GO

-- Listado de columnas enmascaradas 
SELECT OBJECT_NAME(object_id) AS tabla, name AS columna, masking_function
FROM sys.masked_columns
ORDER BY tabla, columna;
GO
