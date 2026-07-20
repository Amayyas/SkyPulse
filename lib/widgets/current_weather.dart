import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:skypulse/l10n/app_localizations.dart';
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/providers/unit_provider.dart';
import 'package:skypulse/utils/constants.dart';
import 'package:skypulse/utils/unit_utils.dart';
import 'package:skypulse/widgets/weather_icon.dart';

class CurrentWeather extends ConsumerWidget {
  final Weather weather;

  const CurrentWeather({super.key, required this.weather});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(unitProvider);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

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
          DateFormat('EEEE d MMMM', locale).format(weather.date),
          style: Theme.of(context).textTheme.bodyLarge,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 20),
        WeatherIcon(
          iconCode: weather.iconCode,
          size: 100,
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        Text(
          UnitConverter.formatTempRounded(weather.temperature, unit),
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        Text(
          _describeWeather(weather.description, locale).toUpperCase(),
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
              l10n.humidity,
            ),
            _buildDetailItem(
              context,
              Icons.air,
              UnitConverter.formatWindSpeed(weather.windSpeed, unit),
              weather.windDeg != null
                  ? l10n.windWithDirection(_compass(l10n, weather.windDeg!))
                  : l10n.wind,
            ),
            _buildDetailItem(
              context,
              Icons.thermostat,
              UnitConverter.formatTempRounded(weather.feelsLike, unit),
              l10n.feelsLike,
            ),
          ],
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
        if (_secondaryDetails(context, unit).isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _secondaryDetails(context, unit),
          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
        ],
      ],
    );
  }

  /// Localised 8-point compass abbreviation for a wind direction in degrees.
  String _compass(AppLocalizations l10n, int degrees) {
    final labels = [
      l10n.compassN,
      l10n.compassNE,
      l10n.compassE,
      l10n.compassSE,
      l10n.compassS,
      l10n.compassSW,
      l10n.compassW,
      l10n.compassNW,
    ];
    return labels[UnitConverter.windDirectionIndex(degrees)];
  }

  /// The weather condition text. The API returns English; in French we run it
  /// through the translation dictionary, in English we show it as-is. (Keying
  /// the dictionary on the OpenWeatherMap condition id is a separate follow-up.)
  String _describeWeather(String description, String locale) {
    if (locale == 'fr') {
      return AppConstants.translateWeatherDescription(description);
    }
    return description;
  }

  /// Pressure and visibility, shown only when the response carried them, so the
  /// row simply doesn't appear rather than showing blanks.
  List<Widget> _secondaryDetails(BuildContext context, UnitSystem unit) {
    final l10n = AppLocalizations.of(context);
    return [
      if (weather.pressure != null)
        _buildDetailItem(
          context,
          Icons.compress,
          UnitConverter.formatPressure(weather.pressure!, unit),
          l10n.pressure,
        ),
      if (weather.visibility != null)
        _buildDetailItem(
          context,
          Icons.visibility,
          UnitConverter.formatVisibility(weather.visibility!, unit),
          l10n.visibility,
        ),
    ];
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
