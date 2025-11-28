class CitySuggestion {
  final String name;
  final String country;
  final String state;
  final double lat;
  final double lon;

  CitySuggestion({
    required this.name,
    required this.country,
    required this.state,
    required this.lat,
    required this.lon,
  });

  factory CitySuggestion.fromJson(Map<String, dynamic> json) {
    return CitySuggestion(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  String get displayName {
    if (state.isNotEmpty) {
      return '$name, $state, $country';
    }
    return '$name, $country';
  }
}
