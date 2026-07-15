/// Convert wind speed from meters per second to kilometers per hour.
double mpsToKmh(double mps) {
  return mps * 3.6;
}

/// Format wind speed for display, converting m/s to km/h rounded to 1 decimal.
String formatWindSpeed(double mps) {
  final kmh = mpsToKmh(mps);
  return '${kmh.toStringAsFixed(1)} km/h';
}
