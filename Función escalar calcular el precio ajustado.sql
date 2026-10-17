
-- Proyecto: Actualizacion y auditoria de precios
-- Archivo: 02_funcion_escalar.sql
-- Objetivo: calcular un precio ajustado sin modificar tablas.

CREATE OR REPLACE FUNCTION public.calcular_precio_ajustado(
    precio_actual NUMERIC,
    porcentaje NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    precio_resultante NUMERIC;
BEGIN
    -- Validar parametros NULL
    IF precio_actual IS NULL OR porcentaje IS NULL THEN
        RAISE EXCEPTION
            'Error: el precio y el porcentaje no pueden ser NULL.';
    END IF;

    -- Validar precio inicial
    IF precio_actual <= 0 THEN
        RAISE EXCEPTION
            'Error: el precio inicial debe ser mayor que cero.';
    END IF;

    -- Validar porcentaje permitido
    IF porcentaje < -50 OR porcentaje > 100 THEN
        RAISE EXCEPTION
            'Error: el porcentaje debe estar entre -50 y 100.';
    END IF;

    -- Calcular y redondear a dos decimales
    precio_resultante := ROUND(
        precio_actual * (1 + porcentaje / 100),
        2
    );

    -- Validar precio resultante
    IF precio_resultante <= 0 THEN
        RAISE EXCEPTION
            'Error: el precio resultante debe ser mayor que cero.';
    END IF;

    RETURN precio_resultante;
END;
$$;

-- Comprobar aumento del 10 por ciento: esperado 11.00
SELECT public.calcular_precio_ajustado(10::NUMERIC, 10::NUMERIC);

-- Comprobar reduccion del 50 por ciento: esperado 5.00
SELECT public.calcular_precio_ajustado(10::NUMERIC, -50::NUMERIC);
