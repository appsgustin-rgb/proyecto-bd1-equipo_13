CREATE TABLE Cliente
(
  id_cliente INT IDENTITY(1,1) NOT NULL,
  nombre VARCHAR(35) NOT NULL,
  apellido VARCHAR(35) NOT NULL,
  direccion VARCHAR(50) NOT NULL,
  email VARCHAR(50) NULL,
  PRIMARY KEY (id_cliente),
);

CREATE TABLE Metodo_Pago
(
  id_metodo_pago INT IDENTITY(1,1) NOT NULL,
  descripcion VARCHAR(35) NOT NULL,
  PRIMARY KEY (id_metodo_pago),
);

CREATE TABLE Venta
(
  id_venta INT IDENTITY(1,1) NOT NULL,
  fecha_venta DATE NOT NULL,
  id_cliente INT NOT NULL,
  id_metodo_pago INT NOT NULL,
  PRIMARY KEY (id_venta),
  FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
  FOREIGN KEY (id_metodo_pago) REFERENCES Metodo_Pago(id_metodo_pago),
);

CREATE TABLE Categoria
(
  id_categoria INT IDENTITY(1,1) NOT NULL,
  nombre_categoria VARCHAR(35) NOT NULL,
  PRIMARY KEY (id_categoria),
);

CREATE TABLE Producto
(
  id_producto INT IDENTITY(1,1) NOT NULL,
  nombre_producto VARCHAR(50) NOT NULL,
  precio_actual FLOAT NOT NULL CHECK (precio_actual > 0),
  stock INT NOT NULL CHECK (stock >= 0),
  id_categoria INT NOT NULL,
  PRIMARY KEY (id_producto),
  FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria),
);

CREATE TABLE Detalle_Venta
(
  nro_linea INT NOT NULL,
  cantidad INT NOT NULL,
  precio_historico FLOAT NOT NULL CHECK (precio_historico > 0),
  id_producto INT NOT NULL,
  id_venta INT NOT NULL,
  PRIMARY KEY (nro_linea, id_venta),
  FOREIGN KEY (id_producto) REFERENCES Producto(id_producto),
  FOREIGN KEY (id_venta) REFERENCES Venta(id_venta)
);

CREATE TABLE Repartidor
(
  id_repartidor INT IDENTITY(1,1) NOT NULL,
  nombre VARCHAR(35) NOT NULL,
  apellido VARCHAR(35) NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  PRIMARY KEY (id_repartidor),
);

CREATE TABLE Entrega
(
  id_entrega INT IDENTITY(1,1) NOT NULL,
  fecha_entrega DATE NOT NULL,
  estado_entrega VARCHAR(20) NOT NULL,
  direccion_entrega VARCHAR(50) NOT NULL,
  id_repartidor INT NOT NULL,
  id_venta INT NOT NULL,
  PRIMARY KEY (id_entrega),
  FOREIGN KEY (id_repartidor) REFERENCES Repartidor(id_repartidor),
  FOREIGN KEY (id_venta) REFERENCES Venta(id_venta),
);

CREATE TABLE Telefono_Cliente
(
  telefono VARCHAR(20) NOT NULL,
  id_cliente INT NOT NULL,
  PRIMARY KEY (telefono, id_cliente),
  FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
);
