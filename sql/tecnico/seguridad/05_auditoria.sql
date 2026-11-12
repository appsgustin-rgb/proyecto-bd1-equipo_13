/* ============================================================================
   05_auditoria.sql
   Medida 5 — SQL Server Audit
   Registra SELECT/INSERT/UPDATE/DELETE sobre las tablas con datos sensibles.
   PRE-REQUISITO: que exista la carpeta C:\SQLAudit\ en el servidor.
   ============================================================================ */

/* --- Limpieza previa (para reejecutar) --- */
USE [base_distribuidora];
GO
-- Borrar cualquier especificacion de auditoria previa (nombre nuevo y el del informe original)
IF EXISTS (SELECT 1 FROM sys.database_audit_specifications WHERE name = 'AuditoriaDatosSensibles')
BEGIN
    ALTER DATABASE AUDIT SPECIFICATION AuditoriaDatosSensibles WITH (STATE = OFF);
    DROP DATABASE AUDIT SPECIFICATION AuditoriaDatosSensibles;
END
IF EXISTS (SELECT 1 FROM sys.database_audit_specifications WHERE name = 'AuditoriaCliente')
BEGIN
    ALTER DATABASE AUDIT SPECIFICATION AuditoriaCliente WITH (STATE = OFF);
    DROP DATABASE AUDIT SPECIFICATION AuditoriaCliente;
END
GO
USE master;
GO
IF EXISTS (SELECT 1 FROM sys.server_audits WHERE name = 'AuditoriaVentas')
BEGIN
    ALTER SERVER AUDIT AuditoriaVentas WITH (STATE = OFF);
    DROP SERVER AUDIT AuditoriaVentas;
END
GO

/* --- 1. Destino de la auditoria (nivel servidor) --- */
CREATE SERVER AUDIT AuditoriaVentas
    TO FILE (FILEPATH = 'C:\SQLAudit\', MAXSIZE = 50 MB, MAX_ROLLOVER_FILES = 10)
    WITH (ON_FAILURE = CONTINUE);
GO
ALTER SERVER AUDIT AuditoriaVentas WITH (STATE = ON);
GO

/* --- 2. Que acciones auditar (nivel base) --- */
USE [base_distribuidora];
GO
CREATE DATABASE AUDIT SPECIFICATION AuditoriaDatosSensibles
    FOR SERVER AUDIT AuditoriaVentas
    ADD (SELECT, INSERT, UPDATE, DELETE ON dbo.Cliente          BY public),
    ADD (SELECT, INSERT, UPDATE, DELETE ON dbo.Telefono_Cliente BY public),
    ADD (SELECT, INSERT, UPDATE, DELETE ON dbo.Repartidor       BY public),
    ADD (SELECT, INSERT, UPDATE, DELETE ON dbo.Entrega          BY public)
    WITH (STATE = ON);
GO

/* ----------------------- VERIFICACION --------------------------- */
-- Generar actividad
SELECT * FROM dbo.Cliente;
UPDATE dbo.Cliente SET nombre = nombre WHERE id_cliente = 1;  -- evento de UPDATE

-- Leer el registro de auditoria
SELECT event_time,
       server_principal_name AS usuario,
       action_id,
       OBJECT_NAME(object_id) AS objeto,
       statement
FROM sys.fn_get_audit_file('C:\SQLAudit\*.sqlaudit', DEFAULT, DEFAULT)
ORDER BY event_time DESC;
GO
