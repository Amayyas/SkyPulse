import 'package:flutter_test/flutter_test.dart';
import 'package:skypulse/models/weather_model.dart';

void main() {
  group('Weather Model Tests', () {
    test('Weather constructor creates valid instance', () {
      final weather = Weather(
        cityName: 'Paris',
        temperature: 20.5,
        feelsLike: 19.0,
        tempMin: 18.0,
        tempMax: 23.0,
        description: 'clear sky',
        iconCode: '01d',
        humidity: 60,
        windSpeed: 5.5,
        date: DateTime(2025, 11, 28),
        sunrise: 1638340000,
        sunset: 1638380000,
        lat: 48.8566,
        lon: 2.3522,
      );

      expect(weather.cityName, 'Paris');
      expect(weather.temperature, 20.5);
      expect(weather.description, 'clear sky');
    });

    test('Weather.fromJson parses JSON correctly', () {
      final json = {
        'coord': {'lon': 2.3522, 'lat': 48.8566},
        'weather': [
          {
            'id': 800,
            'main': 'Clear',
            'description': 'clear sky',
            'icon': '01d',
          },
        ],
        'main': {
          'temp': 20.5,
          'feels_like': 19.5,
          'temp_min': 18.0,
          'temp_max': 22.0,
          'humidity': 60,
        },
        'wind': {'speed': 3.5},
        'dt': 1638360000,
        'sys': {'sunrise': 1638340000, 'sunset': 1638380000},
        'name': 'Paris',
      };

      final weather = Weather.fromJson(json);

      expect(weather.cityName, 'Paris');
      expect(weather.temperature, 20.5);
      expect(weather.feelsLike, 19.5);
      expect(weather.humidity, 60);
      expect(weather.windSpeed, 3.5);
      expect(weather.iconCode, '01d');
    });

    test('Weather.fromForecastJson parses forecast JSON correctly', () {
      final json = {
        'dt': 1638360000,
        'main': {
          'temp': 20.5,
          'feels_like': 19.5,
          'temp_min': 18.0,
          'temp_max': 22.0,
          'humidity': 60,
        },
        'weather': [
          {
            'id': 800,
            'main': 'Clear',
            'description': 'clear sky',
            'icon': '01d',
          },
        ],
        'wind': {'speed': 3.5},
      };

      final weather = Weather.fromForecastJson(json);

      expect(weather.temperature, 20.5);
      expect(weather.feelsLike, 19.5);
      expect(weather.description, 'clear sky');
    });
  });
}
