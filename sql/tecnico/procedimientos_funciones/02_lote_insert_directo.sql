USE base_distribuidora;
go

-- ============================================================
-- Lote 1: carga de clientes con sentencias INSERT directas
-- ============================================================

INSERT INTO Cliente (nombre, apellido, direccion, email)
VALUES
('Valentina', 'Ruiz',   'Catamarca 455',  'valentina.ruiz@gmail.com'),
('Joaquin',   'Ortiz',  'Bolivar 1780',   'joaquin.ortiz@gmail.com'),
('Florencia', 'Vega',   'Mendoza 690',    'florencia.vega@gmail.com'),
('Tomas',     'Medina', 'Salta 1025',     'tomas.medina@gmail.com'),
('Agustina',  'Castro', 'Corrientes 340', 'agustina.castro@gmail.com');

-- Telefonos de algunos de los clientes nuevos
INSERT INTO Telefono_Cliente (telefono, id_cliente)
SELECT '3794100200', id_cliente FROM Cliente WHERE email = 'valentina.ruiz@gmail.com';

INSERT INTO Telefono_Cliente (telefono, id_cliente)
SELECT '3794300400', id_cliente FROM Cliente WHERE email = 'tomas.medina@gmail.com';

-- Verificacion
SELECT * FROM Cliente WHERE id_cliente > 8;