/// Les échecs que la géolocalisation peut rencontrer.
///
/// Comme pour la météo, chaque cas est distinct pour que l'interface puisse
/// dire ce qui s'est passé et proposer le bon geste. Le service renvoyait
/// auparavant des `String` brutes via `Future.error`, que l'écran affichait
/// telles quelles — sans distinguer un service coupé d'une permission refusée,
/// et sans offrir de sortie à l'utilisateur bloqué.
sealed class LocationException implements Exception {
  const LocationException(this.message);

  /// Description technique, destinée aux logs et aux tests — jamais à l'écran.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// La localisation est désactivée au niveau de l'appareil.
class LocationServiceDisabledException extends LocationException {
  const LocationServiceDisabledException()
    : super('Location services are disabled');
}

/// L'utilisateur a refusé la permission pour cette fois.
class LocationPermissionDeniedException extends LocationException {
  const LocationPermissionDeniedException()
    : super('Location permission was denied');
}

/// La permission est refusée définitivement : seule une visite aux réglages
/// système peut la rétablir. C'est le cas qui justifie un bouton dédié.
class LocationPermissionPermanentlyDeniedException extends LocationException {
  const LocationPermissionPermanentlyDeniedException()
    : super('Location permission is permanently denied');
}

/// La position n'est pas arrivée dans le délai imparti.
class LocationTimeoutException extends LocationException {
  const LocationTimeoutException() : super('Location request timed out');
}
