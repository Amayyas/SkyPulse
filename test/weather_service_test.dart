import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skypulse/services/weather_service.dart';
import 'package:skypulse/models/weather_model.dart';

@GenerateMocks([http.Client])
import 'weather_service_test.mocks.dart';

const _weatherBody = '''
{
  "coord": {"lon": 2.3522, "lat": 48.8566},
  "weather": [{"id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"}],
  "main": {"temp": 20.5, "feels_like": 19.5, "temp_min": 18.0, "temp_max": 22.0, "humidity": 60},
  "wind": {"speed": 3.5},
  "dt": 1638360000,
  "sys": {"sunrise": 1638340000, "sunset": 1638380000},
  "name": "Paris"
}
''';

void main() {
  group('WeatherService Tests', () {
    late WeatherService weatherService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      weatherService = WeatherService(client: mockClient);
    });

    /// Stubs a 200 response with [body], runs [call], and returns the URI the
    /// service actually requested.
    Future<Uri> requestedUri(String body, Future<void> Function() call) async {
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response(body, 200));
      await call();
      return verify(mockClient.get(captureAny)).captured.single as Uri;
    }

    test('getCurrentWeather returns Weather when successful', () async {
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response(_weatherBody, 200));

      final result = await weatherService.getCurrentWeather(48.8566, 2.3522);

      expect(result, isA<Weather>());
      expect(result.cityName, 'Paris');
      expect(result.temperature, 20.5);
      expect(result.description, 'clear sky');
    });

    test('searchCities returns list of cities', () async {
      const body = '''
      [
        {
          "name": "Paris",
          "lat": 48.8566,
          "lon": 2.3522,
          "country": "FR",
          "state": "Île-de-France"
        }
      ]
      ''';

      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response(body, 200));

      final result = await weatherService.searchCities('Paris');

      expect(result.length, 1);
      expect(result[0].name, 'Paris');
      expect(result[0].country, 'FR');
    });

    test('searchCities returns empty list when query is too short', () async {
      final result = await weatherService.searchCities('P');

      expect(result, isEmpty);
      verifyNever(mockClient.get(any));
    });

    // Every endpoint must be requested over HTTPS with percent-encoded query
    // parameters. Cleartext HTTP is blocked by default on Android (API 28+) and
    // by App Transport Security on iOS; an unencoded city name produces a
    // malformed URI.
    group('request URIs', () {
      test('current weather is requested over https', () async {
        final uri = await requestedUri(
          _weatherBody,
          () => weatherService.getCurrentWeather(48.8566, 2.3522),
        );

        expect(uri.scheme, 'https');
        expect(uri.host, 'api.openweathermap.org');
        expect(uri.path, '/data/2.5/weather');
        expect(uri.queryParameters['lat'], '48.8566');
        expect(uri.queryParameters['lon'], '2.3522');
        expect(uri.queryParameters['units'], 'metric');
        expect(uri.queryParameters.containsKey('appid'), isTrue);
      });

      test('forecast is requested over https', () async {
        final uri = await requestedUri(
          '{"list": []}',
          () => weatherService.getForecast(48.8566, 2.3522),
        );

        expect(uri.scheme, 'https');
        expect(uri.path, '/data/2.5/forecast');
      });

      test('geocoding is requested over https, not cleartext', () async {
        final uri = await requestedUri(
          '[]',
          () => weatherService.searchCities('Paris'),
        );

        expect(uri.scheme, 'https');
        expect(uri.host, 'api.openweathermap.org');
        expect(uri.path, '/geo/1.0/direct');
        expect(uri.queryParameters['limit'], '5');
      });

      // Uri.https encodes a space in a query value as `+`, the
      // application/x-www-form-urlencoded convention, rather than `%20`. Both
      // are valid in a query string. What matters is that no raw space reaches
      // the URI, and that the value round-trips.
      test('a city name containing a space is encoded', () async {
        final uri = await requestedUri(
          '[]',
          () => weatherService.searchCities('New York'),
        );

        expect(uri.queryParameters['q'], 'New York');
        expect(uri.toString(), isNot(contains(' ')));
        expect(uri.toString(), contains('q=New+York'));
      });

      test('a city name containing accents is percent-encoded', () async {
        final uri = await requestedUri(
          '[]',
          () => weatherService.searchCities('Saint-Étienne'),
        );

        expect(uri.queryParameters['q'], 'Saint-Étienne');
        expect(uri.toString(), contains('Saint-%C3%89tienne'));
      });

      test('getWeatherByCity encodes the city name too', () async {
        final uri = await requestedUri(
          _weatherBody,
          () => weatherService.getWeatherByCity('Besançon'),
        );

        expect(uri.scheme, 'https');
        expect(uri.path, '/data/2.5/weather');
        expect(uri.queryParameters['q'], 'Besançon');
        expect(uri.toString(), contains('Besan%C3%A7on'));
      });
    });
  });
}
