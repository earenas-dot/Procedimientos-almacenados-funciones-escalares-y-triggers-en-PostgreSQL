# Procedimientos-almacenados-funciones-escalares-y-triggers-en-PostgreSQL

# Sistema de actualización y auditoría de precios en PostgreSQL

## 1. Descripción del proyecto

Este proyecto implementa lógica de negocio dentro de PostgreSQL para actualizar los precios de un catálogo de productos de manera controlada y mantener un registro automático de los cambios realizados.

Se utilizan tres objetos principales:

- **Función escalar:** calcula el precio ajustado según un porcentaje, sin modificar los datos de la base de datos.
- **Procedimiento almacenado:** valida los parámetros, comprueba que el producto exista y actualiza su precio utilizando la función escalar.
- **Trigger:** registra automáticamente los cambios efectivos de precio en una tabla de auditoría, incluyendo el precio anterior, el precio nuevo, la fecha y hora, y el usuario de la base de datos.

La actualización afecta únicamente al precio actual del producto. No se modifican precios históricos de facturas.

## 2. Tecnologías utilizadas

- PostgreSQL 18 (versión objetivo del proyecto).
- SQL y PL/pgSQL.
- DataGrip para ejecutar consultas y comprobar resultados.
- GitHub para almacenar y documentar el proyecto.

**Nota:** la versión indicada es la versión objetivo. La versión realmente utilizada debe verificarse en PostgreSQL mediante:

```sql
SELECT version();
```

## 3. Estructura del repositorio

El repositorio contiene los siguientes archivos:

```text
actualizacion-auditoria-precios/
├── README.md
└── sql/
    ├── 01_preparacion.sql
    ├── 02_funcion_escalar.sql
    ├── 03_procedimiento.sql
    ├── 04_trigger_y_funcion.sql
    └── 05_pruebas.sql
```

## 4. Preparación de la base de datos

El proyecto utiliza una base de datos propia de práctica con un catálogo de productos.

Cada producto tiene un identificador, un nombre y un precio actual positivo. Además, se crea una tabla de auditoría para conservar el historial de los cambios de precio.

Antes de comenzar, se debe crear o seleccionar una base de datos de práctica en PostgreSQL y conectarse a ella desde DataGrip.

## 5. Orden de ejecución

Ejecutar los archivos SQL en el siguiente orden:

1. `sql/01_preparacion.sql`: crea las tablas y los datos iniciales.
2. `sql/02_funcion_escalar.sql`: crea la función para calcular precios ajustados.
3. `sql/03_procedimiento.sql`: crea el procedimiento para aplicar los ajustes.
4. `sql/04_trigger_y_funcion.sql`: crea el trigger y su función de soporte para registrar los cambios.
5. `sql/05_pruebas.sql`: contiene las pruebas de funcionamiento y validación.

Los archivos deben ejecutarse en la misma base de datos y en el orden indicado. Para repetir las pruebas, se deben seguir las instrucciones de cada script y utilizar únicamente datos de práctica.

## 6. Reglas de negocio

La función escalar calcula el precio mediante la fórmula:

```text
precio_nuevo = precio_actual * (1 + porcentaje / 100)
```

El resultado se redondea a dos decimales.

Las reglas son:

- El precio inicial debe ser mayor que cero.
- El porcentaje debe estar entre -50 % y 100 %, incluidos ambos límites.
- Los parámetros no pueden ser NULL.
- El precio resultante, después del redondeo, debe ser mayor que cero.
- El producto debe existir para poder actualizar su precio.
- Cada cambio efectivo debe generar un registro de auditoría.
- Si el precio no cambia, no se debe generar un nuevo registro de auditoría.

## 7. Objetos implementados

| Objeto | Parámetros | Responsabilidad |
|---|---|---|
| Función escalar | Precio actual y porcentaje | Calcula y devuelve un precio ajustado sin modificar tablas. |
| Procedimiento almacenado | Identificador del producto y porcentaje | Valida y aplica el cambio de precio. |
| Trigger y función de soporte | Cambio de una fila del catálogo | Registra automáticamente los cambios efectivos de precio. |

## 8. Pruebas realizadas

El archivo `05_pruebas.sql` contempla los siguientes casos:

1. Cálculo de aumento del 10 % y reducción del 50 %.
2. Rechazo de parámetros inválidos en la función escalar.
3. Actualización válida mediante el procedimiento.
4. Rechazo de identificadores de producto inexistentes.
5. Rechazo de porcentajes inválidos sin cambios parciales.
6. Auditoría automática al realizar un UPDATE directo.
7. Ausencia de auditoría cuando el precio no cambia.
8. Reversión del precio y de la auditoría mediante ROLLBACK.

Los casos que producen errores deben ejecutarse de forma aislada para que un error no impida ejecutar las demás pruebas. Las evidencias se obtendrán de los resultados reales mostrados en DataGrip.

## 9. Evidencias y entrega

La entrega académica consiste en un único archivo PDF que incluye:

- Nombre del estudiante.
- Descripción de la base de datos utilizada.
- Enlace al presente repositorio.
- Tabla de responsabilidades de los objetos.
- Capturas de las consultas ejecutadas y sus resultados.
- Explicación de los ocho casos de prueba.
- Conclusión sobre la función escalar, el procedimiento almacenado y el trigger.

## 10. Conclusión

La función escalar permite calcular precios sin modificar datos, el procedimiento centraliza las validaciones y la actualización, y el trigger garantiza que los cambios efectivos queden registrados automáticamente.

Esta separación de responsabilidades facilita el mantenimiento, la comprobación de las reglas de negocio y la trazabilidad de las modificaciones del catálogo.
