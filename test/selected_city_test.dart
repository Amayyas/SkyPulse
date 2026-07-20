import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypulse/models/city_suggestion.dart';
import 'package:skypulse/providers/weather_provider.dart';

CitySuggestion _paris() => CitySuggestion(
  name: 'Paris',
  country: 'FR',
  state: 'Île-de-France',
  lat: 48.8566,
  lon: 2.3522,
);

/// Builds a container whose sharedPreferencesProvider is backed by a mocked
/// prefs store seeded with [initial], the way main() injects the real one.
Future<ProviderContainer> containerWith(Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('selectedCityProvider persistence (#18)', () {
    test('starts on GPS (null) when nothing is stored', () async {
      final container = await containerWith({});
      expect(container.read(selectedCityProvider), isNull);
    });

    test('restores a stored city synchronously on first read', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'selected_city',
        // Same shape toJson writes.
        '{"name":"Paris","country":"FR","state":"Île-de-France",'
            '"lat":48.8566,"lon":2.3522}',
      );
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final city = container.read(selectedCityProvider);
      expect(city, isNotNull);
      expect(city!.name, 'Paris');
      expect(city.lat, 48.8566);
    });

    test('setCity persists, visible to a fresh container', () async {
      final container = await containerWith({});
      container.read(selectedCityProvider.notifier).setCity(_paris());
      expect(container.read(selectedCityProvider)!.name, 'Paris');

      // A new container reading the same prefs sees the saved city.
      final prefs = await SharedPreferences.getInstance();
      final reopened = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(reopened.dispose);
      expect(reopened.read(selectedCityProvider)!.name, 'Paris');
    });

    test('clearCity reverts to GPS and does not survive a restart', () async {
      final container = await containerWith({});
      final notifier = container.read(selectedCityProvider.notifier);
      notifier.setCity(_paris());
      notifier.clearCity();
      expect(container.read(selectedCityProvider), isNull);

      final prefs = await SharedPreferences.getInstance();
      final reopened = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(reopened.dispose);
      expect(reopened.read(selectedCityProvider), isNull);
    });

    test('a corrupt stored value falls back to GPS and is cleared', () async {
      final container = await containerWith({'selected_city': 'not json'});

      expect(container.read(selectedCityProvider), isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_city'), isNull);
    });
  });
}
