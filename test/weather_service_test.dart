import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skypulse/services/weather_service.dart';
import 'package:skypulse/models/weather_model.dart';

@GenerateMocks([http.Client])
import 'weather_service_test.mocks.dart';

void main() {
  group('WeatherService Tests', () {
    late WeatherService weatherService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      weatherService = WeatherService(client: mockClient);
    });

    test('getCurrentWeather returns Weather when successful', () async {
      // Arrange
      const lat = 48.8566;
      const lon = 2.3522;
      final mockResponse =
          '''
      {
        "coord": {"lon": $lon, "lat": $lat},
        "weather": [{"id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"}],
        "main": {"temp": 20.5, "feels_like": 19.5, "temp_min": 18.0, "temp_max": 22.0, "humidity": 60},
        "wind": {"speed": 3.5},
        "dt": 1638360000,
        "sys": {"sunrise": 1638340000, "sunset": 1638380000},
        "name": "Paris"
      }
      ''';

      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response(mockResponse, 200));

      // Act
      final result = await weatherService.getCurrentWeather(lat, lon);

      // Assert
      expect(result, isA<Weather>());
      expect(result.cityName, 'Paris');
      expect(result.temperature, 20.5);
      expect(result.description, 'clear sky');
    });

    test('searchCities returns list of cities', () async {
      // Arrange
      const query = 'Paris';
      final mockResponse = '''
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
      ).thenAnswer((_) async => http.Response(mockResponse, 200));

      // Act
      final result = await weatherService.searchCities(query);

      // Assert
      expect(result.length, 1);
      expect(result[0].name, 'Paris');
      expect(result[0].country, 'FR');
    });

    test('searchCities returns empty list when query is too short', () async {
      // Act
      final result = await weatherService.searchCities('P');

      // Assert
      expect(result, isEmpty);
    });
  });
}
