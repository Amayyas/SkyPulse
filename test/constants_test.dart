import 'package:flutter_test/flutter_test.dart';
import 'package:skypulse/utils/constants.dart';

void main() {
  group('AppConstants Tests', () {
    test('translateWeatherDescription returns French translation', () {
      expect(
        AppConstants.translateWeatherDescription('clear sky'),
        equals('ciel dégagé'),
      );
    });

    test(
      'translateWeatherDescription returns original for unknown description',
      () {
        expect(
          AppConstants.translateWeatherDescription('unknown weather'),
          equals('unknown weather'),
        );
      },
    );

    test('translateWeatherDescription handles case insensitivity', () {
      expect(
        AppConstants.translateWeatherDescription('Clear Sky'),
        equals('ciel dégagé'),
      );
    });

    test('translateWeatherDescription handles rain variations', () {
      expect(
        AppConstants.translateWeatherDescription('light rain'),
        equals('pluie légère'),
      );

      expect(
        AppConstants.translateWeatherDescription('moderate rain'),
        equals('pluie modérée'),
      );
    });

    test('API key is not empty', () {
      expect(AppConstants.openWeatherMapApiKey, isNotEmpty);
    });

    test('Base URL is valid', () {
      expect(AppConstants.baseUrl, contains('openweathermap.org'));
    });
  });
}
