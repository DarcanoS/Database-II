# MongoDB Initialization Report

**Date:** 2025-11-26  
**Database:** air_quality_config  
**Container:** mongodb  
**Status:** ✅ Successfully Initialized

---

## Initialization Summary

### Collections Created

1. ✅ **user_preferences**
   - Purpose: Store user-specific preferences and settings
   - Validation: JSON Schema enabled (moderate level, warn action)
   - Documents: 0 (will be populated at runtime)

2. ✅ **dashboard_configs**
   - Purpose: Store user dashboard layouts and widget configurations
   - Validation: JSON Schema enabled (moderate level, warn action)
   - Documents: 0 (will be populated at runtime)

### Indexes Created

#### user_preferences (6 indexes total)
- `_id_` (default MongoDB index)
- `idx_user_preferences_user_id` (UNIQUE) - Primary lookup
- `idx_user_preferences_theme` (sparse) - Theme filtering
- `idx_user_preferences_email_enabled` (sparse) - Notification queries
- `idx_user_preferences_city_aqi_alert` (compound, sparse) - City + AQI alerts
- `idx_user_preferences_updated_at` (descending, sparse) - Recent updates

#### dashboard_configs (6 indexes total)
- `_id_` (default MongoDB index)
- `idx_dashboard_configs_user_id` (UNIQUE) - Primary lookup
- `idx_dashboard_configs_widget_type` (sparse) - Widget analytics
- `idx_dashboard_configs_widget_enabled` (sparse) - Active widgets
- `idx_dashboard_configs_last_updated` (descending, sparse) - Recent changes
- `idx_dashboard_configs_version` (sparse) - Version tracking

---

## Execution Commands

### Scripts Run

```bash
# 1. Copy scripts to container
podman cp mongo_init.js mongodb:/tmp/mongo_init.js
podman cp mongo_indexes.js mongodb:/tmp/mongo_indexes.js

# 2. Initialize collections (with authentication)
podman exec mongodb mongosh -u stivel -p stivel --authenticationDatabase admin /tmp/mongo_init.js

# 3. Create indexes
podman exec mongodb mongosh -u stivel -p stivel --authenticationDatabase admin /tmp/mongo_indexes.js
```

### Verification Commands

```bash
# List collections
podman exec mongodb mongosh -u stivel -p stivel --authenticationDatabase admin \
  air_quality_config --eval "printjson(db.getCollectionNames())"

# Check indexes on user_preferences
podman exec mongodb mongosh -u stivel -p stivel --authenticationDatabase admin \
  air_quality_config --eval "db.user_preferences.getIndexes()"

# Check indexes on dashboard_configs
podman exec mongodb mongosh -u stivel -p stivel --authenticationDatabase admin \
  air_quality_config --eval "db.dashboard_configs.getIndexes()"
```

---

## Connection Information

### Container Details
- **Name:** mongodb
- **Image:** docker.io/library/mongo:latest
- **Port:** 27017 (mapped to localhost:27017)
- **Status:** Running

### Authentication
- **Username:** stivel
- **Password:** stivel
- **Auth Database:** admin
- **Auth Mechanism:** SCRAM-SHA-256 (default)

### Connection Strings

#### From Host (Python/Backend)
```python
MONGO_URI = "mongodb://stivel:stivel@localhost:27017/air_quality_config?authSource=admin"
```

#### From MongoDB Shell
```bash
mongosh -u stivel -p stivel --authenticationDatabase admin air_quality_config
```

#### Environment Variables (in .env)
```bash
MONGO_URI=mongodb://stivel:stivel@localhost:27017/air_quality_config?authSource=admin
MONGO_DB_NAME=air_quality_config
MONGO_HOST=localhost
MONGO_PORT=27017
MONGO_USER=stivel
MONGO_PASSWORD=stivel
MONGO_AUTH_SOURCE=admin
```

---

## Validation Schemas

### user_preferences Schema
- ✅ `user_id` (int, required) - References AppUser.id from PostgreSQL
- ✅ `default_city` (string) - Default city for display
- ✅ `favorite_pollutants` (array of strings) - Tracked pollutants
- ✅ `theme` (string, enum: "light"|"dark") - UI theme
- ✅ `notifications` (object) - Notification preferences
  - `email_enabled` (bool)
  - `sms_enabled` (bool)
  - `min_aqi_for_alert` (int, 0-500)
  - `frequency` (string, enum: "realtime"|"hourly"|"daily")
- ✅ `language` (string, ISO 639-1 pattern)
- ✅ `timezone` (string, IANA format)
- ✅ `created_at` (date)
- ✅ `updated_at` (date)

### dashboard_configs Schema
- ✅ `user_id` (int, required) - References AppUser.id from PostgreSQL
- ✅ `layout_type` (string, enum: "grid"|"freeform"|"list")
- ✅ `widgets` (array, required) - Dashboard widgets
  - `id` (string, required)
  - `type` (string, required, enum: widget types)
  - `title` (string)
  - `position` (object: x, y, w, h)
  - `config` (object: pollutant, station_id, time_range, chart_type)
  - `enabled` (bool, required)
  - `order` (int)
- ✅ `created_at` (date)
- ✅ `last_updated` (date)
- ✅ `version` (int, min: 1)

---

## Next Steps

### 1. Test MongoDB Connection from Backend

```python
# Test script: test_mongo_connection.py
from pymongo import MongoClient
import os

# Load from .env
MONGO_URI = "mongodb://stivel:stivel@localhost:27017/air_quality_config?authSource=admin"

client = MongoClient(MONGO_URI)
db = client['air_quality_config']

# Test collections exist
print("Collections:", db.list_collection_names())

# Test insert (will be validated by schema)
test_pref = {
    'user_id': 999,
    'default_city': 'Bogotá',
    'theme': 'dark',
    'created_at': datetime.utcnow()
}

result = db.user_preferences.insert_one(test_pref)
print(f"Inserted test document with ID: {result.inserted_id}")

# Clean up test
db.user_preferences.delete_one({'user_id': 999})
print("Test document deleted")

client.close()
```

### 2. Integrate with Backend

See `mongo_python_examples.py` for complete MongoDB service implementation.

### 3. Update Backend Configuration

Add to `backend/app/core/config.py`:
```python
class Settings(BaseSettings):
    # PostgreSQL
    DATABASE_URL: str
    
    # MongoDB
    MONGO_URI: str
    MONGO_DB_NAME: str = "air_quality_config"
    
    class Config:
        env_file = "../database/.env"
```

---

## Troubleshooting

### Authentication Failed
If you get authentication errors, verify credentials:
```bash
podman inspect mongodb | grep -A 5 "MONGO_INITDB"
```

### Cannot Connect from Host
Check container port mapping:
```bash
podman ps | grep mongodb
# Should show: 0.0.0.0:27017->27017/tcp
```

### Schema Validation Errors
View validation details:
```javascript
use air_quality_config;
db.getCollectionInfos({name: "user_preferences"})[0].options.validator
```

---

## Files Created

1. ✅ `mongo_init.js` - Collection creation with validation
2. ✅ `mongo_indexes.js` - Index creation
3. ✅ `MONGODB_SETUP.md` - Complete setup guide
4. ✅ `mongo_python_examples.py` - Python usage examples
5. ✅ `mongo_docker_compose.yml` - Docker Compose config
6. ✅ `.env` - Updated with MongoDB credentials
7. ✅ `.env.example` - Updated template with MongoDB vars

---

## Status: ✅ COMPLETE

MongoDB is fully initialized and ready for use. No seed data required - documents will be created at runtime by the application.
