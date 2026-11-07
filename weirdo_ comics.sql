CREATE DATABASE weirdo_comics
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE weirdo_comics;

CREATE TABLE rol (
    id_rol             INT          NOT NULL AUTO_INCREMENT,
    nombre             VARCHAR(30)  NOT NULL,
    modulos_permitidos VARCHAR(200) NOT NULL,
    CONSTRAINT pk_rol PRIMARY KEY (id_rol),
    CONSTRAINT uq_rol_nombre UNIQUE (nombre)
);
 
CREATE TABLE usuario (
    id_usuario INT          NOT NULL AUTO_INCREMENT,
    nombre     VARCHAR(50)  NOT NULL,
    correo     VARCHAR(50)  NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    id_rol     INT          NOT NULL,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_correo UNIQUE (correo),
    CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) REFERENCES rol (id_rol)
);
 
CREATE TABLE reportes (
    id_reporte   INT  NOT NULL AUTO_INCREMENT,
    fecha_inicio DATE NOT NULL,
    fecha_fin    DATE NOT NULL,
    id_usuario   INT  NOT NULL,
    CONSTRAINT pk_reportes PRIMARY KEY (id_reporte),
    CONSTRAINT fk_reportes_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT chk_reportes_fechas CHECK (fecha_fin >= fecha_inicio)            
);
 
CREATE TABLE productos (
    id_producto  INT           NOT NULL AUTO_INCREMENT,
    codigo       VARCHAR(20)   NOT NULL,
    tipo         VARCHAR(20)   NOT NULL,          
    nombre       VARCHAR(50)   NOT NULL,
    editorial    VARCHAR(20)   NULL,
    categoria    VARCHAR(20)   NOT NULL,
    precio       DECIMAL(8,2)  NOT NULL,
    stock        INT           NOT NULL DEFAULT 0,
    stock_minimo INT           NOT NULL,
    CONSTRAINT pk_productos PRIMARY KEY (id_producto),
    CONSTRAINT uq_productos_codigo UNIQUE (codigo),                              
    CONSTRAINT chk_productos_precio CHECK (precio > 0),                          
    CONSTRAINT chk_productos_stock CHECK (stock >= 0),                           
    CONSTRAINT chk_productos_minimo CHECK (stock_minimo > 0)
);
 
CREATE TABLE proveedores (
    id_proveedor INT          NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(50)  NOT NULL,
    correo       VARCHAR(50)  NOT NULL,                                          
    telefono     VARCHAR(15)  NOT NULL,                                          
    estado       VARCHAR(20)  NOT NULL DEFAULT 'Activo',
    direccion    VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_proveedores PRIMARY KEY (id_proveedor),
    CONSTRAINT chk_proveedores_estado CHECK (estado IN ('Activo','Inactivo'))
);
 
CREATE TABLE pedidos (
    id_pedido    INT         NOT NULL AUTO_INCREMENT,
    codigo       VARCHAR(20) NOT NULL,
    fecha        DATE        NOT NULL,
    estado       VARCHAR(15) NOT NULL DEFAULT 'Pendiente',
    id_proveedor INT         NOT NULL,                                          
    CONSTRAINT pk_pedidos PRIMARY KEY (id_pedido),
    CONSTRAINT uq_pedidos_codigo UNIQUE (codigo),
    CONSTRAINT fk_pedidos_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedores (id_proveedor),
    CONSTRAINT chk_pedidos_estado CHECK (estado IN ('Pendiente','En tránsito','Completado'))
);
 
