# Cambios Necesarios en el Proyecto - Validación del Abstract

**Fecha de análisis:** 8 de diciembre de 2025  
**Documento validado:** `src/Report_Latex/chapters/00_i_abstract.tex`

---

## ✅ Resumen de Validación

Se validaron las afirmaciones del abstract actualizado contra la implementación actual del proyecto. A continuación, se presentan los hallazgos organizados por requerimientos del proyecto.

---

## 📋 Validación por Requerimientos del Proyecto

### 1. ✅ Fast query execution in a big data context

**Estado:** **IMPLEMENTADO PARCIALMENTE** - Requiere mejoras

**Lo que está implementado:**
- ✅ Índices en PostgreSQL definidos en `init_schema.sql`:
  - `idx_air_quality_reading_composite` (station_id, pollutant_id, datetime)
  - `idx_air_quality_daily_stats_composite` (station_id, pollutant_id, date)
  - Índices individuales para station, pollutant, datetime
- ✅ Tabla de agregación diaria `air_quality_daily_stats` para consultas analíticas

**Lo que FALTA (mencionado en el abstract):**
- ❌ **Particionamiento temporal** de la tabla `air_quality_reading`
  - El abstract menciona: "temporal partitioning"
  - La tabla actual NO está particionada
  - **Acción requerida:** Implementar particionamiento por rango de fechas (mensual o semanal)

- ❌ **Vistas materializadas**
  - El abstract menciona: "materialized views where appropriate"
  - No hay vistas materializadas en el schema actual
  - **Acción requerida:** Crear vistas materializadas para consultas analíticas frecuentes (ej: estadísticas por ciudad, promedios mensuales, etc.)

**Archivos a modificar:**
- `src/Project/database/postgresql/init_schema.sql` - Agregar particionamiento y vistas materializadas
- Posiblemente crear `src/Project/database/postgresql/partitions.sql`
- Posiblemente crear `src/Project/database/postgresql/materialized_views.sql`

---

### 2. ✅ Constant ingestion of data throughout the day

**Estado:** **COMPLETAMENTE IMPLEMENTADO**

**Lo que está implementado:**
- ✅ Servicio de ingestion periódica en `src/Project/ingestion/`
- ✅ Adaptador para API de AQICN (tiempo real) - `app/providers/aqicn_adapter.py`
- ✅ Adaptador para archivos CSV históricos - `app/providers/historical_csv_adapter.py`
- ✅ Patrón Adapter implementado correctamente
- ✅ Documentación completa sobre ingestion periódica

**Alineación con el abstract:**
- ✅ "periodic Python ingestion pipeline" - **CONFIRMADO**
- ✅ "normalizes heterogeneous payloads" - **CONFIRMADO**
- ✅ "batched inserts aligned with temporal partitions" - **PARCIAL** (los inserts por lotes existen, pero las particiones temporales no)

**Sin cambios necesarios en este aspecto**, excepto que una vez implementado el particionamiento temporal, ajustar la lógica de inserción para que respete las particiones.

---

### 3. ✅ Business intelligence module for managerial insights

**Estado:** **IMPLEMENTADO PARCIALMENTE** - Funcional pero mejorable

**Lo que está implementado:**
- ✅ Sistema de reportes en `backend/app/api/v1/endpoints/reports.py`
- ✅ Repositorio de reportes `backend/app/repositories/report_repository.py`
- ✅ Tabla `report` en PostgreSQL para metadata de reportes
- ✅ Dashboards por rol:
  - `CitizenDashboardView.vue` - Dashboard para ciudadanos
  - `ResearcherDashboardView.vue` - Dashboard para investigadores
  - `AdminDashboardView.vue` - Dashboard administrativo
- ✅ Tabla de estadísticas diarias `air_quality_daily_stats` para análisis

