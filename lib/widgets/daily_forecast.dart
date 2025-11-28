import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/widgets/weather_icon.dart';

class DailyForecast extends StatelessWidget {
  final List<Weather> forecast;

  const DailyForecast({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    // Regrouper les prévisions par jour unique
    final Map<String, List<Weather>> forecastByDay = {};

    for (var weather in forecast) {
      final dayKey = DateFormat('yyyy-MM-dd').format(weather.date);
      if (!forecastByDay.containsKey(dayKey)) {
        forecastByDay[dayKey] = [];
      }
      forecastByDay[dayKey]!.add(weather);
    }

    // Créer une prévision par jour avec min/max des températures
    final dailyForecast = <Weather>[];

    forecastByDay.forEach((day, weatherList) {
      if (weatherList.isNotEmpty) {
        // Calculer les températures min et max du jour
        final temps = weatherList.map((w) => w.temperature).toList();
        final tempMin = temps.reduce((a, b) => a < b ? a : b);
        final tempMax = temps.reduce((a, b) => a > b ? a : b);

        // Prendre la prévision du milieu de journée (vers 12h-14h) pour l'icône
        final middayWeather = weatherList.firstWhere(
          (w) => w.date.hour >= 12 && w.date.hour <= 14,
          orElse: () => weatherList.first,
        );

        dailyForecast.add(
          Weather(
            cityName: middayWeather.cityName,
            temperature: middayWeather.temperature,
            feelsLike: middayWeather.feelsLike,
            tempMin: tempMin,
            tempMax: tempMax,
            description: middayWeather.description,
            iconCode: middayWeather.iconCode,
            humidity: middayWeather.humidity,
            windSpeed: middayWeather.windSpeed,
            date: middayWeather.date,
            sunrise: middayWeather.sunrise,
            sunset: middayWeather.sunset,
          ),
        );
      }
    });

    // Limiter à 7 jours
    final limitedForecast = dailyForecast.take(7).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Prévisions sur 7 jours',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(limitedForecast.length, (index) {
          final weather = limitedForecast[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        DateFormat('EEEE', 'fr_FR').format(weather.date),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: WeatherIcon(
                          iconCode: weather.iconCode,
                          size: 40,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${weather.tempMax.round()}° / ${weather.tempMin.round()}°',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2, end: 0);
        }),
        const SizedBox(height: 20),
      ],
    );
  }
}
