import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:skypulse/services/location_exception.dart'
    hide LocationServiceDisabledException;
import 'package:skypulse/services/location_exception.dart' as app;
import 'package:skypulse/services/location_service.dart';

/// Stands in for the real plugin so the permission and failure branches can be
/// driven without a device.
class _FakeGeolocator extends GeolocatorPlatform
    with MockPlatformInterfaceMixin {
  _FakeGeolocator({
    this.serviceEnabled = true,
    this.permission = LocationPermission.always,
    this.permissionAfterRequest,
    this.position,
    this.hang = false,
  });

  final bool serviceEnabled;
  final LocationPermission permission;
  final LocationPermission? permissionAfterRequest;
  final Position? position;

  /// Never completes, so the service's timeout is what ends the call.
  final bool hang;

  int requestPermissionCalls = 0;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async {
    requestPermissionCalls++;
    return permissionAfterRequest ?? permission;
  }

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) {
    if (hang) return Completer<Position>().future;
    return Future.value(position ?? _somewhere());
  }
}

Position _somewhere() => Position(
  latitude: 48.8566,
  longitude: 2.3522,
  timestamp: DateTime(2026, 8, 5),
  accuracy: 10,
  altitude: 35,
  altitudeAccuracy: 5,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  // #23 gave each failure its own type so the UI can react to it; these cover
  // the branches that produce them. The service had no tests at all before.
  group('LocationService', () {
    test('returns the position when everything is granted', () async {
      GeolocatorPlatform.instance = _FakeGeolocator(position: _somewhere());

      final position = await LocationService().getCurrentLocation();

      expect(position.latitude, 48.8566);
      expect(position.longitude, 2.3522);
    });

    test('throws when location services are switched off', () {
      GeolocatorPlatform.instance = _FakeGeolocator(serviceEnabled: false);

      expect(
        LocationService().getCurrentLocation(),
        throwsA(isA<app.LocationServiceDisabledException>()),
      );
    });

    test('asks for permission when it is merely denied', () async {
      final fake = _FakeGeolocator(
        permission: LocationPermission.denied,
        permissionAfterRequest: LocationPermission.whileInUse,
      );
      GeolocatorPlatform.instance = fake;

      await LocationService().getCurrentLocation();

      expect(
        fake.requestPermissionCalls,
        1,
        reason: 'a denied permission is worth asking for once',
      );
    });

    test('throws when the user denies the prompt', () {
      GeolocatorPlatform.instance = _FakeGeolocator(
        permission: LocationPermission.denied,
        permissionAfterRequest: LocationPermission.denied,
      );

      expect(
        LocationService().getCurrentLocation(),
        throwsA(isA<LocationPermissionDeniedException>()),
      );
    });

    // The case the UI answers with "open settings" — asking again can't help.
    test('throws a distinct error when permission is blocked for good', () {
      GeolocatorPlatform.instance = _FakeGeolocator(
        permission: LocationPermission.deniedForever,
      );

      expect(
        LocationService().getCurrentLocation(),
        throwsA(isA<LocationPermissionPermanentlyDeniedException>()),
      );
    });

    test('does not prompt again when permission is blocked for good', () async {
      final fake = _FakeGeolocator(
        permission: LocationPermission.deniedForever,
      );
      GeolocatorPlatform.instance = fake;

      await LocationService().getCurrentLocation().catchError(
        (Object _) => _somewhere(),
      );

      expect(fake.requestPermissionCalls, 0);
    });

    test('gives up rather than hanging when no fix arrives', () {
      GeolocatorPlatform.instance = _FakeGeolocator(hang: true);

      expect(
        const LocationService(
          timeout: Duration(milliseconds: 50),
        ).getCurrentLocation(),
        throwsA(isA<LocationTimeoutException>()),
      );
    });
  });
}
