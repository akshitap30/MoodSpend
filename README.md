<div align="center">

# 💸 MoodSpend

**Track your emotions. Understand your spending. Build lasting wealth.**

[![CI](https://github.com/akshitap30/MoodSpend/actions/workflows/ci.yml/badge.svg)](https://github.com/akshitap30/MoodSpend/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.22-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4-0175C2?logo=dart)](https://dart.dev)

MoodSpend is a behaviour-change app at the intersection of emotional intelligence and personal finance. It helps users log their mood alongside every spending decision, detect emotional trigger patterns in their habits, and redirect impulse spending toward meaningful financial goals.

</div>

---

## 🧠 What is MoodSpend?

Most budgeting apps tell you *what* you spent. MoodSpend tells you *why*.

Every time you make a discretionary purchase — morning coffee, a Swiggy order, an impulse Amazon buy — your emotional state is a hidden factor. MoodSpend captures that data point, finds the recurring patterns, and turns them into personalised nudges that help you build better habits over time.

**The core loop:**
1. **Log** your current mood, energy, and any associated spending
2. **Discover** which emotional states reliably trigger expensive habits
3. **Accept a weekly challenge** to skip one triggered habit and redirect the savings
4. **Watch your Saved Jar grow** toward your chosen financial goal

---

## ✨ Features

### 😊 Mood & Spending Log
A frictionless daily check-in captures mood (1–5), energy level (1–10), emotional context tags (stressed, bored, happy…), the habit triggered, the amount spent, and an optional note — all in one screen.

### 🏋️ Habit Library
Create, browse, and manage your discretionary spending habits (food, transport, subscriptions, and more). The onboarding flow seeds a personal habit list from common spending categories.

### 📊 Spending Insights
A dedicated insights screen visualises the relationship between mood states and spending using charts:
- **Mood vs. Spend bar chart** — average spend for each mood level
- **Trigger tag heatmap** — which emotional contexts cost you most
- **Weekly spend heatmap** — peak spending windows across time of day and day of week

### 🔍 On-Device Pattern Detection
A lightweight statistical engine (`PatternService`) runs entirely on device — no server ML required. It identifies the habit you spend most on, the mood bucket and context tags that trigger it, and the peak hour window, then generates a human-readable insight and a confidence score.

### 🎯 Weekly Behavioural Challenges
When a pattern is detected, MoodSpend automatically generates a personalised weekly challenge: skip the triggered habit once during an identified trigger window and replace it with a healthy alternative action (walk, breathe, hydrate, journal). Completing a challenge credits the avoided spend directly to your Saved Jar.

### 💰 Saved Jar
A running total of money redirected from impulse spending toward your goal. Every completed challenge adds to the jar. The jar tracks source challenges and a running balance so you can see your cumulative progress.

### 📈 Future You Simulator
An interactive projection tool that lets you visualise the long-term compounding impact of your current spending habits. Adjust timelines and habit reduction rates to model different "future you" scenarios and stay motivated.

### 🔄 Habit Swap
For any active habit, see a breakdown of what it costs per month/year in real money and in "work days lost". Swap to a cheaper alternative or disable the habit entirely.

### 👤 Profile & Settings
Manage your personal goal (vacation, down payment, investment, emergency fund, or custom), your hourly wage (used to convert money to time cost), notification preferences (daily reminders, weekly summaries, challenge nudges, peak-window alerts), and member stats including your current streak.

### 🔔 Local Notifications
Configurable push reminders to log your mood at your preferred daily time, weekly summaries, challenge nudges, and peak-window spending alerts — all handled on-device via Flutter Local Notifications.

### 🔒 Offline-First Architecture
All user data lives in **Hive** (local device storage) with no mandatory internet connection. The app is fully usable offline. A **Supabase** schema and service layer are included for future cloud-sync functionality.

---

## 📸 Screenshots

> Place your screenshot images in the `screenshots/` directory and they will render here on GitHub.

### Authentication
| Login |
|-------|
| ![Login screen](screenshots/login.png) |

### Onboarding
| Goal Selection | Hourly Income | Spending Habits |
|----------------|---------------|-----------------|
| ![Goal selection](screenshots/onboarding_goal.png) | ![Hourly income](screenshots/onboarding_income.png) | ![Spending habits](screenshots/onboarding_habits.png) |

### Dashboard
| Home Dashboard |
|----------------|
| ![Dashboard](screenshots/dashboard.png) |

### Mood & Habit Logging
| Log Screen | Log with Habit Details |
|------------|------------------------|
| ![Log screen](screenshots/log.png) | ![Log with habit](screenshots/log_habit.png) |

### Future You Simulator
| Simulator |
|-----------|
| ![Simulator](screenshots/simulator.png) |

---

## 🛠️ Tech Stack

### Frontend
| Technology | Purpose |
|------------|---------|
| [Flutter 3.22](https://flutter.dev) | Cross-platform UI framework |
| [Dart 3.4](https://dart.dev) | Language |
| [Flutter Riverpod](https://riverpod.dev) | State management |
| [Go Router](https://pub.dev/packages/go_router) | Declarative navigation |

### Local Storage
| Technology | Purpose |
|------------|---------|
| [Hive](https://pub.dev/packages/hive) + [Hive Flutter](https://pub.dev/packages/hive_flutter) | Offline-first local database |
| [Path Provider](https://pub.dev/packages/path_provider) | Device file system access |

### Backend / Cloud (future sync)
| Technology | Purpose |
|------------|---------|
| [Supabase](https://supabase.com) | PostgreSQL database + auth + RLS policies |

### Visualisation & UI
| Technology | Purpose |
|------------|---------|
| [FL Chart](https://pub.dev/packages/fl_chart) | Bar charts and line charts |
| [Flutter SVG](https://pub.dev/packages/flutter_svg) | SVG asset rendering |
| [Google Fonts](https://pub.dev/packages/google_fonts) | Typography |
| Material Design 3 | Design system |

### Utilities
| Technology | Purpose |
|------------|---------|
| [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications) | On-device push reminders |
| [Share Plus](https://pub.dev/packages/share_plus) | Native sharing |
| [UUID](https://pub.dev/packages/uuid) | Unique ID generation |
| [Intl](https://pub.dev/packages/intl) | Date/number formatting |

---

## 🏗️ Architecture

MoodSpend uses a **feature-first folder structure** with a shared `core` layer.

```
lib/
├── main.dart                 # App entry point — Hive init, adapters, ProviderScope
├── core/
│   ├── models/               # Data models (UserModel, HabitModel, MoodLogModel, …)
│   ├── providers/            # Riverpod providers & state notifiers (settings, habits, logs, …)
│   ├── services/             # Business logic (PatternService, SupabaseService)
│   ├── navigation/           # GoRouter config, shell route, bottom nav
│   ├── theme/                # AppColors, AppTextStyles, AppTheme (dark)
│   └── widgets/              # Shared reusable widgets (AppButton, etc.)
└── features/
    ├── splash/               # Animated splash screen
    ├── auth/                 # Local authentication (no server required)
    ├── onboarding/           # 3-step onboarding: goal → wage → habits
    ├── dashboard/            # Personalized home — streak, jar progress, challenge card
    ├── log/                  # Mood + spending log entry
    ├── habits/               # Habit library + add/edit habits
    ├── insights/             # Charts: mood–spend, tag heatmap, weekly heatmap
    ├── simulator/            # Future-You projection simulator
    ├── challenge/            # Weekly behavioural challenge
    ├── jar/                  # Saved jar history and balance
    ├── swap/                 # Habit swap / cost breakdown
    └── profile/              # Profile, goal settings, notifications
```

### State Flow

```
Hive (on-device) ──► Riverpod Notifiers ──► UI Screens
                              │
                    PatternService (pure Dart)
                              │
                    ChallengeNotifier ──► SavedJarNotifier
```

All state lives in Riverpod `Notifier` providers that hydrate from Hive on startup and persist changes back on every mutation. The router uses a `ChangeNotifier` bridge to react to `settingsProvider` changes and redirect unauthenticated or un-onboarded users automatically.

---

## 🗄️ Database / Storage

### Local — Hive
All app data is stored in typed Hive boxes, making the app fully functional offline:

| Box | Type | Contents |
|-----|------|----------|
| `habits` | `Box<HabitModel>` | User's spending habits |
| `mood_logs` | `Box<MoodLogModel>` | Daily mood + spending entries |
| `challenges` | `Box<ChallengeModel>` | Weekly behavioural challenges |
| `saved_jar` | `Box<SavedJarEntry>` | Completed challenge savings |
| `settings` | `Box` | User profile, preferences, streak |

### Remote — Supabase (schema included)
[`supabase_schema.sql`](supabase_schema.sql) defines the full PostgreSQL schema with Row-Level Security policies so each user can only access their own data:

| Table | Purpose |
|-------|---------|
| `users` | Profile, goal, hourly wage |
| `habits` | Spending habits |
| `mood_logs` | Mood + spend entries |
| `patterns` | Detected behavioural patterns |
| `challenges` | Weekly challenges |
| `saved_jar` | Redirected savings |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.22.0 (stable channel)
- Dart ≥ 3.4.0
- Android Studio or VS Code with Flutter extension

### Installation

```bash
git clone https://github.com/akshitap30/MoodSpend.git
cd MoodSpend
flutter pub get
flutter run
```

The app runs fully offline — no environment variables are required to launch it.

### Optional — Supabase Cloud Sync

If you want to enable cloud sync, create a project on [supabase.com](https://supabase.com), apply the schema from [`supabase_schema.sql`](supabase_schema.sql), then provide your credentials:

```bash
# Create a .env file (never commit this file)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

> **Note:** `.env` files are listed in `.gitignore`. Never commit your Supabase keys.

---

## ⚙️ CI / CD

The project uses a **GitHub Actions** workflow ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) that runs on every push and pull request to `main`/`master`:

| Step | Command |
|------|---------|
| Install Flutter SDK | `subosito/flutter-action@v2` (stable channel) |
| Fetch dependencies | `flutter pub get` |
| Formatting check | `dart format --output=none --set-exit-if-changed .` |
| Static analysis | `flutter analyze --fatal-infos` |
| Run tests | `flutter test` |

---

## 🧪 Testing

```bash
# Run the full test suite
flutter test

# Run with coverage (optional)
flutter test --coverage
```

Tests are located in `test/unit_test.dart` and cover:

- `UserModel` — JSON serialisation round-trip, `copyWith`, default values
- `MoodLogModel` — JSON serialisation round-trip, null-safe field handling
- `PatternModel` — `insightText` generation for different mood/tag combinations
- `PatternService.detectPattern` — pattern detection with sufficient/insufficient logs
- `PatternService.moodSpendAverages` — per-mood average computation
- `PatternService.tagSpendAverages` — per-tag average computation
- `PatternService.buildHeatmap` — 7×24 matrix structure and cell increments

---

## 🤝 Contributing

Contributions are welcome! Please open an issue first to discuss proposed changes.

```bash
# 1. Fork the repository and clone it locally
git clone https://github.com/<your-username>/MoodSpend.git

# 2. Create a feature branch
git checkout -b feature/your-feature-name

# 3. Make your changes and commit
git add .
git commit -m "feat: add your feature description"

# 4. Push to your fork
git push origin feature/your-feature-name
```

Then open a **Pull Request** against `main` on the original repository. The CI pipeline will run automatically on your PR.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Built with ❤️ by [Akshita Pandey](https://github.com/akshitap30)

</div>
