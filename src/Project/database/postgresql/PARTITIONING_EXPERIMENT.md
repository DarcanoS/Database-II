# Experimento de Particionamiento Temporal - Instrucciones Completas

**Propósito:** Validar el impacto del particionamiento temporal en el rendimiento de consultas para el capítulo de Results del reporte técnico.

**Archivo relacionado en el reporte:** `src/Report_Latex/chapters/04_results.tex` - Sección 4.3

---

## 📋 Resumen del Experimento

### Objetivo
Medir la mejora de rendimiento al particionar la tabla `air_quality_reading` por rango temporal (mensual) vs. la tabla monolítica actual.

### Queries a comparar
- **Query 1:** Latest readings per station (dashboard en tiempo real)
- **Query 2:** Monthly historical averages (análisis de tendencias)

### Métricas a registrar
- Execution time (ms) - promedio de 5 ejecuciones
- Index usage (Index Scan vs Seq Scan)
- Partition pruning effectiveness (número de particiones descartadas)

---

## 🔧 Paso 1: Mediciones ANTES del Particionamiento

### 1.1. Conectar a PostgreSQL

```bash
# Opción Docker
docker exec -it <nombre_contenedor_postgres> psql -U <usuario> -d <base_de_datos>

# Opción Podman
podman exec -it <nombre_contenedor_postgres> psql -U <usuario> -d <base_de_datos>

# Ejemplo concreto (ajustar nombres según tu setup):
docker exec -it database-postgres-1 psql -U airquality_user -d airquality_db
```

### 1.2. Verificar estado actual de la tabla

```sql
-- Ver tamaño actual de la tabla
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables 
WHERE tablename = 'air_quality_reading';

-- Contar filas totales
SELECT COUNT(*) FROM air_quality_reading;

-- Ver distribución por estación y contaminante
SELECT 
  s.name AS station,
  p.name AS pollutant,
  COUNT(*) AS reading_count
FROM air_quality_reading aqr
JOIN station s ON aqr.station_id = s.id
JOIN pollutant p ON aqr.pollutant_id = p.id
GROUP BY s.name, p.name
ORDER BY s.name, p.name;
```

### 1.3. Ejecutar Query 1 (Latest Readings) - BASELINE

**Obtener el código de Query 1:**
```bash
# Ver el código SQL real desde el Workshop
cat /home/stivel/Documentos/UD/2025_3/Bases_II/Sierra/Repos/Database-II/src/Workshop_Latex/Codigos/query_1.tex
```

**Ejecutar con EXPLAIN ANALYZE:**
```sql
-- Ejemplo de Query 1 (ajustar según tu query_1.tex real)
EXPLAIN (ANALYZE, BUFFERS) 
WITH latest_readings AS (
  SELECT DISTINCT ON (aqr.station_id, aqr.pollutant_id)
    s.name AS station_name,
    s.city,
    p.name AS pollutant_name,
    aqr.value,
    aqr.aqi,
    aqr.datetime
  FROM air_quality_reading aqr
  JOIN station s ON aqr.station_id = s.id
  JOIN pollutant p ON aqr.pollutant_id = p.id
  WHERE s.city = 'Bogotá'
  ORDER BY aqr.station_id, aqr.pollutant_id, aqr.datetime DESC
)
SELECT * FROM latest_readings;
```

**Registrar resultados:**
- Planning Time: _____ ms
- Execution Time: _____ ms
- Índice usado: ___________________________
- Tipo de scan: Index Scan / Seq Scan / Index Only Scan

**Repetir 5 veces y promediar el Execution Time:**
```
Ejecución 1: _____ ms
Ejecución 2: _____ ms
Ejecución 3: _____ ms
Ejecución 4: _____ ms
Ejecución 5: _____ ms
PROMEDIO: _____ ms
```

### 1.4. Ejecutar Query 2 (Monthly Averages) - BASELINE

**Obtener el código de Query 2:**
```bash
cat /home/stivel/Documentos/UD/2025_3/Bases_II/Sierra/Repos/Database-II/src/Workshop_Latex/Codigos/query_2.tex
```

