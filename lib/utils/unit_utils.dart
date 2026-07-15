enum UnitSystem { metric, imperial }

/// Convert wind speed from meters per second to kilometers per hour.
double mpsToKmh(double mps) => mps * 3.6;

class UnitConverter {
  /// Temperature
  static double celsiusToFahrenheit(double celsius) => (celsius * 9 / 5) + 32;

  /// Wind speed
  static double mpsToKmh(double mps) => mps * 3.6;
  static double mpsToMph(double mps) => mps * 2.23694;

  /// Formatters
  static String formatTemperature(double celsius, UnitSystem unit) {
    if (unit == UnitSystem.imperial) {
      return '${celsiusToFahrenheit(celsius).toStringAsFixed(1)}°F';
    }
    return '${celsius.toStringAsFixed(1)}°C';
  }

  static String formatWindSpeed(double mps, UnitSystem unit) {
    if (unit == UnitSystem.imperial) {
      return '${mpsToMph(mps).toStringAsFixed(1)} mph';
    }
    return '${mpsToKmh(mps).toStringAsFixed(1)} km/h';
  }

  /// Rounded temperature string (no decimal), with degree symbol only — no unit label.
  /// Used where only ° is shown and unit label is elsewhere.
  static String formatTempRounded(double celsius, UnitSystem unit) {
    if (unit == UnitSystem.imperial) {
      return '${celsiusToFahrenheit(celsius).round()}°';
    }
    return '${celsius.round()}°';
  }
}
