# Contributing to SkyPulse ⛅

First off, thank you for taking the time to contribute! Contributions are what make the open-source community such an amazing place to learn, inspire, and create.

This guide provides everything you need to know to get your development environment set up and make your first contribution.

---

## 📋 Prerequisites

Before starting, make sure you have the following installed:
- **Flutter SDK**: `>= 3.29.0` (Stable channel recommended)
- **Dart SDK**: `^3.9.0` (Bundled with Flutter)

To check your installation, run:
```bash
flutter doctor
```

---

## ⚙️ Setup Instructions

Follow these steps to set up the project locally:

1. **Fork and Clone the Repository**
   Fork the repository on GitHub, then clone your fork:
   ```bash
   git clone https://github.com/your-username/SkyPulse.git
   cd SkyPulse
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Code (Mandatory)**
   This project uses code generation (e.g., Mockito for tests). You must run the code generator before compiling or running tests:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

---

## 🔑 API Key Configuration

To fetch real weather data, you need an API key from OpenWeatherMap.

> [!IMPORTANT]
> **Do not edit tracked source files to add your API key.** Specifically, do not hardcode your key in `lib/utils/constants.dart`.

Instead, pass your API key at runtime using `--dart-define`. This ensures your key stays private and is not accidentally committed.

### Running with API Key
```bash
flutter run --dart-define=OPENWEATHERMAP_API_KEY=your_actual_api_key_here
```

---

## 🧪 Running & Verifying

Before submitting a pull request, verify that your changes are correct and follow formatting rules.

### Running the App
```bash
flutter run --dart-define=OPENWEATHERMAP_API_KEY=YOUR_KEY
```

### Running Tests
Execute the unit and widget test suite:
```bash
flutter test
```

### Static Analysis
Ensure there are no analyzer warnings or errors:
```bash
flutter analyze
```

### Code Formatting
Ensure all files conform to Dart standards:
```bash
dart format . --set-exit-if-changed
```

---

## 🛠️ Project Structure Walkthrough

A quick guide to the directory layout in `lib/`:
```
lib/
├── main.dart                     # Application entry point
├── models/                       # Data models (e.g. weather parsing)
├── providers/                    # Riverpod state providers
├── screens/                      # UI screens (Home, Search)
├── services/                     # External services (API, Location)
├── utils/                        # Constants, application themes
└── widgets/                      # Reusable UI components
```

---

## 🤝 Contribution Workflow

1. **Pick an Issue**: Look for open issues. Items tagged `good first issue` are great starting points.
2. **Branching Model**: Create a feature or bugfix branch off `main`:
   ```bash
   git checkout -b feature/AmazingFeature
   # or
   git checkout -b bugfix/AmazingFix
   ```
3. **Write Code**: Implement your changes. Ensure you add unit tests for new logic where possible.
4. **Commit Messages**: We follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat: add hourly temperature graph`
   - `fix: resolve crash on location permission denial`
   - `docs: update setup instructions in README`
   - `test: add unit test for weather parser`
5. **Definition of Done**:
   - `flutter analyze` runs without errors.
   - `flutter test` succeeds.
   - `dart format .` is applied.
   - Changes are documented if necessary.
6. **Submit PR**: Push to your fork and open a Pull Request against the `main` branch of `Amayyas/SkyPulse`.