**Ejecutar con EXPLAIN ANALYZE:**
```sql
-- Ejemplo de Query 2 (ajustar según tu query_2.tex real)
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
  DATE_TRUNC('month', date) AS month,
  p.name AS pollutant_name,
  AVG(avg_value) AS avg_concentration,
  AVG(avg_aqi) AS avg_aqi,
  MAX(max_aqi) AS peak_aqi
FROM air_quality_daily_stats ads
JOIN station s ON ads.station_id = s.id
JOIN pollutant p ON ads.pollutant_id = p.id
WHERE s.city = 'Bogotá'
  AND date >= CURRENT_DATE - INTERVAL '3 years'
GROUP BY DATE_TRUNC('month', date), p.name
ORDER BY month DESC, pollutant_name;
```

**Registrar resultados (mismo formato que Query 1):**
- Planning Time: _____ ms
- Execution Time: _____ ms
- Índice usado: ___________________________
- Tipo de scan: Index Scan / Seq Scan

**Repetir 5 veces y promediar:**
```
Ejecución 1: _____ ms
Ejecución 2: _____ ms
Ejecución 3: _____ ms
Ejecución 4: _____ ms
Ejecución 5: _____ ms
PROMEDIO: _____ ms
```

---

## 🛠️ Paso 2: Implementar Particionamiento Temporal

### 2.1. Crear archivo de script SQL

**Ubicación:** `src/Project/database/postgresql/partitions.sql`

**Contenido del archivo:**

