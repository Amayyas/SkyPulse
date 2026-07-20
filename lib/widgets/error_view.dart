import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'
    hide LocationServiceDisabledException;
import 'package:skypulse/l10n/app_localizations.dart';
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
    final info = _describe(error, AppLocalizations.of(context));

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
                      label: Text(AppLocalizations.of(context).openSettings),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onRetry,
                      child: Text(AppLocalizations.of(context).retry),
                    ),
                  ] else
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: Text(AppLocalizations.of(context).retry),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Maps an error to an icon, message, hint and action.
  ///
  /// The technical message of the exception is never shown — it goes to logs
  /// and tests, not the screen.
  static _ErrorInfo _describe(Object error, AppLocalizations l10n) {
    return switch (error) {
      MissingApiKeyException() => _ErrorInfo(
        Icons.vpn_key_off,
        l10n.errApiKeyMissingTitle,
        l10n.errApiKeyMissingHint,
      ),
      InvalidApiKeyException() => _ErrorInfo(
        Icons.key_off,
        l10n.errApiKeyInvalidTitle,
        l10n.errApiKeyInvalidHint,
      ),
      CityNotFoundException(cityName: final city) => _ErrorInfo(
        Icons.location_off,
        city.isEmpty
            ? l10n.errCityNotFoundTitle
            : l10n.errCityNotFoundTitleNamed(city),
        l10n.errCityNotFoundHint,
      ),
      RateLimitException() => _ErrorInfo(
        Icons.hourglass_empty,
        l10n.errRateLimitTitle,
        l10n.errRateLimitHint,
      ),
      NoConnectionException() => _ErrorInfo(
        Icons.wifi_off,
        l10n.errNoConnectionTitle,
        l10n.errNoConnectionHint,
      ),
      WeatherApiException(statusCode: final code) => _ErrorInfo(
        Icons.cloud_off,
        l10n.errServiceTitle,
        l10n.errServiceHint(code),
      ),
      MalformedResponseException() => _ErrorInfo(
        Icons.error_outline,
        l10n.errMalformedTitle,
        l10n.errMalformedHint,
      ),
      LocationServiceDisabledException() => _ErrorInfo(
        Icons.location_disabled,
        l10n.errLocationDisabledTitle,
        l10n.errLocationDisabledHint,
      ),
      LocationPermissionDeniedException() => _ErrorInfo(
        Icons.location_off,
        l10n.errLocationDeniedTitle,
        l10n.errLocationDeniedHint,
      ),
      LocationPermissionPermanentlyDeniedException() => _ErrorInfo(
        Icons.location_off,
        l10n.errLocationBlockedTitle,
        l10n.errLocationBlockedHint,
        showOpenSettings: true,
      ),
      LocationTimeoutException() => _ErrorInfo(
        Icons.location_searching,
        l10n.errLocationTimeoutTitle,
        l10n.errLocationTimeoutHint,
      ),
      _ => _ErrorInfo(
        Icons.error_outline,
        l10n.errGenericTitle,
        l10n.errGenericHint,
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
