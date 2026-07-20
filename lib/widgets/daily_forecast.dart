import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:skypulse/l10n/app_localizations.dart';
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/providers/unit_provider.dart';
import 'package:skypulse/utils/unit_utils.dart';
import 'package:skypulse/widgets/weather_icon.dart';

class DailyForecast extends ConsumerWidget {
  final List<Weather> forecast;

  const DailyForecast({super.key, required this.forecast});

  /// The free OpenWeatherMap /forecast endpoint spans 5 days, so this never
  /// yields more. The count is a hard ceiling, not a promise.
  static const int _maxDays = 5;

  /// Collapses the 3-hourly (interpolated hourly) forecast into one entry per
  /// day, with that day's real min/max.
  ///
  /// Today is skipped: its bucket only holds the hours left in the day, so its
  /// min/max would understate the real range — and the current conditions are
  /// already shown by [CurrentWeather] above. [now] is injectable for tests.
  static List<Weather> summarizeByDay(List<Weather> forecast, {DateTime? now}) {
    final todayKey = DateFormat('yyyy-MM-dd').format(now ?? DateTime.now());

    final byDay = <String, List<Weather>>{};
    for (final weather in forecast) {
      final dayKey = DateFormat('yyyy-MM-dd').format(weather.date);
      // Skip today and anything before it. Today's bucket is partial (wrong
      // min/max), and a stray past-day entry would otherwise occupy one of the
      // five slots. ISO keys compare chronologically.
      if (dayKey.compareTo(todayKey) <= 0) continue;
      byDay.putIfAbsent(dayKey, () => []).add(weather);
    }

    // Day keys are ISO 'yyyy-MM-dd', so lexical order is chronological order.
    // Don't rely on the input being sorted.
    final sortedKeys = byDay.keys.toList()..sort();

    final days = <Weather>[];
    for (final key in sortedKeys) {
      final entries = byDay[key]!;
      final temps = entries.map((w) => w.temperature);
      final midday = entries.firstWhere(
        (w) => w.date.hour >= 12 && w.date.hour <= 14,
        orElse: () => entries.first,
      );
      days.add(
        Weather(
          cityName: midday.cityName,
          temperature: midday.temperature,
          feelsLike: midday.feelsLike,
          tempMin: temps.reduce((a, b) => a < b ? a : b),
          tempMax: temps.reduce((a, b) => a > b ? a : b),
          description: midday.description,
          iconCode: midday.iconCode,
          humidity: midday.humidity,
          windSpeed: midday.windSpeed,
          date: midday.date,
          sunrise: midday.sunrise,
          sunset: midday.sunset,
        ),
      );
    }

    return days.take(_maxDays).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(unitProvider);
    final locale = Localizations.localeOf(context).languageCode;
    final limitedForecast = summarizeByDay(forecast);

    // Nothing to summarize (e.g. a forecast that only covers today).
    if (limitedForecast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            // The real count, never a fixed number the data can't back up.
            AppLocalizations.of(context).dailyForecast(limitedForecast.length),
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
                        DateFormat('EEEE', locale).format(weather.date),
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
                        '${UnitConverter.formatTempRounded(weather.tempMax, unit)} / ${UnitConverter.formatTempRounded(weather.tempMin, unit)}',
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
