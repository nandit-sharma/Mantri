# Mantri Backend API

FastAPI backend for the Mantri app with PostgreSQL database support.

## 🚀 Render Deployment

### Environment Variables

Set these environment variables in your Render service:

#### Required Variables:
```
DATABASE_URL=postgresql://mantri_user:mqU4UjjZjGTru9dSgijxZYicLudE2Psv@dpg-d27r4ru3jp1c73fli38g-a.oregon-postgres.render.com/mantri
SECRET_KEY=ka4HpgwYemg-6krueqV1ydlWykAk18kT14Xmvy58YOo
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

#### Recommended Variables:
```
BACKEND_CORS_ORIGINS=https://your-frontend-app.vercel.app,http://localhost:3000
PROJECT_NAME=Mantri API
VERSION=1.0.0
API_V1_STR=/api/v1
ENVIRONMENT=production
```

### Render Service Configuration

1. **Build Command**: `pip install -r requirements.txt`
2. **Start Command**: `python start.py`
3. **Python Version**: 3.11 or 3.12

### API Endpoints

- **Base URL**: `https://your-render-service.onrender.com`
- **Documentation**: `https://your-render-service.onrender.com/docs`
- **OpenAPI**: `https://your-render-service.onrender.com/api/v1/openapi.json`

### Database

The app will automatically create all required tables on startup.

### CORS Configuration

Update `BACKEND_CORS_ORIGINS` with your frontend domain(s):
- For development: `http://localhost:3000`
- For production: `https://your-frontend-app.vercel.app`
- For multiple domains: `https://domain1.com,https://domain2.com`

## 🛠️ Local Development

1. Install dependencies: `pip install -r requirements.txt`
2. Set up environment variables (see `env_template.txt`)
3. Run: `python start.py`
4. Access API docs at: `http://localhost:8000/docs` 