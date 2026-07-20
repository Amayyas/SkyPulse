import 'package:flutter_test/flutter_test.dart';
import 'package:skypulse/l10n/app_localizations_en.dart';
import 'package:skypulse/l10n/app_localizations_fr.dart';

void main() {
  // Both regressions CodeRabbit caught on the i18n PR.
  test('French daily-forecast title pluralises "jour" correctly', () {
    final fr = AppLocalizationsFr();
    expect(fr.dailyForecast(1), 'Prévisions sur 1 jour');
    expect(fr.dailyForecast(5), 'Prévisions sur 5 jours');
  });

  test('compass abbreviations are localised (W is O in French)', () {
    expect(AppLocalizationsEn().compassW, 'W');
    expect(AppLocalizationsEn().compassSW, 'SW');
    expect(AppLocalizationsFr().compassW, 'O');
    expect(AppLocalizationsFr().compassSW, 'SO');
  });
}
