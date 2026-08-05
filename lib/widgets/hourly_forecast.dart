import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:skypulse/l10n/app_localizations.dart';
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/providers/unit_provider.dart';
import 'package:skypulse/utils/unit_utils.dart';
import 'package:skypulse/widgets/weather_icon.dart';

class HourlyForecast extends ConsumerWidget {
  final List<Weather> forecast;

  const HourlyForecast({super.key, required this.forecast});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(unitProvider);
    final locale = Localizations.localeOf(context).languageCode;
    // The API issues one reading every 3 hours, so 8 of them cover a day.
    // Each card is a real forecast — nothing here is interpolated.
    final next24Hours = forecast.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            AppLocalizations.of(context).hourlyForecast,
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
                            DateFormat.j(locale).format(weather.date),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          WeatherIcon(iconCode: weather.iconCode, size: 40),
                          const SizedBox(height: 4),
                          Text(
                            UnitConverter.formatTempRounded(
                              weather.temperature,
                              unit,
                            ),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          _PrecipitationChance(pop: weather.pop),
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

/// Shows the chance of rain under an hour, as a droplet + percentage.
///
/// The space is always reserved, even at 0%, so the cards keep a uniform
/// height instead of shifting as dry and wet hours scroll past. A dry hour is
/// simply left blank rather than labelled "0%", which would be noise.
class _PrecipitationChance extends StatelessWidget {
  const _PrecipitationChance({required this.pop});

  final double pop;

  @override
  Widget build(BuildContext context) {
    final percent = (pop.clamp(0, 1) * 100).round();
    final color = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 16,
      child: percent == 0
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.water_drop, size: 12, color: color),
                const SizedBox(width: 2),
                Text(
                  '$percent%',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
    );
  }
}
