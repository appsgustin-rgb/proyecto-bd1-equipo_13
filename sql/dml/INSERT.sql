
-- ============================================
-- 1. CLIENTES
-- ============================================

INSERT INTO Cliente (id_cliente, nombre, apellido, direccion, email)
VALUES
(1, 'Juan', 'Perez', 'Av. 3 de abril 1250', 'juan.perez@gmail.com'),
(2, 'Maria', 'Gomez', 'San Martin 845', 'maria.gomez@gmail.com'),
(3, 'Carlos', 'Rodriguez', 'Junin 1320', 'carlos.rodriguez@gmail.com'),
(4, 'Lucia', 'Fernandez', '25 de Mayo 560', 'lucia.fernandez@gmail.com'),
(5, 'Matias', 'Benitez', 'Belgrano 920', 'matias.benitez@gmail.com'),
(6, 'Sofia', 'Martinez', 'Moreno 1450', 'sofia.martinez@gmail.com'),
(7, 'Diego', 'Gonzalez', 'Maipu 730', 'diego.gonzalez@gmail.com'),
(8, 'Camila', 'Lopez', 'Rivadavia 1105', 'camila.lopez@gmail.com');


-- ============================================
-- 2. TELEFONOS DE CLIENTES
-- ============================================

INSERT INTO Telefono_Cliente (telefono, id_cliente)
VALUES
('3794123456', 1),
('3794234567', 2),
('3794345678', 3),
('3794456789', 4),
('3794567890', 5),
('3794678901', 6),
('3794789012', 7),
('3794890123', 8),
('3794987654', 1),
('3794012345', 3);


-- ============================================
-- 3. CATEGORIAS
-- ============================================

INSERT INTO Categoria (id_categoria, nombre_categoria)
VALUES
(1, 'Agua 350ml'),
(1, 'Agua 500ml'),
(1, 'Agua 1L'),
(1, 'Agua 1,5L'),
(2, 'Soda 500ml'),
(2, 'Soda 1L'),
(2, 'Soda 350ml'),
(2, 'Soda 2L')


-- ============================================
-- 4. PRODUCTOS
-- ============================================

INSERT INTO Producto 
(id_producto, nombre_producto, precio_actual, stock, id_categoria)
VALUES
(1, 'Agua mineral 500ml', 800.00, 100, 1),
(2, 'Agua mineral 1.5L', 1200.00, 80, 1),
(3, 'Agua mineral 2.25L', 1500.00, 60, 1),
(4, 'Soda 500ml', 700.00, 100, 2),
(5, 'Soda 1.5L', 1100.00, 90, 2),
(6, 'Soda 2.25L', 1400.00, 70, 2),
(7, 'Bidon de agua 12L', 4500.00, 40, 3),
(8, 'Bidon de agua 20L', 6000.00, 35, 3),
(9, 'Agua saborizada 1.5L', 1800.00, 50, 4),
(10, 'Agua saborizada 500ml', 1200.00, 75, 4);


-- ============================================
-- 5. METODOS DE PAGO
-- ============================================

INSERT INTO Metodo_Pago (id_metodo_pago, descripcion)
VALUES
(1, 'Efectivo'),
(2, 'Tarjeta de debito'),
(3, 'Tarjeta de credito'),
(4, 'Transferencia');


-- ============================================
-- 6. REPARTIDORES
-- ============================================

INSERT INTO Repartidor (id_repartidor, nombre, apellido, telefono)
VALUES
(1, 'Federico', 'Acosta', '3794111111'),
(2, 'Nicolas', 'Sanchez', '3794222222'),
(3, 'Martin', 'Diaz', '3794333333'),
(4, 'Agustin', 'Romero', '3794444444');


-- ============================================
-- 7. VENTAS
-- ============================================

INSERT INTO Venta 
(id_venta, fecha_venta, id_cliente, id_metodo_pago)
VALUES
(1, '2026-09-01', 1, 1),
(2, '2026-09-02', 2, 4),
(3, '2026-09-03', 3, 2),
(4, '2026-09-04', 4, 1),
(5, '2026-09-05', 5, 3),
(6, '2026-09-06', 6, 4),
(7, '2026-09-07', 7, 1),
(8, '2026-09-08', 8, 2),
(9, '2026-09-09', 1, 4),
(10, '2026-09-10', 3, 1);


-- ============================================
-- 8. DETALLE DE VENTAS
-- ============================================

INSERT INTO Detalle_Venta
(id_venta, nro_linea, cantidad, precio_historico, id_producto)
VALUES

-- Venta 1
(1, 1, 3, 800.00, 1),
(1, 2, 2, 1100.00, 5),

-- Venta 2
(2, 1, 2, 1200.00, 2),
(2, 2, 1, 4500.00, 7),

-- Venta 3
(3, 1, 5, 700.00, 4),
(3, 2, 2, 1400.00, 6),

-- Venta 4
(4, 1, 1, 6000.00, 8),
(4, 2, 3, 1500.00, 3),

-- Venta 5
(5, 1, 4, 800.00, 1),
(5, 2, 2, 1800.00, 9),

-- Venta 6
(6, 1, 2, 4500.00, 7),
(6, 2, 3, 1100.00, 5),

-- Venta 7
(7, 1, 6, 700.00, 4),

-- Venta 8
(8, 1, 2, 6000.00, 8),
(8, 2, 4, 1200.00, 10),

-- Venta 9
(9, 1, 3, 1500.00, 3),
(9, 2, 2, 1400.00, 6),

-- Venta 10
(10, 1, 1, 6000.00, 8),
(10, 2, 5, 800.00, 1);


-- ============================================
-- 9. ENTREGAS
-- ============================================

INSERT INTO Entrega
(id_entrega, fecha_entrega, estado_entrega, direccion_entrega, id_repartidor, id_venta)
VALUES
(1, '2026-09-01', 'Entregada', 'Av. Italia 1250', 1, 1),
(2, '2026-09-02', 'Entregada', 'San Martin 845', 2, 2),
(3, '2026-09-03', 'Entregada', 'Junin 1320', 3, 3),
(4, '2026-09-04', 'Entregada', '25 de Mayo 560', 4, 4),
(5, '2026-09-05', 'Entregada', 'Belgrano 920', 1, 5),
(6, '2026-09-06', 'Entregada', 'Moreno 1450', 2, 6),
(7, '2026-09-07', 'Entregada', 'Maipu 730', 3, 7),
(8, '2026-09-08', 'Entregada', 'Rivadavia 1105', 4, 8),
(9, '2026-09-09', 'Pendiente', 'Av. Italia 1250', 1, 9),
(10, '2026-09-10', 'Pendiente', 'Junin 1320', 2, 10);
