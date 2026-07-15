import 'package:flutter_test/flutter_test.dart';
import 'package:skypulse/utils/unit_utils.dart';

void main() {
  group('UnitConverter', () {
    test('celsiusToFahrenheit', () {
      expect(UnitConverter.celsiusToFahrenheit(0), 32);
      expect(UnitConverter.celsiusToFahrenheit(100), 212);
      expect(UnitConverter.celsiusToFahrenheit(25), 77);
    });

    test('mpsToKmh', () {
      expect(UnitConverter.mpsToKmh(0), 0);
      expect(UnitConverter.mpsToKmh(10), 36);
    });

    test('mpsToMph', () {
      expect(UnitConverter.mpsToMph(0), 0);
      expect(UnitConverter.mpsToMph(1), closeTo(2.23694, 0.001));
    });

    test('formatTemperature metric', () {
      expect(UnitConverter.formatTemperature(25, UnitSystem.metric), '25.0°C');
    });

    test('formatTemperature imperial', () {
      expect(
        UnitConverter.formatTemperature(25, UnitSystem.imperial),
        '77.0°F',
      );
    });

    test('formatWindSpeed metric', () {
      expect(
        UnitConverter.formatWindSpeed(5.14, UnitSystem.metric),
        '18.5 km/h',
      );
    });

    test('formatWindSpeed imperial', () {
      expect(
        UnitConverter.formatWindSpeed(5.14, UnitSystem.imperial),
        '11.5 mph',
      );
    });

    test('formatTempRounded metric', () {
      expect(UnitConverter.formatTempRounded(25, UnitSystem.metric), '25°');
    });

    test('formatTempRounded imperial', () {
      expect(UnitConverter.formatTempRounded(25, UnitSystem.imperial), '77°');
    });
  });
}
