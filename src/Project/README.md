# Air Quality Platform Project

This directory contains the development of a web platform for air quality data consultation and analysis.

## 📁 Project Structure

### `docs/`
Contains global documentation for the project:
- General system architecture, monorepo structure, data model, design patterns, color palette, and development guidelines.
- Git Flow methodology guide, including branch structure, workflows, and commit conventions.

### `backend/`
REST API developed in **Python with FastAPI**.

### `frontend/`
Web application developed in **Vue 3**.
- Includes HTML mockups for different views (login, citizen and researcher dashboards, landing page).

### `database/`
Database management and configuration (PostgreSQL + PostGIS), schemas, migrations, and initialization scripts.

### `ingestion/`
Service for external air quality data ingestion, normalization, and storage in the database.

## 🚀 Main Technologies

- **Frontend**: Vue 3, TypeScript
- **Backend**: Python, FastAPI
- **Database**: PostgreSQL + PostGIS
- **Configurations**: MongoDB (NoSQL)
- **Containerization**: Docker
