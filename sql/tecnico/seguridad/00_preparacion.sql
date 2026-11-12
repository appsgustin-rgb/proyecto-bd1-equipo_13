/* ============================================================================
   00_preparacion.sql
   Entorno de pruebas para las medidas de seguridad
   Motor: SQL Server 2025  |  Base: base_distribuidora
   Crea los logins y usuarios con los que se contrastan los permisos.
   Reejecutable: borra los objetos previos si existen.
   ============================================================================ */
USE [base_distribuidora];
GO

/* --- Limpieza previa de usuarios/logins (para poder reejecutar) --- */
IF DATABASE_PRINCIPAL_ID('usuario_limitado')  IS NOT NULL DROP USER usuario_limitado;
IF DATABASE_PRINCIPAL_ID('usuario_repartidor') IS NOT NULL DROP USER usuario_repartidor;
IF DATABASE_PRINCIPAL_ID('usuario_auditor')    IS NOT NULL DROP USER usuario_auditor;
GO
IF SUSER_ID('usuario_limitado')  IS NOT NULL DROP LOGIN usuario_limitado;
IF SUSER_ID('usuario_repartidor') IS NOT NULL DROP LOGIN usuario_repartidor;
IF SUSER_ID('usuario_auditor')    IS NOT NULL DROP LOGIN usuario_auditor;
GO

/* --- Login + usuario: perfil VENDEDOR (permisos acotados) --- */
CREATE LOGIN usuario_limitado  WITH PASSWORD = 'Demo#Segura2026', CHECK_POLICY = OFF;
CREATE USER  usuario_limitado  FOR LOGIN usuario_limitado;
GO

/* --- Login + usuario: perfil REPARTIDOR (para probar RLS) --- */
CREATE LOGIN usuario_repartidor WITH PASSWORD = 'Demo#Reparto2026', CHECK_POLICY = OFF;
CREATE USER  usuario_repartidor FOR LOGIN usuario_repartidor;
GO

/* --- Login + usuario: perfil AUDITOR / SOLO CONSULTA --- */
CREATE LOGIN usuario_auditor WITH PASSWORD = 'Demo#Auditor2026', CHECK_POLICY = OFF;
CREATE USER  usuario_auditor FOR LOGIN usuario_auditor;
GO

PRINT 'Entorno de pruebas creado: usuario_limitado, usuario_repartidor, usuario_auditor';
GO
