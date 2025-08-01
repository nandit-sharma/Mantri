# Mantri - Gang Management App

A complete Flutter application for managing gangs/groups with daily check-ins, weekly achievements, and leaderboards.

## Color Palette
- Primary: `#1A2634` (Dark Blue)
- Secondary: `#203E5F` (Medium Blue) 
- Accent: `#FFCC00` (Yellow)
- Background: `#FEE5B1` (Light Cream)

## Core Features

### Home Page
- **Sidebar Menu**: User profile, navigation options, leaderboard, settings, logout
- **Create Gang Button**: Navigate to gang creation page
- **Join Gang Button**: Navigate to gang joining page
- **Monthly Leaderboard**: Global ranking based on saves across all gangs
- **Your Gangs Section**: Display all user's gangs with member count and IDs
- **Settings Button**: Top-right corner for quick access

### Create Gang Page
- **Gang Name Input**: Required field with validation
- **Description Input**: Required field for gang description
- **Privacy Toggle**: Public/Private gang settings
- **Auto-generated ID**: 5-digit unique gang ID with refresh option
- **Create Button**: Validates and creates gang, navigates to gang home

### Join Gang Page
- **Gang ID Input**: 5-digit number validation
- **Search Functionality**: Finds gang by ID
- **Gang Preview**: Shows gang details before joining
- **Request to Join**: Sends join request to gang host
- **Loading States**: Proper loading indicators

### Gang Home Page (NEW)
- **Bottom Navigation**: Home, Members, Activity tabs
- **Daily Check-in**: "Did you save today?" checkbox with daily tracking
- **Weekly Leaderboard**: Ranked list of members based on weekly saves
- **Gang Info**: Display gang name, description, member count
- **Members List**: Show all gang members with roles and save counts
- **Recent Activity**: Display recent gang activities and achievements
- **Chat Icon**: Top navigation for messaging
- **More Options**: 3-dot menu with gang management options

### Daily Save System
- **Daily Checkbox**: Users mark if they saved each day
- **Weekly Analysis**: System analyzes all members' saves weekly
- **Achievements**: Most saves gets achievement X, least gets achievement Y
- **Weekly Reset**: System resets every week for new cycle
- **Notifications**: All members notified about weekly results

### Chat Page (NEW)
- **Real-time Messaging**: Send and receive messages
- **Message Bubbles**: Different styles for sent vs received messages
- **User Avatars**: Display user initials in chat
- **Timestamp**: Show message times
- **Send Button**: Easy message sending

### Profile Page (NEW)
- **User Information**: Name, email, avatar
- **Statistics**: Total saves, current streak, best streak, gangs joined
- **Achievements**: List of earned achievements with dates
- **Edit Profile**: Button to modify user information

### Settings Page (NEW)
- **App Settings**: Notifications, dark mode, auto save, weekly reminders
- **Preferences**: Language selection, privacy policy, terms of service
- **Account Management**: Change password, export data, delete account
- **Logout**: Secure logout functionality

## Navigation Flow
1. **Home** → Create Gang → Gang Home
2. **Home** → Join Gang → Request Sent → Back to Home
3. **Home** → Your Gangs → Gang Home
4. **Gang Home** → Chat (via chat icon)
5. **Sidebar** → Profile/Settings

## Weekly Achievement System
- **Daily Tracking**: Each member checks "Did you save today?"
- **Weekly Analysis**: System counts all saves for the week
- **Achievement Distribution**: 
  - Most saves: Achievement X (e.g., "Weekly Champion")
  - Least saves: Achievement Y (e.g., "Needs Motivation")
- **Weekly Reset**: All counters reset every Sunday
- **Notifications**: All members get notified of results

## Leaderboard System
- **Weekly Leaderboard**: Within each gang, ranked by weekly saves
- **Monthly Leaderboard**: Global ranking across all gangs
- **Achievement Icons**: Special icons for top 3 positions
- **Streak Tracking**: Current and best save streaks

## Backend Integration Ready
The app is structured to easily integrate with a backend:
- Gang data models ready for API integration
- User authentication structure in place
- Daily save tracking system
- Weekly achievement calculation logic
- Form validation and error handling
- Loading states for async operations
- Proper state management patterns

## Getting Started
```bash
cd mantri/frontend
flutter pub get
flutter run
```

## File Structure
```
lib/
├── main.dart              # App entry point and theme
├── pages/
│   ├── home_page.dart     # Main home with sidebar and leaderboard
│   ├── create_gang_page.dart  # Gang creation form
│   ├── join_gang_page.dart    # Gang joining interface
│   ├── gang_home_page.dart    # Gang management with daily check-ins
│   ├── chat_page.dart         # Real-time messaging
│   ├── profile_page.dart      # User profile and achievements
│   └── settings_page.dart     # App settings and preferences
```

## Features Coming Soon
- Real-time chat with WebSocket integration
- Push notifications for achievements
- Event creation and management
- Member management (kick, promote, etc.)
- Gang settings and customization
- User authentication and profiles
- File sharing within gangs
- Advanced analytics and insights
