import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/models/city_suggestion.dart';
import 'package:skypulse/utils/constants.dart';

class WeatherService {
  final http.Client client;

  WeatherService({http.Client? client}) : client = client ?? http.Client();

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

  Future<Weather> getCurrentWeather(double lat, double lon) async {
    final url = _apiUri(AppConstants.currentWeatherPath, {
      'lat': '$lat',
      'lon': '$lon',
      'units': 'metric',
    });

    final response = await client.get(url);

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      return _getMockWeather();
    }
  }

  Future<Weather> getWeatherByCity(String cityName) async {
    final url = _apiUri(AppConstants.currentWeatherPath, {
      'q': cityName,
      'units': 'metric',
    });

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        return _getMockWeather(cityName: cityName);
      }
    } catch (e) {
      return _getMockWeather(cityName: cityName);
    }
  }

  Future<List<Weather>> getForecast(double lat, double lon) async {
    final url = _apiUri(AppConstants.forecastPath, {
      'lat': '$lat',
      'lon': '$lon',
      'units': 'metric',
    });

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['list'];
        final forecasts3h = list
            .map((e) => Weather.fromForecastJson(e))
            .toList();

        // Interpoler pour obtenir des prévisions horaires
        return _interpolateHourlyForecasts(forecasts3h);
      } else {
        return _getMockForecast();
      }
    } catch (e) {
      return _getMockForecast();
    }
  }

  // Rechercher des suggestions de villes
  Future<List<CitySuggestion>> searchCities(String query) async {
    if (query.isEmpty || query.length < 2) {
      return [];
    }

    final url = _apiUri(AppConstants.geocodingPath, {'q': query, 'limit': '5'});

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CitySuggestion.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
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
          ),
        );
      }
    }

    // Ajouter la dernière prévision
    if (forecasts3h.isNotEmpty) {
      hourlyForecasts.add(forecasts3h.last);
    }

    return hourlyForecasts;
  }

  Weather _getMockWeather({String cityName = "Paris (Demo)"}) {
    return Weather(
      cityName: cityName,
      temperature: 22.5,
      feelsLike: 24.0,
      tempMin: 20.0,
      tempMax: 25.0,
      description: "ciel dégagé",
      iconCode: "01d",
      humidity: 60,
      windSpeed: 5.2,
      date: DateTime.now(),
      sunrise: DateTime.now().millisecondsSinceEpoch ~/ 1000 - 20000,
      sunset: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 20000,
      lat: 48.8566,
      lon: 2.3522,
    );
  }

  List<Weather> _getMockForecast() {
    return List.generate(40, (index) {
      final date = DateTime.now().add(Duration(hours: index * 3));
      final isDay = date.hour > 6 && date.hour < 20;
      return Weather(
        cityName: "Demo City",
        temperature: 18.0 + (index % 5),
        feelsLike: 17.0 + (index % 5),
        tempMin: 15.0,
        tempMax: 22.0,
        description: index % 3 == 0 ? "pluie légère" : "nuageux",
        iconCode: index % 3 == 0 ? "10d" : (isDay ? "02d" : "02n"),
        humidity: 60 + (index % 20),
        windSpeed: 4.0 + (index % 4),
        date: date,
        sunrise: 0,
        sunset: 0,
      );
    });
  }
}
