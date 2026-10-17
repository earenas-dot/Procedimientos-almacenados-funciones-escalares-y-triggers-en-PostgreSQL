
-- Proyecto: Actualizacion y auditoria de precios
-- Archivo: 03_procedimiento.sql
-- Objetivo: actualizar el precio de un producto existente.

CREATE OR REPLACE PROCEDURE aplicar_ajuste_precio(
    p_id_producto INTEGER,
    p_porcentaje NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_precio_actual NUMERIC(10,2);
    v_precio_nuevo NUMERIC(10,2);
BEGIN
    -- Validar el identificador
    IF p_id_producto IS NULL THEN
        RAISE EXCEPTION
            'Error: el identificador del producto no puede ser NULL.';
    END IF;

    -- Obtener el precio del producto y comprobar que exista
    SELECT precio
    INTO v_precio_actual
    FROM productos
    WHERE id_producto = p_id_producto
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Error: no existe el producto con identificador %.',
            p_id_producto;
    END IF;

    -- Calcular el nuevo precio usando la funcion escalar
    v_precio_nuevo :=
        calcular_precio_ajustado(v_precio_actual, p_porcentaje);

    -- Actualizar solamente el producto solicitado
    UPDATE productos
    SET precio = v_precio_nuevo
    WHERE id_producto = p_id_producto;
END;
$$;
