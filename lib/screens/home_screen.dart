import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skypulse/l10n/app_localizations.dart';
import 'package:skypulse/providers/weather_provider.dart';
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
          data: (weather) => Text(weather.cityName),
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
                  CurrentWeather(weather: weather),
                  HourlyForecast(forecast: forecast),
                  DailyForecast(forecast: forecast),
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
