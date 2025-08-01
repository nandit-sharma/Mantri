# Mantri - Gang Management App

A Flutter application with FastAPI backend for managing gangs and tracking daily saves with weekly leaderboards.

## 🚀 Features

### Authentication
- **User Registration**: Create account with email, username, and password
- **User Login**: Secure JWT-based authentication
- **Session Management**: Automatic token storage and validation

### Gang Management
- **Create Gangs**: Create new gangs with custom names, descriptions, and privacy settings
- **Join Gangs**: Join existing gangs using 5-digit gang IDs
- **Gang Home**: View gang details, members, and activities

### Daily Save System
- **Yes/No Buttons**: Simple green/red buttons for daily save tracking
- **Weekly Record Display**: Visual ticks and crosses for each day of the week
- **Real-time Updates**: Instant feedback when saving

### Weekly Leaderboards
- **Automatic Sorting**: Members ranked by weekly saves
- **Visual Rankings**: Gold, silver, bronze medals for top performers
- **Host Badges**: Special indicators for gang hosts

### Navigation & UI
- **Professional Design**: Clean, modern UI with custom color palette
- **Bottom Navigation**: Easy switching between Home, Members, and Activity tabs
- **Sidebar Menu**: Quick access to all app features
- **Responsive Layout**: Works on all screen sizes

## 🎨 Color Palette

- **Primary**: `#1A2634` (Dark Blue)
- **Secondary**: `#203E5F` (Medium Blue)
- **Accent**: `#FFCC00` (Gold)
- **Background**: `#FEE5B1` (Light Cream)

## 📱 Pages

### Authentication
- **Login Page**: Email/password authentication
- **Register Page**: New user registration

### Main App
- **Home Page**: Dashboard with gang list and quick actions
- **Create Gang**: Form to create new gangs
- **Join Gang**: Search and join existing gangs
- **Gang Home**: Main gang interface with daily saves and leaderboards
- **Chat Page**: Real-time messaging (coming soon)
- **Profile Page**: User statistics and achievements
- **Settings Page**: App preferences and account management

## 🏗️ Architecture

### Frontend (Flutter)
- **State Management**: StatefulWidget with setState
- **Navigation**: Named routes with Navigator
- **API Integration**: HTTP requests with error handling
- **Local Storage**: SharedPreferences for token management

### Backend (FastAPI)
- **Authentication**: JWT tokens with bcrypt password hashing
- **Database**: PostgreSQL with SQLAlchemy ORM
- **API Design**: RESTful endpoints with Pydantic validation
- **Background Tasks**: Daily and weekly reset automation

## 🗄️ Database Schema

### Users
- `id`, `email`, `username`, `hashed_password`, `created_at`

### Gangs
- `id`, `name`, `description`, `is_public`, `gang_id`, `created_by`, `created_at`

### Gang Members
- `id`, `user_id`, `gang_id`, `role`, `joined_at`

### Daily Saves
- `id`, `user_id`, `gang_id`, `saved`, `save_date`, `created_at`

## ⚙️ Setup Instructions

### Backend Setup

1. **Install Python dependencies**:
   ```bash
   cd mantri/backend
   pip install -r requirements.txt
   ```

2. **Set up PostgreSQL**:
   ```sql
   CREATE DATABASE mantri_db;
   CREATE USER mantri_user WITH PASSWORD 'mantri_password';
   GRANT ALL PRIVILEGES ON DATABASE mantri_db TO mantri_user;
   ```

3. **Configure environment**:
   Create `.env` file in `mantri/backend/`:
   ```
   DATABASE_URL=postgresql://mantri_user:mantri_password@localhost:5432/mantri_db
   SECRET_KEY=your-secret-key-here-change-in-production
   ALGORITHM=HS256
   ACCESS_TOKEN_EXPIRE_MINUTES=30
   ```

4. **Run backend**:
   ```bash
   python main.py
   ```

### Frontend Setup

1. **Install Flutter dependencies**:
   ```bash
   cd mantri/frontend
   flutter pub get
   ```

2. **Run Flutter app**:
   ```bash
   flutter run
   ```

## 🔄 API Endpoints

### Authentication
- `POST /register` - User registration
- `POST /login` - User login
- `GET /me` - Get current user

### Gangs
- `POST /gangs` - Create gang
- `GET /gangs/{gang_id}` - Get gang details
- `POST /gangs/{gang_id}/join` - Join gang
- `GET /gangs/{gang_id}/home` - Get gang home data
- `POST /gangs/{gang_id}/save` - Save today's status
- `GET /user/gangs` - Get user's gangs

## 🔄 Daily/Weekly Reset System

### Daily Reset (1 AM)
- Resets daily save status for all users
- Allows new saves for the current day
- Updates weekly records

### Weekly Reset (Monday 1 AM)
- Resets weekly leaderboards
- Clears weekly save counts
- Starts new weekly cycle

## 🎯 Key Features

### Real-time Weekly Records
- Shows current week's save status
- Displays ticks (✓) for saved days
- Shows crosses (✗) for unsaved days
- Future days appear blank until reached

### Smart Leaderboard
- Automatically sorts by weekly saves
- Updates in real-time
- Shows member roles and statistics

### Authentication Flow
- Redirects to login if not authenticated
- Prevents access to gang features without login
- Secure token-based session management

## 🚧 Future Features

- **Real-time Chat**: WebSocket-based messaging
- **Push Notifications**: Daily reminders and achievements
- **Achievement System**: Badges and rewards
- **File Sharing**: Document and media sharing
- **Advanced Analytics**: Detailed statistics and insights
- **Mobile Notifications**: Background sync and alerts

## 🛠️ Development

### Code Structure
```
mantri/
├── backend/
│   ├── main.py          # FastAPI application
│   ├── models.py        # Database models
│   ├── schemas.py       # Pydantic schemas
│   ├── auth.py          # Authentication utilities
│   ├── utils.py         # Helper functions
│   └── requirements.txt # Python dependencies
└── frontend/
    ├── lib/
    │   ├── main.dart    # App entry point
    │   ├── services/    # API service
    │   └── pages/       # UI pages
    └── pubspec.yaml     # Flutter dependencies
```

### Testing
```bash
# Backend tests
cd mantri/backend
pytest

# Frontend tests
cd mantri/frontend
flutter test
```

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

For support and questions, please open an issue in the repository. 