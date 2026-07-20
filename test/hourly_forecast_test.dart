import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/widgets/hourly_forecast.dart';

Weather _hour(DateTime date, double pop) => Weather(
  cityName: 'Test',
  temperature: 20,
  feelsLike: 20,
  tempMin: 18,
  tempMax: 22,
  description: 'rain',
  iconCode: '10d',
  humidity: 60,
  windSpeed: 3,
  date: date,
  sunrise: 0,
  sunset: 0,
  pop: pop,
);

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR', null));

  Future<void> pump(WidgetTester tester, List<Weather> forecast) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: HourlyForecast(forecast: forecast)),
        ),
      ),
    );
    // Let the flutter_animate entrance timers (fadeIn delay) drain.
    await tester.pumpAndSettle();
  }

  // #16: precipitation probability is now shown per hour. A wet hour shows the
  // percentage; a dry hour is left blank rather than labelled "0%". (A failing
  // layout here would also surface as an overflow during pump.)
  testWidgets('a wet hour shows its precipitation percentage', (tester) async {
    await pump(tester, [_hour(DateTime(2026, 7, 18, 14), 0.6)]);

    expect(find.text('60%'), findsOneWidget);
  });

  testWidgets('a dry hour shows no percentage, not "0%"', (tester) async {
    await pump(tester, [_hour(DateTime(2026, 7, 18, 14), 0)]);

    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('rounds the probability to a whole percent', (tester) async {
    await pump(tester, [_hour(DateTime(2026, 7, 18, 14), 0.156)]);

    expect(find.text('16%'), findsOneWidget);
  });
}
