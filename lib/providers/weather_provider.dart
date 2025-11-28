import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/models/city_suggestion.dart';
import 'package:skypulse/services/location_service.dart';
import 'package:skypulse/services/weather_service.dart';

final weatherServiceProvider = Provider((ref) => WeatherService());
final locationServiceProvider = Provider((ref) => LocationService());

final currentLocationProvider = FutureProvider<Position>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getCurrentLocation();
});

// Provider pour la ville sélectionnée (stocke l'objet CitySuggestion complet)
class SelectedCityNotifier extends Notifier<CitySuggestion?> {
  @override
  CitySuggestion? build() {
    return null;
  }

  void setCity(CitySuggestion? city) {
    state = city;
  }

  void clearCity() {
    state = null;
  }
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
    // FORCER le nom de la ville avec celui qu'on a cherché, pas celui de l'API météo
    return Weather(
      cityName: selectedCity.name,
      temperature: weather.temperature,
      feelsLike: weather.feelsLike,
      tempMin: weather.tempMin,
      tempMax: weather.tempMax,
      description: weather.description,
      iconCode: weather.iconCode,
      humidity: weather.humidity,
      windSpeed: weather.windSpeed,
      date: weather.date,
      sunrise: weather.sunrise,
      sunset: weather.sunset,
      lat: weather.lat,
      lon: weather.lon,
    );
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
