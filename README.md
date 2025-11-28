# SkyPulse ⛅

Une application météo moderne et intuitive développée avec Flutter, offrant des prévisions météorologiques en temps réel avec un design dynamique qui s'adapte à l'heure de la journée.

## ✨ Fonctionnalités

- 🌡️ **Météo en temps réel** : Affichage des conditions météorologiques actuelles avec température, humidité, vitesse du vent et ressenti
- ⏰ **Prévisions horaires** : Prévisions détaillées heure par heure pour les prochaines 24 heures
- 📅 **Prévisions sur 7 jours** : Aperçu hebdomadaire des conditions météorologiques
- 🎨 **Thème dynamique** : L'interface change de couleur selon l'heure de la journée (aube, matin, après-midi, soir, crépuscule, nuit)
- 🇫🇷 **Interface en français** : Toutes les descriptions météo et dates sont traduites en français
- 📍 **Géolocalisation** : Détection automatique de votre position
- 🔍 **Recherche de villes** : Recherchez la météo de n'importe quelle ville avec autocomplétion
- ✨ **Animations fluides** : Interface animée et agréable à utiliser

## 🛠️ Technologies utilisées

- **Flutter** : Framework de développement multiplateforme
- **Riverpod** : Gestion d'état moderne et réactive
- **OpenWeatherMap API** : Source des données météorologiques
- **Geolocator** : Géolocalisation
- **Google Fonts** : Police Outfit pour un design moderne
- **Flutter Animate** : Animations fluides

## 📊 Prévisions horaires interpolées

L'API gratuite d'OpenWeatherMap fournit des prévisions toutes les 3 heures. Pour offrir une meilleure expérience utilisateur, **SkyPulse interpole intelligemment les données existantes** pour créer des prévisions horaires complètes.

### Comment fonctionne l'interpolation ?

L'application calcule les valeurs intermédiaires entre chaque point de données 3h en utilisant une interpolation linéaire pour :
- 🌡️ La température
- 💨 Le ressenti thermique
- 💧 L'humidité
- 🌬️ La vitesse du vent

Cela permet d'afficher **24 prévisions horaires consécutives** au lieu de seulement 8 prévisions espacées de 3 heures.

## 🚀 Installation

1. Clonez le repository :
```bash
git clone https://github.com/Amayyas/SkyPulse.git
cd SkyPulse
```

2. Installez les dépendances :
```bash
flutter pub get
```

3. Configurez votre clé API OpenWeatherMap dans `lib/utils/constants.dart` :
```dart
static const String openWeatherMapApiKey = 'VOTRE_CLE_API_ICI';
```

4. Lancez l'application :
```bash
flutter run
```

## 🎨 Thèmes dynamiques

L'application change automatiquement de thème selon l'heure :

- 🌙 **Nuit (22h-5h)** : Bleu très foncé avec étoiles
- 🌅 **Aube (5h-7h)** : Rose et orange doux
- ☀️ **Matin (7h-12h)** : Bleu clair et frais
- 🌞 **Après-midi (12h-17h)** : Bleu vif "ciel azur"
- 🌇 **Soir (17h-19h)** : Orange et doré
- 🌆 **Crépuscule (19h-22h)** : Bleu foncé/violet

## 🏗️ Architecture

```
lib/
├── main.dart                     # Point d'entrée de l'application
├── models/                       # Modèles de données
│   ├── weather_model.dart        # Modèle météo avec parsing JSON
│   └── city_suggestion.dart      # Modèle pour l'autocomplétion
├── providers/                    # Providers Riverpod
│   └── weather_provider.dart     # Gestion d'état (météo, ville sélectionnée)
├── screens/                      # Écrans principaux
│   ├── home_screen.dart          # Écran d'accueil avec météo actuelle
│   └── search_screen.dart        # Écran de recherche avec autocomplétion
├── services/                     # Services externes
│   ├── weather_service.dart      # Communication avec OpenWeatherMap API
│   └── location_service.dart     # Gestion de la géolocalisation GPS
├── utils/                        # Utilitaires et configuration
│   ├── constants.dart            # Constantes (API key, traductions)
│   └── theme.dart                # Thèmes dynamiques selon l'heure
└── widgets/                      # Composants réutilisables
    ├── current_weather.dart      # Widget météo actuelle
    ├── hourly_forecast.dart      # Widget prévisions horaires
    ├── daily_forecast.dart       # Widget prévisions 7 jours
    └── weather_icon.dart         # Widget icône météo animée
```

