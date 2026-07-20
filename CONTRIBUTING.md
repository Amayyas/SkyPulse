# Contributing to SkyPulse

Thanks for taking the time to contribute. This guide should get you from a clean
clone to a green pull request without surprises.

If anything here is wrong or out of date, that is a bug — please open an issue.

## Prerequisites

| Tool | Version |
| --- | --- |
| Flutter | **3.44.4** (stable) — the version CI pins and builds against |
| Dart | `^3.9.0` (ships with Flutter) |

Other Flutter versions may well work, but 3.44.4 is the only one that is
verified on every push.

```bash
flutter --version
flutter doctor
```

## Setup

```bash
git clone https://github.com/<your-username>/SkyPulse.git
cd SkyPulse
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**That last step is mandatory, not optional.** The Mockito mocks under `test/`
are generated and deliberately git-ignored, so a fresh clone does not contain
them. Skip codegen and `flutter test` fails immediately with a missing-import
error that looks like a broken repository. Run it before your first test run,
and again whenever you change a `@GenerateMocks` annotation.

## Configuring the API key

SkyPulse reads live data from [OpenWeatherMap](https://openweathermap.org/api).
Create a free account and generate a key.

Supply it at build time with `--dart-define` — **never** by editing a tracked
file:

```bash
flutter run --dart-define=OWM_API_KEY=your_key
```

The constant in [`lib/utils/constants.dart`](lib/utils/constants.dart) reads
`String.fromEnvironment('OWM_API_KEY')`, so no source file has to change and
your key can never end up in a commit. Without a key the app runs but shows a
"Clé API non configurée" screen.

> [!TIP]
> To avoid retyping it, put the key in a git-ignored `dart_define.json` and use
> `flutter run --dart-define-from-file=dart_define.json`.
>
> A client-side key is still extractable from a shipped binary — `--dart-define`
> keeps it out of git, not out of the app. See [SECURITY.md](SECURITY.md).

Also be aware of [#1](https://github.com/Amayyas/SkyPulse/issues/1): when the
API rejects a request, the app currently falls back to **fabricated demo
weather** instead of showing an error. So a misconfigured key does not look
broken — it looks like a working app showing "Paris (Demo), 22.5°". If the
weather seems oddly stable, check your key first.

## Verifying your work

CI runs exactly these four commands. Run them locally and you will not be
surprised:

```bash
dart format .                                    # CI fails on unformatted code
flutter analyze --no-fatal-infos                 # see the note below
flutter test
flutter run                                      # and actually look at the app
```

`--no-fatal-infos` is a temporary concession: 12 deprecation warnings are
outstanding ([#13](https://github.com/Amayyas/SkyPulse/issues/13)). Once they
are fixed, the flag disappears and *any* analyzer info will fail the build. Do
not add new ones.

There are currently **no widget tests at all**
([#28](https://github.com/Amayyas/SkyPulse/issues/28)), so a green test run
proves less than you would like. If your change touches the UI, run the app and
look at it.

## Project layout

```
lib/
├── main.dart          # entry point, MaterialApp, locale setup
├── models/            # Weather, CitySuggestion — JSON parsing
├── providers/         # Riverpod state (selected city, current weather, forecast)
├── screens/           # HomeScreen, SearchScreen
├── services/          # WeatherService (OpenWeatherMap), LocationService (GPS)
├── utils/             # constants, time-of-day themes
└── widgets/           # CurrentWeather, HourlyForecast, DailyForecast, WeatherIcon
```

## Workflow

1. **Pick an issue and say so on it.** Issues labelled
   [`good first issue`](https://github.com/Amayyas/SkyPulse/labels/good%20first%20issue)
   are scoped and self-contained. Comment before you start, and wait to be
   assigned — it avoids two people doing the same work, and it avoids you
   spending an evening on something that turns out to be the maintainer's call.
   One issue per pull request.

2. **Branch from `main`:**

   ```bash
   git switch -c fix/city-search-encoding
   ```

   Use `feat/`, `fix/`, `docs/`, `test/`, `refactor/` or `chore/` prefixes.

3. **Write the change, and a test for it.** New logic needs a test. Bug fixes
   need a test that fails before your fix and passes after.

4. **Write [Conventional Commits](https://www.conventionalcommits.org/)**, in
   English:

   ```
   fix: percent-encode city names in geocoding requests
   feat: show precipitation probability in the hourly strip
   docs: correct the codegen setup step
   ```

   These are not decoration — they will drive automated versioning and the
   changelog ([#33](https://github.com/Amayyas/SkyPulse/issues/33)).

5. **Open a pull request against `main`.** `main` is protected: it takes pull
   requests only, and all seven CI checks (format/analyze/test plus a build on
   each of the six platforms) must be green before it can merge.

## Definition of done

- [ ] `dart format .` produces no changes
- [ ] `flutter analyze` introduces no new issues
- [ ] `flutter test` passes, and covers the new behaviour
- [ ] The app was actually run, if the change is user-visible
- [ ] Documentation updated if the change makes any of it untrue
- [ ] Commits follow Conventional Commits

## A note on documentation

This project has a history of documentation describing things that do not exist
— a test file that was never written, a `--dart-define` integration that was
never built, a 7-day forecast the free API cannot return
([#30](https://github.com/Amayyas/SkyPulse/issues/30)).

So: **do not document a command you have not run, or a behaviour you have not
observed.** If you write it in a doc, execute it first.

## Code of Conduct

Participation is governed by our [Code of Conduct](CODE_OF_CONDUCT.md).

## Security

Please do not report vulnerabilities through public issues. See
[SECURITY.md](SECURITY.md).