**Lo que FALTA (para considerarse "módulo BI completo"):**
- ⚠️ **Generación real de reportes**
  - Actualmente solo se crea metadata, no archivos reales
  - **Acción sugerida (OPCIONAL):** Implementar generación de PDF/CSV con gráficos
  - **Nota:** Esto podría considerarse "Future Work" si no está en los requisitos estrictos

- ⚠️ **Queries analíticas optimizadas**
  - Con las vistas materializadas sugeridas en el punto 1, el módulo BI sería más robusto
  - **Acción requerida:** Implementar las vistas materializadas mencionadas anteriormente

**Archivos a considerar:**
- Si se decide implementar generación real de reportes: `src/Project/backend/app/services/reporting/` (ya existe el directorio)

---

### 4. ✅ Multi-location data storage and access

**Estado:** **COMPLETAMENTE IMPLEMENTADO**

**Lo que está implementado:**
- ✅ Tabla `station` con campos de geolocalización (latitude, longitude, city, country)
- ✅ Extensión PostGIS habilitada
- ✅ Tabla `map_region` con geometrías MultiPolygon
- ✅ Índices geoespaciales: `idx_map_region_geom`, `idx_station_location`
- ✅ Soporte para múltiples estaciones de Bogotá en datos de muestra
- ✅ API permite filtrar por ciudad y estación

**Alineación con el abstract:**
- ✅ "integrating periodic air-quality data from multiple providers" - **CONFIRMADO**
- ✅ Capacidad multi-ubicación implementada

**Sin cambios necesarios.**

---

### 5. ✅ Recommendation system for products or services

**Estado:** **COMPLETAMENTE IMPLEMENTADO**

**Lo que está implementado:**
- ✅ Sistema de recomendaciones basado en reglas (rule-based)
- ✅ Patrón Factory en `backend/app/services/recommendation_service/factory.py`
- ✅ Lógica de recomendaciones por niveles de AQI:
  - Good (0-50)
  - Moderate (51-100)
  - Unhealthy for Sensitive (101-150)
  - Unhealthy (151-200)
  - Very Unhealthy (201-300)
  - Hazardous (300+)
- ✅ Tablas `recommendation` y `product_recommendation` en PostgreSQL
- ✅ Recomendaciones de productos informativos (máscaras, monitores, purificadores)
- ✅ Servicio `RecommendationService` en `backend/app/services/recommendation_generation_service.py`

**Alineación con el abstract:**
- ✅ "rule-based [...] maps AQI thresholds and basic user metadata to actionable health guidance" - **CONFIRMADO**
- ✅ No es e-commerce, son recomendaciones informativas - **CONFIRMADO**

**Sin cambios necesarios.**

---

### 6. ✅ High availability and scalability

**Estado:** **DISEÑO CONTEMPLADO, NO IMPLEMENTADO OPERACIONALMENTE**

**Lo que está implementado (diseño/arquitectura):**
- ✅ Arquitectura basada en contenedores (Docker/Podman)
- ✅ Separación de concerns (backend, frontend, database, ingestion)
- ✅ Patrón Repository para abstracción de datos
- ✅ Índices y esquema optimizado para rendimiento

**Lo que NO está implementado (pero es aceptable como "Future Work"):**
- ❌ Load balancing
- ❌ Replicación de base de datos
- ❌ Caché distribuido
- ❌ Multi-región deployment
- ❌ Monitoreo y alertas operacionales (Prometheus, Grafana)

**Nota:** Según las instrucciones, esto puede quedar como "design considerations" en el abstract, que es exactamente como está redactado. No requiere implementación inmediata a menos que sea requisito explícito del curso.

**Sin cambios necesarios para el MVP del curso.**

---

## 🔍 Validación de Componentes Específicos del Abstract

### ✅ "PostgreSQL-based analytical schema"
**Estado:** IMPLEMENTADO
- Schema completo en `init_schema.sql`

### ❌ "temporal partitioning"
**Estado:** NO IMPLEMENTADO
- **Acción requerida:** Ver sección 1

