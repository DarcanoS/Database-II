# Database Setup - Process Documentation
**This file is in `.copilot_temp/` and will NOT be committed to Git**

## ✅ Setup Completed on: 2025-11-26

### What was done:

1. **Created database schema** (`init_schema.sql`)
   - 13 tables created according to DBML model
   - PostGIS extension enabled
   - All indexes and foreign keys configured
   - Comments added to all tables

2. **Created user permissions script** (`setup_users_permissions.sql`)
   - Configured granular permissions for `air_quality_app` user
   - Admin user has full privileges
   - Application user follows principle of least privilege

3. **Configured environment variables**
   - Created `.env.example` as template (committed to Git)
   - Created `.env` with actual credentials (NOT committed)
   - Updated `.gitignore` to exclude sensitive files

4. **Created helper script** (`db_helper.sh`)
   - Bash script to easily connect and run SQL scripts
   - Automatically loads credentials from `.env`
   - Provides convenient commands for common operations

5. **Updated documentation**
   - `README.md` updated with .env usage instructions
   - `COPILOT_DATABASE.md` updated with security guidelines
   - Created this process documentation

### Database Created:

- **Database**: `air_quality_db`
- **Container**: `postgis-db` (Podman)
- **Port**: 5433 (localhost)
- **PostgreSQL**: 17.4
- **PostGIS**: 3.5

### Users:

1. **air_quality_admin**
   - Password: admin_secure_password
   - Purpose: Migrations, schema changes
   - Permissions: ALL

2. **air_quality_app**
   - Password: app_secure_password
   - Purpose: Backend/Ingestion runtime
   - Permissions: Limited (see setup_users_permissions.sql)

### Files Created:

**Committed to Git:**
- ✅ `init_schema.sql`
- ✅ `setup_users_permissions.sql`
- ✅ `.env.example`
- ✅ `README.md`
- ✅ `COPILOT_DATABASE.md` (updated)
- ✅ `db_helper.sh`

**NOT Committed (in .gitignore):**
- ❌ `.env` (actual credentials)
- ❌ `.copilot_temp/` (this folder)
- ❌ `CONNECTION_INFO.md` (moved here)

### Commands Used:

```bash
# Create database and users
podman exec -i postgis-db psql -U stivel -d espacial << 'EOF'
SELECT 'CREATE DATABASE air_quality_db' WHERE NOT EXISTS ...
CREATE USER air_quality_admin ...
CREATE USER air_quality_app ...
EOF

# Enable PostGIS and grant permissions
podman exec -i postgis-db psql -U stivel -d air_quality_db << 'EOF'
CREATE EXTENSION IF NOT EXISTS postgis;
GRANT ALL ON SCHEMA public TO air_quality_admin;
EOF

# Run schema creation
podman exec -i postgis-db psql -U air_quality_admin -d air_quality_db < init_schema.sql

# Setup permissions
podman exec -i postgis-db psql -U air_quality_admin -d air_quality_db < setup_users_permissions.sql
```

### Verification:

All tables created successfully:
```
air_quality_daily_stats (9 columns)
air_quality_reading (6 columns)
alert (6 columns)
app_user (6 columns)
map_region (3 columns)
permission (2 columns)
pollutant (4 columns)
product_recommendation (5 columns)
recommendation (6 columns)
report (9 columns)
role (2 columns)
role_permission (2 columns)
station (7 columns)
```

### Next Steps:

1. ⏭️ Create `seed_data.sql` to populate initial data:
   - Roles (Citizen, Researcher, Admin)
   - Permissions
   - Pollutants (PM2.5, PM10, O3, NO2, SO2, CO)
   - Sample regions and stations
   - Demo users
   - Sample readings and statistics

2. ⏭️ Configure backend to use `.env` for DATABASE_URL

3. ⏭️ Configure ingestion service to use `.env` for DATABASE_URL

### Security Checklist:

- ✅ `.env` excluded from Git
- ✅ `.env.example` committed as template
- ✅ No hardcoded credentials in documentation
- ✅ Temporary docs in `.copilot_temp/`
- ✅ Helper script uses environment variables
- ✅ Least privilege principle applied
- ✅ Separate admin and app users

### How to Use:

**Connect to database:**
```bash
./db_helper.sh admin   # As admin
./db_helper.sh app     # As application user
./db_helper.sh info    # Show connection info
```

**Run scripts:**
```bash
./db_helper.sh run-admin seed_data.sql
```

**From Python:**
```python
from dotenv import load_dotenv
import os

load_dotenv("../database/.env")
DATABASE_URL = os.getenv("DATABASE_URL")
```
