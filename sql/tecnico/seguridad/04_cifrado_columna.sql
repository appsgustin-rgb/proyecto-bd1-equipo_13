/* ============================================================================
   04_cifrado_columna.sql
   Medida 4 — Cifrado a nivel de columna (cell-level, AES-256)
   Guarda el email del cliente cifrado en reposo. Alternativa a TDE
   (no disponible en Express).
   ============================================================================ */
USE [base_distribuidora];
GO

/* --- Limpieza previa (para reejecutar) --- */
IF COL_LENGTH('dbo.Cliente','email_cifrado') IS NOT NULL
    ALTER TABLE dbo.Cliente DROP COLUMN email_cifrado;
GO
IF EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = 'ClaveEmail')
    DROP SYMMETRIC KEY ClaveEmail;
GO
IF EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'CertCifradoColumna')
    DROP CERTIFICATE CertCifradoColumna;
GO

/* --- 1. Clave maestra de la base (si no existe) --- */
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Clave#Maestra#Fuerte2026';
GO

/* --- 2. Certificado que protege la clave simetrica --- */
CREATE CERTIFICATE CertCifradoColumna
    WITH SUBJECT = 'Certificado para cifrado de columnas';
GO

/* --- 3. Clave simetrica AES-256 --- */
CREATE SYMMETRIC KEY ClaveEmail
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE CertCifradoColumna;
GO

/* --- 4. Columna binaria para el email cifrado --- */
ALTER TABLE dbo.Cliente ADD email_cifrado VARBINARY(256);
GO

/* --- 5. Cifrar los emails existentes --- */
OPEN SYMMETRIC KEY ClaveEmail DECRYPTION BY CERTIFICATE CertCifradoColumna;
    UPDATE dbo.Cliente
    SET email_cifrado = ENCRYPTBYKEY(KEY_GUID('ClaveEmail'), email);
CLOSE SYMMETRIC KEY ClaveEmail;
GO

/* ----------------------- VERIFICACION --------------------------- */
-- SIN abrir la clave: binario ilegible
SELECT id_cliente, email, email_cifrado FROM dbo.Cliente;

-- ABRIENDO la clave: se descifra
OPEN SYMMETRIC KEY ClaveEmail DECRYPTION BY CERTIFICATE CertCifradoColumna;
    SELECT id_cliente,
           email_cifrado AS valor_almacenado,
           CONVERT(VARCHAR(100), DECRYPTBYKEY(email_cifrado)) AS email_descifrado
    FROM dbo.Cliente;
CLOSE SYMMETRIC KEY ClaveEmail;
GO

/* Opcional (cifrado "real" en reposo): una vez validado, se puede dejar de
   almacenar el email en claro.  Descomentar con cuidado:
   -- ALTER TABLE dbo.Cliente DROP MASKED;  -- si tuviera mascara sobre email
   -- ALTER TABLE dbo.Cliente DROP COLUMN email;
*/
