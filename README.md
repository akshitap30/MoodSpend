# MoodSpend

A behaviour-change app at the intersection of emotional intelligence and personal finance.

MoodSpend empowers users to understand and improve their spending habits by connecting emotional well-being with financial decisions. Track your mood, log your expenses, and discover the patterns between how you feel and how you spend.

## Features

- **Mood Logging** - Record your emotional state throughout the day
- **Expense Tracking** - Log and categorize your spending with mood context
- **Habit Management** - Build positive financial and wellbeing habits
- **Challenges** - Participate in behavioral change challenges to improve spending habits
- **Insights & Analytics** - Visualize spending patterns and mood correlations with interactive charts
- **Offline First** - Full offline functionality with local storage via Hive
- **Personalized Dashboard** - Get a quick overview of your financial and emotional metrics
- **Profile Management** - Customize your experience and preferences
- **Sharing** - Share insights and achievements with others

## Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile development
- **Riverpod** - State management
- **Go Router** - Navigation and routing
- **Flutter Riverpod** - Reactive data flow

### Backend & Storage
- **Supabase** - Backend-as-a-Service (authentication, database, real-time)
- **Hive** - Local offline-first database
- **Dart Hive Generator** - Code generation for Hive models

### UI & Visualization
- **FL Chart** - Interactive charts and graphs
- **Flutter SVG** - SVG asset support
- **Google Fonts** - Typography
- **Material Design** - UI components

### Utilities
- **Flutter Local Notifications** - Push notifications
- **UUID** - Unique identifier generation
- **Intl** - Internationalization and formatting
- **Path Provider** - Platform-specific file system access
- **Share Plus** - Native sharing capabilities

## Project Structure
lib/
├── main.dart # App entry point
├── core/
│ ├── models/ # Data models
│ ├── navigation/ # App routing & navigation
│ ├── providers/ # Riverpod providers (state)
│ ├── services/ # Business logic & API services
│ ├── theme/ # Theme configuration
│ └── widgets/ # Reusable widgets
└── features/
├── auth/ # Authentication & login
├── onboarding/ # First-time user experience
├── dashboard/ # Home & overview screen
├── mood/ # Mood logging
├── log/ # Expense logging
├── habits/ # Habit tracking
├── challenge/ # Challenges feature
├── insights/ # Analytics & data visualization
├── profile/ # User profile & settings
├── swap/ # Transaction features
└── splash/ # Splash screen

## Database Schema
The app uses a hybrid storage approach:

Hive (Local) - Offline-first local database for habits, mood logs, challenges, and saved jar entries
Supabase (Remote) - Cloud database for user data sync and authentication
See supabase_schema.sql for the cloud database structure.

## Architecture
The app follows a clean architecture pattern with clear separation of concerns:

Models - Data structures and entities
Services - Business logic and API communication
Providers - State management with Riverpod
Widgets - UI components and screens
Contributing
Contributions are welcome! Please:

Create a feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request

## Support
For issues, feature requests, or questions, please open an issue in the repository.

## Roadmap
 Add multiple currency support
 Implement advanced analytics with ML predictions
 Social features for group challenges
 Budget planning and recommendations
 Recurring transaction automation



Built with ❤️ using Flutter



