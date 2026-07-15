import 'package:skypulse/services/weather_exception.dart';

class Weather {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final DateTime date;
  final int sunrise;
  final int sunset;
  final double? lat;
  final double? lon;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.date,
    required this.sunrise,
    required this.sunset,
    this.lat,
    this.lon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final sys = json['sys'];
    return Weather(
      cityName: json['name'] as String? ?? '',
      temperature: _num(json, 'main', 'temp'),
      feelsLike: _num(json, 'main', 'feels_like'),
      tempMin: _num(json, 'main', 'temp_min'),
      tempMax: _num(json, 'main', 'temp_max'),
      description: _condition(json, 'description'),
      iconCode: _condition(json, 'icon'),
      humidity: _num(json, 'main', 'humidity').round(),
      windSpeed: _optionalNum(json['wind'], 'speed'),
      date: _date(json),
      sunrise: _epoch(sys, 'sunrise'),
      sunset: _epoch(sys, 'sunset'),
      lat: _coord(json['coord'], 'lat'),
      lon: _coord(json['coord'], 'lon'),
    );
  }

  // For forecast data which has a slightly different structure
  factory Weather.fromForecastJson(Map<String, dynamic> json) {
    return Weather(
      cityName: '', // Forecast items don't have city name usually
      temperature: _num(json, 'main', 'temp'),
      feelsLike: _num(json, 'main', 'feels_like'),
      tempMin: _num(json, 'main', 'temp_min'),
      tempMax: _num(json, 'main', 'temp_max'),
      description: _condition(json, 'description'),
      iconCode: _condition(json, 'icon'),
      humidity: _num(json, 'main', 'humidity').round(),
      windSpeed: _optionalNum(json['wind'], 'speed'),
      date: _date(json),
      sunrise: 0,
      sunset: 0,
    );
  }

  // A 200 response is not a guarantee of a well-formed body. Rather than let a
  // raw TypeError or RangeError escape to the UI, every required field is
  // validated here and a missing or wrong-typed one becomes a
  // MalformedResponseException the service already knows how to surface.

  /// Required numeric field, nested under [object] (e.g. `main` -> `temp`).
  static double _num(Map<String, dynamic> json, String object, String key) {
    final value = _object(json, object)[key];
    if (value is num) return value.toDouble();
    throw MalformedResponseException('Missing or non-numeric "$object.$key"');
  }

  /// Optional numeric field: the API omits `wind` entirely in dead calm.
  static double _optionalNum(dynamic object, String key) {
    if (object is Map && object[key] is num) {
      return (object[key] as num).toDouble();
    }
    return 0;
  }

  static Map<String, dynamic> _object(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    throw MalformedResponseException('Missing object "$key"');
  }

  static DateTime _date(Map<String, dynamic> json) {
    final dt = json['dt'];
    if (dt is int) {
      return DateTime.fromMillisecondsSinceEpoch(dt * 1000);
    }
    throw MalformedResponseException('Missing or non-integer "dt"');
  }

  /// Description and icon are cosmetic: a body without a `weather` entry is
  /// unusual but not worth rejecting, so these degrade to an empty string.
  static String _condition(Map<String, dynamic> json, String key) {
    final list = json['weather'];
    if (list is List && list.isNotEmpty && list.first is Map) {
      return (list.first as Map)[key] as String? ?? '';
    }
    return '';
  }

  static int _epoch(dynamic sys, String key) {
    if (sys is Map && sys[key] is int) return sys[key] as int;
    return 0;
  }

  static double? _coord(dynamic coord, String key) {
    if (coord is Map && coord[key] is num) {
      return (coord[key] as num).toDouble();
    }
    return null;
  }
}
