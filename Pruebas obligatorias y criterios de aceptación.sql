
-- =========================================================
-- PROYECTO: ACTUALIZACION Y AUDITORIA DE PRECIOS
-- ARCHIVO: 05_pruebas.sql
-- Base de datos: semana9
-- Requiere los archivos 01, 02, 03 y 04 ejecutados.
-- =========================================================


-- =========================================================
-- CASO 1: FUNCION ESCALAR
-- Proposito: comprobar aumento y reduccion.
-- Esperado: 11.00 y 5.00.
-- =========================================================

SELECT public.calcular_precio_ajustado(
    10::NUMERIC, 10::NUMERIC
) AS aumento_10_por_ciento;

SELECT public.calcular_precio_ajustado(
    10::NUMERIC, -50::NUMERIC
) AS reduccion_50_por_ciento;


-- =========================================================
-- CASO 2: FUNCION - ENTRADAS INVALIDAS
-- Proposito: comprobar validaciones.
-- Ejecutar cada SELECT por separado.
-- Esperado: error en cada prueba.
-- =========================================================

-- 2A: precio NULL
SELECT public.calcular_precio_ajustado(
    NULL::NUMERIC, 10::NUMERIC
);

-- 2B: precio cero
SELECT public.calcular_precio_ajustado(
    0::NUMERIC, 10::NUMERIC
);

-- 2C: precio negativo
SELECT public.calcular_precio_ajustado(
    -10::NUMERIC, 10::NUMERIC
);

-- 2D: porcentaje menor que -50
SELECT public.calcular_precio_ajustado(
    10::NUMERIC, -51::NUMERIC
);

-- 2E: porcentaje mayor que 100
SELECT public.calcular_precio_ajustado(
    10::NUMERIC, 101::NUMERIC
);

-- 2F: resultado redondeado menor o igual a cero
SELECT public.calcular_precio_ajustado(
    0.01::NUMERIC, -50::NUMERIC
);


-- =========================================================
-- CASO 3: PROCEDIMIENTO - CAMBIO VALIDO
-- Proposito: aumentar el precio del producto 1 en 10%.
-- Esperado: cambia el producto 1 y se crea auditoria.
-- El producto 2 permanece sin cambios.
-- =========================================================

-- Estado antes.
SELECT id_producto, nombre, precio
FROM public.productos
WHERE id_producto IN (1, 2)
ORDER BY id_producto;

SELECT *
FROM public.auditoria_precios
WHERE id_producto = 1
ORDER BY id_auditoria;

-- Aplicar cambio.
CALL public.aplicar_ajuste_precio(1, 10::NUMERIC);

-- Estado despues.
SELECT id_producto, nombre, precio
FROM public.productos
WHERE id_producto IN (1, 2)
ORDER BY id_producto;

-- Auditoria.
SELECT *
FROM public.auditoria_precios
WHERE id_producto = 1
ORDER BY id_auditoria;


-- =========================================================
-- CASO 4: PROCEDIMIENTO - IDENTIFICADOR INEXISTENTE
-- Proposito: rechazar un producto inexistente.
-- Datos: ID -9999, porcentaje 10.
-- Esperado: error y ninguna modificacion.
-- Ejecutar el CALL por separado.
-- =========================================================

-- Estado antes.
SELECT id_producto, nombre, precio
FROM public.productos
ORDER BY id_producto;

SELECT COUNT(*) AS auditorias_antes
FROM public.auditoria_precios;

-- Debe generar un error.
CALL public.aplicar_ajuste_precio(-9999, 10::NUMERIC);

-- Ejecutar estas consultas despues del error.
SELECT id_producto, nombre, precio
FROM public.productos
ORDER BY id_producto;

SELECT COUNT(*) AS auditorias_despues
FROM public.auditoria_precios;


-- =========================================================
-- CASO 5: PROCEDIMIENTO - PORCENTAJE INVALIDO
-- Proposito: rechazar un porcentaje de 150%.
-- Datos: producto 1, porcentaje 150.
-- Esperado: error y ausencia de cambios parciales.
-- Ejecutar el CALL por separado.
-- =========================================================

-- Estado antes.
SELECT id_producto, nombre, precio
FROM public.productos
WHERE id_producto = 1;

SELECT COUNT(*) AS auditorias_antes
FROM public.auditoria_precios;

-- Debe generar un error.
CALL public.aplicar_ajuste_precio(1, 150::NUMERIC);

-- Ejecutar estas consultas despues del error.
SELECT id_producto, nombre, precio
FROM public.productos
WHERE id_producto = 1;

SELECT COUNT(*) AS auditorias_despues
FROM public.auditoria_precios;


-- =========================================================
-- CASO 6: TRIGGER - UPDATE DIRECTO
-- Proposito: comprobar auditoria sin utilizar CALL.
-- Datos: producto 2, aumento directo de 1.00.
-- Esperado: cambio de precio y auditoria automatica.
-- =========================================================

SELECT id_producto, nombre, precio
FROM public.productos
WHERE id_producto = 2;

UPDATE public.productos
SET precio = precio + 1.00
WHERE id_producto = 2;

SELECT id_producto, nombre, precio
FROM public.productos
WHERE id_producto = 2;

SELECT *
FROM public.auditoria_precios
WHERE id_producto = 2
ORDER BY id_auditoria;


-- =========================================================
-- CASO 7: TRIGGER - PRECIO SIN CAMBIO
-- Proposito: comprobar que no se genere auditoria adicional.
-- Datos: producto 2, mismo precio.
-- Esperado: conteos iguales.
-- =========================================================

SELECT COUNT(*) AS auditorias_antes
FROM public.auditoria_precios
WHERE id_producto = 2;

UPDATE public.productos
SET precio = precio
WHERE id_producto = 2;

SELECT COUNT(*) AS auditorias_despues
FROM public.auditoria_precios
WHERE id_producto = 2;


-- =========================================================
-- CASO 8: INTEGRIDAD TRANSACCIONAL
-- Proposito: comprobar que ROLLBACK revierta los cambios.
-- Datos: producto 3, aumento del 10%.
-- Esperado: precio y auditoria restaurados.
-- Ejecutar el bloque completo.
-- =========================================================

BEGIN;

-- Estado antes.
SELECT id_producto, nombre, precio
FROM public.productos
WHERE id_producto = 3;

SELECT COUNT(*) AS auditorias_antes
FROM public.auditoria_precios
WHERE id_producto = 3;

-- Aplicar ajuste.
CALL public.aplicar_ajuste_precio(3, 10::NUMERIC);

-- Comprobar cambio dentro de la transaccion.
SELECT id_producto, nombre, precio
FROM public.productos
WHERE id_producto = 3;

SELECT *
FROM public.auditoria_precios
WHERE id_producto = 3
ORDER BY id_auditoria;

-- Revertir cambio y auditoria.
ROLLBACK;

-- Comprobar estado restaurado.
SELECT id_producto, nombre, precio
FROM public.productos
WHERE id_producto = 3;

SELECT COUNT(*) AS auditorias_despues
FROM public.auditoria_precios
WHERE id_producto = 3;

SELECT
    n.nspname AS esquema,
    p.proname AS nombre,
    pg_get_function_identity_arguments(p.oid) AS parametros
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname ILIKE '%calcular%precio%';
