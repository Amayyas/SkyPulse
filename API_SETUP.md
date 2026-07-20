# Configuration de l'API OpenWeatherMap

## 1. Obtenez une clé gratuite

- Rendez-vous sur [OpenWeatherMap](https://openweathermap.org/api)
- Créez un compte gratuit
- Copiez votre clé API depuis le dashboard

> Une clé fraîchement créée peut mettre jusqu'à deux heures à s'activer.

## 2. Fournissez la clé au build

La clé se passe **au lancement**, via `--dart-define`. Elle n'est jamais écrite
dans un fichier suivi par git : `lib/utils/constants.dart` la lit depuis
l'environnement du build (`String.fromEnvironment('OWM_API_KEY')`).

```bash
flutter run              --dart-define=OWM_API_KEY=votre_cle
flutter build apk        --dart-define=OWM_API_KEY=votre_cle
flutter build web        --dart-define=OWM_API_KEY=votre_cle
```

Sans clé, l'application démarre mais affiche **« Clé API non configurée »**
plutôt que de partir en requête vouée à échouer.

### Astuce : éviter de retaper la clé

Mettez-la dans un fichier `dart_define.json` (à git-ignorer), puis :

```json
{ "OWM_API_KEY": "votre_cle" }
```

```bash
flutter run --dart-define-from-file=dart_define.json
```

## Sécurité

`--dart-define` garde la clé **hors de git**. Il ne la garde pas hors du
binaire : une clé embarquée dans une application cliente reste extractible d'un
build distribué. La clé du palier gratuit a une valeur négligeable et ne donne
accès qu'à des données météo publiques — le compromis est assumé. Voir
[SECURITY.md](SECURITY.md).

Si vous avez malgré tout commité une clé : régénérez-la sur OpenWeatherMap (la
révocation est immédiate), puis nettoyez l'historique si nécessaire
(`git filter-repo`, ou BFG Repo-Cleaner).
