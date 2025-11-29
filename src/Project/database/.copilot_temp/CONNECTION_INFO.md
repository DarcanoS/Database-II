# Air Quality Platform - Database Connection Information

## ✅ Database Successfully Created!

### Database Details
- **Database Name**: `air_quality_db`
- **PostgreSQL Version**: 17.4
- **PostGIS Version**: 3.5
- **Container**: `postgis-db` (Podman)
- **Host**: `localhost`
- **Port**: `5433` (mapped from container port 5432)

---

## 👥 Users Created

### 1. Admin User (Database Administrator)
```
Username: air_quality_admin
Password: admin_secure_password
```
**Purpose**: Database administration, schema changes, migrations, seed data
**Permissions**: ALL PRIVILEGES (full control)

**Connection String**:
```bash
postgresql://air_quality_admin:admin_secure_password@localhost:5433/air_quality_db
```

### 2. Application User (Runtime)
```
Username: air_quality_app
Password: app_secure_password
```
**Purpose**: Backend API and Ingestion Service runtime
**Permissions**: Limited (SELECT on reference tables, INSERT/UPDATE on operational tables)

**Connection String**:
```bash
postgresql://air_quality_app:app_secure_password@localhost:5433/air_quality_db
```

---

## 📊 Tables Created (13 total)

| Table | Columns | Purpose |
|-------|---------|---------|
| `map_region` | 3 | Geographical regions with PostGIS geometry |
| `pollutant` | 4 | Catalog of air pollutants (PM2.5, PM10, O3, etc.) |
| `station` | 7 | Air quality monitoring stations |
| `air_quality_reading` | 6 | Real-time sensor readings |
| `air_quality_daily_stats` | 9 | Aggregated daily statistics |
| `role` | 2 | User roles (Citizen, Researcher, Admin) |
| `permission` | 2 | System permissions |
| `role_permission` | 2 | Role-permission mappings |
| `app_user` | 6 | Application users |
| `alert` | 6 | User pollution alerts |
| `recommendation` | 6 | Health recommendations |
| `product_recommendation` | 5 | Protection product suggestions |
| `report` | 9 | Report metadata |

---

## 🔌 Connection Commands

### Connect as Admin (for migrations, schema changes)
```bash
podman exec -it postgis-db psql -U air_quality_admin -d air_quality_db
```

### Connect as Application User (testing runtime permissions)
```bash
podman exec -it postgis-db psql -U air_quality_app -d air_quality_db
```

### Connect from Host (requires psql installed)
```bash
# As admin
psql postgresql://air_quality_admin:admin_secure_password@localhost:5433/air_quality_db

# As application user
psql postgresql://air_quality_app:app_secure_password@localhost:5433/air_quality_db
```

---

## 🔍 Verification Commands

### List all tables
```sql
\dt
```

### Check PostGIS version
```sql
SELECT PostGIS_Version();
```

### View user permissions
```sql
SELECT 
  table_name,
  string_agg(privilege_type, ', ' ORDER BY privilege_type) as privileges
FROM information_schema.table_privileges 
WHERE grantee = 'air_quality_app'
  AND table_schema = 'public'
GROUP BY table_name
ORDER BY table_name;
```

### Count records per table
```sql
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size,
  n_tup_ins AS inserts,
  n_tup_upd AS updates
FROM pg_stat_user_tables
ORDER BY tablename;
```

---

## 🐍 Python Connection (Backend/Ingestion)

### For Admin Operations
```python
from sqlalchemy import create_engine

# For migrations, schema changes
admin_engine = create_engine(
    "postgresql://air_quality_admin:admin_secure_password@localhost:5433/air_quality_db"
)
```

### For Application Runtime
```python
from sqlalchemy import create_engine

# For backend API and ingestion service
app_engine = create_engine(
    "postgresql://air_quality_app:app_secure_password@localhost:5433/air_quality_db"
)
```

### Environment Variables
```bash
# Add to your .env file or export:
export DATABASE_URL="postgresql://air_quality_app:app_secure_password@localhost:5433/air_quality_db"
export DATABASE_URL_ADMIN="postgresql://air_quality_admin:admin_secure_password@localhost:5433/air_quality_db"
```

---

## 📝 Next Steps

1. ✅ **Database created** - DONE
2. ✅ **Users configured** - DONE  
3. ✅ **Tables created** - DONE
4. ✅ **Permissions set** - DONE
5. ⏭️ **Run seed data** - Execute `seed_data.sql` (to be created)
6. ⏭️ **Configure backend** - Update backend `.env` with connection string
7. ⏭️ **Configure ingestion** - Update ingestion `.env` with connection string

---

## 🔒 Security Notes

- **Change passwords** before production deployment
- **Never commit** connection strings with passwords to Git
- Use **environment variables** for credentials
- The `air_quality_app` user follows the **principle of least privilege**
- Admin user should only be used for schema management

---

## 🛠️ Troubleshooting

### Cannot connect from host
```bash
# Test connection
psql postgresql://air_quality_app:app_secure_password@localhost:5433/air_quality_db -c "SELECT 1;"
```

### Permission denied errors
```bash
# Check user exists and has permissions
podman exec -it postgis-db psql -U air_quality_admin -d air_quality_db -c "\du"
```

### Container not running
```bash
# Start the container
podman start postgis-db

# Check status
podman ps | grep postgis
```
