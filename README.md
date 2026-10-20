# 📝 Tasky — Modern To-Do Mobile Application

A clean, modern, and offline-first task management application built with **Flutter**, designed according to modern UI/UX principles with seamless **Light and Dark mode** support. Developed as part of the **DEPI** program.

---

## ✨ Features

- **🔐 Authentication & Session Persistence:**
  - User registration and login powered by a production **ASP.NET Core REST API**.
  - Secure credential & JWT token caching via `flutter_secure_storage`.
  - Automatic session check on startup (`SplashScreen`) with token expiry handling.
  
- **📋 Task Management:**
  - Create, view, complete, restore, and delete tasks.
  - Priority levels (`High`, `Medium`, `Low`) with visual indicators.
  - Filtering by status (**All**, **To Do**, **Completed**).
  - Quick task overview and progress tracking on the Home screen.

- **💾 Offline-First Architecture (Hive):**
  - Instant local data persistence using **Hive NoSQL database**.
  - Multi-user isolation: tasks are scoped strictly to the authenticated `userId`.

- **🎨 Rich Design & Theming:**
  - Clean Material 3 design inspired by modern Figma designs.
  - Full **Light Mode** and **Dark Mode** support with smooth real-time toggling.
  - Responsive layouts and custom animations.

- **👤 Profile & Personalization:**
  - Update user display name and daily motivational quote.
  - Profile avatar selection from device gallery.
  - Safe logout flow with state cleanup.

---

## 🏛️ Architecture & Folder Structure

The project follows a **Feature-Driven / Modular Architecture** for maintainability and scalability:

```text
lib/
├── main.dart                          # Application entry point & MultiProvider setup
│
├── data/
│   ├── models/
│   │   ├── task_model.dart            # Hive Task entity model
│   │   └── task_model.g.dart          # Generated Hive TypeAdapter
│   └── services/
│       ├── auth_service.dart          # REST API authentication & token handling
│       └── hive_service.dart          # Hive initialization & local boxes
│
├── providers/
│   ├── task_provider.dart             # Task state, filtering, and CRUD operations
│   ├── user_provider.dart             # Active user profile and preferences
│   └── theme_provider.dart            # ThemeMode management (Light / Dark)
│
└── features/
    ├── onboarding/
    │   ├── splash_screen.dart         # Auto-login & session validation
    │   └── welcome_screen.dart        # Introductory screen for new users
    ├── auth/
    │   ├── login_screen.dart          # Sign in screen with validations
    │   └── register_screen.dart       # Account registration screen
    ├── navigation/
    │   └── main_navigation_screen.dart# Bottom navigation bar controller
    ├── home/
    │   ├── home_screen.dart           # Dashboard with summary & progress cards
    │   └── widgets/                   # Home-specific components
    ├── todo/
    │   └── my_tasks_screen.dart       # Pending / To Do tasks list
    ├── completed/
    │   └── completed_tasks_screen.dart# Finished tasks list
    ├── add_task/
    │   └── add_task_screen.dart       # New task creation screen
    ├── profile/
    │   ├── profile_screen.dart        # Profile overview & theme switch
    │   ├── user_details_screen.dart   # Profile details editing screen
    │   └── widgets/                   # Profile UI components
    └── shared/
        └── widgets/                   # Reusable widgets (TaskCard, TaskList, Dialogs)
```

---

## 🛠️ Tech Stack & Dependencies

- **Framework:** [Flutter](https://flutter.dev) (Dart SDK `^3.12.2`)
- **State Management:** [Provider](https://pub.dev/packages/provider) (`^6.1.5`)
- **Local Storage:** [Hive](https://pub.dev/packages/hive) & [Hive Flutter](https://pub.dev/packages/hive_flutter)
- **Secure Storage:** [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- **Networking:** [http](https://pub.dev/packages/http)
- **Image Handling:** [image_picker](https://pub.dev/packages/image_picker) & [path_provider](https://pub.dev/packages/path_provider)

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- Android Studio / VS Code with Flutter & Dart extensions.
- An Android device or emulator (Android 5.0+ / API 21+).

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/FaroukEldars/todoapp.git
   cd todoapp
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation (if Hive models are updated):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## 🧪 Code Analysis & Formatting

To ensure high code quality:

```bash
# Analyze code for warnings and lints
flutter analyze

# Format all code
dart format lib/
```
