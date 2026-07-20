import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/models/city_suggestion.dart';
import 'package:skypulse/services/location_service.dart';
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

// Provider pour la ville sélectionnée (stocke l'objet CitySuggestion complet)
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

// Provider pour obtenir la météo actuelle
final currentWeatherProvider = FutureProvider<Weather>((ref) async {
  final weatherService = ref.watch(weatherServiceProvider);
  final selectedCity = ref.watch(selectedCityProvider);

  if (selectedCity != null) {
    // Si une ville est sélectionnée, utiliser ses coordonnées
    final weather = await weatherService.getCurrentWeather(
      selectedCity.lat,
      selectedCity.lon,
    );
    // FORCER le nom de la ville avec celui qu'on a cherché, pas celui de l'API
    // météo (deux villes peuvent partager des coordonnées).
    return weather.copyWith(cityName: selectedCity.name);
  }

  // Par défaut, utiliser la position GPS
  final position = await ref.watch(currentLocationProvider.future);
  return await weatherService.getCurrentWeather(
    position.latitude,
    position.longitude,
  );
});

final forecastProvider = FutureProvider<List<Weather>>((ref) async {
  final weatherService = ref.watch(weatherServiceProvider);
  final selectedCity = ref.watch(selectedCityProvider);

  if (selectedCity != null) {
    // Si une ville est sélectionnée, utiliser ses coordonnées
    return await weatherService.getForecast(selectedCity.lat, selectedCity.lon);
  }

  // Par défaut, utiliser la position GPS
  final position = await ref.watch(currentLocationProvider.future);
  return await weatherService.getForecast(
    position.latitude,
    position.longitude,
  );
});
