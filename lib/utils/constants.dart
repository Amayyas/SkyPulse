class AppConstants {
  // TODO: Remplacez cette clé par votre propre clé API OpenWeatherMap
  // Obtenez votre clé gratuite sur : https://openweathermap.org/api
  static const String openWeatherMapApiKey = 'YOUR_API_KEY_HERE';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String iconUrl = 'https://openweathermap.org/img/wn/';

  // Traductions des descriptions météo en français
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
