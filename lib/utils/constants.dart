class AppConstants {
  /// OpenWeatherMap API key, injected at build time — never written to a
  /// git-tracked file.
  ///
  ///   flutter run --dart-define=OWM_API_KEY=your_key
  ///
  /// Empty when not supplied; the service then throws a MissingApiKeyException
  /// rather than firing a request with no key. Get a free key at
  /// https://openweathermap.org/api
  static const String openWeatherMapApiKey = String.fromEnvironment(
    'OWM_API_KEY',
  );

  /// Host shared by the weather and geocoding APIs.
  ///
  /// Exposed as host + paths rather than a full URL: requests are built with
  /// `Uri.https`, which imposes the scheme and encodes the parameters. A
  /// hand-assembled URL lets through the two bugs this split makes impossible —
  /// cleartext HTTP and unencoded accents.
  static const String apiHost = 'api.openweathermap.org';

  static const String currentWeatherPath = '/data/2.5/weather';
  static const String forecastPath = '/data/2.5/forecast';
  static const String geocodingPath = '/geo/1.0/direct';

  static const String iconUrl = 'https://openweathermap.org/img/wn/';

  // French translations of the weather descriptions (shown to French users).
  static String translateWeatherDescription(String description) {
    final translations = {
      'clear sky': 'ciel dégagé',
      'few clouds': 'quelques nuages',
      'scattered clouds': 'nuages épars',
      'broken clouds': 'nuages fragmentés',
      'overcast clouds': 'nuages couverts',
      'shower rain': 'averses',
      'rain': 'pluie',
      'light rain': 'pluie légère',
      'moderate rain': 'pluie modérée',
      'heavy intensity rain': 'forte pluie',
      'very heavy rain': 'pluie très forte',
      'extreme rain': 'pluie extrême',
      'freezing rain': 'pluie verglaçante',
      'light intensity shower rain': 'légères averses',
      'heavy intensity shower rain': 'fortes averses',
      'ragged shower rain': 'averses irrégulières',
      'thunderstorm': 'orage',
      'thunderstorm with light rain': 'orage avec pluie légère',
      'thunderstorm with rain': 'orage avec pluie',
      'thunderstorm with heavy rain': 'orage avec forte pluie',
      'light thunderstorm': 'orage léger',
      'heavy thunderstorm': 'orage violent',
      'ragged thunderstorm': 'orage irrégulier',
      'thunderstorm with light drizzle': 'orage avec bruine légère',
      'thunderstorm with drizzle': 'orage avec bruine',
      'thunderstorm with heavy drizzle': 'orage avec forte bruine',
      'snow': 'neige',
      'light snow': 'neige légère',
      'heavy snow': 'neige forte',
      'sleet': 'neige fondue',
      'light shower sleet': 'légères averses de neige fondue',
      'shower sleet': 'averses de neige fondue',
      'light rain and snow': 'pluie et neige légères',
      'rain and snow': 'pluie et neige',
      'light shower snow': 'légères averses de neige',
      'shower snow': 'averses de neige',
      'heavy shower snow': 'fortes averses de neige',
      'mist': 'brume',
      'smoke': 'fumée',
      'haze': 'brume sèche',
      'sand/dust whirls': 'tourbillons de sable/poussière',
      'fog': 'brouillard',
      'sand': 'sable',
      'dust': 'poussière',
      'volcanic ash': 'cendres volcaniques',
      'squalls': 'bourrasques',
      'tornado': 'tornade',
      'drizzle': 'bruine',
      'light intensity drizzle': 'bruine légère',
      'heavy intensity drizzle': 'bruine forte',
      'light intensity drizzle rain': 'bruine et pluie légères',
      'drizzle rain': 'bruine et pluie',
      'heavy intensity drizzle rain': 'bruine et pluie fortes',
      'shower rain and drizzle': 'averses et bruine',
      'heavy shower rain and drizzle': 'fortes averses et bruine',
      'shower drizzle': 'averses de bruine',
    };

    return translations[description.toLowerCase()] ?? description;
  }
}
