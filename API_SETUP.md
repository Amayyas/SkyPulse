# Configuration de l'API OpenWeatherMap

## Étapes de configuration

1. **Obtenez votre clé API gratuite**
   - Rendez-vous sur [OpenWeatherMap](https://openweathermap.org/api)
   - Créez un compte gratuit
   - Accédez à votre dashboard et copiez votre clé API

2. **Configurez la clé dans le projet**
   
   Ouvrez le fichier `lib/utils/constants.dart` et remplacez `YOUR_API_KEY_HERE` par votre clé :
   
   ```dart
   static const String openWeatherMapApiKey = 'VOTRE_CLE_API_ICI';
   ```

3. **Lancez l'application**
   ```bash
   flutter pub get
   flutter run
   ```

## Sécurité

⚠️ **Important** : Ne commitez jamais votre clé API dans un dépôt public !

Si vous avez accidentellement commité votre clé :
1. Régénérez une nouvelle clé sur OpenWeatherMap
2. Utilisez `git filter-branch` ou BFG Repo-Cleaner pour nettoyer l'historique

## Alternative : Variables d'environnement

Pour plus de sécurité, vous pouvez utiliser des variables d'environnement :

1. Créez un fichier `.env` à la racine du projet :
   ```
   OPENWEATHERMAP_API_KEY=votre_cle_ici
   ```

2. Ajoutez `.env` au `.gitignore` (déjà fait)

3. Décommentez la ligne dans `main.dart` :
   ```dart
   await dotenv.load(fileName: ".env");
   ```

4. Modifiez `constants.dart` pour utiliser :
   ```dart
   static final String openWeatherMapApiKey = dotenv.env['OPENWEATHERMAP_API_KEY'] ?? '';
   ```
