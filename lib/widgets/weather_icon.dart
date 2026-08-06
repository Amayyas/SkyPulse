import 'package:flutter/material.dart';
import 'package:skypulse/utils/constants.dart';

class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;

  /// What the icon means, for screen readers.
  ///
  /// The icon is often the only thing on screen carrying the weather condition,
  /// so without this a screen-reader user gets the temperature and nothing
  /// else. Pass null only where the surrounding widget already announces the
  /// condition — inside a card labelled as a whole, say — in which case the
  /// image is marked decorative rather than left silently unlabelled.
  final String? semanticLabel;

  const WeatherIcon({
    super.key,
    required this.iconCode,
    this.size = 50,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      '${AppConstants.iconUrl}$iconCode@2x.png',
      width: size,
      height: size,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.error, size: size, semanticLabel: semanticLabel),
    );
  }
}
