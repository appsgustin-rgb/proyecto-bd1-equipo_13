/* ============================================================================
   99_limpieza.sql
   Revierte TODAS las medidas de seguridad (deja la base como antes).
   Util para repetir la demostracion desde cero.
   ============================================================================ */
USE [base_distribuidora];
GO

/* --- Medida 3: RLS --- */
IF OBJECT_ID('Seguridad.politica_entregas','SP') IS NOT NULL DROP SECURITY POLICY Seguridad.politica_entregas;
IF OBJECT_ID('Seguridad.fn_filtro_repartidor','IF') IS NOT NULL DROP FUNCTION Seguridad.fn_filtro_repartidor;
IF SCHEMA_ID('Seguridad') IS NOT NULL DROP SCHEMA Seguridad;
GO

/* --- Medida 2: DDM --- */
IF COL_LENGTH('dbo.Cliente','email') IS NOT NULL          ALTER TABLE dbo.Cliente ALTER COLUMN email DROP MASKED;
IF COL_LENGTH('dbo.Cliente','direccion') IS NOT NULL      ALTER TABLE dbo.Cliente ALTER COLUMN direccion DROP MASKED;
IF COL_LENGTH('dbo.Cliente','apellido') IS NOT NULL       ALTER TABLE dbo.Cliente ALTER COLUMN apellido DROP MASKED;
IF COL_LENGTH('dbo.Telefono_Cliente','telefono') IS NOT NULL ALTER TABLE dbo.Telefono_Cliente ALTER COLUMN telefono DROP MASKED;
IF COL_LENGTH('dbo.Repartidor','telefono') IS NOT NULL    ALTER TABLE dbo.Repartidor ALTER COLUMN telefono DROP MASKED;
IF COL_LENGTH('dbo.Entrega','direccion_entrega') IS NOT NULL ALTER TABLE dbo.Entrega ALTER COLUMN direccion_entrega DROP MASKED;
GO

/* --- Medida 4: cifrado --- */
IF COL_LENGTH('dbo.Cliente','email_cifrado') IS NOT NULL  ALTER TABLE dbo.Cliente DROP COLUMN email_cifrado;
IF EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name='ClaveEmail') DROP SYMMETRIC KEY ClaveEmail;
IF EXISTS (SELECT 1 FROM sys.certificates WHERE name='CertCifradoColumna') DROP CERTIFICATE CertCifradoColumna;
GO

/* --- Medida 1: roles y usuarios --- */
IF DATABASE_PRINCIPAL_ID('rol_vendedor') IS NOT NULL          DROP ROLE rol_vendedor;
IF DATABASE_PRINCIPAL_ID('rol_repartidor') IS NOT NULL        DROP ROLE rol_repartidor;
IF DATABASE_PRINCIPAL_ID('rol_auditor_consulta') IS NOT NULL  DROP ROLE rol_auditor_consulta;
GO
IF DATABASE_PRINCIPAL_ID('usuario_limitado') IS NOT NULL   DROP USER usuario_limitado;
IF DATABASE_PRINCIPAL_ID('usuario_repartidor') IS NOT NULL DROP USER usuario_repartidor;
IF DATABASE_PRINCIPAL_ID('usuario_auditor') IS NOT NULL    DROP USER usuario_auditor;
GO

/* --- Medida 5: auditoria --- */
IF EXISTS (SELECT 1 FROM sys.database_audit_specifications WHERE name='AuditoriaDatosSensibles')
BEGIN
    ALTER DATABASE AUDIT SPECIFICATION AuditoriaDatosSensibles WITH (STATE = OFF);
    DROP DATABASE AUDIT SPECIFICATION AuditoriaDatosSensibles;
END
IF EXISTS (SELECT 1 FROM sys.database_audit_specifications WHERE name='AuditoriaCliente')
BEGIN
    ALTER DATABASE AUDIT SPECIFICATION AuditoriaCliente WITH (STATE = OFF);
    DROP DATABASE AUDIT SPECIFICATION AuditoriaCliente;
END
GO
USE master;
GO
IF SUSER_ID('usuario_limitado') IS NOT NULL   DROP LOGIN usuario_limitado;
IF SUSER_ID('usuario_repartidor') IS NOT NULL DROP LOGIN usuario_repartidor;
IF SUSER_ID('usuario_auditor') IS NOT NULL    DROP LOGIN usuario_auditor;
GO
IF EXISTS (SELECT 1 FROM sys.server_audits WHERE name='AuditoriaVentas')
BEGIN
    ALTER SERVER AUDIT AuditoriaVentas WITH (STATE = OFF);
    DROP SERVER AUDIT AuditoriaVentas;
END
GO
PRINT 'Medidas de seguridad revertidas.';
GO
