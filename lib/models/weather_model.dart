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
    return Weather(
      cityName: json['name'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '',
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      sunrise: json['sys']['sunrise'] != null
          ? (json['sys']['sunrise'] as int)
          : 0,
      sunset: json['sys']['sunset'] != null
          ? (json['sys']['sunset'] as int)
          : 0,
      lat: json['coord'] != null
          ? (json['coord']['lat'] as num).toDouble()
          : null,
      lon: json['coord'] != null
          ? (json['coord']['lon'] as num).toDouble()
          : null,
    );
  }

  // For forecast data which has a slightly different structure
  factory Weather.fromForecastJson(Map<String, dynamic> json) {
    return Weather(
      cityName: '', // Forecast items don't have city name usually
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '',
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      sunrise: 0,
      sunset: 0,
    );
  }
}
