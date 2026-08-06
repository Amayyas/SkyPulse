import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:skypulse/l10n/app_localizations.dart';
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/widgets/daily_forecast.dart';
import 'package:skypulse/widgets/hourly_forecast.dart';

Weather _weather(DateTime date, {double temp = 18, double pop = 0}) => Weather(
  cityName: 'Test',
  temperature: temp,
  feelsLike: temp,
  tempMin: temp - 5,
  tempMax: temp + 5,
  description: 'light rain',
  iconCode: '10d',
  humidity: 60,
  windSpeed: 3,
  date: date,
  sunrise: 0,
  sunset: 0,
  pop: pop,
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr');
    await initializeDateFormatting('en');
  });

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    double textScale = 1.0,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: Scaffold(body: child),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // #27: the weather icon carried the condition and was invisible to screen
  // readers, so a blind user got the temperature and nothing else.
  group('screen reader labels', () {
    testWidgets('an hourly card reads as one sentence, condition included', (
      tester,
    ) async {
      await pump(
        tester,
        HourlyForecast(
          forecast: [_weather(DateTime(2026, 8, 5, 14), pop: 0.6)],
        ),
      );

      final semantics = tester.getSemantics(find.byType(Card).first);

      expect(semantics.label, contains('pluie légère'));
      expect(semantics.label, contains('18°'));
      expect(semantics.label, contains('60%'));
    });

    testWidgets('a daily row announces day, high, low and condition', (
      tester,
    ) async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await pump(
        tester,
        DailyForecast(
          forecast: [
            _weather(
              DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 13),
              temp: 20,
            ),
          ],
        ),
      );

      final semantics = tester.getSemantics(find.byType(Card).first);

      expect(semantics.label, contains('maximum'));
      expect(semantics.label, contains('minimum'));
      expect(semantics.label, contains('pluie légère'));
    });
  });

  // A fixed-height strip clipped its contents once the user scaled text up.
  group('large text', () {
    testWidgets('the hourly strip does not overflow at 200% text', (
      tester,
    ) async {
      await pump(
        tester,
        HourlyForecast(forecast: [_weather(DateTime(2026, 8, 5, 14))]),
        textScale: 2.0,
      );

      // A RenderFlex overflow reports itself as a test failure; reaching here
      // with the card rendered means the layout absorbed the larger text.
      expect(tester.takeException(), isNull);
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
