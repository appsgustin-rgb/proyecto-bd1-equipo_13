/* ============================================================================
   03_row_level_security.sql
   Medida 3 — Row-Level Security (RLS)
   Cada repartidor ve SOLO sus entregas. Admin/auditor ven todas.
   El filtro vive en la base, no en la aplicacion.
   ============================================================================ */
USE [base_distribuidora];
GO

/* --- Limpieza previa (para reejecutar) --- */
IF OBJECT_ID('Seguridad.politica_entregas', 'SP') IS NOT NULL
    DROP SECURITY POLICY Seguridad.politica_entregas;
GO
IF OBJECT_ID('Seguridad.fn_filtro_repartidor', 'IF') IS NOT NULL
    DROP FUNCTION Seguridad.fn_filtro_repartidor;
GO
IF SCHEMA_ID('Seguridad') IS NULL EXEC('CREATE SCHEMA Seguridad');
GO

/* --- Funcion de predicado --- */
CREATE FUNCTION Seguridad.fn_filtro_repartidor(@id_repartidor INT)
    RETURNS TABLE
    WITH SCHEMABINDING
AS
    RETURN
        SELECT 1 AS acceso_permitido
        WHERE @id_repartidor = CAST(SESSION_CONTEXT(N'id_repartidor') AS INT)
           OR IS_MEMBER('db_owner') = 1                       -- administrador
           OR IS_ROLEMEMBER('rol_auditor_consulta') = 1;      -- auditor ve todo
GO

/* --- Politica de seguridad sobre dbo.Entrega --- */
CREATE SECURITY POLICY Seguridad.politica_entregas
    ADD FILTER PREDICATE Seguridad.fn_filtro_repartidor(id_repartidor) ON dbo.Entrega
    WITH (STATE = ON);
GO

/* ----------------------- VERIFICACION ---------------------------
   IMPORTANTE: como administrador (db_owner) la funcion deja ver TODO
   (bypass de la Medida 1). Para VER el filtro hay que impersonar al
   usuario repartidor, que no es admin. Requiere 00 y 01 ya ejecutados. */
EXEC sp_set_session_context 'id_repartidor', 1;
EXECUTE AS USER = 'usuario_repartidor';
    SELECT 'Repartidor 1' AS contexto;
    SELECT * FROM dbo.Entrega;   -- solo entregas del repartidor 1
REVERT;

EXEC sp_set_session_context 'id_repartidor', 2;
EXECUTE AS USER = 'usuario_repartidor';
    SELECT 'Repartidor 2' AS contexto;
    SELECT * FROM dbo.Entrega;   -- solo entregas del repartidor 2
REVERT;

-- Limpiar el contexto de la sesion
EXEC sp_set_session_context 'id_repartidor', NULL;
GO

/* Alternativa sin usuario: para demostrarlo conectado como admin, se puede
   quitar temporalmente el bypass de la funcion (dejar solo la comparacion
   con SESSION_CONTEXT), probar, y volver a dejarla como esta. */

/* Para desactivar la politica durante pruebas:
   ALTER SECURITY POLICY Seguridad.politica_entregas WITH (STATE = OFF);  */
