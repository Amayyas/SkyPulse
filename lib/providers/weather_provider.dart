import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/models/city_suggestion.dart';
import 'package:skypulse/services/location_service.dart';
import 'package:skypulse/services/weather_cache.dart';
import 'package:skypulse/services/weather_exception.dart';
import 'package:skypulse/services/weather_service.dart';

/// Holds the SharedPreferences instance loaded once at startup in `main()` and
/// injected via a ProviderScope override. Reading it is synchronous, which lets
/// the selected city be restored during the first build — no async gap, so no
/// flash of the GPS location before the saved city appears, and no restore race.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
});

final weatherServiceProvider = Provider((ref) {
  final service = WeatherService();
  // One shared client for the whole app, closed with the provider — rather than
  // a fresh one leaked per screen that constructs its own service.
  ref.onDispose(service.dispose);
  return service;
});
final locationServiceProvider = Provider((ref) => LocationService());

final currentLocationProvider = FutureProvider<Position>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getCurrentLocation();
});

// Provider for the selected city (stores the full CitySuggestion object).
class SelectedCityNotifier extends Notifier<CitySuggestion?> {
  static const String _prefKey = 'selected_city';

  @override
  CitySuggestion? build() {
    final raw = ref.read(sharedPreferencesProvider).getString(_prefKey);
    if (raw == null) return null;
    try {
      return CitySuggestion.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // A corrupt stored value shouldn't strand the user; fall back to GPS and
      // clear it so it can't keep failing.
      ref.read(sharedPreferencesProvider).remove(_prefKey);
      return null;
    }
  }

  void setCity(CitySuggestion? city) {
    state = city;
    final prefs = ref.read(sharedPreferencesProvider);
    if (city == null) {
      prefs.remove(_prefKey);
    } else {
      prefs.setString(_prefKey, jsonEncode(city.toJson()));
    }
  }

  void clearCity() => setCity(null);
}

final selectedCityProvider =
    NotifierProvider<SelectedCityNotifier, CitySuggestion?>(
      SelectedCityNotifier.new,
    );

final weatherCacheProvider = Provider<WeatherCache>((ref) {
  return WeatherCache(ref.watch(sharedPreferencesProvider));
});

/// The coordinates to show weather for: the selected city, or the GPS position.
///
/// Kept separate so both weather providers resolve the location the same way,
/// and so the cache is keyed on it.
Future<({double lat, double lon, String? cityName})> _targetLocation(
  Ref ref,
) async {
  final selectedCity = ref.watch(selectedCityProvider);
  if (selectedCity != null) {
    return (
      lat: selectedCity.lat,
      lon: selectedCity.lon,
      cityName: selectedCity.name,
    );
  }
  final position = await ref.watch(currentLocationProvider.future);
  return (lat: position.latitude, lon: position.longitude, cityName: null);
}

// Provider for the current weather.
//
// Network first; on failure, fall back to the last successful response for this
// location so the app still shows something offline. The result carries whether
// it came from cache, so the UI can say so instead of passing old weather off
// as current.
final currentWeatherProvider = FutureProvider<Cached<Weather>>((ref) async {
  final weatherService = ref.watch(weatherServiceProvider);
  final cache = ref.watch(weatherCacheProvider);
  final target = await _targetLocation(ref);

  try {
    var weather = await weatherService.getCurrentWeather(
      target.lat,
      target.lon,
    );
    // Force the city name to the one we searched for, not the weather API's
    // (two cities can share the same coordinates).
    if (target.cityName != null) {
      weather = weather.copyWith(cityName: target.cityName);
    }
    await cache.saveCurrent(target.lat, target.lon, weather);
    return Cached.fresh(weather);
  } on WeatherException {
    final cached = cache.readCurrent(target.lat, target.lon);
    if (cached != null) return cached;
    rethrow; // nothing cached: the error is all we have to show
  }
});

final forecastProvider = FutureProvider<Cached<List<Weather>>>((ref) async {
  final weatherService = ref.watch(weatherServiceProvider);
  final cache = ref.watch(weatherCacheProvider);
  final target = await _targetLocation(ref);

  try {
    final forecast = await weatherService.getForecast(target.lat, target.lon);
    await cache.saveForecast(target.lat, target.lon, forecast);
    return Cached.fresh(forecast);
  } on WeatherException {
    final cached = cache.readForecast(target.lat, target.lon);
    if (cached != null) return cached;
    rethrow;
  }
});
