import 'package:flutter_test/flutter_test.dart';
import 'package:skypulse/utils/unit_utils.dart';

void main() {
  group('UnitConverter wind speed', () {
    test('formatWindSpeed metric', () {
      expect(
        UnitConverter.formatWindSpeed(5.14, UnitSystem.metric),
        '18.5 km/h',
      );
      expect(UnitConverter.formatWindSpeed(0, UnitSystem.metric), '0.0 km/h');
      expect(UnitConverter.formatWindSpeed(10, UnitSystem.metric), '36.0 km/h');
    });

    test('formatWindSpeed imperial', () {
      expect(
        UnitConverter.formatWindSpeed(5.14, UnitSystem.imperial),
        '11.5 mph',
      );
      expect(UnitConverter.formatWindSpeed(0, UnitSystem.imperial), '0.0 mph');
    });
  });
}
