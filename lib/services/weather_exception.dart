/// The failures the weather service can hit.
///
/// Each case is distinct so the UI can tell the user what actually happened —
/// and, above all, so a failure can no longer be disguised as success. The
/// service used to return fabricated weather when a request failed, which hid
/// an invalid key just as much as a dead network or an entire platform unable
/// to reach the internet.
sealed class WeatherException implements Exception {
  const WeatherException(this.message);

  /// Technical description, for logs and tests — never the screen.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// No key was provided at build time (`--dart-define=OWM_API_KEY=...`).
///
/// Distinct from [InvalidApiKeyException]: here the API is never even called,
/// the key is empty. The message points at configuration rather than an account
/// problem.
class MissingApiKeyException extends WeatherException {
  const MissingApiKeyException()
    : super('No API key was provided at build time');
}

/// The API rejected the key (HTTP 401).
///
/// In practice: the key is wrong, or freshly created (OpenWeatherMap takes up
/// to two hours to activate one).
class InvalidApiKeyException extends WeatherException {
  const InvalidApiKeyException() : super('The API rejected the key (HTTP 401)');
}

/// The requested city was not found (HTTP 404).
class CityNotFoundException extends WeatherException {
  const CityNotFoundException(this.cityName)
    : super('No city matched the query (HTTP 404)');

  final String cityName;
}

/// Quota exceeded (HTTP 429). The free tier allows 60 calls per minute.
class RateLimitException extends WeatherException {
  const RateLimitException() : super('Rate limit exceeded (HTTP 429)');
}

/// The request never reached the server: no network, DNS failure, cleartext
/// traffic blocked by the platform, or a timeout.
class NoConnectionException extends WeatherException {
  const NoConnectionException(super.message);
}

/// The server responded with something other than success, with no known
/// special case.
class WeatherApiException extends WeatherException {
  const WeatherApiException(this.statusCode)
    : super('Unexpected response from the API');

  final int statusCode;

  @override
  String toString() => 'WeatherApiException: HTTP $statusCode';
}

/// The server responded 200, but the body isn't the expected shape.
///
/// Field-by-field validation in the models is still to do (#8); this exception
/// is the net at the service boundary, so a malformed response becomes a
/// displayable error instead of a raw `TypeError`.
class MalformedResponseException extends WeatherException {
  const MalformedResponseException(super.message);
}
