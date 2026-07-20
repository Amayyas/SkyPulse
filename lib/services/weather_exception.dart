/// Les échecs que le service météo peut rencontrer.
///
/// Chaque cas est distinct pour que l'interface puisse dire à l'utilisateur ce
/// qui s'est réellement passé — et surtout, pour qu'un échec ne puisse plus être
/// déguisé en succès. Le service renvoyait autrefois une météo fabriquée quand
/// une requête échouait, ce qui masquait aussi bien une clé invalide qu'une
/// coupure réseau ou une plateforme entière incapable de sortir sur Internet.
sealed class WeatherException implements Exception {
  const WeatherException(this.message);

  /// Description technique, destinée aux logs et aux tests — jamais à l'écran.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Aucune clé n'a été fournie au build (`--dart-define=OWM_API_KEY=...`).
///
/// Distinct de [InvalidApiKeyException] : ici on n'appelle même pas l'API, la
/// clé est vide. Le message pointe vers la configuration plutôt que vers un
/// problème de compte.
class MissingApiKeyException extends WeatherException {
  const MissingApiKeyException()
    : super('No API key was provided at build time');
}

/// L'API a rejeté la clé (HTTP 401).
///
/// En pratique : la clé est fausse, ou vient d'être créée (OpenWeatherMap met
/// jusqu'à deux heures à l'activer).
class InvalidApiKeyException extends WeatherException {
  const InvalidApiKeyException() : super('The API rejected the key (HTTP 401)');
}

/// La ville demandée est introuvable (HTTP 404).
class CityNotFoundException extends WeatherException {
  const CityNotFoundException(this.cityName)
    : super('No city matched the query (HTTP 404)');

  final String cityName;
}

/// Quota dépassé (HTTP 429). Le palier gratuit autorise 60 appels par minute.
class RateLimitException extends WeatherException {
  const RateLimitException() : super('Rate limit exceeded (HTTP 429)');
}

/// La requête n'a jamais atteint le serveur : pas de réseau, DNS en échec,
/// trafic en clair bloqué par la plateforme, ou délai dépassé.
class NoConnectionException extends WeatherException {
  const NoConnectionException(super.message);
}

/// Le serveur a répondu autre chose qu'un succès, sans cas particulier connu.
class WeatherApiException extends WeatherException {
  const WeatherApiException(this.statusCode)
    : super('Unexpected response from the API');

  final int statusCode;

  @override
  String toString() => 'WeatherApiException: HTTP $statusCode';
}

/// Le serveur a répondu 200, mais le corps n'a pas la forme attendue.
///
/// La validation champ par champ dans les modèles reste à faire (#8) ; cette
/// exception est le filet posé à la frontière du service, pour qu'une réponse
/// malformée devienne une erreur affichable plutôt qu'un `TypeError` brut.
class MalformedResponseException extends WeatherException {
  const MalformedResponseException(super.message);
}
