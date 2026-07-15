import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'
    hide LocationServiceDisabledException;
import 'package:skypulse/services/location_exception.dart';
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
    final info = _describe(error);

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
                    info.icon,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    info.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (info.hint != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      info.hint!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 24),
                  // "Retry" cannot fix a permanently-denied permission — only a
                  // trip to the system settings can. Offer that as the primary
                  // action, and keep Retry for when the user comes back.
                  if (info.showOpenSettings) ...[
                    ElevatedButton.icon(
                      onPressed: Geolocator.openAppSettings,
                      icon: const Icon(Icons.settings),
                      label: const Text('Ouvrir les réglages'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onRetry,
                      child: const Text('Réessayer'),
                    ),
                  ] else
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

  /// Traduit une erreur en icône, message, conseil et action.
  ///
  /// Le message technique de l'exception n'est jamais montré : il part dans les
  /// logs et les tests, pas à l'écran.
  static _ErrorInfo _describe(Object error) {
    return switch (error) {
      InvalidApiKeyException() => const _ErrorInfo(
        Icons.key_off,
        'Clé API invalide',
        "La clé OpenWeatherMap est absente ou refusée. Une clé fraîchement "
            "créée peut mettre jusqu'à deux heures à s'activer.",
      ),
      CityNotFoundException(cityName: final city) => _ErrorInfo(
        Icons.location_off,
        city.isEmpty ? 'Ville introuvable' : 'Ville introuvable : $city',
        'Vérifiez l\'orthographe, ou essayez une ville plus grande à proximité.',
      ),
      RateLimitException() => const _ErrorInfo(
        Icons.hourglass_empty,
        'Trop de requêtes',
        'Le quota gratuit est dépassé. Réessayez dans une minute.',
      ),
      NoConnectionException() => const _ErrorInfo(
        Icons.wifi_off,
        'Pas de connexion',
        'Impossible de joindre le service météo. Vérifiez votre réseau.',
      ),
      WeatherApiException(statusCode: final code) => _ErrorInfo(
        Icons.cloud_off,
        'Service météo indisponible',
        'Le serveur a répondu une erreur $code. Ce n\'est pas de votre fait.',
      ),
      MalformedResponseException() => const _ErrorInfo(
        Icons.error_outline,
        'Réponse inattendue',
        'Le service météo a renvoyé des données incompréhensibles.',
      ),
      LocationServiceDisabledException() => const _ErrorInfo(
        Icons.location_disabled,
        'Localisation désactivée',
        'Activez la localisation dans les réglages de l\'appareil, ou '
            'recherchez une ville.',
      ),
      LocationPermissionDeniedException() => const _ErrorInfo(
        Icons.location_off,
        'Localisation refusée',
        'Autorisez l\'accès à votre position, ou recherchez une ville.',
      ),
      LocationPermissionPermanentlyDeniedException() => const _ErrorInfo(
        Icons.location_off,
        'Localisation bloquée',
        'L\'accès à la position est refusé définitivement. Ouvrez les réglages '
            'pour l\'autoriser.',
        showOpenSettings: true,
      ),
      LocationTimeoutException() => const _ErrorInfo(
        Icons.location_searching,
        'Position introuvable',
        'Impossible d\'obtenir votre position à temps. Réessayez, ou '
            'recherchez une ville.',
      ),
      _ => const _ErrorInfo(
        Icons.error_outline,
        'Une erreur est survenue',
        'Réessayez dans un instant.',
      ),
    };
  }
}

class _ErrorInfo {
  const _ErrorInfo(
    this.icon,
    this.message,
    this.hint, {
    this.showOpenSettings = false,
  });

  final IconData icon;
  final String message;
  final String? hint;
  final bool showOpenSettings;
}
