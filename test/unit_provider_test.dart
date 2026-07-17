import 'package:flutter_test/flutter_test.dart';
import 'package:sky_pulse/providers/unit_provider.dart';
import 'package:sky_pulse/utils/unit_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('UnitProvider Race Condition', () {
    test('user choice survives async restore', () async {
      // Setup: saved is imperial
      SharedPreferences.setMockInitialValues({
        'unit_system': 'imperial',
      });

      final provider = UnitProvider();
      
      // User quickly switches to metric during load
      await provider.setUnit(UnitSystem.metric);
      
      // Load preferences (would normally run in background)
      await provider._loadPreferences();
      
      // State should remain metric (user choice)
      expect(provider.state, UnitSystem.metric);
    });
  });
}
