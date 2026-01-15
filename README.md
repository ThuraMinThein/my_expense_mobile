# My Expense - Flutter Mobile App

A simple and beautiful expense tracking app that follows the philosophy: "Record expenses first → Track usage later".

## Features

- **📝 Easy Expense Recording**: Quick and intuitive expense entry with numeric keypad
- **📊 Analytics & Insights**: Visual charts to understand spending patterns
- **📚 Expense History**: Categorized and organized expense tracking
- **👤 User Profile**: Personalized settings and preferences
- **🎨 Beautiful UI**: Clean, minimal design with soft green theme

## Tech Stack

- **Flutter**: Latest stable with Material 3
- **State Management**: Riverpod for reactive state management
- **Navigation**: go_router with persistent bottom navigation
- **Networking**: Dio for API integration
- **Charts**: fl_chart for beautiful analytics
- **Authentication**: Google Sign-In ready
- **Storage**: SharedPreferences for local settings

## Project Structure

```
lib/
├── core/
│   ├── theme/          # App theme and colors
│   ├── widgets/         # Shared UI components
│   ├── constants/       # App constants and enums
│   ├── utils/          # Utility functions
│   └── providers/      # Global app providers
├── features/
│   ├── auth/            # Authentication screens and services
│   ├── expense/         # Expense management (add, history)
│   ├── analytics/        # Analytics and charts
│   └── profile/         # User profile and settings
├── routes/              # Navigation configuration
└── main.dart           # App entry point
```

## Getting Started

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

3. **Build for production**:
   ```bash
   flutter build apk --release
   ```

## Key Features Implementation

### Authentication Flow
- Welcome screen with app illustration
- Login with email/password
- Google Sign-In integration ready
- Secure session management

### Bottom Navigation
- **Add** (Default tab): Quick expense entry
- **History**: View and manage expenses
- **Analytics**: Charts and insights (no FAB)
- **Profile**: User settings and preferences

### Add Expense Screen
- Large amount display
- Numeric keypad for easy entry
- Category selection with colored chips
- Date picker (defaults to today)
- Optional notes field
- One-hand friendly layout

### Expense History
- Grouped by date
- Daily/Weekly/Monthly toggle
- Category icons and amounts
- Clean card-based layout

### Analytics Screen
- Daily/Weekly/Monthly toggle
- Line charts for trends
- Category breakdown with percentages
- Summary cards (total, average)
- **No Add button** (per requirements)

### Profile Screen
- User avatar and info
- Currency selector
- Dark mode toggle
- App version and about
- Logout functionality

## Design Principles

- **Super Easy**: Minimal steps to add expenses
- **Super Friendly**: Warm colors and welcoming UI
- **Calm & Minimal**: Clean interface without clutter
- **Fast to Use**: One-hand operation support

## Development Notes

- Uses feature-based architecture for scalability
- Riverpod for efficient state management
- Mock data ready for UI preview
- API service classes prepared (scaffold only)
- Proper loading and error states
- Responsive design for various screen sizes

## Future Enhancements

- [ ] Real backend API integration
- [ ] Expense editing functionality
- [ ] Budget tracking and alerts
- [ ] Export data functionality
- [ ] Categories management
- [ ] Recurring expenses support