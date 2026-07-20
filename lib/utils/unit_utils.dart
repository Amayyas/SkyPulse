enum UnitSystem { metric, imperial }

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

  /// Pressure: hPa (metric) / inHg (imperial).
  static double hPaToInHg(double hPa) => hPa * 0.02952998;

  static String formatPressure(int hPa, UnitSystem unit) {
    if (unit == UnitSystem.imperial) {
      return '${hPaToInHg(hPa.toDouble()).toStringAsFixed(2)} inHg';
    }
    return '$hPa hPa';
  }

  /// Visibility, given in metres: km (metric) / miles (imperial).
  static String formatVisibility(int metres, UnitSystem unit) {
    final km = metres / 1000;
    if (unit == UnitSystem.imperial) {
      return '${(km * 0.621371).toStringAsFixed(1)} mi';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  /// Wind direction in degrees to an 8-point French compass label.
  static String windCardinal(int degrees) {
    const points = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
    return points[(((degrees % 360) / 45).round()) % 8];
  }
}