```sql
-- ============================================================================
-- PARTICIONAMIENTO TEMPORAL DE air_quality_reading
-- Experimento para validar mejoras de rendimiento
-- Fecha: [COMPLETAR AL EJECUTAR]
-- ============================================================================

-- IMPORTANTE: Este script DESTRUYE Y RECREA la tabla air_quality_reading
-- Asegurarse de tener backup antes de ejecutar

BEGIN;

-- Paso 1: Backup de datos existentes
CREATE TABLE air_quality_reading_backup AS 
SELECT * FROM air_quality_reading;

-- Verificar backup
SELECT COUNT(*) FROM air_quality_reading_backup;
-- Esperado: ~85,000 filas

-- Paso 2: Eliminar tabla original
DROP TABLE air_quality_reading CASCADE;

-- Paso 3: Recrear como tabla particionada por rango temporal (mensual)
CREATE TABLE air_quality_reading (
  id integer GENERATED ALWAYS AS IDENTITY,
  station_id integer NOT NULL,
  pollutant_id integer NOT NULL,
  datetime timestamp with time zone NOT NULL,
  value double precision NOT NULL,
  aqi integer,
  PRIMARY KEY (id, datetime)  -- datetime debe estar en PK para particionamiento
) PARTITION BY RANGE (datetime);

-- Paso 4: Crear particiones mensuales para 3 años (2022-2024)
-- Ajustar fechas según el rango real de tus datos

-- Año 2022
CREATE TABLE air_quality_reading_2022_01 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2022-01-01') TO ('2022-02-01');
CREATE TABLE air_quality_reading_2022_02 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2022-02-01') TO ('2022-03-01');
CREATE TABLE air_quality_reading_2022_03 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2022-03-01') TO ('2022-04-01');
CREATE TABLE air_quality_reading_2022_04 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2022-04-01') TO ('2022-05-01');
CREATE TABLE air_quality_reading_2022_05 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2022-05-01') TO ('2022-06-01');
CREATE TABLE air_quality_reading_2022_06 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2022-06-01') TO ('2022-07-01');
CREATE TABLE air_quality_reading_2022_07 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2022-07-01') TO ('2022-08-01');
CREATE TABLE air_quality_reading_2022_08 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2022-08-01') TO ('2022-09-01');
CREATE TABLE air_quality_reading_2022_09 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2022-09-01') TO ('2022-10-01');
CREATE TABLE air_quality_reading_2022_10 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2022-10-01') TO ('2022-11-01');
CREATE TABLE air_quality_reading_2022_11 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2022-11-01') TO ('2022-12-01');
CREATE TABLE air_quality_reading_2022_12 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2022-12-01') TO ('2023-01-01');

-- Año 2023
CREATE TABLE air_quality_reading_2023_01 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2023-01-01') TO ('2023-02-01');
CREATE TABLE air_quality_reading_2023_02 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2023-02-01') TO ('2023-03-01');
CREATE TABLE air_quality_reading_2023_03 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2023-03-01') TO ('2023-04-01');
CREATE TABLE air_quality_reading_2023_04 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2023-04-01') TO ('2023-05-01');
CREATE TABLE air_quality_reading_2023_05 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2023-05-01') TO ('2023-06-01');
CREATE TABLE air_quality_reading_2023_06 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2023-06-01') TO ('2023-07-01');
CREATE TABLE air_quality_reading_2023_07 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2023-07-01') TO ('2023-08-01');
CREATE TABLE air_quality_reading_2023_08 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2023-08-01') TO ('2023-09-01');
CREATE TABLE air_quality_reading_2023_09 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2023-09-01') TO ('2023-10-01');
CREATE TABLE air_quality_reading_2023_10 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2023-10-01') TO ('2023-11-01');
CREATE TABLE air_quality_reading_2023_11 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2023-11-01') TO ('2023-12-01');
CREATE TABLE air_quality_reading_2023_12 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2023-12-01') TO ('2024-01-01');

-- Año 2024
CREATE TABLE air_quality_reading_2024_01 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE air_quality_reading_2024_02 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
CREATE TABLE air_quality_reading_2024_03 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');
CREATE TABLE air_quality_reading_2024_04 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2024-04-01') TO ('2024-05-01');
CREATE TABLE air_quality_reading_2024_05 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2024-05-01') TO ('2024-06-01');
CREATE TABLE air_quality_reading_2024_06 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2024-06-01') TO ('2024-07-01');
CREATE TABLE air_quality_reading_2024_07 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2024-07-01') TO ('2024-08-01');
CREATE TABLE air_quality_reading_2024_08 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2024-08-01') TO ('2024-09-01');
CREATE TABLE air_quality_reading_2024_09 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2024-09-01') TO ('2024-10-01');
CREATE TABLE air_quality_reading_2024_10 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2024-10-01') TO ('2024-11-01');
CREATE TABLE air_quality_reading_2024_11 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2024-11-01') TO ('2024-12-01');
CREATE TABLE air_quality_reading_2024_12 PARTITION OF air_quality_reading
  FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');

-- Paso 5: Crear índices en la tabla padre (se propagan automáticamente a todas las particiones)
CREATE INDEX idx_reading_composite ON air_quality_reading 
  (station_id, pollutant_id, datetime DESC);

CREATE INDEX idx_reading_station_id ON air_quality_reading (station_id);
CREATE INDEX idx_reading_pollutant_id ON air_quality_reading (pollutant_id);
CREATE INDEX idx_reading_datetime ON air_quality_reading (datetime DESC);

-- Paso 6: Recrear foreign keys que se perdieron con CASCADE
ALTER TABLE air_quality_reading
  ADD CONSTRAINT fk_station 
  FOREIGN KEY (station_id) REFERENCES station(id) ON DELETE CASCADE;

ALTER TABLE air_quality_reading
  ADD CONSTRAINT fk_pollutant
  FOREIGN KEY (pollutant_id) REFERENCES pollutant(id) ON DELETE RESTRICT;

-- Paso 7: Restaurar datos desde backup
-- NOTA: PostgreSQL automáticamente los distribuirá a las particiones correctas según datetime
INSERT INTO air_quality_reading (id, station_id, pollutant_id, datetime, value, aqi)
SELECT id, station_id, pollutant_id, datetime, value, aqi 
FROM air_quality_reading_backup;

-- Verificar que la cantidad de filas es igual al backup
SELECT COUNT(*) FROM air_quality_reading;
-- Esperado: ~85,000 filas

-- Paso 8: Ver distribución de datos por partición
SELECT 
  tableoid::regclass AS partition_name, 
  COUNT(*) AS row_count,
  MIN(datetime) AS min_date,
  MAX(datetime) AS max_date
FROM air_quality_reading 
GROUP BY tableoid 
ORDER BY partition_name;

COMMIT;

-- Opcional: Eliminar backup si todo funcionó correctamente
-- DROP TABLE air_quality_reading_backup;
```

