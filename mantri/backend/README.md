# Mantri Backend

A FastAPI backend for the Mantri gang management application.

## Features

- **User Authentication**: JWT-based authentication with registration and login
- **Gang Management**: Create, join, and manage gangs
- **Daily Save Tracking**: Track daily saves for each user in their gangs
- **Weekly Leaderboards**: Automatic weekly leaderboard generation
- **Real-time Updates**: Background tasks for daily and weekly resets

## Setup

### Prerequisites

- Python 3.8+
- PostgreSQL database
- pip (Python package manager)

### Installation

1. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Set up PostgreSQL database**:
   ```sql
   CREATE DATABASE mantri_db;
   CREATE USER mantri_user WITH PASSWORD 'mantri_password';
   GRANT ALL PRIVILEGES ON DATABASE mantri_db TO mantri_user;
   ```

3. **Configure environment variables**:
   Create a `.env` file in the backend directory:
   ```
   DATABASE_URL=postgresql://mantri_user:mantri_password@localhost:5432/mantri_db
   SECRET_KEY=your-secret-key-here-change-in-production
   ALGORITHM=HS256
   ACCESS_TOKEN_EXPIRE_MINUTES=30
   ```

4. **Run the application**:
   ```bash
   python main.py
   ```

   Or using uvicorn directly:
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

## API Endpoints

### Authentication
- `POST /register` - Register a new user
- `POST /login` - Login user
- `GET /me` - Get current user info

### Gangs
- `POST /gangs` - Create a new gang
- `GET /gangs/{gang_id}` - Get gang details
- `POST /gangs/{gang_id}/join` - Join a gang
- `GET /gangs/{gang_id}/home` - Get gang home data
- `POST /gangs/{gang_id}/save` - Save today's status
- `GET /user/gangs` - Get user's gangs

## Database Schema

### Users
- `id`: Primary key
- `email`: Unique email address
- `username`: Unique username
- `hashed_password`: Bcrypt hashed password
- `created_at`: Timestamp

### Gangs
- `id`: Primary key
- `name`: Gang name
- `description`: Gang description
- `is_public`: Public/private status
- `gang_id`: Unique 5-digit ID
- `created_by`: User ID of creator
- `created_at`: Timestamp

### Gang Members
- `id`: Primary key
- `user_id`: Foreign key to users
- `gang_id`: Foreign key to gangs
- `role`: 'host' or 'member'
- `joined_at`: Timestamp

### Daily Saves
- `id`: Primary key
- `user_id`: Foreign key to users
- `gang_id`: Foreign key to gangs
- `saved`: Boolean save status
- `save_date`: Date of save
- `created_at`: Timestamp

## Background Tasks

The application includes background tasks for:

1. **Daily Reset**: At 1 AM daily, the system resets daily save status
2. **Weekly Reset**: At 1 AM on Mondays, the system resets weekly leaderboards

## Security Features

- JWT token authentication
- Password hashing with bcrypt
- Input validation with Pydantic
- SQL injection protection with SQLAlchemy

## Development

### Running Tests
```bash
pytest
```

### Database Migrations
```bash
alembic upgrade head
```

### Code Formatting
```bash
black .
isort .
```

## Production Deployment

1. **Set up a production database**
2. **Configure environment variables**
3. **Use a production WSGI server like Gunicorn**
4. **Set up reverse proxy (nginx)**
5. **Configure SSL certificates**

Example production command:
```bash
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
``` 