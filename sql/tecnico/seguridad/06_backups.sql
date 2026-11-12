/* ============================================================================
   06_backups.sql
   Medida 6 — Copias de seguridad (disponibilidad y recuperacion)
   PRE-REQUISITO: que exista la carpeta C:\Backups\ en el servidor.
   ============================================================================ */
USE master;
GO

/* --- (Recomendado) modelo de recuperacion FULL para poder respaldar el log --- */
ALTER DATABASE [base_distribuidora] SET RECOVERY FULL;
GO

/* --- 1. Backup COMPLETO --- */
BACKUP DATABASE [base_distribuidora]
    TO DISK = 'C:\Backups\base_distribuidora_FULL.bak'
    WITH FORMAT, INIT,
         NAME = 'Backup completo - base_distribuidora',
         CHECKSUM, STATS = 10;
GO

/* --- 2. Backup DIFERENCIAL (cambios desde el ultimo full) --- */
BACKUP DATABASE [base_distribuidora]
    TO DISK = 'C:\Backups\base_distribuidora_DIFF.bak'
    WITH DIFFERENTIAL, INIT,
         NAME = 'Backup diferencial - base_distribuidora',
         CHECKSUM, STATS = 10;
GO

/* --- 3. Backup del LOG de transacciones (recuperacion punto-en-el-tiempo) --- */
BACKUP LOG [base_distribuidora]
    TO DISK = 'C:\Backups\base_distribuidora_LOG.trn'
    WITH INIT, NAME = 'Backup de log - base_distribuidora', STATS = 10;
GO

/* ----------------------- VERIFICACION --------------------------- */
-- Validar que el archivo de backup es integro
RESTORE VERIFYONLY FROM DISK = 'C:\Backups\base_distribuidora_FULL.bak';
GO

-- Consultar nombres logicos por si difieren
RESTORE FILELISTONLY FROM DISK = 'C:\Backups\base_distribuidora_FULL.bak';
GO

-- Restaurar como base de PRUEBA (no toca la original)
RESTORE DATABASE [base_distribuidora_PRUEBA]
    FROM DISK = 'C:\Backups\base_distribuidora_FULL.bak'
    WITH MOVE 'base_distribuidora'     TO 'C:\Backups\prueba.mdf',
         MOVE 'base_distribuidora_log' TO 'C:\Backups\prueba_log.ldf',
         REPLACE, RECOVERY, STATS = 10;
GO

/* Buenas practicas (documentales):
   - Copia en otra ubicacion (disco externo / nube).
   - Backups periodicos (full semanal + diff diario + log cada X horas).
   - Al menos una copia offline o inmutable (defensa ante ransomware). */