### ❌ "materialized views where appropriate"
**Estado:** NO IMPLEMENTADO
- **Acción requerida:** Ver sección 1

### ✅ "lightweight NoSQL store for user preferences and dashboard configuration"
**Estado:** COMPLETAMENTE IMPLEMENTADO
- MongoDB con colecciones `user_preferences` y `dashboard_configs`
- Esquemas de validación en `mongo_init.js`
- Índices en `mongo_indexes.js`

### ✅ "periodic Python ingestion pipeline"
**Estado:** COMPLETAMENTE IMPLEMENTADO
- Ver sección 2

### ✅ "REST API"
**Estado:** COMPLETAMENTE IMPLEMENTADO
- FastAPI con endpoints en `backend/app/api/v1/endpoints/`
- Endpoints para: auth, stations, air_quality, recommendations, reports, settings, admin

### ✅ "rule-based recommendation logic"
**Estado:** COMPLETAMENTE IMPLEMENTADO
- Ver sección 5

### ⚠️ "near real-time dashboards"
**Estado:** IMPLEMENTADO (con consideración)
- Los dashboards existen y son funcionales
- La "cercanía a tiempo real" depende de la frecuencia de ingestion (cada 10 min según docs)
- **Acción sugerida:** Asegurar que el frontend actualice datos periódicamente (polling o WebSockets)
- **Nota:** Si ya existe polling en el frontend, marcar como COMPLETO

### ✅ "analytical reporting"
**Estado:** IMPLEMENTADO
- Ver sección 3

---

## 📝 Resumen de Cambios Requeridos (Prioridad Alta)

### 🔴 CRÍTICOS (mencionados explícitamente en el abstract)

1. **Implementar Particionamiento Temporal en `air_quality_reading`**
   - **Archivo:** `src/Project/database/postgresql/init_schema.sql`
   - **Estrategia sugerida:** Particionamiento por rango mensual o semanal
   - **Impacto:** Alto - mencionado directamente en abstract
   - **Ejemplo de código necesario:**
     ```sql
     -- Convertir air_quality_reading a tabla particionada
     CREATE TABLE air_quality_reading (
       id integer GENERATED ALWAYS AS IDENTITY,
       station_id integer NOT NULL REFERENCES station (id),
       pollutant_id integer NOT NULL REFERENCES pollutant (id),
       datetime timestamp with time zone NOT NULL,
       value double precision NOT NULL,
       aqi integer,
       PRIMARY KEY (id, datetime)
     ) PARTITION BY RANGE (datetime);
     
     -- Crear particiones mensuales (ejemplo)
     CREATE TABLE air_quality_reading_2024_12 
       PARTITION OF air_quality_reading
       FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');
     -- ... más particiones
     ```

2. **Implementar Vistas Materializadas**
   - **Archivo:** Crear `src/Project/database/postgresql/materialized_views.sql`
   - **Ejemplos necesarios:**
     ```sql
     -- Vista materializada para estadísticas por ciudad
     CREATE MATERIALIZED VIEW mv_city_air_quality_stats AS
     SELECT 
       s.city,
       p.name as pollutant,
       DATE(aqr.datetime) as date,
       AVG(aqr.value) as avg_value,
       AVG(aqr.aqi) as avg_aqi,
       MAX(aqr.aqi) as max_aqi,
       MIN(aqr.aqi) as min_aqi
     FROM air_quality_reading aqr
     JOIN station s ON aqr.station_id = s.id
     JOIN pollutant p ON aqr.pollutant_id = p.id
     GROUP BY s.city, p.name, DATE(aqr.datetime);
     
     CREATE INDEX ON mv_city_air_quality_stats (city, date DESC);
     
     -- Vista materializada para últimas 24h por estación
     CREATE MATERIALIZED VIEW mv_station_latest_readings AS
     SELECT DISTINCT ON (station_id, pollutant_id)
       station_id,
       pollutant_id,
       datetime,
       value,
       aqi
     FROM air_quality_reading
     WHERE datetime > NOW() - INTERVAL '24 hours'
     ORDER BY station_id, pollutant_id, datetime DESC;
     
     CREATE INDEX ON mv_station_latest_readings (station_id, pollutant_id);
     ```

