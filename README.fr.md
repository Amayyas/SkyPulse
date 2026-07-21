# SkyPulse ⛅

[![CI](https://github.com/Amayyas/SkyPulse/actions/workflows/ci.yml/badge.svg)](https://github.com/Amayyas/SkyPulse/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[English](README.md) · **Français**

Une application météo moderne développée avec Flutter : prévisions en temps réel
et un design qui suit l'heure de la journée.

## ✨ Fonctionnalités

- 🌡️ **Conditions actuelles** — température, ressenti, humidité, vent (avec
  direction), pression et visibilité
- ⏰ **Prévisions horaires** — les 24 prochaines heures, avec la probabilité de
  pluie par heure
- 📅 **Prévisions sur 5 jours** — l'API gratuite d'OpenWeatherMap couvre 5 jours
- 🎨 **Thème dynamique** — la palette change selon l'heure (aube, matin,
  après-midi, soir, crépuscule, nuit) et se met à jour en direct
- 🌍 **Bilingue (anglais / français)** — l'interface suit la langue de
  l'appareil, anglais par défaut ; les dates et le format des unités s'adaptent
- 📐 **Métrique / impérial** — changez d'unités dans les réglages ; les
  conversions sont instantanées, sans nouvelle requête
- 📍 **Géolocalisation** — détection automatique de votre position, mémorisée
  entre les lancements
- 🔍 **Recherche de villes** — n'importe quelle ville, avec autocomplétion

## 🛠️ Technologies

- **Flutter** — framework multiplateforme
- **Riverpod** — gestion d'état réactive
- **OpenWeatherMap API** — données météo
- **Geolocator** — géolocalisation
- **Google Fonts** — police Outfit
- **Flutter Animate** — animations

## 🚀 Démarrage

```bash
git clone https://github.com/Amayyas/SkyPulse.git
cd SkyPulse
flutter pub get
```

La clé API se fournit **au lancement** via `--dart-define`, jamais dans un
fichier suivi par git. Obtenez une clé gratuite sur
[OpenWeatherMap](https://openweathermap.org/api), puis :

```bash
flutter run --dart-define=OWM_API_KEY=votre_cle
```

Sans clé, l'application démarre mais affiche « Clé API non configurée ».

> 💡 Pour ne pas retaper la clé, mettez-la dans un fichier `dart_define.json`
> (git-ignoré) et lancez `flutter run --dart-define-from-file=dart_define.json`.

Voir [API_SETUP.md](API_SETUP.md) pour les détails et
[CONTRIBUTING.md](CONTRIBUTING.md) pour l'installation complète (attention : la
génération de code est une étape **obligatoire**).

## 📊 Prévisions horaires interpolées

L'endpoint gratuit `/forecast` renvoie des données toutes les 3 heures. SkyPulse
interpole linéairement la température, le ressenti, l'humidité et le vent entre
ces points pour afficher une bande horaire continue.

> ⚠️ L'interpolation comble les *valeurs* ; l'icône et la description d'une heure
> interpolée sont reprises du créneau 3h précédent, donc une transition
> soleil→pluie peut apparaître un cran en retard. L'amélioration est suivie dans
> les issues.

## 🎨 Thèmes dynamiques

Le thème change avec l'heure, et se met à jour pendant que l'app tourne :

- 🌙 **Nuit (22h–5h)** — bleu très foncé
- 🌅 **Aube (5h–7h)** — rose et orange doux
- ☀️ **Matin (7h–12h)** — bleu clair et frais
- 🌞 **Après-midi (12h–17h)** — bleu ciel vif
- 🌇 **Soir (17h–19h)** — orange et doré
- 🌆 **Crépuscule (19h–22h)** — bleu foncé / violet

## 🏗️ Architecture

```
lib/
├── main.dart          # point d'entrée, MaterialApp, locale + thème
├── l10n/              # fichiers de traduction ARB (en source, fr)
├── models/            # Weather, CitySuggestion — parsing JSON
├── providers/         # état Riverpod (météo, ville, unités, thème)
├── screens/           # HomeScreen, SearchScreen, SettingsScreen
├── services/          # WeatherService (API), LocationService (GPS), exceptions
├── utils/             # constantes, conversion d'unités, thèmes horaires
└── widgets/           # CurrentWeather, HourlyForecast, DailyForecast, ErrorView…
```

## 🧪 Tests

```bash
# Obligatoire une fois après un clone (génère les mocks Mockito) :
dart run build_runner build --delete-conflicting-outputs

flutter test
flutter test --coverage
```

La suite couvre le parsing des modèles (y compris les réponses malformées), les
chemins d'échec des services météo et localisation, la conversion d'unités, les
tranches horaires du thème, la persistance de la ville, la localisation, et des
tests de widget pour les écrans d'erreur et de prévisions.

## 📦 Dépendances principales

| Package | Version | Rôle |
|---|---|---|
| `flutter_riverpod` | ^3.0.3 | Gestion d'état |
| `http` | ^1.6.0 | Requêtes API |
| `geolocator` | ^14.0.2 | Géolocalisation GPS |
| `google_fonts` | ^8.2.0 | Police Outfit |
| `flutter_animate` | ^4.5.2 | Animations |
| `intl` | ^0.20.2 | Formatage des dates selon la locale |
| `shared_preferences` | ^2.5.0 | Persistance de la ville et des unités |
| `shimmer` | ^3.0.0 | Effets de chargement |

## 🔧 Endpoints API

- **Météo actuelle** — `https://api.openweathermap.org/data/2.5/weather`
- **Prévisions 5 jours** — `https://api.openweathermap.org/data/2.5/forecast` (par 3h)
- **Géocodage** — `https://api.openweathermap.org/geo/1.0/direct` (recherche de villes)

## 🤝 Contribution

Les contributions sont les bienvenues. Tout est décrit dans
[CONTRIBUTING.md](CONTRIBUTING.md) : prérequis, installation (la génération de
code est **obligatoire**), configuration de la clé API, conventions de commit et
critères de validation.

- Les issues étiquetées [`good first issue`](https://github.com/Amayyas/SkyPulse/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
  sont cadrées et autonomes — commentez-les avant de vous lancer.
- `main` est protégée : pull requests uniquement, et tous les checks de CI
  doivent être verts.

Ce projet suit un [Code de conduite](CODE_OF_CONDUCT.md). Pour les failles de
sécurité, voir [SECURITY.md](SECURITY.md) — jamais d'issue publique.

## 📱 Plateformes supportées

Android · iOS · Web · Windows · macOS · Linux

## 🙏 Remerciements

- [OpenWeatherMap](https://openweathermap.org/) pour l'API météo gratuite
- [Flutter](https://flutter.dev/) pour le framework
- [Google Fonts](https://fonts.google.com/) pour la police Outfit

## 👨‍💻 Auteur

Développé avec ❤️ par [Amayyas](https://github.com/Amayyas)

---

⭐ Si vous aimez ce projet, n'hésitez pas à lui donner une étoile sur GitHub !
