
-- Proyecto: Actualizacion y auditoria de precios
-- Archivo: 04_trigger_y_funcion.sql
-- Objetivo: registrar automaticamente los cambios efectivos de precio.

-- 1. Funcion de soporte del trigger
CREATE OR REPLACE FUNCTION registrar_cambio_precio()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Registrar solo si el precio realmente cambio
    IF OLD.precio IS DISTINCT FROM NEW.precio THEN
        INSERT INTO auditoria_precios (
            id_producto,
            precio_anterior,
            precio_nuevo,
            fecha_hora,
            usuario_bd
        )
        VALUES (
            NEW.id_producto,
            OLD.precio,
            NEW.precio,
            CURRENT_TIMESTAMP,
            CURRENT_USER
        );
    END IF;

    RETURN NEW;
END;
$$;

-- 2. Crear el trigger sobre la tabla productos
DROP TRIGGER IF EXISTS trigger_auditar_precio ON productos;

CREATE TRIGGER trigger_auditar_precio
AFTER UPDATE ON productos
FOR EACH ROW
EXECUTE FUNCTION registrar_cambio_precio();
