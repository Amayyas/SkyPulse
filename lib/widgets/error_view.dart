import 'package:flutter/material.dart';
import 'package:skypulse/services/weather_exception.dart';

/// Ce qu'on montre à l'utilisateur quand une requête échoue.
///
/// Auparavant, l'écran affichait le résultat brut de `$error`, soit des choses
/// comme `ClientException: Failed host lookup: 'api.openweathermap.org'` —
/// illisible, et sans indication de ce qu'il fallait faire. Chaque cas connu a
/// désormais son message et son geste.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final (icon, message, hint) = _describe(error);

    // Scrollable : sans ça, le RefreshIndicator qui enveloppe cet écran n'a
    // rien à quoi s'accrocher, et le geste « tirer pour réessayer » ne fait
    // rien — précisément sur l'écran où l'utilisateur va le tenter.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hint != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      hint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Traduit une erreur en icône, message et conseil.
  ///
  /// Le message technique de l'exception n'est jamais montré : il part dans les
  /// logs et les tests, pas à l'écran.
  static (IconData, String, String?) _describe(Object error) {
    return switch (error) {
      InvalidApiKeyException() => (
        Icons.key_off,
        'Clé API invalide',
        "La clé OpenWeatherMap est absente ou refusée. Une clé fraîchement "
            "créée peut mettre jusqu'à deux heures à s'activer.",
      ),
      CityNotFoundException(cityName: final city) => (
        Icons.location_off,
        city.isEmpty ? 'Ville introuvable' : 'Ville introuvable : $city',
        'Vérifiez l\'orthographe, ou essayez une ville plus grande à proximité.',
      ),
      RateLimitException() => (
        Icons.hourglass_empty,
        'Trop de requêtes',
        'Le quota gratuit est dépassé. Réessayez dans une minute.',
      ),
      NoConnectionException() => (
        Icons.wifi_off,
        'Pas de connexion',
        'Impossible de joindre le service météo. Vérifiez votre réseau.',
      ),
      WeatherApiException(statusCode: final code) => (
        Icons.cloud_off,
        'Service météo indisponible',
        'Le serveur a répondu une erreur $code. Ce n\'est pas de votre fait.',
      ),
      MalformedResponseException() => (
        Icons.error_outline,
        'Réponse inattendue',
        'Le service météo a renvoyé des données incompréhensibles.',
      ),
      _ => (
        Icons.error_outline,
        'Une erreur est survenue',
        'Réessayez dans un instant.',
      ),
    };
  }
}
