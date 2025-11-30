# Air Quality Platform - Backend API

RESTful API backend for the Air Quality Monitoring Platform built with Python and FastAPI.

---

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- PostgreSQL 14+ with PostGIS extension
- MongoDB 5.0+ (optional, for configuration storage)
- pip or poetry for dependency management

### Installation

1. **Clone the repository and navigate to backend directory:**
   ```bash
   cd src/Project/backend
   ```

2. **Create and activate virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials and configuration
   ```

5. **Run database migrations** (if using Alembic):
   ```bash
   alembic upgrade head
   ```

6. **Start the development server:**
   ```bash
   uvicorn app.main:app --reload
   ```

The API will be available at `http://localhost:8000`

---

## 📚 Documentation

### API Documentation
- **API Contract**: [API_CONTRACT.md](./API_CONTRACT.md) - Complete endpoint documentation
- **Testing Guide**: [TESTING_GUIDE.md](./TESTING_GUIDE.md) - cURL and Postman examples
- **Frontend Integration**: [FRONTEND_INTEGRATION_GUIDE.md](./FRONTEND_INTEGRATION_GUIDE.md) - Guide for frontend developers

### Interactive API Docs
Once the server is running, visit:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

---

## 🏗️ Architecture

### Technology Stack
- **Framework**: FastAPI
- **ORM**: SQLAlchemy
- **Database**: PostgreSQL + PostGIS (geospatial data)
- **Config Storage**: MongoDB (optional)
- **Authentication**: JWT
- **Validation**: Pydantic

### Design Patterns Implemented
- **Strategy Pattern**: Risk categorization based on AQI levels
- **Builder Pattern**: Complex dashboard response construction
- **Factory Pattern**: Recommendation generation based on user roles
- **Prototype Pattern**: Dashboard configuration cloning

### Project Structure
```
backend/
├── app/
│   ├── main.py                 # Application entry point
│   ├── core/                   # Core configuration
│   │   ├── config.py           # Settings and environment variables
│   │   ├── security.py         # JWT and authentication
│   │   └── logging_config.py   # Logging configuration
│   ├── db/                     # Database layer
│   │   ├── base.py            # Base models
│   │   ├── session.py         # Database sessions
│   │   └── mongodb.py         # MongoDB connection
│   ├── models/                 # ORM models
│   ├── schemas/                # Pydantic schemas
│   ├── repositories/           # Data access layer
│   ├── services/               # Business logic
│   │   ├── dashboard_service/ # Dashboard aggregation
│   │   ├── recommendation_service/ # Recommendation engine
│   │   ├── reporting/         # Report generation
│   │   └── risk_category/     # Risk assessment
│   ├── api/                    # API endpoints
│   │   └── v1/                # API version 1
│   │       └── endpoints/     # Route handlers
│   └── tests/                  # Test suite
├── docs/                       # Design pattern documentation
├── requirements.txt            # Python dependencies
├── pytest.ini                  # Pytest configuration
└── Dockerfile                  # Docker configuration
```

---

## 🔧 Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

```bash
# API Configuration
API_V1_STR=/api/v1
PROJECT_NAME=Air Quality API

# PostgreSQL Database
POSTGRES_USER=air_quality_app
POSTGRES_PASSWORD=your_password
POSTGRES_SERVER=localhost
POSTGRES_PORT=5432
POSTGRES_DB=air_quality_db

# MongoDB (Optional)
MONGODB_URL=mongodb://localhost:27017
MONGODB_DB=air_quality_config

# Security
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# CORS
BACKEND_CORS_ORIGINS=["http://localhost:3000","http://localhost:5173"]

# Logging
LOG_LEVEL=INFO
```

---

## 🧪 Testing

### Run Tests
```bash
pytest
```

### Run with Coverage
```bash
pytest --cov=app --cov-report=html
```

### Test Specific Module
```bash
pytest app/tests/test_air_quality.py
```

---

## 📦 API Endpoints Overview

### Authentication
- `POST /api/v1/auth/login` - Login and get JWT token
- `GET /api/v1/auth/me` - Get current user info

### Stations
- `GET /api/v1/stations` - List monitoring stations
- `GET /api/v1/stations/{id}` - Get station details
- `GET /api/v1/stations/{id}/readings/current` - Current readings

### Air Quality
- `GET /api/v1/air-quality/current` - Current AQI by city
- `GET /api/v1/air-quality/dashboard` - Complete dashboard data
- `GET /api/v1/air-quality/daily-stats` - Daily statistics

### Recommendations
- `GET /api/v1/recommendations/current` - Get personalized recommendation
- `GET /api/v1/recommendations/history` - Recommendation history

### Admin (requires Admin role)
- `GET /api/v1/admin/stations` - Manage stations
- `GET /api/v1/admin/users` - Manage users
- `POST /api/v1/admin/stations` - Create station

### Settings
- `GET /api/v1/settings/preferences` - User preferences
- `GET /api/v1/settings/dashboard` - Dashboard configuration

### Reports
- `POST /api/v1/reports` - Generate report
- `GET /api/v1/reports` - List user reports

See [API_CONTRACT.md](./API_CONTRACT.md) for complete documentation.

---

## 🐳 Docker Deployment

### Build Image
```bash
docker build -t air-quality-api .
```

### Run Container
```bash
docker run -p 8000:8000 --env-file .env air-quality-api
```

### Docker Compose
```bash
docker-compose up -d
```

---

## 🔐 Security

- JWT-based authentication
- Password hashing with bcrypt
- Role-based access control (Citizen, Researcher, Admin)
- CORS configuration for allowed origins
- Input validation with Pydantic

---

## 📊 Database Models

### Core Models
- **Station**: Monitoring station locations
- **Pollutant**: Air pollutants (PM2.5, PM10, O3, NO2, SO2, CO)
- **AirQualityReading**: Sensor readings
- **AirQualityDailyStats**: Aggregated daily statistics

### User Management
- **AppUser**: Application users
- **Role**: User roles (Citizen, Researcher, Admin)
- **Permission**: Role permissions

### Features
- **Recommendation**: Personalized health recommendations
- **ProductRecommendation**: Product suggestions
- **Alert**: User-configured alerts
- **Report**: Generated reports

### Geospatial
- **MapRegion**: Geographic regions with PostGIS geometry

---

## 🛠️ Development

### Code Style
- Follow PEP 8 guidelines
- Use type hints
- Document complex logic
- Write tests for new features

### Adding New Endpoints

1. Create schema in `app/schemas/`
2. Define repository in `app/repositories/`
3. Implement service in `app/services/`
4. Add endpoint in `app/api/v1/endpoints/`
5. Register route in `app/api/v1/router.py`
6. Write tests in `app/tests/`

---

## 📈 Performance

- Connection pooling for database
- Async endpoints where applicable
- Pagination for list endpoints
- Indexes on frequently queried fields

---

## 🐛 Troubleshooting

### Database Connection Issues
```bash
# Test database connection
python test_db_connection.py
```

### Import Errors
```bash
# Verify imports
python test_imports.py
```

### Environment Issues
```bash
# Verify environment configuration
python verify_env.py
```

---

## 📝 License

[Your License Here]

---

## 👥 Contributing

1. Follow Git Flow methodology (see `/docs/GIT_FLOW.md`)
2. Create feature branches from `develop`
3. Write tests for new features
4. Update documentation
5. Submit pull request to `develop`

---

## 📧 Support

For questions or issues, contact the backend development team.

**Last Updated**: November 30, 2025
