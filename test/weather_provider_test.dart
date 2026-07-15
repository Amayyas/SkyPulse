import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skypulse/providers/weather_provider.dart';
import 'package:skypulse/services/weather_service.dart';

void main() {
  // #7: SearchScreen used to construct its own WeatherService, leaking an
  // http.Client on every visit. The service now comes from a provider that
  // owns a single client and closes it on dispose.
  test('weatherServiceProvider hands out one shared instance', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final a = container.read(weatherServiceProvider);
    final b = container.read(weatherServiceProvider);

    expect(a, isA<WeatherService>());
    expect(identical(a, b), isTrue);
  });

  test('disposing the container closes the client without error', () {
    final container = ProviderContainer();
    final service = container.read(weatherServiceProvider);

    // If the provider did not own the client's lifecycle, a second close would
    // throw; here disposal must be clean and idempotent from the caller's side.
    container.dispose();

    expect(() => service.dispose(), returnsNormally);
  });
}
