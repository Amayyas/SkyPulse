import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/models/city_suggestion.dart';
import 'package:skypulse/services/weather_exception.dart';
import 'package:skypulse/utils/constants.dart';

class WeatherService {
  WeatherService({http.Client? client, String? apiKey})
    : client = client ?? http.Client(),
      _apiKey = apiKey ?? AppConstants.openWeatherMapApiKey;

  final http.Client client;
  final String _apiKey;

  static const Duration _timeout = Duration(seconds: 10);

  /// Closes the underlying HTTP client. Call from the provider's `onDispose`.
  void dispose() => client.close();

  /// Builds an HTTPS request whose parameters are percent-encoded.
  ///
  /// Never assemble a URL by string interpolation: a city name contains spaces
  /// and accents (`New York`, `Saint-Étienne`) that are illegal as-is in a URI.
  /// `Uri.https` imposes the scheme and encodes the values.
  Uri _apiUri(String path, Map<String, String> queryParameters) {
    // No key means the build was never configured — surface that as its own
    // error rather than firing a request that can only come back 401.
    if (_apiKey.isEmpty) throw const MissingApiKeyException();
    return Uri.https(AppConstants.apiHost, path, {
      ...queryParameters,
      'appid': _apiKey,
    });
  }

  /// Sends the request and translates each failure into a [WeatherException].
  ///
  /// Only returns on a 200. Everything else throws: a call that returns
  /// normally has therefore received a genuine server response.
  Future<String> _get(Uri url, {String? cityName}) async {
    final http.Response response;
    try {
      response = await client.get(url).timeout(_timeout);
    } on TimeoutException {
      throw const NoConnectionException('The request timed out');
    } on http.ClientException catch (e) {
      // package:http wraps socket, DNS and TLS failures here, on every platform
      // — hence no dart:io, which isn't available on the web.
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

  /// Decodes a response body, turning an unexpected shape into a
  /// [MalformedResponseException] rather than a `TypeError` bubbling up to the
  /// UI.
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

    // Returned as-is: every entry is a real 3-hourly reading from the API.
    // These used to be interpolated up to 24 hourly points, which invented
    // conditions the forecaster never issued — see the note on the class.
    return _decode(body, (json) {
      final list = (json as Map<String, dynamic>)['list'] as List<dynamic>;
      return list.map((e) => Weather.fromForecastJson(e)).toList();
    });
  }

  /// Searches for city suggestions.
  ///
  /// A query that's too short isn't worth a network call: returns an empty
  /// list. A search with no match returns one too — that's not an error, the
  /// API responds 200 with an empty array. Everything else throws.
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
}