### 2.2. Ejecutar el script de particionamiento

**ADVERTENCIA:** Este script destruye y recrea la tabla. Asegúrate de tener un backup completo de la base de datos antes de continuar.

```bash
# Opción 1: Ejecutar desde archivo
docker exec -i <contenedor_postgres> psql -U <usuario> -d <database> < src/Project/database/postgresql/partitions.sql

# Opción 2: Ejecutar paso a paso (más seguro)
docker exec -it <contenedor_postgres> psql -U <usuario> -d <database>
# Luego copiar y pegar secciones del script una por una
```

### 2.3. Verificar que el particionamiento funcionó

```sql
-- Ver todas las particiones creadas
SELECT 
  inhrelid::regclass AS partition_name,
  pg_get_expr(relpartbound, inhrelid) AS partition_bounds
FROM pg_inherits
JOIN pg_class ON pg_inherits.inhrelid = pg_class.oid
WHERE inhparent = 'air_quality_reading'::regclass
ORDER BY partition_name;

-- Ver distribución de datos
SELECT tableoid::regclass, COUNT(*) 
FROM air_quality_reading 
GROUP BY tableoid;

-- Ver índices en cada partición
SELECT 
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename LIKE 'air_quality_reading%'
ORDER BY tablename, indexname;
```

---

## 📊 Paso 3: Mediciones DESPUÉS del Particionamiento

### 3.1. Ejecutar Query 1 - CON PARTICIONAMIENTO

```sql
-- Misma query que en Paso 1.3, pero ahora PostgreSQL debería hacer partition pruning
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) 
WITH latest_readings AS (
  SELECT DISTINCT ON (aqr.station_id, aqr.pollutant_id)
    s.name AS station_name,
    s.city,
    p.name AS pollutant_name,
    aqr.value,
    aqr.aqi,
    aqr.datetime
  FROM air_quality_reading aqr
  JOIN station s ON aqr.station_id = s.id
  JOIN pollutant p ON aqr.pollutant_id = p.id
  WHERE s.city = 'Bogotá'
  ORDER BY aqr.station_id, aqr.pollutant_id, aqr.datetime DESC
)
SELECT * FROM latest_readings;
```

**Registrar resultados:**
- Planning Time: _____ ms
- Execution Time: _____ ms
- Índice usado: ___________________________
- Particiones escaneadas: _____ (buscar "Partitions removed: X" en el output)
- Tipo de scan: Index Scan / Seq Scan

**Repetir 5 veces y promediar:**
```
Ejecución 1: _____ ms
Ejecución 2: _____ ms
Ejecución 3: _____ ms
Ejecución 4: _____ ms
Ejecución 5: _____ ms
PROMEDIO: _____ ms
```

### 3.2. Ejecutar Query 2 - CON PARTICIONAMIENTO

```sql
-- Misma query que en Paso 1.4
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT 
  DATE_TRUNC('month', date) AS month,
  p.name AS pollutant_name,
  AVG(avg_value) AS avg_concentration,
  AVG(avg_aqi) AS avg_aqi,
  MAX(max_aqi) AS peak_aqi
FROM air_quality_daily_stats ads
JOIN station s ON ads.station_id = s.id
JOIN pollutant p ON ads.pollutant_id = p.id
WHERE s.city = 'Bogotá'
  AND date >= CURRENT_DATE - INTERVAL '3 years'
GROUP BY DATE_TRUNC('month', date), p.name
ORDER BY month DESC, pollutant_name;
```

**Registrar resultados (mismo formato que Query 1):**
- Planning Time: _____ ms
- Execution Time: _____ ms
- Índice usado: ___________________________
- Particiones escaneadas: _____
- Tipo de scan: Index Scan / Seq Scan

**Repetir 5 veces y promediar:**
```
Ejecución 1: _____ ms
Ejecución 2: _____ ms
Ejecución 3: _____ ms
Ejecución 4: _____ ms
Ejecución 5: _____ ms
PROMEDIO: _____ ms
```

