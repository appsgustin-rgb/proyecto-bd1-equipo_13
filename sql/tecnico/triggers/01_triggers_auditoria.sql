USE base_distribuidora;
GO

-- ============================================================
-- ETAPA V - TRIGGERS DE AUDITORIA
-- ============================================================
-- Tabla Auditoria_Producto
-- Guarda los cambios realizados sobre la tabla Producto.

-- Trigger 1: trg_AuditoriaProducto_Insert
-- Registra los productos nuevos.

-- Trigger 2: trg_AuditoriaProducto_Update
-- Registra los cambios de precio y de stock.

-- Trigger 3: trg_AuditoriaProducto_Delete
-- Registra los productos eliminados.

-- Tabla Auditoria_Entrega
-- Guarda los cambios de estado de las entregas.

-- Trigger 4: trg_AuditoriaEntrega_Update
-- Registra el estado anterior y el nuevo de cada entrega.
-- ============================================================ 


-- ============================================================
-- TABLA DE AUDITORIA DE PRODUCTOS
-- No tiene FOREIGN KEY hacia Producto para que el registro
-- se conserve aunque el producto se elimine.
-- fecha y usuario se completan solos con GETDATE() y
-- SUSER_SNAME().
-- ============================================================ 

IF OBJECT_ID('dbo.Auditoria_Producto', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Auditoria_Producto
    (
        id_auditoria INT IDENTITY(1,1),
        fecha DATETIME NOT NULL DEFAULT GETDATE(),
        usuario VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
        operacion VARCHAR(10) NOT NULL,
        id_producto INT NOT NULL,
        nombre_producto VARCHAR(50) NOT NULL,
        precio_anterior FLOAT NULL,
        precio_nuevo FLOAT NULL,
        stock_anterior INT NULL,
        stock_nuevo INT NULL,
        PRIMARY KEY (id_auditoria)
    );
END;
GO


-- ============================================================
-- TRIGGER 1: ALTA DE PRODUCTOS
-- La tabla inserted tiene las filas nuevas.
-- Si se insertan varios productos en una misma sentencia,
-- se registra una fila por cada uno.
-- ============================================================ 

CREATE OR ALTER TRIGGER dbo.trg_AuditoriaProducto_Insert
ON dbo.Producto
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Auditoria_Producto
        (operacion, id_producto, nombre_producto, precio_nuevo, stock_nuevo)
    SELECT
        'INSERT',
        i.id_producto,
        i.nombre_producto,
        i.precio_actual,
        i.stock
    FROM inserted AS i;
END;
GO


-- ============================================================
-- TRIGGER 2: MODIFICACION DE PRODUCTOS
-- deleted tiene los valores anteriores e inserted los nuevos.
-- Se unen por id_producto para comparar cada fila.
-- Solo se registra si cambio el precio o el stock.
-- ============================================================ 

CREATE OR ALTER TRIGGER dbo.trg_AuditoriaProducto_Update
ON dbo.Producto
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Auditoria_Producto
        (operacion, id_producto, nombre_producto,
         precio_anterior, precio_nuevo, stock_anterior, stock_nuevo)
    SELECT
        'UPDATE',
        i.id_producto,
        i.nombre_producto,
        d.precio_actual,
        i.precio_actual,
        d.stock,
        i.stock
    FROM inserted AS i
    INNER JOIN deleted AS d
        ON d.id_producto = i.id_producto
    WHERE i.precio_actual <> d.precio_actual
       OR i.stock <> d.stock;
END;
GO


-- ============================================================
-- TRIGGER 3: BAJA DE PRODUCTOS
-- La tabla deleted tiene las filas eliminadas.
-- Se guarda el ultimo precio y stock que tenia el producto.
-- ============================================================

CREATE OR ALTER TRIGGER dbo.trg_AuditoriaProducto_Delete
ON dbo.Producto
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Auditoria_Producto
        (operacion, id_producto, nombre_producto, precio_anterior, stock_anterior)
    SELECT
        'DELETE',
        d.id_producto,
        d.nombre_producto,
        d.precio_actual,
        d.stock
    FROM deleted AS d;
END;
GO


-- ============================================================
-- TABLA DE AUDITORIA DE ENTREGAS
-- ============================================================ 

IF OBJECT_ID('dbo.Auditoria_Entrega', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Auditoria_Entrega
    (
        id_auditoria INT IDENTITY(1,1),
        fecha DATETIME NOT NULL DEFAULT GETDATE(),
        usuario VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
        id_entrega INT NOT NULL,
        id_venta INT NOT NULL,
        estado_anterior VARCHAR(20) NOT NULL,
        estado_nuevo VARCHAR(20) NOT NULL,
        PRIMARY KEY (id_auditoria)
    );
END;
GO


-- ============================================================
-- TRIGGER 4: CAMBIO DE ESTADO DE UNA ENTREGA
-- ============================================================

CREATE OR ALTER TRIGGER dbo.trg_AuditoriaEntrega_Update
ON dbo.Entrega
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Auditoria_Entrega
        (id_entrega, id_venta, estado_anterior, estado_nuevo)
    SELECT
        i.id_entrega,
        i.id_venta,
        d.estado_entrega,
        i.estado_entrega
    FROM inserted AS i
    INNER JOIN deleted AS d
        ON d.id_entrega = i.id_entrega
    WHERE i.estado_entrega <> d.estado_entrega;
END;
GO


-- ============================================================
-- VERIFICACION
-- Muestra los triggers creados y la tabla a la que pertenecen.
-- ============================================================

SELECT
    t.name AS trigger_nombre,
    OBJECT_NAME(t.parent_id) AS tabla,
    t.is_disabled AS deshabilitado
FROM sys.triggers AS t
WHERE t.name LIKE 'trg_Auditoria%'
ORDER BY tabla, trigger_nombre;
GO