3. **Ajustar Ingestion para usar Particiones**
   - **Archivo:** `src/Project/ingestion/app/services/ingestion_service.py`
   - **Acción:** Asegurar que los inserts especifiquen la partición correcta o que PostgreSQL lo maneje automáticamente

---

### 🟡 RECOMENDADOS (mejoran la robustez del sistema)

4. **Implementar Refresh de Vistas Materializadas**
   - Crear un script/servicio que ejecute `REFRESH MATERIALIZED VIEW CONCURRENTLY`
   - Puede ser un cron job o parte del servicio de ingestion

5. **Validar Polling en Frontend**
   - **Archivo:** `src/Project/frontend/src/views/CitizenDashboardView.vue` (y otros dashboards)
   - **Acción:** Verificar que los dashboards actualicen datos periódicamente
   - Si no existe, implementar polling cada 1-2 minutos

---

### 🟢 OPCIONALES (Future Work aceptable)

6. Generación real de archivos de reportes (PDF/CSV)
7. Sistema de caché (Redis)
8. WebSockets para actualizaciones en tiempo real
9. Replicación de base de datos
10. Herramientas externas de BI (Grafana, Metabase)

---

## ✅ Componentes que NO requieren cambios

- ✅ Schema de PostgreSQL base
- ✅ Índices existentes
- ✅ MongoDB y colecciones NoSQL
- ✅ Sistema de ingestion periódica
- ✅ Sistema de recomendaciones
- ✅ API REST
- ✅ Frontend con dashboards por rol
- ✅ Sistema de autenticación
- ✅ Soporte multi-ubicación
- ✅ PostGIS y datos geoespaciales

---

## 📊 Conclusión

**Nivel de implementación actual:** **~80-85%** de lo descrito en el abstract

**Cambios CRÍTICOS necesarios para alinearse al 100% con el abstract:**
1. Particionamiento temporal
2. Vistas materializadas

**Estimación de esfuerzo:**
- Particionamiento: 2-4 horas (incluye migración de datos si existen)
- Vistas materializadas: 2-3 horas
- Scripts de refresh: 1 hora
- Ajuste de ingestion: 1 hora
- Testing: 2 horas

**Total estimado:** 8-12 horas de desarrollo

**Recomendación:** Implementar los cambios CRÍTICOS (particionamiento y vistas materializadas) para que el abstract esté 100% respaldado por el código. Los cambios RECOMENDADOS y OPCIONALES pueden dejarse como "Future Work" según el tiempo disponible y los requisitos estrictos del curso.

---

## 📎 Archivos a Crear/Modificar

### Archivos a MODIFICAR:
1. `src/Project/database/postgresql/init_schema.sql` - Agregar particionamiento
2. `src/Project/ingestion/app/services/ingestion_service.py` - Ajustar para particiones

### Archivos a CREAR:
1. `src/Project/database/postgresql/materialized_views.sql` - Vistas materializadas
2. `src/Project/database/postgresql/refresh_views.sql` - Script de refresh
3. `src/Project/database/scripts/refresh_materialized_views.py` - Automatización de refresh

### Archivos a VALIDAR:
1. `src/Project/frontend/src/views/*DashboardView.vue` - Confirmar polling
2. `src/Project/backend/app/repositories/*.py` - Ajustar queries para usar vistas materializadas donde sea apropiado

---

**Nota final:** Este análisis asume que los requisitos del proyecto son los 6 puntos mencionados. Si hay requisitos adicionales específicos del curso que no se han considerado, por favor notificarlos para actualizar este documento.