---

## 📈 Paso 4: Análisis de Resultados

### 4.1. Calcular mejora porcentual

```
Query 1:
  Baseline: _____ ms (promedio)
  Partitioned: _____ ms (promedio)
  Mejora absoluta: _____ ms
  Mejora porcentual: ( (Baseline - Partitioned) / Baseline ) × 100 = _____%

Query 2:
  Baseline: _____ ms (promedio)
  Partitioned: _____ ms (promedio)
  Mejora absoluta: _____ ms
  Mejora porcentual: ( (Baseline - Partitioned) / Baseline ) × 100 = _____%
```

### 4.2. Completar Tabla 4.3 en el reporte

Abrir `src/Report_Latex/chapters/04_results.tex` y buscar `\label{tab:partitioning_results}`.

Reemplazar los "TBD" con los valores calculados arriba.

### 4.3. Notas de interpretación

**Si la mejora es < 10%:**
- Con ~85K filas, el beneficio del particionamiento es modesto
- El valor real está en la escalabilidad futura (cuando haya millones de filas)
- Documentar que el experimento valida la estrategia, pero el beneficio crecerá con el tiempo

**Si la mejora es 10-30%:**
- Beneficio significativo debido a partition pruning
- PostgreSQL está descartando particiones irrelevantes
- Documentar el número exacto de particiones eliminadas

**Si la mejora es > 30%:**
- Excelente resultado, probablemente combinado con mejor cache locality
- Validar que el plan de ejecución muestra "Index Scan" en lugar de "Seq Scan"

---

## 🔄 Paso 5: Rollback (Opcional)

Si necesitas revertir el particionamiento y volver a la tabla monolítica:

```sql
BEGIN;

-- Recrear tabla original desde backup
CREATE TABLE air_quality_reading_restored AS 
SELECT * FROM air_quality_reading_backup;

-- Eliminar tabla particionada
DROP TABLE air_quality_reading CASCADE;

-- Renombrar tabla restaurada
ALTER TABLE air_quality_reading_restored RENAME TO air_quality_reading;

-- Recrear índices originales
CREATE INDEX idx_air_quality_reading_composite 
  ON air_quality_reading (station_id, pollutant_id, datetime);

CREATE INDEX idx_air_quality_reading_station_id 
  ON air_quality_reading (station_id);

CREATE INDEX idx_air_quality_reading_pollutant_id 
  ON air_quality_reading (pollutant_id);

CREATE INDEX idx_air_quality_reading_datetime 
  ON air_quality_reading (datetime);

-- Recrear foreign keys
ALTER TABLE air_quality_reading
  ADD CONSTRAINT fk_station 
  FOREIGN KEY (station_id) REFERENCES station(id) ON DELETE CASCADE;

ALTER TABLE air_quality_reading
  ADD CONSTRAINT fk_pollutant
  FOREIGN KEY (pollutant_id) REFERENCES pollutant(id) ON DELETE RESTRICT;

COMMIT;
```

---

## ✅ Checklist Final

- [ ] Mediciones baseline (sin particionar) completadas para Q1 y Q2
- [ ] Script `partitions.sql` creado y revisado
- [ ] Backup de base de datos completo realizado
- [ ] Particionamiento aplicado exitosamente
- [ ] Verificada distribución de datos en particiones
- [ ] Mediciones post-particionamiento completadas para Q1 y Q2
- [ ] Mejora porcentual calculada
- [ ] Tabla 4.3 en `04_results.tex` actualizada con valores reales
- [ ] Análisis de partition pruning documentado (número de particiones eliminadas)
- [ ] Decisión tomada sobre mantener o revertir el particionamiento

---

## 📚 Referencias Útiles

- PostgreSQL Partitioning Documentation: https://www.postgresql.org/docs/current/ddl-partitioning.html
- EXPLAIN ANALYZE Guide: https://www.postgresql.org/docs/current/using-explain.html
- Partition Pruning: https://www.postgresql.org/docs/current/ddl-partitioning.html#DDL-PARTITION-PRUNING
