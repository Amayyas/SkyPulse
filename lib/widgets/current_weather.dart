import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/widgets/weather_icon.dart';
import 'package:skypulse/utils/constants.dart';

class CurrentWeather extends StatelessWidget {
  final Weather weather;

  const CurrentWeather({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          weather.cityName,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn().slideY(begin: -0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          DateFormat('EEEE d MMMM', 'fr_FR').format(weather.date),
          style: Theme.of(context).textTheme.bodyLarge,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 20),
        WeatherIcon(
          iconCode: weather.iconCode,
          size: 100,
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        Text(
          '${weather.temperature.round()}°',
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        Text(
          AppConstants.translateWeatherDescription(
            weather.description,
          ).toUpperCase(),
          style: Theme.of(context).textTheme.titleMedium,
        ).animate().fadeIn(delay: 500.ms),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildDetailItem(
              context,
              Icons.water_drop,
              '${weather.humidity}%',
              'Humidité',
            ),
            _buildDetailItem(
              context,
              Icons.air,
              '${weather.windSpeed} m/s',
              'Vent',
            ),
            _buildDetailItem(
              context,
              Icons.thermostat,
              '${weather.feelsLike.round()}°',
              'Ressenti',
            ),
          ],
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
