/// The failures geolocation can hit.
///
/// As with weather, each case is distinct so the UI can say what happened and
/// offer the right action. The service used to return raw `String`s via
/// `Future.error`, which the screen showed verbatim — without telling a
/// disabled service apart from a denied permission, and without offering a way
/// out to a blocked user.
sealed class LocationException implements Exception {
  const LocationException(this.message);

  /// Technical description, for logs and tests — never the screen.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Location is turned off at the device level.
class LocationServiceDisabledException extends LocationException {
  const LocationServiceDisabledException()
    : super('Location services are disabled');
}

/// The user denied the permission this time.
class LocationPermissionDeniedException extends LocationException {
  const LocationPermissionDeniedException()
    : super('Location permission was denied');
}

/// The permission is permanently denied: only a trip to the system settings can
/// restore it. This is the case that warrants a dedicated button.
class LocationPermissionPermanentlyDeniedException extends LocationException {
  const LocationPermissionPermanentlyDeniedException()
    : super('Location permission is permanently denied');
}

/// The position didn't arrive within the allotted time.
class LocationTimeoutException extends LocationException {
  const LocationTimeoutException() : super('Location request timed out');
}