CREATE TABLE pedidos_productos (
    id_pedido          INT NOT NULL,
    id_producto        INT NOT NULL,
    cantidad_solicitada INT NOT NULL,
    cantidad_recibida   INT NOT NULL DEFAULT 0,
    CONSTRAINT pk_pedidos_productos PRIMARY KEY (id_pedido, id_producto),
    CONSTRAINT fk_pp_pedido   FOREIGN KEY (id_pedido)   REFERENCES pedidos (id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_pp_producto FOREIGN KEY (id_producto) REFERENCES productos (id_producto),
    CONSTRAINT chk_pp_solicitada CHECK (cantidad_solicitada > 0),
    CONSTRAINT chk_pp_recibida   CHECK (cantidad_recibida >= 0)
);
 
CREATE TABLE ventas (
    id_venta    INT           NOT NULL AUTO_INCREMENT,
    folio       VARCHAR(10)   NOT NULL,
    fecha       DATETIME      NOT NULL,
    metodo_pago VARCHAR(20)   NOT NULL,
    estado      VARCHAR(15)   NOT NULL DEFAULT 'Pendiente',
    total       DECIMAL(10,2) NOT NULL DEFAULT 0,
    id_usuario  INT           NOT NULL,                                         
    CONSTRAINT pk_ventas PRIMARY KEY (id_venta),
    CONSTRAINT uq_ventas_folio UNIQUE (folio),
    CONSTRAINT fk_ventas_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT chk_ventas_estado CHECK (estado IN ('Pendiente','Pagada')),
    CONSTRAINT chk_ventas_total CHECK (total >= 0)
);
 
CREATE TABLE detalle_venta (
    id_venta    INT           NOT NULL,
    id_producto INT           NOT NULL,
    cantidad    INT           NOT NULL,
    precio      DECIMAL(8,2)  NOT NULL,
    subtotal    DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_detalle_venta PRIMARY KEY (id_venta, id_producto),
    CONSTRAINT fk_dv_venta    FOREIGN KEY (id_venta)    REFERENCES ventas (id_venta) ON DELETE CASCADE,
    CONSTRAINT fk_dv_producto FOREIGN KEY (id_producto) REFERENCES productos (id_producto),
    CONSTRAINT chk_dv_cantidad CHECK (cantidad > 0),                             
    CONSTRAINT chk_dv_subtotal CHECK (subtotal > 0)                               
);
INSERT INTO rol (nombre, modulos_permitidos) VALUES
('Administrador', 'Ventas,Cómics,Artículos,Inventario,Proveedores,Pedidos,Reportes,Usuarios,Roles y permisos'),  
('Ventas',        'Ventas,Cómics,Artículos'),                                                                    
('Almacén',       'Cómics,Artículos,Inventario,Proveedores,Pedidos'),                                            
('Supervisor',    'Ventas,Inventario,Proveedores,Pedidos,Reportes');                                             
 INSERT INTO usuario (nombre, correo, contrasena, id_rol) VALUES
('Valeria Gallegos', 'val@gmail.com',    SHA2('Admin#2026', 256), 1),  
('Carlos Ruiz',      'carlos@gmail.com', SHA2('Ventas#2026', 256), 2),  
('Tadeo Servin',     'tadeo@gmail.com',  SHA2('Almacen#2026', 256), 3), 
('Allison Vazquez',  'alico@gmail.com',  SHA2('Ventas#2027', 256), 2),  
('Mario Márquez',    'mario@gmail.com',  SHA2('Super#2026', 256), 4);   
INSERT INTO reportes (fecha_inicio, fecha_fin, id_usuario) VALUES
('2026-09-01', '2026-09-30', 1),
('2026-10-01', '2026-10-02', 1),
('2026-09-15', '2026-10-02', 5);
 
INSERT INTO productos (codigo, tipo, nombre, editorial, categoria, precio, stock, stock_minimo) VALUES
('C-001', 'Cómic',    'One Piece #108',    'Panini',  'Manga',        95.00, 18, 5),  
('C-002', 'Cómic',    'Batman: Año Uno',   'DC',      'Superhéroes', 180.00,  5, 5),  
('C-003', 'Cómic',    'Spider-Man #12',    'Marvel',  'Superhéroes', 120.00,  2, 5),  
('A-044', 'Artículo', 'Figura especial',   NULL,      'Figuras',     850.00,  0, 2),  
('A-051', 'Artículo', 'Póster Darth Maul', NULL,      'Pósters',     120.00, 15, 3),  
('A-060', 'Artículo', 'Llavero Batman',    NULL,      'Accesorios',   80.00, 23, 5);  
 
INSERT INTO proveedores (nombre, correo, telefono, estado, direccion) VALUES
('Editorial Bowlie', 'contacto@bowlie.com', '55 1234 5678', 'Activo',   'Av. Cumbres 6767'),   
('Mr Chepe',         'ventas@mrchepe.com',  '55 2234 8899', 'Activo',   'Calle Reforma 120'),  
('La Cobaya',        'hola@lacobaya.com',   '81 3344 1122', 'Inactivo', 'Av. Juárez 45');      
 
INSERT INTO pedidos (codigo, fecha, estado, id_proveedor) VALUES
('OC-00122', '2026-09-28', 'Completado',  3),  
('OC-00123', '2026-10-01', 'En tránsito', 2),  
('OC-00124', '2026-10-02', 'Pendiente',   1);  
 
INSERT INTO pedidos_productos (id_pedido, id_producto, cantidad_solicitada, cantidad_recibida) VALUES
(1, 1, 15, 15),
(1, 6, 20, 20),
(2, 2, 10, 0),
(2, 5, 10, 0),
(3, 3, 20, 0),
(3, 4, 10, 0);
 
INSERT INTO ventas (folio, fecha, metodo_pago, estado, total, id_usuario) VALUES
('000121', '2026-10-01 15:05:00', 'Efectivo', 'Pagada',     95.00, 4),  
('000122', '2026-10-01 17:20:00', 'Tarjeta',  'Pagada',    440.00, 2),  
('000123', '2026-10-02 11:30:00', 'Efectivo', 'Pagada',    275.00, 2),  
('000124', '2026-10-02 12:45:00', 'Efectivo', 'Pagada',    490.00, 4),  
('000125', '2026-10-03 10:10:00', 'Tarjeta',  'Pendiente',  80.00, 2);  
 
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio, subtotal) VALUES
(1, 1, 1,  95.00,  95.00),
(2, 5, 2, 120.00, 240.00),
(2, 6, 1,  80.00,  80.00),
(2, 3, 1, 120.00, 120.00),
(3, 2, 1, 180.00, 180.00),
(3, 1, 1,  95.00,  95.00),
(4, 1, 2,  95.00, 190.00),
(4, 2, 1, 180.00, 180.00),
(4, 3, 1, 120.00, 120.00),
(5, 6, 1,  80.00,  80.00);
SELECT codigo, nombre, stock, stock_minimo
FROM productos
WHERE stock <= stock_minimo
ORDER BY stock;
SELECT folio, fecha, metodo_pago, total
FROM ventas
WHERE estado = 'Pagada'
ORDER BY fecha DESC;
SELECT tipo, COUNT(*) AS productos, SUM(stock) AS unidades_en_stock
FROM productos
GROUP BY tipo;
SELECT v.folio, v.fecha, u.nombre AS vendedor,
       p.nombre AS producto, d.cantidad, d.precio, d.subtotal
