import 'package:skypulse/utils/constants.dart';

/// The weather condition as text, in the active language.
///
/// The API returns English; French runs through the translation dictionary.
/// Shared so the visible label and the screen-reader label can never drift
/// apart — and so a screen reader reads a condition rather than nothing at all,
/// which is what happened while the icon carried the meaning on its own.
String describeWeather(String description, String locale) {
  if (locale == 'fr') {
    return AppConstants.translateWeatherDescription(description);
  }
  return description;
}