## 🧪 Tests

Le projet inclut des tests unitaires pour garantir la qualité du code :

```bash
# Exécuter tous les tests
flutter test

# Exécuter les tests avec couverture
flutter test --coverage

# Générer les mocks pour les tests (si nécessaire)
flutter pub run build_runner build --delete-conflicting-outputs
```

Tests disponibles :
- ✅ `test/weather_model_test.dart` : Parsing JSON des modèles météo
- ✅ `test/weather_service_test.dart` : Requêtes API avec mocks
- ✅ `test/constants_test.dart` : Validation des traductions françaises
- ✅ `test/theme_test.dart` : Validation des thèmes dynamiques

## 📦 Dépendances principales

| Package | Version | Description |
|---------|---------|-------------|
| `flutter_riverpod` | ^3.0.3 | Gestion d'état réactive |
| `http` | ^1.2.2 | Requêtes HTTP pour l'API |
| `geolocator` | ^14.0.2 | Géolocalisation GPS |
| `geocoding` | ^4.0.0 | Géocodage et recherche de villes |
| `google_fonts` | ^6.3.2 | Police Outfit personnalisée |
| `flutter_animate` | ^4.5.2 | Animations fluides |
| `intl` | ^0.20.2 | Internationalisation (dates françaises) |
| `shimmer` | ^3.0.0 | Effets de chargement |

## 🔧 Configuration

### Obtenir une clé API OpenWeatherMap

1. Créez un compte gratuit sur [OpenWeatherMap](https://openweathermap.org/api)
2. Accédez à votre dashboard et générez une clé API
3. Copiez la clé dans `lib/utils/constants.dart` :

```dart
static const String openWeatherMapApiKey = 'VOTRE_CLE_API_ICI';
```

### Endpoints API utilisés

- **Current Weather** : `https://api.openweathermap.org/data/2.5/weather`
- **5 Day Forecast** : `https://api.openweathermap.org/data/2.5/forecast` (données toutes les 3h)
- **Geocoding** : `https://api.openweathermap.org/geo/1.0/direct` (recherche de villes)

## 🐛 Problèmes connus et solutions

### Nom de ville incorrect
**Problème** : Certaines recherches (ex: "Bourg-et-Comin") affichaient un nom de ville différent (ex: "Meurival"). Cela arrive car ces deux villes ont exactement les mêmes coordonnées géographiques (latitude/longitude), et l'API météo retourne le nom d'une ville différente de celle recherchée via l'API de géocodage.  
**Solution** : Le nom recherché est maintenant préservé et prioritaire sur le nom retourné par l'API météo.

### Permissions de localisation
Si la géolocalisation ne fonctionne pas :
- Vérifiez les permissions dans les paramètres de l'appareil
- Sur Android : ajoutez les permissions dans `AndroidManifest.xml`
- Sur iOS : ajoutez les clés dans `Info.plist`

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. **Fork** le projet
2. Créez une branche pour votre feature (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Poussez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une **Pull Request**

### Lignes directrices

- Suivez les conventions de code Flutter/Dart
- Ajoutez des tests pour les nouvelles fonctionnalités
- Mettez à jour la documentation si nécessaire
- Assurez-vous que tous les tests passent (`flutter test`)
- Vérifiez qu'il n'y a pas d'erreurs d'analyse (`flutter analyze`)

## 📱 Plateformes supportées

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## � Remerciements

- [OpenWeatherMap](https://openweathermap.org/) pour leur API météo gratuite et complète
- [Flutter](https://flutter.dev/) pour le framework multiplateforme
- [Google Fonts](https://fonts.google.com/) pour la magnifique police Outfit
- La communauté Flutter pour tous les packages open-source de qualité

## �👨‍💻 Auteur

Développé avec ❤️ par [Amayyas](https://github.com/Amayyas)

---

⭐ Si vous aimez ce projet, n'hésitez pas à lui donner une étoile sur GitHub !
