import 'dart:async';
// geolocator ships its own LocationServiceDisabledException; hide it so ours
// (part of the app's sealed LocationException hierarchy) is unambiguous.
import 'package:geolocator/geolocator.dart'
    hide LocationServiceDisabledException;
import 'package:skypulse/services/location_exception.dart';

class LocationService {
  static const Duration _timeout = Duration(seconds: 10);

  /// Returns the device position, or throws a [LocationException] naming the
  /// exact reason it could not — so the UI can react to each case instead of
  /// showing one generic message for all of them.
  Future<Position> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationPermissionDeniedException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionPermanentlyDeniedException();
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(_timeout);
    } on TimeoutException {
      throw const LocationTimeoutException();
    }
  }
}
