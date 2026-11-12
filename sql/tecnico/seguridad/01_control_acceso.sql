/* ============================================================================
   01_control_acceso.sql
   Medida 1 — Control de acceso y principio de minimo privilegio
   Crea roles por responsabilidad y asigna SOLO los permisos necesarios.
   Requiere: 00_preparacion.sql
   ============================================================================ */
USE [base_distribuidora];
GO

/* --- Limpieza previa de roles (para reejecutar) --- */
IF DATABASE_PRINCIPAL_ID('rol_vendedor')          IS NOT NULL DROP ROLE rol_vendedor;
IF DATABASE_PRINCIPAL_ID('rol_repartidor')        IS NOT NULL DROP ROLE rol_repartidor;
IF DATABASE_PRINCIPAL_ID('rol_auditor_consulta')  IS NOT NULL DROP ROLE rol_auditor_consulta;
GO

/* ========================= ROL VENDEDOR =========================
   Puede consultar catalogo y registrar ventas; NO borra clientes
   ni modifica precios ni toca la estructura.                        */
CREATE ROLE rol_vendedor;
GO
GRANT SELECT          ON dbo.Cliente        TO rol_vendedor;
GRANT SELECT          ON dbo.Producto       TO rol_vendedor;
GRANT SELECT          ON dbo.Categoria      TO rol_vendedor;
GRANT SELECT          ON dbo.Metodo_Pago    TO rol_vendedor;
GRANT SELECT, INSERT  ON dbo.Venta          TO rol_vendedor;
GRANT SELECT, INSERT  ON dbo.Detalle_Venta  TO rol_vendedor;
-- Denegaciones explicitas (ganan sobre cualquier GRANT heredado):
DENY  DELETE          ON dbo.Cliente        TO rol_vendedor;
DENY  UPDATE, DELETE  ON dbo.Producto       TO rol_vendedor;
DENY  DELETE          ON dbo.Venta          TO rol_vendedor;
GO

/* ========================= ROL REPARTIDOR =======================
   Consulta sus entregas y solo actualiza el ESTADO de la entrega.  */
CREATE ROLE rol_repartidor;
GO
GRANT SELECT               ON dbo.Entrega                 TO rol_repartidor;
GRANT UPDATE (estado_entrega) ON dbo.Entrega              TO rol_repartidor; -- solo esa columna
GRANT SELECT               ON dbo.Venta                   TO rol_repartidor;
DENY  INSERT, DELETE       ON dbo.Entrega                 TO rol_repartidor;
GO

/* ====================== ROL AUDITOR / CONSULTA ==================
   Solo lectura de todo, pero sin poder desenmascarar (ver Medida 2). */
CREATE ROLE rol_auditor_consulta;
GO
GRANT SELECT ON SCHEMA::dbo TO rol_auditor_consulta;
DENY  INSERT, UPDATE, DELETE ON SCHEMA::dbo TO rol_auditor_consulta;
GO

/* --- Asignacion de usuarios a roles --- */
ALTER ROLE rol_vendedor         ADD MEMBER usuario_limitado;
ALTER ROLE rol_repartidor       ADD MEMBER usuario_repartidor;
ALTER ROLE rol_auditor_consulta ADD MEMBER usuario_auditor;
GO

/* ----------------------- VERIFICACION ---------------------------
   El DELETE debe FALLAR: "The DELETE permission was denied..."     */
EXECUTE AS USER = 'usuario_limitado';
    BEGIN TRY
        DELETE FROM dbo.Cliente WHERE id_cliente = 1;  -- debe fallar
        PRINT 'ERROR: el DELETE no deberia haberse permitido';
    END TRY
    BEGIN CATCH
        PRINT 'OK - permiso denegado: ' + ERROR_MESSAGE();
    END CATCH
REVERT;
GO

-- Listado de permisos efectivos por rol 
SELECT dp.name AS rol, p.permission_name, p.state_desc,
       OBJECT_NAME(p.major_id) AS objeto
FROM sys.database_permissions p
JOIN sys.database_principals dp ON dp.principal_id = p.grantee_principal_id
WHERE dp.name IN ('rol_vendedor','rol_repartidor','rol_auditor_consulta')
ORDER BY rol, objeto, p.permission_name;
GO
