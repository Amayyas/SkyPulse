import 'package:flutter/material.dart';
import 'package:skypulse/utils/constants.dart';

class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;

  const WeatherIcon({super.key, required this.iconCode, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      '${AppConstants.iconUrl}$iconCode@2x.png',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.error, size: size),
    );
  }
}
