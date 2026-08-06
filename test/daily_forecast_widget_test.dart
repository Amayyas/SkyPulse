import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:skypulse/l10n/app_localizations.dart';
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/widgets/daily_forecast.dart';

Weather _at(DateTime date, {double temp = 20}) => Weather(
  cityName: 'Test',
  temperature: temp,
  feelsLike: temp,
  tempMin: temp,
  tempMax: temp,
  description: 'clear sky',
  iconCode: '01d',
  humidity: 50,
  windSpeed: 3,
  date: date,
  sunrise: 0,
  sunset: 0,
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr');
    await initializeDateFormatting('en');
  });

  Future<void> pump(WidgetTester tester, List<Weather> forecast) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(body: DailyForecast(forecast: forecast)),
        ),
      ),
    );
    // Drain the flutter_animate entrance timers.
    await tester.pumpAndSettle();
  }

  // summarizeByDay is covered in daily_forecast_test.dart; this covers what the
  // widget actually renders from it.
  group('DailyForecast rendering', () {
    testWidgets('renders nothing when there is no day to summarise', (
      tester,
    ) async {
      // Only today — which is deliberately excluded from the daily summary.
      await pump(tester, [_at(DateTime.now())]);

      expect(find.byType(Card), findsNothing);
    });

    testWidgets('renders one card per upcoming day', (tester) async {
      final now = DateTime.now();
      await pump(tester, [
        _at(now.add(const Duration(days: 1))),
        _at(now.add(const Duration(days: 2))),
        _at(now.add(const Duration(days: 3))),
      ]);

      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('the heading states the real number of days', (tester) async {
      final now = DateTime.now();
      await pump(tester, [
        _at(now.add(const Duration(days: 1))),
        _at(now.add(const Duration(days: 2))),
      ]);

      // Never a fixed number the data can't back up — see #5.
      expect(find.text('Prévisions sur 2 jours'), findsOneWidget);
    });

    testWidgets('shows the day high and low', (tester) async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await pump(tester, [
        _at(DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 6), temp: 11),
        _at(
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 15),
          temp: 24,
        ),
      ]);

      expect(find.text('24° / 11°'), findsOneWidget);
    });
  });
}
