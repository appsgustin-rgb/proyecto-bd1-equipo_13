# Seguridad de la base `base_distribuidora`

Scripts que implementan, de forma completa y reejecutable, las 6 medidas del
informe `docs/etapa-05/Seguridad/informe-seguridad-bdd.md`, adaptadas al
esquema real (`sql/ddl/TABLAS.sql`). Motor: **SQL Server 2025**.

## Orden de ejecución

| Orden | Script | Medida |
|------|--------|--------|
| 1 | `00_preparacion.sql` | Logins/usuarios de prueba (vendedor, repartidor, auditor) |
| 2 | `01_control_acceso.sql` | Roles y mínimo privilegio |
| 3 | `02_enmascaramiento_ddm.sql` | Dynamic Data Masking |
| 4 | `03_row_level_security.sql` | Row-Level Security sobre `Entrega` |
| 5 | `04_cifrado_columna.sql` | Cifrado de columna (AES-256) del email |
| 6 | `05_auditoria.sql` | SQL Server Audit (requiere carpeta `C:\SQLAudit\`) |
| 7 | `06_backups.sql` | Backups full/diff/log (requiere carpeta `C:\Backups\`) |
| — | `99_limpieza.sql` | Revierte todas las medidas |

## Requisitos previos
- Tener creada y cargada la base: ejecutar `sql/ddl/TABLAS.sql` y `sql/dml/INSERT.sql`.
- Crear en el servidor las carpetas `C:\SQLAudit\` y `C:\Backups\` antes de los
  scripts 05 y 06.
- Ejecutar con un usuario administrador (sysadmin / db_owner).

## Notas
- Todos los scripts borran sus objetos previos al inicio: se pueden volver a correr.
- Usuarios de prueba: `usuario_limitado`, `usuario_repartidor`, `usuario_auditor`
  (contraseñas en `00_preparacion.sql`; son solo para la demo).
