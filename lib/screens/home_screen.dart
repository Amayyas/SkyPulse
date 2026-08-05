import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skypulse/l10n/app_localizations.dart';
import 'package:skypulse/providers/weather_provider.dart';
import 'package:skypulse/services/weather_cache.dart';
import 'package:skypulse/screens/search_screen.dart';
import 'package:skypulse/screens/settings_screen.dart';
import 'package:skypulse/widgets/current_weather.dart';
import 'package:skypulse/widgets/daily_forecast.dart';
import 'package:skypulse/widgets/error_view.dart';
import 'package:skypulse/widgets/hourly_forecast.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final weatherAsync = ref.watch(currentWeatherProvider);
    final forecastAsync = ref.watch(forecastProvider);

    return Scaffold(
      appBar: AppBar(
        title: weatherAsync.when(
          data: (weather) => Text(weather.data.cityName),
          loading: () => Text(l10n.loading),
          error: (_, _) => Text(l10n.genericError),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentWeatherProvider);
          ref.invalidate(forecastProvider);
        },
        child: weatherAsync.when(
          data: (weather) => forecastAsync.when(
            data: (forecast) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Shown when *either* result came from cache — the two can
                  // fall back independently, and stale forecasts must be
                  // flagged just as much as stale current conditions. The
                  // oldest timestamp is used, so the banner never claims the
                  // data is fresher than its stalest part.
                  if (stalestAmong([weather, forecast]) case final cachedAt?)
                    _OfflineBanner(cachedAt: cachedAt),
                  CurrentWeather(weather: weather.data),
                  HourlyForecast(forecast: forecast.data),
                  DailyForecast(forecast: forecast.data),
                ],
              ),
            ),
            loading: () => _buildShimmerEffect(),
            error: (error, stack) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(forecastProvider),
            ),
          ),
          loading: () => _buildShimmerEffect(),
          error: (error, stack) => ErrorView(
            error: error,
            onRetry: () {
              ref.invalidate(currentWeatherProvider);
              ref.invalidate(forecastProvider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return SingleChildScrollView(
      // Match the data and error views: pull-to-refresh must work while loading.
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tells the user the weather on screen came from the offline cache, and when
/// it was last fetched — rather than letting stale data look current.
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.cachedAt});

  final DateTime cachedAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 18, color: scheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.offlineCached(
                DateFormat.yMd(locale).add_Hm().format(cachedAt),
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
