import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skypulse/providers/unit_provider.dart';
import 'package:skypulse/utils/unit_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('UnitProvider Race Condition', () {
    test('user choice survives async restore', () async {
      // Setup: saved is imperial
      SharedPreferences.setMockInitialValues({'unit_system': 'imperial'});

      final container = ProviderContainer();
      final provider = container.read(unitProvider.notifier);

      // User quickly switches to metric during load
      await provider.setUnit(UnitSystem.metric);

      // Allow the async preference load to complete
      await Future.delayed(Duration.zero);

      // State should remain metric (user choice)
      expect(container.read(unitProvider), UnitSystem.metric);
    });
  });
}
