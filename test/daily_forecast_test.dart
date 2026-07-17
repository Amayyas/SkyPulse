import 'package:flutter_test/flutter_test.dart';
import 'package:skypulse/models/weather_model.dart';
import 'package:skypulse/widgets/daily_forecast.dart';

Weather _entry(DateTime date, double temp) => Weather(
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
  // #5: the app advertised "7 days" but the free API spans 5, and the first
  // bucket (today) is partial so its min/max is wrong. summarizeByDay skips
  // today and caps at 5, and the widget titles itself with the real count.
  group('DailyForecast.summarizeByDay', () {
    final now = DateTime(2026, 7, 17, 15); // 15:00 today

    test('never returns more than 5 days, even given 7 days of data', () {
      final forecast = [
        for (var day = 0; day < 7; day++)
          for (final hour in [0, 6, 12, 18])
            _entry(DateTime(2026, 7, 17 + day, hour), 20),
      ];

      final result = DailyForecast.summarizeByDay(forecast, now: now);

      expect(result.length, 5);
    });

    test('skips today — the first summarized day is tomorrow', () {
      final forecast = [
        _entry(DateTime(2026, 7, 17, 18), 25), // today
        _entry(DateTime(2026, 7, 18, 12), 22), // tomorrow
        _entry(DateTime(2026, 7, 19, 12), 21),
      ];

      final result = DailyForecast.summarizeByDay(forecast, now: now);

      expect(result.length, 2);
      expect(result.first.date.day, 18);
    });

    test('min and max come from the full day, not the midday entry', () {
      final forecast = [
        _entry(DateTime(2026, 7, 18, 6), 12), // coldest
        _entry(DateTime(2026, 7, 18, 13), 24), // midday (icon source)
        _entry(DateTime(2026, 7, 18, 16), 27), // hottest
      ];

      final result = DailyForecast.summarizeByDay(forecast, now: now);

      expect(result.single.tempMin, 12);
      expect(result.single.tempMax, 27);
    });

    test('past-day entries are excluded, not just today', () {
      final forecast = [
        _entry(DateTime(2026, 7, 15, 12), 10), // two days ago
        _entry(DateTime(2026, 7, 17, 12), 25), // today
        _entry(DateTime(2026, 7, 18, 12), 22), // tomorrow
      ];

      final result = DailyForecast.summarizeByDay(forecast, now: now);

      expect(result.length, 1);
      expect(result.single.date.day, 18);
    });

    test('a forecast that only covers today yields nothing', () {
      final forecast = [
        _entry(DateTime(2026, 7, 17, 16), 25),
        _entry(DateTime(2026, 7, 17, 19), 23),
      ];

      expect(DailyForecast.summarizeByDay(forecast, now: now), isEmpty);
    });

    test('days come out in chronological order', () {
      final forecast = [
        _entry(DateTime(2026, 7, 20, 12), 20),
        _entry(DateTime(2026, 7, 18, 12), 20),
        _entry(DateTime(2026, 7, 19, 12), 20),
      ];

      final days = DailyForecast.summarizeByDay(
        forecast,
        now: now,
      ).map((w) => w.date.day).toList();

      expect(days, [18, 19, 20]);
    });
  });
}
