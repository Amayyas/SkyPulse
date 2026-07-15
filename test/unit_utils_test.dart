import 'package:flutter_test/flutter_test.dart';
import 'package:skypulse/utils/unit_utils.dart';

void main() {
  group('Wind speed conversion', () {
    test('converts m/s to km/h correctly', () {
      expect(mpsToKmh(5.14), closeTo(18.504, 0.001));
      expect(mpsToKmh(0), 0);
      expect(mpsToKmh(10), 36);
    });

    test('formats wind speed correctly', () {
      expect(formatWindSpeed(5.14), '18.5 km/h');
      expect(formatWindSpeed(0), '0.0 km/h');
      expect(formatWindSpeed(10), '36.0 km/h');
    });
  });
}
