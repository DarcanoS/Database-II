# 📘 API Contract - Air Quality Monitoring Backend

**Version:** 1.0.0  
**Base URL:** `http://localhost:8000/api/v1`  
**Date:** November 27, 2025

---

## 📋 Table of Contents

1. [Authentication](#authentication)
2. [Authentication Endpoints](#1-authentication)
3. [Stations Endpoints](#2-stations)
4. [Air Quality Endpoints](#3-air-quality)
5. [Recommendations Endpoints](#4-recommendations)
6. [Admin Endpoints](#5-admin)
7. [Settings Endpoints](#6-settings)
8. [Reports Endpoints](#7-reports)
9. [Data Models](#data-models)
10. [Error Codes](#error-codes)

---

## 🔐 Authentication

### Authentication Type
- **Bearer Token** (JWT)
- Header: `Authorization: Bearer {token}`

### Obtaining a Token
```http
POST /api/v1/auth/login
```

### Access Levels
- 🟢 **Public**: No authentication required
- 🟡 **User**: Requires authenticated user token
- 🔴 **Admin**: Requires token with Admin role

---

## 1. Authentication

### 1.1 Login
**POST** `/api/v1/auth/login` 🟢

Obtains an access token for future requests.

**Request Body (form-data):**
```json
{
  "username": "user@example.com",  // User email
  "password": "password123"
}
```

**Response 200:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "full_name": "John Doe",
    "role": {
      "id": 1,
      "name": "Citizen",
      "description": "Regular citizen user"
    },
    "created_at": "2025-11-27T10:30:00",
    "is_active": true
  }
}
```

**Errors:**
- `401`: Incorrect email or password

**cURL Example:**
```bash
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=user@example.com&password=password123"
```

---

### 1.2 Get Current User
**GET** `/api/v1/auth/me` 🟡

Retrieves information about the authenticated user.

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "full_name": "John Doe",
  "role": {
    "id": 1,
    "name": "Citizen",
    "description": "Regular citizen user"
  },
  "created_at": "2025-11-27T10:30:00",
  "is_active": true
}
```

**Errors:**
- `401`: Invalid or expired token

---

## 2. Stations

### 2.1 List Stations
**GET** `/api/v1/stations` 🟢

Lists all monitoring stations with optional filters.

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| skip | int | No | 0 | Records to skip (pagination) |
| limit | int | No | 100 | Maximum records (1-1000) |
| city | string | No | - | Filter by city |
| country | string | No | - | Filter by country |
| region_id | int | No | - | Filter by region |

**Response 200:**
```json
[
  {
    "id": 1,
    "name": "Downtown Station",
    "latitude": 40.7128,
    "longitude": -74.0060,
    "city": "New York",
    "country": "USA",
    "region": {
      "id": 1,
      "name": "North America",
      "description": "North American region"
    },
    "is_active": true,
    "created_at": "2025-01-15T08:00:00"
  }
]
```

**Example:**
```bash
curl "http://localhost:8000/api/v1/stations?city=New%20York&limit=10"
```

---

### 2.2 Get Station
**GET** `/api/v1/stations/{station_id}` 🟢

Retrieves detailed information about a specific station.

**Path Parameters:**
- `station_id` (int): Station ID

**Response 200:**
```json
{
  "id": 1,
  "name": "Downtown Station",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "city": "New York",
  "country": "USA",
  "region": {
    "id": 1,
    "name": "North America",
    "description": "North American region"
  },
  "is_active": true,
  "created_at": "2025-01-15T08:00:00"
}
```

**Errors:**
- `404`: Station not found

---

### 2.3 Get Current Readings
**GET** `/api/v1/stations/{station_id}/readings/current` 🟢

Retrieves the most recent readings for all pollutants at a station.

**Path Parameters:**
- `station_id` (int): Station ID

**Response 200:**
```json
{
  "station": {
    "id": 1,
    "name": "Downtown Station",
    "city": "New York"
  },
  "readings": [
    {
      "pollutant": {
        "id": 1,
        "name": "PM2.5",
        "unit": "µg/m³",
        "description": "Fine particulate matter"
      },
      "value": 35.5,
      "timestamp": "2025-11-27T14:30:00",
      "aqi": 102
    },
    {
      "pollutant": {
        "id": 2,
        "name": "PM10",
        "unit": "µg/m³"
      },
      "value": 55.2,
      "timestamp": "2025-11-27T14:30:00",
      "aqi": 75
    }
  ],
  "last_updated": "2025-11-27T14:30:00"
}
```

**Errors:**
- `404`: Station not found

---

## 3. Air Quality

### 3.1 Get Current AQI
**GET** `/api/v1/air-quality/current` 🟢

Retrieves the current air quality index for a city.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| city | string | **Yes** | City name |

**Response 200:**
```json
{
  "city": "New York",
  "aqi": 102,
  "primary_pollutant": "PM2.5",
  "risk_category": {
    "level": "Unhealthy for Sensitive Groups",
    "color": "#FF9800",
    "health_implications": "Members of sensitive groups may experience health effects",
    "cautionary_statement": "Active children and adults, and people with respiratory disease should limit prolonged outdoor exertion"
  },
  "timestamp": "2025-11-27T14:30:00",
  "station": {
    "id": 1,
    "name": "Downtown Station"
  }
}
```

**Errors:**
- `404`: No data found for the city

**Example:**
```bash
curl "http://localhost:8000/api/v1/air-quality/current?city=New%20York"
```

---

### 3.2 Get Dashboard Data
**GET** `/api/v1/air-quality/dashboard` 🟢

Retrieves comprehensive dashboard data (uses Builder pattern).

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| city | string | No* | City name |
| station_id | int | No* | Station ID |

*One of the two is required

**Response 200:**
```json
{
  "station": {
    "id": 1,
    "name": "Downtown Station",
    "city": "New York",
    "country": "USA",
    "latitude": 40.7128,
    "longitude": -74.0060
  },
  "current_readings": [
    {
      "pollutant": {
        "id": 1,
        "name": "PM2.5",
        "unit": "µg/m³"
      },
      "value": 35.5,
      "aqi": 102,
      "timestamp": "2025-11-27T14:30:00"
    }
  ],
  "daily_stats": {
    "date": "2025-11-27",
    "avg_aqi": 95.5,
    "max_aqi": 115,
    "min_aqi": 78,
    "dominant_pollutant": "PM2.5"
  },
  "risk_assessment": {
    "level": "Unhealthy for Sensitive Groups",
    "color": "#FF9800",
    "health_implications": "Members of sensitive groups may experience health effects",
    "recommended_actions": [
      "Limit prolonged outdoor exertion",
      "Close windows",
      "Use air purifier indoors"
    ]
  },
  "last_updated": "2025-11-27T14:30:00"
}
```

**Example:**
```bash
curl "http://localhost:8000/api/v1/air-quality/dashboard?city=New%20York"
```

---

### 3.3 Get Daily Stats
**GET** `/api/v1/air-quality/daily-stats` 🟢

Retrieves aggregated daily statistics with filters.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| station_id | int | No | Filter by station |
| pollutant_id | int | No | Filter by pollutant |
| start_date | date | No | Start date (YYYY-MM-DD) |
| end_date | date | No | End date (YYYY-MM-DD) |
| skip | int | No | Pagination (default: 0) |
| limit | int | No | Limit (default: 100) |

**Response 200:**
```json
[
  {
    "id": 1,
    "date": "2025-11-27",
    "station_id": 1,
    "pollutant_id": 1,
    "avg_value": 35.5,
    "max_value": 45.2,
    "min_value": 28.1,
    "avg_aqi": 102,
    "readings_count": 24
  }
]
```

**Example:**
```bash
curl "http://localhost:8000/api/v1/air-quality/daily-stats?station_id=1&start_date=2025-11-01&end_date=2025-11-27"
```

---

## 4. Recommendations

### 4.1 Get Current Recommendation
**GET** `/api/v1/recommendations/current` 🟡

Generates a personalized recommendation using Factory pattern based on user role.

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| location | string | No | Specific location |
| aqi | int | No | Explicit AQI value (0-500) |

**Response 200:**
```json
{
  "id": 1,
  "user_id": 1,
  "location": "New York",
  "aqi": 102,
  "risk_level": "Unhealthy for Sensitive Groups",
  "recommendation_text": "Based on current air quality conditions, we recommend the following actions...",
  "health_advice": [
    "Limit prolonged outdoor activities",
    "Keep windows closed",
    "Monitor symptoms if you have respiratory conditions"
  ],
  "actions": [
    "Use N95 masks when going outside",
    "Enable air purifiers indoors",
    "Check air quality before planning outdoor activities"
  ],
  "products": [
    {
      "type": "mask",
      "name": "N95 Respirator Mask",
      "description": "High-efficiency mask for particle filtration",
      "priority": "high"
    },
    {
      "type": "air_purifier",
      "name": "HEPA Air Purifier",
      "description": "Removes 99.97% of particles from indoor air",
      "priority": "medium"
    }
  ],
  "created_at": "2025-11-27T14:30:00"
}
```

**Example:**
```bash
curl -H "Authorization: Bearer {token}" \
  "http://localhost:8000/api/v1/recommendations/current?location=New%20York"
```

---

### 4.2 Get Recommendation History
**GET** `/api/v1/recommendations/history` 🟡

Retrieves the user's recommendation history.

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
| Parameter | Type | Required | Default |
|-----------|------|----------|---------|
| skip | int | No | 0 |
| limit | int | No | 100 |

**Response 200:**
```json
[
  {
    "id": 1,
    "location": "New York",
    "aqi": 102,
    "risk_level": "Unhealthy for Sensitive Groups",
    "recommendation_text": "...",
    "created_at": "2025-11-27T14:30:00"
  }
]
```

---

## 5. Admin

### 5.1 Health Check
**GET** `/api/v1/admin/health` 🟢

Verifies the API and database status.

**Response 200:**
```json
{
  "status": "healthy",
  "database": "connected",
  "message": "Database contains 6 pollutants"
}
```

---

### 5.2 List Stations (Admin)
**GET** `/api/v1/admin/stations` 🔴

Lists all stations (administrators only).

**Headers:**
```
Authorization: Bearer {admin_token}
```

**Query Parameters:**
| Parameter | Type | Default |
|-----------|------|---------|
| skip | int | 0 |
| limit | int | 100 |

**Response 200:**
```json
[
  {
    "id": 1,
    "name": "Downtown Station",
    "latitude": 40.7128,
    "longitude": -74.0060,
    "city": "New York",
    "country": "USA",
    "region": {...},
    "is_active": true,
    "created_at": "2025-01-15T08:00:00"
  }
]
```

**Errors:**
- `403`: Insufficient permissions (not admin)

---

### 5.3 Create Station
**POST** `/api/v1/admin/stations` 🔴

Creates a new monitoring station.

**Headers:**
```
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "name": "New Station",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "city": "New York",
  "country": "USA",
  "region_id": 1
}
```

**Response 201:**
```json
{
  "id": 2,
  "name": "New Station",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "city": "New York",
  "country": "USA",
  "region": {
    "id": 1,
    "name": "North America"
  },
  "is_active": true,
  "created_at": "2025-11-27T14:30:00"
}
```

**Errors:**
- `403`: Insufficient permissions
- `422`: Validation errors

---

### 5.4 Update Station
**PUT** `/api/v1/admin/stations/{station_id}` 🔴

Updates an existing station.

**Headers:**
```
Authorization: Bearer {admin_token}
```

**Path Parameters:**
- `station_id` (int): Station ID

**Request Body (all fields optional):**
```json
{
  "name": "Updated Station Name",
  "latitude": 40.7200,
  "longitude": -74.0100,
  "city": "New York City",
  "country": "USA",
  "is_active": false
}
```

**Response 200:**
```json
{
  "id": 1,
  "name": "Updated Station Name",
  "latitude": 40.7200,
  "longitude": -74.0100,
  "city": "New York City",
  "country": "USA",
  "region": {...},
  "is_active": false,
  "created_at": "2025-01-15T08:00:00"
}
```

**Errors:**
- `403`: Insufficient permissions
- `404`: Station not found
- `422`: Validation errors

---

### 5.5 Delete Station
**DELETE** `/api/v1/admin/stations/{station_id}` 🔴

Deletes a monitoring station.

**Headers:**
```
Authorization: Bearer {admin_token}
```

**Path Parameters:**
- `station_id` (int): Station ID

**Response 200:**
```json
{
  "message": "Station 1 deleted successfully"
}
```

**Errors:**
- `403`: Insufficient permissions
- `404`: Station not found

---

### 5.6 List Users
**GET** `/api/v1/admin/users` 🔴

Lists all system users.

**Headers:**
```
Authorization: Bearer {admin_token}
```

**Query Parameters:**
| Parameter | Type | Default |
|-----------|------|---------|
| skip | int | 0 |
| limit | int | 100 |

**Response 200:**
```json
[
  {
    "id": 1,
    "email": "user@example.com",
    "full_name": "John Doe",
    "role": {
      "id": 1,
      "name": "Citizen"
    },
    "created_at": "2025-11-01T10:00:00",
    "is_active": true
  }
]
```

**Errors:**
- `403`: Insufficient permissions

---

### 5.7 Update User Role
**PUT** `/api/v1/admin/users/{user_id}/role` 🔴

Updates a user's role.

**Headers:**
```
Authorization: Bearer {admin_token}
```

**Path Parameters:**
- `user_id` (int): User ID

**Request Body:**
```json
{
  "role_id": 2
}
```

**Response 200:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "full_name": "John Doe",
  "role": {
    "id": 2,
    "name": "Researcher",
    "description": "Research and analysis role"
  },
  "created_at": "2025-11-01T10:00:00",
  "is_active": true
}
```

**Errors:**
- `403`: Insufficient permissions
- `404`: User not found

---

## 6. Settings

### 6.1 Get User Preferences
**GET** `/api/v1/settings/preferences` 🟡

Retrieves current user preferences.

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "user_id": 1,
  "theme": "dark",
  "language": "en",
  "notifications_enabled": true,
  "email_alerts": true,
  "aqi_threshold": 100,
  "preferred_units": "metric"
}
```

---

### 6.2 Update User Preferences
**PUT** `/api/v1/settings/preferences` 🟡

Updates user preferences.

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body (all fields optional):**
```json
{
  "theme": "light",
  "language": "es",
  "notifications_enabled": false,
  "email_alerts": true,
  "aqi_threshold": 150,
  "preferred_units": "imperial"
}
```

**Response 200:**
```json
{
  "user_id": 1,
  "theme": "light",
  "language": "es",
  "notifications_enabled": false,
  "email_alerts": true,
  "aqi_threshold": 150,
  "preferred_units": "imperial"
}
```

---

### 6.3 Get Dashboard Config
**GET** `/api/v1/settings/dashboard` 🟡

Retrieves personalized dashboard configuration (uses Prototype pattern).

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "user_id": 1,
  "widgets": [
    {
      "id": "aqi-gauge",
      "type": "gauge",
      "position": {"x": 0, "y": 0},
      "size": {"width": 2, "height": 2},
      "settings": {
        "show_history": true,
        "time_range": "24h"
      }
    },
    {
      "id": "pollutants-chart",
      "type": "chart",
      "position": {"x": 2, "y": 0},
      "size": {"width": 4, "height": 2},
      "settings": {
        "chart_type": "line",
        "pollutants": ["PM2.5", "PM10", "O3"]
      }
    }
  ],
  "layout": "grid",
  "refresh_interval": 300
}
```

---

### 6.4 Update Dashboard Config
**PUT** `/api/v1/settings/dashboard` 🟡

Updates dashboard configuration.

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "widgets": [
    {
      "id": "aqi-gauge",
      "type": "gauge",
      "position": {"x": 0, "y": 0},
      "size": {"width": 3, "height": 2},
      "settings": {
        "show_history": true,
        "time_range": "48h"
      }
    }
  ],
  "layout": "flex",
  "refresh_interval": 180
}
```

**Response 200:**
```json
{
  "user_id": 1,
  "widgets": [...],
  "layout": "flex",
  "refresh_interval": 180
}
```

---

## 7. Reports

### 7.1 Create Report
**POST** `/api/v1/reports` 🟡

Creates a new air quality report.

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "city": "New York",
  "start_date": "2025-11-01",
  "end_date": "2025-11-27",
  "station_id": 1,
  "pollutant_id": 1
}
```

**Response 201:**
```json
{
  "id": 1,
  "user_id": 1,
  "city": "New York",
  "start_date": "2025-11-01",
  "end_date": "2025-11-27",
  "station_id": 1,
  "pollutant_id": 1,
  "file_path": "/reports/user_1/report_New_York_2025-11-01_2025-11-27.pdf",
  "status": "completed",
  "created_at": "2025-11-27T14:30:00"
}
```

---

### 7.2 List User Reports
**GET** `/api/v1/reports` 🟡

Lists reports for the current user.

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
| Parameter | Type | Default |
|-----------|------|---------|
| skip | int | 0 |
| limit | int | 100 |

**Response 200:**
```json
[
  {
    "id": 1,
    "user_id": 1,
    "city": "New York",
    "start_date": "2025-11-01",
    "end_date": "2025-11-27",
    "station_id": 1,
    "pollutant_id": 1,
    "file_path": "/reports/user_1/report_New_York_2025-11-01_2025-11-27.pdf",
    "status": "completed",
    "created_at": "2025-11-27T14:30:00"
  }
]
```

---

### 7.3 Get Report
**GET** `/api/v1/reports/{report_id}` 🟡

Retrieves a specific report.

**Headers:**
```
Authorization: Bearer {token}
```

**Path Parameters:**
- `report_id` (int): Report ID

**Response 200:**
```json
{
  "id": 1,
  "user_id": 1,
  "city": "New York",
  "start_date": "2025-11-01",
  "end_date": "2025-11-27",
  "station_id": 1,
  "pollutant_id": 1,
  "file_path": "/reports/user_1/report_New_York_2025-11-01_2025-11-27.pdf",
  "status": "completed",
  "created_at": "2025-11-27T14:30:00"
}
```

**Errors:**
- `403`: No permission to access this report
- `404`: Report not found

---

## 📊 Data Models

### User
```typescript
interface User {
  id: number;
  email: string;
  full_name: string;
  role: Role;
  created_at: string; // ISO 8601
  is_active: boolean;
}
```

### Role
```typescript
interface Role {
  id: number;
  name: "Citizen" | "Researcher" | "Admin";
  description: string;
}
```

### Station
```typescript
interface Station {
  id: number;
  name: string;
  latitude: number;
  longitude: number;
  city: string;
  country: string;
  region: Region;
  is_active: boolean;
  created_at: string;
}
```

### Region
```typescript
interface Region {
  id: number;
  name: string;
  description: string;
}
```

### Pollutant
```typescript
interface Pollutant {
  id: number;
  name: string; // "PM2.5", "PM10", "O3", "NO2", "SO2", "CO"
  unit: string; // "µg/m³", "ppm"
  description: string;
}
```

### Reading
```typescript
interface Reading {
  pollutant: Pollutant;
  value: number;
  aqi: number;
  timestamp: string; // ISO 8601
}
```

### Risk Category
```typescript
interface RiskCategory {
  level: "Good" | "Moderate" | "Unhealthy for Sensitive Groups" | "Unhealthy" | "Very Unhealthy" | "Hazardous";
  color: string; // Hex color code
  health_implications: string;
  cautionary_statement: string;
}
```

### Recommendation
```typescript
interface Recommendation {
  id: number;
  user_id: number;
  location: string;
  aqi: number;
  risk_level: string;
  recommendation_text: string;
  health_advice: string[];
  actions: string[];
  products: ProductRecommendation[];
  created_at: string;
}
```

### Product Recommendation
```typescript
interface ProductRecommendation {
  type: "mask" | "air_purifier" | "monitor" | "medication";
  name: string;
  description: string;
  priority: "low" | "medium" | "high";
}
```

### Daily Stats
```typescript
interface DailyStats {
  id: number;
  date: string; // YYYY-MM-DD
  station_id: number;
  pollutant_id: number;
  avg_value: number;
  max_value: number;
  min_value: number;
  avg_aqi: number;
  readings_count: number;
}
```

### Dashboard Config Widget
```typescript
interface Widget {
  id: string;
  type: "gauge" | "chart" | "map" | "table" | "alert";
  position: {
    x: number;
    y: number;
  };
  size: {
    width: number;
    height: number;
  };
  settings: Record<string, any>;
}
```

---

## ⚠️ Error Codes

### HTTP Status Codes

| Code | Name | Description |
|------|------|-------------|
| 200 | OK | Successful request |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Malformed request |
| 401 | Unauthorized | Not authenticated or invalid token |
| 403 | Forbidden | Not authorized (no permissions) |
| 404 | Not Found | Resource not found |
| 422 | Unprocessable Entity | Validation error |
| 500 | Internal Server Error | Server error |

### Error Response Format

All errors follow this format:

```json
{
  "detail": "Error message description"
}
```

Or for validation errors (422):

```json
{
  "detail": [
    {
      "loc": ["body", "field_name"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

---

## 🔄 Common Workflow Examples

### Workflow 1: Login and Get Dashboard
```bash
# 1. Login
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=user@example.com&password=password123"

# Response: { "access_token": "eyJ...", ... }

# 2. Get dashboard data
curl -H "Authorization: Bearer eyJ..." \
  "http://localhost:8000/api/v1/air-quality/dashboard?city=New%20York"
```

### Workflow 2: Get Personalized Recommendation
```bash
# 1. Authenticate (get token)
TOKEN="eyJ..."

# 2. Get current recommendation
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/api/v1/recommendations/current?location=New%20York"

# 3. View recommendation history
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/api/v1/recommendations/history?limit=10"
```

### Workflow 3: Admin - Create and Manage Station
```bash
# 1. Login as admin
ADMIN_TOKEN="eyJ..."

# 2. Create new station
curl -X POST "http://localhost:8000/api/v1/admin/stations" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Central Park Station",
    "latitude": 40.7829,
    "longitude": -73.9654,
    "city": "New York",
    "country": "USA",
    "region_id": 1
  }'

# 3. List all stations
curl -H "Authorization: Bearer $ADMIN_TOKEN" \
  "http://localhost:8000/api/v1/admin/stations"
```

---

## 🌐 CORS Configuration

The backend is configured to accept requests from:
- `http://localhost:3000` (frontend development)
- `http://localhost:5173` (Vite)
- Other origins configured in production

---

## 📝 Important Notes

### Date Format
- All dates follow **ISO 8601** format: `YYYY-MM-DDTHH:mm:ss`
- For query parameters: `YYYY-MM-DD`

### Pagination
- Standard parameters: `skip` and `limit`
- Maximum limit: 1000 records per request
- Default: 100 records

### Rate Limiting
- Not currently implemented
- Recommended for production: 100 requests/minute per IP

### Logging
- All important operations are logged
- Includes: logins, resource creation/editing/deletion

---

## 🎨 Design Patterns Used

| Pattern | Endpoint | Description |
|---------|----------|-------------|
| **Strategy** | `/air-quality/current` | Risk categorization based on AQI levels |
| **Builder** | `/air-quality/dashboard` | Complex dashboard response construction |
| **Factory** | `/recommendations/current` | Recommendation generation based on user type |
| **Prototype** | `/settings/dashboard` | Cloning default configurations |

---

## 📧 Support

For any questions or issues with the API, contact the backend team.

**Last updated:** November 27, 2025  
**Version:** 1.0.0
