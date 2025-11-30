# 🚀 Frontend Integration Quick Guide

## 📦 Integration Files

We have created 3 essential files to facilitate frontend integration with the backend:

1. **`API_CONTRACT.md`** - Complete documentation of all endpoints
2. **`api-types.ts`** - TypeScript type definitions
3. **`api-client-example.ts`** - Ready-to-use API client

---

## ⚡ Quick Start

### 1. Copy Files to Frontend Project

```bash
# Copy TypeScript files to your frontend project
cp api-types.ts /path/to/frontend/src/types/
cp api-client-example.ts /path/to/frontend/src/api/
```

### 2. Install Dependencies (if necessary)

The API client uses native `fetch`, no additional dependencies required.

### 3. Configure API Client

```typescript
// src/api/index.ts
import { AirQualityAPI } from './api-client-example';

// Create client instance
export const api = new AirQualityAPI('http://localhost:8000/api/v1');

// Or use environment variable
export const api = new AirQualityAPI(
  process.env.REACT_APP_API_URL || 'http://localhost:8000/api/v1'
);
```

### 4. React Component Usage Example

```typescript
// Login.tsx
import React, { useState } from 'react';
import { api } from './api';

export function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await api.auth.login(email, password);
      
      // Save token
      localStorage.setItem('token', response.access_token);
      api.setToken(response.access_token);
      
      // Save user
      localStorage.setItem('user', JSON.stringify(response.user));
      
      console.log('Login successful:', response.user);
      
      // Redirect to dashboard
      window.location.href = '/dashboard';
    } catch (err: any) {
      setError(err.message || 'Login error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleLogin}>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
        required
      />
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Password"
        required
      />
      {error && <p className="error">{error}</p>}
      <button type="submit" disabled={loading}>
        {loading ? 'Logging in...' : 'Login'}
      </button>
    </form>
  );
}
```

### 5. Dashboard Example

```typescript
// Dashboard.tsx
import React, { useEffect, useState } from 'react';
import { api } from './api';
import type { DashboardResponse } from './types/api-types';

export function Dashboard() {
  const [dashboard, setDashboard] = useState<DashboardResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const loadDashboard = async () => {
      try {
        // Load token from localStorage
        const token = localStorage.getItem('token');
        if (token) {
          api.setToken(token);
        }

        // Get dashboard data
        const data = await api.airQuality.getDashboard({ 
          city: 'New York' 
        });
        
        setDashboard(data);
      } catch (err: any) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    loadDashboard();
  }, []);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!dashboard) return <div>No data available</div>;

  return (
    <div className="dashboard">
      <h1>{dashboard.station.city}</h1>
      
      <div className="aqi-card">
        <h2>Average AQI</h2>
        <div className="aqi-value" style={{ 
          backgroundColor: dashboard.risk_assessment.color 
        }}>
          {dashboard.daily_stats.avg_aqi}
        </div>
        <p>{dashboard.risk_assessment.level}</p>
      </div>

      <div className="readings">
        <h2>Current Readings</h2>
        {dashboard.current_readings.map((reading, index) => (
          <div key={index} className="reading-card">
            <h3>{reading.pollutant.name}</h3>
            <p>{reading.value} {reading.pollutant.unit}</p>
            <p>AQI: {reading.aqi}</p>
          </div>
        ))}
      </div>

      <div className="recommendations">
        <h2>Recommendations</h2>
        <ul>
          {dashboard.risk_assessment.recommended_actions.map((action, i) => (
            <li key={i}>{action}</li>
          ))}
        </ul>
      </div>
    </div>
  );
}
```

---

## 🔐 Authentication Handling

### Configure Token Interceptor

```typescript
// src/api/auth-manager.ts
import { api } from './index';

export class AuthManager {
  static initialize() {
    // Load token on app start
    const token = localStorage.getItem('token');
    if (token) {
      api.setToken(token);
    }
  }

  static async login(email: string, password: string) {
    const response = await api.auth.login(email, password);
    
    // Save token and user
    localStorage.setItem('token', response.access_token);
    localStorage.setItem('user', JSON.stringify(response.user));
    
    // Set token in client
    api.setToken(response.access_token);
    
    return response;
  }

  static logout() {
    // Clear storage
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    
    // Clear client token
    api.clearToken();
    
    // Redirect to login
    window.location.href = '/login';
  }

  static getCurrentUser() {
    const userStr = localStorage.getItem('user');
    return userStr ? JSON.parse(userStr) : null;
  }

  static isAuthenticated() {
    return !!localStorage.getItem('token');
  }

  static isAdmin() {
    const user = this.getCurrentUser();
    return user?.role?.name === 'Admin';
  }
}

// Initialize on app load
AuthManager.initialize();
```

