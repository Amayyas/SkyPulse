import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skypulse/providers/theme_provider.dart';
import 'package:skypulse/utils/theme.dart';

void main() {
  group('AppTheme.bucketForHour', () {
    // Every boundary, so a shift by one hour can't slip through untested.
    const cases = {
      0: TimeOfDayTheme.night,
      4: TimeOfDayTheme.night,
      5: TimeOfDayTheme.dawn,
      6: TimeOfDayTheme.dawn,
      7: TimeOfDayTheme.morning,
      11: TimeOfDayTheme.morning,
      12: TimeOfDayTheme.afternoon,
      16: TimeOfDayTheme.afternoon,
      17: TimeOfDayTheme.evening,
      18: TimeOfDayTheme.evening,
      19: TimeOfDayTheme.dusk,
      21: TimeOfDayTheme.dusk,
      22: TimeOfDayTheme.night,
      23: TimeOfDayTheme.night,
    };

    cases.forEach((hour, expected) {
      test('${hour}h -> ${expected.name}', () {
        expect(AppTheme.bucketForHour(hour), expected);
      });
    });
  });

  group('timeOfDayThemeProvider', () {
    test('builds with the mood for the injected clock', () {
      var now = DateTime(2026, 7, 18, 14); // afternoon
      final container = ProviderContainer(
        overrides: [clockProvider.overrideWithValue(() => now)],
      );
      addTearDown(container.dispose);

      expect(container.read(timeOfDayThemeProvider), TimeOfDayTheme.afternoon);
    });

    test('refresh() picks up a change in the hour', () {
      var now = DateTime(2026, 7, 18, 18); // evening
      final container = ProviderContainer(
        overrides: [clockProvider.overrideWithValue(() => now)],
      );
      addTearDown(container.dispose);

      expect(container.read(timeOfDayThemeProvider), TimeOfDayTheme.evening);

      now = DateTime(2026, 7, 18, 20); // dusk
      container.read(timeOfDayThemeProvider.notifier).refresh();

      expect(container.read(timeOfDayThemeProvider), TimeOfDayTheme.dusk);
    });
  });
}
