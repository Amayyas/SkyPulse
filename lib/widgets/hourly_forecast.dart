import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/widgets/weather_icon.dart';

class HourlyForecast extends StatelessWidget {
  final List<Weather> forecast;

  const HourlyForecast({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    // Afficher les prochaines 24 heures
    final next24Hours = forecast.take(24).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Prévisions horaires',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: next24Hours.length,
            itemBuilder: (context, index) {
              final weather = next24Hours[index];
              return Card(
                    margin: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('HH\'h\'', 'fr_FR').format(weather.date),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          WeatherIcon(iconCode: weather.iconCode, size: 40),
                          const SizedBox(height: 4),
                          Text(
                            '${weather.temperature.round()}°',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: (100 * index).ms)
                  .slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }
}
