import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypulse/models/city_suggestion.dart';
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/providers/weather_provider.dart';
import 'package:skypulse/services/weather_cache.dart';
import 'package:skypulse/services/weather_service.dart';

import 'weather_service_test.mocks.dart';

const _body = '''
{
  "coord": {"lon": 2.3522, "lat": 48.8566},
  "weather": [{"description": "clear sky", "icon": "01d"}],
  "main": {"temp": 20.5, "feels_like": 19.5, "temp_min": 18.0,
           "temp_max": 22.0, "humidity": 60, "pressure": 1013},
  "wind": {"speed": 3.5, "deg": 240},
  "visibility": 10000,
  "dt": 1638360000,
  "sys": {"sunrise": 1638340000, "sunset": 1638380000},
  "name": "Paris"
}
''';

Weather _sample() => Weather.fromJson({
  'main': {
    'temp': 12.5,
    'feels_like': 11.0,
    'temp_min': 10.0,
    'temp_max': 15.0,
    'humidity': 70,
    'pressure': 1008,
  },
  'weather': [
    {'description': 'light rain', 'icon': '10d'},
  ],
  'wind': {'speed': 4.2, 'deg': 180},
  'visibility': 8000,
  'dt': 1638360000,
  // Populated so the round-trip test actually exercises these — null-to-null
  // would pass whether or not they were serialised.
  'coord': {'lat': 45.7640, 'lon': 4.8357},
  'sys': {'sunrise': 1638340000, 'sunset': 1638380000},
  'name': 'Lyon',
});

