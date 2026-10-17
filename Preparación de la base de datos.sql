
-- Proyecto: Actualizacion y auditoria de precios
-- Archivo: 01_preparacion.sql
-- Motor: PostgreSQL
-- Consultar la version instalada con SELECT version();

-- 1. Crear tabla de productos
CREATE TABLE IF NOT EXISTS productos (
    id_producto INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2) NOT NULL CHECK (precio > 0)
);

-- 2. Insertar tres productos de prueba
INSERT INTO productos (nombre, precio)
SELECT datos.nombre, datos.precio
FROM (VALUES
    ('Teclado', 150.00::NUMERIC(10,2)),
    ('Mouse', 75.00::NUMERIC(10,2)),
    ('Monitor', 1200.00::NUMERIC(10,2))
) AS datos(nombre, precio)
WHERE NOT EXISTS (
    SELECT 1
    FROM productos p
    WHERE p.nombre = datos.nombre
);

-- 3. Crear tabla de auditoria de precios
CREATE TABLE IF NOT EXISTS auditoria_precios (
    id_auditoria INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_producto INTEGER NOT NULL
        REFERENCES productos(id_producto),
    precio_anterior NUMERIC(10,2) NOT NULL,
    precio_nuevo NUMERIC(10,2) NOT NULL,
    fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd TEXT NOT NULL
);

-- 4. Consultar la version de PostgreSQL
SELECT version();

-- 5. Comprobar los productos registrados
SELECT id_producto, nombre, precio
FROM productos
ORDER BY id_producto;

-- 6. Comprobar la estructura de auditoria
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'auditoria_precios'
ORDER BY ordinal_position;