### Use in App.tsx

```typescript
// App.tsx
import { useEffect, useState } from 'react';
import { AuthManager } from './api/auth-manager';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
    setIsAuthenticated(AuthManager.isAuthenticated());
  }, []);

  return (
    <div className="App">
      {isAuthenticated ? <Dashboard /> : <Login />}
    </div>
  );
}
```

---

## 🎯 Common Use Case Examples

### 1. List Stations with Filter

```typescript
async function loadStations() {
  try {
    const stations = await api.stations.list({
      city: 'New York',
      limit: 20,
      skip: 0
    });
    
    console.log('Stations found:', stations);
    return stations;
  } catch (error) {
    console.error('Error loading stations:', error);
  }
}
```

### 2. Get Current Station Readings

```typescript
async function loadStationReadings(stationId: number) {
  try {
    const readings = await api.stations.getCurrentReadings(stationId);
    
    console.log('Readings:', readings.readings);
    console.log('Last updated:', readings.last_updated);
    
    return readings;
  } catch (error) {
    console.error('Error loading readings:', error);
  }
}
```

### 3. Get Personalized Recommendation

```typescript
async function getRecommendation(location: string) {
  try {
    const recommendation = await api.recommendations.getCurrent({ 
      location 
    });
    
    console.log('Health advice:', recommendation.health_advice);
    console.log('Recommended actions:', recommendation.actions);
    console.log('Products:', recommendation.products);
    
    return recommendation;
  } catch (error) {
    console.error('Error getting recommendation:', error);
  }
}
```

### 4. Update User Preferences

```typescript
async function updateTheme(theme: 'light' | 'dark') {
  try {
    const preferences = await api.settings.updatePreferences({
      theme: theme
    });
    
    console.log('Preferences updated:', preferences);
    return preferences;
  } catch (error) {
    console.error('Error updating preferences:', error);
  }
}
```

### 5. Admin: Create New Station

```typescript
async function createStation() {
  try {
    const newStation = await api.admin.createStation({
      name: 'Brooklyn Station',
      latitude: 40.6782,
      longitude: -73.9442,
      city: 'Brooklyn',
      country: 'USA',
      region_id: 1
    });
    
    console.log('Station created:', newStation);
    return newStation;
  } catch (error) {
    if (error.statusCode === 403) {
      console.error('You do not have admin permissions');
    } else {
      console.error('Error creating station:', error);
    }
  }
}
```

### 6. Generate Report

```typescript
async function generateReport() {
  try {
    const report = await api.reports.create({
      city: 'New York',
      start_date: '2025-11-01',
      end_date: '2025-11-27',
      station_id: 1,
      pollutant_id: 1
    });
    
    console.log('Report generated:', report);
    console.log('Download from:', report.file_path);
    
    return report;
  } catch (error) {
    console.error('Error generating report:', error);
  }
}
```

---

## 🎨 React Query Integration (Optional)

If you use React Query for state management:

```typescript
// hooks/useAirQuality.ts
import { useQuery } from '@tanstack/react-query';
import { api } from '../api';

export function useCurrentAQI(city: string) {
  return useQuery({
    queryKey: ['aqi', city],
    queryFn: () => api.airQuality.getCurrentAQI(city),
    enabled: !!city,
    refetchInterval: 300000, // Refetch every 5 minutes
  });
}

export function useDashboard(city?: string, stationId?: number) {
  return useQuery({
    queryKey: ['dashboard', city, stationId],
    queryFn: () => api.airQuality.getDashboard({ city, station_id: stationId }),
    enabled: !!(city || stationId),
    refetchInterval: 300000,
  });
}

export function useStations(filters?: { city?: string; country?: string }) {
  return useQuery({
    queryKey: ['stations', filters],
    queryFn: () => api.stations.list(filters),
  });
}

export function useRecommendation(location?: string, aqi?: number) {
  return useQuery({
    queryKey: ['recommendation', location, aqi],
    queryFn: () => api.recommendations.getCurrent({ location, aqi }),
    enabled: !!location || !!aqi,
  });
}
```