void main() {
  Future<SharedPreferences> prefsWith(Map<String, Object> initial) async {
    SharedPreferences.setMockInitialValues(initial);
    return SharedPreferences.getInstance();
  }

  group('Weather cache serialisation', () {
    test('round-trips every field', () {
      final original = _sample();
      final restored = Weather.fromCacheJson(original.toCacheJson());

      expect(restored.cityName, original.cityName);
      expect(restored.temperature, original.temperature);
      expect(restored.feelsLike, original.feelsLike);
      expect(restored.tempMin, original.tempMin);
      expect(restored.tempMax, original.tempMax);
      expect(restored.description, original.description);
      expect(restored.iconCode, original.iconCode);
      expect(restored.humidity, original.humidity);
      expect(restored.windSpeed, original.windSpeed);
      expect(restored.date, original.date);
      expect(restored.sunrise, original.sunrise);
      expect(restored.sunset, original.sunset);
      expect(restored.lat, original.lat);
      expect(restored.lon, original.lon);
      expect(restored.pop, original.pop);
      expect(restored.pressure, original.pressure);
      expect(restored.windDeg, original.windDeg);
      expect(restored.visibility, original.visibility);
    });
  });

  group('WeatherCache', () {
    test('reads back what it saved, marked stale with a timestamp', () async {
      final cache = WeatherCache(await prefsWith({}));
      await cache.saveCurrent(48.8566, 2.3522, _sample());

      final cached = cache.readCurrent(48.8566, 2.3522);

      expect(cached, isNotNull);
      expect(cached!.data.cityName, 'Lyon');
      expect(cached.isStale, isTrue, reason: 'cache reads are never "fresh"');
      expect(cached.cachedAt, isNotNull);
    });

    test('a forecast list round-trips', () async {
      final cache = WeatherCache(await prefsWith({}));
      await cache.saveForecast(48.8566, 2.3522, [_sample(), _sample()]);

      expect(cache.readForecast(48.8566, 2.3522)!.data, hasLength(2));
    });

    test('returns null for a location never cached', () async {
      final cache = WeatherCache(await prefsWith({}));
      expect(cache.readCurrent(1.0, 2.0), isNull);
    });

    // Nearby GPS readings shouldn't each get their own entry.
    test('nearby coordinates hit the same entry', () async {
      final cache = WeatherCache(await prefsWith({}));
      await cache.saveCurrent(48.8566, 2.3522, _sample());

      expect(cache.readCurrent(48.8571, 2.3519), isNotNull);
    });

    test('a corrupt entry yields null and is dropped', () async {
      final prefs = await prefsWith({});
      final cache = WeatherCache(prefs);
      await cache.saveCurrent(48.8566, 2.3522, _sample());
      // Simulate a truncated or older-format entry.
      final key = prefs.getKeys().firstWhere((k) => k.startsWith('weather_'));
      await prefs.setString(key, 'not json');

      expect(cache.readCurrent(48.8566, 2.3522), isNull);
      expect(prefs.getString(key), isNull, reason: 'bad entry is cleared');
    });
  });

  // The point of #20: with no network, the app shows the last known weather
  // instead of nothing — and flags it rather than passing it off as current.
  group('offline fallback', () {
    late MockClient client;

    ProviderContainer containerWith(SharedPreferences prefs) {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          weatherServiceProvider.overrideWith(
            (ref) => WeatherService(client: client, apiKey: 'test-key'),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    /// Prefs with a city already stored, so SelectedCityNotifier restores it
    /// synchronously at build (#18) and the providers never reach for GPS.
    /// Setting it afterwards would invalidate a provider mid-flight.
    Future<SharedPreferences> prefsWithCity() => prefsWith({
      'selected_city': jsonEncode(
        CitySuggestion(
          name: 'Paris',
          country: 'FR',
          state: '',
          lat: 48.8566,
          lon: 2.3522,
        ).toJson(),
      ),
    });

    setUp(() => client = MockClient());

    test('a successful fetch is served fresh and cached', () async {
      when(client.get(any)).thenAnswer((_) async => http.Response(_body, 200));
      final prefs = await prefsWithCity();

      final result = await containerWith(
        prefs,
      ).read(currentWeatherProvider.future);

      expect(result.isStale, isFalse);
      expect(result.data.cityName, 'Paris');
      expect(
        WeatherCache(prefs).readCurrent(48.8566, 2.3522),
        isNotNull,
        reason: 'the successful response should have been cached',
      );
    });

    test('a network failure falls back to the cache, marked stale', () async {
      final prefs = await prefsWithCity();
      await WeatherCache(prefs).saveCurrent(48.8566, 2.3522, _sample());
      when(client.get(any)).thenThrow(http.ClientException('offline'));

      final result = await containerWith(
        prefs,
      ).read(currentWeatherProvider.future);

      expect(result.isStale, isTrue);
      expect(result.data.cityName, 'Lyon', reason: 'came from the cache');
      expect(result.cachedAt, isNotNull);
    });

    // Not tested through the provider: with no cache and no listener, Riverpod
    // disposes the provider mid-flight in a test container, so the assertion
    // would be about that artefact rather than the app. The two halves of this
    // path are covered directly instead — the cache returns null when empty
    // ("returns null for a location never cached", above), and the service
    // throws on a network failure (weather_service_test.dart).
  });

  // Regression: the banner used to key off the current weather only, so a
  // network-fresh current + cached forecast rendered stale data with no
  // indicator at all.
  group('stalestAmong', () {
    final older = DateTime(2026, 7, 20, 9, 0);
    final newer = DateTime(2026, 7, 21, 18, 30);

    test('null when everything is fresh', () {
      expect(
        stalestAmong([const Cached.fresh(1), const Cached.fresh(2)]),
        isNull,
      );
    });

    test('flags staleness even if only one entry is cached', () {
      expect(
        stalestAmong([const Cached.fresh(1), Cached.stale(2, older)]),
        older,
        reason: 'a stale forecast must be flagged, not just stale current data',
      );
    });

    test('reports the oldest timestamp, never the freshest', () {
      expect(
        stalestAmong([Cached.stale(1, newer), Cached.stale(2, older)]),
        older,
      );
    });
  });
}
