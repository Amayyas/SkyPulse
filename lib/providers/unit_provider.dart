import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypulse/utils/unit_utils.dart';

class UnitNotifier extends Notifier<UnitSystem> {
  static const String _prefKey = 'unit_system';

  @override
  UnitSystem build() {
    _loadPreferences();
    return UnitSystem.metric;
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved == 'imperial') {
      state = UnitSystem.imperial;
    }
  }

  Future<void> toggle() async {
    state = state == UnitSystem.metric
        ? UnitSystem.imperial
        : UnitSystem.metric;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, state.name);
  }

  Future<void> setUnit(UnitSystem unit) async {
    state = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, unit.name);
  }
}

final unitProvider = NotifierProvider<UnitNotifier, UnitSystem>(
  UnitNotifier.new,
);