Usage in component:

```typescript
function DashboardWithQuery() {
  const { data, isLoading, error } = useDashboard('New York');

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return <div>AQI: {data.daily_stats.avg_aqi}</div>;
}
```

---

## 🌐 Environment Variables

Create a `.env` file in your frontend project:

```bash
# .env
REACT_APP_API_URL=http://localhost:8000/api/v1
VITE_API_URL=http://localhost:8000/api/v1  # If using Vite

# Production
# REACT_APP_API_URL=https://api.airquality.com/api/v1
```

Use in code:

```typescript
const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api/v1';
export const api = new AirQualityAPI(API_URL);
```

---

## 🔍 Debugging and Logging

Add logging to the client:

```typescript
// api/logger.ts
export class APILogger {
  static log(method: string, endpoint: string, data?: any) {
    if (process.env.NODE_ENV === 'development') {
      console.log(`[API] ${method} ${endpoint}`, data);
    }
  }

  static error(method: string, endpoint: string, error: any) {
    console.error(`[API Error] ${method} ${endpoint}`, error);
  }
}
```

---

## 📱 Complete Example: Air Quality App

```typescript
// App.tsx - Complete application
import React, { useEffect, useState } from 'react';
import { api } from './api';
import { AuthManager } from './api/auth-manager';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [currentView, setCurrentView] = useState('dashboard');

  useEffect(() => {
    setIsAuthenticated(AuthManager.isAuthenticated());
  }, []);

  if (!isAuthenticated) {
    return <LoginPage onLogin={() => setIsAuthenticated(true)} />;
  }

  return (
    <div className="app">
      <Sidebar onNavigate={setCurrentView} />
      <main>
        {currentView === 'dashboard' && <Dashboard />}
        {currentView === 'stations' && <StationsList />}
        {currentView === 'recommendations' && <Recommendations />}
        {currentView === 'reports' && <Reports />}
        {currentView === 'settings' && <Settings />}
      </main>
    </div>
  );
}

function LoginPage({ onLogin }: { onLogin: () => void }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await AuthManager.login(email, password);
      onLogin();
    } catch (error) {
      alert('Login error');
    }
  };

  return (
    <div className="login-page">
      <form onSubmit={handleLogin}>
        <h1>Air Quality Monitor</h1>
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="Email"
        />
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password"
        />
        <button type="submit">Login</button>
      </form>
    </div>
  );
}

export default App;
```

---

## 🚨 Error Handling

```typescript
import { APIError } from './api/api-client-example';

async function handleAPICall() {
  try {
    const data = await api.airQuality.getCurrentAQI('New York');
    return data;
  } catch (error) {
    if (error instanceof APIError) {
      switch (error.statusCode) {
        case 401:
          // Token expired, redirect to login
          AuthManager.logout();
          break;
        case 403:
          alert('You do not have permission for this action');
          break;
        case 404:
          alert('Resource not found');
          break;
        case 422:
          alert('Invalid input data');
          break;
        default:
          alert(`Error: ${error.message}`);
      }
    } else {
      alert('Network error or server unavailable');
    }
  }
}
```

---

## ✅ Integration Checklist

- [ ] Copy `api-types.ts` to project
- [ ] Copy `api-client-example.ts` to project
- [ ] Configure `API_URL` environment variable
- [ ] Create `AuthManager` for authentication handling
- [ ] Implement Login page
- [ ] Implement main Dashboard
- [ ] Test public endpoints (stations, air-quality)
- [ ] Test authenticated endpoints (recommendations, settings)
- [ ] Test admin endpoints (if applicable)
- [ ] Implement error handling
- [ ] Add loading states
- [ ] Add form validation

---

## 📚 Additional Resources

- **Complete documentation**: See `API_CONTRACT.md`
- **TypeScript types**: See `api-types.ts`
- **API client**: See `api-client-example.ts`

---

## 🆘 Support

If you encounter issues during integration, verify:

1. ✅ Backend is running at `http://localhost:8000`
2. ✅ CORS is enabled in the backend
3. ✅ Authentication token is valid
4. ✅ Sent data complies with validation schemas

**Happy coding! 🎉**
