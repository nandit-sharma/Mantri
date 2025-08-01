# Gang App - Flutter Frontend

A complete Flutter application for managing gangs/groups with modern UI and full functionality.

## Color Palette
- Primary: `#1A2634` (Dark Blue)
- Secondary: `#203E5F` (Medium Blue) 
- Accent: `#FFCC00` (Yellow)
- Background: `#FEE5B1` (Light Cream)

## Features

### Home Page
- **Sidebar Menu**: User profile, navigation options, settings, logout
- **Create Gang Button**: Navigate to gang creation page
- **Join Gang Button**: Navigate to gang joining page
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

### Gang Home Page
- **Chat Icon**: Top navigation for messaging (feature coming soon)
- **More Options**: 3-dot menu with gang management options
- **Gang Info**: Display gang name, description, member count
- **Members List**: Show all gang members with roles
- **Recent Activity**: Display recent gang activities
- **Action Buttons**: Create events, share gang

## Navigation Flow
1. **Home** → Create Gang → Gang Home
2. **Home** → Join Gang → Request Sent → Back to Home
3. **Home** → Your Gangs → Gang Home

## Backend Integration Ready
The app is structured to easily integrate with a backend:
- Gang data models ready for API integration
- User authentication structure in place
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
│   ├── home_page.dart     # Main home with sidebar
│   ├── create_gang_page.dart  # Gang creation form
│   ├── join_gang_page.dart    # Gang joining interface
│   └── gang_home_page.dart    # Gang management page
```

## Features Coming Soon
- Real-time chat functionality
- Event creation and management
- Member management (kick, promote, etc.)
- Gang settings and customization
- User authentication and profiles
- Push notifications
- File sharing within gangs
