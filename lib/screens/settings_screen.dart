import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skypulse/providers/unit_provider.dart';
import 'package:skypulse/utils/unit_utils.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(unitProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Unités',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: SegmentedButton<UnitSystem>(
              segments: const [
                ButtonSegment(
                  value: UnitSystem.metric,
                  label: Text('Métrique (°C, km/h)'),
                  icon: Icon(Icons.thermostat),
                ),
                ButtonSegment(
                  value: UnitSystem.imperial,
                  label: Text('Impérial (°F, mph)'),
                  icon: Icon(Icons.flag),
                ),
              ],
              selected: {unit},
              onSelectionChanged: (Set<UnitSystem> selection) {
                ref.read(unitProvider.notifier).setUnit(selection.first);
              },
            ),
          ),
          const Divider(height: 32),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Aperçu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.thermostat),
            title: const Text('Température (25 °C)'),
            trailing: Text(
              UnitConverter.formatTemperature(25, unit),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.air),
            title: const Text('Vent (5.14 m/s)'),
            trailing: Text(
              UnitConverter.formatWindSpeed(5.14, unit),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
