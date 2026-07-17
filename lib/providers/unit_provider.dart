import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/unit_utils.dart';

final unitProvider = StateNotifierProvider<UnitProvider, UnitSystem>((ref) {
  return UnitProvider();
});

class UnitProvider extends StateNotifier<UnitSystem> {
  static const String _prefKey = 'unit_system';
  bool _userChanged = false;  // ← KEY: tracks user action

  UnitProvider() : super(UnitSystem.metric) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // ✅ Only restore if user hasn't changed it
    if (!_userChanged && prefs.getString(_prefKey) == 'imperial') {
      state = UnitSystem.imperial;
    }
  }

  Future<void> setUnit(UnitSystem unit) async {
    _userChanged = true;  // ✅ SET BEFORE ANY AWAIT - THIS IS THE KEY!
    state = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, unit.name);
  }

  Future<void> toggle() async {
    final newState = state == UnitSystem.metric 
        ? UnitSystem.imperial 
        : UnitSystem.metric;
    await setUnit(newState);  // ✅ Reuse setUnit
  }
}
