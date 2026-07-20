import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/models/city_suggestion.dart';
import 'package:skypulse/services/weather_exception.dart';
import 'package:skypulse/utils/constants.dart';

class WeatherService {
  WeatherService({http.Client? client}) : client = client ?? http.Client();

  final http.Client client;

  static const Duration _timeout = Duration(seconds: 10);

  /// Closes the underlying HTTP client. Call from the provider's `onDispose`.
  void dispose() => client.close();

  /// Construit une requête HTTPS dont les paramètres sont percent-encodés.
  ///
  /// Ne jamais assembler une URL par interpolation de chaîne : un nom de ville
  /// contient des espaces et des accents (`New York`, `Saint-Étienne`) qui sont
  /// illégaux tels quels dans une URI. `Uri.https` impose le schéma et encode
  /// les valeurs.
  Uri _apiUri(String path, Map<String, String> queryParameters) {
    return Uri.https(AppConstants.apiHost, path, {
      ...queryParameters,
      'appid': AppConstants.openWeatherMapApiKey,
    });
  }

  /// Émet la requête et traduit chaque échec en [WeatherException].
  ///
  /// Ne renvoie que sur un 200. Tout le reste lève : un appel qui retourne
  /// normalement a donc forcément reçu une vraie réponse du serveur.
  Future<String> _get(Uri url, {String? cityName}) async {
    final http.Response response;
    try {
      response = await client.get(url).timeout(_timeout);
    } on TimeoutException {
      throw const NoConnectionException('The request timed out');
    } on http.ClientException catch (e) {
      // package:http emballe ici les échecs de socket, de DNS et de TLS, sur
      // toutes les plateformes — d'où l'absence de dart:io, indisponible sur le
      // web.
      throw NoConnectionException('The request never reached the server: $e');
    }

    return switch (response.statusCode) {
      200 => response.body,
      401 => throw const InvalidApiKeyException(),
      404 => throw CityNotFoundException(cityName ?? ''),
      429 => throw const RateLimitException(),
      final int code => throw WeatherApiException(code),
    };
  }

  /// Décode un corps de réponse, en transformant une forme inattendue en
  /// [MalformedResponseException] plutôt qu'en `TypeError` remonté jusqu'à
  /// l'interface.
  T _decode<T>(String body, T Function(dynamic json) parse) {
    try {
      return parse(jsonDecode(body));
    } on WeatherException {
      rethrow;
    } catch (e) {
      throw MalformedResponseException('Could not parse the response: $e');
    }
  }

  Future<Weather> getCurrentWeather(double lat, double lon) async {
    final body = await _get(
      _apiUri(AppConstants.currentWeatherPath, {
        'lat': '$lat',
        'lon': '$lon',
        'units': 'metric',
      }),
    );

    return _decode(body, (json) => Weather.fromJson(json));
  }

  Future<Weather> getWeatherByCity(String cityName) async {
    final body = await _get(
      _apiUri(AppConstants.currentWeatherPath, {
        'q': cityName,
        'units': 'metric',
      }),
      cityName: cityName,
    );

    return _decode(body, (json) => Weather.fromJson(json));
  }

  Future<List<Weather>> getForecast(double lat, double lon) async {
    final body = await _get(
      _apiUri(AppConstants.forecastPath, {
        'lat': '$lat',
        'lon': '$lon',
        'units': 'metric',
      }),
    );

    final forecasts3h = _decode(body, (json) {
      final list = (json as Map<String, dynamic>)['list'] as List<dynamic>;
      return list.map((e) => Weather.fromForecastJson(e)).toList();
    });

    // Interpoler pour obtenir des prévisions horaires
    return _interpolateHourlyForecasts(forecasts3h);
  }

  /// Rechercher des suggestions de villes.
  ///
  /// Une requête trop courte ne vaut pas un appel réseau : renvoie une liste
  /// vide. Une recherche sans résultat en renvoie une aussi — ce n'est pas une
  /// erreur, et l'API répond 200 avec un tableau vide. Tout le reste lève.
  Future<List<CitySuggestion>> searchCities(String query) async {
    if (query.length < 2) {
      return [];
    }

    final body = await _get(
      _apiUri(AppConstants.geocodingPath, {'q': query, 'limit': '5'}),
      cityName: query,
    );

    return _decode(body, (json) {
      final list = json as List<dynamic>;
      return list.map((e) => CitySuggestion.fromJson(e)).toList();
    });
  }

  // Interpoler les prévisions de 3h en prévisions horaires
  List<Weather> _interpolateHourlyForecasts(List<Weather> forecasts3h) {
    if (forecasts3h.isEmpty) return [];

    List<Weather> hourlyForecasts = [];

    for (int i = 0; i < forecasts3h.length - 1; i++) {
      final current = forecasts3h[i];
      final next = forecasts3h[i + 1];

      // Ajouter la prévision actuelle
      hourlyForecasts.add(current);

      // Interpoler les 2 heures entre current et next
      for (int hour = 1; hour < 3; hour++) {
        final ratio = hour / 3.0;
        final interpolatedDate = current.date.add(Duration(hours: hour));

        hourlyForecasts.add(
          Weather(
            cityName: current.cityName,
            temperature:
                current.temperature +
                (next.temperature - current.temperature) * ratio,
            feelsLike:
                current.feelsLike +
                (next.feelsLike - current.feelsLike) * ratio,
            tempMin: current.tempMin + (next.tempMin - current.tempMin) * ratio,
            tempMax: current.tempMax + (next.tempMax - current.tempMax) * ratio,
            description: current.description, // Garder la description actuelle
            iconCode: current.iconCode, // Garder l'icône actuelle
            humidity:
                current.humidity +
                ((next.humidity - current.humidity) * ratio).round(),
            windSpeed:
                current.windSpeed +
                (next.windSpeed - current.windSpeed) * ratio,
            date: interpolatedDate,
            sunrise: current.sunrise,
            sunset: current.sunset,
            pop: current.pop, // carried from the 3h slot, like the icon
          ),
        );
      }
    }

    // Ajouter la dernière prévision
    hourlyForecasts.add(forecasts3h.last);

    return hourlyForecasts;
  }
}
