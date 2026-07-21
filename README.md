# SkyPulse ⛅

[![CI](https://github.com/Amayyas/SkyPulse/actions/workflows/ci.yml/badge.svg)](https://github.com/Amayyas/SkyPulse/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/Amayyas/SkyPulse?sort=semver)](https://github.com/Amayyas/SkyPulse/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A modern Flutter weather app: real-time forecasts with a design that follows the
time of day.

## ✨ Features

- 🌡️ **Current conditions** — temperature, feels-like, humidity, wind (with
  direction), pressure and visibility
- ⏰ **Hourly forecast** — the next 24 hours, with the chance of rain per hour
- 📅 **5-day forecast** — the free OpenWeatherMap tier covers 5 days
- 🎨 **Dynamic theme** — the palette shifts with the time of day (dawn, morning,
  afternoon, evening, dusk, night) and updates live as the day goes on
- 🌍 **Bilingual (English / French)** — the UI follows the device language,
  English by default; dates and unit formatting follow the locale
- 📐 **Metric / imperial** — switch units in settings; conversions are instant,
  no refetch
- 📍 **Geolocation** — automatic detection of your position, remembered across
  restarts
- 🔍 **City search** — look up any city, with autocomplete

## 🛠️ Built with

- **Flutter** — cross-platform framework
- **Riverpod** — reactive state management
- **OpenWeatherMap API** — weather data
- **Geolocator** — geolocation
- **Google Fonts** — the Outfit typeface
- **Flutter Animate** — animations

## 🚀 Getting started

```bash
git clone https://github.com/Amayyas/SkyPulse.git
cd SkyPulse
flutter pub get
```

The API key is supplied **at build time** via `--dart-define` — never written to
a tracked file. Get a free key at [OpenWeatherMap](https://openweathermap.org/api),
then:

```bash
flutter run --dart-define=OWM_API_KEY=your_key
```

Without a key the app runs but shows an "API key not configured" screen.

> 💡 To avoid retyping the key, put it in a git-ignored `dart_define.json` and
> run `flutter run --dart-define-from-file=dart_define.json`.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full development setup (note:
code generation is a **required** step).

## 📊 Interpolated hourly forecast

The free `/forecast` endpoint returns data every 3 hours. SkyPulse linearly
interpolates temperature, feels-like, humidity and wind between those points to
show a continuous hourly strip.

> ⚠️ Interpolation fills in *numbers*; the weather icon and description of an
> interpolated hour are carried from the preceding 3-hour slot, so a sunny→rainy
> transition can appear one slot late. Improving this is tracked in the issues.

## 🎨 Dynamic themes

The theme changes with the hour, and updates while the app is running:

- 🌙 **Night (22:00–05:00)** — very dark blue
- 🌅 **Dawn (05:00–07:00)** — soft pink and orange
- ☀️ **Morning (07:00–12:00)** — light, fresh blue
- 🌞 **Afternoon (12:00–17:00)** — vivid sky blue
- 🌇 **Evening (17:00–19:00)** — orange and gold
- 🌆 **Dusk (19:00–22:00)** — deep blue / violet

## 🏗️ Architecture

```
lib/
├── main.dart          # entry point, MaterialApp, locale + theme wiring
├── l10n/              # ARB translation files (en source, fr)
├── models/            # Weather, CitySuggestion — JSON parsing
├── providers/         # Riverpod state (weather, selected city, units, theme)
├── screens/           # HomeScreen, SearchScreen, SettingsScreen
├── services/          # WeatherService (API), LocationService (GPS), exceptions
├── utils/             # constants, unit conversion, time-of-day themes
└── widgets/           # CurrentWeather, HourlyForecast, DailyForecast, ErrorView…
```

## 🧪 Tests

```bash
# Required once after a fresh clone (generates the Mockito mocks):
dart run build_runner build --delete-conflicting-outputs

flutter test
flutter test --coverage
```

The suite covers model parsing (including malformed payloads), the weather and
location service failure paths, unit conversion, the time-of-day theme buckets,
city persistence, localisation, and widget tests for the error and forecast
views.

## 📦 Main dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^3.0.3 | State management |
| `http` | ^1.6.0 | API requests |
| `geolocator` | ^14.0.2 | GPS geolocation |
| `google_fonts` | ^8.2.0 | Outfit typeface |
| `flutter_animate` | ^4.5.2 | Animations |
| `intl` | ^0.20.2 | Locale-aware date formatting |
| `shared_preferences` | ^2.5.0 | Persisting the selected city and units |
| `shimmer` | ^3.0.0 | Loading placeholders |

## 🔧 API endpoints

- **Current weather** — `https://api.openweathermap.org/data/2.5/weather`
- **5-day forecast** — `https://api.openweathermap.org/data/2.5/forecast` (3-hourly)
- **Geocoding** — `https://api.openweathermap.org/geo/1.0/direct` (city search)

## 🤝 Contributing

Contributions are welcome. Everything is in [CONTRIBUTING.md](CONTRIBUTING.md):
prerequisites, setup (code generation is **mandatory**), API key configuration,
commit conventions and the definition of done.

- Issues labelled [`good first issue`](https://github.com/Amayyas/SkyPulse/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
  are scoped and self-contained — comment before you start.
- `main` is protected: pull requests only, and all CI checks must be green.

This project follows a [Code of Conduct](CODE_OF_CONDUCT.md). For security
issues, see [SECURITY.md](SECURITY.md) — never open a public issue.

## 📱 Supported platforms

Android · iOS · Web · Windows · macOS · Linux

## 🙏 Acknowledgements

- [OpenWeatherMap](https://openweathermap.org/) for the free weather API
- [Flutter](https://flutter.dev/) for the framework
- [Google Fonts](https://fonts.google.com/) for the Outfit typeface

## 👨‍💻 Author

Built with ❤️ by [Amayyas](https://github.com/Amayyas)

---

⭐ If you like this project, consider giving it a star on GitHub!
