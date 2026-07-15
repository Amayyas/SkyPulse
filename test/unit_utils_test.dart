import 'package:flutter_test/flutter_test.dart';
import 'package:skypulse/utils/unit_utils.dart';

void main() {
  group('Wind speed conversion (top-level helpers)', () {
    test('mpsToKmh converts correctly', () {
      expect(mpsToKmh(5.14), closeTo(18.504, 0.001));
      expect(mpsToKmh(0), 0);
      expect(mpsToKmh(10), 36);
    });

    test('UnitConverter.formatWindSpeed metric', () {
      expect(
        UnitConverter.formatWindSpeed(5.14, UnitSystem.metric),
        '18.5 km/h',
      );
      expect(UnitConverter.formatWindSpeed(0, UnitSystem.metric), '0.0 km/h');
      expect(UnitConverter.formatWindSpeed(10, UnitSystem.metric), '36.0 km/h');
    });
  });
}
