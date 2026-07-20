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

    test('formatPressure metric shows hPa', () {
      expect(UnitConverter.formatPressure(1013, UnitSystem.metric), '1013 hPa');
    });

    test('formatPressure imperial converts to inHg', () {
      expect(
        UnitConverter.formatPressure(1013, UnitSystem.imperial),
        '29.91 inHg',
      );
    });

    test('formatVisibility metric shows km', () {
      expect(
        UnitConverter.formatVisibility(10000, UnitSystem.metric),
        '10.0 km',
      );
    });

    test('formatVisibility imperial converts to miles', () {
      expect(
        UnitConverter.formatVisibility(10000, UnitSystem.imperial),
        '6.2 mi',
      );
    });

    test('windCardinal maps degrees to an 8-point compass', () {
      expect(UnitConverter.windCardinal(0), 'N');
      expect(UnitConverter.windCardinal(90), 'E');
      expect(UnitConverter.windCardinal(180), 'S');
      expect(UnitConverter.windCardinal(270), 'O');
      expect(UnitConverter.windCardinal(45), 'NE');
      expect(UnitConverter.windCardinal(360), 'N'); // wraps
    });
  });
}