FROM ventas v
INNER JOIN detalle_venta d ON d.id_venta    = v.id_venta
INNER JOIN productos p     ON p.id_producto = d.id_producto
INNER JOIN usuario u       ON u.id_usuario  = v.id_usuario
ORDER BY v.folio, p.nombre;
SELECT pe.codigo AS pedido, pr.nombre AS proveedor, pe.estado,
       p.nombre AS producto, pp.cantidad_solicitada, pp.cantidad_recibida
FROM pedidos pe
INNER JOIN proveedores pr       ON pr.id_proveedor = pe.id_proveedor
INNER JOIN pedidos_productos pp ON pp.id_pedido    = pe.id_pedido
INNER JOIN productos p          ON p.id_producto   = pp.id_producto
ORDER BY pe.codigo, p.nombre;
SELECT u.nombre, u.correo, r.nombre AS rol, r.modulos_permitidos
FROM usuario u
INNER JOIN rol r ON r.id_rol = u.id_rol
ORDER BY r.nombre, u.nombre;
DELIMITER $$
CREATE PROCEDURE sp_agregar_producto_venta(
    IN p_id_venta    INT,
    IN p_id_producto INT,
    IN p_cantidad    INT
)
BEGIN
    DECLARE v_estado   VARCHAR(15);
    DECLARE v_precio   DECIMAL(8,2);
    DECLARE v_stock    INT;
    DECLARE v_en_venta INT DEFAULT 0;
 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
 
    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Datos no válidos: la cantidad debe ser mayor a cero'; 
    END IF;
 
    START TRANSACTION;
 
    SELECT estado INTO v_estado FROM ventas WHERE id_venta = p_id_venta FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta no existe';
    END IF;
    IF v_estado <> 'Pendiente' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se pueden modificar ventas pendientes';
    END IF;
 
    SELECT precio, stock INTO v_precio, v_stock
      FROM productos WHERE id_producto = p_id_producto;
    IF v_precio IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto no existe';
    END IF;
 
    SELECT COALESCE(SUM(cantidad), 0) INTO v_en_venta
      FROM detalle_venta
     WHERE id_venta = p_id_venta AND id_producto = p_id_producto;
 
    IF v_stock < v_en_venta + p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';                                 
    END IF;
 
    INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio, subtotal)
    VALUES (p_id_venta, p_id_producto, p_cantidad, v_precio, v_precio * p_cantidad)
    ON DUPLICATE KEY UPDATE
        cantidad = cantidad + VALUES(cantidad),
        subtotal = cantidad * precio;
 
    UPDATE ventas
       SET total = (SELECT SUM(subtotal) FROM detalle_venta WHERE id_venta = p_id_venta)
     WHERE id_venta = p_id_venta;
 
    COMMIT;
 
    SELECT total AS total_actual FROM ventas WHERE id_venta = p_id_venta;
