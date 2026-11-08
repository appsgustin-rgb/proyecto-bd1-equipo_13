USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'base_distribuidora')
BEGIN
    CREATE DATABASE base_distribuidora;
END;
GO

USE base_distribuidora;
GO


DROP TABLE IF EXISTS Telefono_Cliente;
DROP TABLE IF EXISTS Entrega;
DROP TABLE IF EXISTS Detalle_Venta;
DROP TABLE IF EXISTS Producto;
DROP TABLE IF EXISTS Venta;
DROP TABLE IF EXISTS Repartidor;
DROP TABLE IF EXISTS Categoria;
DROP TABLE IF EXISTS Metodo_Pago;
DROP TABLE IF EXISTS Cliente;
GO

CREATE TABLE Cliente
(
  id_cliente INT IDENTITY(1,1) NOT NULL,
  nombre     VARCHAR(35) NOT NULL,
  apellido   VARCHAR(35) NOT NULL,
  direccion  VARCHAR(50) NOT NULL,
  email      VARCHAR(50) NULL,
  CONSTRAINT PK_Cliente PRIMARY KEY (id_cliente)
);

CREATE TABLE Metodo_Pago
(
  id_metodo_pago INT IDENTITY(1,1) NOT NULL,
  descripcion    VARCHAR(35) NOT NULL,
  CONSTRAINT PK_Metodo_Pago PRIMARY KEY (id_metodo_pago),
  CONSTRAINT UQ_Metodo_Pago_descripcion UNIQUE (descripcion)
);

CREATE TABLE Categoria
(
  id_categoria     INT IDENTITY(1,1) NOT NULL,
  nombre_categoria VARCHAR(35) NOT NULL,
  CONSTRAINT PK_Categoria PRIMARY KEY (id_categoria),
  CONSTRAINT UQ_Categoria_nombre UNIQUE (nombre_categoria)
);

CREATE TABLE Repartidor
(
  id_repartidor INT IDENTITY(1,1) NOT NULL,
  nombre        VARCHAR(35) NOT NULL,
  apellido      VARCHAR(35) NOT NULL,
  telefono      VARCHAR(20) NOT NULL,
  CONSTRAINT PK_Repartidor PRIMARY KEY (id_repartidor)
);

CREATE TABLE Venta
(
  id_venta       INT IDENTITY(1,1) NOT NULL,
  fecha_venta    DATE NOT NULL,
  id_cliente     INT NOT NULL,
  id_metodo_pago INT NOT NULL,
  CONSTRAINT PK_Venta PRIMARY KEY (id_venta),
  CONSTRAINT FK_Venta_Cliente FOREIGN KEY (id_cliente)
      REFERENCES Cliente(id_cliente)
      ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT FK_Venta_Metodo_Pago FOREIGN KEY (id_metodo_pago)
      REFERENCES Metodo_Pago(id_metodo_pago)
      ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE Producto
(
  id_producto     INT IDENTITY(1,1) NOT NULL,
  nombre_producto VARCHAR(50) NOT NULL,
  precio_actual   DECIMAL(10,2) NOT NULL,
  stock           INT NOT NULL,
  id_categoria    INT NOT NULL,
  CONSTRAINT PK_Producto PRIMARY KEY (id_producto),
  CONSTRAINT FK_Producto_Categoria FOREIGN KEY (id_categoria)
      REFERENCES Categoria(id_categoria)
      ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT CK_Producto_precio CHECK (precio_actual > 0),
  CONSTRAINT CK_Producto_stock  CHECK (stock >= 0)
);

CREATE TABLE Detalle_Venta
(
  nro_linea        INT NOT NULL,
  cantidad         INT NOT NULL,
  precio_historico DECIMAL(10,2) NOT NULL,
  id_producto      INT NOT NULL,
  id_venta         INT NOT NULL,
  CONSTRAINT PK_Detalle_Venta PRIMARY KEY (nro_linea, id_venta),
  CONSTRAINT FK_Detalle_Producto FOREIGN KEY (id_producto)
      REFERENCES Producto(id_producto)
      ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT FK_Detalle_Venta FOREIGN KEY (id_venta)
      REFERENCES Venta(id_venta)
      ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT CK_Detalle_nro_linea CHECK (nro_linea > 0),
  CONSTRAINT CK_Detalle_cantidad  CHECK (cantidad > 0),
  CONSTRAINT CK_Detalle_precio    CHECK (precio_historico > 0)
);

CREATE TABLE Entrega
(
  id_entrega        INT IDENTITY(1,1) NOT NULL,
  fecha_entrega     DATE NOT NULL,
  estado_entrega    VARCHAR(20) NOT NULL,
  direccion_entrega VARCHAR(50) NOT NULL,
  id_repartidor     INT NOT NULL,
  id_venta          INT NOT NULL,
  CONSTRAINT PK_Entrega PRIMARY KEY (id_entrega),
  CONSTRAINT FK_Entrega_Repartidor FOREIGN KEY (id_repartidor)
      REFERENCES Repartidor(id_repartidor)
      ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT FK_Entrega_Venta FOREIGN KEY (id_venta)
      REFERENCES Venta(id_venta)
      ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT CK_Entrega_estado
      CHECK (estado_entrega IN ('Pendiente', 'En camino', 'Entregada'))
);

CREATE TABLE Telefono_Cliente
(
  telefono   VARCHAR(20) NOT NULL,
  id_cliente INT NOT NULL,
  CONSTRAINT PK_Telefono_Cliente PRIMARY KEY (telefono, id_cliente),
  CONSTRAINT FK_Telefono_Cliente FOREIGN KEY (id_cliente)
      REFERENCES Cliente(id_cliente)
      ON DELETE CASCADE ON UPDATE NO ACTION
);
GO