END$$
 

CREATE PROCEDURE sp_pagar_venta(IN p_id_venta INT)
BEGIN
    DECLARE v_estado VARCHAR(15);
    DECLARE v_lineas INT DEFAULT 0;
 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
 
    START TRANSACTION;
 
    SELECT estado INTO v_estado FROM ventas WHERE id_venta = p_id_venta FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta no existe';
    END IF;
    IF v_estado = 'Pagada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta ya fue pagada';
    END IF;
 
    SELECT COUNT(*) INTO v_lineas FROM detalle_venta WHERE id_venta = p_id_venta;
    IF v_lineas = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta no tiene productos';
    END IF;
 
    IF EXISTS (SELECT 1
                 FROM detalle_venta d
                INNER JOIN productos p ON p.id_producto = d.id_producto
                WHERE d.id_venta = p_id_venta AND p.stock < d.cantidad) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para completar la venta';          
    END IF;
 
    UPDATE productos p
    INNER JOIN detalle_venta d ON d.id_producto = p.id_producto
       SET p.stock = p.stock - d.cantidad
     WHERE d.id_venta = p_id_venta;
 
    UPDATE ventas SET estado = 'Pagada' WHERE id_venta = p_id_venta;
 
    COMMIT;
 
    SELECT v.folio, v.fecha, v.metodo_pago,
           p.nombre AS producto, d.cantidad, d.precio, d.subtotal, v.total
      FROM ventas v
     INNER JOIN detalle_venta d ON d.id_venta    = v.id_venta
     INNER JOIN productos p     ON p.id_producto = d.id_producto
     WHERE v.id_venta = p_id_venta;
END$$
 
DELIMITER ;
INSERT INTO ventas (folio, fecha, metodo_pago, id_usuario)
VALUES ('000126', NOW(), 'Tarjeta', 2);
SET @id_venta = LAST_INSERT_ID();

CALL sp_agregar_producto_venta(@id_venta, 1, 2);   
CALL sp_agregar_producto_venta(@id_venta, 5, 1);   
CALL sp_pagar_venta(@id_venta);                    
 
SELECT codigo, nombre, stock FROM productos;       
 
